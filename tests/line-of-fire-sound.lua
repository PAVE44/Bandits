-- Run from the mod root with a standalone Lua interpreter.
package.path = "42.21\\media\\lua\\shared\\?.lua;" .. package.path
BloodBodyPartType = {}
WeaponReloadType = {SHOTGUN = "shotgun", DOUBLE_BARREL_SHOTGUN = "double", DOUBLE_BARREL_SHOTGUN_SAWN = "sawn"}
require "BanditUtils"

local impacts, hits, visited = {}, {}, {}
local material = "Concrete"
local missingProperties = false
local characters = {}
local window, door
local cell = {}
function cell:getGridSquare(x, y, z)
    visited[x .. ":" .. y] = true
    local occupants = characters[x .. ":" .. y] or {}
    return {
        getProperties = function()
            if missingProperties then return nil end
            return {get = function(_, name) if name == "MaterialType" then return material end end}
        end,
        getWindow = function() return window end,
        getIsoDoor = function() return door end,
        getVehicleContainer = function() return nil end,
        getMovingObjects = function()
            return {size = function() return #occupants end, get = function(_, i) return occupants[i + 1] end}
        end,
        playSound = function(_, name) table.insert(impacts, {name = name, x = x, y = y, z = z}) end,
    }
end
getCell = function() return cell end
getSpecificPlayer = function() return {} end
getWorld = function()
    return {getFreeEmitter = function(_, x, y, z)
        return {playSound = function(_, name)
            table.insert(impacts, {name = name, x = x, y = y, z = z})
            return #impacts
        end}
    end}
end
BanditCompatibility = {setParameterValueByName = function(_, _, name) assert(name == "BulletHitSurface") end}
BanditUtils.GetCharacterID = function(chr) return chr.id end
BanditUtils.Hit = function(_, _, chr, damageSplit)
    assert(damageSplit == 1.4)
    table.insert(hits, chr.id)
    return true
end
instanceof = function(chr, name) return chr.class == name end
local shooter = {id = 0, getX = function() return 100 end, getY = function() return 100 end}
local piercing, reload = false, "handgun"
local weapon = {
    isPiercingBullets = function() return piercing end,
    getWeaponReloadType = function() return reload end,
}
local function fire(x, y)
    impacts, hits, visited = {}, {}, {}
    return BanditUtils.ManageLineOfFire(shooter, x, y, 0, weapon)
end

assert(fire(120, 100))
assert(#impacts == 1, "One 20-tile shot must not produce 43 impacts")
assert(impacts[1].x == 120 and impacts[1].y == 100, "Impact moved away from the target tile")
assert(visited["118:98"] and visited["122:102"], "Neighbor hit candidates were removed")
assert(fire(100, 100) and #impacts == 1, "Point-blank trace changed")
assert(fire(80, 85) and #impacts == 1, "Reverse diagonal trace duplicated impacts")
material = nil
assert(fire(120, 100) and #impacts == 0, "Material-free tile emitted an impact")
missingProperties = true
assert(fire(120, 100) and #impacts == 0, "Missing properties caused an error")
missingProperties, material = false, "Concrete"

characters["105:100"] = {{id = 1, class = "IsoZombie", getVehicle = function() return nil end}}
characters["106:100"] = {{id = 2, class = "IsoPlayer", getVehicle = function() return nil end}}
assert(not fire(120, 100) and #hits == 1 and #impacts == 0, "Single projectile no longer stops at its first victim")
piercing = true
assert(not fire(120, 100) and #hits == 2, "Piercing hit limit changed")
piercing, reload = false, "shotgun"
assert(fire(120, 100) and #hits == 2 and #impacts == 1, "Shotgun traversal changed")
characters = {}
reload = "handgun"
local thumps = 0
door = {
    IsOpen = function() return false end,
    getNorth = function() return false end,
    getSprite = function()
        return {getProperties = function()
            return {has = function() return true end, get = function() return "WoodDoor" end}
        end}
    end,
}
ZombRand = function() return 9 end
BanditUtils.Thump = function() thumps = thumps + 1 end
assert(not fire(120, 100) and thumps == 1, "Door collision or damage behavior changed")
assert(#impacts == 1 and impacts[1].name == "HitBarricadePlank", "Door impact audio changed")
print("Line-of-fire sound and damage regression tests passed")
