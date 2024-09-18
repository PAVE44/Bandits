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

local function getEscapePoint(bandit, radius)
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)

    -- Create an array to count enemy characters in radial segments
    local segmentCount = 16
    local segments = {}
    for i = 1, segmentCount do
        segments[i] = 0
    end

    -- counters to determine if the bandit is outnumbered
    local friendlies = 0
    local enemies = 0

    local potentialEnemyList = BanditZombie.GetAll()
    for id, potentialEnemy in pairs(potentialEnemyList) do
        -- Calculate distance between bandit and the enemy character
        local distance = math.sqrt((potentialEnemy.x - bx) ^ 2 + (potentialEnemy.y - by) ^ 2)
        if distance <= radius and bz == potentialEnemy.z then
            -- Calculate angle of the point relative to the circle's center
            local angle = math.atan2(potentialEnemy.y - by, potentialEnemy.x - bx)
            -- Convert angle from radians to degrees
            local degrees = math.deg(angle)
            -- Normalize angle to be within the -180 to 180 range
            if degrees >= 180 then
                degrees = degrees - 360
            end
            -- Determine which segment this angle falls into
            local segment = math.floor((degrees + 180) / (360 / segmentCount)) + 1
            
            -- Increment enemy and friendly counters for that segment
            if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
                segments[segment] = segments[segment] + 1
            end
        end
    end

    -- Find the segment with the fewest points
    local minCnt = math.huge
    local segmentBest = 1
    for i = 1, segmentCount do
        if segments[i] < minCnt then
            minCnt = segments[i]
            segmentBest = i
        end
    end

    -- Calculate the mean threat direction
    local segmentSize = 360 / segmentCount
    local segmentStartAngle = -180 + (segmentBest - 1) * segmentSize
    local segmentEndAngle = segmentStartAngle + segmentSize
    local dir = (segmentStartAngle + segmentEndAngle) / 2

    -- Find the space point 10 square away
    local lx = bx + math.floor(25 * math.cos(dir))
    local ly = by + math.floor(25 * math.sin(dir))
    return lx, ly, bz
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

function BanditUpdate.Zombify(zombie)
    zombie:setNoTeeth(false)
    zombie:setUseless(false)
    zombie:setVariable("Bandit", false)
    zombie:setVariable("BanditPrimary", "")
    zombie:setVariable("BanditSecondary", "")
    zombie:setWalkType("2")
    zombie:setVariable("BanditWalkType", "")
    zombie:setPrimaryHandItem(nil)
    zombie:setSecondaryHandItem(nil)
    zombie:resetEquippedHandsModels()
    zombie:clearAttachedItems()
    BanditBrain.Remove(zombie)
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
        local brain = BanditBrain.Get(bandit)
        local zx = bandit:getX()
        local zy = bandit:getY()
        local zz = bandit:getZ()
        local ls = bandit:getVariableBoolean("BanditTorch")
        local veh = bandit:getVehicle()
        if ls and not veh then
            local colors = {r=0.8, g=0.8, b=0.8}
            if brain.clan == 11 then
                colors = {r=0.8, g=0.8, b=0.8}
            end
            if bandit:isProne() then
                local lightSource = IsoLightSource.new(zx, zy, zz, colors.r, colors.g, colors.b, 2, 20)
                getCell():addLamppost(lightSource)
            else
                local theta = bandit:getDirectionAngle() * math.pi / 180
                for i = 0, 15 do
                    local lx = zx + math.floor(i * math.cos(theta) + 0.5)
                    local ly = zy + math.floor(i * math.sin(theta) + 0.5)
                    local lightSource = IsoLightSource.new(lx, ly, zz, colors.r-i/20, colors.g-i/20, colors.b-i/20, i/2, 20)
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
        local sound 
        if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
        if not Bandit.HasTaskType(bandit, "Die") then
            Bandit.ClearTasks(bandit)
            local task = {action="Die", lock=true, anim="Die", fire=true, sound=sound, time=150}
            Bandit.AddTask(bandit, task)
        end
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

function BanditUpdate.Sound(bandit)
    local brain = BanditBrain.Get(bandit)
    if brain.sound and brain.sound > 0 then
        brain.sound = brain.sound - 0.001
        if brain.sound < 0 then brain.sound = 0 end
        BanditBrain.Update(bandit, brain)
    end
end

function BanditUpdate.ActionState(bandit)
    local asn = bandit:getActionStateName()
    local continue = true
    -- print(asn)
    if asn == "onground" then
        
        if bandit:getVehicle() then
            -- the character is a passanger of a car
            continue = true
        else
            if bandit:isUnderVehicle() then
                -- the character exited the car and his position must be fixed
                -- to not be under the car
                bandit:setX(bandit:getX() + 0.5)
                bandit:setY(bandit:getY() + 0.5)
                Bandit.ClearTasks(bandit)
                continue = false
            else
                -- the character is simply on the ground
                Bandit.ClearTasks(bandit)
                continue = false
            end
        end

    elseif asn == "turnalerted" then
        bandit:changeState(ZombieIdleState.instance())

    elseif asn == "getup" or asn =="staggerback" then
        Bandit.ClearTasks(bandit)
        continue = false
        
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
    elseif asn == "lunge"  then
        -- bandit:changeState(ZombieIdleState.instance())
        bandit:setUseless(true)
        bandit:clearAggroList()
        bandit:setTarget(nil)

    elseif asn == "walktoward-network" then

    else
        local world = getWorld()
        local gamemode = world:getGameMode()
        bandit:setTarget(nil)
        bandit:setTargetSeenTime(0)
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
        if bandit:getHealth() < 0.9 then
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

    if SandboxVars.Bandits.General_Infection then
        local brain = BanditBrain.Get(bandit)
        if brain.infection and brain.infection > 0 then
            -- print ("INFECTION: " .. brain.infection)
            local delta = 0.001
            Bandit.UpdateInfection(bandit, delta)
            if brain.infection > 100 then
                local task = {action="Zombify", anim="Faint", lock=true, time=200}
                table.insert(tasks, task)
            end
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
                        local hoppable = object:isHoppable()
                        if lowFence or hoppable then
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
                            if object:getSprite():getProperties():Is(IsoFlagType.doorW) then
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

                            elseif object:canClimbThrough(bandit) then
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

                                    -- Recalculate vision blocked for the surrounding tiles in a r-tile radius
                                    local radius = 5
                                    for dx = -radius, radius do
                                        for dy = -radius, radius do
                                            -- if dx ~= 0 and dy ~= 0 then
                                                local surroundingSquare = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
                                                --local surroundingSquare = getCell():getGridSquare(square:getX(), square:getY() + 1, square:getZ())
                                                if surroundingSquare then
                                                    --[[
                                                    square:ReCalculateCollide(surroundingSquare)
                                                    square:ReCalculatePathFind(surroundingSquare)
                                                    square:ReCalculateVisionBlocked(surroundingSquare)
                                                    surroundingSquare:ReCalculateCollide(square)
                                                    surroundingSquare:ReCalculatePathFind(square)
                                                    surroundingSquare:ReCalculateVisionBlocked(square)
                                                    ]]
                                                    surroundingSquare:InvalidateSpecialObjectPaths()
                                                    surroundingSquare:RecalcProperties()
                                                    surroundingSquare:RecalcAllWithNeighbours(true)
                                                end
                                            -- end
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

function BanditUpdate.Avoidance(bandit)
    local tasks = {}
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)

    -- counters to determine the balance of power in a given radius
    local friendlies = 0
    local enemies = 0
    local radius = 9

    local potentialEnemyList = BanditZombie.GetAll()
    for id, potentialEnemy in pairs(potentialEnemyList) do
        -- Calculate distance between bandit and the enemy character
        local distance = math.sqrt((potentialEnemy.x - bx) ^ 2 + (potentialEnemy.y - by) ^ 2)
        if distance <= radius and bz == potentialEnemy.z then
            -- Calculate angle of the point relative to the circle's center
            
            if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
                enemies = enemies + 1
            else
                friendlies = friendlies + 1
            end
        end
    end

    if enemies > friendlies + 3 and not Bandit.HasMoveTask(bandit) then
        local tx, ty, tz = getEscapePoint(bandit, 10)
        -- bandit:addLineChatElement("evade to")
        local task = BanditUtils.GetMoveTask(0.01, tx, ty, tz, "Run", 30)
        task.panic = true
        task.lock = true
        table.insert(tasks, task)
    end 

    -- print ("BALANCE: F: " .. friendlies .. " E: " .. enemies)
    return tasks
end

function BanditUpdate.Combat(bandit)

    if bandit:isCrawling() then return {} end 
    if Bandit.IsSleeping(bandit) then return {} end
    if bandit:getActionStateName() == "bumped" then return {} end

    local tasks = {}
    local cell = getCell()
    local zx = bandit:getX()
    local zy = bandit:getY()
    local zz = bandit:getZ()
    local brain = BanditBrain.Get(bandit)
    local weapons = Bandit.GetWeapons(bandit)
    
    local bestDist = 40
    local enemyCharacter
    local combat = false
    local firing = false
    local shove = false

    -- COMBAT AGAIST PLAYERS 
    if Bandit.IsHostile(bandit) then
        local playerList = BanditPlayer.GetPlayers()

        for i=0, playerList:size()-1 do
            local potentialEnemy = playerList:get(i)
            if potentialEnemy and bandit:CanSee(potentialEnemy) and not potentialEnemy:isBehind(bandit) and (instanceof(potentialEnemy, "IsoPlayer") and not BanditPlayer.IsGhost(potentialEnemy)) then
                local px = potentialEnemy:getX()
                local py = potentialEnemy:getY()
                local pz = potentialEnemy:getZ()

                local dist = math.sqrt(math.pow(zx - px, 2) + math.pow(zy - py, 2))
                if dist < bestDist and pz == zz then

                    local spottedScore = CalcSpottedScore(potentialEnemy, dist)

                    local isWallTo = bandit:getSquare():isSomethingTo(potentialEnemy:getSquare())
                    if not isWallTo and spottedScore > 0.32 then
                        bestDist = dist

                        --determine if bandit will be in combat mode
                        if Bandit.Can(bandit, "melee") and weapons.melee then
                            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                            local minRange = itemMelee:getMaxRange()
                            local cryingPlayersHandicap = 0.2
                            if dist <= minRange - cryingPlayersHandicap then 
                                enemyCharacter = potentialEnemy
                                local asn = enemyCharacter:getActionStateName()
                                if dist < 0.6 and not enemyCharacter:isProne() and asn ~= "onground" and asn ~= "sitonground" and asn ~= "climbfence" and asn ~= "bumped" then
                                    shove = true
                                else
                                    combat = true
                                end
                            end
                        end

                        --determine if bandit will be in shooting mode
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

    -- COMBAT AGAINST ZOMBIES AND BANDITS FROM OTHER CLAN
    local enemies = 0
    local friendlies = 0
    local potentialEnemyList = BanditZombie.GetAll()
    for id, potentialEnemy in pairs(potentialEnemyList) do

        local dist = math.sqrt(math.pow(zx - potentialEnemy.x, 2) + math.pow(zy - potentialEnemy.y, 2))

        -- hard cap for optimization
        if dist < 25 then
            if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
                if dist < 6 then enemies = enemies + 1 end
                if dist < bestDist and potentialEnemy.z == zz  then
        
                    -- load real instance here
                    local potentialEnemy = BanditZombie.GetInstanceById(id)
                    if bandit:CanSee(potentialEnemy) then -- FIXME: add visibility cone
                        local potentialEnemySquare = potentialEnemy:getSquare()
                        if potentialEnemySquare then
                            local lightLevel = potentialEnemySquare:getLightLevel(0)
                            local isWallTo = bandit:getSquare():isSomethingTo(potentialEnemySquare)
                            if not isWallTo and lightLevel > 0.31 then
                                bestDist = dist
                                
                                --determine if bandit will be in combat mode
                                if Bandit.Can(bandit, "melee") and weapons.melee and zz == potentialEnemy:getZ() then
                                    local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                                    
                                    -- the bandit may need to swich to melee weapon so we need to switch earier
                                    -- before target is in range
                                    local minRange = itemMelee:getMaxRange()
                                    if dist <= minRange then
                                        enemyCharacter = potentialEnemy
                                        local asn = enemyCharacter:getActionStateName()
                                        if dist < 0.6 and not enemyCharacter:isProne() and asn ~= "onground" and asn ~= "climbfence" and asn ~= "bumped" and asn ~= "getup" then
                                            shove = true
                                        else
                                            combat = true
                                        end
                                    end
                                end

                                --determine if bandit will be in shooting mode
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
            else
                if dist < 6 then friendlies = friendlies + 1 end
            end
        end
    end

    -- print ("ENEMIES: " .. enemies .. " FRIENDLIES: " .. friendlies)

    if shove then
        if not Bandit.HasTaskType(bandit, "Shove") then
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

            if bandit:isFacingObject(enemyCharacter, 0.1) then
                local eid = BanditUtils.GetCharacterID(enemyCharacter)
                local task = {action="Shove", anim="Shove", sound="AttackShove", time=60, endurance=-0.05, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            else
                bandit:faceThisObject(enemyCharacter)
            end
        end

    elseif combat then
        if not Bandit.HasTaskType(bandit, "Hit") and not Bandit.HasTaskType(bandit, "Equip") and not Bandit.HasTaskType(bandit, "Unequip") and enemyCharacter:isAlive() then
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

            if not bandit:isPrimaryEquipped(weapons.melee) then
                local stasks = SwitchWeapon(bandit, weapons.melee)
                for _, t in pairs(stasks) do table.insert(tasks, t) end
            end

            if bandit:isFacingObject(enemyCharacter, 0.5) then
                local eid = BanditUtils.GetCharacterID(enemyCharacter)
                local task = {action="Hit", time=60, endurance=-0.03, weapon=weapons.melee, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            else
                bandit:faceThisObject(enemyCharacter)
            end

        
        elseif instanceof(enemyCharacter, "IsoPlayer") and not Bandit.HasActionTask(bandit) then
            local task = {action="Time", anim="Smoke", time=250}
            table.insert(tasks, task)
            Bandit.Say(bandit, "DEATH")
        end


    elseif firing then
        if not Bandit.HasActionTask(bandit) then
            Bandit.ClearTasks(bandit)
            if enemyCharacter:isAlive() then
                
                local veh = enemyCharacter:getVehicle()
                if veh then Bandit.Say(bandit, "CAR") end

                if bandit:isFacingObject(enemyCharacter, 0.5) then
                    if weapons.primary.name and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) then
                        if not bandit:isPrimaryEquipped(weapons.primary.name) then
                            local stasks = SwitchWeapon(bandit, weapons.primary.name)
                            for _, t in pairs(stasks) do table.insert(tasks, t) end

                            local dist = math.sqrt(math.pow(bandit:getX() - enemyCharacter:getX(), 2) + math.pow(bandit:getY() - enemyCharacter:getY(), 2))
                            local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
                            local aimTimeSurp = math.floor(dist ^ 1.2)
                            -- local aimTimeSurp = SandboxVars.Bandits.General_GunReflexRand or 35
                            if aimTimeMin + aimTimeSurp > 0 then
                                print ("AIM: " .. (aimTimeMin + aimTimeSurp))
                                local task = {action="Time", anim="AimRifle", time=aimTimeMin + aimTimeSurp}
                                table.insert(tasks, task)
                            end
                            Bandit.Say(bandit, "SPOTTED")
                        end

                        if weapons.primary.bulletsLeft > 0 then
                            local dist = math.sqrt(math.pow(bandit:getX() - enemyCharacter:getX(), 2) + math.pow(bandit:getY() - enemyCharacter:getY(), 2))

                            local firingtime = weapons.primary.shotDelay + math.floor(dist ^ 1.2)

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
                else
                    bandit:faceThisObject(enemyCharacter)
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

function BanditUpdate.SocialDistance(bandit)

    -- Friendlies will always tend to approach the player
    -- this is because they switch to lunge mode by game engine automatically.
    -- The only way to workaround it, is to set the useless flag to true.  
    -- so here we detect player proximity and we switch the program to CompaningGuard,
    -- which in practice forces the useless flag.

    local brain = BanditBrain.Get(bandit)
    if brain.program.name == "Companion" then
        local playerList = BanditPlayer.GetPlayers()
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player then
                local veh = player:getVehicle()
                local asn = bandit:getActionStateName()
                local dist = math.sqrt(math.pow(bandit:getX() - player:getX(), 2) + math.pow(bandit:getY() - player:getY(), 2))
                
                if bandit:getZ() == player:getZ() and dist < 4 and not veh and asn ~= "onground" then

                    local closestZombie = BanditUtils.GetClosestZombieLocation(player)
                    local closestBandit = BanditUtils.GetClosestZombieLocation(player)
            
                    if closestZombie.dist > 3 and closestBandit.dist > 3 then
                        if Bandit.GetProgram(bandit).name ~= "CompanionGuard" then
                            Bandit.SetProgram(bandit, "CompanionGuard", {})
                        end
                    end
                end
            end
        end
    end
end

function BanditUpdate.Zombie(zombie)
    
    zombie:setVariable("NoLungeAttack", true)
 
    local asn = zombie:getActionStateName()
    if not zombie:getVariableBoolean("Bandit") and not zombie:isProne() and asn ~= "bumped" and asn ~= "onground" and asn ~= "climbfence" and asn ~= "getup" then

        -- sometimes recycled bandits zombies have brain not removed, here is a good place to garbage collect it
        BanditBrain.Remove(zombie)

        -- warning setUseless uses a lot of bandwidth, use only when needed
        if zombie:isUseless() then
            zombie:setUseless(false)
        end

        local phi = zombie:getPrimaryHandItem()
        local shi = zombie:getSecondaryHandItem()
        if phi then
            zombie:setPrimaryHandItem(nil)
        end
        if shi then
            zombie:setSecondaryHandItem(nil)
        end

        local emitter = zombie:getEmitter()
        if emitter:isPlaying("ChainsawIdle") then
            emitter:stopSoundByName("ChainsawIdle")
        end
        
        -- zed coords
        local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()

        -- fetch the RAM-based lightweight zombie cache
        local enemy = BanditUtils.GetClosestBanditLocation(zombie)

        -- deal with the found if it is in range
        if enemy.dist < 20 then

            -- fetch visible players
            -- if player is closer than the bandit, dont do anything, game engine will manage attack on player by itself
            local player = BanditUtils.GetClosestPlayerLocation(zombie, true)
            if player.dist < enemy.dist then return end

            local bandit = BanditZombie.GetInstanceById(enemy.id)
            local isWallTo = zombie:getSquare():isSomethingTo(bandit:getSquare())

            -- the enemy is far, proceed with movement
            if enemy.dist > 1 then
                local asn = zombie:getActionStateName()
                if zombie:CanSee(bandit) and asn ~= "lunge" then
                    zombie:setTarget(bandit)
                    zombie:pathToCharacter(bandit)
                    zombie:spotted(bandit, true)
                end

            elseif enemy.dist > 0.49 and enemy.dist < 0.7 then
                zombie:setTarget(nil)
                zombie:setPath2(nil)
            
            -- the enemy is close, proceed with the attack
            elseif enemy.dist < 0.49 and not isWallTo then

                -- if the zombie is facing the bandit attack may proceed, otherwise turn zombie towards the target
                if zombie:isFacingObject(bandit, 0.5) then

                    -- detect number of zombies attacking the bandit at the same time
                    local attackingZombiesNumber = 0
                    local attackingZombieList = BanditZombie.GetAllZ()
                    for id, attackingZombie in pairs(attackingZombieList) do
                        local dist = math.sqrt(math.pow(attackingZombie.x - enemy.x, 2) + math.pow(attackingZombie.y - enemy.y, 2))
                        if dist < 0.6 then
                            attackingZombiesNumber = attackingZombiesNumber + 1
                            
                            -- if we know there is at least 3, then it's good enough and we can break for the sake of performance
                            if attackingZombiesNumber > 2 then break end
                        end
                    end

                    -- depending on the number of attacking zombies, initiate a dragown or just a bite 
                    if attackingZombiesNumber > 2 then
                        local sound
                        if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
                        if not Bandit.HasTaskType(bandit, "Die") then
                            Bandit.ClearTasks(bandit)
                            local task = {action="Die", lock=true, anim="Die", sound=sound, time=300}
                            Bandit.AddTask(bandit, task)
                        end
                    else
                        zombie:setTarget(nil)
                        zombie:setPath2(nil)
                        zombie:setBumpType("Bite")

                        if ZombRand(4) == 1 then
                            bandit:playSound("ZombieScratch")
                        else
                            bandit:playSound("ZombieBite")
                        end

                        -- this item determines the strenght of the zombie attack on bandit
                        local teeth = InventoryItemFactory.CreateItem("Base.RollingPin")

                        SwipeStatePlayer.splash(bandit, teeth, zombie)

                        bandit:Hit(teeth, zombie, 1.01, false, 1, false)
                        Bandit.UpdateInfection(bandit, 0.001)
                        if bandit:getHealth() <= 0 then
                            bandit:setHealth(0)
                            bandit:clearAttachedItems()
                            -- bandit:changeState(ZombieOnGroundState.instance())
                            bandit:setAttackedBy(getCell():getFakeZombieForHit())
                            -- bandit:becomeCorpse()
                        end
                    end
                else
                    zombie:faceThisObject(bandit)
                end
            end
        end
    end
end


local uTick = 0
function BanditUpdate.OnBanditUpdate(zombie)

    if isServer() then return end

    if uTick == 16 then uTick = 0 end
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
    -- OR ZOMBIFY IF QUEUE HAS BEEN REMOVED
    local gmd = GetBanditModData()
    if gmd.Queue then
        if gmd.Queue[id] and id ~= 0 then
            if not zombie:getVariableBoolean("Bandit") then
                brain = gmd.Queue[id]
                BanditUpdate.Banditize(zombie, brain)
            end
        else
            if zombie:getVariableBoolean("Bandit") then
                BanditUpdate.Zombify(zombie)
            end
        end
    end

    -- if true then return end 
    -- ZOMBIES VS BANDITS
    -- Using adaptive performance here.
    -- The more zombies in player's cell, the less frequent updates.
    -- Up to 100 zombies, update every tick, 
    -- 800+ zombies, update every 1/16 tick. 
    local zcnt = BanditZombie.GetAllCnt()
    if zcnt > 600 then zcnt = 600 end
    local skip = math.floor(zcnt / 50) + 1
    if uTick % skip == 0 then
        -- print (skip)
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
    -- we do it this way, if walktype get overwritten by game engine we force our animations
    zombie:setWalkType(zombie:getVariableString("BanditWalkType"))

    -- NO ZOMBIE SOUNDS
    bandit:getEmitter():stopSoundByName("MaleZombieCombined")
    bandit:getEmitter():stopSoundByName("FemaleZombieCombined")

    -- CANNIBALS
    if not brain.eatBody then
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

    -- MANAGE BANDIT SOUND COOLDOWN
    BanditUpdate.Sound(bandit)

    -- ACTION STATE TWEAKS
    local continue = BanditUpdate.ActionState(bandit)
    if not continue then return end
    
    -- COMPANION SOCIAL DISTANCE HACK
    BanditUpdate.SocialDistance(bandit)

    -- CRAWLERS SCREAM OCASSINALLY
    if bandit:isCrawling() then
        Bandit.Say(bandit, "DEAD")
    end
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

    -- AVOIDANCE
    if #tasks == 0 and uTick % 4 == 0 then
        local avoidanceTasks = BanditUpdate.Avoidance(bandit)
        if #avoidanceTasks > 0 then
            for _, t in pairs(avoidanceTasks) do table.insert(tasks, t) end
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

        if not task.time then task.time = 1000 end
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

        if task.anim == "AimRifle" then
            bandit:setIsAiming(true)
        end

        Bandit.UpdateTask(bandit, task)

    elseif task.state == "COMPLETED" then

        if task.endurance then
            Bandit.UpdateEndurance(bandit, task.endurance)
        end

        if task.anim == "AimRifle" then
            bandit:setIsAiming(false)
        end
        

        local done = ZombieActions[task.action].onComplete(bandit, task)
        if done then 
            Bandit.RemoveTask(bandit)
        end

    end
end

function BanditUpdate.OnHitZombie(zombie)
    if zombie:getVariableBoolean("Bandit") then
        local bandit = zombie
        Bandit.Say(bandit, "HIT")
        if Bandit.IsSleeping(bandit) then
            local task = {action="Time", lock=true, anim="GetUp", time=150}
            Bandit.ClearTasks(bandit)
            Bandit.AddTask(bandit, task)
            Bandit.SetSleeping(bandit, false)
            Bandit.SetProgramStage(bandit, "Prepare")
        end
   
        -- friendly attacked by player turns to a bandit
        local attacker = bandit:getAttackedBy()
        if instanceof(attacker, "IsoPlayer") and not Bandit.IsHostile(bandit) and attacker:getDisplayName() ~= "Bob" and attacker:getDisplayName() ~= "Kate" then
           
            -- attacked friendly, but also other friendlies who were near to witness what player did, should become hostile
            local witnesses = BanditZombie.GetAllB()
            for id, witness in pairs(witnesses) do
                if not witness.brain.hostile then
                    local dist = math.sqrt(math.pow(attacker:getX() - witness.x, 2) + math.pow(attacker:getY() - witness.y, 2))
                    if dist < 12 then
                        local friendly = BanditZombie.GetInstanceById(witness.id)
                        if friendly:CanSee(attacker) then
                            Bandit.SetHostile(friendly, true)
                            Bandit.SetProgram(friendly, "Bandit", {})
                            
                            local brain = BanditBrain.Get(friendly)
                            local syncData = {}
                            syncData.id = brain.id
                            syncData.hostile = brain.hostile
                            syncData.program = brain.program
                            Bandit.ForceSyncPart(friendly, syncData)
                        end
                    end
                end
            end
        end
    end
end

function BanditUpdate.OnZombieDead(zombie)

    if zombie:getVariableBoolean("Bandit") then
   
        Bandit.Say(zombie, "DEAD", true)

        local player = getPlayer()
        local killer = zombie:getAttackedBy()
        if killer then
            if killer == player then
                local args = {}
                args.id = 0
                sendClientCommand(player, 'Commands', 'IncrementBanditKills', args)
                player:setZombieKills(player:getZombieKills() - 1)
            end
        end

        local id = BanditUtils.GetCharacterID(zombie)
        local brain = BanditBrain.Get(zombie)

        zombie:setUseless(false)
        zombie:setReanim(false)
        zombie:setVariable("Bandit", false)
        zombie:setPrimaryHandItem(nil)
        zombie:clearAttachedItems()
        zombie:resetEquippedHandsModels()

        local veh = zombie:getVehicle()
        if veh then
            veh:exit(zombie)
        end

        args = {}
        args.id = id
        sendClientCommand(player, 'Commands', 'BanditRemove', args)
        BanditBrain.Remove(zombie)
    end
end

Events.OnZombieUpdate.Add(BanditUpdate.OnBanditUpdate)
Events.OnHitZombie.Add(BanditUpdate.OnHitZombie)
Events.OnZombieDead.Add(BanditUpdate.OnZombieDead)
