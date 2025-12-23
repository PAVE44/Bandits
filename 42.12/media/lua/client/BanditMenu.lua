--
-- ********************************
-- *** Zombie Bandits           ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BanditMenu = BanditMenu or {}

function BanditMenu.BanditTest (player)
    BanditTest.Check()
end

function BanditMenu.TestAction (player, square, zombie)

    local task = {action="Time", anim="TEST", time=400}
    Bandit.AddTask(zombie, task)
end

function BanditMenu.MakeProcedure (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 7
    local h = 7

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
    local ragdoll = zombie:isRagdoll()
    -- local astate = zombie:getAnimationDebug()
    local baseData = BanditPlayerBase.data

    zombie:resetModelNextFrame()
    zombie:resetModel()

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

function BanditMenu.BanditFlush(player)
    local args = {a=1}
    sendClientCommand(player, 'Commands', 'BanditFlush', args)
end

function BanditMenu.SpawnClan(player, square, cid)
    local args = {}
    args.cid = cid
    args.x = square:getX()
    args.y = square:getY()
    args.z = square:getZ()
    args.program = "Bandit"
    args.size = 6
    args.voice = 101
    sendClientCommand(player, 'Spawner', 'Clan', args)
end

function BanditMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local world = getWorld()
    local player = getSpecificPlayer(playerID)
    local square = BanditCompatibility.GetClickedSquare()

    print ("ROOF: " .. tostring(square:haveRoofFull()))
    print (player:getDirectionAngle())
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

    if zombie then
        print ("zombieid" .. BanditUtils.GetZombieID(zombie))
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

    -- Debug options
    if isDebugEnabled() then

        context:addOption("[DGB] Tests", player, BanditMenu.BanditTest)
        context:addOption("[DGB] Make Procedure", player, BanditMenu.MakeProcedure, square)
        context:addOption("[DGB] Remove All Bandits", player, BanditMenu.BanditFlush, square)

        if zombie then
            context:addOption("[DGB] Show Brain", player, BanditMenu.ShowBrain, square, zombie)
        end
    end

    if isDebugEnabled() or isAdmin() then
        BanditCustom.Load()
        local clanData  = BanditCustom.ClanGetAllSorted()
        local clanSpawnOption = context:addOption("Spawn Bandit Clan")
        local clanSpawnMenu = context:getNew(context)
        context:addSubMenu(clanSpawnOption, clanSpawnMenu)
        for cid, clan in pairs(clanData) do
            clanSpawnMenu:addOption("Clan " .. clan.general.name, player, BanditMenu.SpawnClan, square, cid)
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BanditMenu.WorldContextMenuPre)
