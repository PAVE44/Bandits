BanditPlayer = BanditPlayer or {}

-- This function is neccessary to synchronize the ghost state of players in multiplayer game 
-- Game anti-cheat system does not allow other clients or the server to check the status of ghost mode of other players
-- so each client has to report individually their status to the server
--
-- each client needs status of all players so that the bandits will not attack any of the ghosted players

BanditPlayer.IsGhost = function(player)
    local gmd = GetBanditModDataPlayers()
    local id = BanditUtils.GetCharacterID(player)
    if gmd.OnlinePlayers[id] then
        return gmd.OnlinePlayers[id].isGhost
    end
    return false
end

BanditPlayer.GetPlayers = function()
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

BanditPlayer.GetPlayerById = function(id)
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player then
            local pid = BanditUtils.GetCharacterID(player)
            if pid == id then
                return player
            end
        end
    end
end

BanditPlayer.GetMasterPlayer = function(bandit)
    local gamemode = getWorld():getGameMode()
    local master
    if gamemode == "Multiplayer" then
        master = getPlayerByOnlineID(Bandit.GetMaster(bandit))
    else
        master = getPlayer()
    end
    return master
end

-- A function to wake up all players on the server.
-- We always need to wake up all players to avoid time pardoxes
BanditPlayer.WakeEveryone = function()
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player then
            player:forceAwake()
        end
    end
end

local UpdatePlayersOnline = function ()
    if isServer() then return end

    local player = getPlayer()
    if player then
        local playerData = {}
        playerData.id = BanditUtils.GetCharacterID(player)
        playerData.name = player:getDisplayName()
        playerData.isGhost = player:isGhostMode()
        sendClientCommand(player, 'Players', 'PlayerUpdate', playerData)
    end
end

-- Global variable to store the original PanicIncreaseValue
local originalPanicIncreaseValue = nil

-- Function to check nearby entities and set panic increase value
local PanicHandler = function(player)
    if isServer() then return end

    -- Step 1: Store the original PanicIncreaseValue if it's the first time modifying it
    local bodyDamage = player:getBodyDamage()
    if originalPanicIncreaseValue == nil then
        originalPanicIncreaseValue = bodyDamage:getPanicIncreaseValue()
    end

    if player:getStats():getPanic() < 3 then 
        bodyDamage:setPanicIncreaseValue(originalPanicIncreaseValue)
        return 
    end

    local px, py = player:getX(), player:getY()
    local panicRadius = player:getSeeNearbyCharacterDistance() + 2.0

    -- Step 2: Proceed with checking all zombies within the panicRadius
    local onlyFriendlies = false  -- Default to false, assume hostiles are present
    local zombieList = BanditZombie.GetAll()
    for id, zombie in pairs(zombieList) do
        local dist = BanditUtils.DistToManhattan(zombie.x, zombie.y, px, py)
        if dist <= panicRadius then
            if zombie.brain and not zombie.brain.hostile then
                -- Found a friendly Bandit, mark as potentially only friendlies
                onlyFriendlies = true
            else
                -- Found a hostile entity (zombie or hostile Bandit), override any friendly findings
                onlyFriendlies = false
                break
            end
        end
    end

    -- Step 3: Adjust or restore panic increase value based on the proximity check
    if onlyFriendlies then
        bodyDamage:setPanicIncreaseValue(0.0)  -- Prevent panic increase
        player:getStats():setPanic(0)  -- Set current panic level to 0
    else
        bodyDamage:setPanicIncreaseValue(originalPanicIncreaseValue)  -- Restore the original panic increase
        originalPanicIncreaseValue = nil  -- Reset the stored value since we're done
    end
end

local BanditPlayer.ResetBanditKills = function(player)
    if isServer() then return end
    local args = {}
    args.id = 0
	sendClientCommand(player, 'Commands', 'ResetBanditKills', args)
end

local BanditPlayer.UpdateVisitedBuildings = function()
    if isServer() then return end
    local player = getPlayer()
    local building = player:getBuilding()
    if building then
        local buildingDef = building:getDef()
        local bid = BanditUtils.GetBuildingID(buildingDef)
        local wah = getGameTime():getWorldAgeHours()
        local args = {bid=bid, wah=wah}
        sendClientCommand(player, 'Commands', 'UpdateVisitedBuilding', args)
    end
end

Events.EveryOneMinute.Add(UpdatePlayersOnline)
Events.OnPlayerUpdate.Add(PanicHandler)
Events.OnPlayerDeath.Add(ResetBanditKills)
Events.EveryTenMinutes.Add(UpdateVisitedBuildings)