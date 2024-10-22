require "Farming/CFarmingSystem"

ZombieActions = ZombieActions or {}

ZombieActions.WaterFarm = {}
ZombieActions.WaterFarm.onStart = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if item then
        zombie:setPrimaryHandItem(item)
        inventory:Remove(item)
        zombie:playSound("WaterCrops")
    end
    return true
end

ZombieActions.WaterFarm.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.WaterFarm.onComplete = function(zombie, task)

    local item = zombie:getPrimaryHandItem()
    if not instanceof(item, "DrainableComboItem") then return end

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not square then return true end
    
    local plant = CFarmingSystem.instance:getLuaObjectAt(task.x, task.y, task.z)
    if not plant then return true end

    local waterToPour = plant.waterNeeded - plant.waterLvl
    local waterAvailable = math.floor((item:getUsedDelta() / item:getUseDelta()) + 0.5) * 4
    if waterAvailable < waterToPour then waterToPour = waterAvailable end
    local waterLeft = waterAvailable - waterToPour

    if BanditUtils.IsController(zombie) then
        local args = {x=task.x, y=task.y, z=task.z, uses=waterToPour}
        CFarmingSystem.instance:sendCommand(getPlayer(), 'water', args)
    end

    local newWater = (waterLeft * item:getUseDelta() / 4)
    if newWater > 1 then newWater = 1 end
    item:setUsedDelta(newWater)

    local inventory = zombie:getInventory()
    inventory:AddItem(item)
    return true
end