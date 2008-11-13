local MINOR_VERSION = tonumber(("$Revision: 55025 $"):match("%d+"))

local L = AceLibrary("AceLocale-2.2"):new("Omen")
local dewdrop = AceLibrary("Dewdrop-2.0")
local waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")
local PlayerName = UnitName("player")
local Threat = AceLibrary("Threat-1.0")
local media = LibStub("LibSharedMedia-2.0")
local math_floor = math.floor
local Aura = AceLibrary("SpecialEvents-Aura-2.0")
local BS = AceLibrary("Babble-Spell-2.2")

Omen = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0", "Sink-1.0")
Omen.independentProfile = true
Omen:RegisterDB("OmenDB", "OmenDBPC", "char")

Omen.version = "2.1r" .. MINOR_VERSION
Omen.revision = MINOR_VERSION

BINDING_HEADER_OMEN = "Omen"
BINDING_NAME_OMENTOGGLE = L["Toggle Omen"]

local SkinDefaults = {
	AnimateBars = true,
	StretchBarTextures = false,
	BarTexture = "Blizzard",
	TPSUpdateFrequency = 0.05,
	BarHeight = 15,
	Width = 210,
	ShowTitle = true,
	BackdropColor = {r = 0, g = 0, b = 0, a = 0.5},
	BorderColor = {r = 0, g = 0, b = 0, a = 0.5},
	CustomColors = {},
	CustomBarTextures = {},
	CustomBarHeights = {},
	ShowVersionNumber = false,
	ShowMaxSize = false,
	ShowSelfArrow = true,
	ShowAggroArrow = true,
	SelfArrowColor = {r = 0, g = 1, b = 0, a = 1},
	AggroArrowColor = {r = 1, g = 0, b = 0, a = 1},
	ShowColumns = true,
	ShortThreatNumbers = true,
	-- Custom font: [name] = {size, outlining, color, font}
	CustomBarFonts = {
		["_COLUMNS_"] = {11, 0, {r = 1, g = 1, b = 1}, ""},
		["_BARS_"] = {10, 0, {r = 1, g = 1, b = 1}, ""},
	},
	ColumnVisibility = {
		name = true,
		tps = true,
		fight_tps = false,
		threat = true,
		threatpercent = true
	},
	-- Default font sizes
	ShowTitle = true,
	TitleFontSize = 12,

	ColumnFontSizes = {
		name = {11, 10},
		tps = {11, 10},
		fight_tps = {11, 10},
		threat = {11, 10},
		threatpercent = {11, 10},
	},
	
	ColumnOffsets = {
		name = {0.03, "LEFT", "LEFT"},
		tps = {0.5, "LEFT", "RIGHT"},
		fight_tps = {0.5, "LEFT", "RIGHT"},
		threat = {0.33, "LEFT", "RIGHT"},
		threatpercent = {0.03, "RIGHT", "RIGHT"},
	}
}

Omen.SkinDefaults = SkinDefaults

Omen:RegisterDefaults('account', {
	Skins = OmenDefaultSkins,
})

Omen:RegisterDefaults('profile', {
	-- Operation options
	AlwaysShowOmen = false,
	AlwaysShowSelf = true,
	ActivateSolo = false,
	ActivateWithPet = true,
	ShowKtmData = true,
	ThreatBars = {},
	ActiveSkin = nil,
	CurrentSkinSettings = {},
	EnableKTMPublish = true,
	
	EnableWarnings = true,
	FlashWarningFrame = true,
	ShowFloatingMessage = true,
	
	WarningsWhileTanking = false,
	WarnLevel = 0.9,
	WarningSound = "None",

	-- Non-skin display options
	ShowOmen = true,
	GrowUp = false,
	MaxBars = 10,
	Scale = 1,
	Classes = {
		["DRUID"] = true, 
		["HUNTER"] = true, 
		["MAGE"] = true, 
		["PALADIN"] = true, 
		["PRIEST"] = true, 
		["ROGUE"] = true, 
		["SHAMAN"] = true, 
		["WARLOCK"] = true, 
		["WARRIOR"] = true
	},	
	ShowAggroGain = true
})
OmenDefaultSkins = nil

local new, newHash, newSet, del
do
	local list = setmetatable({}, {__mode='k'})
	function new(...)
		local t = next(list)
		if t then
			list[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
			return t
		else
			return {...}
		end
	end
	function newHash(...)
		local t = next(list)
		if t then
			list[t] = nil
		else
			t = {}
		end	
		for i = 1, select('#', ...), 2 do
			t[select(i, ...)] = select(i+1, ...)
		end
		return t
	end
	function newSet(...)
		local t = next(list)
		if t then
			list[t] = nil
		else
			t = {}
		end	
		for i = 1, select('#', ...) do
			t[select(i, ...)] = true
		end
		return t
	end
	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		list[t] = true
		return nil
	end
end

Omen.bars = {}
Omen.ThreatBars = {}
Omen.SkinList = {}

function Omen:OnInitialize()
	self.threatTargetName = ""
	self.titleOffset = 0
	self.barsOffset = 22 + self.titleOffset
	self.barList = {}

	-- FuBar stuff
	self.hasIcon = "Interface\\AddOns\\Omen\\icon"
	self.hasNoColor  = true
	self.cannotDetachTooltip = true
	self.blizzardTooltip = true
	self.hideWithoutStandby = true
	self.cannotDetachTooltip = true

	self.ActiveSkin = self.db.profile.CurrentSkinSettings
	
	self:UpdateSkinList()

	if not self.ActiveSkin.Width then
		self:LoadSkin("Omen Default")
	end

	-- Frames setup
	self.Anchor = CreateFrame("Frame", "OmenAnchor", UIParent)
	self.Anchor:SetResizable(true)
	self.Anchor:SetClampedToScreen(true)
	self.Anchor:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	})
	self.Anchor:SetMinResize(100, 22)
	self.Anchor:SetMovable(true)
	self.Anchor:EnableMouse(true)
	self.Anchor:SetPoint("CENTER", UIParent, "CENTER")
	self.Anchor:SetScript("OnMouseDown", function() if not Omen.db.profile.Locked then this:StartMoving(); end end)
	self.Anchor:SetScript("OnMouseUp", function()
		this:StopMovingOrSizing();		
		Omen:SetAnchors()
	end)
	self.Anchor:SetScript("OnSizeChanged", function()
		self.ActiveSkin.Width = Omen.Anchor:GetWidth()
		Omen:UpdateLayout()
		Omen:ArrangeBars()
	end)
	self.Anchor:SetHeight(self.barsOffset + 5)
	self.Anchor:SetScale(min(5, max(0.2, self.db.profile.Scale)))
	dewdrop:Register(self.Anchor, "children", self.OnMenuRequest, 'cursorX', true, 'cursorY', true)

	-- Resize grip
	local grip = CreateFrame("Button", "OmenResizeGrip", self.Anchor)
	grip:SetNormalTexture("Interface\\AddOns\\Omen\\ResizeGrip")
	grip:SetHighlightTexture("Interface\\AddOns\\Omen\\ResizeGrip")
	grip:SetWidth(16)
	grip:SetHeight(16)
	grip:SetScript("OnMouseDown", function()
		if not Omen.db.profile.Locked then
			this:GetParent():StartSizing()
		end
	end)
	grip:SetScript("OnMouseUp", function()
		this:GetParent():StopMovingOrSizing()
	end)
	grip:SetPoint("BOTTOMRIGHT", self.Anchor, "BOTTOMRIGHT", 0, 1)
	self.Grip = grip
	
	self.modName = "|cff6299FFOmen"

	-- App title
	self.Anchor.title = self.Anchor:CreateFontString(nil, nil, "GameFontNormal")
	self.Anchor.title:SetPoint("BOTTOM", self.Anchor, "TOP", 0, 2)
	self.Anchor.title:SetText(self.modName)

	-- App revision string
	self.Anchor.revision = self.Anchor:CreateFontString(nil, nil, "GameFontNormal")
	self.Anchor.revision:SetPoint("TOPLEFT", self.Anchor, "BOTTOMLEFT", 4, 2)
	local font, size = self.Anchor.revision:GetFont()
	self.Anchor.revision:SetFont(font, 8)
	self.Anchor.revision:SetText(string.format("|cffFFB400Omen r |cffffffff%s /|cffFFB400 Threat-1.0 r |cffffffff%s", MINOR_VERSION, select(2,Threat:GetLibraryVersion())))

	-- App "out of date" notification
	self.Anchor.outofDate = self.Anchor:CreateFontString(nil, nil, "GameFontNormal")
	self.Anchor.outofDate:SetPoint("TOPLEFT", self.Anchor.revision, "BOTTOMLEFT", 0, -1)
	self.Anchor.outofDate:Hide()
	local font, size = self.Anchor.revision:GetFont()
	self.Anchor.outofDate:SetFont(font, 8)
	self.Anchor.outofDate:SetText("|cffff0000Out of date notice")

	-- Create columns
	self.Anchor.columns = {}
	self:CreateColumn("name", L["Name"], 10)
	self:CreateColumn("tps", L["TPS"], 10)
	self:CreateColumn("threat", L["Threat"], 10)
	self:CreateColumn("threatpercent", "%", 10)
	self:CreateColumn("fight_tps", L["E-TPS"], 10)
	
	local columns = {L["Name"], "name", L["TPS"], "tps", L["E-TPS"], "fight_tps", L["Threat"], "threat", "%", "threatpercent"}
	for i = 1, #columns, 2 do
		local name = columns[i]
		local iName = columns[i+1]
		local val = {
			type = "group",
			name = name,
			desc = name,
			args = {
				["toggle_column_" .. iName] = {
					type = "toggle",
					name = L["Show"],
					desc = L["Show"],
					get = function()
						return Omen.ActiveSkin.ColumnVisibility[iName]
					end,
					set = function(v)
						Omen.ActiveSkin.ColumnVisibility[iName] = v
						Omen:ToggleColumn(iName, v)
					end
				},
				["column_offset_" .. iName] = {
					type = "range",
					name = L["Offset"],
					desc = L["Offset"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					get = function()
						return Omen.ActiveSkin.ColumnOffsets[iName][1]
					end,
					set = function(v)
						Omen.ActiveSkin.ColumnOffsets[iName][1] = v
						Omen:UpdateLayout()
					end
				}
				
			}			
		}
		self.mainMenu.args.skins.args.skinOptions.args.columns.args["column_" .. iName] = val
	end
	
	-- Load threat bars
	for k,v in pairs(self.db.profile.ThreatBars) do
		local bar = OmenThreatBar:new()
		bar:LoadBar(k)
	end

	-- Final cleanup and stuff
	
	if Threat:IsActive() then
		self:Threat_Activate()
	end
	self:PatchSkin()
	self:RegisterEvent("AceEvent_FullyInitialized")	
	if not self.Initialized and AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	end
end

local playerClass = select(2, UnitClass("player"))
local playerIsTanking = false

function Omen:OnEnable()
	if not self.Initialized and AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	end
	if self.db.profile.ActivateSolo then
		Threat:RequestActiveOnSolo(true)
	end
	self:RegisterEvent("Threat_Activate")
	self:RegisterEvent("Threat_Deactivate")		
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	self:RegisterEvent("Threat_ThreatCleared", "Clear")
	self:RegisterEvent("Threat_PartyChanged")
	self:RegisterEvent("Threat_OutOfDateNotice")
	self:RegisterEvent("Threat_ThreatUpdated")
	self:RegisterEvent("PLAYER_LOGOUT")
	
	if playerClass == "WARRIOR" or playerClass == "DRUID" then
		self:RegisterEvent("SPELLS_CHANGED")
		self:SPELLS_CHANGED()
	elseif playerClass == "PALADIN" then
		self:RegisterEvent("SpecialEvents_PlayerBuffGained", "buffGained")
		self:RegisterEvent("SpecialEvents_PlayerBuffLost", "buffLost")
		for buffName in Aura:BuffIter("player") do
			if buffName == BS["Righteous Fury"] then
				playerIsTanking = true
				break
			end
		end	
	end
	
	if Threat:IsActive() then
		self:Threat_Activate()
	end
	self:ArrangeBars()
	self:SetAnchors(true)
	self:ApplySkin()
	self:Toggle(self.db.profile.ShowOmen)
	Threat:EnableKLHTMBroadcast(self.db.profile.EnableKTMPublish)
end

function Omen:OnDisable()
	self:Clear()
	self:Toggle(false)
	Threat:EnableKLHTMBroadcast(false)
end

function Omen:PLAYER_LOGOUT()
	self:Clear()
end

-- Only registered when the player is a warrior/druid
function Omen:SPELLS_CHANGED()
	if playerClass == "WARRIOR" and GetShapeshiftForm(true) == 2 then
		playerIsTanking = true
	elseif playerClass == "DRUID" and GetShapeshiftForm(true) == 1 then
		playerIsTanking = true
	end
end

-- Only registered when the player is a paladin
function Omen:buffGained(buffName)
	if buffName == BS["Righteous Fury"] then
		playerIsTanking = true
	end
end

-- Only registered when the player is a paladin
function Omen:buffLost()
	if buffName == BS["Righteous Fury"] then
		playerIsTanking = false
	end
end

function Omen:UpdateSkinList()
	local osl = self.SkinList
	for i = 1, #osl do
		tremove(osl)
	end
	for k, v in pairs(Omen.db.account.Skins) do
		tinsert(osl, k)
	end
	table.sort(osl)
end

function Omen:AceEvent_FullyInitialized()
	self.Initialized = true
	self:SetAnchors()
	self:CreateAggroGainBar(string.format("*%s*", L["Aggro Gain"]))
	if Threat:IsActive() then
		self:Threat_Activate()
	else
		self:Threat_Deactivate()
	end
	for k,v in ipairs(self.ThreatBars) do
		v:UpdateTexture()
	end
	self:ApplySkin()
end

local function ConvertToK(n)
	if not Omen.ActiveSkin.ShortThreatNumbers then return n , "" end
	if n > 1000 then
		return n / 1000, "k"
	end
	return n, ""
end

function Omen:Threat_Activate()
	if not self:IsEventRegistered("UNIT_TARGET") then
		self:RegisterEvent("UNIT_TARGET")
	end
	if not self:IsEventRegistered("PLAYER_TARGET_CHANGED") then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
	end
	self:PLAYER_TARGET_CHANGED()
	
	self:SetIcon("Interface\\AddOns\\Omen\\icon")
	local pMembers = GetNumPartyMembers() + GetNumRaidMembers()
	if pMembers == 0 and not self.db.profile.ActivateWithPet then return end
	if self.db.profile.ShowOmen or Omen.db.profile.AlwaysShowOmen then
		Omen:Toggle(true)
	end
end

function Omen:Threat_Deactivate()
	if self:IsEventRegistered("UNIT_TARGET") then
		self:UnregisterEvent("UNIT_TARGET")
	end
	if self:IsEventRegistered("PLAYER_TARGET_CHANGED") then
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end
	self:SetIcon("Interface\\AddOns\\Omen\\icon_off")
	if not Omen.db.profile.AlwaysShowOmen then
		self.Anchor:Hide()
	end
end

function Omen:Toggle(state)
	if state or not self.Anchor:IsVisible() then
		self.Anchor:Show()
		self:ArrangeBars()
	else
		self.Anchor:Hide()
	end

	self.db.profile.ShowOmen = (Omen.Anchor:IsVisible() and true or false) -- DB didn't like nil
end

-- If our party changes around, we want to follow our target by name
-- We use the Threat event rather than the Blizzard event because this way we
-- know that Threat:GetUnitIDByUnitName will be accurate
function Omen:Threat_PartyChanged()	
	for k,v in pairs(self.bars) do
		local partyID = Threat:GetUnitIDByUnitName(v.unitname)
		if partyID then
			v.unitid = partyID
		end
	end
	if self.partyMemberName then
		local partyID = Threat:GetUnitIDByUnitName(self.partyMemberName)
		if partyID then
			self.watchedUnitID = partyID
			self.threatTargetName = UnitName(partyID .. "target")
		else
			-- We couldn't find a corresponding unit for the party member we want to watch
			-- Go ahead and invalidate them
			self.partyMemberName = nil
			self.watchedUnitID = nil
			self.threatTargetName = nil
		end
		self:UpdateThreatLists(self.threatTargetName or Threat.GlobalTarget)
	end
end

function Omen:UpdateThreatLists(target)
	if not target and self.AggroBar then
		self.AggroBar.threatVal = 0
	end
	target = target or Threat.GlobalTarget

	if self.lastTargetName == target then return end
	self.lastTargetName = target
	
	self:Clear()
	self.threatWarned = false

	self.Anchor.title:SetText(target and string.format("%s - |cffFF4200%s", self.modName, target) or "")
	-- self.Anchor.mobName:SetText(target and string.format("|cffFF4200%s", target) or "")
	for k, v in Threat:IterateGroupThreatForTarget(target) do
		local bar = self.bars[k]
		if not bar then
			local unit = Threat:GetUnitIDByUnitName(k)
			if unit then
				bar = self:addOrGetBar(k, unit)
			end
		end

		if  bar then -- unit can be non-existent when self or someone leaves party
			local val, isK = ConvertToK(v)
			bar.targetThreat = 0
			bar.globalThreat = 0
			self.bars[k].threatVal = v
			self.bars[k].labels.threat:SetText(string.format("%2.2f%s", val, isK))
		end
	end

	self:ArrangeBars()
end

function Omen:PLAYER_TARGET_CHANGED()
	self.threatTargetName = UnitName("target")
	if self.threatTargetName then
		self.watchedUnitID = "target"
	else
		self.watchedUnitID = nil
	end
		
	self.lastWithAggro = UnitName("targettarget")

	if UnitInParty("target") or UnitInRaid("target") or UnitIsUnit("target", "pet") then
		self.threatTargetName = UnitName("targettarget")
		self.lastWithAggro = UnitName("targettargettarget")
	end
	
	self:UpdateThreatLists(self.threatTargetName)
end

local function func(self, name)
	self.lastWithAggro = name
end

function Omen:UNIT_TARGET(arg1)
	if UnitIsUnit("player", arg1) then
		return
		
	-- Anyone know the conditions for getting a unit named "npc"?
	elseif self.watchedUnitID and UnitIsUnit(arg1, self.watchedUnitID) and arg1 ~= "npc" then
		local lastThreatTarget = self.threatTargetName
		if UnitInParty(arg1) or UnitInRaid(arg1) or UnitIsUnit(arg1, "pet") then
			local et = arg1 .. "target"
			local ett = arg1 .. "targettarget"
			self.threatTargetName = UnitName(et)
			if UnitInParty(ett) or UnitInRaid(ett) or UnitIsUnit(ett, "pet") then
				local ettN = UnitName(ett)
				if not lastThreatTarget or Threat:GetThreat(ettN, lastThreatTarget) > Threat:GetThreat(self.lastWithAggro, lastThreatTarget) then
					self.lastWithAggro = ettN
					if self:IsEventScheduled("OmenSwitchAggro") then
						self:CancelScheduledEvent("OmenSwitchAggro")
					end
				else
					self:ScheduleEvent("OmenSwitchAggro", func, 2.5, self, ettN)
				end
			end
			self:UpdateThreatLists(self.threatTargetName)
		else
			self.threatTargetName = UnitName(arg1)
			local et = arg1 .. "target"
			if UnitInParty(et) or UnitInRaid(et) or UnitIsUnit(et, "pet") then
				local ettN = UnitName(et)
				if not lastThreatTarget or Threat:GetThreat(ettN, lastThreatTarget) > Threat:GetThreat(self.lastWithAggro, lastThreatTarget) then
					self.lastWithAggro = ettN
					if self:IsEventScheduled("OmenSwitchAggro") then
						self:CancelScheduledEvent("OmenSwitchAggro")
					end
				else
					self:ScheduleEvent("OmenSwitchAggro", func, 2.5, self, ettN)
				end
			end
		end
		if lastThreatTarget ~= self.threatTargetName then
			self:UpdateThreatLists(self.threatTargetName)
		end
	end	
end

function Omen:PLAYER_REGEN_ENABLED()
	self:ScheduleEvent("ResetTPSTimerTables", self.DisableTPSUpdate, 3.5, self)
end

local function WarnOnThreatThreshold(self, warningLevel)
	if playerIsTanking and not self.db.profile.WarningsWhileTanking then return end
	
	local ttName = self.threatTargetName
	if not ttName then return end
	if PlayerName == self.lastWithAggro then return end
	local playerThreat = Threat:GetThreat(PlayerName, ttName)
	local tankThreat = Threat:GetThreat(self.lastWithAggro, ttName)
	if tankThreat == 0 then return end
	local threshold = tankThreat * warningLevel
	if playerThreat >= threshold and not self.threatWarned then
		if self.db.profile.FlashWarningFrame then
			LowHealthFrame:Hide();
			UIFrameFlash(LowHealthFrame, 0.25, 0.75, 2.2, false, 0, 0.1)
		end
		if self.db.profile.ShowFloatingMessage then
			self:Pour((L["Warning: Passed %2.0f%% of %s's threat!"]):format(warningLevel * 100, self.lastWithAggro), 1, 0, 0, nil, 24, "OUTLINE", true)
		end		
		local sound = media:Fetch("sound", Omen.db.profile.WarningSound)
		if sound then
			PlaySoundFile(sound)
		end
		self.threatWarned = true
	elseif playerThreat < threshold then
		self.threatWarned = false
	end
end

local TTL, TTLBase = 0.5, 0.5

local GTARGET = Threat.GlobalTarget
function Omen:Threat_ThreatUpdated(pName, pUnit, targetHash)
	if not self:IsEventScheduled("OmenTPSUpdate") then
		self:EnableTPSUpdate()
	end
	if not targetHash then
		self:Print(string.format("Error: Got a nil target, %s, %s, %s", pName, pUnit, threatVal))
		return
	end
	local isCurrentTarget = self.threatTargetName and Threat:UnitIsUnit(self.threatTargetName, targetHash)
	if not isCurrentTarget and not Threat:UnitIsUnit(targetHash, GTARGET) then return end

	local threatVal = Threat:GetThreat(pName, self.threatTargetName or GTARGET)
	local bar = self:addOrGetBar(pName, pUnit)
	
	if (pName == PlayerName or pName == self.lastWithAggro) and self.db.profile.EnableWarnings then
		WarnOnThreatThreshold(self, self.db.profile.WarnLevel, threatVal)
	end
	
	local isK
	bar.threatVal = threatVal
	threatVal, isK = ConvertToK(threatVal)
	bar.labels.threat:SetText(string.format("%2.1f%s", threatVal, isK))
	TTL = TTL - GetTime()
	if TTL < 0 then
		TTL = TTL + TTLBase
		self:ArrangeBars()
	end
end

function Omen:Threat_OutOfDateNotice(myVersion, newVersion, newVersionHolder, isCritical)
	if isCritical then
		self.Anchor.outofDate:SetText(string.format("|cffff0000CRITICAL UPDATE AVAILABLE! |cffFFB400r |cffffffff%s (%s)", newVersion, newVersionHolder))
	else
		self.Anchor.outofDate:SetText(string.format("|cffff0000New version available! |cffFFB400r |cffffffff%s (%s)", newVersion, newVersionHolder))
	end
	self.Anchor.outofDate:Show()
end

function Omen:OnClick()
	if IsShiftKeyDown() then
		Threat:RequestThreatClear()
	elseif IsControlKeyDown() then
		if waterfall then
			waterfall:Open("Omen")
		else
			self:Print("Waterfall-1.0 is required to access the GUI.")
		end
	else
		self:Toggle()
	end
end

function Omen:OnTooltipUpdate()
	GameTooltip:AddLine("|cffffff00" .. L["Click|r to toggle the Omen window"])
	GameTooltip:AddLine("|cffffff00" .. L["Ctrl-Click|r to open the options menu"])
	GameTooltip:AddLine("|cffffff00" .. L["Shift-Click|r to issue a threat clear request"])
end

------------------------------------------------
-- UI Manipulation
------------------------------------------------

function Omen:CreateTPSGraph(unitNameA, unitNameB)
end

------------------------------------------------------------------------------------------------
-- TPS crap
------------------------------------------------------------------------------------------------

function Omen:EnableTPSUpdate()
	if not self:IsEventScheduled("OmenTPSUpdate") then
		self:ScheduleRepeatingEvent("OmenTPSUpdate", self.UpdateAllTPS, Omen.ActiveSkin.TPSUpdateFrequency, self)
		self:ScheduleEvent("ResetTPSTimerTables", self.DisableTPSUpdate, 10, self)
	end
end

function Omen:DisableTPSUpdate()
	if self:IsEventScheduled("OmenTPSUpdate") then
		self:CancelScheduledEvent("OmenTPSUpdate")
	end
end

function Omen:UpdateAllTPS()
	local target = self.threatTargetName or GTARGET
	for k, v in ipairs(self.barList) do
		if v.validUnit and v.unitname and v:IsVisible() then
			local tps, e_tps = Threat:GetTPS(v.unitname, target)
			v.labels.tps:SetText(math_floor(tps or 0))
			v.labels.fight_tps:SetText(math_floor(e_tps or 0))
		end
	end
end

function Omen:GetTPS(player, target)
	return Threat:GetTPS(player, target)
end

-- Thanks to Kalman for working out the TPS formula with me.
-- It's just a single-pole IIR filter which decreases the weight of older samples
-- over time. 0 < p1 < 1 - a higher p1 results in faster decay (which means a shorter window)
------------------------------------------------------------------------------------
-- Graphing
------------------------------------------------------------------------------------
function Omen:UpdateGraphCompare(unit)
	self.graph_unitA = unit

	self.graph_unitB = PlayerName
	if not self.GraphFrame then
		self:CreateGraph()
	end

	local r, g, b = self.bars[self.graph_unitA].tex:GetVertexColor()
	self.GraphA:SetBarColors({r, g, b, 0.1},{r, g, b, 0.6})
end

function Omen:CreateGraph()
	self.GraphFrame = CreateFrame("Frame", "OmenThreatGraph", self.Anchor)
	self.GraphFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	})

	local f = self.db.profile.BackdropColor
	self.GraphFrame:SetBackdropColor(f.r, f.g, f.b, f.a)

	local f = self.db.profile.BorderColor
	self.GraphFrame:SetBackdropBorderColor(f.r, f.g, f.b, f.a)
	
	self.GraphFrame:SetWidth(self.Anchor:GetWidth())
	self.GraphFrame:SetHeight(50)
	self.GraphFrame:SetPoint("TOPLEFT", self.Anchor, "BOTTOMLEFT", 0, -10)
	local width = math.floor(self.GraphFrame:GetWidth() - 7)
	local height = math.floor(self.GraphFrame:GetHeight() - 7)
	
	local Graph = AceLibrary("Graph-1.0")

	self.GraphA = Graph:CreateGraphRealtime("OmenThreatGraphA", self.GraphFrame, "TOPLEFT", "TOPLEFT", 5, -4, width, height)
	self.GraphB = Graph:CreateGraphRealtime("OmenThreatGraphB", self.GraphFrame, "TOPLEFT", "TOPLEFT", 5, -4, width, height)

	self.graphMax = 0
		
	local g = self.GraphA
	g:SetAutoScale(false)
	g:SetGridSpacing(1.0,10.0)
	g:SetXAxis(-10,-1)
	g:SetFilterRadius(1.5)
	g:SetYMax(0.01)
	local cr, cg, cb = self.bars[self.graph_unitA].tex:GetVertexColor()
	g:SetBarColors({cr, cg, cb, 0.1},{cr, cg, cb, 0.6})

	g = self.GraphB
	g:SetAutoScale(false)
	g:SetGridSpacing(1.0,10.0)
	g:SetXAxis(-10,-1)
	g:SetYMax(0.01)
	g:SetFilterRadius(1.5)
	if self.bars[self.graph_unitB] then
		local cr, cg, cb = self.bars[self.graph_unitB].tex:GetVertexColor()
		g:SetBarColors({cr, cg, cb, 0.1},{cr, cg, cb, 0.6})
	else
		local cr, cg, cb = 1, 0, 0
		g:SetBarColors({cr, cg, cb, 0.1},{cr, cg, cb, 0.6})
	end
	self.updateCt = 9
	self.tA = 0
	self.tB = 0	
	self.tSA = 0
	self.tSB = 0	
	
	self:ScheduleRepeatingEvent("OmenUpdateThreatGraphA", function()
		self.updateCt = self.updateCt + 1
		if self.updateCt == 10 then
			local tpsA = self:GetTPS(self.graph_unitA, self.threatTargetName or "") or 0
			local tpsB = self:GetTPS(self.graph_unitB, self.threatTargetName or "") or 0
			local yMax = max(self.GraphA:GetMaxValue(), self.GraphB:GetMaxValue()) * 1.1
			self.oldTPSA = tpsA
			self.oldTPSB = tpsB
			self.GraphA.YMax = yMax
			self.GraphB.YMax = yMax
			self.tSA = (tpsA - self.tA) / 10
			self.tSB = (tpsB - self.tB) / 10
			self.tA = tpsA
			self.tB = tpsB
			self.updateCt = 0
		end
		self.GraphA:AddTimeData(self.tA + (self.tSA * self.updateCt))
		self.GraphB:AddTimeData(self.tB + (self.tSB * self.updateCt))
	end, 0.1, self)
end
