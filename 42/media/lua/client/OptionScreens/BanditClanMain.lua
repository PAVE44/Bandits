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
    local iconSize = 40
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

    lbl = ISLabel:new(avatarSpacing, topY + rowY, BUTTON_HGT, "Clan name", 1, 1, 1, 1, UIFont.Small, true)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    if not clanData.general.name then
        clanData.general.name = ""
    end

    self.clanNameEntry = ISTextEntryBox:new(clanData.general.name, avatarSpacing + getTextManager():MeasureStringX(UIFont.Small, "Clan name") + UI_BORDER_SPACING, topY + rowY, 200, BUTTON_HGT)
    self.clanNameEntry:initialise()
    self.clanNameEntry:instantiate()
    self:addChild(self.clanNameEntry)
    rowY = rowY + BUTTON_HGT + 18

    --[[lbl = ISLabel:new(avatarSpacing, topY + rowY, BUTTON_HGT, "Clan Members", 1, 1, 1, 1, UIFont.Medium, true)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    rowY = rowY + BUTTON_HGT + 8]]

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
            x = i * (avatarWidth + avatarSpacing) + avatarSpacing
            y = topY + rowY + j * (avatarHeight + avatarSpacing)

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
            if i == 8 then
                j = j + 1
                i = 0
            end
            total = total + 1
        end
    end

    if total < 24 then 
        x = i * (avatarWidth + avatarSpacing) + avatarSpacing
        y = topY + rowY + j * (avatarHeight + avatarSpacing)
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

function BanditClanMain:onClick(button)
    if button.internal == "BACK" then
        local modal = BanditClansMain:new(500, 80, 1220, 900)
        modal:initialise()
        modal:addToUIManager()
        self:removeFromUIManager()
        self:close()
    elseif button.internal == "SAVE" then
        self:saveConfig()
        local modal = BanditClansMain:new(500, 80, 1220, 900)
        modal:initialise()
        modal:addToUIManager()
        self:removeFromUIManager()
        self:close()
    end
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
