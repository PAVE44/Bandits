ZombieActions = ZombieActions or {}

ZombieActions.Fishing = {}
ZombieActions.Fishing.onStart = function(zombie, task)
    local primaryItem = BanditCompatibility.InstanceItem("Base.SpearShort")
    zombie:setPrimaryHandItem(primaryItem)
    zombie:setVariable("BanditPrimary", task.itemPrimary)
    zombie:setVariable("BanditPrimaryType", "spear")
    return true
end

ZombieActions.Fishing.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)

    if not task.stage then task.stage = 1 end

    if not zombie:isBumped() then

        -- print ("STAGE: " .. task.stage)

        if task.stage < 9 then
            zombie:setBumpType("FishingSpearIdle")
        else
            zombie:setBumpType("FishingSpearStrike")
            zombie:playSound("StrikeWithFishingSpear")
        end

        task.stage = task.stage + 1
        Bandit.UpdateTask(zombie, task)
    end

    if task.stage == 10 then
        local rng = BanditUtils.BanditRand(2)
        if rng == 1 then
            local fishTypes = {
                "Base.LargemouthBass", "Base.SmallmouthBass", "Base.BlackCrappie",
                "Base.WhiteCrappie", "Base.YellowPerch", "Base.RedearSunfish"
            }
            local fishType = fishTypes[1 + BanditUtils.BanditRand(#fishTypes)]
            local fishItem = BanditCompatibility.InstanceItem(fishType)
            if fishItem then zombie:getInventory():AddItem(fishItem) end


            --[[if item then
                zombie:getSquare():AddWorldInventoryItem(fishItem, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
            end]]
        end

        return true
    end

    return false
end

ZombieActions.Fishing.onComplete = function(zombie, task)
    return true
end
