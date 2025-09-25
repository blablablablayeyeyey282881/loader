local userId = game.Players.LocalPlayer.UserId
local blacklist = {
}

for _, id in pairs(blacklist) do
    if userId == id then
        game.Players.LocalPlayer:Kick("You have been Blacklisted from using Nexa Hub.")
        break
    end
end


setclipboard("https://discord.gg/EabKZjJGGF")

local scripts = {
    -- fish it
    [121864768012064] = "loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/f196a0a2c3db9e4c"))()",
  
    -- My Singing Brainrot
    [127742093697776] = "loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/21bb87d616bf1fec"))()",

}

local url = scripts[game.PlaceId]
if url then
    loadstring(game:HttpGet(url))()
else
    game.Players.LocalPlayer:Kick("NEXA HUB does not support this game.")
end
