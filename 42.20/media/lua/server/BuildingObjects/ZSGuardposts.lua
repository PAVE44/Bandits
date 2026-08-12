ZSPosts = ISBuildingObject:derive("ZSPosts")

function ZSPosts:create(x, y, z, north, sprite)
    BanditPost.GuardToggle(getPlayer(), x, y, z)
end

function ZSPosts:walkTo(x, y, z)
    return true
end

function ZSPosts:isValid(square)
    return square:TreatAsSolidFloor() and square:isFree(false)
end

function ZSPosts:render(x, y, z, square)
    local player = getSpecificPlayer(0)

    if not ZSPosts.floorSprite then
        ZSPosts.floorSprite = IsoSprite.new()
        ZSPosts.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    end

    local hc = getCore():getGoodHighlitedColor()
    if not self:isValid(square) then
        hc = getCore():getBadHighlitedColor()
    end
    
    local remove = false
    local ptype
    if not isDebugEnabled() then ptype = "guard" end

    local posts = BanditPost.GetInRadius(player, ptype, 40)
    for id, gp in pairs(posts) do
        
        alfa = 0.05
        if gp.z == player:getZ() then alfa = 0.8 end
        
        local colors = {r=1, g=1, b=0}

		if gp.type == "container-to" then colors = {r=0, g=0, b=1} end
		if gp.type == "container-from" then colors = {r=0, g=1, b=1} end

        ZSPosts.floorSprite:RenderGhostTileColor(gp.x, gp.y, gp.z, colors.r, colors.g, colors.b, alfa)

        if gp.x == x and gp.y == y and gp.z == z then
            remove = true
        end
    end

    if remove then
        ZSPosts.floorSprite:RenderGhostTileColor(x, y, z, 1, 0, 0, 0.8)
    else
        ZSPosts.floorSprite:RenderGhostTileColor(x, y, z, 0, 1, 0, 0.8)
    end
end

function ZSPosts:new(sprite, northSprite, character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = character
    o.player = character:getPlayerNum()
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end

