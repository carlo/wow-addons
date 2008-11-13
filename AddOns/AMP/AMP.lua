AMP_Missed_Auctions = { }
AMP_Missed_Tells = { }
AMP_Missed_Authors = { }

local Is_RECORDING = false
local Is_COMBAT = false
local Is_AFK = false
local Is_DND = false
local Is_BG = false
local Autoreplies = {}
local LCLICK, RCLICK, DCLICK = 1, 2, 3

-- Ignore strings are case insenstive
local Default_AMPConfig = {
	["Version"] = AMP_VERSION,
	["Ignore_Strings"] = {
		[1] = "<GA",
		[2] = "<GEM",
	 },
	["chk_Ignore"] = true,
	["autoreply_COMBAT"] = false,
	["rec_AFK"] = true,
	["rec_DND"] = true,
	["rec_AUCTION"] = true,
	["autoclear"] = true,
	["AMP_Frame"] = false,
	["AMP_Frame_Click"] = DCLICK,
	["AFK_Msg"] = "",
	["AFK_Msg_Persist"] = false,
}

AMPConfig = {}

function AMP_OnLoad()
	AMPFrame:RegisterEvent("VARIABLES_LOADED")
	AMPFrame:RegisterEvent("ZONE_CHANGED")
	AMPFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	AMPFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	AMPFrame:RegisterEvent("CHAT_MSG_WHISPER")
	AMPFrame:RegisterForDrag("LeftButton")
	DEFAULT_CHAT_FRAME:AddMessage(AMP_MENU .. AMP_LOADED, 1.0, 1.0, 0)
end

function AMP_OnDragStart()
	AMPFrame:StartMoving()
end

function AMP_OnDragStop()
	AMPFrame:StopMovingOrSizing()
end

function AMP_OnEvent(event)
	if event == "PLAYER_REGEN_ENABLED" then
		Is_COMBAT = false
	elseif event == "PLAYER_REGEN_DISABLED" then
		Is_COMBAT = true
	elseif event == "CHAT_MSG_SYSTEM" then
		if string.find(arg1, string.sub(MARKED_AFK_MESSAGE, 1, string.len(MARKED_AFK_MESSAGE) - 4), 1) then
			if AMPConfig.rec_AFK then
				AMP_Record()
			elseif Is_DND then
				AMP_Stop()
			end
			Is_AFK = true
			if Is_DND then
				Is_DND = false
			end
		elseif string.find(arg1, string.sub(MARKED_DND, 1, string.len(MARKED_DND) - 3), 1) then
			if AMPConfig.rec_DND then
				AMP_Record()
			elseif Is_AFK then
				AMP_Stop()
			end
			Is_DND = true
			if Is_AFK then
				Is_AFK = false
			end
		elseif arg1 == CLEARED_AFK then
			AMP_Stop()
			Is_AFK = false
		elseif arg1 == CLEARED_DND then
			AMP_Stop()
			Is_DND = false
		elseif string.find(arg1, "Your auction of .+ sold%.") then
			AMP_RecordAH(arg1)
		elseif string.find(arg1, "Your auction of .+ expired%.") then
			AMP_RecordAH(arg1)
		elseif string.find(arg1, "You have been outbid", 0, true) then
			AMP_RecordAH(arg1)
		elseif string.find(arg1, "You won an auction for ", 0, true) then
			AMP_RecordAH(arg1)
		end
	elseif event == "CHAT_MSG_WHISPER" then
		if AMPConfig.autoreply_COMBAT and Is_COMBAT then
			local Autoreplied = false
			for i = 1, #(Autoreplies) do
				if (Autoreplies[i] == arg2) then
					Autoreplied = true
					break
				end
			end
			if Autoreplied == false and UnitName("player") ~= arg2 then
				SendChatMessage(AMP_IN_COMBAT_AUTO_MSG, "WHISPER", GetDefaultLanguage("player"), arg2)
				table.insert(Autoreplies, arg2)
			end
		end
		if Is_RECORDING then
			if AMPConfig.chk_Ignore then
				if (AMP_Check_Ignore_Strings(arg1) == false) then
					AMP_RecordWhispers(arg1, arg2)
				end
			else
				AMP_RecordWhispers(arg1, arg2)
			end
		end
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		Is_BG = false
		local currentZoneName = GetZoneText()
		for i=1, #(AMP_BG) do
			if (currentZoneName == AMP_BG[i]) then
				Is_BG = true
				break
			end
		end
	elseif event == "VARIABLES_LOADED" then
		SlashCmdList["AMP"] = AMP_SlashHandler
		SLASH_AMP1 = "/answer"
		SLASH_AMP2 = "/amp"
		if AMPConfig == nil or AMPConfig.Version ~= Default_AMPConfig.Version then
			AMPConfig = Default_AMPConfig
		else
			if AMPConfig.AFK_Msg_Persist and AFK_Msg ~= "" then
				DEFAULT_AFK_MESSAGE = AMPConfig.AFK_Msg
			end
		end
	end
end

function AMP_RecordAH(x)
	if Is_RECORDING and AMPConfig.rec_AUCTION then
		table.insert(AMP_Missed_Auctions, x)
		AMP_Text:SetText(AMP_MISSED1 .. #(AMP_Missed_Auctions) .. AMP_MISSED3)
	else
		UIErrorsFrame:AddMessage(x, 1.0, 1.0, 0.0, 1.0, 10)
		PlaySound("AuctionWindowClose")
	end
	if IsAddOnLoaded("AMPFu") then
		AMPFu:Update()
	end
end

function AMP_RecordWhispers(x, y)
	table.insert(AMP_Missed_Tells, x)
	table.insert(AMP_Missed_Authors, y)
	AMP_Text:SetText(AMP_MISSED1 .. #(AMP_Missed_Tells) .. AMP_MISSED2)
	if IsAddOnLoaded("AMPFu") then
		AMPFu:Update()
	end
end

function AMP_ToggleAMPFrame()
	if AMPConfig.AMP_Frame then
		AMP_AMPFrame(false)
	else
		AMP_AMPFrame(true)
	end
end

function AMP_AMPFrame(x)
	AMPConfig.AMP_Frame = x
	if x then
		if Is_RECORDING then
			AMPFrame:Show()
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		AMPFrame:Hide()
		DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_Frame_OnClick()
	if AMPFrame.isMoving ~= true then
		if AMPConfig.AMP_Frame_Click == LCLICK and arg1 == "LeftButton" then
			AMP_Retell_Msgs()
		elseif AMPConfig.AMP_Frame_Click == RCLICK and arg1 == "RightButton" then
			AMP_Retell_Msgs()
		end
	end
end

function AMP_Frame_OnDoubleClick()
	if AMPFrame.isMoving ~= true and AMPConfig.AMP_Frame_Click == DCLICK then
		AMP_Retell_Msgs()
	end
end

function AMP_getMissedTells()
	return #(AMP_Missed_Tells)
end

function AMP_getMissedAuctions()
	return #(AMP_Missed_Auctions)
end

function AMP_Print_Ignore_Strings()
	local ignore_strings = #(AMPConfig.Ignore_Strings)
	if ignore_strings > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR .. "\n" .. AMP_IGNORE_STATUS .. ignore_strings, 1.0, 1.0, 0)
		for k,v in pairs(AMPConfig.Ignore_Strings) do
			DEFAULT_CHAT_FRAME:AddMessage(v, 1.0, 1.0, 0)
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR, 1.0, 1.0, 0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_NOIGNORES, 1.0, 1.0, 0)
	end
end

function AMP_Insert_Ignore_String(x)
	if string.len(x) > 0 and AMP_Check_Ignore_Strings_Exists(x) == false then
		table.insert(AMPConfig.Ignore_Strings, string.upper(x))
		DEFAULT_CHAT_FRAME:AddMessage(x .. AMP_IGNORE_ADDED, 1.0, 1.0, 0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(x .. AMP_IGNORE_PREEXISTS, 1.0, 1.0, 0)
	end
end

function AMP_Remove_Ignore_String(x)
	if string.len(x) > 0 then
		local index = AMP_Check_Ignore_Strings_Exists(x)
		if index then
			table.remove(AMPConfig.Ignore_Strings, index)
			DEFAULT_CHAT_FRAME:AddMessage(x .. AMP_IGNORE_REMOVED, 1.0, 1.0, 0)
		else
			DEFAULT_CHAT_FRAME:AddMessage(x .. AMP_IGNORE_NOTEXISTS, 1.0, 1.0, 0)
		end
	end
end

function AMP_Check_Ignore_Strings_Exists(x)
	for k,v in pairs(AMPConfig.Ignore_Strings) do
		if string.upper(x) == v then
			return k
		end
	end
	return false
end

function AMP_Check_Ignore_Strings(x)
	for k,v in pairs(AMPConfig.Ignore_Strings) do
		if string.find(string.upper(x), v) then
			return k
		end
	end
	return false
end

function AMP_Record()
	if Is_BG then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC .. AMP_BG_DISABLED .. GetZoneText(), 1.0, 1.0, 0)
	else
		Is_RECORDING = true
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC .. AMP_ON, 1.0, 1.0, 0)
		if AMPConfig.AMP_Frame then
			AMPFrame:Show()
		end
	end
end

function AMP_Stop()
	if Is_RECORDING then
		Is_RECORDING = false
		AMP_Retell_Msgs()
		Autoreplies = {}
		AMPFrame:Hide()
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC .. AMP_OFF, 1.0, 1.0, 0)
	end
end

function AMP_Clear()
	AMP_Missed_Tells = { }
	AMP_Missed_Auctions = { }
	AMP_Missed_Authors = { }
	AMP_Text:SetText("")
end

function AMP_Retell_Msgs()

	if #(AMP_Missed_Tells) > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR .. "\n" .. AMP_MISSED1 .. #(AMP_Missed_Tells) .. AMP_MISSED2, 1.0, 0.5, 1.0)
		for i=1,#(AMP_Missed_Tells) do
			DEFAULT_CHAT_FRAME:AddMessage("[|Hplayer:" .. AMP_Missed_Authors[i] .. "|h" .. AMP_Missed_Authors[i] .. "|h]: " .. AMP_Missed_Tells[i], 1.0, 0.5, 1.0)
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR, 1.0, 0.5, 1.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_NOTELLS, 1.0, 1.0, 0.0)
	end

	if #(AMP_Missed_Auctions) > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR .. "\n" .. AMP_MISSED1 .. #(AMP_Missed_Auctions) .. AMP_MISSED3, 1.0, 1.0, 0)
		for i=1,#(AMP_Missed_Auctions) do
			DEFAULT_CHAT_FRAME:AddMessage(AMP_Missed_Auctions[i], 1.0, 1.0, 0)
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_SEPARATOR, 1.0, 1.0, 0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_NOAUCTIONS, 1.0, 1.0, 0)
	end

	if AMPConfig.autoclear then
		AMP_Clear()
	end
end

function AMP_SlashHandler(msg)
	local words = {}
	for word in string.gmatch(msg, "%w+") do
		table.insert(words, word)
	end
	if #(words) == 0 then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_MSG_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AWAY_MSG_PERSIST_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AFK_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_DND_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AUCTION_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_COMBAT_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_PLAY_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_CLEAR_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AUTOCLEAR_HELP .. "\n\n", 1.0, 1.0, 0.0)
		DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_HELP, 1.0, 1.0, 0.0)
	else
		local cmd = string.lower(words[1])
		if cmd == "clear" then
			AMP_Clear()
		elseif cmd == "play" then
			AMP_Retell_Msgs()
		elseif cmd == "msg" then
			local afk_msg = ""
			if #(words) > 1 then
				for i=2,#(words) do
					afk_msg = afk_msg .. " " .. words[i]
				end
				if AMP_msg == "" then
					DEFAULT_CHAT_FRAME:AddMessage(AMP_AWAY_MSG .. DEFAULT_AFK_MESSAGE, 1.0, 1.0, 0.0)
				else
					AMPConfig.AFK_Msg = afk_msg
					DEFAULT_AFK_MESSAGE = AMPConfig.AFK_Msg
					DEFAULT_CHAT_FRAME:AddMessage(AMP_DEFAULT .. DEFAULT_AFK_MESSAGE, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "msgpersist" then
			if #(words) == 1 then
				AMP_AFKMsgPersist(AMPConfig.AFK_Msg_Persist)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_AFKMsgPersist(true)
				elseif param == "off" then
					AMP_AFKMsgPersist(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_AWAY_MSG_PERSIST_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "frame" then
			if #(words) == 1 then
				AMP_AMPFrame(AMPConfig.AMP_Frame)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_AMPFrame(true)
				elseif param == "off" then
					AMP_AMPFrame(false)
				elseif param == "right" then
					DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_STATUS .. AMP_RCLICK, 1.0, 1.0, 0.0)
					AMPConfig.AMP_Frame_Click = RCLICK
				elseif param == "left" then
					DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_STATUS .. AMP_LCLICK, 1.0, 1.0, 0.0)
					AMPConfig.AMP_Frame_Click = LCLICK
				elseif param == "double" then
					DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_STATUS .. AMP_DCLICK, 1.0, 1.0, 0.0)
					AMPConfig.AMP_Frame_Click = DCLICK
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_FRAME_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "afk" then
			if #(words) == 1 then
				AMP_RecAFK(AMPConfig.rec_AFK)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_RecAFK(true)
				elseif param == "off" then
					AMP_RecAFK(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AFK_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "dnd" then
			if #(words) == 1 then
				AMP_RecDND(AMPConfig.rec_DND)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_RecDND(true)
				elseif param == "off" then
					AMP_RecDND(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_DND_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "auction" then
			if #(words) == 1 then
				AMP_RecAuction(AMPConfig.rec_AUCTION)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_RecAuction(true)
				elseif param == "off" then
					AMP_RecAuction(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AUCTION_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "ignore" then
			if #(words) == 1 then
				AMP_ChkIgnore(AMPConfig.chk_Ignore)
			elseif string.lower(words[2]) == "on" then
				AMP_ChkIgnore(true)
			elseif string.lower(words[2]) == "off" then
				AMP_ChkIgnore(false)
			elseif #(words) == 3 then
				if string.lower(words[2]) == "add" then
					AMP_Insert_Ignore_String(words[3])
				elseif string.lower(words[2]) == "remove" then
					AMP_Remove_Ignore_String(words[3])
				end
			elseif string.lower(words[2]) == "list" then
				AMP_Print_Ignore_Strings()
			else
				DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_HELP, 1.0, 1.0, 0.0)
			end
		elseif cmd == "combat" then
			if #(words) == 1 then
				AMP_AutoReplyInCombat(AMPConfig.autoreply_COMBAT)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_AutoReplyInCombat(true)
				elseif param == "off" then
					AMP_AutoReplyInCombat(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_COMBAT_HELP, 1.0, 1.0, 0.0)
				end
			end
		elseif cmd == "autoclear" then
			if #(words) == 1 then
				AMP_AutoClear(AMPConfig.autoclear)
			else
				local param = string.lower(words[2])
				if param == "on" then
					AMP_AutoClear(true)
				elseif param == "off" then
					AMP_AutoClear(false)
				else
					DEFAULT_CHAT_FRAME:AddMessage(AMP_AUTOCLEAR_HELP, 1.0, 1.0, 0.0)
				end
			end
		end
	end	
end

function AMP_AFKMsgPersist(x)
	AMPConfig.AFK_Msg_Persist = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AWAY_MSG_PERSIST_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AWAY_MSG_PERSIST_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_ToggleAFKMsgPersist()
	AMP_AFKMsgPersist(not AMPConfig.AFK_Msg_Persist)
end

function AMP_AutoClear(x)
	AMPConfig.autoclear = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AUTOCLEAR_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_AUTOCLEAR_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_ToggleAutoClear()
	if (AMPConfig.autoclear) then
		AMP_AutoClear(false)
	else
		AMP_AutoClear(true)
	end
end

function AMP_ChkIgnore(x)
	AMPConfig.chk_Ignore = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_RecAuction(x)
	AMPConfig.rec_AUCTION = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AUCTION_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AUCTION_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_RecDND(x)
	AMPConfig.rec_DND = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_DND_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		if (Is_DND) then
			AMP_Stop()
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_DND_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_RecAFK(x)
	AMPConfig.rec_AFK = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AFK_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		if (Is_AFK) then
			AMP_Stop()
		end
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_AFK_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_AutoReplyInCombat(x)
	AMPConfig.autoreply_COMBAT = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_COMBAT_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
		AMPFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		AMPFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_REC_COMBAT_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
		AMPFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
		AMPFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		Is_COMBAT = false
	end
end

function AMP_ChkIgnore(x)
	AMPConfig.chk_Ignore = x
	if x then
		DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_STATUS .. AMP_ON, 1.0, 1.0, 0.0)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AMP_IGNORE_STATUS .. AMP_OFF, 1.0, 1.0, 0.0)
	end
end

function AMP_ToggleRecAFK()
	if AMPConfig.rec_AFK then
		AMP_RecAFK(false)
	else
		AMP_RecAFK(true)
	end
end

function AMP_ToggleRecDND()
	if (AMPConfig.rec_DND) then
		AMP_RecDND(false)
	else
		AMP_RecDND(true)
	end
end

function AMP_ToggleRecAUCTION()
	if (AMPConfig.rec_AUCTION) then
		AMP_RecAuction(false)
	else
		AMP_RecAuction(true)
	end
end

function AMP_ToggleAutoReplyInCombat()
	if (AMPConfig.autoreply_COMBAT) then
		AMP_AutoReplyInCombat(false)
	else
		AMP_AutoReplyInCombat(true)
	end
end

function AMP_ToggleChkIgnore()
	if (AMPConfig.chk_Ignore) then
		AMP_ChkIgnore(false)
	else
		AMP_ChkIgnore(true)
	end
end

function AMP_GetTooltipText()
	if (Is_BG) then
		return AMP_REC .. AMP_BG_DISABLED .. GetZoneText()
	elseif (Is_RECORDING) then
		return AMP_REC .. AMP_ON .. "\n" .. AMP_MISSED1 .. #(AMP_Missed_Tells) .. AMP_MISSED2 .. "\n" .. AMP_MISSED1 .. #(AMP_Missed_Auctions) .. AMP_MISSED3 .. "\n|cff00ff00" ..  AMP_HINT .. "|r"
	else
		return AMP_REC .. AMP_OFF
	end
end

function AMP_IsAFK()
	return Is_AFK
end

function AMP_IsDND()
	return Is_DND
end

function AMP_IsBG()
	return Is_BG
end