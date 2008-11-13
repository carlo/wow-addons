local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 39751 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "MAGE" then return end 

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local select = _G.select
local floor = _G.floor
local max = _G.max
local GetTalentInfo = _G.GetTalentInfo
local GetTime = _G.GetTime

local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Mage = ThreatLib:GetModule("ClassCore"):NewModule(c)

--[[
	["mage"] = 
	{
		["arcanist"] = false, 		-- 8 piece bonus
		["netherwind"] = false, 	-- 3 piece
		["arcanethreat"] = 0.0,		-- almost a modifier to global threat (spells only) e.g. "-0.4" for 2/2 talent points.
		["frostthreat"] = 0.0, 		-- almost a modifier to global threat (spells only) e.g. "-0.3" for 3/3 talent points.
		["firethreat"] = 0.0, 		-- almost a modifier to global threat (spells only) e.g. "-0.3" for 2/2 talent points.
	},
]]--

local frostChanneling = { 0, 0.04, 0.07, 0.10 }

function Mage:ClassInit()	
	self.className = "MAGE"
	self.passiveThreatModifiers = 1

	self.ClassBuffs[BS["Invisibility"]] = self.Invisibility
	
	-- School names come through in english thanks to Parser-3.0
	self.schoolThreatMods["Fire"] = function(self, amt) return amt * self.fireThreatMod * self:ItemSetMods() end
	self.schoolThreatMods["Frost"] = function(self, amt) return amt * self.frostThreatMod * self:ItemSetMods() end
	self.schoolThreatMods["Arcane"] = function(self, amt) return amt * self.arcaneThreatMod * self:ItemSetMods() end
	
	self.abilityThreatMods[BS["Scorch"]] = self.NWBonus100
	self.abilityThreatMods[BS["Arcane Missiles"]] = self.NWBonus20
	self.abilityThreatMods[BS["Fireball"]] = self.NWBonus100
	self.abilityThreatMods[BS["Frostbolt"]] = self.NWBonus100
	
	-- I tested Counterspell with a level 32 mage. I would like mages of other levels
	-- to test its threat value as well.
	self.CastHandlers[BS["Counterspell"]] = function() self:AddTargetThreat(300 * self:threatMods()) end
	
	self.itemSets = {
		["Arcanist"] 	= {16795, 16796, 16797, 16800, 16802, 16799, 16798, 16801},
		["Netherwind"]	= {16914, 16915, 16917, 16912, 16818, 16918, 16916, 16913}
	}	
end

function Mage:ScanTalents()
	self.arcaneThreatMod = 1 - (select(5, GetTalentInfo(1,1)) * 0.2)
	self.frostThreatMod = 1 - frostChanneling[select(5, GetTalentInfo(3,12)) + 1]
	self.fireThreatMod = 1 - (select(5, GetTalentInfo(2,9)) * 0.05)
end

function Mage:ItemSetMods()
	local mod = 1
	if self:getWornSetPieces("Arcanist") >= 8 then
		mod = mod * 0.85
	end
	return mod
end

local invisModifiers = {90/100, 80/90, 70/80, 60/70, 0}
local function InvisUpdate()
	local self = Mage
	self.invisTickCount = self.invisTickCount + 1
	if self.invisTickCount > 5 then
		self:CancelScheduledEvent("updateInvisAggroModifier")
		return
	end	
	self:_reduceAllThreat(invisModifiers[self.invisTickCount])
end

function Mage:Invisibility(action, rank)
	if action == "gain" then
		self.invisStartTime = GetTime()
		self.invisTickCount = 0
		self:ScheduleRepeatingEvent("updateInvisAggroModifier", InvisUpdate, 1)
	elseif action == "lose" then
		if self:IsEventScheduled("updateInvisAggroModifier") then
			self:CancelScheduledEvent("updateInvisAggroModifier")
		end
	end
end

function Mage:NWBonus100(amt)
	if self:getWornSetPieces("Netherwind") >= 3 then
		amt = max(0, amt - 100)
	end
	return amt
end

function Mage:NWBonus20(amt)
	if self:getWornSetPieces("Netherwind") >= 3 then
		amt = max(0, amt - 20)
	end
	return amt
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Mage = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
