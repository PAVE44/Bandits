ZombieActions = ZombieActions or {}

ZombieActions.Unequip = {}
ZombieActions.Unequip.onStart = function(zombie, task)

    if task.itemPrimary then
        local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)

        if primaryItem:IsWeapon() then
            local primaryItemType = WeaponType.getWeaponType(primaryItem)

            local anim
            if primaryItemType == WeaponType.firearm or primaryItemType == WeaponType.spear or primaryItemType == WeaponType.heavy or primaryItemType == WeaponType.twohanded then
                anim = "AttachBack"
            elseif primaryItemType == WeaponType.handgun then
                anim = "AttachHolsterRight"
            else
                anim = "AttachHolsterLeft"
            end
            zombie:setBumpType(anim)
        end
    end
    
    return true
end

ZombieActions.Unequip.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Unequip.onComplete = function(zombie, task)
    if task.itemPrimary then
        local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
        if primaryItem:IsWeapon() then
            local primaryItemType = WeaponType.getWeaponType(primaryItem)

            local anim
            if primaryItemType == WeaponType.firearm or primaryItemType == WeaponType.spear or primaryItemType == WeaponType.heavy or primaryItemType == WeaponType.twohanded then
                zombie:setAttachedItem("Rifle On Back", primaryItem)
            elseif primaryItemType == WeaponType.handgun then
                zombie:setAttachedItem("Holster Right", primaryItem)
            else
                zombie:setAttachedItem("Belt Left", primaryItem)
            end
        end
    end
    return true
end

