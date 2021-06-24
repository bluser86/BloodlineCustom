local _, BloodlineCustom = ...

local restockingOptions = { name = "Automatic Restocking", type = "group", args = {}, }
local options = { name = "Bloodline Custom", type = "group", args = { restocking = restockingOptions }, }
local restockingOptionsGroupTemplate = {
    name = "Item",
    type = "group",
    inline = true,
    args = {
        quantity = {
            name = "Quantity",
            desc = "The amount of items you wish to have on you.",
            type = "input",
            order = 1,
        },
        remove = {
            name = "Remove",
            type = "execute",
            width = 0.5,
            order = 3,
        }
    },
}

function BloodlineCustom:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[BloodlineCustom:DeepCopy(orig_key)] = BloodlineCustom:DeepCopy(orig_value)
        end
        setmetatable(copy, BloodlineCustom:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function BloodlineCustom:InitializeRestockingOptions()
    restockingOptions.args = {
        itemName = {
            name = "Add item",
            type = "input",
            set = function (_, itemName)
                BloodlineCustom:AddAutomaticRestockingOptionGroup(itemName)
            end,
        },
    }

    for itemName, _ in pairs(BloodlineCustom.db.char.restocking) do
        BloodlineCustom:AddAutomaticRestockingOptionGroup(itemName)
    end
end

function BloodlineCustom:AddAutomaticRestockingOptionGroup(itemName)
    local optionsGroup = BloodlineCustom:DeepCopy(restockingOptionsGroupTemplate)

    optionsGroup.name = itemName
    optionsGroup.args.remove.func = function ()
        BloodlineCustom:RemoveAutomaticRestockingOptionGroup(itemName)
    end
    optionsGroup.args.quantity.get = function ()
        local quantity = BloodlineCustom.db.char.restocking[itemName]
        if quantity then
            return quantity
        end
    end
    optionsGroup.args.quantity.set = function(_, value)
        BloodlineCustom.db.char.restocking[itemName] = value
    end

    restockingOptions.args[itemName] = optionsGroup
end

function BloodlineCustom:RemoveAutomaticRestockingOptionGroup(itemName)
    restockingOptions.args[itemName] = nil
    BloodlineCustom.db.char.restocking[itemName] = nil
end

function BloodlineCustom:InitializeConfig()
    BloodlineCustom:InitializeRestockingOptions()

    LibStub("AceConfig-3.0"):RegisterOptionsTable("BloodlineCustom", options, nil)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BloodlineCustom", "Bloodline Custom")
end

