local config = {
    keyBind   = nil,
    checkBox  = nil,
    textEntry = nil,
    multiBox  = nil,
    comboBox  = nil,
    colorPick = nil,
    slider    = nil,
    button    = nil
}

local options = PZAPI.ModOptions:create("Bandits", getText("UI_optionscreen_binding_Bandits"))
options:addTitle("Bandits")
config.keyBind = options:addKeyBind("POSTS", getText("UI_optionscreen_binding_POSTS"), Keyboard.KEY_G, getText("UI_optionscreen_binding_POSTS"))
