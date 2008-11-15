--[[
	Auctioneer Advanced - Search UI - Searcher Converter
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: SearcherConverter.lua 3588 2008-10-12 14:56:31Z Norganna $
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Converter")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Converter"

local vendor, pctstring, value

-- Set our defaults
--Essences
local GPLANAR = 22446
local GETERNAL = 16203
local GNETHER = 11175
local GMYSTIC = 11135
local GASTRAL = 11082
local GMAGIC = 10939
local LPLANAR = 22447
local LETERNAL = 16202
local LNETHER = 11174
local LMYSTIC = 11134
local LASTRAL = 10998
local LMAGIC = 10938
--Motes/Primals
local PAIR = 22451
local MAIR = 22572
local PEARTH= 22452
local MEARTH = 22573
local PFIRE = 21884
local MFIRE = 22574
local PLIFE = 21886
local MLIFE = 22575
local PMANA = 22457
local MMANA = 22576
local PSHADOW = 22456
local MSHADOW = 22577
local PWATER = 21885
local MWATER = 22578
--Depleted items
local DCBRACER = 0
local DCBRACERTO = 32655	-- crystalweave bracers
local DMGAUNTLETS = 0
local DMGAUNTLETSTO = 32656	-- crystalhide handwraps
local DBADGE = 0
local DBADGETO = 32658			-- badge of tenacity
local DCLOAK = 32677
local DCLOAKTO = 32665 	-- crystalweave cape
local DDAGGER = 32673
local DDAGGERTO = 0	-- crystal-infused shiv
local DMACE = 0
local DMACETO = 32661	-- apexis crystal mace
local DRING = 32678
local DRINGTO = 0	-- dreamcrystal band
local DSTAFF = 0
local DSTAFFTO = 32662	-- flaming quartz staff
local DSWORD = 0
local DSWORDTO = 32660	-- crystalforged sword
local DTHAXE = 32676
local DTHAXETO = 32663	-- apexis cleaver

--Set convertable items table up
local convertableMat = {
	[GPLANAR] = true,
	[GETERNAL] = true,
	[GNETHER] = true,
	[GMYSTIC] = true,
	[GASTRAL] = true,
	[GMAGIC] = true,
	[LPLANAR] = true,
	[LETERNAL] = true,
	[LNETHER] = true,
	[LMYSTIC] = true,
	[LASTRAL] = true,
	[LMAGIC] = true,
	--[PAIR] = false,  leaving the placeholders for the primals but keeping them commented for possible future use
	[MAIR] = true,
	--[PEARTH] = false, 	-- Blacksmiths can convert them back
	[MEARTH] = true,
	--[PFIRE] = false,           -- Blacksmiths can convert them back
	[MFIRE] = true,
	--[PLIFE] = false,
	[MLIFE] = true,
	--[PMANA] = false,
	[MMANA] = true,
	--[PSHADOW]= false,
	[MSHADOW] = true,
	--[PWATER] = false,
	[MWATER] = true,
--	[DCBRACER] = true,   --depleted items are disabled until the function is completed and I have all the item id numbers for them and their converted items
--	[DMGAUNTLETS] = true,
--	[DBADGE] = true,
	[DCLOAK] = true,
--	[DDAGGER] = true,
--	[DMACE] = true,
--	[DRING] = true,
--	[DSTAFF] = true,
--	[DSWORD] = true,
	[DTHAXE] = true,
}

default("converter.profit.min", 1) --.......
default("converter.profit.pct", 50)--...................
default("converter.adjust.brokerage", true)--......................
default("converter.adjust.deposit", true)
default("converter.allow.bid", true)--....................
default("converter.allow.buy", true)--.................
default("converter.matching.check", true)--.................
default("converter.buyout.check", true)--.......................
default("converter.enableEssence", true)--................
default("converter.enableMote", true)--.....................
default("converter.enableDepleted", true)--................

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	-- Add the help
	gui:AddSearcher("Converter", "Search for items which can be converted into other items for profit (essences, motes, etc)", 100)
	gui:AddHelp(id, "converter searcher",
		"What does this searcher do?",
		"This searcher provides the ability to search for items that can be converted to another item which is worth more money.")

	local last = gui:GetLast(id)
	gui:AddControl(id, "Header",     0,      "Converter search criteria")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0, 1, "converter.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0, 11,  "converter.allow.buy", "Allow Buyouts")

	local last = gui:GetLast(id)
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "converter.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "converter.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")

	gui:AddControl(id, "Subhead",           0.0,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.0, 1, "converter.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.0, 1, "converter.adjust.deposit", "Subtract deposit cost")

	gui:SetLast(id, last)
	gui:AddControl(id, "Subhead",           0.42,  "Appraiser Value Origination")
	gui:AddControl(id, "Checkbox",          0.42, 1, "converter.matching.check", "Use Market Matched")
	gui:AddControl(id, "Checkbox",          0.42, 1, "converter.buyout.check", "Use buyout not bid")

	gui:SetLast(id, last)
	gui:AddControl(id, "Subhead",           0.76,   "Include in search")
	gui:AddControl(id, "Checkbox",          0.76, 1, "converter.enableEssence", "Essence <> lesser")
	gui:AddControl(id, "Checkbox",          0.76, 1, "converter.enableMote", "Mote > Primal")
	gui:AddControl(id, "Checkbox",          0.76, 1, "converter.enableDepleted", "Depleted Items")
end

function lib.Search(item)
	-- LINK ILEVEL ITYPE ISUB IEQUIP PRICE TLEFT TIME NAME TEXTURE
	-- COUNT QUALITY CANUSE ULEVEL MINBID MININC BUYOUT CURBID
	-- AMHIGH SELLER FLAG ID ITEMID SUFFIX FACTOR ENCHANT SEED

	if not convertableMat[item[Const.ITEMID]] then
		return false, "Item not convertable"
	end

	--get and set the item we are looking at's base appraiser value
	local convertsToValue = 0
	local convertToID = 0
	local newBid = 0
	local newBuy = 0
	local curModelText = "Unknown"
	local newBid, newBuy,_, curModelText = AucAdvanced.Modules.Util.Appraiser.GetPrice(item[Const.ITEMID], nil,get("conveter.matching.check"))
	local evalPrice = 0

	if newBuy == nil then newBuy = newBid end
	if newBuy == nil then
		return false, "No appraiser price"
	end

	if get("converter.buyout.check") then
		evalPrice = newBuy
	else
		evalPrice = newBid
	end

	--No appraiser price? Can't evaluate this item.
	if (evalPrice == nill or evalPrice == 0) then
		return false, "No appraiser price"
	end

	--get stack size we are dealing with
	local stackSize = item[Const.COUNT]

	-- set evalPrice to stack value for tooltip use
	local evalPrice = evalPrice * stackSize

		local convertsToL = {
		[GPLANAR] = true,
		[GETERNAL] = true,
		[GNETHER] = true,
		[GMYSTIC] = true,
		[GASTRAL] = true,
		[GMAGIC] = true,
	}

	if convertsToL[ item[Const.ITEMID] ] then
		--If category is disabled we are done here.
		if (not get("converter.enableEssence")) then
			return false, "Category disabled"
		end

		if item[Const.ITEMID] == GPLANAR then convertToID = LPLANAR end
		if item[Const.ITEMID] == GETERNAL then convertToID = LETERNAL end
		if item[Const.ITEMID] == GNETHER then convertToID = LNETHER end
		if item[Const.ITEMID] == GMYSTIC then convertToID = LMYSTIC end
		if item[Const.ITEMID] == GASTRAL then convertToID = LASTRAL end
		if item[Const.ITEMID] == GMAGIC then convertToID = LMAGIC end
				local newBid = 0
				local newBuy = 0
				local curModelText = "Unknown"
				local newBid, newBuy, _, curModelText = AucAdvanced.Modules.Util.Appraiser.GetPrice(convertToID, nil, get("converter.matching.check"))

				if newBuy == nil then newBuy = newBid end
				if newBuy == nil then
					return false, "No appraiser price for final product"
				end
				--update value since greater = 3 lesser ( lesser value *  3 = correct value of one greater )
				if get("converter.buyout.check") then
					convertsToValue = newBuy * 3
				else
					convertsToValue = newBid * 3
				end

				--Fail and end if appraiser has no value for the item we want to convert
				if (convertsToValue == nill or convertsToValue == 0) then
					return false, "No appraiser price for final product"
				end

			convertsToValue = convertsToValue * stackSize
		value = convertsToValue
	end

	local convertsToG = {
		[LPLANAR] = true,
		[LETERNAL] = true,
		[LNETHER] = true,
		[LMYSTIC] = true,
		[LASTRAL] = true,
		[LMAGIC] = true,
	}

	if convertsToG[ item[Const.ITEMID] ] then
		--If category is disabled we are done here.
		if (not get("converter.enableEssence")) then
			return false, "Category is disabled"
		end

		if item[Const.ITEMID] == LPLANAR then convertToID = GPLANAR end
		if item[Const.ITEMID] == LETERNAL then convertToID = GETERNAL end
		if item[Const.ITEMID] == LNETHER then convertToID = GNETHER end
		if item[Const.ITEMID] == LMYSTIC then convertToID = GMYSTIC end
		if item[Const.ITEMID] == LASTRAL then convertToID = GASTRAL end
		if item[Const.ITEMID] == LMAGIC then convertToID = GMAGIC end
				newBid = 0
				newBuy = 0
				curModelText = "Unknown"
				newBid, newBuy, _, curModelText = AucAdvanced.Modules.Util.Appraiser.GetPrice(convertToID, nil, get("converter.matching.check"))

				if newBuy == nil then newBuy = newBid end
				if newBuy == nil then
					return false, "No appraiser price for final product"
				end

				--update value since 3 lesser = 1 greater ( greater value /  3 = correct value of one lesser )
					if get("converter.buyout.check") then
						convertsToValue = newBuy / 3
					else
						convertsToValue = newBid / 3
					end
				--Fail and end if appraiser has no value for the item we want to convert
				if (convertsToValue == nill or convertsToValue == 0) then
					return false, "No appraiser price for final product"
				end
			convertsToValue = convertsToValue * stackSize

		value = convertsToValue
	end

	local convertsToP = {
		[MAIR] = true,
		[MEARTH] = true,
		[MFIRE] = true,
		[MLIFE] = true,
		[MMANA] = true,
		[MSHADOW] = true,
		[MWATER] = true,
	}

	if convertsToP[ item[Const.ITEMID] ] then
		--If category is disabled we are done here.
		if (not get("converter.enableMote")) then
			return false, "Category is disabled"
		end

		if item[Const.ITEMID] == MAIR then convertToID = PAIR end
		if item[Const.ITEMID] == MEARTH then convertToID = PEARTH end
		if item[Const.ITEMID] == MFIRE then convertToID = PFIRE end
		if item[Const.ITEMID] == MLIFE then convertToID = PLIFE end
		if item[Const.ITEMID] == MMANA then convertToID = PMANA end
		if item[Const.ITEMID] == MSHADOW then convertToID = PSHADOW end
		if item[Const.ITEMID] == MWATER then convertToID = PWATER end

				local newBid = 0
				local newBuy = 0
				local curModelText = "Unknown"
				local newBid, newBuy, _, curModelText = AucAdvanced.Modules.Util.Appraiser.GetPrice(convertToID, nil, get("converter.matching.check"))

				if newBuy == nil then newBuy = newBid end
				if newBuy == nil then
					return false, "No appraiser price for final product"
				end

			--update value since 10 motes = 1 primal do primal price / 10
					if get("converter.buyout.check") then
						convertsToValue = newBuy / 10
					else
						convertsToValue = newBid / 10
					end
				--Fail and end if appraiser has no value for the item we want to convert
				if (convertsToValue == nill or convertsToValue == 0) then
					return false, "No appraiser price for final product"
				end

			convertsToValue = convertsToValue * stackSize
		value = convertsToValue
	end

	local convertsFromDepleted = {
	--	[DCBRACER] = true,   --depleted items are disabled until the function is completed and I have all the item id numbers for them and their converted items
	--	[DMGAUNTLETS] = true,
	--	[DBADGE] = true,
	--	[DCLOAK] = true,
	--	[DDAGGER] = true,
	--	[DMACE] = true,
	--	[DRING] = true,
	--	[DSTAFF] = true,
	--	[DSWORD] = true,
		[DTHAXE] = true,
	}

	if convertsFromDepleted[ item[Const.ITEMID] ] then
		--If category is disabled we are done here.
		if (not get("converter.enableDepleted")) then
			return false, "Category is disabled"
		end

		if item[Const.ITEMID] == DCBRACER then convertToID = DCBRACERTO end
		if item[Const.ITEMID] == DMGAUNTLETS then convertToID = DMGAUNTLETSTO end
		if item[Const.ITEMID] == DBADGE then convertToID = DBADGETO end
		if item[Const.ITEMID] == DCLOAK then convertToID = DCLOAKTO end
		if item[Const.ITEMID] == DDAGGER then convertToID = DDAGGERTO end
		if item[Const.ITEMID] == DMACE then convertToID = DMACETO end
		if item[Const.ITEMID] == DRING then convertToID = DRINGTO end
		if item[Const.ITEMID] == DSTAFF then convertToID = DSTAFFTO end
		if item[Const.ITEMID] == DSWORD then convertToID = DSWORDTO end
		if item[Const.ITEMID] == DTHAXE then convertToID = DTHAXETO end

				newBid = 0
				newBuy = 0
				curModelText = "Unknown"
				newBid, newBuy, _, curModelText = AucAdvanced.Modules.Util.Appraiser.GetPrice(convertToID, nil, get("converter.matching.check"))

				if newBuy == nil then newBuy = newBid end
				if newBuy == nil then
					return false, "No appraiser price for final product"
				end

			--update value 1 depleted = 1 non depleted item (meaning no modified to newbid or buy below)
				if get("converter.buyout.check") then
					convertsToValue = newBuy
				else
					convertsToValue = newBid
				end
				--Fail and end if appraiser has no value for the item we want to convert
				if (convertsToValue == nill or convertsToValue == 0) then
					return false, "No appraiser price for final product"
				end
			convertsToValue = convertsToValue * stackSize
		value = convertsToValue
	end

	--adjust for brokerage/deposit costs
	local deposit = get("converter.adjust.deposit")
	local brokerage = get("converter.adjust.brokerage")

	if brokerage then
		value = value * 0.95
	end
	if deposit then
		local rate = AucAdvanced.depositRate or 0.05
		local newfaction
		if rate == .25 then newfaction = "neutral" end
		local amount = GetDepositCost(item[Const.LINK], 12, newfaction, item[Const.COUNT])
		if not amount then
			amount = 0
		else
			amount = amount
		end
		value = value - amount
	end

	local pct = get("converter.profit.pct")
	local minprofit = get("converter.profit.min")
	local market = value
	value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end

	--Return bid or buy if item is below the searchers evaluated value
	if get("converter.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		return "buy", market
	elseif get("converter.allow.bid") and (item[Const.PRICE] <= value) then
		return "bid", market
	end
	return false, "Not enough profit"
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-SearchUI/SearcherConverter.lua $", "$Rev: 3588 $")
