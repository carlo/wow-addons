--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucUtil.lua 2469 2007-11-14 06:08:37Z jslagle $

	Auctioneer utility functions.
	Functions to manipulate items keys, signatures etc

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



Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucUtil.lua $", "$Rev: 2469 $")

local addonName = "Auctioneer"

local DebugLib = LibStub("DebugLib")

-- Local function prototypes
local aucAssert
local aucDebugPrint
local chatPrint
local checkConstantsLimit
local colorTextWhite
local debugPrint
local delocalizeCommand
local delocalizeFilterVal
local findEmptySlot
local getAuctionKey
local getConstants
local getGSC
local getHomeKey
local getItemHyperlinks
local getItemLinks
local getItems
local getLocalizedFilterVal
local getNeutralKey
local getNumConstants
local getOppositeKey
local getSecondsLeftString
local getTextGSC
local getTimeLeftString
local getWarnColor
local isValidAlso
local localizeCommand
local localizeFilterVal
local nilSafeString
local nullSafe
local priceForOne
local protectAuctionFrame
local round
local sanifyAHSnapshot
local setFilterDefaults
local split
local storePlayerFaction
local unpackSeconds

-- Function Imports
local pairs = pairs;
local max = math.max
local ceil = math.ceil
local floor = math.floor;
local tonumber = tonumber;
local tostring = tostring;
local tinsert = table.insert;

function storePlayerFaction()
	Auctioneer.Core.Constants.PlayerFaction = (Auctioneer.Core.Constants.PlayerFaction or UnitFactionGroup("player") or "Alliance");
end

-- return the string representation of the given timeLeft constant
function getTimeLeftString(timeLeft)
	local timeLeftTable = Auctioneer.Core.Constants.TimeLeft

	if (timeLeft == timeLeftTable.Short) then
		return _AUCT('TimeShort');

	elseif (timeLeft == timeLeftTable.Medium) then
		return _AUCT('TimeMed');

	elseif (timeLeft == timeLeftTable.Long) then
		return _AUCT('TimeLong');

	elseif (timeLeft == timeLeftTable.VeryLong) then
		return _AUCT('TimeVlong');
	end
end

function getSecondsLeftString(secondsLeft)
	for i = #Auctioneer.Core.Constants.TimeLeft.Seconds, 1, -1 do
		if (secondsLeft >= Auctioneer.Core.Constants.TimeLeft.Seconds[i]) then
			return getTimeLeftString(i);
		end
	end
end

function checkConstantsLimit() --%TODO%: Localize
	local numConstants = getNumConstants(AuctionConfig, AuctioneerItemDB, AuctioneerSnapshotDB, AuctioneerHistoryDB, AuctioneerFixedPriceDB, AuctioneerTransactionDB)

	if (numConstants >= ((((2^18)-1) / 20) * 17)) then --85% Critical
		chatPrint(_AUCT("ConstantsCritical"):format((numConstants/((2^18)-1)) * 100), 1, 0, 0)

	elseif (numConstants >= ((((2^18)-1) / 20) * 14)) then --70% Warning
		chatPrint(_AUCT("ConstantsWarning"):format((numConstants/((2^18)-1)) * 100), 1, 1, 0)

	else
		chatPrint(_AUCT("ConstantsMessage"):format((numConstants/((2^18)-1)) * 100))
	end
end

function getNumConstants(...)
	local constantsTable = {}
	local recursedTables = {}
	local lastIndex = select("#", ...);
	local number = lastIndex;
	for index = 1, lastIndex do
		getConstants((select(index, ...)), constantsTable, recursedTables);
	end
	for key in pairs(constantsTable) do
		number = number + 1;
	end
	return number;
end

function getConstants(tbl, constants, recursedTables)
	if (recursedTables[tbl]) then
		return
	end
	for key, value in pairs(tbl) do
		--First look at the Key
		if (type(key) == "table") then
			getConstants(key, constants, recursedTables);
		else
			constants[key] = true;
		end

		--Now look at the value
		if (type(value) == "table") then
			getConstants(value, constants, recursedTables);
		else
			constants[value] = true;
		end
	end
end

function unpackSeconds(seconds)
	seconds = tonumber(seconds)
	if (not seconds) then
		return
	end

	local weeks
	local days
	local hours
	local minutes

	seconds = floor(seconds)

	if (seconds >= 604800) then
		weeks = floor(seconds / 604800)
		seconds = (seconds % 604800)
	end
	if (seconds >= 86400) then
		days = floor(seconds / 86400)
		seconds = (seconds % 86400)
	end
	if (seconds >= 3600) then
		hours = floor(seconds / 3600)
		seconds = (seconds % 3600)
	end
	if (seconds >= 60) then
		minutes = floor(seconds / 60)
		seconds = (seconds % 60)
	end

	return (weeks or 0), (days or 0), (hours or 0), (minutes or 0), (seconds or 0)
end

function getGSC(money)
	local g,s,c = EnhTooltip.GetGSC(money);
	return g,s,c;
end

function getTextGSC(money)
	return EnhTooltip.GetGSC(money);
end

-- return an empty string if str is nil
function nilSafeString(str)
	return str or "";
end

function colorTextWhite(text)
	text = text or "";

	local COLORING_START = "|cff%s%s|r";
	local WHITE_COLOR = "e6e6e6";

	return COLORING_START:format(WHITE_COLOR, ""..text);
end

function getWarnColor(warn)
	--Make "warn" a required parameter and verify that its a string
	if (not (type(warn) == "string")) then
		return nil
	end

	local cHex, cRed, cGreen, cBlue;

	if (Auctioneer.Command.GetFilter('warn-color')) then
		local FrmtWarnAbovemkt, FrmtWarnUndercut, FrmtWarnNocomp, FrmtWarnAbovemkt, FrmtWarnMarkup, FrmtWarnUser, FrmtWarnNodata, FrmtWarnMyprice

		FrmtWarnToolow = _AUCT('FrmtWarnToolow');
		FrmtWarnNocomp = _AUCT('FrmtWarnNocomp');
		FrmtWarnAbovemkt = _AUCT('FrmtWarnAbovemkt');
		FrmtWarnUser = _AUCT('FrmtWarnUser');
		FrmtWarnNodata = _AUCT('FrmtWarnNodata');
		FrmtWarnMyprice = _AUCT('FrmtWarnMyprice');

		FrmtWarnUndercut = _AUCT('FrmtWarnUndercut'):format(tonumber(Auctioneer.Command.GetFilterVal('pct-underlow')));
		FrmtWarnMarkup = _AUCT('FrmtWarnMarkup'):format(tonumber(Auctioneer.Command.GetFilterVal('pct-markup')));

		if (warn == FrmtWarnToolow) then
			--Color Red
			cHex = "ffff0000";
			cRed = 1.0;
			cGreen = 0.0;
			cBlue = 0.0;

		elseif (warn == FrmtWarnUndercut) then
			--Color Yellow
			cHex = "ffffff00";
			cRed = 1.0;
			cGreen = 1.0;
			cBlue = 0.0;

		elseif ((warn == FrmtWarnNocomp) or (warn == FrmtWarnAbovemkt)) then
			--Color Green
			cHex = "ff00ff00";
			cRed = 0.0;
			cGreen = 1.0;
			cBlue = 0.0;

		elseif ((warn == FrmtWarnMarkup) or (warn == FrmtWarnUser) or (warn == FrmtWarnNodata) or (warn == FrmtWarnMyprice)) then
			--Color Gray
			cHex = "ff999999";
			cRed = 0.6;
			cGreen = 0.6;
			cBlue = 0.6;
		end

	else
		--Color Orange
		cHex = "ffe66600";
		cRed = 0.9;
		cGreen = 0.4;
		cBlue = 0.0;
	end

	return cHex, cRed, cGreen, cBlue
end

-- Used to convert variables that should be numbers but are nil to 0
function nullSafe(val)
	return tonumber(val) or 0;
end

-- Returns the current faction's auction signature, depending on location
function getAuctionKey()
	local serverName = GetCVar("realmName");
	local currentZone = GetMinimapZoneText();
	local factionGroup;

	--Added the ability to record Neutral AH auctions in its own tables.
	if ((currentZone == "Gadgetzan") or (currentZone == "Everlook") or (currentZone == "Booty Bay")) then
		factionGroup = "Neutral"

	else
		factionGroup = Auctioneer.Core.Constants.PlayerFaction;
	end
	return serverName:lower().."-"..factionGroup:lower();
end

-- Returns the current faction's opposing faction's auction signature
function getOppositeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = Auctioneer.Core.Constants.PlayerFaction;

	if (factionGroup == "Alliance") then factionGroup="Horde"; else factionGroup="Alliance"; end
	return serverName:lower().."-"..factionGroup:lower();
end

-- Returns the current server's neutral auction signature
function getNeutralKey()
	local serverName = GetCVar("realmName");

	return serverName:lower().."-neutral";
end

-- Returns the current faction's auction signature
function getHomeKey()
	local serverName = GetCVar("realmName");
	local factionGroup = Auctioneer.Core.Constants.PlayerFaction;

	return serverName:lower().."-"..factionGroup:lower();
end

-------------------------------------------------------------------------------
-- Checks the given string to be a valid string which can be used by the also
-- command.
--
-- called by:
--    globally - AucUtil.IsValidAlso()
--
-- parameters:
--    also - (string) the string to be validated.
--
-- returns:
--    true, if it is a valid string
--    false, otherwise
--
-- remarks:
--    The tests performed are case sensitive! Therfore "Horde" is no valid
--    faction name, while "horde" would be accepted.
--    The tests are being case sensitive so that validated strings can be
--    easier compared since you do not have to care about possibe case
--    sensitivity.
--
--    Valid strings are either the following special strings
--       - opposite
--       - off
--       - neutral
--       - home
--    or a normal string in the format
--       [realm]-[faction]
--    where [faction] is one of the following strings
--       - horde
--       - alliance
--       - neutral
-------------------------------------------------------------------------------
function isValidAlso(also)
	if (type(also) ~= "string") then
		return false
	end

	if ((also == 'opposite') or (also == 'off') or (also == 'neutral') or (also == 'home')) then
		return true -- allow special keywords
	end

	-- check if string matches: "[realm]-[faction]"
	local realm, faction = also:match("^(.+)-(.+)$")
	if not realm then
		return false -- invalid string
	end

	-- check, if faction = "horde", "alliance" or "neutral"
	if (faction ~= 'horde') and (faction ~= 'alliance') and (faction ~= 'neutral') then
		return false -- invalid faction
	end

	return true
end

function split(str, at)
	if (not (type(str) == "string")) then
		return
	end

	if (not str) then
		str = ""
	end

	if (not at) then
		return {str}

	else
		return {strsplit(at, str)};
	end
end

function getItemLinks(str)
	if (not (type(str) == "string")) then
		return
	end
	local itemList = {};

	for link, item in str:gmatch("|Hitem:([^|]+)|h%[(.-)%]|h") do
		tinsert(itemList, item.." = "..link)
	end
	return itemList;
end

function getItems(str)
	if (not (type(str) == "string")) then
		return
	end
	local itemList = {};

	for itemID, enchant, randomProp in str:gmatch("|Hitem:(%p?%d+):(%p?%d+):%p?%d+:%p?%d+:%p?%d+:%p?%d+:(%p?%d+):%p?%d+|h%[(.-)%]|h") do
		tinsert(itemList, strjoin(":", itemID, randomProp, enchant))
	end
	return itemList;
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function getItemHyperlinks(str)
	if (not (type(str) == "string")) then
		return
	end
	local itemList = {};

	for color, item, name in str:gmatch("|c(%x+)|Hitem:(%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+)|h%[(.-)%]|h|r") do
		tinsert(itemList, strconcat("|c", color, "|Hitem:", item, "|h[", name, "]|h|r"))
	end
	return itemList;
end

function chatPrint(text, cRed, cGreen, cBlue, id)
	local frameIndex = Auctioneer.Command.GetFrameIndex();
	local frameReference = getglobal("ChatFrame"..frameIndex)

	if (cRed and cGreen and cBlue) then
		if frameReference then
			frameReference:AddMessage(text, cRed, cGreen, cBlue, id);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, id);
		end

	else
		if frameReference then
			frameReference:AddMessage(text, 0.0, 1.0, 0.25);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 0.0, 1.0, 0.25);
		end
	end
end

-------------------------------------------------------------------------------
-- Sets all unset values in AuctionConfig.filters to their default ones using
-- Auctioneer.Core.Constants.FilterDefaults.
--
-- called by:
--    globally - AucUtil.SetFilterDefaults()
--       called in Auctioneer: AucCommand.default()
--       called in Auctioneer: AucCommand.getFilterVal()
--       called in Auctioneer: AucDatabase.load()
-------------------------------------------------------------------------------
function setFilterDefaults()
	if (not AuctionConfig.filters) then
		AuctionConfig.filters = {};
	end

	for k, v in pairs(Auctioneer.Core.Constants.FilterDefaults) do
		if (AuctionConfig.filters[k] == nil) then
			AuctionConfig.filters[k] = v;
		end
	end
end

-- Pass true to protect the Auction Frame from being undesireably closed, not true to disable this
local ahFrameProtected
local originalToggleWorldMap
function protectAuctionFrame(enable)
	--Make sure we have an AuctionFrame before doing anything
	if (AuctionFrame) then
		-- helper functions necessary to allow the dressing room feature to
		-- work correctly
		function enableAuctionFrame()
			UIPanelWindows.AuctionFrame = AuctionFrame
		end
		function disableAuctionFrame()
			UIPanelWindows.AuctionFrame = nil
		end

		-- Handle enabling of protection
		if (enable and not ahFrameProtected and AuctionFrame:IsShown()) then
			--Remember that we are now protecting the frame
			ahFrameProtected = true;
			--If the frame is the current doublewide frame, then clear the doublewide

			if ( GetUIPanel("doublewide") == AuctionFrame ) then
				UIParent.doublewide = nil
			end
			--Remove the frame from the UI frame handling system
			UIPanelWindows.AuctionFrame = nil

			Stubby.RegisterFunctionHook("AuctionDressUpFrame_OnShow", -200, enableAuctionFrame)
			Stubby.RegisterFunctionHook("AuctionDressUpFrame_OnShow", 200, disableAuctionFrame)
			Stubby.RegisterFunctionHook("AuctionDressUpFrame_OnHide", -200, enableAuctionFrame)
			Stubby.RegisterFunctionHook("AuctionDressUpFrame_OnHide", 200, disableAuctionFrame)

			--If mobile frames is around, then remove AuctionFrame from Mobile Frames handling system
			if (MobileFrames_UIPanelWindowBackup) then
				MobileFrames_UIPanelWindowBackup.AuctionFrame = nil;
			end

			if (MobileFrames_UIPanelsVisible) then
				MobileFrames_UIPanelsVisible.AuctionFrame = nil;
			end
			--Hook the function to show the WorldMap, WorldMap has internal code that forces all these frames to close
			--so for it, we have to prevent it from showing at all

			if (not originalToggleWorldMap) then
				originalToggleWorldMap = ToggleWorldMap;
			end
			function ToggleWorldMap()

				if ( ( not ahFrameProtected ) or ( not ( AuctionFrame and AuctionFrame:IsVisible() ) ) ) then
					originalToggleWorldMap();

				else
					UIErrorsFrame:AddMessage(_AUCT('GuiNoWorldMap'), 0, 1, 0, 1.0, UIERRORS_HOLD_TIME)
				end
			end

		elseif (not enable and ahFrameProtected) then
			--Handle disabling of protection
			ahFrameProtected = nil;
			--If Mobile Frames is around, then put the frame back under its control if it is proper to do so

			if ( MobileFrames_UIPanelWindowBackup and MobileFrames_MasterEnableList and MobileFrames_MasterEnableList.AuctionFrame ) then
				MobileFrames_UIPanelWindowBackup.AuctionFrame = { area = "doublewide", pushable = 0 };

				if ( MobileFrames_UIPanelsVisible and AuctionFrame:IsVisible() ) then
					MobileFrames_UIPanelsVisible.AuctionFrame = 0;
				end

			else
				--Put the frame back into the UI frame handling system
				UIPanelWindows.AuctionFrame = { area = "doublewide", pushable = 0 };

				if ( AuctionFrame:IsVisible() ) then
					SetUIPanel("doublewide", AuctionFrame)
				end
			end

			-- remove the hooks to bypass the dressing feature needing to alter
			-- the AH width
			Stubby.UnregisterFunctionHook("AuctionDressUpFrame_OnShow", enableAuctionFrame)
			Stubby.UnregisterFunctionHook("AuctionDressUpFrame_OnShow", disableAuctionFrame)
			Stubby.UnregisterFunctionHook("AuctionDressUpFrame_OnHide", enableAuctionFrame)
			Stubby.UnregisterFunctionHook("AuctionDressUpFrame_OnHide", disableAuctionFrame)

		end
	end
end

function priceForOne(price, count)
	price = nullSafe(price)
	count = max(nullSafe(count), 1)
	return ceil(price / count)
end

function round(x)
	return ceil(x - 0.5);
end

-------------------------------------------------------------------------------
-- Localization functions
-------------------------------------------------------------------------------

function delocalizeFilterVal(value)
	if (value == _AUCT('CmdOn')) then
		return 'on';

	elseif (value == _AUCT('CmdOff')) then
		return 'off';

	elseif (value == _AUCT('CmdDefault')) then
		return 'default';

	elseif (value == _AUCT('CmdToggle')) then
		return 'toggle';

	else
		return value;
	end
end

function localizeFilterVal(value)
	local result

	if (value == 'on') then
		result = _AUCT('CmdOn');

	elseif (value == 'off') then
		result = _AUCT('CmdOff');

	elseif (value == 'default') then
		result = _AUCT('CmdDefault');

	elseif (value == 'toggle') then
		result = _AUCT('CmdToggle');
	end

	if (result) then return result; else return value; end
end

function getLocalizedFilterVal(key)
	return localizeFilterVal(Auctioneer.Command.GetFilterVal(key))
end

-- Turns a localized slash command into the generic English version of the command
function delocalizeCommand(cmd)
	if (not Auctioneer.Command.CommandMap) then Auctioneer.Command.BuildCommandMap();end

	return Auctioneer.Command.CommandMap[cmd] or cmd;
end

-- Translate a generic English slash command to the localized version, if available
function localizeCommand(cmd)
	if (not Auctioneer.Command.CommandMapRev) then Auctioneer.Command.BuildCommandMap(); end

	return Auctioneer.Command.CommandMapRev[cmd] or cmd;
end

-------------------------------------------------------------------------------
-- Inventory modifying functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Checks all bags, which can carry any item to find an empty slot.
-- This function skips any bags, which are not designed to carry any kind of
-- items.
--
-- returns 2 values:
--    first  = number of bag
--    second = number of slot in that specific bag
-- returns nil, if no empty slots are present
-------------------------------------------------------------------------------
function findEmptySlot()
	for bag = 0, 4 do
		local strBagName = GetBagName(bag)
		-- strBagName can be nil, if the user has no bag on the selected bag slot
		local strBagType = nil
		if strBagName then
			_, _, _, _, _, _, strBagType = GetItemInfo(strBagName)
		end
		-- strBagType is nil for bag 0, for all other bags, it should be "Bag"
		if not strBagType or (strBagType == _AUCT("SubTypeBag", GetLocale())) then
			for slot = 1, GetContainerNumSlots(bag) do
				if not (GetContainerItemInfo(bag, slot)) then
					return bag, slot;
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = aucDebugPrint([message][, category][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
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
function aucDebugPrint(message, category, title, errorCode, level)
	return DebugLib.DebugPrint(addonName, message, category, title, errorCode, level)
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
	return Auctioneer.Util.DebugPrint(message, "AucUtil", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- syntax:
--    assertion = aucAssert(test, message)
--
-- parameters:
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- returns:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
-------------------------------------------------------------------------------
function aucAssert(test, message)
	return DebugLib.Assert(addonName, test, message)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.Util) then return end;

Auctioneer.Util = {
	StorePlayerFaction = storePlayerFaction,
	GetTimeLeftString = getTimeLeftString,
	GetSecondsLeftString = getSecondsLeftString,
	CheckConstantsLimit = checkConstantsLimit,
	GetNumConstants = getNumConstants,
	UnpackSeconds = unpackSeconds,
	GetGSC = getGSC,
	GetTextGSC = getTextGSC,
	NilSafeString = nilSafeString,
	ColorTextWhite = colorTextWhite,
	GetWarnColor = getWarnColor,
	NullSafe = nullSafe,
	SanifyAHSnapshot = sanifyAHSnapshot,
	GetAuctionKey = getAuctionKey,
	GetOppositeKey = getOppositeKey,
	GetNeutralKey = getNeutralKey,
	GetHomeKey = getHomeKey,
	IsValidAlso = isValidAlso,
	Split = split,
	GetItemLinks = getItemLinks,
	GetItems = getItems,
	GetItemHyperlinks = getItemHyperlinks,
	ChatPrint = chatPrint,
	SetFilterDefaults = setFilterDefaults,
	ProtectAuctionFrame = protectAuctionFrame,
	PriceForOne = priceForOne,
	Round = round,
	DelocalizeFilterVal = delocalizeFilterVal,
	LocalizeFilterVal = localizeFilterVal,
	GetLocalizedFilterVal = getLocalizedFilterVal,
	DelocalizeCommand = delocalizeCommand,
	LocalizeCommand = localizeCommand,
	FindEmptySlot = findEmptySlot,
	DebugPrint = aucDebugPrint,
	Assert = aucAssert,
	DebugLib = DebugLib
}
