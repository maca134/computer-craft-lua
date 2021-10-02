-- An item counter for CC: Tweaked - https://pastebin.com/FBNVFw3A
-- https://dl.dropboxusercontent.com/s/hwxp3jkfopy51n3/xhW2PxsI4XKads0Utgeg.gif
-- 
-- Input chest is on the left of the computer
-- Output chest is on the right of the computer
-- A redstone signal on the front of the computer resets the counters
--
-- To install run the follow in a CC: Tweaked computer: 
--      pastebin get FBNVFw3A startup
--      reboot
--

local inputChest = peripheral.wrap("left")
local outputChest = peripheral.wrap("right")
local monitor = peripheral.find("monitor")

local startTime = os.clock();
local items = {}

local function shortNumberFormat(n)
    if n >= 10^12 then
        return string.format("%.2fg", n / 10^12)
    elseif n >= 10^6 then
        return string.format("%.2fm", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.2fk", n / 10^3)
    else
        return tostring(n)
    end
end

local function trimString(str, length)
    if #str <= length then
        return str .. string.rep(" ", length - #str)
    else
        return string.sub(str, 0, length - 3) .. "..."
    end
end

local function round(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end

local function renderText(text, line, color, pos)
    local monX, monY = monitor.getSize()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(color)
    local length = string.len(text)
    local dif = math.floor(monX - length)
    local x = math.floor(dif / 2)

    if pos == "center" then
        monitor.setCursorPos(x+1, line)
        monitor.write(text)
    elseif pos == "left" then
        monitor.setCursorPos(2, line)
        monitor.write(text)
    elseif pos == "right" then
        monitor.setCursorPos(monX-length, line)
        monitor.write(text)
    end
end

local function clearScreen()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos(1,1)
    line = 1
end

local function render()
    clearScreen()
    local duration = os.clock() - startTime;
    renderText("Item Counter", 1, colors.red, "center")
    local sortedItems = {}
    for key, val in pairs(items) do
        table.insert(sortedItems, val)
    end
    table.sort(sortedItems, function(a, b) return a["count"] > b["count"] end)
    local monX, monY = monitor.getSize()
    monX = monX - 5
    local rows = {}
    for i, val in ipairs(sortedItems) do
        if i + 2 > monY then break end
        local rate = val["count"] / duration
        local unit = "sec"
        if (rate < 1) then
            rate = rate * 60
            unit = "min"
        end
        if (rate < 1) then
            rate = rate * 60
            unit = "hr"
        end
        rows[i] = {
            shortNumberFormat(val["count"]),
            val["name"],
            shortNumberFormat(round(rate, 2)) .. "/" .. unit
        }
    end
    local sizes = {}
    for i, row in ipairs(rows) do
        for j, col in ipairs(row) do
            if not sizes[j] then
                sizes[j] = 0
            end
            if sizes[j] < #col then
                sizes[j] = #col
            end
        end
    end
    local sum = 0
    for i, size in ipairs(sizes) do
        sum = sum + size
    end
    if sum == 0 then
        return
    end
    sizes[2] = sizes[2] + (monX - sum)
    for i, row in ipairs(rows) do
        renderText(trimString(row[1], sizes[1]) .. "|" .. trimString(row[2], sizes[2]), i+2, colors.yellow, "left")
        renderText(row[3], i+2, colors.green, "right")
    end
end

local function countItems()
    while true do
        for slot, item in pairs(inputChest.list()) do
            if not items[item.name] then
                local itemDetails = inputChest.getItemDetail(slot)
                items[item.name] = {
                    ["name"] = itemDetails.displayName, 
                    ["count"] = 0 
                }
            end
            items[item.name]["count"] = items[item.name]["count"] + item.count
            inputChest.pushItems(peripheral.getName(outputChest), slot)
        end
        render()
        os.sleep(1)
    end
end

local function reset()
    while true do
        local event = os.pullEvent("redstone")
        if redstone.getInput("front") then
            startTime = os.clock()
            items = {}
            render()
        end
    end
end

clearScreen()
print("running")
parallel.waitForAny(countItems, reset)