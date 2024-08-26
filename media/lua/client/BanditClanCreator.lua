-- CustomizationUI class definition
CustomizationUI = ISPanel:derive("CustomizationUI")

-- Constructor for the CustomizationUI
function CustomizationUI:new(x, y, width, height)
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.7}  -- Darker, semi-transparent background
    o.borderColor = {r=1, g=1, b=1, a=1}  -- White border
    o:initialise()
    return o
end

-- Initialise method, called once during creation
function CustomizationUI:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function CustomizationUI:createChildren()
    print("createChildren: Start")

    local padding = 10
    local labelWidth = 120
    local controlWidth = 200
    local controlHeight = 25
    local startY = 10

    -- Model Preview Panel (left side)
    local playerObj = getPlayer()
    if not playerObj then
        print("Error: playerObj is nil")
        return
    end

    local kahluaTable = {}
    self.modelPreview = UI3DModel:new(kahluaTable)
    if not self.modelPreview then
        print("Error: modelPreview is nil after creation")
        return
    end

    -- Set up the modelPreview
    self.modelPreview:setCharacter(playerObj)
    self.modelPreview:setZoom(1.0)
    self.modelPreview:setIsometric(true) -- Set to true for isometric view, false otherwise
    self.modelPreview:setXOffset(0)
    self.modelPreview:setYOffset(0)

    -- Position where the 3D model should be rendered
    self.modelPreviewX = padding
    self.modelPreviewY = startY

    -- UI Elements on the right
    local startX = padding + controlWidth + padding

    -- Gender Section (optional)
    startY = self:addLabelAndDropdown(startX, startY, labelWidth, controlHeight, "Gender:", {"Male", "Female"}, 1, function(option)
        self.isFemale = (option == "Female")
        self:populateOutfitDropdown(self.isFemale)
    end)

    -- Outfit Section
    startY = startY + controlHeight + padding

    -- Create the outfit dropdown and assign it to self.outfitDropdown
    self.outfitDropdown = ISComboBox:new(startX + labelWidth, startY, 150, controlHeight, self, nil)
    if not self.outfitDropdown then
        print("Error: outfitDropdown is nil after creation")
    else
        self.outfitDropdown:initialise()
        self:addChild(self.outfitDropdown)
    end

    -- Populate the outfit dropdown initially
    self:populateOutfitDropdown(false) -- Assuming Male by default

    print("createChildren: End")
end

-- Helper method to add a label and a dropdown with an event listener
function CustomizationUI:addLabelAndDropdown(x, y, labelWidth, height, labelText, options, selectedIndex, onChange)
    local label = ISLabel:new(x, y, height, labelText, 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(label)
    local dropdown = ISComboBox:new(x + labelWidth, y, 150, height, self, nil)
    dropdown:initialise()
    for i, option in ipairs(options) do
        dropdown:addOption(option)
    end
    dropdown.selected = selectedIndex
    dropdown.onChange = function()
        onChange(dropdown:getSelectedText())
    end
    self:addChild(dropdown)
    return y + height + 10
end

-- Method to populate the outfit dropdown with all available outfits
function CustomizationUI:populateOutfitDropdown(isFemale)
    -- Ensure outfitDropdown is properly initialized
    if not self.outfitDropdown then
        print("Error: outfitDropdown is nil, cannot populate")
        return
    end

    -- Attempt to get the list of outfits
    local outfits = getAllOutfits(isFemale)
    
    -- Check if outfits is nil or not a table
    if not outfits or type(outfits) ~= "table" then
        print("Error: getAllOutfits returned nil or is not a table")
        return
    end
    
    -- Clear the dropdown before populating it
    self.outfitDropdown:clear()

    -- Populate the dropdown with outfit names
    for i = 1, #outfits do
        local outfitName = outfits[i]
        self.outfitDropdown:addOption(outfitName)
    end

    -- Set the first outfit as the default selection if available
    if #outfits > 0 then
        self.outfitDropdown.selected = 1
        self:updateModelOutfit(outfits[1])
    end
end

-- Method to update the model preview based on the selected outfit
function CustomizationUI:updateModelOutfit(outfitName)
    self.modelPreview:setOutfitName(outfitName, self.isFemale or false, false)
    self.modelPreview:render()
end

-- Override the render method to directly render the modelPreview
function CustomizationUI:render()
    ISPanel.render(self) -- Render the panel and its children

    -- Directly render the modelPreview
    if self.modelPreview then
        local x = self:getAbsoluteX() + self.modelPreviewX
        local y = self:getAbsoluteY() + self.modelPreviewY
        self.modelPreview:setX(x)
        self.modelPreview:setY(y)
        self.modelPreview:render()
    else
        print("Error: modelPreview is nil in render")
    end
end

-- Function to show the Customization UI
function ShowCustomizationUI()
    local ui = CustomizationUI:new(100, 100, 600, 700) -- Adjust dimensions
    ui:initialise()
    ui:addToUIManager()
end

-- Hook into the game's start event to show the customization UI
--Events.OnGameStart.Add(ShowCustomizationUI)
