BanditPatches = BanditPatches or {}

local function OnZombieUpdate(zombie)
	if not SandboxVars.TrueCrawl.StealhModeEnable == true then return end
	if not SandboxVars.TrueCrawl.StealhModeServer == false then return end
    
    -- this line prevents TrueCrawl modification of useless status for bandits.
    if zombie:getVariableBoolean("Bandit") then return end

	if SandboxVars.TrueCrawl.StealhModeEnable == true then
		if SandboxVars.TrueCrawl.StealhModeServer == false then
			if TC_Stealth == true then 
			    zombie:setUseless(true)
			elseif TC_Stealth == false then
			    zombie:setUseless(false)
			end
		end
	end
end

BanditPatches.TrueCrawl = function()

    if getActivatedMods():contains("TrueCrawl") then

        SandboxVars.TrueCrawl.StealhModeEnable = false

        --[[local old_add = Events.OnZombieUpdate.Add
        Events.OnZombieUpdate.Add = function(func)
            -- does nothing but resets the function to the original
            -- print ("THIS METHOD WAS PATCHED")
        end

        require "TC_SinglePlayer"

        Events.OnZombieUpdate.Add = old_add
        Events.OnZombieUpdate.Add(OnZombieUpdate)]]
        print ("TrueCrawl patched successfully!")
    end
end

Events.OnGameStart.Add(BanditPatches.TrueCrawl)

