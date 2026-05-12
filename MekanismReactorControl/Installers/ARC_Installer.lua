local version = "1.0.0"

local function InstallBasalt()
    shell.run("wget", "https://raw.githubusercontent.com/Pyroxenium/Basalt2/refs/heads/main/release/basalt-full.lua")
    fs.move("basalt-full.lua", "basalt.lua")
end

if not (fs.exists("basalt.lua")) then
    InstallBasalt()
end

------------------------------------------------------------------------------------------------------------------
--- UI CODE
------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local main = basalt.getMainFrame():setBackground(colors.black)
local subFrame = main:addFrame():setBackground(colors.blue):setSize(60, 20)
local fileFrame = subFrame:addFrame():setBackground(colors.gray):setSize(30,20)
local scrollFrame = subFrame:addScrollFrame():setBackground(colors.black):setSize(30,20):centerVertical(fileFrame):centerHorizontal(fileFrame)

local infoFrame = subFrame:addFrame():setBackground(colors.gray):rightOf(scrollFrame, 1):setSize(21,20)
local fileNameLabel = infoFrame:addLabel():setSize(20,3):setText(""):setForeground(colors.white):setPosition(2,2)
local fileDescLabel = infoFrame:addLabel():setSize(20,10):setForeground(colors.white):setPosition(2, 4):setAutoSize(false)
fileDescLabel:setText("")

local installButton = infoFrame:addButton():setBackground(colors.green):setSize(20,5):setPosition(2, 15):setText("Install"):setVisible(false)

local installFrame = main:addFrame():setBackground(colors.blue):setSize(60,20):setVisible(false)

local exitInstallMenuButton = installFrame:addButton():setBackground(colors.green):setSize(10,5):setText("Exit"):setPosition(0,15)

local installLabel = installFrame:addLabel():setForeground(colors.white):setAutoSize(false):setSize(30, 3)
installLabel:setText("")

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
        description = "Script that displays data to attached monitors from the manager computer.",
        link = "https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/src/ARC_Monitor.lua"
    }
}

local buttonTable = {}

local selectedFile = {}

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
        installLabel:setText("Installation Complete\n\nFile Saved As ".. filename)
    else
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

local function HandleButtonClick(inButton, index)
    for _, button in ipairs(buttonTable) do
        if (inButton == button) then
            button:setBackground(colors.green)
        else
            button:setBackground(colors.gray)
        end
    end
    selectedFile = fileTable[index] -- sets the selected file
    UpdateSubFrame()
end

local function AddButtonsToScrollBar()
    local buttonHeight = 8
    local buttonWidth = 30
    for index, file in ipairs(fileTable) do
        local button = scrollFrame:addButton():setPosition(1, (index - 1) * buttonHeight):setBackground(colors.gray):setText(file.name):setSize(buttonWidth,buttonHeight):setForeground(colors.white)
        button:onClick(function (self)
            HandleButtonClick(button, index)
        end)
        table.insert(buttonTable, button)
    end
end

AddButtonsToScrollBar()

basalt.run();