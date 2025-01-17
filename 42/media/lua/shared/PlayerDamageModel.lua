PlayerDamageModel = PlayerDamageModel or {}

function PlayerDamageModel.BulletHit(shooter, player)
    local bodyDamage = player:getBodyDamage()
    local health = bodyDamage:getOverallBodyHealth()
    local item = instanceItem("Base.AssaultRifle2")

    -- SELECT BODY PART THAT WAS HIT
    local bodyParts = {}
    table.insert(bodyParts, {bname=BloodBodyPartType.Foot_R, name=BodyPartType.Foot_R, chance=1000})
    table.insert(bodyParts, {bname=BloodBodyPartType.Foot_L, name=BodyPartType.Foot_L, chance=990})
    table.insert(bodyParts, {bname=BloodBodyPartType.LowerLeg_R, name=BodyPartType.LowerLeg_R, chance=980})
    table.insert(bodyParts, {bname=BloodBodyPartType.LowerLeg_L, name=BodyPartType.LowerLeg_L, chance=940})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperLeg_R, name=BodyPartType.UpperLeg_R, chance=900})
    table.insert(bodyParts, {bname=BloodBodyPartType.UpperLeg_L, name=BodyPartType.UpperLeg_L, chance=800})
    table.insert(bodyParts, {bname=BloodBodyPartType.Groin, name=BodyPartType.Groin, chance=700})
    table.insert(bodyParts, {bname=BloodBodyPartType.Neck, name=BodyPartType.Neck, chance=660})
    table.insert(bodyParts, {bname=BloodBodyPartType.Head, name=BodyPartType.Head, chance=650})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Lower, name=BodyPartType.Torso_Lower, chance=600})
    table.insert(bodyParts, {bname=BloodBodyPartType.Torso_Upper, name=BodyPartType.Torso_Upper, chance=350})
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
    local shotBodyPart = player:getBodyDamage():getBodyPart(sbp.name)
    print ("-- PLAYER SHOT IN: " .. tostring(sbp.name))

    -- CHECK PROTECTIVE CLOTHES
    local vest = player:getWornItem("TorsoExtraVest")
    local vestDef = 0
    local vestHoles = 0
    if vest then
        vestDef = vest:getBulletDefense()
        vestHoles = vest:getHolesNumber()
    end

    local hat = player:getWornItem("Hat")
    local hatDef = 0
    local hatHoles = 0
    if hat then
        hatDef = hat:getScratchDefense()
        hatHoles = hat:getHolesNumber()
    end

    -- CALCULATE IF THIS IS SUPERFICIAL WOUND
    local isSuperficial = false
    if 1 + ZombRand(100) <= 15 then
        isSuperficial = true
    end

    if isSuperficial then
        shotBodyPart:setScratched(true, true)
        player:addBlood(0.2)
        -- SwipeStatePlayer.splash(player, item, shooter)
    else
        if sbp.name == BodyPartType.Head then
            print ("HEADSHOT")
            if hat and hatDef == 100 and hatHoles == 0 and ZombRand(100) < 10 then
                print ("HELMET PROTECTED")
            else
                print ("PLAYER DEAD")
                player:addBlood(0.6)
                -- SwipeStatePlayer.splash(player, item, shooter)

                if not player:isGodMod() then
                    bodyDamage:ReduceGeneralHealth(100)
                    player:Hit(item, shooter, 50, false, 1, false)
                end
            end
            
            if hat then
                hat:setChanceToFall(100)
                player:helmetFall(true)
            end

        elseif sbp.name == BodyPartType.Torso_Lower or sbp.name == BodyPartType.Torso_Upper then

            if vest and vestDef == 100 and vestHoles < 2 then
                -- pass
                bodyDamage:ReduceGeneralHealth(3)
                if ZombRand(16) < 3 then player:addHole(sbp.bname, false) end
            else
                bodyDamage:ReduceGeneralHealth(12)
                shotBodyPart:setHaveBullet(true, 1)
                player:addBlood(0.6)
                player:addHole(sbp.bname, false)
                -- SwipeStatePlayer.splash(player, item, shooter)
            end

        elseif sbp.name == BodyPartType.Foot_R or sbp.name == BodyPartType.Foot_L or sbp.name == BodyPartType.LowerLeg_R or sbp.name == BodyPartType.LowerLeg_L then
            bodyDamage:ReduceGeneralHealth(7)
            shotBodyPart:setHaveBullet(true, 1)
            player:addHole(sbp.bname, true)
            player:addBlood(0.6)
            -- SwipeStatePlayer.splash(player, item, shooter)
            if player:isRunning() or player:isSprinting() then
                player:clearVariable("BumpFallType")
                player:setBumpType("stagger")
                player:setBumpFall(true)
                player:setBumpFallType("pushedBehind")
            end
        else
            bodyDamage:setOverallBodyHealth(10)
            shotBodyPart:setHaveBullet(true, 1)
            player:addHole(sbp.bname, true)
            player:addBlood(0.6)
            -- SwipeStatePlayer.splash(player, item, shooter)
        end
    end



    --[[
    local wornItems = player:getWornItems()
    for i=0, wornItems:size()-1 do
        local item = wornItems:get(i)
        print (item:getLocation())
    end
    ]]

    

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
    print ("-- PLAYER HIT IN: " .. tostring(sbp.name))

    if ZombRand(4) == 1 then
        hitBodyPart:setScratched(true, true)
        bodyDamage:ReduceGeneralHealth(6)
    else
        bodyDamage:ReduceGeneralHealth(3)
    end

    player:addBlood(0.2)

    if sbp.name == BodyPartType.Head then
        player:helmetFall(true)

    end

end