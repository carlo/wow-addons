--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucAskPrice.lua 1935 2007-05-30 21:22:09Z mentalpower $

	Auctioneer AskPrice created by Mikezter and merged into Auctioneer by MentalPower.
	Functions responsible for AskPrice's operation..

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

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucAskPrice.lua $", "$Rev: 1935 $")

--Local function prototypes
local init
local askpriceFrame
local commandHandler
local chatPrintHelp
local onOff
local setTrigger
local genVarSet
local setCustomSmartWords
local setKhaosSetKeyValue
local sendAskPrice
local eventHandler
local sendWhisper
local onEventHook
local getData
local getItems
local debugPrint

local whisperList = {}
local sentAskPriceAd = {}

function init()
	askPriceFrame = CreateFrame("Frame")

	askPriceFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
	askPriceFrame:RegisterEvent("CHAT_MSG_WHISPER")
	askPriceFrame:RegisterEvent("CHAT_MSG_OFFICER")
	askPriceFrame:RegisterEvent("CHAT_MSG_PARTY")
	askPriceFrame:RegisterEvent("CHAT_MSG_GUILD")
	askPriceFrame:RegisterEvent("CHAT_MSG_RAID")

	askPriceFrame:SetScript("OnEvent", Auctioneer.AskPrice.EventHandler)

	Auctioneer.AskPrice.Language = GetDefaultLanguage("player");

	Stubby.RegisterFunctionHook("ChatFrame_OnEvent", -200, Auctioneer.AskPrice.OnEventHook);
end

function commandHandler(command, source)

	-- Did the command come from khaos or from /auc askprice xxxxx?
	local khaosCommand
	if (source == "GUI") then
		khaosCommand = true;
	else
		khaosCommand = false;
	end;

	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local cmd, param = command:match("^(%w+)%s*(.*)$");

	cmd = cmd or command or "";
	param = param or "";
	cmd = Auctioneer.Util.DelocalizeCommand(cmd);

	--Now for the real Command handling

	--/auctioneer askprice help
	if ((cmd == "") or (cmd == "help")) then
		chatPrintHelp();

	--/auctioneer askprice (on|off|toggle)
	elseif (cmd == 'on' or cmd == 'off' or cmd == 'toggle') then
		onOff(cmd, khaosCommand);

	--/auctioneer askprice trigger (char)
	elseif (cmd == 'trigger') then
		setTrigger(param, khaosCommand)

	--/auctioneer askprice (party|guild|smart|ad|whispers) (on|off|toggle)
	elseif (
		cmd == 'vendor'	or cmd == 'party'	or cmd == 'guild' or
		cmd == 'smart'	or cmd == 'ad'		or cmd == 'whispers'
	) then
		genVarSet(cmd, param, khaosCommand);

	--/auctioneer askprice word # (customSmartWord)
	elseif (cmd == 'word') then
		setCustomSmartWords(param, nil, nil, khaosCommand);

	elseif (cmd == 'send') then
		sendAskPrice(param)

	--Command not recognized
	else
		if khaosCommand == false then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActUnknown'):format(command));
		end
	end
end

function chatPrintHelp()
	local onOffToggle = " (".._AUCT('CmdOn').."|".._AUCT('CmdOff').."|".._AUCT('CmdToggle')..")";
	local lineFormat = "  |cffffffff/auctioneer askprice %s"..onOffToggle.."|r |cff2040ff[%s]|r\n          %s\n\n";

	Auctioneer.Util.ChatPrint("  |cffffffff/auctioneer askprice"..onOffToggle.."|r |cff2040ff["..Auctioneer.Util.GetLocalizedFilterVal('askprice').."]|r\n          " .. _AUCT('HelpAskPrice') .. "\n\n");

	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceWhispers'),	Auctioneer.Util.GetLocalizedFilterVal('askprice-whispers'),	_AUCT('HelpAskPriceWhispers')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceVendor'),		Auctioneer.Util.GetLocalizedFilterVal('askprice-vendor'),	_AUCT('HelpAskPriceVendor')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceParty'),		Auctioneer.Util.GetLocalizedFilterVal('askprice-party'),	_AUCT('HelpAskPriceParty')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceGuild'),		Auctioneer.Util.GetLocalizedFilterVal('askprice-guild'),	_AUCT('HelpAskPriceGuild')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceSmart'),		Auctioneer.Util.GetLocalizedFilterVal('askprice-smart'),	_AUCT('HelpAskPriceSmart')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceAd'),			Auctioneer.Util.GetLocalizedFilterVal('askprice-ad'),		_AUCT('HelpAskPriceAd')));

	lineFormat = "  |cffffffff/auctioneer askprice %s|r |cff2040ff[%s]|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceTrigger'),	Auctioneer.Command.GetFilterVal('askprice-trigger'),		_AUCT('HelpAskPriceTrigger')));

	lineFormat = "  |cffffffff/auctioneer askprice %s %d|r |cff2040ff[%s]|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceWord'), 1,	Auctioneer.Command.GetFilterVal('askprice-word1'),			_AUCT('HelpAskPriceWord')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceWord'), 2,	Auctioneer.Command.GetFilterVal('askprice-word2'),			_AUCT('HelpAskPriceWord')));

	lineFormat = "  |cffffffff/auctioneer askprice %s %s|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAskPriceSend'),			_AUCT('OptAskPriceSend'),								_AUCT('HelpAskPriceSend')));
end

--[[
	The onOff(state, chatprint) function handles AskPrice's state (whether it is currently on or off)
	If "on" or "off" is specified in the first argument then AskPrice's state is changed to that value,
	If "toggle" is specified then it will toggle AskPrice's state (if currently on then it will be turned off and vice-versa)

	If a boolean (or nil) value is passed as the first argument the conversion is as follows:
	"true" is the same as "on"
	"false" is the same as "off"
	"nil" is the same as "toggle"

	If chatprint is "true" then the state will also be printed to the user.
]]
function onOff(state, khaosCommand)
	if (type(state) == "string") then
		state = Auctioneer.Util.DelocalizeFilterVal(state);
	elseif (state == true) then
		state = 'on'
	elseif (state == false) then
		state = 'off'
	elseif (state == nil) then
		state = 'toggle'
	end

	if (state == 'on' or state == 'off') then
		Auctioneer.Command.SetFilter('askprice', state);
	elseif (state == 'toggle') then
		Auctioneer.Command.SetFilter('askprice', not Auctioneer.Command.GetFilter('askprice'));
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if khaosCommand == false then
		state = Auctioneer.Command.GetFilter('askprice')
		setKhaosSetKeyValue("askprice", Auctioneer.Command.GetFilter('askprice'))

		if (state) then
			Auctioneer.Util.ChatPrint(_AUCT('StatAskPriceOn'));
		else
			Auctioneer.Util.ChatPrint(_AUCT('StatAskPriceOff'));
		end
	end
end

function setTrigger(param, khaosCommand)
	if (not (type(param) == 'string')) then
		return
	end

	param = param:sub(1, 1)
	Auctioneer.Command.SetFilter('askprice-trigger', param)

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format("askprice ".._AUCT('CmdAskPriceTrigger'), param));
		setKhaosSetKeyValue('askprice-trigger', param)
	end
end

function genVarSet(variable, param, khaosCommand)
	if (type(param) == "string") then
		param = Auctioneer.Util.DelocalizeFilterVal(param);
	end

	local var = "askprice-"..variable

	if (param == "on" or param == "off" or type(param) == "boolean") then
		Auctioneer.Command.SetFilter(var, param);

	elseif (param == "toggle" or param == nil or param == "") then
		param = Auctioneer.Command.SetFilter(var, not Auctioneer.Command.GetFilter(var));
	end

	if khaosCommand == false then
		if (Auctioneer.Command.GetFilter(var)) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtAskPriceEnable'):format(Auctioneer.Util.LocalizeCommand(variable)));
			setKhaosSetKeyValue(var, true)
		else
			Auctioneer.Util.ChatPrint(_AUCT('FrmtAskPriceDisable'):format(Auctioneer.Util.LocalizeCommand(variable)));
			setKhaosSetKeyValue(var, false)
		end
	end
end

--Function for users to add/modify smartWords (written by Kandoko, integrated into AskPrice by MentalPower)
function setCustomSmartWords(param, number, word, khaosCommand)

	--Only parse the param if the pre-parsed components are not present.
	if (not (number and word)) then
		--Divide the large command into smaller logical sections (Shameless copy from the original function)
		number, word = param:match("^(%w+)%s*(.*)$");

		number = number or param or "";
		word = word or "";
	end

	number = tonumber(number)

	if (not (((type(param) == 'string') or (type(word) == 'string'))and number)) then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param or word, "askprice ".._AUCT('CmdAskPriceWord')));
		return
	end

	word = word:lower()

	--Save choosen words.
	if (number == 1) then
		Auctioneer.Command.SetFilter('askprice-word1', word)

	elseif (number == 2) then
		Auctioneer.Command.SetFilter('askprice-word2', word)
	else
		Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, "askprice ".._AUCT('CmdAskPriceWord')));
		return;
	end

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format(
			"askprice ".._AUCT('CmdAskPriceWord').." "..number,
			Auctioneer.Command.GetFilterVal('askprice-word'..number)
		));
		setKhaosSetKeyValue('askprice-word'..number, word)
	end
end

--Function to manually send AskPrice messages to a player
function sendAskPrice(param, player, text)
	--If we we were passed an unparsed param, and were not passed the digested ones, digest the param
	if (param and not (player and text)) then
		player, text = param:match("^(%w+)%s*(.*)$")
	end
	
	if (nLog) then nLog.AddMessage("Auctioneer","AucAskPrice.lua",N_DEBUG,"AskPrice Send command generated","player: "..tostring(player),"text: "..tostring(text));  end
	
	--If we still don't have the digested params, stop here.
	if (not (player and text)) then
		return
	end

	--Tail call to the eventHandler function, the fourth parameter is set to "true" to bypass the trigger/SmartWords checking.
	return eventHandler(askPriceFrame, "CHAT_MSG_WHISPER", text, player, true)
end

-------------------------------------------------------------------------------
-- Updates the Khaos settings, if khaos is installed.
--
-- called by:
--    genVarSet()           - if khaos settings should be changed
--    onOff()               - if khaos settings should be changed
--    setCustomSmartWords() - if khaos settings should be changed
--    setTrigger()          - if khaos settings should be changed
--
-- calls:
--    Khaos.getSetKey()          - if khaos is installed
--    Khaos.setSetKeyParameter() - if the setting is valid
--
-- parameters:
--    key   - (string) the khaos key id (i.e. auctioneer setting id) to be
--                     changed
--    value - (boolean) true/false, if the key represents a checkbox to be set
--                      to the given value
--            (string) the new value, if the key represents anything else but a
--                     checkbox
--
-- returns:
--    first value:
--       nil      - if no error occured
--       (number) - errorcode
--    second value:
--       nil      - if no error occured
--       (string) - errormessage
--
-- remarks:
--    Refer to the error codes section in AucUtil to get a list of possible
--    errors.
-------------------------------------------------------------------------------
function setKhaosSetKeyValue(key, value)
	if (Auctioneer_Khaos_Registered) then
		local kKey = Khaos.getSetKey("Auctioneer", key)

		if (not kKey) then
			return debugPrint("AucAskprice.setKhaosSetKeyParameter(): key "..key.." does not exist", 2)
		elseif (type(value) == "boolean") then
			Khaos.setSetKeyParameter("Auctioneer", key, "checked", value)
		else
			Khaos.setSetKeyParameter("Auctioneer", key, "value", value)
		end
	end
end

function eventHandler(self, event, text, player, ignoreTrigger)
	--Nothing to do if askprice is disabled
	if (not Auctioneer.Command.GetFilter('askprice')) then
		return;
	end

	--Make sure that we recieve the proper events and that our settings allow a response
	if (not ((event == "CHAT_MSG_WHISPER")
		or (
			((event == "CHAT_MSG_GUILD") or
			(event == "CHAT_MSG_OFFICER")) and
			Auctioneer.Command.GetFilter('askprice-guild')
		)
		or (
			((event == "CHAT_MSG_PARTY") or
			(event == "CHAT_MSG_RAID") or
			(event == "CHAT_MSG_RAID_LEADER")) and
			Auctioneer.Command.GetFilter('askprice-party'))
		)) then
		return;
	end

	local aCount, historicalMedian, snapshotMedian, vendorSell, askedCount, items, usedStack, multipleItems;

	-- Check for marker (trigger char or "smart" words) only if the ignore option is not set
	if (not (ignoreTrigger == true)) then --We need to check for "true" here, since Blizzard might decide to send us a fourth parameter.
		if (not (text:sub(1, 1) == Auctioneer.Command.GetFilterVal('askprice-trigger'))) then

			--If the trigger char was not found scan the text for SmartWords (if the feature has been enabled)
			if (Auctioneer.Command.GetFilter('askprice-smart')) then
				-- Check if the custom SmartWords are present in the chat message
				-- Note, that both words must be contained in the text, to be identified as a valid askprice request.
				if (not (
					text:lower():find(Auctioneer.Command.GetFilterVal('askprice-word1'), 1, true) and
					text:lower():find(Auctioneer.Command.GetFilterVal('askprice-word2'), 1, true)
				)) then
					return;
				end
			else
				return;
			end
		end
	end

	-- Check for itemlink after trigger
	if (not (text:find("|Hitem:"))) then
		return;
	end

	--Parse the text and separate out the different links
	items = getItems(text)
	for key, item in ipairs(items) do --Do the items in the order they were recieved.
		aCount, historicalMedian, snapshotMedian, vendorSell = getData(item.link);
		local askedCount;

		--If there are multiple items send a separator line (since we can't send \n's as those would cause DC's)
		if (multipleItems) then
			Auctioneer.AskPrice.SendWhisper("    ", player);
		end

		local strHistOne, strSnapOne
		--If the stackSize is grater than one, add the unit price to the message
		if (item.count > 1) then
			strHistOne = _AUCT('FrmtAskPriceEach'):format(EnhTooltip.GetTextGSC(historicalMedian, nil, true));
			strSnapOne = _AUCT('FrmtAskPriceEach'):format(EnhTooltip.GetTextGSC(snapshotMedian, nil, true));
		else
			strHistOne = "";
			strSnapOne = ""
		end

		if (aCount > 0) then
			Auctioneer.AskPrice.SendWhisper(item.link..": ".._AUCT('FrmtInfoSeen'):format(aCount), player);
			Auctioneer.AskPrice.SendWhisper(
				_AUCT('FrmtAskPriceBuyoutMedianHistorical'):format(
					"    ",
					EnhTooltip.GetTextGSC(historicalMedian*item.count, nil, true),
					strHistOne),
				player
			);
			Auctioneer.AskPrice.SendWhisper(
				_AUCT('FrmtAskPriceBuyoutMedianSnapshot'):format(
					"    ",
					EnhTooltip.GetTextGSC(snapshotMedian*item.count, nil, true),
					strSnapOne),
				player
			);
		else
			Auctioneer.AskPrice.SendWhisper(item.link..": ".._AUCT('FrmtInfoNever'):format(Auctioneer.Util.GetAuctionKey()), player);
		end

		--Send out vendor info if we have it
		if (Auctioneer.Command.GetFilter('askprice-vendor') and (vendorSell > 0)) then

			local strVendOne
			--Again if the stackSize is grater than one, add the unit price to the message
			if (item.count > 1) then
				strVendOne = _AUCT('FrmtAskPriceEach'):format(EnhTooltip.GetTextGSC(vendorSell, nil, true));
			else
				strVendOne = "";
			end

			Auctioneer.AskPrice.SendWhisper(
				_AUCT('FrmtAskPriceVendorPrice'):format(
					"    ",
					EnhTooltip.GetTextGSC(vendorSell * item.count, nil, true),
					strVendOne),
				player
			);
		end

		usedStack = usedStack or (item.count > 1)
		multipleItems = true;
	end

	--Once we're done sending out the itemInfo, check if the person used the stack size feature, if not send them the ad message.
	if ((not usedStack) and (Auctioneer.Command.GetFilter('askprice-ad'))) then
		if (not sentAskPriceAd[player]) then --If the player in question has been sent the ad message in this session, don't spam them again.
			sentAskPriceAd[player] = true
			Auctioneer.AskPrice.SendWhisper(_AUCT('AskPriceAd'):format(Auctioneer.Command.GetFilterVal('askprice-trigger')), player)
		end
	end
end

function getData(itemLink)
	local auctKey = Auctioneer.Util.GetHomeKey();
	local itemKey = Auctioneer.ItemDB.CreateItemKeyFromLink(itemLink);
	local itemID = Auctioneer.ItemDB.BreakItemKey(itemKey);

	local itemTotals = Auctioneer.HistoryDB.GetItemTotals(itemKey, auctKey);
	local historicalMedian, historicalMedCount = Auctioneer.Statistic.GetItemHistoricalMedianBuyout(itemKey, auctKey);
	local snapshotMedian, snapshotMedCount = Auctioneer.Statistic.GetItemSnapshotMedianBuyout(itemKey, auctKey);
	local vendorSell = Auctioneer.API.GetVendorSellPrice(itemID)

	local seenCount
	if (itemTotals) then
		seenCount = itemTotals.seenCount
	end

	return seenCount or 0, historicalMedian or 0, snapshotMedian or 0, vendorSell or 0;
end

--Many thanks to the guys at irc://chat.freenode.net/wowi-lounge for their help in creating this function
function getItems(str)
	if (not str) then return nil end
	local itemList = {};

	for number, color, item, name in str:gmatch("(%d*)%s*|c(%x+)|Hitem:([^|]+)|h%[(.-)%]|h|r") do
		table.insert(itemList, {link = "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r", count = tonumber(number) or 1})
	end
	return itemList;
end

function sendWhisper(message, player)
	whisperList[message] = true
	SendChatMessage(message, "WHISPER", Auctioneer.AskPrice.Language, player)
end

-- parameters:
--    event = the name of the event
--    ...   = all arguments for that event
function onEventHook(_, _, event, ...)
	if (event == "CHAT_MSG_WHISPER_INFORM") then
		if (whisperList[arg1]) then
			whisperList[arg1] = nil
			if (Auctioneer.Command.GetFilter('askprice-whispers')==false) then
				return "abort"
			end
		end
	end
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
	return Auctioneer.Util.DebugPrint(message, "AucAskPrice", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.AskPrice) then return end;

Auctioneer.AskPrice = {
	Init                = init,
	CommandHandler      = commandHandler,
	ChatPrintHelp       = chatPrintHelp,
	OnOff               = onOff,
	SetTrigger          = setTrigger,
	GenVarSet           = genVarSet,
	SetCustomSmartWords = setCustomSmartWords,
	EventHandler        = eventHandler,
	SendWhisper         = sendWhisper,
	OnEventHook         = onEventHook
}
