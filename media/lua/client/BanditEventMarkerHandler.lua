BanditEventMarkerHandler = {}
BanditEventMarkerHandler.markers = {}

function BanditEventMarkerHandler.setOrUpdate(eventID, icon, duration, posX, posY, color, desc)

    local player = getSpecificPlayer(0)
    local marker = BanditEventMarkerHandler.markers[eventID]

    if not marker and duration > 0 then
        local dist = BanditUtils.DistTo(posX, posY, player:getX(), player:getY())
        if dist <= BanditEventMarker.maxRange then
            --print(" -- not marker: generating")
            local oldX
            local oldY
            local pModData = player:getModData()["BanditEventMarkerPlacement"]
            if pModData then
                oldX = pModData[1]
                oldY = pModData[2]
            end
            local screenX = oldX or (getCore():getScreenWidth()/2) - (BanditEventMarker.iconSize/2)
            local screenY = oldY or (BanditEventMarker.iconSize/2)
            --print("BanditEventMarkerHandler: generateNewMarker: "..p:getUsername().." ".."("..screenX..","..screenY..")")

            marker = BanditEventMarker:new(eventID, icon, duration, posX, posY, player, screenX, screenY, color, desc)
            BanditEventMarkerHandler.markers[eventID] = marker
        end
    end

    if marker then
        --print(" --- marker given duration")
        marker.textureIcon = getTexture(icon)
        marker:setDuration(duration)
        marker:update(posX, posY)
    end

end

function BanditEventMarkerHandler.RemoveOldMarkers ()
    local markers = BanditEventMarkerHandler.markers
    for eventId, marker in pairs(markers) do
        if marker.start + marker.duration < getGametimeTimestamp() then

            marker:setDuration(0)
            BanditEventMarkerHandler.markers[eventId] = nil
        end
    end
end

Events.EveryTenMinutes.Add(BanditEventMarkerHandler.RemoveOldMarkers)