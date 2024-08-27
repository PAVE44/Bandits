BanditServer = {}
BanditServer.Commands = {}
BanditServer.Broadcaster = {}

BanditServer.Commands.GuardpostToggle = function(player, args)
    local gmd = GetBanditModData()
    if not (args.x and args.y and args.z) then return end

    local id = args.x .. "-" .. args.y .. "-" .. args.z
    
    if gmd.Guardposts[id] then
        gmd.Guardposts[id] = nil
    else
        gmd.Guardposts[id] = args
    end
end

BanditServer.Commands.UpdatePlayer = function(player, args)
    local gmd = GetBanditModData()
    local id = args.id
    gmd.OnlinePlayers[id] = args
end

BanditServer.Commands.BanditRemove  = function(player, args)
    local gmd = GetBanditModData()
    local id = args.id
    if gmd.Queue[id] then
        gmd.Queue[id] = nil
        print ("QUEUE REMOVED: " .. id)
    end
end

BanditServer.Commands.SpawnGroup = function(player, event)
    local radius = 0.5
    local knockedDown = false
    local crawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local gmd = GetBanditModData()

    local gx = event.x
    local gy = event.y
    local gz = event.z or 0

    for _, bandit in pairs(event.bandits) do
 
        if #event.bandits > 1 then
            gx = ZombRand(gx - radius, gx + radius + 1)
            gy = ZombRand(gy - radius, gy + radius + 1)
        end

        local zombieList = addZombiesInOutfit(gx, gy, gz, 1, bandit.outfit, bandit.femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, bandit.health)
        for i=0, zombieList:size()-1 do
            local zombie = zombieList:get(i)
            local id = BanditUtils.GetCharacterID(zombie)

            -- zombie:setUseless(false)
            zombie:setVariable("Bandit", false)

            local brain = {}
            brain.id = id
            brain.master = BanditUtils.GetCharacterID(player)
            brain.fullname = BanditNames.GenerateName(zombie:isFemale())
            brain.hostile = event.hostile
            brain.clan = bandit.clan
            brain.eatBody = bandit.eatBody
            brain.accuracyBoost = bandit.accuracyBoost
            brain.stationary = false
            brain.sleeping = false
            brain.endurance = 1.00
            brain.speech = 0.00

            brain.weapons = bandit.weapons
            brain.loot = bandit.loot

            brain.program = {}
            brain.program.name = event.program.name
            brain.program.stage = event.program.stage
            brain.program.params = {}

            -- capabilities are program specific, not clan specific
            brain.capabilities = ZombiePrograms[event.program.name].GetCapabilities()
            
            brain.inventory = {}
            table.insert(brain.inventory, "weldingGear")
            table.insert(brain.inventory, "crowbar")
            
            brain.world = {}
            
            brain.tasks = {}

            print ("[INFO] Bandit " .. brain.fullname .. "(".. id .. ") from clan " .. bandit.clan .. " in outfit " .. bandit.outfit .. " has joined the game.")
            gmd.Queue[id] = brain
        end
    end
end

local _getBarricadeAble = function(x, y, z, index)
    local sq = getCell():getGridSquare(x, y, z)
    if sq and index >= 0 and index < sq:getObjects():size() then
        local o = sq:getObjects():get(index)
        if instanceof(o, 'BarricadeAble') then
            return o
        end
    end
    return nil
end

BanditServer.Commands.Unbarricade = function(player, args)
    local object = _getBarricadeAble(args.x, args.y, args.z, args.index)
    if object then
        local barricade = object:getBarricadeOnSameSquare()
        if not barricade then barricade = object:getBarricadeOnOppositeSquare() end
        if barricade then
            if barricade:isMetal() then
                local metal = barricade:removeMetal(nil)
            elseif barricade:isMetalBar() then
                local bar = barricade:removeMetalBar(nil)
            else
                local plank = barricade:removePlank(nil)
                if barricade:getNumPlanks() > 0 then
                    barricade:sendObjectChange('state')
                end
            end
        end
    end
end

BanditServer.Commands.Barricade = function(player, args)
    local object = _getBarricadeAble(args.x, args.y, args.z, args.index)
    if object then
        local barricade = IsoBarricade.AddBarricadeToObject(object, player)
        if barricade then
            if not barricade:isMetal() and args.isMetal then
                local metal = InventoryItemFactory.CreateItem('Base.SheetMetal')
                metal:setCondition(args.condition)
                barricade:addMetal(nil, metal)
                barricade:transmitCompleteItemToClients()
            elseif not barricade:isMetalBar() and args.isMetalBar then
                local metal = InventoryItemFactory.CreateItem('Base.MetalBar')
                metal:setCondition(args.condition)
                barricade:addMetalBar(nil, metal)
                barricade:transmitCompleteItemToClients()
            elseif barricade:getNumPlanks() < 4 then
                local plank = InventoryItemFactory.CreateItem('Base.Plank')
                plank:setCondition(args.condition)
                barricade:addPlank(nil, plank)
                if barricade:getNumPlanks() == 1 then
                    barricade:transmitCompleteItemToClients()
                else
                    barricade:sendObjectChange('state')
                end
            end
        end
    else
        noise('expected BarricadeAble')
    end
end

BanditServer.Commands.ToggleDoor = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
            if not object:IsOpen() then
                object:ToggleDoorSilent()
            end
        end
    end
end

BanditServer.Commands.VehicleSpawn = function(player, args)
    local square = getCell():getGridSquare(args.x, args.y, 0)
    if square then
        local vehicle = addVehicleDebug(args.type, IsoDirections.S, nil, square)
        if vehicle then
            for i = 0, vehicle:getPartCount() - 1 do
                local container = vehicle:getPartByIndex(i):getItemContainer()
                if container then
                    container:removeAllItems()
                end
            end
            vehicle:repair()
            vehicle:setColor(0, 0, 0)

            if ZombRand(3) == 1 then
                vehicle:setAlarmed(true)
            end

            local cond = (2 + ZombRand(8)) / 10
            vehicle:setGeneralPartCondition(cond, 80)
            if args.engine then
                vehicle:tryStartEngine(true)
                vehicle:engineDoStartingSuccess()
                vehicle:engineDoRunning()
            end

            if args.lights then
                vehicle:setHeadlightsOn(true)
            end

            if args.lightbar or args.siren or args.alarm then
                local newargs = {id=vehicle:getId(), lightbar=args.lightbar, siren=args.siren, alarm=args.alarm}
                sendServerCommand('Commands', 'UpdateVehicle', newargs)
            end
        end
    end
end

BanditServer.Commands.VehiclePartRemove = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, 0)
    if sq then
        local vehicle = sq:getVehicleContainer()
        if vehicle then
            local vehiclePart = vehicle:getPartById(args.id)
            if vehiclePart then
                vehiclePart:setInventoryItem(nil)
                vehicle:transmitPartItem(vehiclePart)
                vehicle:updatePartStats()
            end
        end
    end
end

BanditServer.Commands.VehiclePartDamage = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, 0)
    if sq then
        local vehicle = sq:getVehicleContainer()
        if vehicle then
            local vehiclePart = vehicle:getPartById(args.id)
            if vehiclePart then
                vehiclePart:damage(args.dmg)

                if vehiclePart:getCondition() <= 0 then
                    vehiclePart:setInventoryItem(nil)
                    vehicle:transmitPartItem(vehiclePart)
                else
                    vehicle:transmitPartCondition(vehiclePart)
                end
                vehicle:updatePartStats()
            end
        end
    end
end

-- main
local onClientCommand = function(module, command, player, args)
    if BanditServer[module] and BanditServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("received " .. module .. "." .. command .. " "  .. argStr)
        BanditServer[module][command](player, args)
        TransmitBanditModData()
    end
end

Events.OnClientCommand.Add(onClientCommand)
