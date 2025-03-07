BanditClanMain = ISPanel:derive("BanditClanMain")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditClanMain:initialise()
    ISPanel.initialise(self)

    local btnCancelWidth = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 64
    local btnSaveWidth = getTextManager():MeasureStringX(UIFont.Small, "Save") + 64
    local btnCancelX = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) - 4
    local btnCancelY = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) + btnCancelWidth + 4

    self.cancel = ISButton:new(btnCancelX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnCancelWidth, BUTTON_HGT, "Cancel", self, BanditClanMain.onClick)
    self.cancel.internal = "CANCEL"
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
    local avatarWidth = 120
    local avatarHeight = 220
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
    local allData = BanditCustom.GetAll()

    self.models = {}
    self.avatarPanel = {}
    local i = 0
    for bid, data in pairs(allData) do
        local x = i * (avatarWidth + avatarSpacing) + avatarSpacing
        local y = topY

        self.avatarPanel[bid] = BanditCreationAvatar:new(x, y, avatarWidth, avatarHeight)
        self.avatarPanel[bid].onclick = BanditClanMain.onClick
        self.avatarPanel[bid].controls = false
        self.avatarPanel[bid].clickable = true
        self.avatarPanel[bid].bid = bid
        self:addChild(self.avatarPanel[bid])

        self.models[bid] = IsoPlayer.new(getCell(), desc, player:getX(), player:getY(), player:getZ())
        self.models[bid]:setSceneCulled(false)
        self.models[bid]:setNPC(true)
        self.models[bid]:setGodMod(true)
        self.models[bid]:setInvisible(true)
        self.models[bid]:setGhostMode(true)
        
        if data.general then
            local name = data.general.name

            if data.general.female then
                self.models[bid]:setFemale(true)
            else
                self.models[bid]:setFemale(false)
            end

            self.models[bid]:getHumanVisual():setSkinTextureIndex(data.general.skin - 1)
            self.models[bid]:getHumanVisual():setHairModel(BanditCustom.GetHairStyle(data.general.female, data.general.hairType))
            self.models[bid]:getHumanVisual():setBeardModel(BanditCustom.GetBeardStyle(data.general.female, data.general.beardType))

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
    end

end

function BanditClanMain:onClick(button)
    if button.internal == "CANCEL" then
        self:close()
    elseif button.internal == "SAVE" then
        self:saveConfig()
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

function BanditClanMain:new(x, y, width, height)
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
    o.bid = "1"
    -- o.bid = bid
    BanditClanMain.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end
