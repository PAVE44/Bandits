BanditPatches = BanditPatches or {}

BanditPatches.ImprovedProjectile = function()

    if getActivatedMods():contains("ImprovedProjectile") then
       
    end
end

Events.OnGameStart.Add(BanditPatches.ImprovedProjectile)


