local beql = beql
local L = AceLibrary("AceLocale-2.2"):new("beql")

function beql:InitTooltip()
	if beqlQ then
		self:HookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
		self:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
	end
	-- Init Tracker Tooltips
	
	QuestWatchFrame:SetScript("OnMouseDown", function() if not beql.db.char.saved.minimizedtracker then beql:TrackerClick() end end)
	QuestWatchFrame:SetScript("OnUpdate", function() 
		if not MouseIsOver(QuestWatchFrame) and beql.db.char.saved.tooltipset then
			ResetCursor()
			GameTooltip:FadeOut()
			beql.db.char.saved.tooltipset = false
		end	
		if MouseIsOver(QuestWatchFrame) then 
			beql:TrackerTooltip() 
		end 
	end)	
end

function beql:GameTooltip_OnTooltipSetUnit(this, ...)
	self.hooks[this].OnTooltipSetUnit(this, ...)
	if beql.db.profile.tooltipmob then
		local Color = {
			r = beql.db.profile.Color.ColorMobTooltip.r,
			g = beql.db.profile.Color.ColorMobTooltip.g,
			b = beql.db.profile.Color.ColorMobTooltip.b,
		}
		local queryString = GameTooltip:GetUnit()
		if queryString then
			if beqlQ:IsQuestMob(queryString) then
				beql:ScanTooltipItem(queryString, Color)
			end
		end
	end
end

function beql:GameTooltip_OnTooltipSetItem(this, ...)
	self.hooks[this].OnTooltipSetItem(this, ...)
	if beql.db.profile.tooltipitem then
		local Color = {
			r = beql.db.profile.Color.ColorItemTooltip.r,
			g = beql.db.profile.Color.ColorItemTooltip.g,
			b = beql.db.profile.Color.ColorItemTooltip.b,
		}
		local queryString = GameTooltip:GetItem()
		if queryString then	
			if beqlQ:IsQuestItem(queryString) then
				beql:ScanTooltipItem(queryString, Color)
			end
		end
	end
end

function beql:ScanTooltipItem(queryString, Color)
	if Color == nil then
		Color.r = 0.8
		Color.g = 0.8
		Color.b = 0.8
	end
	for questID, questTitle, questLevel, questTag, questGroup, questComplete, questNumObjectives, questZone in beqlQ:IterateQuests() do
		for objIndex = 1,questNumObjectives do 
			objDescription, objType, objPossessed, objNeeded, objComplete = beqlQ:GetQuestStatusById(questID,objIndex)
			if objDescription == queryString then 
				if questGroup > 0 then
					questPrefix = questLevel.."G"..questGroup
				else
					questPrefix = questLevel
				end
				if beql.db.profile.TooltipItemFade then
					Color.r = GetDifficultyColor(questLevel).r
					Color.g = GetDifficultyColor(questLevel).g
					Color.b = GetDifficultyColor(questLevel).b
				end
				GameTooltip:AddDoubleLine("["..questPrefix.."]"..questTitle,objPossessed.."/"..objNeeded,Color.r,Color.g,Color.b)
			end
		end
	end
	GameTooltip:Show()
end

function beql:TrackerClick()
		if QuestWatchFrame.ismoving then
			return
		end
		if (not beql.db.char.saved.CurrentHoveredQuest or beql.db.char.saved.CurrentHoveredQuest <= 0) then
			return
		end
		if arg1 == "LeftButton" and beql.db.profile.activetrackerleft then
			if not IsShiftKeyDown() and IsControlKeyDown()  then
				if ChatFrameEditBox:IsVisible() then
					beql:AddQuestStatusToChatFrame(beql.db.char.saved.CurrentHoveredQuest)
				end				
			else		
				SelectQuestLogEntry(beql.db.char.saved.CurrentHoveredQuest)
				if( not QuestLogFrame:IsVisible() ) then
					ShowUIPanel(QuestLogFrame)
				else
					QuestLog_Update()
					QuestLog_UpdateQuestDetails(1)
				end
				if beql.db.char.saved.minimized then 
					beql:Maximize() 
				end
			end
		elseif arg1 == "RightButton" and beql.db.profile.activetrackerright then
			if beql.db.char.saved.tooltipset then
				ResetCursor()
				GameTooltip:FadeOut()
				beql.db.char.saved.tooltipset = false		
			end
			RemoveQuestWatch(beql.db.char.saved.CurrentHoveredQuest)
			QuestLog_Update()		
			QuestWatch_Update()
		end	
end

function beql:TrackerTooltip()
		if not MouseIsOver(this) or (GetMouseFocus() ~= QuestWatchFrame) then
			return
		end
		local qid = 0
		local textline = 0
		local watchLine
		local x, y = GetCursorPosition()
		local s = QuestWatchFrame:GetEffectiveScale()
		x,y = x/s, y/s
	
		for i=1, MAX_QUESTWATCH_LINES, 1 do
			textline = textline + 1
			watchLine = getglobal("QuestWatchLine"..i)
			if ( watchLine:IsVisible() ) then
				local l, r, t, b = watchLine:GetLeft(), watchLine:GetRight(), watchLine:GetTop(), watchLine:GetBottom()
				if ( x <= r and x >= l and y <= t and y >= b ) then
					break;
				end
			end
		end
		if beql.db.char.TrackerQuests[textline] then
			ResetCursor()
			qid = beql.db.char.TrackerQuests[textline]
			local oldSelection = GetQuestLogSelection()
			SelectQuestLogEntry(qid)
			local _, questObjectives = GetQuestLogQuestText()
			SelectQuestLogEntry(oldSelection)
			beql.db.char.saved.CurrentHoveredQuest = qid
			local qTitle,qLvl,qTag,qRec,qStat,qObj,qZone,qID = beqlQ:GetQuest(qid)
			
			if beql.db.profile.activetracker then
				ShowInspectCursor()	
				GameTooltip:SetOwner(QuestWatchFrame, "ANCHOR_CURSOR")
				if beql.db.profile.TooltipTitleDiff then
					Color = GetDifficultyColor(qLvl)
				else
					Color = beql.db.profile.Color.TooltipQuestTitle
				end
				GameTooltip:AddLine(qTitle,Color.r,Color.g,Color.b)
				if beql.db.profile.activetrackerdesc then
					GameTooltip:AddLine(questObjectives,beql.db.profile.Color.TooltipDesc.r,beql.db.profile.Color.TooltipDesc.g,beql.db.profile.Color.TooltipDesc.b,1)		
				end
				if beql.db.profile.activetrackerparty then
					if GetNumPartyMembers() > 0 then
						for i=1, GetNumPartyMembers(), 1 do
							local name = UnitName("party"..i)
							if beqlQ:PartyMemberHasQuest(name,qTitle) then
								if beqlQ:PartyMemberHasQuixote(name) then
									GameTooltip:AddLine(name,beql.db.profile.Color.TooltipPartyQuixote.r,beql.db.profile.Color.TooltipPartyQuixote.g,beql.db.profile.Color.TooltipPartyQuixote.b)
									for description in beqlQ:IteratePartyQuestLeaderboard(name, qTitle) do
										local oPos, oNeed = beqlQ:GetPartyQuestStatus(name, qTitle, description)
										if beql.db.profile.TooltipObjFade then
											Color = beql:FadeColors(beql.db.profile.Color.TooltipPartyObj,beql.db.profile.Color.TooltipPartyObjComp,oPos,oNeed)
										else
											if oPos == oNeed then
												Color = beql.db.profile.Color.TooltipPartyObjComp
											else
												Color = beql.db.profile.Color.TooltipPartyObj
											end
										end
										GameTooltip:AddDoubleLine("  "..description, oPos.."/"..oNeed,Color.r,Color.g,Color.b)					
									end
								else
									GameTooltip:AddLine(name,beql.db.profile.Color.TooltipPartyNonQuixote.r, beql.db.profile.Color.TooltipPartyNonQuixote.g, beql.db.profile.Color.TooltipPartyNonQuixote.b)
								end
							end
						end
					end
				end
				GameTooltip:Show()
				beql.db.char.saved.tooltipset = true		
			end
		else
			if beql.db.char.saved.tooltipset then
				ResetCursor()
				GameTooltip:FadeOut()
				beql.db.char.saved.tooltipset = false
			end		
		end
end