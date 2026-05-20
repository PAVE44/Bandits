require "TimedActions/ISInventoryTransferAction"

local transferItem = ISInventoryTransferAction.transferItem

function ISInventoryTransferAction:transferItem(item)
    transferItem(self, item)
	triggerEvent("OnTransferItem", self, item)
end
