-- Client-side LocalScript mimicking CoolKidd GUI behavior (no buttons, keybinds & mobile compatible)
-- Features: Flight, Teleports (to player, to me, to void), Invisibility, NoClip

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Settings
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
local noclipConnection
local function toggleNoClip(state)
    noclipEnabled = state
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
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

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * flightSpeed
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveVector)
    else
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

RunService.RenderStepped:Connect(flightControl)

-- Teleport Functions
local function tpPlayerToPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function tpPlayerToMe(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function tpPlayerToVoid(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
    end
end

-- Keybinds for toggles and teleports (mobile compatible with on-screen keyboard)

-- Flight toggle: F
-- NoClip toggle: N
-- Invisibility toggle: I
-- Teleport to player: T (prompts for player name)
-- Teleport player to me: Y (prompts for player name)
-- Teleport player to void: V (prompts for player name)

local function promptForPlayerName(action)
    local TextService = game:GetService("TextService")
    local InputGui = Instance.new("ScreenGui", player.PlayerGui)
    InputGui.Name = "InputGui"
    InputGui.ResetOnSpawn = false

    local TextBox = Instance.new("TextBox", InputGui)
    TextBox.Size = UDim2.new(0, 200, 0, 50)
    TextBox.Position = UDim2.new(0.5, -100, 0.5, -25)
    TextBox.PlaceholderText = "Enter player name for "..action
    TextBox.Text = ""
    TextBox.ClearTextOnFocus = true
    TextBox.TextScaled = true
    TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextBox.TextColor3 = Color3.new(1,1,1)
    TextBox.Font = Enum.Font.SourceSansBold
    TextBox.TextStrokeTransparency = 0.75

    local confirmed = false
    local playerName = nil

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            playerName = TextBox.Text
            confirmed = true
            InputGui:Destroy()
        else
            InputGui:Destroy()
        end
    end)

    -- Wait for input or cancellation
    repeat
        RunService.RenderStepped:Wait()
    until confirmed or not InputGui.Parent

    return playerName
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.F then
            toggleFlight(not flightEnabled)
        elseif key == Enum.KeyCode.N then
            toggleNoClip(not noclipEnabled)
        elseif key == Enum.KeyCode.I then
            toggleInvisibility(not invisibilityEnabled)
        elseif key == Enum.KeyCode.T then
            local targetName = promptForPlayerName("Teleport to Player")
            if targetName then
                tpPlayerToPlayer(targetName)
            end
        elseif key == Enum.KeyCode.Y then
            local targetName = promptForPlayerName("Teleport Player to Me")
            if targetName then
                tpPlayerToMe(targetName)
            end
        elseif key == Enum.KeyCode.V then
            local targetName = promptForPlayerName("Teleport Player to Void")
            if targetName then
                tpPlayerToVoid(targetName)
            end
        end
    end
end)

-- Mobile users can use the on-screen keyboard to trigger these keybinds.

-- End of script
