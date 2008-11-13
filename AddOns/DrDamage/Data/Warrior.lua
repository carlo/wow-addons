if select(2, UnitClass("player")) ~= "WARRIOR" then return end
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
	self.Calculation["WARRIOR"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if BuffTalentRanks["Blood Frenzy"] and (ActiveAuras["Rend"] or ActiveAuras["Deep Wound"]) then
			calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Blood Frenzy"] ) 
		end
	end
	self.Calculation["Two-Handed Weapon Specialization"] = function( calculation, talentValue )
		if DrDamage:GetNormM() == 3.3 then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
		end
	end
	self.Calculation["One-Handed Weapon Specialization"] = function( calculation, talentValue )
		local normM = self:GetNormM()
		if  normM == 2.4 or normM == 1.7 then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
		end
	end
	
	--Action specific
	self.Calculation["Heroic Strike"] = function( calculation, ActiveAuras, _, spell )
		if ActiveAuras["Dazed"] then
			if spell.Daze then
				calculation.minDam = calculation.minDam + spell.Daze
				calculation.maxDam = calculation.maxDam + spell.Daze
			end
		end
	end
	self.Calculation["Shield Slam"] = function( calculation )
		local bv = (GetShieldBlock() - UnitStat("player",1) * 0.05)
		calculation.minDam = calculation.minDam + bv 
		calculation.maxDam = calculation.maxDam + bv
	end
	
	
	--Set bonuses
	self.SetBonuses["Destroyer Battlegear"] = { 30118, 30119, 30120, 30121, 30122 }
	self.SetBonuses["Warbringer Battlegear"] = { 29019, 29020, 29021, 29022, 29023 }
	self.SetBonuses["Onslaught Armor"] = { 30970, 30974, 30976, 30978, 30980 }
	self.SetBonuses["Onslaught Battlegear"] = { 30969, 30972, 30975, 30977, 30979 }
	
	self.SetBonuses["Mortal Strike"] = function( calculation )
		if self:GetSetAmount("Destroyer Battlegear") >= 4 then
			calculation.actionCost = calculation.actionCost - 5
		end
		if self:GetSetAmount("Onslaught Battlegear") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end
	self.SetBonuses["Bloodthirst"] = self.SetBonuses["Mortal Strike"]
	self.SetBonuses["Whirlwind"] = function( calculation )
		if self:GetSetAmount("Warbringer Battlegear") >= 2 then
			calculation.actionCost = calculation.actionCost -5
		end
	end
	self.SetBonuses["Shield Slam"] = function( calculation )
		if self:GetSetAmount("Onslaught Armor") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	self.SetBonuses["Execute"] = function( calculation )
		if self:GetSetAmount("Onslaught Battlegear") >= 2 then
			calculation.actionCost = calculation.actionCost - 3
		end
	end	
	
	
	--Auras
	self.PlayerAura["Revenge"] = { Spell = BS["Revenge"], Value = 0.1 }
	self.Debuffs["Rend"] = { ModType = "ActiveAura", ActiveAura = true, SelfCast = true }
	self.Debuffs["Deep Wound"] = { ModType = "ActiveAura", ActiveAura = true, SelfCast = true }
	self.Debuffs["Dazed"] = { ModType = "ActiveAura", Spell = BS["Heroic Strike"], ActiveAura = true }

	self.spellInfo = {
		[BS["Heroic Strike"]] = {
			[0] = { Rage = 15, WeaponDamage = 1, NextMelee = true },
			[1] = { 11, },
			[2] = { 21, },
			[3] = { 32, },
			[4] = { 44, },
			[5] = { 58, },
			[6] = { 80, },
			[7] = { 111, },
			[8] = { 138, },
			[9] = { 157, },
			[10] = { 176, Daze = 61.6 },
			[11] = { 208, Daze = 72.8 },
		},
		[BS["Rend"]] = {
			[0] = { Rage = 15, WeaponDamage = 0.05201, eDuration = 21, NoNormalization = true },
			[1] = { 15, WeaponDamage = 0.02229, eDuration = 9, },
			[2] = { 28, WeaponDamage = 0.02972, eDuration = 12, },
			[3] = { 45, WeaponDamage = 0.03715, eDuration = 15, },
			[4] = { 66, WeaponDamage = 0.04458, eDuration = 18, },
			[5] = { 98,  },
			[6] = { 126, },
			[7] = { 147, },
			[8] = { 182, },
		},
		[BS["Hamstring"]] = {
			[0] = { Rage = 10 },
			[1] = { 5 },
			[2] = { 18 },
			[3] = { 45 },
			[4] = { 63 },		
		},
		[BS["Overpower"]] = {
			[0] = { Rage = 5, WeaponDamage = 1 },
			[1] = { 5 },
			[2] = { 15 },
			[3] = { 25 },
			[4] = { 35 },

		},
		[BS["Shield Bash"]] = {
			[0] = { Rage = 10 },
			[1] = { 6 },
			[2] = { 18 },
			[3] = { 45 },
			[4] = { 63 },

		},
		[BS["Revenge"]] = {
			[0] = { Rage = 5, },
			[1] = { 55 },
			[2] = { 77, 93, },
			[3] = { 118, },
			[4] = { 200, },
			[5] = { 300, },
			[6] = { 342, 418, },
			[7] = { 360, 440, },
			[8] = { 414, 506, },
		},
		[BS["Mocking Blow"]] = {
			[0] = { Rage = 10 },
			[1] = { 22 },
			[2] = { 31 },
			[3] = { 46 },
			[4] = { 71 },
			[5] = { 93 },
			[6] = { 114 },
		},
		[BS["Thunder Clap"]] = {
			[0] = { Rage = 20 },
			[1] = { 10 },
			[2] = { 23 },
			[3] = { 37 },
			[4] = { 55 },
			[5] = { 82 },
			[6] = { 103 },
			[7] = { 123 },
		},
		[BS["Cleave"]] = {
			[0] = { Rage = 20, WeaponDamage = 1, Hits = 2, NextMelee = true },
			[1] = { 5 },
			[2] = { 10 },
			[3] = { 18 },
			[4] = { 32 },
			[5] = { 50 },
			[6] = { 70 },
		},
		[BS["Execute"]] = {
			[0] = { Rage = 15, },
			[1] = { 125, PowerBonus = 3 },
			[2] = { 200, PowerBonus = 6 },
			[3] = { 325, PowerBonus = 9 },
			[4] = { 450, PowerBonus = 12 },
			[5] = { 600, PowerBonus = 15 },
			[6] = { 750, PowerBonus = 18 },
			[7] = { 925, PowerBonus = 21 },
		},
		[BS["Intercept"]] = {
			[0] = { Rage = 10, Cooldown = 30, },
			[1] = { 25 },
			[2] = { 45 },
			[3] = { 65 },
			[4] = { 85 },
			[5] = { 105 },
		},
		[BS["Slam"]] = {
			[0] = { Rage = 15, WeaponDamage = 1, SpamDPS = 1.5 },
			[1] = { 32 },
			[2] = { 43 },
			[3] = { 68 },
			[4] = { 87 },
			[5] = { 105 },
			[6] = { 140 },
		},
		[BS["Pummel"]] = {
			[0] = { Rage = 10 },
			[1] = { 20 },
			[2] = { 50 },
		},
		[BS["Bloodthirst"]] = {
			[0] = { Rage = 30, APBonus = 45/100 },
			[1] = { 0 },
			[2] = { 0 },
			[3] = { 0 },
			[4] = { 0 },
			[5] = { 0 },
			[6] = { 0 },
		},
		[BS["Mortal Strike"]] = {
			[0] = { Rage = 30, WeaponDamage = 1, Cooldown = 6 },
			[1] = { 85 },
			[2] = { 110 },
			[3] = { 135 },
			[4] = { 160 },
			[5] = { 185 },
			[6] = { 210 },

		},
		[BS["Shield Slam"]] = {
			[0] = { Rage = 20 },
			[1] = { 225, 235, },
			[2] = { 264, 276, },
			[3] = { 303, 317, },
			[4] = { 342, 358, },
			[5] = { 381, 399, },
			[6] = { 420, 440, },
		},
		[BS["Devastate"]] = {
			[0] = { Rage = 15, WeaponDamage = 0.5, },
			[1] = { 15 },
			[2] = { 25 },
			[3] = { 35 },
		},
		[BS["Victory Rush"]] = {
			[0] = { Rage = 0, APBonus = 45/100 },
			[1] = { 0 },
		},
		[BS["Whirlwind"]] = {
			[0] = { Rage = 25, WeaponDamage = 1, Cooldown = 10, Hits = 4 },
			["None"] = { 0 },
		},
	}
	self.talentInfo = {
		["Improved Rend"] = {			[1] = { Effect = 0.25, Spells = "Rend" }, },
		["Improved Heroic Strike"] = {		[1] = { Effect = 1, Spells = "Heroic Strike", ModType = "PowerCost" }, },
		["Improved Thunder Clap"] = {		[1] = { Effect = { 0.3, 0.7, 1.0 }, Spells = "Thunder Clap" },
							[2] = { Effect = { 1,2,4 }, Spells = "Thunder Clap", ModType = "PowerCost" },
						},
		["Improved Overpower"] = {		[1] = { Effect = 25, Spells = "Overpower", ModType = "Crit" }, },
		["Two-Handed Weapon Specialization"] = { [1] = { Effect = 0.01, Spells = "All", ModType = "Two-Handed Weapon Specialization" }, },
		["Impale"] = {				[1] = { Effect = 0.1, Spells = "All", ModType = "CritMultiplier", Specials = true }, },
		["Blood Frenzy"] = {			[1] = { Effect = 0.02, Spells = "All", ModType = "BuffTalentRanks"  }, },
		["Improved Mortal Strike"] = {		[1] = { Effect = 0.01, Spells = "Mortal Strike", }, 
							[2] = { Effect = 0.2, Spells = "Mortal Strike", ModType = "Cooldown" },
						},
		["Improved Cleave"] = {			[1] = { Effect = 0.4, Spells = "Cleave", ModType = "BaseDamage" }, },
		["Improved Execute"] = {		[1] = { Effect = { 2, 5 }, Spells = "Execute", ModType = "PowerCost"  }, },
		["Dual Wield Specialization"] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "OffHand"  }, },
		["Improved Intercept"] = {		[1] = { Effect = 5, Spells = "Intercept", ModType = "Cooldown" }, },
		["Precision"] = {			[1] = { Effect = 1, Spells = "All", ModType = "Hit" }, },
		["Improved Whirlwind"] = {		[1] = { Effect = 1, Spells = "Whirlwind", ModType = "Cooldown" }, },
		["One-Handed Weapon Specialization"] = { [1] = { Effect = 0.02, Spells = "All", ModType = "One-Handed Weapon Specialization" }, },
		["Focused Rage"] = { 			[1] = { Effect = 1, Spells = "All", ModType = "PowerCost" }, },
	}
end