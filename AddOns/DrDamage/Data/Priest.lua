if select(2, UnitClass("player")) ~= "PRIEST" then return end
local GetSpellInfo = GetSpellInfo

--No baseincrease: Mind Flay, starshards, circle of healing, devouring plague, vampiric touch, SW: D, SW: P

function DrDamage:PlayerData()

	--Special Calculation
	self.Calculation["Mind Blast"] = function ( calculation, ActiveAuras, BuffTalentRanks )
		if ActiveAuras["Shadow Word: Pain"] and BuffTalentRanks["Twisted Faith"] then
 			calculation.dmgM = calculation.dmgM * (1 + (BuffTalentRanks["Twisted Faith"] ))
		end
	end
	self.Calculation["Mind Flay"] = self.Calculation["Mind Blast"]
	
	self.Calculation["Shadow Word: Pain"] = function ( calculation, ActiveAuras )
		if ActiveAuras["Shadowform"] then
			calculation.dmgM = calculation.dmgM + ( calculation.critPerc / 100)
		end
	end
	
	self.Calculation["Devouring Plague"] = self.Calculation["Shadow Word: Pain"]
	self.Calculation["Vampiric Touch"] = self.Calculation["Shadow Word: Pain"]
	
	--General
	self.Calculation["PRIEST"] = function ( calculation, ActiveAuras, _, _, baseSpell )
		if ActiveAuras["Shadowform"] and baseSpell.School == "Shadow" then
			calculation.dmgM = calculation.dmgM + 0.15
		end
	end
	
	--Set bonuses
	
	--Sets
	self.SetBonuses["Hallowed Raiment"] = { 27536, 27775, 27875, 28230, 28413 }
	self.SetBonuses["Incarnate Regalia"] = { 29056, 29057, 29058, 29059, 29060 }
	self.SetBonuses["Incarnate Raiment"] = { 29049, 29050, 29053, 29054, 29055 }
	self.SetBonuses["Avatar Raiment"] = { 30150, 30151, 30152, 30153, 30154 }
	self.SetBonuses["Absolution Regalia"] = { 31061, 31064, 31065, 31067, 31070, 34434, 34528, 34563 }
	self.SetBonuses["Vestments of Absolution"] = { 31060, 31063, 31066, 31068, 31069, 34435, 34527, 34562 }
	
	--Effects
	self.SetBonuses["Prayer of Mending"] = function( calculation )
		if self:GetSetAmount( "Hallowed Raiment" ) >= 4 then
			calculation.finalMod = calculation.finalMod + 100
		end	
	end
	self.SetBonuses["Smite"] = function( calculation )
		if self:GetSetAmount( "Incarnate Regalia" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	self.SetBonuses["Mind Flay"] = self.SetBonuses["Smite"]
	--[[self.SetBonuses["Prayer of Healing"] = function( calculation )
		if DrDamage:GetSetAmount( "Incarnate Raiment" ) >= 2 then
			2: Your Prayer of Healing spell now also causes an additional 150 healing over 9 seconds.
		end	
	end--]]
	self.SetBonuses["Renew"] = function( calculation )
		if self:GetSetAmount( "Avatar Raiment" ) >= 4 then
			calculation.eDuration = calculation.eDuration + 3
		end	
	end
	self.SetBonuses["Shadow Word: Pain"] = function( calculation )
		if self:GetSetAmount( "Absolution Regalia" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 3
		end	
	end
	self.SetBonuses["Mind Blast"] = function( calculation )
		if self:GetSetAmount( "Absolution Regalia" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.1
		end	
	end
	self.SetBonuses["Greater Heal"] = function( calculation )
		if self:GetSetAmount( "Vestments of Absolution" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end	
	end	
	
	--AURAS
	--Shadowform
	--Flexibility
	---Judgement of the Crusader
	--Shadow Weaving
	--Grace
	--Shadow Word: Pain
	self.PlayerAura[GetSpellInfo(15473)] = { ModType = "ActiveAura", ActiveAura = "Shadowform" }
	self.PlayerAura[GetSpellInfo(37565)] = { ModType = "Update", Spell = GetSpellInfo(2060) }
	--self.TargetAura[GetSpellInfo(21183)] = { School = "Holy", ModType = "spellDmg", Ranks = 7, Value = { 20, 30, 50, 80, 110, 140, 190 }, }
	self.PlayerAura[GetSpellInfo(15258)] =  { School = "Shadow", Value = 0.02, Apps = 5}
	self.TargetAura[GetSpellInfo(47516)] =  { School = "Healing", Value = 0.02, Apps = 3, SelfCast = true }
	self.TargetAura[GetSpellInfo(589)] = { ModType = "ActiveAura", ActiveAura = "Shadow Word: Pain" }
	
	self.spellInfo = { 
		[GetSpellInfo(15407)] = {
					["Name"] = "Mind Flay", ----processed by zironic for 3.02, Can crit, right base value, I hope the sFactor is correct 
					[0] = { School = "Shadow", canCrit = true, castTime=3, sFactor = 0.9, sTicks = 1, },
					[1] = { 45, 45, spellLevel = 20, },
					[2] = { 108, 108, spellLevel = 28, },
					[3] = { 159, 159, spellLevel = 36, },
					[4] = { 222, 222, spellLevel = 44, },
					[5] = { 282, 282, spellLevel = 52, },
					[6] = { 363, 363, spellLevel = 60, },
					[7] = { 450, 450, spellLevel = 68, },
					[8] = { 492, 492, spellLevel = 74, },
					[9] = { 588, 588, spellLevel = 80, },
		},		
		[GetSpellInfo(2944)] = {
					["Name"] = "Devouring Plague", ----processed by zironic for 3.02  --Quick test showed sFactor should be about 0.5 assuming all other math is correct. --DALLYTEMP
					[0] = { School = "Shadow", eDot = true, eDuration = 24, sFactor = 0.5, Cooldown = 24, sTicks = 3, },
					[1] = { 152, 152, spellLevel = 20, },
					[2] = { 272, 272, spellLevel = 28, },
					[3] = { 400, 400, spellLevel = 36, },
					[4] = { 544, 544, spellLevel = 44, },
					[5] = { 712, 712, spellLevel = 52, },
					[6] = { 904, 904, spellLevel = 60, },
					[7] = { 1088, 1088, spellLevel = 68, }, --this rank is getting nerfed in 3.03
					[8] = { 1144, 1144, spellLevel = 73, }, --this rank is getting nerfed in 3.03
					[9] = { 1376, 1376, spellLevel = 79, }, --this rank is getting nerfed in 3.03
		},
		[GetSpellInfo(589)] = {
					["Name"] = "Shadow Word: Pain", --processed by zironic for 3.02 
					[0] = { School = "Shadow", eDot = true, eDuration = 18 , bonusFactor = 1.2 * 0.915, sTicks = 3, NoDownRank = true },
					[1] = { 30, 30, spellLevel = 4, },
					[2] = { 60, 60, spellLevel = 10, },
					[3] = { 120, 120, spellLevel = 18, },
					[4] = { 210, 210, spellLevel = 26, },
					[5] = { 330, 330, spellLevel = 34, },
					[6] = { 462, 462, spellLevel = 42, },	
					[7] = { 606, 606, spellLevel = 50, },
					[8] = { 768, 768, spellLevel = 58, },
					[9] = { 906, 906, spellLevel = 65, },
					[10] = { 1116, 1116, spellLevel = 70, },
					[11] = { 1176, 1176, spellLevel = 75, },
					[12] = { 1380, 1380, spellLevel = 80, },
		},
		[GetSpellInfo(34914)] = {
					["Name"] = "Vampiric Touch", --processed by zironic for 3.02
					[0] = { School = "Shadow", eDot = true, bonusFactor = 1, eDuration = 15, sTicks = 3, },
					[1] = { 450, 450, spellLevel = 50, },
					[2] = { 600, 600, spellLevel = 60, },	
					[3] = { 650, 650, spellLevel = 70, },	
					[4] = { 735, 735, spellLevel = 75, },	
					[5] = { 850, 850, spellLevel = 80, },	
		},		
		[GetSpellInfo(32379)] = {
					["Name"] = "Shadow Word: Death", --processed by zironic for 3.02
					[0] = { School = "Shadow", canCrit = true, Cooldown = 12, },
					[1] = { 450, 522, spellLevel = 62, },
					[2] = { 572, 664, spellLevel = 70, },		
					[3] = { 639, 741, spellLevel = 75, },
					[4] = { 750, 870, spellLevel = 80, },				
		},		
		[GetSpellInfo(8092)] = {
					["Name"] = "Mind Blast", --processed by zironic for 3.02
					[0] = { School = "Shadow", canCrit = true, Cooldown = 8, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 39, 43, 3, 3, spellLevel = 10, },
					[2] = { 72, 78, 4, 5, spellLevel = 16, },
					[3] = { 112, 120, 5, 6, spellLevel = 22, },
					[4] = { 167, 177, 7, 7, spellLevel = 28, },
					[5] = { 217, 231, 8, 8, spellLevel = 34, },
					[6] = { 279, 297, 9, 10, spellLevel = 40, },
					[7] = { 346, 366, 10, 11, spellLevel = 46, },
					[8] = { 425, 449, 12, 12, spellLevel = 52, },
					[9] = { 503, 531, 13, 13, spellLevel = 58, },
					[10] = { 557, 587, 14, 15, spellLevel = 63, },
					[11] = { 708, 748, 16, 17, spellLevel = 69, }, --Guess --DALLYTEMP
					[12] = { 837, 883, 0, 0, spellLevel = 74, },
					[13] = { 992, 1048, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(17)] = {
					["Name"] = "Power Word: Shield", -- --processed by zironic for 3.02, as you can see the last ranks don't have their levelbous, apparently buffed to "normal" scaling so i removed ", bonusFactor = 0.8"
					[0] = { School = "Holy", Healing = true, Cooldown = 4, NoDPS = true, NoDebuffs = true, NoDoom = true, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 44, 44, 4, 4, spellLevel = 6, },
					[2] = { 88, 88, 6, 6, spellLevel = 12, },
					[3] = { 158, 158, 8, 8, spellLevel = 18, },
					[4] = { 234, 234, 10, 10, spellLevel = 24, },
					[5] = { 301, 301, 11, 11, spellLevel = 30, },
					[6] = { 381, 381, 13, 13, spellLevel = 36, },
					[7] = { 484, 484, 15, 15, spellLevel = 42, },
					[8] = { 605, 605, 17, 17, spellLevel = 48, },
					[9] = { 763, 763, 19, 19, spellLevel = 54, },
					[10] = { 942, 942, 21, 21, spellLevel = 60, },
					[11] = { 1125, 1125, 18, 18, spellLevel = 65, },
					[12] = { 1265, 1265, 0, 0, spellLevel = 70, },
					[13] = { 1920, 1920, 0, 0, spellLevel = 75, },
					[14] = { 2230, 2230, 0, 0, spellLevel = 80, },
		},
		[GetSpellInfo(2054)] = {
					["Name"] = "Heal", --processed by zironic for 3.02
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 3, BaseIncrease = true,  LevelIncrease = 5 },
					[1] = { 295, 341, 12, 12, spellLevel = 16, },
					[2] = { 429, 491, 16, 16, spellLevel = 22, },
					[3] = { 566, 642, 20, 20, spellLevel = 28, },
					[4] = { 712, 804, 22, 23, spellLevel = 34, },
		},
		[GetSpellInfo(2050)] = {
					["Name"] = "Lesser Heal", --processed by zironic for 3.02
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 2.5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 46, 56, 1, 2, spellLevel = 1, castTime = 1.5, },
					[2] = { 71, 85, 5, 6, spellLevel = 4, castTime = 2, },
					[3] = { 135, 157, 8, 8, spellLevel = 10, },			
		},			
		[GetSpellInfo(2060)] = {
					["Name"] = "Greater Heal", --processed by zironic for 3.02, last 3 ranks lack leveling adjustment
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 3, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 899, 1013, 25, 26, spellLevel = 40, },
					[2] = { 1149, 1289, 29, 29, spellLevel = 46, },
					[3] = { 1437, 1609, 33, 33, spellLevel = 52, },
					[4] = { 1798, 2006, 37, 38, spellLevel = 58, },
					[5] = { 1966, 2194, 40, 41, spellLevel = 60, },
					[6] = { 2074, 2410, 33, 34, spellLevel = 63, },
					[7] = { 2396, 2784, 45, 46, spellLevel = 68, },	--Guess --DALLYTEMP
					[8] = { 3395, 3945, 0, 0, spellLevel = 73, },
					[9] = { 3950, 4590, 0, 0, spellLevel = 78, },			
		},
		[GetSpellInfo(596)] = {
					["Name"] = "Prayer of Healing", --processed by zironic for 3.02, last 3 ranks lack leveling adjustment
					[0] = { School = { "Holy", "Healing" }, canCrit = true, castTime = 3, Healing = true, sFactor = 1/3 * 1.5, BaseIncrease = true, LevelIncrease = 9 },
					[1] = { 301, 321, 11, 12, spellLevel = 30, },
					[2] = { 444, 472, 14, 15, spellLevel = 40, },
					[3] = { 657, 695, 15, 18, spellLevel = 50, },
					[4] = { 939, 991, 14, 15, spellLevel = 60, },
					[5] = { 997, 1053, 22, 23, spellLevel = 60, },
					[6] = { 1246, 1316, 23, 24, spellLevel = 68, }, --Guess --DALLYTEMP
					[7] = { 2091, 2209, 0, 0, spellLevel = 76, },
		},
		[GetSpellInfo(34861)] = {
					["Name"] = "Circle of Healing", --processed by zironic for 3.02,
					[0] = { School = { "Holy", "Healing" }, sFactor = 1/3 * 1.5, },
					[1] = { 246, 270, spellLevel = 50, },
					[2] = { 288, 318, spellLevel = 56, },
					[3] = { 327, 361, spellLevel = 60, },
					[4] = { 370, 408, spellLevel = 65, },
					[5] = { 409, 451, spellLevel = 70, },
					[6] = { 589, 651, spellLevel = 75, },
					[7] = { 684, 756, spellLevel = 80, },
		},		
		[GetSpellInfo(2061)] = {
					["Name"] = "Flash Heal", --processed by zironic for 3.02, leveladjustment for last 3 ranks is obviously inaccurate
					[0] = { School = { "Holy", "Healing" }, canCrit = true, BaseIncrease = true,  LevelIncrease = 5 },
					[1] = { 193, 237, 9, 10, spellLevel = 20, },
					[2] = { 258, 314, 11, 11, spellLevel = 26, },
					[3] = { 327, 393, 12, 13, spellLevel = 32, },
					[4] = { 400, 478, 14, 14, spellLevel = 38, },
					[5] = { 518, 616, 16, 17, spellLevel = 44, },
					[6] = { 644, 764, 18, 19, spellLevel = 52, },
					[7] = { 812, 958, 21, 21, spellLevel = 58, },
					[8] = { 913, 1059, 18, 19, spellLevel = 61, },
					[9] = { 1101, 1279, 26, 27, spellLevel = 67, }, --Guess --DALLYTEMP
					[10] = { 1578, 1832, 0, 0, spellLevel = 73, },
					[11] = { 1887, 2193, 0, 0, spellLevel = 79, },
		},
		[GetSpellInfo(19236)] = {
					--TODO: Get REAL baseincrease ranks 7-8
					["Name"] = "Desperate Prayer", --processed by zironic for 3.02, leveladjustment will be comletely out of whack and has to be tested.
					[0] = { School = { "Holy", "Healing" }, canCrit = true, NoDoom = true, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 263, 325, 20, 21, spellLevel = 20, },
					[2] = { 447, 543, 27, 27, spellLevel = 26, },
					[3] = { 588, 708, 31, 32, spellLevel = 34, },
					[4] = { 834, 994, 38, 39, spellLevel = 42, },
					[5] = { 1101, 1305, 44, 45, spellLevel = 50, },
					[6] = { 1324, 1562, 50, 51, spellLevel = 58, },
					[7] = { 1601, 1887, 56, 57, spellLevel = 66, }, --Guess --DALLYTEMP
					[8] = { 3111, 3699, 0, 0, spellLevel = 73, },
					[9] = { 3716, 4384, 0, 0, spellLevel = 80, },
		},		
		[GetSpellInfo(139)] = {
					["Name"] = "Renew", --processed by zironic for 3.02
					[0] = { School = { "Holy", "Healing" }, eDot = true, eDuration = 15, sTicks = 3, },
					[1] = { 45, 45, spellLevel = 8, },
					[2] = { 100, 100, spellLevel = 14, },
					[3] = { 175, 175, spellLevel = 20, },
					[4] = { 245, 245, spellLevel = 26, },
					[5] = { 315, 315, spellLevel = 32, },
					[6] = { 400, 400, spellLevel = 38, },
					[7] = { 510, 510, spellLevel = 44, },
					[8] = { 650, 650, spellLevel = 50, },
					[9] = { 810, 810, spellLevel = 56, },
					[10] = { 970, 970, spellLevel = 60, },
					[11] = { 1010, 1010, spellLevel = 65, },
					[12] = { 1110, 1110, spellLevel = 70, },
					[13] = { 1235, 1235, spellLevel = 75, },
					[14] = { 1400, 1400, spellLevel = 80, },
		},
		[GetSpellInfo(32546)] = {
					["Name"] = "Binding Heal", --processed by zironic for 3.02, last 2 ranks won't have the right level value
					[0] = { School = { "Holy", "Healing" }, canCrit = true, BaseIncrease = true, LevelIncrease = 7}, --Need to find LevelIncrease -DALLYTEMP
					[1] = { 1042, 1338, 60, 61, spellLevel = 64, }, --Guess --DALLYTEMP
					[2] = { 1619, 2081, 0, 0, spellLevel = 72, },
					[3] = { 1952, 2508, 0, 0, spellLevel = 78, },
		},
		[GetSpellInfo(33076)] = {
					["Name"] = "Prayer of Mending", --processed by zironic for 3.02
					[0] = { School = { "Holy", "Healing" }, canCrit = true, Cooldown = 10, sHits = 5, sFactor = 5, NoDPS = true },
					[1] = { 800, 800, spellLevel = 68, },
					[2] = { 905, 905, spellLevel = 74, },
					[3] = { 1043, 1043, spellLevel = 79, },
		},			
		[GetSpellInfo(585)] = {
					["Name"] = "Smite", --processed by zironic for 3.02, level adjustment for last 3 ranks will be non functional
					[0] = { School = "Holy", canCrit = true, castTime=2.5, BaseIncrease = true, LevelIncrease = 5 },
					[1] = { 13, 17, 2, 3, spellLevel = 1, castTime = 1.5, },
					[2] = { 25, 31, 3, 3,  spellLevel = 6, castTime = 2.0, },
					[3] = { 54, 62, 4, 5, spellLevel = 14, },
					[4] = { 91, 105, 6, 7, spellLevel = 22, },
					[5] = { 150, 170, 8, 8, spellLevel = 30, },
					[6] = { 212, 240, 10, 10, spellLevel = 38, },
					[7] = { 287, 323, 12, 12, spellLevel = 46, },
					[8] = { 371, 415, 13, 14, spellLevel = 54, },
					[9] = { 405, 453, 17, 17, spellLevel = 61, },
					[10] = { 545, 611, 22, 23, spellLevel = 69, }, --Guess --DALLYTEMP
					[11] = { 604, 676, 0, 0, spellLevel = 74, },					
					[12] = { 707, 793, 0, 0, spellLevel = 79, },					
		},
		[GetSpellInfo(14914)] = {
					["Name"] = "Holy Fire", --processed by zironic for 3.02, scaling might be way off, and so might the leveladjustment
					[0] = { School = "Holy", canCrit = true, castTime=2, Cooldown = 10, eDuration = 7, sTicks = 1, hybridFactor = 0.8571, hybridDotFactor = 1.7495, BaseIncrease = true,  LevelIncrease = 6 },
					[1] = { 102, 128, 6, 6, hybridDotDmg= 21, spellLevel = 20, },
					[2] = { 137, 173, 10, 11, hybridDotDmg= 28, spellLevel = 24, },
					[3] = { 200, 252, 12, 12, hybridDotDmg= 42, spellLevel = 30, },
					[4] = { 267, 339, 13, 14, hybridDotDmg= 56, spellLevel = 36, },
					[5] = { 348, 440, 15, 15, hybridDotDmg= 70, spellLevel = 42, },
					[6] = { 430, 546, 17, 18, hybridDotDmg= 91, spellLevel = 48, },
					[7] = { 529, 671, 19, 20, hybridDotDmg= 112, spellLevel = 54, },
					[8] = { 639, 811, 20, 21, hybridDotDmg= 126, spellLevel = 60, },
					[9] = { 705, 895, 22, 23, hybridDotDmg= 147, spellLevel = 66, }, --Guess --DALLYTEMP
					[10] = { 732, 928, 0, 0, hybridDotDmg= 287, spellLevel = 72, },
					[11] = { 890, 1130, 0, 0, hybridDotDmg= 350, spellLevel = 78, },				
		},
		[GetSpellInfo(15237)] = {
					["Name"] = "Holy Nova", --processed by zironic for 3.02, buffed healing scaling to 0.3
					[0] = { School = "Holy", canCrit = true, bonusFactor = 0.163, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 28, 32, 1, 2, spellLevel = 20, },
					[2] = { 50, 58, 2, 3, spellLevel = 28, },
					[3] = { 76, 88, 3, 4, spellLevel = 36, },
					[4] = { 106, 123, 4, 4, spellLevel = 44, },
					[5] = { 140, 163, 6, 6, spellLevel = 52, },
					[6] = { 181, 210, 7, 7, spellLevel = 60, },
					[7] = { 242, 280, 8, 8, spellLevel = 68, }, --Guess --DALLYTEMP
					[8] = { 333, 387, 0, 0, spellLevel = 75, },
					[9] = { 398, 462, 0, 0, spellLevel = 80, },
			["Secondary"] = {
					["Name"] = "Holy Nova",
					[0] = { School = { "Holy", "Healing" }, canCrit = true, bonusFactor = 0.3, BaseIncrease = true, LevelIncrease = 7 },
					[1] = { 52, 60, 2, 3, spellLevel = 20, },
					[2] = { 86, 98, 3, 3, spellLevel = 28, },
					[3] = { 121, 139, 3, 4, spellLevel = 36, },
					[4] = { 161, 188, 4, 4, spellLevel = 44, },
					[5] = { 235, 272, 4, 4, spellLevel = 52, },
					[6] = { 302, 350, 5, 6, spellLevel = 60, },
					[7] = { 384, 446, 6, 6, spellLevel = 68, }, --Guess --DALLYTEMP
					[8] = { 611, 709, 0, 0, spellLevel = 75, },
					[9] = { 713, 827, 0, 0, spellLevel = 80, },
			}
		},
		[GetSpellInfo(28880)] = {
					["Name"] = "Gift of the Naaru",
					[0] = { School = { "Holy", "Healing" }, Cooldown = 180, eDot = true, eDuration = 15, sTicks = 3, bonusFactor = 1, BaseIncrease = true, NoLowLevelPenalty = true, NoDownRank = true, NoSchoolTalents = true, },
					["None"] = { 50, 50, 1035, 1035, spellLevel = 1, },
		},
		[GetSpellInfo(724)] = {
					["Name"] = "Lightwell", --processed by zironic for 3.02
					[0] = { School = "Holy", Healing = true, bonusFactor = 1, eDot = true, eDuration = 6, sTicks = 2, Stacks = 5 },
					[1] = { 801, 801, spellLevel = 40, },
					[2] = { 1164, 1164, spellLevel = 50, },
					[3] = { 1599, 1599, spellLevel = 60, },
					[4] = { 2361, 2361, spellLevel = 70, },		
					[5] = { 3915, 3915, spellLevel = 75, },
					[6] = { 4620, 4620, spellLevel = 80, },					
		},
		[GetSpellInfo(47951)] = {
					["Name"] = "Divine Hymn", --added by Zironic, base value is accurate, everything else is probably not.
					[0] = { School = "Holy", Healing = true, eDot = true, eDuration = 6, sTicks = 1, castTime = 1.5 },
					[1] = { 2088, 2088, spellLevel = 80},
		},
		[GetSpellInfo(48045)] = {
		["Name"] = "Mind Sear", --added by Zironic, base value is accurate, everything else is probably not.
					[0] = { School = "Shadow", sTicks = 1, castTime = 5 },
					[1] = { 915, 985, spellLevel = 75},
					[2] = { 1060, 1140, spellLevel = 80},
		},
		[GetSpellInfo(53007)] = {
					["Name"] = "Penance", --added by Zironic, base value is accurate, everything else is probably not.
					[0] = { School = "Holy", Healing = true, sHits = 3, castTime = 2 },
					[1] = { 670, 756, spellLevel = 60},
					[2] = { 805, 909, spellLevel = 70},
					[3] = { 1278, 1442, spellLevel = 75},
					[4] = { 1484, 1676, spellLevel = 80},
				["Secondary"] = {
					["Name"] = "Penance",
					[0] = { School = "Holy", sHits = 3, castTime = 2 },
					[1] = { 184, 184, spellLevel = 60},
					[2] = { 224, 224, spellLevel = 70},
					[3] = { 256, 256, spellLevel = 75},
					[4] = { 288, 288, spellLevel = 80},
				}
		},		
	}
	self.talentInfo = { 
		--SHADOW:
		--Shadow Focus
		--Darkness
		--Improved Shadow Word: Pain
		--Shadow Power
		--Improved Mind Blast
		--Misery
		--Twisted Faith
		--Mind Melt
		[GetSpellInfo(15260)] = { 	[1] = { Effect = 1, Spells = "Shadow", ModType = "hitPerc" }, },
		[GetSpellInfo(15259)] = { 	[1] = { Effect = 0.02, Spells = "Shadow" }, },
		[GetSpellInfo(15275)] = { 	[1] = { Effect = 0.03, Spells = "Shadow Word: Pain", }, },
		[GetSpellInfo(33221)] = { 	[1] = { Effect = 0.1, Spells = { "Mind Blast", "Shadow Word: Death", "Mind Flay" }, ModType = "critM", }, },
		[GetSpellInfo(15273)] = { 	[1] = { Effect = -0.5, Spells = "Mind Blast", ModType = "cooldown" }, },
		[GetSpellInfo(33191)] = {   [1] = { Effect = 0.05, Spells = {"Mind Blast", "Mind Flay", "Mind Sear"}, ModType = "SpellDamage", Multiply = true}, },
		[GetSpellInfo(47573)] = {		[1] = { Effect = 0.02, Spells = {"Mind Flay", "Mind Blast"}, ModType = "Amount", Value = "Twisted Faith" }, },
		[GetSpellInfo(14910)] = {   [1] = { Effect = 2, Spells = {"Mind Blast", "Mind Flay", "Mind Sear"}, ModType = "critPerc", }, },
		--HOLY:
		--Improved Renew
		--Searing Light
		--Spiritual Healing
		--Empowered Healing
		--Divine Providence
		[GetSpellInfo(14908)] = { 	[1] = { Effect = 0.05, Spells = "Renew", }, },
		[GetSpellInfo(14909)] = { 	[1] = { Effect = 0.05, Spells = { "Smite", "Holy Fire", "Penace" }, }, },
		[GetSpellInfo(14898)] = {		[1] = { Effect = 0.02, Spells = "Healing", }, },
		[GetSpellInfo(33158)] = { 	[1] = { Effect = 0.08, Spells = "Greater Heal", ModType = "SpellDamage", Multiply = true },
																[2] = { Effect = 0.04, Spells = { "Flash Heal", "Binding Heal" }, ModType = "SpellDamage", Multiply = true }, },
		[GetSpellInfo(47562)] = { 	[1] = { Effect = 0.02, Spells = { "Circle of Healing", "Binding Heal", "Divine Hymn", "Holy Nova", "Prayer of Healing" }, },
																[2] = { Effect = -0.6, Spells = "Prayer of Mending", ModType = "cooldown" }, },
		--DISCIPLINE:
		--Improved Power Word: Shield
		--Twin Disciplines
		--Borrowed Time
		[GetSpellInfo(14748)] = { 	[1] = { Effect = 0.05, Spells = "Power Word: Shield", }, },
		[GetSpellInfo(47586)] = { 	[1] = { Effect = 0.01, Spells = {"Shadow Word: Pain", "Renew", "Power Word: Shield", "Holy Nova", "Prayer of Mending", "Devouring Plague", "Shadow Word: Death"},   }, },
		[GetSpellInfo(52795)] = {   [1] = { Effect = 0.08, Spells = "Power Word: Shield", ModType = "Spelldamage", Multiply = true},},
		}
end