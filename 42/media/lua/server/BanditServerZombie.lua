-- Zombie cache
BanditServerZombie = BanditServerZombie or {}

BanditServerZombie.Cache = BanditServerZombie.Cache or {}

-- rebuids cache
local UpdateZombieCache = function(numberTicks)
    if not isServer() then return end

    local skip = 8
    if numberTicks % skip ~= 0 then return end

    local ts = getTimestampMs()
    local cell = getCell()
    local zombieList = cell:getZombieList()
    local zombieListSize = zombieList:size()

    -- prepare local cache vars
    local cache = {}
    local cacheLight = {}
    local cacheLightB = {}
    local cacheLightZ = {}

    for i = 0, zombieListSize - 1 do
        local zombie = zombieList:get(i)
        local id = BanditUtils.GetZombieID(zombie)
        cache[id] = zombie
    end

    -- recreate global cache vars with new findings
    BanditServerZombie.Cache = cache

    print ("BZS:" .. (getTimestampMs() - ts))
end 

-- Events.OnTick.Add(UpdateZombieCache)
