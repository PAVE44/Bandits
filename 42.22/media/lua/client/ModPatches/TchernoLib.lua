BanditPatches = BanditPatches or {}

BanditPatches.TchernoLib = function()

    if getActivatedMods():contains("TchernoLib") then
        local replace1 = PlaVar.onZombieUpdateDontAttack

        Events.OnZombieUpdate.Remove(PlaVar.onZombieUpdateDontAttack)
        PlaVar.onZombieUpdateDontAttack = function(isoZombie)
            return false
        end

        print ("TchernoLib patched successfully!")
    end
end

-- Events.OnGameStart.Add(BanditPatches.TchernoLib)

