BanditActionInterceptor = BanditActionInterceptor or {}

local function predicateAll(item)
	return true
end

-- this is useful for catching player actions that have no predefined triggers
-- and convert them to actual triggers

LuaEventManager.AddEvent("OnTimedActionPerform")

BanditActionInterceptor.Main = function(data)
    local character = data.character
    if not character then return end

    local action = data.action:getMetaType()
    if not action then return end

    -- action for registering player base
    if action == "ISInventoryTransferAction" then
        local container = data.destContainer
        if not container then return end

        local containerType = container:getType()
        
        if containerType == "fridge" or containerType == "freezer" then
            print ("base created")
            local object = container:getParent()
            local square = object:getSquare()
            local building = square:getBuilding()
            local buildingDef = building:getDef()
            local x = buildingDef:getX()
            local y = buildingDef:getY()
            local x2 = buildingDef:getX2()
            local y2 = buildingDef:getY2()

            local args = {x=x, y=y, x2=x2, y2=y2}
            sendClientCommand(character, 'Commands', 'BaseUpdate', args)
            -- BanditPlayerBase.RegisterBase(buildingDef)
        end
    end
end

Events.OnTimedActionPerform.Add(BanditActionInterceptor.Main)