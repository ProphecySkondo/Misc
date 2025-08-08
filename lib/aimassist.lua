-- // services

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")
local userinputService = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")

local plr = players.LocalPlayer
local char = plr.Character
local hrp = char:WaitForChild("HumanoidRootPart", 3)
local camera = workspace.CurrentCamera

local allplayers = {}
local mouse = plr:GetMouse()

local ac, ho, st = false, false, false
local s = runService.RenderStepped
local e = Enum.UserInputType
local y, n = userinputService.InputBegan, userinputService.InputEnded
f, t = false, true
local T = tweenService
local m = mousemoverel

str = tostring
output = print

function getallplrs()
    allplayers = {}
    for i, v in pairs(players:GetPlayers()) do
        if v ~= plr then
            table.insert(allplayers, v)
        end
    end
end; getallplrs()

function changemoustasset(assetid)
    if typeof(assetid) == "number" then
        mouse.Icon = "rbxassetid://" .. tostring(assetid)
    elseif typeof(assetid) == "string" and assetid:sub(1,14) == config["assets"]["Starting"] then
        mouse.Icon = tostring(assetid)
    end
end; changemoustasset(config["assets"]["Mouse"])

function getclosestplayer()
    local a = nil
    local h = math.huge
    local f = userinputService:GetMouseLocation()
    for _, b in next, players:GetPlayers() do
        if b.Name ~= plr.Name and b.Character then
            local c = b.Character:FindFirstChild("HumanoidRootPart")
            local d = b.Character:FindFirstChild("Humanoid")
            if c and d and d.Health > 0 then
                local e, onScreen = camera:WorldToScreenPoint(c.Position)
                if onScreen then
                    local g = (Vector2.new(f.X, f.Y) - Vector2.new(e.X, e.Y)).Magnitude
                    if g < config.Radius and g < h then
                        a = b
                        h = g
                    end
                end
            end
        end
    end
    return a
end

function aimassist()
    if ho then
        local t = getclosestplayer()
        if t and t.Character then
            local p = t.Character:FindFirstChild(config.AimPart)
            if p then
                local s = config.Smoothness
                local c = camera.CFrame
                local tp = p.Position
                local nc = CFrame.new(c.Position, c.Position + (tp - c.Position).Unit)
                camera.CFrame = c:Lerp(nc, s)
            end
        end
    end
end

active = function(...)
    local args = {...}
    inp = args[1]
    y:Connect(function(I)
        if I.UserInputType == e[str(inp)] then
            ho = t
        end
    end)
    n:Connect(function(I)
        if I.UserInputType == e[str(inp)] then
            ho = f
        end
    end)
end; active(config.ActivationKey)

s:Connect(aimassist)
output("test")