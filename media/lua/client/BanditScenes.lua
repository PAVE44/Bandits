BanditScenes = BanditScenes or {}

function BanditScenes.BuildDefaultScenes(restore)
    local gmd = GetBanditModData()
    local scenes = gmd.Scenes

    if not scenes.ArmyCheckPoint then
        local scene = {}
        scene.x = 14533
        scene.y = 4017
        scene.z = 0
        scene.bandits = {}
    end

    -- westpoint gun shop
    if not scenes.WestpointGunShop then
        local scene = {}
        scene.x = 12068
        scene.y = 6761
        scene.z = 0
        scene.bandits = {}
    end

end