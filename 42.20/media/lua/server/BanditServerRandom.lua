local everyOneMinute = function()
    if isServer() then 
        local newIterator = ZombRand(10001)
        sendServerCommand('BanditRandom', 'IteratorChangeReveiver', {iterator=newIterator})
    end
end

Events.EveryOneMinute.Add(everyOneMinute)
