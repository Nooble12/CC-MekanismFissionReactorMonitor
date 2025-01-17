rednet.open("top") -- Open the modem on the top side

local alarm = peripheral.wrap("left")

local computerIsListening = true
local monitor = peripheral.find("monitor")

local reactorData = {}

local function enableAlarm()
    redstone.setOutput("left", true)
end

local function disableAlarm()
    redstone.setOutput("left", false)
end

local currentRow = 1
local function resetCursorPos()
    monitor.setCursorPos(1,1)
    currentRow = 1
end

local function writeToMonitor(label, value, color)
    monitor.setTextColor(color)
    monitor.write(string.format("%-20s: %s", label, value))
    currentRow = currentRow + 1
    monitor.setCursorPos(1, currentRow)
end

local function getTemperatureColor(inTemperature, maxTemperature)
    local warningTemp = maxTemperature * 0.60
    local criticalTemp = maxTemperature * 0.70

    if inTemperature > criticalTemp then
        enableAlarm()
    else
        disableAlarm()
    end

    if inTemperature < warningTemp then
        return colors.green

        elseif inTemperature > warningTemp and inTemperature < criticalTemp then
            return colors.orange
        else
            return colors.red
    end
end

local function getCoolantColor(coolantPercent)
    local warningPercent = 80
    local criticalLevel = 50

    if coolantPercent < criticalLevel then
        enableAlarm()
    else
        disableAlarm()
    end

    if coolantPercent >= warningPercent then
        return colors.green

    elseif coolantPercent < warningPercent and coolantPercent > criticalLevel then
        return colors.orange
    else
        return colors.red
    end
end

local function getReactorDamageColor(inDamage)
    if inDamage > 0 then
        return colors.red

    else
        return colors.green
    end
end

local function getWasteColor(inWastePercent)
    local warningPercent = 50
    local criticalPercent = 80

    if inWastePercent < warningPercent then
        return colors.green

    else if inWastePercent > warningPercent and inWastePercent < criticalPercent then
        return colors.orange
    else
        return colors.red
        end
    end
end

local function updateMonitor()
    monitor.clear()
    resetCursorPos()

    local reactorStatusColor = reactorData.reactorStatus and colors.green or colors.red
    writeToMonitor
    (
        "Reactor Status: ", (reactorData.reactorStatus and "Active" or "Inactive"), reactorStatusColor
    )

    writeToMonitor
    (
        "Temperature: ", reactorData.currentTemperature  .. " / " .. reactorData.maxTemperature .. "K", getTemperatureColor(reactorData.currentTemperature, reactorData.maxTemperature)
    )

    writeToMonitor
    (
        "Coolant: ", reactorData.coolantPercent .. "%", getCoolantColor(reactorData.coolantPercent)
    )

    writeToMonitor
    (
        "Damage: ", reactorData.reactorDamage.. "%", getReactorDamageColor(reactorData.reactorDamage)
    )

    writeToMonitor
    (
        "Burn Rate: ", reactorData.burnRate .. " / " .. reactorData.maxBurnRate .." mB/s", colors.white
    )

    writeToMonitor
    (
        "Steam: ", reactorData.heatedCoolantPercent  .. "%", colors.white
    )

    writeToMonitor
    (
        "Waste: ", reactorData.wastePercent .. "%", getWasteColor(reactorData.wastePercent)
    )
    resetCursorPos()
end

while computerIsListening do
    local senderID, message, protocol = rednet.receive()

    if type(message) == "table" and message.type == "reactorData" then
        reactorData = message.data
    end

    updateMonitor()
    os.sleep(0.5)
end