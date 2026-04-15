# DarkLib V6

> **Version:** V6 &nbsp;·&nbsp; **Author:** darkmoonhub (`darki-exe`) &nbsp;·&nbsp; **Language:** Luau (Roblox)  
> **Repository:** [github.com/darki-exe/DarkLibV6](https://github.com/darki-exe/DarkLibV6)

---

## Table of Contents

1. [Overview](#overview)
2. [Loading](#loading)
3. [Theme](#theme)
4. [Window](#window)
   - [Key System](#key-system)
   - [Close & Minimize Buttons](#close--minimize-buttons)
5. [Tab](#tab)
6. [Components](#components)
   - [Button](#button)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Input](#input)
   - [Dropdown](#dropdown)
   - [Keybind](#keybind)
   - [Color Picker](#color-picker)
   - [Label](#label)
   - [Paragraph](#paragraph)
   - [Divider](#divider)
   - [Discord Inviter](#discord-inviter)
7. [Notifications](#notifications)
8. [Dialog](#dialog)
9. [Toggle Button](#toggle-button)
10. [Flag System](#flag-system)
11. [Lock System](#lock-system)
12. [Executor Compatibility](#executor-compatibility)

---

## Overview

**DarkLib V6** is a UI library for Roblox script executors. It provides a draggable multi-tab window with a full component suite, smooth animations, and a dark purple aesthetic.

- TweenService-based animations throughout
- PC and mobile (Touch) support
- Optional loading screen and key authentication
- Component locking — disable/re-enable any element at runtime
- Modal dialogs with up to 4 buttons
- Floating toggle button with drag support
- Notification toasts with type theming and auto-dismiss
- Global flag system via `DarkLib.Options`

---

## Loading

```lua
local DarkLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/darki-exe/DarkLibV6/refs/heads/main/Main/Source.luau"
))()
```

> You can also paste the source directly into your script if you have it locally.

---

## Theme

All colors are accessible and overridable at `DarkLib.Theme`. Values are `Color3`.

| Key | Description | Default |
|---|---|---|
| `BG` | Main background | `(14, 14, 18)` |
| `BG2` | Secondary background | `(20, 20, 26)` |
| `BG3` | Elevated surface | `(28, 28, 36)` |
| `Surface` | Content area | `(22, 22, 30)` |
| `NavBG` | Navigation panel | `(16, 16, 22)` |
| `Border` | Default border | `(42, 42, 58)` |
| `BorderHover` | Border on hover | `(80, 78, 110)` |
| `Accent` | Primary purple | `(120, 90, 220)` |
| `AccentDim` | Dimmed accent | `(75, 55, 145)` |
| `AccentGlow` | Bright accent | `(150, 115, 255)` |
| `Text` | Primary text | `(220, 218, 232)` |
| `TextDim` | Secondary text | `(140, 136, 165)` |
| `TextMuted` | Muted text | `(80, 78, 100)` |
| `Green` | Success | `(80, 200, 130)` |
| `Red` | Error / danger | `(200, 70, 70)` |
| `Yellow` | Warning | `(230, 190, 60)` |
| `TabActive` | Active tab row | `(34, 32, 50)` |
| `TabInactive` | Inactive tab row | `(0, 0, 0)` |

```lua
-- Override any color at runtime
DarkLib.Theme.Accent = Color3.fromRGB(255, 80, 120)
```

> ⚠️ Theme overrides only apply to components created **after** the change.

---

## Window

```lua
local Window = DarkLib:CreateWindow(cfg: table)
```

Creates the main application window. Calling `CreateWindow` again destroys any existing window.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"DarkLib V6"` | Window title in the top bar |
| `Subtitle` | `string` | `"by darkmoonhub"` | Subtitle next to the title |
| `HideBind` | `Enum.KeyCode` | `RightControl` | Keyboard shortcut to toggle visibility |
| `LoadingScreen` | `bool` | `true` | Show animated loading screen on startup |
| `LoadingTitle` | `string` | `"Loading..."` | Text displayed during loading |
| `KeySystem` | `bool` | `false` | Enable key authentication screen |
| `KeySettings` | `table` | `{}` | Key system configuration (see below) |

The window size adapts to the viewport, clamped to **560–720 px** wide and **380–480 px** tall.

### Example

```lua
local Window = DarkLib:CreateWindow({
    Title         = "My Script",
    Subtitle      = "v1.0",
    HideBind      = Enum.KeyCode.RightAlt,
    LoadingScreen = true,
    LoadingTitle  = "Initializing...",
})
```

---

### Key System

Set `KeySystem = true` to display a full-screen authentication overlay before the UI becomes accessible.

#### KeySettings Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `cfg.Title` | Title on the key screen |
| `Subtitle` | `string` | `"Key Required"` | Subtitle text |
| `Description` | `string?` | `nil` | Optional description shown below the subtitle |
| `Key` | `{string}` | `{""}` | Valid keys — any match is accepted |
| `SaveKey` | `bool` | `false` | Persist key across sessions (reserved) |
| `Placeholder` | `string?` | `"Enter your key..."` | Input placeholder text |
| `KeyLink` | `string?` | `nil` | Shows a "Get Key" button that copies this URL |
| `Icon` | `string?` | `nil` | Asset ID for an icon displayed above the title |
| `MaxAttempts` | `number` | `5` | Failed attempts before lockout |
| `LockDuration` | `number` | `30` | Lockout duration in seconds |

#### Example

```lua
local Window = DarkLib:CreateWindow({
    Title      = "My Script",
    KeySystem  = true,
    KeySettings = {
        Title        = "Authentication",
        Subtitle     = "Key Required",
        Description  = "Join our Discord to obtain a key.",
        Key          = { "myKey-2026", "altKey-9999" },
        KeyLink      = "https://discord.gg/example",
        MaxAttempts  = 3,
        LockDuration = 60,
    }
})
```

---

### Close & Minimize Buttons

#### `Window:CreateCloseButton(cfg)`

| Field | Type | Description |
|---|---|---|
| `IconId` | `string?` | Asset ID for the close icon. Falls back to `"×"` text if omitted |

```lua
Window:CreateCloseButton({ IconId = "10747384394" })
```

#### `Window:CreateMinimizeButton(cfg)`

| Field | Type | Description |
|---|---|---|
| `OnIconId` | `string?` | Icon displayed when the window is **minimized** (restore icon) |
| `OffIconId` | `string?` | Icon displayed when the window is **open** (minimize icon) |

```lua
Window:CreateMinimizeButton({
    OnIconId  = "10734924532",
    OffIconId = "10734896206",
})
```

---

## Tab

```lua
local Tab = Window:CreateTab(cfg: table)
```

Creates a tab entry in the left navigation panel and a corresponding scrollable content page. The first tab created is automatically selected.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Tab"` | Label shown in the nav panel |
| `IconID` | `string?` | `nil` | Asset ID for a small icon shown before the tab name |

### Example

```lua
local MainTab     = Window:CreateTab({ Name = "Main" })
local VisualsTab  = Window:CreateTab({ Name = "Visuals", IconID = "10747384394" })
local SettingsTab = Window:CreateTab({ Name = "Settings" })
```

---

## Components

All components are methods on a `Tab` object. Each one appends to the tab's scroll page and returns a control object with methods to update, lock, or destroy it.

Pass a `flag` string as the second argument to register the component globally in `DarkLib.Options`.

---

### Button

```lua
local BtnObj = Tab:CreateButton(cfg: table)
```

A clickable button row with an optional description.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Button"` | Button label |
| `Description` | `string?` | `nil` | Optional subtitle below the name |
| `Callback` | `function()` | `function() end` | Called on click |

#### Methods

| Method | Description |
|---|---|
| `BtnObj:Destroy()` | Remove the component |

#### Example

```lua
Tab:CreateButton({
    Name        = "Rejoin Server",
    Description = "Reconnects you to the current game.",
    Callback    = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})
```

---

### Toggle

```lua
local TogObj = Tab:CreateToggle(cfg: table, flag: string?)
```

A boolean on/off switch.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Toggle"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Default` | `bool` | `false` | Initial state |
| `Callback` | `function(bool)` | `function() end` | Called when the state changes |

#### Methods

| Method | Description |
|---|---|
| `TogObj:UpdateState(bool)` | Set toggle state without firing the callback |
| `TogObj:ToggleLock(bool)` | Lock or unlock the component |
| `TogObj:IsLocked()` | Returns `bool` |
| `TogObj:Destroy()` | Remove the component |

#### Example

```lua
local godMode = Tab:CreateToggle({
    Name        = "God Mode",
    Description = "Prevents all incoming damage.",
    Default     = false,
    Callback    = function(state)
        -- apply godmode
    end
}, "GodMode")

-- Read state via flag
print(DarkLib.Options.GodMode.Default)

-- Force state without triggering callback
godMode:UpdateState(true)
```

---

### Slider

```lua
local SlObj = Tab:CreateSlider(cfg: table, flag: string?)
```

A draggable range slider.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Slider"` | Display name |
| `Range` | `{number, number}` | `{0, 100}` | `{min, max}` |
| `Increment` | `number` | `1` | Step size |
| `Default` | `number` | `50` | Initial value |
| `Suffix` | `string` | `""` | Text appended to the value (e.g. `" ms"`, `"%"`) |
| `Callback` | `function(number)` | `function() end` | Called on value change |

#### Methods

| Method | Description |
|---|---|
| `SlObj:UpdateValue(number)` | Set value without firing the callback |
| `SlObj:ToggleLock(bool)` | Lock or unlock the component |
| `SlObj:IsLocked()` | Returns `bool` |
| `SlObj:Destroy()` | Remove the component |

#### Example

```lua
local speedSlider = Tab:CreateSlider({
    Name      = "Walk Speed",
    Range     = {16, 500},
    Increment = 2,
    Default   = 16,
    Suffix    = " WS",
    Callback  = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
}, "WalkSpeed")
```

---

### Input

```lua
local InObj = Tab:CreateInput(cfg: table, flag: string?)
```

A text input field.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Input"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Placeholder` | `string` | `"Type here..."` | Placeholder text |
| `Default` | `string` | `""` | Initial value |
| `Numeric` | `bool` | `false` | Restrict input to numbers only |
| `MaxChars` | `number?` | `nil` | Maximum character count |
| `Enter` | `bool` | `false` | Fire callback only on Enter key |
| `ClearOnLost` | `bool` | `false` | Clear the field when focus is lost |
| `Callback` | `function(string)` | `function() end` | Called on focus lost (or Enter if `Enter = true`) |

#### Methods

| Method | Description |
|---|---|
| `InObj:Set(newCfg)` | Update config and current value |
| `InObj:ToggleLock(bool)` | Lock or unlock the component |
| `InObj:IsLocked()` | Returns `bool` |
| `InObj:Destroy()` | Remove the component |

#### Example

```lua
Tab:CreateInput({
    Name        = "Target Player",
    Placeholder = "Username...",
    Enter       = true,
    Callback    = function(text)
        print("Target:", text)
    end
})
```

---

### Dropdown

```lua
local DDObj = Tab:CreateDropdown(cfg: table, flag: string?)
```

A dropdown selector with optional multi-select.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Dropdown"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Options` | `{string}` | `{"Option 1", "Option 2"}` | Selectable options |
| `Default` | `string \| {string} \| nil` | `nil` | Initial selection(s) |
| `Multi` | `bool` | `false` | Allow multiple simultaneous selections |
| `Callback` | `function(string \| {string})` | `function() end` | Called with the selection on change |

> When `Multi = false`, the callback receives a `string`. When `Multi = true`, it receives a `{string}` array.

#### Methods

| Method | Description |
|---|---|
| `DDObj:Set(newCfg)` | Update options and/or selection |
| `DDObj:ToggleLock(bool)` | Lock or unlock the component |
| `DDObj:IsLocked()` | Returns `bool` |
| `DDObj:Destroy()` | Remove the component |

#### Example

```lua
-- Single select
local modeDD = Tab:CreateDropdown({
    Name     = "Game Mode",
    Options  = { "Normal", "Silent", "Aggressive" },
    Default  = "Normal",
    Callback = function(selected)
        print("Mode:", selected)
    end
}, "GameMode")

-- Multi select
Tab:CreateDropdown({
    Name     = "Active Features",
    Options  = { "Fly", "Speed", "NoClip", "ESP" },
    Default  = { "Fly", "Speed" },
    Multi    = true,
    Callback = function(selected)
        print("Active:", table.concat(selected, ", "))
    end
})
```

---

### Keybind

```lua
local BndObj = Tab:CreateBind(cfg: table, flag: string?)
-- Alias:
local BndObj = Tab:CreateKeybind(cfg: table, flag: string?)
```

A keybind listener. Click the bind box to enter listening mode, then press any key to assign it. Press `Escape` to cancel.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Keybind"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Default` | `string` | `"None"` | Initial key name (e.g. `"F"`, `"LeftShift"`) |
| `Hold` | `bool` | `false` | If `true`, callback fires with `true` on press and `false` on release |
| `Callback` | `function(bool?)` | `function() end` | Called on key press (and release when `Hold = true`) |

#### Methods

| Method | Description |
|---|---|
| `BndObj:Set(newCfg)` | Update config and displayed bind |
| `BndObj:ToggleLock(bool)` | Lock or unlock the component |
| `BndObj:IsLocked()` | Returns `bool` |
| `BndObj:Destroy()` | Remove the component |

#### Example

```lua
-- Press to toggle
Tab:CreateBind({
    Name     = "Toggle Fly",
    Default  = "F",
    Callback = function()
        -- toggle fly
    end
}, "BindFly")

-- Hold to activate
Tab:CreateBind({
    Name     = "Speed Boost",
    Default  = "LeftShift",
    Hold     = true,
    Callback = function(holding)
        if holding then
            -- boost on
        else
            -- boost off
        end
    end
})
```

---

### Color Picker

```lua
local CPObj = Tab:CreateColorPicker(cfg: table, flag: string?)
```

A color picker popup with a 2D saturation/value canvas, hue strip, hex input, and RGB numeric inputs.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Color Picker"` | Display name |
| `Color` | `Color3` | `Color3.fromRGB(120, 90, 220)` | Initial color |
| `Callback` | `function(Color3)` | `function() end` | Called on every color change |

#### Methods

| Method | Description |
|---|---|
| `CPObj:Set(newCfg)` | Update config and initial color |
| `CPObj:ToggleLock(bool)` | Lock or unlock the component |
| `CPObj:IsLocked()` | Returns `bool` |
| `CPObj:Destroy()` | Remove the component and close popup |

#### Example

```lua
local espColor = Tab:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(255, 50, 50),
    Callback = function(c)
        -- apply color
    end
}, "ESPColor")

-- Read color via flag
print(DarkLib.Options.ESPColor.Color)
```

---

### Label

```lua
local LbObj = Tab:CreateLabel(cfg: table)
```

A static informational text row. Supports 3 visual styles.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string` | `"Label"` | Label text |
| `Style` | `number` | `1` | `1` = subtle grey · `2` = blue info · `3` = yellow warning |

#### Methods

| Method | Description |
|---|---|
| `LbObj:Set(string)` | Update the label text |
| `LbObj:Destroy()` | Remove the component |

#### Example

```lua
Tab:CreateLabel({ Text = "Combat Settings",           Style = 1 })
Tab:CreateLabel({ Text = "ℹ Feature is experimental", Style = 2 })
Tab:CreateLabel({ Text = "⚠ Requires restart",        Style = 3 })
```

---

### Paragraph

```lua
local PgObj = Tab:CreateParagraph(cfg: table)
```

A text block with a bold title and wrapping body. Height auto-adjusts to content.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Paragraph"` | Bold header |
| `Text` | `string` | `""` | Body text. Supports Roblox RichText tags |

#### Methods

| Method | Description |
|---|---|
| `PgObj:Set(newCfg)` | Update title and/or text — auto-resizes |
| `PgObj:Destroy()` | Remove the component |

#### Example

```lua
local info = Tab:CreateParagraph({
    Title = "About",
    Text  = "Made by <b>darkmoonhub</b>. Use responsibly.",
})

info:Set({ Title = "Status", Text = "All systems operational." })
```

---

### Divider

```lua
Tab:CreateDivider(cfg: table?)
```

A horizontal separator, optionally with a centered text label.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string?` | `nil` | Text centered on the line |
| `Thickness` | `number` | `1` | Line thickness in pixels |

#### Example

```lua
Tab:CreateDivider()
Tab:CreateDivider({ Text = "Advanced Options" })
```

---

### Discord Inviter

```lua
Tab:CreateDiscordInviter(cfg: table)
```

A styled card row with a server icon, name, and a copy-link button for a Discord invite.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Discord Server"` | Server name displayed on the card |
| `Link` | `string` | `""` | Full Discord invite URL |
| `IconID` | `string` | `"0"` | Asset ID for the server icon |

#### Example

```lua
Tab:CreateDiscordInviter({
    Name   = "My Server",
    Link   = "https://discord.gg/myserver",
    IconID = "10747384394",
})
```

---

## Notifications

```lua
DarkLib:Notify(cfg: table)
```

Displays an animated toast in the bottom-right corner. Auto-dismisses after a set or calculated duration.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Notification"` | Bold title |
| `Content` | `string` | `""` | Body text (wraps automatically) |
| `Type` | `string` | `"info"` | `"info"` · `"success"` · `"warn"` · `"error"` |
| `Duration` | `number?` | auto | Display time in seconds. If `nil`, calculated from content length (3–10 s) |

### Example

```lua
DarkLib:Notify({
    Title    = "Script Loaded",
    Content  = "DarkLib V6 initialized successfully.",
    Type     = "success",
    Duration = 4,
})
```

---

## Dialog

```lua
DarkLib:Dialog(cfg: table)
```

Opens a modal overlay with a backdrop and 1–4 customizable buttons.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Dialog"` | Dialog title |
| `Description` | `string` | `""` | Body text |
| `Buttons` | `{ButtonCfg}` | **required** | 1–4 button definitions |
| `Callback` | `function(index)?` | `nil` | Called with the button index when any button is pressed |

### Button Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string` | `"Button N"` | Button label |
| `Color` | `Color3?` | `Theme.Accent` | Background color |
| `StrokeColor` | `Color3?` | `Theme.Border` | Border color |
| `StrokeThick` | `number?` | `1` | Border thickness |
| `Round` | `number?` | `7` | Corner radius |
| `Callback` | `function(index)?` | `nil` | Per-button callback |

**Button layout:**
- 1 button → full width
- 2 buttons → side by side
- 3 buttons → 2 on top, 1 centered below
- 4 buttons → 2×2 grid

### Example

```lua
DarkLib:Dialog({
    Title       = "Confirm",
    Description = "This action cannot be undone.",
    Buttons = {
        {
            Text     = "Confirm",
            Color    = Color3.fromRGB(80, 200, 130),
            Callback = function() print("Confirmed") end,
        },
        {
            Text  = "Cancel",
            Color = Color3.fromRGB(200, 70, 70),
        },
    },
    Callback = function(idx)
        print("Button pressed:", idx)
    end,
})
```

---

## Toggle Button

```lua
local btn = DarkLib:CreateToggleButton(cfg: table, windowObj: Window?)
```

A floating circular button (default: top-left) that toggles the linked window's visibility. Independently draggable with a 4 px drag threshold to differentiate taps from drags on mobile.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `IconID` | `string` | `"rbxassetid://0"` | Asset ID for the button icon |
| `Radius` | `number` | `28` | Circle radius in pixels |

When `windowObj` is provided, clicking toggles visibility with a full fade animation. Open popups (dropdowns, color pickers) are automatically closed on toggle.

### Example

```lua
local toggleBtn = DarkLib:CreateToggleButton({
    IconID = "rbxassetid://10734897102",
    Radius = 30,
}, Window)
```

---

## Flag System

Every component accepts an optional `flag` string as its second argument. When provided, it registers the component in `DarkLib.Options[flag]`, allowing you to access or control it from anywhere in your script.

```lua
Tab:CreateToggle({
    Name     = "ESP",
    Default  = false,
    Callback = function(v) end,
}, "ESP")

Tab:CreateSlider({
    Name     = "FOV",
    Range    = {50, 120},
    Default  = 90,
    Callback = function(v) end,
}, "FOV")

-- Access anywhere
print(DarkLib.Options.ESP.Default)   -- boolean
print(DarkLib.Options.FOV.Default)   -- number

-- Control anywhere
DarkLib.Options.ESP:UpdateState(true)
DarkLib.Options.FOV:UpdateValue(100)
```

> `DarkLib.Flags` is also available and mirrors `DarkLib.Options`.

---

## Lock System

All interactive components support locking via `ToggleLock`. When locked, a semi-transparent overlay is applied and all interaction is blocked.

```lua
component:ToggleLock(true)   -- lock
component:ToggleLock(false)  -- unlock
component:IsLocked()         -- returns bool
```

When unlocking, an animated padlock icon transition plays before the overlay disappears.

```lua
local slider = Tab:CreateSlider({
    Name     = "Power",
    Range    = {1, 100},
    Default  = 50,
    Callback = function(v) end,
}, "Power")

slider:ToggleLock(true)

task.delay(5, function()
    slider:ToggleLock(false)
end)
```

---

## Executor Compatibility

DarkLib V6 detects the executor environment automatically.

| Feature | Method |
|---|---|
| GUI Parenting | `gethui()` → `syn.protect_gui` → `CoreGui` (fallback) |
| Clipboard Paste | `getclipboard()` → `GuiService:GetClipboard()` (fallback) |

All callbacks are wrapped in `pcall` via `SafeCall`. A broken callback will never crash the UI — it triggers a brief red error flash on the affected component and prints a warning:

```
[DarkLibV6] Toggle 'God Mode' error: attempt to index nil value
```
