local tagToExport = "forge:weapon"

local bridge = peripheral.find("rsBridge")
local outputChest  = peripheral.wrap("right")

local function includes(val, tbl)
    for i, row in ipairs(tbl) do
        if row == val then
            return true
        end
    end
    return false
end

local items = bridge.listItems()
for i, item in ipairs(items) do
    if item["tags"] and includes(tagToExport, item["tags"]) then
        if #outputChest.list() >= outputChest.size() then
            print("output chest full");
            break
        end
        print("exporting " .. item["displayName"])
        bridge.exportItemToPeripheral(item, peripheral.getName(outputChest))
    end
end

print("all done")
