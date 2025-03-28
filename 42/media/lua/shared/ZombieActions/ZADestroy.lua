ZombieActions = ZombieActions or {}

ZombieActions.Destroy = {}
ZombieActions.Destroy.onStart = function(zombie, task)
    Bandit.Say(zombie, "BREACH")
    task.tick = 1
    return true
end

ZombieActions.Destroy.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end

    if task.tick == 25 then
        local cell = zombie:getSquare():getCell()
        local square = cell:getGridSquare(task.x, task.y, task.z)
        local thumpable
        local soundThump
        local soundBreak
        if square then
            local objects = square:getObjects()
            for i=0, objects:size()-1 do
                local object = objects:get(i)
                if instanceof(object, "IsoThumpable") then
                    thumpable = object
                    soundThump = object:getThumpSound()
                    soundBreak = object:getBreakSound()
                elseif instanceof(object, "IsoDoor") then
                    thumpable = object
                    soundThump = object:getThumpSound()
                    soundBreak = object:getThumpSound() -- no break sound for iso door
                end

                if instanceof(object, "IsoWindow") or instanceof(object, "IsoDoor") or instanceof(object, "IsoThumpable") then
                    if object:isBarricaded() then
                        local barricade = object:getBarricadeOnSameSquare()
                        if not barricade then barricade = object:getBarricadeOnOppositeSquare() end
                        thumpable = barricade

                        if barricade:isMetal() or barricade:isMetalBar() then
                            soundThump = "HitBarricadeMetal"
                            soundBreak = "MetalDoorBreak"
                        else
                            soundThump = "HitBarricadePlank"
                            soundBreak = "WoodDoorBreak"
                        end
                        break
                    end
                end
            end
        end

        if thumpable then
            local health = thumpable:getHealth()
            local brain = BanditBrain.Get(zombie)
            local boost = brain.strengthBoost or 1
            
            health = health - (40 * boost)
            -- print ("thumpable health: " .. thumpable:getHealth())
            if health < 0 then health = 0 end
            if health == 0 then
                if instanceof(thumpable, "IsoBarricade") then
                    if BanditUtils.IsController(zombie) then
                        local args = {x=task.x, y=task.y, z=task.z, index=task.idx}
                        sendClientCommand(getSpecificPlayer(0), 'Commands', 'Unbarricade', args)
                    end
                else
                    thumpable:destroy()
                end
                local emitter = getWorld():getFreeEmitter(task.x, task.y, task.z)
                emitter:playSound(soundBreak)
            else
                thumpable:setHealth(health)
                thumpable:Thump(zombie)
                local emitter = getWorld():getFreeEmitter(task.x, task.y, task.z)
                emitter:playSound(soundThump)
            end
            
        end
    end

    task.tick = task.tick + 1
    return false
end

ZombieActions.Destroy.onComplete = function(zombie, task)


    return true
end