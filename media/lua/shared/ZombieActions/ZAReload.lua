ZombieActions = ZombieActions or {}

ZombieActions.Reload = {}
ZombieActions.Reload.onStart = function(zombie, task)
    return true
end

ZombieActions.Reload.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Reload.onComplete = function(zombie, task)

    local brain = BanditBrain.Get(zombie)
    local weapon = brain.weapons[task.slot]

    weapon.bulletsLeft = weapon.magSize
    weapon.magCount = weapon.magCount - 1

    return true
end