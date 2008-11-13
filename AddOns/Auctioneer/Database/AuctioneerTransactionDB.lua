--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AuctioneerTransactionDB.lua 2469 2007-11-14 06:08:37Z jslagle $

	SnapshotDB - the AH snapshot database

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/Database/AuctioneerTransactionDB.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load
local loadDatabase
local createDatabase
local createDatabaseFrom3x
local createAHDatabase
local upgradeAHDatabase
local getAHDatabase
local onEventHook
local onBidEvent
local clear
local createItemKey
local debugPrint

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------
-- The Auctioneer snapshot database saved on disk. Nobody should access this
-- variable outside of the loadDatabase() method. Instead the LoadedSnapshotDB
-- variable should be used.
AuctioneerTransactionDB = nil

-- The current Auctioneer history database as determined in the load() method.
-- This is either the database on disk or a temporary database if the user
-- chose not to upgrade their database.
local LoadedTransactionDB
local moneyEventsQueue = {}
local previousPlayerMoney = GetMoney()

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

-- The version of the history database first released in Auctioneer 4.0. This
-- number should NEVER change. Upgrades from Auctioneer 3.x are first upgraded
-- to this version of the database.
local BASE_TRANSACTIONDB_VERSION = 1;

-- The current version of the history database. This number must be incremented
-- anytime a change is made to the database schema.
local CURRENT_TRANSACTIONDB_VERSION = 1;
--[[ --We don't currently use this table, its just here for possible future use.
-- Schema for records in the transactions database.
local AuctionMetaData = {
	{
		fieldName = "itemName";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = nilSafeStringFromString;
	},
	{
		fieldName = "itemKey";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = nilSafeStringFromString;
	},
	{
		fieldName = "bidOrBuyout";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "resultCode";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = nilSafeStringFromString;
	},
	{
		fieldName = "bidAmount";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "minBidPrice";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "curBidPrice";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "buyoutPrice";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "playerMoney";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "owner";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = nilSafeStringFromString;
	},
}
--]]

-------------------------------------------------------------------------------
-- Loads this module.
-------------------------------------------------------------------------------
function load(usePersistentDatabase)
	-- Register for events.
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_BID_SENT", onBidEvent);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_BID_COMPLETE", onBidEvent);
	Stubby.RegisterEventHook("PLAYER_MONEY", "Auctioneer_TransactionDB", onEventHook);

	previousPlayerMoney = GetMoney()

	-- Decide what database to use. If the user has an older database and they
	-- choose not to upgrade, we cannot use it. Insetad we'll use a temporary
	-- empty database that will not be saved.
	if (usePersistentDatabase) then
		loadDatabase();
	else
		debugPrint("Using temporary AuctioneerTransactionDB", DebugLib.Level.Notice)
		LoadedHistoryDB = createDatabase();
	end
end

--=============================================================================
-- Database management functions
--=============================================================================

-------------------------------------------------------------------------------
-- Loads and upgrades the AuctioneerHistoryDB database. If the table does not
-- exist it creates a new one.
-------------------------------------------------------------------------------
function loadDatabase()
	-- If the Auctioneer database is older than 4.0, upgrade to 4.0 first.
	if (AuctionConfig.version < 40000) then
		debugPrint("Creating AuctioneerTransactionDB database from 3.x AuctionConfig", DebugLib.Level.Notice)
		AuctioneerTransactionDB = createDatabaseFrom3x();
	end

	-- Ensure that AuctioneerHistoryDB exists.
	if (not AuctioneerTransactionDB) then
		debugPrint("Creating new AuctioneerTransactionDB database", DebugLib.Level.Notice)
		AuctioneerTransactionDB = createDatabase();
	end

	-- Upgrade each realm-faction database (if needed).
	for ahKey in pairs(AuctioneerTransactionDB) do
		if (not upgradeAHDatabase(AuctioneerTransactionDB[ahKey], CURRENT_TRANSACTIONDB_VERSION)) then
			debugPrint("WARNING: Transaction database corrupted for "..ahKey.."! Creating new database.", DebugLib.Level.Warning)
			AuctioneerTransactionDB[ahKey] = createAHDatabase(ahKey);
		end
	end

	-- Make AuctioneerHistoryDB the loaded database!
	LoadedTransactionDB = AuctioneerTransactionDB;
end

-------------------------------------------------------------------------------
-- Creates a new database.
-------------------------------------------------------------------------------
function createDatabase()
	return {};
end

-------------------------------------------------------------------------------
-- Creates a new database from a Auctioneer 3.x AuctionConfig table.
-------------------------------------------------------------------------------
function createDatabaseFrom3x()
	local db = {}
	if (AuctionConfig.bids) then
		local saveName = "original-data"
		local ah = createAHDatabase(saveName, BASE_TRANSACTIONDB_VERSION)
		db[saveName] = ah

		local itemKey
		local itemSignature, bidAmmount, bidOrBuyout, ownerName
		local itemID, randomProp, enchant, itemName, stackSize, minBid, buyout, uniqueID, extra

		for charName, charData in pairs(AuctionConfig.bids) do
			ah[charName] = {}
			local charDB = ah[charName]

			for epochTime, transactionData in pairs(charData) do
				local store --Flag to indicate whether or not we attempt to store data

				if (type(transactionData) == "string") then --Auctioneer 3.8 format (string)
					if (transactionData:find("|c%x%x%x%x%x%x%x%x")) then --Corrupted data
						store = false --Flag so that the storage code below doesn't scream
					else
						itemSignature, bidAmmount, bidOrBuyout, ownerName = ("|"):split(transactionData)
						itemID, randomProp, enchant, itemName, stackSize, minBid, buyout, uniqueID, extra = (":"):split(itemSignature)

						if (extra) then --Some items have a colon (":") in their names, so account for this possibility when converting
							itemName, stackSize, minBid, buyout, uniqueID = itemName..":"..stackSize, minBid, buyout, uniqueID, extra
						end
						store = true --Flag so that this data is saved
					end

				else --Pre Auctioneer 3.8 format (table)
					ownerName = transactionData.itemOwner
					bidAmmount = transactionData.bidAmount
					itemID, randomProp, enchant, itemName, stackSize, minBid, buyout, uniqueID, extra = (":"):split(transactionData.signature)

					if (transactionData.itemWon) then
						bidOrBuyout = 1
					else
						bidOrBuyout = 0
					end

					if (extra) then --Some items have a colon (":") in their names, so account for this possibility when converting
						itemName, stackSize, minBid, buyout, uniqueID = itemName..":"..stackSize, minBid, buyout, uniqueID, extra
					end
					store = true --Flag so that this data is saved
				end

				if (store) then
					itemKey = createItemKey(itemID, randomProp, enchant, uniqueID)
					--["e1234567890.0"] = "ItemName;AuctioneerItemKey;BidOrBuyout;ResultCode;BidAmmount;MinBid;CurBid;Buyout;PlayerMoney;Owner"
					charDB[epochTime..".0"] = (";"):join(itemName, itemKey, bidOrBuyout, "BidSent", bidAmmount, minBid, math.min(bidAmmount, buyout), buyout, -1, ownerName)
				end
			end
		end
	end
	return db;
end

-------------------------------------------------------------------------------
-- Create a new table for the specified auction house key (realm-faction).
-------------------------------------------------------------------------------
function createAHDatabase(ahKey, version)
	-- If no version was specified, assume the current version.
	version = version or CURRENT_HISTORYDB_VERSION;

	-- Create the original version of the database.
	local ah = {
		version = BASE_TRANSACTIONDB_VERSION;
		ahKey = ahKey;
	};

	-- Upgrade the table to the requested version of auctioneer.
	if (ah.version ~= version) then
		upgradeAHDatabase(ah, version);
	end

	return ah;
end

-------------------------------------------------------------------------------
-- Upgrades the specified AH database. Returns true if the database was
-- upgraded successfully.
-------------------------------------------------------------------------------
function upgradeAHDatabase(ah, version)
	-- Check that we have a valid database.
	if (not (ah.version and ah.ahKey)) then
		return false
	end

	-- Check if we need upgrading.
	if (ah.version == version) then
		return true;
	end

	-- Future DB upgrade code goes here...
	debugPrint("Upgrading transaction database for "..ah.ahKey.." to version "..version, DebugLib.Level.Notice)

	-- Return the result of the upgrade!
	return (ah.version == version);
end

-------------------------------------------------------------------------------
-- Gets the Auctioneer transactions database for the specified auction house.
-------------------------------------------------------------------------------
function getAHDatabase(ahKey, create)
	-- If no auction house key was provided use the default key for the
	-- current zone.
	ahKey = ahKey or Auctioneer.Util.GetAuctionKey();
	local ah = LoadedTransactionDB[ahKey];
	if ((not ah) and (create)) then
		ah = createAHDatabase(ahKey);
		LoadedTransactionDB[ahKey] = ah;
		debugPrint("Created AuctioneerHistoryDB["..ahKey.."]", DebugLib.Level.Notice)
	end
	return ah;
end

function onEventHook(hookArgs, event, ...)
	local newPlayerMoney = GetMoney()
	local playerMoneyDelta = previousPlayerMoney - newPlayerMoney

	if (playerMoneyDelta <= 0) then
		return
	end

	local moneyEvent = moneyEventsQueue[playerMoneyDelta]

	if (moneyEvent) then
		onBidEvent(event, moneyEvent.auction, moneyEvent.bid, "MoneyEvent")

		if (moneyEvent.next) then
			moneyEventsQueue[playerMoneyDelta] = moneyEvent.next
		else
			moneyEventsQueue[playerMoneyDelta] = nil
		end
	end
end

function onBidEvent(event, auction, bid, result)
	if (event == "AUCTIONEER_BID_SENT") then

		if (moneyEventsQueue[bid]) then
			local state = moneyEventsQueue[bid]
			local event = state

			while (state) do
				event = state
				state = state.next
			end

			event.next = {
				auction = auction,
				bid = bid,
			}

		else
			moneyEventsQueue[bid] = {
				auction = auction,
				bid = bid,
			}
		end

		-- AUCTIONEER_BID_SENT has no result code (other than
		-- AUCTIONEER_BID_COMPLETE) - since we write the result variable to the db
		-- to later on identify what the entry in the DB means, we have to set it
		-- to something here.
		result = "BidSent"
	end

	local itemKey = createItemKey(auction.itemId, auction.suffixId, auction.enchantId, auction.uniqueId or 0)
	local bidOrBuyout

	if (not LoadedTransactionDB[auction.ahKey]) then
		LoadedTransactionDB[auction.ahKey] = createAHDatabase(auction.ahKey, BASE_TRANSACTIONDB_VERSION)
	end
	if (not LoadedTransactionDB[auction.ahKey][UnitName("player")]) then
		LoadedTransactionDB[auction.ahKey][UnitName("player")] = createDatabase()
	end

	if (bid >= auction.buyoutPrice) then
		bidOrBuyout = 1
	else
		bidOrBuyout = 0
	end

	itemInfo = Auctioneer.ItemDB.GetItemInfo(itemKey)

	local playerTransactionDB = LoadedTransactionDB[auction.ahKey][UnitName("player")]
	local currentTime = time()

	local timeIndex = 0
	local template = "e"..currentTime.."."
	local timeKey
	while (true) do
		timeKey = template..timeIndex
		if(playerTransactionDB[timeKey]) then
			timeIndex = timeIndex + 1
		else
			break
		end
	end

	playerTransactionDB[timeKey] = (";"):join(itemInfo.name, itemKey, bidOrBuyout, result, bid, auction.minBid, auction.bidAmount, auction.buyoutPrice, GetMoney(), auction.owner)
end

-------------------------------------------------------------------------------
-- Removes the specified item from the database. Removes all items if itemKey
-- is nil.
-------------------------------------------------------------------------------
function clear(ahKey)
	local ah = getAHDatabase(ahKey, false);
	if (ah) then
		-- Toss the entire database by recreating it.
		LoadedTransactionDB[ah.ahKey] = createAHDatabase(ah.ahKey);
		debugPrint("Cleared transaction database for "..ah.ahKey, DebugLib.Level.Info)
	end
end

-------------------------------------------------------------------------------
-- Creates an item key (itemId:suffixId:enchantId)
-------------------------------------------------------------------------------
function createItemKey(itemId, suffixId, enchantId, uniqueId)
	return itemId..":"..suffixId..":"..enchantId..":"..uniqueId
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
	return Auctioneer.Util.DebugPrint(message, "AucTransactionDB", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.TransactionDB) then return end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.TransactionDB = {
	Load = load,
}
