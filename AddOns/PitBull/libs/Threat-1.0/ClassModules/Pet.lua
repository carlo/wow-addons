local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 41459 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local pairs = _G.pairs

local UnitName = _G.UnitName
local UnitAffectingCombat = _G.UnitAffectingCombat
local GetPetActionInfo = _G.GetPetActionInfo

local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

-- local _, c = _G.UnitClass("player")
-- We'll let it load for everyone, because sometimes non-hunter/locks get pets.
-- if c ~= "HUNTER" and c ~= "WARLOCK" then return end 
local c = "PET"
local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet

local BS = AceLibrary("Babble-Spell-2.2")
local Aura = AceLibrary("SpecialEvents-Aura-2.0")
local Pet = ThreatLib:GetModule("ClassCore"):NewModule(c)

-- Most of theses data come from KTM's pet module
local skillData = {
	-- Scaling skills
	[BS["Growl"]] = {
		rankLevel    = { 1, 10,  20,  30,  40,  50,  60,  70},
		rankThreat   = {50, 65, 110, 170, 240, 320, 415, 664},
		apBaseBonus  = 1235.6,
		apLevelMalus = 28.14,
		apFactor     = 5.7,
	},	
	[BS["Anguish"]] = {
		rankLevel    = { 50,  60,  69},
		rankThreat   = {300, 395, 632},
		apBaseBonus  = 109,
		apLevelMalus = 0,
		apFactor     = 0.698,
	},
	[BS["Torment"]] = {
		rankLevel    = {10, 20,  30,  40,  50,  60,  70},
		rankThreat   = {45, 75, 125, 215, 300, 395, 632},
		apBaseBonus  = 123,
		apLevelMalus = 0,
		apFactor     = 0.385,
	},
	[BS["Suffering"]] = {
		rankLevel    = { 24,  36,  48,  60,  63,  69},
		rankThreat   = {150, 300, 450, 600, 645, 885},
		apBaseBonus  = 124,
		apLevelMalus = 0,
		apFactor     = 0.547,	
	},
	
	-- I think that Intimidation scales, but I don't have any scaling data on it
	[BS["Intimidation"]] = {
		rankThreat = {580}
	},
	
	-- Unscaling skills
	[BS["Cower"]] = {
		rankThreat = {-30, -55,  -85, -125, -175, -225, -360},	
	},
	[BS["Cleave"]] = {
		rankThreat = {0, 0, 0, 0, 100, 130},
	},
	[BS["Soothing Kiss"]] = {
		rankThreat = {-45, -75, -127, -165, -275},
	},
}

local petAPThreshold = 0

local skillRanks = {}

function Pet:InitHooks()
	self:RegisterEvent("LOCALPLAYER_PET_RENAMED")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_PET")
end

function Pet:ClassInit()
	-- CastHandlers
	self.petName = UnitName("pet")
	self.isPetModule = true
	self.unitType = "pet"
	
	local playerClass = select(2, UnitClass("player"))
	self.petScaling = (playerClass == "HUNTER") or (playerClass == "WARLOCK")
	
	local function castHandler(self, rank, name) self:AddSkillThreat(name, rank) end
	for name in pairs(skillData) do
		self.CastHandlers[name] = castHandler
	end
	
	for k, v in pairs(skillRanks) do
		skillRanks[k] = nil
	end
	self.skillRanks = skillRanks
	
	self:ScanPetSkillRanks()
	self:RegisterEvent("PET_BAR_UPDATE", "ScanPetSkillRanks")
	self:RegisterEvent("UNIT_HEALTH")	
end

function Pet:ScanPetSkillRanks()
	for i = 1,10 do
		local name, rank = GetPetActionInfo(i)
		if skillData[name] then
			self.skillRanks[name] = rank
		end
	end
end

function Pet:AddSkillThreat(name, rank)
	rank = rank or self.skillRanks[name] or "1"
	local rankNum = tonumber(rank:match("%d+"))
	local skill = skillData[name]
	local rankLevel = skill.rankLevel
	local rankThreat = skill.rankThreat

	local threat, baseThreat = rankThreat[rankNum], rankThreat[rankNum]

	-- This could be optimized pretty heavily
	local petLevel = UnitLevel("pet")

	if skill.apFactor and petLevel then
		for i = 1, #rankLevel do
			if rankLevel[#rankLevel - i + 1] <= petLevel then
				rankNum = #rankLevel - i + 1
				break
			end
		end
		local baseThreat  = rankThreat[rankNum]
		
		local baseAP, posAPBuff, negAPBuff = UnitAttackPower("pet");	
		local petAP = baseAP + posAPBuff + negAPBuff;
		threat = threat + (max(0, petAP - (baseThreat + petLevel)) * skill.apFactor)
	end
	-- ThreatLib:Debug("Adding %s threat for %s, %s", threat, name, rank)
	if not threat then return end
	self:AddTargetThreat(threat * self:threatMods())	
end

function Pet:LOCALPLAYER_PET_RENAMED()
	self.petName = UnitName("pet")
end

local function reinitme(self)
	ThreatLib:GetModule("ClassCore"):ToggleModuleActive(self, false)
	self:InitHooks()
	ThreatLib:GetModule("ClassCore"):ToggleModuleActive(self, true)
	ThreatLib:PARTY_MEMBERS_CHANGED()
	ThreatLib:PLAYER_ENTERING_WORLD()
end

function Pet:UNIT_PET(arg1)
	if arg1 == "player" then
		self.petName = UnitName("pet")
		-- ThreatLib:Debug("Pet changed. Pet is %s", self.petName)
		if self.petName then
			self:ScheduleEvent("ThreatReInitPetModule", reinitme, 0.5, self)
		else
			-- ThreatLib:Debug("Pet despawn, setting pet out of combat")
			self:PLAYER_REGEN_ENABLED()
		end		
	end
end

function Pet:UNIT_NAME_UPDATE(arg1)
	if arg1 == "pet" then	
		self.petName = UnitName("pet")
		if self.petName then
			self:ScheduleEvent("ThreatReInitPetModule", reinitme, 0.5, self)
			ThreatLib:PARTY_MEMBERS_CHANGED()
		end		
	end
end

function Pet:UNIT_HEALTH(arg1)
	if arg1 == "pet" and UnitHealth(arg1) == 0 then
		-- Pet's dead!
		-- ThreatLib:Debug("Pet died, setting pet out of combat")
		self:PLAYER_REGEN_ENABLED()
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Pet = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end