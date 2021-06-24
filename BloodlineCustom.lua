local ADDON_NAME, BloodlineCustom = ...

local AS = unpack(AddOnSkins)
local ChatFrame = _G["ChatFrame1"]

local f = CreateFrame("FRAME")
f:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, ...)
end)

function BloodlineCustom:AddMessage(message)
    ChatFrame:AddMessage(string.format("|cff69CCF0BloodlineCustom:|r %s", message))
end

function BloodlineCustom:HandlePortalMage()
    if not AS:CheckAddOn('PortalMage') then return end

    function AS:PortalMage()
        local function StyleNormalButton(self, count)
            local Name = self:GetName()
            local Button = self
            local Backdrop = Button:GetBackdrop()
            local Icon = Button:CreateTexture(Name.."Texture", "BACKGROUND")
            local newHeight = 40;
            local newWidth = 40;

            Button:SetHeight(newHeight)
            Button:SetWidth(newWidth)
            Button:SetNormalTexture("")
            Button:ClearAllPoints()
            Button:Point("TOPLEFT", 0, (newHeight + 2) * -(count - 1))

            if (Button.isSkinned) then
                return
            end

            Icon:SetTexture(Backdrop.bgFile)

            AS:SetTemplate(Button)
            AS:SkinTexture(Icon)
            AS:SetInside(Icon)
            AS:StyleButton(Button)

            Button.isSkinned = true
        end

        for i = 1, 6 do
            if _G['PortalMageButton'..i] then
                StyleNormalButton(_G['PortalMageButton'..i], i)
            end
        end

        local parent = _G['PortalMageButton1']:GetParent()
        parent:SetHeight(250)
    end

    AS:RegisterSkin('PortalMage', AS.PortalMage)
end

function BloodlineCustom:HandleAutomaticRestock()
    local _
    local stockQuantities = BloodlineCustom.db.char.restocking

    f:RegisterEvent("MERCHANT_SHOW")

    function f:MERCHANT_SHOW()
        local purchaseTable = {}
        local needToBuySomething = false
        for itemName, quantity in pairs(stockQuantities) do
            local amountOwned = GetItemCount(itemName, false)
            local amountToBuy = quantity - amountOwned

            if amountToBuy > 0 then
                purchaseTable[itemName] = amountToBuy
                needToBuySomething = true
            end
        end

        if needToBuySomething == false then return end

        local purchasedTable = {}
        local boughtSomething = false
        for i = 0, GetMerchantNumItems() do
            local itemName, _, _, _, amountAvailable = GetMerchantItemInfo(i)
            local itemLink = GetMerchantItemLink(i)

            if purchaseTable[itemName] then
                local amountToBuy = purchaseTable[itemName]
                local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemLink)
                local amountBought = 0

                if amountToBuy > amountAvailable and amountAvailable > 0 then
                    BuyMerchantItem(i, amountAvailable)

                    amountBought = amountAvailable
                else
                    for n = amountToBuy, 1, -itemStackCount do
                        if n > itemStackCount then
                            BuyMerchantItem(i, itemStackCount)
                        else
                            BuyMerchantItem(i, n)
                        end
                    end

                    amountBought = amountToBuy
                end

                purchasedTable[itemName] = {
                    quantity = amountBought,
                    itemLink = itemLink
                }

                boughtSomething = true
            end
        end

        if boughtSomething then
            for _, purchased in pairs(purchasedTable) do
                BloodlineCustom:AddMessage(string.format("Restocked %d x %s", purchased.quantity, purchased.itemLink))
            end
        end
    end
end

f:RegisterEvent("ADDON_LOADED")
function f:ADDON_LOADED()
    if ADDON_NAME ~= "BloodlineCustom" then return end

    local dbDefaults = {
        char = {
            restocking = {}
        }
    }

    BloodlineCustom.db = LibStub("AceDB-3.0"):New("BloodlineCustomDB", dbDefaults)

    BloodlineCustom:InitializeConfig()

    BloodlineCustom:HandlePortalMage()
    BloodlineCustom:HandleAutomaticRestock()

    f:UnregisterEvent("ADDON_LOADED")
end

