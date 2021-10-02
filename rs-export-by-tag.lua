local pretty = require "cc.pretty"

local bridge = peripheral.find("rsBridge")
local filterChest  = peripheral.wrap("top")
local outputChest  = peripheral.wrap("right")

local function includes(needles, haystack)
    for _, a in ipairs(haystack) do
        for _, b in ipairs(needles) do
            if a == b then
                return true
            end
        end
    end
    return false
end

local function getTagsFromFilterChest()
    local hash = {}
    for slot, item in pairs(filterChest.list()) do
        local itemDetails = filterChest.getItemDetail(slot)
        for tag, _ in pairs(itemDetails["tags"]) do
            hash[tag] = true
        end
    end
    local tags = {}
    for tag, _ in pairs(hash) do
        tags[#tags + 1] = tag
    end
    return tags
end

local function exportFromRS()
    local filterTags = getTagsFromFilterChest()
    local items = bridge.listItems()
    for i, item in ipairs(items) do
        if item["tags"] and includes(filterTags, item["tags"]) then
            if #outputChest.list() >= outputChest.size() then
                print("output chest full");
                break
            end
            local count = 64
            if not item["amount"] then
                count = 1
            elseif item["amount"] < 64 then
                count = item["amount"]
            end
            print("exporting " .. item["displayName"] .. " x " .. count)
            pretty.print(pretty.pretty(item))
            pretty.print(pretty.pretty({
                name=item["name"],
                count=count,
                nbt=item['nbt'] or {}
            }))
            break
            --bridge.exportItemToPeripheral({
            --    name=item["name"],
            --    count=count,
            --    nbt=item['nbt'] or {}
            --}, peripheral.getName(outputChest))
        end
    end
end

exportFromRS()

-- while true do
--     print("waiting for redstone")
--     local event = os.pullEvent("redstone")
--     if redstone.getInput("front") then
--         exportFromRS()
--         print("all done")
--     end
-- end
