ZSClient = {}
ZSClient.Commands = {}

ZSClient.Commands.UpdateVehicle = function(args)
    for i=0, 100 do
        local vehicleList = getCell():getVehicles()
        for i=0, vehicleList:size()-1 do
            local vehicle = vehicleList:get(i)
            if vehicle and vehicle:getId() == args.id then
                if vehicle:hasLightbar() then 
                    if args.lightbar then
                        vehicle:setLightbarLightsMode(args.lightbar)
                    end
                    if args.siren then
                        vehicle:setLightbarSirenMode(args.siren)
                    end
                end 

                if args.alarm then
                    vehicle:setAlarmed(true)
                    vehicle:triggerAlarm()
                end
                return
            end
        end
    end
end

ZSClient.Commands.UpdateHealth  = function(args)
    local id = args.id
    if id then
        local zombie = BanditZombie.Cache[id]
        if zombie then
            local health = zombie:getHealth()
            print ("CLIENT HEALTH CURRENT: " .. health .. " NEW:" .. args.h)
            if health > args.h then
                zombie:setHealth(args.h)
            end
        end
    end
end

ZSClient.Commands.SendCustomToClients = function(args)
    BanditCustom.banditData = args.banditData
    BanditCustom.clanData = args.clanData
    BanditCustom.Save()
end

ZSClient.Commands.SetMarker  = function(args)
    BanditEventMarkerHandler.set(getRandomUUID(), args.icon, args.time, args.x, args.y, args.color, args.desc)
end

local onServerCommand = function(module, command, args)
    if ZSClient[module] and ZSClient[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("client received " .. module .. "." .. command .. " "  .. argStr)
        ZSClient[module][command](args)
    end
end

Events.OnServerCommand.Add(onServerCommand)
