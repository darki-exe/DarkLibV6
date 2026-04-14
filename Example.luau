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

local Tab2 = Window:CreateTab({ Name = "Sliders" })

Tab2:CreateDivider({ Text = "Sliders" })

local slSpeed = Tab2:CreateSlider({
    Name         = "Walk Speed",
    Description  = "Controls the character's walking speed.",
    Range        = { 0, 500 },
    Increment    = 5,
    CurrentValue = 16,
    Suffix       = " studs/s",
    Callback     = function(v)
        DarkLib:Notify({ Title = "Speed", Content = "Walk speed: " .. v, Type = "info", Duration = 1 })
    end,
}, "SliderSpeed")

local slJump = Tab2:CreateSlider({
    Name         = "Jump Power",
    Range        = { 0, 200 },
    Increment    = 1,
    CurrentValue = 50,
    Suffix       = "",
    Callback     = function(v)
        DarkLib:Notify({ Title = "Jump", Content = "Jump power: " .. v, Type = "info", Duration = 1 })
    end,
}, "SliderJump")

local slTrans = Tab2:CreateSlider({
    Name         = "Transparency",
    Range        = { 0, 1 },
    Increment    = 0.05,
    CurrentValue = 0,
    Suffix       = "",
    Callback     = function(v)
        print("Transparency:", v)
    end,
}, "SliderTrans")

Tab2:CreateDivider({ Text = "Slider Controls" })

Tab2:CreateButton({
    Name     = "Reset All Sliders",
    Callback = function()
        slSpeed:UpdateValue(16)
        slJump:UpdateValue(50)
        slTrans:UpdateValue(0)
        DarkLib:Notify({ Title = "Reset", Content = "All sliders reset to defaults.", Type = "info" })
    end,
})

Tab2:CreateButton({
    Name     = "Max Walk Speed",
    Callback = function()
        slSpeed:UpdateValue(500)
        DarkLib:Notify({ Title = "Speed", Content = "Walk speed set to max (500).", Type = "warn" })
    end,
})

Tab2:CreateButton({
    Name     = "Lock Speed Slider",
    Callback = function()
        slSpeed:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "Speed slider locked.", Type = "warn" })
    end,
})

Tab2:CreateButton({
    Name     = "Unlock Speed Slider",
    Callback = function()
        slSpeed:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "Speed slider unlocked.", Type = "success" })
    end,
})

local Tab3 = Window:CreateTab({ Name = "Inputs" })

Tab3:CreateDivider({ Text = "Text Inputs" })

local inpName = Tab3:CreateInput({
    Name            = "Player Name",
    Description     = "Fires callback on every keystroke.",
    PlaceholderText = "Enter a player name...",
    CurrentValue    = "",
    Callback        = function(v)
        DarkLib:Notify({ Title = "Input", Content = 'Name: "' .. v .. '"', Type = "info", Duration = 1 })
    end,
}, "InputName")

local inpNum = Tab3:CreateInput({
    Name            = "Numeric Field",
    Description     = "Accepts numbers only, max 6 characters.",
    PlaceholderText = "e.g. 123456",
    Numeric         = true,
    MaxCharacters   = 6,
    Callback        = function(v)
        DarkLib:Notify({ Title = "Numeric", Content = "Value: " .. v, Type = "success" })
    end,
}, "InputNum")

Tab3:CreateInput({
    Name             = "Enter-Only Input",
    Description      = "Callback fires only when Enter is pressed.",
    PlaceholderText  = "Type and press Enter...",
    Enter            = true,
    ClearOnFocusLost = true,
    Callback         = function(v)
        DarkLib:Notify({ Title = "Confirmed", Content = "Input: " .. v, Type = "success" })
    end,
})

Tab3:CreateDivider({ Text = "Input Controls" })

Tab3:CreateButton({
    Name     = "Set Player Name to 'darki'",
    Callback = function()
        inpName:Set({ CurrentValue = "darki" })
        DarkLib:Notify({ Title = "Input Set", Content = "Name field set to 'darki'.", Type = "info" })
    end,
})

Tab3:CreateButton({
    Name     = "Clear Numeric Field",
    Callback = function()
        inpNum:Set({ CurrentValue = "" })
        DarkLib:Notify({ Title = "Input Cleared", Content = "Numeric field cleared.", Type = "warn" })
    end,
})

Tab3:CreateButton({
    Name     = "Lock Name Input",
    Callback = function()
        inpName:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "Name input locked.", Type = "warn" })
    end,
})

Tab3:CreateButton({
    Name     = "Unlock Name Input",
    Callback = function()
        inpName:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "Name input unlocked.", Type = "success" })
    end,
})

local Tab4 = Window:CreateTab({ Name = "Dropdowns" })

Tab4:CreateDivider({ Text = "Single Select" })

local ddMode = Tab4:CreateDropdown({
    Name          = "Game Mode",
    Description   = "Select the active game mode.",
    Options       = { "Normal", "Silent", "Aggressive", "Passive", "Debug" },
    CurrentOption = "Normal",
    Callback      = function(v)
        DarkLib:Notify({ Title = "Dropdown", Content = "Mode: " .. tostring(v), Type = "info" })
    end,
}, "DropdownMode")

Tab4:CreateDivider({ Text = "Multi Select" })

local ddFeatures = Tab4:CreateDropdown({
    Name            = "Active Features",
    Description     = "Select one or more features to enable.",
    Options         = { "Fly", "Speed", "NoClip", "InfJump", "ESP", "Aimbot" },
    CurrentOption   = { "Fly", "Speed" },
    MultipleOptions = true,
    Callback        = function(v)
        DarkLib:Notify({ Title = "Features", Content = "Active: " .. table.concat(v, ", "), Type = "info" })
    end,
}, "DropdownFeatures")

Tab4:CreateDivider({ Text = "Dropdown Controls" })

Tab4:CreateButton({
    Name     = "Reset Mode to Normal",
    Callback = function()
        ddMode:Set({ CurrentOption = "Normal" })
        DarkLib:Notify({ Title = "Reset", Content = "Mode reset to Normal.", Type = "warn" })
    end,
})

Tab4:CreateButton({
    Name     = "Reset Features to Fly Only",
    Callback = function()
        ddFeatures:Set({ CurrentOption = { "Fly" } })
        DarkLib:Notify({ Title = "Reset", Content = "Features reset to Fly only.", Type = "warn" })
    end,
})

Tab4:CreateButton({
    Name     = "Lock Mode Dropdown",
    Callback = function()
        ddMode:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "Mode dropdown locked.", Type = "warn" })
    end,
})

Tab4:CreateButton({
    Name     = "Unlock Mode Dropdown",
    Callback = function()
        ddMode:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "Mode dropdown unlocked.", Type = "success" })
    end,
})

Tab4:CreateButton({
    Name     = "Destroy Features Dropdown",
    Callback = function()
        ddFeatures:Destroy()
        DarkLib:Notify({ Title = "Destroy", Content = "Features dropdown destroyed.", Type = "error" })
    end,
})

local Tab5 = Window:CreateTab({ Name = "Keybinds" })

Tab5:CreateDivider({ Text = "Press Binds" })

local bindFly = Tab5:CreateBind({
    Name           = "Toggle Fly",
    Description    = "Press the bound key to toggle fly.",
    CurrentBind    = "F",
    HoldToInteract = false,
    Callback       = function()
        DarkLib:Notify({ Title = "Fly", Content = "Fly toggled!", Type = "success" })
    end,
}, "BindFly")

local bindNoclip = Tab5:CreateBind({
    Name           = "Toggle NoClip",
    CurrentBind    = "N",
    HoldToInteract = false,
    Callback       = function()
        DarkLib:Notify({ Title = "NoClip", Content = "NoClip toggled!", Type = "success" })
    end,
}, "BindNoClip")

Tab5:CreateDivider({ Text = "Hold Binds" })

Tab5:CreateBind({
    Name           = "Hold to Sprint",
    Description    = "Hold the key to activate sprint.",
    CurrentBind    = "LeftShift",
    HoldToInteract = true,
    Callback       = function(holding)
        if holding then
            DarkLib:Notify({ Title = "Sprint", Content = "Sprinting ON", Type = "success", Duration = 1 })
        else
            DarkLib:Notify({ Title = "Sprint", Content = "Sprinting OFF", Type = "warn", Duration = 1 })
        end
    end,
}, "BindSprint")

Tab5:CreateBind({
    Name           = "Hold to Aim",
    Description    = "Hold the key to enable aim assist.",
    CurrentBind    = "Q",
    HoldToInteract = true,
    Callback       = function(holding)
        DarkLib:Notify({ Title = "Aim Assist", Content = holding and "Active" or "Inactive", Type = holding and "success" or "warn", Duration = 1 })
    end,
}, "BindAim")

Tab5:CreateDivider({ Text = "Keybind Controls" })

Tab5:CreateButton({
    Name     = "Reset Fly Bind to F",
    Callback = function()
        bindFly:Set({ CurrentBind = "F" })
        DarkLib:Notify({ Title = "Reset", Content = "Fly bind reset to F.", Type = "info" })
    end,
})

Tab5:CreateButton({
    Name     = "Lock NoClip Bind",
    Callback = function()
        bindNoclip:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "NoClip bind locked.", Type = "warn" })
    end,
})

Tab5:CreateButton({
    Name     = "Unlock NoClip Bind",
    Callback = function()
        bindNoclip:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "NoClip bind unlocked.", Type = "success" })
    end,
})

Tab5:CreateButton({
    Name     = "Destroy Fly Bind",
    Callback = function()
        bindFly:Destroy()
        DarkLib:Notify({ Title = "Destroy", Content = "Fly bind destroyed.", Type = "error" })
    end,
})

local Tab6 = Window:CreateTab({ Name = "Visual" })

Tab6:CreateDivider({ Text = "Color Pickers" })

local cpESP = Tab6:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(120, 90, 220),
    Callback = function(col)
        DarkLib:Notify({ Title = "Color", Content = "ESP color updated.", Type = "info", Duration = 1 })
        print("ESP:", col)
    end,
}, "ColorESP")

local cpChams = Tab6:CreateColorPicker({
    Name     = "Chams Color",
    Color    = Color3.fromRGB(80, 200, 130),
    Callback = function(col)
        DarkLib:Notify({ Title = "Color", Content = "Chams color updated.", Type = "info", Duration = 1 })
        print("Chams:", col)
    end,
}, "ColorChams")

local cpUI = Tab6:CreateColorPicker({
    Name     = "UI Accent Color",
    Color    = Color3.fromRGB(150, 115, 255),
    Callback = function(col)
        print("UI Accent:", col)
    end,
}, "ColorUI")

Tab6:CreateDivider({ Text = "Color Controls" })

Tab6:CreateButton({
    Name     = "Reset ESP Color",
    Callback = function()
        cpESP:Set({ Color = Color3.fromRGB(120, 90, 220) })
        DarkLib:Notify({ Title = "Reset", Content = "ESP color reset.", Type = "info" })
    end,
})

Tab6:CreateButton({
    Name     = "Reset Chams Color",
    Callback = function()
        cpChams:Set({ Color = Color3.fromRGB(80, 200, 130) })
        DarkLib:Notify({ Title = "Reset", Content = "Chams color reset.", Type = "info" })
    end,
})

Tab6:CreateButton({
    Name     = "Lock ESP Color",
    Callback = function()
        cpESP:ToggleLock(true)
        DarkLib:Notify({ Title = "Lock", Content = "ESP color picker locked.", Type = "warn" })
    end,
})

Tab6:CreateButton({
    Name     = "Unlock ESP Color",
    Callback = function()
        cpESP:ToggleLock(false)
        DarkLib:Notify({ Title = "Unlock", Content = "ESP color picker unlocked.", Type = "success" })
    end,
})

Tab6:CreateButton({
    Name     = "Destroy UI Color Picker",
    Callback = function()
        cpUI:Destroy()
        DarkLib:Notify({ Title = "Destroy", Content = "UI color picker destroyed.", Type = "error" })
    end,
})

Tab6:CreateDivider({ Text = "Labels" })

Tab6:CreateLabel({ Text = "Default label (style 1)", Style = 1 })
Tab6:CreateLabel({ Text = "Info label (style 2)", Style = 2 })
Tab6:CreateLabel({ Text = "Warning label (style 3)", Style = 3 })

local dynLabel = Tab6:CreateLabel({ Text = "This label updates in 3 seconds...", Style = 1 })
task.delay(3, function()
    dynLabel:Set("Label updated via :Set() after 3s!")
end)

Tab6:CreateButton({
    Name     = "Destroy Dynamic Label",
    Callback = function()
        dynLabel:Destroy()
        DarkLib:Notify({ Title = "Destroy", Content = "Dynamic label destroyed.", Type = "error" })
    end,
})

Tab6:CreateDivider({ Text = "Paragraphs" })

Tab6:CreateParagraph({
    Title = "What is DarkLib V6?",
    Text  = "DarkLib V6 is a feature-rich UI library for Roblox executors.\n\nIt supports: Button, Toggle, Slider, Input, Dropdown, Keybind, ColorPicker, Label, Paragraph, Dialog, Notifications, and a Key System.\n\nAll components support flags, :Destroy(), :ToggleLock(), and :IsLocked().",
})

Tab6:CreateParagraph({
    Title = "Flag System",
    Text  = "Pass a string as the second argument to any component to register it as a flag.\n\nExample: CreateToggle({...}, \"MyFlag\")\n\nRead it back via: DarkLib.Options[\"MyFlag\"]\n\nThis lets you manage component state from anywhere in your script.",
})

local Tab7 = Window:CreateTab({ Name = "Notifications" })

Tab7:CreateDivider({ Text = "Notification Types" })

Tab7:CreateButton({
    Name     = "Info Notification",
    Callback = function()
        DarkLib:Notify({ Title = "Info", Content = "This is an informational message.", Type = "info" })
    end,
})

Tab7:CreateButton({
    Name     = "Success Notification",
    Callback = function()
        DarkLib:Notify({ Title = "Success", Content = "The operation completed successfully!", Type = "success" })
    end,
})

Tab7:CreateButton({
    Name     = "Warning Notification",
    Callback = function()
        DarkLib:Notify({ Title = "Warning", Content = "Proceed with caution.", Type = "warn" })
    end,
})

Tab7:CreateButton({
    Name     = "Error Notification",
    Callback = function()
        DarkLib:Notify({ Title = "Error", Content = "Something went wrong. Check output.", Type = "error" })
    end,
})

Tab7:CreateDivider({ Text = "Custom Duration" })

Tab7:CreateButton({
    Name     = "Short (2s)",
    Callback = function()
        DarkLib:Notify({ Title = "Short", Content = "Disappears in 2 seconds.", Type = "info", Duration = 2 })
    end,
})

Tab7:CreateButton({
    Name     = "Long (10s)",
    Callback = function()
        DarkLib:Notify({ Title = "Long", Content = "This notification stays for 10 seconds.", Type = "warn", Duration = 10 })
    end,
})

Tab7:CreateButton({
    Name     = "Spam 5 Notifications",
    Callback = function()
        local types = { "info", "success", "warn", "error", "info" }
        local msgs  = { "First!", "Second!", "Third!", "Fourth!", "Fifth!" }
        for i = 1, 5 do
            task.delay((i - 1) * 0.3, function()
                DarkLib:Notify({ Title = "Spam " .. i, Content = msgs[i], Type = types[i], Duration = 3 })
            end)
        end
    end,
})

local Tab8 = Window:CreateTab({ Name = "Dialog" })

Tab8:CreateDivider({ Text = "1 Button" })

Tab8:CreateButton({
    Name     = "Open 1 Button Dialog",
    Callback = function()
        DarkLib:Dialog({
            Title       = "Notice",
            Description = "This dialog has a single button spanning full width.",
            Buttons = {
                {
                    Text        = "Dismiss",
                    Color       = Color3.fromRGB(120, 90, 220),
                    StrokeColor = Color3.fromRGB(150, 115, 255),
                    Round       = 7,
                    Callback    = function(id)
                        DarkLib:Notify({ Title = "Dialog", Content = "Dismissed (btn " .. id .. ")", Type = "info" })
                    end,
                },
            },
        })
    end,
})

Tab8:CreateDivider({ Text = "2 Buttons" })

Tab8:CreateButton({
    Name     = "Open 2 Button Dialog",
    Callback = function()
        DarkLib:Dialog({
            Title       = "Confirm Action",
            Description = "Are you sure you want to proceed? This action cannot be undone.",
            Buttons = {
                {
                    Text        = "Confirm",
                    Color       = Color3.fromRGB(80, 200, 130),
                    StrokeColor = Color3.fromRGB(60, 160, 100),
                    Round       = 7,
                    Callback    = function(id)
                        DarkLib:Notify({ Title = "Dialog", Content = "Confirmed (btn " .. id .. ")", Type = "success" })
                    end,
                },
                {
                    Text        = "Cancel",
                    Color       = Color3.fromRGB(200, 70, 70),
                    StrokeColor = Color3.fromRGB(160, 50, 50),
                    Round       = 7,
                    Callback    = function(id)
                        DarkLib:Notify({ Title = "Dialog", Content = "Cancelled (btn " .. id .. ")", Type = "warn" })
                    end,
                },
            },
        })
    end,
})

Tab8:CreateDivider({ Text = "3 Buttons" })

Tab8:CreateButton({
    Name     = "Open 3 Button Dialog",
    Callback = function()
        DarkLib:Dialog({
            Title       = "Choose an Option",
            Description = "Three choices are available. The third button appears centered on the second row.",
            Buttons = {
                {
                    Text        = "Option A",
                    Color       = Color3.fromRGB(120, 90, 220),
                    StrokeColor = Color3.fromRGB(150, 115, 255),
                    Round       = 7,
                },
                {
                    Text        = "Option B",
                    Color       = Color3.fromRGB(60, 140, 200),
                    StrokeColor = Color3.fromRGB(40, 110, 170),
                    Round       = 7,
                },
                {
                    Text        = "Cancel",
                    Color       = Color3.fromRGB(200, 70, 70),
                    StrokeColor = Color3.fromRGB(160, 50, 50),
                    Round       = 7,
                },
            },
            Callback = function(id)
                DarkLib:Notify({ Title = "Dialog", Content = "Selected button " .. id, Type = "info" })
            end,
        })
    end,
})

Tab8:CreateDivider({ Text = "4 Buttons" })

Tab8:CreateButton({
    Name     = "Open 4 Button Dialog",
    Callback = function()
        DarkLib:Dialog({
            Title       = "Select Action",
            Description = "Four actions available. Buttons 3 and 4 share the second row at the same height as the 3-button layout.",
            Buttons = {
                {
                    Text        = "Teleport",
                    Color       = Color3.fromRGB(120, 90, 220),
                    StrokeColor = Color3.fromRGB(150, 115, 255),
                    Round       = 7,
                },
                {
                    Text        = "Spectate",
                    Color       = Color3.fromRGB(60, 140, 200),
                    StrokeColor = Color3.fromRGB(40, 110, 170),
                    Round       = 7,
                },
                {
                    Text        = "Kick",
                    Color       = Color3.fromRGB(200, 70, 70),
                    StrokeColor = Color3.fromRGB(160, 50, 50),
                    Round       = 7,
                },
                {
                    Text        = "Cancel",
                    Color       = Color3.fromRGB(50, 50, 65),
                    StrokeColor = Color3.fromRGB(80, 78, 110),
                    Round       = 7,
                },
            },
            Callback = function(id)
                DarkLib:Notify({ Title = "Dialog", Content = "Selected button " .. id, Type = "info" })
            end,
        })
    end,
})

Tab8:CreateDivider({ Text = "No Description" })

Tab8:CreateButton({
    Name     = "Dialog Without Description",
    Callback = function()
        DarkLib:Dialog({
            Title   = "Minimal Dialog",
            Buttons = {
                {
                    Text        = "Got it",
                    Color       = Color3.fromRGB(120, 90, 220),
                    StrokeColor = Color3.fromRGB(150, 115, 255),
                    Round       = 7,
                },
            },
        })
    end,
})

local Tab9 = Window:CreateTab({ Name = "Flags" })

Tab9:CreateDivider({ Text = "Flag Inspector" })

Tab9:CreateButton({
    Name     = "Print All Flags",
    Callback = function()
        for k, obj in pairs(DarkLib.Options) do
            local val
            if obj.CurrentValue ~= nil then
                val = tostring(obj.CurrentValue)
            elseif obj.CurrentOption ~= nil then
                val = type(obj.CurrentOption) == "table" and table.concat(obj.CurrentOption, ", ") or tostring(obj.CurrentOption)
            elseif obj.CurrentBind ~= nil then
                val = obj.CurrentBind
            elseif obj.Color ~= nil then
                val = tostring(obj.Color)
            end
            print(string.format("[Flag] %s = %s", k, val or "?"))
        end
        DarkLib:Notify({ Title = "Flags", Content = "All flags printed to output.", Type = "info" })
    end,
})

Tab9:CreateDivider({ Text = "Flag Control" })

Tab9:CreateButton({
    Name     = "Flip ToggleSimple via Flag",
    Callback = function()
        local obj = DarkLib.Options["ToggleSimple"]
        if obj then
            local new = not obj.CurrentValue
            obj:UpdateState(new)
            DarkLib:Notify({ Title = "Flag", Content = "ToggleSimple -> " .. tostring(new), Type = "info" })
        end
    end,
})

Tab9:CreateButton({
    Name     = "Set Speed Slider to 100 via Flag",
    Callback = function()
        local obj = DarkLib.Options["SliderSpeed"]
        if obj then
            obj:UpdateValue(100)
            DarkLib:Notify({ Title = "Flag", Content = "SliderSpeed set to 100.", Type = "info" })
        end
    end,
})

Tab9:CreateButton({
    Name     = "Set Mode to Debug via Flag",
    Callback = function()
        local obj = DarkLib.Options["DropdownMode"]
        if obj then
            obj:Set({ CurrentOption = "Debug" })
            DarkLib:Notify({ Title = "Flag", Content = "DropdownMode set to Debug.", Type = "info" })
        end
    end,
})

Tab9:CreateButton({
    Name     = "Reset Fly Bind via Flag",
    Callback = function()
        local obj = DarkLib.Options["BindFly"]
        if obj then
            obj:Set({ CurrentBind = "F" })
            DarkLib:Notify({ Title = "Flag", Content = "BindFly reset to F.", Type = "info" })
        end
    end,
})

Tab9:CreateButton({
    Name     = "Reset ESP Color via Flag",
    Callback = function()
        local obj = DarkLib.Options["ColorESP"]
        if obj then
            obj:Set({ Color = Color3.fromRGB(120, 90, 220) })
            DarkLib:Notify({ Title = "Flag", Content = "ESP color reset via flag.", Type = "info" })
        end
    end,
})

Tab9:CreateButton({
    Name     = "Check ToggleSimple Lock via Flag",
    Callback = function()
        local obj = DarkLib.Options["ToggleSimple"]
        if obj then
            DarkLib:Notify({ Title = "Flag", Content = "ToggleSimple locked: " .. tostring(obj:IsLocked()), Type = "info" })
        end
    end,
})

Tab9:CreateDivider({ Text = "Reference" })

Tab9:CreateParagraph({
    Title = "Component Methods",
    Text  = "Toggle: :UpdateState(bool), :ToggleLock(bool), :IsLocked(), :Destroy()\nSlider: :UpdateValue(number), :ToggleLock(bool), :IsLocked(), :Destroy()\nDropdown: :Set({CurrentOption}), :ToggleLock(bool), :IsLocked(), :Destroy()\nInput: :Set({CurrentValue}), :ToggleLock(bool), :IsLocked(), :Destroy()\nKeybind: :Set({CurrentBind}), :ToggleLock(bool), :IsLocked(), :Destroy()\nColorPicker: :Set({Color}), :ToggleLock(bool), :IsLocked(), :Destroy()\nLabel: :Set(string), :Destroy()\nButton: :Destroy()",
})
