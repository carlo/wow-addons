if select(2, UnitClass("player")) ~= "ROGUE" then return end
local BR
local GetSpellInfo = GetSpellInfo
local UnitDebuff = UnitDebuff
local UnitCreatureType = UnitCreatureType
local math_min = math.min
local math_floor = math.floor
local BI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

if GetLocale() ~= "enUS" then 
	BI = LibStub:GetLibrary("LibBabble-Inventory-3.0"):GetLookupTable()
else
	BI = {}
	setmetatable(BI,{ __index = function(t,k) return k end })
end

function DrDamage:PlayerData()

	--Special calculation
	--self.Calculation["Mace Specialization"] = function( calculation, value )
	--	if self:GetWeaponType() == BI["One-Handed Maces"] then
	--		calculation.critM = calculation.critM * (1 + 0.01 * value)
	--	end
	--end
	--General
	local TargetIsPoisoned = false
	local Mutilate = GetSpellInfo(1329)
	self.Calculation["TargetAura"] = function()
		local temp = TargetIsPoisoned
		local TargetIsPoisoned = false
		for i=1,40 do
			local name, _, _, _, debuffType = UnitDebuff("target",i)
			if name then
				if debuffType == "Poison" then
					TargetIsPoisoned = true
					break
				end
			else break end
		end
		if temp ~= TargetIsPoisoned then
			return true, Mutilate
		end
	end
	
	self.Calculation["ROGUE"] = function( calculation, ActiveAuras, BuffTalentRanks, action, baseAction )
		if BuffTalentRanks["Prey on the Weak"] then
			if(UnitHealth("target") ~= 0) then
				if((UnitHealth("player") / UnitHealthMax("player")) > (UnitHealth("target")) / UnitHealthMax("target")) then
					calculation.critM = calculation.critM + BuffTalentRanks["Prey on the Weak"]
				end
			end
		end
		if BuffTalentRanks["Remorseless Attacks"] and ActiveAuras["Remorseless"] then
			calculation.critPerc = calculation.critPerc + BuffTalentRanks["Remorseless Attacks"]
		end
		if BuffTalentRanks["Improved Kidney Shot"] and ActiveAuras["Kidney Shot"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Kidney Shot"])
		end
		if BuffTalentRanks["Find Weakness"] and ActiveAuras["Find Weakness"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Find Weakness"])
		end
		if ActiveAuras["Master of Subtlety"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Master of Subtlety"])
		end
		if BuffTalentRanks["Dirty Deeds"] then
			if(UnitHealth("target") ~= 0) then
				if (UnitHealth("target") / UnitHealthMax("target")) < 0.35 then
					calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Dirty Deeds"])
				end
			end
		end
		if ActiveAuras["Shadowstep"] then
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end	
	self.Calculation["Murder"] = function( calculation, talentValue )
		local targetType = UnitCreatureType("target")
		
		if BR and targetType and BR:HasReverseTranslation( targetType ) then
			targetType = BR:GetReverseTranslation( targetType )
		end
		
		if targetType == "Humanoid"
		or targetType == "Beast"
		or targetType == "Giant"
		or targetType == "Dragonkin" then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
		end
	end
	
	--Spell specific
	self.Calculation["Mutilate"] = function( calculation, ActiveAuras )
		if TargetIsPoisoned then
			calculation.dmgM = calculation.dmgM * 1.5
		end
	end
	self.Calculation["Envenom"] = function( calculation, ActiveAuras, BuffTalentRanks, action )
		local cp = calculation.Melee_ComboPoints
		if ActiveAuras["Deadly Poison"] and  cp > 0 then
			local bonus = (self:GetSetAmount("Deathmantle") >= 2) and 40 or 0
			calculation.minDam = calculation.minDam + action.PerCombo * math_min(ActiveAuras["Deadly Poison"], cp) + cp * bonus
			calculation.maxDam = calculation.maxDam + action.PerCombo * math_min(ActiveAuras["Deadly Poison"], cp) + cp * bonus
		else
			calculation.zero = true
		end
	end
	
	--Set bonuses
	self.SetBonuses["Deathmantle"] = { 30144, 30145, 30146, 30147, 30148, }
	self.SetBonuses["Slayer's Armor"] = { 31026, 31027, 31028, 31029, 31030, 34448, 34558, 34575 }
	
	self.SetBonuses["Eviscerate"] = function( calculation )
		local cp = calculation.Melee_ComboPoints
		if cp > 0 and self:GetSetAmount("Deathmantle") >= 2 then
			calculation.minDam = calculation.minDam + cp * 40
			calculation.maxDam = calculation.maxDam + cp * 40
		end
	end
	self.SetBonuses["Backstab"] = function( calculation )
		if self:GetSetAmount("Slayer's Armor") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.06
		end
	end
	self.SetBonuses["Sinister Strike"] = self.SetBonuses["Backstab"]
	self.SetBonuses["Mutilate"] = self.SetBonuses["Backstab"]
	self.SetBonuses["Hemorrhage"] = self.SetBonuses["Backstab"]
	
	
	--Auras
	local dPoison = { 2818, 2819, 11353, 11354, 25349, 26968, 27187, 57969, 57970 }			
	for _, v in ipairs(dPoison) do
		self.TargetAura[GetSpellInfo(v)] = { ModType = "ActiveAura", ActiveAura = "Deadly Poison", Spell = { GetSpellInfo(32645), GetSpellInfo(1329) }, SelfCast = true }
	end
	
	--Remorseless
	--Find Weakness
	--Shadowstep
	--Kidney Shot
	--Hunger for Blood
	self.PlayerAura[GetSpellInfo(14143)] = { ModType = "ActiveAura", ActiveAura = "Remorseless" }
	self.PlayerAura[GetSpellInfo(31234)] = { ModType = "ActiveAura", ActiveAura = "Find Weakness" }
	self.PlayerAura[GetSpellInfo(36554)] = { ModType = "ActiveAura", ActiveAura = "Shadowstep" }
	self.TargetAura[GetSpellInfo(408)] = { ModType = "ActiveAura", ActiveAura = "Kidney Shot", SelfCast = true }
	self.PlayerAura[GetSpellInfo(51662)] = { ModType = "ActiveAura", ActiveAura = "Hunger For Blood" }
	self.PlayerAura[GetSpellInfo(31221)] = { ModType = "ActiveAura", ActiveAura = "Master of Subtlety" }
	
	self.spellInfo = {
		[GetSpellInfo(1752)] = {
			["Name"] = "Sinister Strike",
			[0] = { Energy = 45, WeaponDamage = 1 },
			[1] = { 3 },
			[2] = { 6 },
			[3] = { 10 },
			[4] = { 15 },
			[5] = { 22 },
			[6] = { 33 },
			[7] = { 52 },
			[8] = { 68 },
			[9] = { 80 },
			[10] = { 98 },
			[11] = { 150 },
			[12] = { 180 },
		},
		[GetSpellInfo(53)] = {
			["Name"] = "Backstab",
			[0] = { Energy = 60, WeaponDamage = 1.5, Weapon = "Daggers" },
			[1] = { 15 },
			[2] = { 30 },
			[3] = { 48 },
			[4] = { 69 },
			[5] = { 90 },
			[6] = { 135 },
			[7] = { 165 },
			[8] = { 210 },
			[9] = { 225 },
			[10] = { 255 },
			[11] = { 382.5 },
			[12] = { 465 },
		},
		[GetSpellInfo(2098)] = {
			["Name"] = "Eviscerate",
			[0] = { Energy = 35, ComboPoints = true, APBonus = { 0.03, 0.06, 0.09, 0.12, 0.15 } },
			[1] = { 6, 10, PerCombo = 5 },
			[2] = { 14, 22, PerCombo = 11 },
			[3] = { 25, 39, PerCombo = 19 },
			[4] = { 41, 61, PerCombo = 31 },
			[5] = { 60, 90, PerCombo = 45 },
			[6] = { 93, 137, PerCombo = 71 },
			[7] = { 144, 212, PerCombo = 110 },
			[8] = { 199, 295, PerCombo = 151 },
			[9] = { 224, 332, PerCombo = 170 },
			[10] = { 245, 365, PerCombo = 185 },
			[11] = { 405, 613, PerCombo = 301 },
			[12] = { 497, 751, PerCombo = 370 },
		},
		[GetSpellInfo(8676)] = {
			["Name"] = "Ambush",
			[0] = { Energy = 60, WeaponDamage = 2.75, Weapon = "Daggers" },
			[1] = { 70 },
			[2] = { 110 },
			[3] = { 137.5 },
			[4] = { 203.5 },
			[5] = { 253 },
			[6] = { 319 },
			[7] = { 368.5 },
			[8] = { 508.75 },
			[9] = { 770 },
			[9] = { 907.5 },
		},
		[GetSpellInfo(1776)] = {
			["Name"] = "Gouge",
			[0] = { Energy = 45, APBonus = 0.21, Cooldown = 10 },
			["None"] = { 1 },
		},	
		[GetSpellInfo(14278)] = {
			["Name"] = "Ghostly Strike",
			[0] = { Energy = 40, WeaponDamage = 1.25, Cooldown = 20, NoNormalization = true },
			["None"] = { 0 },
		},
		[GetSpellInfo(14251)] = {
			["Name"] = "Riposte",
			[0] = { Energy = 10, WeaponDamage = 1.5, NoNormalization = true, NoWeapon = true },
			["None"] = { 0 },
		},
		[GetSpellInfo(703)] = {
			["Name"] = "Garrote",
			[0] = { Energy = 50, NoCrits = true, APBonus = 0.42, eDuration = 18, Ticks = 3, NoWeapon = true, Bleed = true },
			[1] = { 120 },
			[2] = { 162 },
			[3] = { 222 },
			[4] = { 270 },
			[5] = { 342 },
			[6] = { 426 },
			[7] = { 510 },
			[8] = { 646 },
			[9] = { 714 },
		},
		[GetSpellInfo(1943)] = {
			["Name"] = "Rupture",
			[0] = { Energy = 25, NoCrits = true, ComboPoints = true, APBonus = { 0.06, 0.12, 0.18, 0.24, 0.3 }, ExtraPerCombo = { 0, 0, 1, 3, 6 }, eDuration = 6, DurationPerCombo = 2, Bleed = true },
			[1] = { 40, PerCombo = 20, Extra = 4 },
			[2] = { 60, PerCombo = 30, Extra = 6 },
			[3] = { 88, PerCombo = 42, Extra = 8 },
			[4] = { 128, PerCombo = 57, Extra = 10 },
			[5] = { 176, PerCombo = 79, Extra = 14 },
			[6] = { 272, PerCombo = 108, Extra = 16 },
			[7] = { 324, PerCombo = 136, Extra = 22 },
			[8] = { 488, PerCombo = 197, Extra = 30 },
			[9] = { 580, PerCombo = 235, Extra = 36 },
		},
		[GetSpellInfo(16511)] = {
			["Name"] = "Hemorrhage",
			[0] = { Energy = 35, WeaponDamage = 1.1 },
			[1] = { 0 },
			[2] = { 0 },
			[3] = { 0 },
			[4] = { 0 },
			[5] = { 0 },
		},
		[GetSpellInfo(5938)] = {
			["Name"] = "Shiv",
			[0] = { Energy = 20, WeaponDamage = 1, OffhandAttack = true },
			["None"] = { 0 },
		},		
		[GetSpellInfo(32645)] = {
			["Name"] = "Envenom",
			[0] = { School = "Nature", ComboPoints = true, Energy = 35, APBonus = { 0.07, 0.14, 0.21, 0.28, 0.35 } },
			[1] = { 118, PerCombo = 118 },
			[2] = { 148, PerCombo = 148 },
			[2] = { 148, PerCombo = 148 },
			[3] = { 148, PerCombo = 148 }, -- Eggi: seems to be wrong (data taken from wowhead) --DALLYTEMP
			[4] = { 148, PerCombo = 148 },
		},
		[GetSpellInfo(26679)] = {
			["Name"] = "Deadly Throw",
			[0] = { School = "Ranged", WeaponDamage = 1, Energy = 35, ComboPoints = true, APBonus = 0.03 },
			[1] = { 164, 180, PerCombo = 105 },
			[2] = { 223, 245, PerCombo = 142 },
			[3] = { 350, 386, PerCombo = 224 },
		},
		[GetSpellInfo(1329)] = {
			["Name"] = "Mutilate",
			[0] = { Energy = 60, WeaponDamage = 1, DualAttack = true, OffhandBonus = true },
			[1] = { 44 },
			[2] = { 63 },
			[3] = { 88 },
			[4] = { 101 },
			[5] = { 153 },
			[6] = { 181 },
		},
		[GetSpellInfo(51723)] = {
			["Name"] = "Fan of Knives",
			[0] = { School = "Ranged", Energy = 50, WeaponDamage = 1, DualAttack = true, Cooldown = 10 },
			["None"] = { 0 },
		},
		[GetSpellInfo(51690)] = {
			["Name"] = "Killing Spree",
			[0] = { Energy = 0, WeaponDamage = 5, DualAttack = true },
			["None"] = { 0 },
		},
	}
	self.talentInfo = {
		--Assassination:
		--Remorseless Attacks
		--Find Weakness
		--Puncturing Wounds
		--Improved Eviscerate
		--Lethality
		--Murder
		--Vile Poisons
		--Improved Kidney Shot
		--Blood Spatter
		[GetSpellInfo(14144)] = {	[1] = { Effect = 20, Spells = { "Sinister Strike", "Hemorrhage", "Backstab", "Mutilate", "Ambush", "Ghostly Strike" }, ModType = "Amount", Value = "Remorseless Attacks" }, },
		[GetSpellInfo(31234)] = {	[1] = { Effect = 0.02, Spells = "All" }, },
		[GetSpellInfo(13733)] = {	[1] = { Effect = 10, Spells = "Backstab", ModType = "critPerc" }, 
						[2] = { Effect = 5, Spells = "Mutilate", ModType = "critPerc" }, },
		[GetSpellInfo(14162)] = {	[1] = { Effect = {0.07, 0.14, 0.20} , Spells = "Eviscerate" }, },
		[GetSpellInfo(14128)] = {	[1] = { Effect = 0.06, Spells = { "Sinister Strike", "Gouge", "Backstab", "Ghostly Strike", "Mutilate", "Shiv", "Hemorrhage" }, ModType = "critM" }, },
		[GetSpellInfo(14158)] = {	[1] = { Effect = 0.01, Spells = "All", ModType = "Murder" }, },
		[GetSpellInfo(16513)] = {	[1] = { Effect = { 0.07, 0.14, 0.20 }, Spells = "Envenom" }, },
		[GetSpellInfo(14174)] = {	[1] = { Effect = 0.03, Spells = "All", ModType = "Amount", Value = "Improved Kidney Shot" }, },
		[GetSpellInfo(51632)] = {	[1] = { Effect = 0.15, Spells = {"Rupture", "Garrote"} }, },
		--Combat:
		--Aggression
		--Precision
		---Mace Specialization
		--Dual Wield Specialization
		--Surprise Attacks
		--Blade Twisting
		--Prey on the Weak
		[GetSpellInfo(18427)] = {	[1] = { Effect = 0.03, Spells = { "Sinister Strike", "Eviscerate", "Backstab" } }, },
		[GetSpellInfo(13705)] = {	[1] = { Effect = 1, Spells = "All", ModType = "hitPerc" }, },
		--[GetSpellInfo(13709)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Mace Specialization" }, },
		[GetSpellInfo(13715)] = {	[1] = { Effect = 0.1, Spells = { "Attack", "Mutilate" }, ModType = "offHdmgM", Multiply = true }, NoManual = true, },
		[GetSpellInfo(32601)] = {	[1] = { Effect = 0.1, Spells = { "Sinister Strike", "Backstab", "Shiv", "Gouge", "Hemorrhage" } }, },
		[GetSpellInfo(31124)] = { 	[1] = { Effect = 0.05, Spells = { "Sinister Strike", "Backstab" } }, },
		[GetSpellInfo(51685)] = { 	[1] = { Effect = 0.04, ModType = "Amount", Value = "Prey on the Weak" }, },
		--Subtlety:
		--Improved Ambush
		--Opportunity
		--Serrated Blades
		--Sinister Calling
		--Dirty Deeds
		--Master of Subtlety
		[GetSpellInfo(14079)] = {	[1] = { Effect = 25, Spells = "Ambush", ModType = "critPerc" }, },
		[GetSpellInfo(14057)] = {	[1] = { Effect = 0.04, Spells = { "Backstab", "Mutilate", "Ambush", "Mutilate" } }, }, --No longer required to be behind target for this talent
		[GetSpellInfo(14171)] = {	[1] = { Effect = 0.1, Spells = "Rupture" }, },
		[GetSpellInfo(31216)] = {	[1] = { Effect = 0.01, Spells = { "Backstab", "Hemorrhage" }, Add = true, }, },
		[GetSpellInfo(14082)] = { 	[1] = { Effect = 0.1, Spells = "All", Specials = true, ModType = "Amount", Value = "Dirty Deeds" }, },
		[GetSpellInfo(31221)] = { 	[1] = { Effect = {0.04, 0.07, 0.1}, Spells = "All", ModType = "Amount",  Value = "Master of Subtlety"}, },
	}
end