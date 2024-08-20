ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Civilian = {}
ZombiePrograms.Civilian.Stages = {}

ZombiePrograms.Civilian.Init = function(civilian)
end

ZombiePrograms.Civilian.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = false
    capabilities.breakObjects = false
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Civilian.Prepare = function(civilian)

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(civilian, Bandit.GetWeapons(civilian))

    return {status=true, next="Defend", tasks={}}
end

ZombiePrograms.Civilian.Defend = function(civilian)

    local tasks = {}

    local gamemode = getWorld():getGameMode()
    local moveAI = "Move"
    if gamemode == "Multiplayer" then
        moveAI = "GoTo"
    end

    local handweapon = civilian:getVariableString("BanditWeapon")
    local health = civilian:getHealth()
    local cx = civilian:getX()
    local cy = civilian:getY()
    local id = math.abs(civilian:getPersistentOutfitID())
    
    local target = BanditScheduler.FindBuilding(civilian, 10, 50)

    if target and target.x and target.y then 
        local pace

        local zeds = 0
        for _, z in pairs(BanditMap.ZMap) do
            if z.x > cx - 8 and z.x < cx + 8 and z.y > cx - 8 and z.y < cx + 8 then
                zeds = zeds + 1
            end
        end

        print ("ZOMBIES AROUND:" .. zeds)
        if zeds < 1 then
            pace = "Run"
            print ("i will go to x:" .. target.x .. " y:" .. target.y)
        else
            pace = "Run"
            print ("i will  run to x:" .. target.x .. " y:" .. target.y)
        end

        if health < 0.4 then
            pace = "Limp"
        end
    
        local walkType = pace .. handweapon
        local task = {action=moveAI, time=75, x=target.x, y=target.y, z=0, walkType=walkType}
        table.insert(tasks, task)
    end

    return {status=true, next="Defend", tasks=tasks}
end

