BanditPlayer = BanditPlayer or {}

BanditPlayer.UpdatePlayersOnline = function ()
    if not isServer() then
        local player = getPlayer()
        if player then
            local playerData = {}
            playerData.id = BanditUtils.GetCharacterID(player)
            playerData.name = player:getDisplayName()
            playerData.isGhost = player:isGhostMode()
            sendClientCommand(player, 'Commands', 'UpdatePlayer', playerData)
        end
        local gmd = GetBanditModData()
        for _, p in pairs(gmd.OnlinePlayers) do
            -- print ("PLAYER:" .. p.name .. " (" .. p.id .. ") GHOST: " .. tostring(p.isGhost))
        end
    end
end

BanditPlayer.IsGhost = function(player)
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(player)
    if gmd.OnlinePlayers[id] then
        return gmd.OnlinePlayers[id].isGhost
    end
    return false
end

Events.EveryOneMinute.Add(BanditPlayer.UpdatePlayersOnline)