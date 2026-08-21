BanditServer = BanditServer or {}
BanditServer.Custom = {}

BanditServer.Custom.SendStats = function()
    local stats = BanditCustom.GetStats()
    sendServerCommand('Custom', 'SendCustomStatsToClient', stats)
end

BanditServer.Custom.ReceiveFromClient  = function(player, args)
    print("[BANDITS] Received Custom Bandits data from client.")
    BanditCustom.banditData = args.banditData
    BanditCustom.clanData = args.clanData
    BanditCustom.Save()
    BanditServer.Custom.SendStats()
end

local function onClientCommand(module, command, player, args)
    if module == "Custom" and BanditServer[module] and BanditServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("received " .. module .. "." .. command .. " "  .. argStr)
        BanditServer[module][command](player, args)
    end
end

local function onServerStarted()
    BanditCustom.Load()
    print("[BANDITS] Custom Bandits loaded successfully.")
end

Events.OnClientCommand.Add(onClientCommand)
Events.OnServerStarted.Add(onServerStarted)