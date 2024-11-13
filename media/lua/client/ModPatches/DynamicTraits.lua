BanditPatches = BanditPatches or {}

BanditPatches.DynamicTraits = function()

    if getActivatedMods():contains("Dynamic Traits") then
        DTOnWeaponHitCharacterMain = function (player, target, weapon, damage)

            -- the "player" does not have to be a player if zombie is hitting a zombie
            -- so we need to add this check
            -- the documentation clearly states that the first parameter is IsoGameCharacter
            -- but this is not respected by modders very often
            if instanceof(player, "IsoPlayer") then
                onPlayerHittingAZombie(player, target, weapon, damage)
            end
        end
    end
end

Events.OnGameStart.Add(BanditPatches.DynamicTraits)

