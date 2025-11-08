getgenv().Config = {
    Enabled = false,
    TargetMultiplier = 1.20,
    DupeSpeed = 1,
    AutoRejoin = true,
    AntiAFK = true
}

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function findElements()
    local e = {}
    for _,v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("rocket") or v.Name:lower():find("gift")) then
            e.Remote = v break
        end
    end
    for _,v in pairs(PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:lower():find("multiplier") then e.MultLabel = v end
        if v:IsA("Frame") and (v.Name:lower():find("rocket") or v.Name:lower():find("gift")) then e.Frame = v end
    end
    return e
end

local Elements = findElements()

local function getMultiplier()
    local mult = 1.0
    pcall(function()
        if Elements.MultLabel then
            local found = Elements.MultLabel.Text:match("x([%d%.]+)")
            if found then mult = tonumber(found) or 1.0 end
        end
    end)
    return mult
end

local function getPrize()
    if not Elements.Frame then return "Gift" end
    for _,v in pairs(Elements.Frame:GetChildren()) do
        if (v:IsA("ImageLabel") or v:IsA("TextButton")) and v.Visible then return v.Name end
    end
    return "Gift"
end

local function startDupe()
    task.spawn(function()
        while getgenv().Config.Enabled do
            if getMultiplier() >= getgenv().Config.TargetMultiplier then
                pcall(function()
                    if Elements.Remote then
                        Elements.Remote:FireServer(getPrize(), "Claim")
                    end
                end)
                if getgenv().Config.AutoRejoin then
                    task.wait(2)
                    TS:Teleport(game.PlaceId, Player)
                end
                break
            end
            task.wait(getgenv().Config.DupeSpeed)
        end
    end)
end

local function createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Parent = PlayerGui
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 200)
    f.Position = UDim2.new(0, 10, 0, 10)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.Parent = sg
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 40)
    toggle.Position = UDim2.new(0.05, 0, 0.1, 0)
    toggle.Text = "START DUP: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Parent = f
    
    local mult = Instance.new("TextBox")
    mult.Size = UDim2.new(0.9, 0, 0, 30)
    mult.Position = UDim2.new(0.05, 0, 0.4, 0)
    mult.Text = "1.20"
    mult.PlaceholderText = "Target Multiplier"
    mult.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    mult.TextColor3 = Color3.fromRGB(255, 255, 255)
    mult.Parent = f
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 40)
    status.Position = UDim2.new(0.05, 0, 0.7, 0)
    status.Text = "Status: Ready"
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.Parent = f
    
    toggle.MouseButton1Click:Connect(function()
        getgenv().Config.Enabled = not getgenv().Config.Enabled
        if getgenv().Config.Enabled then
            toggle.Text = "START DUP: ON"
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            status.Text = "Status: Running..."
            startDupe()
        else
            toggle.Text = "START DUP: OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            status.Text = "Status: Stopped"
        end
    end)
    
    mult.FocusLost:Connect(function()
        local m = tonumber(mult.Text)
        if m and m >= 1.0 then
            getgenv().Config.TargetMultiplier = m
        else
            mult.Text = "1.20"
        end
    end)
end

if getgenv().Config.AntiAFK then
    local VU = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end

task.spawn(function()
    while task.wait(10) do
        Elements = findElements()
    end
end)

createGUI()
return "🎁 NFT BATTLE Duper Loaded!"
