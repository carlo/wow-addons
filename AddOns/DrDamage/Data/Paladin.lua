if select(2, UnitClass("player")) ~= "PALADIN" then return end
local SEA = AceLibrary("SpecialEvents-Aura-2.0")
local BR
local BS
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2")
else
	BS = {}
	setmetatable(BS,{ __index = function(t,k) return k end })
end

--No base increase: Avenger's Shield, Holy Shield, Consecration, Holy Wrath

function DrDamage:PlayerData()

	--Special calculation
	
	--General
	self.Calculation["PALADIN"] = function( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Judgement of the Crusader"] then
			if IsEquippedItem( 23203 ) then						--Libram of Fervor
				ActiveAuras["Judgement of the Crusader"] = ActiveAuras["Judgement of the Crusader"] + 33
			elseif IsEquippedItem( 27983 ) or IsEquippedItem( 27949 ) then		--Libram of Zeal
				ActiveAuras["Judgement of the Crusader"] = ActiveAuras["Judgement of the Crusader"] + 48					
			end
			
			--Merciless Gladiator's Scaled Gauntlets
			if IsEquippedItem( 32040 ) then
				ActiveAuras["Judgement of the Crusader"] = ActiveAuras["Judgement of the Crusader"] + 20
			end
			
			if self:GetSetAmount( "Justicar Battlegear" ) >= 2 then
				ActiveAuras["Judgement of the Crusader"] = ActiveAuras["Judgement of the Crusader"] * 1.15
			end			

			if BuffTalentRanks["Sanctified Crusader"] then
				calculation.critPerc = calculation.critPerc + BuffTalentRanks["Sanctified Crusader"]
			end
			
			calculation.spellDmg = calculation.spellDmg + ActiveAuras["Judgement of the Crusader"]		
		end
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
	self.Calculation["One-Handed Weapon Specialization"] = function( calculation, talentValue )
		if not calculation.healingSpell then
			if self:GetNormM() == 2.4 then
				calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
			end
		end
	end
	self.Calculation["Two-Handed Weapon Specialization"] = function( calculation, talentValue )
		if self:GetNormM() == 3.3 then
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )
		end
	end
	
	--Spell specific
	self.Calculation["Improved Holy Shield"] = function( calculation, talentValue )
		if calculation.sHits then
			calculation.sHits = calculation.sHits + talentValue
		end
	end	
	self.Calculation["Crusader Strike"] = function( calculation )
		calculation.minDam, calculation.maxDam = DrDamage:WeaponDamage(DrDamage:GetAP())
	end
	self.Calculation["Holy Light"] = function( calculation, ActiveAuras )
		if ActiveAuras["Blessing of Light"] or ActiveAuras["Greater Blessing of Light"] then
			if IsEquippedItem( 28592 ) then
				calculation.finalMod = calculation.finalMod + 105
			end
		end
	end
	self.Calculation["Flash of Light"] = function( calculation, ActiveAuras )
		if ActiveAuras["Blessing of Light"] or ActiveAuras["Greater Blessing of Light"] then
			if IsEquippedItem( 28592 ) then
				calculation.finalMod = calculation.finalMod + 105
			end
		end
		--Merciless Gladiator's Ornamented Gloves
		if IsEquippedItem( 32021 ) then
			calculation.critPerc = calculation.critPerc + 2
		end
	end
	self.Calculation["Vengeance"] = function( calculation, _, BuffTalentRanks, _, apps )
		if apps and BuffTalentRanks["Vengeance"] then
			calculation.dmgM = calculation.dmgM * ( 1 + 0.01 * BuffTalentRanks["Vengeance"] * apps )
		end
	end
	self.Calculation["Revenge"] = self.Calculation["Vengeance"]
	self.Calculation["Sanctity Aura"] = function( calculation, _, BuffTalentRanks )
		if calculation.spellSchool == "Holy" then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	
	--Relic slot items
	self.RelicSlot["Consecration"] = { 27917, 47 }				--Libram of the Eternal Rest
	self.RelicSlot["Crusader Strike"] = { 31033, 18, ModType1 = "Final" }	--Libram of Righteous Power
	self.RelicSlot["Flash of Light"] = { 23006, 83, 25644, 79, 23201, 53, }	--Libram of Light, Blessed Book of Nagrand, Libram of Divinity	
	self.RelicSlot["Holy Light"] = { 28296, 87, }				--Libram of the Lightbringer
	self.RelicSlot["Judgement of Righteousness"] = { 33504, 63 }		--Libram of Divine Purpose
	
	--Set bonuses
	
	--Sets
	self.SetBonuses["Justicar Armor"] = { 29066, 29067, 29068, 29069, 29070 }
	self.SetBonuses["Justicar Battlegear"] = { 29071, 29072, 29073, 29074, 29075 }
	self.SetBonuses["Crystalforge Raiment"] = { 30134, 30135, 30136, 30137, 30138 }
	self.SetBonuses["Lightbringer Armor"] = { 30985, 30987, 30991, 30995, 30998 }
	self.SetBonuses["Lightbringer Battlegear"] = { 30982, 30989, 30990, 30993, 30997 }
	self.SetBonuses["Lightbringer Raiment"] = { 30983, 30988, 30992, 30994, 30996 }
	
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
		if self:GetSetAmount( "Crystalforge Raiment" ) >= 4 then
			calculation.castTime = calculation.castTime - 0.25
		end
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
	
	--Seals and judgements
	self.Calculation["Seal of Blood"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		local data = select(10,self:RawNumbers( DrDamage:GetSpellInfo(BS["Judgement of Command"], spell.Rank), BS["Judgement of Command"], true ))
		calculation.dmgM = data.DmgM
		if BuffTalentRanks["Sanctified Crusader"] and ActiveAuras["Judgement of the Crusader"] then
			calculation.critPerc = calculation.critPerc + BuffTalentRanks["Sanctified Crusader"]
		end		
	end
	self.DmgCalculation["Seal of Righteousness"] = function( calculation, _, _, spell )
		local spd = self:GetWeaponSpeed()
		local min, max = self:WeaponDamage(calculation.AP,true)
		local data = select(10,self:RawNumbers( DrDamage:GetSpellInfo(BS["Judgement of Righteousness"], spell.Rank), BS["Judgement of Righteousness"], true ))
		local sDmgM = 0.092 * spd
		if self:GetNormM() == 3.3 then sDmgM = 0.108 * spd end
		local dmg = spd * spell.Multiplier
		calculation.minDam = 0.0085 * dmg + 0.015 * (min+max) + sDmgM * (data.SpellDmg + calculation.spellDmg) + 1
		calculation.maxDam = 0.012 * dmg + 0.015 * (min+max) + sDmgM * (data.SpellDmg + calculation.spellDmg) + 1
		calculation.spellDmg = data.SpellDmg
		calculation.dmgM = data.DmgM
		calculation.Hits = math.floor(30/spd)
		--calculation.hitPerc = data.HitRate
		
		if IsEquippedItem( 33504 ) then --Libram of Divine Purpose
			calculation.minDam = calculation.minDam + 63
			calculation.maxDam = calculation.maxDam + 63
		end
		
		if self:GetSetAmount( "Justicar Armor" ) >= 2 then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	self.DmgCalculation["Seal of Command"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		local data = select(10,self:RawNumbers( DrDamage:GetSpellInfo(BS["Judgement of Command"], spell.Rank), BS["Judgement of Command"], true ))
		local bonus = 0.29 * (data.SpellDmg - GetSpellBonusDamage(1)) + 0.2 * GetSpellBonusDamage(1)
		calculation.minDam = bonus + 0.29 * calculation.spellDmg
		calculation.maxDam = bonus + 0.29 * calculation.spellDmg
		calculation.spellDmg = bonus
		calculation.dmgM = data.DmgM
		if BuffTalentRanks["Sanctified Crusader"] and ActiveAuras["Judgement of the Crusader"] then
			calculation.critPerc = calculation.critPerc + BuffTalentRanks["Sanctified Crusader"]
		end
	end
	self.Calculation["Judgement of Vengeance"] = function( calculation, ActiveAuras )
		if ActiveAuras["Holy Vengeance"] then
			calculation.bDmgM = calculation.bDmgM + ( ActiveAuras["Holy Vengeance"] - 1 )
		end
	end
	self.Calculation["Sanctified Judgement"] = function( calculation, talentValue )
		calculation.costM = 1 - talentValue
	end		
	
	--Auras
	self.HealingBuffs["Blessing of Light"] = { ModType = "RankTable2", Ranks = 4, Spell = { BS["Flash of Light"], BS["Holy Light"] }, Value = { 60, 85, 115, 185 }, Value2 = { 210, 300, 400, 580, }, ActiveAura = true }
	self.HealingBuffs["Greater Blessing of Light"] = { ModType = "RankTable2", Ranks = 2, Spell = { BS["Flash of Light"], BS["Holy Light"] }, Value = { 115, 185 }, Value2 = { 400, 580, }, ActiveAura = true }	

	self.PlayerAura["Seal of Righteousness"] = { ModType = "None" }
	self.PlayerAura["Seal of Command"] = { ModType = "None" }
	self.PlayerAura["Seal of Blood"] = { ModType = "None" }
	self.PlayerAura["Seal of Vengeance"] = { ModType = "None" }
	
	self.PlayerAura["Sanctity Aura"] = { ModType = "Special" }	
	self.PlayerAura["Vengeance"] = { School = { "Holy", "Physical" }, ModType = "Special" }	
	self.PlayerAura["Revenge"] = { School = { "Holy", "Physical" }, ModType = "Special" }	
	self.PlayerAura["Light's Grace"] = { Value = -0.5, ModType = "CastTime", Spell = BS["Holy Light"], }
	self.PlayerAura["Divine Favor"] = { Spell = { BS["Flash of Light"], BS["Holy Light"], BS["Holy Shock"], }, ModType = "Crit", Value = 100, }
	
	self.Debuffs["Holy Vengeance"] = { ModType = "ActiveAura", Spell = BS["Judgement"], ActiveAura = true }
	self.Debuffs["Judgement of the Crusader"] = { ModType = "JotC", School = { "Holy", "Physical" }, Ranks = 7, Value = { 23, 35, 58, 92, 127, 161, 219 }, ActiveAura = true }

	self.Debuffs["Intercept Stun"] = 	{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Starfire Stun"] = 	{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Stun"] = 			{ Stun = true, Spell = BS["Judgement of Command"], } 
	self.Debuffs["Bash"] = 			{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Blackout"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Hammer of Justice"] = 	{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Charge Stun"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Concussion Blow"] = 	{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Cheap Shot"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Gouge"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Impact"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Kidney Shot"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Maim"] = 			{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Pounce"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Sap"] = 			{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["War Stomp"] = 		{ Stun = true, Spell = BS["Judgement of Command"], }
	self.Debuffs["Feral Charge Effect"]= 	{ Stun = true, Spell = BS["Judgement of Command"], }
	
	self.spellInfo = { 
		[BS["Crusader Strike"]] = { 
					[0] = { School = { "Holy", "Physical" }, bonusFactor = 0.4, Cooldown = 6, NoSchoolBuffs = true, NoTypeBuffs = true },
					["None"] = { 0, 0, spellLevel = 50, },
					[1] = { 0, 0, spellLevel = 50, },
		},
		[BS["Avenger's Shield"]] = { 
					[0] = { School = { "Holy", "Physical" }, canCrit = true, castTime = 1, sFactor = 1/2, chainFactor = 1, Cooldown = 30, },
					[1] = { 270, 330, spellLevel = 50, },
					[2] = { 370, 452, spellLevel = 60, }, 
					[3] = { 494, 602, spellLevel = 70, }, 
		},
		[BS["Holy Wrath"]] = { 
					[0] = { School = "Holy", canCrit = true, castTime = 2, sFactor = 1/2, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 362, 428, 6, 7, spellLevel = 50, },
					[2] = { 490, 576, 7, 8, spellLevel = 60, },
					[3] = { 635, 745, 2, 3, spellLevel = 69, },
		},
		[BS["Holy Shield"]] = { 
					[0] = { School = "Holy", Instant = true, bonusFactor = 0.20, NoDPS = true, NoDoom = true, sHits = 4, },
					[1] = { 59, 59, spellLevel = 40, },
					[2] = { 86, 86, spellLevel = 50, },
					[3] = { 117, 117, spellLevel = 60, },
					[4] = { 155, 155, spellLevel = 70, },
		},
		[BS["Holy Light"]] = { 
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 2.5, BaseIncrease = true, LevelIncrease = 5 }, --4?
					[1] = { 39, 47, 3, 4, spellLevel = 1, },
					[2] = { 76, 90, 5, 6, spellLevel = 6, },
					[3] = { 159, 187, 8, 9, spellLevel = 14, },
					[4] = { 310, 356, 12, 12, spellLevel = 22, },
					[5] = { 491, 553, 15, 16, spellLevel = 30, },
					[6] = { 698, 780, 19, 19, spellLevel = 38, },
					[7] = { 945, 1053, 23, 23, spellLevel = 46, },
					[8] = { 1246, 1388, 26, 26, spellLevel = 54, },
					[9] = { 1590, 1770, 29, 29, spellLevel = 60, },
					[10] = { 1741, 1939, 32, 32, spellLevel = 62, },
					[11] = { 2196, 2446, 0, 0, spellLevel = 70, },
		},	
		[BS["Hammer of Wrath"]] = {
					[0] = { School = { "Holy", "Physical" }, canCrit = true, Cooldown = 6, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 304, 336, 12, 12, spellLevel = 44, },
					[2] = { 399, 441, 13, 14, spellLevel = 52, },
					[3] = { 504, 556, 15, 16, spellLevel = 60, },
					[4] = { 665, 735, 7, 7, spellLevel = 68, }, --Check increase
		},
		[BS["Exorcism"]] = {
					[0] = { School = "Holy", Instant = true, canCrit = true, Cooldown = 15, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 84, 96, 6, 6, spellLevel = 20, },
					[2] = { 152, 172, 8, 8, spellLevel = 28, },
					[3] = { 217, 245, 10, 10, spellLevel = 36, },
					[4] = { 304, 342, 12, 12, spellLevel = 44, },
					[5] = { 393, 439, 14, 14, spellLevel = 52, },
					[6] = { 505, 563, 16, 16, spellLevel = 60, },
					[7] = { 619, 691, 7, 7, spellLevel = 68, },
		},
		[BS["Consecration"]] = {
					--sFactor = 1/2 * 0.83?
					[0] = { School = "Holy", castTime = 8, sFactor = 1/2.4, sTicks = 1, },
					[1] = { 64, 64, spellLevel = 20, },
					[2] = { 120, 120, spellLevel = 30, },
					[3] = { 192, 192, spellLevel = 40, },
					[4] = { 280, 280, spellLevel = 50, },
					[5] = { 384, 384, spellLevel = 60, },
					[6] = { 512, 512, spellLevel = 70, },
		},
		[BS["Flash of Light"]] = { 
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 1.5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 62, 72, 5, 5, spellLevel = 20, },
					[2] = { 96, 110, 6, 7, spellLevel = 26, },
					[3] = { 145, 163, 8, 9, spellLevel = 34, },
					[4] = { 197, 221, 9, 10, spellLevel = 42, },
					[5] = { 267, 299, 11, 11, spellLevel = 50, },
					[6] = { 343, 383, 13, 13, spellLevel = 58, },
					[7] = { 448, 502, 10, 11, spellLevel = 66, },
		},
		[BS["Holy Shock"]] = { 
					[0] = { School = "Holy", Instant = true, canCrit = true, Cooldown = 15, },
					[1] = { 204, 220, spellLevel = 40, },
					[2] = { 279, 301, spellLevel = 48, },
					[3] = { 365, 395, spellLevel = 56, },
					[4] = { 452, 488, spellLevel = 64, },
					[5] = { 530, 574, spellLevel = 70, },
		},
		["Judgements"] = { [BS["Seal of Righteousness"]] = BS["Judgement of Righteousness"], [BS["Seal of Command"]] = BS["Judgement of Command"], [BS["Seal of Vengeance"]] = "Judgement of Vengeance", [BS["Seal of Blood"]] = "Judgement of Blood" },
		--Judgements:
		[BS["Judgement"]] = { [0] = function()
						for k, v in pairs(DrDamage.spellInfo["Judgements"]) do
							local index, _, _, rank = SEA:UnitHasBuff("player",k)
							if index then
								return v, DrDamage.spellInfo[v][0], DrDamage.spellInfo[v][tonumber(rank:match("%d+"))]
							end
						end
					end
		
		},
		[BS["Seal of Righteousness"]] = {
					[0] = { School = "Holy", Melee = true, SpellDmgBonus = true, NoCrits = true, WeaponDPS = true, APGain = true },
					[1] = { 0, Multiplier = 133.488, Rank = 1 },
					[2] = { 0, Multiplier = 266.976, Rank = 2 },
					[3] = { 0, Multiplier = 435.072, Rank = 3 },
					[4] = { 0, Multiplier = 668.676, Rank = 4 },
					[5] = { 0, Multiplier = 970.260, Rank = 5 },
					[6] = { 0, Multiplier = 1337.35, Rank = 6 },
					[7] = { 0, Multiplier = 1739.05, Rank = 7 },
					[8] = { 0, Multiplier = 2207.50, Rank = 8 },
					[9] = { 0, Multiplier = 2610.43, Rank = 9 },
		},
		[BS["Judgement of Righteousness"]] = {
					[0] = { School = { "Holy", "Judgement" }, Instant = true, Cooldown = 10, bonusFactor = 0.73, canCrit = true, NoDoom = true, BaseIncrease = true, LevelIncrease = 6 },
					[1] = { 15, 15, 10, 11, spellLevel = 1,  },
					[2] = { 25, 27, 11, 12, spellLevel = 10, },
					[3] = { 39, 43, 14, 15, spellLevel = 18, },
					[4] = { 57, 63, 16, 17, spellLevel = 26, },
					[5] = { 78, 86, 18, 19, spellLevel = 34, },
					[6] = { 102, 112, 22, 23, spellLevel = 42, },	
					[7] = { 131, 143, 24, 25, spellLevel = 50, },
					[8] = { 162, 178, 24, 25, spellLevel = 58, },
					[9] = { 208, 228, 17, 18, spellLevel = 66, }, 
		},
		[BS["Seal of Command"]] = {
					[0] = { School = "Physical", Melee = true, SpellDmgBonus = true, WeaponDamage = 0.7, Hits = 3.5, eDuration = 30, PPM = 7, NoNormalization = true },
					[1] = { 0, Rank = 1 },
					[2] = { 0, Rank = 2 },
					[3] = { 0, Rank = 3 },
					[4] = { 0, Rank = 4 },
					[5] = { 0, Rank = 5 },
					[6] = { 0, Rank = 6 },
		},
		[BS["Judgement of Command"]] = {
					[0] = { School = { "Holy", "Judgement", "Physical" }, Cooldown = 10, Instant = true, canCrit = true, NoDoom = true, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 46, 50, 22, 23, spellLevel = 20, },
					[2] = { 73, 80, 24, 25, spellLevel = 30, },
					[3] = { 102, 112, 22, 23, spellLevel = 40, },
					[4] = { 130, 143, 24, 25, spellLevel = 50, },
					[5] = { 169, 186, 24, 25, spellLevel = 60, },
					[6] = { 228, 252, 0, 0, spellLevel = 70, },
		},
		[BS["Seal of Vengeance"]] = {
					[0] = { School = "Holy", Instant = true, castTime = 30, extraDotFactor = 0.17, Stacks = 10, StacksDuration = 30, NoDoom = true, PPM = 20 },
					[1] = { 0, 0, extraDotDmg = 120, spellLevel = 64, },
		},
		["Judgement of Vengeance"] = {
					[0] = { School = { "Holy", "Judgement" }, Cooldown = 10, Instant = true, canCrit = true, NoDoom = true, },
					[1] = { 120, 120, spellLevel = 64, },			
		},
		[BS["Seal of Blood"]] = { 
					[0] = { School = "Holy", Melee = true, WeaponDamage = 0.35, WeaponDPS = true },
					[1] = { 0, Rank = 5 },
		},		
		["Judgement of Blood"] = {
					[0] = { School = { "Holy", "Judgement", "Physical" }, Cooldown = 10, Instant = true, canCrit = true, NoDoom = true, BaseIncrease = true, },
					[1] = { 295, 325, 36, 37, spellLevel = 64, },			
		},
		[BS["Gift of the Naaru"]] = {
					[0] = { School = { "Holy", "Healing" }, Cooldown = 180, eDot = true, eDuration = 15, sTicks = 3, bonusFactor = 1, BaseIncrease = true, NoLowLevelPenalty = true, NoDownRank = true, },
					["None"] = { 50, 50, 1035, 1035, spellLevel = 1, },
		},			
	}
	self.talentInfo = { 
		--Holy:
		["Improved Seal of Righteousness"] = { 	[1] = { Effect = 0.03, Spells = "Seal of Righteousness", "Judgement of Righteousness" }, },
		["Healing Light"] = { 			[1] = { Effect = 0.04, Spells = { "Holy Light", "Flash of Light", }, }, },
		["Sanctified Light"] = { 		[1] = { Effect = 2, Spells = "Holy Light", ModType = "Crit" }, },
		["Illumination"] = { 			[1] = { Effect = 0.12, Spells = { "Holy Light", "Flash of Light", "Holy Shock" }, ModType = "FreeCrit" }, },
		["Purifying Power"] = {			[1] = { Effect = 10, Spells = { "Holy Wrath", "Exorcism", }, ModType = "Crit" }, },
		--Retribution:
		["Crusade"] = { 			[1] = { Effect = 0.01, Spells = "All", ModType = "Crusade" }, },
		["Vengeance"] = { 			[1] = { Effect = 1, Spells = { "Physical", "Holy" }, ModType = "BuffTalentRanks", }, },
		["Improved Seal of the Crusader"] = { 	[1] = { Effect = 1, Spells = "All", ModType = "BuffTalentRanks" }, },
		["Fanaticism"] = { 			[1] = { Effect = 3, Spells = "Judgement", ModType = "Crit" }, },
		["Improved Holy Shield"] = { 		[1] = { Effect = 0.1, Spells = "Holy Shield", },
							[2] = { Effect = 2, Spells = "Holy Shield", ModType = "Improved Holy Shield" },
		},
		["One-Handed Weapon Specialization"] = { [1] = { Effect = 0.01, Spells = "All", ModType = "One-Handed Weapon Specialization" }, },
		--Melee module
		["Precision"] = {			[1] = { Effect = 1, Spells = "Physical", ModType = "Hit" }, },
		["Two-Handed Weapon Specialization"] = { [1] = { Effect = 0.02, Spells = "All", Melee = true, ModType = "Two-Handed Weapon Specialization" }, },
		["Sanctified Judgement"] = { 		[1] = { Effect = 0.25, Spells = "Judgement", ModType = "Sanctified Judgement" }, },
		["Improved Judgement"] = { 		[1] = { Effect = 1, Spells = "Judgement", ModType = "Cooldown" }, },
	}
end