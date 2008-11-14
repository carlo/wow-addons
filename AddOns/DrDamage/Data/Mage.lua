if select(2, UnitClass("player")) ~= "MAGE" then return end
local GetSpellInfo = GetSpellInfo
local UnitManaMax = UnitManaMax
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

function DrDamage:PlayerData()

	--Special AB info
	--Evocation
	self.ClassSpecials[GetSpellInfo(12051)] = function()
		if self:GetSetAmount( "Tempest Regalia" ) >= 2 then
			return 0.75 * UnitManaMax("player"), 0.40, 0.8, 1
		else
			return 0.6 * UnitManaMax("player"), 0.40, 0.8, 1
		end
	end
	
	--General
	--Snare list for Torment the Weak
	--Wing Clip, Frost Trap Aura, Concussive Shot, Frostbolt
	--Cone of Cold, Blast Wave, Slow, Mind Flay, Crippling Poison (may be wrong debuff), Deadly Throw,
	--Frost Shock, Earthbind, Curse of Exhaustion, Hamstring, Piercing Howl, Infected Wounds
	local snareList = { (GetSpellInfo(2974)), (GetSpellInfo(13810)), (GetSpellInfo(5116)), (GetSpellInfo(116)),
								(GetSpellInfo(120)), (GetSpellInfo(11113)), (GetSpellInfo(31589)), (GetSpellInfo(15407)), (GetSpellInfo(25809)), (GetSpellInfo(26679)),
								(GetSpellInfo(8056)), (GetSpellInfo(3600)), (GetSpellInfo(18223)), (GetSpellInfo(1715)), (GetSpellInfo(12323)), (GetSpellInfo(58179)) }
	
	self.Calculation["MAGE"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if self.db.profile.ManaConsumables then
			calculation.manaRegen = calculation.manaRegen + 20 --Assumes usage of Conjured Mana Emeralds 
		end
		--There's a problem here that the target gaining a snare won't trigger an update
		if BuffTalentRanks["Torment the Weak"] then
			for _,k in ipairs(snareList) do
				if UnitDebuff("target", k) then
					calculation.dmgM = calculation.dmgM * (1 + BuffTalentRanks["Torment the Weak"])
					break
				end	
			end
		end
		if BuffTalentRanks["Molten Fury"] then
			if UnitHealth("target") ~= 0 then
				if (UnitHealth("target") / UnitHealthMax("target")) < 0.35 then
					calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Molten Fury"])
				end
			end
		end
	end
	--Spell specific
	self.Calculation["Ice Lance"] = function( calculation, ActiveAuras )
		if ActiveAuras["Frost Nova"] or ActiveAuras["Frostbite"] or ActiveAuras["Fingers of Frost"] or ActiveAuras["Deep Freeze"] then
			calculation.spellDmgM = calculation.spellDmgM  * 3
			calculation.bDmgM = calculation.bDmgM  + 2
		end
	end
	
	--Set Bonuses
	--Sets
	self.SetBonuses["Tirisfal Armor"] = { 30196, 30205, 30206, 30207, 30210 }
	self.SetBonuses["Tempest Regalia"] = { 31055, 31056, 31057, 31058, 31059, 34447, 34557, 34574 }
	
	--Effects
	self.SetBonuses["Arcane Blast"] = function( calculation )
		if self:GetSetAmount( "Tirisfal Armor" ) >= 2 then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	self.SetBonuses["Fireball"] = function( calculation )
		if self:GetSetAmount( "Tempest Regalia" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end	
	end
	self.SetBonuses["Frostbolt"] = self.SetBonuses["Fireball"]
	self.SetBonuses["Arcane Missiles"] = self.SetBonuses["Fireball"]
	
	
	--AURA
	--Icy Veins
	--Arcane Blast
	--Arcane Power
	--Combustion
	--Fingers of Frost
	--Frost Nova
	--Frostbite
	--Deep Freeze
	self.PlayerAura[GetSpellInfo(12472)] = { Mods = { ["castTime"] = function(v) return v/1.2 end } }
	self.PlayerAura[GetSpellInfo(30451)] = { ModType = "Update", Spell = GetSpellInfo(30451) }	
	self.PlayerAura[GetSpellInfo(12042)] = { Value = 0.3 }
	self.PlayerAura[GetSpellInfo(11129)] = { School = "Fire", Value = 10, Apps = 3, ModType = "critPerc" }	
	self.PlayerAura[GetSpellInfo(44544)] = { ModType = "Special", }
	self.TargetAura[GetSpellInfo(122)] = { ModType = "Special", }	
	self.TargetAura[GetSpellInfo(12494)] = { ModType = "Special", }
	self.TargetAura[GetSpellInfo(44572)] = { ModType = "Special", }
	
	--Frost Nova
	self.Calculation[GetSpellInfo(122)] = function( calculation, ActiveAuras, BuffTalentRanks )
		if not ActiveAuras["Frost Nova"] and not ActiveAuras["Frostbite"] and not ActiveAuras["Fingers of Frost"] and not ActiveAuras["Deep Freeze"] then
			ActiveAuras["Frost Nova"] = true
			if BuffTalentRanks["Shatter"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Shatter"]
			end
		end
	end
	--Frostbite
	self.Calculation[GetSpellInfo(12494)] = function( calculation, ActiveAuras, BuffTalentRanks )
		if not ActiveAuras["Frost Nova"] and not ActiveAuras["Frostbite"] and not ActiveAuras["Fingers of Frost"] and not ActiveAuras["Deep Freeze"] then
			ActiveAuras["Frostbite"] = true
			if BuffTalentRanks["Shatter"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Shatter"]
			end
		end
	end
	--Fingers of Frost
	self.Calculation[GetSpellInfo(44544)] = function( calculation, ActiveAuras, BuffTalentRanks )
		if not ActiveAuras["Frost Nova"] and not ActiveAuras["Frostbite"] and not ActiveAuras["Fingers of Frost"] and not ActiveAuras["Deep Freeze"] then
			ActiveAuras["Fingers of Frost"] = true
			if BuffTalentRanks["Shatter"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Shatter"]
			end
		end
	end
	--Deep Freeze
	self.Calculation[GetSpellInfo(44572)] = function( calculation, ActiveAuras, BuffTalentRanks )
		if not ActiveAuras["Frost Nova"] and not ActiveAuras["Frostbite"] and not ActiveAuras["Fingers of Frost"] and not ActiveAuras["Deep Freeze"] then
			ActiveAuras["Deep Freeze"] = true
			if BuffTalentRanks["Shatter"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Shatter"]
			end
		end
	end
	
	self.spellInfo = {
		[GetSpellInfo(11366)] = { --Processed --DALLYTEMP
					["Name"] = "Pyroblast",
					[0] = { School = "Fire", castTime = 6, canCrit = true, eDuration=12, sTicks = 3, bonusFactor = 1.15, hybridDotFactor = 0.25, BaseIncrease = true, LevelIncrease = 5, },
					[1] = { 141, 187, 7, 8, hybridDotDmg = 56, spellLevel = 20, },
					[2] = { 180, 236, 13, 14, hybridDotDmg = 72, spellLevel = 24, },
					[3] = { 255, 327, 15, 16, hybridDotDmg = 96, spellLevel = 30, },
					[4] = { 329, 419, 18, 18, hybridDotDmg = 124, spellLevel = 36, },
					[5] = { 407, 515, 20, 21, hybridDotDmg = 156, spellLevel = 42, },
					[6] = { 503, 631, 22, 23, hybridDotDmg = 188, spellLevel = 48, },
					[7] = { 600, 750, 25, 26, hybridDotDmg = 228, spellLevel = 54, },
					[8] = { 708, 898, 27, 28, hybridDotDmg = 268, spellLevel = 60, },
					[9] = { 846, 1074, 20, 20, hybridDotDmg = 312, spellLevel = 66, },
					[10] = { 939, 1191, 0, 0, hybridDotDmg = 356, spellLevel = 70, },
					[11] = { 1014, 1286, 0, 0, hybridDotDmg = 384, spellLevel = 73, },
					[12] = { 1190, 1510, 0, 0, hybridDotDmg = 452, spellLevel = 77, },
		},
		[GetSpellInfo(133)] = { --Processed --DALLYTEMP
					["Name"] = "Fireball",
					[0] = { School = "Fire", canCrit = true, castTime = 3.5, CastMod = 0.1, eDuration=8, sTicks = 2, BaseIncrease = true, LevelIncrease = 3, },
					[1] = { 14, 22, 2, 3, extraDotDmg= 2, spellLevel = 1, castTime = 1.5, eDuration = 4, },
					[2] = { 31, 45, 3, 4, extraDotDmg= 3, spellLevel = 6, castTime = 2, eDuration = 6, },
					[3] = { 53, 73, 4, 4, extraDotDmg= 6, spellLevel = 12, castTime = 2.5, eDuration = 6, },
					[4] = { 84, 116, 5, 6, extraDotDmg= 12, spellLevel = 18, castTime = 3, },
					[5] = { 139, 187, 6, 8, extraDotDmg= 20, spellLevel = 24, },
					[6] = { 199, 265, 8, 9, extraDotDmg= 28, spellLevel = 30, },
					[7] = { 255, 335, 11, 10, extraDotDmg= 32, spellLevel = 36, },
					[8] = { 318, 414, 10, 11, extraDotDmg=40, spellLevel = 42, },
					[9] = { 392, 506, 12, 12, extraDotDmg=52, spellLevel = 48, },
					[10] = { 475, 609, 13, 14, extraDotDmg=60, spellLevel = 54, },
					[11] = { 561, 715, 14, 15, extraDotDmg=72, spellLevel = 60, },
					[12] = { 596, 760, 15, 16, extraDotDmg=76, spellLevel = 60, },
					[13] = { 633, 805, 16, 16, extraDotDmg=84, spellLevel = 66, },
					[14] = { 717, 913, 0, 0, extraDotDmg=92, spellLevel = 70, },
					[15] = { 783, 997, 0, 0, extraDotDmg=100, spellLevel = 74, },
					[16] = { 888, 1132, 0, 0, extraDotDmg=116, spellLevel = 78, },
		},
		[GetSpellInfo(2948)] = { --Processed --DALLYTEMP
					["Name"] = "Scorch",
					[0] = { School = "Fire", canCrit = true, BaseIncrease = true, LevelIncrease = 5, },
					[1] = { 53, 65, 3, 4, spellLevel = 22, },
					[2] = { 77, 93, 4, 5, spellLevel = 28, },
					[3] = { 100, 120, 5, 6, spellLevel = 34, },
					[4] = { 133, 159, 6, 6, spellLevel = 40, },
					[5] = { 162, 192, 6, 7, spellLevel = 46, },
					[6] = { 200, 239, 7, 8, spellLevel = 52, },
					[7] = { 233, 275, 8, 9, spellLevel = 58, },
					[8] = { 269, 317, 9, 10, spellLevel = 64, },
					[9] = { 305, 361, 0, 0, spellLevel = 70, },
					[10] = { 321, 379, 0, 0, spellLevel = 73, },
					[11] = { 376, 444, 0, 0, spellLevel = 78, },
		},
		[GetSpellInfo(2136)] = { --Processed --DALLYTEMP
					["Name"] = "Fire Blast",
					[0] = { School = "Fire", canCrit = true, Cooldown = 8, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 24, 32, 3, 3, spellLevel = 6, },
					[2] = { 57, 71, 5, 5, spellLevel = 14, },
					[3] = { 103, 127, 7, 7, spellLevel = 22, },
					[4] = { 168, 202, 9, 9, spellLevel = 30, },
					[5] = { 242, 290, 11, 11, spellLevel = 38, },
					[6] = { 332, 394, 13, 13, spellLevel = 46, },
					[7] = { 431, 509, 15, 15, spellLevel = 54, },
					[8] = { 539, 637, 16, 18, spellLevel = 61, },
					[9] = { 664, 786, 0, 0, spellLevel = 70, },
					[10] = { 760, 900, 0, 0, spellLevel = 74, },
					[11] = { 925, 1095, 0, 0, spellLevel = 80, },
		},				
		[GetSpellInfo(11113)] = { --Processed --DALLYTEMP
					["Name"] = "Blast Wave",
					[0] = { School = "Fire", canCrit = true, sFactor=0.90 * 1/2, Cooldown = 45, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 154, 186, 6, 6, spellLevel = 30, },
					[2] = { 201, 241, 7, 8, spellLevel = 36, },
					[3] = { 277, 329, 8, 9, spellLevel = 44, },
					[4] = { 365, 433, 9, 10, spellLevel = 52, },
					[5] = { 462, 544, 11, 12, spellLevel = 60, },
					[6] = { 533, 627, 10, 11, spellLevel = 65, },
					[7] = { 616, 724, 0, 0, spellLevel = 70, },
					[8] = { 882, 1038, 0, 0, spellLevel = 75, },
					[9] = { 1047, 1233, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(31661)] = { --Processed --DALLYTEMP
					["Name"] = "Dragon's Breath",
					[0] = { School = "Fire", canCrit = true, sFactor= 0.90 * 1/2, Cooldown = 20, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 370, 430, 12, 12, spellLevel = 50, },
					[2] = { 454, 526, 9, 10, spellLevel = 56, },
					[3] = { 574, 666, 10, 11, spellLevel = 64, },
					[4] = { 680, 790, 0, 0, spellLevel = 70, },
					[5] = { 935, 1085, 0, 0, spellLevel = 75, },
					[6] = { 1101, 1279, 0, 0, spellLevel = 80, },
		},				
		[GetSpellInfo(2120)] = { --Processed --DALLYTEMP
					["Name"] = "Flamestrike",
					[0] = { School = "Fire", castTime = 3, canCrit = true, eDuration = 8, sTicks = 2, sFactor = 1/2, hybridFactor = 417/757, hybridDotFactor = 0.83, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 52, 68, 3, 3, hybridDotDmg = 48, spellLevel = 16, },
					[2] = { 96, 122, 4, 4, hybridDotDmg = 88, spellLevel = 24, },
					[3] = { 154, 192, 5, 5, hybridDotDmg = 140, spellLevel = 32, },
					[4] = { 220, 272, 6, 7, hybridDotDmg = 196, spellLevel = 40, },
					[5] = { 291, 359, 7, 8, hybridDotDmg = 264, spellLevel = 48, },
					[6] = { 375, 459, 8, 9, hybridDotDmg = 340, spellLevel = 56, },
					[7] = { 471, 575, 9, 10, hybridDotDmg = 424, spellLevel = 64, },
					[8] = { 688, 842, 0, 0, hybridDotDmg = 620, spellLevel = 72, },
					[9] = { 873, 1067, 0, 0, hybridDotDmg = 780, spellLevel = 79, },
					--Check LevelIncrease
		},
		[GetSpellInfo(44457)] = { --Added --DALLYTEMP
					["Name"] = "Living Bomb", -- Need to find hybridFactor, also each rank has TWO entries in wowhead, likely only one of each will be valid on release --DALLYTEMP
					[0] = { School = "Fire", canCrit = true, eDuration = 12, hybridFactor = 0.349, sTicks = 3, },
					[1] = { 306, 306, hybridDotDmg = 612, spellLevel = 60, },
					[2] = { 512, 512, hybridDotDmg = 1024, spellLevel = 70, },
					[3] = { 306, 306, hybridDotDmg = 1380, spellLevel = 60, }, --The explosion damage on this rank must be incorrect --DALLYTEMP
		},
		[GetSpellInfo(44614)] = { --Added --DALLTEMP
					["Name"] = "Frostfire Bolt", --Using Secondary to simulate the Frost version as there's no way I'm aware to determine whether a target is more vulnerable to fire or frost. --DALLYTEMP
					[0] = { School = "Fire", canCrit = true, castTime = 3, eDuration=9, sTicks = 3, }, 
					[1] = { 629, 731, extraDotDmg= 60, spellLevel = 75, },
					[2] = { 722, 838, extraDotDmg= 90, spellLevel = 80, },
			["Secondary"] = {
					["Name"] = "Frostfire Bolt",
					[0] = { School = "Frost", canCrit = true, castTime = 3, eDuration=9, sTicks = 3, }, 
					[1] = { 629, 731, extraDotDmg= 60, spellLevel = 75, },
					[2] = { 722, 838, extraDotDmg= 90, spellLevel = 80, },
			}
		},
		[GetSpellInfo(116)] = { --Processed --DALLYTEMP
					["Name"] = "Frostbolt",
					[0] = { School = "Frost", castTime = 3, canCrit = true, CastMod = 0.1, sFactor_Base = 0.95, BaseIncrease = true, LevelIncrease = 4, },
					[1] = { 18, 20, 2, 2, spellLevel = 4, castTime = 1.5, },
					[2] = { 31, 35, 2, 3, spellLevel = 8, castTime = 1.8, },
					[3] = { 51, 57, 3, 4, spellLevel = 14, castTime = 2.2, },
					[4] = { 74, 82, 4, 5, spellLevel = 20, castTime = 2.6, },
					[5] = { 126, 138, 6, 6, spellLevel = 26, },
					[6] = { 174, 190, 6, 7, spellLevel = 32, },
					[7] = { 227, 247, 8, 8, spellLevel = 38, },
					[8] = { 292, 316, 9, 10, spellLevel = 44, },
					[9] = { 353, 383, 10, 11, spellLevel = 50, },
					[10] = { 429, 463, 11, 12, spellLevel = 56, },
					[11] = { 515, 555, 12, 13, spellLevel = 60, },
					[12] = { 536, 578, 12, 13, spellLevel = 63, },
					[13] = { 597, 643, 13, 14, spellLevel = 69, }, --Guess --DALLYTEMP
					[14] = { 630, 680, 0, 0, spellLevel = 70, },
					[15] = { 702, 758, 0, 0, spellLevel = 75, },
					[16] = { 799, 861, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(10)] = { --Processed --DALLYTEMP
					["Name"] = "Blizzard",
					[0] = { School = "Frost", canCrit = "true", castTime = 8, bonusFactor = 1.14797, BaseIncrease = true, sTicks = 1, LevelIncrease = 7, },
					[1] = { 288, 288, 0, 0, spellLevel = 20, },
					[2] = { 504, 504, 8, 8, spellLevel = 28, },
					[3] = { 736, 736, 8, 8, spellLevel = 36, },
					[4] = { 1024, 1024, 8, 8, spellLevel = 44, },
					[5] = { 1328, 1328, 8, 8, spellLevel = 52, },
					[6] = { 1696, 1696, 16, 16, spellLevel = 60, }, --Need new baseincrease values for rank 6 and 7! --DALLYTEMP
					[7] = { 2184, 2184, 16, 16, spellLevel = 68, }, --Guess --DALLYTEMP
					[8] = { 2800, 2800, 0, 0, spellLevel = 74, },
					[9] = { 3408, 3408, 0, 0, spellLevel = 80, },
					--Check LevelIncrease
		},
		--Empiric tests suggests: 1.5/3.5 * 1/2 * 0.8
		[GetSpellInfo(120)] = { --Processed --DALLYTEMP
					["Name"] = "Cone of Cold",
					[0] = { School = "Frost", canCrit = true, sFactor= 0.80 * 1/2, Cooldown = 10, BaseIncrease = true, LevelIncrease = 9, },
					[1] = { 98, 108, 4, 4, spellLevel = 26, },
					[2] = { 146, 160, 5, 5, spellLevel = 34, },
					[3] = { 203, 223, 6, 6, spellLevel = 42, },
					[4] = { 264, 290, 6, 7, spellLevel = 50, },
					[5] = { 335, 365, 7, 8, spellLevel = 58, },
					[6] = { 410, 448, 8, 9, spellLevel = 66, }, --Guess --DALLYTEMP
					[7] = { 559, 611, 0, 0, spellLevel = 72, },
					[8] = { 707, 773, 0, 0, spellLevel = 79, },
					--Check LevelIncrease
		},
		[GetSpellInfo(122)] = { --Processed --DALLYTEMP
					["Name"] = "Frost Nova",
					[0] = { School = "Frost", canCrit = true, sFactor= 0.13 * 1/2, Cooldown = 25, BaseIncrease = true, LevelIncrease = 15, },
					[1] = { 19, 21, 2, 3,  spellLevel = 10, },
					[2] = { 33, 37, 2, 3,  spellLevel = 26, },
					[3] = { 52, 58, 2, 3, spellLevel = 40, },
					[4] = { 70, 80, 2, 3, spellLevel = 54, }, -- Need updates BaseIncrease values --DALLYTEMP
					[5] = { 230, 260, 2, 3, spellLevel = 67, },
					[6] = { 365, 415, 0, 0, spellLevel = 75, },
					--Check LevelIncrease
		},
		[GetSpellInfo(30455)] = { --Processed --DALLYTEMP
					["Name"] = "Ice Lance",
					[0] = { School = "Frost", canCrit = true, sFactor = 1/3, BaseIncrease = true, LevelIncrease = 6}, --Need to find LevelIncrease --DALLYTEMP
					[1] = { 161, 187, 9, 13, spellLevel = 66, },
					[2] = { 182, 210, 0, 0, spellLevel = 72, },
					[3] = { 221, 255, 0, 0, spellLevel = 78, },
		},			
		[GetSpellInfo(11426)] = { --Processed --DALLYTEMP
					["Name"] = "Ice Barrier",
					[0] = { School = "Frost", Cooldown = 10, bonusFactor = 0.3, NoSchoolTalents = true, NoDPS = true, NoDoom = true, Unresistable = true, NoAura = true, NoDPM = true, BaseIncrease = true, LevelIncrease = 5, },
					[1] = { 438, 438, 16, 16,  spellLevel = 40, },
					[2] = { 549, 549, 19, 19, spellLevel = 46, },
					[3] = { 678, 678, 21, 21, spellLevel = 52, },
					[4] = { 818, 818, 24, 24, spellLevel = 58, },
					[5] = { 925, 925, 26, 26, spellLevel = 64, },
					[6] = { 1075, 1075, 0, 0, spellLevel = 70, },
					[7] = { 2800, 2800, 0, 0, spellLevel = 75, },
					[8] = { 3300, 3300, 0, 0, spellLevel = 80, },
					--Check LevelIncrease
		},
		[GetSpellInfo(5143)] = { --Processed --DALLYTEMP
					["Name"] = "Arcane Missiles",
					[0] = { School = "Arcane", canCrit = true, castTime = 5, sHits = 5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 24, 24, 1, 2, spellLevel = 8, castTime = 3, sHits = 3, },
					[2] = { 36, 36, 1, 2, spellLevel = 16, castTime = 4, sHits = 4, },
					[3] = { 56, 56, 2, 2, spellLevel = 24, },
					[4] = { 83, 83, 2, 3, spellLevel = 32, },
					[5] = { 115, 115, 2, 3, spellLevel = 40, },
					[6] = { 151, 151, 3, 4, spellLevel = 48, },
					[7] = { 192, 192, 3, 4, spellLevel = 56, },
					[8] = { 230, 230, 4, 4, spellLevel = 60, },
					[9] = { 240, 240, 3, 4, spellLevel = 63, },
					[10] = { 263, 264, 3, 4, spellLevel = 69, }, --Blizzard tooltip reports wrong basedamage (real is +3,4)
					[11] = { 280, 280, 0, 0, spellLevel = 70, },
					[12] = { 320, 320, 0, 0, spellLevel = 75, },
					[13] = { 360, 360, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(1449)] = { --Processed --DALLYTEMP
					["Name"] = "Arcane Explosion",
					[0] = { School = "Arcane", canCrit = true, sFactor = 1/2, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 32, 36, 2, 2,  spellLevel = 14, },
					[2] = { 57, 63, 3, 3, spellLevel = 22, },
					[3] = { 97, 105, 4, 5, spellLevel = 30, },
					[4] = { 139, 151, 4, 5, spellLevel = 38, },
					[5] = { 186, 202, 5, 6, spellLevel = 46, },
					[6] = { 243, 263, 6, 7, spellLevel = 54, },
					[7] = { 306, 330, 7, 8, spellLevel = 62, },
					[8] = { 377, 407, 0, 0, spellLevel = 70, },
					[9] = { 481, 519, 0, 0, spellLevel = 76, },
					[10] = { 538, 582, 0, 0, spellLevel = 80, },
					--Check LevelIncrease
		},
		[GetSpellInfo(30451)] = { --Processed --DALLYTEMP
					["Name"] = "Arcane Blast",
					[0] = { School = "Arcane", canCrit = true, castTime = 2.5, BaseIncrease = true, LevelIncrease = 6}, --Need to find LevelIncrease --DALLYTEMP
					[1] = { 648, 752, 20, 20, spellLevel = 64, },
					[2] = { 690, 800, 0, 0, spellLevel = 71, },
					[3] = { 805, 935, 0, 0, spellLevel = 76, },
					[4] = { 912, 1058, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(44425)] = { --Added --DALLYTEMP
					["Name"] = "Arcane Barrage",
					[0] = { School = "Arcane", sFactor = 1.5, canCrit = true, },
					[1] = { 386, 470, spellLevel = 60, },
					[2] = { 709, 865, spellLevel = 70, },
					[3] = { 936, 1144, spellLevel = 80, },
		},
		[GetSpellInfo(6143)] = { --Processed --DALLYTEMP
					["Name"] = "Frost Ward",
					[0] = { School = "Frost", bonusFactor = 0.30, NoSchoolTalents= true, NoDPS = true, NoTooltip = true, NoAura = true, Unresistable = true, },
					[1] = { 165, 165, spellLevel = 22, },
					[2] = { 290, 290, spellLevel = 32, },
					[3] = { 470, 470, spellLevel = 42, },
					[4] = { 675, 675, spellLevel = 52, },
					[5] = { 875, 875, spellLevel = 60, },
					[6] = { 1125, 1125, spellLevel = 70, },
					[7] = { 1950, 1950, spellLevel = 79, },
		},
		[GetSpellInfo(543)] = { --Processed --DALLYTEMP
					["Name"] = "Fire Ward",
					[0] = { School = "Fire", bonusFactor = 0.30, NoSchoolTalents= true, NoDPS = true, NoTooltip = true, NoAura = true, Unresistable = true, },
					[1] = { 165, 165, spellLevel = 20, },
					[2] = { 290, 290, spellLevel = 30, },
					[3] = { 470, 470, spellLevel = 40, },
					[4] = { 675, 675, spellLevel = 50, },
					[5] = { 875, 875, spellLevel = 60, },
					[6] = { 1125, 1125, spellLevel = 69, },
					[7] = { 1950, 1950, spellLevel = 78, },
		},		
		[GetSpellInfo(28880)] = {
					["Name"] = "Gift of the Naaru",
					[0] = { School = { "Holy", "Healing" }, Cooldown = 180, eDot = true, eDuration = 15, sTicks = 3, bonusFactor = 1, BaseIncrease = true, NoLowLevelPenalty = true, NoDownRank = true, },
					["None"] = { 50, 50, 1035, 1035, spellLevel = 1, },
		},
	}
	self.talentInfo = { 
		--ARCANE:
		--Arcane Focus
		--Spell Impact
		--Torment the Weak
		--Arcane Instability
		--Arcane Empowerment		
		--Spell Power	
		[GetSpellInfo(11222)] = {		[1] = { Effect = 1, Spells = "Arcane", ModType = "hitPerc" }, },
		[GetSpellInfo(11242)] = {		[1] = { Effect = 0.02, Spells = { "Arcane Explosion", "Arcane Blast", "Blast Wave", "Fire Blast", "Scorch", "Fireball", "Ice Lance", "Cone of Cold" }, }, },
		[GetSpellInfo(29447)] = {		[1] = { Effect = 0.04, Spells = { "Frostbolt", "Fireball", "Frostfire Bolt", "Arcane Missiles", "Arcane Barrage" }, ModType = "Amount", Value = "Torment the Weak" }, },
		[GetSpellInfo(15058)] = {		[1] = { Effect = 0.01, Spells = "All" }, },
		[GetSpellInfo(31579)] = { 	[1] = { Effect = 0.15, Spells = "Arcane Missiles", ModType = "SpellDamage", }, 
																[2]	= { Effect = 0.03, Spells = "Arcane Blast", ModType = "SpellDamage", }, },
		[GetSpellInfo(35578)] = { 	[1] = { Effect = 0.125, Spells = "All", ModType = "critM", }, },
		
		--FIRE:
		--Improved Fire Blast
		--Incineration
		--Ignite
		--World in Flames
		--Playing with Fire
		--Fire Power
		--Molten Fury
		--Empowered Fire	
		--Burnout
		[GetSpellInfo(11078)] = { 	[1] = { Effect = -1, Spells = "Fire Blast", ModType = "cooldown", }, },
		[GetSpellInfo(18459)] = { 	[1] = { Effect = 2, Spells = { "Fire Blast", "Scorch", "Arcane Blast", "Cone of Cold" }, ModType = "critPerc", }, },
		[GetSpellInfo(11119)] = { 	[1] = { Effect = 0.08, Spells = "Fire", ModType = "igniteM", }, },
		[GetSpellInfo(11108)] = {		[1] = { Effect = 2, Spells = { "Flamestrike", "Pyroblast", "Blast Wave", "Dragon's Breath", "Living Bomb", "Blizzard", "Arcane Explosion" }, ModType = "critPerc", }, },
		[GetSpellInfo(31638)] = { 	[1] = { Effect = 0.01, Spells = "All", }, },
		[GetSpellInfo(11124)] = {		[1] = { Effect = 0.02, Spells = "Fire", }, },
		[GetSpellInfo(31679)] = {		[1] = { Effect = 0.06, Spells = "All", ModType = "Amount", Value = "Molten Fury", }, },
		[GetSpellInfo(31656)] = { 	[1] = { Effect = 0.05, Spells = { "Fireball", "Frostfire Bolt" }, ModType = "SpellDamage", Multiply = true}, },
		[GetSpellInfo(44449)] = {		[1] = { Effect = 0.05, Spells = "Fire", ModType = "critM" }, },
		
		--FROST:
		--Ice Floes
		--Ice Shards
		--Elemental Precision
		--Piercing Ice		
		--Shatter		
		--Improved Cone of Cold
		--Cold as Ice
		--Arctic Winds		
		--Empowered Frostbolt
		--Chilled to the Bone
		[GetSpellInfo(31670)] = {		[1] = { Effect = { -1.75, -3.5, 5 }, Spell = "Frost Nova", ModType = "cooldown" },
																[2] = { Effect = { -0.7, -1.4, -2 }, Spell = "Cone of Cold", ModType = "cooldown" }, },
		[GetSpellInfo(11207)] = { 	[1] = { Effect = (1/6), Spells = "Frost", ModType = "critM", }, },
		[GetSpellInfo(29438)] = { 	[1] = { Effect = 1, Spells = { "Frost", "Fire" }, ModType = "hitPerc" }, },
		[GetSpellInfo(11151)] = { 	[1] = { Effect = 0.02, Spells = "Frost", }, },		
		[GetSpellInfo(11170)] = { 	[1] = { Effect = {17, 34, 50}, Spells = "All", ModType = "Amount", Value = "Shatter" }, },		
		[GetSpellInfo(11190)] = { 	[1] = { Effect = { 0.15, 0.25, 0.35, }, Spells = "Cone of Cold", }, },
		[GetSpellInfo(55091)] = {		[1] = { Effect = { -3, -6 }, Spell = "Ice Barrier", ModType = "cooldown" }, },
		[GetSpellInfo(31674)] = { 	[1] = { Effect = 0.01, Spells = "Frost", }, },		
		[GetSpellInfo(31682)] = { 	[1] = { Effect = 0.05, Spells = "Frostbolt", ModType = "SpellDamage", Multiply = true},
																[2] = { Effect = 2, Spells = "Frostbolt", ModType = "critPerc" }, },
		[GetSpellInfo(44566)] = { 	[1] = { Effect = 0.01, Spells = { "Frostbolt", "Frostfire Bolt", "Ice Lance" }, }, },		
	}
end