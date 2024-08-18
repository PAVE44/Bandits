-- These are the default options.
local OPTIONS = {}

-- Key options
local key_data_GUARDPOSTS = {
    key = Keyboard.KEY_G,
    name = "GUARDPOSTS",
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
    ModOptions:getInstance(OPTIONS, "Bandits", "Bandits")

    local category = "[Bandits]"
    ModOptions:AddKeyBinding(category, key_data_GUARDPOSTS)
end

local function InitModOptions()
end

-- Check actual options at game loading.
Events.OnGameStart.Add(InitModOptions)
  



