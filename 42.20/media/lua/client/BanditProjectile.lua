BanditProjectile = BanditProjectile or {}
BanditProjectile.list = {}

local math_pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_floor = math.floor

BanditProjectile.Add = function(oid, isox, isoy, isoz, dir, projectiles)
    local x, y = ISCoordConversion.ToScreen(isox, isoy, isoz)
    local ndir = dir + ZombRandFloat(0, 0.3) - 0.3
    local theta = ndir * math_pi / 180
    local dx = math_cos(theta) - math_sin(theta)
    local dy = (math_cos(theta) + math_sin(theta)) / 2
    -- local altTarget = 20 + ZombRand(75)
    if projectiles == 1 then
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir, dx=dx, dy=dy, tick=1})
    elseif projectiles == 5 then
        local theta1 = (ndir - 1.7) * math_pi / 180
        local theta2 = (ndir - 1.3) * math_pi / 180
        local theta3 = ndir * math_pi / 180
        local theta4 = (ndir + 1.4) * math_pi / 180
        local theta5 = (ndir + 1.7) * math_pi / 180
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir-1.7, dx=math_cos(theta1) - math_sin(theta1), dy=(math_cos(theta1) + math_sin(theta1)) / 2, tick=1})
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir-1.3, dx=math_cos(theta2) - math_sin(theta2), dy=(math_cos(theta2) + math_sin(theta2)) / 2, tick=1})
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir, dx=math_cos(theta3) - math_sin(theta3), dy=(math_cos(theta3) + math_sin(theta3)) / 2, tick=1})
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir+1.4, dx=math_cos(theta4) - math_sin(theta4), dy=(math_cos(theta4) + math_sin(theta4)) / 2, tick=1})
        table.insert(BanditProjectile.list, {oid=oid, x=x, y=y, dir=ndir+1.7, dx=math_cos(theta5) - math_sin(theta5), dy=(math_cos(theta5) + math_sin(theta5)) / 2, tick=1})
    end
end

BanditProjectile.Stop = function(oid)
    local projectileList = BanditProjectile.list
    for i = #projectileList, 1, -1 do
        local projectile = projectileList[i]
        if projectile.oid == oid then
            table.remove(projectileList, i)
        end
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

        -- Apply isometric movement correction
        local b_l = 600 / zoom  -- Bullet movement length
        local dx = projectile.dx or 0  -- Isometric X correction
        local dy = projectile.dy or 0  -- Isometric Y correction

        -- Add slight randomness to the altitude at the target
        local targetAltVariation = ZombRandFloat(-10, 10) / zoom  -- Random height shift at target

        -- Compute start and end positions
        local b_x1 = projectile.x / zoom
        local b_y1 = projectile.y / zoom
        local stepX = math_floor(b_l * dx)
        local stepY = math_floor(b_l * dy)
        local b_x2 = b_x1 + stepX
        local b_y2 = b_y1 + stepY

        -- Render projectile with slight variation at the endpoint
        renderer:renderline(tex, b_x1, b_y1 - baseAlt, b_x2, b_y2 - (baseAlt + targetAltVariation), 1, 1, 0.72, 0.14)

        -- Update projectile position
        projectile.x = projectile.x + stepX
        projectile.y = projectile.y + stepY
        projectile.tick = projectile.tick + 1

        -- Remove projectile after 10 ticks
        if projectile.tick > 12 then
            table.remove(projectileList, i)
        end
    end
end

Events.OnPreUIDraw.Add(updateProjectile)