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
    if isServer() then return end
    
    -- if not numberTicks % 4 == 1 then return end
    
    -- adaptive pefrormance
    -- local skip = math.floor(BanditZombie.LastSize / 200) + 1
    local skip = 6
    if numberTicks % skip ~= 0 then return end

    -- local ts = getTimestampMs()
    local cell = getCell()
    local zombieList = cell:getZombieList()
    local zombieListSize = zombieList:size()

    -- limit zombie map to player surrondings, helps performance
    -- local mr = 40
    local mr = math.ceil(100 - (zombieListSize / 4))
    if mr < 40 then mr = 40 end
    local player = getPlayer()
    local px = player:getX()
    local py = player:getY()

    -- reset all cache
    BanditZombie.Cache = {}
    BanditZombie.CacheLight = {}
    BanditZombie.CacheLightB = {}
    BanditZombie.CacheLightZ = {}
    BanditZombie.LastSize = zombieListSize

    for i = 0, zombieListSize - 1 do
        
        local zombie = zombieList:get(i)
        
        --if zombie:isAlive() then
            local id = BanditUtils.GetCharacterID(zombie)

            BanditZombie.Cache[id] = zombie
            
            local zx = zombie:getX()
            local zy = zombie:getY()
            local zz = zombie:getZ()
            
            if math.abs(px - zx) < mr and math.abs(py - zy) < mr then
            -- if zx > px - mr and zx < px + mr and zy > py - mr and zy < py + mr then
                local light = {}
                light.id = id
                light.x = zx
                light.y = zy
                light.z = zz
                light.brain = BanditBrain.Get(zombie)

                if zombie:getVariableBoolean("Bandit")  then
                    light.isBandit = true
                    BanditZombie.CacheLightB[id] = light
                    -- zombies in hitreaction state are not processed by onzombieupdate
                    -- so we need to make them shut their zombie sound here too
                    
                    local asn = zombie:getActionStateName()
                    if asn == "hitreaction" or asn == "hitreaction-hit" or asn == "climbfence" or asn == "climbwindow" then
                        zombie:getEmitter():stopSoundByName("MaleZombieCombined")
                        zombie:getEmitter():stopSoundByName("FemaleZombieCombined")
                    end
                else
                    light.isBandit = false
                    BanditZombie.CacheLightZ[id] = light
                end

                BanditZombie.CacheLight[id] = light
            end
        --end
    end

    -- print ("BZ:" .. (getTimestampMs() - ts))

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