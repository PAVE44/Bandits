BanditServer = {}
BanditServer.Commands = {}
BanditServer.Broadcaster = {}

BanditServer.Commands.UpdatePlayer = function(player, args)
    local gmd = GetBanditModData()
    local id = args.id
    gmd.OnlinePlayers[id] = args
end

BanditServer.Commands.SyncBrainToClients = function(player, args)
    sendServerCommand('Commands', 'SyncBrainToClients', args)
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
    local gz = 0

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
            brain.loot = bandit.loot
            brain.enslaved = true
            brain.sleeping = false
            brain.combat = false
            brain.firing = false
            brain.endurance = 1.00
            brain.speech = 0.00

            brain.weapons = bandit.weapons

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

            gmd.Queue[id] = brain
        end
    end
end

BanditServer.Commands.Unbarricade = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, 'BarricadeAble') then
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
end

BanditServer.Commands.Barricade = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, 'BarricadeAble') then
            local barricade = object:getBarricadeOnSameSquare()
            if not barricade then barricade = object:getBarricadeOnOppositeSquare() end

            if not barricade then
                local barricade = IsoBarricade.AddBarricadeToObject(object, player)
                if barricade then
                    local metal = InventoryItemFactory.CreateItem('Base.MetalBar')
                    metal:setCondition(100)
                    barricade:addMetalBar(player, metal)
                    barricade:transmitCompleteItemToClients()
                end
            end
        end
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
