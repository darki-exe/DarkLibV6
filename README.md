# DarkLib V6

DarkLib V6 is a modern UI framework for Roblox executors, focused on consistency, smooth animations, and ease of use.

---

## Preview

![DarkLib Preview](https://cdn.discordapp.com/attachments/1294749078265135115/1493772993065652425/IMG_20260414_214025.png?ex=69e03002&is=69dede82&hm=faedcb661450795bc22034689927360787a674964f2da072ac0d9562e3f13c91&)

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

local Tab1 = Window:CreateTab({ Name = "Buttons", IconID = "10747384394" })

Tab1:CreateDiscordInviter({
    Name   = "my server",
    Link   = "https://discord.gg/serverlink",
    IconID = "10734897102",
})

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
    Default = false,
    Callback     = function(v)
        DarkLib:Notify({ Title = "Toggle", Content = "Simple toggle: " .. tostring(v), Type = v and "success" or "warn" })
    end,
}, "ToggleSimple")

local togDesc = Tab1:CreateToggle({
    Name         = "Toggle with Description",
    Description  = "Toggling this affects the described feature.",
    Default = true,
    Callback     = function(v)
        DarkLib:Notify({ Title = "Toggle", Content = "Toggle w/ desc: " .. tostring(v), Type = v and "success" or "warn" })
    end,
}, "ToggleDesc")

Tab1:CreateDivider({ Text = "Toggle Controls" })

Tab1:CreateButton({
    Name     = "Force Both Toggles OFF",
    Callback = function()
        togSimple:UpdateState(false)
        togDesc:UpdateState(false)
        DarkLib:Notify({ Title = "UpdateState", Content = "Both toggles set to false.", Type = "warn" })
    end,
})

Tab1:CreateButton({
    Name     = "Force Both Toggles ON",
    Callback = function()
        togSimple:UpdateState(true)
        togDesc:UpdateState(true)
        DarkLib:Notify({ Title = "UpdateState", Content = "Both toggles set to true.", Type = "success" })
    end,
})

Tab1:CreateButton({
    Name     = "Lock Simple Toggle",
    Callback = function()
        togSimple:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "Simple toggle locked.", Type = "warn" })
    end,
})

Tab1:CreateButton({
    Name     = "Unlock Simple Toggle",
    Callback = function()
        togSimple:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "Simple toggle unlocked.", Type = "success" })
    end,
})

Tab1:CreateButton({
    Name     = "Check Lock State",
    Callback = function()
        DarkLib:Notify({
            Title   = "Lock State",
            Content = "Simple toggle locked: " .. tostring(togSimple:IsLocked()),
            Type    = "info",
        })
    end,
})

Tab1:CreateButton({
    Name     = "Destroy Toggle w/ Desc",
    Callback = function()
        togDesc:Destroy()
        DarkLib:Notify({ Title = "Destroy", Content = "Toggle with description destroyed.", Type = "error" })
    end,
})
```
