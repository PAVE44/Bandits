ZombieActions = ZombieActions or {}

ZombieActions.Destroy = {}
ZombieActions.Destroy.onStart = function(zombie, task)
    Bandit.Say(zombie, "BREACH")
    return true
end

ZombieActions.Destroy.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Destroy.onComplete = function(zombie, task)
    local cell = zombie:getSquare():getCell()
    local square = cell:getGridSquare(task.x, task.y, task.z)
    if square then
        local thumpable = square:getIsoDoor()
        
        if not thumpable then
            local objects = square:getSpecialObjects()
            for i=0, objects:size()-1 do
                local obj = objects:get(i)
                if instanceof(obj, "IsoThumpable") then
                    thumpable = obj
                    break
                end
            end
        end

        if thumpable then
            local health = thumpable:getHealth()
            -- print ("thumpable health: " .. thumpable:getHealth())
            health = health - 40
            if health < 0 then health = 0 end
            if health == 0 then
                thumpable:destroy()
            else
                thumpable:setHealth(health)
                thumpable:Thump(zombie)
            end
        end
    end

    return true
end