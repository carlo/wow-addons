local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54897 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local BS = AceLibrary("Babble-Spell-2.2")

local _G = _G
local assert = _G.assert
local tonumber = _G.tonumber
local ipairs = _G.ipairs
local pairs = _G.pairs
local tinsert = _G.tinsert
local tremove = _G.tremove
local max = _G.max
local min = _G.min
local time = _G.time
local select = _G.select
local tostring = _G.tostring
local error = _G.error
local type = _G.type
local geterrorhandler = _G.geterrorhandler
local pcall = _G.pcall
local setmetatable = _G.setmetatable

local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemGem = _G.GetItemGem
local UnitMana = _G.UnitMana
local UnitManaMax = _G.UnitManaMax
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitIsDead = _G.UnitIsDead
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitExists = _G.UnitExists
local GetNetStats = _G.GetNetStats
local GetTime = _G.GetTime
local IsEquippedItem = _G.IsEquippedItem

local ParserLib = _G.ParserLib
local ParserLib_SELF = _G.ParserLib_SELF

local AceLibrary = _G.AceLibrary

local useParser40 = AceLibrary:HasInstance("LibParser-4.0")
local useParser30 = not useParser40 and AceLibrary:HasInstance("Parser-3.0")

local abilityName, damageType, recipientId, recipientName
if useParser30 or useParser40 then
	abilityName = "abilityName"
	damageType = "damageType"
	recipientId = "recipientID"
	recipientName = "recipientName"
else
	abilityName = "skill"
	damageType = "element"
	recipientId = "victim"
	recipientName = "victim"
end

local Aura = AceLibrary("SpecialEvents-Aura-2.0")
local ThreatLib = _G.ThreatLib

local ThreatClassModuleCore
if useParser40 then
	ThreatClassModuleCore = ThreatLib:NewModule("ClassCore", "AceEvent-2.0", "LibParser-4.0")
elseif useParser30 then
	ThreatClassModuleCore = ThreatLib:NewModule("ClassCore", "AceEvent-2.0", "Parser-3.0")
else
	ThreatClassModuleCore = ThreatLib:NewModule("ClassCore", "AceEvent-2.0")
end

local modules = {}
local activeModules = {}

ThreatClassModuleCore.modulePrototype = {}
function ThreatClassModuleCore:GetModule(name)
	return modules[name]
end
local mt = {__index = ThreatClassModuleCore.modulePrototype}
function ThreatClassModuleCore:NewModule(name, ...)
	local mod = setmetatable({ mixins = {} }, mt)
	for i = 1, select('#', ...) do
		local lib = AceLibrary((select(i, ...)))
		mod.mixins[lib] = true
		if lib.embed then
			lib:embed(mod)
		else
			lib:Embed(mod)
		end
	end
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
	modules[name] = mod
	mod.name = name
	activeModules[mod] = false
	return mod
end
function ThreatClassModuleCore:ToggleModuleActive(module, value)
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

local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet

function ThreatClassModuleCore:OnInitialize()
	ThreatLib:ToggleModuleActive(self, true)
	
	for name, mod in pairs(modules) do
		if mod.OnInitialize then
			mod:OnInitialize()
		end
	end
	
	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	else
		self:RegisterEvent("AceEvent_FullyInitialized")
	end
end

-- We do this on FullyInitialized because otherwise, talent data is not available on login.
function ThreatClassModuleCore:AceEvent_FullyInitialized()
	local playerClassModule = _G.select(2, UnitClass("player"))
	local mod = self:GetModule(playerClassModule)
	if mod then
		self.activeModule = mod
		self:ToggleModuleActive(playerClassModule, true)
	end
	mod = self:GetModule("PET")
	mod:InitHooks()	-- special handling for pets!
	self.petModule = mod
	if UnitName("pet") then
		self:ToggleModuleActive(mod, true)
	end
end

function ThreatClassModuleCore:ClearThreat()
	return self.activeModule:ClearThreat()
end

local partyUnits = ThreatLib.partyUnits

------------------------------------------
-- Module prototype
------------------------------------------

function ThreatClassModuleCore.modulePrototype:OnEnable()
	if not AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		ThreatClassModuleCore:ToggleModuleActive(self, false)
		return
	end 
	self.unitType = "player"

	self.buffThreatMultipliers = 1
	self.debuffThreatMultipliers = 1

	self.buffThreatFlatMods = 0
	self.debuffThreatFlatMods = 0

	self.equipmentThreatModifiers = 1
	self.equipmentBonusThreatModifiers = 1
	self.enchantMods = 1
	self.passiveThreatModifiers = 1
	
	self.redirectThreatTo = nil

	self.itemSets = new()
	self.itemSetsWorn = new()
	
	-- To be filled in by each class module
	self.ClassBuffs = new()
	self.ClassDebuffs = new()
	self.CastHandlers = new()
	self.ThreatQueries = new()
	
	-- Shrouding potions
	self.CastHandlers["Shrouding"] = function() self:AddTargetThreat(-800 * self:threatMods()) end
	
	self.SpecialCastHandlers = new()
	
	self.ExemptGains = newHash()
	self.ExemptGains[BS["Improved Leader of the Pack"]] = true
	
	self.CastMissHandlers = new()
	
	self.totalThreatMods = nil
	self.abilityThreatMods = new()
	
	self.schoolThreatMods = new()
	self.transactions = new()
	
	self.generalThreat = 0
	self.meleeCritReduction = 0
	self.spellCritReduction = 0
	
	self.targetThreat = new()

	self:ScanTalents()
	
	self:ClassInit()

	if self.isPetModule and not self.petName then return end

	if not self.isPetModule and select(2, UnitClass(self.unitType)) ~= "SHAMAN" then
		self.abilityThreatMods[BS["Lightning Bolt"]] = function(self, amount) return amount * 0.5 end
	end

	self:RegisterEvent("SpecialEvents_PlayerBuffGained", "buffGained")
	self:RegisterEvent("SpecialEvents_PlayerBuffLost", "buffLost")
	self:RegisterEvent("SpecialEvents_PlayerDebuffGained", "debuffGained")
	self:RegisterEvent("SpecialEvents_PlayerDebuffLost", "debuffLost")

	if not self.isPetModule then
		self:RegisterBucketEvent("UNIT_INVENTORY_CHANGED", 0.25, "equipChanged")
	end

	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	
	if self.isPetModule then
		self:RegisterEvent("PET_ATTACK_START")
		self:RegisterEvent("PET_ATTACK_STOP")
	end
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	-- self:RegisterEvent("PLAYER_ALIVE", "PLAYER_REGEN_ENABLED")
	-- self:RegisterEvent("PLAYER_UNGHOST", "PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_DEAD", "PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	local sourceID = "player"
	if self.isPetModule then
	 	sourceID = "pet"
	end
	
	self.parser40_filters = self.parser40_filters or {
		["parseDamage"] = { eventType = 'Damage', sourceID = sourceID },
		["parseHeal30"] = { eventType = 'Heal', sourceID = sourceID },
		["parseGain"] = { eventType = 'Gain', sourceID = sourceID },
		["parseCast"] = { eventType = 'Cast', sourceID = sourceID },
		["parseMiss"] = { eventType = 'Miss', sourceID = sourceID },
	}	
	
	if useParser40 then
		for k, v in pairs(self.parser40_filters) do
			if not self:HasParserListener(v) then
				self:AddParserListener(v, k)
			end
		end
	elseif useParser30 then
		-- Success
		for k, v in pairs(self.parser40_filters) do
			self:RegisterParserEvent(v, k)
		end
	else
		local events = new(
			'CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS',
			'CHAT_MSG_COMBAT_PET_HITS',
			'CHAT_MSG_COMBAT_PET_MISSES',
			'CHAT_MSG_COMBAT_SELF_HITS',
			'CHAT_MSG_COMBAT_SELF_MISSES',
			'CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF',
			'CHAT_MSG_SPELL_PET_BUFF',
			'CHAT_MSG_SPELL_PET_DAMAGE',
			'CHAT_MSG_SPELL_SELF_BUFF',
			'CHAT_MSG_SPELL_SELF_DAMAGE',
			'CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE',
			'CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS',
			'CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS',
			'CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF'
		)
		local parser = ParserLib:GetInstance("1.1")
		local function parserCombatEvent(event, info)
			local source
			if info.source == ParserLib_SELF then 
				source = "player"
			else
				source = partyUnits[info.source]
			end
			if source ~= sourceID then return end
			if info.type == "hit" then
				self:parseDamage(info)
			elseif info.type == "heal" then
				self:parseHeal11(info)
			elseif info.type == "gain" then
				self:parseGain(info)
			elseif info.type == "cast" then
				self:parseCast(info)
			elseif info.type == "miss" then
				self:parseMiss(info)
			elseif info.type == "buff" or info.type == "debuff" then
				self:parseAura(info)
			end
		end
		for k,v in pairs(events) do
			parser:RegisterEvent("ThreatClassModule-" .. self.name, v, parserCombatEvent)
		end
		events = del(events)
	end
	
	--temp activation of enchant scanning
	self:equipChanged()
	
	self:calcBuffMods()
	self:calcDebuffMods()
	
	-- self:RegisterEvent("UNIT_TARGET")
end

function ThreatClassModuleCore.modulePrototype:OnDisable()
	self.itemSets = del(self.itemSets)
	self.itemSetsWorn = del(self.itemSetsWorn)
	self.ClassBuffs = del(self.ClassBuffs)
	self.ClassDebuffs = del(self.ClassDebuffs)
	self.CastHandlers = del(self.CastHandlers)
	self.SpecialCastHandlers = del(self.SpecialCastHandlers)
	self.CastMissHandlers = del(self.CastMissHandlers)
	self.abilityThreatMods = del(self.abilityThreatMods)
	self.schoolThreatMods = del(self.schoolThreatMods)
	self.transactions = del(self.transactions)
	self.targetThreat = del(self.targetThreat)
	self.ExemptGains = del(self.ExemptGains)
	if useParser40 then
		self:RemoveAllParserListeners()
	elseif useParser30 then
		self:UnregisterAllParserEvents()
	end
end

------------------------------------------------
-- Internal utility methods
------------------------------------------------

function ThreatClassModuleCore.modulePrototype:threatMods()
	if self.totalThreatMods ~= nil then
		return self.totalThreatMods
	end
	local deathMod = 1
	if UnitIsDead(self.unitType) then
		deathMod = 0
	end
	self.totalThreatMods = self.buffThreatMultipliers * self.passiveThreatModifiers * self.debuffThreatMultipliers * self.equipmentThreatModifiers * self.equipmentBonusThreatModifiers * self.enchantMods * deathMod
	return self.totalThreatMods
end

------------------------------------------------
-- Equipment handling
------------------------------------------------
function ThreatClassModuleCore.modulePrototype:getWornSetPieces(name)
	if self.isPetModule then
		return 0
	end
	if self.itemSetsWorn[name] then
		return self.itemSetsWorn[name]
	end
	
	local ct = 0
	local data = self.itemSets[name]
	if data then
		for _, itemID in ipairs(data) do
			if IsEquippedItem( itemID ) then
				ct = ct + 1
			end
		end
	end
	self.itemSetsWorn[name] = ct
	return ct
end

function ThreatClassModuleCore.modulePrototype:equipChanged(units)
	if (units and not units.player) or ThreatLib.inCombat then
		return
	end
	for k in pairs(self.itemSetsWorn) do
		self.itemSetsWorn[k] = nil
	end
	--self.totalThreatMods = nil
	
	self.enchantMods = 1
	
	local enchant = (GetInventoryItemLink("player", 15) or ""):match(".-item:%d+:(%d+).*")
	
	-- -2% threat on cloack
	if tonumber(enchant) == 2621 then
		self.enchantMods = self.enchantMods - 0.02
	end
	enchant = (GetInventoryItemLink("player", 10) or ""):match(".-item:%d+:(%d+).*")
	
	-- +2% threat on gloves
	if tonumber(enchant) == 2613 then
		self.enchantMods = self.enchantMods + 0.02
	end
	
	local helmlink = GetInventoryItemLink("player", 1) or "" 
	for i=1, 3 do 
		local enchant = (select(2, GetItemGem(helmlink, i)) or ""):match(".-item:(%d+).*")
		if tonumber(enchant) == 25897 then 
			self.enchantMods = self.enchantMods - 0.02 
			break
		end
	end
	
	-- metagem -2% threat FIXME: need to make sure that it's active
	--[[
	enchant = (GetItemGem(GetInventoryItemLink("player", 1) or "", 2) or ""):match(".-item:(%d+).*")
	if tonumber(enchant) == 25897 then
		self.enchantMods = self.enchantMods - 0.02
	end
	]]--
	
	-- tonumber here to speed up with possible future trinkets
	local trinket1ID = tonumber((GetInventoryItemLink("player", 13) or ""):match(".-item:(%d+):.*"))
	local trinket2ID = tonumber((GetInventoryItemLink("player", 14) or ""):match(".-item:(%d+):.*"))

	self.meleeCritReduction = 0
	self.spellCritReduction = 0
	
	-- Prism of Inner Calm, see http://www.wowhead.com/?item=30621
	if trinket1ID == 30621 or trinket2ID == 30621 then
		self.meleeCritReduction = 150
		self.spellCritReduction = 1000
	end
	
	self.totalThreatMods = nil
	-- Scan equip for any modifying items
end

----------------------------------------------------------------------------------
-- Buff modifier handling
----------------------------------------------------------------------------------
function ThreatClassModuleCore.modulePrototype:AddBuffThreatMultiplier(multiplier)
	self.buffThreatMultipliers = self.buffThreatMultipliers * multiplier
	self.totalThreatMods = nil
end

function ThreatClassModuleCore.modulePrototype:AddBuffThreatModifier(amount)
	self.buffThreatFlatMods = self.buffThreatFlatMods + amount
	self.totalThreatMods = nil
end

function ThreatClassModuleCore.modulePrototype:buffChange(buffName, applications, texture, rank, action)
	local func = ThreatLib.BuffModifiers[buffName] or self.ClassBuffs[buffName]
	if func then
		func(self, action, rank, applications)
	end
end

function ThreatClassModuleCore.modulePrototype:calcBuffMods(gainedBuffName)
	self.buffThreatMultipliers = 1
	for buffName, index, applications, texture, rank in Aura:BuffIter(self.unitType) do
		local action = "exist"
		if gainedBuffName and gainedBuffName == buffName then
			action = "gain"
		end
		self:buffChange(buffName, applications, texture, rank, action) 
	end	
end

function ThreatClassModuleCore.modulePrototype:buffGained(buffName, buffIndex, applications, texture, rank, index) 
	self:calcBuffMods(buffName)
end

function ThreatClassModuleCore.modulePrototype:buffLost(buffName, applications, texture, rank)
	self:buffChange(buffName, applications, texture, rank, "lose")
	self:calcBuffMods()
end

----------------------------------------------------------------------------------
-- Debuff modifier handling
----------------------------------------------------------------------------------

function ThreatClassModuleCore.modulePrototype:AddDebuffThreatMultiplier(multiplier)
	self.debuffThreatMultipliers = self.debuffThreatMultipliers * multiplier
	self.totalThreatMods = nil
end

function ThreatClassModuleCore.modulePrototype:AddDebuffThreatModifier(amount)
	self.debuffThreatFlatMods = self.debuffThreatFlatMods + amount
	self.totalThreatMods = nil
end

function ThreatClassModuleCore.modulePrototype:debuffChange(buffName, applications, texture, rank, action)
	local func = ThreatLib.DebuffModifiers[buffName] or self.ClassDebuffs[buffName]
	if func then
		func(self, action, rank, applications)
	end
end

function ThreatClassModuleCore.modulePrototype:calcDebuffMods(gainingDebuffName)
	self.debuffThreatMultipliers = 1
	for buffName, index, applications, texture, rank in Aura:DebuffIter(self.unitType) do
		local action = "exist"
		if buffName == gainingDebuffName then
			action = "gain"
		end
		self:debuffChange(buffName, applications, texture, rank, action) 
	end	
end

function ThreatClassModuleCore.modulePrototype:debuffGained(debuffName, applications, debuffType, texture, rank, index) 
	self:calcDebuffMods(debuffName)
end

function ThreatClassModuleCore.modulePrototype:debuffLost(debuffName, applications, debuffType, texture, rank)
	self:debuffChange(debuffName, applications, texture, rank, "lose")
	self:calcDebuffMods()
end

---------------------------------------------------------------------------
-- End buffs/debuffs
---------------------------------------------------------------------------

function ThreatClassModuleCore.modulePrototype:parseDamage(info)
	ThreatLib:Debug("Parsing damage from Omen")
	ThreatLib:Debug("%s: %s (%s)", info.sourceID, info.amount, info.recipientName)
	if not ThreatLib.running then
		return
	end
	if info.recipientID and UnitIsPlayer(info.recipientID) then
		return
	end
	
	local threat = info.amount
	local skill = info[abilityName]
	
	local element = info[damageType]
	if info.isCrit then
		if self.meleeCritReduction > 0 and element == "Physical" then
			threat = threat - self.meleeCritReduction
		elseif self.spellCritReduction > 0 and element ~= "Physical" then
			threat = threat - self.spellCritReduction
		end
	end
	
	if skill then
		self:commitOldestTransactionFor(skill)
	end
	
	local handler = self.abilityThreatMods[skill]
	if handler then
		threat = handler(self, threat, true, info.isCrit)
	end
	
	handler = self.schoolThreatMods[element]
	if handler then
		threat = handler(self, threat, true, info.isCrit)
	end
	threat = threat * self:threatMods()
	
	local recipient = info[recipientName]
	self:_addTargetThreat(threat, recipient, self.redirectThreatTo)
end

function ThreatClassModuleCore.modulePrototype:parseHeal30(info)
	if not ThreatLib.running then
		return
	end
	
	local unitID = info.recipientID
	if not ThreatLib.inCombat or not unitID or not UnitAffectingCombat(unitID) then
		return
	end
		
	local threat = info.amount - info.overhealAmount
	local skill = info[abilityName]
	
	if not self.ExemptGains[skill] then
		local handler = self.abilityThreatMods[skill]
		if handler then
			threat = handler(self, threat, false, info.isCrit)
		end
		threat = threat * ThreatLib.ThreatConstants.healing * self:threatMods()
		self:_addThreat(threat)
	end
end

function ThreatClassModuleCore.modulePrototype:parseHeal11(info)
	if not ThreatLib.running then
		return
	end
	if info.source ~= ParserLib_SELF then
		return
	end
	
	local unitID
	if info.victim == ParserLib_SELF then
		unitID = "player"
	else
		unitID = partyUnits[info.victim]
	end

	if not ThreatLib.inCombat or not unitID or not UnitAffectingCombat(unitID) then
		return
	end
		
	local threat = info.amount
	if type(threat) ~= "number" then
		AceLibrary("AceConsole-2.0"):PrintLiteral(info)
		AceLibrary("AceConsole-2.0"):Print("Problem with info.amount. Please inform ckknight or Antiarc with the above information. Take a screenshot or something.")
	end
	threat = min(UnitHealthMax(unitID) - UnitHealth(unitID), threat)

	local skill = info[abilityName]
	if not self.ExemptGains[skill] then
		local handler = self.abilityThreatMods[skill]
		if handler then
			threat = handler(self, threat, false, info.isCrit)
		end
		threat = threat * ThreatLib.ThreatConstants.healing * self:threatMods()
		self:_addThreat(threat)
	end
end

function ThreatClassModuleCore.modulePrototype:parseGain(info)
	if not ThreatLib.running then
		return
	end
	if not useParser30 and not useParser40 and info.source ~= ParserLib_SELF then
		return
	end
	if not ThreatLib.inCombat then
		return
	end
	
	local unitType = self.unitType
	
	local maxgain
	if info.recipientID then
		maxgain = UnitManaMax(info.recipientID) - UnitMana(info.recipientID)
	else
		-- This can happen if a gain is procced on someone that is not in our party - for example, Blackheart MCs someone and benefits from a gain from that person.
		return
	end
	local amount = min(maxgain, info.amount)
	if not self.ExemptGains[info[abilityName]] then
		if info.attribute == "Mana" then
			self:_addThreat(amount * ThreatLib.ThreatConstants.manaGain)
		elseif info.attribute == "Rage" then
			self:_addThreat(amount * ThreatLib.ThreatConstants.rageGain)
		elseif info.attribute == "Energy" then
			self:_addThreat(amount * ThreatLib.ThreatConstants.energyGain)
		end
	end
end

function ThreatClassModuleCore.modulePrototype:parseMiss(info)
	if not ThreatLib.running then
		return
	end
	if info.abilityName then
		if self.CastMissHandlers[info.abilityName] then
			self.CastMissHandlers[info.abilityName](self, info.recipientName)
		end
		self:rollbackTransaction(info.abilityName)
	end
end

function ThreatClassModuleCore.modulePrototype:parseCast(info)
	if not ThreatLib.running then
		return
	end
	if self.isPetModule then
		self.currentTarget = info[recipientName]
		self:RunCastHandlers(nil, info[abilityName], nil)
		self.currentTarget = nil
	else
		if self.SpecialCastHandlers[info.abilityName] then
			self.SpecialCastHandlers[info.abilityName](self, info.recipientName)
		end
		self:commitOldestTransactionFor(info.abilityName)
	end
end

function ThreatClassModuleCore.modulePrototype:RunCastHandlers(arg1, arg2, arg3)
	local func = self.CastHandlers[arg2]
	if func then
		func(self, arg3, arg2)
	end	
end

function ThreatClassModuleCore.modulePrototype:PLAYER_REGEN_DISABLED()
	self.totalThreatMods = nil
	if not ThreatLib.running then return end
	self.TransactionsCommitting = true
	self:activatePeriodicTransactionCommit()
end

local function func(self)
	if not UnitExists("pet") or not UnitAffectingCombat("pet") then
		self:CancelScheduledEvent("ThreatClassModuleCore-PetInCombat")
		ThreatLib:Debug("Pet exiting combat.")
		ThreatLib:SendCommMessage("GROUP", "LEFT_COMBAT", false, true)		
		self:ClearThreat()
		self:rollbackAllTransactions()
		self:deactivatePeriodicTransactionCommit()
		self.TransactionsCommitting = false
	end
end

function ThreatClassModuleCore.modulePrototype:PLAYER_REGEN_ENABLED()
	self.totalThreatMods = nil		-- Accounts for death, mostly
	if not self.TransactionsCommitting then return end
	-- PET_ATTACK_STOP doesn't always fire like you might expect it to	
	if self.unitType == "pet" then
		self:ScheduleRepeatingEvent("ThreatClassModuleCore-PetInCombat", func, 0.5, self)
	else
		ThreatLib:Debug("Player exiting combat.")
		local petIsOutOfCombat = not UnitExists("pet") or not UnitAffectingCombat("pet")
		ThreatLib:SendCommMessage("GROUP", "LEFT_COMBAT", true, petIsOutOfCombat)		
		self:ClearThreat()
		self:rollbackAllTransactions()
		self:deactivatePeriodicTransactionCommit()
		self.TransactionsCommitting = false
	end
end

function ThreatClassModuleCore.modulePrototype:PET_ATTACK_START()
	self:PLAYER_REGEN_DISABLED()
end

function ThreatClassModuleCore.modulePrototype:PET_ATTACK_STOP()
	--	self:ScheduleRepeatingEvent("ThreatClassModuleCore-PetInCombat", func, 0.5, self)
end

function ThreatClassModuleCore.modulePrototype:CHARACTER_POINTS_CHANGED()
	self:ScanTalents()
end

------------------------------------------------
-- Public API
------------------------------------------------

function ThreatClassModuleCore.modulePrototype:GetAbilityThreat(spell, rank, damage)
	if self.ThreatQueries[spell] then
		threat = self.ThreatQueries[spell](self, rank or damage)
		if rank and damage then
			return threat + (damage * self:threatMods())
		end
		return threat
	end
	return 0
end

function ThreatClassModuleCore.modulePrototype:ClearThreat()
	self.generalThreat = 0
	if not self.targetThreat then return end
	for k,v in pairs(self.targetThreat) do
		self.targetThreat[k] = nil
	end	
	ThreatLib:_clearThreat(UnitName(self.unitType))
end

	---------------------------------------------
	-- Threat modification interface [Public API]
	---------------------------------------------
	
local function addtransaction(list, func, param)
	local n = #list
	list[n + 1] = func
	list[n + 2] = param
end

function ThreatClassModuleCore.modulePrototype:RedirectThreatTo(target)
	ThreatLib:Debug("Trying to set redirect target to %s", target)
	if target and partyUnits[target] then
		ThreatLib:Debug("Setting redirect target to %s", target)
		self.redirectThreatTo = target
		return true
	else
		ThreatLib:Debug("Invalid redirect target: %s!", target)
		self.redirectThreatTo = nil
		return false
	end
end

-- Specific-target threat
function ThreatClassModuleCore.modulePrototype:AddTargetThreat(threat)
	-- DEFAULT_CHAT_FRAME:AddMessage(string.format("%s, %s, %s", tostring(threat), tostring(self.currentTarget), tostring(self.redirectThreatTo)))
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_addTargetThreat", threat)
		self.activeTransaction.redirectThreatTo = self.redirectThreatTo
	else
		self:_addTargetThreat(threat, self.currentTarget, self.redirectThreatTo)
	end
end

-- Specific-target threat
function ThreatClassModuleCore.modulePrototype:MultiplyTargetThreat(modifier)
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_multiplyTargetThreat", modifier)
	else
		self:_multiplyTargetThreat(modifier, self.currentTarget)
	end
end

-- Global threat, like heals, mana gain, buffs, etc
function ThreatClassModuleCore.modulePrototype:AddThreat(threat)
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_addThreat", threat)
	else
		self:_addThreat(threat)
	end
end

-- Global threat, like heals, mana gain, buffs, etc
function ThreatClassModuleCore.modulePrototype:MultiplyThreat(modifier)
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_multiplyThreat", modifier)
	else
		self:_multiplyThreat(modifier)
	end
end

-- Set your target's hate to a given value (Taunt effects, Feign Death minus resists)
function ThreatClassModuleCore.modulePrototype:SetTargetThreat(threat)
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_setTargetThreat", threat)
	else
		self:_setTargetThreat(threat, self.currentTarget)
	end
end

-- Reduces all threat by a multiplier. Vanish, Invisibility, some trinkets use this.
function ThreatClassModuleCore.modulePrototype:ReduceAllThreat(multiplier)
	if self:hasActiveTransaction() then
		addtransaction(self.activeTransaction.ops, "_reduceAllThreat", multiplier)
	else
		self:_reduceAllThreat(multiplier)
	end
end

------------------------------------------------
-- Overridable methods
------------------------------------------------

function ThreatClassModuleCore.modulePrototype:ScanTalents()
	
end

------------------------------------------------
-- Internal threat modification function, transaction-free
------------------------------------------------

function ThreatClassModuleCore.modulePrototype:_addTargetThreat(threat, currentTarget, redirectTo)
	if partyUnits[currentTarget] then
		return
	end
	if redirectTo then
		ThreatLib:SendThreatTo(redirectTo, currentTarget, threat)
	else
		local v = max(0, (self.targetThreat[currentTarget] or 0) + threat)
		self.targetThreat[currentTarget] = v
		ThreatLib:ThreatUpdated(currentTarget, v, self.isPetModule)
	end
end

function ThreatClassModuleCore.modulePrototype:_multiplyTargetThreat(modifier, target)
	if partyUnits[target] then
		return
	end
	local v = (self.targetThreat[target] or 0) * modifier
	self.targetThreat[target] = v
	ThreatLib:ThreatUpdated(target, v, self.isPetModule)
end

function ThreatClassModuleCore.modulePrototype:_addThreat(threat)
	-- We need to not floor this because of things like fade
	-- Instead, we should floor in the GUI
	local v = self.generalThreat + ( threat / ThreatLib:EncounterMobs() )
	self.generalThreat = v
	ThreatLib:ThreatUpdated("_GLOBAL_", v, self.isPetModule)
end

function ThreatClassModuleCore.modulePrototype:_multiplyThreat(modifier)
	local v = self.generalThreat * modifier
	self.generalThreat = v
	ThreatLib:ThreatUpdated("_GLOBAL_", v, self.isPetModule)
end

function ThreatClassModuleCore.modulePrototype:_setTargetThreat(threat, target)
	self.targetThreat[target] = threat
	ThreatLib:ThreatUpdated(target, threat, self.isPetModule)
end

function ThreatClassModuleCore.modulePrototype:_reduceAllThreat(multiplier)
	local val = self.generalThreat * multiplier
	self.generalThreat = val
	local unitType = self.unitType
	local unitName = UnitName(unitType)
	local isPet = self.unitType == "pet"
	
	if not unitName then
		ThreatLib:Debug("No unit name given for %s in _reduceAllThreat!", tostring(unitType))
		return
	end
	for k,v in pairs(self.targetThreat) do
		local newV = v * multiplier
		self.targetThreat[k] = newV
		ThreatLib:ThreatUpdated(k, newV, self.isPetModule)
	end	
	ThreatLib:ThreatUpdated("_GLOBAL_", val, self.isPetModule)
end

------------------------------------------------
-- Spell transaction stuff
------------------------------------------------
--[[

Transactioning

Begin transaction on UNIT_SPELLCAST_SENT
Store spell name, rank, source, target

Rollback if UNIT_SPELLCAST_FAILED

Commit if CHAT_SPELL_SELF_DAMAGE matches transaction's spell name

Commit if a new transaction is started for a spell that we already have a transaction for

Commit after 2 seconds

Rollback if dodge/parry/miss/block/immune/resist

]]--

function ThreatClassModuleCore.modulePrototype:UNIT_SPELLCAST_SENT(arg1, arg2, arg3, arg4)
	if arg1 ~= self.unitType then -- or not ThreatLib.inCombat 
		return
	end
	self.currentTarget = arg4
	self.activeTransaction = self:startTransaction(arg2, arg3)
end

function ThreatClassModuleCore.modulePrototype:UNIT_SPELLCAST_INTERRUPTED(arg1)
	if arg1 ~= self.unitType or not ThreatLib.inCombat then
		return
	end
	local skill = self:hasActiveTransaction()
	if skill then
		self:rollbackTransaction(skill)
	end
end

function ThreatClassModuleCore.modulePrototype:UNIT_SPELLCAST_SUCCEEDED(arg1, arg2, arg3)
	if arg1 ~= self.unitType then
		return
	end
	local hostileTarget = UnitExists("target") and UnitCanAttack("player", "target")
	if (not ThreatLib.inCombat and not hostileTarget) then
		return
	end
	if self:hasActiveTransaction() then
		self.activeTransaction.sent = true
		self.activeTransaction.time = GetTime()
	end
	self:RunCastHandlers(arg1, arg2, arg3)
end

function ThreatClassModuleCore.modulePrototype:hasActiveTransaction()
	return self.activeTransaction and self.activeTransaction.skill
end

function ThreatClassModuleCore.modulePrototype:commitOldestTransactionFor(skill)
	local transactionSet = self.transactions[skill]
	if not transactionSet then
		return
	end
	local t = tremove(transactionSet, 1)
	if not t then
		return
	end
	self:commitTransaction(t)
	t = del(t)
	if #transactionSet == 0 then
		self.transactions[skill] = del(transactionSet)
	end
end

function ThreatClassModuleCore.modulePrototype:commitTransaction(transaction)
	for i = 1, #transaction.ops, 2 do
		local call = transaction.ops[i]
		local threat = transaction.ops[i + 1]
		self[call](self, threat, transaction.currentTarget, transaction.redirectThreatTo)		
	end
	transaction.ops = del(transaction.ops)
end

function ThreatClassModuleCore.modulePrototype:rollbackAllTransactions()
	local transactions = self.transactions
	if not transactions then return end
	for skill, transactionList in pairs(transactions) do
		for i = 1, #transactionList do
			del(tremove(transactionList, 1))
		end
		transactions[skill] = del(transactionList)
	end
end

function ThreatClassModuleCore.modulePrototype:commitPeriodicTransactions()
	local t = GetTime()
	local lag = select(3, GetNetStats()) / 1000
	for skill, transactionList in pairs(self.transactions) do
		local offset = 0
		for idx = 1, #transactionList do
			local transaction = transactionList[idx - offset]
			if transaction and transaction.sent and t - transaction.time > (0.5 + lag) then
				self:commitTransaction(transaction)
				del(tremove(transactionList, idx - offset))
				offset = offset + 1
			end
		end
		if #transactionList == 0 then
			self.transactions[skill] = del(transactionList)
		end
	end	
end

function ThreatClassModuleCore.modulePrototype:startTransaction(skill, rank)
	local t = self.transactions[skill]
	if not t then
		t = new()
		self.transactions[skill] = t
	end
	local v = newHash(
		"skill", skill,
		"rank", rank,
		"sent", false,
		"currentTarget", self.currentTarget,
		"time", GetTime(),
		"ops", new()
	)
	tinsert(t, v)
	return v
end

-- Shifts the oldest entry off of the list and invalidates it
function ThreatClassModuleCore.modulePrototype:rollbackTransaction(skill)
	local t = self.transactions[skill]
	
	-- I -think- it's valid to not have a transaction for a skill, so I'm going to just short-circuit rather than assert. Should doublecheck though.
	if not t or #t == 0 then
		return
	end
	-- assert(#t > 0, "invalid transaction to rollback")
	local transaction = tremove(t, 1)
	transaction.ops = del(transaction.ops)
	del(transaction)
	if #t == 0 then
		self.transactions[skill] = del(t)
	end
end

function ThreatClassModuleCore.modulePrototype:deactivatePeriodicTransactionCommit()
	local n = "ThreatLibPeriodicCommit-" .. self.name
	if self:IsEventScheduled(n) then
		self:CancelScheduledEvent(n)
	end
end

function ThreatClassModuleCore.modulePrototype:activatePeriodicTransactionCommit()
	local n = "ThreatLibPeriodicCommit-" .. self.name
	if not self:IsEventScheduled(n) then
		local clientLatency = select(3, GetNetStats()) / 1000
		self:ScheduleRepeatingEvent(n, self.commitPeriodicTransactions, 0.2 + clientLatency, self)
	end
end

tinsert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib;
	ThreatClassModuleCore = ThreatLib:GetModule("ClassCore")
end)

end
