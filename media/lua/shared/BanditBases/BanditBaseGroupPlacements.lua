BanditBaseGroupPlacements = BanditBaseGroupPlacements or {}

function BanditBaseGroupPlacements.CheckSpace (x, y, w, h)
    local cell = getCell()
    for cx=x, x+w do
        for cy=y, y+h do
            local square = cell:getGridSquare(cx, cy, 0)
            if square then
                local player = square:getPlayer()
                if player then 
                    return false
                end

                local objects = square:getObjects()
                local good = false
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    if object then
                        local sprite = object:getSprite()
                        if sprite then 
                            local sn = sprite:getName()
                            if sn ~= "" then
                                local naturefloor = sprite:getProperties():Val("natureFloor")
                                local floor = sprite:getProperties():Is(IsoFlagType.solidfloor)
                                local canBeRemoved = sprite:getProperties():Is(IsoFlagType.canBeRemoved)
                                local vegi = sprite:getProperties():Is(IsoFlagType.vegitation)
                                local tree = sprite:getProperties():Val("tree")
                                if naturefloor or canBeRemoved or vegi or tree then
                                    good = true
                                else
                                    local sn = sprite:getName()
                                    print ("bad")
                                end
                            end
                        end
                    end
                end
                if not good then return false end
            else
                return false
            end
        end
    end
    return true
end

function BanditBaseGroupPlacements.ClearSpace (x, y, z, w, h)
    local cell = getCell()

    for cz=0, 2 do
        for cx=x, x+w do
            for cy=y, y+h do
                local square = cell:getGridSquare(cx, cy, cz)
                if square then
                    local objects = square:getObjects()
                    local destroyList = {}

                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if object then
                            local sprite = object:getSprite()
                            if sprite then 
                                local spriteName = sprite:getName()
                                local spriteProps = sprite:getProperties()

                                local isSolidFloor = spriteProps:Is(IsoFlagType.solidfloor)
                                local isAttachedFloor = spriteProps:Is(IsoFlagType.attachedFloor)

                                if not isSolidFloor or cz > 0 then
                                    table.insert(destroyList, object)
                                end
                            end
                        end
                    end

                    for k, obj in pairs(destroyList) do
                        if isClient() then
                            sledgeDestroy(obj);
                        else
                            square:transmitRemoveItemFromSquare(obj)
                        end
                    end
                end
            end
        end
    end
end

-- objects
function BanditBaseGroupPlacements.Junk (x, y, z, w, h, intensity)
    for cx=1, w do
        for cy=1, h do
            if ZombRand(100) < intensity then
                local rn = ZombRand(53)
                local sprite = "trash_01_" .. tostring(rn)
                BanditBasePlacements.IsoObject(sprite, x+cx, y+cy, z)
            end
        end
    end
end

function BanditBaseGroupPlacements.Papers (x, y, z, w, h, intensity)
    for cx=1, w do
        for cy=1, h do
            if ZombRand(100) < intensity then
                local rn = ZombRand(95)
                local sprite = "desks_01_" .. tostring(rn)
                BanditBasePlacements.IsoObject(sprite, x+cx, y+cy, z)
            end
        end
    end
end

-- items
function BanditBaseGroupPlacements.Item (item, x, y, z, w, h, intensity)
    for cx=1, w do
        for cy=1, h do
            if ZombRand(100) < intensity then

                local n = ZombRand(10)
                if n < 3 then q = 1
                elseif n == 3 then q = 2
                elseif n == 4 then q = 3
                elseif n == 5 then q = 5
                elseif n == 6 then q = 8
                elseif n == 7 then q = 13
                elseif n == 8 then q = 21
                elseif n == 9 then q = 34
                end

                BanditBasePlacements.Item (item, x+cx, y+cy, z, q)
            end
        end
    end
end

function BanditBaseGroupPlacements.Blood (x, y, z, w, h, intensity)
    for cx=1, w do
        for cy=1, h do
            if ZombRand(100) < intensity then

                local n = ZombRand(10)
                if n < 3 then q = 3
                elseif n == 3 then q = 5
                elseif n == 4 then q = 8
                elseif n == 5 then q = 13
                elseif n == 6 then q = 21
                elseif n == 7 then q = 34
                elseif n == 8 then q = 55
                elseif n == 9 then q = 80
                end

                BanditBasePlacements.Blood(x+cx, y+cy, z, q) 
            end
        end
    end
end