-- keep your globals exactly as before
BanditZombie = BanditZombie or {}

-- consists of IsoZombie instances
BanditZombie.Cache = BanditZombie.Cache or {}

-- cache light consists of only necessary properties for fast manipulation
-- this cache has all zombies and bandits
BanditZombie.CacheLight = BanditZombie.CacheLight or {}

-- this cache has all zombies without bandits
BanditZombie.CacheLightZ = BanditZombie.CacheLightZ or {}
BanditZombie.CacheLightZCnt = 0

-- this cache has all bandit without zombies
BanditZombie.CacheLightB = BanditZombie.CacheLightB or {}
BanditZombie.CacheLightBCnt = 0

-- localize frequently-used globals for speed
local GetZombieID = BanditUtils.GetZombieID
local IsReanimated = BanditCompatibility.IsReanimatedForGrappleOnly
local GetBrain = BanditBrain.Get

local function removeZombieFromCaches(id)
    BanditZombie.Cache[id] = nil
    BanditZombie.CacheLight[id] = nil
    BanditZombie.CacheLightB[id] = nil
    BanditZombie.CacheLightZ[id] = nil
end

local function getRoomId(zombie)
    local square = zombie:getSquare()
    if not square then return nil end
    
    local room = square:getRoom()
    if room then
        local roomDef = room:getRoomDef()
        if roomDef then
            return roomDef:getIDString()
        end
    end
end

local function onZombieUpdate(zombie)
    if isServer() then return end
    local ts = getTimestampMs()
    -- cheap early-outs first
    if IsReanimated(zombie) or zombie:isRagdoll() or not zombie:isAlive() then
        local id = GetZombieID(zombie)
        if BanditZombie.Cache[id] then removeZombieFromCaches(id) end
        return
    end

    local id = GetZombieID(zombie)

    -- always store the raw zombie reference
    BanditZombie.Cache[id] = zombie

    -- reuse existing light table to avoid allocating each tick
    local light = BanditZombie.CacheLight[id]
    if not light then
        light = {}
        BanditZombie.CacheLight[id] = light
    end

    -- update only what changed (optional micro-optimization)
    light.id = id
    light.x = zombie:getX()
    light.y = zombie:getY()
    light.z = zombie:getZ()
    light.d = zombie:getDirectionAngle()

    local isBandit = zombie:getVariableBoolean("Bandit")
    light.isBandit = isBandit

    if isBandit then
        -- if GetBrain is expensive, consider caching it on enter-bandit only
        light.brain = GetBrain(zombie)
        light.rid = getRoomId(zombie)
        BanditZombie.CacheLightB[id] = light
        BanditZombie.CacheLightZ[id] = nil
    else
        light.brain = nil
        BanditZombie.CacheLightZ[id] = light
        BanditZombie.CacheLightB[id] = nil
    end
    -- THIS IS NOW WELL OPTIMIZED
    --print ("time: " .. getTimestampMs() - ts .. "ms, bandit count: " .. BanditZombie.CacheLightBCnt .. ", zombie count: " .. BanditZombie.CacheLightZCnt)
end

local function onZombieDead(zombie)
    if isServer() then return end
    local id = GetZombieID(zombie)
    if BanditZombie.Cache[id] then removeZombieFromCaches(id) end
end

local function flush()
    if isServer() then return end

    -- prepare local cache vars
    local cache = {}
    local cacheLight = {}
    local cacheLightB = {}
    local cacheLightZ = {}

    local cell = getCell()
    local zombieList = cell:getZombieList()
    local zombieListSize = zombieList:size()

    local bcnt, zcnt = 0, 0

    for i = 0, zombieListSize - 1 do
        local zombie = zombieList:get(i)

        if not BanditCompatibility.IsReanimatedForGrappleOnly(zombie) and not zombie:isRagdoll() then

            local id = BanditUtils.GetZombieID(zombie)

            cache[id] = zombie

            local zx, zy, zz, zd = zombie:getX(), zombie:getY(), zombie:getZ(), zombie:getDirectionAngle()

            local light = {id = id, x = zx, y = zy, z = zz, d = zd}

            local isBandit = zombie:getVariableBoolean("Bandit")
            light.isBandit = isBandit
            if isBandit  then
                light.brain = BanditBrain.Get(zombie)
                light.rid = getRoomId(zombie)
                cacheLightB[id] = light
                bcnt = bcnt + 1
            else
                cacheLightZ[id] = light
                zcnt = zcnt + 1
            end
            cacheLight[id] = light
        end

    end

    -- recreate global cache vars with new findings
    BanditZombie.Cache = cache
    BanditZombie.CacheLight = cacheLight
    BanditZombie.CacheLightB = cacheLightB
    BanditZombie.CacheLightZ = cacheLightZ
    BanditZombie.CacheLightBCnt = bcnt
    BanditZombie.CacheLightZCnt = zcnt

    -- without this enforcement, bandits can only move and not do any other action while outside of player view
    -- but it tanks performance, so only enable if necessary 
    if BanditZombie.CacheLightBCnt < 50 and BanditZombie.CacheLightZCnt < 50 then
        getCore():setOptionTieredZombieUpdates(false)
        -- print ("Tiered zombie updates disabled, bandit count: " .. BanditZombie.CacheLightBCnt .. " / 50, zombie count: " .. BanditZombie.CacheLightZCnt .. " / 50")
    else
        getCore():setOptionTieredZombieUpdates(true)
        -- print ("Tiered zombie updates enabled, bandit count: " .. BanditZombie.CacheLightBCnt .. " / 50, zombie count: " .. BanditZombie.CacheLightZCnt .. " / 50")
    end

    BanditPermanent.Check()
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

Events.OnZombieUpdate.Remove(onZombieUpdate)
Events.OnZombieUpdate.Add(onZombieUpdate)

Events.OnZombieDead.Remove(onZombieDead)
Events.OnZombieDead.Add(onZombieDead)

Events.EveryOneMinute.Remove(flush)
Events.EveryOneMinute.Add(flush)
