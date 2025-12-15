BanditTest = {}
BanditTest.Check = function()
    local problems = {}
    local txt = ""
    -- begin tests

    -- sound test
    local volume = getSoundManager():getSoundVolume()
    if volume < 0.8 then
        table.insert(problems, "Sound volume is too low. As a result, mod sounds will be too loud compared to original game sounds. Consider rising sound volume to 90% or 100% and then decrease your operating system volume to compensate.")
    end

    -- square access test
    --[[
    local cell = getCell()
    local player = getSpecificPlayer(0)
    local sqs = {
        {x=-70, y=-70},
        {x=-70, y=70},
        {x=70, y=70},
        {x=70, y=-70}
    }
    for k, coords in pairs(sqs) do
        local square = cell:getGridSquare(player:getX() + coords.x, player:getY() + coords.y, 0)
        if not square then
            table.insert(problems, "There is no access to a places located 70 squares away from player. As a result, bandits spawning may not occur and other features might also be affected. This may be inflicted by other mods such as betterFPS that limit access to distant squares. ")
            break
        end
    end]]

    -- disabled zombies
    --[[
    local pop = SandboxVars.ZombieConfig.PopulationStartMultiplier
    if pop < 0.2 then
        table.insert(problems, "Zombie population is too low. As a result bandits will not spawn. You will need to raise the value to make bandits work.")
    end]]
    
    -- UI refresh rate
    if getCore():getOptionUIRenderFPS() < 60 then
        -- getCore():setOptionUIRenderFPS(120)
        getCore():setOptionUIRenderFPS(60)
        table.insert(problems, "UI rendering FPS was too low and was changed to 60. This way the visual effects will run with the proper timing and smoothness.")
    end
    
    -- report problems
    if #problems > 0 then
        txt = txt .. "<SIZE:medium> <RGB:0.8,0.8,0.8> Bandit Automated Tests Results <LINE> <LINE>"
        for i=1, #problems do
            local problem = problems[i]
            txt = txt .. "<SIZE:medium> <RGB:0.8,0.8,0.0> " .. i .. ". " .. problem .. " <LINE> <LINE> "
        end

        local windowSize = 600+(getCore():getOptionFontSizeReal() * 100)
        local animPopup = ISModalRichText:new((getCore():getScreenWidth()-windowSize)/2,getCore():getScreenHeight() / 2 - 300, windowSize, 600, txt, false, nil)
        animPopup:initialise()
        animPopup.backgroundColor = {r=0, g=0, b=0, a=0.9}
        animPopup.alwaysOnTop = true
        animPopup.chatText:paginate()
        animPopup:setY(getCore():getScreenHeight()/2-(animPopup:getHeight()/2))
        animPopup:setVisible(true)
        animPopup:addToUIManager()
    end
        
        --[[
        UI_News_Anim3 = UI_News_Anim3 = "<LINE> <LINE> <H1> Support the Modders Who Keep Project Zomboid Alive! <LINE> <TEXT> <LINE> <LINE> <LINE>" ..
                    "<SIZE:large> <RGB:0.8,0.8,0.0> Project Zomboid thrives thanks to its incredible modding community, with some of the creators spending hundreds — if not thousands — of personal life hours crafting various experiences for you. Yet, despite their efforts, there's no system ensuring sustainable profits for them. <LINE><LINE> " ..
                    "<SIZE:large> <RGB:0.8,0.8,0.0> If you've enjoyed these mods and want to see them continue to evolve, consider supporting the authors directly through donations on their mod pages on Steam. Every contribution helps them keep creating and improving the content that makes PZ even better. <LINE><LINE>" ..
                    "<SIZE:large> <RGB:0.8,0.8,0.0> Week One and Bandit required tremendous time, dedication, and patience to develop. If you enjoy these mods, don’t forget to leave a Like on my mod pages, it’s a simple way to show appreciation! <LINE><LINE>" .. 
                    "<CENTRE> <SIZE:large> <RGB:0.8,0.8,0.8> Slayer <LINE><LINE> ",

    local txt = " This i s a test\nttt"
    ]]
    

end

Events.OnGameStart.Add(BanditTest.Check)