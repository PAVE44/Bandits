ZSGuardposts = ISBuildingObject:derive("ZSGuardposts")

function ZSGuardposts:create(x, y, z, north, sprite)
	BanditGuardpost.Toggle(getPlayer(), x, y, z)
end

function ZSGuardposts:isValid(square)
	return square:TreatAsSolidFloor()
end

function ZSGuardposts:render(x, y, z, square)
	local player = getPlayer()

	if not ZSGuardposts.floorSprite then
		ZSGuardposts.floorSprite = IsoSprite.new()
		ZSGuardposts.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end

	local hc = getCore():getGoodHighlitedColor()
	if not self:isValid(square) then
		hc = getCore():getBadHighlitedColor()
	end
	
	local remove = false
	local guardposts = BanditGuardpost.GetInRadius(player, 40)
	for id, gp in pairs(guardposts) do
		
		alfa = 0.05
		if gp.z == player:getZ() then alfa = 0.8 end
		
		ZSGuardposts.floorSprite:RenderGhostTileColor(gp.x, gp.y, gp.z, 1, 1, 0, alfa)

		if gp.x == x and gp.y == y and gp.z == z then
			remove = true
		end
	end

	if remove then
		ZSGuardposts.floorSprite:RenderGhostTileColor(x, y, z, 1, 0, 0, 0.8)
	else
		ZSGuardposts.floorSprite:RenderGhostTileColor(x, y, z, 0, 1, 0, 0.8)
	end
end

function ZSGuardposts:new(sprite, northSprite, character)
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

