ZombieActions = ZombieActions or {}

ZombieActions.Equip = {}
ZombieActions.Equip.onStart = function(zombie, task)

    if task.itemPrimary then
        local primaryItem = InventoryItemFactory.CreateItem(task.itemPrimary)
        local primaryItemType = WeaponType.getWeaponType(primaryItem)

        local oldItemPrimary = zombie:getVariableString("BanditPrimary")
        if oldItemPrimary ~= task.itemPrimary then
            zombie:setPrimaryHandItem(primaryItem)
            zombie:setVariable("BanditHasPrimary", true)
            zombie:setVariable("BanditPrimary", task.itemPrimary)
        end

        local hands
        if primaryItemType == WeaponType.barehand then
            hands = "barehand"
        elseif primaryItemType == WeaponType.firearm then
            hands = "rifle"
        elseif primaryItemType == WeaponType.handgun then
            hands = "handgun"
        elseif primaryItemType == WeaponType.heavy then
            hands = "twohanded"
        elseif primaryItemType == WeaponType.onehanded then
            hands = "onehanded"
        elseif primaryItemType == WeaponType.spear then
            hands = "spear"
        elseif primaryItemType == WeaponType.twohanded then
            hands = "twohanded"
        elseif primaryItemType == WeaponType.throwing then
            hands = "throwing"
        elseif primaryItemType == WeaponType.chainsaw then
            hands = "chainsaw"
        else
            hands = "onehanded"
        end

        zombie:setVariable("BanditPrimaryType", hands)

        if task.itemSecondary then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" or hands == "throwing" then
                local oldSecondaryPrimary = zombie:getVariableString("BanditSecondary")
                if oldSecondaryPrimary ~= task.itemSecondary then
                    local secondaryItem = InventoryItemFactory.CreateItem(task.itemSecondary)
                    zombie:setSecondaryHandItem(secondaryItem)
                    zombie:setVariable("BanditHasSecondary", true)
                    zombie:setVariable("BanditSecondary", task.itemSecondary)

                    local ls = secondaryItem:getLightStrength()
                    if ls > 0 then
                        secondaryItem:setActivated(true)
                        zombie:setVariable("BanditTorch", true)
                    else
                        zombie:setVariable("BanditTorch", false)
                    end
                end
            else
                print ("ERROR: Cannot equip secondary item because primary item occupies both hands")
            end
        end

        local anim
        if primaryItemType == WeaponType.firearm or primaryItemType == WeaponType.spear or primaryItemType == WeaponType.heavy or primaryItemType == WeaponType.twohanded then
            anim = "AttachBackOut"
        elseif primaryItemType == WeaponType.handgun then
            anim = "AttachHolsterRightOut"
        else
            anim = "AttachHolsterLeftOut"
        end
        zombie:setBumpType(anim)
    end
    return true
end

ZombieActions.Equip.onWorking = function(zombie, task)
    local asn = zombie:getActionStateName()
    if asn == "bumped" then
        return false
    else
        return true
    end
end

ZombieActions.Equip.onComplete = function(zombie, task)
    return true
end

