Bandit = Bandit or {}

function Bandit.AddTask(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.insert(brain.tasks, task)
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.AddTaskFirst(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.insert(brain.tasks, 1, task)
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.GetTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if #brain.tasks > 0 then
        return brain.tasks[1]
    end
    return nil
end

function Bandit.HasTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if #brain.tasks > 0 then
        return true
    end
    return false
end

function Bandit.HasTaskType(zombie, taskType)
    local brain = BanditBrain.Get(zombie)
    if #brain.tasks > 0 and brain.tasks[1].action == taskType then
        return true
    end
    return false
end

function Bandit.HasMoveTask(zombie)
    local brain = BanditBrain.Get(zombie)
    for _, task in pairs(brain.tasks) do
        if task.action == "Move" or task.action == "GoTo" then
            return true
        end
    end
    return false
end

function Bandit.HasActionTask(zombie)
    local brain = BanditBrain.Get(zombie)
    for _, task in pairs(brain.tasks) do
        if task.action ~= "Move" and task.action ~= "GoTo" then
            return true
        end
    end
    return false
end

function Bandit.UpdateTask(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.remove(brain.tasks, 1)
        table.insert(brain.tasks, 1, task)
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.RemoveTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.remove(brain.tasks, 1)
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.ClearTasks(zombie)
    local brain = BanditBrain.Get(zombie)
    local newtasks = {}
    for _, task in pairs(brain.tasks) do
        if task.lock == true then
            table.insert(newtasks, task)
        end
    end

    brain.tasks = newtasks
    BanditBrain.Update(zombie, brain)
end

function Bandit.ClearOtherTasks(zombie, exception)
    local brain = BanditBrain.Get(zombie)
    local newtasks = {}
    for _, task in pairs(brain.tasks) do
        if task.lock == true or task.action == exception then
            table.insert(newtasks, task)
        end
    end

    brain.tasks = newtasks
    BanditBrain.Update(zombie, brain)
end

function Bandit.UpdateEndurance(zombie, delta)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if not brain.endurance then brain.endurance = 1.00 end
        brain.endurance = brain.endurance + delta
        if brain.endurance < 0 then brain.endurance = 0 end
        if brain.endurance > 1 then brain.endurance = 1 end
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.UpdateInfection(zombie, delta)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if not brain.infection then brain.infection = 0 end
        brain.infection = brain.infection + delta
        BanditBrain.Update(zombie, brain)
    end
end

function Bandit.ForceStationary(zombie, stationary)
    local brain = BanditBrain.Get(zombie)
    brain.stationary = stationary
    BanditBrain.Update(zombie, brain)
end

function Bandit.IsForceStationary(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.stationary
end

function Bandit.SetSleeping(zombie, sleeping)
    local brain = BanditBrain.Get(zombie)
    brain.sleeping = sleeping
    BanditBrain.Update(zombie, brain)
end

function Bandit.IsSleeping(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.sleeping
end

function Bandit.SetCapabilities(zombie, capabilities)
    local brain = BanditBrain.Get(zombie)
    brain.capabilities = capabilities
    BanditBrain.Update(zombie, brain)
end

function Bandit.Can(zombie, capability)
    local brain = BanditBrain.Get(zombie)
    if brain.capabilities[capability] then return true end
    return false
end

-- Functions that require brain sync below

-- Bandit ownership
function Bandit.GetMaster(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.master
end

function Bandit.SetMaster(zombie, master)
    local brain = BanditBrain.Get(zombie)
    brain.master = master
    BanditBrain.Update(zombie, brain)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end


-- Bandit Programs
function Bandit.GetProgram(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.program
end

function Bandit.SetProgram(zombie, program, programParams)
    local brain = BanditBrain.Get(zombie)
    brain.program = {}
    brain.program.name = program
    brain.program.stage = "Prepare"
    brain.program.params = {}
    for k, v in pairs(programParams) do
        brain.program.params[k] = v
    end

    BanditBrain.Update(zombie, brain)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

function Bandit.SetProgramStage(zombie, stage)
    local brain = BanditBrain.Get(zombie)
    brain.program.stage = stage
    BanditBrain.Update(zombie, brain)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

-- Bandit hostility
function Bandit.SetHostile(zombie, hostile)
    local brain = BanditBrain.Get(zombie)
    brain.hostile = hostile
    BanditBrain.Update(zombie, brain)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

function Bandit.IsHostile(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.hostile
end

-- Bandit weapons
function Bandit.GetWeapons(zombie)
    local brain = BanditBrain.Get(zombie)
    return brain.weapons
end

function Bandit.GetBestWeapon(zombie)
    local brain = BanditBrain.Get(zombie)
    local weapons = brain.weapons
    if weapons.primary.bulletsLeft > 0 or weapons.primary.magCount > 0 then
        return weapons.primary.name
    elseif weapons.secondary.bulletsLeft > 0 or weapons.secondary.magCount > 0 then
        return weapons.secondary.name
    else
        return weapons.melee
    end
end

function Bandit.IsOutOfAmmo(zombie)
    local brain = BanditBrain.Get(zombie)
    local weapons = brain.weapons
    if weapons.primary.bulletsLeft == 0 and weapons.primary.magCount == 0 and weapons.secondary.bulletsLeft == 0 and weapons.secondary.magCount == 0 then
        return true
    end
    return false
end

function Bandit.SetWeapons(zombie, weapons)
    local brain = BanditBrain.Get(zombie)
    brain.weapons = weapons
    BanditBrain.Update(zombie, brain)
    Bandit.UpdateItemsToSpawnAtDeath(zombie)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

-- Inventory
function Bandit.SetInventory(zombie, inventory)
    local brain = BanditBrain.Get(zombie)
    brain.inventory = inventory
    BanditBrain.Update(zombie, brain)
    Bandit.UpdateItemsToSpawnAtDeath(zombie)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

function Bandit.Has(zombie, item)
    local brain = BanditBrain.Get(zombie)
    for _, i in pairs(brain.inventory) do
        if i == item then return true end
    end
    return false
end

-- Bandit loot inventory
function Bandit.SetLoot(zombie, loot)
    local brain = BanditBrain.Get(zombie)
    brain.loot = loot
    BanditBrain.Update(zombie, brain)
    Bandit.UpdateItemsToSpawnAtDeath(zombie)
    sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

-- This translates weapons, loot, inventory to actual items to be
-- spawned at bandit death
function Bandit.UpdateItemsToSpawnAtDeath(zombie)
    if not BanditUtils.IsController(zombie) then return end
    
    local brain = BanditBrain.Get(zombie)
    local weapons = brain.weapons
    --zombie:setPrimaryHandItem(nil)
    --zombie:resetEquippedHandsModels()
    zombie:clearItemsToSpawnAtDeath()
    
    -- keyring
    if brain.fullname then
        local item = InventoryItemFactory.CreateItem("Base.KeyRing")
        item:setName(brain.fullname .. " Key Ring")
        zombie:addItemToSpawnAtDeath(item)
    end

    -- update weapons that the bandit has
    if weapons.melee then 
        local item = InventoryItemFactory.CreateItem(weapons.melee)
        item:setCondition(1+ZombRand(10))
        zombie:addItemToSpawnAtDeath(item)
    end

    if weapons.primary then
        if weapons.primary.name then

            if weapons.primary.magName then
                local mag = InventoryItemFactory.CreateItem(weapons.primary.magName)
                mag:setCurrentAmmoCount(weapons.primary.bulletsLeft)
                mag:setMaxAmmo(weapons.primary.magSize)
                zombie:addItemToSpawnAtDeath(mag)

                local gun = InventoryItemFactory.CreateItem(weapons.primary.name)
                gun:setCondition(3+ZombRand(15))
                gun:setClip(nil)
                zombie:addItemToSpawnAtDeath(gun)

                for i=1, weapons.primary.magCount do
                    local mag = InventoryItemFactory.CreateItem(weapons.primary.magName)
                    mag:setCurrentAmmoCount(weapons.primary.magSize)
                    mag:setMaxAmmo(weapons.primary.magSize)
                    zombie:addItemToSpawnAtDeath(mag)
                end
            end
        end
    end

    if weapons.secondary then
        if weapons.secondary.name then

            if weapons.secondary.magName then
                local mag = InventoryItemFactory.CreateItem(weapons.secondary.magName)
                mag:setCurrentAmmoCount(weapons.secondary.bulletsLeft)
                mag:setMaxAmmo(weapons.secondary.magSize)
                zombie:addItemToSpawnAtDeath(mag)

                local gun = InventoryItemFactory.CreateItem(weapons.secondary.name)
                gun:setClip(nil)
                gun:setCondition(3+ZombRand(22))
                zombie:addItemToSpawnAtDeath(gun)

                for i=1, weapons.secondary.magCount do
                    local mag = InventoryItemFactory.CreateItem(weapons.secondary.magName)
                    mag:setCurrentAmmoCount(weapons.secondary.magSize)
                    mag:setMaxAmmo(weapons.secondary.magSize)
                    zombie:addItemToSpawnAtDeath(mag)
                end
            end
        end
    end

    -- update loot items that the bandit has
    local loot = brain.loot
    if loot then
        for _, itemType in pairs(brain.loot) do
            local item = InventoryItemFactory.CreateItem(itemType)
            zombie:addItemToSpawnAtDeath(item)
        end
    end
end

function Bandit.Say(zombie, phrase, force)
    local brain = BanditBrain.Get(zombie)
    
    if not force and brain.speech and brain.speech > 0 then return end
    if force then zombie:getEmitter():stopAll() end
    
    local player = getPlayer()
    local dist = math.sqrt(math.pow(player:getX() - zombie:getX(), 2) + math.pow(player:getY() - zombie:getY(), 2))
    
    if dist <= 14 then
        local id = BanditUtils.GetCharacterID(zombie)
        local voice = 1 + math.abs(id) % 5
        if voice > 2 then voice = 1 end

        local sex = "Male"
        if zombie:isFemale() then 
            sex = "Female" 
            voice = 3
        end

        local sound
        local length = 2
        if phrase == "SPOTTED" then
            sound = "ZSSpotted_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(6))
        elseif phrase == "HIT" then
            sound = "ZSHit_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(14))
            length = 0.5
        elseif phrase == "BREACH" then
            sound = "ZSBreach_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(6))
            length = 4
        elseif phrase == "RELOADING" then
            sound = "ZSReloading_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(6))
            length = 4
        elseif phrase == "CAR" then
            sound = "ZSCar_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(6))
            length = 4
        elseif phrase == "DEATH" then
            sound = "ZSDeath_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(8))
            length = 6
        elseif phrase == "DEAD" then
            sound = "ZSDead_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(6))
            length = 3
        elseif phrase == "BURN" then
            sound = "ZSBurn_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(3))
            length = 8
        elseif phrase == "DRAGDOWN" then
            sound = "ZSDragdown_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(3))
            length = 8
        elseif phrase == "INSIDE" then
            sound = "ZSInside_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(3))
            length = 6
        elseif phrase == "OUTSIDE" then
            sound = "ZSOutside_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(3))
            length = 6
        elseif phrase == "UPSTAIRS" then
            sound = "ZSUpstairs_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(1))
            length = 6
        elseif phrase == "ROOM_KITCHEN" then
            sound = "ZSRoom_Kitchen_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(1))
            length = 6
        elseif phrase == "ROOM_BATHROOM" then
            sound = "ZSRoom_Bathroom_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(1))
            length = 6
        elseif phrase == "DEFENDER_SPOTTED" then
            sound = "ZSDefender_Spot_" .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(4))
            length = 5
        end

        if sound then
            -- text captions
            if SandboxVars.Bandits.General_Captions then
                local text = "IGUI_Bandits_Speech_" .. sound
                if brain.hostile then
                    zombie:addLineChatElement(getText(text), 0.8, 0.1, 0.1)
                else
                    zombie:addLineChatElement(getText(text), 0.1, 0.8, 0.1)
                end
            end

            -- audiable speech
            if SandboxVars.Bandits.General_Speak then
                if localSound then
                    local emitter = getWorld():getFreeEmitter(zombie:getX(), zombie:getY(), zombie:getZ())
                    -- emitter:setVolumeAll(0.2)
                    emitter:playSoundLocal(sound)
                else
                    zombie:getEmitter():playVocals(sound)
                end
            end

            brain.speech = length
            BanditBrain.Update(zombie, brain)
            addSound(getPlayer(), zombie:getX(), zombie:getY(), zombie:getZ(), 5, 50)
        end
    end

end

