--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucDatabase.lua 1820 2007-05-10 14:47:35Z luke1410 $

	AucDatabase - Auctioneer database methods

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/Database/AucDatabase.lua $", "$Rev: 1820 $")

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local loadDatabases;
local addPlayerToAccount;
local isPlayerOnAccount;
local stringFromBoolean;
local booleanFromString;
local stringFromNumber;
local nilSafeStringFromString;
local stringFromNilSafeString;
local packRecord;
local unpackRecord;
local packNumericList;
local unpackNumericList;
local doesNameMatch;
local debugPrint
local upgradeTo40002

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local NIL_VALUE = "<nil>";
local DATABASE_VERSION_40 = 40000;
local CURRENT_DATABASE_VERSION = 40002;

-------------------------------------------------------------------------------
-- Called when the Auctioneer addon loads. This method should check the
-- version of the database and upgrade if needed.
-------------------------------------------------------------------------------
function load()
	-- Load/Upgrade AuctionConfig
	if (not AuctionConfig) then
		-- start with a new one, if AuctionConfig does not exist
		AuctionConfig = {
			version = CURRENT_DATABASE_VERSION
		};
	end
	if (not AuctionConfig.version) then
		-- version number is missing, therefore that's a <=3.0 database or an
		-- empty db... in both cases we want to run the pre 4.0 conversion, so
		-- set it to 3.0, anyway
		AuctionConfig.version = 30000;
	end
	-- set default values for everything, which has not been set, yet.
	Auctioneer.Util.SetFilterDefaults();

	-- Load/Upgrade the various databases.
	if (AuctionConfig.version < CURRENT_DATABASE_VERSION) then
		-- The database is from an older verison of Auctioneer. Prompt to
		-- upgrade.
		StaticPopupDialogs["CONVERT_AUCTIONEER"] = {
			text = _AUCT('MesgConvert'),
			button1 = _AUCT('MesgConvertYes'),
			button2 = _AUCT('MesgConvertNo'),
			OnAccept = function()
				-- Load and upgrade the database.
				loadDatabases(true);
			end,
			OnCancel = function()
				-- Use a temporary database so we don't trample the user's
				-- data.
				loadDatabases(false);
				Auctioneer.Util.ChatPrint(_AUCT('MesgNotconverting'));
			end,
			timeout = 0,
			whileDead = 1,
			exclusive = 1
		};
		StaticPopup_Show("CONVERT_AUCTIONEER", "","");
	elseif (AuctionConfig.version > CURRENT_DATABASE_VERSION) then
		-- Hmmm... the database is newer than this version of Auctioneer!
		-- We'll use a temporary database so we don't trample the user's
		-- data.
		loadDatabases(false);
	else
		-- The database is from this version of Auctioneer.
		loadDatabases(true);
	end
end

-------------------------------------------------------------------------------
-- Loads the appropriate databases.
-------------------------------------------------------------------------------
function loadDatabases(upgrade)
	-- Load the databases. Each database will take care of upgrading itself.
	Auctioneer.ItemDB.Load(upgrade);
	Auctioneer.SnapshotDB.Load(upgrade);
	Auctioneer.HistoryDB.Load(upgrade);
	Auctioneer.FixedPriceDB.Load(upgrade);
	Auctioneer.TransactionDB.Load(upgrade);

	-- Although most of the tables of the pre 4.0 version would automatically
	-- being removed when the user logs out, we remove the data for the current
	-- run of WoW, too to reduce the current memory usage.
	if (upgrade and AuctionConfig.version < DATABASE_VERSION_40) then
		AuctionPrices = nil;
		AuctionBids = nil;
		AHSnapshot = nil;
		AHSnapshotItemPrices = nil;
		AuctionConfig.bids = nil;
		AuctionConfig.classes = nil;
		AuctionConfig.data = nil;
		AuctionConfig.fixedprice = nil;
		AuctionConfig.info = nil;
		AuctionConfig.sbuy = nil;
		AuctionConfig.snap = nil;
		AuctionConfig.stats = nil;
		AuctionConfig.success = nil;
	end

	-- We are up-to-date!
	if (upgrade) then
		upgradeTo40002()

		AuctionConfig.version = CURRENT_DATABASE_VERSION;

		-- Check number of constants in SV file, after the database was
		-- loaded/converted.
		Auctioneer.Util.CheckConstantsLimit()
	end
end

-------------------------------------------------------------------------------
-- Adds a player to the list of players on the current account.
-------------------------------------------------------------------------------
function addPlayerToAccount(player)
	-- List of players on the same account as the current player (including the
	-- current player). Auctions owned by these players cannot be bid on.
	if (not AuctionConfig.players) then AuctionConfig.players = {}; end
	if (not isPlayerOnAccount(player)) then
		table.insert(AuctionConfig.players, player);
	end
end

-------------------------------------------------------------------------------
-- Checks if a player is on the same account as the current player.
-------------------------------------------------------------------------------
function isPlayerOnAccount(player)
	if (not AuctionConfig.players) then AuctionConfig.players = {}; end
	for _, storedPlayer in pairs(AuctionConfig.players) do
		if (storedPlayer == player) then
			return true;
		end
	end
	return false;
end

-------------------------------------------------------------------------------
-- Converts boolean into a numeric string.
-------------------------------------------------------------------------------
function stringFromBoolean(boolean)
	if (boolean == nil) then
		return NIL_VALUE;
	elseif (boolean) then
		return "1";
	else
		return "0";
	end
end

-------------------------------------------------------------------------------
-- Converts a numeric string into a boolean.
-------------------------------------------------------------------------------
function booleanFromString(string)
	if (string == NIL_VALUE) then
		return nil;
	elseif (string == "0") then
		return false;
	else
		return true;
	end
end

-------------------------------------------------------------------------------
-- Converts number into a numeric string.
-------------------------------------------------------------------------------
function stringFromNumber(number)
	return tostring(number) or NIL_VALUE;
end

-------------------------------------------------------------------------------
-- Converts a string into a nil safe string (nil -> "<nil>")
-------------------------------------------------------------------------------
function nilSafeStringFromString(string)
	return string or NIL_VALUE;
end

-------------------------------------------------------------------------------
-- Converts a nil safe string into a string ("<nil>" -> nil)
-------------------------------------------------------------------------------
function stringFromNilSafeString(nilSafeString)
	if (nilSafeString == NIL_VALUE) then
		return nil;
	else
		return nilSafeString;
	end
end

-------------------------------------------------------------------------------
-- Converts a record into a ';' delimited string.
-------------------------------------------------------------------------------
function packRecord(record, recordMetaData)
	local packedRecord;
	for index, metadata in ipairs(recordMetaData) do
		local value = metadata.toStringFunc(record[metadata.fieldName]);
		if (not packedRecord) then
			packedRecord = value
		else
			packedRecord = strjoin(";", packedRecord, value);
		end
	end
	return packedRecord;
end

-------------------------------------------------------------------------------
-- Converts a ';' delimited string into a record.
-------------------------------------------------------------------------------
function unpackRecord(packedRecord, recordMetaData)
	local record = {strsplit(";", packedRecord)};
	for index, metadata in ipairs(recordMetaData) do
		record[metadata.fieldName] = metadata.fromStringFunc(record[index]);
		record[index] = nil;
	end
	return record;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function packNumericList(list)
	local hist = "";
	local function GrowList(last, n)
		if (n == 1) then
			if (hist == "") then hist = tostring(last);
			else hist = ("%s:%d"):format(hist, last); end
		elseif (n ~= 0) then
			if (hist == "") then hist = ("%dx%d"):format(last, n);
			else hist = ("%s:%dx%d"):format(hist, last, n); end
		end
	end
	local n = 0;
	local last = 0;
	for pos, hPrice in pairs(list) do
		if (pos == 1) then
			last = hPrice;
		elseif (hPrice ~= last) then
			GrowList(last, n)
			last = hPrice;
			n = 0;
		end
		n = n + 1
	end
	GrowList(last, n)
	return hist;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function unpackNumericList(str)
	local splut = {};
	if (str) then
		for x,c in str:gmatch('([^%:]*)(%:?)') do
			local y,n = x:match('(%d*)x(%d*)')
			if (not y) then
				table.insert(splut, tonumber(x));
			else
				for i = 1, n do
					table.insert(splut, tonumber(y));
				end
			end
			if (c == '') then break end
		end
	end
	return splut;
end

-------------------------------------------------------------------------------
-- Checks if the item names match. If exact is false, it checks if name2
-- appears within name1.
-------------------------------------------------------------------------------
function doesNameMatch(name1, name2, exact)
	if (name1 and name2) then
		if (exact) then
			return (name1:lower() == name2:lower());
		else
			return (name1:lower():find(name2:lower(), 1, true));
		end
	end
end

-------------------------------------------------------------------------------
-- Upgrades the database to 40002.
-------------------------------------------------------------------------------
function upgradeTo40002()
	-- The locale setting is no longer used.
	AuctionConfig.filters["locale"] = nil
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
	return Auctioneer.Util.DebugPrint(message, "AucDatabase", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.Database) then return end;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.Database = {
	Load = load;
	AddPlayerToAccount = addPlayerToAccount;
	IsPlayerOnAccount = isPlayerOnAccount;
	StringFromBoolean = stringFromBoolean;
	BooleanFromString = booleanFromString;
	StringFromNumber = stringFromNumber;
	NilSafeStringFromString = nilSafeStringFromString;
	StringFromNilSafeString = stringFromNilSafeString;
	PackRecord = packRecord;
	UnpackRecord = unpackRecord;
	PackNumericList = packNumericList;
	UnpackNumericList = unpackNumericList;
	DoesNameMatch = doesNameMatch;
};
