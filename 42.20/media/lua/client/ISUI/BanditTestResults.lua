BanditTestResults = ISPanel:derive("BanditTestResults")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditTestResults:initialise()
    ISPanel.initialise(self)

    local btnCloseWidth = 100 -- getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 64
    local btnPullWidth = 150 -- getTextManager():MeasureStringX(UIFont.Small, "Pull From Server") + 64
    local btnPushWidth = 150 -- getTextManager():MeasureStringX(UIFont.Small, "Push To Server") + 64
    local btnCloseX = math.floor(self:getWidth() / 2) - ((btnCloseWidth ) / 2)

    self.cancel = ISButton:new(btnCloseX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - UI_BORDER_SPACING, btnCloseWidth, BUTTON_HGT, getText("UI_BanditsCreator_Close"), self, BanditTestResults.onClick)
    self.cancel.internal = "CLOSE"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    if BanditCompatibility.GetGameVersion() >= 42 then
        self.cancel:enableCancelColor()
    end
    self:addChild(self.cancel)

end


function BanditTestResults:onClick(button)
    if button.internal == "CLOSE" then
        self:removeFromUIManager()
        if MainScreen and MainScreen.instance then
            MainScreen.instance.bottomPanel:setVisible(true)
        end
        self:close()
    end
end

function BanditTestResults:onRightClick(button)
end

function BanditTestResults:update()
    ISPanel.update(self)
end

function BanditTestResults:prerender()
    ISPanel.prerender(self)
    self:drawTextCentre("Problems detected", self.width / 2, UI_BORDER_SPACING + 5, 1, 1, 1, 1, UIFont.Medium)
end

function BanditTestResults:new(x, y, width, height, problems)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2)
    y = getCore():getScreenHeight() / 2 - (height / 2)
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.width = width
    o.height = height
    o.moveWithMouse = true
    o.problems = problems
    BanditTestResults.instance = o
    ISDebugMenu.RegisterClass(self)
    return o
end
