BanditMap = BanditMap or {}

BanditMap.ZMap = {}
BanditMap.BMap = {}

BanditMap.Update = function(numberTicks)
    local cell = getCell()
    local zombieList = cell:getZombieList()

    BanditMap.ZMap = {}
    BanditMap.BMap = {}

    for i=0, zombieList:size()-1 do
        local zombie = zombieList:get(i)
        if zombie:isAlive() then
            local id = BanditUtils.GetCharacterID(zombie)
            if zombie:getVariableBoolean("Bandit") then
                local brain = BanditBrain.Get(zombie)
                if not brain.clan then brain.clan = 0 end
                BanditMap.BMap[id] = {x=zombie:getX(), y=zombie:getY(), z=zombie:getZ(), clan=brain.clan, hostile=brain.hostile}
            else
                BanditMap.ZMap[id] = {x=zombie:getX(), y=zombie:getY(), z=zombie:getZ()}
            end
        end
    end
end

Events.OnTick.Add(BanditMap.Update)