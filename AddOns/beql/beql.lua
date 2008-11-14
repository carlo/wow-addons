
beql = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1", "AceDB-2.0", "AceConsole-2.0")
beqlQ = AceLibrary("Quixote-1.0")
local L = AceLibrary("AceLocale-2.2"):new("beql")
--local beqldewdrop = AceLibrary("Dewdrop-2.0")
--beqlwaterfall = AceLibrary("Waterfall-1.0")
local beql, self = beql, beql
local beqlfu = beqlfu
local VERSION = GetAddOnMetadata("beql", "Version")
beql.revision = VERSION
beql.versionstring = VERSION


-- Debug Function
-- #NODOC
function beql:Print(text)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(text))
end

-- Internal for Locale Changing
-- #NODOC
function beql:Nyelv(l,realy)
	if not realy then 
		StaticPopup_Show("CONFIRM_RELOADUI")
		beql.newlang = l
	else
		l = beql.newlang
		if not l or l == "" then
			beql.db.profile.locale = ""
			ReloadUI()
		else
			beql.db.profile.locale = l
			L:SetLocale(l)
			ReloadUI()
		end
	end
end


function beql:Disabletracker(value ,realy)
    if not beql.db.profile.disabledtracker then
        if not realy then 
		    StaticPopup_Show("CONFIRM_DISABLETRACKER")
		    beql.disabletracker = value
	    else
			beql.db.profile.disabledtracker = beql.disabletracker
            ReloadUI()
	    end
	else
	   beql.db.profile.disabledtracker = value
	   beql:InitTracker();
       beql:setmovabletracker(beql.db.profile.lockedtracker);
    end
end

function beql:Disableaddon(value ,realy)
    if beql:IsActive() then
        if not realy then 
		    StaticPopup_Show("CONFIRM_DISABLEADDON")
	    else
			beql:ToggleActive()
            ReloadUI()
	    end
	else
        beql:ToggleActive()
    end
end

function beql:DisableQuestLog(value ,realy)
    if not beql.db.profile.simplequestlog then
        if not realy then 
		    StaticPopup_Show("CONFIRM_SIMPLEQUESTLOG")
		    beql.simplequestlog = value
	    else
			beql.db.profile.simplequestlog = beql.simplequestlog
            ReloadUI()
	    end
	else
	   beql.db.profile.simplequestlog = value
	   beql:ExtendedQuestLog()
	   QuestLog_Update();
    end
end
-- Addon functions

function beql:OnInitialize()
	beql:RegisterDB("beqlDB","beqlDBPC")
	LibStub("AceDB-2.0"):GetAceOptionsDataTable(beql)
	if beql.db.profile.locale and L:HasLocale(beql.db.profile.locale) then
		L:SetLocale(beql.db.profile.locale)
		if BEQL_PostTransFunc[beql.db.profile.locale] then
			BEQL_PostTransFunc[beql.db.profile.locale]()
		end
	end
	beql:SetupDefaults()
	beql:BlizzardSetupOptions()
	beql:RegisterChatCommand({"/beql"}, function() InterfaceOptionsFrame_OpenToCategory(beql3.optionsFrames["main"]) end)


end


function beql:OnEnable()
    if Expo then self.debugFrame = Expo:ReturnDebugFrame() end
	-- Check for other addons
    beql:Compatibility()
	-- Init Questlog
	beql:InitQuestLog()
	-- Load Questtracker if used
	if not beql.db.profile.disabled.tracker and not beql.db.profile.disabledtracker then
		beql:InitTracker()
	end
	-- init Tooltip
	beql:InitTooltip()
	beql:setmovable(beql.db.profile.locked)
	beql:setmovabletracker(beql.db.profile.lockedtracker)
	
	-- Achievements
	if beql.db.profile.atracker.savelast and beql.db.char.AchievementTracker.Achievement >= 1 then
		-- this is needed, because it will not effect before entering world
		beql:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	beql:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");

	if beql.db.profile.atracker.Enable then
		beql:InitAchievementTracker()
		beql:ATrackerEnable()
	end
end

function beql:OnDisable()
	QUESTS_DISPLAYED = 6
	beql:UnhookAll()
--	ReloadUI()
end

-- Internal for Compatiblity with other addons
-- #NODOC
function beql:Compatibility()
	if IsAddOnLoaded("CT_Core") then
		-- CT_Core fix
		beql.db.profile.disabled.lockedtracker = true
		beql.db.profile.lockedtracker = true
		optionsmain.args.qtracker.args.LockedTracker.desc = optionsmain.args.qtracker.args.LockedTracker.desc.." "..L[" |cffff0000Disabled by|r"].." |cffe0c000CT_Core|r"
		
		optionsmain.args.qtracker.args.ForceUnlockTracker = {
					type = 'toggle',
					order = 1,
					width = 'full',
					name = L["Force Tracker Unlock"],
					desc = L["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"],
					get = function(info) return beql.db.profile.forcemove end,
					set = function(info, newval)
						self.db.profile.forcemove = newval
						if not self.db.profile.disabled.tracker and not self.db.profile.disabledtracker then
							if not self.db.profile.forcemove then
								QuestWatchFrame:RegisterForDrag(0)
								beql.TrackerTitleBar:RegisterForDrag(0)
							else
								QuestWatchFrame:RegisterForDrag("LeftButton")
								beql.TrackerTitleBar:RegisterForDrag("LeftButton")
							end			
						end
					end,
		}
		
		-- leaving there for old users
		beql.db.profile.disabled.showlevel = false
	else
		beql.db.profile.disabled.showlevel = false
		beql.db.profile.disabled.lockedtracker = false
	end
	
	if IsAddOnLoaded("Mobmap") then
		beql.db.profile.disabled.markers = true
		optionsmain.args.qtracker.args.MarkerOptions.desc = optionsmain.args.qtracker.args.MarkerOptions.desc.." "..L[" |cffff0000Disabled by|r"].." |cffe0c000Mobmap|r"
		optionsmain.args.qtracker.args.MarkerOptions.args.ShowObjectiveMarkers.desc = optionsmain.args.qtracker.args.MarkerOptions.args.ShowObjectiveMarkers.desc.." "..L[" |cffff0000Disabled by|r"].." |cffe0c000Mobmap|r"
		if beql.db.profile.ShowObjectiveMarkers then
			beql.db.profile.ShowObjectiveMarkers = false
		end
	else
		beql.db.profile.disabled.markers = false
	end
	
		beql.db.profile.disabled.tracker = false
	
	if (QuestLogFrame_MidTextures) ~= nil then
		optionsmain.args.qlogoption.args.SimpleQuestLog.desc = optionsmain.args.qlogoption.args.SimpleQuestLog.desc.." "..L[" |cffff0000Disabled by|r"].." |cffe0c000FramesResized|r"
		beql.db.profile.disabled.simplequestlog = true
		beql.db.profile.simplequestlog = true
	else
		beql.db.profile.disabled.simplequestlog = false
	end
end

-- Internal for setting default values for the variables
-- #NODOC
function beql:SetupDefaults()
	
	beql:RegisterDefaults("char", {
		QuestDB = {},
		QuestWatches = {},	
		saved = {},
		TrackerQuests = {},
		AchievementTracker = {
			Achievement = 0,
			minimized = false,
			posy = 0,
			posx = 0,

		},
	})
	
	beql:RegisterDefaults("profile", {
		disabled = {},
		Color = 
		{
			BackgroundColor = {
				r = TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
				g = TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
				b = TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
			},
			BackgroundCornerColor = {
				r = TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
				g = TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
				b = TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,			
			},
			Zone = {
				r = 1,
				g = 1,
				b = 1,
			},
			HeaderComplete = {
				r = NORMAL_FONT_COLOR.r,
				g = NORMAL_FONT_COLOR.g,
				b = NORMAL_FONT_COLOR.b,
			},
			HeaderEmpty = {
				r = 0.75,
				g = 0.61,
				b = 0,
			},
			HeaderFailed = {
				r = 1,
				g = 0,
				b = 0,
			},
			ObjectiveEmpty = {
				r = 0.8,
				g = 0.8,
				b = 0.8,
			},
			ObjectiveComplete = {
				r = HIGHLIGHT_FONT_COLOR.r,
				g = HIGHLIGHT_FONT_COLOR.g,
				b = HIGHLIGHT_FONT_COLOR.b,
			},
			TooltipQuestTitle = {
				r = 0.75,
				g = 0.61,
				b = 0,
			},
			TooltipDesc = {
				r = 1.0,
				g = 0.8,
				b = 0,	
			},
			TooltipPartyQuixote = {
				r = 0.4,
				g = 0.4,
				b = 1,
			},
			TooltipPartyNonQuixote = {
				r = 1,
				g = 0.4,
				b = 0.4,
			},
			TooltipPartyObj = {
				r = 0.8,
				g = 0.8,
				b = 0.8,
			},
			TooltipPartyObjComp = {
				r = HIGHLIGHT_FONT_COLOR.r,
				g = HIGHLIGHT_FONT_COLOR.g,
				b = HIGHLIGHT_FONT_COLOR.b,
			},
			ColorMobTooltip = {
				r = 0.8,
				g = 0.8,
				b = 0.8,
			},
			ColorItemTooltip = {
				r = 0.8,
				g = 0.8,
				b = 0.8,
			},
		},
		
-- QuestLog
		locked = true,
		alwaysminimize = false,
		alwaysmaximize = false,
		showlevel = true,
		InfoOnQuestCompletion = false,
		autocomplete = false,
		simplequestlog = false,
		QuestLogAlpha = 1,
		QuestLogScale = 1,
		forcemove = false,
		
-- QuestTracker
		lockedtracker = false,
		disabledtracker = false,
		ShowTrackerHeader = false,
		TrackerFontHeight = 12,
		CustomBackgroundColor = false,
		BackgroundAlpha = false,		
		ShowZonesInTracker = false,
		CustomZoneColor = false,
		CustomObjetiveColor = false,
		RemoveFinished = true,
		MinimizeFinished = false,
		HideCompletedOnly = false,
		CustomHeaderColor = false,
		HeaderQuestLevelColor = false,
		ShowObjectiveMarkers = true,
		UseTrackerListing = false,
		TrackerList = 0,
		TrackerSymbol = 0,
		SortTrackerItems = true,
		AddNew = true,
		AddUntracked = true,
		FadeColor = false,
		QuestTrackerAlpha = 1,
		TrackerAutoResize = true,
		TrackerFixedWidth = 250,
		
-- Tooltip
		tooltipmob = true,
		tooltipitem = true,
		activetracker = true,
		activetrackerdesc = true,		
		activetrackerleft = false,
		activetrackerright = false,
		activetrackerparty = false,
		AnnounceQuest = false,
		InfoSound = "Sound\\Interface\\GnomeExploration.wav",
		QuestLogFontSize = 12,
		TooltipTitleDiff = true,
		TooltipObjFade = true,
		TooltipItemFade = true,

-- Fubar

-- Achievementtracker
		atracker = {
			savelast	= true,
			Enable	= true,
			Locked	= true,
			headline	= true,
			alpha		= 1,
			scale 	= 0.9,
			RemoveFinished 	= true,
			showbg		= false,
			ownbgcolor	= false,
			BgColor 	= {
				r	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
				g	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
				b	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
			},
			BgCornerColor 	= {
				r	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
				g	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
				b	= TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,			
			},
		},

	})		
	
end

--------------------------------------------
-- Arguments:
-- number - quest id
-- string - quest name
--
-- Notes:
-- Prints the Quest Name/Status and Objectives to the currently opened chatbox
--
-- Returns:
-- * nothing
--------------------------------------------
function beql:AddQuestStatusToChatFrame(questIndex)
	local chatFrame = DEFAULT_CHAT_FRAME
    local chatType = chatFrame.editBox:GetAttribute("chatType")
    local oText, oType, oNumP, oNumN, oComp
    local text
    if chatType == "WHISPER" then
		chatType = "SAY"
	end
	local qTitle,qLvl,qTag,qRec,qStat,qObj,qZone,qID = beqlQ:GetQuestById(questIndex)
	if qObj and qObj > 0 then
		SendChatMessage("["..qLvl..string.upper(qTag).."] "..qTitle, chatType)
		for i=1, qObj do
			text = ""
			oText, oType, oNumP, oNumN, oComp = beqlQ:GetQuestStatusById(questIndex, i)
			text = oText
			if finished then
				text = text.." "..L["(Done)"]
			else
				text = text..": "..oNumP.."/"..oNumN
			end
			if text and strlen(text) > 0 then
				SendChatMessage(" - "..text, chatType)
			end
		end
	else
		chatFrame:AddMessage(L["No Objectives!"])
	end
	chatFrame.editBox:Hide()
end

--------------------------------------------
-- Notes:
-- Sorts the Tracked quests
--
-- Returns:
-- * nothing
--------------------------------------------
function beql:SortWatchedQuests()
	if beql.db.profile.ShowZonesInTracker and beql.db.profile.SortTrackerItems then
		table.sort(beql.db.char.QuestWatches)
	else
		if beql.db.profile.SortTrackerItems then
			table.sort(beql.db.char.QuestWatches, SortCompare)
		end
	end
end

function SortCompare(first, second)
	local temp = string.gsub(first, ".+,%d+,[%[%d+%+*%]]*", "")
	local temp2 = string.gsub(second, ".+,%d+,[%[%d+%+*%]]*", "")
	if temp < temp2  then
		return true
	end
	return false
end

--------------------------------------------
-- Notes:
-- Manage Tracked Quest list
--
-- Returns:
-- * nothing
--------------------------------------------
function beql:ManageQuests()
	local tempHeaderList = {}
	local tempQuestList = {}
	local numEntries = GetNumQuestLogEntries()
	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete
	local currentHeader = nil
	local temp, _
	
	local oldTitle
	
	if numEntries ~= 0 then
		for j=numEntries, 1, -1 do
			questLogTitleText, _, _, _, isHeader, isCollapsed = GetQuestLogTitle(j)
			if (isHeader and isCollapsed) then
				tempHeaderList[j] = 1
				ExpandQuestHeader(j)
			end
		end
	
		numEntries = GetNumQuestLogEntries()
	
		for j=1, numEntries, 1 do
			questLogTitleText, level, questTag, _, isHeader, isCollapsed, isComplete = GetQuestLogTitle(j)
			oldTitle = self.hooks.GetQuestLogTitle(j)
			if isHeader then
				currentHeader = questLogTitleText
			else
				temp = currentHeader..","..level..","..questLogTitleText
				table.insert(tempQuestList, temp)
				if beql.TrackerQueue and beql.TrackerQueue == oldTitle then
					table.insert(beql.db.char.QuestWatches, temp)
					beql.TrackerQueue = nil
				end
			end
		end	
	
		for j=1, numEntries, 1 do
			if(tempHeaderList[j] == 1) then
				CollapseQuestHeader(j)
			end
		end
	
	
		local numWatches = table.getn(beql.db.char.QuestWatches)
		local numEntries = table.getn(tempQuestList)
		local found = false
		for i=numWatches, 1, -1 do
			found = false
			for j=0, numEntries, 1 do
				if beql.db.char.QuestWatches[i] == tempQuestList[j] then
					found = true
					break
				end
			end
			if not found then
				table.remove(beql.db.char.QuestWatches, i)
			end
		end	
	end
	beql:SortWatchedQuests()
end

--------------------------------------------
-- Arguments:
-- table - Color1
-- table - Color2
-- number - Have
-- number - Needed
--
-- Notes:
-- Fades Colors between Color1 and Color2 depending on how much percent has Have from Needed
--
-- Returns:
-- * table - Color Faded
--------------------------------------------
function beql:FadeColors(tempColor, tempColor2, done, obj)
	local color = {r=0, g=0, b=0}
	local multiplier

	multiplier = (done / obj)
	color.r = tempColor.r + ((tempColor2.r - tempColor.r)*multiplier)
	color.g = tempColor.g + ((tempColor2.g - tempColor.g)*multiplier)
	color.b = tempColor.b + ((tempColor2.b - tempColor.b)*multiplier)

	return color

end

--------------------------------------------
-- Arguments:
-- number - Decimal nr
-- number - Length of number
--
-- Notes:
-- Converts a Decimal Number to Hexadecimal
--
-- Returns:
-- string - Hexadecimal number
--------------------------------------------
function beql:decToHex(Dec, Length)
	local B, K, Hex, I, D = 16, "0123456789ABCDEF", "", 0;
	while Dec>0 do
		I=I+1;
		Dec, D = math.floor(Dec/B), math.fmod(Dec,B)+1;
		Hex=string.sub(K,D,D)..Hex;
	end
	if( (Length ~= nil) and (string.len(Hex) < Length) ) then
		local temp, i = Length-string.len(Hex), 1;
		for i=1, temp, 1 do
			Hex = "0"..Hex;
		end
	end
	return Hex;
end

--------------------------------------------
-- Arguments:
-- string - text
-- number - Red Component
-- number - Green Component
-- number - Blue Component
--
-- Notes:
-- Returns a WoW-style colored text
--
-- Returns:
-- string - Text colored with WoW control characters
--------------------------------------------
function beql:ColorText(t, r, g, b)
	if ( t == nil ) then t = ""; end
	if ( r == nil ) then r = 0.0; end
	if ( g == nil ) then g = 0.0; end
	if ( b == nil ) then b = 0.0; end
	return "|CFF"..beql:decToHex(r*255, 2)..beql:decToHex(g*255, 2)..beql:decToHex(b*255, 2)..t.."|r";
end

--- EOF ---