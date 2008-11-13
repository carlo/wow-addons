--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucItemDB.lua 2469 2007-11-14 06:08:37Z jslagle $

	ItemDB - static item information

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/Database/AucItemDB.lua $", "$Rev: 2469 $")

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------
local tonumber = tonumber;

local chatPrint = Auctioneer.Util.ChatPrint;
local stringFromBoolean = Auctioneer.Database.StringFromBoolean;
local booleanFromString = Auctioneer.Database.BooleanFromString;
local stringFromNumber = Auctioneer.Database.StringFromNumber;
local nilSafeStringFromString = Auctioneer.Database.NilSafeStringFromString;
local stringFromNilSafeString = Auctioneer.Database.StringFromNilSafeString;

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;

local loadDatabase;
local createDatabase;
local upgradeDatabase;
local getDatabase;

local getItemInfo;
local getItemInfoFromBlizzard;
local getItemInfoFromDatabase;
local getItemName;
local getItemLink;
local getLongItemLink
local getItemString;
local getLongItemString
local getItemCategory;
local getItemQuality;
local isPlayerMade;
local packItemInfo;
local unpackItemInfo;
local onAuctionSeen;

local createItemKey;
local createItemKeyFromAuction;
local createItemKeyFromLink;
local breakItemKey;

local getIndex;
local getString;

local getCategoryName;
local getSubCategoryName;
local getInventoryTypeName;

local debugPrint

local DebugLib = Auctioneer.Util.DebugLib

-------------------------------------------------------------------------------
-- Data Members
-------------------------------------------------------------------------------

-- The Auctioneer item database saved on disk. Nobody should access this
-- variable outside of the loadDatabase() method. Instead the LoadedItemDB
-- variable should be used.
AuctioneerItemDB = nil;

-- The current Auctioneer item database as determined in the load() method.
-- This is either the database on disk or a temporary database if the user
-- chose not to upgrade their database.
local LoadedItemDB;

local cachedItemInfoKey;
local cachedItemInfo;

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

-- The current version of the item database. This number must be incremented
-- anytime a change is made to the database schema.
local CURRENT_ITEMDB_VERSION = 1; -- Auctioneer 4.0

-- Schema for records in the items table of the item database.
local ItemInfoMetaData = {
	{
		fieldName = "name";
		fromStringFunc = stringFromNilSafeString;
		toStringFunc = stringFromNilSafeString;
	},
	{
		fieldName = "quality";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "useLevel";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "categoryName";
		fromStringFunc = function(index) return getString(getDatabase().auctionItemClasses, tonumber(index)) end;
		toStringFunc = function(name) return tostring(getIndex(getDatabase().auctionItemClasses, name, true)) end;
	},
	{
		fieldName = "subCategoryName";
		fromStringFunc = function(index) return getString(getDatabase().auctionItemSubClasses, tonumber(index)) end;
		toStringFunc = function(name) return tostring(getIndex(getDatabase().auctionItemSubClasses, name, true)) end;
	},
	{
		fieldName = "stackCount";
		fromStringFunc = tonumber;
		toStringFunc = stringFromNumber;
	},
	{
		fieldName = "equipLocName";
		fromStringFunc = function(index) return getString(getDatabase().inventoryTypes, tonumber(index)) end;
		toStringFunc = function(name) return tostring(getIndex(getDatabase().inventoryTypes, name, true)) end;
	},
	{
		fieldName = "textureName";
		fromStringFunc = function(index) return getString(getDatabase().textures, tonumber(index)) end;
		toStringFunc = function(name) return tostring(getIndex(getDatabase().textures, name, true)) end;
	},
};

local AUCTION_ITEM_CLASS_NAMES = {GetAuctionItemClasses()};

local AUCTION_ITEM_SUBCLASS_NAMES = {};
for classIndex, class in ipairs(AUCTION_ITEM_CLASS_NAMES) do
	table.insert(AUCTION_ITEM_SUBCLASS_NAMES, {GetAuctionItemSubClasses(classIndex)});
end

local AUCTION_INV_TYPE_NAMES = {};
for classIndex, class in ipairs(AUCTION_ITEM_CLASS_NAMES) do
	AUCTION_INV_TYPE_NAMES[classIndex] = {};
	for subclassIndex, subclass in ipairs(AUCTION_ITEM_SUBCLASS_NAMES[classIndex]) do
		table.insert(AUCTION_INV_TYPE_NAMES[classIndex], {GetAuctionInvTypes(classIndex, subclassIndex)});
	end
end

-------------------------------------------------------------------------------
-- Loads this module.
-------------------------------------------------------------------------------
function load(usePersistentDatabase)
	-- Register for events.
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_SEEN", onAuctionSeen);

	-- Decide what database to use. If the user has an older database and they
	-- choose not to upgrade, we cannot use it. Insetad we'll use a temporary
	-- empty database that will not be saved.
	if (usePersistentDatabase) then
		loadDatabase();
	else
		debugPrint("Using temporary AuctioneerItemDB", DebugLib.Level.Notice)
		LoadedItemDB = createDatabase();
	end
end

--=============================================================================
-- Database management functions
--=============================================================================

-------------------------------------------------------------------------------
-- Upgrades the AuctioneerItemDB database. If the table does not exist
-- it creates a new one.
-------------------------------------------------------------------------------
function loadDatabase()
	-- Create the AuctioneerItemDB table, if needed.
	if (not AuctioneerItemDB) then
		debugPrint("Creating new AuctioneerItemDB database", DebugLib.Level.Notice)
		AuctioneerItemDB = createDatabase();
	end

	-- Upgrade the database, if needed.
	if (not upgradeDatabase(AuctioneerItemDB)) then
		debugPrint("WARNING: Item database corrupted! Creating new database.", DebugLib.Level.Warning)
		AuctioneerItemDB = createDatabase();
	end

	-- Make AuctioneerItemDB the loaded database!
	LoadedItemDB = AuctioneerItemDB;
end

-------------------------------------------------------------------------------
-- Create a brand new item database.
-------------------------------------------------------------------------------
function createDatabase()
	return {
		version = CURRENT_ITEMDB_VERSION;
		items = {};
		auctionItemClasses = {};
		auctionItemSubClasses = {};
		inventoryTypes = {};
		textures = {};
	};
end

-------------------------------------------------------------------------------
-- Upgrades the specified database. Returns true if the database was upgraded
-- successfully.
-------------------------------------------------------------------------------
function upgradeDatabase(db)
	-- Check that we have a valid database.
	if (not db.version) then
		return false
	end

	-- Check if we need upgrading.
	if (db.version == CURRENT_ITEMDB_VERSION) then
		return true;
	end

	-- Future DB upgrade code goes here.
	debugPrint("Upgrading item database", DebugLib.Level.Notice)

	-- Return the result of the upgrade!
	return (db.version == CURRENT_ITEMDB_VERSION);
end

-------------------------------------------------------------------------------
-- Gets the Auctioneer item database.
-------------------------------------------------------------------------------
function getDatabase()
	return LoadedItemDB;
end

--=============================================================================
-- Item functions
--=============================================================================

-------------------------------------------------------------------------------
-- Gets the item info. It first tries to get the information from Blizzard.
-- Failing that, it gets the info from our database. Failing that this method
-- returns nil.
-------------------------------------------------------------------------------
function getItemInfo(itemKey)
	-- Check if we've cached the item info.
	if (cachedItemInfoKey == itemKey) then
		return cachedItemInfo;
	end

	-- Nope, gotta get it from the database.
	local itemInfo = getItemInfoFromBlizzard(itemKey) or getItemInfoFromDatabase(itemKey);
	if (itemInfo) then
		cachedItemInfo = itemInfo;
		cachedItemInfoKey = itemKey;
	end
	return itemInfo;
end

-------------------------------------------------------------------------------
-- Gets the item info from our own database. Returns nil if its not found.
-------------------------------------------------------------------------------
function getItemInfoFromDatabase(itemKey)
	local packedItemInfo = LoadedItemDB.items[itemKey];
	if (packedItemInfo) then
		return unpackItemInfo(packedItemInfo);
	end
end

-------------------------------------------------------------------------------
-- Gets the item info from Blizzard for the specified item. Returns nil if its
-- not in blizzard's cache.
-------------------------------------------------------------------------------
function getItemInfoFromBlizzard(itemKey)
	local itemString = getItemString(itemKey);
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
	if (itemName) then
		return {
			name = itemName;
			quality = itemQuality;
			useLevel = itemMinLevel;
			categoryName = itemType;
			subCategoryName = itemSubType;
			stackCount = itemStackCount;
			equipLocName = itemEquipLoc;
			textureName = itemTexture;
		};
	end
end

-------------------------------------------------------------------------------
-- Gets the itemName for the specified item. Returns nil if the item cannot
-- be found (not in Blizzard's cache or Auctioneer's item database).
-------------------------------------------------------------------------------
function getItemName(itemKey)
	local itemInfo = getItemInfo(itemKey);
	if (itemInfo) then
		return itemInfo.name;
	end
end

-------------------------------------------------------------------------------
-- Gets the itemLink for the specified item. Returns nil if the item cannot
-- be found (not in Blizzard's cache or Auctioneer's item database).
-------------------------------------------------------------------------------
function getItemLink(itemKey)
	local itemInfo = getItemInfo(itemKey);
	if (itemInfo) then
		local _, _, _, hexColor = GetItemQualityColor(itemInfo.quality);
		local itemId, suffixId, enchantId, uniqueId = breakItemKey(itemKey);
		return ("%s|Hitem:%s:%s:0:0:0:0:%s:%s|h[%s]|h|r"):format(hexColor, itemId, enchantId, suffixId, uniqueId, itemInfo.name);
	end
end

-------------------------------------------------------------------------------
-- Gets the itemLink including the uniqueId for the specified item.
-- Returns nil if the item cannot be found (not in Blizzard's cache or
-- Auctioneer's item database).
-------------------------------------------------------------------------------
-- deprecated!!! remove in 5.0
function getLongItemLink(itemKey)
	return getItemLink(itemKey)
end

-------------------------------------------------------------------------------
-- Gets the itemString (item:itemId:enchantId:0:0:0:0:suffixId:uniqueId) for the
-- specified item.
-------------------------------------------------------------------------------
function getItemString(itemKey)
	local itemId, suffixId, enchantId, uniqueId = breakItemKey(itemKey);
	return ("item:%s:%s:0:0:0:0:%s:%s"):format(itemId, enchantId, suffixId, uniqueId);
end

-------------------------------------------------------------------------------
-- Gets the itemString (item:itemId:enchantId:0:0:0:0:suffixId:uniqueId) for the
-- specified item.
-------------------------------------------------------------------------------
-- deprecated!!! remove in 5.0
function getLongItemString(itemKey)
	return getItemString(itemKey)
end

-------------------------------------------------------------------------------
-- Gets the item's category (aka numeric version of itemType)
-------------------------------------------------------------------------------
function getItemCategory(itemKey)
	local itemInfo = getItemInfo(itemKey);
	if (itemInfo) then
		return itemInfo.category;
	end
end

-------------------------------------------------------------------------------
-- Gets the item's quality.
-------------------------------------------------------------------------------
function getItemQuality(itemKey)
	local itemInfo = getItemInfo(itemKey);
	if (itemInfo) then
		return itemInfo.quality;
	end
end

-------------------------------------------------------------------------------
-- Checks if an item is player made. This method relies on Informant.
-------------------------------------------------------------------------------
function isPlayerMade(itemKey)
	local itemData;
	if (Informant) then
		itemData = Informant.GetItem(breakItemKey(itemKey))
	end

	local reqSkill = 0
	local reqLevel = 0
	if (itemData) then
		reqSkill = itemData.reqSkill
		reqLevel = itemData.reqLevel
	end
	return (reqSkill ~= 0), reqSkill, reqLevel
end

-------------------------------------------------------------------------------
-- Converts an item info table into a ';' delimited string.
-------------------------------------------------------------------------------
function packItemInfo(itemInfo)
	return Auctioneer.Database.PackRecord(itemInfo, ItemInfoMetaData);
end

-------------------------------------------------------------------------------
-- Converts a ';' delimited string into an item info table using the
-- ItemInfoMetaData table.
-------------------------------------------------------------------------------
function unpackItemInfo(packedItemInfo)
	return Auctioneer.Database.UnpackRecord(packedItemInfo, ItemInfoMetaData);
end

-------------------------------------------------------------------------------
-- Called whenever an auction is seen at the AH.
-------------------------------------------------------------------------------
function onAuctionSeen(event, auction)
	-- Get the item info from Blizzard and store it.
	local itemKey = createItemKeyFromAuction(auction);
	local itemInfo = getItemInfoFromBlizzard(itemKey);
	if (itemInfo) then
		local db = getDatabase();
		db.items[itemKey] = packItemInfo(itemInfo);
	end

	-- Notify other interested addons that we saw an item link.
	local itemLink = getItemLink(itemKey)
	if (ItemsMatrix_ProcessLinks) then
		ItemsMatrix_ProcessLinks(
				itemLink, -- itemlink
				nil,  -- not used atm
				nil,  -- vendorprice - TODO: not calculatable in AH?
				nil	-- event - TODO: donno, maybe only for chatevents?
		);
	end
	if (LootLink_ProcessLinks) then
		LootLink_ProcessLinks(
				itemLink, -- itemlink
				true  -- TODO: uncertain? - ah is a trustable source?
		);
	end
	if (Itemizer and Itemizer.ProcessLinks) then
		Itemizer.ProcessLinks(
				itemLink, -- itemLink
				true -- The Link comes from the API, which means it doesn't have to be split up
		);
	end
end

-------------------------------------------------------------------------------
-- Creates an item key (itemId:suffixId:enchantId)
-------------------------------------------------------------------------------
function createItemKey(itemId, suffixId, enchantId)
	return strjoin(":", itemId, suffixId, enchantId);
end

-------------------------------------------------------------------------------
-- Creates an item key (itemId:suffixId:enchantId)
-------------------------------------------------------------------------------
function createItemKeyFromAuction(auction)
	return createItemKey(auction.itemId, auction.suffixId, auction.enchantId);
end

-------------------------------------------------------------------------------
-- Creates an item key (itemId:suffixId:enchantId)
-------------------------------------------------------------------------------
function createItemKeyFromLink(link)
	local itemId, suffixId, enchantId = EnhTooltip.BreakLink(link);
	return createItemKey(itemId, suffixId, enchantId);
end

-------------------------------------------------------------------------------
-- Breaks an item key (itemId;suffixId;enchantId;uniqueId)
-------------------------------------------------------------------------------
function breakItemKey(itemKey)
	local itemId, suffixId, enchantId, uniqueId = strsplit(":", itemKey);
	return tonumber(itemId) or 0, tonumber(suffixId) or 0, tonumber(enchantId) or 0, tonumber(uniqueId) or 0;
end

-------------------------------------------------------------------------------
-- Gets the index of the string in the list. If the string isn't found and
-- create is true, the string is added to the list and the resulting index
-- returned. If the string isn't found and create is false, nil is returned.
-------------------------------------------------------------------------------
function getIndex(list, string, create)
	-- Look for the string in the list.
	for index, value in pairs(list) do
		if (value == string) then
			return index;
		end
	end

	-- If we made it this far we didn't find it. Add it if instructed to.
	if (create) then
		table.insert(list, string);
		return #list;
	end
end

-------------------------------------------------------------------------------
-- Gets the string at the specified index.
-------------------------------------------------------------------------------
function getString(list, index)
	return list[index];
end

-------------------------------------------------------------------------------
-- Returns the category name (aka class) corresponding to Blizzard's category
-- index.
--
-- NOTE: This is NOT the index we store in Auctioneer's item database.
-------------------------------------------------------------------------------
function getCategoryName(categoryIndex)
	return AUCTION_ITEM_CLASS_NAMES[categoryIndex];
end

-------------------------------------------------------------------------------
-- Returns the sub category name (aka sub class) corresponding to Blizzard's
-- sub category index.
--
-- NOTE: This is NOT the index we store in Auctioneer's item database.
-------------------------------------------------------------------------------
function getSubCategoryName(categoryIndex, subCategoryIndex)
	return AUCTION_ITEM_SUBCLASS_NAMES[categoryIndex][subCategoryIndex];
end

-------------------------------------------------------------------------------
-- Returns the inventory type name corresponding to Blizzard's inventory type
-- index.
--
-- NOTE: This is NOT the index we store in Auctioneer's item database.
-------------------------------------------------------------------------------
function getInventoryTypeName(categoryIndex, subCategoryIndex, inventoryTypeIndex)
	return AUCTION_INV_TYPE_NAMES[categoryIndex][subCategoryIndex][inventoryTypeIndex];
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
	return Auctioneer.Util.DebugPrint(message, "AucItemDB", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.ItemDB) then return end;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.ItemDB = {
	Load = load;
	GetItemInfo = getItemInfo;
	GetItemName = getItemName;
	GetItemLink = getItemLink;
	GetLongItemLink = getLongItemLink,
	GetItemString = getItemString;
	GetLongItemString = getLongItemString,
	GetItemCategory = getItemCategory;
	GetItemQuality = getItemQuality;
	IsPlayerMade = isPlayerMade;
	CreateItemKeyFromAuction = createItemKeyFromAuction;
	CreateItemKeyFromLink = createItemKeyFromLink;
	CreateItemKey = createItemKey;
	BreakItemKey = breakItemKey;
	GetCategoryName = getCategoryName;
	GetSubCategoryName = getSubCategoryName;
	GetInventoryTypeName = getInventoryTypeName;
};

-------------------------------------------------------------------------------
-- Create an empty database to use before any upgrading is performed.
-------------------------------------------------------------------------------
AuctioneerItemDB = createDatabase();
LoadedItemDB = AuctioneerItemDB;
