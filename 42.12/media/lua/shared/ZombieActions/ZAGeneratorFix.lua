ZombieActions = ZombieActions or {}

ZombieActions.GeneratorFix = {}
ZombieActions.GeneratorFix.onStart = function(zombie, task)
    zombie:playSound("GeneratorRepair")
    return true
end

ZombieActions.GeneratorFix.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.GeneratorFix.onComplete = function(zombie, task)
    zombie:getEmitter():stopAll()

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not square then return true end

    local generator = square:getGenerator()
    if not generator then return true end

    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType("ElectronicsScrap")
    if item then
        inventory:Remove(item)
        Bandit.UpdateItemsToSpawnAtDeath(zombie)
    end

    if BanditUtils.IsController(zombie) then
        local condition = generator:getCondition()
        local newCondition = condition + 5
        if newCondition > 100 then newCondition = 100 end
        generator:setCondition(newCondition)
    end

    return true
end

