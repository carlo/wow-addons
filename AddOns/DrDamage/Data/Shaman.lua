if select(2, UnitClass("player")) ~= "SHAMAN" then return end
local GetSpellInfo = GetSpellInfo
local tonumber = tonumber
local string_match = string.match
local UnitManaMax = UnitManaMax
local IsEquippedItem = IsEquippedItem
local OffhandHasWeapon = OffhandHasWeapon
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend

--Downranking exceptions: Flame Shock, Frost Shock. Rest is normal.
--No downranking penalty on: Lightning Shield, Searing Totem, Fire Nova Totem, Magma Totem, Healing Stream Totem and Earth Shield

function DrDamage:PlayerData()
	--Mana tide totem
	self.ClassSpecials[GetSpellInfo(16190)] = function()
		local _, _, _, manaCost = GetSpellInfo(16190)
		return 0.24 * UnitManaMax("player") - manaCost, 0.40, 0.8, 1
	end
	--Mana spring totem
	self.ClassSpecials["MST Table"] = { 900, 1350, 1950, 2550, 3000, 3750, 4500, 5100 }
	self.ClassSpecials[GetSpellInfo(5675)] = function(rank, id, pid)
		local bonus = 0
		if DrDamage:GetSetAmount("Cyclone Raiment") >= 2 then
			bonus = 180
		end
		local _, _, _, manaCost = GetSpellInfo(GetSpellInfo(5675),rank)
		
		return (self.ClassSpecials["MST Table"][tonumber(string_match(rank,"%d+"))] + bonus) * (1 + (self.talents[GetSpellInfo(16187)] or 0) * 0.05) - manaCost, 0.40, 0.8, 1
	end	

	--Special calculation
	
	--General
	local wf = GetSpellInfo(32910)
	self.Calculation["Attack"] = function( calculation, _, BuffTalentRanks )
		local name, rank = self:GetWeaponBuff()
		if name == wf then
			local AP = rank and select(rank, 103, 221, 315, 433, 475) --46, 119, 249, 333, 445
			if AP then
				calculation.WindfuryBonus = AP 
				calculation.WindfuryAttacks = 2 * (1 + BuffTalentRanks["Elemental Weapons"] or 0)
			end
		end
		if OffhandHasWeapon() then
			local name, rank = self:GetWeaponBuff(true)
			if name == wf then
				local AP = rank and select(rank, 103, 221, 315, 433, 475) --46, 119, 249, 333, 445
				if AP then
					calculation.WindfuryBonus_O = AP 
					calculation.WindfuryAttacks_O = 2 * (1 + BuffTalentRanks["Elemental Weapons"] or 0)
				end
			end			
		end
	end	
	self.Calculation["Dual Wield Specialization"] = function( calculation, talentValue )
		if OffhandHasWeapon() then
			calculation.hitPerc = calculation.hitPerc + talentValue
		end
	end
	
	--Spell specific
	self.Calculation["Earth Shield"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if BuffTalentRanks["Purification"] and UnitExists("target") and not UnitIsUnit("target","player") and UnitIsFriend("target","player") then
			calculation.dmgM = calculation.dmgM / ( 1 + BuffTalentRanks["Purification"] * 0.02 )
		end
	end
	self.SetBonuses["Attack"] = function( calculation )
		--Totem of the Astral Winds
		if IsEquippedItem( 27815 ) then
			if calculation.WindfuryBonus and calculation.WindfuryAttacks and calculation.WindfuryAttacks >= 2 then
				calculation.WindfuryBonus = calculation.WindfuryBonus + 80
			end
			if calculation.WindfuryBonusO and calculation.WindfuryAttacksO and calculation.WindfuryAttacksO >= 2 then
				calculation.WindfuryBonusO = calculation.WindfuryBonusO + 80
			end
		end
	end
	self.Calculation["Lightning Shield"] = function( calculation )
		--Gladiator's Linked Gauntlets
		if IsEquippedItem( 26000 ) or IsEquippedItem( 32005 ) then
			calculation.dmgM = calculation.dmgM * 1.08
		end
	end
	self.Calculation["Lesser Healing Wave"] = function( calculation )
		--Gladiator's Ringmail Gauntlets
		if IsEquippedItem( 31397 ) or IsEquippedItem( 32030 ) then
			calculation.critPerc = calculation.critPerc + 2
		end
	end
	self.Calculation["Lava Burst"] = function ( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Flame Shock"] then
			calculation.critPerc = 100
		end
	end
	self.Calculation["Chain Heal"] = function ( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Riptide"] then
			calculation.dmgM = calculation.dmgM * 1.25
		end
	end
	--self.Calculation["Lava Lash"] = function ( calculation, ActiveAuras, BuffTalentRanks )  --Need to implement offhand weapon buff detection --DALLYTEMP
	--	if OffhandHasWeapon() then 
	--	end
	--end
	
	--Set bonuses
	self.SetBonuses["Tidefury Raiment"] = { 27510, 27802, 27909, 28231, 28349, }
	self.SetBonuses["The Ten Storms"] = { 16943, 16944, 16945, 16946, 16947, 16948, 16949, 16950 }
	self.SetBonuses["Cyclone Raiment"] = { 29028, 29029, 29030, 29031, 29032 }
	self.SetBonuses["Cyclone Harness"] = { 29038, 29039, 29040, 29042, 29043 }
	self.SetBonuses["Skyshatter Raiment"] = { 31007, 31012, 31016, 31019, 31022, 34438, 34543, 34565 }
	self.SetBonuses["Skyshatter Regalia"] = { 31008, 31014, 31017, 31020, 31023, 34437, 34542, 34566 }
	
	--Effects
	self.SetBonuses["Chain Lightning"] = function( calculation )
		if self:GetSetAmount( "Tidefury Raiment" ) >= 2 then
			calculation.chainFactor = calculation.chainFactor + 0.13
		end
	end
	self.SetBonuses["Chain Heal"] = function( calculation )
		if self:GetSetAmount( "The Ten Storms" ) >= 3 then
			calculation.chainFactor = calculation.chainFactor + 0.05
		end
		if self:GetSetAmount( "Skyshatter Raiment" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end
	self.SetBonuses["Stormstrike"] = function( calculation )
		if self:GetSetAmount( "Cyclone Harness" ) >= 4 then
			calculation.baseBonus = calculation.baseBonus + 30
		end
	end
	self.SetBonuses["Lightning Bolt"] = function( calculation )
		if self:GetSetAmount( "Skyshatter Regalia" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end	
	
	--Relic slot
	self.RelicSlot["Chain Heal"] = { 28523, 87, ModType1 = "Base" } 		--Totem of Healing Rains (Epic)
	self.RelicSlot["Healing Wave"] = { 27544, 88, }					--Totem of Spontaneous Regrowth
	self.RelicSlot["Lesser Healing Wave"] = { 25645, 79, 22396, 80, 23200, 53 }	--Totem of the Plains, Totem of Life, Totem of Sustaining
	self.RelicSlot["Earth Shock"] = { 22395, 30, 27947, 46, 27984, 46, }		--Totem of Rage, Totem of Impact
	self.RelicSlot["Frost Shock"] = { 22395, 30, 27947, 46, 27984, 46, }		--Totem of Rage, Totem of Impact
	self.RelicSlot["Flame Shock"] = { 22395, 30, 27947, 46, 27984, 46, }		--Totem of Rage, Totem of Impact
	self.RelicSlot["Lightning Bolt"] = { 28248, 55, 23199, 33, 32330, 85 }		--Totem of the Void, Totem of the Storm, Totem of Ancestral Guidance
	self.RelicSlot["Chain Lightning"] = { 28248, 55, 23199, 33, 32330, 85 }		--Totem of the Void, Totem of the Storm, Totem of Ancestral Guidance
	
	--AURA
	--Elemental Mastery
	--Wave Trance
	--Tidal Waves
	--Maelstrom Weapon
	--Riptide x 2
	--Tidal Force
	--Healing Way
	--Flame Shock	
	--Stormstrike
	self.PlayerAura[GetSpellInfo(16166)] = { School = { "Nuke", "Shock" }, Value = 100, ModType = "critPerc" }
	self.PlayerAura[GetSpellInfo(39950)] = { ModType = "Update", Spell = GetSpellInfo(331) }
	self.PlayerAura[GetSpellInfo(53390)] = { ModType = "Update", Spell = { GetSpellInfo(331), GetSpellInfo(8004) } }
	self.PlayerAura[GetSpellInfo(53817)] = { ModType = "Update", Spell = "All" }
	self.PlayerAura[GetSpellInfo(61295)] = { ModType = "ActiveAura", ActiveAura = "Riptide" }
	self.TargetAura[GetSpellInfo(61295)] = { ModType = "ActiveAura", ActiveAura = "Riptide" }
	self.TargetAura[GetSpellInfo(55166)] = { ModType = "Special", Spell = { GetSpellInfo(331), GetSpellInfo(8004), GetSpellInfo(1064) }  }
	self.TargetAura[GetSpellInfo(29206)] = { ModType = "Special", Spell = GetSpellInfo(331) }
	self.TargetAura[GetSpellInfo(8050)] = { ModType = "ActiveAura", ActiveAura = "Flame Shock" }	
	self.TargetAura[GetSpellInfo(17364)] = { School = "Nature", Value = 0.2, SelfCast = true }
	
	--Healing Way
	self.Calculation[GetSpellInfo(29206)] = function( calculation, _, _, _, apps )
		apps = apps or 3
		calculation.bDmgM = calculation.bDmgM + apps * 0.06
		calculation.spellDmgM = calculation.spellDmgM + apps * 0.054 - ( apps - 1 ) * 0.003
	end
	
	--Tidal Force
	self.Calculation[GetSpellInfo(55166)] = function ( calculation, _, _, _, apps )
		apps = apps or 3
		calculation.critPerc = calculation.critPerc + apps * 20
	end


	self.spellInfo = { --Processed --DALLYTEMP
		[GetSpellInfo(324)] = {
						["Name"] = "Lightning Shield",
						[0] = { School = "Nature", bonusFactor = 0.805, sHits = 3, NoDPS = true, NoDoom = true, NoDownRank = true, },
						[1] = { 13, 13, spellLevel = 8, },
						[2] = { 29, 29, spellLevel = 16, },
						[3] = { 51, 51, spellLevel = 24, },
						[4] = { 80, 80, spellLevel = 32, },
						[5] = { 114, 114, spellLevel = 40, },
						[6] = { 154, 154, spellLevel = 48, },
						[7] = { 198, 198, spellLevel = 56, },
						[8] = { 232, 232, spellLevel = 63, },
						[9] = { 287, 287, spellLevel = 70, },
						[10] = { 325, 325, spellLevel = 75, },
						[11] = { 380, 380, spellLevel = 80, },
		},	
		[GetSpellInfo(403)] = { --Processed --DALLYTEMP
						["Name"] = "Lightning Bolt",
						[0] = { School = { "Nature", "Nuke" }, canCrit = true, castTime = 2.5, bonusFactor = 0.794, CastMod = 0.1, BaseIncrease = true, LevelIncrease = 5, },
						[1] = { 13, 15, 2, 2, spellLevel = 1, castTime = 1.5, },
						[2] = { 26, 30, 2, 3, spellLevel = 8, castTime = 2, },
						[3] = { 45, 53, 3, 4, spellLevel = 14, castTime = 2.5, },
						[4] = { 83, 95, 5, 5, spellLevel = 20, },
						[5] = { 125, 143, 6, 6, spellLevel = 26, },
						[6] = { 172, 194, 7, 8, spellLevel = 32, },
						[7] = { 227, 255, 8, 9, spellLevel = 38, },
						[8] = { 282, 316, 9, 10, spellLevel = 44, },
						[9] = { 347, 389, 10, 11, spellLevel = 50, },
						[10] = { 419, 467, 12, 12, spellLevel = 56, }, 
						[11] = { 495, 565, 10, 12, spellLevel = 62, }, 
						[12] = { 563, 643, 13, 14, spellLevel = 67, }, --Guess --DALLYTEMP
						[13] = { 595, 679, 0, 0, spellLevel = 73, },
						[14] = { 715, 815, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(421)] = { --Processed --DALLYTEMP
						["Name"] = "Chain Lightning",
						[0] = { School = { "Nature", "Nuke" }, canCrit = true, castTime = 2, bonusFactor = 0.641, Cooldown = 6, chainFactor = 0.7, BaseIncrease = true, LevelIncrease = 7 },
						[1] = { 191, 217, 9, 10, spellLevel = 32, },
						[2] = { 277, 311, 11, 12, spellLevel = 40, },
						[3] = { 378, 424, 13, 14, spellLevel = 48, },
						[4] = { 493, 551, 15, 16, spellLevel = 56, },
						[5] = { 603, 687, 17, 18, spellLevel = 63, },
						[6] = { 734, 838, 0, 0, spellLevel = 70, },
						[7] = { 806, 920, 0, 0, spellLevel = 74, },
						[8] = { 913, 1111, 0, 0, spellLevel = 80, },
						--Check LevelIncrease
		},
		[GetSpellInfo(8042)] = { --Processed --DALLYTEMP
						["Name"] = "Earth Shock",
						[0] = { School = { "Nature", "Shock" }, canCrit = true, Cooldown = 6, sFactor = 0.90, BaseIncrease = true, LevelIncrease = 5 },
						[1] = { 17, 19, 2, 3, spellLevel = 4, },
						[2] = { 32, 34, 3, 4, spellLevel = 8, },
						[3] = { 60, 64, 5, 5, spellLevel = 14, },
						[4] = { 119, 127, 7, 7, spellLevel = 24, },
						[5] = { 225, 239, 10, 10, spellLevel = 36, },
						[6] = { 359, 381, 13, 13, spellLevel = 48, }, 
						[7] = { 517, 545, 15, 16, spellLevel = 60, },
						[8] = { 658, 692, 17, 18, spellLevel = 69, }, --Guess --DALLYTEMP
						[9] = { 723, 761, 0, 0, spellLevel = 74, },
						[10] = { 849, 895, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(8050)] = { --Processed --DALLYTEMP
						["Name"] = "Flame Shock",
						[0] = { School = { "Fire", "Shock" }, canCrit = true, Cooldown = 6, eDuration = 12, sTicks = 3, sFactor = 0.5, BaseIncrease = true, LevelIncrease = 5, Downrank = 1 },
						[1] = { 21, 21, 4, 4, hybridDotDmg = 28, spellLevel = 10, },
						[2] = { 45, 45, 6, 6, hybridDotDmg = 48, spellLevel = 18, },
						[3] = { 86, 86, 8, 9, hybridDotDmg = 96, spellLevel = 28, },
						[4] = { 152, 152, 10, 11, hybridDotDmg = 168, spellLevel = 40, },
						[5] = { 230, 230, 14, 15, hybridDotDmg = 256, spellLevel = 52, },
						[6] = { 309, 309, 24, 25, hybridDotDmg = 344, spellLevel = 60, },
						[7] = { 377, 377, 0, 0, hybridDotDmg = 420, spellLevel = 70, },
						[8] = { 425, 425, 0, 0, hybridDotDmg = 476, spellLevel = 75, },
						[9] = { 500, 500, 0, 0, hybridDotDmg = 556, spellLevel = 80, },
						--NOTE: Downrank +1 -> exception
		},
		[GetSpellInfo(8056)] = { --Processed --DALLYTEMP
						["Name"] = "Frost Shock",
						[0] = { School = { "Frost", "Shock" }, canCrit = true, Cooldown = 6, sFactor = 0.90, BaseIncrease = true, LevelIncrease = 5, Downrank = 1, },
						[1] = { 89, 95, 6, 6, spellLevel = 20, },
						[2] = { 206, 220, 9, 10, spellLevel = 34, },
						[3] = { 333, 353, 12, 13, spellLevel = 46, },
						[4] = { 486, 514, 15, 15, spellLevel = 58, },
						[5] = { 640, 676, 19, 19, spellLevel = 68, }, --Guess --DALLYTEMP
						[6] = { 681, 719, 0, 0, spellLevel = 73, },
						[7] = { 802, 848, 0, 0, spellLevel = 78, },
						--NOTE: Downrank: +1 -> exception
		},		
		[GetSpellInfo(3599)] = { --Processed --DALLYTEMP
						["Name"] = "Searing Totem",
						[0] = { School = { "Fire", "OffensiveTotem" }, sHits = true, eDot = true, canCrit = true, NoDownRank = true, },
						[1] = { 9, 11, spellLevel = 10, eDuration = 30, sHits = 12, },
						[2] = { 13, 17, spellLevel = 20, eDuration = 35, sHits = 14, },
						[3] = { 19, 25, spellLevel = 30, eDuration = 40, sHits = 16, },
						[4] = { 26, 34, spellLevel = 40, eDuration = 45, sHits = 18, },
						[5] = { 33, 45, spellLevel = 50, eDuration = 50, sHits = 20, },
						[6] = { 40, 54, spellLevel = 60, eDuration = 55, sHits = 22, },
						[7] = { 56, 74, spellLevel = 69, eDuration = 60, sHits = 24, },
						[8] = { 68, 92, spellLevel = 71, eDuration = 60, sHits = 24, },
						[9] = { 77, 103, spellLevel = 75, eDuration = 60, sHits = 24, },
						[10] = { 90, 120, spellLevel = 80, eDuration = 60, sHits = 24, },
		},
		[GetSpellInfo(1535)] = { --Processed --DALLYTEMP
						["Name"] = "Fire Nova Totem",
						[0] = { School = { "Fire", "OffensiveTotem" }, canCrit = true, sFactor = 1/2, Cooldown = 15, BaseIncrease = true, NoDownRank = true, LevelIncrease = 9 },
						[1] = { 48, 56, 5, 6, spellLevel = 12, },
						[2] = { 102, 116, 8, 8, spellLevel = 22, },
						[3] = { 184, 208, 11, 11, spellLevel = 32, },
						[4] = { 281, 317, 14, 14, spellLevel = 42, },
						[5] = { 396, 442, 17, 17, spellLevel = 52, },
						[6] = { 518, 578, 19, 20, spellLevel = 61, },
						[7] = { 727, 813, 0, 0, spellLevel = 70, },
						[8] = { 755, 843, 0, 0, spellLevel = 75, },
						[9] = { 893, 997, 0, 0, spellLevel = 80, },
						--Check LevelIncrease
		},
		[GetSpellInfo(8190)] = { --Processed --DALLYTEMP
						["Name"] = "Magma Totem",
						[0] = { School = { "Fire", "OffensiveTotem" }, canCrit = true, eDot = true, eDuration = 20, sHits = 10, sFactor = 1/2, NoDownRank = true, },
						[1] = { 22, 22, spellLevel = 26, },
						[2] = { 37, 37, spellLevel = 36, },
						[3] = { 54, 54, spellLevel = 46, },
						[4] = { 75, 75, spellLevel = 56, },
						[5] = { 100, 100, spellLevel = 67, },
						[6] = { 145, 145, spellLevel = 73, },
						[7] = { 172, 172, spellLevel = 78, },
		},
		[GetSpellInfo(51490)] = { --Added --DALLYTEMP
						["Name"] = "Thunderstorm",
						[0] = { School = { "Nature", "Nuke" }, canCrit = true, Vooldown = 45, sFactor = 1/2, NoDownRank = true, },
						[1] = { 551, 629, spellLevel = 60, },
						[2] = { 1074, 1226, spellLevel = 70, },
						[3] = { 1226, 1400, spellLevel = 75, },
						[4] = { 1450, 1656, spellLevel = 80, },
		},
		[GetSpellInfo(51505)] = { --Added --DALLYTEMP
						["Name"] = "Lava Burst",
						[0] = { School = { "Fire", "Nuke" }, canCrit = true, Cooldown = 8, sFactor = 0.9, NoDownRank = true, },
						[1] = { 1012, 1290, spellLevel = 75, },
						[2] = { 1192, 1518, spellLevel = 80, },
		},
		[GetSpellInfo(8004)] = { --Processed --DALLYTEMP
						["Name"] = "Lesser Healing Wave",
						[0] = { School = { "Nature", "Healing", }, canCrit = true, BaseIncrease = true, LevelIncrease = 5 },
						[1] = { 162, 186, 8, 9, spellLevel = 20, },
						[2] = { 247, 281, 10, 11, spellLevel = 28, },
						[3] = { 337, 381, 12, 13, spellLevel = 36, },
						[4] = { 458, 514, 15, 15, spellLevel = 44, },
						[5] = { 631, 705, 18, 18, spellLevel = 52, },
						[6] = { 832, 928, 21, 21, spellLevel = 60, },
						[7] = { 1039, 1185, 24, 24, spellLevel = 66, }, --Guess --DALLYTEMP
						[8] = { 1382, 1578, 0, 0, spellLevel = 72, },
						[9] = { 1606, 1834, 0, 0, spellLevel = 77, },
		},
		[GetSpellInfo(331)] = { --Processed --DALLYTEMP
						["Name"] = "Healing Wave",
						[0] = { School = { "Nature", "Healing", }, canCrit = true, castTime = 3, BaseIncrease = true, LevelIncrease = 5 },
						[1] = { 34, 44, 2, 3, spellLevel = 1, castTime = 1.5, Downrank = -2 },
						[2] = { 64, 78, 5, 5, spellLevel = 6, castTime = 2.0, },
						[3] = { 129, 155, 7, 8, spellLevel = 12, castTime = 2.5, },
						[4] = { 268, 316, 11, 12, spellLevel = 18, },
						[5] = { 376, 440, 13, 14, spellLevel = 24, },
						[6] = { 536, 622, 16, 17, spellLevel = 32, },
						[7] = { 740, 854, 19, 20, spellLevel = 40, },
						[8] = { 1017, 1167, 23, 24, spellLevel = 48, },
						[9] = { 1367, 1561, 27, 28, spellLevel = 56, },
						[10] = { 1620, 1850, 27, 28, spellLevel = 60, },
						[11] = { 1725, 1969, 31, 32, spellLevel = 63, },
						[12] = { 2134, 2436, 0, 0, spellLevel = 70, },
						[13] = { 2624, 2996, 0, 0, spellLevel = 75, },
						[14] = { 3034, 3466, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(1064)] = { --Processed --DALLYTEMP
						["Name"] = "Chain Heal",
						[0] = { School = { "Nature", "Healing", }, canCrit = true, castTime = 2.5, chainFactor = 0.5, BaseIncrease = true, LevelIncrease = 5 },
						[1] = { 320, 368, 12, 13, spellLevel = 40, },
						[2] = { 405, 465, 14, 14, spellLevel = 46, },
						[3] = { 551, 629, 16, 17, spellLevel = 54, },
						[4] = { 605, 691, 19, 19, spellLevel = 61, },
						[5] = { 826, 942, 21, 21, spellLevel = 68, }, --Guess --DALLYTEMP
						[6] = { 906, 1034, 0, 0, spellLevel = 74, },
						[7] = { 1055, 1205, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(5394)] = { --Processed --DALLYTEMP
						["Name"] = "Healing Stream Totem",
						[0] = { School = { "Nature", "Healing", }, eDot = true, eDuration = 300, sHits = 150, sFactor = 1/3 * 0.99, NoDownRank = true, },
						[1] = { 6, 6, spellLevel = 20, }, 
						[2] = { 8, 8, spellLevel = 30, },
						[3] = { 10, 10, spellLevel = 40, },
						[4] = { 12, 12, spellLevel = 50, },
						[5] = { 14, 14, spellLevel = 60, },
						[6] = { 18, 18, spellLevel = 69, },
						[7] = { 20, 20, spellLevel = 71, },
						[8] = { 23, 23, spellLevel = 76, },
						[9] = { 25, 25, spellLevel = 80, },
		},
		[GetSpellInfo(974)] = { --Processed --DALLYTEMP
						["Name"] = "Earth Shield",
						[0] = { School = { "Nature", "Healing", }, canCrit = true, sHits = 6, bonusFactor = 6/3.5, NoDPS = true, NoDoom = true, NoDebuffs = true, NoDownRank = true, },
						[1] = { 150, 150, spellLevel = 50, },
						[2] = { 205, 205, spellLevel = 60, },
						[3] = { 270, 270, spellLevel = 70, },
						[4] = { 300, 300, spellLevel = 75, },
						[5] = { 337, 337, spellLevel = 80, },
		},
		[GetSpellInfo(61295)] = { --Added --DALLYTEMP
						["Name"] = "Riptide",
						[0] = { School = { "Nature", "Healing", }, canCrit = true, Cooldown = 6, hybridFactor = 0.5, eDuration = 15, sTicks = 3, },
						[1] = { 639, 691, hybridDotDmg = 500, spellLevel = 60, },
						[2] = { 849, 919, hybridDotDmg = 885, spellLevel = 70, },
						[3] = { 1378, 1492, hybridDotDmg = 1435, spellLevel = 75, },
						[4] = { 1604, 1736, hybridDotDmg = 1670, spellLevel = 80, },
		},
		[GetSpellInfo(28880)] = {
						["Name"] = "Gift of the Naaru",
						[0] = { School = { "Holy", "Healing" }, Cooldown = 180, eDot = true, eDuration = 15, sTicks = 3, bonusFactor = 1, BaseIncrease = true, NoLowLevelPenalty = true, NoDownRank = true, NoSchoolTalents = true, },
						["None"] = { 50, 50, 1035, 1035, spellLevel = 1, },
		},
		[GetSpellInfo(17364)] = {
						["Name"] = "Stormstrike",
						[0] = { Melee = true, Cooldown = 10, DualAttack = true, WeaponDamage = 1 },
						["None"] = { 0 },
		},
		[GetSpellInfo(60103)] = {
						["Name"] = "Lava Lash",
						[0] = { Melee = true, Cooldown = 6, OffHandAttack = true, WeaponDamage = 1 },
						[1] = { 0 },
		},
	}
	self.talentInfo = {
		--ELEMENTAL:
		--Concussion
		--Call of Flame
		--Reverberation
		--Elemental Fury
		--Improved Fire Nova Totem
		--Call of Thunder
		--Elemental Precision
		--Lightning Overload
		--Lava Flows
		--Storm, Earth and Fire 
		---Elemental Focus
		[GetSpellInfo(16035)] = { 	[1] = { Effect = 0.01, Spells = { "Nuke", "Shock" }, }, },
		[GetSpellInfo(16038)] = { 	[1] = { Effect = 0.05, Spells = "OffensiveTotem" },
																[2] = { Effect = 0.02, Spells = "Lava Burst" }, },
		[GetSpellInfo(16040)] = { 	[1] = { Effect = -0.2, Spells = "Shock", ModType = "cooldown" }, },
		[GetSpellInfo(16089)] = { 	[1] = { Effect = 0.1, Spells = { "Nuke", "Shock", "OffensiveTotem" }, ModType= "critM", }, },
		[GetSpellInfo(16086)] = {		[1] = { Effect = 0.1, Spells = "Fire Nova Totem", }, },
		[GetSpellInfo(16041)] = { 	[1] = { Effect = 5, Spells = { "Lightning Bolt", "Chain Lightning", "Thunderstorm" }, ModType = "critPerc", }, },
		[GetSpellInfo(30672)] = { 	[1] = { Effect = 1, Spells = { "Lightning Shield", "Nuke", "Shock", "OffensiveTotem", }, ModType = "hitPerc", }, },
		[GetSpellInfo(30675)] = {		[1] = { Effect = 0.02, Spells = { "Lightning Bolt", "Chain Lightning" }, ModType = "finalMod_M" }, },
		[GetSpellInfo(51480)] = { 	[1] = { Effect = { 0.03, 0.06, 0.12 }, Spells = "Lava Burst", ModType = "critM", }, },
		[GetSpellInfo(51480)] = { 	[1] = { Effect = 0.1, Spells = "Flame Shock", ModType = "dotSpellDmgM", Multiply = true }, },
		--[GetSpellInfo(16164)] = { 	[1] = { Effect = 0.8, Spells = { "Nuke", "Shock" }, ModType = "freeCrit" }, },
		
		--RESTORATION:
		--Restorative Totems
		--Tidal Mastery
		--Purification
		--Improved Chain Heal
		--Improved Earth Shield
		--Tidal Waves
		[GetSpellInfo(16187)] = { 	[1] = { Effect = 0.05, Spells = "Healing Stream Totem", }, },
		[GetSpellInfo(16194)] = { 	[1] = { Effect = 1, Spells = { "Healing", "Lightning Bolt", "Chain Lightning", "Thunderstorm" }, ModType = "critPerc", }, },
		[GetSpellInfo(16178)] = { 	[1] = { Effect = 0.02, Spells = "Healing", },
						[2] = { Effect = 1, Spells = "Earth Shield", ModType = "Amount", Value = "Purification" }, },
		[GetSpellInfo(30872)] = { 	[1] = { Effect = 0.10, Spells = "Chain Heal", }, },
		[GetSpellInfo(51560)] = {	[1] = { Effect = 1, Spells = "Earth Shield", ModType = "sHits" },
						[2] = { Effect = 0.05, Spells = "Earth Shield", }, },
		[GetSpellInfo(51562)] = {	[1] = { Effect = 0.04, Spells = "Healing Wave", },
						[2] = { Effect = 0.02, Spells = "Lesser Healing Wave", }, },
		
		--Enhancement
		--Improved Shields
		--Elemental Weapons
		--Weapon Mastery
		--Dual Wield Specialization
		--Improved Stormstrike
		--Static Shock		
		[GetSpellInfo(16261)] = { 	[1] = { Effect = 0.05, Spells = { "Lightning Shield", "Earth Shield" }, }, },
		[GetSpellInfo(16266)] = {	[1] = { Effect = { 0.13, 0.27, 0.4 }, Spells = "Attack", ModType = "Amount", Value = "Elemental Weapons" }, },
		[GetSpellInfo(29082)] = {	[1] = { Effect = { 0.04, 0.07, 0.1 }, Spells = "All", Melee = true }, },
		[GetSpellInfo(30816)] = {	[1] = { Effect = 2, Spells = "Attack", ModType = "Dual Wield Specialization" }, },
		[GetSpellInfo(51521)] = {	[1] = { Effect = -1, Spells = "Stormstrike", ModType = "cooldown" }, },
		[GetSpellInfo(51525)] = { 	[1] = { Effect = 2, Spells = "Lightning Shield", ModType = "sHits" }, },
	}
end