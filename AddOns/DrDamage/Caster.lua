local playerClass = select(2,UnitClass("player"))
if playerClass ~= "DRUID" and playerClass ~="MAGE" and playerClass ~="PALADIN" and playerClass ~="PRIEST" and playerClass ~="SHAMAN" and playerClass ~="WARLOCK" then return end
local playerHealer, playerHybrid, hybridMana
if playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" then playerHealer = true end
if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then playerHybrid = true end
if playerClass == "DRUID" then hybridMana = true end

DrDamage = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0", "AceHook-2.1", "FuBarPlugin-2.0")
local L = AceLibrary("AceLocale-2.2"):new("DrDamage")
local SEA = AceLibrary("SpecialEvents-Aura-2.0")
local GT = AceLibrary("Gratuity-2.0")
local Deformat = AceLibrary("Deformat-2.0")
local BS
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2") 
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
local math_max = math.max
local string_match = string.match
local select = select
local UnitLevel = UnitLevel
local UnitMana = UnitMana
local Mana_Cost = MANA_COST

--Caster
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local GetCombatRatingBonus = GetCombatRatingBonus
local GetManaRegen = GetManaRegen
local playerMana

local function DrD_ClearTable(table)
	for k in pairs(table) do
		table[k] = nil
	end
end

local function DrD_Round(x, y)
	return math_floor(x * 10 ^ y + 0.5) / 10 ^ y
end

local function DrD_MatchData( data, ... )
	if not data or not ... then
		return false
	end

	if type(data) == "table" then
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

DrDamage.defaults = {
	--Calculation
	HitCalc = false,
	HitTarget = false,
	TargetLevel = 3,
	TargetPlayer = false,
	SpellDamage = 0,
	Healing = 0,
	ShadowDamage = 0,
	FireDamage = 0,
	NatureDamage = 0,
	FrostDamage = 0,
	ArcaneDamage = 0,
	HolyDamage = 0,
	HitRating = 0,
	CritRating = 0,
	ManualDmg = false,
	ManualPlus = false,
	ManaConsumables = false,
	--Actionbar:
	DisplayType = "Avg",
	CastsLeft = false,
	CastsLeftDmg = false,
	--Tooltip:
	PlusDmg = true,
	Coeffs = true,
	DispCrit = true,
	DispHit = true,
	AvgHit = true,
	AvgCrit = true,
	Ticks = true,
	Total = true,
	Extra = true,
	Next = true,
	DPS = true,
	DPM = true,
	Doom = true,
	Casts = true,
	TwoRoll = false,
	ManaUsage = false,
}

function DrDamage:Caster_Options()
	local table
	
	if playerHybrid then
		self.options.args.Caster = { type = "group", desc = "Caster Options", name = "Caster", order = 2, args = {} }
		table = self.options.args.Caster.args	
	else
		table = self.options.args
	end	
	
	table.ActionBar = {
		type = "group", desc = L["Options for the actionbar"], name = L["ActionBar"],
		args = {
			DisplayType = {
				type = "text",
				name = L["Display"],
				desc = L["Choose what to display on the actionbar"],
				validate =  { "Avg", "AvgHit", "AvgHitTotal", "DPS", "DPSC", "Min", "MaxHit", "Max", "DPM", "ManaCost", "TrueManaCost", "MPS" },
				get =  function() return settings["DisplayType"] end,
				set =  DrD_Set("DisplayType"),
				order = 70,
			}, 					
			CastsLeftDmg = {
				type = 'toggle',
				name = L["Damage spell casts left"],
				desc = L["Toggles amount of casts left to display on actionbar for damaging spells"],
				order = 100,
				get = function() return settings["CastsLeftDmg"] end,
				set = DrD_Set("CastsLeftDmg"),
			},				
		},
	}
	table.Tooltip = {
		type = "group", desc = L["Options for the tooltips"], name = L["Tooltip"],
		args = {					
			PlusDmg = {
				type = 'toggle',
				name = L["Show efficient +dmg/+healing"],
				desc = L["Toggles displaying of efficient +dmg/+healing"],
				order = 52,
				get = function() return settings["PlusDmg"] end,
				set = DrD_Set("PlusDmg", nil, true),
			},
			Coeffs = {
				type = 'toggle',
				name = L["Show coefficients"],
				desc = L["Toggles displaying of spell calculation data"],
				order = 53,
				get = function() return settings["Coeffs"] end,
				set = DrD_Set("Coeffs", nil, true),
			},				
			DispCrit = {
				type = 'toggle',
				name = L["Show crit %"],
				desc = L["Toggles displaying of crit %"],
				order = 54,
				get = function() return settings["DispCrit"] end,
				set = DrD_Set("DispCrit", nil, true),
			},
			DispHit = {
				type = 'toggle',
				name = L["Show hit %"],
				desc = L["Toggles displaying of hit %."],
				order = 56,
				get = function() return settings["DispHit"] end,
				set = DrD_Set("DispHit", nil, true),
			},				
			AvgHit = {
				type = 'toggle',
				name = L["Show avg + hit range"],
				desc = L["Toggles displaying of avg hit"],
				order = 58,
				get = function() return settings["AvgHit"] end,
				set = DrD_Set("AvgHit", nil, true),
			},
			AvgCrit = {
				type = 'toggle',
				name = L["Show avg crit + crit range"],
				desc = L["Toggles displaying of avg crit"],
				order = 60,
				get = function() return settings["AvgCrit"] end,
				set = DrD_Set("AvgCrit", nil, true),
			},
			Ticks = {
				type = 'toggle',
				name = L["Show per tick/hit"],
				desc = L["Toggles displaying of per hit/tick values"],
				order = 62,
				get = function() return settings["Ticks"] end,
				set = DrD_Set("Ticks", nil, true),
			},
			Total = {
				type = 'toggle',
				name = L["Show avg total dmg/heal"],
				desc = L["Toggles displaying of average in total values"],
				order = 64,
				get = function() return settings["Total"] end,
				set = DrD_Set("Total", nil, true),
			},				
			Extra = {
				type = 'toggle',
				name = L["Show extra dmg/heal (DoT, Ignite, Chained)"],
				desc = L["Toggles displaying of extra info"],
				order = 66,
				get = function() return settings["Extra"] end,
				set = DrD_Set("Extra", nil, true),
			},
			Next = {
				type = 'toggle',
				name = L["Show next values (+1% crit, +10 dmg)"],
				desc = L["Toggles displaying of +1% crit, +10 dmg values"],
				order = 68,
				get = function() return settings["Next"] end,
				set = DrD_Set("Next", nil, true),
			},
			DPS = {
				type = 'toggle',
				name = L["Show DPS/HPS"],
				desc = L["Toggles displaying of DPS/HPS"],
				order = 70,
				get = function() return settings["DPS"] end,
				set = DrD_Set("DPS", nil, true),
			},
			DPM = {
				type = 'toggle',
				name = L["Show DPM/HPM"],
				desc = L["Toggles displaying of DPM/HPM"],
				order = 72,
				get = function() return settings["DPM"] end,
				set = DrD_Set("DPM", nil, true),
			},
			Doom = {
				type = 'toggle',
				name = L["Show Damage/healing until OOM"],
				desc = L["Toggles displaying of damage/healing until OOM"],
				order = 74,
				get = function() return settings["Doom"] end,
				set = DrD_Set("Doom", nil, true),
			},
			Casts = {
				type = 'toggle',
				name = L["Show casts and time until OOM."],
				desc = L["Toggles displaying of casts and time until OOM (regen included)"],
				order = 75,
				get = function() return settings["Casts"] end,
				set = DrD_Set("Casts", nil, true),
			},
			ManaUsage = {
				type = 'toggle',
				name = L["Show additional mana usage information."],
				desc = L["Toggles displaying of true mana cost (if different) and mana per seconds cast"],
				order = 76,
				get = function() return settings["ManaUsage"] end,
				set = DrD_Set("ManaUsage", nil, true),
			},
		},
	}		
	table.Calculation = {
		type = "group", desc = L["Calculation options"], name = L["Calculation"],
		args = {
			ManaConsumables = {
				type = 'toggle',
				name = L["Include mana consumables into calculation"],
				desc = L["Toggles usage of super mana potions (Mages, also mana gems) into casts left with regen calculation."],
				order = 63,
				get = function() return settings["ManaConsumables"] end,
				set = DrD_Set("ManaConsumables"),
			},				
			TwoRoll = {
				type = 'toggle',
				name = L["Toggle usage of two roll hit calculation"],
				desc = L["Toggles two roll hit calculation on. Don't change this unless you know what this does."],
				order = 64,
				get = function() return settings["TwoRoll"] end,
				set = DrD_Set("TwoRoll"),
			},			
			HitCalc = {			
				type = 'toggle',
				name = L["+Hit calculation"],
				desc = L["Toggles +hit calculation effects into averages on/off"],
				order = 65,
				get = function() return settings["HitCalc"] end,
				set = DrD_Set("HitCalc"),
			},
			HitTarget = {			
				type = 'toggle',
				name = L["Hit calculation by target level"],
				desc = L["Toggles +hit calculation by target level."],
				order = 66,
				get = function() return settings["HitTarget"] end,
				set = DrD_Set("HitTarget"),
			},
			TargetLevel = {
				type = 'range',
				name = L["Manual target level setting"],
				desc = L["Manual set of target level compared to your level. Make sure 'HitTarget' is turned off to use this."],
				min = -10,
				max = 10,
				step = 1,
				order = 67,
				get = function() return settings["TargetLevel"] end,
				set = DrD_Set("TargetLevel"),
			},
			TargetPlayer = {
				type = 'toggle',
				name = L["Manual target is a player."],
				desc = L["Toggles if your manually set target is a player."],
				order = 68,
				get = function() return settings["TargetPlayer"] end,
				set = DrD_Set("TargetPlayer"),
			},				
			ManualDmg = {
				type = 'toggle',
				name = L["Manual variables"],
				desc = L["Allows you to manually set damage/healing properties"],
				order = 71,
				get = function() return settings["ManualDmg"] end,
				set = DrD_Set("ManualDmg"),
			},
			ManualPlus = {
				type = 'toggle',
				name = L["Manual damage adds to detected"],
				desc = L["Allows you to set if manual values should add to detected values"],
				order = 72,
				get = function() return settings["ManualPlus"] end,
				set = DrD_Set("ManualPlus"),
			}, 				
			SpellDamage = {
				type = 'range',
				name = L["Spell Damage"],
				min = -500,
				max = 2000,
				step = 1,
				desc = L["Input your spell damage"],
				order = 80,
				get = function() return settings["SpellDamage"] end,
				set = DrD_Set("SpellDamage"),
			},					
			CritRating = {
				type = 'range',
				name = L["Manual critical rating"],
				min = -400,
				max = 1000,
				step = 1,
				desc = L["Input critical rating you want to use."],
				order = 88,
				get = function() return settings["CritRating"] end,
				set = DrD_Set("CritRating"),					
			},
			HitRating = {
				type = 'range',
				name = L["Manual hit rating"],
				min = -200,
				max = 500,
				step = 1,
				desc = L["Input hit rating you want to use."],
				order = 89,
				get = function() return settings["HitRating"] end,
				set = DrD_Set("HitRating"),	
			},
		},
	}
	local calcTable = table.Calculation.args
	
	if playerHealer then
		table.ActionBar.args.CastsLeft = {
			type = 'toggle',
			name = L["Healing casts left"],
			desc = L["Toggles amount of casts left to display on actionbar for heals"],
			order = 105,
			get = function() return settings["CastsLeft"] end,
			set = DrD_Set("CastsLeft"),
		}
		calcTable.Healing = {
			type = 'range',
			name = L["Healing"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your +healing"],
			order = 79,
			get = function() return settings["Healing"] end,
			set = DrD_Set("Healing"),
		}		
	end
	if playerClass == "MAGE" or playerClass == "WARLOCK" or playerClass == "SHAMAN" then
		calcTable.FireDamage = {
			type = 'range',
			name = L["Fire Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your fire +damage"],
			order = 81,
			get = function() return settings["FireDamage"] end,
			set = DrD_Set("FireDamage"),
		}
	end
	if playerClass == "PRIEST" or playerClass == "WARLOCK" then
		calcTable.ShadowDamage = {
			type = 'range',
			name = L["Shadow Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your shadow +damage"],
			order = 82,
			get = function() return settings["ShadowDamage"] end,
			set = DrD_Set("ShadowDamage"),		
		}
	end
	if playerClass == "MAGE" or playerClass == "SHAMAN" then
		calcTable.FrostDamage = {
			type = 'range',
			name = L["Frost Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your frost +damage"],
			order = 83,
			get = function() return settings["FrostDamage"] end,
			set = DrD_Set("FrostDamage"),		
		}
	end
	if playerClass == "DRUID" or playerClass == "SHAMAN" then
		calcTable.NatureDamage = {
			type = 'range',
			name = L["Nature Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your nature +damage"],
			order = 84,
			get = function() return settings["NatureDamage"] end,
			set = DrD_Set("NatureDamage"),		
		}
	end
	if playerClass == "DRUID" or playerClass == "MAGE" then
		calcTable.ArcaneDamage = {
			type = 'range',
			name = L["Arcane Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your arcane +damage"],
			order = 85,
			get = function() return settings["ArcaneDamage"] end,
			set = DrD_Set("ArcaneDamage"),		
		}
	end
	if playerClass == "PALADIN" or playerClass == "PRIEST" then
		calcTable.HolyDamage = {
			type = 'range',
			name = L["Holy Damage"],
			min = -500,
			max = 2000,
			step = 1,
			desc = L["Input your holy +damage"],
			order = 85,
			get = function() return settings["HolyDamage"] end,
			set = DrD_Set("HolyDamage"),		
		}
	end
end

function DrDamage:Caster_Data()
	if not playerHybrid then self.ClassSpecials[((BS and BS["Shoot"]) or "Shoot")] = self.WandSlot end
end

function DrDamage:Caster_OnEnable()
	if self.Caster_Options then
		self:Caster_Options()
		self.Caster_Options = nil
	end
	if self.Caster_Data then
		self:Caster_Data()
		self.Caster_Data = nil
	end
	if settings.ABText then
		self:RegisterBucketEvent("UNIT_MANA", 2)
	end	
	
	playerMana = UnitMana("player")
	if hybridMana then
		self.lastMana = playerMana
	end
end

function DrDamage:Caster_OnProfileEnable()
	settings = self.db.profile
end

local displayTypeTable = { ["Avg"] = 2, ["DPS"] = 3, ["DPSC"] = 4, ["AvgHit"] = 5, ["Min"] = 6, ["MaxHit"] = 7, ["AvgHitTotal"] = 8, ["Max"] = 9 }
function DrDamage:WandSlot()
	if not HasWandEquipped() then
		return ""
	end

	local selector = displayTypeTable[settings.DisplayType] or 2
	local speed, lowDmg, hiDmg = UnitRangedDamage("player")
	local avgDmg = (lowDmg + hiDmg) / 2
	local avgTotal = avgDmg * (1 + ( GetRangedCritChance() / 100) * 0.5)
	local DPS = math_floor(avgTotal / speed + 0.5)
	local hiCritDmg = math_floor(hiDmg * 1.5 + 0.5)
	
	avgTotal = math_floor(avgTotal + 0.5)
	avgDmg = math_floor(avgDmg + 0.5)
	lowDmg = math_floor(lowDmg + 0.5)
	hiDmg = math_floor(hiDmg + 0.5)
	
	return (select( selector, false, avgTotal, DPS, DPS, avgDmg, lowDmg, hiDmg, avgDmg, hiCritDmg ))
end

function DrDamage:Caster_InventoryChanged()
	local update = self:CheckRelicSlot()
	if self:Caster_CheckBaseStats() or update then
		return true	
	end
end

local oldValues = 0
function DrDamage:Caster_CheckBaseStats()
	local newValues = 0

	for i = 1, 7 do
		newValues = newValues + GetSpellBonusDamage(i)
		newValues = newValues + GetSpellCritChance(i)
	end

	newValues = newValues + GetSpellBonusHealing() + GetCombatRatingBonus(8) + GetCombatRatingBonus(20) + UnitStat("player",5)

	if newValues ~= oldValues then
		oldValues = newValues
		return true
	end

	return false	
end

function DrDamage:UNIT_MANA( units )
	if not hybridMana and not settings.CastsLeft and not settings.CastsLeftDmg then
		return
	end

	for unit in pairs( units ) do
		if unit == "player" then
			if hybridMana and UnitPowerType("player") == 0 then
				self.lastMana = UnitMana("player")
				if not settings.CastsLeft and not settings.CastsLeftDmg then
					return
				end
			end
			if math_abs( UnitMana( "player" ) - playerMana ) >= ( 20 + UnitLevel( "player" ) * 2 ) then
				playerMana = UnitMana( "player" )
				self:CancelScheduledEvent( "UpdatingAB" )
				self:ScheduleEvent("UpdatingAB", self.UpdateAB, 1, self, false, true)
			end
			return
		end
	end
end

local CalculationResults = {}
function DrDamage:CasterTooltip( frame, spellName, baseSpell, tableSpell )

	local healingSpell, AvgTotal, DPS, DPSC, AvgDmg, MinDmg, MaxDmg = self:RawNumbers(tableSpell, spellName, true, true)

	frame:AddLine(" ")
	
	if CalculationResults.Name then
		frame:AddLine( CalculationResults.Name, 1, 1, 1 )
		frame:AddLine(" ")
	end

	local r, g, b = 1, 0.82745098, 0

	if not settings.DefaultColor then
		r, g, b = 0, 0.7, 0
	end

	local spellType, spellAbbr

	if healingSpell then
		spellType = L["Heal"]
		spellAbbr = L["H"]
	else
		spellType = L["Dmg"]
		spellAbbr = L["D"]
	end

	if settings.PlusDmg then
		frame:AddDoubleLine( "+" .. spellType .. L[" (eff.):"], "+" .. DrD_Round( CalculationResults.SpellDmg * CalculationResults.SpellDmgM * CalculationResults.DmgM, 1 ), 1, 1, 1, r, g, b  )
	end

	if settings.Coeffs then
		frame:AddDoubleLine(L["Coeffs:"], CalculationResults.DmgM .. "/" .. CalculationResults.SpellDmgM .."/" .. CalculationResults.SpellDmg, 1, 1, 1, r, g, b  )
	end

	if settings.DispCrit and CalculationResults.CritRate then
		frame:AddDoubleLine(L["Crit:"], CalculationResults.CritRate .. "%", 1, 1, 1, r, g, b )
	end

	if settings.DispHit and not baseSpell.Unresistable and not healingSpell then
		frame:AddDoubleLine(L["Hit:"], CalculationResults.HitRate .. "%", 1, 1, 1, r, g, b )
	end  				

	if not settings.DefaultColor then
		r, g, b = 0.8, 0.8, 0.9
	end

	if settings.AvgHit then
		frame:AddDoubleLine(L["Avg:"], AvgDmg .. " (".. MinDmg .."-".. MaxDmg ..")", 1, 1, 1, r, g, b )

		if baseSpell.Leech and CalculationResults.AvgLeech and CalculationResults.AvgLeech > AvgDmg then
			frame:AddDoubleLine(L["Avg Heal:"], CalculationResults.AvgLeech, 1, 1, 1, r, g, b )
		end
	end

	if settings.AvgCrit and CalculationResults.AvgCrit and not baseSpell.sHits then
		frame:AddDoubleLine(L["Avg Crit:"], CalculationResults.AvgCrit .. " (".. CalculationResults.MinCrit .."-".. CalculationResults.MaxCrit ..")", 1, 1, 1, r, g, b )
	end

	if settings.Ticks and CalculationResults.PerHit then
		if baseSpell.sHits then
			frame:AddDoubleLine(L["Hits:"], CalculationResults.Hits .. "x ~" .. CalculationResults.PerHit, 1, 1, 1, r, g, b )

			if baseSpell.Leech and CalculationResults.PerHitHeal and CalculationResults.PerHitHeal > CalculationResults.PerHit then
				frame:AddDoubleLine(L["Hits Heal:"], CalculationResults.Hits .. "x ~" .. CalculationResults.PerHitHeal, 1, 1, 1, r, g, b )
			end  						
		elseif baseSpell.sTicks then
			frame:AddDoubleLine(L["Ticks:"], CalculationResults.Hits .. "x ~" .. CalculationResults.PerHit, 1, 1, 1, r, g, b )

			if baseSpell.Leech and CalculationResults.PerHitHeal and CalculationResults.PerHitHeal > CalculationResults.PerHit then
				frame:AddDoubleLine(L["Ticks Heal:"], CalculationResults.Hits .. "x ~" .. CalculationResults.PerHitHeal, 1, 1, 1, r, g, b )
			end  						
		end
	end

	if settings.Extra then 
		if CalculationResults.ChainDmg then
			frame:AddDoubleLine(L["Avg Chain:"], CalculationResults.ChainDmg, 1, 1, 1, r, g, b  )
		end

		if CalculationResults.IgniteDmg then
			frame:AddDoubleLine(L["Ignite:"], CalculationResults.IgniteDmg, 1, 1, 1, r, g, b )
		end

		if CalculationResults.DotDmg > 0 then
			frame:AddDoubleLine(L["DoT:"], CalculationResults.DotDmg, 1, 1, 1, r, g, b )
		end
	end  				

	if settings.Total and AvgTotal > AvgDmg then
		frame:AddDoubleLine(L["Avg Total:"], AvgTotal, 1, 1, 1, r, g, b  )
	end

	if not settings.DefaultColor then
		r, g, b = 0.3, 0.6, 0.5
	end

	if settings.Next and not baseSpell.NoNext then
		local critA, hitA, dmgA

		if CalculationResults.NextCrit then
			frame:AddDoubleLine("+1%/" .. self:GetRating("Crit") .. " " .. L["Crit:"], "+" .. CalculationResults.NextCrit .. " (" .. DrD_Round((CalculationResults.NextCrit * 10) / CalculationResults.NextTenDmg, 1) .. " +" .. spellType .. ")", 1, 1, 1, r, g, b )
			critA = DrD_Round(AvgTotal * 0.01 / CalculationResults.NextCrit * self:GetRating("Crit", nil, true ), 1 )
		end

		if CalculationResults.NextHit then
			if DrD_MatchData(baseSpell.School, "Physical") then
				frame:AddDoubleLine("+1%/" .. self:GetRating("MeleeHit") .. " " .. L["Hit:"], "+" .. CalculationResults.NextHit .. " (" .. DrD_Round((CalculationResults.NextHit * 10) / CalculationResults.NextTenDmg, 1) .. " +" .. spellType .. ")", 1, 1, 1, r, g, b )
				if CalculationResults.NextHit > 0.5 then
					hitA = DrD_Round(AvgTotal * 0.01 / CalculationResults.NextHit * self:GetRating("MeleeHit", nil, true), 1 )
				end  							
			else
				frame:AddDoubleLine("+1%/" .. self:GetRating("Hit") .. " " .. L["Hit:"], "+" .. CalculationResults.NextHit .. " (" .. DrD_Round((CalculationResults.NextHit * 10) / CalculationResults.NextTenDmg, 1) .. " +" .. spellType .. ")", 1, 1, 1, r, g, b )
				if CalculationResults.NextHit > 0.5 then
					hitA = DrD_Round(AvgTotal * 0.01 / CalculationResults.NextHit * self:GetRating("Hit", nil, true), 1 )
				end  							
			end
			if not hitA then hitA = "-" end
		end

		frame:AddDoubleLine("+10 " .. spellType .. ":", "+" .. CalculationResults.NextTenDmg, 1, 1, 1, r, g, b )
		dmgA = DrD_Round((AvgTotal * 0.1) / CalculationResults.NextTenDmg, 1)

		if critA and hitA then
			frame:AddDoubleLine(L["+1% Total ("] .. L["Cr/Ht/"] ..spellType .. "):", critA .. "/" .. hitA .. "/" .. dmgA, 1, 1, 1, r, g, b )
		elseif critA then
			frame:AddDoubleLine(L["+1% Total ("] .. L["Cr/"] .. spellType .. "):", critA .. "/" .. dmgA, 1, 1, 1, r, g, b )
		elseif hitA then
			frame:AddDoubleLine(L["+1% Total ("] .. L["Ht/"] .. spellType .. "):", hitA .. " /" .. dmgA, 1, 1, 1, r, g, b )
		else
			frame:AddDoubleLine(L["+1% Total ("] .. spellType .. "):", dmgA, 1, 1, 1, r, g, b )
		end
	end

	if not settings.DefaultColor then
		r, g, b = 0.8, 0.1, 0.1
	end

	if settings.DPS and not baseSpell.NoDPS then
		if DPSC ~= DPS then
			frame:AddDoubleLine(spellAbbr .. L["PS/"] .. spellAbbr .. L["PSC:"], DPS .. ((CalculationResults.ExtraDPS and ("+" .. CalculationResults.ExtraDPS)) or "") .. "/" .. DPSC, 1, 1, 1, r, g, b)
		else
			frame:AddDoubleLine(spellAbbr .. L["PS:"], DPS .. ((CalculationResults.ExtraDPS and ("+" .. CalculationResults.ExtraDPS)) or "") , 1, 1, 1, r, g, b)
		end
		if CalculationResults.DPSCD then
			frame:AddDoubleLine(spellAbbr .. L["PS (CD):"], CalculationResults.DPSCD, 1, 1, 1, r, g, b)
		end  					
	end

	if settings.DPM and CalculationResults.DPM and not baseSpell.NoDPM then
		frame:AddDoubleLine(spellAbbr .. L["PM:"], CalculationResults.DPM, 1, 1, 1, r, g, b )
	end

	if settings.Doom and CalculationResults.DOOM and not baseSpell.NoDoom then
		frame:AddDoubleLine(spellType .. L[" until OOM:"], CalculationResults.DOOM, 1, 1, 1, r, g, b )
	end

	if settings.Casts and CalculationResults.castsBase then
		frame:AddDoubleLine(((CalculationResults.castsRegen > 0) and L["Casts (rgn):"]) or L["Casts:"], CalculationResults.castsBase .. ((CalculationResults.castsRegen > 0 and ("+" .. CalculationResults.castsRegen)) or "") .. ((CalculationResults.SOOM and (" (" .. CalculationResults.SOOM .. "s)")) or ""), 1, 1, 1, r, g, b )
	end

	if settings.ManaUsage then
		if CalculationResults.TrueManaCost and CalculationResults.TrueManaCost ~= CalculationResults.ManaCost then
			frame:AddDoubleLine(L["True Mana Cost:"], CalculationResults.TrueManaCost, 1, 1, 1, r, g, b)
		end
		if CalculationResults.MPS then
			frame:AddDoubleLine(L["MPS:"], CalculationResults.MPS, 1, 1, 1, r, g, b)
		end
	end

	frame:Show()
end

local hitDataMOB = { [0] = 96, 95, 94, 83, 72, 61, 50, 39, 28, 17, 6 }
local hitDataPlayer = { [0] = 96, 95, 94, 87, 80, 73, 66, 59, 52, 45, 38 }
local hitMod = select(2, UnitRace("player")) == "Draenei" and (playerClass == "MAGE" or playerClass == "PRIEST" or playerClass == "SHAMAN") and 1 or 0
local lastTargetLevel
local lastSpellHit

local function DrD_SpellHit()
	local hitPerc = 99
	
	if settings.HitTarget then
		local levelDiff, _, targetLevel = DrDamage:GetLevels()

		if levelDiff >= 0 then
			if UnitIsPlayer("target") then
				hitPerc = hitDataPlayer[levelDiff]
			else
				hitPerc = hitDataMOB[levelDiff]
			end
		end
		lastTargetLevel = targetLevel
	else
		if settings.TargetLevel >= 0 then
			if settings.TargetPlayer then
				hitPerc = hitDataPlayer[math_floor(settings.TargetLevel)]
			else
				hitPerc = hitDataMOB[math_floor(settings.TargetLevel)]
			end
		end
		lastTargetLevel = settings.TargetLevel
	end
	
	lastSpellHit = hitPerc + hitMod
	
	return lastSpellHit
end

--Static tables
local schoolTable = { ["Holy"] = 2, ["Fire"] = 3, ["Nature"] = 4, ["Frost"] = 5, ["Shadow"] = 6, ["Arcane"] = 7 }
local debuffMods = { "Shadow Embrace" }

--Values you can modify with the modify table (5th arg in DrDamage:RawNumbers)
local modifyTable = { "spellDmg", "critPerc", "hitPerc", "manaRegen", "finalMod", "manaMod" }

--Temporary tables
local calculation = {}
local BuffTalentRanks = {}
local ActiveAuras = {}

--Local functions
local DrD_DmgCalc, DrD_TalentCalc, DrD_BuffCalc

function DrDamage:RawNumbers( spell, lSpellName, tooltip, manaCalc, modify )
	if not spell or not lSpellName then
		do return end
	end
	
	local spellName = lSpellName

	if BS and BS:HasReverseTranslation(spellName) then
		spellName = BS:GetReverseTranslation(spellName)
	end
	
	local baseSpell = self.spellInfo[lSpellName][0]							--Base spell information
	local healingSpell = baseSpell.Healing or DrD_MatchData(baseSpell.School, "Healing")		--Healing spell (boolean)
	
	calculation.healingSpell = healingSpell
	calculation.hitPerc = lastSpellHit								--Hit chance (%)	
	calculation.castTime = spell.castTime or baseSpell.castTime or 1.5				--Cast time
	calculation.eDuration = spell.eDuration or baseSpell.eDuration or 1				--Effect duration
	calculation.sHits = spell.sHits or baseSpell.sHits						--Amount of hits(ticks) of spell
	calculation.critM = 0.5										--Crit multiplier
	calculation.bNukeDmg = 0									--Modifier for spells with a DOT portion
	calculation.bDmgM = 1										--Base damage Modifier
	calculation.dmgM = 1
	calculation.spellDmgM_AddTalent = 0								--Talents: Spell damage multiplier additive	
	calculation.dmgM_AddTalent = 0									--Talents: Damage multiplier additive
	calculation.spellDmgM_AddNoDownrank = 0								--Additive spell damage modifier (not affected by downranking)
	calculation.dotSpellDmgM = calculation.eDuration / 15						--Dot portion spelldamage modifier
	calculation.cooldown = baseSpell.Cooldown or 0							--Spell's cooldown
	calculation.finalMod = 0 									--Modifier to final damage +/-
	calculation.finalMod_fM = 0
	calculation.finalMod_sM = 0
	calculation.dotFinalMod = 0									--Modifier to final dot damage +/-
	calculation.minDam = spell[1]									--Spell initial base min damage
	calculation.maxDam = spell[2]									--Spell initial base max damage
	calculation.chainFactor = baseSpell.chainFactor							--Chain effect spells
	calculation.manaRegen = select(2, GetManaRegen("player"))					--Mana regen while casting
	calculation.lowRankFactor = 1
	calculation.lowLevelFactor = 1
	calculation.manaMod = 0
		
	if type(baseSpell.School) == "table" then
		calculation.spellSchool = baseSpell.School[1]
		calculation.spellType = baseSpell.School[2]
	else
		calculation.spellSchool = baseSpell.School
	end
	
	--Calculate +healing/+dmg
	if healingSpell then
		calculation.spellDmg = GetSpellBonusHealing()
	else
		calculation.spellDmg = GetSpellBonusDamage(schoolTable[calculation.spellSchool] or 1)
		if not baseSpell.NoAura then
			calculation.dmgM = DrDamage.globalMod
			if not calculation.spellType == "Physical" then
				for i, v in ipairs( debuffMods ) do
					if BS and BS:HasReverseTranslation(v) then
						v = BS:GetReverseTranslation(v)
					end
					local index = SEA:UnitHasDebuff("player", v)
					if index then
						GT:SetUnitDebuff("player", index)
						local amount = select( 3, GT:Find( "(%d+)%%" ))
						if amount then
							calculation.dmgM = calculation.dmgM / (1-tonumber(amount)/100)
						end
					end
				end
			end
		end
	end
	
	--Calculate spelldamage modifier
	if baseSpell.bonusFactor then
		calculation.spellDmgM = baseSpell.bonusFactor
	elseif baseSpell.eDot then 
		calculation.spellDmgM = (calculation.eDuration / 15)
	else
		calculation.spellDmgM = (calculation.castTime / 3.5) 
	end
	
	--Factor for downranking
	if not baseSpell.NoDownRank then
		local playerLevel = UnitLevel("player")
		local downRankMod = spell.Downrank or baseSpell.Downrank or 0
		local lowRankFactor = (spell.spellLevel + 11 + downRankMod) / playerLevel

		if lowRankFactor < 1 then
			calculation.lowRankFactor = lowRankFactor
		end
	end
	
	--Factor for spells under level 20
	if spell.spellLevel and spell.spellLevel < 20 and not baseSpell.NoLowLevelPenalty then
		local lowLevelFactor = 1 - ((20 - spell.spellLevel) * 0.0375)
		
		if lowLevelFactor < 1 and lowLevelFactor > 0 then
			calculation.lowLevelFactor = lowLevelFactor
		end
	end	
		
	--Calculate base hit chance (only if needed)
	if settings.HitTarget and UnitLevel("target") ~= lastTargetLevel then
		calculation.hitPerc = DrD_SpellHit() 		
	elseif not settings.HitTarget and settings.TargetLevel ~= lastTargetLevel then
		calculation.hitPerc = DrD_SpellHit()
	end	
	
	--Calculate crit/hit
	if not DrD_MatchData(baseSpell.School, "Physical") then
		calculation.critPerc = GetSpellCritChance(schoolTable[calculation.spellSchool] or 1)
		calculation.hitPerc = calculation.hitPerc + GetCombatRatingBonus(8)
	else
		calculation.critPerc = GetCritChance()
		calculation.critM = 1
		calculation.hitPerc = calculation.hitPerc + GetCombatRatingBonus(6)
	end
		
	if settings.ManaConsumables then
		calculation.manaRegen = calculation.manaRegen + 20 
	end
	
	--Random item bonuses to base values not supplied by API
	if self.RelicSlot then
		if self.RelicSlot[spellName] then
			local data = self.RelicSlot[spellName]
			local count = #data
			if count then
				for i = 1, count - 1, 2 do
					if data[i] and data[i+1] then
						if IsEquippedItem(data[i]) then
							local modType = data["ModType"..((i+1)/2)]
							
							if not modType then
								calculation.spellDmg = calculation.spellDmg + data[i+1]
							elseif modType == "Base" then
								calculation.minDam = calculation.minDam + data[i+1]
								calculation.maxDam = calculation.maxDam + data[i+1]
							elseif modType == "Final" then
								calculation.finalMod = calculation.finalMod + data[i+1]
							elseif modType == "Final_fM" then
								calculation.finalMod_fM = calculation.finalMod_fM + data[i+1]
							elseif modType == "Final_sM" then
								calculation.finalMod_sM = calculation.finalMod_sM + data[i+1]
							end
						end
					end
				end
			end
		end
	end	

	--Manual variables from profile:
	if settings.ManualDmg then
		if settings.ManualPlus then
			if healingSpell then
				calculation.spellDmg = math_max(0, calculation.spellDmg + settings.Healing)
			else
				calculation.spellDmg = math_max(0, calculation.spellDmg + settings.SpellDamage)
			end
			calculation.critPerc = math_max(0, calculation.critPerc + self:GetRating("Crit", settings.CritRating, true))
			calculation.hitPerc = math_max(0, calculation.hitPerc + self:GetRating("Hit", settings.HitRating, true))	
		else
			if healingSpell then
				calculation.spellDmg = settings.Healing
			else
				calculation.spellDmg = settings.SpellDamage
			end
			if not DrD_MatchData(baseSpell.School, "Physical") then
				calculation.critPerc = calculation.critPerc - GetCombatRatingBonus(11) + self:GetRating("Crit", settings.CritRating, true)
				calculation.hitPerc = calculation.hitPerc - GetCombatRatingBonus(8) + self:GetRating("Hit", settings.HitRating, true)
			else
				calculation.critPerc = calculation.critPerc - GetCombatRatingBonus(9) + self:GetRating("Crit", settings.CritRating, true)
				calculation.hitPerc = calculation.hitPerc - GetCombatRatingBonus(6) + self:GetRating("MeleeHit", settings.HitRating, true)
			end			
		end
		
		if healingSpell then
			calculation.spellDmg = math_max(0, calculation.spellDmg + settings.Healing)
		else
			local schoolMod = settings[calculation.spellSchool.."Damage"]
			if schoolMod then calculation.spellDmg = math_max(0, calculation.spellDmg + schoolMod) end		
		end
	end
	
	--Process modify table
	if modify and type( modify ) == "table" then
		for _, v in ipairs( modifyTable ) do
			if modify[v] then
				calculation[v] = math_max(0, calculation[v] + modify[v])
			end
		end
	end

	--Adding to spells base damage after levelups:
	if baseSpell.BaseIncrease then
		local playerLevel = UnitLevel("player")
	
		if playerLevel > spell.spellLevel then
			local spellmaxLevel
			if baseSpell.LevelIncrease then
				spellmaxLevel = spell.spellLevel + baseSpell.LevelIncrease
				if spellmaxLevel > 70 then spellmaxLevel = 70 end
			else
				spellmaxLevel = 70
			end
			if playerLevel >= spellmaxLevel then
				calculation.minDam = calculation.minDam + spell[3]
				calculation.maxDam = calculation.maxDam + spell[4]			
			else
				local diff = spellmaxLevel - spell.spellLevel
				
				calculation.minDam = calculation.minDam + (playerLevel - spell.spellLevel) * (spell[3] / diff)
				calculation.maxDam = calculation.maxDam + (playerLevel - spell.spellLevel) * (spell[4] / diff)
			end
		end
		
		calculation.minDam = math_floor(calculation.minDam)
		calculation.maxDam = math_ceil(calculation.maxDam)
	end	

	--Apply talents		
	for talentName, talentRank in pairs(self.talents) do						
		local talentTable = self.talentInfo[talentName]
		
		for i = 1, #talentTable do
			local talent = talentTable[i]	

			if not talent.Melee then
				if DrD_MatchData(talent.Spells, spellName, calculation.spellType) or not baseSpell.NoSchoolTalents and DrD_MatchData(talent.Spells, "All", calculation.spellSchool) then		
					DrD_TalentCalc(baseSpell, talentName, talentRank, talent)
				end
			end
		end
	end

	--Add up additive components:
	calculation.dmgM = calculation.dmgM + calculation.dmgM_AddTalent
	calculation.spellDmgM = calculation.spellDmgM + calculation.spellDmgM_AddTalent
	--calculation.spellDmgM = calculation.spellDmgM * (calculation.castModDmg or 1)

	--Start calculating Buffs/Debuffs that affects damage not provided by blizzard API.

	--BUFF/DEBUFF -- DAMAGE/HEALING -- PLAYER
	if not baseSpell.NoAura then
		for buffName, index, apps, texture, rank in SEA:BuffIter("player") do
			if BS and BS:HasReverseTranslation(buffName) then
				buffName = BS:GetReverseTranslation(buffName)
			end		
		
			if self.PlayerAura[buffName] then
				local buffData = self.PlayerAura[buffName]
			
				if not healingSpell
					and ( DrD_MatchData( buffData.School, calculation.spellSchool ) and not baseSpell.NoSchoolBuffs
					or ( not buffData.School and not buffData.Spell ))
				or DrD_MatchData( buffData.School, calculation.spellType )
				or healingSpell 
					and buffData.School == "Healing"
				or buffData.School == "All" 
					and calculation.spellType ~= "Physical"
				or DrD_MatchData( buffData.Spell, lSpellName ) then
					if buffData.ModType == "Special" and self.Calculation[buffName] then
						self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
					else
						DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, lSpellName )
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
				
				if not healingSpell 
					and ( DrD_MatchData( buffData.School, calculation.spellSchool ) 
					or ( not buffData.School and not buffData.Spell ))
				or healingSpell 
					and buffData.School == "Healing"					
				or DrD_MatchData( buffData.Spell, lSpellName ) then	
					if buffData.ModType == "Special" and self.Calculation[buffName] then
						self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
					else
						DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, lSpellName )
					end
				end
			end
		end	
		--DEBUFF -- DAMAGE/HEALING -- TARGET
		local debuffTarget
		if not healingSpell then
			debuffTarget = "target"
		elseif UnitIsFriend("player", "target") then
			debuffTarget = "target"
		elseif UnitIsFriend("player", "targettarget") then
			debuffTarget = "targettarget" 
		end		

		if debuffTarget then
			local socStun			--Variable for SoC stun bonus		
		
			for buffName, apps, _, texture, rank, index in SEA:DebuffIter(debuffTarget) do
				if BS and BS:HasReverseTranslation(buffName) then
					buffName = BS:GetReverseTranslation(buffName)
				end

				if self.Debuffs[buffName] then
					local buffData = self.Debuffs[buffName]
					local modType = buffData.ModType
					
					if buffData.Affliction then
						if BuffTalentRanks["Soul Siphon"] then
							ActiveAuras["Soul Siphon"] = ( ActiveAuras["Soul Siphon"] or 0 ) + 1
						end
					end					

					if not healingSpell 
						and ( DrD_MatchData( buffData.School, calculation.spellSchool ) and not baseSpell.NoSchoolBuffs
						or not buffData.School and not buffData.Spell )
						or DrD_MatchData( buffData.School, calculation.spellType ) and not baseSpell.NoTypeBuffs
					or healingSpell and buffData.School == "Healing"
					or DrD_MatchData( buffData.Spell, lSpellName )
					then
						if modType == "Special" and self.Calculation[buffName] then
							self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
						elseif buffData.Stun and not socStun then
							socStun = true
							calculation.bDmgM = calculation.bDmgM + 1
						else
							DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, lSpellName )
						end
					end
				end
			end
		end
	end
	--BUFF - HEALING -- TARGET
	if healingSpell and self.HealingBuffs then
		local healingTarget
		
		if UnitIsFriend("player", "target") then
			healingTarget = "target"
		elseif UnitIsFriend("player", "targettarget") then
			healingTarget = "targettarget" 
		end
		
		if healingTarget then
			for buffName, index, apps, texture, rank in SEA:BuffIter(healingTarget) do
				if BS and BS:HasReverseTranslation(buffName) then
					buffName = BS:GetReverseTranslation(buffName)
				end		

				if self.HealingBuffs[buffName] then
					local buffData = self.HealingBuffs[buffName]

					if not buffData.Spell or DrD_MatchData( buffData.Spell, lSpellName ) then
						if buffData.ModType == "Special" and self.Calculation[buffName] then
							self.Calculation[buffName]( calculation, ActiveAuras, BuffTalentRanks, index, apps, texture, rank )
						else
							DrD_BuffCalc( buffName, buffData, index, apps, texture, rank, lSpellName )
						end
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
	if self.SetBonuses[spellName] then
		self.SetBonuses[spellName]( calculation, ActiveAuras )
	end
	if self.Calculation[spellName] then
		self.Calculation[spellName]( calculation, ActiveAuras, BuffTalentRanks, spell )
	end	
	
	--Calculate modified cast time
	if GetCombatRatingBonus(20) > 0 and not baseSpell.Instant then
		calculation.castTime = calculation.castTime / (1 + GetCombatRatingBonus(20)/100)
	end
	
	--Split between bonus to dot and nuke
	if baseSpell.hybridFactor then
		calculation.spellDmgM = calculation.spellDmgM * baseSpell.hybridFactor
	end
	
	--Factor that applies to all ranks of the spell
	if baseSpell.sFactor then
		calculation.spellDmgM = calculation.spellDmgM * baseSpell.sFactor
	end
	
	--Factor that applies to current rank of the spell
	if spell.sFactor then
		calculation.spellDmgM = calculation.spellDmgM * spell.sFactor
	end
	
	--Low rank and low level penalties
	calculation.spellDmgM = calculation.spellDmgM * calculation.lowRankFactor * calculation.lowLevelFactor
	
	--Add additive components with no downranking effect
	calculation.spellDmgM = calculation.spellDmgM + calculation.spellDmgM_AddNoDownrank	
	
	local returnAvgTotal, returnDPS, returnDPSC, returnAvg, returnMinDmg, returnMaxDmg, returnAvgHitTotal, returnMaxCritDmg = DrD_DmgCalc( spellName, baseSpell, spell, false, false, tooltip, manaCalc )
	
	if tooltip then
		if settings.Next then
			if baseSpell.canCrit then
				calculation.critPerc = calculation.critPerc + 1
				CalculationResults.NextCrit = DrD_Round( DrD_DmgCalc( spellName, baseSpell, spell, true ) - returnAvgTotal, 1 )
				calculation.critPerc = calculation.critPerc - 1	
			end

			calculation.spellDmg = calculation.spellDmg + 10
			CalculationResults.NextTenDmg = DrD_Round( DrD_DmgCalc( spellName, baseSpell, spell, true ) - returnAvgTotal, 1 )
			calculation.spellDmg = calculation.spellDmg - 10

			if not healingSpell and not baseSpell.Unresistable then
				local temp
				
				if settings.HitCalc then
					temp = returnAvgTotal
				else
					temp = DrD_DmgCalc( spellName, baseSpell, spell, true, true )
				end
				
				calculation.hitPerc = calculation.hitPerc + 1
				CalculationResults.NextHit = DrD_Round( DrD_DmgCalc( spellName, baseSpell, spell, true, true ) - temp, 1 )
			end	
		end		
	end
	
	DrD_ClearTable( BuffTalentRanks )
	DrD_ClearTable( ActiveAuras )
	DrD_ClearTable( calculation )
	
	return healingSpell, math_floor( returnAvgTotal + 0.5 ), returnDPS, returnDPSC, returnAvg, returnMinDmg, returnMaxDmg, returnAvgHitTotal, returnMaxCritDmg, CalculationResults
end

local function DrD_FreeCrits( casts, canCrit, freeCrit, critRate )
	if canCrit and freeCrit and freeCrit > 0 then
		local total = casts
		for i = 1, 5 do
			casts = math_floor(freeCrit * (critRate / 100) * casts)
			if casts == 0 then break end									
			total = total + casts
		end
		return total
	end
	return casts
end

DrD_DmgCalc = function( spellName, baseSpell, spell, nextCalc, hitCalc, tooltip, manaCalc )
	--Initialize variables that are calculated
	local dispSpellDmgM = calculation.spellDmgM	--Calculated spelldamage modifier		
	local calcAvgDmgCrit = 0			--Calculated final damage with averaged crit
	local calcDotDmg = 0				--Calculated DOT portion
	local calcAvgDmg				--Calculated final damage without crit
	local calcMinDmg				--Calculated dmg range: min
	local calcMaxDmg				--Calculated dmg range: max
	local calcDPS
	local calcMinCrit				--Calculated crit range: min
	local calcMaxCrit				--Calculated crit range: max
	local igniteDotDmg				--Calculated ignite DOT portion
	local perHit					--Calculated damage per hit
	local ticks
	local extraDmg				
	local extraDPS
	local baseDuration = spell.eDuration or baseSpell.eDuration

	if calculation.sHits then
		calcMinDmg = calculation.dmgM * ( calculation.bDmgM * calculation.minDam * calculation.sHits + (  calculation.spellDmg * calculation.spellDmgM ) )
		calcMaxDmg = calculation.dmgM * ( calculation.bDmgM * calculation.maxDam * calculation.sHits + (  calculation.spellDmg * calculation.spellDmgM ) )
	elseif spell.hybridDotDmg then
		calcMinDmg = ( calculation.dmgM + calculation.bNukeDmg ) * ( calculation.bDmgM * calculation.minDam + ( calculation.spellDmg * calculation.spellDmgM ) )
		calcMaxDmg = ( calculation.dmgM + calculation.bNukeDmg ) * ( calculation.bDmgM * calculation.maxDam + ( calculation.spellDmg * calculation.spellDmgM ) )
	else
		calcMinDmg = calculation.dmgM * ( calculation.bDmgM * calculation.minDam + ( calculation.spellDmg * calculation.spellDmgM ) )
		calcMaxDmg = calculation.dmgM * ( calculation.bDmgM * calculation.maxDam + ( calculation.spellDmg * calculation.spellDmgM ) )
	end

	if calculation.finalMod ~= 0 then
		calcMinDmg = math_max(0, calcMinDmg + calculation.finalMod)
		calcMaxDmg = math_max(0, calcMaxDmg + calculation.finalMod)	
	end
	
	calcMinDmg = calcMinDmg + calculation.finalMod_sM * calculation.spellDmgM + calculation.finalMod_fM * calculation.dmgM
	calcMaxDmg = calcMaxDmg + calculation.finalMod_sM * calculation.spellDmgM + calculation.finalMod_fM * calculation.dmgM
		
	--This is for Imp SW:P and others with extended duration through talents etc.
	if baseSpell.eDot and baseSpell.eDuration and calculation.eDuration > baseDuration then
		calcMinDmg = calcMinDmg + (calcMinDmg / baseDuration) * (calculation.eDuration - baseDuration)
		calcMaxDmg = calcMaxDmg + (calcMaxDmg / baseDuration) * (calculation.eDuration - baseDuration)
	end		

	calcAvgDmg = (calcMinDmg + calcMaxDmg) / 2

	--Crit calculation:
	local critBonus = 0

	if calculation.critPerc > 100 then
		calculation.critPerc = 100
	end

	if baseSpell.canCrit then
		calcMinCrit = calcMinDmg + calcMinDmg * calculation.critM
		calcMaxCrit = calcMaxDmg + calcMaxDmg * calculation.critM
		critBonus = (calculation.critPerc / 100) * calcAvgDmg * calculation.critM
		calcAvgDmgCrit = calcAvgDmg + critBonus
	else
		calcAvgDmgCrit = calcAvgDmg
		calculation.critPerc = 0;
	end		

	--Hybrid spells:
	local hybridDmgM = 0
	if spell.hybridDotDmg then
		local hybridFactor = baseSpell.hybridFactor or 0
		local sFactor = 1

		if baseSpell.sFactor then
			sFactor = baseSpell.sFactor * sFactor
		end

		if spell.sFactor then
			sFactor = spell.sFactor * sFactor
		end

		if baseSpell.hybridDotFactor then
			sFactor = baseSpell.hybridDotFactor * sFactor
		end

		hybridDmgM =  calculation.dotSpellDmgM * ( 1 - hybridFactor ) * sFactor * calculation.lowRankFactor * calculation.lowLevelFactor
	end	
	
	if spell.hybridDotDmg then
		calcDotDmg = calculation.dmgM * ( hybridDmgM * calculation.spellDmg + spell.hybridDotDmg )
		dispSpellDmgM = dispSpellDmgM + hybridDmgM

		if calculation.eDuration > baseDuration then 
			calcDotDmg = calcDotDmg + ( calcDotDmg / baseDuration ) * ( calculation.eDuration - baseDuration )
		end
	end

	--For spells that can ignite
	if calculation.igniteM then
		igniteDotDmg = calculation.igniteM * (( calcMinCrit + calcMaxCrit ) / 2 )
		calcAvgDmgCrit = calcAvgDmgCrit + ( calculation.critPerc / 100 ) * igniteDotDmg
	end

	--For spells with extra DOT portion eg. fireball
	if spell.extraDotDmg then
		calcDotDmg = calcDotDmg + calculation.dmgM * spell.extraDotDmg
		if baseSpell.extraDotF then 
			calcDotDmg = calcDotDmg + calculation.dmgM * baseSpell.extraDotF * calculation.lowRankFactor * calculation.lowLevelFactor * calculation.spellDmg
			dispSpellDmgM = dispSpellDmgM + baseSpell.extraDotF * calculation.lowRankFactor * calculation.lowLevelFactor
		end
	end
	
	calcDotDmg = calcDotDmg + calculation.dotFinalMod

	--For chain effects (chain lightning, chain heal)
	local chainEffect

	if calculation.chainFactor then
		chainEffect = calcAvgDmgCrit * ( calculation.chainFactor + ( calculation.chainFactor ^ 2 ) + ( calculation.chainFactor ^ 3 ) )
		calcAvgDmgCrit = calcAvgDmgCrit + chainEffect
	end
	
	if baseSpell.Stacks then
		if spell.extraDotDmg then
			perHit = calcAvgDmgCrit
			ticks = "~" .. baseSpell.Stacks
			calcAvgDmgCrit = calcAvgDmgCrit + spell.extraDotDmg * (baseSpell.Stacks - 1) * calculation.dmgM
		end
	end
	
	--Special cases:
	if spellName == "Seed of Corruption" then
		perHit = calcDotDmg / 6
		ticks = math_ceil( 1044 / perHit )
		calcDotDmg = 0 --ticks * perHit
		dispSpellDmgM =  dispSpellDmgM - hybridDmgM + ( hybridDmgM / 6 ) * ticks
	end
	
	--Hit calculation:
	if calculation.hitPerc > 99 then
		calculation.hitPerc = 99
	end	
	if not calculation.healingSpell and not baseSpell.Unresistable then
		if settings.HitCalc or hitCalc then
			if settings.TwoRoll then
				calcAvgDmgCrit = calcAvgDmgCrit * ( calculation.hitPerc / 100 )
			else
				calcAvgDmgCrit = ( calcAvgDmgCrit - critBonus ) * ( calculation.hitPerc / 100 ) + critBonus
			end
			calcAvgDmgCrit = calcAvgDmgCrit - calcDotDmg * (1 - ( calculation.hitPerc / 100))
		end
	end	

	--DPS calculations
	--[[
	if calculation.castTime < 1.5 and baseSpell.Instant then
		calculation.castTime = 1.5
	end
	--]]

	if baseSpell.eDot or spell.hybridDotDmg then
		calcDPS = ( calcAvgDmgCrit + calcDotDmg ) / calculation.eDuration
	elseif baseSpell.Stacks then
		calcDPS = calcAvgDmgCrit / baseSpell.StacksDuration
	elseif spell.extraDotDmg then
		calcDPS = calcAvgDmgCrit / calculation.castTime + calcDotDmg / calculation.eDuration
	else
		calcDPS = calcAvgDmgCrit / calculation.castTime
	end

	calcAvgDmgCrit = calcAvgDmgCrit + calcDotDmg
	
	if spellName == "Seed of Corruption" then
		calcDotDmg = ticks * perHit
	end

	if nextCalc then
		return calcAvgDmgCrit
	else
		local MaxCritDmg = calcDotDmg

		if calcMaxCrit then MaxCritDmg = MaxCritDmg + calcMaxCrit else MaxCritDmg = MaxCritDmg + calcMaxDmg end
		if igniteDotDmg then MaxCritDmg = MaxCritDmg + igniteDotDmg end
		if extraDmg then MaxCritDmg = MaxCritDmg + extraDmg end
		if chainEffect then MaxCritDmg = MaxCritDmg + chainEffect end
		MaxCritDmg = math_ceil( MaxCritDmg )

		if tooltip or manaCalc then
			DrD_ClearTable( CalculationResults )
		end

		--Write tooltip data
		if tooltip then
			if DrD_MatchData( baseSpell.School, "Judgement" ) then
				CalculationResults.Name = spellName
			end
		
			if baseSpell.Cooldown then
				CalculationResults.DPSCD = 	DrD_Round( calcAvgDmgCrit / calculation.cooldown, 1 )
			end

			if baseSpell.canCrit then
				CalculationResults.MinCrit =	math_floor( calcMinCrit )
				CalculationResults.MaxCrit = 	math_ceil( calcMaxCrit )
				CalculationResults.AvgCrit = 	math_floor( ( calcMinCrit + calcMaxCrit ) / 2 + 0.5 )
				CalculationResults.CritRate = 	DrD_Round( calculation.critPerc, 2 )

				--Lightning capacitor
				if not calculation.healingSpell and IsEquippedItem( 28785 ) and not DrD_MatchData( baseSpell.School, "OffensiveTotem", "Physical" ) then
					extraDmg = ( (( 694 + 806 ) / 2 ) * ( 1 + ( GetSpellCritChance(schoolTable["Nature"]) / 100 ) * 0.5 ) ) / ( 300 / calculation.critPerc )

					if calculation.sHits then
						extraDmg = calculation.sHits * extraDmg
					end

					extraDPS = extraDmg / calculation.castTime
				end
			end

			CalculationResults.HitRate = 	DrD_Round( calculation.hitPerc, 2 )
			CalculationResults.DotDmg = 	math_floor( calcDotDmg + 0.5 )
			CalculationResults.SpellDmg = 	math_floor( calculation.spellDmg + 0.5 )
			CalculationResults.SpellDmgM = 	DrD_Round( dispSpellDmgM, 3 )
			CalculationResults.DmgM = 	DrD_Round( calculation.dmgM, 3 )
			
			CalculationResults.CastTime = 	calculation.castTime
			CalculationResults.Cooldown = 	calculation.cooldown			

			if igniteDotDmg then
				CalculationResults.IgniteDmg = 	math_floor( igniteDotDmg + 0.5 )
			end
			if chainEffect then 
				CalculationResults.ChainDmg = 	math_floor( chainEffect + 0.5 ) 
			end
			if extraDPS then
				CalculationResults.ExtraDPS = 	DrD_Round( extraDPS, 1 )
			end

			if not perHit and not ticks then
				local sTicks = baseSpell.sTicks or spell.sTicks
			
				if calculation.sHits then
					ticks = calculation.sHits
					perHit = calcAvgDmg / ticks
				elseif sTicks then
					if calculation.castTime > calculation.eDuration then
						ticks = (spell.castTime or baseSpell.castTime or 1.5) / sTicks
					else
						ticks = calculation.eDuration / sTicks
					end
					if spell.hybridDotDmg or spell.extraDotDmg then
						perHit = calcDotDmg / ticks
					else
						perHit = calcAvgDmg / ticks
					end
				end
			end

			if perHit and ticks then
				CalculationResults.PerHit = DrD_Round( perHit, 1 )
				CalculationResults.Hits = ticks
			end				

			if baseSpell.Leech and calculation.LeechBonus then
				CalculationResults.AvgLeech = DrD_Round( calcAvgDmgCrit * calculation.LeechBonus, 1 )

				if perHit then
					CalculationResults.PerHitHeal =  DrD_Round( perHit * calculation.LeechBonus, 1 )
				end
			end
		end
		if manaCalc then
			local manaCost
			
			if GT:GetLine(2) and Mana_Cost then
				manaCost = Deformat(GT:GetLine(2), Mana_Cost)
			end

			if manaCost then
				manaCost = tonumber(manaCost) * (calculation.costM or 1)
				if manaCost == 0 then
					CalculationResults.castsBase = "\226\136\158"
					CalculationResults.DPM = "\226\136\158"
					CalculationResults.ManaCost = 0
					CalculationResults.TrueManaCost = 0
					CalculationResults.MPS = 0
				else
					if calculation.freeCrit and calculation.CritRate and calculation.CritRate < 100 then
						CalculationResults.TrueManaCost = DrD_Round(manaCost * (1 - (calculation.critPerc / 100) * calculation.freeCrit), 1)
						CalculationResults.DPM = DrD_Round(calcAvgDmgCrit / CalculationResults.TrueManaCost, 1)
						CalculationResults.MPS = DrD_Round(CalculationResults.TrueManaCost / calculation.castTime, 1)

					else
						CalculationResults.TrueManaCost = manaCost
						CalculationResults.DPM = DrD_Round(calcAvgDmgCrit / manaCost, 1)
						CalculationResults.MPS = DrD_Round(manaCost / calculation.castTime, 1)
					end

					local PlayerMana
					
					if UnitPowerType("player") == 0 then
						PlayerMana = UnitMana("player")
					else
						PlayerMana = DrDamage.lastMana
					end
					
					PlayerMana = PlayerMana + calculation.manaMod
						
					CalculationResults.castsBase = DrD_FreeCrits(math_floor(PlayerMana / manaCost), baseSpell.canCrit, calculation.freeCrit, calculation.critPerc)
					CalculationResults.ManaCost = manaCost

					if tooltip then
						local regen = 0
						local regenCasts = 0
						local castTime = math_max(calculation.cooldown, calculation.castTime)

						if castTime <= 10 and not baseSpell.eDot then
							regen = math_floor(PlayerMana / manaCost) * castTime * calculation.manaRegen
							local newCasts = DrD_FreeCrits(math_floor(regen / manaCost), baseSpell.canCrit, calculation.freeCrit, calculation.critPerc)
							regenCasts = newCasts

							for i = 1, 5 do
								local newRegen = newCasts * castTime * calculation.manaRegen
								newCasts = DrD_FreeCrits(math_floor(newRegen / manaCost), baseSpell.canCrit, calculation.freeCrit, calculation.critPerc)
								regen = regen + newRegen
								regenCasts = regenCasts + newCasts

								if newCasts == 0 then break end
							end

							CalculationResults.SOOM = DrD_Round((CalculationResults.castsBase + regenCasts) * castTime, 1)
						end

						if (CalculationResults.castsBase + regenCasts) > 1000 then
							CalculationResults.castsBase = "\226\136\158"
							CalculationResults.SOOM = nil
						end

						CalculationResults.DOOM = math_floor(CalculationResults.DPM * (PlayerMana + regen) + 0.5)
						if CalculationResults.DOOM > 1000000 then CalculationResults.DOOM = "1000000+" end
						CalculationResults.castsRegen = regenCasts
					end
				end
			end
		end		

		return calcAvgDmgCrit, DrD_Round( calcDPS, 1 ), DrD_Round( calcAvgDmgCrit / calculation.castTime, 1 ), math_floor( calcAvgDmg + 0.5 ), math_floor( calcMinDmg ), math_ceil( calcMaxDmg ), math_floor( calcAvgDmg + calcDotDmg + 0.5 ), MaxCritDmg
	end
end

DrD_TalentCalc = function( baseSpell, talentName, talentRank, talent )
	local modType = talent.ModType
	local talentValue

	if type( talent.Effect ) == "table" then
		talentValue = talent.Effect[talentRank]
	else
		talentValue = talent.Effect * talentRank
	end		

	if not modType then
		if talent.Add then
			calculation.dmgM_AddTalent = calculation.dmgM_AddTalent + talentValue
		else
			calculation.dmgM = calculation.dmgM * ( 1 + talentValue )	
		end					
	elseif modType == "SpellDamage" then
		if talent.Multiply then
			calculation.spellDmgM = calculation.spellDmgM * ( 1 + talentValue )
		else
			calculation.spellDmgM_AddTalent = calculation.spellDmgM_AddTalent + talentValue
		end
	elseif modType == "Crit" then
		calculation.critPerc = calculation.critPerc + talentValue
	elseif modType == "Hit" then
		calculation.hitPerc = calculation.hitPerc + talentValue							
	elseif modType == "CastTime" then
		if baseSpell.CastMod then
			calculation.castTime = calculation.castTime - baseSpell.CastMod * talentValue
		end
		--if baseSpell.CastModDmg then
		--	calculation.castModDmg = 1 - baseSpell.CastModDmg * talentValue
		--end
	elseif modType == "BaseNuke" then
		calculation.bNukeDmg = talentValue
	elseif modType == "BaseDamage" then
		calculation.bDmgM = calculation.bDmgM + talentValue
	elseif modType == "DotSpellDamage" then
		if talent.Multiply then
			calculation.dotSpellDmgM = calculation.dotSpellDmgM  * ( 1 + talentValue )
		else
			calculation.dotSpellDmgM = calculation.dotSpellDmgM + talentValue
		end
	elseif modType == "CritMultiplier" then
		calculation.critM = calculation.critM + talentValue
	elseif modType == "SpellDuration" then
		calculation.eDuration = calculation.eDuration + talentValue
	elseif modType == "Cooldown" then
		calculation.cooldown = calculation.cooldown - talentValue	
	elseif modType == "BuffTalentRanks" then
		BuffTalentRanks[talentName] = talentValue
	elseif modType == "FreeCrit" then
		calculation.freeCrit = talentValue
	end

	if modType then
		if DrDamage.Calculation[modType] then DrDamage.Calculation[modType]( calculation, talentValue ) end
	end				
end

DrD_BuffCalc = function( bName, bData, index, apps, texture, rank, spellName )
	local modType = bData.ModType
	
	if bData.ActiveAura then
		if apps and apps > 0 then
			ActiveAuras[bName] = apps
		else
			ActiveAuras[bName] = ( ActiveAuras[bName] or 0 ) + 1
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
		elseif modType == "RankTable" then
			calculation.spellDmg = calculation.spellDmg + bData.Value[rank]
		elseif modType == "RankTable2" then
			if spellName == bData.Spell[1] then
				calculation.finalMod = calculation.finalMod + bData.Value[rank] * calculation.lowRankFactor * calculation.lowLevelFactor * calculation.dmgM
			elseif spellName == bData.Spell[2] then
				calculation.finalMod = calculation.finalMod + bData.Value2[rank] * calculation.lowRankFactor * calculation.lowLevelFactor * calculation.dmgM
			end
		elseif modType == "JotC" then
			ActiveAuras[bName] = bData.Value[rank]											
		end
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
	elseif bData.Apps2 then
		calculation.dmgM = calculation.dmgM * ( 1 + apps * bData.Value2 )
	elseif modType == "CastTime" then
		if bData.Value < 0 then
			calculation.castTime = calculation.castTime + bData.Value
		else
			calculation.castTime = calculation.castTime / bData.Value
		end
	elseif modType == "BaseDamage" then
		calculation.bDmgM = calculation.bDmgM + bData.Value
	elseif modType == "SpellDamage" then
		calculation.spellDmgM = calculation.spellDmgM + bData.Value
	elseif modType == "Crit" then
		calculation.critPerc = calculation.critPerc + bData.Value
	elseif modType == "Hit" then
		calculation.hitPerc = calculation.hitPerc + bData.Value
	elseif not modType then
		calculation.dmgM = calculation.dmgM * ( 1 + bData.Value )
	end
end