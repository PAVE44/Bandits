local getBarricadeAble = function(x, y, z, index)
    local sq = getCell():getGridSquare(x, y, z)
    if sq and index >= 0 and index < sq:getObjects():size() then
        local o = sq:getObjects():get(index)
        if instanceof(o, 'BarricadeAble') then
            return o
        end
    end
    return nil
end

BanditServer = BanditServer or {}
BanditServer.Commands = {}

BanditServer.Commands.PostToggle = function(player, args)
    local gmd = GetBanditModData()
    if not (args.x and args.y and args.z) then return end

    local id = args.x .. "-" .. args.y .. "-" .. args.z
    
    if gmd.Posts[id] then
        gmd.Posts[id] = nil
    else
        gmd.Posts[id] = args
    end
end

BanditServer.Commands.PostUpdate = function(player, args)
    local gmd = GetBanditModData()
    if not (args.x and args.y and args.z) then return end

    local id = args.x .. "-" .. args.y .. "-" .. args.z
    gmd.Posts[id] = args
end

BanditServer.Commands.BaseUpdate = function(player, args)
    local gmd = GetBanditModData()
    if not (args.x and args.y) then return end

    local id = args.x .. "-" .. args.y
    gmd.Bases[id] = args
end

BanditServer.Commands.BanditRemove  = function(player, args)
    local gmd = GetBanditModData()
    local id = args.id
    if gmd.Queue[id] then
        gmd.Queue[id] = nil
        -- print ("[INFO] Bandit removed: " .. id)
    end
end

BanditServer.Commands.BanditFlush  = function(player, args)
    local gmd = GetBanditModData()
    gmd.Queue = {}
    gmd.VisitedBuildings = {}
    gmd.Posts = {}
    gmd.Bases = {}
    print ("[INFO] All bandits removed!!!")
end

BanditServer.Commands.BanditUpdatePart = function(player, args)
    local gmd = GetBanditModData()
    local id = args.id
    if id and gmd.Queue[id] then

        local brain = gmd.Queue[id]
        for k, v in pairs(args) do
            brain[k] = v
            -- print ("[INFO] Bandit sync id: " .. id .. " key: " .. k)
        end

        gmd.Queue[id] = brain

        sendServerCommand('Commands', 'UpdateBanditPart', args)
    end
end

BanditServer.Commands.AddEffect = function(player, args)
    sendServerCommand('BanditEffects', 'Add', args)
end

BanditServer.Commands.SpawnCustom = function(player, args)
    local radius = 0.5
    local knockedDown = false
    local crawler = false
    local fallOnFront = false
    local fakeDead = false
    local invulnerable = false
    local sitting = false

    local groupSize = args.size
    local gx = args.x or player:getX()
    local gy = args.y or player:getY()
    local gz = args.z or player:getZ()

    local gmd = GetBanditModData()
    local pid = BanditUtils.GetCharacterID(player)

    BanditCustom.Load()

    local cid
    if args.cid then 
        cid = args.cid
    elseif args.waveId then
        local clanData = BanditCustom.ClanGetAll()
        local cidChoices = {}
        for cid, clan in pairs(clanData) do
            if clan.spawn.wave == args.waveId then
                table.insert(cidChoices, cid)
            end
        end

        cid = BanditUtils.Choice(cidChoices)
    else
        return 
    end

    local banditOptions = BanditCustom.GetFromClan(cid)
    if not banditOptions then return end

    local keys = {}
    for key in pairs(banditOptions) do
        table.insert(keys, key)
    end

    for i = #keys, 2, -1 do
        local j = ZombRand(i) + 1
        keys[i], keys[j] = keys[j], keys[i]
    end

    local banditSelected = {}
    for i = 1, math.min(groupSize, #keys) do
        local key = keys[i]
        banditSelected[key] = banditOptions[key]
    end

    for bid, bandit in pairs(banditSelected) do
        local femaleChance = bandit.general.female and 100 or 0
        local health = 1 -- will be updated later

        local zombieList = BanditCompatibility.AddZombiesInOutfit(gx, gy, gz, "Naked", femaleChance, 
                                                                  crawler, fallOnFront, fakeDead, 
                                                                  knockedDown, invulnerable, sitting,
                                                                  health)
        for i=0, zombieList:size()-1 do
            local zombie = zombieList:get(i)
            local id = BanditUtils.GetCharacterID(zombie)

            local brain = {}

            -- auto-generated properties 
            brain.id = id
            brain.master = pid
            brain.inVehicle = false
            brain.fullname = BanditNames.GenerateName(bandit.general.female)
            brain.voice = Bandit.PickVoice(zombie)

            brain.born = getGameTime():getWorldAgeHours()
            brain.bornCoords = {}
            brain.bornCoords.x = gx
            brain.bornCoords.y = gy
            brain.bornCoords.z = gz

            brain.stationary = false
            brain.sleeping = false
            brain.aiming = false
            brain.moving = false
            brain.endurance = 1.00
            brain.speech = 0.00
            brain.sound = 0.00
            brain.infection = 0

            -- properties taken from args
            brain.program = {}
            brain.program.name = args.program
            brain.program.stage = "Prepare"

            brain.permanent = args.permanent and true or false
            brain.key = args.key

            -- properties taken from bandit custom profile
            local general = bandit.general
            brain.clan = general.cid
            brain.cid = general.cid
            brain.female = general.female or false
            brain.skin = general.skin or 1
            brain.hairType = general.hairType or 1
            brain.hairColor = general.hairColor or 1
            brain.beardType = general.beardType or 1
            brain.eatBody = false

            local health = general.health or 5
            brain.health = BanditUtils.Lerp(health, 1, 9, 1, 2.6)

            local accuracyBoost = general.sight or 5
            brain.accuracyBoost = BanditUtils.Lerp(accuracyBoost, 1, 9, -4, 4)

            local enduranceBoost = general.endurance or 5
            brain.enduranceBoost = BanditUtils.Lerp(enduranceBoost, 1, 9, 0.5, 1.5)

            local strengthBoost = general.strength or 5
            brain.strengthBoost = BanditUtils.Lerp(strengthBoost, 1, 9, 0.5, 1.5)

            brain.exp = {0, 0, 0}
            if general.exp1 and general.exp2 and general.exp3 then
                brain.exp = {general.exp1, general.exp2, general.exp3}
            end

            brain.weapons = {}
            if bandit.weapons then
                brain.weapons.melee = bandit.weapons.melee or "Base.BareHands"

                for _, slot in pairs({"primary", "secondary"}) do
                    brain.weapons[slot] = {}
                    brain.weapons[slot].bulletsLeft = 0
                    brain.weapons[slot].magCount = 0
                    if bandit.weapons[slot] and bandit.ammo[slot] then
                        brain.weapons[slot] = BanditWeapons.Make(bandit.weapons[slot], bandit.ammo[slot])
                    end
                end
            end

            brain.clothing = bandit.clothing or {}
            brain.bag = bandit.bag

            brain.loot = {}
            brain.inventory = {}
            brain.tasks = {}

            brain.personality = {}

            -- addiction and sickness
            brain.personality.alcoholic = (ZombRand(50) == 0)
            brain.personality.smoker = (ZombRand(4) == 0)
            brain.personality.compulsiveCleaner = (ZombRand(90) == 0)

            -- collectors
            brain.personality.comicsCollector = (ZombRand(80) == 0)
            brain.personality.gameCollector = (ZombRand(220) == 0)
            brain.personality.hottieCollector = (ZombRand(100) == 0)
            brain.personality.toyCollector = (ZombRand(220) == 0)
            brain.personality.videoCollector = (ZombRand(220) == 0)
            brain.personality.underwearCollector = (ZombRand(150) == 0)

            -- heritage
            brain.personality.fromPoland = (ZombRand(120) == 0) -- ku chwale ojczyzny!

            -- properties from clan
            local clan = BanditCustom.ClanGet(bandit.general.cid)
            local spawn = clan.spawn
            brain.hostile = not spawn.friendly

            gmd.Queue[id] = brain

            zombie:setHealth(health)
            zombie:setVariable("Bandit", false)
            zombie:setPrimaryHandItem(nil)
            zombie:setSecondaryHandItem(nil)
            zombie:clearAttachedItems()
            zombie:getModData().IsBandit = true
        end
    end
end

-- to be depracated
BanditServer.Commands.SpawnGroup = function(player, event)

    local getSkinTexture = function(female, id)
        -- must be deterministc, do not use random
        if female then
            local r = 1 + math.abs(id) % 5 
            return "FemaleBody0" .. tostring(r)
        else
            local r = 1 + math.abs(id) % 10
            if r > 5 then
                return "MaleBody0" .. tostring(r - 5) .. "a"
            else
                return "MaleBody0" .. tostring(r)
            end
        end
    end

    local radius = 0.5
    local knockedDown = false
    local crawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local isInvulnerable = false
    local isSitting = false
    local gmd = GetBanditModData()

    local gx = event.x
    local gy = event.y
    local gz = event.z or 0

    for _, bandit in pairs(event.bandits) do
 
        if #event.bandits > 1 then
            gx = ZombRand(gx - radius, gx + radius + 1)
            gy = ZombRand(gy - radius, gy + radius + 1)
        end

        -- bandit.outfit = "Naked"
        local zombieList = BanditCompatibility.AddZombiesInOutfit(gx, gy, gz, bandit.outfit, bandit.femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, isInvulnerable, isSitting, bandit.health)
        for i=0, zombieList:size()-1 do
            local zombie = zombieList:get(i)
            local zombieVisuals = zombie:getHumanVisual()
            local id = BanditUtils.GetCharacterID(zombie)

            zombie:setHealth(bandit.health)

            -- clients will change that flag to true once they recognize the bandit by its ID
            zombie:setVariable("Bandit", false)

            -- just in case
            zombie:setPrimaryHandItem(nil)
            zombie:setSecondaryHandItem(nil)
            zombie:clearAttachedItems()

            local brain = {}

            -- unique bandit id based on outfit
            brain.id = id

            -- permanent bandits will store bandit details
            brain.permanent = bandit.permanent

            -- flag to simulate being in a vehicle
            brain.inVehicle = false

            -- gender
            brain.female = zombie:isFemale()

            -- time of birth
            brain.born = getGameTime():getWorldAgeHours()

            -- place of birth
            brain.bornCoords = {}
            brain.bornCoords.x = gx
            brain.bornCoords.y = gy
            brain.bornCoords.z = gz

            -- initial health
            brain.health = bandit.health

            -- the player that spawned the bandit becomes his master, 
            -- this plays a role in particular programs like Companion
            brain.master = BanditUtils.GetCharacterID(player)

            -- for keyring
            brain.fullname = BanditNames.GenerateName(zombie:isFemale())

            -- which voice to use
            brain.voice = Bandit.PickVoice(zombie)

            -- hostility towards human players
            brain.hostile = event.hostile

            -- looks
            local hairColor = zombieVisuals:getHairColor()
            local beardColor = zombieVisuals:getBeardColor()

            brain.skinTexture = bandit.skinTexture and bandit.skinTexture or getSkinTexture(zombie:isFemale(), id)
            brain.hairStyle = bandit.hairStyle and bandit.hairStyle or zombieVisuals:getHairModel()
            brain.hairColor = bandit.hairColor and bandit.hairColor or {r=hairColor:getRedFloat(), g=hairColor:getGreenFloat(), b=hairColor:getBlueFloat()}
            brain.beardStyle = bandit.beardStyle and bandit.beardStyle or zombieVisuals:getBeardModel()
            brain.beardColor = bandit.beardColor and bandit.beardColor or {r=beardColor:getRedFloat(), g=beardColor:getGreenFloat(), b=beardColor:getBlueFloat()}
            brain.outfit = bandit.outfit

            -- copy clan abilities to the bandit
            brain.clan = bandit.clan
            brain.eatBody = bandit.eatBody
            brain.accuracyBoost = bandit.accuracyBoost

            -- the AI program to follow at start
            brain.program = {}
            brain.program.name = event.program.name
            brain.program.stage = event.program.stage

            -- random DNA
            local dna = {}
            dna.slow = BanditUtils.CoinFlip()
            dna.blind = BanditUtils.CoinFlip()
            dna.sneak = BanditUtils.CoinFlip()
            dna.unfit = BanditUtils.CoinFlip()
            dna.coward = BanditUtils.CoinFlip()

            -- action and state flags
            brain.stationary = false
            brain.sleeping = false
            brain.aiming = false
            brain.moving = false
            brain.endurance = 1.00
            brain.speech = 0.00
            brain.sound = 0.00
            brain.infection = 0

            -- inventory
            brain.weapons = bandit.weapons
            brain.loot = bandit.loot
            brain.key = bandit.key
            brain.inventory = {}
            
            -- empty task table, will be populated during bandit life
            brain.tasks = {}

            -- not used
            brain.world = {}

            -- print ("[INFO] Bandit " .. brain.fullname .. "(".. id .. ") from clan " .. bandit.clan .. " in outfit " .. bandit.outfit .. " has joined the game.")
            gmd.Queue[id] = brain

            zombie:getModData().IsBandit = true
        end
    end
end

BanditServer.Commands.SpawnRestore = function(player, brain)
    local gmd = GetBanditModData()
    local knockedDown = false
    local crawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local isInvulnerable = false
    local isSitting = false
    local health = brain.health or 2
    local outfit = brain.outfit
    local oldId = brain.id
    local gx = brain.bornCoords.x
    local gy = brain.bornCoords.y
    local gz = brain.bornCoords.z

    local femaleChance = 0
    if brain.female then
        femaleChance = 100
    end

    local zombieList = BanditCompatibility.AddZombiesInOutfit(gx, gy, gz, outfit, femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, isInvulnerable, isSitting, health)
    for i=0, zombieList:size()-1 do
        local zombie = zombieList:get(i)
        local id = BanditUtils.GetCharacterID(zombie)

        zombie:setHealth(health)

        -- clients will change that flag to true once they recognize the bandit by its ID
        zombie:setVariable("Bandit", false)

        -- just in case
        zombie:setPrimaryHandItem(nil)
        zombie:setSecondaryHandItem(nil)
        zombie:clearAttachedItems()

        -- we have new id
        brain.id = id

        -- swap
        gmd.Queue[oldId] = nil
        gmd.Queue[id] = brain

        zombie:getModData().IsBandit = true
    end
end

BanditServer.Commands.Unbarricade = function(player, args)
    local object = getBarricadeAble(args.x, args.y, args.z, args.index)
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
    local object = getBarricadeAble(args.x, args.y, args.z, args.index)
    if object then
        local barricade = IsoBarricade.AddBarricadeToObject(object, player)
        if barricade then
            if not barricade:isMetal() and args.isMetal then
                local metal = BanditCompatibility.InstanceItem("Base.SheetMetal")
                metal:setCondition(args.condition)
                barricade:addMetal(nil, metal)
                barricade:transmitCompleteItemToClients()
            elseif not barricade:isMetalBar() and args.isMetalBar then
                local metal = BanditCompatibility.InstanceItem("Base.MetalBar")
                metal:setCondition(args.condition)
                barricade:addMetalBar(nil, metal)
                barricade:transmitCompleteItemToClients()
            elseif barricade:getNumPlanks() < 4 then
                local plank = BanditCompatibility.InstanceItem("Base.Plank")
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

BanditServer.Commands.OpenDoor = function(player, args)
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

BanditServer.Commands.CloseDoor = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
            if object:IsOpen() then
                object:ToggleDoorSilent()
            end
        end
    end
end

BanditServer.Commands.LockDoor = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
            if not object:isLockedByKey() then
                object:setLockedByKey(true)
            end
        end
    end
end

BanditServer.Commands.UnlockDoor = function(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if sq and args.index >= 0 and args.index < sq:getObjects():size() then
        local object = sq:getObjects():get(args.index)
        if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
            if object:isLockedByKey() then
                object:setLockedByKey(false)
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

BanditServer.Commands.IncrementBanditKills = function(player, args)
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(player)
    if gmd.Kills[id] then
        gmd.Kills[id] = gmd.Kills[id] + 1
    else
        gmd.Kills[id] = 1
    end
end

BanditServer.Commands.ResetBanditKills = function(player, args)
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(player)
    if gmd.Kills[id] then
        gmd.Kills[id] = 0
    end
end

BanditServer.Commands.UpdateVisitedBuilding = function(player, args)
    local gmd = GetBanditModData()
    gmd.VisitedBuildings[args.bid] = args.wah 
end

local onClientCommand = function(module, command, player, args)
    if module == "Commands" and BanditServer[module] and BanditServer[module][command] then
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
