local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54897 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "ROGUE" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Rogue = ThreatLib:GetModule("ClassCore"):NewModule(c)

local feintThreatAmounts = {
	-150, -240, -390, -600, -800, -1050
}

function Rogue:ClassInit()	
	self.className = "ROGUE"
	self.passiveThreatModifiers = 0.71
	
	-- CastHandlers should return true if they modified the threat level, false if they don't
	self.CastHandlers[BS["Feint"]] = function(self, rank) self:AddTargetThreat(self:Feint(rank)) end
	self.CastHandlers[BS["Vanish"]] = self.Vanish
	
	self.ThreatQueries[BS["Feint"]] = self.Feint
	self.ThreatQueries[BS["Sinister Strike"]] = self.BonescytheBonus
	self.ThreatQueries[BS["Backstab"]] = self.BonescytheBonus
	self.ThreatQueries[BS["Hemorrhage"]] = self.BonescytheBonus
	self.ThreatQueries[BS["Eviscerate"]] = self.BonescytheBonus
	self.ThreatQueries[BS["Anesthetic Poison"]] = function() return 0 end
	
	-- ThreatMods should return the modifications (if any) to the threat passed in
	self.abilityThreatMods[BS["Sinister Strike"]]	= self.BonescytheBonus
	self.abilityThreatMods[BS["Backstab"]]			= self.BonescytheBonus
	self.abilityThreatMods[BS["Hemorrhage"]]		= self.BonescytheBonus
	self.abilityThreatMods[BS["Eviscerate"]]		= self.BonescytheBonus	
	self.abilityThreatMods[BS["Anesthetic Poison"]]		= function() return 0 end
	
	-- Set names don't need to be localized.
	self.itemSets = {
		["Bloodfang"] = { 16908, 16909, 16832, 16906, 16910, 16911, 16905, 16907 },
		["Bonescythe"] = { 22478, 22477, 22479, 22480, 22482, 22483, 22476, 22481, 23060}
	}
end

function Rogue:ScanTalents()
	-- Scan talents
	local rank = select(5, GetTalentInfo(3, 3))
	self.feintMod = 1 + (0.1 * rank)
end

function Rogue:Feint(rank)
	local bfBonus = 1
	if self:getWornSetPieces("Bloodfang") >= 5 then
		bfBonus = 1.2
	end
	local ranknum = tonumber(rank:match("%d+"))
	return feintThreatAmounts[ranknum] * self.feintMod * self:threatMods() * bfBonus
end

function Rogue:Vanish()
	self:ReduceAllThreat(0)
end

function Rogue:BonescytheBonus(amt)
	if self:getWornSetPieces("Bonescythe") >= 6 then
		return amt * 0.92
	end
	return amt
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Rogue = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end