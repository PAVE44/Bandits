ZombieActions = ZombieActions or {}

ZombieActions.Equip = {}
ZombieActions.Equip.onStart = function(zombie, task)
    task.tick = 1
    local oldItemPrimary = zombie:getVariableString("BanditPrimary")
    if task.itemPrimary and oldItemPrimary ~= task.itemPrimary then

        --[[
        if task.itemSecondary then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" or hands == "throwing" then
                local oldSecondaryPrimary = zombie:getVariableString("BanditSecondary")
                if oldSecondaryPrimary ~= task.itemSecondary then
                    local secondaryItem = BanditCompatibility.InstanceItem(task.itemSecondary)
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
        end]]

        local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
        local attachmentType = primaryItem:getAttachmentType()
        for _, def in pairs(ISHotbarAttachDefinition) do
            if def.attachments then
                for k, v in pairs(def.attachments) do
                    if k == attachmentType then
                        if def.type == "HolsterRight" then 
                            task.anim1 = "AttachHolsterRight"
                            task.anim2 = "AttachHolsterRightOut"
                            task.slot = v
                            return true
                        elseif def.type == "Back" then
                            task.anim1 = "AttachBack"
                            task.anim2 = "AttachBackOut"
                            task.slot = v
                            return true
                        elseif def.type == "SmallBeltLeft" then
                            task.anim1 = "AttachHolsterLeft"
                            task.anim2 = "AttachHolsterLeftOut"
                            task.slot = v
                            return true
                        end
                    end
                end
            end
        end
    end
    task.anim1 = "AttachHolsterLeft"
    task.anim2 = "AttachHolsterLeftOut"
    return true
end

ZombieActions.Equip.onWorking = function(zombie, task)
    if task.tick == 1 then
        zombie:setBumpType(task.anim1)
    end

    if task.tick == 15 then
        local brain = BanditBrain.Get(zombie)
        if task.slot then
            zombie:setAttachedItem(task.slot, nil)
        end

        zombie:setBumpType(task.anim2)

        if task.itemPrimary then
            local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
            primaryItem = BanditWeapons.Modify(primaryItem, brain)
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
        end
    end
    
    if zombie:getBumpType() ~= task.anim1 and zombie:getBumpType() ~= task.anim2 then 
        return true
    end

    task.tick = task.tick + 1

    return false
end

ZombieActions.Equip.onComplete = function(zombie, task)
    return true
end

