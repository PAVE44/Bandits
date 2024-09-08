BanditGuardpost = BanditGuardpost or {}

function BanditGuardpost.Toggle(player, x, y, z)
    local args = {x=x, y=y, z=z}
    sendClientCommand(player, 'Commands', 'GuardpostToggle', args)
end

function BanditGuardpost.At(character)
    local gmd = GetBanditModData()
    local px = math.floor(character:getX() )
    local py = math.floor(character:getY())
    local pz = character:getZ()
    for id, gp in pairs(gmd.Guardposts) do
        --[[local dist = math.sqrt(math.pow(gp.x - px, 2) + math.pow(gp.y - py, 2))
        if dist < 0.8 then
            return true
        end]]
        if gp.x == px and gp.y == py and gp.z == pz then return true end
    end
    return false
end

function BanditGuardpost.GetAll()
    local gmd = GetBanditModData()
    return gmd.Guardposts
end

function BanditGuardpost.GetInRadius(character, radius)
    local gmd = GetBanditModData()
    local px = character:getX()
    local py = character:getY()

    local nearGuardPosts = {}
    for id, gp in pairs(gmd.Guardposts) do
        local dist = math.sqrt(math.pow(gp.x - px, 2) + math.pow(gp.y - py, 2))
        if dist < radius then
            nearGuardPosts[id] = gp
        end
    end
    return nearGuardPosts
end

function BanditGuardpost.GetClosestFree(character, radius)
    local gmd = GetBanditModData()
    local px = character:getX()
    local py = character:getY()

    local bestDist = radius
    local bestGuardpost
    for id, gp in pairs(gmd.Guardposts) do
        local dist = math.sqrt(math.pow(gp.x - px, 2) + math.pow(gp.y - py, 2))
        if dist <= radius then
            if dist < bestDist then
                local square = getCell():getGridSquare(gp.x, gp.y, gp.z)
                if square then
                    if not square:getZombie() then
                        bestGuardpost = gp
                        bestDist = dist
                    end
                end
            end
        end
    end
    return bestGuardpost
end

function BanditGuardpost.Render()
    local playerObj = getPlayer()
	local bo = ZSGuardposts:new("", "", playerObj)
	getCell():setDrag(bo, playerObj:getPlayerNum())
end

function BanditGuardpost.OnKeyPressed(keynum)
    if keynum == getCore():getKey("GUARDPOSTS") then
        BanditGuardpost.Render()
    end
end

Events.OnKeyPressed.Add(BanditGuardpost.OnKeyPressed)
