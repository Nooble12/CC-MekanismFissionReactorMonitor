local reactor = peripheral.find("fissionReactorLogicAdapter")
local reactorIsOn = false

if reactor then
    print("Fission Reactor Found")
    reactor.activate()
    reactorIsOn = reactor.getStatus()
else
    print("Error, could not find fission reactor")
end

--Config
local reactorMaxTemp = 1100 -- kelvin

local function checkReactorTemp()
    while reactorIsOn do
        os.sleep(0.01)
        local reactorTemp = reactor.getTemperature()

        if (reactorTemp > reactorMaxTemp) then
            print("Danger, reactor temp exceeds safe limit.")
            reactor.scram()

            reactorIsOn = reactor.getStatus()
        end
    end
end

while true do
    checkReactorTemp()
end