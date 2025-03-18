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
    self.cancel:enableCancelColor()
    self:addChild(self.cancel)

    self.save = ISButton:new(btnCancelY, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnSaveWidth, BUTTON_HGT, "Save", self, BanditClanMain.onClick)
    self.save.internal = "SAVE"
    self.save.anchorTop = false
    self.save.anchorBottom = true
    self.save:initialise()
    self.save:instantiate()
    self.save:enableAcceptColor()
    self:addChild(self.save)

    local topY = 60
    local leftX = 130
    local avatarWidth = 130
    local avatarHeight = 240
    local avatarSpacing = 20

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

    BanditCustom.Load()

    

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

    self.clanNameEntry = ISTextEntryBox:new("", leftX, topY + rowY, 160, BUTTON_HGT)
    self.clanNameEntry:initialise()
    self.clanNameEntry:instantiate()
    self:addChild(self.clanNameEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Sandbox wave", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    
    self.waveCombo = ISComboBox:new(leftX, topY + rowY, 160, BUTTON_HGT, self)
    self.waveCombo:initialise();
    self.waveCombo:addOption("Disabled")
    for i=1, 16 do
        self.waveCombo:addOption("Wave " .. tostring(i))
    end
    self.waveCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.waveCombo)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Favorite zone", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.zoneCombo = ISComboBox:new(leftX, topY + rowY, 160, BUTTON_HGT, self)
    self.zoneCombo:initialise();
    self.zoneCombo:addOption("None")
    self.zoneCombo:addOption("Urban")
    self.zoneCombo:addOption("Suburban")
    self.zoneCombo:addOption("Wilderness")
    self.zoneCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.zoneCombo)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Spawn AI", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.boolOptions = ISTickBox:new(leftX, topY + rowY, 200, BUTTON_HGT, "", self, BanditClanMain.onBoolOptionsChange)
    self.boolOptions:initialise()
    self:addChild(self.boolOptions)
    self.boolOptions:addOption("Friendly")
    self.boolOptions:addOption("Defenders")
    self.boolOptions:addOption("Campers")
    self.boolOptions:addOption("Assault")
    self.boolOptions:addOption("Wanderer")
    self.boolOptions:addOption("Roadblock")
    rowY = rowY + (6 * BUTTON_HGT) + 8

    self:loadConfig()

    leftX = 300
    local allData = BanditCustom.GetAll()

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
                self.models[bid]:getHumanVisual():setHairModel(BanditCustom.GetHairStyle(data.general.female, data.general.hairType))

                if not data.general.female then
                    self.models[bid]:getHumanVisual():setBeardModel(BanditCustom.GetBeardStyle(data.general.female, data.general.beardType))
                end

                local color = BanditCustom.GetHairColor(data.general.hairColor)
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
                self.models[bid]:setWornItem(item:canBeEquipped(), item)
            end

            self.avatarPanel[bid]:setCharacter(self.models[bid])
            i = i + 1
            if i == 6 then
                j = j + 1
                i = 0
            end
            total = total + 1
        end
    end

    if total < 18 then
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
        self.models[bid]:getHumanVisual():setHairModel(BanditCustom.GetHairStyle(false, 1))
        self.models[bid]:getHumanVisual():setBeardModel(BanditCustom.GetBeardStyle(false, 1))
        self.avatarPanel[bid]:setCharacter(self.models[bid])
    end
end

function BanditClanMain:loadConfig()
    local data = BanditCustom.ClanGet(self.cid)

    self.clanNameEntry:setText(data.general.name)

    if data.spawn then
        self.waveCombo.selected = (data.spawn.wave or 0) + 1
        self.zoneCombo.selected = (data.spawn.zone or 0) + 1

        if data.spawn.friendly then self.boolOptions:setSelected(1, true) end
        if data.spawn.defenders then self.boolOptions:setSelected(2, true) end
        if data.spawn.campers then self.boolOptions:setSelected(3, true) end
        if data.spawn.assault then self.boolOptions:setSelected(4, true) end
        if data.spawn.wanderer then self.boolOptions:setSelected(5, true) end
        if data.spawn.roadblock then self.boolOptions:setSelected(6, true) end
        self:onBoolOptionsChange()
    end
end

function BanditClanMain:saveConfig()
    BanditCustom.Load()
    local data = BanditCustom.ClanGet(self.cid)
    data.general = {}
    data.general.name = self.clanNameEntry:getText()
    data.spawn = {}
    data.spawn.wave = self.waveCombo.selected - 1
    data.spawn.zone = self.zoneCombo.selected - 1
    data.spawn.friendly = self.boolOptions:isSelected(1)
    data.spawn.defenders = self.boolOptions:isSelected(2)
    data.spawn.campers = self.boolOptions:isSelected(3)
    data.spawn.assault = self.boolOptions:isSelected(4)
    data.spawn.wanderer = self.boolOptions:isSelected(5)
    data.spawn.roadblock = self.boolOptions:isSelected(6)
    

    BanditCustom.Save()
end

function BanditClanMain:onBoolOptionsChange(index, selected)
    if self.boolOptions.selected[1] == true then
        self.boolOptions.selected[3] = false
        self.boolOptions.selected[5] = false
    end
    if self.boolOptions.selected[3] == true then
        self.boolOptions.selected[1] = false
    end
    if self.boolOptions.selected[5] == true then
        self.boolOptions.selected[1] = false
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
