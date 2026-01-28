local programVersion = "1.0"
local monitor = peripheral.find("monitor")
local monitorWidth, monitorHeight = monitor.getSize()
local basalt = require("basalt")
local mainFrame = basalt.createFrame():setTerm(monitor):setBackground(colors.black):setSize(monitor.getSize())
local subFrame = mainFrame:addFrame():setSize(monitorWidth, monitorHeight):setBackground(colors.black):setVisible(false) 

--Config
local reactorSenderID = -1 -- this will auto update when the reactor computer sends a package

monitor.clear()

-- Centers the label relative to the monitor. 
function GetLabelCenterCords(label, monitorWidth, monitorHeight)
    local labelLength = string.len(label:getText())
    local xPos = math.floor((monitorWidth - labelLength) / 2)
    local yPos = math.floor((monitorHeight) / 2)

    return xPos, yPos
end

-- Centers the Element relative to the monitor. 
function GetElementCenterCords(elementWidth, elementHeight, monitorWidth, monitorHeight)
    local xPos = math.floor((monitorWidth - elementWidth) / 2)
    local yPos = math.floor((monitorHeight- elementHeight) / 2)
    return xPos, yPos
end

-------------------------------------------------------------------------
--- Interface Error Screen
--- Errpr screen that is actiaved when connection to the reactor is lost
-------------------------------------------------------------------------
local errorFrame = mainFrame:addFrame():setBackground(colors.black):setSize(monitor.getSize()):setVisible(false)
local errorLabel = errorFrame:addLabel():setText("N/A"):setForeground(colors.red):setVisible(false)
local counterLabel = errorFrame:addLabel():setText("Trying Again"):setForeground(colors.white)

function DisplayError(ErrorMessage, isActive)

    subFrame:setVisible(false)

    errorLabel:setText(ErrorMessage)
    errorLabel:setPosition(GetLabelCenterCords(errorLabel, monitorWidth, monitorHeight)):setVisible(isActive)
    errorFrame:setVisible(isActive)
    local blinkAnim = errorLabel:animate()
        :fadeText("text", ErrorMessage, 2)
        :sequence()
        :start()
    counterLabel:setPosition(GetLabelCenterCords(counterLabel, monitorWidth, monitorHeight + 3))
end
-------------------------------------------------------------------------
--- Interface Error Screen
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Main User Interface Code
-------------------------------------------------------------------------

local reactorButton = subFrame:addButton()
    :setText("Start")
    :setBackground(colors.green)
    :alignBottom(subFrame, 0) 
    :alignRight(subFrame, 0)
    :setSize(math.ceil(monitorWidth * .3), math.ceil(monitorHeight * 0.15))
    :onClick(function(self)
        --Sends the override command to the ARC_Manager computer
        rednet.send(reactorSenderID, {type = "ReactorOverrideRequest", data = {},})

    end)

-- Frame that holds the temperature-related UI
local progressBarFrame = subFrame:addFrame():setBackground(colors.black)
progressBarFrame:setSize(monitorWidth * 0.7, monitorHeight * .8)
--:alignRight(subFrame, 0)
:centerVertical(subFrame,  math.floor(monitorHeight * (-0.05)))

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
            :setProgressColor(colors.green)
            :setBackground(colors.gray)
            :setShowPercentage(true)
            :setProgress(50)
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

local reactorInfoFrame = subFrame:addFrame()
:setBackground(colors.black)
:setSize(math.floor(monitorWidth * 0.30), math.floor(monitorHeight * 0.80))
:alignTop(progressBarFrame, 0)
reactorInfoFrame:alignRight(progressBarFrame, reactorInfoFrame:getWidth() + math.floor(monitorWidth * 0.05))

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

--Creates the warning / alarm textbox
local warningTextBox = subFrame
:addTextBox()
:setText("No current warnings"):setBackground(colors.gray)
:setSize(math.floor(monitorWidth * 0.70), math.ceil(monitorHeight * 0.15))
:alignBottom(subFrame, 0)
:setForeground(colors.red)

-------------------------------------------------------------------------
--- User Interface Code
-------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------
--- Logic Code
--- Handles the sending and retrieval of data from the linked computer
--------------------------------------------------------------------------------------------------------------------------------------------------

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
            ApplyBarColor(pairTable[index].bar, colors.green)
        end
    end
end
local currentReactorStatus -- keeps track if the reactor is active or not
local function UpdateReactorInfoFrame(newDataTable, labelTable)
    local reactorDataTable = newDataTable.reactorInfo
    for index, data in ipairs(reactorDataTable) do
        labelTable[index]:setText(data.name .. ": " .. "\n" .. data.value .. " " .. data.unit)
    end

    --Updates the reactor on / off button to match current state
    local newReactorStatus = reactorDataTable[1].boolValue --  index 1 is the hard coded status object

    if (currentReactorStatus == newReactorStatus) then
        return
    end

    if (newReactorStatus) then
        reactorButton:setBackground(colors.red)
        reactorButton:setText("SCRAM")
    else
        reactorButton:setBackground(colors.green)
        reactorButton:setText("ACTIVATE")
    end
    currentReactorStatus = newReactorStatus
end

--Updates all elements on the monitor to represent latest reactor data
local function UpdateMonitor(newDataTable, barTable, labelTable)
    UpdateBarElements(newDataTable, barTable)
    UpdateReactorInfoFrame(newDataTable, labelTable)
end

local function CheckIfModemFound()
    while true do
        if (not rednet.isOpen()) then
            DisplayError("Error, could not find modem!" , true)
            local rednetModem = peripheral.find("modem", rednet.open)
            os.sleep(1)
        else
             DisplayError("Found!", false)
            subFrame:setVisible(true)
        end
    os.sleep(1)
    end
end

local function UpdateWarningTextBox(warningData)
    for _, line in ipairs(warningData) do
        warningTextBox:setText(line .. "\n")
    end
end

local function TriggerAlarm()
    redstone.setOutput("left", true)
end

local function DisableAlarm()
    redstone.setOutput("left", false)
end

local function ListenForPackage()
    local pairTable = CreateProgressBars() -- contains progressBars objects
    local reactorInfoLabelTable = CreateReactorInfoLabels() -- Holds all the labels for the reactor info frame
    while true do
        local senderID, message, protocol = rednet.receive()
        if type(message) == "table" and message.type == "reactorData" then
            UpdateMonitor(message.data, pairTable, reactorInfoLabelTable)
            reactorSenderID = senderID
        end

        if type(message) == "table" and message.type == "warningData" then
            UpdateWarningTextBox(message.data)
            if (#message.data > 0) then
                TriggerAlarm()
                subFrame:setBackground(colors.red)
            else
                DisableAlarm()
                warningTextBox:setText("No issues.")
                subFrame:setBackground(colors.black)
            end
            reactorSenderID = senderID
        end
        os.sleep(0.1)
    end
end

local rednetModem = peripheral.find("modem", rednet.open)
-- Main Loop that will update monitor states from the reactor computer via rednet
local function InitalizeMonitoringSystem()

    parallel.waitForAny(ListenForPackage, CheckIfModemFound)
end
--------------------------------------------------------------------------------------------------------------------------------------------------
--- Logic Code
--------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------
--- Interface Startup Screen
--------------------------------------------------------------------------------------------------------------------------------------------------
local startupFrame = mainFrame:addFrame():setBackground(colors.black):setSize(monitor.getSize())
local displayLabel = startupFrame
    :addBigFont()
    :setFontSize(1)
    :setSize(45,5)
    :setBackground(colors.black)
    :setForeground(colors.green)
    displayLabel:setPosition(GetLabelCenterCords(displayLabel, monitorWidth - 35, monitorHeight))

local anim = displayLabel:animate():typewrite("text", "ARC Version " .. programVersion, 2)
anim:start()

anim:onComplete(function ()
    os.sleep(1)
    displayLabel:setSize(100,5)
    displayLabel:setText("Basalt Framework")
    displayLabel:setPosition(GetLabelCenterCords(displayLabel, monitorWidth - 30, monitorHeight))

    local blinkAnim = displayLabel:animate()
    :fadeText("text", "Basalt Framework", 2)
    :sequence()
    :fadeText("text", "Standby", 2)
    :sequence()
    :fadeText("text", "Standby", 2)
    :start()

    blinkAnim:onComplete(function ()
        startupFrame:setVisible(false)
        subFrame:setVisible(true)
        InitalizeMonitoringSystem()
    end)
end)
-------------------------------------------------------------------------
--- Interface Startup
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Terminal Startup Screen
-------------------------------------------------------------------------
term.clear()
print("ARC Version " .. programVersion)
print("Powered by Basalt UI Framework")
-------------------------------------------------------------------------
--- Terminal Startup Screen
-------------------------------------------------------------------------
basalt.run()