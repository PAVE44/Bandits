BanditCreationMain = ISPanel:derive("BanditCreationMain")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditCreationMain:initialise()
	ISPanel.initialise(self)
	local btnCancelWidth = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 50
	local btnSaveWidth = getTextManager():MeasureStringX(UIFont.Small, "Save") + 50
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
end

function BanditCreationMain:onClick(button)
    if button.internal == "CANCEL" then
        self:close()
	elseif button.internal == "SAVE" then
		self:close()
	end
end


function BanditCreationMain:update()
    ISPanel.update(self)
end

function BanditCreationMain:prerender()
    ISPanel.prerender(self);
    self:drawTextCentre("Bandit Creator", self.width / 2, UI_BORDER_SPACING+1, 1, 1, 1, 1, UIFont.Title);

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
    -- o.bid = bid
    BanditCreationMain.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end
