ZombieActions = ZombieActions or {}

ZombieActions.CleanBlood = {}
ZombieActions.CleanBlood.onStart = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if item then
        zombie:setPrimaryHandItem(item)
        zombie:setVariable("BanditPrimary", task.itemType)
        zombie:setVariable("BanditPrimaryType", "twohanded")
        inventory:Remove(item)
        Bandit.UpdateItemsToSpawnAtDeath(zombie)
        zombie:playSound("CleanBloodScrub")
    end
    return true
end

ZombieActions.CleanBlood.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if task.time <= 0 then
        return true
    else
        local bumpType = zombie:getBumpType()
        if bumpType ~= task.anim then 
            zombie:playSound("CleanBloodScrub")
            zombie:setBumpType(task.anim)
        end
    end
end

ZombieActions.CleanBlood.onComplete = function(zombie, task)
    zombie:getEmitter():stopAll()

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not square then return true end

    local bleach = zombie:getInventory():getItemFromType("Bleach")
    local amount = bleach:getFluidContainer():getAmount()
    local use = ZomboidGlobals.CleanBloodBleachAmount
    if amount >= use then
        bleach:getFluidContainer():adjustAmount(amount - use)
        square:removeBlood(false, false)
    end

    return true
end