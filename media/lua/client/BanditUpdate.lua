BanditUpdate = BanditUpdate or {}

local function CalcSpottedScore(player, dist)
    if not instanceof(player, "IsoPlayer") then return end

    spottedScore = player:getSquare():getLightLevel(0)

    if player:isRunning() then
        spottedScore = spottedScore + 0.1
    end
    if player:isSprinting() then
        spottedScore = spottedScore + 0.12
    end

    if player:isSneaking() then 
        spottedScore = spottedScore - 0.1
        local objects = player:getSquare():getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            if object then
                local props = object:getProperties()
                if props and props:Is(IsoFlagType.vegitation) and props:Is(IsoFlagType.canBeCut)   then 
                    spottedScore = spottedScore - 0.15
                    break
                end
            end
        end
    end

    if dist <= 8 then 
        local m = -0.075
        local c = 0.65
        spottedScore = spottedScore - m * dist + c
    end
    return spottedScore
end

local function SwitchWeapon(bandit, itemName)

    local tasks = {}
    bandit:clearAttachedItems()

    -- check what is equippped that needs to be deattached
    local old = bandit:getPrimaryHandItem()
    if old then
        local task = {action="Unequip", time=200, itemPrimary=old:getFullType()}
        table.insert(tasks, task)
    end

    -- grab new weapon
    local new = InventoryItemFactory.CreateItem(itemName)
    if new then
        local task = {action="Equip", itemPrimary=itemName}
        table.insert(tasks, task)
    end
    return tasks
end

function BanditUpdate.Banditize(zombie, brain)

    -- load brain
    BanditBrain.Update(zombie, brain)

    -- just in case
    zombie:setNoTeeth(true)

    -- used to determine if zombie is a bandit, can be used by other mods
    zombie:setVariable("Bandit", true)

    -- bandit primary and secondary hand items
    zombie:setVariable("BanditPrimary", "")
    zombie:setVariable("BanditSecondary", "")

    -- bandit walking type defined in animations
    zombie:setWalkType("Walk")
    zombie:setVariable("BanditWalkType", "Walk")

    -- this shit here is important, removes black screen crashes
    -- with this var set, game engine skips testDefense function that
    -- wrongly refers to moodles, which zombie object does not have
    zombie:setVariable("ZombieHitReaction", "Chainsaw")

    -- stfu
    zombie:getEmitter():stopAll()

    zombie:setPrimaryHandItem(nil)
    zombie:setSecondaryHandItem(nil)
    zombie:resetEquippedHandsModels()
    zombie:clearAttachedItems()

    -- makes bandit unstuck after spawns
    zombie:setTurnAlertedValues(-5, 5)

end

function BanditUpdate.Visuals(bandit)
    local banditVisuals = bandit:getHumanVisual()
    if banditVisuals then
        local skin = banditVisuals:getSkinTexture()
        if skin then
            if string.sub(skin, 1, 10) ~= "FemaleBody" and string.sub(skin, 1, 8) ~= "MaleBody" then
                local id = BanditUtils.GetCharacterID(bandit)
                local r = 1 + math.abs(id) % 5 -- deterministc for all clients
                if bandit:isFemale() then
                    banditVisuals:setSkinTextureName("FemaleBody0" .. tostring(r))
                    -- banditVisuals:setSkinTextureName("FemaleBody03")
                else
                    banditVisuals:setSkinTextureName("MaleBody0" .. tostring(r))
                end
                banditVisuals:randomDirt()
                banditVisuals:removeBlood()
                bandit:resetModel()
                bandit:setVariable("BanditSkin", true)
            end
        end
    end
end

function BanditUpdate.Torch(bandit)
    if SandboxVars.Bandits.General_CarryTorches then
        local zx = bandit:getX()
        local zy = bandit:getY()
        local zz = bandit:getZ()
        local ls = bandit:getVariableBoolean("BanditTorch")
        if ls then
            if bandit:isProne() then
                local lightSource = IsoLightSource.new(zx, zy, zz, 0.8, 0.8, 0.8, 2, 20)
                getCell():addLamppost(lightSource)
            else
                local theta = bandit:getDirectionAngle() * math.pi / 180
                for i = 0, 15 do
                    local lx = zx + math.floor(i * math.cos(theta) + 0.5)
                    local ly = zy + math.floor(i * math.sin(theta) + 0.5)
                    local lightSource = IsoLightSource.new(lx, ly, zz, 0.8-i/20, 0.8-i/20, 0.8-i/20, i/2, 20)
                    getCell():addLamppost(lightSource)
                    -- print (x2 .. ", " .. y2)
                end
            end
        end
    end
end

function BanditUpdate.Chainsaw(bandit)
    if bandit:isPrimaryEquipped("AuthenticZClothing.Chainsaw") then
        local emitter = bandit:getEmitter()
        if not emitter:isPlaying("ChainsawIdle") then
            bandit:playSound("ChainsawIdle")
        end
    end
end

function BanditUpdate.Fire(bandit)
    if bandit:isOnFire() then
        local sound = "MaleBeingEatenDeath"
        if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
        local task = {action="Die", lock=true, anim="Die", sound=sound, time=150}
        Bandit.ClearTasks(bandit)
        Bandit.AddTask(bandit, task)
    end
end

function BanditUpdate.Speech(bandit)
    local brain = BanditBrain.Get(bandit)
    if brain.speech and brain.speech > 0 then
        brain.speech = brain.speech - 0.01
        if brain.speech < 0 then brain.speech = 0 end
        BanditBrain.Update(bandit, brain)
    end
end

function BanditUpdate.ActionState(bandit)
    local asn = bandit:getActionStateName()
    local continue = true
    -- print(asn)
    if asn == "onground" or asn == "getup" or asn =="staggerback" then
        
        -- bandits car passangers are in ongroundstate
        local vehicle = bandit:getVehicle()
        if not vehicle then
            Bandit.ClearTasks(bandit)
            continue = false
        end
        
    elseif asn == "turnalerted"  then
        -- bandits dont bite pls
        bandit:changeState(ZombieIdleState.instance())
        bandit:clearAggroList()
        bandit:setTarget(nil)
    elseif asn == "pathfind" then

    elseif asn == "thump" then
        -- bandit:changeState(ZombieIdleState.instance())
        --[[
        if not SandboxVars.Bandits.General_DestroyThumpable or program.name == "Defend" then
            bandit:changeState(ZombieIdleState.instance())
        end
        ]]
    elseif asn == "lunge" then
        bandit:setUseless(true)
        bandit:clearAggroList()
        bandit:setTarget(nil)
    elseif asn == "walktoward-network" then
        -- bandit:changeState(ZombieIdleState.instance())
        --[[Bandit.ClearTasks(bandit)
        local task = {action="Time", anim="ReloadPistol", sound="M9InsertAmmo", time=90}
        table.insert(tasks, task)
        bandit:changeState(ZombieIdleState.instance())
        return--]]
    else
        local world = getWorld()
        local gamemode = world:getGameMode()

        if gamemode == "Multiplayer" and not Bandit.IsForceStationary(bandit) then
            bandit:setUseless(false)
        else
            bandit:setUseless(true)
        end
    end
    return continue
end

function BanditUpdate.Endurance(bandit)
    local tasks = {}
    if SandboxVars.Bandits.General_LimitedEndurance then
        local brain = BanditBrain.Get(bandit)
        if brain.endurance == 0 then
            if not Bandit.HasActionTask(bandit) then
                Bandit.UpdateEndurance(bandit, 1)
                for i=0, 4 do
                    local task = {action="Time", anim="Exhausted", time=200, lock=true}
                    table.insert(tasks, task)
                end
            end
        end
    end
    return tasks
end

function BanditUpdate.Health(bandit)
    local tasks = {}
    if SandboxVars.Bandits.General_BleedOut then
        local healing = false
        if bandit:getHealth() < 1 then
            local zx = bandit:getX()
            local zy = bandit:getY()
            local zz = bandit:getZ()

            -- purely visual so random allowed
            if ZombRand(12) == 1 then
                local bx = zx - 0.5 + ZombRandFloat(0.1, 0.9)
                local by = zy - 0.5 + ZombRandFloat(0.1, 0.9)
                bandit:getChunk():addBloodSplat(bx, by, 0, ZombRand(20))
            end

            if BanditUtils.IsController(bandit) then
                bandit:setHealth(bandit:getHealth() - 0.00025)
            end
            
            if not Bandit.HasActionTask(bandit) then

                local id = BanditUtils.GetCharacterID(bandit)

                if bandit:getHealth() < 0.4 and id % 3 == 1 then
                    Bandit.ClearTasks(bandit)
                    healing = true
                end

                if bandit:getHealth() < 0.3 and id % 2 == 1 then
                    Bandit.ClearTasks(bandit)
                    healing = true
                end
            end
        end

        if healing then
            local task = {action="Bandage", time=800}
            table.insert(tasks, task)
        end
    end
    return tasks
end

function BanditUpdate.Collisions(bandit)
    local tasks = {}
    local cell = getCell()
    local weapons = Bandit.GetWeapons(bandit)

    local asn = bandit:getActionStateName()
    local sr = bandit:getSquare():getSheetRope()
    if not Bandit.HasActionTask(bandit) and sr and asn ~= "climbrope" then
        bandit:changeState(ClimbSheetRopeState.instance())
        bandit:setVariable("ClimbUp", true)
    else
        bandit:setVariable("ClimbUp", false)
    end

    if not Bandit.HasActionTask(bandit) and bandit:isCollidedThisFrame() then
        bandit:getPathFindBehavior2():cancel()
        bandit:setPath2(nil)

        local fd = bandit:getForwardDirection()
        local fdx = math.floor(fd:getX() + 0.5)
        local fdy = math.floor(fd:getY() + 0.5)

        local sqs = {}
        table.insert(sqs, {x=math.floor(bandit:getX()), y=math.floor(bandit:getY()), z=bandit:getZ()})
        table.insert(sqs, {x=math.floor(bandit:getX())+fdx, y=math.floor(bandit:getY())+fdy, z=bandit:getZ()})

        for _, s in pairs(sqs) do
            local square = cell:getGridSquare(s.x, s.y, s.z)
            if square then

                local safehouse = SafeHouse.isSafeHouse(square, nil, true)

                -- print ("SQ X:" .. square:getX() .. " Y:" .. square:getY())
                local objects = square:getObjects()

                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    local properties = object:getProperties()
                    if properties then
                        local lowFence = properties:Val("FenceTypeLow")
                        if lowFence then
                            if bandit:isFacingObject(object, 0.5) then
                                local params = bandit:getStateMachineParams(ClimbOverFenceState.instance())
                                local raw = KahluaUtil.rawTostring2(params) -- ugly but works
                                local endx = string.match(raw, "3=(%d+)")
                                local endy = string.match(raw, "4=(%d+)")

                                if endx and endy then
                                    bandit:changeState(ClimbOverFenceState.instance())
                                    bandit:setBumpType("ClimbFenceEnd")
                                end
                            else
                                bandit:faceThisObject(object)
                            end
                            break
                        end
                        local highFence = properties:Val("FenceTypeHigh")
                        if highFence then

                            if bandit:getVariableBoolean("bPathfind") or not bandit:getVariableBoolean("bMoving") then
                                bandit:setVariable("bPathfind", false)
                                bandit:setVariable("bMoving", true)
                            end

                            if bandit:isFacingObject(object, 0.5) then

                                -- bandit:changeState(ClimbOverFenceState.instance())
                                if not bandit:getVariableBoolean("ClimbWallStartEnded") then
                                    bandit:setVariable("hitreaction", "ClimbWallStart")
                                    
                                else
                                    bandit:setCollidable(false)
                                    bandit:setVariable("hitreaction", "ClimbWallSuccess")
                                end


                            else
                                bandit:faceThisObject(object)
                            end
                            break

                        end
                    end

                    if instanceof(object, "IsoWindow") and (not safehouse or Bandit.IsHostile(bandit)) then
                        if bandit:isFacingObject(object, 0.5) then

                            local fx = object:getSquare():getX()
                            local fy = object:getSquare():getY()
                            if object:getSprite():getProperties():Is(IsoFlagType.WindowN) then
                                fy = fy - 0.5
                            end
                            if object:getSprite():getProperties():Is(IsoFlagType.DoorW) then
                                fx = fx - 0.5
                            end

                            if object:isBarricaded() then
                                if SandboxVars.Bandits.General_RemoveBarricade and Bandit.Can(bandit, "unbarricade") and Bandit.Has(bandit, "crowbar") then

                                    local task = {action="Equip", itemPrimary="Base.Crowbar"}
                                    table.insert(tasks, task)

                                    task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)

                                    task = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=230, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                end

                            elseif not object:IsOpen() and not object:isSmashed() then
                                if SandboxVars.Bandits.General_SmashWindow and Bandit.Can(bandit, "smashWindow") then

                                    local task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)

                                    task = {action="SmashWindow", anim="WindowSmash", time=25, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ()}
                                    table.insert(tasks, task)
                                end

                            else
                                local params = bandit:getStateMachineParams(ClimbThroughWindowState.instance())
                                local raw = KahluaUtil.rawTostring2(params)
                                local startx = string.match(raw, "0=(%d+)")
                                local starty = string.match(raw, "1=(%d+)")
                                local endx = string.match(raw, "3=(%d+)")
                                local endy = string.match(raw, "4=(%d+)")

                                if true or (startx and starty and endx and endy) then
                                    ClimbThroughWindowState.instance():setParams(bandit, object)
                                    bandit:changeState(ClimbThroughWindowState.instance())
                                    bandit:setBumpType("ClimbWindow")
                                end
                            end
                        end

                        break
                    end

                    if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
                        if bandit:isFacingObject(object, 0.5) then

                            local fx = object:getSquare():getX()
                            local fy = object:getSquare():getY()
                            if object:getSprite():getProperties():Is(IsoFlagType.doorN) then
                                fy = fy - 0.5
                            end
                            if object:getSprite():getProperties():Is(IsoFlagType.doorW) then
                                fx = fx - 0.5
                            end

                            if object:isBarricaded() and (not safehouse or Bandit.IsHostile(bandit)) then
                                if SandboxVars.Bandits.General_RemoveBarricade and Bandit.Can(bandit, "unbarricade") and Bandit.Has(bandit, "crowbar") then
                                    Bandit.ClearTasks(bandit)

                                    local task = {action="Equip", itemPrimary="Base.Crowbar"}
                                    table.insert(tasks, task)

                                    task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)

                                    task = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=230, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                end

                            elseif object:isLocked() and (not safehouse or Bandit.IsHostile(bandit)) then
                                if SandboxVars.Bandits.General_DestroyDoor and Bandit.Can(bandit, "breakDoor") then
                                    Bandit.ClearTasks(bandit)

                                    local task = {action="Equip", itemPrimary=weapons.melee}
                                    table.insert(tasks, task)

                                    task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)

                                    task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), sound=object:getThumpSound(), time=80}
                                    table.insert(tasks, task)

                                end
                            elseif not object:IsOpen() and Bandit.Can(bandit, "openDoor") then
                                if IsoDoor.getDoubleDoorIndex(object) > -1 then
                                    IsoDoor.toggleDoubleDoor(object, true)
                                elseif IsoDoor.getGarageDoorIndex(object) > -1 then
                                    IsoDoor.toggleGarageDoor(object, true)
                                else
                                    object:ToggleDoorSilent()

                                    local args = {
                                        x = object:getSquare():getX(),
                                        y = object:getSquare():getY(),
                                        z = object:getSquare():getZ(),
                                        index = object:getObjectIndex()
                                    }
                                    sendClientCommand(getPlayer(), 'Commands', 'ToggleDoor', args)

                                    -- Get the square of the object
                                    local square = getPlayer():getSquare()

                                    -- Recalculate vision blocked for the surrounding tiles in a 10-tile radius
                                    local radius = 10
                                    for dx = -radius, radius do
                                        for dy = -radius, radius do
                                            local surroundingSquare = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
                                            if surroundingSquare then
                                                square:ReCalculateVisionBlocked(surroundingSquare)
                                            end
                                        end
                                    end

                                    bandit:playSound("WoodDoorOpen")
                                end
                            end
                        else
                            bandit:faceThisObject(object)
                        end
                        break
                    end

                    if instanceof(object, "IsoThumpable") and not properties:Val("FenceTypeLow") then
                        if SandboxVars.Bandits.General_DestroyThumpable and Bandit.Can(bandit, "breakObjects") then
                            Bandit.ClearTasks(bandit)

                            local task = {action="Equip", itemPrimary=weapons.melee}
                            table.insert(tasks, task)

                            local task = {action="FaceLocation", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), time=30}
                            table.insert(tasks, task)

                            local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), sound=object:getThumpSound(), time=80}
                            table.insert(tasks, task)
                        end
                        break
                    end

                end
            end
        end
    end
    return tasks
end

function BanditUpdate.Combat(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local gamemode = world:getGameMode()
    local zx = bandit:getX()
    local zy = bandit:getY()
    local zz = bandit:getZ()
    local brain = BanditBrain.Get(bandit)
    local weapons = Bandit.GetWeapons(bandit)

    local bestDist = 32
    local combat = false
    local firing = false

    -- COMBAT AGAIST PLAYERS 
    if Bandit.IsHostile(bandit) then
        local playerList = {}
        if gamemode == "Multiplayer" then
            playerList = getOnlinePlayers()
        else
            playerList = IsoPlayer.getPlayers()
        end

        for i=0, playerList:size()-1 do
            local potentialEnemy = playerList:get(i)
            if potentialEnemy and bandit:CanSee(potentialEnemy) and not potentialEnemy:isBehind(bandit) and (instanceof(potentialEnemy, "IsoPlayer") and not BanditPlayer.IsGhost(potentialEnemy)) then

                local px = potentialEnemy:getX()
                local py = potentialEnemy:getY()
                local pz = potentialEnemy:getZ()

                local dist = math.sqrt(math.pow(zx - px, 2) + math.pow(zy - py, 2))
                if dist < bestDist then

                    local spottedScore = CalcSpottedScore(potentialEnemy, dist)

                    local isWallTo = bandit:getSquare():isSomethingTo(potentialEnemy:getSquare())
                    if not isWallTo and spottedScore > 0.32 then

                        bestDist = dist
                        if Bandit.Can(bandit, "melee") and weapons.melee then
                            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                            local minRange = itemMelee:getMaxRange()
                            if dist <= minRange + 0.1 then 
                                enemyCharacter = potentialEnemy
                                combat = true
                            end
                        end

                        if Bandit.Can(bandit, "shoot") and weapons.primary and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange then 
                            enemyCharacter = potentialEnemy
                            firing = true
                        elseif Bandit.Can(bandit, "shoot") and weapons.secondary and (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange then
                            enemyCharacter = potentialEnemy
                            firing = true
                        end
                    end
                end
            end
        end
    end

    -- COMBAT AGAINST BANDITS FROM OTHER CLAN
    for i, coords in pairs(BanditMap.BMap) do
        if brain.clan ~= coords.clan and (brain.hostile or coords.hostile) then

            local dist = math.sqrt(math.pow(zx - coords.x, 2) + math.pow(zy - coords.y, 2))
            if dist < bestDist then

                local square = cell:getGridSquare(coords.x, coords.y, coords.z)
                if square then

                    local lightLevel = bandit:getSquare():getLightLevel(0)
                    local isWallTo = bandit:getSquare():isSomethingTo(square)
                    if not isWallTo and lightLevel > 0.31 then

                        local potentialEnemy = square:getZombie()
                        if potentialEnemy and bandit:CanSee(potentialEnemy) then

                            bestDist = dist
                            if Bandit.Can(bandit, "melee") and weapons.melee then
                                local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                                local minRange = itemMelee:getMaxRange()
                                if dist <= minRange then
                                    enemyCharacter = potentialEnemy
                                    combat = true
                                end
                            end

                            if Bandit.Can(bandit, "shoot") and weapons.primary and  (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange - 6 then 
                                enemyCharacter = potentialEnemy
                                firing = true
                            elseif Bandit.Can(bandit, "shoot") and weapons.secondary and  (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange - 4 then
                                enemyCharacter = potentialEnemy
                                firing = true
                            end
                        end
                    end
                end
            end
        end
    end

    -- COMBAT AGAINST ZOMBIES
    for i, coords in pairs(BanditMap.ZMap) do

        local dist = math.sqrt(math.pow(zx - coords.x, 2) + math.pow(zy - coords.y, 2))
        if dist < bestDist then

            local square = cell:getGridSquare(coords.x, coords.y, coords.z)
            if square then

                local lightLevel = bandit:getSquare():getLightLevel(0)
                local isWallTo = bandit:getSquare():isSomethingTo(square)
                if not isWallTo and lightLevel > 0.31 then

                    local potentialEnemy = square:getZombie()
                    if potentialEnemy and bandit:CanSee(potentialEnemy) then

                        bestDist = dist
                        if Bandit.Can(bandit, "melee") and weapons.melee then
                            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                            local minRange = itemMelee:getMaxRange()
                            if dist <= minRange + 0.4 then
                                enemyCharacter = potentialEnemy
                                combat = true
                            end
                        end

                        if Bandit.Can(bandit, "shoot") and weapons.primary and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange - 6 then 
                            enemyCharacter = potentialEnemy
                            firing = true
                        elseif Bandit.Can(bandit, "shoot") and weapons.secondary and (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange - 4 then
                            enemyCharacter = potentialEnemy
                            firing = true
                        end
                    end
                end
            end
        end
    end

    if combat and weapons.melee and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        if not Bandit.HasActionTask(bandit) then
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

            if not bandit:isPrimaryEquipped(weapons.melee) then
                local stasks = SwitchWeapon(bandit, weapons.melee)
                for _, t in pairs(stasks) do table.insert(tasks, t) end
            end

            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
            local swingSound = itemMelee:getSwingSound()

            if bandit:isPrimaryEquipped("AuthenticZClothing.Chainsaw") then
                local emitter = bandit:getEmitter()
                emitter:stopSoundByName("ChainsawIdle")
                swingSound = "ChainsawAttack1"
            end

            local anim
            if enemyCharacter:isAlive() then
                local task = {action="Hit", sound=swingSound, time=60, endurance=-0.2, weapon=weapons.melee, prone=enemyCharacter:isProne(), x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            elseif instanceof(enemyCharacter, "IsoPlayer") then
                local task = {action="Time", anim="Smoke", time=250}
                table.insert(tasks, task)
                Bandit.Say(bandit, "DEATH")
            end
        end

    elseif firing and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        if not Bandit.HasActionTask(bandit) then
            Bandit.ClearTasks(bandit)
            if enemyCharacter:isAlive() then
                
                local veh = enemyCharacter:getVehicle()
                if veh then Bandit.Say(bandit, "CAR") end

                if weapons.primary.name and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) then
                    if not bandit:isPrimaryEquipped(weapons.primary.name) then
                        local stasks = SwitchWeapon(bandit, weapons.primary.name)
                        for _, t in pairs(stasks) do table.insert(tasks, t) end

                        local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
                        local aimTimeSurp = SandboxVars.Bandits.General_GunReflexRand or 35
                        if aimTimeMin + aimTimeSurp > 0 then
                            local task = {action="Time", anim="AimRifle", time=aimTimeMin + ZombRand(aimTimeSurp)}
                            table.insert(tasks, task)
                        end
                        Bandit.Say(bandit, "SPOTTED")
                    end

                    if weapons.primary.bulletsLeft > 0 then
                        local firingtime = weapons.primary.shotDelay
                        if ZombRand(5) == 1 then firingtime = 50 end

                        local task = {action="Shoot", anim="AimRifle", weaponSound=weapons.primary.shotSound, time=firingtime, weapon=weapons.primary.name, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                        table.insert(tasks, task)

                        weapons.primary.bulletsLeft = weapons.primary.bulletsLeft - 1

                    elseif weapons.primary.magCount > 0 then
                        local task = {action="Drop", itemType=weapons.primary.magName, anim="UnloadRifle", sound="M14EjectAmmo", time=90}
                        table.insert(tasks, task)

                        local task = {action="Time", anim="ReloadRifle", sound="M14InsertAmmo", time=90}
                        table.insert(tasks, task)
                        Bandit.Say(bandit, "RELOADING")

                        weapons.primary.bulletsLeft = weapons.primary.magSize
                        weapons.primary.magCount = weapons.primary.magCount - 1
                    end
                    Bandit.SetWeapons(bandit, weapons)

                elseif weapons.secondary.name and (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) then

                    if not bandit:isPrimaryEquipped(weapons.secondary.name) then
                        local stasks = SwitchWeapon(bandit, weapons.secondary.name)
                        for _, t in pairs(stasks) do table.insert(tasks, t) end
                
                        local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
                        local aimTimeSurp = SandboxVars.Bandits.General_GunReflexRand or 35
                        if aimTimeMin + aimTimeSurp > 0 then
                            local task = {action="Time", anim="AimPistol", time=aimTimeMin + ZombRand(aimTimeSurp)}
                            table.insert(tasks, task)
                        end
                        Bandit.Say(bandit, "SPOTTED")
                    end

                    if weapons.secondary.bulletsLeft > 0 then

                        local task = {action="Shoot", anim="AimPistol", weaponSound=weapons.secondary.shotSound, time=weapons.secondary.shotDelay, weapon=weapons.secondary.name, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                        table.insert(tasks, task)

                        weapons.secondary.bulletsLeft = weapons.secondary.bulletsLeft - 1

                    elseif weapons.secondary.magCount > 0 then
                        local task = {action="Drop", itemType=weapons.secondary.magName, anim="UnloadPistol", sound="M9EjectAmmo", time=90}
                        table.insert(tasks, task)

                        local task = {action="Time", anim="ReloadPistol", sound="M9InsertAmmo", time=90}
                        table.insert(tasks, task)
                        Bandit.Say(bandit, "RELOADING")

                        weapons.secondary.bulletsLeft = weapons.secondary.magSize
                        weapons.secondary.magCount = weapons.secondary.magCount - 1

                    end
                    Bandit.SetWeapons(bandit, weapons)

                end

            elseif instanceof(enemyCharacter, "IsoPlayer") then
                local task = {action="Time", anim="Smoke", time=250}
                table.insert(tasks, task)
                Bandit.Say(bandit, "DEATH")
            end

        end
    end
    return tasks
end

function BanditUpdate.Zombie(zombie)

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    -- this item determines the strenght of the zombie attach on bandit
    local teeth = InventoryItemFactory.CreateItem("Base.RollingPin")

    local asn = zombie:getActionStateName()
    if not zombie:getVariableBoolean("Bandit") and asn ~= "bumped" and not zombie:isProne() then
        for _, b in pairs(BanditMap.BMap) do
            if b then
                local dist = math.sqrt(math.pow(zx - b.x, 2) + math.pow(zy - b.y, 2))
                if dist < 12 and b.z == zz then

                    -- zombie lunge attack on a zombie/bandit results in game crash because of moodle check
                    -- this forces an alternate animation with the checkattack event removed to avoid the crash
                    zombie:setVariable("NoLungeAttack", true)

                    local square = getCell():getGridSquare(b.x, b.y, b.z)
                    if square then
                        local bandit = square:getZombie()
                        if bandit then
                            if bandit:getVariableBoolean("Bandit") then
                                local isWallTo = zombie:getSquare():isSomethingTo(bandit:getSquare())

                                if dist < 0.7 and not isWallTo then

                                    if zombie:isFacingObject(bandit, 0.5) then
                                        local attackingZombiesNumber = 0
                                        for _, z in pairs(BanditMap.ZMap) do 
                                            local dist = math.sqrt(math.pow(z.x - b.x, 2) + math.pow(z.y - b.y, 2))
                                            if dist < 0.7 then
                                                attackingZombiesNumber = attackingZombiesNumber +1
                                            end
                                        end

                                        zombie:setBumpType("Bite")

                                        if ZombRand(4) == 1 then
                                            bandit:playSound("ZombieScratch")
                                        else
                                            bandit:playSound("ZombieBite")
                                        end

                                        SwipeStatePlayer.splash(bandit, teeth, zombie)

                                        if attackingZombiesNumber > 2 then
                                            local sound = "MaleBeingEatenDeath"
                                            if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
                                            local task = {action="Die", lock=true, anim="Die", sound=sound, time=150}
                                            Bandit.AddTask(bandit, task)
                                        else
                                            bandit:Hit(teeth, zombie, 1.01, false, 1, false)
                                        end
                                    else
                                        zombie:faceThisObject(bandit)
                                    end
                                else
                                    local asn = zombie:getActionStateName()
                                    if asn == "idle" then
                                        zombie:pathToLocationF(b.x, b.y, b.z)
                                        zombie:spotted(bandit, true)
                                        zombie:addAggro(bandit, 10)
                                    end
                                end
                            end
                        end
                    end
                else
                    zombie:setVariable("NoLungeAttack", false)
                end
            end
        end
    end
end


local uTick = 0
function BanditUpdate.OnBanditUpdate(zombie)

    if isServer() then return end

    if uTick == 15 then uTick = 0 end
    uTick = uTick + 1

    if not zombie:isAlive() then return end

    ------------------------------------------------------------------------------------------------------------------------------------
    -- ZOMBIE UPDATE AFTER THIS LINE
    ------------------------------------------------------------------------------------------------------------------------------------

    local id = BanditUtils.GetCharacterID(zombie)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    local cell = getCell()
    local world = getWorld()
    local gamemode = world:getGameMode()
    local brain = BanditBrain.Get(zombie)

    -- BANDITIZE ZOMBIES SPAWNED AND ENQUEUED BY SERVER
    if not zombie:getVariableBoolean("Bandit") then
        local gmd = GetBanditModData()
        if gmd.Queue and gmd.Queue[id] and id ~= 0 then
            brain = gmd.Queue[id]
            BanditUpdate.Banditize(zombie, brain)
        else
            -- make sure recycled bandits respawned as zombies are not equipped with items
            if zombie:getPrimaryHandItem() then
                zombie:setPrimaryHandItem(nil)
            end
            BanditBrain.Remove(zombie)
        end
    end

    -- ZOMBIES VS BANDITS
    if uTick % 2 == 1 then
        BanditUpdate.Zombie(zombie)
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    -- BANDIT UPDATE AFTER THIS LINE
    ------------------------------------------------------------------------------------------------------------------------------------
    if not zombie:getVariableBoolean("Bandit") then return end
    if not brain then return end

    local bandit = zombie

    -- IF TELEPORTING THEN THERE IS NO SENSE IN PROCEEDING
    if bandit:isTeleporting() then
        return
    end

    -- WALKTYPE
    -- we do ot this way, if walktype get overwritten by game engine we force our animations
    zombie:setWalkType(zombie:getVariableString("BanditWalkType"))
    

    -- NO ZOMBIE SOUNDS
    bandit:getEmitter():stopSoundByName("MaleZombieCombined")
    bandit:getEmitter():stopSoundByName("FemaleZombieCombined")

        -- CANNIBALS
    -- hardcoded for now
    if brain.clan ~= 3 then
        bandit:setEatBodyTarget(nil, false)
    end

    -- ADJUST HUMAN VISUALS
    BanditUpdate.Visuals(bandit)

    -- MANAGE BANDIT TORCH
    BanditUpdate.Torch(bandit)

    -- MANAGE BANDIT CHAINSAW
    BanditUpdate.Chainsaw(bandit)

    -- MANAGE BANDIT BEING ON FIRE
    BanditUpdate.Fire(bandit)

    -- MANAGE BANDIT SPEECH COOLDOWN
    BanditUpdate.Speech(bandit)

    -- ACTION STATE TWEAKS
    local continue = BanditUpdate.ActionState(bandit)
    if not continue then return end

     ------------------------------------------------------------------------------------------------------------------------------------
    -- TASKBUILDER
    ------------------------------------------------------------------------------------------------------------------------------------

    local tasks = {}

    -- MANAGE BANDIT ENDURANCE LOSS
    local enduranceTasks = BanditUpdate.Endurance(bandit)
    if #enduranceTasks > 0 then
        for _, t in pairs(enduranceTasks) do table.insert(tasks, t) end
    end

    -- MANAGE BLEEDING AND HEALING
    if #tasks == 0 then
        local healingTasks = BanditUpdate.Health(bandit)
        if #healingTasks > 0 then
            for _, t in pairs(healingTasks) do table.insert(tasks, t) end
        end
    end

    -- MANAGE MELEE / SHOOTING TASKS
    if #tasks == 0 then
        local combatTasks = BanditUpdate.Combat(bandit)
        if #combatTasks > 0 then
            for _, t in pairs(combatTasks) do table.insert(tasks, t) end
        end
    end

    -- MANAGE COLLISION TASKS
    if #tasks == 0 then
        local colissionTasks = BanditUpdate.Collisions(bandit)
        if #colissionTasks > 0 then
            for _, t in pairs(colissionTasks) do table.insert(tasks, t) end
        end
    end

    -- CUSTOM PROGRAM 
    if #tasks == 0 and not Bandit.HasTask(bandit) then
        local program = Bandit.GetProgram(bandit)
        if program and program.name and program.stage then
            local res = ZombiePrograms[program.name][program.stage](bandit)
            if res.status and res.next then
                Bandit.SetProgramStage(bandit, res.next)
                for _, task in pairs(res.tasks) do
                    table.insert(tasks, task)
                end
            else
                local task = {action="Time", anim="Shrug", time=200}
                table.insert(tasks, task)
            end
        end
    end

    if #tasks > 0 then
        for _, task in pairs(tasks) do
            table.insert(brain.tasks, task)
        end
        BanditBrain.Update(zombie, brain)
    end
    
    ------------------------------------------------------------------------------------------------------------------------------------
    -- TASK PROCESSOR
    ------------------------------------------------------------------------------------------------------------------------------------

    local task = Bandit.GetTask(bandit)
    if not task then return end
    if not task.action then return end
    if not task.state then task.state = "NEW" end

    if task.state == "NEW" then

        if task.sound then
            bandit:playSound(task.sound)
        end

        if task.anim then
            bandit:setBumpType(task.anim)
        end

        if not task.time then task.time = 10000 end
        local done = ZombieActions[task.action].onStart(bandit, task)

        if done then 
            task.state = "WORKING"
            Bandit.UpdateTask(bandit, task)
        end

    elseif task.state == "WORKING" then

        task.time = task.time - 1

        local done = ZombieActions[task.action].onWorking(bandit, task)

        if done or task.time == 0 then 
            task.state = "COMPLETED"
        end
        Bandit.UpdateTask(bandit, task)

    elseif task.state == "COMPLETED" then

        if task.endurance then
            Bandit.UpdateEndurance(bandit, task.endurance)
        end

        local done = ZombieActions[task.action].onComplete(bandit, task)
        if done then 
            Bandit.RemoveTask(bandit)
        end

    end

end

function BanditUpdate.OnHitZombie(zombie)
    if zombie:getVariableBoolean("Bandit") then
        Bandit.Say(zombie, "HIT")

        if Bandit.IsSleeping(zombie) then
            local task = {action="Time", lock=true, anim="GetUp", time=150}
            Bandit.ClearTasks(zombie)
            Bandit.AddTask(zombie, task)
            Bandit.SetSleeping(zombie, false)
            Bandit.SetProgramStage(zombie, "Prepare")
        end

    end
end

function BanditUpdate.OnZombieDead(zombie)

    if zombie:getVariableBoolean("Bandit") then

        local id = BanditUtils.GetCharacterID(zombie)
        local brain = BanditBrain.Get(zombie)

        zombie:setUseless(false)
        zombie:setReanim(false)
        zombie:setVariable("Bandit", false)
        zombie:setPrimaryHandItem(nil)
        zombie:clearAttachedItems()
        zombie:resetEquippedHandsModels()
        -- brain.enslaved = false
        -- BanditBrain.Update(bandit, brain)

        args = {}
        args.id = id
        sendClientCommand(getPlayer(), 'Commands', 'BanditRemove', args)

        BanditMap.BMap[id] = nil
    else
        BanditMap.ZMap[id] = nil
    end
end

Events.OnZombieUpdate.Add(BanditUpdate.OnBanditUpdate)
Events.OnHitZombie.Add(BanditUpdate.OnHitZombie)
Events.OnZombieDead.Add(BanditUpdate.OnZombieDead)