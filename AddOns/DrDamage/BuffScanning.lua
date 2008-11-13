local playerClass = select(2,UnitClass("player"))
local playerHealer, playerCaster, playerMelee, playerHybrid
if playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" then playerHealer = true end
if playerClass == "MAGE" or playerClass == "PRIEST" or playerClass == "WARLOCK" then playerCaster = true end
if playerClass == "ROGUE" or playerClass == "WARRIOR" or playerClass == "HUNTER" then playerMelee = true end
if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then playerHybrid = true end

local BS
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2")
else
	BS = {}
	setmetatable(BS,{ __index = function(t,k) return k end })
end

local function DrD_LoadAuras()
	DrDamage.PlayerAura = {
		--Core buffs
		["Bloodlust"] = { Value = 1.3, ModType = "CastTime" },
		["Heroism"] = { Value = 1.3, ModType = "CastTime" },
		["Inspiring Presence"] = { Value = 1, ModType = "Hit", },
	}
	if playerCaster or playerHybrid then
		DrDamage.PlayerAura["Totem of Wrath"] = { Value = 3, ModType = "Hit", Caster = true }
		DrDamage.PlayerAura["Vibrant Blood"] = { Value = 0.1, Caster = true }
		DrDamage.PlayerAura["Power Infusion"] = { School = "All", Value = 0.2, Caster = true }
		DrDamage.PlayerAura["Bloodgem Infusion"] = { School = "All", Value = 0.05, Caster = true }	
	end
	if playerHealer then
		DrDamage.PlayerAura["A'dal's Song of Battle"] = { School = "Healing", Value = 0.05 }
		DrDamage.PlayerAura["Vile Slime"] = { School = "Healing", Value = -0.5 }
		DrDamage.PlayerAura["Debilitating Spray"] = { School = "Healing", Value = -0.5 }
		DrDamage.PlayerAura["Vile Sludge"] = { School = "Healing", Value = -0.5 }	
		DrDamage.PlayerAura["Nether Portal - Serenity"] = { School = "Healing", Value = 0.05, Apps = true }
		DrDamage.HealingBuffs = {
			["Amplify Magic"] = { ModType = "RankTable", Ranks = 6, Value = { 30, 60, 100, 150, 180, 240 }, },
			["Quick Recovery"] = { Ranks = 2, Value = 0.1 },
			["Fel Armor"] = { Value = 0.2, },
		}
	end
	DrDamage.Debuffs = {
		--["Berserking"] = { Value = 0.1, Texture = "Spell_Nature_BloodLust", ModType = "Texture" },
		--["Evocation"] = { Value = 2 },
		--["Recklessness"] = { Value = 0.2 },
		["Stormstrike"] = { School = "Nature", Value = 0.2, Class = { "DRUID", "SHAMAN", "ROGUE", "HUNTER" }, },
	}
	if playerCaster or playerHybrid then
		--School
		DrDamage.Debuffs["Curse of Shadow"] = { School = { "Shadow", "Arcane" }, Value = 0.1, Class = { "WARLOCK", "PRIEST", "DRUID", }, Affliction = true, }
		DrDamage.Debuffs["Shadow Vulnerability"] = { School = "Shadow", Texture = "Spell_Shadow_ShadowBolt", Value = 0.2, Apps2 = true, Value2 = 0.02, Class = { "WARLOCK", "PRIEST", }, ModType = "Texture", }
		DrDamage.Debuffs["Fire Vulnerability"] = { School = "Fire", Apps = true, Value = 0.03, Class = { "WARLOCK", "SHAMAN", "MAGE", }, }
		DrDamage.Debuffs["Curse of the Elements"] = { School = { "Fire", "Frost" }, Value = 0.1, Class = { "WARLOCK", "SHAMAN", "MAGE", }, Affliction = true, }
		DrDamage.Debuffs["Winter's Chill"] = { School = "Frost", Apps = true, Value = 2, ModType = "Crit", Class = { "SHAMAN", "MAGE", }, }
		--General
		DrDamage.Debuffs["Spell Vulnerability"] = { Value = 0.15, Caster = true }
		DrDamage.Debuffs["Misery"] = { Value = 0.01, Ranks = 5, Caster = true }
		DrDamage.Debuffs["Magic Disruption"] = { Value = 0.05, Apps = true, Caster = true }
	end
	if playerHealer then
		DrDamage.Debuffs["Wound Poison"] = { School = "Healing", Apps = 5, Value = -0.1, }
		DrDamage.Debuffs["Blood Fury"] = { School = "Healing", Value = -0.5, }
		DrDamage.Debuffs["Mortal Strike"] = { School = "Healing", Value = -0.5, }
		DrDamage.Debuffs["Hex of Weakness"] = { School = "Healing", Value = -0.2, }
		DrDamage.Debuffs["Necrotic Poison"] = { School = "Healing", Value = -0.9, }
		DrDamage.Debuffs["Veil of Shadow"] = { School = "Healing", Value = -0.75, }
		DrDamage.Debuffs["Nether Portal - Dominance"] = { School = "Healing", Value = -0.01, Apps = true }
	end
	if playerMelee or playerHybrid then
		DrDamage.Debuffs["Shadowform"] = { School = {"Ranged", "Physical"}, Value = -0.1 }
		DrDamage.Debuffs["Armor Disruption"] = { School = {"Ranged", "Physical"}, Value = 0.05, Apps = true }
		DrDamage.Debuffs["Hemorrhage"] = { School = {"Ranged", "Physical"}, Value = { 3, 5, 7, 10 }, Ranks = 4, ModType = "BaseBonus" }
	end
end

DrD_LoadAuras()
DrD_LoadAuras = nil