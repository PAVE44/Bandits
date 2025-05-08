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
                            local props = sprite:getProperties()
                            if sn ~= "" then
                                local naturefloor = props:Val("natureFloor")
                                local floor = props:Is(IsoFlagType.solidfloor)
                                local canBeRemoved = props:Is(IsoFlagType.canBeRemoved)
                                local vegi = props:Is(IsoFlagType.vegitation)
                                local stone = props:Is("CustomName") and (props:Val("CustomName"):embodies("Stone") or props:Val("CustomName"):embodies("Stump"))
                                local tree = props:Val("tree")
                                if naturefloor or canBeRemoved or vegi or tree or stone then
                                    good = true
                                else
                                    local sn = sprite:getName()
                                    local test = props:Val("CustomName")
                                    -- print ("bad")
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

                                if isSolidFloor and spriteName:embodies("natural") then
                                    object:clearAttachedAnimSprite()
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
                elseif n == 5 then q = 4
                elseif n == 6 then q = 6
                elseif n == 7 then q = 9
                elseif n == 8 then q = 14
                elseif n == 9 then q = 17
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
                elseif n == 3 then q = 2
                elseif n == 4 then q = 3
                elseif n == 5 then q = 4
                elseif n == 6 then q = 6
                elseif n == 7 then q = 9
                elseif n == 8 then q = 14
                elseif n == 9 then q = 17
                end

                BanditBasePlacements.Blood(x+cx, y+cy, z, q) 
            end
        end
    end
end