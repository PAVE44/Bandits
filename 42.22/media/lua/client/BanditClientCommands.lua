ZSClient = {}
ZSClient.Commands = {}

ZSClient.Commands.UpdateVehicle = function(args)
    for i=0, 100 do
        local vehicleList = getCell():getVehicles():toArray()
        for _, vehicle in pairs(vehicleList) do
            if vehicle:getId() == args.id then
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
        local zombie = BanditZombie.GetInstanceById(id)
        if zombie then
            local health = zombie:getHealth()
            -- print ("CLIENT HEALTH CURRENT: " .. health .. " NEW:" .. args.h)
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

-- partial brain update pushed by the server after a BanditUpdatePart; applied to
-- the live brain when this client has the body and to the local roster copy, so
-- a later banditize starts from current data. The sending client already holds
-- the state and skips its own echo, otherwise a change made in flight would be
-- reverted.
ZSClient.Commands.UpdateBanditPart = function(args)
    local id = args.id
    if not id then return end

    local player = getSpecificPlayer(0)
    if args.origin and player and args.origin == player:getOnlineID() then return end

    local targets = {}
    local gmd = GetBanditClusterData(id)
    if gmd and gmd[id] then
        targets[gmd[id]] = true
    end
    local zombie = BanditZombie.GetInstanceById(id)
    local brain = zombie and BanditBrain.Get(zombie)
    if brain then
        targets[brain] = true
    end

    for target in pairs(targets) do
        for k, v in pairs(args) do
            if k ~= "id" and k ~= "origin" and k ~= "tasks" then
                target[k] = v
            end
        end
    end
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
