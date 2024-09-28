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

    -- not implemented yet
    if false and jobType then
        if jobType:startsWith(getText("IGUI_PuttingInContainer")) then
            print ("load container")
            local destContainer = data.destContainer
            local object = destContainer:getParent()

            if object then
                local item = data.item

                local post = {}
                post.x = object:getX()
                post.y = object:getY()
                post.z = object:getZ()
                post.type = "container-to"
                post.data = {}
                post.data.categories = BanditActionInterceptor.GetContainerCategories(destContainer, item)

                BanditPost.Update(character, post)
            end
        elseif jobType:startsWith(getText("IGUI_TakingFromContainer")) then
            print ("take container")
            local srcContainer = data.srcContainer
            local object = srcContainer:getParent()

            if object then
                local item = data.item
                local category = BanditActionInterceptor.getItemCategory(item)

                local cell = character:getCell()
                local building = character:getBuilding()
                local def = building:getDef()
                local roomDefs = def:getRooms()
                for i=0, roomDefs:size() - 1 do
                    local roomDef = roomDefs:get(i)
                    for x=roomDef:getX(), roomDef:getX2() do
                        for y=roomDef:getY(), roomDef:getY2() do
                            local square = cell:getGridSquare(x, y, roomDef:getZ())
                            if square then
                                local objects = square:getObjects()
                                for i=0, objects:size() - 1 do
                                    local object = objects:get(i)
                                    local container = object:getContainer()
                                    if container and not container:isEmpty() then

                                        local x = object:getX()
                                        local y = object:getY()
                                        local z = object:getZ()

                                        local post = BanditPost.Get(x, y, z, "container-from")
                                        if not post then
                                            post = {}
                                            post.x = x
                                            post.y = y
                                            post.z = z
                                            post.type = "container-from"
                                            post.data = {}
                                            post.data.categories = {}
                                        end
                                        post.data.categories[category] = true

                                        BanditPost.Update(character, post)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnTimedActionPerform.Add(BanditActionInterceptor.Main)