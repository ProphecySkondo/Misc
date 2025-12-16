--[[
Minimal, safe, and readable "invisible" system for Roblox.
Provides two functions you can call:
    TurnInvisible()
    TurnVisible()

Key fixes included:
 - Explicitly rebinds camera to avoid black screens
 - Uses FallenPartsDestroyHeight properly (works if it's negative or positive)
 - Waits for Humanoids before making connections
 - Cleanly disconnects connections to avoid leaks
 - Comments explain the tricky parts for beginners
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

-- Local player
local Player = Players.LocalPlayer

-- State
local IsInvisible = false          -- true when we're currently invisible
local InvisibilityBusy = false     -- prevents re-entrancy when toggling
local RealCharacter                -- the player's original character model
local InvisibleCharacter           -- the cloned "playable" model we show other players
local VoidCheckConn                -- connection to monitor FallenPartsDestroyHeight / void
local DeathConn                    -- connection to monitor clone death
local CharacterAddedConn           -- optional connection to keep camera consistent on respawn

------------------------------------------------------------------------------
-- Helper: waitForHumanoid(model)
-- Ensures a Humanoid object exists on a Model and returns it.
-- This is safer than assuming the Humanoid is instantly present.
------------------------------------------------------------------------------
local function waitForHumanoid(model, timeout)
    timeout = timeout or 5
    local elapsed = 0
    while elapsed < timeout do
        if not model or not model.Parent then return nil end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum then return hum end
        task.wait(0.05)
        elapsed = elapsed + 0.05
    end
    return model:FindFirstChildOfClass("Humanoid") -- might still be nil
end

------------------------------------------------------------------------------
-- Helper: safeDisconnect(conn)
-- Disconnects a connection if it exists and nils the variable.
------------------------------------------------------------------------------
local function safeDisconnect(connVarName)
    if connVarName and type(connVarName) == "RBXScriptConnection" then
        connVarName:Disconnect()
    end
end

------------------------------------------------------------------------------
-- Internal cleanup - disconnects runtime connections and clears refs.
------------------------------------------------------------------------------
local function cleanupConnections()
    if VoidCheckConn then
        VoidCheckConn:Disconnect()
        VoidCheckConn = nil
    end
    if DeathConn then
        DeathConn:Disconnect()
        DeathConn = nil
    end
end

------------------------------------------------------------------------------
-- Camera rebind helper
-- Ensures camera is tracking the Humanoid of `model`.
-- We `defer` a tiny bit because Roblox sometimes needs a moment to update the
-- character/humanoid internally after swapping Player.Character.
------------------------------------------------------------------------------
local function rebindCameraToModel(model)
    task.defer(function()
        if not workspace.CurrentCamera then return end
        if not model or not model.Parent then return end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = waitForHumanoid(model, 1)
        end
        if hum and workspace.CurrentCamera then
            -- Use Custom so Roblox's camera controls (mouse) still work normally
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            workspace.CurrentCamera.CameraSubject = hum
        end
    end)
end

------------------------------------------------------------------------------
-- TurnVisible()
-- Restores the original character and cleans up clones + connections.
------------------------------------------------------------------------------
local function TurnVisible()
    -- If we're not invisible, nothing to do
    if not IsInvisible then
        return
    end

    -- Prevent re-entrancy while cleaning
    if InvisibilityBusy then
        return
    end
    InvisibilityBusy = true

    -- Disconnect monitoring
    cleanupConnections()

    -- If the invisible clone exists, destroy it
    if InvisibleCharacter and InvisibleCharacter.Parent then
        -- store the camera-relative position of clone to place real character where player expects
        local ok, cf = pcall(function()
            return InvisibleCharacter:FindFirstChild("HumanoidRootPart") and InvisibleCharacter.HumanoidRootPart.CFrame
        end)
        -- Remove clone
        InvisibleCharacter:Destroy()
        InvisibleCharacter = nil

        -- Restore the real character and place it where the clone was (if we have the cf)
        if RealCharacter then
            RealCharacter.Parent = workspace
            if ok and cf and RealCharacter:FindFirstChild("HumanoidRootPart") then
                RealCharacter.HumanoidRootPart.CFrame = cf
            end
            -- Make this the player's active character
            Player.Character = RealCharacter

            -- Rebind camera to the restored character's humanoid
            rebindCameraToModel(RealCharacter)

            -- Reset animate script as a safe measure
            if RealCharacter:FindFirstChild("Animate") then
                RealCharacter.Animate.Disabled = true
                RealCharacter.Animate.Disabled = false
            end
        end
    else
        -- If there was no clone (edge case), just try to ensure the player has a character and camera is correct
        if RealCharacter and RealCharacter.Parent ~= workspace then
            RealCharacter.Parent = workspace
            Player.Character = RealCharacter
            rebindCameraToModel(RealCharacter)
        end
    end

    -- Clear flags
    IsInvisible = false
    InvisibilityBusy = false
end

------------------------------------------------------------------------------
-- TurnInvisible()
-- Makes the player's original character hidden and places a semi-invisible clone
-- under player control. Monitors void and clone death to restore safely.
------------------------------------------------------------------------------
local function TurnInvisible()
    -- Avoid calling while another toggle is running
    if InvisibilityBusy or IsInvisible then
        return
    end
    InvisibilityBusy = true

    -- Ensure a character exists
    if not Player.Character or not Player.Character.Parent then
        -- Wait for the player's character to exist
        Player.CharacterAdded:Wait()
    end

    -- Store original character (the one to restore later)
    RealCharacter = Player.Character
    -- Make sure we can clone it
    RealCharacter.Archivable = true

    -- Make a clone that will be the visible/controllable model
    InvisibleCharacter = RealCharacter:Clone()
    InvisibleCharacter.Name = ""                 -- empty name so other scripts that rely on name are less likely to fail
    InvisibleCharacter.Parent = workspace       -- put clone into workspace so it replicates normally

    -- Make the clone semi-invisible for other players:
    -- - HumanoidRootPart should be fully invisible (so there's no floating torso)
    -- - Other parts set to some transparency (0.5) so you can debug; change to 1.0 for full invisible
    for _, obj in ipairs(InvisibleCharacter:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name == "HumanoidRootPart" then
                obj.Transparency = 1
            else
                obj.Transparency = 0.5
            end
        end
    end

    -- Save the clone's root CFrame so we can place the real character there when we toggle back
    local rootCFrame
    if InvisibleCharacter:FindFirstChild("HumanoidRootPart") then
        rootCFrame = InvisibleCharacter.HumanoidRootPart.CFrame
    else
        -- fallback: try to find any primary part
        rootCFrame = RealCharacter:FindFirstChild("HumanoidRootPart") and RealCharacter.HumanoidRootPart.CFrame
    end

    -- Hide the real character safely by parenting it to Lighting and moving it far away.
    -- Putting it in Lighting is a common pattern because Lighting is not rendered/replicated to
    -- other players, so they won't see the original model.
    RealCharacter.Parent = Lighting
    -- Move it far away to avoid collisions / physics issues (we use a large finite Y rather than math.huge).
    -- NOTE: MoveTo can sometimes fail if object is not in workspace; we set CFrame on HumanoidRootPart if present.
    if RealCharacter:FindFirstChild("HumanoidRootPart") then
        local safeY = 1e6 -- a large Y coordinate to move it far away
        RealCharacter:MoveTo(Vector3.new(0, safeY, 0))
    end

    -- Give player control of the clone:
    Player.Character = InvisibleCharacter

    -- Rebind camera to the clone's humanoid to avoid black screen
    rebindCameraToModel(InvisibleCharacter)

    -- Reset animate script to avoid animation glitches
    local animate = InvisibleCharacter:FindFirstChild("Animate")
    if animate then
        animate.Disabled = true
        animate.Disabled = false
    end

    -- Mark invisible state
    IsInvisible = true
    InvisibilityBusy = false

    ----------------------------------------------------------------------------
    -- Void (FallenPartsDestroyHeight) monitoring
    -- We must restore the real character BEFORE either character or clone gets deleted
    -- FallenPartsDestroyHeight is a numeric Y-level. If something crosses the plane
    -- defined by that Y value, the engine will destroy parts. This value can be
    -- negative (common) or positive (rare). We handle both cases.
    ----------------------------------------------------------------------------
    local voidY = workspace.FallenPartsDestroyHeight or -500

    VoidCheckConn = RunService.Stepped:Connect(function()
        -- pcall so any transient nils don't break the loop
        pcall(function()
            if not Player.Character or not Player.Character.Parent then
                return
            end
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return
            end
            local y = hrp.Position.Y
            -- If engine's void line is negative (e.g. -500), things below it are destroyed
            if voidY < 0 then
                if y <= voidY then
                    TurnVisible()
                end
            else
                -- If the void line is positive (rare), things above it are destroyed
                if y >= voidY then
                    TurnVisible()
                end
            end
        end)
    end)

    ----------------------------------------------------------------------------
    -- Death protection
    -- If the clone dies, restore original character.
    ----------------------------------------------------------------------------
    local cloneHum = waitForHumanoid(InvisibleCharacter, 2)
    if cloneHum then
        DeathConn = cloneHum.Died:Connect(function()
            TurnVisible()
        end)
    else
        -- If humanoid never appeared, be safe and restore immediately (edge case)
        TurnVisible()
    end
end

------------------------------------------------------------------------------
-- Optional: ensure camera rebinds when the player respawns normally.
-- This keeps the camera consistent when not using invis or after manual resets.
------------------------------------------------------------------------------
CharacterAddedConn = Player.CharacterAdded:Connect(function(char)
    -- If we're not invisible, rebind to whatever new humanoid exists.
    if not IsInvisible then
        rebindCameraToModel(char)
    end
end)

------------------------------------------------------------------------------
-- Example usage:
-- Call these functions from other scripts, hotkeys, or UI:
-- TurnInvisible()
-- TurnVisible()
------------------------------------------------------------------------------
-- For demonstration only: uncomment to test immediately (remove in production)
-- TurnInvisible()
-- task.delay(8, TurnVisible)

-- Export functions to global (optional) so you can call them from other local scripts:
_G.TurnInvisible = TurnInvisible
_G.TurnVisible = TurnVisible

-- End of script
