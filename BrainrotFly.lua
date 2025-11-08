-- NoClip Fly for Steal A brainrot
-- by https://t.me/vomagla

getgenv().FlyConfig = {
    Enabled = false,
    Speed = 50,
    NoClip = true,
    AntiAntiCheat = true
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Анти-античит методы
local function setupAntiAntiCheat()
    if not getgenv().FlyConfig.AntiAntiCheat then return end
    
    -- Скрываем скрипт от обнаружения
    if hookfunction then
        local oldNamecall
        oldNamecall = hookfunction(metatable.__namecall, function(self, ...)
            local method = getnamecallmethod()
            if tostring(self) == "AntiCheat" or method == "Kick" or method == "Destroy" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    end
    
    -- Обход проверок скорости
    if setfflag then
        setfflag("HumanoidParallelRemoveNoPhysics", "False")
        setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
    end
end

-- NoClip функция
local function enableNoClip()
    if not getgenv().FlyConfig.NoClip then return end
    
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- Основная система полета
local function createFlySystem()
    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    BodyVelocity.P = 1000
    BodyVelocity.Parent = RootPart

    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    BodyGyro.P = 1000
    BodyGyro.Parent = RootPart

    local flying = false
    local flyConnection

    local function startFlying()
        flying = true
        Humanoid.PlatformStand = true
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flying or not Character or not RootPart then return end
            
            enableNoClip()
            
            local camera = Workspace.CurrentCamera
            BodyGyro.CFrame = camera.CFrame
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Управление WASD
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * getgenv().FlyConfig.Speed
            end
            
            BodyVelocity.Velocity = moveDirection
        end)
    end

    local function stopFlying()
        flying = false
        Humanoid.PlatformStand = false
        
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if BodyVelocity then
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end

    -- Переключение полета на T
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.T then
            getgenv().FlyConfig.Enabled = not getgenv().FlyConfig.Enabled
            
            if getgenv().FlyConfig.Enabled then
                startFlying()
            else
                stopFlying()
            end
        end
        
        -- Изменение скорости на R/F
        if input.KeyCode == Enum.KeyCode.R then
            getgenv().FlyConfig.Speed = math.min(getgenv().FlyConfig.Speed + 10, 200)
        elseif input.KeyCode == Enum.KeyCode.F then
            getgenv().FlyConfig.Speed = math.max(getgenv().FlyConfig.Speed - 10, 10)
        end
    end)

    return {
        Start = startFlying,
        Stop = stopFlying,
        BodyVelocity = BodyVelocity,
        BodyGyro = BodyGyro
    }
end

-- GUI для управления
local function createFlyGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.Name = "FlyGUI"

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Text = "🚀 FLY & NOCLIP"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = MainFrame

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.Text = "Status: OFF\nPress T to toggle\nSpeed: " .. getgenv().FlyConfig.Speed .. "\nR/F - Speed +/-"
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextWrapped = true
    Status.Parent = MainFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 120)
    ToggleBtn.Text = "🔄 TOGGLE FLY (T)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = MainFrame

    local SpeedBtn = Instance.new("TextButton")
    SpeedBtn.Size = UDim2.new(1, -20, 0, 30)
    SpeedBtn.Position = UDim2.new(0, 10, 0, 165)
    SpeedBtn.Text = "⚡ SPEED: " .. getgenv().FlyConfig.Speed
    SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SpeedBtn.Font = Enum.Font.Gotham
    SpeedBtn.TextSize = 12
    SpeedBtn.Parent = MainFrame

    ToggleBtn.MouseButton1Click:Connect(function()
        getgenv().FlyConfig.Enabled = not getgenv().FlyConfig.Enabled
        if getgenv().FlyConfig.Enabled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            Status.Text = "Status: ON\nPress T to toggle\nSpeed: " .. getgenv().FlyConfig.Speed .. "\nR/F - Speed +/-"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            Status.Text = "Status: OFF\nPress T to toggle\nSpeed: " .. getgenv().FlyConfig.Speed .. "\nR/F - Speed +/-"
        end
    end)

    SpeedBtn.MouseButton1Click:Connect(function()
        getgenv().FlyConfig.Speed = 100
        SpeedBtn.Text = "⚡ SPEED: " .. getgenv().FlyConfig.Speed
        Status.Text = "Status: " .. (getgenv().FlyConfig.Enabled and "ON" or "OFF") .. "\nPress T to toggle\nSpeed: " .. getgenv().FlyConfig.Speed .. "\nR/F - Speed +/-"
    end)

    -- Обновление статуса
    local function updateStatus()
        while task.wait(0.5) do
            if Status then
                Status.Text = "Status: " .. (getgenv().FlyConfig.Enabled and "ON" or "OFF") .. 
                             "\nPress T to toggle\nSpeed: " .. getgenv().FlyConfig.Speed .. 
                             "\nR/F - Speed +/-"
            end
        end
    end
    task.spawn(updateStatus)

    return ScreenGui
end

-- Инициализация
setupAntiAntiCheat()
local FlySystem = createFlySystem()
local FlyGUI = createFlyGUI()

-- Авто-реконнект при смерти/респавне
Character:WaitForChild("Humanoid").Died:Connect(function()
    if getgenv().FlyConfig.Enabled then
        getgenv().FlyConfig.Enabled = false
        FlySystem.Stop()
    end
end)

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    task.wait(1)
    FlySystem = createFlySystem()
    
    if getgenv().FlyConfig.Enabled then
        FlySystem.Start()
    end
end)

print("🚀 Fly & NoClip loaded!")
print("Controls: T - Toggle, WASD - Move, Space/Shift - Up/Down, R/F - Speed")
