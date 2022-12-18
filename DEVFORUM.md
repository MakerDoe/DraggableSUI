# Draggable For SurfaceGui

<hr />

The draggable property is still usable, but it is deprecated. Thus, I created this module; **the module allows you to make a [GuiObject]["guiobject"] draggable for _[SurfaceGui]["surfacegui"]_ with any [NormalId]["normalid"].**

## Preview

<hr />

https://user-images.githubusercontent.com/109215379/208297604-5affb9c1-1015-4200-b282-ca8db6dc73f5.mp4

The green dot is simply a representation of where the mouse point is in relation to the normal ID of the part surface GUI. **This is disabled by default.**

## Constructors

<hr />

```lua
DraggableSUI.new: (guiObject: GuiObject, config: DraggableConfig?) -> Draggable
```

Creates a new object of type Draggable. The parameter `config` is a type of [DraggableConfig](#draggableconfig); this is optional. There is also a hidden parameter, which is the `_debugMode` type of [DebugModeConfig](#debugmodeconfig), which is what you saw in the [preview video](#preview).

## Special

<hr />

```
DraggableSUI.DragAt :: DragAt
```

[DragAt](#dragat) is a custom enum that allows you to set where the GuiObject starts dragging, relative to the location of the mouse.

## Basic Usage

<hr />

```lua
local DraggableSUI = require(game:GetService("ReplicatedStorage"):WaitForChild("DraggableSUI"))

local DraggableFrame = DraggableSUI.new(script.Parent)
```

Once you have created a draggable, you may now use the methods listed below.

## Methods

<hr />

<details><summary><b id="activatefrom" style="font-size: 1.25rem">ActivateFrom</b></summary>

When the mouse is over the GuiObject, the draggable will be activated when mouse button 1 is down.

</details>

```lua
ActivateFrom: (self: Draggable, guiObject: GuiObject) -> ()
```

<details><summary><b id="destroy" style="font-size: 1.25rem">Destroy</b></summary>

This method disconnects all connections and destroys all signals. This method is called when the GuiObject is destroyed.

</details>

```lua
Destroy: (self: Draggable) -> ()
```

<details><summary><b id="disable" style="font-size: 1.25rem">Disable</b></summary>

This method forces the dragging to stop and sets the Disabled property to true. **This is false by default.**

</details>

```lua
Disable: (self: Draggable) -> ()
```

<details><summary><b id="disablelimit" style="font-size: 1.25rem">DisableLimit</b></summary>

This allows the draggable to be dragged anywhere on the surface gui. **This is disabled by default.**

</details>

```lua
DisableLimit: (self: Draggable) -> ()
```

<details><summary><b id="enable" style="font-size: 1.25rem">Enable</b></summary>

This method sets the Disabled property to false; if the [Disabled](#disabled) method is called while the draggable is active, the dragging continues. **This is true by default.**

</details>

```lua
Enable: (self: Draggable) -> ()
```

<details><summary><b id="enablelimit" style="font-size: 1.25rem">EnableLimit</b></summary>

This method allows you to limit the draggable, as seen in the [preview video](#preview). The parameter `config` is a type of [LimitConfig](#limitconfig); this is optional.

</details>

```lua
EnableLimit: (self: Draggable, config: LimitConfig?) -> ()
```

<details><summary><b id="eventlistener" style="font-size: 1.25rem">EventListener</b></summary>

This method allows you to listen for signals such as `"start"`, `"end"`, or `"move"`. The **start** fires when the client has pressed mouse button 1 while hovering over the GuiObject. The **end** fires when the client releases mouse button 1 while the draggable is active. Lastly, the **move** fires when the GuiObject has been dragged. All of this signal fires with the mouse location on the surface gui. The parameter `funcSelf` is a [table]["{}"] where the first parameter of the func is set to self, while the parameter `...any?` is for extra information for the func; this is passed after `mouseLocation`. This method returns a type of `SignalConnection`, which is similar to [RBXScriptConnection]["connection"]

</details>

```lua
EventListener: (
	self: Draggable,
	eventType: "start" | "end" | "move",
	func: (mouseLocation: Vector2, ...any?) -> (),
	funcSelf: {}?,
	...any?
) -> SignalConnection
```

<details><summary><b id="forceenddrag" style="font-size: 1.25rem">ForceEndDrag</b></summary>

This method forces the dragging to stop. **This still triggers the "end" signal.**

</details>

```lua
ForceEndDrag: (self: Draggable) -> ()
```

<details><summary><b id="forcestartdrag" style="font-size: 1.25rem">ForceStartDrag</b></summary>

This method force activate the dragging, even without mouse button 1 being down. The parameter `dragAt` is optional; if present, it must be a type of [DragAt](#dragat); if the parameter is `DragAt.Center` the dragging starts at the center of the GuiObject relative to the location of the mouse, while `dragAtOffset` is `dragAt + offset`. **This still triggers the "start" signal.**

</details>

```lua
ForceStartDrag: (self: Draggable, dragAt: DragAt?, dragAtOffset: Vector2?) -> ()
```

<details><summary><b id="ignore" style="font-size: 1.25rem">Ignore</b></summary>

This method allows you to stop the draggable from activating when the mouse is hovering over the GuiObjects inside the parameter `list`. The parameter `protected` indicates whether to use the protected call function when looping the list.

</details>

```lua
Ignore: (self: Draggable, list: { GuiObject }, protected: boolean?) -> ()
```

<details><summary><b id="ignorechildren" style="font-size: 1.25rem">IgnoreChildren</b></summary>

This method calls the [Ignore](#ignore) method, with list being `GuiObject:GetChildren()` and protected being true.

</details>

```lua
IgnoreChildren: (self: Draggable) -> ()
```

<details><summary><b id="ignoredescendants" style="font-size: 1.25rem">IgnoreDescendants</b></summary>

This method calls the [Ignore](#ignore) method, with list being `GuiObject:GetDescendants()` and protected being true.

</details>

```lua
IgnoreDescendants: (self: Draggable) -> ()
```

<details><summary><b id="isactive" style="font-size: 1.25rem">IsActive</b></summary>

This method allows you to identify if the draggable is active. This method returns a type of boolean.

</details>

```lua
IsActive: (self: Draggable) -> boolean
```

<details><summary><b id="listenallevent" style="font-size: 1.25rem">ListenAllEvent</b></summary>

This method allows you to listen to all of the available signals: `"start"`, `"end"`, and `"move"`. The **start** fires when the client has pressed mouse button 1 while hovering over the GuiObject. The **end** fires when the client releases mouse button 1 while the draggable is active. Lastly, the **move** fires when the GuiObject has been dragged. All of this signal fires with the mouse location on the surface gui. The parameter `funcSelf` is a [table]["{}"] where the first parameter of the func is set to self, while the parameter `...any?` is for extra information for the func; this is passed after `mouseLocation`. This method returns a dictionary with the indexes `"start"`, `"end"`, and `"move"` which all have the same type, `SignalConnection` which is similar to [RBXScriptConnection]["connection"].

</details>

```lua
ListenAllEvent: (
	self: Draggable,
	func: (mouseLocation: Vector2, ...any?) -> (),
	funcSelf: {}?,
	...any?
) -> {
	["start"]: SignalConnection,
	["move"]: SignalConnection,
	["end"]: SignalConnection,
}
```

<details><summary><b id="setdragat" style="font-size: 1.25rem">SetDragAt</b></summary>

This method allows you to set where the dragging starts relative to the location of the mouse. The parameter `dragAt` is optional; if present, it must be a type of [DragAt](#dragat); if the parameter is `DragAt.Center` the dragging starts at the center of the GuiObject relative to the location of the mouse, while `dragAtOffset` is `dragAt + offset`. **This still triggers the "start" signal.**

</details>

```lua
SetDragAt: (self: Draggable, dragAt: DragAt?, dragAtOffset: Vector2?) -> ()
```

<details><summary><b id="settweeninfo" style="font-size: 1.25rem">SetTweenInfo</b></summary>

This method allows you to have smooth dragging on your draggable.

</details>

```lua
SetTweenInfo: (self: Draggable, tweenInfo: TweenInfo) -> ()
```

## Types

<hr />

<details><summary><b id="draggableconfig" style="font-size: 1.25rem">DraggableConfig</b></summary>

|      Key      |                Data type                |
| :-----------: | :-------------------------------------: |
|   ByOffset:   |          [boolean]["boolean"]           |
|  CircleSize:  |           [number]["number"]            |
|   Circular:   |          [boolean]["boolean"]           |
|    DragAt:    |            [DragAt](#dragat)            |
| DragAtOffset: |          [Vector2]["vector2"]           |
|  Horizontal:  |          [boolean]["boolean"]           |
|    Ignore:    | [Array]["{}"]<[GuiObject]["guiobject"]> |
|    Limit:     |          [boolean]["boolean"]           |
| LimitNoPivot  |          [boolean]["boolean"]           |
|     Tween     |        [TweenInfo]["tweeninfo"]         |
|   Vertical    |          [boolean]["boolean"]           |

</details>

-   This data type is used in the new [constructor](#constructors) for the `config` parameter.

<details><summary><b id="limitconfig" style="font-size: 1.25rem">LimitConfig</b></summary>

|     Key     |      Data type       |
| :---------: | :------------------: |
| CircleSize: |  [number]["number"]  |
|  Circular:  | [boolean]["boolean"] |
|   NoPivot   | [boolean]["boolean"] |

</details>

-   This data type is used in the [EnableLimit](#enablelimit) for the `config` parameter.

<details><summary><b id="debugmodeconfig" style="font-size: 1.25rem">DebugModeConfig</b></summary>

|     Key      |               Data type               |
| :----------: | :-----------------------------------: |
|    Color:    |          [Color3]["color3"]           |
|  Material:   | [Enum]["enum"].[Material]["material"] |
|    Shape     | [Enum]["enum"].[PartType]["parttype"] |
|     Size     |         [Vector3]["vector3"]          |
| Transparency |          [number]["number"]           |

</details>

-   This data type is used in the new [constructor](#constructors) for the hidden `_debugMode` parameter.

## Custom Enum

<hr />

<b id="dragat" style="font-size: 1.25rem">DragAt</b>

|     Name     | Value |                   Summary                    |
| :----------: | :---: | :------------------------------------------: |
|    Center    |   4   |      Drag at the center of a GuiObject.      |
|  CenterLeft  |   3   |  Drag at at the center left of a GuiObject.  |
| CenterRight  |   5   | Drag at at the center right of a GuiObject.  |
| BottomCenter |   7   | Drag at at the bottom center of a GuiObject. |
|  BottomLeft  |   6   |  Drag at at the bottom left of a GuiObject.  |
| BottomRight  |   8   | Drag at at the bottom right of a GuiObject.  |
|  TopCenter   |   1   |  Drag at at the top center of a GuiObject.   |
|   TopLeft    |   0   |   Drag at at the top left of a GuiObject.    |
|   TopRight   |   2   |   Drag at at the top right of a GuiObject.   |

["guiobject"]: https://create.roblox.com/docs/reference/engine/classes/GuiObject
["surfacegui"]: https://create.roblox.com/docs/reference/engine/classes/SurfaceGui
["normalid"]: https://create.roblox.com/docs/reference/engine/enums/NormalId
["connection"]: https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection
["boolean"]: https://create.roblox.com/docs/scripting/luau/booleans
["number"]: https://create.roblox.com/docs/scripting/luau/numbers
["vector2"]: https://create.roblox.com/docs/reference/engine/datatypes/Vector2
["{}"]: https://create.roblox.com/docs/scripting/luau/tables
["tweeninfo"]: https://create.roblox.com/docs/reference/engine/datatypes/TweenInfo
["color3"]: https://create.roblox.com/docs/reference/engine/datatypes/Color3
["enum"]: https://create.roblox.com/docs/reference/engine/datatypes/Enum
["material"]: https://create.roblox.com/docs/reference/engine/enums/Material
["parttype"]: https://create.roblox.com/docs/reference/engine/enums/PartType
["vector3"]: https://create.roblox.com/docs/reference/engine/datatypes/Vector3
