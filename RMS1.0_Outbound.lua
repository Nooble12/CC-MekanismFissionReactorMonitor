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
]]

local reactor = peripheral.find("fissionReactorLogicAdapter")
local reactorIsOn = false

if reactor then
    print("Fission Reactor Found")
    --reactor.activate()
    reactorIsOn = reactor.getStatus()
else
    print("Error, could not find fission reactor")
end

local reactorData = {}

--Config
local reactorMaxTemp = 1100 -- kelvin

--Change this to your computer ID
local reactorMonitorComputerID = 6

rednet.open("top")

local function updateReactorData()
    reactorData = 
    {
       burnRate = reactor.getBurnRate(),
       maxBurnRate = reactor.getMaxBurnRate(),
       currentTemperature = math.floor(reactor.getTemperature()),
       maxTemperature = reactorMaxTemp,
       reactorDamage = math.floor(reactor.getDamagePercent()),
       coolantPercent = math.floor(reactor.getCoolantFilledPercentage() * 100),
       wastePercent = math.floor(reactor.getWasteFilledPercentage() * 100),
       heatedCoolantPercent = math.floor(reactor.getHeatedCoolantFilledPercentage() * 100),
       reactorStatus = reactor.getStatus()
    }
end

while true do 
     os.sleep(0.5) -- sleep for 1 second to prevent server overload

     updateReactorData()
    
    --Sends the reactor data table to a computer
     rednet.send(reactorMonitorComputerID, {
        type = "reactorData",
        data = reactorData
    })
end


