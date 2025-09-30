local placeId = game.PlaceId
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local gameName, success = nil, false

-- Deteksi perangkat
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = not isMobile

-- Fungsi deteksi executor
local function getExecutor()
    -- Deteksi Delta
    if delta or DELTA then
        return "delta"
    end
    
    -- Deteksi executor lainnya
    if syn then
        return "synapse"
    elseif KRNL_LOADED then
        return "krnl"
    elseif Fluxus then
        return "fluxus"
    elseif identifyexecutor then
        return identifyexecutor():lower()
    end
    
    return "unknown"
end

-- Fungsi untuk menjalankan script berdasarkan perangkat dan executor
local function runScript(config)
    if isPC then
        if config.pc then
            loadstring(game:HttpGet(config.pc))()
            return true, "PC script loaded"
        end
    elseif isMobile then
        -- Khusus untuk Plant Vs Brainrots di mobile
        if config.name == "Plant Vs Brainrots" then
            local executor = getExecutor()
            
            if executor == "delta" then
                -- Jalankan script mobile jika Delta
                if config.mobile then
                    loadstring(game:HttpGet(config.mobile))()
                    return true, "Mobile script loaded (Delta)"
                end
            else
                -- Alihkan ke script PC jika bukan Delta
                if config.pc then
                    loadstring(game:HttpGet(config.pc))()
                    return true, "PC script loaded (Mobile mode)"
                end
            end
        else
            -- Game lainnya di mobile
            if config.mobile then
                loadstring(game:HttpGet(config.mobile))()
                return true, "Mobile script loaded"
            end
        end
    end
    return false, "No script available"
end

-- Konfigurasi game dengan URL terpisah untuk PC/Mobile
local gameConfigs = {
    [121864768012064] = {
        name = "Fish It",
        pc = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c",
        mobile = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"
    },
    [127742093697776] = {
        name = "Plant Vs Brainrots",
        pc = "https://pandadevelopment.net/virtual/file/7a5d3ecc207b5a1b",
        mobile = "https://pandadevelopment.net/virtual/file/4ea37beb93387fb0"
    },
    [18687417158] = {
        name = "Forsaken",
        pc = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c",
        mobile = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"
    },
    [131716211654599] = {
        name = "Fisch 🐟",
        pc = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c",
        mobile = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"
    },
    [109983668079237] = {
        name = "Steal A Brainrot",
        pc = "https://raw.githubusercontent.com/username/game-6/main.lua",
        mobile = "https://raw.githubusercontent.com/username/game-6/mobile.lua"
    },
    -- Tambahkan game lainnya dengan format yang sama
}

-- Eksekusi script berdasarkan PlaceId
local config = gameConfigs[placeId]
local message = ""
if config then
    gameName = config.name
    success, message = runScript(config)
end

-- Notifikasi hasil
if success and gameName then
    StarterGui:SetCore("SendNotification", {
        Title = "NEXA HUB Loaded!",
        Text = gameName .. " - " .. message,
        Duration = 6,
        Icon = "rbxassetid://6023426926"
    })
else
    local errorMsg = message or ((gameName or "Game") .. " not supported")
    
    -- Pesan khusus untuk Plant Vs Brainrots di mobile dengan executor selain Delta
    if gameName == "Plant Vs Brainrots" and isMobile and getExecutor() ~= "delta" then
        errorMsg = "Switched to PC mode (Mobile only supports Delta)"
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "NEXA HUB",
        Text = errorMsg,
        Duration = 6,
        Icon = "rbxassetid://6023426923"
    })
end
