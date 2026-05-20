ZombieActions = ZombieActions or {}

ZombieActions.PickUpBody = {}
ZombieActions.PickUpBody.onStart = function(zombie, task)
    return true
end

ZombieActions.PickUpBody.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.PickUpBody.onComplete = function(zombie, task)
    if not task.cnt then task.cnt = 1 end

    local inventory = zombie:getInventory()
    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if square then
        local body = square:getDeadBody()
        if body then
            inventory:AddItem(body:getItem())
            if BanditUtils.IsController(zombie) then
                square:removeCorpse(body, false)
            end
        end
    end

    return true
end

