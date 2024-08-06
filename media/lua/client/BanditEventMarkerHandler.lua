BanditEventMarkerHandler = {}
BanditEventMarkerHandler.markers = {} --[player] = {["id"]=marker}
BanditEventMarkerHandler.expirations = {} --[player] = {["id]=time}
--set
--updatePos
--unSet
--OnPlayerUpdate

function BanditEventMarkerHandler.setOrUpdate(eventID, icon, duration, posX, posY, color)

    --print("eventMarker: eventID:"..tostring(eventID).." icon:"..tostring(icon).." duration:"..tostring(duration).." posX:"..tostring(posX).." posY:"..tostring(posY).." override:"..tostring(override))

    for p=1, getNumActivePlayers() do
        local player = getSpecificPlayer(p-1)
        if player then

            --print(" - player:"..player:getUsername())
            BanditEventMarkerHandler.markers[player] = BanditEventMarkerHandler.markers[player] or {}
            BanditEventMarkerHandler.expirations[player] = BanditEventMarkerHandler.expirations[player] or {}

            local marker = BanditEventMarkerHandler.markers[player][eventID]
            BanditEventMarkerHandler.expirations[player][eventID] = getGametimeTimestamp()+duration

            if not marker and duration>0 then

                if BanditEventMarker then

                    local dist = IsoUtils.DistanceTo(posX, posY, player:getX(), player:getY())
                    if dist and (dist <= BanditEventMarker.maxRange) then
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

                        marker = BanditEventMarker:new(eventID, icon, duration, posX, posY, player, screenX, screenY, color)
                        BanditEventMarkerHandler.markers[player][eventID] = marker
                    else
                        --print("-- dist not valid: "..tostring(dist))
                    end
                else
                    --print("EHE: ERR: BanditEventMarker not found: ".." isClient:"..tostring(isClient()).." isServer:"..tostring(isServer()) )
                end
            end

            if marker then
                --print(" --- marker given duration")
                marker.textureIcon = getTexture(icon)
                marker:setDuration(duration)
                marker:update(posX,posY)
            end
        end
    end

end
