BanditMap = ISPanel:derive("BanditMap")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BanditMap:initialise()
    ISPanel.initialise(self)
end

function BanditMap:onRightClick(button)
end

function BanditMap:update()
    ISPanel.update(self)
end

function BanditMap:onDoubleClick()
    BanditMenu.mapInstance:removeFromUIManager()
    BanditMenu.mapInstance = nil
    self:close()
end

function BanditMap:prerender()
    local gmd = GetBanditModData()
    local wanderers = gmd.Wanderers

    local xmin = 0
    local xmax = 16000
    local ymin = 0
    local ymax = 16000
    local resolution = self.width / (xmax - xmin)
    local friendly = 0
    local enemy = 0
    local cidStat = {}

    for i, group in ipairs(wanderers) do
        if group.x >= xmin and group.x <= xmax and group.y >= ymin and group.y <= ymax then
            local x = (group.x - xmin) * resolution
            local y = (group.y - ymin) * resolution

            local colors
            if group.alive then
                alpha = 1
            else
                alpha = 0.5
            end

            local clan = BanditCustom.ClanGet(group.cid)
            if clan.spawn.friendly then
                friendly = friendly + 1
                colors = {r = 1, g = 1, b = 0}
            else
                enemy = enemy + 1
                colors = {r = 1, g = 0, b = 0}
            end
            if not cidStat[group.cid] then
                cidStat[group.cid] = {}
                cidStat[group.cid].name = clan.general.name
                cidStat[group.cid].cnt = 1
            else
                cidStat[group.cid].cnt = cidStat[group.cid].cnt + 1
            end

            self:drawRect(x, y, 4, 4, alpha, colors.r, colors.g, colors.b)
            self:drawRectBorder(x, y, 4, 4, alpha, colors.r, colors.g, colors.b)
        end
    end

    local player = getPlayer()
    local px, py = player:getX(), player:getY()
    local x = (px - xmin) * resolution
    local y = (py - ymin) * resolution

    self:drawRect(x, y, 4, 4, 1, 0, 1, 0)
    self:drawRectBorder(x, y, 4, 4, 1, 0, 1, 0)

    self:drawText("WANDERING GROUPS: " .. #wanderers, 5, 5, 1, 1, 1, 1, UIFont.Small)
    self:drawText("FRIENDLY GROUPS: " .. friendly, 5, 20, 1, 1, 1, 1, UIFont.Small)
    self:drawText("ENEMY GROUPS: " .. enemy, 5, 35, 1, 1, 1, 1, UIFont.Small)

    i = 0
    for cid, stat in pairs(cidStat) do
        self:drawText("CLAN " .. stat.name .. ": " .. stat.cnt, 5, 50 + 15 * i, 1, 1, 1, 1, UIFont.Small)
        i = i + 1
    end

    ISPanel.prerender(self)
end

function BanditMap:new(x, y, width, height, icon, text)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.1}
    o.width = width
    o.height = height
    o.moveWithMouse = true
    o.icon = icon
    o.text = text
    BanditMap.instance = o
    ISDebugMenu.RegisterClass(self)
    return o
end
