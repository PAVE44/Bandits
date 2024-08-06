BanditBrain = BanditBrain or {}

function BanditBrain.Get(zombie)
    local modData = zombie:getModData()
    return modData.brain
end

function BanditBrain.Create(zombie, master)
    local brain = {}
    brain.id = BanditUtils.GetCharacterID(zombie)
    brain.master = BanditUtils.GetCharacterID(master)
    brain.endurance = 1.00
    brain.speech = 0.00
    brain.sleeping = false
    brain.enslaved = true
    brain.combat = false
    brain.firing = false
    brain.enemy = false
    brain.world = {}
    brain.tasks = {}

    brain.weapons = {}
    brain.weapons.melee = false
    brain.weapons.primary = {}
    brain.weapons.primary.name = false
    brain.weapons.primary.magSize = 20
    brain.weapons.primary.bulletsLeft = 0
    brain.weapons.primary.magCount = 0
    brain.weapons.secondary = {}
    brain.weapons.secondary.name = false
    brain.weapons.secondary.magSize = 20
    brain.weapons.secondary.bulletsLeft = 0
    brain.weapons.secondary.magCount = 0

    brain.program = {}
    brain.program.role = nil
    brain.program.stage = nil

    brain.target = {}
    brain.target.x = nil
    brain.target.y = nil
    brain.target.z = nil

    local modData = zombie:getModData()
    modData.brain = brain
    return brain
end

function BanditBrain.Update(zombie, brain)
    local modData = zombie:getModData()
    modData.brain = brain
end

function BanditBrain.Remove(zombie)
    local modData = zombie:getModData()
    modData.brain = nil
end
