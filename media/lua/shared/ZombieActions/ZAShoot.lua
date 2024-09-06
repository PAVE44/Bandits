ZombieActions = ZombieActions or {}

local function ATROShoot(bandit, handWeapon)
    
    if getSandboxOptions():getOptionByName("Advanced_trajectory.showOutlines"):getValue() and instanceof(handWeapon,"HandWeapon") and not handWeapon:hasTag("Thrown") and not Advanced_trajectory.hasFlameWeapon and not (handWeapon:hasTag("XBow") and not getSandboxOptions():getOptionByName("Advanced_trajectory.DebugEnableBow"):getValue()) and (handWeapon:isRanged() and getSandboxOptions():getOptionByName("Advanced_trajectory.Enablerange"):getValue()) then
        handWeapon:setMaxHitCount(getSandboxOptions():getOptionByName("Advanced_trajectory.DebugHitCountShoot"):getValue())
    end

    local banditLevel = 8
    local modEffectsTable = Advanced_trajectory.getAttachmentEffects(handWeapon)  

    -- print(character)
    local item
    local winddir = 1
    local weaponname = ""
    local rollspeed = 0
    local iscanthrough = false
    local ballisticspeed = 0.15  
    local ballisticdistance = handWeapon:getMaxRange() 
    local itemtypename = ""
    local iscanbigger = 0
    local sfxname = ""
    local isthroughwall =true
    local distancez = 0

    local deltX
    local deltY
    local ProjectileCount = 1

    local throwinfo ={}
    local ispass =false


    local square
    local _damage

    -- direction from -pi to pi OR -180 to 180 deg
    -- N (top left corner): pi,-pi  (180, -180)
    -- W (bottom left): pi/2 (90)
    -- E (top right): -pi/2 (-90)
    -- S (bottom right corner): 0
    local banditDir = bandit:getForwardDirection():getDirection()

    -- bullet position 
    local spawnOffset = getSandboxOptions():getOptionByName("Advanced_trajectory.DebugSpawnOffset"):getValue()
    local offx = bandit:getX() + spawnOffset * math.cos(banditDir)
    local offy = bandit:getY() + spawnOffset * math.sin(banditDir)
    local offz = bandit:getZ()

    --local offx = character:getX()
    --local offy = character:getY()
    --local offz = character:getZ()

    -- pi/250 = .7 degrees
    -- aimnum can go up to (77-9+40) 108 
    -- max/min -+96 degrees, and even more when drunk (6*24+108 = 252 => 208 deg)
    -- og denominator was 250

    local maxProjCone = getSandboxOptions():getOptionByName("Advanced_trajectory.MaxProjCone"):getValue()
    -- 120 as max aimnum
    local denom = 120 * math.pi / maxProjCone
    Advanced_trajectory.aimrate = Advanced_trajectory.aimnum * math.pi / denom

    --print("MaxProjCone: ", maxProjCone)
    --print("Aimrate: ", Advanced_trajectory.aimrate )
    
    -- NOTES: I'm assuming aimrate, which is affected by aimnum, determines how wide the bullets can spread.
    -- adding dirc (direction player is facing) will cause bullets to go towards the direction of where player is looking
    local dirc = banditDir + ZombRandFloat(-Advanced_trajectory.aimrate, Advanced_trajectory.aimrate)

    --print("Dirc: ", dirc)
    deltX = math.cos(dirc)
    deltY = math.sin(dirc)

    local tablez = 
    {
        item,                       --1 item obj
        square,                     --2 square obj
        {deltX,deltY},              --3 vector
        {offx, offy, offz},         --4 offset BULLET POS
        dirc,                       --5 direction
        _damage,                    --6 damage
        ballisticdistance,          --7 distance
        winddir,                    --8 ballistic small categories
        weaponname,                 --9 types
        rollspeed,                  --10 rotation speed
        iscanthrough,               --11 whether it can penetrate
        ballisticspeed,             --12 ballistic speed
        iscanbigger,                --13 can be made bigger
        sfxname,                    --14 ballistic name
        isthroughwall,              --15 whether it can pass through the wall
        1,                          --16 size
        0,                          --17 current distance
        distancez,                  --18 distance constant
        bandit,                     --19 players
        {offx, offy, offz},         --20 original offset PLAYER POS
        0,                          --21 count
        throwinfo                   --22 thrown object attributes                                                       
    }

    tablez["boomsfx"] = {}
    tablez["animlevels"] = Advanced_trajectory.aimlevels or math.floor(tablez[4][3])

    tablez[22] = {
        handWeapon:getSmokeRange(),
        handWeapon:getExplosionPower(),
        handWeapon:getExplosionRange(),
        handWeapon:getFirePower(),
        handWeapon:getFireRange()
    }

    tablez[22][7] = handWeapon:getExplosionSound()

    tablez["ThroNumber"] = 1

    local isspweapon = Advanced_trajectory.Advanced_trajectory[handWeapon:getFullType()] 
    if isspweapon then
        for lk,pk in pairs(isspweapon) do
            if lk == 4 then
                tablez[4][1] = tablez[4][1] + pk[1] * tablez[3][1]
                tablez[4][2] = tablez[4][2] + pk[2] * tablez[3][2]
                tablez[4][3] = tablez[4][3] + pk[3]
            else 
                tablez[lk] = pk
            end
            
        end
        ispass = true
    end

    if Advanced_trajectory.aimcursorsq then
        tablez[18] = ((Advanced_trajectory.aimcursorsq:getX()+0.5-offx) ^ 2 + (Advanced_trajectory.aimcursorsq:getY()+0.5-offy)^2) ^ 0.5
    else
        tablez[18] = 32 -- handWeapon:getMaxRange(character)
    end

    local isHoldingShotgun = false
    if not ispass then  
        if getSandboxOptions():getOptionByName("Advanced_trajectory.Enablethrow"):getValue() and handWeapon:getSwingAnim() =="Throw" then 
   
            if tablez[22][1] == 0 and tablez[22][2] == 0 and tablez[22][4] == 0 then
                tablez[22][6] = 0.016
            else
                tablez[22][6] = 0.04 -- radian
            end
            
            tablez[22][9] = handWeapon:canBeReused()
            tablez[7] = tablez[18]
            tablez[9]="Grenade"
            tablez[14] = handWeapon:getFullType()
            tablez[8] = ""
            tablez[11] = false
            tablez[15] = false

            tablez[4][1] = tablez[4][1] + 0.3 * tablez[3][1]
            tablez[4][2] = tablez[4][2] + 0.3 * tablez[3][2]

            tablez[10] = 6
            tablez[12] = 0.3
    
            tablez[22][10] = tablez[14]
            tablez[22][11] = handWeapon:getNoiseRange()

            tablez["isparabola"] = tablez[22][6]
        
            -- disabling enable range means guns don't work (no projectiles)
        elseif getSandboxOptions():getOptionByName("Advanced_trajectory.Enablerange"):getValue() and (handWeapon:getSubCategory() =="Firearm" or handWeapon:getSubCategory() =="BBGun") then ----枪

            local hideTracer = getSandboxOptions():getOptionByName("Advanced_trajectory.hideTracer"):getValue()
            --print("Tracer hidden: ", hideTracer)

            local offset = getSandboxOptions():getOptionByName("Advanced_trajectory.DebugOffset"):getValue()

            --print("Range enabled...Weapon is Firearm.")
            if getIsHoldingShotgun(handWeapon) then
                local shotgunDistanceModifier = getSandboxOptions():getOptionByName("Advanced_trajectory.shotgunDistanceModifier"):getValue()
                
                tablez[9] = "Shotgun" --weapon name

                --print("Weapon has shotgun type ammo.")

                --wpn sndfx
                if hideTracer then
                    --print("Empty")
                    tablez[14] = "Empty.aty_Shotguna"    
                else
                    --print("Base")
                    tablez[14] = "Base.aty_Shotguna"  
                end

                -- Shotgun's max cone spread is independent from default spread
                local maxShotgunProjCone = getSandboxOptions():getOptionByName("Advanced_trajectory.maxShotgunProjCone"):getValue()
                if (dirc > banditDir + maxShotgunProjCone or dirc < banditDir - maxShotgunProjCone) then
                    tablez[5] = banditDir + ZombRandFloat(-maxShotgunProjCone, maxShotgunProjCone)
                end

                tablez[12] = 1.6                                    --ballistic speed
                tablez[7] = tablez[7] * shotgunDistanceModifier     --ballistic distance
                tablez[15] = false                                  --isthroughwall

                tablez[4][1] = tablez[4][1] + offset*tablez[3][1]    --offsetx=offsetx +.6 * deltX; deltX is cos of dirc
                tablez[4][2] = tablez[4][2] + offset*tablez[3][2]    --offsety=offsety +.6 * deltY; deltY is sin of dirc
                tablez[4][3] = tablez[4][3]+0.5                      --offsetz=offsetz +.5

                isHoldingShotgun = true
            
            elseif string.contains(handWeapon:getAmmoType() or "", "INCRound") or string.contains(handWeapon:getAmmoType() or "", "HERound") then 
                -- The idea here is to solve issue of Brita's launchers spawning a bullet along with their grenade.
                --print("Weapon has round type ammo (Brita grenades).")
                return
            elseif Advanced_trajectory.hasFlameWeapon then 
                -- Break bullet if flamethrower
                --print("Weapon is flame type.")
                return
            elseif ((handWeapon:hasTag("XBow") and not getSandboxOptions():getOptionByName("Advanced_trajectory.DebugEnableBow"):getValue()) or handWeapon:hasTag("Thrown")) then
                -- Break bullet if bow
                --print("Weapon is either bow or throwable nonexplosive.")
                return
            else
                --print("Weapon is a normal gun (revolver).")

                tablez[9] = "revolver"

                --wpn sndfx
                if hideTracer then
                    --print("Empty")
                    tablez[14] = "Empty.aty_revolversfx"  
                else
                    --print("Base")
                    tablez[14] = "Base.aty_revolversfx" 
                end


                tablez[12] = 1.8
                tablez[15]  = false

                tablez[4][1] = tablez[4][1] + offset*tablez[3][1]
                tablez[4][2] = tablez[4][2] + offset*tablez[3][2]
                tablez[4][3] = tablez[4][3] + 0.5

                -- determines number of zombies it can hit with one bullet (pen), if enabled set to stat. Else it will be set to 1 in checkontick.
                if getSandboxOptions():getOptionByName("Advanced_trajectory.enableBulletPenFlesh"):getValue() then
                    tablez["ThroNumber"] = ScriptManager.instance:getItem(handWeapon:getFullType()):getMaxHitCount()
                else
                    tablez["ThroNumber"] = 1
                end

                isHoldingShotgun = false
            end
        else
            --print("Weapon is not firearm, but ", handWeapon:getSubCategory())
            return      
        end
        

    end

    tablez[2] = tablez[2] or getWorld():getCell():getGridSquare(offx,offy,offz)
    if tablez[2] == nil then return end

    -- NOTES: tablez[6] is damage, firearm damages vary from 0 to 2. Example, M16 has min to max: 0.8 to 1.4 (source wiki)
    tablez[6] = tablez[6] or (handWeapon:getMinDamage() + ZombRandFloat(0.1, 1.3) * (0.5 + handWeapon:getMaxDamage() - handWeapon:getMinDamage()))

    if isHoldingShotgun then
        local shotgunDamageMultiplier = getSandboxOptions():getOptionByName("Advanced_trajectory.shotgunDamageMultiplier"):getValue()
        tablez[6] = tablez[6] * shotgunDamageMultiplier
    end
    
    -- firearm crit chance can vary from 0 to 30. Ex, M16 has a crit chance of 30 (source wiki)
    -- Rifles - 25 to 30
    -- M14 - 0 crit but higher hit chance
    -- Pistols - 20
    -- Shotguns - 60 to 80
    -- Lower aimnum (to reduce spamming crits with god awful bloom) and higher player level means higher crit chance.
    local critChanceModifier = getSandboxOptions():getOptionByName("Advanced_trajectory.critChanceModifier"):getValue() 
    local critChanceAdd = (Advanced_trajectory.aimnumBeforeShot*critChanceModifier) + (11-banditLevel)

    -- higher = higher crit chance
    local critIncreaseShotgun = getSandboxOptions():getOptionByName("Advanced_trajectory.critChanceModifierShotgunsOnly"):getValue() 
    if isHoldingShotgun then
        critChanceAdd = (critChanceAdd * 0) - (critIncreaseShotgun - banditLevel)
    end
    if ZombRand(100+critChanceAdd) <= handWeapon:getCriticalChance() then
        tablez[6]=tablez[6] * 2
    end


    -- throwinfo[8] = tablez[6]
    tablez[22][8] = handWeapon:getMinDamage()

    -- tablez[5] is dirc
    local dirc1 = tablez[5]
    tablez[5] = tablez[5]*360 / (2*math.pi)

    -- ballistic speed
    tablez[12] = tablez[12] * getSandboxOptions():getOptionByName("Advanced_trajectory.bulletspeed"):getValue() 

    -- bullet distance
    tablez[7] = tablez[7] * getSandboxOptions():getOptionByName("Advanced_trajectory.bulletdistance"):getValue() 


    ------------------------------
    -----RANGE ATTACHMENT EFFECT--
    ------------------------------
    local rangeMod = modEffectsTable[4]
    if rangeMod ~= 0 then
        tablez[7] = tablez[7] + rangeMod
    end

    local bulletnumber = getSandboxOptions():getOptionByName("Advanced_trajectory.shotgunnum"):getValue() 

    local damagemutiplier = getSandboxOptions():getOptionByName("Advanced_trajectory.ATY_damage"):getValue()  or 1

    -- NOTES: damage is multiplied by user setting (default 1)
    tablez[6] = tablez[6] * damagemutiplier

    local damageer = tablez[6]

    Advanced_trajectory.aimnumBeforeShot = Advanced_trajectory.aimnum

    -- print(tablez[5])
    if tablez[9] == "Shotgun" then

        local aimtable = {}

        for shot = 1, bulletnumber do
            local adirc

            -- lower value means tighter spread
            local numpi = getSandboxOptions():getOptionByName("Advanced_trajectory.shotgundivision"):getValue() *0.7

            --------------------------------
            -----ANGLE ATTACHMENT EFFECT---
            --------------------------------
            local angleMod = modEffectsTable[5]
            if angleMod ~= 0 then
                numpi = numpi * angleMod
            end


            adirc = dirc1 +ZombRandFloat(-math.pi * numpi,math.pi*numpi)

            tablez[3] = {math.cos(adirc), math.sin(adirc)}
            tablez[4] = {tablez[4][1], tablez[4][2], tablez[4][3]}
            tablez[5] = adirc * 360 / (2 * math.pi)
            tablez[20] = {tablez[4][1], tablez[4][2], tablez[4][3]}

            tablez[6] = damageer / 4

            if getSandboxOptions():getOptionByName("Advanced_trajectory.enableHitOrMiss"):getValue() then
                tablez["missedShot"] = determineHitOrMiss() 
            end
            

            if isClient() then
                tablez["nonsfx"] = 1
                sendClientCommand("ATY_shotsfx","true",{tablez, getPlayer():getOnlineID()})
            end
            tablez["nonsfx"] = nil
            table.insert(Advanced_trajectory.table,Advanced_trajectory.twotable(tablez))
        end
    else

        -- print(tablez[9])
        if tablez["wallcarmouse"] then
            tablez[7] = Advanced_trajectory.aimtexdistance - 1
        end
        tablez[20] = {offx, offy, tablez[4][3]}

        if getSandboxOptions():getOptionByName("Advanced_trajectory.enableHitOrMiss"):getValue() then
            tablez["missedShot"] = determineHitOrMiss() 
        end

        table.insert(Advanced_trajectory.table,Advanced_trajectory.twotable(tablez))
        if isClient() then
            tablez["nonsfx"] = 1
            sendClientCommand("ATY_shotsfx","true",{tablez,getPlayer():getOnlineID()})
        end

        -- print(Advanced_trajectory.aimtexdistance)
    end
end

local function Hit(shooter, item, victim)

    -- Clone the shooter to create a temporary IsoPlayer
    local tempShooter = BanditUtils.CloneIsoPlayer(shooter)

    -- Calculate the distance between the shooter and the victim
    local dist = math.sqrt(math.pow(tempShooter:getX() - victim:getX(), 2) + math.pow(tempShooter:getY() - victim:getY(), 2))

    -- Determine accuracy based on SandboxVars and shooter clan
    local brainShooter = BanditBrain.Get(shooter)
    local accuracyBoost = brainShooter.accuracyBoost or 1
    local accuracyLevel = SandboxVars.Bandits.General_OverallAccuracy
    local accuracyCoeff = 0.11
    if accuracyLevel == 1 then
        accuracyCoeff = 0.5
    elseif accuracyLevel == 2 then
        accuracyCoeff = 0.22
    elseif accuracyLevel == 3 then
        accuracyCoeff = 0.11
    elseif accuracyLevel == 4 then
        accuracyCoeff = 0.06
    elseif accuracyLevel == 5 then
        accuracyCoeff = 0.028
    end

    local accuracyThreshold = 100 / (1 + accuracyCoeff * dist / accuracyBoost)

    if ZombRand(100) < accuracyThreshold then
        local hitSound = "ZSHit" .. tostring(1 + ZombRand(3))
        victim:playSound(hitSound)
        victim:forceAwake()
        
        if instanceof(victim, 'IsoPlayer') and SandboxVars.Bandits.General_HitModel == 2 then
            PlayerDamageModel.BulletHit(tempShooter, victim)
        else
            if victim:isSprinting() or (victim:isRunning() and ZombRand(8) == 1) then
                victim:clearVariable("BumpFallType")
                victim:setBumpType("stagger")
                victim:setBumpFall(true)
                victim:setBumpFallType("pushedBehind")
            else
                victim:Hit(item, tempShooter, 0.8, false, 0.8, false)
            end

            victim:addBlood(0.6)
            SwipeStatePlayer.splash(victim, item, tempShooter)
            if victim:getHealth() <= 0 then victim:Kill(getCell():getFakeZombieForHit(), true) end
        end
    else
        local missSound = "ZSMiss".. tostring(1 + ZombRand(8))
        -- victim:getSquare():playSound(missSound)
    end

    -- Clean up the temporary player after use
    tempShooter:removeFromWorld()
    tempShooter = nil

    return true
end

-- Bresenham's line of fire to detect what needs to destroyed between shooter and target
local function ManageLineOfFire (shooter, victim)
    local cell = getCell()
    local player = getPlayer()
    
    local x0 = shooter:getX()
    local y0 = shooter:getY()
    local x1 = victim:getX()
    local y1 = victim:getY()

    if x0 > x1 then x0, x1 = x1, x0 end
    if y0 > y1 then y0, y1 = y1, y0 end

    local dx = x1 - x0
    local dy = y1 - y0
    local D = 2 * dy - dx
    local y = y0
    
    for x = x0, x1 do

        for sx = -1, 1 do
            for sy = -1, 1 do

                local square = cell:getGridSquare(math.floor(x + 0.5) + sx, math.floor(y + 0.5) + sy, 0)

                if square then
                    -- smash windows
                    local window = square:getWindow()
                    if window and not window:isSmashed() then
                        square:playSound("SmashWindow")
                        window:smashWindow()
                    end

                    local vehicle = square:getVehicleContainer()
                    if vehicle then
                        local partRandom = ZombRand(30)

                        local vehiclePart
                        if partRandom == 1 then
                            vehiclePart = vehicle:getPartById("HeadlightLeft")
                        elseif partRandom == 2 then
                            vehiclePart = vehicle:getPartById("HeadlightRight")
                        elseif partRandom == 3 then
                            vehiclePart = vehicle:getPartById("HeadlightRearLeft")
                        elseif partRandom == 4 then
                            vehiclePart = vehicle:getPartById("HeadlightRight")
                        elseif partRandom == 5 then
                            vehiclePart = vehicle:getPartById("Windshield")
                        elseif partRandom == 6 then
                            vehiclePart = vehicle:getPartById("WindshieldRear")
                        elseif partRandom == 7 then
                            vehiclePart = vehicle:getPartById("WindowFrontRight")
                        elseif partRandom == 8 then
                            vehiclePart = vehicle:getPartById("WindowFrontLeft")
                        elseif partRandom == 9 then
                            vehiclePart = vehicle:getPartById("WindowRearRight")
                        elseif partRandom == 10 then
                            vehiclePart = vehicle:getPartById("WindowRearLeft")
                        elseif partRandom == 11 then
                            vehiclePart = vehicle:getPartById("WindowMiddleLeft")
                        elseif partRandom == 12 then
                            vehiclePart = vehicle:getPartById("WindowMiddleRight")
                        elseif partRandom == 13 then
                            vehiclePart = vehicle:getPartById("DoorFrontRight")
                        elseif partRandom == 14 then
                            vehiclePart = vehicle:getPartById("DoorFrontLeft")
                        elseif partRandom == 15 then
                            vehiclePart = vehicle:getPartById("DoorRearRight")
                        elseif partRandom == 16 then
                            vehiclePart = vehicle:getPartById("DoorRearLeft")
                        elseif partRandom == 17 then
                            vehiclePart = vehicle:getPartById("EngineDoor")
                        elseif partRandom == 18 then
                            vehiclePart = vehicle:getPartById("TireFrontRight")
                        elseif partRandom == 19 then
                            vehiclePart = vehicle:getPartById("TireFrontLeft")
                        elseif partRandom == 20 then
                            vehiclePart = vehicle:getPartById("TireRearLeft")
                        elseif partRandom == 21 then
                            vehiclePart = vehicle:getPartById("TireRearRight")
                        else
                            return false
                        end

                        if vehiclePart and vehiclePart:getInventoryItem() then
                            
                            local vehiclePartId = vehiclePart:getId()

                            if vehiclePart:getCondition() <= 0 then
                                vehiclePart:setInventoryItem(nil)
                            end

                            if partRandom <= 4 then
                                local dmg = 20 + ZombRand(5)
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                square:playSound("BreakGlassItem")
                                return false
                            elseif partRandom <= 12 then
                                local dmg = 20 + ZombRand(10)
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("SmashWindow")
                                else
                                    square:playSound("BreakGlassItem")
                                    return false
                                end
                            elseif partRandom <= 17 then
                                local dmg = 15 + ZombRand(5)
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                square:playSound("HitVehiclePartWithWeapon")
                                if vehiclePart:getCondition() > 0 then
                                    return false
                                end
                            elseif partRandom <= 21 then
                                local dmg = 10 + ZombRand(30)
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("VehicleTireExplode")
                                end
                                return false
                            end

			                vehicle:updatePartStats()
                        end

                        --
                    end

                    -- cant shoot through the closed door (although bandits can see through them)
                    local door = square:getIsoDoor()
                    if door and not door:IsOpen() then
                        return false
                    end
                end
            end
        end

        if D > 0 then
            y = y + 1
            D = D - 2 * dx
        end
        D = D + 2 * dy
    end
    return true
end

ZombieActions.Shoot = {}
ZombieActions.Shoot.onStart = function(zombie, task)
    return true
end

ZombieActions.Shoot.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)

    return false
end

ZombieActions.Shoot.onComplete = function(zombie, task)
    local shooter = zombie
    local cell = shooter:getSquare():getCell()

    -- local item = InventoryItemFactory.CreateItem("Base.AssaultRifle2")
    -- ATROShoot(shooter, item)

    local brainShooter = BanditBrain.Get(shooter)
    
    shooter:startMuzzleFlash()
    shooter:playSound(task.weaponSound)
    
    -- this adds world sound that attract zombies, it must be on cooldown
    -- otherwise too many sounds disorient zombies. 
    if not brainShooter.sound or brainShooter.sound == 0 then
        addSound(getPlayer(), shooter:getX(), shooter:getY(), shooter:getZ(), 40, 100)
        brainShooter.sound = 1
        BanditBrain.Update(shooter, brainShooter)
    end

    for dx=-2, 2 do
        for dy=-2, 2 do
            local square = cell:getGridSquare(task.x + dx, task.y + dy, task.z)

            if square then
                local victim

                if brainShooter.hostile then
                    victim = square:getPlayer()
                end

                if not victim and math.abs(dx) <= 1 and math.abs(dy) <= 1 then
                    local testVictim = square:getZombie()

                    if testVictim then
                        local brainVictim = BanditBrain.Get(testVictim)
                        if not brainVictim or not brainVictim.clan or brainShooter.clan ~= brainVictim.clan or (brainShooter.hostile and not brainVictim.hostile) then 
                            victim = testVictim
                        end
                    end
                end
                
                if victim then
                    if BanditUtils.GetCharacterID(shooter) ~= BanditUtils.GetCharacterID(victim) then 
                        local res = ManageLineOfFire(shooter, victim)
                        if res then
                            local item = InventoryItemFactory.CreateItem(task.weapon)
                            Hit(shooter, item, victim)
                        end
                        
                        break
                    end
                end
            end
        end
    end

    return true
end