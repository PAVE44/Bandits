ZombieActions = ZombieActions or {}

ZombieActions.Unequip = {}
ZombieActions.Unequip.onStart = function(zombie, task)
    task.tick = 1
    if task.itemPrimary then
        local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
        if primaryItem then
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
    end
    
    return true
end

ZombieActions.Unequip.onWorking = function(zombie, task)
    if task.tick == 1 then
        zombie:setBumpType(task.anim1)
    end
    if task.tick == 15 then
        local brain = BanditBrain.Get(zombie)
        if task.itemPrimary then
            local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
            primaryItem = BanditWeapons.Modify(primaryItem, brain)
            if task.slot then
                zombie:setAttachedItem(task.slot, primaryItem)
            end
            zombie:setPrimaryHandItem(nil)
            zombie:clearVariable("BanditPrimary")
            zombie:clearVariable("BanditPrimaryType")

        end
    end

    if zombie:getBumpType() ~= task.anim1 and zombie:getBumpType() ~= task.anim2 then 
        return true
    end

    task.tick = task.tick + 1

    return false
end

ZombieActions.Unequip.onComplete = function(zombie, task)

    return true
end

