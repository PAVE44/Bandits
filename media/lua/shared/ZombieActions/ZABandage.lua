ZombieActions = ZombieActions or {}

local function GetBodyParts()
    local bodyParts = {}
    table.insert(bodyParts, {name=BodyPartType.Foot_R, anim="BandageRightLeg"})
    table.insert(bodyParts, {name=BodyPartType.Foot_L, anim="BandageLeftLeg"})
    table.insert(bodyParts, {name=BodyPartType.LowerLeg_R, anim="BandageRightLeg"})
    table.insert(bodyParts, {name=BodyPartType.LowerLeg_L, anim="BandageLeftLeg"})
    table.insert(bodyParts, {name=BodyPartType.UpperLeg_R, anim="BandageRightLeg"})
    table.insert(bodyParts, {name=BodyPartType.UpperLeg_L, anim="BandageLeftLeg"})
    table.insert(bodyParts, {name=BodyPartType.Groin, anim="BandageLowerBody"})
    table.insert(bodyParts, {name=BodyPartType.Neck, anim="BandageHead"})
    table.insert(bodyParts, {name=BodyPartType.Head, anim="BandageHead"})
    table.insert(bodyParts, {name=BodyPartType.Torso_Lower, anim="BandageLowerBody"})
    table.insert(bodyParts, {name=BodyPartType.Torso_Upper, anim="BandageUpperBody"})
    table.insert(bodyParts, {name=BodyPartType.UpperArm_R, anim="BandageRightArm"})
    table.insert(bodyParts, {name=BodyPartType.UpperArm_L, anim="BandageLeftArm"})
    table.insert(bodyParts, {name=BodyPartType.ForeArm_R, anim="BandageRightArm"})
    table.insert(bodyParts, {name=BodyPartType.ForeArm_L, anim="BandageLeftArm"})
    table.insert(bodyParts, {name=BodyPartType.Hand_R, anim="BandageRightArm"})
    table.insert(bodyParts, {name=BodyPartType.Hand_L, anim="BandageLeftArm"})
    return bodyParts
end

local function Heal(zombie)
    local bpi = 1 + BanditUtils.GetCharacterID(zombie) % 17
    local bodyParts = GetBodyParts()
    local bodyPart = bodyParts[bpi]

    zombie:setHealth(2)
    zombie:addVisualBandage(bodyPart.name, true)
end

ZombieActions.Bandage = {}
ZombieActions.Bandage.onStart = function(zombie, task)
    local bpi = 1 + math.abs(BanditUtils.GetCharacterID(zombie)) % 17
    local bodyParts = GetBodyParts()
    local bodyPart = bodyParts[bpi]

    -- print ("BANDAGING: " .. tostring(bodyPart.name) .. " WITH ANIM: " .. bodyPart.anim)
    zombie:setBumpType(bodyPart.anim)

    return true
end

ZombieActions.Bandage.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Bandage.onComplete = function(zombie, task)
    Heal(zombie)
    return true
end