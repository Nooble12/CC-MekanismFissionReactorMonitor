--[[
Method Name 	Additional Info
activate(): 	Will activate the reactor.
scram(): 	Will, you guessed it, scram the reactor.
getStatus(): Boolean 	Will return true when the reactor is online, and false when it isn't.
getTemperature(): Number 	By default in Kelvin. (subtract 273.15 to convert to Celsius)
getDamagePercent(): Number 	Returns damage.
getCoolant(): Table 	Returns both the amount and type. For example, for coolant it can be {amount=7.29E7, name="minecraft:water"}
getCoolantFilledPercentage(): Number 	Returns how full the coolant tank is.
getHeatedCoolant(): Table 	Returns both the amount and type.
getHeatedCoolantFilledPercentage(): Number 	Returns how full the heated coolant tank is.
getFuel(): Table 	Returns both the amount and type.
getFuelFilledPercentage(): Number 	Returns how full the fuel tank is.
getFuelNeeded(): Number 	Returns the amount of fuel needed to completely fill the tank.
getFuelCapacity(): Number 	Returns the fuel capacity.
getWaste(): Table 	Returns both the amount and type.
getWasteFilledPercentage(): Number 	Returns how full the waste tank is.
getBurnRate(): Number 	Returns the set reactor burn rate.
getActualBurnRate(): Number 	Returns the current burn rate.
getMaxBurnRate(): Number 	Returns the maximum possible reactor burn rate.
getHeatingRate(): Number 	Returns the amount of coolant being heated (mB/t).
getEnvironmentalLoss(): Number 	Returns the environmental loss.
isForceDisabled(): Boolean 	Returns wether the reactor is force disabled.
setBurnRate(): Number 	Set the desired reactor burn rate. 
--]]

local reactor = peripheral.find("fissionReactorLogicAdapter")
local reactorIsOn = false

if reactor then
    print("Fission Reactor Found")
else
    print("Error, could not find fission reactor")
end

--Config
local reactorMaxTemp = 1100 -- kelvin

--Change this to your computer ID
local reactorMonitorComputerID = 1

local rednetModem = peripheral.find("modem", rednet.open)

if (rednet.isOpen()) then
    print("Modem Found!")
    
else
    print("Modem Not Found!")
end

local function GetReactorStatusAsString() 
    local reactorIsRunning = reactor.getStatus()

    if (reactorIsRunning) then
        return "Active"
    else
        return "Disabled"
    end
end
    

local function GetReactorDataTable()
    local reactorData = 
    {

        reactorInfo = 
        {
            { -- Warning, changing this object will cause an issue. The monitor code looks for this object to determine the button ACTIVATE or SCRAM state. 
                name = "Status",
                value = GetReactorStatusAsString(),
                boolValue = reactor.getStatus(),
                unit = ""
            },

            {
                name = "Current Temp",
                value = math.floor(reactor.getTemperature()), 
                unit = "K"
            },

            {
                name = "Coolant",
                value = reactor.getCoolant().name,
                unit = ""
            },

            {
                name = "Damage",
                value = reactor.getDamagePercent() * 100,
                unit = "percent"
            },

            {
                name = "Burn Rate",
                value = reactor.getBurnRate(),
                unit = "mb/t"
            },

            {
                name = "Max Actual Burn Rate", 
                value = reactor.getActualBurnRate(),
                unit = "mb/t"
            }

        },

        --[[ Naming Conventions
        @labelText = displayed text that appears on the monitor
        @value = value of reactor measurement
        @threshold = range of numbers where if the value is within, the bar will turn red. Ex. reactor temp is too high -> turn bar red
        ]]

        barData = {
            {
                labelText = "Core Temperature",
                value = math.ceil((reactor.getTemperature() / reactorMaxTemp) * 100),
                threshold = {80, 100}
            },

            {
                labelText = "Fissile Fuel",
                value = math.ceil(reactor.getFuelFilledPercentage() * 100),
                threshold = {0, 30}
            },

            {
                labelText = "Coolant",
                value = math.floor(reactor.getCoolantFilledPercentage() * 100),
                threshold = {0, 50}
            },

            {
                labelText = "Steam",
                value = math.floor(reactor.getHeatedCoolantFilledPercentage() * 100),
                threshold = {80, 100}
            },

            {
                labelText = "Waste",
                value = math.floor(reactor.getWasteFilledPercentage() * 100),
                threshold = {80, 100}
            },

        },
    }
    return reactorData
end

local function SendData()
    while true do
        local reactorDataTable = GetReactorDataTable()
        rednet.send(reactorMonitorComputerID, {
            type = "reactorData",
            data = reactorDataTable
        })
        os.sleep(0.5) -- sleep for 1/2 second to prevent server overload 
    end
end

--Activates / Disables the reactor from a remote computer
local function ListenForOverride()
while true do 
    local senderID, message, protocol = rednet.receive()
        if type(message) == "table" and message.type == "ReactorOverrideRequest" then
            print("Request received")
            local isRunning = reactor.getStatus()

            if (isRunning) then
                reactor.scram()
                print("Reactor is now off")
            else
                reactor.activate()
                print("Reactor is now on")
            end
        end
        os.sleep(0.1)
    end
end

parallel.waitForAny(ListenForOverride, SendData)