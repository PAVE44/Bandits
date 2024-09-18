BanditGlobalData = {}
BanditGlobalDataPlayers = {}

function InitBanditModData(isNewGame)

    -- BANDIT GLOBAL MODDATA
    local globalData = ModData.getOrCreate("Bandit")
    if isClient() then
        ModData.request("Bandit")
    end

    if not globalData.Queue then globalData.Queue = {} end
    if isServer() then
        globalData.Queue = {}
    end
    
    if not globalData.Scenes then globalData.Scenes = {} end
    if not globalData.Bandits then globalData.Bandits = {} end
    if not globalData.Guardposts then globalData.Guardposts = {} end
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
end

function LoadBanditModData(key, globalData)
    if isClient() then
        if key and globalData then
            if key == "Bandit" then
                BanditGlobalData = globalData
            elseif key == "BanditPlayers" then
                BanditGlobalDataPlayers = globalData
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

function TransmitBanditModData()
    ModData.transmit("Bandit")
end

function TransmitBanditModDataPlayers()
    ModData.transmit("BanditPlayers")
end

Events.OnInitGlobalModData.Add(InitBanditModData)
Events.OnReceiveGlobalModData.Add(LoadBanditModData)