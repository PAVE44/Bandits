BanditModData = {}

function InitBanditModData(isNewGame)

    local modData = ModData.getOrCreate("Bandit")

    if isClient() then
        ModData.request("Bandit")
    end

    --if not modData.Queue then modData.modData = {} end
    modData.Queue = {}
    modData.OnlinePlayers = {}
    if not modData.Scenes then modData.Scenes = {} end
    if not modData.Bandits then modData.Bandits = {} end

    BanditModData = modData
end

function LoadBanditModData(key, modData)
    if isClient() then
        if key and key == "Bandit" and modData then
            BanditModData = modData
        end
    end
end

function GetBanditModData()
    return BanditModData
end

function TransmitBanditModData()
    ModData.transmit("Bandit")
end


Events.OnInitGlobalModData.Add(InitBanditModData)
Events.OnReceiveGlobalModData.Add(LoadBanditModData)
