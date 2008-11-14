local beql = beql
local L = AceLibrary("AceLocale-2.2"):new("beql")

function beql:InitQuestLog()

	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("Quixote_Quest_Complete")
    self:RegisterEvent("Quixote_Leaderboard_Update")
    
	self:Hook("QuestLog_OnShow", "Hooks_QuestLog_OnShow", true)	    
    self:Hook("QuestLogTitleButton_OnClick","Hooks_QuestLogTitleButton_OnClick", true)
    self:Hook("GetQuestLogTitle","Hooks_GetQuestLogTitle",true)
    self:Hook("QuestLogCollapseAllButton_OnClick","Hooks_QuestLogCollapseAllButton_OnClick", true)
    self:Hook("QuestLog_Update", "Hooks_QuestLog_Update", true)

	QuestLogTitleText:SetText(L["Bayi's Extended Quest Log"])


	beql.ConfigButton = CreateFrame("Button","ConfigButton", QuestLogFrame, "UIPanelButtonTemplate")
	beql.ConfigButton:SetWidth(15)
	beql.ConfigButton:SetHeight(19)
	beql.ConfigButton:SetText("O")
	beql.ConfigButton:Show()
	beql.ConfigButton:ClearAllPoints()
	beql.ConfigButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT",0,0)
	beql.ConfigButton:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(beql3.optionsFrames["main"])
	end)
	
	QuestLogFrame:SetScript("OnDragStart",function() QuestLogFrame:StartMoving() end)
	QuestLogFrame:SetScript("OnDragStop",function() QuestLogFrame:StopMovingOrSizing() beql:SavePosition() end)
	QuestLogFrame:SetAlpha(beql.db.profile.QuestLogAlpha)
	QuestLogFrame:SetScale(beql.db.profile.QuestLogScale)
	beql:SetQuestLogFontSize(beql.db.profile.QuestLogFontSize)
	
	if not beql.db.profile.simplequestlog then
		beql:ExtendedQuestLog()
	end
end

function beql:ExtendedQuestLog()
		
		-- Code from DoubleWide by Iriel
		-- {
		QuestLogFrame:SetAttribute("UIPanelLayout-width", 680)
		QuestLogFrame:SetWidth(718)
		QuestLogFrame:SetHeight(561)
		QuestLogDetailScrollFrame:ClearAllPoints()
		QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 34, 0)
		QuestLogDetailScrollFrame:SetHeight(410)
		QuestLogListScrollFrame:SetHeight(410)

		local oldQuestsDisplayed = QUESTS_DISPLAYED
		QUESTS_DISPLAYED = 27
		for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
			local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame,"QuestLogTitleButtonTemplate")
			button:SetID(i)
			button:Hide()
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", getglobal("QuestLogTitle" .. (i-1)), "BOTTOMLEFT", 0, 1)
		end

		local regions = { QuestLogFrame:GetRegions() }

		local xOffsets = { Left = 3; Middle = 259; Right = 515; }
		local yOffsets =  { Top = 0; Bot = -256; }

		local textures = {
			TopLeft = "Interface\\AddOns\\beql\\Images\\topleft",
			TopMiddle = "Interface\\AddOns\\beql\\Images\\topmid_on",
			TopRight = "Interface\\AddOns\\beql\\Images\\topright",

			BotLeft = "Interface\\AddOns\\beql\\Images\\botleft",
			BotMiddle = "Interface\\AddOns\\beql\\Images\\botmid_on",
			BotRight = "Interface\\AddOns\\beql\\Images\\botright",
		
		}

		local PATTERN = "^Interface\\QuestFrame\\UI%-QuestLog%-(([A-Z][a-z]+)([A-Z][a-z]+))$"
		for _, region in ipairs(regions) do
			if region:IsObjectType("Texture") then
				local texturefile = region:GetTexture()
				if texturefile == "Interface\\QuestFrame\\UI-QuestLog-BookIcon" then
					region:SetTexture("Interface\\Addons\\beql\\Images\\icon")
				end
				local which, yofs, xofs = texturefile:match(PATTERN)
				xofs = xofs and xOffsets[xofs]
				yofs = yofs and yOffsets[yofs]
				if xofs and yofs and textures[which] then
					region:ClearAllPoints()
					region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs)
					region:SetTexture(textures[which])
					region:SetWidth(256)
					region:SetHeight(256)
					textures[which] = nil
				end
			end
		end

		for name, path in pairs(textures) do
			local yofs, xofs = name:match("^([A-Z][a-z]+)([A-Z][a-z]+)$")
			xofs = xofs and xOffsets[xofs]
			yofs = yofs and yOffsets[yofs]
			if xofs and yofs then
				local region = QuestLogFrame:CreateTexture(nil, "ARTWORK")
				region:ClearAllPoints()
				region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs)
				region:SetWidth(256)
				region:SetHeight(256)
				region:SetTexture(path)
			end
		end
		-- }
		-- Code from DoubleWide by Iriel

		beql.MinimizeButton = CreateFrame("Button","MinimizeButton", QuestLogFrame, "UIPanelButtonTemplate")
		beql.MinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\minimize_up")
		beql.MinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\minimize_down")
		beql.MinimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		beql.MinimizeButton:SetWidth(24)
		beql.MinimizeButton:SetHeight(24)
		beql.MinimizeButton:Show()
		beql.MinimizeButton:ClearAllPoints()
		beql.MinimizeButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT", 0,5)
		beql.MinimizeButton:SetScript("OnClick", function() 
			if beql.db.char.saved.minimized then 
				beql:Maximize() 
			else 
				beql:Minimize() 
			end 
		end)
	
	beql.ConfigButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT",-22,0)
end


function beql:Minimize()
	beql.db.char.saved.minimized = true 
	if beql.db.profile.simplequestlog then
		return
	end
	beql.ConfigButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT",-19,0)	
	beql.MinimizeButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT", 3,5)		
	beql.MinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\restore_up")
	beql.MinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\restore_down")
	QuestLogDetailScrollFrame:Hide()
	QuestLogFrame:SetAttribute("UIPanelLayout-width", 390)
	QuestLogFrame:SetWidth(387)
	local regions = { QuestLogFrame:GetRegions() }	
	for _, region in ipairs(regions) do
		if region:IsObjectType("Texture") then
			local texturefile = region:GetTexture()
			if texturefile == "Interface\\AddOns\\beql\\Images\\topmid_on" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\topmid_off")
			end
			if texturefile == "Interface\\AddOns\\beql\\Images\\botmid_on" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\botmid_off")
			end			
			if texturefile == "Interface\\AddOns\\beql\\Images\\botright" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\botright_off")
			end	
			if texturefile == "Interface\\AddOns\\beql\\Images\\topright" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\topright_off")
			end				
		end
	end	
end




function beql:Maximize()
	beql.db.char.saved.minimized = false 
	if beql.db.profile.simplequestlog then
		return
	end	
	local numEntries, _ = GetNumQuestLogEntries()
	if ( numEntries == 0 ) then
		return	
	end
	beql.ConfigButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT",-22,0)	
	beql.MinimizeButton:SetPoint("RIGHT",QuestLogFrameCloseButton, "LEFT", 0,5)	
	beql.MinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\minimize_up")
	beql.MinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\minimize_down")
	QuestLogDetailScrollFrame:Show()
	QuestLogFrame:SetAttribute("UIPanelLayout-width", 680)
	QuestLogFrame:SetWidth(718)

	local regions = { QuestLogFrame:GetRegions() }		
	for _, region in ipairs(regions) do
		if region:IsObjectType("Texture") then
			local texturefile = region:GetTexture()
			if texturefile == "Interface\\AddOns\\beql\\Images\\topmid_off" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\topmid_on")
			end
			if texturefile == "Interface\\AddOns\\beql\\Images\\botmid_off" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\botmid_on")
			end			
			if texturefile == "Interface\\AddOns\\beql\\Images\\botright_off" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\botright")
			end	
			if texturefile == "Interface\\AddOns\\beql\\Images\\topright_off" then
				region:SetTexture("Interface\\AddOns\\beql\\Images\\topright")
			end				
		end
	end		
end

function beql:SavePosition()
	local Left = QuestLogFrame:GetLeft()
	local Top = QuestLogFrame:GetTop()
	if Left and Top then
		beql.db.char.saved.qlogposx = Left
		beql.db.char.saved.qlogposy = Top
	end
end

--
-- EVENTS --
--

function beql:QUEST_PROGRESS()
	if beql.db.profile.autocomplete then
		CompleteQuest()
	end
end

function beql:QUEST_COMPLETE()
	if beql.db.profile.autocomplete and GetNumQuestChoices() == 0 then
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	end	
end

function beql:Quixote_Quest_Complete(questname)
	if beql.db.profile.InfoOnQuestCompletion then
		UIErrorsFrame:AddMessage(questname.." "..L["Completed!"], 1.0, 0.8, 0.0, 1.0, UIERRORS_HOLD_TIME)
		if beql.db.profile.InfoSound and beql.db.profile.InfoSound ~= "" then 
			PlaySoundFile(beql.db.profile.InfoSound)
		end
	end
end

function beql:Quixote_Leaderboard_Update(questname, id, lid, description, numHad, numGot, numNeeded, type)
	if beql.db.profile.AnnounceQuest and GetNumPartyMembers() > 0 then
		local chatType = "PARTY"	
		local text = ""
		local objText = ""
		local qstatus
		if type == "item" or type == "monster" or type == "reputation" then
			objText = objText..": "..numGot.."/"..numNeeded
		end		
		text = description..objText
		SendChatMessage(text, chatType)
		_,_,_,_,qstatus = beqlQ:GetQuestByName(questname)
		if numGot == numNeeded and (qstatus == 1) then
			SendChatMessage(questname.." "..L["Completed!"], chatType)
		end		
	end
end

function beql:QUEST_LOG_UPDATE()
	if(beqlfu) then
	  local _,questEntries = GetNumQuestLogEntries()
	  beqlfu:SetText(questEntries.."/25")
	end
	-- Workaround for a quixote issue
	beqlQ:QUEST_LOG_UPDATE()
end

-- 
-- Hooks
--

function beql:Hooks_QuestLogTitleButton_OnClick(self, button)
	-- Add control click
	if beql.db.char.saved.minimized then
		beql:Maximize()
	end
	local questName = this:GetText()
	local questIndex = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)	
	
	if button == "LeftButton" then
		if not IsShiftKeyDown() and IsControlKeyDown()  then
			if ChatFrameEditBox:IsVisible() then
				beql:AddQuestStatusToChatFrame(questIndex)
			end			
		end
		if  IsShiftKeyDown()  then
				local questLogTitleText, isHeader, isCollapsed, firstTrackable, lastTrackable, numTracked, numUntracked
				lastTrackable = -1
				numTracked = 0
				numUntracked = 0
				local track = false
				if  this.isHeader  then
					for i=1, GetNumQuestLogEntries(), 1 do
						questLogTitleText, _, _, _, isHeader, isCollapsed = GetQuestLogTitle(i)
						if  questLogTitleText == questName  then
							track = true
							firstTrackable = i+1
						elseif ( track ) then
							if  not isHeader  then
								if IsQuestWatched(i)  then
									numTracked = numTracked+1
									RemoveQuestWatch(i)
								else
									numUntracked = numUntracked+1
									RemoveQuestWatch(i)
								end
							end
							if  isHeader and questLogTitleText ~= questName  then
								lastTrackable = i-1
								break
							end
						end
					end
					if  lastTrackable == -1  then
						lastTrackable = GetNumQuestLogEntries()
					end
					if  numUntracked == 0  then
						-- Untrack all
						for i=firstTrackable, lastTrackable, 1 do
							RemoveQuestWatch(i)
						end
						QuestWatch_Update()
					else
						-- Track all
						for i=firstTrackable, lastTrackable, 1 do
							AddQuestWatch(i)
							-- Set an error message if trying to show too many quests
							if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
								UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0)
								break
							end							
						end
						QuestWatch_Update()
					end
					QuestLog_Update()
				end
		end
	end	
	
	--
	-- Original QuestLogTitleButton_OnClick(button) (altered)
	--
	
	local questName = this:GetText()
	local questIndex = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
	if ( IsShiftKeyDown() ) then
		-- If header then return
		if ( this.isHeader ) then
			return
		end
		-- Otherwise try to track it or put it into chat
		if ( ChatFrameEditBox:IsVisible() ) then
			--ChatFrameEditBox:Insert(strsub(strtrim(this:GetText()),11))
			local questLink = GetQuestLink(questIndex);
			if ( questLink ) then
				ChatEdit_InsertLink(questLink);
			else
				ChatFrameEditBox:Insert(gsub(this:GetText(), " *(.*)", "%1"))
			end
		else
			-- Shift-click toggles quest-watch on this quest.
			if ( IsQuestWatched(questIndex) ) then
				RemoveQuestWatch(questIndex)
				QuestWatch_Update()
			else
				-- Set an error message if trying to show too many quests
				if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
					UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0)
					return
				end
				AddQuestWatch(questIndex)
				QuestLog_Update()
				QuestWatch_Update()
			end
		end
	end
	
	-- Quest History Love :)
	if (IsAltKeyDown() and QuestHistoryFrame) then -- questhistory
		if (button == "LeftButton") then
			QuestHistoryFrameSearchEditBox_OnEnterPressed_External(questName)
		end
	end	
	
	QuestLog_SetSelection(questIndex)
--	if IsAddOnLoaded("Lightheaded") then
--		LightHeaded:QuestLogTitleButton_OnClick(frame, button)
--	end
	QuestLog_Update()
end

function beql:Hooks_QuestLog_OnShow()
	securecall(self.hooks.QuestLog_OnShow)
	
	if beql.db.char.saved.qlogposx and beql.db.char.saved.qlogposy then
		QuestLogFrame:ClearAllPoints()
		QuestLogFrame:SetPoint("TOPLEFT","UIParent", "BOTTOMLEFT", beql.db.char.saved.qlogposx, beql.db.char.saved.qlogposy)
	end
		
	if beql.db.char.saved.minimized then
		beql:Minimize()
	end
	if beql.db.profile.alwaysminimize then
		beql:Minimize()
	end
	if beql.db.profile.alwaysmaximize then
		beql:Maximize()
	end
end

function beql:Hooks_GetQuestLogTitle(...)
	local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = self.hooks.GetQuestLogTitle(...)
	
	if beql.db.profile.showlevel and questLogTitleText and level and level > 0 and not isHeader and beql.AddTags then
		if  questTag == GROUP then
			if suggestedGroup > 0 then
				questLogTitleText = "["..  level .. "G" .. suggestedGroup .. "]" .. questLogTitleText
			else
				questLogTitleText = "["..  level .. "G] " .. questLogTitleText
			end
		elseif  questTag == ELITE  then
			questLogTitleText = "[" .. level .. "+] " .. questLogTitleText
		elseif  questTag == DUNGEON_DIFFICULTY2 then
			questLogTitleText = "[" .. level .. "H] " .. questLogTitleText
		elseif  questTag == RAID  then
			questLogTitleText = "[" .. level .. "R] " .. questLogTitleText
		elseif  questTag == PVP  then
			questLogTitleText = "[" .. level .. "P] " .. questLogTitleText
		elseif isDaily then
			questLogTitleText = "[" .. level .. "Y] " .. questLogTitleText
		elseif  questTag == LFG_TYPE_DUNGEON  then
			questLogTitleText = "[" .. level .. "D] " .. questLogTitleText
		else
			questLogTitleText = "[" .. level .. "] " .. questLogTitleText
		end
	end
	
	return questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily
end

function beql:Hooks_QuestLogCollapseAllButton_OnClick(this)
	self.hooks.QuestLogCollapseAllButton_OnClick(this)
	if beql.db.char.saved.minimized then
		beql:Minimize()
	else
		beql:Maximize()
	end
end

function beql:Hooks_QuestLog_Update()
	beql.AddTags = true
	securecall(self.hooks.QuestLog_Update)
	beql.AddTags = false
	local numEntries, numQuests = GetNumQuestLogEntries()
	if ( numEntries == 0 ) then
		beql:Minimize()	
	end
	if beql.db.char.saved.minimized then
		beql:Minimize()
	else
		beql:Maximize()
	end
end

function beql:SetQuestLogFontSize(size)
	if not size or size == 0 then size = 12 end
	local font, fontsize, fontflags, button, buttontag
	for i = 1, QUESTS_DISPLAYED do
			buttontag = getglobal("QuestLogTitle"..i.."Tag")
			font,fontsize,fontflags = buttontag:GetFont()
			buttontag:SetFont(font,size)

            button = getglobal("QuestLogTitle"..i.."NormalText");
			font,fontsize,fontflags = button:GetFont()
            button:SetFont(font,size) 
	end

	font,fontsize,fontflags = QuestLogDummyText:GetFont()
	QuestLogDummyText:SetFont(font,size + 6)
	

-- Questdiscrition short
	-- title
	font,fontsize,fontflags = QuestLogQuestTitle:GetFont()
	QuestLogQuestTitle:SetFont(font,size + 6)

	-- description
	font,fontsize,fontflags = QuestLogObjectivesText:GetFont()
	QuestLogObjectivesText:SetFont(font,size)

    -- objetives
	for i = 1, 10 do
        buttontag = getglobal("QuestLogObjective" .. i);
        font,fontsize,fontflags = buttontag:GetFont()
		buttontag:SetFont(font,size)
	end   
	
	-- need money
	font,fontsize,fontflags = QuestLogRequiredMoneyText:GetFont()
	QuestLogRequiredMoneyText:SetFont(font,size)
	
-- Questdiscrition long
	-- title
    font,fontsize,fontflags = QuestLogDescriptionTitle:GetFont()
	QuestLogDescriptionTitle:SetFont(font,size + 6)
	
	-- description
    font,fontsize,fontflags = QuestLogQuestDescription:GetFont()
	QuestLogQuestDescription:SetFont(font,size)
	
--  Questreward
	-- title
	font,fontsize,fontflags = QuestLogRewardTitleText:GetFont()
	QuestLogRewardTitleText:SetFont(font,size+6)
	
	-- items
    font,fontsize,fontflags = QuestLogItemChooseText:GetFont()
	QuestLogItemChooseText:SetFont(font,size)

    -- items
    font,fontsize,fontflags = QuestLogItemReceiveText:GetFont()
	QuestLogItemReceiveText:SetFont(font,size)

    -- spell 
    font,fontsize,fontflags = QuestLogSpellLearnText:GetFont()
	QuestLogSpellLearnText:SetFont(font,size)

    -- titles
    font,fontsize,fontflags = QuestLogPlayerTitleText:GetFont()
	QuestLogPlayerTitleText:SetFont(font,size)
 
end

--- EOF ---
