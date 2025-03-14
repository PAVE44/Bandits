BanditProjectile = BanditProjectile or {}
BanditProjectile.list = {}

BanditProjectile.Add = function(isox, isoy, isoz, dir, projectiles)
    local x, y = ISCoordConversion.ToScreen(isox, isoy, isoz)
    local ndir = dir + ZombRandFloat(0, 0.3) - 0.3
    -- local altTarget = 20 + ZombRand(75)
    if projectiles == 1 then
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir, tick=1})
    elseif projectiles == 5 then
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir-1.7, tick=1})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir-1.3, tick=1})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir, tick=1})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir+1.4, tick=1})
        table.insert(BanditProjectile.list, {x=x, y=y, dir=ndir+1.7, tick=1})
    end
end

BanditProjectile.tex = getTexture("media/textures/mask_white.png")

local updateProjectile = function()
    if not isIngameState() then return end
    if isServer() then return end

    local tex = BanditProjectile.tex
    local zoom = getCore():getZoom(0)
    local baseAlt = 85 / zoom  -- Base height at shooter
    local renderer = getRenderer()
    local projectileList = BanditProjectile.list

    for i = #projectileList, 1, -1 do
        local projectile = projectileList[i]

        -- Convert direction to radians
        local theta = projectile.dir * math.pi / 180  

        -- Apply isometric movement correction
        local b_l = 400 / zoom  -- Bullet movement length
        local dx = math.cos(theta) - math.sin(theta)  -- Isometric X correction
        local dy = (math.cos(theta) + math.sin(theta)) / 2  -- Isometric Y correction

        -- Add slight randomness to the altitude at the target
        local targetAltVariation = ZombRandFloat(-10, 10) / zoom  -- Random height shift at target

        -- Compute start and end positions
        local b_x1 = projectile.x / zoom
        local b_y1 = projectile.y / zoom
        local b_x2 = b_x1 + math.floor(b_l * dx)
        local b_y2 = b_y1 + math.floor(b_l * dy)

        -- Render projectile with slight variation at the endpoint
        renderer:renderline(tex, b_x1, b_y1 - baseAlt, b_x2, b_y2 - (baseAlt + targetAltVariation), 1, 1, 0.78, 0.1)

        -- Update projectile position
        projectile.x = projectile.x + math.floor(b_l * dx)
        projectile.y = projectile.y + math.floor(b_l * dy)
        projectile.tick = projectile.tick + 1

        -- Remove projectile after 10 ticks
        if projectile.tick > 12 then
            table.remove(projectileList, i)
        end
    end
end

Events.OnPreUIDraw.Add(updateProjectile)