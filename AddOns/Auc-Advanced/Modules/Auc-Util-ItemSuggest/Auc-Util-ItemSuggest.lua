--[[
	Auctioneer Advanced - Item Suggest module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: Auc-Util-ItemSuggest.lua 3793 2008-11-08 18:57:06Z aesir $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that allows the added tooltip for suggesting
	what should be done with an item based on weights and skills set. This module is also
	used by other modules in Auctioneer Advanced.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local libType, libName = "Util", "ItemSuggest"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local GetAprPrice = AucAdvanced.Modules.Util.Appraiser.GetPrice
local AppraiserValue, DisenchantValue, ProspectValue, VendorValue, bestmethod, bestvalue, _

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then lib.ProcessTooltip(...) --Called when the tooltip is being drawn.
	elseif (callbackType == "config") then lib.SetupConfigGui(...) --Called when you should build your Configator tab.
	elseif (callbackType == "listupdate") then --Called when the AH Browse screen receives an update.
	elseif (callbackType == "configchanged") then --Called when your config options (if Configator) have been changed.
	end
end

function lib.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost, additional)
	if (get("util.itemsuggest.enablett")) then
		local aimethod = lib.itemsuggest(hyperlink, quantity)
		tooltip:AddLine("Suggestion: ".. aimethod.. " this item")
	end
end

function lib.OnLoad()
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
end

local ahdeplength = {
	{'12', "12 hour"},
	{'24', "24 hour"},
	{'48', "48 hour"},
}
default("util.itemsuggest.enablett", 1) --Enables Item Suggest from Item AI to be displayed in tooltip
default("util.itemsuggest.enchantskill", 375) -- Used for item AI
default("util.itemsuggest.jewelcraftskill", 375)-- Used for item AI
default("util.itemsuggest.vendorweight", 100)-- Used for item AI
default("util.itemsuggest.auctionweight", 100)-- Used for item AI
default("util.itemsuggest.prospectweight", 100)-- Used for item AI
default("util.itemsuggest.disenchantweight", 100)-- Used for item AI
default("util.itemsuggest.relisttimes", 1)-- Used for item AI
default("util.itemsuggest.includebrokerage", 1)-- Used for item AI
default("util.itemsuggest.includedeposit", 1)-- Used for item AI
default("util.itemsuggest.deplength", "48")

function lib.SetupConfigGui(gui)
	local id = gui:AddTab(libName)
	gui:MakeScrollable(id)

	gui:AddHelp(id, "what itemsuggest",
        "What is the ItemSuggest module?",
        "ItemSuggest adds a tooltip line that suggests whether or not to auction, vendor, disenchant or prospect that item.")

	gui:AddControl(id, "Header",     0,    "ItemSuggest")
	gui:AddControl(id, "Checkbox",      0, 1, "util.itemsuggest.enablett", "Display ItemSuggest Tooltips")
	gui:AddTip(id,  "If enabled, will show ItemSuggest tooltip information.")

    gui:AddControl(id, "Header",     0,    "Set skill usage limits if desired")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.enchantskill", 0, 375, 25, "Max Enchanting Skill On Realm. %s")
	gui:AddTip(id, "Set ItemSuggest limits based upon Enchanting skill for your characters on this realm.")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.jewelcraftskill", 0, 375, 25, "Max JewelCrafting Skill On Realm. %s")
	gui:AddTip(id, "Set ItemSuggest limits based upon Jewelcrafting skill for your characters on this realm.")

	gui:AddControl(id, "Header",     0,    "ItemSuggest Recommendation Bias")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.vendorweight", 0, 200, 1, "Vendor Bias %s")
	gui:AddTip(id, "Weight ItemSuggest recommendations for vendor resale higher or lower.")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.auctionweight", 0, 200, 1, "Auction Bias %s")
	gui:AddTip(id, "Weight ItemSuggest recommendations for auction resale higher or lower.")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.disenchantweight", 0, 200, 1, "Disenchant Bias %s")
	gui:AddTip(id, "Weight ItemSuggest recommendations for Disenchanting higher or lower.")
	gui:AddControl(id, "WideSlider",           0, 2, "util.itemsuggest.prospectweight", 0, 200, 1, "Prospect Bias %s")
   	gui:AddTip(id, "Weight ItemSuggest recommendations for Prospecting higher or lower.")

	gui:AddControl(id, "Header",     0,    "Deposit cost influence")
	gui:AddControl(id, "Checkbox",     0, 1, "util.itemsuggest.includedeposit", "Include deposit costs?")
	gui:AddTip(id, "Set whether or not to include Auction House deposit costs as part of ItemSuggest tooltip calculations.")
	gui:AddControl(id, "Selectbox",		0, 1, 	ahdeplength, "util.itemsuggest.deplength", "Base deposits on what length of auction.")
	gui:AddTip(id, "If Auction House deposit costs are included, set the default Auction period used for purposes of calculating Auction House deposit costs.")
	gui:AddControl(id, "WideSlider",       0, 2, "util.itemsuggest.relisttimes", 1, 20, 0.1, "Average # of listings: %0.1fx")
	gui:AddTip(id, "Set the estimated average number of times an auction item is relisted.")
	gui:AddControl(id, "Checkbox",     0, 1, "util.itemsuggest.includebrokerage", "Include AH brokerage costs?")
	gui:AddTip(id, "Set whether or not to include Auction House brokerage costs as part of ItemSuggest tooltip calculations.")

end

function lib.itemsuggest(hyperlink, quantity)
	-- Determine Base Values
	if (quantity == nil) then quantity = 1 end
	VendorValue = lib.GetVendorValue(hyperlink, quantity)
	AppraiserValue = lib.GetAppraiserValue(hyperlink, quantity)

	if (get("util.itemsuggest.jewelcraftskill") == 0) then
		ProspectValue = 0
	else
		ProspectValue = lib.GetProspectValue(hyperlink, quantity)
	end

	if (get("util.itemsuggest.enchantskill") == 0) then
		DisenchantValue = 0
	else
		DisenchantValue = lib.GetDisenchantValue(hyperlink, quantity)
	end

	-- Do super duper nil check
	if VendorValue == nil then VendorValue = 0 end
	if AppraiserValue == nil then AppraiserValue = 0 end
	if ProspectValue == nil then ProspectValue = 0 end
	if DisenchantValue == nil then DisenchantValue = 0 end

	-- Adjust final values based on custom weights by enduser
	local adjustment = get("util.itemsuggest.vendorweight") or 0
	VendorValue = VendorValue * adjustment / 100
	adjustment = get("util.itemsuggest.auctionweight") or 0
	AppraiserValue = AppraiserValue * adjustment / 100
	adjustment = get("util.itemsuggest.prospectweight") or 0
	ProspectValue = ProspectValue * adjustment / 100
	adjustment = get("util.itemsuggest.disenchantweight") or 0
	DisenchantValue = DisenchantValue * adjustment / 100

	-- Determine which method 'wins' the battle
	bestvalue = math.max(0, VendorValue, AppraiserValue, ProspectValue, DisenchantValue)
	bestmethod = "Unknown"
	if bestvalue == 0 then
		bestmethod = "Unknown"
		bestvalue = "Unknown"
	elseif bestvalue == VendorValue then
		bestmethod = "Vendor"
	elseif bestvalue == AppraiserValue then
		bestmethod = "Auction"
	elseif bestvalue == ProspectValue then
		bestmethod = "Prospect"
	elseif bestvalue == DisenchantValue then
		bestmethod = "Disenchant"
	end

	-- Hand the winner back to caller...
	return bestmethod, bestvalue
end

function lib.GetAppraiserValue(hyperlink, quantity)
	AppraiserValue = GetAprPrice(hyperlink, nil, true) or 0
	AppraiserValue = AppraiserValue * quantity
	local brokerRate, depositRate = 0.05, 0.05
	if (get("util.itemsuggest.includedeposit")) then
		local aadvdepcost = GetDepositCost(hyperlink, 24, nil, quantity) or 0
		local depcost = aadvdepcost * get("util.itemsuggest.relisttimes")
		AppraiserValue = AppraiserValue - depcost
	end
	if (get("util.itemsuggest.includebrokerage")) then
		AppraiserValue = AppraiserValue - AppraiserValue * brokerRate
	end

return AppraiserValue end

function lib.GetDisenchantValue(hyperlink, quantity)
	if not (Enchantrix and Enchantrix.Storage) then return end
	local DisenchantValue = 0
	local _, _, iQual, iLevel = GetItemInfo(hyperlink)
	if (iQual == nil or iQual <= 1 or iLevel == nil) then return end
	local skillneeded = Enchantrix.Util.DisenchantSkillRequiredForItemLevel(iLevel, iQual)
	local market

	if (skillneeded > get("util.itemsuggest.enchantskill"))  then
		return DisenchantValue
	else
		_, _, _, market = Enchantrix.Storage.GetItemDisenchantTotals(hyperlink)

		if (market == 0)  then
			return DisenchantValue
		end
	end

	local adjusted = market or 0

	if (get("util.itemsuggest.includebrokerage")) then
		local brokerRate, depositRate = 0.05, 0.05
		local amount = (adjusted * brokerRate)
		adjusted = adjusted - amount
	end

	DisenchantValue = adjusted
return DisenchantValue end

function lib.GetProspectValue(hyperlink, quantity)
	if not Enchantrix then return end
	local ProspectValue = 0
	local prospects = Enchantrix.Storage.GetItemProspects(hyperlink)
	local jcSkillRequired = Enchantrix.Util.JewelCraftSkillRequiredForItem(hyperlink)
	if (jcSkillRequired == nil or jcSkillRequired > get("util.itemsuggest.jewelcraftskill"))  then
		return ProspectValue
	else
		local _, itemid, _, _, _, _ = decode(hyperlink)  -- lType, id, suffix, factor, enchant, seed
		local trashTotal, marketTotal, depositTotal, brokerTotal = 0, 0, 0, 0
		local brokerRate, depositRate = 0.05, 0.05

		if (prospects) == nil then return ProspectValue end
		for result, yield in pairs(prospects) do
		-- adjust for stack size
		yield = yield * quantity / 5

			local _, _, quality = GetItemInfo(result)
			if quality == 0 then
				-- vendor trash (lower level powders)
				-- we need informant (or some other mod using GetSellValue) to get the vendor prices, if it is missing, use price of zero
				local vendor = GetSellValue and GetSellValue(result) or 0
				trashTotal = trashTotal + vendor * yield
			else
				-- gem or non-trashy powder
				local _, _, _, market = Enchantrix.Util.GetReagentPrice(result)
				-- use a zero value if no price is available (may happen for reagents you haven't seen)
				market = market or 0
				local marketPrice = market * yield
				marketTotal = marketTotal + marketPrice

				-- calculate costs
				if (get("util.itemsuggest.includedeposit")) then
					local _, itemid, itemsuffix, _, itemenchant, itemseed = decode(hyperlink)  -- lType, id, suffix, factor, enchant, seed
					local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
					local aadvdepcost = GetDepositCost(hyperlink, 24, nil, nil) or 0
					depositTotal = depositTotal + aadvdepcost * get("util.itemsuggest.relisttimes") * yield
				end
				if (get("util.itemsuggest.includebrokerage")) then
					brokerTotal = brokerTotal + marketPrice * brokerRate
				end
			end
		end

		local resaleTotal = marketTotal - depositTotal - brokerTotal
		ProspectValue = resaleTotal
	end

return ProspectValue end

function lib.GetVendorValue(hyperlink, quantity)
	VendorValue = GetSellValue and GetSellValue(hyperlink) or 0
	VendorValue = VendorValue * quantity
return VendorValue end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-ItemSuggest/Auc-Util-ItemSuggest.lua $", "$Rev: 3793 $")
