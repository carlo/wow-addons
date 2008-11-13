local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 55457 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "SHAMAN" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local ipairs = _G.ipairs
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Shaman = ThreatLib:GetModule("ClassCore"):NewModule(c)

local healingSpells = { "Lesser Healing Wave", "Healing Wave", "Chain Heal", "Earth Shield", "Healing Stream Totem" }
local damageSpells = { "Lightning Shield", "Chain Lightning", "Lightning Bolt", "Earth Shock", "Flame Shock" }

function Shaman:ClassInit()	
	self.className = "SHAMAN"
	self.passiveThreatModifiers = 1
	
	-- CastHandlers should return true if they modified the threat level, false if they don't
	--self.CastHandlers[BS["Another Example"]] = self.AnotherExample
	
	-- ThreatMods should return the modifications (if any) to the threat passed in
	for _,v in ipairs(healingSpells) do
		self.abilityThreatMods[BS[v]] = self.HealingSpells
	end
	healingSpells = nil

	for _,v in ipairs(damageSpells) do
		self.abilityThreatMods[BS[v]] = self.DamageSpells
	end
	damageSpells = nil

	self.abilityThreatMods[BS["Frost Shock"]] = self.FrostShock
	--self.abilityThreatMods[BS["Stormstrike"]] = self.Melee
	
	self.schoolThreatMods["Physical"] = self.Melee
	
	self.abilityThreatMods[BS["Chain Lightning"]] = self.ChainLightning
	self.abilityThreatMods[BS["Lightning Bolt"]] = self.LightningBolt
	
	self.CastMissHandlers[BS["Chain Lightning"]] = self.ChainLightningMiss
	self.CastMissHandlers[BS["Lightning Bolt"]] = self.LightningBoltMiss

	self.lastCLCast = 0
	self.lastCLHitTime = 0
	self.lastLBCast = 0
	self.lastLBHitTime = 0

	self.threatValues = {
		["frostshock"] = 2,
	}	
	
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

local precisionReduction = {1, 0.96, 0.93, 0.9}
function Shaman:ScanTalents()
	-- Scan talents
	self.HealingGrace = 1 - 0.05 * select(5, GetTalentInfo(3,9))
	self.ElementalPrecision = precisionReduction[select(5, GetTalentInfo(1,15))+1]
	
	local SpiritWeaponsModifier = 0.3
	self.SpiritWeapons = 1 - SpiritWeaponsModifier * select(5, GetTalentInfo(2,13))
end

function Shaman:HealingSpells(amt)
	return amt * self.HealingGrace
end

function Shaman:DamageSpells(amt)
	return amt * self.ElementalPrecision
end

function Shaman:FrostShock(amt)
	return amt * self.threatValues.frostshock * self.ElementalPrecision
end

function Shaman:Melee(amt)
	return amt * self.SpiritWeapons
end

function Shaman:ChainLightning(amt)
	local t = GetTime()
	if self.lastCLHitTime == 0 then
		self.lastCLHitTime = t
	end
	if t - self.lastCLHitTime <= 0.045 then
		return amt * self.ElementalPrecision
	else
		return 0
	end
end

function Shaman:LightningBolt(amt)
	if self.lastLBHitTime == 0 then
		self.lastLBHitTime = GetTime()
		return amt * self.ElementalPrecision
	else
		return 0
	end	
end

function Shaman:ChainLightningMiss()
	local t = GetTime()
	if self.lastCLHitTime == 0 then
		self.lastCLHitTime = t
	end
end

function Shaman:LightningBoltMiss()
	local t = GetTime()
	if self.lastLBHitTime == 0 then
		self.lastLBHitTime = t
	end
end

function Shaman:UNIT_SPELLCAST_SUCCEEDED(unit, spell)
	if unit ~= "player" then return end
	if spell == BS["Chain Lightning"] then
		self.lastCLCast = GetTime()
		self.lastCLHitTime = 0
	elseif spell == BS["Lightning Bolt"] then
		self.lastLBCast = GetTime()
		self.lastLBHitTime = 0
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Shaman = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end