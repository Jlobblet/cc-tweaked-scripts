-- Configure this to be the threshold to trigger output
-- Valid options: 0-1
local threshold = 0.99

-- Configure this to be the output side that redstone signal will be sent to
-- Valid options: top, bottom, left, right, front, back
local outputSide = "bottom"

-- Configure this to be duration in seconds to sleep between checks
-- Valid options: >= 0
local checkSleepTime = 1

-- Validate inputs

if threshold < 0 or threshold > 1 then
    error("Threshold is out of logical range (expected 0-1, got" .. threshold .. ").")
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local validSides = {
    "top",
    "bottom",
    "left",
    "right",
    "front",
    "back",
}

if not table.contains(validSides, outputSide) then
    error("Invalid output side " .. outputSide .. ".")
end

if checkSleepTime < 0 then
    error("Sleep time is out of logical range (expected > 0, got " .. checkSleepTime .. ").")
end

-- Now that we have validated the inputs, can proceed to find the energy cube

local cubes = {
    "basicEnergyCube",
    "advancedEnergyCube",
    "eliteEnergyCube",
    "ultimateEnergyCube",
}

local ec = nil

for _, v in pairs(cubes) do
    ec = peripheral.find(v)
    if ec ~= nil then break end
end

if ec == nil then error("Could not find an Energy Cube!") end

-- With an energy cube, can run main loop

local lastState = false
local state = lastState
while true do
    lastState = state
    local percentage = ec.getEnergyFilledPercentage()
    if percentage <= threshold then
        state = true
    else
        state = false
    end

    if state ~= lastState then
        local time = textutils.formatTime(os.time("local"), true)
        print("State changed from " .. tostring(lastState) .. " to " .. tostring(state) .. " at " .. time .. ".")
        redstone.setOutput(outputSide, state)
    end
    sleep(checkSleepTime)
end
