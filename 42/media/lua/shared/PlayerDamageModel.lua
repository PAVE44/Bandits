
PlayerDamageModel = PlayerDamageModel or {}

function PlayerDamageModel.BulletHit(shooter, item, player)
    local playerBodyDamage = player:getBodyDamage()
    local health = playerBodyDamage:getOverallBodyHealth()

    -- SELECT BODY PART THAT WAS HIT
    local bodyPartTypes = {
        Foot_R = {prob = 1, dmg=5},
        Foot_L = {prob = 1, dmg=5},
        LowerLeg_R = {prob = 4, dmg=5},
        LowerLeg_L = {prob = 4, dmg=5},
        UpperLeg_R = {prob = 6, dmg=5},
        UpperLeg_L = {prob = 6, dmg=5},
        Groin = {prob = 7, dmg=10},
        Neck = {prob = 1, dmg=10},
        Head = {prob = 2, dmg=75},
        Torso_Lower = {prob = 18, dmg=10},
        Torso_Upper = {prob = 28, dmg=10},
        UpperArm_R = {prob = 5, dmg=5},
        UpperArm_L = {prob = 5, dmg=5},
        ForeArm_R = {prob = 4, dmg=5},
        ForeArm_L = {prob = 4, dmg=5},
        Hand_R = {prob = 2, dmg=5},
        Hand_L = {prob = 2, dmg=5},
    }

    local hitPart, hitBodyPart, hitBloodBodyPart, hitDmg
    local roll = ZombRand(100)
    local cumulative = 0

    for part, data in pairs(bodyPartTypes) do
        cumulative = cumulative + data.prob
        if roll <= cumulative then
            hitPart = part
            hitBodyPart = BodyPartType[part]
            hitBloodBodyPart = BloodBodyPartType[part]
            hitDmg = data.dmg
            break
        end
    end

    local playerHitBodyPart = playerBodyDamage:getBodyPart(hitBodyPart)

    -- HELMET FALL FOR HEAD SHOT

    if hitPart == "Head" then
        local hat = player:getWornItem("Hat")
        if hat then
            hat:setChanceToFall(100)
            player:helmetFall(true)
        end

        local list = {
            "ZedDmg_HEAD_Bullet",
        }
        for i=1, #list do
            local dmgitem = BanditCompatibility.InstanceItem(list[i])
            if dmgitem then
                player:setWornItem("ZedDmg", dmgitem)
            end
        end
    end

    -- SMALL RANDOM CHANCE FOR SUPERFICIAL WOUND
    local rndS = ZombRand(100)
    if rndS == 1 then

        local args = {
            bodyPartIndex = BodyPartType.ToIndex(playerHitBodyPart:getType()), 
            scratched = true
        }
        sendClientCommand(player, "Commands", "PlayerDamage", args)

        return
    end

    -- PLAYER FALL ON LEG HIT
    if hitPart == "Foot_R" or hitPart == "Foot_L" or hitPart == "LowerLeg_R" or hitPart == "LowerLeg_L" then
        if player:isRunning() or player:isSprinting() then
            player:setVariable("BumpDone", false)
            player:clearVariable("BumpFallType")
            player:setBumpType("trippingFromSprint")
            player:setBumpFall(true)
            player:setBumpFallType("pushedBehind")
            -- player:getActionContext():reportEvent("wasBumped")
        end
    end

    -- CHECK DEFENCE CLOTHES
    local idx = BodyPartType.ToIndex(hitBodyPart)
    local def = player:getBodyPartClothingDefense(idx, false, true) -- idx, bite, bullet
    local rnd = ZombRand(101)
    if rnd < def then 
        player:addHole(hitBloodBodyPart, false) -- single layer

        local args = {
            bodyPartIndex = BodyPartType.ToIndex(playerHitBodyPart:getType()), 
            hole = true,
            holeAllLayers = false,
        }
        sendClientCommand(player, "Commands", "PlayerDamage", args)
        return 
    end

    BanditCompatibility.Splash(player, item, shooter)

    -- SCREAM
    if hitPart ~= "Head" then
        BanditCompatibility.PlayerVoiceSound(player, "PainFromFallHigh")
    end

    local args = {
        bodyPartIndex = BodyPartType.ToIndex(playerHitBodyPart:getType()), 
        hole = true,
        holeAllLayers = true,
        blood = true,
        bullet = true,
        healthDrop = hitDmg,
    }
    sendClientCommand(player, "Commands", "PlayerDamage", args)

end

function PlayerDamageModel.BareHandHit(shooter, player)
    local bodyDamage = player:getBodyDamage()
    local health = bodyDamage:getOverallBodyHealth()

    -- SELECT BODY PART THAT WAS HIT
    local bodyParts = {}
    table.insert(bodyParts, {bname=BloodBodyPartType.Head, name=BodyPartType.Head, chance=1000})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Lower, name=BodyPartType.Torso_Lower, chance=600})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Upper, name=BodyPartType.Torso_Upper, chance=450})
    table.insert(bodyParts, {bname=BloodBodyPartType.Groin, name=BodyPartType.Groin, chance=300})
    table.insert(bodyParts, {bname=BloodBodyPartType.Neck, name=BodyPartType.Neck, chance=200})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperArm_R, name=BodyPartType.UpperArm_R, chance=100})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperArm_L, name=BodyPartType.UpperArm_L, chance=75})
    table.insert(bodyParts, {bname=BloodBodyPartType.ForeArm_R, name=BodyPartType.ForeArm_R, chance=50})
    table.insert(bodyParts, {bname=BloodBodyPartType.ForeArm_L, name=BodyPartType.ForeArm_L, chance=35})
    table.insert(bodyParts, {bname=BloodBodyPartType.Hand_R, name=BodyPartType.Hand_R, chance=20})
    table.insert(bodyParts, {bname=BloodBodyPartType.Hand_L, name=BodyPartType.Hand_L, chance=10})

    local r = 1 + ZombRand(1000)
    local bpi = 0
    for i, bp in pairs(bodyParts) do
        if bp.chance >= r then 
            bpi = i
        end
    end

    local sbp = bodyParts[bpi]
    local hitBodyPart = player:getBodyDamage():getBodyPart(sbp.name)

    local hitDmg = 3
    local scratched = false
    if ZombRand(4) == 1 then
        scratched = true
        hitDmg = 7
    end

    if sbp.name == BodyPartType.Head then
        player:helmetFall(true)
    end

    local args = {
        bodyPartIndex = BodyPartType.ToIndex(hitBodyPart:getType()), 
        blood = true,
        scratched = scratched,
        healthDrop = hitDmg,
    }
    sendClientCommand(player, "Commands", "PlayerDamage", args)
end

function PlayerDamageModel.MeleeHit(shooter, player, item)
    local bodyDamage = player:getBodyDamage()
    local health = bodyDamage:getOverallBodyHealth()

    -- SELECT BODY PART THAT WAS HIT
    local bodyParts = {}
    table.insert(bodyParts, {bname=BloodBodyPartType.Head, name=BodyPartType.Head, chance=1000})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Lower, name=BodyPartType.Torso_Lower, chance=600})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Upper, name=BodyPartType.Torso_Upper, chance=450})
    table.insert(bodyParts, {bname=BloodBodyPartType.Groin, name=BodyPartType.Groin, chance=300})
    table.insert(bodyParts, {bname=BloodBodyPartType.Neck, name=BodyPartType.Neck, chance=200})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperArm_R, name=BodyPartType.UpperArm_R, chance=100})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperArm_L, name=BodyPartType.UpperArm_L, chance=75})
    table.insert(bodyParts, {bname=BloodBodyPartType.ForeArm_R, name=BodyPartType.ForeArm_R, chance=50})
    table.insert(bodyParts, {bname=BloodBodyPartType.ForeArm_L, name=BodyPartType.ForeArm_L, chance=35})
    table.insert(bodyParts, {bname=BloodBodyPartType.Hand_R, name=BodyPartType.Hand_R, chance=20})
    table.insert(bodyParts, {bname=BloodBodyPartType.Hand_L, name=BodyPartType.Hand_L, chance=10})

    local r = 1 + ZombRand(1000)
    local bpi = 0
    for i, bp in pairs(bodyParts) do
        if bp.chance >= r then 
            bpi = i
        end
    end

    local sbp = bodyParts[bpi]
    local hitBodyPart = player:getBodyDamage():getBodyPart(sbp.name)

    local minDamage = item:getMinDamage()
    local maxDamage = item:getMaxDamage()
    local hitDmg = ZombRandFloat(minDamage, maxDamage) * 10
    print (hitDmg)

    local scratch = false
    local cut = false
    local deepWound = false

    if hitDmg < 5 then
    elseif hitDmg < 10 then
        scratch = true
    elseif hitDmg < 25 then
        cut = true
    else
        deepWound = true
    end
    local hole = item:isDamageMakeHole()

    if sbp.name == BodyPartType.Head then
        player:helmetFall(true)
    end

    local args = {
        bodyPartIndex = BodyPartType.ToIndex(hitBodyPart:getType()), 
        blood = true,
        hole = hole,
        holeAllLayers = true,
        scratched = scratched,
        cut = cut,
        deepWound = deepWound,
        healthDrop = hitDmg,
    }
    sendClientCommand(player, "Commands", "PlayerDamage", args)

end