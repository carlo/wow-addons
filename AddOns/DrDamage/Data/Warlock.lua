if select(2, UnitClass("player")) ~= "WARLOCK" then return end
local GT = LibStub:GetLibrary("LibGratuity-3.0")
local GetSpellInfo = GetSpellInfo
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitStat = UnitStat
local UnitBuff = UnitBuff

--Downranking exceptions: Death Coil, Siphon life, Searing Pain, Hellfire
--Untested assumed normal: UA, Conflagrate, Shadowfury
--No downranking: Lifetap, Drain soul, CoA

function DrDamage:PlayerData()

	--Spell specific
	self.Calculation["Drain Life"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Soul Siphon"] and BuffTalentRanks["Soul Siphon"] then
			local SSBonus = 0
			if BuffTalentRanks["Soul Siphon"] == 1 then
				SSBonus = ActiveAuras["Soul Siphon"] * 0.02
				if SSBonus > 0.24 then SSBonus = 0.24 end
			elseif BuffTalentRanks["Soul Siphon"] == 2 then
				SSBonus = ActiveAuras["Soul Siphon"] * 0.04
				if SSBonus > 0.60 then SSBonus = 0.60 end
			end
			calculation.dmgM = calculation.dmgM * ( 1 + SSBonus )	
		end
		if BuffTalentRanks["Death's Embrace (Drain Life)"] then
			if (UnitHealth("player") / UnitHealthMax("player")) <= 0.2 then
				calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Death's Embrace (Drain Life)"] )
			end
		end
	end
	self.Calculation["Incinerate"] = function( calculation, ActiveAuras, _, spell )
		if ActiveAuras["Immolate"] then
			calculation.minDam = calculation.minDam + spell.incinerateMin
			calculation.maxDam = calculation.maxDam + spell.incinerateMax
		end
	end
	self.Calculation["Life Tap"] = function ( calculation, ActiveAuras, BuffTalentRanks, spell )
		calculation.minDam = calculation.minDam + spell.spiritFactor * select(2,UnitStat("player",5))
		calculation.maxDam = calculation.maxDam + spell.spiritFactor * select(2,UnitStat("player",5))
	end
	self.Calculation["Drain Soul"] = function ( calculation, ActiveAuras, BuffTalentRanks, spell )
		if UnitHealth("target") ~= 0 then
			if (UnitHealth("target") / UnitHealthMax("target")) <= 0.25 then
				calculation.minDam = calculation.minDam * (spell.dsBonus or 1)
				calculation.maxDam = calculation.maxDam * (spell.dsBonus or 1)
			end
		end
	end
	
	--General
	self.Calculation["WARLOCK"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if ActiveAuras["Shadow Embrace"] and BuffTalentRanks["Shadow Embrace"] then
			calculation.dmgM_dot = calculation.dmgM_dot * (1 + (BuffTalentRanks["Shadow Embrace"] * ActiveAuras["Shadow Embrace"]))
		end
		if BuffTalentRanks["Death's Embrace (Shadow)"] then
			if (UnitHealth("target") / UnitHealthMax("target")) <= 0.35 then
				calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Death's Embrace (Shadow)"] )
			end
		end		
	end
	
	--Set bonuses
	--Sets
	self.SetBonuses["Oblivion Raiment"] = { 27537, 27778, 27948, 28232, 28415 }
	self.SetBonuses["Voidheart Raiment"] = { 28963, 28964, 28966, 28967, 28968 }
	self.SetBonuses["Corruptor Raiment"] = { 30211, 30212, 30213, 30214, 30215 }
	self.SetBonuses["Plagueheart Raiment"] = { 22504, 22505, 22506, 22507, 22508, 22509, 22510, 22511, 23063 }
	self.SetBonuses["Malefic Raiment"] = { 31050, 31051, 31052, 31053, 31054, 34436, 34541, 34564 }
	
	--Effects
	self.SetBonuses["Seed of Corruption"] = function( calculation )
		if self:GetSetAmount( "Oblivion Raiment" ) >= 4 then
			calculation.finalMod = calculation.finalMod + 180
		end
	end	
	self.SetBonuses["Corruption"] = function( calculation )
		if self:GetSetAmount( "Voidheart Raiment" ) >= 4 then			
			calculation.eDuration = calculation.eDuration + 3
		end
		if self:GetSetAmount( "Plagueheart Raiment" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.12
		end		
	end
	self.SetBonuses["Immolate"] = function( calculation )
		if self:GetSetAmount( "Voidheart Raiment" ) >= 4 then			
			calculation.eDuration = calculation.eDuration + 3
		end
	end
	self.SetBonuses["Shadow Bolt"] = function( calculation )
		if self:GetSetAmount( "Malefic Raiment" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.06
		end		
	end
	self.SetBonuses["Incinerate"] = function( calculation )
		if self:GetSetAmount( "Malefic Raiment" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.06
		end		
	end

	--AURA
	--Demon Armor
	--Fel Armor
	--Touch of Shadow
	--Burning Wish
	--Shadow Embrace
	--Haunt
	--Molten Core
	--Master Demonologist
	self.PlayerAura[GetSpellInfo(706)] = { ModType = "Special" }
	--self.PlayerAura[GetSpellInfo(28176)] = { ModType = "Special" }
	self.PlayerAura[GetSpellInfo(18791)] = { School = "Shadow", ModType = "Special" }
	self.PlayerAura[GetSpellInfo(18789)] = { School = "Fire", Value = 0.1 }
	self.TargetAura[GetSpellInfo(32386)] = { ModType = "ActiveAura", ActiveAura = "Shadow Embrace", Value = 1, Apps = 2}
	self.TargetAura[GetSpellInfo(48181)] = { ModType = "dmgM_dot", Value = 0.2, Spells = "All" }
	self.PlayerAura[GetSpellInfo(47383)] = { School = "Fire", Value = 0.1, SelfCast = true }
	self.PlayerAura[GetSpellInfo(23785)] = { School = {"Fire", "Shadow" }, ModType = "Special" }
	--Immolate
	self.TargetAura[GetSpellInfo(348)] = { Spell = GetSpellInfo(29722), ModType = "ActiveAura", ActiveAura = "Immolate", }
	--Corruption
	--Death Coil
	--Curse of Agony
	--Curse of Doom
	--Curse of Recklessness
	--Curse of Weakness
	--Curse of Tongues
	--Curse of Exhaustion
	--Fear
	--Drain Soul
	--Drain Mana
	--Siphon Life
	--Unstable Affliction
	--Seed of Corruption
	--Shadow Embrace
	--Howl of Terror
	self.TargetAura[GetSpellInfo(172)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(6789)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(980)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(603)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(704)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(702)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(1714)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(18223)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(5782)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(1120)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(5138)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(18265)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(30108)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(27243)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(32385)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	self.TargetAura[GetSpellInfo(5484)] = 	{ ActiveAura = "Soul Siphon", Spell = GetSpellInfo(689), ModType = "ActiveAura" }
	
	local demonarmor = GetSpellInfo(706)
	self.Calculation[GetSpellInfo(706)] = function( calculation, _, BuffTalentRanks )
		calculation.leechBonus = calculation.leechBonus  * (1.2 + 0.02 * (BuffTalentRanks["Demonic Aegis"] or 0))
	end
	
	--[[ Fix manual applying later..
	local felarmor = GetSpellInfo(28176)
	self.Calculation[GetSpellInfo(28176)] = function( calculation, _, BuffTalentRanks )
		if not UnitBuff("player", felarmor) then
			calculation.spellDmg = calculation.spellDmg + 100 * (1 + 0.1 * (BuffTalentRanks["Demonic Aegis"] or 0)) + 0.3 * select(2, UnitStat("player", 5))
		end
	end
	--]]
	
	self.Calculation[GetSpellInfo(18791)] = function( calculation, _, _, index )
		local _, amount
		if index then
			GT:SetUnitBuff( "player", index )
			_, _, amount = GT:Find("(%d+)%%")
		end
		if amount and tonumber(amount) == 10 then
			calculation.dmgM = calculation.dmgM * 1.1
		else
			calculation.dmgM = calculation.dmgM * 1.07
		end
	end
	local imp = GetSpellInfo(3110)
	local succ = GetSpellInfo(7814)
	self.Calculation[GetSpellInfo(23785)] = function ( calculation, _, BuffTalentRanks )
		if calculation.spellSchool == "Fire" and GetSpellInfo(imp) or calculation.spellSchool == "Shadow" and GetSpellInfo(succ) then
			calculation.dmgM = calculation.dmgM * ( 1 + BuffTalentRanks["Master Demonologist"])
		end
	end
		

	self.spellInfo = {
		[GetSpellInfo(172)] = { --Processed --DALLYTEMP
					["Name"] = "Corruption",
					[0] = { School = { "Shadow", "Affliction", }, bonusFactor = 1.2, castTime = 2, eDot = true, eDuration = 18, sTicks = 3, },
					[1] = { 40, 40, spellLevel = 4, eDuration = 12, Downrank = -1, },
					[2] = { 90, 90, spellLevel = 14, eDuration = 15, },
					[3] = { 222, 222, spellLevel = 24, },
					[4] = { 324, 324, spellLevel = 34, },
					[5] = { 486, 486, spellLevel = 44, }, 
					[6] = { 666, 666, spellLevel = 54, },
					[7] = { 822, 822, spellLevel = 60, },
					[8] = { 900, 900, spellLevel = 65, },
					[9] = { 984, 984, spellLevel = 71, },
					[10] = { 1080, 1080, spellLevel = 77, },
		},
		[GetSpellInfo(686)] = { --Processed --DALLYTEMP
					["Name"] = "Shadow Bolt",
					[0] = { School = { "Shadow", "Destruction" }, castTime = 3, canCrit = true, CastMod = 0.1, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 12, 16, 1, 2, spellLevel = 1, castTime = 1.7, Downrank = -1, },
					[2] = { 23, 29, 3, 4, spellLevel = 6, castTime = 2.2, },
					[3] = { 48, 56, 4, 5, spellLevel = 12, castTime = 2.8, },
					[4] = { 86, 98, 6, 6, spellLevel = 20, },
					[5] = { 142, 162, 8, 8, spellLevel = 28, },
					[6] = { 204, 230, 9, 10, spellLevel = 36, },
					[7] = { 281, 315, 11, 12, spellLevel = 44, },
					[8] = { 360, 402, 13, 13, spellLevel = 52, }, 
					[9] = { 455, 507, 15, 15, spellLevel = 60, },
					[10] ={ 482, 538, 15, 16, spellLevel = 60, },
					[11] ={ 541, 603, 17, 18, spellLevel = 69, }, --Guess --DALLYTEMP
					[12] ={ 596, 664, 0, 0, spellLevel = 74, },
					[13] ={ 690, 770, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(1454)] = { --Processed --DALLYTEMP
					["Name"] = "Life Tap",
					[0] = { School = { "Shadow", "Affliction", }, bonusFactor = 0, NoSchoolTalents= true, NoDPS = true, NoTooltip = true, NoAura = true, Unresistable = true, NoDownRank = true, },
					[1] = { 0, 0, spellLevel = 6, spiritFactor = 1.0, },
					[2] = { 6, 6, spellLevel = 16, spiritFactor = 1.5, },
					[3] = { 24, 24, spellLevel = 26, spiritFactor = 2.0, },
					[4] = { 37, 37, spellLevel = 36, spiritFactor = 2.5, },
					[5] = { 42, 42, spellLevel = 46, spiritFactor = 3.0, },
					[6] = { 500, 500, spellLevel = 56, spiritFactor = 3.0, },
					[7] = { 710, 710, spellLevel = 68, spiritFactor = 3.0, },
					[8] = { 1490, 1490, spellLevel = 80, spiritFactor = 3.0, },
		},
		[GetSpellInfo(6229)] = { --Processed --DALLYTEMP
					["Name"] = "Shadow Ward",
					[0] = { School = "Shadow", bonusFactor = 0.30, NoSchoolTalents= true, NoDPS = true, NoTooltip = true, NoAura = true, Unresistable = true, NoDownRank = true },
					[1] = { 290, 290, spellLevel = 32, },
					[2] = { 470, 470, spellLevel = 42, },
					[3] = { 675, 675, spellLevel = 52, },
					[4] = { 875, 875, spellLevel = 60, },
					[5] = { 2750, 2750, spellLevel = 72, },
					[6] = { 3300, 3300, spellLevel = 78, },
		},		
		[GetSpellInfo(18220)] = { --Processed --DALLYTEMP
					["Name"] = "Dark Pact",
					[0] = { School = { "Shadow", "Affliction", }, bonusFactor = 0.96, NoSchoolTalents= true, NoDPS = true, NoTooltip = true, NoAura = true, Unresistable = true, NoDownRank = true, },
					[1] = { 305, 305, spellLevel = 40, },
					[2] = { 440, 440, spellLevel = 50, },
					[3] = { 545, 545, spellLevel = 60, },
					[4] = { 700, 700, spellLevel = 70, },
					[5] = { 1200, 1200, spellLevel = 80, },
		},			
		[GetSpellInfo(980)] = { --Processed --DALLYTEMP
					["Name"] = "Curse of Agony",
					[0] = { School = { "Shadow", "Affliction", }, bonusFactor = 1.20, eDot = true, eDuration = 24, sTicks = 2, NoDownRank = true, },
					[1] = { 84, 84, spellLevel = 8,  },
					[2] = { 180, 180, spellLevel = 18, },
					[3] = { 324, 324, spellLevel = 28, }, 
					[4] = { 504, 504, spellLevel = 38, }, 
					[5] = { 780, 780, spellLevel = 48, }, 
					[6] = { 1044, 1044, spellLevel = 58, },
					[7] = { 1356, 1356, spellLevel = 67, }, 
					[8] = { 1440, 1440, spellLevel = 73, },
					[9] = { 1740, 1740, spellLevel = 79, }, 
		},
		[GetSpellInfo(603)] = { --Processed --DALLYTEMP
					["Name"] = "Curse of Doom",
					[0] = { School = { "Shadow", "Affliction", }, sFactor = 0.5, NoSchoolTalents = true, eDot = true, eDuration = 60, },
					[1] = { 3200, 3200, spellLevel = 60, },
					[2] = { 4200, 4200, spellLevel = 70, },
					[3] = { 7300, 7300, spellLevel = 80, },
		},
		[GetSpellInfo(6789)] = { --Processed --DALLYTEMP
					["Name"] = "Death Coil",
					[0] = { School = { "Shadow", "Affliction", }, sFactor = 0.5, Cooldown = 120, Leech = true, NoDoom = true, BaseIncrease = true, LevelIncrease = 7, Downrank = 1 },
					[1] = { 244, 244, 13, 13, spellLevel = 42, },
					[2] = { 319, 319, 15, 15, spellLevel = 50, }, 
					[3] = { 400, 400, 18, 18, spellLevel = 58, },
					[4] = { 519, 519, 21, 21, spellLevel = 68, }, --Guess --DALLYTEMP
					[5] = { 670, 670, 0, 0, spellLevel = 73, },
					[6] = { 790, 790, 0, 0, spellLevel = 78, },
					--Note: Downrank: +1 -> exception
					--Check LevelIncrease
		},
		[GetSpellInfo(689)] = { --Processed --DALLYTEMP
					["Name"] = "Drain Life",
					[0] = { School = { "Shadow", "Affliction", }, castTime=5, Leech = true, sHits = 5, sFactor = 0.5, },
					[1] = { 10, 10, spellLevel = 14, },
					[2] = { 17, 17, spellLevel = 22, },
					[3] = { 29, 29, spellLevel = 30, },
					[4] = { 41, 41, spellLevel = 38, },
					[5] = { 55, 55, spellLevel = 46, },
					[6] = { 71, 71, spellLevel = 54, },
					[7] = { 87, 87, spellLevel = 62, },
					[8] = { 108, 108, spellLevel = 69, },
					[9] = { 133, 133, spellLevel = 78, },
		},
		[GetSpellInfo(1120)] = { --Processed --DALLYTEMP
					["Name"] = "Drain Soul",
					[0] = { School = { "Shadow", "Affliction", }, castTime=15, sFactor = 0.5, sTicks = 3, NoDownRank = true, },
					[1] = { 55, 55, spellLevel = 10, },
					[2] = { 155, 155, spellLevel = 24, },
					[3] = { 295, 295, spellLevel = 38, },
					[4] = { 455, 455, spellLevel = 52, },
					[5] = { 620, 620, spellLevel = 67, },
					[6] = { 710, 710, spellLevel = 77, dsBonus = 4, },
		},
		[GetSpellInfo(18265)] = { --Processed --DALLYTEMP
					["Name"] = "Siphon Life",
					[0] = { School = { "Shadow", "Affliction", }, sHits = 10, Leech = true, eDot = true, eDuration = 30, sFactor = 0.5, Downrank = 5 },
					[1] = { 15, 15, spellLevel = 30, Downrank = 3 },
					[2] = { 22, 22, spellLevel = 38, },
					[3] = { 33, 33, spellLevel = 48, },
					[4] = { 45, 45, spellLevel = 58, },
					[5] = { 52, 52, spellLevel = 63, },
					[6] = { 63, 63, spellLevel = 70, },
					[7] = { 70, 70, spellLevel = 75, },
					[8] = { 81, 81, spellLevel = 80, },
					--Note: Downranking +3/5, why?
		},
		[GetSpellInfo(5676)] = { --Processed --DALLYTEMP
					["Name"] = "Searing Pain",
					[0] = { School = { "Fire", "Destruction" }, canCrit = true, BaseIncrease = true, LevelIncrease = 7, Downrank = 1 },
					[1] = { 34, 42, 4, 5, spellLevel = 18, },
					[2] = { 59, 71, 6, 6, spellLevel = 26, },
					[3] = { 86, 104, 7, 8, spellLevel = 34, },
					[4] = { 122, 146, 9, 9, spellLevel = 42, },
					[5] = { 158, 188, 10, 10, spellLevel = 50, },
					[6] = { 204, 240, 12, 12, spellLevel = 58, },
					[7] = { 243, 287, 9, 10, spellLevel = 65, },
					[8] = { 270, 320, 0, 0, spellLevel = 70, },
					[9] = { 295, 349, 0, 0, spellLevel = 74, },
					[10] = { 343, 405, 0, 0, spellLevel = 79, },
					--Note: Downranking +1 -> exception
					--Check LevelIncrease
		},
		[GetSpellInfo(6353)] = { --Processed --DALLYTEMP
					["Name"] = "Soul Fire",
					[0] = { School = { "Fire", "Destruction" }, bonusFactor = 1.15, castTime=6, canCrit = true, CastMod = 0.4, BaseIncrease = true, Cooldown = 60,  LevelIncrease = 7 },
					[1] = { 623, 783, 17, 18, spellLevel = 48, },
					[2] = { 703, 881, 18, 19, spellLevel = 56, },
					[3] = { 839, 1051, 14, 14, spellLevel = 64, },
					[4] = { 1003, 1257, 0, 0, spellLevel = 70, },
					[5] = { 1137, 1423, 0, 0, spellLevel = 75, },
					[6] = { 1323, 1657, 0, 0, spellLevel = 80, },
					--Check LevelIncrease
		},
		[GetSpellInfo(17877)] = { --Processed --DALLYTEMP
					["Name"] = "Shadowburn",
					[0] = { School = { "Shadow", "Destruction" }, Cooldown = 15, canCrit = true, BaseIncrease = true,  LevelIncrease = 7 },
					[1] = { 87, 99, 4, 6, spellLevel = 20, },
					[2] = { 115, 131, 8, 9, spellLevel = 24, },
					[3] = { 186, 210, 10, 11, spellLevel = 32, },
					[4] = { 261, 293, 13, 14, spellLevel = 40, },
					[5] = { 350, 392, 15, 16, spellLevel = 48, },
					[6] = { 450, 502, 17, 19, spellLevel = 56, },
					[7] = { 518, 578, 20, 21, spellLevel = 63, },
					[8] = { 597, 665, 0, 0, spellLevel = 70, },
					[9] = { 662, 738, 0, 0, spellLevel = 75, },
					[10] = { 775, 865, 0, 0, spellLevel = 80, },
					--Check LevelIncrease
		},
		[GetSpellInfo(348)] = { --Processed --DALLYTEMP
					["Name"] = "Immolate",
					[0] = { School = { "Fire", "Destruction" }, canCrit = true, castTime=2, CastMod = 0.1, hybridFactor = 0, eDuration = 15, sTicks = 3, BaseIncrease = true,  LevelIncrease = 5 },
					[1] = { 8, 8, 2, 2, hybridDotDmg = 20, spellLevel = 1, Downrank = -1 },
					[2] = {	19, 19, 4, 4, hybridDotDmg = 40, spellLevel = 10, }, 	 
					[3] = { 45, 45, 7, 7, hybridDotDmg = 90, spellLevel = 20, },	 
					[4] = { 90, 90, 10, 10, hybridDotDmg = 165, spellLevel = 30, }, 
					[5] = { 134, 134, 13, 13, hybridDotDmg = 255, spellLevel = 40, },
					[6] = { 192, 192, 16, 16, hybridDotDmg = 365, spellLevel = 50, }, 
					[7] = { 258, 258, 19, 19, hybridDotDmg = 485, spellLevel = 60, },
					[8] = { 279, 279, 19, 20, hybridDotDmg = 510, spellLevel = 60, },
					[9] = { 327, 327, 22, 23, hybridDotDmg = 615, spellLevel = 69, }, --Guess --DALLYTEMP
					[10] = { 370, 370, 0, 0, hybridDotDmg = 695, spellLevel = 75, },
					[11] = { 460, 460, 0, 0, hybridDotDmg = 785, spellLevel = 80, },
		},
		[GetSpellInfo(1949)] = { --Processed --DALLYTEMP
					["Name"] = "Hellfire",
					[0] = { School = "Fire", castTime=15, sHits = 15, sFactor = 1/2, BaseIncrease = true, LevelIncrease = 11, Downrank = 5, },
					[1] = { 83, 83, 4, 4, spellLevel = 30, },
					[2] = { 139, 139, 5, 5, spellLevel = 42, },
					[3] = { 208, 208, 7, 7, spellLevel = 54, },
					[4] = { 306, 306, 10, 10, spellLevel = 68, }, --Guess --DALLYTEMP
					[5] = { 451, 451, 0, 0, spellLevel = 78, },
					--Note: Downrank +5 -> exception
		},
		[GetSpellInfo(5740)] = { --Processed --DALLYTEMP
					["Name"] = "Rain of Fire",
					[0] = { School = "Fire", castTime=8, bonusFactor = 1.1458, sTicks = 2, BaseIncrease = true, LevelIncrease = 11, },
					[1] = { 240, 240, 8, 8, spellLevel = 20, },
					[2] = { 544, 544, 8, 8, spellLevel = 34, },
					[3] = { 880, 880, 12, 12, spellLevel = 46, },
					[4] = { 1284, 1284, 12, 12, spellLevel = 58, },
					[5] = { 1808, 1808, 22, 22, spellLevel = 69, }, --Guess --DALLYTEMP
					[6] = { 2152, 2152, 0, 0, spellLevel = 72, },
					[7] = { 2700, 2700, 0, 0, spellLevel = 79, },
					--Check LevelIncrease
		},
		[GetSpellInfo(30108)] = { --Processed --DALLYTEMP
					["Name"] = "Unstable Affliction",
					[0] = { School = { "Shadow", "Affliction", }, eDot = true, eDuration = 18, sTicks = 3, },
					[1] = { 550, 550, spellLevel = 50, },
					[2] = { 700, 700, spellLevel = 60, },
					[3] = { 875, 875, spellLevel = 70, },
					[4] = { 985, 985, spellLevel = 75, },
					[5] = { 1150, 1150, spellLevel = 80, },
		},
		[GetSpellInfo(17962)] = { --Processed --DALLYTEMP
					["Name"] = "Conflagrate",
					[0] = { School = { "Fire", "Destruction" }, canCrit = true, BaseIncrease = true, LevelIncrease = 5, },
					[1] = { 240, 306, 9, 10, spellLevel = 40, },
					[2] = { 316, 396, 10, 11, spellLevel = 48, },
					[3] = { 383, 479, 12, 12, spellLevel = 54, },
					[4] = { 447, 557, 8, 9, spellLevel = 60, },
					[5] = { 512, 638, 9, 10, spellLevel = 65, },
					[6] = { 579, 721, 0, 0, spellLevel = 70, },
					[7] = { 650, 810, 0, 0, spellLevel = 75, },
					[8] = { 766, 954, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(27243)] = {  --Processed --DALLYTEMP
					["Name"] = "Seed of Corruption",
					[0] = { School = { "Shadow", "Affliction", }, canCrit = true, sFactor = 1/2, eDuration = 18, hybridDotFactor = 2 * 1.25, sTicks = 3, },
					[1] = { 1110, 1290, hybridDotDmg = 1044, spellLevel = 70, },
					[2] = { 1383, 1607, hybridDotDmg = 1296, spellLevel = 75, },
					[3] = { 1633, 1897, hybridDotDmg = 1518, spellLevel = 80, },
		},
		[GetSpellInfo(30283)] = { --Processed --DALLYTEMP
					["Name"] = "Shadowfury",
					[0] = { School = { "Shadow", "Destruction" }, canCrit = true, sFactor = 1/2 * 0.90, Cooldown = 20, BaseIncrease = true,  LevelIncrease = 9, },
					[1] = { 343, 407, 14, 15, spellLevel = 50, },
					[2] = { 459, 547, 17, 18, spellLevel = 60, },
					[3] = { 612, 728, 0, 0, spellLevel = 70, },
					[4] = { 822, 978, 0, 0, spellLevel = 75, },
					[5] = { 968, 1152, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(32231)] = { --Processed --DALLYTEMP
					["Name"] = "Incinerate",
					[0] = { School = { "Fire", "Destruction" }, canCrit = true, castTime = 2.5, BaseIncrease = true, LevelIncrease = 5, },
					[1] = { 403, 467, 13, 13, incinerateMin = 100, incinerateMax = 116, spellLevel = 64, },
					[2] = { 444, 514, 0, 0, incinerateMin = 111, incinerateMax = 128, spellLevel = 70, },
					[3] = { 485, 563, 0, 0, incinerateMin = 121, incinerateMax = 140, spellLevel = 74, },
					[4] = { 582, 676, 0, 0, incinerateMin = 145, incinerateMax = 169, spellLevel = 80, },
		},
		[GetSpellInfo(47897)] = { --Added --DALLYTEMP
					["Name"] = "Shadowflame",
					[0] = { School = { "Shadow", "Destruction" }, canCrit = true, Cooldown = 15 },
					[1] = { 520, 568, spellLevel = 75,  },
					[2] = {	615, 671, spellLevel = 80, },
			["Secondary"] = {
					["Name"] = "Shadowflame",
					[0] = { School = { "Fire", "Destruction" }, castTime=0, eDuration = 8, sTicks = 2, Cooldown = 15 },
					[1] = { 0, 0, hybridDotDmg = 544, spellLevel = 75,  },
					[2] = {	0, 0, hybridDotDmg = 644, spellLevel = 80, },
			},
		},
		[GetSpellInfo(48181)] = { --Added --DALLYTEMP
					["Name"] = "Haunt",
					[0] = { School = {"Shadow", "Affliction" }, canCrit = true, castTime = 1.5, Cooldown = 8 },
					[1] = { 405, 473, spellLevel = 60, },
					[2] = { 487, 569, spellLevel = 70, },
					[3] = { 550, 642, spellLevel = 75, },
					[4] = { 645, 753, spellLevel = 80, },
		},
		[GetSpellInfo(50796)] = { --Added --DALLYTEMP
					["Name"] = "Chaos Bolt",
					[0] = { School = { "Fire", "Destruction" }, castTime = 2.5, canCrit = true, Unresistable = true },
					[1] = { 607, 769, spellLevel = 60, },
					[2] = { 781, 991, spellLevel = 70, },
					[3] = { 882, 1120, spellLevel = 75, },
					[4] = { 1036, 1314, spellLevel = 80, },
		},
	}
	self.talentInfo = {
		--AFFLICTION:
		--Improved Curse of Agony
		--Suppression
		--Improved Corruption
		--Improved Life Tap
		--Soul Siphon
		--Empowered Corruption
		--Shadow Embrace
		--Shadow Mastery
		--Contagion
		--Malediction
		--Death's Embrace
		--Everlasting Affliction
		[GetSpellInfo(18827)] = { 	[1] = { Effect = 0.05, Spells = "Curse of Agony", Add = true, }, },
		[GetSpellInfo(18174)] = { 	[1] = { Effect = 1, Spells = "Affliction", ModType = "hitPerc", }, },
		[GetSpellInfo(17810)] = {		[1] = { Effect = 0.02, Spells = "Corruption", Add = true, },
																[2] = { Effect = 1, Spells = "Seed of Corruption", ModType = "critPerc", }, },
		[GetSpellInfo(18182)] = { 	[1] = { Effect = 0.1, Spells = "Life Tap", }, },
		[GetSpellInfo(17804)] = { 	[1] = { Effect = 1, Spells = "Drain Life", ModType = "Amount", Value = "Soul Siphon" }, },
		[GetSpellInfo(32381)] = { 	[1] = { Effect = 0.12, Spells = "Corruption", ModType = "SpellDamage", Multiply = true }, },
		[GetSpellInfo(32385)] = {		[1] = { Effect = 0.01, Spells = "All", }, },
		[GetSpellInfo(18271)] = { 	[1] = { Effect = 0.03, Spells = "Shadow" }, },			
		[GetSpellInfo(30060)] = { 	[1] = { Effect = 0.01, Spells = { "Curse of Agony", "Corruption", "Seed of Corruption" }, Add = true, }, },
		[GetSpellInfo(32477)] = {		[1] = { Effect = 0.01, Spells = "All" }, },
		[GetSpellInfo(47198)] = {		[1] = { Effect = 0.1, Spells = "Drain Life", ModType = "Amount", Value = "Death's Embrace (Drain Life)", },
																[2] = { Effect = 0.04, Spells = "Shadow", ModType = "Amount", Value = "Death's Embrace (Shadow)", }, },
		[GetSpellInfo(47201)] = {		[1] = { Effect = 0.01, Spells = { "Corruption", "Siphon Life", "Unstable Affliction" }, ModType = "SpellDamage", Multiply = true }, },
		--DEMONOLOGY:
		--Demonic Aegis
		--Master Demonologist
		[GetSpellInfo(30143)] = { 	[1] = { Effect = 1, Spells = "All", ModType = "Amount", Value = "Demonic Aegis" }, },
		[GetSpellInfo(23785)] = {		[1] = { Effect = 0.01, Spells = "All", ModType = "Amount", Value = "Master Demonologist" }, },
		--Destruction:
		--Cataclysm
		--Ruin
		--Improved Searing Pain
		--Improved Immolate
		--Devastation
		--Emberstorm		
		--Shadow and Flame		
		--Fire and Brimstone
		[GetSpellInfo(17778)] = {		[1] = { Effect = 1, Spells = "Destruction", ModType = "hitPerc", }, },
		[GetSpellInfo(17959)] = { 	[1] = { Effect = 0.1, Spells = "Destruction", ModType = "critM", }, },
		[GetSpellInfo(17927)] = { 	[1] = { Effect = { 4, 7, 10, }, Spells = "Searing Pain", ModType = "critPerc", }, },
		[GetSpellInfo(17815)] = { 	[1] = { Effect = 0.1, Spells = "Immolate", ModType = "bNukeDmg" }, },
		[GetSpellInfo(18130)] = { 	[1] = { Effect = 1, Spells = "Destruction", ModType = "critPerc", }, },
		[GetSpellInfo(17954)] = { 	[1] = { Effect = 0.03, Spells = "Fire", Mod = { "Incinerate", 3, 16, "castTime", function(v,c,t) return (v*(1+0.02*c))/(1+0.02*t) end }, }, },		
		[GetSpellInfo(30288)] = { 	[1] = { Effect = 0.04, Spells = { "Shadow Bolt", "Chaos Bolt", "Incinerate" }, ModType = "SpellDamage", Multiply = true }, },
		[GetSpellInfo(47266)] = {		[1] = { Effect = 0.03, Spells = "Immolate", ModType = "SpellDamage", Multiply = true }, },				
	}
end