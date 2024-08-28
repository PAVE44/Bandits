require "ISUI/ISPanel"

BanditWorld = ISPanel:derive("BanditWorld")

BanditWorldData = BanditWorldData or {
    Buildings = {}
}

function BanditWorld:mergeZones()
    local regionMap = {}
    local regionSize = 300

    for _, zone in ipairs(self.zoneData) do
        local regionX = math.floor(zone.x / regionSize)
        local regionY = math.floor(zone.y / regionSize)
        local key = regionX .. "," .. regionY .. "," .. zone.type

        if not regionMap[key] then
            regionMap[key] = {x = regionX * regionSize, y = regionY * regionSize, z = zone.z, width = regionSize, height = regionSize, type = zone.type}
        else
            local region = regionMap[key]
            region.width = math.max(region.width, (zone.x - region.x) + zone.width)
            region.height = math.max(region.height, (zone.y - region.y) + zone.height)
        end
    end

    -- Convert the region map back to the zone data format
    self.zoneData = {}
    for _, region in pairs(regionMap) do
        table.insert(self.zoneData, region)
    end

    print("Zones after region merging: ", #self.zoneData)
end

function BanditWorld:scanZoneData()
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then
        print("Error: Could not retrieve MetaGrid")
        return
    end

    local gridWidth = metaGrid:getWidth()
    local gridHeight = metaGrid:getHeight()

    -- Define constants for chunk and cell sizes
    local chunkTileSize = 10  -- Assuming 10x10 cells per chunk
    local cellTileSize = 30   -- Assuming each cell is 30x30 tiles

    local chunkTileWidth = chunkTileSize * cellTileSize
    local chunkTileHeight = chunkTileSize * cellTileSize

    for cellX = 0, gridWidth - 1 do
        for cellY = 0, gridHeight - 1 do
            local metaCell = metaGrid:getCellData(cellX, cellY)
            if not metaCell then
                break
            end
            
            for chunkX = 0, cellTileSize - 1 do
                for chunkY = 0, cellTileSize - 1 do
                    local chunk = metaCell:getChunk(chunkX, chunkY)
                    -- Retrieve zones in the chunk
                    for i = 0, chunk:numZones() - 1 do
                        local zone = chunk:getZone(i)
                        if zone then
                            table.insert(self.zoneData, {
                                x = zone:getX(),
                                y = zone:getY(),
                                z = zone:getZ(),
                                width = zone:getWidth(),
                                height = zone:getHeight(),
                                type = zone:getType(),
                                hasCons = zone:haveCons(),
                            })
                        end
                    end
                end
            end
        end
    end

    if #self.zoneData > 0 then
        print("Total zones found: ", #self.zoneData)
        self:mergeZones()
    else
        print("No zones found in the entire map.")
    end
end

-- optimized for just gathering buildings
function BanditWorld:scanBuildingData()
    local metaGrid = getWorld():getMetaGrid()
    local gridWidth = metaGrid:getWidth()
    local gridHeight = metaGrid:getHeight()

    -- Define constants for chunk and cell sizes
    local chunkTileSize = 10  -- Assuming 10x10 cells per chunk
    local cellTileSize = 30   -- Assuming each cell is 30x30 tiles

    local chunkTileWidth = chunkTileSize * cellTileSize
    local chunkTileHeight = chunkTileSize * cellTileSize

    for cellX = 0, gridWidth - 1 do
        for cellY = 0, gridHeight - 1 do
            local metaCell = metaGrid:getCellData(cellX, cellY)
            if not metaCell then
                -- Skip this cell if no metaCell is found
                break
            end
            
            for chunkX = 0, cellTileSize - 1 do
                for chunkY = 0, cellTileSize - 1 do
                    local chunk = metaCell:getChunk(chunkX, chunkY)
                    -- if not chunk then
                    --     -- Skip this chunk if no chunk data is found
                    --     break
                    -- end
                    
                    -- Skip chunks with no rooms
                    local numRooms = chunk:getNumRooms()
                    if numRooms == 0 then
                        -- Continue to the next chunk if no rooms are found
                        break
                    end

                    -- Calculate the chunk's starting world coordinates
                    local chunkStartX = cellX * chunkTileWidth
                    local chunkStartY = cellY * chunkTileHeight

                    -- Start with a larger step size and adjust based on findings
                    local stepSize = 10

                    -- Check each potential (x, y) position in the chunk
                    for localX = 0, chunkTileWidth - 1, stepSize do
                        for localY = 0, chunkTileHeight - 1, stepSize do
                            local worldX = chunkStartX + localX
                            local worldY = chunkStartY + localY
                            local building = metaGrid:getBuildingAt(worldX, worldY)
                            if building then
                                -- local buildingID = building:getKeyId()
                                local buildingKey = string.format("%d,%d", building:getX(), building:getY())
                                -- Only process if the building is not already in the cache
                                if not BanditWorldData.Buildings[buildingKey] then
                                    BanditWorldData.Buildings[buildingKey] = building
                                    table.insert(self.buildingData, {
                                        x = building:getX(),
                                        y = building:getY(),
                                        width = building:getW(),
                                        height = building:getH()
                                    })
                                    print(string.format("Found building ID %s at World X=%d, Y=%d, Z=0",
                                        buildingKey, worldX, worldY))
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Count the number of buildings in the cache
    local buildingCount = 0
    for _ in pairs(BanditWorldData.Buildings) do
        buildingCount = buildingCount + 1
    end

    -- Output unique buildings found
    print("Total unique buildings found:", buildingCount)
end

function BanditWorld:getMapSize()
    local metaGrid = getWorld():getMetaGrid()
    local widthInCells = metaGrid:getMinX() * -1 + metaGrid:getMaxX() + 1
    local heightInCells = metaGrid:getMinY() * -1 + metaGrid:getMaxY() + 1
    
    local widthInTiles = widthInCells * 300
    local heightInTiles = heightInCells * 300
    
    print("Map Width (in tiles): " .. widthInTiles)
    print("Map Height (in tiles): " .. heightInTiles)
    
    return widthInTiles, heightInTiles
end

function BanditWorld:renderBuildingsOnPanel()
    for _, building in ipairs(self.buildingData) do
        local x, y, width, height = self:worldToScreen(building.x, building.y, building.width, building.height)
        self:drawRect(x, y, width, height, 0, 0, 1, 0.8)  -- Blue color with 80% opacity
        self:drawRectBorder(x, y, width, height, 1, 1, 1, 1)  -- White border around the building
    end
end

function BanditWorld:renderZonesOnPanel()
    -- Dictionary to group zones by their colors
    local colorGroupedZones = {}
    local consZones = {}

    for _, zone in ipairs(self.zoneData) do
        local color = self:getZoneColor(zone.type)
        local colorKey = color.r .. "," .. color.g .. "," .. color.b .. "," .. color.a

        if zone.hasCons then
            table.insert(consZones, zone)
        else
            if not colorGroupedZones[colorKey] then
                colorGroupedZones[colorKey] = {}
            end
            table.insert(colorGroupedZones[colorKey], zone)
        end
    end

    -- Draw the non-construction zones by color group
    for colorKey, zones in pairs(colorGroupedZones) do
        local colorParts = {string.match(colorKey, "([^,]+),([^,]+),([^,]+),([^,]+)")}
        local r, g, b, a = tonumber(colorParts[1]), tonumber(colorParts[2]), tonumber(colorParts[3]), tonumber(colorParts[4])

        for _, zone in ipairs(zones) do
            local x, y, width, height = self:worldToScreen(zone.x, zone.y, zone.width, zone.height)
            self:drawRect(x, y, width, height, r, g, b, a)
        end
    end

    -- Draw zones with constructions separately
    for _, zone in ipairs(consZones) do
        local x, y, width, height = self:worldToScreen(zone.x, zone.y, zone.width, zone.height)
        self:drawRect(x, y, width, height, 1, 0, 0, 1)  -- Use a distinct color or style, e.g., red
        self:drawRectBorder(x, y, width, height, 1, 1, 1, 1)  -- Draw a white border around these zones
    end
end

function BanditWorld:worldToScreen(x, y, width, height)
    local screenX = x * self.scaleX + self.offx
    local screenY = y * self.scaleY + self.offy
    local screenW = width * self.scaleX
    local screenH = height * self.scaleY
    return screenX, screenY, screenW, screenH
end

function BanditWorld:drawZoneRect(x, y, width, height, zoneType)
    local color = self:getZoneColor(zoneType)
    self:drawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

-- Function to define unique colors for each zone type
function BanditWorld:getZoneColor(zoneType)
    local colors = {
        Forest = {r = 0.0, g = 0.5, b = 0.0, a = 0.7},
        DeepForest = {r = 0.5, g = 0.0, b = 0.0, a = 0.7},
        Nav = {r = 0.0, g = 0.0, b = 0.5, a = 0.7},
        Vegitation = {r = 0.0, g = 0.8, b = 0.2, a = 0.7},
        TownZone = {r = 0.8, g = 0.8, b = 0.0, a = 0.7},
        Ranch = {r = 0.6, g = 0.4, b = 0.2, a = 0.7},
        Farm = {r = 0.5, g = 0.2, b = 0.8, a = 0.7},
        TrailerPark = {r = 0.3, g = 0.3, b = 0.3, a = 0.7},
        ZombiesType = {r = 0.9, g = 0.1, b = 0.1, a = 0.7},
        FarmLand = {r = 0.7, g = 0.7, b = 0.2, a = 0.7},
        LootZone = {r = 0.9, g = 0.4, b = 0.0, a = 0.7},
        ZoneStory = {r = 0.6, g = 0.2, b = 0.8, a = 0.7},
    }
    return colors[zoneType] or {r = 0.5, g = 0.5, b = 0.5, a = 0.7} -- Default color if type is not defined
end

function BanditWorld:drawLegend()
    local startX = 600
    local startY = 10
    local boxWidth = 20
    local boxHeight = 20
    local spacing = 5
    local textOffset = 25
    local currentY = startY

    -- Iterate over the actual zone types in the zoneData
    local displayedTypes = {}
    for _, zone in ipairs(self.zoneData) do
        local zoneType = zone.type
        if not displayedTypes[zoneType] then
            displayedTypes[zoneType] = true
            local color = self:getZoneColor(zoneType)
            self:drawRect(startX, currentY, boxWidth, boxHeight, color.r, color.g, color.b, color.a)
            self:drawText(zoneType, startX + textOffset, currentY + 5, 1, 1, 1, 1, UIFont.Small)
            currentY = currentY + boxHeight + spacing
        end
    end
end

function BanditWorld:render()
    ISPanel.render(self)
    self:renderZonesOnPanel()
    self:renderBuildingsOnPanel()
    self:drawLegend()
end

function BanditWorld:initializeRenderVariables()
    if not self.xPos then self.xPos = 0 end
    if not self.yPos then self.yPos = 0 end
    if not self.zoom then self.zoom = 1 end
    if not self.offx then self.offx = 0 end
    if not self.offy then self.offy = 0 end
    if not self.draww then self.draww = self.width end
    if not self.drawh then self.drawh = self.height end

    -- Get the map size in tiles
    local widthInTiles, heightInTiles = self:getMapSize()

    -- Set the world size in tiles
    self.worldMaxX = widthInTiles
    self.worldMaxY = heightInTiles

    -- Calculate scale factors based on tile coordinates
    self.scaleX = self.draww / widthInTiles
    self.scaleY = self.drawh / heightInTiles
end

function BanditWorld:initialise()
    ISPanel.initialise(self)
    self:initializeRenderVariables()
    self.buildingData = {}
    self.zoneData = {}
    self:scanBuildingData()
    -- self:scanZoneData()
end

function BanditWorld:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o.zoom = 1.0
    o.xPos = 0
    o.yPos = 0
    o.offx = 0
    o.offy = 0

    o.buildingData = {}
    o.zoneData = {}

    o:initialise()
    return o
end

local function onStart()
    local renderer = BanditWorld:new(100, 10, 800, 600)
    -- renderer:addToUIManager()
end

-- Events.OnGameStart.Add(onStart)