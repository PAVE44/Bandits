require "TimedActions/ISBaseTimedAction"

-- this intercepts all player actions and sends an event when they are performed

local perform = ISBaseTimedAction.perform

function ISBaseTimedAction:perform()
    perform(self)
	triggerEvent("OnTimedActionPerform", self)
end
