Quadtree = {}
Quadtree.__index = Quadtree

function Quadtree:new(level, bounds)
    local o = {
        level = level,
        bounds = bounds,
        objects = {},
        nodes = {}
    }
    setmetatable(o, self)
    return o
end

function Quadtree:clear()
    self.objects = {}
    for i = 1, 4 do
        if self.nodes[i] then
            self.nodes[i]:clear()
        end
    end
    self.nodes = {}
end

function Quadtree:split()
    local subWidth = self.bounds.width / 2
    local subHeight = self.bounds.height / 2
    local x = self.bounds.x
    local y = self.bounds.y

    self.nodes[1] = Quadtree:new(self.level + 1, {x = x + subWidth, y = y, width = subWidth, height = subHeight})
    self.nodes[2] = Quadtree:new(self.level + 1, {x = x, y = y, width = subWidth, height = subHeight})
    self.nodes[3] = Quadtree:new(self.level + 1, {x = x, y = y + subHeight, width = subWidth, height = subHeight})
    self.nodes[4] = Quadtree:new(self.level + 1, {x = x + subWidth, y = y + subHeight, width = subWidth, height = subHeight})
end

function Quadtree:getIndex(zone)
    local verticalMidpoint = self.bounds.x + (self.bounds.width / 2)
    local horizontalMidpoint = self.bounds.y + (self.bounds.height / 2)

    local topQuadrant = (zone.y < horizontalMidpoint and zone.y + zone.height < horizontalMidpoint)
    local bottomQuadrant = (zone.y > horizontalMidpoint)

    if zone.x < verticalMidpoint and zone.x + zone.width < verticalMidpoint then
        if topQuadrant then
            return 2
        elseif bottomQuadrant then
            return 3
        end
    elseif zone.x > verticalMidpoint then
        if topQuadrant then
            return 1
        elseif bottomQuadrant then
            return 4
        end
    end

    return -1
end

function Quadtree:insert(zone)
    if #self.nodes > 0 then
        local index = self:getIndex(zone)
        if index ~= -1 then
            self.nodes[index]:insert(zone)
            return
        end
    end

    table.insert(self.objects, zone)

    if #self.objects > 10 and self.level < 5 then
        if #self.nodes == 0 then
            self:split()
        end

        local i = 1
        while i <= #self.objects do
            local index = self:getIndex(self.objects[i])
            if index ~= -1 then
                local zone = table.remove(self.objects, i)
                self.nodes[index]:insert(zone)
            else
                i = i + 1
            end
        end
    end
end

function Quadtree:retrieve(returnObjects, viewport)
    local index = self:getIndex(viewport)
    if index ~= -1 and #self.nodes > 0 then
        self.nodes[index]:retrieve(returnObjects, viewport)
    end

    for _, obj in ipairs(self.objects) do
        table.insert(returnObjects, obj)
    end

    return returnObjects
end