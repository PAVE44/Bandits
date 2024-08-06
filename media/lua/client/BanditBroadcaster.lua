BanditBroadcaster = BanditBroadcaster or {}

BanditBroadcaster.Messages = {}

BanditBroadcaster.AddBroadcast = function(message)
    table.insert(BanditBroadcaster.Messages, message)
end

BanditBroadcaster.tick = 0

BanditBroadcaster.BroadCast = function()
    if #BanditBroadcaster.Messages == 0 then return end
    -- clearTvScreenSprites()

    if BanditBroadcaster.tick == 0 then   
        local world = getWorld()
        local message = BanditBroadcaster.Messages[1]
        for _, object in pairs(message.tvs) do
            if instanceof(object, "IsoTelevision") then
                if message.text == "END" then
                    object:setOverlaySprite(nil)
                else
                    local dd = object:getDeviceData()
                    if dd:getIsTurnedOn() and object:getX() and object:getY() and object:getZ() then
                        dd:StopPlayMedia()
                        dd:setDeviceVolume(0.01)

                        -- object:clearTvScreenSprites()
                        -- object:setOverlaySprite("appliances_television_01_20")
                        object:Say(message.text)

                        if message.sound then
                            local emitter = world:getFreeEmitter(object:getX(), object:getY(), object:getZ())
                            emitter:setVolumeAll(0.2)
                            emitter:playSound(message.sound)
                            -- dd:playSound(message.sound, 1, true)
                        end
                    end
                end
            end
        end
        table.remove(BanditBroadcaster.Messages, 1)
    end

    BanditBroadcaster.tick = BanditBroadcaster.tick + 1

    if BanditBroadcaster.tick == 3 then
        BanditBroadcaster.tick = 0
    end
end


Events.EveryOneMinute.Add(BanditBroadcaster.BroadCast)
