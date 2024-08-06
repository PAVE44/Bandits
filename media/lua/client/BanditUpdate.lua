BanditUpdate = BanditUpdate or {}

local function predicateAll(item)
	return true
end

local uTick = 0
function BanditUpdate.OnBanditUpdate(zombie)

    if uTick == 15 then uTick = 0 end
    uTick = uTick + 1

    local id = BanditUtils.GetCharacterID(zombie)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    
    local cell = getCell()
    local currentPlayer = getPlayer()
    local world = getWorld()
    local gamemode = world:getGameMode()
    local brain = BanditBrain.Get(zombie)
    
    -- HACKED GARBAGE BANDIT COLLECTION
    if zombie:getHealth() <= 0 and zombie:getActionStateName() == "onground" then
        -- if ZombRand(100) == 1 then
            -- zombie:Kill(getCell():getFakeZombieForHit(), true)
            -- zombie:changeState(ZombieOnGroundState.instance())
            -- zombie:setAttackedBy(getCell():getFakeZombieForHit())
            -- zombie:DoDeath(nil,nil,true)
            zombie:Kill(getCell():getFakeZombieForHit(), true)
        return
    end

    if not zombie:isAlive() then return end

    -- BANDITIZE
    -- ZOMBIES->BANDIT CONVERSION
    -- EACH CLIENT IS RESPONSIBLE FOR CONVERSION SEPARATELY
    local isNew = false
    if not zombie:getVariableBoolean("Bandit") then
        local gmd = GetBanditModData()
        if gmd.Queue and gmd.Queue[id] then

            isNew = true

            brain = gmd.Queue[id]
            BanditBrain.Update(zombie, brain)

            -- just in case
            zombie:setNoTeeth(true)

            zombie:setVariable("Bandit", true)
            zombie:setVariable("BanditPrimary", "")
            zombie:setVariable("BanditSecondary", "")
            zombie:setWalkType("Walk")
            -- zombie:getEmitter():playVocals("Zombie/Voice/TurnThisShitOffPls")

            -- this voodoo shit here is important, removes black screen crashes
            zombie:setVariable("ZombieHitReaction", "Chainsaw")
            zombie:getEmitter():stopAll()
            -- zombie:setVariable("BanditPace", "Run")

            -- makes bandit unstuck after spawns
            zombie:setTurnAlertedValues(-5, 5)

        else
            -- RECYCLED BANDITS BECOME ZOMBIES WITH WEAPONS IN HAND, FIX IT
            if zombie:getPrimaryHandItem() then
                zombie:setPrimaryHandItem(nil)
            end
            BanditBrain.Remove(zombie)
        end

        
    else
        
    end

    -- ZOMBIES ATTACK BANDITS
    local dragdown = false
    local teeth = InventoryItemFactory.CreateItem("Base.Pencil")
    local asn = zombie:getActionStateName()
    if uTick % 2 == 1 and not zombie:getVariableBoolean("Bandit") and asn ~= "bumped" then
        for _, b in pairs(BanditMap.BMap) do
            if b then
                local dist = math.sqrt(math.pow(zx - b.x, 2) + math.pow(zy - b.y, 2))
                if dist < 12 and b.z == zz then

                    -- zombie lunge attack on a zombie/bandit results in game crash because of moodle check
                    -- this forces an alternate animation without the checkattack event
                    zombie:setVariable("NoLungeAttack", true)
                    
                    local square = cell:getGridSquare(b.x, b.y, b.z)
                    if square then
                        local bandit = square:getZombie()
                        if bandit then
                            if bandit:getVariableBoolean("Bandit") then
                                if dist < 0.8 then

                                    local attackingZombiesNumber = 0
                                    for _, z in pairs(BanditMap.ZMap) do 
                                        local dist = math.sqrt(math.pow(z.x - b.x, 2) + math.pow(z.y - b.y, 2))
                                        if dist < 0.8 then
                                            attackingZombiesNumber = attackingZombiesNumber +1
                                        end
                                    end
                                    -- print ("--------------- BITE!!!!")
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
                                        bandit:Hit(teeth, zombie, 0.01, false, 1, false)
                                    end

                                    -- bandit:Kill(zombie, true)
                                else
                                    local asn = zombie:getActionStateName()
                                    if asn == "idle" then
                                        zombie:pathToLocationF(b.x, b.y, b.z)
                                        zombie:spotted(bandit, true)
                                        zombie:addAggro(bandit, 10)
                                    end
                                    -- print ("ADDED SPOTTED!")
                                end

                                --zombie:changeState(LungeState.instance())
                                
                                    
                                    -- bandit:setBumpType("Die")
                                -- print ("ATTACK BANDIT")
                            end
                        end
                    end
                else
                    zombie:setVariable("NoLungeAttack", false)
                end
            end
        end
    end

    
    -- AFTER THIS LINE PROCEED ONLY IF A ZOMBIE IS A BANDIT
    if not zombie:getVariableBoolean("Bandit") then return end
    if not brain or not brain.enslaved then return end
    
    local bandit = zombie
    
    -- bandit:setThumpTarget(nil)
    -- bandit:setTeleport(nil)
    if bandit:isTeleporting() then
        -- print ("teleporting...")
        return
    end

    -- NO ZOMBIE SOUNDS
    bandit:getEmitter():stopSoundByName("MaleZombieCombined")
    bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
    -- bandit:setHurtSound("SlidingGlassDoorBreak")
    --[[
    bandit:getEmitter():stopSoundByName("ZombieCrawlLungeSwing")
    bandit:getEmitter():stopSoundByName("MaleZombieIdle")
    bandit:getEmitter():stopSoundByName("FemaleZombieIdle")
    bandit:getEmitter():stopSoundByName("MaleZombieHurt")
    bandit:getEmitter():stopSoundByName("FemaleZombieHurt")
    bandit:getEmitter():stopSoundByName("MaleZombieAttack")
    bandit:getEmitter():stopSoundByName("FemaleZombieAttack")
    bandit:getEmitter():stopSoundByName("MaleZombieDeath")
    bandit:getEmitter():stopSoundByName("FemaleZombieDeath")
    bandit:getEmitter():stopSoundByName("FemaleBeingEatenDeath")
    bandit:getEmitter():stopSoundByName("MaleBeingEatenDeath")
    ]]

    local sb  = getFMODSoundBank()
    local raw = KahluaUtil.rawTostring2(sb)

    -- ADJUST HUMAN VISUALS
    -- WORKS ONLY IF BANDIT CLOSE TO PLAYER
    local banditVisuals = bandit:getHumanVisual()
    if banditVisuals then
        local skin = banditVisuals:getSkinTexture()
        if skin then
            if string.sub(skin, 1, 10) ~= "FemaleBody" and string.sub(skin, 1, 8) ~= "MaleBody" then
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

    -- BANDIT TORCH
    if SandboxVars.Bandits.General_CarryTorches then
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

    -- ON FIRE
    if bandit:isOnFire() then
        local sound = "MaleBeingEatenDeath"
        if bandit:isFemale() then sound = "FemaleBeingEatenDeath" end
        local task = {action="Die", lock=true, anim="Die", sound=sound, time=150}
        Bandit.ClearTasks(bandit)
        Bandit.AddTask(bandit, task)
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    -- TASKBUILDER
    ------------------------------------------------------------------------------------------------------------------------------------

    local tasks = {}
    local combat = false
    local firing = false
    local collide = false
    local exhausted = false
    local healing = false
    local weapons = Bandit.GetWeapons(bandit)
    local program = Bandit.GetProgram(bandit)
    local enemyCharacter

    -- DETECTING SITUATIONAL CONTEXT 
    -- SITUATIONAL TASKS WILL BE ALLOWED ONLY WHEN ACTION STATE IS VALID
    local asn = bandit:getActionStateName()
    -- print(asn)
    if asn == "onground" or asn == "getup" or asn =="staggerback" then 
        Bandit.ClearTasks(bandit)
        return
    elseif asn == "turnalerted" or asn == "attack" then
        -- bandits dont bite pls
        bandit:changeState(ZombieIdleState.instance())
        bandit:clearAggroList()
        bandit:setTarget(nil)
    elseif asn == "pathfind" then

    elseif asn == "thump" then
        if not SandboxVars.Bandits.General_DestroyThumpable or program.name ~= "Defend" then
            bandit:changeState(ZombieIdleState.instance())
        end
    elseif asn == "lunge" then
        bandit:setUseless(true)
    elseif asn == "walktoward-network" then
        -- bandit:changeState(ZombieIdleState.instance())
        --[[Bandit.ClearTasks(bandit)
        local task = {action="Time", anim="ReloadPistol", sound="M9InsertAmmo", time=90}
        table.insert(tasks, task)
        bandit:changeState(ZombieIdleState.instance())
        return--]]
    else
        if gamemode == "Multiplayer" then
            bandit:setUseless(false)
        else
            bandit:setUseless(true)
        end
    end

    --BANDIT ENDURANCE LOSS
    if SandboxVars.Bandits.General_LimitedEndurance then
        if brain.endurance == 0 then
            exhausted = true
        end
    end

    --BANDIT BLEEDING AND HEALING
    if SandboxVars.Bandits.General_BleedOut then
        if bandit:getHealth() < 1 then
            if ZombRand(12) == 1 then
                local bx = zx - 0.5 + ZombRandFloat(0.1, 0.9)
                local by = zy - 0.5 + ZombRandFloat(0.1, 0.9)
                bandit:getChunk():addBloodSplat(bx, by, 0, ZombRand(20))
            end
            bandit:setHealth(bandit:getHealth() - 0.00025)
            --print (bandit:getHealth())
            if not Bandit.HasActionTask(bandit) then

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
    end
    
    -- PATH COLLISION TASKS (FENCE, WINDOW JUMPING, DESTROYING BARRICADES, DOORS)
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
                    end

                    if instanceof(object, "IsoWindow") and program.name ~= "Defend" then
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
                                if SandboxVars.Bandits.General_RemoveBarricade then
                                    collide = true

                                    local task = {action="Equip", itemPrimary="Base.Crowbar"}
                                    table.insert(tasks, task)

                                    local task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)
                        
                                    local task = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=230, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                end

                            elseif not object:IsOpen() and not object:isSmashed() then
                                if SandboxVars.Bandits.General_SmashWindow then
                                    collide = true
                                    
                                    local task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)
                        
                                    local task = {action="SmashWindow", anim="WindowSmash", time=25, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ()}
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
                                    ClimbThroughWindowState.instance():setParams(zombie, object)
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

                            if object:isBarricaded() then
                                if SandboxVars.Bandits.General_RemoveBarricade then
                                    Bandit.SetCollidedAction(bandit, true)
                                    Bandit.ClearTasks(bandit)

                                    local task = {action="Equip", itemPrimary="Base.Crowbar"}
                                    table.insert(tasks, task)

                                    local task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)
                        
                                    local task = {action="Unbarricade", anim="RemoveBarricadeCrowbarHigh", time=230, x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), idx=object:getObjectIndex()}
                                    table.insert(tasks, task)
                                end

                            elseif object:isLocked() then
                                if SandboxVars.Bandits.General_DestroyDoor then
                                    Bandit.SetCollidedAction(bandit, true)
                                    Bandit.ClearTasks(bandit)

                                    local task = {action="Equip", itemPrimary=weapons.melee}
                                    table.insert(tasks, task)
                                    
                                    local task = {action="FaceLocation", x=fx, y=fy, z=object:getSquare():getZ(), time=30}
                                    table.insert(tasks, task)
                        
                                    local task = {action="Destroy", anim="ChopTree", x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), sound=object:getThumpSound(), time=80}
                                    table.insert(tasks, task)
                        
                                end
                            elseif not object:IsOpen() then
                                object:ToggleDoorSilent()
                                local args = {x=object:getSquare():getX(), y=object:getSquare():getY(), z=object:getSquare():getZ(), index=object:getObjectIndex()}
                                sendClientCommand(getPlayer(), 'Commands', 'ToggleDoor', args)

                                local material = object:getSprite():getProperties():Val("Material2")
                                bandit:playSound("WoodDoorOpen")
                            end
                        else
                            bandit:faceThisObject(object)
                        end
                        break
                    end

                    if instanceof(object, "IsoThumpable") and not properties:Val("FenceTypeLow") then
                        if SandboxVars.Bandits.General_DestroyThumpable then
                            Bandit.SetCollidedAction(bandit, true)
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
    
    local bestDist = 32

    -- COMBAT AGAIST PLAYERS 
    if Bandit.IsHostile(bandit) then
        local world = getWorld()
        local playerList = {}
        if gamemode == "Multiplayer" then
            playerList = getOnlinePlayers()
        else
            playerList = IsoPlayer.getPlayers()
        end
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            
            if player and bandit:CanSee(player) and not player:isBehind(bandit) then -- and not player:isGhostMode()
                local isWallTo = bandit:getSquare():isSomethingTo(player:getSquare())
                -- print (getPlayer():getOnlineID() .. " " .. zx .. " " .. zy)
                local dist = math.sqrt(math.pow(zx - player:getX(), 2) + math.pow(zy - player:getY(), 2))
                
                if dist < bestDist and not isWallTo then
                    bestDist = dist

                    if weapons.melee then
                        local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                        local minRange = itemMelee:getMaxRange()
                        if dist <= minRange + 0.1 then 
                            enemyCharacter = player
                            combat = true
                        end
                    end
                    
                    if weapons.primary and (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange then 
                        enemyCharacter = player
                        firing = true
                    elseif weapons.secondary and (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange then
                        enemyCharacter = player
                        firing = true
                    end
                end
            end
        end
        -- "------- DIST: " .. bestDist)
    end

    -- COMBAT AGAINST BANDITS FROM OTHER CLAN
    for i, coords in pairs(BanditMap.BMap) do
        if brain.clan ~= coords.clan then
            local dist = math.sqrt(math.pow(zx - coords.x, 2) + math.pow(zy - coords.y, 2))
            if dist < bestDist then
                bestDist = dist
                local square = cell:getGridSquare(coords.x, coords.y, coords.z)
                if square then
                    local potentialEnemy = square:getZombie()
                    if potentialEnemy and bandit:CanSee(potentialEnemy) then

                        if weapons.melee then
                            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                            local minRange = itemMelee:getMaxRange()
                            if dist <= minRange + 0.4 then
                                enemyCharacter = potentialEnemy
                                combat = true
                            end
                        end

                        if weapons.primary and  (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange - 6 then 
                            enemyCharacter = potentialEnemy
                            firing = true
                        elseif weapons.secondary and  (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange - 4 then
                            enemyCharacter = potentialEnemy
                            firing = true
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
            bestDist = dist
            local square = cell:getGridSquare(coords.x, coords.y, coords.z)
            if square then
                local potentialEnemy = square:getZombie()
                if potentialEnemy and bandit:CanSee(potentialEnemy) then

                    if weapons.melee then
                        local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
                        local minRange = itemMelee:getMaxRange()
                        if dist <= minRange + 0.4 then
                            enemyCharacter = potentialEnemy
                            combat = true
                        end
                    end

                    if weapons.primary and  (weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0) and dist < SandboxVars.Bandits.General_RifleRange - 6 then 
                        enemyCharacter = potentialEnemy
                        firing = true
                    elseif weapons.secondary and  (weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0) and dist < SandboxVars.Bandits.General_PistolRange - 4 then
                        enemyCharacter = potentialEnemy
                        firing = true
                    end
                end
            end
        end
    end

    -- UPDATE SITUATIONAL STATUSES
    if Bandit.IsCombat(bandit) ~= combat  and not Bandit.IsSleeping(bandit) then
        Bandit.ClearTasks(bandit)
        Bandit.SetCombat(bandit, combat)
    end

    if Bandit.IsFiring(bandit) ~= firing  and not Bandit.IsSleeping(bandit)then
        Bandit.ClearTasks(bandit)
        Bandit.SetFiring(bandit, firing)

        local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
        local aimTimeSurp = SandboxVars.Bandits.General_GunReflexRand or 35
        if aimTimeMin + aimTimeSurp > 0 then
            local task = {action="Time", anim="AimRifle", time=aimTimeMin + ZombRand(aimTimeSurp)}
            table.insert(tasks, task)
        end
        if ZombRand(10) == 1 then Bandit.Say(bandit, "SPOTTED") end
    end

    if exhausted and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        local task = {action="Time", anim="Exhausted", time=200, endurance=0.3}
        table.insert(tasks, task)

    elseif healing and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        local task = {action="Bandage", time=800}
        table.insert(tasks, task)

    elseif combat and weapons.melee and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        if not Bandit.HasTask(bandit)  then
            local veh = enemyCharacter:getVehicle()
            if veh and ZombRand(9) == 1 then Bandit.Say(bandit, "CAR") end

            local task = {action="Equip", itemPrimary=weapons.melee}
            Bandit.AddTask(bandit, task)
            local itemMelee = InventoryItemFactory.CreateItem(weapons.melee)
            local swingSound = itemMelee:getSwingSound()
 
            local anim
            if enemyCharacter:isAlive() then
                local task = {action="Hit", sound=swingSound, time=60, endurance=-0.2, weapon=weapons.melee, prone=enemyCharacter:isProne(), x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                table.insert(tasks, task)
            else

                local task = {action="Time", anim="Smoke", time=250}
                table.insert(tasks, task)

                if ZombRand(8) == 1 then Bandit.Say(bandit, "DEATH") end
            end

        end
    elseif firing and not bandit:isCrawling() and not Bandit.IsSleeping(bandit) then
        if not Bandit.HasTask(bandit) then
            if weapons.primary.name or weapons.secondary.name then
                if weapons.primary.bulletsLeft > 0 then

                    local task = {action="Equip", itemPrimary=weapons.primary.name}
                    table.insert(tasks, task)
    
                    local firingtime = weapons.primary.shotDelay
                    -- burst break
                    if ZombRand(5) == 1 then firingtime = 50 end

                    local task = {action="Shoot", anim="AimRifle", weaponSound=weapons.primary.shotSound, time=firingtime, weapon=weapons.primary.name, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                    table.insert(tasks, task)

                    weapons.primary.bulletsLeft = weapons.primary.bulletsLeft - 1
                else
                    if weapons.primary.magCount > 0 then
                        local task = {action="Drop", itemType=weapons.primary.magName, anim="UnloadRifle", sound="M14EjectAmmo", time=90}
                        table.insert(tasks, task)

                        local task = {action="Time", anim="ReloadRifle", sound="M14InsertAmmo", time=90}
                        table.insert(tasks, task)
                        if ZombRand(3) == 1 then Bandit.Say(bandit, "RELOADING") end

                        weapons.primary.bulletsLeft = weapons.primary.magSize
                        weapons.primary.magCount = weapons.primary.magCount - 1
                    else
                        if weapons.secondary.bulletsLeft > 0 then
                            
                            local task = {action="Equip", itemPrimary=weapons.secondary.name}
                            table.insert(tasks, task)

                            local task = {action="Shoot", anim="AimPistol", weaponSound=weapons.secondary.shotSound, time=weapons.secondary.shotDelay, weapon=weapons.secondary.name, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
                            table.insert(tasks, task)
                            
                            weapons.secondary.bulletsLeft = weapons.secondary.bulletsLeft - 1
                        else
                            if weapons.secondary.magCount > 0 then
                                local task = {action="Drop", itemType=weapons.secondary.magName, anim="UnloadPistol", sound="M9EjectAmmo", time=90}
                                table.insert(tasks, task)

                                local task = {action="Time", anim="ReloadPistol", sound="M9InsertAmmo", time=90}
                                table.insert(tasks, task)
                                if ZombRand(3) == 1 then Bandit.Say(bandit, "RELOADING") end

                                weapons.secondary.bulletsLeft = weapons.secondary.magSize
                                weapons.secondary.magCount = weapons.secondary.magCount - 1
                            end
                        end
                    end
                end
            end
            Bandit.SetWeapons(bandit, weapons)
        end

    elseif collide then
    else

        -- CUSTOM PROGRAM 
        if not Bandit.HasTask(bandit) then
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


    -- PROCESS FIRST TASK FROM THE LIST
    local task = Bandit.GetTask(bandit)
    if not task then return end
    if not task.action then return end
    if not task.state then task.state = "NEW" end
    
    if task.state == "NEW" then

        if task.sound then

            -- if the sound is too far, it will not be heard by player
            -- this applies to modded gun sounds, where distanceMax does not work
            -- this puts the sound 10 squares away preserving the right direction
            --[[ 
            local sx, sy
            sx, sy = BanditUtils.findPoint(player:getX(), player:getY(), bandit:getX(), bandit:getY(), 10)
            
            local emitter = world:getFreeEmitter(sx, sy, 0)
            emitter:playSound(task.sound)

            local soundSquare = cell:getGridSquare(sx, sy, 0)
            if soundSquare then
                soundSquare:playSound(task.sound)
            end

            ]]

            bandit:playSound(task.sound)
            
        end
        if task.anim then
            -- local item = InventoryItemFactory.CreateItem("farming.WateredCanFull")
            -- bandit:getNetworkCharacterAI():setOverride(true, item, nil)
            bandit:setBumpType(task.anim)
            -- bandit:reportEvent("wasBumped")
            --local ac = bandit:getActionContext()
            
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

    bandit:getEmitter():stopSoundByName("MaleZombieCombined")
    bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
    
end

function BanditUpdate.OnHitZombie(zombie)
    if zombie:getVariableBoolean("Bandit") then
        zombie:getEmitter():stopAll()
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
    
    local id = BanditUtils.GetCharacterID(zombie)
    local brain = BanditBrain.Get(zombie)

    if zombie:getVariableBoolean("Bandit") then
        zombie:setUseless(false)
        -- zombie:setReanim(true)
        -- zombie:setReanimateTimer(10)
        zombie:setVariable("Bandit", false)
        zombie:setPrimaryHandItem(nil)
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

function BanditUpdate.OnWeaponSwing(character, handWeapon)
    if instanceof(character, "IsoPlayer") then
        if handWeapon:isRanged() then
            print (#BanditMap.BMap)
            for _, b in pairs(BanditMap.BMap) do
                if b then
                    print ("FPUND")
                    local dist = math.sqrt(math.pow(character:getX() - b.x, 2) + math.pow(character:getY() - b.y, 2))
                    if dist < 12 then
                        
                        local zombie = getCell():getGridSquare(b.x, b.y, b.z):getZombie()
                        if zombie then
                            local brain = BanditBrain.Get(zombie)
                            if brain then
                                if Bandit.IsSleeping(zombie) then
                                    if ZombRand(4) == 1 then Bandit.Say(zombie, "SPOTTED") end
                                    local task = {action="Time", lock=true, anim="GetUp", time=150}
                                    Bandit.ClearTasks(zombie)
                                    Bandit.AddTask(zombie, task)
                                    Bandit.SetSleeping(zombie, false)
                                    Bandit.SetProgramStage(zombie, "Prepare")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnZombieUpdate.Add(BanditUpdate.OnBanditUpdate)
Events.OnHitZombie.Add(BanditUpdate.OnHitZombie)
Events.OnZombieDead.Add(BanditUpdate.OnZombieDead)
-- Events.OnWeaponSwing.Add(BanditUpdate.OnWeaponSwing)