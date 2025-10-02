local Players = game:GetService("Players")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- Fixed blacklist syntax
local blacklist = {
    "geriedsmod",
    "vibez_qxys",  -- Added missing comma
    "spidersamm122",
    "cosmosfsv"
}

for _, plr in pairs(Players:GetPlayers()) do
    if table.find(blacklist, plr.Name) then
        plr:Kick("You have been permanently banned.\nReason: Attempting to impersonate another individual.")
    end
end

local VALID_KEY = "XYNHUB_GHIIRRM6PXFF"

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "XynHub",
            Text = text,
            Duration = 4
        })
    end)
    print("[Notify]", text)
end

local function createKeyGui(onCorrectKey)
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "XynHub | Key System"
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    keyGui.Parent = player:WaitForChild("PlayerGui")

    -- Main Background
    local bg = Instance.new("Frame", keyGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    bg.BorderSizePixel = 0

    -- Animated Gradient Background
    local gradient = Instance.new("UIGradient", bg)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 45)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 35, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 45))
    }
    gradient.Rotation = 45
    local gradientTween = TweenService:Create(gradient, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 405})
    gradientTween:Play()

    -- Main Frame
    local frame = Instance.new("Frame", keyGui)
    frame.Size = UDim2.new(0, 400, 0, 280)
    frame.Position = UDim2.new(0.5, -200, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)

    -- Frame Shadow
    local shadow = Instance.new("Frame", frame)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 9
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 25)

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "XYNHUB"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 36
    title.ZIndex = 11

    -- Subtitle
    local subtitle = Instance.new("TextLabel", frame)
    subtitle.Size = UDim2.new(1, -40, 0, 25)
    subtitle.Position = UDim2.new(0, 20, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "PREMIUM ACCESS SYSTEM"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 16
    subtitle.ZIndex = 11

    -- Key Input Frame
    local inputFrame = Instance.new("Frame", frame)
    inputFrame.Size = UDim2.new(1, -40, 0, 50)
    inputFrame.Position = UDim2.new(0, 20, 0, 110)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 11
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

    -- Key Input
    local keyBox = Instance.new("TextBox", inputFrame)
    keyBox.Size = UDim2.new(1, -20, 1, 0)
    keyBox.Position = UDim2.new(0, 10, 0, 0)
    keyBox.PlaceholderText = "ENTER YOUR ACCESS KEY..."
    keyBox.Text = ""
    keyBox.BackgroundTransparency = 1
    keyBox.TextColor3 = Color3.fromRGB(200, 200, 255)
    keyBox.TextScaled = true
    keyBox.Font = Enum.Font.GothamSemibold
    keyBox.TextXAlignment = Enum.TextXAlignment.Center
    keyBox.ZIndex = 12
    keyBox.ClearTextOnFocus = false

    -- Input Glow Effect
    local inputGlow = Instance.new("Frame", inputFrame)
    inputGlow.Size = UDim2.new(1, 4, 1, 4)
    inputGlow.Position = UDim2.new(0, -2, 0, -2)
    inputGlow.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
    inputGlow.BorderSizePixel = 0
    inputGlow.BackgroundTransparency = 1
    inputGlow.ZIndex = 10
    Instance.new("UICorner", inputGlow).CornerRadius = UDim.new(0, 12)

    keyBox.Focused:Connect(function()
        TweenService:Create(inputGlow, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
    end)

    keyBox.FocusLost:Connect(function()
        TweenService:Create(inputGlow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    end)

    -- Submit Button
    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.Size = UDim2.new(1, -40, 0, 50)
    submitBtn.Position = UDim2.new(0, 20, 0, 170)
    submitBtn.Text = "UNLOCK ACCESS"
    submitBtn.BackgroundTransparency = 1
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 20
    submitBtn.ZIndex = 11

    -- Button Gradient
    local btnGradient = Instance.new("UIGradient", submitBtn)
    btnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 255))
    }
    btnGradient.Rotation = 90

    -- Button Frame
    local btnFrame = Instance.new("Frame", submitBtn)
    btnFrame.Size = UDim2.new(1, 0, 1, 0)
    btnFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    btnFrame.BorderSizePixel = 0
    btnFrame.ZIndex = 10
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 10)

    -- Button Glow
    local btnGlow = Instance.new("Frame", submitBtn)
    btnGlow.Size = UDim2.new(1, 6, 1, 6)
    btnGlow.Position = UDim2.new(0, -3, 0, -3)
    btnGlow.BackgroundColor3 = Color3.fromRGB(70, 120, 255)
    btnGlow.BorderSizePixel = 0
    btnGlow.BackgroundTransparency = 0.8
    btnGlow.ZIndex = 9
    Instance.new("UICorner", btnGlow).CornerRadius = UDim.new(0, 13)

    -- Get Key Button
    local getKeyBtn = Instance.new("TextButton", frame)
    getKeyBtn.Size = UDim2.new(1, -40, 0, 40)
    getKeyBtn.Position = UDim2.new(0, 20, 0, 230)
    getKeyBtn.Text = "GET KEY IN DISCORD"
    getKeyBtn.BackgroundTransparency = 1
    getKeyBtn.TextColor3 = Color3.fromRGB(150, 150, 255)
    getKeyBtn.Font = Enum.Font.Gotham
    getKeyBtn.TextSize = 16
    getKeyBtn.ZIndex = 11

    -- Button Animations
    submitBtn.MouseEnter:Connect(function()
        TweenService:Create(btnGlow, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(btnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 80)}):Play()
    end)

    submitBtn.MouseLeave:Connect(function()
        TweenService:Create(btnGlow, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
        TweenService:Create(btnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 70)}):Play()
    end)

    getKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 255)}):Play()
    end)

    getKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 255)}):Play()
    end)

    -- Button Click Effects
    local function clickEffect(button)
        local originalSize = button.Size
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0.9, 0)}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize}):Play()
    end

    submitBtn.MouseButton1Click:Connect(function()
        clickEffect(submitBtn)
        local enteredKey = keyBox.Text:upper():gsub("%s+", "")
        if enteredKey == VALID_KEY then
            notify("✅ Authentication Successful!")
            wait(0.5)
            notify("🔓 XynHub key Unlocked")
            keyGui:Destroy()
            if onCorrectKey then onCorrectKey() end
        else
            notify("❌ Invalid Key! Access Denied")
            -- Shake animation
            local originalPos = inputFrame.Position
            for i = 1, 4 do
                TweenService:Create(inputFrame, TweenInfo.new(0.05), {Position = UDim2.new(0, 20 + (i%2==0 and 5 or -5), 0, 110)}):Play()
                wait(0.05)
            end
            TweenService:Create(inputFrame, TweenInfo.new(0.1), {Position = originalPos}):Play()
        end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        clickEffect(getKeyBtn)
        pcall(function()
            setclipboard("https://discord.gg/qfwXXf4EA9")
        end)
        notify("🔗 Discord Link Copied!")
    end)

    return keyGui
end

-- Initialize the key system with game loader inside callback
createKeyGui(function()
    -- Game loader now only runs after successful authentication
    local placeId = game.PlaceId
    local gameName, success = nil, false

    -- Fixed duplicate PlaceId check
    if placeId == 121864768012064 then
        gameName = "Fish It"
        pcall(function()
            loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
        end)
        success = true
    elseif placeId == 127742093697776 then
        gameName = "Plant Vs Brainrots"
        pcall(function()
            loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/8da29ab7864a448e"))()
        end)
        success = true
    elseif placeId == 18687417158 then
        gameName = "Forsaken"
        pcall(function()
            loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
        end)
        success = true
    elseif placeId == 131716211654599 then
        gameName = "Fisch 🐟"
        pcall(function()
            loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/18468d6a99cee147"))()
        end)
        success = true
    elseif placeId == 109983668079237 then
        gameName = "Steal A Brainrot"
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-6/main.lua"))()
        end)
        success = true
    end

    -- Fixed branding to XynHub
    if success and gameName then
        StarterGui:SetCore("SendNotification", {
            Title = "XynHub Loaded!",
            Text = gameName .. " script loaded!",
            Duration = 6,
            Icon = "rbxassetid://6023426926"
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "XynHub",
            Text = (gameName or "Game") .. " Not Supported!",
            Duration = 6,
            Icon = "rbxassetid://6023426923"
        })
    end
    
    print("XynHub successfully loaded!")
end)
