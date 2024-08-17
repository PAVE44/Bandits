ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.CompanionGuard = {}
ZombiePrograms.CompanionGuard.Stages = {}

ZombiePrograms.CompanionGuard.Init = function(bandit)
end

ZombiePrograms.Companion.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.CompanionGuard.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, true)

    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    local task = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task)

    return {status=true, next="Guard", tasks=tasks}
end

ZombiePrograms.CompanionGuard.Guard = function(bandit)
    local tasks = {}

    -- GUARD POST MUST BE PRESENT OTHERWISE SWITH PROGRAM
    local guardpost = false
    local objects = bandit:getSquare():getObjects()
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        local sprite = object:getSprite()
        if sprite then
            local spriteName = sprite:getName()
            if spriteName == "location_community_cemetary_01_31" then
                guardpost = true
                
            end
        end
    end

    if not guardpost then
        Bandit.SetProgram(bandit, "Companion", {})
        return {status=true, next="Prepare", tasks=tasks}
    end
    
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)

    local action = ZombRand(50)

    local gameTime = getGameTime()
    local alfa = gameTime:getMinutes() * 4
    local theta = alfa * math.pi / 180
    local x1 = bandit:getX() + 3 * math.cos(theta)
    local y1 = bandit:getY() + 3 * math.sin(theta)

    -- bandit:faceLocation(x1, y1)

    if action == 0 then
        local task = {action="Time", anim="ShiftWeight", time=200}
        table.insert(tasks, task)
    elseif action == 1 then
        local task = {action="Time", anim="Cough", time=200}
        table.insert(tasks, task)
    elseif action == 2 then
        local task = {action="Time", anim="ChewNails", time=200}
        table.insert(tasks, task)
    elseif action == 3 then
        local task = {action="Time", anim="Smoke", time=200}
        table.insert(tasks, task)
        table.insert(tasks, task)
        table.insert(tasks, task)
    elseif not outOfAmmo then

        local task = {action="FaceLocation", anim="AimRifle", x=x1, y=y1, time=100}
        table.insert(tasks, task)
    end

    return {status=true, next="Guard", tasks=tasks}
end



