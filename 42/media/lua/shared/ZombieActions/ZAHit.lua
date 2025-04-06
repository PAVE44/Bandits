ZombieActions = ZombieActions or {}

local stuckItemLocations = {
    ["Back"] = {
        ["MeatCleaver in Back"] = {
            "Base.HandAxe",
            "Base.MeatCleaver",
            "Base.HandAxe_Old",
            "Base.Machete",
            "Base.Machete_Crude",
            "Base.MeatCleaver_Scrap"
        },
        ["Axe Back"] = {
            "Base.Axe", 
            "Base.IceAxe",
            "Base.Axe_Old",
            "Base.Axe_Sawblade",
            "Base.Axe_Sawblade_Hatchet",
            "Base.Axe_ScrapCleaver",
            "Base.Hatchet_Bone",
            "Base.JawboneBovide_Axe"
        },
        ["Knife in Back"] = {
            "Base.ButterKnife",
            "Base.CarvingFork2",
            "Base.Fork",
            "Base.HandFork",
            "Base.LetterOpener",
            "Base.KnifeFillet",
            "Base.KnifeParing",
            "Base.Screwdriver",
            "Base.Scissors",
            "Base.TinOpener_Old",
            "Base.HuntingKnife",
            "Base.LargeKnife",
            "Base.BreadKnife",
            "Base.KitchenKnife",
            "Base.SteakKnife",
            "Base.CrudeKnife",
            "Base.FightingKnife",
            "Base.GlassShiv",
            "Base.KnifeShiv",
            "Base.LongCrudeKnife",
            "Base.LongStick_Broken",
            "Base.SharpBone_Long",
            "Base.Toothbrush_Shiv",
            "Base.Screwdriver_Improvised",
        }
    },
    ["Front"] = {
        ["Knife Left Leg"] = {
            "Base.ButterKnife",
            "Base.CarvingFork2",
            "Base.Fork",
            "Base.HandFork",
            "Base.LetterOpener",
            "Base.KnifeFillet",
            "Base.KnifeParing",
            "Base.Screwdriver",
            "Base.Scissors",
            "Base.TinOpener_Old",
            "Base.HandShovel",
            "Base.HuntingKnife",
            "Base.LargeKnife",
            "Base.MasonsTrowel",
            "Base.BreadKnife",
            "Base.KitchenKnife",
            "Base.SteakKnife",
            "Base.CrudeKnife",
            "Base.FightingKnife",
            "Base.GlassShiv",
            "Base.KnifeShiv",
            "Base.LongCrudeKnife",
            "Base.LongStick_Broken",
            "Base.SharpBone_Long",
            "Base.Toothbrush_Shiv",
            "Base.Screwdriver_Improvised",
        },
        ["Knife Right Leg"] = {
            "Base.ButterKnife",
            "Base.CarvingFork2",
            "Base.Fork",
            "Base.HandFork",
            "Base.LetterOpener",
            "Base.KnifeFillet",
            "Base.KnifeParing",
            "Base.Screwdriver",
            "Base.Scissors",
            "Base.TinOpener_Old",
            "Base.HandShovel",
            "Base.HuntingKnife",
            "Base.LargeKnife",
            "Base.MasonsTrowel",
            "Base.BreadKnife",
            "Base.KitchenKnife",
            "Base.SteakKnife",
            "Base.CrudeKnife",
            "Base.FightingKnife",
            "Base.GlassShiv",
            "Base.KnifeShiv",
            "Base.LongCrudeKnife",
            "Base.LongStick_Broken",
            "Base.SharpBone_Long",
            "Base.Toothbrush_Shiv",
            "Base.Screwdriver_Improvised",
        },
        ["Knife Shoulder"] = {
            "Base.ButterKnife",
            "Base.CarvingFork2",
            "Base.Fork",
            "Base.HandFork",
            "Base.LetterOpener",
            "Base.KnifeFillet",
            "Base.KnifeParing",
            "Base.Screwdriver",
            "Base.Scissors",
            "Base.TinOpener_Old",
            "Base.HuntingKnife",
            "Base.LargeKnife",
            "Base.MasonsTrowel",
            "Base.BreadKnife",
            "Base.KitchenKnife",
            "Base.SteakKnife",
            "Base.CrudeKnife",
            "Base.FightingKnife",
            "Base.GlassShiv",
            "Base.KnifeShiv",
            "Base.LongCrudeKnife",
            "Base.LongStick_Broken",
            "Base.SharpBone_Long",
            "Base.Toothbrush_Shiv",
            "Base.Screwdriver_Improvised",
            "Base.Machete",
            "Base.Machete_Crude",
            "Base.Sword_Scrap",
            "Base.Sword_Scrap_Broken",
        },
        ["Knife Stomach"] = {
            "Base.ButterKnife",
            "Base.CarvingFork2",
            "Base.Fork",
            "Base.HandFork",
            "Base.LetterOpener",
            "Base.KnifeFillet",
            "Base.KnifeParing",
            "Base.Screwdriver",
            "Base.Scissors",
            "Base.Stake",
            "Base.TinOpener_Old",
            "Base.HandShovel",
            "Base.HuntingKnife",
            "Base.LargeKnife",
            "Base.MasonsTrowel",
            "Base.BreadKnife",
            "Base.KitchenKnife",
            "Base.SteakKnife",
            "Base.CrudeKnife",
            "Base.FightingKnife",
            "Base.GlassShiv",
            "Base.KnifeShiv",
            "Base.LongCrudeKnife",
            "Base.LongStick_Broken",
            "Base.SharpBone_Long",
            "Base.Toothbrush_Shiv",
            "Base.Screwdriver_Improvised",
            "Base.BanjoNeck_Broken",
            "Base.BaseballBat_Broken",
            "Base.CarpentryChisel",
            "Base.ChairLeg",
            "Base.Crowbar",
            "Base.FieldHockeyStick_Broken",
            "Base.File",
            "Base.GardenToolHandle_Broken",
            "Base.GuitarAcousticNeck_Broken",
            "Base.GuitarElectricNeck_Broken",
            "Base.GuitarElectricBassNeck_Broken",
            "Base.Handle",
            "Base.LeadPipe",
            "Base.LongHandle_Broken",
            "Base.MasonsChisel",
            "Base.MetalBar",
            "Base.MetalPipe_Broken",
            "Base.MetalworkingChisel",
            "Base.Nightstick",
            "Base.PipeWrench",
            "Base.SheetMetalSnips",
            "Base.SteelBar",
            "Base.SteelBarHalf",
            "Base.SteelRodHalf",
            "Base.TableLeg_Broken",
            "Base.TireIron",
            "Base.BoltCutters",
            "Base.Bone",
            "Base.Branch_Broken",
            "Base.LargeBone",
            "Base.TreeBranch2",
        }
    }
}

local passengerToWindow = {
    "WindowFrontLeft",
    "WindowFrontRight",
    "WindowMiddleLeft",
    "WindowMiddleRight",
    "WindowRearLeft",
    "WindowRearRight"
}

local locationBlood = {
    ["MeatCleaver in Back"] = {"Back"},
    ["Axe Back"] = {"Back"},
    ["Knife in Back"] = {"Back"},
    ["Knife Left Leg"] = {"UpperLeg_L"},
    ["Knife Right Leg"]  = {"UpperLeg_R"},
    ["Knife Shoulder"] = {"UpperArm_L", "Torso_Upper"},
    ["Knife Stomach"] = {"Torso_Lower", "Back"}
}

local function getStuckLocations (behind, searchItemType)
    local ret = {}
    local locations = stuckItemLocations["Front"]
    if behind then 
        locations = stuckItemLocations["Back"]
    end

    for location, itemTypes in pairs(locations) do
        for _, itemType in pairs(itemTypes) do
            if itemType == searchItemType then
                table.insert(ret, location)
            end
        end
    end
    return ret
end

local function getBloodLocations (stuckLocation)
    local ret = {}
    if locationBlood[stuckLocation] then
        ret = locationBlood[stuckLocation]
    end
    return ret
end

local function addStuckItem(attacker, victim, behind, item)
    local visuals = victim:getHumanVisual()
    local itemVisuals = victim:getItemVisuals()

    local locations = getStuckLocations(behind, item:getFullType())

    if #locations > 0 then
        local location = BanditUtils.Choice(locations)
        victim:setAttachedItem(location, item)
        -- attacker:playSound(item:getBreakSound())
        attacker:playSound("ZSWeaponStuck")
        
        -- Bandit.Say(victim, "DEAD")
        local bloodLocations = getBloodLocations(location)
        for _, bloodLocation in pairs(bloodLocations) do
            visuals:setBlood(BloodBodyPartType[bloodLocation], 1)
            for i = 0, itemVisuals:size() - 1 do
                local itemVisual = itemVisuals:get(i)
                itemVisual:setBlood(BloodBodyPartType[bloodLocation], 1)
                local clothing = itemVisual:getInventoryItem()
                if instanceof(clothing, "Clothing") then
                    local coveredPartList = clothing:getCoveredParts()
                    for i=0, coveredPartList:size()-1 do
                        local coveredPart = coveredPartList:get(i)
                        if coveredPart == bloodLocation then
                            item:setHole(BloodBodyPartType[bloodLocation])
                        end
                    end
                end
            end
        end

        local hands = "Base.BareHands"
        local brainAttacker = BanditBrain.Get(attacker)
        brainAttacker.weapons.melee = hands

        local meleeItem = BanditCompatibility.InstanceItem(hands)
        attacker:setPrimaryHandItem(meleeItem)

        victim:resetModel()
    end
end

local function addBlood (character, chance)

    local visuals = character:getHumanVisual()
    local maxIndex = BloodBodyPartType.MAX:index()
    for i = 0, maxIndex - 1 do
        local part = BloodBodyPartType.FromIndex(i)
        local blood = visuals:getBlood(part)
        if ZombRand(100) < chance then
            visuals:setBlood(part, blood + 0.1)
        end
    end

    local itemVisuals = character:getItemVisuals()
    for i = 0, itemVisuals:size() - 1 do
        local item = itemVisuals:get(i)
        if item then
            for j = 0, maxIndex - 1 do
                local part = BloodBodyPartType.FromIndex(j)
                local blood = item:getBlood(part)
                if ZombRand(100) < chance then
                    item:setBlood(part, blood + 0.1)
                end
            end
        end
    end
    character:resetModelNextFrame()
    character:resetModel()
end

local function Hit(attacker, item, victim)
    -- Clone the attacker to create a temporary IsoPlayer
    local tempAttacker = BanditUtils.CloneIsoPlayer(attacker)

    -- Calculate distance between attacker and victim
    local dist = BanditUtils.DistTo(victim:getX(), victim:getY(), tempAttacker:getX(), tempAttacker:getY())
    local range = item:getMaxRange()
    if dist < range + 0.5 then

        if instanceof(victim, "IsoPlayer") then
            BanditPlayer.WakeEveryone()
        end

        local vehicle = victim:getVehicle()
        local protected = false
        if vehicle then
            local square = vehicle:getSquare()
            victim:playSound("HitVehicleWindowWithWeapon")
            local seat = vehicle:getSeat(victim) + 1
            local windowName = passengerToWindow[seat]
            local vehiclePart = vehicle:getPartById(windowName)
            if vehiclePart and vehiclePart:getInventoryItem() then
                protected = false
                local window = vehiclePart:getWindow()
                if window and not window:isOpen() then
                    local vehiclePartId = vehiclePart:getId()
                    vehiclePart:damage(20)
            
                    if vehiclePart:getCondition() <= 0 then
                        vehiclePart:setInventoryItem(nil)
                        square:playSound("SmashWindow")
                    else
                        protected = true
                        square:playSound("BreakGlassItem")
                    end

                    vehicle:updatePartStats()

                    local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                    sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)
                end
            end
        else
            if victim:isSprinting() or victim:isRunning() and ZombRand(6) == 1 then
                victim:clearVariable("BumpFallType")
                victim:setBumpType("stagger")
                victim:setBumpFall(true)
                victim:setBumpFallType("pushedBehind")
            end
        end

        if not protected then
            local behind = attacker:isBehind(victim)
            victim:setHitFromBehind(behind)
            victim:setAttackedBy(attacker)

            if instanceof(victim, "IsoZombie") then
                victim:setHitAngle(attacker:getForwardDirection())
                victim:setPlayerAttackPosition(victim:testDotSide(attacker))
                if BanditRandom.Get() % 4 == 0 then
                    addStuckItem(attacker, victim, behind, item)
                end
            end

            if item:getFullType() == "Base.BareHands" and instanceof(victim, "IsoPlayer") then
                PlayerDamageModel.BareHandHit(attacker, victim)
            else
                victim:setBumpDone(true)
                victim:Hit(item, tempAttacker, 1.4, false, 1, false)

                local h = victim:getHealth()
                local id = BanditUtils.GetCharacterID(victim)
                local args={id=id, h=h}
                sendClientCommand(getSpecificPlayer(0), 'Sync', 'Health', args)
            end
            
            victim:playSound(item:getZombieHitSound())

            -- addBlood(victim, 100)
            -- addBlood(attacker, 30)
            
            BanditCompatibility.Splash(victim, item, tempAttacker)
                
            if instanceof(victim, "IsoPlayer") then
                BanditCompatibility.PlayerVoiceSound(victim, "PainFromFallHigh")
            end

            if victim:getHealth() <= 0 then 
                -- victim:setKnifeDeath(true)
                -- :Kill(getCell():getFakeZombieForHit(), true) 
            end
        end
        
        -- addSound(getPlayer(), victim:getX(), victim:getY(), victim:getZ(), 4, 50)
    end

    -- Clean up the temporary player after use
    tempAttacker:removeFromWorld()
    tempAttacker = nil
end

ZombieActions.Hit = {}
ZombieActions.Hit.onStart = function(bandit, task)
    local anim 
    local soundSwing, soundVoice

    local enemy = BanditZombie.Cache[task.eid] or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end
    
    local prone = enemy:isProne() or enemy:getActionStateName() == "onground" or enemy:getActionStateName() == "sitonground" or enemy:getActionStateName() == "climbfence" 
    local female = bandit:isFemale()
    local meleeItem = BanditCompatibility.InstanceItem(task.weapon)
    local meleeItemType = WeaponType.getWeaponType(meleeItem)

    local soundSwing = meleeItem:getSwingSound()

    if prone then
        task.prone = true
        if ZombRand(2) == 0 and task.weapon ~= "Base.BareHands" then
            anim = "Attack2HFloor"
        else
            anim = "Attack2HStamp"
            soundSwing = "AttackStomp"
            soundVoice = female and "VoiceFemaleMeleeStomp" or "VoiceMaleMeleeStomp"
        end
    else

        local attacks
        soundVoice = female and "VoiceFemaleMeleeAttack" or "VoiceMaleMeleeAttack"
        if task.weapon == "Base.BareHands" or meleeItemType == WeaponType.barehand then
            attacks = {"AttackBareHands1", "AttackBareHands2", "AttackBareHands3", "AttackBareHands4", "AttackBareHands5", "AttackBareHands6"}
        elseif meleeItemType == WeaponType.twohanded then
            attacks = {"Attack2H1", "Attack2H2", "Attack2H3", "Attack2H4"}
        -- elseif meleeItemType == WeaponType.heavy then
        --    attacks = {"Attack2HHeavy1", "Attack2HHeavy2"}
        elseif meleeItemType == WeaponType.onehanded then
            attacks = {"Attack1H1", "Attack1H2", "Attack1H3", "Attack1H4", "Attack1H5"}
        elseif meleeItemType == WeaponType.spear then
            attacks = {"AttackS1", "AttackS2"}
        elseif meleeItemType == WeaponType.chainsaw then
            attacks = {"AttackChainsaw1", "AttackChainsaw2"}
        elseif meleeItemType == WeaponType.knife then
            soundVoice = female and "VoiceFemaleMeleeStab" or "VoiceMaleMeleeStab"
            attacks = {"AttackKnife"} -- , "AttackKnifeMiss"
        else -- two handed / knife ?
            attacks = {"Attack2H1", "Attack2H2", "Attack2H3", "Attack2H4"}
        end

        if attacks then 
            anim = attacks[1+ZombRand(#attacks)]
        end
    end

    if soundSwing then
        bandit:playSound(soundSwing)
    end
    if soundVoice then
        bandit:playSound(soundVoice)
    end

    if anim then
        task.anim = anim
        -- Bandit.UpdateTask(bandit, task)
        bandit:setBumpType(anim)
    else
        return false
    end
    return true
end

ZombieActions.Hit.onWorking = function(bandit, task)
    bandit:faceLocation(task.x, task.y)
    local bumpType = bandit:getBumpType()

    if bumpType ~= task.anim then return false end
    
    if not task.hit and task.time <= 50 then

        task.hit = true

        local asn = bandit:getActionStateName()
        -- print ("HIT AS:" .. asn)
        if asn == "getup" or asn == "getup-fromonback" or asn == "getup-fromonfront" or asn == "getup-fromsitting"
                 or asn =="staggerback" or asn == "staggerback-knockeddown" then return false end

        Bandit.UpdateTask(bandit, task)

        local item = BanditCompatibility.InstanceItem(task.weapon)
        local enemy = BanditZombie.Cache[task.eid]
        if enemy then 
            local brainBandit = BanditBrain.Get(bandit)
            local brainEnemy = BanditBrain.Get(enemy)
            if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
                Hit (bandit, item, enemy)
            end
        end

        if Bandit.IsHostile(bandit) then
            local player = BanditPlayer.GetPlayerById(task.eid)
            if player then
                local eid = BanditUtils.GetCharacterID(player)
                if player:isAlive() and eid == task.eid then
                    Hit (bandit, item, player)
                end
            end
        end

        return false

    end
    
    return false
end

ZombieActions.Hit.onComplete = function(bandit, task)
    return true
end