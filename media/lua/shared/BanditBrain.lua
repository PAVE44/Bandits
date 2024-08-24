BanditBrain = BanditBrain or {}

function BanditBrain.Get(zombie)
    local modData = zombie:getModData()
    return modData.brain
end

function BanditBrain.Update(zombie, brain)
    local modData = zombie:getModData()
    modData.brain = brain
end

function BanditBrain.Remove(zombie)
    local modData = zombie:getModData()
    modData.brain = nil
end
