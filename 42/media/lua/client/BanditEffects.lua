BanditEffects = BanditEffects or {}

BanditEffects.tab = {}
BanditEffects.tick = 0

BanditEffects.Add = function(effect)

    table.insert(BanditEffects.tab, effect)
end

BanditEffects.Process = function()
    if isServer() then return end

    BanditEffects.tick = BanditEffects.tick + 1
    if BanditEffects.tick >= 16 then
        BanditEffects.tick = 0
    end

    if BanditEffects.tick % 2 == 0 then return end

    local cell = getCell()
    for i, effect in pairs(BanditEffects.tab) do

        local square = cell:getGridSquare(effect.x, effect.y, effect.z)
        if square then

            if not effect.repCnt then effect.repCnt = 1 end
            if not effect.rep then effect.rep = 1 end

            if not effect.frame then 

                local dummy = IsoObject.new(square, "")

                dummy:setOffsetX(effect.offset)
                dummy:setOffsetY(effect.offset)

                -- square:AddTileObject(dummy)
                square:AddSpecialObject(dummy)
                if effect.frameRnd then
                    effect.frame = 1 + ZombRand(effect.frameCnt)
                else
                    effect.frame = 1
                end

                effect.object = dummy

                if effect.r and effect.g and effect.g then
                    effect.object:setCustomColor(effect.r, effect.g, effect.b, 0)
                end

            end
            
            if effect.frame > effect.frameCnt and effect.rep >= effect.repCnt then
                square:RemoveTileObject(effect.object)
                BanditEffects.tab[i] = nil
            else
                if effect.frame > effect.frameCnt then
                    effect.rep = effect.rep + 1
                    effect.frame = 1
                end

                local frameStr = string.format("%03d", effect.frame)
                local alpha = (effect.repCnt - effect.rep + 1) / effect.repCnt
                local sprite = effect.object:getSprite()
                
                if sprite then
                    effect.object:getSprite():LoadFrameExplicit("media/textures/FX/" .. effect.name .. "/" .. frameStr .. ".png")
                    --effect.object:setAlpha(alpha)
                    effect.frame = effect.frame + 1
                end
            end
        else
            BanditEffects.tab[i] = nil
        end
    end
end

local onServerCommand = function(mod, command, args)
    if mod == "BanditEffects" then
        BanditEffects[command](args)
    end
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnTick.Add(BanditEffects.Process)