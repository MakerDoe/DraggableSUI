local CustomEnum = require(script.Parent.CustomEnum)
local Types = require(script.Parent.Types)

local ConfigDataTypes: Types.DraggableConfig<string> = {
	LimitNoPivot = "boolean",
	Horizontal = "boolean",
	ByOffset = "boolean",
	Vertical = "boolean",
	Circular = "boolean",
	Limit = "boolean",

	Ignore = "table",
	DragAt = "table",

	DragAtOffset = "Vector2",
	Tween = "TweenInfo",

	CircleSize = "number",
	MaxDistance = "number",
}

local LimitConfigDataTypes: LimitConfig<string> = {
	NoPivot = "boolean",
	Circular = "boolean",

	CircleSize = "number",
}

local DefaultConfigs: Types.DraggableConfig = {
	Horizontal = true,
	ByOffset = false,
	Circular = false,
	Vertical = true,
	DragAt = false,
	Limit = false,
	Tween = false,

	DragAtOffset = Vector2.new(0, 0),
	MaxDistance = 40,
}

local Validation = {
	DragAt = CustomEnum.new({
		"TopLeft",
		"TopCenter",
		"TopRight",

		"CenterLeft",
		"Center",
		"CenterRight",

		"BottomLeft",
		"BottomCenter",
		"BottomRight",
	}) :: Types.DragAt,
}

function Validation.IsValidLimitConfig(config: LimitConfig): (boolean, Message?)
	for key, value in pairs(config) do
		local configType = LimitConfigDataTypes[key]
		local valueType = typeof(value)

		if configType == nil then
			return false, ("%s is not a valid key"):format(key)
		end

		if not (valueType == configType) then
			return false, ("%s must be a %s; got %s"):format(key, configType, valueType)
		end
	end

	return true
end

function Validation.SetConfig(self: ColorPicker, config: ColorPickerConfig)
	for key, value in pairs(config) do
		self._Config[key] = value
	end
end

function Validation.IsMouseOrTouch(input: InputObject, isMouseMovement: boolean?): boolean
	return input.UserInputType
			== (if isMouseMovement then Enum.UserInputType.MouseMovement else Enum.UserInputType.MouseButton1)
		or input.UserInputType == Enum.UserInputType.Touch
end

function Validation.SetDefaultConfig(config: Types.DraggableConfig)
	for key, default in pairs(DefaultConfigs) do
		if config[key] == nil then
			config[key] = default
		end
	end
end

function Validation.IsValidParameters(guiObject: GuiObject, config: Types.DraggableConfig): (boolean, Message?)
	if not (typeof(guiObject) == "Instance") then
		return false, "Argument #1 must be a instance; got " .. typeof(guiObject)
	end

	if not (guiObject:IsA("GuiObject")) then
		return false, "Argument #1 must be a GuiObject; got " .. guiObject.ClassName
	end

	if not (typeof(config) == "table") then
		return false, "Argument #2 must be a table; got " .. typeof(config)
	end

	for key, value in pairs(config) do
		local configType = ConfigDataTypes[key]
		local valueType = typeof(value)

		if configType == nil then
			return false, ("Argument #2 %s is not a valid key"):format(key)
		end

		if not (valueType == configType) then
			return false, ("Argument #2 %s must be a %s; got %s"):format(key, configType, valueType)
		end
	end

	local dragAt = config.DragAt

	if dragAt and not CustomEnum.Is(dragAt) then
		return false, "Argument #2 DragAt is not a valid DragAt; got " .. typeof(dragAt)
	end

	return true
end

return Validation
