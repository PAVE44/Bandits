local function predicateRemovable(item)
    if not item:getModData().preserve and not instanceof(item, "Clothing") then
        return true
    end
end

local function predicateAll(item)
	return true
end

local function CalcSpottedScore(player, dist)
    if not instanceof(player, "IsoPlayer") then return end

    local square = player:getSquare()
    local spottedScore = square:getLightLevel(0)

    if player:isRunning() then spottedScore = spottedScore + 0.05 end
    if player:isSprinting() then spottedScore = spottedScore + 0.08 end

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
                    if instanceof(chr, "IsoPlayer") and not (brainShooter.hostile or brainShooter.hostileP) then
                        -- shooter:addLineChatElement("PLAYER IN LINE", 0.8, 0.8, 0.1)
                        return false
                    elseif instanceof(chr, "IsoZombie") then
                        local brainEnemy = BanditBrain.Get(chr)
                        if not BanditUtils.AreEnemies(brainEnemy, brainShooter) then
                        -- if brainEnemy and brainEnemy.clan and brainShooter.clan == brainEnemy.clan and (not brainShooter.hostile or brainEnemy.hostile) then
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

    local desc = zombie:getDescriptor()
    -- local test = desc:getVoicePrefix()
    desc:setVoicePrefix("Bandit")

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

        if Bandit.HasExpertise(bandit, Bandit.Expertise.Recon) then
            bandit:setVariable("MovementSpeed", 1.00)
        else
            bandit:setVariable("MovementSpeed", 0.70)
        end

        bandit:setHealth(brain.health)

        if brain.skin then
            banditVisuals:setSkinTextureName(Bandit.GetSkinTexture(brain.female, brain.skin))
        end

        if brain.hairType then
            banditVisuals:setHairModel(Bandit.GetHairStyle(brain.female, brain.hairType)) 
        end

        if not bandit:isFemale() and brain.beardType then
            local beardModel = Bandit.GetBeardStyle(brain.female, brain.beardType)
            if beardModel then
                banditVisuals:setBeardModel(beardModel) 
            end
        end

        if brain.hairColor then
            local hairColor = Bandit.GetHairColor(brain.hairColor)
            local icolor = ImmutableColor.new(hairColor.r, hairColor.g, hairColor.b)
            banditVisuals:setHairColor(icolor) 
            banditVisuals:setBeardColor(icolor) 
        end

        -- items must be applied in a good order, hence the double loop
        for _, bodyLocationDef in pairs(BanditCompatibility.GetBodyLocationsOrdered()) do
            for bodyLocation, itemType in pairs(brain.clothing) do
                if bodyLocation == bodyLocationDef then
                    local item = BanditCompatibility.InstanceItem(itemType)
                    if item then
                        --[[
                        local clothingItem = item:getClothingItem()
                        if clothingItem then
                            local itemVisual = banditVisuals:addClothingItem(itemVisuals, clothingItem)
                        end]]
                        local itemVisual = ItemVisual.new()
                        itemVisual:setItemType(itemType)
                        itemVisual:setClothingItemName(itemType)

                        if brain.tint[bodyLocation] then
                            local color = BanditUtils.dec2rgb(brain.tint[bodyLocation])
                            local immutableColor = ImmutableColor.new(color.r, color.g, color.b, 1)
                            itemVisual:setTint(immutableColor)
                        end

                        itemVisuals:add(itemVisual)
                    end
                end
            end
        end

        for _, slot in pairs({"primary", "secondary", "melee"}) do

            if brain.weapons[slot].name then
                local weapon = BanditCompatibility.InstanceItem(brain.weapons[slot].name)

                if weapon then
                    weapon = BanditUtils.ModifyWeapon(weapon, brain)

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
            if item then
                --[[
                local clothingItem = item:getClothingItem()
                local itemVisual = banditVisuals:addClothingItem(itemVisuals, clothingItem)]]

                local itemVisual = ItemVisual.new()
                itemVisual:setItemType(brain.bag.name)
                itemVisual:setClothingItemName(brain.bag.name)
                local immutableColor = ImmutableColor.new(0.1, 0.1, 0.1, 1)
                itemVisual:setTint(immutableColor)
                itemVisuals:add(itemVisual)
            end
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

local function RemoveWindowFromPathing (bandit, square)

    -- will need to unset for windows and windowframes too
    local recalc = false
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local properties = object:getProperties()

        if properties then
            if properties:Is(IsoFlagType.canPathN) then
                properties:UnSet(IsoFlagType.canPathN)
                recalc = true
            end
            if properties:Is(IsoFlagType.canPathW) then
                properties:UnSet(IsoFlagType.canPathW)
                recalc = true
            end

            -- properties:UnSet(IsoFlagType.WindowN)
            -- properties:UnSet(IsoFlagType.WindowW)
        end
    end

    if recalc then
        square:RecalcProperties()
        square:RecalcAllWithNeighbours(true)
        if BanditCompatibility.GetGameVersion() >= 42 then
            square:setSquareChanged()
        end
    end
end

-- manages collisions with doors, windows, fences and other objects
local function ManageCollisions(bandit)

    if Bandit.HasActionTask(bandit) then return {} end

    -- bandit:setCollidable(true)

    if not bandit:isCollidedThisFrame() then return {} end

    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapons = brain.weapons

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

                    -- TALL FENCE COLLISION
                    local tallFence = properties:Val("FenceTypeHigh")
                    local tallHoppable = object:isTallHoppable()
                    if tallFence or tallHoppable then
                        bandit:setCollidable(false)
                        if bandit:isFacingObject(object, 0.5) then
                            bandit:setBumpType("ClimbFenceTall")
                        else
                            bandit:faceThisObject(object)
                        end
                        return tasks
                    end

                    -- WINDOW COLLISIONS
                    if instanceof(object, "IsoWindow") then
                        if (object:isInvincible() or (object:getSprite() and properties:Is("WindowLocked"))) and (not brain.hostile and brain.program.name ~= "Civilian") then
                            RemoveWindowFromPathing(bandit, square)
                            
                        elseif bandit:isFacingObject(object, 0.5) then
                            if object:isBarricaded() then
                                if brain.hostile then
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
                                else
                                    RemoveWindowFromPathing(bandit, square)
                                end

                            elseif not object:IsOpen() and not object:isSmashed() then
                                if SandboxVars.Bandits.General_SmashWindow and (brain.hostile or brain.program.name == "Civilian") then
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
                    end

                    -- DOOR COLLISIONS
                    if instanceof(object, "IsoDoor") or (instanceof(object, 'IsoThumpable') and object:isDoor() == true) then
                        if bandit:isFacingObject(object, 0.5) then

                            if object:isBarricaded() then
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
                                local sameSide = barricade:getSquare():getX() == bandit:getSquare():getX() and barricade:getSquare():getY() == bandit:getSquare():getY()

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
                                    Bandit.Say(bandit, "BREACH")
                                    local task = {action="Unbarricade", anim=anim, time=300, fx=fx, fy=fy, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                    return tasks
                                else
                                    if not bandit:isPrimaryEquipped(weapons.melee) then
                                        local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                        for _, t in pairs(stasks) do table.insert(tasks, t) end
                                    end
                                    Bandit.Say(bandit, "BREACH")
                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                    return tasks
                                end

                            elseif not object:IsOpen() then
                                if IsoDoor.getDoubleDoorIndex(object) > -1 then

                                    if object:isLocked() or object:isLockedByKey() or object:isObstructed() then
                                        if bandit:isPrimaryEquipped(weapons.melee) then
                                            local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                            table.insert(tasks, task)
                                        else
                                            local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                            for _, t in pairs(stasks) do table.insert(tasks, t) end
                                            return tasks
                                        end
                                    else
                                        IsoDoor.toggleDoubleDoor(object, true)
                                        local doorSound = properties:Is("DoorSound") and properties:Val("DoorSound") or "WoodDoor"
                                        doorSound = doorSound .. "Open"
                                        bandit:playSound(doorSound)
                                    end

                                elseif IsoDoor.getGarageDoorIndex(object) > -1 then
                                
                                    local exterior = bandit:getCurrentSquare():Is(IsoFlagType.exterior)
                                    if exterior and (object:isLocked() or object:isLockedByKey()) then
                                        if bandit:isPrimaryEquipped(weapons.melee) then
                                            Bandit.Say(bandit, "BREACH")
                                            local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                            table.insert(tasks, task)
                                        else
                                            local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                            for _, t in pairs(stasks) do table.insert(tasks, t) end
                                            return tasks
                                        end
                                    else
                                        IsoDoor.toggleGarageDoor(object, true)
                                        local doorSound = properties:Is("DoorSound") and properties:Val("DoorSound") or "WoodDoor"
                                        doorSound = doorSound .. "Open"
                                        bandit:playSound(doorSound)
                                    end
                                else

                                    -- door locks are complicated... 
                                    if ((object:isLocked() or object:isLockedByKey()) and (not bandit:getCurrentSquare():getRoom() or object:getProperties():Is("forceLocked"))) or object:isObstructed() then
                                        if bandit:isPrimaryEquipped(weapons.melee) then
                                            Bandit.Say(bandit, "BREACH")
                                            local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                            table.insert(tasks, task)
                                        else
                                            local stasks = BanditPrograms.Weapon.Switch(bandit, weapons.melee)
                                            for _, t in pairs(stasks) do table.insert(tasks, t) end
                                            return tasks
                                        end
                                    else
                                        object:DirtySlice()
                                        IsoGridSquare.RecalcLightTime = -1.0
                                        square:InvalidateSpecialObjectPaths()
                                        object:ToggleDoorSilent()
                                        square:RecalcProperties()
                                        object:syncIsoObject(false, 1, nil, nil)
                                        LuaEventManager.triggerEvent("OnContainerUpdate")
                                        if BanditCompatibility.GetGameVersion() >= 42 then
                                            object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
                                        end

                                        --[[
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
                                                        
                                                        --
                                                        square:ReCalculateCollide(surroundingSquare)
                                                        square:ReCalculatePathFind(surroundingSquare)
                                                        square:ReCalculateVisionBlocked(surroundingSquare)
                                                        surroundingSquare:ReCalculateCollide(square)
                                                        surroundingSquare:ReCalculatePathFind(square)
                                                        surroundingSquare:ReCalculateVisionBlocked(square)
                                                        --
                                                        
                                                        surroundingSquare:InvalidateSpecialObjectPaths()
                                                        surroundingSquare:RecalcProperties()
                                                        surroundingSquare:RecalcAllWithNeighbours(true)
                                                    end
                                                -- end
                                            end
                                        end
                                        ]]
                                        local doorSound = properties:Is("DoorSound") and properties:Val("DoorSound") or "WoodDoor"
                                        doorSound = doorSound .. "Open"
                                        bandit:playSound(doorSound)
                                    end
                                end
                            end
                        else
                            bandit:faceThisObject(object)
                        end
                    end

                    -- THUMPABLE COLLISIONS
                    if SandboxVars.Bandits.General_DestroyThumpable and instanceof(object, "IsoThumpable") and not properties:Val("FenceTypeLow") and brain.hostile then
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

-- manages melee and weapon combat
local function ManageCombat(bandit)

    if bandit:isCrawling() then return {} end 
    if Bandit.IsSleeping(bandit) then return {} end
    -- if bandit:getActionStateName() == "bumped" then return {} end

    local tasks = {}
    local zx, zy, zz = bandit:getX(), bandit:getY(), bandit:getZ()
    local brain = BanditBrain.Get(bandit)
    local weapons = brain.weapons
    local isOutOfAmmo = BanditBrain.IsOutOfAmmo(brain)
    local isNeedPrimary = BanditBrain.NeedResupplySlot(brain, "primary")
    local isNeedSecondary = BanditBrain.NeedResupplySlot(brain, "secondary")
    local isBareHands = BanditBrain.IsBareHands(brain)
    local isOutside = bandit:getSquare():isOutside()

    local bestDist = 40
    local enemyCharacter, switchTo
    local healing, reload, resupply = false, false, false
    local combat, switch, firing, shove, escape = false, false, false, false, false
    local maxRangeMelee, maxRangePistol, maxRangeRifle
    local friendlies, friendliesBwd, enemies, enemiesBwd = 0, 0, 0, 0
    local sx, sy = 0, 0

    -- THIS GOVERNS LOW-PRIORITY TASKS
    if not BanditBrain.HasActionTask(brain) then
        
        -- HEALING FLAG
        local health = bandit:getHealth()    
        if health < 0.4 then
            healing = true
        end

        -- PEACFUL RELOAD FLAG
        for _, slot in pairs({"primary", "secondary"}) do
            if weapons[slot].name then
                if (weapons[slot].type == "mag" and weapons[slot].bulletsLeft <= 0 and weapons[slot].magCount > 0) or
                   (weapons[slot].type == "nomag" and weapons[slot].bulletsLeft < weapons[slot].ammoSize and weapons[slot].ammoCount > 0) or 
                    weapons[slot].racked == false then 
                    
                    if bandit:isPrimaryEquipped(weapons[slot].name) then
                        reload = true
                    end
                end
            end
        end

        -- RESUPPLY FLAG
        if isBareHands or isNeedPrimary or isNeedSecondary then
            resupply = true
        end
    end

    -- SWITCH WEAPON DISTANCES
    local meleeDist = isOutside and 2.6 or 1.2
    local meleeDistPlayer = isOutside and 3.5 or 1.2
    local rifleDist = 5.5
    local escapeDist = 5.2
    local bwdDist = 2.8

    -- COMBAT AGAIST PLAYERS 
    if brain.hostile or brain.hostileP then
        local playerList = BanditPlayer.GetPlayers()

        for i=0, playerList:size()-1 do
            local potentialEnemy = playerList:get(i)
            if potentialEnemy and potentialEnemy:isAlive() and bandit:CanSee(potentialEnemy) and not potentialEnemy:isBehind(bandit) and (instanceof(potentialEnemy, "IsoPlayer") and not BanditPlayer.IsGhost(potentialEnemy)) then
                local px, py, pz = potentialEnemy:getX(), potentialEnemy:getY(), potentialEnemy:getZ()
                -- local dist = BanditUtils.DistTo(zx, zy, px, py)
                local dist = math.sqrt(((zx - px) * (zx - px)) + ((zy - py) * (zy - py))) -- no function call for performance
                if dist < bestDist and math.abs(zz - pz) < 0.5 then
                    local spottedScore = CalcSpottedScore(potentialEnemy, dist)
                    if not bandit:getSquare():isSomethingTo(potentialEnemy:getSquare()) and spottedScore > 0.49 then
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
                                        shove = dist < 0.5 and not prone and asn ~= "onground" and asn ~= "sitonground" and asn ~= "climbfence" and asn ~= "bumped"
                                        combat = not shove
                                    end
                                else
                                    switch = true
                                    switchTo = weapons.melee
                                end
                            end
                        end

                        --determine if bandit will be in shooting mode
                        if not isOutOfAmmo and dist > meleeDistPlayer + 1 and not combat and not shove then
                            if weapons.primary.name and weapons.primary.bulletsLeft > 0 then
                                if not maxRangeRifle then
                                    local item = BanditCompatibility.InstanceItem(weapons.primary.name)
                                    item = BanditUtils.ModifyWeapon(item, brain)
                                    maxRangeRifle = BanditCompatibility.GetMaxRange(item)
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
                                    item = BanditUtils.ModifyWeapon(item, brain)
                                    maxRangePistol = BanditCompatibility.GetMaxRange(item)
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
        if math.abs(potentialEnemy.x - zx) + math.abs(potentialEnemy.y - zy) < 57 then

            if BanditUtils.AreEnemies(potentialEnemy.brain, brain) then
            -- if not potentialEnemy.brain or (brain.clan ~= potentialEnemy.brain.clan and (brain.hostile or potentialEnemy.brain.hostile)) then
     
                -- load real instance here
                local potentialEnemy = cache[id]
                if potentialEnemy:isAlive() and potentialEnemy:getHealth() > 0 and bandit:CanSee(potentialEnemy) then
                --- if true then
                    local pesq = potentialEnemy:getSquare()
                    if pesq and pesq:getLightLevel(0) > 0.31 and not bandit:getSquare():isSomethingTo(pesq) then
                        local px, py, pz = potentialEnemy:getX(), potentialEnemy:getY(), potentialEnemy:getZ()
                        -- local dist = BanditUtils.DistTo(zx, zy, potentialEnemy:getX(), potentialEnemy:getY())
                        local dist = math.sqrt(((zx - px) * (zx - px)) + ((zy - py) * (zy - py)))
                        if dist < escapeDist then
                            local rad = math.rad(potentialEnemy:getDirectionAngle())
                            sx = sx + math.cos(rad)
                            sy = sy + math.sin(rad)
                            enemies = enemies + 1
                            if dist < bwdDist then
                                enemiesBwd = enemiesBwd + 1
                            end
                        end
                        if dist < bestDist then
                            bestDist, enemyCharacter = dist, potentialEnemy

                            --reset action flags, only one can be true
                            combat, switch, firing, shove, escape = false, false, false, false, false
                            
                            local asn = enemyCharacter:getActionStateName()

                            --determine if bandit will be in combat mode
                            if weapons.melee and math.abs(zz - pz) < 0.5 and asn ~= "falldown" then
                                if dist <= meleeDist then
                                    if bandit:isPrimaryEquipped(weapons.melee) then

                                        if not maxRangeMelee then
                                            maxRangeMelee = BanditCompatibility.InstanceItem(weapons.melee):getMaxRange()
                                        end
                                        local prone = enemyCharacter:isProne()
                                        local fix = 0.1
                                        if prone then fix = -0.2 end

                                        if dist <= maxRangeMelee + fix then
                                            shove = dist < 0.0 and not prone and asn ~= "onground" and asn ~= "climbfence" and asn ~= "bumped" and asn ~= "getup" and asn ~= "falldown" and not BanditCompatibility.IsRagdoll(potentialEnemy)
                                            combat = not shove
                                        end
                                    else
                                        switch = true
                                        switchTo = weapons.melee
                                        -- bandit:addLineChatElement("Melee" .. dist, 0.8, 0.8, 0.1)
                                    end
                                end
                            end

                            --determine if bandit will be in shooting mode
                            if not isOutOfAmmo and dist > meleeDist + 1 and not combat and not shove then
                                if weapons.primary.name and weapons.primary.bulletsLeft > 0 then
                                    if not maxRangeRifle then
                                        local item = BanditCompatibility.InstanceItem(weapons.primary.name)
                                        item = BanditUtils.ModifyWeapon(item, brain)
                                        maxRangeRifle = BanditCompatibility.GetMaxRange(item)
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
                                            -- bandit:addLineChatElement("Primary" .. dist, 0.8, 0.8, 0.1)
                                        end
                                    end
                                elseif weapons.secondary.name and weapons.secondary.bulletsLeft > 0 then
                                    if not maxRangePistol then
                                        local item = BanditCompatibility.InstanceItem(weapons.secondary.name)
                                        item = BanditUtils.ModifyWeapon(item, brain)
                                        maxRangePistol = BanditCompatibility.GetMaxRange(item)
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
                                            -- bandit:addLineChatElement("Secondary" .. dist, 0.8, 0.8, 0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local distSq = ((zx - potentialEnemy.x) * (zx - potentialEnemy.x)) + ((zy - potentialEnemy.y) * (zy - potentialEnemy.y))
                if distSq < 27.04 then
                    friendlies = friendlies + 1
                    if distSq < 5.76 then
                        friendliesBwd = friendliesBwd + 1
                    end
                end
            end
        end
    end
    
    if enemies >= friendlies + 3 then
        if not BanditBrain.HasMoveTask(brain) then
            local l = 4
            local time = 80
            if firing then 
                l = 20
                time = 400
            end
            -- bandit:addLineChatElement("Escape", 0.8, 0.8, 0.1)
            -- print ("E: " .. enemies .. " F: " .. friendlies)
            Bandit.ClearTasks(bandit)
            local mrad = math.atan2(sy, sx)
            local mdeg = math.deg(mrad)
            local nbx = zx + (l * math.cos(mrad))
            local nby = zy + (l * math.sin(mrad))
            local nbz = zz
            local task = BanditUtils.GetMoveTask(0.01, nbx, nby, nbz, "Run", 12, false)
            task.time = time
            task.lock = true
            task.backwards = false
            table.insert(tasks, task)
        end

    elseif shove then
        if not BanditBrain.HasTaskType(brain, "Shove") then
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

            if bandit:isFacingObject(enemyCharacter, 0.1) then
                local eid = BanditUtils.GetCharacterID(enemyCharacter)
                local task = {action="Push", anim="Shove", sound="AttackShove", time=60, endurance=-0.05, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            else
                bandit:faceThisObject(enemyCharacter)
            end
        end

    elseif switch then
        if not BanditBrain.HasActionTask(brain) then
            Bandit.ClearTasks(bandit)
            local stasks = BanditPrograms.Weapon.Switch(bandit, switchTo)
            for _, t in pairs(stasks) do table.insert(tasks, t) end
        end

    elseif combat then
        if not BanditBrain.HasTaskTypes(brain, {"Smack", "Push", "Equip", "Unequip"}) then 
            Bandit.ClearTasks(bandit)
            local veh = enemyCharacter:getVehicle()
            if veh then Bandit.Say(bandit, "CAR") end

            if bandit:isFacingObject(enemyCharacter, 0.5) then
                local shouldHitMoving = false
                if enemiesBwd >= friendliesBwd + 1 then
                    shouldHitMoving = true
                end
                local eid = BanditUtils.GetCharacterID(enemyCharacter)
                local task = {action="Smack", time=65, endurance=-0.03, shm=shouldHitMoving, weapon=weapons.melee, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            else
                bandit:faceThisObject(enemyCharacter)
            end

        
        elseif instanceof(enemyCharacter, "IsoPlayer") and not Bandit.HasActionTask(bandit) then
            local task = {action="Time", anim="Smoke", time=250}
            table.insert(tasks, task)
            Bandit.Say(bandit, "DEATH")
        end

    elseif BanditCompatibility.GetGameVersion() >= 42 and enemiesBwd >= 2 then
        if not Bandit.HasMoveTask(bandit) and not Bandit.HasTaskType(bandit, "Shove") and not Bandit.HasTaskType(bandit, "Hit") then
            Bandit.ClearTasks(bandit)
            -- bandit:addLineChatElement("Slow", 0.8, 0.8, 0.1)
            local mrad = math.atan2(sy, sx)
            local mdeg = math.deg(mrad)
            local l = 1
            local nbx = zx + (l * math.cos(mrad))
            local nby = zy + (l * math.sin(mrad))
            local nbz = zz
            local task = BanditUtils.GetMoveTask(0.01, nbx, nby, nbz, "WalkBwdAim", l, false)
            task.backwards = true
            task.lock = false
            table.insert(tasks, task)

            --[[
            local eid = BanditUtils.GetCharacterID(enemyCharacter)
            local task = {action="Shove", anim="Shove", sound="AttackShove", time=60, endurance=-0.05, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
            -- local task = {action="Hit", time=65, endurance=-0.03, weapon=weapons.melee, eid=eid, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
            table.insert(tasks, task)]]
        end

    elseif healing then
        if not BanditBrain.HasTaskType(brain, "Bandage") then
            local task = {action="Bandage"}
            table.insert(tasks, task)
        end

    elseif firing then
        if not BanditBrain.HasTaskTypes(brain, {"Shoot", "Turn", "Aim", "Rack", "Equip", "Unequip", "Load", "Unload"}) then 

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
        if not BanditBrain.HasActionTask(brain) then
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
        if not BanditBrain.HasTask(brain) then
            local stasks = BanditPrograms.Weapon.Resupply(bandit)
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
                local closestZombie = BanditUtils.GetClosestZombieLocation(player)
                local closestBandit = BanditUtils.GetClosestBanditLocation(player)

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

    local asn = zombie:getActionStateName()
    local zid = zombie:getModData().zid
    if zid and biteTab[zid] and (zombie:getBumpType() == "Bite" or zombie:getBumpType() == "BiteLow") and asn == "bumped" then
        local tick = biteTab[zid].tick
        if tick == 9 then
            local bandit = biteTab[zid].bandit
            local dist = BanditUtils.DistTo(zombie:getX(), zombie:getY(), bandit:getX(), bandit:getY())
            if dist < 0.8 then 
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
        
                if not bandit:isOnKillDone() then
                    Bandit.ClearTasks(bandit)
                    -- bandit:setBumpDone(true)
                    bandit:Hit(teeth, zombie, 1.01, false, 1, false)
                    Bandit.UpdateInfection(bandit, 0.001)

                    local h = bandit:getHealth()
                    local id = BanditUtils.GetCharacterID(bandit)
                    local args = {id=id, h=h}
                    sendClientCommand(getSpecificPlayer(0), 'Sync', 'Health', args)
                end
            end
        elseif tick >= 16 then
            biteTab[zid] = nil
            zombie:getModData().zid = nil
            return
        end
        biteTab[zid].tick = tick + 1
        return
    end

    if asn == "bumped" or asn == "onground" or asn == "climbfence" or asn == "getup" then
        return
    end
    if zombie:isProne() then return end

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
    --[[
    if target and (not target:isAlive() or not zombie:CanSee(target)) then
        zombie:setTarget(nil)
    end]]

    -- Stop sound if playing
    --[[
    local emitter = zombie:getEmitter()
    if emitter:isPlaying("ChainsawIdle") then
        emitter:stopSoundByName("ChainsawIdle")
    end]]

    -- Fetch zombie coordinates and closest bandit location
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local enemy = BanditUtils.GetClosestBanditLocation(zombie)

    -- If bandit is in range, proceed
    if enemy.dist < 30 then
        --local player = BanditUtils.GetClosestPlayerLocation(zombie, true)
        
        -- Skip if player is closer than the bandit
        --if player.dist < enemy.dist then return end

        local bandit = BanditZombie.Cache[enemy.id]
        local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
        local dist = math.sqrt(((bx - zx) * (bx - zx)) + ((by - zy) * (by - zy)))

        -- Standard movement if bandit is far
        if dist > 3 then
            -- zombie:addLineChatElement(tostring(ZombRand(100)) .. " far", 0.6, 0.6, 1)
            if zombie:CanSee(bandit) then
                zombie:pathToCharacter(bandit)
            end

        -- Approach bandit if in range
        else
            -- zombie:addLineChatElement(string.format("mid %.2f", enemy.dist), 0.6, 0.6, 1)
            local player = getSpecificPlayer(0)
            -- local tempTarget = BanditUtils.CloneIsoPlayer(bandit)
            -- if zombie:CanSee(bandit) and zombie:CanSee(player) then
                -- if BanditCompatibility.GetGameVersion() >= 42 then
                    -- zombie:pathToCharacter(bandit)
                -- end
                -- if not zombie:getTarget() then
                    -- zombie:addLineChatElement(string.format("SPOTTED %.2f", enemy.dist), 0.6, 0.6, 1)
                    -- zombie:changeState(LungeState.instance())
                    -- zombie:getPathFindBehavior2():cancel()
                    -- zombie:setPath2(nil)
                    zombie:spotted(player, true)
                    zombie:setTarget(bandit)
                    zombie:setAttackedBy(bandit)
                    
                    
                    --tempTarget:removeFromWorld()
                    -- tempTarget = nil

                -- end
            -- end
            if dist < 0.80 and math.abs(zz - bz) < 0.3 then
                
                local isWallTo = zombie:getSquare():isSomethingTo(bandit:getSquare())
                if not isWallTo then


                    if zombie:isFacingObject(bandit, 0.3) then
                        -- Optimized close-range attack logic
                        local attackingZombiesNumber = 0
                        for id, attackingZombie in pairs(BanditZombie.CacheLightZ) do
                            -- local distManhattan = BanditUtils.DistToManhattan(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                            if math.abs(attackingZombie.x - bx) + math.abs(attackingZombie.y - by) < 1 then
                                -- local dist = BanditUtils.DistTo(attackingZombie.x, attackingZombie.y, enemy.x, enemy.y)
                                local dist = math.sqrt(((attackingZombie.x - bx) * (attackingZombie.x - bx)) + ((attackingZombie.y - by) * (attackingZombie.y - by)))
                                if dist < 0.6 then
                                    attackingZombiesNumber = attackingZombiesNumber + 1
                                    if attackingZombiesNumber > 2 then break end
                                end
                            end
                        end

                        -- If more than 2 zombies attacking, initiate death task
                        if attackingZombiesNumber > 2 then
                            if not Bandit.HasTaskType(bandit, "Die") then
                                Bandit.ClearTasks(bandit)
                                local task = {action="Die", lock=true, anim="Die", time=300}
                                Bandit.AddTask(bandit, task)
                            end
                            return
                        end

                        if zombie:getBumpType() ~= "Bite" and zombie:getBumpType() ~= "BiteLow" and asn ~= "staggerback" then
                            -- prevents zombie into entering real attack state (we want simulate our own attack)
                            -- zombie:setVariable("bAttack", false)
                            bandit:setZombiesDontAttack(true)
                            if bandit:isProne() or bandit:isCrawling() then
                                zombie:setBumpType("BiteLow")
                            else
                                zombie:setBumpType("Bite")
                            end
                            local zid = BanditUtils.GetCharacterID(zombie)
                            zombie:getModData().zid = zid 
                            biteTab[zid] = {bandit=bandit, tick=0}
                            -- zombie:addLineChatElement("BITE", 0.8, 0.8, 0.1)
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
            bandit:getPathFindBehavior2():cancel()
            bandit:setPath2(nil)
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

    if BanditCompatibility.IsRagdoll(zombie) then return end

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

    local asn = zombie:getActionStateName()
    if asn == "onground" then
        local h = zombie:getHealth()
        if h <=0 then
            zombie:setAttackedBy(getCell():getFakeZombieForHit())
            zombie:becomeCorpse()
        end
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

    if BanditCompatibility.GetGameVersion() >= 42 then
        bandit:setAnimatingBackwards(false)
    end

    -- IF TELEPORTING THEN THERE IS NO SENSE IN PROCEEDING
    if bandit:isTeleporting() then
        return
    end

    -- WALKTYPE
    -- we do it this way, if walktype get overwritten by game engine we force our animations
    bandit:setWalkType(bandit:getVariableString("BanditWalkType"))
    bandit:setSpeedMod(1)

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
    -- ManageChainsaw(bandit)

    -- MANAGE BANDIT BEING ON FIRE
    if uTick == 2 then
        ManageOnFire(bandit)
    end

    -- MANAGE BANDIT SPEECH COOLDOWN
    ManageSpeechCooldown(brain)

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
    
    if not zombie:getVariableBoolean("Bandit") then return end

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

    BanditPlayer.CheckFriendlyFire(bandit, attacker)

    if handWeapon:isRanged() and instanceof(attacker, "IsoPlayer") then
        local bodyPartTypes = {
            Foot_R = {},
            Foot_L = {},
            LowerLeg_R = {},
            LowerLeg_L = {},
            UpperLeg_R = {},
            UpperLeg_L = {},
            Groin = {serious = true},
            Neck = {serious = true},
            Head = {insta = true},
            Torso_Lower = {serious = true},
            Torso_Upper = {serious = true},
            UpperArm_R = {},
            UpperArm_L = {},
            ForeArm_R = {},
            ForeArm_L = {},
            Hand_R = {},
            Hand_L = {}
        }

        for k, tab in pairs(bodyPartTypes) do
            if BodyPartType[k] == bodyPartType then
                local idx = BodyPartType.ToIndex(bodyPartType)
                local def = bandit:getBodyPartClothingDefense(idx, false, true)
                local rnd = ZombRand(100)
                if rnd > def then
                    if tab.insta then
                        bandit:Kill(nil)
                        return
                    end
                    if tab.serious then
                        local maxDmg = handWeapon:getMaxDamage() or 1
                        local extraDmg = 0.26 * maxDmg
                        local health = bandit:getHealth() - extraDmg
                        if health <=0 then
                            bandit:Kill(nil)
                            return
                        else
                            bandit:setHealth(health)
                        end
                    end
                end
            end
        end
    end
end

local function OnZombieDead(bandit)

    if bandit:getVariableBoolean("Bandit") then 

        local brain = BanditBrain.Get(bandit)
        local inventory = bandit:getInventory()
        local items = ArrayList.new()

        local veh = bandit:getVehicle()
        if veh then veh:exit(bandit) end

        inventory:getAllEvalRecurse(predicateRemovable, items)
        for i=0, items:size()-1 do
            local item = items:get(i)
            inventory:Remove(item)
            inventory:setDrawDirty(true)
        end

        -- update stuck weapons
        local stuckLocationList = {"MeatCleaver in Back", "Axe Back", "Knife in Back", "Knife Left Leg", "Knife Right Leg", "Knife Shoulder", "Knife Stomach"}
        for _, stuckLocation in pairs(stuckLocationList) do
            local attachedItem = bandit:getAttachedItem(stuckLocation)
            if attachedItem then
                inventory:AddItem(attachedItem)
                inventory:setDrawDirty(true)
            end
        end

        -- drop extra suitcase item 
        if brain.bag then
            if brain.bag == "Briefcase" then
                local bag = BanditCompatibility.InstanceItem("Base.Briefcase")
                local bagContainer = bag:getItemContainer()
                if bagContainer then
                    local rn = ZombRand(3)
                    if rn == 0 then
                        for i = 1, 1000 do
                            local money = instanceItem("Base.Money")
                            bagContainer:AddItem(money)
                        end
                    elseif rn == 1 then
                        local c1 = BanditCompatibility.InstanceItem("Base.Corset_Black")
                        local c2 = BanditCompatibility.InstanceItem("Base.StockingsBlack")
                        local c3 = BanditCompatibility.InstanceItem("Base.Hat_PeakedCapArmy")
                        bagContainer:AddItem(c1)
                        bagContainer:AddItem(c2)
                        bagContainer:AddItem(c3)
                    elseif rn == 2 then
                        local c1 = BanditCompatibility.InstanceItem("Base.Machete")
                        bagContainer:AddItem(c1)
                        if BanditCompatibility.GetGameVersion() >= 42 then
                            local c2 = BanditCompatibility.InstanceItem("Base.Hat_HalloweenMaskVampire")
                            local c3 = BanditCompatibility.InstanceItem("Base.BlackRobe")
                            bagContainer:AddItem(c2)
                            bagContainer:AddItem(c3)
                        end
                    end
                    bandit:getSquare():AddWorldInventoryItem(bag, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                end
            end
        end

        -- add key to inv
        if brain.key and ZombRand(3) == 1 then
            local item = BanditCompatibility.InstanceItem("Base.Key1")
            item:setKeyId(brain.key)
            item:setName("Building Key")
            inventory:AddItem(item)
            Bandit.UpdateItemsToSpawnAtDeath(bandit)
        end

        Bandit.Say(bandit, "DEAD", true)

        -- update player kills
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

        -- warning: bwo overwrites CheckFriendlyFire
        local attacker = bandit:getAttackedBy()
        BanditPlayer.CheckFriendlyFire(bandit, attacker)

        -- deprovision
        bandit:setUseless(false)
        bandit:setReanim(false)
        bandit:setVariable("Bandit", false)
        bandit:setPrimaryHandItem(nil)
        bandit:clearAttachedItems()
        bandit:resetEquippedHandsModels()
        bandit:getModData().isDeadBandit = true

        args = {}
        args.id = brain.id
        sendClientCommand(player, 'Commands', 'BanditRemove', args)
        BanditBrain.Remove(bandit)

        local bx, by = bandit:getX(), bandit:getY()
        local zombieList = BanditZombie.CacheLightZ
        for id, zombie in pairs(zombieList) do
            local dist = math.abs(bx - zombie.x) + math.abs(by - zombie.y)
            if dist < 10 then
                local zombie = BanditZombie.Cache[id]
                if zombie then
                    zombie:setEatBodyTarget(bandit, true)
                end
            end
        end
    end

    -- stale corpse removal hack fro b42, it replaces the dying zombie with a deadbody
    -- and copies most of the properties to look as the original 
    if SandboxVars.Bandits.General_CorpseSwapper and BanditCompatibility.GetGameVersion() >= 42 then
        local isSeen = false
        local playerList = BanditPlayer.GetPlayers()
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player then
                if  player:CanSee(bandit) then
                    if bandit:getSquare():isCanSee(0) then
                        isSeen = true
                    end
                end
            end
        end

        if not isSeen and not bandit:getVariableBoolean("BanditBecomingCorpse") then
            bandit:setVariable("BanditBecomingCorpse", true)
            bandit:getModData().isDeadBandit = false
            local wornItems = bandit:getWornItems()
            local inv = bandit:getInventory()
            local hv = bandit:getHumanVisual()
            local arrItems = ArrayList.new()
            inv:getAllEvalRecurse(predicateAll, arrItems)

            
            local bandit2 = createZombie(bandit:getX(), bandit:getY(), bandit:getZ(), nil, 0, IsoDirections.fromAngle(bandit:getForwardDirection()))
            local hv2 = bandit2:getHumanVisual()
            bandit2:setFemale(bandit:isFemale())
            hv2:setSkinTextureName(hv:getSkinTexture())
            hv2:setHairModel(hv:getHairModel())
            hv2:setBeardModel(hv:getHairModel())
            hv2:setHairColor(hv:getHairColor()) 
            hv2:setBeardColor(hv:getBeardColor())
            
            bandit2:setWornItems(wornItems)
            bandit2:setAttachedItems(bandit:getAttachedItems())
            bandit2:getModData().isDeadBandit = false

            local body = IsoDeadBody.new(bandit2, false);
            inv2 = body:getContainer()
            for i = 0, wornItems:size() - 1 do
                local wornItem = wornItems:get(i)
                local item = wornItem:getItem()
                inv2:AddItem(item)
            end

            for i = 0, arrItems:size()-1 do
                local item = arrItems:get(i)
                inv2:AddItem(item)
            end

            bandit:removeFromSquare()
            bandit:removeFromWorld()
            
            bandit2:removeFromWorld()
            bandit2:removeFromSquare()
            print ("----- CORPSE SWAPPED ------")
        end
    end

end

local function OnDeadBodySpawn(body)
    --[[
    local hv = body:getHumanVisual()
    local skin = hv:getSkinTexture()
    if skin:find("^FemaleBody") or skin:find("^MaleBody") then
        local age = getGameTime():getWorldAgeHours()
        body:setReanimateTime(age + ZombRandFloat(0.1, 0.7))
    end
    ]]
    local md = body:getModData()
    if body:getModData().isDeadBandit then
        if body:getModData().isDeadBandit == true then
            body:getModData().isDeadBandit = false
            local age = getGameTime():getWorldAgeHours()
            body:setReanimateTime(age + ZombRandFloat(0.1, 0.8))
        end
    end
end

Events.OnZombieUpdate.Remove(OnBanditUpdate)
Events.OnZombieUpdate.Add(OnBanditUpdate)

Events.OnHitZombie.Remove(OnHitZombie)
Events.OnHitZombie.Add(OnHitZombie)

Events.OnZombieDead.Remove(OnZombieDead)
Events.OnZombieDead.Add(OnZombieDead)

Events.OnDeadBodySpawn.Remove(OnDeadBodySpawn)
Events.OnDeadBodySpawn.Add(OnDeadBodySpawn)