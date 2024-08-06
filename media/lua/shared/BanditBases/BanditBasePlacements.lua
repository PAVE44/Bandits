BanditBasePlacements = BanditBasePlacements or {}

-- private
local function GetOrCreateSquare (x, y, z)
    local cell = getCell()
    local square = cell:getGridSquare(x, y, z)
	if square == nil and getWorld():isValidSquare(x, y, z) then
		square = cell:createNewGridSquare(x, y, z, true)
	end
    return square
end

local function GetSurfaceOffset (x, y, z)

    local cell = getCell()
    local square = cell:getGridSquare(x, y, z)
    local tileObjects = square:getLuaTileObjectList()
    local squareSurfaceOffset = 0

    -- get the object with the highest offset
    for k, object in pairs(tileObjects) do
        local surfaceOffsetNoTable = object:getSurfaceOffsetNoTable()
        if surfaceOffsetNoTable > squareSurfaceOffset then
            squareSurfaceOffset = surfaceOffsetNoTable
        end

        local surfaceOffset = object:getSurfaceOffset()
        if surfaceOffset > squareSurfaceOffset then
            squareSurfaceOffset = surfaceOffset
        end
    end

    return squareSurfaceOffset / 96
end

-- objects
function BanditBasePlacements.IsoObject (sprite, x, y, z)
    local square = GetOrCreateSquare(x, y, z)
    local obj = IsoObject.new(square, sprite, "")
	square:AddSpecialObject(obj)
	obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.IsoThumpable (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local obj = IsoThumpable.new(cell, square, sprite, false, {})
    -- obj:setHoppable(false)
	square:AddTileObject(obj)
	obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.IsoDoor (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)

    for s, number in string.gmatch(sprite, "(.+)_(%d+)") do
        local north = true
        if (number % 2 == 0) then
            north = false
        end

        obj = IsoDoor.new(cell, square, sprite, north)
        square:AddSpecialObject(obj)
        obj:transmitCompleteItemToServer()
    end
end

function BanditBasePlacements.IsoWindow (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)

    for s, number in string.gmatch(sprite, "(.+)_(%d+)") do
        local north = true
        if (number % 2 == 0) then
            north = false
        end

        obj = IsoWindow.new(cell, square, getSprite(sprite), north)
        obj:setIsLocked(true)
        square:AddSpecialObject(obj)
        obj:transmitCompleteItemToServer()

        local b = 1 + ZombRand(4)
		local barricade = IsoBarricade.AddBarricadeToObject(obj, true)
		if barricade then
			if b == 1 then
				local metal = InventoryItemFactory.CreateItem('Base.SheetMetal')
                metal:setCondition(100)
				barricade:addMetal(nil, metal)
				barricade:transmitCompleteItemToClients()
            elseif b == 2 then
                local metal = InventoryItemFactory.CreateItem('Base.MetalBar')
                metal:setCondition(100)
                barricade:addMetalBar(nil, metal)
                barricade:transmitCompleteItemToClients()
			elseif b == 3 then
				local plank = InventoryItemFactory.CreateItem('Base.Plank')
				plank:setCondition(100)
				barricade:addPlank(nil, plank)
				if barricade:getNumPlanks() == 1 then
					barricade:transmitCompleteItemToClients()
				else
					barricade:sendObjectChange('state')
				end
			end
		end
    end
end

function BanditBasePlacements.IsoCurtain (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)


    obj = IsoCurtain.new(cell, square, sprite, false)
    square:AddSpecialObject(obj)
    obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.IsoLightSwitch (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local spriteObj = getSprite(sprite)
    local spriteProps = spriteObj:getProperties()
    spriteProps:Set("lightR", "110")
    spriteProps:Set("lightG", "110")
    spriteProps:Set("lightB", "90")
    spriteProps:Set("LightRadius", "20")

    obj = IsoLightSwitch.new(cell, square, spriteObj, square:getRoomID())
    obj:setUseBattery(false)
    obj:addLightSourceFromSprite()
    square:AddSpecialObject(obj)
    obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.IsoGenerator (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local genItem = InventoryItemFactory.CreateItem("Base.Generator")
    local obj = IsoGenerator.new(genItem, cell, square)
    obj:setConnected(true)
    obj:setFuel(30 + ZombRand(60))
    obj:setCondition(99)
    obj:setActivated(true)

    -- square:AddSpecialObject(obj)
    obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.Container (sprite, x, y, z, items)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local obj = IsoThumpable.new(cell, square, sprite, false, {})
    obj:setIsContainer(true)
	square:AddSpecialObject(obj)
	obj:transmitCompleteItemToServer()
    return obj:getContainer()
end

function BanditBasePlacements.WaterContainer (sprite, x, y, z, items)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    obj = IsoThumpable.new(cell, square, sprite, false, {})
    obj:setWaterAmount(100+ZombRand(260))
    obj:setTaintedWater(true)
    square:AddSpecialObject(obj)
    obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.Fireplace (sprite, x, y, z, items)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)

    local obj = IsoObject.new(square, sprite, "")
	square:AddSpecialObject(obj)
	obj:transmitCompleteItemToServer()

    obj = IsoFire.new(cell, square)
    obj:AttachAnim("Fire", "01", 4, IsoFireManager.FireAnimDelay, -16, -78, true, 0, false, 0.7, IsoFireManager.FireTintMod)
    square:AddTileObject(obj)
    obj:transmitCompleteItemToServer()
end

function BanditBasePlacements.Fridge (sprite, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local obj = IsoObject.new(square, sprite, "")
    local sprite = getSprite(sprite);
    obj:createContainersFromSpriteProperties()
	square:AddSpecialObject(obj)
	obj:transmitCompleteItemToServer()
end

-- inventory items
function BanditBasePlacements.Journal (title, story, x, y, z)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)

    local surfaceOffset = GetSurfaceOffset(x, y, z)

    
    item = square:AddWorldInventoryItem("Base.Journal", ZombRandFloat(0.3, 0.7), ZombRandFloat(0.3, 0.7), surfaceOffset)
    item:setName(title)
    item:setCustomName(true)
    for i, v in pairs(story) do
        item:addPage(i, v)
    end

    PlaceItem("Base.Pencil", x, y, z, 1)
end

function BanditBasePlacements.Item (item, x, y, z, q)
    local cell = getCell()
    local square = GetOrCreateSquare(x, y, z)
    local surfaceOffset = GetSurfaceOffset(x, y, z)

    for i=1, q do
        square:AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), surfaceOffset)
    end

end

function BanditBasePlacements.Blood (x, y, z, q)
    local square = GetOrCreateSquare(x, y, z)
    local surfaceOffset = GetSurfaceOffset(x, y, z)

    for i=1, q do
        local bx = x + ZombRandFloat(0.1, 0.9)
        local by = y + ZombRandFloat(0.1, 0.9)
        square:getChunk():addBloodSplat(bx, by, surfaceOffset, ZombRand(20))
        -- square:DoSplat
    end
end

-- zombie
function BanditBasePlacements.Body (x, y, z, q)

    for i=1, q do
        local zombie = createZombie(x, y, z, nil, 0, IsoDirections.S)
        local body = IsoDeadBody.new(zombie, false);
    end
end

