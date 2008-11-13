--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucStatistic.lua 2469 2007-11-14 06:08:37Z jslagle $

	Auctioneer statistical functions.
	Functions to calculate various forms of statistics from the auction data.

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucStatistic.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------
local stringFromBoolean = Auctioneer.Database.StringFromBoolean;
local booleanFromString = Auctioneer.Database.BooleanFromString;
local stringFromNumber = Auctioneer.Database.StringFromNumber;
local nilSafeStringFromString = Auctioneer.Database.NilSafeStringFromString;
local stringFromNilSafeString = Auctioneer.Database.StringFromNilSafeString;

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local subtractPercent;
local addPercent;
local percentLessThan;
local getMedian;
local getPercentile;
local getMeans;
local getItemSnapshotMedianBuyout;
local getItemHistoricalMedianBuyout;
local getUsableMedian;
local profitComparisonSort;
local roundDownTo95;
local getAuctionWithLowestBuyout;
local doLow;
local doMedian;
local doHSP;
local getBidBasedSellablePrice;
local getMarketPrice;
local getHSP;
local determinePrice;
local getBidProfit;
local getBuyoutProfit;
local getSuggestedResale;
local clearCache;
local debugPrint

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MedianMetaData =
{
	{
		fieldName = "median";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "count";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
};

local HSPInfoMetaData =
{
	{
		fieldName = "hsp";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "count";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "market";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "warn";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = nilSafeStringFromString;
	},
};

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------
AuctioneerCache = {};

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_ADDED", onAuctionAdded);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_REMOVED", onAuctionRemoved);
end

-------------------------------------------------------------------------------
-- Gets the cache for the specified auction house.
-------------------------------------------------------------------------------
function getCacheForAHKey(ahKey, create)
	-- If no auction house key was provided use the default key for the
	-- current zone.
	ahKey = ahKey or Auctioneer.Util.GetAuctionKey();

	-- Get or create the cache.
	if (not AuctioneerCache) then
		AuctioneerCache = {};
	end
	local cache = AuctioneerCache[ahKey];
	if ((not cache) and (create)) then
		cache = createCacheForAHKey(ahKey);
		AuctioneerCache[ahKey] = cache;
		debugPrint("Created AuctioneerCache["..ahKey.."]", DebugLib.Level.Info)
	end
	return cache;
end

-------------------------------------------------------------------------------
-- Creates a cache table for the specified AH key.
-------------------------------------------------------------------------------
function createCacheForAHKey(ahKey)
	return {
		ahKey = ahKey;
		snapshotMedians = {};
		historicalMedians = {};
		lowestBuyoutAuctionId = {};
		hspInfo = {};
		hspSettings = {}
	}
end

-------------------------------------------------------------------------------
-- Clears the cache for the specified item. If itemKey is nil then the entire
-- cache for that AH is cleared.
-------------------------------------------------------------------------------
function clearCache(itemKey, ahKey)
	local cache = getCacheForAHKey(ahKey);
	if (cache) then
		if (itemKey) then
			-- Toss the cache for the specified item.
			cache.snapshotMedians[itemKey] = nil;
			cache.historicalMedians[itemKey] = nil;
			cache.lowestBuyoutAuctionId[itemKey] = nil;
			cache.hspInfo[itemKey] = nil;
			debugPrint("Removed "..itemKey.." from cache "..cache.ahKey, DebugLib.Level.Info)
		else
			-- Toss the entire cache by recreating it.
			AuctioneerCache[cache.ahKey] = createCacheForAHKey(cache.ahKey);
			debugPrint("Cleared cache database for "..cache.ahKey, DebugLib.Level.Info)
		end
	end
end

-------------------------------------------------------------------------------
-- Called when an auction is added to the snapshot. We use this event as an
-- indication that we need to clear snapshot values from the cache.
-------------------------------------------------------------------------------
function onAuctionAdded(event, auction)
	local cache = getCacheForAHKey(auction.ahKey, false);
	if (cache) then
		local itemKey = Auctioneer.ItemDB.CreateItemKeyFromAuction(auction);
		clearCache(itemKey, auction.ahKey);
	end
end

-------------------------------------------------------------------------------
-- Called when an auction is removed from the snapshot. We use this event as an
-- indication that we need to clear snapshot values from the cache.
-------------------------------------------------------------------------------
function onAuctionRemoved(event, auction)
	local cache = getCacheForAHKey(auction.ahKey, false);
	if (cache) then
		local itemKey = Auctioneer.ItemDB.CreateItemKeyFromAuction(auction);
		cache.snapshotMedians[itemKey] = nil;
		cache.lowestBuyoutAuctionId[itemKey] = nil;
		cache.hspInfo[itemKey] = nil;
	end
end

-------------------------------------------------------------------------------
-- Returns the current snapshot median for an item
-------------------------------------------------------------------------------
function getItemSnapshotMedianBuyout(itemKey, ahKey)
	if (not ahKey) then ahKey = Auctioneer.Util.GetAuctionKey() end

	-- Try to get the value from the cache first.
	local unpacked;
	local cache = getCacheForAHKey(ahKey, true);
	local packed = cache.snapshotMedians[itemKey];
	if (packed) then
		-- Use the cached value.
		unpacked = Auctioneer.Database.UnpackRecord(packed, MedianMetaData);
	else
		-- Not in the cache, we'll have to calculate it.
		unpacked = {};

		-- Query the snapshot and calculate the median.
		local buyoutPrices = {};
		local auctions = Auctioneer.SnapshotDB.GetAuctionsForItem(itemKey, ahKey);
		for _, auction in pairs(auctions) do
			if (auction.buyoutPrice and auction.buyoutPrice > 0) then
				table.insert(buyoutPrices, auction.buyoutPrice / auction.count);
			end
		end
		unpacked.median, unpacked.count = getMedian(buyoutPrices);

		-- Cache the calculated values.
		cache.snapshotMedians[itemKey] = Auctioneer.Database.PackRecord(unpacked, MedianMetaData);
	end

	return unpacked.median, unpacked.count;
end

-------------------------------------------------------------------------------
-- Returns the historical median for an item
-------------------------------------------------------------------------------
function getItemHistoricalMedianBuyout(itemKey, ahKey)
	if (not ahKey) then ahKey = Auctioneer.Util.GetAuctionKey() end

	-- Try to get the value from the cache first.
	local unpacked;
	local cache = getCacheForAHKey(ahKey, true);
	local packed = cache.historicalMedians[itemKey];
	if (packed) then
		-- Use the cached value.
		unpacked = Auctioneer.Database.UnpackRecord(packed, MedianMetaData);
	else
		-- Not in the cache, we'll have to calculate it.
		unpacked = {};

		-- Get the historical median price list and calculate the median.
		local medianBuyoutPriceList = Auctioneer.HistoryDB.GetMedianBuyoutPriceList(itemKey, ahKey);
		if (medianBuyoutPriceList) then
			unpacked.median, unpacked.count = getMedian(medianBuyoutPriceList);
		else
			unpacked.median, unpacked.count = 0, 0;
		end

		-- Cache the calculated values.
		cache.historicalMedians[itemKey] = Auctioneer.Database.PackRecord(unpacked, MedianMetaData);
	end

	return unpacked.median, unpacked.count;
end

-------------------------------------------------------------------------------
-- Subtracts given percentage from a value
-------------------------------------------------------------------------------
function subtractPercent(value, percentLess)
	return math.floor(value * ((100 - percentLess)/100));
end

-------------------------------------------------------------------------------
-- Adds given percentage to a value
-------------------------------------------------------------------------------
function addPercent(value, percentMore)
	return math.floor(value * ((100 + percentMore)/100));
end

-------------------------------------------------------------------------------
-- returns the integer representation of the percent less value2 is from value1
-- example: value1=10, value2=7,  percentLess=30
-------------------------------------------------------------------------------
function percentLessThan(value1, value2)
	if Auctioneer.Util.NullSafe(value1) > 0 and Auctioneer.Util.NullSafe(value2) < Auctioneer.Util.NullSafe(value1) then
		return 100 - math.floor((100 * Auctioneer.Util.NullSafe(value2))/Auctioneer.Util.NullSafe(value1));
	else
		return 0;
	end
end

-------------------------------------------------------------------------------
-- Returns the median value of a given table one-dimentional table
-------------------------------------------------------------------------------
function getMedian(valuesTable)
	return getPercentile(valuesTable, 0.5)
end

-------------------------------------------------------------------------------
-- Return weighted average percentile such that returned value
-- is larger than or equal to (100*pct)% of the table values
-- 0 <= pct <= 1
-------------------------------------------------------------------------------
function getPercentile(valuesTable, pct)
	if (type(valuesTable) ~= "table") or (not tonumber(pct)) then
		return nil   -- make valuesTable a required table argument
	end
	pct = math.min(math.max(pct, 0), 1) -- Make sure 0 <= pct <= 1

	local _percentile = function(sortedTable, p, first, last)
		local f = (last - first) * p + first
		local i1, i2 = math.floor(f), math.ceil(f)
		f = f - i1

		return sortedTable[i1] * (1 - f) + sortedTable[i2] * f
	end

	local tableSize = #valuesTable or 0

	if (tableSize == 0) then
		return 0, 0; -- if there is an empty table, returns median = 0, count = 0
	elseif (tableSize == 1) then
		return tonumber(valuesTable[1]), 1
	end

	-- The following calculations require a sorted table
	table.sort(valuesTable)

	-- Skip IQR calculations if table is too small to have outliers
	if tableSize <= 4 then
		return _percentile(valuesTable, pct, 1, tableSize), tableSize
	end

	--  REWORK by Karavirs to use IQR*1.5 to ignore outliers
	-- q1 is median 1st quartile q2 is median of set q3 is median of 3rd quartile iqr is q3 - q1
	local q1 = _percentile(valuesTable, 0.25, 1, tableSize)
	local q3 = _percentile(valuesTable, 0.75, 1, tableSize)
	Auctioneer.Util.Assert(q3 >= q1, "Quartile 3 is smaller than Quartile 1!")

	local iqr = (q3 - q1) * 1.5
	local iqlow, iqhigh = q1 - iqr, q3 + iqr

	-- Find first and last index to include in median calculation
	local first, last = 1, tableSize

	-- Skip low outliers
	while valuesTable[first] < iqlow do
		first = first + 1
	end

	-- Skip high outliers
	while valuesTable[last] > iqhigh do
		last = last - 1
	end
	Auctioneer.Util.Assert(last >= first, "Last is smaller than first!")

	return _percentile(valuesTable, pct, first, last), last - first + 1
end

-------------------------------------------------------------------------------
-- Return all of the averages for an item
-- Returns: avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,aCount
-------------------------------------------------------------------------------
function getMeans(itemKey, from)
	local avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount;
	local itemTotals = Auctioneer.HistoryDB.GetItemTotals(itemKey, from);
	if (itemTotals and itemTotals.seenCount > 0) then
		avgQty = math.floor(itemTotals.minCount / itemTotals.seenCount);
		avgMin = math.floor(itemTotals.minPrice / itemTotals.minCount);
		bidPct = math.floor(itemTotals.bidCount / itemTotals.minCount * 100);
		buyPct = math.floor(itemTotals.buyoutCount / itemTotals.minCount * 100);

		avgBid = 0;
		if (itemTotals.bidCount > 0) then
			avgBid = math.floor(itemTotals.bidPrice / itemTotals.bidCount);
		end

		avgBuy = 0;
		if (itemTotals.buyoutCount > 0) then
			avgBuy = math.floor(itemTotals.buyoutPrice / itemTotals.buyoutCount);
		end

		seenCount = itemTotals.seenCount;
	end
	return avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount;
end

-------------------------------------------------------------------------------
-- This function returns the most accurate median possible,
-- If an accurate median cannot be obtained based on min seen counts then nil
-- is returned.
-------------------------------------------------------------------------------
function getUsableMedian(itemKey, ahKey)
	if (not ahKey) then ahKey = Auctioneer.Util.GetAuctionKey() end

	--get snapshot median
	local snapshotMedian, snapCount = getItemSnapshotMedianBuyout(itemKey, ahKey)
	--get history median
	local historyMedian, histCount = getItemHistoricalMedianBuyout(itemKey, ahKey);

	local median, count
	if (histCount >= Auctioneer.Core.Constants.MinBuyoutSeenCount) then
		median, count = historyMedian, histCount;
	end
	if (snapCount >= Auctioneer.Core.Constants.MinBuyoutSeenCount) then
		if (histCount < snapCount) then
			-- History median isn't shown in tooltip if histCount < snapCount so use snap median in this case
			median, count = snapshotMedian, snapCount;
		elseif (snapshotMedian < 1.2 * historyMedian) then
			median, count = snapshotMedian, snapCount;
		end
	end

	return median, count;
end

-------------------------------------------------------------------------------
-- This function takes copper and rounds to 5 silver below the the nearest gold
-- if it is less than 15 silver above of an even gold.
-- example: this function changes 1g9s to 95s
-- example: 1.5g will be unchanged and remain 1.5g
-------------------------------------------------------------------------------
function roundDownTo95(copper)
	local g,s,c = EnhTooltip.GetGSC(copper);
	if g > 0 and s < 10 then
		return (copper - ((s + 5) * 100)); -- subtract enough copper to round to 95 silver
	end
	return copper;
end

-------------------------------------------------------------------------------
-- Returns the auction in the snapshot with the lowest buyout price.
-------------------------------------------------------------------------------
function getAuctionWithLowestBuyout(itemKey, ahKey)
	if (not ahKey) then ahKey = Auctioneer.Util.GetAuctionKey() end

	-- Try to get the list from the cache first.
	local auctionWithLowestBuyout;
	local cache = getCacheForAHKey(ahKey, true);
	local auctionId = cache.lowestBuyoutAuctionId[itemKey];
	if (auctionId and auctionId ~= 0) then
		-- Return the auction id in the cache.
		auctionWithLowestBuyout = Auctioneer.SnapshotDB.GetAuctionById(ahKey, auctionId);
	else
		-- Query the snapshot for all auctions of this item with a buyout.
		local auctions = Auctioneer.SnapshotDB.QueryWithItemKey(
			itemKey,
			ahKey,
			function (auction)
				return (auction.buyoutPrice and auction.buyoutPrice > 0);
			end);

		-- If we found any auctions, get the lowest buyout price.
		if (#auctions > 0) then
			-- Sort the list of auctions by buyoutPrice.
			table.sort(
				auctions,
				function (auction1, auction2)
					return (Auctioneer.Util.PriceForOne(auction1.buyoutPrice, auction1.count) < Auctioneer.Util.PriceForOne(auction2.buyoutPrice, auction2.count))
				end);

			-- Cache the lowest auction id.
			cache.lowestBuyoutAuctionId[itemKey] = auctions[1].auctionId;

			-- Return the lowest we found.
			auctionWithLowestBuyout = auctions[1];
		else
			-- Cache none.
			cache.lowestBuyoutAuctionId[itemKey] = 0;
		end
	end


	return auctionWithLowestBuyout;
end

-------------------------------------------------------------------------------
-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
-------------------------------------------------------------------------------
function doLow(link)
	local ahKey = Auctioneer.Util.GetAuctionKey();
	local items = Auctioneer.Util.GetItems(link);
	local itemLinks = Auctioneer.Util.GetItemHyperlinks(link);

	if (items) then
		for pos,itemKey in pairs(items) do
			local auction = getAuctionWithLowestBuyout(itemKey, ahKey);
			if (not auction) then
				Auctioneer.Util.ChatPrint(_AUCT('FrmtNoauct'):format(itemLinks[pos]));
			else
				Auctioneer.Util.ChatPrint(_AUCT('FrmtLowLine'):format(Auctioneer.Util.ColorTextWhite(count.."x")..itemLinks[pos], EnhTooltip.GetTextGSC(auction.buyoutPrice), Auctioneer.Util.ColorTextWhite(auction.owner), EnhTooltip.GetTextGSC(auction.buyout / auction.count), Auctioneer.Util.ColorTextWhite(percentLessThan(getUsableMedian(itemKey), auction.buyout / auction.count).."%")));
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function doMedian(link)
	local items = Auctioneer.Util.GetItems(link);
	local itemLinks = Auctioneer.Util.GetItemHyperlinks(link);

	if (items) then
		for pos,itemKey in pairs(items) do
			local median, count = getUsableMedian(itemKey);
			if (not median) then
				Auctioneer.Util.ChatPrint(_AUCT('FrmtMedianNoauct'):format(Auctioneer.Util.ColorTextWhite(itemName)));
			else
				if (not count) then count = 0 end
				Auctioneer.Util.ChatPrint(_AUCT('FrmtMedianLine'):format(count, Auctioneer.Util.ColorTextWhite(itemName), EnhTooltip.GetTextGSC(median)));
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function doHSP(link)
	local items = Auctioneer.Util.GetItems(link);
	local itemLinks = Auctioneer.Util.GetItemHyperlinks(link);

	if (items) then
		for pos,itemKey in pairs(items) do
			local highestSellablePrice = getHSP(itemKey, Auctioneer.Util.GetAuctionKey());
			Auctioneer.Util.ChatPrint(_AUCT('FrmtHspLine'):format(itemLinks[pos], EnhTooltip.GetTextGSC(Auctioneer.Util.NilSafeString(highestSellablePrice))));
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function getBidBasedSellablePrice(itemKey, ahKey, avgMin, avgBuy, avgBid, bidPct, buyPct, avgQty, seenCount)
	-- We can pass these values along if we have them.
	if (not seenCount) then
		avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount = getMeans(itemKey, ahKey);
	end
	local bidBasedSellPrice = 0;
	local typicalBuyout = 0;

	local medianBuyout = getUsableMedian(itemKey, ahKey);
	if medianBuyout and avgBuy then
		typicalBuyout = math.min(avgBuy, medianBuyout);
	elseif medianBuyout then
		typicalBuyout = medianBuyout;
	else
		typicalBuyout = avgBuy or 0;
	end

	if (avgBid) then
		bidBasedSellPrice = math.floor((3*typicalBuyout + avgBid) / 4);
	else
		bidBasedSellPrice = typicalBuyout;
	end
	return bidBasedSellPrice;
end

-------------------------------------------------------------------------------
-- returns the best market price - 0, if no market price could be calculated
-------------------------------------------------------------------------------
function getMarketPrice(itemKey, ahKey)
	-- make sure to call this function with valid parameters! No check is being performed!
	local buyoutMedian = Auctioneer.Util.NullSafe(getUsableMedian(itemKey, ahKey))
	local avgMin, avgBuy, avgBid, bidPct, buyPct, avgQty, meanCount = getMeans(itemKey, ahKey)
	local commonBuyout = 0

	-- assign the best common buyout
	if buyoutMedian > 0 then
		commonBuyout = buyoutMedian
	elseif meanCount and meanCount > 0 then
		-- if a usable median does not exist, use the average buyout instead
		commonBuyout = avgBuy;
	end

	local category = Auctioneer.ItemDB.GetItemCategory(itemKey);
	if (category and Auctioneer.Core.Constants.BidBasedCategories[category]) then
		local playerMade, skill, level = Auctioneer.ItemDB.IsPlayerMade(itemKey);
		if (not (playerMade and level < 250 and commonBuyout < 100000)) then
			-- returns bibasedSellablePrice for bidbaseditems, playermade items or if the buyoutprice is not present or less than 10g
			return getBidBasedSellablePrice(itemKey,ahKey, avgMin,avgBuy,avgBid,bidPct,buyPct,avgQty,seenCount);
		end
	end

	-- returns buyoutMedian, if present - returns avgBuy otherwise, if meanCount > 0 - returns 0 otherwise
	return commonBuyout;
end

-------------------------------------------------------------------------------
-- Returns market information relating to the HighestSellablePrice for one of
-- the given items. If HSP cannot be calculated this method will return
-- 0 for the HSP.
-------------------------------------------------------------------------------
function getHSP(itemKey, ahKey)
	-- Normalize the arguments.
	if (not ahKey) then ahKey = Auctioneer.Util.GetAuctionKey() end
	if (not itemKey) then
		debugPrint("ERROR: Calling Auctioneer.Statistic.GetHSP(itemKey, ahKey) - Function requires valid itemKey.", DebugLib.Level.Error)
		return nil
	end

	-- TODO: This should be moved to a separate Cache-class
	-- If any of the settings was changed, the cache is invalid and must be
	-- cleared.
	local cache = getCacheForAHKey(ahKey, true);

	local pctMaxless  = tonumber(Auctioneer.Command.GetFilterVal('pct-maxless'))
	local pctUnderlow = tonumber(Auctioneer.Command.GetFilterVal('pct-underlow'))
	local pctUndermkt = tonumber(Auctioneer.Command.GetFilterVal('pct-undermkt'))
	local pctNocomp   = tonumber(Auctioneer.Command.GetFilterVal('pct-nocomp'))
	local pctMarkup   = tonumber(Auctioneer.Command.GetFilterVal('pct-markup'))
	if (cache.hspSettings.pctMaxless  ~= pctMaxless) or
	   (cache.hspSettings.pctUnderlow ~= pctUnderlow) or
	   (cache.hspSettings.pctUndermkt ~= pctUndermkt) or
	   (cache.hspSettings.pctNocomp   ~= pctNocomp) or
	   (cache.hspSettings.pctMarkup   ~= pctMarkup) then

		-- since we changed the settings, it's unlikely that any new calculated
		-- hsp is the same as the one before - therefore we do not bother about
		-- reusing old table entries, and simply create a new clean hsp cache
		cache.hspInfo = {}
		cache.hspSettings = {
			pctMaxless  = pctMaxless,
			pctUnderlow = pctUnderlow,
			pctUndermkt = pctUndermkt,
			pctNocomp   = pctNocomp,
			pctMarkup   = pctMarkup
		}
	end

	-- Check the cache first.
	local packedInfo = cache.hspInfo[itemKey];
	if (packedInfo) then
		-- Use the cached info.
		info = Auctioneer.Database.UnpackRecord(packedInfo, HSPInfoMetaData);
		return info.hsp, info.count, info.market, info.warn;
	end

	-- It's not in the cache, so calculate it.
	local _, seenCount = getUsableMedian(itemKey, ahKey);
	seenCount = Auctioneer.Util.NullSafe(seenCount);
	local hsp, market, warn = determinePrice(
		itemKey,
		ahKey,
		getAuctionWithLowestBuyout(itemKey, ahKey),
		pctMaxless,
		pctUnderlow,
		pctUndermkt,
		pctNocomp,
		pctMarkup)

	-- Cache our calculations
	local info = {};
	info.hsp = hsp;
	info.count = seenCount;
	info.market = market;
	info.warn = warn;
	cache.hspInfo[itemKey] = Auctioneer.Database.PackRecord(info, HSPInfoMetaData);

	debugPrint("Calculated HSP for "..itemKey..": hsp = "..info.hsp.."; count = "..info.count.."; market = "..info.market.."; warn = "..info.warn, DebugLib.Level.Info)
	return info.hsp, info.count, info.market, info.warn;
end

-------------------------------------------------------------------------------
-- Calcultes the HSP, market price and HSP description for an item.
-------------------------------------------------------------------------------
function determinePrice(itemKey, ahKey, auctionWithLowestBuyout, lowestAllowedPercentBelowMarket, discountLowPercent, discountMarketPercent, discountNoCompetitionPercent, vendorSellMarkupPercent)
	local highestSellablePrice = 0;
	local marketPrice = getMarketPrice(itemKey, ahKey);
	local warn = _AUCT('FrmtWarnNodata');
	if (marketPrice and marketPrice > 0) then
		if (auctionWithLowestBuyout) then
			local lowestBuyoutPriceAllowed = subtractPercent(marketPrice, lowestAllowedPercentBelowMarket);

			-- since we don't want to decode the full data unless there's a chance it belongs to the player
			-- do a substring search for the players name first.
			-- For some reason AuctionConfig.snap[ahKey][itemCat][currentLowestSig] sometimes doesn't
			-- exist, even if currentLowestBuyout is set. Added a check for this as a workaround, but
			-- the real cause should probably be tracked down - Thorarin
			local lowestBuyout = (auctionWithLowestBuyout.buyoutPrice / auctionWithLowestBuyout.count);
			if (auctionWithLowestBuyout.owner == UnitName("player")) then
				highestSellablePrice = lowestBuyout; -- If I am the lowest seller use same low price
				warn = _AUCT('FrmtWarnMyprice');
			-- Is there currently an item on the market which has a lower BO than the BO we allow?
			elseif (lowestBuyout < lowestBuyoutPriceAllowed) then
				highestSellablePrice = subtractPercent(marketPrice, discountMarketPercent);
				warn = _AUCT('FrmtWarnToolow');
			else
				if (lowestBuyout > marketPrice) then
					highestSellablePrice = subtractPercent(marketPrice, discountNoCompetitionPercent);
					warn = _AUCT('FrmtWarnAbovemkt');
				end
				-- Account for negative discountNoCompetitionPercent values
				if (lowestBuyout <= marketPrice or highestSellablePrice >= lowestBuyout) then
					-- set highest price to "Discount low"
					highestSellablePrice = subtractPercent(lowestBuyout, discountLowPercent);
					warn = _AUCT('FrmtWarnUndercut'):format(discountLowPercent);
				end
			end
		else -- no low buyout, use discount no competition
			-- set highest price to "Discount no competition"
			highestSellablePrice = subtractPercent(marketPrice, discountNoCompetitionPercent);
			warn = _AUCT('FrmtWarnNocomp');
		end
	else -- no market
		if (auctionWithLowestBuyout) then
			-- set highest price to "Discount low"
			debugPrint("Discount low case 2", DebugLib.Level.Info)
			highestSellablePrice = subtractPercent(auctionWithLowestBuyout.buyoutPrice, discountLowPercent);
			warn = _AUCT('FrmtWarnUndercut'):format(discountLowPercent);
		else
			-- Use vendor price markup.
			local baseData;
			local itemId = Auctioneer.ItemDB.BreakItemKey(itemKey);
			if (Informant) then baseData = Informant.GetItem(itemId, true) end;
			if (baseData and baseData.sell) then
				-- use vendor prices if no auction data available
				local vendorSell = Auctioneer.Util.NullSafe(baseData.sell); -- use vendor prices
				highestSellablePrice = addPercent(vendorSell, vendorSellMarkupPercent);
				warn = _AUCT('FrmtWarnMarkup'):format(vendorSellMarkupPercent);
			end
		end
	end

	return highestSellablePrice, marketPrice, warn;
end

-------------------------------------------------------------------------------
-- Calculates the HSP based bid profit for the specified auction.
-- Returns the profit amount (ie 5500 copper) and profit percent (200% profit)
-- and percent less HSP (50% less than HSP).
-------------------------------------------------------------------------------
function getBidProfit(auction, hsp)
	-- Calculate profit from bidding.
	local currentBid;
	if (auction.bidAmount and auction.bidAmount > 0) then
		currentBid = auction.bidAmount; -- %todo: take into account the min bid increment
	else
		currentBid = auction.minBid;
	end
	local itemKey = Auctioneer.ItemDB.CreateItemKeyFromAuction(auction);
	if (hsp == nil) then
		hsp = Auctioneer.Statistic.GetHSP(itemKey, auction.ahKey);
	end
	local bidProfit = (hsp * auction.count) - currentBid;
	local bidProfitPercent = math.floor((bidProfit / currentBid) * 100);
	local bidPercentLess = Auctioneer.Statistic.PercentLessThan(hsp * auction.count, currentBid);
	return bidProfit, bidProfitPercent, bidPercentLess;
end

-------------------------------------------------------------------------------
-- Calculates the HSP based buyout profit for the specified auction.
-- Returns the profit amount (ie 5500 copper) and profit percent (200% profit)
-- and percent less HSP (50% less than HSP).
-------------------------------------------------------------------------------
function getBuyoutProfit(auction, hsp)
	if (auction.buyoutPrice and auction.buyoutPrice > 0) then
		local itemKey = Auctioneer.ItemDB.CreateItemKeyFromAuction(auction);
		if (hsp == nil) then
			hsp = Auctioneer.Statistic.GetHSP(itemKey, auction.ahKey);
		end
		local buyoutProfit = (hsp * auction.count) - auction.buyoutPrice;
		local buyoutProfitPercent = math.floor((buyoutProfit / auction.buyoutPrice) * 100);
		local buyoutPercentLess = Auctioneer.Statistic.PercentLessThan(hsp * auction.count, auction.buyoutPrice);
		return buyoutProfit, buyoutProfitPercent, buyoutPercentLess;
	end
	return 0, 0, 0;
end

-------------------------------------------------------------------------------
-- Calculates the suggested starting bid and buyout. If there is no info on
-- which to base a suggestion, this method returns zero for bid, buyout and
-- market prices.
--
-- parameters:
--    count = number of items to calculate the suggested resale prices for
--            Note: this value MUST be passed to the function, because
--                  calculating the prices is no simple multiplication!
-------------------------------------------------------------------------------
function getSuggestedResale(itemKey, ahKey, count)
	if (ahKey == nil) then ahKey = Auctioneer.Util.GetAuctionKey() end;
	local hsp, hspCount, marketPrice, warn = Auctioneer.Statistic.GetHSP(itemKey, ahKey);
	if (hsp == 0) then
		local itemTotals = Auctioneer.HistoryDB.GetItemTotals(itemKey, ahKey);
		if (itemTotals and itemTotals.buyoutCount > 0) then
			hsp = math.ceil(itemTotals.buyoutPrice / itemTotals.buyoutCount); -- use mean buyout if median not available
		end
	end
	local discountBidPercent = tonumber(Auctioneer.Command.GetFilterVal('pct-bidmarkdown'));
	local buyPrice = Auctioneer.Statistic.RoundDownTo95(hsp * count);
	local bidPrice = Auctioneer.Statistic.RoundDownTo95(Auctioneer.Statistic.SubtractPercent(buyPrice, discountBidPercent));
	return bidPrice, buyPrice, (marketPrice*count), warn;
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
	return Auctioneer.Util.DebugPrint(message, "AucStatistic", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.Statistic = {
	Load = load;
	SubtractPercent = subtractPercent;
	AddPercent = addPercent;
	PercentLessThan = percentLessThan;
	GetMedian = getMedian;
	GetPercentile = getPercentile;
	GetMeans = getMeans;
	GetItemSnapshotMedianBuyout = getItemSnapshotMedianBuyout;
	GetSnapMedian = getItemSnapshotMedianBuyout;
	GetItemHistoricalMedianBuyout = getItemHistoricalMedianBuyout;
	GetHistMedian = getItemHistoricalMedianBuyout;
	GetUsableMedian = getUsableMedian;
	ProfitComparisonSort = profitComparisonSort;
	RoundDownTo95 = roundDownTo95;
	GetAuctionWithLowestBuyout = getAuctionWithLowestBuyout;
	DoLow = doLow;
	DoMedian = doMedian;
	DoHSP = doHSP;
	GetMarketPrice = getMarketPrice;
	GetHSP = getHSP;
	GetBidProfit = getBidProfit;
	GetBuyoutProfit = getBuyoutProfit;
	GetSuggestedResale = getSuggestedResale;
	ClearCache = clearCache;
}
