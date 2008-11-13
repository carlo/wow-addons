local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 55354 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "PALADIN" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local ipairs = _G.ipairs
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Paladin = ThreatLib:GetModule("ClassCore"):NewModule(c)
local Aura = AceLibrary("SpecialEvents-Aura-2.0")

local irfRanks = {0, 0.16, 0.33, 0.5}

local HolyHealsEN = {
	"Holy Light", "Holy Shock", "Lay on Hands", "Seal of Light", "Flash of Light"
}

-- These abilities seem to be modified by global modifiers, like Salvation!
-- They're obviously incomplete, but data collected so far shows that they're not too significant
-- Unused for now
local buffThreatValues = {
		[BS["Blessing of Might"]] = {5, 10, 25, 35, 45, 55, 65, 75},
		[BS["Blessing of Freedom"]] = {20},
		[BS["Blessing of Salvation"]] = {20},
		[BS["Blessing of Kings"]] = {20},
		[BS["Hammer of Justice"]] = {15, 50, 80},
		[BS["Seal of Justice"]] = {25, 50},
		[BS["Seal of Wisdom"]] = {25, 50},
		[BS["Seal of Righteousness"]] = {nil, nil, nil, nil, nil, 45}
}
local judgements = { "Wisdom", "Light", "the Crusader", "Justice", "Blood", "Command" }
-- , 

local rfOn = false
local fanaticismModifier = 1

function Paladin:ClassInit()
	self.className = "PALADIN"
	self.passiveThreatModifiers = 1
	
	self.schoolThreatMods["Holy"] = self.RighteousFury
	self.ClassBuffs[BS["Righteous Fury"]] = self.RighteousFuryBuff
	
	local healMod = function(self, amt, isDamage)
		local dMod = 1
		if isDamage then
			dMod = 2
		end
		return self:RighteousFury(amt) * 0.5 * dMod
	end

	for _,v in ipairs(HolyHealsEN) do
		self.abilityThreatMods[BS[v]] = healMod
	end
	
	self.CastHandlers[BS["Judgement"]] = function(self, rank) self:AddTargetThreat(self:RighteousFury(57)) end
	
	self.abilityThreatMods[BS["Holy Shield"]] = function(self, amt, isDamage)
		return amt * 1.35
	end
	
	self.SpecialCastHandlers[BS["Righteous Defense"]] = self.RighteousDefense
	
	HolyHealsEN = nil
	self:CheckRighteousFury()
end

function Paladin:ScanTalents()
	-- Scan talents	
	self.righteousFuryMod = 1.6 + (0.6 * irfRanks[select(5, GetTalentInfo(2, 7))+1])
	
	-- Fanaticism
	local rank = select(5, GetTalentInfo(3, 21))
	fanaticismModifier = (0.06 * rank)
	self:CheckRighteousFury()
end

function Paladin:CheckRighteousFury()
	self.passiveThreatModifiers = 1 - fanaticismModifier
	rfOn = false
	for buffName, index, applications, texture, rank in Aura:BuffIter("player") do
		if buffName == BS["Righteous Fury"] then
			self.passiveThreatModifiers = 1
			rfOn = true
			return
		end
	end
end

function Paladin:RighteousFuryBuff(action, rank, applications)
	rfOn = true
	self.passiveThreatModifiers = 1
	if action == "lose" then
		self.passiveThreatModifiers = 1 - fanaticismModifier
		rfOn = false
	end
	ThreatLib:Debug("passiveThreatModifiers is %s", self.passiveThreatModifiers)
end

function Paladin:RighteousFury(amt)
	if rfOn then
		return amt * self.righteousFuryMod
	else 
		return amt
	end
end

function Paladin:RighteousDefense(target)
	local maxThreat = ThreatLib:GetMaxThreatOnTarget(target)
	self:_setTargetThreat(maxThreat, target)	
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Paladin = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
