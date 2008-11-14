if select(2, UnitClass("player")) ~= "DRUID" then return end
local GetSpellInfo = GetSpellInfo
local IsEquippedItem = IsEquippedItem
local UnitStat = UnitStat

--No base increase on: Insect Swarm, Rejuvenation, Entangling Roots, Lifebloom

function DrDamage:PlayerData()

	--Special calculation
	--Nourish bonus if Rejuvenation, Regrowth or Lifebloom are active on the target
	local rejaura = GetSpellInfo(774)
	local regaura = GetSpellInfo(8936)
	local lbaura = GetSpellInfo(33763)
	self.Calculation["Nourish"] = function( calculation, ActiveAuras, _, spell )
		if ( ActiveAuras["Rejuvenation"] or ActiveAuras["Regrowth"] or ActiveAuras["Lifebloom"] ) or not UnitExists("target") and ( UnitBuff("player", rejaura) or UnitBuff("player", regaura) or UnitBuff("player", lbaura) ) then
			calculation.minDam = calculation.minDam * ( 1 + nourishBonus )
			calculation.maxDam = calculation.maxDam * ( 1 + nourishBonus )
		end
	end
	
	self.Calculation["Starfire"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if ActiveAuras["Insect Swarm"] and BuffTalentRanks["Improved Insect Swarm"] then
			calculation.critPerc = calculation.critPerc + 1 * BuffTalentRanks["Improved Insect Swarm"]
		end
	end
	
	self.Calculation["Wrath"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if ActiveAuras["Insect Swarm"] and BuffTalentRanks["Improved Insect Swarm"] then
			calculation.dmgM = calculation.dmgM * (1 + (BuffTalentRanks["Improved Insect Swarm"] * 0.01))
		end
	end

	--Bleed detection hack for Rend and Tear Talent
	local bleedDeepWounds = tostring(GetSpellInfo(43104)) -- May be incorrect spellid --DALLYTEMP
	local bleedRend = tostring(GetSpellInfo(16403))
	local bleedGarrote = tostring(GetSpellInfo(703))
	local bleedRupture = tostring(GetSpellInfo(1943))
	local bleedLacerate = tostring(GetSpellInfo(33745))
	local bleedPounce = tostring(GetSpellInfo(9005))
	local bleedRip = tostring(GetSpellInfo(1079))
	local bleedRake = tostring(GetSpellInfo(59881))
	self.Calculation["Maul"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if BuffTalentRanks["Rend and Tear"] then
			if UnitDebuff("target", bleedDeepWounds) or UnitDebuff("target", bleedRend) or UnitDebuff("target", bleedGarrote) or UnitDebuff("target", bleedRupture) or UnitDebuff("target", bleedLacerate) or UnitDebuff("target", bleedPounce) or UnitDebuff("target", bleedRip) or UnitDebuff("target", bleedRake) then
				calculation.dmgM = calculation.dmgM * (1 + (0.04 * BuffTalentRanks["Rend and Tear"]))
			end
		end
	end
	self.Calculation["Shred"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if BuffTalentRanks["Rend and Tear"] then
			if UnitDebuff("target", bleedDeepWounds) or UnitDebuff("target", bleedRend) or UnitDebuff("target", bleedGarrote) or UnitDebuff("target", bleedRupture) or UnitDebuff("target", bleedLacerate) or UnitDebuff("target", bleedPounce) or UnitDebuff("target", bleedRip) or UnitDebuff("target", bleedRake) then
				calculation.dmgM = calculation.dmgM * (1 + (0.04 * BuffTalentRanks["Rend and Tear"]))
			end
		end
	end
	self.Calculation["Ferocious Bite"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if BuffTalentRanks["Rend and Tear"] then
			if UnitDebuff("target", bleedDeepWounds) or UnitDebuff("target", bleedRend) or UnitDebuff("target", bleedGarrote) or UnitDebuff("target", bleedRupture) or UnitDebuff("target", bleedLacerate) or UnitDebuff("target", bleedPounce) or UnitDebuff("target", bleedRip) or UnitDebuff("target", bleedRake) then
				calculation.critPerc = calculation.critPerc + (10 * BuffTalentRanks["Rend and Tear"])
			end
		end
	end
			
	
	--General
	local tol = GetSpellInfo(34123)
	local mka = GetSpellInfo(24907)
	self.Calculation["DRUID"] = function( calculation, ActiveAuras, BuffTalentRanks, spell )
		if calculation.healingSpell then
			if ActiveAuras["Tree of Life"] or not UnitExists("target") and UnitBuff("player", tol) then --GetPlayerBuff* replaced with UnitBuff
			 	calculation.spellDmg = ( calculation.spellDmg + (IsEquippedItem(32387) and 44 or 0) ) * 1.06  --Idol of the Raven Goddess and new ToL 6%
			 	--if BuffTalentRanks["Improved Tree of Life"] then --Improved tree of life "5/10/15% of spirit" healing bonus
			 	--	calculation.spellDmg = calculation.spellDmg + BuffTalentRanks["Improved Tree of Life"] * select(2,UnitStat("player",5))
			 	--end
			 	if BuffTalentRanks["Master Shapeshifter"] then
			 		calculation.spellDmg = calculation.spellDmg * (1 + BuffTalentRanks["Master Shapeshifter"])
				end
			end
		else
			if BuffTalentRanks["Naturalist"] then
				calculation.spellDmg = calculation.spellDmg / ( 1 + BuffTalentRanks["Naturalist"] )
			end
			if BuffTalentRanks["Improved Faerie Fire"] and ActiveAuras["Faerie Fire"] then
				calculation.critPerc = calculation.critPerc + 1 * BuffTalentRanks["Improved Faerie Fire"]
				calculation.hitPerc = calculation.hitPerc + 1 * BuffTalentRanks["Improved Faerie Fire"]
			end
			if ActiveAuras["Owlkin Frenzy"] then
				calculation.dmgM = calculation.dmgM * 1.1
			end
			if BuffTalentRanks["King of the Jungle"] and GetShapeShiftForm(true) == 1 and ActiveAuras["Enrage"] then
				calculation.dmgM = calculation.dmgM * (1 + (0.05 * BuffTalentRanks["King of the Jungle"]))
			end
			--if GetShapeshiftForm(true) == 1 and BuffTalentRanks["Master Shapeshifter (Melee)"] then
				--if calculation.isMelee then -- to ensure only physical abilities show the damage increase
					--calculation.dmgM = calculation.dmgM  * (1 + BuffTalentRanks["Master Shapeshifter (Melee)"])
				--end
			--end
			if UnitBuff("player", mka) and BuffTalentRanks["Master Shapeshifter"] then
				--if not baseSpell.Melee then
					--self:Print("shouldn't be here")
					calculation.dmgM = calculation.dmgM  * (1 + BuffTalentRanks["Master Shapeshifter"])
				--end
			end
		end
	end
	
	--Set bonuses
	
	--Sets
	self.SetBonuses["Nordrassil Harness"] = { 30222, 30223, 30228, 30229, 30230 }
	self.SetBonuses["Nordrassil Raiment"] = { 30216, 30217, 30219, 30220, 30221 }
	self.SetBonuses["Nordrassil Regalia"] = { 30231, 30232, 30233, 30234, 30235 }
	
	self.SetBonuses["Thunderheart Harness"] = { 31034, 31039, 31042, 31044, 31048, 34444, 34556, 34573 }
	self.SetBonuses["Thunderheart Raiment"] = { 31032, 31037, 31041, 31045, 31047, 34445, 34554, 34571 }
	self.SetBonuses["Thunderheart Regalia"] = { 31035, 31040, 31043, 31046, 31049, 34446, 34555, 34572 }
	
	--Effects
	self.SetBonuses["Regrowth"] = function( calculation )
		if self:GetSetAmount( "Nordrassil Raiment" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 6
		end
	end
	self.SetBonuses["Lifebloom"] = function( calculation, _, spell )
		if self:GetSetAmount( "Nordrassil Raiment" ) >= 4 then
			calculation.finalMod = calculation.finalMod + 150
		end
		if IsEquippedItem(27886) then --Idol of the Emerald Queen, +88 to HOT portion
			calculation.dotFinalMod = calculation.dotFinalMod + 88 * spell.dotFactor
		elseif IsEquippedItem(28355) then --Gladiator's Idol of Tenacity
			calculation.finalMod = calculation.finalMod + 87
		elseif IsEquippedItem(33076) then --Merciless Gladiator's Idol of Tenacity
			calculation.finalMod = calculation.finalMod + 105
		elseif IsEquippedItem(33841) then --Vengeful Gladiator's Idol of Tenacity
			calculation.finalMod = calculation.finalMod + 116
		end
	end
	self.SetBonuses["Starfire"] = function( calculation, ActiveAuras )
		if self:GetSetAmount( "Nordrassil Regalia" ) >= 4 then
			if ActiveAuras["Moonfire"] or ActiveAuras["Insect Swarm"] then
				calculation.dmgM = calculation.dmgM * 1.1
			end
		end
		if self:GetSetAmount( "Thunderheart Regalia" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.SetBonuses["Moonfire"] = function( calculation )
		if self:GetSetAmount( "Thunderheart Regalia" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 3
		end
	end	
	self.SetBonuses["Shred"] = function( calculation )
		if self:GetSetAmount("Nordrassil Harness") >= 4 then
			calculation.minDam = calculation.minDam + 75
			calculation.maxDam = calculation.maxDam + 75
		end
	end
	self.SetBonuses["Lacerate"] = function( calculation )
		if self:GetSetAmount("Nordrassil Harness") >= 4 then
			calculation.extraDamBonus = calculation.extraDamBonus + 15
		end
		if IsEquippedItem(27744) then --Idol of Ursoc
			calculation.extraDamBonus = calculation.extraDamBonus + 8
			calculation.minDam = calculation.minDam + 8
			calculation.maxDam = calculation.maxDam + 8
		end
	end
	self.SetBonuses["Rip"] = function( calculation )
		if self:GetSetAmount("Thunderheart Harness") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.15
		end
		if IsEquippedItem(28372) then --Idol of Feral Shadows
			local cp = calculation.Melee_ComboPoints
			calculation.minDam = calculation.minDam + 7 * cp
			calculation.maxDam = calculation.maxDam + 7 * cp
		end
	end
	self.SetBonuses["Ferocious Bite"] = self.SetBonuses["Rip"]
	self.SetBonuses["Swipe"] = self.SetBonuses["Rip"]
	self.SetBonuses["Healing Touch"] = function( calculation )
		if self:GetSetAmount("Thunderheart Raiment") >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end		
	end

	
	--Relic slot items:
	self.RelicSlot["Rejuvenation"] = { 25643, 86, 22398, 50, ModType1 = "finalMod_sM", ModType2 = "finalMod_sM" }	--Harold's Rejuvenating Broach, Idol of Rejuvenation
	self.RelicSlot["Healing Touch"] = { 28568, 136, 22399, 100, ModType1 = "finalMod_fM", ModType2 = "finalMod_fM" }--Idol of the Avian Heart, Idol of Health
	self.RelicSlot["Wrath"] = { 31025, 25 }										--Idol of the Avenger		
	self.RelicSlot["Moonfire"] = { 23197, 33, ModType1 = "finalMod_sM" }						--Idol of the Moon
	self.RelicSlot["Starfire"] = { 27518, 55, ModType1 = "finalMod_sM" }						--Ivory Idol of the Moongoddess
	
	self.RelicSlot["Shred"] = { 29390, 88, } --Everbloom idol
	self.RelicSlot["Mangle (Cat)"] = { 28064, 24, } --Idol of the Wild
	self.RelicSlot["Mangle (Bear)"] = { 28064, 51.75, } --Idol of the Wild
	self.RelicSlot["Maul"] = { 23198, 50 } --Idol of Brutality
	self.RelicSlot["Swipe"] = { 23198, 10 } --Idol of Brutality
	self.RelicSlot["Rake"] = { 22397, 20, 27989, 30 } --Idol of Ferocity, Idol of Savagery
	self.RelicSlot["Claw"] = { 22397, 20, 27989, 30 } --Idol of Ferocity, Idol of Savagery
	
	--AURA
	--Nature's Grace
	--Moonfire
	--Insect Swarm
	---Mangle (Bear) --Adding effect to Aura.lua
	---Mangle (Cat)
	self.PlayerAura[GetSpellInfo(16880)] = { ModType = "Update" }
	self.TargetAura[GetSpellInfo(34123)] = { School = "Healing", ModType = "ActiveAura", ActiveAura = "Tree of Life", }
	self.TargetAura[GetSpellInfo(8921)] = { Spell = GetSpellInfo(2912), ModType = "ActiveAura", ActiveAura = "Moonfire", }
	self.TargetAura[GetSpellInfo(5570)] = { Spell = { GetSpellInfo(2912), GetSpellInfo(5176) }, ModType = "ActiveAura", ActiveAura = "Insect Swarm", }
	--self.TargetAura[GetSpellInfo(33878)] = { Spell = { GetSpellInfo(9005), GetSpellInfo(1079), GetSpellInfo(33745), GetSpellInfo(5221), GetSpellInfo(1822), GetSpellInfo(6807) }, Value = 0.3 }
	--self.TargetAura[GetSpellInfo(33876)] = self.TargetAura[GetSpellInfo(33878)]
	--Rejuvenation (for Nourish bonus)
	--Regrowth (for Nourish bonus)
	--Lifebloom (for Nourish bonus)
	self.TargetAura[GetSpellInfo(774)] = { Spell = GetSpellInfo(50464), ModType = "ActiveAura", ActiveAura="Rejuvenation", SelfCast = true, }
	self.TargetAura[GetSpellInfo(8936)] = { Spell = GetSpellInfo(50464), ModType = "ActiveAura", ActiveAura="Regrowth", SelfCast = true, }
	self.TargetAura[GetSpellInfo(33763)] = { Spell = GetSpellInfo(50464), ModType = "ActiveAura", ActiveAura="Lifebloom", SelfCast = true, }
	--Faerie Fire
	self.TargetAura[GetSpellInfo(770)] = { ModType = "ActiveAura", ActiveAura = "Faerie Fire", SelfCast = true, }
	--Owlkin Frenzy
	self.PlayerAura[GetSpellInfo(48391)] = { ModType = "ActiveAura", ActiveAura = "Owlkin Frenzy", }
	--Eclipse (Boosted Wrath)
	--Eclipse (Boosted Starfire)
	self.PlayerAura[GetSpellInfo(48517)] = { Spell = GetSpellInfo(5176), Value = 0.2 }
	self.PlayerAura[GetSpellInfo(48518)] = { Spell = GetSpellInfo(2912), Value = 30, ModType = "critPerc" }
	--Enrage
	self.PlayerAura[GetSpellInfo(5229)] = { ModType = "ActiveAura", ActiveAura = "Enrage" }
	--Master Shapshifter
	self.PlayerAura[GetSpellInfo(48411)] = { ModType = "Activeaura", ActiveAura = "Master Shapeshifter" }
	
	self.spellInfo = { --Processed --DALLYTEMP
		[GetSpellInfo(5176)] = {
					["Name"] = "Wrath",
					[0] = { School = "Nature", canCrit = true, castTime = 2, CastMod = 0.1, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 17, 19, 1, 2, spellLevel = 1, castTime = 1.5, },
					[2] = { 32, 36, 3, 4, spellLevel = 6, castTime = 1.7, },
					[3] = { 49, 57, 4, 5, spellLevel = 14, },
					[4] = { 68, 78, 6, 6, spellLevel = 22, },
					[5] = { 130, 148, 7, 8, spellLevel = 30, },
					[6] = { 169, 191, 9, 10, spellLevel = 38, },
					[7] = { 215, 241, 10, 11, spellLevel = 46, },
					[8] = { 306, 344, 12, 13, spellLevel = 54, },
					[9] = { 397, 447, 14, 15, spellLevel = 61, },
					[10] = { 431, 485, 16, 17, spellLevel = 69, }, --Guess --DALLYTEMP
					[11] = { 504, 568, 0, 0, spellLevel = 74, },
					[12] = { 553, 623, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(27012)] = { --Processed --DALLYTEMP
					["Name"] = "Hurricane",
					[0] = { School = "Nature", canCrit = true, castTime = 10, sHits = 10, bonusFactor = 1.28962, BaseIncrease = true, LevelIncrease = 9 },
					[1] = { 100, 100, 1, 2, spellLevel = 40, },
					[2] = { 142, 142, 1, 2, spellLevel = 50, },
					[3] = { 190, 190, 1, 2, spellLevel = 60, },
					[4] = { 303, 303, 1, 2, spellLevel = 70, }, --Guess --DALLYTEMP
					[5] = { 451, 451, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(5570)] = { --Processed --DALLYTEMP
					["Name"] = "Insect Swarm",
					[0] = { School = "Nature", sFactor = 0.95, eDot = true, eDuration = 12, sTicks = 2, },
					[1] = { 144, 144, spellLevel = 30 },
					[2] = { 234, 234, spellLevel = 30 },
					[3] = { 372, 372, spellLevel = 40 },
					[4] = { 540, 540, spellLevel = 50 },
					[5] = { 594, 594, spellLevel = 60 },
					[6] = { 1032, 1032, spellLevel = 70 },
					[7] = { 1290, 1290, spellLevel = 80 },
		},		
		[GetSpellInfo(8921)] = { --Processed --DALLYTEMP
					["Name"] = "Moonfire",
					[0] = { School = "Arcane", canCrit = true, eDuration = 12, sTicks = 3, hybridFactor = 0.348, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 7, 9, 2, 3, hybridDotDmg = 12, spellLevel = 4, },
					[2] = { 13, 17, 4, 4, hybridDotDmg = 32, spellLevel = 10 },
					[3] = { 25, 31, 5, 6, hybridDotDmg = 52, spellLevel = 16, },
					[4] = { 40, 48, 7, 7, hybridDotDmg = 80, spellLevel = 22, },
					[5] = { 61, 73, 9, 9, hybridDotDmg = 124, spellLevel = 28, },
					[6] = { 81, 97, 10, 11, hybridDotDmg = 164, spellLevel = 34, },
					[7] = { 105, 125, 12, 12, hybridDotDmg = 212, spellLevel = 40, },
					[8] = { 130, 154, 13, 14, hybridDotDmg = 264, spellLevel = 46, },
					[9] = { 157, 185, 15, 15, hybridDotDmg = 320, spellLevel = 52, },
					[10] = { 189, 221, 16, 17, hybridDotDmg = 384, spellLevel = 58, },
					[11] = { 220, 258, 18, 18, hybridDotDmg = 444, spellLevel = 63, },
					[12] = { 305, 357, 19, 20, hybridDotDmg = 600, spellLevel = 70, }, --Guess --DALLYTEMP
					[13] = { 347, 407, 0, 0, hybridDotDmg = 684, spellLevel = 75, },
					[14] = { 407, 476, 0, 0, hybridDotDmg = 800, spellLevel = 80, },
		},
		[GetSpellInfo(2912)] = { --Processed --DALLYTEMP
					["Name"] = "Starfire",
					[0] = { School = "Arcane", canCrit = true, castTime = 3.5, CastMod = 0.1, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 121, 149, 6, 6, spellLevel = 20, },
					[2] = { 189, 231, 9, 10, spellLevel = 26, },
					[3] = { 272, 328, 11, 12, spellLevel = 34, },
					[4] = { 370, 442, 13, 14, spellLevel = 42, },
					[5] = { 485, 575, 16, 17, spellLevel = 50, },
					[6] = { 615, 725, 18, 18, spellLevel = 58, },
					[7] = { 693, 817, 18, 19, spellLevel = 60, },
					[8] = { 818, 964, 20, 21, spellLevel = 67, }, --Guess --DALLYTEMP
					[9] = { 854, 1006, 0, 0, spellLevel = 72, },
					[10] = { 1028, 1212, 0, 0, spellLevel = 78, },
		},
		[GetSpellInfo(339)] = { --Updated --DALLYTEMP	
					["Name"] = "Entangling Roots",
					[0] = { School = "Nature", eDot = true, eDuration = 27, sFactor = 0.5, sTicks = 3, },
					[1] = { 20, 20, spellLevel = 8, eDuration = 12, },
					[2] = { 50, 50, spellLevel = 18, eDuration = 15, },
					[3] = { 90, 90, spellLevel = 28, eDuration = 18, },
					[4] = { 140, 140, spellLevel = 38, eDuration = 21, },
					[5] = { 200, 200, spellLevel = 48, eDuration = 24, },
					[6] = { 270, 270, spellLevel = 58, },
					[7] = { 351, 351, spellLevel = 68, },
					[8] = { 423, 423, spellLevel = 78, },
		},
		-- Need to find sFactor, using 1 for now; need to find LeveIncrease, using 9 for now --DALLYTEMP
		[GetSpellInfo(50516)] = { --Added --DALLYTEMP
					["Name"] = "Typhoon",
					[0] = { School = "Nature", canCrit = true, sFactor = 1, Cooldown = 20, BaseIncrease = true, LevelIncrease = 9 },
					[1] = { 400, 400, 0, 0, spellLevel = 50, },
					[2] = { 550, 550, 0, 0, spellLevel = 60, },
					[3] = { 735, 735, 0, 0, spellLevel = 70, },
					[4] = { 1010, 1010, 0, 0, spellLevel = 75, },
					[5] = { 1190, 1190, 0, 0, spellLevel = 80, },
		},
		-- Need to implement AoE from each shard?; Need to find sFactor, using 1 for now; need to find LeveIncrease, using 9 for now --DALLYTEMP
		[GetSpellInfo(48505)] = { --Added --DALLYTEMP
					["Name"] = "Starfall",
					[0] = { School = "Arcane", canCrit = true, sHits = 20, sFactor = 1, BaseIncrease = true, LevelIncrease = 9 },
					[1] = { 111, 129, 0, 0, spellLevel = 60, },
					[2] = { 250, 290, 0, 0, spellLevel = 70, },
					[3] = { 366, 424, 0, 0, spellLevel = 75, },
					[4] = { 433, 503, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(5185)] = { --Processed --DALLYTEMP
					["Name"] = "Healing Touch",
					[0] = { School = { "Nature", "Healing", }, canCrit = true, castTime = 3.0,CastMod = 0.1, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 37, 51, 3, 4, spellLevel = 1, castTime = 1.5, },
					[2] = { 88, 112, 6, 7, spellLevel = 8, castTime = 2, },
					[3] = { 195, 243, 9, 10, spellLevel = 14, castTime = 2.5, },
					[4] = { 363, 445, 13, 14, spellLevel = 20, },
					[5] = { 490, 594, 15, 15, spellLevel = 26, },
					[6] = { 636, 766, 17, 17, spellLevel = 32, },
					[7] = { 802, 960, 19, 20, spellLevel = 38, },					
					[8] = { 1199, 1427, 22, 23, spellLevel = 44, },
					[9] = { 1299, 1539, 25, 26, spellLevel = 50, },
					[10] = { 1620, 1912, 28, 29, spellLevel = 56, },
					[11] = { 1944, 2294, 31, 31, spellLevel = 60, },
					[12] = { 2026, 2392, 31, 32, spellLevel = 62, },
					[13] = { 2321, 2739, 34, 35, spellLevel = 69, }, --Guess --DALLYTEMP
					[14] = { 3223, 3805, 0, 0, spellLevel = 74, },
					[15] = { 3750, 4428, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(774)] = { --Processed --DALLYTEMP
					["Name"] = "Rejuvenation",
					[0] = { School = { "Nature", "Healing", }, eDot = true, eDuration = 12, sTicks = 3, },
					[1] = { 32, 32, spellLevel = 4, },
					[2] = { 56, 56, spellLevel = 10, },
					[3] = { 116, 116, spellLevel = 16, },
					[4] = { 180, 180, spellLevel = 22, },
					[5] = { 244, 244, spellLevel = 28, },
					[6] = { 304, 304, spellLevel = 34, },
					[7] = { 388, 388, spellLevel = 40, },
					[8] = { 488, 488, spellLevel = 46, },
					[9] = { 608, 608, spellLevel = 52, },
					[10] = { 756, 756, spellLevel = 58, },
					[11] = { 888, 888, spellLevel = 60, },
					[12] = { 932, 932, spellLevel = 63, },
					[13] = { 1060, 1060, spellLevel = 69, },
					[14] = { 1192, 1192, spellLevel = 75, },
					[15] = { 1690, 1690, spellLevel = 80, eDuration = 15, },
		},
		[GetSpellInfo(8936)] = { --Processed --DALLYTEMP
					["Name"] = "Regrowth",
					[0] = { School = { "Nature", "Healing", }, canCrit = true, castTime = 2, hybridFactor = 0.499, eDuration = 21, sTicks = 3, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 84, 98, 9, 9, hybridDotDmg = 98, spellLevel = 12, },
					[2] = { 164, 188, 12, 13, hybridDotDmg = 175, spellLevel = 18, },
					[3] = { 240, 274, 15, 16, hybridDotDmg = 259, spellLevel = 24, },
					[4] = { 318, 360, 18, 18, hybridDotDmg = 343, spellLevel = 30, },
					[5] = { 405, 457, 20, 21, hybridDotDmg = 427, spellLevel = 36, },
					[6] = { 511, 575, 23, 24, hybridDotDmg = 546, spellLevel = 42, },
					[7] = { 646, 724, 26, 27, hybridDotDmg = 686, spellLevel = 48, },
					[8] = { 809, 905, 30, 30, hybridDotDmg = 861, spellLevel = 54, },
					[9] = { 1003, 1119, 34, 34, hybridDotDmg = 1064, spellLevel = 60, },
					[10] = { 1215, 1355, 38, 39, hybridDotDmg = 1274, spellLevel = 65, },
					[11] = { 1710, 1908, 0, 0, hybridDotDmg = 1792, spellLevel = 71, },
					[12] = { 2234, 2494, 0, 0, hybridDotDmg = 2345, spellLevel = 77, },
		},
		[GetSpellInfo(740)] = { --Processed --DALLYTEMP
					["Name"] = "Tranquility",
					[0] = { School = { "Nature", "Healing", }, castTime = 8, Cooldown = 600, sFactor = 1/3, sHits = 4, BaseIncrease = true, LevelIncrease = 9 },
					[1] = { 351, 351, 13, 13, spellLevel = 30, },
					[2] = { 515, 515, 15, 15, spellLevel = 40, },
					[3] = { 765, 765, 20, 20, spellLevel = 50, },
					[4] = { 1097, 1097, 22, 22, spellLevel = 60, },
					[5] = { 1518, 1518, 0, 0,  spellLevel = 70, },
					[6] = { 2598, 2598, 0, 0, spellLevel = 75, },
					[7] = { 3035, 3035, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(33763)] = { --Processed --DALLYTEMP
					["Name"] = "Lifebloom",
					[0] = { School = { "Nature", "Healing" }, canCrit = true, eDuration = 7, sTicks = 1, bonusFactor = 1.5/3.5 * 0.8, dotFactor = 0.51983, DotStacks = 3 },
					[1] = { 600, 600, hybridDotDmg = 224, spellLevel = 64, },	
					[2] = { 770, 770, hybridDotDmg = 287, spellLevel = 72, },
					[3] = { 970, 970, hybridDotDmg = 371, spellLevel = 80, },				
		},
		[GetSpellInfo(48438)] = {
				["Name"] = "Wild Growth",
				[0] = { School = { "Nature", "Healing" }, eDot = true, eDuration = 7, sTicks = 1, },
				[1] = { 686, 686, spellLevel = 60, },
				[2] = { 861, 861, spellLevel = 70, },
				[3] = { 1239, 1239, spellLevel = 75, },
				[4] = { 1442, 1442, spellLevel = 80, },
		},
		[GetSpellInfo(50464)] = {
				["Name"] = "Nourish",
				[0] = { School = { "Nature", "Healing" }, canCrit = true, castTime = 1.5, },
				[1] = { 1883, 2187, nourishBonus = 0.2, spellLevel = 80, },
		},
		--Feral
		[GetSpellInfo(6807)] = { --Processed -DALLYTEMP
					["Name"] = "Maul",
					[0] = { Rage = 15, Melee = true, WeaponDamage = 1, RequiresForm = 1, NextMelee = true },
					[1] = { 18 },
					[2] = { 27 },
					[3] = { 37 },
					[4] = { 64 },
					[5] = { 103 },
					[6] = { 145 },
					[7] = { 192 },
					[8] = { 290 },
					[9] = { 472 },
					[10] = { 578 },
		},
		[GetSpellInfo(779)] = { --Processed --DALLYTEMP
					["Name"] = "Swipe",
					[0] = { Rage = 20, Melee = true, RequiresForm = 1, APBonus = 0.07 },
					[1] = { 9 },
					[2] = { 13 },
					[3] = { 19 },
					[4] = { 37 },
					[5] = { 54 },
					[6] = { 76 },
					[7] = { 95 },
					[8] = { 108 },
		},
		[GetSpellInfo(1082)] = { --Processed --DALLYTEMP
					["Name"] = "Claw",
					[0] = { Energy = 45, WeaponDamage = 1, Melee = true, RequiresForm = 3 },
					[1] = { 27 },
					[2] = { 39 },
					[3] = { 57 },
					[4] = { 88 },
					[5] = { 115 },
					[6] = { 190 },
					[7] = { 300 },
					[8] = { 370 },
		},
		[GetSpellInfo(1079)] = { --Processed --DALLYTEMP
					["Name"] = "Rip",
					[0] = { Energy = 30, NoCrits = true, ComboPoints = true, Melee = true, RequiresForm = 3, eDuration = 12, APBonus = { 0.06, 0.12, 0.18, 0.24, 0.3 }, Bleed = true },
					[1] = { 42, PerCombo = 24 },
					[2] = { 66, PerCombo = 32 },
					[3] = { 90, PerCombo = 54 },
					[4] = { 138, PerCombo = 84, },
					[5] = { 192, PerCombo = 120, },
					[6] = { 270, PerCombo = 168, },
					[7] = { 426, PerCombo = 282, },
					[8] = { 624, PerCombo = 432, },
					[9] = { 828, PerCombo = 594, },
		},
		[GetSpellInfo(5221)] = { --Processed --DALLYTEMP
					["Name"] = "Shred",
					[0] = { Energy = 60, WeaponDamage = 2.25, Melee = true, RequiresForm = 3 },
					[1] = { 54 },
					[2] = { 72 },
					[3] = { 99 },
					[4] = { 144 },
					[5] = { 180 },
					[6] = { 236 },
					[7] = { 405 },
					[8] = { 630 },
					[9] = { 742.5 },
		},
		[GetSpellInfo(1822)] = { --Processed --DALLYTEMP
					["Name"] = "Rake",
					[0] = { School = { "Physical", "Bleed" }, Energy = 40, APBonus = 0.01, ExtraDamage = 0.18, E_eDuration = 9, Melee = true, RequiresForm = 3, Bleed = true },
					[1] = { 17, Extra = 90 },
					[2] = { 26, Extra = 135 },
					[3] = { 46, Extra = 207 },
					[4] = { 64, Extra = 297 },
					[5] = { 90, Extra = 414 },
					[6] = { 150, Extra = 963 },
					[7] = { 190, Extra = 1161 },
		},
		-- Using EnergyBonus for the new druid FB calculation: (EnergyBonus + AP) / 410 = dmg per extra point of energy, different from execute now
		[GetSpellInfo(22568)] = { --Processed --DALLYTEMP
					["Name"] = "Ferocious Bite",
					[0] = { Energy = 35, ComboPoints = true, APBonus = 0.07, Melee = true, RequiresForm = 3 }, 
					[1] = { 50, 66, PerCombo = 36, EnergyBonus = 0.7 },
					[2] = { 79, 103, PerCombo = 59, EnergyBonus = 1.1 },
					[3] = { 122, 162, PerCombo = 92, EnergyBonus = 1.5 },
					[4] = { 173, 223, PerCombo = 128, EnergyBonus = 2 },
					[5] = { 199, 259, PerCombo = 147, EnergyBonus = 2.1 },
					[6] = { 226, 292, PerCombo = 169, EnergyBonus = 3.4 },
					[7] = { 334, 446, PerCombo = 236, EnergyBonus = 7.7 },
					[8] = { 310, 550, PerCombo = 290, EnergyBonus = 9.4 },
		},
		[GetSpellInfo(6785)] = { --Processed --DALLYTEMP
					["Name"] = "Ravage",
					[0] = { Energy = 60, WeaponDamage = 3.85, Melee = true, RequiresForm = 3 },
					[1] = { 161.7 },
					[2] = { 238.7 },
					[3] = { 300.3 },
					[4] = { 377.3 },
					[5] = { 565.95 },
					[6] = { 1405.25 },
					[7] = { 1771 },
		},
		[GetSpellInfo(9005)] = { --Processed --DALLYTEMP
					["Name"] = "Pounce",
					[0] = { Energy = 50, NoCrits = true, APBonus = 0.18, Melee = true, RequiresForm = 3, eDuration = 18, Bleed = true },
					[1] = { 270 },
					[2] = { 330 },
					[3] = { 450 },
					[4] = { 600 },
					[5] = { 2100 },
		},
		[GetSpellInfo(33878)] = { --Processed --DALLYTEMP
					["Name"] = "Mangle (Bear)",
					[0] = { Rage = 20, WeaponDamage = 1.15, Melee = true, RequiresForm = 1, Cooldown = 6 },
					[1] = { 86.25 },
					[2] = { 120.75 },
					[3] = { 155.25 },
					[4] = { 251.85 },
					[5] = { 299 },
		},
		[GetSpellInfo(33876)] = { --Processed --DALLYTEMP
					["Name"] = "Mangle (Cat)",
					[0] = { Energy = 45, WeaponDamage = 2.00, Melee = true, RequiresForm = 3, },
					[1] = { 198 },
					[2] = { 256 },
					[3] = { 330 },
					[4] = { 536 },
					[5] = { 634 },
		},
		[GetSpellInfo(22570)] = { --Processed --DALLYTEMP
					["Name"] = "Maim",
					[0] = { Energy = 35, WeaponDamage = 1, ComboPoints = true, Melee = true, RequiresForm = 3, Cooldown = 10 },
					[1] = { 129, 129, PerCombo = 84 },
					[2] = { 224, 224, PerCombo = 158 },
		},
		[GetSpellInfo(33745)] = { --Processed, real initial damage consistently lower than even Blizz states - due to armour? --DALLYTEMP
					["Name"] = "Lacerate",
					[0] = { School = { "Physical", "Bleed" }, Rage = 15, Melee = true, ExtraDamage = 0.05, E_eDuration = 15, Bleed = true },
					[1] = { 31, Extra = 155 },
					[2] = { 70, Extra = 255 },
					[3] = { 88, Extra = 320 },
		},		
	}
	self.talentInfo = {
		--BALANCE:
		--Focused Starlight
		--Improved Moonfire
		--Brambles
		--Vengeance
		--Improved Insect Swarm
		--Moonfury
		--Balance of Power
		--Wrath of Cenarius
		--Gale Winds
		--Earth and Moon
		[GetSpellInfo(35363)] = { 	[1] = { Effect = 2, Spells = { "Wrath", "Starfire", "Starfall", "Nourish", "Healing Touch" }, ModType = "critPerc", }, },
		[GetSpellInfo(16821)] = { 	[1] = { Effect = 5, Spells = "Moonfire", ModType = "critPerc", }, 
																[2] = { Effect = 0.05, Spells = "Moonfire", }, },
		[GetSpellInfo(16836)] = {   [1] = { Effect = 0.25, Spells = { "Entangling Roots" }, }, },				
		[GetSpellInfo(16909)] = { 	[1] = { Effect = 0.1, Spells = { "Starfire", "Starfall", "Moonfire", "Wrath" }, ModType = "critM", }, },
		[GetSpellInfo(57849)] = {		[1] = { Effect = 1, Spells = { "Starfire", "Wrath" }, ModType = "Amount", Value = "Improved Insect Swarm", }, },
		[GetSpellInfo(16896)] = { 	[1] = { Effect = { 0.03, 0.06, 0.1 }, Spells = { "Starfire", "Moonfire", "Wrath" }, }, },
		[GetSpellInfo(33592)] = { 	[1] = { Effect = 2, Spells = "All", Caster = true, ModType = "hitPerc" }, },
		[GetSpellInfo(33603)] = { 	[1] = { Effect = 0.04, Spells = "Starfire", ModType = "SpellDamage", Multiply = true},
																[2] = { Effect = 0.02, Spells = "Wrath", ModType = "SpellDamage", Multiply = true}, },
		[GetSpellInfo(48488)] = {		[1] = { Effect = 15, Spells = { "Hurricane", "Typhoon" }, ModType = "critPerc", }, },
		[GetSpellInfo(48506)] = {		[1] = { Effect = 0.01, Spells = "All", }, },
		--RESTORATION:
		--Naturalist
		--Master Shapeshifter
		--Gift of Nature
		--Improved Rejuvenation
		--Improved Regrowth
		--Empowered Touch
		--Empowered Rejuvenation
		--Improved Tree of Life
		[GetSpellInfo(17069)] = { 	[1] = { Effect = 0.02, Spells = "All", Caster = true, ModType = "Amount", Value = "Naturalist" }, },
		[GetSpellInfo(48411)] = {		[1] = { Effect = 0.02, Spells = "All", Caster = true, ModType = "Amount", Value = "Master Shapeshifter", }, },
		[GetSpellInfo(17104)] = { 	[1] = { Effect = 0.02, Spells = "Healing", Add = true, }, },
		[GetSpellInfo(17111)] = { 	[1] = { Effect = 0.05, Spells = "Rejuvenation", Add = true, }, },
		[GetSpellInfo(17074)] = { 	[1] = { Effect = 10, Spells = "Regrowth", ModType = "critPerc" }, },
		[GetSpellInfo(33879)] = { 	[1] = { Effect = 0.2, Spells = "Healing Touch", ModType = "SpellDamage", Multiply = true}, },
		[GetSpellInfo(33886)] = { 	[1] = { Effect = 0.04, Spells = { "Rejuvenation", "Regrowth", "Lifebloom", "Wild Growth" }, ModType = "SpellDamage", Multiply = true, }, 
																[2] = { Effect = 0.04, Spells = { "Regrowth", "Lifebloom", }, ModType = "dotSpellDmgM", Multiply = true, }, },
		[GetSpellInfo(48535)] = {		[1] = { Effect = 0.05, Spells = "Healing", ModType = "Amount", Value = "Improved Tree of Life", }, },
		--FERAL:
		--Feral Aggression
		--Feral Instinct
		--Savage Fury
		--Predatory Instincts
		--Rend and Tear
		[GetSpellInfo(16858)] = { 	[1] = { Effect = 0.03, Spells = "Ferocious Bite", }, },
		[GetSpellInfo(16947)] = {		[1] = { Effect = 0.1, Spells = "Swipe", }, },
		[GetSpellInfo(16998)] = { 	[1] = { Effect = 0.1, Spells = { "Claw", "Rake", "Mangle (Cat)", "Mangle (Bear)", "Maul" }, }, },
		[GetSpellInfo(33859)] = { 	[1] = { Effect = { 0.03, 0.07, 0.1 }, Spells = "All", Melee = true, ModType = "critM" }, },
		[GetSpellInfo(48432)] = {		[1] = { Effect = 1, Spells = { "Maul", "Shred", "Ferocious Bite" }, ModType = "Amount", Value = "Rend and Tear", }, },
	}
end