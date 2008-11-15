--[[
	Auctioneer Advanced
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: CoreAPI.lua 3812 2008-11-11 06:36:16Z Shirik $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
]]
if not AucAdvanced then return end

AucAdvanced.API = {}
local lib = AucAdvanced.API
local private = {}

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const

local replicate, empty, fill = AucAdvanced.Replicate, AucAdvanced.Empty, AucAdvanced.Fill

--[[
	The following functions are defined for modules's exposed methods:

	GetName()         (ALL*)  Should return this module's full name
	OnLoad()          (ALL*)  Receives load message for all modules
	Processor()       (ALL)   Processes messages sent by Auctioneer
	CommandHandler()  (ALL)   Slash command handler for this module
	ScanProcessor {}  (ALL)   Processes items from the scan manager
	GetPrice()        (STAT*) Returns estimated price for item link
	GetPriceColumns() (STAT)  Returns the column names for GetPrice
	StartScan()       (SCAN*) Begins an AH scan session
	IsScanning()      (SCAN*) Indicates an AH scan is in session
	AbortScan()       (SCAN)  Cancels the currently running scan
	Hook { }          (ALL)   Functions that are hooked by the module
    GetItemPDF()      (STAT*) Provides a probability distribution function for an item price


	Module type in parentheses to describe which ones provide.
	Possible Module Types are STAT, UTIL, SCAN.  ALL is a shorthand for all three.
	A * after the module type states the function is REQUIRED.

	Please visit http://norganna.org/wiki/Auctioneer/5.0/Modules_API for a
	more complete specification.
]]

do
    local EPSILON = 0.000001;
    local IMPROVEMENT_FACTOR = 0.8;
    local CORRECTION_FACTOR = 1000; -- 10 silver per gold, integration steps at tail
    local cache = {};
    local pdfList = {};
    local engines = {};
    local tremove = table.remove;
    local tinsert = table.insert;
    local abs = math.abs;
    local floor = math.floor;
    local ERROR = 0.05;
    local GetSetting = AucAdvanced.Settings.GetSetting;
    local GetItemInfo = GetItemInfo;
    local type = type;
    local pairs, ipairs = pairs, ipairs;
    local GetCVar = GetCVar;
    local assert = assert;
    -- local LOWER_INT_LIMIT, HIGHER_INT_LIMIT = -100000, 10000000;
    --[[
        This function acquires the current market value of the mentioned item using
        a configurable algorithm to process the data used by the other installed
        algorithms.

        The returned value is the most probable value that the item is worth
        using the algorithms in each of the STAT modules as specified
        by the GetItemPDF() function.

        AucAdvanced.API.GetMarketValue(itemLink, serverKey)
    ]]
    function lib.GetMarketValue(itemLink, serverKey)
        ERROR = GetSetting("marketvalue.accuracy");
        local _;
        if type(itemLink) == 'number' then _, itemLink = GetItemInfo(itemLink) end
        if not itemLink then return; end
        local saneLink = AucAdvanced.SanitizeLink(itemLink)

        -- Look up in the cache if it's recent enough
        local cacheTable = cache[lib.GetSigFromLink(itemLink)..":"..(serverKey or GetCVar("realmName"))];
        if cacheTable then
            return cacheTable.value, cacheTable.seen, cacheTable.stats;
        end


        local upperLimit, lowerLimit, seen = 0, 1e11, 0;

        if #engines == 0 then
            -- Rebuild the engine cache
            local modules = AucAdvanced.GetAllModules(nil, "Stat")
            for pos, engineLib in ipairs(modules) do
                local fn = engineLib.GetItemPDF;
                if fn then
                    tinsert(engines, {pdf = fn, array = engineLib.GetPriceArray});
                elseif nLog then
                    nLog.AddMessage("Auctioneer", "Market Pricing", N_WARNING, "Missing PDF", "Auctioneer Advanced engine '"..engineLib.GetName().."' does not have a GetItemPDF() function. This check will be removed in the near future in favor of faster calls. Implement this function.");
                end
            end
        end

        -- Run through all of the stat modules and get the PDFs
        local c, oldPdfMax, total = 0, #pdfList, 0;
        for _, engine in ipairs(engines) do
            local i, min, max, area = engine.pdf(saneLink, serverKey);
            
            local priceArray = engine.array(saneLink, serverKey);

            if priceArray and (priceArray.seen or 0) > seen then
                seen = priceArray.seen;
            end

            if i then   -- pdfList[++c] = i;
                total = total + (area or 1);                                -- Add total area, assume 1 if not supplied
                c = c + 1;
                pdfList[c] =  i;
                if min < lowerLimit then lowerLimit = min; end
                if max > upperLimit then upperLimit = max; end
            end
        end

        -- Clean out extras if needed
        for i = c+1, oldPdfMax do
            pdfList[i] = nil;
        end


        assert(lowerLimit > -1/0 and upperLimit < 1/0, "Invalid bounds detected while pricing "..(GetItemInfo(itemLink) or itemLink)..": "..tostring(lowerLimit).." to "..tostring(upperLimit));



        -- Determine the totals from the PDFs
        local delta = (upperLimit - lowerLimit) * .01;

        if #pdfList == 0 or delta < EPSILON or total < EPSILON then
            return;                 -- No PDFs available for this item
        end

        local limit = total/2;
        local midpoint, lastMidpoint = 0, 0;
        
        -- Now find the 50% point
        repeat
            lastMidpoint = midpoint;
            total = 0;

            assert(delta > 0, "Infinite loop detected during market pricing for "..(GetItemInfo(itemLink) or itemLink));
            
            for x = lowerLimit, upperLimit, delta do
                for i = 1, #pdfList do
                    local val = pdfList[i](x);
                    total = total + val * delta;
                end

                if total > limit then
                    midpoint = x;
                    break;
                end
            end
            
            delta = delta * IMPROVEMENT_FACTOR;
    

            if midpoint ~= midpoint or midpoint == 0 then
                if nLog and midpoint ~= midpoint then
                    nLog.AddMessage("Auctioneer", "Market Pricing", N_WARNING, "Unable To Calculate", "A NaN value was detected while processing the midpoint for PDF of "..(GetItemInfo(itemLink) or itemLink).."... Giving up.");
                elseif nLog then
                    nLog.AddMessage("Auctioneer", "Market Pricing", N_NOTICE, "Unable To Calculate", "A zero total was detected while processing the midpoint for PDF of "..(GetItemInfo(itemLink) or itemLink).."... Giving up.");
                end
                return;                 -- Cannot calculate: NaN
            end

        until abs(midpoint - lastMidpoint)/midpoint < ERROR;

        if midpoint and midpoint > 0 then
            midpoint = floor(midpoint + 0.5);   -- Round to nearest copper
            
            -- Cache before finishing up
            local cacheTable = {}
            cache[lib.GetSigFromLink(itemLink)..":"..(serverKey or GetCVar("realmName"))] = cacheTable;
            cacheTable.time = GetTime();
            cacheTable.value = midpoint;
            cacheTable.seen = seen;
            cacheTable.stats = #pdfList;


            return midpoint, seen, #pdfList;
        else
            if nLog then
                nLog.AddMessage("Auctioneer", "Market Pricing", N_WARNING, "Unable To Calculate", "No midpoint was detected for item "..(GetItemInfo(itemLink) or itemLink).."... Giving up.");
            end
            return;
        end

    end

    -- Now hook NewModule so that we clear the engine cache when a new module comes into play
    local oldNewModule = AucAdvanced.NewModule;
    AucAdvanced.NewModule = function(...)
        engines = {};               -- Clear the engine list
        return oldNewModule(...);   -- Tailcall original function
    end


    -- Clears the cache for AucAdvanced.API.GetMarketValue()
    function lib.ClearMarketCache()
        for x, _ in pairs(cache) do
            cache[x] = nil;
        end
    end
end

function lib.ClearItem(itemLink, serverKey)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local modules = AucAdvanced.GetAllModules("ClearItem")
	for pos, engineLib in ipairs(modules) do
		engineLib.ClearItem(saneLink, serverKey)
	end
end

function lib.GetAlgorithms(itemLink)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local engines = {}
	local modules = AucAdvanced.GetAllModules()
	for pos, engineLib in ipairs(modules) do
		if engineLib.GetPrice or engineLib.GetPriceArray then
			if not engineLib.IsValidAlgorithm
			or engineLib.IsValidAlgorithm(saneLink) then
				local engine = engineLib.GetName()
				table.insert(engines, engine)
			end
		end
	end
	return engines
end

function lib.IsValidAlgorithm(algorithm, itemLink)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local modules = AucAdvanced.GetAllModules()
	for pos, engineLib in ipairs(modules) do
		if engine == algorithm and (engineLib.GetPrice or engineLib.GetPriceArray) then
			if engineLib.IsValidAlgorithm then
				return engineLib.IsValidAlgorithm(saneLink)
			end
			return true
		end
	end
	return false
end

private.algorithmstack = {}
function lib.GetAlgorithmValue(algorithm, itemLink, serverKey, reserved)
	if (not algorithm) then
		error("No pricing algorithm supplied")
	end
	if (not itemLink) then
		error("No itemLink supplied")
	end

    if reserved then
        lib.ShowDeprecationAlert("AucAdvanced.API.GetAlgorithmValue(algorithm, itemLink, serverKey)",
            "The 'faction' and 'realm' parameters are deprecated in favor of the new 'serverKey' parameter. Use this instead."
        );

        serverKey = reserved.."-"..serverKey;
    end
    serverKey = serverKey or AucAdvanced.GetFaction()

	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local modules = AucAdvanced.GetAllModules()
	for pos, engineLib in ipairs(modules) do
		engine = engineLib.GetName()
		if engine == algorithm and (engineLib.GetPrice or engineLib.GetPriceArray) then
			if engineLib.IsValidAlgorithm
			and not engineLib.IsValidAlgorithm(saneLink) then
				return
			end
			local algosig = strjoin(":", algorithm, saneLink, serverKey)
			for pos, history in ipairs(private.algorithmstack) do
				if (history == algosig) then
					-- We are looping
					local origAlgo = private.algorithmstack[1]
					local endSize = #(private.algorithmstack)+1
					while (#(private.algorithmstack)) do
						table.remove(private.algorithmstack)
					end
					error(("Cannot solve price algorithm for: %s. (Recursion at level %d->%d: %s)"):format(origAlgo, algosig, endSize, pos))
				end
			end

			local price, seen, array
			table.insert(private.algorithmstack, algosig)
			if (engineLib.GetPriceArray) then
				array = engineLib.GetPriceArray(saneLink, serverKey)
				if (array) then
					price = array.price
					seen = array.seen
				end
			else
				price = engineLib.GetPrice(saneLink, serverKey)
			end
			table.remove(private.algorithmstack, -1)
			return price, seen, array
		end
	end
	--error(("Cannot find pricing algorithm: %s"):format(algorithm))
	return
end


private.queryTime = 0
private.prevQuery = { empty = true }
private.curResults = {}
function lib.QueryImage(query, faction, realm, ...)
	local scandata = AucAdvanced.Scan.GetScanData(faction, realm)

	local prevQuery = private.prevQuery
	local curResults = private.curResults

	local saneQueryLink
	if query.link then
		saneQueryLink = AucAdvanced.SanitizeLink(query.link)
	end

	local invalid = false
	for k,v in pairs(prevQuery) do
		if k ~= "page" and v ~= query[k] then invalid = true end
	end
	for k,v in pairs(query) do
		if k ~= "page" and v ~= prevQuery[k] then invalid = true end
	end
	if (private.queryTime ~= scandata.time) then invalid = true end
	if not invalid then return curResults end

	local numResults = #curResults
	for i=1, numResults do curResults[i] = nil end
	for k,v in pairs(prevQuery) do prevQuery[k] = v end

	local ptr, max = 1, #scandata.image
	while ptr <= max do
		repeat
			local data = scandata.image[ptr] ptr = ptr + 1
			if (not data) then break end
			if bit.band(data[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then break end
			if query.filter and query.filter(data, ...) then break end
			if query.link and data[Const.LINK] ~= saneQueryLink then break end
			if query.itemId and data[Const.ITEMID] ~= query.itemId then break end
			if query.suffix and data[Const.SUFFIX] ~= query.suffix then break end
			if query.factor and data[Const.FACTOR] ~= query.factor then break end
			if query.minUseLevel and data[Const.ULEVEL] < query.minUseLevel then break end
			if query.maxUseLevel and data[Const.ULEVEL] > query.maxUseLevel then break end
			if query.minItemLevel and data[Const.ILEVEL] < query.minItemLevel then break end
			if query.maxItemLevel and data[Const.ILEVEL] > query.maxItemLevel then break end
			if query.class and data[Const.ITYPE] ~= query.class then break end
			if query.subclass and data[Const.ISUB] ~= query.subclass then break end
			if query.quality and data[Const.QUALITY] ~= query.quality then break end
			if query.invType and data[Const.IEQUIP] ~= query.invType then break end
			if query.seller and data[Const.SELLER] ~= query.seller then break end
			if query.name then
				local name = data[Const.NAME]
				if not (name and name:lower():find(query.name:lower(), 1, true)) then break end
			end

			local stack = data[Const.COUNT]
			local nextBid = data[Const.PRICE]
			local buyout = data[Const.BUYOUT]
			if query.perItem and stack > 1 then
				nextBid = math.ceil(nextBid / stack)
				buyout = math.ceil(buyout / stack)
			end
			if query.minStack and stack < query.minStack then break end
			if query.maxStack and stack > query.maxStack then break end
			if query.minBid and nextBid < query.minBid then break end
			if query.maxBid and nextBid > query.maxBid then break end
			if query.minBuyout and buyout < query.minBuyout then break end
			if query.maxBuyout and buyout > query.maxBuyout then break end

			-- If we're still here, then we've got a winner
			table.insert(curResults, data)
		until true
	end

	private.queryTime = scandata.time
	return curResults
end

function lib.UnpackImageItem(item)
	return AucAdvanced.Scan.UnpackImageItem(item)
end

function lib.ListUpdate()
	if lib.IsBlocked() then return end
	AucAdvanced.SendProcessorMessage("listupdate")
end

function lib.BlockUpdate(block, propagate)
	local blocked
	if block == true then
		blocked = true
		private.isBlocked = true
		AuctionFrameBrowse:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	else
		blocked = false
		private.isBlocked = nil
		AuctionFrameBrowse:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	end

	if (propagate) then
		AucAdvanced.SendProcessorMessage("blockupdate", blocked)
	end
end

function lib.IsBlocked()
	return private.isBlocked == true
end

--Market matcher APIs
private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
function lib.GetBestMatch(itemLink, algorithm, serverKey, reserved)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)

    if reserved then
        lib.ShowDeprecationAlert("AucAdvanced.API.GetBestMatch(itemLink, algorithm, serverKey)",
            "The 'realm' and 'faction' parameters have been removed in favor of a single "..
            "variable 'serverKey' which should be used in the future."
        );

        serverKey = reserved.."-"..serverKey;
    end

	-- TODO: Make a configurable algorithm.
	-- This algorithm is currently less than adequate.

    local faction = (serverKey or ""):match("^[^%-]+%-(.+)$") or AucAdvanced.GetFaction()
	local realm = (serverKey or ""):match("^([^%-]+)%-.+$") or GetRealmName()

	local matchers = lib.GetMatchers(saneLink)
	local total, count, diff, _ = 0, 0, 0


	local priceArray = {}

	if algorithm == "market" then
		priceArray.price, priceArray.seen = lib.GetMarketValue(saneLink, serverKey)
	elseif type(algorithm) == "string" then
		_, _, priceArray = lib.GetAlgorithmValue(algorithm, saneLink, serverKey)
	else
		priceArray.price = algorithm
	end

	local InfoString = ""
	if not priceArray or not priceArray.price then return end
	for index, matcher in ipairs(matchers) do
		if lib.IsValidMatcher(matcher, saneLink) then
			local value, MatchpriceArray = lib.GetMatcherValue(matcher, saneLink, priceArray.price)
			priceArray.price = value
			count = count + 1
			diff = diff + MatchpriceArray.diff
			if MatchpriceArray.returnstring then
				InfoString = strjoin("\n", InfoString, MatchpriceArray.returnstring)
			end
		end
	end

	if (priceArray.price > 0) then
		return priceArray.price, total, count, diff/count, InfoString
	end
end

function lib.GetMatcherDropdownList()
	private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
	if not private.matcherlist or #private.matcherlist == 0 then
		lib.GetMatchers()
	end
	if not private.matcherlist or #private.matcherlist == 0 then
		return
	end
	local dropdownlist = {}
	for index, value in ipairs(private.matcherlist) do
		dropdownlist[index] = tostring(index)..": "..tostring(private.matcherlist[index])
	end
	return dropdownlist
end

function lib.GetMatchers(itemLink)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	private.matcherlist = AucAdvanced.Settings.GetSetting("matcherlist")
	local engines = {}
	local modules = AucAdvanced.GetAllModules()
	for pos, engineLib in ipairs(modules) do
		if engineLib.GetMatchArray then
			if not engineLib.IsValidMatcher
			or engineLib.IsValidMatcher(saneLink) then
				local engine = engineLib.GetName()
				table.insert(engines, engine)
			end
		end
	end
	local insetting = false
	local stillactive = false
	--check to see if there are any new matchers.  If so, add them to the end of the running order.
	--There is no check to see if matchers are missing, as this would destroy the saved order.  Instead, invalid matchers can be called without errors.
	if private.matcherlist then
		for index, matcher in ipairs(engines) do
			for i, j in ipairs(private.matcherlist) do
				if matcher == j then insetting = true
				end
			end
			if not insetting then
				AucAdvanced.Print("AucAdvanced: New matcher found: "..tostring(matcher))
				table.insert(private.matcherlist, matcher)
			end
			insetting = false
		end
	else
		private.matcherlist = engines
	end
	AucAdvanced.Settings.SetSetting("matcherlist", private.matcherlist)
	return private.matcherlist
end

function lib.IsValidMatcher(matcher, itemLink)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local engines = {}
	local modules = AucAdvanced.GetAllModules()
	for pos, engineLib in ipairs(modules) do
		local engine = engineLib.GetName()
		if engine == matcher and engineLib.GetMatchArray then
			if engineLib.IsValidMatcher then
				return engineLib.IsValidMatcher(saneLink)
			end
			return engineLib
		end
	end
	return false
end

function lib.GetMatcherValue(matcher, itemLink, price)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	if (type(matcher) == "string") then
		matcher = lib.IsValidMatcher(matcher, saneLink)
	end
	if not matcher then return end
	--If matcher is not a table at this point, the following code will throw an "attempt to index a <something> value" type error
	local matchArray = matcher.GetMatchArray(saneLink, price)
	if not matchArray then
		matchArray = {}
		matchArray.value = price
		matchArray.diff = 0
	end

	return matchArray.value, matchArray
end


-- Allows the return of Appraiser price values to other functions.
-- If Appraiser is not loaded it uses Market Price
function lib.GetAppraiserValue(itemLink, useMatching)
	local saneLink = AucAdvanced.SanitizeLink(itemLink)
	local newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration
	if not AucAdvanced.Modules.Util.Appraiser then
		newBuy, seen = AucAdvanced.API.GetMarketValue(saneLink)
		curModelText = "Market"
		return newBuy, newBuy, seen, curModelText
	end

	newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration = AucAdvanced.Modules.Util.Appraiser.GetPrice(saneLink, 0, useMatching)
	lib.ShowDeprecationAlert("AucAdvanced.Modules.Util.Appraiser.GetPrice(itemLink, _, useMatching)");

	return newBid, newBuy, seen, curModelText, MatchString, stack, number, duration
end

-- Signature conversion functions

-- Creates an AucAdvanced signature from an item link
function lib.GetSigFromLink(link)
	local sig
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	if itype == "item" then
		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
	else
		lib.Print("Link is not item")
	end
	return sig
end

-- Creates an item link from an AucAdvanced signature
function lib.GetLinkFromSig(sig)
	local link, name
	local id, suffix, factor, enchant = strsplit(":", sig)
	if not suffix then suffix = "0" end
	if not factor then factor = "0" end
	if not enchant then enchant = "0" end

	link = ("item:%d:%d:0:0:0:0:%d:%d:0"):format(id, enchant, suffix, factor)
	name, link = GetItemInfo(link)
	link = AucAdvanced.SanitizeLink(link)
	return link, name -- name is ignored by most calls
end


-------------------------------------------------------------------------------
-- Statistical devices created by Matthew 'Shirik' Del Buono
-- For Auctioneer Advanced
-------------------------------------------------------------------------------
local sqrtpi = math.sqrt(math.pi);
local sqrtpiinv = 1/sqrtpi;
local sq2pi = math.sqrt(2*math.pi);
local pi = math.pi;
local exp = math.exp;
local bellCurveMeta = {
    __index = {
        SetParameters = function(self, mean, stddev)
            if (stddev == 0) then
                error("Standard deviation cannot be zero");
            elseif (stddev ~= stddev) then
                error("Standard deviation must be a real number");
            end
			if stddev < .1 then --need to prevent obsurdly small stddevs like 1e-11, as they cause freeze-ups
				stddev = .1
			end
            self.mean = mean;
            self.stddev = stddev;
            self.param1 = 1/(stddev*sq2pi);     -- Make __call a little faster where we can
            self.param2 = 2*stddev^2;
        end
    },
    -- Simple bell curve call
    __call = function(self, x)
        local n = self.param1*exp(-(x-self.mean)^2/self.param2);
        -- if n ~= n then
            -- DEFAULT_CHAT_FRAME:AddMessage("-----------------");
            -- DevTools_Dump{param1 = self.param1, param2 = self.param2, x = x, mean = self.mean, stddev = self.stddev, exp = exp(-(x-self.mean)^2/self.param2)};
            -- error(x.." produced NAN ("..tostring(n)..")");
        -- end
        return n;
    end
}
-------------------------------------------------------------------------------
-- Creates a bell curve object that can then be manipulated to pass
-- as a PDF function. This is a recyclable object -- the mean and
-- standard deviation can be updated as necessary so that it does not have
-- to be regenerated
--
-- Note: This creates a bell curve with a standard deviation of 1 and
-- mean of 0. You will probably want to update it to your own desired
-- values by calling return:SetParameters(mean, stddev)
-------------------------------------------------------------------------------
function lib.GenerateBellCurve()
    return setmetatable({mean=0, stddev=1, param1=sqrtpiinv, param2=2}, bellCurveMeta);
end


--[[===========================================================================
--|| Deprecation Alert Functions
--||=========================================================================]]
do
    local SOURCE_PATTERN = "([^\\/:]+:%d+): in function `([^\"']+)[\"']";
    local seenCalls = {};
    local uid = 0;

    -------------------------------------------------------------------------------
    -- Shows a deprecation alert. Indicates that a deprecated function has
    -- been called and provides a stack trace that can be used to help
    -- find the culprit.
    -- @param replacementName (Optional) The displayable name of the replacement function
    -- @param comments (Optional) Any extra text to display
    -------------------------------------------------------------------------------
    function lib.ShowDeprecationAlert(replacementName, comments)
        local caller, source, functionName =
            debugstack(3):match(SOURCE_PATTERN),        -- Keep in mind this will be truncated to only the first in the tuple
            debugstack(2):match(SOURCE_PATTERN);        -- This will give us both the source and the function name

        functionName = functionName .. "()";

        -- Check for this source & caller combination
        seenCalls[source] = seenCalls[source] or {};
        if not seenCalls[source][caller] then
            -- Not warned yet, so warn them!
            seenCalls[source][caller]=true
            -- Display it
            AucAdvanced.Print(
                "Auctioneer Advanced: "..
                functionName .. " has been deprecated and was called by |cFF9999FF"..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:").."|r. "..
                (replacementName and ("Please use "..replacementName.." instead. ") or "")..
                (comments or "")
            );
	        geterrorhandler()(
	            "Deprecated function call occurred in AuctioneerAdvanced API:\n     {{{Deprecated Function:}}} "..functionName..
	                "\n     {{{Source Module:}}} "..source:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
	                "\n     {{{Calling Module:}}} "..caller:match("^(.+)%.[lLxX][uUmM][aAlL]:")..
	                "\n     {{{Available Replacement:}}} "..replacementName..
	                (comments and "\n\n"..comments or "")
			)
		end



    end

end



AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Advanced/CoreAPI.lua $", "$Rev: 3812 $")
