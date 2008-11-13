--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucScanManager.lua 2510 2007-11-16 21:13:09Z RockSlice $

	ScanManager - manages AH scanning

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucScanManager.lua $", "$Rev: 2510 $")

-------------------------------------------------------------------------------
-- Function definitions
-------------------------------------------------------------------------------
local addRequestToQueue;
local cancelScan;
local debugPrint
local isQueryStyle;
local isScanning;
local killHook;
local load;
local onAuctionAdded;
local onAuctionRemoved;
local onAuctionUpdated;
local onEventHook;
local queryCompleteCallback;
local removeRequestFromQueue;
local scan;
local scanAll;
local scanCategories;
local scanEnded;
local scanQuery;
local scanStarted;
local sendQuery;
local setUpdated;
local updateScanProgressUI;

local DebugLib = Auctioneer.Util.DebugLib
-------------------------------------------------------------------------------
-- Enumerations
-------------------------------------------------------------------------------
-- The states, which a scan request can enter.
local ScanRequestState = {
	WaitingToQuery        = "WaitingToQuery";        -- request is waiting in queue to be sent to the query manager
	WaitingForQueryResult = "WaitingForQueryResult"; -- request is waiting in queue to be processed by the callback function
	Done                  = "Done";                  -- request is done
	Canceled              = "Canceled";              -- request is meant to be canceled
	Failed                = "Failed";                -- request failed
}

-------------------------------------------------------------------------------
-- Table definitions
-------------------------------------------------------------------------------
--[[
	-- The scan request table contains the description of a single scan request.
	-- [in] means that this variable must/can be set before the request is sent
	--      to the queue
	-- [out] means that this variable is automatically being set throghout
	--       processing the request
	ScanRequestTable = {
		[description]     = (string) Describes what the scan is doing. This string
		                    [in]     is being displayed on the AH frame, while
		                             scanning is in progress.
		                             _AUCT('AuctionScanAll') for scanAll()
		                             _AUCT('AuctionScanCat') for scanCategories()
		                             _AUCT('AuctionScanAuctions') for scanQuery()
		                             This value must never be nil.
		[name]            = (string) (part of) the name of items to be scanned
		                    [in]     nil, if no name specified
		[minLevel]        = (number) minimum level of items to be scanned
		                    [in]     nil, if no minimum level specified
		[maxLevel]        = (number) maximum level of items to be scanned
		                    [in]     nil, if no maximum level specified
		[invTypeIndex]    = (number) index of inventory type of items to be scanned
		                    [in]     nil, if no inventory type specified
		[classIndex]      = (number) index of item class of items to be scanned
		                    [in]     nil, if no item class specified
		[subclassIndex]   = (number) index of item subclass of items to be scanned
		                    [in]     nil, if no item subclass specified
		[qualityIndex]    = (number) index of item quality of items to be scanned
		                    [in]     nil, if no item quality specified
		[isUsable]        = (boolean) scan for items only, which the current
		                    [in]      character can use?
		                              nil equals setting this to false
		[page]            = (number) number of page to be scanned
		                    [in]     nil, scan all pages
		[pages]           = (number) number of pages of auctions for the current
		                    [out]    scan request
		[totalAuctions]   = (number) number of auctions, which are going to be
		                    [out]    be scanned in this scan request
		[nextPage]        = (number) page to be scanned next, respectively the
		                    [out]    page which has been just scanned
		                             -1, if finished
		[auctionsScanned] = (number) number of auctions on the current page, which
		                    [out]    have already been scanned
		[state]           = (enum) ScanRequestState - Indicates, which state this
		                    [out]  request is currently in (see enum definitions)
		[startTime]       = (float) The time, when scanning the first page started
		                    [out]   nil, if not scanning yet, or just scanning a
		                            single page
	}
]]

-------------------------------------------------------------------------------
-- Local variables
-------------------------------------------------------------------------------
-- Queue of scan requests.
--    ScanRequestQueue{         - (list) List of scan requests
--       [x] = ScanRequestTable - (table) ScanRequestTable (see table definitions)
--   }
local ScanRequestQueue = {};

-- Counters that keep track of the number of auctions added, updated or removed
-- during the course of a scan.
local AuctionsAdded   -- (number)
local AuctionsUpdated -- (number)
local AuctionsRemoved -- (number)

-- Counter which records the number of auctions which have been already written
-- to the database.
local AuctionsWrittenToDB -- (number)

-- Contains the state of the last request, before it was removed from the scan
-- request queue.
local LastRequestResult -- (enum) ScanRequestState (see enumerations)

-- Flag which indicates, if a QueryStyleScan is queued or currently in progress.
local QueryStyleScan = false -- (boolean)

-- Flag that indicates, if scanning is in progress.
local Scanning = false -- (boolean)

-- Flag that indicates that the database has already been updated on this scan.
local HasUpdated = false -- (boolean)

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- This function is called when the ADDON_LOADED event is fired for Auctioneer.
-- It registers the function onEventHook() to be called when the event
-- AUCTION_HOUSE_CLOSED is fired.
--
-- called by:
--    globally - AucScanManager.Load()
--       called in Auctioneer: AucCore.addOnLoaded()
--
-- calls:
--    Stubby.RegisterEventHook - always
-------------------------------------------------------------------------------
function load()
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_ScanManager", onEventHook);
end

-------------------------------------------------------------------------------
-- Called each frame to check out if ScanManager has to perform any operations.
-- If so, it can start/stop a scanning request and dispatch requests to the
-- QueryManager.
--
-- called by:
--    globally - AucScanManager_OnUpdate()
--       called in OnUpdate of the AuctioneerFrame frame
--
-- calls:
--    AucQueryManager.CanSendAuctionQuery() - if a request is queued
--    scanStarted() - before a queued request is queried and not scanning atm
--    sendQuery()   - if a request is ready to be sent
--    scanEnded()   - if the queue is empty and scanning atm
--
-- parameters:
--    elapsed - (float) passed time in seconds.milliseconds, since this
--                      function's last call --- this value is reserved for
--                      future use
-------------------------------------------------------------------------------
function AucScanManager_OnUpdate(elapsed)
	local request = ScanRequestQueue[1];
	if (request) then
		if (request.state == ScanRequestState.WaitingToQuery and Auctioneer.QueryManager.CanSendAuctionQuery()) then
			if (not Scanning) then
				scanStarted();
			end
			sendQuery(request);
		end
	elseif (Scanning) then
		scanEnded();
	end
end

-------------------------------------------------------------------------------
-- ScanManager's onEvent handler. It processes all events which are dispatched
-- to ScanManager and performs the necessary processing.
-- Currently this function is only registered for AUCTION_HOUSE_CLOSED.
--
-- called by:
--    event - AUCTION_HOUSE_CLOSED
--
-- calls:
--    cancelScan() - when AUCTION_HOUSE_CLOSED is fired
--
-- parameters:
--    _     - ignoreing the first parameter, which is an empty table, since no
--            parameters are passed when registering this function with Stubby
--            (see Stubby.RegisterEventHook() for more details)
--    event - (string) name of the event which was fired
--    ...   - contains all event paramters --- this is reserved for future use
--            (see Stubby.RegisterEventHook() for more details)
-------------------------------------------------------------------------------
function onEventHook(_, event, ...)
	if (event == "AUCTION_HOUSE_CLOSED") then
		cancelScan();
	end
end

-------------------------------------------------------------------------------
-- Indicates wheterh or not a scan is in progress.
--
-- called by:
--    globally - AucScanManager.IsScanning()
--       called in Auctioneer: AucCommand.protectWindow()
--       called in Auctioneer: AucQueryManager.postCanSendAuctionQuery()
--
-- returns:
--    true, if scanning is in progress
--    false, otherwise
-------------------------------------------------------------------------------
function isScanning()
	return Scanning;
end

-------------------------------------------------------------------------------
-- Queues a scan request of an AH scan of the categories selected in the UI.
--
-- called by:
--    globally AucScanManager.Scan()
--       called in Auctioneer: AucAPI.requestAuctionScan()
--       called in Auctioneer: AucCommand.mainHandler()
--       called in Auctioneer: AucFrameBrowse.BrowseScanButton_OnClick()
--
-- calls:
--    scanAll()               - if all categories are selected
--    scanCategories()        - if not each category is selected
--    GetAuctionItemClasses() - always
--
-- returns:
--    true, if the scan was requested
--    false, if the scan could not be requested, due to another scan currently
--           in progress
-------------------------------------------------------------------------------
function scan()
	if not AuctionFrame then return false end

	-- Get the list of categories checked (by index).
	categories = {};
	local allCategories = {GetAuctionItemClasses()};
	for category, name in ipairs(allCategories) do
		if (tostring(Auctioneer.Command.GetFilterVal("scan-class"..category)) == "on") then
			table.insert(categories, category);
		end
	end

	-- Scan everything or only selected categories?
	if (#allCategories == #categories) then
		debugPrint("Scanning all categories", DebugLib.Level.Info)
		return scanAll();
	else
		debugPrint("Scanning "..#categories.." categories", DebugLib.Level.Info)
		return scanCategories(categories);
	end
end

-------------------------------------------------------------------------------
-- Queues a scan request of an AH scan of all auctions.
--
-- called by:
--    scan() - if all categories are selected
--    globally AucScanManager.ScanAll()
--
-- calls:
--    addRequestToQueue() - if no queued requests atm
--
-- returns:
--    true, if the scan was requested
--    false, if the scan could not be requested, since another scan is currently in progress
-------------------------------------------------------------------------------
function scanAll()
	if not AuctionFrame then return false end
	if (#ScanRequestQueue == 0) then
		-- Construct a scan all request.
		local request = {};
		request.description = _AUCT('AuctionScanAll');
		addRequestToQueue(request);
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!", DebugLib.Level.Warning)
		return false;
	end
end

-------------------------------------------------------------------------------
-- Queues a scan request of an AH scan of the specified categories.
--
-- called by:
--    scan() - if at least one category is not selected
--    globally AucScanManager.ScanCategories()
--
-- calls:
--    addRequestToQueue()         - if no queued requests atm and at least one
--                                  selected category
--    AucItemDB.GetCategoryName() - if no queued requests atm and at least one
--                                  selected category
--
-- parameters:
--    categories{ - (list) List of categories
--       [x] = index of selected category
--    }
--
-- returns:
--    true, if the scan was requested
--    false, if the scan could not be requested, due to another scan being
--           currently in progress
-------------------------------------------------------------------------------
function scanCategories(categories)
	if not AuctionFrame then return false end
	if (#ScanRequestQueue == 0) then
		-- Construct a scan request for each category requested.
		for index, category in pairs(categories) do
			local request = {};
			request.description = string.format(_AUCT('AuctionScanCat'), Auctioneer.ItemDB.GetCategoryName(category));
			request.classIndex = category;
			addRequestToQueue(request);
		end
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!", DebugLib.Level.Warning)
		return false;
	end
end

-------------------------------------------------------------------------------
-- Queues a scan request of an AH scan based on a query.
--
-- called:
--    globally AucScanManager.ScanQuery()
--       called in Auctioneer: AuctionFramePost - when pressing the UIRefresh
--                             button
--       called in Auctioneer: AuctionDropDownMenu - when choosing the refresh
--                             option (drop down menu is shown upon right-
--                             clicking on items in the result lists in
--                             AuctionFramePost and AuctionFrameSearch)
--
-- calls:
--    addRequestToQueue() - if no queued requests atm
--
-- parameters:
--    name          - (string) (part of) the name of items to be scanned
--                    nil, if no name specified
--    minLevel      - (number) minimum level of items to be scanned
--                    nil, if no minimum level specified
--    maxLevel      - (number) maximum level of items to be scanned
--                    nil, if no maximum level specified
--    invTypeIndex  - (number) index of inventory type of items to be scanned
--                    nil, if no inventory type specified
--    classIndex    - (number) index of item class of items to be scanned
--                    nil, if no item class specified
--    subclassIndex - (number) index of item subclass of items to be scanned
--                    nil, if no item subclass specified
--    page          - (number) number of page to be scanned
--                    nil, scan all pages
--    isUsable      - (boolean) scan for items only, which the current
--                    character can use?
--                    nil equals setting this to false
--    qualityIndex  - (number) index of item quality of items to be scanned
--                    nil, if no item quality specified
--
-- returns:
--    true, if the scan query was sucessfully queued
--    false, otherwise
-------------------------------------------------------------------------------
function scanQuery(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	if (#ScanRequestQueue == 0) then
		-- Construct the scan request.
		local request = {
			description = _AUCT('AuctionScanAuctions');
			name = name;
			minLevel = minLevel;
			maxLevel = maxLevel;
			invTypeIndex = invTypeIndex;
			classIndex = classIndex;
			subclassIndex = subclassIndex;
			page = page;
			isUsable = isUsable;
			qualityIndex = qualityIndex;
		};
		addRequestToQueue(request);
		QueryStyleScan = true;
		debugPrint("Query Style Scan queued", DebugLib.Level.Info)
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!", DebugLib.Level.Warning)
		return false;
	end
end

-------------------------------------------------------------------------------
-- Removes any scan request from the queue.
--
-- called by:
--    onEventHook - if AUCTION_HOUSE_CLOSED was thrown
--
-- calls:
--    removeRequestFromQueue() - for each request in the queue
-------------------------------------------------------------------------------
function cancelScan()
	-- %todo: We should probaby wait for the result of any query that is in
	-- progress.
	while (#ScanRequestQueue > 0) do
		ScanRequestQueue[1].state = ScanRequestState.Canceled;
		removeRequestFromQueue();
	end
end

-------------------------------------------------------------------------------
-- Adds a request at the end of the queue.
--
-- called by:
--    scanAll()        - if queue is empty
--    scanCategories() - if queue is empty and at least one category was
--                       selected
--    scanQuery()      - if queue is empty
--
-- parameters:
--    request - (table) ScanRequestTable (see table definitions)
--
-- remarks:
--    Note that since this function is only called, if the queue is empty,
--    the resulting queue will always contain requests from one scan, only.
--    If called by scanAll() or scanQuery() this means that only one request is
--    present. In case of scanCategories(), this means that there can be several
--    scan requests (one request for each category).
-------------------------------------------------------------------------------
function addRequestToQueue(request)
	request.totalAuctions   = 0;
	request.nextPage        = 0;
	request.auctionsScanned = 0;
	request.state           = ScanRequestState.WaitingToQuery;
	table.insert(ScanRequestQueue, request);
	debugPrint("Added request to back of queue", DebugLib.Level.Info)
end

-------------------------------------------------------------------------------
-- Removes the request at the head of the queue.
-- If the removed request indicates that a scan was finished, updates the
-- counter.
--
-- called by:
--    cancelScan()            - for each queued scan request
--    queryCompleteCallback() - if a scan request is complete, or failed
-------------------------------------------------------------------------------
function removeRequestFromQueue()
	if (#ScanRequestQueue > 0) then
		-- Remove the request from the queue.
		local request = ScanRequestQueue[1];
		table.remove(ScanRequestQueue, 1);
		debugPrint("Removed request from queue with result: "..request.state, DebugLib.Level.Notice)

		-- If the request succeeded, add the auctions scanned to the total.
		LastRequestResult = request.state;
		if (LastRequestResult == ScanRequestState.Done) then
			AuctionsWrittenToDB = AuctionsWrittenToDB + request.auctionsScanned
			debugPrint("AuctionsScanned: "..AuctionsWrittenToDB, DebugLib.Level.Notice)
		end
	end
end

-------------------------------------------------------------------------------
-- Sends the next scan request to the query manager.
--
-- called by:
--    AucScanManager_OnUpdate - if a request is waiting in the queue to be sent
--                              to the query manager
--
-- calls:
--    AucQueryManager.QueryAuctionItems() - always
--
-- parameters:
--    request - (table) ScanRequestTable (see table definitions)
-------------------------------------------------------------------------------
function sendQuery(request)
	-- If this is the first query of the request, update the UI to say so.
	if (request.totalAuctions == 0) then
		BrowseNoResultsText:SetText(_AUCT('AuctionScanStart'):format(request.description));
	end

	-- Send the query!
	debugPrint("Requesting page "..request.nextPage, DebugLib.Level.Info)
	Auctioneer.QueryManager.QueryAuctionItems(
		request.name,
		request.minLevel,
		request.maxLevel,
		request.invTypeIndex,
		request.classIndex,
		request.subclassIndex,
		request.nextPage,
		request.isUsable,
		request.qualityIndex,
		10,
		3,
		queryCompleteCallback
	);
	request.state = ScanRequestState.WaitingForQueryResult;
end

-------------------------------------------------------------------------------
-- Called when our query request completes.
-- In case there is more than one page to be scanned, the first call to this
-- function initializes the following request to start a reverse scan. All
-- subsequent calls process the just scanned page and issue the scanning of
-- the next page.
-- If there is only one page to be scanned, this function is only called one
-- single time where it simply does the final processing (i.e. updates the
-- counter and calls removeRequestFromQueue()).
--
-- called by:
--    AucQueryManager.removeRequestFromQueue() - after the request is finished
--                                               and removed from the query
--                                               queue
--
-- calls:
--    removeRequestFromQueue()         - if the requested scan failed or is done
--    updateScanProgressUI()           - after scanning a page is done for each
--                                       page, except if only scanning one
--                                       single page
--    AucQueryManager.ClearPageCache() - after scanning a page is done for each
--                                       page, except if only scanning one
--                                       single page
--    AucQueryManager.ProcessQuery()   - if scanning only one page and the data
--                                       has not yet been processed
--    GetNumAuctionItems()             - always, unless an error occured
--    GetTime()                        - always, except if only scanning one
--                                       single page
--
-- parameters:
--    query  = (table) which contains the parameters used creating the query
--             This is reserved for future use.
--    result = (string) the querie's result code
-------------------------------------------------------------------------------
function queryCompleteCallback(query, result)
	local request = ScanRequestQueue[1];
	if (not request) or (request.state ~= ScanRequestState.WaitingForQueryResult) then
		debugPrint("WARNING: Received query complete callback in unexpected state", DebugLib.Level.Error)
		return
	end

	-- Check, if query failed
	if (result ~= QueryAuctionItemsResultCodes.Complete) and (result ~= QueryAuctionItemsResultCodes.PartialComplete) then
		debugPrint("Aborting request due to failed query!", DebugLib.Level.Error)
		-- set, so that the debug output in removeRequestFromQueue() will print the correct state
		request.state = ScanRequestState.Failed
		removeRequestFromQueue();
		return
	end

	-- Query succeeded so update the request.
	debugPrint("Scanned page "..request.nextPage, DebugLib.Level.Info)
	local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");

	-- Is this the first query?
	if (request.totalAuctions == 0) then
		-- This was the first query to initialize the request.
		request.totalAuctions = totalAuctions;
		request.pages = math.floor((totalAuctions - 1) / NUM_AUCTION_ITEMS_PER_PAGE) + 1;
		if (request.pages == 1) then
			-- There's one and only one page. Tally the auctions
			-- scanned and we are done!
			if (not HasUpdated) then
				Auctioneer.QueryManager.ProcessQuery(1);
			end
			request.nextPage = -1;
			request.auctionsScanned = lastIndexOnPage;
		else
			-- More then one page so we'll scan in reverse so as to
			-- not miss any auctions.
			-- We are about to start scanning... so safe the start time
			request.startTime = GetTime();
			-- set the nextPage to the last page (pages are indexed zero based, so
			-- if there are 67 pages to be scanned, the last one is page 66, the
			-- first one page 0)
			request.nextPage = request.pages - 1;
			Auctioneer.QueryManager.ClearPageCache();
		end
		debugPrint("Found "..request.totalAuctions.." auctions ("..request.pages.." pages)", DebugLib.Level.Notice)
	else
		-- Tweak the start time, if it happened in less than 5 seconds.
		local currentTime = GetTime();
		local timeElapsed = currentTime - request.startTime;
		-- nextPage has not been updated yet and therefore referes to the current
		-- page which has just been scanned.
		local pagesScanned = request.pages - request.nextPage;
		-- Scanning one page should take at least approximitaly 4-5 seconds due to
		-- blizzards restrictions on how fast a new page might be querried.
		-- Therefore scanning one page should never be faster then 4 seconds.
		--local minTimeElapsed = 4.0 * pagesScanned;
		debugPrint(pagesScanned.." pages scanned thus far in "..timeElapsed, DebugLib.Level.Info)
		--if (timeElapsed < minTimeElapsed) then
		--	debugPrint("Adjusted request.startTime to keep the time remaining accurate.", DebugLib.Level.Info)
		--	request.startTime = currentTime - minTimeElapsed;
		--end

		-- This was a subsequent query.
		request.nextPage = request.nextPage - 1;
		request.auctionsScanned = request.auctionsScanned + lastIndexOnPage;
		if request.nextPage >= 0 then
			-- update the scan progress only, if there is at least one page left to be processed
			updateScanProgressUI(request.description, pagesScanned, request.pages, request.startTime, request.auctionsScanned)
		end
	end

	-- Check if the scan is complete.
	if (request.nextPage < 0) then
		-- Request is complete!
		debugPrint("Reached the first page", DebugLib.Level.Info)
		request.state = ScanRequestState.Done;
		removeRequestFromQueue();
	else
		-- More pages to go...
		request.state = ScanRequestState.WaitingToQuery;
	end
end

-------------------------------------------------------------------------------
-- Hooked into AuctionFrameBrowser_OnEvent, AuctionFrameBrowser_Update and
-- AuctionFrameBrowser_Search, this function is used to disable the original
-- Auction Frame Browser functionality while scanning is in progress.
-- This fixes the "no search after scan"-bug.
--
-- called by:
--    AuctionFrameBrowse_OnEvent - before the original function, while scanning
--                                 is in progress
--    AuctionFrameBrowse_Update  - before the original function, while scanning
--                                 is in progress
--    AuctionFrameBrowse_Search  - before the original function, while scanning
--                                 is in progress
--
-- returns:
--    "killorig", always
-------------------------------------------------------------------------------
function killHook()
	return "killorig"
end

-------------------------------------------------------------------------------
-- Called before a scan request is despatched to the query manager, it disables
-- the Auction House UI elements to disallow searching and hides any search
-- elements, while scanning is in progress.
-- Also performs needed initialisations like hooking and resetting the counters,
-- clearing the page cache and setting the appropriate flags.
--
-- called by:
--    AucScanManager_OnUpdate() - if the next scan request in the queue is to be
--                                started
--
-- calls:
--    AucCommand.GetFilterVal()        - always
--    AucEventManager.RegisterEvent()  - always
--    AucQueryManager.ClearPageCache() - always
--    AucUtil.ProtectAuctionFrame()    - if protecting the AH window while
--                                       scanning
--    Stubby.RegisterFunctionHook()    - always
-------------------------------------------------------------------------------
function scanStarted()
	-- Protect window if needed
	if (Auctioneer.Command.GetFilterVal('protect-window') == 1) then
		-- We're set to protect only while scanning, so protect the window now
		Auctioneer.Util.ProtectAuctionFrame(true);
	end

	-- Don't allow AuctionFrameBrowse updates during a scan.
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_OnEvent", -200, killHook)
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_Update", -200, killHook)
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_Search", -200, killHook)

	-- Hide the results UI
	BrowseNoResultsText:SetText("");
	BrowseNoResultsText:Show();
	-- "result buttons" (i.e. the entries, shown in the saerch result list)
	for iButton = 1, NUM_BROWSE_TO_DISPLAY do
		button = getglobal("BrowseButton"..iButton);
		button:Hide();
	end
	BrowsePrevPageButton:Hide();
	BrowseNextPageButton:Hide();
	BrowseSearchCountText:Hide();
	BrowseBidButton:Disable();
	BrowseBuyoutButton:Disable();

	-- Initialize the counters for this scan.
	AuctionsAdded       = 0;
	AuctionsUpdated     = 0;
	AuctionsRemoved     = 0;
	AuctionsWrittenToDB = 0;

	-- Register for snapshot update events so we can track how many auctions
	-- are added, updated and removed.
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_ADDED", onAuctionAdded);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_UPDATED", onAuctionUpdated);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_REMOVED", onAuctionRemoved);

	-- Scanning has begun!
	Scanning = true;
	Auctioneer.Scanning.IsScanningRequested = true;
	Auctioneer.QueryManager.ClearPageCache();
	debugPrint("Scan started", DebugLib.Level.Info)
end

-------------------------------------------------------------------------------
-- Called after a scan is finished, this function handles the necessary updates
-- to the UI by reenabling buttons and functionality as well as outputs the
-- scan results to the chat channel as well as to the AH UI.
-- It also handles playing a soundfile, logging out the character or quitting
-- WoW as well as unprotecting the AH window again, if the user set the
-- appropriate options. 
-- In the end, a garbage collection is being issued to clean up the memory
-- consumption.
--
-- called by:
--    AucScanManager_OnUpdate() - if the request queue is empty, and we are
--                                scanning atm
--
-- calls:
--    AucCommand.GetFilter()            - always
--    AucEventManager.UnregisterEvent() - always
--    AucUtil.ChatPrint()               - always
--    AucUtil.ProtectAuctionFrame()     - if Auctioneer is set to protect the
--                                        AH window only while scanning
--    Stubby.UnregisterFunctionHook()   - always
--    Logout()                          - if Auctioneer is set to log out the
--                                        character when a scan is finished
--    PlaySoundFile()                   - if Auctioneer is set to play a sound
--                                        when a scan is finished
--    Quit()                            - if Auctioneer is set to quit WoW
--                                        when a scan is finished
-------------------------------------------------------------------------------
function scanEnded()
	-- Scanning has ended!
	Scanning = false;
	Auctioneer.Scanning.IsScanningRequested = false;
	debugPrint("Scan ended with result: "..LastRequestResult, DebugLib.Level.Info)

	-- Unregister snapshot events.
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_ADDED", onAuctionAdded)
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_UPDATED", onAuctionUpdated)
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_REMOVED", onAuctionRemoved)

	-- reenable the original Auction Browse Frame functions
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_OnEvent", killHook)
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_Update", killHook)
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_Search", killHook)

	-- Compile the results.
	local chatResultText;
	local uiResultText;
	if (LastRequestResult == ScanRequestState.Done) then
		chatResultText = _AUCT('ScanComplete')
		uiResultText   = _AUCT('UIScanComplete')
	elseif (LastRequestResult == ScanRequestState.Canceled) then
		chatResultText = _AUCT('ScanCanceled')
		uiResultText   = _AUCT('UIScanCanceled')
	else
		chatResultText = _AUCT('ScanFailed')
		uiResultText   = _AUCT('UIScanFailed')
	end
	local auctionsScannedMessage = _AUCT('AuctionTotalAucts'):format(AuctionsWrittenToDB);
	local auctionsAddedMessage   = _AUCT('AuctionNewAucts'):format(AuctionsAdded);
	local auctionsRemovedMessage = _AUCT('AuctionDefunctAucts'):format(AuctionsRemoved);
	local auctionsUpdatedMessage = _AUCT('AuctionUpdatedAucts'):format(AuctionsUpdated);

	-- Report the result to the chat window.
	Auctioneer.Util.ChatPrint(chatResultText..":");
	Auctioneer.Util.ChatPrint(auctionsScannedMessage);
	Auctioneer.Util.ChatPrint(auctionsAddedMessage);
	Auctioneer.Util.ChatPrint(auctionsRemovedMessage);
	Auctioneer.Util.ChatPrint(auctionsUpdatedMessage);

	-- Report the result to the UI.
	BrowseNoResultsText:SetText(strjoin("\n", uiResultText, auctionsScannedMessage, auctionsAddedMessage, auctionsRemovedMessage, auctionsUpdatedMessage));

	-- play finish sound/logout/quit when we performed a full or category scan,
	-- only
	if not QueryStyleScan then
		-- The followng was added by MentalPower to implement the "/auc finish-sound" command
		if Auctioneer.Command.GetFilter("finish-sound") then
			PlaySoundFile("Interface\\AddOns\\Auctioneer\\Sounds\\ScanComplete.mp3")
		end

		-- The followng was added by MentalPower to implement the "/auc finish" command
		local finish = Auctioneer.Command.GetFilterVal('finish');
		if finish == 1 then
			Logout();
		elseif finish == 2 then
			Quit();
		end
	end

	-- Reset Flags
	QueryStyleScan = false;
	HasUpdated     = false;

	-- Un-Protect window if needed
	if (Auctioneer.Command.GetFilterVal('protect-window') == 1) then
		-- We're set to protect only while scanning, so it's time to unprotect the window
		Auctioneer.Util.ProtectAuctionFrame(false);
	end

	-- Cleaning up after oneself is always a good idea.
	collectgarbage("collect");
end

-------------------------------------------------------------------------------
-- Called for each page when scanning multiple pages, after the last one
-- (which is the first one being scanned) this function updates the AH UI text
-- to reflect the current scanning progress.
--
-- called by:
--    queryCompleteCallback() - for each page after the first one
--
-- calls:
--    GetTime()       - always
--    SecondsToTime() - always
--
-- parameters:
--    description     - (string) the description to be displayed
--    pagesScanned    - (number) number of pages which already have been scanned
--    pages           - (number) number of pages to be scanned
--    startTime       - (float)  time in seconds.milliseconds when the scan
--                               started
--    auctionsScanned - (number) number of auctions which have already been
--                               scanned in the current scan request
-------------------------------------------------------------------------------
function updateScanProgressUI(description, pagesScanned, pages, startTime, auctionsScanned)
	local pagesToScan       = pages - pagesScanned
	local auctionsToScan    = pagesToScan * NUM_AUCTION_ITEMS_PER_PAGE
	local secondsElapsed    = GetTime() - startTime

	-- This explains the following calculation, since it's a bit tricky:
	-- pagesScanned * NUM_AUCTION_ITEMS_PER_PAGE:
	--    We assume that we scanned the maximum number of auctions on each page;
	--    even for the last page (which is scanned first, since we are scanning
	--    in reverese order) we assume that the it also contains the maximum
	--    number of auctions. That's because scanning one auction takes only a
	--    few milliseconds, while the most time the scan waits for the next page
	--    being sent.
	--    Blizzard limits the interval for requesting AH pages to something like
	--    4-5 seconds (the latency is included in this assumption) to reduce the
	--    serverload. Therefore most of the time Auctioneer is idle.
	--    That's why there is almost no difference in the needed time to scan 1
	--    or 50 auctions, and to get a more precise estimated time, we simply
	--    assume that each page contains these 50 items (which is defined by bliz
	--    in NUM_AUCTION_ITEMS_PER_PAGE).
	--    We finally get the [NUMBER_OF_SCANNED_AUCTIONS].
	-- [NUMBER_OF_SCANNED_AUCTION] / secondsElapsed:
	--    Deviding this number by the seconds which already elapsed, results in
	--    the very accurate [AUCTIONS_PER_SECOND] value. Note that this value is
	--    a float and the positions after the decimal represent the milliseconds.
	-- [AUCTIONS_PER_SECOND] * 100:
	--    This simply returns the [AUCTIONS_PER_HUNDRED_MILLISECONDS] with the
	--    rest of the milliseconds still being positioned after the decimal
	--    point.
	-- math.floor([AUCTIONS_PER_HUNDRED_MILLISECONDS]):
	--    This way we get rid of the milliseconds after the decimal point and
	--    get [AUCTIONS_PER_HUNDRED_MILLISECONDS_INT].
	-- [AUCTIONS_PER_HUNDRED_MILLISECONDS_INT] / 100:
	--    The final operation moves the milliseconds, which are still there, back
	--    by two digits after the decimal point.
	local auctionsPerSecond = math.floor(pagesScanned * NUM_AUCTION_ITEMS_PER_PAGE / secondsElapsed * 100) / 100
	local secondsLeft       = auctionsToScan / auctionsPerSecond

	-- Update the progress of this request in the UI to
	-- Auctioneer: [request.description]
	-- Scanning page [request.pages - request.nextPage] of [request.pages]
	-- Auctions per second: [auctionsScannedPerSecond]
	-- Estimated time left: [secondsLeft]
	-- Auctions scanned thus far: [AuctionsWrittenToDB]
	BrowseNoResultsText:SetText(
		_AUCT('AuctionPageN'):format(
			description,
			pagesScanned + 1,
			pages,
			-- tostring() is used instead of %f, so that the number won't be
			-- displayed with tailing zeroes
			tostring(auctionsPerSecond),
			SecondsToTime(secondsLeft),
			auctionsScanned + AuctionsWrittenToDB
		)
	)
end

-------------------------------------------------------------------------------
-- Callback function used to count the number of added auctions during a scan.
--
-- called by:
--    event - AUCTIONEER_AUCTION_ADDED, while scanning is in progress
-------------------------------------------------------------------------------
function onAuctionAdded()
	AuctionsAdded = AuctionsAdded + 1
end

-------------------------------------------------------------------------------
-- Callback function used to count the number of updated auctions during a scan.
--
-- called by:
--    event - AUCTIONEER_AUCTION_UPDATED, while scanning is in progress
-------------------------------------------------------------------------------
function onAuctionUpdated()
	AuctionsUpdated = AuctionsUpdated + 1
end

-------------------------------------------------------------------------------
-- Callback function used to count the number of removed auctions in the
-- complete scan request.
--
-- called by:
--    event - AUCTIONEER_AUCTION_REMOVED, while scanning is in progress
-------------------------------------------------------------------------------
function onAuctionRemoved()
	AuctionsRemoved = AuctionsRemoved + 1
end

-------------------------------------------------------------------------------
-- Indicates whether or not a query scan is in the scan request queue.
--
-- called by:
--    globally AucScanManager.IsQueryStyle()
--       called in Auctioneer: AucQueryManager.onAuctionItemListUpdate()
--
-- returns:
--    true, if a query scan is in the scan request queue
--    false, otherwise
-------------------------------------------------------------------------------
function isQueryStyle()
	return QueryStyleScan
end

-------------------------------------------------------------------------------
-- Sets the HasUpdated flag accordingly to the given parameter.
--
-- called by:
--    globally AucScanManager.SetUpdated()
--       called in Auctioneer: AucQueryManager.proccessQuery()
--
-- parameters:
--    status - (boolean) the new state of the HasUpdated flag
-------------------------------------------------------------------------------
function setUpdated(status)
	HasUpdated = status;
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
	return Auctioneer.Util.DebugPrint(message, "AucScanManager", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Global access table
-------------------------------------------------------------------------------
Auctioneer.ScanManager = {
	IsQueryStyle      = isQueryStyle;
	IsScanning        = isScanning;
	Load              = load;
	Scan              = scan;
	ScanAll           = scanAll;
	ScanCategories    = scanCategories;
	ScanQuery         = scanQuery;
	SetUpdated        = setUpdated;
}

-- This is the variable Auctioneer used to use to indicate scanning. Keep it for
-- compatbility with addons such as AuctionFilterPlus.
Auctioneer.Scanning = {
	IsScanningRequested = false;
}
