--[[
@author Nooble12 | https://github.com/Nooble12
@repo https://github.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-
A simple installer program for Adaptive Reactor Control (ARC).

@credits Uses Basalt2 UI framework | https://github.com/Pyroxenium/Basalt2
]]


local reactorSenderID

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local main = basalt.getMainFrame():setBackground(colors.black)

-- Contains all of the reactor data. Child of main frame.
local interfaceFrame = main:addFrame()
:setSize(main:getWidth(), main:getHeight())
:setBackground(colors.gray)
:center():setVisible(true)

local tabControl = main:addTabControl({
width = interfaceFrame:getWidth(),
height = interfaceFrame:getHeight(),
}):setBackground(colors.gray)

-- Main Tab --
local mainTab = tabControl:newTab("Reactor")
local mainTabFrame = mainTab:addFrame():setSize(mainTab:getSize()):setBackground(colors.green)

local progressBarFrame = mainTabFrame:addFrame({
    background = colors.gray,
    width = mainTabFrame:getWidth(),
    height = math.floor(mainTabFrame:getHeight() * 8/10),
})

local warningTextBox = mainTabFrame:addTextBox({
    background = colors.black,
    foreground = colors.red,
    width = mainTabFrame:getWidth(),
    height = math.floor(mainTabFrame:getHeight() * 2/10),
    editable = false
}):alignBottom(mainTabFrame,0):setText("No current issues.")
-- Main Tab -- 

-- Reactor Override Tab --
local overrideTab = tabControl:newTab("Controls")

local reactorControlButton = overrideTab:addButton({
text = "ACTIVATE",
foreground = colors.white,
background = colors.green,
width = overrideTab:getWidth(),
height = math.floor(overrideTab:getHeight() * 1/2)
}):center()

local nextClickTime = 0 -- second
local clickCoolDown = 3 -- second
reactorControlButton:onClick(function ()

    if (reactorSenderID == nil) then
        return
    end
    
    local currentTime = os.clock()

    if (currentTime < nextClickTime) then
        return
    end
    nextClickTime = currentTime + clickCoolDown

    reactorControlButton:setText("Sending Request...")
    rednet.send(reactorSenderID, {type = "ReactorOverrideRequest", data = {},})
end)

-- Reactor Override Tab --

-- Reactor Info Tab --
local infoTab = tabControl:newTab("Info")
local infoTabFrame = infoTab:addFrame({
    background = colors.gray,
    width = infoTab:getWidth(),
    height = infoTab:getHeight(),
})

local computerInfoFrame = infoTabFrame:addFrame({
    background = colors.black,
    width = infoTabFrame:getWidth(),
    height = math.floor(infoTabFrame:getHeight() * 2/10)
})

local computerIDLabel = computerInfoFrame:addLabel({
    foreground = colors.green,
    width = infoTabFrame:getWidth(),
    height = math.floor(infoTabFrame:getHeight() * 5/10)
}):setText("Computer ID: " .. os.getComputerID())

local reactorInfoFrame = infoTabFrame:addFrame({
    background = colors.black,
    width = infoTabFrame:getWidth(),
    height = math.floor(infoTabFrame:getHeight() * 8/10)
}):below(computerInfoFrame, 0)
-- Reactor Info Tab --

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
--- Logic Code
------------------------------------------------------------------------------------------------------------------
rednet.open("back") 

--[[
Centers the label relative to the dimensions of a frame. Accounts for label length.
@param inLabel The input label to be centered.
@param inFrame The frame which the label will be centered to.
@return The x and y positions
]] 
function GetLabelCenterCords(inLabel, inFrame)
    local labelLength = string.len(inLabel:getText())
    local xPos = math.floor((inFrame:getWidth() - labelLength) / 2)
    local yPos = math.floor((inFrame:getHeight()) / 2)

    return xPos, yPos
end

local function UpdateWarningTextBox(warningData)
    for _, line in ipairs(warningData) do
        warningTextBox:setText(line .. "\n")
    end
end

local function ApplyBarColor(bar, newColor) 
    local currentBarColor = bar:getProgressColor()

    if (currentBarColor == newColor) then
        return
    end
    bar:setProgressColor(newColor)
end

local function UpdateBarElements(reactorDataTable, pairTable)
    local barData = reactorDataTable.barData

    for index, bar in ipairs(barData) do
        pairTable[index].label:setText(bar.labelText)
        pairTable[index].bar:setProgress(bar.value)

        if (bar.value >= bar.threshold[1] and bar.value <= bar.threshold[2]) then
            ApplyBarColor(pairTable[index].bar, colors.red)
        else
            -- Alternates to better highlight bars
            if (index %2 ~= 0) then
                ApplyBarColor(pairTable[index].bar, colors.green)
            else
                ApplyBarColor(pairTable[index].bar, colors.lime)
            end
        end
    end
end

local function HasTableChanged(newDataTable, currentDataTable)
    if newDataTable == currentDataTable then
        return false
    end

    if type(newDataTable) ~= "table" or type(currentDataTable) ~= "table" then
        return true
    end

    for key, value in pairs(newDataTable) do
        if currentDataTable[key] == nil or HasTableChanged(value, currentDataTable[key]) then
            return true
        end
    end

    for k, _ in pairs(currentDataTable) do
        if newDataTable[k] == nil then
            return true
        end
    end

    return false
end

local currentReactorInfoTable = {}
local function UpdateReactorInfoFrame(newDataTable, labelTable)
    local reactorDataTable = newDataTable.reactorInfo

    if (not HasTableChanged(reactorDataTable, currentReactorInfoTable)) then
        return
    end

    for index, data in ipairs(reactorDataTable) do
        labelTable[index]:setText(data.name .. ": " .. data.value .. " " .. data.unit .. "\n")
    end

    currentReactorInfoTable = reactorDataTable
end

--[[
Updates the SCRAM/ACTIVATE reactor button and updates the reactor status
@param The new reactor table table
]]
local currentReactorStatus -- keeps track if the reactor is active or not
local function UpdateReactorButton(reactorDataTable)
--Updates the reactor on / off button to match current state
    local newReactorStatus = reactorDataTable.reactorInfo[1].boolValue--  index 1 is the hard coded status object

    if (currentReactorStatus == newReactorStatus) then
        return
    end

    if (newReactorStatus) then
        reactorControlButton:setBackground(colors.red)
        reactorControlButton:setText("SCRAM")
    else
        reactorControlButton:setBackground(colors.green)
        reactorControlButton:setText("ACTIVATE")
    end
    currentReactorStatus = newReactorStatus
end

--Updates all elements on the monitor to represent latest reactor data
local function UpdateMonitor(newDataTable, barTable, labelTable)
    UpdateBarElements(newDataTable, barTable)
    UpdateReactorButton(newDataTable)
    UpdateReactorInfoFrame(newDataTable, labelTable)
end

--Creates all the textboxes (6)
local function CreateReactorInfoLabels()
    local labelCount = 6
    local labelH = math.ceil(reactorInfoFrame:getHeight() / labelCount - 1) 
    local labelTable = {}
    for i = 1, labelCount do
        local label = reactorInfoFrame:addTextBox():setText("N/A")
        :setForeground(colors.white)
        :setSize(reactorInfoFrame:getWidth(),  labelH)
        :setEditable(false)
        :setBackground(colors.black)
        table.insert(labelTable, label)
    end

    for i = 2, #labelTable do
        labelTable[i]:alignBottom(labelTable[i-1], labelH)
    end

    return labelTable
end

-- Creates a progress bar and places it next to another bar with spacing
local function CreateProgressBars()

    local barCount = 5
    local frameW = progressBarFrame:getWidth()
    local frameH = progressBarFrame:getHeight()

    local totalSpacing = frameW * 0.1
    local spacing = totalSpacing / (barCount - 1)
    local barW = math.floor(frameW / 5) 
    local barH = math.ceil(frameH / barCount - 1) 


    local barTable = {}
    local labelTable ={}

    for i = 1, barCount do
        local progressBar = progressBarFrame:addProgressBar()
        progressBar
            :setDirection("right")
            :setSize(frameW, barH)
            :setShowPercentage(true)
            :setProgress(50)
            :setBackground(colors.gray)
            :setProgressColor(colors.green)
        table.insert(barTable, progressBar)
    end

    --Positions the bars side by side 
    for i = 2, barCount do
        barTable[i]:alignBottom(barTable[i-1], barH)
    end

    --Creates the labels
    for i = 1, barCount do
        local label = progressBarFrame:addLabel()
        label
            :setSize(frameW, barH)
            :setForeground(colors.white)
            :setText("N/A")
            table.insert(labelTable, label)
    end

     --Positions the labels side by side 
    for i = 1, barCount do
        labelTable[i]:alignTop(barTable[i])
    end

    -- Creates a bar to label pair. Ex -> {label1, bar1}
    local pairTable = {}
    for i = 1, barCount do
        pairTable[i] = {label = labelTable[i], bar = barTable[i]}
    end

    return pairTable
end

--[[
Listens for packages from the Manager Computer. 
On package receive, run UpdateMonitor function.
]]
local function ListenForPackage()

    local pairTable = CreateProgressBars() -- contains progressBars objects
    local reactorInfoLabelTable = CreateReactorInfoLabels() -- Holds all the labels for the reactor info frame

    while true do
        local senderID, message, protocol = rednet.receive()
        if type(message) == "table" and message.type == "reactorData" then
            UpdateMonitor(message.reactorData, pairTable, reactorInfoLabelTable)
            reactorSenderID = senderID

            if (#message.warningData > 0) then
                UpdateWarningTextBox(message.warningData)
            else
                warningTextBox:setText("No issues.")
            end
        end

        if type(message) == "table" and message.type == "overrideResponse" then
            reactorControlButton:setText(message.message)
        end

        os.sleep(0.1)
    end
end

--[[
Starts the monitoring code. 
Runs ListenForPackage and ListenForOverrideReponse functions in parallel.
]]
local function InitalizeMonitoringSystem()
    ListenForPackage()
end

------------------------------------------------------------------------------------------------------------------
--- Logic Code
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
--- Startup Screen
------------------------------------------------------------------------------------------------------------------
os.sleep(0.5) -- Fixes black screen issue on startup for first time.

local startUpFrame = main:addFrame()
:setBackground(colors.black):
setSize(main:getWidth(), main:getHeight())

local startUpLabel = startUpFrame:addLabel()
:setForeground(colors.green)
:setText("ARC Mobile")
startUpLabel:setPosition(GetLabelCenterCords(startUpLabel, startUpFrame))
startUpLabel:setSize(100,5)
startUpLabel:setText("")

local blinkAnim = startUpLabel:animate()
:fadeText("text", "ARC Mobile", 2)
:start()

blinkAnim:onComplete(function ()
    startUpFrame:setVisible(false)
    interfaceFrame:setVisible(true)
    InitalizeMonitoringSystem()
end)

------------------------------------------------------------------------------------------------------------------
--- Startup Screen
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------

basalt.run();