ZombieActions = ZombieActions or {}

local function increaseCorpse(square)
    for i=0, square:getSpecialObjects():size()-1 do
        local grave = square:getSpecialObjects():get(i)
        if grave:getName() == "EmptyGraves" then
            grave:getModData()["corpses"] = grave:getModData()["corpses"] + 1
            grave:transmitModData()
            break
        end
    end
end

ZombieActions.BuryCorpse = {}
ZombieActions.BuryCorpse.onStart = function(zombie, task)
    return true
end

ZombieActions.BuryCorpse.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.BuryCorpse.onComplete = function(zombie, task)

    local inventory = zombie:getInventory()

    if inventory:containsType("CorpseMale") then
		inventory:RemoveOneOf("CorpseMale", false)
	elseif inventory:containsType("CorpseFemale") then
		inventory:RemoveOneOf("CorpseFemale", false)
	end

    if BanditUtils.IsController(zombie) then
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

        increaseCorpse(sq1)
        increaseCorpse(sq2)
    end

    return true
end

