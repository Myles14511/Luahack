-- Client-side LocalScript based on CoolKidd GUI style for Mobile Compatible Flight, Teleports, Invisibility, NoClip, and More

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Flight variables
local flightSpeed = 50
local flightEnabled = false
local noclipEnabled = false
local invisibilityEnabled = false

-- Body movers for flight
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = rootPart

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
bodyGyro.CFrame = rootPart.CFrame
bodyGyro.Parent = rootPart

-- Toggle Flight
local function toggleFlight(state)
    flightEnabled = state
    if flightEnabled then
        humanoid.PlatformStand = true
        bodyVelocity.Parent = rootPart
        bodyGyro.Parent = rootPart
    else
        humanoid.PlatformStand = false
        bodyVelocity.Parent = nil
        bodyGyro.Parent = nil
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Toggle NoClip
local function toggleNoClip(state)
    noclipEnabled = state
    if noclipEnabled then
        RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Toggle Invisibility
local function toggleInvisibility(state)
    invisibilityEnabled = state
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = invisibilityEnabled and 1 or 0
        elseif part:IsA("Accessory") then
            for _, accPart in pairs(part:GetDescendants()) do
                if accPart:IsA("BasePart") or accPart:IsA("Decal") then
                    accPart.Transparency = invisibilityEnabled and 1 or 0
                end
            end
        end
    end
    humanoid.NameDisplayDistance = invisibilityEnabled and 0 or 100
end

-- Flight Control
local function flightControl()
    if not flightEnabled then return end

    local moveVector = Vector3.new(0, 0, 0)
    local cam = workspace.CurrentCamera
    local forward = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end

    moveVector = moveVector.Unit * flightSpeed
    if moveVector.Magnitude == 0 then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    else
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveVector)
    end
end

RunService.RenderStepped:Connect(flightControl)

-- Teleport Functions

local function tpPlayerToPlayer(targetPlayerName)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function tpPlayerToMe(targetPlayerName)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function tpPlayerToVoid(targetPlayerName)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Teleport below map to kill
        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
    end
end

-- Example GUI buttons (CoolKidd style) setup (requires ScreenGui with buttons named accordingly)
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("CoolKiddGui") -- Assume your GUI is named "CoolKiddGui"

local flightToggleButton = gui:WaitForChild("FlightToggle")
local noclipToggleButton = gui:WaitForChild("NoClipToggle")
local invisToggleButton = gui:WaitForChild("InvisToggle")
local tpToPlayerButton = gui:WaitForChild("TpToPlayer")
local tpPlayerToMeButton = gui:WaitForChild("TpPlayerToMe")
local tpToVoidButton = gui:WaitForChild("TpToVoid")

-- Button events
flightToggleButton.MouseButton1Click:Connect(function()
    toggleFlight(not flightEnabled)
end)

noclipToggleButton.MouseButton1Click:Connect(function()
    toggleNoClip(not noclipEnabled)
end)

invisToggleButton.MouseButton1Click:Connect(function()
    toggleInvisibility(not invisibilityEnabled)
end)

tpToPlayerButton.MouseButton1Click:Connect(function()
    local targetName = gui.TargetPlayerName.Text
    tpPlayerToPlayer(targetName)
end)

tpPlayerToMeButton.MouseButton1Click:Connect(function()
    local targetName = gui.TargetPlayerName.Text
    tpPlayerToMe(targetName)
end)

tpToVoidButton.MouseButton1Click:Connect(function()
    local targetName = gui.TargetPlayerName.Text
    tpPlayerToVoid(targetName)
end)

-- Mobile controls can be added similarly by connecting TouchGui buttons to these functions.

