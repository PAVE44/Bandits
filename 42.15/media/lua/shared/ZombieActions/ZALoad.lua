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
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)

    if weapon.type == "mag" and not weapon.clipIn then
        if weapon.magCount > 0 then
            weapon.bulletsLeft = weapon.magSize
            weapon.magCount = weapon.magCount - 1
            weapon.clipIn = true
            weapon.racked = false
        end
    elseif weapon.type == "nomag" then
        if weapon.bulletsLeft < weapon.ammoSize then
            local b = 1
            if weaponItem:isInsertAllBulletsReload() then
                b = weapon.ammoSize
            end
            weapon.bulletsLeft = weapon.bulletsLeft + b
            weapon.ammoCount = weapon.ammoCount - b
            weapon.racked = false
        end
    end

    return true
end