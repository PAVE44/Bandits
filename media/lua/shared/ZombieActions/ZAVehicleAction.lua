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
    local asn = zombie:getActionStateName()
    if asn == "bumped" then
        return false
    else
        return true
    end
end

ZombieActions.VehicleAction.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        
        local vehicle = getCell():getGridSquare(task.vx, task.vy, 0):getVehicleContainer()
        if vehicle then
            local vehiclePart = vehicle:getPartById(task.id)
            if vehiclePart then
                if task.subaction == "Uninstall" then
                    local item = vehiclePart:getInventoryItem()
                    if item then
                        zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                        -- vehiclePart:damage(100)
                        vehiclePart:setInventoryItem(nil)
                        vehicle:transmitPartItem(vehiclePart)
                        if task.area == "TireRearLeft" or task.area == "TireRearRight" or task.area == "TireFrontLeft" or task.area == "TireFrontRight" then
                            vehiclePart:setModelVisible("InflatedTirePlusWheel", false)
                            vehicle:setTireRemoved(vehiclePart:getWheelIndex(), true)
                        end
                        vehicle:updatePartStats()
                    end
                end
            end
        end
        
    end
    
    return true
end

