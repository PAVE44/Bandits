BanditPatches = BanditPatches or {}

BanditPatches.TheStar = function()

    if getActivatedMods():contains("TheStar") then
        local replace1 = TheStar.Notifier.Condition.onEquipPrimary
        local replace2 = TheStar.HandMainExtension.Ammo.onEquipPrimary
        local replace3 = TheStar.HandMainExtension.Battery.onEquipPrimary

        Events.OnEquipPrimary.Remove(TheStar.Notifier.Condition.onEquipPrimary)

        TheStar.Notifier.Condition.onEquipPrimary = function(player, item)
            if instanceof(player, 'IsoPlayer') then
                replace1(player, item)
            end
        end

        Events.OnEquipPrimary.Remove(TheStar.HandMainExtension.Ammo.onEquipPrimary)
        TheStar.HandMainExtension.Ammo.onEquipPrimary = function(player, item)
            if instanceof(player, 'IsoPlayer') then
                replace2(player, item)
            end
        end

        Events.OnEquipPrimary.Remove(TheStar.HandMainExtension.Battery.onEquipPrimary)
        TheStar.HandMainExtension.Battery.onEquipPrimary = function(player, item)
            if instanceof(player, 'IsoPlayer') then
                replace3(player, item)
            end
        end
        print ("TheStar patched successfully!")
    end
end

-- Events.OnGameStart.Add(BanditPatches.TheStar)

