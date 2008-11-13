--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AuctioneerUI.lua 2505 2007-11-16 06:49:12Z RockSlice $

	Auctioneer UI manager

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

if (Auctioneer) then
	Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/UserInterface/AuctioneerUI.lua $", "$Rev: 2505 $")
end

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local onEvent;
local onAuctionUILoaded;
local onAuctionHouseShow;
local onAuctionHouseClose;
local preContainerFrameItemButtonOnModifiedClickHook;
--local postGetAuctionItemSubClasses
local postPickupContainerItemHook;
local getCursorContainerItem;
local relevelFrame;
local relevelFrames;
local insertAHTab;
local dropDownMenuInitialize;
local dropDownMenuSetSelectedID;
local debugPrint;

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Data members
-------------------------------------------------------------------------------
AuctioneerCursorItem = nil;

MoneyTypeInfo.AUCTIONEER = {
	UpdateFunc = function()
		return this.staticMoney;
	end,
	collapse = 1,
	fixedWidth = 1,
	showSmallerCoins = 1
};

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	-- Register for functions and methods we need locally.
--	Stubby.RegisterFunctionHook("PickupContainerItem", 200, postPickupContainerItemHook);
	hooksecurefunc("PickupContainerItem", postPickupContainerItemHook)

	-- register our hook to add the new trade skill sub classes to the AH
	--Stubby.RegisterFunctionHook("GetAuctionItemSubClasses", 200, postGetAuctionItemSubClasses)

	-- Blizzard's auction UI may or may not have been loaded yet.
	if (IsAddOnLoaded("Blizzard_AuctionUI")) then
		onAuctionUILoaded();
	else
		Stubby.RegisterEventHook("ADDON_LOADED", "Auctioneer_UI", onAddonLoaded);
	end
end

-------------------------------------------------------------------------------
-- Called on the ADDON_LOADED event.
-------------------------------------------------------------------------------
function onAddonLoaded(hookParams, event, addon)
	if (addon:lower() == "blizzard_auctionui") then
		onAuctionUILoaded();
	end
end

-------------------------------------------------------------------------------
-- Called when Auctioneer is loaded if Blizzard_AuctionUI is loaded. Otherwise
-- this method is called when we receive the ADDON_LOADED event for
-- Blizzard_AuctionUI.
-------------------------------------------------------------------------------
function onAuctionUILoaded()
	debugPrint("Loading auction house UI", DebugLib.Level.Info)

	-- Hook auction related functions and events we need locally.
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_UI", onAuctionHouseClose);
	Stubby.RegisterFunctionHook("AuctionFrame_Show", 200, onAuctionHouseShow);
	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -200, preContainerFrameItemButtonOnModifiedClickHook);

	-- Load Auctioneer's tabs.
	Auctioneer.UI.BrowseTab.Load();
	Auctioneer.UI.AuctionsTab.Load();
	Auctioneer.UI.SearchTab.Load();
	Auctioneer.UI.PostTab.Load();

	-- Protect the auction frame from being closed.
	-- This call is to ensure the window is protected even after you
	-- manually load Auctioneer while already showing the AuctionFrame
	if (Auctioneer.Command.GetFilterVal('protect-window') == 2) then
		Auctioneer.Util.ProtectAuctionFrame(true);
	end
end

-------------------------------------------------------------------------------
-- Called when the auction house opens.
-------------------------------------------------------------------------------
function onAuctionHouseShow()
	-- Protect the auction frame from being closed if we should
	if (Auctioneer.Command.GetFilterVal('protect-window') == 2) then
		Auctioneer.Util.ProtectAuctionFrame(true);
	end
end

-------------------------------------------------------------------------------
-- Called when the auction house closes.
-------------------------------------------------------------------------------
function onAuctionHouseClose()
	-- Unprotect the auction frame
	Auctioneer.Util.ProtectAuctionFrame(false);
end

-------------------------------------------------------------------------------
-- Called before Blizzard's ContainerFrameItemButton_OnClick()
-------------------------------------------------------------------------------
function preContainerFrameItemButtonOnModifiedClickHook(hookParams, returnValue, button, ignoreShift)
	local bag = this:GetParent():GetID()
	local slot = this:GetID()

	local texture, count, noSplit = GetContainerItemInfo(bag, slot)
	local link = GetContainerItemLink(bag, slot)
	if (count and count > 1 and not noSplit) then
		if (button == "RightButton") and (IsControlKeyDown()) then
			local splitCount = math.floor(count / 2)
			local emptyBag, emptySlot = Auctioneer.Util.FindEmptySlot()
			if (emptyBag) then
				SplitContainerItem(bag, slot, splitCount)
				PickupContainerItem(emptyBag, emptySlot)
			else
				chatPrint("Can't split, all bags are full")
			end
			return "abort";
		end
	end

	if (AuctionFrame and AuctionFrame:IsVisible()) then
		if (link) then
			if (button == "RightButton") and (IsAltKeyDown()) then
				AuctionFrameTab_OnClick(1)
				local itemID = EnhTooltip.BreakLink(link)
				if (itemID) then
					local itemName = GetItemInfo(tostring(itemID))
					if (itemName) then
						BrowseName:SetText(itemName)
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
						AuctionFrameBrowse_Search()
						BrowseNoResultsText:SetText(BROWSE_NO_RESULTS)
					end
				end
				return "abort";
			end
		end
	end

	if (not CursorHasItem() and AuctionFrameAuctions and AuctionFrameAuctions:IsVisible() and IsAltKeyDown()) then
		PickupContainerItem(bag, slot)
		if (CursorHasItem() and Auctioneer.Command.GetFilter('auction-click')) then
			ClickAuctionSellItemButton()
			AuctionsFrameAuctions_ValidateAuction()
			local start = MoneyInputFrame_GetCopper(StartPrice)
			local buy = MoneyInputFrame_GetCopper(BuyoutPrice)
			local duration = AuctionFrameAuctions.duration
			local warn = AuctionInfoWarnText:GetText()
			if (AuctionsCreateAuctionButton:IsEnabled() and IsShiftKeyDown()) then
				local cHex, cRed, cGreen, cBlue = Auctioneer.Util.GetWarnColor(warn)
				warn = ("|c"..cHex..warn.."|r")
				StartAuction(start, buy, duration);
				chatPrint(_AUCT('FrmtAutostart'):format(link, EnhTooltip.GetTextGSC(start), EnhTooltip.GetTextGSC(buy), duration/60, warn));
			end
			return "abort";
		end
	end

	if (not CursorHasItem() and AuctionFramePost and AuctionFramePost:IsVisible() and button == "LeftButton" and IsAltKeyDown()) then
		local _, count = GetContainerItemInfo(bag, slot);
		if (count) then
			if (count > 1 and IsShiftKeyDown()) then
				this.SplitStack = function(button, split)
					AuctionFramePost:SetAuctionItem(bag, slot, split);
				end
				OpenStackSplitFrame(count, this, "BOTTOMRIGHT", "TOPRIGHT");
			else
				AuctionFramePost:SetAuctionItem(bag, slot, 1);
			end
			return "abort";
		end
	end
end

-------------------------------------------------------------------------------
-- Called after Blizzard's PickupContainerItem() method in order to capture
-- which item is on the cursor.
-------------------------------------------------------------------------------
function postPickupContainerItemHook(bag, slot)
	if (CursorHasItem()) then
		AuctioneerCursorItem = { bag = bag, slot = slot };
	else
		AuctioneerCursorItem = nil;
	end
	getCursorContainerItem();
end

-------------------------------------------------------------------------------
-- Gets the bag and slot number of the item on the cursor.
-------------------------------------------------------------------------------
function getCursorContainerItem()
	if (CursorHasItem() and AuctioneerCursorItem) then
		return AuctioneerCursorItem;
	end
	return nil;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function relevelFrame(frame)
	return relevelFrames(frame:GetFrameLevel() + 2, frame:GetChildren())
end

function relevelFrames(myLevel, ...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:SetFrameLevel(myLevel)
		relevelFrame(child)
	end
end

-------------------------------------------------------------------------------
-- Adds a tab to the auction house.
-------------------------------------------------------------------------------
function insertAHTab(tabButton, tabFrame)
	-- Count the number of auction house tabs (including the tab we are going
	-- to insert).
	local tabCount = 1;
	while (getglobal("AuctionFrameTab"..(tabCount))) do
		tabCount = tabCount + 1;
	end

	-- Find the correct location to insert our Search Auctions and Post Auctions
	-- tabs. We want to insert them at the end or before BeanCounter's
	-- Transactions tab.
	local tabIndex = 1;
	while (getglobal("AuctionFrameTab"..(tabIndex)) and
		   getglobal("AuctionFrameTab"..(tabIndex)):GetName() ~= "AuctionFrameTabTransactions") do
		tabIndex = tabIndex + 1;
	end

	-- Make room for the tab, if needed.
	for index = tabCount, tabIndex + 1, -1  do
		setglobal("AuctionFrameTab"..(index), getglobal("AuctionFrameTab"..(index - 1)));
		getglobal("AuctionFrameTab"..(index)):SetID(index);
	end

	-- Configure the frame.
	tabFrame:SetParent("AuctionFrame");
	tabFrame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 0, 0);
	relevelFrame(tabFrame);

	-- Configure the tab button.
	setglobal("AuctionFrameTab"..tabIndex, tabButton);
	tabButton:SetParent("AuctionFrame");
	tabButton:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(tabIndex - 1)):GetName(), "TOPRIGHT", -8, 0);
	tabButton:SetID(tabIndex);
	tabButton:Show();

	-- If we inserted a tab in the middle, adjust the layout of the next tab button.
	if (tabIndex < tabCount) then
		nextTabButton = getglobal("AuctionFrameTab"..(tabIndex + 1));
		nextTabButton:SetPoint("TOPLEFT", tabButton:GetName(), "TOPRIGHT", -8, 0);
	end

	-- Update the tab count.
	PanelTemplates_SetNumTabs(AuctionFrame, tabCount)
end

-------------------------------------------------------------------------------
-- Wrapper for UIDropDownMenu_Initialize() that sets 'this' before calling
-- UIDropDownMenu_Initialize().
-------------------------------------------------------------------------------
function dropDownMenuInitialize(dropdown, func)
	-- Hide all the buttons to prevent any calls to Hide() inside
	-- UIDropDownMenu_Initialize() which will screw up the value of this.
	local button, dropDownList;
	for i = 1, UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = getglobal("DropDownList"..i);
		if ( i >= UIDROPDOWNMENU_MENU_LEVEL or dropdown:GetName() ~= UIDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = getglobal("DropDownList"..i.."Button"..j);
				button:Hide();
			end
		end
	end

	-- Call the UIDropDownMenu_Initialize() after swapping in a value for 'this'.
	local oldThis = this;
	this = getglobal(dropdown:GetName().."Button");
	local newThis = this;
	UIDropDownMenu_Initialize(dropdown, func);
	-- Double check that the value of 'this' didn't change... this can screw us
	-- up and prevent the reason for this method!
	if (newThis ~= this) then
		debugPrint("WARNING: The value of this changed during dropDownMenuInitialize()", DebugLib.Level.Warning)
	end
	this = oldThis;
end

-------------------------------------------------------------------------------
-- Wrapper for UIDropDownMenu_SetSeletedID() that sets 'this' before calling
-- UIDropDownMenu_SetSelectedID().
-------------------------------------------------------------------------------
function dropDownMenuSetSelectedID(dropdown, index)
	local oldThis = this;
	this = dropdown;
	local newThis = this;
	UIDropDownMenu_SetSelectedID(dropdown, index);
	-- Double check that the value of 'this' didn't change... this can screw us
	-- up and prevent the reason for this method!
	if (newThis ~= this) then
		debugPrint("WARNING: The value of this changed during dropDownMenuSetSelectedID()", DebugLib.Level.Warning)
	end
	this = oldThis;
end

-------------------------------------------------------------------------------
-- Designed to change the return value of GetAuctionItemSubClasses() and that
-- way extend the AH to add sub classes for trade goods.
--
-- parameters:
--    _     - ignoring the first parameter, which is an empty table, since no
--            parameters are passed when registering this function with
--            Stubby (see Stubby.RegisterFunctionHook() for more details)
--    _     - ignoring the second parameter, which is an empty table, since the
--            original function was not yet called
--            (see Stubby.RegisterFunctionHook() for more details)
--    index - (number) the index of the class for which the function should
--            return the subcategories
--
-- returns:
--    first value:
--       "setreturn", always
--    second value:
--       always localised (based on the client's language) strings in the form:
--       {"Trade Goods", "Parts", "Explosives", "Devices"}
-------------------------------------------------------------------------------
--[[
function postGetAuctionItemSubClasses(_, _, index)
	if (index == 5) then
		return "setreturn", {_AUCT("SubClassTradeGoods", GetLocale()),
		                     _AUCT("SubClassParts",      GetLocale()),
		                     _AUCT("SubClassExplosives", GetLocale()),
		                     _AUCT("SubClassDevices",    GetLocale())}
	end
end
]]
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
	return Auctioneer.Util.DebugPrint(message, "AuctioneerUI", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
-- AuctioneerUI.lua is used by BeanCounter, therefore we have to treat this
-- specially
if not Auctioneer then
	Auctioneer = {}
end
if (Auctioneer.UI) then return end;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.UI = {
	Load = load;
	InsertAHTab = insertAHTab;
	GetCursorContainerItem = getCursorContainerItem;
	DropDownMenu =
	{
		Initialize = dropDownMenuInitialize;
		SetSelectedID = dropDownMenuSetSelectedID;
	};
};
