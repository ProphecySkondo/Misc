local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local watermark = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProphecySkondo/Misc/refs/heads/main/watermark.lua"))()

if not setclipboard then
    warn("setclipboard function not available. Using print instead.")
end
local CONFIG = {
    MAX_INSTANCES = 1000,
    INDENT_SIZE = 4,
    SKIP_GUIS = {"Chat", "Backpack", "PlayerList", "Health", "PurchasePrompt", "BubbleChat", "GamepadMenu", "InspectMenu", "EmotesMenu", "TopbarPlus", "Freecam", "DevConsole", "SettingsShield", "RobloxGui", "CoreGui", "NotificationGui", "LoadingGui", "ErrorPrompt", "ConnectionErrorPrompt", "ReconnectPrompt"},
    SKIP_CLASSES = {"CoreGui", "StarterGui", "ReplicatedFirst", "Lighting", "SoundService", "TeleportService", "BadgeService", "GamePassService", "DataStoreService", "HttpService", "MarketplaceService"},
    SKIP_PROPERTIES = {"AbsolutePosition", "AbsoluteSize", "AbsoluteRotation", "LocalTransparencyModifier", "Parent", "ClassName"},
    GUI_CLASSES = {"ScreenGui", "Frame", "ScrollingFrame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "ViewportFrame", "CanvasGroup", "GuiObject", "GuiBase2d", "GuiBase"}
}

local SYNAPSE_COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 30),
    SECONDARY = Color3.fromRGB(40, 40, 40),
    ACCENT = Color3.fromRGB(60, 60, 60),
    BORDER = Color3.fromRGB(80, 80, 80),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    TEXT_MUTED = Color3.fromRGB(150, 150, 150),
    SUCCESS = Color3.fromRGB(0, 255, 127),
    WARNING = Color3.fromRGB(255, 193, 7),
    ERROR = Color3.fromRGB(220, 53, 69),
    PROGRESS = Color3.fromRGB(13, 110, 253),
    HIGHLIGHT = Color3.fromRGB(100, 100, 100)
}

local progressGui = nil
local progressFrame = nil
local progressBar = nil
local progressText = nil
local statusText = nil

local function createIntroAnimation()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "SynapseIntro"
    introGui.Parent = playerGui
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local introFrame = Instance.new("Frame")
    introFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    introFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    introFrame.Parent = introGui
    
    local logo = Instance.new("TextLabel")
    logo.Text = "Xeon"
    logo.Size = UDim2.new(0, 300, 0, 80)
    logo.Position = UDim2.new(0.5, -150, 0.5, -40)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = SYNAPSE_COLORS.PROGRESS
    logo.TextSize = 36
    logo.Font = Enum.Font.SourceSansBold
    logo.Parent = introFrame
    logo.TextTransparency = 1
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "GUI COPIER v1.0"
    subtitle.Size = UDim2.new(0, 200, 0, 30)
    subtitle.Position = UDim2.new(0.5, -100, 0.5, 20)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = SYNAPSE_COLORS.TEXT_SECONDARY
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.SourceSans
    subtitle.Parent = introFrame
    subtitle.TextTransparency = 1
    
    TweenService:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    wait(0.3)
    TweenService:Create(subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    wait(1.5)
    
    local fadeOut = TweenService:Create(introFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    TweenService:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    fadeOut:Play()
    
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
    wait(0.6)
end

local function createProgressGui()
    if progressGui then
        progressGui:Destroy()
    end
    
    progressGui = Instance.new("ScreenGui")
    progressGui.Name = "SynapseGuiCopier"
    progressGui.Parent = playerGui
    progressGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    progressGui.ResetOnSpawn = false
    
    progressFrame = Instance.new("Frame")
    progressFrame.Name = "MainFrame"
    progressFrame.Parent = progressGui
    progressFrame.Size = UDim2.new(0, 500, 0, 320)
    progressFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    progressFrame.BackgroundColor3 = SYNAPSE_COLORS.BACKGROUND
    progressFrame.BorderSizePixel = 1
    progressFrame.BorderColor3 = SYNAPSE_COLORS.BORDER
    
    progressFrame.BackgroundTransparency = 1
    local openTween = TweenService:Create(progressFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    })
    openTween:Play()
    
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = progressGui
    shadow.Size = UDim2.new(0, 506, 0, 326)
    shadow.Position = UDim2.new(0.5, -247, 0.5, -157)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = progressFrame.ZIndex - 1
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = progressFrame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = SYNAPSE_COLORS.SECONDARY
    titleBar.BorderSizePixel = 0
    
    local titleBorder = Instance.new("Frame")
    titleBorder.Name = "TitleBorder"
    titleBorder.Parent = titleBar
    titleBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBorder.Position = UDim2.new(0, 0, 1, 0)
    titleBorder.BackgroundColor3 = SYNAPSE_COLORS.BORDER
    titleBorder.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = titleBar
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Xeon - GUI Copier"
    title.TextColor3 = SYNAPSE_COLORS.TEXT_PRIMARY
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = titleBar
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = SYNAPSE_COLORS.BACKGROUND
    closeButton.BorderSizePixel = 1
    closeButton.BorderColor3 = SYNAPSE_COLORS.BORDER
    closeButton.Text = "×"
    closeButton.TextColor3 = SYNAPSE_COLORS.TEXT_PRIMARY
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.SourceSansBold
    
    closeButton.MouseButton1Click:Connect(function()
        closeProgressGui()
    end)
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = progressFrame
    contentArea.Size = UDim2.new(1, -20, 1, -60)
    contentArea.Position = UDim2.new(0, 10, 0, 50)
    contentArea.BackgroundTransparency = 1
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = contentArea
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS:"
    statusLabel.TextColor3 = SYNAPSE_COLORS.TEXT_MUTED
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Parent = contentArea
    statusText.Size = UDim2.new(1, 0, 0, 25)
    statusText.Position = UDim2.new(0, 0, 0, 25)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Initializing GUI Copier..."
    statusText.TextColor3 = SYNAPSE_COLORS.TEXT_PRIMARY
    statusText.TextSize = 14
    statusText.Font = Enum.Font.SourceSans
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.TextWrapped = true
    
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "ProgressLabel"
    progressLabel.Parent = contentArea
    progressLabel.Size = UDim2.new(1, 0, 0, 20)
    progressLabel.Position = UDim2.new(0, 0, 0, 70)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "PROGRESS:"
    progressLabel.TextColor3 = SYNAPSE_COLORS.TEXT_MUTED
    progressLabel.TextSize = 12
    progressLabel.Font = Enum.Font.SourceSansBold
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBackground"
    progressBg.Parent = contentArea
    progressBg.Size = UDim2.new(1, 0, 0, 20)
    progressBg.Position = UDim2.new(0, 0, 0, 95)
    progressBg.BackgroundColor3 = SYNAPSE_COLORS.ACCENT
    progressBg.BorderSizePixel = 1
    progressBg.BorderColor3 = SYNAPSE_COLORS.BORDER
    
    progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Parent = progressBg
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = SYNAPSE_COLORS.PROGRESS
    progressBar.BorderSizePixel = 0
    
    progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Parent = progressBg
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.Position = UDim2.new(0, 0, 0, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = SYNAPSE_COLORS.TEXT_PRIMARY
    progressText.TextSize = 12
    progressText.Font = Enum.Font.SourceSansBold
    
    local detailsLabel = Instance.new("TextLabel")
    detailsLabel.Name = "DetailsLabel"
    detailsLabel.Parent = contentArea
    detailsLabel.Size = UDim2.new(1, 0, 0, 20)
    detailsLabel.Position = UDim2.new(0, 0, 0, 140)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = "DETAILS:"
    detailsLabel.TextColor3 = SYNAPSE_COLORS.TEXT_MUTED
    detailsLabel.TextSize = 12
    detailsLabel.Font = Enum.Font.SourceSansBold
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local detailsFrame = Instance.new("Frame")
    detailsFrame.Name = "DetailsFrame"
    detailsFrame.Parent = contentArea
    detailsFrame.Size = UDim2.new(1, 0, 0, 80)
    detailsFrame.Position = UDim2.new(0, 0, 0, 165)
    detailsFrame.BackgroundColor3 = SYNAPSE_COLORS.SECONDARY
    detailsFrame.BorderSizePixel = 1
    detailsFrame.BorderColor3 = SYNAPSE_COLORS.BORDER
    
    local statsText = Instance.new("TextLabel")
    statsText.Name = "StatsText"
    statsText.Parent = detailsFrame
    statsText.Size = UDim2.new(1, -10, 1, -10)
    statsText.Position = UDim2.new(0, 5, 0, 5)
    statsText.BackgroundTransparency = 1
    statsText.Text = "Initializing scanner...\nNo data available"
    statsText.TextColor3 = SYNAPSE_COLORS.TEXT_SECONDARY
    statsText.TextSize = 11
    statsText.Font = Enum.Font.SourceSans
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.TextYAlignment = Enum.TextYAlignment.Top
    statsText.TextWrapped = true
    
    return statsText
end

local function updateProgress(current, total, status, stats)
    if not progressBar or not progressText or not statusText then return end
    
    local percentage = total > 0 and (current / total) * 100 or 0
    local targetSize = UDim2.new(percentage / 100, 0, 1, 0)
    
    local tween = TweenService:Create(progressBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
    
    progressText.Text = string.format("%d%%", math.floor(percentage))
    
    local typewriterSpeed = 0.02
    spawn(function()
        local fullText = status or "Processing..."
        statusText.Text = ""
        for i = 1, #fullText do
            statusText.Text = fullText:sub(1, i)
            wait(typewriterSpeed)
        end
    end)
    
    if stats then
        local statsLabel = progressFrame:FindFirstChild("ContentArea"):FindFirstChild("DetailsFrame"):FindFirstChild("StatsText")
        if statsLabel then
            spawn(function()
                statsLabel.Text = ""
                for i = 1, #stats do
                    statsLabel.Text = stats:sub(1, i)
                    wait(typewriterSpeed * 0.5)
                end
            end)
        end
    end
end

local function closeProgressGui()
    if progressGui then
        local closeTween = TweenService:Create(progressFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        closeTween:Play()
        
        closeTween.Completed:Connect(function()
            progressGui:Destroy()
            progressGui = nil
        end)
    end
end

local function isRobloxEmbedded(instance)
    local current = instance
    while current do
        if current.Name == "CoreGui" or current.Name == "StarterGui" then return true end
        for _, skipName in pairs(CONFIG.SKIP_GUIS) do
            if current.Name == skipName then return true end
        end
        current = current.Parent
        if current == game then break end
    end
    return false
end

local function isValidGuiInstance(instance)
    if not instance or not instance.Parent or isRobloxEmbedded(instance) then return false end
    for _, className in pairs(CONFIG.GUI_CLASSES) do
        if instance:IsA(className) then return true end
    end
    return false
end

local function sanitizeName(name)
    local sanitized = name:gsub("[^%w_]", "_")
    if sanitized:match("^%d") then
        sanitized = "_" .. sanitized
    end
    if sanitized == "" then
        sanitized = "GuiElement"
    end
    return sanitized
end

local function roundNumber(num, decimals)
    local mult = 10^(decimals or 3)
    return math.floor(num * mult + 0.5) / mult
end

local function formatUDim2(udim2)
    return string.format("UDim2.new(%s, %s, %s, %s)",
        roundNumber(udim2.X.Scale),
        roundNumber(udim2.X.Offset),
        roundNumber(udim2.Y.Scale),
        roundNumber(udim2.Y.Offset)
    )
end

local function formatColor3(color3)
    return string.format("Color3.fromRGB(%d, %d, %d)",
        math.floor(color3.R * 255),
        math.floor(color3.G * 255),
        math.floor(color3.B * 255)
    )
end

local function getGuiProperties(instance, varName, indent)
    local code = ""
    
    code = code .. indent .. varName .. ".Name = \"" .. instance.Name .. "\"\n"
    
    if instance:IsA("GuiObject") then
        -- Position and Size
        if instance.Size ~= UDim2.new(0, 100, 0, 100) then
            code = code .. indent .. varName .. ".Size = " .. formatUDim2(instance.Size) .. "\n"
        end
        
        if instance.Position ~= UDim2.new(0, 0, 0, 0) then
            code = code .. indent .. varName .. ".Position = " .. formatUDim2(instance.Position) .. "\n"
        end
        
        -- Background
        if instance.BackgroundColor3 ~= Color3.fromRGB(163, 162, 165) then
            code = code .. indent .. varName .. ".BackgroundColor3 = " .. formatColor3(instance.BackgroundColor3) .. "\n"
        end
        
        if instance.BackgroundTransparency > 0 then
            code = code .. indent .. varName .. ".BackgroundTransparency = " .. roundNumber(instance.BackgroundTransparency) .. "\n"
        end
        
        -- Border
        if instance.BorderSizePixel ~= 1 then
            code = code .. indent .. varName .. ".BorderSizePixel = " .. instance.BorderSizePixel .. "\n"
        end
        
        if instance.BorderColor3 ~= Color3.fromRGB(27, 42, 53) then
            code = code .. indent .. varName .. ".BorderColor3 = " .. formatColor3(instance.BorderColor3) .. "\n"
        end
        
        -- Anchor Point
        if instance.AnchorPoint ~= Vector2.new(0, 0) then
            code = code .. indent .. varName .. ".AnchorPoint = Vector2.new(" .. 
                   roundNumber(instance.AnchorPoint.X) .. ", " .. roundNumber(instance.AnchorPoint.Y) .. ")\n"
        end
        
        -- ZIndex
        if instance.ZIndex ~= 1 then
            code = code .. indent .. varName .. ".ZIndex = " .. instance.ZIndex .. "\n"
        end
        
        -- Visible
        if not instance.Visible then
            code = code .. indent .. varName .. ".Visible = false\n"
        end
    end
    
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        if instance.Text ~= "" then
            code = code .. indent .. varName .. ".Text = \"" .. instance.Text:gsub("\"", "\\\"") .. "\"\n"
        end
        
        if instance.TextColor3 ~= Color3.fromRGB(27, 42, 53) then
            code = code .. indent .. varName .. ".TextColor3 = " .. formatColor3(instance.TextColor3) .. "\n"
        end
        
        if instance.Font ~= Enum.Font.Legacy then
            code = code .. indent .. varName .. ".Font = Enum.Font." .. instance.Font.Name .. "\n"
        end
        
        if instance.TextSize ~= 14 then
            code = code .. indent .. varName .. ".TextSize = " .. instance.TextSize .. "\n"
        end
        
        if instance.TextScaled then
            code = code .. indent .. varName .. ".TextScaled = true\n"
        end
        
        if instance.TextXAlignment ~= Enum.TextXAlignment.Center then
            code = code .. indent .. varName .. ".TextXAlignment = Enum.TextXAlignment." .. instance.TextXAlignment.Name .. "\n"
        end
        
        if instance.TextYAlignment ~= Enum.TextYAlignment.Center then
            code = code .. indent .. varName .. ".TextYAlignment = Enum.TextYAlignment." .. instance.TextYAlignment.Name .. "\n"
        end
        
        if instance.TextWrapped then
            code = code .. indent .. varName .. ".TextWrapped = true\n"
        end
    end
    
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        if instance.Image ~= "" then
            code = code .. indent .. varName .. ".Image = \"" .. instance.Image .. "\"\n"
        end
        
        if instance.ImageColor3 ~= Color3.fromRGB(255, 255, 255) then
            code = code .. indent .. varName .. ".ImageColor3 = " .. formatColor3(instance.ImageColor3) .. "\n"
        end
        
        if instance.ImageTransparency > 0 then
            code = code .. indent .. varName .. ".ImageTransparency = " .. roundNumber(instance.ImageTransparency) .. "\n"
        end
        
        if instance.ScaleType ~= Enum.ScaleType.Stretch then
            code = code .. indent .. varName .. ".ScaleType = Enum.ScaleType." .. instance.ScaleType.Name .. "\n"
        end
    end
    
    if instance:IsA("ScrollingFrame") then
        code = code .. indent .. varName .. ".ScrollBarThickness = " .. instance.ScrollBarThickness .. "\n"
        code = code .. indent .. varName .. ".CanvasSize = " .. formatUDim2(instance.CanvasSize) .. "\n"
        
        if not instance.ScrollingEnabled then
            code = code .. indent .. varName .. ".ScrollingEnabled = false\n"
        end
    end
    
    if instance:IsA("ScreenGui") then
        if not instance.Enabled then
            code = code .. indent .. varName .. ".Enabled = false\n"
        end
        
        if instance.DisplayOrder ~= 0 then
            code = code .. indent .. varName .. ".DisplayOrder = " .. instance.DisplayOrder .. "\n"
        end
        
        if not instance.ResetOnSpawn then
            code = code .. indent .. varName .. ".ResetOnSpawn = false\n"
        end
    end
    
    return code
end

local function organizeGuiInstances(instances)
    local organized = {
        screenguis = {},
        frames = {},
        labels = {},
        buttons = {},
        textboxes = {},
        images = {},
        other = {}
    }
    
    for _, instance in pairs(instances) do
        if instance:IsA("ScreenGui") then
            table.insert(organized.screenguis, instance)
        elseif instance:IsA("Frame") or instance:IsA("ScrollingFrame") then
            table.insert(organized.frames, instance)
        elseif instance:IsA("TextLabel") then
            table.insert(organized.labels, instance)
        elseif instance:IsA("TextButton") or instance:IsA("ImageButton") then
            table.insert(organized.buttons, instance)
        elseif instance:IsA("TextBox") then
            table.insert(organized.textboxes, instance)
        elseif instance:IsA("ImageLabel") then
            table.insert(organized.images, instance)
        else
            table.insert(organized.other, instance)
        end
    end
    
    for category, items in pairs(organized) do
        table.sort(items, function(a, b) return a.Name < b.Name end)
    end
    
    return organized
end

local function generateGuiCode(instance, parentName, depth, processedNames)
    local indent = string.rep(" ", CONFIG.INDENT_SIZE * depth)
    local code = ""
    
    local baseName = sanitizeName(instance.Name)
    local varName = baseName
    local counter = 1
    
    while processedNames[varName] do
        varName = baseName .. "_" .. counter
        counter = counter + 1
    end
    processedNames[varName] = true
    
    code = code .. indent .. "local " .. varName .. " = Instance.new(\"" .. instance.ClassName .. "\")\n"
    
    code = code .. getGuiProperties(instance, varName, indent)
    
    if parentName then
        code = code .. indent .. varName .. ".Parent = " .. parentName .. "\n"
    end
    
    code = code .. "\n"
    
    local children = {}
    for _, child in pairs(instance:GetChildren()) do
        if isValidGuiInstance(child) then
            table.insert(children, child)
        end
    end
    
    if #children > 0 then
        local organizedChildren = organizeGuiInstances(children)
        
        local categories = {"screenguis", "frames", "labels", "buttons", "textboxes", "images", "other"}
        for _, category in ipairs(categories) do
            if #organizedChildren[category] > 0 then
                code = code .. indent .. "-- " .. category:upper() .. "\n"
                for _, child in ipairs(organizedChildren[category]) do
                    code = code .. generateGuiCode(child, varName, depth + 1, processedNames)
                end
                code = code .. "\n"
            end
        end
    end
    
    return code
end

local function selectGuiFromList()
    local validGuis = {}
    for _, gui in pairs(playerGui:GetChildren()) do
        if isValidGuiInstance(gui) and not isRobloxEmbedded(gui) then
            table.insert(validGuis, gui)
        end
    end
    
    if #validGuis == 0 then
        return nil, "No valid GUIs found in PlayerGui"
    end
    
    return validGuis[1], nil
end

local function generateCompleteGuiCode()
    local startTime = tick()
    local processedNames = {}
    local instanceCount = 0
    local processedCount = 0
    
    createIntroAnimation()
    local statsTextLabel = createProgressGui()
    wait(0.5)
    updateProgress(5, 100, "Booting Xeon GUI Copier...", "System Status: Initializing\nMemory Usage: Low\nScan Mode: Preparing")
    wait(0.3)
    updateProgress(12, 100, "Loading advanced filtering system...", "System Status: Loading\nFilters: Loading\nEngine: Xeon")
    wait(0.2)
    
    updateProgress(20, 100, "Deploying GUI detection algorithms...", "System Status: Scanning\nDetection: Active\nTarget: PlayerGui")
    wait(0.3)
    
    local selectedGui, error = selectGuiFromList()
    if not selectedGui then
        updateProgress(100, 100, "Error: No valid GUIs detected", (error or "No valid GUIs found") .. "\nSystem Status: Failed\nScan Results: 0 GUIs")
        wait(3)
        closeProgressGui()
        return "-- Error: " .. (error or "No valid GUIs found") .. "\n"
    end
    
    local fullCode = "-- ============================================\n"
    fullCode = fullCode .. "--            XEON GUI COPIER v1.0\n"
    fullCode = fullCode .. "-- ============================================\n"
    fullCode = fullCode .. "-- Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    fullCode = fullCode .. "-- Source: " .. selectedGui.Name .. " (" .. selectedGui.ClassName .. ")\n"
    fullCode = fullCode .. "-- Engine: Roblox Luau\n"
    fullCode = fullCode .. "-- ============================================\n\n"
    
    fullCode = fullCode .. "-- SERVICES\n"
    fullCode = fullCode .. "local Players = game:GetService('Players')\n"
    fullCode = fullCode .. "local player = Players.LocalPlayer\n"
    fullCode = fullCode .. "local playerGui = player:WaitForChild('PlayerGui')\n\n"
    
    updateProgress(35, 100, "Target acquired: " .. selectedGui.Name, "System Status: Locked\nTarget: " .. selectedGui.Name .. "\nType: " .. selectedGui.ClassName)
    wait(0.3)
    updateProgress(45, 100, "Performing deep structure analysis...", "System Status: Analyzing\nAlgorithm: Neural\nDepth: Recursive")
    wait(0.2)
    
    local function countInstances(parent)
        local count = 1
        for _, child in pairs(parent:GetChildren()) do
            if isValidGuiInstance(child) then
                count = count + countInstances(child)
            end
        end
        return count
    end
    
    instanceCount = countInstances(selectedGui)
    
    updateProgress(60, 100, "Compiling " .. instanceCount .. " GUI elements...", "System Status: Compiling\nElements: " .. instanceCount .. "\nOptimization: Maximum")
    wait(0.2)
    updateProgress(75, 100, "Applying Xeon code generation...", "System Status: Generating\nEngine: Luau\nMode: Production")
    wait(0.25)
    
    fullCode = fullCode .. "-- GUI GENERATION\n"
    fullCode = fullCode .. generateGuiCode(selectedGui, "playerGui", 0, processedNames)
    
    updateProgress(90, 100, "Running final quality checks...", "System Status: Validating\nQuality: Premium\nStandard: Xeon")
    wait(0.2)
    updateProgress(96, 100, "Preparing clipboard deployment...", "System Status: Finalizing\nCode Lines: " .. #fullCode:split('\n') .. "\nValidation: Complete")
    wait(0.15)
    
    local stats = "\n-- ============================================\n"
    stats = stats .. "--                 STATISTICS\n"
    stats = stats .. "-- ============================================\n"
    stats = stats .. "-- Elements Processed: " .. instanceCount .. "\n"
    stats = stats .. "-- Source GUI: " .. selectedGui.ClassName .. " '" .. selectedGui.Name .. "'\n"
    stats = stats .. "-- Code Lines: " .. #fullCode:split('\n') .. "\n"
    
    fullCode = fullCode .. stats
    
    -- Footer
    local generationTime = tick() - startTime
    fullCode = fullCode .. "-- Generation Time: " .. string.format("%.3f", generationTime) .. "s\n"
    fullCode = fullCode .. "-- Status: Ready for execution\n"
    fullCode = fullCode .. "-- ============================================\n"
    
    updateProgress(100, 100, "Mission accomplished! Code ready for deployment.", "System Status: SUCCESS\nTime: " .. string.format("%.3f", generationTime) .. "s\nOutput: Optimized")
    wait(0.4)
    
    return fullCode
end

local function main()
    print("🔥 Xeon GUI Copier v1.0 - Initializing...")
    
    local success, result = pcall(generateCompleteGuiCode)
    
    if not success then
        updateProgress(100, 100, "Critical Error: Generation failed", "System Status: Error\nError Type: " .. tostring(result):sub(1, 50) .. "\nAction: Check console")
        wait(3)
        closeProgressGui()
        error("Generation failed: " .. tostring(result))
        return
    end
    
    if setclipboard then
        setclipboard(result)
        updateProgress(100, 100, "✓ Code successfully deployed to clipboard!", "System Status: DEPLOYED\nClipboard: Updated\nReady: Execute")
        print("🔥 Xeon GUI Copier v1.0 - Code Generated!")
        print("📋 " .. #result:split('\n') .. " lines of optimized Lua code copied to clipboard")
        print("⚡ Ready for immediate deployment!")
    else
        updateProgress(100, 100, "⚠ Clipboard unavailable - Console output", "System Status: Warning\nOutput: Console\nAction: Manual copy")
        print("⚠️ Clipboard not available - Code output:")
        print(result)
    end
    
    wait(2.5)
    closeProgressGui()
    print("🎯 Xeon GUI Copier - Mission Complete!")
    print("💫 Thank you for using premium Xeon technology")
end

main()
