--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucPostManager.lua 2477 2007-11-14 16:40:54Z Norganna $

	AucPostManager - manages posting auctions in the AH

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucPostManager.lua $", "$Rev: 2477 $")

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------
local RequestQueue = {};
local ProcessingRequestQueue = false;

-- Queue of pending auctions. In otherwords StartAuction() had been called but
-- we haven't received confirmation from the server of the start.
local PendingAuctions = {};

-------------------------------------------------------------------------------
-- State machine states for a request.
-------------------------------------------------------------------------------
local READY_STATE = "Ready";
local COMBINING_STACK_STATE = "CombiningStacks";
local SPLITTING_STACK_STATE = "SplittingStack";
local SPLITTING_AND_COMBINING_STACK_STATE = "SplittingAndCombiningStacks";
local AUCTIONING_STACK_STATE = "AuctioningStack";

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local onEventHook;
local pickupContainerItem;
local splitContainerItem;
local postAuction;
local addRequestToQueue;
local removeRequestFromQueue;
local processRequestQueue;
local run;
local onEvent;
local setState;
local findEmptySlot;
local findStackByItemKey;
local getContainerItemName;
local getContainerItemKey;
local clearAuctionItem;
local findAuctionItem;
local getItemQuantityByItemKey;
local printBag;
local getTimeLeftFromDuration;
local preStartAuctionHook;
local addPendingAuction;
local removePendingAuction;
local debugPrint

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_PostManager", onEventHook);
	Stubby.RegisterFunctionHook("StartAuction", -200, preStartAuctionHook)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function onEventHook(_, event, message, ...)
	-- Toss all the pending requests when the AH closes.
	if (event == "AUCTION_HOUSE_CLOSED") then
		while (#RequestQueue > 0) do
			removeRequestFromQueue();
		end

	-- Check for an auction created message.
	elseif (event == "CHAT_MSG_SYSTEM" and message) then
		if (message == ERR_AUCTION_STARTED) then
		 	removePendingAuction(true);
		end

	-- Check for an auction failure message.
	elseif (event == "UI_ERROR_MESSAGE" and message) then
		if (message == ERR_NOT_ENOUGH_MONEY) then
			removePendingAuction(false);
		end

	-- Otherwise hand off the event to the current request.
	elseif (#RequestQueue > 0) then
		local request = RequestQueue[1];
		if (request.state ~= READY_STATE) then
			onEvent(request, event, message, ...);
			processRequestQueue();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucPostManager_PickupContainerItem(bag, slot)
	-- Don't allow items to be picked up while posting auctions.
	debugPrint("Prevented call to PickupContainerItem()", DebugLib.Level.Info)
	return "abort"
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucPostManager_SplitContainerItem(bag, slot, count)
	-- Don't allow items to be picked up while posting auctions.
	debugPrint("Prevented call to SplitContainerItem()", DebugLib.Level.Info)
	return "abort"
end

-------------------------------------------------------------------------------
-- Our own version of pickupContainerItem() allows us to use this function by
-- ourselves while not allowing it for others.
-------------------------------------------------------------------------------
function pickupContainerItem(bag, slot)
	Stubby.UnregisterFunctionHook("PickupContainerItem", AucPostManager_PickupContainerItem)
	PickupContainerItem(bag, slot)
	Stubby.RegisterFunctionHook("PickupContainerItem", -200, AucPostManager_PickupContainerItem)
end

-------------------------------------------------------------------------------
-- Our own version of splitContainerItem() allows us to use this function by
-- ourselves while not allowing it for others.
-------------------------------------------------------------------------------
function splitContainerItem(bag, slot, count)
	Stubby.UnregisterFunctionHook("SplitContainerItem", AucPostManager_SplitContainerItem)
	SplitContainerItem(bag, slot, count)
	Stubby.RegisterFunctionHook("SplitContainerItem", -200, AucPostManager_SplitContainerItem)
end

-------------------------------------------------------------------------------
-- Start an auction.
-------------------------------------------------------------------------------
function postAuction(itemKey, stackSize, stackCount, bid, buyout, duration, callbackFunc, callbackParam)
	-- Problems can occur if the Auctions tab hasn't been shown at least once.
	if (not AuctionFrameAuctions:IsVisible()) then
		AuctionFrameAuctions:Show();
		AuctionFrameAuctions:Hide();
	end

	-- Add the request to the queue.
	local request = {
		itemKey = itemKey;
		name = Auctioneer.ItemDB.GetItemName(itemKey);
		stackSize = stackSize;
		stackCount = stackCount;
		bid = bid;
		buyout = buyout;
		duration = duration;
		callback = { func = callbackFunc, param = callbackParam };
	};
	addRequestToQueue(request);
	processRequestQueue();
end

-------------------------------------------------------------------------------
-- Adds a request to the queue.
-------------------------------------------------------------------------------
function addRequestToQueue(request)
	debugPrint("Add request to queue", DebugLib.Level.Info)
	request.state = READY_STATE;
	request.stackPostCount = 0;
	request.lockEventsInCurrentState = 0;
	request.stack = nil;
	table.insert(RequestQueue, request);
end

-------------------------------------------------------------------------------
-- Removes a request at the head of the queue.
-------------------------------------------------------------------------------
function removeRequestFromQueue()
	if (#RequestQueue > 0) then
		local request = RequestQueue[1];

		-- Make absolutely sure we are back in the READY_STATE so that we
		-- correctly unregister for events.
		setState(request, READY_STATE);

		-- Perform the callback
		local callback = request.callback;
		if (callback and callback.func) then
			callback.func(callback.param, request);
		end

		-- Report the auctions posted
		if (request.stackPostCount == 1) then
			chatPrint(_AUCT('FrmtPostedAuction'):format(request.name, request.stackSize));
		else
			chatPrint(_AUCT('FrmtPostedAuctions'):format(request.stackPostCount, request.name, request.stackSize));
		end
		table.remove(RequestQueue, 1);

		-- If this was the last request, end processing the queue.
		if (#RequestQueue == 0) then
			endProcessingRequestQueue()
		end
	end
end

-------------------------------------------------------------------------------
-- Executes the request at the head of the queue.
-------------------------------------------------------------------------------
function processRequestQueue()
	if (beginProcessingRequestQueue()) then
		run(RequestQueue[1]);
	end
end

-------------------------------------------------------------------------------
-- Starts processing the request queue if possible. Returns true if started.
-------------------------------------------------------------------------------
function beginProcessingRequestQueue()
	if (not ProcessingRequestQueue and
		AuctionFrame and AuctionFrame:IsVisible() and
		#RequestQueue > 0) then

		ProcessingRequestQueue = true;
		debugPrint("Begin processing the post queue", DebugLib.Level.Info);

		-- Hook the functions to disable picking up items. This prevents
		-- spurious ITEM_LOCK_CHANGED events from confusing us.
		Stubby.RegisterFunctionHook("PickupContainerItem", -200, AucPostManager_PickupContainerItem)
		Stubby.RegisterFunctionHook("SplitContainerItem", -200, AucPostManager_SplitContainerItem)
	end
	return ProcessingRequestQueue;
end

-------------------------------------------------------------------------------
-- Ends processing the request queue
-------------------------------------------------------------------------------
function endProcessingRequestQueue()
	if (ProcessingRequestQueue) then
		-- Unhook the functions.
		Stubby.UnregisterFunctionHook("PickupContainerItem", AucPostManager_PickupContainerItem)
		Stubby.UnregisterFunctionHook("SplitContainerItem", AucPostManager_SplitContainerItem)

		debugPrint("End processing the post queue", DebugLib.Level.Info);
		ProcessingRequestQueue = false;
	end
end

-------------------------------------------------------------------------------
-- Performs the next step in fulfilling the request.
-------------------------------------------------------------------------------
function run(request)
	debugPrint("Run request: "..request.state, DebugLib.Level.Info)
	if (request.state == READY_STATE) then
		-- Locate a stack of the items. If the request has a stack associated
		-- with it, that's a hint to try and use it. Otherwise we'll search
		-- for a stack of the exact size. Failing that, we'll start with the
		-- first stack we find.
		local stack1 = nil;
		if (request.stack and request.itemKey == getContainerItemKey(request.stack.bag, request.stack.slot)) then
			-- Use the stack hint.
			stack1 = request.stack;
		else
			-- Find the first stack.
			stack1 = findStackByItemKey(request.itemKey);

			-- Now look for a stack of the exact size to use instead.
			if (stack1) then
				local stack2 = { bag = stack1.bag, slot = stack1.slot };
				local _, stack2Size = GetContainerItemInfo(stack2.bag, stack2.slot);
				while (stack2 and stack2Size ~= request.stackSize) do
					stack2 = findStackByItemKey(request.itemKey, stack2.bag, stack2.slot + 1);
					if (stack2) then
						_, stack2Size = GetContainerItemInfo(stack2.bag, stack2.slot);
					end
				end
				if (stack2) then
					stack1 = stack2;
				end
			end
		end

		-- If we have found a stack, figure out what we should do with it.
		if (stack1) then
			local _, stack1Size = GetContainerItemInfo(stack1.bag, stack1.slot);
			if (stack1Size == request.stackSize) then
				-- We've done it! Now move the stack to the auction house.
				request.stack = stack1;
				setState(request, AUCTIONING_STACK_STATE);
				pickupContainerItem(stack1.bag, stack1.slot);
				ClickAuctionSellItemButton();

				-- Start the auction if requested.
				if (request.bid and request.buyout and request.duration) then
					StartAuction(request.bid, request.buyout, request.duration);
				else
					removeRequestFromQueue();
				end
			elseif (stack1Size < request.stackSize) then
				-- The stack we have is less than needed. Locate more of the item.
				local stack2 = findStackByItemKey(request.itemKey, stack1.bag, stack1.slot + 1);
				if (stack2) then
					local _, stack2Size = GetContainerItemInfo(stack2.bag, stack2.slot);
					if (stack1Size + stack2Size <= request.stackSize) then
						-- Combine all of stack2 with stack1.
						setState(request, COMBINING_STACK_STATE);
						pickupContainerItem(stack2.bag, stack2.slot);
						pickupContainerItem(stack1.bag, stack1.slot);
						request.stack = stack1;
					else
						-- Combine part of stack2 with stack1.
						setState(request, SPLITTING_AND_COMBINING_STACK_STATE);
						splitContainerItem(stack2.bag, stack2.slot, request.stackSize - stack1Size);
						pickupContainerItem(stack1.bag, stack1.slot);
						request.stack = stack1;
					end
				else
					-- Not enough of the item!
					chatPrint(_AUCT('FrmtNotEnoughOfItem'):format(request.name));
					removeRequestFromQueue();
				end
			else
				-- The stack we have is more than needed. Locate an empty slot.
				local stack2 = findEmptySlot();
				if (stack2) then
					setState(request, SPLITTING_STACK_STATE);
					splitContainerItem(stack1.bag, stack1.slot, request.stackSize);
					pickupContainerItem(stack2.bag, stack2.slot);
					request.stack = stack2;
				else
					-- No empty slot found
					chatPrint(_AUCT('FrmtNoEmptyPackSpace'));
					removeRequestFromQueue();
				end
			end
		else
			-- Item not found!
			chatPrint(_AUCT('FrmtNotEnoughOfItem'):format(request.name));
			removeRequestFromQueue();
		end
	end
end

-------------------------------------------------------------------------------
-- Processes the event.
-------------------------------------------------------------------------------
function onEvent(request, event)
	debugPrint("Received event "..event.. " in state "..request.state, DebugLib.Level.Info)

	-- Process the event.
	if (event == "ITEM_LOCK_CHANGED") then
		-- Check if we are waiting for a stack to be complete.
		request.lockEventsInCurrentState = request.lockEventsInCurrentState + 1;
		if (request.lockEventsInCurrentState >= 2 and
			(request.state == SPLITTING_STACK_STATE or
			 request.state == COMBINING_STACK_STATE or
			 request.state == SPLITTING_AND_COMBINING_STACK_STATE)) then
			-- Ready to move onto the next step.
			setState(request, READY_STATE);
		end
	elseif (event == "BAG_UPDATE") then
		-- Check if we are waiting for StartAuction() to complete. If so, check
		-- if the stack we are trying to auction is now gone.
		if (request.state == AUCTIONING_STACK_STATE and GetContainerItemInfo(request.stack.bag, request.stack.slot) == nil) then
			-- Ready to move onto the next step.
			setState(request, READY_STATE);

			-- Decrement the auction target count.
			request.stackPostCount = request.stackPostCount + 1;
			if (request.stackPostCount == request.stackCount) then
				removeRequestFromQueue();
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Changes the request state.
-------------------------------------------------------------------------------
function setState(request, newState)
	if (request.state ~= newState) then
		debugPrint("Entered state: "..newState, DebugLib.Level.Info)

		-- Unregister for events needed in the old state.
		if (request.state == SPLITTING_STACK_STATE or
			request.state == COMBINING_STACK_STATE or
			request.state == SPLITTING_AND_COMBINING_STACK_STATE) then
			debugPrint("Unregistering for ITEM_LOCK_CHANGED", DebugLib.Level.Info)
			Stubby.UnregisterEventHook("ITEM_LOCK_CHANGED", "Auctioneer_PostManager");
		elseif (request.state == AUCTIONING_STACK_STATE) then
			debugPrint("Unregistering for BAG_UPDATE", DebugLib.Level.Info)
			Stubby.UnregisterEventHook("BAG_UPDATE", "Auctioneer_PostManager");
		end

		-- Update the request's state.
		request.state = newState;
		request.lockEventsInCurrentState = 0;

		-- Register for events needed in the new state.
		if (request.state == SPLITTING_STACK_STATE or
			request.state == COMBINING_STACK_STATE or
			request.state == SPLITTING_AND_COMBINING_STACK_STATE) then
			debugPrint("Registering for ITEM_LOCK_CHANGED", DebugLib.Level.Info)
			Stubby.RegisterEventHook("ITEM_LOCK_CHANGED", "Auctioneer_PostManager", onEventHook);
		elseif (request.state == AUCTIONING_STACK_STATE) then
			debugPrint("Registering for BAG_UPDATE", DebugLib.Level.Info)
			Stubby.RegisterEventHook("BAG_UPDATE", "Auctioneer_PostManager", onEventHook);
		end
	end
end

-------------------------------------------------------------------------------
-- Finds an empty slot in the player's containers.
--
-- returns BagTable
--    {
--     bag  = number of bag which contains the empty slot
--     slot = number of empty slot in that specific bag
--    }
--    nil, if no empty slot could be found
--
-- TODO: Correctly handle containers like ammo packs, so that if u try to find
--       an empty place for ammo, the ammo pack will be taken into account and
--       not skipped, as it's currently the case
-------------------------------------------------------------------------------
function findEmptySlot()
	bag, slot = Auctioneer.Util.FindEmptySlot()
	if bag then
		return { bag=bag, slot=slot }
	end
end

-------------------------------------------------------------------------------
-- Finds the specified item by id
--
-- TODO: Correctly handle containers like ammo packs
-------------------------------------------------------------------------------
function findStackByItemKey(itemKey, startingBag, startingSlot)
	if (startingBag == nil) then
		startingBag = 0;
	end
	if (startingSlot == nil) then
		startingSlot = 1;
	end
	for bag = startingBag, 4, 1 do
		if (GetBagName(bag)) then
			local numItems = GetContainerNumSlots(bag);
			if (startingSlot <= numItems) then
				for slot = startingSlot, GetContainerNumSlots(bag), 1 do
					local thisItemKey = getContainerItemKey(bag, slot);
					if (itemKey == thisItemKey) then
						return { bag=bag, slot=slot };
					end
				end
			end
			startingSlot = 1;
		end
	end
	return nil;
end


-------------------------------------------------------------------------------
-- Gets the name of the specified
-------------------------------------------------------------------------------
function getContainerItemName(bag, slot)
	local link = GetContainerItemLink(bag, slot);
	if (link) then
		local _, _, _, _, name = EnhTooltip.BreakLink(link);
		return name;
	end
end

-------------------------------------------------------------------------------
-- Gets the item key of the specified item (itemId:suffixId:enchantId)
-------------------------------------------------------------------------------
function getContainerItemKey(bag, slot)
	local link = GetContainerItemLink(bag, slot);
	if (link) then
		return Auctioneer.ItemDB.CreateItemKeyFromLink(link);
	end
end

-------------------------------------------------------------------------------
-- Clears the current auction item, if any.
-------------------------------------------------------------------------------
function clearAuctionItem()
	local bag, item = findAuctionItem();
	if (bag and item) then
		ClickAuctionSellItemButton();
		pickupContainerItem(bag, item);
	end
end

-------------------------------------------------------------------------------
-- Finds the bag and slot for the current auction item.
--
-- TODO: Correctly handle containers like ammo packs
-------------------------------------------------------------------------------
function findAuctionItem()
	local auctionName, _, auctionCount = GetAuctionSellItemInfo();
	if (auctionName and auctionCount) then
		for bag = 0, 4, 1 do
			if (GetBagName(bag)) then
				for item = GetContainerNumSlots(bag), 1, -1 do
					local _, itemCount, itemLocked = GetContainerItemInfo(bag, item);
					if (itemLocked and itemCount == auctionCount) then
						local itemName = getContainerItemName(bag, item);
						if (itemName == auctionName) then
							return bag, item;
						end
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Gets the quanity of the specified item
--
-- TODO: Correctly handle containers like ammo packs
-------------------------------------------------------------------------------
function getItemQuantityByItemKey(itemKey)
	local quantity = 0;
	for bag = 0, 4, 1 do
		if (GetBagName(bag)) then
			for item = GetContainerNumSlots(bag), 1, -1 do
				local thisItemKey = getContainerItemKey(bag, item);
				if (itemKey == thisItemKey) then
					local _, itemCount = GetContainerItemInfo(bag, item);
					quantity = quantity + itemCount;
				end
			end
		end
	end
	return quantity;
end


-------------------------------------------------------------------------------
-- Converts from duration (in minutes) to time left (1 thru 4 representing
-- short to very long). Returns nil if the duration is invalid.
-------------------------------------------------------------------------------
function getTimeLeftFromDuration(duration)
	if (duration) then
		if (duration == 12*60) then
			return 2;
		elseif (duration == 24*60) then
			return 3;
		elseif (duration == 48*60) then
			return 4;
		end
	end
end

-------------------------------------------------------------------------------
-- Called before Blizzard's StartAuctionHook().
-------------------------------------------------------------------------------
function preStartAuctionHook(_, _, bid, buyout, duration)
	debugPrint("Blizzard's StartAuction("..nilSafe(bid)..", "..nilSafe(buyout)..", "..nilSafe(duration)..") called", DebugLib.Level.Info)
	if (bid ~= nil and bid > 0 and getTimeLeftFromDuration(duration)) then
		local bag, item = findAuctionItem();
		if (bag and item) then
			-- Get the item's information.
			local itemTexture, itemCount = GetContainerItemInfo(bag, item);
			local itemLink = GetContainerItemLink(bag, item);
			local itemId, suffixId, enchantId, uniqueId, name = EnhTooltip.BreakLink(itemLink);

			-- Create the auction and add it to the pending list.
			local auction = {};
			auction.ahKey = Auctioneer.Util.GetAuctionKey();
			auction.itemId = itemId;
			auction.suffixId = suffixId;
			auction.enchantId = enchantId;
			auction.uniqueId = uniqueId
			auction.count = itemCount;
			auction.minBid = bid;
			auction.buyoutPrice = buyout;
			auction.owner = UnitName("player");
			auction.bidAmount = 0;
			auction.highBidder = false;
			auction.timeLeft = getTimeLeftFromDuration(duration);
			auction.lastSeen = time();
			addPendingAuction(auction);
		else
			debugPrint("Aborting StartAuction() because item cannot be found in bags", DebugLib.Level.Error)
			return "abort";
		end
	else
		debugPrint("Aborting StartAuction() due to invalid arguments", DebugLib.Level.Error)
		return "abort";
	end
end

-------------------------------------------------------------------------------
-- Adds a pending auction to the queue.
-------------------------------------------------------------------------------
function addPendingAuction(auction)
	table.insert(PendingAuctions, auction);
	debugPrint("Added pending auction", DebugLib.Level.Info);

	-- Register for the response events if this is the first pending auction.
	if (#PendingAuctions == 1) then
		debugPrint("addPendingAuction() - Registering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE", DebugLib.Level.Info)
		Stubby.RegisterEventHook("CHAT_MSG_SYSTEM", "Auctioneer_PostManager", onEventHook);
		Stubby.RegisterEventHook("UI_ERROR_MESSAGE", "Auctioneer_PostManager", onEventHook);
	end
end

-------------------------------------------------------------------------------
-- Removes the pending auction from the queue.
-------------------------------------------------------------------------------
function removePendingAuction(result)
	if (#PendingAuctions > 0) then
		-- Remove the first pending auction.
		local pendingAuction = PendingAuctions[1];
		table.remove(PendingAuctions, 1);
		if (result) then
			debugPrint("Removed pending auction with result: true", DebugLib.Level.Info)
		else
			debugPrint("Removed pending auction with result: false", DebugLib.Level.Notice)
		end

		-- Unregister for the response events if this is the last pending auction.
		if (#PendingAuctions == 0) then
			debugPrint("removePendingAuction() - Unregistering for CHAT_MSG_SYSTEM and UI_ERROR_MESSAGE", DebugLib.Level.Info)
			Stubby.UnregisterEventHook("CHAT_MSG_SYSTEM", "Auctioneer_PostManager");
			Stubby.UnregisterEventHook("UI_ERROR_MESSAGE", "Auctioneer_PostManager");
		end

		-- If successful, then add it to the snapshot.
		if (result) then
			Auctioneer.SnapshotDB.AddAuction(pendingAuction);
		end
	else
		-- We got out of sync somehow... this indicates a bug in how we determine
		-- the results of auction requests.
		chatPrint("Post auction queue out of sync!"); -- %todo: localize
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafe(string)
	return string or "<nil>";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
chatPrint = Auctioneer.Util.ChatPrint;

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
	return Auctioneer.Util.DebugPrint(message, "AucPostManager", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.PostManager = {
	Load = load;
	PostAuction = postAuction;
	GetItemQuantityByItemKey = getItemQuantityByItemKey;
};
