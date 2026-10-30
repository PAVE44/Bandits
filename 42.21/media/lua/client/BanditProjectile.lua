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

-- Muzzle flash rendered manually per shooter. B42 removed IsoGameCharacter.startMuzzleFlash
-- and EffectsManager is not exposed to lua, so the vanilla flash textures are drawn here
-- as a direction-aligned billboard at the muzzle, same technique as the tracers above.
-- The vanilla sheets are UV atlases for the 3d flash model; only the side-flame region
-- is sampled (uv below), which is the side-on look the 3d model produces anyway.
BanditMuzzleFlash = BanditMuzzleFlash or {}
BanditMuzzleFlash.list = {}
BanditMuzzleFlash.tex = {}
for i = 0, 5 do
    local tex = getTexture("media/textures/weapons/firearm/fx/muzzle_flash_0" .. i .. ".png")
    if tex then table.insert(BanditMuzzleFlash.tex, tex) end
end

-- side-flame blob region within each 256x256 sheet (bright head at top, tail below)
BanditMuzzleFlash.u1 = 0.0
BanditMuzzleFlash.u2 = 0.32
BanditMuzzleFlash.v1 = 0.22
BanditMuzzleFlash.v2 = 0.82

BanditMuzzleFlash.Add = function(isox, isoy, isoz, dir)
    local texCount = #BanditMuzzleFlash.tex
    if texCount == 0 then return end
    local x, y = ISCoordConversion.ToScreen(isox, isoy, isoz)
    local theta = dir * math_pi / 180
    local dx = math_cos(theta) - math_sin(theta)
    local dy = (math_cos(theta) + math_sin(theta)) / 2
    local tex = BanditMuzzleFlash.tex[1 + ZombRand(texCount)]
    table.insert(BanditMuzzleFlash.list, {x=x, y=y, dx=dx, dy=dy, tex=tex, tick=0})
end

local updateMuzzleFlash = function()
    if not isIngameState() then return end
    if isServer() then return end

    local list = BanditMuzzleFlash.list
    if #list == 0 then return end

    local zoom = getCore():getZoom(0)
    local renderer = getRenderer()
    -- barrel height on screen: screen Y grows downward, so a bigger value puts the
    -- flash higher. The tracer uses 85; the barrel tip sits a bit above that line.
    local baseAlt = 92 / zoom
    local u1, u2 = BanditMuzzleFlash.u1, BanditMuzzleFlash.u2
    local v1, v2 = BanditMuzzleFlash.v1, BanditMuzzleFlash.v2

    for i = #list, 1, -1 do
        local flash = list[i]

        -- muzzle position: slightly ahead of the shooter along the firing direction
        local muzzleDist = 36 / zoom
        local mx = flash.x / zoom + muzzleDist * flash.dx
        local my = flash.y / zoom - baseAlt + muzzleDist * flash.dy

        -- forward (fire direction) and side axes in screen space
        local len = math.sqrt(flash.dx * flash.dx + flash.dy * flash.dy)
        local fxv, fyv = flash.dx / len, flash.dy / len
        local sxv, syv = -fyv, fxv

        local alpha = 1 - flash.tick * 0.35
        local flashLen = (140 + flash.tick * 20) / zoom -- along fire direction
        local flashWid = (72 + flash.tick * 8) / zoom
        local hw = flashWid / 2

        -- quad: bright flame head anchored at the muzzle, tail extending forward;
        -- texture top (v1) maps to the muzzle edge, texture bottom (v2) to the tip
        local mlx, mly = mx - sxv * hw, my - syv * hw -- muzzle left
        local mrx, mry = mx + sxv * hw, my + syv * hw -- muzzle right
        local tlx, tly = mlx + fxv * flashLen, mly + fyv * flashLen -- tip left
        local trx, try_ = mrx + fxv * flashLen, mry + fyv * flashLen -- tip right

        renderer:renderPoly(flash.tex,
            mlx, mly, mrx, mry, trx, try_, tlx, tly,
            1, 1, 1, alpha,
            u1, v1, u2, v1, u2, v2, u1, v2)

        flash.tick = flash.tick + 1
        if flash.tick > 2 then
            table.remove(list, i)
        end
    end
end

Events.OnPreUIDraw.Add(updateMuzzleFlash)