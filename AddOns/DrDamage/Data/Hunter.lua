if select(2, UnitClass("player")) ~= "HUNTER" then return end
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
	self.Calculation["HUNTER"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if BuffTalentRanks["Rapid Killing"] and ActiveAuras["Rapid Killing"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Rapid Killing"])
		end
	end
	self.Calculation["Monster Slaying"] = function( calculation, talentValue )
		local targetType = UnitCreatureType("target")
		
		if BR and targetType and BR:HasReverseTranslation( targetType ) then
			targetType = BR:GetReverseTranslation( targetType )
		end	
		
		if targetType == "Beast"
		or targetType == "Giant"
		or targetType == "Dragonkin" then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
			calculation.critPerc = calculation.critPerc + 100 * talentValue
		end
	end
	self.Calculation["Humanoid Slaying"] = function( calculation, talentValue )
		local targetType = UnitCreatureType("target")
		
		if BR and targetType and BR:HasReverseTranslation( targetType ) then
			targetType = BR:GetReverseTranslation( targetType )
		end	
		
		if targetType == "Humanoid" then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
			calculation.critPerc = calculation.critPerc + 100 * talentValue
		end
	end
	self.Calculation["Hunter's Mark"] = function( calculation, _, BuffTalentRanks, _, _, _, rank )
		if rank then
			rank = tonumber(string.match(rank,"%d+"))
		end
		if not rank then
			rank = 4
		end
		if calculation.actionSchool == "Ranged" then
			calculation.AP = calculation.AP + DrDamage.Debuffs["Hunter's Mark"].Value[rank]
		elseif BuffTalentRanks["Improved Hunter's Mark"] and calculation.actionSchool == "Physical" then
			calculation.AP = calculation.AP + DrDamage.Debuffs["Hunter's Mark"].Value[rank] * BuffTalentRanks["Improved Hunter's Mark"]
		end
	end	
	
	--Spell specific
	self.Calculation["Steady Shot"] = function( calculation, ActiveAuras, _, spell )
		local min, max = DrDamage:GetRangedBase()
		local spd = select(3,DrDamage:GetWeaponSpeed())
		if spd then
			calculation.minDam = calculation.minDam + min/spd * 2.8
			calculation.maxDam = calculation.maxDam + max/spd * 2.8
		end
		if ActiveAuras["Dazed"] then
			if spell.Daze then
				calculation.minDam = calculation.minDam + spell.Daze
				calculation.maxDam = calculation.maxDam + spell.Daze
			end
		end
	end
	self.Calculation["Aimed Shot"] = function( calculation )
		local spd = select(3,DrDamage:GetWeaponSpeed())
		if spd then
			calculation.cooldown = calculation.cooldown + spd
		end
	end
	self.Calculation["Multi-Shot"] = function( calculation )
		--Merciless Gladiator's Chain Gauntlets
		if IsEquippedItem( 31961 ) then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	
	--Set Bonuses
	self.SetBonuses["Rift Stalker Armor"] = { 30139, 30140, 30141, 30142, 30143 }
	self.SetBonuses["Gronnstalker's Armor"] = { 31001, 31003, 31004, 31005, 31006 }
	
	self.SetBonuses["Steady Shot"] = function( calculation )
		if self:GetSetAmount("Rift Stalker Armor") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "Gronnstalker's Armor" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end		
	end
	
	
	--Auras
	self.PlayerAura["Rapid Killing"] = { ModType = "ActiveAura", ActiveAura = true }
	
	self.Debuffs["Hunter's Mark"] = { Value = { 20, 45, 75, 110 }, ModType = "Special" }
	self.Debuffs["Dazed"] = { ModType = "ActiveAura", Spell = BS["Steady Shot"], ActiveAura = true }
	
	self.spellInfo = {
		[BS["Auto Shot"]] = {
			[0] = { School = "Ranged", WeaponDamage = 1, NoNormalization = true, AutoShot = true },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[BS["Arcane Shot"]] = {
			[0] = { School = { "Ranged", "Arcane" }, Cooldown = 6, APBonus = 0.15 },
			[1] = { 15 },
			[2] = { 23 },
			[3] = { 36 },
			[4] = { 65 },
			[5] = { 91 },
			[6] = { 125 },
			[7] = { 158 },
			[8] = { 200 },
			[9] = { 273 },
		},
		[BS["Aimed Shot"]] = {
			[0] = { School = "Ranged", WeaponDamage = 1, Cooldown = 6 },
			[1] = { 70 },
			[2] = { 125 },
			[3] = { 200 },
			[4] = { 330 },
			[5] = { 460 },
			[6] = { 600 },
			[7] = { 870 },
		},
		[BS["Multi-Shot"]] = {
			[0] = { School = "Ranged", WeaponDamage = 1, Cooldown = 10 },
			[1] = { 0 },
			[2] = { 40 },
			[3] = { 80 },
			[4] = { 120 },
			[5] = { 150 },
			[6] = { 205 },
		},
		[BS["Scatter Shot"]] = {
			[0] = { School = "Ranged", WeaponDamage = 0.5, Cooldown = 30 },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[BS["Silencing Shot"]] = {
			[0] = { School = "Ranged", WeaponDamage = 0.5, Cooldown = 20 },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[BS["Steady Shot"]] = {
			[0] = { School = "Ranged", APBonus = 0.2, DPSrg = true },
			[1] = { 150, Daze = 175  },
		},
		[BS["Serpent Sting"]] = {
			[0] = { School = { "Ranged", "Nature" }, APBonus = 0.1, NoCrits = true, eDuration = 15, Ticks = 3 },
			[1] = { 20 },
			[2] = { 40 },
			[3] = { 80 },
			[4] = { 140 },
			[5] = { 210 },
			[6] = { 290 },
			[7] = { 385 },
			[8] = { 490 },
			[9] = { 555 },
			[10] = { 660 },
		},
		[BS["Immolation Trap"]] = {
			[0] = { School = { "Ranged", "Fire" }, Unresistable = true, APBonus = 0.1, NoCrits = true, eDuration = 15, Ticks = 3, Cooldown = 30 },
			[1] = { 105 },
			[2] = { 215 },
			[3] = { 340 },
			[4] = { 510 },
			[5] = { 690 },
			[6] = { 985 },
		},
		[BS["Explosive Trap"]] = {
			[0] = { School = { "Ranged", "Fire" }, Unresistable = true, APBonus = 0.1, NoCrits = true, Cooldown = 30 },
			[1] = { 100, 130 },
			[2] = { 139, 187 },
			[3] = { 201, 257 },
			[4] = { 263, 337 },
		},		
		[BS["Wyvern Sting"]] = {
			[0] = { School = { "Ranged", "Nature" }, NoCrits = true, eDuration = 12 },
			[1] = { 300 },
			[2] = { 420 },
			[3] = { 600 },
			[4] = { 942 },
		},
		[BS["Raptor Strike"]] = {
			[0] = { WeaponDamage = 1, Cooldown = 6, NextMelee = true, NoNormalization = true },
			[1] = { 5 },
			[2] = { 11 },
			[3] = { 21 },
			[4] = { 34 },
			[5] = { 50 },
			[6] = { 80 },
			[7] = { 110 },
			[8] = { 140 },
			[9] = { 170 },
		},
		[BS["Wing Clip"]] = {
			[0] = {  },
			[1] = { 5 },
			[2] = { 25 },
			[3] = { 50 },
		},
		[BS["Mongoose Bite"]] = {
			[0] = { Cooldown = 5, APBonus = 0.2 },
			[1] = { 25 },
			[2] = { 45 },
			[3] = { 75 },
			[4] = { 115 },
			[5] = { 150 },
		},
		[BS["Counterattack"]] = {
			[0] = { Cooldown = 5 },
			[1] = { 40 },
			[2] = { 70 },
			[3] = { 110 },
			[4] = { 165 },
		},
	}
	self.talentInfo = {
		--Marksmanship:
		["Improved Hunter's Mark"] = {		[1] = { Effect = 0.2, Spells = "Physical", ModType = "BuffTalentsRank" }, },
		["Improved Arcane Shot"] = {		[1] = { Effect = 0.2, Spells = "Arcane Shot", ModType = "Cooldown" }, },
		["Rapid Killing"] = {			[1] = { Effect = 0.1, Spells = { "Aimed Shot", "Arcane Shot", "Auto Shot" }, ModType = "BuffTalentsRank"  }, },
		["Improved Stings"] = {			[1] = { Effect = 0.06, Spells = { "Serpent Sting", "Wyvern Sting" } }, },
		["Mortal Shots"] = {			[1] = { Effect = 0.06, Spells = "Ranged", ModType = "CritMultiplier" }, },
		["Barrage"] = {				[1] = { Effect = 0.04, Spells = { "Multi-Shot", "Volley" }, }, },
		["Ranged Weapon Specialization"] = {	[1] = { Effect = 0.01, Spells = "Ranged" }, },
		["Improved Barrage"] = {		[1] = { Effect = 4, Spells = "Multi-Shot", ModType = "Crit" }, },
		--Survival:
		["Monster Slaying"] = {			[1] = { Effect = 0.01, Spells = "All", ModType = "Monster Slaying" }, },
		["Humanoid Slaying"] = {		[1] = { Effect = 0.01, Spells = "All", ModType = "Humanoid Slaying" }, },
		["Savage Strikes"] = {			[1] = { Effect = 10, Spells = { "Raptor Strike", "Mongoose Bite" }, ModType = "Crit" }, },
		["Surefooted"] = {			[1] = { Effect = 1, Spells = "All", ModType = "Hit" }, }, 
		["Clever Traps"] = {			[1] = { Effect = 0.15, Spells = { "Explosive Trap", "Immolation Trap" }, }, },
	--	["Thrill of the Hunt"] = {		[1] = {  }, },
	--	["Expose Weakness"] = {			[1] = {  }, },
	}
end