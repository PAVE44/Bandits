
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

-- janitor: culls ex-bandit bodies that lost their brain entry (e.g. through an id
-- collision before the banditize reroll fix); only this mod dresses zombies in the
-- Naked* outfits, so a live Naked* zombie without a brain entry is always an orphan
local function cullOrphans()
    if isClient() then return end

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        if zombie:getHealth() > 0 then
            local outfit = zombie:getOutfitName()
            if outfit and string.sub(outfit, 1, 5) == "Naked" then
                local id = BanditUtils.GetZombieID(zombie)
                local gmd = GetBanditClusterData(id)
                if not (gmd and gmd[id]) then
                    print ("[BANDITS] removed orphaned bandit body, id " .. id)
                    zombie:removeFromWorld()
                    zombie:removeFromSquare()
                end
            end
        end
    end
end

Events.EveryTenMinutes.Add(cullOrphans)

local function onGameStart()
    if isClient() then return end

    for c = 0, BanditClusterCount - 1 do
        local gmd = BanditClusters[c]
        if gmd then
            -- snapshot first: Spawner.Restore inserts new brains into the clusters, and
            -- mutating a table while pairs() iterates it is undefined behavior
            local pending = {}
            for id, data in pairs(gmd) do
                if data and data.bornCoords and data.needRestore then
                    pending[id] = data
                end
            end
            for id, data in pairs(pending) do
                data.needRestore = nil
                if data.recycle then
                    -- ghost entry: a copy already respawned elsewhere while its own body
                    -- was removed on save, so there is nothing left to restore or cull
                    gmd[id] = nil
                elseif BanditServer.Spawner.Restore(nil, data) then
                    gmd[id] = nil
                end
                -- on a failed restore (position not in a loaded cell) the entry is kept
                -- without needRestore; the remote manager respawns it once its position
                -- enters a loaded cell, and clearing the flag prevents this entry from
                -- being restored again (duplicated) on every subsequent game start
            end
        end
    end
end

Events.OnGameStart.Add(onGameStart)
