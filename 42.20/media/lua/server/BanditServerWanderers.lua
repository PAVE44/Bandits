BanditServer = BanditServer or {}
BanditServer.Wanderers = {}

BanditServer.Wanderers.destinations = {
    {
        name = "March Ridge Center",
        x = 10100,
        y = 12658,
        z = 0
    },
    {
        name = "March Ridge Bunker",
        x = 9923, 
        y = 12624,
        z = 0
    },
    {
        name = "March Ridge Center Gas Station",
        x = 10144,
        y = 12802,
        z = 0
    },
    {
        name = "Muldraugh Crossroads",
        x = 10572,
        y = 11221,
        z = 0
    },
    {
        name = "Muldraugh Gas 2 Go",
        x = 10643,
        y = 10629,
        z = 0
    },
    {
        name = "Muldraugh Bar",
        x = 10762,
        y = 10564,
        z = 0
    },
    {
        name = "Muldraugh Hit Vids",
        x = 10614,
        y = 10459,
        z = 0
    },
    {
        name = "Muldraugh Police Station",
        x = 10637,
        y = 10422,
        z = 0
    },
    {
        name = "Muldraugh Cortman",
        x = 10879,
        y = 10034,
        z = 0
    },
    {
        name = "Muldraugh Fossoil",
        x = 10608,
        y = 9748,
        z = 0
    },
    {
        name = "Muldraugh Mass-Genfac Co.",
        x = 10632,
        y = 9314,
        z = 0
    },
    {
        name = "Muldraugh Lakehouse.",
        x = 10100,
        y = 8247,
        z = 0
    },
    {
        name = "Dixie.",
        x = 11475,
        y = 8778,
        z = 0
    },
    {
        name = "Dixie Crossroads",
        x = 11619,
        y = 8309,
        z = 0
    },
    {
        name = "Westpoint Fossoil",
        x = 12083,
        y = 7146,
        z = 0
    },
    {
        name = "Westpoint Gigamart",
        x = 12020,
        y = 6863,
        z = 0
    },
    {
        name = "Westpoint Stendo",
        x = 12096,
        y = 6794,
        z = 0
    },
    {
        name = "Westpoint Townhall",
        x = 11950,
        y = 6892,
        z = 0
    },
    {
        name = "Westpoint Thundergas",
        x = 11826,
        y = 6875,
        z = 0
    },
    {
        name = "Westpoint Police",
        x = 11819,
        y = 6617,
        z = 0
    },
    {
        name = "Westpoint Hitvids",
        x = 11673,
        y = 7113,
        z = 0
    },
    {
        name = "Westpoint School",
        x = 11344,
        y = 6790,
        z = 0
    },
    {
        name = "Westpoint Villas",
        x = 10112,
        y = 6656,
        z = 0
    },
    {
        name = "Fallas Farming",
        x = 7261,
        y = 8332,
        z = 0
    },
    {
        name = "Fallas EP Tools",
        x = 7270,
        y = 8242,
        z = 0
    },
    {
        name = "Fallas Church",
        x = 7220, 
        y = 8536,
        z = 0
    },
    {
        name = "Rosewood Police",
        x = 8071,
        y = 11727,
        z = 0
    },
    {
        name = "Rosewood Firestation",
        x = 8146,
        y = 11738,
        z = 0
    },
    {
        name = "Rosewood Mainstreet",
        x = 8105,
        y = 11574,
        z = 0
    },
    {
        name = "Rosewood Gigamart",
        x = 8021,
        y = 11260,
        z = 0
    },
    {
        name = "Rosewood School",
        x = 8346,
        y = 11624,
        z = 0
    },
    {
        name = "Rosewood Prison",
        x = 7666, 
        y = 11793,
        z = 0
    },
    {
        name = "Echo Creek Center",
        x = 3579,
        y = 10913,
        z = 0
    },
    {
        name = "Echo Creek Guns Unlimited",
        x = 2623,
        y = 10922,
        z = 0
    },
    {
        name = "Ekron Industrial Area",
        x = 1917,
        y = 10773,
        z = 0
    },
    {
        name = "Ekron Community College",
        x = 790,  
        y = 9835,
        z = 0
    },
    {
        name = "Sanatorium",
        x = 4065, 
        y = 6522,
        z = 0
    },
    {
        name = "Coalfield",
        x = 3455,
        y = 8194,
        z = 0
    },
    {
        name = "Louisville Border Camp",
        x = 12512, 
        y = 4267,
        z = 0
    },
    {
        name = "Crossroads Mall",
        x = 13943, 
        y = 5830,
        z = 0
    },
    {
        name = "Irvington Speedway",
        x = 911, 
        y = 13043,
        z = 0
    },
    {
        name = "Irvington Town Hall",
        x = 2457, 
        y = 14078,
        z = 0
    },
    {
        name = "Irvington Gun Club",
        x = 1856, 
        y = 14164,
        z = 0
    },
    {
        name = "Brandenburg Mansion",
        x = 1264, 
        y = 7381,
        z = 0
    },
    {
        name = "Brandenburg P.S. Delilah",
        x = 2046, 
        y = 5688,
        z = 0
    },
    {
        name = "Brandenburg Community Center",
        x = 1848, 
        y = 5943,
        z = 0
    },
    {
        name = "Brandenburg Airfield",
        x = 941,
        y = 6115,
        z = 0
    },
    {
        name = "Military Research Facility",
        x = 5558,  
        y = 12480,
        z = 0
    }
}

BanditServer.Wanderers.speed = 4
BanditServer.Wanderers.contactRange = 70

BanditServer.Wanderers.AddGroup = function(group)
    local gmd = GetBanditModData()

    if not group.x then return false end
    if not group.y then return false end
    if not group.z then return false end
    if not group.cid then return false end

    if not group.alive then group.alive = true end
    if not group.size then group.size = 1 end

    if not group.destination then group.destination = BanditUtils.Choice(BanditServer.Wanderers.destinations) end

    if #gmd.Wanderers >= 100 then
        print ("[WANDERERS] Maximum number of wanderer groups reached. Cannot add more.")
        return false
    end
    table.insert(gmd.Wanderers, group)
    return true
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

local function isInCircle(x, y, cx, cy, r)
    local d2 = (x - cx) ^ 2 + (y - cy) ^ 2
    return d2 <= r ^ 2
end

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

local getRandomDestination = function()
    local playerList = getPlayers()
    local destinations = BanditServer.Wanderers.destinations

    for i = #destinations, 2, -1 do
        local j = ZombRand(i) + 1
        destinations[i], destinations[j] = destinations[j], destinations[i]
    end

    local choices = {}
    for i, destination in ipairs(destinations) do
        local allFar = true
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player and not isGhost(player) then
                local dist = BanditUtils.DistTo(destination.x, destination.y, player:getX(), player:getY())
                if dist < 150 then
                    allFar = false
                    break
                end
            end
        end
        if allFar then
            table.insert(choices, i)
        end
    end

    return BanditUtils.Choice(choices)
end

local updateGroups = function()
    if isClient() then return end

    local function updateCombatGroups(winner, loser)
        -- winner group gets casualties
        local worldAge = getWorldAge()
        local casualties = math.floor(math.floor(winner.size * 0.25))
        winner.size = math.max(1, winner.size - casualties)

        -- calualities group is separated from winners and added as dead group
        if casualties > 0 then
            local gmd = GetBanditModData()
            local casualtiesGroup = {
                cid = winner.cid,
                size = casualties,
                x = loser.x,
                y = loser.y,
                z = loser.z,
                destination = winner.destination,
                alive = false,
                deadDay = worldAge
            }
            table.insert(gmd.Wanderers, casualtiesGroup)
        end

        -- loser group is marked as dead
        loser.alive = false
        loser.deadDay = worldAge
    end

    local cell = getCell()
    local gmd = GetBanditModData()
    local toRemove = {}
    local wanderers = gmd.Wanderers
    local destinations = BanditServer.Wanderers.destinations
    local speed = BanditServer.Wanderers.speed
    local contactRange2 = BanditServer.Wanderers.contactRange * BanditServer.Wanderers.contactRange
    local playerList = getPlayers()
    local worldAge = getWorldAge()

    local first = true
    for i, group in ipairs(wanderers) do
        
        if group.alive then

            -- manage combat between group 
            for _, otherGroup in ipairs(wanderers) do
                if otherGroup ~= group and otherGroup.alive then
                    local dist2 = ((otherGroup.x - group.x) * (otherGroup.x - group.x)) + ((otherGroup.y - group.y) * (otherGroup.y - group.y))
                    if dist2 <= contactRange2 then
                        if group.cid ~= otherGroup.cid then
                            print ("[WANDERERS] Group " .. group.cid .. " is in contact with group " .. otherGroup.cid)
                            local groupSize = group.size
                            local otherGroupSize = otherGroup.size

                            local chance

                            if groupSize > otherGroupSize then
                                chance = 0.5 + ((groupSize - otherGroupSize) / (groupSize + otherGroupSize)) * 0.4
                            else
                                chance = 0.5 - ((otherGroupSize - groupSize) / (groupSize + otherGroupSize)) * 0.4
                            end

                            if ZombRand(100) < chance * 100 then
                                local winner = group
                                local loser = otherGroup
                                updateCombatGroups(winner, loser)
                            else
                                local winner = otherGroup
                                local loser = group
                                updateCombatGroups(winner, loser)
                            end
                        end
                    end
                end
            end
        end

        -- manage movement
        if group.destination and group.alive then
            
            local dx = group.destination.x - group.x
            local dy = group.destination.y - group.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance > 0 then
                -- Don't overshoot the destination
                local movement = math.min(speed, distance)

                group.x = group.x + (dx / distance) * movement
                group.y = group.y + (dy / distance) * movement

                -- print ("[WANDERERS] Group " .. group.cid .. " moved to (" .. group.x .. ", " .. group.y .. ") towards " .. group.destination.name .. " distance: " .. distance)

                --[[
                if false and first then
                    local player = getPlayer()
                    player:setX(group.x)
                    player:setY(group.y)
                    player:setZ(group.z)
                    first = false
                end
                ]]
            else
                -- Reached destination, choose a new one
                group.destination = BanditUtils.Choice(destinations)
                print ("[WANDERERS] Group " .. group.cid .. " reached destination and is now heading to " .. group.destination.name)
            end
        end

        -- manage devirtualization
        local square = cell:getGridSquare(group.x, group.y, group.z)
        if square and not square:isWaterSquare() then

            local playerSelected
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player and not isGhost(player) then
                    local dist = BanditUtils.DistTo(group.x, group.y, player:getX(), player:getY())
                    if dist < 70 then
                        playerSelected = player
                    end
                end
            end

            if playerSelected then
                print ("[WANDERERS] Group " .. group.cid .. " is being devirtualized at (" .. group.x .. ", " .. group.y .. ")")
                local args = {
                    cid = group.cid,
                    size = 1,
                    z = group.z,
                }

                if group.alive then
                    args.program = "Bandit"
                else
                    args.program = "Dead"
                end

                local zombieList = cell:getZombieList()
                for j = zombieList:size() -1, 0, -1 do
                    local zombie = zombieList:get(j)
                    if zombie and isInCircle(zombie:getX(), zombie:getY(), group.x, group.y, 30) then
                        zombie:setHealth(0)
                        zombie:clearAttachedItems()
                        zombie:changeState(ZombieOnGroundState.instance())
                        zombie:setAttackedBy(cell:getFakeZombieForHit())
                        zombie:die()
                        -- print ("[WANDERERS] Removed zombie at (" .. zombie:getX() .. ", " .. zombie:getY() .. ")")
                    end
                end

                for i = 1, group.size do
                    args.x = group.x - 5 + ZombRand(10)
                    args.y = group.y - 5 + ZombRand(10)
                    BanditServer.Spawner.Clan(playerSelected, args)
                end

                local zone = square:getZone()
                local multiplier = 0
                if zone then
                    local zoneType = zone:getType()
                    if zoneType then
                        if zoneType == "DeepForest" then
                            local x1 = group.x - 7
                            local y1 = group.y - 7
                            BanditBaseGroupPlacements.ClearSpace (x1, y1, 0, 14, 14)

                            BanditBasePlacements.Tent(x1 + 1, y1 + 1, 0)
                            BanditBasePlacements.Tent(x1 + 4, y1 + 1, 0)
                            BanditBasePlacements.Tent(x1 + 8, y1 + 2, 0)
                            BanditBasePlacements.Tent(x1 + 11, y1 + 2, 0)
                        end
                    end
                end

                local clan = BanditCustom.ClanGet(group.cid)
                if SandboxVars.Bandits.General_ArrivalIcon  then
                    local icon, color, desc = getIconDataByProgram("Looter", clan.spawn.friendly)
                    if icon and color and desc then
                        if isServer() then
                            local args = {icon=icon, time=1800, x=group.x, y=group.y, color=color, desc=desc}
                            sendServerCommand('Commands', 'SetMarker', args)
                        else
                            BanditEventMarkerHandler.set(getRandomUUID(), icon, 1800, group.x, group.y, color, desc)
                        end
                    end
                end
                
                table.insert(toRemove, i)
            end
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(wanderers, toRemove[i])
    end

    -- time purge of dead groups
    for i = #wanderers, 1, -1 do
        local g = wanderers[i]
        if not g.alive then
            if not g.deadDay then
                g.deadDay = worldAge
            elseif worldAge - g.deadDay >= 14 then
                table.remove(wanderers, i)
            end
        end
    end

    TransmitBanditModData()
end

local orchestrator = function()
    if isClient() then return end

    local world = getWorld()
    local gamemode = world:getGameMode()
    local player 
    local day

    if gamemode == "Multiplayer" then
        local playerList = getOnlinePlayers()
        if playerList:size() > 0 then
            local pid = ZombRand(playerList:size())
            player = playerList:get(pid)
            day = player:getHoursSurvived() / 24
        end
    else
        day = getWorldAge()
        player = getSpecificPlayer(0)
    end

    local clanData = BanditCustom.ClanGetAll()

    for cid, clan in pairs(clanData) do
        local spawnConfig = clan.spawn

        if spawnConfig then
            spawnConfig.dayStart = tonumber(spawnConfig.dayStart)
            spawnConfig.dayEnd = tonumber(spawnConfig.dayEnd)
            spawnConfig.groupMin = tonumber(spawnConfig.groupMin)
            spawnConfig.groupMax = tonumber(spawnConfig.groupMax)

            -- print ("[BANDITS] Orchestrator checking clan " .. cid .. " for spawn. Day: " .. day)

            if spawnConfig.wanderer and spawnConfig.dayStart and spawnConfig.dayEnd then
                if day and day >= spawnConfig.dayStart and day <= spawnConfig.dayEnd then
                    local spawnChance = spawnConfig.spawnChance * SandboxVars.Bandits.General_SpawnMultiplier / 6

                    local spawnRandom = ZombRandFloat(0, 100)
                    -- print (cid .. ": " .. spawnRandom .. " / " .. spawnChance)

                    if spawnRandom < spawnChance then
                        print ("[BANDITS] Wanderer scheduler is adding bandits now." .. " day=" .. day .. " chance=" .. spawnChance .. " random=" .. spawnRandom)

                        local did = getRandomDestination()

                        if did then

                            local destination = BanditServer.Wanderers.destinations[did]
                        
                            local group = {
                                cid = cid,
                                z = 0,
                                size = spawnConfig.groupMin + ZombRand(spawnConfig.groupMax - spawnConfig.groupMin + 1),
                                alive = true,
                                x = destination.x,
                                y = destination.y,
                            }
                            BanditServer.Wanderers.AddGroup(group)
                            TransmitBanditModData()
                        end
                    end
                end
            end
        else
            print ("[BANDITS] No wanderer spawn configuration for clan " .. cid .. ". Check your clan configuration!")
        end
    end
end

Events.EveryOneMinute.Add(updateGroups)
Events.EveryTenMinutes.Add(orchestrator)
