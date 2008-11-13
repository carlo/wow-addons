local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 51732 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local UnitLevel = _G.UnitLevel
local AceLibrary = _G.AceLibrary

-- This is intended to be a separate config file, so that config changes don't require core edits

-- This is a stub and needs proper localization
local L = {
	["The Eye of Diminution"] = "The Eye of Diminution",
	["Fungal Bloom"]= "Fungal Bloom"
}

if GetLocale() == "deDE" then
	L["The Eye of Diminution"] = "Das Auge des Schwunds"
	L["Fungal Bloom"]	= "Pilzwucher"
end

if GetLocale() == "koKR" then
	L["The Eye of Diminution"] = "감쇠의 눈"
	L["Fungal Bloom"]	= "곰팡이 번식"
end

if GetLocale() == "frFR" then
	L["The Eye of Diminution"] = "L'Oeil de diminution"
	L["Fungal Bloom"] = "Floraison fongique"
end

if GetLocale() == "zhTW" then
	L["The Eye of Diminution"] = "統御之眼"
	L["Fungal Bloom"] = "真菌成長"
end

if GetLocale() == "zhCN" then
	L["The Eye of Diminution"] = "衰落之眼"
	L["Fungal Bloom"] = "蘑菇花"
end

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
function ThreatLib:ThreatInitData()
	self.BuffModifiers = {
		[BS["Tranquil Air"]] = function(self)
			self:AddBuffThreatMultiplier(0.8)
		end,
		[BS["Blessing of Salvation"]] = function(self)
			self:AddBuffThreatMultiplier(0.7)
		end,
		[BS["Greater Blessing of Salvation"]] = function(self)
			self:AddBuffThreatMultiplier(0.7)
		end,
		[L["Fungal Bloom"]] = function(self)
			self:AddBuffThreatMultiplier(0)
		end,
		[BS["Arcane Shroud"]] = function(self)
			local value = 0.3
			local pl = UnitLevel("player")
			
			if pl > 60 then
				value = value + (pl - 60) * 0.02
			end	
			self:AddBuffThreatMultiplier(value)
		end,
		[L["The Eye of Diminution"]] = function(self)	
			local value = 0.65
			local pl = UnitLevel("player")
			if pl > 60 then
				value = value + (pl - 60) * 0.01
			end
			self:AddBuffThreatMultiplier(value)
		end,
		[BS["Pain Suppression"]] = function(self, action, rank, applications)
			-- Only for 2.3+, apply 5% permanent threat reduction when Pain Suppression is gained.
			if ThreatLib.WowVersion >= 2 and ThreatLib.WowMajor >= 3 and action == "gain" then
				self:_reduceAllThreat(0.95)
			end
		end
	}
	
	self.DebuffModifiers = {
		[BS["Thunderfury"]] = function()
			return 1, 0
		end,

		-- Uncomment this once Insignifigance is in Babble-Spell
		-- See http://www.wowhead.com/?spell=40618
		[BS["Insignifigance"]] = function(self)
			self:AddDebuffThreatMultiplier(0)
		end,

		[BS["Fel Rage"]] = function(self)
			self:AddDebuffThreatMultiplier(0)
		end,
		
		-- Increases all threat done by 500% for the duration
		[BS["Spiteful Fury"]] = function(self)
			self:AddDebuffThreatMultiplier(5)
		end,
		
		[BS["Seethe"]] = function(self)
			self:AddDebuffThreatMultiplier(2)
		end
	}
	
	self.ThreatConstants = {
		healing = 0.5,
		meleeAggroGain = 1.1,
		rangeAggroGain = 1.3,
		rageGain = 5.0,
		energyGain = 5.0,
		manaGain = 0.5,
	}
	
	self.ThreatInitData = nil
end

_G.tinsert(ThreatLib.UpvalueFixers, function(lib) ThreatLib = lib end)

end
