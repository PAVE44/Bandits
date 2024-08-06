--
-- ********************************
-- *** Zombie Bandits           ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BanditMenu = BanditMenu or {}

function BanditMenu.SpawnGroup (player, waveId)

    local waveData = BanditConfig.GetWaveDataAll()
    local wave = waveData[waveId]
    wave.spawnDistance = 5
    BanditScheduler.SpawnWave(player, wave)

end

function BanditMenu.SpawnGroupFar (player, waveId)

    local waveData = BanditConfig.GetWaveDataAll()
    local wave = waveData[waveId]
    wave.spawnDistance = 60
    BanditScheduler.SpawnWave(player, wave)

end

function BanditMenu.SpawnDefenders (player, square)
    BanditScheduler.SpawnDefenders(player, 1, 6)
end

function BanditMenu.RaiseDefences (player, square)
    BanditScheduler.RaiseDefences(square:getX(), square:getY())
end

function BanditMenu.SpawnCivilian (player, square)
    BanditScheduler.SpawnCivilian(player)
end

function BanditMenu.EventDayOne (player, square)
    BanditScheduler.DayOne(player)
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

function BanditMenu.VehicleTest (player, vehicle)
    -- vehicle:tryStartEngine(true)
    -- vehicle:engineDoStartingSuccess()
    -- vehicle:engineDoRunning()
    -- vehicle:setRegulator(true)
    -- vehicle:setRegulatorSpeed(10)

    --[[local vx = zombie:getForwardDirection():getX()
    local vy = zombie:getForwardDirection():getY()
    local forwardVector = Vector3f.new(vx, vy, 0)
    zombie:enterVehicle(vehicle, 0, forwardVector)]]

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
    local walktype = zombie:getVariableBoolean("zombieWalkType")
    local zx = zombie:getX()
    local zy = zombie:getY()
    local waveData = BanditConfig.GetWaveDataForDay(daysPassed)
end

function BanditMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local square = clickedSquare
    local player = getSpecificPlayer(playerID)
    -- print ("INVISIBILITY:" .. tostring(player:isInvisible()))
   
    if isDebugEnabled() or isAdmin() then
        print (BanditUtils.GetCharacterID(player))
        print (player:getHoursSurvived() / 24)

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

        local zombie = square:getZombie()
        
        if zombie then
            print ("this is zombie index: " .. BanditUtils.GetCharacterID(zombie))
            print ("this zombie outfit id: " .. zombie:getPersistentOutfitID())
            context:addOption("[DGB] Show Brain", player, BanditMenu.ShowBrain, square, zombie)
            context:addOption("[DGB] Test action", player, BanditMenu.TestAction, square, zombie)
            context:addOption("[DGB] Set Human Visuals", player, BanditMenu.SetHumanVisuals, zombie)

        end
        local spawnBaseOption = context:addOption("[DGB] Spawn Base Far")
        local spawnBaseMenu = context:getNew(context)
        context:addSubMenu(spawnBaseOption, spawnBaseMenu)
        for i=1, 10 do
            spawnBaseMenu:addOption("Base " .. tostring(i), player, BanditMenu.SpawnBase, square, i)
        end

        context:addOption("[DGB] Spawn Defenders", player, BanditMenu.SpawnDefenders, square)
        context:addOption("[DGB] Spawn Event: Day One", player, BanditMenu.EventDayOne, square)
        context:addOption("[DGB] Raise Defences", player, BanditMenu.RaiseDefences, square)
        context:addOption("[DGB] Emergency TC Broadcast", player, BanditMenu.BroadcastTV, square)
        
        local building = square:getBuilding()
        if building then
            local room = building:getRandomRoom()
            if room then
                local roomDef = room:getRoomDef()
                if roomDef then
                    print (roomDef:getName())
                end
            end
        end

        local zones = getWorld():getMetaGrid():getZonesAt(square:getX(), square:getY(), 0)
        if zones then
            for i = zones:size(), 1, -1 do
                local zone = zones:get(i-1)
                if zone then
                    print (zone:getType())
                end
            end
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BanditMenu.WorldContextMenuPre)
