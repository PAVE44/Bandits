require "ISUI/ISCharacterInfoWindow"

local function getBanditKillCount()
    local gmd = GetBanditModData()
    local id = BanditUtils.GetCharacterID(getPlayer())
    if gmd.Kills[id] then
        return gmd.Kills[id]
    else
        return 0
    end
end

-- Backup the original render function
local originalRender = ISCharacterInfoWindow.render

-- Override the render function
function ISCharacterInfoWindow:render()
    -- Call the original render function to retain existing behavior
    originalRender(self)
    
    local viewIndex = self.panel:getActiveViewIndex()
    if viewIndex == 1 then
        local bestWeapon = getPlayer():getInventory():getBestWeapon()
        local zombieKills = getPlayer():getZombieKills()
        local banditKills = getBanditKillCount()
        local offset = 0
        -- Only show bandit kills if the player has at least 1 type of kill due not being able to find api for the players 'favorite weapon'
        if zombieKills > 0 or banditKills > 0 then
            offset = 15
            self:drawText("Bandits", 38, 355 + offset, 1, 1, 1, 1, UIFont.Small)
            self:drawText("Killed", 85, 355 + offset, 1, 1, 1, 1, UIFont.Small)
            self:drawText(tostring(banditKills), 125, 355 + offset, 0.5, 0.5, 0.5, 1, UIFont.Small)
        end
    end
end