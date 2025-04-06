BanditServer = BanditServer or {}
BanditServer.Custom = {}

BanditServer.Custom.SendToClients  = function(player, argsOld)
    local args = {}
    args.banditData = BanditCustom.banditData
    args.clanData = BanditCustom.clanData
    sendServerCommand('Commands', 'SendCustomToClients', args)
end

BanditServer.Custom.ReceiveFromClient  = function(player, args)
    BanditCustom.banditData = args.banditData
    BanditCustom.clanData = args.clanData
    BanditCustom.Save()
    sendServerCommand('Commands', 'SendCustomToClients', args)
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

Events.OnClientCommand.Add(onClientCommand)