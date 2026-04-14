local DarkLib = {
    Options = {},
    Flags = {},
    Version = "V6"
}

local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ActiveWindows = {}
local _isStudio = RS:IsStudio()

local function Merge(defaults, passed)
    passed = passed or {}
    for k, v in pairs(defaults) do
        if passed[k] == nil then
            passed[k] = v
        end
    end
    return passed
end

local _ti_fast = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local _ti_med  = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local _ti_slow = TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function Tween(obj, props, speed)
    local info = (speed == "fast" and _ti_fast) or (speed == "slow" and _ti_slow) or _ti_med
    local t = TS:Create(obj, info, props)
    t:Play()
    return t
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return true, nil end
    return pcall(fn, ...)
end

local function TableContains(t, val)
    for _, v in ipairs(t) do
        if tostring(v) == tostring(val) then return true end
    end
    return false
end

local function TableRemoveValue(t, val)
    for i, v in ipairs(t) do
        if tostring(v) == tostring(val) then
            table.remove(t, i)
            return
        end
    end
end

local function Round(n, inc)
    return math.floor(n / inc + 0.5) * inc
end

local Theme = {
    BG          = Color3.fromRGB(14, 14, 18),
    BG2         = Color3.fromRGB(20, 20, 26),
    BG3         = Color3.fromRGB(28, 28, 36),
    Surface     = Color3.fromRGB(22, 22, 30),
    NavBG       = Color3.fromRGB(16, 16, 22),
    Border      = Color3.fromRGB(42, 42, 58),
    BorderHover = Color3.fromRGB(80, 78, 110),
    Accent      = Color3.fromRGB(120, 90, 220),
    AccentDim   = Color3.fromRGB(75, 55, 145),
    AccentGlow  = Color3.fromRGB(150, 115, 255),
    Text        = Color3.fromRGB(220, 218, 232),
    TextDim     = Color3.fromRGB(140, 136, 165),
    TextMuted   = Color3.fromRGB(80, 78, 100),
    Green       = Color3.fromRGB(80, 200, 130),
    Red         = Color3.fromRGB(200, 70, 70),
    Yellow      = Color3.fromRGB(230, 190, 60),
    TabActive   = Color3.fromRGB(34, 32, 50),
    TabInactive = Color3.fromRGB(0, 0, 0),
}

DarkLib.Theme = Theme

local function New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function UICorner(r)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 6) })
end

local function UIStroke(color, thickness, trans)
    return New("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = trans or 0
    })
end

local function UIListLayout(padding, fillDir, halign, valign)
    return New("UIListLayout", {
        Padding = UDim.new(0, padding or 4),
        FillDirection = fillDir or Enum.FillDirection.Vertical,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
end

local function UIPadding(t, b, l, r)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0)
    })
end

local function MakeOverlayGui(name, displayOrder)
    local existing = CoreGui:FindFirstChild(name)
    if existing then existing:Destroy() end

    local sg = New("ScreenGui", {
        Name = name,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = displayOrder or 9000,
    })

    if gethui then
        sg.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = CoreGui
    else
        sg.Parent = CoreGui
    end

    return sg
end

local function MakeDraggable(handle, target)
    local dragging  = false
    local dragInput = nil
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragInput = input
            dragStart = input.Position
            startPos  = target.Position


            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging  = false
                    dragInput = nil
                end
            end)
        end
    end)


    UIS.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging  = false
            dragInput = nil
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart

        target.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

local NotifHolder

local function SetupNotifHolder()
    local existing = CoreGui:FindFirstChild("DarkLibV6_Notifs")
    if existing then NotifHolder = existing; return end

    local screen = New("ScreenGui", {
        Name = "DarkLibV6_Notifs",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    if gethui then
        screen.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screen)
        screen.Parent = CoreGui
    else
        screen.Parent = CoreGui
    end

    NotifHolder = New("Frame", {
        Name = "Holder",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -294, -0.01, 0),
        BackgroundTransparency = 1,
        Parent = screen
    }, { UIListLayout(6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom) })
end

function DarkLib:Notify(data)
    data = Merge({
        Title = "Notification",
        Content = "",
        Duration = nil,
        Type = "info"
    }, data)

    if not NotifHolder then SetupNotifHolder() end

    local accentColor = ({
        info    = Theme.Accent,
        success = Theme.Green,
        warn    = Theme.Yellow,
        error   = Theme.Red
    })[data.Type] or Theme.Accent

    task.spawn(function()
        local card = New("Frame", {
            Name = "Notif",
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.BG2,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            LayoutOrder = tick(),
        }, {
            UICorner(8),
            UIStroke(Theme.Border, 1, 0.4),
            UIPadding(10, 10, 12, 12),
        })

        New("Frame", {
            Name = "Bar",
            Size = UDim2.new(0, 3, 1, -16),
            Position = UDim2.new(0, 0, 0, 8),
            BackgroundColor3 = accentColor,
            Parent = card
        }, { UICorner(3) })

        local title = New("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = data.Title,
            Parent = card
        })

        local content = New("TextLabel", {
            Name = "Content",
            Size = UDim2.new(1, -16, 0, 0),
            Position = UDim2.new(0, 12, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = Theme.TextDim,
            TextTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Text = data.Content,
            Parent = card
        })

        card.Parent = NotifHolder

        task.wait()
        content.Size = UDim2.new(1, -16, 0, math.huge)
        local textH = content.TextBounds.Y
        content.Size = UDim2.new(1, -16, 0, textH)
        local totalH = 22 + textH + 20

        Tween(card, { Size = UDim2.new(1, 0, 0, totalH), BackgroundTransparency = 0.1 }, "slow")
        task.wait(0.1)
        Tween(title, { TextTransparency = 0 })
        Tween(content, { TextTransparency = 0.15 })

        local waitTime = data.Duration or math.clamp(#data.Content * 0.055 + 2.5, 3, 10)
        task.wait(waitTime)

        Tween(card, { BackgroundTransparency = 1 })
        Tween(title, { TextTransparency = 1 })
        Tween(content, { TextTransparency = 1 })
        Tween(card, { Size = UDim2.new(1, 0, 0, 0) }, "slow")
        task.wait(0.6)
        card:Destroy()
    end)
end

function DarkLib:CreateWindow(cfg)
    cfg = Merge({
        Title         = "DarkLib V6",
        Subtitle      = "by darkmoonhub",
        HideBind      = Enum.KeyCode.RightControl,
        LoadingScreen = true,
        LoadingTitle  = "Loading...",
        KeySystem     = false,
        KeySettings   = {},
    }, cfg)

    cfg.KeySettings = Merge({
        Title    = cfg.Title,
        Subtitle = "Key Required",
        Key      = { "" },
        SaveKey  = false,
    }, cfg.KeySettings)

    
    local existingRoot = CoreGui:FindFirstChild("DarkLibV6_Root")
    if existingRoot then existingRoot:Destroy() end

    local screenGui = New("ScreenGui", {
        Name = "DarkLibV6_Root",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end

    
    local vp = workspace.CurrentCamera.ViewportSize
    local winW = math.min(math.max(vp.X - 120, 560), 720)
    local winH = math.min(math.max(vp.Y - 100, 380), 480)

    
    local Window = New("Frame", {
        Name = "DarkWindow",
        Size = UDim2.fromOffset(winW, winH),
        Position = UDim2.new(0.5, -math.floor(winW/2), 0.5, -math.floor(winH/2)),
        BackgroundColor3 = Theme.BG,
        ClipsDescendants = false,
        Parent = screenGui
    }, { UICorner(10) })

    
    New("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = 0,
        Parent = Window
    })

    
    UIStroke(Theme.Border, 1, 0).Parent = Window

    
    local TopBar = New("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.BG2,
        ZIndex = 2,
        Parent = Window
    }, {
        UICorner(10),
        UIStroke(Theme.Border, 1, 0.5),
    })

    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = TopBar
    })

    New("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar
    }, { UICorner(2) })

    local TitleLabel = New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = cfg.Title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar
    })

    New("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14 + TitleLabel.TextBounds.X + 8, 0, 0),
        BackgroundTransparency = 1,
        Text = cfg.Subtitle,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar
    })

    
    local _ctrlOffset = -12

    local function MakeCtrlBtn(accentColor, iconId, fallbackText)
        local xpos = _ctrlOffset
        _ctrlOffset = _ctrlOffset - 30

        local btn = New("Frame", {
            Size     = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, xpos - 22, 0.5, -11),
            BackgroundColor3 = Theme.BG3,
            ZIndex           = 3,
            Parent           = TopBar
        }, {
            UICorner(4),
            UIStroke(accentColor, 1, 0.55),
        })

        local validIcon = type(iconId) == "string" and iconId ~= ""
            and tonumber(iconId:match("%d+")) ~= nil

        if validIcon then
            New("ImageLabel", {
                Size                 = UDim2.new(1, -4, 1, -4),
                Position             = UDim2.new(0, 2, 0, 2),
                BackgroundTransparency = 1,
                Image                = "rbxassetid://" .. iconId:match("%d+"),
                ImageColor3          = accentColor,
                ScaleType            = Enum.ScaleType.Fit,
                ZIndex               = 4,
                Parent               = btn
            })
        else
            New("TextLabel", {
                Size                 = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                 = fallbackText,
                TextColor3           = accentColor,
                TextTransparency     = 0.1,
                Font                 = Enum.Font.GothamBold,
                TextSize             = 9,
                ZIndex               = 4,
                Parent               = btn
            })
        end

        local interact = New("TextButton", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = "",
            ZIndex               = 5,
            Parent               = btn
        })

        interact.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = accentColor:Lerp(Theme.BG, 0.72) }, "fast")
            local stroke = btn:FindFirstChildWhichIsA("UIStroke")
            if stroke then Tween(stroke, { Transparency = 0 }, "fast") end
        end)
        interact.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.BG3 }, "fast")
            local stroke = btn:FindFirstChildWhichIsA("UIStroke")
            if stroke then Tween(stroke, { Transparency = 0.55 }, "fast") end
        end)

        return btn, interact
    end

    local _closeBtnFrame, closeBtn = MakeCtrlBtn(Color3.fromRGB(190, 60, 90),  nil, "✕")
    local _minBtnFrame,   minBtn   = MakeCtrlBtn(Color3.fromRGB(120, 90, 220), nil, "─")

    
    local NavWidth = 140
    local NavPanel = New("Frame", {
        Name = "NavPanel",
        Size = UDim2.new(0, NavWidth, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.NavBG,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = Window
    }, { UICorner(10) })

    New("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = Theme.NavBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = NavPanel
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.NavBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = NavPanel
    })

    New("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 1, 1, -24),
        Position = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = NavPanel
    })

    local PlayerStrip = New("Frame", {
        Name = "PlayerStrip",
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 1, -44),
        BackgroundColor3 = Theme.BG3,
        ZIndex = 3,
        Parent = NavPanel
    }, { UICorner(10) })

    local pAvatar = New("ImageLabel", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(0, 8, 0.5, -13),
        BackgroundTransparency = 1,
        Image = "",
        ZIndex = 4,
        Parent = PlayerStrip
    }, { UICorner(5) })

    New("TextLabel", {
        Size = UDim2.new(1, -44, 0, 14),
        Position = UDim2.new(0, 40, 0, 8),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = PlayerStrip
    })

    New("TextLabel", {
        Size = UDim2.new(1, -44, 0, 12),
        Position = UDim2.new(0, 40, 0, 24),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = PlayerStrip
    })

    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok then pAvatar.Image = img end
    end)

    local TabButtonList = New("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 3,
        Parent = NavPanel
    }, {
        UIListLayout(2),
        UIPadding(8, 0, 0, 0)
    })

    
    local ContentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -NavWidth, 1, -42),
        Position = UDim2.new(0, NavWidth, 0, 42),
        BackgroundColor3 = Theme.Surface,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = Window
    }, { UICorner(10) })

    New("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = ContentArea
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = ContentArea
    })

    local Pages = New("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = ContentArea
    })

    
    MakeDraggable(TopBar, Window)

    
    local WindowObj = {
        _root       = screenGui,
        _window     = Window,
        _pages      = Pages,
        _tablist    = TabButtonList,
        _currentTab = nil,
        _tabs       = {},
        Visible     = true
    }

    
    closeBtn.MouseButton1Click:Connect(function()
        
        for _, name in ipairs({"DarkLibV6_DDPopup", "DarkLibV6_CPPopup"}) do
            local g = CoreGui:FindFirstChild(name)
            if not g and gethui then g = gethui():FindFirstChild(name) end
            if g then g:Destroy() end
        end
        
        Tween(Window, { BackgroundTransparency = 1 }, "med")
        for _, c in ipairs(Window:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                Tween(c, { TextTransparency = 1, BackgroundTransparency = 1 }, "med")
            elseif c:IsA("Frame") or c:IsA("ScrollingFrame") then
                Tween(c, { BackgroundTransparency = 1 }, "med")
            elseif c:IsA("ImageLabel") or c:IsA("ImageButton") then
                Tween(c, { ImageTransparency = 1, BackgroundTransparency = 1 }, "med")
            elseif c:IsA("UIStroke") then
                Tween(c, { Transparency = 1 }, "med")
            end
        end
        task.delay(0.38, function() screenGui:Destroy() end)
    end)

    local _minimized = false
    local _lastSize

    local function _setMinIcon(isMinimized)
        local mcfg = WindowObj._minCfg
        if not mcfg then return end
        local iconChild = _minBtnFrame:FindFirstChildWhichIsA("ImageLabel")
        local textChild = _minBtnFrame:FindFirstChildWhichIsA("TextLabel")
        if iconChild then
            local id = isMinimized and mcfg._onIconId or mcfg._offIconId
            if id then iconChild.Image = "rbxassetid://" .. id end
        elseif textChild then
            textChild.Text = isMinimized and (mcfg._onFallback or "+") or (mcfg._offFallback or "─")
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        if _minimized then
            _minimized = false
            Tween(Window, { Size = _lastSize }, "slow")
            ContentArea.Visible = true
            NavPanel.Visible = true
        else
            _minimized = true
            _lastSize = Window.Size
            Tween(Window, { Size = UDim2.new(0, winW, 0, 42) }, "slow")
            ContentArea.Visible = false
            NavPanel.Visible = false
        end
        _setMinIcon(_minimized)
    end)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == cfg.HideBind then
            WindowObj.Visible = not WindowObj.Visible
            Window.Visible = WindowObj.Visible
        end
    end)

    
    if cfg.LoadingScreen then
        local Loader = New("Frame", {
            Name = "Loader",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.BG,
            ZIndex = 100,
            Parent = Window
        }, { UICorner(10) })

        local spinnerBg = New("Frame", {
            Size = UDim2.fromOffset(46, 46),
            Position = UDim2.new(0.5, -23, 0.5, -36),
            BackgroundColor3 = Theme.BG3,
            ZIndex = 101,
            Parent = Loader
        }, { UICorner(23) })

        local spinnerArc = New("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://4965945816",
            ImageColor3 = Theme.Accent,
            ZIndex = 102,
            Parent = spinnerBg
        })

        New("TextLabel", {
            Size = UDim2.new(0, 260, 0, 22),
            Position = UDim2.new(0.5, -130, 0.5, 20),
            BackgroundTransparency = 1,
            Text = cfg.LoadingTitle,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            ZIndex = 101,
            Parent = Loader
        })

        New("TextLabel", {
            Size = UDim2.new(0, 260, 0, 18),
            Position = UDim2.new(0.5, -130, 0.5, 44),
            BackgroundTransparency = 1,
            Text = cfg.Subtitle,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ZIndex = 101,
            Parent = Loader
        })

        RS:BindToRenderStep("DarkLib_Spin", 200, function(dt)
            spinnerArc.Rotation = (spinnerArc.Rotation + 200 * dt) % 360
        end)

        task.delay(1.8, function()
            RS:UnbindFromRenderStep("DarkLib_Spin")
            Tween(Loader, { BackgroundTransparency = 1 }, "slow")
            for _, c in ipairs(Loader:GetDescendants()) do
                if c:IsA("TextLabel") then
                    Tween(c, { TextTransparency = 1 })
                elseif c:IsA("ImageLabel") then
                    Tween(c, { ImageTransparency = 1 })
                elseif c:IsA("Frame") then
                    Tween(c, { BackgroundTransparency = 1 })
                end
            end
            task.delay(0.55, function()
                Loader:Destroy()
            end)
        end)
    end

    function WindowObj:CreateTab(tabCfg)
        tabCfg = Merge({
            Name = "Tab",
            Icon = nil,
        }, tabCfg)

        local isFirst = #WindowObj._tabs == 0

        local NavBtn = New("Frame", {
            Name = tabCfg.Name .. "_NavBtn",
            Size = UDim2.new(1, -8, 0, 30),
            BackgroundColor3 = Theme.TabInactive,
            BackgroundTransparency = 1,
            ZIndex = 4,
            LayoutOrder = #WindowObj._tabs,
            Parent = TabButtonList
        }, {
            UICorner(6),
            UIPadding(0, 0, 8, 8),
        })

        local activeBar = New("Frame", {
            Name = "ActiveBar",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            ZIndex = 5,
            Parent = NavBtn
        }, { UICorner(2) })

        local btnLabel = New("TextLabel", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = tabCfg.Name,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = NavBtn
        })

        local btnInteract = New("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 6,
            Parent = NavBtn
        })

        local Page = New("ScrollingFrame", {
            Name = tabCfg.Name .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 3,
            Parent = Pages
        }, {
            UIListLayout(5),
            UIPadding(10, 10, 10, 14)
        })

        local function Activate(animate)
            if WindowObj._currentTab == tabCfg.Name then return end

            for _, t in ipairs(WindowObj._tabs) do
                t._page.Visible = false
                Tween(t._navbtn, { BackgroundTransparency = 1 })
                Tween(t._bar, { BackgroundTransparency = 1 })
                Tween(t._label, { TextColor3 = Theme.TextMuted })
            end

            WindowObj._currentTab = tabCfg.Name
            Page.Visible = true
            Tween(NavBtn, { BackgroundTransparency = 0.8 })
            Tween(activeBar, { BackgroundTransparency = 0 })
            Tween(btnLabel, { TextColor3 = Theme.Text })
        end

        btnInteract.MouseButton1Click:Connect(function() Activate(true) end)

        NavBtn.MouseEnter:Connect(function()
            if WindowObj._currentTab ~= tabCfg.Name then
                Tween(NavBtn, { BackgroundTransparency = 0.93 })
                Tween(btnLabel, { TextColor3 = Theme.TextDim })
            end
        end)
        NavBtn.MouseLeave:Connect(function()
            if WindowObj._currentTab ~= tabCfg.Name then
                Tween(NavBtn, { BackgroundTransparency = 1 })
                Tween(btnLabel, { TextColor3 = Theme.TextMuted })
            end
        end)

        local TabObj = {
            _page   = Page,
            _navbtn = NavBtn,
            _bar    = activeBar,
            _label  = btnLabel,
            Name    = tabCfg.Name,
        }

        table.insert(WindowObj._tabs, TabObj)

        if isFirst then
            task.defer(function() Activate(false) end)
        end

        local function AutoCanvas()
            local layout = Page:FindFirstChildWhichIsA("UIListLayout")
            if layout then
                Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end
        end

        local function SpawnFadeIn(frame)
            frame.BackgroundTransparency = 1
            for _, c in ipairs(frame:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextBox") or c:IsA("TextButton") then
                    c.TextTransparency = 1
                elseif c:IsA("ImageLabel") then
                    c.ImageTransparency = 1
                elseif c:IsA("UIStroke") then
                    c.Transparency = 1
                end
            end
            Tween(frame, { BackgroundTransparency = frame:GetAttribute("TargetBT") or 0.55 }, "slow")
            for _, c in ipairs(frame:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextBox") then
                    Tween(c, { TextTransparency = c:GetAttribute("TargetTT") or 0 }, "slow")
                elseif c:IsA("ImageLabel") then
                    Tween(c, { ImageTransparency = c:GetAttribute("TargetIT") or 0 }, "slow")
                elseif c:IsA("UIStroke") then
                    Tween(c, { Transparency = c:GetAttribute("TargetST") or 0.55 }, "slow")
                end
            end
        end

        local function ErrorFlash(frame, origName, origColor, label)
            Tween(frame, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Red })
            if frame:FindFirstChildWhichIsA("UIStroke") then
                Tween(frame:FindFirstChildWhichIsA("UIStroke"), { Transparency = 1 })
            end
            if label then label.Text = "Callback Error" end
            task.wait(0.5)
            Tween(frame, { BackgroundTransparency = 0.55, BackgroundColor3 = origColor })
            if frame:FindFirstChildWhichIsA("UIStroke") then
                Tween(frame:FindFirstChildWhichIsA("UIStroke"), { Transparency = 0.55 })
            end
            if label then label.Text = origName end
        end

        local function BaseRow(h)
            local f = New("Frame", {
                Size = UDim2.new(1, 0, 0, h or 36),
                BackgroundColor3 = Theme.BG3,
                ZIndex = 4,
                Parent = Page
            }, {
                UICorner(7),
                UIStroke(Theme.Border, 1, 0.55),
            })
            f:SetAttribute("TargetBT", 0.55)
            return f
        end

        
    local function MakeLockable(compObj, row)
    local _locked = false
    local _lockIcon = nil
    local _LOCKED_ID   = "10723434711"
    local _UNLOCKED_ID = "10747366027"

    local _lockOverlay = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.BG,
        BackgroundTransparency = 1,
        ZIndex = 200,
        Visible = false,
        Parent = row
    }, { UICorner(7) })

    New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 201,
        Parent = _lockOverlay
    })

    function compObj:ToggleLock(locked)
        _locked = locked

        if locked then
            if _lockIcon then _lockIcon:Destroy(); _lockIcon = nil end

            _lockIcon = New("ImageLabel", {
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(0.5, -12, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. _LOCKED_ID,
                ImageColor3 = Theme.AccentGlow,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 202,
                Parent = _lockOverlay
            })

            _lockOverlay.Visible = true
            Tween(_lockOverlay, { BackgroundTransparency = 0.25 })

        else
            _locked = false

            if _lockIcon then
                local t1 = TS:Create(_lockIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -12, 0.5, -12),
                    Size = UDim2.fromOffset(24, 24),
                })
                t1:Play()
                t1.Completed:Wait()

                local t2 = TS:Create(_lockIcon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                    ImageTransparency = 1
                })
                t2:Play()
                t2.Completed:Wait()

                _lockIcon.Image = "rbxassetid://" .. _UNLOCKED_ID

                local t3 = TS:Create(_lockIcon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                    ImageTransparency = 0
                })
                t3:Play()
                t3.Completed:Wait()

                TS:Create(_lockIcon, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -12, 0.5, 24),
                    ImageTransparency = 1,
                }):Play()
                Tween(_lockOverlay, { BackgroundTransparency = 1 }, "slow")

                task.delay(0.65, function()
                    _lockOverlay.Visible = false
                    if _lockIcon then _lockIcon:Destroy(); _lockIcon = nil end
                end)
            else
                Tween(_lockOverlay, { BackgroundTransparency = 1 }, "slow")
                task.delay(0.6, function()
                    _lockOverlay.Visible = false
                end)
            end
        end
    end

    function compObj:IsLocked()
        return _locked
    end
end

        
        function TabObj:CreateButton(btnCfg, flag)
            btnCfg = Merge({
                Name = "Button",
                Description = nil,
                Callback = function() end,
            }, btnCfg)

            local h = (btnCfg.Description ~= nil and btnCfg.Description ~= "") and 52 or 36
            local row = BaseRow(h)

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Text = btnCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            if btnCfg.Description ~= nil and btnCfg.Description ~= "" then
                nameLabel.Position = UDim2.new(0, 12, 0.28, -9)
                New("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 14),
                    Position = UDim2.new(0, 12, 0, 30),
                    BackgroundTransparency = 1,
                    Text = btnCfg.Description,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row
                })
            end

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 6,
                Parent = row
            })

            interact.MouseButton1Click:Connect(function()
                local ok, err = SafeCall(btnCfg.Callback)
                if not ok then
                    ErrorFlash(row, btnCfg.Name, Theme.BG3, nameLabel)
                    warn("[DarkLibV6] Button '" .. btnCfg.Name .. "' error: " .. tostring(err))
                end
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local BtnObj = { Settings = btnCfg }
            function BtnObj:Set(newCfg)
                newCfg = Merge(btnCfg, newCfg)
                btnCfg = newCfg
                nameLabel.Text = btnCfg.Name
            end
            function BtnObj:Destroy()
                row:Destroy(); AutoCanvas()
            end
            MakeLockable(BtnObj, row)

            if flag then DarkLib.Options[flag] = BtnObj end

            return BtnObj
        end

        
        function TabObj:CreateToggle(togCfg, flag)
            togCfg = Merge({
                Name = "Toggle",
                Description = nil,
                CurrentValue = false,
                Callback = function() end,
            }, togCfg)

            local h = (togCfg.Description ~= nil and togCfg.Description ~= "") and 52 or 36
            local row = BaseRow(h)

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Text = togCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            if togCfg.Description ~= nil and togCfg.Description ~= "" then
                nameLabel.Position = UDim2.new(0, 12, 0.28, -9)
                New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14),
                    Position = UDim2.new(0, 12, 0, 30),
                    BackgroundTransparency = 1,
                    Text = togCfg.Description,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row
                })
            end

            local track = New("Frame", {
                Name = "Track",
                Size = UDim2.fromOffset(34, 18),
                Position = UDim2.new(1, -46, 0.5, -9),
                BackgroundColor3 = Theme.BG,
                ZIndex = 5,
                Parent = row
            }, {
                UICorner(9),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local knob = New("Frame", {
                Name = "Knob",
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(0, 3, 0.5, -6),
                BackgroundColor3 = Theme.TextMuted,
                ZIndex = 6,
                Parent = track
            }, { UICorner(6) })

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 7,
                Parent = row
            })

            local state = togCfg.CurrentValue

            local function SetToggle(val, silent)
                state = val
                if state then
                    Tween(track, { BackgroundColor3 = Theme.AccentDim })
                    Tween(track:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Accent, Transparency = 0 })
                    Tween(knob, { Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Theme.AccentGlow })
                else
                    Tween(track, { BackgroundColor3 = Theme.BG })
                    Tween(track:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border, Transparency = 0.3 })
                    Tween(knob, { Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Theme.TextMuted })
                end
                if not silent then
                    local ok, err = SafeCall(togCfg.Callback, state)
                    if not ok then
                        ErrorFlash(row, togCfg.Name, Theme.BG3, nameLabel)
                        warn("[DarkLibV6] Toggle '" .. togCfg.Name .. "' error: " .. tostring(err))
                    end
                end
            end

            SetToggle(state, true)

            interact.MouseButton1Click:Connect(function()
                SetToggle(not state)
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local TogObj = { CurrentValue = state, Settings = togCfg }
            function TogObj:Set(newCfg)
                newCfg = Merge(togCfg, newCfg)
                togCfg = newCfg
                nameLabel.Text = togCfg.Name
                SetToggle(togCfg.CurrentValue, true)
                TogObj.CurrentValue = state
            end
            function TogObj:UpdateState(v)
                SetToggle(v, true)
                TogObj.CurrentValue = state
            end
            function TogObj:Destroy()
                row:Destroy(); AutoCanvas()
            end
            MakeLockable(TogObj, row)

            if flag then DarkLib.Options[flag] = TogObj end

            return TogObj
        end

        
        function TabObj:CreateSlider(slCfg, flag)
            slCfg = Merge({
                Name = "Slider",
                Range = {0, 100},
                Increment = 1,
                CurrentValue = 50,
                Suffix = "",
                Callback = function() end,
            }, slCfg)

            local row = BaseRow(54)
            row.Size = UDim2.new(1, 0, 0, 54)

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -80, 0, 16),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = slCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            local valLabel = New("TextLabel", {
                Size = UDim2.new(0, 70, 0, 16),
                Position = UDim2.new(1, -80, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(slCfg.CurrentValue) .. slCfg.Suffix,
                TextColor3 = Theme.AccentGlow,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
                Parent = row
            })

            local track = New("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, 36),
                BackgroundColor3 = Theme.BG,
                ZIndex = 5,
                Parent = row
            }, {
                UICorner(2),
                UIStroke(Theme.Border, 1, 0.6),
            })

            local fill = New("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 6,
                Parent = track
            }, { UICorner(2) })

            local knob = New("Frame", {
                Name = "Knob",
                Size = UDim2.fromOffset(12, 12),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Theme.AccentGlow,
                ZIndex = 7,
                Parent = track
            }, { UICorner(6) })

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 8,
                Parent = row
            })

            local curVal = slCfg.CurrentValue
            local dragging = false

            local function SetSlider(raw, silent)
                local clamped = math.clamp(raw, slCfg.Range[1], slCfg.Range[2])
                curVal = Round(clamped, slCfg.Increment)
                local pct = (curVal - slCfg.Range[1]) / (slCfg.Range[2] - slCfg.Range[1])
                Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, "fast")
                Tween(knob, { Position = UDim2.new(pct, 0, 0.5, 0) }, "fast")
                valLabel.Text = tostring(curVal) .. slCfg.Suffix
                if not silent then
                    local ok, err = SafeCall(slCfg.Callback, curVal)
                    if not ok then
                        ErrorFlash(row, slCfg.Name, Theme.BG3, nameLabel)
                        warn("[DarkLibV6] Slider '" .. slCfg.Name .. "' error: " .. tostring(err))
                    end
                end
            end

            SetSlider(curVal, true)

            local function PosToVal(mouseX)
                local abs = track.AbsolutePosition.X
                local sz  = track.AbsoluteSize.X
                local pct = math.clamp((mouseX - abs) / sz, 0, 1)
                return slCfg.Range[1] + pct * (slCfg.Range[2] - slCfg.Range[1])
            end

            interact.MouseButton1Down:Connect(function()
                dragging = true
                local loop; loop = RS.Stepped:Connect(function()
                    if dragging then
                        SetSlider(PosToVal(UIS:GetMouseLocation().X))
                    else
                        loop:Disconnect()
                    end
                end)
            end)

            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                   inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local SlObj = { CurrentValue = curVal, Settings = slCfg }
            function SlObj:Set(newCfg)
                newCfg = Merge(slCfg, newCfg)
                slCfg = newCfg
                nameLabel.Text = slCfg.Name
                SetSlider(slCfg.CurrentValue, true)
                SlObj.CurrentValue = curVal
            end
            function SlObj:UpdateValue(v)
                SetSlider(v, true)
                SlObj.CurrentValue = curVal
            end
            function SlObj:Destroy()
                row:Destroy(); AutoCanvas()
            end
            MakeLockable(SlObj, row)

            if flag then DarkLib.Options[flag] = SlObj end

            return SlObj
        end

        
        function TabObj:CreateInput(inCfg, flag)
            inCfg = Merge({
                Name = "Input",
                Description = nil,
                PlaceholderText = "Type here...",
                CurrentValue = "",
                Numeric = false,
                MaxCharacters = nil,
                Enter = false,
                ClearOnFocusLost = false,
                Callback = function() end,
            }, inCfg)

            local h = (inCfg.Description ~= nil and inCfg.Description ~= "") and 62 or 48
            local row = BaseRow(h)

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -20, 0, 16),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = inCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            if inCfg.Description ~= nil and inCfg.Description ~= "" then
                New("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 12),
                    Position = UDim2.new(0, 12, 0, 24),
                    BackgroundTransparency = 1,
                    Text = inCfg.Description,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 5,
                    Parent = row
                })
            end

            local inputBg = New("Frame", {
                Size = UDim2.new(1, -24, 0, 22),
                Position = UDim2.new(0, 12, 1, -28),
                BackgroundColor3 = Theme.BG,
                ZIndex = 5,
                Parent = row
            }, {
                UICorner(5),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local box = New("TextBox", {
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = inCfg.CurrentValue,
                PlaceholderText = inCfg.PlaceholderText,
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 6,
                Parent = inputBg
            })

            box.Focused:Connect(function()
                Tween(inputBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Accent, Transparency = 0 })
            end)

            box.FocusLost:Connect(function(enter)
                Tween(inputBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border, Transparency = 0.3 })
                if inCfg.Enter and not enter then
                    if inCfg.ClearOnFocusLost then box.Text = "" end
                    return
                end
                local ok, err = SafeCall(inCfg.Callback, box.Text)
                if not ok then
                    warn("[DarkLibV6] Input '" .. inCfg.Name .. "' error: " .. tostring(err))
                end
                if inCfg.ClearOnFocusLost then box.Text = "" end
            end)

            if inCfg.Numeric then
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    local t = box.Text
                    if not tonumber(t) and t ~= "." and t ~= "-" then
                        box.Text = t:match("[%-0-9%.]*") or ""
                    end
                end)
            end

            if inCfg.MaxCharacters then
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if #box.Text > inCfg.MaxCharacters then
                        box.Text = box.Text:sub(1, inCfg.MaxCharacters)
                    end
                end)
            end

            row.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            row.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local InObj = { CurrentValue = box.Text, Settings = inCfg }
            function InObj:Set(newCfg)
                newCfg = Merge(inCfg, newCfg)
                inCfg = newCfg
                nameLabel.Text = inCfg.Name
                box.Text = tostring(inCfg.CurrentValue)
                InObj.CurrentValue = box.Text
            end
            function InObj:Destroy()
                row:Destroy(); AutoCanvas()
            end
            MakeLockable(InObj, row)

            if flag then DarkLib.Options[flag] = InObj end

            return InObj
        end

        

        function TabObj:CreateDropdown(ddCfg, flag)
            ddCfg = Merge({
                Name = "Dropdown",
                Description = nil,
                Options = {"Option 1", "Option 2"},
                CurrentOption = nil,
                MultipleOptions = false,
                Callback = function() end,
            }, ddCfg)

            if type(ddCfg.CurrentOption) == "string" then
                ddCfg.CurrentOption = {ddCfg.CurrentOption}
            elseif ddCfg.CurrentOption == nil then
                ddCfg.CurrentOption = {}
            end

            local selected = {}
            for _, v in ipairs(ddCfg.CurrentOption) do
                table.insert(selected, tostring(v))
            end

            local row = BaseRow(36)
            local _ddLocked = false

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = ddCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            local preview = New("TextLabel", {
                Size = UDim2.new(0.4, -30, 1, 0),
                Position = UDim2.new(0.55, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = #selected > 0 and table.concat(selected, ", ") or "None",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
                Parent = row
            })

            local arrow = New("ImageLabel", {
            Size = UDim2.fromOffset(18, 36),
           Position = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://10709790948",
           ImageColor3 = Theme.TextMuted,
            ScaleType = Enum.ScaleType.Fit,
               ZIndex = 5,
                Parent = row
           })

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 6,
                Parent = row
            })

            local ddGui = MakeOverlayGui("DarkLibV6_DDPopup_" .. ddCfg.Name, 9500)

            local popupFrame = New("Frame", {
                Name = "DDPopup",
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.BG2,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 1,
                Parent = ddGui
            }, {
                UICorner(7),
                UIStroke(Theme.Border, 1, 0.25),
            })

            local popupScroll = New("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                Parent = popupFrame
            }, {
                UIListLayout(2),
                UIPadding(4, 4, 4, 4),
            })

            local open = false

            local function ClosePopup()
                open = false
                Tween(popupFrame, { Size = UDim2.new(popupFrame.Size.X.Scale, popupFrame.Size.X.Offset, 0, 0) }, "fast")
                Tween(arrow, { Rotation = 0 })
                task.delay(0.25, function()
                    if not open then
                        popupFrame.Visible = false
                    end
                end)
            end

            local function RebuildPopup()

                for _, c in ipairs(popupScroll:GetChildren()) do
                    if c:IsA("Frame") then c:Destroy() end
                end

                local optList = ddCfg.Options
                if ddCfg.SpecialType == "Player" then
                    optList = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        table.insert(optList, p.Name)
                    end
                end

                for _, opt in ipairs(optList) do
                    local isSelected = TableContains(selected, opt)

                    local optRow = New("Frame", {
                        Name = tostring(opt),
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = isSelected and Theme.TabActive or Color3.fromRGB(0,0,0),
                        BackgroundTransparency = isSelected and 0.0 or 1,
                        ZIndex = 3,
                        Parent = popupScroll
                    }, { UICorner(5) })

                    local selBar = New("Frame", {
                        Name = "SelBar",
                        Size = UDim2.new(0, 3, 0.6, 0),
                        Position = UDim2.new(0, 0, 0.2, 0),
                        BackgroundColor3 = Theme.Accent,
                        BackgroundTransparency = isSelected and 0 or 1,
                        ZIndex = 4,
                        Parent = optRow
                    }, { UICorner(2) })

                    local optLabel = New("TextLabel", {
                        Size = UDim2.new(1, -18, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(opt),
                        TextColor3 = isSelected and Theme.Text or Theme.TextDim,
                        Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 4,
                        Parent = optRow
                    })

                    local optInteract = New("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 5,
                        Parent = optRow
                    })

                    optInteract.MouseEnter:Connect(function()
                        if not TableContains(selected, opt) then
                            Tween(optRow, { BackgroundTransparency = 0.85 })
                            Tween(optLabel, { TextColor3 = Theme.TextDim:Lerp(Theme.Text, 0.5) })
                        end
                    end)
                    optInteract.MouseLeave:Connect(function()
                        if not TableContains(selected, opt) then
                            Tween(optRow, { BackgroundTransparency = 1 })
                            Tween(optLabel, { TextColor3 = Theme.TextDim })
                        end
                    end)

                    optInteract.MouseButton1Click:Connect(function()

                        if _ddLocked then return end

                        if ddCfg.MultipleOptions then
                            if TableContains(selected, opt) then
                                TableRemoveValue(selected, opt)
                            else
                                table.insert(selected, opt)
                            end
                        else
                            selected = {opt}
                            ClosePopup()
                        end

                        preview.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                        RebuildPopup()
                        SafeCall(ddCfg.Callback, ddCfg.MultipleOptions and selected or selected[1])
                    end)
                end
            end

            local function PositionAndOpenPopup()
                local rowAbs = row.AbsolutePosition
                local rowSz  = row.AbsoluteSize
                local vp     = workspace.CurrentCamera.ViewportSize

                local optCount = #ddCfg.Options
                if ddCfg.SpecialType == "Player" then
                    optCount = #Players:GetPlayers()
                end
                local contentH = math.min(optCount * 32 + 8, 200)
                local popW = math.max(rowSz.X, 160)

                
                local spaceBelow = vp.Y - (rowAbs.Y + rowSz.Y)
                local openUp = spaceBelow < contentH + 10

                popupFrame.Size = UDim2.fromOffset(popW, 0)
                if openUp then
                    popupFrame.Position = UDim2.fromOffset(rowAbs.X, rowAbs.Y - contentH - 4)
                else
                    popupFrame.Position = UDim2.fromOffset(rowAbs.X, rowAbs.Y + rowSz.Y + 4)
                end

                popupFrame.Visible = true
                RebuildPopup()
                Tween(popupFrame, { Size = UDim2.fromOffset(popW, contentH) })
                Tween(arrow, { Rotation = 180 })
            end

            interact.MouseButton1Click:Connect(function()
                if _ddLocked then return end
                open = not open
                if open then
                    PositionAndOpenPopup()
                else
                    ClosePopup()
                end
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if open and (
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch
                ) then

                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local mpos = UIS:GetMouseLocation() - inset
                    local ppos = popupFrame.AbsolutePosition
                    local psz  = popupFrame.AbsoluteSize
                    local rpos = row.AbsolutePosition
                    local rsz  = row.AbsoluteSize

                    local inPopup = mpos.X >= ppos.X and mpos.X <= ppos.X + psz.X
                        and mpos.Y >= ppos.Y and mpos.Y <= ppos.Y + psz.Y
                    local inRow = mpos.X >= rpos.X and mpos.X <= rpos.X + rsz.X
                        and mpos.Y >= rpos.Y and mpos.Y <= rpos.Y + rsz.Y

                    if not inPopup and not inRow then
                        ClosePopup()
                    end
                end
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local DDObj = { CurrentOption = selected, Settings = ddCfg }

            function DDObj:Set(newCfg)
                newCfg = Merge(ddCfg, newCfg)
                ddCfg = newCfg
                nameLabel.Text = ddCfg.Name
                if type(ddCfg.CurrentOption) == "table" then
                    selected = ddCfg.CurrentOption
                else
                    selected = {ddCfg.CurrentOption}
                end
                preview.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                DDObj.CurrentOption = selected
            end

            function DDObj:Destroy()
                if open then ClosePopup() end
                task.delay(0.3, function() ddGui:Destroy() end)
                row:Destroy()
                AutoCanvas()
            end

            function DDObj:Refresh()
                if open then RebuildPopup() end
            end

            local _lockOverlay2 = New("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.BG,
                BackgroundTransparency = 1,
                ZIndex = 50,
                Visible = false,
                Parent = row
            }, { UICorner(7) })

            New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 51,
                Parent = _lockOverlay2
            })

            function DDObj:ToggleLock(locked)
                _ddLocked = locked
                if locked then
                    if open then ClosePopup() end
                    local existing = _lockOverlay2:FindFirstChildOfClass("ImageLabel")
                    if existing then existing:Destroy() end
                    local _lockIcon2 = New("ImageLabel", {
                        Size = UDim2.fromOffset(20, 20),
                        Position = UDim2.new(0.5, -12, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://10723434711",
                        ImageColor3 = Theme.AccentGlow,
                        ScaleType = Enum.ScaleType.Fit,
                        ZIndex = 52,
                        Parent = _lockOverlay2
                    })
                    _lockOverlay2.Visible = true
                    Tween(_lockOverlay2, { BackgroundTransparency = 0.25 })
                else
                    local _lockIcon2 = _lockOverlay2:FindFirstChildOfClass("ImageLabel")
                    if _lockIcon2 then
                        task.spawn(function()
                            local t1 = TS:Create(_lockIcon2, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                                Position = UDim2.new(0.5, -12, 0.5, -12),
                                Size = UDim2.fromOffset(24, 24),
                            })
                            t1:Play()
                            t1.Completed:Wait()

                            local t2 = TS:Create(_lockIcon2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                                ImageTransparency = 1
                            })
                            t2:Play()
                            t2.Completed:Wait()

                            _lockIcon2.Image = "rbxassetid://10747366027"

                            local t3 = TS:Create(_lockIcon2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                                ImageTransparency = 0
                            })
                            t3:Play()
                            t3.Completed:Wait()

                            TS:Create(_lockIcon2, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                                Position = UDim2.new(0.5, -12, 0.5, 24),
                                ImageTransparency = 1,
                            }):Play()
                            Tween(_lockOverlay2, { BackgroundTransparency = 1 }, "slow")

                            task.delay(0.65, function()
                                _lockOverlay2.Visible = false
                                if _lockIcon2 then _lockIcon2:Destroy() end
                            end)
                        end)
                    else
                        Tween(_lockOverlay2, { BackgroundTransparency = 1 }, "slow")
                        task.delay(0.6, function()
                            _lockOverlay2.Visible = false
                        end)
                    end
                end
            end

            function DDObj:IsLocked()
                return _ddLocked
            end

            if flag then DarkLib.Options[flag] = DDObj end

            return DDObj
        end

        
        function TabObj:CreateBind(bndCfg, flag)
            bndCfg = Merge({
                Name = "Keybind",
                Description = nil,
                CurrentBind = "None",
                HoldToInteract = false,
                Callback = function() end,
            }, bndCfg)

            local h = (bndCfg.Description ~= nil and bndCfg.Description ~= "") and 52 or 36
            local row = BaseRow(h)

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -80, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Text = bndCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            if bndCfg.Description ~= nil and bndCfg.Description ~= "" then
                nameLabel.Position = UDim2.new(0, 12, 0.28, -9)
                New("TextLabel", {
                    Size = UDim2.new(1, -80, 0, 14),
                    Position = UDim2.new(0, 12, 0, 30),
                    BackgroundTransparency = 1,
                    Text = bndCfg.Description,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row
                })
            end

            local bindBox = New("Frame", {
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -68, 0.5, -11),
                BackgroundColor3 = Theme.BG,
                ZIndex = 5,
                Parent = row
            }, {
                UICorner(5),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local bindLabel = New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = bndCfg.CurrentBind,
                TextColor3 = Theme.AccentGlow,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                ZIndex = 6,
                Parent = bindBox
            })

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 7,
                Parent = row
            })

            local listening = false
            local currentBind = bndCfg.CurrentBind
            local held = false

            interact.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                bindLabel.Text = "..."
                Tween(bindBox:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Accent })
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if listening then
                    local keyStr = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    if keyStr ~= "Unknown" and keyStr ~= "Return" then
                        currentBind = keyStr
                        bindLabel.Text = keyStr
                        bndCfg.CurrentBind = keyStr
                        listening = false
                        Tween(bindBox:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
                    end
                    return
                end

                if gpe then return end
                local keyStr = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                if keyStr == currentBind then
                    if bndCfg.HoldToInteract then
                        held = true
                        SafeCall(bndCfg.Callback, true)
                    else
                        SafeCall(bndCfg.Callback)
                    end
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if bndCfg.HoldToInteract and held then
                    local keyStr = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    if keyStr == currentBind then
                        held = false
                        SafeCall(bndCfg.Callback, false)
                    end
                end
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local BndObj = { Settings = bndCfg, CurrentBind = currentBind }
            function BndObj:Set(newCfg)
                newCfg = Merge(bndCfg, newCfg)
                bndCfg = newCfg
                currentBind = bndCfg.CurrentBind
                nameLabel.Text = bndCfg.Name
                bindLabel.Text = currentBind
                BndObj.CurrentBind = currentBind
            end
            function BndObj:Destroy()
                row:Destroy(); AutoCanvas()
            end
            MakeLockable(BndObj, row)

            if flag then DarkLib.Options[flag] = BndObj end

            return BndObj
        end

        TabObj.CreateKeybind = TabObj.CreateBind

        
        function TabObj:CreateLabel(lbCfg)
            lbCfg = Merge({
                Text = "Label",
                Style = 1,
            }, lbCfg)

            local colors = {
                [1] = { bg = Theme.BG3, text = Theme.TextDim },
                [2] = { bg = Color3.fromRGB(25, 50, 80), text = Color3.fromRGB(110, 180, 255) },
                [3] = { bg = Color3.fromRGB(60, 48, 20), text = Theme.Yellow },
            }
            local col = colors[lbCfg.Style] or colors[1]

            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = col.bg,
                BackgroundTransparency = lbCfg.Style == 1 and 1 or 0.65,
                ZIndex = 4,
                Parent = Page
            }, {
                UICorner(6),
                UIStroke(Theme.Border, 1, lbCfg.Style == 1 and 0.7 or 0.5),
            })

            local lbl = New("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = lbCfg.Text,
                TextColor3 = col.text,
                Font = lbCfg.Style == 1 and Enum.Font.Gotham or Enum.Font.GothamSemibold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            SpawnFadeIn(row)
            AutoCanvas()

            local LbObj = { Settings = lbCfg }
            function LbObj:Set(text)
                lbCfg.Text = text
                lbl.Text = text
            end
            function LbObj:Destroy()
                row:Destroy(); AutoCanvas()
            end

            return LbObj
        end

        
        function TabObj:CreateParagraph(pgCfg)
            pgCfg = Merge({
                Title = "Paragraph",
                Text = ""
            }, pgCfg)

            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.BG3,
                BackgroundTransparency = 0.55,
                ZIndex = 4,
                Parent = Page
            }, {
                UICorner(7),
                UIStroke(Theme.Border, 1, 0.55),
                UIPadding(8, 10, 12, 12),
            })

            local titleLbl = New("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = pgCfg.Title,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            local bodyLbl = New("TextLabel", {
                Name = "Body",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = pgCfg.Text,
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                RichText = true,
                ZIndex = 5,
                Parent = row
            })

            local function Resize()
                bodyLbl.Size = UDim2.new(1, 0, 0, math.huge)
                local bh = bodyLbl.TextBounds.Y
                bodyLbl.Size = UDim2.new(1, 0, 0, bh)
                Tween(row, { Size = UDim2.new(1, 0, 0, bh + 38) })
                task.defer(AutoCanvas)
            end

            task.defer(Resize)
            SpawnFadeIn(row)

            local PgObj = { Settings = pgCfg }
            function PgObj:Set(newCfg)
                newCfg = Merge(pgCfg, newCfg)
                pgCfg = newCfg
                titleLbl.Text = pgCfg.Title
                bodyLbl.Text = pgCfg.Text
                Resize()
            end
            function PgObj:Destroy()
                row:Destroy(); AutoCanvas()
            end

            return PgObj
        end

        

        function TabObj:CreateDivider(divCfg)
    divCfg = Merge({
        Text = nil,
        Thickness = 1,
    }, divCfg or {})

    local hasText = divCfg.Text ~= nil and divCfg.Text ~= ""
    local h = hasText and 20 or 10

    local divRow = New("Frame", {
        Size = UDim2.new(1, 0, 0, h),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Page
    })

    if hasText then
        local textLbl = New("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = divCfg.Text,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            ZIndex = 5,
            Parent = divRow
        })

        local lineLeft = New("Frame", {
            Size = UDim2.fromOffset(0, divCfg.Thickness),
            Position = UDim2.fromOffset(0, h / 2),
            BackgroundColor3 = Theme.Border,
            ZIndex = 4,
            Parent = divRow
        }, { UICorner(1) })

        local lineRight = New("Frame", {
            Size = UDim2.fromOffset(0, divCfg.Thickness),
            Position = UDim2.fromOffset(0, h / 2),
            BackgroundColor3 = Theme.Border,
            ZIndex = 4,
            Parent = divRow
        }, { UICorner(1) })

        local function Update()
            local tw = textLbl.TextBounds.X + 12
            local totalWidth = divRow.AbsoluteSize.X
            local halfSpace = (totalWidth - tw) / 2

            halfSpace = math.max(halfSpace, 0)

            lineLeft.Size = UDim2.fromOffset(halfSpace, divCfg.Thickness)
            lineLeft.Position = UDim2.fromOffset(0, h / 2)

            lineRight.Size = UDim2.fromOffset(halfSpace, divCfg.Thickness)
            lineRight.Position = UDim2.fromOffset(totalWidth - halfSpace, h / 2)
        end

        divRow:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update)
        textLbl:GetPropertyChangedSignal("TextBounds"):Connect(Update)

        Update()
    else
        New("Frame", {
            Size = UDim2.new(1, -24, 0, divCfg.Thickness),
            Position = UDim2.new(0, 12, 0.5, 0),
            BackgroundColor3 = Theme.Border,
            ZIndex = 4,
            Parent = divRow
        }, { UICorner(1) })
    end

    for _, c in ipairs(divRow:GetDescendants()) do
        if c:IsA("Frame") then
            c.BackgroundTransparency = 1
            Tween(c, { BackgroundTransparency = 0 }, "slow")
        elseif c:IsA("TextLabel") then
            c.TextTransparency = 1
            Tween(c, { TextTransparency = 0 }, "slow")
        end
    end

    AutoCanvas()

    local DivObj = {}
    function DivObj:Destroy()
        divRow:Destroy()
        AutoCanvas()
    end

    return DivObj
end

function TabObj:CreateColorPicker(cpCfg, flag)
            cpCfg = Merge({
                Name = "Color Picker",
                Color = Color3.fromRGB(120, 90, 220),
                Callback = function() end,
            }, cpCfg)

            local row = BaseRow(36)
            local _cpOpen = false

            local nameLabel = New("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = cpCfg.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = row
            })

            local swatch = New("Frame", {
                Size = UDim2.fromOffset(24, 24),
                Position = UDim2.new(1, -36, 0.5, -12),
                BackgroundColor3 = cpCfg.Color,
                ZIndex = 5,
                Parent = row
            }, {
                UICorner(5),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local interact = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 6,
                Parent = row
            })

            local cpGui = MakeOverlayGui("DarkLibV6_CPPopup_" .. cpCfg.Name, 9600)

            local cpWin = New("Frame", {
                Name = "CPWindow",
                Size = UDim2.fromOffset(230, 0),
                BackgroundColor3 = Theme.BG,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 1,
                Parent = cpGui
            }, {
                UICorner(8),
                UIStroke(Theme.Border, 1, 0.2),
                UIPadding(10, 10, 10, 10),
            })

            New("ImageLabel", {
                Name = "Shadow",
                Size = UDim2.new(1, 30, 1, 30),
                Position = UDim2.new(0, -15, 0, -15),
                BackgroundTransparency = 1,
                Image = "rbxassetid://5028857084",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 0.55,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(24, 24, 276, 276),
                ZIndex = 0,
                Parent = cpWin
            })

            local h, s, v = cpCfg.Color:ToHSV()
            local mouse = LocalPlayer:GetMouse()
            local draggingSV, draggingH = false, false

            local satValBg = New("Frame", {
                Size = UDim2.new(1, 0, 0, 110),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                ZIndex = 2,
                Parent = cpWin
            }, { UICorner(5) })

            local svImage = New("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://4155801252",
                ImageColor3 = Color3.new(1, 1, 1),
                ZIndex = 3,
                Parent = satValBg
            })

            local svKnob = New("Frame", {
                Size = UDim2.fromOffset(12, 12),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(s, 0, 1 - v, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 5,
                Parent = satValBg
            }, {
                UICorner(6),
                UIStroke(Color3.new(0,0,0), 1.5, 0)
            })

            local svInteract = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 6,
                Parent = satValBg
            })

            local hueSlider = New("Frame", {
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 0, 120),
                ZIndex = 2,
                Parent = cpWin
            }, {
                UICorner(4),
                New("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
                    })
                })
            })

            local hueKnob = New("Frame", {
                Size = UDim2.fromOffset(8, 14),
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(h, 0, 0, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 3,
                Parent = hueSlider
            }, {
                UICorner(3),
                UIStroke(Color3.new(0,0,0), 1, 0)
            })

            local hInteract = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 4,
                Parent = hueSlider
            })

            local bottomRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 144),
                BackgroundTransparency = 1,
                ZIndex = 2,
                Parent = cpWin
            })

            local colorPreview = New("Frame", {
                Size = UDim2.fromOffset(24, 24),
                BackgroundColor3 = cpCfg.Color,
                ZIndex = 3,
                Parent = bottomRow
            }, {
                UICorner(5),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local hexBg = New("Frame", {
                Size = UDim2.new(1, -32, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                BackgroundColor3 = Theme.BG2,
                ZIndex = 3,
                Parent = bottomRow
            }, {
                UICorner(5),
                UIStroke(Theme.Border, 1, 0.3),
            })

            local hexBox = New("TextBox", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = string.format("#%02X%02X%02X",
                    math.round(cpCfg.Color.R*255),
                    math.round(cpCfg.Color.G*255),
                    math.round(cpCfg.Color.B*255)
                ),
                PlaceholderText = "#RRGGBB",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Code,
                TextSize = 12,
                ClearTextOnFocus = false,
                ZIndex = 4,
                Parent = hexBg
            })

            local rgbRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 176),
                BackgroundTransparency = 1,
                ZIndex = 2,
                Parent = cpWin
            }, { UIListLayout(4, Enum.FillDirection.Horizontal) })

            local function MakeRGBBox(label)
                local bg = New("Frame", {
                    Size = UDim2.new(0.33, -3, 1, 0),
                    BackgroundColor3 = Theme.BG2,
                    ZIndex = 3,
                    Parent = rgbRow
                }, {
                    UICorner(5),
                    UIStroke(Theme.Border, 1, 0.3),
                })

                New("TextLabel", {
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.new(0, 2, 0.5, -7),
                    BackgroundTransparency = 1,
                    Text = label,
                    TextColor3 = Theme.TextMuted,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    ZIndex = 4,
                    Parent = bg
                })

                local box = New("TextBox", {
                    Size = UDim2.new(1, -14, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "0",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    ZIndex = 4,
                    Parent = bg
                })

                return bg, box
            end

            local _, rBox = MakeRGBBox("R")
            local _, gBox = MakeRGBBox("G")
            local _, bBox = MakeRGBBox("B")

            local CP_H = 10 + 110 + 10 + 14 + 10 + 24 + 8 + 22 + 10

            local function UpdateAll(silent)
                local col3 = Color3.fromHSV(h, s, v)
                local r = math.round(col3.R * 255)
                local g2 = math.round(col3.G * 255)
                local b2 = math.round(col3.B * 255)

                swatch.BackgroundColor3       = col3
                colorPreview.BackgroundColor3 = col3
                satValBg.BackgroundColor3     = Color3.fromHSV(h, 1, 1)
                svImage.ImageColor3           = Color3.new(1, 1, 1)
                svKnob.Position               = UDim2.new(s, 0, 1 - v, 0)
                hueKnob.Position              = UDim2.new(h, 0, 0, 0)
                hexBox.Text = string.format("#%02X%02X%02X", r, g2, b2)
                rBox.Text = tostring(r)
                gBox.Text = tostring(g2)
                bBox.Text = tostring(b2)
                cpCfg.Color = col3

                if not silent then
                    SafeCall(cpCfg.Callback, col3)
                end
            end

            UpdateAll(true)

            svInteract.MouseButton1Down:Connect(function() draggingSV = true end)
            hInteract.MouseButton1Down:Connect(function() draggingH = true end)

            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                   inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = false
                    draggingH  = false
                end
            end)

            RS.RenderStepped:Connect(function()
                if not _cpOpen then return end
                if draggingSV then
                    local lx = math.clamp(mouse.X - satValBg.AbsolutePosition.X, 0, satValBg.AbsoluteSize.X)
                    local ly = math.clamp(mouse.Y - satValBg.AbsolutePosition.Y, 0, satValBg.AbsoluteSize.Y)
                    s = lx / satValBg.AbsoluteSize.X
                    v = 1 - (ly / satValBg.AbsoluteSize.Y)
                    UpdateAll()
                end
                if draggingH then
                    local lx = math.clamp(mouse.X - hueSlider.AbsolutePosition.X, 0, hueSlider.AbsoluteSize.X)
                    h = lx / hueSlider.AbsoluteSize.X
                    UpdateAll()
                end
            end)

            hexBox.Focused:Connect(function()
                Tween(hexBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Accent, Transparency = 0 })
            end)
            hexBox.FocusLost:Connect(function()
                Tween(hexBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border, Transparency = 0.3 })
                local txt = hexBox.Text:gsub("#", "")
                local r2, g2, b2 = txt:match("^(%x%x)(%x%x)(%x%x)$")
                if r2 then
                    local col3 = Color3.fromRGB(tonumber(r2,16), tonumber(g2,16), tonumber(b2,16))
                    h, s, v = col3:ToHSV()
                    UpdateAll()
                else
                    local c = Color3.fromHSV(h, s, v)
                    hexBox.Text = string.format("#%02X%02X%02X",
                        math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
                end
            end)

            local function applyRGB()
                local r2 = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
                local g2 = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
                local b2 = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
                h, s, v = Color3.fromRGB(r2, g2, b2):ToHSV()
                UpdateAll()
            end

            rBox.FocusLost:Connect(applyRGB)
            gBox.FocusLost:Connect(applyRGB)
            bBox.FocusLost:Connect(applyRGB)

            local function PositionAndOpenCP()
                local rowAbs = row.AbsolutePosition
                local rowSz  = row.AbsoluteSize
                local vp     = workspace.CurrentCamera.ViewportSize

                local popW = 230
                local spaceBelow = vp.Y - (rowAbs.Y + rowSz.Y)
                local openUp = spaceBelow < CP_H + 10

                cpWin.Size = UDim2.fromOffset(popW, 0)
                if openUp then
                    cpWin.Position = UDim2.fromOffset(
                        math.clamp(rowAbs.X, 4, vp.X - popW - 4),
                        rowAbs.Y - CP_H - 4
                    )
                else
                    cpWin.Position = UDim2.fromOffset(
                        math.clamp(rowAbs.X, 4, vp.X - popW - 4),
                        rowAbs.Y + rowSz.Y + 4
                    )
                end

                cpWin.Visible = true
                Tween(cpWin, { Size = UDim2.fromOffset(popW, CP_H) })
            end

            local function CloseCP()
                _cpOpen = false
                draggingSV = false
                draggingH  = false
                Tween(cpWin, { Size = UDim2.fromOffset(cpWin.AbsoluteSize.X, 0) }, "fast")
                task.delay(0.25, function()
                    if not _cpOpen then cpWin.Visible = false end
                end)
            end

            interact.MouseButton1Click:Connect(function()
                _cpOpen = not _cpOpen
                if _cpOpen then
                    PositionAndOpenCP()
                else
                    CloseCP()
                end
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if _cpOpen and (
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch
                ) then
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local mpos = UIS:GetMouseLocation() - inset
                    local wpos = cpWin.AbsolutePosition
                    local wsz  = cpWin.AbsoluteSize
                    local rpos = row.AbsolutePosition
                    local rsz  = row.AbsoluteSize

                    local inWin = mpos.X >= wpos.X and mpos.X <= wpos.X + wsz.X
                        and mpos.Y >= wpos.Y and mpos.Y <= wpos.Y + wsz.Y
                    local inRow = mpos.X >= rpos.X and mpos.X <= rpos.X + rsz.X
                        and mpos.Y >= rpos.Y and mpos.Y <= rpos.Y + rsz.Y

                    if not inWin and not inRow then
                        CloseCP()
                    end
                end
            end)

            interact.MouseEnter:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.BorderHover })
            end)
            interact.MouseLeave:Connect(function()
                Tween(row:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border })
            end)

            SpawnFadeIn(row)
            AutoCanvas()

            local CPObj = { Color = cpCfg.Color, Settings = cpCfg }

            function CPObj:Set(newCfg)
                newCfg = Merge(cpCfg, newCfg)
                cpCfg = newCfg
                nameLabel.Text = cpCfg.Name
                h, s, v = cpCfg.Color:ToHSV()
                UpdateAll(true)
                CPObj.Color = cpCfg.Color
            end

            function CPObj:Destroy()
                CloseCP()
                task.delay(0.3, function() cpGui:Destroy() end)
                row:Destroy()
                AutoCanvas()
            end

            MakeLockable(CPObj, row)

            if flag then DarkLib.Options[flag] = CPObj end

            return CPObj
           end
    
    function TabObj:CreateDiscordInviter(cfg)
    cfg = Merge({
        Name   = "Discord Server",
        Link   = "https://discord.gg/example",
        IconID = "0",
    }, cfg)

    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.BG3,
        ZIndex           = 4,
        Parent           = Page,
    }, {
        UICorner(7),
        UIStroke(Theme.Border, 1, 0.55),
    })
    row:SetAttribute("TargetBT", 0.55)

    local iconFrame = New("Frame", {
        Size             = UDim2.fromOffset(40, 40),
        Position         = UDim2.new(0, 12, 0.5, -20),
        BackgroundColor3 = Theme.BG2,
        ZIndex           = 5,
        Parent           = row,
    }, { UICorner(10) })

    New("ImageLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://" .. tostring(cfg.IconID),
        ScaleType              = Enum.ScaleType.Fit,
        ZIndex                 = 6,
        Parent                 = iconFrame,
    }, { UICorner(5) })

    New("TextLabel", {
        Size                   = UDim2.new(1, -76, 0, 16),
        Position               = UDim2.new(0, 62, 0, 12),
        BackgroundTransparency = 1,
        Text                   = cfg.Name,
        TextColor3             = Theme.Text,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
        Parent                 = row,
    })

    New("TextLabel", {
        Size                   = UDim2.new(1, -76, 0, 14),
        Position               = UDim2.new(0, 62, 0, 30),
        BackgroundTransparency = 1,
        Text                   = cfg.Link,
        TextColor3             = Color3.fromRGB(88, 166, 255),
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        ZIndex                 = 5,
        Parent                 = row,
    })

    local joinBtn = New("TextButton", {
        Size             = UDim2.fromOffset(150, 30),
        Position         = UDim2.new(1, -155, 1, -35),
        BackgroundColor3 = Color3.fromRGB(80, 200, 75),
        Text             = "Join",
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        AutoButtonColor  = false,
        TextTransparency = 0,
        ZIndex           = 6,
        Parent           = row,
    }, { UICorner(5) })

    local _copied = false

    joinBtn.MouseButton1Click:Connect(function()
        if _copied then return end
        _copied = true

        pcall(function()
            if setclipboard then
                setclipboard(cfg.Link)
            elseif toclipboard then
                toclipboard(cfg.Link)
            end
        end)

        Tween(joinBtn, { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }, "fast")
        joinBtn.Text = "Copied!"

        task.delay(3, function()
            if not joinBtn or not joinBtn.Parent then return end
            _copied = false
            Tween(joinBtn, { BackgroundColor3 = Color3.fromRGB(80, 200, 75) }, "fast")
            joinBtn.Text = "Join"
        end)
    end)

    local interact = New("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 7,
        Parent                 = row,
    })

    interact.MouseButton1Click:Connect(function()
        joinBtn.MouseButton1Click:Fire()
    end)

    interact.MouseEnter:Connect(function()
        Tween(row, { BackgroundTransparency = 0.35 }, "fast")
    end)
    interact.MouseLeave:Connect(function()
        Tween(row, { BackgroundTransparency = 0.55 }, "fast")
    end)

    joinBtn.ZIndex = 8

    SpawnFadeIn(row)
    AutoCanvas()

    local InviterObj = { Settings = cfg }

    function InviterObj:Set(newCfg)
        cfg = Merge(cfg, newCfg)
        for _, c in ipairs(row:GetDescendants()) do
            if c:IsA("TextLabel") then
                if c.Font == Enum.Font.GothamBold and c.TextSize == 13 then
                    c.Text = cfg.Name
                elseif c.TextColor3 == Color3.fromRGB(88, 166, 255) then
                    c.Text = cfg.Link
                end
            elseif c:IsA("ImageLabel") then
                c.Image = "rbxassetid://" .. tostring(cfg.IconID)
            end
        end
        InviterObj.Settings = cfg
    end

    function InviterObj:Destroy()
        row:Destroy()
        AutoCanvas()
    end

    MakeLockable(InviterObj, row)
    return InviterObj
end

        return TabObj
    end

    if cfg.KeySystem then
        local KeySettings = cfg.KeySettings
        local _keyAttempts   = 0
        local _keyMaxTries   = KeySettings.MaxAttempts or 5
        local _keyLocked     = false
        local _keySubmitting = false

        local keyScreen = New("Frame", {
            Name = "KeyScreen",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.BG,
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = Window
        }, { UICorner(10) })

        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 30)),
                ColorSequenceKeypoint.new(1, Theme.BG),
            }),
            Rotation = 135,
            Parent = keyScreen
        })

        local keyAccentBar = New("Frame", {
            Size = UDim2.new(0, 60, 0, 3),
            Position = UDim2.new(0.5, -30, 0.5, -108),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 202,
            Parent = keyScreen
        }, { UICorner(4) })

        if KeySettings.Icon and KeySettings.Icon ~= "" then
            New("ImageLabel", {
                Size = UDim2.new(0, 38, 0, 38),
                Position = UDim2.new(0.5, -19, 0.5, -130),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. tostring(KeySettings.Icon),
                ImageColor3 = Theme.AccentGlow,
                ScaleType = Enum.ScaleType.Fit,
                ImageTransparency = 1,
                ZIndex = 202,
                Parent = keyScreen
            })
        end

        local keyTitle = New("TextLabel", {
            Size = UDim2.new(0, 280, 0, 28),
            Position = UDim2.new(0.5, -140, 0.5, -82),
            BackgroundTransparency = 1,
            Text = KeySettings.Title,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        })

        local keySubtitle = New("TextLabel", {
            Size = UDim2.new(0, 280, 0, 16),
            Position = UDim2.new(0.5, -140, 0.5, -56),
            BackgroundTransparency = 1,
            Text = KeySettings.Subtitle or "",
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        })

  
        local keyDesc = New("TextLabel", {
            Size = UDim2.new(0, 280, 0, 14),
            Position = UDim2.new(0.5, -140, 0.5, -36),
            BackgroundTransparency = 1,
            Text = KeySettings.Description or "",
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        })

        local keySep = New("Frame", {
            Size = UDim2.new(0, 240, 0, 1),
            Position = UDim2.new(0.5, -120, 0.5, -16),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        })

        local keyInputBg = New("Frame", {
            Size = UDim2.new(0, 248, 0, 36),
            Position = UDim2.new(0.5, -124, 0.5, 4),
            BackgroundColor3 = Theme.BG2,
            BackgroundTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        }, {
            UICorner(7),
            UIStroke(Theme.Border, 1, 0.3),
        })

        local keyBox = New("TextBox", {
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            PlaceholderText = KeySettings.Placeholder or "Enter your key...",
            Text = "",
            PlaceholderColor3 = Theme.TextMuted,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            ClearTextOnFocus = false,
            TextTransparency = 1,
            ZIndex = 202,
            Parent = keyInputBg
        })

        local keyPasteBtn = New("ImageButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, -32, 0.5, -13),
            BackgroundColor3 = Theme.BG3,
            BackgroundTransparency = 0.3,
            Image = "rbxassetid://10709799288",
            ImageColor3 = Theme.TextDim,
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            AutoButtonColor = false,
            ZIndex = 203,
            Parent = keyInputBg
        }, { UICorner(5) })

        local keyBtnRow = New("Frame", {
            Size = UDim2.new(0, 248, 0, 32),
            Position = UDim2.new(0.5, -124, 0.5, 48),
            BackgroundTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        }, { UIListLayout(8, Enum.FillDirection.Horizontal) })

        local keySubmit = New("TextButton", {
            Size = UDim2.new(0, 148, 1, 0),
            BackgroundColor3 = Theme.AccentDim,
            Text = "Submit",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextTransparency = 1,
            ZIndex = 202,
            Parent = keyBtnRow
        }, { UICorner(7) })

        local keyGetBtn
        if KeySettings.KeyLink and KeySettings.KeyLink ~= "" then
            keyGetBtn = New("TextButton", {
                Size = UDim2.new(0, 92, 1, 0),
                BackgroundColor3 = Theme.BG3,
                Text = "Get Key",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextTransparency = 1,
                ZIndex = 202,
                Parent = keyBtnRow
            }, {
                UICorner(7),
                UIStroke(Theme.Border, 1, 0.3),
            })
        end

        local keyStatus = New("TextLabel", {
            Size = UDim2.new(0, 248, 0, 18),
            Position = UDim2.new(0.5, -124, 0.5, 88),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Theme.Red,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextTransparency = 1,
            ZIndex = 201,
            Parent = keyScreen
        })

        local function _keyFadeIn(obj, extraDelay)
            task.delay(extraDelay or 0, function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    Tween(obj, { TextTransparency = 0, BackgroundTransparency = obj:IsA("TextButton") and 0 or 1 }, "slow")
                elseif obj:IsA("Frame") then
                    Tween(obj, { BackgroundTransparency = 0 }, "slow")
                elseif obj:IsA("ImageLabel") then
                    Tween(obj, { ImageTransparency = 0 }, "slow")
                end
            end)
        end

        task.spawn(function()
            Tween(keyScreen, { BackgroundTransparency = 0 }, "slow")
            task.delay(0.05, function() _keyFadeIn(keyAccentBar) end)
            task.delay(0.1,  function()
                for _, c in ipairs(keyScreen:GetDescendants()) do
                    if c:IsA("ImageLabel") then Tween(c, { ImageTransparency = 0 }, "slow") end
                end
            end)
            task.delay(0.12, function() _keyFadeIn(keyTitle) end)
            task.delay(0.18, function() _keyFadeIn(keySubtitle) end)
            task.delay(0.22, function() _keyFadeIn(keyDesc) end)
            task.delay(0.26, function() Tween(keySep, { BackgroundTransparency = 0.6 }, "slow") end)
            task.delay(0.30, function()
                Tween(keyInputBg, { BackgroundTransparency = 0 }, "slow")
                Tween(keyBox, { TextTransparency = 0 }, "slow")
                Tween(keyPasteBtn, { BackgroundTransparency = 0.3, ImageTransparency = 0 }, "slow")
            end)
            task.delay(0.36, function()
                Tween(keySubmit, { TextTransparency = 0, BackgroundTransparency = 0 }, "slow")
                if keyGetBtn then Tween(keyGetBtn, { TextTransparency = 0, BackgroundTransparency = 0 }, "slow") end
            end)
            task.delay(0.42, function() Tween(keyStatus, { TextTransparency = 0 }, "slow") end)
        end)

        local function _keyFadeOut(cb)
            Tween(keyScreen, { BackgroundTransparency = 1 }, "med")
            for _, c in ipairs(keyScreen:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextBox") or c:IsA("TextButton") then
                    Tween(c, { TextTransparency = 1, BackgroundTransparency = 1 }, "med")
                elseif c:IsA("Frame") then
                    Tween(c, { BackgroundTransparency = 1 }, "med")
                elseif c:IsA("ImageLabel") then
                    Tween(c, { ImageTransparency = 1 }, "med")
                elseif c:IsA("UIStroke") then
                    Tween(c, { Transparency = 1 }, "med")
                end
            end
            task.delay(0.38, function()
                keyScreen:Destroy()
                if cb then cb() end
            end)
        end

        local function _shakeInput()
            local orig = keyInputBg.Position
            local ox = orig.X.Offset
            local oy = orig.Y.Offset
            local offsets = {-7, 7, -5, 5, -3, 3, 0}
            local t = 0
            for _, dx in ipairs(offsets) do
                t = t + 0.045
                task.delay(t, function()
                    keyInputBg.Position = UDim2.new(orig.X.Scale, ox + dx, orig.Y.Scale, oy)
                end)
            end
        end

        local function _doSubmit()
            if _keySubmitting or _keyLocked then return end
            local entered = keyBox.Text
            if entered == "" then return end

            _keySubmitting = true
            keySubmit.Text = "Checking..."
            keySubmit.Active = false

            local valid = false
            for _, k in ipairs(KeySettings.Key) do
                if entered == k then valid = true; break end
            end

            task.delay(0.3, function() 
                if valid then
                    keyStatus.TextColor3 = Theme.Green
                    keyStatus.Text = "Key accepted!"
                    task.delay(0.5, function()
                        _keyFadeOut(function()
                            DarkLib:Notify({
                                Title = "Access Granted",
                                Content = KeySettings.Title .. " unlocked.",
                                Type = "success",
                                Duration = 4
                            })
                        end)
                    end)
                else
                    _keyAttempts = _keyAttempts + 1
                    _keySubmitting = false
                    keySubmit.Text = "Submit"
                    keySubmit.Active = true

                    _shakeInput()
                    Tween(keyInputBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Red, Transparency = 0 })

                    local remaining = _keyMaxTries - _keyAttempts
                    if remaining <= 0 then
                        _keyLocked = true
                        local lockSecs = KeySettings.LockDuration or 30
                        keyStatus.TextColor3 = Theme.Red
                        keySubmit.Active = false

                        local countdown = lockSecs
                        local function _tick()
                            if countdown <= 0 then
                                _keyLocked = false
                                _keyAttempts = 0
                                keySubmit.Active = true
                                keySubmit.Text = "Submit"
                                keyStatus.Text = ""
                                Tween(keyInputBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border, Transparency = 0.3 })
                                return
                            end
                            keyStatus.Text = ("Too many attempts. Wait %ds"):format(countdown)
                            keySubmit.Text = ("%ds"):format(countdown)
                            countdown = countdown - 1
                            task.delay(1, _tick)
                        end
                        _tick()
                    else
                        keyStatus.TextColor3 = Theme.Red
                        keyStatus.Text = ("Invalid key! %d attempt%s left"):format(remaining, remaining == 1 and "" or "s")
                        task.delay(1.4, function()
                            Tween(keyInputBg:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Border, Transparency = 0.3 })
                            if keyStatus.Text:find("attempt") then keyStatus.Text = "" end
                        end)
                    end
                end
            end)
        end

        keySubmit.MouseButton1Click:Connect(_doSubmit)

        keyBox.FocusLost:Connect(function(enter)
            if enter then _doSubmit() end
        end)

        keyPasteBtn.MouseButton1Click:Connect(function()
            
            local clip = nil
            if type(getclipboard) == "function" then
                local ok, res = pcall(getclipboard)
                if ok and res and res ~= "" then clip = res end
            end
            if not clip and type(cloneref) == "function" then
                local ok, res = pcall(function()
                    return cloneref(game:GetService("GuiService")):GetClipboard()
                end)
                if ok and res and res ~= "" then clip = res end
            end

            if clip and clip ~= "" then
                keyBox.Text = clip
                Tween(keyPasteBtn, { BackgroundColor3 = Theme.AccentDim, ImageColor3 = Theme.AccentGlow }, "fast")
                task.delay(0.5, function()
                    Tween(keyPasteBtn, { BackgroundColor3 = Theme.BG3, ImageColor3 = Theme.TextDim }, "med")
                end)
            else
                
                Tween(keyPasteBtn, { ImageColor3 = Theme.Red }, "fast")
                task.delay(0.5, function()
                    Tween(keyPasteBtn, { ImageColor3 = Theme.TextDim }, "med")
                end)
            end
        end)

        if keyGetBtn and KeySettings.KeyLink then
            keyGetBtn.MouseButton1Click:Connect(function()
                local ok, _ = pcall(setclipboard, KeySettings.KeyLink)
                if ok then
                    local prev = keyGetBtn.Text
                    keyGetBtn.Text = "Copied!"
                    task.delay(1.5, function() keyGetBtn.Text = prev end)
                end
            end)
        end
    end

    function WindowObj:CreateCloseButton(cfg2)
        cfg2 = cfg2 or {}
        local iconId    = cfg2.IconId
        local validIcon = type(iconId) == "string" and iconId ~= ""
            and tonumber(iconId:match("%d+")) ~= nil

        for _, c in ipairs(_closeBtnFrame:GetChildren()) do
            if c:IsA("ImageLabel") or c:IsA("TextLabel") then c:Destroy() end
        end

        local closeColor = Color3.fromRGB(190, 60, 90)

        if validIcon then
            New("ImageLabel", {
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. iconId:match("%d+"),
                ImageColor3 = closeColor,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 4,
                Parent = _closeBtnFrame
            })
        else
            New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "X",
                TextColor3 = closeColor,
                TextTransparency = 0.1,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                ZIndex = 4,
                Parent = _closeBtnFrame
            })
        end
    end

    function WindowObj:CreateMinimizeButton(cfg2)
        cfg2 = cfg2 or {}

        local function validId(id)
            return type(id) == "string" and id ~= "" and tonumber(id:match("%d+")) ~= nil
        end

        local onId  = validId(cfg2.OnIconId)  and cfg2.OnIconId:match("%d+")  or nil
        local offId = validId(cfg2.OffIconId) and cfg2.OffIconId:match("%d+") or nil

        WindowObj._minCfg = {
            _onIconId    = onId,
            _offIconId   = offId,
            _onFallback  = "+",
            _offFallback = "-",
        }

        for _, c in ipairs(_minBtnFrame:GetChildren()) do
            if c:IsA("ImageLabel") or c:IsA("TextLabel") then c:Destroy() end
        end

        local minColor = Color3.fromRGB(120, 90, 220)

        if onId or offId then
            local startId = _minimized and (onId or offId) or (offId or onId)
            New("ImageLabel", {
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. startId,
                ImageColor3 = minColor,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 4,
                Parent = _minBtnFrame
            })
        else
            New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = _minimized and "+" or "─",
                TextColor3 = minColor,
                TextTransparency = 0.1,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                ZIndex = 4,
                Parent = _minBtnFrame
            })
        end
    end
    
    

    return WindowObj
end

function DarkLib:Dialog(data)
    assert(type(data) == "table", "Dialog: data must be a table")
    assert(type(data.Buttons) == "table" and #data.Buttons >= 1 and #data.Buttons <= 4,
        "Dialog: Buttons must contain between 1 and 4 entries")

    data = Merge({
        Title       = "Dialog",
        Description = "",
        Callback    = nil,
    }, data)

    local sg = MakeOverlayGui("DarkLibV6_Dialog", 10000)

    local backdrop = New("Frame", {
        Name = "Backdrop",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = sg,
    })

    local CARD_W   = 380
    local PAD_H    = 22
    local PAD_V    = 24
    local SEP_GAP  = 10
    local DESC_GAP = 12
    local BTN_H    = 38
    local BTN_GAP  = 10
    local BTN_TOP_GAP = 16

    local card = New("Frame", {
        Name = "Card",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, CARD_W, 0, 0),
        BackgroundColor3 = Theme.BG2,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = sg,
    }, {
        UICorner(10),
        UIStroke(Theme.Border, 1, 0),
    })

    local accentBar = New("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 3, 0, 26),
        Position = UDim2.new(0, PAD_H - 10, 0, PAD_V - 2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = card,
    }, { UICorner(3) })

    local titleLbl = New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -(PAD_H * 2), 0, 22),
        Position = UDim2.new(0, PAD_H, 0, PAD_V),
        BackgroundTransparency = 1,
        Text = data.Title,
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = card,
    })

    local sep = New("Frame", {
        Name = "Sep",
        Size = UDim2.new(1, -(PAD_H * 2), 0, 1),
        Position = UDim2.new(0, PAD_H, 0, SEP_Y),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        ZIndex = 3,
        Parent = card,
    })

    local descLbl = New("TextLabel", {
        Name = "Desc",
        Size = UDim2.new(1, -(PAD_H * 2), 0, 0),
        Position = UDim2.new(0, PAD_H, 0, DESC_Y),
        BackgroundTransparency = 1,
        Text = data.Description,
        TextColor3 = Theme.TextDim,
        TextTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 3,
        Parent = card,
    })

    task.wait()

    
    titleLbl.Size = UDim2.new(1, -(PAD_H * 2), 0, math.huge)
    local titleH = math.max(titleLbl.TextBounds.Y, 1)
    titleLbl.Size = UDim2.new(1, -(PAD_H * 2), 0, titleH)


    local SEP_Y_real = PAD_V + titleH + SEP_GAP
    sep.Position   = UDim2.new(0, PAD_H, 0, SEP_Y_real)
    accentBar.Size = UDim2.new(0, 3, 0, titleH + 4)


    local DESC_Y_real = SEP_Y_real + 1 + DESC_GAP
    descLbl.Position  = UDim2.new(0, PAD_H, 0, DESC_Y_real)
    descLbl.Size      = UDim2.new(1, -(PAD_H * 2), 0, math.huge)
    local descH = descLbl.TextBounds.Y
    if descH < 1 then descH = 0 end
    descLbl.Size = UDim2.new(1, -(PAD_H * 2), 0, descH)

    local numBtns    = #data.Buttons
    local btnsTop    = DESC_Y_real + descH + (descH > 0 and BTN_TOP_GAP or SEP_GAP)


    local numRows    = (numBtns <= 2) and 1 or 2
    local totalBtnsH = numRows * BTN_H + (numRows - 1) * BTN_GAP

    local btnContainer = New("Frame", {
        Name = "Buttons",
        Size = UDim2.new(1, -(PAD_H * 2), 0, totalBtnsH),
        Position = UDim2.new(0, PAD_H, 0, btnsTop),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = card,
    })

    local CARD_H = btnsTop + totalBtnsH + PAD_V

    local _closed = false
    local _closeDialog
    _closeDialog = function(btnIndex)
        if _closed then return end
        _closed = true

        Tween(backdrop, { BackgroundTransparency = 1 }, "med")
        Tween(card, { BackgroundTransparency = 1 }, "med")
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                Tween(d, { TextTransparency = 1, BackgroundTransparency = 1 }, "med")
            elseif d:IsA("UIStroke") then
                Tween(d, { Transparency = 1 }, "med")
            elseif d:IsA("Frame") then
                Tween(d, { BackgroundTransparency = 1 }, "med")
            end
        end
        Tween(card, { Size = UDim2.new(0, CARD_W, 0, CARD_H * 0.85) }, "med")
        task.delay(0.38, function() sg:Destroy() end)

        if btnIndex then
            local btnCfg = data.Buttons[btnIndex]
            if btnCfg and type(btnCfg.Callback) == "function" then
                SafeCall(btnCfg.Callback, btnIndex)
            end
            if type(data.Callback) == "function" then
                SafeCall(data.Callback, btnIndex)
            end
        end
    end

    local function _makeBtn(i, btnData, posX, posY, sizeX)
        local bColor = btnData.Color       or Theme.Accent
        local sColor = btnData.StrokeColor or Theme.Border
        local sThick = btnData.StrokeThick or 1
        local bRound = btnData.Round       or 7
        local bText  = btnData.Text        or ("Button " .. i)

        local btn = New("TextButton", {
            Name = "Btn_" .. i,
            Position = UDim2.new(posX, 0, posY, 0),
            Size     = UDim2.new(sizeX, 0, 0, BTN_H),
            BackgroundColor3 = bColor,
            BackgroundTransparency = 0.15,
            Text = bText,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
            ZIndex = 4,
            Parent = btnContainer,
        }, {
            UICorner(bRound),
            UIStroke(sColor, sThick, 0.3),
        })

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0, TextTransparency = 0 }, "fast")
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.15, TextTransparency = 0 }, "fast")
        end)

        btn.MouseButton1Click:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.35 }, "fast")
            task.delay(0.12, function() _closeDialog(i) end)
        end)

        return btn
    end

    local row2Y          = (BTN_H + BTN_GAP) / totalBtnsH
    local PAIR_GAP_SCALE = BTN_GAP / (CARD_W - PAD_H * 2)
    local PAIR_W         = (1 - PAIR_GAP_SCALE) / 2

    if numBtns == 1 then
        _makeBtn(1, data.Buttons[1], 0, 0, 1)

    elseif numBtns == 2 then
        _makeBtn(1, data.Buttons[1], 0,                       0, PAIR_W)
        _makeBtn(2, data.Buttons[2], PAIR_W + PAIR_GAP_SCALE, 0, PAIR_W)

    elseif numBtns == 3 then
        _makeBtn(1, data.Buttons[1], 0,                       0,     PAIR_W)
        _makeBtn(2, data.Buttons[2], PAIR_W + PAIR_GAP_SCALE, 0,     PAIR_W)
        local centerX = (1 - PAIR_W) / 2
        _makeBtn(3, data.Buttons[3], centerX,                 row2Y, PAIR_W)

    elseif numBtns == 4 then
        _makeBtn(1, data.Buttons[1], 0,                       0,     PAIR_W)
        _makeBtn(2, data.Buttons[2], PAIR_W + PAIR_GAP_SCALE, 0,     PAIR_W)
        _makeBtn(3, data.Buttons[3], 0,                       row2Y, PAIR_W)
        _makeBtn(4, data.Buttons[4], PAIR_W + PAIR_GAP_SCALE, row2Y, PAIR_W)
    end

    card.Size = UDim2.new(0, CARD_W, 0, CARD_H * 0.88)

    Tween(backdrop, { BackgroundTransparency = 0.55 }, "med")
    Tween(card, {
        Size = UDim2.new(0, CARD_W, 0, CARD_H),
        BackgroundTransparency = 0.04,
    }, "slow")

    task.wait(0.12)
    Tween(titleLbl, { TextTransparency = 0 })
    Tween(accentBar, { BackgroundTransparency = 0 }, "slow")
    if descH > 0 then
        task.wait(0.06)
        Tween(descLbl, { TextTransparency = 0.15 })
    end
    task.wait(0.08)
    for _, btn in ipairs(btnContainer:GetChildren()) do
        if btn:IsA("TextButton") then
            Tween(btn, { TextTransparency = 0, BackgroundTransparency = 0.15 })
            task.wait(0.05)
        end
    end
end

function DarkLib:CreateToggleButton(cfg, windowObj)
    cfg = Merge({
        IconID = "rbxassetid://0",
        Radius = 28,
    }, cfg)

    local size = cfg.Radius * 2
    local sg = MakeOverlayGui("DarkLibV6_ToggleBtn", 9800)

    local btn = New("Frame", {
        Name = "ToggleButton",
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.fromOffset(24, 24),
        BackgroundColor3 = Theme.BG2,
        ZIndex = 1,
        Parent = sg,
    }, {
        UICorner(cfg.Radius),
        UIStroke(Theme.Accent, 2, 0),
    })

    New("ImageLabel", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Image = cfg.IconID,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 2,
        Parent = btn,
    })

    local interact = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = btn,
    })

    local dragging   = false
    local dragInput  = nil
    local dragStart  = nil
    local startPos   = nil
    local _visible   = true
    local _dragMoved = false

    interact.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            _dragMoved = false
            dragInput  = input
            dragStart  = input.Position
            startPos   = btn.Position

            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging  = false
                    dragInput = nil
                end
            end)
        end
    end)


    UIS.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging  = false
            dragInput = nil
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart

        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            _dragMoved = true
        end
        btn.Position = UDim2.fromOffset(
            startPos.X.Offset + delta.X,
            startPos.Y.Offset + delta.Y
        )
    end)

    interact.MouseButton1Click:Connect(function()
        if _dragMoved then return end

        local root = CoreGui
        if gethui then root = gethui() end

        for _, child in ipairs(root:GetChildren()) do
            if child.Name:find("DarkLibV6_DDPopup") or child.Name:find("DarkLibV6_CPPopup") then
                child:Destroy()
            end
        end

        if windowObj then
            _visible = not _visible
            local win = windowObj._window

            if _visible then
                win.Visible = true
                Tween(win, { BackgroundTransparency = 0 }, "med")
                for _, c in ipairs(win:GetDescendants()) do
                    if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                        Tween(c, { TextTransparency = 0 }, "med")
                    elseif c:IsA("ImageLabel") or c:IsA("ImageButton") then
                        Tween(c, { ImageTransparency = 0 }, "med")
                    elseif c:IsA("UIStroke") then
                        Tween(c, { Transparency = 0 }, "med")
                    end
                end
                Tween(btn:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.Accent }, "fast")
            else
                Tween(win, { BackgroundTransparency = 1 }, "med")
                for _, c in ipairs(win:GetDescendants()) do
                    if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                        Tween(c, { TextTransparency = 1 }, "med")
                    elseif c:IsA("ImageLabel") or c:IsA("ImageButton") then
                        Tween(c, { ImageTransparency = 1 }, "med")
                    elseif c:IsA("UIStroke") then
                        Tween(c, { Transparency = 1 }, "med")
                    end
                end
                Tween(btn:FindFirstChildWhichIsA("UIStroke"), { Color = Theme.AccentDim }, "fast")
                task.delay(0.13, function()
                    if not _visible then
                        win.Visible = false
                    end
                end)
            end

            windowObj.Visible = _visible
        end
    end)

    interact.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.BG3 }, "fast")
    end)
    interact.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.BG2 }, "fast")
    end)

    return btn
end

return DarkLib
