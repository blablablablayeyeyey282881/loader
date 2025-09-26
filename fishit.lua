-- Perbaikan script (paste-friendly)
local player = game.Players.LocalPlayer
local userId = player and player.UserId or 0

-- blacklist harus angka jika dibandingkan dengan userId
local blacklist = {
    -- contoh: 12345678,
}

for _, id in pairs(blacklist) do
    if userId == id then
        player:Kick("You have been Blacklisted from using Nexa Hub.")
        return
    end
end

-- setclipboard kadang memerlukan executor yang support; pcall supaya aman
pcall(function() setclipboard("https://discord.gg/EabKZjJGGF") end)

-- simpan HANYA URL di table ini
local scripts = {
    -- fish it (contoh PlaceId, ganti dengan PlaceId yang benar)
    [121864768012064] = "https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c",
  
    -- PvB
    [127742093697776] = "https://pandadevelopment.net/virtual/file/5e67cc02173e3850"",
}

local placeId = game.PlaceId
local url = scripts[placeId]

if url then
    -- aman: pcall untuk tangkap error HttpGet / loadstring
    local ok, err = pcall(function()
        local response = game:HttpGet(url) -- ambil kode dari URL
        local func = loadstring(response)
        if type(func) == "function" then
            func()
        else
            error("loadstring returned non-function")
        end
    end)
    if not ok then
        -- tampilkan error (atau kick sesuai kebutuhan)
        warn("FAILED FAILED:", err)
        -- game.Players.LocalPlayer:Kick("Failed to load script: "..tostring(err))
    end
else
    player:Kick("NEXA HUB does not support this game.")
end
