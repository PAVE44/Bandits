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
    base.x = x - padding
    base.y = y - padding
    base.x2 = x2 + padding
    base.y2 = y2 + padding
    base.items = {}
    base.farms = {}
    base.containers = {}
    base.waterSources = {}
    base.generators = {}

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
            tab.cnt = cnt

            items[itemType][contId] = tab
            
        end
    end
    BanditPlayerBase.data[baseId].items = items
end

-- registers container and its items
BanditPlayerBase.UpdateContainer = function(container)

    if not container then return end
    local debug = BanditPlayerBase.data

    local x, y, z
    if container:getType() == "floor" then
        local player = getPlayer()
        x = math.floor(player:getX() + 0.5)
        y = math.floor(player:getY() + 0.5)
        y = player:getZ()
    else
        local object = container:getParent()
        x = object:getX()
        y = object:getY()
        z = object:getZ()
    end
    local contId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    local cont = {}
    cont.id = contId
    cont.x = x
    cont.y = y
    cont.z = z
    cont.items = {}

    local items = ArrayList.new()
    container:getAllEvalRecurse(predicateAll, items)
    for i=0, items:size()-1 do
        local item = items:get(i)
        local itemType = item:getType()
        if not cont.items[itemType] then
            cont.items[itemType] = 1
        else
            cont.items[itemType] = cont.items[itemType] + 1
        end
    end
    BanditPlayerBase.data[baseId].containers[contId] = cont

    BanditPlayerBase.ReindexItems(baseId)
end

-- registers farm
BanditPlayerBase.UpdateFarm = function(farm)
    local x = farm:getX()
    local y = farm:getY()
    local z = farm:getZ()
    local farmId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    local farm = {}
    farm.id = farmId
    farm.x = x
    farm.y = y
    farm.z = z

    if not BanditPlayerBase.data[baseId].farms then
        BanditPlayerBase.data[baseId].farms = {}
    end

    BanditPlayerBase.data[baseId].farms[farmId] = farm
    local debug = BanditPlayerBase.data
end

-- unregisters farm
BanditPlayerBase.RemoveFarm = function(farm)
    local x = farm:getX()
    local y = farm:getY()
    local z = farm:getZ()
    local farmId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    if not BanditPlayerBase.data[baseId].farms then
        BanditPlayerBase.data[baseId].farms = {}
    end

    if BanditPlayerBase.data[baseId].farms[farmId] then
        BanditPlayerBase.data[baseId].farms[farmId] = nil
    end
    local debug = BanditPlayerBase.data
end

-- registers water source
BanditPlayerBase.UpdateWaterSource = function(waterSource)
    local x = waterSource:getX()
    local y = waterSource:getY()
    local z = waterSource:getZ()
    local waterSourceId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    local waterSource = {}
    waterSource.id = waterSourceId
    waterSource.x = x
    waterSource.y = y
    waterSource.z = z

    if not BanditPlayerBase.data[baseId].waterSources then
        BanditPlayerBase.data[baseId].waterSources = {}
    end

    BanditPlayerBase.data[baseId].waterSources[waterSourceId] = waterSource
    local debug = BanditPlayerBase.data
end

-- registers generator
BanditPlayerBase.UpdateGenerator = function(generator)
    local x = generator:getX()
    local y = generator:getY()
    local z = generator:getZ()
    local generatorId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    local generator = {}
    generator.id = generatorId
    generator.x = x
    generator.y = y
    generator.z = z

    if not BanditPlayerBase.data[baseId].generators then
        BanditPlayerBase.data[baseId].generators = {}
    end

    BanditPlayerBase.data[baseId].generators[generatorId] = generator
    local debug = BanditPlayerBase.data
end

-- unregisters generator
BanditPlayerBase.RemoveGenerator = function(generator)
    local x = generator:getX()
    local y = generator:getY()
    local z = generator:getZ()
    local generatorId = x .. "-" .. y .. "-" .. z

    local baseId = getBase(x, y)
    if not baseId then return end

    if not BanditPlayerBase.data[baseId].generators then
        BanditPlayerBase.data[baseId].generators = {}
    end

    if BanditPlayerBase.data[baseId].generators[generatorId] then
        BanditPlayerBase.data[baseId].generators[generatorId] = nil
    end

    local debug = BanditPlayerBase.data
end

-- returns generator requiring action closest to the character 
BanditPlayerBase.GetGenerator = function(character)
    local debug = BanditPlayerBase.data

    if getWorld():isHydroPowerOn() then return end

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
                if condition < 70 or fuel < 60 then
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