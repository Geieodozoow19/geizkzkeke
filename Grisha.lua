-- SWILL Delta Script: Auto Private Server Creator & Joiner для Steal Brainrot
-- Место: 109983668079237 (Steal Brainrot)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Конфигурация
local TARGET_PLACE_ID = 109983668079237
local SERVER_NAME = "SWILL_Private_" .. math.random(1000,9999)

-- Функция создания приватного сервера
function createPrivateServer()
    -- Проверяем, есть ли право на создание приватных серверов
    local success, hasAccess = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, --[[ID GamePass для приватных серверов, если требуется]])
    end)
    
    -- Создаем запрос на создание приватного сервера
    local url = string.format("https://games.roblox.com/v1/games/%d/private-servers", TARGET_PLACE_ID)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Cookie"] = ".ROBLOSECURITY=" .. get_cookie() or ""
    }
    
    local body = {
        name = SERVER_NAME,
        maxPlayers = 30
    }
    
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = HttpService:JSONEncode(body)
    })
    
    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data.accessCode then
            return data.accessCode
        end
    end
    return nil
end

-- Функция получения cookie (для Delta)
function get_cookie()
    local cookie
    pcall(function()
        cookie = game:GetService("HttpService"):GetCookies()[".ROBLOSECURITY"] or
                syn and syn.request({Url="https://roblox.com"}).Headers[".ROBLOSECURITY"]
    end)
    return cookie
end

-- Основной процесс
local function main()
    -- Показываем уведомление
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL Private Server",
        Text = "Создание приватного сервера Steal Brainrot...",
        Duration = 3
    })
    
    -- Пытаемся создать приватный сервер
    local accessCode = createPrivateServer()
    
    if not accessCode then
        -- Если не удалось создать, используем стандартный код
        accessCode = "ERTJioQnOK5X7Jki7BY5hF3Lk5r5NUINmKZL2MzMKluFineRB2QAAA2"
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SWILL Private Server",
            Text = "Используется резервный код доступа",
            Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SWILL Private Server",
            Text = "Приватный сервер создан: " .. SERVER_NAME,
            Duration = 3
        })
    end
    
    -- Задержка перед подключением
    wait(2)
    
    -- Подключаемся к приватному серверу
    local success, errorMsg = pcall(function()
        -- Метод 1: Через TeleportService (предпочтительный)
        TeleportService:TeleportToPrivateServer(TARGET_PLACE_ID, accessCode)
    end)
    
    if not success then
        -- Метод 2: Резервный метод
        wait(1)
        pcall(function()
            game:GetService("ReplicatedStorage").ContactListIrisInviteTeleport:FireServer(
                tostring(TARGET_PLACE_ID), 
                "", 
                accessCode
            )
        end)
        
        -- Метод 3: Через ссылку
        wait(1)
        pcall(function()
            local teleportUrl = string.format(
                "https://www.roblox.com/games/%d?privateServerLinkCode=%s",
                TARGET_PLACE_ID,
                accessCode
            )
            game:GetService("TeleportService"):Teleport(TARGET_PLACE_ID, Players.LocalPlayer, teleportUrl)
        end)
    end
    
    -- Финальное уведомление
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL Private Server",
        Text = "Подключение к Steal Brainrot...",
        Duration = 5
    })
end

-- Автоматический запуск
local function autoExecute()
    -- Проверяем, находимся ли мы уже в целевой игре
    if game.PlaceId == TARGET_PLACE_ID then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SWILL Private Server",
            Text = "Вы уже в Steal Brainrot",
            Duration = 3
        })
        return
    end
    
    -- Запускаем основной процесс
    local success, err = pcall(main)
    
    if not success then
        -- Резервный метод: прямой телепорт
        wait(1)
        pcall(function()
            TeleportService:Teleport(TARGET_PLACE_ID)
        end)
    end
end

-- Запускаем скрипт
autoExecute()

-- UI для ручного управления
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")

ScreenGui.Name = "SWILL_PrivateServer_GUI"
ScreenGui.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.8, 0, 0.7, 0)
Frame.Size = UDim2.new(0.15, 0, 0.08, 0)

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
TextButton.BorderSizePixel = 0
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSansBold
TextButton.Text = "SWILL: Join Private"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14

TextButton.MouseButton1Click:Connect(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL",
        Text = "Подключение к приватному серверу...",
        Duration = 2
    })
    main()
end)

-- Автоматическое скрытие UI при успешном телепорте
spawn(function()
    while wait(5) do
        if game.PlaceId == TARGET_PLACE_ID then
            ScreenGui:Destroy()
            break
        end
    end
end)

print("[SWILL] Скрипт приватного сервера Steal Brainrot активирован")
print("[SWILL] Место ID: " .. TARGET_PLACE_ID)
print("[SWILL] Имя сервера: " .. SERVER_NAME)
