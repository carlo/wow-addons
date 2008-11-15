--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: Mail-GUI.lua 3663 2008-10-20 14:28:27Z kandoko $
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

---------------------------------------------------------
-- Set ID's for ease of lookup
---------------------------------------------------------
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
local DEEPPERIDOT = 23079
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

---------------------------------------------------------
-- Mail Functions
---------------------------------------------------------
function lib.gemAction()
	MailFrameTab_OnClick(nil, 2)
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
	MailFrameTab_OnClick(nil, 2)
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

function lib.disenchantAction()
	MailFrameTab_OnClick(nil, 2)
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
				if (AucAdvanced.Modules.Util.ItemSuggest and get("util.automagic.overidebtmmail") == true) then
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
							print("AutoMagic has loaded", itemName, " due to", text ,"Rule(Disenchant)")
						end
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function lib.prospectAction()
	MailFrameTab_OnClick(nil, 2)
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
				if (AucAdvanced.Modules.Util.ItemSuggest and get("util.automagic.overidebtmmail") == true) then
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

---------------------------------------------------------
-- Mail Interface
---------------------------------------------------------
lib.ammailgui = CreateFrame("Frame", "", UIParent); lib.ammailgui:Hide()
function lib.makeMailGUI()
	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	lib.ammailgui:ClearAllPoints()
	lib.ammailgui:SetPoint("CENTER", UIParent, "BOTTOMLEFT", get("util.automagic.ammailguix"), get("util.automagic.ammailguiy"))
	lib.ammailgui:SetFrameStrata("DIALOG")
	lib.ammailgui:SetHeight(75)
	lib.ammailgui:SetWidth(240)
	lib.ammailgui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	lib.ammailgui:SetBackdropColor(0,0,0, 0.8)
	lib.ammailgui:EnableMouse(true)
	lib.ammailgui:SetMovable(true)
	lib.ammailgui:SetClampedToScreen(true)

	-- Make highlightable drag bar
	lib.ammailgui.Drag = CreateFrame("Button", "", lib.ammailgui)
	lib.ammailgui.Drag:SetPoint("TOPLEFT", lib.ammailgui, "TOPLEFT", 10,-5)
	lib.ammailgui.Drag:SetPoint("TOPRIGHT", lib.ammailgui, "TOPRIGHT", -10,-5)
	lib.ammailgui.Drag:SetHeight(6)
	lib.ammailgui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	lib.ammailgui.Drag:SetScript("OnMouseDown", function() lib.ammailgui:StartMoving() end)
	lib.ammailgui.Drag:SetScript("OnMouseUp", function() lib.ammailgui:StopMovingOrSizing() end)
	lib.ammailgui.Drag:SetScript("OnEnter", function() lib.buttonTooltips( lib.ammailgui.Drag, "Click and drag to reposition window.") end)
	lib.ammailgui.Drag:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- Text Header
	lib.mguiheader = lib.ammailgui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	lib.mguiheader:SetText("AutoMagic: Mail Loader")
	lib.mguiheader:SetJustifyH("CENTER")
	lib.mguiheader:SetWidth(200)
	lib.mguiheader:SetHeight(10)
	lib.mguiheader:SetPoint("TOPLEFT",  lib.ammailgui, "TOPLEFT", 0, 0)
	lib.mguiheader:SetPoint("TOPRIGHT", lib.ammailgui, "TOPRIGHT", 0, 0)
	lib.ammailgui.mguiheader = lib.mguiheader

	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)


	lib.mguibtmrules = lib.ammailgui:CreateFontString(two, "OVERLAY", "NumberFontNormalYellow")
	lib.mguibtmrules:SetText("BTM/IS Rule:")
	lib.mguibtmrules:SetJustifyH("LEFT")
	lib.mguibtmrules:SetWidth(101)
	lib.mguibtmrules:SetHeight(10)
	lib.mguibtmrules:SetPoint("TOPLEFT",  lib.ammailgui, "TOPLEFT", 8, -16)
	lib.ammailgui.mguibtmrules = lib.mguibtmrules

	lib.ammailgui.loadde = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadde:SetText(("Disenchant"))
	lib.ammailgui.loadde:SetPoint("TOPLEFT", lib.mguibtmrules, "BOTTOMLEFT", 0, 1)
	lib.ammailgui.loadde:SetScript("OnClick", lib.disenchantAction)
	lib.ammailgui.loadde:SetScript("OnEnter", function() lib.buttonTooltips( lib.ammailgui.loadde, "Add all items tagged \nfor DE to the mail.") end)
	lib.ammailgui.loadde:SetScript("OnLeave", function() GameTooltip:Hide() end)

--[[	lib.ammailgui.mailto = CreateFrame("EditBox", "", lib.ammailgui, "InputBoxTemplate")
	lib.ammailgui.mailto:SetPoint("TOPLEFT", lib.ammailgui.loaddemats, "BOTTOMRIGHT", 0, -12)
	lib.ammailgui.mailto:SetAutoFocus(false)
	lib.ammailgui.mailto:SetHeight(15)
	lib.ammailgui.mailto:SetWidth(100)
	lib.ammailgui.mailto:SetMaxLetters(12)
	--lib.ammailgui.loaddemailto:SetScript("OnEnterPressed", silvertocopper)
	--lib.ammailgui.loaddemailto:SetScript("OnTabPressed", silvertocopper)

	lib.mguimailtotxt = lib.ammailgui:CreateFontString(four, "OVERLAY", "NumberFontNormalYellow")
	lib.mguimailtotxt:SetText("Set Recipiant to:")
	lib.mguimailtotxt:SetJustifyH("LEFT")
	lib.mguimailtotxt:SetWidth(101)
	lib.mguimailtotxt:SetHeight(10)
	lib.mguimailtotxt:SetPoint("TOPRIGHT",  lib.ammailgui.mailto, "TOPLEFT", 0, -25)
	--lib.mguimailfor:SetPoint("TOPRIGHT", lib.ammailgui.loadprospect, "BOTTOMRIGHT", 0, 0)
	lib.ammailgui.mguimailtotxt = lib.mguimailtotxt]]

	lib.ammailgui.loadprospect = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadprospect:SetText(("Prospect"))
	lib.ammailgui.loadprospect:SetPoint("TOPLEFT", lib.ammailgui.loadde, "BOTTOMLEFT", 0, 0)
	lib.ammailgui.loadprospect:SetScript("OnClick", lib.prospectAction)
	lib.ammailgui.loadprospect:SetScript("OnEnter", function() lib.buttonTooltips( lib.ammailgui.loadprospect, "Add all items tagged \nfor Prospect to the mail.") end)
	lib.ammailgui.loadprospect:SetScript("OnLeave", function() GameTooltip:Hide() end)

	lib.mguimailfor = lib.ammailgui:CreateFontString(three, "OVERLAY", "NumberFontNormalYellow")
	lib.mguimailfor:SetText("Misc:")
	lib.mguimailfor:SetJustifyH("LEFT")
	lib.mguimailfor:SetWidth(101)
	lib.mguimailfor:SetHeight(10)
	lib.mguimailfor:SetPoint("TOPLEFT",  lib.mguibtmrules, "TOPRIGHT", 25, 0)
	--lib.mguimailfor:SetPoint("TOPRIGHT", lib.ammailgui.loadprospect, "BOTTOMRIGHT", 0, 0)
	lib.ammailgui.mguimailfor = lib.mguimailfor

	lib.ammailgui.loadgems = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadgems:SetText(("Gems"))
	lib.ammailgui.loadgems:SetPoint("TOPLEFT", lib.mguimailfor, "BOTTOMLEFT", 0, 0)
	lib.ammailgui.loadgems:SetScript("OnClick", lib.gemAction)
	lib.ammailgui.loadgems:SetScript("OnEnter", function() lib.buttonTooltips( lib.ammailgui.loadgems, "Add all Gems to the mail.") end)
	lib.ammailgui.loadgems:SetScript("OnLeave", function() GameTooltip:Hide() end)

	lib.ammailgui.loaddemats = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loaddemats:SetText(("Chant Mats"))
	lib.ammailgui.loaddemats:SetPoint("TOPLEFT", lib.ammailgui.loadgems, "BOTTOMLEFT", 0, 0)
	lib.ammailgui.loaddemats:SetScript("OnClick", lib.dematAction)
	lib.ammailgui.loaddemats:SetScript("OnEnter", function() lib.buttonTooltips( lib.ammailgui.loaddemats, "Add all Enchanting mats \nto the mail.") end)
	lib.ammailgui.loaddemats:SetScript("OnLeave", function() GameTooltip:Hide() end)


end
AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-AutoMagic/Mail-GUI.lua $", "$Rev: 3663 $")
