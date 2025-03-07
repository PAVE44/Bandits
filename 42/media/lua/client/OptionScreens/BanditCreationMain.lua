BanditCreationMain = ISPanel:derive("BanditCreationMain")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditCreationMain:initialise()
    ISPanel.initialise(self)

    local btnCancelWidth = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 64
    local btnSaveWidth = getTextManager():MeasureStringX(UIFont.Small, "Save") + 64
    local btnCancelX = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) - 4
    local btnCancelY = math.floor(self:getWidth() / 2) - ((btnCancelWidth + btnSaveWidth) / 2) + btnCancelWidth + 4

    self.cancel = ISButton:new(btnCancelX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnCancelWidth, BUTTON_HGT, "Cancel", self, BanditCreationMain.onClick)
    self.cancel.internal = "CANCEL"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel:enableCancelColor()
    self:addChild(self.cancel)

    self.save = ISButton:new(btnCancelY, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnSaveWidth, BUTTON_HGT, "Save", self, BanditCreationMain.onClick)
    self.save.internal = "SAVE"
    self.save.anchorTop = false
    self.save.anchorBottom = true
    self.save:initialise()
    self.save:instantiate()
    self.save:enableAcceptColor()
    self:addChild(self.save)

    local topY = 60
    local iconSize = 40
    local avatarWidth = 320
    local avatarHeight = 640
    self.avatarPanel = BanditCreationAvatar:new((self:getWidth() / 2) - (avatarWidth / 2), topY, avatarWidth, avatarHeight)
    self.avatarPanel.controls = true
    self.avatarPanel.clickable = false
    self.avatarPanel:noBackground()
    self:addChild(self.avatarPanel)

    local player = getSpecificPlayer(0)
    self.desc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    self.model = IsoPlayer.new(getCell(), self.desc, player:getX(), player:getY(), player:getZ())
    self.model:setSceneCulled(false)
    self.model:setNPC(true)
    self.model:setGodMod(true)
    self.model:setInvisible(true)
    self.model:setGhostMode(true)

    -- self.avatarPanel:setSurvivorDesc(self.desc)

    self.avatarPanel:setCharacter(self.model)

    local leftX = 130
    local lbl
    local rowY = 0

    -- APPEARANCE
    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Appearance", 1, 1, 1, 1, UIFont.Medium, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    rowY = rowY + BUTTON_HGT + 8

    -- NAME
    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_characreation_forename"), 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.nameEntry = ISTextEntryBox:new("", leftX, topY + rowY, 200, BUTTON_HGT)
    self.nameEntry:initialise()
    self.nameEntry:instantiate()
    self:addChild(self.nameEntry)
    rowY = rowY + BUTTON_HGT + 8

    -- GENDER

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_characreation_gender"), 1, 1, 1, 1, UIFont.Small, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.genderCombo = ISComboBox:new(leftX, topY + rowY, 200, BUTTON_HGT, self, BanditCreationMain.onGenderSelected)
    self.genderCombo:initialise();
    self.genderCombo:addOption(getText("IGUI_char_Female"))
    self.genderCombo:addOption(getText("IGUI_char_Male"))
    self.genderCombo.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    self:addChild(self.genderCombo)
    rowY = rowY + BUTTON_HGT + 8

    -- SKIN

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_SkinColor"), 1, 1, 1, 1, UIFont.Small);
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.skinColors = { {r=1,g=0.91,b=0.72},
        {r=0.98,g=0.79,b=0.49},
        {r=0.8,g=0.65,b=0.45},
        {r=0.54,g=0.38,b=0.25},
        {r=0.36,g=0.25,b=0.14} }

    local skinColorBtn = ISButton:new(leftX, topY + rowY, BUTTON_HGT, BUTTON_HGT, "", self, BanditCreationMain.onSkinColorSelected)
    skinColorBtn:initialise()
    skinColorBtn:instantiate()
    local color = self.skinColors[1]
    skinColorBtn.backgroundColor = {r = color.r, g = color.g, b = color.b, a = 1}
    self:addChild(skinColorBtn)
    self.skinColorButton = skinColorBtn
    
    self.colorPickerSkin = ISColorPicker:new(0, 0, nil)
    self.colorPickerSkin:initialise()
    self.colorPickerSkin.keepOnScreen = true
    self.colorPickerSkin.pickedTarget = self
    self.colorPickerSkin.resetFocusTo = self
    self.colorPickerSkin:setColors(self.skinColors, #self.skinColors, 1)
    rowY = rowY + BUTTON_HGT + 8

    -- CHEST HAIR

    -- todo

    -- HAIR STYLE

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_characreation_hairtype"), 1, 1, 1, 1, UIFont.Small)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    
    self.hairTypeCombo = ISComboBox:new(leftX, topY + rowY, 200, BUTTON_HGT, self, BanditCreationMain.onHairTypeSelected)
    self.hairTypeCombo:initialise();
    self:addChild(self.hairTypeCombo)
    rowY = rowY + BUTTON_HGT + 8

    -- BEARD STYLE

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_characreation_beardtype"), 1, 1, 1, 1, UIFont.Small)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    
    self.beardTypeCombo = ISComboBox:new(leftX, topY + rowY, 200, BUTTON_HGT, self, BanditCreationMain.onBeardTypeSelected)
    self.beardTypeCombo:initialise()
    self:addChild(self.beardTypeCombo)
    rowY = rowY + BUTTON_HGT + 8

    -- HAIR/BEARD COLOR

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, getText("UI_characreation_color"), 1, 1, 1, 1, UIFont.Small);
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    local hairColors = self.desc:getCommonHairColor();
    self.hairColors = {}
    local info = ColorInfo.new()
    for i=1, hairColors:size() do
        local color = hairColors:get(i-1)
        info:set(color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat(), 1)
        table.insert(self.hairColors, { r=info:getR(), g=info:getG(), b=info:getB() })
    end

    local hairColorBtn = ISButton:new(leftX, topY + rowY, BUTTON_HGT, BUTTON_HGT, "", self, BanditCreationMain.onHairColorMouseDown)
    hairColorBtn:initialise()
    hairColorBtn:instantiate()
    local color = self.hairColors[1]
    hairColorBtn.backgroundColor = {r=color.r, g=color.g, b=color.b, a=1}
    self:addChild(hairColorBtn)
    self.hairColorButton = hairColorBtn

    self.colorPickerHair = ISColorPicker:new(0, 0, nil)
    self.colorPickerHair:initialise()
    self.colorPickerHair.keepOnScreen = true
    self.colorPickerHair.pickedTarget = self
    self.colorPickerHair.resetFocusTo = self
    self.colorPickerHair:setColors(self.hairColors, math.min(#self.hairColors, 10), math.ceil(#self.hairColors / 10))
    rowY = rowY + BUTTON_HGT + 18

    self:updateHairCombo()

    -- WEAPONS

    lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, BUTTON_HGT, "Weapons", 1, 1, 1, 1, UIFont.Medium, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)
    rowY = rowY + BUTTON_HGT + 8

	self.weapons = {}
	
	lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, iconSize, "Primary Gun", 1, 1, 1, 1, UIFont.Small)
	lbl:initialise()
	lbl:instantiate()
	self:addChild(lbl)

	self.weapons.primary = BanditItemDropBox:new(leftX, topY + rowY, iconSize, iconSize, true, self, BanditCreationMain.addItem, BanditCreationMain.removeItem, BanditCreationMain.verifyItem, nil)
	self.weapons.primary:initialise()
	self.weapons.primary:setToolTip(true, "Primary Gun")
	self.weapons.primary.internal = "primary"
	self.weapons.primary.mode = "weapons"
	self:addChild(self.weapons.primary)
	rowY = rowY + iconSize + 4

	lbl = ISLabel:new(leftX - UI_BORDER_SPACING, topY + rowY, iconSize, "Secondary Gun", 1, 1, 1, 1, UIFont.Small)
	lbl:initialise()
	lbl:instantiate()
	self:addChild(lbl)

	self.weapons.secondary = BanditItemDropBox:new(leftX, topY + rowY, iconSize, iconSize, true, self, BanditCreationMain.addItem, BanditCreationMain.removeItem, BanditCreationMain.verifyItem, nil)
	self.weapons.secondary:initialise()
	self.weapons.secondary:setToolTip(true, "Secondary Gun")
	self.weapons.secondary.internal = "secondary"
	self.weapons.secondary.mode = "weapons"
	self:addChild(self.weapons.secondary)


    -- CLOTHING

    local clothingX = math.floor(self:getWidth() * 0.70)

    local bodyLocations = {Head = {"Hat", "FullHat", "Ears", "EarTop", "Nose"},
                           Face = {"Mask", "MaskEyes", "RightEye", "LeftEye"},
                           Neck = {"Neck", "Necklace", "Scarf"},
                           Suit = {"FullSuit", "FullSuitHead", "Boilersuit", "Torso1Legs1", "Dress", "LongDress"},
                           TopShirt = {"TankTop", "Tshirt", "ShortSleeveShirt", "Shirt"},
                           TopJacket = {"Jacket", "JacketHat", "Jacket_Down", "JacketHat_Bulky", "Jacket_Bulky", "JacketSuit"},
                           TopVest = {"TorsoExtraVest", "TorsoExtraVestBullet", "VestTexture", "Sweater", "SweaterHat"},
                           Underwear = {"UnderwearBottom", "UnderwearTop", "UnderwearExtra1", "UnderwearExtra2"},
                           Bags = {"FannyPackFront", "FannyPackBack", "Webbing"},
                           Holsters = {"AmmoStrap", "AnkleHolster", "BeltExtra", "ShoulderHolster"},
                           Hands = {"Hands", "RightWrist", "Right_MiddleFinger", "Right_RingFinger", "LeftWrist", "Left_MiddleFinger", "Left_RingFinger"},
                           Bottom = {"Pants", "PantsExtra", "Legs1", "ShortPants", "ShortsShort", "LongSkirt", "Skirt"},
                           Shoes = {"Shoes"}
     }

    lbl = ISLabel:new(clothingX - UI_BORDER_SPACING, topY, BUTTON_HGT, "Outfit", 1, 1, 1, 1, UIFont.Medium, false)
    lbl:initialise()
    lbl:instantiate()
    self:addChild(lbl)

    self.clothing = {}
    local row = 1
    for groupName, group in pairs(bodyLocations) do
        row = row + 1
        local y = topY + (row - 1) * (iconSize + 4) - 4

        local label = ISLabel:new(clothingX, y, iconSize, groupName, 1, 1, 1, 1, UIFont.Small)
        label:initialise()
        self:addChild(label)

        for col, bodyLocation in pairs(group) do
            local x = clothingX + (col - 1) * (iconSize + 4) + 10
            
            self.clothing[bodyLocation] = BanditItemDropBox:new(x, y, iconSize, iconSize, true, self, BanditCreationMain.addItem, BanditCreationMain.removeItem, BanditCreationMain.verifyItem, nil)
            self.clothing[bodyLocation]:initialise()
            self.clothing[bodyLocation]:setToolTip(true, bodyLocation)
            self.clothing[bodyLocation].internal = bodyLocation
			self.clothing[bodyLocation].mode = "outfit"
            self:addChild(self.clothing[bodyLocation])
        end
    end

    self:loadConfig()
end

function BanditCreationMain:onClothingChanged()
    for bodyLocation, dropbox in pairs(self.clothing) do
        self.model:setWornItem(bodyLocation, nil)
    end
    for bodyLocation, dropbox in pairs(self.clothing) do
        local item = dropbox.storedItem
        if item then
            self.model:setWornItem(bodyLocation, item)
        end
    end

	local primary = self.weapons.primary.storedItem
	if primary then
		self.model:setAttachedItem("Rifle On Back", primary)
	else
		self.model:setAttachedItem("Rifle On Back", nil)
	end

	local secondary = self.weapons.secondary.storedItem
	if secondary then
		self.model:setAttachedItem("Holster Right", secondary)
	else
		self.model:setAttachedItem("Holster Right", nil)
	end

    self.avatarPanel:setCharacter(self.model)

end

function BanditCreationMain:updateHairCombo()
    self.hairTypeCombo.options = {}
    local hairStyles = getAllHairStyles(self.model:isFemale())
    for i=1,hairStyles:size() do
        local styleId = hairStyles:get(i-1)
        local hairStyle = self.model:isFemale() and getHairStylesInstance():FindFemaleStyle(styleId) or getHairStylesInstance():FindMaleStyle(styleId)
        local label = styleId
        if label == "" then
            label = getText("IGUI_Hair_Bald")
        else
            label = getText("IGUI_Hair_" .. label);
        end
        if not hairStyle:isNoChoose() then
            self.hairTypeCombo:addOptionWithData(label, hairStyles:get(i-1))
        end
    end
    
    self.beardTypeCombo.options = {}
    if self.model:isFemale() then
        -- no bearded ladies
    else
        local beardStyles = getAllBeardStyles()
        for i=1,beardStyles:size() do
            local label = beardStyles:get(i-1)
            if label == "" then
                label = getText("IGUI_Beard_None")
            else
                label = getText("IGUI_Beard_" .. label);
            end
            self.beardTypeCombo:addOptionWithData(label, beardStyles:get(i-1))
        end
    end
end

function BanditCreationMain:onGenderSelected(combo)
    if combo.selected == 1 then
        -- self.avatar:setFemale(true)
        self.model:setFemale(true)
        self.model:getHumanVisual():removeBodyVisualFromItemType("Base.M_Hair_Stubble")
        self.model:getHumanVisual():removeBodyVisualFromItemType("Base.M_Beard_Stubble")
    else
        -- self.avatar:setFemale(false)
        self.model:setFemale(false)
        self.model:getHumanVisual():removeBodyVisualFromItemType("Base.F_Hair_Stubble")
    end
    self.avatarPanel:setCharacter(self.model)
    self:updateHairCombo()
end

function BanditCreationMain:onSkinColorSelected(button, x, y)
    self.colorPickerSkin:setX(button:getAbsoluteX())
    self.colorPickerSkin:setY(button:getAbsoluteY() + button:getHeight())
    self.colorPickerSkin:setPickedFunc(BanditCreationMain.onSkinColorPicked)
    local color = button.backgroundColor
    self.colorPickerSkin:setInitialColor(ColorInfo.new(color.r, color.g, color.b, 1))
    self:showColorPicker(self.colorPickerSkin)
end

function BanditCreationMain:onSkinColorPicked(color, mouseUp)
    self.skinColorButton.backgroundColor = { r=color.r, g=color.g, b=color.b, a = 1 }
    self.model:getHumanVisual():setSkinTextureIndex(self.colorPickerSkin.index - 1)
    self.avatarPanel:setCharacter(self.model)
end

function BanditCreationMain:onChestHairSelected(index, selected)
    self.model:getHumanVisual():setBodyHairIndex(selected and 0 or -1)
    self.avatarPanel:setCharacter(self.model)
end

function BanditCreationMain:onHairTypeSelected(combo)
    self.hairType = combo.selected - 1
    local hair = combo:getOptionData(combo.selected)
    self.model:getHumanVisual():setHairModel(hair)
    self.avatarPanel:setCharacter(self.model)
end

function BanditCreationMain:onBeardTypeSelected(combo)
    local beard = combo:getOptionData(combo.selected)
    self.model:getHumanVisual():setBeardModel(beard)
    self.avatarPanel:setCharacter(self.model)
end

function BanditCreationMain:onHairColorMouseDown(button, x, y)
    self.colorPickerHair:setX(button:getAbsoluteX())
    self.colorPickerHair:setY(button:getAbsoluteY() + button:getHeight())
    self.colorPickerHair:setPickedFunc(BanditCreationMain.onHairColorPicked)
    local color = button.backgroundColor
    self.colorPickerHair:setInitialColor(ColorInfo.new(color.r, color.g, color.b, 1))
    self:showColorPicker(self.colorPickerHair)
end

function BanditCreationMain:onHairColorPicked(color, mouseUp)
    self.hairColorButton.backgroundColor = { r=color.r, g=color.g, b=color.b, a = 1 }
    local immutableColor = ImmutableColor.new(color.r, color.g, color.b, 1)
    self.model:getHumanVisual():setHairColor(immutableColor)
    self.model:getHumanVisual():setBeardColor(immutableColor)
    self.model:getHumanVisual():setNaturalHairColor(immutableColor)
    self.model:getHumanVisual():setNaturalBeardColor(immutableColor)
    self.avatarPanel:setCharacter(self.model)
end

function BanditCreationMain:addItem(dropbox)
    local listBox = BanditItemsListTable:new(300, 200, 800, 600, self, dropbox)
    listBox:initialise();
    listBox:addToUIManager()
end

function BanditCreationMain:removeItem(dropbox)
    dropbox:setStoredItem(nil)
    self:onClothingChanged()
end

function BanditCreationMain:showColorPicker(picker)
    picker:removeFromUIManager()
    picker:addToUIManager()
end

function BanditCreationMain:onClick(button)

    if button.internal == "SAVE" then
        self:saveConfig()
    end
    
    local modal = BanditClanMain:new(200, 100, 1520, 880)
    modal:initialise()
    modal:addToUIManager()
	self:close()
end

function BanditCreationMain:update()
    ISPanel.update(self)
end

function BanditCreationMain:prerender()
    ISPanel.prerender(self);
    self:drawTextCentre("BANDIT CREATOR", self.width / 2, UI_BORDER_SPACING + 5, 1, 1, 1, 1, UIFont.Title);
end

function BanditCreationMain:loadConfig()
    BanditCustom.Load()

    local data = BanditCustom.Get(self.bid)

	if data.general then
		self.nameEntry:setText(data.general.name)

		if data.general.female then
			self.genderCombo.selected = 1
		else
			self.genderCombo.selected = 2
		end
		self:onGenderSelected(self.genderCombo)

		self.colorPickerSkin.index = data.general.skin
		local color = self.skinColors[data.general.skin]
		self:onSkinColorPicked(color)

		self.hairTypeCombo.selected = data.general.hairType
		self:onHairTypeSelected(self.hairTypeCombo)

		self.beardTypeCombo.selected = data.general.beardType
		self:onBeardTypeSelected(self.beardTypeCombo)

		self.colorPickerHair.index = data.general.hairColor
		local color = self.hairColors[data.general.hairColor]
		self:onHairColorPicked(color)
	end

	if data.clothing then
		for bodyLocation, itemType in pairs(data.clothing) do
			for _, dropbox in pairs(self.clothing) do
				if dropbox.internal == bodyLocation then
					local item = BanditCompatibility.InstanceItem(itemType)
					dropbox:setStoredItem(item)
				end
			end
		end
	end

	if data.weapons then
		if data.weapons.primary then
			local item = BanditCompatibility.InstanceItem(data.weapons.primary)
			self.weapons.primary:setStoredItem(item)
		end
		if data.weapons.secondary then
			local item = BanditCompatibility.InstanceItem(data.weapons.secondary)
			self.weapons.secondary:setStoredItem(item)
		end
	end
    self:onClothingChanged()

end

function BanditCreationMain:saveConfig()
    local data = BanditCustom.Get(self.bid)

	data.general = {}
    data.general.name = self.nameEntry:getText()

    if self.genderCombo.selected == 1 then
        data.general.female = true
    else
        data.general.female = false
    end

    data.general.skin = self.colorPickerSkin.index
    data.general.hairType = self.hairTypeCombo.selected
    data.general.beardType = self.beardTypeCombo.selected
    data.general.hairColor = self.colorPickerHair.index

    data.clothing = {}
    for _, dropbox in pairs(self.clothing) do
        local item = dropbox:getStoredItem()
        if item then
            data.clothing[dropbox.internal] = item:getFullType()
        end
    end

	data.weapons = {}
	local primary = self.weapons.primary:getStoredItem()
	if primary then
		data.weapons.primary = primary:getFullType()
	end

	local secondary = self.weapons.secondary:getStoredItem()
	if secondary then
		data.weapons.secondary = secondary:getFullType()
	end

    BanditCustom.Save()
end

function BanditCreationMain:new(x, y, width, height)
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
    BanditCreationMain.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end
