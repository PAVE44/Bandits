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
        wave.groupName = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupName"]
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

function BanditScheduler.GetGroundType(square)
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
                sp.groundType = BanditScheduler.GetGroundType(square)
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

        -- print ("SPAWN ATTEMPT" .. daysPassed)
        for _, wave in pairs(waveData) do

            local spawnRandom = ZombRandFloat(0, 101)
            -- print ("spawnRandom" .. spawnRandom)
            -- print ("spawnHourlyChance" .. wave.spawnHourlyChance / 6)
            if spawnRandom < wave.spawnHourlyChance / 6 then
                BanditScheduler.SpawnWave(currentPlayer, wave)
            end
        end

        -- SPAWN DEFENDERS
        local spawnRandom = ZombRandFloat(0, 101)
        -- print ("DEFEND CHANCE:" ..spawnRandom)
        local spawnChance = SandboxVars.Bandits.General_DefenderSpawnHourlyChanced or 8
        if spawnRandom < spawnChance / 6 then
            print ("SPAWNING DEFENDERS")
            BanditScheduler.SpawnDefenders(currentPlayer, 45, 100)
        end

        -- SPAWN BASES
        local spawnRandom = ZombRandFloat(0, 101)
        -- print ("DEFEND CHANCE:" ..spawnRandom)
        local spawnChance = SandboxVars.Bandits.General_BaseSpawnHourlyChance or 0.3
        if spawnRandom < spawnChance / 6 then
            print ("SPAWNING BASE")
            local sceneNo = 1 + ZombRand(#BanditBaseScenes)
            BanditScheduler.SpawnBase(currentPlayer, sceneNo)
        end
    end
end

function BanditScheduler.SpawnWave(player, wave)
    local event = {}
    event.name = wave.groupName
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
    
    for i=1, wave.groupSize do
        local groupName = wave.groupName
        local bandit = BanditCreator.GroupMap[groupName](wave)
        table.insert(event.bandits, bandit)
    end

    if #event.bandits > 0 then
        local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, wave.spawnDistance)
        if spawnPoint then
            print ("SPAWNING ATTACK GROUP " .. event.name .. " FOR PLAYER: " .. BanditUtils.GetCharacterID(player))
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

            if SandboxVars.Bandits.General_ArrivalWakeUp and event.hostile then
                player:forceAwake()
            end
            -- player:Say("Bandits are coming!")

            if SandboxVars.Bandits.General_ArrivaPanic and event.hostile then
                local stats = player:getStats()
                stats:setPanic(80)
            end

            sendClientCommand(player, 'Commands', 'SpawnGroup', event)
            if SandboxVars.Bandits.General_ArrivalIcon then
                if event.hostile then
                    if event.program.name == "Bandit" then
                        color = {r=1, g=0.5, b=0.5}
                    else
                        color = {r=1, g=1, b=0.5}
                    end
                else
                    color = {r=0.5, g=1, b=0.5}
                end

                BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), "media/ui/crew.png", 10, event.x, event.y, color)
            end

            if event.hostile and spawnPoint.groundType == "street" then

                local xcnt = 0
                for x=spawnPoint.x-20, spawnPoint.x+20 do
                    local square = getCell():getGridSquare(x, spawnPoint.y, 0)
                    if square then
                        local gt = BanditScheduler.GetGroundType(square)
                        if gt == "street" then xcnt = xcnt + 1 end
                    end
                end

                local ycnt = 0
                for y=spawnPoint.y-20, spawnPoint.y+20 do
                    local square = getCell():getGridSquare(spawnPoint.x, y, 0)
                    if square then
                        local gt = BanditScheduler.GetGroundType(square)
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

                local args = {type="Base.PickUpTruckLightsFire", x=spawnPoint.x-ym*3, y=spawnPoint.y-xm*3}

                sendClientCommand(player, 'Commands', 'VehicleSpawn', args)
                for b=-4, 4, 2 do
                    BanditBasePlacements.IsoObject(sprite, spawnPoint.x + xm * b, spawnPoint.y + ym * b, 0)
                end
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
            BanditBaseGroupPlacements.Junk(buildingDef:getX(), buildingDef:getY(), 0, buildingDef:getX2() - buildingDef:getX(), buildingDef:getY2() - buildingDef:getY(), 3)

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
                for y = buildingDef:getY(), buildingDef:getY2() do
                    for x = buildingDef:getX(), buildingDef:getX2() do
                        local square = cell:getGridSquare(x, y, z)
                        if square then
                            local objects = square:getObjects()
                            for i=0, objects:size()-1 do
                                local object = objects:get(i)
                                if object then
                                    if instanceof(object, "IsoLightSwitch") then
                                        if not object:isActivated() then
                                            object:setActive(true)  
                                        end
                                    end
                                    if instanceof(object, "IsoCurtain") then
                                        if object:IsOpen() then
                                            object:ToggleDoorSilent()
                                        end
                                    end

                                    --[[
                                    if instanceof(object, "IsoWindow") then
                                        local args = {x=x, y=y, z=z, index=object:getObjectIndex()}
                                        sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
                                    end
                                    ]]

                                    local fridge = object:getContainerByType("fridge")
                                    if fridge then
                                        BanditLoot.FillContainer(fridge, BanditLoot.FridgeItems, 6)
                                    end

                                    local freezer = object:getContainerByType("freezer")
                                    if freezer then
                                        BanditLoot.FillContainer(freezer, BanditLoot.FridgeItems, 5)
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

function BanditScheduler.FindBuilding(character, min, max)
    local px = character:getX()
    local py = character:getY()
    local cell = character:getCell()
    local ret = {}
    ret.random = {}
    ret.bed = {}
    --for y=-100, 100, 5 do
    --    for x=-100, 100, 5 do
        for i=0, 5000 do
            local offsetX = ZombRand(min, max)
            local offsetY = ZombRand(min, max)
            if ZombRand(2) == 1 then offsetX = -offsetX end
            if ZombRand(2) == 1 then offsetY = -offsetY end 

            local testSquare = cell:getGridSquare(px + offsetX, py + offsetY, 0)
            if testSquare then
                local building = testSquare:getBuilding()
                if building then

                    -- AVOID PLAYER OCCUPIED BUILDINGS
                    local occupied = false
                    local gamemode = getWorld():getGameMode()
                    if gamemode == "Multiplayer" then
                        playerList = getOnlinePlayers()
                    else
                        playerList = IsoPlayer.getPlayers()
                    end
                    for i=0, playerList:size()-1 do
                        local player = playerList:get(i)
                        if player then
                            local playerSquare = player:getSquare()
                            if playerSquare then
                                playerBuilding = playerSquare:getBuilding()
                                if playerBuilding then
                                    if playerBuilding:getID() == building:getID() then
                                        print ("THIS IS OCCUPIED")
                                        occupied = true
                                    end
                                end
                            end
                        end
                    end

                    if SafeHouse.isSafeHouse(testSquare, nil, true) then
                        occupied = true
                    end

                    if not occupied then
                        if building:containsRoom("medclinic") or building:containsRoom("medicalstorage") then
                            ret.type = "medical"
                        elseif building:containsRoom("policestore") or building:containsRoom("policestorage") or building:containsRoom("cell") then
                            ret.type = "police"
                        elseif building:containsRoom("gunstore") then
                            ret.type = "gunstore"
                        elseif building:containsRoom("bank") then
                            ret.type = "bank"
                        elseif building:containsRoom("warehouse") then
                            ret.type = "warehouse"
                        elseif building:containsRoom("grocery") or building:containsRoom("grocerystore") or building:containsRoom("clothingstore") or building:containsRoom("conveniencestore") or building:containsRoom("liquorstore") then
                            ret.type = "store"
                        elseif building:containsRoom("motelroom") then
                            ret.type = "motel"
                        elseif building:containsRoom("gasstore") then
                            ret.type = "gasstore"
                        elseif building:containsRoom("spiffo_dining") then
                            ret.type = "spiffo"
                        elseif building:containsRoom("church") then
                            ret.type = "church"
                        else
                            ret.type = "unknown"
                        end
                        local room = building:getRandomRoom()
                        if room then
                            local roomDef = room:getRoomDef()
                            if roomDef then
                                local name = roomDef:getName()
                                local bed
                                for x=roomDef:getX(), roomDef:getX2() do
                                    for y=roomDef:getY(), roomDef:getY2() do
                                        local testSquare = cell:getGridSquare(x, y, roomDef:getZ())
                                        if testSquare then
                                            local objects = testSquare:getObjects()
                                            for i=0, objects:size()-1 do
                                                local object = objects:get(i)
                                                if object then
                                                    local sprite = object:getSprite()
                                                    if sprite then
                                                        local spriteName = sprite:getName()
                                                        if spriteName then 
                                                            local isBed = sprite:getProperties():Is(IsoFlagType.bed)
                                                            if isBed then
                                                                ret.bed.x = x
                                                                ret.bed.y = y-1
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                                local newSquare = roomDef:getFreeSquare()
                                if newSquare then
                                    ret.random.x = newSquare:getX()
                                    ret.random.y = newSquare:getY()
                                    return ret
                                end

                            end
                        end
                    end
                end
            end
        end
        --end
    --end
    print ("NO BUILDING FOUND")
    return false
end

function BanditScheduler.SpawnDefenders(player, min, max)
    local event = {}
    event.name = 1
    event.hostile = true
    event.occured = false
    event.program = {}
    event.program.name = "Defend"

    local gameTime = getGameTime()
    local hour = gameTime:getHour() 
    if gameTime:getHour() >= 0 and gameTime:getHour() < 6 then
        event.program.stage = "Sleep"
    else
        event.program.stage = "Prepare"
    end

    event.bandits = {}

    local spawn = BanditScheduler.FindBuilding(player, min, max)
    
    if spawn then
        BanditScheduler.RaiseDefences(spawn.random.x, spawn.random.y)

        event.x = spawn.random.x
        event.y = spawn.random.y
        
        print ("SPAWNING DEFENDER X:" .. event.x .. " Y:" .. event.y .. " TYPE:" .. spawn.type)

        local config = {}
        local cnt = 2
        local bandit
        if spawn.type == "medical" then
            
            config.hasRifleChance = 0
            config.hasPistolChance = 100
            config.rifleMagCount = 0
            config.pistolMagCount = 3

            bandit = BanditCreator.MakeMadDoctor(config)

        elseif spawn.type == "police" then

            config.hasRifleChance = 40
            config.hasPistolChance = 100
            config.rifleMagCount = 3
            config.pistolMagCount = 5

            bandit = BanditCreator.MakePolice(config)
            cnt = 5

        elseif spawn.type == "gunstore" then

            config.hasRifleChance = 100
            config.hasPistolChance = 100
            config.rifleMagCount = 16
            config.pistolMagCount = 12

            bandit = BanditCreator.MakeVeteran(config)
            cnt = 5

        elseif spawn.type == "bank" then

            config.hasRifleChance = 0
            config.hasPistolChance = 100
            config.rifleMagCount = 0
            config.pistolMagCount = 4

            bandit = BanditCreator.MakeSecurityGuard(config)
            cnt = 6

        elseif spawn.type == "store" then

            config.hasRifleChance = 0
            config.hasPistolChance = 40
            config.rifleMagCount = 0
            config.pistolMagCount = 3

            bandit = BanditCreator.MakeSecurityGuard(config)
            cnt = 3

        elseif spawn.type == "warehouse" then

            config.hasRifleChance = 50
            config.hasPistolChance = 80
            config.rifleMagCount = 3
            config.pistolMagCount = 4

            bandit = BanditCreator.MakeForeman(config)
            cnt = 4

        elseif spawn.type == "spiffo" then

            config.hasRifleChance = 100
            config.hasPistolChance = 100
            config.rifleMagCount = 5
            config.pistolMagCount = 5

            bandit = BanditCreator.MakeSpiffo(config)
            cnt = 1

        elseif spawn.type == "church" then

            config.hasRifleChance = 100
            config.hasPistolChance = 0
            config.rifleMagCount = 5
            config.pistolMagCount = 0

            bandit = BanditCreator.MakePriest(config)
            cnt = 1

        else
            config.hasRifleChance = 0
            config.hasPistolChance = 50
            config.rifleMagCount = 0
            config.pistolMagCount = 3

            bandit = BanditCreator.MakeDesperateCitizen(config)
            cnt = 1 + ZombRand(3)
        end
        
        for i = 1, cnt do
            table.insert(event.bandits, bandit)
        end

        sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    end

end

function BanditScheduler.SpawnBase(player, sceneNo)
    local cell = getCell()
    local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, ZombRand(30,60))
    if spawnPoint then
        local canPlace = BanditBaseGroupPlacements.CheckSpace (spawnPoint.x-2, spawnPoint.y-2, 32, 32)
        if canPlace then
            print ("SPAWNING BASE " .. tostring(sceneNo) .. " FOR PLAYER: " .. BanditUtils.GetCharacterID(player))
            local square = cell:getGridSquare(spawnPoint.x, spawnPoint.y, 0)
            BanditBaseScenes[sceneNo](player, square)

            if SandboxVars.Bandits.General_ArrivalIcon then
                color = {r=1, g=0, b=1}
                BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), "media/ui/crew.png", 10, spawnPoint.x, spawnPoint.y, color)
            end
        else
            print ("BASE HAS NO FREE SPACE")
        end
    else
        print ("BASE HAS NO FREE POINT")
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

function BanditScheduler.SpawnCivilian(player)
    local event = {}
    event.name = 1
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "Civilian"
    event.program.stage = "Prepare"

    event.bandits = {}

    event.x = player:getX() + 1
    event.y = player:getY() + 1

    config = {}
    config.hasRifleChance = 5
    config.hasPistolChance = 15
    config.rifleMagCount = 2
    config.pistolMagCount = 4

    local bandit = BanditCreator.GroupMap[1](config)
    table.insert(event.bandits, bandit)

    print ("SPAWNING CIVILIAN X:" .. event.x .. " Y:" .. event.y .. " TYPE:" )
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

Events.EveryTenMinutes.Add(BanditScheduler.CheckEvent)
