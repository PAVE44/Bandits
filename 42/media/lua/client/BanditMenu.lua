--
-- ********************************
-- *** Zombie Bandits           ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BanditMenu = BanditMenu or {}

function BanditMenu.BanditCreator(player)
    -- local modal = BanditCreationMain:new(200, 100, 1520, 880)
    local modal = BanditClansMain:new(500, 80, 1220, 900)
    modal:initialise()
    modal:addToUIManager()
end

function BanditMenu.TestSpawn(player, square)
    local args = {cid = "c5c7f769-e5e8-44bb-ada6-cdf00ee2c234", 
                  size=1,
                  x=square:getX(),
                  y=square:getY(),
                  z=square:getZ(),
                  program="Bandit"}
    BanditServer.Commands.SpawnCustom(player, args)
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

function BanditMenu.SpawnGroup (player, waveId)
    local waveData = BanditScheduler.GetWaveDataAll()
    local wave = waveData[waveId]
    wave.spawnDistance = 3
    BanditScheduler.SpawnWave(player, wave)
end

function BanditMenu.SpawnGroupFar (player, waveId)
    local waveData = BanditScheduler.GetWaveDataAll()
    local wave = waveData[waveId]
    wave.spawnDistance = 50
    BanditScheduler.SpawnWave(player, wave)
end

function BanditMenu.SpawnDefenders (player, square)
    BanditScheduler.SpawnDefenders(player, 1, 15)
end

function BanditMenu.RaiseDefences (player, square)
    BanditScheduler.RaiseDefences(square:getX(), square:getY())
end

function BanditMenu.SpawnCivilian (player, square)
    BanditScheduler.SpawnCivilian(player)
end

function BanditMenu.BaseballMatch (player, square)
    BanditScheduler.BaseballMatch(player)
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
    local daysPassed = BanditScheduler.DaysSinceApo()
    local isUseless = zombie:isUseless()
    local isBandit = zombie:getVariableBoolean("Bandit")
    local walktype = zombie:getVariableString("zombieWalkType")
    local walktype2 = zombie:getVariableString("BanditWalkType")
    local isBanditTarget = zombie:getVariableString("BanditTarget")
    local walktype2 = zombie:getVariableString("BanditWalkType")
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
    local waveData = BanditScheduler.GetWaveDataForDay(daysPassed)
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
        if not brain.hostile and brain.clan > 0 then
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

    -- Admin spawn options
    if isDebugEnabled() or isAdmin() then
        local spawnOption = context:addOption("Spawn Bandits Here")
        local spawnMenu = context:getNew(context)
        context:addSubMenu(spawnOption, spawnMenu)
        for i=1, 16 do
            spawnMenu:addOption("Wave " .. tostring(i), player, BanditMenu.SpawnGroup, i)
        end

        local spawnOptionFar = context:addOption("Spawn Bandits Far")
        local spawnMenuFar = context:getNew(context)
        context:addSubMenu(spawnOptionFar, spawnMenuFar)
        for i=1, 16 do
            spawnMenuFar:addOption("Wave " .. tostring(i), player, BanditMenu.SpawnGroupFar, i)
        end

        context:addOption("Spawn Bandit Defenders", player, BanditMenu.SpawnDefenders, square)

        local spawnBaseOption = context:addOption("Spawn Bandit Base Far")
        local spawnBaseMenu = context:getNew(context)
        context:addSubMenu(spawnBaseOption, spawnBaseMenu)
        for i=1, 2 do
            spawnBaseMenu:addOption("Base " .. tostring(i), player, BanditMenu.SpawnBase, square, i)
        end

        context:addOption("Remove All Bandits", player, BanditMenu.BanditFlush, square)

        context:addOption("New Spawn Test", player, BanditMenu.TestSpawn, square)
        
    end
    
    -- Debug options
    if isDebugEnabled() then

        context:addOption("Bandit Creator", player, BanditMenu.BanditCreator)

        print (BanditUtils.GetCharacterID(player))
        print (player:getHoursSurvived() / 24)
        print ("SPAWN BOOST: " .. BanditScheduler.GetDensityScore(player, 120) .. "%")
        context:addOption("[DGB] Make Prcedure", player, BanditMenu.MakeProcedure, square)
        context:addOption("[DGB] Place Plane", player, BanditMenu.PlacePlane, square)

        if zombie then
            print ("this is zombie index: " .. BanditUtils.GetCharacterID(zombie))
            print ("this zombie dir is: " .. zombie:getDirectionAngle())
            context:addOption("[DGB] Show Brain", player, BanditMenu.ShowBrain, square, zombie)
            context:addOption("[DGB] Test action", player, BanditMenu.TestAction, square, zombie)
            context:addOption("[DGB] Zombify", player, BanditMenu.Zombify, zombie)

          
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
