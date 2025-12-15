require "Farming/CFarmingSystem"

ZombieActions = ZombieActions or {}

ZombieActions.StompPlant = {}
ZombieActions.StompPlant.onStart = function(zombie, task)
    return true
end

ZombieActions.StompPlant.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.StompPlant.onComplete = function(zombie, task)

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if not square then return true end
    
    local plant = CFarmingSystem.instance:getLuaObjectAt(task.x, task.y, task.z)
    if not plant then return true end

    if BanditUtils.IsController(zombie) and ZombRand(4) == 0 then
        local args = {x=task.x, y=task.y, z=task.z}
        CFarmingSystem.instance:sendCommand(getSpecificPlayer(0), 'destroy', args)
    end

    return true
end