if select(2, UnitClass("player")) ~= "ROGUE" then return end
local BR
local BS
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2")
else
	BS = {}
	setmetatable(BS,{ __index = function(t,k) return k end })
end

function DrDamage:PlayerData()

	--Special calculation
	
	--General
	self.Calculation["ROGUE"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if BuffTalentRanks["Remorseless Attacks"] and ActiveAuras["Remorseless"] then
			calculation.critPerc = calculation.critPerc + BuffTalentRanks["Remorseless Attacks"]
		end
		if BuffTalentRanks["Improved Kidney Shot"] and ActiveAuras["Kidney Shot"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Kidney Shot"])
		end
		if BuffTalentRanks["Find Weakness"] and ActiveAuras["Find Weakness"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Find Weakness"])
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
	self.Calculation["Dagger Specialization"] = function( calculation, talentValue )
		if self:GetWeaponType() == "Daggers" then
			calculation.critPerc = calculation.critPerc + talentValue
		end
	end
	self.Calculation["Fist Weapon Specialization"] = function( calculation, talentValue )
		if self:GetWeaponType() == "Fist Weapons" then
			calculation.critPerc = calculation.critPerc + talentValue
		end
	end
	
	--Spell specific
	self.Calculation["Mutilate"] = function( calculation, ActiveAuras )
		if ActiveAuras["Deadly Poison"] or ActiveAuras["Poison"] then
			calculation.dmgM = calculation.dmgM * 1.5
		end
	end
	self.Calculation["Envenom"] = function( calculation, ActiveAuras, _, action )
		local cp = GetComboPoints()
		if ActiveAuras["Deadly Poison"] and  cp > 0 then
			local bonus = (self:GetSetAmount("Deathmantle") >= 2) and 40 or 0
			calculation.minDam = calculation.minDam + action.PerCombo * math.min(ActiveAuras["Deadly Poison"], cp) + cp * bonus
			calculation.maxDam = calculation.maxDam + action.PerCombo * math.min(ActiveAuras["Deadly Poison"], cp) + cp * bonus
		else
			calculation.zero = true
		end
	end
	self.Calculation["Ambush"] = function( calculation, ActiveAuras )
		if ActiveAuras["Shadowstep"] then
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end
	self.Calculation["Garrote"] = self.Calculation["Ambush"]
	self.Calculation["Backstab"] = self.Calculation["Ambush"]
	self.Calculation["Shiv"] = function( calculation )
		local ospd = select(2,self:GetWeaponSpeed())
		if ospd then
			calculation.actionCost = calculation.actionCost + 10 * ospd
		end
	end
	
	
	--Set bonuses
	self.SetBonuses["Deathmantle"] = { 30144, 30145, 30146, 30147, 30148, }
	self.SetBonuses["Slayer's Armor"] = { 31026, 31027, 31028, 31029, 31030, }
	
	self.SetBonuses["Eviscerate"] = function( calculation )
		local cp = GetComboPoints()
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
	local dPoison = { "Deadly Poison", "Deadly Poison II", "Deadly Poison III", "Deadly Poison IV", "Deadly Poison V", "Deadly Poison VI", "Deadly Poison VII" }
	local allPoisons = { 	"Anesthetic Poison",
				"Crippling Poison", "Crippling Poison II",
				"Mind-numbing Poison", "Mind-numbing Poison II", "Mind-numbing Poison III", 
				"Instant Poison", "Instant Poison II", "Instant Poison III", "Instant Poison IV", "Instant Poison V", "Instant Poison VI", "Instant Poison VII",
				"Wound Poison", "Wound Poison II", "Wound Poison III", "Wound Poison IV", "Wound Poison V",
	}			
	for _, v in ipairs(dPoison) do
		self.Debuffs[v] = { ModType = "ActiveAura", Spell = { BS["Envenom"], BS["Mutilate"] }, ActiveAura = true, SelfCast = true }
	end
	for _, v in ipairs(allPoisons) do
		self.Debuffs[v] = { ModType = "Special", Spell = BS["Mutilate"] }
		self.Calculation[v] = function( _, ActiveAuras, _, index )
			if select(7,UnitDebuff("target",index)) then
				ActiveAuras["Poison"] = true
			end
		end
	end
	
	self.PlayerAura["Remorseless"] = { ModType = "ActiveAura", ActiveAura = true }
	self.PlayerAura["Find Weakness"] = { ModType = "ActiveAura", ActiveAura = true }
	self.PlayerAura["Shadowstep"] = { ModType = "ActiveAura", ActiveAura = true }
	self.Debuffs["Kidney Shot"] = { ModType = "ActiveAura", ActiveAura = true, SelfCast = true }
	
	self.spellInfo = {
		[BS["Sinister Strike"]] = {
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
		},
		[BS["Backstab"]] = {
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
		},
		[BS["Eviscerate"]] = {
			[0] = { Energy = 35, ComboPoints = true, APBonus = 0.03 },
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
		},
		[BS["Ambush"]] = {
			[0] = { Energy = 60, WeaponDamage = 2.5, Weapon = "Daggers" },
			[1] = { 70 },
			[2] = { 100 },
			[3] = { 125 },
			[4] = { 185 },
			[5] = { 230 },
			[6] = { 290 },
			[7] = { 335 },
		},
		[BS["Gouge"]] = {
			[0] = { Energy = 45, Cooldown = 10 },
			[1] = { 10 },
			[2] = { 20 },
			[3] = { 32 },
			[4] = { 55 },
			[5] = { 75 },
			[6] = { 105 },
		},
		[BS["Kick"]] = {
			[0] = { Energy = 25, Cooldown = 10 },
			[1] = { 15 },
			[2] = { 30 },
			[3] = { 45 },
			[4] = { 80 },
			[5] = { 110 },
		},		
		[BS["Ghostly Strike"]] = {
			[0] = { Energy = 40, WeaponDamage = 1.25, Cooldown = 20, NoNormalization = true },
			[1] = { 0 },
			["None"] = { 0 },
		},
		[BS["Riposte"]] = {
			[0] = { Energy = 10, WeaponDamage = 1.5, NoNormalization = true },
			[1] = { 0 },
		},
		[BS["Garrote"]] = {
			[0] = { Energy = 50, NoCrits = true, APBonus = 0.18, eDuration = 18, Ticks = 3 },
			[1] = { 144 },
			[2] = { 204 },
			[3] = { 282 },
			[4] = { 354 },
			[5] = { 444 },
			[6] = { 552 },
			[7] = { 666 },
			[8] = { 810 },
		},
		[BS["Rupture"]] = {
			[0] = { Energy = 25, NoCrits = true, ComboPoints = true, APBonus = { 0.04, 0.10, 0.18, 0.21, 0.24 }, ExtraPerCombo = { 0, 0, 1, 3, 6 }, eDuration = 6, DurationPerCombo = 2 },
			[1] = { 40, PerCombo = 20, Extra = 4 },
			[2] = { 60, PerCombo = 30, Extra = 6 },
			[3] = { 88, PerCombo = 42, Extra = 8 },
			[4] = { 128, PerCombo = 57, Extra = 10 },
			[5] = { 176, PerCombo = 79, Extra = 14 },
			[6] = { 272, PerCombo = 108, Extra = 16 },
			[7] = { 324, PerCombo = 136, Extra = 22 },
		},
		[BS["Hemorrhage"]] = {
			[0] = { Energy = 35, WeaponDamage = 1.25, NoNormalization = true },
			[1] = { 0 },
			[2] = { 0 },
			[3] = { 0 },
			[4] = { 0 },
		},
		[BS["Shiv"]] = {
			[0] = { Energy = 20, WeaponDamage = 1, OffhandAttack = true },
			[1] = { 0 },
		},		
		[BS["Envenom"]] = {
			[0] = { School = "Nature", Energy = 35, APBonus = 0.03 },
			[1] = { 144, PerCombo = 144 },
			[2] = { 180, PerCombo = 180 },
		},
		[BS["Deadly Throw"]] = {
			[0] = { School = "Ranged", WeaponDamage = 1, Energy = 35, ComboPoints = true, APBonus = 0.03 },
			[1] = { 164, 180, PerCombo = 105 },
		},
		[BS["Mutilate"]] = {
			[0] = { Energy = 60, WeaponDamage = 1, DualAttack = true },
			[1] = { 44 },
			[2] = { 63 },
			[3] = { 88 },
			[4] = { 101 },
		},
	}
	self.talentInfo = {
		--Assassination:
		["Remorseless Attacks"] = {	[1] = { Effect = 20, Spells = { "Sinister Strike", "Hemorrhage", "Backstab", "Mutilate", "Ambush", "Ghostly Strike" }, ModType = "BuffTalentRanks" }, },
		["Find Weakness"] = {		[1] = { Effect = 0.02, Spells = "All", ModType = "BuffTalentRanks" }, },
		["Improved Backstab"] = {	[1] = { Effect = 10, Spells = "Backstab", ModType = "Crit" }, },
		["Improved Eviscerate"] = {	[1] = { Effect = 0.05, Spells = "Eviscerate" }, },
		["Lethality"] = {		[1] = { Effect = 0.06, Spells = { "Sinister Strike", "Gouge", "Backstab", "Ghostly Strike", "Mutilate", "Shiv", "Hemorrhage" }, ModType = "CritMultiplier" }, },
		["Murder"] = {			[1] = { Effect = 0.01, Spells = "All", ModType = "Murder" }, },
		["Vile Poisons"] = {		[1] = { Effect = 0.04, Spells = "Envenom" }, },
		["Improved Kidney Shot"] = { 	[1] = { Effect = 0.03, Spells = "All", ModType = "BuffTalentRanks" }, },
		--Combat:
		["Aggression"] = {		[1] = { Effect = 0.02, Spells = { "Sinister Strike", "Eviscerate" } }, },
		["Precision"] = {		[1] = { Effect = 1, Spells = "All", ModType = "Hit" }, },
		["Dagger Specialization"] = {	[1] = { Effect = 1, Spells = "All", ModType = "Dagger Specialization" }, },
		["Fist Weapon Specialization"] = { [1] = { Effect = 1, Spells = "All", ModType = "Fist Weapon Specialization" }, },
		["Dual Wield Specialization"] = { [1] = { Effect = 0.1, Spells = { "Attack", "Mutilate" }, ModType = "Offhand" }, },
		["Improved Sinister Strike"] = { [1] = { Effect = { 2, 5 }, Spells = "Sinister Strike", ModType = "PowerCost" }, },
		["Surprise Attacks"] = {	[1] = { Effect = 0.1, Spells = { "Sinister Strike", "Backstab", "Shiv", "Gouge" } }, },
		--Subtlety:
		["Improved Ambush"] = {		[1] = { Effect = 15, Spells = "Ambush", ModType = "Crit" }, },
		["Opportunity"] = {		[1] = { Effect = 0.04, Spells = { "Backstab", "Mutilate", "Ambush" } }, },
		["Serrated Blades"] = {		[1] = { Effect = 0.1, Spells = "Rupture" }, },
		["Dirty Deeds"] = {		[1] = { Effect = 10, Spells = { "Cheap Shot", "Garrote" }, ModType = "PowerCost" }, },
	}
end