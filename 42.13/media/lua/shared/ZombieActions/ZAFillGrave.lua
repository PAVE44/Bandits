ZombieActions = ZombieActions or {}

local function changeSprite(square)
    for i=0,square:getSpecialObjects():size()-1 do
        local grave = square:getSpecialObjects():get(i)
        if grave:getName() == "EmptyGraves" then
            grave:getModData()["filled"] = true
            grave:transmitModData()
            local split = luautils.split(grave:getSprite():getName(), "_")
            local spriteName = "location_community_cemetary_01_" .. (split[5] + 8)
            grave:setSpriteFromName(spriteName)
            grave:transmitUpdatedSpriteToServer()
            break
        end
    end
end

ZombieActions.FillGrave = {}
ZombieActions.FillGrave.onStart = function(zombie, task)
    local inventory = zombie:getInventory()
    local item = inventory:getItemFromType(task.itemType)
    if item then
        zombie:setPrimaryHandItem(item)
        zombie:setVariable("BanditPrimary", task.itemType)
        zombie:setVariable("BanditPrimaryType", "twohanded")
        inventory:Remove(item)
        zombie:playSound("Shoveling")
    end
    return true
end

ZombieActions.FillGrave.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if task.time <= 0 then
        return true
    else
        local bumpType = zombie:getBumpType()
        if bumpType ~= task.anim then 
            zombie:playSound("Shoveling")
            zombie:setBumpType(task.anim)
        end
    end
end

ZombieActions.FillGrave.onComplete = function(zombie, task)
    zombie:getEmitter():stopAll()

    local sq1 = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    local sq2 = nil
    if not sq1 then return true end

    local objects = sq1:getSpecialObjects()
    local grave
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        if object:getName() == "EmptyGraves" then
            grave = object
            break
        end
    end
    if not grave then return true end

    if grave:getNorth() then
        if grave:getModData()["spriteType"] == "sprite1" then
            sq2 = getCell():getGridSquare(sq1:getX(), sq1:getY() - 1, sq1:getZ());
        elseif grave:getModData()["spriteType"] == "sprite2" then
            sq2 = getCell():getGridSquare(sq1:getX(), sq1:getY() + 1, sq1:getZ());
        end
    else
        if grave:getModData()["spriteType"] == "sprite1" then
            sq2 = getCell():getGridSquare(sq1:getX() - 1, sq1:getY(), sq1:getZ());
        elseif grave:getModData()["spriteType"] == "sprite2" then
            sq2 = getCell():getGridSquare(sq1:getX() + 1, sq1:getY(), sq1:getZ());
        end
    end

    if sq1 and sq2 then
        changeSprite(sq1)
        changeSprite(sq2)
    end

    local item = zombie:getPrimaryHandItem()
    
    local inventory = zombie:getInventory()
    inventory:AddItem(item)


    -- zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)

    return true
end

