ZombieActions = ZombieActions or {}

ZombieActions.Unequip = {}
ZombieActions.Unequip.onStart = function(zombie, task)

    if task.itemPrimary then
        local primaryItem = InventoryItemFactory.CreateItem(task.itemPrimary)
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
    
    return true
end

ZombieActions.Unequip.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Unequip.onComplete = function(zombie, task)
    if task.itemPrimary then
        local primaryItem = InventoryItemFactory.CreateItem(task.itemPrimary)
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
    return true
end

