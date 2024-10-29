ZombieActions = ZombieActions or {}

local function predicateAll(item)
    -- item:getType()
	return true
end

ZombieActions.LootItems = {}
ZombieActions.LootItems.onStart = function(zombie, task)
    return true
end

ZombieActions.LootItems.onWorking = function(zombie, task)
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

ZombieActions.LootItems.onComplete = function(zombie, task)
    local cell = getCell()
    local csquare = cell:getGridSquare(task.x, task.y, task.z)
    local zinventory = zombie:getInventory()

    if csquare then
        local objects = csquare:getObjects()
        for i=0, objects:size() - 1 do
            local object = objects:get(i)
            local container = object:getContainer()
            if container and not container:isEmpty() then

                local items = ArrayList.new()
                container:getAllEvalRecurse(predicateAll, items)
                for i=0, items:size()-1 do
                    local item = items:get(i)
                    local name = item:getFullType() 
                    print ("ITEM: " .. name)
                    container:Remove(item)
                    container:removeItemOnServer(item)
                    zinventory:AddItem(item)
                    Bandit.UpdateItemsToSpawnAtDeath(zombie)
                end
            end
        end
    end
    return true
end

