BanditPrograms = BanditPrograms or {}

BanditPrograms.ShouldRetreat = function(bandit)
        
    -- Function to find the escape direction for a bandit based on other characters
    -- in his surroundings
    function getEscapeDir(cx, cy, cz, radius)
        -- Create an array to count enemy characters in radial segments
        local segmentCount = 45
        local segments = {}
        for i = 1, segmentCount do
            segments[i] = 0
        end

        local zombieList = cell:getZombieList()
        for i=0, zombieList:size()-1 do
            local zombie = zombieList:get(i)
            local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
            
            -- Calculate distance between bandit and the other character
            local distance = math.sqrt((zx - cx) ^ 2 + (zy - cy) ^ 2)
            if distance <= radius and cz == zz then
                -- Calculate angle of the point relative to the circle's center
                local angle = math.atan2(zy - cy, zx - cx)
                -- Convert angle from radians to degrees
                local degrees = (math.deg(angle) + 360) % 360
                -- Determine which segment this angle falls into
                local segment = math.floor(degrees / (360 / segmentCount)) + 1
                -- Increment the count for that segment
                segments[segment] = segments[segment] + 1
            end
        end

        -- Find the segment with the fewest points
        local minCnt = math.huge
        local segmentBest = 1
        for i = 1, segmentCount do
            if segments[i] < minCnt then
                minCnt = segments[i]
                segmentBest = i
            end
        end

        -- Calculate the start and end angles of the least populated arc
        local segmentSize = 360 / segmentCount
        local segmentStartAngle = (segmentBest - 1) * segmentSize
        local segmentEndAngle = segmentBest * segmentSize

        return (segmentStartAngle + segmentEndAngle) / 2
    end

    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    
    local angle  = getEscapeDir(center_x, center_y, radius)
    print("Least populated arc: from " .. segmentStartAngle .. "° to " .. segmentEndAngle .. "°")
end