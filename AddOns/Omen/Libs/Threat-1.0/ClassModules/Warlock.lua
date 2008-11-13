local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 42123 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "WARLOCK" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local type = _G.type
local ipairs = _G.ipairs
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local UnitCreatureFamily = _G.UnitCreatureFamily
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local BR = AceLibrary("Babble-Race-2.2")
local Warlock = ThreatLib:GetModule("ClassCore"):NewModule(c)

--[[
	Health funnel threat = ?
	Unending breath doesn't seem to cause threat
	Drain life debuff = no threat
	Imp shadowbolt proc = no threat
	Drain soul debuff = no threat
	Amplify Curse = no threat
--]]

local afflictionSpells = { "Drain Life", "Unstable Affliction", "Drain Soul", "Curse of Doom", "Death Coil", "Seed of Corruption" }	
local destructionSpells = { "Hellfire",	"Rain of Fire", "Soul Fire", "Conflagrate", "Incinerate", "Shadow Bolt", "Shadowburn" }

function Warlock:ClassInit()	
	self.className = "WARLOCK"
	self.passiveThreatModifiers = 1
	
	-- CastBuff handlers should take a multiplier and modify it by any multipliers they infer
	self.ClassBuffs[BS["Master Demonologist"]] = function(action)
		if action ~= "lose" and UnitCreatureFamily( "pet" ) == BR["Imp"] then
			self:AddBuffThreatMultiplier(self.MDMod)
		end
	end

	-- CastHandlers should return true if they modified the threat level, false if they don't

	self.CastHandlers[BS["Soulshatter"]] = self.Soulshatter
	self.CastMissHandlers[BS["Soulshatter"]] = self.SoulshatterMiss

	self.CastHandlers[BS["Curse of Shadow"]] = self.CoS
	self.CastHandlers[BS["Curse of the Elements"]] = self.CoE
	self.CastHandlers[BS["Curse of Weakness"]] = self.CoW
	self.CastHandlers[BS["Curse of Recklessness"]] = self.CoR
	self.CastHandlers[BS["Curse of Tongues"]] = self.CoT
	self.CastHandlers[BS["Curse of Doom"]] = self.CoD
	self.CastHandlers[BS["Siphon Life"]] = self.SiphonLife
	self.CastHandlers[BS["Fear"]] = self.Fear
	self.CastHandlers[BS["Howl of Terror"]] = self.Howl
	self.CastHandlers[BS["Banish"]] = self.Banish

	self.CastHandlers[BS["Detect Invisibility"]] = self.Invis
	self.CastHandlers[BS["Shadow Ward"]] = self.ShadowWard
	self.CastHandlers[BS["Fel Armor"]] = self.FelArmor
	self.CastHandlers[BS["Demon Armor"]] = self.DemonArmor
	self.CastHandlers[BS["Demon Skin"]] = self.DemonSkin


	-- ThreatMods should return the modifications (if any) to the threat passed in
	-- self.abilityThreatMods["Sinister Strike"]	= self.BonescytheBonus
	
	self.abilityThreatMods[BS["Searing Pain"]] = self.SearingPain
	
	--Affliction
	
	for _,v in ipairs(afflictionSpells) do
		self.abilityThreatMods[BS[v]] = self.Affliction
	end
	
	--Plagueheart modded spells
	self.abilityThreatMods[BS["Siphon Life"]] = self.AfflictionSpecial
	self.abilityThreatMods[BS["Corruption"]] = self.AfflictionSpecial
	self.abilityThreatMods[BS["Curse of Agony"]] = self.AfflictionSpecial
	
	--Destruction
	
	for _,v in ipairs(destructionSpells) do
		self.abilityThreatMods[BS[v]] = self.Destruction
	end
	
	--Plagueheart modded spells
	self.abilityThreatMods[BS["Immolate"]] = self.DestructionSpecial
	
	self.itemSets = {
	 	["Nemesis"] = { 16927, 16928 , 16929, 16930, 16931, 16932, 16933, 16934  },
	 	["Plagueheart"] = { 22504, 22505, 22506, 22507, 22508, 22509, 22510, 22511, 23063 },
	}
	
	self.threatValues = {
		["searingpain"] = 2,
		["cos"] = { 44, 56, 67 },
		["coe"] = { 32, 46, 60, 69 }, 
		["cow"] = { 4, 12, 22, 32, 42, 42, 61, 69 },
		["cor"] = { 14, 28, 42, 56, 69 },
		["cot"] = { 26, 50 },
		["cod"] = { 60, 70 },
		["siphonlife"] = { 30, 38, 48, 58, 63, 70 },
		["fear"] = { 8, 32, 56 },
		["howl"] = { 40, 54 },
		["banish"] = { 56, 96 },
		["invis"] = 26,
		["shadowward"] = { 32, 42, 52, 60 },
		["felarmor"] = { 62, 69 },
		["demonarmor"] = { 20, 30, 40, 50, 60, 70 },
		["demonskin"] = { 1, 10 },
	}
	
	self.ExemptGains[BS["Life Tap"]] = true
	self.ExemptGains[BS["Death Coil"]] = true
	self.ExemptGains[BS["Siphon Life"]] = true
	self.ExemptGains[BS["Drain Life"]] = true
	self.ExemptGains[BS["Drain Mana"]] = true
	
end

local function parserank(rank, max)
	if type(rank) == "string" then
		rank = tonumber(rank:match("%d+"))
	end
	
	if not rank or rank > max then
		rank = max
	end
	
	return rank
end

function Warlock:ScanTalents()
	-- Scan talents
	self.MDMod = 1 - 0.04 * select( 5, GetTalentInfo(2, 17))
	self.afflictionModifier = 1 - 0.05 * select( 5, GetTalentInfo(1, 4))
	self.destructionModifier = 1 - 0.05 * select( 5, GetTalentInfo(3, 10))
end

-- This isn't an exact modeling of warlock threat, since global threat won't get halved on targets that resist Soulshatter
-- However, it should be close enough for gubmint work.
local function halveGlobalThreat(self)
	self:_multiplyThreat(0.5)
end

local function halveTargetThreat(self, target)
	self:_multiplyTargetThreat(0.5, target)
end

-- This gets called once for every target it hits
-- As such, we need to take care to only halve global threat once
-- and to only halve threat per target name once 
function Warlock:Soulshatter()
	for target in pairs(self.targetThreat) do
		self:ScheduleEvent("ThreatLib-Warlock-Soulshatter-" .. target, halveTargetThreat, 1.75, self, target)
	end
	self:ScheduleEvent("ThreatLib-Warlock-Soulshatter-GlobalThreat", halveGlobalThreat, 1.75, self)
end

function Warlock:SoulshatterMiss(target)
	if self:IsEventScheduled("ThreatLib-Warlock-Soulshatter-" .. target) then
		self:CancelScheduledEvent("ThreatLib-Warlock-Soulshatter-" .. target)
	end
end

function Warlock:Curses(table, rank)
	self:AddTargetThreat(table[rank] * 2 * self.afflictionModifier * self:threatMods())
end

function Warlock:CoS(rank)
	Warlock:Curses(self.threatValues.cos, parserank(rank, 3))
end
function Warlock:CoE(rank)
	Warlock:Curses(self.threatValues.coe, parserank(rank, 4))
end
function Warlock:CoW(rank)
	Warlock:Curses(self.threatValues.cow, parserank(rank, 8))
end
function Warlock:CoR(rank)
	Warlock:Curses(self.threatValues.cor, parserank(rank, 5))
end
function Warlock:CoT(rank)
	Warlock:Curses(self.threatValues.cot, parserank(rank, 2))
end
function Warlock:CoD(rank)
	Warlock:Curses(self.threatValues.cod, parserank(rank, 2))
end
function Warlock:SiphonLife(rank)
	Warlock:Curses(self.threatValues.siphonlife , parserank(rank, 6))
end
function Warlock:Fear(rank)
	Warlock:Curses(self.threatValues.fear, parserank(rank, 3))
end
function Warlock:Howl(rank)
	Warlock:Curses(self.threatValues.howl, parserank(rank, 2))
end
function Warlock:Banish(rank)
	self:AddTargetThreat(self.threatValues.banish[parserank(rank, 2)] * 2 * self:threatMods())
end

function Warlock:Invis()
	self:AddThreat(self.threatValues.invis * self:threatMods())
end
function Warlock:ShadowWard(rank)
	self:AddThreat(self.threatValues.shadowward[parserank(rank, 4)] * self:threatMods())
end
function Warlock:FelArmor(rank)
	self:AddThreat(self.threatValues.felarmor[parserank(rank, 2)] * self:threatMods())
end
function Warlock:DemonArmor(rank)
	self:AddThreat(self.threatValues.demonarmor[parserank(rank, 6)] * self:threatMods())
end
function Warlock:DemonSkin(rank)
	self:AddThreat(self.threatValues.demonskin[parserank(rank, 2)] * self:threatMods())
end

function Warlock:SearingPain(amt)
	return amt * self.threatValues.searingpain * self.destructionModifier
end

function Warlock:Affliction(amt)
	return amt * self.afflictionModifier
end

function Warlock:AfflictionSpecial(amt)
	local plagueheartBonus = 1
	
	if self:getWornSetPieces("Plagueheart") >= 6 then
		plagueheartBonus = 0.75
	end
	
	return amt * self.afflictionModifier * plagueheartBonus
end

function Warlock:Destruction(amt, dmg, isCrit)
	local plagueheartBonus = 1
	
	if isCrit and self:getWornSetPieces("Plagueheart") >= 6 then
		plagueheartBonus = 0.75
	end

	local nemesisBonus = 1
		
	if self:getWornSetPieces("Nemesis") == 8 then
		nemesisBonus = 0.8
	end

	return amt * self.destructionModifier * nemesisBonus * plagueheartBonus
end

function Warlock:DestructionSpecial(amt, dmg, isCrit)
	local plagueheartBonus = 1
	
	if self:getWornSetPieces("Plagueheart") >= 6 then
		if isCrit then
			plagueheartBonus = 0.75 * 0.75
		else
			plagueheartBonus = 0.75
		end
	end
	
	local nemesisBonus = 1
	
	if self:getWornSetPieces("Nemesis") == 8 then
		nemesisBonus = 0.8
	end	
	
	return amt * self.destructionModifier * nemesisBonus * plagueheartBonus
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Warlock = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
