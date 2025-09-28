local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local nexaIntro = Instance.new("ScreenGui")
nexaIntro.Name = "NexaIntro"
nexaIntro.ResetOnSpawn = false
nexaIntro.IgnoreGuiInset = true
nexaIntro.Parent = playerGui

local spawnEffect = Instance.new("Frame")
spawnEffect.Size = UDim2.new(1, 0, 1, 0)
spawnEffect.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
spawnEffect.BackgroundTransparency = 1
spawnEffect.Parent = nexaIntro

local container = Instance.new("Frame")
container.Size = UDim2.new(0, 900, 0, 200)
container.Position = UDim2.new(0.5, -450, 0.5, -100)
container.BackgroundTransparency = 1
container.Parent = nexaIntro

local function createLetter(char, isNexa)
    local letterFrame = Instance.new("Frame")
    letterFrame.Size = UDim2.new(0, 100, 0, 120)
    letterFrame.BackgroundTransparency = 1
    letterFrame.Parent = container

    local glow = Instance.new("TextLabel")
    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.Text = char
    glow.TextScaled = true
    glow.Font = Enum.Font.GothamBlack
    glow.BackgroundTransparency = 1
    glow.TextTransparency = 1
    glow.TextStrokeTransparency = 1
    glow.ZIndex = 1
    glow.Parent = letterFrame

    local main = Instance.new("TextLabel")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.Text = char
    main.TextScaled = true
    main.Font = Enum.Font.GothamBlack
    main.BackgroundTransparency = 1
    main.TextTransparency = 1
    main.TextStrokeTransparency = 1
    main.ZIndex = 2
    main.Parent = letterFrame

    local gradient = Instance.new("UIGradient")
    if isNexa then
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
        }
        glow.TextColor3 = Color3.fromRGB(0, 150, 255)
        glow.TextStrokeColor3 = Color3.fromRGB(0, 100, 200)
    else
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
        }
        glow.TextColor3 = Color3.fromRGB(255, 255, 255)
        glow.TextStrokeColor3 = Color3.fromRGB(200, 200, 200)
    end
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    gradient.Rotation = 90
    gradient.Parent = main

    return letterFrame, main, glow
end

local letters = {}
local text = "XYN HUB"
local index = 0

for i = 1, #text do
    local char = text:sub(i,i)
    if char ~= " " then
        local isNexa = i <= 4
        local frame, main, glow = createLetter(char, isNexa)
        frame.Position = UDim2.new(0, index*110, 0, 40)

        table.insert(letters, {
            frame = frame,
            main = main,
            glow = glow,
            isNexa = isNexa
        })
        index += 1
    end
end

spawn(function()
    local spawnTween = TweenService:Create(spawnEffect, TweenInfo.new(0.5), {
        BackgroundTransparency = 0.8
    })
    spawnTween:Play()

    spawnTween.Completed:Connect(function()
        TweenService:Create(spawnEffect, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
    end)

    for i, letterData in ipairs(letters) do
        local frame = letterData.frame
        local main = letterData.main
        local glow = letterData.glow

        frame.Position = UDim2.new(0, (i-1)*110, 0, -200)
        frame.Size = UDim2.new(0, 100, 0, 0)

        local spawnTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, (i-1)*110, 0, 40),
            Size = UDim2.new(0, 100, 0, 120)
        })
        spawnTween:Play()

        wait(0.2)
        local glowTween = TweenService:Create(glow, TweenInfo.new(0.4), {
            TextTransparency = 0.6,
            TextStrokeTransparency = 0.3
        })
        glowTween:Play()

        wait(0.1)
        local mainTween = TweenService:Create(main, TweenInfo.new(0.5), {
            TextTransparency = 0,
            TextStrokeTransparency = 0
        })
        mainTween:Play()

        if letterData.isNexa then
            spawn(function()
                while frame.Parent do
                    TweenService:Create(main, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        TextStrokeTransparency = 0
                    }):Play()
                    wait(3)
                end
            end)
        end

        wait(0.25)
    end

    wait(3)

    local darkFade = Instance.new("Frame")
    darkFade.Size = UDim2.new(1, 0, 1, 0)
    darkFade.BackgroundColor3 = Color3.new(0, 0, 0)
    darkFade.BackgroundTransparency = 1
    darkFade.Parent = nexaIntro

    local darkTween = TweenService:Create(darkFade, TweenInfo.new(0.8), {
        BackgroundTransparency = 0.7
    })
    darkTween:Play()

    for i, letterData in ipairs(letters) do
        local frame = letterData.frame
        local main = letterData.main
        local glow = letterData.glow

        local explodeTween = TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, (i-1)*110 + math.random(-300, 300), 0, math.random(-200, 200)),
            Rotation = math.random(-360, 360),
            Size = UDim2.new(0, 100, 0, 120)
        })
        explodeTween:Play()

        TweenService:Create(main, TweenInfo.new(0.4), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        }):Play()

        TweenService:Create(glow, TweenInfo.new(0.4), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        }):Play()

        wait(0.08)
    end

    local whiteFlash = Instance.new("Frame")
    whiteFlash.Size = UDim2.new(1, 0, 1, 0)
    whiteFlash.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteFlash.BackgroundTransparency = 1
    whiteFlash.Parent = nexaIntro

    local whiteTween = TweenService:Create(whiteFlash, TweenInfo.new(0.2), {
        BackgroundTransparency = 0
    })
    whiteTween:Play()

    whiteTween.Completed:Connect(function()
        TweenService:Create(whiteFlash, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
    end)

    wait(0.5)
    nexaIntro:Destroy()
end)

local placeId = game.PlaceId
local StarterGui = game:GetService("StarterGui")
local gameName, success = nil, false

if placeId == 121864768012064 then
    gameName = "Fish It"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
    success = true
elseif placeId == 127742093697776 then
    gameName = "Plant Vs Brainrots"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/b3b9788fb28d2574"))()
    success = true
elseif placeId == 18687417158 then
    gameName = "Forsaken"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
    success = true
elseif placeId == 121864768012064 then
    gameName = "Fish It"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
    success = true
elseif placeId == 131716211654599 then
    gameName = "Fisch 🐟"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/18468d6a99cee147"))()
    success = true
elseif placeId == 109983668079237 then
    gameName = "Steal A Brainrot"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-6/main.lua"))()
    success = true
elseif placeId == 3456789012 then
    gameName = "Game 7"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-7/main.lua"))()
    success = true
elseif placeId == 4567890123 then
    gameName = "Game 8"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-8/main.lua"))()
    success = true
elseif placeId == 5678901234 then
    gameName = "Game 9"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-9/main.lua"))()
    success = true
elseif placeId == 6789012345 then
    gameName = "Game 10"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/username/game-10/main.lua"))()
    success = true
end

if success and gameName then
    StarterGui:SetCore("SendNotification", {
        Title = "NEXA HUB Loaded!",
        Text = gameName .. " script loader!",
        Duration = 6,
        Icon = "rbxassetid://6023426926"
    })
else
    StarterGui:SetCore("SendNotification", {
        Title = "NEXA HUB",
        Text = (gameName or "Game") .. " Not Found!",
        Duration = 6,
        Icon = "rbxassetid://6023426923"
    })
end
