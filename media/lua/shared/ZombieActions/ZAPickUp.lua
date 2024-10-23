ZombieActions = ZombieActions or {}

ZombieActions.PickUp = {}
ZombieActions.PickUp.onStart = function(zombie, task)
    return true
end

ZombieActions.PickUp.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.PickUp.onComplete = function(zombie, task)
    if not task.cnt then task.cnt = 1 end

    local zinventory = zombie:getInventory()

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    local toRemove = {}
    if square then
        local wobs = square:getWorldObjects()
        local cnt = 0
        for i=0, wobs:size()-1 do
            local object = wobs:get(i)
            local item = object:getItem()
            local itemType = item:getFullType()
            if itemType == task.itemType then
                item = BanditUtils.ReplaceDrainable(item)
                local test1 = item:getFullType()
                zinventory:AddItem(item)
                table.insert(toRemove, object)
                cnt = cnt + 1
                if cnt >= task.cnt then break end
            end
        end
        
        for k, object in pairs(toRemove) do
            square:removeWorldObject(object)
            square:transmitRemoveItemFromSquare(object)
            local item = object:getItem()
            item:setWorldItem(nil)
        end

    end

    return true
end

