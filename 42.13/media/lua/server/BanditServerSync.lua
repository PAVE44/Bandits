BanditServer = BanditServer or {}
BanditServer.Sync = {}

BanditServer.Sync.Health  = function(player, args)
    sendServerCommand('Commands', 'UpdateHealth', args)
    --[[
    local id = args.id
    if id then
        local zombie = BanditServerZombie.Cache[id]
        if zombie then
            local health = zombie:getHealth()
            zombie:setHealth(args.h)
            print ("CLIENT HEALTH CURRENT: " .. health .. " NEW:" .. args.h)
            if args.h <=0 then
                print ("BECOME CORPSE")
                zombie:changeState(ZombieOnGroundState.instance())
                zombie:setAttackedBy(getCell():getFakeZombieForHit())
                zombie:becomeCorpse()
            end

        end
    end
    ]]

    --[[
    local square = getCell():getGridSquare(args.x, args.y, args.z)
    if square then
        local chrs = square:getMovingObjects()
        for i=0, chrs:size()-1 do
            local chr = chrs:get(i)
            local id = BanditUtils.GetCharacterID(chr)
            if id == args.id then
                local health = chr:getHealth()
                print ("HEALTH CURRENT: " .. health .. " NEW:" .. args.h)
                if health > args.h then
                    chr:setHealth(args.h)
                    sendServerCommand('Commands', 'UpdateHealth', args)
                    break
                end
            end
        end
    end
    ]]
end

local onClientCommand = function(module, command, player, args)
    if module == "Sync" and BanditServer[module] and BanditServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        -- print ("received " .. module .. "." .. command .. " "  .. argStr)
        BanditServer[module][command](player, args)
    end
end

Events.OnClientCommand.Add(onClientCommand)