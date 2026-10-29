ZombieActions = ZombieActions or {}

ZombieActions.TimeItem = {}
ZombieActions.TimeItem.onStart = function(zombie, task)
    if task.item then
        local fakeItem = BanditCompatibility.InstanceItem(task.item)
        if not task.left then
            zombie:setPrimaryHandItem(fakeItem)
        end
        if not task.right then
            zombie:setSecondaryHandItem(fakeItem)
        end

    end
    return true
end

ZombieActions.TimeItem.onWorking = function(zombie, task)
    if task.time <= 0 then
        return true
    else
        local bumpType = zombie:getBumpType()
        if bumpType ~= task.anim then 
            zombie:setBumpType(task.anim)

            if task.sound then
                local emitter = zombie:getEmitter()
                if not emitter:isPlaying(task.sound) then
                    emitter:playSound(task.sound)
                end
            end

        end
    end
end

ZombieActions.TimeItem.onComplete = function(zombie, task)
    if task.item then
        if task.left then
            zombie:setSecondaryHandItem(nil)
        else
            zombie:setPrimaryHandItem(nil)
        end
    end
    return true
end