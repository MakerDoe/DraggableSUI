local Types = require(script.Parent.Types)

local FRONT_BACK_SIZE = { X = "X", Y = "Y" }
local RIGHT_LEFT_SIZE = { X = "Z", Y = "Y" }
local TOP_BOTTOM_SIZE = { X = "Z", Y = "X" }

local NORMALID_OBJECT = {
	[Enum.NormalId.Front] = {
		Size = FRONT_BACK_SIZE,
	},
	[Enum.NormalId.Back] = {
		Size = FRONT_BACK_SIZE,
	},

	[Enum.NormalId.Right] = {
		Size = RIGHT_LEFT_SIZE,
	},
	[Enum.NormalId.Left] = {
		Size = RIGHT_LEFT_SIZE,
	},

	[Enum.NormalId.Top] = {
		Size = TOP_BOTTOM_SIZE,
	},
	[Enum.NormalId.Bottom] = {
		Size = TOP_BOTTOM_SIZE,
	},
}

local UserInputService = game:GetService("UserInputService")
local PlayerObject = game:GetService("Players").LocalPlayer

local Camera = workspace.CurrentCamera

local AtOffsets: Types.DragAt<Vector2> = {
	Vector2.new(0, 0),
	Vector2.new(0.5, 0),
	Vector2.new(1, 0),

	Vector2.new(0, 0.5),
	Vector2.new(0.5, 0.5),
	Vector2.new(1, 0.5),

	Vector2.new(0, 1),
	Vector2.new(0.5, 1),
	Vector2.new(1, 1),
}

local GetFaceCenter = {
	[Enum.NormalId.Front] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = cFrame.LookVector
		cFrame = cFrame + lookVector * partHalfSize.Z

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, cFrame.UpVector)
	end,
	[Enum.NormalId.Back] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = -cFrame.LookVector
		cFrame = cFrame + lookVector * partHalfSize.Z

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, cFrame.UpVector)
	end,

	[Enum.NormalId.Right] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = cFrame.RightVector
		cFrame = cFrame + lookVector * partHalfSize.X

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, cFrame.UpVector)
	end,
	[Enum.NormalId.Left] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = -cFrame.RightVector
		cFrame = cFrame + lookVector * partHalfSize.X

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, cFrame.UpVector)
	end,

	[Enum.NormalId.Top] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = cFrame.UpVector
		cFrame = cFrame + lookVector * partHalfSize.Y

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, -cFrame.RightVector)
	end,
	[Enum.NormalId.Bottom] = function(cFrame: CFrame, partHalfSize: Vector2): CFrame
		local lookVector = -cFrame.UpVector
		cFrame = cFrame + lookVector * partHalfSize.Y

		local position = cFrame.Position
		return CFrame.lookAt(position, position + lookVector, cFrame.RightVector)
	end,
}

local function GetWorldMousePositionRaycastResult(
	self,
	raycastParams: RaycastParams,
	returnMouseRay: boolean?
): (RaycastResult, Ray?)
	local mouseLocation = UserInputService:GetMouseLocation()
	local mouseRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

	if not raycastParams then
		raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { PlayerObject.Character }
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	end

	return workspace:Raycast(mouseRay.Origin, mouseRay.Direction * self._Config.MaxDistance, raycastParams),
		if returnMouseRay then mouseRay else nil
end

local Methods = {}

function Methods:GetTopMostGuiObject(surfaceGui: SurfaceGui): GuiObject?
	if not surfaceGui then
		return
	end

	local mouseLocation = Methods.GetLocation(self, surfaceGui)

	for _, guiObject: GuiObject in ipairs(surfaceGui:GetDescendants()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local size = guiObject.AbsoluteSize
		local position = guiObject.AbsolutePosition

		local position_size = position + size

		if
			(mouseLocation.X >= position.X and mouseLocation.X <= position_size.X)
			and (mouseLocation.Y >= position.Y and mouseLocation.Y <= position_size.Y)
		then
			return guiObject
		end
	end
end

function Methods.GetAtOffset(dragAt: Types.DragAt): Vector2
	return AtOffsets[dragAt.__value + 1]
end

function Methods.GetCameraCFrame()
	return Camera.CFrame
end

function Methods.GetMouseRay()
	local mouseLocation = UserInputService:GetMouseLocation()

	return Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
end

function Methods:IsMouseTargetPart(part: BasePart): boolean
	local raycastResult = GetWorldMousePositionRaycastResult(self) or {}

	return raycastResult.Instance == part
end

function Methods:GetWorldCFrame(raycastParams: RaycastParams?): CFrame?
	local raycastResult, mouseRay = GetWorldMousePositionRaycastResult(self, raycastParams, true)

	if not raycastResult then
		local maxDistance = self._Config.MaxDistance

		local direction = mouseRay.Direction
		local origin = mouseRay.Origin

		local hit = origin + direction

		return CFrame.new(hit * maxDistance, hit * (maxDistance + 1))
	else
		local position = raycastResult.Position
		return CFrame.new(position, position + mouseRay.Direction)
	end
end

function Methods:GetWorldPosition(raycastParams: RaycastParams?): Vector3
	local raycastResult, mouseRay = GetWorldMousePositionRaycastResult(self, raycastParams, true)

	return if raycastResult
		then raycastResult.Position
		else mouseRay.Origin + mouseRay.Direction * self._Config.MaxDistance
end

local function GetPixelPerStud(surfaceGui: SurfaceGui, partSize: Vector3): Vector3
	local normalIdObject = NORMALID_OBJECT[surfaceGui.Face]
	local size = normalIdObject.Size

	local pixelSizePerStud = surfaceGui.CanvasSize / Vector2.new(partSize[size.X], partSize[size.Y])

	return Vector3.new(pixelSizePerStud.X, pixelSizePerStud.Y, 0)
end

local function DebugMode(self, mouseCFrame: CFrame)
	local pointPart: Part = self.__PointPart

	if not pointPart then
		return
	end

	pointPart.CFrame = mouseCFrame
end

function Methods:GetLocation(surfaceGui: SurfaceGui): Vector2
	local part: BasePart = surfaceGui.Adornee or surfaceGui.Parent

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { part }
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

	local partHalfSize = part.Size / 2

	local faceCenter = GetFaceCenter[surfaceGui.Face](part.CFrame, partHalfSize)
	local mouseCFrame: CFrame

	do
		local cameraPosition = Methods.GetCameraCFrame().Position

		local relativeCameraPosition = faceCenter:PointToObjectSpace(cameraPosition)
		local diff = relativeCameraPosition - faceCenter:PointToObjectSpace(cameraPosition + Methods.GetMouseRay().Direction)

		mouseCFrame =
			faceCenter:ToWorldSpace(CFrame.new(relativeCameraPosition - (diff / diff.Z) * relativeCameraPosition.Z))

		local debugMode = self._DebugMode

		if debugMode then
			if not debugMode.__Active then
				debugMode.__Active = true

				local pointPart = Instance.new("Part")

				pointPart.Size = debugMode.Size or Vector3.new(0.25, 0.25, 0.25)
				pointPart.Material = debugMode.Material or Enum.Material.Neon
				pointPart.Color = debugMode.Color or Color3.new(0, 1, 0)
				pointPart.Shape = debugMode.Shape or Enum.PartType.Ball
				pointPart.Transparency = debugMode.Transparency or 0
				pointPart.CanCollide = false
				pointPart.CanTouch = false
				pointPart.CanQuery = false
				pointPart.Anchored = true
				pointPart.Parent = part

				debugMode.__PointPart = pointPart
			end

			DebugMode(debugMode, mouseCFrame)
		end
	end

	local sizeObject = NORMALID_OBJECT[surfaceGui.Face].Size

	local relativePosition = (
		Vector3.new(partHalfSize[sizeObject.X], partHalfSize[sizeObject.Y], 0)
		- faceCenter:PointToObjectSpace(mouseCFrame.Position)
	)
		* if surfaceGui.SizingMode == Enum.SurfaceGuiSizingMode.FixedSize
		then GetPixelPerStud(surfaceGui, part.Size)
		else surfaceGui.PixelsPerStud

	return Vector2.new(relativePosition.X, relativePosition.Y)
end

return Methods
