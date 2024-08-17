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

    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)

    local action = ZombRand(10)

    bandit:faceLocation(bandit:getX() - 5 + ZombRand(11), bandit:getY()  -5 + ZombRand(11))

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
        local task = {action="Time", anim="AimRifle", time=200}
        table.insert(tasks, task)
    end

    return {status=true, next="Guard", tasks=tasks}
end



