------------------------------------------------------
-- Linkerator.lua
-- Link scanning code based on LootLink 1.9. Thanks Telo!
------------------------------------------------------

FLT_RandomItemIDs = { };
FLT_RandomPropIDs = { };
FLT_RandomItemCombos = { };

FLT_Locale = GetLocale();
FLT_RandomPropIDs[FLT_Locale] = { };
FLT_RandomItemCombos[FLT_Locale] = { };
FLT_AuctionLinks = {};

local ChatMessageTypes = {
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_SAY",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_YELL",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_RAID",
	"CHAT_MSG_LOOT",
};

local INVENTORY_SLOT_LIST = {
	{ name = "HeadSlot" },
	{ name = "NeckSlot" },
	{ name = "ShoulderSlot" },
	{ name = "BackSlot" },
	{ name = "ChestSlot" },
	{ name = "ShirtSlot" },
	{ name = "TabardSlot" },
	{ name = "WristSlot" },
	{ name = "HandsSlot" },
	{ name = "WaistSlot" },
	{ name = "LegsSlot" },
	{ name = "FeetSlot" },
	{ name = "Finger0Slot" },
	{ name = "Finger1Slot" },
	{ name = "Trinket0Slot" },
	{ name = "Trinket1Slot" },
	{ name = "MainHandSlot" },
	{ name = "SecondaryHandSlot" },
	{ name = "RangedSlot" },
};

-- number greater than the highest known item ID, used to import link names from client cache.
-- may need updating as future patches/expansions add items to the game.
FLT_MAX_ITEM_ID = 60000;
FLT_MAX_SPELL_ID = 80000;

FLT_COMPLETE_DELAY_DEFAULT = 0.25;

-- Anti-freeze code borrowed from ReagentInfo (in turn, from Quest-I-On):
-- keeps WoW from locking up if we try to scan the tradeskill window too fast.
FLT_TradeSkillLock = { };
FLT_TradeSkillLock.NeedScan = false;
FLT_TradeSkillLock.Locked = false;
FLT_TradeSkillLock.EventTimer = 0;
FLT_TradeSkillLock.EventCooldown = 0;
FLT_TradeSkillLock.EventCooldownTime = 1;

------------------------------------------------------
-- Autocompletion in chat edit box 
------------------------------------------------------

function FLT_ChatEdit_OnChar()
	if (not FLT_ChatEdit_ShouldComplete(this)) then
		if (FLT_Orig_ChatEdit_OnChar) then return FLT_Orig_ChatEdit_OnChar(); end
	end
	
	local text = this:GetText();
	local textlen = strlen(text);
    local _, _, query = string.find(text, "%[([^]]-)$");
	if (query and string.len(query) > 0) then
		FLT_PartialText = text;
	end
	
	FLT_ChatCompleteQueued = GetTime();
	FLT_CompletionBox = this;
end

function FLT_ChatEdit_ShouldComplete(editBox)
	local text = editBox:GetText();
	
	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";
	command = strupper(command);
	
	-- don't autocomplete in scripts
	if (command == "/SCRIPT" or command == "/RUN" or command == "/DUMP" ) then
		return;
	end

	-- don't autocomplete in secure /commands or we'll taint the text and cause the commands to be blocked
	-- item links don't make sense in most of the secure commands anyway
	if (IsSecureCmd(command)) then
		return; 
	end
	
	return true;
	
end

function FLT_ChatEdit_Complete(editBox)

	local text = editBox:GetText();

	-- if the text contains any completed (brackets on both sides) links, "linkify" them
    local newText = FLT_ParseChatMessage(text);
	if (newText ~= text) then
		editBox:SetText(newText);
		FLT_PartialText = nil;
		FLT_Matches = nil;
		FLT_LastCompletion = nil;
		FLT_HighlightStart = nil;
		FLT_MatchCount = 0;	-- will get incremented before use
		return;
	end

	-- if we just typed a ']' and had highlighted completion text, finish it
	local _, _, closedPart = string.find(text, "%[([^]]-)%]$");
	if (closedPart and FLT_LastCompletion) then
		local lowerQuery = string.lower(closedPart); -- for case insensitive lookups
		if (string.sub(string.lower(FLT_LastCompletion), 1, string.len(lowerQuery)) == lowerQuery) then
			local newText = string.gsub(text, "%[([^]]-)%]$", "["..FLT_LastCompletion.."]");
		    newText = FLT_ParseChatMessage(newText);
			if (newText ~= text) then
				editBox:SetText(newText);
				FLT_PartialText = nil;
				FLT_Matches = nil;
				FLT_LastCompletion = nil;
				FLT_HighlightStart = nil;
				return;
			end
		end
	end
	
	-- otherwise, see if there's a partial link typed and provide highlighted completion
	local textlen = strlen(text);
    local _, _, query = string.find(text, "%[([^]]-)$");
	if (query and string.len(query) > 0) then
		FLT_PartialText = text;
		FLT_Matches = FLT_LinkPrefixMatches(query);
		FLT_MatchCount = 1;
		
		if (FLT_Matches and FLT_Matches[FLT_MatchCount]) then
			local lowerQuery = string.lower(query); -- for case insensitive lookups
			lowerQuery = string.gsub(lowerQuery, "([%$%(%)%.%[%]%*%+%-%?%^%%])", "%%%1"); -- convert regex special characters
			local completion = string.gsub(FLT_Matches[FLT_MatchCount], "^"..lowerQuery, query);
			local newText = string.gsub(text, "%[([^]]-)$", "["..completion);
			FLT_LastCompletion = completion;
			editBox:SetText(newText);
			editBox:HighlightText(textlen);
			FLT_HighlightStart = textlen;
			return;
		end
	end
	
end

function FLT_ChatEdit_OnTextChanged(self)

	if (not FLT_ChatEdit_ShouldComplete(this)) then
		if (FLT_Orig_ChatEdit_OnTextChanged) then return FLT_Orig_ChatEdit_OnTextChanged(self); end
	end
	
	local text = this:GetText();
	-- reset matches if text has been deleted
	if (FLT_PartialText and string.len(text) <= string.len(FLT_PartialText)) then
		FLT_HighlightStart = nil;
		FLT_LastCompletion = nil;
		FLT_Matches = nil;
		FLT_MatchCount = 0;	-- will get incremented before use
	end
	FLT_Orig_ChatEdit_OnTextChanged(this);
	if (FLT_HighlightStart and FLT_HighlightStart < string.len(text)) then
		this:HighlightText(FLT_HighlightStart);
	end
end

function FLT_ChatEdit_OnTabPressed()

	if (not FLT_ChatEdit_ShouldComplete(this)) then
		if (FLT_Orig_ChatEdit_OnTabPressed) then return FLT_Orig_ChatEdit_OnTabPressed(); end
	end
	
	-- if we haven't highlighted text, we don't have matches agains the current query
	if (FLT_PartialText and not FLT_HighlightStart) then
		FLT_PartialText = this:GetText();
		local _, _, query = string.find(FLT_PartialText, "%[([^]]-)$");
		if (query and string.len(query) > 0) then
			FLT_Matches = FLT_LinkPrefixMatches(query);
		end
	end
	if (FLT_Matches and table.getn(FLT_Matches) > 0) then

		local prefix = FLT_CommonPrefixFromList(FLT_Matches);
			
	    local _, _, query = string.find(FLT_PartialText, "%[([^]]-)$");
		local lowerQuery = string.lower(query); -- for case insensitive lookups
		lowerQuery = string.gsub(lowerQuery, "([%$%(%)%.%[%]%*%+%-%?%^%%])", "%%%1"); -- convert regex special characters
		if (prefix and string.len(prefix) > string.len(query)) then
			local expandedPrefix = string.gsub(prefix, "^"..lowerQuery, query);
			local newText = string.gsub(FLT_PartialText, "%[([^]]-)$", "["..expandedPrefix);
			if (FLT_PartialText ~= newText) then
				this:SetText(newText);
				FLT_ChatEdit_OnChar(this);
				FLT_PartialText = newText;
			    local _, _, newQuery = string.find(FLT_PartialText, "%[([^]]-)$");
				if (newQuery and string.len(newQuery) > 0) then
					FLT_Matches = FLT_LinkPrefixMatches(newQuery);
				end
			end
			return;
		elseif (FLT_Matches and table.getn(FLT_Matches) > 0) then
			-- we've hit tab and there's no prefix to expand
			FLT_MatchCount = FLT_MatchCount + 1;
			if (FLT_MatchCount > table.getn(FLT_Matches)) then
				FLT_MatchCount = 1;
			end
		
			-- if we add a display of the match list, it should go here...

			local completion = string.gsub(FLT_Matches[FLT_MatchCount], "^"..lowerQuery, query);
			newText = string.gsub(FLT_PartialText, "%[([^]]-)$", "["..completion);
			FLT_LastCompletion = completion;
			this:SetText(newText);
			local textlen = string.len(FLT_PartialText);
			this:HighlightText(textlen);
			FLT_HighlightStart = textlen;
			return;
		end
	end
	FLT_Orig_ChatEdit_OnTabPressed(this);
end

function FLT_ChatEdit_OnEscapePressed()
	FLT_ResetCompletion();
end

function FLT_ChatEdit_OnEnterPressed()
	FLT_ResetCompletion();
end

function FLT_ResetCompletion()
	if (FLT_ItemCacheFull and not ChatFrameEditBox:IsVisible()) then
		FLT_ItemNamesCache = nil;
		collectgarbage();
		FLT_ItemCacheFull = nil;
	end
	FLT_PartialText = nil;
	FLT_Matches = nil;
	FLT_LastCompletion = nil;
	FLT_HighlightStart = nil;
	FLT_MatchCount = 0;	-- will get incremented before use
end

function FLT_SendChatMessage(message, type, language, channel)
	-- if the text contains any completed (brackets on both sides) links, "linkify" them
    message = FLT_ParseChatMessage(message);
	FLT_Orig_SendChatMessage(message, type, language, channel);
	FLT_ResetCompletion();
end

function FLT_OnLoad()
	--GFWUtils.Debug = 1;
	-- Register Slash Commands
	SLASH_FLT1 = "/linkerator";
	SLASH_FLT2 = "/link";
	SlashCmdList["FLT"] = function(msg)
		FLT_ChatCommandHandler(msg);
	end
	
	for index, value in ipairs(ChatMessageTypes) do
		this:RegisterEvent(value);
	end

	for index = 1, getn(INVENTORY_SLOT_LIST), 1 do
		INVENTORY_SLOT_LIST[index].id = GetInventorySlotInfo(INVENTORY_SLOT_LIST[index].name);
	end
		
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_LEAVING_WORLD");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("MERCHANT_SHOW");
	this:RegisterEvent("MERCHANT_UPDATE");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_UPDATE");
	this:RegisterEvent("QUEST_COMPLETE");
	this:RegisterEvent("QUEST_DETAIL");
	this:RegisterEvent("QUEST_FINISHED");
	this:RegisterEvent("QUEST_PROGRESS");
	this:RegisterEvent("QUEST_GREETING");
	this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
	
	-- hooks for autocompletion in the edit box
	FLT_Orig_ChatEdit_OnChar = ChatFrameEditBox:GetScript("OnChar");
	ChatFrameEditBox:SetScript("OnChar", FLT_ChatEdit_OnChar);
	FLT_Orig_ChatEdit_OnTextChanged = ChatEdit_OnTextChanged;
	ChatEdit_OnTextChanged = FLT_ChatEdit_OnTextChanged;
	FLT_Orig_ChatEdit_OnTabPressed = ChatEdit_OnTabPressed;
	ChatEdit_OnTabPressed = FLT_ChatEdit_OnTabPressed;

	-- hooks for automatic linkifying of other text sent to chat
	FLT_Orig_SendChatMessage = SendChatMessage;
	SendChatMessage = FLT_SendChatMessage;

	-- hooks for cleaning up after completion
	hooksecurefunc("ChatEdit_OnEscapePressed", FLT_ChatEdit_OnEscapePressed);
	hooksecurefunc("ChatEdit_OnEnterPressed", FLT_ChatEdit_OnEnterPressed);
	
	-- hooks for harvesting links
	FLT_Orig_QuestLog_UpdateQuestDetails = QuestLog_UpdateQuestDetails;
	QuestLog_UpdateQuestDetails = FLT_QuestLog_UpdateQuestDetails;

	-- hooks for keeping track of AH state during link scanning
	hooksecurefunc("SortAuctionClearSort", FLT_SortAuctionClearSort);
	hooksecurefunc("SortAuctionSetSort", FLT_SortAuctionSetSort);
	
end

FLT_UpdateInterval = 1;
FLT_CompleteDelay = FLT_COMPLETE_DELAY_DEFAULT;
function FLT_OnUpdate(elapsed)

	if (FLT_ChatCompleteQueued and GetTime() - FLT_ChatCompleteQueued >= FLT_CompleteDelay) then
		FLT_ChatEdit_Complete(FLT_CompletionBox);
		FLT_ChatCompleteQueued = nil;
	end

	this.TimeSinceLastUpdate = (this.TimeSinceLastUpdate or 0) + elapsed;        
	if (this.TimeSinceLastUpdate <= FLT_UpdateInterval) then return; end
	this.TimeSinceLastUpdate = 0;

	-- If it's been more than a second since our last tradeskill update,
	-- we can allow the event to process again.
	FLT_TradeSkillLock.EventTimer = FLT_TradeSkillLock.EventTimer + elapsed;
	if (FLT_TradeSkillLock.Locked) then
		FLT_TradeSkillLock.EventCooldown = FLT_TradeSkillLock.EventCooldown + elapsed;
		if (FLT_TradeSkillLock.EventCooldown > FLT_TradeSkillLock.EventCooldownTime) then

			FLT_TradeSkillLock.EventCooldown = 0;
			FLT_TradeSkillLock.Locked = false;
		end
	end
	
	if (FLT_TradeSkillLock.NeedScan) then
		FLT_TradeSkillLock.NeedScan = false;
		FLT_ScanTradeSkill();
	end
	
	if (table.getn(FLT_AuctionLinks) > 0) then
		for i = 1, NUM_AUCTION_ITEMS_PER_PAGE do
			FLT_ProcessLinks(FLT_AuctionLinks[1]);
			table.remove(FLT_AuctionLinks, 1);
		end
	end
end

function FLT_OnEvent(event)
	if( event == "PLAYER_TARGET_CHANGED" ) then
		if( UnitIsUnit("target", "player") ) then
			return;
		elseif( UnitIsPlayer("target") ) then
			FLT_Inspect("target");
		end
	elseif( event == "PLAYER_ENTERING_WORLD" or (event == "ADDON_LOADED" and arg1 == "GFW_Linkerator")) then
		FLT_ScanInventory();
		FLT_Inspect("player");
		this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	elseif( event == "PLAYER_LEAVING_WORLD" ) then
		this:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	elseif( event == "UNIT_INVENTORY_CHANGED" ) then
		if( arg1 == "player" ) then
			FLT_ScanInventory();
			FLT_Inspect("player");
		end
	elseif( event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" ) then
		for i=1, GetMerchantNumItems() do
			local link = GetMerchantItemLink(i);
			if ( link ) then
				FLT_ProcessLinks(link);
			end
		end
	elseif( event == "BANKFRAME_OPENED" ) then
		FLT_ScanBank();
	elseif( event == "AUCTION_ITEM_LIST_UPDATE" ) then
		FLT_ScanAuction();
	elseif ( event == "QUEST_COMPLETE" or event == "QUEST_DETAIL" or event == "QUEST_FINISHED" or event == "QUEST_PROGRESS" or event == "QUEST_GREETING") then
		FLT_ScanQuestgiver();
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" ) then
		FLT_ScanTradeSkill();
	elseif (event == "CHAT_MSG_CHANNEL") then
		--DevTools_Dump({event=event, args={arg1=arg1,arg2=arg2,arg3=arg3,arg4=arg4,arg5=arg5,arg6=arg6,arg7=arg7,arg8=arg8,arg9=arg9,}});
		if (FLT_Debug) then
			debugprofilestart();
		end
		local gotLink = FLT_ProcessLinks(arg1);
		if (FLT_Debug) then
			local parseTime = debugprofilestop();
			if (gotLink) then
				FLT_MaxFoundTime = math.max((FLT_MaxFoundTime or 0), parseTime);
			else
				FLT_MaxNotFoundTime = math.max((FLT_MaxNotFoundTime or 0), parseTime);
			end
		end
	else
		FLT_ProcessLinks(arg1);
	end
end

function FLT_ChatCommandHandler(msg)

	-- Print Help
	if ( msg == "help" ) or ( msg == "" ) then
		local version = GetAddOnMetadata("GFW_Linkerator", "Version");
		GFWUtils.Print("Fizzwidget Linkerator "..version..":");
		GFWUtils.Print("/linkerator (or /link) <command>");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - Print this helplist.");
		GFWUtils.Print("- "..GFWUtils.Hilite("delay <seconds>").." - Change the delay before links typed in chat are automatically completed.");
		GFWUtils.Print("- "..GFWUtils.Hilite("<item name>").." - Print a hyperlink to the chat window for an item known by name.");
		GFWUtils.Print("- "..GFWUtils.Hilite("<item id #>").." - Print a hyperlink to the chat window for a generic item whose ID number is known.");
		GFWUtils.Print("- "..GFWUtils.Hilite("<code>").." - Print a hyperlink to the chat window for an item whose complete link code is known.");
		return;
	end

	if (msg == "debug") then
		if (FLT_Debug) then
			FLT_Debug = nil;
			GFWUtils.Print("Linkerator debugging messages off.");
		else
			FLT_Debug = 1;
			GFWUtils.Print("Linkerator debugging messages on.");
		end
		return;
	end

	local _, _, delay = string.find(msg, "^delay (.+)");
	if (delay or msg == "delay") then
		if (delay == "reset") then
			FLT_CompleteDelay = FLT_COMPLETE_DELAY_DEFAULT;
		elseif (tonumber(delay)) then
			FLT_CompleteDelay = tonumber(delay);
		end
		GFWUtils.Print(string.format("Linkerator will attempt to complete links typed in chat "..GFWUtils.Hilite("%.2f").." seconds after a character is typed.", FLT_CompleteDelay));
		GFWUtils.Print("Type "..GFWUtils.Hilite("/link delay <seconds>").." to change the delay, or "..GFWUtils.Hilite("/link delay reset").." to reset to default.");
		return;
	end
	
	if (msg and msg ~= "") then
		if (FLT_PrintLinkSearch(msg)) then return; end
	end
	
	-- If we're this far, we probably have bad input.
	FDP_ChatCommandHandler("help");
end

function FLT_GetItemLink(linkInfo, shouldAdd)
	if (linkInfo == nil) then
		FLT_DebugLog(debugstack(1, 3, 0));
		error("invalid argument #1 to FLT_GetItemLink()", 2);
	end
	local sName, sLink = GetItemInfo(linkInfo);
	if (sLink and shouldAdd) then
		added = FLT_AddLink(sName, sLink); -- add it to our name index if we're getting it from another source
	end
	return sLink;
end

------------------------------------------------------
-- Searching for links
------------------------------------------------------

function FLT_PrintLinkSearch(msg)
	
	-- if it's just a number, try it as an itemID
	if (tonumber(msg)) then
		--DevTools_Dump({msg=msg});
		local link = FLT_GetItemLink(msg, 1);
		if (link) then
			GFWUtils.Print("Item ID "..msg..": "..link);
		else
			LinkeratorTip.printHyperlinkID = 1;
			LinkeratorTip:SetHyperlink("item:"..msg);
		end
		return true;
	end
	
	-- dump code when a full link is provided
	local _, _, itemLink = string.find(msg, "(item:[-%d:]+)");
	local _, _, enchantLink = string.find(msg, "(enchant:[-%d:]+)");
	local _, _, spellLink = string.find(msg, "(spell:[-%d:]+)");
	local _, _, talentLink = string.find(msg, "(talent:[-%d:]+)");
	local _, _, questLink = string.find(msg, "(quest:[-%d:]+)");
	if (itemLink) then
		--DevTools_Dump({msg=msg, itemLink=itemLink});
		local link = FLT_GetItemLink(itemLink);
		if (link) then
			GFWUtils.Print(itemLink..": "..link);
		else
			GFWUtils.Print(itemLink.." is unknown to this WoW client.");
		end
		return true;
	elseif (enchantLink) then
		--DevTools_Dump({msg=msg, itemLink=itemLink});
		local _, _, enchantID = string.find(msg, "enchant:(%d+)");
		local link = FLT_EnchantLink(enchantID);
		if (link) then
			GFWUtils.Print(enchantLink..": "..link);
		else
			GFWUtils.Print(enchantLink.." is unknown, or not a tradeskill link.");
		end
		return true;
	elseif (spellLink or talentLink or questLink) then
		local _, _, link = string.find(msg, "(|c%x+.-|h|r)");
		GFWUtils.Print((spellLink or talentLink or questLink)..": "..link);
		return true;
	end
	
	FLT_ResetItemNamesCache();
	
	-- search for basic item links (no random property)
	local foundCount = 0;
	msg = string.lower(msg);
	
	local itemsFound = FLT_SearchItems(msg, true);
	foundCount = foundCount + #itemsFound;
	
	-- search random-property items
	for itemID in pairs(FLT_RandomItemIDs) do
		if (type(itemID) == "number") then
			local baseName = FLT_ItemNamesCache[itemID];
			if (baseName) then
				baseName = string.lower(baseName);
				if (string.find(msg, baseName, 1, true)) then
					-- if the query string entirely contains the base name, search for observed variations that match
					local observedVariations = FLT_RandomItemCombos[FLT_Locale][itemID];
					if (observedVariations) then
						for propID, uniqueID in pairs(observedVariations) do
							local propName = FLT_RandomPropIDs[FLT_Locale][propID];
							if (propName) then
								--DevTools_Dump({baseName=baseName, propName=propName, itemID=itemID, propID=propID})
								local fullName = string.format(propName, baseName);
								if (string.find(fullName, msg, 1, true)) then
									local fullLink = GFWUtils.BuildItemLink(itemID, nil, nil, nil, nil, nil, propID, uniqueID);
									local link = FLT_GetItemLink(fullLink);
									if (link) then
										if (FLT_Debug) then
											GFWUtils.Print(link.." ("..fullLink..")");
										else
											GFWUtils.Print(link);
										end
										foundCount = foundCount + 1;
									end
								end
							end
						end
					end
				elseif (string.find(baseName, msg, 1, true)) then
					-- if the query string is a substring of the base name, just list the base item with some info on the variations
					local observedVariations = FLT_RandomItemCombos[FLT_Locale][itemID];
					local variationCount = 0;
					if (observedVariations) then
						variationCount = table.getn(observedVariations);
					end
					local link = FLT_GetItemLink(itemID);
					if (link) then
						local extraText = string.format(": random-property item (%s variants seen), type %s to see them all", GFWUtils.Hilite(variationCount), GFWUtils.Hilite("/link "..baseName));
						if (FLT_Debug) then
							GFWUtils.Print(link.." ("..itemID..")"..extraText);
						else
							GFWUtils.Print(link..extraText);
						end
						foundCount = foundCount + 1;
					end
				end
			end
		end
	end
	
	FLT_ResetSpellNamesCache();
	-- search spells
	local spellsFound = FLT_SearchSpells(msg, true);
	foundCount = foundCount + #spellsFound;
	
	-- also search for exact matches and query strings with parenthesized descriptors
	local foundLinks = FLT_GetLinkByName(msg, true);
	if (foundLinks) then
		if (type(foundLinks) == "string") then
			foundCount = foundCount + 1;
			if (FLT_Debug) then
				local _, _, linkInfo = string.find(foundLinks, "(item:[-%d:]+)");
				if (linkInfo == nil) then
					_, _, linkInfo = string.find(foundLinks, "(enchant:%d+)");
				end
				GFWUtils.Print(foundLinks.." ("..linkInfo..")");
			else
				GFWUtils.Print(foundLinks);
			end
		elseif (type(foundLinks) == "table") then
			for _, aLink in pairs(foundLinks) do
				foundCount = foundCount + 1;
				if (FLT_Debug) then
					local _, _, linkInfo = string.find(aLink, "(item:[-%d:]+)");
					if (linkInfo == nil) then
						_, _, linkInfo = string.find(aLink, "(enchant:%d+)");
					end
					GFWUtils.Print(aLink.." ("..linkInfo..")");
				else
					GFWUtils.Print(aLink);
				end
			end
		else
			GFWUtils.Print(GFWUtils.Red("Linkerator error: ").."Unexpected result from FLT_GetLinkByName().");
		end
	end
	
	FLT_ItemNamesCache = nil;
	collectgarbage();
	
	if (foundCount > 0) then
		GFWUtils.Print(GFWUtils.Hilite(foundCount).." links found for '"..GFWUtils.Hilite(msg).."'");
	else
		GFWUtils.Print("Could not find '"..GFWUtils.Hilite(msg).."' in Linkerator's item history.");
		GFWUtils.Print("Type '"..GFWUtils.Hilite("/link help").."' for options.");
	end
	return true;
end

function FLT_SearchItems(text, printResults)
	text = string.lower(text);
	local itemsFound = {};
	for itemID = 1, FLT_MAX_ITEM_ID do
		if (not FLT_RandomItemIDs[itemID]) then
			local itemName = FLT_ItemNamesCache[itemID];
			if (itemName) then
				itemName = string.lower(itemName);
				if (itemName ~= text and string.find(itemName, text, 1, true)) then
					table.insert(itemsFound, itemID);
				end
			end
		end
	end
	if (printResults and #itemsFound > 0) then
		for _, itemID in pairs(itemsFound) do
			local _, link = GetItemInfo(itemID);
			if (FLT_Debug) then
				GFWUtils.Print(link.." ("..itemID..")");
			else
				GFWUtils.Print(link);
			end
		end
	end
	return itemsFound;
end

function FLT_SearchSpells(text, printResults)
	text = string.lower(text);
	local spellsFound = {};
	for spellID = 1, FLT_MAX_SPELL_ID do
		local spellName = FLT_SpellNamesCache[spellID];
		if (spellName) then
			spellName = string.lower(spellName);
			if (string.find(spellName, text, 1, true)) then
				table.insert(spellsFound, spellID);
			end
		end
	end
	if (printResults and #spellsFound > 0) then
		for _, spellID in pairs(spellsFound) do
			local spellName = GetSpellInfo(spellID);
			local cachedName = FLT_SpellNamesCache[spellID];
			local link;
			if (cachedName == spellName) then
				-- it's a regular spell
				link = GetSpellLink(spellID);
			else
				-- it's a tradeskill
				link = FLT_EnchantLink(spellID);
			end
			if (FLT_Debug) then
				GFWUtils.Print(link.." ("..spellID..")");
			else
				GFWUtils.Print(link);
			end
		end
	end
	return spellsFound;
end

function FLT_GetLinkByName(text, returnAll)
	
	-- if we're passed some form of link code, just resolve it
	if (string.find(text, "^(item:[-%d:]+)$")) then
		local link = FLT_GetItemLink(text);
		if (link) then return link; end
	elseif (string.find(text, "^(enchant:%d+)$")) then
		local _, _, enchantID = string.find(text, "enchant:(%d+)");
		local link = FLT_EnchantLink(enchantID);
		if (link) then return link; end
	elseif (string.find(text, "^#%d+$")) then
		local link = FLT_GetItemLink(string.sub(text,2));
		if (link) then return link; end
	end

	-- otherwise, we get into searching for matches by name
	local lowerText = string.lower(text);
	local allResults = {};
	
	FLT_ResetItemNamesCache();
	
	-- try to find exact matches for the text in basic (no random property) items
	for itemID = 1, FLT_MAX_ITEM_ID do
		if (not FLT_RandomItemIDs[itemID]) then
			local itemName = FLT_ItemNamesCache[itemID];
			if (itemName and string.lower(itemName) == lowerText) then
				local _, link = GetItemInfo(itemID);
				if (not returnAll) then
					return link;
				else
					table.insert(allResults, link);
				end
			end
		end
	end
		
	-- try to find exact matches in the random-property items
	for itemID in pairs(FLT_RandomItemIDs) do
		if (type(itemID) == "number") then
			local baseName = FLT_ItemNamesCache[itemID];
			if (baseName) then
				baseName = string.lower(baseName);
				if (string.find(lowerText, baseName, 1, true)) then
					-- if the query string entirely contains the base name, search for observed variations that match
					local observedVariations = FLT_RandomItemCombos[FLT_Locale][itemID];
					if (observedVariations) then
						for propID, uniqueID in pairs(observedVariations) do
							local propName = FLT_RandomPropIDs[FLT_Locale][propID];
							if (propName) then
								--DevTools_Dump({baseName=baseName, propName=propName, itemID=itemID, propID=propID})
								local fullName = string.format(propName, baseName);
								if (fullName == lowerText) then
									local fullLink = GFWUtils.BuildItemLink(itemID, nil, nil, nil, nil, nil, propID, uniqueID);
									local link = FLT_GetItemLink(fullLink);
									if (link) then 
										if (returnAll) then
											table.insert(allResults, link);
										else
											return link;
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- no exact matches, so we prepare to look for parenthesized description elements and search based on those
	local _, _, name, description = string.find(lowerText, "(.+)%((.-)%)" );
	-- 'description' here is some text from the item's tooltip, such as part of a slot name or a stat line
	-- e.g. "warblade of the hakkari (main)" or "funky boots of the eagle (11 int)"
	if (name and description) then
		name = string.gsub(name, " +$", ""); -- drop trailing spaces
	
		-- back in the basic (no random property) items, now looking based on description
		local basicResults = {};
		for itemID = 1, FLT_MAX_ITEM_ID do
			if (not FLT_RandomItemIDs[itemID]) then
				local itemName = FLT_ItemNamesCache[itemID];
				if (itemName and string.lower(itemName) == name) then
					local _, link = GetItemInfo(itemID);
					table.insert(basicResults, link);
				end
			end
		end
		if (not returnAll and #basicResults == 1) then
			-- only one exact match for the name, no description needed
			return basicResults[1];
		elseif (#basicResults > 1) then
			-- see if the description matches the item type or equip location
			for _, link in pairs(basicResults) do
				if (FLT_ItemLinkMatchesDescriptor(link, description)) then
					if (returnAll) then
						table.insert(allResults, link);
					else
						return link;
					end
				end
			end
			-- failing that, see if the description matches any text from the item tooltip
			for _, link in pairs(basicResults) do
				if (FLT_FindInItemTooltip(description, link)) then
					if (returnAll) then
						table.insert(allResults, link);
					else
						return link;
					end
				end
			end 
		end
			
		-- look for random-property items based on description
		for itemID in pairs(FLT_RandomItemIDs) do
			if (type(itemID) == "number") then
				local baseName = FLT_ItemNamesCache[itemID];
				if (baseName) then
					baseName = string.lower(baseName);
					if (string.find(name, baseName, 1, true)) then
						-- if the query string entirely contains the base name, search for observed variations that match
						local observedVariations = FLT_RandomItemCombos[FLT_Locale][itemID];
						if (observedVariations) then
							for propID, uniqueID in pairs(observedVariations) do
								local propName = FLT_RandomPropIDs[FLT_Locale][propID];
								if (propName) then
									--DevTools_Dump({baseName=baseName, propName=propName, itemID=itemID, propID=propID})
									local fullName = string.format(propName, baseName);
									if (fullName == name) then
										local fullLink = GFWUtils.BuildItemLink(itemID, nil, nil, nil, nil, nil, propID, uniqueID);
										-- see if the description matches the item type or equip location
										if (FLT_ItemLinkMatchesDescriptor(fullLink, description)) then
											local link = FLT_GetItemLink(fullLink);
											if (link) then 
												if (returnAll) then
													table.insert(allResults, link);
												else
													return link;
												end
											end
										end
										-- failing that, see if the description matches any text from the item tooltip
										if (FLT_FindInItemTooltip(description, fullLink)) then
											local link = FLT_GetItemLink(fullLink);
											if (link) then 
												if (returnAll) then
													table.insert(allResults, link);
												else
													return link;
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if (returnAll and table.getn(allResults) > 0) then
		return allResults;
	end
end

function FLT_ItemLinkMatchesDescriptor(itemLink, description)
	-- see if the description matches the item type or equip location
	local name, link, rarity, level, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(itemLink);
	if ((type and string.find(string.lower(type), description, 1, true)) 
	 or (subType and string.find(string.lower(subType), description, 1, true))
	 or (getglobal(equipLoc) and string.find(string.lower(getglobal(equipLoc)), description, 1, true))) then
		return true;
	end
end

------------------------------------------------------
-- Caching seen links
------------------------------------------------------

function FLT_ProcessLinks(text)
	local lastLink;
	if ( text ) then
		local link, name;
		for link, name in string.gmatch(text, "|c%x+|H(item:[-%d:]+)|h%[(.-)%]|h|r") do
			if (link and name and name ~= "") then
				lastLink = FLT_AddLink(name, link);
				if (lastLink) then 
					pcall(setHyperlink, LinkeratorTip, link); -- get our WoW client to cache it if possible
				end
			end
		end
		for link, name in string.gmatch(text, "|c%x+|H(enchant:%d+)|h%[(.-)%]|h|r") do
			if (link and name and name ~= "") then
			--	lastLink = FLT_AddLink(name, link);
			end
		end
	end
	return lastLink;
end

function FLT_AddLink(name, link)
	name = string.lower(name); -- so we can do case-insensitive lookups
	local itemID, enchant, gem1, gem2, gem3, gem4, randomProp, uniqueID;
	if (type(link) == "number") then
		itemID = link;
	elseif (type(link) == "string") then
		itemID, enchant, gem1, gem2, gem3, gem4, randomProp, uniqueID = GFWUtils.DecomposeItemLink(link);
		if (itemID == nil) then
			itemID = tonumber(link);
		end
	end
	--DevTools_Dump({name=name, link=link, itemID=itemID, randomProp=randomProp})
	if (itemID) then
		LinkeratorTip:SetHyperlink("item:"..itemID);	-- make sure client caches the (base) item
		if (randomProp == 0 or randomProp == nil) then
			return;	-- we don't need our own database for basic links; we can just rely on the WoW client
		else
			return FLT_AddRandomPropertyItemLink(name, link);
		end
	end

	-- if we got down to here, it's bad input
	GFWUtils.Print("Error: unparseable link passed to FLT_AddLink()");
	FLT_DebugLog("Name: "..GFWUtils.Hilite(name or "(nil)").." Link: "..GFWUtils.Hilite(link or "(nil)"));
	FLT_DebugLog(debugstack(2, 1, 0));
end

function FLT_AddRandomPropertyItemLink(name, link)
	local itemID, enchant, gem1, gem2, gem3, gem4, randomProp, uniqueID = GFWUtils.DecomposeItemLink(link);
	local cleanLink = GFWUtils.BuildItemLink(itemID, nil, nil, nil, nil, nil, randomProp, uniqueID);
	
	local baseName = GetItemInfo(itemID); -- the item name without the "of the Boar", etc suffix for random property
	if (baseName == nil) then return; end
	local lowerBase = string.lower(baseName);
	
	FLT_RandomItemIDs[itemID] = 1;
	
	local searchBase = string.gsub(lowerBase, "([%$%(%)%.%[%]%*%+%-%?%^%%])", "%%%1"); -- convert regex special characters
	local propertyName = string.gsub(name, searchBase, "%%s"); -- format string for just the suffix (or whatever alteration to the name) with token for inserting the base name
	local existingProp = FLT_RandomPropIDs[FLT_Locale][randomProp];
	if (existingProp == propertyName) then
		-- these aren't the droids you're looking for
	elseif (existingProp == nil) then
		FLT_RandomPropIDs[FLT_Locale][randomProp] = propertyName;
		FLT_DebugLog("Added "..GFWUtils.Hilite(propertyName).." ("..randomProp.."), new property name");
	else
		FLT_RandomPropIDs[FLT_Locale][randomProp] = propertyName;
		FLT_DebugLog(GFWUtils.Red("Duplicate: ").."replaced "..GFWUtils.Hilite(existingProp).." with "..GFWUtils.Hilite(propertyName).." ("..randomProp..")");
	end
	
	local verifiedLink = FLT_GetItemLink(cleanLink);
	if (verifiedLink) then
		if (FLT_RandomItemCombos[FLT_Locale][itemID] == nil) then
			FLT_RandomItemCombos[FLT_Locale][itemID] = {};
		end
		if (FLT_RandomItemCombos[FLT_Locale][itemID][randomProp] == nil) then			
			FLT_RandomItemCombos[FLT_Locale][itemID][randomProp] = uniqueID;
			FLT_DebugLog("Added "..verifiedLink.." ("..cleanLink..")");
		end
	else
		if (FLT_RandomItemCombos[FLT_Locale][itemID] and FLT_RandomItemCombos[FLT_Locale][itemID][randomProp]) then			
			FLT_RandomItemCombos[FLT_Locale][itemID][randomProp] = nil;
		end
		if (GFWTable.Count(FLT_RandomItemCombos[FLT_Locale][itemID]) == 0) then
			FLT_RandomItemCombos[FLT_Locale][itemID] = nil;
		end
	end
end

------------------------------------------------------
-- Finding links to cache
------------------------------------------------------

function FLT_InspectSlot(unit, id)
	local link = GetInventoryItemLink(unit, id);
	if ( link ) then
		FLT_ProcessLinks(link);
	end
end

function FLT_Inspect(who)
	local index;
	
	for index = 1, getn(INVENTORY_SLOT_LIST), 1 do
		FLT_InspectSlot(who, INVENTORY_SLOT_LIST[index].id)
	end
end

function FLT_ScanTradeSkill()
	if (not TradeSkillFrame or not TradeSkillFrame:IsVisible() or FLT_TradeSkillLock.Locked) then return; end
	-- This prevents further update events from being handled if we're already processing one.
	-- This is done to prevent the game from freezing under certain conditions.
	FLT_TradeSkillLock.Locked = true;

	local skillLineName, skillLineRank, skillLineMaxRank = GetTradeSkillLine();
	if not (skillLineName) then
		FLT_TradeSkillLock.NeedScan = true;
		return; -- apparently sometimes we're called too early, this is nil, and all hell breaks loose.
	end

	for id = 1, GetNumTradeSkills() do 
		local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(id);
		if ( skillType ~= "header" ) then				
			local recipeLink = GetTradeSkillRecipeLink(id);
			if (recipeLink == nil) then
				FLT_TradeSkillLock.NeedScan = true;
			else
				FLT_ProcessLinks(recipeLink);
			end
			local itemLink = GetTradeSkillItemLink(id);
			if (itemLink == nil) then
				FLT_TradeSkillLock.NeedScan = true;
			else
				FLT_ProcessLinks(itemLink);
				for i=1, GetTradeSkillNumReagents(id), 1 do
					local link = GetTradeSkillReagentItemLink(id, i);
					if (link == nil) then
						FLT_TradeSkillLock.NeedScan = true;
						break;
					else
						FLT_ProcessLinks(link);
					end
				end
			end
		end
	end

end

function FLT_ScanQuestgiver()
	local link;
	for i = 1, GetNumQuestItems() do
		link = GetQuestItemLink("required", i);
		if (link) then
			FLT_ProcessLinks(link);
		end
	end
	for i = 1, GetNumQuestChoices() do
		link = GetQuestItemLink("choice", i);
		if (link) then
			FLT_ProcessLinks(link);
		end
	end
	for i = 1, GetNumQuestRewards() do
		link = GetQuestItemLink("reward", i);
		if (link) then
			FLT_ProcessLinks(link);
		end
	end
end

function FLT_ScanInventory()
	local bagid, size, slotid, link;
	
	for bagid = 0, 4, 1 do
		size = GetContainerNumSlots(bagid);
		if( size ) then
			for slotid = size, 1, -1 do
				link = GetContainerItemLink(bagid, slotid);
				if( link ) then
					FLT_ProcessLinks(link);
				end
			end
		end
	end
end

function FLT_ScanAuction()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local auctionid, link;
	
	if( numBatchAuctions > 0 and AuctionFrameBrowse.page ~= FLT_AuctionLastPage) then
		FLT_AuctionLastPage = AuctionFrameBrowse.page;
		for auctionid = 1, numBatchAuctions do
			link = GetAuctionItemLink("list", auctionid);
			if( link ) then
				table.insert(FLT_AuctionLinks, link);
			end
		end
	end
end

function FLT_SortAuctionClearSort(...)
	FLT_AuctionLastPage = nil;
end

function FLT_SortAuctionSetSort(...)
	FLT_AuctionLastPage = nil;
end

function FLT_ScanBank()
	local index, bagid, size, slotid, link;
	local bagList = { BANK_CONTAINER };
	for i=NUM_BAG_SLOTS+1, (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
		table.insert(bagList, i);
	end
	
	for index, bagid in pairs(bagList) do
		size = GetContainerNumSlots(bagid);
		if( size ) then
			for slotid = size, 1, -1 do
				link = GetContainerItemLink(bagid, slotid);
				if( link ) then
					FLT_ProcessLinks(link);
				end
			end
		end
	end
end

function FLT_QuestLog_UpdateQuestDetails()
	for i = 1, GetNumQuestLogChoices() do
		link = GetQuestLogItemLink("choice", i);
		if (link) then
			FLT_ProcessLinks(link);
		end
	end
	for i = 1, GetNumQuestLogRewards() do
		link = GetQuestLogItemLink("reward", i);
		if (link) then
			FLT_ProcessLinks(link);
		end
	end
	FLT_Orig_QuestLog_UpdateQuestDetails();
end

------------------------------------------------------
-- utilities
------------------------------------------------------

function FLT_LinkifyName(head, text, tail)
	if (head ~= "|h" and tail ~= "|h") then -- only linkify things text that isn't linked already
		local link = FLT_GetLinkByName(text);
		if (link) then return link; end
	end
	return head.."["..text.."]"..tail;
end

function FLT_FindInItemTooltip(text, link)
	LinkeratorTip:ClearLines();
	LinkeratorTip:SetHyperlink(link);
	for lineNum = 1, LinkeratorTip:NumLines() do
		local leftText = getglobal("LinkeratorTipTextLeft"..lineNum):GetText();
		if (leftText and string.find(string.lower(leftText), text, 1, true)) then return true; end
		local rightText = getglobal("LinkeratorTipTextRight"..lineNum):GetText();
		if (rightText and string.find(string.lower(rightText), text, 1, true)) then return true; end
	end
	for lineNum = 1, LinkeratorTip:NumLines() do
		-- for some reason ClearLines alone isn't clearing the right-side text
		getglobal("LinkeratorTipTextLeft"..lineNum):SetText(nil);
		getglobal("LinkeratorTipTextRight"..lineNum):SetText(nil);
	end
end

function FLT_ParseChatMessage(text)
	return string.gsub(text, "(|?h?)%[(.-)%](|?h?)", FLT_LinkifyName);
end

function FLT_LinkPrefixMatches(text)
	text = string.lower(text) -- for case insensitive lookups
	
	FLT_ResetItemNamesCache();
	
	-- build list of known links prefixed with the search string
	local matches = {};
	for itemID = 1, FLT_MAX_ITEM_ID do
		if (not FLT_RandomItemIDs[itemID]) then
			local name = FLT_ItemNamesCache[itemID];
			if (name and string.sub(string.lower(name), 1, string.len(text)) == text) then
				table.insert(matches, name);
			end
		end
	end
	
	-- need to search random-property links too
	for itemID in pairs(FLT_RandomItemIDs) do
		if (type(itemID) == "number") then
			local baseName = FLT_ItemNamesCache[itemID];
			if (baseName) then
				baseName = string.lower(baseName);
				if (string.sub(text, 1, string.len(baseName)) == baseName) then
					local observedVariations = FLT_RandomItemCombos[FLT_Locale][itemID];
					if (observedVariations) then
						for propID, uniqueID in pairs(observedVariations) do
							local propName = FLT_RandomPropIDs[FLT_Locale][propID];
							if (propName) then
								--DevTools_Dump({baseName=baseName, propName=propName, itemID=itemID, propID=propID})
								local fullName = string.format(propName, baseName);
								if (string.sub(fullName, 1, string.len(text)) == text) then
									table.insert(matches, fullName);
								end
							end
						end
					end
				elseif (string.sub(baseName, 1, string.len(text)) == text) then
					table.insert(matches, baseName);
				end
			end
		end
	end
	table.sort(matches);
	return matches;
	
end

function FLT_CommonPrefixFromList(list, minLength)
	if (table.getn(list) == 1) then
		return list[1];
	elseif (table.getn(list) == 2) then
		return FLT_CommonPrefix(list[1], list[2]);
	elseif (table.getn(list) > 2) then
		local previousCommon;
		local lastCommon = FLT_CommonPrefix(list[1], list[2]);
		local i = 3;
		while (lastCommon) do
			previousCommon = lastCommon;
			lastCommon = FLT_CommonPrefix(previousCommon, list[i]);
			if (lastCommon and minLength and string.len(lastCommon) <= minLength) then
				break;
			end
			i = i + 1;
		end
		return previousCommon;
	end
end

function FLT_CommonPrefix(strA, strB)
	
	if (strA == nil or strB == nil) then return; end
	
    -- shorter string first
    if (string.len(strA) > string.len(strB)) then
        strA, strB = strB, strA;
    end
    
    for length = string.len(strA), 1, -1 do
        local subA = string.sub(strA, 1, length);
        local subB = string.sub(strB, 1, length);
        if (subA == subB) then
            return subA;
        end
    end    
end

-- substitute for GetItemInfo() for "enchant:0000" style links
function FLT_GetEnchantInfo(id)
	local name = GetSpellInfo(id);
	if (name) then
		LinkeratorTip:SetHyperlink("spell:"..id);
		local tooltipName = LinkeratorTipTextLeft1:GetText();
		if (name ~= tooltipName) then
			return tooltipName;
		end
	end
end

function FLT_EnchantLink(id)
	if (tonumber(id) == nil) then
		error("bad argument #1 to 'FLT_EnchantLink' (number expected, got "..type(id)..")", 2);
	end
    local name = FLT_GetEnchantInfo(id);
    if (name) then
	    local linkFormat = "|cffffd000|Henchant:%s|h[%s]|h|r";
        return string.format(linkFormat, id, name);
    else
        return nil;
    end 
end

function FLT_DebugLog(text)
	if (FLT_Debug) then
		GFWUtils.Print(text, GFW_DEBUG_COLOR.r, GFW_DEBUG_COLOR.g, GFW_DEBUG_COLOR.b);
	end
end

function FLT_ResetItemNamesCache()
	FLT_ItemNamesCache = {};
	setmetatable(FLT_ItemNamesCache, {__index = function(tbl,key) return (GetItemInfo(key)); end});
	FLT_ItemCacheFull = true;	
end

function FLT_ResetSpellNamesCache()
	FLT_SpellNamesCache = {};
	setmetatable(FLT_SpellNamesCache, {__index = function(tbl,key)
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(key);
		local link = GetSpellLink(key);
		if (name and link) then
			return name;
		end
	end});
	FLT_SpellCacheFull = true;	
end

			