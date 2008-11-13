local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 44618 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "DRUID" then return end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tonumber = _G.tonumber
local GetTalentInfo = _G.GetTalentInfo
local GetShapeshiftForm = _G.GetShapeshiftForm
local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Druid = ThreatLib:GetModule("ClassCore"):NewModule(c)


local HealsEN = { "Healing Touch", "Regrowth", "Rejuvenation", "Lifebloom", "Swiftmend" }
local threatValues = {
	["faerieFire"] = { nil, nil, nil, 108, 127 }, --TODO ranks 1-3
	["maul"] = { nil, nil, nil, nil, nil, nil, 207, 322 }, --TODO ranks 1-6
	["lacerate"] = { 0.2, 285 },
	["mangle"] = 1.3,
	["cower"] = { 240, 390, 600, 800, 1170 },
	["demoroar"] = 42,
}

-- recursive function to calculate linear threat for missing spell ranks
local function calcLinearThreat(data)
	if not data then
		return
	end
	if type(data) == "table" then
		for _,v in pairs(data) do
			calcLinearThreat(v)
		end
	elseif type(data) == "string" then
		local tbl = threatValues[data]
		local m = #tbl
		for i=1,m do
			if not tbl[i] then
				tbl[i] = (tbl[m] / m) * i
			end
		end
	end
end
calcLinearThreat({"faerieFire", "maul"})

function Druid:ClassInit()
	self.className = "Druid"
	
	self:GetStanceThreatMod()

	--Cast Handlers
	self.CastHandlers[BS["Growl"]] = self.Growl
	self.CastHandlers[BS["Faerie Fire"]] = self.FaerieFire
	self.CastHandlers[BS["Faerie Fire (Feral)"]] = self.FaerieFire
	self.CastHandlers[BS["Maul"]] = self.Maul
	self.CastHandlers[BS["Lacerate"]] = self.Lacerate
	self.CastHandlers[BS["Cower"]] = self.Cower
	self.CastHandlers[BS["Cyclone"]] = self.Cyclone
	self.CastHandlers[BS["Demoralizing Roar"]] = self.DemoRoar
	self.CastMissHandlers[BS["Demoralizing Roar"]] = self.DemoRoarMiss
	
	--Ability Threat Mods
	
	-- Subtlety for all Heals
	for _,v in ipairs(HealsEN) do
		self.abilityThreatMods[BS[v]] = self.Subtlety
	end
	
	-- Subtlety for all Arcane or Nature Damage, thats all on casts out there
	self.schoolThreatMods["Nature"] = self.Subtlety
	self.schoolThreatMods["Arcane"] = self.Subtlety
	
	self.abilityThreatMods[BS["Tranquility"]] = self.Tranquility
	self.abilityThreatMods[BS["Lacerate"]] = self.LacerateDmg
	self.abilityThreatMods[BS["Mangle (Bear)"]] = self.Mangle
	
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "GetStanceThreatMod")
	self.itemSets = {
		["Thunderheart"] = { 31042, 31034, 31039, 31044, 31048 }
	}
end

function Druid:ScanTalents()
	self.feralinstinctMod = 0.05 * select(5, GetTalentInfo(2, 3))
	self.subtletyMod = 1 - 0.04 * select(5, GetTalentInfo(3, 7))
	self.tranqMod = 1 - 0.5 * select(5, GetTalentInfo(3, 13))
end

-- get form passive threat modifier
-- this function has one issue, if the druid skipped his Aquatic Quest, cat form will have index 2 not 3 - maybe change detection
function Druid:GetStanceThreatMod()
	local form = GetShapeshiftForm()
	if form == 1 then
		self.passiveThreatModifiers = 1.3 + self.feralinstinctMod
	elseif form == 3 then
		self.passiveThreatModifiers = 0.71
	else
		self.passiveThreatModifiers = 1
	end
	self.totalThreatMods = nil		-- Needed to recalc total mods
end

function Druid:ParseRank(rank, max)

	if type(rank) == "string" then
		rank = tonumber(rank:match("%d+"))
	end
	
	if not rank or rank > max then
		rank = max
	end
	
	return rank
end

function Druid:Growl()
	if UnitExists("targettarget") then
		local myThreat = ThreatLib:GetThreat(UnitName("player"), UnitName("target"))
		local theirThreat = ThreatLib:GetThreat(UnitName("targettarget"), UnitName("target"))
		if myThreat >= theirThreat then 
			return 
		end
		local globalThreat = ThreatLib:GetThreat(UnitName("player"), "_GLOBAL_")
		self:SetTargetThreat(theirThreat - globalThreat)
	elseif UnitExists("target") then
		-- Assume we get max threat? This seems dangerous, but we need it to apply taunt in situations where the mob is sheeped/stunned/shackled/anything else that prevents a target
		local maxThreat = ThreatLib:GetMaxThreatOnTarget(UnitName("target")) 
		local globalThreat = ThreatLib:GetThreat(UnitName("player"), "_GLOBAL_")
		self:SetTargetThreat(maxThreat - globalThreat)
	end	
end

local function applyDemo(self, target, threat)
	self:_addTargetThreat(threat, target)
end
function Druid:DemoRoar(rank)
	local threat = threatValues.demoroar * self:threatMods()
	local ct = 0
	for target in pairs(self.targetThreat) do
		ct = ct + 1
	end
	for target in pairs(self.targetThreat) do
		self:ScheduleEvent("ThreatLib-Druid-DemoShout-" .. target, applyDemo, 0.5, self, target, threat / ct)
	end
end

function Druid:DemoRoarMiss(target)
	if self:IsEventScheduled("ThreatLib-Druid-DemoShout-" .. target) then
		self:CancelScheduledEvent("ThreatLib-Druid-DemoShout-" .. target)
	end
end

function Druid:FaerieFire(rank)
	self:AddTargetThreat(threatValues.faerieFire[self:ParseRank(rank, 5)] * self:threatMods())
end

function Druid:Maul(rank)
	self:AddTargetThreat(threatValues.maul[self:ParseRank(rank, 8)] * self:threatMods())
end

function Druid:Lacerate(rank)
	self:AddTargetThreat(threatValues.lacerate[self:ParseRank(rank, 1) + 1] * self:threatMods())
end

function Druid:Cower(rank)
	self:AddTargetThreat(-1 * threatValues.cower[self:ParseRank(rank, 5)] * self:threatMods())
end

function Druid:Subtlety(amount)
	return amount * self.subtletyMod
end

function Druid:Tranquility(amount)
	return self:Subtlety(amount * self.tranqMod)
end

function Druid:LacerateDmg(amount)
	return amount * threatValues.lacerate[1]
end

function Druid:Mangle(amount)
	local mangleMod = 1
	if self:getWornSetPieces("Thunderheart") >= 2 then	
		mangleMod = 1.15
	end
	
	return amount * threatValues.mangle * mangleMod
end

function Druid:Cyclone()
	self:AddTargetThreat(180 * self:threatMods())
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Druid = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
