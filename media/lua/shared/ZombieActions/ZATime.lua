ZombieActions = ZombieActions or {}

ZombieActions.Time = {}
ZombieActions.Time.onStart = function(zombie, task)
    return true
end

ZombieActions.Time.onWorking = function(zombie, task)
    local asn = zombie:getActionStateName()
    if asn == "bumped" then
        return false
    else
        return true
    end
end

ZombieActions.Time.onComplete = function(zombie, task)
    return true
end