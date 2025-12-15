require "Fishing/FishingHandler"

function Fishing.Handler.handleFishing(player, primaryHandItem)
    if not instanceof(player, "IsoPlayer") then return end
    
    local playerIndex = player:getPlayerNum()

    if Fishing.Handler.isFishingValid(primaryHandItem) then
        if Fishing.ManagerInstances[playerIndex] == nil then
            Fishing.ManagerInstances[playerIndex] = Fishing.FishingManager:new(player, player:getJoypadBind())
            --getCore():setZoomEnalbed(false)
        end
    else
        if Fishing.ManagerInstances[playerIndex] ~= nil then
            Fishing.ManagerInstances[playerIndex]:destroy()
            Fishing.ManagerInstances[playerIndex] = nil
        end
    end
end