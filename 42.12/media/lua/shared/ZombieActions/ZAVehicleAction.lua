ZombieActions = ZombieActions or {}

ZombieActions.VehicleAction = {}
ZombieActions.VehicleAction.onStart = function(zombie, task)
    local vehicle = getCell():getGridSquare(task.vx, task.vy, task.vz):getVehicleContainer()
    if vehicle then
        if task.partId == "TireRearLeft" or task.partId == "TireRearRight" or task.partId == "TireFrontLeft" or task.partId == "TireFrontRight" then
            task.anim = "LootLow"
            -- zombie:playSound("RepairWithWrench")
        else
            task.anim = "Loot"
            zombie:playSound("VehicleHoodOpen")
        end
        zombie:setBumpType(task.anim)
    end
    return true
end

ZombieActions.VehicleAction.onWorking = function(zombie, task)
    local vehicle = getCell():getGridSquare(task.vx, task.vy, task.vz):getVehicleContainer()
    if not vehicle then return true end

    if task.fx and task.fy then
        zombie:faceLocation(task.fx, task.fy)
    end

    local bumpType = zombie:getBumpType()
    if bumpType ~= task.anim then 
        zombie:setBumpType(task.anim)
    end

    if task.sound then
        local emitter = zombie:getEmitter()
        if not emitter:isPlaying(task.sound) then
            emitter:playSound(task.sound)
        end
    end

    return false
end

ZombieActions.VehicleAction.onComplete = function(zombie, task)
    if task.sound then
        local emitter = zombie:getEmitter()
        emitter:stopSoundByName(task.sound)
    end

    local vehicle = getCell():getGridSquare(task.vx, task.vy, task.vz):getVehicleContainer()
    if vehicle then
        local vehiclePart = vehicle:getPartById(task.partId)
        if vehiclePart then
            if task.subaction == "Uninstall" then
                local item = vehiclePart:getInventoryItem()
                if item then
                    if BanditUtils.IsController(zombie) then
                        zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                    end

                    if task.partId == "TireRearLeft" or task.partId == "TireRearRight" or task.partId == "TireFrontLeft" or task.partId == "TireFrontRight" then
                        vehiclePart:setModelVisible("InflatedTirePlusWheel", false)
                        vehicle:setTireRemoved(vehiclePart:getWheelIndex(), true)
                    end
                    vehicle:updatePartStats()

                    local args = {x=task.vx, y=task.vy, id=task.partId}
                    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehiclePartRemove', args)
                end
            end
        end
    end
    
    return true
end

