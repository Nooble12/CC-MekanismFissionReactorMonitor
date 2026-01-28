
local function InstallFiles()
    print("Starting installation...")

    local linkTable = {
        "https://raw.githubusercontent.com/Pyroxenium/Basalt2/refs/heads/main/release/basalt-full.lua",
        "https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/ARC_Manager.lua"
    }

    for i = 1, #linkTable do
        local response = http.get(linkTable[i])

        if (response) then
            response.close()
            shell.run("wget", linkTable[i])
            
        else
            print("Error, could not install. Did you enable http in the settings?")
        end
    end
    print("Installation complete.")
    fs.move("basalt-full.lua", "basalt.lua")
end

InstallFiles()