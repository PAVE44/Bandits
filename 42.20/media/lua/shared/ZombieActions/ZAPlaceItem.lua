ZombieActions = ZombieActions or {}

ZombieActions.PlaceItem = {}
ZombieActions.PlaceItem.onStart = function(zombie, task)
    return true
end

ZombieActions.PlaceItem.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.PlaceItem.onComplete = function(zombie, task)
    if not BanditUtils.IsController(zombie) then return true end

    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if not item then return true end

    local cell = getCell()
    local square = cell:getGridSquare(task.x, task.y, task.z)
    local tileObjects = square:getLuaTileObjectList()
    local squareSurfaceOffset = 0

    -- get the object with the highest offset
    for k, object in pairs(tileObjects) do
        local surfaceOffsetNoTable = object:getSurfaceOffsetNoTable()
        if surfaceOffsetNoTable > squareSurfaceOffset then
            squareSurfaceOffset = surfaceOffsetNoTable
        end

        local surfaceOffset = object:getSurfaceOffset()
        if surfaceOffset > squareSurfaceOffset then
            squareSurfaceOffset = surfaceOffset
        end
    end

    squareSurfaceOffset = squareSurfaceOffset / 96

    inventory:Remove(item)

    square:AddWorldInventoryItem(item, ZombRandFloat(0.35, 0.65), ZombRandFloat(0.35, 0.65), squareSurfaceOffset)

    return true
end

