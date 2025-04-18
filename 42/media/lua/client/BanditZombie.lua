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
local UpdateZombieCache = function(numberTicks)
    -- if true then return end 
    if isServer() then return end

    if not Bandit.Engine then return end

    -- ts = getTimestampMs()
    -- if not numberTicks % 4 == 1 then return end

    local silenceStates = {"hitreaction", "hitreaction-hit", "hitreaction-gettingup", "hitreaction-knockeddown", "climbfence", "climbwindow"}

    -- adaptive pefrormance
    -- local skip = math.floor(BanditZombie.LastSize / 200) + 1
    local skip = 4
    if numberTicks % skip ~= 0 then return end

    -- local ts = getTimestampMs()
    local cell = getCell()
    local zombieList = cell:getZombieList()
    local zombieListSize = zombieList:size()

    -- limit zombie map to player surrondings, helps performance
    -- local mr = 40
    local mr = math.ceil(100 - (zombieListSize / 4))
    if mr < 60 then mr = 60 end
    -- print ("MR: " .. mr)
    local player = getSpecificPlayer(0)
    if not player then return end
    local px = player:getX()
    local py = player:getY()

    -- prepare local cache vars
    local cache = {}
    local cacheLight = {}
    local cacheLightB = {}
    local cacheLightZ = {}
    local d = 0
    for i = 0, zombieListSize - 1 do

        local zombie = zombieList:get(i)

        if not BanditCompatibility.IsReanimatedForGrappleOnly(zombie) then

            local id = BanditUtils.GetZombieID(zombie)

            if cache[id] then
                print ("DUPLICATE ID!!!")
            end

            cache[id] = zombie

            local zx, zy, zz, zd = zombie:getX(), zombie:getY(), zombie:getZ(), zombie:getDirectionAngle()

            if math.abs(px - zx) < mr and math.abs(py - zy) < mr then
                local light = {id = id, x = zx, y = zy, z = zz, d = zd}

                if zombie:getVariableBoolean("Bandit")  then
                    light.isBandit = true
                    light.brain = BanditBrain.Get(zombie)
                    cacheLightB[id] = light

                    -- zombies in hitreaction state are not processed by onzombieupdate
                    -- so we need to make them shut their zombie sound here too
                    -- logically this does not fit here, should be a separate process
                    -- but it's here due to performance optimization to avoid additional iteration
                    -- over zombieList
                    if math.abs(px - zx) < 12 and math.abs(py - zy) < 12 then
                        local asn = zombie:getActionStateName()
                        for _, ss in pairs(silenceStates) do
                            if asn == ss then
                                Bandit.SurpressZombieSounds(zombie)
                                break
                            end
                        end

                        if asn == "bumped" then
                            local btype = zombie:getBumpType()
                            if btype and (btype == "ClimbWindow" or btype == "ClimbFence" or btype == "ClimbFenceEnd") then
                                Bandit.SurpressZombieSounds(zombie)
                            end
                        end
                    end
                else
                    light.isBandit = false
                    cacheLightZ[id] = light
                end

                cacheLight[id] = light
            end
        end

    end

    -- recreate global cache vars with new findings
    BanditZombie.Cache = cache
    BanditZombie.CacheLight = cacheLight
    BanditZombie.CacheLightB = cacheLightB
    BanditZombie.CacheLightZ = cacheLightZ
    BanditZombie.LastSize = zombieListSize

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

Events.OnTick.Add(UpdateZombieCache)
