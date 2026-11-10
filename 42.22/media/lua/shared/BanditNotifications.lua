BanditNotifications = BanditNotifications or {}

BanditNotifications.EVENT_TOGGLE_DOOR = "OnBanditDoorToggled"
LuaEventManager.AddEvent(BanditNotifications.EVENT_TOGGLE_DOOR)

BanditNotifications.DoorToggled = function(bandit, object, open)
    if not bandit or not object then return end

    local square = object:getSquare()
    if not square then return end

    local info = {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
        idx = object:getObjectIndex(),
        open = open == true,
    }

    LuaEventManager.triggerEvent(BanditNotifications.EVENT_TOGGLE_DOOR, bandit, object, info)
end