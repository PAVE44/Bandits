ZombieActions = ZombieActions or {}

ZombieActions.Reload = {}
ZombieActions.Reload.onStart = function(zombie, task)
    return true
end

ZombieActions.Reload.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Reload.onComplete = function(zombie, task)

    local brain = BanditBrain.Get(zombie)
    local weapon = brain.weapons[task.slot]

    weapon.bulletsLeft = weapon.magSize
    weapon.magCount = weapon.magCount - 1
    Bandit.UpdateItemsToSpawnAtDeath(zombie)

    return true
end