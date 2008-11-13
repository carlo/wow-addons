--[[
Name: RatingBuster deDE locale (incomplete)
Revision: $Revision: 1 $
Translated by:
- Runenstetter@Nathrezim.EU
]]
local L = AceLibrary("AceLocale-2.2"):new("RatingBuster")
----
-- This file is coded in UTF-8
-- If you don't have a editor that can save in UTF-8, I recommend Ultraedit
----
L:RegisterTranslations("deDE", function() return {
	---------------------------
	-- Slash Command Options --
	---------------------------
	-- /rb itemid
	["Show ItemID"] = "Zeige ItemID",
	["Show the ItemID in tooltips"] = "ItemID im Tooltip ein/ausschalten",
	-- /rb itemlevel
	["Show ItemLevel"] = "Zeige ItemLevel",
	["Show the ItemLevel in tooltips"] = "ItemLevel im Tooltip ein/ausschalten",
	-- /rb usereqlv
	["Use required level"] = "Nutze benötigten level",
	["Calculate using the required level if you are below the required level"] = "Nutze benötigten level, wenn du unter dem benötigten level bist",
	-- /rb level
	["Set level"] = "Level des Ziels",
	--["Set the level used in calculations (0 = your level)"] = "ändert den Level des Ziels, der in der Berechnung benutzt wird",
	-----------------------
	-- Item Level and ID --
	-----------------------
	-- ["ItemLevel: "] = true,
	-- ["ItemID: "] = true,
	-----------------------
	-- Matching Patterns --
	-----------------------
	["numberPatterns"] = {
		{pattern = " um (%d+)", addInfo = "AfterNumber",},
		{pattern = "%+(%d+)", addInfo = "AfterStat",},
	},
	["separators"] = {
		"/", " und ", ",", "%. ",
	},
	["statList"] = {
		{pattern = string.lower(SPELL_STAT1_NAME), id = SPELL_STAT1_NAME}, -- Strength
		{pattern = string.lower(SPELL_STAT2_NAME), id = SPELL_STAT2_NAME}, -- Agility
		{pattern = string.lower(SPELL_STAT3_NAME), id = SPELL_STAT3_NAME}, -- Stamina
		{pattern = string.lower(SPELL_STAT4_NAME), id = SPELL_STAT4_NAME}, -- Intellect
		{pattern = string.lower(SPELL_STAT5_NAME), id = SPELL_STAT5_NAME}, -- Spirit
		{pattern = "verteidigungswertung", id = CR_DEFENSE_SKILL},
		{pattern = "ausweichwertung", id = CR_DODGE},
		{pattern = "blockwertung", id = CR_BLOCK},
		{pattern = "parierwertung", id = CR_PARRY},


		{pattern = "kritische zaubertrefferwertung", id = CR_CRIT_SPELL},
		{pattern = "zaubertrefferwertung", id = CR_HIT_SPELL},

		{pattern = "kritische distanztrefferwertung", id = CR_CRIT_RANGED},
		{pattern = "distanztrefferwertung", id = CR_HIT_RANGED},

		{pattern = "kritische trefferwertung", id = CR_CRIT_MELEE},
		{pattern = "trefferwertung", id = CR_HIT_MELEE},


		{pattern = "abhärtungswertung", id = CR_CRIT_TAKEN_MELEE}, -- resilience is implicitly a rating

		{pattern = "zaubertempowertung", id = CR_HASTE_SPELL},
		{pattern = "distanzangriffstempowertung", id = CR_HASTE_RANGED},
		{pattern = "angriffstempowertung", id = CR_HASTE_MELEE},
		-- {pattern = "speed rating", id = CR_HASTE_MELEE}, -- [Drums of Battle]

		{pattern = "fertigkeitswertung", id = CR_WEAPON_SKILL},

		--{pattern = "hit avoidance rating", id = CR_HIT_TAKEN_MELEE},
		--[[
		{pattern = "fertigkeitswertung für dolche", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für schwerter", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für zweihandschwerter", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für äxte", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für bögen", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für armbrüste", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für schusswaffen", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für %'wilden kampf%'", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für streitkolben", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für stangenwaffen", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für stäbe", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für zweihandäxte", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für zweihandstreitkolben", id = CR_WEAPON_SKILL},
		{pattern = "fertigkeitswertung für faustwaffen", id = CR_WEAPON_SKILL},
		--]]
	},
} end)
