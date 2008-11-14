if select(2, UnitClass("player")) ~= "PALADIN" then return end
local GetPlayerBuffName = GetPlayerBuffName
local BR
local GetSpellInfo = GetSpellInfo
local IsEquippedItem = IsEquippedItem
local UnitCreatureType = UnitCreatureType
local UnitAttackSpeed = UnitAttackSpeed
local math_floor = math.floor
local string_match = string.match
local tonumber = tonumber
local select = select

--No base increase: Avenger's Shield, Holy Shield, Consecration, Holy Shock

function DrDamage:PlayerData()
	--Special calculation
	self.Calculation["One-Handed Weapon Specialization"] = function( calculation, value )
		if self:GetNormM() == 2.4 then
			if calculation.wDmgM then
				calculation.wDmgM = calculation.wDmgM * (1 + value)
			else
				calculation.dmgM = calculation.dmgM * (1 + value)
			end
		end
	end	
	self.Calculation["Two-Handed Weapon Specialization"] = function( calculation, value )
		if self:GetNormM() == 3.3 then
			if calculation.wDmgM then
				calculation.wDmgM = calculation.wDmgM * (1 + value)
			else
				calculation.dmgM = calculation.dmgM * (1 + value)
			end
		end
	end	
	
	--General
	self.Calculation["PALADIN"] = function( calculation, ActiveAuras, BuffTalentRanks, spell, baseSpell )
		if not baseSpell.Melee then
			if baseSpell.SpellAPBonus then
				calculation.AP = self:GetAP()
				calculation.minDam = calculation.minDam + (calculation.AP * baseSpell.SpellAPBonus)
				calculation.maxDam = calculation.maxDam + (calculation.AP * baseSpell.SpellAPBonus)
			end
		end
		--[[if ActiveAuras["JotC"] then
			if IsEquippedItem( 23203 ) then						--Libram of Fervor
				ActiveAuras["JotC"] = ActiveAuras["JotC"] + 33
			elseif IsEquippedItem( 27983 ) or IsEquippedItem( 27949 ) then		--Libram of Zeal
				ActiveAuras["JotC"] = ActiveAuras["JotC"] + 48					
			end
			
			--Merciless Gladiator's Scaled Gauntlets
			if IsEquippedItem( 27880 ) or IsEquippedItem( 32040 ) then
				ActiveAuras["JotC"] = ActiveAuras["JotC"] + 20
			end
			
			if self:GetSetAmount( "Justicar Battlegear" ) >= 2 then
				ActiveAuras["JotC"] = ActiveAuras["JotC"] * 1.15
			end			

			--if BuffTalentRanks["Improved Seal of the Crusader"] then
			--	calculation.critPerc = calculation.critPerc + BuffTalentRanks["Improved Seal of the Crusader"]
			--end
			
			calculation.spellDmg = calculation.spellDmg + ActiveAuras["JotC"]		
		end ]]--
	end	
	self.Calculation["Crusade"] = function( calculation, talentValue )
		if not calculation.healingSpell then
			local targetType = UnitCreatureType("target")
			
			if BR and targetType and BR:HasReverseTranslation( targetType ) then
				targetType = BR:GetReverseTranslation( targetType )
			end	
			
			if targetType == "Undead"
			or targetType == "Demon"
			or targetType == "Humanoid"
			or targetType == "Elemental" then
				calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
			end
		end
	end
	
	--Spell specific
	self.Calculation["Improved Holy Shield"] = function( calculation, talentValue )
		calculation.sHits = calculation.sHits + talentValue * 2
		calculation.spellDmgM = calculation.spellDmgM + talentValue * 0.1
		calculation.dmgM = calculation.dmgM * ( 1 + talentValue * 0.1 )
	end	
	self.Calculation["Holy Light"] = function( calculation, ActiveAuras )
		if ActiveAuras["BoL"] and IsEquippedItem( 28592 ) then --Libram of Souls Redeemed
			calculation.finalMod = calculation.finalMod + 120
		end
	end
	self.Calculation["Flash of Light"] = function( calculation, ActiveAuras )
		if ActiveAuras["BoL"] and IsEquippedItem( 28592 ) then --Libram of Souls Redeemed
			calculation.finalMod = calculation.finalMod + 60
		end
		--Gladiator's Flash of Light Bonus
		if self:GetSetAmount( "Gladiator's Gloves" ) >= 1 then
			calculation.critPerc = calculation.critPerc + 2
		end
	end
	self.Calculation["Crusader Strike"] = function( calculation )
		--Vengeful Gladiator's Scaled Gauntlets
		if IsEquippedItem( 33750 ) then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	--[[
	self.Calculation["Consecration"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + (calculation.AP * 0.32)
		calculation.maxDam = calculation.maxDam + (calculation.AP * 0.32)
	end
	self.Calculation["Exorcism"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + (calculation.AP * 0.15)
		calculation.maxDam = calculation.maxDam + (calculation.AP * 0.15)
	end
	self.Calculation["Holy Wrath"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + (calculation.AP * 0.07)
		calculation.maxDam = calculation.maxDam + (calculation.AP * 0.07)
	end
	self.Calculation["Hammer of Wrath"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + (calculation.AP * 0.15)
		calculation.maxDam = calculation.maxDam + (calculation.AP * 0.15)
	end	
	self.Calculation["Avenger's Shield"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + (calculation.AP * 0.07)
		calculation.maxDam = calculation.maxDam + (calculation.AP * 0.07)
	end]]--
		
	--Relic slot items
	self.RelicSlot["Consecration"] = { 27917, 47 }				--Libram of the Eternal Rest
	self.RelicSlot["Crusader Strike"] = { 31033, 36, }			--Libram of Righteous Power
	self.RelicSlot["Flash of Light"] = { 23006, 83, 25644, 79, 23201, 53, }	--Libram of Light, Blessed Book of Nagrand, Libram of Divinity	
	self.RelicSlot["Holy Light"] = { 28296, 87, }				--Libram of the Lightbringer
	self.RelicSlot["Judgement of Righteousness"] = { 33504, 94 }		--Libram of Divine Purpose
	self.RelicSlot["Exorcism"] = { 28065, 120 }				--Libram of Wracking
	self.RelicSlot["Holy Wrath"] = { 28065, 120 }				--Libram of Wracking
	
	--Set bonuses
	
	--Sets
	--Flash of Light
	self.SetBonuses["Gladiator's Gloves"] = { 27703, 31614, 31993, 32021, 33696, 33723 }
	self.SetBonuses["Gladiator's Redemption"] = { 31613, 31614, 31616, 31618, 31619, 32020, 32021, 32022, 32023, 32024, 33722, 33723, 33724, 33725, 33726 }
	self.SetBonuses["Justicar Armor"] = { 29066, 29067, 29068, 29069, 29070 }
	self.SetBonuses["Justicar Battlegear"] = { 29071, 29072, 29073, 29074, 29075 }
	self.SetBonuses["Lightbringer Armor"] = { 30985, 30987, 30991, 30995, 30998, 34433, 34488, 34560 }
	self.SetBonuses["Lightbringer Battlegear"] = { 30982, 30989, 30990, 30993, 30997, 34431, 34485, 34561 }
	self.SetBonuses["Lightbringer Raiment"] = { 30983, 30988, 30992, 30994, 30996, 34432, 34487, 34559 }
	
	--Effects
	self.SetBonuses["Seal of Blood"] = function( calculation )
		if self:GetSetAmount( "Justicar Armor" ) >= 2 then
			calculation.dmgM = calculation.dmgM * 1.1
		end	
	end
	self.SetBonuses["Seal of Vengeance"] = self.SetBonuses["Seal of Blood"]
	self.SetBonuses["Holy Shield"] = function( calculation )
		if self:GetSetAmount( "Justicar Armor" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.15
		end
	end
	self.SetBonuses["Holy Light"] = function( calculation )
		if self:GetSetAmount( "Lightbringer Raiment" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end		
	end
	self.SetBonuses["Flash of Light"] = function( calculation )
		if self:GetSetAmount( "Lightbringer Raiment" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end	
	self.SetBonuses["Judgement of Command"] = function( calculation )
		if self:GetSetAmount( "Justicar Battlegear" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	self.SetBonuses["Consecration"] = function( calculation )
		if self:GetSetAmount( "Lightbringer Armor" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end	
	end
	self.SetBonuses["Hammer of Wrath"] = function( calculation )
		if self:GetSetAmount( "Lightbringer Battlegear" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end	
	end
	self.SetBonuses["Holy Wrath"] = function( calculation )
		if calculation.healingSpell and self:GetSetAmount( "Gladiator's Redemption" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.3
		end
	end
	
	--Seals and judgements
	
	self.Calculation["Seal of Righteousness"] = function ( calculation )
		calculation.spellDmg = calculation.spellDmg + GetSpellBonusDamage(2)
	end
	self.DmgCalculation["Seal of Righteousness"] = function( calculation, _, _, spell )
		local spd = self:GetWeaponSpeed()
		local cspd = UnitAttackSpeed("player")
		--local min, max = self:WeaponDamage(calculation, true)
		--local _, data = self:CasterCalc( "Judgement of Righteousness", spell.Rank, true )
		
		calculation.minDam = spd * ( 0.022 * ( calculation.AP ) + 0.044 * ( calculation.spellDmg ) )
		calculation.maxDam = calculation.minDam --Min and max damage is the same
		calculation.Hits = floor(120/cspd) --Average damage per hit based on 2 minute duration
	end
	--[[self.Calculation["Judgement of Righteousness"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + ( calculation.AP * 0.25 )
		calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.25 )
	end
	self.Calculation["Judgement of Light(s)"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + ( calculation.AP * 0.2 )
		calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.2 )
	end
	self.Calculation["Judgement of Wisdom(s)"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + ( calculation.AP * 0.2 )
		calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.2 )
	end
	self.Calculation["Judgement of Justice(s)"] = function ( calculation )
		calculation.AP = self:GetAP()
		
		calculation.minDam = calculation.minDam + ( calculation.AP * 0.2 )
		calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.2 )
	end]]--
	--self.DmgCalculation["Seal of Command"] = function( calculation, _, _, spell )
		--local _, data = self:CasterCalc( "Judgement of Command", spell.Rank, true )
		--local bonus = 0.29 * GetSpellBonusDamage(2)
		--calculation.minDam = bonus + 0.29 * calculation.spellDmg
		--calculation.maxDam = bonus + 0.29 * calculation.spellDmg
		--calculation.spellDmg = bonus
		--calculation.dmgM = data.DmgM
	--end
	self.Calculation["Judgement of Command"] = function ( calculation )
		calculation.AP = self:GetAP()
		local cspd = UnitAttackSpeed("player")
		local mMin, mMax = DrDamage:WeaponDamage( calculation, false )
		
		calculation.minDam = calculation.minDam + ( mMin * 0.3)-- + ( calculation.AP * 0.2 ) --DALLYTEMP
		calculation.maxDam = calculation.maxDam + ( mMax * 0.3)-- + ( calculation.AP * 0.2 )
	end
	self.Calculation["Judgement of Blood"] = function ( calculation )
		calculation.AP = self:GetAP()
		local cspd = UnitAttackSpeed("player")
		local mMin, mMax = DrDamage:WeaponDamage( calculation, cspd )
		
		calculation.minDam = calculation.minDam + ( mMin * 0.45)-- + ( calculation.AP * 0.2 )
		calculation.maxDam = calculation.maxDam + ( mMax * 0.45)-- + ( calculation.AP * 0.2 )
		calculation.Hits = floor(120/cspd)
	end
	self.Calculation["Judgement of the Martyr"] = function ( calculation )
		calculation.AP = self:GetAP()
		local cspd = UnitAttackSpeed("player")
		local mMin, mMax = DrDamage:WeaponDamage( calculation, cspd )
		
		calculation.minDam = calculation.minDam + ( mMin * 0.45)-- + ( calculation.AP * 0.2 )
		calculation.maxDam = calculation.maxDam + ( mMax * 0.45)-- + ( calculation.AP * 0.2 )
		calculation.Hits = floor(120/cspd)
	end
	--[[self.Calculation["Seal of Vengeance"] = function ( calculation, _, _, spell )
		calculation.AP = self:GetAP()
				
		calculation.minDam = spell.extraDotDmg + ( calculation.AP * 0.192 )
		calculation.maxDam = spell.extraDotDmg + ( calculation.AP * 0.192 )
	end]]--	
	self.Calculation["Judgement of Vengeance"] = function( calculation, ActiveAuras )
		calculation.AP = self:GetAP()
		
		--calculation.minDam = calculation.minDam + ( calculation.AP * 0.175 )
		--calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.175 )
		if ActiveAuras["Holy Vengeance"] then
			calculation.spellDmgM = calculation.spellDmgM * ActiveAuras["Holy Vengeance"]
			calculation.minDam = calculation.minDam * ActiveAuras["Holy Vengeance"]
			calculation.maxDam = calculation.maxDam * ActiveAuras["Holy Vengeance"]
		end
	end
	--[[self.Calculation["Seal of Corruption"] = function ( calculation, _, _, spell )
		calculation.AP = self:GetAP()
		
		calculation.minDam = spell.extraDotDmg + ( calculation.AP * 0.192 )
		calculation.maxDam = spell.extraDotDmg + ( calculation.AP * 0.192 )
	end]]--
	self.Calculation["Judgement of Corruption"] = function( calculation, ActiveAuras )
		calculation.AP = self:GetAP()
		
		--calculation.minDam = calculation.minDam + ( calculation.AP * 0.175 )
		--calculation.maxDam = calculation.maxDam + ( calculation.AP * 0.175 )
		if ActiveAuras["Blood Corruption"] then
			calculation.spellDmgM = calculation.spellDmgM * ActiveAuras["Blood Corruption"]
			calculation.minDam = calculation.minDam * ActiveAuras["Blood Corruption"]
			calculation.maxDam = calculation.maxDam * ActiveAuras["Blood Corruption"]
		end
	end	
	
	--AURA
	--Seal of Righteousness
	--Seal of Command
	--Seal of Blood
	--Seal of Vengeance
	--Light's Grace

	--Divine Favor
	
	--Holy Vengeance

	self.PlayerAura[GetSpellInfo(21084)] = { ModType = "Update" }
	self.PlayerAura[GetSpellInfo(20375)] = { ModType = "Update" }
	self.PlayerAura[GetSpellInfo(31892)] = { ModType = "Update" }
	self.PlayerAura[GetSpellInfo(31801)] = { ModType = "Update" }
	self.PlayerAura[GetSpellInfo(31834)] = { ModType = "Update", Spell = GetSpellInfo(635) }

	self.PlayerAura[GetSpellInfo(20216)] = { Spell = { GetSpellInfo(19750), GetSpellInfo(635), GetSpellInfo(20473), }, ModType = "critPerc", Value = 100, }
	
	self.TargetAura[GetSpellInfo(31803)] = { ModType = "ActiveAura", ActiveAura = "Holy Vengeance", Value = 0.1, Apps = 5, }
	self.TargetAura[GetSpellInfo(53742)] = { ModType = "ActiveAura", ActiveAura = "Blood Corruption", Value = 0.1, Apps = 5, }
	
	self.spellInfo = {
		[GetSpellInfo(31935)] = { 
					["Name"] = "Avenger's Shield", --Processed* --DALLYTEMP
					[0] = { School = { "Holy", "Physical" }, SpellAPBonus = 0.07, canCrit = true, bonusFactor = 0.07, sFactor = 1/2, chainFactor = 1, Cooldown = 30, },
					[1] = { 338, 412, spellLevel = 50, },
					[2] = { 462, 564, spellLevel = 60, }, 
					[3] = { 612, 748, spellLevel = 70, }, 
					[4] = { 702, 858, spellLevel = 75, }, 
					[5] = { 846, 1034, spellLevel = 80, }, 
		},
		[GetSpellInfo(2812)] = { 
					["Name"] = "Holy Wrath",	--Processed* --DALLYTEMP
					[0] = { School = "Holy", SpellAPBonus = 0.07, canCrit = true, bonusFactor = 0.07, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 399, 471, 6, 7, spellLevel = 50, },
					[2] = { 551, 649, 7, 8, spellLevel = 60, },
					[3] = { 777, 913, 2, 3, spellLevel = 69, },
					[4] = { 857, 1007, 0, 0, spellLevel = 72, },
					[5] = { 1050, 1234, 0, 0, spellLevel = 78, },
		},
		[GetSpellInfo(20925)] = { 
					["Name"] = "Holy Shield",	--updated by Zironic
					[0] = { School = "Holy", bonusFactor = 0.20, NoDPS = true, NoDoom = true, sHits = 4, },
					[1] = { 61, 61, spellLevel = 40, },
					[2] = { 89, 89, spellLevel = 50, },
					[3] = { 121, 121, spellLevel = 60, },
					[4] = { 160, 1160, spellLevel = 70, },
					[5] = { 181, 181, spellLevel = 75, },
					[6] = { 211, 211, spellLevel = 80, },
		},
		[GetSpellInfo(635)] = { 
					["Name"] = "Holy Light",	--Processed --DALLYTEMP
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 2.5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 50, 60, 3, 4, spellLevel = 1, },
					[2] = { 96, 116, 5, 6, spellLevel = 6, },
					[3] = { 203, 239, 8, 9, spellLevel = 14, },
					[4] = { 397, 455, 12, 12, spellLevel = 22, },
					[5] = { 628, 708, 15, 16, spellLevel = 30, },
					[6] = { 894, 998, 19, 19, spellLevel = 38, },
					[7] = { 1209, 1349, 23, 23, spellLevel = 46, },
					[8] = { 1595, 1777, 26, 26, spellLevel = 54, },
					[9] = { 2034, 2266, 29, 29, spellLevel = 60, },
					[10] = { 2232, 2486, 32, 32, spellLevel = 62, },
					[11] = { 2818, 3138, 0, 0, spellLevel = 70, },
					[12] = { 4199, 4677, 0, 0, spellLevel = 75, },
					[13] = { 4888, 5444, 0, 0, spellLevel = 80, },
		},	
		[GetSpellInfo(24275)] = {
					["Name"] = "Hammer of Wrath",	--Processed* --DALLYTEMP
					[0] = { School = { "Holy", "Physical" }, canCrit = true, SpellAPBonus = 0.15, bonusFactor = 0.15, Cooldown = 6, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 351, 387, 12, 12, spellLevel = 44, },
					[2] = { 459, 507, 13, 14, spellLevel = 52, },
					[3] = { 570, 628, 15, 16, spellLevel = 60, },
					[4] = { 733, 809, 7, 7, spellLevel = 68, },
					[5] = { 878, 970, 0, 0, spellLevel = 74, },
					[6] = { 1139, 1257, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(879)] = {
					["Name"] = "Exorcism",	--Processed* --DALLYTEMP
					[0] = { School = "Holy", canCrit = true, SpellAPBonus = 0.15, bonusFactor = 0.15, Cooldown = 15, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 96, 110, 6, 6, spellLevel = 20, },
					[2] = { 173, 195, 8, 8, spellLevel = 28, },
					[3] = { 250, 280, 10, 10, spellLevel = 36, },
					[4] = { 350, 394, 12, 12, spellLevel = 44, },
					[5] = { 452, 506, 14, 14, spellLevel = 52, },
					[6] = { 564, 628, 16, 16, spellLevel = 60, },
					[7] = { 687, 765, 7, 7, spellLevel = 68, },
					[8] = { 787, 877, 0, 0, spellLevel = 73, },
					[9] = { 1028, 1146, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(26573)] = {
					["Name"] = "Consecration",	--Processed* --DALLYTEMP
					[0] = { School = "Holy", castTime = 8, SpellAPBonus = 0.32, bonusFactor = 0.32, sTicks = 1, },
					[1] = { 72, 72, spellLevel = 20, },
					[2] = { 136, 136, spellLevel = 30, },
					[3] = { 224, 224, spellLevel = 40, },
					[4] = { 336, 336, spellLevel = 50, },
					[5] = { 448, 448, spellLevel = 60, },
					[6] = { 576, 576, spellLevel = 70, },
					[7] = { 696, 696, spellLevel = 75, },
					[8] = { 904, 904, spellLevel = 80, },
		},
		[GetSpellInfo(19750)] = { 
					["Name"] = "Flash of Light",	--Processed --DALLYTEMP
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 1.5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 81, 93, 5, 5, spellLevel = 20, },
					[2] = { 124, 144, 6, 7, spellLevel = 26, },
					[3] = { 189, 211, 8, 9, spellLevel = 34, },
					[4] = { 256, 288, 9, 10, spellLevel = 42, },
					[5] = { 346, 390, 11, 11, spellLevel = 50, },
					[6] = { 445, 499, 13, 13, spellLevel = 58, },
					[7] = { 588, 658, 10, 11, spellLevel = 66, },
					[8] = { 682, 764, 0, 0, spellLevel = 74, },
					[9] = { 785, 879, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(20473)] = { 
					["Name"] = "Holy Shock",	--Processed --DALLYTEMP
					[0] = { School = { "Holy", "Healing" }, canCrit = true, Cooldown = 15, },
					[1] = { 481, 519, spellLevel = 40, },
					[2] = { 644, 696, spellLevel = 48, },
					[3] = { 845, 915, spellLevel = 56, },
					[4] = { 1061, 1149, spellLevel = 64, },
					[5] = { 1258, 1362, spellLevel = 70, },
					[6] = { 2065, 2235, spellLevel = 75, },
					[7] = { 2401, 2599, spellLevel = 80, },
					
			["Secondary"] = { 
					["Name"] = "Holy Shock",	--Processed --DALLYTEMP
					[0] = { School = "Holy", canCrit = true, Cooldown = 15, },
					[1] = { 314, 340, spellLevel = 40, },
					[2] = { 431, 465, spellLevel = 48, },
					[3] = { 562, 608, spellLevel = 56, },
					[4] = { 614, 664, spellLevel = 64, },
					[5] = { 904, 978, spellLevel = 70, },
					[6] = { 1043, 1129, spellLevel = 75, },
					[7] = { 1296, 1402, spellLevel = 80, },
			},
		},
		[GetSpellInfo(35395)] = { --Processed --DALLYTEMP
					["Name"] = "Crusader Strike",
					[0] = { School = "Physical", Melee = true, WeaponDamage = 1.1, canCrit = true, Cooldown = 6, },
					["None"] = { 0, 0, },
		},
		[GetSpellInfo(53385)] = { --Added --DALLYTEMP
					["Name"] = "Divine Storm",
					[0] = { School = "Physical", Melee = true, WeaponDamage = 4, canCrit = true, Cooldown = 10 },
					["None"] = { 0, 0 },
		},	
		[GetSpellInfo(21084)] = { --Processed --DALLYTEMP
					["Name"] = "Seal of Righteousness", --Processed --DALLYTEMP
					[0] = { School = "Holy", Melee = true, bonusFactor = 0.4, SpellDmgBonus = true, NoCrits = true, WeaponDPS = true, NoWeapon = true },
					["None"] = { 0 },
		},
		[GetSpellInfo(20375)] = { --Processed --DALLYTEMP
					["Name"] = "Seal of Command",
					[0] = { School = "Physical", Melee = true, SpellDmgBonus = true, WeaponDamage = 0.45, Hits = 120/14, eDuration = 120, PPM = 7, NoNormalization = true, NoWeapon = true },
					["None"] = { 0 },
		},
		[GetSpellInfo(31801)] = { --Processed* --DALLYTEMP
					["Name"] = "Seal of Vengeance",
					[0] = { School = "Holy", castTime = 120, SpellAPBonus = 0.15, bonusFactor = 0.088, Stacks = 5, StacksDuration = 15, NoDoom = true, NoDownRank = true },
					["None"] = { 0, 0, extraDotDmg = 0, },
		},
		[GetSpellInfo(31892)] = { --Processed --DALLYTEMP
					["Name"] = "Seal of Blood",
					[0] = { School = "Physical", Melee = true, SpellDmgBonus = true, WeaponDamage = 0.22, eDuration = 120, NoNormalization = true, NoWeapon = true },
					["None"] = { 0 },
		},
		[GetSpellInfo(53720)] = { --Processed --DALLYTEMP
					["Name"] = "Seal of the Martyr",
					[0] = { School = "Physical", Melee = true, SpellDmgBonus = true, WeaponDamage = 0.22, eDuration = 120, NoNormalization = true, NoWeapon = true },
					["None"] = { 0 },
		},
		[GetSpellInfo(53736)] = { --Processed* --DALLYTEMP
					["Name"] = "Seal of Corruption",
					[0] = { School = "Holy", castTime = 120, SpellAPBonus = 0.15, bonusFactor = 0.088, Stacks = 5, StacksDuration = 15, NoDoom = true, NoDownRank = true },
					["None"] = { 0, 0, extraDotDmg = 0, },
		},
		["Judgements"] = { [GetSpellInfo(21084)] = "Judgement of Righteousness", [GetSpellInfo(20375)] = "Judgement of Command", [GetSpellInfo(31801)] = "Judgement of Vengeance", [GetSpellInfo(53736)] = "Judgement of Corruption", [GetSpellInfo(31892)] = "Judgement of Blood", [GetSpellInfo(53720)] = "Judgement of the Martyr", [GetSpellInfo(20165)] = "Judgement of Light(s)", [GetSpellInfo(20166)] = "Judgement of Wisdom(s)", [GetSpellInfo(20164)] = "Judgement of Justice(s)" },
		[GetSpellInfo(20271)] = { --Processed --DALLYTEMP
					["Name"] = "Judgement of Light",
					[0] = function()
						for k, v in pairs(DrDamage.spellInfo["Judgements"]) do
							local active, rank = UnitBuff("player", k)
							if active then
								return DrDamage.spellInfo[v][0], DrDamage.spellInfo[v][tonumber(string_match(rank,"%d+")) or "None"], v
							end
						end
					end
		},
		[GetSpellInfo(53408)] = { --Added --DALLYTEMP
					["Name"] = "Judgement of Wisdom",
					[0] = function()
						for k, v in pairs(DrDamage.spellInfo["Judgements"]) do
							local active, rank = UnitBuff("player", k)
							if active then
								return DrDamage.spellInfo[v][0], DrDamage.spellInfo[v][tonumber(string_match(rank,"%d+")) or "None"], v
							end
						end
					end
		},
		[GetSpellInfo(53407)] = { --Added --DALLYTEMP
					["Name"] = "Judgement of Justice",
					[0] = function()
						for k, v in pairs(DrDamage.spellInfo["Judgements"]) do
							local active, rank = UnitBuff("player", k)
							if active then
								return DrDamage.spellInfo[v][0], DrDamage.spellInfo[v][tonumber(string_match(rank,"%d+")) or "None"], v
							end
						end
					end
		},
		["Judgement of Righteousness"] = { --Processed* --DALLYTEMP
					["Name"] = "Judgement of Righteousness",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.25, bonusFactor = 0.4, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 1, 1 },
		},
		["Judgement of Command"] = { --Processed* --DALLYTEMP
					["Name"] = "Judgement of Command",
					[0] = { School = { "Holy", "Judgement", "Physical" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 0, 0 },
		},
		["Judgement of Vengeance"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Vengeance",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.14, bonusFactor = 0.22, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					[1] = { 1, 1 },
		},
		["Judgement of Corruption"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Corruption",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.14, bonusFactor = 0.22, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					[1] = { 1, 1 },
		},
		["Judgement of Blood"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Blood",
					[0] = { School = { "Holy", "Judgement", "Physical" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 0, 0 },
		},
		["Judgement of the Martyr"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of the Martyr",
					[0] = { School = { "Holy", "Judgement", "Physical" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 0, 0 },
		},
		["Judgement of Light(s)"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Light(s)",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 1, 1 },
		},
		["Judgement of Wisdom(s)"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Wisdom(s)",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 1, 1 },
		},
		["Judgement of Justice(s)"] = { --Added* --DALLYTEMP
					["Name"] = "Judgement of Justice(s)",
					[0] = { School = { "Holy", "Judgement" }, SpellAPBonus = 0.16, bonusFactor = 0.25, Cooldown = 10, canCrit = true, NoDoom = true, NoDownRank = true, },
					["None"] = { 1, 1 },
		},
		[GetSpellInfo(28880)] = {
					["Name"] = "Gift of the Naaru",
					[0] = { School = { "Holy", "Healing" }, Cooldown = 180, eDot = true, eDuration = 15, sTicks = 3, bonusFactor = 1, BaseIncrease = true, NoLowLevelPenalty = true, NoDownRank = true, NoSchoolTalents = true, },
					["None"] = { 50, 50, 1035, 1035, spellLevel = 1, },
		},
	}
	self.talentInfo = { 
		--HOLY:
		--Seals of the Pure
		--Healing Light
		--Sanctified Light
		--Purifying Power
		[GetSpellInfo(20332)] = { 	[1] = { Effect = 0.03, Spells = { "Seal of Righteousness", "Judgement of Righteousness",  "Seal of Vengeance", "Judgement of Vengeance", "Seal of Corruption", "Judgement of Corruption"}, }, },
		[GetSpellInfo(20237)] = { 	[1] = { Effect = 0.04, Spells = { "Holy Light", "Flash of Light", }, }, },
		[GetSpellInfo(20359)] = { 	[1] = { Effect = 2, Spells = {"Holy Light", "Holy Shock"}, ModType = "critPerc" }, },
		[GetSpellInfo(31825)] = {		[1] = { Effect = 10, Spells = { "Holy Wrath", "Exorcism", }, ModType = "critPerc" }, },

		--PROTECTION:
		--One-Handed Weapon Specialization
		--Touched by the Light
		--Shield of the Templar
		[GetSpellInfo(20196)] = { 	[1] = { Effect = 0.02, Melee = true, Spells = "Physical", ModType = "One-Handed Weapon Specialization" }, },		
		[GetSpellInfo(53590)] = {		[1] = { Effect = 0.05, Spells = "Healing", ModType = "critM" }, },
		[GetSpellInfo(53709)] = {		[1] = { Effect = 0.1, Spells = { "Holy Shield", "Avenger's Shield", "Shield of Righteousness" }, }, },

		--RETRIBUTION:
		--Improved Judgements
		--Crusade
		--Two-Handed Weapon Specialization
		--The Art of War
		--Fanaticism
		--Sactified Wrath
		---Righteous Vengeance
		[GetSpellInfo(25956)] = { 	[1] = { Effect = -1, Spells = "Judgement", ModType = "cooldown" }, },
		[GetSpellInfo(31866)] = { 	[1] = { Effect = 0.01, Spells = "All", ModType = "Crusade" }, },
		[GetSpellInfo(20111)] = { 	[1] = { Effect = 0.02, Melee = true, Spells = "Physical", ModType = "Two-Handed Weapon Specialization" }, },
		[GetSpellInfo(53486)] = {		[1] = { Effect = 0.05, Spells = { "Judgement", "Crusader Strike", "Divine Storm" }, }, },
		[GetSpellInfo(31879)] = { 	[1] = { Effect = 5, Spells = "Judgement", ModType = "critPerc" }, },
		[GetSpellInfo(53375)] = {		[1] = { Effect = 25, Spells = "Hammer of Wrath", ModType = "critPerc" }, },
		--[GetSpellInfo(53380)] = {		[1] = { Effect = 0.05, Spells = { "Judgement", "Divine Storm" }, ModType = "critM" }, },
		---Heart of the Crusader
		--[GetSpellInfo(20335)] = { 	[1] = { Effect = 1, Spells = "All", ModType = "Amount", Value = "Heart of the Crusader" }, },
		
		--Melee module
		---Precision
		--[GetSpellInfo(20189)] = {	[1] = { Effect = 1, Spells = "All", ModType = "hitPerc" }, },
		---Sanctified Judgement
		--[GetSpellInfo(31876)] = { 	[1] = { Effect = -0.264, Spells = "Judgement", ModType = "manaCostM" }, },
	}
end