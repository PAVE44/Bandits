BanditActionInterceptor = BanditActionInterceptor or {}

local function predicateAll(item)
	return true
end


-- this analyzes actions performed by players that will be useful as data for friendlies actions
LuaEventManager.AddEvent("OnTimedActionPerform")

BanditActionInterceptor.getItemCategory = function(item)
    local category = item:getDisplayCategory()
    if category == "Food" then
        local canSpoil = item:getOffAgeMax() < 1000
        if canSpoil then
            category = "FoodFresh"
        end
    end
    return category
end

BanditActionInterceptor.GetContainerCategories = function(container, newItem)
    
    -- return categories of items already present in the container
    local categories = {}
    local items = ArrayList.new()
    container:getAllEvalRecurse(predicateAll, items)
    for i=0, items:size()-1 do
        local item = items:get(i)
        local category = BanditActionInterceptor.getItemCategory(item)
        
        categories[category] = true
    end

    -- add category of the item being added
    categories[BanditActionInterceptor.getItemCategory(newItem)] = true

    return categories
end

BanditActionInterceptor.Main = function(data)
    local character = data.character
    local jobType = data.jobType
    local action = data.action:getMetaType()

    if not action then return end

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

            local object = container:getParent()
            if object then
                local sprite = object:getSprite()
                local props = sprite:getProperties()
                if sprite:getProperties():Is("IsTrashCan") then
                    BanditPlayerBase.UpdateTrashcan(object)
                end
            end

            BanditPlayerBase.UpdateContainer(container)

        elseif jobType:startsWith(getText("IGUI_TakingFromContainer")) then
            local container = data.srcContainer
            BanditPlayerBase.UpdateContainer(container)
        end

    elseif action == "ISSeedAction" then
        if data.plant then
            if data.plant.globalObject then
                local farm = data.plant.globalObject
                BanditPlayerBase.UpdateFarm(farm)
            end
        end
    elseif action == "ISShovelAction" or action == "ISHarvestPlantAction" then
        if data.plant then
            if data.plant.globalObject then
                local farm = data.plant.globalObject
                BanditPlayerBase.RemoveFarm(farm)
            end
        end
    elseif action == "ISBuildAction" then
        if data.spriteName then
            if data.spriteName == "carpentry_02_52" or data.spriteName == "carpentry_02_54" then
                local square = getCell():getGridSquare(data.x, data.y, data.z)
                if square then 
                    local obj = IsoObject.new(square, data.spriteName, "")
                    BanditPlayerBase.UpdateWaterSource(obj)
                end
            elseif data.spriteName == "location_community_cemetary_01_33" or data.spriteName == "location_community_cemetary_01_34" then
                local square = getCell():getGridSquare(data.x, data.y, data.z)
                if square then 
                    local obj = IsoObject.new(square, data.spriteName, "")
                    BanditPlayerBase.UpdateGrave(obj)
                end
            end
        end
    elseif action == "ISTakeWaterAction" then
        if data.waterObject then
            BanditPlayerBase.UpdateWaterSource(data.waterObject)
        end
    elseif action == "ISWashClothing" or action == "ISWashYourself" then
        if data.sink then
            BanditPlayerBase.UpdateWaterSource(data.sink)
        end

    elseif action == "ISPlugGenerator" or action == "ISActivateGenerator" then
        if data.generator then
            BanditPlayerBase.UpdateGenerator(data.generator)
        end
    elseif action == "ISTakeGenerator" then
        if data.generator then
            BanditPlayerBase.RemoveGenerator(data.generator)
        end
    
    end
end

Events.OnTimedActionPerform.Add(BanditActionInterceptor.Main)