local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54897 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "WARRIOR" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local max = _G.max
local tonumber = _G.tonumber
local type = _G.type
local select = _G.select
local GetTalentInfo = _G.GetTalentInfo
local GetShapeshiftForm = _G.GetShapeshiftForm
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Aura = AceLibrary("SpecialEvents-Aura-2.0")
local Warrior = ThreatLib:GetModule("ClassCore"):NewModule(c)

-- For devastate.
local localSunder = BS["Sunder Armor"]

local MSBTTalentMod = 1.0
local MSBTMod = 1.0
local zerkerStanceMod = 0

local threatValues = {
	["sunder"] 			= {nil, nil, nil, nil, 260, 301},
	["shieldBash"]		= {nil, nil, 180, 230},
	["revenge"]			= {nil, nil, nil, nil, nil, nil, nil, 201},
	["heroicStrike"]	= {nil, nil, nil, nil, nil, nil, nil, 145, 173, 196, 220},
	["shieldSlam"]		= {nil, nil, nil, 250, 286, 307},
	["cleave"]			= {nil, nil, nil, nil, 100, 130},
	["thunderclap"]		= 1.75,
	["execute"]			= 1.25,
	["hamstring"]		= {nil, nil, nil, 181},
	["mockingBlow"]		= {nil, nil, nil, nil, nil, 290},
	["disarm"]			= 104,
	["battleShout"]		= {nil, nil, nil, nil, nil, nil, 30, 69},
	["demoShout"]		= {nil, nil, nil, nil, nil, nil, 56},
}

local playerLevel = UnitLevel("player")
	
function Warrior:ClassInit()
	self.className = "Warrior"

	-- Scan talents
	-- Defiance

	self:GetStanceThreatMod()
	
	-- CastHandlers should return true if they modified the threat level, false if they don't
	self.CastHandlers[BS["Taunt"]] 				= self.Taunt
	self.CastHandlers[BS["Sunder Armor"]] 		= function(self, rank) self:AddTargetThreat(self:SunderArmor(rank)) end
	self.CastHandlers[BS["Heroic Strike"]]		= function(self, rank) self:AddTargetThreat(self:HeroicStrike(rank)) end
	self.CastHandlers[BS["Shield Bash"]]		= function(self, rank) self:AddTargetThreat(self:ShieldBash(rank)) end
	self.CastHandlers[BS["Shield Slam"]]		= function(self, rank) self:AddTargetThreat(self:ShieldSlam(rank)) end
	self.CastHandlers[BS["Revenge"]]			= function(self, rank) self:AddTargetThreat(self:Revenge(rank)) end
	self.CastHandlers[BS["Mocking Blow"]]		= function(self, rank) self:AddTargetThreat(self:MockingBlow(rank)) end
	self.CastHandlers[BS["Commanding Shout"]]	= function(self) self:AddThreat(68) end
	self.CastHandlers[BS["Hamstring"]]			= function(self, rank) self:AddTargetThreat(self:Hamstring(rank)) end
	self.CastHandlers[BS["Battle Shout"]]		= function(self, rank) self:AddTargetThreat(self:BattleShout(rank)) end
	self.CastHandlers[BS["Disarm"]]				= function(self, rank) self:AddTargetThreat(self:Disarm(rank)) end
	self.CastHandlers[BS["Devastate"]]			= function(self, rank) self:AddTargetThreat(self:Devastate(rank)) end
	self.CastHandlers[BS["Demoralizing Shout"]]	= function(self, rank) self:AddTargetThreat(self:DemoShoutThreat(rank)) end
	self.CastMissHandlers[BS["Demoralizing Shout"]]	= self.DemoShoutMiss
	
	-- This provides a means for other mods to get effective threat values for these abilties
	self.ThreatQueries[BS["Sunder Armor"]] 		= self.SunderArmor
	self.ThreatQueries[BS["Heroic Strike"]] 	= self.HeroicStrike
	self.ThreatQueries[BS["Shield Bash"]] 		= self.ShieldBash
	self.ThreatQueries[BS["Shield Slam"]] 		= self.ShieldSlam
	self.ThreatQueries[BS["Revenge"]] 			= self.Revenge
	self.ThreatQueries[BS["Commanding Shout"]]	= function() return 68 end
	self.ThreatQueries[BS["Mocking Blow"]] 		= self.MockingBlow
	self.ThreatQueries[BS["Hamstring"]] 		= self.Hamstring
	self.ThreatQueries[BS["Battle Shout"]] 		= self.BattleShout
	self.ThreatQueries[BS["Demoralizing Shout"]]= self.DemoShoutThreat
	self.ThreatQueries[BS["Thunder Clap"]]		= self.Thunderclap
	self.ThreatQueries[BS["Execute"]]			= self.Execute
	self.ThreatQueries[BS["Mortal Strike"]]		= self.MSBT
	self.ThreatQueries[BS["Bloodthirst"]]		= self.MSBT
	self.ThreatQueries[BS["Disarm"]]			= self.Disarm
	self.ThreatQueries[BS["Devastate"]]			= self.Devastate	
	
	-- ThreatMods should return the modifications (if any) to the threat passed in
	self.abilityThreatMods[BS["Thunder Clap"]]	= self.Thunderclap
	self.abilityThreatMods[BS["Execute"]]		= self.Execute
	
	self.abilityThreatMods[BS["Mortal Strike"]]		= self.MSBT
	self.abilityThreatMods[BS["Bloodthirst"]]		= self.MSBT
	
	-- Set names don't need to be localized.
	self.itemSets = {
		["Might"] = { 16866, 16867, 16868, 16862, 16864, 16861, 16865, 16863 }
	}
	
	self.lastDevastateTime = 0

	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "GetStanceThreatMod" )
end

function Warrior:ScanTalents()
	local rank = _G.select(5, GetTalentInfo(3, 9))
	self.defianceMod = 1 + (0.05 * rank)

	-- Tactical mastery
	local rank = _G.select(5, GetTalentInfo(3, 2))
	MSBTTalentMod = 1 + (0.21 * rank)
	
	-- Improved berserker stance
	local rank = _G.select(5, GetTalentInfo(2, 20))
	zerkerStanceMod = 0.02 * rank	
	
	-- We need to watch debuffs if we're devastate, unfortunately.
	if _G.select(5, GetTalentInfo(3, 22)) > 0 then
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "GetDevastateSunder")
	end
end

function Warrior:GetLinearThreatGuess(index, rank)
	if type(rank) == "string" then
		local ranknum = tonumber(rank:match("%d+"))
		rank = ranknum
	end
	local threatValues_index = threatValues[index]
	local v = threatValues_index[rank]
	if not v then
		local m = threatValues_index[#threatValues_index]
		v = (m / #threatValues_index) * rank
	end
	return v
end

function Warrior:GetStanceThreatMod()
	if GetShapeshiftForm() == 2 then
		self.passiveThreatModifiers = 1.3 * self.defianceMod
		MSBTMod = MSBTTalentMod
	elseif GetShapeshiftForm() == 3 then
		-- Currently assuming that the zerker change is multiplicative
		self.passiveThreatModifiers = 0.8 * (1 - zerkerStanceMod)
		-- Change to this if it tests out to additive
		-- self.passiveThreatModifiers = 0.8 - zerkerStanceMod
		MSBTMod = 1.0
	else
		self.passiveThreatModifiers = 0.8
		MSBTMod = 1.0
	end
	self.totalThreatMods = nil		-- Needed to recalc total mods
end

function Warrior:SunderArmor(rank)
	local sunderMod = 1.0
	if self:getWornSetPieces("Might") >= 8 then	
		sunderMod = 1.15;
	end
	local ranknum = tonumber(rank:match("%d+"))
	local threat = self:GetLinearThreatGuess("sunder", ranknum)
	return threat * sunderMod * self:threatMods()
end

function Warrior:Taunt()
	if UnitExists("targettarget") then
		local myThreat = ThreatLib:GetThreat(UnitName("player"), UnitName("target"))
		local theirThreat = ThreatLib:GetThreat(UnitName("targettarget"), UnitName("target"))
		ThreatLib:Debug("Taunting - my threat is %s, %s's threat on %s is %s.", myThreat, UnitName("targettarget"), UnitName("target"), theirThreat)
		if myThreat >= theirThreat then 
			ThreatLib:Debug("No threat change; my threat exceeds the current target's threat.")
			return 
		end
		local globalThreat = ThreatLib:GetThreat(UnitName("player"), "_GLOBAL_")
		self:SetTargetThreat(theirThreat - globalThreat)
	elseif UnitExists("target") then
		-- Assume we get max threat? This seems dangerous, but we need it to apply taunt in situations where the mob is sheeped/stunned/shackled/anything else that prevents a target
		local maxThreat = ThreatLib:GetMaxThreatOnTarget(UnitName("target")) 
		local globalThreat = ThreatLib:GetThreat(UnitName("player"), "_GLOBAL_")
		ThreatLib:Debug("Taunting - no targettarget. Setting my threat on %s to %s - %s = %s", UnitName("target"), maxThreat, globalThreat, maxThreat - globalThreat)
		self:SetTargetThreat(maxThreat - globalThreat)
	end	
end

function Warrior:HeroicStrike(rank)
	local threat = self:GetLinearThreatGuess("heroicStrike", rank)
	return threat * self:threatMods()
end

function Warrior:ShieldBash(rank)
	local threat = self:GetLinearThreatGuess("shieldBash", rank)
	return threat * self:threatMods()
end

function Warrior:ShieldSlam(rank)
	local threat = self:GetLinearThreatGuess("shieldSlam", rank)
	return threat * self:threatMods()
end

function Warrior:Revenge(rank)
	local threat = self:GetLinearThreatGuess("revenge", rank)
	return threat * self:threatMods()
end

function Warrior:MockingBlow(rank)
	local threat = self:GetLinearThreatGuess("mockingBlow", rank)
	return threat * self:threatMods()
end

function Warrior:Hamstring(rank)
	local threat = self:GetLinearThreatGuess("hamstring", rank)
	return threat * self:threatMods()
end

function Warrior:Thunderclap(amt)
	return amt * threatValues.thunderclap
end

function Warrior:Execute(amt)
	return amt * threatValues.execute
end

function Warrior:MSBT(amt)
	return amt * MSBTMod
end

function Warrior:Disarm()
	return threatValues.disarm * self:threatMods()
end

function Warrior:BattleShout(rank)
	local threat = self:GetLinearThreatGuess("battleShout", rank)
	return threat * self:threatMods()
end

local function applyDemo(self, target, threat)
	self:_addTargetThreat(threat, target)
end
function Warrior:DemoShoutThreat(rank)
	local threat = self:GetLinearThreatGuess("demoShout", rank) * self:threatMods()
	local ct = 0
	for target in pairs(self.targetThreat) do
		ct = ct + 1
	end
	return threat / ct
end

function Warrior:DemoShout(rank)
	local threat = self:DemoShoutThreat(rank)	
	for target in pairs(self.targetThreat) do
		self:ScheduleEvent("ThreatLib-Warrior-DemoShout-" .. target, applyDemo, 0.5, self, target, threat)
	end
end

function Warrior:DemoShoutMiss(target)
	if self:IsEventScheduled("ThreatLib-Warrior-DemoShout-" .. target) then
		self:CancelScheduledEvent("ThreatLib-Warrior-DemoShout-" .. target)
	end
end

local devastateThreat = {119, 134, 147, 162, 176, 176}
function Warrior:Devastate(rank)
	-- local threat = self:GetLinearThreatGuess("devastate", rank)
	local threat = devastateThreat[1]
	for buffName, applications in Aura:DebuffIter("target") do
		if buffName == BS["Sunder Armor"] then
			threat = devastateThreat[applications+1]
			break
		end
	end	
	self.lastDevastateTime = GetTime()
	return threat * self:threatMods()
end

-- This is an incredibly ugly hack, but will hopefully tide us over until 2.4.
function Warrior:GetDevastateSunder(arg1)
	if GetTime() - self.lastDevastateTime < 2 and arg1:match(localSunder) then
		if playerLevel < 58 then
			rank = "Rank 4"
		elseif playerLevel < 68 then
			rank = "Rank 5"
		else
			rank = "Rank 6"
		end
		self:AddTargetThreat(self:SunderArmor(rank))
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Warrior = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
