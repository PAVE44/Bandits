BanditBrain = BanditBrain or {}

function BanditBrain.Get(zombie)
    local modData = zombie:getModData()
    return modData.brain
end

function BanditBrain.Update(zombie, brain)
    local modData = zombie:getModData()
    modData.brain = brain
end

function BanditBrain.Remove(zombie)
    local modData = zombie:getModData()
    modData.brain = nil
end

function BanditBrain.IsOutOfAmmo(brain)
    local weapons = brain.weapons
    if weapons.primary.bulletsLeft <= 0 and 
        ((weapons.primary.type == "mag" and weapons.primary.magCount <= 0) or
            (weapons.primary.type == "nomag" and weapons.primary.ammoCount <= 0))
        and weapons.secondary.bulletsLeft <= 0 and 
        ((weapons.secondary.type == "mag" and weapons.secondary.magCount <= 0) or 
            (weapons.secondary.type == "nomag" and weapons.secondary.ammoCount <= 0)) then
        return true
    end
    return false
end

function BanditBrain.NeedResupplySlot(brain, slot)
    local weapons = brain.weapons
    if not weapons[slot].name or 
        (
            weapons.primary.bulletsLeft <= 0 and 
            (
                (weapons[slot].type == "mag" and weapons[slot].magCount <= 0) or
                (weapons[slot].type == "nomag" and weapons[slot].ammoCount <= 0)
            )
        ) then

        return true

    end
    return false
end

function BanditBrain.IsBareHands(brain)
    local weapons = brain.weapons
    if weapons.melee == "Base.BareHands" then
        return true
    end
    return false
end

function BanditBrain.HasTask(brain)
    if #brain.tasks > 0 then
        return true
    end
    return false
end

function BanditBrain.HasActionTask(brain)
    for _, task in pairs(brain.tasks) do
        if task.action ~= "Move" and task.action ~= "GoTo" then
            return true
        end
    end

    return false
end

function BanditBrain.HasMoveTask(brain)
    for _, task in pairs(brain.tasks) do
        if task.action == "Move" or task.action == "GoTo" then
            return true
        end
    end
    return false
end

function BanditBrain.HasTaskType(brain, taskType)

    for _, task in pairs(brain.tasks) do
        if task.action == taskType then
            return true
        end
    end

    return false
end

function BanditBrain.HasTaskTypes(brain, taskTypes)
    local cnt = #taskTypes
    for _, task in pairs(brain.tasks) do
        for i=1, cnt do
            if task.action == taskTypes[i] then
                return true
            end
        end
    end

    return false
end