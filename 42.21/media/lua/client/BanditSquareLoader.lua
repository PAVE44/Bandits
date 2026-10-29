local processSquare = function(square)

    if square:HasSlopedRoof() or square:HasEave() then return end

    local wallNS = square:getWall(true) or square:getHoppableThumpable(true)
    local wallWE = square:getWall(false) or square:getHoppableThumpable(false)

    local wall
    local newCanPath

    if wallNS or wallWE and not square:haveRoofFull() then

        if wallNS and wallNS:isTallHoppable() then
            -- local test2 = instanceof(wallNS, "IsoThumpable")
            -- local test3 = wallNS:getSprite():getProperties():Is(IsoFlagType.canPathN)
            -- if (not instanceof(wallNS, "IsoThumpable") or not wallNS:getSprite():getProperties():Is(IsoFlagType.canPathN)) then
            wall = wallNS
            newCanPath = IsoFlagType.canPathN
            -- end
        elseif wallWE and wallWE:isTallHoppable() then
            -- local test2 = instanceof(wallWE, "IsoThumpable")
            -- local test3 = wallWE:getSprite():getProperties():Is(IsoFlagType.canPathN)
            -- if (not instanceof(wallWE, "IsoThumpable") or not wallWE:getSprite():getProperties():Is(IsoFlagType.canPathW))  then
            wall = wallWE
            newCanPath = IsoFlagType.canPathW

            -- end
        end
    end

    if wall then
        local sprite = wall:getSprite()
        local oldSpriteName = sprite:getName()

        local health = 300
        if instanceof(wall, "IsoThumpable") then
            health = wall:getHealth()
        end

        if isClient() then
            sledgeDestroy(wall)
        else
            square:transmitRemoveItemFromSquare(wall)
            -- print ("TRANSMIT " .. oldWall:getX() .. " " .. oldWall:getY() .. " " .. ZombRand(10))
        end

        square:RecalcProperties()
        square:RecalcAllWithNeighbours(true)
        if BanditCompatibility.GetGameVersion() >= 42 then
            square:setSquareChanged()
        end

        local newWall = IsoThumpable.new(getCell(), square, oldSpriteName, false, {})
        local newSprite = newWall:getSprite()
        local newProps = newSprite:getProperties()
        newProps:Set(newCanPath)
        newWall:setHealth(health)
        square:AddTileObject(newWall)
    end
end

-- DISABLED - 42.12 BROKE IT
-- ENABLED AGAIN 42.12.1 FIXED IT
-- Events.LoadGridsquare.Remove(processSquare)
-- Events.LoadGridsquare.Add(processSquare)