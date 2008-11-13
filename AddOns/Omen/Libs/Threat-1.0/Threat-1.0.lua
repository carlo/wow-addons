--[[-----------------------------------------------------------------------------
Name: Threat-1.0
Revision: $Revision: 54707 $
Author(s): Antiarc (cheald at gmail)
Website: http://www.wowace.com/wiki/Threat-1.0
Documentation: http://www.wowace.com/wiki/Threat-1.0
SVN: http://svn.wowace.com/wowace/trunk/Threat-1.0/
Description: Tracks and communicates player and pet threat levels
License: LGPL v2.1

Copyright (C) 2007 Chris Heald and the Threat-1.0 team

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
-------------------------------------------------------------------------------]]

local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54707 $"):match("%d+"))

_G.ThreatLib_MINOR_VERSION = MINOR_VERSION

_G.ThreatLib_funcs = {}

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

------------------------------------------------------------------------
-- Localization
------------------------------------------------------------------------

local MyLocale = _G.GetLocale()
-- MyLocale = "faKE"

------------------------------------------------------------------------
-- Setup and utility functions
------------------------------------------------------------------------

-- Need to update this when backwards incompatible changes are made
local LAST_BACKWARDS_COMPATIBLE_REVISION = 42451

local _G = _G
local tonumber = _G.tonumber
local error = _G.error
local pairs = _G.pairs
local select = _G.select
local next = _G.next
local tinsert = _G.tinsert
local tremove = _G.tremove
local type = _G.type
local time = _G.time
local table_sort = _G.table.sort
local tostring = _G.tostring
local setmetatable = _G.setmetatable
local math_floor = _G.math.floor
local math_min = _G.math.min
local math_max = _G.math.max
local string_char = _G.string.char
local pcall = _G.pcall

local UnitName = _G.UnitName
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers
local InCombatLockdown = _G.InCombatLockdown
local UnitAffectingCombat = _G.UnitAffectingCombat
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local ChatThrottleLib = _G.ChatThrottleLib
local AceLibrary = _G.AceLibrary
local UnitIsUnit = _G.UnitIsUnit
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitIsPlayer = _G.UnitIsPlayer
local CheckInteractDistance = _G.CheckInteractDistance
local UnitIsVisible = _G.UnitIsVisible
local UnitExists = _G.UnitExists
local debugstack = _G.debugstack
local IsInGuild = _G.IsInGuild
local IsResting = _G.IsResting
local GetRealZoneText = _G.GetRealZoneText
local IsInInstance = _G.IsInInstance
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local IsPartyLeader = _G.IsPartyLeader
local GetPartyLeaderIndex = _G.GetPartyLeaderIndex
local geterrorhandler = _G.geterrorhandler
local GetLocale = _G.GetLocale

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end

local BS = AceLibrary("Babble-Spell-2.2")
local ThreatLib = _G.ThreatLib
setmetatable(ThreatLib, {__tostring = function(self) return (self:GetLibraryVersion()) end})
ThreatLib.name = MAJOR_VERSION
AceLibrary("AceComm-2.0"):embed(ThreatLib)
AceLibrary("AceEvent-2.0"):embed(ThreatLib)
ThreatLib.OnCommReceive = {}
ThreatLib.OnCommReceiveGuild = {}
ThreatLib.OnCommReceiveWhisper = {}

local ThreatKLHTMSupport

---------------------------------------------------------
-- Default/enUS translation
---------------------------------------------------------

local L = {
	["Alterac Valley"] = "Alterac Valley",
	["You must be a raid officer or the raid leader to request a threat list clear."] = "You must be a raid officer or the raid leader to request a threat list clear.",
	["Knock Away"] = "Knock Away",
	["Wing Buffet"] = "Wing Buffet",
	["Sand Blast"] = "Sand Blast",
	["Unknown"] = "Unknown"
}

if GetLocale() == "deDE" then
	L["Alterac Valley"] = "Alteractal"
	L["Knock Away"] = "Wegschlagen"
	L["Wing Buffet"] = "Flügelstoß"
	L["Sand Blast"] = "Sandstoß"
	L["Unknown"] = "Unbekannt"
	
elseif GetLocale() == "frFR" then
	L["Alterac Valley"] = "Vallée d'Alterac"
	L["You must be a raid officer or the raid leader to request a threat list clear."] = "Vous devez être officier du raid ou chef du raid pour effectuer une réinitialisation de la liste des menaces."
	L["Knock Away"] = "Repousser au loin"
	L["Wing Buffet"] = "Frappe des ailes"
	L["Sand Blast"] = "Explosion de sable"
	L["Unknown"] = "Inconnu"
	
elseif GetLocale() == "zhCN" then
	L["Alterac Valley"] = "奥特兰克山谷"
	L["You must be a raid officer or the raid leader to request a threat list clear."] = "你必须是团队助理或更高级别才能清除威胁值列表."
	L["Knock Away"] = "击飞"
	L["Wing Buffet"] = "龙翼打击"
	L["Sand Blast"] = "沙尘爆裂"
	L["Unknown"] = "未知"
	
elseif GetLocale() == "zhTW" then
	L["Alterac Valley"] = "奧特蘭克山谷"
	L["You must be a raid officer or the raid leader to request a threat list clear."] = "你必須是團隊副手或團隊隊長才能清除威脅列表。"
	L["Knock Away"] = "擊退"
	L["Wing Buffet"] = "羽翼攻擊"
	L["Sand Blast"] = "沙塵爆裂"
	L["Unknown"] = "未知"
	
elseif GetLocale() == "koKR" then
	L["Alterac Valley"] = "알터랙 계곡"
	L["You must be a raid officer or the raid leader to request a threat list clear."] = "위협수준 목록을 초기화하려면 공격대장이거나 승급자여야 합니다."
	L["Knock Away"] = "날려버리기"
	L["Wing Buffet"] = "폭풍 날개"
	L["Sand Blast"] = "모래 돌풍"
	L["Unknown"] = "무엇인가"
	
elseif GetLocale() == "esES" then
	L["Alterac Valley"] = "Valle de Alterac"
	L["Knock Away"] = "Empujar"
	L["Wing Buffet"] = "Sacudida de alas"
	L["Unknown"] = "Desconocido"
	
end

_G.ThreatLib.L = L

local playerName = UnitName("player")
local mobNameTranslations = {}
local partyMemberLocales = {}
ThreatLib.partyMemberLocales = partyMemberLocales

local partyMemberAgents = {}
local partyMemberLocaleCount = 0
local lastPublishedPlayerThreat = {}
local lastPublishedPetThreat = {}
local globalPlayerThreatAdjustments = {}
local globalPetThreatAdjustments = {}
local partyForeignLocales = {}

local function NumericCheckSum(text)
	local counter = 1
	local len = text:len()
	for i = 1, len, 3 do
		counter = (counter*8257 % 16777259) +
			(text:byte(i)) +
			((text:byte(i+1) or 1)*127) +
			((text:byte(i+2) or 2)*16383)
	end
	return counter % 16777213
end

local function TailoredNumericCheckSum(text)
	local hash = NumericCheckSum(text)
	local a = math_floor(hash / 256^2)
	local b = math_floor(hash / 256) % 256
	local c = hash % 256
	-- \000, \n, |, \176, s, S, \015, \020
	if a == 0 or a == 10 or a == 124 or a == 176 or a == 115 or a == 83 or a == 15 or a == 20 or a == 37 then
		a = a + 1
	-- \t, \255
	elseif a == 9 or a == 255 then
		a = a - 1
	end
	if b == 0 or b == 10 or b == 124 or b == 176 or b == 115 or b == 83 or b == 15 or b == 20 or b == 37 then
		b = b + 1
	elseif b == 9 or b == 255 then
		b = b - 1
	end
	if c == 0 or c == 10 or c == 124 or c == 176 or c == 115 or c == 83 or c == 15 or c == 20 or c == 37 then
		c = c + 1
	elseif c == 9 or c == 255 then
		c = c - 1
	end
	return a * 256^2 + b * 256 + c
end

local function toliteral(q)
	if type(q) == "string" then
		return ("%q"):format(q)
	else
		return tostring(q)
	end
end

local TailoredBinaryCheckSum = setmetatable({}, {__mode='k', __index = function(self, key)
	--[[
	if type(key) ~= "string" then -- REMOVE LATER MAYBE
		error(("Bad argument #1 to `TailoredBinaryCheckSum'. %q expected, got %q (%s). Please report to Antiarc."):format("string", type(key), tostring(key)), 2)
	end
	]]--
	local num = TailoredNumericCheckSum(key)
	local value = string_char(math_floor(num / 256^2), math_floor(num / 256) % 256, num % 256)
	self[key] = value
	return value
end})
ThreatLib.TailoredBinaryCheckSum = TailoredBinaryCheckSum

local GLOBAL_HASH = TailoredBinaryCheckSum["_GLOBAL_"]
local PUBLIC_GLOBAL_HASH
local publishInterval
local lastPublishTime = 0
local dontPublishThreat = false

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
	ThreatLib.new = new
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
	ThreatLib.newHash = newHash
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
	ThreatLib.newSet = newSet
	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		t[''] = true
		t[''] = nil
		list[t] = true
		return nil
	end
	ThreatLib.del = del
end

local modules = {}
local activeModules = {}

-- #NODOC
function ThreatLib:GetModule(name)
	return modules[name]
end

-- #NODOC
function ThreatLib:NewModule(name, ...)
	local mod = { mixins = {} }
	for i = 1, select('#', ...) do
		local lib = AceLibrary((select(i, ...)))
		mod.mixins[lib] = true
		if lib.embed then
			lib:embed(mod)
		else
			lib:Embed(mod)
		end
	end
	modules[name] = mod
	mod.name = name
	activeModules[mod] = false
	return mod
end

-- #NODOC
function ThreatLib:ToggleModuleActive(module, value)
	if type(module) == "string" then
		module = modules[module]
	end
	if value == activeModules[module] then
		return
	end

	activeModules[module] = value
	
	local OnEmbedChange = value and "OnEmbedEnable" or "OnEmbedDisable"
	for mixin in pairs(module.mixins) do
		if type(mixin[OnEmbedChange]) == "function" then
			local success, ret = pcall(mixin[OnEmbedChange], mixin, module)
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	
	local OnChange = value and "OnEnable" or "OnDisable"
	if type(module[OnChange]) == "function" then
		local success, ret = pcall(module[OnChange], module)
		if not success then
			geterrorhandler()(ret)
		end
	end
end

ThreatLib.partyUnits = {}
local partyUnits = ThreatLib.partyUnits
local partyMemberUsesKLHTM = {}
ThreatLib.partyMemberUsesKLHTM = partyMemberUsesKLHTM

local partyUnits_mt = {__index = function(self, key)
	local numRaid = GetNumRaidMembers()
	if numRaid > 0 then
		for i = 1, numRaid do
			local u = "raidpet" .. i
			local n = UnitName(u)
			if n then
				partyUnits[n] = u
			end
		end
		local n = UnitName("pet")
		if n then
			partyUnits[n] = "pet"
		end
		for i = 1, numRaid do
			local u = "raid" .. i
			partyUnits[UnitName(u)] = u
		end
	else
		local numParty = GetNumPartyMembers()
		if numParty > 0 then
			for i = 1, numParty do
				local u = "partypet" .. i
				local n = UnitName(u)
				if n then
					partyUnits[n] = u
				end
			end
			local n = UnitName("pet")
			if n then
				partyUnits[n] = "pet"
			end
			for i = 1, numParty do
				local u = "party" .. i
				partyUnits[UnitName(u)] = u
			end
		else
			local n = UnitName("pet")
			if n then
				partyUnits[n] = "pet"
			end
		end
	end
	partyUnits[playerName] = "player"
	setmetatable(partyUnits, nil)
	
	for name in pairs(partyMemberUsesKLHTM) do
		if not partyUnits[name] then
			partyMemberUsesKLHTM[name] = nil
		end
	end
	
	return self[key]
end}
local threatTargets = {}
ThreatLib.threatTargets = threatTargets

local latestSeenRevision -- set later, to get the latest version of the whole lib
local currentPartySize = 0
local inParty = false
local inRaid = false
local partyMemberRevisions = {}
local latestSeenSender
ThreatLib.partyMemberRevisions = partyMemberRevisions

local function IsGroupOfficer(unit)
	if not inRaid and not inParty then return unit == "player" end
	if inRaid then
		for i = 1, GetNumRaidMembers() do
			if UnitIsUnit("raid" .. i, unit) then
				local name, rank = GetRaidRosterInfo(i)
				if rank > 0 then
					return true
				end
			end
		end
	elseif inParty then
		if IsPartyLeader() and unit == "player" then return true end
		return UnitIsUnit(unit, "party" .. GetPartyLeaderIndex())
	end

	return false	
end
ThreatLib.IsGroupOfficer = IsGroupOfficer

local tpsSigma = {}
local tpsSamples = 25
local function UpdateTPS(player, target, targetThreat)
	if not player then
		error("Invalid parameter #1 passed to UpdateTPS: expected string, got nil")
	end
	if not target then
		error("Invalid parameter #2 passed to UpdateTPS: expected string, got nil")
	end
	if not targetThreat then
		error("Invalid parameter #3 passed to UpdateTPS: expected number, got nil")
	end
	local playerTable = tpsSigma[player]
	if not playerTable then
		playerTable = new()
		tpsSigma[player] = playerTable
		playerTable["FIGHT_START"] = GetTime()
	end
	local sigma = playerTable[target]
	if not sigma then
		-- average, last threat, avg sum, sample 1, sample time 1, ..., sample n, sample time n
		sigma = new(targetThreat, targetThreat, 0)
		playerTable[target] = sigma
	end
	local removedVal, removedTime, period, delta, total, tt = 0, nil, nil, targetThreat - sigma[2], 0, GetTime()
	if targetThreat - sigma[2] == 0 then return end
	tinsert(sigma, delta)
	tinsert(sigma, tt)
	local nPoints = (#sigma - 3) / 2
	while nPoints >= tpsSamples do
		removedVal = tremove(sigma, 4)
		removedTime = tremove(sigma, 4)
		sigma[3] = sigma[3] - removedVal
		nPoints = (#sigma - 3) / 2
	end
	sigma[3] = sigma[3] + delta
	
	period = tt - (removedTime or sigma[5])
	period = period == 0 and 1 or period
	sigma[1] = sigma[3] / period
	sigma[2] = targetThreat
end
ThreatLib.UpdateTPS = UpdateTPS -- for profiling

--[[----------------------------------------------------------
-- Returns:
--	The current number of threat samples used to calculate TPS
------------------------------------------------------------]]
function ThreatLib:GetTPSSamples()
	return tpsSamples
end

--[[----------------------------------------------------------
Arguments:
	integer - number of threat events to consider for TPS calculations
Notes:
	Default is 15

	A larger sample size will produce a TPS reading for a longer slice of combat, which means that it'll be more stable, but won't reflect your TPS-at-the-moment as accurately.
------------------------------------------------------------]]
function ThreatLib:SetTPSSamples(samples)
	tpsSamples = tonumber(samples)
end

local function ResetTPS(resetOn, force)
	if ThreatLib.inCombat and not force then return end
	ThreatLib:Debug("Resetting TPS on %s", resetOn)
	for k, v in pairs(tpsSigma) do
		for k2, v2 in pairs(v) do
			if resetOn then
				if k2 == resetOn and type(v2) == "table" then
					v[k2] = del(v2)
				end				
			else
				if type(v2) == "table" then
					v[k2] = del(v2)
				end
			end
		end
		v["FIGHT_START"] = GetTime()
		if not resetOn then
			tpsSigma[k] = del(v)
		end
	end
end
-- ThreatLib.ResetTPS = ResetTPS -- for profiling

local NPCCore
-- #NODOC
function ThreatLib:OnInitialize()
	self.WowVersion, self.WowMajor, self.WowMinor = (GetBuildInfo()):match("(%d).(%d).(%d)")
	self.WowVersion, self.WowMajor, self.WowMinor = tonumber(self.WowVersion), tonumber(self.WowMajor), tonumber(self.WowMinor)
	
	ThreatKLHTMSupport = self:GetModule("KLHTMSupport")
	self:UnregisterAllEvents()
	self:UnregisterAllComms()

	self.commPrefix = "Thr"
	self.userAgent = "Threat-1.0"
	self:SetCommPrefix(self.commPrefix)

	self:RegisterMemoizations({
		"CLIENT_INFO",
		"LEFT_COMBAT",
		"MISDIRECT_THREAT",
		"MOB_NAME_TRANSLATION_REQUEST",
		"MOB_NAME_TRANSLATION_REPLY",
		"RAID_MOB_THREAT_WIPE",
		"NEW_ENCOUNTER_MOB",
		"REQUEST_CLIENT_INFO",
		"THREAT_UPDATE",
		"WIPE_ALL_THREAT",
		"ACTIVATE_NPC_MODULE",
		"SET_NPC_MODULE_VALUE"
	})
	
	self:RegisterComm(self.commPrefix, "GROUP", "OnCommReceive")
	self:RegisterComm(self.commPrefix, "GUILD", "OnCommReceiveGuild")
	self:RegisterComm(self.commPrefix, "WHISPER", "OnCommReceiveWhisper")
	self:SetDefaultCommPriority("ALERT")
	self:ThreatInitData()

	latestSeenRevision = MINOR_VERSION
	
	self.GlobalTarget = "GLOBAL"
	PUBLIC_GLOBAL_HASH = TailoredBinaryCheckSum[self.GlobalTarget]
	
	self.inCombat = InCombatLockdown()
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD")
	
	self.LogEvents = false
	self.DebugEnabled = false
	
	for name, mod in pairs(modules) do
		if mod.OnInitialize then
			mod:OnInitialize()
		end
	end
	
	NPCCore = self:GetModule("NPCCore")
	
	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	else
		self:RegisterEvent("AceEvent_FullyInitialized")
	end
end

local console = AceLibrary:HasInstance("AceConsole-2.0") and AceLibrary("AceConsole-2.0")
-- #NODOC
function ThreatLib:Debug(msg, ...)
	if self.DebugEnabled then
		local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = ...
		if _G.ChatFrame5 then
			_G.ChatFrame5:AddMessage(("|cffffcc00ThreatLib-Debug: |r" .. msg):format( 
				tostring(a),
				tostring(b),
				tostring(c),
				tostring(d),
				tostring(e),
				tostring(f),
				tostring(g),
				tostring(h),
				tostring(i),
				tostring(j),
				tostring(k),
				tostring(l),
				tostring(m),
				tostring(n),
				tostring(o),
				tostring(p)				
			))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ThreatLib-Debug: |rPlease create ChatFrame5 for ThreatLib debug messages.")
		end
	end
end

-- #NODOC
function ThreatLib:DebugLiteral(msg)
	if self.DebugEnabled then
		if console then
			console:PrintLiteral(msg)
		end
	end
end

local RockEvent
local AceEvent
function ThreatLib.dispatchEvent(name, ...)
	if not RockEvent then
		if AceLibrary:HasInstance("LibRockEvent-1.0") then
			RockEvent = AceLibrary("LibRockEvent-1.0")
		end
	end
	if not AceEvent then
		if AceLibrary:HasInstance("AceEvent-2.0") then
			AceEvent = AceLibrary("AceEvent-2.0")
		end
	end
	if RockEvent then
		RockEvent:DispatchNamespaceEvent(MAJOR_VERSION, name, ...)
	end
	if AceEvent then
		AceEvent:TriggerEvent("Threat_" .. name, ...)
	end
end
------------------------------------------------------------------------
-- Handled events
------------------------------------------------------------------------
function ThreatLib:PLAYER_ENTERING_WORLD()
	local previousRunning = self.running
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp" or kind == "arena") and GetRealZoneText() ~= L["Alterac Valley"] then
		-- in a battleground that is not AV.
		self.running = false
	elseif IsResting() then
		-- in a city/inn
		self.running = false
	elseif not self.alwaysRunOnSolo and not UnitExists("pet") and GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
		-- all alone
		self.running = false
	else
		self.running = true
	end
	if previousRunning ~= self.running then
		if self.running then
			self.dispatchEvent("Activate")
		else
			self.dispatchEvent("Deactivate")
		end
	end
end

function ThreatLib:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	if self:IsEventScheduled("Threat_ResetTPSTimerTables") then
		self:CancelScheduledEvent("Threat_ResetTPSTimerTables")
	end
	if self:IsEventScheduled("Threat_ResetThreat") then
		self:CancelScheduledEvent("Threat_ResetThreat")
	end
end

function ThreatLib:PLAYER_REGEN_ENABLED()
	self.inCombat = false
	self:ScheduleEvent("Threat_ResetTPSTimerTables", ResetTPS, 3)
	self:ScheduleEvent("Threat_ResetThreat", self._clearAllThreat, 5, self)
end

-- #NODOC
function ThreatLib:AceEvent_FullyInitialized()
	-- DEFAULT_CHAT_FRAME:AddMessage("|cffffff7fThreat-1.0|r is still in development, and may change, break, not work, kick your dog, or do any number of other things. Please update it (and mods that use it, like |cffffff7fOmen|r, |cffffff7fViolation|r, |cffffff7fAssessment|r, |cffffff7fPitBull|r or |cffffff7fAloft|r) often. This message will be removed once |cffffff7fThreat-1.0|r enters stable beta.")

	-- Do event registrations here, as a Blizzard bug seems to be causing lockups if these are registered too early
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_PET_CHANGED", "PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_LOGIN", "PARTY_MEMBERS_CHANGED")

	self:PARTY_MEMBERS_CHANGED()
	self:PLAYER_ENTERING_WORLD()

	self:SendPrioritizedCommMessage("NORMAL", "GROUP", "REQUEST_CLIENT_INFO", MyLocale, MINOR_VERSION, self.userAgent)
	if IsInGuild() then
		self:SendPrioritizedCommMessage("NORMAL", "GUILD", "REQUEST_CLIENT_INFO", MyLocale, MINOR_VERSION, self.userAgent)
	end
end

-- #NODOC
function ThreatLib:ThreatUpdated(target, threat, fromPet)
	local uName = playerName
	if fromPet and self:DoesPlayerHavePet() then
		uName = self:GetPetModule().petName
	end
	self:ThreatUpdatedForUnit(uName, TailoredBinaryCheckSum[target], threat)
	local t = GetTime()
	if not publishInterval then
		publishInterval = self:GetPublishInterval()
	end
	if t - lastPublishTime > publishInterval then
		lastPublishTime = t
		self:PublishThreat()
	end
	-- self:TriggerEvent("ThreatLib-ThreatUpdatesToPublish")
end

-- #NODOC
function ThreatLib:ThreatUpdatedForUnit(unitName, target, threat)
	-- self:ScheduleEvent("Threat_ResetTPSTimerTables", ResetTPS, 5)
	if not target then
		self:Debug("Got nil target in ThreatUpdatedForUnit for %s", unitName) 
		return
	end
	
	local pName = unitName
	UpdateTPS(pName, target, threat)

	if type(pName) ~= "string" then
		error(("Assertion failed: type(%s --[[pName]]) == %q, trace: %s"):format(toliteral(pName), "string", debugstack()))
	end
			
	local pUnit = partyUnits[pName]
	
	-- We may get a race condition when we receive data from KTM during login before the party's been scanned
	if not pUnit then
		self:Debug("pUnit is nil, unit name is %s", unitName)
		return
	end
	
	self:_setThreat(pName, target, threat)
	if target == GLOBAL_HASH then
		self.dispatchEvent("ThreatUpdated", pName, pUnit, self.GlobalTarget, self:GetThreat(pName, GLOBAL_HASH))
	else
		self.dispatchEvent("ThreatUpdated", pName, pUnit, target, self:GetThreat(pName,  target))
	end
end

-- #NODOC
function ThreatLib:UpdateParty()
	for k in pairs(partyUnits) do
		partyUnits[k] = nil
	end
	setmetatable(partyUnits, partyUnits_mt)
	
	local sizeBeforeUpdate = currentPartySize
	local numRaid = GetNumRaidMembers()
	if numRaid > 0 then
		inRaid = true
		inParty = true
		currentPartySize = numRaid
	else
		inRaid = false
		local numParty = GetNumPartyMembers()
		if numParty > 0 then
			inParty = true
			currentPartySize = numParty
		else
			inParty = false
			currentPartySize = 0
		end
	end
	
	if currentPartySize > sizeBeforeUpdate and currentPartySize > 0 then
		-- Let's be sociable and tell the newcomers about ourselves.
		self:PublishLocaleAndVersion("GROUP")
	elseif currentPartySize < sizeBeforeUpdate then
		-- Clear all displayed threat. This gets rid of threat vals for people that aren't in
		-- The party anymore, and gets repopulated for those that are on next received publish
		-- self:Debug("Party updated, clearing all threat")
		-- self:_clearAllThreat()
		
		-- Cancel existing clear requests, since this will get called multiple times per fight. Note that this line really needs to be removed if we ever use :ScheduleLeaveCombatAction() elsewhere. 
		self:CancelAllCombatSchedules()
		--[[
		if InCombatLockdown() then
			self:ScheduleLeaveCombatAction(self, "_clearAllThreat")
		else
			self:_clearAllThreat()
		end	
		]]--
	end
	self.dispatchEvent("PartyChanged")
	
	publishInterval = self:GetPublishInterval()
	self:PLAYER_ENTERING_WORLD()
end

local PLAYER_PET_NAME = nil
function ThreatLib:UNIT_PET()
	if not UnitExists("pet") and PLAYER_PET_NAME then
		self:_clearThreat(PLAYER_PET_NAME)
	elseif UnitExists("pet") then
		PLAYER_PET_NAME = UnitName("pet")
	end
	self:PARTY_MEMBERS_CHANGED()
end

function ThreatLib:PARTY_MEMBERS_CHANGED()
	self:ScheduleEvent("ThreatLibUpdateParty", self.UpdateParty, 0.5, self)
end
------------------------------------------------------------------------
-- Handled chat messages
------------------------------------------------------------------------

function ThreatLib.OnCommReceive:THREAT_UPDATE(prefix, sender, distribution, playerDict, petDict)
	-- playerDict can be nil or a table with the form { targetHash = threatValue }
	-- petDict is the same as playerHash, only for pet.
	if (playerDict and type(playerDict) ~= "table") or (petDict and type(petDict) ~= "table") then
		return
	end

	-- sender not exist in partyUnit table somehow..
	local senderUnit = partyUnits[sender]
	if not senderUnit then
		return
	end
	
	if playerDict then
		local unit = senderUnit
		for target, threat in pairs(playerDict) do
			target = self:TranslateForeignMobHash(target)
			-- self:Debug("Updated %s's threat on %s: %s", sender, target, threat)
			self:ThreatUpdatedForUnit(sender, target, threat)
		end
	end
	
	if petDict then
		local unit = senderUnit .. "pet"
		local petName = UnitName(unit)
		if petName == "Unknown" then
			self:Debug("Alert! Pet name is %q [pet->party damage]", petName)
		end
		if petName then
			for target, threat in pairs(petDict) do
				target = self:TranslateForeignMobHash(target)
				-- self:Debug("Updated %s's threat on %s: %s", petName, target, threat)
				self:ThreatUpdatedForUnit(petName, target, threat)
			end
		end
	end
end

function ThreatLib.OnCommReceive:LEFT_COMBAT(prefix, sender, distribution, playerLeft, petLeft)
	local senderUnit = partyUnits[sender]
	if not senderUnit then return end
	local petName
	if playerLeft then
		if partyUnits[sender] then
			petName = UnitName(partyUnits[sender] .. "pet")
		end
		self:_clearThreat(sender)
	end
	
	if petLeft and petName then
		self:_clearThreat(petName)
	end
end

local function func(self)
	local playerModule = self:GetPlayerModule()
	local petModule = self:GetPetModule()
	playerModule:_reduceAllThreat(0)

	if self:DoesPlayerHavePet() then
		petModule:_reduceAllThreat(0)
	end

	for k, v in pairs(globalPlayerThreatAdjustments) do
		globalPlayerThreatAdjustments[k] = nil
	end

	for k, v in pairs(globalPetThreatAdjustments) do
		globalPetThreatAdjustments[k] = nil
	end
	
	ResetTPS(nil, true)
	self:ClearStoredThreatTables()
	self.dispatchEvent("ThreatCleared")
	self:PublishThreat(true)
end
function ThreatLib.OnCommReceive:WIPE_ALL_THREAT(prefix, sender, distribution)
	self:Debug("Got a clear request from %s", sender)
	local senderUnit = partyUnits[sender]
	if not senderUnit then
		if sender == playerName then
			senderUnit = "player"
		else
			return
		end
	end
	if IsGroupOfficer(senderUnit) then
		self:Debug("%s (%s) is an officer, scheduling clear", sender, senderUnit)
		self:ScheduleEvent(
			"ThreatLibThreatWipe",
			func,
			0.35, 
			self
		)	
	else
		self:Debug("%s (%s) is NOT an officer, ignoring clear", sender, senderUnit)
	end
end

local cooldownTimes = {}
local function func(self, m)
	-- Get global threat offset
	self:Debug("Clearing threat on %s [delay]", m)
	local tHash = TailoredBinaryCheckSum[m]
	
	local playerModule = self:GetPlayerModule()
	if threatTargets[playerName] then
		globalPlayerThreatAdjustments[tHash] = threatTargets[playerName][GLOBAL_HASH] or 0
		self:Debug("Set %s's threat adjustment on %s to %s", playerName, m, globalPlayerThreatAdjustments[tHash])
	end
	playerModule:_setTargetThreat(0, m)
	self:Debug("Player's threat on %s is %s", m, playerModule.targetThreat[m])
	
	if self:DoesPlayerHavePet() then
		local petModule = self:GetPetModule()
		local petName = UnitName("pet")
		if petName and threatTargets[petName] then
			globalPetThreatAdjustments[tHash] = threatTargets[petName][GLOBAL_HASH] or 0
		end
		petModule:_setTargetThreat(0, m)
	end
	ResetTPS(m, true)
	self:PublishThreat(true)
	self:ClearStoredThreatTables(m)
end
function ThreatLib.OnCommReceive:RAID_MOB_THREAT_WIPE(prefix, sender, distribution, mobName)
	mobName = self:TranslateForeignMobName(mobName)
	self:Debug("Got RAID_MOB_THREAT_WIPE, %s, %s, %s, %s", prefix, sender, distribution, mobName)
	if type(mobName) ~= "string" then
		return
	end
	
	if not self:IsEventScheduled("ThreatLibMobRaidThreatWipe-" .. mobName) and GetTime() - (cooldownTimes[mobName] or 0) > 15 then
		cooldownTimes[mobName] = GetTime()
		self:ScheduleEvent(
			"ThreatLibMobRaidThreatWipe-" .. mobName,
			func,
			0.5,
			self,
			mobName
		)
	end
end

function ThreatLib:ClearStoredThreatTables(mobName)
	for k, v in pairs(threatTargets) do
		for k2, v2 in pairs(v) do
			if not mobName or mobName == k2 then
				v[k2] = 0
			end
		end
	end
end

local function zeroGlobalThreat(self, m)
	-- Get global threat offset
	ThreatLib:Debug("Got mob name for global clear: %s", m)
	local tHash = TailoredBinaryCheckSum[m]
	
	local playerModule = self:GetPlayerModule()
	if threatTargets[playerName] then
		globalPlayerThreatAdjustments[tHash] = threatTargets[playerName][GLOBAL_HASH] or 0
		ThreatLib:Debug("Removing %s threat from player on %s", globalPlayerThreatAdjustments[tHash], m)
	end
	
	if self:DoesPlayerHavePet() then
		local petModule = self:GetPetModule()
		local petName = petModule.petName
		if petName and threatTargets[petName] then
			globalPetThreatAdjustments[tHash] = threatTargets[petName][GLOBAL_HASH] or 0
			ThreatLib:Debug("Removing %s threat from pet on %s", globalPlayerThreatAdjustments[tHash], m)
		end
	end
end
function ThreatLib.OnCommReceive:NEW_ENCOUNTER_MOB(prefix, sender, distribution, mobName)
	if not ThreatLib.running then return end
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp" or kind == "arena") then
		return
	end
	
	if not mobName then
		error("Nil mob name received on NEW_ENCOUNTER_MOB from %s", sender)
	end
	local oldMobName = mobName
	mobName = self:TranslateForeignMobName(mobName)
	if not mobName then
		error("Nil mob name translation for %s in NEW_ENCOUNTER_MOB", oldMobName)
	end
	if NPCCore:AddEncounterEnemy(mobName) then
		if not partyUnits[mobName] then
			zeroGlobalThreat(self, mobName)
		end
	end
end

-- #NODOC
function ThreatLib:NewEncounterMob(mobName)
	if not ThreatLib.running then return end
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp" or kind == "arena") then
		return
	end

	if not mobName then
		error("Nil mob name translation for %s in :NewEncounterMob", oldMobName)
	end
	if NPCCore:AddEncounterEnemy(mobName) then
		if not partyUnits[mobName] then
			zeroGlobalThreat(self, mobName)
			self:SendCommMessage("GROUP", "NEW_ENCOUNTER_MOB", mobName)
		end
	end	
end

function ThreatLib.OnCommReceive:MISDIRECT_THREAT(prefix, sender, distribution, targetPlayer, targetEnemy, amount)
	if type(targetPlayer) ~= "string" or type(targetEnemy) ~= "string" or type(amount) ~= "number" then
		return
	end
	targetEnemy = self:TranslateForeignMobName(targetEnemy)
	local senderUnit = partyUnits[sender]
	if targetPlayer == playerName and senderUnit and select(2, UnitClass(senderUnit)) == "HUNTER" then
		self:GetModule("ClassCore").activeModule:_addTargetThreat(amount, targetEnemy)
	end
end

function ThreatLib.OnCommReceiveGuild:REQUEST_CLIENT_INFO(prefix, sender, distribution, locale, revision, useragent)
	if type(locale) ~= "string" or type(revision) ~= "number" then
		self:Debug("Invalid info request received from %s: locale %s, revision %s (%s, %s)", sender, locale, revision, type(locale), type(revision))
		return
	end

	self:PublishLocaleAndVersion("WHISPER", sender)
	if useragent == self.userAgent then
		self:CheckLatestRevision(revision, sender)
	end
end
function ThreatLib.OnCommReceive:REQUEST_CLIENT_INFO(prefix, sender, distribution, locale, revision, useragent)

	if type(locale) ~= "string" or type(revision) ~= "number" then
		self:Debug("Invalid info request received from %s: locale %s, revision %s (%s, %s)", sender, locale, revision, type(locale), type(revision))
		return
	end
	
	partyMemberAgents[sender] = useragent or "(Unknown agent)"
	partyMemberLocales[sender] = locale or "(Unknown)"
	partyMemberRevisions[sender] = revision or "(Unknown)"
	partyMemberUsesKLHTM[sender] = nil
	self:PublishLocaleAndVersion("WHISPER", sender)
	if useragent == self.userAgent then
		self:CheckLatestRevision(revision, sender)
	end
	self:ScheduleEvent("ThreatLibUpdatePartyLocaleSettings", self.UpdatePartyLocaleSettings, 0.5, self)		
end

function ThreatLib.OnCommReceiveWhisper:CLIENT_INFO(prefix, sender, distribution, locale, revision, useragent)
	ThreatLib.OnCommReceive.CLIENT_INFO(ThreatLib, prefix, sender, distribution, locale, revision, useragent)
end

function ThreatLib.OnCommReceive:CLIENT_INFO(prefix, sender, distribution, locale, revision, useragent)
	if type(locale) ~= "string" or type(revision) ~= "number" then
		self:Debug("Invalid client info received from %s: locale %s, revision %s (%s, %s)", sender, locale, revision, type(locale), type(revision))
		return
	end
	self:Debug("Received client info from %s: locale %s, revision %s [distribution: %s]", sender, locale, revision, distribution)
	partyMemberAgents[sender] = useragent or "(Unknown agent)"
	partyMemberLocales[sender] = locale or "(Unknown)"
	partyMemberRevisions[sender] = revision or "(Unknown)"
	partyMemberUsesKLHTM[sender] = nil
	if useragent == self.userAgent then
		self:CheckLatestRevision(revision, sender)
	end
	self:ScheduleEvent("ThreatLibUpdatePartyLocaleSettings", self.UpdatePartyLocaleSettings, 0.5, self)		
end

function ThreatLib.OnCommReceive:ACTIVATE_NPC_MODULE(prefix, sender, distribution, module_name)
	NPCCore:ActivateModule(module_name)
end

function ThreatLib.OnCommReceive:SET_NPC_MODULE_VALUE(prefix, sender, distribution, var_name, var_value)
	if not partyUnits[sender] then return end
	if IsGroupOfficer(partyUnits[sender]) then
		NPCCore:SetModuleVar(var_name, var_value)
		self:Debug("%s set variable %q = %q", sender, var_name, var_value)
	end
end

------------------------------------------------------------------------
-- Command invocation methods
------------------------------------------------------------------------

-- Arguments:
-- 	string - variable name to set
--	float - value to set for variable
function ThreatLib:SetNPCModuleValue(var_name, var_value)
	if IsGroupOfficer("player") then
		self:SendCommMessage("GROUP", "SET_NPC_MODULE_VALUE", var_name, var_value)
		ThreatLib.OnCommReceive.SET_NPC_MODULE_VALUE(self, nil, playerName, nil, var_name, var_value)
	end
end

-- #NODOC
function ThreatLib:NotifyGroupModuleActivate(module_name)
	self:SendCommMessage("GROUP", "ACTIVATE_NPC_MODULE", module_name)
end

------------------------------------------------------------------------
-- Internal Methods
------------------------------------------------------------------------

-- #NODOC
function ThreatLib:_getTargetHash(target)
	return TailoredBinaryCheckSum[target]
end

-- #NODOC
function ThreatLib:_setThreat(sender, target, threat)
	if not sender then
		self:Debug("Invalid sender to _setThreat!")
		self:Debug(debugstack())
		return
	end
	local data = threatTargets[sender]
	if not data then
		data = new()
		threatTargets[sender] = data
	end	
	data[target] = threat
end

-- #NODOC
function ThreatLib:_clearAllThreat()
	-- These do the standard clear but also comm that back to the group
	self:_clearThreat(playerName)
	self:_clearThreat(PLAYER_PET_NAME)
	
	for k,v in pairs(threatTargets) do
		threatTargets[k] = del(v)
	end	
	
	for k,v in pairs(lastPublishedPlayerThreat) do
		lastPublishedPlayerThreat[k] = nil
	end
	for k,v in pairs(lastPublishedPetThreat) do
		lastPublishedPetThreat[k] = nil
	end
	
	self:CancelAllCombatSchedules()
	
	-- self:Debug("Clearing ALL threat!")
	self.dispatchEvent("ThreatCleared")
end

-------------------------------------------------------
-- Arguments:
--	string - name of the player to get TPS for
--	string - name of the target to get TPS on
-- Returns:
--	* Local TPS (float)
--	* Encounter TPS (float)
-------------------------------------------------------
function ThreatLib:GetTPS(player, target)
	target = TailoredBinaryCheckSum[target]
	local pSigma = tpsSigma[player] 
	if not pSigma then return 0, 0 end
	-- self:Debug("Target is global: %s (%s, %s)", target == PUBLIC_GLOBAL_HASH, target, PUBLIC_GLOBAL_HASH)
	local gTPS = pSigma[GLOBAL_HASH]
	local tt = GetTime()
	if target == GLOBAL_HASH or target == PUBLIC_GLOBAL_HASH then
		if not gTPS then return 0, 0 end
		local td = tt - gTPS[#gTPS]
		return gTPS[1] * max(0, (1 - (td / 10))), gTPS[2] / (tt - pSigma["FIGHT_START"])
	else		
		local tTPS = pSigma[target]
		local td, gd, ftd, fgd = 0, 0, 0, 0
		if tTPS then
			local ttd = tt - tTPS[#tTPS]
			td = tTPS[1] * max(0, (1 - (ttd / 10)))
			ftd = tTPS[2] / (tt - pSigma["FIGHT_START"])
		end
		if gTPS then
			local gtd = tt - gTPS[#gTPS]
			gd = gTPS[1] * max(0, (1 - (gtd / 10)))
			fgd = gTPS[2] / (tt - pSigma["FIGHT_START"])
		end
		return td + gd, ftd + fgd
	end
end

-- #NODOC
function ThreatLib:_clearThreat(player)
	player = player or playerName
	
	if tpsSigma[player] then
		tpsSigma[player] = del(tpsSigma[player])
	end
	
	local data = threatTargets[player]
	if not data then
		return
	end
	
	-- data[GLOBAL_HASH] = 0
	for k,v in pairs(data) do
		data[k] = nil
	end
	
	if type(player) ~= "string" then
		error(("Assertion failed: type(%s --[[player]]) == %q"):format(toliteral(player), "string"))
	end
	local partyUnit = partyUnits[player]
	if type(partyUnit) ~= "string" then
		-- This can happen if we end up trying to clear threat for a pet that has despawned and gave us "Unknown" as a unit name.
		-- error(("Assertion failed: type(%s --[=[partyUnits[player]]=]) == %q (unitname: %s)"):format(toliteral(partyUnits[player]), "string", player))
		-- Fail silently.
		return
	end
	-- self:Debug("Cleared threat on %s (%s)", player, partyUnits[player])
	if UnitIsUnit(partyUnit, "player") then
		for k,v in pairs(lastPublishedPlayerThreat) do
			lastPublishedPlayerThreat[k] = nil
		end
		for k,v in pairs(globalPlayerThreatAdjustments) do
			globalPlayerThreatAdjustments[k] = nil
		end			
	elseif UnitIsUnit(partyUnit, "pet") then
		for k,v in pairs(lastPublishedPetThreat) do
			lastPublishedPlayerThreat[k] = nil
		end
		for k,v in pairs(globalPetThreatAdjustments) do
			globalPetThreatAdjustments[k] = nil
		end	
	end
	
	threatTargets[player] = del(data)
	ThreatKLHTMSupport:PublishThreatToKLHTM()
	self:ThreatUpdatedForUnit(player, GLOBAL_HASH, 0)
	-- self.dispatchEvent("ThreatUpdated", player, partyUnit, self.GlobalTarget, 0)
end

-------------------------------------------------------
-- Arguments:
--	boolean - Whether or not to publish threat updates
-- Notes:
--	Toggles threat publishes on and off, in case you don't want to send
--	threat values to your group for some reason
-------------------------------------------------------
function ThreatLib:ToggleThreatPublish(val)
	dontPublishThreat = not val
end

-- #NODOC
function ThreatLib:PublishThreat(force)	
	if (not inParty and not inRaid) or dontPublishThreat then return end
	
	local playerHash = new()
	local petHash = new()
	
	local playerChanged, petChanged = false, false
	
	local activeModule = self:GetPlayerModule()
	local globalThreat = activeModule.generalThreat or 0
	local GLOBAL_TARGET = self.GlobalTarget

	for k, v in pairs(activeModule.targetThreat) do
		if k and k ~= "_GLOBAL_" then
			local total = v
			local tHash = TailoredBinaryCheckSum[k]
			local gOffset = globalPlayerThreatAdjustments[tHash] or 0
			local threat = math_floor(total - gOffset)
			if lastPublishedPlayerThreat[tHash] ~= threat or force then
				playerHash[tHash] = threat
				lastPublishedPlayerThreat[tHash] = threat
			end
		end
	end
	local threat = math_floor(globalThreat)
	if lastPublishedPlayerThreat[GLOBAL_HASH] ~= threat or force then
		playerHash[GLOBAL_HASH] = threat
		lastPublishedPlayerThreat[GLOBAL_HASH] = threat
	end
	
	if self:DoesPlayerHavePet() then
		activeModule = self:GetPetModule()
		globalThreat = activeModule.generalThreat or 0
		if activeModule.targetThreat == nil then
			
		end
		for k, v in pairs(activeModule.targetThreat) do
			if k and k ~= "_GLOBAL_" then
				local total = v
				local tHash = TailoredBinaryCheckSum[k]
				local gOffset = globalPetThreatAdjustments[tHash] or 0
				local threat = math_floor(total - gOffset)
				if lastPublishedPetThreat[tHash] ~= threat or force then
					petHash[tHash] = threat
					lastPublishedPetThreat[tHash] = threat
				end
			end
		end	
		local threat = math_floor(globalThreat)
		if lastPublishedPetThreat[GLOBAL_HASH] ~= threat or force then
			petHash[GLOBAL_HASH] = threat
			lastPublishedPetThreat[GLOBAL_HASH] = threat
		end
	end
	
	if not next(playerHash) then
		playerHash = del(playerHash)
	end
	if not next(petHash) then
		petHash = del(petHash)
	end
	if playerHash or petHash then
		self:SendCommMessage("GROUP", "THREAT_UPDATE", playerHash, petHash)
		
		if playerHash then
			ThreatKLHTMSupport:PublishThreatToKLHTM()
			playerHash = del(playerHash)
		end
		if petHash then
			petHash = del(petHash)
		end
	end
end

-- #NODOC
function ThreatLib:GetPublishInterval()
	-- Scale publish interval from 0.5 to 1.5 based on party size
	-- We'll be at 0.5 sec for 0-5 party size, scale from 0.5 to 1.5 for 6-25 players, and stay at 1.5 for > 20 players
	-- This means that we'll transmit as much as 66% less data in a raid
	local pSize = currentPartySize
	local partyNum = math_max(0, pSize - 5)
	return math_min(2.5, 1 + (1 * (partyNum / 20)))
end

local function func()
	ThreatLib.dispatchEvent("OutOfDateNotice", MINOR_VERSION, latestSeenRevision, latestSeenSender)
end

-- #NODOC
function ThreatLib:CheckLatestRevision(revision, sender)
	if not revision then
		return -- needed for older clients
	end
	revision = tonumber(revision)
	if not revision then return end
	if revision > latestSeenRevision then
		latestSeenRevision = revision
		latestSeenSender = sender
		self:ScheduleEvent("ThreatLib_NotifyOutOfDate", func, 0.5)
	end
end

-- #NODOC
function ThreatLib:PublishLocaleAndVersion(distribution, whisperTo)
	partyMemberLocales[UnitName("player")] = MyLocale
	partyMemberAgents[UnitName("player")] = self.userAgent
	if distribution == "WHISPER" and whisperTo ~= nil then
		self:SendPrioritizedCommMessage("NORMAL", distribution, whisperTo, "CLIENT_INFO", MyLocale, MINOR_VERSION, self.userAgent)
	else
		self:SendPrioritizedCommMessage("NORMAL", distribution, "CLIENT_INFO", MyLocale, MINOR_VERSION, self.userAgent)
	end
end

-- #NODOC
function ThreatLib:UpdatePartyLocaleSettings()	
	local t = newHash()
	t[MyLocale] = true
	local ct = 1
	for k = 1, #partyForeignLocales do
		tremove(partyForeignLocales)
	end
	for k,v in pairs(partyMemberLocales) do
		if partyUnits[k] == nil then
			partyMemberLocales[k] = nil
		else
			if not t[v] then
				t[v] = true
				tinsert(partyForeignLocales, v)
				ct = ct + 1
			end
		end
	end
	self:DebugLiteral(t)
	t = del(t)
	partyMemberLocaleCount = ct
	self:Debug("Updating party locale settings")
	if ct > 1 then
		self:Debug("Enabling mob name translation")
		self:ToggleModuleActive("MobNameTranslation", true)
	else
		self:Debug("Disabling mob name translation")
		self:ToggleModuleActive("MobNameTranslation", false)
	end
end

------------------------------------------------------------------------
-- API Methods
------------------------------------------------------------------------

------------------------------------------------------------------------
-- :RequestThreatClear()
-- Notes:
-- Executes a raid-wide threat wipe
-- Must have privileges to execute this; you can clear your own, but other
-- clients are going to verify that you're allowed to do this
------------------------------------------------------------------------
function ThreatLib:RequestThreatClear()
	if IsGroupOfficer("player") then
		self:Debug("We're an officer - sending threat clear request and wiping our own threat.")
		self:SendCommMessage("GROUP", "WIPE_ALL_THREAT")
	else
		self:Debug("We aren't an officer - can't send clear request!")
	--	DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r - %s"):format(MAJOR_VERSION, L["You must be a raid officer or the raid leader to request a threat list clear."]))
	end
	self.OnCommReceive.WIPE_ALL_THREAT(self, self.commPrefix, playerName, "GROUP")
end

------------------------------------------------------------------------
-- :UnitIsUnit("unitNameOrHash", "unitNameOrHash")
-- Arguments: 
--  string - Unit name or hash to check
--  string - Unit name or hash to check
-- Notes:
-- Checks to see if a unit's name matches a unit's hash. Since Threat_ThreatUpdated
-- sends hashes, you'll want to check a raw name against that hash with this method
------------------------------------------------------------------------
function ThreatLib:UnitIsUnit(a, b)
	if type(a) ~= "string" then
		error(("Bad argument #2 to `UnitIsUnit'. expected %q, got %q (%s)"):format("string", type(a), tostring(a)), 2)
	end
	if type(b) ~= "string" then
		error(("Bad argument #3 to `UnitIsUnit'. expected %q, got %q (%s)"):format("string", type(b), tostring(b)), 2)
	end
	local tostring_b = tostring(b)
	if TailoredBinaryCheckSum[a] == tostring_b then
		return true
	end
	local tostring_a = tostring(a)
	return tostring_a == tostring_b or TailoredBinaryCheckSum[b] == tostring_a
end

------------------------------------------------------------------------
-- :GetThreat("playerName", "targetName" or "targetHash")
-- Arguments: 
--  string - Name of the player or pet to get threat for
--  string - Name or hash of the target to get threat on
-- Notes:
-- Returns a float corresponding to the given player or pet's threat level on the given target
------------------------------------------------------------------------
function ThreatLib:GetThreat(player, target)
	if type(target) ~= "string" then
		error(("Bad argument #2 to `GetThreat'. expected %q, got %q (%s)"):format("string", type(target), tostring(target)), 2)
	end
	local data = threatTargets[player]
	if not data then
		return 0
	end
	local hash = TailoredBinaryCheckSum[target]
	local nThreat = data[hash] or data[target] or 0
	local gThreat = data[GLOBAL_HASH] or 0
	local gOffset = 0
	if player == playerName then
		gOffset = globalPlayerThreatAdjustments[hash] or globalPlayerThreatAdjustments[target] or 0
	elseif self:DoesPlayerHavePet() then
		if player == self:PetName() then
			gOffset = globalPetThreatAdjustments[hash] or globalPetThreatAdjustments[target] or 0
		end
	end
	if target == GLOBAL_HASH or target == "_GLOBAL_" or target == self.GlobalTarget then
		return math_max(0, gThreat - gOffset)
	else
		return math_max(0, nThreat + gThreat - gOffset)
	end
end

--[[------------------------------------------------------------
Arguments:
	string - player name to get cumulative threat for
Returns:
	integer - this player's cumulative threat in the encounter, suitable for publishing to KTM or similar
--------------------------------------------------------------]]
function ThreatLib:GetCumulativeThreat()
	local data = threatTargets[playerName]
	if not data then
		return 0
	end
	local totalThreat = 0
	for k, v in pairs(data) do
		totalThreat = totalThreat + v - (globalPlayerThreatAdjustments[k] or 0)
	end
	return math_max(0, totalThreat)
end

------------------------------------------------------------------------
-- :UnitInMeleeRange("unitID")
-- Arguments: 
--  string - UnitID to check melee range for
-- Notes:
-- Returns true if the unit is within 10 yards
------------------------------------------------------------------------
function ThreatLib:UnitInMeleeRange(unitID)
	return UnitExists(unitID) and UnitIsVisible(unitID) and CheckInteractDistance(unitID, 3)
end

------------------------------------------------------------------------
-- :GetPlayerModule()
-- Arguments: none
-- Notes:
-- Returns the currently active class module for the player.
-- Not generally needed by GUIs; may be needed by NPC core
------------------------------------------------------------------------
local activePlayerModule = nil
function ThreatLib:GetPlayerModule()
	if activePlayerModule then return activePlayerModule end
	activePlayerModule = self:GetModule("ClassCore").activeModule
	return activePlayerModule
end

------------------------------------------------------------------------
-- :DoesPlayerHavePet()
-- Arguments: none
-- Notes:
-- Returns true if the player has a pet and an active pet module
------------------------------------------------------------------------
local PETMODULE
function ThreatLib:DoesPlayerHavePet()
	if not PETMODULE then
		PETMODULE = self:GetModule("ClassCore").petModule
	end
	return PETMODULE ~= nil and PETMODULE.petName ~= nil and PETMODULE.unitType ~= nil
end

function ThreatLib:PetName()
	if not PETMODULE then
		PETMODULE = self:GetModule("ClassCore").petModule
	end
	return PETMODULE and PETMODULE.petName or nil
end

------------------------------------------------------------------------
-- :GetPetModule()
-- Arguments: none
-- Notes:
-- Returns the currently active class module for the pet.
-- Not generally needed by GUIs; may be needed by NPC core
------------------------------------------------------------------------
function ThreatLib:GetPetModule()
	if not PETMODULE then
		PETMODULE = self:GetModule("ClassCore").petModule
	end
	return PETMODULE
end

------------------------------------------------------------------------
-- :EncounterMobs()
-- Arguments: none
-- Notes:
-- Returns the number of mobs in the current encounter as specified by the NPC
-- core. Not generally needed by GUIs; may be needed by Class core
------------------------------------------------------------------------
function ThreatLib:EncounterMobs()
	return math_max(1, NPCCore.encounterMobCount or 1)
end

------------------------------------------------------------------------
-- :IterateGroupThreatForTarget("targetName" or "targetHash")
-- Arguments: string - name or hash of the target to iterate threat on
-- Notes:
-- Returns a list of all group members and their threat levels on the given
-- mob, sorted descending by threat value
------------------------------------------------------------------------
do
	local sortThreatDesc_values
	local function sortThreatDesc(alpha, bravo)
		return sortThreatDesc_values[alpha] > sortThreatDesc_values[bravo]
	end

	local function threatIter(t, key)
		local n = t.n + 1
		local k = t[n]
		if k == nil then
			del(t.values)
			del(t)
			return nil
		end
		t.n = n
		return k, t.values[k]
	end

	function ThreatLib:IterateGroupThreatForTarget(target)
		if type(target) ~= "string" then
			error(("Bad argument #2 to `IterateGroupThreatForTarget`. expected %q, got %q (%s)"):format("string", type(target), tostring(target)), 2)
		end
		local results = new()
		local tHash = TailoredBinaryCheckSum[target]
		local t = new()
		for k, v in pairs(threatTargets) do
			local gThreat = v[GLOBAL_HASH] or 0
			local gOffset = 0
			if k == playerName then
				gOffset = globalPlayerThreatAdjustments[tHash] or 0
			elseif self:DoesPlayerHavePet() then
				if k == self:PetName() then
					gOffset = globalPetThreatAdjustments[tHash] or 0
				end
			end
			if target == self.GlobalTarget or target == GLOBAL_HASH or tHash == GLOBAL_HASH then
				t[#t+1] = k
				results[k] = gThreat - gOffset
			elseif v[tHash] then
				t[#t+1] = k
				results[k] = v[tHash] + gThreat - gOffset
			end
		end
		sortThreatDesc_values = results
		table_sort(t, sortThreatDesc)
		sortThreatDesc_values = nil
		t.values = results
		t.n = 0
		return threatIter, t, nil
	end
end

------------------------------------------------------------------------
-- :GetUnitIDByUnitName("unitName")
-- Arguments: string - name of the group member to get a unit ID for
-- Notes:
-- Returns a group id ("player3", "raid4pet") for the given name, nil if not found
------------------------------------------------------------------------
function ThreatLib:GetUnitIDByUnitName(unitName)
	return partyUnits[unitName]
end

------------------------------------------------------------------------
-- :GetMaxThreatOnTarget("unitName")
-- Arguments: string - name of the target to get max threat one.
-- Notes:
-- Returns the maximum threat value and the name of the player with the maximum threat
-- on the given target
------------------------------------------------------------------------
function ThreatLib:GetMaxThreatOnTarget(target)
	if type(target) ~= "string" then
		error(("Bad argument #2 to `GetMaxThreatOnTarget`. expected %q, got %q (%s)"):format("string", type(target), tostring(target)), 2)
	end
	local maxVal = 0
	local maxname = nil
	for k in pairs(threatTargets) do
		local v = self:GetThreat(k, target)
		if v > maxVal then
			maxVal = v
			maxname = k
		end
	end
	return maxVal, maxname
end

------------------------------------------------------------------------
-- :SendThreatTo("nameOfGroupMember", "enemyName", threatValue)
-- Arguments:
--   string - name of the group member to send threat to
--   string - name of the enemy to send threat for
--   float  - amount of threat to send
-- Notes:
-- Sends a given amount of threat to a group member. Used for Misdirection.
-- Not needed by GUIs.
------------------------------------------------------------------------
function ThreatLib:SendThreatTo(targetPlayer, targetEnemy, threat)
	if type(targetPlayer) ~= "string" then
		error(("Bad argument #2 to `SendThreatTo`. expected %q, got %q (%s)"):format("string", type(targetPlayer), tostring(targetPlayer)), 2)
	end
	
	if self:DoesPlayerHavePet() and self:GetPetModule().petName == targetPlayer then
		self:GetPetModule():_addTargetThreat(threat, targetEnemy)
	elseif partyMemberUsesKLHTM[targetPlayer] then
		ThreatKLHTMSupport:MisdirectToKLHTM(targetPlayer, threat)
	else
		self:SendCommMessage("GROUP", "MISDIRECT_THREAT", targetPlayer, targetEnemy, threat)
	end
end

------------------------------------------------------------------------
-- :WipeRaidThreatOnMob("mobName")
-- Arguments:
--   string - name of the enemy to ask the group to wipe threat on
-- Notes:
-- Sends a comm message to the group instructing them to wipe their threat
-- levels on a specific mob. This is not protected as it needs to be able to 
-- be executed by anyone who sees the relevant events.
--
-- KTM protects this by requiring 2 or more people to send the event before
-- it is processed.
------------------------------------------------------------------------
function ThreatLib:WipeRaidThreatOnMob(mob)
	self:Debug("Wiping threat on %s", mob)
	self:SendCommMessage("GROUP", "RAID_MOB_THREAT_WIPE", mob)
	self.OnCommReceive.RAID_MOB_THREAT_WIPE(self, nil, nil, nil, mob)
end

------------------------------------------------------------------------
-- :IsUsingForeignThreatSource("partyMemberName")
-- Arguments:
--   string - name of the party member to check
-- Notes:
-- Returns a boolean indicating whether the given party member is using ThreatLib (false)
-- or an external source like KTM (true)
------------------------------------------------------------------------
function ThreatLib:IsUsingForeignThreatSource(partyMember)
	local partyUnit = partyUnits[partyMember]
	if not partyUnit then
		return true
	end
	partyUnit = partyUnit:gsub("pet", "")
	if partyUnit == "player" or partyUnit == "" then
		return false
	end
	
	local partyMemberName = UnitName(partyUnit)
	
	local r = not partyMemberRevisions[partyMemberName]
	return r
end

------------------------------------------------------------------------
-- :IsOutOfDate(["partyMemberName"])
-- Arguments:
--   string - name of the party member to check
-- Returns:
--   * boolean - whether the given party member is using an out-of-date ThreatLib or not
--   * integer - our version number
--   * integer - the latest revision number we've seen
--   * string  - the name of the person holding the latest revision
------------------------------------------------------------------------
function ThreatLib:IsOutOfDate(name)
	if name == nil or name == playerName then
		if latestSeenSender then
			return true, MINOR_VERSION, latestSeenRevision, latestSeenSender
		else
			return false, MINOR_VERSION, MINOR_VERSION, playerName
		end
	elseif not partyMemberRevisions[name] then
		return true, 0, latestSeenRevision, latestSeenSender or playerName
	else
		local num = partyMemberRevisions[name]
		if num < latestSeenRevision then
			return true, num, latestSeenRevision, latestSeenSender or playerName
		else
			return false, num, num, name
		end
	end
end

------------------------------------------------------------------------
-- :RequestActiveOnSolo([value])
-- Arguments:
--   boolean - whether to be activated. Default: true
-- Notes:
--   This is meant to be called by a GUI to allow for testing in solo situations.
------------------------------------------------------------------------
function ThreatLib:RequestActiveOnSolo(value)
	if value == nil then
		value = true
	end
	self.alwaysRunOnSolo = value
	self:PLAYER_ENTERING_WORLD()
end

------------------------------------------------------------------------
-- :IsActive()
-- Returns:
--   boolean - whether Threat-1.0 is currently activated.
------------------------------------------------------------------------
function ThreatLib:IsActive()
	return self.running or false
end

------------------------------------------------------------------------
-- Notes:
--	Returns a pre-formatted hash of party revisions suitable for printing
------------------------------------------------------------------------
local revCopy = {}
function ThreatLib:GetPartyRevisions()
	for k,v in pairs(revCopy) do
		revCopy[k] = nil
	end
	
	local raidNum = GetNumRaidMembers()
	local partyNum = GetNumPartyMembers()
	local prefix = ""
	local inum = 0
	
	if raidNum > 0 then
		prefix = "raid"
		inum = raidNum
	elseif partyNum > 0 then
		prefix = "party"
		inum = partyNum
	else
		prefix = "player"
		inum = 0
	end
	for i = 1, inum do
		local v = prefix .. i
		local k = UnitName(v)
		if not UnitIsUnit(v, "player") then
			local str = ""
			if partyMemberAgents[k] == self.userAgent and LAST_BACKWARDS_COMPATIBLE_REVISION > partyMemberRevisions[k] then
				str = ("%s v%s |cffff0000- Not compatible!|r"):format(partyMemberAgents[k], partyMemberRevisions[k])
			elseif partyMemberRevisions[k] then
				str = ("%s v%s"):format(partyMemberAgents[k], partyMemberRevisions[k])
			else
				str = "|cffffff00Not using Threat-1.0 or compatible agent|r"
			end
			revCopy[k] = str
		end
	end
	return revCopy
end

------------------------------------------------
-- Debugging methods
------------------------------------------------

------------------------------------------------
-- Arguments:
--	[optional] string - player to dump the threat table for
-- Notes:
--	Prints the current threat table to the console
------------------------------------------------
function ThreatLib:DumpThreatTable(sender)
	if not AceLibrary:HasInstance("AceConsole-2.0") then
		error("Threat:DumpThreatTable() requires AceConsole-2.0", 2)
	end
	if sender then
		AceLibrary("AceConsole-2.0"):PrintLiteral(threatTargets[sender])
	else
		AceLibrary("AceConsole-2.0"):PrintLiteral(threatTargets)
	end
end

function ThreatLib:DumpQueriedRevisions()
	if not AceLibrary:HasInstance("AceConsole-2.0") then
		error("Threat:DumpQueriedRevisions() requires AceConsole-2.0", 2)
	end
	AceLibrary("AceConsole-2.0"):PrintLiteral(partyMemberRevisions)
end

-- #NODOC
function ThreatLib:DumpEventLog(isFor)
	if isFor == "pet" then
		AceLibrary("AceConsole-2.0"):PrintLiteral(self:GetPetModule().EventLog)
	else
		AceLibrary("AceConsole-2.0"):PrintLiteral(self:GetPlayerModule().EventLog)
	end
end

-- #NODOC
function ThreatLib:SetFakeLocale(locale, suffix)
	MyLocale = locale
	self.targetSuffix = suffix
end

-- #NODOC
function ThreatLib:ClearEventLog(isFor)
	local t 
	if isFor == "pet" then
		t = self:GetPetModule().EventLog
	else
		t = self:GetPlayerModule().EventLog
	end
	for i = 1, #t do
		tremove(t)
	end
end

local PreUpvalueFixers = {}
ThreatLib.PreUpvalueFixers = PreUpvalueFixers
tinsert(PreUpvalueFixers, function()
	-- internal variables
	ThreatLib.new = nil
	ThreatLib.newHash = nil
	ThreatLib.newSet = nil
	ThreatLib.del = nil
	ThreatLib.partyUnits = nil
	ThreatLib.partyMemberUsesKLHTM = nil
	ThreatLib.partyMemberRevisions = nil
	ThreatLib.IsGroupOfficer = nil
	ThreatLib.TailoredBinaryCheckSum = nil
end)
local UpvalueFixers = {}
ThreatLib.UpvalueFixers = UpvalueFixers
tinsert(UpvalueFixers, function(lib, oldLib)
	ThreatLib = lib
	local _
	_, MINOR_VERSION = lib:GetLibraryVersion()
	
	UpvalueFixers[#UpvalueFixers+1] = function(lib)
		lib:OnInitialize()
	end
	
	-- values from last revision
	ThreatLib.alwaysRunOnSolo = oldLib and oldLib.alwaysRunOnSolo or false
	ThreatLib.commPrefix = oldLib and oldLib.commPrefix or nil
	local AceCommLib = AceLibrary("AceComm-2.0")
	if oldLib and oldLib.commPrefix then
		AceCommLib.prefixes[oldLib.commPrefix] = nil
		AceCommLib.prefixHashToText[oldLib.commPrefix] = nil		-- This only works because Threat uses a 3-letter prefix.
		AceCommLib.prefixTextToHash[oldLib.commPrefix] = nil
		AceCommLib.prefixMemoizations[oldLib.commPrefix] = nil
		AceCommLib.commPrefixes[lib] = nil
	end	
end)

end
