-- Zombie cache

BanditZombie = BanditZombie or {}

-- consists of IsoZombie instances
BanditZombie.Cache = BanditZombie.Cache or {}

-- consists of only necessary properties for fast manipulation
BanditZombie.CacheLight = BanditZombie.CacheLight or {}

-- used for adaptive perofmance
BanditZombie.LastSize = 0

-- rebuids cache
BanditZombie.Update = function(numberTicks)
    -- if not numberTicks % 4 == 1 then return end
    
    -- adaptive pefrormance
    local skip = math.floor(BanditZombie.LastSize / 200) + 1
    -- print (skip)
    if numberTicks % skip ~= 0 then return end

    local cell = getCell()
    local zombieList = cell:getZombieList()

    BanditZombie.Cache = {}
    BanditZombie.CacheLight = {}
    BanditZombie.LastSize = zombieList:size()

    for i=0, zombieList:size()-1 do
        local zombie = zombieList:get(i)
        if zombie:isAlive() then
            local id = BanditUtils.GetCharacterID(zombie)
            BanditZombie.Cache[id] = zombie
            
            local light = {}
            light.isBandit = zombie:getVariableBoolean("Bandit")
            light.x = zombie:getX()
            light.y = zombie:getY()
            light.z = zombie:getZ()
            light.brain = BanditBrain.Get(zombie)
            BanditZombie.CacheLight[id] = light
        end
    end
end 

-- returns IsoZombie by id
BanditZombie.GetInstanceById = function(id)
    if BanditZombie.Cache[id] then
        return BanditZombie.Cache[id]
    end
    return nil
end

-- returns all zombies
BanditZombie.GetAll = function()
    return BanditZombie.CacheLight
end

Events.OnTick.Add(BanditZombie.Update)