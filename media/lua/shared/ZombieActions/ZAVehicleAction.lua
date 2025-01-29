ZombieActions = ZombieActions or {}

ZombieActions.VehicleAction = {}
ZombieActions.VehicleAction.onStart = function(zombie, task)
    local vehicle = getCell():getGridSquare(task.vx, task.vy, 0):getVehicleContainer()
    if vehicle then
        local anim
        if task.area == "TireRearLeft" or task.area == "TireRearRight" or task.area == "TireFrontLeft" or task.area == "TireFrontRight" then
            anim = "LootLow"
            -- zombie:playSound("RepairWithWrench")
        else
            anim = "Loot"
            zombie:playSound("VehicleHoodOpen")
        end
        zombie:setBumpType(anim)
    end
    return true
end

ZombieActions.VehicleAction.onWorking = function(zombie, task)
    zombie:faceLocation(task.px, task.py)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.VehicleAction.onComplete = function(zombie, task)
    local vehicle = getCell():getGridSquare(task.vx, task.vy, 0):getVehicleContainer()
    if vehicle then
        local vehiclePart = vehicle:getPartById(task.id)
        if vehiclePart then
            if task.subaction == "Uninstall" then
                local item = vehiclePart:getInventoryItem()
                if item then
                    if BanditUtils.IsController(zombie) then
                        zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                    end

                    if task.area == "TireRearLeft" or task.area == "TireRearRight" or task.area == "TireFrontLeft" or task.area == "TireFrontRight" then
                        vehiclePart:setModelVisible("InflatedTirePlusWheel", false)
                        vehicle:setTireRemoved(vehiclePart:getWheelIndex(), true)
                    end
                    vehicle:updatePartStats()

                    local args = {x=task.vx, y=task.vy, id=task.id}
                    sendClientCommand(getPlayer(), 'Commands', 'VehiclePartRemove', args)
                end
            end
        end
    end
    
    return true
end

