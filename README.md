# DarkLib V6

DarkLib V6 is a modern UI framework for Roblox executors, focused on consistency, smooth animations, and ease of use.

---

## Preview

![DarkLib Preview](https://cdn.discordapp.com/attachments/1294749078265135115/1493609479818707074/82_Sem_Titulo_20260414105027.png)

---

## Overview

DarkLib V6 is designed to simplify UI creation while maintaining a clean and professional look.

Instead of manually handling layouts, animations, and states, the library provides a unified system where everything is pre-structured and consistent.

The library focuses on:

- Visual consistency (dark theme with purple accents)
- Smooth transitions using TweenService
- Cross-platform compatibility (PC and mobile)
- Modular and scalable UI structure

---

## Core Features

### Window System
- Draggable multi-tab interface
- Built-in minimize and close controls
- Floating toggle button support

### Components
- Buttons
- Toggles
- Dividers
- Dialogs (up to 4 buttons)
- Notifications (toast system)

### Systems
- Key authentication system
- Component locking system
- Loading screen system

---

## Documentation

https://github.com/darki-exe/DarkLibV6/blob/main/Docs.md

---

## Example

https://github.com/darki-exe/DarkLibV6/blob/main/Example.luau

---

## Basic Usage

```lua
local DarkLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/darki-exe/DarkLibV6/refs/heads/main/Main/Source.luau"))()

local Window = DarkLib:CreateWindow({
    Title         = "DarkLib V6",
    Subtitle      = "Full Demo",
    HideBind      = Enum.KeyCode.RightControl,
    LoadingScreen = true,
    LoadingTitle  = "Initializing...",
    KeySystem     = false,
    KeySettings   = {
        Title        = "DarkLib V6",
        Subtitle     = "Authentication Required",
        Description  = "Obtain your access key from our Discord server.",
        Key          = { "demo-key-2026", "alt-key-9999" },
        Icon         = "",
        Placeholder  = "XXXX-XXXX-XXXX-XXXX",
        KeyLink      = "https://discord.gg/yourlink",
        MaxAttempts  = 3,
        LockDuration = 60,
        SaveKey      = true,
    },
})

Window:CreateCloseButton({ IconId = "10747384394" })
Window:CreateMinimizeButton({ OnIconId = "10734924532", OffIconId = "10734896206" })

local toggleBtn = DarkLib:CreateToggleButton({
    IconID = "rbxassetid://10734897102",
    Radius = 28,
}, Window)

local Tab1 = Window:CreateTab({ Name = "Buttons", Icon = "10747384394" })

Tab1:CreateDivider({ Text = "Basic Buttons" })

Tab1:CreateButton({
    Name     = "Simple Button",
    Callback = function()
        DarkLib:Notify({ Title = "Button", Content = "Simple button clicked.", Type = "success" })
    end,
})

Tab1:CreateButton({
    Name        = "Button with Description",
    Description = "This button has a short description below its name.",
    Callback    = function()
        DarkLib:Notify({ Title = "Button", Content = "Button with description clicked.", Type = "info" })
    end,
})

Tab1:CreateDivider({ Text = "Toggles" })

local togSimple = Tab1:CreateToggle({
    Name         = "Simple Toggle",
    CurrentValue = false,
    Callback     = function(v)
        DarkLib:Notify({ Title = "Toggle", Content = "Simple toggle: " .. tostring(v), Type = v and "success" or "warn" })
    end,
}, "ToggleSimple")

local togDesc = Tab1:CreateToggle({
    Name         = "Toggle with Description",
    Description  = "Toggling this affects the described feature.",
    CurrentValue = true,
    Callback     = function(v)
        DarkLib:Notify({ Title = "Toggle", Content = "Toggle w/ desc: " .. tostring(v), Type = v and "success" or "warn" })
    end,
}, "ToggleDesc")
