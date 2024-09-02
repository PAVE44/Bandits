BanditScheduler = BanditScheduler or {}

BanditBaseScenes = BanditBaseScenes or {}
table.insert(BanditBaseScenes, BanditScenes.Hikers)
table.insert(BanditBaseScenes, BanditScenes.MilitaryDeserters)

-- Function to check if a year is a leap year
local function isLeapYear(year)
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        return true
    else
        return false
    end
end

-- Function to get the number of days in a month
local function daysInMonth(year, month)
    local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    if month == 2 and isLeapYear(year) then
        return 29
    else
        return days[month]
    end
end

-- Function to count the number of days from the start of the year to a given date
local function daysFromStartOfYear(year, month, day)
    local days = 0
    for m = 1, month - 1 do
        days = days + daysInMonth(year, m)
    end
    days = days + day
    return days
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
                    end
                end
            end
        end
    end
    return groundType
end

function BanditScheduler.DaysSinceApo()

    local gameTime = getGameTime()
    local year1 = gameTime:getStartYear()
    local month1 = gameTime:getStartMonth() + 1
    local day1 = gameTime:getStartDay() + 1

    local year2 = gameTime:getYear()
    local month2 = gameTime:getMonth() + 1
    local day2 = gameTime:getDay() + 1

    local days = 0

    if year1 == year2 then
        -- If the dates are in the same year, count the days directly
        days = daysFromStartOfYear(year2, month2, day2) - daysFromStartOfYear(year1, month1, day1)
    else
        -- Count the days from the first date to the end of that year
        days = days + (daysInMonth(year1, month1) - day1)
        for m = month1 + 1, 12 do
            days = days + daysInMonth(year1, m)
        end

        -- Add the days for the years between the two dates
        for y = year1 + 1, year2 - 1 do
            if isLeapYear(y) then
                days = days + 366
            else
                days = days + 365
            end
        end

        -- Add the days from the start of the year to the second date
        for m = 1, month2 - 1 do
            days = days + daysInMonth(year2, m)
        end
        days = days + day2
    end

    return days

end

function BanditScheduler.GetWaveDataAll()
    local waveCnt = 16
    local waveData = {}
    for i=1, waveCnt do
        local wave = {}

        wave.enabled = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_WaveEnabled"]
        wave.friendlyChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_FriendlyChance"]
        wave.enemyBehaviour = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_EnemyBehaviour"]
        wave.firstDay = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_FirstDay"]
        wave.lastDay = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_LastDay"]
        wave.spawnDistance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_SpawnDistance"]
        wave.spawnHourlyChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_SpawnHourlyChance"]
        wave.groupSize = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupSize"]
        wave.clanId = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupName"]
        wave.hasPistolChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_HasPistolChance"]
        wave.pistolMagCount = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_PistolMagCount"]
        wave.hasRifleChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_HasRifleChance"]
        wave.rifleMagCount = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RifleMagCount"]

        table.insert(waveData, wave)
    end
    return waveData
end

function BanditScheduler.GetWaveDataForDay(day)
    local waveData = BanditScheduler.GetWaveDataAll()
    local waveDataForDay = {}

    for k, wave in pairs(waveData) do
        if wave.enabled and day >= wave.firstDay and day <= wave.lastDay then
            table.insert(waveDataForDay, wave)
        end
    end
    return waveDataForDay
end

function BanditScheduler.GenerateSpawnPoint(player, d)
    local spawnPoints = {}
    local validSpawnPoints = {}
    local px = player:getX()
    local py = player:getY()
    
     -- Function to check if a point is within a basement region
    local function isInBasement(x, y, basement)
        return x >= basement.x and x < basement.x + basement.width and
               y >= basement.y and y < basement.y + basement.height
    end

    local function isTooCloseToPlayer(x, y)
        -- Check if the player is in debug mode or admin mode
        if isDebugEnabled() or isAdmin() then
            return false
        end
        local gamemode = getWorld():getGameMode()
        local playerList = {}
        if gamemode == "Multiplayer" then
            playerList = getOnlinePlayers()
        else
            playerList = IsoPlayer.getPlayers()
        end

        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player and not BanditPlayer.IsGhost(player) then
                local dist = math.sqrt(math.pow(x - player:getX(), 2) + math.pow(y - player:getY(), 2))
                if dist < 30 then
                    return true
                end
            end
        end
        return false
    end

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

    -- Check if RVInterior exists before using it
    if RVInterior then
        if RVInterior.playerInsideInterior(player) then
            print("[INFO] Player is inside an RV interior. Wave will not be spawned.")
            return
        end
    end

    table.insert(spawnPoints, {x=px+d, y=py+d})
    table.insert(spawnPoints, {x=px+d, y=py-d})
    table.insert(spawnPoints, {x=px-d, y=py+d})
    table.insert(spawnPoints, {x=px-d, y=py-d})
    table.insert(spawnPoints, {x=px+d, y=py})
    table.insert(spawnPoints, {x=px-d, y=py})
    table.insert(spawnPoints, {x=px, y=py+d})
    table.insert(spawnPoints, {x=px, y=py-d})

    local cell = player:getCell()
    for i, sp in pairs(spawnPoints) do
        local square = cell:getGridSquare(sp.x, sp.y, 0)
        if square then
            if SafeHouse.isSafeHouse(square, nil, true) then
                print("[INFO] Spawn point is inside a safehouse, skipping.")
            elseif not square:isFree(false) then
                print("[INFO] Square is occupied, skipping.")
            elseif isTooCloseToPlayer(sp.x, sp.y) then
                print("[INFO] Spawn is too close to one of the players, skipping.")
            else
                sp.groundType = getGroundType(square)
                table.insert(validSpawnPoints, sp)
            end
        end
    end

    if #validSpawnPoints >= 1 then
        local p = 1 + ZombRand(#validSpawnPoints)
        return validSpawnPoints[p]
    else
        print ("[ERR] No valid spawn points available. Wave will not be spawned.")
    end

    return false
end

function BanditScheduler.SpawnWave(player, wave)
    local event = {}
    event.occured = false
    event.program = {}

    event.hostile = true
    if ZombRand(100) < wave.friendlyChance then
        event.hostile = false
        event.program.name = "Companion"
    else
        if wave.enemyBehaviour == 1 then
            event.program.name = BanditUtils.Choice({"Bandit", "Looter"})
        elseif wave.enemyBehaviour == 2 then
            event.program.name = "Bandit"
        elseif wave.enemyBehaviour == 3 then
            event.program.name = "Looter"
        elseif wave.enemyBehaviour == 4 then
            event.program.name = "BaseGuard"
        else
            event.program.name = "Bandit"
        end
    end

    event.program.stage = "Prepare"
    event.bandits = {}
    
    local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, wave.spawnDistance)
    if spawnPoint then

        for i=1, wave.groupSize do
            local bandit = BanditCreator.MakeFromWave(wave)
            table.insert(event.bandits, bandit)
        end
    
        if #event.bandits > 0 then
            print ("[INFO] Spawning a bandit group against player id: " .. BanditUtils.GetCharacterID(player))
            event.x = spawnPoint.x
            event.y = spawnPoint.y

            local arrivalSoundVolume = SandboxVars.Bandits.General_ArrivalSoundLevel or 0.4
            if arrivalSoundVolume > 0 then

                local arrivalSound
                local arrivalSoundX
                local arrivalSoundY

                if wave.groupSize >= 10 then
                    arrivalSound = "ZSAttack_Chopper_1"
                elseif wave.groupSize >= 6 then
                    arrivalSound = "ZSAttack_Big_" .. tostring(1 + ZombRand(2))
                elseif wave.groupSize >= 4 then
                    arrivalSound = "ZSAttack_Medium_" .. tostring(1 + ZombRand(5))
                else
                    arrivalSound = "ZSAttack_Small_" .. tostring(1 + ZombRand(21))
                end
                
                if event.x < getPlayer():getX() then 
                    arrivalSoundX = getPlayer():getX() - 30
                else
                    arrivalSoundX = getPlayer():getX() + 30
                end
            
                if event.y < getPlayer():getY() then 
                    arrivalSoundY = getPlayer():getY() - 30
                else
                    arrivalSoundY = getPlayer():getY() + 30
                end

                local emitter = getWorld():getFreeEmitter(arrivalSoundX, arrivalSoundY, 0)
                
                emitter:setVolumeAll(arrivalSoundVolume)
                emitter:playSound(arrivalSound)
            end

            if SandboxVars.Bandits.General_ArrivalWakeUp and event.hostile and event.program.name == "Bandit" then
                player:forceAwake()
            end
            -- player:Say("Bandits are coming!")

            if SandboxVars.Bandits.General_ArrivaPanic and event.hostile and event.program.name == "Bandit" then
                local stats = player:getStats()
                stats:setPanic(80)
            end

            -- road block spawn
            if event.hostile and spawnPoint.groundType == "street" and ZombRand(4) == 1 then

                -- check space
                local allfree = true
                for x=spawnPoint.x-4, spawnPoint.x+4 do
                    for y=spawnPoint.y-4, spawnPoint.y+4 do
                        local testSquare = getCell():getGridSquare(x, y, 0)
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
                    event.program.name = "BaseGuard"

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
                    local args = {type=BanditUtils.Choice(carOpts), x=spawnPoint.x-ym*3, y=spawnPoint.y-xm*3, engine=true, lights=true, lightbar=true}
                    sendClientCommand(player, 'Commands', 'VehicleSpawn', args)
                    
                    for b=-4, 4, 2 do
                        BanditBasePlacements.IsoObject(sprite, spawnPoint.x + xm * b, spawnPoint.y + ym * b, 0)
                    end
                end
            end

            -- spawn now
            sendClientCommand(player, 'Commands', 'SpawnGroup', event)
            if SandboxVars.Bandits.General_ArrivalIcon then
                local color
                local icon
                if event.hostile then
                    if event.program.name == "Bandit" then
                        icon = "media/ui/raid.png"
                        color = {r=1, g=0.5, b=0.5}
                    else
                        icon = "media/ui/loot.png"
                        color = {r=1, g=1, b=0.5}
                    end
                else
                    icon = "media/ui/friend.png"
                    color = {r=0.5, g=1, b=0.5}
                end

                BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), icon, 10, event.x, event.y, color)
            end
        end
    end  
end

function BanditScheduler.RaiseDefences(x, y)
    local cell = getCell()
    local square = cell:getGridSquare(x, y, 0)
    local building = square:getBuilding()
    if building then
        local buildingDef = building:getDef()
        if buildingDef then
            local x = buildingDef:getX()
            local y = buildingDef:getY()
            local w = buildingDef:getX2() - buildingDef:getX()
            local h = buildingDef:getY2() - buildingDef:getY()
            BanditBaseGroupPlacements.Junk(x, y, 0, w, h, 3)
            BanditBaseGroupPlacements.Item("Base.WineEmpty", x, y, 0, w, h, 2)
            BanditBaseGroupPlacements.Item("Base.BeerCanEmpty", x, y, 0, w, h, 2)
            BanditBaseGroupPlacements.Item("Base.ToiletPaper", x, y, 0, w, h, 1)
            BanditBaseGroupPlacements.Item("Base.TinCanEmpty", x, y, 0, w, h, 2)

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
                    local genItem = InventoryItemFactory.CreateItem("Base.Generator")
                    local obj = IsoGenerator.new(genItem, cell, genSquare)
                    obj:setConnected(true)
                    obj:setFuel(30 + ZombRand(60))
                    obj:setCondition(99)
                    obj:setActivated(true)
                end
            end

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
                                    end
                                    if instanceof(object, "IsoCurtain") then
                                        if object:IsOpen() then
                                            object:ToggleDoorSilent()
                                        end
                                    end

                                    if z == 0 then
                                        if instanceof(object, "IsoWindow") then
                                            local args = {x=x, y=y, z=z, index=object:getObjectIndex(), isMetal=true, condition=5000}
                                            -- tempPlayer:setPerkLevelDebug(Perks.Woodwork, 10)
                                            sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
                                        end
                                    end

                                    local fridge = object:getContainerByType("fridge")
                                    if fridge then
                                        BanditLoot.FillContainer(fridge, BanditLoot.FreshFoodItems, 4)
                                    end

                                    local freezer = object:getContainerByType("freezer")
                                    if freezer then
                                        BanditLoot.FillContainer(freezer, BanditLoot.FreshFoodItems, 4)
                                    end

                                    local counter = object:getContainerByType("counter")
                                    if counter then
                                        BanditLoot.FillContainer(counter, BanditLoot.CannedFoodItems, 7)
                                    end

                                    local crate = object:getContainerByType("crate")
                                    if crate then
                                        BanditLoot.FillContainer(crate, BanditLoot.CannedFoodItems, 7)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function BanditScheduler.GenerateSpawnPointsInRandomBuilding(character, min, max)
    local cell = character:getCell()
    local px = character:getX()
    local py = character:getY()
    local ret = {}

    -- checks if there building is valid for a the spawn
    local function checkBuilding(building)

        -- avoid safehouses
        local buildingDef = building:getDef()
        for x=buildingDef:getX(), buildingDef:getX2() do
            for y=buildingDef:getY(), buildingDef:getY2() do
                local square = cell:getGridSquare(x, y, 0)
                if square and SafeHouse.isSafeHouse(square, nil, true) then
                    print ("[INFO] Defenders are not allowed to spawn in a safehouse.")
                    return false
                end
            end
        end
        
        -- avoid recently visited buildings
        local bid = building:getID()
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

        return true
    end

    -- based on the room types establish general type of the building
    local function getBuildingType(building)
        local btype
        if building:containsRoom("medclinic") or building:containsRoom("medicalstorage") then
            btype = "medical"
        elseif building:containsRoom("policestore") or building:containsRoom("policestorage") or building:containsRoom("cell") then
            btype = "police"
        elseif building:containsRoom("gunstore") then
            btype = "gunstore"
        elseif building:containsRoom("bank") then
            btype = "bank"
        elseif building:containsRoom("warehouse") then
            btype = "warehouse"
        elseif building:containsRoom("grocery") or building:containsRoom("grocerystore") or building:containsRoom("clothingstore") or building:containsRoom("conveniencestore") or building:containsRoom("liquorstore") then
            btype = "store"
        elseif building:containsRoom("motelroom") then
            btype = "motel"
        elseif building:containsRoom("gasstore") then
            btype = "gasstore"
        elseif building:containsRoom("spiffo_dining") then
            btype = "spiffo"
        elseif building:containsRoom("church") then
            btype = "church"
        else
            btype = "unknown"
        end
        return btype
    end

    -- iterates over rooms in a building and finds free squares
    -- that will be available for the spawn
    local function getSpawnPoints(buildingDef)
        local spawnPoints = {}

        -- this actually return roomDefs
        local roomDefList = buildingDef:getRooms()
        for i=0, roomDefList:size()-1 do
            local roomDef = roomDefList:get(i)
            local square = roomDef:getFreeSquare()

            -- double-checking
            if square and square:isFree(false) then
                table.insert(spawnPoints, {x=square:getX(), y=square:getY(), z=square:getZ()})
            end
        end
        return spawnPoints
    end

    -- get center x, y of a building
    local function getCenterCoords(buildingDef)
        local coords = {}
        local x = math.floor((buildingDef:getX() + buildingDef:getX2()) / 2)
        local y = math.floor((buildingDef:getY() + buildingDef:getY2()) / 2)
        coords = {x=x, y=y}
        return coords
    end

    local function getNearbyBuildings(character, min, max)
        -- Get the character's current cell
        local cell = character:getCell()  

        -- Get the character's current position
        local chrX = character:getX()
        local chrY = character:getY()
        
        -- Get the list of all rooms in the character's current cell
        local rooms = cell:getRoomList()
        local buildings = {}

        -- Iterate through the rooms and construct our own list of buildings
        for i = 0, rooms:size() - 1 do
            local room = rooms:get(i)  -- Get the room at the current index
            local building = room:getBuilding()
            if building then
                local buildingDef = building:getDef()
                local buildingKey = buildingDef:getKeyId()
                
                -- Calculate the distance between the character and the building
                local coords = getCenterCoords(buildingDef)
                local distance = math.sqrt((coords.x - chrX)^2 + (coords.y - chrY)^2)

                -- Buildings stay in memory even after exiting the cell, so we need to check if the building is within a set distance
                if distance >= min and distance <= max then
                    if not buildings[buildingKey] then
                        buildings[buildingKey] = building
                    end
                end
            end
        end

        return buildings
    end

    -- get building candidates for the spawn
    local buildings = getNearbyBuildings(character, min, max)

    -- shuffle (Fisher-Yates)
    for i = #buildings, 2, -1 do
        local j = ZombRand(i) + 1
        buildings[i], buildings[j] = buildings[j], buildings[i]
    end

    -- choose first good building
    for _, building in pairs(buildings) do
        local valid = checkBuilding(building)
        if valid then
            local buildingDef = building:getDef()
            ret.buildingCoords = {x = buildingDef:getX(), y = buildingDef:getY()}
            ret.buildingCenterCoords = getCenterCoords(buildingDef)
            ret.spawnPoints = getSpawnPoints(buildingDef)
            ret.buildingType = getBuildingType(building)
            break
        end
    end

    return ret
end

function BanditScheduler.GetDensityScore(player, r)
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
                    else
                        print ("[WARNING] Unknown zone type " .. zoneType .. ".")
                    end
                end
            end
        end
    end
    return 1 + (score / 10000)
end

function BanditScheduler.GetSpawnZoneBoost(player, clanId)
    local zoneBoost = 1
    local clan = BanditCreator.GroupMap[clanId]
    local zone = getWorld():getMetaGrid():getZoneAt(player:getX(), player:getY(), 0)

    if zone and clan then
        local zoneType = zone:getType()
        if clan.favoriteZones then
            for _, zt in pairs(clan.favoriteZones) do
                if zt == zoneType then
                    zoneBoost = 1.4
                    break
                end
            end
        end
        if clan.avoidZones then
            for _, zt in pairs(clan.avoidZones) do
                if zt == zoneType then
                    zoneBoost = 0.6
                    break
                end
            end
        end
    end
    return zoneBoost
end
-------------------------------------------------------------------------------
-- Spawning function
-------------------------------------------------------------------------------
function BanditScheduler.SpawnDefenders(player, min, max)
    local event = {}
    event.hostile = true
    event.occured = false
    event.program = {}
    event.program.name = "Defend"
    event.program.stage = "Prepare"

    -- get spawn locations per room and shuffle with Fisher-Yates
    local spawnData = BanditScheduler.GenerateSpawnPointsInRandomBuilding(player, min, max)
    
    -- no buildings available
    if not spawnData.spawnPoints or #spawnData.spawnPoints == 0 then return end

    for i = #spawnData.spawnPoints, 2, -1 do
        local j = ZombRand(i) + 1
        spawnData.spawnPoints[i], spawnData.spawnPoints[j] = spawnData.spawnPoints[j], spawnData.spawnPoints[i]
    end

    -- prepare the building
    BanditScheduler.RaiseDefences(spawnData.buildingCoords.x, spawnData.buildingCoords.y)

    -- each defender is spawned separately, because we need to spawn it exactly on
    -- the free square in different rooms, not in one group 
    local cnt = 0
    for _, spawnPoint in pairs(spawnData.spawnPoints) do
        event.x = spawnPoint.x
        event.y = spawnPoint.y
        event.z = spawnPoint.z
        event.bandits = {}
        
        local bandit = BanditCreator.MakeFromSpawnType(spawnData)
        if bandit then
            print ("[INFO] Spawning defenders at X:" .. event.x .. " Y:" .. event.y .. " Z: " .. event.z .. " Type:" .. spawnData.buildingType .. ".")
            table.insert(event.bandits, bandit)
            sendClientCommand(player, 'Commands', 'SpawnGroup', event)
        end

        -- building probably too big, breaking
        cnt = cnt + 1
        if cnt > 24 then break end
    end

    if SandboxVars.Bandits.General_ArrivalIcon then
        local color = {r=0.5, g=0.5, b=1}
        local icon = "media/ui/defend.png"
        BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), icon, 10, spawnData.buildingCenterCoords.x, spawnData.buildingCenterCoords.y, color)
    end
end

function BanditScheduler.SpawnBase(player, sceneNo)
    local cell = getCell()
    local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, ZombRand(40,70))
    if spawnPoint then
        local canPlace = BanditBaseGroupPlacements.CheckSpace(spawnPoint.x-10, spawnPoint.y-10, 40, 40)
        if canPlace then
            print ("[INFO] Spawning a camp site " .. tostring(sceneNo) .. " for player id: " .. BanditUtils.GetCharacterID(player) .. ".")
            local square = cell:getGridSquare(spawnPoint.x, spawnPoint.y, 0)
            BanditBaseScenes[sceneNo](player, square)

            if SandboxVars.Bandits.General_ArrivalIcon then
                color = {r=1, g=0, b=1}
                BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), "media/ui/tent.png", 10, spawnPoint.x, spawnPoint.y, color)
            end
        else
            print ("[INFO] Camp site has no space to spawn.")
        end
    else
        print ("[INFO] Campt site has no free point to spawn.")
    end
end

function BanditScheduler.BaseballMatch(player)
    local event = {}
    event.name = 1
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "Bandit"
    event.program.stage = "Prepare"
    
    config = {}
    config.hasRifleChance = 0
    config.hasPistolChance = 0
    config.rifleMagCount = 0
    config.pistolMagCount = 0

    -- FIRST TEAM
    event.bandits = {}
    event.x = player:getX()
    event.y = player:getY() - 14
    
    local bandit = BanditCreator.MakeBaseballKY(config)
    for i=1, 10 do
        table.insert(event.bandits, bandit)
    end
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    -- FIRST TEAM
    event.bandits = {}
    event.x = player:getX() 
    event.y = player:getY() + 14
    
    local bandit = BanditCreator.MakeBaseballZ(config)
    for i=1, 10 do
        table.insert(event.bandits, bandit)
    end
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
end

function BanditScheduler.BroadcastTV(cx, cy)
    local cell = getCell()

    local tvs = {}
    for z = 0, 7 do
        for y = cy-20, cy+20 do
            for x = cx-20, cx+20 do
                local square = cell:getGridSquare(x, y, z)
                if square then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if object then
                            if instanceof(object, "IsoTelevision") then
                                print ("FOUND TV")
                                table.insert(tvs, object)
                                -- tv:clearTvScreenSprites()
                            end
                        end
                    end
                end
            end
        end
    end

    if #tvs then
        local lines = {}
        table.insert(lines, {text="This is an automated emergency broadcast system. "})
        table.insert(lines, {text="Authorities have identified a group..."})
        table.insert(lines, {text="...of armed bandits operating within the region..."})
        table.insert(lines, {text="...engaging in theft and violent activities."})
        table.insert(lines, {text="Remain indoors and secure all entry points."})
        table.insert(lines, {text="Do not travel alone or engage with suspicious individuals."})
        table.insert(lines, {text="This message will repeat. "})
        table.insert(lines, {text="END"})

        for _, line in pairs(lines) do
            local message = {tvs=tvs, text=line.text, sound=line.sound}
            BanditBroadcaster.AddBroadcast(message)
        end
    end
end

-------------------------------------------------------------------------------
-- Main function
-------------------------------------------------------------------------------

function BanditScheduler.CheckEvent()
    
    local world = getWorld()
    local gamemode = world:getGameMode()
    local playerList = {}
    local currentPlayer = getPlayer()
    local onlinePlayer 

    -- if true then return end 

    local pid
    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
        pid = ZombRand(playerList:size())

        onlinePlayer = playerList:get(pid)
    else
        onlinePlayer = getPlayer()
    end
    

    if BanditUtils.GetCharacterID(currentPlayer) == BanditUtils.GetCharacterID(onlinePlayer) then

        -- SPAWN ATTACKING FORCE
        local daysPassed = currentPlayer:getHoursSurvived() / 24
        local waveData = BanditScheduler.GetWaveDataForDay(daysPassed)

        local densityScore = 1
        if SandboxVars.Bandits.General_DensityScore then
           densityScore = BanditScheduler.GetDensityScore(currentPlayer, 120)
        end

        for _, wave in pairs(waveData) do
            local spawnZoneBoost = BanditScheduler.GetSpawnZoneBoost(currentPlayer, wave.clanId)
            local spawnChance = wave.spawnHourlyChance * spawnZoneBoost * densityScore / 6
            local spawnRandom = ZombRandFloat(0, 101)
            if spawnRandom < spawnChance then
                BanditScheduler.SpawnWave(currentPlayer, wave)
            end
        end

        -- SPAWN DEFENDERS
        local spawnRandom = ZombRandFloat(0, 101)
        local spawnChance = SandboxVars.Bandits.General_DefenderSpawnHourlyChanced or 8
        if spawnRandom < spawnChance / 6 then
            BanditScheduler.SpawnDefenders(currentPlayer, 55, 100)
        end

        -- SPAWN BASES
        local spawnRandom = ZombRandFloat(0, 101)
        local spawnChance = SandboxVars.Bandits.General_BaseSpawnHourlyChance or 0.3
        if spawnRandom < spawnChance / 6 then
            local sceneNo = 1 + ZombRand(#BanditBaseScenes)
            BanditScheduler.SpawnBase(currentPlayer, sceneNo)
        end
    end
end

Events.EveryTenMinutes.Add(BanditScheduler.CheckEvent)
