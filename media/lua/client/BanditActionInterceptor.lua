BanditActionInterceptor = BanditActionInterceptor or {}

local function predicateAll(item)
	return true
end

-- this is useful for catching player actions that have no predefined triggers
-- and convert them to actual triggers

LuaEventManager.AddEvent("OnTimedActionPerform")

BanditActionInterceptor.Main = function(data)
    local character = data.character
    local jobType = data.jobType
    local action = data.action:getMetaType()

    if not action then return end

    -- action for registering player base
    if action == "ISInventoryTransferAction" then
        if jobType:startsWith(getText("IGUI_PuttingInContainer")) then
            print ("load container")
            local container = data.destContainer
            local containerType = container:getType()
            
            if containerType == "fridge" or containerType == "freezer" then
                local object = container:getParent()
                local square = object:getSquare()
                local building = square:getBuilding()
                local buildingDef = building:getDef()
                BanditPlayerBase.RegisterBase(buildingDef)
            end
        end
    end
end

Events.OnTimedActionPerform.Add(BanditActionInterceptor.Main)