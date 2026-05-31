--[[
@author Nooble12 | https://github.com/Nooble12
@repo https://github.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-
A simple installer program for Adaptive Reactor Control (ARC).

@credits Uses Basalt2 UI framework | https://github.com/Pyroxenium/Basalt2
]]

local version = "1.0.0"

if not (fs.exists("basalt.lua")) then
    shell.run("wget", "https://raw.githubusercontent.com/Pyroxenium/Basalt2/refs/heads/main/release/basalt-full.lua", "basalt.lua")

    if (fs.exists("basalt.lua")) then
        print("\n Basalt installed. Loading ARC_Installer.")
    else
        print("Error, could not install Basalt. Try Again.")
        return
    end
end

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local main = basalt.getMainFrame():setBackground(colors.black) -- main width is 60, height is 30
local subFrame = main:addFrame():setBackground(colors.gray):setSize(main:getWidth(), main:getHeight()):alignRight(main,0)
local scrollFrame = subFrame:addScrollFrame():setBackground(colors.gray):setSize(main:getWidth() / 2, main:getHeight()):alignLeft(subFrame, 0)

-- Info Frame UI
-- The frame on the right side that contains the file name, info, and install button.
local infoFrame = subFrame:addFrame():setBackground(colors.gray):alignRight(subFrame, 0):setSize(main:getWidth() / 2, main:getHeight())
local infoScrollFrame = infoFrame:addScrollFrame():alignTop(infoFrame, 0):setSize(math.floor(infoFrame:getWidth()), math.floor(infoFrame:getHeight() * (5/6))):setBackground(colors.gray)

local fileNameLabel = infoScrollFrame:addLabel()
:setSize((math.floor(infoScrollFrame:getWidth() * (11/12))), math.floor(infoScrollFrame:getHeight() / 6))
:setText("Select a file.")
:setForeground(colors.white)
:alignTop(infoScrollFrame, math.floor(infoScrollFrame:getHeight() / 12))
:alignLeft(infoScrollFrame, math.floor(infoScrollFrame:getWidth() * (1/12)))

local fileDescLabel = infoScrollFrame
:addLabel()
:setSize(math.floor(infoScrollFrame:getWidth() * (11/12)), math.floor(infoScrollFrame:getHeight() * (11/12)))
:setForeground(colors.white)
:setAutoSize(false)
:alignBottom(fileNameLabel, math.floor(infoScrollFrame:getHeight() * (1/12)))
:alignLeft(infoScrollFrame, math.floor(infoScrollFrame:getWidth() * (1/12)))
fileDescLabel:setText("")

local installButton = infoFrame:addButton():setBackground(colors.green):setSize(infoFrame:getWidth(), math.floor(infoFrame:getHeight() / 6)):setText("Install"):alignBottom(infoFrame, 0):setVisible(false)
-- Info Frame UI

-- Install UI
local installFrame = main:addFrame():setBackground(colors.blue):setSize(main:getWidth(), main:getHeight()):setVisible(false)
local exitInstallMenuButton = installFrame:addButton()
:setBackground(colors.green)
:setSize(math.floor(installFrame:getWidth() / 4), math.floor(installFrame:getHeight() / 6))
:alignLeft(installFrame, 0)
:alignBottom(installFrame, 0)
:setText("Exit"):setPosition(0,15)

local installLabel = installFrame:addLabel():setForeground(colors.white):setAutoSize(false):setSize(math.floor(installFrame:getWidth()), installFrame:getHeight() / 10 )
installLabel:setText("")
-- Install UI

main:addLabel()
    :setText("ARC Installer Version " .. version)
    :alignTop(main, 0)
    :setForeground(colors.white)

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
--- Logic
------------------------------------------------------------------------------------------------------------------

local fileTable = 
{
    {
        name = "ARC Manager",
        description = "Controls the Fission reactor. \n\n Sends out packages to monitor computers. \n\n Attached to logic adapter.",
        link = "https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/src/ARC_Manager.lua"
    },

    {
        name  = "ARC Monitor",
        description = "Displays data from Manager computer to attached monitors\n\nMekanism alarm can be attached to the left side\n\n",
        link = "https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/src/ARC_Monitor.lua"
    },

    {
        name  = "ARC Mobile",
        description = "A mobile version for ARC",
        link = "https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/src/ARC_Mobile.lua"
    },
}

local buttonTable = {}

local selectedFile = nil

local function UpdateSubFrame()
    fileNameLabel:setText(selectedFile.name)
    fileDescLabel:setText(selectedFile.description)
    
    installButton:setVisible(true)

    -- Checks if the computer already has the file to determine if it is an install or reinstall.
    local fileName = selectedFile.link:match("([^/]+)$")
    if not (fs.exists(fileName)) then
        installButton:setText("Install")
        installButton:setBackground(colors.green)
    else
        installButton:setText("Reinstall")
        installButton:setBackground(colors.blue)
    end
end

local function CloseInstallMenu()
    subFrame:setVisible(true)
    installFrame:setVisible(false)
    UpdateSubFrame()
end

local function OpenInstallMenu()
    subFrame:setVisible(false)
    installFrame:setVisible(true)

    exitInstallMenuButton:onClick(function ()
        CloseInstallMenu()
    end)
end

local function InstallFile(inFile)
    installLabel:setText("Installing " .. inFile.name)
    local filename = inFile.link:match("([^/]+)$")

    local response = http.get(inFile.link)
    if (response) then

        local file = fs.open(filename, "w")
        file.write(response.readAll())
        file.close()

        response.close()
    end
    if (fs.exists(filename)) then
        installFrame:setBackground(colors.blue)
        installLabel:setText("Installation Complete\n\nFile Saved As ".. filename)
    else
        installFrame:setBackground(colors.red)
        installLabel:setText("Error, could not install. Did you enable http in the settings?")
    end

    exitInstallMenuButton:setVisible(true)
end

installButton:onClick(function (self)
    OpenInstallMenu()
   
    basalt.schedule(function()
        InstallFile(selectedFile)
    end)
end)

local function UpdateSelectedButton(inButton)
    for _, button in ipairs(buttonTable) do
        if (inButton == button) then
            button:setBackground(colors.green)
        else
            button:setBackground(colors.gray)
        end
    end
end

local function HandleButtonClick(inButton, index)
    UpdateSelectedButton(inButton)
    selectedFile = fileTable[index] -- sets the selected file
    UpdateSubFrame()
end

local function AddButtonsToScrollBar()
    local buttonHeight = math.floor(scrollFrame:getHeight() / 3) 
    local buttonWidth = math.floor(scrollFrame:getWidth() * (11/12))
    for index, file in ipairs(fileTable) do
        local button = scrollFrame:addButton():setBackground(colors.gray):setText(file.name):setSize(buttonWidth,buttonHeight):setForeground(colors.white):alignLeft(scrollFrame,0)
        button:setPosition(0, ((index - 1) * buttonHeight))
        button:onClick(function (self)
            HandleButtonClick(button, index)
        end)
        table.insert(buttonTable, button)
    end
end

AddButtonsToScrollBar()

basalt.run();