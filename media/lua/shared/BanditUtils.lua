BanditUtils = BanditUtils or {}

function BanditUtils.GetCharacterID (character)
    if instanceof(character, "IsoZombie") then
        return character:getPersistentOutfitID()
    end
    
    if instanceof(character, "IsoPlayer") then
        local world = getWorld()
        local gamemode = world:getGameMode()
        local id = false
        if gamemode == "Multiplayer" then
            id = character:getOnlineID()
        else
            id = character:getID()
        end
        return id
    end
end

function BanditUtils.IsInAngle(observer, targetX, targetY)
    
    local omega = observer:getDirectionAngle()
    local targer_delta_x = targetX - observer:getX()
    local targer_delta_y = targetY - observer:getY()
    local theta = 57.295779513 * math.atan(targer_delta_y / targer_delta_x)

    -- print ("omega:" .. omega)
    -- print ("theta:" .. theta)

    if math.abs(theta - omega) < 45 then 
        return true
    else
        return false
    end
end

function BanditUtils.GetClosestPlayerLocation(bandit, mustSee)
    local world = getWorld()
    local gamemode = world:getGameMode()
    local playerList = {}
    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
    else
        playerList = IsoPlayer.getPlayers()
    end

    local bestDist = 10000
    local bestX = false
    local bestY = false
    local bestZ = false
    local bestPlayerId = false

    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player and not BanditPlayer.IsGhost(player) then
            local dist = math.sqrt(math.pow(bandit:getX() - player:getX(), 2) + math.pow(bandit:getY() - player:getY(), 2))
            if dist < bestDist and (not mustSee or (bandit:CanSee(player) and dist < SandboxVars.Bandits.General_RifleRange)) then
                bestDist = dist
                bestX = player:getX()
                bestY = player:getY()
                bestZ = player:getZ()
                bestPlayerId = player:getOnlineID()
            end
        end
    end
    return bestX, bestY, bestZ, bestDist, bestPlayerId
end

function BanditUtils.GetClosestZombieLocation(bandit)
    local bestDist = 10000
    local bestX = false
    local bestY = false
    local bestZ = false
    local bestZombieId = false

    for i, coords in pairs(BanditMap.ZMap) do
        local dist = math.sqrt(math.pow(bandit:getX() - coords.x, 2) + math.pow(bandit:getY() - coords.y, 2))
        if dist < bestDist then
            bestDist = dist
            bestX = coords.x
            bestY = coords.y
            bestZ = coords.z
            bestZombieId = 0
        end
    end

    return bestX, bestY, bestZ, bestDist, bestZombieId
end

function BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local bestDist = 10000
    local bestX = false
    local bestY = false
    local bestZ = false
    local bestZombieId = false
    local brain = BanditBrain.Get(bandit)

    for i, coords in pairs(BanditMap.BMap) do
        if brain.clan ~= coords.clan and (brain.hostile or coords.hostile) then
            local dist = math.sqrt(math.pow(bandit:getX() - coords.x, 2) + math.pow(bandit:getY() - coords.y, 2))
            if dist < bestDist then
                bestDist = dist
                bestX = coords.x
                bestY = coords.y
                bestZ = coords.z
                bestZombieId = 0
            end
        end
    end

    return bestX, bestY, bestZ, bestDist, bestZombieId
end

function BanditUtils.CloneIsoPlayer(originalCharacter)
    -- Create a new temporary IsoPlayer at the same position as the original player
    local tempPlayer = IsoPlayer.new(nil, nil, originalCharacter:getX(), originalCharacter:getY(), originalCharacter:getZ())

    -- Copy relevant properties from the original player to the temporary player
    -- tempPlayer:setForname(originalCharacter:getForname())
    -- tempPlayer:setSurname(originalCharacter:getSurname())
    tempPlayer:setGhostMode(true) -- Ensure the temp player is not interactable
    tempPlayer:setGodMod(true)    -- Ensure the temp player cannot die
    tempPlayer:setPrimaryHandItem(originalCharacter:getPrimaryHandItem())
    tempPlayer:setSecondaryHandItem(originalCharacter:getSecondaryHandItem())

    -- You can copy more properties as needed, depending on what you need for the Hit function

    return tempPlayer
end

--[[
local x1 = player:getX()
local y1 = player:getY()
local theta = bandit:getDirectionAngle() * math.pi / 180
local r = 5
local x2 = x1 + math.floor(r * math.cos(theta) + 0.5)
local y2 = y1 + math.floor(r * math.sin(theta) + 0.5)
local soundSquare = cell:getGridSquare(x2, y2, 0)
]]

function BanditUtils.findPoint(Ax, Ay, Bx, By, X)
    -- Calculate the direction vector from A to B
    local directionX = Bx - Ax
    local directionY = By - Ay
    
    -- Calculate the length of the direction vector
    local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
    
    -- Normalize the direction vector
    local unitX = directionX / length
    local unitY = directionY / length
    
    -- Scale the unit vector by X units
    local scaledX = unitX * X
    local scaledY = unitY * X
    
    -- Calculate the coordinates of point P
    local Px = Ax + scaledX
    local Py = Ay + scaledY
    
    return Px, Py
end


function BanditUtils.Choice(arr)
    local r = 1 + ZombRand(#arr)
    return arr[r]
end