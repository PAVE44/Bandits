require "Farming/CFarmingSystem"

ZombieActions = ZombieActions or {}

local function getFakeItem(itemType)
    local fakeItemType
    if itemType == "farming.WateredCanFull" or itemType == "farming.WateredCan" or itemType == "Base.WateredCan" then
        fakeItemType = "Bandits.WateringCan"
    elseif itemType == "Base.BucketWaterFull" or itemType == "Base.BucketEmpty" or itemType == "Base.Bucket" then
        fakeItemType = "Bandits.Bucket"
    end
    local fakeItem = BanditCompatibility.InstanceItem(fakeItemType)
    return fakeItem
end

ZombieActions.WaterFarm = {}
ZombieActions.WaterFarm.onStart = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if not instanceof(item, "DrainableComboItem") then return end

    local fakeItem = getFakeItem(item:getFullType())
    zombie:setPrimaryHandItem(fakeItem)
    zombie:playSound("WaterCrops")

    return true
end

ZombieActions.WaterFarm.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.WaterFarm.onComplete = function(zombie, task)

    zombie:setPrimaryHandItem(nil)

    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
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
        CFarmingSystem.instance:sendCommand(getSpecificPlayer(0), 'water', args)
    end

    local newWater = (waterLeft * item:getUseDelta() / 4)
    if newWater > 1 then newWater = 1 end
    item:setUsedDelta(newWater)

    -- local inventory = zombie:getInventory()
    -- inventory:AddItem(item)
    return true
end