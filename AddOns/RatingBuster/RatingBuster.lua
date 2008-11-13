--[[
Name: RatingBuster
Revision: $Revision: 51966 $
Developed by: Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
Description: Converts combat ratings in tooltips into normal percentages.
]]

---------------
-- Libraries --
---------------
local TipHooker = AceLibrary("TipHooker-1.0")
local StatLogic = AceLibrary("StatLogic-1.0")
local Waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")
local L = AceLibrary("AceLocale-2.2"):new("RatingBuster")
local BC = AceLibrary("Babble-Class-2.2")
local BI = AceLibrary("Babble-Inventory-2.2")


--------------------
-- AceAddon Setup --
--------------------
-- AceAddon Initialization
RatingBuster = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "AceConsole-2.0", "AceEvent-2.0", "AceDebug-2.0")
RatingBuster.title = "Rating Buster"
RatingBuster.version = "1.2.8 (r"..gsub("$Revision: 51966 $", "(%d+)", "%1")..")"
RatingBuster.date = gsub("$Date: 2007-10-14 15:32:29 +0800 (星期日, 14 十月 2007) $", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1")


-------------------
-- Set Debugging --
-------------------
RatingBuster:SetDebugging(false)


-----------
-- Cache --
-----------
local cache = {}
setmetatable(cache, {__mode = "kv"}) -- weak table to enable garbage collection
local function clearCache()
	for k in pairs(cache) do
		cache[k] = nil
	end
end
--debug
--RatingBuster.cache = cache


---------------------
-- Local Variables --
---------------------
local _
local _, class = UnitClass("player")
local calcLevel, playerLevel
local profileDB, classDB -- Initialized in :OnInitialize()

-- Localize globals
local _G = getfenv(0)
local strfind = strfind
local strsub = strsub
local gsub = gsub
local pairs = pairs
local ipairs = ipairs
local type = type
local select = select
local tinsert = tinsert
local tremove = tremove
local strsplit = strsplit
local strjoin = strjoin
local unpack = unpack
local tonumber = tonumber

local GetItemInfoCached = setmetatable({}, { __index = function(self, n)
	self[n] = {GetItemInfo(n)} -- store in cache
	return self[n] -- return result
end })
local GetItemInfo = function(item)
	return unpack(GetItemInfoCached[item])
end
local GetParryChance = GetParryChance
local GetBlockChance = GetBlockChance

---------------------
-- Saved Variables --
---------------------
-- Register DB
RatingBuster:RegisterDB("RatingBusterDB")
-- Default values
local profileDefault = {
	showItemLevel = true,
	showItemID = false,
	useRequiredLevel = false,
	customLevel = 0,
	textColor = {r = 1.0, g = 0.996,  b = 0.545, hex = "|cfffffe8b"},
	enableTextColor = true,
	enableStatMods = true,
	showRatings = true,
	detailedConversionText = false,
	defBreakDown = false,
	wpnBreakDown = false,
	expBreakDown = false,
	showStats = true,
	showSum = true,
	sumIgnoreUnused = true,
	sumIgnoreEquipped = false,
	sumIgnoreEnchant = false,
	sumIgnoreGems = false,
	sumBlankLine = true,
	sumBlankLineAfter = false,
	sumShowIcon = true,
	sumShowTitle = true,
	sumDiffStyle = "main",
	showZeroValueStat = false,
	calcDiff = true,
	calcSum = true,
}
--[[
Str -> AP, Block, Healing
Agi -> Crit, Dodge, AP, RAP, Armor
Sta -> Health, SpellDmg
Int -> Mana, SpellCrit, SpellDmg, Healing, MP5, RAP, Armor
Spi -> MP5, MP5NC, HP5, SpellDmg, Healing
--]]
local classDefault = {
	-- Base stat conversions
	showAPFromStr = false,
	showBlockValueFromStr = false,
	showHealingFromStr = false, -- druid
	
	showCritFromAgi = true,
	showDodgeFromAgi = true,
	showAPFromAgi = false,
	showRAPFromAgi = false,
	showArmorFromAgi = false,
	
	showHealthFromSta = false,
	showSpellDmgFromSta = false, -- warlock
	
	showManaFromInt = false,
	showSpellCritFromInt = true,
	showSpellDmgFromInt = false, -- Druid, Mage, Paladin, Shaman, Warlock
	showHealingFromInt = false, -- Druid, Paladin, Shaman
	showMP5FromInt = false, -- Druid, Shaman
	showRAPFromInt = false, -- Hunter
	showArmorFromInt = false, -- Mage
	
	showMP5FromSpi = false, -- Druid, Mage, Priest
	showMP5NCFromSpi = false,
	showHP5FromSpi = false,
	showSpellDmgFromSpi = false, -- Priest
	showHealingFromSpi = false, -- Priest
	
	-- Stat Summary
	-- statbase
	sumHP = false,
	sumMP = false,
	sumAP = false,
	sumRAP = false,
	sumFAP = false,
	sumSpellDmg = false,
	sumArcaneDmg = false,
	sumFrostDmg = false,
	sumNatureDmg = false,
	sumFireDmg = false,
	sumShadowDmg = false,
	sumHolyDmg = false,
	sumHealing = false,
	sumHit = false,
	sumCrit = false,
	sumSpellHit = false,
	sumSpellCrit = false,
	sumDodge = false,
	sumParry = false,
	sumBlock = false,
	sumBlockValue = false,
	sumArmor = false,
	sumMP5 = false,
	sumHP5 = false,
	sumMP5NC = false,
	sumHP5OC = false,
	sumHitAvoid = false,
	sumCritAvoid = false,
	sumDodgeNeglect = false,
	sumParryNeglect = false,
	sumBlockNeglect = false,
	sumArcaneResist = false,
	sumFrostResist = false,
	sumNatureResist = false,
	sumFireResist = false,
	sumShadowResist = false,
	sumWeaponMaxDamage = false,
	sumWeaponDPS = false,
	
	-- statcomposite
	sumStr = false,
	sumAgi = false,
	sumSta = false,
	sumInt = false,
	sumSpi = false,
	sumDefense = false,
	sumWeaponSkill = false,
	sumExpertise = false,
	sumTankPoints = false,
	sumTotalReduction = false,
	sumAvoidance = false,
}

if class == "DRUID" then
	classDefault.showHealingFromStr = true
end
if class == "PRIEST" or class == "MAGE" or class == "WARLOCK" then
	classDefault.showCritFromAgi = false
end
if class == "PRIEST" or class == "MAGE" or class == "WARLOCK" or class == "HUNTER" then
	classDefault.showDodgeFromAgi = false
end
if class == "WARLOCK" then
	classDefault.showSpellDmgFromSta = true
end
if class == "WARRIOR" or class == "ROGUE" or class == "HUNTER" then
	classDefault.showSpellCritFromInt = false
end
if class == "DRUID" or class == "MAGE" or class == "PALADIN" or class == "SHAMAN" or class == "WARLOCK" then
	classDefault.showSpellDmgFromInt = true
end
if class == "DRUID" or class == "PALADIN" or class == "SHAMAN" then
	classDefault.showHealingFromInt = true
end
if class == "DRUID" or class == "SHAMAN" then
	classDefault.showMP5FromInt = true
end
if class == "HUNTER" then
	classDefault.showRAPFromInt = true
end
if class == "MAGE" then
	classDefault.showArmorFromInt = true
end
if class == "DRUID" or class == "MAGE" or class == "PRIEST" then
	classDefault.showMP5FromSpi = true
end
if class == "PRIEST" then
	classDefault.showSpellDmgFromSpi = true
end
if class == "PRIEST" then
	classDefault.showHealingFromSpi = true
end
-- Stat Summary
if class == "WARRIOR" then
	classDefault.sumHP = true
	classDefault.sumAP = true
	classDefault.sumHit = true
	classDefault.sumCrit = true
end
if class == "PALADIN" then
	classDefault.sumHP = true
	classDefault.sumMP = true
	classDefault.sumHolyDmg = true
	classDefault.sumHealing = true
	classDefault.sumMP5 = true
end
if class == "HUNTER" then
	classDefault.sumRAP = true
	classDefault.sumHit = true
	classDefault.sumCrit = true
	classDefault.sumMP5 = true
end
if class == "ROGUE" then
	classDefault.sumHP = true
	classDefault.sumAP = true
	classDefault.sumHit = true
	classDefault.sumCrit = true
end
if class == "PRIEST" then
	classDefault.sumMP = true
	classDefault.sumSpellDmg = true
	classDefault.sumHealing = true
	classDefault.sumMP5 = true
end
if class == "SHAMAN" then
	classDefault.sumMP = true
	classDefault.sumSpellDmg = true
	classDefault.sumHealing = true
	classDefault.sumSpellCrit = true
	classDefault.sumMP5 = true
end
if class == "MAGE" then
	classDefault.sumHP = true
	classDefault.sumMP = true
	classDefault.sumSpellDmg = true
	classDefault.sumSpellCrit = true
	classDefault.sumMP5 = true
end
if class == "WARLOCK" then
	classDefault.sumHP = true
	classDefault.sumMP = true
	classDefault.sumSpellDmg = true
	classDefault.sumSpellCrit = true
end
if class == "DRUID" then
	classDefault.sumHP = true
	classDefault.sumMP = true
	classDefault.sumFAP = true
	classDefault.sumSpellDmg = true
	classDefault.sumHealing = true
	classDefault.sumMP5 = true
	classDefault.sumDodge = true
	classDefault.sumArmor = true
end

-- Register Defaults
RatingBuster:RegisterDefaults("profile", profileDefault)
RatingBuster:RegisterDefaults("class", classDefault)


---------------------------
-- Slash Command Options --
---------------------------

local function getProfileOption(key)
	return profileDB[key]
end
local function setProfileOptionAndClearCache(key, value)
	profileDB[key] = value
	clearCache()
end
local function setProfileOption(key, value)
	profileDB[key] = value
end

local function getClassOption(key)
	return classDB[key]
end
local function setClassOptionAndClearCache(key, value)
	classDB[key] = value
	clearCache()
end

local consoleOptions = {
	type = 'group',
	args = {
		optionswin = {
			type = "execute",
			name = L["Options Window"],
			desc = L["Shows the Options Window"],
			func = function()
				if Waterfall then
					Waterfall:Open("RatingBuster")
				else
					RatingBuster:Print(L["Waterfall-1.0 is required to access the GUI."])
				end
			end,
		},
		statmod = {
			type = 'toggle',
			name = L["Enable Stat Mods"],
			desc = L["Enable support for Stat Mods"],
			passValue = "enableStatMods",
			get = getProfileOption,
			set = setProfileOptionAndClearCache,
		},
		itemid = {
			type = 'toggle',
			name = L["Show ItemID"],
			desc = L["Show the ItemID in tooltips"],
			passValue = "showItemID",
			get = getProfileOption,
			set = setProfileOptionAndClearCache,
		},
		itemlevel = {
			type = 'toggle',
			name = L["Show ItemLevel"],
			desc = L["Show the ItemLevel in tooltips"],
			passValue = "showItemLevel",
			get = getProfileOption,
			set = setProfileOptionAndClearCache,
		},
		usereqlv = {
			type = 'toggle',
			name = L["Use required level"],
			desc = L["Calculate using the required level if you are below the required level"],
			passValue = "useRequiredLevel",
			get = getProfileOption,
			set = setProfileOption,
		},
		level = {
			type = 'range',
			name = L["Set level"],
			desc = L["Set the level used in calculations (0 = your level)"],
			passValue = "customLevel",
			get = getProfileOption,
			set = setProfileOption,
			min = 0,
			max = 73, -- set to level cap + 3
			step = 1,
		},
		rating = {
			type = 'group',
			name = L["Rating"],
			desc = L["Options for Rating display"],
			args = {
				show = {
					type = 'toggle',
					name = L["Show Rating conversions"],
					desc = L["Show Rating conversions in tooltips"],
					passValue = "showRatings",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				detail = {
					type = 'toggle',
					name = L["Show detailed conversions text"],
					desc = L["Show detailed text for Resiliance and Expertise conversions"],
					passValue = "detailedConversionText",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				def = {
					type = 'toggle',
					name = L["Defense breakdown"],
					desc = L["Convert Defense into Crit Avoidance, Hit Avoidance, Dodge, Parry and Block"],
					passValue = "defBreakDown",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				wpn = {
					type = 'toggle',
					name = L["Weapon Skill breakdown"],
					desc = L["Convert Weapon Skill into Crit, Hit, Dodge Neglect, Parry Neglect and Block Neglect"],
					passValue = "wpnBreakDown",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				exp = {
					type = 'toggle',
					name = L["Expertise breakdown"],
					desc = L["Convert Expertise into Dodge Neglect and Parry Neglect"],
					passValue = "expBreakDown",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				color = {
					type = 'group',
					name = L["Change text color"],
					desc = L["Changes the color of added text"],
					args = {
						pick = {
							type = 'execute',
							name = L["Pick color"],
							desc = L["Pick a color"],
							func = function()
								CloseMenus()
								ColorPickerFrame.func = function()
									profileDB.textColor.r, profileDB.textColor.g, profileDB.textColor.b = ColorPickerFrame:GetColorRGB();
									profileDB.textColor.hex = "|cff"..string.format("%02x%02x%02x", profileDB.textColor.r * 255, profileDB.textColor.g * 255, profileDB.textColor.b * 255)
									-- clear cache
									clearCache()
								end
								ColorPickerFrame:SetColorRGB(profileDB.textColor.r, profileDB.textColor.g, profileDB.textColor.b);
								ColorPickerFrame.previousValues = {r = profileDB.textColor.r, g = profileDB.textColor.g, b = profileDB.textColor.b};
								ColorPickerFrame:Show()
							end,
						},
						enable = {
							type = 'toggle',
							name = L["Enable color"],
							desc = L["Enable colored text"],
							passValue = "enableTextColor",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
					},
				},
			},
		},
		stat = {
			type = 'group',
			name = L["Stat"],
			desc = L["Changes the display of base stats"],
			args = {
				show = {
					type = 'toggle',
					name = L["Show base stat conversions"],
					desc = L["Show base stat conversions in tooltips"],
					passValue = "showStats",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				str = {
					type = 'group',
					name = L["Strength"],
					desc = L["Changes the display of Strength"],
					args = {
						ap = {
							type = 'toggle',
							name = L["Show Attack Power"],
							desc = L["Show Attack Power from Strength"],
							passValue = "showAPFromStr",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						block = {
							type = 'toggle',
							name = L["Show Block Value"],
							desc = L["Show Block Value from Strength"],
							passValue = "showBlockValueFromStr",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						heal = {
							type = 'toggle',
							name = L["Show Healing"].." ("..BC["Druid"]..")",
							desc = L["Show Healing from Strength"].." ("..BC["Druid"]..")",
							passValue = "showHealingFromStr",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
				agi = {
					type = 'group',
					name = L["Agility"],
					desc = L["Changes the display of Agility"],
					args = {
						crit = {
							type = 'toggle',
							name = L["Show Crit"],
							desc = L["Show Crit chance from Agility"],
							passValue = "showCritFromAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dodge = {
							type = 'toggle',
							name = L["Show Dodge"],
							desc = L["Show Dodge chance from Agility"],
							passValue = "showDodgeFromAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						ap = {
							type = 'toggle',
							name = L["Show Attack Power"],
							desc = L["Show Attack Power from Agility"],
							passValue = "showAPFromAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						rap = {
							type = 'toggle',
							name = L["Show Ranged Attack Power"],
							desc = L["Show Ranged Attack Power from Agility"],
							passValue = "showRAPFromAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						armor = {
							type = 'toggle',
							name = L["Show Armor"],
							desc = L["Show Armor from Agility"],
							passValue = "showArmorFromAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
				sta = {
					type = 'group',
					name = L["Stamina"],
					desc = L["Changes the display of Stamina"],
					args = {
						hp = {
							type = 'toggle',
							name = L["Show Health"],
							desc = L["Show Health from Stamina"],
							passValue = "showHealthFromSta",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmg = {
							type = 'toggle',
							name = L["Show Spell Damage"].." ("..BC["Warlock"]..")",
							desc = L["Show Spell Damage from Stamina"].." ("..BC["Warlock"]..")",
							passValue = "showSpellDmgFromSta",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
				int = {
					type = 'group',
					name = L["Intellect"],
					desc = L["Changes the display of Intellect"],
					args = {
						spellcrit = {
							type = 'toggle',
							name = L["Show Spell Crit"],
							desc = L["Show Spell Crit chance from Intellect"],
							passValue = "showSpellCritFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp = {
							type = 'toggle',
							name = L["Show Mana"],
							desc = L["Show Mana from Intellect"],
							passValue = "showManaFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmg = {
							type = 'toggle',
							name = L["Show Spell Damage"].." ("..BC["Mage"]..", "..BC["Warlock"]..", "..BC["Druid"]..", "..BC["Shaman"]..", "..BC["Paladin"]..")",
							desc = L["Show Spell Damage from Intellect"].." ("..BC["Mage"]..", "..BC["Warlock"]..", "..BC["Druid"]..", "..BC["Shaman"]..", "..BC["Paladin"]..")",
							passValue = "showSpellDmgFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						heal = {
							type = 'toggle',
							name = L["Show Healing"].." ("..BC["Druid"]..", "..BC["Shaman"]..", "..BC["Paladin"]..")",
							desc = L["Show Healing from Intellect"].." ("..BC["Druid"]..", "..BC["Shaman"]..", "..BC["Paladin"]..")",
							passValue = "showHealingFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp5 = {
							type = 'toggle',
							name = L["Show Mana Regen"].." ("..BC["Druid"]..", "..BC["Shaman"]..")",
							desc = L["Show Mana Regen while casting from Intellect"].." ("..BC["Druid"]..", "..BC["Shaman"]..")",
							passValue = "showMP5FromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						rap = {
							type = 'toggle',
							name = L["Show Ranged Attack Power"].." ("..BC["Hunter"]..")",
							desc = L["Show Ranged Attack Power from Intellect"].." ("..BC["Hunter"]..")",
							passValue = "showRAPFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						armor = {
							type = 'toggle',
							name = L["Show Armor"].." ("..BC["Mage"]..")",
							desc = L["Show Armor from Intellect"].." ("..BC["Mage"]..")",
							passValue = "showArmorFromInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
				spi = {
					type = 'group',
					name = L["Spirit"],
					desc = L["Changes the display of Spirit"],
					args = {
						mp5 = {
							type = 'toggle',
							name = L["Show Mana Regen"].." ("..BC["Priest"]..", "..BC["Druid"]..", "..BC["Mage"]..")",
							desc = L["Show Mana Regen while casting from Spirit"].." ("..BC["Priest"]..", "..BC["Druid"]..", "..BC["Mage"]..")",
							passValue = "showMP5FromSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp5nc = {
							type = 'toggle',
							name = L["Show Mana Regen while NOT casting"],
							desc = L["Show Mana Regen while NOT casting from Spirit"],
							passValue = "showMP5NCFromSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						hp5 = {
							type = 'toggle',
							name = L["Show Health Regen"],
							desc = L["Show Health Regen from Spirit"],
							passValue = "showHP5FromSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmg = {
							type = 'toggle',
							name = L["Show Spell Damage"].." ("..BC["Priest"]..")",
							desc = L["Show Spell Damage from Spirit"].." ("..BC["Priest"]..")",
							passValue = "showSpellDmgFromSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						heal = {
							type = 'toggle',
							name = L["Show Healing"].." ("..BC["Priest"]..")",
							desc = L["Show Healing from Spirit"].." ("..BC["Priest"]..")",
							passValue = "showHealingFromSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
			},
		},
		sum = {
			type = 'group',
			name = L["Stat Summary"],
			desc = L["Options for stat summary"],
			args = {
				show = {
					type = 'toggle',
					name = L["Show stat summary"],
					desc = L["Show stat summary in tooltips"],
					passValue = "showSum",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				ignore = {
					type = 'group',
					name = L["Ignore settings"],
					desc = L["Ignore stuff when calculating the stat summary"],
					args = {
						unused = {
							type = 'toggle',
							name = L["Ignore unused items types"],
							desc = L["Show stat summary only for highest level armor type and items you can use with uncommon quality and up"],
							passValue = "sumIgnoreUnused",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
						equipped = {
							type = 'toggle',
							name = L["Ignore equipped items"],
							desc = L["Hide stat summary for equipped items"],
							passValue = "sumIgnoreEquipped",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
						enchant = {
							type = 'toggle',
							name = L["Ignore enchants"],
							desc = L["Ignore enchants on items when calculating the stat summary"],
							passValue = "sumIgnoreEnchant",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
						gem = {
							type = 'toggle',
							name = L["Ignore gems"],
							desc = L["Ignore gems on items when calculating the stat summary"],
							passValue = "sumIgnoreGems",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
					},
				},
				diffstyle = {
					type = 'text',
					name = L["Display style for diff value"],
					desc = L["Display diff values in the main tooltip or only in compare tooltips"],
					validate = {"comp", "main"},
					passValue = "sumDiffStyle",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				space = {
					type = 'group',
					name = L["Add empty line"],
					desc = L["Add a empty line before or after stat summary"],
					args = {
						before = {
							type = 'toggle',
							name = L["Add before summary"],
							desc = L["Add a empty line before stat summary"],
							passValue = "sumBlankLine",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
						after = {
							type = 'toggle',
							name = L["Add after summary"],
							desc = L["Add a empty line after stat summary"],
							passValue = "sumBlankLineAfter",
							get = getProfileOption,
							set = setProfileOptionAndClearCache,
						},
					},
				},
				icon = {
					type = 'toggle',
					name = L["Show icon"],
					desc = L["Show the sigma icon before summary listing"],
					passValue = "sumShowIcon",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				title = {
					type = 'toggle',
					name = L["Show title text"],
					desc = L["Show the title text before summary listing"],
					passValue = "sumShowTitle",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				showzerostat = {
					type = 'toggle',
					name = L["Show zero value stats"],
					desc = L["Show zero value stats in summary for consistancy"],
					passValue = "showZeroValueStat",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				calcsum = {
					type = 'toggle',
					name = L["Calculate stat sum"],
					desc = L["Calculate the total stats for the item"],
					passValue = "calcSum",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				calcdiff = {
					type = 'toggle',
					name = L["Calculate stat diff"],
					desc = L["Calculate the stat difference for the item and equipped items"],
					passValue = "calcDiff",
					get = getProfileOption,
					set = setProfileOptionAndClearCache,
				},
				stat = {
					type = 'group',
					name = L["Stat - Base"],
					desc = L["Choose base stats for summary"],
					args = {
						hp = {
							type = 'toggle',
							name = L["Sum Health"],
							desc = L["Health <- Health, Stamina"],
							passValue = "sumHP",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp = {
							type = 'toggle',
							name = L["Sum Mana"],
							desc = L["Mana <- Mana, Intellect"],
							passValue = "sumMP",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						ap = {
							type = 'toggle',
							name = L["Sum Attack Power"],
							desc = L["Attack Power <- Attack Power, Strength, Agility"],
							passValue = "sumAP",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						rap = {
							type = 'toggle',
							name = L["Sum Ranged Attack Power"],
							desc = L["Ranged Attack Power <- Ranged Attack Power, Intellect, Attack Power, Strength, Agility"],
							passValue = "sumRAP",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						fap = {
							type = 'toggle',
							name = L["Sum Feral Attack Power"],
							desc = L["Feral Attack Power <- Feral Attack Power, Attack Power, Strength, Agility"],
							passValue = "sumFAP",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmg = {
							type = 'toggle',
							name = L["Sum Spell Damage"],
							desc = L["Spell Damage <- Spell Damage, Intellect, Spirit, Stamina"],
							passValue = "sumSpellDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgholy = {
							type = 'toggle',
							name = L["Sum Holy Spell Damage"],
							desc = L["Holy Spell Damage <- Holy Spell Damage, Spell Damage, Intellect, Spirit"],
							passValue = "sumHolyDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgarcane = {
							type = 'toggle',
							name = L["Sum Arcane Spell Damage"],
							desc = L["Arcane Spell Damage <- Arcane Spell Damage, Spell Damage, Intellect"],
							passValue = "sumArcaneDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgfire = {
							type = 'toggle',
							name = L["Sum Fire Spell Damage"],
							desc = L["Fire Spell Damage <- Fire Spell Damage, Spell Damage, Intellect, Stamina"],
							passValue = "sumFireDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgnature = {
							type = 'toggle',
							name = L["Sum Nature Spell Damage"],
							desc = L["Nature Spell Damage <- Nature Spell Damage, Spell Damage, Intellect"],
							passValue = "sumNatureDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgfrost = {
							type = 'toggle',
							name = L["Sum Frost Spell Damage"],
							desc = L["Frost Spell Damage <- Frost Spell Damage, Spell Damage, Intellect"],
							passValue = "sumFrostDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dmgshadow = {
							type = 'toggle',
							name = L["Sum Shadow Spell Damage"],
							desc = L["Shadow Spell Damage <- Shadow Spell Damage, Spell Damage, Intellect, Spirit, Stamina"],
							passValue = "sumShadowDmg",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						heal = {
							type = 'toggle',
							name = L["Sum Healing"],
							desc = L["Healing <- Healing, Intellect, Spirit, Strength"],
							passValue = "sumHealing",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						hit = {
							type = 'toggle',
							name = L["Sum Hit Chance"],
							desc = L["Hit Chance <- Hit Rating, Weapon Skill Rating"],
							passValue = "sumHit",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						hitspell = {
							type = 'toggle',
							name = L["Sum Spell Hit Chance"],
							desc = L["Spell Hit Chance <- Spell Hit Rating"],
							passValue = "sumSpellHit",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						crit = {
							type = 'toggle',
							name = L["Sum Crit Chance"],
							desc = L["Crit Chance <- Crit Rating, Agility, Weapon Skill Rating"],
							passValue = "sumCrit",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						critspell = {
							type = 'toggle',
							name = L["Sum Spell Crit Chance"],
							desc = L["Spell Crit Chance <- Spell Crit Rating, Intellect"],
							passValue = "sumSpellCrit",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp5 = {
							type = 'toggle',
							name = L["Sum Mana Regen"],
							desc = L["Mana Regen <- Mana Regen, Spirit"],
							passValue = "sumMP5",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						mp5nc = {
							type = 'toggle',
							name = L["Sum Mana Regen while not casting"],
							desc = L["Mana Regen while not casting <- Spirit"],
							passValue = "sumMP5NC",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						hp5 = {
							type = 'toggle',
							name = L["Sum Health Regen"],
							desc = L["Health Regen <- Health Regen"],
							passValue = "sumHP5",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						hp5oc = {
							type = 'toggle',
							name = L["Sum Health Regen when out of combat"],
							desc = L["Health Regen when out of combat <- Spirit"],
							passValue = "sumHP5OC",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						armor = {
							type = 'toggle',
							name = L["Sum Armor"],
							desc = L["Armor <- Armor from items, Armor from bonuses, Agility, Intellect"],
							passValue = "sumArmor",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						blockvalue = {
							type = 'toggle',
							name = L["Sum Block Value"],
							desc = L["Block Value <- Block Value, Strength"],
							passValue = "sumBlockValue",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						dodge = {
							type = 'toggle',
							name = L["Sum Dodge Chance"],
							desc = L["Dodge Chance <- Dodge Rating, Agility, Defense Rating"],
							passValue = "sumDodge",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						parry = {
							type = 'toggle',
							name = L["Sum Parry Chance"],
							desc = L["Parry Chance <- Parry Rating, Defense Rating"],
							passValue = "sumParry",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						block = {
							type = 'toggle',
							name = L["Sum Block Chance"],
							desc = L["Block Chance <- Block Rating, Defense Rating"],
							passValue = "sumBlock",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						avoidhit = {
							type = 'toggle',
							name = L["Sum Hit Avoidance"],
							desc = L["Hit Avoidance <- Defense Rating"],
							passValue = "sumHitAvoid",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						avoidcrit = {
							type = 'toggle',
							name = L["Sum Crit Avoidance"],
							desc = L["Crit Avoidance <- Defense Rating, Resilience"],
							passValue = "sumCritAvoid",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						neglectdodge = {
							type = 'toggle',
							name = L["Sum Dodge Neglect"],
							desc = L["Dodge Neglect <- Expertise, Weapon Skill Rating"],
							passValue = "sumDodgeNeglect",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						neglectparry = {
							type = 'toggle',
							name = L["Sum Parry Neglect"],
							desc = L["Parry Neglect <- Expertise, Weapon Skill Rating"],
							passValue = "sumParryNeglect",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						neglectblock = {
							type = 'toggle',
							name = L["Sum Block Neglect"],
							desc = L["Block Neglect <- Weapon Skill Rating"],
							passValue = "sumBlockNeglect",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						resarcane = {
							type = 'toggle',
							name = L["Sum Arcane Resistance"],
							desc = L["Arcane Resistance Summary"],
							passValue = "sumArcaneResist",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						resfire = {
							type = 'toggle',
							name = L["Sum Fire Resistance"],
							desc = L["Fire Resistance Summary"],
							passValue = "sumFireResist",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						resnature = {
							type = 'toggle',
							name = L["Sum Nature Resistance"],
							desc = L["Nature Resistance Summary"],
							passValue = "sumNatureResist",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						resfrost = {
							type = 'toggle',
							name = L["Sum Frost Resistance"],
							desc = L["Frost Resistance Summary"],
							passValue = "sumFrostResist",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						resshadow = {
							type = 'toggle',
							name = L["Sum Shadow Resistance"],
							desc = L["Shadow Resistance Summary"],
							passValue = "sumShadowResist",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						maxdamage = {
							type = 'toggle',
							name = L["Sum Weapon Max Damage"],
							desc = L["Weapon Max Damage Summary"],
							passValue = "sumWeaponMaxDamage",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						--[[
						weapondps = {
							type = 'toggle',
							name = L["Sum Weapon DPS"],
							desc = L["Weapon DPS Summary"],
							get = function() return classDB.sumWeaponDPS end,
							set = function(v)
								classDB.sumWeaponDPS = v
								-- clear cache
								clearCache()
							end,
						},
						--]]
					},
				},
				statcomp = {
					type = 'group',
					name = L["Stat - Composite"],
					desc = L["Choose composite stats for summary"],
					args = {
						str = {
							type = 'toggle',
							name = L["Sum Strength"],
							desc = L["Strength Summary"],
							passValue = "sumStr",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						agi = {
							type = 'toggle',
							name = L["Sum Agility"],
							desc = L["Agility Summary"],
							passValue = "sumAgi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						sta = {
							type = 'toggle',
							name = L["Sum Stamina"],
							desc = L["Stamina Summary"],
							passValue = "sumSta",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						int = {
							type = 'toggle',
							name = L["Sum Intellect"],
							desc = L["Intellect Summary"],
							passValue = "sumInt",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						spi = {
							type = 'toggle',
							name = L["Sum Spirit"],
							desc = L["Spirit Summary"],
							passValue = "sumSpi",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						def = {
							type = 'toggle',
							name = L["Sum Defense"],
							desc = L["Defense <- Defense Rating"],
							passValue = "sumDefense",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						wpn = {
							type = 'toggle',
							name = L["Sum Weapon Skill"],
							desc = L["Weapon Skill <- Weapon Skill Rating"],
							passValue = "sumWeaponSkill",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						exp = {
							type = 'toggle',
							name = L["Sum Expertise"],
							desc = L["Expertise <- Expertise Rating"],
							passValue = "sumExpertise",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
						avoid = {
							type = 'toggle',
							name = L["Sum Avoidance"],
							desc = L["Avoidance <- Dodge, Parry, MobMiss"],
							passValue = "sumAvoidance",
							get = getClassOption,
							set = setClassOptionAndClearCache,
						},
					},
				},
			},
		},
	},
}

-- TankPoints support, version check
local tpSupport
local tpLocale
if TankPoints and (tonumber(strsub(TankPoints.version, 1, 3)) >= 2.6) then
	tpSupport = true
	tpLocale = AceLibrary("AceLocale-2.2"):new("TankPoints")
	consoleOptions.args.sum.args.statcomp.args.tp = {
		type = 'toggle',
		name = L["Sum TankPoints"],
		desc = L["TankPoints <- Health, Total Reduction"],
		passValue = "sumTankPoints",
		get = getClassOption,
		set = setClassOptionAndClearCache,
	}
	consoleOptions.args.sum.args.statcomp.args.tr = {
		type = 'toggle',
		name = L["Sum Total Reduction"],
		desc = L["Total Reduction <- Armor, Dodge, Parry, Block, Block Value, Defense, Resilience, MobMiss, MobCrit, MobCrush, DamageTakenMods"],
		passValue = "sumTotalReduction",
		get = getClassOption,
		set = setClassOptionAndClearCache,
	}
	--[[
	consoleOptions.args.sum.args.statcomp.args.avoid = {
		type = 'toggle',
		name = L["Sum Avoidance"],
		desc = L["Avoidance <- Dodge, Parry, MobMiss"],
		passValue = "sumAvoidance",
		get = getClassOption,
		set = setClassOptionAndClearCache,
	}
	--]]
end
-----------
-- Tools --
-----------
-- copyTable
local function copyTable(to, from)
	if to then
		for k in pairs(to) do
			to[k] = nil
		end
		setmetatable(to, nil)
	else
		to = {}
	end
	for k,v in pairs(from) do
		if type(k) == "table" then
			k = copyTable({}, k)
		end
		if type(v) == "table" then
			v = copyTable({}, v)
		end
		to[k] = v
	end
	setmetatable(to, getmetatable(from))
	return to
end


---------------------
-- Initializations --
---------------------
--[[ Loading Process Event Reference
{
ADDON_LOADED - When this addon is loaded
VARIABLES_LOADED - When all addons are loaded
PLAYER_LOGIN - Most information about the game world should now be available to the UI
}
--]]
-- OnInitialize(name) called at ADDON_LOADED
function RatingBuster:OnInitialize()
	profileDB = self.db.profile
	classDB = self.db.class

	self:RegisterChatCommand("/rb", "/ratingbuster", consoleOptions, "RATINGBUSTER")

	if Waterfall then
		Waterfall:Register("RatingBuster",
		"aceOptions", consoleOptions,
		"title", L["RatingBuster Options"])
	end
end

-- OnEnable() called at PLAYER_LOGIN
function RatingBuster:OnEnable()
	-- Hook item tooltips
	TipHooker:Hook(self.ProcessTooltip, "item")
	-- Initialize playerLevel
	playerLevel = UnitLevel("player")
	-- for setting a new level
	self:RegisterEvent("PLAYER_LEVEL_UP")
	-- Events that require cache clearing
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", clearCache) -- talent point changed
	self:RegisterEvent("UNIT_AURA", 1) -- fire at most once every 1 second
end

function RatingBuster:OnDisable()
	-- Unhook item tooltips
	TipHooker:Unhook(self.ProcessTooltip, "item")
end

-- event = PLAYER_LEVEL_UP
-- arg1 = New player level
function RatingBuster:PLAYER_LEVEL_UP(newlevel)
	playerLevel = newlevel
	clearCache()
end

-- event = UNIT_AURA
-- arg1 = the UnitID of the entity
function RatingBuster:UNIT_AURA(unit)
	if unit ~= "player" then return end
	clearCache()
end

--------------------------
-- Process Tooltip Core --
--------------------------
--[[
"+15 Agility"
-> "+15 Agility (+0.46% Crit)"
"+15 Crit Rating"
-> "+15 Crit Rating (+1.20%)"
"Equip: Increases your hit rating by 10."
-> "Equip: Increases your hit rating by 10 (+1.20%)."
--]]
function RatingBuster.ProcessTooltip(tooltip, name, link)
	-- Check if we're in standby mode
	--if not RatingBuster:IsActive() then return end
	---------------------------
	-- Set calculation level --
	---------------------------
	calcLevel = profileDB.customLevel or 0
	if calcLevel == 0 then
		calcLevel = playerLevel
	end
	if profileDB.useRequiredLevel and link then
		local _, _, _, _, reqLevel = GetItemInfo(link)
		--RatingBuster:Print(link..", "..calcLevel)
		if reqLevel and calcLevel < reqLevel then
			calcLevel = reqLevel
		end
	end
	---------------------
	-- Tooltip Scanner --
	---------------------
	-- Loop through tooltip lines starting at line 2
	local tipTextLeft = tooltip:GetName().."TextLeft"
	for i = 2, tooltip:NumLines() do
		local fontString = _G[tipTextLeft..i]
		local text = fontString:GetText()
		if text then -- do nothing if we don't find a number
			-- Get data from cache if available
			local cacheID = text..calcLevel
			local cacheText = cache[cacheID]
			if cacheText then
				if cacheText ~= text then
					fontString:SetText(cacheText)
				end
			elseif strfind(text, "%d") then
				-- Initial pattern check, do nothing if not found
				-- Check for separators and bulid separatorTable
				local separatorTable = {}
				for _, sep in ipairs(L["separators"]) do
					if strfind(text, sep) then
						tinsert(separatorTable, sep)
					end
				end
				-- SplitDoJoin
				text = RatingBuster:SplitDoJoin(text, separatorTable)
				cache[cacheID] = text
				-- SetText
				fontString:SetText(text)
			end
		end
	end
	----------------------------
	-- Item Level and Item ID --
	----------------------------
	-- Check for ItemLevel addon, do nothing if found
	if not ItemLevel_AddInfo and (profileDB.showItemLevel or profileDB.showItemID) and link then
		if cache[link] then
			tooltip:AddLine(cache[link])
		else
			-- Get the Item ID from the link string
			local _, link, _, level = GetItemInfo(link)
			if link then
				local _, _, id = strfind(link, "item:(%d+)")
				local newLine = ""
				if level and profileDB.showItemLevel then
					newLine = newLine..L["ItemLevel: "]..level
				end
				if id and profileDB.showItemID then
					if newLine ~= "" then
						newLine = newLine..", "
					end
					newLine = newLine..L["ItemID: "]..id
				end
				if newLine ~= "" then
					cache[link] = newLine
					tooltip:AddLine(newLine)
				end
			end
		end
	end
	------------------
	-- Stat Summary --
	------------------
	--[[
	----------------
	-- Base Stats --
	----------------
	-- Health - HEALTH, STA
	-- Mana - MANA, INT
	-- Attack Power - AP, STR, AGI
	-- Ranged Attack Power - RANGED_AP, INT, AP, STR, AGI
	-- Feral Attack Power - FERAL_AP, AP, STR, AGI
	-- Spell Damage - SPELL_DMG, STA, INT, SPI
	-- Holy Damage - HOLY_SPELL_DMG, SPELL_DMG, INT, SPI
	-- Arcane Damage - ARCANE_SPELL_DMG, SPELL_DMG, INT
	-- Fire Damage - FIRE_SPELL_DMG, SPELL_DMG, STA, INT
	-- Nature Damage - NATURE_SPELL_DMG, SPELL_DMG, INT
	-- Frost Damage - FROST_SPELL_DMG, SPELL_DMG, INT
	-- Shadow Damage - SHADOW_SPELL_DMG, SPELL_DMG, STA, INT, SPI
	-- Healing - HEAL, STR, INT, SPI
	-- Hit Chance - MELEE_HIT_RATING, WEAPON_RATING
	-- Crit Chance - MELEE_CRIT_RATING, WEAPON_RATING, AGI
	-- Spell Hit Chance - SPELL_HIT_RATING
	-- Spell Crit Chance - SPELL_CRIT_RATING, INT
	-- Mana Regen - MANA_REG, SPI
	-- Health Regen - HEALTH_REG
	-- Mana Regen Not Casting - SPI
	-- Health Regen While Casting - SPI
	-- Armor - ARMOR, ARMOR_BONUS, AGI, INT
	-- Block Value - BLOCK_VALUE, STR
	-- Dodge Chance - DODGE_RATING, DEFENSE_RATING, AGI
	-- Parry Chance - PARRY_RATING, DEFENSE_RATING
	-- Block Chance - BLOCK_RATING, DEFENSE_RATING
	-- Hit Avoidance - DEFENSE_RATING, MELEE_HIT_AVOID_RATING
	-- Crit Avoidance - DEFENSE_RATING, RESILIENCE_RATING, MELEE_CRIT_AVOID_RATING
	-- Dodge Neglect - EXPERTISE_RATING, WEAPON_RATING
	-- Parry Neglect - EXPERTISE_RATING, WEAPON_RATING
	-- Block Neglect - WEAPON_RATING
	---------------------
	-- Composite Stats --
	---------------------
	-- Strength - STR
	-- Agility - AGI
	-- Stamina - STA
	-- Intellect - INT
	-- Spirit - SPI
	-- Defense - DEFENSE_RATING
	-- Weapon Skill - WEAPON_RATING
	-- Expertise - EXPERTISE_RATING
	--]]
	if profileDB.showSum then
		RatingBuster:StatSummary(tooltip, name, link)
	end
	---------------------
	-- Repaint tooltip --
	---------------------
	tooltip:Show()
end

---------------------------------------------------------------------------------
-- Recursive algorithm that divides a string into pieces using the separators in separatorTable,
-- processes them separately, then joins them back together
---------------------------------------------------------------------------------
-- text = "+24 Agility/+4 Stamina and +4 Spell Crit/+5 Spirit"
-- separatorTable = {"/", " and ", ","}
-- RatingBuster:SplitDoJoin("+24 Agility/+4 Stamina, +4 Dodge and +4 Spell Crit/+5 Spirit", {"/", " and ", ",", "%. ", " for ", "&"})
-- RatingBuster:SplitDoJoin("+6法術傷害及5耐力", {"/", "和", ",", "。", " 持續 ", "&", "及",})
function RatingBuster:SplitDoJoin(text, separatorTable)
	if type(separatorTable) == "table" and table.maxn(separatorTable) > 0 then
		local sep = tremove(separatorTable, 1)
		text =  gsub(text, sep, "@")
		text = {strsplit("@", text)}
		local processedText = {}
		local tempTable = {}
		for _, t in ipairs(text) do
			--self:Print(t[1])
			copyTable(tempTable, separatorTable)
			tinsert(processedText, self:SplitDoJoin(t, tempTable))
		end
		-- Join text
		return (gsub(strjoin("@", unpack(processedText)), "@", sep))
	else
		--self:Print(cacheID)
		return self:ProcessText(text)
	end
end


function RatingBuster:ProcessText(text)
	--self:Print(text)
	-- Check if test has a matching pattern
	for _, num in ipairs(L["numberPatterns"]) do
		-- Convert text to lower so we don't have to worry about same ratings with different cases
		local lowerText = string.lower(text)
		-- Capture the stat value
		local s, e, value, partialtext = strfind(lowerText, num.pattern)
		if value then
			-- Check and switch captures if needed
			if partialtext and tonumber(partialtext) then
				value, partialtext = partialtext, value
			end
			-- Capture the stat name
			for _, stat in ipairs(L["statList"]) do
				if (not partialtext and strfind(lowerText, stat.pattern)) or (partialtext and strfind(partialtext, stat.pattern)) then
					value = tonumber(value)
					local infoString = ""
					if type(stat.id) == "number" and stat.id >= 1 and stat.id <= 24 and profileDB.showRatings then
						--------------------
						-- Combat Ratings --
						--------------------
						-- Calculate stat value
						local effect, strID = StatLogic:GetEffectFromRating(value, stat.id, calcLevel)
						--self:Debug(reversedAmount..", "..amount..", "..v[2]..", "..RatingBuster.targetLevel)-- debug
						-- If rating is resilience, add a minus sign
						if strID == "DEFENSE" and profileDB.defBreakDown then
							effect = effect * 0.04
							local numStats = 5
							if GetParryChance() == 0 then
								numStats = numStats - 1
							end
							if GetBlockChance() == 0 then
								numStats = numStats - 1
							end
							infoString = format("%+.2f%% x"..numStats, effect)
						elseif strID == "WEAPON_SKILL" and profileDB.wpnBreakDown then
							effect = effect * 0.04
							infoString = format("%+.2f%% x5", effect)
						elseif strID == "EXPERTISE" and profileDB.expBreakDown then
							effect = floor(effect) * -0.25
							if profileDB.detailedConversionText then
								infoString = gsub(L["$value to be Dodged/Parried"], "$value", format("%+.2f%%%%", effect))
							else
								infoString = format("%+.2f%%", effect)
							end
						elseif stat.id >= 15 and stat.id <= 17 then -- Resilience
							effect = effect * -1
							if profileDB.detailedConversionText then
								infoString = gsub(L["$value to be Crit"], "$value", format("%+.2f%%%%", effect))..", "..gsub(L["$value Crit Dmg Taken"], "$value", format("%+.2f%%%%", effect * 2))..", "..gsub(L["$value DOT Dmg Taken"], "$value", format("%+.2f%%%%", effect))
							else
								infoString = format("%+.2f%%", effect)
							end
						else
							--self:Debug(text..", "..tostring(effect)..", "..value..", "..stat.id..", "..calcLevel)
							-- Build info string
							infoString = format("%+.2f", effect)
							if stat.id > 2 and stat.id < 21 then -- if rating is a percentage
								infoString = infoString.."%"
							end
						end
					elseif stat.id == SPELL_STAT1_NAME and profileDB.showStats then
						--------------
						-- Strength --
						--------------
						local statmod = 1
						if profileDB.enableStatMods then
							statmod = StatLogic:GetStatMod("MOD_STR")
							value = value * statmod
						end
						local infoTable = {}
						if classDB.showAPFromStr then
							local mod = StatLogic:GetStatMod("MOD_AP")
							local effect = value * StatLogic:GetAPPerStr(class) * mod
							if (mod ~= 1 or statmod ~= 1) and floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value AP"], "$value", format("%+.1f", effect))))
							elseif floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value AP"], "$value", format("%+.0f", effect))))
							end
						end
						if classDB.showBlockValueFromStr then
							local effect = value * StatLogic:GetBlockValuePerStr(class)
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Block"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showHealingFromStr then
							local mod = StatLogic:GetStatMod("MOD_HEALING")
							local effect = value * StatLogic:GetStatMod("ADD_HEALING_MOD_STR") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Heal"], "$value", format("%+.1f", effect))))
							end
						end
						infoString = strjoin(", ", unpack(infoTable))
					elseif stat.id == SPELL_STAT2_NAME and profileDB.showStats then
						-------------
						-- Agility --
						-------------
						local statmod = 1
						if profileDB.enableStatMods then
							statmod = StatLogic:GetStatMod("MOD_AGI")
							value = value * statmod
						end
						local infoTable = {}
						if classDB.showAPFromAgi then
							local mod = StatLogic:GetStatMod("MOD_AP")
							local effect = value * StatLogic:GetAPPerAgi(class) * mod
							if (mod ~= 1 or statmod ~= 1) and floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value AP"], "$value", format("%+.1f", effect))))
							elseif floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value AP"], "$value", format("%+.0f", effect))))
							end
						end
						if classDB.showRAPFromAgi then
							local mod = StatLogic:GetStatMod("MOD_RANGED_AP")
							local effect = value * StatLogic:GetRAPPerAgi(class) * mod
							if (mod ~= 1 or statmod ~= 1) and floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value RAP"], "$value", format("%+.1f", effect))))
							elseif floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value RAP"], "$value", format("%+.0f", effect))))
							end
						end
						if classDB.showCritFromAgi then
							local effect = StatLogic:GetCritFromAgi(value, class, calcLevel)
							if effect > 0 then
								tinsert(infoTable, (gsub(L["$value% Crit"], "$value", format("%+.2f", effect))))
							end
						end
						if classDB.showDodgeFromAgi and (calcLevel == playerLevel) then
							local effect = StatLogic:GetDodgeFromAgi(value)
							if effect > 0 then
								tinsert(infoTable, (gsub(L["$value% Dodge"], "$value", format("%+.2f", effect))))
							end
						end
						if classDB.showArmorFromAgi then
							local effect = value * 2
							if effect > 0 then
								tinsert(infoTable, (gsub(L["$value Armor"], "$value", format("%+.0f", effect))))
							end
						end
						infoString = strjoin(", ", unpack(infoTable))
					elseif stat.id == SPELL_STAT3_NAME and profileDB.showStats then
						-------------
						-- Stamina --
						-------------
						local statmod = 1
						if profileDB.enableStatMods then
							statmod = StatLogic:GetStatMod("MOD_STA")
							value = value * statmod
						end
						local infoTable = {}
						if classDB.showHealthFromSta then
							local mod = StatLogic:GetStatMod("MOD_HEALTH")
							local effect = value * 10 * mod -- 10 Health per Sta
							if (mod ~= 1 or statmod ~= 1) and floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value HP"], "$value", format("%+.1f", effect))))
							elseif floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value HP"], "$value", format("%+.0f", effect))))
							end
						end
						if classDB.showSpellDmgFromSta then
							local mod = StatLogic:GetStatMod("MOD_SPELL_DMG")
							local effect = value * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Dmg"], "$value", format("%+.1f", effect))))
							end
						end
						infoString = strjoin(", ", unpack(infoTable))
					elseif stat.id == SPELL_STAT4_NAME and profileDB.showStats then
						---------------
						-- Intellect --
						---------------
						local statmod = 1
						if profileDB.enableStatMods then
							statmod = StatLogic:GetStatMod("MOD_INT")
							value = value * statmod
						end
						local infoTable = {}
						if classDB.showManaFromInt then
							local mod = StatLogic:GetStatMod("MOD_MANA")
							local effect = value * 15 * mod -- 15 Mana per Int
							if (mod ~= 1 or statmod ~= 1) and floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value MP"], "$value", format("%+.1f", effect))))
							elseif floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value MP"], "$value", format("%+.0f", effect))))
							end
						end
						if classDB.showSpellCritFromInt then
							local effect = StatLogic:GetSpellCritFromInt(value, class, calcLevel)
							if effect > 0 then
								tinsert(infoTable, (gsub(L["$value% Spell Crit"], "$value", format("%+.2f", effect))))
							end
						end
						if classDB.showSpellDmgFromInt then
							local mod = StatLogic:GetStatMod("MOD_SPELL_DMG")
							local effect = value * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Dmg"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showHealingFromInt then
							local mod = StatLogic:GetStatMod("MOD_HEALING")
							local effect = value * StatLogic:GetStatMod("ADD_HEALING_MOD_INT") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Heal"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showMP5FromInt then
							local effect = value * StatLogic:GetStatMod("ADD_MANA_REG_MOD_INT")
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value MP5"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showRAPFromInt then
							local mod = StatLogic:GetStatMod("MOD_RANGED_AP")
							local effect = value * StatLogic:GetStatMod("ADD_RANGED_AP_MOD_INT") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value RAP"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showArmorFromInt then
							local effect = value * StatLogic:GetStatMod("ADD_ARMOR_MOD_INT")
							if floor(effect + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Armor"], "$value", format("%+.0f", effect))))
							end
						end
						infoString = strjoin(", ", unpack(infoTable))
					elseif stat.id == SPELL_STAT5_NAME and profileDB.showStats then
						------------
						-- Spirit --
						------------
						local statmod = 1
						if profileDB.enableStatMods then
							statmod = StatLogic:GetStatMod("MOD_SPI")
							value = value * statmod
						end
						local infoTable = {}
						if classDB.showMP5FromSpi then
							local mod = StatLogic:GetStatMod("ADD_MANA_REG_MOD_NORMAL_MANA_REG")
							local effect = StatLogic:GetNormalManaRegenFromSpi(value, class) * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value MP5"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showMP5NCFromSpi then
							local effect = StatLogic:GetNormalManaRegenFromSpi(value, class)
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value MP5(NC)"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showHP5FromSpi then
							local effect = StatLogic:GetHealthRegenFromSpi(value, class)
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value HP5"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showSpellDmgFromSpi then
							local mod = StatLogic:GetStatMod("MOD_SPELL_DMG")
							local effect = value * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Dmg"], "$value", format("%+.1f", effect))))
							end
						end
						if classDB.showHealingFromSpi then
							local mod = StatLogic:GetStatMod("MOD_HEALING")
							local effect = value * StatLogic:GetStatMod("ADD_HEALING_MOD_SPI") * mod
							if floor(effect * 10 + 0.5) > 0 then
								tinsert(infoTable, (gsub(L["$value Heal"], "$value", format("%+.1f", effect))))
							end
						end
						infoString = strjoin(", ", unpack(infoTable))
					end
					if infoString ~= "" then
						-- Add parenthesis
						infoString = "("..infoString..")"
						-- Add Color
						if profileDB.enableTextColor then
							infoString = profileDB.textColor.hex..infoString.."|r"
						end
						-- Build replacement string
						if num.addInfo == "AfterNumber" then -- Add after number
							infoString = gsub(infoString, "%%", "%%%%%%%%") -- sub "%" with "%%%%"
							infoString = gsub(strsub(text, s, e), "%d+", "%0 "..infoString, 1) -- sub "33" with "33 (3.33%)"
						else -- Add after stat
							infoString = gsub(infoString, "%%", "%%%%")
							s, e = strfind(lowerText, stat.pattern)
							infoString = "%0 "..infoString
						end
						-- Insert info into text
						return (gsub(text, strsub(text, s, e), infoString, 1)) -- because gsub has 2 return values, but we only want 1
					end
					return text
				end
			end
		end
	end
	return text
end


-- Color Numbers
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE -- "|cff20ff20" Green
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE -- "|cffffffff" White
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE -- "|cffffffff" White
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE -- "|r"
local function colorNum(text, num)
	if num > 0 then
		return GREEN_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	elseif num < 0 then
		return RED_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	else
		return HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	end
end

-- Used armor type each class uses
local classArmorTypes = {
	WARRIOR = {
		[BI["Plate"]] = true,
	},
	PALADIN = {
		[BI["Plate"]] = true,
		[BI["Mail"]] = true,
		[BI["Leather"]] = true,
		[BI["Cloth"]] = true,
	},
	HUNTER = {
		[BI["Mail"]] = true,
		[BI["Leather"]] = true,
	},
	ROGUE = {
		[BI["Leather"]] = true,
	},
	PRIEST = {
		[BI["Cloth"]] = true,
	},
	SHAMAN = {
		[BI["Mail"]] = true,
		[BI["Leather"]] = true,
		[BI["Cloth"]] = true,
	},
	MAGE = {
		[BI["Cloth"]] = true,
	},
	WARLOCK = {
		[BI["Cloth"]] = true,
	},
	DRUID = {
		[BI["Leather"]] = true,
		[BI["Cloth"]] = true,
	},
}

local armorTypes = {
	[BI["Plate"]] = true,
	[BI["Mail"]] = true,
	[BI["Leather"]] = true,
	[BI["Cloth"]] = true,
}


local summaryCalcData = {
	-- Health - HEALTH, STA
	{
		option = "sumHP",
		name = "HEALTH",
		func = function(sum) return ((sum["HEALTH"] or 0) + (sum["STA"] * 10)) * StatLogic:GetStatMod("MOD_HEALTH") end,
	},
	-- Mana - MANA, INT
	{
		option = "sumMP",
		name = "MANA",
		func = function(sum) return ((sum["MANA"] or 0) + (sum["INT"] * 15)) * StatLogic:GetStatMod("MOD_MANA") end,
	},
	-- Attack Power - AP, STR, AGI
	{
		option = "sumAP",
		name = "AP",
		func = function(sum) return ((sum["AP"] or 0) + (sum["STR"] * StatLogic:GetAPPerStr(class))
			 + (sum["AGI"] * StatLogic:GetAPPerAgi(class))) * StatLogic:GetStatMod("MOD_AP") end,
	},
	-- Ranged Attack Power - RANGED_AP, AP, AGI, INT
	{
		option = "sumRAP",
		name = "RANGED_AP",
		func = function(sum) return ((sum["RANGED_AP"] or 0) + (sum["AP"] or 0) + (sum["AGI"] * StatLogic:GetRAPPerAgi(class))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_RANGED_AP_MOD_INT"))) * (StatLogic:GetStatMod("MOD_RANGED_AP") + StatLogic:GetStatMod("MOD_AP") - 1) end,
	},
	-- Feral Attack Power - FERAL_AP, AP, STR, AGI
	{
		option = "sumFAP",
		name = "FERAL_AP",
		func = function(sum) return ((sum["FERAL_AP"] or 0) + (sum["AP"] or 0) + (sum["STR"] * StatLogic:GetAPPerStr(class))
			 + (sum["AGI"] * StatLogic:GetAPPerAgi(class))) * StatLogic:GetStatMod("MOD_AP") end,
	},
	-- Spell Damage - SPELL_DMG, STA, INT, SPI
	{
		option = "sumSpellDmg",
		name = "SPELL_DMG",
		func = function(sum)
			local ap = ((sum["AP"] or 0) + (sum["STR"] * StatLogic:GetAPPerStr(class))
			 + (sum["AGI"] * StatLogic:GetAPPerAgi(class))) * StatLogic:GetStatMod("MOD_AP")
			return ((sum["SPELL_DMG"] or 0) + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))
			 + (ap * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_AP"))) * StatLogic:GetStatMod("MOD_SPELL_DMG")
		end,
	},
	-- Holy Damage - HOLY_SPELL_DMG, SPELL_DMG, INT, SPI
	{
		option = "sumHolyDmg",
		name = "HOLY_SPELL_DMG",
		func = function(sum) return ((sum["HOLY_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Arcane Damage - ARCANE_SPELL_DMG, SPELL_DMG, INT
	{
		option = "sumArcaneDmg",
		name = "ARCANE_SPELL_DMG",
		func = function(sum) return ((sum["ARCANE_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Fire Damage - FIRE_SPELL_DMG, SPELL_DMG, STA, INT
	{
		option = "sumFireDmg",
		name = "FIRE_SPELL_DMG",
		func = function(sum) return ((sum["FIRE_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Nature Damage - NATURE_SPELL_DMG, SPELL_DMG, INT
	{
		option = "sumNatureDmg",
		name = "NATURE_SPELL_DMG",
		func = function(sum) return ((sum["NATURE_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Frost Damage - FROST_SPELL_DMG, SPELL_DMG, INT
	{
		option = "sumFrostDmg",
		name = "FROST_SPELL_DMG",
		func = function(sum) return ((sum["FROST_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Shadow Damage - SHADOW_SPELL_DMG, SPELL_DMG, STA, INT, SPI
	{
		option = "sumShadowDmg",
		name = "SHADOW_SPELL_DMG",
		func = function(sum) return ((sum["SHADOW_SPELL_DMG"] or 0) + (sum["SPELL_DMG"] or 0)
			 + (sum["STA"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_STA"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_SPELL_DMG_MOD_SPI"))) * StatLogic:GetStatMod("MOD_SPELL_DMG") end,
	},
	-- Healing - HEAL, STR, INT, SPI
	{
		option = "sumHealing",
		name = "HEAL",
		func = function(sum)
			local ap = ((sum["AP"] or 0) + (sum["STR"] * StatLogic:GetAPPerStr(class))
			 + (sum["AGI"] * StatLogic:GetAPPerAgi(class))) * StatLogic:GetStatMod("MOD_AP")
			return ((sum["HEAL"] or 0)
			 + (sum["STR"] * StatLogic:GetStatMod("ADD_HEALING_MOD_STR"))
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_HEALING_MOD_INT"))
			 + (sum["SPI"] * StatLogic:GetStatMod("ADD_HEALING_MOD_SPI"))
			 + (ap * StatLogic:GetStatMod("ADD_HEALING_MOD_AP"))) * StatLogic:GetStatMod("MOD_SPELL_DMG")
		end,
	},
	-- Crit Chance - MELEE_CRIT_RATING, WEAPON_RATING, AGI
	{
		option = "sumCrit",
		name = "MELEE_CRIT",
		func = function(sum)
			local s = 0
			for id, v in pairs(sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					s = s + StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel) * 0.04
					break
				end
			end
			return s + StatLogic:GetEffectFromRating((sum["MELEE_CRIT_RATING"] or 0), "MELEE_CRIT_RATING", calcLevel)
					 + StatLogic:GetCritFromAgi(sum["AGI"], class, calcLevel)
		end,
		ispercent = true,
	},
	-- Hit Chance - MELEE_HIT_RATING, WEAPON_RATING
	{
		option = "sumHit",
		name = "MELEE_HIT",
		func = function(sum)
			local s = 0
			for id, v in pairs(sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					s = s + StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel) * 0.04
					break
				end
			end
			return s + StatLogic:GetEffectFromRating((sum["MELEE_HIT_RATING"] or 0), "MELEE_HIT_RATING", calcLevel)
		end,
		ispercent = true,
	},
	-- Spell Crit Chance - SPELL_CRIT_RATING, INT
	{
		option = "sumSpellCrit",
		name = "SPELL_CRIT",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["SPELL_CRIT_RATING"] or 0), "SPELL_CRIT_RATING", calcLevel)
			 + StatLogic:GetSpellCritFromInt(sum["INT"], class, calcLevel) end,
		ispercent = true,
	},
	-- Spell Hit Chance - SPELL_HIT_RATING
	{
		option = "sumSpellHit",
		name = "SPELL_HIT",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["SPELL_HIT_RATING"] or 0), "SPELL_HIT_RATING", calcLevel) end,
		ispercent = true,
	},
	-- Mana Regen - MANA_REG, SPI, INT
	{
		option = "sumMP5",
		name = "MANA_REG",
		func = function(sum) return (sum["MANA_REG"] or 0)
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_MANA_REG_MOD_INT"))
			 + (StatLogic:GetNormalManaRegenFromSpi(sum["SPI"], class) * StatLogic:GetStatMod("ADD_MANA_REG_MOD_NORMAL_MANA_REG")) end,
	},
	-- Health Regen - HEALTH_REG
	{
		option = "sumHP5",
		name = "HEALTH_REG",
		func = function(sum) return (sum["HEALTH_REG"] or 0) end,
	},
	-- Mana Regen while Not casting - MANA_REG, SPI, INT
	{
		option = "sumMP5NC",
		name = "MANA_REG_NOT_CASTING",
		func = function(sum) return (sum["MANA_REG"] or 0)
			 + (sum["INT"] * StatLogic:GetStatMod("ADD_MANA_REG_MOD_INT"))
			 + StatLogic:GetNormalManaRegenFromSpi(sum["SPI"], class) end,
	},
	-- Health Regen while Out of Combat - HEALTH_REG, SPI
	{
		option = "sumHP5OC",
		name = "HEALTH_REG_OUT_OF_COMBAT",
		func = function(sum) return (sum["HEALTH_REG"] or 0) + StatLogic:GetHealthRegenFromSpi(sum["SPI"], class) end,
	},
	-- Armor - ARMOR, ARMOR_BONUS, AGI, INT
	{
		option = "sumArmor",
		name = "ARMOR",
		func = function(sum) return (sum["ARMOR"] or 0) * StatLogic:GetStatMod("MOD_ARMOR")
			 + (sum["ARMOR_BONUS"] or 0) + ((sum["AGI"] or 0) * 2)
			 + ((sum["INT"] or 0) * StatLogic:GetStatMod("ADD_ARMOR_MOD_INT")) end,
	},
	-- Block Value - BLOCK_VALUE, STR
	{
		option = "sumBlockValue",
		name = "BLOCK_VALUE",
		func = function(sum)
			if GetBlockChance() == 0 then return 0 end
			return (sum["BLOCK_VALUE"] or 0) * StatLogic:GetStatMod("MOD_BLOCK_VALUE")
				 + ((sum["STR"] or 0) * StatLogic:GetBlockValuePerStr(class))
		end,
	},
	-- Dodge Chance - DODGE_RATING, DEFENSE_RATING, AGI
	{
		option = "sumDodge",
		name = "DODGE",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["DODGE_RATING"] or 0), "DODGE_RATING", calcLevel)
			 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
			 + StatLogic:GetDodgeFromAgi(sum["AGI"]) end,
		ispercent = true,
	},
	-- Parry Chance - PARRY_RATING, DEFENSE_RATING
	{
		option = "sumParry",
		name = "PARRY",
		func = function(sum)
			if GetParryChance() == 0 then return 0 end
			return StatLogic:GetEffectFromRating((sum["PARRY_RATING"] or 0), "PARRY_RATING", calcLevel)
				 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
		end,
		ispercent = true,
	},
	-- Block Chance - BLOCK_RATING, DEFENSE_RATING
	{
		option = "sumBlock",
		name = "BLOCK",
		func = function(sum)
			if GetBlockChance() == 0 then return 0 end
			return StatLogic:GetEffectFromRating((sum["BLOCK_RATING"] or 0), "BLOCK_RATING", calcLevel)
				 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
		end,
		ispercent = true,
	},
	-- Hit Avoidance - DEFENSE_RATING, MELEE_HIT_AVOID_RATING
	{
		option = "sumHitAvoid",
		name = "MELEE_HIT_AVOID",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["MELEE_HIT_AVOID_RATING"] or 0), "MELEE_HIT_AVOID_RATING", calcLevel)
			 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04 end,
		ispercent = true,
	},
	-- Crit Avoidance - DEFENSE_RATING, RESILIENCE_RATING, MELEE_CRIT_AVOID_RATING
	{
		option = "sumCritAvoid",
		name = "MELEE_CRIT_AVOID",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["MELEE_CRIT_AVOID_RATING"] or 0), "MELEE_CRIT_AVOID_RATING", calcLevel)
			 + StatLogic:GetEffectFromRating((sum["RESILIENCE_RATING"] or 0), "RESILIENCE_RATING", calcLevel)
			 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04 end,
		ispercent = true,
	},
	-- Dodge Neglect - EXPERTISE_RATING, WEAPON_RATING -- 2.3.0
	{
		option = "sumDodgeNeglect",
		name = "DODGE_NEGLECT",
		func = function(sum)
			local s = 0
			for id, v in pairs(sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					s = StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel) * 0.04
				end
			end
			s = s + floor(StatLogic:GetEffectFromRating((sum["EXPERTISE_RATING"] or 0), "EXPERTISE_RATING", calcLevel)) * 0.25
			return s
		end,
		ispercent = true,
	},
	-- Parry Neglect - EXPERTISE_RATING, WEAPON_RATING -- 2.3.0
	{
		option = "sumParryNeglect",
		name = "PARRY_NEGLECT",
		func = function(sum)
			local s = 0
			for id, v in pairs(sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					s = StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel) * 0.04
				end
			end
			s = s + floor(StatLogic:GetEffectFromRating((sum["EXPERTISE_RATING"] or 0), "EXPERTISE_RATING", calcLevel)) * 0.25
			return s
		end,
		ispercent = true,
	},
	-- Block Neglect - WEAPON_RATING
	{
		option = "sumBlockNeglect",
		name = "BLOCK_NEGLECT",
		func = function(sum)
			for id, v in pairs(sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					return StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel) * 0.04
				end
			end
			return 0
		end,
		ispercent = true,
	},
	-- Arcane Resistance - ARCANE_RES
	{
		option = "sumArcaneResist",
		name = "ARCANE_RES",
		func = function(sum) return (sum["ARCANE_RES"] or 0) end,
	},
	-- Fire Resistance - FIRE_RES
	{
		option = "sumFireResist",
		name = "FIRE_RES",
		func = function(sum) return (sum["FIRE_RES"] or 0) end,
	},
	-- Nature Resistance - NATURE_RES
	{
		option = "sumNatureResist",
		name = "NATURE_RES",
		func = function(sum) return (sum["NATURE_RES"] or 0) end,
	},
	-- Frost Resistance - FROST_RES
	{
		option = "sumFrostResist",
		name = "FROST_RES",
		func = function(sum) return (sum["FROST_RES"] or 0) end,
	},
	-- Shadow Resistance - SHADOW_RES
	{
		option = "sumShadowResist",
		name = "SHADOW_RES",
		func = function(sum) return (sum["SHADOW_RES"] or 0) end,
	},
	-- Weapon Max Damage - MAX_DAMAGE
	{
		option = "sumWeaponMaxDamage",
		name = "MAX_DAMAGE",
		func = function(sum) return (sum["MAX_DAMAGE"] or 0) end,
	},
	-- statcomposite
	-- Strength - STR
	{
		option = "sumStr",
		name = "STR",
		func = function(sum) return sum["STR"] end,
	},
	-- Agility - AGI
	{
		option = "sumAgi",
		name = "AGI",
		func = function(sum) return sum["AGI"] end,
	},
	-- Stamina - STA
	{
		option = "sumSta",
		name = "STA",
		func = function(sum) return sum["STA"] end,
	},
	-- Intellect - INT
	{
		option = "sumInt",
		name = "INT",
		func = function(sum) return sum["INT"] end,
	},
	-- Spirit - SPI
	{
		option = "sumSpi",
		name = "SPI",
		func = function(sum) return sum["SPI"] end,
	},
	-- Defense - DEFENSE_RATING
	{
		option = "sumDefense",
		name = "DEFENSE",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) end,
	},
	-- Expertise - EXPERTISE_RATING
	{
		option = "sumExpertise",
		name = "EXPERTISE",
		func = function(sum) return StatLogic:GetEffectFromRating((sum["EXPERTISE_RATING"] or 0), "EXPERTISE_RATING", calcLevel) end,
	},
	-- Avoidance - PARRY, DODGE, MOBMISS
	{
		option = "sumAvoidance",
		name = "AVOIDANCE",
		ispercent = true,
		func = function(sum)
			local dodge, parry, mobMiss
			if GetParryChance() == 0 then
				parry = 0
			else
				parry = StatLogic:GetEffectFromRating((sum["PARRY_RATING"] or 0), "PARRY_RATING", calcLevel)
				 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
			end
			dodge = StatLogic:GetEffectFromRating((sum["DODGE_RATING"] or 0), "DODGE_RATING", calcLevel)
			 + StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
			 + StatLogic:GetDodgeFromAgi(sum["AGI"])
			mobMiss = StatLogic:GetEffectFromRating((sum["DEFENSE_RATING"] or 0), "DEFENSE_RATING", calcLevel) * 0.04
			return parry + dodge + mobMiss
		end,
		ispercent = true,
	},
}
if tpSupport == true then
	-- TankPoints
	tinsert(summaryCalcData, {
		option = "sumTankPoints",
		name = "TANKPOINTS",
		func = function(diffTable1)
			-- Item type
			local itemType = diffTable1.itemType
			local right
			-- Calculate current TankPoints
			local tpSource = {}
			local TP = TankPoints
			local TPTips = TankPointsTooltips
			TP:GetSourceData(tpSource, TP_MELEE)
			local tpResults = {}
			copyTable(tpResults, tpSource)
			TP:GetTankPoints(tpResults, TP_MELEE)
			-- Update if different
			if floor(TP.resultsTable.tankPoints[TP_MELEE]) ~= floor(tpResults.tankPoints[TP_MELEE]) then
				copyTable(TP.sourceTable, tpSource)
				copyTable(TP.resultsTable, tpResults)
			end
			----------------------------------------------------
			-- Calculate TP difference with 1st equipped item --
			----------------------------------------------------
			local tpTable = {}
			-- Set the forceShield arg
			local forceShield
			-- if not equipped shield and item is shield then force on
			-- if not equipped shield and item is not shield then nil
			-- if equipped shield and item is shield then nil
			-- if equipped shield and item is not shield then force off
			if ((diffTable1.diffItemType1 ~= "INVTYPE_SHIELD") and (diffTable1.diffItemType2 ~= "INVTYPE_SHIELD")) and (itemType == "INVTYPE_SHIELD") then
				forceShield = true
			elseif ((diffTable1.diffItemType1 == "INVTYPE_SHIELD") or (diffTable1.diffItemType2 == "INVTYPE_SHIELD")) and (itemType ~= "INVTYPE_SHIELD") then
				forceShield = false
			end
			-- Get the tp table
			TP:GetSourceData(tpTable, TP_MELEE, forceShield)
			-- Build changes table
			local changes = TPTips:BuildChanges({}, diffTable1)
			-- Alter tp table
			TP:AlterSourceData(tpTable, changes, forceShield)
			-- Calculate TankPoints from tpTable
			TP:GetTankPoints(tpTable, TP_MELEE, forceShield)
			-- Calculate tp difference
			local diff = floor(tpTable.tankPoints[TP_MELEE]) - floor(TP.resultsTable.tankPoints[TP_MELEE])
	
			return diff
		end,
	})
	-- Total Reduction
	tinsert(summaryCalcData, {
		option = "sumTotalReduction",
		name = "TOTALREDUCTION",
		ispercent = true,
		func = function(diffTable1)
			-- Item type
			local itemType = diffTable1.itemType
			local right
			-- Calculate current TankPoints
			local tpSource = {}
			local TP = TankPoints
			local TPTips = TankPointsTooltips
			TP:GetSourceData(tpSource, TP_MELEE)
			local tpResults = {}
			copyTable(tpResults, tpSource)
			TP:GetTankPoints(tpResults, TP_MELEE)
			-- Update if different
			if floor(TP.resultsTable.tankPoints[TP_MELEE]) ~= floor(tpResults.tankPoints[TP_MELEE]) then
				copyTable(TP.sourceTable, tpSource)
				copyTable(TP.resultsTable, tpResults)
			end
			----------------------------------------------------
			-- Calculate TP difference with 1st equipped item --
			----------------------------------------------------
			local tpTable = {}
			-- Set the forceShield arg
			local forceShield
			-- if not equipped shield and item is shield then force on
			-- if not equipped shield and item is not shield then nil
			-- if equipped shield and item is shield then nil
			-- if equipped shield and item is not shield then force off
			if ((diffTable1.diffItemType1 ~= "INVTYPE_SHIELD") and (diffTable1.diffItemType2 ~= "INVTYPE_SHIELD")) and (itemType == "INVTYPE_SHIELD") then
				forceShield = true
			elseif ((diffTable1.diffItemType1 == "INVTYPE_SHIELD") or (diffTable1.diffItemType2 == "INVTYPE_SHIELD")) and (itemType ~= "INVTYPE_SHIELD") then
				forceShield = false
			end
			-- Get the tp table
			TP:GetSourceData(tpTable, TP_MELEE, forceShield)
			-- Build changes table
			local changes = TPTips:BuildChanges({}, diffTable1)
			-- Alter tp table
			TP:AlterSourceData(tpTable, changes, forceShield)
			-- Calculate TankPoints from tpTable
			TP:GetTankPoints(tpTable, TP_MELEE, forceShield)
			-- Calculate tp difference
			local diff = tpTable.totalReduction[TP_MELEE] - TP.resultsTable.totalReduction[TP_MELEE]
			
			return diff * 100
		end,
	})
	--[[
	-- Avoidance
	tinsert(summaryCalcData, {
		option = "sumAvoidance",
		name = "AVOIDANCE",
		ispercent = true,
		func = function(diffTable1)
			-- Item type
			local itemType = diffTable1.itemType
			local right
			-- Calculate current TankPoints
			local tpSource = {}
			local TP = TankPoints
			local TPTips = TankPointsTooltips
			TP:GetSourceData(tpSource, TP_MELEE)
			local tpResults = {}
			copyTable(tpResults, tpSource)
			TP:GetTankPoints(tpResults, TP_MELEE)
			-- Update if different
			if floor(TP.resultsTable.tankPoints[TP_MELEE]) ~= floor(tpResults.tankPoints[TP_MELEE]) then
				copyTable(TP.sourceTable, tpSource)
				copyTable(TP.resultsTable, tpResults)
			end
			----------------------------------------------------
			-- Calculate TP difference with 1st equipped item --
			----------------------------------------------------
			local tpTable = {}
			-- Set the forceShield arg
			local forceShield
			-- if not equipped shield and item is shield then force on
			-- if not equipped shield and item is not shield then nil
			-- if equipped shield and item is shield then nil
			-- if equipped shield and item is not shield then force off
			if ((diffTable1.diffItemType1 ~= "INVTYPE_SHIELD") and (diffTable1.diffItemType2 ~= "INVTYPE_SHIELD")) and (itemType == "INVTYPE_SHIELD") then
				forceShield = true
			elseif ((diffTable1.diffItemType1 == "INVTYPE_SHIELD") or (diffTable1.diffItemType2 == "INVTYPE_SHIELD")) and (itemType ~= "INVTYPE_SHIELD") then
				forceShield = false
			end
			-- Get the tp table
			TP:GetSourceData(tpTable, TP_MELEE, forceShield)
			-- Build changes table
			local changes = TPTips:BuildChanges({}, diffTable1)
			-- Alter tp table
			TP:AlterSourceData(tpTable, changes, forceShield)
			-- Calculate TankPoints from tpTable
			TP:GetTankPoints(tpTable, TP_MELEE, forceShield)
			-- Calculate tp difference
			local diff = tpTable.mobMissChance + tpTable.dodgeChance + tpTable.parryChance - TP.resultsTable.mobMissChance - TP.resultsTable.dodgeChance - TP.resultsTable.parryChance
			
			return diff * 100
		end,
	})
	--]]
end

function RatingBuster:StatSummary(tooltip, name, link)
	-- Hide stat summary for equipped items
	if profileDB.sumIgnoreEquipped and IsEquippedItem(link) then return end
	
	-- Show stat summary only for highest level armor type and items you can use with uncommon quality and up
	if profileDB.sumIgnoreUnused then
		local _, _, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(link)
		
		-- Check rarity
		if not itemRarity or itemRarity < 2 then
			return
		end

		-- Check armor type
		if armorTypes[itemSubType] and (not classArmorTypes[class][itemSubType]) and itemEquipLoc ~= "INVTYPE_CLOAK" then
			--self:Print("Check armor type", itemSubType)
			return
		end
		
		-- Check for Red item types
		local tName = tooltip:GetName()
		if _G[tName.."TextRight3"]:GetText() and select(2, _G[tName.."TextRight3"]:GetTextColor()) < 0.2 then
			--self:Print("TextRight3", select(2, _G[tName.."TextRight3"]:GetTextColor()))
			return
		end
		if _G[tName.."TextRight4"]:GetText() and select(2, _G[tName.."TextRight4"]:GetTextColor()) < 0.2 then
			--self:Print("TextRight4", select(2, _G[tName.."TextRight4"]:GetTextColor()))
			return
		end
		if select(2, _G[tName.."TextLeft3"]:GetTextColor()) < 0.2 then
			--self:Print("TextLeft3", select(2, _G[tName.."TextLeft3"]:GetTextColor()))
			return
		end
		if select(2, _G[tName.."TextLeft4"]:GetTextColor()) < 0.2 then
			--self:Print("TextLeft4", select(2, _G[tName.."TextLeft4"]:GetTextColor()))
			return
		end
	end
	
	-- Ignore enchants and gems on items when calculating the stat summary
	if profileDB.sumIgnoreEnchant then
		link = StatLogic:RemoveEnchant(link)
	end
	if profileDB.sumIgnoreGems then
		link = StatLogic:RemoveGem(link)
	end
	
	-- Diff Display Style
	-- Main Tooltip: tooltipLevel = 0
	-- Compare Tooltip 1: tooltipLevel = 1
	-- Compare Tooltip 2: tooltipLevel = 2
	local id
	local tooltipLevel = 0
	local mainTooltip = tooltip
	-- Determine tooltipLevel and id
	if profileDB.calcDiff and (profileDB.sumDiffStyle == "comp") then
		-- Obtain main tooltip
		for _, t in pairs(TipHooker.SupportedTooltips) do
			if mainTooltip:IsOwned(t) then
				mainTooltip = t
				break
			end
		end
		for _, t in pairs(TipHooker.SupportedTooltips) do
			if mainTooltip:IsOwned(t) then
				mainTooltip = t
				break
			end
		end
		-- Detemine tooltip level
		local _, mainlink, difflink1, difflink2 = StatLogic:GetDiffID(mainTooltip, profileDB.sumIgnoreEnchant, profileDB.sumIgnoreGems)
		if link == mainlink then
			tooltipLevel = 0
		elseif link == difflink1 then
			tooltipLevel = 1
		elseif link == difflink2 then
			tooltipLevel = 2
		end
		-- Construct id
		if tooltipLevel > 0 then
			id = link..mainlink
		else
			id = "sum"..link
		end
	else
		id = StatLogic:GetDiffID(link, profileDB.sumIgnoreEnchant, profileDB.sumIgnoreGems)
	end
	
	-- Check Cache
	if cache[id] then
		if table.maxn(cache[id]) == 0 then return end
		-- Write Tooltip
		if profileDB.sumBlankLine then
			tooltip:AddLine(" ")
		end
		if profileDB.sumShowTitle then
			tooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..L["Stat Summary"]..FONT_COLOR_CODE_CLOSE)
			if profileDB.sumShowIcon then
				tooltip:AddTexture("Interface\\AddOns\\RatingBuster\\images\\Sigma")
			end
		end
		for _, o in ipairs(cache[id]) do
			tooltip:AddDoubleLine(o[1], o[2])
		end
		if profileDB.sumBlankLineAfter then
			tooltip:AddLine(" ")
		end
		return
	end
	
	-------------------------
	-- Build Summary Table --
	local statData = {}
	statData.sum = StatLogic:GetSum(link)
	if not statData.sum then return end
	if not profileDB.calcSum then
		statData.sum = nil
	end
	
	-- Ignore bags
	if not StatLogic:GetDiff(link) then return end
	
	-- Get Diff Data
	if profileDB.calcDiff then
		if profileDB.sumDiffStyle == "comp" then
			if tooltipLevel > 0 then
				statData.diff1 = select(tooltipLevel, StatLogic:GetDiff(mainTooltip, nil, nil, profileDB.sumIgnoreEnchant, profileDB.sumIgnoreGems))
			end
		else
			statData.diff1, statData.diff2 = StatLogic:GetDiff(link, nil, nil, profileDB.sumIgnoreEnchant, profileDB.sumIgnoreGems)
		end
	end
	-- Apply Base Stat Mods
	for _, v in pairs(statData) do
		v["STR"] = (v["STR"] or 0)
		v["AGI"] = (v["AGI"] or 0)
		v["STA"] = (v["STA"] or 0)
		v["INT"] = (v["INT"] or 0)
		v["SPI"] = (v["SPI"] or 0)
	end
	if profileDB.enableStatMods then
		for _, v in pairs(statData) do
			v["STR"] = v["STR"] * StatLogic:GetStatMod("MOD_STR")
			v["AGI"] = v["AGI"] * StatLogic:GetStatMod("MOD_AGI")
			v["STA"] = v["STA"] * StatLogic:GetStatMod("MOD_STA")
			v["INT"] = v["INT"] * StatLogic:GetStatMod("MOD_INT")
			v["SPI"] = v["SPI"] * StatLogic:GetStatMod("MOD_SPI")
		end
	end
	-- Summary Table
	--[[
	local statData = {
		sum = {},
		diff1 = {},
		diff2 = {},
	}
	if classDB.sumHP then
		local d = {name = "HEALTH"}
		for k, sum in pairs(data) do
			d[k] = ((sum["HEALTH"] or 0) + (sum["STA"] * 10)) * StatLogic:GetStatMod("MOD_HEALTH")
		end
		tinsert(summary, d)
	end
	local summaryCalcData = {
		-- Health - HEALTH, STA
		sumHP = {
			name = "HEALTH",
			func = function(sum) return ((sum["HEALTH"] or 0) + (sum["STA"] * 10)) * StatLogic:GetStatMod("MOD_HEALTH") end,
			ispercent = false,
		},
	}
	--]]
	local summary = {}
	for _, calcData in pairs(summaryCalcData) do
		if classDB[calcData.option] then
			local entry = {
				name = calcData.name,
				ispercent = calcData.ispercent,
			}
			for statDataType, statTable in pairs(statData) do
				if tpSupport and ((calcData.name == "TANKPOINTS") or (calcData.name == "TOTALREDUCTION")) and (statDataType == "sum") then
					entry[statDataType] = nil
				else
					entry[statDataType] = calcData.func(statTable)
				end
			end
			tinsert(summary, entry)
		end
	end
	
	local calcSum = profileDB.calcSum
	local calcDiff = profileDB.calcDiff
	-- Weapon Skill - WEAPON_RATING
	if classDB.sumWeaponSkill then
		local weapon = {}
		if calcSum then
			for id, v in pairs(statData.sum) do
				if strsub(id, -13) == "WEAPON_RATING" then
					weapon[id] = true
					local entry = {
						name = strsub(id, 1, -8),
					}
					entry.sum = StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel)
					if calcDiff and statData.diff1 then
						entry.diff1 = StatLogic:GetEffectFromRating((statData.diff1[id] or 0), CR_WEAPON_SKILL, calcLevel)
						if statData.diff2 then
							entry.diff2 = StatLogic:GetEffectFromRating((statData.diff2[id] or 0), CR_WEAPON_SKILL, calcLevel)
						end
					end
					tinsert(summary, entry)
				end
			end
		end
		if calcDiff and statData.diff1 then
			for id, v in pairs(statData.diff1) do
				if (strsub(id, -13) == "WEAPON_RATING") and not weapon[id] then
					weapon[id] = true
					local entry = {
						name = strsub(id, 1, -8),
						sum = 0,
					}
					entry.diff1 = StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel)
					if statData.diff2 then
						entry.diff2 = StatLogic:GetEffectFromRating((statData.diff2[id] or 0), CR_WEAPON_SKILL, calcLevel)
					end
					tinsert(summary, entry)
				end
			end
			if statData.diff2 then
				for id, v in pairs(statData.diff2) do
					if (strsub(id, -13) == "WEAPON_RATING") and not weapon[id] then
						weapon[id] = true
						local entry = {
							name = strsub(id, 1, -8),
							sum = 0,
							diff1 = 0,
						}
						entry.diff2 = StatLogic:GetEffectFromRating(v, CR_WEAPON_SKILL, calcLevel)
						tinsert(summary, entry)
					end
				end
			end
		end
	end
	
	local showZeroValueStat = profileDB.showZeroValueStat
	------------------------
	-- Build Output Table --
	local output = {}
	for _, t in ipairs(summary) do
		local n, s, d1, d2, ispercent = t.name, t.sum, t.diff1, t.diff2, t.ispercent
		local right, left
		local skip
		if not showZeroValueStat then
			if (s == 0 or not s) and (d1 == 0 or not d1) and (d2 == 0 or not d2) then
				skip = true
			end
		end
		if not skip then
			if calcSum and calcDiff then
				local d = ((not s) or ((s - floor(s)) == 0)) and ((not d1) or ((d1 - floor(d1)) == 0)) and ((not d2) or ((d2 - floor(d2)) == 0))
				if s then
					if d then
						s = format("%d", s)
					elseif ispercent then
						s = format("%.2f%%", s)
					else
						s = format("%.1f", s)
					end
					if d1 then
						if d then
							d1 = colorNum(format("%+d", d1), d1)
						elseif ispercent then
							d1 = colorNum(format("%+.2f%%", d1), d1)
						else
							d1 = colorNum(format("%+.1f", d1), d1)
						end
						if d2 then
							if d then
								d2 = colorNum(format("%+d", d2), d2)
							elseif ispercent then
								d2 = colorNum(format("%+.2f%%", d2), d2)
							else
								d2 = colorNum(format("%+.1f", d2), d2)
							end
							right = format("%s (%s||%s)", s, d1, d2)
						else
							right = format("%s (%s)", s, d1)
						end
					else
						right = s
					end
				else
					if d1 then
						if d then
							d1 = colorNum(format("%+d", d1), d1)
						elseif ispercent then
							d1 = colorNum(format("%+.2f%%", d1), d1)
						else
							d1 = colorNum(format("%+.1f", d1), d1)
						end
						if d2 then
							if d then
								d2 = colorNum(format("%+d", d2), d2)
							elseif ispercent then
								d2 = colorNum(format("%+.2f%%", d2), d2)
							else
								d2 = colorNum(format("%+.1f", d2), d2)
							end
							right = format("(%s||%s)", d1, d2)
						else
							right = format("(%s)", d1)
						end
					end
				end
			elseif calcSum then
				if s then
					if (s - floor(s)) == 0 then
						s = format("%d", s)
					elseif ispercent then
						s = format("%.2f%%", s)
					else
						s = format("%.1f", s)
					end
					right = s
				end
			elseif calcDiff then
				local d = ((not d1) or (d1 - floor(d1)) == 0) and ((not d2) or ((d2 - floor(d2)) == 0))
				if d1 then
					if d then
						d1 = colorNum(format("%+d", d1), d1)
					elseif ispercent then
						d1 = colorNum(format("%+.2f%%", d1), d1)
					else
						d1 = colorNum(format("%+.1f", d1), d1)
					end
					if d2 then
						if d then
							d2 = colorNum(format("%+d", d2), d2)
						elseif ispercent then
							d2 = colorNum(format("%+.2f%%", d2), d2)
						else
							d2 = colorNum(format("%+.1f", d2), d2)
						end
						right = format("%s||%s", d1, d2)
					else
						right = d1
					end
				end
			end
			if right then
				if n == "TANKPOINTS" then
					if tpSupport then
						left = tpLocale["TankPoints"]
					else
						left = "TankPoints"
					end
				elseif n == "TOTALREDUCTION" then
					if tpSupport then
						left = tpLocale["Total Reduction"]
					else
						left = "Total Reduction"
					end
				else
					left = StatLogic:GetStatNameFromID(n)
				end
				tinsert(output, {left, right})
			end
		end
	end
	-- Write cache
	cache[id] = output
	if table.maxn(output) == 0 then return end
	-------------------
	-- Write Tooltip --
	if profileDB.sumBlankLine then
		tooltip:AddLine(" ")
	end
	if profileDB.sumShowTitle then
		tooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..L["Stat Summary"]..FONT_COLOR_CODE_CLOSE)
		if profileDB.sumShowIcon then
			tooltip:AddTexture("Interface\\AddOns\\RatingBuster\\images\\Sigma")
		end
	end
	for _, o in ipairs(output) do
		tooltip:AddDoubleLine(o[1], o[2])
	end
	if profileDB.sumBlankLineAfter then
		tooltip:AddLine(" ")
	end
end


-- RatingBuster:Bench(1000)
---------
-- self:SplitDoJoin("+24 Agility/+4 Stamina, +4 Dodge and +4 Spell Crit/+5 Spirit", {"/", " and ", ","})
-- 1000 times: 0.16 - 0.18 without Compost
-- 1000 times: 0.22 - 0.24 with Compost
---------
-- RatingBuster.ProcessTooltip(ItemRefTooltip, link)
-- 1000 times: 0.31 sec - 0.7.6
-- 1000 times: 0.29 sec - 0.
-- 1000 times: 0.24 sec - 0.8.58.0
---------
-- strjoin 1000000 times: 0.46
-- ..      1000000 times: 0.27
--------------
function RatingBuster:Bench(k)
	local t1 = GetTime()
	local link = GetInventoryItemLink("player", 12)
	for i = 1, k, 1 do
		---------------------------------------------------------------------------
		--self:SplitDoJoin("+24 Agility/+4 Stamina, +4 Dodge and +4 Spell Crit/+5 Spirit", {"/", " and ", ","})
		---------------------------------------------------------------------------
		ItemRefTooltip:SetInventoryItem("player", 12)
		RatingBuster.ProcessTooltip(ItemRefTooltip, link)
		---------------------------------------------------------------------------
		--ItemRefTooltip:SetScript("OnTooltipSetItem", function(frame, ...) RatingBuster:Print("OnTooltipSetItem") end)
		----------------------------------------------------------------------
		--local h = strjoin("", "test", "123")
		--local h = "test".."123"
		--------------------------------------------------------------------------------
	end
	return GetTime() - t1
end
