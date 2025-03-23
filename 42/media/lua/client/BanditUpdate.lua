local function predicateRemovable(item)
    if not item:getModData().preserve and not instanceof(item, "Clothing") then
        return true 
    end
end

local function CalcSpottedScore(player, dist)
    if not instanceof(player, "IsoPlayer") then return end

    local square = player:getSquare()
    local spottedScore = square:getLightLevel(0)

    if player:isRunning() then spottedScore = spottedScore + 0.1 end
    if player:isSprinting() then spottedScore = spottedScore + 0.12 end

    if player:isSneaking() then
        spottedScore = spottedScore - 0.1
        local objects = square:getObjects()
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            local props = object and object:getProperties()
            if props and props:Is(IsoFlagType.vegitation) and props:Is(IsoFlagType.canBeCut) then
                spottedScore = spottedScore - 0.15
                break
            end
        end
    end

    -- distance-based adjustment
    if dist <= 8 then
        spottedScore = spottedScore + (0.65 - (dist * 0.075))
    end

    return spottedScore
end

-- return coordinates of the optimal point to escape from zombies
local function GetEscapePoint(bandit, radius)
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)

    -- Predefine segment offsets
    local segments = {
        {x=-3, y=-16, e=0}, -- N
        {x=5, y=-13, e=0},  -- NE
        {x=8, y=-4, e=0},   -- E
        {x=5, y=5, e=0},    -- SE
        {x=-3, y=8, e=0},   -- S
        {x=-11, y=5, e=0},  -- SW
        {x=-15, y=-4, e=0}, -- W
        {x=-11, y=-13, e=0} -- NW
    }

    -- Calculate enemies in segments
    for _, chr in pairs(BanditZombie.CacheLight) do
        local cx, cy, cbrain = chr.x, chr.y, chr.brain
        for i = 1, #segments do
            local seg = segments[i]
            if cx >= seg.x and cx < seg.x + 8 and cy >= seg.y and cy < seg.y + 8 then
                if not cbrain or (brain.clan ~= cbrain.clan and (brain.hostile or cbrain.hostile)) then
                    seg.e = seg.e + 1
                end
            end
        end
    end

    -- Find the segment with the fewest enemies
    local segmentBest, minCnt = 1, math.huge
    for i = 1, #segments do
        local segE = segments[i].e
        if segE < minCnt then
            minCnt = segE
            segmentBest = i
        end
    end

    -- Return coordinates of the center of the best segment
    local bestSegment = segments[segmentBest]
    return bx + bestSegment.x + 3.5, by + bestSegment.y + 3.5, bz
end

-- checks if the line of fire is clear from friendlies
local function IsShotClear (shooter, enemy)

    local cell = getCell()

    local x0 = math.floor(shooter:getX())
    local y0 = math.floor(shooter:getY())
    local x1 = math.floor(enemy:getX())
    local y1 = math.floor(enemy:getY())
    local z = enemy:getZ()

    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = (x0 < x1) and 1 or -1
    local sy = (y0 < y1) and 1 or -1
    local err = dx - dy

    local cx, cy, cz = x0, y0, z

    local brainShooter = BanditBrain.Get(shooter)

    local i = 0
    while true do

        -- last iteration
        local list = {}
        if cx == x1 and cy == y1 then
            for x = -2, 2 do
                for y = -2, 2 do
                    table.insert(list, {x = cx + x, y = cy + y, z=cz})
                end
            end
        else
            table.insert(list, {x=cx, y=cy, z=cz})
        end

        for _, c in pairs(list) do
            local square = cell:getGridSquare(c.x, c.y, c.z)
            if i > 1 and square then

                local chrs = square:getMovingObjects()
                for i=0, chrs:size()-1 do
                    local chr = chrs:get(i)
                    if instanceof(chr, "IsoPlayer") and not brainShooter.hostile then
                        -- shooter:addLineChatElement("PLAYER IN LINE", 0.8, 0.8, 0.1)
                        return false
                    elseif instanceof(chr, "IsoZombie") then
                        local brainEnemy = BanditBrain.Get(chr)
                        if brainEnemy and brainEnemy.clan and brainShooter.clan == brainEnemy.clan and (not brainShooter.hostile or brainEnemy.hostile) then
                            -- shooter:addLineChatElement("FRIENDLY IN LINE", 0.8, 0.8, 0.1)
                            return false
                        end
                    end
                end
            end
        end

        if cx == x1 and cy == y1 then break end
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            cx = cx + sx
        end
        if e2 < dx then
            err = err + dx
            cy = cy + sy
        end
        i = i + 1
    end

    return true
end

-- hostilizes friendlies that witnessed player attacking a friendly
local function CheckFriendlyFire(bandit, attacker)
    if not attacker then return end

    -- attacking zombies is ok!
    if not bandit:getVariableBoolean("Bandit") then return end

    -- hostility against civilians (clan=0) is handled by other mods
    local brain = BanditBrain.Get(bandit)
    if not brain then return end
    if brain.clan == 0 then return end

    -- attacking hostiles is ok!
    if brain.hostile then return end

    -- attacker is not a real player
    if not instanceof(attacker, "IsoPlayer") or attacker:isNPC() then return end

    -- attacking thief needs to be handled separately because of his pseudo-friendliness
    if brain.program.name == "Thief" then
        Bandit.SetHostile(bandit, true)
        Bandit.SetProgram(bandit, "Bandit", {})

        local syncData = { id = brain.id, hostile = true, program = {name="Bandit", stage="Prepare"} }
        Bandit.ForceSyncPart(bandit, syncData)
        return
    end

    -- attacked friendly, but also other friendlies who were near to witness what player did, should become hostile
    local attackerX, attackerY = attacker:getX(), attacker:getY()
    local cache, witnesses = BanditZombie.Cache, BanditZombie.CacheLightB

    for _, witness in pairs(witnesses) do
        if not witness.brain.hostile then
            local dx, dy = witness.x - attackerX, witness.y - attackerY
            if dx * dx + dy * dy < 144 then -- squared distance check (avoids sqrt call)
                local friendly = cache[witness.id]
                if friendly and friendly:CanSee(attacker) then
                    Bandit.SetHostile(friendly, true)
                    Bandit.SetProgram(friendly, "Bandit", {})

                    local fBrain = BanditBrain.Get(friendly)
                    local syncData = { id = fBrain.id, hostile = true, program = {name="Bandit", stage="Prepare"} }
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
local function ApplyVisuals(bandit, brain)
    local banditVisuals = bandit:getHumanVisual()
    if not banditVisuals then return end

    local skin = banditVisuals:getSkinTexture()
    if not skin or skin:find("^FemaleBody") or skin:find("^MaleBody") then return end

    local itemVisuals = bandit:getItemVisuals()

    if brain.cid then

        bandit:setHealth(brain.health)

        banditVisuals:setSkinTextureName(BanditCustom.GetSkinTexture(brain.female, brain.skin))
        banditVisuals:setHairModel(BanditCustom.GetHairStyle(brain.female, brain.hairType)) 

        if not bandit:isFemale() then
            banditVisuals:setBeardModel(BanditCustom.GetBeardStyle(brain.female, brain.beardType)) 
        end

        local hairColor = BanditCustom.GetHairColor(brain.hairColor)
        local icolor = ImmutableColor.new(hairColor.r, hairColor.g, hairColor.b)
        banditVisuals:setHairColor(icolor) 
        banditVisuals:setBeardColor(icolor) 

        for bodyLocation, itemType in pairs(brain.clothing) do
            local item = BanditCompatibility.InstanceItem(itemType)
            local clothingItem = item:getClothingItem()
            local itemVisual = banditVisuals:addClothingItem(itemVisuals, clothingItem)
        end

        for _, slot in pairs({"primary", "secondary", "melee"}) do

            if brain.weapons[slot].name then
                local weapon = BanditCompatibility.InstanceItem(brain.weapons[slot].name)

                if weapon then
                    weapon = BanditWeapons.Modify(weapon, brain)

                    local attachmentType = weapon:getAttachmentType()
                    
                    for _, def in pairs(ISHotbarAttachDefinition) do
                        if def.type == "HolsterRight" or def.type == "Back" or def.type == "SmallBeltLeft" then
                            if def.attachments then
                                for k, v in pairs(def.attachments) do
                                    if k == attachmentType then
                                        bandit:setAttachedItem(v, weapon)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if brain.bag and brain.bag.name then
            local item = BanditCompatibility.InstanceItem(brain.bag.name)
            local clothingItem = item:getClothingItem()
            local itemVisual = banditVisuals:addClothingItem(itemVisuals, clothingItem)
            -- bandit:setWornItem(item:canBeEquipped(), item)
        end
        
    else
        if brain.skinTexture then 
            banditVisuals:setSkinTextureName(brain.skinTexture)
        end
        if brain.hairStyle then 
            banditVisuals:setHairModel(brain.hairStyle) 
        end
        if brain.hairColor then
            banditVisuals:setHairColor(ImmutableColor.new(brain.hairColor.r, brain.hairColor.g, brain.hairColor.b))
        end
        if brain.beardStyle then 
            banditVisuals:setBeardModel(brain.beardStyle)
        end
        if brain.beardColor then
            banditVisuals:setBeardColor(ImmutableColor.new(brain.beardColor.r, brain.beardColor.g, brain.beardColor.b))
        end
    end

    banditVisuals:randomDirt()
    banditVisuals:removeBlood()

    -- Cleanup blood/dirt
    local maxIndex = BloodBodyPartType.MAX:index()
    for i = 0, maxIndex - 1 do
        local part = BloodBodyPartType.FromIndex(i)
        banditVisuals:setBlood(part, 0)
        banditVisuals:setDirt(part, 0)
    end

    -- Cleanup item visuals
    
    for i = 0, itemVisuals:size() - 1 do
        local item = itemVisuals:get(i)
        if item then
            for j = 0, maxIndex - 1 do
                local part = BloodBodyPartType.FromIndex(j)
                item:removeHole(j)
                item:setBlood(part, 0)
                item:setDirt(part, 0)
            end
            item:setInventoryItem(nil)
        end
    end

    -- Remove bandit-specific body visuals
    local bodyVisuals = banditVisuals:getBodyVisuals()
    local toRemove, toRemoveCount = {}, 0
    for i = 0, bodyVisuals:size() - 1 do
        local item = bodyVisuals:get(i)
        if item and BanditUtils.ItemVisuals[item:getItemType()] then
            toRemoveCount = toRemoveCount + 1
            toRemove[toRemoveCount] = item:getItemType()
        end
    end
    for i = 1, toRemoveCount do
        banditVisuals:removeBodyVisualFromItemType(toRemove[i])
    end

    --[[
    local clothing = BanditCustom.GetClothing("bandit1")

    for i=1, #clothing do
        local item = BanditCompatibility.InstanceItem(clothing[i])
        local clothingItem = item:getClothingItem()
        local itemVisual = banditVisuals:addClothingItem(itemVisuals, clothingItem)
    end]]

    -- Reset model to apply changes
    bandit:resetModelNextFrame()
    bandit:resetModel()

    Bandit.UpdateItemsToSpawnAtDeath(bandit)
end

-- updates bandit torches light
local function ManageTorch(bandit)
    if not SandboxVars.Bandits.General_CarryTorches then return end

    local zx, zy, zz = bandit:getX(), bandit:getY(), bandit:getZ()
    local vehicle = bandit:getVehicle()
    local cell = getCell()

    if vehicle then return end
    
    local colors = {r = 1, g = 1, b = 0.8}

    local md = bandit:getModData()
    if not md.torch then md.torch = {} end

    if bandit:isProne() then
        --[[
        local lightSource = IsoLightSource.new(zx, zy, zz, colors.r, colors.g, colors.b, 2, 2)
        if lightSource then
            getCell():addLamppost(lightSource)
        end]]
    else
        local theta = bandit:getDirectionAngle() * 0.0174533  -- Convert degrees to radians
        for i = 2, 14 do
            local fadeFactor = i * 0.05
            local lx = math.floor(zx + (i * math.cos(theta)))
            local ly = math.floor(zy + (i * math.sin(theta)))
            local lz = zz + 32

            if md.torch[i] then
                md.torch[i]:setActive(false)
                -- print ("REM: x: ".. md.torch[i]:getX() .. " y:" .. md.torch[i]:getY() .. " z:" .. md.torch[i]:getZ() .. " i:" .. i)
                cell:removeLamppost(md.torch[i])
            end

            -- print ("ADD x: ".. lx .. " y:" .. ly .. " z:" .. lz .. " i:" .. i)
            ls = IsoLightSource.new(lx, ly, zz, colors.r, colors.g, colors.b, i * 0.5, 20)
            md.torch[i] = ls
            cell:addLamppost(md.torch[i])
            
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
        if not Bandit.HasTaskType(bandit, "Die") then
            Bandit.ClearTasks(bandit)
            Bandit.AddTask(bandit, {action="Die", lock=true, anim="Die", fire=true, time=250})
        end
        return
    end

    local cell = bandit:getCell()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()

    if Bandit.HasActionTask(bandit) then return end

    for x = -2, 2 do
        for y = -2, 2 do
            local testSquare = cell:getGridSquare(bx + x, by + y, bz)
            if testSquare and testSquare:haveFire() then
                Bandit.ClearTasks(bandit)
                Bandit.AddTask(bandit, {action="Time", anim="Cough", time=200})
                return
            end
        end
    end
end

-- reduces cooldown for bandit speech
local function ManageSpeechCooldown(brain)
    if brain.speech and brain.speech > 0 then
        brain.speech = brain.speech - 0.01
        if brain.speech < 0 then brain.speech = 0 end
        -- BanditBrain.Update(bandit, brain)
    end
end

-- reduces cooldown for bandit sounds
local function ManageSoundCoolDown(brain)
    if brain.sound and brain.sound > 0 then
        brain.sound = brain.sound - 0.001
        if brain.sound < 0 then brain.sound = 0 end
        -- BanditBrain.Update(bandit, brain)
    end
end

-- applies tweaks based on bandit action state
local function ManageActionState(bandit)
    local asn = bandit:getActionStateName()
    
    -- Hashmap for O(1) lookup of actions
    local actions = {
        ["onground"] = function()
            if not bandit:getVehicle() then
                if bandit:isUnderVehicle() then
                    local bx, by = bandit:getX(), bandit:getY()
                    bandit:setX(bx + 0.5)
                    bandit:setY(by + 0.5)
                end
                Bandit.ClearTasks(bandit)
                return false
            end
            return true
        end,

        ["turnalerted"] = function()
            bandit:changeState(ZombieIdleState.instance())
            bandit:clearAggroList()
            bandit:setTarget(nil)
            return true
        end,

        ["pathfind"] = function() return false end,

        ["lunge"] = function()
            bandit:setUseless(true)
            bandit:clearAggroList()
            bandit:setTarget(nil)
            return true
        end,

        ["getup"] = function() Bandit.ClearTasks(bandit); return false end,
        ["getup-fromonback"] = function() Bandit.ClearTasks(bandit); return false end,
        ["getup-fromonfront"] = function() Bandit.ClearTasks(bandit); return false end,
        ["getup-fromsitting"] = function() Bandit.ClearTasks(bandit); return false end,
        ["staggerback"] = function() Bandit.ClearTasks(bandit); return false end,
        ["staggerback-knockeddown"] = function() Bandit.ClearTasks(bandit); return false end,
    }

    -- Execute the corresponding function if found in the hashmap
    if actions[asn] then
        return actions[asn]()
    end

    -- Default behavior (for undefined states)
    bandit:setTarget(nil)
    bandit:setTargetSeenTime(0)
    bandit:setUseless(getWorld():getGameMode() ~= "Multiplayer" or Bandit.IsForceStationary(bandit))

    return true
end

-- manages endurance regain tasks 
local function ManageEndurance(bandit)
    if not SandboxVars.Bandits.General_LimitedEndurance then
        return {}
    end

    local brain = BanditBrain.Get(bandit)
    if brain.endurance > 0 or Bandit.HasActionTask(bandit) then
        return {}
    end

    brain.endurance = 1

    local exhaustionTasks = {}
    local exhaustionTask = { action = "Time", anim = "Exhausted", time = 200, lock = true }

    for i = 1, 5 do
        exhaustionTasks[i] = exhaustionTask
    end

    return exhaustionTasks
end

-- manages tasks related to bandit health
local function ManageHealth(bandit)
    local tasks = {}

    -- temporarily removed until bleeding bug in week one investigation is complete
    if SandboxVars.Bandits.General_BleedOut then
        local healing = false
        local health = bandit:getHealth()
        if health < 0.7 then
            local zx, zy = bandit:getX(), bandit:getY()

            -- purely visual so random allowed
            if ZombRand(16) == 0 then
                local bx = zx - 0.5 + ZombRandFloat(0.1, 0.9)
                local by = zy - 0.5 + ZombRandFloat(0.1, 0.9)
                bandit:getChunk():addBloodSplat(bx, by, 0, ZombRand(20))
            end
            bandit:setHealth(health - 0.00005)
        end
    end

    if SandboxVars.Bandits.General_Infection then
        local brain = BanditBrain.Get(bandit)
        if brain.infection and brain.infection > 0 then
            -- print ("INFECTION: " .. brain.infection)
            Bandit.UpdateInfection(bandit, 0.001)
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

    if Bandit.HasActionTask(bandit) then return {} end

    if not bandit:isCollidedThisFrame() then return {} end

    bandit:getPathFindBehavior2():cancel()
    bandit:setPath2(nil)

    local weapons = Bandit.GetWeapons(bandit)

    local fd = bandit:getForwardDirection()
    local fdx = math.floor(fd:getX() + 0.5)
    local fdy = math.floor(fd:getY() + 0.5)

    local sqs = {}
    table.insert(sqs, {x = math.floor(bandit:getX()), y = math.floor(bandit:getY()), z = bandit:getZ()})
    table.insert(sqs, {x = math.floor(bandit:getX()) + fdx, y=math.floor(bandit:getY()) + fdy, z = bandit:getZ()})

    local cell = getCell()
    for _, s in pairs(sqs) do
        local square = cell:getGridSquare(s.x, s.y, s.z)
        if square then

            -- local safehouse = SafeHouse.isSafeHouse(square, nil, true)
            -- print ("SQ X:" .. square:getX() .. " Y:" .. square:getY())
            local objects = square:getObjects()
            for i = 0, objects:size() - 1 do
                local object = objects:get(i)
                local properties = object:getProperties()

                if properties then
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
                                local barricade = object:getBarricadeOnSameSquare()
                                if not barricade then barricade = object:getBarricadeOnOppositeSquare() end
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

                                if SandboxVars.Bandits.General_RemoveBarricade and Bandit.HasExpertise(bandit, Bandit.Expertise.Breaker) then
                                    if barricade:isMetal() or barricade:isMetalBar() then
                                        if not bandit:isPrimaryEquipped("Bandits.PropaneTorch") then
                                            local stasks = BanditPrograms.Weapon.Switch(bandit, "Bandits.PropaneTorch")
                                            for _, t in pairs(stasks) do table.insert(tasks, t) end
                                        end
                                        local task = {action="UnbarricadeMetal", anim="BlowtorchHigh", time=500, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                        table.insert(tasks, task)
                                        return tasks
                                    else
                                        anim = "RemoveBarricadeCrowbarMid"
                                        local planks = barricade:getNumPlanks()
                                        if planks == 2 or planks == 4 then
                                            anim = "RemoveBarricadeCrowbarHigh"
                                        end
                                        if not bandit:isPrimaryEquipped("Base.Crowbar") then
                                            local stasks = BanditPrograms.Weapon.Switch(bandit, "Base.Crowbar")
                                            for _, t in pairs(stasks) do table.insert(tasks, t) end
                                        end
                                        local task = {action="Unbarricade", anim=anim, time=300, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                        table.insert(tasks, task)
                                        return tasks
                                    end
                                else
                                    if not bandit:isPrimaryEquipped(weapons.melee) then
                                        local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                        for _, t in pairs(stasks) do table.insert(tasks, t) end
                                    end
                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                    return tasks
                                end

                            elseif not object:IsOpen() and not object:isSmashed() then
                                if true then
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
                                local barricade = object:getBarricadeOnSameSquare()
                                local sameSide = barricade:getSquare():getX() == bandit:getSquare():getX() and barricade:getSquare():getY() == bandit:getSquare():getY()
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

                                if SandboxVars.Bandits.General_RemoveBarricade and Bandit.HasExpertise(bandit, Bandit.Expertise.Breaker) and sameSide then
                                    anim = "RemoveBarricadeCrowbarMid"
                                    local planks = barricade:getNumPlanks()
                                    if planks == 2 or planks == 4 then
                                        anim = "RemoveBarricadeCrowbarHigh"
                                    end
                                    if not bandit:isPrimaryEquipped("Base.Crowbar") then
                                        local stasks = BanditPrograms.Weapon.Switch(bandit, "Base.Crowbar")
                                        for _, t in pairs(stasks) do table.insert(tasks, t) end
                                    end
                                    local task = {action="Unbarricade", anim=anim, time=300, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                    return tasks
                                else
                                    if not bandit:isPrimaryEquipped(weapons.melee) then
                                        local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                        for _, t in pairs(stasks) do table.insert(tasks, t) end
                                    end
                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                    return tasks
                                end

                            elseif (object:isLockedByKey() and bandit:getCurrentSquare():Is(IsoFlagType.exterior)) or object:getProperties():Is("forceLocked") then
                                if bandit:isPrimaryEquipped(weapons.melee) then
                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                else
                                    local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                    for _, t in pairs(stasks) do table.insert(tasks, t) end
                                    return tasks
                                end

                            elseif not object:IsOpen() then
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
                                    sendClientCommand(getSpecificPlayer(0), 'Commands', 'OpenDoor', args)

                                    -- Get the square of the object
                                    local square = getSpecificPlayer(0):getSquare()

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
                    end

                    -- THUMPABLE COLLISIONS
                    if instanceof(object, "IsoThumpable") and not properties:Val("FenceTypeLow") then
                        local isWallTo = bandit:getSquare():isSomethingTo(object:getSquare())
                        if not isWallTo then
                            if bandit:isPrimaryEquipped(weapons.melee) then
                                local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), soundEnd=object:getThumpSound(), time=80}
                                table.insert(tasks, task)
                            else
                                local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end
                                return tasks
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

    local friendlies, enemies = 0, 0
    local radiusSquared = 81 -- 9^2

    local potentialEnemyList = BanditZombie.CacheLight
    for _, potentialEnemy in pairs(potentialEnemyList) do
        if bz == potentialEnemy.z then  -- First check avoids unnecessary calculations
            local dx, dy = potentialEnemy.x - bx, potentialEnemy.y - by
            if dx * dx + dy * dy <= radiusSquared then  -- Faster than Manhattan distance
                local enemyBrain = potentialEnemy.brain
                if not enemyBrain or (brain.clan ~= enemyBrain.clan and (brain.hostile or enemyBrain.hostile)) then
                    enemies = enemies + 1
                else
                    friendlies = friendlies + 1
                end
            end
        end
    end

    if enemies > friendlies + 3 then
        local tx, ty, tz = GetEscapePoint(bandit, 10)
        local task = BanditUtils.GetMoveTask(0.01, tx, ty, tz, "Run", 30, false)
        task.panic = true
        task.lock = true
        table.insert(tasks, task)
    end 

    return tasks
end

-- manages bandit self-preservation tasks
local function ManagePreservation2(bandit)
    local tasks = {}
    if not Bandit.HasMoveTask(bandit) then
        local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
        local brain = BanditBrain.Get(bandit)

        local friendlies, enemies = 0, 0
        local sx, sy = 0, 0
        local radiusSquared = 49 

        local potentialEnemyList = BanditZombie.CacheLight
        for _, potentialEnemy in pairs(potentialEnemyList) do
            if bz == potentialEnemy.z then  -- First check avoids unnecessary calculations
                local dx, dy, dd = potentialEnemy.x - bx, potentialEnemy.y - by, potentialEnemy.d
                if dx * dx + dy * dy <= radiusSquared then  -- Faster than Manhattan distance
                    local enemyBrain = potentialEnemy.brain
                    if not enemyBrain or (brain.clan ~= enemyBrain.clan and (brain.hostile or enemyBrain.hostile)) then
                        local rad = math.rad(dd)
                        sx = sx + math.cos(rad)
                        sy = sy + math.sin(rad)
                        enemies = enemies + 1
                    else
                        friendlies = friendlies + 1
                    end
                end
            end
        end

        if enemies > 3 then
            
            local mrad = math.atan2(sy, sx)
            local mdeg = math.deg(mrad)
            bandit:addLineChatElement("escape " ..mdeg, 0.8, 0.8, 0.1)

            local l = 7
            local nbx = bx + l * math.cos(mrad)
            local nby = by + l * math.sin(mrad)
            local nbz = bz

            local task = BanditUtils.GetMoveTask(0.01, nbx, nby, nbz, "Run", 30, false)
            task.panic = true
            task.lock = true
            table.insert(tasks, task)
        else
            bandit:addLineChatElement("E:" .. enemies, 0.8, 0.8, 0.1)
        end 
    end

    return tasks
end

local function ManagePreservation3(bandit)
    local tasks = {}
    if not Bandit.HasMoveTask(bandit) then
        local angles = {}
        local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
        local potentialEnemyList = BanditZombie.CacheLight
        for _, potentialEnemy in pairs(potentialEnemyList) do
            if bz == potentialEnemy.z then  -- First check avoids unnecessary calculations
                local dx = potentialEnemy.x - bx
                local dy = potentialEnemy.y - by
                local angle = math.deg(math.atan2(dy, dx)) -- Convert radians to degrees
                table.insert(angles, angle)
            end
        end

        local max_gap = 0
        local best_angle
        
        for i = 1, #angles do
            local next_index = (i % #angles) + 1
            local gap = (angles[next_index] - angles[i]) % 360
            
            if gap > max_gap then
                max_gap = gap
                best_angle = (angles[i] + gap / 2) % 360 -- Middle of the largest gap
                if best_angle > 180 then
                    best_angle = best_angle - 360 -- Keep angles in range [-180, 180]
                end
            end
        end

        if best_angle then
        end
    end
end

-- manages melee and weapon combat
local function ManageCombat(bandit)

    if bandit:isCrawling() then return {} end 
    if Bandit.IsSleeping(bandit) then return {} end
    -- if bandit:getActionStateName() == "bumped" then return {} end

    local tasks = {}
    local zx, zy, zz = bandit:getX(), bandit:getY(), bandit:getZ()
    local health = bandit:getHealth()
    local brain = BanditBrain.Get(bandit)
    local weapons = brain.weapons
    local isOutOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local isBareHands = Bandit.IsBareHands(bandit)

    local bestDist = 40
    local enemyCharacter, switchTo
    local healing, reload, resupply = false, false, false
    local combat, switch, firing, shove, escape = false, false, false, false, false
    local maxRangeMelee, maxRangePistol, maxRangeRifle
    local friendlies, enemies = 0, 0
    local sx, sy = 0, 0

    -- THIS GOVERNS LOW-PRIORITY TASKS
    if not Bandit.HasActionTask(bandit) then
        
        -- HEALING FLAG         
        if health < 0.4 then
            healing = true
        end

        -- PEACFUL RELOAD FLAG
        for _, slot in pairs({"primary", "secondary"}) do
            if weapons[slot].name and bandit:isPrimaryEquipped(weapons[slot].name) then
                if (weapons[slot].type == "mag" and weapons[slot].bulletsLeft <= 0 and weapons[slot].magCount > 0) or
                   (weapons[slot].type == "nomag" and weapons[slot].bulletsLeft < weapons[slot].ammoSize and weapons[slot].ammoCount > 0) or 
                    weapons[slot].racked == false then 
                    
                    reload = true
                end
            end
        end

        -- RESUPPLY FLAG
        if isBareHands or isOutOfAmmo then
            resupply = true
        end
    end

    -- SWITCH WEAPON DISTANCES
    local meleeDist = 4.5
    local meleeDistPlayer = 5
    local rifleDist = 5
    local escapeDist = 5

    -- COMBAT AGAIST PLAYERS 
    if Bandit.IsHostile(bandit) then
        local playerList = BanditPlayer.GetPlayers()

        for i=0, playerList:size()-1 do
            local potentialEnemy = playerList:get(i)
            if potentialEnemy and bandit:CanSee(potentialEnemy) and not potentialEnemy:isBehind(bandit) and (instanceof(potentialEnemy, "IsoPlayer") and not BanditPlayer.IsGhost(potentialEnemy)) then
                local px, py, pz = potentialEnemy:getX(), potentialEnemy:getY(), potentialEnemy:getZ()
                -- local dist = BanditUtils.DistTo(zx, zy, px, py)
                local dist = math.sqrt(((zx - px) * (zx - px)) + ((zy - py) * (zy - py))) -- no function call for performance
                if dist < bestDist and pz == zz then
                    local spottedScore = CalcSpottedScore(potentialEnemy, dist)
                    if not bandit:getSquare():isSomethingTo(potentialEnemy:getSquare()) and spottedScore > 0.32 then
                        bestDist, enemyCharacter = dist, potentialEnemy

                        --reset action flags, only one can be true
                        combat, switch, firing, shove, escape = false, false, false, false, false

                        --determine if bandit will be in combat mode
                        if weapons.melee then
                            if not maxRangeMelee then
                                maxRangeMelee = BanditCompatibility.InstanceItem(weapons.melee):getMaxRange()
                            end
                            local prone = potentialEnemy:isProne()
                            
                            if dist <= meleeDistPlayer then 
                                if bandit:isPrimaryEquipped(weapons.melee) then
                                    if dist <= maxRangeMelee then
                                        local asn = enemyCharacter:getActionStateName()
                                        shove = dist < 0.6 and not prone and asn ~= "onground" and asn ~= "sitonground" and asn ~= "climbfence" and asn ~= "bumped"
                                        combat = not shove
                                    end
                                else
                                    switch = true
                                    switchTo = weapons.melee
                                end
                            end
                        end

                        --determine if bandit will be in shooting mode
                        if not isOutOfAmmo and dist > meleeDist + 1 then
                            if weapons.primary.name and weapons.primary.bulletsLeft > 0 then
                                if not maxRangeRifle then
                                    local item = BanditCompatibility.InstanceItem(weapons.primary.name)
                                    item = BanditWeapons.Modify(item, brain)
                                    maxRangeRifle = item:getMaxRange()
                                    
                                end
                                if dist < maxRangeRifle then
                                    if bandit:isPrimaryEquipped(weapons.primary.name) then
                                        if dist < maxRangeRifle + rifleDist and IsShotClear(bandit, potentialEnemy) then
                                            firing = true
                                        end
                                    elseif not reload then
                                        Bandit.Say(bandit, "SPOTTED")
                                        switch = true
                                        switchTo = weapons.primary.name
                                    end
                                end
                            elseif weapons.secondary.name and weapons.secondary.bulletsLeft > 0 then
                                if not maxRangePistol then
                                    local item = BanditCompatibility.InstanceItem(weapons.secondary.name)
                                    item = BanditWeapons.Modify(item, brain)
                                    maxRangePistol = item:getMaxRange()
                                end
                                if dist < maxRangePistol then
                                    if bandit:isPrimaryEquipped(weapons.secondary.name) then
                                        if dist < maxRangePistol + rifleDist and IsShotClear(bandit, potentialEnemy) then
                                            firing = true
                                        end
                                    elseif not reload then
                                        Bandit.Say(bandit, "SPOTTED")
                                        switch = true
                                        switchTo = weapons.secondary.name
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- COMBAT AGAINST ZOMBIES AND BANDITS FROM OTHER CLAN
    local cache, potentialEnemyList = BanditZombie.Cache, BanditZombie.CacheLight
    for id, potentialEnemy in pairs(potentialEnemyList) do

        -- quick manhattan check for performance boost
        -- if BanditUtils.DistToManhattan(potentialEnemy.x, potentialEnemy.y, zx, zy) < 36 then
        if math.abs(potentialEnemy.x - zx) + math.abs(potentialEnemy.y - zy) < 36 then

            if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
            
                -- load real instance here
                local potentialEnemy = cache[id]
                if bandit:CanSee(potentialEnemy) then -- FIXME: add visibility cone
                    local pesq = potentialEnemy:getSquare()
                    if pesq and pesq:getLightLevel(0) > 0.31 and not bandit:getSquare():isSomethingTo(pesq) then
                        local px, py, pz = potentialEnemy:getX(), potentialEnemy:getY(), potentialEnemy:getZ()
                        -- local dist = BanditUtils.DistTo(zx, zy, potentialEnemy:getX(), potentialEnemy:getY())
                        local dist = math.sqrt(((zx - px) * (zx - px)) + ((zy - py) * (zy - py)))
                        if dist < 40 then
                            if dist < escapeDist then
                                local rad = math.rad(potentialEnemy:getDirectionAngle())
                                sx = sx + math.cos(rad)
                                sy = sy + math.sin(rad)
                                enemies = enemies + 1
                            end
                            if dist < bestDist then
                                bestDist, enemyCharacter = dist, potentialEnemy

                                --reset action flags, only one can be true
                                combat, switch, firing, shove, escape = false, false, false, false, false
                                
                                --determine if bandit will be in combat mode
                                if weapons.melee and zz == pz then
                                    if dist <= meleeDist then
                                        if bandit:isPrimaryEquipped(weapons.melee) then

                                            if not maxRangeMelee then
                                                maxRangeMelee = BanditCompatibility.InstanceItem(weapons.melee):getMaxRange()
                                            end
                                            local prone = potentialEnemy:isProne()
                                            local fix = 0.4
                                            if prone then fix = -0.2 end

                                            if dist <= maxRangeMelee + fix then
                                                local asn = enemyCharacter:getActionStateName()
                                                shove = dist < 0.8 and not enemyCharacter:isProne() and asn ~= "onground" and asn ~= "climbfence" and asn ~= "bumped" and asn ~= "getup" and asn ~= "falldown"
                                                combat = not shove
                                            end
                                        else
                                            switch = true
                                            switchTo = weapons.melee
                                        end
                                    end
                                end

                                --determine if bandit will be in shooting mode
                                if not isOutOfAmmo and dist > meleeDist + 1 then
                                    if weapons.primary.name and weapons.primary.bulletsLeft > 0 then
                                        if not maxRangeRifle then
                                            maxRangeRifle = BanditCompatibility.InstanceItem(weapons.primary.name):getMaxRange()
                                        end
                                        if dist < maxRangeRifle then
                                            if bandit:isPrimaryEquipped(weapons.primary.name) then
                                                if dist < maxRangeRifle + rifleDist and IsShotClear(bandit, potentialEnemy) then
                                                    firing = true
                                                end
                                            elseif not reload then
                                                Bandit.Say(bandit, "SPOTTED")
                                                switch = true
                                                switchTo = weapons.primary.name
                                            end
                                        end
                                    elseif weapons.secondary.name and weapons.secondary.bulletsLeft > 0 then
                                        if not maxRangePistol then
                                            maxRangePistol = BanditCompatibility.InstanceItem(weapons.secondary.name):getMaxRange()
                                        end
                                        if dist < maxRangePistol then
                                            if bandit:isPrimaryEquipped(weapons.secondary.name) then
                                                if dist < maxRangePistol + rifleDist and IsShotClear(bandit, potentialEnemy) then
                                                    firing = true
                                                end
                                            elseif not reload then
                                                Bandit.Say(bandit, "SPOTTED")
                                                switch = true
                                                switchTo = weapons.secondary.name
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local dist = ((zx - potentialEnemy.x) * (zx - potentialEnemy.x)) + ((zy - potentialEnemy.y) * (zy - potentialEnemy.y))
                if dist < 36 then
                    friendlies = friendlies + 1
                end
            end
        end
    end

    if enemies > friendlies + 2 then
        if not Bandit.HasMoveTask(bandit) then
            -- bandit:addLineChatElement("Escape", 0.8, 0.8, 0.1)
            print ("E: " .. enemies .. " F: " .. friendlies)
            Bandit.ClearTasks(bandit)
            local mrad = math.atan2(sy, sx)
            local mdeg = math.deg(mrad)
            local l = 20
            local nbx = zx + (l * math.cos(mrad))
            local nby = zy + (l * math.sin(mrad))
            local nbz = zz
            local task = BanditUtils.GetMoveTask(0.01, nbx, nby, nbz, "Run", 12, false)
            task.time = 400
            task.lock = true
            task.backwards = false
            table.insert(tasks, task)
        end
    --[[elseif enemies >= 2 then
        if not Bandit.HasMoveTask(bandit) and not Bandit.HasTaskType(bandit, "Shove") and not Bandit.HasTaskType(bandit, "Hit") then
            Bandit.ClearTasks(bandit)
            bandit:addLineChatElement("Slow", 0.8, 0.8, 0.1)
            local mrad = math.atan2(sy, sx)
            local mdeg = math.deg(mrad)
            local l = 2
            local nbx = zx + (l * math.cos(mrad))
            local nby = zy + (l * math.sin(mrad))
            local nbz = zz
            local task = BanditUtils.GetMoveTask(0.01, nbx, nby, nbz, "WalkBwdAim", 20, false)
            task.backwards = true
            table.insert(tasks, task)

            --[[
            local eid = BanditUtils.GetCharacterID(enemyCharacter)
            local task = {action="Shove", anim="Shove", sound="AttackShove", time=60, endurance=-0.05, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
            -- local task = {action="Hit", time=65, endurance=-0.03, weapon=weapons.melee, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
            table.insert(tasks, task)]]
        --end

    elseif shove then
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

    elseif switch then
        if not Bandit.HasActionTask(bandit) and enemyCharacter:isAlive() then
            Bandit.ClearTasks(bandit)
            local stasks = BanditPrograms.Weapon.Switch(bandit, switchTo)
            for _, t in pairs(stasks) do table.insert(tasks, t) end
        end

    elseif combat then
        if not Bandit.HasTaskType(bandit, "Hit") and not Bandit.HasTaskType(bandit, "Shove") and not Bandit.HasTaskType(bandit, "Equip") and not Bandit.HasTaskType(bandit, "Unequip") and enemyCharacter:isAlive() then
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

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

    elseif healing then
        if not Bandit.HasTaskType(bandit, "Bandage") then
            local task = {action="Bandage"}
            table.insert(tasks, task)
        end

    elseif firing then
        if not Bandit.HasTaskType(bandit, "Shoot") and not Bandit.HasTaskType(bandit, "Aim") and not Bandit.HasTaskType(bandit, "Rack") 
           and not Bandit.HasTaskType(bandit, "Equip") and not Bandit.HasTaskType(bandit, "Unequip")
           and not Bandit.HasTaskType(bandit, "Load") and not Bandit.HasTaskType(bandit, "Unload")
           and not Bandit.HasTaskType(bandit, "Rack") then

            Bandit.ClearTasks(bandit)
            if enemyCharacter:isAlive() then
                
                local veh = enemyCharacter:getVehicle()
                if veh then Bandit.Say(bandit, "CAR") end

                if bandit:isFacingObject(enemyCharacter, 0.1) then
                    for _, slot in pairs({"primary", "secondary"}) do
                        
                        if weapons[slot].name then

                            if weapons[slot].bulletsLeft > 0 then
                                if not weapons[slot].racked then
                                        local stasks = BanditPrograms.Weapon.Rack(bandit, slot)
                                        for _, t in pairs(stasks) do table.insert(tasks, t) end

                                elseif not Bandit.IsAim(bandit) then
                                    local stasks = BanditPrograms.Weapon.Aim(bandit, enemyCharacter, slot)
                                    for _, t in pairs(stasks) do table.insert(tasks, t) end

                                elseif weapons[slot].bulletsLeft > 0 then
                                    local stasks = BanditPrograms.Weapon.Shoot(bandit, enemyCharacter, slot)
                                    for _, t in pairs(stasks) do table.insert(tasks, t) end

                                end

                                break

                            elseif (weapons[slot].type == "mag"  and weapons[slot].magCount > 0) or
                                (weapons[slot].type == "nomag" and weapons[slot].ammoCount > 0) then

                                Bandit.Say(bandit, "RELOADING")

                                local stasks = BanditPrograms.Weapon.Reload(bandit, slot)
                                for _, t in pairs(stasks) do table.insert(tasks, t) end

                                break
                            end
                            
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
    elseif reload then
        if not Bandit.HasActionTask(bandit) then
            for _, slot in pairs({"primary", "secondary"}) do
                if weapons[slot].name and bandit:isPrimaryEquipped(weapons[slot].name) then
                    Bandit.ClearTasks(bandit)
                    Bandit.Say(bandit, "RELOADING")
                    local stasks = BanditPrograms.Weapon.Reload(bandit, slot)
                    for _, t in pairs(stasks) do table.insert(tasks, t) end
                end
            end
        end
    elseif resupply then
        if not Bandit.HasTask(bandit) then
            local stasks = BanditPrograms.Weapon.Resupply(bandit, slot)
            for _, t in pairs(stasks) do table.insert(tasks, t) end
        end
    end

    return tasks
end

-- manages multiplayer social distance hack
local function ManageSocialDistance(bandit)
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)
    
    if brain.program.name ~= "Companion" then return end

    local playerList = BanditPlayer.GetPlayers()

    -- Iterate through players
    for i = 0, playerList:size() - 1 do
        local player = playerList:get(i)
        if player then
            -- Cache player's position and vehicle status
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local veh = player:getVehicle()
            local asn = bandit:getActionStateName()
            
            -- Calculate distance only once and check if conditions are met
            -- local dist = BanditUtils.DistToManhattan(bx, by, px, py)
            local dist = math.sqrt(((bx - px) * (bx - px)) + ((by - py) * (by - py)))
            if bz == pz and dist < 3 and not veh and asn ~= "onground" then
                -- Cache closest zombie and bandit locations
                local closestZombie = BanditUtils.GetClosestZombieLocationFast(player)
                local closestBandit = BanditUtils.GetClosestBanditLocationFast(player)

                -- If both distances are greater than 10, switch to "CompanionGuard" program
                if closestZombie.dist > 10 and closestBandit.dist > 10 then
                    if Bandit.GetProgram(bandit).name ~= "CompanionGuard" then
                        Bandit.SetProgram(bandit, "CompanionGuard", {})
                    end
                end
            end
        end
    end
end

-- table of bandits being attacked by zombies
local biteTab = {}

-- manages zombie behavior towards bandits
local function UpdateZombies(zombie)

    zombie:setVariable("NoLungeAttack", true)
    if zombie:getVariableBoolean("Bandit") then return end
    if zombie:isProne() then return end

    local toRemove = {}    
    for id, tab in pairs(biteTab) do
        if tab.tick >= 60 then
            local attackId = zombie:getModData().attackId
            if attackId and tab.attackId == attackId and zombie:getBumpType() == "Bite" and zombie:getActionStateName() == "bumped" then 

                local asn = zombie:getActionStateName()
                local bandit = tab.bandit
                if ZombRand(4) == 1 then
                    zombie:playSound("ZombieBite")
                else
                    zombie:playSound("ZombieScratch")
                end

                local teeth = BanditCompatibility.InstanceItem("Base.RollingPin")
                BanditCompatibility.Splash(bandit, teeth, zombie)
                bandit:setHitFromBehind(zombie:isBehind(bandit))
        
                if instanceof(bandit, "IsoZombie") then
                    bandit:setHitAngle(zombie:getForwardDirection())
                    bandit:setPlayerAttackPosition(bandit:testDotSide(zombie))
                end
        
                bandit:Hit(teeth, zombie, 1.01, false, 1, false)
                Bandit.UpdateInfection(bandit, 0.001)
                if bandit:getHealth() <= 0 then
                    bandit:setHealth(0)
                    bandit:clearAttachedItems()
                    bandit:setAttackedBy(zombie)
                end
                table.insert(toRemove, id)
            end
        end
        tab.tick = tab.tick + 1
    end

    for _, v in pairs(toRemove) do
        biteTab[v] = nil
        zombie:getModData().attackId = nil
    end

    local asn = zombie:getActionStateName()
    if asn == "bumped" or asn == "onground" or asn == "climbfence" or asn == "getup" then
        return
    end

    -- Recycle brain and handle useless state
    BanditBrain.Remove(zombie)
    if zombie:isUseless() then
        zombie:setUseless(false)
    end

    -- Handle primary and secondary hand items
    local phi = zombie:getPrimaryHandItem()
    if phi then zombie:setPrimaryHandItem(nil) end
    local shi = zombie:getSecondaryHandItem()
    if shi then zombie:setSecondaryHandItem(nil) end

    -- Handle zombie target and teeth state
    local target = zombie:getTarget()
    if target and instanceof(target, "IsoZombie") then
        zombie:setVariable("ZombieBiteDone", true)
        zombie:setNoTeeth(true)
    else
        zombie:setNoTeeth(false)
    end

    -- Clear invalid target
    if target and (not target:isAlive() or not zombie:CanSee(target)) then
        zombie:setTarget(nil)
    end

    -- Stop sound if playing
    local emitter = zombie:getEmitter()
    if emitter:isPlaying("ChainsawIdle") then
        emitter:stopSoundByName("ChainsawIdle")
    end

    -- Fetch zombie coordinates and closest bandit location
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local enemy = BanditUtils.GetClosestBanditLocationFast(zombie)

    -- If bandit is in range, proceed
    if enemy.dist < 30 then
        local player = BanditUtils.GetClosestPlayerLocation(zombie, true)
        
        -- Skip if player is closer than the bandit
        if player.dist < enemy.dist then return end

        local bandit = BanditZombie.Cache[enemy.id]

        -- Standard movement if bandit is far
        if enemy.dist > 6 then
            -- zombie:addLineChatElement(tostring(ZombRand(100)) .. " far", 0.6, 0.6, 1)
            if zombie:CanSee(bandit) then
                zombie:pathToCharacter(bandit)
            end

        -- Approach bandit if in range
        else
            -- zombie:addLineChatElement(tostring(ZombRand(100)) .. " mid", 0.6, 0.6, 1)
            local player = getSpecificPlayer(0)
            if zombie:CanSee(bandit) and zombie:CanSee(player) then
                if BanditCompatibility.GetGameVersion() >= 42 then
                    zombie:pathToCharacter(bandit)
                end
                zombie:spotted(player, true)
                zombie:setTarget(bandit)
                zombie:setAttackedBy(bandit)
            end

            -- Bite range attack
            if enemy.dist < 0.55 and enemy.z == zz then
                -- :addLineChatElement(tostring(ZombRand(100)) .. " close", 0.6, 0.6, 1)
                local isWallTo = zombie:getSquare():isSomethingTo(bandit:getSquare())
                if not isWallTo then
                    if zombie:isFacingObject(bandit, 0.3) then
                        -- Optimized close-range attack logic
                        local attackingZombiesNumber = 0
                        for id, attackingZombie in pairs(BanditZombie.CacheLightZ) do
                            -- local distManhattan = BanditUtils.DistToManhattan(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                            if math.abs(attackingZombie.x - enemy.x) + math.abs(attackingZombie.y - enemy.y) < 1 then
                                -- local dist = BanditUtils.DistTo(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                                local dist = math.sqrt(((attackingZombie.x - enemy.x) * (attackingZombie.x - enemy.x)) + ((attackingZombie.y - enemy.y) * (attackingZombie.y - enemy.y)))
                                if dist < 0.6 then
                                    attackingZombiesNumber = attackingZombiesNumber + 1
                                    if attackingZombiesNumber > 2 then break end
                                end
                            end
                        end

                        -- If more than 2 zombies attacking, initiate death task
                        if attackingZombiesNumber > 2 then
                            local sound = bandit:isFemale() and "FemaleBeingEatenDeath" or nil
                            if not Bandit.HasTaskType(bandit, "Die") then
                                Bandit.ClearTasks(bandit)
                                local task = {action="Die", lock=true, anim="Die", sound=sound, time=300}
                                Bandit.AddTask(bandit, task)
                            end
                            return
                        end

                        if zombie:getBumpType() ~= "Bite" then
                            -- print ("BITE: " .. asn .. " " .. zombie:getBumpType())
                            zombie:setBumpType("Bite")
                            local attackId = ZombRand(1000000)
                            zombie:getModData().attackId = attackId 
                            biteTab[enemy.id] = {attackId=attackId, bandit=bandit, tick=0}
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
    if not task.action then return end
    if not task.state then task.state = "NEW" end

    if task.state == "NEW" then
        if not task.time then task.time = 1000 end
        -- bandit:addLineChatElement(task.action, 0.8, 0.8, 0.1)
        if task.action ~= "Shoot" and task.action ~= "Aim" and task.action ~= "Rack"  and task.action ~= "Load" then
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
                local player = getSpecificPlayer(0)
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

    --[[
    -- AVOIDANCE
    if #tasks == 0 and uTick % 4 == 0 then
        local avoidanceTasks = ManagePreservation2(bandit)
        if #avoidanceTasks > 0 then
            for _, t in pairs(avoidanceTasks) do table.insert(tasks, t) end
        end
    end]]

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
        if program and program.name and program.stage  then
            -- local ts = getTimestampMs()
            local res = ZombiePrograms[program.name][program.stage](bandit)
            -- print ("AT: " .. program.name .. "." .. program.stage .. " " .. (getTimestampMs() - ts))
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

    if BanditCompatibility.IsReanimatedForGrappleOnly(zombie) then return end

    local id = BanditUtils.GetZombieID(zombie)
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

    bandit:setAnimatingBackwards(false)
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
    ApplyVisuals(bandit, brain)

    -- MANAGE BANDIT TORCH
    --[[
    if uTick == 1 then
        ManageTorch(bandit)
    end]]

    -- MANAGE BANDIT CHAINSAW
    ManageChainsaw(bandit)

    -- MANAGE BANDIT BEING ON FIRE
    if uTick == 2 then
        ManageOnFire(bandit)
    end

    -- MANAGE BANDIT SPEECH COOLDOWN
    ManageSpeechCooldown(brain)

    -- MANAGE BANDIT SOUND COOLDOWN
    ManageSoundCoolDown(brain)

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

    uTick = uTick + 1

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
    local inventory = bandit:getInventory()
    local items = ArrayList.new()
    inventory:getAllEvalRecurse(predicateRemovable, items)
    for i=0, items:size()-1 do
        local item = items:get(i)
        inventory:Remove(item)
        inventory:setDrawDirty(true)
    end

    -- update stuck weapons
    local stuckLocationList = {"MeatCleaver in Back", "Axe Back", "Knife in Back", "Knife Left Leg", "Knife Right Leg", "Knife Shoulder", "Knife Stomach"}
    for _, stuckLocation in pairs(stuckLocationList) do
        local attachedItem = zombie:getAttachedItem(stuckLocation)
        if attachedItem then
            inventory:AddItem(attachedItem)
            inventory:setDrawDirty(true)
        end
    end

    -- hostility against civilians (clan=0) is handled by other mods
    local brain = BanditBrain.Get(bandit)
    if brain.clan == 0 then return end

    Bandit.Say(bandit, "DEAD", true)

    local attacker = bandit:getAttackedBy()
    CheckFriendlyFire(bandit, attacker)

    local player = getSpecificPlayer(0)
    local killer = bandit:getAttackedBy()
    if killer then
        if killer == player then
            local args = {}
            args.id = 0
            sendClientCommand(player, 'Commands', 'IncrementBanditKills', args)
            player:setZombieKills(player:getZombieKills() - 1)
        end
    end

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
    args.id = brain.id
    sendClientCommand(player, 'Commands', 'BanditRemove', args)
    BanditBrain.Remove(bandit)
end

Events.OnZombieUpdate.Add(OnBanditUpdate)
Events.OnHitZombie.Add(OnHitZombie)
Events.OnZombieDead.Add(OnZombieDead)
