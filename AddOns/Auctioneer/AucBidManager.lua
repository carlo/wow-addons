--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucBidManager.lua 2469 2007-11-14 06:08:37Z jslagle $

	BidManager - manages bid requests in the AH

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
]]

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucBidManager.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------
local chatPrint = Auctioneer.Util.ChatPrint;

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local onEventHook;
local prePlaceAuctionBidHook;
local placeAuctionBid;
local showingConfirmation;
local bidConfirmed;
local getBidAmmount
local isBidAllowed;
local isBidInProgress;
local addPendingBid;
local removePendingBid;
local isPendingBidForAuction;
local debugPrint
local onAHClosed

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------

-- Queue of bids submitted to the server, but not yet accepted or rejected
local PendingBids = {};

-- True if PlaceAuctionBid calls should be hooked. This is always the case
-- unless Auctioneer wants to call it. Setting this to false effectively
-- unhooks the method.
local hookPlaceAuctionBid = true;

-- True if the confirmation popup is showing, false otherwise
local showingConfirmationFlag = false;

-- The following variables are used to temporarily store the information
-- of the bid/buyout awaiting confirmation
local currentListType, currentIndex, currentBid, currentCallbackFunc

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
BidResultCodes = {
	BidAccepted = "BidAccepted";
	BidCanceled = "BidCanceled";
	ItemNotFound = "ItemNotFound";
	NotEnoughMoney = "NotEnoughMoney";
	OwnAuction = "OwnAuction";
	AlreadyHigherBid = "AlreadyHigherBid";
	AlreadyHighBidder = "AlreadyHighBidder";
	MaxItemCount = "MaxItemCount";
}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	Stubby.RegisterFunctionHook("PlaceAuctionBid", -200, prePlaceAuctionBidHook)

	StaticPopupDialogs["AUCTIONEER_BIDORBUYOUT_AUCTION"] = {
		text = BUYOUT_AUCTION_CONFIRMATION,
		button1 = ACCEPT,
		button2 = CANCEL,

		OnAccept = function()
			-- Bid was confirmed
			Auctioneer.BidManager.BidConfirmed()
		end,
		
		OnCancel = function()
			-- Bid was canceled by user
			Auctioneer.BidManager.BidCanceled()
		end,

		OnShow = function()
			-- Modify CanSendAuctionQuery() return value
			Auctioneer.BidManager.ShowingConfirmation(true)

			-- Update money field
			MoneyFrame_Update(this:GetName().."MoneyFrame", Auctioneer.BidManager.GetBidAmmount());

			-- Autoclose, if the AH is closed
			Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_BidManager", onAHClosed);
		end,

		OnHide = function()
			-- Restore CanSendAuctionQuery()'s return value
			Auctioneer.BidManager.ShowingConfirmation(false)

			-- Remove autoclose hook
			Stubby.UnregisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_BidManager")
		end,

		hasMoneyFrame = 1,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		hideOnEscape = 1
	};
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function onEventHook(_, event, message)
	if (event == "CHAT_MSG_SYSTEM" and message) then
		if (message == ERR_AUCTION_BID_PLACED) then
		 	removePendingBid(BidResultCodes.BidAccepted);
		end
	elseif (event == "UI_ERROR_MESSAGE" and message) then
		if (message == ERR_ITEM_NOT_FOUND) then
			removePendingBid(BidResultCodes.ItemNotFound);
		elseif (message == ERR_NOT_ENOUGH_MONEY) then
			removePendingBid(BidResultCodes.NotEnoughMoney);
		elseif (message == ERR_AUCTION_BID_OWN) then
			removePendingBid(BidResultCodes.OwnAuction);
		elseif (message == ERR_AUCTION_HIGHER_BID) then
			removePendingBid(BidResultCodes.AlreadyHigherBid);
		elseif (message == ERR_ITEM_MAX_COUNT) then
			removePendingBid(BidResultCodes.MaxItemCount);
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the AH closes, while the bid/bo confirmation window is still
-- active, this function closes the confirmation window and cancels the bid.
--
-- parameters:
--    _ - ignoreing the first parameter, which is an empty table, since no
--        parameters are passed when registering this function with Stubby
--        (see Stubby.RegisterEventHook() for more details)
--    _ - ignoring the second parameter, which is the string representing the
--        event (in this case it's always "AUCTION_HOUSE_CLOSED").
-------------------------------------------------------------------------------
function onAHClosed(_, _)
	StaticPopup_Hide("AUCTIONEER_BIDORBUYOUT_AUCTION")
	Auctioneer.BidManager.BidCanceled()
end

-------------------------------------------------------------------------------
-- Called before Blizzard's PlaceAuctionBid()
-------------------------------------------------------------------------------
function prePlaceAuctionBidHook(_, _, listType, index, bid)
	if (hookPlaceAuctionBid) then
		if (isBidAllowed(listType, index)) then
			-- Add the pending bid to the list.
			addPendingBid(listType, index, bid, nil);
			currentListType, currentIndex, currentBid, currentCallbackFunc = listType, index, bid, nil;
		else
			debugPrint("Aborting bid on "..listType.." "..index.." "..bid.." in prePlaceAuctionBidHook", "Bid not allowed", DebugLib.Level.Notice)
			return "abort";
		end
	end
end

-------------------------------------------------------------------------------
-- Auctioneer's version of PlaceAuctionBid. Similar to the Blizzard version
-- except that it accepts a callback function.
-------------------------------------------------------------------------------
function placeAuctionBid(listType, index, bid, callbackFunc)
	if (isBidAllowed(listType, index)) then
		-- Store the pending bid's info and show the confirmation dialog.
		currentListType, currentIndex, currentBid, currentCallbackFunc = listType, index, bid, callbackFunc;

		local itemLink = GetAuctionItemLink(listType, index)
		local _, _, count, _, _, _, _, _, buyoutPrice = GetAuctionItemInfo(listType, index);
		local action

		if (bid and (buyoutPrice > 0) and (bid >= buyoutPrice)) then
			action = BUYOUT:lower()
		else
			action = BID:lower()
		end

		StaticPopupDialogs.AUCTIONEER_BIDORBUYOUT_AUCTION.text = _AUCT("ConfirmBidBuyout"):format(action, count, itemLink)
		StaticPopup_Show("AUCTIONEER_BIDORBUYOUT_AUCTION");
	else
		debugPrint("Aborting bid on "..listType.." "..index.." "..bid.." in placeAuctionBid", "Bid not allowed", DebugLib.Level.Notice)
	end
end

-------------------------------------------------------------------------------
-- Helper functions to the staticPopup
-------------------------------------------------------------------------------
function showingConfirmation(state)
	if (state == nil) then
		return showingConfirmationFlag;
	else
		showingConfirmationFlag = state;
	end
end

function bidConfirmed()
	addPendingBid(currentListType, currentIndex, currentBid, currentCallbackFunc);
	hookPlaceAuctionBid = false;
	PlaceAuctionBid(currentListType, currentIndex, currentBid);
	hookPlaceAuctionBid = true;
end

function bidCanceled()
	-- Get the auction being bid on. We first try to get it from the snapshot
	-- database so that we have the auctionId. If we are unable then we just
	-- get it from the query manager.
	local auction;
	local auctionId = Auctioneer.QueryManager.GetAuctionId(currentListType, currentIndex);
	if (auctionId) then
		auction = Auctioneer.SnapshotDB.GetAuctionById(nil, auctionId);
	end
	if (auction and auction.auctionId) then
		debugPrint("Found item "..auction.auctionId.." in snapshot in bidCanceled", "Pending bid found for cancellation", DebugLib.Level.Info)
	else
		debugPrint("Can't find item "..auction.auctionId.." in snapshot in bidCanceled", "Pending bid for cancellation not in snap", DebugLib.Level.Warning)
		auction = Auctioneer.QueryManager.GetAuctionByIndex(currentListType, currentIndex);
	end

	-- We had better have an auction by now...
	if (auction) then
		currentCallbackFunc(auction, BidResultCodes.BidCanceled)
	end
end

function getBidAmmount()
	return currentBid
end

-------------------------------------------------------------------------------
-- Checks if a bid is allowed on the specified auction.
-------------------------------------------------------------------------------
function isBidAllowed(listType, index)
	-- Must be a valid auction.
	local auction = Auctioneer.QueryManager.GetAuctionByIndex(listType, index)
	if (not Auctioneer.QueryManager.IsAuctionValid(auction)) then
		return false;
	end

	-- Must not have a query in progress.
	if (Auctioneer.QueryManager.IsQueryInProgress()) then
		return false;
	end

	-- Must not be a pending bid on the same auction.
	local auctionId = Auctioneer.QueryManager.GetAuctionId(listType, index);
	if (auctionId and isPendingBidForAuction(auctionId)) then
		return false;
	end

	return true;
end

-------------------------------------------------------------------------------
-- Returns true if a bid request is in flight to the server
-------------------------------------------------------------------------------
function isBidInProgress()
	return (#PendingBids > 0);
end

-------------------------------------------------------------------------------
-- Adds a pending bid to the queue.
-------------------------------------------------------------------------------
function addPendingBid(listType, index, bid, callbackFunc)
	-- Get the auction being bid on. We first try to get it from the snapshot
	-- database so that we have the auctionId. If we are unable then we just
	-- get it from the query manager.
	local auction;
	local auctionId = Auctioneer.QueryManager.GetAuctionId(listType, index);
	if (auctionId) then
		auction = Auctioneer.SnapshotDB.GetAuctionById(nil, auctionId);
	end
	if (auction and auction.auctionId) then
		debugPrint("Found item "..auction.auctionId.." in snapshot in addPendingBid", "Pending bid found", DebugLib.Level.Info)
	else
		debugPrint("Can't find item in snapshot in addPendingBid", "Pending bid not in snap", DebugLib.Level.Warning)
		auction = Auctioneer.QueryManager.GetAuctionByIndex(listType, index);
	end

	-- We had better have an auction by now...
	if (auction) then
		-- Add a pending bid to the queue.
		local pendingBid = {
			auction = auction;
			bid = bid;
			callbackFunc = callbackFunc;
		};
		table.insert(PendingBids, pendingBid);
		debugPrint("Found item in addPendingBid", "Added pending bid", DebugLib.Level.Info)

		-- Register for the response events if this is the first pending bid.
		if (#PendingBids == 1) then
			debugPrint("Registering handlers for bid result", "Registering bid handlers", DebugLib.Level.Info)
			Stubby.RegisterEventHook("CHAT_MSG_SYSTEM", "Auctioneer_BidManager", onEventHook);
			Stubby.RegisterEventHook("UI_ERROR_MESSAGE", "Auctioneer_BidManager", onEventHook);
		end

		-- Fire the AUCTIONEER_BID_SENT event.
		debugPrint("Sending bid request event to event manager", "Firing bid event", DebugLib.Level.Info)
		Auctioneer.EventManager.FireEvent("AUCTIONEER_BID_SENT", auction, bid);
	end
end

-------------------------------------------------------------------------------
-- Removes the pending bid from the queue.
-------------------------------------------------------------------------------
function removePendingBid(result)
	if (#PendingBids > 0) then
		-- Remove the first pending bid.
		local pendingBid = PendingBids[1];
		table.remove(PendingBids, 1);
		debugPrint("Removed pending bid with result "..result, "Removing pending bid", DebugLib.Level.Info)

		-- Unregister for the response events if this is the last pending bid.
		if (#PendingBids == 0) then
			debugPrint("Deregistering handlers for bid result", "Deregistering bid handlers", DebugLib.Level.Info)
			Stubby.UnregisterEventHook("CHAT_MSG_SYSTEM", "Auctioneer_BidManager");
			Stubby.UnregisterEventHook("UI_ERROR_MESSAGE", "Auctioneer_BidManager");
		end

		-- Fire the AUCTIONEER_BID_COMPLETE event.
		Auctioneer.EventManager.FireEvent("AUCTIONEER_BID_COMPLETE", pendingBid.auction, pendingBid.bid, result);

		-- If a callback function was provided, call it.
		if (pendingBid.callbackFunc) then
			pendingBid.callbackFunc(pendingBid.auction, result);
		end
	else
		-- We got out of sync somehow... this indicates a bug in how we determine
		-- the results of bid requests.
		chatPrint(_AUCT('FrmtBidQueueOutOfSync'));
	end
end

-------------------------------------------------------------------------------
-- Checks if there is a pending for the specified auction.
-------------------------------------------------------------------------------
function isPendingBidForAuction(auctionId)
	for _, pendingBid in pairs(PendingBids) do
		if (pendingBid.auction.auctionId == auctionId) then
			return true;
		end
	end
	return false;
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
	return Auctioneer.Util.DebugPrint(message, "AucBidManager", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.BidManager = {
	Load = load;
	IsBidInProgress = isBidInProgress;
	IsBidAllowed = isBidAllowed;
	PlaceAuctionBid = placeAuctionBid;
	BidConfirmed = bidConfirmed;
	BidCanceled = bidCanceled;
	ShowingConfirmation = showingConfirmation;
	GetBidAmmount = getBidAmmount;
	AddPendingBid = addPendingBid;
}


