local function main()
    local Gui
    local Target: Instance
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
	  local VirtualUser = game:GetService("VirtualUser")
    local Client = Players.LocalPlayer
    local char = Client.Character or Client.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local Camera = workspace.CurrentCamera; do
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function(x)
            Camera = x or workspace.CurrentCamera
        end)
    end
    local fieldofview = function(num: number)
        Camera.FieldOfView = tonumber(num)
    end
    Gui = Instance.new("ScreenGui")
    Gui.Parent = gethui()

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 200)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BorderSizePixel = 0
    Frame.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Anti-Afk"
    Label.TextColor3 = Color3.fromRGB(30, 30, 30)
    Label.TextSize = 18
    Label.Font = Enum.Font.GothamMedium
    Label.Parent = Frame

    local dragging = false
    local dragStart
    local startPos

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

	Client.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
		Label.Text = "Disabled Roblox Idled Connection"
		task.delay(5, function()
			Label.Text = "Anti-Afk"
		end)
	end)
end

setfenv(main, setmetatable({
    game = game,
    workspace = workspace,
    script = script,
    Instance = Instance,
    Vector2 = Vector2,
    UDim2 = UDim2,
    UDim = UDim,
    Color3 = Color3,
    Enum = Enum,
    task = task,
    tonumber = tonumber,
    gethui = gethui,
    main = main,
}, {
	__index = function(_, key)
		local line = debug.getinfo(3, "l").currentline or "unknown"
		error(tostring(key) .. " is blocked | line: " .. line, 0)
	end
}))

main()
