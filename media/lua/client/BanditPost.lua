BanditPost = BanditPost or {}

function BanditPost.GuardToggle(player, x, y, z)
    local args = {x=x, y=y, z=z, type="guard"}
    sendClientCommand(player, 'Commands', 'PostToggle', args)
end

function BanditPost.Update(player, post)
    sendClientCommand(player, 'Commands', 'PostUpdate', post)
end

function BanditPost.At(character, ptype)
    local gmd = GetBanditModData()
    local px = math.floor(character:getX() )
    local py = math.floor(character:getY())
    local pz = character:getZ()
    for id, gp in pairs(gmd.Posts) do
        if gp.x == px and gp.y == py and gp.z == pz and (not ptype or gp.type == ptype) then return true end
    end
    return false
end

function BanditPost.GetAll()
    local gmd = GetBanditModData()
    return gmd.Posts
end

function BanditPost.GetInRadius(character, ptype, radius)
    local gmd = GetBanditModData()
    local px = character:getX()
    local py = character:getY()

    local nearPosts = {}
    for id, gp in pairs(gmd.Posts) do
        local dist = BanditUtils.DistTo(gp.x, gp.y, px, py)
        if dist < radius and (not ptype or gp.type == ptype) then
            nearPosts[id] = gp
        end
    end
    return nearPosts
end

function BanditPost.GetClosestFree(character, ptype, radius)
    local gmd = GetBanditModData()
    local px = character:getX()
    local py = character:getY()

    local bestDist = radius
    local bestPost
    for id, gp in pairs(gmd.Posts) do
        local dist = BanditUtils.DistTo(gp.x, gp.y, px, py)
        if dist <= radius then
            if dist < bestDist and (not ptype or gp.type == ptype) then
                local square = getCell():getGridSquare(gp.x, gp.y, gp.z)
                if square then
                    if not square:getZombie() then
                        bestPost = gp
                        bestDist = dist
                    end
                end
            end
        end
    end
    return bestPost
end

function BanditPost.Get(x, y, z, ptype)
    local gmd = GetBanditModData()
    local id = x .. "-" .. y .. "-" .. z
    if gmd.Posts[id] and (not ptype or gmd.Posts[id].type == ptype) then
        return gmd.Posts[id]
    end
end

function BanditPost.Render()
    local playerObj = getPlayer()
	local bo = ZSPosts:new("", "", playerObj)
	getCell():setDrag(bo, playerObj:getPlayerNum())
end

function BanditPost.OnKeyPressed(keynum)
    if keynum == getCore():getKey("POSTS") then
        BanditPost.Render()
    end
end

Events.OnKeyPressed.Add(BanditPost.OnKeyPressed)
