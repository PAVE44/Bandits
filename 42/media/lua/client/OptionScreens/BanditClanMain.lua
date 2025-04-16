BanditClanMain = ISPanel:derive("BanditClanMain")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditClanMain:initialise()
    ISPanel.initialise(self)

    self:onAvatarListChange()
end

function BanditClanMain:onAvatarListChange()

    local btnCancelWidth = 100 -- getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 64
    local btnSaveWidth = 100 -- getTextManager():MeasureStringX(UIFont.Small, "Save") + 64
    local btnCancelX = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) - 4
    local btnCancelY = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) + btnCancelWidth + 4

    self:cleanUp()
    self:clearChildren()

    self.cancel = ISButton:new(btnCancelX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnCancelWidth, BUTTON_HGT, "Back", self, BanditClanMain.onClick)
    self.cancel.internal = "BACK"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    if BanditCompatibility.GetGameVersion() >= 42 then
        self.cancel:enableCancelColor()
    end
    self:addChild(self.cancel)

    self.save = ISButton:new(btnCancelY, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnSaveWidth, BUTTON_HGT, "Save", self, BanditClanMain.onClick)
    self.save.internal = "SAVE"
    self.save.anchorTop = false
    self.save.anchorBottom = true
    self.save:initialise()
    self.save:instantiate()
    if BanditCompatibility.GetGameVersion() >= 42 then
        self.save:enableAcceptColor()
    end
    self:addChild(self.save)

    BanditCustom.Load()
    local allData = BanditCustom.GetFromClanSorted(self.cid)

    local cnt = 0
    for _, _ in pairs(allData) do
        cnt = cnt + 1
    end

    if cnt == 0 then
        local modal = BanditClansMain:new(500, 80, 1220, 900)
        modal:initialise()
        modal:addToUIManager()
        self:clearChildren()
        self:removeFromUIManager()
        self:close()
        return
    end

    local topY = 60
    local leftX = 160
    local avatarWidth = 130
    local avatarHeight = 240
    local avatarSpacing = 20
    local inRow = 6

    if cnt >= 18 then
        avatarWidth = 75
        avatarHeight = 120
        avatarSpacing = 5
        inRow = 11
    end

    local player = getSpecificPlayer(0)
    local desc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)

    local hairColors = desc:getCommonHairColor();
    self.hairColors = {}
    local info = ColorInfo.new()
    for i=1, hairColors:size() do
        local color = hairColors:get(i-1)
        info:set(color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat(), 1)
        table.insert(self.hairColors, { r=info:getR(), g=info:getG(), b=info:getB() })
    end

    local rowY = 0

    lbl = ISLabel:new(avatarSpacing, topY + rowY, BUTTON_HGT, "Clan Settings", 1, 1, 1, 1, UIFont.Medium, true)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Clan name", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.clanNameEntry = ISTextEntryBox:new("", leftX, topY + rowY, 130, BUTTON_HGT)
    self.clanNameEntry:initialise()
    self.clanNameEntry:instantiate()
    self:addChild(self.clanNameEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Spawn AI", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.boolOptions = BanditTickBox:new(leftX, topY + rowY, 130, BUTTON_HGT, "", self, BanditClanMain.onBoolOptionsChange)
    -- self.boolOptions.tooltip = "test"
    self.boolOptions:initialise()
    self:addChild(self.boolOptions)
    self.boolOptions:addOption("Friendly", nil, nil, "Will not attack human players.")
    self.boolOptions:addOption("Companions", nil, nil, "Will follow the player. ")
    self.boolOptions:addOption("Defenders", nil, nil, "May spawn in barricaded buildings.")
    self.boolOptions:addOption("Campers", nil, nil, "May spawn with tent base in wilderness.")
    self.boolOptions:addOption("Assault", nil, nil, "fixme")
    self.boolOptions:addOption("Wanderer", nil, nil, "fixme")
    self.boolOptions:addOption("Roadblock", nil, nil, "May organize a road blockade.")
    rowY = rowY + (7 * (BUTTON_HGT + UI_BORDER_SPACING))

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Day start/end", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.dayStartEntry = ISTextEntryBox:new("", leftX, topY + rowY, 36, BUTTON_HGT)
    self.dayStartEntry:initialise()
    self.dayStartEntry:instantiate()
    self.dayStartEntry:setOnlyNumbers(true)
    self.dayStartEntry.tooltip = "Timeframe in which clan may spawn. \nIn signle player games, days number refer to the world age. \nIn multiplayer games, days refer to the number of survived days for a player near whom the spawn will occur. \n In both cases days are counted from zero."
    self:addChild(self.dayStartEntry)

    self.dayEndEntry = ISTextEntryBox:new("", leftX + 36 + UI_BORDER_SPACING, topY + rowY, 36, BUTTON_HGT)
    self.dayEndEntry:initialise()
    self.dayEndEntry:instantiate()
    self.dayEndEntry:setOnlyNumbers(true)
    self.dayEndEntry.tooltip = "Timeframe in which clan may spawn. \nIn signle player games, days number refer to the world age. \nIn multiplayer games, days refer to the number of survived days for a player near whom the spawn will occur. \n In both cases days are counted from zero."
    self:addChild(self.dayEndEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Hourly spawn chance (%)", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.spawnChanceEntry = ISTextEntryBox:new("", leftX, topY + rowY, 36, BUTTON_HGT)
    self.spawnChanceEntry:initialise()
    self.spawnChanceEntry:instantiate()
    self.spawnChanceEntry:setOnlyNumbers(true)
    self.spawnChanceEntry.tooltip = "Average nominal chance of a spawn per hour. "
    self:addChild(self.spawnChanceEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Group size min/max", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.groupMinEntry = ISTextEntryBox:new("", leftX, topY + rowY, 36, BUTTON_HGT)
    self.groupMinEntry:initialise()
    self.groupMinEntry:instantiate()
    self.groupMinEntry:setOnlyNumbers(true)
    self.groupMinEntry.tooltip = "Minimum number of bandits during one spawn."
    self:addChild(self.groupMinEntry)

    self.groupMaxEntry = ISTextEntryBox:new("", leftX + 36 + UI_BORDER_SPACING, topY + rowY, 36, BUTTON_HGT)
    self.groupMaxEntry:initialise()
    self.groupMaxEntry:instantiate()
    self.groupMaxEntry:setOnlyNumbers(true)
    self.groupMaxEntry.tooltip = "Maximum number of bandits during one spawn. Total members of the clan must be equal or higher that the max value."
    self:addChild(self.groupMaxEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Zone occurance", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.zoneCombo = ISComboBox:new(leftX, topY + rowY, 130, BUTTON_HGT, self)
    self.zoneCombo:initialise();
    self.zoneCombo:addOption("Any")
    self.zoneCombo:addOption("Only urban")
    self.zoneCombo:addOption("Only wilderness")
    self.zoneCombo:setToolTipMap({["Any"] = "Bandits have the same chance to spawn in any zone.", ["Only urban"] = "Bandits will spawn only in urban areas.", ["Only wilderness"] = "Bandits will only spawn outside of cities."})
    self.zoneCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.zoneCombo)
    rowY = rowY + BUTTON_HGT + 8

    --[[
    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Zone Boost Spawn", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.zoneTypeCombo = ISComboBox:new(leftX, topY + rowY, 130, BUTTON_HGT, self)
    self.zoneTypeCombo:initialise();
    self.zoneTypeCombo:addOption("Any")

    for zone, tab in pairs(ZombiesZoneDefinition) do
        self.zoneTypeCombo:addOption(zone)
    end
    self.zoneTypeCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.zoneTypeCombo)
    rowY = rowY + BUTTON_HGT + 8
    ]]

    self:loadConfig()

    leftX = 300

    self.models = {}
    self.avatarPanel = {}
    local total = 0
    local i = 0
    local j = 0
    local x
    local y
    for bid, data in pairs(allData) do
        if data.general.cid == self.cid then
            x = leftX + (i * (avatarWidth + avatarSpacing)) + avatarSpacing
            y = topY + j * (avatarHeight + avatarSpacing)

            self.avatarPanel[bid] = BanditCreationAvatar:new(x, y, avatarWidth, avatarHeight, bid, data.general.cid)
            self.avatarPanel[bid].onclick = BanditClanMain.onClick
            self.avatarPanel[bid].onrclick = BanditClanMain.onRightClick
            self.avatarPanel[bid].controls = false
            self.avatarPanel[bid].clickable = true
            self.avatarPanel[bid].name = data.general.name
            self:addChild(self.avatarPanel[bid])

            self.models[bid] = IsoPlayer.new(getCell(), desc, player:getX(), player:getY(), player:getZ())
            self.models[bid]:setSceneCulled(false)
            self.models[bid]:setIsAiming(true)
            self.models[bid]:setNPC(true)
            self.models[bid]:setGodMod(true)
            self.models[bid]:setInvisible(true)
            self.models[bid]:setGhostMode(true)
            

            if data.general then
                if data.general.female then
                    self.models[bid]:setFemale(true)
                else
                    self.models[bid]:setFemale(false)
                end

                self.models[bid]:getHumanVisual():setSkinTextureIndex(data.general.skin - 1)
                self.models[bid]:getHumanVisual():setHairModel(Bandit.GetHairStyle(data.general.female, data.general.hairType))

                if not data.general.female then
                    self.models[bid]:getHumanVisual():setBeardModel(Bandit.GetBeardStyle(data.general.female, data.general.beardType))
                end

                local color = Bandit.GetHairColor(data.general.hairColor)
                local immutableColor = ImmutableColor.new(color.r, color.g, color.b, 1)
                self.models[bid]:getHumanVisual():setHairColor(immutableColor)
                self.models[bid]:getHumanVisual():setBeardColor(immutableColor)
                self.models[bid]:getHumanVisual():setNaturalHairColor(immutableColor)
                self.models[bid]:getHumanVisual():setNaturalBeardColor(immutableColor)
            end

            if data.clothing then
                for bodyLocation, itemType in pairs(data.clothing) do
                    self.models[bid]:setWornItem(bodyLocation, nil)
                    local item = BanditCompatibility.InstanceItem(itemType)
                    if item then
                        self.models[bid]:setWornItem(bodyLocation, item)
                    end
                end
            end

            if data.weapons then
                if data.weapons.primary then
                    local item = BanditCompatibility.InstanceItem(data.weapons.primary)
                    if item then
                        self.models[bid]:setAttachedItem("Rifle On Back", item)
                    end
                else
                    self.models[bid]:setAttachedItem("Rifle On Back", nil)
                end

                if data.weapons.secondary then
                    local item = BanditCompatibility.InstanceItem(data.weapons.secondary)
                    if item then
                        self.models[bid]:setAttachedItem("Holster Right", item)
                    end
                else
                    self.models[bid]:setAttachedItem("Holster Right", nil)
                end
            end

            if data.bag then
                local item = BanditCompatibility.InstanceItem(data.bag.name)
                if item then
                    self.models[bid]:setWornItem(item:canBeEquipped(), item)
                end
            end

            self.avatarPanel[bid]:setCharacter(self.models[bid])
            i = i + 1
            if i == inRow then
                j = j + 1
                i = 0
            end
            total = total + 1
        end
    end

    if total < 66 then
        x = leftX + (i * (avatarWidth + avatarSpacing)) + avatarSpacing
        y = topY + j * (avatarHeight + avatarSpacing)
        local bid = BanditCustom.GetNextId()

        self.avatarPanel[bid] = BanditCreationAvatar:new(x, y, avatarWidth, avatarHeight, bid, self.cid)
        self.avatarPanel[bid].onclick = BanditClanMain.onClick
        self.avatarPanel[bid].controls = false
        self.avatarPanel[bid].clickable = true
        self.avatarPanel[bid].name = "New"
        self.avatarPanel[bid].add = true
        self:addChild(self.avatarPanel[bid])

        self.models[bid] = IsoPlayer.new(getCell(), desc, player:getX(), player:getY(), player:getZ())
        self.models[bid]:setSceneCulled(false)
        self.models[bid]:setNPC(true)
        self.models[bid]:setGodMod(true)
        self.models[bid]:setInvisible(true)
        self.models[bid]:setGhostMode(true)
        self.models[bid]:setFemale(false)
        self.models[bid]:getHumanVisual():setSkinTextureIndex(0)
        self.models[bid]:getHumanVisual():setHairModel(Bandit.GetHairStyle(false, 1))
        self.models[bid]:getHumanVisual():setBeardModel(Bandit.GetBeardStyle(false, 1))
        self.avatarPanel[bid]:setCharacter(self.models[bid])
    end
end

function BanditClanMain:loadConfig()
    local data = BanditCustom.ClanGet(self.cid)

    if data.general then
        self.clanNameEntry:setText(data.general.name)
    end

    if data.spawn then
        if data.spawn.friendly then self.boolOptions:setSelected(1, true) end
        if data.spawn.companion then self.boolOptions:setSelected(2, true) end
        if data.spawn.defenders then self.boolOptions:setSelected(3, true) end
        if data.spawn.campers then self.boolOptions:setSelected(4, true) end
        if data.spawn.assault then self.boolOptions:setSelected(5, true) end
        if data.spawn.wanderer then self.boolOptions:setSelected(6, true) end
        if data.spawn.roadblock then self.boolOptions:setSelected(7, true) end
        self:onBoolOptionsChange()
        
        self.dayStartEntry:setText(data.spawn.dayStart and tostring(data.spawn.dayStart) or "0")
        self.dayEndEntry:setText(data.spawn.dayEnd and tostring(data.spawn.dayEnd) or "10000")
        self.spawnChanceEntry:setText(data.spawn.spawnChance and tostring(data.spawn.spawnChance) or "1.00")
        self.groupMinEntry:setText(data.spawn.groupMin and tostring(data.spawn.groupMin) or "1")
        self.groupMaxEntry:setText(data.spawn.groupMax and tostring(data.spawn.groupMax) or "4")
        self.zoneCombo.selected = (data.spawn.zone or 0) + 1
    end
end

function BanditClanMain:saveConfig()
    BanditCustom.Load()
    local data = BanditCustom.ClanGet(self.cid)
    data.general = {}
    data.general.name = BanditUtils.SanitizeString(self.clanNameEntry:getText())
    data.spawn = {}
    
    data.spawn.friendly = self.boolOptions:isSelected(1)
    data.spawn.companion = self.boolOptions:isSelected(2)
    data.spawn.defenders = self.boolOptions:isSelected(3)
    data.spawn.campers = self.boolOptions:isSelected(4)
    data.spawn.assault = self.boolOptions:isSelected(5)
    data.spawn.wanderer = self.boolOptions:isSelected(6)
    data.spawn.roadblock = self.boolOptions:isSelected(7)

    data.spawn.dayStart = BanditUtils.SanitizeString(self.dayStartEntry:getText())
    data.spawn.dayEnd = BanditUtils.SanitizeString(self.dayEndEntry:getText())
    data.spawn.spawnChance = BanditUtils.SanitizeString(self.spawnChanceEntry:getText())
    data.spawn.groupMin = BanditUtils.SanitizeString(self.groupMinEntry:getText())
    data.spawn.groupMax = BanditUtils.SanitizeString(self.groupMaxEntry:getText())
    data.spawn.zone = self.zoneCombo.selected - 1

    BanditCustom.Save()
end

function BanditClanMain:onBoolOptionsChange(index, selected)
    if self.boolOptions.selected[1] == true then
        self.boolOptions.selected[5] = false
    else
        self.boolOptions.selected[2] = false
    end

    if self.boolOptions.selected[5] == true then
        self.boolOptions.selected[1] = false
        self.boolOptions.selected[2] = false
    end
end

function BanditClanMain:cleanUp()
    local toRem = {}
    if self.models then
        for bid, model in pairs(self.models) do
            table.insert(toRem, bid)
        end
        for _, bid in pairs(toRem) do
            self.avatarPanel[bid]:setCharacter(nil)
            self.models[bid]:removeFromSquare()
            self.models[bid]:removeFromWorld()
            self.models[bid]:removeSaveFile()
            self.models[bid] = nil
        end
    end
end

function BanditClanMain:onClick(button)
    if button.internal == "SAVE" then
        self:saveConfig()
    end

    self:cleanUp()

    local modal = BanditClansMain:new(500, 80, 1220, 900)
    modal:initialise()
    modal:addToUIManager()
    self:clearChildren()
    self:removeFromUIManager()
    self:close()
end

function BanditClanMain:update()
    ISPanel.update(self)
end

function BanditClanMain:prerender()
    ISPanel.prerender(self);
    self:drawTextCentre("BANDIT CLAN", self.width / 2, UI_BORDER_SPACING + 5, 1, 1, 1, 1, UIFont.Title);
end

function BanditClanMain:new(x, y, width, height, cid)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.moveWithMouse = true;
    o.cid = cid
    BanditClanMain.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end
