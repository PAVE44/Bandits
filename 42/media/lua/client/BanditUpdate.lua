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

-- return coordinates of the optimal point to escape from zombies
local function GetEscapePoint(bandit, radius)
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)

    -- each segment is 8x8, the coordinates are for west/north corners
    local segments = {}
    table.insert(segments, {x=-3, y=-16, f=0, e=0}) -- N
    table.insert(segments, {x=5, y=-13, f=0, e=0}) -- NE
    table.insert(segments, {x=8, y=-4, f=0, e=0}) -- E
    table.insert(segments, {x=5, y=5, f=0, e=0}) -- SE
    table.insert(segments, {x=-3, y=8, f=0, e=0}) -- S
    table.insert(segments, {x=-11, y=5, f=0, e=0}) -- SW
    table.insert(segments, {x=-15, y=-4, f=0, e=0}) -- W
    table.insert(segments, {x=-11, y=-13, f=0, e=0}) -- W

    -- calulcate enemies in segments
    local chrs = BanditZombie.CacheLight
    for id, chr in pairs(chrs) do
        for i = 1, #segments do
            local sx1 = segments[i].x
            local sx2 = segments[i].x + 8
            local sy1 = segments[i].y
            local sy2 = segments[i].y + 8

            if chr.x >= sx1 and chr.x < sx2 and chr.y >= sy1 and chr.y < sy2 then
                if not chr.brain or (brain.clan ~= chr.brain.clan and (brain.hostile or chr.brain.hostile)) then
                    segment[i].e = segment[i].e + 1
                end
            end
        end
    end

    -- find the segment with the fewest enemies
    local minCnt = math.huge
    local segmentBest
    for i = 1, #segments do
        if segments[i].e < minCnt then
            minCnt = segments[i].e
            segmentBest = i
        end
    end

    -- return coords of center of the segment
    local lx = bx + segments[segmentBest].x + 3.5
    local ly = by + segments[segmentBest].y + 3.5
    local lz = bz

    return lx, ly, lz
end

-- hostilizes friendlies that witnessed player attacking a friendly
local function CheckFriendlyFire(bandit, attacker)

    if not attacker then return end

    -- attacking zombies is ok!
    if not bandit:getVariableBoolean("Bandit") then return end

    -- hostility against civilians (clan=0) is handled by other mods
    local brain = BanditBrain.Get(bandit)
    if brain.clan == 0 then return end

    -- atacking hostiles is ok!
    if brain.hostile then return end

    -- attacker is not a real player
    if not instanceof(attacker, "IsoPlayer") or attacker:isNPC() then return end

    -- attacking thief needs to be handled separately because of his pseudo-friendliness
    if brain.program.name == "Thief" then
        Bandit.SetHostile(bandit, true)
        Bandit.SetProgram(bandit, "Bandit", {})
        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.hostile = brain.hostile
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return
    end

    -- attacked friendly, but also other friendlies who were near to witness what player did, should become hostile
    local cache = BanditZombie.Cache
    local witnesses = BanditZombie.CacheLightB
    for id, witness in pairs(witnesses) do
        if not witness.brain.hostile then
            local dist = BanditUtils.DistTo(attacker:getX(), attacker:getY(), witness.x, witness.y)
            if dist < 12 then
                local friendly = cache[witness.id]
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

-- turns a zombie into a bandit
local function Banditize(zombie, brain)

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

-- turns bandit into a zombie
local function Zombify(bandit)
    bandit:setNoTeeth(false)
    bandit:setUseless(false)
    bandit:setVariable("Bandit", false)
    bandit:setVariable("BanditPrimary", "")
    bandit:setVariable("BanditSecondary", "")
    bandit:setWalkType("2")
    bandit:setVariable("BanditWalkType", "")
    bandit:setPrimaryHandItem(nil)
    bandit:setSecondaryHandItem(nil)
    bandit:resetEquippedHandsModels()
    bandit:clearAttachedItems()
    BanditBrain.Remove(bandit)
end

-- applies human look for a banditized zaombie
local function ApplyVisuals(bandit)
    local banditVisuals = bandit:getHumanVisual()
    if banditVisuals then
        local skin = banditVisuals:getSkinTexture()
        if skin then
            if string.sub(skin, 1, 10) ~= "FemaleBody" and string.sub(skin, 1, 8) ~= "MaleBody" then
                local brain = BanditBrain.Get(bandit)
                local id = brain.id

                if brain.skinTexture then
                    banditVisuals:setSkinTextureName(brain.skinTexture)
                end
                if brain.hairStyle then
                    banditVisuals:setHairModel(brain.hairStyle)
                end
                if brain.hairColor then
                    local color = ImmutableColor.new(brain.hairColor.r, brain.hairColor.g, brain.hairColor.b)
                    banditVisuals:setHairColor(color)
                end
                if brain.beardStyle then
                    banditVisuals:setBeardModel(brain.beardStyle)
                end
                if brain.beardColor then
                    local color = ImmutableColor.new(brain.beardColor.r, brain.beardColor.g, brain.beardColor.b)
                    banditVisuals:setBeardColor(color)
                end

                banditVisuals:randomDirt()
                banditVisuals:removeBlood()

                for i=1,BloodBodyPartType.MAX:index() do
                    local part = BloodBodyPartType.FromIndex(i-1)
                    banditVisuals:setBlood(part, 0)
                    banditVisuals:setDirt(part, 0)
                end

                local itemVisuals = bandit:getItemVisuals()
                for i=0, itemVisuals:size()-1 do
                    local item = itemVisuals:get(i)
                    if item then
                        for i=1,BloodBodyPartType.MAX:index() do
                            local part = BloodBodyPartType.FromIndex(i-1)
                            local hole = item:getHole(part)
                            if item:getHole(part) ~= 0 then
                                item:removeHole(i-1)
                            end
                            item:setBlood(part, 0)
                            item:setDirt(part, 0)
                        end
                        if item:getInventoryItem() then
                            item:setInventoryItem(nil)
                        end 
                    end
                end

                local toRemove = {}
                local bodyVisuals = banditVisuals:getBodyVisuals()
                local s = bodyVisuals:size()
                for i=0, bodyVisuals:size()-1 do
                    local item = bodyVisuals:get(i)
                    if item then
                        local itemType = item:getItemType()
                        if BanditUtils.ItemVisuals[itemType] then
                            table.insert(toRemove, itemType)
                        end
                    end
                end
                for k, v in pairs(toRemove) do
                    banditVisuals:removeBodyVisualFromItemType(v)
                end

                bandit:resetModelNextFrame()
                bandit:resetModel()
            end
        end
    end
end

-- updates bandit torches light
local function ManageTorch(bandit)
    if BanditCompatibility.GetGameVersion() < 42 and SandboxVars.Bandits.General_CarryTorches then
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
                local theta = bandit:getDirectionAngle() * math.pi * 0.00555555--/ 180
                for i = 0, 15 do
                    local lx = zx + math.floor(i * math.cos(theta) + 0.5)
                    local ly = zy + math.floor(i * math.sin(theta) + 0.5)
                    local lightSource = IsoLightSource.new(lx, ly, zz, colors.r-i * 0.05, colors.g-i * 0.05, colors.b-i * 0.05, i * 0.5, 20)
                    getCell():addLamppost(lightSource)
                    -- print (x2 .. ", " .. y2)
                end
            end
        end
    end
end

-- update bandit chainsaw sound
local function ManageChainsaw(bandit)
    if bandit:isPrimaryEquipped("AuthenticZClothing.Chainsaw") then
        local emitter = bandit:getEmitter()
        if not emitter:isPlaying("ChainsawIdle") then
            bandit:playSound("ChainsawIdle")
        end
    end
end

-- updates bandit being on fire
local function ManageOnFire(bandit)
    if bandit:isOnFire() then
        local sound 
        if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
        if not Bandit.HasTaskType(bandit, "Die") then
            Bandit.ClearTasks(bandit)
            local task = {action="Die", lock=true, anim="Die", fire=true, sound=sound, time=150}
            Bandit.AddTask(bandit, task)
        end
    end

    local cell = bandit:getCell()
    -- local brain = BanditBrain.Get(bandit)
    local nearFire = false
    for x=-2, 2 do
        for y=-2, 2 do
            local testSquare = cell:getGridSquare(bandit:getX() + x, bandit:getY() + y, bandit:getZ())
            if testSquare and testSquare:haveFire() then
                if not Bandit.HasActionTask(bandit) then
                    Bandit.ClearTasks(bandit)
                    local task = {action="Time", anim="Cough", time=200}
                    Bandit.AddTask(bandit, task)
                end
            end
        end
    end
end

-- reduces cooldown for bandit speech
local function ManageSpeechCooldown(bandit)
    local brain = BanditBrain.Get(bandit)
    if brain.speech and brain.speech > 0 then
        brain.speech = brain.speech - 0.01
        if brain.speech < 0 then brain.speech = 0 end
        -- BanditBrain.Update(bandit, brain)
    end
end

-- reduces cooldown for bandit sounds
local function ManageSoundCoolDown(bandit)
    local brain = BanditBrain.Get(bandit)
    if brain.sound and brain.sound > 0 then
        brain.sound = brain.sound - 0.001
        if brain.sound < 0 then brain.sound = 0 end
        -- BanditBrain.Update(bandit, brain)
    end
end

-- applies tweaks based on bandit action state
local function ManageActionState(bandit)
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

    --elseif asn == "turnalerted" then
    --    bandit:changeState(ZombieIdleState.instance())

    elseif asn == "getup" or asn == "getup-fromonback" or asn == "getup-fromonfront" or asn == "getup-fromsitting"
           or asn =="staggerback" or asn == "staggerback-knockeddown" then

        Bandit.ClearTasks(bandit)
        continue = false
        
    elseif asn == "turnalerted"  then
        -- bandits dont bite pls
        bandit:changeState(ZombieIdleState.instance())
        bandit:clearAggroList()
        bandit:setTarget(nil)
    elseif asn == "pathfind" then
        continue = false

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

    -- elseif asn == "walktoward-network" then

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

-- manages endurance regain tasks 
local function ManageEndurance(bandit)
    local tasks = {}
    if SandboxVars.Bandits.General_LimitedEndurance then
        local brain = BanditBrain.Get(bandit)
        if brain.endurance == 0 then
            if not Bandit.HasActionTask(bandit) then
                local endurance = 1
                if Bandit.IsDNA(bandit, "unfit") then
                    endurance = 0.75
                end
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

-- manages tasks related to bandit health
local function ManageHealth(bandit)
    local tasks = {}

    -- temporarily removed until bleeding bug in week one investigation is complete
    if false and SandboxVars.Bandits.General_BleedOut then
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

                if bandit:getHealth() < 0.4 and math.abs(id) % 3 == 1 then
                    Bandit.ClearTasks(bandit)
                    healing = true
                end

                if bandit:getHealth() < 0.3 and math.abs(id) % 2 == 1 then
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
            if brain.infection >= 100 then
                Bandit.ClearTasks(bandit)
                local task = {action="Zombify", anim="Faint", lock=true, time=200}
                table.insert(tasks, task)
            end
        end
    end
    return tasks
end

-- manages collisions with doors, windows, fences and other objects
local function ManageCollisions(bandit)
    local tasks = {}

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

        local cell = getCell()
        for _, s in pairs(sqs) do
            local square = cell:getGridSquare(s.x, s.y, s.z)
            if square then

                -- local safehouse = SafeHouse.isSafeHouse(square, nil, true)
                -- print ("SQ X:" .. square:getX() .. " Y:" .. square:getY())
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    local properties = object:getProperties()

                    if properties then
                        local weapons = Bandit.GetWeapons(bandit)
                        local lowFence = properties:Val("FenceTypeLow")
                        local hoppable = object:isHoppable()

                        -- LOW FENCE COLLISION
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
                            return tasks
                        end

                        -- HIGH FENCE COLLISION
                        local highFence = properties:Val("FenceTypeHigh")
                        if highFence and hoppable then
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
                            return tasks
                        end

                        -- WINDOW COLLISIONS
                        if instanceof(object, "IsoWindow") then
                            if bandit:isFacingObject(object, 0.5) then
                                if object:isBarricaded() then
                                    if SandboxVars.Bandits.General_RemoveBarricade and Bandit.Can(bandit, "unbarricade") and Bandit.Has(bandit, "crowbar") then
                                        local barricade = object:getBarricadeOnSameSquare()
                                        local fx, fy
                                        if barricade then
                                            if properties:Is(IsoFlagType.WindowN) then
                                                fx = barricade:getX()
                                                fy = barricade:getY() - 0.5
                                            else
                                                fx = barricade:getX() - 0.5
                                                fy = barricade:getY()
                                            end

                                        else
                                            barricade = object:getBarricadeOnOppositeSquare()
                                            if properties:Is(IsoFlagType.WindowN) then
                                                fx = barricade:getX()
                                                fy = barricade:getY() + 0.5
                                            else
                                                fx = barricade:getX() + 0.5
                                                fy = barricade:getY()
                                            end
                                        end
                                        
                                        if barricade:isMetal() or barricade:isMetalBar() then
                                            local task1 = {action="Equip", itemPrimary="Bandits.PropaneTorch"}
                                            table.insert(tasks, task1)
    
                                            local task2 = {action="UnbarricadeMetal", anim="BlowtorchHigh", time=500, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                            table.insert(tasks, task2)
                                            return tasks
                                        else
                                            local task1 = {action="Equip", itemPrimary="Base.Crowbar"}
                                            table.insert(tasks, task1)

                                            local task2 = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=300, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                            table.insert(tasks, task2)
                                            return tasks
                                        end
                                    end

                                elseif not object:IsOpen() and not object:isSmashed() then
                                    if SandboxVars.Bandits.General_SmashWindow and Bandit.Can(bandit, "smashWindow") then
                                        local task = {action="SmashWindow", anim="WindowSmash", time=25, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ()}
                                        table.insert(tasks, task)
                                    elseif not object:isPermaLocked() then
                                        local task = {action="OpenWindow", anim="WindowOpen", time=25, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ()}
                                        table.insert(tasks, task)
                                        return tasks
                                    end

                                elseif object:canClimbThrough(bandit) then
                                    ClimbThroughWindowState.instance():setParams(bandit, object)
                                    bandit:changeState(ClimbThroughWindowState.instance())
                                    bandit:setBumpType("ClimbWindow")
                                    return tasks
                                end
                            end

                        elseif false and (properties:Is(IsoFlagType.WindowW) or properties:Is(IsoFlagType.WindowN)) then
                            ClimbThroughWindowState.instance():setParams(bandit, object)
                            bandit:changeState(ClimbThroughWindowState.instance())
                            bandit:setBumpType("ClimbWindow")
                            return tasks
                        end

                        -- DOOR COLLISIONS
                        if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
                            if bandit:isFacingObject(object, 0.5) then

                                if object:isBarricaded() then
                                    if SandboxVars.Bandits.General_RemoveBarricade and Bandit.Can(bandit, "unbarricade") and Bandit.Has(bandit, "crowbar") then

                                        local barricade = object:getBarricadeOnSameSquare()
                                        local fx, fy
                                        if barricade then
                                            if properties:Is(IsoFlagType.doorN) then
                                                fx = barricade:getX()
                                                fy = barricade:getY() - 1
                                            else
                                                fx = barricade:getX() - 1
                                                fy = barricade:getY()
                                            end

                                        else
                                            barricade = object:getBarricadeOnOppositeSquare()
                                            if properties:Is(IsoFlagType.doorN) then
                                                fx = barricade:getX()
                                                fy = barricade:getY() + 1
                                            else
                                                fx = barricade:getX() + 1
                                                fy = barricade:getY()
                                            end
                                        end
                                        local task1 = {action="Equip", itemPrimary="Base.Crowbar"}
                                        table.insert(tasks, task1)

                                        local task2 = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=230, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                        table.insert(tasks, task2)
                                        return tasks
                                    end

                                elseif (object:isLockedByKey() and bandit:getCurrentSquare():Is(IsoFlagType.exterior)) or object:getProperties():Is("forceLocked") then
                                    if SandboxVars.Bandits.General_DestroyDoor and Bandit.Can(bandit, "breakDoor") then
                                        -- Bandit.ClearTasks(bandit)

                                        local task1 = {action="Equip", itemPrimary=weapons.melee}
                                        table.insert(tasks, task1)

                                        local task2 = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), sound=object:getThumpSound(), time=80}
                                        table.insert(tasks, task2)
                                        return tasks
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
                                        sendClientCommand(getPlayer(), 'Commands', 'OpenDoor', args)

                                        -- Get the square of the object
                                        local square = getPlayer():getSquare()

                                        -- Recalculate vision blocked for the surrounding tiles in a r-tile radius
                                        local radius = 5
                                        for dx = -radius, radius do
                                            for dy = -radius, radius do
                                                -- if dx ~= 0 and dy ~= 0 then
                                                    local surroundingSquare = cell:getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
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
                            return tasks
                        end

                        -- THUMPABLE COLLISIONS
                        if instanceof(object, "IsoThumpable") and not properties:Val("FenceTypeLow") then
                            if SandboxVars.Bandits.General_DestroyThumpable and Bandit.Can(bandit, "breakObjects") then
                                local isWallTo = bandit:getSquare():isSomethingTo(object:getSquare())
                                if not isWallTo then
                                    Bandit.ClearTasks(bandit)

                                    local task = {action="Equip", itemPrimary=weapons.melee}
                                    table.insert(tasks, task)

                                    local task = {action="FaceLocation", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)

                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), sound=object:getThumpSound(), time=80}
                                    table.insert(tasks, task)
                                    return tasks
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return tasks
end

-- manages bandit self-preservation tasks
local function ManagePreservation(bandit)
    local tasks = {}
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)

    -- counters to determine the balance of power in a given radius
    local friendlies = 0
    local enemies = 0
    local radius = 9

    local potentialEnemyList = BanditZombie.CacheLight
    for id, potentialEnemy in pairs(potentialEnemyList) do
        -- Calculate distance between bandit and the enemy character
        local distance = BanditUtils.DistToManhattan(potentialEnemy.x, potentialEnemy.y, bx, by)
        if distance <= radius and bz == potentialEnemy.z then
            -- Calculate angle of the point relative to the circle's center
            
            if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
                enemies = enemies + 1
            else
                friendlies = friendlies + 1
            end
        end
    end

    if enemies > friendlies + 3 then
        local tx, ty, tz = GetEscapePoint(bandit, 10)
        -- bandit:addLineChatElement("evade to")
        local task = BanditUtils.GetMoveTask(0.01, tx, ty, tz, "Run", 30, false)
        task.panic = true
        task.lock = true
        table.insert(tasks, task)
    end 

    -- print ("BALANCE: F: " .. friendlies .. " E: " .. enemies)
    return tasks
end

-- manages melee and weapon combat
local function ManageCombat(bandit)

    if bandit:isCrawling() then return {} end 
    if Bandit.IsSleeping(bandit) then return {} end
    -- if bandit:getActionStateName() == "bumped" then return {} end

    local tasks = {}
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

                local dist = BanditUtils.DistTo(zx, zy, px, py)
                if dist < bestDist and pz == zz then

                    local spottedScore = CalcSpottedScore(potentialEnemy, dist)

                    local isWallTo = bandit:getSquare():isSomethingTo(potentialEnemy:getSquare())
                    if not isWallTo and spottedScore > 0.32 then
                        bestDist = dist

                        --determine if bandit will be in combat mode
                        if weapons.melee and Bandit.Can(bandit, "melee") then
                            local itemMelee = BanditCompatibility.InstanceItem(weapons.melee)
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
                        local pistolRange = SandboxVars.Bandits.General_PistolRange - 1
                        local rifleRange = SandboxVars.Bandits.General_RifleRange - 1
                        if Bandit.IsDNA(bandit, "blind") then
                            pistolRange = pistolRange - 4
                            rifleRange = rifleRange - 7
                        end
                        if Bandit.Can(bandit, "shoot") and weapons.primary and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < rifleRange then 
                            enemyCharacter = potentialEnemy
                            firing = true
                        elseif Bandit.Can(bandit, "shoot") and weapons.secondary and (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < pistolRange then
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
    local potentialEnemyList = BanditZombie.CacheLight
    local cache = BanditZombie.Cache
    for id, potentialEnemy in pairs(potentialEnemyList) do

        if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
        
            -- quick manhattan check for performance boost
            if BanditUtils.DistToManhattan(potentialEnemy.x, potentialEnemy.y, zx, zy) < 36 then
            
                -- load real instance here
                local potentialEnemy = cache[id]
                if bandit:CanSee(potentialEnemy) then -- FIXME: add visibility cone
                    local potentialEnemySquare = potentialEnemy:getSquare()
                    if potentialEnemySquare then
                        local lightLevel = potentialEnemySquare:getLightLevel(0)
                        local isWallTo = bandit:getSquare():isSomethingTo(potentialEnemySquare)
                        if not isWallTo and lightLevel > 0.31 then

                            local dist = BanditUtils.DistTo(zx, zy, potentialEnemy:getX(), potentialEnemy:getY())
                            if dist < 25 then
                            
                                if dist < 6 then 
                                    enemies = enemies + 1 
                                end
                                if dist < bestDist then

                                    bestDist = dist
                                    
                                    --determine if bandit will be in combat mode
                                    if Bandit.Can(bandit, "melee") and weapons.melee and zz == potentialEnemy:getZ() then
                                        local itemMelee = BanditCompatibility.InstanceItem(weapons.melee)
                                        
                                        -- the bandit may need to swich to melee weapon so we need to switch earier
                                        -- before target is in range
                                        local minRange = itemMelee:getMaxRange()
                                        if dist <= minRange + 0.4 then
                                            enemyCharacter = potentialEnemy
                                            local asn = enemyCharacter:getActionStateName()
                                            if dist < 0.7 and not enemyCharacter:isProne() and asn ~= "onground" and asn ~= "climbfence" and asn ~= "bumped" and asn ~= "getup" then
                                                shove = true
                                            else
                                                combat = true
                                            end
                                        end
                                    end

                                    --determine if bandit will be in shooting mode
                                    local pistolRange = SandboxVars.Bandits.General_PistolRange - 4
                                    local rifleRange = SandboxVars.Bandits.General_RifleRange - 6
                                    if Bandit.IsDNA(bandit, "blind") then
                                        pistolRange = pistolRange - 4
                                        rifleRange = rifleRange - 7
                                    end
                                    if Bandit.Can(bandit, "shoot") and weapons.primary and  (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < rifleRange then 
                                        enemyCharacter = potentialEnemy
                                        firing = true
                                    elseif Bandit.Can(bandit, "shoot") and weapons.secondary and  (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < pistolRange then
                                        enemyCharacter = potentialEnemy
                                        firing = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            if math.abs(potentialEnemy.x - zx) < 8 and math.abs(potentialEnemy.y - zy) < 8 then
                friendlies = friendlies + 1
            end
        end
    end

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
                local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                for _, t in pairs(stasks) do table.insert(tasks, t) end
            end

            if bandit:isFacingObject(enemyCharacter, 0.5) then
                local eid = BanditUtils.GetCharacterID(enemyCharacter)
                local task = {action="Hit", time=65, endurance=-0.03, weapon=weapons.melee, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
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
                    local slots = {"primary", "secondary"}
                    for _, slot in pairs(slots) do
                        if weapons[slot].name and (weapons[slot].bulletsLeft > 0 or weapons[slot].magCount > 0) then
                            if not bandit:isPrimaryEquipped(weapons[slot].name) then
                                Bandit.Say(bandit, "SPOTTED")

                                local stasks = BanditPrograms.Weapon.Switch(bandit, weapons[slot].name)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end
                            end

                            if not Bandit.IsAim(bandit) then
                                local stasks = BanditPrograms.Weapon.Aim(bandit, enemyCharacter, slot)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end
                            end

                            if weapons[slot].bulletsLeft > 0 then
                                local stasks = BanditPrograms.Weapon.Shoot(bandit, enemyCharacter, slot)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end

                            elseif weapons[slot].magCount > 0 then
                                Bandit.Say(bandit, "RELOADING")

                                local stasks = BanditPrograms.Weapon.Reload(bandit, slot)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end
                            end
                            -- Bandit.SetWeapons(bandit, weapons)
                            break
                        end
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

-- manages multiplayer social distance hack
local function ManageSocialDistance(bandit)

    -- Friendlies will always tend to approach the player
    -- this is because they switch to lunge mode by game engine automatically.
    -- The only way to workaround it, is to set the useless flag to true.  
    -- so here we detect player proximity and we switch the program to CompaningGuard,
    -- which in practice forces the useless flag.

    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)
    if brain.program.name == "Companion" then
        local playerList = BanditPlayer.GetPlayers()
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player then
                local px, py, pz = player:getX(), player:getY(), player:getZ()
                local veh = player:getVehicle()
                local asn = bandit:getActionStateName()
                local dist = BanditUtils.DistTo(bx, by, px, py)
                
                if bandit:getZ() == player:getZ() and dist < 3 and not veh and asn ~= "onground" then

                    local closestZombie = BanditUtils.GetClosestZombieLocation(player)
                    local closestBandit = BanditUtils.GetClosestZombieLocation(player)
            
                    if closestZombie.dist > 10 and closestBandit.dist > 10 then
                        if Bandit.GetProgram(bandit).name ~= "CompanionGuard" then
                            Bandit.SetProgram(bandit, "CompanionGuard", {})
                        end
                    end
                end
            end
        end
    end
end

-- manages zombie behavior towards bandits
local function UpdateZombies(zombie)
    
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
        if phi then
            zombie:setPrimaryHandItem(nil)
        end

        local shi = zombie:getSecondaryHandItem()
        if shi then
            zombie:setSecondaryHandItem(nil)
        end

        local target = zombie:getTarget()
        if target and instanceof(target, "IsoZombie") then
            -- shutting down zombie attack on bandit because it will crash the game
            -- zombie:setVariable("BanditTarget", true)
            zombie:setVariable("ZombieBiteDone", true)
            zombie:setNoTeeth(true)
            
        else
            -- zombie:setVariable("BanditTarget", false)
            zombie:setNoTeeth(false)
        end

        if target and (not target:isAlive() or not zombie:CanSee(target)) then
            zombie:setTarget(nil)
        end

        local emitter = zombie:getEmitter()
        if emitter:isPlaying("ChainsawIdle") then
            emitter:stopSoundByName("ChainsawIdle")
        end
        
        -- zed coords
        local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()

        -- fetch the RAM-based lightweight zombie cache
        local enemy = BanditUtils.GetClosestBanditLocationFast(zombie)

        -- deal with the found if it is in range
        if enemy.dist < 30 then

            -- fetch visible players
            -- if player is closer than the bandit, dont do anything, game engine will manage attack on player by itself
            local player = BanditUtils.GetClosestPlayerLocation(zombie, true)
            if player.dist < enemy.dist then return end

            -- local asn = zombie:getActionStateName()

            local bandit = BanditZombie.Cache[enemy.id]

            -- the enemy is far, proceed with standard movement
            if enemy.dist > 6 then 
                if zombie:CanSee(bandit) then
                    zombie:pathToCharacter(bandit)
                end

            elseif enemy.dist >= 0.59  then
                local player = getPlayer()
                if zombie:CanSee(bandit) and zombie:CanSee(player) then
                    
                    -- we need to use   spotted function to activate the zombie, otherwise setTarget does not work
                    -- unfortunatelly spotted function only works for players, so we need to use it in this context,
                    -- and then retarget on bandit

                    if BanditCompatibility.GetGameVersion() >= 42 then
                        zombie:pathToCharacter(bandit)
                    end
                    zombie:spotted(player, true)
                    zombie:setTarget(bandit)
                    
                    -- probably not needed
                    zombie:setAttackedBy(bandit)
                end

            -- the enemy is in bite range, proceed with the attack
            elseif enemy.dist < 0.59 and enemy.z == zz then

                local isWallTo = zombie:getSquare():isSomethingTo(bandit:getSquare())
                if not isWallTo then

                    -- if the zombie is facing the bandit attack may proceed, otherwise turn zombie towards the target
                    if zombie:isFacingObject(bandit, 0.3) then

                        -- detect the number of closeby zombies attacking the bandit at the same time
                        local attackingZombiesNumber = 0
                        local attackingZombieList = BanditZombie.CacheLightZ
                        for id, attackingZombie in pairs(attackingZombieList) do
                            local distManhattan = BanditUtils.DistToManhattan(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                            if distManhattan < 1 then -- the manhattan distance for 0.6 euclidean distance will range from 0.6 to ~0.8485
                                local dist = BanditUtils.DistTo(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                                if dist < 0.6 then
                                    attackingZombiesNumber = attackingZombiesNumber + 1
                                    
                                    -- if we know there is at least 3, then it's good enough and we can break for the sake of performance
                                    if attackingZombiesNumber > 2 then break end
                                end
                            end
                        end

                        -- depending on the number of attacking zombies, initiate either a dragown or just a single bite attack 
                        if attackingZombiesNumber > 2 then
                            local sound
                            if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
                            if not Bandit.HasTaskType(bandit, "Die") then
                                Bandit.ClearTasks(bandit)
                                local task = {action="Die", lock=true, anim="Die", sound=sound, time=300}
                                Bandit.AddTask(bandit, task)
                                
                            end
                            return
                        end

                        zombie:setBumpType("Bite")

                        if ZombRand(4) == 1 then
                            bandit:playSound("ZombieScratch")
                        else
                            bandit:playSound("ZombieBite")
                        end

                        -- this item determines the strenght of the zombie attack on bandit
                        local teeth = BanditCompatibility.InstanceItem("Base.RollingPin")

                        BanditCompatibility.Splash(bandit, teeth, zombie)

                        bandit:setHitFromBehind(zombie:isBehind(bandit))

                        if instanceof(bandit, "IsoZombie") then
                            bandit:setHitAngle(zombie:getForwardDirection())
                            bandit:setPlayerAttackPosition(bandit:testDotSide(zombie))
                        end

                        bandit:Hit(teeth, zombie, 1.01, false, 1, false)
                        Bandit.UpdateInfection(bandit, 0.001)
                        -- bandit:setReanimateTimer(0.1)
                        if bandit:getHealth() <= 0 then
                            bandit:setHealth(0)
                            bandit:clearAttachedItems()
                            -- bandit:changeState(ZombieOnGroundState.instance())
                            bandit:setAttackedBy(zombie)
                            -- bandit:becomeCorpse()
                        end
                    
                    else
                        zombie:faceThisObject(bandit)
                    end
                end
            end
        end
    end
end

local function ProcessTask(bandit, task)
    local ts = getTimestampMs()
    if not task.action then return end
    if not task.state then task.state = "NEW" end

    if task.state == "NEW" then
        
        if not task.time then task.time = 1000 end

        if task.action ~= "Shoot" and task.action ~= "Aim" then
            Bandit.SetAim(bandit, false)
        end

        if task.action ~= "Move" and task.action ~= "GoTo" then
            if Bandit.IsMoving(bandit) then
                Bandit.SetMoving(bandit, false)
            end
        end

        if task.sound then
            local play = true
            if task.soundDistMax then
                local player = getPlayer()
                local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), player:getX(), player:getY())
                if dist > task.soundDistMax then
                    play = false
                end
            end

            if play then
                local emitter = bandit:getEmitter()
                if not emitter:isPlaying(task.sound) then
                    emitter:playSound(task.sound)
                end
            end
            -- bandit:playSound(task.sound)
        end

        if task.anim then
            bandit:setBumpType(task.anim)
        end
        
        local done = ZombieActions[task.action].onStart(bandit, task)

        if done then 
            task.state = "WORKING"
            --Bandit.UpdateTask(bandit, task)
        end

    elseif task.state == "WORKING" then

        -- normalize time speed
        local decrement = 1 / ((getAverageFPS() + 0.5) * 0.01666667)
        task.time = task.time - decrement

        local done = ZombieActions[task.action].onWorking(bandit, task)
        if done or task.time <= 0 then 
            task.state = "COMPLETED"
        end
        -- Bandit.UpdateTask(bandit, task)

    elseif task.state == "COMPLETED" then

        if task.sound then
            local emitter = bandit:getEmitter()
            if not emitter:isPlaying(task.sound) then
                bandit:playSound(task.sound)
            end
        end
        
        if task.endurance then
            Bandit.UpdateEndurance(bandit, task.endurance)
        end

        local done = ZombieActions[task.action].onComplete(bandit, task)

        if done then 
            Bandit.RemoveTask(bandit)
        end
    end
    
    local elapsed = getTimestampMs() - ts
end

local function GenerateTask(bandit, uTick)
    local tasks = {}
    
    -- MANAGE BANDIT ENDURANCE LOSS
    local enduranceTasks = ManageEndurance(bandit)
    if #enduranceTasks > 0 then
        for _, t in pairs(enduranceTasks) do table.insert(tasks, t) end
    end
    
    -- MANAGE BLEEDING AND HEALING
    if #tasks == 0 then
        local healingTasks = ManageHealth(bandit)
        if #healingTasks > 0 then
            for _, t in pairs(healingTasks) do table.insert(tasks, t) end
        end
    end

    -- AVOIDANCE
    if #tasks == 0 and uTick % 4 == 0 then
        local avoidanceTasks = ManagePreservation(bandit)
        if #avoidanceTasks > 0 then
            for _, t in pairs(avoidanceTasks) do table.insert(tasks, t) end
        end
    end

    -- MANAGE MELEE / SHOOTING TASKS
    if #tasks == 0  then
        local combatTasks = ManageCombat(bandit)
        if #combatTasks > 0 then
            for _, t in pairs(combatTasks) do table.insert(tasks, t) end
        end
    end

    -- MANAGE COLLISION TASKS
    if #tasks == 0  and uTick % 2 then
        local colissionTasks = ManageCollisions(bandit)
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
        local brain = BanditBrain.Get(bandit)
        for _, task in pairs(tasks) do
            table.insert(brain.tasks, task)
        end
        -- BanditBrain.Update(zombie, brain)
    end
end

-- main function to handle bandits
local uTick = 0
local function OnBanditUpdate(zombie)

    local ts = getTimestampMs()
    
    if isServer() then return end

    if not Bandit.Engine then return end

    if uTick == 16 then uTick = 0 end
    uTick = uTick + 1

    if BanditCompatibility.IsReanimatedForGrappleOnly(zombie) then return end

    local id = BanditUtils.GetCharacterID(zombie)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    -- local cell = getCell()
    -- local world = getWorld()
    -- local gamemode = world:getGameMode()
    local brain = BanditBrain.Get(zombie)
    
    -- BANDITIZE ZOMBIES SPAWNED AND ENQUEUED BY SERVER
    -- OR ZOMBIFY IF QUEUE HAS BEEN REMOVED
    local gmd = GetBanditModData()
    if gmd.Queue then
        if gmd.Queue[id] then -- and id ~= 0
            if not zombie:getVariableBoolean("Bandit") then
                brain = gmd.Queue[id]
                Banditize(zombie, brain)
            end
        else
            if zombie:getVariableBoolean("Bandit") then
                Zombify(zombie)
            end
        end
    end
    
    -- if true then return end 
    -- ZOMBIES VS BANDITS
    -- Using adaptive performance here.
    -- The more zombies in player's cell, the less frequent updates.
    -- Up to 100 zombies, update every tick, 
    -- 800+ zombies, update every 1/16 tick. 
    -- local zcnt = BanditZombie.GetAllCnt()
    -- if zcnt > 600 then zcnt = 600 end
    -- local skip = math.floor(zcnt / 50) + 1
    if uTick % 2 == 0 then
        -- print (skip)
        UpdateZombies(zombie)
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    -- BANDIT UPDATE AFTER THIS LINE
    ------------------------------------------------------------------------------------------------------------------------------------
    if not zombie:getVariableBoolean("Bandit") then return end
    if not brain then return end
    
    -- distant bandits are not updated by this mod so they need to be set useless
    -- to prevent game updating them as if they were zombies
    if BanditZombie.CacheLightB[id] then 
        zombie:setUseless(false)
    else
        zombie:setUseless(true)
        return
    end
    
    local bandit = zombie

    -- IF TELEPORTING THEN THERE IS NO SENSE IN PROCEEDING
    if bandit:isTeleporting() then
        return
    end

    -- WALKTYPE
    -- we do it this way, if walktype get overwritten by game engine we force our animations
    zombie:setWalkType(zombie:getVariableString("BanditWalkType"))

    -- NO ZOMBIE SOUNDS
    Bandit.SurpressZombieSounds(bandit)

    -- CANNIBALS
    if not brain.eatBody then
        bandit:setEatBodyTarget(nil, false)
    end
    
    -- ADJUST HUMAN VISUALS
    ApplyVisuals(bandit)

    -- MANAGE BANDIT TORCH
    ManageTorch(bandit)

    -- MANAGE BANDIT CHAINSAW
    ManageChainsaw(bandit)

    -- MANAGE BANDIT BEING ON FIRE
    if uTick == 2 then
        -- ManageOnFire(bandit)
    end

    -- MANAGE BANDIT SPEECH COOLDOWN
    ManageSpeechCooldown(bandit)

    -- MANAGE BANDIT SOUND COOLDOWN
    ManageSoundCoolDown(bandit)

    -- ACTION STATE TWEAKS
    local continue = ManageActionState(bandit)
    if not continue then return end
    
    -- COMPANION SOCIAL DISTANCE HACK
    ManageSocialDistance(bandit)

    -- CRAWLERS SCREAM OCASSINALLY
    if bandit:isCrawling() then
        Bandit.Say(bandit, "DEAD")
    end
    
    GenerateTask(bandit, uTick)

    local task = Bandit.GetTask(bandit)
    if task then
        ProcessTask(bandit, task)
    end

    local elapsed = getTimestampMs() - ts
end

local function OnHitZombie(zombie, attacker, bodyPartType, handWeapon)
    if zombie:getVariableBoolean("Bandit") then
        local bandit = zombie

        Bandit.AddVisualDamage(bandit, handWeapon)
        Bandit.ClearTasks(bandit)
        Bandit.Say(bandit, "HIT", true)
        if Bandit.IsSleeping(bandit) then
            local task = {action="Time", lock=true, anim="GetUp", time=150}
            Bandit.ClearTasks(bandit)
            Bandit.AddTask(bandit, task)
            Bandit.SetSleeping(bandit, false)
            Bandit.SetProgramStage(bandit, "Prepare")
        end
   
        if ZombRand(11) == 5 then
            CheckFriendlyFire(bandit, attacker)
        end
        
    end
end

local function OnZombieDead(zombie)

    if not zombie:getVariableBoolean("Bandit") then return end
        
    local bandit = zombie

    -- hostility against civilians (clan=0) is handled by other mods
    local brain = BanditBrain.Get(bandit)
    if brain.clan == 0 then return end

    Bandit.Say(bandit, "DEAD", true)

    local attacker = bandit:getAttackedBy()
    CheckFriendlyFire(bandit, attacker)

    local player = getPlayer()
    local killer = bandit:getAttackedBy()
    if killer then
        if killer == player then
            local args = {}
            args.id = 0
            sendClientCommand(player, 'Commands', 'IncrementBanditKills', args)
            player:setZombieKills(player:getZombieKills() - 1)
        end
    end

    local id = BanditUtils.GetCharacterID(bandit)
    local brain = BanditBrain.Get(bandit)

    bandit:setUseless(false)
    bandit:setReanim(false)
    bandit:setVariable("Bandit", false)
    bandit:setPrimaryHandItem(nil)
    bandit:clearAttachedItems()
    bandit:resetEquippedHandsModels()
    -- bandit:getInventory():clear()

    local veh = bandit:getVehicle()
    if veh then
        veh:exit(bandit)
    end

    args = {}
    args.id = id
    sendClientCommand(player, 'Commands', 'BanditRemove', args)
    BanditBrain.Remove(bandit)
end

Events.OnZombieUpdate.Add(OnBanditUpdate)
Events.OnHitZombie.Add(OnHitZombie)
Events.OnZombieDead.Add(OnZombieDead)
