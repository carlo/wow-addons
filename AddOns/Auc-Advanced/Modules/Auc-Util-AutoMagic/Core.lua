--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: Core.lua 3576 2008-10-10 03:07:13Z aesir $
	URL: http://auctioneeraddon.com/
	AutoMagic is an Auctioneer Advanced module.
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

local lib = AucAdvanced.Modules.Util.AutoMagic
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local AppraiserValue, DisenchantValue, ProspectValue, VendorValue, bestmethod, bestvalue, runstop, _


-- Setting mats and gems itemID's to something understandable
-- enchant mats
local VOID = 22450
local NEXUS = 20725
local LPRISMATIC = 22449
local LBRILLIANT = 14344
local LRADIANT = 11178
local LGLOWING = 11139
local LGLIMMERING = 11084
local SPRISMATIC = 22448
local SBRILLIANT = 14343
local SRADIANT = 11177
local SGLOWING = 11138
local SGLIMMERING = 10978
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
local ARCANE = 22445
local ILLUSION = 16204
local DREAM = 11176
local VISION = 11137
local SOUL = 11083
local STRANGE = 10940
-- gems
local TIGERSEYE = 818
local MALACHITE = 774
local SHADOWGEM = 1210
local LESSERMOONSTONE = 1705
local MOSSAGATE = 1206
local CITRINE = 3864
local JADE = 1529
local AQUAMARINE = 7909
local STARRUBY = 7910
local AZEROTHIANDIAMOND = 12800
local BLUESAPPHIRE = 12361
local LARGEOPAL = 12799
local HUGEEMERALD = 12364
local BLOODGARNET = 23077
local FLAMESPESSARITE = 21929
local GOLDENDRAENITE = 23112
local DEEPPERIDOT = 23709
local AZUREMOONSTONE = 23117
local SHADOWDRAENITE = 23107
local LIVINGRUBY = 23436
local NOBLETOPAZ = 23439
local DAWNSTONE = 23440
local TALASITE = 23427
local STAROFELUNE = 23428
local NIGHTSEYE = 23441

-- This table is validating that each ID within it is a gem from prospecting.
local isGem =
	{
	[TIGERSEYE] = true,
	[MALACHITE] = true,
	[SHADOWGEM] = true,
	[LESSERMOONSTONE] = true,
	[MOSSAGATE] = true,
	[CITRINE] = true,
	[JADE] = true,
	[AQUAMARINE] = true,
	[STARRUBY] = true,
	[AZEROTHIANDIAMOND] = true,
	[BLUESAPPHIRE] = true,
	[LARGEOPAL] = true,
	[HUGEEMERALD] = true,
	[BLOODGARNET] = true,
	[FLAMESPESSARITE] = true,
	[GOLDENDRAENITE] = true,
	[DEEPPERIDOT] = true,
	[AZUREMOONSTONE] = true,
	[SHADOWDRAENITE] = true,
	[LIVINGRUBY] = true,
	[NOBLETOPAZ] = true,
	[DAWNSTONE] = true,
	[TALASITE] = true,
	[STAROFELUNE] = true,
	[NIGHTSEYE] = true,
}

-- This table is validating that each ID within it is a mat from disenchanting.
local isDEMats =
	{
	[VOID] = true,
	[NEXUS] = true,
	[LPRISMATIC] = true,
	[LBRILLIANT] = true,
	[LRADIANT] = true,
	[LGLOWING] = true,
	[LGLIMMERING] = true,
	[SPRISMATIC] = true,
	[SBRILLIANT] = true,
	[SRADIANT] = true,
	[SGLOWING] = true,
	[SGLIMMERING] = true,
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
	[ARCANE] = true,
	[ILLUSION] = true,
	[DREAM] = true,
	[VISION] = true,
	[SOUL] = true,
	[STRANGE] = true,
}

lib.vendorlist = {}
function lib.vendorAction()
	lib.vendorlist = {} --this needs to be cleared and recalcuated on EVERY vendor open. Not just when we confirm a sell
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				runstop = 0  --Teslek, not sure why you are using this with elseif statements only one branch will be run anyways?
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink)
				if lib.autoSellList[ itemID ] then
					lib.vendorlist[bag..":"..slot] = itemName..":"..itemID..":Custom Add"
					runstop = 1
				elseif (get("util.automagic.autosellgrey") and itemRarity == 0 and runstop == 0) then
					lib.vendorlist[bag..":"..slot] = itemName..":"..itemID..":Grey"
					runstop = 1
				else --look for btmScan or SearchUI reason codes if above fails
					local reason, text = lib.getReason(itemLink, itemName, itemCount, "vendor")
					if reason and text then
						lib.vendorlist[bag..":"..slot] = itemName..":"..itemID..":"..text.."-vendor"
					end
				end
			end
		end
	end
	lib.ASCPrompt()
end

function lib.disenchantAction()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if (itemLink == nil) then return end
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				runstop = 0
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink)
				if (get("util.automagic.overidebtmmail") == true) then
					local aimethod = AucAdvanced.Modules.Util.ItemSuggest.itemsuggest(itemLink, itemCount)
					if(aimethod == "Disenchant") then
						if (get("util.automagic.chatspam")) then
							print("AutoMagic has loaded", itemName, " due to Item Suggest(Disenchant)")
						end
						UseContainerItem(bag, slot)
						runstop = 1
					end
				else --look for btmScan or SearchUI reason codes if above fails
					local reason, text = lib.getReason(itemLink, itemName, itemCount, "disenchant")
					if reason and text then
						if (get("util.automagic.chatspam")) then
							print("AutoMagic has loaded", itemName, " due to ",text ,"Rule(Disenchant)")
						end
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function lib.prospectAction()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if (itemLink == nil) then return end
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink)
				runstop = 0
				if (get("util.automagic.overidebtmmail") == true) then
					local aimethod = AucAdvanced.Modules.Util.ItemSuggest.itemsuggest(itemLink, itemCount)
					if(aimethod == "Prospect") then
						if (get("util.automagic.chatspam")) then
							print("AutoMagic has loaded", itemName, " due to Item Suggest(Prospect)")
						end
						UseContainerItem(bag, slot)
						runstop = 1
					end
				else --look for btmScan or SearchUI reason codes if above fails
					local reason, text = lib.getReason(itemLink, itemName, itemCount, "prospect")
					if reason and text then
						if (get("util.automagic.chatspam")) then
							print("AutoMagic has loaded", itemName, " due to", text ,"Rule(Prospect)")
						end
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function lib.gemAction()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if (itemLink == nil) then return end
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink)
				if isGem[ itemID ] then
					if (get("util.automagic.chatspam")) then
						print("AutoMagic has loaded", itemName, " because it is a gem!")
					end
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

function lib.dematAction()
	MailFrameTab_OnClick(2)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local itemLink, itemCount = GetContainerItemLink(bag,slot)
				if (itemLink == nil) then return end
				if itemCount == nil then _, itemCount = GetContainerItemInfo(bag, slot) end
				if itemCount == nil then itemCount = 1 end
				local _, itemID, _, _, _, _ = decode(itemLink)
				local itemName, _, itemRarity, _, _, _, _, _, _, _ = GetItemInfo(itemLink)
				if isDEMats[ itemID ] then
					if (get("util.automagic.chatspam")) then
						print("AutoMagic has loaded", itemName, " because it is a mat used for enchanting.")
					end
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

--Searches for reason and returns values if found nil other wise.
--Consolidates code into one function instead of 5-6 places that need editing/maintaining
function lib.getReason(itemLink, itemName, itemCount, text)
	if (BtmScan) then
		local bidlist = BtmScan.Settings.GetSetting("bid.list")
		if (bidlist) then
			local id, suffix, enchant, seed = BtmScan.BreakLink(itemLink)
			local sig = ("%d:%d:%d"):format(id, suffix, enchant)
			local bids = bidlist[sig..":"..seed.."x"..itemCount]

			if(bids and bids[1] and bids[1] == text) then
				return bids[1], "BTM"
			end
		end
	end

	if (BeanCounter and BeanCounter.API.isLoaded) then
		local reason = BeanCounter.API.getBidReason(itemLink, itemCount) or ""
		if reason:lower() == text then
			return reason, "SearchUI"
		end
	end

	return
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-AutoMagic/Core.lua $", "$Rev: 3576 $")
