local tagToExport = "minecraft:leaves"
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
        local count = 64
        if not item["amount"] then
            count = 1
        elseif item["amount"] < 64 then
            count = item["amount"]
        end
        print("exporting " .. item["displayName"] .. " x " .. count)
        bridge.exportItemToPeripheral({
            name=item["name"],
            count=count,
            nbt=item['nbt']
        }, peripheral.getName(outputChest))
    end
end

print("all done")
