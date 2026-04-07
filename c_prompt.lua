--# Created by sai
--# YT is https://www.youtube.com/@its-skondo for more scripts or my own shi https://saiscripts.vercel.app/

local loadedModules = {}

local loadedInstances = {}

local function newEnv(func, blacklist)
    blacklist = blacklist or {}
    
    local env = {
        VERSION = "1.1.1-dbg",
        game = game,
        workspace = workspace,
        Instance = Instance,
        Vector2 = Vector2,
        Vector3 = Vector3,
        CFrame = CFrame,
        UDim2 = UDim2,
        UDim = UDim,
        Color3 = Color3,
        Enum = Enum,
        task = task,
        print = print,
        warn = warn,
        error = error,
        tonumber = tonumber,
        tostring = tostring,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        select = select,
        getfenv = getfenv,
        setfenv = setfenv,
        require = require,
        loadstring = loadstring,
        pcall = pcall,
        xpcall = xpcall,
        math = math,
        table = table,
        string = string,
        coroutine = coroutine,
        debug = debug,
        tick = tick,
        os = os,
        gethui = gethui,
		setmetatable = setmetatable
    }
    
    for key, _ in pairs(blacklist) do
        env[key] = nil
    end
    
    return setmetatable(env, {
        __index = function(self, key)
            if blacklist[key] ~= nil then
                return nil
            end
            return getfenv(0)[key]
        end,
        __metatable = "This metatable is locked",
    })
end

local function import(_url: string, params)
    local url = _url
    if loadedModules[url] then return loadedModules[url] end
    
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok then warn("[import] Fetch failed:", url, code) return nil end
    
    local func, err = loadstring(code)
    if not func then warn("[import] Loadstring failed:", err) return nil end
    
    setfenv(func, newEnv(func, params))
    
    local ok2, result = pcall(func)
    if not ok2 then warn("[import] Execution failed:", result) return nil end
    
    loadedModules[url] = result
    return result
end

local function get_fallback_func(t, f, fallback)
	if type(f) == t then
		print("[+] " .. tostring(t) .. ": " .. tostring(f))
		return f
	end

	return fallback
end

local function getInstancePath(Inst: Instance)
	local success, result = pcall(function()
		local x: string = Inst.Name
		local current = Inst.Parent

		while current do
			x = tostring(current.Name) .. '/' .. x
			if current == game then break end
			current = current.Parent
		end

		return x
	end)

	if not success then
		if result then
			print("[-] Expected success on getInstancePath, got: " .. tostring(result))
			return result
		end
		return nil
	end

	if success then
		return result
	end
end	

local function newInstance(Name, Properties, Bool: boolean)
	local instance = Instance.new(Properties.className)
	local _debugid = instance:GetDebugId(10)
	instance.Name = Name
	instance.Parent = Properties.parent

	loadedInstances[Name] = {
		["Instance"] = instance,
		["Class"] = instance.ClassName,
		["Parent"] = instance.Parent,
		["DebugId"] = _debugid,
		["Path"] = getInstancePath(instance)
	}

	if Bool then
		return instance
	end
end

local function getInstance(Identifier)
    for Name, data in pairs(loadedInstances) do
        if Name == Identifier or data["DebugId"] == Identifier then
            return data["Instance"]
        end
    end
    return nil
end

local Commands = {
    ["Fly"] = function() import("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt", { -- * I was to lazy to check what was inside of it so I just disabled request and setfenv get fenv and loadstring :>
            request = true,
            loadstring = true,
            getfenv = true,
            setfenv = true,
        })
    end
}

local Services = import("https://raw.githubusercontent.com/ProphecySkondo/Modules/refs/heads/main/Services.lua", {})

local CoreGui = Services.CoreGui
local Players = Services.Players
local UserInputService = Services.UserInputService

local secure_gui = get_fallback_func("function", get_hidden_gui or gethui or function()
	if getInstance("RobloxInternalFunctions") then
		return getInstance("RobloxInternalFunctions")
	end

	local Protected = newInstance("RobloxInternalFunctions", {
		className = "Folder",
		parent = CoreGui
	}, true)

	return Protected
end)

local Microsoft = [[Microsoft Windows [Version %s]\n(c) Microsoft Corporation. All rights reserved.]]
local User = [[C:\Users\%s]]

local Gui = newInstance("Microsoft", {className = "ScreenGui", parent = secure_gui()}, true)
local Frame = newInstance("CmdFrame", {className = "Frame", parent = Gui}, true)
local Output = newInstance("Output", {className = "ScrollingFrame", parent = Frame}, true)
local InputBox = newInstance("InputBox", {className = "TextBox", parent = Frame}, true)
local TitleBar = newInstance("TitleBar", {className = "Frame", parent = Frame}, true)
local TitleLabel = newInstance("TitleLabel", {className = "TextLabel", parent = TitleBar}, true)

local _username = game.Players.LocalPlayer.Name
local _version = "10.0.19045.6093"

local function guiEdits(Params)
	local BG = Color3.fromRGB(table.unpack(Params.BG))
	local TitleBG = Color3.fromRGB(table.unpack(Params.TitleBG))
	local TextCol = Color3.fromRGB(table.unpack(Params.TextCol))
	local InputText = Color3.fromRGB(255, 255, 255)

	Frame.Size = UDim2.new(0, 600, 0, 350)
	Frame.Position = UDim2.new(0.5, -300, 0.5, -175)
	Frame.BackgroundColor3 = BG
	Frame.BorderSizePixel = 0
	Frame.Active = true
	Frame.Draggable = true

	TitleBar.Size = UDim2.new(1, 0, 0, 30)
	TitleBar.Position = UDim2.new(0, 0, 0, 0)
	TitleBar.BackgroundColor3 = TitleBG
	TitleBar.BorderSizePixel = 0

	TitleLabel.Size = UDim2.new(1, -138, 1, 0)
	TitleLabel.Position = UDim2.new(0, 36, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Command Prompt"
	TitleLabel.TextColor3 = TextCol
	TitleLabel.TextSize = 13
	TitleLabel.Font = Enum.Font.Code
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	Output.Size = UDim2.new(1, 0, 1, -56)
	Output.Position = UDim2.new(0, 0, 0, 30)
	Output.BackgroundTransparency = 1
	Output.BorderSizePixel = 0
	Output.ScrollBarThickness = 4
	Output.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	Output.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Output.CanvasSize = UDim2.new(0, 0, 0, 0)

	local OutputLayout = Instance.new("UIListLayout")
	OutputLayout.Parent = Output
	OutputLayout.SortOrder = Enum.SortOrder.LayoutOrder
	OutputLayout.Padding = UDim.new(0, 0)

	local OutputPadding = Instance.new("UIPadding")
	OutputPadding.Parent = Output
	OutputPadding.PaddingLeft = UDim.new(0, 8)
	OutputPadding.PaddingTop = UDim.new(0, 4)

	InputBox.Size = UDim2.new(1, -8, 0, 22)
	InputBox.Position = UDim2.new(0, 8, 1, -26)
	InputBox.BackgroundTransparency = 1
	InputBox.BorderSizePixel = 0
	InputBox.Text = ""
	InputBox.PlaceholderText = ""
	InputBox.TextColor3 = InputText
	InputBox.TextSize = 14
	InputBox.Font = Enum.Font.Code
	InputBox.TextXAlignment = Enum.TextXAlignment.Left
	InputBox.ClearTextOnFocus = false
end

local function makeTitleBtn(Symbol, XOffset, HoverColor, Callback)
	local Btn = Instance.new("TextButton")
	Btn.Parent = TitleBar
	Btn.Size = UDim2.new(0, 46, 1, 0)
	Btn.Position = UDim2.new(1, XOffset, 0, 0)
	Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Btn.BorderSizePixel = 0
	Btn.Text = Symbol
	Btn.TextColor3 = Color3.fromRGB(12, 12, 12)
	Btn.TextSize = 13
	Btn.Font = Enum.Font.Code

	Btn.MouseEnter:Connect(function()
		Btn.BackgroundColor3 = HoverColor
	end)
	Btn.MouseLeave:Connect(function()
		Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end)
	Btn.MouseButton1Click:Connect(Callback)
end

local function addLine(Text, Color)
	local Line = Instance.new("TextLabel")
	Line.Parent = Output
	Line.Size = UDim2.new(1, 0, 0, 18)
	Line.AutomaticSize = Enum.AutomaticSize.Y
	Line.BackgroundTransparency = 1
	Line.Text = Text
	Line.TextColor3 = Color or Color3.fromRGB(204, 204, 204)
	Line.TextSize = 14
	Line.Font = Enum.Font.Code
	Line.TextXAlignment = Enum.TextXAlignment.Left
	Line.TextWrapped = true
end

local function scrollToBottom()
	Output.CanvasPosition = Vector2.new(0, math.huge)
end

local function getPrompt()
	return (User:format(_username)) .. ">"
end

guiEdits {
	BG = {12, 12, 12},
	TitleBG = {255, 255, 255},
	TextCol = {12, 12, 12},
}

makeTitleBtn("✕", -46, Color3.fromRGB(12, 12, 12), function() Gui:Destroy() end)
makeTitleBtn("□", -92, Color3.fromRGB(12, 12, 12), function() Frame.Size = UDim2.new(0, 1000, 0, 700) end)
makeTitleBtn("–", -138, Color3.fromRGB(12, 12, 12), function() Frame.Size = UDim2.new(0, 600, 0, 350) end)

do
    local HeaderText = Microsoft:format(_version):gsub("\\n", "\n")
    for _, Line in ipairs(string.split(HeaderText, "\n")) do
	    addLine(Line)
    end
    addLine("")
    addLine(getPrompt())
end

local history = {}
local historyIndex = 0

local function runCommand(Cmd)
	Cmd = Cmd:match("^%s*(.-)%s*$")

	local Lines = Output:GetChildren()
	local LastLine = Lines[#Lines]
	if LastLine and LastLine:IsA("TextLabel") then
		LastLine.Text = getPrompt() .. Cmd
	end

	if Cmd == "ipv4" then
		local response = request({
    		Url = "https://httpbin.org/get",
    		Method = "GET"
		})

		local data = game:GetService("HttpService"):JSONDecode(response.Body)
		addLine(data.origin)
	elseif Cmd:lower() == "cls" then
		for _, Child in ipairs(Output:GetChildren()) do
			if Child:IsA("TextLabel") then Child:Destroy() end
		end

	elseif Cmd:lower() == "exit" then
		Gui:Destroy()
		return

	elseif Cmd:lower() == "help" then
		addLine("cls        Clears the screen.")
		addLine("exit       Quits CMD.")
		addLine("echo [msg] Prints a message.")
		addLine("ver        Displays Windows version.")
		addLine("help       Shows this list.")

	elseif Cmd:lower():sub(1, 4) == "echo" then
		addLine(Cmd:sub(6))

	elseif Cmd:lower() == "ver" then
		addLine(("Microsoft Windows [Version %s]"):format(_version))
	else
		addLine("'" .. Cmd .. "' is not recognized as an internal or external command,", Color3.fromRGB(220, 80, 80))
		addLine("operable program or batch file.", Color3.fromRGB(220, 80, 80))
	end

	addLine("")
	addLine(getPrompt())
	scrollToBottom()
end

InputBox.FocusLost:Connect(function(EnterPressed)
	if EnterPressed then
		local Cmd = InputBox.Text
		table.insert(history, Cmd)
		historyIndex = #history + 1
		InputBox.Text = ""
		runCommand(Cmd)
	end
end)

UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE then return end
	if Input.KeyCode == Enum.KeyCode.Up then
		if historyIndex > 1 then
			historyIndex -= 1
			InputBox.Text = history[historyIndex] or ""
		end
	elseif Input.KeyCode == Enum.KeyCode.Down then
		if historyIndex < #history then
			historyIndex += 1
			InputBox.Text = history[historyIndex] or ""
		else
			historyIndex = #history + 1
			InputBox.Text = ""
		end
	end
end)

Frame.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		InputBox:CaptureFocus()
	end
end)

InputBox:CaptureFocus()
scrollToBottom()
