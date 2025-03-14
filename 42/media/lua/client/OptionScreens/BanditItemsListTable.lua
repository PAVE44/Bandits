--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "ISUI/ISPanel"

BanditItemsListTable = ISPanel:derive("BanditItemsListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

function BanditItemsListTable:initialise()
    ISPanel.initialise(self);

    local btnCancelWidth = 100 -- getTextManager():MeasureStringX(UIFont.Small, "Close") + 64
    local btnCancelX = math.floor(self:getWidth() / 2) - (btnCancelWidth / 2)

    self.cancel = ISButton:new(btnCancelX, self:getHeight() - UI_BORDER_SPACING - BUTTON_HGT - 1, btnCancelWidth, BUTTON_HGT, "Close", self, BanditItemsListTable.onClick)
    self.cancel.internal = "CLOSE"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel:enableCancelColor()
    self:addChild(self.cancel)

    self.datas = ISScrollingListBox:new(0, 0, self.width, self.height - BUTTON_HGT - 24)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = 48
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
--    self.datas.parent = self;
    self.datas:addColumn("Icon", 0)
    self.datas:addColumn("Type", self.datas.itemheight)
    self.datas:addColumn("Name", 384)
    self.datas:setOnMouseDoubleClick(self, BanditItemsListTable.addItem)
    self:addChild(self.datas)

    local internal = self.dropbox.internal
    local mode = self.dropbox.mode
    local items = {}

    if mode == "outfit" then
        items = getAllItemsForBodyLocation(internal)
    elseif mode == "carriable" then
        local all = getAllItems()
        for i=0, all:size()-1 do
            local item = all:get(i)
            if not item:getObsolete() and not item:isHidden() and item:getMinDamage() > 0 then
                local itemType = item:getFullName()
                local invItem = BanditCompatibility.InstanceItem(itemType)
                local invItemType = WeaponType.getWeaponType(invItem)
                if invItem then
                    if internal == "primary" and invItemType == WeaponType.firearm then
                        table.insert(items, itemType)
                    elseif internal == "secondary" and invItemType == WeaponType.handgun then
                        table.insert(items, itemType)
                    elseif internal == "melee" and invItemType ~= WeaponType.firearm and invItemType ~= WeaponType.handgun then
                        table.insert(items, itemType)
                    elseif internal == "bag" then
                        local container = invItem:getContainer()
                        if container then
                            if container:setCanBeEquipped() == "Back" then
                                table.insert(items, itemType)
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(items, function(a,b) return not string.sort(a, b) end)

    for i, itemType in pairs(items) do
        local item = BanditCompatibility.InstanceItem(itemType)
        self.datas:addItem(item:getDisplayName(), item)
    end


    self.buttons = {}

    --[[
    local spacing = 8
    local size = 64
    local col = 0
    local row = 0
    for i, itemType in pairs(self.items) do
        
        local item = BanditCompatibility.InstanceItem(itemType)
        local tex = item:getTexture()
        local name = item:getName()

        local x = col * (size + spacing) + spacing
        local y = row * (size + spacing + FONT_HGT_SMALL) + spacing
        self.buttons[itemType] = ISButton:new(x, y, size, size, "", self, BanditItemsListTable.onClick)
        self.buttons[itemType].internal = itemType
        self.buttons[itemType]:setTooltip(name)
        self.buttons[itemType]:setImage(tex)
        self.buttons[itemType]:forceImageSize(48, 48)
        self.buttons[itemType]:initialise()
        self.buttons[itemType]:instantiate()
        self:addChild(self.buttons[itemType])

        local label = ISLabel:new(x + size, y + size, BUTTON_HGT, item:getType(), 1, 1, 1, 1, UIFont.Small)
        label:initialise()
        self:addChild(label)

        col = col + 1
        if col == 8 then
            col = 0
            row = row + 1
        end
    end
    ]]


end

function BanditItemsListTable:addItem(item)
    self.dropbox:setStoredItem(item)
    self.parent:onClothingChanged()
end

function BanditItemsListTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    
    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    local iconX = 4
    local iconSize = self.itemheight - 8
    local xoffset = 4
    local x = self.columns[1].size
    local icon = item.item:getTexture()
    --[[
    if item.item:getIconsForTexture() and not item.item:getIconsForTexture():isEmpty() then
        icon = item.item:getIconsForTexture():get(0)
    end]]
    if icon then
        self:drawTextureScaledAspect2(icon, x + xoffset, y + 3, iconSize, iconSize, 1, 1, 1, 1)
    end

    x = self.columns[2].size
    self:drawText(item.item:getFullType(), x + xoffset, y + 3, 1, 1, 1, a, self.font)

    x = self.columns[3].size
    self:drawText(item.item:getDisplayName(), x + xoffset, y + 3, 1, 1, 1, a, self.font)
   
    return y + self.itemheight;

end

function BanditItemsListTable:initList(module)
    print ("ok")
end


function BanditItemsListTable:prerender()
    ISPanel.prerender(self);
end

function BanditItemsListTable:render()
    ISPanel.render(self);
end

function BanditItemsListTable:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    end
end


function BanditItemsListTable:render()
    ISPanel.render(self);
    
end

function BanditItemsListTable:new (x, y, width, height, parent, dropbox)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.moveWithMouse = true;
    o.parent = parent
    o.dropbox = dropbox
    BanditItemsListTable.instance = o;
    return o;
end

