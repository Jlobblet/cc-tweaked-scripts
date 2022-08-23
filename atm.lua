local targets = {
    "allthemodium:allthemodium_ore",
    "allthemodium:allthemodium_slate_ore",
}

local cb = peripheral.find("chatBox")
if cb == nil then error("Chat Box not found.") end

local br = peripheral.find("blockReader")
if br == nil then error("Block Reader not found.") end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Check()
    local blockName = br.getBlockName()
    return table.contains(targets, blockName)
end

function Alert()
    local time = textutils.formatTime(os.time("local"), true)
    local function send()
        cb.sendMessage("Stuck on Allthemodium Ore since " .. time .. "!", "ATM Alert")
    end

    send()
    local count = 0
    while Check() do
        sleep(1)
        count = count + 1
        if count == 300 then
            count = 0
            send()
        end
    end
end

while true do
    local isAtm = Check()
    if isAtm then
        Alert()
    end
    sleep(1)
end
