ZombieActions = ZombieActions or {}

ZombieActions.GeneratorRefill = {}
ZombieActions.GeneratorRefill.onStart = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType("PetrolCan")
    if item then
        zombie:setPrimaryHandItem(item)
        inventory:Remove(item)
        Bandit.UpdateItemsToSpawnAtDeath(zombie)
        zombie:playSound("GeneratorAddFuel")
    end
    return true
end

ZombieActions.GeneratorRefill.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.GeneratorRefill.onComplete = function(zombie, task)
    zombie:getEmitter():stopAll()

    local item = zombie:getPrimaryHandItem()
    local itemType = item:getType()
    if itemType ~= "PetrolCan" then return true end

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not square then return true end

    local generator = square:getGenerator()
    if not generator then return true end

    local gasFuel = item:getUsedDelta() * 80
    local fuel = generator:getFuel()
    local newFuel = fuel + gasFuel
    local gasLeft = (newFuel - 100) / 80
    if newFuel > 100 then newFuel = 100 end
    
    if gasLeft > 0 then
        item:setUsedDelta(gasLeft)
    else
        item = BanditCompatibility.InstanceItem("Base.EmptyPetrolCan")
    end

    if BanditUtils.IsController(zombie) and item then
        generator:setFuel(newFuel)
        square:AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
    end

    return true
end

