local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 49229 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local useParser40 = AceLibrary:HasInstance("LibParser-4.0")
local useParser30 = not useParser40 and AceLibrary:HasInstance("Parser-3.0")

local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet

local ThreatLib = _G.ThreatLib
local ThreatLibNPCModuleCore = nil
if useParser40 then
	ThreatLibNPCModuleCore = ThreatLib:NewModule("NPCCore", "AceEvent-2.0", "LibParser-4.0")
elseif useParser30 then
	ThreatLibNPCModuleCore = ThreatLib:NewModule("NPCCore", "AceEvent-2.0", "Parser-3.0")
else
	ThreatLibNPCModuleCore = ThreatLib:NewModule("NPCCore", "AceEvent-2.0")
end

local BB = AceLibrary("Babble-Boss-2.2")

local _G = _G
local GetLocale = _G.GetLocale
local pairs = _G.pairs
local next = _G.next
local type = _G.type
local pcall = _G.pcall
local geterrorhandler = _G.geterrorhandler
local select = _G.select
local error = _G.error
local setmetatable = _G.setmetatable
local UnitExists = _G.UnitExists
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitName = _G.UnitName
local math_max = _G.math.max
local AceLibrary = _G.AceLibrary

ThreatLibNPCModuleCore.modulePrototype = {}
local module_mt = {__index = ThreatLibNPCModuleCore.modulePrototype}

local function ToggleModuleActive(module, value)
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

local combatantToModule = {}
local registeredModules = {}
local moduleValueOverrides = {}
local moduleValues = {}
local knownNPCs = {}

function ThreatLibNPCModuleCore:RegisterModule(... --[[, func]])
	local n = select('#', ...)
	if n < 1 then
		error("Error registering module, must provide at least one combatant.", 2)
	end
	
	local name = ...
	
	if type(name) ~= "string" then
		error(("Bad argument #2 to `RegisterModule'. Expecting %q, got %q."):format("string", type(name)), 2)
	end

	if registeredModules[name] then
		error(("Error, module %q already registered"):format(name), 2)
	end
	
	for i = 1, n - 1 do
		local combatant = select(i, ...)
		if type(combatant) ~= "string" then
			error(("Bad argument #%d to `RegisterModule'. Expecting %q, got %q."):format(i + 1, "string", type(combatant)), 2)
		end
		if combatantToModule[combatant] then
			error(("Error registering module %q, as combatant %q is already registered to module %q."):format(name, combatant, combatantToModule[combatant]), 2)
		end
		combatantToModule[combatant] = name
	end
	
	local func = select(n, ...)
	if type(func) ~= "function" then
		error(("Bad argument #%d to `RegisterModule'. Expecting %q, got %q."):format(n + 1, "function", type(func)), 2)
	end
	
	registeredModules[name] = func
end

local function ModifyThreat(mob, target, multi, add)
	if type(mob) ~= "string" then
		error("Invalid parameter #1 to ModifyThreat: expected string, got %q", type(mob))
	end
	local module
	if target == "player" then
		module = ThreatLib:GetPlayerModule()
	elseif target == "pet" and ThreatLib:DoesPlayerHavePet() then
		module = ThreatLib:GetPetModule()
	end
	if module then
		ThreatLib:Debug("Multiplying %s's threat on %s by %s", target, mob, multi)
		module:_multiplyTargetThreat(multi, mob)
		module:_multiplyThreat(multi)
		module:_addTargetThreat(add, mob)
		module:_addThreat(add)
	end
end

function ThreatLibNPCModuleCore:OnInitialize()
	local L = ThreatLib.L
	self.activeModule = nil
	self.activeModuleName = nil
	self.generic_attacks = {}
	self.generic_attacks[L["Knock Away"]] = function(mob, target) ModifyThreat(mob, target, 0.5, 0) end
	self.generic_attacks[L["Wing Buffet"]] = function(mob, target) ModifyThreat(mob, target, 0.5, 0) end
	self.generic_attacks[L["Sand Blast"]] = function(mob, target) ModifyThreat(mob, target, 0, 0) end		
	self.ToggleModuleActive = ToggleModuleActive
	if useParser40 then
	
		-- Pick up any damage to or from us
		self:AddParserListener({
			eventType = "Damage",
			recipientID_not = false
		}, "addEnemyMob")
		self:AddParserListener({
			eventType = "Damage",
			sourceID_not = false
		}, "addEnemyMob")
		
		self:AddParserListener({
			eventType = "Damage",
			recipientID = "player"
		}, "parseMobAttack")
		self:AddParserListener({
			eventType = "Damage",
			recipientID = "pet"
		}, "parseMobAttack")	
		self:AddParserListener({
			eventType = "Death"
		}, "parseDeath")
	elseif useParser30 then
	
		-- Pick up any damage to or from us
		self:RegisterParserEvent({
			eventType = "Damage",
			recipientID_not = false
		}, "addEnemyMob")
		self:RegisterParserEvent({
			eventType = "Damage",
			sourceID_not = false
		}, "addEnemyMob")
		
		self:RegisterParserEvent({
			eventType = "Damage",
			recipientID = "player"
		}, "parseMobAttack")
		self:RegisterParserEvent({
			eventType = "Damage",
			recipientID = "pet"
		}, "parseMobAttack")	
		self:RegisterParserEvent({
			eventType = "Death"
		}, "parseDeath")
	else
		-- TODO: Parser-1.1 compat
	end
	
	self.encounterMobCount = 1
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	ThreatLib:ToggleModuleActive(self, true)
end

function ThreatLibNPCModuleCore:addEnemyMob(info)
	if not ThreatLib.running then return end
	if info.sourceName and not knownNPCs[info.sourceName] then
		ThreatLib:NewEncounterMob(info.sourceName)
	elseif info.recipientName and not knownNPCs[info.recipientName] then
		ThreatLib:NewEncounterMob(info.recipientName)
	end
end

function ThreatLibNPCModuleCore:parseMobAttack(info)
	if not ThreatLib.running then return end
	
	if self.activeModule and self.activeModule:parseMobAttack(info) then
		return
	end

	if self.generic_attacks[info.abilityName] then
		self.generic_attacks[info.abilityName](info.sourceName, info.recipientID)
	end	
end

function ThreatLibNPCModuleCore:parseDeath(info)
	if not ThreatLib.running then return end
	
	if self.activeModule then
		self.activeModule:parseDeath(info)
	end
end

local function activateModule(self, mobName, localActivation)
	if self.activeModuleName ~= combatantToModule[mobName] then
		if self.activeModule then
			ToggleModuleActive(self.activeModule, false)
		end
		
		local mod = setmetatable({ mixins = {} }, module_mt)
		mod.name = combatantToModule[mobName]
		local AceEvent = AceLibrary("AceEvent-2.0")
		if not mod.mixins[AceEvent] then
			mod.mixins[AceEvent] = true
			AceEvent:embed(mod)
		end
		if useParser40 then
			local Parser = AceLibrary("LibParser-4.0")
			if not mod.mixins[Parser] then
				mod.mixins[Parser] = true
				Parser:Embed(mod)
			end
		elseif useParser30 then
			local Parser = AceLibrary("Parser-3.0")
			if not mod.mixins[Parser] then
				mod.mixins[Parser] = true
				Parser:embed(mod)
			end
		end
		
		self.activeModuleName = mod.name
		ThreatLib:Debug("Activated %s module", mod.name)
		
		registeredModules[combatantToModule[mobName]](mod)
		
		mod:OnInitialize()		
		ToggleModuleActive(mod, true)
		if localActivation then
			ThreatLib:NotifyGroupModuleActivate(BB:GetReverseTranslation(mod.name))
		end
	end
end

local function checkUnit(self, unit, enteringCombat)
	if not UnitExists(unit) or UnitIsDeadOrGhost(unit) or UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
		return
	end
	local mobName = UnitName(unit)
	if not mobName then return end 
	if combatantToModule[mobName] then
		activateModule(self, mobName, true)
	end
	--[[
	if UnitAffectingCombat(unit) or (unit == "target" and enteringCombat) then
		ThreatLib:NewEncounterMob(mobName)
	end
	]]--
end

local function ClearKnownEnemies()
	for k,v in pairs(knownNPCs) do
		knownNPCs[k] = nil
	end
end

function ThreatLibNPCModuleCore:PLAYER_REGEN_DISABLED()
	if self:IsEventScheduled("ThreatLib_ClearKnownEnemies") then
		self:CancelScheduledEvent("ThreatLib_ClearKnownEnemies")
	end
end

function ThreatLibNPCModuleCore:PLAYER_REGEN_ENABLED()
	if not self:IsEventScheduled("ThreatLib_ClearKnownEnemies") then
		self:ScheduleEvent("ThreatLib_ClearKnownEnemies", ClearKnownEnemies, 3)
	end
end

function ThreatLibNPCModuleCore:AddEncounterEnemy(mobName)
	if knownNPCs[mobName] then return false end
	knownNPCs[mobName] = true
	return true
end

function ThreatLibNPCModuleCore:SetModuleVar(var, value)
	ThreatLib:Debug("Set %q = %s", var, value)
	moduleValueOverrides[var] = value
end

-- Mob name, when passed from a chat message, should be localized to English by the passer via GetReverseTranslation()
-- So, we can just translate it to our native locale
function ThreatLibNPCModuleCore:ActivateModule(mobName)
	local localizedMobName = BB[mobName]
	activateModule(self, localizedMobName, false)
end

function ThreatLibNPCModuleCore:UPDATE_MOUSEOVER_UNIT()
	if not ThreatLib.running then return end
	checkUnit(self, "mouseover")
end

function ThreatLibNPCModuleCore:PLAYER_TARGET_CHANGED()
	if not ThreatLib.running then return end
	checkUnit(self, "target")
end

function ThreatLibNPCModuleCore.modulePrototype:OnInitialize()
	self.chatEvents = {}
	self.encounterEnemies = {}
	self.attacks = {}
	self.encounterMobCount = 1
	self.translations = {}
	self:Init()
	self.ModifyThreat = ModifyThreat
end

local MY_LOCALE = GetLocale()
local BASE_LOCALE = "enUS"

local translations = {}
function ThreatLibNPCModuleCore.modulePrototype:RegisterTranslation(locale, translation)
	if locale ~= MY_LOCALE and locale ~= BASE_LOCALE then
		return
	end
	local m = translations[self.name]
	if not m then
		m = {}
		translations[self.name] = m
	end
	m[locale] = translation()
end

function ThreatLibNPCModuleCore.modulePrototype:UnregisterTranslations()
	translations[self.name] = nil
end

function ThreatLibNPCModuleCore.modulePrototype:GetTranslation(string)
	local selfName = self.name
	local data = translations[selfName]
	if not data then
		if ThreatLib.WarnMissingTranslations then
			error("Threat-1.0: No translations registered for " .. selfName)
		end
		return
	end
	local data_MY_LOCALE = data[MY_LOCALE]
	if not data_MY_LOCALE then
		if ThreatLib.WarnMissingTranslations then
			error(("Threat-1.0: Missing %s translation for %q in module %q"):format(MY_LOCALE, string, selfName))
		end
		local data_BASE_LOCALE = data[BASE_LOCALE]
		if data_BASE_LOCALE then
			return data_BASE_LOCALE[string]
		end
	end
	local data_MY_LOCALE_string = data_MY_LOCALE[string]
	if data_MY_LOCALE_string == true then
		return string
	end
	return data_MY_LOCALE_string
end

function ThreatLibNPCModuleCore.modulePrototype:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	ThreatLibNPCModuleCore.activeModule = self
end

function ThreatLibNPCModuleCore.modulePrototype:OnDisable()
	ThreatLibNPCModuleCore.activeModule = nil
	ThreatLibNPCModuleCore.activeModuleName = nil
end

function ThreatLibNPCModuleCore.modulePrototype:parseDeath(info)
	if not ThreatLib.running then
		return
	end
	if not ThreatLib.inCombat then
		return
	end
	local recipientName = info.recipientName
	local func = self.encounterEnemies[recipientName]
	if func then
		func(self, recipientName, info.sourceName)
		self:TriggerEvent("ThreatLib_BossDeath", recipientName)
	end
end

function ThreatLibNPCModuleCore.modulePrototype:parseMobAttack(info)
	if not ThreatLib.running then
		return
	end
	if not ThreatLib.inCombat then
		return
	end
	local func = self.attacks[info.abilityName]
	if func then
		func(self, info.sourceName, info.recipientID)
		return true
	end
end

function ThreatLibNPCModuleCore.modulePrototype:CHAT_MSG_MONSTER_EMOTE(arg1, arg2)
	if not ThreatLib.running then
		return
	end
	local emote = self.chatEvents.emote
	if not emote then
		return
	end
	local mob = emote[arg2]
	if not mob then
		return
	end
	local func = mob[arg1]
	if not func then
		return
	end
	func(self)
end

function ThreatLibNPCModuleCore.modulePrototype:CHAT_MSG_MONSTER_YELL(arg1, arg2)
	if not ThreatLib.running then
		return
	end
	local yell = self.chatEvents.yell
	if not yell then
		return
	end
	
	local mob = yell[arg2]
	if not mob then
		return
	end

	local func = mob[arg1]
	if not func then
		return
	end
	func(self)
end

function ThreatLibNPCModuleCore.modulePrototype:PLAYER_REGEN_ENABLED()
	self:ScheduleEvent("NPCModuleCoreResetMobCount" .. self.name, "ResetFight", 5)
end

function ThreatLibNPCModuleCore.modulePrototype:PLAYER_REGEN_DISABLED()
	if self:IsEventScheduled("NPCModuleCoreResetMobCount" .. self.name) then
		self:CancelScheduledEvent("NPCModuleCoreResetMobCount" .. self.name)
	end
end

function ThreatLibNPCModuleCore.modulePrototype:RegisterCombatant(combatantName, callback)
	if not callback then
		return
	end
	if callback == true then
		callback = self.BossDeath
	end
	self.encounterEnemies[combatantName] = callback
	
	if useParser40 then
		self:AddParserListener({
			eventType = "Damage",
			recipientName = combatantName
		}, "StartCombat")	

		self:AddParserListener({
			eventType = "Cast",
			recipientName = combatantName
		}, "StartCombat")
	elseif useParser30 then
		self:RegisterParserEvent({
			eventType = "Damage",
			recipientName = combatantName
		}, "StartCombat")	

		self:RegisterParserEvent({
			eventType = "Cast",
			recipientName = combatantName
		}, "StartCombat")	
	else
		-- TODO: Parser-1.1 implementation
	end
end

-- Override to implement state reset on fight start
function ThreatLibNPCModuleCore.modulePrototype:StartFight()
end

function ThreatLibNPCModuleCore.modulePrototype:SetNumberOfMobs(num)
	self.encounterMobCount = math_max(1, num)
	ThreatLibNPCModuleCore.encounterMobCount = self.encounterMobCount
end

function ThreatLibNPCModuleCore:GetModuleVarList()
	return moduleValues
end

function ThreatLibNPCModuleCore:GetModuleVar(name, default)
	return moduleValueOverrides[name] or default
end

function ThreatLibNPCModuleCore.modulePrototype:RegisterModuleVar(nicename, varname, default)
	moduleValueOverrides[varname] = default
	moduleValues[self.name] = moduleValues[self.name] or {}
	moduleValues[self.name][varname] = nicename
end

function ThreatLibNPCModuleCore.modulePrototype:GetModuleVar(name, default)
	return moduleValueOverrides[name] or default
end

function ThreatLibNPCModuleCore.modulePrototype:GetNumberOfMobs()
	return self.encounterMobCount
end

function ThreatLibNPCModuleCore.modulePrototype:ResetFight()
	self:SetNumberOfMobs(1)
	self.InCombat = false
end

function ThreatLibNPCModuleCore.modulePrototype:StartCombat()
	if not self.InCombat then
		self:StartFight()
		self.InCombat = true
	end
end

function ThreatLibNPCModuleCore.modulePrototype:BossDeath()
	self:ResetFight()
	ToggleModuleActive(self, false)
end

local new, del = ThreatLib.new, ThreatLib.del

function ThreatLibNPCModuleCore.modulePrototype:RegisterChatEvent(eventType, mob, text, callback)
	if not mob then
		return
	end
	if not text then
		return
	end
	local t = self.chatEvents[eventType]
	if not t then
		t = new()
		self.chatEvents[eventType] = t
	end
	
	local tm = t[mob]
	if not tm then
		tm = new()
		t[mob] = tm
	end
	tm[text] = callback		
end

function ThreatLibNPCModuleCore.modulePrototype:UnregisterChatEvent(eventType, mob, text)
	local t = self.chatEvents[eventType]
	if not t then
		return
	end
	
	local tm = t[mob]
	if not tm then
		return
	end
	
	tm[text] = nil
	if not next(tm) then
		t[mob] = del(tm)
	end
	if not next(t) then
		self.chatEvents[eventType] = del(t)
	end
end

function ThreatLibNPCModuleCore.modulePrototype:SingleDeath()
	self:SetNumberOfMobs(self:GetNumberOfMobs() - 1)
end

----------------------------------------------------------------
-- Module API
----------------------------------------------------------------

function ThreatLibNPCModuleCore.modulePrototype:WipeRaidThreatOnMob(mob)
	ThreatLib:Debug("Wiping threat on %s", mob)
	ThreatLib:WipeRaidThreatOnMob(mob)
end

function ThreatLibNPCModuleCore.modulePrototype:WipeAllRaidThreat()
	ThreatLib:RequestThreatClear()
end

_G.tinsert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	ThreatLibNPCModuleCore = ThreatLib:GetModule("NPCCore")
end)

end
