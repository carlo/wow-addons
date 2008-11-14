if select(2, UnitClass("player")) ~= "HUNTER" then return end
local GetSpellInfo = GetSpellInfo
local UnitCreatureType = UnitCreatureType
local IsEquippedItem = IsEquippedItem
local BR
local UnitExists = UnitExists
local tonumber = tonumber
local string_match = string.match

function DrDamage:PlayerData()

	local hmark = GetSpellInfo(1130)
	
	--General
	self.Calculation["HUNTER"] = function( calculation, ActiveAuras, BuffTalentRanks, action, baseAction )
		if BuffTalentRanks["Rapid Killing"] and ActiveAuras["Rapid Killing"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Rapid Killing"])
		end
		if UnitExists("pet") and BuffTalentRanks["Focused Fire"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Focused Fire"])
		end
		if ActiveAuras["Serpent Sting"] and BuffTalentRanks["Noxious Stings"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Noxious Stings"])
		end
		if ActiveAuras["Freezing Trap"] or ActiveAuras["Frost Trap"] or ActiveAuras["Freezing Arrow"] then
			if BuffTalentRanks["Point of No Escape"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Point of No Escape"]
			end
		end
	end
	
	self.Calculation["Auto Shot"] = function( calculation, ActiveAuras, BuffTalentRanks, action, baseAction )
		if ActiveAuras[hmark] and BuffTalentRanks["Marked for Death"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Marked for Death"])
		end	
	
		if not baseAction.eDuration and BuffTalentRanks["Improved Tracking"] then
			local targetType = UnitCreatureType("target")

			if BR and targetType and BR:HasReverseTranslation( targetType ) then
				targetType = BR:GetReverseTranslation( targetType )
			end

			if ActiveAuras["Track Beasts"] and targetType == "Beast"
			or ActiveAuras["Track Demons"] and targetType == "Demon"
			or ActiveAuras["Track Dragonkin"] and targetType == "Dragonkin"
			or ActiveAuras["Track Elementals"] and targetType == "Elemental"
			or ActiveAuras["Track Giants"] and targetType == "Giant"
			or ActiveAuras["Track Humanoids"] and targetType == "Humanoid"
			or ActiveAuras["Track Undead"] and targetType == "Undead" then
				calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Tracking"])
			end
		end
	end
	
	--Spell specific
	self.Calculation["Steady Shot"] = function( calculation, ActiveAuras, _, spell )
		local min, max = DrDamage:GetRangedBase()
		local spd = select(3,DrDamage:GetWeaponSpeed())
		local ammo = DrDamage:GetAmmoDmg()
		if spd then
			calculation.minDam = calculation.minDam + min/spd * 2.8 + ammo
			calculation.maxDam = calculation.maxDam + max/spd * 2.8 + ammo
		end
		if ActiveAuras["Dazed"] then
			if spell.Daze then
				calculation.minDam = calculation.minDam + spell.Daze
				calculation.maxDam = calculation.maxDam + spell.Daze
			end
		end
		
	end
	self.Calculation["Aimed Shot"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Improved Steady Shot"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Steady Shot"])
		end
	end
	self.Calculation["Multi-Shot"] = function( calculation )
		--Gladiator's Chain Gauntlets
		if IsEquippedItem( 28335 ) or IsEquippedItem( 31961 ) or IsEquippedItem( 33665 ) then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	self.Calculation["Arcane Shot"] = function ( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Improved Steady Shot"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Steady Shot"])
		end
	end
	local ssting = GetSpellInfo(1978)
	self.Calculation["Chimera Shot"] = function ( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Improved Steady Shot"] then
			calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Improved Steady Shot"])
		end
		if ActiveAuras["Serpent Sting"] then --Modify Chimera tooltip to include damage on targets with Serpent Sting active
			local ssrank = tonumber(string_match((select(2, UnitDebuff("target", ssting))),"%d+")) --Strip the text and just use the raw number for the rank
			local dmgtoadd = (1 + (BuffTalentRanks["Improved Stings"] or 0)) * (self:GetRAP() * 0.2 + self.TargetAura[ssting].Value[ssrank]) -- RAP * 0.2 added to the damage for the particular rank (stored in the TargetAura["Serpent Sting"] = The normal total damage for that rank of Serpent Sting
			calculation.minDam = calculation.minDam + 0.4 * dmgtoadd -- Add 40% of that damage to the min and max damage values
			calculation.maxDam = calculation.maxDam + 0.4 * dmgtoadd -- DALLYTEMP
		end
	end
	
	--Set Bonuses
	self.SetBonuses["Rift Stalker Armor"] = { 30139, 30140, 30141, 30142, 30143 }
	self.SetBonuses["Gronnstalker's Armor"] = { 31001, 31003, 31004, 31005, 31006, 34443, 34549, 34570 }
	
	self.SetBonuses["Steady Shot"] = function( calculation )
		if self:GetSetAmount("Rift Stalker Armor") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "Gronnstalker's Armor" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end		
	end
	
	--AURA
	--Rapid Killing
	--Aspect of the Viper
	--The Beast Within
	--Improved Steady Shot
	--Dazed
	--Hunter's Mark	
	self.PlayerAura[GetSpellInfo(35098)] = { ModType = "ActiveAura", ActiveAura = "Rapid Killing" }
	self.PlayerAura[GetSpellInfo(34074)] = { ModType = "ActiveAura", ActiveAura = "Aspect of the Viper" }
	self.PlayerAura[GetSpellInfo(34471)] = { Spell = "All", Value = 0.1 }
	self.PlayerAura[GetSpellInfo(53220)] = { ModType = "ActiveAura", ActiveAura = "Improved Steady Shot" }
	self.TargetAura[GetSpellInfo(1604)] = { ModType = "ActiveAura", Spell = GetSpellInfo(34120), ActiveAura = "Dazed" }
	self.TargetAura[GetSpellInfo(1130)] = { Value = { 20, 45, 75, 110, 300 }, ModType = "Special" }
	--Serpent Sting
	self.TargetAura[GetSpellInfo(1978)] = { Value = { 20, 40, 80, 140, 210, 290, 385, 490, 555, 660, 990, 1210 }, ModType = "ActiveAura", ActiveAura = "Serpent Sting" }
	--Freezing Trap
	--Frost Trap
	--Freezing Arrow
	self.TargetAura[GetSpellInfo(3355)] = { ModType = "ActiveAura", ActiveAura = "Freezing Trap" }
	self.TargetAura[GetSpellInfo(13810)] = { ModType = "ActiveAura", ActiveAura = "Frost Trap" }
	self.TargetAura[GetSpellInfo(60210)] = { ModType = "ActiveAura", ActiveAura = "Freezing Arrow" }
	--TRACKING
	--Track Beasts
	--Track Demons
	--Track Dragonkin
	--Track Elementals
	--Track Giants
	--Track Humanoids
	--Track Undead
	self.PlayerAura[GetSpellInfo(1494)] = { ModType = "ActiveAura", ActiveAura = "Track Beasts" }
	self.PlayerAura[GetSpellInfo(19878)] = { ModType = "ActiveAura", ActiveAura = "Track Demons" }
	self.PlayerAura[GetSpellInfo(19879)] = { ModType = "ActiveAura", ActiveAura = "Track Dragonkin" }
	self.PlayerAura[GetSpellInfo(19880)] = { ModType = "ActiveAura", ActiveAura = "Track Elementals" }
	self.PlayerAura[GetSpellInfo(19882)] = { ModType = "ActiveAura", ActiveAura = "Track Giants" }
	self.PlayerAura[GetSpellInfo(19883)] = { ModType = "ActiveAura", ActiveAura = "Track Humanoids" }
	self.PlayerAura[GetSpellInfo(19884)] = { ModType = "ActiveAura", ActiveAura = "Track Undead" }
	
	self.Calculation[hmark] = function( calculation, ActiveAuras, BuffTalentRanks, _, _, _, rank )
		rank = rank and tonumber(string_match(rank,"%d+")) or 5
		if calculation.actionSchool == "Ranged" then
			calculation.AP = calculation.AP + self.TargetAura[hmark].Value[rank] * (1 + (BuffTalentRanks["Improved Hunter's Mark"] or 0))
		end
		ActiveAuras[hmark] = true
	end	
	
	self.spellInfo = {
		[GetSpellInfo(75)] = { --Processed --DALLYTEMP
			["Name"] = "Auto Shot",
			[0] = { School = "Ranged", WeaponDamage = 1, Shot = true, NoNormalization = true, AutoShot = true },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[GetSpellInfo(3044)] = { --Processed --DALLYTEMP
			["Name"] = "Arcane Shot",
			[0] = { School = { "Ranged", "Arcane" }, Shot = true, Cooldown = 6, APBonus = 0.15 },
			[1] = { 15 },
			[2] = { 23 },
			[3] = { 36 },
			[4] = { 65 },
			[5] = { 91 },
			[6] = { 125 },
			[7] = { 158 },
			[8] = { 200 },
			[9] = { 273 },
			[10] = { 402 },
			[11] = { 492 },
		},
		[GetSpellInfo(19434)] = { --Processed --DALLYTEMP
			["Name"] = "Aimed Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 1, Cooldown = 10 },
			[1] = { 5 },
			[2] = { 35 },
			[3] = { 55 },
			[4] = { 90 },
			[5] = { 110 },
			[6] = { 150 },
			[7] = { 205 },
			[8] = { 345 },
			[9] = { 408 },
		},
		[GetSpellInfo(2643)] = { --Processed --DALLYTEMP
			["Name"] = "Multi-Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 1, Cooldown = 10 },
			[1] = { 0 },
			[2] = { 40 },
			[3] = { 80 },
			[4] = { 120 },
			[5] = { 150 },
			[6] = { 205 },
			[7] = { 333 },
			[8] = { 408 },
		},
		[GetSpellInfo(19503)] = {
			["Name"] = "Scatter Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 0.5, Cooldown = 30 },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[GetSpellInfo(34490)] = { --Processed --DALLYTEMP
			["Name"] = "Silencing Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 0.5, Cooldown = 20 },
			["None"] = { 0 },
			[1] = { 0 },
		},
		[GetSpellInfo(34120)] = { --Processed --DALLYTEMP
			["Name"] = "Steady Shot",
			[0] = { School = "Ranged", Shot = true, castTime = 1.5, APBonus = 0.2, DPSrg = true },
			[1] = { 45, Daze = 175  },
			[2] = { 108, Daze = 175 },
			[3] = { 198, Daze = 175 },
			[4] = { 252, Daze = 175 },
		},
		[GetSpellInfo(1978)] = { --Processed --DALLYTEMP
			["Name"] = "Serpent Sting",
			[0] = { School = { "Ranged", "Nature" }, APBonus = 0.2, NoCrits = true, eDuration = 15, Ticks = 3 },
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
			[11] = { 990 },
			[12] = { 1210 },
		},
		[GetSpellInfo(1510)] = { --Processed, but not happy with the way this is handled. There's no channeling calculations in Melee.lua. Will have to do it properly later. --DALLYTEMP
			["Name"] = "Volley",
			[0] = { School = { "Ranged", "Arcane" }, castTime = 6, Ticks = 1 },
			[1] = { 450 },
			[2] = { 678 },
			[3] = { 864 },
			[4] = { 1440 },
			[5] = { 2484 },
			[6] = { 3030 },
		},
		[GetSpellInfo(53351)] = { --Added --DALLYTEMP
			["Name"] = "Kill Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 2, APBonus = 0.4, Cooldown = 35 },
			[1] = { 410 },
			[2] = { 500 },
			[3] = { 650 },
		},
		[GetSpellInfo(53209)] = {
			["Name"] = "Chimera Shot",
			[0] = { School = "Ranged", Shot = true, WeaponDamage = 1.25, Cooldown = 10 },
			[1] = { 0 },
		},
		[GetSpellInfo(13795)] = { --Processed --DALLYTEMP
			["Name"] = "Immolation Trap",
			[0] = { School = { "Ranged", "Fire" }, Unresistable = true, APBonus = 0.1, NoCrits = true, eDuration = 15, Ticks = 3, Cooldown = 30, NoWeapon = true },
			[1] = { 105 },
			[2] = { 215 },
			[3] = { 340 },
			[4] = { 510 },
			[5] = { 690 },
			[6] = { 985 },
			[7] = { 1540 },
			[8] = { 1885 },
		},
		[GetSpellInfo(13813)] = { --Processed --DALLYTEMP
			["Name"] = "Explosive Trap",
			[0] = { School = { "Ranged", "Fire" }, Unresistable = true, APBonus = 0.1, ExtraDamage = 0, E_eDuration = 20, NoCrits = true, Cooldown = 30, NoWeapon = true },
			[1] = { 100, 130, Extra = 150 },
			[2] = { 139, 187, Extra = 240 },
			[3] = { 201, 257, Extra = 330 },
			[4] = { 263, 337, Extra = 450 },
			[5] = { 434, 556, Extra = 740 },
			[6] = { 523, 671, Extra = 900 },
		},		
		[GetSpellInfo(19386)] = { --Processed --DALLYTEMP
			["Name"] = "Wyvern Sting",
			[0] = { School = { "Ranged", "Nature" }, NoCrits = true, eDuration = 6 },
			[1] = { 300 },
			[2] = { 420 },
			[3] = { 600 },
			[4] = { 942 },
			[5] = { 2082 },
			[6] = { 2460 },
		},
		[GetSpellInfo(2973)] = { --Processed --DALLYTEMP
			["Name"] = "Raptor Strike",
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
			[10] = { 275 },
			[11] = { 335 },
		},
		[GetSpellInfo(1495)] = { --Processed --DALLYTEMP
			["Name"] = "Mongoose Bite",
			[0] = { Cooldown = 5, APBonus = 0.2, NoWeapon = true },
			[1] = { 25 },
			[2] = { 45 },
			[3] = { 75 },
			[4] = { 115 },
			[5] = { 150 },
			[6] = { 280 },
		},
		[GetSpellInfo(19306)] = { --Processed --DALLYTEMP
			["Name"] = "Counterattack",
			[0] = { Cooldown = 5, APBonus = 0.2, NoWeapon = true },
			[1] = { 48 },
			[2] = { 84 },
			[3] = { 132 },
			[4] = { 196 },
			[5] = { 288 },
			[6] = { 342 },
		},
	}
	self.talentInfo = {
		--Beast Mastery:
		--Focused Fire
		--Aspect Mastery
		[GetSpellInfo(35029)] = {	[1] = { Effect = 0.02, Spells = "All", ModType = "Amount", Value = "Focused Fire" }, },
		[GetSpellInfo(53265)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Amount", Value = "Aspect Mastery" }, },
		
		--Marksmanship:
		--Improved Hunter's Mark
		--Mortal Shots
		--Improved Arcane Shot
		--Rapid Killing
		--Improved Stings		
		--Barrage
		--Ranged Weapon Specialization
		--Improved Barrage
		--Improved Steady Shot
		--Marked for Death
		[GetSpellInfo(19421)] = {	[1] = { Effect = 0.1, Spells = "Physical", ModType = "Amount", Value = "Improved Hunter's Mark" }, }, -- Effect changed to AP bonus.-- DALLYTEMP
		[GetSpellInfo(19485)] = {	[1] = { Effect = 0.06, Spells = "Ranged", ModType = "critM" }, },
		[GetSpellInfo(19454)] = {	[1] = { Effect = 0.05, Spells = "Arcane Shot" }, },
		[GetSpellInfo(34948)] = {	[1] = { Effect = 0.1, Spells = { "Aimed Shot", "Arcane Shot", "Chimera Shot" }, ModType = "Amount", Value = "Rapid Killing"  }, },
		[GetSpellInfo(19464)] = {	[1] = { Effect = 0.1, Spells = { "Serpent Sting", "Wyvern Sting" } }, 
						[2] = { Effect = 0.1, Spells = "Chimera Shot", ModType = "Amount", Value = "Improved Stings" } },		
		[GetSpellInfo(19461)] = {	[1] = { Effect = 0.04, Spells = { "Aimed Shot", "Multi-Shot", "Volley" }, }, },
		[GetSpellInfo(19507)] = {	[1] = { Effect = 0.01, Spells = "Ranged" }, },
		[GetSpellInfo(35104)] = {	[1] = { Effect = 4, Spells = { "Aimed Shot", "Multi-Shot" }, ModType = "critPerc" }, },
		[GetSpellInfo(53221)] = {	[1] = { Effect = 0.15, Spells = { "Aimed Shot", "Arcane Shot", "Chimera Shot" }, ModType = "Amount", Value = "Improved Steady Shot" }, },
		[GetSpellInfo(53241)] = { 	[1] = { Effect = 0.01, School = "Shot", ModType = "Amount", Value = "Marked for Death" },
						[2] = { Effect = 2, Spells = { "Aimed Shot", "Steady Shot", "Kill Shot", "Chimera Shot" }, ModType = "critPerc" }, },
		--Survival:
		--Improved Tracking
		--Savage Strikes
		--Survival Instincts
		--T.N.T.
		--Clever Traps
		--Resourcefulness
		--Noxious Stings
		--Point of No Escape
		--Trap Mastery
		--Sniper Training (Kill Shot bonus only)
		[GetSpellInfo(52783)] = {	[1] = { Effect = 0.01, Spells = "All", ModType = "Amount", Value = "Improved Tracking" }, },
		[GetSpellInfo(19159)] = {	[1] = { Effect = 10, Spells = { "Raptor Strike", "Mongoose Bite", "Counterattack" }, ModType = "critPerc" }, },
		[GetSpellInfo(34494)] = {	[1] = { Effect = 2, Spells = { "Arcane Shot", "Steady Shot", "Explosive Shot" }, ModType = "critPerc" }, }, 
		[GetSpellInfo(56333)] = {	[1] = { Effect = 3, Spells = "Explosive Shot", ModType = "critPerc" }, },
		--[GetSpellInfo(19239)] = {	[1] = { Effect = 0.15, Spells = { "Explosive Trap", "Immolation Trap" }, }, },
		[GetSpellInfo(34491)] = {	[1] = { Effect = -2, Spells = { "Explosive Trap", "Immolation Trap" }, ModType = "cooldown" }, },
		[GetSpellInfo(53295)] = { 	[1] = { Effect = 0.01, Spells = "All", ModType = "Amount", Value = "Noxious Stings" }, },
		[GetSpellInfo(53298)] = {	[1] = { Effect = 3, Spells = "All", ModType = "Amount", Value = "Point of No Escape" }, },
		[GetSpellInfo(19376)] = {	[1] = { Effect = 0.3, Spells = { "Immolation Trap", "Explosive Trap" } }, },
		[GetSpellInfo(53302)] = {	[1] = { Effect = 5, Spells = "Kill Shot", ModType = "critPerc" }, },
	}
end