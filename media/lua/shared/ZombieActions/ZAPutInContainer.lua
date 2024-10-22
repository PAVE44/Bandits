ZombieActions = ZombieActions or {}

ZombieActions.PutInContainer = {}
ZombieActions.PutInContainer.onStart = function(zombie, task)
    return true
end

ZombieActions.PutInContainer.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end

    return false
end

ZombieActions.PutInContainer.onComplete = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if not item then return true end

    local csquare = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not csquare then return end

    local objects = csquare:getObjects()
    local cnt = 0
    for i=0, objects:size() - 1 do
        local object = objects:get(i)
        local container = object:getContainer()
        if container then
            container:AddItem(item)
            if BanditUtils.IsController(zombie) then
                container:addItemOnServer(item)
            end
            inventory:Remove(item)
            break
        end
    end
    return true
end

