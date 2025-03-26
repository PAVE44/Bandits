Bandit = Bandit or {}

Bandit.SoundTab = Bandit.SoundTab or {}
Bandit.SoundTab.SPOTTED =           {prefix = "ZSSpotted_", chance = 90, randMax = 6, length = 2}
Bandit.SoundTab.HIT =               {prefix = "ZSHit_", chance = 100, randMax = 14, length = 0.1}
Bandit.SoundTab.BREACH =            {prefix = "ZSBreach_", chance = 80, randMax = 6, length = 10}
Bandit.SoundTab.RELOADING =         {prefix = "ZSReloading_", chance = 80, randMax = 6, length = 4}
Bandit.SoundTab.CAR =               {prefix = "ZSCar_", chance = 90, randMax = 6, length = 4}
Bandit.SoundTab.DEATH =             {prefix = "ZSDeath_", chance = 70, randMax = 8, length = 6}
Bandit.SoundTab.DEAD =              {prefix = "ZSDead_", chance = 100, randMax = 6, length = 3}
Bandit.SoundTab.BURN =              {prefix = "ZSBurn_", chance = 100, randMax = 3, length = 8}
Bandit.SoundTab.DRAGDOWN =          {prefix = "ZSDragdown_", chance = 100, randMax = 3, length = 8}
Bandit.SoundTab.INSIDE =            {prefix = "ZSInside_", chance = 40, randMax = 3, length = 25}
Bandit.SoundTab.OUTSIDE =           {prefix = "ZSOutside_", chance = 40, randMax = 3, length = 25}
Bandit.SoundTab.UPSTAIRS =          {prefix = "ZSUpstairs_", chance = 40, randMax = 1, length = 25}
Bandit.SoundTab.ROOM_KITCHEN =      {prefix = "ZSRoom_Kitchen_", chance = 40, randMax = 1, length = 25}
Bandit.SoundTab.ROOM_BATHROOM =     {prefix = "ZSRoom_Bathroom_", chance = 40, randMax = 1, length = 25}
Bandit.SoundTab.DEFENDER_SPOTTED =  {prefix = "ZSDefender_Spot_", chance = 80, randMax = 4, length = 8}
Bandit.SoundTab.THIEF_SPOTTED =     {prefix = "ZSThief_Spot_", chance = 80, randMax = 6, length = 12}

Bandit.SoundStopList = Bandit.SoundStopList or {}
table.insert(Bandit.SoundStopList, "BeginRemoveBarricadePlank")
table.insert(Bandit.SoundStopList, "BlowTorch")
table.insert(Bandit.SoundStopList, "GeneratorAddFuel")
table.insert(Bandit.SoundStopList, "GeneratorRepair")
table.insert(Bandit.SoundStopList, "GetWaterFromTapMetalBig")

Bandit.VisualDamage = {}

Bandit.VisualDamage.Melee = {"ZedDmg_BACK_Slash", "ZedDmg_BellySlashLeft", "ZedDmg_BellySlashRight", "ZedDmg_BELLY_Slash", 
                             "ZedDmg_ChestSlashLeft", "ZedDmg_CHEST_Slash", "ZedDmg_FaceSkullLeft", "ZedDmg_FaceSkullRight", 
                             "ZedDmg_HeadSlashCentre01", "ZedDmg_HeadSlashCentre02", "ZedDmg_HeadSlashCentre03", "ZedDmg_HeadSlashLeft01", 
                             "ZedDmg_HeadSlashLeft02", "ZedDmg_HeadSlashLeft03", "ZedDmg_HeadSlashLeftBack01", "ZedDmg_HeadSlashLeftBack02", 
                             "ZedDmg_HeadSlashRight01", "ZedDmg_HeadSlashRight02", "ZedDmg_HeadSlashRight03", "ZedDmg_HeadSlashRightBack01", 
                             "ZedDmg_HeadSlashRightBack02", "ZedDmg_HEAD_Skin", "ZedDmg_HEAD_Slash", "ZedDmg_Mouth01", 
                             "ZedDmg_Mouth02", "ZedDmg_MouthLeft", "ZedDmg_MouthRight", "ZedDmg_NoChin", 
                             "ZedDmg_NoEarLeft", "ZedDmg_NoEarRight", "ZedDmg_NoNose", "ZedDmg_ShoulderSlashLeft", 
                             "ZedDmg_ShoulderSlashRight", "ZedDmg_SkullCap", "ZedDmg_SkullUpLeft", "ZedDmg_SkullUpRight"}

Bandit.VisualDamage.Gun = {"ZedDmg_BulletBelly01", "ZedDmg_BulletBelly02", "ZedDmg_BulletBelly03", "ZedDmg_BulletChest01", 
                           "ZedDmg_BulletChest02", "ZedDmg_BulletChest03", "ZedDmg_BulletChest04", "ZedDmg_BulletFace01",
                           "ZedDmg_BulletFace02", "ZedDmg_BulletForehead01", "ZedDmg_BulletForehead02", "ZedDmg_BulletForehead03",
                           "ZedDmg_BulletLeftTemple", "ZedDmg_BulletRightTemple", "ZedDmg_BELLY_Bullet", "ZedDmg_BELLY_Shotgun",
                           "ZedDmg_CHEST_Bullet", "ZedDmg_CHEST_Shotgun", "ZedDmg_HEAD_Bullet", "ZedDmg_HEAD_Shotgun",
                           "ZedDmg_ShotgunBelly", "ZedDmg_ShotgunChestCentre", "ZedDmg_ShotgunChestLeft", "ZedDmg_ShotgunChestRight",
                           "ZedDmg_ShotgunFaceFull", "ZedDmg_ShotgunFaceLeft", "ZedDmg_ShotgunFaceRight", "ZedDmg_ShotgunLeft",
                           "ZedDmg_ShotgunRight"}

Bandit.Expertise = {}
Bandit.Expertise.Assasin = 1
Bandit.Expertise.Breaker = 2
Bandit.Expertise.Electrician = 3
Bandit.Expertise.Cook = 4
Bandit.Expertise.Goblin = 5
Bandit.Expertise.Infected = 6
Bandit.Expertise.Mechanic = 7
Bandit.Expertise.Medic = 8
Bandit.Expertise.Recon = 9
Bandit.Expertise.Thief = 10
Bandit.Expertise.Repairman = 11
Bandit.Expertise.Tracker = 12
Bandit.Expertise.Trapper = 13
Bandit.Expertise.Traitor = 14
Bandit.Expertise.Sacrificer = 15
Bandit.Expertise.Zombiemaster = 16

Bandit.Engine = true

local function predicateAll(item)
    return true
end
                        

function Bandit.ForceSyncPart(zombie, syncData)
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'BanditUpdatePart', syncData)
end

function Bandit.AddTask(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then

        if #brain.tasks > 9 then
            print ("[WARN] Task queue too big, flushing!")
            brain.tasks = {}
        end
    
        table.insert(brain.tasks, task)
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.AddTaskFirst(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then

        if #brain.tasks > 9 then
            print ("[WARN] Task queue too big, flushing!")
            brain.tasks = {}
        end

        table.insert(brain.tasks, 1, task)
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.GetTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if #brain.tasks > 0 then
            return brain.tasks[1]
        end
    end
    return nil
end

function Bandit.HasTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if #brain.tasks > 0 then
            return true
        end
    end
    return false
end

function Bandit.HasTaskType(zombie, taskType)
    local brain = BanditBrain.Get(zombie)
    if brain then
        --[[
        if #brain.tasks > 0 and brain.tasks[1].action == taskType then
            return true
        end]]
        for _, task in pairs(brain.tasks) do
            if task.action == taskType then
                return true
            end
        end
    end
    return false
end

function Bandit.HasMoveTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        for _, task in pairs(brain.tasks) do
            if task.action == "Move" or task.action == "GoTo" then
                return true
            end
        end
    end
    return false
end

function Bandit.HasActionTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        for _, task in pairs(brain.tasks) do
            if task.action ~= "Move" and task.action ~= "GoTo" then
                return true
            end
        end
    end
    return false
end

function Bandit.UpdateTask(zombie, task)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.remove(brain.tasks, 1)
        table.insert(brain.tasks, 1, task)
        --BanditBrain.Update(zombie, brain)
    end
end

function Bandit.RemoveTask(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        table.remove(brain.tasks, 1)
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.ClearTasks(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local newtasks = {}
        for _, task in pairs(brain.tasks) do
            if task.lock == true then
                table.insert(newtasks, task)
            end
        end

        brain.tasks = newtasks
        -- BanditBrain.Update(zombie, brain)
    end

    local emitter = zombie:getEmitter()
    local stopList = Bandit.SoundStopList

    for _, stopSound in pairs(stopList) do
        if emitter:isPlaying(stopSound) then
            emitter:stopSoundByName(stopSound)
        end
    end
end

function Bandit.ClearMoveTasks(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local newtasks = {}
        for _, task in pairs(brain.tasks) do
            if task.action ~= "Move" and task.action ~= "GoTo" then
                table.insert(newtasks, task)
            end
        end

        brain.tasks = newtasks
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.ClearOtherTasks(zombie, exception)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local newtasks = {}
        for _, task in pairs(brain.tasks) do
            if task.lock == true or task.action == exception then
                table.insert(newtasks, task)
            end
        end

        brain.tasks = newtasks
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.UpdateEndurance(zombie, delta)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if not brain.endurance then brain.endurance = 1.00 end
        brain.endurance = brain.endurance + delta
        if brain.endurance < 0 then brain.endurance = 0 end
        if brain.endurance > 1 then brain.endurance = 1 end
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.GetInfection(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if not brain.infection then brain.infection = 0 end
        return brain.infection
    end
    return nil
end

function Bandit.UpdateInfection(zombie, delta)
    local brain = BanditBrain.Get(zombie)
    if brain then
        if not brain.infection then brain.infection = 0 end
        brain.infection = brain.infection + delta
        -- if brain.infection > 90 then print (brain.infection) end
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.ForceStationary(zombie, stationary)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.stationary = stationary
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsForceStationary(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.stationary
    end
end

function Bandit.SetNearFire(zombie, nearFire)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.nearFire = nearFire
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsNearFire(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.nearFire
    end
end

function Bandit.SetSleeping(zombie, sleeping)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.sleeping = sleeping
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsSleeping(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.sleeping
    end
end

function Bandit.SetAim(zombie, aim)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.aim = aim
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsAim(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.aim
    end
end

function Bandit.SetMoving(zombie, moving)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.moving = moving
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsMoving(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.moving
    end
end


function Bandit.HasExpertise(zombie, exp)
    local brain = BanditBrain.Get(zombie)
    if brain and brain.exp then
        for _, v in pairs(brain.exp) do
            if v == exp then return true end
        end
    end
    return false
end

-- Functions that require brain sync below

-- Bandit ownership
function Bandit.GetMaster(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.master
    end
end

function Bandit.SetMaster(zombie, master)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.master = master
        -- BanditBrain.Update(zombie, brain)
        -- sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
    end
end

-- Bandit Programs
function Bandit.GetProgram(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.program
    end
end

function Bandit.SetProgram(zombie, program, programParams)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.program = {}
        brain.program.name = program
        brain.program.stage = "Prepare"

        -- BanditBrain.Update(zombie, brain)
    end
    -- sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

function Bandit.SetProgramStage(zombie, stage)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.program.stage = stage
        -- BanditBrain.Update(zombie, brain)
    end
    -- sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
end

-- Bandit hostility
function Bandit.SetHostile(zombie, hostile)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.hostile = hostile
        -- BanditBrain.Update(zombie, brain)
    end
end

function Bandit.IsHostile(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.hostile
    end
end

-- Bandit weapons
function Bandit.GetWeapons(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        return brain.weapons
    end
end

function Bandit.GetBestWeapon(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local weapons = brain.weapons
        if weapons.primary.bulletsLeft > 0 or 
           (weapons.primary.type == "mag" and weapons.primary.magCount > 0) or 
           (weapons.primary.type == "nomag" and weapons.primary.ammoCount > 0) then

            return weapons.primary.name
        elseif weapons.secondary.bulletsLeft > 0 or 
           (weapons.secondary.type == "mag" and weapons.secondary.magCount > 0) or 
           (weapons.secondary.type == "nomag" and weapons.secondary.ammoCount > 0) then

            return weapons.secondary.name
        else
            return weapons.melee
        end
    end
end

function Bandit.IsOutOfAmmo(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local weapons = brain.weapons
        if weapons.primary.bulletsLeft <= 0 and 
            ((weapons.primary.type == "mag" and weapons.primary.magCount <= 0) or
             (weapons.primary.type == "nomag" and weapons.primary.ammoCount <= 0))
            and weapons.secondary.bulletsLeft <= 0 and 
            ((weapons.secondary.type == "mag" and weapons.secondary.magCount <= 0) or 
             (weapons.secondary.type == "nomag" and weapons.secondary.ammoCount <= 0)) then
            return true
        end
    end
    return false
end

function Bandit.IsBareHands(zombie)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local weapons = brain.weapons
        if weapons.melee == "Base.BareHands" then
            return true
        end
    end
    return false
end

function Bandit.NeedResupplySlot(zombie, slot)
    local brain = BanditBrain.Get(zombie)
    if brain then
        local weapons = brain.weapons
        if not weapons[slot].name or 
            (
                weapons.primary.bulletsLeft <= 0 and 
                (
                    (weapons[slot].type == "mag" and weapons[slot].magCount <= 0) or
                    (weapons[slot].type == "nomag" and weapons[slot].ammoCount <= 0)
                )
            ) then

            return true

        end
    end
    return false
end

function Bandit.SetWeapons(zombie, weapons)
    local brain = BanditBrain.Get(zombie)
    if brain then
        brain.weapons = weapons
        -- BanditBrain.Update(zombie, brain)
        Bandit.UpdateItemsToSpawnAtDeath(zombie)
        -- sendClientCommand(getPlayer(), 'Commands', 'BanditUpdate', brain)
    end
end

-- This translates weapons, loot, inventory to actual items to be
-- spawned at bandit death
function Bandit.UpdateItemsToSpawnAtDeath(zombie)
    
    local brain = BanditBrain.Get(zombie)
    local weapons = brain.weapons
    --zombie:setPrimaryHandItem(nil)
    --zombie:resetEquippedHandsModels()
    zombie:clearItemsToSpawnAtDeath()

    -- keyring / id
    if brain.fullname then
        BanditCompatibility.AddId(zombie, brain.fullname)
    end

    -- update inventory
    local inventory = zombie:getInventory()
    local items = ArrayList.new()
    inventory:getAllEvalRecurse(predicateAll, items)
    for i=0, items:size()-1 do
        local item = items:get(i)
        item:getModData().preserve = true
        zombie:addItemToSpawnAtDeath(item)
    end

    -- update weapons that the bandit has
    if weapons.melee and weapons.melee ~= "Base.BareHands" then 
        local item = BanditCompatibility.InstanceItem(weapons.melee)
        item:getModData().preserve = true
        item = BanditCompatibility.SetRandomCondition(item, 0.8)

        zombie:addItemToSpawnAtDeath(item)
    end

    if weapons.primary then
        if weapons.primary.name then

            local gun = BanditCompatibility.InstanceItem(weapons.primary.name)
            if gun then
                gun = BanditWeapons.Modify(gun, brain)
                gun:getModData().preserve = true
                gun = BanditCompatibility.SetRandomCondition(gun, 0.8)
                zombie:addItemToSpawnAtDeath(gun)
            end

            if weapons.primary.type == "mag" and weapons.primary.magName then
                local mag = BanditCompatibility.InstanceItem(weapons.primary.magName)
                if mag then
                    mag:getModData().preserve = true
                    mag:setCurrentAmmoCount(weapons.primary.bulletsLeft)
                    mag:setMaxAmmo(weapons.primary.magSize)
                    zombie:addItemToSpawnAtDeath(mag)
                end

                for i=1, weapons.primary.magCount do
                    local mag = BanditCompatibility.InstanceItem(weapons.primary.magName)
                    if mag then
                        mag:getModData().preserve = true
                        mag:setCurrentAmmoCount(weapons.primary.magSize)
                        mag:setMaxAmmo(weapons.primary.magSize)
                        zombie:addItemToSpawnAtDeath(mag)
                    end
                end
            elseif weapons.primary.type == "nomag" and weapons.primary.ammoName then
                for i=1, weapons.primary.ammoCount do
                    local ammo = BanditCompatibility.InstanceItem(weapons.primary.ammoName)
                    if ammo then
                        ammo:getModData().preserve = true
                        zombie:addItemToSpawnAtDeath(ammo)
                    end
                end
            end
        end
    end

    if weapons.secondary then
        if weapons.secondary.name then

            local gun = BanditCompatibility.InstanceItem(weapons.secondary.name)
            if gun then
                gun = BanditWeapons.Modify(gun, brain)
                gun:getModData().preserve = true
                gun = BanditCompatibility.SetRandomCondition(gun, 0.8)
                zombie:addItemToSpawnAtDeath(gun)
            end

            if weapons.secondary.type == "mag" and weapons.secondary.magName then
                local mag = BanditCompatibility.InstanceItem(weapons.secondary.magName)
                if mag then
                    mag:getModData().preserve = true
                    mag:setCurrentAmmoCount(weapons.secondary.bulletsLeft)
                    mag:setMaxAmmo(weapons.secondary.magSize)
                    zombie:addItemToSpawnAtDeath(mag)
                end

                for i=1, weapons.secondary.magCount do
                    local mag = BanditCompatibility.InstanceItem(weapons.secondary.magName)
                    if mag then
                        mag:getModData().preserve = true
                        mag:setCurrentAmmoCount(weapons.secondary.magSize)
                        mag:setMaxAmmo(weapons.secondary.magSize)
                        zombie:addItemToSpawnAtDeath(mag)
                    end
                end
            elseif weapons.secondary.type == "nomag" and weapons.secondary.ammoName then
                for i=1, weapons.secondary.ammoCount do
                    local ammo = BanditCompatibility.InstanceItem(weapons.secondary.ammoName)
                    if ammo then
                        ammo:getModData().preserve = true
                        zombie:addItemToSpawnAtDeath(ammo)
                    end
                end
            end
        end
    end

    -- update loot items that the bandit has
    --[[
    local loot = brain.loot
    if loot then
        for _, itemType in pairs(brain.loot) do
            local item = BanditCompatibility.InstanceItem(itemType)
            if item then
                if item:IsDrainable() then
                    item:setUses(1+ZombRand(2))
                elseif item:IsWeapon() then
                    item:setCondition(1+ZombRand(3))
                end
                zombie:addItemToSpawnAtDeath(item)
            end
        end
    end]]

    -- clothing
    --[[
    if brain.clothing then
        for _, itemType in pairs(brain.clothing) do
            local item = BanditCompatibility.InstanceItem(itemType)
            item:getModData().preserve = true
            zombie:addItemToSpawnAtDeath(item)
        end
    end]]

    local bag
    if brain.bag and brain.bag.name then
        bag = BanditCompatibility.InstanceItem(brain.bag.name)
        bag:getModData().preserve = true
        zombie:addItemToSpawnAtDeath(bag)
    end

    local loot = {}
    local lootBag = {}
    -- update loot

    -- essential loot
    table.insert(loot, {itemType="Base.WaterBottle", chance=100, n=1})
    table.insert(loot, {itemType="Base.HandTorch", chance=40, n=1})
    table.insert(loot, {itemType="Base.Soap2", chance=40, n=1})

    table.insert(lootBag, {itemType="Base.TinnedBeans", chance=5, n=4})
    table.insert(lootBag, {itemType="Base.CannedCarrots2", chance=6, n=4})
    table.insert(lootBag, {itemType="Base.CannedChili", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedCorn", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedCornedBeef", chance=4, n=4})
    table.insert(lootBag, {itemType="Base.CannedFruitCocktail", chance=5, n=4})
    table.insert(lootBag, {itemType="Base.CannedMushroomSoup", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedPeaches", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedPeas", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedPineapple", chance=2, n=4})
    table.insert(lootBag, {itemType="Base.CannedPotato2", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedSardines", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.TinnedSoup", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedBolognese", chance=7, n=4})
    table.insert(lootBag, {itemType="Base.CannedTomato2", chance=5, n=4})
    table.insert(lootBag, {itemType="Base.TinOpener", chance=85, n=1})
    table.insert(lootBag, {itemType="Base.WaterBottle", chance=20, n=2})
    table.insert(lootBag, {itemType="Base.Book", chance=10, n=2})
    
    -- experise loot
    if Bandit.HasExpertise(zombie, Bandit.Expertise.Assasin) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Breaker) then
        table.insert (loot, {itemType="Base.Crowbar", chance=100, n=1})
        table.insert (loot, {itemType="Base.BlowTorch", chance=100, n=1})
        table.insert (loot, {itemType="Base.WeldingMask", chance=100, n=1})
        table.insert (lootBag, {itemType="Base.Sledgehammer", chance=1, n=1})
        table.insert (lootBag, {itemType="Base.PropaneTank", chance=4, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Electrician) then
        table.insert (loot, {itemType="Base.Screwdriver", chance=100, n=1})
        table.insert (lootBag, {itemType="Base.LightBulbBox", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.ElectricWire", chance=20, n=3})
        table.insert (lootBag, {itemType="Base.ElectronicsScrap", chance=30, n=5})
        table.insert (lootBag, {itemType="Base.BookElectrician1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookElectrician2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookElectrician3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookElectrician4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookElectrician5", chance=2, n=1})
        table.insert (lootBag, {itemType="Base.ElectronicsMag1", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.ElectronicsMag2", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.ElectronicsMag3", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.ElectronicsMag4", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.ElectronicsMag5", chance=3, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Cook) then
        table.insert (lootBag, {itemType="Base.Pot", chance=30, n=1})
        table.insert (lootBag, {itemType="Base.Pan", chance=30, n=1})
        table.insert (lootBag, {itemType="Base.Salt", chance=30, n=1})
        table.insert (lootBag, {itemType="Base.Pepper", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.Spoon", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.Spatula", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.Bowl", chance=20, n=2})
        table.insert (lootBag, {itemType="Base.KitchenKnife", chance=50, n=1})
        table.insert (lootBag, {itemType="Base.Charcoal", chance=20, n=2})
        table.insert (lootBag, {itemType="Base.Matches", chance=50, n=1})
        table.insert (lootBag, {itemType="camping.CampfireKit", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookCooking1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookCooking2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookCooking3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookCooking4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookCooking5", chance=2, n=1})
        table.insert (lootBag, {itemType="Base.CookingMag1", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.CookingMag2", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.CookingMag3", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.CookingMag4", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.CookingMag5", chance=3, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Goblin) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Infected) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Mechanic) then
        table.insert (loot, {itemType="Base.Wrench", chance=100, n=1})
        table.insert (loot, {itemType="Base.LugWrench", chance=100, n=1})
        table.insert (loot, {itemType="Base.Jack", chance=100, n=1})
        table.insert (loot, {itemType="Base.PetrolCan", chance=100, n=1})
        table.insert (lootBag, {itemType="Base.ScrewsBox", chance=7, n=1})
        table.insert (lootBag, {itemType="Base.BookMechanic1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookMechanic2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookMechanic3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookMechanic4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookMechanic5", chance=2, n=1})
        table.insert (lootBag, {itemType="Base.MechanicMag1", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.MechanicMag2", chance=3, n=1})
        table.insert (lootBag, {itemType="Base.MechanicMag3", chance=3, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Medic) then
        table.insert (loot, {itemType="Base.Bandage", chance=100, n=2})
        table.insert (lootBag, {itemType="Base.SutureNeedle", chance=50, n=1})
        table.insert (lootBag, {itemType="Base.AlcoholBandage", chance=12, n=10})
        table.insert (lootBag, {itemType="Base.BandageBox", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.SutureNeedle", chance=50, n=3})
        table.insert (lootBag, {itemType="Base.SutureNeedleBox", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.SutureNeedleHolder", chance=50, n=1})
        table.insert (lootBag, {itemType="Base.Tweezers", chance=50, n=1})
        table.insert (lootBag, {itemType="Base.Stethoscope", chance=30, n=1})
        table.insert (lootBag, {itemType="Base.Antibiotics", chance=10, n=3})
        table.insert (lootBag, {itemType="Base.Disinfectant", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.Pills", chance=80, n=2})
        table.insert (lootBag, {itemType="Base.AlcoholWipes", chance=50, n=2})
        table.insert (lootBag, {itemType="Base.BookFirstAid1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookFirstAid2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookFirstAid3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookFirstAid4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookFirstAid5", chance=2, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Recon) then
        table.insert (lootBag, {itemType="Base.BookForaging1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookForaging2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookForaging3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookForaging4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookForaging5", chance=2, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap1", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap2", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap3", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap4", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap5", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap6", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap7", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap8", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.LouisvilleMap9", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.MarchRidgeMap", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.MuldraughMap", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.RiversideMap", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.RosewoodMap", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.WestpointMap", chance=20, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Thief) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Repairman) then
        table.insert (loot, {itemType="Base.Hammer", chance=100, n=1})
        table.insert (lootBag, {itemType="Base.Woodglue", chance=20, n=3})
        table.insert (lootBag, {itemType="Base.DuctTape", chance=20, n=3})
        table.insert (lootBag, {itemType="Base.Epoxy", chance=20, n=1})
        table.insert (lootBag, {itemType="Base.BatteryBox", chance=10, n=3})
        table.insert (lootBag, {itemType="Base.BookMaintenance1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookMaintenance2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookMaintenance3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookMaintenance4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookMaintenance5", chance=2, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Tracker) then
        local city = BanditUtils.GetCity(zombie)
        if city then
            local maps = BanditUtils.GetStashMap(city)
            for i=1, #maps do
                table.insert (lootBag, {itemType=maps[i], chance=20, n=1})
            end
        end
        table.insert (loot, {itemType="Base.Pencil", chance=100, n=1})
        table.insert (loot, {itemType="Base.Eraser", chance=20, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Trapper) then
        table.insert (lootBag, {itemType="Base.TrapCage", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.TrapSnare", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookTrapping1", chance=10, n=1})
        table.insert (lootBag, {itemType="Base.BookTrapping2", chance=8, n=1})
        table.insert (lootBag, {itemType="Base.BookTrapping3", chance=6, n=1})
        table.insert (lootBag, {itemType="Base.BookTrapping4", chance=4, n=1})
        table.insert (lootBag, {itemType="Base.BookTrapping5", chance=2, n=1})
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Traitor) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Sacrificer) then
    end

    if Bandit.HasExpertise(zombie, Bandit.Expertise.Zombiemaster) then
    end

    -- personal loot
    -- idea: add personal story letters
    local personality = brain.personality or {}
    if personality.alcoholic then
        table.insert(loot, {itemType="Base.Vodka", chance=50, n=5})
        table.insert(loot, {itemType="Base.Whiskey", chance=40, n=4})
        table.insert(loot, {itemType="Base.Gin", chance=30, n=3})
    end

    if personality.smoker then
        table.insert(loot, {itemType="Base.CigaretteSingle", chance=50, n=20})
        table.insert(loot, {itemType="Base.Lighter", chance=100, n=1})
    end

    if personality.compulsiveCleaner then
        table.insert(lootBag, {itemType="Base.Soap2", chance=50, n=20})
        table.insert(lootBag, {itemType="Base.ToiletPaper", chance=50, n=20})
    end

    if personality.comicsCollector then
        table.insert(lootBag, {itemType="Base.ComicBook", chance=50, n=30})
    end

    if personality.gameCollector then
        table.insert(lootBag, {itemType="Base.VideoGame", chance=50, n=20})
    end

    if personality.hottieCollector then
        table.insert(lootBag, {itemType="Base.HottieZ", chance=50, n=30})
    end

    if personality.toyCollector then
        table.insert(lootBag, {itemType="Base.Doll", chance=50, n=20})
    end

    if personality.underwearCollector then
        local i = 1 + ZombRand(5)
        if i == 1 then
            table.insert(lootBag, {itemType="Base.Underpants_White", chance=50, n=30})
        elseif i == 2 then
            table.insert(lootBag, {itemType="Base.Underpants_Black", chance=50, n=30})
        elseif i == 3 then
            table.insert(lootBag, {itemType="Base.FrillyUnderpants_Black", chance=50, n=30})
        elseif i == 4 then
            table.insert(lootBag, {itemType="Base.FrillyUnderpants_Pink", chance=50, n=30})
        elseif i == 5 then
            table.insert(lootBag, {itemType="Base.FrillyUnderpants_Red", chance=50, n=30})
        end
    end

    if personality.videoCollector then
    end

    if personality.fromPoland then
        table.insert(loot, {itemType="Base.Perogies", chance=50, n=30})
    end

    -- save loot
    for _, tab in pairs(loot) do
        for i=1, tab.n do
            local r = ZombRand(100)
            if tab.chance > r then
                local item = BanditCompatibility.InstanceItem(BanditCompatibility.GetLegacyItem(tab.itemType))
                item:getModData().preserve = true
                zombie:addItemToSpawnAtDeath(item)
            end
        end
    end

    -- save loot in bag
    if bag then
        for _, tab in pairs(lootBag) do
            for i=1, tab.n do
                local r = ZombRand(100)
                if tab.chance > r then
                    local item = BanditCompatibility.InstanceItem(BanditCompatibility.GetLegacyItem(tab.itemType))
                    if item then
                        bag:getInventory():AddItem(item)
                    else
                        print ("[WARN] Unknown item: " .. tab.itemType)
                    end
                end
            end
        end
    
        zombie:addItemToSpawnAtDeath(bag)
    end
    
end

function Bandit.SurpressZombieSounds(bandit)
    BanditCompatibility.SurpressZombieSounds(bandit)
end

function Bandit.PickVoice(zombie)
    local maleOptions = {"1", "2", "3", "4"} -- , "14", "16", "18", "21"}
    local femaleOptions = {"1", "2"}

    if zombie:isFemale() then
        return BanditUtils.Choice(femaleOptions)
    else
        return BanditUtils.Choice(maleOptions)
    end
end

function Bandit.Say(zombie, phrase, force)
    local brain = BanditBrain.Get(zombie)
    if not brain then return end
    
    if not force and brain.speech and brain.speech > 0 then return end
    if force then zombie:getEmitter():stopAll() end
    
    local player = getSpecificPlayer(0)
    local dist = BanditUtils.DistTo(player:getX(), player:getY(), zombie:getX(), zombie:getY())
    
    if dist <= 14 then
        local voice

        local sex = "Male"
        if zombie:isFemale() then 
            sex = "Female" 
        end

        if brain.voice then 
            voice = brain.voice
        else
            -- if voice was not assigned on spawn then preserve backward compatibility
            if zombie:isFemale() then 
                voice = 3
            else
                voice = 1 + math.abs(brain.id) % 5
                if voice > 4 then voice = 1 end
            end
        end

        local config = Bandit.SoundTab[phrase]
        if config then
            local r = ZombRand(100)
            if r < config.chance then
                local sound = config.prefix .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(config.randMax))
                local length = config.length or 2

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
                    zombie:getEmitter():playVocals(sound)
                end

                brain.speech = length

                addSound(getSpecificPlayer(0), zombie:getX(), zombie:getY(), zombie:getZ(), 5, 50)
            end
        end
    end

end

function Bandit.SayLocation(bandit, targetSquare)
    local banditSquare = bandit:getSquare()
    local targetBuilding = targetSquare:getBuilding()
    local banditBuilding = banditSquare:getBuilding()

    if targetBuilding and not banditBuilding then
        Bandit.Say(bandit, "INSIDE")
    end
    if not targetBuilding and banditBuilding then
        Bandit.Say(bandit, "OUTSIDE")
    end
    if targetBuilding and banditBuilding then
        if bandit:getZ() < targetSquare:getZ() then
            Bandit.Say(bandit, "UPSTAIRS")
        else
            local room = targetSquare:getRoom()
            if room then
                local roomName = room:getName()
                if roomName == "kitchen" then
                    Bandit.Say(bandit, "ROOM_KITCHEN")
                end
                if roomName == "bathroom" then
                    Bandit.Say(bandit, "ROOM_BATHROOM")
                end
            end
        end
    end
end

function Bandit.AddVisualDamage(bandit, handWeapon)
    
    if handWeapon then
        local itemVisual
        local weaponType = WeaponType.getWeaponType(handWeapon)
        if weaponType == WeaponType.firearm or weaponType == WeaponType.handgun then
            itemVisual = BanditUtils.Choice(Bandit.VisualDamage.Gun)
        else
            itemVisual = BanditUtils.Choice(Bandit.VisualDamage.Melee)
        end

        bandit:addVisualDamage(itemVisual)
    end
end

function Bandit.GetSkinTexture(female, idx)
    if female then
        return "FemaleBody0" .. tostring(idx)
    else
        return "MaleBody0" .. tostring(idx) .. "a"
        --return "MaleBody0" .. tostring(idx)
    end
end

function Bandit.GetHairColor(idx)
    local desc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    local hairColors = desc:getCommonHairColor()
    local tab = {}
    local info = ColorInfo.new()
    for i=1, hairColors:size() do
        local color = hairColors:get(i-1)
        info:set(color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat(), 1)
        table.insert(tab, { r=info:getR(), g=info:getG(), b=info:getB() })
    end
    return tab[idx]
end

function Bandit.GetHairStyle(female, idx)
    local hairStyles = getAllHairStyles(female)
    local tab = {}
    for i=1, hairStyles:size() do
        local styleId = hairStyles:get(i-1)
        local hairStyle = female and getHairStylesInstance():FindFemaleStyle(styleId) or getHairStylesInstance():FindMaleStyle(styleId)
        if not hairStyle:isNoChoose() then
            table.insert(tab, styleId)
        end
    end
    return tab[idx]
end

function Bandit.GetBeardStyle(female, idx)
    if female then return end
    local tab = {}
    local beardStyles = getAllBeardStyles()
    for i=1, beardStyles:size() do
        local styleId = beardStyles:get(i-1)
        table.insert(tab, styleId)
    end
    return tab[idx]
end
