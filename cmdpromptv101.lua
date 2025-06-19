--[[ 
    script was made by skondoooo92
    discord https://discord.gg/4THYgrRQd3 
    site xeonhub.netlify.app
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Terminal = {}
Terminal.Commands = {}
Terminal.History = {}
Terminal.HistoryIndex = 0
Terminal.CurrentDirectory = "C:\\Users\\" .. LocalPlayer.Name

local function createTerminalGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Terminal"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "TerminalFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(128, 128, 128)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -75, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Command Prompt - " .. Terminal.CurrentDirectory
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -25, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(196, 43, 28)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = titleBar
    
    local outputFrame = Instance.new("ScrollingFrame")
    outputFrame.Name = "OutputFrame"
    outputFrame.Size = UDim2.new(1, -10, 1, -55)
    outputFrame.Position = UDim2.new(0, 5, 0, 30)
    outputFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    outputFrame.BorderSizePixel = 0
    outputFrame.ScrollBarThickness = 12
    outputFrame.ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128)
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputFrame.Parent = mainFrame
    
    local outputLayout = Instance.new("UIListLayout")
    outputLayout.SortOrder = Enum.SortOrder.LayoutOrder
    outputLayout.Padding = UDim.new(0, 0)
    outputLayout.Parent = outputFrame
    
    return screenGui, mainFrame, outputFrame, closeButton, titleLabel
end

local gui, mainFrame, outputFrame, closeButton, titleLabel = createTerminalGUI()

local currentInput = ""
local inputActive = false
local inputFocused = false
local cursorPosition = 0
local cursorVisible = true
local currentInputLine = nil

local function addOutput(text, color, isInput)
    color = color or Color3.fromRGB(255, 255, 255)
    local outputLabel = Instance.new("TextLabel")
    outputLabel.Size = UDim2.new(1, -10, 0, 16)
    outputLabel.BackgroundTransparency = 1
    outputLabel.Text = text
    outputLabel.TextColor3 = color
    outputLabel.TextSize = 14
    outputLabel.Font = Enum.Font.RobotoMono
    outputLabel.TextXAlignment = Enum.TextXAlignment.Left
    outputLabel.TextYAlignment = Enum.TextYAlignment.Top
    outputLabel.Parent = outputFrame
    
    local textService = game:GetService("TextService")
    local textSize = textService:GetTextSize(text, 14, Enum.Font.RobotoMono, Vector2.new(outputFrame.AbsoluteSize.X - 10, math.huge))
    outputLabel.Size = UDim2.new(1, -10, 0, math.max(16, textSize.Y))
    
    if isInput then
        currentInputLine = outputLabel
    end
    
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, outputFrame.UIListLayout.AbsoluteContentSize.Y)
    outputFrame.CanvasPosition = Vector2.new(0, outputFrame.CanvasSize.Y.Offset)
end

local function createInputLine()
    local promptText = Terminal.CurrentDirectory .. ">"
    addOutput(promptText, Color3.fromRGB(255, 255, 255), true)
    currentInput = ""
    cursorPosition = 0
    inputActive = true
    inputFocused = false
    
    if currentInputLine then
        local clickButton = Instance.new("TextButton")
        clickButton.Size = UDim2.new(1, 0, 1, 0)
        clickButton.Position = UDim2.new(0, 0, 0, 0)
        clickButton.BackgroundTransparency = 1
        clickButton.Text = ""
        clickButton.Parent = currentInputLine
        
        clickButton.MouseButton1Click:Connect(function()
            inputFocused = true
            updateInputDisplay()
        end)
    end
end

local function updateInputDisplay()
    if currentInputLine and inputActive then
        local promptText = Terminal.CurrentDirectory .. ">"
        local displayText = promptText .. currentInput
        
        if inputFocused and cursorVisible then
            if cursorPosition >= string.len(currentInput) then
                displayText = displayText .. "_"
            else
                displayText = string.sub(displayText, 1, string.len(promptText) + cursorPosition) .. "_" .. string.sub(displayText, string.len(promptText) + cursorPosition + 1)
            end
        end
        
        currentInputLine.Text = displayText
        
        if inputFocused then
            currentInputLine.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            currentInputLine.TextColor3 = Color3.fromRGB(128, 128, 128)
        end
    end
end

local function updateTitle()
    titleLabel.Text = "Command Prompt - " .. Terminal.CurrentDirectory
end

function Terminal:RegisterCommand(name, description, func)
    self.Commands[name:lower()] = {
        description = description,
        func = func
    }
end

-- Easy function to add commands
function addCmd(name, description, func)
    Terminal:RegisterCommand(name, description, func)
    print("Command '" .. name .. "' added successfully!")
end

function Terminal:ExecuteCommand(input)
    if input == "" then
        createInputLine()
        return
    end
    
    table.insert(self.History, input)
    self.HistoryIndex = #self.History + 1
    
    if currentInputLine then
        currentInputLine.Text = Terminal.CurrentDirectory .. ">" .. input
        inputActive = false
        inputFocused = false
    end
    
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then
        createInputLine()
        return
    end
    
    local commandName = args[1]:lower()
    table.remove(args, 1)
    
    if self.Commands[commandName] then
        local success, result = pcall(self.Commands[commandName].func, args)
        if not success then
            addOutput("Error executing command: " .. tostring(result), Color3.fromRGB(255, 100, 100))
        elseif result and result ~= "" then
            addOutput(tostring(result), Color3.fromRGB(255, 255, 255))
        end
    else
        addOutput("'" .. commandName .. "' is not recognized as an internal or external command,", Color3.fromRGB(255, 255, 255))
        addOutput("operable program or batch file.", Color3.fromRGB(255, 255, 255))
    end
    
    createInputLine()
end

local function getIP()
	local ok, res = pcall(function() return game:HttpGet("https://httpbin.org/get") end)
	if ok then
		local suc, d = pcall(function() return HttpService:JSONDecode(res) end)
		if suc and d then return d.origin end
	end
	return "Unavailable"
end

addCmd("help", "Shows available commands", function(args)
    addOutput("Available Commands:", Color3.fromRGB(100, 255, 100))
    addOutput("", Color3.fromRGB(255, 255, 255))
    
    for name, cmd in pairs(Terminal.Commands) do
        addOutput(string.upper(name) .. " - " .. cmd.description, Color3.fromRGB(255, 255, 255))
    end
    
    addOutput("", Color3.fromRGB(255, 255, 255))
    addOutput("Use 'addCmd(name, description, function)' to add new commands", Color3.fromRGB(100, 200, 255))
end)

addCmd("cls", "Clears the screen", function(args)
    for _, child in pairs(outputFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

addCmd("clear", "Clears the screen (Linux)", function(args)
    for _, child in pairs(outputFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

addCmd("echo", "Displays text", function(args)
    if #args == 0 then
        return "ECHO is on."
    end
    return table.concat(args, " ")
end)

addCmd("date", "Shows current date", function(args)
    return "The current date is: " .. os.date("%a %m/%d/%Y")
end)

addCmd("time", "Shows current time", function(args)
    return "The current time is: " .. os.date("%I:%M:%S %p")
end)

addCmd("ver", "Shows Windows version", function(args)
    return "Microsoft Windows [Version 10.0.19041.1234]"
end)

addCmd("whoami", "Shows current username", function(args)
    return "desktop-computer\\" .. LocalPlayer.Name
end)

addCmd("players", "Lists all players in the game", function(args)
    addOutput("Players in game:", Color3.fromRGB(100, 255, 100))
    for _, player in pairs(Players:GetPlayers()) do
        addOutput("  " .. player.Name .. " (ID: " .. player.UserId .. ")", Color3.fromRGB(255, 255, 255))
    end
end)

addCmd("baseplate", "tping to my baseplate", function(args)
    addOutput("Teleporting...", Color3.fromRGB(100, 255, 100))
    local tps = game:GetService("TeleportService")
    tps:Teleport(LocalPlayer, 77162174997541)
end)

addCmd("ipconfig", "Displays IP configuration", function(args)
    addOutput("", Color3.fromRGB(255, 255, 255))
    addOutput("Windows IP Configuration", Color3.fromRGB(255, 255, 255))
    addOutput("", Color3.fromRGB(255, 255, 255))
    addOutput("Ethernet adapter Ethernet:", Color3.fromRGB(255, 255, 255))
    addOutput("", Color3.fromRGB(255, 255, 255))
    addOutput("   Connection-specific DNS Suffix  . : home", Color3.fromRGB(255, 255, 255))
    addOutput("   IPv4 Address. . . . . . . . . . . : " .. getIP(), Color3.fromRGB(255, 255, 255))
    addOutput("   Subnet Mask . . . . . . . . . . . : ---", Color3.fromRGB(255, 255, 255))
    addOutput("   Default Gateway . . . . . . . . . : ---", Color3.fromRGB(255, 255, 255))
end)

addCmd("tp", "Teleport to a player", function(args)
    if not args[1] then
        return "Usage: tp <playername>"
    end
    
    local targetName = args[1]:lower()
    local targetPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName) then
            targetPlayer = player
            break
        end
    end
    
    if not targetPlayer then
        return "Player '" .. args[1] .. "' not found"
    end
    
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            return "Teleported to " .. targetPlayer.Name
        else
            return "Your character is not loaded"
        end
    else
        return targetPlayer.Name .. "'s character is not loaded"
    end
end)

spawn(function()
    while true do
        wait(0.5)
        if inputFocused then
            cursorVisible = not cursorVisible
            updateInputDisplay()
        else
            cursorVisible = false
            updateInputDisplay()
        end
    end
end)

local function handleTyping(inputObject)
    if not mainFrame.Visible or not inputActive or not inputFocused then
        return false
    end
    
    local keyCode = inputObject.KeyCode
    local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    local character = ""
    local keyValue = keyCode.Value
    
    if keyValue >= Enum.KeyCode.A.Value and keyValue <= Enum.KeyCode.Z.Value then
        local letter = string.char(keyValue - Enum.KeyCode.A.Value + 65)
        character = isShiftPressed and letter or string.lower(letter)
    elseif keyValue >= Enum.KeyCode.Zero.Value and keyValue <= Enum.KeyCode.Nine.Value then
        if isShiftPressed then
            local shiftChars = {")", "!", "@", "#", "$", "%", "^", "&", "*", "("}
            character = shiftChars[keyValue - Enum.KeyCode.Zero.Value + 1]
        else
            character = string.char(keyValue - Enum.KeyCode.Zero.Value + 48)
        end
    elseif keyCode == Enum.KeyCode.Space then
        character = " "
    elseif keyCode == Enum.KeyCode.Period then
        character = isShiftPressed and ">" or "."
    elseif keyCode == Enum.KeyCode.Comma then
        character = isShiftPressed and "<" or ","
    elseif keyCode == Enum.KeyCode.Slash then
        character = isShiftPressed and "?" or "/"
    elseif keyCode == Enum.KeyCode.Semicolon then
        character = isShiftPressed and ":" or ";"
    elseif keyCode == Enum.KeyCode.Quote then
        character = isShiftPressed and '"' or "'"
    elseif keyCode == Enum.KeyCode.LeftBracket then
        character = isShiftPressed and "{" or "["
    elseif keyCode == Enum.KeyCode.RightBracket then
        character = isShiftPressed and "}" or "]"
    elseif keyCode == Enum.KeyCode.BackSlash then
        character = isShiftPressed and "|" or "\\"
    elseif keyCode == Enum.KeyCode.Minus then
        character = isShiftPressed and "_" or "-"
    elseif keyCode == Enum.KeyCode.Equals then
        character = isShiftPressed and "+" or "="
    elseif keyCode == Enum.KeyCode.Backquote then
        character = isShiftPressed and "~" or "`"
    end
    
    if character ~= "" then
        currentInput = string.sub(currentInput, 1, cursorPosition) .. character .. string.sub(currentInput, cursorPosition + 1)
        cursorPosition = cursorPosition + 1
        updateInputDisplay()
        return true
    end
    
    return false
end

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    inputFocused = false
end)

local clickDetector = Instance.new("TextButton")
clickDetector.Size = UDim2.new(1, 0, 1, 0)
clickDetector.Position = UDim2.new(0, 0, 0, 0)
clickDetector.BackgroundTransparency = 1
clickDetector.Text = ""
clickDetector.ZIndex = -1
clickDetector.Parent = mainFrame

clickDetector.MouseButton1Click:Connect(function()
    if inputFocused then
        inputFocused = false
        updateInputDisplay()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F9 then
        mainFrame.Visible = not mainFrame.Visible
        if not mainFrame.Visible then
            inputFocused = false
        end
        return
    end
    
    if mainFrame.Visible and inputFocused then
        local handled = false
        
        if input.KeyCode == Enum.KeyCode.Return then
            Terminal:ExecuteCommand(currentInput)
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Backspace then
            if cursorPosition > 0 then
                currentInput = string.sub(currentInput, 1, cursorPosition - 1) .. string.sub(currentInput, cursorPosition + 1)
                cursorPosition = cursorPosition - 1
                updateInputDisplay()
            end
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Delete then
            if cursorPosition < string.len(currentInput) then
                currentInput = string.sub(currentInput, 1, cursorPosition) .. string.sub(currentInput, cursorPosition + 2)
                updateInputDisplay()
            end
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Left then
            if cursorPosition > 0 then
                cursorPosition = cursorPosition - 1
                updateInputDisplay()
            end
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Right then
            if cursorPosition < string.len(currentInput) then
                cursorPosition = cursorPosition + 1
                updateInputDisplay()
            end
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Home then
            cursorPosition = 0
            updateInputDisplay()
            handled = true
        elseif input.KeyCode == Enum.KeyCode.End then
            cursorPosition = string.len(currentInput)
            updateInputDisplay()
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Up then
            if Terminal.HistoryIndex > 1 then
                Terminal.HistoryIndex = Terminal.HistoryIndex - 1
                currentInput = Terminal.History[Terminal.HistoryIndex] or ""
                cursorPosition = string.len(currentInput)
                updateInputDisplay()
            end
            handled = true
        elseif input.KeyCode == Enum.KeyCode.Down then
            if Terminal.HistoryIndex < #Terminal.History then
                Terminal.HistoryIndex = Terminal.HistoryIndex + 1
                currentInput = Terminal.History[Terminal.HistoryIndex] or ""
                cursorPosition = string.len(currentInput)
                updateInputDisplay()
            else
                Terminal.HistoryIndex = #Terminal.History + 1
                currentInput = ""
                cursorPosition = 0
                updateInputDisplay()
            end
            handled = true
        else
            handled = handleTyping(input)
        end
        
        if handled then
            return
        end
    end
    
    if gameProcessed then return end
end)

local function initializeTerminal()
    addOutput("Microsoft Windows [Version 10.0.19041.1234]", Color3.fromRGB(255, 255, 255))
    addOutput("(c) Microsoft Corporation. All rights reserved.", Color3.fromRGB(255, 255, 255))
    addOutput("", Color3.fromRGB(255, 255, 255))
    addOutput("Type 'help' to see available commands", Color3.fromRGB(100, 200, 255))
    addOutput("Use 'addCmd(name, description, function)' to add new commands", Color3.fromRGB(100, 200, 255))
    addOutput("", Color3.fromRGB(255, 255, 255))
    updateTitle()
    createInputLine()
end

mainFrame.Visible = true
initializeTerminal()

print("Windows Command Prompt loaded! Press F9 to toggle.")
print("Use addCmd(name, description, function) to add new commands!")
