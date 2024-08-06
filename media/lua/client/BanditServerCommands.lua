ZSClient = {}
ZSClient.Commands = {}

ZSClient.Commands.SyncBrainToClients = function(args)
    local cell = getCell()
  
    -- do not synchronize sender, he apready has the data
    local player = getPlayer()
    local playerId = BanditUtils.GetCharacterID(player)
    if playerId == args.sentById then return end

    -- in multiplayer, zombies not always occupy the same square between clients
    -- so we need to look around
    for dx = -3, 3 do
        for dy = -3, 3 do
            local square = cell:getGridSquare(args.x + dx, args.y + dy, args.z)
            if square then
                local zombie = square:getZombie()
                if zombie then
                    local id = BanditUtils.GetCharacterID(zombie)
                    if id == args.id or true then
                        local brain = BanditBrain.Get(zombie)
                        if brain then
                            for _, task in pairs(args.sync) do
                                table.insert(brain.tasks, task)
                            end
                            BanditBrain.Update(zombie, brain)
                            return true
                        end
                    end
                end
            end
        end
    end
end

local onServerCommand = function(module, command, args)
    if ZSClient[module] and ZSClient[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("client received " .. module .. "." .. command .. " "  .. argStr)
        ZSClient[module][command](args)
    end
end

Events.OnServerCommand.Add(onServerCommand)
