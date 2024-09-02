ZombieActions = ZombieActions or {}

ZombieActions.Zombify = {}
ZombieActions.Zombify.onStart = function(zombie, task)
    zombie:clearAttachedItems()
    return true
end

ZombieActions.Zombify.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Zombify.onComplete = function(zombie, task)
    zombie:changeState(ZombieOnGroundState.instance())
    local id = BanditUtils.GetCharacterID(zombie)
    local args = {}
    args.id = id
    sendClientCommand(getPlayer(), 'Commands', 'BanditRemove', args)
    return true
end