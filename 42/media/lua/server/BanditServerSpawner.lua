local LogLevel = 0

local function daysInMonth(month)
    local daysPerMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    return daysPerMonth[month]
end

local function calculateHourDifference(startHour, startDay, startMonth, startYear, hour, day, month, year)
    local startTotalHours = startHour + (startDay - 1) * 24
    for m = 1, startMonth - 1 do
        startTotalHours = startTotalHours + daysInMonth(m) * 24
    end
    startTotalHours = startTotalHours + (startYear * 365 * 24) 

    local totalHours = hour + (day - 1) * 24
    for m = 1, month - 1 do
        totalHours = totalHours + daysInMonth(m) * 24
    end
    totalHours = totalHours + (year * 365 * 24) 

    return totalHours - startTotalHours
end

local function getWorldAge()
    local gametime = getGameTime()
    local startHour = gametime:getStartTimeOfDay()
    local startDay = gametime:getStartDay()
    local startMonth = gametime:getStartMonth()
    local startYear = gametime:getStartYear()
    local hour = gametime:getHour()
    local day = gametime:getDay()
    local month = gametime:getMonth()
    local year = gametime:getYear()

    local worldAge = calculateHourDifference(startHour, startDay, startMonth, startYear, hour, day, month, year)
    return math.floor(worldAge / 24)
end


local isGhost = function(player)
    local gmd = GetBanditModDataPlayers()
    local id = BanditUtils.GetCharacterID(player)
    if gmd.OnlinePlayers[id] then
        return gmd.OnlinePlayers[id].isGhost
    end
    return false
end

local getPlayers = function()
    local world = getWorld()
    local gamemode = world:getGameMode()

    local playerList = {}
    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
    else
        playerList = IsoPlayer.getPlayers()
    end
    return playerList
end

local function getDensityScore(player, r)
    local score = 0
    local px = player:getX()
    local py = player:getY()

    local zoneScore = {}
    zoneScore.Forest = -3.2
    zoneScore.DeepForest = -4.2
    zoneScore.Nav = 4
    zoneScore.Vegitation = -2.5
    zoneScore.TownZone = 5
    zoneScore.Ranch = 2
    zoneScore.Farm = 2
    zoneScore.TrailerPark = 3
    zoneScore.ZombiesType = 0
    zoneScore.FarmLand = 2
    zoneScore.LootZone = 3
    zoneScore.ZoneStory = 2

    local function isInCircle(x, y, cx, cy, r)
        local d2 = (x - cx) ^ 2 + (y - cy) ^ 2
        return d2 <= r ^ 2
    end

    local function calculateDistance(x1, y1, x2, y2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    end

    -- todo use numBuildings for additional scoring
    -- local numBuildings = BanditUtils.GetNumNearbyBuildings()

    -- about 1250 iterations
    for x=px-r, px+r, 5 do
        for y=py-r, py+r, 5 do
            if isInCircle(x, y, px, py, r) then
                local zone = getWorld():getMetaGrid():getZoneAt(x, y, 0)
                if zone then
                    local zoneType = zone:getType()
                    if zoneScore[zoneType] then
                        score = score + zoneScore[zoneType]
                    end
                end
            end
        end
    end
    return 1 + (score / 10000)
end

local function getGroundType(square)
    local groundType = "generic"
    local objects = square:getObjects()
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        if object then
            local sprite = object:getSprite()
            if sprite then
                local spriteName = sprite:getName()
                if spriteName then
                    if spriteName:embodies("street") then
                        groundType = "street"
                    elseif spriteName:embodies("natural") then
                        groundType = "natural"
                    end
                end
            end
        end
    end
    return groundType
end

local function getZone(square)
    local zone = square:getZone()
    if zone then
        local zoneType = zone:getType()
        return zoneType
    end
end

local function generateSpawnPointHere(player, x, y, z, count)
    local ret = {}
    local cell = player:getCell()
    local square = cell:getGridSquare(x, y, z)

    if square then
        local sp = {}
        sp.x = x
        sp.y = y
        sp.z = z
        sp.groundType = getGroundType(square)
        sp.zone = getZone(square)
        sp.outside = square:isOutside()
        
        for i=1, count do
            table.insert(ret, sp)
        end
    end
    return ret
end

local function generateSpawnPointUniform(player, d, count)
    
     -- Function to check if a point is within a basement region (b41!)
    local function isInBasement(x, y, basement)
        return x >= basement.x and x < basement.x + basement.width and
               y >= basement.y and y < basement.y + basement.height
    end

    local function isTooCloseToPlayer(x, y)
        -- Check if the player is in debug mode or admin mode
        if isDebugEnabled() or isAdmin() then
            return false
        end

        local playerList = getPlayers()
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player and not isGhost(player) then
                local dist = BanditUtils.DistTo(x, y, player:getX(), player:getY())
                if dist < 35 then
                    return true
                end
            end
        end
        return false
    end

    local cell = player:getCell()
    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()

    -- Check if BasementAPI exists before using it
    if BasementAPI then
        -- Get the list of basements
        local basements = BasementAPI.GetBasements()

        -- Check if the player is inside any basement region
        for _, basement in ipairs(basements) do
            if isInBasement(px, py, basement) then
                print("[INFO] Player is inside a basement region. Wave will not be spawned.")
                return
            end
        end
    end

    -- Check if RVInterior exists before using it (b41!)
    if RVInterior then
        if RVInterior.playerInsideInterior(player) then
            print("[INFO] Player is inside an RV interior. Wave will not be spawned.")
            return
        end
    end

    local validSpawnPoints = {}
    for i=1, 16 do
        local theta = ZombRandFloat(0, 2 * math.pi)
        local x = px + (d * math.cos(theta))
        local y = py + (d * math.sin(theta))
        local z = pz

        local square = cell:getGridSquare(x, y, z)
        if square then
            local sp = {
                x = x,
                y = y,
                z = z
            }
            if SafeHouse.isSafeHouse(square, nil, true) then
                print("[INFO] Spawn point is inside a safehouse, skipping.")
            elseif not square:isFree(false) then
                print("[INFO] Square is occupied, skipping.")
            elseif isTooCloseToPlayer(x, y) then
                print("[INFO] Spawn is too close to one of the players, skipping.")
            else
                sp.groundType = getGroundType(square)
                sp.zone = getZone(square)
                sp.outside = square:isOutside()
                table.insert(validSpawnPoints, sp)
            end
        end
    end

    if #validSpawnPoints >= 1 then
        local p = 1 + ZombRand(#validSpawnPoints)
        local spawnPoint = validSpawnPoints[p]
        local ret = {}
        for i=1, count do
            table.insert(ret, spawnPoint)
        end
        return ret
    else
        print ("[ERR] No valid spawn points available. Wave will not be spawned.")
    end

    return {}
end

local function generateSpawnPointBuilding(building, groupSize)

    local function getRoomSize(roomDef)
        local roomSize = (roomDef:getX2() - roomDef:getX()) * (roomDef:getY2() - roomDef:getY())
        return roomSize
    end

    local spawnPoints = {}

    local buildingDef = building:getDef()
    if not buildingDef then return false end

    -- getRooms actually returns roomDefs
    local roomDefList = buildingDef:getRooms()

    for i=0, math.min(roomDefList:size()-1, groupSize) do
        local roomDef = roomDefList:get(i)
        local square = roomDef:getFreeSquare()

        -- double-checking, and roomsize must be big enough  otherwise they spawn in columns of the buildings :)
        if square and square:isFree(false) and getRoomSize(roomDef) >= 4 then
            local sp = {}
            sp.x = square:getX()
            sp.y = square:getY()
            sp.z = square:getZ()
            sp.groundType = getGroundType(square)
            sp.zone = getZone(square)
            sp.outside = square:isOutside()
            table.insert(spawnPoints, sp)
        end
    end
    return spawnPoints
end

-- args: program, permanent, key
local function banditize(zombie, bandit, clan, args)
    local id = zombie:getPersistentOutfitID()
    if LogLevel >= 3 then print ("[BANDITS] banditize started id " .. id) end

    local brain = {}

    -- auto-generated properties 
    brain.id = id
    brain.inVehicle = false
    brain.fullname = BanditNames.GenerateName(bandit.general.female)
    brain.voice = Bandit.PickVoice(zombie)

    brain.born = getGameTime():getWorldAgeHours()
    brain.bornCoords = {}
    brain.bornCoords.x = zombie:getX()
    brain.bornCoords.y = zombie:getY()
    brain.bornCoords.z = zombie:getZ()

    brain.stationary = false
    brain.sleeping = false
    brain.aiming = false
    brain.moving = false
    brain.endurance = 1.00
    brain.speech = 0.00
    brain.sound = 0.00
    brain.infection = 0

    -- properties taken from bandit custom profile
    local general = bandit.general
    brain.clan = general.cid
    brain.cid = general.cid
    brain.bid = general.bid
    brain.female = general.female or false
    brain.skin = general.skin or 1
    brain.hairType = general.hairType or 1
    brain.hairColor = general.hairColor or 1
    brain.beardType = general.beardType or 1
    brain.eatBody = false

    local health = general.health or 5
    brain.health = BanditUtils.Lerp(health, 1, 9, 1, 2.6)

    local accuracyBoost = general.sight or 5
    brain.accuracyBoost = BanditUtils.Lerp(accuracyBoost, 1, 9, -8, 8)

    local enduranceBoost = general.endurance or 5
    brain.enduranceBoost = BanditUtils.Lerp(enduranceBoost, 1, 9, 0.25, 1.75)

    local strengthBoost = general.strength or 5
    brain.strengthBoost = BanditUtils.Lerp(strengthBoost, 1, 9, 0.25, 1.75)

    brain.exp = {0, 0, 0}
    if general.exp1 and general.exp2 and general.exp3 then
        brain.exp = {general.exp1, general.exp2, general.exp3}
    end

    brain.weapons = {}
    brain.weapons.melee = "Base.BareHands"
    brain.weapons.primary = {["bulletsLeft"] = 0, ["magCount"] = 0}
    brain.weapons.secondary = {["bulletsLeft"] = 0, ["magCount"] = 0}

    if bandit.weapons then
        if bandit.weapons.melee then
            brain.weapons.melee = BanditCompatibility.GetLegacyItem(bandit.weapons.melee)
        end
        for _, slot in pairs({"primary", "secondary"}) do
            brain.weapons[slot].bulletsLeft = 0
            brain.weapons[slot].magCount = 0
            if bandit.weapons[slot] and bandit.ammo[slot] then
                brain.weapons[slot] = BanditWeapons.Make(bandit.weapons[slot], bandit.ammo[slot])
            end
        end
    end

    brain.clothing = bandit.clothing or {}
    brain.tint = bandit.tint or {}
    brain.bag = bandit.bag

    brain.loot = {}
    brain.inventory = {}
    brain.tasks = {}

    -- bandit differentiators
    brain.rnd = {ZombRand(2), ZombRand(10), ZombRand(100), ZombRand(1000), ZombRand(10000)}

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
    local spawn = clan.spawn
    brain.hostile = not spawn.friendly -- global hostility
    brain.hostileP = brain.hostile -- hostility against players

    -- properties taken from args, 
    brain.program = {}
    brain.program.name = args.program
    brain.program.stage = "Prepare"
    brain.programFallback = args.program

    -- bwo uses it
    brain.occupation = args.occupation
    brain.loyal = args.loyal or false

    brain.master = args.pid
    brain.permanent = args.permanent and true or false
    brain.key = args.key

    -- enforcing args
    brain.hostile = args.hostile or brain.hostile
    brain.hostileP = args.hostileP or brain.hostileP

    -- ready!
    local gmd = GetBanditModData()
    gmd.Queue[id] = brain

    if LogLevel >= 3 then print ("[BANDITS] banditize finished id " .. id) end

    -- zombie:getModData().IsBandit = true
end

-- args: pid, waveId or cid, 
local function spawnGroup(spawnPoints, args)
    local knockedDown = false
    local crawler = args.crawler and true or false
    local fallOnFront = false
    local fakeDead = false
    local invulnerable = false
    local sitting = false
    local groupSize = #spawnPoints

    local cid = args.cid
    if not cid then return end

    local clan = BanditCustom.ClanGet(cid)
    if not clan then return end

    local banditOptions = BanditCustom.GetFromClan(cid)
    if not banditOptions then return end

    local keys = {}
    for key in pairs(banditOptions) do
        table.insert(keys, key)
    end

    if LogLevel >= 3 then print ("[BANDITS] spawnGroup has bandit options " .. #keys) end

    for i = #keys, 2, -1 do
        local j = ZombRand(i) + 1
        keys[i], keys[j] = keys[j], keys[i]
    end

    local banditSelected = {}
    for i = 1, math.min(groupSize, #keys) do
        local key = keys[i]
        banditSelected[key] = banditOptions[key]
    end

    local i = 1
    for bid, bandit in pairs(banditSelected) do
        bandit.general.bid = bid
        local femaleChance = bandit.general.female and 100 or 0
        local health = 1 -- client needs to update this later

        local sp = spawnPoints[i]

        -- local outfit = BanditUtils.Choice({"Generic01", "Generic02", "Generic03", "Generic04", "Generic05"})
        local outfit = "Naked" .. (1 + ZombRand(101))
        local zombieList = BanditCompatibility.AddZombiesInOutfit(sp.x, sp.y, sp.z, outfit, femaleChance, 
                                                                  crawler, fallOnFront, fakeDead, 
                                                                  knockedDown, invulnerable, sitting,
                                                                  health)

        if zombieList:size() > 0 then
            local zombie = zombieList:get(0)
            banditize(zombie, bandit, clan, args)
            i = i + 1
        end
    end
    return i - 1
end

local function spawnRestore(brain)
    local knockedDown = false
    local crawler = false
    local fallOnFront = false
    local fakeDead = false
    local invulnerable = false
    local sitting = false
    local outfit = "Naked" .. (1 + ZombRand(101))
    local femaleChance = 0
    local health = 1
    local oldId = brain.id
    local gx = brain.bornCoords.x
    local gy = brain.bornCoords.y
    local gz = brain.bornCoords.z

    local bandit = BanditCustom.GetById(brain.bid)
    if not bandit then return end

    bandit.general.bid = brain.bid

    local clan = BanditCustom.ClanGet(brain.cid)
    if not clan then return end

    local args = {}
    args.program = brain.program.name
    args.occupation = brain.occupation
    args.loyal = brain.loyal
    args.master = brain.pid
    args.permanent = brain.permanent
    args.key = brain.key

    if bandit.general.female then
        femaleChance = 100
    end

    local zombieList = BanditCompatibility.AddZombiesInOutfit(gx, gy, gz, outfit, femaleChance, crawler, fallOnFront, fakeDead, knockedDown, invulnerable, sitting, health)

    local zombie = zombieList:get(0)
    banditize(zombie, bandit, clan, args)

    -- remove old one
    local gmd = GetBanditModData()
    gmd.Queue[oldId] = nil

end

local function spawnIndividual(sp, args)
    local knockedDown = false
    local crawler = false
    local fallOnFront = false
    local fakeDead = false
    local invulnerable = false
    local sitting = false
    local outfit = "Naked" .. (1 + ZombRand(101))

    local bid = args.bid
    if not bid then return end

    local bandit = BanditCustom.GetById(bid)
    if bandit then

        local clan = BanditCustom.ClanGet(bandit.cid)
        if not clan then return end

        local femaleChance = bandit.general.female and 100 or 0
        local health = 1 -- client needs to update this later

        local zombieList = BanditCompatibility.AddZombiesInOutfit(sp.x, sp.y, sp.z, outfit, femaleChance, 
                                                                  crawler, fallOnFront, fakeDead, 
                                                                  knockedDown, invulnerable, sitting,
                                                                  health)
        local zombie = zombieList:get(0)
        banditize(zombie, bandit, clan, args)
    end
end

local function spawnVehicle (player, x, y, vtype, args)
    local cell = player:getCell()
    local square = cell:getGridSquare(x, y, 0)
    if not square then return end

    local vehicle = addVehicleDebug(vtype, IsoDirections.S, nil, square)
    if not vehicle then return end

    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then
            container:removeAllItems()
        end
    end
    vehicle:repair()

    if ZombRand(3) == 1 then
        vehicle:setAlarmed(true)
    end

    local cond = (2 + ZombRand(8)) / 10
    vehicle:setGeneralPartCondition(cond, 80)
    if args.engine then
        vehicle:setHotwired(true)
        vehicle:tryStartEngine(true)
        vehicle:engineDoStartingSuccess()
        vehicle:engineDoRunning()
    end

    if args.lights then
        vehicle:setHeadlightsOn(true)
    end

    --[[
    if args.lightbar or args.siren or args.alarm then
        local newargs = {id=vehicle:getId(), lightbar=args.lightbar, siren=args.siren, alarm=args.alarm}
        sendServerCommand('Commands', 'UpdateVehicle', newargs)
    end]]
end

local function checkSpace (player, x, y, w, h)
    local cell = player:getCell()
    for cx=x, x+w do
        for cy=y, y+h do
            local square = cell:getGridSquare(cx, cy, 0)
            if square then
                local player = square:getPlayer()
                if player then 
                    return false
                end

                local objects = square:getObjects()
                local good = false
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    if object then
                        local sprite = object:getSprite()
                        if sprite then 
                            local sn = sprite:getName()
                            local props = sprite:getProperties()
                            if sn ~= "" then
                                local naturefloor = props:Val("natureFloor")
                                local floor = props:Is(IsoFlagType.solidfloor)
                                local canBeRemoved = props:Is(IsoFlagType.canBeRemoved)
                                local vegi = props:Is(IsoFlagType.vegitation)
                                local stone = props:Is("CustomName") and (props:Val("CustomName"):embodies("Stone") or props:Val("CustomName"):embodies("Stump"))
                                local tree = props:Val("tree")
                                if naturefloor or canBeRemoved or vegi or tree or stone then
                                    good = true
                                else
                                    local sn = sprite:getName()
                                    local test = props:Val("CustomName")
                                    -- print ("bad")
                                end
                            end
                        end
                    end
                end
                if not good then return false end
            else
                return false
            end
        end
    end
    return true
end

local function spawnObject (player, sprite, x, y, z)
    local cell = player:getCell()
    local square = cell:getGridSquare(x, y, z)
    if not square then return end
    -- if not square:isFree(false) then return end
    local obj = IsoObject.new(square, sprite, "")
    square:AddSpecialObject(obj)
    obj:transmitCompleteItemToClients()
end

local function spawnRoadblock(player, spawnPoint)
    local cell = player:getCell()
    local vehicleCount = cell:getVehicles():size()
    if spawnPoint.groundType == "street" and vehicleCount < 7 then

        -- check space
        local allfree = true
        for x=spawnPoint.x-4, spawnPoint.x+4 do
            for y=spawnPoint.y-4, spawnPoint.y+4 do
                local testSquare = cell:getGridSquare(x, y, 0)
                if testSquare then
                    if not testSquare:isFree(false) then allfree = false end
                    local testVeh = testSquare:getVehicleContainer()
                    if testVeh then allfree = false end
                else
                    allfree = false
                end
            end
        end

        if allfree then

            local xcnt = 0
            for x=spawnPoint.x-20, spawnPoint.x+20 do
                local square = getCell():getGridSquare(x, spawnPoint.y, 0)
                if square then
                    local gt = getGroundType(square)
                    if gt == "street" then xcnt = xcnt + 1 end
                end
            end

            local ycnt = 0
            for y=spawnPoint.y-20, spawnPoint.y+20 do
                local square = getCell():getGridSquare(spawnPoint.x, y, 0)
                if square then
                    local gt = getGroundType(square)
                    if gt == "street" then ycnt = ycnt + 1 end
                end
            end

            local xm = 0
            local ym = 0
            local sprite
            if xcnt > ycnt then 
                -- ywide
                ym = 1
                sprite = "construction_01_9"
            else
                -- xwide
                xm = 1
                sprite = "construction_01_8"
            end

            local carOpts = {"Base.PickUpTruck", "Base.PickUpVan", "Base.VanSeats"}
            local vx, vy = spawnPoint.x - ym * 3, spawnPoint.y - xm * 3
            local args = {engine=true, lights=true, lightbar=true}
            spawnVehicle(player, vx, vy, BanditUtils.Choice(carOpts), args)

            for b=-4, 4, 2 do
                spawnObject(player, sprite, spawnPoint.x + xm * b, spawnPoint.y + ym * b, 0)
            end
            return true
        end
    end
    return false
end

local function spawnCamp(player, spawnPoint)
    local sx = spawnPoint.x - 4
    local sy = spawnPoint.y - 4
    local sz = spawnPoint.z

    if spawnPoint.groundType ~= "natural" then return end

    if spawnPoint.zone ~= "Forest" and spawnPoint.zone ~= "PRForest" and spawnPoint.zone ~= "PHForest" then return end

    local res = checkSpace(player, sx, sy, 8, 8)
    if not res then return end

    spawnObject(player, "camping_01_2", sx + 0, sy + 3, sz + 0)
    spawnObject(player, "camping_01_3", sx + 1, sy + 3, sz + 0)
    spawnObject(player, "camping_01_1", sx + 3, sy + 0, sz + 0)
    spawnObject(player, "camping_01_0", sx + 3, sy + 1, sz + 0)
    spawnObject(player, "furniture_seating_outdoor_01_23", sx + 3, sy + 4, sz + 0)
    spawnObject(player, "furniture_seating_outdoor_01_22", sx + 3, sy + 5, sz + 0)
    spawnObject(player, "camping_01_1", sx + 5, sy + 0, sz + 0)
    spawnObject(player, "camping_01_0", sx + 5, sy + 1, sz + 0)
    spawnObject(player, "trash_01_11", sx + 6, sy + 6, sz + 0)
    spawnObject(player, "camping_01_28", sx + 6, sy + 8, sz + 0)
    spawnObject(player, "camping_01_29", sx + 7, sy + 8, sz + 0)
    return true
end

local function spawnHouse(player, spawnPoint)
    local cell = player:getCell()
    local square = cell:getGridSquare(spawnPoint.x, spawnPoint.y, spawnPoint.z)
    if not square then return end

    local building = square:getBuilding()
    if not building then return false end

    local buildingDef = building:getDef()
    if not buildingDef then return false end

    -- avoid recently visited buildings
    local bid = BanditUtils.GetBuildingID(buildingDef)
    local gmd = GetBanditModData()
    if gmd.VisitedBuildings and gmd.VisitedBuildings[bid] then
        local now = getGameTime():getWorldAgeHours() --  8
        local lastVisit = gmd.VisitedBuildings[bid] -- 1
        local coolDown = 7 * 24
        if now - coolDown < lastVisit then
            print ("[INFO] Defenders are not allowed to spawn in a building visited by a player in last 7 days.")
            return false
        end
    end

    local x = buildingDef:getX()
    local y = buildingDef:getY()
    local w = buildingDef:getX2() - buildingDef:getX()
    local h = buildingDef:getY2() - buildingDef:getY()

    --[[
    BanditBaseGroupPlacements.Junk(x, y, 0, w, h, 3)
    if ZombRand(5) == 0 then    
        BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.WineOpen"), x, y, 0, w, h, 2)
        BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.BeerCanEmpty"), x, y, 0, w, h, 2)
        BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.ToiletPaper"), x, y, 0, w, h, 1)
        BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.TinCanEmpty"), x, y, 0, w, h, 2)
    end

    local genSquare = cell:getGridSquare(buildingDef:getX()-1, buildingDef:getY()-1, 0)
    if genSquare then
        local generator = genSquare:getGenerator()
        if generator then
            if not generator:isActivated() then
                generator:setCondition(99)
                generator:setFuel(80 + ZombRand(20))
                generator:setActivated(true)
            end
        else
            local genItem = BanditCompatibility.InstanceItem("Base.Generator")
            local obj = IsoGenerator.new(genItem, cell, genSquare)
            obj:setConnected(true)
            obj:setFuel(30 + ZombRand(60))
            obj:setCondition(99)
            obj:setActivated(true)
        end
    end]]

    local maxc = 5
    local c = 0
    for z = 0, 7 do
        for y = buildingDef:getY()-1, buildingDef:getY2()+1 do
            for x = buildingDef:getX()-1, buildingDef:getX2()+1 do
                local square = cell:getGridSquare(x, y, z)
                if square then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if object then
                            if instanceof(object, "IsoLightSwitch") then
                                local lightList = object:getLights()
                                if lightList:size() == 0 then
                                    object:setActive(false)
                                else
                                    object:setBulbItemRaw("Base.LightBulbRed")
                                    object:setPrimaryR(1)
                                    object:setPrimaryG(0)
                                    object:setPrimaryB(0)
                                    object:setActive(true)
                                end
                                object:sendObjectChange('state')
                            end
                            if instanceof(object, "IsoCurtain") then
                                if object:IsOpen() then
                                    object:ToggleDoorSilent()
                                    object:sendObjectChange('state')
                                end
                            end

                            if z == 0 then
                                if instanceof(object, "IsoWindow") then

                                    local barricade = object:getBarricadeOnSameSquare()
                                    if not barricade then
                                        barricade = object:getBarricadeOnOppositeSquare()
                                    end

                                    if not barricade then
                                        local barricade = IsoBarricade.AddBarricadeToObject(object, player)
                                        if barricade then
                                            for i=1, 2 + ZombRand(3) do
                                                local plank = BanditCompatibility.InstanceItem("Base.Plank")
                                                plank:setCondition(200)
                                                barricade:addPlank(nil, plank)
                                            end
                                            barricade:transmitCompleteItemToClients()
                                        end
                                    end
                                end
                            end

                            --[[
                            local lootAmount = SandboxVars.Bandits.General_DefenderLootAmount - 1
                            local roomCnt = building:getRoomsNumber()
                            if lootAmount > 0 and roomCnt > 2 and c < maxc then
                                local fridge = object:getContainerByType("fridge")
                                if fridge then
                                    BanditLoot.FillContainer(fridge, BanditLoot.FreshFoodItems, lootAmount)
                                    c = c + 1
                                end

                                local freezer = object:getContainerByType("freezer")
                                if freezer then
                                    BanditLoot.FillContainer(freezer, BanditLoot.FreshFoodItems, lootAmount)
                                    c = c + 1
                                end

                                if ZombRand(10) == 1 then
                                    local counter = object:getContainerByType("counter")
                                    if counter then
                                        BanditLoot.FillContainer(counter, BanditLoot.CannedFoodItems, lootAmount)
                                        c = c + 1
                                    end

                                    local crate = object:getContainerByType("crate")
                                    if crate then
                                        BanditLoot.FillContainer(crate, BanditLoot.CannedFoodItems, lootAmount)
                                        c = c + 1
                                    end
                                end
                            end
                            ]]
                        end
                    end
                end
            end
        end
    end
    return building
end

local function getIconDataByProgram(program, friendly)

    local icon, color, desc

    if friendly then
        desc = "Friendly"
        color = {r=0.5, g=1, b=0.5} -- green
    else
        desc = "Hostile"
        color = {r=1, g=0.5, b=0.5} -- red
    end

    if program == "Bandit" then 
        icon = "media/ui/raid.png"
        desc = desc .. " " .. "Assault"
    elseif program == "Companion" then
        icon = "media/ui/friend.png"
        desc = desc .. " " .. "Companions"
    elseif program == "Looter" then
        icon = "media/ui/loot.png"
        desc = desc .. " " .. "Wanderers"
    elseif program == "Defend" then
        icon = "media/ui/defend.png"
        desc = desc .. " " .. "Defenders"
    elseif program == "Camper" then
        icon = "media/ui/tent.png"
        desc = desc .. " " .. "Camp"
    elseif program == "Roadblock" then
        icon = "media/ui/roadblock.png"
        desc = desc .. " " .. "Roadblock"
    end
    return icon, color, desc
end

local function spawnType(player, args)

    local pid = BanditUtils.GetCharacterID(player)
    local cid = args.cid
    if not cid then return end

    if LogLevel >= 3 then print ("[BANDITS] spawnType has cid " .. cid) end
    local clan = BanditCustom.ClanGet(cid).spawn
    local groupSize = clan.groupMin + ZombRand(clan.groupMax - clan.groupMin + 1)
    groupSize = math.floor(groupSize * SandboxVars.Bandits.General_SpawnMultiplier + 0.5)
    local spawnPoints = {}

    if LogLevel >= 3 then print ("[BANDITS] groupSize is " .. groupSize) end

    if args.dist then
        spawnPoints = generateSpawnPointUniform(player, args.dist, groupSize)
    elseif args.x and args.y and args.z then
        spawnPoints = generateSpawnPointHere(player, args.x, args.y, args.z, groupSize)
    end

    if #spawnPoints == 0 then return end

    if LogLevel >= 3 then print ("[BANDITS] spawnPoints generated " .. #spawnPoints) end

    local args = {}
    args.pid = pid
    args.cid = cid
    args.permanent = false
    args.program = "Looter"
    -- args.key = false

    if clan.wanderer and clan.assault then
        args.program = BanditUtils.Choice({"Looter", "Bandit"})
    elseif clan.wanderer then
        args.program = "Looter"
    elseif clan.assault then
        args.program = "Bandit"
    elseif clan.companion then
        args.program = "Companion"
    end

    if clan.roadblock then
        local res = spawnRoadblock(player, spawnPoints[1])
        if res then
            args.program = "Roadblock"
        end
    end
    
    if clan.campers then
        local res = spawnCamp(player, spawnPoints[1])
        if res then
            args.program = "Camper"
        end
    end

    if clan.defenders then
        local building = spawnHouse(player, spawnPoints[1])
        if building then
            args.program = "Defend"
            spawnPoints = generateSpawnPointBuilding(building, groupSize)
        end
    end

    if LogLevel >= 3 then print ("[BANDITS] AI program is " .. args.program) end

    if #spawnPoints > 0 then
        local cnt = spawnGroup(spawnPoints, args)
        if SandboxVars.Bandits.General_ArrivalIcon and cnt > 0 then
            local icon, color, desc = getIconDataByProgram(args.program, clan.friendly)
            if icon and color and desc then
                local x, y = spawnPoints[1].x, spawnPoints[1].y
                if isServer() then
                    local args = {icon=icon, time=1800, x=x, y=y, color=color, desc=desc}
                    sendServerCommand('Commands', 'SetMarker', args)
                else
                    BanditEventMarkerHandler.set(getRandomUUID(), icon, 1800, x, y, color, desc)
                end
            end
        end
    end

end

local function checkEvent()
    if isClient() then return end

    local world = getWorld()
    local gamemode = world:getGameMode()
    local player 
    local day

    if gamemode == "Multiplayer" then
        local playerList = getOnlinePlayers()
        local pid = ZombRand(playerList:size())
        player = playerList:get(pid)
        day = player:getHoursSurvived() / 24
    else
        day = getWorldAge()
        player = getSpecificPlayer(0)
    end

    local clanData = BanditCustom.ClanGetAll()
    local densityScore = 1
    if SandboxVars.Bandits.General_DensityScore then
        densityScore = getDensityScore(player, 120)
    end

    for cid, clan in pairs(clanData) do
        local spawnConfig = clan.spawn
        if spawnConfig and spawnConfig.dayStart and spawnConfig.dayEnd and day >= spawnConfig.dayStart and day <= spawnConfig.dayEnd then
            local spawnChance = spawnConfig.spawnChance * SandboxVars.Bandits.General_SpawnMultiplier / 6
            -- boost spawn in non-wilderness area
            -- if spawnConfig.zone and spawnConfig.zone ~= 3 then 
            --    spawnChance = spawnChance * densityScore
            -- end

            local spawnRandom = ZombRandFloat(0, 100)
            -- print (cid .. ": " .. spawnRandom .. " / " .. spawnChance)

            if spawnRandom < spawnChance then
                print ("[BANDITS] Scheduler is spawning bandits now.")
                local args = {}
                args.cid = cid
                args.dist = 55 + ZombRand(10)
                spawnType(player, args)
                TransmitBanditModData()
                print ("[BANDITS] Data transmitted.")
            end
        end
    end
end

local function onClientCommand(module, command, player, args)
    if module == "Spawner" and BanditServer[module] and BanditServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("received " .. module .. "." .. command .. " "  .. argStr)
        BanditServer[module][command](player, args)

        if module == "Spawner" then
            TransmitBanditModData()
        end
    end
end

-- api
BanditServer = BanditServer or {}
BanditServer.Spawner = {}

-- used for dedicated spawning by mods or debug
BanditServer.Spawner.Type = function(player, args)
    if not args.cid then return end
    
    args.pid = BanditUtils.GetCharacterID(player)
    spawnType(player, args)
end

-- used for dedicated spawning by mods or debug
BanditServer.Spawner.Clan = function(player, args)
    if not args.cid then return end
    args.pid = BanditUtils.GetCharacterID(player)

    if not args.size then args.size = 1 end
    if not args.program then args.program = "Bandit" end
    
    local spawnPoints = args.spawnPoints
    if not spawnPoints then
        if not args.x then args.x = player:getX() end
        if not args.y then args.y = player:getY() end
        if not args.z then args.z = player:getZ() end
        spawnPoints = generateSpawnPointHere(player, args.x, args.y, args.z, args.size)
    end

    if #spawnPoints > 0 then
        spawnGroup(spawnPoints, args)
    end
end

-- used for dedicated spawning of an individual by mods
BanditServer.Spawner.Individual = function(player, args)
    if not args.bid then return end
    if not args.x then args.x = player:getX() end
    if not args.y then args.y = player:getY() end
    if not args.z then args.z = player:getZ() end
    if not args.program then args.program = "Bandit" end

    args.pid = BanditUtils.GetCharacterID(player)
    args.size = 1

    local spawnPoint = generateSpawnPointHere(player, args.x, args.y, args.z, args.size)
    if #spawnPoints > 0 then
        spawnIndividual(spawnPoints[1], args)
    end
end

-- used for restoring an individual
BanditServer.Spawner.Restore = function(player, args)
    local brain = args
    spawnRestore(brain)
end

-- used for dedicated spawning by mods
BanditServer.Spawner.Vehicle = function(player, args)
    spawnVehicle (player, args.x, args.y, args.vtype, args)
end

Events.OnClientCommand.Add(onClientCommand)

Events.EveryTenMinutes.Add(checkEvent)
