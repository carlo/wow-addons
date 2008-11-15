--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: ConfirmSellUI.lua 3776 2008-11-06 12:48:41Z Nayala $
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
local GetPrice = AucAdvanced.Modules.Util.Appraiser.GetPrice

local _, selected, selecteditem, selectedvendor, selectedappraiser, selectedwhy, selectedignored
local selecteddata = {}


function lib.ASCPrompt()
	local vendorcount = 0
	for k, v in pairs(lib.vendorlist) do
		vendorcount = vendorcount + 1
	end
	if vendorcount ~= 0 then
		lib.confirmsellui:Show()
		lib.ASCRefreshSheet()
	end
end

---------------------------------------------------------
-- Button Functions
---------------------------------------------------------
function lib.ASCConfirmContinue()
	for k, v in pairs(lib.vendorlist) do
		local bag, slot = strsplit(":", k)
		local iName, iID, iWhy = strsplit(":", v)
		if (get("util.automagic.chatspam")) then
			print("AutoMagic is selling:", iName, "due to", iWhy)
		end

		UseContainerItem(bag, slot)
		lib.vendorlist[k] = nil
	end
	lib.confirmsellui:Hide()
end

function lib.ASCRemoveItem()
	--print("REMOVE ", selecteditem, selectedvendor, selectedappraiser, selectedwhy)
end

function lib.ASCIgnoreItem()
	--print("IGNORE ", selecteditem, selectedvendor, selectedappraiser, selectedwhy)
end

function lib.ASCUnIgnoreItem()
	--print("UNIGNORE ", selecteditem, selectedvendor, selectedappraiser, selectedwhy)
end

---------------------------------------------------------
-- ScrollSheet Functions
---------------------------------------------------------
function lib.ASCRefreshSheet()  --- item / vendor / appraiser / why
	local ASCtempstorage = {}
	local GetPrice = AucAdvanced.Modules.Util.Appraiser.GetPrice
	for k, v in pairs(ASCtempstorage) do ASCtempstorage[k] = nil; end --Reset table to ensure fresh data.
	for k, v in pairs(lib.vendorlist) do
		local bag, slot = strsplit(":", k)
		local iName, iID, iWhy = strsplit(":", v)
		local vendorignored = "no (will-sell)"
		local _, itemLink, _, _, _, _, _, _, _, _ = GetItemInfo(iID)
		local	vendor = GetSellValue and GetSellValue(iID) or 0
		local abid,abuy = GetPrice(itemLink, nil, true)
		if (get("util.automagic.vidignored"..iID) and get("util.automagic.vidignored"..iID) == true) then
			local vendorignored = "yes (no-sell)"
		end

		table.insert(ASCtempstorage,{
			itemLink, --link form for mouseover tooltips to work
			vendor,
			tonumber(abuy) or tonumber(abid),
			iWhy,
			vendorignored,
		})
	end

	lib.confirmsellui.resultlist.sheet:SetData(ASCtempstorage, style) --Set the GUI scrollsheet
end

function lib.ASCOnEnter(button, row, index)
	if lib.confirmsellui.resultlist.sheet.rows[row][index]:IsShown()then --Hide tooltip for hidden cells
		local link, name
		link = lib.confirmsellui.resultlist.sheet.rows[row][index]:GetText()
		if not link then return end
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			AucAdvanced.ShowItemLink(GameTooltip, link, count)
			end
		end
	end

function lib.ASCOnLeave(button, row, index)
	GameTooltip:Hide()
end

function lib.ASCOnClick()
	--print("CLICK")
end


function lib.ASCSelect()
	--if selected ~= lib.confirmsellui.resultlist.sheet.selected then
		selected = lib.confirmsellui.resultlist.sheet.selected
		selecteddata = lib.confirmsellui.resultlist.sheet:GetSelection()
		selecteditem = selecteddata[1]
		selectedvendor = selecteddata[2]
		selectedappraiser = selecteddata[3]
		selectedwhy = selecteddata[4]
		selectedignored = selecteddata[5]
		--print("Select: ", selecteditem, selectedvendor, selectedappraiser, selectedwhy, selectedignored)
	--end
end
---------------------------------------------------------
-- Confirm AutoSell Interface
---------------------------------------------------------

local SelectBox = LibStub:GetLibrary("SelectBox")
local ScrollSheet = LibStub:GetLibrary("ScrollSheet")

lib.confirmsellui = CreateFrame("Frame", "confirmsellui", UIParent); lib.confirmsellui:Hide()
function lib.makeconfirmsellui()
	--function lib.makeconfirmsellui()
	lib.confirmsellui:ClearAllPoints()
	lib.confirmsellui:SetPoint("CENTER", UIParent, "CENTER", 1,1)
	lib.confirmsellui:SetFrameStrata("DIALOG")
	lib.confirmsellui:SetHeight(200)
	lib.confirmsellui:SetWidth(520)
	lib.confirmsellui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	lib.confirmsellui:SetBackdropColor(0,0,0, 0.8)
	lib.confirmsellui:EnableMouse(true)
	lib.confirmsellui:SetMovable(true)
	lib.confirmsellui:SetClampedToScreen(true)

	-- Make highlightable drag bar
	lib.confirmsellui.Drag = CreateFrame("Button", "", lib.confirmsellui)
	lib.confirmsellui.Drag:SetPoint("TOPLEFT", lib.confirmsellui, "TOPLEFT", 10,-5)
	lib.confirmsellui.Drag:SetPoint("TOPRIGHT", lib.confirmsellui, "TOPRIGHT", -10,-5)
	lib.confirmsellui.Drag:SetHeight(6)
	lib.confirmsellui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	lib.confirmsellui.Drag:SetScript("OnMouseDown", function() lib.confirmsellui:StartMoving() end)
	lib.confirmsellui.Drag:SetScript("OnMouseUp", function() lib.confirmsellui:StopMovingOrSizing() end)
	lib.confirmsellui.Drag:SetScript("OnEnter", function() lib.buttonTooltips( lib.confirmsellui.Drag, "Click and drag to reposition window") end)
	lib.confirmsellui.Drag:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- Text Header
	lib.confirmsellheader = lib.confirmsellui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	lib.confirmsellheader:SetText("AutoMagic: Confirm Pending Sales")
	lib.confirmsellheader:SetJustifyH("CENTER")
	lib.confirmsellheader:SetWidth(200)
	lib.confirmsellheader:SetHeight(10)
	lib.confirmsellheader:SetPoint("TOPLEFT",  lib.confirmsellui, "TOPLEFT", 0, 0)
	lib.confirmsellheader:SetPoint("TOPRIGHT", lib.confirmsellui, "TOPRIGHT", 0, 0)
	lib.confirmsellui.confirmsellheader = lib.confirmsellheader

	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)

	--Create the autosell list results frame
	lib.confirmsellui.resultlist = CreateFrame("Frame", nil, lib.confirmsellui)
	lib.confirmsellui.resultlist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})

	lib.confirmsellui.resultlist:SetBackdropColor(0, 0, 0.0, 0.5)
	lib.confirmsellui.resultlist:SetPoint("TOPLEFT", lib.confirmsellui, "TOPLEFT", 10, -10)
	lib.confirmsellui.resultlist:SetPoint("TOPRIGHT", lib.confirmsellui, "TOPRIGHT", -10, -10)
	lib.confirmsellui.resultlist:SetPoint("BOTTOM", lib.confirmsellui, "BOTTOM", 0, 30)

	lib.confirmsellui.resultlist.sheet = ScrollSheet:Create(lib.confirmsellui.resultlist, {
		{ ('Item:'), "TOOLTIP", 170 },
		{ "Vendor", "COIN", 70 },
		{ "Appraiser", "COIN", 70 },
		{ "Selling for", "TEXT", 70 },
		{ "Ignored?", "TEXT", 70,  { DESCENDING=true, DEFAULT=true } },
	}, lib.ASCOnEnter, lib.ASCOnLeave, lib.ASCOnClick, nil, lib.ASCSelect)

	lib.confirmsellui.resultlist.sheet:EnableSelect(true)

	-- Continue with sales button
	lib.confirmsellui.continueButton = CreateFrame("Button", nil, lib.confirmsellui, "OptionsButtonTemplate")
	lib.confirmsellui.continueButton:SetPoint("BOTTOMRIGHT", lib.confirmsellui, "BOTTOMRIGHT", -18, 10)
	lib.confirmsellui.continueButton:SetText(("Continue"))
	lib.confirmsellui.continueButton:SetScript("OnClick",  lib.ASCConfirmContinue)
	lib.confirmsellui.continueButton:SetScript("OnEnter", function() lib.buttonTooltips( lib.confirmsellui.continueButton, "Click to sell all listed items to vendor.") end)
	lib.confirmsellui.continueButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

	--[[ Remove item from sales button
	lib.confirmsellui.removeButton = CreateFrame("Button", nil, lib.confirmsellui, "OptionsButtonTemplate")
	lib.confirmsellui.removeButton:SetPoint("BOTTOMRIGHT", lib.confirmsellui.continueButton, "BOTTOMLEFT", -18, 0)
	lib.confirmsellui.removeButton:SetText(("Remove Item"))
	lib.confirmsellui.removeButton:SetScript("OnClick",  lib.ASCRemoveItem)
	lib.confirmsellui.removeButton:Disable()

	-- Ignore item from future sales
	lib.confirmsellui.ignoreButton = CreateFrame("Button", nil, lib.confirmsellui, "OptionsButtonTemplate")
	lib.confirmsellui.ignoreButton:SetPoint("BOTTOMRIGHT", lib.confirmsellui.removeButton, "BOTTOMLEFT", -18, 0)
	lib.confirmsellui.ignoreButton:SetText(("Ignore Item"))
	lib.confirmsellui.ignoreButton:SetScript("OnClick",  lib.ASCIgnoreItem)
	lib.confirmsellui.ignoreButton:Disable()

	-- Un-Ignore item from future sales
	lib.confirmsellui.unignoreButton = CreateFrame("Button", nil, lib.confirmsellui, "OptionsButtonTemplate")
	lib.confirmsellui.unignoreButton:SetPoint("BOTTOMRIGHT", lib.confirmsellui.ignoreButton, "BOTTOMLEFT", -18, 0)
	lib.confirmsellui.unignoreButton:SetText(("Un-Ignore Item"))
	lib.confirmsellui.unignoreButton:SetScript("OnClick",  lib.ASCUnIgnoreItem)
	lib.confirmsellui.unignoreButton:Disable()]]
end

lib.makeconfirmsellui()
AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-AutoMagic/ConfirmSellUI.lua $", "$Rev: 3776 $")
