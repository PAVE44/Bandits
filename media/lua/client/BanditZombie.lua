-- Zombie cache

BanditZombie = BanditZombie or {}

-- consists of IsoZombie instances
BanditZombie.Cache = BanditZombie.Cache or {}

-- cache light consists of only necessary properties for fast manipulation
-- this cache has all zombies and bandits
BanditZombie.CacheLight = BanditZombie.CacheLight or {}

-- this cache has all zombies without bandits
BanditZombie.CacheLightZ = BanditZombie.CacheLightZ or {}

-- this cache has all bandit without zombies
BanditZombie.CacheLightB = BanditZombie.CacheLightB or {}

-- used for adaptive perofmance
BanditZombie.LastSize = 0

-- rebuids cache
BanditZombie.Update = function(numberTicks)
    -- if not numberTicks % 4 == 1 then return end
    
    -- adaptive pefrormance
    -- local skip = math.floor(BanditZombie.LastSize / 200) + 1
    local skip = 4
    if numberTicks % skip ~= 0 then return end

    local cell = getCell()
    local zombieList = cell:getZombieList()

    -- reset all cache
    BanditZombie.Cache = {}
    BanditZombie.CacheLight = {}
    BanditZombie.CacheLightB = {}
    BanditZombie.CacheLightZ = {}
    BanditZombie.LastSize = zombieList:size()

    for i=0, zombieList:size()-1 do
        local zombie = zombieList:get(i)
        if zombie:isAlive() then
            local id = BanditUtils.GetCharacterID(zombie)
            BanditZombie.Cache[id] = zombie
            
            local light = {}
            light.id = id
            light.isBandit = zombie:getVariableBoolean("Bandit")
            light.x = zombie:getX()
            light.y = zombie:getY()
            light.z = zombie:getZ()
            light.brain = BanditBrain.Get(zombie)
            BanditZombie.CacheLight[id] = light

            if light.isBandit then
                BanditZombie.CacheLightB[id] = light
                -- zombies in hitreaction state are not processed by onzombieupdate
                -- so we need to make them shut their zombie sound here too
                local asn = zombie:getActionStateName()
                if asn == "hitreaction" or asn == "hitreaction-hit" then
                    zombie:getEmitter():stopSoundByName("MaleZombieCombined")
                    zombie:getEmitter():stopSoundByName("FemaleZombieCombined")
                end
            else
                BanditZombie.CacheLightZ[id] = light
            end
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

-- returns all cache
BanditZombie.GetAll = function()
    return BanditZombie.CacheLight
end

-- returns all cached zombies
BanditZombie.GetAllZ = function()
    return BanditZombie.CacheLightZ
end

-- returns all cached bandits
BanditZombie.GetAllB = function()
    return BanditZombie.CacheLightB
end

-- returns size of zombie cache
BanditZombie.GetAllCnt = function()
    return BanditZombie.LastSize
end

Events.OnTick.Add(BanditZombie.Update)