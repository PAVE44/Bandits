require "Farming/CFarmingSystem"
require "RainBarrel/CRainBarrelSystem"

BanditPlayerBase = BanditPlayerBase or {}

local function predicateAll(item)
	return true
end

local function getBase(x, y)
    for id, base in pairs(BanditPlayerBase.data) do
        if x >= base.x and x <= base.x2 and y >= base.y and y <= base.y2 then
            return id
        end
    end
end

BanditPlayerBase.const = BanditPlayerBase.const or {}

-- determines the margin around a base building to be treated as base area
BanditPlayerBase.const.padding = 20

BanditPlayerBase.data = BanditPlayerBase.data or {}

-- debug
BanditPlayerBase.Debug = function(buildingDef)
    local debug = BanditPlayerBase.data
end

-- function that governs player bases regeneration
BanditPlayerBase.Update = function(numberTicks)
    if numberTicks % 4 == 0 then 
        for baseId, _ in pairs(BanditPlayerBase.data) do
            BanditPlayerBase.Regenerate(baseId)
            BanditPlayerBase.ReindexItems(baseId)
        end
    end
end

-- this updates player bases gradually to preserve performance
BanditPlayerBase.Regenerate = function(baseId)

    -- registers virtual object at the given location of a given type
    local function addObject(baseId, x, y, z, objectType)
        local obj = {}
        local id = x .. "-" .. y .. "-" .. z
        obj.id = id
        obj.x = x
        obj.y = y
        obj.z = z
    
        if not BanditPlayerBase.data[baseId][objectType] then
            BanditPlayerBase.data[baseId][objectType] = {}
        end
    
        BanditPlayerBase.data[baseId][objectType][id] = obj
    end
    
    -- unregisters virtual object at the given location of a given type
    local function removeObject(baseId, x, y, z, objectType)
        local id = x .. "-" .. y .. "-" .. z
        BanditPlayerBase.data[baseId][objectType][id] = nil
    end

    -- registers given items located at the given location for a given base
    local function addItems(baseId, x, y, z, contType, items)
        local obj = {}
        local id = x .. "-" .. y .. "-" .. z
        obj.id = id
        obj.x = x
        obj.y = y
        obj.z = z
        obj.type = contType
        obj.items = items
    
        if not BanditPlayerBase.data[baseId].containers then
            BanditPlayerBase.data[baseId].containers = {}
        end
    
        BanditPlayerBase.data[baseId].containers[id] = obj
    end
    
    -- unregisters all items located at the given location for a given base
    local function removeItems(baseId, x, y, z)
        local id = x .. "-" .. y .. "-" .. z
        BanditPlayerBase.data[baseId].containers[id] = nil
    end
    
    -- scans square for square features and ground items to be registered as virtual objects and items
    local function updateSquare(baseId, square)
        local x = square:getX()
        local y = square:getY()
        local z = square:getZ()

        -- blood
        if square:haveBlood() then
            addObject(baseId, x, y, z, "blood")
        else
            removeObject(baseId, x, y, z, "blood")
        end

        -- ground items
        local items = {}
        local wobs = square:getWorldObjects()
        for i = 0, wobs:size()-1 do
            local o = wobs:get(i)
            local item = o:getItem()
            local itemType = item:getFullType()
            if not items[itemType] then
                items[itemType] = 1
            else
                items[itemType] = items[itemType] + 1
            end
        end

        addItems(baseId, x, y, z, "floor", items)
    end

    -- scans square for lua objects to be registered as virtual objects
    local function updateLuaObjects(baseId, square)
        local x = square:getX()
        local y = square:getY()
        local z = square:getZ()

        -- farms
        local plant = CFarmingSystem.instance:getLuaObjectAt(x, y, z)
        if plant then
            addObject(baseId, x, y, z, "farms")
        else
            removeObject(baseId, x, y, z, "farms")
        end
    end

    -- scans square for real objects to be registered as virtual objects
    local function updateRealObjects(baseId, square)
        local x = square:getX()
        local y = square:getY()
        local z = square:getZ()

        removeObject(baseId, x, y, z, "generators")
        removeObject(baseId, x, y, z, "deadbodies")
        removeObject(baseId, x, y, z, "graves")
        removeObject(baseId, x, y, z, "waterSources")
        removeObject(baseId, x, y, z, "trashcans")

        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            local container = object:getContainer()
            local sprite = object:getSprite()
            local md = object:getModData()
            local props
            if sprite then props = sprite:getProperties() end

            if instanceof(object, "IsoGenerator") then
                addObject(baseId, x, y, z, "generators")
            elseif instanceof(object, "IsoDeadBody") then
                addObject(baseId, x, y, z, "deadbodies")
            elseif object:getName() == "EmptyGraves" and md.filled == false then
                addObject(baseId, x, y, z, "graves")
            elseif object:getWaterAmount() > 0 then
                addObject(baseId, x, y, z, "waterSources")
            elseif props and props:Is("IsTrashCan") then
                addObject(baseId, x, y, z, "trashcans")
            elseif container then

                local arrItems = ArrayList.new()
                local items = {}
                container:getAllEvalRecurse(predicateAll, arrItems)
                for i=0, arrItems:size()-1 do
                    local item = arrItems:get(i)
                    local itemType = item:getFullType()
                    if not items[itemType] then
                        items[itemType] = 1
                    else
                        items[itemType] = items[itemType] + 1
                    end
                end

                addItems(baseId, x, y, z, container:getType(), items)
            end
        end
    end

    local base = BanditPlayerBase.data[baseId]

    local cell = getCell()

    -- player base is updated gradualy by fragments 
    -- size determines a size of a fragment square
    local size = 10

    local xmin = base.x + base.pointer.x
    local xmax = base.x + base.pointer.x + size
    if xmax > base.x2 then xmax = base.x2 end

    local ymin = base.y + base.pointer.y
    local ymax = base.y + base.pointer.y + size
    if ymax > base.y2 then ymax = base.y2 end

    -- print ("scanning: x:" .. xmin .. "-" .. xmax .. " y:" .. ymin .. "-" .. ymax)

    for z=0, 7 do
        for x=xmin, xmax do
            for y=ymin, ymax do
                local square = cell:getGridSquare(x, y, z)
                if square then

                    -- square props
                    updateSquare(baseId, square)

                    -- lua objects 
                    updateLuaObjects(baseId, square)

                    -- real objects
                    updateRealObjects(baseId, square)

                end
            end
        end
    end

    if xmin > base.x2 - size then
        base.pointer.x = 0
        base.pointer.y = base.pointer.y + size
        if ymin > base.y2 - size then
            base.pointer.y = 0
            print ("------ SCAN COMPLETE ------")
        end
    else
        base.pointer.x = base.pointer.x + size
    end
end

-- registers a new base based on building definition
BanditPlayerBase.RegisterBase = function(buildingDef)
    local debug = BanditPlayerBase.data

    local x = buildingDef:getX()
    local y = buildingDef:getY()
    local x2 = buildingDef:getX2()
    local y2 = buildingDef:getY2()

    -- this base already exists, do not overwrite it
    local baseId = x .. "-" .. y
    if getBase(x, y) then return end

    -- init base vars
    local padding = BanditPlayerBase.const.padding
    local base = {}

    base.pointer = {}
    base.pointer.x = 0
    base.pointer.y = 0
    base.pointer.z = 0

    base.x = x - padding
    base.y = y - padding
    base.x2 = x2 + padding
    base.y2 = y2 + padding
    base.items = {}
    base.farms = {}
    base.containers = {}
    base.waterSources = {}
    base.generators = {}
    base.blood = {}
    base.trashcans = {}
    base.deadbodies = {}
    base.graves = {}

    -- register base
    if not BanditPlayerBase.data[baseId] then
        BanditPlayerBase.data[baseId] = base
    end
end

-- iterates over all player base containers to create a map of items
BanditPlayerBase.ReindexItems = function(baseId)
    local items = {}
    local debug = BanditPlayerBase.data
    for contId, cont in pairs(BanditPlayerBase.data[baseId].containers) do
        for itemType, cnt in pairs(cont.items) do
            
            if not items[itemType] then
                items[itemType] = {}
            end
            tab = {}
            tab.x = cont.x
            tab.y = cont.y
            tab.z = cont.z
            tab.type = cont.type
            tab.cnt = cnt

            items[itemType][contId] = tab
            
        end
    end
    BanditPlayerBase.data[baseId].items = items
end

-- returns closest container containing required number of items
BanditPlayerBase.GetContainer = function(character, item, cnt)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    if not BanditPlayerBase.data[baseId].items[item] then return end

    local bestDist = math.huge
    local bestCont
    for contId, cont in pairs(BanditPlayerBase.data[baseId].items[item]) do
        if cont.cnt >= cnt then
            local dist = math.sqrt(math.pow(cont.x - x, 2) + math.pow(cont.y - y, 2))
            if dist < bestDist then
                bestCont = cont
                bestDist = dist
            end
        end
    end

    if bestCont then
        local square = character:getCell():getGridSquare(bestCont.x, bestCont.y, bestCont.z)

        if square then
            if bestCont.type == "floor" then 
                return square
            else
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    local container = object:getContainerByType(bestCont.type)
                    if container and container:getItemCountFromTypeRecurse(item) > 0 then
                        return container
                    end
                end
            end
        end
    end

end

-- returns farm requiring action closest to the character 
BanditPlayerBase.GetFarm = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestPlant
    for k, farm in pairs(BanditPlayerBase.data[baseId].farms) do
        local square = character:getCell():getGridSquare(farm.x, farm.y, farm.z)
        if square then
            local plant = CFarmingSystem.instance:getLuaObjectAt(farm.x, farm.y, farm.z)
            if plant then
                if plant.waterNeeded > 0 and plant.waterLvl < plant.waterNeeded - 20 then
                    local dist = math.sqrt(math.pow(farm.x - x, 2) + math.pow(farm.y - y, 2))
                    if dist < bestDist then
                        bestPlant = plant
                        bestDist = dist
                    end
                end
            end
        end
    end

    return bestPlant
end

-- returns non-empty water source closest to the character 
BanditPlayerBase.GetWaterSource = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestSource
    for k, ws in pairs(BanditPlayerBase.data[baseId].waterSources) do
        local square = character:getCell():getGridSquare(ws.x, ws.y, ws.z)
        if square then
            local objects = square:getObjects()
            local source
            for i=0, objects:size()-1 do
                local object = objects:get(i)
                local md = object:getModData()
                if md.waterAmount and md.waterAmount > 0 then
                    source = object
                    break
                end
            end

            if source then
                local dist = math.sqrt(math.pow(ws.x - x, 2) + math.pow(ws.y - y, 2))
                if dist < bestDist then
                    bestSource = source
                    bestDist = dist
                end
            end
            --[[local barrel = CRainBarrelSystem.instance:getLuaObjectAt(ws.x, ws.y, ws.z)
            if barrel then
                if barrel.waterAmount > 10 then
                    local dist = math.sqrt(math.pow(ws.x - x, 2) + math.pow(ws.y - y, 2))
                    if dist < bestDist then
                        bestBarrel = barrel
                        bestDist = dist
                    end
                end
            end]]

        end
    end

    return bestSource
end

-- returns generator requiring action closest to the character 
BanditPlayerBase.GetGenerator = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestGenerator
    for k, gen in pairs(BanditPlayerBase.data[baseId].generators) do
        local square = character:getCell():getGridSquare(gen.x, gen.y, gen.z)
        if square then
            local generator = square:getGenerator()
            if generator then
                local condition = generator:getCondition()
                local fuel = generator:getFuel()
                if condition < 60 or fuel < 40 then
                    local dist = math.sqrt(math.pow(gen.x - x, 2) + math.pow(gen.y - y, 2))
                    if dist < bestDist then
                        bestGenerator = generator
                        bestDist = dist
                    end
                end
            end
        end
    end

    return bestGenerator
end

-- get square that has blood to clean
BanditPlayerBase.GetBlood = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestBlood
    for k, blood in pairs(BanditPlayerBase.data[baseId].blood) do
        local square = character:getCell():getGridSquare(blood.x, blood.y, blood.z)
        if square then
            if square:haveBlood() then
                local dist = math.sqrt(math.pow(blood.x - x, 2) + math.pow(blood.y - y, 2))
                if dist < bestDist then
                    bestBlood = square
                    bestDist = dist
                end
            end
        end
    end

    return bestBlood
end

-- get square that has a trashcan
BanditPlayerBase.GetTrashcan = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestTrashcan
    for k, trashcan in pairs(BanditPlayerBase.data[baseId].trashcans) do
        local square = character:getCell():getGridSquare(trashcan.x, trashcan.y, trashcan.z)
        if square then
            local dist = math.sqrt(math.pow(trashcan.x - x, 2) + math.pow(trashcan.y - y, 2))
            if dist < bestDist then
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    local sprite = object:getSprite()
                    if sprite then
                        local props = sprite:getProperties()
                        if props then
                            if sprite:getProperties():Is("IsTrashCan") then
                                -- BanditPlayerBase.UpdateTrashcan(object)
                                bestTrashcan = object
                                bestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTrashcan
end

-- get square that has a grave
BanditPlayerBase.GetGrave = function(character, isFull)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestGrave
    for k, grave in pairs(BanditPlayerBase.data[baseId].graves) do
        local square = character:getCell():getGridSquare(grave.x, grave.y, grave.z)
        if square then
            local dist = math.sqrt(math.pow(grave.x - x, 2) + math.pow(grave.y - y, 2))
            if dist < bestDist then
                local objects = square:getSpecialObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    if object:getName() == "EmptyGraves" then
                        local corpses = object:getModData()["corpses"]
                        local filled = object:getModData()["filled"]
                        if filled == false then
                            if (isFull and corpses >=5) or (not isFull and corpses < 5) then
                                bestGrave = object
                                bestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return bestGrave
end

-- get square that has a deadbody
BanditPlayerBase.GetDeadbody = function(character)
    local x = character:getX()
    local y = character:getY()

    local baseId = getBase(x, y)
    if not baseId then return end

    local bestDist = math.huge
    local bestDeadbody
    for k, deadbody in pairs(BanditPlayerBase.data[baseId].deadbodies) do
        local square = character:getCell():getGridSquare(deadbody.x, deadbody.y, deadbody.z)
        if square then
            local dist = math.sqrt(math.pow(deadbody.x - x, 2) + math.pow(deadbody.y - y, 2))
            if dist < bestDist then
                local deadbody = square:getDeadBody()
                if deadbody then
                    bestDeadbody = deadbody
                    bestDist = dist
                end
            end
        end
    end

    return bestDeadbody
end

Events.OnTick.Add(BanditPlayerBase.Update)