BanditProjectile = BanditProjectile or {}
BanditProjectile.list = {}

BanditProjectile.Add = function(isox, isoy, isoz, dir, projectiles)
    local x, y = ISCoordConversion.ToScreen(isox, isoy, isoz)
    local ndir = dir + ZombRandFloat(0, 0.3) - 0.3
    local altTarget = 20 + ZombRand(75)
    if projectiles == 1 then
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir, tick=1, altTarget=altTarget})
    elseif projectiles == 5 then
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir-1.7, tick=1, altTarget=altTarget})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir-1.3, tick=1, altTarget=altTarget - 1})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir, tick=1, altTarget=altTarget - 2})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir+1.4, tick=1, altTarget=altTarget - 4})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir+1.7, tick=1, altTarget=altTarget + 3})
    end
end

local updateProjectile = function()
    local tex = getTexture("media/textures/mask_white.png")
    -- UIManager.DrawTexture(tex, tx, ty, size, size, 0.7)

    local zoom = getCore():getZoom(0)
    local alt = 85 / zoom
    local renderer = getRenderer()
    -- renderer:renderline(tex, 1000, 1000, 1, 1, 1, 1, 0.2, 1)

    local projectileRemoveList = {}
    local projectileList = BanditProjectile.list
    for i = #projectileList, 1, -1 do
        local projectile = projectileList[i]
        
        local altTarget = projectile.altTarget / zoom

        local dir = projectile.dir
        dir = dir + 30 -- transform to isometric
        if dir > 180 then dir = dir - 360 end
        local theta = dir * 0.0174533  -- Convert degrees to radians
        
        --debug 
        --[[
        local b_l = 200 / zoom
        local b_x1 = projectile.x / zoom
        local b_y1 = projectile.y / zoom
        local b_x2 = b_x1 + math.floor(b_l * math.cos(theta))
        local b_y2 = b_y1 + math.floor(b_l * math.sin(theta))
        renderer:renderline(tex, b_x1, b_y1 - alt, b_x2, b_y2 - alt, 1, 0, 0, 1)
        ]]

        --
        -- bullet
        local b_l = 400 / zoom
        local b_x1 = projectile.x / zoom
        local b_y1 = projectile.y / zoom
        local b_x2 = b_x1 + math.floor(b_l * math.cos(theta))
        local b_y2 = b_y1 + math.floor(b_l * math.sin(theta))

        -- if b_x1 < b_x2 then b_x1, b_x2 = b_x2, b_x1 end
        -- if b_y1 < b_y2 then b_y1, b_y2 = b_y2, b_y1 end

        renderer:renderline(tex, b_x1, b_y1 - alt, b_x2, b_y2 - altTarget, 1, 1, 0.78, 0.1)

        --[[
        -- tail
        local t_l = 20
        local t_x1 = b_x2
        local t_y1 = b_y2
        local t_x2 = b_x2 + math.floor(t_l * math.cos(theta))
        local t_y2 = b_y2 + math.floor(t_l * math.sin(theta)) 
        -- renderer:renderline(tex, t_x1, t_y1, t_x2, t_y2, 0.5, 0.5, 0.5, 0.2)
        ]]

        projectileList[i].x = projectile.x + math.floor(b_l * math.cos(theta))
        projectileList[i].y = projectile.y + math.floor(b_l * math.sin(theta))


        projectileList[i].tick = projectile.tick + 1

        if projectile.tick > 10 then
            table.remove(projectileList, i)
        end
    end
end

Events.OnPreUIDraw.Add(updateProjectile)