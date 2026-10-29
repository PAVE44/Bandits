
local function onSave()
    if isClient() then return end

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    local zombieListSize = zombieList:size()
    for i = zombieListSize - 1, 0, -1 do
        local zombie = zombieList:get(i)
        local id = BanditUtils.GetZombieID(zombie)
        local gmd = GetBanditClusterData(id)
        if gmd and gmd[id] then
            gmd[id].bornCoords = {
                x = zombie:getX(),
                y = zombie:getY(),
                z = zombie:getZ(),
            }
            gmd[id].needRestore = true

            zombie:removeFromWorld()
            zombie:removeFromSquare()
        end
    end
end

Events.OnSave.Add(onSave)

local function onGameStart()
    if isClient() then return end

    for c = 0, BanditClusterCount - 1 do
        local gmd = BanditClusters[c]
        if gmd then
            local toRemove = {}
            for id, data in pairs(gmd) do
                if data and data.bornCoords and data.needRestore then
                    BanditServer.Spawner.Restore(nil, data)
                    table.insert(toRemove, id)
                end
            end
            for _, id in ipairs(toRemove) do
                gmd[id] = nil
            end
        end
    end
end

Events.OnGameStart.Add(onGameStart)
