--
-- ********************************
-- *** Zombie Bandits           ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BanditMenu = BanditMenu or {}

function BanditMenu.SwitchProgram (player, zombie, program)
    Bandit.SetProgram(zombie, program, {})
    Bandit.SetMaster(zombie, BanditUtils.GetCharacterID(player))
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
    -- zombie:setBumpType("trippingFromSprint")
    -- zombie:setBumpType("trippingFromSprint")

    local task = {action="Sleep", anim="Sleep", time=400}
    Bandit.AddTask(zombie, task)
end

function BanditMenu.Zombify (player, zombie)
    local task = {action="Zombify", anim="Faint", time=400}
    Bandit.AddTask(zombie, task)
end

function BanditMenu.SetHumanVisuals (player, zombie)
    local zombieVisuals = zombie:getHumanVisual()
    if zombieVisuals then
        local r = 1 + BanditUtils.GetCharacterID(zombie) % 5 -- deterministc for all clients 
        if zombie:isFemale() then
            zombieVisuals:setSkinTextureName("FemaleBody0" .. tostring(r))
        else
            zombieVisuals:setSkinTextureName("MaleBody0" .. tostring(r))
        end
        
        zombieVisuals:randomDirt()
        zombieVisuals:removeBlood()
        zombie:resetModel()
    end
    local itemVisuals = zombie:getItemVisuals()
    if itemVisuals then
        local mask = itemVisuals:findMask()
        local hat = itemVisuals:findHat()
    end
end

function BanditMenu.VehicleTest (player, square)
    -- vehicle:tryStartEngine(true)
    -- vehicle:engineDoStartingSuccess()
    -- vehicle:engineDoRunning()
    -- vehicle:setRegulator(true)
    -- vehicle:setRegulatorSpeed(10)

    --[[local vx = zombie:getForwardDirection():getX()
    local vy = zombie:getForwardDirection():getY()
    local forwardVector = Vector3f.new(vx, vy, 0)
    zombie:enterVehicle(vehicle, 0, forwardVector)]]

    --[[
    local square = getCell():getGridSquare(player:getX(), player:getY(), player:getZ())
    local obj = IsoObject.new(square, "Base.Generator", "")

    -- vehicle:ApplyImpulse(obj, 1000)

    local vx = player:getForwardDirection():getX() + 10
    local vy = player:getForwardDirection():getY() + 10
    local forwardVector = Vector2.new(vx, vy)

    local is = IsoObject
    local carController = vehicle:getController() -- .new(vehicle)
    local ef = type(carController)
    local mt = getmetatable(carController)
    local raw = KahluaUtil.rawTostring2(carController)
    print (raw)
    local className = "zombie.core.physics.CarController@4680b27"
    local fn = getNumClassFunctions(className)
    for i=0, fn do
        local cf = getClassFunction(className, i);
        print (cf)
    end

    --carController:accelerator(true)
    --local t = carController:getClientControls()
    ]]

end

function BanditMenu.VehicleMove(player, vehicle)

    print ("VEH: X:" .. vehicle:getLimpulsex() .. " Y:" .. vehicle:getLimpulsey())
    local vx = player:getX()
    local vy = player:getY()
    local posVector = Vector3f.new(vx, vy, 0)

    local vx = player:getForwardDirection():getX() + 10
    local vy = player:getForwardDirection():getY() + 10
    local forwardVector = Vector3f.new(vx, vy, 0)

    vehicle:addImpulse(forwardVector, posVector)
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

    -- add breakpoint below to see data
    local brain = BanditBrain.Get(zombie)
    local daysPassed = BanditScheduler.DaysSinceApo()
    local isUseless = zombie:isUseless()
    local isBandit = zombie:getVariableBoolean("Bandit")
    local walktype = zombie:getVariableString("zombieWalkType")
    local walktype2 = zombie:getVariableString("BanditWalkType")
    local ans = zombie:getActionStateName()
    local under = zombie:isUnderVehicle()
    local veh = zombie:getVehicle()
    local zx = zombie:getX()
    local zy = zombie:getY()
    local target = zombie:getTarget()
    local animator = zombie:getAdvancedAnimator()
    -- local astate = zombie:getAnimationDebug()
    local waveData = BanditScheduler.GetWaveDataForDay(daysPassed)
    
end

function BanditMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local square = clickedSquare
    local player = getSpecificPlayer(playerID)

    local zombie = square:getZombie()
    
    --[[
    if zombie and zombie:getVariableBoolean("Bandit") and not Bandit.IsHostile(zombie) then
        local brain = BanditBrain.Get(zombie)
        local banditOption = context:addOption(brain.fullname)
        local banditMenu = context:getNew(context)
        context:addSubMenu(banditOption, banditMenu)

        banditMenu:addOption("Stay Here!", player, BanditMenu.SwitchProgram, zombie, "CompanionGuard")
        banditMenu:addOption("Follow Me!", player, BanditMenu.SwitchProgram, zombie, "Companion")

    end
    ]]

    if isDebugEnabled() or isAdmin() then
        print (BanditUtils.GetCharacterID(player))
        print (player:getHoursSurvived() / 24)
        print ("SPAWN BOOST: " .. BanditScheduler.GetDensityScore(player, 120) .. "%")

        local spawnOption = context:addOption("[DGB] Spawn Group Here")
        local spawnMenu = context:getNew(context)
        context:addSubMenu(spawnOption, spawnMenu)
        for i=1, 16 do
            spawnMenu:addOption("Wave " .. tostring(i), player, BanditMenu.SpawnGroup, i)
        end

        local spawnOptionFar = context:addOption("[DGB] Spawn Group Far")
        local spawnMenuFar = context:getNew(context)
        context:addSubMenu(spawnOptionFar, spawnMenuFar)
        for i=1, 16 do
            spawnMenuFar:addOption("Wave " .. tostring(i), player, BanditMenu.SpawnGroupFar, i)
        end
    
        if zombie then
            print ("this is zombie index: " .. BanditUtils.GetCharacterID(zombie))
            print ("this zombie dir is: " .. zombie:getDirectionAngle())
            context:addOption("[DGB] Show Brain", player, BanditMenu.ShowBrain, square, zombie)
            context:addOption("[DGB] Test action", player, BanditMenu.TestAction, square, zombie)
            context:addOption("[DGB] Set Human Visuals", player, BanditMenu.SetHumanVisuals, zombie)
            context:addOption("[DGB] Zombify", player, BanditMenu.Zombify, zombie)

        end

        local spawnBaseOption = context:addOption("[DGB] Spawn Base Far")
        local spawnBaseMenu = context:getNew(context)
        context:addSubMenu(spawnBaseOption, spawnBaseMenu)
        for i=1, 2 do
            spawnBaseMenu:addOption("Base " .. tostring(i), player, BanditMenu.SpawnBase, square, i)
        end

        context:addOption("[DGB] Spawn Defenders", player, BanditMenu.SpawnDefenders, square)
        context:addOption("[DGB] Spawn Event: Baseball Match", player, BanditMenu.BaseballMatch, square)
        
        context:addOption("[DGB] Clear Space", player, BanditMenu.ClearSpace, square)
        context:addOption("[DGB] Raise Defences", player, BanditMenu.RaiseDefences, square)
        context:addOption("[DGB] Emergency TC Broadcast", player, BanditMenu.BroadcastTV, square)
        -- context:addOption("[DGB] Give me wheels", player, BanditMenu.VehicleTest, square)
        
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BanditMenu.WorldContextMenuPre)
