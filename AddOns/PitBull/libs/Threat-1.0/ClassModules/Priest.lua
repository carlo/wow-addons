local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 42133 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "PRIEST" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local ipairs = _G.ipairs
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local DiscSpellsEN = {
	"Consume Magic", "Starshards", "Dispel Magic", "Divine Spirit", "Elune's Grace", "Inner Fire", "Levitate", "Mass Dispel", 
	"Power Word: Fortitude", "Prayer of Fortitude", "Prayer of Spirit", "Shackle Undead", "Symbol of Hope",
	"Feedback", "Mana Burn"
}

local HolySpellsEn = {
	"Abolish Disease", "Circle of Healing", "Cure Disease", "Desperate Prayer", "Fear Ward", "Flash Heal", "Greater Heal", "Heal", "Holy Fire",
	"Lesser Heal", "Lightwell", "Prayer of Healing", "Prayer of Mending", "Renew", "Resurrection", "Smite"
}

local ShadowSpellsEN = {
	"Prayer of Shadow Protection", "Devouring Plague", "Fade", "Hex of Weakness", "Mind Blast", "Mind Control", "Mind Flay", "Mind Soothe", "Mind Vision", "Psychic Scream",
	"Shadow Protection", "Shadow Word: Death", "Shadow Word: Pain", "Shadowfiend", "Shadowguard", "Touch of Weakness", "Vampiric Touch"
}

local MindControlThreat = {nil, nil, 5500}

local BS = AceLibrary("Babble-Spell-2.2")
local Priest = ThreatLib:GetModule("ClassCore"):NewModule(c)

local threatAmounts = {
	["reflectiveshield"] = 0,
	["fade"] = {55, 155, 285, 440, 620, 820, 1500},
	["pws"] = {22, 44, 79, 117, 150.5, 190.5, 242, 302.5, 381.5, 471, 573.5, 657.5}
}

function Priest:ClassInit()	
	self.className = "PRIEST"
	self.passiveThreatModifiers = 1
	
	local function modForSilentResolve(self, amt) return amt * self.silentResolveMod end
	local function modForShadowAffinity(self, amt) return amt * self.shadowAffinityMod end
	
	for _,v in ipairs(DiscSpellsEN) do
		self.abilityThreatMods[BS[v]] = modForSilentResolve
	end
	DiscSpellsEN = nil

	for _,v in ipairs(HolySpellsEn) do
		self.abilityThreatMods[BS[v]] = modForSilentResolve
	end
	HolySpellsEn = nil

	for _,v in ipairs(ShadowSpellsEN) do
		self.abilityThreatMods[BS[v]] = modForShadowAffinity
	end
	ShadowSpellsEN = nil
	
	self.fadedAmount = 0
	
	-- CastBuff handlers should take a multiplier and modify it by any multipliers they infer
	self.ClassBuffs[BS["Fade"]] = self.Fade
	
	--[[
		For some odd reason, Vampiric Embrace tests out as obeying Silent Resolve, rather than Shadow Affinity. The good news is that it does get a threat reduction.
		1621 mb, 405 healed

		pulled aggro at 1435-1447

		1215.75 MB threat
		heal threat base = 202.5

		1215.75 + 202.5 * 1.1 = 1560.075
		1215.75 + (202.5  * 0.96) * 1.1 = 1429.59	<-- 1 point in silent resolve
		1215.75 + (202.5  * 0.75) * 1.1 = 1382.81	<-- 5 points in shadow affinity	
		
		Not sure what's up with the missing  ~5 threat. VE is 1 threat, probably modified by Shadow Affinity, and I procced Focused Casting multiple times, so that may
		account for it.
	]]--
	-- Need to test this.
	self.abilityThreatMods[BS["Vampiric Embrace"]] = modForSilentResolve
	
	self.CastHandlers[BS["Power Word: Shield"]] = function(self, rank)
		local ranknum = tonumber(rank:match("%d+"))
		local base = threatAmounts["pws"][ranknum] * self.impPWS * self.silentResolveMod * self:threatMods()
		self:_addThreat(base)
	end

	self.abilityThreatMods[BS["Holy Nova"]] = function(self, amt) return 0 end
	self.abilityThreatMods[BS["Shadowguard"]] = function(self, amt) return 0 end
	self.abilityThreatMods[BS["Binding Heal"]] = function(self, amt) return amt * 0.5 * self.silentResolveMod end
end

local shadowAffinityRanks = {0.92, 0.84, 0.75}
function Priest:ScanTalents()
	-- Scan talents
	self.silentResolveMod = 1 - (0.04 * select(5, GetTalentInfo(1, 3)))
	self.shadowAffinityMod = shadowAffinityRanks[select(5, GetTalentInfo(3, 3))] or 1
	self.impPWS = 1 + (select(5, GetTalentInfo(1, 5)) * 0.05)
end

function Priest:Fade(action, rank, applications)
	if action == "lose" then
		self:_addThreat(self.fadedAmount)
	elseif action == "gain" then
		local ranknum = tonumber(rank:match("%d+"))
		self.fadedAmount = max(0, threatAmounts["fade"][ranknum] * self.shadowAffinityMod) * self:threatMods()
		self:_addThreat(self.fadedAmount * -1)
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Priest = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
