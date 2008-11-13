--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucQueryManager.lua 2469 2007-11-14 06:08:37Z jslagle $

	QueryManager - manages AH queries

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


Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucQueryManager.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function definitions
-------------------------------------------------------------------------------
local addPageToCache;
local addRequestToQueue;
local canSendAuctionQuery;
local checkForDups;
local clearPageCache;
local clearRequestQueue;
local debugPrint
local doAuctionsMatchQuery;
local doQueriesMatch;
local getAuctionByIndex;
local getAuctionId;
local getAuctionsInCache;
local getAuctionsOnCurrentPage;
local isAuctionValid;
local isBidInProgress;
local isQueryInProgress;
local load;
local nilSafeNumber;
local nilSafeString;
local normalizeNumericQueryParam;
local onAuctionItemListUpdate;
local onBidComplete;
local onBidSent;
local onEventHook;
local postCanSendAuctionQuery;
local postQueryAuctionItemsHook;
local postSortAuctionItemsHook;
local preQueryAuctionItemsHook;
local preSortAuctionItemsHook;
local processQuery;
local queryAuctionItems;
local reconcileAuctionLists;
local removeRequestFromQueue;
local sendQuery;

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Public Data
-------------------------------------------------------------------------------
QueryAuctionItemsResultCodes = {
	Complete        = "Complete";
	PartialComplete = "PartialComplete";
	Canceled        = "Canceled";
};

-------------------------------------------------------------------------------
-- Private Data
-------------------------------------------------------------------------------
--Queue of query requests.
--
--QueryRequestQueue[Index] = {
--	parameters;				-- query parameters
--	maxSilence;
--	retriesLeft;
--	callbackFunc;			-- callback function called when the query is complete.
--	querySent;				-- true if the query has been sent to the server.
--	receivedQueryResponse;	-- true if the initial response has been received.
--	lastQueryResponseTime		-- time of the last query response.
-- }
local QueryRequestQueue = {};

-- Flag that is true when inside Blizzard's SortAuctionItems().
local PerformingSortAuctionItems = false;

-- The query parameters for the current page cache.
local PageCacheQuery = {};

-- Table containing all the pages seen for the PageCacheQuery. The table has the
-- following structure:
--
--PageCache[PageNum] = {
--	query					-- query parameters
--	pageNum;				-- page number
--	isLastPage;				-- true if this is the last page for the search
--	lastSeen				-- time the page was seen
--	auctions[IndexOnPage] = {	-- list of auctions on the page.
--		auctionId;			-- nil unless the snapshot has been updated
--		itemId;
--		suffixId;
--		enchantId;
--		uniqueId;
--		name;
--		texture;
--		count;
--		quality;
--		canUse;
--		level;
--		minBid;
--		minIncrement;
--		buyoutPrice;
--		bidAmount;
--		highBidder;
--		owner;
--	}
--}
local PageCache = {};

-- Table of pending bids listed by auction id.
--
-- PendingBidInfo[AuctionId]
-- {
--	bid;						-- the bid sent to the server
--	receivedBidComplete;			-- true if onBidComplete() has been called
--	receivedAuctionItemListUpdate;	-- true if onAuctionItemListUpdate() has been called
-- }
local PendingBidInfo = {};

local CurrentPage = nil;

-- used to trap auction database update on start of scan
local Scanned = 0;

-- True if CanSendAuctionQuery calls should be hooked. This is always the case
-- unless Auctioneer wants to call it. Setting this to false effectively
-- unhooks the method.
local hookCanSendAuctionQuery = true;

-- True if QueryAuctionItems calls should be hooked. This is always the case
-- unless Auctioneer wants to call it. Setting this to false effectively
-- unhooks the method.
local hookQueryAuctionItems = true;
-- flag for the Blizzard Scan type 
local BlizzardScan = nil;
local ForwardScan = nil;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	Stubby.RegisterEventHook("AUCTION_ITEM_LIST_UPDATE", "Auctioneer_QueryManager", onEventHook);
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_QueryManager", onEventHook);
	Stubby.RegisterFunctionHook("CanSendAuctionQuery", 50, postCanSendAuctionQuery);
	Stubby.RegisterFunctionHook("QueryAuctionItems", -50, preQueryAuctionItemsHook);
	Stubby.RegisterFunctionHook("QueryAuctionItems", 50, postQueryAuctionItemsHook);
	Stubby.RegisterFunctionHook("SortAuctionItems", -50, preSortAuctionItemsHook);
	Stubby.RegisterFunctionHook("SortAuctionItems", 50, postSortAuctionItemsHook);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_BID_SENT", onBidSent);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_BID_COMPLETE", onBidComplete);
end

-------------------------------------------------------------------------------
-- Check if a query should be sent or resent.
-------------------------------------------------------------------------------
function AucQueryManager_OnUpdate()
	local request = QueryRequestQueue[1];
	if (request) then
		-- If the query has been sent, check if it needs to be aborted or resent.
		if (request.querySent) then
			-- Check if we've recevied any response from the server.
			local silence = (GetTime() - request.lastQueryResponseTime);
			if (request.receivedQueryResponse) then
				-- Yep, check how long the server has been quite.
				if (silence > request.maxSilence) then
					-- Either retry or fail it.
					if (request.retriesLeft > 0) then
						request.retriesLeft = request.retriesLeft - 1;
						sendQuery(request);
					else
						debugPrint("AucQueryManager.AucQueryManager_OnUpdate(): Query Response not received in "..silence.." seconds (maxSilence = "..request.maxSilence..")", "Timeout", DebugLib.Level.Warning)
						removeRequestFromQueue(QueryAuctionItemsResultCodes.PartialComplete);
					end
				elseif (not request.ownerTimeout and silence >= request.maxSilence - 1) then
					debugPrint("Trigger owner timeout at "..silence.." seconds.", "Owner timeout", DebugLib.Level.Notice)
					request.ownerTimeout = true
					onAuctionItemListUpdate()
				end
			else
				if (silence > request.maxSilence) then
					--retry or fail 
					if (request.retriesLeft > 0) then
						request.retriesLeft = request.retriesLeft -1;
						sendQuery(request);
					else
						debugPrint("Query response not received in the last "..silence.." seconds (maxSilence = "..request.maxSilence..")", "Timeout", DebugLib.Level.Warning)
						removeRequestFromQueue(QueryAuctionItemsResultCodes.PartialComplete);
					end
				end
			end
		-- Otherwise check if we can send the query now.
		elseif (canSendAuctionQuery()) then
			sendQuery(request);
		end
	end
end

-------------------------------------------------------------------------------
-- OnEvent handler.
-------------------------------------------------------------------------------
function onEventHook(_, event)
	debugPrint("Event: "..event.." caught.", DebugLib.Level.Info)

	if (event == "AUCTION_ITEM_LIST_UPDATE") then
		onAuctionItemListUpdate();
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		clearRequestQueue();
	end
end

-------------------------------------------------------------------------------
-- Called when a bid is sent to the server.
-------------------------------------------------------------------------------
function onBidSent(event, auction, bid)
	-- Only pay attention to bids with auction ids.
	if (auction.auctionId) then
		local bidInfo = {
			bid = bid;
			receivedBidComplete = false;
			receivedAuctionItemListUpdate = false;
		};
		PendingBidInfo[auction.auctionId] = bidInfo;
		debugPrint("Added pending bid for auction "..auction.auctionId..".", DebugLib.Level.Info)
	else
		debugPrint("Ignoring bid sent due to no auction id", DebugLib.Level.Error);
	end
end

-------------------------------------------------------------------------------
-- Called when the result of a bid is received.
-------------------------------------------------------------------------------
function onBidComplete(event, auction, bid, result)
	-- Only pay attention to bids with auction ids.
	if (auction.auctionId) then
		-- Remove the pending bid.
		local bidInfo = PendingBidInfo[auction.auctionId];
		if (bidInfo) then
			-- Remove the pending bid info if the bid was unsuccessful or if we've
			-- received the AUCTION_ITEM_LIST_UPDATE event.
			if (result ~= BidResultCodes.BidAccepted or bidInfo.receivedAuctionItemListUpdate) then
				PendingBidInfo[auction.auctionId] = nil;
				debugPrint("Removed pending bid for auction "..auction.auctionId, DebugLib.Level.Warning)
			else
				bidInfo.receivedBidComplete = true;
				debugPrint("Deferring removal of pending bid for auction "..auction.auctionId, nil, DebugLib.Level.Info)
			end
		else
			debugPrint("WARNING: No pending bid for auction "..auction.auctionId, DebugLib.Level.Error);
		end
	else
		debugPrint("Ignoring bid complete due to no auction id", DebugLib.Level.Error);
	end
end

-------------------------------------------------------------------------------
-- Hook called after Blizzard's CanSendAuctionQuery().
-- Overrides the return value to prevent other addons from intervening with our
-- scan procedure. Under the following conditions we permit sending auction
-- queries:
-- 1. Blizzard's CanSendAuctionQuery() returns nil.
-- 2. There is a query in progress.
-- 3. There is a bid in progress.
--
-- In advance these checks are performed whenever CanSendAuctionQuery() is
-- called outside of our other provided function
-- AucQueryManager.CanSendAuctionQuery() which would skip these tests:
-- 4. The scan manager is performing a scan.
-- 5. The bid scanner is performing bidding (which includes a scan)
--
-- called by:
--    function hook - CanSendAuctionQuery() (position: 50)
--
-- calls:
--    isQueryInProgress()                 - everytime
--    isBidInProgress()                   - if isQueryInProgress() is false
--    AucScanManager.IsScanning()         - if isBidInProgress() is false and
--                                          hooking into CanSendAuctionQuery()
--                                          is enabled
--    AucBidScanner.IsScanning()          - if AucScanManager.IsScanning() is
--                                          false and hooking into 
--                                          CanSendAuctionQuery() is enabled
--    AucBidManager.ShowingConfirmation() - if AucBidScanner.IsScanning() is
--                                          false and hooking into 
--                                          CanSendAuctionQuery() is enabled
--
-- parameters:
--    _     - ignoring the first parameter, which is an empty table, since no
--            parameters are passed when registering this function with Stubby
--            (see Stubby.RegisterFunctionHook() for more details)
--    returnValues - (table) {[1] = 1}, if CanSendAuctionQuery() returned 1,
--                           {}, otherwise
--
-- returns:
--    first value:
--       nil, if sending an auction query is fine
--       "setreturn", otherwise
--    second value:
--       nil, if sending an auction query is fine
--       {}, otherwise
--
-- remarks:
--    See AucQueryManager.CanSendAuctionQuery() for a way to work around
--    our changed return values, if required.
-------------------------------------------------------------------------------
function postCanSendAuctionQuery(_, returnValues)
	if not returnValues[1] then
		-- sending a query is already restricted by the original
		-- CanSendAuctionQuery() call - so there's no point in checking, if we
		-- permit it
		return
	end

	-- If Blizzard will allow the query, check if we should allow it.
	if (isQueryInProgress()) then
		debugPrint("Overriding CanSendAuctionQuery() due to query being in progress", DebugLib.Level.Notice);
		return "setreturn", {};
	elseif (isBidInProgress()) then
		debugPrint("Overriding CanSendAuctionQuery() due to bid being in progress", DebugLib.Level.Notice);
		return "setreturn", {};
	elseif (hookCanSendAuctionQuery and Auctioneer.ScanManager.IsScanning()) then
		debugPrint("Overriding CanSendAuctionQuery() due to scan being in progress", DebugLib.Level.Notice);
		return "setreturn", {};
	elseif (hookCanSendAuctionQuery and Auctioneer.BidScanner.IsScanning()) then
		debugPrint("Overriding CanSendAuctionQuery() due to bid scan being in progress", DebugLib.Level.Notice);
		return "setreturn", {};
	end
end

-------------------------------------------------------------------------------
-- Auctioneer's version of CanSendAuctionQuery(). This method returns true
-- under any of the following conditions:
-- 1. Blizzard's CanSendAuctionQuery() returns true;
-- 2. There is a query in progress.
-- 3. There is a bid in progress.
-------------------------------------------------------------------------------
function canSendAuctionQuery()
	hookCanSendAuctionQuery = false
	local result = CanSendAuctionQuery();
	hookCanSendAuctionQuery = true

	return result;
end

-------------------------------------------------------------------------------
-- Hook called before Blizzard's SortAuctionItems().
-------------------------------------------------------------------------------
function preSortAuctionItemsHook(_, _, sortType, sortColumn)
	if (sortType == "list") then
		if (isQueryInProgress()) then
			debugPrint("Overriding SortAuctionItems() - Request in progress", DebugLib.Level.Notice);
			return "abort"
		elseif (isBidInProgress()) then
			debugPrint("Overriding SortAuctionItems() - Bid in progress", DebugLib.Level.Notice);
			return "abort"
		end
		PerformingSortAuctionItems = true;
	end
end

-------------------------------------------------------------------------------
-- Hook called after Blizzard's SortAuctionItems().
-------------------------------------------------------------------------------
function postSortAuctionItemsHook(_, _, sortType, sortColumn)
	if (sortType == "list") then
		PerformingSortAuctionItems = false;
	end
end

-------------------------------------------------------------------------------
-- Hook called before Blizzard's QueryAuctionItems(). Aborts the method if
-- it cannot be called at this time.
-------------------------------------------------------------------------------
function preQueryAuctionItemsHook(_, _, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	-- If BottomScanner is driving, let it do it's own thing without
	-- interference from us, cause we don't really know what's going
	-- on, as BtmScan overrides CanSendAuctionQuery()
	if (BtmScan and BtmScan.scanStage and BtmScan.scanStage > 0) then return end
	if (hookQueryAuctionItems) then
		if (not CanSendAuctionQuery()) then
			debugPrint("Aborting QueryAuctionItems() - CanSendAuctionQuery() returned false", DebugLib.Level.Notice);
			return "abort";
		elseif (page == nil) then
			debugPrint("Aborting QueryAuctionItems() - Invalid page number", DebugLib.Level.Notice);
			return "abort";
		end
	end
end

-------------------------------------------------------------------------------
-- Hook called after Blizzard's QueryAuctionItems(). If we make it this far
-- its assumed that the query went through and we start the waiting game.
-------------------------------------------------------------------------------
function postQueryAuctionItemsHook(_, _, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	if (hookQueryAuctionItems and (not BtmScan or not BtmScan.scanning)) then
		debugPrint("Blizzard's QueryAuctionItems() called", DebugLib.Level.Info);
		BlizzardScan = 1;

		-- Construct the request and add it to the front of the queue.
		local request = {
			-- Construct a table for the QueryAuctionItem parameters.
			parameters = {
				name = name;
				minLevel = normalizeNumericQueryParam(minLevel);
				maxLevel = normalizeNumericQueryParam(maxLevel);
				invTypeIndex = normalizeNumericQueryParam(invTypeIndex);
				classIndex = normalizeNumericQueryParam(classIndex);
				subclassIndex = normalizeNumericQueryParam(subclassIndex);
				page = page;
				isUsable = isUsable;
				qualityIndex = normalizeNumericQueryParam(qualityIndex);
			};
			maxSilence = 5; -- 5 seconds
			retriesLeft = 0;
			callbackFunc = nil;
			querySent = true;
			receivedQueryResponse = false;
			lastQueryResponseTime = GetTime();
		};

		-- Add the request to the queue. We are guaranteed to be the only ones
		-- in the queue.
		addRequestToQueue(request, true);
	end
end

-------------------------------------------------------------------------------
-- Auctioneer's version of QueryAuctionItems. Similar to the Blizzard version
-- except that it accepts a callback function.
-------------------------------------------------------------------------------
function queryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex, maxSilence, maxRetries, callbackFunc)
	debugPrint("Auctioneer's QueryAuctionItems() called", DebugLib.Level.Info);

	-- Validate the parameters.
	maxSilence = maxSilence or 5;
	maxRetries = maxRetries or 3;

	-- Construct a table for the QueryAuctionItem parameters.

	-- Construct the request and add it to the queue.
	local request = {
		parameters = {
			name = name;
			minLevel = normalizeNumericQueryParam(minLevel);
			maxLevel = normalizeNumericQueryParam(maxLevel);
			invTypeIndex = normalizeNumericQueryParam(invTypeIndex);
			classIndex = normalizeNumericQueryParam(classIndex);
			subclassIndex = normalizeNumericQueryParam(subclassIndex);
			page = page;
			isUsable = isUsable;
			qualityIndex = normalizeNumericQueryParam(qualityIndex);
		};
		maxSilence = maxSilence;
		retriesLeft = maxRetries;
		callbackFunc = callbackFunc;
		querySent = false;
		receivedQueryResponse =  false;
		lastQueryResponseTime = nil;
	}

	-- Add the request to the queue.
	addRequestToQueue(request);
end

-------------------------------------------------------------------------------
-- Adds a request to the back of the queue.
-------------------------------------------------------------------------------
function addRequestToQueue(request, front)
	if (front) then
		table.insert(QueryRequestQueue, 1, request);
		debugPrint("Added request to front of queue", DebugLib.Level.Notice);
	else
		table.insert(QueryRequestQueue, request);
		debugPrint("Added request to back of queue", DebugLib.Level.Notice);
	end
end

-------------------------------------------------------------------------------
-- Removes the request at the head of the queue.
-------------------------------------------------------------------------------
function removeRequestFromQueue(result)
	if (#QueryRequestQueue > 0) then
		-- Remove the request from the queue.
		local request = QueryRequestQueue[1];
		table.remove(QueryRequestQueue, 1);
		debugPrint("Removed request from queue with result: "..result, DebugLib.Level.Notice);

		-- If the query was successful, add the page to the cache. Otherwise
		-- toss the cache since we have only partial results.
		if (result == QueryAuctionItemsResultCodes.Complete) then
			addPageToCache(CurrentPage, true);
		else
			clearPageCache();
		end

		-- If a callback function was provided, call it.
		if (request.callbackFunc) then
			request.callbackFunc(request.parameters, result);
		end
	end
end

-------------------------------------------------------------------------------
-- Cancels the current query, if any. Doesn't really cancel the query, it
-- just cancels the waiting.
-------------------------------------------------------------------------------
function clearRequestQueue()
	-- %todo
end

-------------------------------------------------------------------------------
-- Send (or resend) the query for the current request.
-------------------------------------------------------------------------------
function sendQuery(request)
	if (request.querySent) then
		debugPrint("Resending query...", DebugLib.Level.Notice);
	else
		debugPrint("Sending query...", DebugLib.Level.Notice);
	end

	-- Update the query status.
	request.querySent = true;
	request.receivedQueryResponse = false;
	request.lastQueryResponseTime = GetTime();

	-- Send the query.
	local parameters = request.parameters;
	hookQueryAuctionItems = false;
	QueryAuctionItems(
		parameters.name,
		parameters.minLevel,
		parameters.maxLevel,
		parameters.invTypeIndex,
		parameters.classIndex,
		parameters.subclassIndex,
		parameters.page,
		parameters.isUsable,
		parameters.qualityIndex);
	hookQueryAuctionItems = true;
end

-------------------------------------------------------------------------------
-- Handles auction item list updates. Updates fall under one of three
-- categories:
-- Sort Change - The update was due to a sort (local operation).
-- Query Response - The update was due to query sent to the server.
-- Current Bid Change - The update was due to a current bid change.
-------------------------------------------------------------------------------
function onAuctionItemListUpdate()
	local updatedAuctions = getAuctionsOnCurrentPage();

	-- Check if the update is a result of a sort.
	if (CurrentPage and PerformingSortAuctionItems) then
		-- Update the current page. Note that we lose any auction ids that have
		-- been assigned to auctions on the current page because we cannot tell
		-- which auction is which anymore.
		CurrentPage.auctions = updatedAuctions;
		debugPrint("onAuctionItemListUpdate() - sort complete", DebugLib.Level.Notice);
		return;
	end

	-- Check if the update is the result of a query.
	if (isQueryInProgress() and doAuctionsMatchQuery(updatedAuctions, QueryRequestQueue[1].parameters)) then
		local request = QueryRequestQueue[1];
		local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");

		-- Update the current page.
		CurrentPage = {
			query = request.parameters;
			pageNum = request.parameters.page;
			lastSeen = time();
			auctions = updatedAuctions;
			isLastPage = false;
		};
		if (lastIndexOnPage == 0 or (CurrentPage.pageNum == 0 and Scanned == 1)) then
			CurrentPage.isLastPage = true;
			debugPrint("isLastPage Now True", DebugLib.Level.Notice);
		elseif (CurrentPage.pageNum * NUM_AUCTION_ITEMS_PER_PAGE + lastIndexOnPage == totalAuctions) and ((Auctioneer.ScanManager.IsQueryStyle() or BlizzardScan)) then
			CurrentPage.isLastPage = true;
			debugPrint("isLastPage is now True", DebugLib.Level.Notice);
			ForwardScan = 1;
		end

		-- Update the receive time of the query request.
		request.lastQueryResponseTime = GetTime();
		request.receivedQueryResponse = true;

		-- Check if the query is complete. The query is considered
		-- complete once we have received all the owners. Assume true
		-- until otherwise proven false.
		local complete = true;
		for index, auction in pairs(updatedAuctions) do
			-- Ignore auctions with no item name, retry auctions with no owner 3 times before giving up(Blizzard bugs).
			-- Missing (nil?) (all?)  details except for auction at position X is due to server restart. its itemCache is cleared but the AH is not
			--   it just so happens that the server does not classify an item as being valid (that you can link, display, etc) if its only present in the AH
			--   These auctions should be skipped.
			-- Empty string owner alone is akin to 'Unknown Entity'.
			--   should cause 2 more attempts at scanning the page, then the item should be skipped.
			if (not auction.name) then
				Auctioneer.Util.ChatPrint("Auctioneer alert: Nil name detected. Please contact Auctioneer support ASAP.");
				Auctioneer.Util.ChatPrint("(This is a very rare condition which requires live servers for testing. Your data should be fine.)");
				debugPrint("onAuctionItemListUpdate() - No name", DebugLib.Level.Warning);
				break;
			end
			if (not auction.owner or auction.owner == "") then
				if (request.ownerTimeout) then auction.owner = "unknown"
				else
					debugPrint("onAuctionItemListUpdate() - No owner for "..auction.name, DebugLib.Level.Warning);
					-- No dice... there should be more updates coming... or maybe not.
					complete = false;
					break;
				end
			end
		end

		-- If the request is complete, remove it from the queue.
		if (complete) then
			debugPrint("onAuctionItemListUpdate() - query complete", DebugLib.Level.Notice);
			removeRequestFromQueue(QueryAuctionItemsResultCodes.Complete);
		else
			debugPrint("onAuctionItemListUpdate() - query incomplete (missing owner)", DebugLib.Level.Warning);
		end

		-- All done with update!
		return;
	end

	-- Check if this is a refresh of the current page. A refresh would be
	-- caused by a bid or an outbid.
	if (
		CurrentPage and
		doAuctionsMatchQuery(updatedAuctions, CurrentPage.query) and
		reconcileAuctionLists(CurrentPage.auctions, updatedAuctions)
	) then
		debugPrint("onAuctionItemListUpdate() - query refresh", DebugLib.Level.Notice);
		return;
	end

	-- Unknown update, so reset page and try again.
	debugPrint("onAuctionItemListUpdate() - unknown update resetting page and trying again", DebugLib.Level.Warning);
	CurrentPage = nil;
end

-------------------------------------------------------------------------------
-- Checks if we are awaiting the results of a query.
-------------------------------------------------------------------------------
function isQueryInProgress()
	return (#QueryRequestQueue > 0 and QueryRequestQueue[1].querySent);
end

-------------------------------------------------------------------------------
-- Checks if we are awaiting the results of bid. This method may return a
-- different result than the bid manager because we could still be waiting for
-- the auction list to update as a result of a bid.
-------------------------------------------------------------------------------
function isBidInProgress()
	return (#PendingBidInfo > 0);
end

-------------------------------------------------------------------------------
-- Creates a list of auctions on the current page using Blizzard's API.
-------------------------------------------------------------------------------
function getAuctionsOnCurrentPage()
	-- Get the contents of the page.
	local auctions = {};
	local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");
	for indexOnPage = 1, lastIndexOnPage do
		local auction = getAuctionByIndex("list", indexOnPage);
		table.insert(auctions, auction);
	end
	return auctions;
end

-------------------------------------------------------------------------------
-- Checks if two queries are the same (except for page number).
-------------------------------------------------------------------------------
function doQueriesMatch(query1, query2)
	return(
		query1.name == query2.name and
		query1.minLevel == query2.minLevel and
		query1.maxLevel == query2.maxLevel and
		query1.invTypeIndex == query2.invTypeIndex and
		query1.classIndex == query2.classIndex and
		query1.subclassIndex == query2.subclassIndex and
		query1.isUsable == query2.isUsable and
		query1.qualityIndex == query2.qualityIndex
	)
end

-------------------------------------------------------------------------------
-- Checks if the auctions all match the specified query.
-------------------------------------------------------------------------------
function doAuctionsMatchQuery(auctions, query)
	for _, auction in ipairs(auctions) do
		local itemKey = Auctioneer.ItemDB.CreateItemKeyFromAuction(auction);
		if (not Auctioneer.SnapshotDB.DoesItemKeyMatchQuery(itemKey, query)) then
			return false;
		end
	end
	return true;
end

-------------------------------------------------------------------------------
-- Checks if the auctions match by signature.
-------------------------------------------------------------------------------
function reconcileAuctionLists(oldList, newList)
	-- First check if the its a list of the same auctions. Take into account
	-- auctions that are removed because of buyouts.
	local oldIndex = 1;
	local newIndex = 1;
	while (oldIndex < #oldList and newIndex < #newList) do
		local oldAuction = oldList[oldIndex];
		local oldSignature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(oldAuction);
		local newAuction = newList[newIndex];
		local newSignature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(newAuction);

		-- Check if the signatures match. If the signatures don't match it
		-- could be because an auction was bought out and is now missing from
		-- the new list.
		if (oldSignature == newSignature) then
			newIndex = newIndex + 1;
		else
			-- If the auction does not have an auction id then we cannot tell
			-- there was a pending buyout.
			if (oldAuction.auctionId == nil) then
				return false;
			end

			-- Check if there is a pending bid for this auction id.
			local bidInfo = PendingBidInfo[oldAuction.auctionId];
			if (bidInfo == nil or bidInfo.receivedAuctionItemListUpdate) then
				return false;
			end

			-- Check if the pending bid was a buyout. If not, it could not have
			-- been bought out.
			if (oldAuction.buyoutPrice ~= bidInfo.bid) then
				return false;
			end
		end
		oldIndex = oldIndex + 1;
	end

	-- Check if we matched up all the auctions in both lists.
	if (oldIndex ~= #oldList and newIndex ~= #newList) then
		return false;
	end

	-- Now that we know the lists match we need to update the cache and
	-- snapshot.
	local oldIndex = 1;
	local newIndex = 1;
	while (oldIndex < #oldList and newIndex < #newList) do
		-- Get the auctions and their signatures.
		local oldAuction = oldList[oldIndex];
		local oldSignature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(oldAuction);
		local newAuction = newList[newIndex];
		local newSignature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(newAuction);

		-- Check if the signatures match.
		if (oldSignature == newSignature) then
			-- Check if the auction bid has changed.
			if (oldAuction.bidAmount ~= newAuction.bidAmount or
				oldAuction.highBidder ~= newAuction.highBidder) then
				-- Update the old auction with the new auction.
				oldAuction.bidAmount = newAuction.bidAmount;
				oldAuction.highBidder = newAuction.highBidder;
				oldAuction.timeLeft = newAuction.timeLeft;
				oldAuction.lastSeen = newAuction.lastSeen;
				debugPrint("reconcileAuctionLists(): Updated auction at index "..oldIndex.." in cache", DebugLib.Level.Info);

				-- If we have an auction id for the old auction, inform the
				-- snapshot of the update.
				if (oldAuction.auctionId) then
					-- Update the snapshot.
					debugPrint("Updating auction "..oldAuction.auctionId.." in snapshot", DebugLib.Level.Info);
					Auctioneer.SnapshotDB.UpdateAuction(oldAuction);

					-- Update the pending bid list.
					local bidInfo = PendingBidInfo[oldAuction.auctionId];
					if (bidInfo) then
						if (bidInfo.receivedBidComplete) then
							PendingBidInfo[oldAuction.auctionId] = nil;
							debugPrint("Removed pending bid for auction "..oldAuction.auctionId, DebugLib.Level.Info);
						else
							bidInfo.receivedAuctionItemListUpdate = true;
							debugPrint("Deferring removal of pending bid for auction "..oldAuction.auctionId, DebugLib.Level.Notice);
						end
					end
				end
			end

			-- Increment the lists.
			newIndex = newIndex + 1;
			oldIndex = oldIndex + 1;
		else
			-- The auction was bought out. Remove it from the page cache.
			table.remove(oldList, oldIndex);
			debugPrint("reconcileAuctionLists(): Removed auction "..oldAuction.auctionId.." from the cache", DebugLib.Level.Info);

			-- If we have an auction id for the old auction, inform the
			-- snapshot of the update.
			if (oldAuction.auctionId) then
				-- Update the snapshot.
				debugPrint("Removing auction "..oldAuction.auctionId.." from the snapshot", DebugLib.Level.Info);
				Auctioneer.SnapshotDB.RemoveAuction(oldAuction);

				-- Update the pending bid list.
				local bidInfo = PendingBidInfo[oldAuction.auctionId];
				if (bidInfo) then
					if (bidInfo.receivedBidComplete) then
						PendingBidInfo[oldAuction.auctionId] = nil;
						debugPrint("Removed pending bid for auction "..oldAuction.auctionId, DebugLib.Level.Info);
					else
						bidInfo.receivedAuctionItemListUpdate = true;
						debugPrint("Deferring removal of pending bid for auction "..oldAuction.auctionId, DebugLib.Level.Notice);
					end
				end
			end
		end
	end

	return true;
end

-------------------------------------------------------------------------------
-- Adds a page to the cache.
-------------------------------------------------------------------------------
function addPageToCache(page, updateSnapshot)
	-- Check if this query matches the last query. If not, we need to toss the
	-- page cache and start a new one.
	if (not doQueriesMatch(PageCacheQuery, page.query)) then
		debugPrint("Clearing the page cache (query doesn't match last query)", DebugLib.Level.Warning);
		PageCache = {};
		PageCacheQuery = page.query;
	end

	-- Add the page to the cache.
	if (not page) then debugPrint("Not page", DebugLib.Level.Error); end
	PageCache[page.pageNum] = page;
	for _, auction in pairs(page.auctions) do
		Auctioneer.EventManager.FireEvent("AUCTIONEER_AUCTION_SEEN", auction);
	end
	debugPrint("Added page "..page.pageNum.." to the cache", DebugLib.Level.Info);

	-- Check if we have all the pages (numbering starts at 0).
	if (updateSnapshot) then
		local pageNum = 0;
		while (true) do
			local page = PageCache[pageNum];
			if (pageNum ~= 0) then debugPrint("Page: "..pageNum, DebugLib.Level.Info); end
			if (page == nil) then
				if (pageNum ~= 0) then debugPrint("Still missing page "..pageNum, DebugLib.Level.Warning); end
				Scanned = CurrentPage.pageNum;
				break;
			elseif (page.isLastPage) then
				processQuery(pageNum)
				break;
			end
			pageNum = pageNum + 1;
		end
	end
end

-------------------------------------------------------------------------------
-- calls functions to check for duplicates and update the Snapshot
-------------------------------------------------------------------------------
function processQuery(pNum)
	debugPrint("Seen all "..(pNum + 1).." page(s), updating snapshot", DebugLib.Level.Info);
	Auctioneer.ScanManager.SetUpdated(true);
	local auctions, scannedInReverse = getAuctionsInCache();
	Auctioneer.SnapshotDB.UpdateForQuery(nil, PageCacheQuery, auctions, (not scannedInReverse));
	clearPageCache();
	Scanned = 0;
end

-------------------------------------------------------------------------------
-- Gets the list of auctions in the cache.
-------------------------------------------------------------------------------
function getAuctionsInCache()
	local auctions = {};
	local scannedInReverse = true;
	for pageNum, page in pairs(PageCache) do
		-- Get the auctions on this page.
		local auctionsOnPage = page.auctions;

		-- Get the previous page, if any.
		local prevPage = PageCache[pageNum + 1];
		if (prevPage) then
			-- Check if the previous page was seen before this page.
			if (prevPage.lastSeen < page.lastSeen) then
				-- Yep, check for dups on the previous page.
				local auctionsOnPrevPage = prevPage.auctions;
				checkForDups(auctionsOnPage, auctionsOnPrevPage);
			elseif (not ForwardScan) then
				-- Scan was still done in reverse but due to bugged auctions we can't check for dups
				debugPrint("Bugged auctions encountered cannot check for dupes", DebugLib.Level.Warning);
			else
				debugPrint("Scan was not done in reverse!", DebugLib.Level.Warning);
				scannedInReverse = false;
			end
		end

		-- Add the auctions on this page the list.
		for indexOnPage, auctionOnPage in pairs(auctionsOnPage) do
			table.insert(auctions, auctionOnPage);
		end
	end
	-- clean up scan flags
	BlizzardScan = nil; 
	ForwardScan = nil;
	return auctions, scannedInReverse;
end

-------------------------------------------------------------------------------
-- Compares the auction against the previous page. If the auction matches an
-- auction on the previous page, the auction on the previous page is flagged
-- as a dup.
-------------------------------------------------------------------------------
function checkForDups(auctions, auctionsOnPrevPage)
	for _, auction in pairs(auctions) do
		local signature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(auction);
		for _, auctionOnPrevPage in pairs(auctionsOnPrevPage) do
			if (not auctionOnPrevPage.dup and
				signature == Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(auctionOnPrevPage) and
				auction.bidAmount == auctionOnPrevPage.bidAmount and
				auction.timeLeft == auctionOnPrevPage.timeLeft) then
				debugPrint("Marking auction as potential dup", DebugLib.Level.Notice);
				auctionOnPrevPage.dup = true;
				return;
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Clears the cached pages for the query.
-------------------------------------------------------------------------------
function clearPageCache()
	PageCache = {};
	PageCacheQuery = {};
end

-------------------------------------------------------------------------------
-- Creates an auction structure from the listType and index. All of the fields
-- in the auction structure are nil safe. The auctionId field will always be
-- nil. The auctionId can be obtained by calling getAuctionId();
-------------------------------------------------------------------------------
function getAuctionByIndex(listType, index)
	local auction;
	local lastIndexOnPage, totalAuctions = GetNumAuctionItems(listType);
	if (index >= 0 and index <= lastIndexOnPage) then
		auction = {
			ahKey = Auctioneer.Util.GetAuctionKey();
		};

		-- Get the item link and decompose it.
		local itemLink = GetAuctionItemLink(listType, index);
		if (itemLink) then
			local itemId, suffixId, enchantId, uniqueId = EnhTooltip.BreakLink(itemLink);
			auction.itemId = nilSafeNumber(itemId);
			auction.suffixId = nilSafeNumber(suffixId);
			auction.enchantId = nilSafeNumber(enchantId);
			auction.uniqueId = nilSafeNumber(uniqueId);
		else
			auction.itemId = 0;
			auction.suffixId = 0;
			auction.enchantId = 0;
			auction.uniqueId = 0;
		end

		-- Get the auction information.
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo(listType, index);
		auction.name = nilSafeString(name);
		auction.texture = nilSafeString(texture);
		auction.count = nilSafeNumber(count);
		auction.quality = nilSafeNumber(quality);
		auction.canUse = (canUse ~= nil);
		auction.level = nilSafeNumber(level);
		auction.minBid = nilSafeNumber(minBid);
		auction.minIncrement = nilSafeNumber(minIncrement);
		auction.buyoutPrice = nilSafeNumber(buyoutPrice);
		auction.bidAmount = nilSafeNumber(bidAmount);
		auction.highBidder = (highBidder ~= nil);
		auction.owner = nilSafeString(owner);

		-- Get the time left.
		local timeLeft = GetAuctionItemTimeLeft(listType, index);
		auction.timeLeft = timeLeft or 0;

		-- Add the last seen as now.
		auction.lastSeen = time();
	end
	return auction;
end

-------------------------------------------------------------------------------
-- Gets the auction id for auction at the specified index. This may result in
-- a partial snapshot update if the auction id isn't already known. If the
-- auction id cannot be determined (such as for non "list" auctions), nil is
-- returned.
-------------------------------------------------------------------------------
function getAuctionId(listType, index)
	if (listType == "list") then
		if (CurrentPage) then
			-- Get the signature of the auction in question.
			local auction = CurrentPage.auctions[index];
			if (auction.auctionId == nil) then
				-- Get a list of all auctions in our cache that match the
				-- signature of the auciton in question.
				local auctions = {};
				local signature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(auction);
				for _, thisPage in pairs(PageCache) do
					for _, thisAuction in pairs(thisPage.auctions) do
						local thisSignature = Auctioneer.SnapshotDB.CreateAuctionSignatureFromAuction(thisAuction);
						if (signature == thisSignature) then
							table.insert(auctions, thisAuction);
						end
					end
				end

				-- Do a partial update of the snapshot so we auction ids get assigned.
				debugPrint("Updating snapshot with partial results for "..signature, DebugLib.Level.Notice);
				Auctioneer.SnapshotDB.UpdateForSignature(nil, signature, auctions, true);
			end

			-- Return the auction id of the auction.
			return auction.auctionId;
		else
			debugPrint("GetAuctionId() - ignoring due to no last query!", DebugLib.Level.Warning);
		end
	else
		debugPrint("GetAuctionId() - ignoring due to invalid listType!", DebugLib.Level.Warning);
	end
end

-------------------------------------------------------------------------------
-- Checks if an auction has valid values. This method should be used to
-- validate auctions before adding them to the database. That way we can
-- insure the the validity of the database.
-------------------------------------------------------------------------------
function isAuctionValid(auction)
	-- Must have an auction. Duh!
	if (not auction) then
		debugPrint("isAuctionValid() - false (no auction)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a name.
	if (auction.name == "") then
		debugPrint("isAuctionValid() - false (bad name)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a count.
	if (auction.count < 1) then
		debugPrint("isAuctionValid() - false (bad count)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a valid bid.
	if (auction.minBid < 1 or auction.minBid > Auctioneer.Core.Constants.MaxAllowedFormatInt) then
		debugPrint("isAuctionValid() - false (bad minBid)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a valid buyout.
	if (auction.buyoutPrice < 0 or auction.buyoutPrice > Auctioneer.Core.Constants.MaxAllowedFormatInt) then
		debugPrint("isAuctionValid() - false (bad buyoutPrice)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a valid bid amount.
	if (auction.bidAmount < 0 or auction.bidAmount > Auctioneer.Core.Constants.MaxAllowedFormatInt) then
		debugPrint("isAuctionValid() - false (bad bidAmount)", DebugLib.Level.Info);
		return false;
	end

	-- Must have a valid owner.
	if (auction.owner == "") then
		debugPrint("isAuctionValid() - false (bad owner)", DebugLib.Level.Info);
		return false;
	end

	return true;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafeString(string)
	return string or "";
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function nilSafeNumber(number)
	return number or 0;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function normalizeNumericQueryParam(param)
	return tonumber(param) or param;
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
	return Auctioneer.Util.DebugPrint(message, "AucQueryManager", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.QueryManager = {
	CanSendAuctionQuery = canSendAuctionQuery;
	ClearPageCache      = clearPageCache;
	GetAuctionByIndex   = getAuctionByIndex;
	GetAuctionId        = getAuctionId;
	IsAuctionValid      = isAuctionValid;
	IsQueryInProgress   = isQueryInProgress;
	Load                = load;
	ProcessQuery        = processQuery;
	QueryAuctionItems   = queryAuctionItems;
}

function Auctioneer.QueryManager.GetRequestQueue()
	return QueryRequestQueue
end
