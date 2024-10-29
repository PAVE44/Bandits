ZombiePrograms = ZombiePrograms or {}

local function predicateAll(item)
    return true
end

ZombiePrograms.Thief = {}
ZombiePrograms.Thief.Stages = {}

ZombiePrograms.Thief.Init = function(bandit)
end

ZombiePrograms.Thief.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = true
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Thief.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    local weapons = Bandit.GetWeapons(bandit)
    local primary = Bandit.GetBestWeapon(bandit)

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, weapons)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    if weapons.primary.name and weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local task2 = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task2)

    return {status=true, next="Operate", tasks=tasks}
end

ZombiePrograms.Thief.Operate = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
 
    local walkType = "Run"

    local endurance = 0 -- -0.02
    local secondary
    if dls < 0.3 then
        if SandboxVars.Bandits.General_CarryTorches then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" then
                secondary = "Base.HandTorch"
            end
        end

        if SandboxVars.Bandits.General_SneakAtNight then
            if Bandit.IsDNA(bandit, "sneak") then
                walkType = "SneakWalk"
                endurance = 0
            end
        end
    end

    local health = bandit:getHealth()
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    local baseId, base = BanditPlayerBase.GetBaseClosest(bandit)
    local closeSlow = true

    if not base then
        return {status=true, next="Operate", tasks=tasks}
    end

    local inventory = bandit:getInventory()

    local items = ArrayList.new()
    inventory:getAllEvalRecurse(predicateAll, items)

    -- got enough now run away
    if items:size() > 10 then
        return {status=true, next="Escape", tasks=tasks}
    end

    -- find the closest non-empty container
    local contId, cont = BanditPlayerBase.GetContainerClosest(bandit, baseId)
    if not contId then
        return {status=true, next="Escape", tasks=tasks}
    end

    -- select first item
    local itemType
    local cnt
    for k, v in pairs(cont.items) do
        itemType = k
        cnt = v
        break
    end
    if not itemType then
        return {status=true, next="Escape", tasks=tasks}
    end

    local square = cell:getGridSquare(cont.x, cont.y, cont.z)
    if square then
        local asquare = AdjacentFreeTileFinder.Find(square, bandit)
    
        if asquare then
            local dist = math.sqrt(math.pow(bandit:getX() - (asquare:getX() + 0.5), 2) + math.pow(bandit:getY() - (asquare:getY() + 0.5), 2))
            if dist > 0.90 or bandit:getZ() ~= asquare:getZ() then
                local task = BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), walkType, dist, false)
                table.insert(tasks, task)
            elseif bandit:getZ() == asquare:getZ() then
                if cont.type == "floor" then
                    -- bandit:addLineChatElement(("pickup " .. itemType), 1, 1, 1)
                    local task = {action="PickUp", anim="LootLow", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
                    table.insert(tasks, task)
                else
                    -- bandit:addLineChatElement(("take from container: " .. itemType), 1, 1, 1)
                    local task = {action="TakeFromContainer", anim="Loot", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
                    table.insert(tasks, task)
                end
            end
        end
    end
    return {status=true, next="Operate", tasks=tasks}
end

ZombiePrograms.Thief.Wait = function(bandit)
    return {status=true, next="Operate", tasks={}}
end

ZombiePrograms.Thief.Escape = function(bandit)
    local tasks = {}
    local health = bandit:getHealth()
    local endurance = -0.03
    local walkType = "Run"
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end

    local handweapon = bandit:getVariableString("BanditWeapon")

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit)

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then

        -- calculate random escape direction
        local deltaX = 100 
        local deltaY = 100 

        local gametime = getGameTime()
        local hour = gametime:getHour()

        if hour < 6 then 
            deltaX = -deltaX 
        elseif hour < 12 then 
            deltaY = -deltaY
        elseif hour < 18 then
            deltaX = -deltaX 
            deltaY = -deltaY
        end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestPlayer.x+deltaX, closestPlayer.y+deltaY, 0, walkType, 12, false))
    end
    return {status=true, next="Escape", tasks=tasks}
end