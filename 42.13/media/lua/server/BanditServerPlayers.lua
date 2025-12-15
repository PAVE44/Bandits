BanditServer = BanditServer or {}
BanditServer.Players = {}

BanditServer.Players.PlayerUpdate = function(player, args)
    local gmd = GetBanditModDataPlayers()
    local id = args.id
    gmd.OnlinePlayers[id] = args
end

local onClientCommand = function(module, command, player, args)
    if module == "Players" and BanditServer[module] and BanditServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("received " .. module .. "." .. command .. " "  .. argStr)
        BanditServer[module][command](player, args)

        TransmitBanditModDataPlayers()
    end
end

Events.OnClientCommand.Add(onClientCommand)
