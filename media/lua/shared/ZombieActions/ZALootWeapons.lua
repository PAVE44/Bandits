ZombieActions = ZombieActions or {}

local function predicateAll(item)
    -- item:getType()
	return true
end

local function lootContainer(zombie, container, task)
    local items = ArrayList.new()
    container:getAllEvalRecurse(predicateAll, items)
    
    local success = false
    for _, v in pairs(task.toRemove) do
        for i=0, items:size()-1 do
            local item = items:get(i)
            local name = item:getFullType() 
            if v == name then
                container:Remove(item)
                container:removeItemOnServer(item)
                success = true
            end
        end
    end

    if success then
        local weapons = Bandit.GetWeapons(zombie)
        for k, v in pairs(task.toAdd) do
            weapons[k] = v
        end
        Bandit.SetWeapons(zombie, weapons)

        -- requires a sync
        local brain = BanditBrain.Get(zombie)
        local syncData = {}
        syncData.id = brain.id
        syncData.weapons = weapons
        Bandit.ForceSyncPart(zombie, syncData)
    end
    return success
end

ZombieActions.LootWeapons = {}
ZombieActions.LootWeapons.onStart = function(zombie, task)
    return true
end

ZombieActions.LootWeapons.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if task.time <= 0 then
        return true
    else
        local bumpType = zombie:getBumpType()
        if bumpType ~= task.anim then 
            zombie:setBumpType(task.anim)
        end
    end

    return false
end

ZombieActions.LootWeapons.onComplete = function(zombie, task)
    local cell = getCell()
    local square = cell:getGridSquare(task.x, task.y, task.z)
    if square then
        local objects = square:getStaticMovingObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            if instanceof (object, "IsoDeadBody") then
                local container = object:getContainer()
                if container and not container:isEmpty() then
                    local success = lootContainer(zombie, container, task)
                    if success then return end
                end
            end
        end

        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            local container = object:getContainer()
            if container and not container:isEmpty() then
                local success = lootContainer(zombie, container, task)
                if success then return end
            end
        end
    end
    return true
end

