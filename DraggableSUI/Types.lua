local SignalTypes = require(script.Parent.Signal.Types)
local CustomEnum = require(script.Parent.CustomEnum)

export type Draggable = {
	ForceStartDrag: (self: Draggable, dragAt: DragAt?, dragAtOffset: Vector2?) -> (),
	SetDragAt: (self: Draggable, dragAt: DragAt?, dragAtOffset: Vector2?) -> (),
	Ignore: (self: Draggable, list: { GuiObject }, protected: boolean?) -> (),
	ActivateFrom: (self: Draggable, guiObject: GuiObject) -> (),
	SetTweenInfo: (self: Draggable, tweenInfo: TweenInfo) -> (),
	EnableLimit: (self: Draggable, config: LimitConfig?) -> (),
	IgnoreDescendants: (self: Draggable) -> (),
	IgnoreChildren: (self: Draggable) -> (),
	IsActive: (self: Draggable) -> boolean,
	ForceEndDrag: (self: Draggable) -> (),
	DisableLimit: (self: Draggable) -> (),
	Disable: (self: Draggable) -> (),
	Destroy: (self: Draggable) -> (),
	Enable: (self: Draggable) -> (),

	ListenAllEvent: (
		self: Draggable,
		func: (mousePosition: Vector2, ...any?) -> (),
		funcSelf: {}?,
		...any?
	) -> {
		["start"]: SignalTypes.SignalConnection,
		["move"]: SignalTypes.SignalConnection,
		["end"]: SignalTypes.SignalConnection,
	},

	EventListener: (
		self: Draggable,
		eventType: "start" | "end" | "move",
		func: (mousePosition: Vector2, ...any?) -> (),
		funcSelf: {}?,
		...any?
	) -> SignalTypes.SignalConnection,

	Released: SignalTypes.Event,
	Began: SignalTypes.Event,
	Moved: SignalTypes.Event,
}

export type DraggableConfig = {
	LimitNoPivot: boolean?,
	Horizontal: boolean?,
	ByOffset: boolean?,
	Vertical: boolean?,
	Circular: boolean?,
	Limit: boolean?,

	Ignore: { GuiObject }?,
	Tween: TweenInfo?,

	DragAtOffset: Vector2?,
	DragAt: DragAt?,

	CircleSize: number?,
}

export type LimitConfig = {
	NoPivot: boolean,
	Circular: boolean,

	CircleSize: number,
}

type TopLeft = CustomEnum.EnumItem
type TopCenter = CustomEnum.EnumItem
type TopRight = CustomEnum.EnumItem

type CenterLeft = CustomEnum.EnumItem
type Center = CustomEnum.EnumItem
type CenterRight = CustomEnum.EnumItem

type BottomLeft = CustomEnum.EnumItem
type BottomCenter = CustomEnum.EnumItem
type BottomRight = CustomEnum.EnumItem

export type DragAt = {
	TopLeft: TopLeft,
	TopCenter: TopCenter,
	TopRight: TopRight,

	CenterLeft: CenterLeft,
	Center: Center,
	CenterRight: CenterRight,

	BottomLeft: BottomLeft,
	BottomCenter: BottomCenter,
	BottomRight: BottomRight,
}

export type DebugModeConfig = {
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	Transparency: number?,
	Color: Color3?,
	Size: Vector3?,
}

return 0
