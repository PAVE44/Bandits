ZombieActions = ZombieActions or {}

ZombieActions.Zombify = {}
ZombieActions.Zombify.onStart = function(zombie, task)
    zombie:clearAttachedItems()
    return true
end

ZombieActions.Zombify.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Zombify.onComplete = function(zombie, task)
    zombie:changeState(ZombieOnGroundState.instance())
    local id = BanditUtils.GetCharacterID(zombie)
    local args = {}
    args.id = id
    if isClient() then
        sendClientCommand(getSpecificPlayer(0), 'Commands', 'BanditRemove', args)
    else
        BanditServer.Commands.BanditRemove(getSpecificPlayer(0), args)
    end
    return true
end