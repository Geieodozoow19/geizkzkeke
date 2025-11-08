local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Конфигурация
getgenv().DupeConfig = {
    Enabled = false,
    DupeMethod = "Fast", -- Fast, ServerHop, Trade
    DupeSpeed = 1,
    AutoRejoin = true,
    WebhookURL = ""
}

-- Поиск элементов игры
local function findGameElements()
    local elements = {}
    
    -- Поиск ремов для кражи/дюпа
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if string.find(obj.Name:lower(), "steal") or string.find(obj.Name:lower(), "take") then
                elements.StealRemote = obj
            elseif string.find(obj.Name:lower(), "trade") then
                elements.TradeRemote = obj
            elseif string.find(obj.Name:lower(), "dupe") then
                elements.DupeRemote = obj
            end
        end
    end
    
    -- Поиск баз и точек спавна
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then
            if string.find(obj.Name:lower(), "base") or string.find(obj.Name:lower(), "spawn") then
                table.insert(elements.Bases or {}, obj)
            end
        end
    end
    
    return elements
end

local GameElements = findGameElements()

-- Создание GUI
local function createDupeGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.Name = "BrainrotDupeGUI"

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(0, 255, 170)
    UIStroke.Parent = MainFrame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Text = "🧠 BRAINROT DUPER"
    Title.TextColor3 = Color3.fromRGB(0, 255, 170)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    -- Основные настройки
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Size = UDim2.new(1, -20, 0, 200)
    SettingsFrame.Position = UDim2.new(0, 10, 0, 60)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Parent = MainFrame

    -- Переключатель дупа
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 0, 40)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.Text = "🚀 START DUP: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = SettingsFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton

    -- Выбор метода
    local MethodLabel = Instance.new("TextLabel")
    MethodLabel.Size = UDim2.new(1, 0, 0, 20)
    MethodLabel.Position = UDim2.new(0, 0, 0, 50)
    MethodLabel.Text = "Method: Fast Dupe"
    MethodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MethodLabel.BackgroundTransparency = 1
    MethodLabel.Font = Enum.Font.Gotham
    MethodLabel.TextSize = 12
    MethodLabel.TextXAlignment = Enum.TextXAlignment.Left
    MethodLabel.Parent = SettingsFrame

    local MethodButton = Instance.new("TextButton")
    MethodButton.Size = UDim2.new(1, 0, 0, 30)
    MethodButton.Position = UDim2.new(0, 0, 0, 70)
    MethodButton.Text = "🔄 CHANGE METHOD"
    MethodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MethodButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    MethodButton.Font = Enum.Font.Gotham
    MethodButton.TextSize = 12
    MethodButton.Parent = SettingsFrame

    -- Скорость
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 0, 0, 110)
    SpeedLabel.Text = "Speed: 1"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 12
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = SettingsFrame

    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(1, 0, 0, 30)
    SpeedBox.Position = UDim2.new(0, 0, 0, 130)
    SpeedBox.Text = "1"
    SpeedBox.PlaceholderText = "Dupe Speed"
    SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SpeedBox.Font = Enum.Font.Gotham
    SpeedBox.TextSize = 12
    SpeedBox.Parent = SettingsFrame

    -- Статус
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 100)
    StatusFrame.Position = UDim2.new(0, 10, 0, 270)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    StatusFrame.Parent = MainFrame

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = StatusFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 1, -10)
    StatusLabel.Position = UDim2.new(0, 5, 0, 5)
    StatusLabel.Text = "Status: Ready to dupe brainrots!\nFound Remotes: " .. (GameElements.StealRemote and "Yes" or "No")
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 12
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = StatusFrame

    -- Обработчики событий
    local methods = {"Fast", "ServerHop", "Trade"}
    local currentMethod = 1

    MethodButton.MouseButton1Click:Connect(function()
        currentMethod = currentMethod % #methods + 1
        getgenv().DupeConfig.DupeMethod = methods[currentMethod]
        MethodLabel.Text = "Method: " .. methods[currentMethod]
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        getgenv().DupeConfig.Enabled = not getgenv().DupeConfig.Enabled
        if getgenv().DupeConfig.Enabled then
            ToggleButton.Text = "🚀 START DUP: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            StatusLabel.Text = "Status: Dupe started!\nMethod: " .. methods[currentMethod]
            startDupeProcess()
        else
            ToggleButton.Text = "🚀 START DUP: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            StatusLabel.Text = "Status: Dupe stopped"
        end
    end)

    SpeedBox.FocusLost:Connect(function()
        local speed = tonumber(SpeedBox.Text)
        if speed and speed >= 0.1 and speed <= 10 then
            getgenv().DupeConfig.DupeSpeed = speed
            SpeedLabel.Text = "Speed: " .. speed
        else
            SpeedBox.Text = "1"
        end
    end)

    return {
        GUI = ScreenGui,
        StatusLabel = StatusLabel
    }
end

-- Основной процесс дупа
local function startDupeProcess()
    task.spawn(function()
        while getgenv().DupeConfig.Enabled do
            local method = getgenv().DupeConfig.DupeMethod
            
            if method == "Fast" then
                -- Быстрый дуп через спам ремов
                for i = 1, 20 do
                    if not getgenv().DupeConfig.Enabled then break end
                    
                    pcall(function()
                        if GameElements.StealRemote then
                            GameElements.StealRemote:FireServer()
                        end
                        if GameElements.DupeRemote then
                            GameElements.DupeRemote:FireServer()
                        end
                    end)
                    
                    task.wait(0.1 / getgenv().DupeConfig.DupeSpeed)
                end
                
            elseif method == "Trade" then
                -- Трейд метод
                pcall(function()
                    if GameElements.TradeRemote then
                        -- Симуляция трейда
                        GameElements.TradeRemote:FireServer(Player)
                    end
                end)
                
            elseif method == "ServerHop" then
                -- Смена серверов
                local TeleportService = game:GetService("TeleportService")
                local servers = {}
                
                pcall(function()
                    local response = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                    servers = game:GetService("HttpService"):JSONDecode(response).data
                end)
                
                for _, server in pairs(servers) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                        break
                    end
                end
            end
            
            -- Авто-режим
            if getgenv().DupeConfig.AutoRejoin and getgenv().DupeConfig.Enabled then
                task.wait(3)
                game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
            end
            
            task.wait(1)
        end
    end)
end

-- Авто-поиск базы
local function findAndGoToBase()
    if not GameElements.Bases or #GameElements.Bases == 0 then
        GameElements = findGameElements()
    end
    
    if GameElements.Bases and #GameElements.Bases > 0 then
        local closestBase = GameElements.Bases[1]
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid:MoveTo(closestBase.Position)
        end
    end
end

-- Анти-АФК
local function setupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Инициализация
setupAntiAFK()
findAndGoToBase()
local GUI = createDupeGUI()

-- Периодическое обновление элементов
task.spawn(function()
    while task.wait(10) do
        GameElements = findGameElements()
        if GUI.StatusLabel then
            GUI.StatusLabel.Text = "Status: Updated game elements\nRemotes: " .. (GameElements.StealRemote and "Found" or "Searching")
        end
    end
end)

print("🧠 Brainrot Duper loaded! Ready to steal and dupe!")
