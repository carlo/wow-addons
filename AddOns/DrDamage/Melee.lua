local playerClass = select(2,UnitClass("player"))
if playerClass ~= "ROGUE" and playerClass ~= "WARRIOR" and playerClass ~= "HUNTER" and playerClass ~= "DRUID" and playerClass ~= "PALADIN" and playerClass ~= "SHAMAN" then return end
local playerHybrid
if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then playerHybrid = true end

if not DrDamage then DrDamage = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0", "AceHook-2.1", "FuBarPlugin-2.0") end
local L = AceLibrary("AceLocale-2.2"):new("DrDamage")
local SEA = AceLibrary("SpecialEvents-Aura-2.0")
local GT = AceLibrary("Gratuity-2.0")
local Deformat = AceLibrary("Deformat-2.0")
local BS, BI
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2")
	BI = AceLibrary("Babble-Inventory-2.2")
else
	BI = {}
	setmetatable(BI,{ __index = function(t,k) return k end })
end

--General
local settings
local type = type
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local math_abs = math.abs
local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min
local math_max = math.max
local string_match = string.match
local select = select
local UnitLevel = UnitLevel
local Mana_Cost = MANA_COST
local UnitMana = UnitMana

--Melee
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetCombatRatingBonus = GetCombatRatingBonus
local GetItemInfo = GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetComboPoints = GetComboPoints
local UnitRangedDamage = UnitRangedDamage
local UnitRangedAttack = UnitRangedAttack
local UnitDamage = UnitDamage
local UnitAttackSpeed = UnitAttackSpeed
local UnitAttackPower = UnitAttackPower
local UnitAttackBothHands = UnitAttackBothHands
local UnitRangedAttackPower = UnitRangedAttackPower
local UnitPowerType = UnitPowerType
local OffhandHasWeapon = OffhandHasWeapon
local IsEquippedItem = IsEquippedItem
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff

local function DrD_ClearTable(table)
	for k in pairs(table) do
		table[k] = nil
	end
end

local function DrD_Round(x, y)
	return math_floor( x * 10 ^ y + 0.5 ) / 10 ^ y
end

local function DrD_MatchData( data, ... )
	if not data or not ... then
		return false
	end

	if type( data ) == "table" then
		for _, dataName in ipairs( data ) do
			for i = 1, select('#', ...) do
				if dataName == select(i, ...) then
					return true
				end
			end
		end
	else	
		for i = 1, select('#', ...) do
			if data == select(i, ...) then
				return true
			end
		end
	end
	
	return false
end

local function DrD_Set( n, v, setOnly )
	return function(v) 
		settings[n] = v
		if not setOnly and not DrDamage:IsEventScheduled("UpdatingAB") then
			DrDamage:ScheduleEvent("UpdatingAB", DrDamage.UpdateAB, 1.0, DrDamage)
		end
	end
end

if not playerHybrid then
	DrDamage.defaults = {}
end

DrDamage.defaults.HitCalc_M = false
DrDamage.defaults.HitTarget_M = false
DrDamage.defaults.TargetLevel_M = 3
DrDamage.defaults.DisplayType_M = "AvgTotal"
DrDamage.defaults.Coeffs_M = true
DrDamage.defaults.DispCrit_M = true
DrDamage.defaults.DispHit_M = true
DrDamage.defaults.AvgHit_M = true
DrDamage.defaults.AvgCrit_M = true
DrDamage.defaults.Ticks_M = true
DrDamage.defaults.Total_M = true
DrDamage.defaults.Extra_M = true
DrDamage.defaults.Next_M = true
DrDamage.defaults.DPS_M = true
DrDamage.defaults.DPM_M = true
		

function DrDamage:Melee_OnEnable()
	if self.Melee_Options then
		self:Melee_Options()
		self.Melee_Options = nil
	end
	if self.Melee_Data then
		self:Melee_Data()
		self.Melee_Data = nil
	end
	self:RegisterEvent("PLAYER_COMBO_POINTS")
	if playerClass == "WARRIOR" then
		self:RegisterBucketEvent("UNIT_RAGE",1)
	end
	if playerClass == "DRUID" then
		self:RegisterBucketEvent("UNIT_ENERGY",1)
	end
end

function DrDamage:Melee_OnProfileEnable()
	settings = self.db.profile
end

function DrDamage:Melee_Options()
	local table
	
	if playerHybrid then
		self.options.args.Melee = { type = "group", desc = "Melee Options", name = "Melee", order = 3, args = {} }
		table = self.options.args.Melee.args	
	else
		table = self.options.args
	end
	
	table.Calculation = {
		type = "group", desc = L["Calculation options"], name = L["Calculation"],
		args = {			
			HitCalc = {			
				type = 'toggle',
				name = L["+Hit calculation"],
				desc = L["Toggles +hit calculation effects into averages on/off"],
				order = 65,
				get = function() return settings["HitCalc_M"] end,
				set = DrD_Set("HitCalc_M"),
			},
			HitTarget = {			
				type = 'toggle',
				name = L["Hit calculation by target level"],
				desc = L["Toggles +hit calculation by target level."],
				order = 66,
				get = function() return settings["HitTarget_M"] end,
				set = DrD_Set("HitTarget_M"),
			},
			TargetLevel = {
				type = 'range',
				name = L["Manual target level setting"],
				desc = L["Manual set of target level compared to your level. Make sure 'HitTarget' is turned off to use this."],
				min = -10,
				max = 10,
				step = 1,
				order = 67,
				get = function() return settings["TargetLevel_M"] end,
				set = DrD_Set("TargetLevel_M"),
			},			
		},
	}
	table.ActionBar = {
		type = "group", desc = L["Options for the actionbar"], name = L["ActionBar"],
		args = {
			DisplayType = {
				type = "text",
				name = L["Display"],
				desc = L["Choose what to display on the actionbar"],
				validate =  { "AvgTotal", "Avg", "Min", "Max", "AvgCrit", "MinCrit", "MaxCrit", "DPM" },
				get =  function() return settings["DisplayType_M"] end,
				set =  DrD_Set("DisplayType_M"),
				order = 70,
			},
		},
	}
	table.Tooltip = {
		type = "group", desc = L["Options for the tooltips"], name = L["Tooltip"],
		args = {					
			Coeffs = {
				type = 'toggle',
				name = L["Show coefficients"],
				desc = L["Toggles displaying of calculation data"],
				order = 53,
				get = function() return settings["Coeffs_M"] end,
				set = DrD_Set("Coeffs_M", nil, true),
			},				
			DispCrit = {
				type = 'toggle',
				name = L["Show crit %"],
				desc = L["Toggles displaying of crit %"],
				order = 54,
				get = function() return settings["DispCrit_M"] end,
				set = DrD_Set("DispCrit_M", nil, true),
			},
			DispHit = {
				type = 'toggle',
				name = L["Show hit %"],
				desc = L["Toggles displaying of hit %."],
				order = 56,
				get = function() return settings["DispHit_M"] end,
				set = DrD_Set("DispHit_M", nil, true),
			},				
			AvgHit = {
				type = 'toggle',
				name = L["Show avg + hit range"],
				desc = L["Toggles displaying of avg hit"],
				order = 58,
				get = function() return settings["AvgHit_M"] end,
				set = DrD_Set("AvgHit_M", nil, true),
			},
			AvgCrit = {
				type = 'toggle',
				name = L["Show avg crit + crit range"],
				desc = L["Toggles displaying of avg crit"],
				order = 60,
				get = function() return settings["AvgCrit_M"] end,
				set = DrD_Set("AvgCrit_M", nil, true),
			},
			Ticks = {
				type = 'toggle',
				name = L["Show per tick/hit"],
				desc = L["Toggles displaying of per hit/tick values"],
				order = 62,
				get = function() return settings["Ticks_M"] end,
				set = DrD_Set("Ticks_M", nil, true),
			},
			Total = {
				type = 'toggle',
				name = L["Show avg total dmg/heal"],
				desc = L["Toggles displaying of average in total values"],
				order = 64,
				get = function() return settings["Total_M"] end,
				set = DrD_Set("Total_M", nil, true),
			},				
			Extra = {
				type = 'toggle',
				name = L["Show extra damage info (Windfury, Dual Attack)"],
				desc = L["Toggles displaying of extra info"],
				order = 66,
				get = function() return settings["Extra_M"] end,
				set = DrD_Set("Extra_M", nil, true),
			},
			Next = {
				type = 'toggle',
				name = L["Show next values (crit/hit/AP/dmg)"],
				desc = L["Toggles displaying of +1% crit, +1% hit, +100 AP values"],
				order = 68,
				get = function() return settings["Next_M"] end,
				set = DrD_Set("Next_M", nil, true),
			},
			DPS = {
				type = 'toggle',
				name = L["Show DPS"],
				desc = L["Toggles displaying of DPS where available"],
				order = 70,
				get = function() return settings["DPS_M"] end,
				set = DrD_Set("DPS_M", nil, true),
			},
			DPM = {
				type = 'toggle',
				name = L["Show damage per power"],
				desc = L["Toggles displaying of DPM/DPR/DPE"],
				order = 72,
				get = function() return settings["DPM_M"] end,
				set = DrD_Set("DPM_M", nil, true),
			},
		},
	}
end

function DrDamage:Melee_Data()
	self.spellInfo[((BS and BS["Attack"]) or "Attack")] = { 	
		[0] = { AutoAttack = true, Melee = true, WeaponDamage = 1, NoNormalization = true },
		["None"] = { 0 },
	}
	
	self.Calculation["Attack"] = function( calculation, _, BuffTalentRanks )
		local name, rank = SEA:GetPlayerMainHandItemBuff()
		if name == (BS and BS["Windfury"] or "Windfury") then
			local AP = rank and select(rank, 103, 221, 315, 433, 475) --46, 119, 249, 333, 445
			if AP then
				calculation.WindfuryBonus = AP 
				calculation.WindfuryAttacks = 2 * (BuffTalentRanks["Elemental Weapons"] and select(BuffTalentRanks["Elemental Weapons"], 1.13, 1.27, 1.4) or 1)
			end
		elseif name == (BS and BS["Windfury Totem"] or "Windfury Totem") then
			local AP = rank and select(rank, 103, 221, 315, 433, 475)
			if AP then
				calculation.WindfuryBonus = AP * (1 + (BuffTalentRanks["Improved Weapon Totems"] and BuffTalentRanks["Improved Weapon Totems"] * 0.15 or 0))
				calculation.WindfuryAttacks = 1				
			end
		end
		if OffhandHasWeapon() then
			local name, rank = SEA:GetPlayerOffHandItemBuff()
			if name == (BS and BS["Windfury"] or "Windfury") then
				local AP = rank and select(rank, 103, 221, 315, 433, 475) --46, 119, 249, 333, 445
				if AP then
					calculation.WindfuryBonus_O = AP 
					calculation.WindfuryAttacks_O = 2 * (BuffTalentRanks["Elemental Weapons"] and select(BuffTalentRanks["Elemental Weapons"], 1.13, 1.27, 1.4) or 1)
				end
			elseif name == (BS and BS["Windfury Totem"] or "Windfury Totem") then
				local AP = rank and select(rank, 122, 221, 315, 433, 475)
				if AP then
					calculation.WindfuryBonus_O = AP * (1 + (BuffTalentRanks["Improved Weapon Totems"] and BuffTalentRanks["Improved Weapon Totems"] * 0.15 or 0))
					calculation.WindfuryAttacks_O = 1
				end
			end			
		end
	end
end

local lastRage = 0
function DrDamage:UNIT_RAGE( units )
	for unit in pairs(units) do
		if UnitIsUnit(unit, "player") then
			if math_abs(UnitMana("player") - lastRage) >= 10 then
				lastRage = UnitMana("player")
				if not self:IsEventScheduled( "Rage_Update_AB" ) then
					self:ScheduleEvent("Rage_Update_AB", self.UpdateAB, 0.5, self, BS and BS["Execute"] or "Execute")
				end
			end
			return
		end
	end
end

local lastEnergy = 0
function DrDamage:UNIT_ENERGY( units )
	for unit in pairs(units) do
		if UnitIsUnit(unit, "player") then
			if UnitPowerType("player") == 3 and (math_abs(UnitMana("player") - lastEnergy) >= 20 or UnitMana("player") == 100 and lastEnergy ~= 100) then
				lastEnergy = UnitMana("player")
				self:CancelScheduledEvent( "UpdatingAB" )
				self:UpdateAB(BS and BS["Ferocious Bite"] or "Ferocious Bite")
			end
			return
		end
	end
end

local normalizationTable = {
	[BI["Daggers"]] = 1.7,
	[BI["One-Handed Axes"]] = 2.4,
	[BI["One-Handed Maces"]] = 2.4,
	[BI["One-Handed Swords"]] = 2.4,
	[BI["Fist Weapons"]] = 2.4,	
	[BI["Two-Handed Axes"]] = 3.3,
	[BI["Two-Handed Maces"]] = 3.3,
	[BI["Two-Handed Swords"]] = 3.3,	
	[BI["Polearms"]] = 3.3,
	[BI["Staves"]] = 3.3,
	[BI["Fishing Pole"]] = 3.3,
	["None"] = 2,
}

local oldValues = 0
function DrDamage:Melee_CheckBaseStats()
	local newValues = 
	GetCombatRatingBonus(6)
	+ GetCombatRatingBonus(7)
	+ GetCombatRatingBonus(18)
	+ GetCombatRatingBonus(19)	
	+ self:GetAP() 
	+ self:GetRAP() 
	+ GetCritChance()
	+ GetRangedCritChance()
	+ UnitDamage("player")
	+ select(3,UnitDamage("player"))
	+ UnitRangedDamage("player")
	+ select(2,UnitRangedDamage("player"))
	+ GetShieldBlock()

	if newValues ~= oldValues then
		oldValues = newValues
		return true
	end

	return false	
end

local mhSpeed, ohSpeed, rgSpeed
local rgMin, rgMax

function DrDamage:Melee_InventoryChanged()
	local update
	if playerHybrid then
		update = self:CheckRelicSlot()
	end
	if self:Melee_CheckBaseStats() then
		self:RefreshWeaponType()
	
		mhSpeed, ohSpeed = UnitAttackSpeed("player")
		rgSpeed = UnitRangedDamage("player")
		rgMin, rgMax = 0, 0

		if GT:SetInventoryItem("player", GetInventorySlotInfo("MainHandSlot")) then 
			for i = 3, GT:NumLines() do
				local line = GT:GetLine(i,true)
				line = line and tonumber(string_match(line,"%d+\.%d+"))			
				if line then
					mhSpeed = line
					break
				end
			end
		end
		if GT:SetInventoryItem("player", GetInventorySlotInfo("SecondaryHandSlot" )) then
			for i = 3, GT:NumLines() do
				local line = GT:GetLine(i,true)
				line = line and tonumber(string_match(line,"%d+\.%d+"))
				if line then
					ohSpeed = line
					break					
				end
			end
		end
		if GT:SetInventoryItem("player", GetInventorySlotInfo("RangedSlot")) then
			for i = 3, GT:NumLines() do
				local line = GT:GetLine(i,true)
				line = line and tonumber(string_match(line,"%d+\.%d+"))			
				if line then
					rgSpeed = line
					rgMin, rgMax = Deformat(GT:GetLine(i), DAMAGE_TEMPLATE)
					rgMin = (rgMin or 0)
					rgMax = (rgMax or 0)
					break
				end
			end
		end
		return true	
	end
	return update
end

function DrDamage:GetAP()
	local baseAP, posBuff, negBuff = UnitAttackPower("player")
	return baseAP + posBuff + negBuff
end

function DrDamage:GetRAP()
	local baseAP, posBuff, negBuff = UnitRangedAttackPower("player")
	return baseAP + posBuff + negBuff	
end

local mhType, ohType, rgType
function DrDamage:GetWeaponType()
	return mhType, ohType, rgType
end

function DrDamage:RefreshWeaponType()
	mhType, ohType, rgType = "None", "None", "None"
	local mh = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
	if mh then mhType = select(7,GetItemInfo(mh)) or "None" end
	local oh = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
	if oh and OffhandHasWeapon() then ohType = select(7,GetItemInfo(oh)) or "None" end
	local rg = GetInventoryItemLink("player", GetInventorySlotInfo("RangedSlot"))
	if rg then rgType = select(7,GetItemInfo(rg)) or "None" end
end

function DrDamage:GetRangedBase()
	return rgMin, rgMax
end

function DrDamage:GetWeaponSpeed()
	return mhSpeed, ohSpeed, rgSpeed
end

function DrDamage:GetNormM() 
	return normalizationTable[mhType] or 2.4, normalizationTable[ohType] or 2.4
end

function DrDamage:WeaponDamage(AP, wspd, ranged, requiresForm, offMod)
	local min, max, omin, omax, mod
	local spd, normM, normM_O
	local mh, oh = self:GetNormM()
	local baseAP
	
	if ranged then
		_, min, max, _, _, mod = UnitRangedDamage("player")
		spd = rgSpeed
		normM = wspd and spd or 2.8
		baseAP = self:GetRAP()
	else
		min, max, omin, omax, _, _, mod = UnitDamage("player")
		baseAP = self:GetAP()
		
		if requiresForm then
			if requiresForm == 1 then
				spd = 2.5
				normM = 2.5
			elseif requiresForm == 3 then
				spd = 1
				normM = 1
			end
		else
			spd = mhSpeed
			normM = wspd and mhSpeed or mh
			normM_O = wspd and ohSpeed or oh
		end
	end
	
	min = min/mod - (baseAP / 14) * spd + (AP / 14) * normM
	max = max/mod - (baseAP / 14) * spd + (AP / 14) * normM
	
	if OffhandHasWeapon() and omin and omax and ohSpeed then
		omin = omin/((offMod or 0.5) * mod) - (baseAP / 14) * ohSpeed + (AP / 14) * normM_O
		omax = omax/((offMod or 0.5) * mod) - (baseAP / 14) * ohSpeed + (AP / 14) * normM_O
	end
	
	return min, max, omin, omax
end

function DrDamage:GetRageGain( avg, calculation )
    	local level = UnitLevel("player")
    	if level >= 60 then
		local avgFactor = 3.5 + 3.5 * (calculation.critPerc/100)
		local conversion = 230.6 + (level-60) * ((274.6-230.6)/10)
		local rage = (avg / conversion * 7.5 + (mhSpeed * avgFactor))/2
		return rage
	else
		return 0
	end
end

local weaponSkill = { 
	[0] = 0, 
	[1] = 0.1, 
	[2] = 0.2, 
	[3] = 0.3, 
	[4] = 0.4,
	[5] = 0.5,
	[6] = 0.6,
	[7] = 0.7,
	[8] = 0.8,
	[9] = 0.9,
	[10] = 1.0,
	[11] = 2.4,
	[12] = 2.8,
	[13] = 3.2,
	[14] = 3.6,
	[15] = 4.0,
}

local levelHit = {
	[1] = 0.5,
	[2] = 1,
	[3] = 4,
}
	
local function DrD_GetMeleeHit(ranged, skill, skillO)
	local bonus
	if ranged then
		bonus = GetCombatRatingBonus(7)
	else
		bonus = GetCombatRatingBonus(6)
	end
	
	local skillBonus = 0
	local skillBonusO = 0
	
	local lvlDiff, playerLevel, targetLevel = DrDamage:GetLevels()
	
	if UnitName("target") or not settings.HitTarget_M then
		if not settings.HitTarget_M then
			targetLevel = playerLevel + settings.TargetLevel_M
		end
	
		local dSkill = targetLevel * 5 - skill
		local dSkillO = targetLevel * 5 - (skillO or playerLevel * 5)
		
		if UnitIsPlayer("target") then
			if lvlDiff > 0 then
				if lvlDiff <= 3 then
					bonus = bonus - levelHit[lvlDiff]
				else
					bonus = bonus - 4 - (lvlDiff - 3) * 3
				end
			end
		else
			if dSkill > 0 then
				if dSkill <= 15 then
					skillBonus = weaponSkill[dSkill] 
				else
					skillBonus = 4 + (dSkill - 15) * 0.4
				end
			end
			if dSkillO > 0 then
				if dSkillO <= 15 then
					skillBonusO = weaponSkill[dSkillO]
				else
					skillBonusO = 4 + (dSkillO - 15) * 0.4
				end
			end
		end
	end
	
	local hit = 95 + bonus - skillBonus
	local hitDW = 76 + bonus - skillBonus
	local hitDWO = 76 + bonus - skillBonusO
	
	return hit, hitDW - hit, hitDWO - hit
end

local powerTypes = { [0] = "Mana", [1] = "Rage", [2] = "Focus", [3] = "Energy", [4] = "Happiness" }

local ActiveAuras = {}
local BuffTalentRanks = {}
local CalculationResults = {}

local calculation = {}
local CalculationResults = {}

local DrD_DmgCalc, DrD_TalentCalc, DrD_BuffCalc

function DrDamage:MeleeCalc( action, lActionName, tooltip, powerCalc )
	if not action or not lActionName then
		do return end
	end
	
	local actionName = lActionName
	
	if BS and BS:HasReverseTranslation(actionName) then
		actionName = BS:GetReverseTranslation(actionName)
	end
	
	local baseAction = self.spellInfo[lActionName][0]
	calculation.offHdmgM = 0.5
	calculation.bDmgM = 1
	calculation.eDuration = action.eDuration or baseAction.eDuration or 0
	calculation.WeaponDamage = action.WeaponDamage or baseAction.WeaponDamage
	calculation.actionCost = baseAction.Energy or baseAction.Rage
	calculation.critM = 1
	calculation.cooldown = baseAction.Cooldown or 0
	calculation.castTime = action.castTime or baseAction.castTime
	calculation.baseBonus = 0
	calculation.extraDamBonus = 0
	calculation.requiresForm = baseAction.RequiresForm
	calculation.spellDmg = 0
	
	if not calculation.castTime then
		if baseAction.NextMelee then
			calculation.castTime = mhSpeed
		elseif playerClass == "ROGUE" or playerClass == "DRUID" and GetShapeshiftForm() == 3 then
			calculation.castTime = 1
		else
			calculation.castTime = 1.5
		end
	end
	
	if baseAction.Energy then
		calculation.powerType = 3
	elseif baseAction.Rage then
		calculation.powerType = 1
	else
		calculation.powerType = 0
	end
	
	if type( baseAction.School ) == "table" then
		calculation.actionSchool = baseAction.School[1]
		calculation.actionType = baseAction.School[2]
	else
		calculation.actionSchool = baseAction.School or "Physical"	
	end
	 
	if calculation.actionSchool == "Ranged" then
		calculation.ranged = true
		calculation.AP = self:GetRAP()
		calculation.critPerc = GetRangedCritChance()
		calculation.haste = GetCombatRatingBonus(18)
		calculation.dmgM = select(6,UnitRangedDamage("player"))
		local skill, bonus = UnitRangedAttack("player")
		calculation.skillMain = skill + bonus
		if baseAction.AutoShot then
			calculation.castTime = UnitRangedDamage("player")
		end
	else
		calculation.AP = self:GetAP()
		calculation.critPerc = GetCritChance()
		calculation.haste = GetCombatRatingBonus(19)
		calculation.dmgM = select(7,UnitDamage("player"))
		local skill, bonus, skillO, bonusO = UnitAttackBothHands("player")
		calculation.skillMain, calculation.skillOff = skill + bonus, skillO + bonusO
	end
	
	--[[	Is this correct? Removed for now.
	if calculation.skillMain then
		local _, playerLevel, targetLevel = self:GetLevels()
		calculation.critPerc = calculation.critPerc + 0.4 * math_max(0, calculation.skillMain - playerLevel * 5)
		if targetLevel == 73 then
			calculation.critPerc = calculation.critPerc + 1 * math_max(0, calculation.skillMain - playerLevel * 5)
		end
	end
	--]]
	
	if calculation.haste == 0 then calculation.haste = 1 end
	calculation.hitPerc, calculation.hitDW, calculation.hitDWO = DrD_GetMeleeHit(calculation.ranged, calculation.skillMain, calculation.skillOff)
	
	calculation.minDam = action[1]
	calculation.maxDam = (action[2] or action[1])
	
	if self.RelicSlot then
		if self.RelicSlot[actionName] then
			local data = self.RelicSlot[actionName]
			local count = #data
			if count then
				for i = 1, count - 1, 2 do
					if data[i] and data[i+1] then
						if IsEquippedItem(data[i]) then
							local modType = data["ModType"..((i+1)/2)]
							if not modType then
								calculation.minDam = calculation.minDam + data[i+1]
								calculation.maxDam = calculation.maxDam + data[i+1]
							end
						end
					end
				end
			end
		end
	end	
	
	--Apply talents		
	for talentName, talentRank in pairs(self.talents) do						
		local talentTable = self.talentInfo[talentName]
		
		for i = 1, #talentTable do
			local talent = talentTable[i]	

			if not talent.Caster and not (baseAction.AutoAttack and talent.Specials) then 
				if DrD_MatchData(talent.Spells, actionName, calculation.actionTypeType) or DrD_MatchData(talent.Spells, "All", calculation.actionSchool) then		
					DrD_TalentCalc(baseAction, talentName, talentRank, talent)
				end
			end
		end
	end
	
	for buffName, index, apps, texture, rank in SEA:BuffIter("player") do
		if BS and BS:HasReverseTranslation(buffName) then
			buffName = BS:GetReverseTranslation(buffName)
		end		

		if self.PlayerAura[buffName] then
			local buffData = self.PlayerAura[buffName]
			
			if not buffData.Caster then
				if DrD_MatchData(buffData.School, calculation.actionSchool) and not baseAction.NoSchoolBuffs
				or not buffData.School and not buffData.Spell
				or DrD_MatchData( buffData.Spell, lActionName )
				or DrD_MatchData( buffData.School, calculation.actionType ) then
					if buffData.ModType == "Special" and self.Calculation[buffName] then
						self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
					else
						DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, "player", false, baseAction )
					end				
				end
			end
		end		
	end
	for buffName, apps, _, texture, rank, index in SEA:DebuffIter("player") do
		if BS and BS:HasReverseTranslation(buffName) then
			buffName = BS:GetReverseTranslation(buffName)
		end		

		if self.PlayerAura[buffName] then
			local buffData = self.PlayerAura[buffName]
			
			if not buffData.Caster then
				if DrD_MatchData( buffData.School, calculation.actionSchool ) 
				or not buffData.School and not buffData.Spell					
				or DrD_MatchData( buffData.Spell, lActionName ) then	
					if buffData.ModType == "Special" and self.Calculation[buffName] then
						self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
					else
						DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, "player", true, baseAction )
					end
				end
			end
		end
	end	
	for buffName, apps, _, texture, rank, index in SEA:DebuffIter("target") do
		if BS and BS:HasReverseTranslation(buffName) then
			buffName = BS:GetReverseTranslation(buffName)
		end

		if self.Debuffs[buffName] then
			local buffData = self.Debuffs[buffName]			

			if not buffData.Caster then
				if DrD_MatchData( buffData.School, calculation.actionSchool ) and not baseAction.NoSchoolBuffs
				or not buffData.School and not buffData.Spell
				or DrD_MatchData( buffData.School, calculation.actionType )
				or DrD_MatchData( buffData.Spell, lActionName ) then
					if buffData.ModType == "Special" and self.Calculation[buffName] then
						self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
					else
						DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, "target", true, baseAction )
					end
				end
			end
		end
	end
	
	if self.SetBonuses[playerClass] then
		self.SetBonuses[playerClass]( calculation, ActiveAuras )
	end		
	if self.Calculation[playerClass] then
		self.Calculation[playerClass]( calculation, ActiveAuras, BuffTalentRanks )
	end
	if self.SetBonuses[actionName] then
		self.SetBonuses[actionName]( calculation, ActiveAuras )
	end
	if self.Calculation[actionName] then
		self.Calculation[actionName]( calculation, ActiveAuras, BuffTalentRanks, action )
	end
	
	if baseAction.DualAttack and OffhandHasWeapon() then
		calculation.bDmgM = calculation.bDmgM * 2
	end
	
	local avgTotal, text = DrD_DmgCalc( actionName, baseAction, action, false, false, tooltip, powerCalc )
	
	if tooltip then
		if not baseAction.NoCrits then
			calculation.critPerc = calculation.critPerc + 1
			CalculationResults.NextCrit = DrD_Round( DrD_DmgCalc( actionName, baseAction, action, true ) - avgTotal, 2 )
			calculation.critPerc = calculation.critPerc - 1	
		end
		if baseAction.APBonus or baseAction.WeaponDamage or baseAction.APGain then
			calculation.AP = calculation.AP + 100
			CalculationResults.NextAP = DrD_Round( DrD_DmgCalc( actionName, baseAction, action, true ) - avgTotal, 2 )
			calculation.AP = calculation.AP - 100
		end
		if baseAction.SpellDmgBonus then
			calculation.spellDmg = calculation.spellDmg + 10
			CalculationResults.NextSpellDmg = DrD_Round( DrD_DmgCalc( actionName, baseAction, action, true ) - avgTotal, 2 )
			calculation.spellDmg = calculation.spellDmg - 10
		end
		if not baseAction.Unresistable then
			local temp

			if settings.HitCalc_M then
				temp = avgTotal
			else
				temp = DrD_DmgCalc( actionName, baseAction, action, true, true )
			end

			calculation.hitPerc = calculation.hitPerc + 1
			CalculationResults.NextHit = DrD_Round( DrD_DmgCalc( actionName, baseAction, action, true, true ) - temp, 2 )
		end			
	end	
	
	DrD_ClearTable( BuffTalentRanks )
	DrD_ClearTable( ActiveAuras )	
	DrD_ClearTable( calculation )
	
	return text, CalculationResults
end

DrD_DmgCalc = function( actionName, baseAction, action, nextCalc, hitCalc, tooltip, powerCalc )

	if DrDamage.DmgCalculation[actionName] then
		DrDamage.DmgCalculation[actionName]( calculation, ActiveAuras, BuffTalentRanks, action )
	end

	--Calculation
	local minDam = calculation.minDam * calculation.bDmgM
	local maxDam = calculation.maxDam * calculation.bDmgM
	local minDam_O, maxDam_O
	local minCrit, maxCrit
	local minCrit_O, maxCrit_O	
	local avgHit, avgHit_O
	local avgCrit,avgCrit_O
	local avgTotal
	local avgTotal_O = 0
	local eDuration = calculation.eDuration
	local hitPerc, hitPercDW, hitPercDWO = math_min(100,calculation.hitPerc), math_min(100,calculation.hitPerc + calculation.hitDW), math_min(100,calculation.hitPerc + calculation.hitDWO)
	local hits = baseAction.Hits or calculation.Hits
	local perHit
	
	calculation.trueTotal = 0
	calculation.trueDPS = 0
	
	if calculation.WeaponDamage then
		local min, max, min_O, max_O = DrDamage:WeaponDamage( calculation.AP, baseAction.NoNormalization, calculation.ranged, calculation.requiresForm, calculation.offHdmgM )
		minDam = minDam + (min + calculation.baseBonus) * calculation.WeaponDamage
		maxDam = maxDam + (max + calculation.baseBonus) * calculation.WeaponDamage
		minDam_O = min_O
		maxDam_O = max_O
	end
	if OffhandHasWeapon() then
		if (baseAction.AutoAttack or baseAction.DualAttack or baseAction.OffhandAttack) then
			minDam_O = (minDam_O + calculation.baseBonus) * calculation.WeaponDamage * calculation.offHdmgM
			maxDam_O = (maxDam_O + calculation.baseBonus) * calculation.WeaponDamage * calculation.offHdmgM
			if baseAction.OffhandAttack then
				minDam = minDam_O
				maxDam = maxDam_O
				minDam_O = nil
				maxDam_O = nil
			end
		end
	end
	
	if baseAction.ComboPoints then
		local cp = GetComboPoints()
		
		if cp > 0 then
			if action.PerCombo then
				minDam = minDam + action.PerCombo * ( cp - 1 )
				maxDam = maxDam + action.PerCombo * ( cp - 1 )
			end
			if baseAction.ExtraPerCombo then
				minDam = minDam + action.Extra * baseAction.ExtraPerCombo[cp]
				maxDam = maxDam + action.Extra * baseAction.ExtraPerCombo[cp]
			end
			if baseAction.APBonus then
				if type( baseAction.APBonus ) == "table" then
					minDam = minDam + baseAction.APBonus[cp] * calculation.AP
					maxDam = maxDam + baseAction.APBonus[cp] * calculation.AP
				else
					minDam = minDam + baseAction.APBonus * cp * calculation.AP
					maxDam = maxDam + baseAction.APBonus * cp * calculation.AP
				end
			end
			if baseAction.DurationPerCombo then
				eDuration = calculation.eDuration + baseAction.DurationPerCombo * cp
			end
		else
			calculation.zero = true
		end
	else
		if baseAction.APBonus then
			minDam = minDam + baseAction.APBonus * calculation.AP
			maxDam = maxDam + baseAction.APBonus * calculation.AP		
		end
	end
	
	if action.PowerBonus and calculation.powerType == UnitPowerType("player") then
		minDam = minDam + math_max(0, (UnitMana("player") - calculation.actionCost) * action.PowerBonus)
		maxDam = maxDam + math_max(0, (UnitMana("player") - calculation.actionCost) * action.PowerBonus)
		calculation.actionCost = math_max( UnitMana("player"), calculation.actionCost )
	end	
	
	minDam = calculation.dmgM * minDam
	maxDam = calculation.dmgM * maxDam
	
	if baseAction.Weapon and BI[baseAction.Weapon] ~= mhType
	or calculation.actionSchool == "Ranged" and rgType == "None"
	or calculation.actionSchool == "Physical" and mhType == "None" and not baseAction.AutoAttack and not baseAction.NoWeapon
	or calculation.zero then
		minDam = 0
		maxDam = 0
	end
	
	avgHit = ((minDam + maxDam) / 2)
	
	if calculation.critPerc > 100 then
		calculation.critPerc = 100
	end	
	
	local critBonus = 0
	local critBonus_O = 0
	
	if not baseAction.NoCrits then
		minCrit = minDam + minDam * calculation.critM
		maxCrit = maxDam + maxDam * calculation.critM
		avgCrit = (minCrit + maxCrit) / 2
		critBonus = (calculation.critPerc / 100) * avgHit * calculation.critM
		avgTotal = avgHit + critBonus
	else
		avgTotal = avgHit
	end
	
	if (baseAction.DualAttack or baseAction.AutoAttack) and OffhandHasWeapon() then
		if baseAction.AutoAttack then
			hitPerc = hitPercDW
		end
		
		minDam_O = calculation.dmgM * minDam_O
		maxDam_O = calculation.dmgM * maxDam_O		

		avgHit_O = (minDam_O + maxDam_O)/2
		minCrit_O = minDam_O + minDam_O * calculation.critM
		maxCrit_O = maxDam_O + maxDam_O * calculation.critM
		avgCrit_O = (minCrit_O + maxCrit_O) / 2
		critBonus_O = (calculation.critPerc / 100) * avgHit_O * calculation.critM
		avgTotal_O = avgHit_O + critBonus_O
	end
	
	local extraDam
	local extraDPS = 0
	
	if baseAction.ExtraDamage then
		extraDam = (action.Extra + baseAction.ExtraDamage * calculation.AP) * calculation.dmgM + calculation.extraDamBonus
		avgTotal = avgTotal + extraDam
		extraDPS = extraDam / (baseAction.E_eDuration or baseAction.castTime)
	end
	
	if hits then perHit = avgTotal end
	
	local baseAttack, avgTotalMod
	if baseAction.NextMelee then
		if baseAction.WeaponDamage then
			local min, max = DrDamage:WeaponDamage( calculation.AP, baseAction.NoNormalization, false, calculation.requiresForm, calculation.offHdmgM )
			baseAttack = (calculation.dmgM * baseAction.WeaponDamage*(min+max+calculation.baseBonus)/2)
			avgTotalMod = avgTotal - critBonus - baseAttack
			avgTotalMod = avgTotalMod + avgTotalMod * (calculation.critPerc / 100) * calculation.critM
		end
	end
	
	if hits then
		avgTotal = avgTotal + (hits - 1) * perHit
	end	
	
	if not baseAction.Unresistable then
		if settings.HitCalc_M or hitCalc then
			if baseAction.NextMelee and avgTotalMod then
				avgTotalMod = (avgTotalMod - avgTotalMod * (calculation.critPerc / 100) * calculation.critM) * (hitPerc / 100) + avgTotalMod * (calculation.critPerc / 100) * calculation.critM
			elseif baseAction.AutoAttack or baseAction.AutoShot then
				avgTotal = (avgTotal - critBonus) * (hitPerc / 100) + critBonus
			else
				avgTotal = avgTotal * (hitPerc / 100)
			end
			if OffhandHasWeapon() then
				if baseAction.AutoAttack then
					avgTotal_O = ( avgTotal_O - critBonus_O ) * (hitPercDWO / 100) + critBonus_O
				elseif baseAction.DualAttack then
					avgTotal_O = avgTotal_O * (hitPerc / 100)
				end
			end
		end
	end	
	
	local avgCombined = (avgTotalMod or avgTotal) + avgTotal_O
	local DPS, DPSCD, avgWf, avgWf_O, avgTotalWf, avgTotalWf_O

	if baseAction.AutoShot then
		DPS = avgTotal / math_max(0.5, (UnitRangedDamage("player")))
	elseif baseAction.AutoAttack or baseAction.WeaponDPS then
		local spd, ospd = UnitAttackSpeed("player")
		
		if hits then DPS = (avgTotal / (hits - 1)) / spd 
		else DPS = avgTotal /spd end
		
		if ospd then
			DPS = DPS + avgTotal_O / ospd
		end
	elseif baseAction.DPSrg then
		DPS = avgTotal / (UnitRangedDamage("player"))
	else
		if eDuration > 0 then
			DPS = avgCombined / eDuration + extraDPS
		end
		if calculation.cooldown > 0 then
			DPSCD = DrD_Round(avgCombined / calculation.cooldown,1)
		end
		if baseAction.SpamDPS then
			DPS = avgCombined / baseAction.SpamDPS
		end
	end
	
	--calculation.trueDPS = calculation.trueDPS + (DPS or 0)
	
	if baseAction.AutoAttack then
		if calculation.WindfuryBonus then
			local min, max = DrDamage:WeaponDamage(calculation.AP, true, nil, nil, calculation.offHdmgM)
			avgWf = calculation.dmgM * calculation.WindfuryAttacks * ((min+max)/2 + calculation.WindfuryBonus/14)

			avgTotalWf = (hitPerc / 100) * (avgWf + avgWf * calculation.critM * calculation.critPerc/100)
			avgCombined = avgCombined + avgTotalWf
		end
		if calculation.WindfuryBonus_O then
			local _, _, min, max = DrDamage:WeaponDamage(calculation.AP, true, nil, nil, calculation.offHdmgM)
			avgWf_O = calculation.dmgM * calculation.WindfuryAttacks_O * calculation.offHdmgM * ((min+max)/2 + calculation.WindfuryBonus_O/14)

			avgTotalWf_O = (hitPerc / 100) * (avgWf_O + avgWf_O * calculation.critM * calculation.critPerc/100)
			avgCombined = avgCombined + avgTotalWf_O	
		end
		--model 3s cd effects later more accurately?
		if avgTotalWf or avgTotalWf_O then
			local pcm, pco
			local spd, ospd = UnitAttackSpeed("player")

			if calculation.WindfuryAttacks and calculation.WindfuryAttacks >= 2 then
				pcm = 0.2 - math_min(0.1,math_max(0,(3-spd) * 0.064))
			end
			if calculation.WindfuryAttacks_O and calculation.WindfuryAttacks_O >= 2 then
				pco = 0.2 - math_min(0.1,math_max(0,(3-ospd) * 0.064))
			end
			if pcm and pco then
				local mlt = 1 - pcm * pco * math_min(1,3/spd) * math_min(1,3/ospd)
				pcm = mlt * pcm
				pco = mlt * pco
			end
			pcm = pcm or 0.2
			pco = pco or 0.2
			if avgTotalWf then
				calculation.trueDPS = calculation.trueDPS + (avgTotalWf * math_min(20,(60/spd) * (hitPerc / 100) * pcm))/60
			end
			if avgTotalWf_O then
				calculation.trueDPS = calculation.trueDPS + (avgTotalWf_O * math_min(20,(60/ospd) * (hitPercDWO / 100) * pco))/60
			end
		end
	end
	
	if DrDamage.FinalCalculation[actionName] then
		DrDamage.DmgCalculation[actionName]( calculation, BuffTalentRanks )
	end
	
	--temp
	if DPS then
		DPS = DPS + calculation.trueDPS
	end

	if not nextCalc then
		DrD_ClearTable( CalculationResults )
	
		CalculationResults.Avg = 	math_floor(avgHit + 0.5)
		CalculationResults.AvgTotal = 	math_floor(avgTotal + 0.5)
		CalculationResults.Min = 	math_floor(minDam)
		CalculationResults.Max = 	math_ceil(maxDam)

		if not baseAction.NoCrits then
			CalculationResults.AvgCrit = 	math_floor(avgCrit + 0.5)
			CalculationResults.MinCrit = 	math_floor(minCrit)
			CalculationResults.MaxCrit = 	math_ceil(maxCrit)
		else
			CalculationResults.AvgCrit = 	CalculationResults.Avg
			CalculationResults.MinCrit = 	CalculationResults.Min
			CalculationResults.MaxCrit = 	CalculationResults.Max		
		end

		if powerCalc or settings.DisplayType_M == "DPM" then
			CalculationResults.PowerType = calculation.powerType

			if not calculation.actionCost then 
				local manaCost
				if GT:GetLine(2) and Mana_Cost then
					manaCost = Deformat(GT:GetLine(2), Mana_Cost)
				end

				if manaCost then
					manaCost = tonumber(manaCost)
					if manaCost == 0 then
						CalculationResults.DPM = "\226\136\158"
					else
						CalculationResults.DPM = DrD_Round((avgTotalMod or avgTotal) / manaCost, 1 )
					end
				end
			else
				if baseAttack and calculation.powerType == 1 then
					calculation.actionCost = calculation.actionCost + DrDamage:GetRageGain(baseAttack, calculation)
				end
				if calculation.actionCost <= 0 then
					CalculationResults.DPM = "\226\136\158"
				else
					CalculationResults.DPM = DrD_Round((avgTotalMod or avgTotal) / calculation.actionCost, 1)
				end
			end
		end
		if tooltip then
			CalculationResults.Hit = 	DrD_Round(hitPerc, 2)
			CalculationResults.Crit = 	not baseAction.NoCrits and DrD_Round(calculation.critPerc, 2)
			CalculationResults.DmgM = 	DrD_Round(calculation.dmgM, 2 )
			CalculationResults.AP = 	calculation.AP		

			CalculationResults.Ranged =	calculation.ranged

			if DPS then
				CalculationResults.DPS = DrD_Round(DPS,1)
			end
			if DPSCD then
				CalculationResults.DPSCD = DPSCD
			end

			if avgHit_O then
				CalculationResults.AvgO = 	math_floor(avgHit_O + 0.5)
				CalculationResults.MinO = 	math_floor(minDam_O)
				CalculationResults.MaxO = 	math_ceil(maxDam_O)
				if baseAction.AutoAttack then
					CalculationResults.HitO =	DrD_Round(hitPercDWO, 2)
				else
					CalculationResults.HitO =	DrD_Round(hitPerc, 2)
				end

				CalculationResults.MinCritO = 	math_floor(minCrit_O)
				CalculationResults.MaxCritO = 	math_ceil(maxCrit_O)
				CalculationResults.AvgCritO = 	math_floor(avgCrit_O + 0.5)
				CalculationResults.AvgTotalO =  math_floor(avgTotal_O + 0.5)
			end

			if extraDam then
				CalculationResults.Extra = 	math_floor(extraDam + 0.5)
			end

			if avgWf then
				CalculationResults.WindfuryAvg = math_floor(avgWf + 0.5)
				CalculationResults.WindfuryAvgTotal = math_floor(avgTotalWf + 0.5)		
			end
			if avgWf_O then
				CalculationResults.WindfuryAvg_O = math_floor(avgWf_O + 0.5)
				CalculationResults.WindfuryAvgTotal_O = math_floor(avgTotalWf_O + 0.5)
			end

			if calculation.spellDmg > 0 then CalculationResults.SpellDmg = calculation.spellDmg end
			if perHit then
				CalculationResults.Hits = 	hits
				CalculationResults.PerHit =	DrD_Round(perHit, 1)
			end

			CalculationResults.AvgCombined = math_floor( avgCombined + 0.5 )
		end
	end
	
	return avgCombined, CalculationResults[settings.DisplayType_M], CalculationResults
end

DrD_TalentCalc = function( baseAction, talentName, talentRank, talent )
	local modType = talent.ModType
	local talentValue

	if type( talent.Effect ) == "table" then
		talentValue = talent.Effect[talentRank]
	else
		talentValue = talent.Effect * talentRank
	end		

	if not modType then
		calculation.dmgM = calculation.dmgM * (1 + talentValue)	
	elseif modType == "Crit" then
		calculation.critPerc = calculation.critPerc + talentValue
	elseif modType == "Hit" then
		calculation.hitPerc = calculation.hitPerc + talentValue
	elseif modType == "BaseDamage" then
		calculation.bDmgM = calculation.bDmgM * (1 + talentValue )
	elseif modType == "Offhand" then
		calculation.offHdmgM = calculation.offHdmgM * (1 + talentValue)
	elseif modType == "PowerCost" then
		if calculation.actionCost then
			calculation.actionCost = calculation.actionCost - talentValue
		end
	elseif modType == "CritMultiplier" then
		calculation.critM = calculation.critM + talentValue
	elseif modType == "SpellDuration" then
		calculation.eDuration = calculation.eDuration + talentValue
	elseif modType == "Cooldown" then
		calculation.cooldown = calculation.cooldown - talentValue	
	elseif modType == "BuffTalentRanks" then
		BuffTalentRanks[talentName] = talentValue
	end

	if modType then
		if DrDamage.Calculation[modType] then DrDamage.Calculation[modType]( calculation, talentValue ) end
	end				
end

DrD_BuffCalc = function( bName, bData, index, apps, texture, rank, target, debuff, baseAction )
	local modType = bData.ModType
	
	if bData.ActiveAura then
		local write
		
		if bData.SelfCast then
			if debuff and select(7,UnitDebuff(target,index)) then
				write = true
			elseif not debuff and select(6,UnitBuff(target,index)) then
				write = true
			end
		end
		if not bData.SelfCast or write then
			if apps and apps > 0 then
				ActiveAuras[bName] = apps
			else
				ActiveAuras[bName] = ( ActiveAuras[bName] or 0 ) + 1
			end
		end
		if modType == "ActiveAura" then return end
	end

	if not bData.Value then return end

	if bData.Ranks then
		if rank then
			rank = tonumber(string_match(rank,"%d+"))
		end
		if not rank then
			rank = bData.Ranks
		end

		if not modType then
			calculation.dmgM = calculation.dmgM * ( 1 + rank * bData.Value )			
		elseif modType == "BaseBonus" then
			calculation.baseBonus = calculation.baseBonus + bData.Value[rank]
		end
	--[[
	elseif bData.Apps then
		if apps and apps > 0 then
			if modType == "Crit" then
				calculation.critPerc = calculation.critPerc + apps * bData.Value
			elseif modType == "BaseDamage" then
				calculation.bDmgM = calculation.bDmgM + apps * bData.Value
			elseif modType == "CastTime" then
				if bData.Value < 0 then
					calculation.castTime = calculation.castTime + apps * bData.Value
				end
			elseif not modType then
				calculation.dmgM = calculation.dmgM * ( 1 + apps * bData.Value )		
			end
		end
	elseif bData.Texture and texture and string.find( texture, bData.Texture ) then
		calculation.dmgM = calculation.dmgM * ( 1 + bData.Value )
	--]]
	elseif modType == "CastTime" then
		if bData.Value < 0 then
			calculation.castTime = calculation.castTime + bData.Value
		else
			if baseAction.NextMelee or baseAction.AutoAttack or baseAction.AutoShot then
				calculation.castTime = calculation.castTime / bData.Value
			end
		end
	elseif modType == "BaseDamage" then
		calculation.bDmgM = calculation.bDmgM + bData.Value
	elseif modType == "Crit" then
		calculation.critPerc = calculation.critPerc + bData.Value
	elseif modType == "Hit" then
		calculation.hitPerc = calculation.hitPerc + bData.Value
	elseif not modType then
		calculation.dmgM = calculation.dmgM * ( 1 + bData.Value )
	end
end

function DrDamage:MeleeTooltip( frame, spellName, baseSpell, tableSpell )

	self:MeleeCalc(tableSpell, spellName, true, true)
	frame:AddLine(" ")
	
	if CalculationResults.Name then
		frame:AddLine( CalculationResults.Name, 1, 1, 1 )
		frame:AddLine(" ")
	end	

	local r, g, b = 1, 0.82745098, 0

	if not settings.DefaultColor then
		r, g, b = 0, 0.7, 0
	end

	if settings.Coeffs_M then
		frame:AddDoubleLine(L["Coeffs:"], CalculationResults.DmgM .. "/" .. CalculationResults.AP .. (CalculationResults.SpellDmg and ("/" .. CalculationResults.SpellDmg) or ""), 1, 1, 1, r, g, b  )
	end

	if settings.DispCrit_M and CalculationResults.Crit then
		frame:AddDoubleLine(L["Crit:"], CalculationResults.Crit .. "%", 1, 1, 1, r, g, b )
	end

	if settings.DispHit_M and not baseSpell.Unresistable then
		frame:AddDoubleLine(L["Hit:"], CalculationResults.Hit .. "%", 1, 1, 1, r, g, b )
		if CalculationResults.HitO then
			frame:AddDoubleLine("Off-Hand " .. L["Hit:"], CalculationResults.HitO .. "%", 1, 1, 1, r, g, b )
		end
	end  				

	if not settings.DefaultColor then
		r, g, b = 0.8, 0.8, 0.9
	end
	
	if settings.AvgHit_M or settings.AvgCrit_M then
		if CalculationResults.AvgO then
			frame:AddLine("Main Hand:")
		end
	end
	if settings.AvgHit_M then
		frame:AddDoubleLine(L["Avg:"], CalculationResults.Avg .. " (".. CalculationResults.Min .."-".. CalculationResults.Max ..")", 1, 1, 1, r, g, b )
	end
	if settings.AvgCrit_M and not baseSpell.NoCrits and CalculationResults.AvgCrit then
		frame:AddDoubleLine(L["Avg Crit:"], CalculationResults.AvgCrit .. " (".. CalculationResults.MinCrit .."-".. CalculationResults.MaxCrit ..")", 1, 1, 1, r, g, b )
	end
	
	if settings.Extra_M then
		if CalculationResults.Extra then
			frame:AddDoubleLine("Additional:", CalculationResults.Extra, 1, 1, 1, r, g, b)
		end
		if CalculationResults.WindfuryAvg then
			frame:AddDoubleLine("Windfury Avg/Total:", CalculationResults.WindfuryAvg .. "/" .. CalculationResults.WindfuryAvgTotal, 1, 1, 1, r, g, b)
		end
	end
	
	if CalculationResults.Hits and CalculationResults.PerHit and settings.Ticks_M then
		frame:AddDoubleLine(L["Hits:"], CalculationResults.Hits .. "x ~" .. CalculationResults.PerHit .. ((baseSpell.PPM and (" (" .. baseSpell.PPM .. " PPM)")) or ""), 1, 1, 1, r, g, b ) 
	end
	
	if settings.Total_M and CalculationResults.AvgTotal then -- and CalculationResults.AvgTotal > CalculationResults.Avg then
		frame:AddDoubleLine(L["Avg Total:"], CalculationResults.AvgTotal, 1, 1, 1, r, g, b)
	end	
	
	if CalculationResults.AvgO and (settings.AvgHit_M or settings.AvgCrit_M) then
		frame:AddLine("Off Hand:")
	end	
	
	if baseSpell.DualAttack and settings.Extra_M or baseSpell.AutoAttack then
		if CalculationResults.AvgO then
			if settings.AvgHit_M then
				frame:AddDoubleLine(L["Avg:"], CalculationResults.AvgO .. " (".. CalculationResults.MinO .."-".. CalculationResults.MaxO ..")", 1, 1, 1, r, g, b )
			end
			if settings.AvgCrit_M and CalculationResults.AvgCritO then
				frame:AddDoubleLine(L["Avg Crit:"], CalculationResults.AvgCritO .. " (".. CalculationResults.MinCritO .."-".. CalculationResults.MaxCritO ..")", 1, 1, 1, r, g, b )
			end
			if settings.Total_M and CalculationResults.AvgTotalO then -- and CalculationResults.AvgTotalO > CalculationResults.AvgO then
				frame:AddDoubleLine(L["Avg Total:"], CalculationResults.AvgTotalO, 1, 1, 1, r, g, b  )
			end
			if settings.Extra_M and CalculationResults.WindfuryAvgO then
				frame:AddDoubleLine("Windfury Avg/Total:", CalculationResults.WindfuryAvgO .. "/" .. CalculationResults.WindfuryAvgTotalO, 1, 1, 1, r, g, b)
			end			
		end
	end	
	
	if settings.Total_M and CalculationResults.AvgTotalO then
		frame:AddLine("-")
		frame:AddDoubleLine("Combined Total:", CalculationResults.AvgCombined, 1, 1, 1, r, g, b  )
	end
	

	if not settings.DefaultColor then
		r, g, b = 0.3, 0.6, 0.5
	end
	
	local bType
	if CalculationResults.Ranged then
		bType = "RAP"
	else
		bType = "AP"
	end
	
	if not baseSpell.NoNext and settings.Next_M then
		local critA, hitA, apA, sdA

		if CalculationResults.NextCrit then
			frame:AddDoubleLine("+1%/" .. self:GetRating("Crit") .. " " .. L["Crit:"], "+" .. CalculationResults.NextCrit, 1, 1, 1, r, g, b )
			if CalculationResults.NextCrit > 0.25 then
				critA = DrD_Round(CalculationResults.AvgCombined * 0.01 / CalculationResults.NextCrit * self:GetRating("Crit", nil, true ), 1 )
			end
		end

		if CalculationResults.NextHit then
			frame:AddDoubleLine("+1%/" .. self:GetRating("MeleeHit") .. " " .. L["Hit:"], "+" .. CalculationResults.NextHit, 1, 1, 1, r, g, b )
			if CalculationResults.NextHit > 0.25 then
				hitA = DrD_Round(CalculationResults.AvgCombined * 0.01 / CalculationResults.NextHit * self:GetRating("MeleeHit", nil, true), 1 )
			end  										
		end

		if CalculationResults.NextAP then
			frame:AddDoubleLine("+100 " .. bType .. ":", "+" .. CalculationResults.NextAP, 1, 1, 1, r, g, b )
			if CalculationResults.NextAP > 0.25 then
				apA = DrD_Round(CalculationResults.AvgCombined / CalculationResults.NextAP, 1)
			end
		end
		
		if CalculationResults.NextSpellDmg then
			frame:AddDoubleLine("+10 Spell Dmg:", "+" .. CalculationResults.NextSpellDmg, 1, 1, 1, r, g, b )
			if CalculationResults.NextSpellDmg > 0.25 then
				sdA = DrD_Round(CalculationResults.AvgCombined * 0.1 / CalculationResults.NextSpellDmg, 1)
			end
		end
		
		if sdA then
			frame:AddDoubleLine("+1% Total (Cr/Ht/" .. bType .. "/Spell Dmg):", (critA or "-") .. "/" .. (hitA or "-") .. "/" .. (apA or "-") .. "/" .. (sdA or "-"), 1, 1, 1, r, g, b )
		else
			frame:AddDoubleLine("+1% Total (Cr/Ht/" .. bType .. "):", (critA or "-") .. "/" .. (hitA or "-") .. "/" .. (apA or "-"), 1, 1, 1, r, g, b )
		end
	end

	if not settings.DefaultColor then
		r, g, b = 0.8, 0.1, 0.1
	end
	
	if not baseSpell.NoDPS and settings.DPS_M then
		if CalculationResults.DPS then
			frame:AddDoubleLine( "DPS" .. ((baseSpell.DPSrg and " (1/wspd):") or ":"), CalculationResults.DPS, 1, 1, 1, r, g, b )
		end
		if CalculationResults.DPSCD then
			frame:AddDoubleLine( "DPS(CD):", CalculationResults.DPSCD, 1, 1, 1, r, g, b )
		end
	end

	if CalculationResults.DPM and not baseSpell.NoDPM and settings.DPM_M then
		frame:AddDoubleLine( "Dmg/" .. powerTypes[CalculationResults.PowerType], CalculationResults.DPM, 1, 1, 1, r, g, b )
	end

	frame:Show()
end