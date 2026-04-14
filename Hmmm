
# DarkLib V6 — Official Documentation

> **Version:** V6  
> **Author:** darkmoonhub (`darki-exe`)  
> **Repository:** [github.com/darki-exe/DarkLibV6](https://github.com/darki-exe/DarkLibV6)  
> **Language:** Luau (Roblox)

---

## Table of Contents

1. [Overview](#overview)
2. [Loading the Library](#loading-the-library)
3. [Theme System](#theme-system)
4. [Notifications — `DarkLib:Notify()`](#notifications)
5. [Window — `DarkLib:CreateWindow()`](#window)
   - [Key System](#key-system)
   - [Window Methods](#window-methods)
6. [Tab — `WindowObj:CreateTab()`](#tab)
7. [Components](#components)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Input](#input)
   - [Dropdown](#dropdown)
   - [Keybind](#keybind)
   - [Color Picker](#color-picker)
   - [Label](#label)
   - [Paragraph](#paragraph)
   - [Divider](#divider)
8. [Dialog — `DarkLib:Dialog()`](#dialog)
9. [Toggle Button — `DarkLib:CreateToggleButton()`](#toggle-button)
10. [Flag System — `DarkLib.Options`](#flag-system)
11. [Lock System](#lock-system)
12. [Executor Compatibility](#executor-compatibility)

---

## Overview

**DarkLib V6** is a feature-rich, theme-consistent UI library for Roblox, designed for use within script executors. It provides a complete set of interactive components inside a draggable, multi-tab window. Key characteristics:

- Dark aesthetic with a purple accent color palette
- Smooth TweenService-based animations throughout
- Full mobile (Touch input) and PC support
- Built-in loading screen and optional key authentication system
- Component locking system to disable/re-enable any element at runtime
- Dialog modal with up to 4 customizable buttons
- Floating toggle button to show/hide the main window
- Notification toasts with auto-dismiss and type theming

---

## Loading the Library

```lua
local DarkLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/darki-exe/DarkLibV6/main/source.lua"
))()
```

> Alternatively, paste the source directly into your script if you have it locally.

---

## Theme System

DarkLib exposes its internal color theme at `DarkLib.Theme`. All colors are `Color3` values. The default palette is:

| Key | Description | Default RGB |
|---|---|---|
| `BG` | Main window background | `(14, 14, 18)` |
| `BG2` | Secondary background (topbar, cards) | `(20, 20, 26)` |
| `BG3` | Elevated surface (buttons, rows) | `(28, 28, 36)` |
| `Surface` | Content area background | `(22, 22, 30)` |
| `NavBG` | Navigation panel background | `(16, 16, 22)` |
| `Border` | Default border color | `(42, 42, 58)` |
| `BorderHover` | Border color on hover | `(80, 78, 110)` |
| `Accent` | Primary accent (purple) | `(120, 90, 220)` |
| `AccentDim` | Dimmed accent | `(75, 55, 145)` |
| `AccentGlow` | Bright accent glow | `(150, 115, 255)` |
| `Text` | Primary text | `(220, 218, 232)` |
| `TextDim` | Secondary text | `(140, 136, 165)` |
| `TextMuted` | Muted/placeholder text | `(80, 78, 100)` |
| `Green` | Success color | `(80, 200, 130)` |
| `Red` | Error/danger color | `(200, 70, 70)` |
| `Yellow` | Warning color | `(230, 190, 60)` |
| `TabActive` | Active tab background | `(34, 32, 50)` |
| `TabInactive` | Inactive tab background | `(0, 0, 0)` |

You can override individual colors at runtime:

```lua
DarkLib.Theme.Accent = Color3.fromRGB(255, 100, 100)
```

> ⚠️ Theme changes apply only to subsequently created components, not retroactively to existing ones.

---

## Notifications

```lua
DarkLib:Notify(data: table)
```

Displays an animated toast notification in the bottom-right corner of the screen. Notifications auto-dismiss after a calculated or specified duration.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Notification"` | Bold title text |
| `Content` | `string` | `""` | Body text (wraps automatically) |
| `Duration` | `number?` | auto | Display time in seconds. If `nil`, calculated from content length (clamp 3–10s) |
| `Type` | `string` | `"info"` | Notification type: `"info"`, `"success"`, `"warn"`, `"error"` |

The accent bar color on the left side of the card is automatically determined by `Type`.

### Example

```lua
DarkLib:Notify({
    Title   = "Script Loaded",
    Content = "DarkLib V6 has been initialized successfully.",
    Type    = "success",
    Duration = 5
})

DarkLib:Notify({
    Title   = "Warning",
    Content = "Remote event not found. Retrying...",
    Type    = "warn"
})
```

---

## Window

```lua
local Window = DarkLib:CreateWindow(cfg: table)
```

Creates the main application window. Only one window can exist at a time — calling `CreateWindow` again destroys the previous one.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"DarkLib V6"` | Window title shown in the top bar |
| `Subtitle` | `string` | `"by darkmoonhub"` | Subtitle shown next to the title |
| `HideBind` | `Enum.KeyCode` | `RightControl` | Keybind to toggle window visibility |
| `LoadingScreen` | `bool` | `true` | Show animated loading screen on startup |
| `LoadingTitle` | `string` | `"Loading..."` | Text shown during loading |
| `KeySystem` | `bool` | `false` | Enable key authentication overlay |
| `KeySettings` | `table` | `{}` | Key system configuration (see below) |

### Window Size

The window size adapts to the current viewport, clamped between:
- Width: `560–720px`
- Height: `380–480px`

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

Activated by setting `KeySystem = true` in `CreateWindow`. Displays a full-screen overlay over the window requiring a valid key before the UI becomes accessible.

#### `KeySettings` Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `cfg.Title` | Title shown on the key screen |
| `Subtitle` | `string` | `"Key Required"` | Subtitle text |
| `Description` | `string?` | `nil` | Optional description below subtitle |
| `Key` | `{string}` | `{""}` | Array of valid keys (any match is accepted) |
| `SaveKey` | `bool` | `false` | Reserved for future save-to-file support |
| `Placeholder` | `string?` | `"Enter your key..."` | Placeholder text in the input box |
| `KeyLink` | `string?` | `nil` | If provided, shows a "Get Key" button that copies this URL |
| `Icon` | `string?` | `nil` | Roblox asset ID for an icon shown above the title |
| `MaxAttempts` | `number` | `5` | Maximum failed attempts before lockout |
| `LockDuration` | `number` | `30` | Seconds of lockout after `MaxAttempts` is exceeded |

Features:
- Input field with paste button (`getclipboard` / `GuiService:GetClipboard()` fallback)
- Animated shake effect on incorrect key entry
- Countdown lockout timer
- Auto-submits when Enter is pressed in the input field
- Fade-in/fade-out animations for all elements

### Example

```lua
local Window = DarkLib:CreateWindow({
    Title      = "My Script",
    KeySystem  = true,
    KeySettings = {
        Title       = "Authentication",
        Subtitle    = "Key Required",
        Description = "Join our Discord to get a key.",
        Key         = { "mySecretKey123", "altKey456" },
        KeyLink     = "https://discord.gg/example",
        MaxAttempts = 3,
        LockDuration = 60,
    }
})
```

---

### Window Methods

#### `WindowObj:CreateTab(tabCfg)`

Creates a new navigation tab. See [Tab](#tab) section.

#### `WindowObj:CreateCloseButton(cfg2)`

Customizes the close button icon in the top bar.

| Field | Type | Description |
|---|---|---|
| `IconId` | `string?` | Roblox asset ID string (e.g. `"rbxassetid://12345"`). Falls back to `"X"` text |

```lua
Window:CreateCloseButton({ IconId = "rbxassetid://7072725342" })
```

#### `WindowObj:CreateMinimizeButton(cfg2)`

Customizes the minimize button. Supports two separate icons for minimized / restored states.

| Field | Type | Description |
|---|---|---|
| `OnIconId` | `string?` | Icon asset ID when window is minimized (shows restore icon) |
| `OffIconId` | `string?` | Icon asset ID when window is visible (shows minimize icon) |

```lua
Window:CreateMinimizeButton({
    OnIconId  = "rbxassetid://7072725342",  -- icon shown when minimized
    OffIconId = "rbxassetid://7072725399",  -- icon shown when open
})
```

---

## Tab

```lua
local Tab = Window:CreateTab(tabCfg: table)
```

Creates a tab navigation entry and a corresponding scrollable content page.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Tab"` | Tab label displayed in the navigation panel |
| `Icon` | `any` | `nil` | Reserved field (not yet rendered) |

The first tab created is automatically selected. Tabs are displayed as a vertical list in the left navigation panel. Each page is a `ScrollingFrame` with auto-canvas sizing.

### Example

```lua
local MainTab     = Window:CreateTab({ Name = "Main" })
local SettingsTab = Window:CreateTab({ Name = "Settings" })
local VisualsTab  = Window:CreateTab({ Name = "Visuals" })
```

---

## Components

All components are methods on a `TabObj` returned by `CreateTab`. Each component appends itself to the tab's scrollable page and returns a control object with methods to update or destroy it.

Every component accepts an optional `flag` string as its second argument. If provided, the component is registered in `DarkLib.Options[flag]` for global access.

---

### Toggle

```lua
local TogObj = Tab:CreateToggle(togCfg: table, flag: string?)
```

A boolean on/off toggle switch.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Toggle"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle below the name |
| `CurrentValue` | `bool` | `false` | Initial state |
| `Callback` | `function(bool)` | `function() end` | Called when the toggle changes |

#### Object Methods

| Method | Description |
|---|---|
| `TogObj:Set(newCfg)` | Update config (name, value, callback) |
| `TogObj:UpdateState(bool)` | Silently set the toggle state (no callback) |
| `TogObj:Destroy()` | Remove the component from the page |
| `TogObj:ToggleLock(bool)` | Lock/unlock the component |

#### Example

```lua
local myToggle = Tab:CreateToggle({
    Name         = "God Mode",
    Description  = "Makes you invincible",
    CurrentValue = false,
    Callback     = function(state)
        print("God Mode:", state)
    end
}, "GodMode")

-- Read value externally
print(DarkLib.Options.GodMode.CurrentValue)

-- Force state silently
myToggle:UpdateState(true)
```

---

### Slider

```lua
local SlObj = Tab:CreateSlider(slCfg: table, flag: string?)
```

A draggable range slider with optional suffix.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Slider"` | Display name |
| `Range` | `{number, number}` | `{0, 100}` | `{min, max}` |
| `Increment` | `number` | `1` | Step size |
| `CurrentValue` | `number` | `50` | Initial value |
| `Suffix` | `string` | `""` | Text appended to value display (e.g. `"ms"`, `"%"`) |
| `Callback` | `function(number)` | `function() end` | Called on value change |

#### Object Methods

| Method | Description |
|---|---|
| `SlObj:Set(newCfg)` | Update config |
| `SlObj:UpdateValue(number)` | Silently set the slider value |
| `SlObj:Destroy()` | Remove the component |
| `SlObj:ToggleLock(bool)` | Lock/unlock the component |

#### Example

```lua
local speedSlider = Tab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 100},
    Increment    = 2,
    CurrentValue = 16,
    Suffix       = " WS",
    Callback     = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
}, "WalkSpeed")
```

---

### Input

```lua
local InObj = Tab:CreateInput(inCfg: table, flag: string?)
```

A text input field.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Input"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `PlaceholderText` | `string` | `"Type here..."` | Placeholder text |
| `CurrentValue` | `string` | `""` | Initial text |
| `Numeric` | `bool` | `false` | If true, only allows numeric input |
| `MaxCharacters` | `number?` | `nil` | Max character limit |
| `Enter` | `bool` | `false` | If true, callback only fires when Enter is pressed |
| `ClearOnFocusLost` | `bool` | `false` | Clear field after losing focus |
| `Callback` | `function(string)` | `function() end` | Called on focus lost (or Enter if `Enter = true`) |

#### Object Methods

| Method | Description |
|---|---|
| `InObj:Set(newCfg)` | Update config and current value |
| `InObj:Destroy()` | Remove the component |
| `InObj:ToggleLock(bool)` | Lock/unlock the component |

#### Example

```lua
Tab:CreateInput({
    Name            = "Target Player",
    PlaceholderText = "Username...",
    Enter           = true,
    Callback        = function(text)
        print("Target set to:", text)
    end
})
```

---

### Dropdown

```lua
local DDObj = Tab:CreateDropdown(ddCfg: table, flag: string?)
```

A dropdown selector with optional multi-select support.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Dropdown"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Options` | `{string}` | `{"Option 1", "Option 2"}` | List of selectable options |
| `CurrentOption` | `string \| {string} \| nil` | `nil` | Initial selection(s) |
| `MultipleOptions` | `bool` | `false` | Allow multiple simultaneous selections |
| `Callback` | `function({string})` | `function() end` | Called with the array of current selections |

The dropdown popup opens below the row (or above if not enough space below).

#### Object Methods

| Method | Description |
|---|---|
| `DDObj:Set(newCfg)` | Update config, options, and selection |
| `DDObj:Destroy()` | Remove the component |
| `DDObj:ToggleLock(bool)` | Lock/unlock the component |
| `DDObj:IsLocked()` | Returns `bool` — whether the dropdown is currently locked |

#### Example

```lua
local gameModeDD = Tab:CreateDropdown({
    Name            = "Game Mode",
    Options         = {"Endless", "1v1", "Ranked"},
    CurrentOption   = "Endless",
    MultipleOptions = false,
    Callback        = function(selected)
        print("Mode:", selected[1])
    end
}, "GameMode")
```

---

### Keybind

```lua
local BndObj = Tab:CreateBind(bndCfg: table, flag: string?)
-- Alias:
local BndObj = Tab:CreateKeybind(bndCfg: table, flag: string?)
```

A keybind listener component. Click the bind box to enter listening mode, then press any key to assign.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Keybind"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `CurrentBind` | `string` | `"None"` | Initial key name (e.g. `"F"`, `"RightShift"`) |
| `HoldToInteract` | `bool` | `false` | If true, callback fires with `true` on press and `false` on release |
| `Callback` | `function(bool?)` | `function() end` | Called when the bound key is pressed (and released if `HoldToInteract`) |

#### Object Methods

| Method | Description |
|---|---|
| `BndObj:Set(newCfg)` | Update config and current bind display |
| `BndObj:Destroy()` | Remove the component |
| `BndObj:ToggleLock(bool)` | Lock/unlock the component |

#### Example

```lua
Tab:CreateBind({
    Name        = "Aimbot Toggle",
    CurrentBind = "Q",
    Callback    = function()
        print("Toggled aimbot")
    end
})

Tab:CreateBind({
    Name           = "Speed Boost",
    CurrentBind    = "LeftShift",
    HoldToInteract = true,
    Callback       = function(holding)
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
local CPObj = Tab:CreateColorPicker(cpCfg: table, flag: string?)
```

A color picker with a saturation/value 2D picker, hue strip, hex input, and R/G/B numeric inputs. Opens as a floating popup aligned to the row.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Color"` | Display name |
| `Description` | `string?` | `nil` | Optional subtitle |
| `Color` | `Color3` | `Color3.fromRGB(255,255,255)` | Initial color |
| `Callback` | `function(Color3)` | `function() end` | Called on every color change |

#### Object Methods

| Method | Description |
|---|---|
| `CPObj:Set(newCfg)` | Update config and initial color |
| `CPObj:Destroy()` | Remove the component and close popup |
| `CPObj:ToggleLock(bool)` | Lock/unlock the component |

#### Example

```lua
local trailColor = Tab:CreateColorPicker({
    Name     = "Trail Color",
    Color    = Color3.fromRGB(120, 90, 220),
    Callback = function(c)
        -- apply color
    end
}, "TrailColor")

-- Read color elsewhere
print(DarkLib.Options.TrailColor.Color)
```

---

### Label

```lua
local LbObj = Tab:CreateLabel(lbCfg: table)
```

A static informational text row. Supports 3 visual styles.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string` | `"Label"` | Label text |
| `Style` | `number` | `1` | `1` = subtle grey, `2` = blue info, `3` = yellow warning |

#### Object Methods

| Method | Description |
|---|---|
| `LbObj:Set(string)` | Update the label text |
| `LbObj:Destroy()` | Remove the component |

#### Example

```lua
Tab:CreateLabel({ Text = "Combat Settings", Style = 1 })
Tab:CreateLabel({ Text = "⚠ Requires executor restart", Style = 3 })
Tab:CreateLabel({ Text = "ℹ Feature is experimental", Style = 2 })
```

---

### Paragraph

```lua
local PgObj = Tab:CreateParagraph(pgCfg: table)
```

A text block with a bold title and a wrapped body. Height auto-adjusts to content.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Paragraph"` | Bold header |
| `Text` | `string` | `""` | Body text. Supports Roblox RichText tags |

#### Object Methods

| Method | Description |
|---|---|
| `PgObj:Set(newCfg)` | Update title and/or text, auto-resizes |
| `PgObj:Destroy()` | Remove the component |

#### Example

```lua
local info = Tab:CreateParagraph({
    Title = "About This Script",
    Text  = "This script was made by <b>darkmoonhub</b>. Use responsibly.",
})

-- Update later
info:Set({
    Title = "Status",
    Text  = "All systems operational."
})
```

---

### Divider

```lua
local DivObj = Tab:CreateDivider(divCfg: table?)
```

A horizontal separator line, optionally with a centered text label.

#### Config

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string?` | `nil` | If provided, displays text centered on the line |
| `Thickness` | `number` | `1` | Line thickness in pixels |

#### Object Methods

| Method | Description |
|---|---|
| `DivObj:Destroy()` | Remove the component |

#### Example

```lua
Tab:CreateDivider()
Tab:CreateDivider({ Text = "Advanced Options", Thickness = 1 })
```

---

## Dialog

```lua
DarkLib:Dialog(data: table)
```

Creates a modal dialog overlay on top of everything, with a backdrop blur and 1–4 customizable buttons.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Dialog"` | Dialog title |
| `Description` | `string` | `""` | Body text (supports wrapping) |
| `Buttons` | `{ButtonCfg}` | **required** | Array of 1–4 button definitions |
| `Callback` | `function(index)?` | `nil` | Called with the button index when any button is pressed |

### Button Config (`ButtonCfg`)

| Field | Type | Default | Description |
|---|---|---|---|
| `Text` | `string` | `"Button N"` | Button label |
| `Color` | `Color3?` | `Theme.Accent` | Button background color |
| `StrokeColor` | `Color3?` | `Theme.Border` | Button border color |
| `StrokeThick` | `number?` | `1` | Border thickness |
| `Round` | `number?` | `7` | Corner radius |
| `Callback` | `function(index)?` | `nil` | Per-button callback |

Button layout:
- 1 button → full width
- 2 buttons → side by side
- 3 buttons → 2 on top, 1 centered below
- 4 buttons → 2×2 grid

### Example

```lua
DarkLib:Dialog({
    Title       = "Confirm Action",
    Description = "Are you sure you want to execute this? This action cannot be undone.",
    Buttons     = {
        {
            Text     = "Confirm",
            Color    = Color3.fromRGB(80, 200, 130),
            Callback = function()
                print("Confirmed!")
            end
        },
        {
            Text     = "Cancel",
            Color    = Color3.fromRGB(200, 70, 70),
        }
    },
    Callback = function(idx)
        print("Button pressed:", idx)
    end
})
```

---

## Toggle Button

```lua
local btn = DarkLib:CreateToggleButton(cfg: table, windowObj: WindowObj?)
```

Creates a floating circular button (default position: top-left) that can show/hide the linked window when tapped. It is independently draggable and supports a 4px threshold to differentiate tap from drag on mobile.

### Parameters

| Field | Type | Default | Description |
|---|---|---|---|
| `IconID` | `string` | `"rbxassetid://0"` | Asset ID for the button icon |
| `Radius` | `number` | `28` | Circle radius in pixels |

When `windowObj` is provided, clicking the button toggles the window's visibility with a full fade animation. Open popups (dropdowns, color pickers) are automatically closed on toggle.

### Example

```lua
local toggleBtn = DarkLib:CreateToggleButton({
    IconID = "rbxassetid://7072725342",
    Radius = 30
}, Window)
```

---

## Flag System

Every component that accepts a `flag` string registers itself in `DarkLib.Options[flag]`. This allows you to access or update any component from anywhere in your script without needing to keep references.

```lua
-- Creating with a flag
Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function() end }, "ESP")
Tab:CreateSlider({ Name = "FOV", Range = {50, 120}, CurrentValue = 90, Callback = function() end }, "FOV")

-- Accessing anywhere later
print(DarkLib.Options.ESP.CurrentValue)      -- boolean
print(DarkLib.Options.FOV.CurrentValue)      -- number

DarkLib.Options.FOV:UpdateValue(100)
DarkLib.Options.ESP:UpdateState(true)
```

`DarkLib.Flags` is also exposed as a companion table (currently mirrors `DarkLib.Options`).

---

## Lock System

Every interactive component (Toggle, Slider, Input, Dropdown, Keybind, Color Picker) supports locking via:

```lua
component:ToggleLock(true)   -- locks
component:ToggleLock(false)  -- unlocks
```

When locked:
- An semi-transparent overlay covers the component
- A padlock icon (`rbxassetid://10723434711`) is shown
- All interaction is blocked

When unlocked:
- The padlock transitions to an unlocked icon (`rbxassetid://10747366027`)
- An animated exit plays — the icon scales up, fades to unlocked, then falls off
- The overlay disappears

```lua
-- Lock a component until a condition is met
local mySlider = Tab:CreateSlider({ Name = "Power", Range = {1, 100}, Callback = function() end }, "Power")
mySlider:ToggleLock(true)

task.delay(5, function()
    mySlider:ToggleLock(false)  -- re-enable after 5 seconds
end)
```

---

## Executor Compatibility

DarkLib V6 automatically detects and adapts to the executor environment for GUI parenting and clipboard access:

| Feature | Detection Method |
|---|---|
| GUI Parenting | `gethui()` → `syn.protect_gui` → `CoreGui` (fallback) |
| Clipboard Paste | `getclipboard()` → `GuiService:GetClipboard()` |

The library uses `pcall` wrappers around all callbacks (`SafeCall`) so a broken callback will never crash the UI — instead it triggers a brief red error flash on the affected component and prints a warning to the console.

```
[DarkLibV6] Toggle 'God Mode' error: attempt to index nil value
```

