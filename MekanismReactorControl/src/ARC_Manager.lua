-- An array of multiple different computer ID to send packages to.
local computerTargets = {-1, -2} 

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

local reactor
local reactorIsOn = false

--[[
Runs a pcall to see if data can be pulled from the reactor. Only possible if it is fully assembled.
]]
local function CheckIfReactorIsAssembled()
    local success, result = pcall(reactor.getBurnRate)

    return success
end

--[[
Keeps checking for the reactor logic adapter
]]
local function CheckForReactor()
    local isReactorAssembled = false
    local checkCount = 1 -- number of failed reactor checks
    while (checkCount <= 10 and not isReactorAssembled) do
        term.clear()
        term.setCursorPos(1,1)
        reactor = peripheral.find("fissionReactorLogicAdapter")
        isReactorAssembled = CheckIfReactorIsAssembled()
        
        if isReactorAssembled then
            print("Fission Reactor Found")
        else
            for i = 5, 0, -1 do
                term.clear()
                term.setCursorPos(1,1)

                print("Error, could not find fission reactor.")
                print("Trying again in " .. i .. " seconds.")
                print("Attempt " .. checkCount .. "/10.")
                os.sleep(1)
            end
        end
        os.sleep(0.1) 
        checkCount = checkCount + 1
    end
    checkCount = 1

    return isReactorAssembled
end

--[[
Checks and assigns modem if found
]]
local function CheckForModem()
    if (rednet.isOpen()) then
        print("Modem Found!")
    else
        print("Modem Not Found!")
    end
end

--[[
Prints the error message/
@param errorMessage the pcall result message
]]
local function PrintException(errorMessage)
   if type(errorMessage) == "string" then
        print("Error: " .. errorMessage) 
    end
end

--[[
Runs a pcall for the input function. If fail, print exception. If sucessful, return the result.
@param inFunction A passed function that will be ran within a pcall.
@return result The return of the inputed function or nil if failed.
]]
local function SafeCall(inFunction)
    local success, result = pcall(inFunction)

    if (success) then
        return result
    else
        PrintException(result)
        return nil
    end
end

--Config
local reactorMaxTemp = 1100 -- kelvin

local rednetModem = peripheral.find("modem", rednet.open)

local function GetReactorStatusAsString() 
    local reactorIsRunning = reactor.getStatus()

    if (reactorIsRunning) then
        return "Active"
    else
        return "Disabled"
    end
end

local function ScramReactor()
    if (reactor.getStatus() == false) then
        return
    end

    reactor.scram()
end

-- Checks reactor data to ensure that it is running within safe parameters
local function RunSafetyChecks()
    local warningList = {} -- holds a bunch of warning strings that will be sent to the computer

    ------------------------------------------------------
    --- Hard shut off checks
    ------------------------------------------------------
    if (reactor.getTemperature() > 1100) then
        ScramReactor()
        table.insert(warningList, "SCRAM: Maximum core temperature was exceeded.")
        return warningList
    end

    if ((reactor.getCoolantFilledPercentage() * 100) < 30) then
        ScramReactor()
        table.insert(warningList, "SCRAM: Insufficent coolant.")
        return warningList
    end

    if ((reactor.getWasteFilledPercentage()* 100 >= 90)) then
        ScramReactor()
        table.insert(warningList, "SCRAM: Maximum nulcear waste limit was exceeded.")
        return warningList
    end

     if ((reactor.getHeatedCoolantFilledPercentage() * 100 >= 90)) then
        ScramReactor()
        table.insert(warningList, "SCRAM: Maximum steam limit was exceeded.")
        return warningList
    end
    ------------------------------------------------------
    --- Hard shut off checks
    ------------------------------------------------------


    ------------------------------------------------------
    --- Warnings
    ------------------------------------------------------
    -- Sends a warning to the monitoring computer
    if(reactor.getTemperature() > 880) then
        table.insert(warningList, "Danger: Critical core temperature.")
    end

    if ((reactor.getCoolantFilledPercentage() * 100) < 50) then
        table.insert(warningList, "Danger: Coolant is low.")
    end

    if ((reactor.getWasteFilledPercentage()* 100 >= 80)) then
        table.insert(warningList, "Danger: Excess nuclear waste.")
    end

     if ((reactor.getHeatedCoolantFilledPercentage() * 100 >= 90)) then
        table.insert(warningList, "Danger: Excess steam.")
    end
    ------------------------------------------------------
    --- Warnings
    ------------------------------------------------------

    return warningList
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
                name = "Actual Burn Rate", 
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
        local routineTable = {}

        -- Pauses the program if reactor is broken
        if (not CheckIfReactorIsAssembled()) then
            -- If reactor can not be found after x attempts, end program loop.
            if (not CheckForReactor())then
                break;
            end
        end

        local reactorDataResult = SafeCall(GetReactorDataTable)
        local warningDataResult = SafeCall(RunSafetyChecks)

        if (reactorDataResult and warningDataResult ~= nil) then
            for _, id in ipairs(computerTargets) do
                table.insert(routineTable, coroutine.create(function ()
                    rednet.send(id, {
                        type = "reactorData",
                        reactorData = reactorDataResult,
                        warningData = warningDataResult
                    })
                end))
            end
            for _, c in ipairs(routineTable) do
                coroutine.resume(c)
            end
        end

        os.sleep(0.5) -- sleep for 1/2 second to prevent server overload 
    end
end

local function SendOverrideResponse(inMessage, senderID)
    rednet.send(senderID, {
        type = "overrideResponse",
        message = inMessage
    })
end

--Activates / Disables the reactor from a remote computer
local function ListenForOverride()
while true do 
    local senderID, message, protocol = rednet.receive()
        if type(message) == "table" and message.type == "ReactorOverrideRequest" then
            print("Request received from " .. senderID)

            local success, isRunning = pcall(reactor.getStatus) -- checks if status can be found. prevents requests from crashing manager if reactor is not found or is broken.

            if (not success) then
                SendOverrideResponse("Reactor not found.", senderID)
                goto continue
            end

            if (isRunning) then
                SendOverrideResponse("Reactor Disabled", senderID)
                reactor.scram()
                print("Reactor is now off")
            else
                local warningTable = SafeCall(RunSafetyChecks)

                if (#warningTable == 0) then
                    reactor.activate()
                    print("Reactor is now on") 
                    SendOverrideResponse("Reactor Enabled", senderID)
                else
                    print("Request Denied. Reactor Not Safe. Sent to " .. senderID)
                    SendOverrideResponse("Request Denied.", senderID)
                end
            end
        end

        ::continue::
        os.sleep(0.1)
    end
end

local function InitializeReactor()

    if (CheckForReactor()) then
        CheckForModem()
        parallel.waitForAny(ListenForOverride, SendData) 
    else
        print("Program Terminated. Could not find fission reactor.")
    end
end

InitializeReactor()
