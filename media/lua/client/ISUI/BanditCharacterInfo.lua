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
        local zombieKills = getPlayer():getZombieKills()
        local offset = 0
        if zombieKills > 0 then
            offset = 15
        end

        self:drawText("Bandits", 38, 355 + offset, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Killed", 85, 355 + offset, 1, 1, 1, 1, UIFont.Small)
        self:drawText(tostring(getBanditKillCount()), 125, 355 + offset, 0.5, 0.5, 0.5, 1, UIFont.Small)
    end
end

-- Ensure GlobalModData is initialized when the game starts
Events.OnGameStart.Add(initializeBanditKillData)