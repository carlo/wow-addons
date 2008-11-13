local beql = beql
local L = AceLibrary("AceLocale-2.2"):new("beql")

function beql:InitTracker()
	MAX_QUESTWATCH_LINES = 50
	MAX_WATCHABLE_QUESTS = 20
	for i = 31, 50 do
		local string = QuestWatchFrame:CreateFontString("QuestWatchLine" .. i,"BACKGROUND","QuestWatchFontTemplate")
		string:SetPoint("TOPLEFT", getglobal("QuestWatchLine" .. (i-1)), "BOTTOMLEFT")
	end
	
	self:Hook("QuestWatch_Update","Hooks_QuestWatch_Update", true)
	self:Hook("RemoveQuestWatch","Hooks_RemoveQuestWatch", true)
	self:Hook("IsQuestWatched", "Hooks_IsQuestWatched", true)
	self:Hook("GetNumQuestWatches", "Hooks_GetNumQuestWatches", true)
	self:Hook("AddQuestWatch", "Hooks_AddQuestWatch", true)
	self:Hook("GetQuestIndexForWatch", "Hooks_GetQuestIndexForWatch", true)
	self:Hook("UIParent_ManageFramePositions","Hooks_UIParent_ManageFramePositions", true)  

    --self:RegisterEvent("Quixote_Quest_Gained")
    self:RegisterEvent("Quixote_Ready")
    self:RegisterEvent("Quixote_Update")
    self:RegisterEvent("CHAT_MSG_SYSTEM")

	if beql.db.char.saved.qtrackercorner and beql.db.char.saved.qtrackerposx and beql.db.char.saved.qtrackerposy then
		QuestWatchFrame:ClearAllPoints()
		QuestWatchFrame:SetPoint(beql.db.char.saved.qtrackercorner,"UIParent","BOTTOMLEFT", beql.db.char.saved.qtrackerposx, beql.db.char.saved.qtrackerposy)
	else
		QuestWatchFrame:ClearAllPoints()
		QuestWatchFrame:SetPoint("TOPLEFT","UIParent","Center",0,0)
		beql:SavePositionTracker()
	end

	QuestWatchFrame:SetFrameStrata("BACKGROUND")
	QuestWatchFrame:SetMovable(true)
	QuestWatchFrame:EnableMouse(true)	
	QuestWatchFrame:SetScript("OnDragStart",function() if not beql.db.char.saved.minimizedtracker then QuestWatchFrame.ismoving = true QuestWatchFrame:StartMoving() end end)
	QuestWatchFrame:SetScript("OnDragStop",function() QuestWatchFrame.ismoving = false QuestWatchFrame:StopMovingOrSizing() beql:SavePositionTracker() end)	
	
	beql.TrackerBackdrop = CreateFrame("Frame","QuestWatchFrameBackdrop",QuestWatchFrame)
	beql.TrackerBackdrop:ClearAllPoints()
	if IsAddOnLoaded("Mobmap") then
		beql.TrackerBackdrop:SetPoint("TOPLEFT", QuestWatchFrame, "TOPLEFT",-20, 0)
		beql.TrackerBackdrop:SetPoint("BOTTOMLEFT", QuestWatchFrame, "BOTTOMLEFT",-20,-40)
	else
		beql.TrackerBackdrop:SetPoint("TOPLEFT", QuestWatchFrame ,"TOPLEFT", -8, 0)
		beql.TrackerBackdrop:SetPoint("BOTTOMLEFT",QuestWatchFrame, "BOTTOMLEFT",-8,-40)
	end
	beql.TrackerBackdrop:SetPoint("TOPRIGHT", QuestWatchFrame ,"TOPRIGHT", 0, 0)	
	beql.TrackerBackdrop:SetPoint("BOTTOMRIGHT",QuestWatchFrame, "BOTTOMRIGHT", 0,-40)	
	beql.TrackerBackdrop:SetFrameStrata("BACKGROUND")
	
	beql.TrackerBackdrop:SetBackdrop({
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16, tileSize = 16,
		insets = { left= 5, right = 5, top = 5, bottom = 5 }
		})
	beql.TrackerBackdrop:SetFrameLevel("1")
	beql.TrackerBackdrop:Show()	
	

	beql.TrackerTitleBar = CreateFrame("Frame","TrackerTitleBar", QuestWatchFrame)
	
	beql.TrackerTitleBar:ClearAllPoints()
	beql.TrackerTitleBar:SetHeight(32)
	if IsAddOnLoaded("Mobmap") then
		beql.TrackerTitleBar:SetPoint("TOPLEFT",QuestWatchFrame, "TOPLEFT",-20,25)
	else
		beql.TrackerTitleBar:SetPoint("TOPLEFT",QuestWatchFrame, "TOPLEFT",-8,25)
	end
	beql.TrackerTitleBar:SetPoint("TOPRIGHT",QuestWatchFrame, "TOPRIGHT",0,25)
	beql.TrackerTitleBar:SetBackdrop({
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16, tileSize = 16,
		insets = { left= 5, right = 5, top = 5, bottom = 5 }
		})			
	beql.TrackerTitleBar:SetFrameStrata("BACKGROUND")
	beql.TrackerTitleBar:SetFrameLevel("1")
	beql.TrackerTitleBar:SetAlpha(50)
	beql.TrackerTitleBar:SetMovable(true)
	beql.TrackerTitleBar:EnableMouse(true)
	beql.TrackerTitleBar:SetScript("OnDragStart",function() QuestWatchFrame:StartMoving() end)
	beql.TrackerTitleBar:SetScript("OnDragStop",function() QuestWatchFrame:StopMovingOrSizing() beql:SavePositionTracker() end)		
	beql.TrackerTitleBar:Show()
	
	beql.TrackerTitleBarText = beql.TrackerTitleBar:CreateFontString("TrackerTitleBarText","BACKGROUND","QuestWatchFontTemplate")
	beql.TrackerTitleBarText:SetPoint("LEFT",10,1)
	beql.TrackerTitleBarText:SetAlpha(1)

	beql.TrackerMinimizeButton = CreateFrame("Button","TrackerMinimizeButton", TrackerTitleBar, "UIPanelButtonTemplate")
	beql.TrackerMinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\minimize_up")
	beql.TrackerMinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\minimize_down")
	beql.TrackerMinimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	beql.TrackerMinimizeButton:SetWidth(18)
	beql.TrackerMinimizeButton:SetHeight(18)
	beql.TrackerMinimizeButton:Show()
	beql.TrackerMinimizeButton:ClearAllPoints()
	beql.TrackerMinimizeButton:SetPoint("TOPRIGHT",TrackerTitleBar, "TOPRIGHT", -4,2)
	beql.TrackerMinimizeButton:SetScript("OnClick", function() 
		if beql.db.char.saved.minimizedtracker then 
			beql:TrackerMaximize() 
		else 
			beql:TrackerMinimize() 
		end 
	end)
	
	QuestWatchFrame:SetAlpha(beql.db.profile.QuestTrackerAlpha)
	QuestWatch_Update()
end


function beql:SavePositionTracker()
	beql:TrackerLockCornerForGrowth()
end

function beql:TrackerMinimize()
	beql.db.char.saved.minimizedtracker = true
	beql.TrackerMinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\restore_up")
	beql.TrackerMinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\restore_down")	
	for i = 1, 50 do
		local CurFrame = getglobal("QuestWatchLine"..(i))
		CurFrame:Hide()
	end	
	local minWidth = beql.TrackerTitleBarText:GetWidth()+32
	QuestWatchFrame:SetHeight(32)
	QuestWatchFrame:SetWidth(minWidth)
	beql.TrackerBackdrop:Hide()
end

function beql:TrackerMaximize()
	beql.db.char.saved.minimizedtracker = false
	beql.TrackerMinimizeButton:SetNormalTexture("Interface\\AddOns\\beql\\Images\\minimize_up")
	beql.TrackerMinimizeButton:SetPushedTexture("Interface\\AddOns\\beql\\Images\\minimize_down")	
	for i = 1, 50 do
		local CurFrame = getglobal("QuestWatchLine"..(i))
		CurFrame:Show()
	end	
	beql.TrackerBackdrop:Show()
	QuestWatch_Update()
end

--
-- Events
--

function beql:Quixote_Ready()
	QuestWatch_Update()
	-- Check if enabled
	beql:HistoryScanLog()
end

function beql:Quixote_Update()
	QuestWatch_Update()
end

-- Removed due to a Quixote Bug
--[[
function beql:Quixote_Quest_Gained(questname,id)
	if beql.db.profile.AddNew then
		AddQuestWatch(id)
		QuestLog_Update()
		QuestWatch_Update()
	end
	QuestWatch_Update()
end
]]--

function beql:CHAT_MSG_SYSTEM(arg1)
	if beql.db.profile.AddNew then
		if string.find(arg1, BEQL_QUEST_ACCEPTED.." .+") then
			local temp = string.gsub(arg1, BEQL_QUEST_ACCEPTED.." ", "")
			beql.TrackerQueue = temp
			beql:ManageQuests()
		end
	end
end

--
-- Hooks
--

function beql:Hooks_AddQuestWatch(questIndex)
	
	local questName, level = GetQuestLogTitle(questIndex)
	local questLogHeader, tempId

	if IsQuestWatched(questIndex) then
		return
	else
		isHeader = false
		tempId = questIndex
		while (not isHeader) do
			questLogHeader, _, _, _, isHeader = GetQuestLogTitle(tempId)
			tempId = tempId-1
		end

		table.insert(beql.db.char.QuestWatches, questLogHeader..","..level..","..questName)
	end
	beql:SortWatchedQuests()
end

function beql:Hooks_RemoveQuestWatch(questIndex)
	if questIndex <= 0 then
		return
	end
	local questName, level = GetQuestLogTitle(questIndex)

	local questLogHeader, isHeader, tempId

	isHeader = false
	tempId = questIndex
	while (not isHeader) do
		questLogHeader, _, _, _, isHeader = GetQuestLogTitle(tempId)
		tempId = tempId-1
	end

	local temp = questLogHeader..","..level..","..questName

	if table.getn(beql.db.char.QuestWatches) > 0 then
		for i=1, table.getn(beql.db.char.QuestWatches) do
			if beql.db.char.QuestWatches[i] == temp then
				table.remove(beql.db.char.QuestWatches , i)
				break
			end
		end
	end
	beql:SortWatchedQuests()
end

function beql:Hooks_IsQuestWatched(questIndex)
	
	local questName, level = self.hooks.GetQuestLogTitle(questIndex)
	local questLogHeader, isHeader, tempId

	isHeader = false
	tempId = questIndex
	while (not isHeader and tempId > 0) do
		questLogHeader, _, _, _, isHeader = self.hooks.GetQuestLogTitle(tempId)
		tempId = tempId-1
	end
	

	local temp = questLogHeader..","..level..","..questName
	if table.getn(beql.db.char.QuestWatches) > 0 then
		for i=1, table.getn(beql.db.char.QuestWatches) do
			if beql.db.char.QuestWatches[i] == temp then
				return true
			end
		end
	end
	return false
end


-- Returns the number of watched quests
function beql:Hooks_GetNumQuestWatches()
	return table.getn(beql.db.char.QuestWatches)
end

function beql:Hooks_GetQuestIndexForWatch(id)
	local numEntries, numQuests = GetNumQuestLogEntries()
	local questLogTitleText, level
	local questLogHeader, isHeader, tempId
	local questFound = false
	local temp, currentHeader=nil

	for i=1, numEntries, 1 do
		questLogTitleText, level, _, _, isHeader, _ = GetQuestLogTitle(i)
		if isHeader then
			currentHeader = questLogTitleText
		else
			temp = currentHeader..","..level..","..questLogTitleText
			if  temp == beql.db.char.QuestWatches[id]  then
				return i
			end
		end
	end
	return 0
end

function beql:Hooks_UIParent_ManageFramePositions()
	self.hooks.UIParent_ManageFramePositions()
	if beql.db.char.saved.qtrackercorner and beql.db.char.saved.qtrackerposx and beql.db.char.saved.qtrackerposy then
		QuestWatchFrame:ClearAllPoints()
		QuestWatchFrame:SetPoint(beql.db.char.saved.qtrackercorner,"UIParent","BOTTOMLEFT", beql.db.char.saved.qtrackerposx, beql.db.char.saved.qtrackerposy)
	end	
end

function beql:Hooks_QuestWatch_Update()

	-- Dont do anything before Quixote gets his data
	if not beqlQ.firstScanDone then
		return
	end

	-- Is it realy needed ?
	beql:ManageQuests()

	local questIndex,isRemoved,isCollapsed
	local qTitle,qLvl,qTag,qRec,qStat,qObj,qZone,qID
	local oText, oType, oNumP, oNumN, oComp, numObjectives, objText
	local temp,curZone
	local watchTextID = 1
	local Color = {}
	local tempwidth = 0
	local tempColor,tempColor2,tempColor3
	local markerID = 0
	local completedQuests = 0
	local questWatchMaxWidth = 0	
	
	beql.db.char.TrackerQuests = {}
	
	for i=1, GetNumQuestWatches() do
		questIndex = GetQuestIndexForWatch(i)
		if questIndex then qTitle,qLvl,qTag,qRec,qStat,qObj,qZone,qID = beqlQ:GetQuestById(questIndex) end
		if qID then
			isRemoved = false
			
			if beql.db.profile.RemoveFinished and qStat == 1 then
				isRemoved = true
				completedQuests = completedQuests +1
			end					
			
			--
			-- Zone !
			--
			if (curZone == nil or curZone ~= qZone) and not isRemoved then
				curZone = qZone
				if beql.db.profile.ShowZonesInTracker then
					if beql.db.profile.CustomZoneColor then
						tempwidth = beql:AddWatchLineText(watchTextID,curZone,beql.db.profile.TrackerFontHeight,beql.db.profile.Color.Zone, beql.db.profile.TrackerFontHeight+2)
					else
						Color = {r = 0.8,g = 0.8,b = 1}
						tempwidth = beql:AddWatchLineText(watchTextID,curZone,beql.db.profile.TrackerFontHeight, Color, beql.db.profile.TrackerFontHeight+1)
					end
					if tempwidth > questWatchMaxWidth then questWatchMaxWidth = tempwidth end
					watchTextID = watchTextID + 1
				end
			end
				
			--
			-- Quest !
			--
			if questIndex > 0 and not isRemoved then
				if qStat == 1 then
					--Completed
					completedQuests = completedQuests +1
					if beql.db.profile.CustomHeaderColor then
						Color = beql.db.profile.Color.HeaderComplete
					else
						Color = NORMAL_FONT_COLOR
					end
				elseif qStat == -1 then
					if beql.db.profile.CustomHeaderColor then
						Color = beql.db.profile.Color.HeaderFailed
					else
						Color = NORMAL_FONT_COLOR
					end
				else
					-- Normal
					if beql.db.profile.CustomHeaderColor then
						if beql.db.profile.HeaderQuestLevelColor then
							Color = GetDifficultyColor(qLvl)
						else
							Color = beql.db.profile.Color.HeaderEmpty
						end
					else
						Color = { r = 0.75, g = 0.61, b = 0 }
					end
				end
				if beql.db.profile.showlevel then
					tempwidth = beql:AddWatchLineText(watchTextID,"  ".."["..qLvl..string.upper(qTag).."] "..qTitle,beql.db.profile.TrackerFontHeight, Color)
				else
					tempwidth = beql:AddWatchLineText(watchTextID,"  "..qTitle,beql.db.profile.TrackerFontHeight, Color)				
				end
				beql.db.char.TrackerQuests[watchTextID] = qID
				if tempwidth > questWatchMaxWidth then questWatchMaxWidth = tempwidth end
				watchTextID = watchTextID + 1
				
				--
				-- Objectives !
				--
				numObjectives = qObj
				if beql.db.profile.MinimizeFinished and qStat == 1 then
					numObjectives = 0
				end				
				if beql.db.profile.HideCompletedOnly and qStat == 1 then
					numObjectives = 0
				end
				markerID = 0
				if  numObjectives > 0 then

					for j=1, numObjectives do
						oText, oType, oNumP, oNumN, oComp = beqlQ:GetQuestStatusById(questIndex, j)
													
						if beql.db.profile.CustomObjetiveColor then
									tempColor = { r=beql.db.profile.Color.ObjectiveEmpty.r, g=beql.db.profile.Color.ObjectiveEmpty.g, b=beql.db.profile.Color.ObjectiveEmpty.b }
									tempColor2 = { r=beql.db.profile.Color.ObjectiveComplete.r, g=beql.db.profile.Color.ObjectiveComplete.g, b=beql.db.profile.Color.ObjectiveComplete.b }
						else
									tempColor = {r=0.8, g=0.8, b=0.8}
									tempColor2 = {r=HIGHLIGHT_FONT_COLOR.r, g=HIGHLIGHT_FONT_COLOR.g, b=HIGHLIGHT_FONT_COLOR.b}						
						end
						if oComp then
							Color = tempColor2
						else								
							if beql.db.profile.FadeColor then
								if oType == "reputation" then
									if oNumN == oNumP then
										Color = beql:FadeColors(tempColor, tempColor2, 1,1)
									else
										Color = beql:FadeColors(tempColor, tempColor2, 0,1)
									end
								else
									Color = beql:FadeColors(tempColor, tempColor2, oNumP,oNumN)
								end
							else
								Color = tempColor
							end
						end
						
						if  beql.db.profile.ShowObjectiveMarkers  then
							if beql.db.profile.UseTrackerListing then 
								objText = "   "..BEQL_TrackerLists[beql.db.profile.TrackerList][markerID]..") " 
							else
								objText = "   "..BEQL_TrackerSymbols[beql.db.profile.TrackerSymbol].." "
							end
						else
							if IsAddOnLoaded("Mobmap") then
								objText = " - "
							else
								objText = "   "
							end						
						end
											
						objText = objText..oText
						if oType == "item" or oType == "monster" or oType == "reputation" then
							objText = objText..": "..oNumP.."/"..oNumN
						end
						if (oComp and not beql.db.profile.MinimizeFinished) or (not oComp) then
							tempwidth = beql:AddWatchLineText(watchTextID,objText,beql.db.profile.TrackerFontHeight,Color)
							if tempwidth > questWatchMaxWidth then questWatchMaxWidth = tempwidth end
							watchTextID = watchTextID + 1
						end
						marekrID = markerID + 1
					end

				end
				
			end
		end
	end
	
	-- Show Tracker header if set, set quest count in tracker header
	if beql.db.profile.ShowTrackerHeader then
		t1, _, t2 = QuestWatchLine1:GetFont()
		beql.TrackerTitleBarText:SetFont(t1, beql.db.profile.TrackerFontHeight+2, t2)
		beql.TrackerTitleBarText:SetHeight(beql.db.profile.TrackerFontHeight+2)	
		beql.TrackerTitleBarText:Show()
		local questnums = GetNumQuestWatches()
		local _,questEntries = GetNumQuestLogEntries()
		if beql.db.profile.RemoveFinished then
			beql.TrackerTitleBarText:SetText(L["Quest Tracker"].. " ("..questnums - completedQuests.."/"..questEntries..")")		
		else
			beql.TrackerTitleBarText:SetText(L["Quest Tracker"].. " ("..questnums.."/"..questEntries..")")				
		end
		beql.TrackerMinimizeButton:Show()
		beql.TrackerTitleBar:Show()
	else
		beql.TrackerTitleBar:Hide()
		beql.TrackerMinimizeButton:Hide()
		if beql.db.char.saved.minimizedtracker then
			beql:TrackerMaximize()
		end		
	end

	-- Tracker Background handling
	if beql.db.profile.CustomBackgroundColor then
		beql.TrackerBackdrop:SetBackdropColor(beql.db.profile.Color.BackgroundColor.r,beql.db.profile.Color.BackgroundColor.g,beql.db.profile.Color.BackgroundColor.b,beql.db.profile.Color.BackgroundColor.a)
		beql.TrackerBackdrop:SetBackdropBorderColor(beql.db.profile.Color.BackgroundCornerColor.r,beql.db.profile.Color.BackgroundCornerColor.g,beql.db.profile.Color.BackgroundCornerColor.b,beql.db.profile.Color.BackgroundCornerColor.a)
		beql.TrackerTitleBar:SetBackdropColor(beql.db.profile.Color.BackgroundColor.r,beql.db.profile.Color.BackgroundColor.g,beql.db.profile.Color.BackgroundColor.b,beql.db.profile.Color.BackgroundColor.a)
		beql.TrackerTitleBar:SetBackdropBorderColor(beql.db.profile.Color.BackgroundCornerColor.r,beql.db.profile.Color.BackgroundCornerColor.g,beql.db.profile.Color.BackgroundCornerColor.b,beql.db.profile.Color.BackgroundCornerColor.a)		
		if beql.db.profile.BackgroundAlpha then
			beql.TrackerBackdrop:SetAlpha(50)
		else
			beql.TrackerBackdrop:SetAlpha(0)
			beql.TrackerTitleBar:SetBackdropColor(0,0,0,0)
			beql.TrackerTitleBar:SetBackdropBorderColor(0,0,0,0)				
		end
	else
		beql.TrackerBackdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		beql.TrackerBackdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		beql.TrackerTitleBar:SetBackdropBorderColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		beql.TrackerTitleBar:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)					
		if beql.db.profile.BackgroundAlpha then
			beql.TrackerBackdrop:SetAlpha(50)
		else
			beql.TrackerBackdrop:SetAlpha(0)								
			beql.TrackerTitleBar:SetBackdropColor(0,0,0,0)	
			beql.TrackerTitleBar:SetBackdropBorderColor(0,0,0,0)		
		end
	end		
		
	--Hide unused Watchlines
	for i=watchTextID, MAX_QUESTWATCH_LINES do
		getglobal("QuestWatchLine"..i):Hide()
	end

	--Hide the tracker if nothing is watched or Show it and resize it
	if ( watchTextID == 1 ) then
		--Set the tracker indicator
		QuestLogTrackTracking:SetVertexColor(1.0, 0, 0)
		QuestWatchFrame:Hide()
		return
	else
		-- Set the tracker indicator
		QuestLogTrackTracking:SetVertexColor(0, 1.0, 0)
		QuestWatchFrame:Show()
		QuestWatchFrame:SetHeight((watchTextID * beql.db.profile.TrackerFontHeight+1) + (watchTextID * 4) + 12)
		
		-- Auto-Resize the tracker to fit or set fixed width
		if not beql.db.profile.TrackerAutoResize then
			QuestWatchFrame:SetWidth(beql.db.profile.TrackerFixedWidth)
		else
			QuestWatchFrame:SetWidth(questWatchMaxWidth + 12)
			-- If the tracker is smaller than the minwidht, resize it
			local minWidth = beql.TrackerTitleBarText:GetWidth()+32
			local curWidth = QuestWatchFrame:GetWidth()
			if curWidth < minWidth then
				QuestWatchFrame:SetWidth(minWidth)
			end	
		end
	end


	--Position the Tracker
	UIParent_ManageFramePositions()
	--Lock Tracker Corner for resizing
	beql:TrackerLockCornerForGrowth()
		
	--Minimize the Tracker if its state is set to minimized
	if beql.db.char.saved.minimizedtracker then
		beql:TrackerMinimize()
	end

end

-- For adding Text to Watcher
function beql:AddWatchLineText(id,text,size,color,height)
	local curWidth, tempWidth
	--local linenr
	if size == nil then size = beql.db.profile.TrackerFontHeight end
	if color == nil then color = {r=1,g=1,b=1} end
	if height == nil then height = beql.db.profile.TrackerFontHeight end
	watchText = getglobal("QuestWatchLine"..id)
	if watchText ~= nil then
		t1, _, t2 = watchText:GetFont()
		watchText:SetWidth(0)
		watchText:SetHeight(0)
		watchText:SetText(text)
		watchText:SetNonSpaceWrap(true)
		watchText:SetFont(t1, size, t2)
		tempWidth = watchText:GetWidth()
		curWidth = watchText:GetStringWidth()
		if not beql.db.profile.TrackerAutoResize then
			if curWidth > beql.db.profile.TrackerFixedWidth then 
				-- Switching back to auto calculate so this is not needed
				--linenr = ceil(curWidth / beql.db.profile.TrackerFixedWidth)
				--watchText:SetHeight(height*linenr)
				watchText:SetWidth(beql.db.profile.TrackerFixedWidth)
			else
				watchText:SetHeight(height)
				watchText:SetWidth(curWidth)
			end
		else
			watchText:SetHeight(height)
			watchText:SetWidth(curWidth)
		end

		if ( id > 1 ) then
			watchText:SetPoint("TOPLEFT", "QuestWatchLine"..(id - 1), "BOTTOMLEFT", 0, -4)
		end
		watchText:SetTextColor(color.r, color.g, color.b)
		watchText:Show()	
	end
	return tempWidth
end


function beql:TrackerLockCornerForGrowth()
	local Left = QuestWatchFrame:GetLeft()
	local Right = QuestWatchFrame:GetRight()
	local Top = QuestWatchFrame:GetTop()
	local Bottom = QuestWatchFrame:GetBottom()
	local lock
	local pointone
	local pointtwo
	local TOPBOTTOM_MEDIAN = 384
	local LEFTRIGHT_MEDIAN = 512
	if Left and Right and Top and Bottom then
		if Bottom < TOPBOTTOM_MEDIAN and Top > TOPBOTTOM_MEDIAN then
			local topcross = Top - TOPBOTTOM_MEDIAN
			local bottomcross = TOPBOTTOM_MEDIAN - Bottom
			if bottomcross > topcross then
				lock = "BOTTOM"
				pointtwo = Bottom
			else
				lock = "TOP"
				pointtwo = Top
			end
		elseif Top > TOPBOTTOM_MEDIAN then
			lock = "TOP"
			pointtwo = Top
		elseif Bottom < TOPBOTTOM_MEDIAN then
			lock = "BOTTOM"
			pointtwo = Bottom
		end
		if Left < LEFTRIGHT_MEDIAN and Right > LEFTRIGHT_MEDIAN then
			local leftcross = LEFTRIGHT_MEDIAN - Left
			local rightcross = Right - LEFTRIGHT_MEDIAN
			if rightcross > leftcross then
				lock = lock.."RIGHT"
				pointone = Right
			else
				lock = lock.."LEFT"
				pointone = Left
			end
		elseif Left < LEFTRIGHT_MEDIAN then
			lock = lock.."LEFT"
			pointone = Left
		elseif Right > LEFTRIGHT_MEDIAN then
			lock = lock.."RIGHT"
			pointone = Right
		end
		if lock and lock ~= "" and pointone and pointtwo then
			QuestWatchFrame:ClearAllPoints()
			QuestWatchFrame:SetPoint(lock,"UIParent","BOTTOMLEFT",pointone,pointtwo)
			beql.db.char.saved.qtrackercorner = lock
			beql.db.char.saved.qtrackerposx = pointone
			beql.db.char.saved.qtrackerposy = pointtwo
		elseif beql.db.char.saved.qtrackercorner and beql.db.char.saved.qtrackerposx and beql.db.char.saved.qtrackerposy then
			QuestWatchFrame:ClearAllPoints()
			QuestWatchFrame:SetPoint(beql.db.char.saved.qtrackercorner,"UIParent","BOTTOMLEFT",beql.db.char.saved.qtrackerposx,beql.db.char.saved.qtrackerposy)
		end
	end
end