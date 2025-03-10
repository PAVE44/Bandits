ZombieActions = ZombieActions or {}

ZombieActions.Load = {}
ZombieActions.Load.onStart = function(zombie, task)
    return true
end

ZombieActions.Load.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Load.onComplete = function(zombie, task)

    local brain = BanditBrain.Get(zombie)
    local weapon = brain.weapons[task.slot]

    if weapon.type == "mag" and not weapon.clipIn then
        if weapon.magCount > 0 then
            weapon.bulletsLeft = weapon.magSize
            weapon.magCount = weapon.magCount - 1
            weapon.clipIn = true
            weapon.racked = false
        end
    elseif weapon.type == "nomag" then
        if weapon.bulletsLeft < weapon.ammoSize then
            weapon.bulletsLeft = weapon.bulletsLeft + 1
            weapon.ammoCount = weapon.ammoCount - 1
            weapon.racked = false
        end
    end
    
    Bandit.UpdateItemsToSpawnAtDeath(zombie)

    return true
end