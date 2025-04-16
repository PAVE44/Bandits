--
-- ********************************
-- *** Zombie Bandits           ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BanditMenu = BanditMenu or {}

function BanditMenu.InitProjectile(player)
    -- local modal = BanditCreationMain:new(200, 100, 1520, 880)
    BanditProjectile.Add(player:getX(), player:getY(), player:getZ(), player:getDirectionAngle())
end


function BanditMenu.BanditCreator(player)
    -- local modal = BanditCreationMain:new(200, 100, 1520, 880)
    local modal = BanditClansMain:new(500, 80, 1220, 900)
    modal:initialise()
    modal:addToUIManager()
end

function BanditMenu.MakeProcedure (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 44
    local h = 44

    local lines = {}

    table.insert(lines, "require \"MysteryPlacements\"\n")
    table.insert(lines, "\n")
    table.insert(lines, "function ProcMedicalTent (sx, sy, sz)\n")
    
    for x = 0, w do
        for y = 0, h do
            for z = 0, 4 do
                local square = cell:getGridSquare(sx + x, sy + y, sz + z)
                if square then
                    local objects = square:getObjects()

                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if object then

                            local objectType = object:getType()
                            local spriteName = object:getSprite():getName()
                            local spriteProps = object:getSprite():getProperties()

                            local isSolidFloor = spriteProps:Is(IsoFlagType.solidfloor)
                            local isAttachedFloor = spriteProps:Is(IsoFlagType.attachedFloor)
                            local isExterior = spriteProps:Is(IsoFlagType.exterior)
                            local isCanBeRemoved = spriteProps:Is(IsoFlagType.canBeRemoved)
                            
                            if spriteName then
                                --[[if isSolidFloor and isExterior and not isAttachedFloor then
                                    --nature floor - skip it
                                    print ("nature floor")
                                elseif objectType == IsoObjectType.tree then
                                    print ("tree")

                                elseif isCanBeRemoved == true then
                                    print ("grass")

                                elseif isSolidFloor or isAttachedFloor then
                                    --floors
                                    table.insert(lines, "\tBanditBasePlacements.IsoObject (\"" .. spriteName .. "\", sx + " .. tostring(x) .. ", sy + " .. tostring(y) .. ", sz + " .. tostring(z) .. ")\n")
                                
                                elseif false and objectType == IsoObjectType.wall then
                                    -- walls 
                                    table.insert(lines, "\tBanditBasePlacements.IsoThumpable (\"" .. spriteName .. "\", sx + " .. tostring(x) .. ", sy + " .. tostring(y) .. ", sz + " .. tostring(z) .. ")\n")
                                ]]
                                if instanceof(object, 'IsoDoor') then
                                    -- door
                                    table.insert(lines, "\tBanditBasePlacements.IsoDoor (\"" .. spriteName .. "\", sx + " .. tostring(x) .. ", sy + " .. tostring(y) .. ", sz + " .. tostring(z) .. ")\n")

                                elseif instanceof(object, 'IsoWindow') then
                                    -- window
                                    table.insert(lines, "\tBanditBasePlacements.IsoWindow (\"" .. spriteName .. "\", sx + " .. tostring(x) .. ", sy + " .. tostring(y) .. ", sz + " .. tostring(z) .. ")\n")

                                else
                                    -- special objects?
                                    table.insert(lines, "\tBanditBasePlacements.IsoObject (\"" .. spriteName .. "\", sx + " .. tostring(x) .. ", sy + " .. tostring(y) .. ", sz + " .. tostring(z) .. ")\n")
                                    
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local fileWriter = getFileWriter("test6.txt", true, true)
    table.insert(lines, "end\n\n")

    local output = ""
    for k, v in pairs(lines) do
        output = output .. v
    end
    print (output)
    fileWriter:write(output)
    fileWriter:close()
                            
end

function BanditMenu.SpawnWave (player, wid)
    local args = {}
    args.wid = wid
    args.dist = 10
    sendClientCommand(player, 'Spawner', 'Wave', args)
end

function BanditMenu.SpawnClan(player, square, cid)
    local args = {}
    args.cid = cid
    args.x = square:getX()
    args.y = square:getY()
    args.z = square:getZ()
    sendClientCommand(player, 'Spawner', 'Type', args)
end

function BanditMenu.SpawnDefenders (player, square)
    BanditScheduler.SpawnDefenders(player, 1, 15)
end

function BanditMenu.RaiseDefences (player, square)
    BanditScheduler.RaiseDefences(square:getX(), square:getY())
end

function BanditMenu.ClearSpace (player, square)
    BanditBaseGroupPlacements.ClearSpace (player:getX(), player:getY(), player:getZ(), 50, 50)
end

function BanditMenu.BroadcastTV (player, square)
    BanditScheduler.BroadcastTV(square:getX(), square:getY())
end

function BanditMenu.TestAction (player, square, zombie)

    local task = {action="Time", anim="DanceHipHop3", time=400}
    Bandit.AddTask(zombie, task)
end

function BanditMenu.Zombify (player, zombie)
    local task = {action="Zombify", anim="Faint", time=400}
    Bandit.AddTask(zombie, task)
end

function BanditMenu.SpawnBase (player, square, sceneNo)
    BanditScheduler.SpawnBase(player, sceneNo)
end

function BanditMenu.CheckFloor (player, square)
    local canPlace = BanditBaseGroupPlacements.CheckSpace(square:getX(), square:getY(), 32, 32)
    print ("CANPLACE: " .. tostring(canPlace))
end

function BanditMenu.ShowBrain (player, square, zombie)
    local gmd = GetBanditModData()

    local bcnt = 0
    for k, v in pairs(gmd.Queue) do
        bcnt = bcnt + 1
    end

    -- add breakpoint below to see data
    local brain = BanditBrain.Get(zombie)
    local moddata = zombie:getModData()
    local id = BanditUtils.GetCharacterID(zombie)
    local isUseless = zombie:isUseless()
    local isBandit = zombie:getVariableBoolean("Bandit")
    local walktype = zombie:getVariableString("zombieWalkType")
    local walktype2 = zombie:getVariableString("BanditWalkType")
    local isBanditTarget = zombie:getVariableString("BanditTarget")
    local primary = zombie:getVariableString("BanditPrimary")
    local primaryType = zombie:getVariableString("BanditPrimaryType")
    local secondary = zombie:getVariableString("BanditSecondary")
    local outfit = zombie:getOutfitName()
    local ans = zombie:getActionStateName()
    local under = zombie:isUnderVehicle()
    local veh = zombie:getVehicle()
    local health = zombie:getHealth()
    local zx = zombie:getX()
    local zy = zombie:getY()
    local hv = zombie:getHumanVisual()
    local bv = hv:getBodyVisuals()
    local moddata = zombie:getModData()
    local target = zombie:getTarget()
    local animator = zombie:getAdvancedAnimator()
    local inventory = zombie:getInventory()
    -- local astate = zombie:getAnimationDebug()
    local baseData = BanditPlayerBase.data

end

function BanditMenu.BanditFlush(player)
    local args = {a=1}
    sendClientCommand(player, 'Commands', 'BanditFlush', args)
end

function BanditMenu.ResetGenerator (player, generator)
    generator:setFuel(20)
    generator:setCondition(50)
end

function BanditMenu.RegenerateBase (player)
    BanditPlayerBase.Regenerate(player)
end

function BanditMenu.SwitchProgram(player, bandit, program)
    local brain = BanditBrain.Get(bandit)
    if brain then
        local pid = BanditUtils.GetCharacterID(player)

        brain.master = pid
        brain.program = {}
        brain.program.name = program
        brain.program.stage = "Prepare"
        BanditBrain.Update(bandit, brain)

        local syncData = {}
        syncData.id = brain.id
        syncData.master = brain.master
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
    end
end

function BanditMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local world = getWorld()
    local gamemode = world:getGameMode()
    local player = getSpecificPlayer(playerID)
    print (player:getDirectionAngle())
    local square = BanditCompatibility.GetClickedSquare()
    local generator = square:getGenerator()

    local zombie = square:getZombie()
    if not zombie then
        local squareS = square:getS()
        if squareS then
            zombie = squareS:getZombie()
            if not zombie then
                local squareW = square:getW()
                if squareW then
                    zombie = squareW:getZombie()
                end
            end
        end
    end
    
    -- Player options
    if zombie and zombie:getVariableBoolean("Bandit") then
        local brain = BanditBrain.Get(zombie)
        if not (brain.hostile or brain.hostileP) then
            local banditOption = context:addOption(brain.fullname)
            local banditMenu = context:getNew(context)

            if brain.program.name == "Looter" then
                context:addSubMenu(banditOption, banditMenu)
                banditMenu:addOption("Join Me!", player, BanditMenu.SwitchProgram, zombie, "Companion")
            elseif brain.program.name == "Companion" or brain.program.name == "CompanionGuard" then
                context:addSubMenu(banditOption, banditMenu)
                banditMenu:addOption("Leave Me!", player, BanditMenu.SwitchProgram, zombie, "Looter")
            end
        end
    end

    if zombie then
        local x = 0
        local items = zombie:getAttachedItems()
        for i=0, items:size()-1 do
            local item = items:get(i)
            local location = item:getLocation()
            local itm = item:getItem()
        end

    end

    -- Admin spawn options
    if isDebugEnabled() or isAdmin() then
        local spawnOption = context:addOption("Spawn Bandit Wave")
        local spawnMenu = context:getNew(context)
        context:addSubMenu(spawnOption, spawnMenu)
        for i=1, 16 do
            spawnMenu:addOption("Wave " .. tostring(i), player, BanditMenu.SpawnWave, i)
        end

        context:addOption("Remove All Bandits", player, BanditMenu.BanditFlush, square)
    end
    
    BanditCustom.Load()
    local clanData  = BanditCustom.ClanGetAllSorted()
    local clanSpawnOption = context:addOption("Spawn Bandit Clan")
    local clanSpawnMenu = context:getNew(context)
    context:addSubMenu(clanSpawnOption, clanSpawnMenu)
    for cid, clan in pairs(clanData) do
        clanSpawnMenu:addOption("Clan " .. clan.general.name, player, BanditMenu.SpawnClan, square, cid)
    end

    context:addOption("Bandit Creator", player, BanditMenu.BanditCreator)


    -- Debug options
    if isDebugEnabled() then

        local vehicle = square:getVehicleContainer()
        
        if vehicle then
            print ("VEHICLE: X:" .. vehicle:getX() .. " Y:" .. vehicle:getY())
            local partIds = {"TireFrontRight", "TireFrontLeft", "TireRearLeft", "TireRearRight"}
            for i=1, #partIds do
                local vehiclePart = vehicle:getPartById(partIds[i])
                --  ("PART: " .. partIds[i] .. " X:" .. vehiclePart:getX() .. " Y:" .. vehiclePart:getY())
                local vector = vehicle:getAreaCenter(partIds[i])
                print ("PARTV: " .. partIds[i] .. " X:" .. vector:getX() .. " Y:" .. vector:getY())
            end
        end

        context:addOption("Init Projectile", player, BanditMenu.InitProjectile)

        print (BanditUtils.GetCharacterID(player))
        print (player:getHoursSurvived() / 24)
        context:addOption("[DGB] Make Prcedure", player, BanditMenu.MakeProcedure, square)
        context:addOption("[DGB] Place Plane", player, BanditMenu.PlacePlane, square)

        if zombie then
            print ("this is zombie index: " .. BanditUtils.GetCharacterID(zombie))
            print ("this zombie dir is: " .. zombie:getDirectionAngle())
            context:addOption("[DGB] Show Brain", player, BanditMenu.ShowBrain, square, zombie)
            context:addOption("[DGB] Test action", player, BanditMenu.TestAction, square, zombie)
            context:addOption("[DGB] Zombify", player, BanditMenu.Zombify, zombie)

          
        end

        local zone = square:getZone()
        if zone then
            local zoneType = zone:getType()
            print ("ZONE TYPE:" .. zoneType)
        end
        -- context:addOption("[DGB] Bandit UI", player, ShowCustomizationUI)

        -- context:addOption("[DGB] Bandit Diagnostics", player, BanditMenu.RemoveAllBandits)
        -- context:addOption("[DGB] Clear Space", player, BanditMenu.ClearSpace, square)
        -- context:addOption("[DGB] Regenerate base", player, BanditMenu.RegenerateBase)
        -- context:addOption("[DGB] Raise Defences", player, BanditMenu.RaiseDefences, square)
        -- context:addOption("[DGB] Emergency TC Broadcast", player, BanditMenu.BroadcastTV, square)
        
        -- if generator then
        --    context:addOption("[DGB] Reset generator", player, BanditMenu.ResetGenerator, generator)
        -- end

    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BanditMenu.WorldContextMenuPre)
