if select(2, UnitClass("player")) ~= "WARRIOR" then return end
local GetSpellInfo = GetSpellInfo
local GetShieldBlock = GetShieldBlock
local UnitStat = UnitStat

function DrDamage:PlayerData()

	--Special calculation
	self.Calculation["One-Handed Weapon Specialization"] = function( calculation, value, baseAction )
		if (self:GetNormM() == 2.4 or self:GetNormM() == 1.7) and not baseAction.SpellCrit then
			calculation.wDmgM = calculation.wDmgM * (1 + value)
		end
	end	
	self.Calculation["Two-Handed Weapon Specialization"] = function( calculation, value, baseAction )
		if self:GetNormM() == 3.3 and not baseAction.SpellCrit then
			calculation.wDmgM = calculation.wDmgM * (1 + value)
		end
	end
	self.Calculation["Poleaxe Specialization"] = function( calculation, value, baseAction )
		calculation.critM = calculation.critM + (0.01 * value)
		calculation.critPerc = calculation.critPerc + value
	end
	
	--General
	self.Calculation["WARRIOR"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if BuffTalentRanks["Blood Frenzy"] and (ActiveAuras["Rend"] or ActiveAuras["Deep Wound"]) then
			calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Blood Frenzy"] ) 
		end
		if ActiveAuras["Disarm"] and BuffTalentRanks["Improved Disarm"] then
			calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Improved Disarm"] )
		end
	end
	
	--Action specific
	self.Calculation["Thunder Clap"] = function( calculation, _, BuffTalentRanks )
		calculation.critM = 0.5 * (1 + (BuffTalentRanks["Impale"] or 0)) 
	end	
	self.Calculation["Heroic Strike"] = function( calculation, ActiveAuras, _, spell )
		if ActiveAuras["Dazed"] and spell.Daze then
			calculation.minDam = calculation.minDam + spell.Daze
			calculation.maxDam = calculation.maxDam + spell.Daze
		end
	end
	self.Calculation["Shield Slam"] = function( calculation )
		local bv = (GetShieldBlock() - UnitStat("player",1) * 0.05)
		calculation.minDam = calculation.minDam + bv 
		calculation.maxDam = calculation.maxDam + bv
	end
	self.Calculation["Devastate"] = function( calculation, ActiveAuras, _, spell )
		if (ActiveAuras["Sunder Armor"]) then
			calculation.minDam = calculation.minDam + (ActiveAuras["Sunder Armor"] * spell.sunderDmg)
			calculation.maxDam = calculation.maxDam + (ActiveAuras["Sunder Armor"] * spell.sunderDmg)
		end
	end
	
	--Set bonuses
	self.SetBonuses["Onslaught Armor"] = { 30970, 30974, 30976, 30978, 30980, 34442, 34547, 34568 }
	self.SetBonuses["Onslaught Battlegear"] = { 30969, 30972, 30975, 30977, 30979, 34441, 34546, 34569 }
	
	self.SetBonuses["Mortal Strike"] = function( calculation )
		if self:GetSetAmount("Onslaught Battlegear") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end
	self.SetBonuses["Bloodthirst"] = self.SetBonuses["Mortal Strike"]
	self.SetBonuses["Shield Slam"] = function( calculation )
		if self:GetSetAmount("Onslaught Armor") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end

	--Auras
	--Revenge
	--Rend
	--Deep Wound
	--Dazed
	--Disarm
	self.PlayerAura[GetSpellInfo(37517)] = { Value = 0.1 }
	self.TargetAura[GetSpellInfo(772)] = { ModType = "ActiveAura", ActiveAura = "Rend", SelfCast = true }
	self.TargetAura[GetSpellInfo(12721)] = { ModType = "ActiveAura", ActiveAura = "Deep Wound", SelfCast = true }
	self.TargetAura[GetSpellInfo(1604)] = { ModType = "ActiveAura", Spell = GetSpellInfo(78), ActiveAura = "Dazed" }
	self.TargetAura[GetSpellInfo(676)] = { ModType = "ActiveAura", Spell = "All", ActiveAura = "Disarm" }

	self.spellInfo = {
		[GetSpellInfo(78)] = {
			["Name"] = "Heroic Strike",
			[0] = { Rage = 15, WeaponDamage = 1, NextMelee = true },
			[1] = { 11, },
			[2] = { 21, },
			[3] = { 32, },
			[4] = { 44, },
			[5] = { 60, },
			[6] = { 93, },
			[7] = { 136, },
			[8] = { 178, },
			[9] = { 201, },
			[10] = { 234, Daze = 81.9 },
			[11] = { 317, Daze = 110.95 },
			[12] = { 432, Daze = 151.2 },
			[13] = { 495, Daze = 173.25 },
		},
		[GetSpellInfo(772)] = {
			["Name"] = "Rend",
			[0] = { Rage = 15, WeaponDamage = 0.5, NoCrits = true, eDuration = 15, NoNormalization = true, Bleed = true },
			[1] = { 15, eDuration = 9, },
			[2] = { 32, eDuration = 12, },
			[3] = { 50 },
			[4] = { 70 },
			[5] = { 115 },
			[6] = { 150 },
			[7] = { 185 },
			[8] = { 215 },
			[9] = { 315 },
			[10] = { 380 },
		},
		[GetSpellInfo(7384)] = {
			["Name"] = "Overpower",
			[0] = { Rage = 5, WeaponDamage = 1 },
			["None"] = { 0 },
		},
		[GetSpellInfo(6572)] = {
			["Name"] = "Revenge",
			[0] = { Rage = 5, APBonus = 0.207, Cooldown = 5, },
			[1] = { 89, 107 },
			[2] = { 129, 157 },
			[3] = { 175, 213 },
			[4] = { 320, 390 },
			[5] = { 490, 608 },
			[6] = { 643, 785, },
			[7] = { 799, 853, },
			[8] = { 855, 1045, },
			[9] = { 1454, 1776, },
		},
		[GetSpellInfo(694)] = {
			["Name"] = "Mocking Blow",
			[0] = { Rage = 10, WeaponDamage = 1 },
			["None"] = { 0 },
		},
		[GetSpellInfo(6343)] = {
			["Name"] = "Thunder Clap",
			[0] = { Rage = 20, APBonus = 0.12, NoWeapon = true, SpellCrit = true },
			[1] = { 15 },
			[2] = { 34 },
			[3] = { 55 },
			[4] = { 82 },
			[5] = { 123 },
			[6] = { 154 },
			[7] = { 184 },
			[8] = { 247 },
			[9] = { 300 },
		},
		[GetSpellInfo(845)] = {
			["Name"] = "Cleave",
			[0] = { Rage = 20, WeaponDamage = 1, Hits = 2, NextMelee = true },
			[1] = { 15 },
			[2] = { 30 },
			[3] = { 50 },
			[4] = { 70 },
			[5] = { 95 },
			[6] = { 135 },
			[7] = { 189 },
			[8] = { 222 },
		},
		[GetSpellInfo(5308)] = {
			["Name"] = "Execute",
			[0] = { Rage = 15, APBonus = 0.2, },
			[1] = { 93, PowerBonus = 3 },
			[2] = { 159, PowerBonus = 6 },
			[3] = { 282, PowerBonus = 9 },
			[4] = { 404, PowerBonus = 12 },
			[5] = { 554, PowerBonus = 15 },
			[6] = { 687, PowerBonus = 18 },
			[7] = { 865, PowerBonus = 21 },
			[8] = { 1142, PowerBonus = 30 },
			[9] = { 1456, PowerBonus = 38 },
		},
		[GetSpellInfo(20252)] = {
			["Name"] = "Intercept",
			[0] = { Rage = 10, APBonus = 0.12, Cooldown = 30, NoWeapon = true },
			["None"] = { 0 },
		},
		[GetSpellInfo(1464)] = {
			["Name"] = "Slam",
			[0] = { Rage = 15, WeaponDamage = 1, SpamDPS = 1.5, NoNormalization = true },
			[1] = { 32 },
			[2] = { 43 },
			[3] = { 68 },
			[4] = { 87 },
			[5] = { 105 },
			[6] = { 140 },
			[6] = { 220 },
			[6] = { 250 },
		},
		[GetSpellInfo(23881)] = {
			["Name"] = "Bloodthirst",
			[0] = { Rage = 30, APBonus = 0.5, Cooldown = 5 },
			["None"] = { 0 },
		},
		[GetSpellInfo(12294)] = {
			["Name"] = "Mortal Strike",
			[0] = { Rage = 30, WeaponDamage = 1, Cooldown = 6 },
			[1] = { 85 },
			[2] = { 110 },
			[3] = { 135 },
			[4] = { 160 },
			[5] = { 185 },
			[6] = { 210 },
			[7] = { 320 },
			[8] = { 380 },
		},
		[GetSpellInfo(23922)] = {
			["Name"] = "Shield Slam",
			[0] = { Rage = 20, Offhand = "Shields" },
			[1] = { 294, 308, },
			[2] = { 346, 362, },
			[3] = { 396, 416, },
			[4] = { 447, 469, },
			[5] = { 499, 523, },
			[6] = { 549, 577, },
			[7] = { 837, 879, },
			[8] = { 990, 1040, },
		},
		[GetSpellInfo(20243)] = {
			["Name"] = "Devastate",
			[0] = { Rage = 15, WeaponDamage = 0.5, },
			[1] = { 0, sunderDmg = 24 },
			[2] = { 0, sunderDmg = 40 },
			[3] = { 0, sunderDmg = 56 },
			[4] = { 0, sunderDmg = 85 },
			[5] = { 0, sunderDmg = 101 },
		},
		[GetSpellInfo(34428)] = {
			["Name"] = "Victory Rush",
			[0] = { Rage = 0, APBonus = 0.45, NoWeapon = true },
			[1] = { 0 },
		},
		[GetSpellInfo(46968)] = {
			["Name"] = "Shockwave",
			[0] = { Rage = 15, APBonus = 0.75, NoWeapon = true },
			["None"] = { 0 },
		},
		[GetSpellInfo(1680)] = {
			["Name"] = "Whirlwind",
			[0] = { Rage = 25, WeaponDamage = 1, DualAttack = true, Cooldown = 10, Hits = 4 },
			["None"] = { 0 },
		},
		[GetSpellInfo(12809)] = {
			["Name"] = "Concussion Blow",
			[0] = { Rage = 15, APBonus = 0.75 },
			["None"] = { 0 },
		},
		[GetSpellInfo(57755)] = {
			["Name"] = "Heroic Throw",
			[0] = { School = "Ranged", APBonus = 0.5, Cooldown = 60 },
			["None"] = { 12 },
		},
	}
	self.talentInfo = {
		--ARMS:
		--Improved Rend
		--Improved Overpower
		--Impale
		--Two-Handed Weapon Specialization
		--Poleaxe Specialization
		--Improved Intercept
		--Improved Mortal Strike		
		--Unrelenting Assault
		--Blood Frenzy
		[GetSpellInfo(12286)] = {	[1] = { Effect = 0.1, Spells = "Rend" }, },
		[GetSpellInfo(12290)] = {	[1] = { Effect = 25, Spells = "Overpower", ModType = "critPerc" }, },
		[GetSpellInfo(16493)] = {	[1] = { Effect = 0.1, Spells = "All", ModType = "critM", Specials = true, }, 
						[2] = { Effect = 0.05, Spells = "Thunder Clap", ModType = "Amount", Value = "Impale" }, },
		[GetSpellInfo(12163)] = {	[1] = { Effect = 0.02, Spells = "All", ModType = "Two-Handed Weapon Specialization" }, },
		[GetSpellInfo(12700)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Poleaxe Specialization", }, }, --need to add a check to verify axes or polearms are equipped
		[GetSpellInfo(29888)] = {	[1] = { Effect = -5, Spells = "Intercept", ModType = "cooldown" }, },
		[GetSpellInfo(35446)] = {	[1] = { Effect = 0.03, Spells = "Mortal Strike", }, 
															[2] = { Effect = {-0.333, -0.666, -1 }, Spells = "Mortal Strike", ModType = "cooldown" }, },		
		[GetSpellInfo(46859)] = {	[1] = { Effect = -2, Spells = { "Overpower", "Revenge" }, ModType = "cooldown" }, },
		[GetSpellInfo(29836)] = {	[1] = { Effect = 0.01, Spells = "All", ModType = "Amount", Value = "Blood Frenzy"  }, },
		
		--FURY:
		--Improved Cleave
		--Dual Wield Specialization
		--Precision
		--Improved Whirlwind
		--Unending Fury
		--Titan's Grip
		--Titan's Grip
		[GetSpellInfo(12329)] = {	[1] = { Effect = 0.4, Spells = "Cleave", ModType = "bDmgM", Multiply = true }, },
		[GetSpellInfo(23584)] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "offHdmgM", Multiply = true  }, NoManual = true },
		[GetSpellInfo(29590)] = {	[1] = { Effect = 0.10, Spells = "Whirlwind", Multiply = true }, },
		[GetSpellInfo(29721)] = {	[1] = { Effect = -1, Spells = "Whirlwind", ModType = "cooldown" }, },
		[GetSpellInfo(56927)] = {	[1] = { Effect = 0.02, Spells = { "Slam", "Whirlwind", "Bloodthirst", },   Multiply = true }, },
		[GetSpellInfo(46917)] = {	[1] = { Effect = -5, Spells = "All", ModType = "hitPerc", Specials = true, }, },
		
		--PROTECTION:
		--Improved Thunder Clap
		--Incite
		--Improved Revenge
		--Improved Disarm
		--Gag Order
		--One-Handed Weapon Specialization
		--Critical Block
		--Sword and Board
		[GetSpellInfo(12287)] = {	[1] = { Effect = 0.1, Spells = "Thunder Clap" }, },
		[GetSpellInfo(50685)] = {	[1] = { Effect = 5, Spells = { "Heroic Strike", "Thunder Clap", "Cleave" }, ModType = "critPerc" }, },
		[GetSpellInfo(12797)] = {	[1] = { Effect = 0.1, Spells = "Revenge" }, },
		[GetSpellInfo(12313)] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "Amount", Value = "Improved Disarm"  }, },
		[GetSpellInfo(12311)] = {	[1] = { Effect = 0.05, Spells = "Shield Slam"}, },
		[GetSpellInfo(16538)] = {	[1] = { Effect = 0.02, Spells = "All", ModType = "One-Handed Weapon Specialization" }, },
		[GetSpellInfo(47294)] = {	[1] = { Effect = 5, Spells = "Shield Slam", ModType = "critPerc" }, },
		[GetSpellInfo(46951)] = {	[1] = { Effect = 5, Spells = "Devastate", ModType = "critPerc" }, },
	}
end