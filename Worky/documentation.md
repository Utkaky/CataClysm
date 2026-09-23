# Worky Library

A UI library for Roblox/Luau. It gives you a draggable, resizable window with tabs, a built-in theme switcher, notifications, dialogs, and the usual set of controls (toggles, sliders, dropdowns, keybinds, a color picker, and so on).

> Version found in the source: `1.3`

## Loading the library

```lua
local Library = loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/RZP5f8FnksKPpY3O/raw"))()
```

The script destroys any previous `WorkyLibrary` ScreenGui under `CoreGui` before creating a new one, so re-running the loadstring is safe and won't leave duplicate windows behind.

## Creating a window

```lua
local Window = Library:Window({
	Title = "My Interface",
	Desc = "Optional description",
	Icon = "gem",
	Theme = "Dark",
	Config = {
		Keybind = Enum.KeyCode.RightShift,
		Size = UDim2.new(0, 580, 0, 450),
		FreeMouse = true
	},
	CloseUIButton = {
		Enabled = false,
		Text = "Toggle UI"
	}
})
```

### Window options

| Field | Type | Default | Notes |
| --- | --- | --- | --- |
| `Title` | string | `"null"` | Shown in the top bar. |
| `Desc` | string | `""` | Small text under the title. Hidden automatically if left empty. |
| `Icon` | string, number, or asset id | `"door-open"` | Icon name from the built-in icon pack, a numeric asset id, or a full `rbxassetid://...` string. |
| `Theme` | string | `"Dark"` | Starting theme. Must match one of the built-in theme names exactly (case-sensitive). |
| `Config.Keybind` | `Enum.KeyCode` | `LeftControl` | Key used to show/hide the whole window. |
| `Config.Size` | `UDim2` | `UDim2.new(0, 530, 0, 400)` | Starting size of the window. |
| `Config.FreeMouse` | boolean | `false` | Forces the mouse cursor to stay visible and unlocked while the UI is open. Useful for FPS-style games where the cursor is normally hidden. |
| `CloseUIButton.Enabled` | boolean | — | Adds a small floating pill button outside the main window that toggles it open/closed. |
| `CloseUIButton.Text` | string | — | Label on that floating button. |

A couple of things worth knowing before you copy-paste this:

- `Config` and `CloseUIButton` are **not optional tables with safe fallbacks** — the code reads `p.Config.Keybind` directly, so if you skip `Config` entirely the call will error. Always pass at least an empty `Config = {}` if you don't need to customize it, and same goes for `CloseUIButton`.
- The window fades and scales in on creation (a quick tween on `GroupTransparency` and `Size`), so don't be surprised if it looks "empty" for a couple of frames on slower devices.
- Resizing is done by dragging the small handle in the bottom-right corner. There's a hard floor of `450x220` baked into the resize logic — the window won't shrink below that no matter what `Config.Size` you passed initially.

## Window methods

```lua
Window:SetTitle("New title")
Window:SetDesc("New description")

Window:SetBackGroundImage(14390626506)
Window:SetBackgroundImage("rbxassetid://14390626506") -- alias, same thing

Window:SetTransparencyBackGround(35)   -- accepts 0-100
Window:SetTransparencyBackground(0.35) -- alias, accepts 0-1 as well

Window:SetSectionBackGroundTransparency(50)
Window:SetSectionBackgroundTransparency(0.5)  -- alias
Window:SetTransparencySection(50)             -- alias

Window:SetFunctionBackGroundTransparency(50)
Window:SetFunctionBackgroundTransparency(0.5) -- alias
Window:SetTransparencyFunction(50)            -- alias

Window:SelectTab(2)
Window:Line()
```

Notes on these:

- Every transparency setter normalizes the input itself: pass `35` or `0.35`, both work, and anything above `1` is assumed to be a 0–100 percentage.
- `SetBackGroundImage` (and its alias `SetBackgroundImage`) accepts a plain asset id number, a `rbxassetid://` string, an external image URL, or the string `"None"`/`nil`/`""` to clear it. External URLs only work if the executor exposes `getcustomasset` or `getsynasset` alongside `writefile` — without those, the library just prints a warning and leaves the background alone.
- `SetSectionBackGroundTransparency` and `SetFunctionBackGroundTransparency` look similar but touch different layers: the "section" one adjusts the background behind grouped controls, while the "function" one adjusts the background of individual controls (toggles, buttons, etc.) inside `ScrollingFrame` pages, skipping anything already marked as a section header.
- `SelectTab(index)` just sets which tab index gets auto-selected the first time tabs are populated — call it *before* you start adding tabs with `Window:Tab(...)`, since the selection check runs shortly after each tab is created.
- `Window:Line()` draws a thin horizontal divider inside the tab list on the left sidebar (not inside a tab's content — it's meant to visually separate groups of tab buttons). It also has a subtle proximity-glow effect when your mouse gets close to it.

## Themes

Built-in themes: `Dark`, `Amethyst`, `Ocean`, `Forest`, `Sunset`, `Crimson`, `Ice`.

The theme dropdown appears automatically in the top bar next to the window controls — you don't need to build it yourself. Whatever string you pass as `Theme` when creating the window has to match one of these names exactly, or the library will index into a `nil` theme table and error out when it tries to color the toggle switches.

If you want to change the theme from code instead of letting the user pick it, there isn't a direct `Window:SetTheme("Ocean")` shortcut exposed — the theme swap is wired internally through the dropdown's callback (`CallTheme`). Selecting an item in that built-in dropdown is currently the supported way to switch themes at runtime.

## Creating a tab

```lua
local Tab = Window:Tab({
	Title = "Main",
	Icon = "house"
})
```

| Field | Type | Default |
| --- | --- | --- |
| `Title` | string | `"null"` |
| `Icon` | string, number, or asset id | `"house"` |

`Window:Tab(...)` returns a table of component constructors (`:Toggle`, `:Slider`, `:Dropdown`, etc.) scoped to that tab's page. The first tab you create is auto-selected on load unless you called `Window:SelectTab(n)` beforehand to point at a different index.

## Section

A plain section header, useful for visually grouping a handful of controls under a tab.

```lua
local Section = Tab:Section({
	Title = "Settings"
})

Section:SetTitle("New title")
```

It's just a label — it doesn't nest or contain the controls placed after it, it simply marks a break in the list.

## Toggle

```lua
local Toggle = Tab:Toggle({
	Title = "Enable feature",
	Desc = "Optional description",
	Image = "settings",
	Value = false,
	Callback = function(value)
		print("Toggle:", value)
	end,
	Bindable = {
		Default = Enum.KeyCode.E,
		Hold = false
	}
})
```

- `Value` sets the starting state.
- `Callback` fires with a boolean every time the toggle flips, including once automatically right after creation (there's a short `delay(0.1, change)` internally that fires the initial callback).
- `Bindable` is optional. When provided, it attaches a keybind box directly to the toggle row, letting the player rebind the key by clicking the box and pressing a new key or mouse button. With `Hold = true`, the callback fires `true` while the bound key/button is held down and `false` the instant it's released, instead of toggling on press.

```lua
Toggle:SetTitle("New title")
Toggle:SetDesc("New description")
Toggle:SetVisible(true)
Toggle:SetValue(true)

local Bind = Toggle:CreateBind({
	Default = Enum.KeyCode.Q,
	Hold = false
})
Bind:Set(Enum.KeyCode.R)
Bind:SetKey(Enum.KeyCode.T) -- alias of :Set
print(Bind:Get())
```

`CreateBind` is the manual equivalent of passing `Bindable` up front — use whichever fits your flow better; both end up calling the same internal binder.

## Label

A simple, non-interactive line of text with an optional icon and description.

```lua
local Label = Tab:Label({
	Title = "Status",
	Desc = "Everything is running fine",
	Image = "check"
})

Label:SetTitle("New title")
Label:SetDesc("New text")
Label:SetVisible(false)
```

## Button

```lua
local Button = Tab:Button({
	Title = "Run",
	Desc = "Runs an action",
	Image = "play",
	Callback = function()
		print("Clicked")
	end
})

Button:SetTitle("Run now")
Button:SetDesc("Updated description")
Button:SetVisible(true)
```

Clicking plays a small squash-and-recover animation on the row itself before firing the callback — purely cosmetic, no need to account for it in your code.

## Slider

```lua
local Slider = Tab:Slider({
	Title = "Speed",
	Desc = "Pick a value",
	Min = 0,
	Max = 100,
	Value = 25,
	Rounding = 2,
	Callback = function(value)
		print("Value:", value)
	end
})
```

`Min`/`Max` set the range, `Value` is the starting point, and `Rounding` controls how many decimal places the value is rounded to (pass `0` for whole numbers). Dragging the handle or the bar itself updates the value live, and there's also a text box next to the bar where the player can type an exact number directly — it commits on focus lost.

```lua
Slider:SetTitle("New title")
Slider:SetDesc("New description")
Slider:SetVisible(true)
Slider:SetValue(75)
Slider:SetMin(10)
Slider:SetMax(200)
```

`SetMin`/`SetMax` also clamp the current value into the new range automatically if it's now out of bounds — you don't need to call `SetValue` afterward just to fix that.

## Code

A syntax-highlighted code block with line numbers and a copy button — handy for showing loadstrings, config snippets, or scripts to the player.

```lua
local Code = Tab:Code({
	Title = "Example",
	Code = 'print("Hello, Worky!")'
})

Code:SetTitle("Updated title")
Code:SetCode("local value = 10\nprint(value)")
```

The highlighter is a lightweight hand-rolled tokenizer aimed at Lua/Luau — it recognizes keywords, common Roblox globals (`game`, `workspace`, `Instance`, `Vector3`, etc.), strings, comments, numbers, and booleans, and colors function calls slightly differently from properties. It's not a full parser, so extremely unusual formatting may highlight oddly, but for typical scripts it reads well.

The `Copy` button relies on `setclipboard`, so it only works on executors that implement it — on ones that don't, clicking it will silently do nothing (the callback is wrapped in a way that avoids throwing, but no text ends up on the clipboard).

## Dropdown

```lua
local Dropdown = Tab:Dropdown({
	Title = "Select option",
	Desc = "Choose an item",
	List = {"Option 1", "Option 2", "Option 3"},
	Value = "Option 1",
	Multi = false,
	Callback = function(value)
		print("Selected:", value)
	end
})
```

With `Multi = false`, the callback receives a plain string. With `Multi = true`, pass `Value` as a table of pre-selected items, and the callback will receive a table listing everything currently checked.

```lua
local MultiDropdown = Tab:Dropdown({
	Title = "Multiple choice",
	List = {"A", "B", "C"},
	Value = {"A", "C"},
	Multi = true,
	Callback = function(values)
		print(table.concat(values, ", "))
	end
})

Dropdown:SetTitle("New title")
Dropdown:SetDesc("New description")
Dropdown:SetVisible(true)
Dropdown:SetValue("Option 2")
Dropdown:Add("Option 4")
Dropdown:Clear()                 -- removes everything
Dropdown:Clear("Option 2")      -- removes a single item by name
Dropdown:Clear({"A", "B"})      -- removes several items at once
```

A few implementation details worth knowing:

- The dropdown panel has a built-in search box that filters the list as the player types — no setup needed on your end.
- The list field is called `List`, not `Options` — passing `Options` will just leave the dropdown empty, since the code only ever reads `p.List`.
- The panel auto-sizes based on content, up to a maximum height of `200px`, after which it becomes scrollable.
- Calling `:Clear()` with no arguments also resets `Value` back to `nil` and, in multi-select mode, fires the callback with an empty table — so if you're listening for changes, expect a call during a full clear too.

## Keybind

`Keybind` toggles a boolean state whenever the configured key is pressed, and lets the player rebind it by clicking the key box.

```lua
local Keybind = Tab:Keybind({
	Title = "Special mode",
	Desc = "Press the configured key",
	Key = Enum.KeyCode.F,
	Value = false,
	Callback = function(key, enabled)
		print(key, enabled)
	end
})

Keybind:SetTitle("New title")
Keybind:SetDesc("New description")
Keybind:SetVisible(true)
Keybind:SetValue(true)
Keybind:SetKey(Enum.KeyCode.G)
```

The callback signature here is `(key, enabled)` — both values are passed together every time, unlike `Toggle`'s callback which only receives the boolean.

## Keybind2

A second, more action-oriented keybind variant. Where `Keybind` is meant to flip a persistent toggle, `Keybind2` is built for firing one-off actions or hold-to-use mechanics, and it also accepts mouse buttons as bindable inputs (not just keyboard keys).

```lua
local Bind = Tab:Keybind2({
	Title = "Action",
	Key = Enum.KeyCode.LeftAlt,
	Hold = true,
	Flag = "ActionKey",
	Callback = function(isHolding)
		print("Holding:", isHolding)
	end
})

Bind:SetTitle("New action")
Bind:SetDesc("Updated description")
Bind:SetVisible(true)
Bind:SetKey(Enum.KeyCode.LeftControl)
```

With `Hold = true`, the callback fires `true` on press and `false` on release, similar to `Toggle`'s `Bindable.Hold`. With `Hold = false` (the default), it fires once per press with no arguments. If you pass `Flag`, the currently bound key is also mirrored into `_G[Flag]` — convenient if other parts of your script need to read the current bind without holding a reference to this specific component.

## ColorPicker

```lua
local ColorPicker = Tab:ColorPicker({
	Title = "Color",
	Desc = "Pick a color",
	Value = Color3.fromRGB(255, 80, 120),
	Callback = function(red, green, blue)
		print(red, green, blue)
	end
})

ColorPicker:SetTitle("Main color")
ColorPicker:SetDesc("Updated RGB")
ColorPicker:SetVisible(true)
ColorPicker:SetValue({
	R = 0,
	G = 170,
	B = 255
})
```

Important gotcha: the callback receives **three separate integers** (`0`–`255`), not a `Color3`. If you need a `Color3` in your own code, build one yourself with `Color3.fromRGB(red, green, blue)` inside the callback.

The picker itself supports three ways to enter a color — dragging on the saturation/value square, dragging the hue bar, or typing directly into the RGB fields or the hex field — and they all stay in sync with each other.

## Textbox

```lua
local Textbox = Tab:Textbox({
	Title = "Name",
	Desc = "Enter a value",
	Value = "Player",
	Placeholder = "Type here...",
	ClearTextOnFocus = false,
	Callback = function(value)
		print(value)
	end
})

Textbox:SetTitle("New title")
Textbox:SetDesc("New description")
Textbox:SetVisible(true)
Textbox:SetValue("New value")
Textbox:SetClearTextOnFocus(true)
Textbox:SetPlaceholderText("New placeholder")
```

The callback fires when the textbox loses focus, and also once automatically at creation time if `Value` was non-empty. `ClearText` is accepted as an alternate spelling of `ClearTextOnFocus` in the constructor options, in case you're used to that naming from other libraries.

## Image

Drops a fixed decorative image into the current tab.

```lua
Tab:Image()
```

This one doesn't take any configuration — it always renders the same built-in asset baked into the library. There's currently no way to pass a custom image through this method; if you need a custom picture in your UI, you'd have to build it manually with an `ImageLabel` outside the library's component set.

## Simple notification

```lua
Window:Notify({
	Title = "Done",
	Desc = "The operation finished.",
	Time = 5
})
```

`Time` is the display duration in seconds (default `5`). Notifications stack in the bottom-right corner and animate in/out; a thin progress bar along the bottom edge shrinks over the duration so the player has a sense of how long they have left.

## Notification with confirmation

```lua
Window:NotifyAsk({
	Title = "Confirm action?",
	Desc = "This cannot be undone.",
	Time = 10,
	AcceptText = "Confirm",
	DeclineText = "Cancel",
	OnAccept = function()
		print("Accepted")
	end,
	OnDecline = function()
		print("Declined or timed out")
	end
})
```

This is the same visual style as `Notify`, but with Accept/Decline buttons instead of a plain countdown. If the timer runs out with no interaction, `OnDecline` is called automatically — treat that the same as an explicit decline in your logic, since there's no third "timed out" state passed to the callbacks.

## Dialog

A modal confirmation prompt rendered on top of the main window itself (rather than in the notification corner). Only one dialog can be open at a time — calling `Window:Dialog(...)` again while one is already showing is a no-op.

```lua
Window:Dialog({
	Title = "Do you want to continue?",
	Button1 = {
		Title = "Yes",
		Color = Color3.fromRGB(0, 188, 0),
		Callback = function()
			print("Confirmed")
		end
	},
	Button2 = {
		Title = "No",
		Color = Color3.fromRGB(226, 39, 6),
		Callback = function()
			print("Cancelled")
		end
	}
})
```

Note that `Button1`/`Button2` are required tables (the code reads `p.Button1.Callback` directly), so both must be provided even if one of them just cancels with no side effects. The built-in "close the UI" confirmation shown when clicking the window's close (X) button is actually built on top of this same `Dialog` method internally, so you can see a real-world usage pattern in the library source itself.

## Full example

```lua
local Library = loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/RZP5f8FnksKPpY3O/raw"))()

local Window = Library:Window({
	Title = "Worky Demo",
	Desc = "Full example",
	Icon = "gem",
	Theme = "Ocean",
	Config = {
		Keybind = Enum.KeyCode.RightShift,
		Size = UDim2.new(0, 580, 0, 450),
		FreeMouse = true
	},
	CloseUIButton = {
		Enabled = false,
		Text = "Toggle UI"
	}
})

local Main = Window:Tab({Title = "Main", Icon = "house"})
Main:Section({Title = "Controls"})

Main:Toggle({
	Title = "Enabled",
	Value = true,
	Callback = function(value)
		print("Enabled:", value)
	end
})

Main:Slider({
	Title = "Intensity",
	Min = 0,
	Max = 100,
	Value = 50,
	Rounding = 0,
	Callback = function(value)
		print("Intensity:", value)
	end
})

Main:Button({
	Title = "Notify",
	Callback = function()
		Window:Notify({Title = "Worky", Desc = "Button pressed!"})
	end
})
```

## Things to keep in mind

- Icons accept three formats: a name from the built-in icon pack, a plain numeric asset id, or a full `rbxassetid://...` string.
- The library builds everything inside a `ScreenGui` named `WorkyLibrary` under `CoreGui`. Loading the library twice in the same session is safe — the old instance is destroyed first.
- External background images require executor support for `getcustomasset`/`getsynasset`, `writefile`, and outbound HTTP requests. If any of those are missing, the library just warns instead of erroring.
- The window can be dragged by its top bar, resized from the bottom-right corner (with a `450x220` minimum size), and minimized via the small icon next to the resize handle.
- Every callback passed into a component is wrapped in `pcall`. If your callback throws an error, it will fail silently rather than breaking the rest of the UI — worth keeping in mind while debugging, since a broken callback won't show up as a normal error in the console unless you add your own logging inside it.
- There is no persistent settings/config-saving system built into this version (no `Library:SaveConfig` or similar) — if you need to remember toggle states, slider values, etc. between sessions, you'll need to wire that up yourself using `DataStoreService` or file I/O, depending on context.
