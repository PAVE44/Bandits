local processSquare = function(square)
    local wallNS = square:getWall(true) or square:getHoppableThumpable(true)
    local wallWE = square:getWall(false) or square:getHoppableThumpable(false)

    local oldWall
    local newCanPath
    local health

    if wallNS or wallWE then
        if wallNS and wallNS:isTallHoppable() then
            -- local test2 = instanceof(wallNS, "IsoThumpable")
            -- local test3 = wallNS:getSprite():getProperties():Is(IsoFlagType.canPathN)
            -- if (not instanceof(wallNS, "IsoThumpable") or not wallNS:getSprite():getProperties():Is(IsoFlagType.canPathN)) then
                oldWall = wallNS
                newCanPath = IsoFlagType.canPathN
                if instanceof(wallNS, "IsoThumpable") then
                    health = wallNS:getHealth()
                end
            -- end
        elseif wallWE and wallWE:isTallHoppable() then
            -- local test2 = instanceof(wallWE, "IsoThumpable")
            -- local test3 = wallWE:getSprite():getProperties():Is(IsoFlagType.canPathN)
            -- if (not instanceof(wallWE, "IsoThumpable") or not wallWE:getSprite():getProperties():Is(IsoFlagType.canPathW))  then
                oldWall = wallWE
                newCanPath = IsoFlagType.canPathW
                if instanceof(wallWE, "IsoThumpable") then
                    health = wallWE:getHealth()
                end
            -- end
        end
    end

    if oldWall then
        local oldSpriteName = oldWall:getSprite():getName()

        if isClient() then
            sledgeDestroy(oldWall)
        else
            square:transmitRemoveItemFromSquare(oldWall)
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
        if health then
            newWall:setHealth(health)
        end
        square:AddTileObject(newWall)
    end
end

Events.LoadGridsquare.Remove(processSquare)
Events.LoadGridsquare.Add(processSquare)