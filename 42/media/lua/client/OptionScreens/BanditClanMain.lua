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

    local clanData = BanditCustom.ClanGet(self.cid)
    if not clanData then
        clanData = BanditCustom.ClanCreate(self.cid)
    end

    local rowY = 0

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Clan Settings", 1, 1, 1, 1, UIFont.Medium, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Clan name", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.clanNameEntry = ISTextEntryBox:new(clanData.general.name, leftX, topY + rowY, 200, BUTTON_HGT)
    self.clanNameEntry:initialise()
    self.clanNameEntry:instantiate()
    self:addChild(self.clanNameEntry)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Spawn wave", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.waveCombo = ISComboBox:new(leftX, topY + rowY, 200, BUTTON_HGT, self)
    self.waveCombo:initialise();
    for i=1, 16 do
        self.waveCombo:addOption(i)
    end
    self.waveCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.waveCombo)
    rowY = rowY + BUTTON_HGT + 8

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Favorite zone", 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.zoneCombo = ISComboBox:new(leftX, topY + rowY, 200, BUTTON_HGT, self)
    self.zoneCombo:initialise();
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

    leftX = 260
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
        self.models[bid]:Kill(nil)
        self.models[bid]:removeFromSquare()
        self.models[bid]:removeFromWorld()
        self.models[bid]:removeSaveFile()
        self.models[bid]:getHumanVisual():setSkinTextureIndex(0)
        self.models[bid]:getHumanVisual():setHairModel(BanditCustom.GetHairStyle(false, 1))
        self.models[bid]:getHumanVisual():setBeardModel(BanditCustom.GetBeardStyle(false, 1))
        self.avatarPanel[bid]:setCharacter(self.models[bid])
    end
end

function BanditClanMain:saveConfig()
    BanditCustom.Load()
    local data = BanditCustom.ClanGet(self.cid)
    data.general = {}
    data.general.name = self.clanNameEntry:getText()
    BanditCustom.Save()
end

function BanditClanMain:onBoolOptionsChange(index, selected)
    if not selected then return end
    if index == 1 then
        self.boolOptions.selected[3] = false
        self.boolOptions.selected[5] = false
    end
    if index == 3 or index == 5 then
        self.boolOptions.selected[1] = false
    end
end

function BanditClanMain:onClick(button)
    if button.internal == "SAVE" then
        self:saveConfig()
    end

    local toRem = {}
    for bid, model in pairs(self.models) do
        table.insert(toRev, bid)
    end
    for _, bid in pairs(toRem) do
        self.avatarPanel[bid]:setCharacter(nil)
        self.models[v] = nil
    end

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
