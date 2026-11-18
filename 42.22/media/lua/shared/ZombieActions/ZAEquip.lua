ZombieActions = ZombieActions or {}

ZombieActions.Equip = {}
ZombieActions.Equip.onStart = function(zombie, task)

    task.stage = 1
    
    if not task.itemPrimary then
        return false
    end

    if task.itemPrimary == "Base.BareHands" then
        return true
    end
    
    local primaryItem = BanditCompatibility.InstanceItem(task.itemPrimary)
    if not primaryItem then
        return false
    end

    -- default
    task.anim1 = "AttachHolsterLeft"
    task.anim2 = "AttachHolsterLeftOut"

    local attachmentType = primaryItem:getAttachmentType()
    for _, def in pairs(ISHotbarAttachDefinition) do
        if def.attachments then
            for k, v in pairs(def.attachments) do
                if k == attachmentType then
                    if def.type == "HolsterRight" then 
                        task.anim1 = "AttachHolsterRight"
                        task.anim2 = "AttachHolsterRightOut"
                        task.slot = v
                        zombie:setBumpType(task.anim1)
                        return true
                    elseif def.type == "Back" then
                        task.anim1 = "AttachBack"
                        task.anim2 = "AttachBackOut"
                        task.slot = v
                        zombie:setBumpType(task.anim1)
                        return true
                    elseif def.type == "SmallBeltLeft" then
                        task.anim1 = "AttachHolsterLeft"
                        task.anim2 = "AttachHolsterLeftOut"
                        task.slot = v
                        zombie:setBumpType(task.anim1)
                        return true
                    end
                end
            end
        end
    end

    

    return true
end

ZombieActions.Equip.onWorking = function(zombie, task)

    if not task.itemPrimary then
        return true
    end

    if task.stage == 1 and zombie:getBumpType() ~= task.anim1 then
        
        if task.slot then
            zombie:setAttachedItem(task.slot, nil)
        end
        Bandit.SetHands(zombie, task.itemPrimary)

        if task.anim2 then
            zombie:setBumpType(task.anim2)
        end
        task.stage = 2
        return false
    end

    if task.stage == 2 and zombie:getBumpType() ~= task.anim2 then
        return true
    end

    return false
end

