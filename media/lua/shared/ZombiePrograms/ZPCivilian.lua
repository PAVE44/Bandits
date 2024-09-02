ZombiePrograms = ZombiePrograms or {}

local function GetMoveTask(endurance, x, y, z, walkType, dist)
    local gamemode = getWorld():getGameMode()
    local task
    if gamemode == "Multiplayer" then
        if dist > 30 then
            task = {action="Move", time=25, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
        else
            task = {action="GoTo", time=50, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
        end
    else
        task = {action="Move", time=25, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
    end
    return task
end

ZombiePrograms.Civilian = {}
ZombiePrograms.Civilian.Stages = {}

ZombiePrograms.Civilian.Init = function(bandit)
end

ZombiePrograms.Civilian.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = false
    capabilities.breakObjects = false
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Civilian.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local task = {action="Equip", itemPrimary=primary, itemSecondary=nil}
    table.insert(tasks, task)

    return {status=true, next="Operate", tasks={}}
end

ZombiePrograms.Civilian.Operate = function(bandit)

    local tasks = {}

    
    -- determine
    -- seek shelter in the nearest building
    

   

    return {status=true, next="Operate", tasks=tasks}
end

