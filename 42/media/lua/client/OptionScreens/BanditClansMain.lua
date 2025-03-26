BanditClansMain = ISPanel:derive("BanditClansMain")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditClansMain:initialise()
    ISPanel.initialise(self)

    local btnCloseWidth = 100 -- getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 64
    local btnCloseX = math.floor(self:getWidth() / 2) - ((btnCloseWidth ) / 2)

    self.cancel = ISButton:new(btnCloseX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnCloseWidth, BUTTON_HGT, "Close", self, BanditClansMain.onClick)
    self.cancel.internal = "CLOSE"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel:enableCancelColor()
    self:addChild(self.cancel)

    local topY = 60
    local clanButtonWidth = 130
    local clanButtonHeight = 130
    local clanButtonSpacing = 20

    local rowY = 0

    BanditCustom.Load()
    local allData = BanditCustom.ClanGetAll()

    local keys = {}
    for key in pairs(allData) do
        table.insert(keys, key)
    end

    table.sort(keys, function(k1, k2)
        return allData[k1].general.name < allData[k2].general.name
    end)

    local allDataSorted = {}
    for _, key in ipairs(keys) do
        allDataSorted[key] = allData[key]
    end

    self.clanButton = {}
    local total = 0
    local i = 0
    local j = 0
    local x
    local y
    for cid, data in pairs(allDataSorted) do
        x = i * (clanButtonWidth + clanButtonSpacing) + clanButtonSpacing
        y = topY + rowY + j * (clanButtonHeight + clanButtonSpacing)

        self.clanButton[cid] = BanditButtonCounter:new(x, y, clanButtonWidth, clanButtonHeight, data.general.name, self, self.onClick, self.onRightClick)
        self.clanButton[cid].internal = "EDITCLAN"
		self.clanButton[cid].cid = cid
		self.clanButton[cid].borderColor = {r=0.4, g=0.4, b=0.4, a=1}
		self.clanButton[cid]:initialise()
		self.clanButton[cid]:instantiate()
		self:addChild(self.clanButton[cid])

        i = i + 1
        if i == 8 then
            j = j + 1
            i = 0
        end
        total = total + 1
    end

    if total < 48 then 
        x = i * (clanButtonWidth + clanButtonSpacing) + clanButtonSpacing
        y = topY + rowY + j * (clanButtonHeight + clanButtonSpacing)

        self.clanButtonNew = BanditButtonCounter:new(x, y, clanButtonWidth, clanButtonHeight, "New Clan", self, self.onClick, self.onRightClick)
        self.clanButtonNew.internal = "NEWCLAN"
		self.clanButtonNew.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
		self.clanButtonNew:initialise()
		self.clanButtonNew:instantiate()
		self:addChild(self.clanButtonNew)
    end
end


function BanditClansMain:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    elseif button.internal == "EDITCLAN" then
        local modal = BanditClanMain:new(500, 80, 1220, 900, button.cid)
        modal:initialise()
        modal:addToUIManager()
        self:removeFromUIManager()
        self:close()
    elseif button.internal == "NEWCLAN" then
        local cid = BanditCustom.GetNextId()
        local bid = BanditCustom.GetNextId()
        local modal = BanditCreationMain:new(500, 80, 1220, 900, bid, cid)
        modal:initialise()
        modal:addToUIManager()
        self:removeFromUIManager()
        self:close()
    end
end

function BanditClansMain:onRightClick(button)
end

function BanditClansMain:update()
    ISPanel.update(self)
end

function BanditClansMain:prerender()
    ISPanel.prerender(self);
    self:drawTextCentre("BANDIT CLANS", self.width / 2, UI_BORDER_SPACING + 5, 1, 1, 1, 1, UIFont.Title);
end

function BanditClansMain:new(x, y, width, height)
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
    BanditClansMain.instance = o;
    ISDebugMenu.RegisterClass(self);
    return o;
end
