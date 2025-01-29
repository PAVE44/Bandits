ZombieActions = ZombieActions or {}

local function predicateAll(item)
    -- item:getType()
	return true
end

ZombieActions.TakeFromContainer = {}
ZombieActions.TakeFromContainer.onStart = function(zombie, task)
    return true
end

ZombieActions.TakeFromContainer.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.TakeFromContainer.onComplete = function(zombie, task)
    if not task.cnt then task.cnt = 1 end

    local cell = zombie:getCell()
    local csquare = cell:getGridSquare(task.x, task.y, task.z)
    local inventory = zombie:getInventory()

    if csquare then
        local objects = csquare:getObjects()
        local cnt = 0
        for i=0, objects:size() - 1 do
            local object = objects:get(i)
            local container = object:getContainer()
            if container then

                local items = ArrayList.new()
                container:getAllEvalRecurse(predicateAll, items)
                for i=0, items:size()-1 do
                    local item = items:get(i)
                    if item:getFullType() == task.itemType then
                        container:Remove(item)
                        if BanditUtils.IsController(zombie) then
                            container:removeItemOnServer(item)
                        end

                        if not isClient() then
                            if container:getParent() and container:getParent():getOverlaySprite() then
                                ItemPicker.updateOverlaySprite(container:getParent())
                            end
                        end
                        
                        item = BanditUtils.ReplaceDrainable(item)
                        inventory:AddItem(item)
                        Bandit.UpdateItemsToSpawnAtDeath(zombie)
                        cnt = cnt + 1
                        if cnt == task.cnt then return true end
                    end
                end
            end
        end
    end
    return true
end

