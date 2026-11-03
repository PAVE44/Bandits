ZombieActions = ZombieActions or {}

local function ShovePlayer (attacker, player)

    local hitFromBehind = false
    local hdx = player:getX() - attacker:getX()
    local hdy = player:getY() - attacker:getY()
    local hlen = math.sqrt(hdx * hdx + hdy * hdy)
    if hlen > 0 then
        local fwd = player:getForwardDirection()
        hitFromBehind = (hdx * fwd:getX() + hdy * fwd:getY()) / hlen > 0.5
    end

    player:clearVariable("BumpFallType")
    player:setBumpType("stagger")

    if BanditUtils.BanditRand(3) == 1 then
        player:setBumpFall(true)
    else
        player:setBumpFall(false)
    end

    if not hitFromBehind then
        player:setBumpFallType("pushedFront")
    else
        player:setBumpFallType("pushedBehind")
    end
end

local function ShoveZombie (attacker, zombie)
    
    local hitFromBehind = false
    local hdx = zombie:getX() - attacker:getX()
    local hdy = zombie:getY() - attacker:getY()
    local hlen = math.sqrt(hdx * hdx + hdy * hdy)
    if hlen > 0 then
        local fwd = zombie:getForwardDirection()
        hitFromBehind = (hdx * fwd:getX() + hdy * fwd:getY()) / hlen > 0.5
    end

    zombie:setHitFromBehind(hitFromBehind)
    zombie:setPlayerAttackPosition(zombie:testDotSide(attacker))
    zombie:setHitForce(1)
    --zombie:setStaggerBack(true)
    zombie:setKnockedDown(true)
    --zombie:setOnFloor(true)
    
end

ZombieActions.Push = {}
ZombieActions.Push.onStart = function(bandit, task)

    local anim = BanditUtils.Choice({"Shove", "HighKick", "FrontKick"})

    local primaryItem = bandit:getPrimaryHandItem()
    if primaryItem and primaryItem:IsWeapon() then
        local primaryItemType = WeaponType.getWeaponType(primaryItem)

        if primaryItemType == WeaponType.FIREARM then
            anim = BanditUtils.Choice({"WhipRifle1", "WhipRifle2", "HighKick", "FrontKick"})
        elseif primaryItemType == WeaponType.HANDGUN then
            anim = BanditUtils.Choice({"WhipPistol1", "WhipPistol2", "HighKick", "FrontKick"})
        end
    end

    if anim then
        task.anim = anim
        bandit:setBumpType(anim)
    else
        return false
    end

    return true
end

ZombieActions.Push.onWorking = function(bandit, task)
    bandit:faceLocationF(task.x, task.y)

    local bumpType = bandit:getBumpType()
    if bumpType ~= task.anim then return task.hit == true end

    if not task.hit and task.time <= 54 then

        task.hit = true

        local enemy = BanditZombie.Cache[task.eid]
        if enemy then 
            local brainBandit = BanditBrain.Get(bandit)
            local brainEnemy = BanditBrain.Get(enemy)
            if BanditUtils.AreEnemies(brainEnemy, brainBandit) then
            -- if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
                ShoveZombie (bandit, enemy)
            end
        end

        if Bandit.IsHostile(bandit) then
            local playerList = BanditPlayer.GetPlayers()
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local eid = BanditUtils.GetCharacterID(player)
                    if player:isAlive() and eid == task.eid then
                        ShovePlayer (bandit, player)
                    end
                end
            end
        end
    end
    return false
end

ZombieActions.Push.onComplete = function(bandit, task)
    return true
end
