ZombieActions = ZombieActions or {}

ZombieActions.Equip = {}
ZombieActions.Equip.onStart = function(zombie, task)
    local oldItemPrimary = zombie:getVariableString("BanditPrimary")
    if task.itemPrimary and oldItemPrimary ~= task.itemPrimary then
        local primaryItem = InventoryItemFactory.CreateItem(task.itemPrimary)

        zombie:setPrimaryHandItem(primaryItem)
        zombie:setVariable("BanditPrimary", task.itemPrimary)

        local hands
        if primaryItem:IsWeapon() then
            local primaryItemType = WeaponType.getWeaponType(primaryItem)
            
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
        else
            hands = "item"
        end

        zombie:setVariable("BanditPrimaryType", hands)

        if task.itemSecondary then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" or hands == "throwing" then
                local oldSecondaryPrimary = zombie:getVariableString("BanditSecondary")
                if oldSecondaryPrimary ~= task.itemSecondary then
                    local secondaryItem = InventoryItemFactory.CreateItem(task.itemSecondary)
                    zombie:setSecondaryHandItem(secondaryItem)
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
        task.anim = anim
        Bandit.UpdateTask(zombie, task)

        zombie:setBumpType(anim)
    end
    return true
end

ZombieActions.Equip.onWorking = function(zombie, task)
    local bumpType = zombie:getBumpType()
    if bumpType ~= task.anim then return true end

    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Equip.onComplete = function(zombie, task)
    return true
end

