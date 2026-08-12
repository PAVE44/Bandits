BanditPermanent = BanditPermanent or {}

-- if player travels to different cell, bandits get unloaded
-- this logic restores bandits marked as permanent in their original location
-- should the player decide to come back to the cell where they were born.

BanditPermanent.Check = function()
    if true then return end

    local gmd = GetBanditModData()
    if not gmd.Queue then return end

    local cache = BanditZombie.CacheLightB
    if not cache then return end

    local player = getSpecificPlayer(0)
    local cell = getCell()
    for id, gmdBrain in pairs(gmd.Queue) do
        if gmdBrain.permanent and not gmdBrain.inVehicle then
            if not cache[id] then
                local square = cell:getGridSquare(gmdBrain.bornCoords.x, gmdBrain.bornCoords.y, gmdBrain.bornCoords.z)
                if square then
                    sendClientCommand(player, 'Spawner', 'Restore', gmdBrain)
                end
            end
        end
    end
end

