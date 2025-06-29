-- MylesGUI Client-Side Script
-- Features: Flight, Teleport to Players, Teleport Players to You, Teleport to Void (Kill), Invisibility, NoClip

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "mylesgui"
ScreenGui.Parent = game.CoreGui

local function createButton(name, position, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = ScreenGui
    return btn
end

-- Buttons
local flyBtn = createButton("FlyButton", UDim2.new(0, 20, 0, 20), "Toggle Flight")
local tpToPlayerBtn = createButton("TpToPlayerButton", UDim2.new(0, 20, 0, 70), "TP To Player")
local tpPlayersToMeBtn = createButton("TpPlayersToMeButton", UDim2.new(0, 20, 0, 120), "TP Players To Me")
local tpToVoidBtn = createButton("TpToVoidButton", UDim2.new(0, 20, 0, 170), "TP To Void (Kill)")
local invisBtn = createButton("InvisButton", UDim2.new(0, 20, 0, 220), "Toggle Invisibility")
local noclipBtn = createButton("NoClipButton", UDim2.new(0, 20, 0, 270), "Toggle NoClip")

-- Flight variables
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

local function startFly()
    if flying then return end
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = RootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = RootPart.CFrame
    bodyGyro.Parent = RootPart

    RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, function()
        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0,1,0)
        end
        bodyVelocity.Velocity = moveDir.Unit * flySpeed
        if moveDir.Magnitude > 0 then
            bodyGyro.CFrame = CFrame.new(RootPart.Position, RootPart.Position + moveDir)
        end
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    RunService:UnbindFromRenderStep("Fly")
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

-- Teleport to player
tpToPlayerBtn.MouseButton1Click:Connect(function()
    local targetName = tostring(LocalPlayer:PromptInput("Enter player name to TP to:"))
    if not targetName or targetName == "" then return end
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        RootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
    else
        LocalPlayer:Kick("Player not found or no character.")
    end
end)

-- Teleport all players to me
tpPlayersToMeBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = RootPart.CFrame + Vector3.new(0,5,0)
        end
    end
end)

-- Teleport players to void (kill)
tpToVoidBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = CFrame.new(0, -1000, 0)
        end
    end
end)

-- Invisibility toggle
local invisible = false
invisBtn.MouseButton1Click:Connect(function()
    invisible = not invisible
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = invisible and 1 or 0
            if part:IsA("Decal") then
                part.Transparency = invisible and 1 or 0
            end
        elseif part:IsA("Decal") then
            part.Transparency = invisible and 1 or 0
        end
    end
    Humanoid.NameDisplayDistance = invisible and 0 or 100
    Humanoid.HealthDisplayDistance = invisible and 0 or 100
end)

-- NoClip toggle
local noclip = false
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
end)

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- Character update on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)
