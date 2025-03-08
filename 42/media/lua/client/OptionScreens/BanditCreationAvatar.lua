require "ISUI/ISButton"
require "ISUI/ISComboBox"
require "ISUI/ISPanel"
require "ISUI/ISUI3DModel"

BanditCreationAvatar = ISPanel:derive("BanditCreationAvatar")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local NAME_HGT = FONT_HGT_SMALL + 8

function BanditCreationAvatar:createChildren()
	self.avatarBackgroundTexture = getTexture("media/ui/avatarBackgroundWhite.png")

	self.avatarPanel = ISUI3DModel:new(2, 2, self.width - 4, self.height - 4 - NAME_HGT)
	self.avatarPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
	self.avatarPanel.borderColor = {r=1, g=1, b=1, a=0.0}
	self:addChild(self.avatarPanel)

	self.avatarPanel:setState("idle")
	self.avatarPanel:setDirection(IsoDirections.S)
	self.avatarPanel:setIsometric(false)
	self.avatarPanel:setDoRandomExtAnimations(true)

	if self.clickable then
		if self.name then
			local x = (self.width / 2) + (getTextManager():MeasureStringX(UIFont.Small, self.name) / 2)
			local nameBox = ISLabel:new(x, self.height - 4 - NAME_HGT, NAME_HGT, self.name, 1, 1, 1, 0.8, UIFont.Small, false)
			nameBox:initialise()
			nameBox:instantiate()
			-- nameBox.center = true
			nameBox:setWidth(self.width)
			
			self:addChild(nameBox)
		end
		self.clickButton = BanditButtonCounter:new(2, 2, self.width - 4, self.height - 4, "", self, self.onClick, self.onRightClick)
		self.clickButton.bid = self.bid
		self.clickButton.cid = self.cid
		self.clickButton.displayBackground = nil
		self.clickButton.backgroundColor = {r=0, g=0, b=0, a=0.0}
		self.clickButton:initialise()
		self.clickButton:instantiate()
		self:addChild(self.clickButton)
	end

	if self.controls then
		self.turnLeftButton = ISButton:new(self.avatarPanel.x, self.avatarPanel:getBottom()-BUTTON_HGT, BUTTON_HGT, BUTTON_HGT, "", self, self.onTurnChar)
		self.turnLeftButton.internal = "TURNCHARACTERLEFT"
		self.turnLeftButton:initialise()
		self.turnLeftButton:instantiate()
		self.turnLeftButton:setImage(getTexture("media/ui/ArrowLeft.png"))
		self:addChild(self.turnLeftButton)

		self.turnRightButton = ISButton:new(self.avatarPanel:getRight()-BUTTON_HGT, self.avatarPanel:getBottom()-BUTTON_HGT, BUTTON_HGT, BUTTON_HGT, "", self, self.onTurnChar)
		self.turnRightButton.internal = "TURNCHARACTERRIGHT"
		self.turnRightButton:initialise()
		self.turnRightButton:instantiate()
		self.turnRightButton:setImage(getTexture("media/ui/ArrowRight.png"))
		self:addChild(self.turnRightButton)

		self.animCombo = ISComboBox:new(0, self.avatarPanel:getBottom() + UI_BORDER_SPACING, self.width, BUTTON_HGT, self, self.onAnimSelected)
		self.animCombo:initialise()
		self:addChild(self.animCombo)
		self.animCombo:addOptionWithData(getText("IGUI_anim_Idle"), "EventIdle")
		self.animCombo:addOptionWithData(getText("IGUI_anim_Walk"), "EventWalk")
		self.animCombo:addOptionWithData(getText("IGUI_anim_Run"), "EventRun")
		self.animCombo.selected = 1
	end
end

function BanditCreationAvatar:prerender()
	ISPanel.prerender(self)
	-- self:drawRectBorder(self.avatarPanel.x - 2, self.avatarPanel.y - 2, self.avatarPanel.width + 4, self.avatarPanel.height + 4, 1, 0.3, 0.3, 0.3)
	self:drawTextureScaled(self.avatarBackgroundTexture, self.avatarPanel.x, self.avatarPanel.y, self.avatarPanel.width, self.avatarPanel.height, 1, 0.4, 0.4, 0.4);
end

function BanditCreationAvatar:update()
	if not self.onclick then return end

	local a = self.borderColor.a
	if self.selected and a < 1 then
		a = a + 0.6
		if a > 1 then a = 1 end
		self.borderColor = {r=1, g=1, b=1, a=a}
	elseif not self.selected and a > 0.2 then
		a = a - 0.2
		if a < 0.2 then a = 0.2 end
		self.borderColor = {r=1, g=1, b=1, a=a}
	end
end

function BanditCreationAvatar:onMouseMove(dx, dy)
	self.selected = true
end

function BanditCreationAvatar:onMouseMoveOutside(dx, dy)
	self.selected = false
end

function BanditCreationAvatar:onDelete(button)
	if button.internal == "YES" then
		BanditCustom.Load()
		BanditCustom.Delete(self.bid)
		BanditCustom.Save()
		self.parent:onAvatarListChange()
	end
end

function BanditCreationAvatar:onClick(button)
	local modal = BanditCreationMain:new(500, 80, 1220, 900, self.bid, self.cid)
    modal:initialise()
    modal:addToUIManager()
	self.parent:removeFromUIManager()
	self.parent:close()
end

function BanditCreationAvatar:onRightClick(button)
	if self.add then return end
	local player = 0
    local width = 380
	local height = 120
    local x = getPlayerScreenLeft(player) + (getPlayerScreenWidth(player) - width) / 2
    local y = getPlayerScreenTop(player) + (getPlayerScreenHeight(player) - height) / 2

	local modal = ISModalDialog:new(x, y, width, height, "Delete bandit \"" .. self.name .. "\" ?", true, self, BanditCreationAvatar.onDelete, player)
    modal:initialise()
    modal:addToUIManager()
    modal:setAlwaysOnTop(true)
    modal:bringToTop()
end

function BanditCreationAvatar:onTurnChar(button, x, y)
	local direction = self.avatarPanel:getDirection()
	if button.internal == "TURNCHARACTERLEFT" then
		direction = IsoDirections.RotLeft(direction)
		self.avatarPanel:setDirection(direction)
	elseif button.internal == "TURNCHARACTERRIGHT" then
		direction = IsoDirections.RotRight(direction)
		self.avatarPanel:setDirection(direction)
	end
end

function BanditCreationAvatar:onAnimSelected(combo)
--	self.avatarPanel:setState(combo:getOptionData(combo.selected))
	self.avatarPanel:reportEvent(combo:getOptionData(combo.selected))
end

function BanditCreationAvatar:setCharacter(character)
	self.avatarPanel:setCharacter(character)
end

function BanditCreationAvatar:setSurvivorDesc(survivorDesc)
	self.avatarPanel:setSurvivorDesc(survivorDesc)
end

function BanditCreationAvatar:setFacePreview(val)
	if val then
		self.avatarPanel:setZoom(14)
		self.avatarPanel:setYOffset(-0.85)
	else
		self.avatarPanel:setZoom(1)
		self.avatarPanel:setYOffset(0)
	end
end

function BanditCreationAvatar:rescaleAvatarViewer()
	local h = math.floor(self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT) --floor to remove rounding errors
	self.avatarPanel:setHeight(h-4)
	self.avatarPanel:setWidth(h/2-4)
	self.avatarPanel:setX((self.width - h/2)/2+2)
	self.avatarPanel:setY(2)

	self.turnLeftButton:setX(self.avatarPanel:getX())
	self.turnLeftButton:setY(self.avatarPanel:getBottom() - BUTTON_HGT)
	self.turnRightButton:setX(self.avatarPanel:getRight() - BUTTON_HGT)
	self.turnRightButton:setY(self.turnLeftButton:getY())

	self.animCombo:setWidth(self.avatarPanel:getWidth()+4)
	self.animCombo:setX(self.avatarPanel:getX()-2)
	self.animCombo:setY(self.avatarPanel:getBottom() + UI_BORDER_SPACING+2)
end

function BanditCreationAvatar:new(x, y, width, height, bid, cid)
	local o = ISPanel.new(self, x, y, width, height)
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	o.bid = bid
	o.cid = cid
	o.direction = IsoDirections.E
	return o
end
