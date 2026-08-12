BanditGlobalData = {}
BanditGlobalDataPlayers = {}
BanditClusters = {}
BanditClusterCount = 32

local function getClusterName(c)
    return "BanditC"  .. tostring(c)
end

local function getClusterId(id)
    return math.floor(math.abs(id) % BanditClusterCount)
end

local function initBanditModData(isNewGame)

    -- BANDIT GLOBAL MODDATA
    local globalData = ModData.getOrCreate("Bandit")
    if isClient() then
        ModData.request("Bandit")
    end

    -- if not globalData.Queue then globalData.Queue = {} end
    
    -- uncomment these to reset all bandits on server restart
    -- if isServer() then
    --    globalData.Queue = {}
    -- end
    
    if not globalData.Scenes then globalData.Scenes = {} end
    if not globalData.Bandits then globalData.Bandits = {} end
    if not globalData.Posts then globalData.Posts = {} end
    if not globalData.Bases then globalData.Bases = {} end
    if not globalData.Kills then globalData.Kills = {} end
    if not globalData.VisitedBuildings then globalData.VisitedBuildings = {} end
    BanditGlobalData = globalData

    -- BANDIT PLAYERS GLOBAL MODDATA
    local globalDataPlayers = ModData.getOrCreate("BanditPlayers")
    if isClient() then
        ModData.request("BanditPlayers")
    end
   
    globalDataPlayers.OnlinePlayers = {}
    BanditGlobalDataPlayers = globalDataPlayers

    -- BANDIT CLUSTERS GLOBAL MODDATA
    for i = 0, BanditClusterCount - 1 do
        local clusterName = getClusterName(i)
        BanditClusters[i] = ModData.getOrCreate(clusterName)
        print ("[GMD] Cluster " .. clusterName .. " created.")
        if isClient() then
            ModData.request(clusterName)
        end
    end

end

local function loadBanditModData(key, globalData)
    if isClient() then
        if key and globalData then
            if key == "Bandit" then
                BanditGlobalData = globalData
            elseif key == "BanditPlayers" then
                BanditGlobalDataPlayers = globalData
            end
            for i = 0, BanditClusterCount - 1 do
                if key == getClusterName(i) then
                    BanditClusters[i] = globalData
                end
            end
        end
    end
end

function GetBanditModData()
    return BanditGlobalData
end

function GetBanditModDataPlayers()
    return BanditGlobalDataPlayers
end

function GetBanditCluster(id)
    return getClusterId(id)
end

function GetBanditClusterData(id)
    local c = getClusterId(id)
    return BanditClusters[c]
end

function TransmitBanditModData()
    ModData.transmit("Bandit")
end

function TransmitBanditModDataPlayers()
    ModData.transmit("BanditPlayers")
end

function TransmitBanditCluster(id)
    local c = getClusterId(id)
    ModData.transmit(getClusterName(c))
end

function TransmitBanditClusterExpicit(c)
    ModData.transmit(getClusterName(c))
end

local function everyTenMinutes()
    for i = 0, BanditClusterCount - 1 do
        local globalData = BanditClusters[i]
        local cnt = 0
        for _, _ in pairs(globalData) do
            cnt = cnt + 1
        end
        print ("[GMD] Cluster " .. i .. " is " .. cnt .. " long.")
    end
end


Events.OnInitGlobalModData.Add(initBanditModData)
Events.OnReceiveGlobalModData.Add(loadBanditModData)

Events.EveryTenMinutes.Remove(everyTenMinutes)
Events.EveryTenMinutes.Add(everyTenMinutes)