-- DraggableSUI v1

local SignalTypes = require(script.Signal.Types)
local CustomEnum = require(script.CustomEnum)
local Validation = require(script.Validation)
local Methods = require(script.Methods)
local Signal = require(script.Signal)
local Types = require(script.Types)

local EVENT_TYPES = { "Began", "Released", "Moved" }
local EVENT_KEYS = { "start", "end", "move" }

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DraggableSUI = { DragAt = Validation.DragAt }
DraggableSUI.__index = DraggableSUI
DraggableSUI.__tostring = function()
	return "Draggable"
end

function DraggableSUI.new(guiObject: GuiObject, config: Types.DraggableConfig, _debugMode: {})
	config = config or {}

	do
		local success, message = Validation.IsValidParameters(guiObject, config)

		if not success then
			error(message)
		end
	end

	local self = setmetatable({
		_Released = Signal.new() :: SignalTypes.Signal,
		_Began = Signal.new() :: SignalTypes.Signal,
		_Moved = Signal.new() :: SignalTypes.Signal,

		_Connections = {} :: { RBXScriptConnection },
		_OverlappingUI = {} :: { [GuiObject]: boolean? },
		_Config = {} :: Types.DraggableConfig,
		_MouseActions = {
			Button1Down = false,
			OnUI = false,

			From = {} :: { [GuiObject]: boolean? },
		},

		_SurfaceGui = guiObject:FindFirstAncestorOfClass("SurfaceGui"),
		_UIStartPosition = guiObject.AbsolutePosition,
		_DebugMode = _debugMode,
		_GuiObject = guiObject,

		_DragStartPosition = Vector2.new(),
		_OldPosition = Vector3.new(),
		_DragAt = Vector2.new(),

		_Disabled = false,
	}, DraggableSUI)

	self.Released = self._Released.Event
	self.Began = self._Began.Event
	self.Moved = self._Moved.Event

	do
		local success: boolean, result: Message? = pcall(self._Initialize, self, config)

		if not success then
			error(("Something went wrong::%s"):format(result))
		end
	end

	return self
end

function DraggableSUI:_Initialize(_config: Types.DraggableConfig)
	Validation.SetConfig(self, _config)
	Validation.SetDefaultConfig(self._Config)

	local config: Types.DraggableConfig = self._Config
	local guiObject: GuiObject = self._GuiObject
	local mouseActions = self._MouseActions

	local ignorelist = config.Ignore

	if config.Circular or config.CircleSize or config.LimitNoPivot then
		config.Limit = true
	end

	if ignorelist then
		self:Ignore(ignorelist, true)
		table.clear(ignorelist)
	end

	self:_InsertConnection(guiObject.MouseEnter:Connect(function()
		mouseActions.OnUI = true
	end))

	self:_InsertConnection(guiObject.MouseLeave:Connect(function()
		mouseActions.OnUI = false
	end))

	self:_InsertConnection(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not Validation.IsMouseOrTouch(input) or self._Disabled or gameProcessedEvent then
			return
		end

		local isHoveringAt = self:_IsHoveringAtActiveFrom()

		if not (mouseActions.OnUI or isHoveringAt) then
			return
		end

		self:_StartDrag(nil, nil, nil, isHoveringAt)
	end))

	self:_InsertConnection(UserInputService.InputEnded:Connect(function(input)
		if not (Validation.IsMouseOrTouch(input) and mouseActions.Button1Down) or self._Disabled then
			return
		end

		self:_EndDrag()
	end))
end

function DraggableSUI:_InsertConnection(connection: RBXScriptConnection)
	table.insert(self._Connections, connection)
end

function DraggableSUI:_Drag()
	local config: Types.DraggableConfig = self._Config
	local surfaceGui: SurfaceGui = self._SurfaceGui
	local guiObject: GuiObject = self._GuiObject

	local uiStartPosition = self._UIStartPosition
	local mouseLocation = Methods.GetLocation(self, surfaceGui)

	local delta = mouseLocation - self._DragStartPosition
	local vectorPosition = uiStartPosition + delta + self._DragAt
	local uDimPosition: UDim2

	vectorPosition = Vector2.new(
		if config.Horizontal then vectorPosition.X else uiStartPosition.X,
		if config.Vertical then vectorPosition.Y else uiStartPosition.Y
	)

	if config.Limit then
		vectorPosition = self:_LimitDraggable(vectorPosition)
	end

	if config.ByOffset then
		uDimPosition = UDim2.fromOffset(vectorPosition.X, vectorPosition.Y)
	else
		local position = vectorPosition / guiObject.Parent.AbsoluteSize
		uDimPosition = UDim2.fromScale(position.X, position.Y)
	end

	if typeof(config.Tween) == "TweenInfo" then
		TweenService:Create(guiObject, config.Tween, { Position = uDimPosition }):Play()
	else
		guiObject.Position = uDimPosition
	end

	if not (self._OldPosition == vectorPosition) then
		self._OldPosition = vectorPosition
		self._Moved:Fire(mouseLocation)
	end
end

function DraggableSUI:_StartDrag(
	dragAt: Types.DragAt,
	dragAtOffset: Vector2,
	forceDrag: boolean?,
	isActiveFrom: boolean?
)
	local guiObject: GuiObject = self._GuiObject
	local surfaceGui: SurfaceGui = guiObject:FindFirstAncestorOfClass("SurfaceGui")

	if not forceDrag then
		if
			not surfaceGui
			or not Methods.IsMouseTargetPart(self, surfaceGui.Adornee or surfaceGui.Parent)
				and not (Methods.GetTopMostGuiObject(self, surfaceGui) == guiObject or isActiveFrom)
		then
			return
		end

		for _, value in pairs(self._OverlappingUI) do
			if value then
				return
			end
		end
	end

	local mouseLocation = Methods.GetLocation(self, surfaceGui)
	local config: Types.DraggableConfig = self._Config
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	dragAtOffset = dragAtOffset or config.DragAtOffset
	dragAt = dragAt or config.DragAt

	self._UIStartPosition = position + size * guiObject.AnchorPoint - guiObject.Parent.AbsolutePosition
	self._DragStartPosition = mouseLocation
	self._SurfaceGui = surfaceGui

	self._DragAt = if dragAt
		then (mouseLocation - position - size * Methods.GetAtOffset(dragAt)) - dragAtOffset
		else Vector2.new()

	self._MouseActions.Button1Down = true
	self._Began:Fire(mouseLocation)
	self._Connections.RenderStepped = RunService.RenderStepped:Connect(function()
		self:_Drag()
	end)
end

function DraggableSUI:_EndDrag()
	local connection = self._Connections.RenderStepped
	local debugMode = self._DebugMode

	if connection then
		connection:Disconnect()
	end

	self._MouseActions.Button1Down = false
	self._Released:Fire(Methods.GetLocation(self, self._SurfaceGui))

	if debugMode then
		debugMode.__PointPart:Destroy()
		debugMode.__Active = false
	end
end

function DraggableSUI:_LimitDraggable(position: Vector2): Vector2
	local config: Types.DraggableConfig = self._Config
	local guiObject: GuiObject = self._GuiObject

	local parent: GuiObject = guiObject.Parent
	local parentSize = parent.AbsoluteSize

	if config.Circular then
		return self:_Circular(position, parentSize)
	elseif config.LimitNoPivot then
		return Vector2.new(math.clamp(position.X, 0, parentSize.X), math.clamp(position.Y, 0, parentSize.Y))
	end

	local uiSize = guiObject.AbsoluteSize
	local offset = uiSize * guiObject.AnchorPoint
	local edge = (parentSize - uiSize) + offset

	return Vector2.new(
		math.clamp(position.X, math.min(offset.X, edge.X), math.max(offset.X, edge.X)),
		math.clamp(position.Y, math.min(offset.Y, edge.Y), math.max(offset.Y, edge.Y))
	)
end

function DraggableSUI:_Circular(position: Vector2, parentSize: Vector2): Vector2
	local halfSize = parentSize / 2
	local difference = position - halfSize
	local radius = self._Config.CircleSize or math.min(halfSize.X, halfSize.Y)

	local radian = math.atan2(difference.Y, difference.X)
	local max = math.clamp(difference.Magnitude, 0, radius)
	local cosine, sine = math.cos(radian), math.sin(radian)

	return Vector2.new(max * cosine, max * sine) + halfSize
end

function DraggableSUI:_Ignore(guiObject: GuiObject)
	self:_InsertConnection(guiObject.MouseEnter:Connect(function()
		self._OverlappingUI[guiObject] = 1
	end))

	self:_InsertConnection(guiObject.MouseLeave:Connect(function()
		self._OverlappingUI[guiObject] = nil
	end))
end

function DraggableSUI:_IsHoveringAtActiveFrom(): boolean
	for _, value in pairs(self._MouseActions.From) do
		if value then
			return true
		end
	end

	return false
end

function DraggableSUI:_ActivateFrom(guiObject: GuiObject)
	local from = self._MouseActions.From

	self:_InsertConnection(guiObject.MouseEnter:Connect(function()
		from[guiObject] = true
	end))

	self:_InsertConnection(guiObject.MouseLeave:Connect(function()
		from[guiObject] = nil
	end))
end

function DraggableSUI:_EventListener(
	eventType: string,
	func: (mouseLocation: Vector2, ...any?) -> (),
	funcSelf: {}?,
	...
): SignalTypes.SignalConnection
	local args = { ... }

	if funcSelf then
		return self[eventType]:Connect(function(mouseLocation)
			func(funcSelf, mouseLocation, unpack(args))
		end)
	end

	return self[eventType]:Connect(function(mouseLocation)
		func(mouseLocation, unpack(args))
	end)
end

function DraggableSUI:ListenAllEvent(
	func: (mousePosition: Vector2, ...any?) -> (),
	funcSelf: {}?,
	...
): {
	["start"]: SignalTypes.SignalConnection,
	["move"]: SignalTypes.SignalConnection,
	["end"]: SignalTypes.SignalConnection,
}
	if not (typeof(func) == "function") then
		error("Argument #1 must be a funciton; got " .. typeof(func))
	end

	if funcSelf and not (typeof(funcSelf) == "table") then
		error("Argument #2 must be a table; got " .. typeof(funcSelf))
	end

	local connections = {}

	for index, eventType in ipairs(EVENT_TYPES) do
		connections[EVENT_KEYS[index]] = self:_EventListener(eventType, func, funcSelf, ...)
	end

	return connections
end

function DraggableSUI:EventListener(
	eventType: "start" | "end" | "move",
	func: (mousePosition: Vector2) -> (),
	funcSelf: {}?,
	...
): SignalTypes.SignalConnection
	if not (typeof(eventType) == "string") then
		error("Argument #1 must be a string; got " .. typeof(eventType))
	end

	eventType = eventType:lower()

	if not (typeof(func) == "function") then
		error("Argument #2 must be a funciton; got " .. typeof(func))
	end

	if funcSelf and not (typeof(funcSelf) == "table") then
		error("Argument #3 must be a table; got " .. typeof(funcSelf))
	end

	if eventType == "start" then
		eventType = "Began"
	elseif eventType == "end" then
		eventType = "Released"
	elseif eventType == "move" then
		eventType = "Moved"
	else
		error("Argument #1 is not a valid event type; got " .. eventType)
	end

	return self:_EventListener(eventType, func, funcSelf, ...)
end

function DraggableSUI:ActivateFrom(guiObject: GuiObject)
	if not (typeof(guiObject) == "Instance") then
		error("Argument #1 must be a Instance; got " .. typeof(guiObject))
	end

	if not guiObject:IsA("GuiObject") then
		error("Argument #1 must be a GuiObject; got " .. guiObject.ClassName)
	end

	self:_ActivateFrom(guiObject)
end

function DraggableSUI:SetDragAt(dragAt: Types.DragAt, dragAtOffset: Vector2?)
	if not CustomEnum.Is(dragAt) then
		error("Argument #1 must be a DragAt; got " .. typeof(dragAt))
	end

	if dragAtOffset and not (typeof(dragAtOffset) == "Vector2") then
		error("Argument #2 must be a Vector2; got " .. typeof(dragAtOffset))
	end

	local config: Types.DraggableConfig = self._Config

	config.DragAt = dragAt
	config.DragAtOffset = dragAtOffset or Vector2.new(0, 0)
end

function DraggableSUI:EnableLimit(config: Types.LimitConfig?)
	local _config: Types.DraggableConfig = self._Config

	if config then
		if not (typeof(config) == "table") then
			error("Argument #1 must be a table; got " .. typeof(config))
		end

		local success, message = Validation.IsValidLimitConfig(config)

		if not success then
			error("Argument #1 " .. message)
		end

		_config.LimitNoPivot = if not (config.NoPivot == nil) then config.NoPivot else _config.LimitNoPivot
		_config.CircleSize = if not (config.CircleSize == nil) then config.CircleSize else _config.CircleSize
		_config.Circular = if not (config.Circular == nil) then config.Circular else _config.Circular
	end

	_config.Limit = true
end
function DraggableSUI:DisableLimit()
	self._Config.Limit = false
end

function DraggableSUI:ForceStartDrag(dragAt: Types.DragAt?, dragAtOffset: Vector2?)
	if self._Disabled then
		return
	end

	if dragAt and not CustomEnum.Is(dragAt) then
		error("Argument #1 must be a DragAt; got " .. typeof(dragAt))
	end

	if dragAtOffset and not (typeof(dragAtOffset) == "Vector2") then
		error("Argument #2 must be a Vector2; got " .. typeof(dragAtOffset))
	end

	self:_StartDrag(dragAt, dragAtOffset, true)
end

function DraggableSUI:ForceEndDrag()
	if not self:IsActive() then
		return
	end

	self:_EndDrag()
end

function DraggableSUI:Enable()
	self._Disabled = false
end

function DraggableSUI:Disable()
	self._MouseActions.Button1Down = false
	self._Disabled = true
end

function DraggableSUI:SetTweenInfo(tweenInfo: TweenInfo)
	if not (typeof(tweenInfo) == "TweenInfo") then
		error("Argument #1 must be a TweenInfo; got " .. typeof(tweenInfo))
	end

	self._Config.Tween = tweenInfo
end

function DraggableSUI:IsActive(): boolean
	return self._MouseActions.Button1Down
end

function DraggableSUI:Ignore(list: { GuiObject }, protected: boolean?)
	protected = protected or false

	if not (typeof(list) == "table") then
		error("Argument #1 must be a table; got" .. typeof(list))
	end

	if not (typeof(protected) == "boolean") then
		error("Argument #2 must be a boolean; got" .. typeof(protected))
	end

	local success = pcall(function()
		if protected then
			for _, object in ipairs(list) do
				pcall(self._Ignore, self, object)
			end

			return
		end

		for _, object in ipairs(list) do
			self:_Ignore(object)
		end
	end)

	if not success then
		error("It seems that the array contained a none GuiObject")
	end
end

function DraggableSUI:IgnoreChildren()
	self:Ignore(self._GuiObject:GetChildren(), true)
end

function DraggableSUI:IgnoreDescendants()
	self:Ignore(self._GuiObject:GetDescendants(), true)
end

function DraggableSUI:Destroy()
	for _, connection: RBXScriptSignal in ipairs(self._Connections) do
		if typeof(connection) == "RBXScriptSignal" then
			connection:Disconnect()
		end
	end

	for key, _ in pairs(self._IgnoreList) do
		self._IgnoreList[key] = nil
	end

	self._Released:Destroy()
	self._Began:Destroy()
	self._Moved:Destroy()

	table.clear(self)
end

return DraggableSUI :: {
	new: (guiObject: GuiObject, config: Types.DraggableConfig?) -> Types.Draggable,
	DragAt: Types.DragAt,
}
