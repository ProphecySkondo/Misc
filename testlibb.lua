-- Advanced Command Library for Roblox
-- Infinite Yield inspired UI with modular command system
-- Author: Assistant

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Player Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Check if library already exists (for game persistence)
if _G.CommandLibraryLoaded then
    return _G.CommandLibraryInstance
end

-- Command Library Class
local CommandLibrary = {}
CommandLibrary.__index = CommandLibrary

-- Library Variables
local Commands = {}
local CommandHistory = {}
local Aliases = {}
local Plugins = {}
local Settings = {
    Prefix = "",
    Theme = "Dark",
    Keybind = Enum.KeyCode.Semicolon,
    FadeKeybind = Enum.KeyCode.BackQuote, -- Backtick key
    AutoComplete = true,
    CommandSuggestions = true,
    Notifications = true,
    LoadingTime = 2,
    DiscordServer = "https://discord.gg/YourServerHere" -- Replace with your Discord invite
}

-- State Variables
local States = {
    FlyEnabled = false,
    FlySpeed = 50,
    FlyConnection = nil,
    BodyVelocity = nil,
    BodyAngularVelocity = nil,
    NoClipEnabled = false,
    NoClipConnection = nil,
    SpeedEnabled = false,
    OriginalSpeed = 16,
    JumpPowerEnabled = false,
    OriginalJumpPower = 50,
    InfiniteJumpEnabled = false,
    GodModeEnabled = false,
    FullbrightEnabled = false,
    ESPEnabled = false,
    ClickTPEnabled = false,
    AntiAFKEnabled = false,
    Character = nil,
    Humanoid = nil,
    RootPart = nil
}

-- UI Variables
local GUI = {}
local LoadingGUI = {}

-- Utility Functions
local function updateCharacterReferences()
    States.Character = Player.Character
    if States.Character then
        States.Humanoid = States.Character:WaitForChild("Humanoid", 5)
        States.RootPart = States.Character:WaitForChild("HumanoidRootPart", 5)
        if States.Humanoid then
            States.OriginalSpeed = States.Humanoid.WalkSpeed
            States.OriginalJumpPower = States.Humanoid.JumpPower
        end
    end
end

local function createNotification(title, text, duration, color)
    if not Settings.Notifications then return end
    
    StarterGui:SetCore("SendNotification", {
        Title = title or "Command Library";
        Text = text or "";
        Duration = duration or 3;
        Button1 = "OK";
    })
end

local function createSound(id, volume, pitch)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = volume or 0.5
    sound.Pitch = pitch or 1
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Beautiful Intro Animation
local function createIntroAnimation()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "CommandLibraryIntro"
    IntroGui.Parent = CoreGui
    IntroGui.ResetOnSpawn = false
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Background with animated gradient
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = IntroGui
    Background.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    
    local BgGradient = Instance.new("UIGradient")
    BgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 30))
    }
    BgGradient.Rotation = 45
    BgGradient.Parent = Background
    
    -- Animated particles background
    local ParticleFrame = Instance.new("Frame")
    ParticleFrame.Name = "ParticleFrame"
    ParticleFrame.Parent = Background
    ParticleFrame.BackgroundTransparency = 1
    ParticleFrame.Size = UDim2.new(1, 0, 1, 0)
    
    -- Create floating particles
    for i = 1, 20 do
        local Particle = Instance.new("Frame")
        Particle.Parent = ParticleFrame
        Particle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        Particle.BorderSizePixel = 0
        Particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        Particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Particle.BackgroundTransparency = math.random(30, 80) / 100
        
        local ParticleCorner = Instance.new("UICorner")
        ParticleCorner.CornerRadius = UDim.new(1, 0)
        ParticleCorner.Parent = Particle
        
        -- Animate particles
        spawn(function()
            while Particle.Parent do
                local newPos = UDim2.new(math.random(), 0, math.random(), 0)
                local tween = TweenService:Create(Particle, TweenInfo.new(math.random(3, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = newPos})
                tween:Play()
                wait(math.random(1, 3))
            end
        end)
    end
    
    -- Main intro container
    local IntroContainer = Instance.new("Frame")
    IntroContainer.Name = "IntroContainer"
    IntroContainer.Parent = Background
    IntroContainer.BackgroundTransparency = 1
    IntroContainer.Position = UDim2.new(0.5, -300, 0.5, -150)
    IntroContainer.Size = UDim2.new(0, 600, 0, 300)
    
    -- Logo/Icon
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Name = "LogoFrame"
    LogoFrame.Parent = IntroContainer
    LogoFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    LogoFrame.BorderSizePixel = 0
    LogoFrame.Position = UDim2.new(0.5, -40, 0, 20)
    LogoFrame.Size = UDim2.new(0, 80, 0, 80)
    LogoFrame.BackgroundTransparency = 1
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 20)
    LogoCorner.Parent = LogoFrame
    
    local LogoGradient = Instance.new("UIGradient")
    LogoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
    }
    LogoGradient.Rotation = 45
    LogoGradient.Parent = LogoFrame
    
    -- Logo text
    local LogoText = Instance.new("TextLabel")
    LogoText.Name = "LogoText"
    LogoText.Parent = LogoFrame
    LogoText.BackgroundTransparency = 1
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Text = "CL"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextScaled = true
    LogoText.TextTransparency = 1
    
    -- Main title
    local MainTitle = Instance.new("TextLabel")
    MainTitle.Name = "MainTitle"
    MainTitle.Parent = IntroContainer
    MainTitle.BackgroundTransparency = 1
    MainTitle.Position = UDim2.new(0, 0, 0, 120)
    MainTitle.Size = UDim2.new(1, 0, 0, 50)
    MainTitle.Font = Enum.Font.GothamBold
    MainTitle.Text = "COMMAND LIBRARY"
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextSize = 36
    MainTitle.TextTransparency = 1
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Parent = IntroContainer
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 170)
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Advanced Command System v2.0"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
    Subtitle.TextSize = 18
    Subtitle.TextTransparency = 1
    
    -- Loading indicator
    local LoadingContainer = Instance.new("Frame")
    LoadingContainer.Name = "LoadingContainer"
    LoadingContainer.Parent = IntroContainer
    LoadingContainer.BackgroundTransparency = 1
    LoadingContainer.Position = UDim2.new(0, 0, 0, 220)
    LoadingContainer.Size = UDim2.new(1, 0, 0, 60)
    
    -- Animated loading dots
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.Parent = LoadingContainer
    LoadingText.BackgroundTransparency = 1
    LoadingText.Position = UDim2.new(0, 0, 0, 0)
    LoadingText.Size = UDim2.new(1, 0, 0, 25)
    LoadingText.Font = Enum.Font.Gotham
    LoadingText.Text = "Loading"
    LoadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
    LoadingText.TextSize = 16
    LoadingText.TextTransparency = 1
    
    -- Progress bar background
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Name = "ProgressBG"
    ProgressBG.Parent = LoadingContainer
    ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Position = UDim2.new(0, 50, 0, 35)
    ProgressBG.Size = UDim2.new(1, -100, 0, 4)
    ProgressBG.BackgroundTransparency = 1
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 2)
    ProgressCorner.Parent = ProgressBG
    
    -- Progress bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Parent = ProgressBG
    ProgressBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    
    local ProgressBarCorner = Instance.new("UICorner")
    ProgressBarCorner.CornerRadius = UDim.new(0, 2)
    ProgressBarCorner.Parent = ProgressBar
    
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
    }
    ProgressGradient.Parent = ProgressBar
    
    -- Animation sequence
    local function playIntroAnimation()
        -- Background gradient animation
        spawn(function()
            while IntroGui.Parent do
                TweenService:Create(BgGradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = BgGradient.Rotation + 360}):Play()
                wait(3)
            end
        end)
        
        wait(0.5)
        
        -- Logo entrance
        LogoFrame.BackgroundTransparency = 0
        LogoFrame.Size = UDim2.new(0, 0, 0, 0)
        local logoTween1 = TweenService:Create(LogoFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 80, 0, 80)})
        logoTween1:Play()
        
        wait(0.3)
        TweenService:Create(LogoText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        
        wait(0.5)
        
        -- Title entrance
        MainTitle.Position = UDim2.new(0, 0, 0, 150)
        local titleTween = TweenService:Create(MainTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 120),
            TextTransparency = 0
        })
        titleTween:Play()
        
        wait(0.3)
        
        -- Subtitle entrance
        Subtitle.Position = UDim2.new(0, 0, 0, 200)
        local subtitleTween = TweenService:Create(Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 170),
            TextTransparency = 0
        })
        subtitleTween:Play()
        
        wait(0.5)
        
        -- Loading text entrance
        TweenService:Create(LoadingText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        TweenService:Create(ProgressBG, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        
        wait(0.3)
        
        -- Loading animation with stages
        local loadingStages = {
            "Initializing services...",
            "Loading command modules...",
            "Setting up UI components...",
            "Registering commands...",
            "Applying configurations...",
            "Finalizing setup..."
        }
        
        for i, stage in ipairs(loadingStages) do
            LoadingText.Text = stage
            local progress = i / #loadingStages
            TweenService:Create(ProgressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
            wait(0.6)
        end
        
        wait(0.5)
        
        -- Completion
        LoadingText.Text = "Complete!"
        TweenService:Create(LoadingText, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(100, 255, 100)}):Play()
        TweenService:Create(ProgressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(100, 255, 100)}):Play()
        
        wait(1)
        
        -- Exit animation
        local exitTween = TweenService:Create(IntroContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -300, -1, -150)
        })
        exitTween:Play()
        
        TweenService:Create(Background, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        
        wait(1)
        IntroGui:Destroy()
    end
    
    playIntroAnimation()
    return IntroGui
end

-- Modern Sectioned UI Creation
local function createMainUI()
    -- Destroy existing GUI
    if PlayerGui:FindFirstChild("CommandLibraryGUI") then
        PlayerGui:FindFirstChild("CommandLibraryGUI"):Destroy()
    end
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CommandLibraryGUI"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -500, 0.5, -300)
    MainFrame.Size = UDim2.new(0, 1000, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.BackgroundTransparency = 1
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Background with gradient
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = MainFrame
    Background.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 12)
    BgCorner.Parent = Background
    
    local BgGradient = Instance.new("UIGradient")
    BgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    BgGradient.Rotation = 135
    BgGradient.Parent = Background
    
    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.3
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 26))
    }
    TitleGradient.Rotation = 90
    TitleGradient.Parent = TitleBar
    
    -- Title Bar Bottom Fix
    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Parent = TitleBar
    TitleBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TitleBarFix.BorderSizePixel = 0
    TitleBarFix.Position = UDim2.new(0, 0, 1, -12)
    TitleBarFix.Size = UDim2.new(1, 0, 0, 12)
    
    -- Logo in title bar
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Name = "LogoFrame"
    LogoFrame.Parent = TitleBar
    LogoFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    LogoFrame.BorderSizePixel = 0
    LogoFrame.Position = UDim2.new(0, 15, 0, 10)
    LogoFrame.Size = UDim2.new(0, 30, 0, 30)
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoFrame
    
    local LogoGradient = Instance.new("UIGradient")
    LogoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 130, 255))
    }
    LogoGradient.Rotation = 45
    LogoGradient.Parent = LogoFrame
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Name = "LogoText"
    LogoText.Parent = LogoFrame
    LogoText.BackgroundTransparency = 1
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Text = "CL"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextScaled = true
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 55, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Command Library"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Version Label
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Parent = TitleBar
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 255, 0, 0)
    Version.Size = UDim2.new(0, 50, 1, 0)
    Version.Font = Enum.Font.Gotham
    Version.Text = "v2.0"
    Version.TextColor3 = Color3.fromRGB(120, 120, 150)
    Version.TextSize = 12
    Version.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Window Controls
    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "WindowControls"
    WindowControls.Parent = TitleBar
    WindowControls.BackgroundTransparency = 1
    WindowControls.Position = UDim2.new(1, -80, 0, 10)
    WindowControls.Size = UDim2.new(0, 70, 0, 30)
    
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.Parent = WindowControls
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.Padding = UDim.new(0, 5)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = WindowControls
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeButton.TextSize = 16
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = WindowControls
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.BorderSizePixel = 0
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Main Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 0, 0, 50)
    ContentArea.Size = UDim2.new(1, 0, 1, -50)
    
    -- Sidebar (Command Categories)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = ContentArea
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.Size = UDim2.new(0, 200, 1, -60)
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24))
    }
    SidebarGradient.Rotation = 90
    SidebarGradient.Parent = Sidebar
    
    -- Sidebar Header
    local SidebarHeader = Instance.new("TextLabel")
    SidebarHeader.Name = "SidebarHeader"
    SidebarHeader.Parent = Sidebar
    SidebarHeader.BackgroundTransparency = 1
    SidebarHeader.Position = UDim2.new(0, 15, 0, 10)
    SidebarHeader.Size = UDim2.new(1, -30, 0, 30)
    SidebarHeader.Font = Enum.Font.GothamBold
    SidebarHeader.Text = "Categories"
    SidebarHeader.TextColor3 = Color3.fromRGB(200, 200, 220)
    SidebarHeader.TextSize = 16
    SidebarHeader.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Category List
    local CategoryList = Instance.new("ScrollingFrame")
    CategoryList.Name = "CategoryList"
    CategoryList.Parent = Sidebar
    CategoryList.BackgroundTransparency = 1
    CategoryList.Position = UDim2.new(0, 10, 0, 50)
    CategoryList.Size = UDim2.new(1, -20, 1, -60)
    CategoryList.ScrollBarThickness = 3
    CategoryList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    CategoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local CategoryLayout = Instance.new("UIListLayout")
    CategoryLayout.Parent = CategoryList
    CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CategoryLayout.Padding = UDim.new(0, 5)
    
    -- Main Panel
    local MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Parent = ContentArea
    MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    MainPanel.BorderSizePixel = 0
    MainPanel.Position = UDim2.new(0, 220, 0, 10)
    MainPanel.Size = UDim2.new(1, -230, 1, -60)
    
    local MainPanelCorner = Instance.new("UICorner")
    MainPanelCorner.CornerRadius = UDim.new(0, 8)
    MainPanelCorner.Parent = MainPanel
    
    local MainPanelGradient = Instance.new("UIGradient")
    MainPanelGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24))
    }
    MainPanelGradient.Rotation = 90
    MainPanelGradient.Parent = MainPanel
    
    -- Command Input Section
    local InputSection = Instance.new("Frame")
    InputSection.Name = "InputSection"
    InputSection.Parent = MainPanel
    InputSection.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    InputSection.BorderSizePixel = 0
    InputSection.Position = UDim2.new(0, 15, 0, 15)
    InputSection.Size = UDim2.new(1, -30, 0, 50)
    
    local InputSectionCorner = Instance.new("UICorner")
    InputSectionCorner.CornerRadius = UDim.new(0, 8)
    InputSectionCorner.Parent = InputSection
    
    -- Command Input
    local CommandInput = Instance.new("TextBox")
    CommandInput.Name = "CommandInput"
    CommandInput.Parent = InputSection
    CommandInput.BackgroundTransparency = 1
    CommandInput.Position = UDim2.new(0, 15, 0, 0)
    CommandInput.Size = UDim2.new(1, -30, 1, 0)
    CommandInput.Font = Enum.Font.Gotham
    CommandInput.PlaceholderText = "Enter command here... (e.g., fly, speed 100, tp player)"
    CommandInput.Text = ""
    CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CommandInput.TextSize = 14
    CommandInput.TextXAlignment = Enum.TextXAlignment.Left
    CommandInput.ClearTextOnFocus = false
    
    -- Content Tabs
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainPanel
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 15, 0, 80)
    TabContainer.Size = UDim2.new(1, -30, 0, 40)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Commands Tab
    local CommandsTab = Instance.new("TextButton")
    CommandsTab.Name = "CommandsTab"
    CommandsTab.Parent = TabContainer
    CommandsTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    CommandsTab.BorderSizePixel = 0
    CommandsTab.Size = UDim2.new(0, 100, 1, 0)
    CommandsTab.Font = Enum.Font.GothamBold
    CommandsTab.Text = "Commands"
    CommandsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    CommandsTab.TextSize = 12
    
    local CommandsTabCorner = Instance.new("UICorner")
    CommandsTabCorner.CornerRadius = UDim.new(0, 6)
    CommandsTabCorner.Parent = CommandsTab
    
    -- Output Tab
    local OutputTab = Instance.new("TextButton")
    OutputTab.Name = "OutputTab"
    OutputTab.Parent = TabContainer
    OutputTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    OutputTab.BorderSizePixel = 0
    OutputTab.Size = UDim2.new(0, 100, 1, 0)
    OutputTab.Font = Enum.Font.Gotham
    OutputTab.Text = "Output"
    OutputTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    OutputTab.TextSize = 12
    
    local OutputTabCorner = Instance.new("UICorner")
    OutputTabCorner.CornerRadius = UDim.new(0, 6)
    OutputTabCorner.Parent = OutputTab
    
    -- Settings Tab
    local SettingsTab = Instance.new("TextButton")
    SettingsTab.Name = "SettingsTab"
    SettingsTab.Parent = TabContainer
    SettingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SettingsTab.BorderSizePixel = 0
    SettingsTab.Size = UDim2.new(0, 100, 1, 0)
    SettingsTab.Font = Enum.Font.Gotham
    SettingsTab.Text = "Settings"
    SettingsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    SettingsTab.TextSize = 12
    
    local SettingsTabCorner = Instance.new("UICorner")
    SettingsTabCorner.CornerRadius = UDim.new(0, 6)
    SettingsTabCorner.Parent = SettingsTab
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainPanel
    ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 15, 0, 135)
    ContentFrame.Size = UDim2.new(1, -30, 1, -150)
    
    local ContentFrameCorner = Instance.new("UICorner")
    ContentFrameCorner.CornerRadius = UDim.new(0, 8)
    ContentFrameCorner.Parent = ContentFrame
    
    -- Commands List (Default View)
    local CommandsList = Instance.new("ScrollingFrame")
    CommandsList.Name = "CommandsList"
    CommandsList.Parent = ContentFrame
    CommandsList.BackgroundTransparency = 1
    CommandsList.Position = UDim2.new(0, 10, 0, 10)
    CommandsList.Size = UDim2.new(1, -20, 1, -20)
    CommandsList.ScrollBarThickness = 4
    CommandsList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    CommandsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local CommandsListLayout = Instance.new("UIListLayout")
    CommandsListLayout.Parent = CommandsList
    CommandsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CommandsListLayout.Padding = UDim.new(0, 5)
    
    -- Output Frame
    local OutputFrame = Instance.new("ScrollingFrame")
    OutputFrame.Name = "OutputFrame"
    OutputFrame.Parent = ContentFrame
    OutputFrame.BackgroundTransparency = 1
    OutputFrame.Position = UDim2.new(0, 10, 0, 10)
    OutputFrame.Size = UDim2.new(1, -20, 1, -20)
    OutputFrame.ScrollBarThickness = 4
    OutputFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    OutputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    OutputFrame.Visible = false
    
    local OutputList = Instance.new("UIListLayout")
    OutputList.Parent = OutputFrame
    OutputList.SortOrder = Enum.SortOrder.LayoutOrder
    OutputList.Padding = UDim.new(0, 3)
    
    -- Settings Frame
    local SettingsFrame = Instance.new("ScrollingFrame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Parent = ContentFrame
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Position = UDim2.new(0, 10, 0, 10)
    SettingsFrame.Size = UDim2.new(1, -20, 1, -20)
    SettingsFrame.ScrollBarThickness = 4
    SettingsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    SettingsFrame.Visible = false
    
    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.Parent = SettingsFrame
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Padding = UDim.new(0, 10)
    
    -- Bottom Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.Parent = ContentArea
    StatusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    StatusBar.BorderSizePixel = 0
    StatusBar.Position = UDim2.new(0, 10, 1, -40)
    StatusBar.Size = UDim2.new(1, -20, 0, 30)
    
    local StatusBarCorner = Instance.new("UICorner")
    StatusBarCorner.CornerRadius = UDim.new(0, 8)
    StatusBarCorner.Parent = StatusBar
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = StatusBar
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 0)
    StatusLabel.Size = UDim2.new(0.3, 0, 1, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Ready"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Command Count
    local CommandCount = Instance.new("TextLabel")
    CommandCount.Name = "CommandCount"
    CommandCount.Parent = StatusBar
    CommandCount.BackgroundTransparency = 1
    CommandCount.Position = UDim2.new(0.3, 0, 0, 0)
    CommandCount.Size = UDim2.new(0.4, 0, 1, 0)
    CommandCount.Font = Enum.Font.Gotham
    CommandCount.Text = "0 commands loaded"
    CommandCount.TextColor3 = Color3.fromRGB(150, 150, 170)
    CommandCount.TextSize = 12
    CommandCount.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Keybind Info
    local KeybindInfo = Instance.new("TextLabel")
    KeybindInfo.Name = "KeybindInfo"
    KeybindInfo.Parent = StatusBar
    KeybindInfo.BackgroundTransparency = 1
    KeybindInfo.Position = UDim2.new(0.7, 0, 0, 0)
    KeybindInfo.Size = UDim2.new(0.3, -15, 1, 0)
    KeybindInfo.Font = Enum.Font.Gotham
    KeybindInfo.Text = "Press ; to toggle"
    KeybindInfo.TextColor3 = Color3.fromRGB(120, 120, 150)
    KeybindInfo.TextSize = 12
    KeybindInfo.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Store GUI references
    GUI = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        CommandInput = CommandInput,
        OutputFrame = OutputFrame,
        CommandsList = CommandsList,
        SettingsFrame = SettingsFrame,
        CategoryList = CategoryList,
        StatusLabel = StatusLabel,
        CommandCount = CommandCount,
        CloseButton = CloseButton,
        MinimizeButton = MinimizeButton,
        CommandsTab = CommandsTab,
        OutputTab = OutputTab,
        SettingsTab = SettingsTab,
        CurrentTab = "Commands"
    }
    
    return GUI
end

-- Command System Functions
function CommandLibrary:AddCommand(name, description, aliases, func)
    Commands[name:lower()] = {
        Name = name,
        Description = description,
        Function = func,
        Aliases = aliases or {}
    }
    
    -- Add aliases
    if aliases then
        for _, alias in ipairs(aliases) do
            Aliases[alias:lower()] = name:lower()
        end
    end
    
    self:UpdateCommandCount()
    
    -- Refresh UI if it exists
    if GUI.CommandsList then
        self:PopulateCommandsList()
        self:PopulateCategories()
        
        -- Update status if this is the first command
        if self:GetCommandCount() == 1 then
            self:UpdateStatus("Ready", Color3.fromRGB(100, 255, 100))
        end
    end
end

function CommandLibrary:RemoveCommand(name)
    local cmd = Commands[name:lower()]
    if cmd then
        -- Remove aliases
        if cmd.Aliases then
            for _, alias in ipairs(cmd.Aliases) do
                Aliases[alias:lower()] = nil
            end
        end
        Commands[name:lower()] = nil
        self:UpdateCommandCount()
    end
end

function CommandLibrary:GetCommand(name)
    local cmdName = Aliases[name:lower()] or name:lower()
    return Commands[cmdName]
end

function CommandLibrary:ExecuteCommand(input)
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then return end
    
    local commandName = args[1]:lower()
    table.remove(args, 1)
    
    local command = self:GetCommand(commandName)
    if command then
        self:AddOutput("> " .. input, Color3.fromRGB(200, 200, 200))
        
        local success, error = pcall(command.Function, args)
        if not success then
            self:AddOutput("Error: " .. tostring(error), Color3.fromRGB(255, 100, 100))
        end
        
        table.insert(CommandHistory, input)
        if #CommandHistory > 50 then
            table.remove(CommandHistory, 1)
        end
    else
        self:AddOutput("> " .. input, Color3.fromRGB(200, 200, 200))
        self:AddOutput("Unknown command: " .. commandName, Color3.fromRGB(255, 100, 100))
    end
end

function CommandLibrary:AddOutput(text, color)
    if not GUI.OutputFrame then return end
    
    color = color or Color3.fromRGB(255, 255, 255)
    
    local OutputLabel = Instance.new("TextLabel")
    OutputLabel.Parent = GUI.OutputFrame
    OutputLabel.BackgroundTransparency = 1
    OutputLabel.Size = UDim2.new(1, -10, 0, 20)
    OutputLabel.Font = Enum.Font.Gotham
    OutputLabel.Text = text
    OutputLabel.TextColor3 = color
    OutputLabel.TextSize = 12
    OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
    OutputLabel.TextYAlignment = Enum.TextYAlignment.Top
    OutputLabel.TextWrapped = true
    
    -- Auto-resize based on text
    local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(GUI.OutputFrame.AbsoluteSize.X - 10, math.huge))
    OutputLabel.Size = UDim2.new(1, -10, 0, math.max(20, textSize.Y))
    
    GUI.OutputFrame.CanvasSize = UDim2.new(0, 0, 0, GUI.OutputFrame.UIListLayout.AbsoluteContentSize.Y)
    GUI.OutputFrame.CanvasPosition = Vector2.new(0, GUI.OutputFrame.CanvasSize.Y.Offset)
    
    -- Remove old messages if too many
    local children = GUI.OutputFrame:GetChildren()
    local labelCount = 0
    for _, child in ipairs(children) do
        if child:IsA("TextLabel") then
            labelCount = labelCount + 1
        end
    end
    
    if labelCount > 100 then
        for i = 1, 10 do
            for _, child in ipairs(children) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                    break
                end
            end
        end
    end
end

function CommandLibrary:UpdateCommandCount()
    if GUI.CommandCount then
        local count = 0
        for _ in pairs(Commands) do
            count = count + 1
        end
        GUI.CommandCount.Text = count .. " commands loaded"
    end
end

function CommandLibrary:UpdateStatus(text, color)
    if GUI.StatusLabel then
        GUI.StatusLabel.Text = text
        GUI.StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    end
end

function CommandLibrary:ToggleGUI()
    if GUI.MainFrame then
        if GUI.MainFrame.Visible then
            -- Animate close
            TweenService:Create(GUI.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            wait(0.3)
            GUI.MainFrame.Visible = false
        else
            -- Show and animate open
            GUI.MainFrame.Visible = true
            self:CreateIntroAnimation()
            GUI.CommandInput:CaptureFocus()
        end
    end
end

function CommandLibrary:FadeGUI()
    if GUI.MainFrame and GUI.MainFrame.Visible then
        -- Fade out animation
        local fadeOut = TweenService:Create(GUI.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        })
        
        -- Fade all child elements
        local function fadeElement(element)
            if element:IsA("GuiObject") then
                local originalTransparency = element.BackgroundTransparency
                local originalTextTransparency = element:IsA("TextLabel") and element.TextTransparency or nil
                
                if element.BackgroundTransparency < 1 then
                    TweenService:Create(element, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 1
                    }):Play()
                end
                
                if originalTextTransparency and originalTextTransparency < 1 then
                    TweenService:Create(element, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                        TextTransparency = 1
                    }):Play()
                end
                
                for _, child in pairs(element:GetChildren()) do
                    fadeElement(child)
                end
            end
        end
        
        fadeElement(GUI.MainFrame)
        fadeOut:Play()
        
        fadeOut.Completed:Connect(function()
            GUI.MainFrame.Visible = false
            -- Reset transparencies for next show
            self:ResetTransparencies()
        end)
    end
end

function CommandLibrary:ResetTransparencies()
    local function resetElement(element)
        if element:IsA("GuiObject") then
            if element.Name ~= "Shadow" then
                element.BackgroundTransparency = element:GetAttribute("OriginalBGTransparency") or 0
            end
            
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                element.TextTransparency = element:GetAttribute("OriginalTextTransparency") or 0
            end
            
            for _, child in pairs(element:GetChildren()) do
                resetElement(child)
            end
        end
    end
    
    if GUI.MainFrame then
        resetElement(GUI.MainFrame)
    end
end

function CommandLibrary:CopyDiscordServer()
    if setclipboard then
        setclipboard(Settings.DiscordServer)
        self:AddOutput("Discord server copied to clipboard!", Color3.fromRGB(100, 255, 100))
        createNotification("Discord Server", "Invite link copied to clipboard!", 3)
    else
        self:AddOutput("Clipboard not supported by your executor", Color3.fromRGB(255, 100, 100))
        self:AddOutput("Discord Server: " .. Settings.DiscordServer, Color3.fromRGB(100, 255, 255))
    end
end

-- Character Management
function CommandLibrary:UpdateCharacter()
    updateCharacterReferences()
    
    if States.Character then
        self:AddOutput("Character updated", Color3.fromRGB(100, 255, 100))
    end
end

-- Fly System
function CommandLibrary:StartFly()
    if States.FlyEnabled or not States.RootPart then return end
    
    States.FlyEnabled = true
    
    -- Create body movers
    if States.BodyVelocity then States.BodyVelocity:Destroy() end
    if States.BodyAngularVelocity then States.BodyAngularVelocity:Destroy() end
    
    States.BodyVelocity = Instance.new("BodyVelocity")
    States.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    States.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    States.BodyVelocity.Parent = States.RootPart
    
    States.BodyAngularVelocity = Instance.new("BodyAngularVelocity")
    States.BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
    States.BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    States.BodyAngularVelocity.Parent = States.RootPart
    
    -- Fly connection
    States.FlyConnection = RunService.Heartbeat:Connect(function()
        if not States.FlyEnabled or not States.RootPart then return end
        
        local Camera = workspace.CurrentCamera
        local MoveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveVector = MoveVector + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveVector = MoveVector - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveVector = MoveVector - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveVector = MoveVector + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveVector = MoveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            MoveVector = MoveVector - Vector3.new(0, 1, 0)
        end
        
        States.BodyVelocity.Velocity = MoveVector * States.FlySpeed
    end)
    
    self:AddOutput("Fly enabled (Speed: " .. States.FlySpeed .. ")", Color3.fromRGB(100, 255, 100))
    self:UpdateStatus("Flying", Color3.fromRGB(100, 255, 100))
end

function CommandLibrary:StopFly()
    if not States.FlyEnabled then return end
    
    States.FlyEnabled = false
    
    if States.FlyConnection then
        States.FlyConnection:Disconnect()
        States.FlyConnection = nil
    end
    
    if States.BodyVelocity then
        States.BodyVelocity:Destroy()
        States.BodyVelocity = nil
    end
    
    if States.BodyAngularVelocity then
        States.BodyAngularVelocity:Destroy()
        States.BodyAngularVelocity = nil
    end
    
    self:AddOutput("Fly disabled", Color3.fromRGB(255, 100, 100))
    self:UpdateStatus("Ready", Color3.fromRGB(100, 255, 100))
end

-- NoClip System
function CommandLibrary:StartNoClip()
    if States.NoClipEnabled then return end
    
    States.NoClipEnabled = true
    
    States.NoClipConnection = RunService.Stepped:Connect(function()
        if not States.NoClipEnabled or not States.Character then return end
        
        for _, part in pairs(States.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    self:AddOutput("NoClip enabled", Color3.fromRGB(100, 255, 100))
end

function CommandLibrary:StopNoClip()
    if not States.NoClipEnabled then return end
    
    States.NoClipEnabled = false
    
    if States.NoClipConnection then
        States.NoClipConnection:Disconnect()
        States.NoClipConnection = nil
    end
    
    if States.Character then
        for _, part in pairs(States.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    
    self:AddOutput("NoClip disabled", Color3.fromRGB(255, 100, 100))
end

-- Register Built-in System Commands Only
function CommandLibrary:RegisterSystemCommands()
    -- System Commands
    self:AddCommand("clear", "Clear console", {"cls"}, function(args)
        for _, child in pairs(GUI.OutputFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        self:AddOutput("Console cleared", Color3.fromRGB(255, 255, 100))
    end)
    
    self:AddCommand("help", "Show command list", {"h", "commands", "cmds"}, function(args)
        self:AddOutput("=== COMMAND LIBRARY HELP ===", Color3.fromRGB(100, 255, 255))
        self:AddOutput("", Color3.fromRGB(255, 255, 255))
        
        if self:GetCommandCount() == 0 then
            self:AddOutput("No commands loaded yet.", Color3.fromRGB(255, 255, 100))
            self:AddOutput("Use lib:AddCommand() to add commands.", Color3.fromRGB(255, 255, 100))
            return
        end
        
        local categories = {
            ["Movement"] = {},
            ["Teleport"] = {},
            ["Character"] = {},
            ["Visual"] = {},
            ["Info"] = {},
            ["System"] = {}
        }
        
        -- Categorize existing commands
        for cmdName, cmd in pairs(Commands) do
            local category = "System" -- Default
            
            if cmdName:find("fly") or cmdName:find("speed") or cmdName:find("jump") or cmdName:find("noclip") then
                category = "Movement"
            elseif cmdName:find("tp") or cmdName:find("goto") or cmdName:find("teleport") then
                category = "Teleport"
            elseif cmdName:find("sit") or cmdName:find("reset") or cmdName:find("respawn") then
                category = "Character"
            elseif cmdName:find("fullbright") or cmdName:find("esp") then
                category = "Visual"
            elseif cmdName:find("coords") or cmdName:find("players") or cmdName:find("about") then
                category = "Info"
            end
            
            table.insert(categories[category], cmdName)
        end
        
        for category, cmds in pairs(categories) do
            if #cmds > 0 then
                self:AddOutput("--- " .. category .. " ---", Color3.fromRGB(150, 150, 255))
                for _, cmdName in ipairs(cmds) do
                    local cmd = Commands[cmdName]
                    if cmd then
                        local aliasText = ""
                        if cmd.Aliases and #cmd.Aliases > 0 then
                            aliasText = " (" .. table.concat(cmd.Aliases, ", ") .. ")"
                        end
                        self:AddOutput(cmdName .. aliasText .. " - " .. cmd.Description, Color3.fromRGB(255, 255, 255))
                    end
                end
                self:AddOutput("", Color3.fromRGB(255, 255, 255))
            end
        end
        
        self:AddOutput("Total commands: " .. self:GetCommandCount(), Color3.fromRGB(100, 255, 255))
        self:AddOutput("Press " .. Settings.Keybind.Name .. " to toggle GUI", Color3.fromRGB(100, 255, 255))
        self:AddOutput("Press ` (backtick) to fade GUI", Color3.fromRGB(100, 255, 255))
    end)
    
    self:AddCommand("about", "Show library information", {"info"}, function(args)
        self:AddOutput("=== COMMAND LIBRARY INFO ===", Color3.fromRGB(100, 255, 255))
        self:AddOutput("Version: 2.0 - Pure Library", Color3.fromRGB(255, 255, 255))
        self:AddOutput("Author: Assistant", Color3.fromRGB(255, 255, 255))
        self:AddOutput("Commands loaded: " .. self:GetCommandCount(), Color3.fromRGB(255, 255, 255))
        self:AddOutput("Inspired by Infinite Yield", Color3.fromRGB(255, 255, 255))
        self:AddOutput("", Color3.fromRGB(255, 255, 255))
        self:AddOutput("Features:", Color3.fromRGB(150, 150, 255))
        self:AddOutput("• Pure modular command library", Color3.fromRGB(255, 255, 255))
        self:AddOutput("• Dark themed sectioned UI", Color3.fromRGB(255, 255, 255))
        self:AddOutput("• Command aliases & categories", Color3.fromRGB(255, 255, 255))
        self:AddOutput("• Cross-game persistence", Color3.fromRGB(255, 255, 255))
        self:AddOutput("• Extensible plugin system", Color3.fromRGB(255, 255, 255))
        self:AddOutput("", Color3.fromRGB(255, 255, 255))
        self:AddOutput("Usage:", Color3.fromRGB(150, 150, 255))
        self:AddOutput("lib:AddCommand(name, desc, aliases, func)", Color3.fromRGB(255, 255, 255))
        self:AddOutput("", Color3.fromRGB(255, 255, 255))
        self:AddOutput("Example:", Color3.fromRGB(150, 150, 255))
        self:AddOutput('lib:AddCommand("fly", "Enable flight", {"f"}, function()', Color3.fromRGB(200, 200, 200))
        self:AddOutput('    -- Your fly code here', Color3.fromRGB(200, 200, 200))
        self:AddOutput('end)', Color3.fromRGB(200, 200, 200))
    end)
    
    self:AddCommand("discord", "Copy Discord server invite", {"dc", "server"}, function(args)
        self:CopyDiscordServer()
    end)
    
    self:AddCommand("reload", "Reload the library", {"rl"}, function(args)
        self:AddOutput("Reloading Command Library...", Color3.fromRGB(255, 255, 100))
        wait(1)
        
        -- Clear global flag
        _G.CommandLibraryLoaded = false
        _G.CommandLibraryInstance = nil
        
        -- Destroy current GUI
        if GUI.ScreenGui then
            GUI.ScreenGui:Destroy()
        end
        
        -- Reload script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ProphecySkondo/Misc/refs/heads/main/testlibb.lua"))()
    end)
end

-- Initialize Library
-- UI Helper Functions
function CommandLibrary:SwitchTab(tabName)
    if not GUI.CommandsList then return end
    
    GUI.CurrentTab = tabName
    
    -- Hide all content frames
    GUI.CommandsList.Visible = false
    GUI.OutputFrame.Visible = false
    GUI.SettingsFrame.Visible = false
    
    -- Reset tab colors
    GUI.CommandsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    GUI.CommandsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    GUI.OutputTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    GUI.OutputTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    GUI.SettingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    GUI.SettingsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Show selected tab and highlight it
    if tabName == "Commands" then
        GUI.CommandsList.Visible = true
        GUI.CommandsTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        GUI.CommandsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tabName == "Output" then
        GUI.OutputFrame.Visible = true
        GUI.OutputTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        GUI.OutputTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tabName == "Settings" then
        GUI.SettingsFrame.Visible = true
        GUI.SettingsTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        GUI.SettingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Animate tab switch
    local activeTab = GUI[tabName .. "Tab"]
    if activeTab then
        TweenService:Create(activeTab, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(120, 170, 255)
        }):Play()
        wait(0.1)
        TweenService:Create(activeTab, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        }):Play()
    end
end

function CommandLibrary:CreateCategoryButton(name, icon, commandCount)
    local CategoryButton = Instance.new("TextButton")
    CategoryButton.Name = name .. "Category"
    CategoryButton.Parent = GUI.CategoryList
    CategoryButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    CategoryButton.BorderSizePixel = 0
    CategoryButton.Size = UDim2.new(1, 0, 0, 35)
    CategoryButton.Font = Enum.Font.Gotham
    CategoryButton.Text = ""
    CategoryButton.TextColor3 = Color3.fromRGB(200, 200, 220)
    CategoryButton.TextSize = 12
    
    local CategoryCorner = Instance.new("UICorner")
    CategoryCorner.CornerRadius = UDim.new(0, 6)
    CategoryCorner.Parent = CategoryButton
    
    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = "Icon"
    IconLabel.Parent = CategoryButton
    IconLabel.BackgroundTransparency = 1
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.Size = UDim2.new(0, 20, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = icon
    IconLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    IconLabel.TextSize = 14
    
    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "Name"
    NameLabel.Parent = CategoryButton
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 35, 0, 0)
    NameLabel.Size = UDim2.new(1, -70, 1, 0)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Count
    local CountLabel = Instance.new("TextLabel")
    CountLabel.Name = "Count"
    CountLabel.Parent = CategoryButton
    CountLabel.BackgroundTransparency = 1
    CountLabel.Position = UDim2.new(1, -30, 0, 0)
    CountLabel.Size = UDim2.new(0, 25, 1, 0)
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.Text = tostring(commandCount)
    CountLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    CountLabel.TextSize = 10
    CountLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Hover effects
    CategoryButton.MouseEnter:Connect(function()
        TweenService:Create(CategoryButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        }):Play()
    end)
    
    CategoryButton.MouseLeave:Connect(function()
        TweenService:Create(CategoryButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        }):Play()
    end)
    
    CategoryButton.MouseButton1Click:Connect(function()
        self:FilterCommandsByCategory(name)
    end)
    
    return CategoryButton
end

function CommandLibrary:CreateCommandCard(commandName, command)
    local CommandCard = Instance.new("Frame")
    CommandCard.Name = commandName .. "Card"
    CommandCard.Parent = GUI.CommandsList
    CommandCard.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    CommandCard.BorderSizePixel = 0
    CommandCard.Size = UDim2.new(1, 0, 0, 60)
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = CommandCard
    
    local CardGradient = Instance.new("UIGradient")
    CardGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 28))
    }
    CardGradient.Rotation = 90
    CardGradient.Parent = CommandCard
    
    -- Command Name
    local CommandNameLabel = Instance.new("TextLabel")
    CommandNameLabel.Name = "CommandName"
    CommandNameLabel.Parent = CommandCard
    CommandNameLabel.BackgroundTransparency = 1
    CommandNameLabel.Position = UDim2.new(0, 15, 0, 5)
    CommandNameLabel.Size = UDim2.new(0.6, 0, 0, 20)
    CommandNameLabel.Font = Enum.Font.GothamBold
    CommandNameLabel.Text = commandName
    CommandNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CommandNameLabel.TextSize = 14
    CommandNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Description
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Name = "Description"
    DescriptionLabel.Parent = CommandCard
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Position = UDim2.new(0, 15, 0, 25)
    DescriptionLabel.Size = UDim2.new(0.6, 0, 0, 15)
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.Text = command.Description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    DescriptionLabel.TextSize = 11
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Aliases
    if command.Aliases and #command.Aliases > 0 then
        local AliasesLabel = Instance.new("TextLabel")
        AliasesLabel.Name = "Aliases"
        AliasesLabel.Parent = CommandCard
        AliasesLabel.BackgroundTransparency = 1
        AliasesLabel.Position = UDim2.new(0, 15, 0, 40)
        AliasesLabel.Size = UDim2.new(0.6, 0, 0, 15)
        AliasesLabel.Font = Enum.Font.Gotham
        AliasesLabel.Text = "Aliases: " .. table.concat(command.Aliases, ", ")
        AliasesLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
        AliasesLabel.TextSize = 9
        AliasesLabel.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Execute Button
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Name = "ExecuteButton"
    ExecuteButton.Parent = CommandCard
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    ExecuteButton.BorderSizePixel = 0
    ExecuteButton.Position = UDim2.new(1, -80, 0, 15)
    ExecuteButton.Size = UDim2.new(0, 70, 0, 30)
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Text = "Execute"
    ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteButton.TextSize = 11
    
    local ExecuteCorner = Instance.new("UICorner")
    ExecuteCorner.CornerRadius = UDim.new(0, 6)
    ExecuteCorner.Parent = ExecuteButton
    
    ExecuteButton.MouseButton1Click:Connect(function()
        self:ExecuteCommand(commandName)
    end)
    
    -- Hover effects
    ExecuteButton.MouseEnter:Connect(function()
        TweenService:Create(ExecuteButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(120, 170, 255)
        }):Play()
    end)
    
    ExecuteButton.MouseLeave:Connect(function()
        TweenService:Create(ExecuteButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        }):Play()
    end)
    
    return CommandCard
end

function CommandLibrary:PopulateCommandsList()
    -- Clear existing commands
    for _, child in pairs(GUI.CommandsList:GetChildren()) do
        if child:IsA("Frame") and (child.Name:find("Card") or child.Name == "EmptyState") then
            child:Destroy()
        end
    end
    
    -- Check if we have commands
    local commandCount = self:GetCommandCount()
    
    if commandCount == 0 then
        -- Show empty state
        local EmptyState = Instance.new("Frame")
        EmptyState.Name = "EmptyState"
        EmptyState.Parent = GUI.CommandsList
        EmptyState.BackgroundTransparency = 1
        EmptyState.Size = UDim2.new(1, 0, 0, 200)
        
        local EmptyIcon = Instance.new("TextLabel")
        EmptyIcon.Name = "EmptyIcon"
        EmptyIcon.Parent = EmptyState
        EmptyIcon.BackgroundTransparency = 1
        EmptyIcon.Position = UDim2.new(0.5, -30, 0, 20)
        EmptyIcon.Size = UDim2.new(0, 60, 0, 60)
        EmptyIcon.Font = Enum.Font.GothamBold
        EmptyIcon.Text = "📋"
        EmptyIcon.TextColor3 = Color3.fromRGB(100, 100, 120)
        EmptyIcon.TextScaled = true
        
        local EmptyTitle = Instance.new("TextLabel")
        EmptyTitle.Name = "EmptyTitle"
        EmptyTitle.Parent = EmptyState
        EmptyTitle.BackgroundTransparency = 1
        EmptyTitle.Position = UDim2.new(0, 0, 0, 90)
        EmptyTitle.Size = UDim2.new(1, 0, 0, 30)
        EmptyTitle.Font = Enum.Font.GothamBold
        EmptyTitle.Text = "No Commands Loaded"
        EmptyTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
        EmptyTitle.TextSize = 18
        
        local EmptyDesc = Instance.new("TextLabel")
        EmptyDesc.Name = "EmptyDesc"
        EmptyDesc.Parent = EmptyState
        EmptyDesc.BackgroundTransparency = 1
        EmptyDesc.Position = UDim2.new(0, 0, 0, 125)
        EmptyDesc.Size = UDim2.new(1, 0, 0, 40)
        EmptyDesc.Font = Enum.Font.Gotham
        EmptyDesc.Text = "Use lib:AddCommand() to add your own commands\nType 'help' for usage information"
        EmptyDesc.TextColor3 = Color3.fromRGB(120, 120, 140)
        EmptyDesc.TextSize = 12
        EmptyDesc.TextWrapped = true
    else
        -- Add command cards
        for commandName, command in pairs(Commands) do
            self:CreateCommandCard(commandName, command)
        end
    end
    
    -- Update canvas size
    GUI.CommandsList.CanvasSize = UDim2.new(0, 0, 0, GUI.CommandsList.UIListLayout.AbsoluteContentSize.Y)
end

function CommandLibrary:PopulateCategories()
    -- Clear existing categories
    for _, child in pairs(GUI.CategoryList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Define categories
    local categories = {
        {name = "All", icon = "📋", commands = Commands},
        {name = "Movement", icon = "🚀", commands = {}},
        {name = "Teleport", icon = "📍", commands = {}},
        {name = "Character", icon = "👤", commands = {}},
        {name = "Visual", icon = "👁️", commands = {}},
        {name = "System", icon = "⚙️", commands = {}},
        {name = "Info", icon = "ℹ️", commands = {}}
    }
    
    -- Categorize commands
    for commandName, command in pairs(Commands) do
        local category = "System" -- Default category
        
        if commandName:find("fly") or commandName:find("speed") or commandName:find("jump") or commandName:find("noclip") then
            category = "Movement"
        elseif commandName:find("tp") or commandName:find("goto") or commandName:find("teleport") then
            category = "Teleport"
        elseif commandName:find("sit") or commandName:find("reset") or commandName:find("respawn") then
            category = "Character"
        elseif commandName:find("fullbright") or commandName:find("esp") then
            category = "Visual"
        elseif commandName:find("coords") or commandName:find("players") or commandName:find("about") then
            category = "Info"
        end
        
        for _, cat in ipairs(categories) do
            if cat.name == category then
                cat.commands[commandName] = command
                break
            end
        end
    end
    
    -- Create category buttons
    for _, category in ipairs(categories) do
        local count = 0
        for _ in pairs(category.commands) do
            count = count + 1
        end
        self:CreateCategoryButton(category.name, category.icon, count)
    end
    
    -- Update canvas size
    GUI.CategoryList.CanvasSize = UDim2.new(0, 0, 0, GUI.CategoryList.UIListLayout.AbsoluteContentSize.Y)
end

function CommandLibrary:FilterCommandsByCategory(categoryName)
    -- Clear existing commands
    for _, child in pairs(GUI.CommandsList:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Card") then
            child:Destroy()
        end
    end
    
    -- Show commands for category
    if categoryName == "All" then
        self:PopulateCommandsList()
    else
        for commandName, command in pairs(Commands) do
            local shouldShow = false
            
            if categoryName == "Movement" and (commandName:find("fly") or commandName:find("speed") or commandName:find("jump") or commandName:find("noclip")) then
                shouldShow = true
            elseif categoryName == "Teleport" and (commandName:find("tp") or commandName:find("goto") or commandName:find("teleport")) then
                shouldShow = true
            elseif categoryName == "Character" and (commandName:find("sit") or commandName:find("reset") or commandName:find("respawn")) then
                shouldShow = true
            elseif categoryName == "Visual" and (commandName:find("fullbright") or commandName:find("esp")) then
                shouldShow = true
            elseif categoryName == "Info" and (commandName:find("coords") or commandName:find("players") or commandName:find("about")) then
                shouldShow = true
            elseif categoryName == "System" and not (commandName:find("fly") or commandName:find("speed") or commandName:find("jump") or commandName:find("noclip") or commandName:find("tp") or commandName:find("goto") or commandName:find("teleport") or commandName:find("sit") or commandName:find("reset") or commandName:find("respawn") or commandName:find("fullbright") or commandName:find("esp") or commandName:find("coords") or commandName:find("players") or commandName:find("about")) then
                shouldShow = true
            end
            
            if shouldShow then
                self:CreateCommandCard(commandName, command)
            end
        end
    end
    
    -- Update canvas size
    GUI.CommandsList.CanvasSize = UDim2.new(0, 0, 0, GUI.CommandsList.UIListLayout.AbsoluteContentSize.Y)
end

function CommandLibrary:CreateIntroAnimation()
    if not GUI.MainFrame then return end
    
    -- Start with GUI invisible
    GUI.MainFrame.BackgroundTransparency = 1
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    GUI.MainFrame.Visible = true
    
    -- Animate entrance
    local sizeUpTween = TweenService:Create(GUI.MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 1000, 0, 600),
        Position = UDim2.new(0.5, -500, 0.5, -300)
    })
    
    local fadeInTween = TweenService:Create(GUI.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0
    })
    
    sizeUpTween:Play()
    wait(0.3)
    fadeInTween:Play()
    
    -- Animate individual elements
    wait(0.2)
    
    -- Animate tabs
    for _, tab in pairs({GUI.CommandsTab, GUI.OutputTab, GUI.SettingsTab}) do
        tab.Position = UDim2.new(tab.Position.X.Scale, tab.Position.X.Offset, -1, 0)
        TweenService:Create(tab, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(tab.Position.X.Scale, tab.Position.X.Offset, 0, 0)
        }):Play()
        wait(0.1)
    end
end

function CommandLibrary:Initialize()
    -- Show intro animation
    createIntroAnimation()
    
    -- Wait for intro to complete
    wait(Settings.LoadingTime + 2)
    
    -- Update character references
    updateCharacterReferences()
    
    -- Create main UI
    createMainUI()
    
    -- Store original transparencies for fade functionality
    self:StoreOriginalTransparencies()
    
    -- Register only system commands
    self:RegisterSystemCommands()
    
    -- Populate UI
    self:PopulateCategories()
    self:PopulateCommandsList()
    
    -- Setup event connections
    self:SetupEvents()
    
    -- Show GUI with animation
    self:CreateIntroAnimation()
    
    -- Initial messages
    self:AddOutput("Command Library v2.0 - Pure Library loaded!", Color3.fromRGB(100, 255, 100))
    self:AddOutput("This is a pure command library - no commands pre-loaded", Color3.fromRGB(100, 255, 255))
    self:AddOutput("Use lib:AddCommand() to add your own commands", Color3.fromRGB(255, 255, 100))
    self:AddOutput("Type 'help' for system commands and usage info", Color3.fromRGB(200, 200, 255))
    
    -- Play success sound
    createSound(131961136, 0.3, 1.2)
    
    -- Show notification
    createNotification("Command Library", "Pure library loaded! Ready for commands.", 5)
    
    self:UpdateStatus("Ready - No commands loaded", Color3.fromRGB(255, 255, 100))
    self:UpdateCommandCount()
    
    -- Set global persistence flag
    _G.CommandLibraryLoaded = true
    _G.CommandLibraryInstance = self
end

function CommandLibrary:StoreOriginalTransparencies()
    local function storeTransparencies(element)
        if element:IsA("GuiObject") then
            element:SetAttribute("OriginalBGTransparency", element.BackgroundTransparency)
            
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                element:SetAttribute("OriginalTextTransparency", element.TextTransparency)
            end
            
            for _, child in pairs(element:GetChildren()) do
                storeTransparencies(child)
            end
        end
    end
    
    if GUI.MainFrame then
        storeTransparencies(GUI.MainFrame)
    end
end

function CommandLibrary:GetCommandCount()
    local count = 0
    for _ in pairs(Commands) do
        count = count + 1
    end
    return count
end

function CommandLibrary:SetupEvents()
    -- Command input
    GUI.CommandInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and GUI.CommandInput.Text ~= "" then
            self:ExecuteCommand(GUI.CommandInput.Text)
            GUI.CommandInput.Text = ""
        end
    end)
    
    -- Tab switching
    GUI.CommandsTab.MouseButton1Click:Connect(function()
        self:SwitchTab("Commands")
    end)
    
    GUI.OutputTab.MouseButton1Click:Connect(function()
        self:SwitchTab("Output")
    end)
    
    GUI.SettingsTab.MouseButton1Click:Connect(function()
        self:SwitchTab("Settings")
    end)
    
    -- Window controls
    GUI.CloseButton.MouseButton1Click:Connect(function()
        -- Animate close
        TweenService:Create(GUI.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        GUI.MainFrame.Visible = false
    end)
    
    GUI.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleGUI()
    end)
    
    -- Button hover effects
    local function addHoverEffect(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = hoverColor
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = normalColor
            }):Play()
        end)
    end
    
    addHoverEffect(GUI.CloseButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 120, 120))
    addHoverEffect(GUI.MinimizeButton, Color3.fromRGB(255, 200, 100), Color3.fromRGB(255, 220, 120))
    
    -- Keybind toggles
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Settings.Keybind then
            self:ToggleGUI()
        elseif input.KeyCode == Settings.FadeKeybind then
            self:FadeGUI()
        end
    end)
    
    -- Character respawn handler
    Player.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to fully load
        self:UpdateCharacter()
        
        -- Reset states
        States.FlyEnabled = false
        States.NoClipEnabled = false
        
        if States.FlyConnection then
            States.FlyConnection:Disconnect()
            States.FlyConnection = nil
        end
        
        if States.NoClipConnection then
            States.NoClipConnection:Disconnect()
            States.NoClipConnection = nil
        end
        
        self:AddOutput("Character respawned - states reset", Color3.fromRGB(255, 255, 100))
        
        -- Refresh UI
        self:PopulateCommandsList()
        self:PopulateCategories()
    end)
end

-- Create and return library instance
local Library = setmetatable({}, CommandLibrary)

-- Auto-initialize only if not already loaded
if not _G.CommandLibraryLoaded then
    spawn(function()
        Library:Initialize()
    end)
else
    -- Return existing instance if already loaded
    return _G.CommandLibraryInstance
end

return Library
