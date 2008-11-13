--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AuctionFrameBrowse.lua 2469 2007-11-14 06:08:37Z jslagle $

	Auctioneer Browse tab

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
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/UserInterface/AuctionFrameBrowse.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local postFilterButtonSetTypeHook;
local postAuctionFrameFiltersUpdateClassesHook;
local nextButtonHook, prevButtonHook;
local queryForItemByName;
local debugPrint;

local DebugLib = Auctioneer.Util.DebugLib

local function nextButton(...)
	if (IsModifierKeyDown()) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		local curPage = AuctionFrameBrowse.page
		local pages = totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE
		if (IsControlKeyDown()) then
			-- Jump ahead to the end
			AuctionFrameBrowse.page = pages - 1
		elseif (IsAltKeyDown()) then
			AuctionFrameBrowse.page = math.min(pages - 1, AuctionFrameBrowse.page + 9)
		elseif (IsShiftKeyDown()) then
			AuctionFrameBrowse.page = math.min(pages - 1, AuctionFrameBrowse.page + 4)
		end
	end
	return nextButtonHook(...)
end

local function prevButton(...)
	if (IsModifierKeyDown()) then
		local curPage = AuctionFrameBrowse.page
		if (IsControlKeyDown()) then
			-- Jump back to the start
			AuctionFrameBrowse.page = 1
		elseif (IsAltKeyDown()) then
			AuctionFrameBrowse.page = math.min(1, AuctionFrameBrowse.page - 9)
		elseif (IsShiftKeyDown()) then
			AuctionFrameBrowse.page = math.min(1, AuctionFrameBrowse.page - 4)
		end
	end
	return prevButtonHook(...)
end

local function showTooltip(obj)
	local tooltip = obj.tooltip
	GameTooltip:SetOwner(obj, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(tooltip)
	GameTooltip:Show()
end

local function hideTooltip()
	GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	debugPrint("Loading", DebugLib.Level.Info)

	BrowseScanButton:SetText(_AUCT('TextScan'));
	BrowseScanButton:SetParent("AuctionFrameBrowse");
	BrowseScanButton:SetPoint("LEFT", "AuctionFrameMoneyFrame", "RIGHT", 5,0);
	BrowseScanButton:Show();

	BrowseClearButton.tooltip = _AUCT('ClearTooltip')
	BrowseClearButton:SetText(" ");
	BrowseClearButton:SetParent("AuctionFrameBrowse");
	BrowseClearButton:SetNormalTexture("Interface\\AddOns\\Auctioneer\\Textures\\Clear.tga");
	BrowseClearButton:SetHighlightTexture("Interface\\AddOns\\Auctioneer\\Textures\\Clear.tga");
	BrowseClearButton:SetPushedTexture("Interface\\AddOns\\Auctioneer\\Textures\\Clear.tga");
	BrowseClearButton:SetPoint("TOPLEFT", "AuctionFrameBrowse", "TOPLEFT", 80, -16);
	BrowseClearButton:SetScript("OnEnter", showTooltip);
	BrowseClearButton:SetScript("OnLeave", hideTooltip);
	BrowseClearButton:Show();

	BrowseRefreshButton.tooltip = _AUCT('RefreshTooltip')
	BrowseRefreshButton:SetText(" ");
	BrowseRefreshButton:SetParent("AuctionFrameBrowse");
	BrowseRefreshButton:SetNormalTexture("Interface\\AddOns\\Auctioneer\\Textures\\Refresh.tga");
	BrowseRefreshButton:SetHighlightTexture("Interface\\AddOns\\Auctioneer\\Textures\\Refresh.tga");
	BrowseRefreshButton:SetPushedTexture("Interface\\AddOns\\Auctioneer\\Textures\\Refresh.tga");
	BrowseRefreshButton:SetPoint("LEFT", "BrowseClearButton", "RIGHT", 5,0);
	BrowseRefreshButton:SetScript("OnEnter", showTooltip);
	BrowseRefreshButton:SetScript("OnLeave", hideTooltip);
	BrowseRefreshButton:Show();

	BrowseBuySortButton.tooltip = _AUCT('BuySortTooltip')
	BrowseBuySortButton:SetText(" ");
	BrowseBuySortButton:SetParent("AuctionFrameBrowse");
	BrowseBuySortButton:SetNormalTexture("Interface\\AddOns\\Auctioneer\\Textures\\Sort.tga");
	BrowseBuySortButton:SetHighlightTexture("Interface\\AddOns\\Auctioneer\\Textures\\Sort.tga");
	BrowseBuySortButton:SetPushedTexture("Interface\\AddOns\\Auctioneer\\Textures\\Sort.tga");
	BrowseBuySortButton:SetPoint("LEFT", "BrowseRefreshButton", "RIGHT", 5,0);
	BrowseBuySortButton:SetScript("OnEnter", showTooltip);
	BrowseBuySortButton:SetScript("OnLeave", hideTooltip);
	BrowseBuySortButton:Show();

	nextButtonHook = BrowseNextPageButton:GetScript("OnClick")
	BrowseNextPageButton:SetScript("OnClick", nextButton);
	prevButtonHook = BrowsePrevPageButton:GetScript("OnClick")
	BrowsePrevPageButton:SetScript("OnClick", prevButton);

	-- Register for events and hook methods.
	Stubby.RegisterFunctionHook("FilterButton_SetType", 200, postFilterButtonSetTypeHook);
	Stubby.RegisterFunctionHook("AuctionFrameFilters_UpdateClasses", 200, postAuctionFrameFiltersUpdateClassesHook);

	AuctionFrameFilters_UpdateClasses();
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function postFilterButtonSetTypeHook(_, _, button, type, text, isLast)
	local buttonName = button:GetName();
	local buttonID = buttonName:match("(%d+)$");
	buttonID = tonumber(buttonID);

	local checkbox = getglobal(buttonName.."Checkbox");
	if checkbox then
		if (type == "class") then
			local classid, maxid = Auctioneer.Command.FindFilterClass(text);
			if (classid > 0) then
				Auctioneer.Command.FilterSetFilter(checkbox, "scan-class"..classid);
				if (classid == maxid) and (buttonID < 15) then
					for i=buttonID+1, 15 do
						getglobal("AuctionFilterButton"..i):Hide();
					end
				end
			else
				checkbox:Hide();
			end
		else
			checkbox:Hide();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function postAuctionFrameFiltersUpdateClassesHook()
	local obj
	for i=1, 15 do
		obj = getglobal("AuctionFilterButton"..i.."Checkbox")
		if (obj) then
			obj:SetParent("AuctionFilterButton"..i)
			obj:SetPoint("RIGHT", "AuctionFilterButton"..i, "RIGHT", -5,0)
		end
	end
end

-------------------------------------------------------------------------------
-- The OnClick handler for the BrowseScanButton.
-------------------------------------------------------------------------------
function BrowseScanButton_OnClick()
	Auctioneer.ScanManager.Scan();
end

-------------------------------------------------------------------------------
-- The OnClick handler for the BrowseResetButton.
-------------------------------------------------------------------------------
function BrowseClearButton_OnClick()
	BrowseName:SetText("")
	BrowseMinLevel:SetText("")
	BrowseMaxLevel:SetText("")
	AuctionFrameBrowse.selectedInvtype = nil
	AuctionFrameBrowse.selectedInvtypeIndex = nil
	AuctionFrameBrowse.selectedClass = nil
	AuctionFrameBrowse.selectedClassIndex = nil
	AuctionFrameBrowse.selectedSubclass = nil
	AuctionFrameBrowse.selectedSubclassIndex = nil
	AuctionFrameFilters_Update()
	IsUsableCheckButton:SetChecked(0)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
end

-------------------------------------------------------------------------------
-- The OnClick handler for the BrowseRefreshButton.
-------------------------------------------------------------------------------
function BrowseRefreshButton_OnClick()
	AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1
	prevButtonHook()
end

-------------------------------------------------------------------------------
-- The OnClick handler for the BrowseBuySortButton.
-------------------------------------------------------------------------------
function BrowseBuySortButton_OnClick()
	if (IsShiftKeyDown()) then
		SortAuctionItems("list", "name")
	else
		SortAuctionItems("list", "buyout")
	end
end

-------------------------------------------------------------------------------
-- Queries the auction house for the specified item name.
-------------------------------------------------------------------------------
function queryForItemByName(itemName)
	if (CanSendAuctionQuery()) then
		BrowseClearButton_OnClick()
		-- Search for the item and switch to the Browse tab.
		BrowseName:SetText(itemName)
		AuctionFrameBrowse_Search()
	end
end

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function debugPrint(message, title, errorCode, level)
	return Auctioneer.Util.DebugPrint(message, "AuctionFrameBrowse", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.UI.BrowseTab) then return end;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.UI.BrowseTab = {
	Load = load;
	QueryForItemByName = queryForItemByName;
};
