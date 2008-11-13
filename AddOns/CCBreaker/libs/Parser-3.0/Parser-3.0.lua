--[[
Name: Parser-3.0
Revision: $Rev: 44704 $
Author: Cameron Kenneth Knight (ckknight@gmail.com),
        Mikord (of MSBT),
        Rophy
Website: http://wiki.wowace.com/index.php/Parser-3.0
Documentation: http://wiki.wowace.com/index.php/Parser-3.0
SVN: svn://svn.wowace.com/wowace/trunk/Parser-3.0/Parser-3.0
Description: Combat Parser library
Dependencies: AceLibrary
License: LGPL v2.1
]]

local MAJOR_VERSION = "Parser-3.0"
local MAJOR_LOCALE_VERSION = "Parser-Locale-3.0"
local MINOR_VERSION = "$Revision: 44704 $"

local AceLibrary = AceLibrary
local error = error

-- This ensures the code is only executed if the library doesn't already exist, or is a newer version
if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0.") end

local EVENTTYPE_DAMAGE = "Damage"
local EVENTTYPE_HEAL = "Heal"
local EVENTTYPE_ENVIRONMENTAL = "Environmental"
local EVENTTYPE_MISS = "Miss"
local EVENTTYPE_DEATH = "Death"
local EVENTTYPE_CAST = "Cast"
local EVENTTYPE_DRAIN = "Drain"
local EVENTTYPE_DURABILITY = "Durability"
local EVENTTYPE_EXTRAATTACK = "Extra Attack"
local EVENTTYPE_INTERRUPT = "Interrupt"
local EVENTTYPE_DISPEL = "Dispel"
local EVENTTYPE_LEECH = "Leech"
local EVENTTYPE_FAIL = "Fail"
local EVENTTYPE_ENCHANT = "Enchant"
local EVENTTYPE_REPUTATION = "Reputation"
local EVENTTYPE_HONOR = "Honor"
local EVENTTYPE_EXPERIENCE = "Experience"
local EVENTTYPE_FADE = "Fade"
local EVENTTYPE_GAIN = "Gain"
local EVENTTYPE_AURA = "Aura"
local EVENTTYPE_FEEDPET = "Feed Pet"
local EVENTTYPE_CREATE = "Create"
local EVENTTYPE_SKILL = "Skill"
local EVENTTYPE_UNKNOWN = "Unknown"
local DAMAGETYPE_PHYSICAL = "Physical"
local DAMAGETYPE_HOLY = "Holy"
local DAMAGETYPE_FIRE = "Fire"
local DAMAGETYPE_NATURE = "Nature"
local DAMAGETYPE_FROST = "Frost"
local DAMAGETYPE_SHADOW = "Shadow"
local DAMAGETYPE_ARCANE = "Arcane"
local DAMAGETYPE_UNKNOWN = "Unknown"
local ATTRIBUTE_MANA = "Mana"
local ATTRIBUTE_RAGE = "Rage"
local ATTRIBUTE_ENERGY = "Energy"
local ATTRIBUTE_FOCUS = "Focus"
local ATTRIBUTE_HEALTH = "Health"
local ATTRIBUTE_HAPPINESS = "Happiness"
local ATTRIBUTE_UNKNOWN = "Unknown"
local MISSTYPE_MISS = "Miss"
local MISSTYPE_PARRY = "Parry"
local MISSTYPE_DODGE = "Dodge"
local MISSTYPE_REFLECT = "Reflect"
local MISSTYPE_DEFLECT = "Deflect"
local MISSTYPE_RESIST = "Resist"
local MISSTYPE_ABSORB = "Absorb"
local MISSTYPE_BLOCK = "Block"
local MISSTYPE_EVADE = "Evade"
local MISSTYPE_IMMUNE = "Immune"
local HAZARDTYPE_DROWNING = "Drowning"
local HAZARDTYPE_FALLING = "Falling"
local HAZARDTYPE_FATIGUE = "Fatigue"
local HAZARDTYPE_FIRE = "Fire"
local HAZARDTYPE_LAVA = "Lava"
local HAZARDTYPE_SLIME = "Slime"

local eventTypeToLocal = {
	[EVENTTYPE_DAMAGE] = DAMAGE,
	[EVENTTYPE_HEAL] = "Heal",
	[EVENTTYPE_ENVIRONMENTAL] = "Environmental",
	[EVENTTYPE_MISS] = MISS,
	[EVENTTYPE_DEATH] = "Death",
	[EVENTTYPE_CAST] = "Cast",
	[EVENTTYPE_DRAIN] = "Drain",
	[EVENTTYPE_DURABILITY] = "Durability",
	[EVENTTYPE_EXTRAATTACK] = "Extra Attack",
	[EVENTTYPE_INTERRUPT] = "Interrupt",
	[EVENTTYPE_DISPEL] = "Dispel",
	[EVENTTYPE_LEECH] = "Leech",
	[EVENTTYPE_FAIL] = "Fail",
	[EVENTTYPE_ENCHANT] = "Enchant",
	[EVENTTYPE_REPUTATION] = "Reputation",
	[EVENTTYPE_HONOR] = "Honor",
	[EVENTTYPE_EXPERIENCE] = "Experience",
	[EVENTTYPE_FADE] = "Fade",
	[EVENTTYPE_GAIN] = "Gain",
	[EVENTTYPE_AURA] = "Aura",
	[EVENTTYPE_FEEDPET] = "Feed Pet",
	[EVENTTYPE_CREATE] = "Create",
	[EVENTTYPE_SKILL] = SKILL,
	[EVENTTYPE_UNKNOWN] = UNKNOWN,
}

local fixDamageType = setmetatable({}, {__index = function(self, key)
	if key == nil then
		return nil
	end
	self[key] = key
	return key
end})

local CurrentLocale = GetLocale()

if CurrentLocale == "frFR" then
	fixDamageType["Arcane"] = SPELL_SCHOOL6_CAP
elseif CurrentLocale == "zhTW" then
	fixDamageType["暗影"] = SPELL_SCHOOL5_CAP
end

local damageTypeToLocal = {
	[DAMAGETYPE_PHYSICAL] = SPELL_SCHOOL0_CAP,
	[DAMAGETYPE_HOLY] = SPELL_SCHOOL1_CAP,
	[DAMAGETYPE_FIRE] = SPELL_SCHOOL2_CAP,
	[DAMAGETYPE_NATURE] = SPELL_SCHOOL3_CAP,
	[DAMAGETYPE_FROST] = SPELL_SCHOOL4_CAP,
	[DAMAGETYPE_SHADOW] = SPELL_SCHOOL5_CAP,
	[DAMAGETYPE_ARCANE] = SPELL_SCHOOL6_CAP,
	[DAMAGETYPE_UNKNOWN] = UNKNOWN,	
}

local missTypeToLocal = {
	[MISSTYPE_MISS] = MISS,
	[MISSTYPE_PARRY] = PARRY,
	[MISSTYPE_DODGE] = DODGE,
	[MISSTYPE_DEFLECT] = DEFLECT,
	[MISSTYPE_REFLECT] = REFLECT,
	[MISSTYPE_RESIST] = RESIST,
	[MISSTYPE_ABSORB] = ABSORB,
	[MISSTYPE_BLOCK] = BLOCK,
	[MISSTYPE_EVADE] = EVADE,
	[MISSTYPE_IMMUNE] = IMMUNE,
}

local hazardTypeToLocal = {
	[HAZARDTYPE_DROWNING] = "Drowning",
	[HAZARDTYPE_FALLING] = "Falling",
	[HAZARDTYPE_FATIGUE] = "Fatigue",
	[HAZARDTYPE_FIRE] = "Fire",
	[HAZARDTYPE_LAVA] = "Lava",
	[HAZARDTYPE_SLIME] = "Slime",
}

if CurrentLocale == "koKR" then
	eventTypeToLocal[EVENTTYPE_HEAL] = "치유"
	eventTypeToLocal[EVENTTYPE_ENVIRONMENTAL] = "환경"
	eventTypeToLocal[EVENTTYPE_DEATH] = "죽음"
	eventTypeToLocal[EVENTTYPE_CAST] = "시전"
	eventTypeToLocal[EVENTTYPE_DRAIN] = "소진"
	eventTypeToLocal[EVENTTYPE_DURABILITY] = "내구도"
	eventTypeToLocal[EVENTTYPE_EXTRAATTACK] = "추가 공격"
	eventTypeToLocal[EVENTTYPE_INTERRUPT] = "차단"
	eventTypeToLocal[EVENTTYPE_DISPEL] = "해제"
	eventTypeToLocal[EVENTTYPE_LEECH] = "착취"
	eventTypeToLocal[EVENTTYPE_FAIL] = "실패"
	eventTypeToLocal[EVENTTYPE_ENCHANT] = "마법부여"
	eventTypeToLocal[EVENTTYPE_REPUTATION] = "평판"
	eventTypeToLocal[EVENTTYPE_HONOR] = "명예"
	eventTypeToLocal[EVENTTYPE_EXPERIENCE] = "경험치"
	eventTypeToLocal[EVENTTYPE_FADE] = "사라짐"
	eventTypeToLocal[EVENTTYPE_GAIN] = "획득"
	eventTypeToLocal[EVENTTYPE_AURA] = "효과"
	eventTypeToLocal[EVENTTYPE_FEEDPET] = "먹이주기"
	eventTypeToLocal[EVENTTYPE_CREATE] = "제작"
	
	hazardTypeToLocal[HAZARDTYPE_DROWNING] = "호흡"
	hazardTypeToLocal[HAZARDTYPE_FALLING] = "낙하"
	hazardTypeToLocal[HAZARDTYPE_FATIGUE] = "피로"
	hazardTypeToLocal[HAZARDTYPE_FIRE] = "화염"
	hazardTypeToLocal[HAZARDTYPE_LAVA] = "용암"
	hazardTypeToLocal[HAZARDTYPE_SLIME] = "독성"
end


local Parser = AceLibrary("AceOO-2.0").Mixin { "RegisterParserEvent", "UnregisterParserEvent", "UnregisterAllParserEvents", "IsParserEventRegistered" }

local _G = _G
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local table_concat = table.concat
local select = select
local tonumber = tonumber
local GetTime = GetTime
local pcall = pcall
local geterrorhandler = geterrorhandler
local pairs = pairs
local ipairs = ipairs
local next = next
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local UnitName = UnitName
local UnitExists = UnitExists
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsFriend = UnitIsFriend
local playerName = UnitName("player")
local string_find = string.find
local setmetatable = setmetatable
local rawget = rawget
local type = type
local tostring = tostring
local loadstring = loadstring
local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local assert = assert
local unpack = unpack

local eventSearchMap = {}
local globalStringInfo = {}
local messages = {}
local toUnitID = {}
local recentPvP = {}
local function toliteral(v)
	if type(v) == "string" then
		return ("%q"):format(v)
	else
		return ("%s"):format(tostring(v))
	end
end
local function isList(v)
	local num = 0
	for k in pairs(v) do
		num = num + 1
	end
	for i in ipairs(v) do
		num = num - 1
	end
	return num == 0
end
local tmp
local function validateFilter(filter)
	if type(filter) ~= "table" then
		return "Filter is not a table"
	end
	for k, v in pairs(filter) do
		if type(k) ~= "string" then
			return ("%s is an invalid key. Must be a string."):format(tostring(k))
		end
		local left, modifier = k:match("^(.+)_([^_]+)$")
		local type_v = type(v)
		if not modifier or modifier == "not" then
			if type_v ~= "boolean" and type_v ~= "string" and type_v ~= "number" and type_v ~= "function" then
				return ("[%q] = %s, is invalid. Value must be a boolean, string, number, or function."):format(k, toliteral(v))
			end
		elseif modifier == "in" or modifier == "notin" then
			if type_v ~= "table" then
				return ("[%q] = %s, is invalid. Value must be a table."):format(k, toliteral(v))
			end
		elseif modifier == "start" or modifier == "end" or modifier == "match" or modifier == "notstart" or modifier == "notend" or modifier == "notmatch" then
			if type_v ~= "string" then
				return ("[%q] = %s, is invalid. Value must be a string."):format(k, toliteral(v))
			end
		elseif modifier == "lt" or modifier == "le" or modifier == "gt" or modifier == "ge" then
			if type_v ~= "string" and type_v ~= "number" and type_v ~= "function" then
				return ("[%q] = %s, is invalid. Value must be a string, number, or function."):format(k, toliteral(v))
			end
		end
		if k == "eventType" or left == "eventType" then
			if not modifier or modifier == "not" then
				if not eventTypeToLocal[v] then
					if not tmp then
						tmp = {}
					end
					for k in pairs(eventTypeToLocal) do
						tmp[#tmp+1] = k
					end
					local s = ("[%q] = %s, is invalid, Value must be "):format(k, toliteral(v))
					for i = 1, #tmp-1 do
						s = s .. ("%q"):format(tmp[i]) .. ", "
					end
					s = s .. "or " .. ("%q"):format(tmp[#tmp]) .. "."
					for k in pairs(tmp) do
						tmp[k] = nil
					end
					return s
				end
			elseif modifier == "in" or modifier == "notin" then
				local bad
				if isList(v) then
					for _,u in ipairs(v) do
						if not eventTypeToLocal[u] then
							bad = u
							break
						end
					end
				else
					for u in pairs(v) do
						if not eventTypeToLocal[u] then
							bad = u
							break
						end
					end
				end
				if bad then
					if not tmp then
						tmp = {}
					end
					for k in pairs(eventTypeToLocal) do
						tmp[#tmp+1] = k
					end
					local s = ("[%q] = { %s }, is invalid, Value must be "):format(k, toliteral(bad))
					for i = 1, #tmp-1 do
						s = s .. ("%q"):format(tmp[i]) .. ", "
					end
					s = s .. "or " .. ("%q"):format(tmp[#tmp]) .. "."
					for k in pairs(tmp) do
						tmp[k] = nil
					end
					return s
				end
			end
		end
	end
	return nil
end
local t, t_2 = {}, {}
local filterFuncs = setmetatable({}, {__index = function(self, filter)
	t[1] = [[local string_find = string.find; local type = type;]]
	t[2] = [[return function(t) ]]
	for k,v in pairs(filter) do
		if type(v) == "function" then
			table.insert(t, 2, "local ")
			table.insert(t, 3, k)
			table.insert(t, 4, "_func = assert(AceLibrary('Parser-3.0').__")
			table.insert(t, 5, k)
			table.insert(t, 6, "_func)")
			Parser[("__%s_func"):format(k)] = v
			t[#t+1] = "local "
			t[#t+1] = k
			t[#t+1] = " = "
			t[#t+1] = k
			t[#t+1] = "_func()"
		end
	end
	t[#t+1] = [[return ]]
	local first = true
	local current_tab = 0
	for k,v in pairs(filter) do
		if k ~= 'eventType' and k ~= 'eventType_in' and k ~= 'eventType_notin' and k ~= 'eventType_not' then
			local k,v = k,v
			if not first then
				t[#t+1] = [[ and ]]
			end
			first = false
			local toliteral_v
			if type(v) ~= "function" then
				toliteral_v = toliteral(v)
			else
				toliteral_v = k
			end
			if k:find("_lt$") then
				t[#t+1] = ([[type(t[%q]) == %q and t[%q] < %s]]):format(k:sub(1, -4), type(v), k:sub(1, -4), toliteral_v)
			elseif k:find("_le$") then
				t[#t+1] = ([[type(t[%q]) == %q and t[%q] <= %s]]):format(k:sub(1, -4), type(v), k:sub(1, -4), toliteral_v)
			elseif k:find("_gt$") then
				t[#t+1] = ([[type(t[%q]) == %q and t[%q] > %s]]):format(k:sub(1, -4), type(v), k:sub(1, -4), toliteral_v)
			elseif k:find("_ge$") then
				t[#t+1] = ([[type(t[%q]) == %q and t[%q] >= %s]]):format(k:sub(1, -4), type(v), k:sub(1, -4), toliteral_v)
			elseif k:find("_not$") then
				if v == false then
					t[#t+1] = ([=[t[%q]]=]):format(k:sub(1, -5))
				else
					t[#t+1] = ([[t[%q] ~= %s]]):format(k:sub(1, -5), toliteral_v)
				end
			elseif k:find("_start$") then
				local v = "^" .. v:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
				t[#t+1] = ([[type(t[%q]) == "string" and string_find(t[%q], %q)]]):format(k:sub(1, -7), k:sub(1, -7), tostring(v))
			elseif k:find("_end$") then
				local v = v:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1") .. "$"
				t[#t+1] = ([[type(t[%q]) == "string" and string_find(t[%q], %q)]]):format(k:sub(1, -5), k:sub(1, -5), tostring(v))
			elseif k:find("_match$") then
				t[#t+1] = ([[type(t[%q]) == "string" and string_find(t[%q], %q)]]):format(k:sub(1, -7), k:sub(1, -7), tostring(v))
			elseif k:find("_notstart$") then
				local v = "^" .. v:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
				t[#t+1] = ([[(type(t[%q]) ~= "string" or not string_find(t[%q], %q))]]):format(k:sub(1, -10), k:sub(1, -10), tostring(v))
			elseif k:find("_notend$") then
				local v = v:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1") .. "$"
				t[#t+1] = ([[(type(t[%q]) ~= "string" or not string_find(t[%q], %q))]]):format(k:sub(1, -8), k:sub(1, -8), tostring(v))
			elseif k:find("_notmatch$") then
				t[#t+1] = ([[(type(t[%q]) ~= "string" or not string_find(t[%q], %q))]]):format(k:sub(1, -10), k:sub(1, -10), tostring(v))
			elseif k:find("_in$") then
				if next(v) == nil then
					t[#t+1] = "false"
				else
					current_tab = current_tab + 1
					t_2[#t_2+1] = ("local tab_%d = { "):format(current_tab)
					if isList(v) then
						for _,l in ipairs(v) do
							t_2[#t_2+1] = ("[%s] = true, "):format(toliteral(l))
						end
					else
						for l,u in pairs(v) do
							if u then
								t_2[#t_2+1] = ("[%s] = true, "):format(toliteral(l))
							end
						end
					end	
					t_2[#t_2+1] = "};"
					table.insert(t, 2, table_concat(t_2))
					for i = 1, #t_2 do
						t_2[i] = nil
					end
					t[#t+1] = ("tab_%d[t[%q] or false]"):format(current_tab, k:sub(1, -4))
				end
			elseif k:find("_notin$") then
				if next(v) == nil then
					t[#t+1] = "true"
				else
					current_tab = current_tab + 1
					t_2[#t_2+1] = ("local tab_%d = { "):format(current_tab)
					if isList(v) then
						for _,l in ipairs(v) do
							t_2[#t_2+1] = ("[%s] = true, "):format(toliteral(l))
						end
					else
						for l,u in pairs(v) do
							if u then
								t_2[#t_2+1] = ("[%s] = true, "):format(toliteral(l))
							end
						end
					end
					t_2[#t_2+1] = "};"
					table.insert(t, 2, table_concat(t_2))
					for i = 1, #t_2 do
						t_2[i] = nil
					end
					t[#t+1] = ("not tab_%d[t[%q] or false]"):format(current_tab, k:sub(1, -4))
				end
			else
				if v == false then
					t[#t+1] = ([=[not t[%q]]=]):format(k)
				else
					t[#t+1] = ([[t[%q] == %s]]):format(k, toliteral_v)
				end
			end
		end
	end
	if first then
		t[#t+1] = [[true]]
	end
	t[#t+1] = [[ end]]
	local s = table_concat(t)
	for i = 1, #t do
		t[i] = nil
	end
	local func, problem = loadstring(s)
	if not func then
		error(("Error loading function: [=[%s]=]. %s"):format(s, problem))
	end
	local func = func()
	for k,v in pairs(filter) do
		if type(v) == "function" then
			Parser[("__%s_func"):format(k)] = nil
		end
	end
	self[filter] = func
	return func
end, __mode = 'k' })
local registry
local ownerRegistry

local parserEvent = {}

local function GlobalStringCompareFunc(alpha, bravo)
	-- Get the global string for the passed names.
	alpha = _G[alpha]
	bravo = _G[bravo]

	local alpha_stripped = alpha:gsub("%%[sd]", ""):gsub("%%%d%$[sd]", "")
	local bravo_stripped = bravo:gsub("%%[sd]", ""):gsub("%%%d%$[sd]", "")

	-- Check if the stripped global strings are the same length.
	if alpha_stripped:len() == bravo_stripped:len() then
		-- Count the number of captures in each string.
		local alpha_num = 0
		for _ in alpha:gmatch("%%%d%$[sd]") do
			alpha_num = alpha_num + 1
		end
		if alpha_num == 0 then
			for _ in alpha:gmatch("%%[sd]") do
				alpha_num = alpha_num + 1
			end
		end

		local bravo_num = 0
		for _ in bravo:gmatch("%%%d%$[sd]") do
			bravo_num = bravo_num + 1
		end
		if bravo_num == 0 then
			for _ in bravo:gmatch("%%[sd]") do
				bravo_num = bravo_num + 1
			end
		end
		
		-- Return the global string with the least captures.
		return alpha_num < bravo_num
	else
		-- Return the longest global string.
		return alpha_stripped:len() > bravo_stripped:len()
	end
end

local function CreateEventSearchMap()
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS"] = {
		"SPELLLOGCRITSCHOOLOTHEROTHER", "SPELLLOGSCHOOLOTHEROTHER", "COMBATHITCRITSCHOOLOTHEROTHER",
		"COMBATHITSCHOOLOTHEROTHER", "SPELLLOGCRITOTHEROTHER", "SPELLLOGOTHEROTHER", "COMBATHITCRITOTHEROTHER",
		"COMBATHITOTHEROTHER", "ENVIRONMENTALDAMAGE_SLIME_OTHER", "VSENVIRONMENTALDAMAGE_LAVA_OTHER",
		"VSENVIRONMENTALDAMAGE_FIRE_OTHER", "VSENVIRONMENTALDAMAGE_FATIGUE_OTHER", "VSENVIRONMENTALDAMAGE_DROWNING_OTHER",
		"VSENVIRONMENTALDAMAGE_FALLING_OTHER"
	}
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS"]
	eventSearchMap["CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS"]
	
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES"] = {
		"VSABSORBOTHEROTHER", "VSRESISTOTHEROTHER", "IMMUNEDAMAGECLASSOTHEROTHER", "VSIMMUNEOTHEROTHER", "IMMUNEOTHEROTHER",
		"VSDEFLECTOTHEROTHER", "VSPARRYOTHEROTHER", "VSEVADEOTHEROTHER", "VSBLOCKOTHEROTHER", "VSDODGEOTHEROTHER",
		"MISSEDOTHEROTHER",
	}
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES"]
	eventSearchMap["CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES"]
	
	-- Incoming Melee Hits/Crits
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"] = {
		"SPELLLOGCRITSCHOOLOTHERSELF", "SPELLLOGSCHOOLOTHERSELF", "COMBATHITCRITSCHOOLOTHERSELF",
		"SPELLLOGCRITSCHOOLOTHEROTHER", "COMBATHITSCHOOLOTHERSELF", "SPELLLOGSCHOOLOTHEROTHER",
		"COMBATHITCRITSCHOOLOTHEROTHER", "COMBATHITSCHOOLOTHEROTHER", "SPELLLOGCRITOTHERSELF", "SPELLLOGOTHERSELF",
		"COMBATHITCRITOTHERSELF", "SPELLLOGCRITOTHEROTHER", "COMBATHITOTHERSELF", "SPELLLOGOTHEROTHER",
		"COMBATHITCRITOTHEROTHER", "COMBATHITOTHEROTHER", "VSENVIRONMENTALDAMAGE_SLIME_OTHER",
		"VSENVIRONMENTALDAMAGE_LAVA_OTHER", "VSENVIRONMENTALDAMAGE_FIRE_OTHER", "VSENVIRONMENTALDAMAGE_FATIGUE_OTHER",
		"VSENVIRONMENTALDAMAGE_DROWNING_OTHER", "VSENVIRONMENTALDAMAGE_FALLING_OTHER"
	}
	eventSearchMap["CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"]
	eventSearchMap["CHAT_MSG_COMBAT_PARTY_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"]
	eventSearchMap["CHAT_MSG_COMBAT_PET_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"]
	
	-- Incoming Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes
	eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"] = {
		"VSABSORBOTHERSELF", "VSRESISTOTHERSELF", "VSABSORBOTHEROTHER", "VSRESISTOTHEROTHER", "IMMUNEOTHERSELF",
		"IMMUNEDAMAGECLASSOTHERSELF", "VSIMMUNEOTHERSELF", "IMMUNEDAMAGECLASSOTHEROTHER", "VSIMMUNEOTHEROTHER",
		"IMMUNEOTHEROTHER", "VSDEFLECTOTHERSELF", "VSPARRYOTHERSELF", "VSBLOCKOTHERSELF", "VSEVADEOTHERSELF",
		"VSDODGEOTHERSELF", "VSDEFLECTOTHEROTHER", "VSPARRYOTHEROTHER", "VSBLOCKOTHEROTHER", "VSEVADEOTHEROTHER",
		"VSDODGEOTHEROTHER", "MISSEDOTHERSELF", "MISSEDOTHEROTHER",
	}
	eventSearchMap["CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"]
	eventSearchMap["CHAT_MSG_COMBAT_PARTY_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"]
	eventSearchMap["CHAT_MSG_COMBAT_PET_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"]
	
	-- Incoming Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Reflects, Power Losses
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"] = {
		"SPELLLOGCRITSCHOOLOTHERSELF", "SPELLLOGSCHOOLOTHERSELF", "SPELLLOGCRITSCHOOLOTHEROTHER", "SPELLLOGSCHOOLOTHEROTHER",
		"SPELLLOGCRITOTHERSELF", "SPELLLOGOTHERSELF", "SPELLLOGCRITOTHEROTHER", "SPELLLOGOTHEROTHER", "SPELLCASTOTHERSTART",
		"SPELLPERFORMOTHERSTART", "SPELLPOWERLEECHOTHERSELF", "SPELLPOWERLEECHOTHEROTHER", "SPELLPOWERDRAINOTHERSELF",
		"SPELLPOWERDRAINOTHEROTHER", "SPELLPOWERDRAINSELF", "SPELLPOWERDRAINOTHER", "SPELLIMMUNEOTHERSELF",
		"SPELLREFLECTOTHEROTHER", "IMMUNESPELLOTHERSELF", "SPELLDEFLECTEDOTHEROTHER", "SPELLIMMUNEOTHEROTHER",
		"SPELLRESISTOTHEROTHER", "SPELLLOGABSORBOTHEROTHER", "SPELLPARRIEDOTHEROTHER", "SPELLBLOCKEDOTHEROTHER",
		"SPELLDODGEDOTHEROTHER", "SPELLEVADEDOTHEROTHER", "SPELLDEFLECTEDOTHERSELF", "IMMUNESPELLOTHEROTHER",
		"SPELLRESISTOTHERSELF", "SPELLREFLECTOTHERSELF", "SPELLBLOCKEDOTHERSELF", "SPELLPARRIEDOTHERSELF",
		"SPELLEVADEDOTHERSELF", "SPELLDODGEDOTHERSELF", "SPELLLOGABSORBOTHERSELF", "SPELLMISSOTHERSELF",
		"SPELLMISSOTHEROTHER", "INSTAKILLSELF", "INSTAKILLOTHER", "PROCRESISTOTHERSELF", "PROCRESISTOTHEROTHER",
		"SPELLSPLITDAMAGEOTHERSELF", "SPELLSPLITDAMAGEOTHEROTHER", "SPELLDURABILITYDAMAGEALLOTHERSELF",
		"SPELLDURABILITYDAMAGEALLOTHEROTHER", "SPELLDURABILITYDAMAGEOTHERSELF", "SPELLDURABILITYDAMAGEOTHEROTHER",
		"SPELLINTERRUPTOTHERSELF", "SPELLINTERRUPTOTHEROTHER", "SIMPLECASTOTHERSELF", "SIMPLECASTOTHEROTHER",
		"SPELLTERSE_OTHER", "SIMPLEPERFORMOTHERSELF", "OPEN_LOCK_OTHER", "SIMPLEPERFORMOTHEROTHER", "SPELLTERSEPERFORM_OTHER",
		"SPELLEXTRAATTACKSOTHER", "SPELLEXTRAATTACKSOTHER_SINGULAR", "DISPELFAILEDOTHERSELF", "DISPELFAILEDOTHEROTHER",
		"SPELLLOGCRITSCHOOLSELF", "SPELLLOGSCHOOLSELF", "SPELLLOGCRITSCHOOLOTHER", "SPELLLOGCRITSELF", "SPELLLOGSELF",
		"SPELLLOGOTHER", "SPELLLOGSCHOOLOTHER", "SPELLRESISTOTHER", "SPELLRESISTSELF", "SPELLEVADEDOTHER", "IMMUNESPELLOTHER", "IMMUNESPELLSELF",
		"SPELLIMMUNEOTHER", "SPELLIMMUNESELF", "SPELLLOGABSORBOTHER", "SPELLLOGABSORBSELF",
	}
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_PARTY_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_PET_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"]
	
	-- Incoming damage from shields
	eventSearchMap["CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS"] = {
		"DAMAGESHIELDOTHEROTHER","DAMAGESHIELDOTHERSELF","SPELLRESISTOTHEROTHER","SPELLRESISTOTHERSELF"
	}

	-- Incoming DoTs, Power Gains
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"] = {
		"PERIODICAURADAMAGESELFSELF", "PERIODICAURADAMAGEOTHERSELF", "PERIODICAURADAMAGESELFOTHER",
		"PERIODICAURADAMAGEOTHEROTHER", "PERIODICAURADAMAGESELF", "PERIODICAURADAMAGEOTHER",
		"AURAAPPLICATIONADDEDSELFHARMFUL", "AURAADDEDSELFHARMFUL", "AURAAPPLICATIONADDEDOTHERHARMFUL",
		"AURAADDEDOTHERHARMFUL", "SPELLLOGABSORBSELFOTHER", "SPELLLOGABSORBOTHEROTHER", "SPELLLOGABSORBSELFSELF",
		"SPELLLOGABSORBOTHERSELF", "SPELLPOWERLEECHSELFOTHER", "SPELLPOWERDRAINSELFSELF", "SPELLPOWERDRAINSELFOTHER",
		"SPELLLOGABSORBSELF", "SPELLLOGABSORBOTHER",
	}


	-- Incoming HoTs, Power Gains
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS"] = {
		"PERIODICAURAHEALSELFOTHER", "PERIODICAURAHEALOTHERSELF", "PERIODICAURAHEALOTHEROTHER", "PERIODICAURAHEALSELFSELF",
		"AURAAPPLICATIONADDEDSELFHELPFUL", "POWERGAINOTHEROTHER", "POWERGAINOTHERSELF", "POWERGAINSELFSELF",
		"AURAAPPLICATIONADDEDOTHERHELPFUL", "AURAADDEDSELFHELPFUL", "POWERGAINSELFOTHER", "AURAADDEDOTHERHELPFUL",
		"SPELLPOWERLEECHSELFOTHER", "SPELLPOWERDRAINSELFSELF", "SPELLPOWERDRAINSELFOTHER", "PERIODICAURADAMAGESELFSELF",
		"PERIODICAURADAMAGEOTHERSELF", "PERIODICAURADAMAGESELF",
	}

	-- Outgoing Melee Hits/Crits, Environmental Damage
	eventSearchMap["CHAT_MSG_COMBAT_SELF_HITS"] = {
		-- Physical Hit/Crit, Environmental.
		'SPELLLOGCRITSCHOOLSELFOTHER', 'SPELLLOGSCHOOLSELFOTHER', 'COMBATHITCRITSCHOOLSELFOTHER', 'COMBATHITSCHOOLSELFOTHER',
		'SPELLLOGCRITSELFOTHER', 'SPELLLOGSELFOTHER', 'COMBATHITCRITSELFOTHER', 'COMBATHITSELFOTHER',
		'VSENVIRONMENTALDAMAGE_SLIME_SELF', 'VSENVIRONMENTALDAMAGE_LAVA_SELF', 'VSENVIRONMENTALDAMAGE_FATIGUE_SELF',
		'VSENVIRONMENTALDAMAGE_FIRE_SELF', 'VSENVIRONMENTALDAMAGE_DROWNING_SELF', 'VSENVIRONMENTALDAMAGE_FALLING_SELF',
	}


	-- Outgoing Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes, Evades
	eventSearchMap["CHAT_MSG_COMBAT_SELF_MISSES"] = {
		-- Miss, Dodge, Parry, Block, Absorb, Immune, Evade.
		"MISSEDSELFOTHER", "VSDODGESELFOTHER", "VSPARRYSELFOTHER", "VSBLOCKSELFOTHER",
		"VSABSORBSELFOTHER", "VSIMMUNESELFOTHER", "VSEVADESELFOTHER"
	}


	-- Outgoing Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Evades, Extra Attacks
	eventSearchMap["CHAT_MSG_SPELL_SELF_DAMAGE"] = {
		-- Ability Crit/Hit, Self Spell Crit/Hit, Spell Crit/Hit, Miss, Dodge, Parry, Block, Spell Resist, Absorb, Immune,
		-- Reflect, Evade, Extra Attack(s), 
		"SPELLLOGCRITSCHOOLSELFSELF", "SPELLLOGSCHOOLSELFSELF", "SPELLLOGCRITSCHOOLSELFOTHER", "SPELLLOGSCHOOLSELFOTHER",
		"SPELLLOGCRITSELFSELF", "SPELLLOGSELFSELF", "SPELLLOGCRITSELFOTHER", "SPELLLOGSELFOTHER",
		"SPELLDURABILITYDAMAGEALLSELFOTHER", "SPELLDURABILITYDAMAGESELFOTHER", "SIMPLECASTSELFOTHER", "SIMPLECASTSELFSELF",
		"SPELLTERSE_SELF", "OPEN_LOCK_SELF", "SIMPLEPERFORMSELFOTHER", "SIMPLEPERFORMSELFSELF", "SPELLTERSEPERFORM_SELF",
		"SPELLIMMUNESELFSELF", "SPELLREFLECTSELFOTHER", "SPELLIMMUNESELFOTHER", "IMMUNESPELLSELFSELF",
		"SPELLDEFLECTEDSELFOTHER", "SPELLRESISTSELFOTHER", "SPELLLOGABSORBSELFOTHER", "SPELLBLOCKEDSELFOTHER",
		"SPELLPARRIEDSELFOTHER", "SPELLDODGEDSELFOTHER", "SPELLEVADEDSELFOTHER", "SPELLDEFLECTEDSELFSELF",
		"SPELLREFLECTSELFSELF", "IMMUNESPELLSELFOTHER", "SPELLRESISTSELFSELF", "SPELLPARRIEDSELFSELF", "SPELLDODGEDSELFSELF",
		"SPELLEVADEDSELFSELF", "SPELLLOGABSORBSELFSELF", "SPELLMISSSELFSELF", "SPELLMISSSELFOTHER", "SPELLCASTSELFSTART",
		"SPELLPERFORMSELFSTART", "SPELLINTERRUPTSELFOTHER", "DISPELFAILEDSELFSELF", "DISPELFAILEDSELFOTHER",
		"SPELLEXTRAATTACKSSELF", "SPELLEXTRAATTACKSSELF_SINGULAR", "SPELLPOWERLEECHSELFOTHER", "SPELLPOWERDRAINSELFSELF",
		"SPELLPOWERDRAINSELFOTHER", "SPELLLOGSCHOOLSELF", "SPELLLOGSCHOOLOTHER",
	}


	-- Outgoing damage from shields
	eventSearchMap["CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF"] = {
		"DAMAGESHIELDSELFOTHER", "SPELLRESISTSELFOTHER", "DAMAGESHIELDOTHEROTHER", "SPELLRESISTOTHEROTHER",
	}


	-- Outgoing Heals, Power Gains, Dispel/Purge Resists, Extra Attacks
	eventSearchMap["CHAT_MSG_SPELL_SELF_BUFF"] = {
		-- (Crit) Heal to self, (Crit) Heal to others, Power Gain from self, Power Leech, Dispel/Purge Resist, Extra Attack(s)
		"HEALEDCRITSELFSELF", "HEALEDCRITSELFOTHER", "HEALEDSELFSELF", "HEALEDSELFOTHER", "ITEMENCHANTMENTADDSELFSELF",
		"ITEMENCHANTMENTADDSELFOTHER", "SIMPLECASTSELFOTHER", "SIMPLECASTSELFSELF", "SPELLTERSE_SELF", "OPEN_LOCK_SELF",
		"SIMPLEPERFORMSELFOTHER", "SIMPLEPERFORMSELFSELF", "SPELLTERSEPERFORM_SELF", "DISPELFAILEDSELFSELF",
		"DISPELFAILEDSELFOTHER", "SPELLCASTSELFSTART", "SPELLPERFORMSELFSTART", "SPELLEXTRAATTACKSSELF",
		"SPELLPOWERLEECHSELFOTHER", "SPELLEXTRAATTACKSSELF_SINGULAR", "SPELLPOWERDRAINSELFSELF", "SPELLPOWERDRAINSELFOTHER",
		"POWERGAINSELFSELF", "POWERGAINSELFOTHER", "SPELLSPLITDAMAGESELFOTHER", "SPELLIMMUNESELFSELF", "SPELLREFLECTSELFOTHER",
		"SPELLIMMUNESELFOTHER", "IMMUNESPELLSELFSELF", "SPELLDEFLECTEDSELFOTHER", "SPELLRESISTSELFOTHER",
		"SPELLBLOCKEDSELFOTHER", "SPELLLOGABSORBSELFOTHER", "SPELLEVADEDSELFOTHER", "SPELLPARRIEDSELFOTHER",
		"SPELLDODGEDSELFOTHER", "SPELLREFLECTSELFSELF", "SPELLDEFLECTEDSELFSELF", "IMMUNESPELLSELFOTHER",
		"SPELLRESISTSELFSELF", "SPELLPARRIEDSELFSELF", "SPELLEVADEDSELFSELF", "SPELLLOGABSORBSELFSELF", "SPELLDODGEDSELFSELF",
		"PROCRESISTSELFSELF", "SPELLMISSSELFSELF", "PROCRESISTSELFOTHER", "SPELLMISSSELFOTHER",
	}

	-- Outgoing DoTs, Power Losses
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"] = {
		"AURAAPPLICATIONADDEDOTHERHARMFUL", "AURAADDEDOTHERHARMFUL", "PERIODICAURADAMAGESELFOTHER",
		"PERIODICAURADAMAGEOTHEROTHER", "PERIODICAURADAMAGEOTHER", "SPELLLOGABSORBSELFOTHER", "SPELLLOGABSORBOTHEROTHER",
		"SPELLPOWERLEECHOTHERSELF", "SPELLPOWERLEECHOTHEROTHER", "SPELLPOWERDRAINOTHERSELF", "SPELLPOWERDRAINOTHEROTHER",
		"POWERGAINOTHERSELF", "AURAAPPLICATIONADDEDOTHERHELPFUL", "POWERGAINOTHEROTHER", "AURAADDEDOTHERHELPFUL",
		"SPELLLOGABSORBOTHER",
	}
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"]
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"]

	-- Honor Gains
	eventSearchMap["CHAT_MSG_COMBAT_HONOR_GAIN"] = {
		"COMBATLOG_HONORGAIN", "COMBATLOG_HONORAWARD", "COMBATLOG_DISHONORGAIN"
	}
	
	-- Reputation Gains/Losses
	eventSearchMap["CHAT_MSG_COMBAT_FACTION_CHANGE"] = {
		"FACTION_STANDING_INCREASED", "FACTION_STANDING_DECREASED", "FACTION_STANDING_CHANGED"
	}
	
	-- Skill Gains
	eventSearchMap["CHAT_MSG_SKILL"] = {
		"SKILL_RANK_UP"
	}
	
	-- Experience Gains
	eventSearchMap["CHAT_MSG_COMBAT_XP_GAIN"] = {
		"COMBATLOG_XPGAIN_EXHAUSTION4_RAID", "COMBATLOG_XPGAIN_EXHAUSTION5_RAID", "COMBATLOG_XPGAIN_EXHAUSTION5_GROUP",
		"COMBATLOG_XPGAIN_EXHAUSTION4_GROUP", "COMBATLOG_XPGAIN_EXHAUSTION2_RAID", "COMBATLOG_XPGAIN_EXHAUSTION1_RAID",
		"COMBATLOG_XPGAIN_EXHAUSTION1_GROUP", "COMBATLOG_XPGAIN_EXHAUSTION2_GROUP",
		"COMBATLOG_XPGAIN_FIRSTPERSON_RAID", "COMBATLOG_XPGAIN_FIRSTPERSON_GROUP", "COMBATLOG_XPGAIN_EXHAUSTION5",
		"COMBATLOG_XPGAIN_EXHAUSTION4", "COMBATLOG_XPGAIN_EXHAUSTION1", "COMBATLOG_XPGAIN_EXHAUSTION2",
		"COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP",
		"COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED", "COMBATLOG_XPGAIN",
	}
	
	-- Aura
	eventSearchMap["CHAT_MSG_SPELL_AURA_GONE_OTHER"] = {
		"AURAREMOVEDOTHER"
	}
	eventSearchMap["CHAT_MSG_SPELL_AURA_GONE_PARTY"] = eventSearchMap["CHAT_MSG_SPELL_AURA_GONE_OTHER"]
	
	eventSearchMap["CHAT_MSG_SPELL_AURA_GONE_SELF"] = {
		"AURAREMOVEDSELF", "AURAREMOVEDOTHER",
	}
	
	eventSearchMap["CHAT_MSG_SPELL_BREAK_AURA"] = {
		"AURADISPELSELF3", "AURADISPELSELF2", "AURADISPELSELF", "AURADISPELOTHER3", "AURADISPELOTHER2",
		"AURADISPELOTHER",
	}
	
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"] = {
		"SPELLPOWERLEECHOTHERSELF", "SPELLEXTRAATTACKSOTHER", "HEALEDCRITOTHERSELF", "SPELLEXTRAATTACKSOTHER_SINGULAR",
		"SPELLPOWERLEECHOTHEROTHER", "HEALEDCRITOTHEROTHER", "SPELLPOWERDRAINOTHERSELF", "HEALEDOTHERSELF",
		"HEALEDCRITSELF", "HEALEDCRITOTHER", --[["HEALEDSELF",]] "SPELLPOWERDRAINOTHEROTHER", "HEALEDOTHEROTHER",
		"HEALEDOTHER", "POWERGAINOTHERSELF", "POWERGAINOTHEROTHER", "SPELLCASTOTHERSTART", "SIMPLEPERFORMOTHERSELF",
		"ITEMENCHANTMENTADDOTHERSELF", "SIMPLECASTOTHERSELF", "SIMPLEPERFORMOTHEROTHER", "OPEN_LOCK_OTHER",
		"ITEMENCHANTMENTADDOTHEROTHER", "SIMPLECASTOTHEROTHER", "SPELLTERSEPERFORM_OTHER", "SPELLTERSE_OTHER",
		"SPELLPERFORMOTHERSTART", "SPELLIMMUNEOTHERSELF", "SPELLREFLECTOTHEROTHER", "IMMUNESPELLOTHERSELF",
		"SPELLDEFLECTEDOTHEROTHER", "SPELLIMMUNEOTHEROTHER", "SPELLRESISTOTHEROTHER", "SPELLLOGABSORBOTHEROTHER",
		"SPELLPARRIEDOTHEROTHER", "SPELLBLOCKEDOTHEROTHER", "SPELLDODGEDOTHEROTHER", "SPELLEVADEDOTHEROTHER",
		"SPELLDEFLECTEDOTHERSELF", "IMMUNESPELLOTHEROTHER", "SPELLRESISTOTHERSELF", "SPELLREFLECTOTHERSELF",
		"SPELLBLOCKEDOTHERSELF", "SPELLPARRIEDOTHERSELF", "SPELLEVADEDOTHERSELF", "SPELLDODGEDOTHERSELF",
		"SPELLLOGABSORBOTHERSELF", "SPELLMISSOTHERSELF", "SPELLMISSOTHEROTHER", "PROCRESISTOTHERSELF",
		"PROCRESISTOTHEROTHER", "SPELLSPLITDAMAGEOTHERSELF", "SPELLSPLITDAMAGEOTHEROTHER", "DISPELFAILEDOTHERSELF",
		"DISPELFAILEDOTHEROTHER"
	}
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]
	eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]
	eventSearchMap["CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]
	eventSearchMap["CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]
	eventSearchMap["CHAT_MSG_SPELL_PARTY_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]
	eventSearchMap["CHAT_MSG_SPELL_PET_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"]

	-- Killing Blows
	eventSearchMap["CHAT_MSG_COMBAT_FRIENDLY_DEATH"] = {
		"SELFKILLOTHER", "UNITDESTROYEDOTHER", "PARTYKILLOTHER", "UNITDIESSELF", "UNITDIESOTHER",
	}
	eventSearchMap["CHAT_MSG_COMBAT_HOSTILE_DEATH"] = eventSearchMap["CHAT_MSG_COMBAT_FRIENDLY_DEATH"]

	-- Created Items (Soul Shards)
	eventSearchMap["CHAT_MSG_LOOT"] = {
		"LOOT_ITEM", "LOOT_ITEM_MULTIPLE", "LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF",
		"LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
	}
	
	eventSearchMap["CHAT_MSG_MONEY"] = {
		"YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT", "LOOT_MONEY",
	}
	
	eventSearchMap["CHAT_MSG_SPELL_FAILED_LOCALPLAYER"] = {
		"SPELLFAILPERFORMSELF", "SPELLFAILCASTSELF",
	}
	
	eventSearchMap["CHAT_MSG_SPELL_ITEM_ENCHANTMENTS"] = {
		"ITEMENCHANTMENTADDSELFSELF", "ITEMENCHANTMENTADDSELFOTHER", "ITEMENCHANTMENTADDOTHERSELF",
		"ITEMENCHANTMENTADDOTHEROTHER",
	}
	
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"] = {
		"PERIODICAURAHEALSELFOTHER", "PERIODICAURAHEALOTHEROTHER", "SPELLPOWERLEECHOTHERSELF", "SPELLPOWERLEECHOTHEROTHER",
		"SPELLPOWERDRAINOTHERSELF", "SPELLPOWERDRAINOTHEROTHER", "POWERGAINOTHERSELF", "AURAAPPLICATIONADDEDOTHERHELPFUL",
		"POWERGAINOTHEROTHER", "AURAADDEDOTHERHELPFUL", "PERIODICAURADAMAGESELFOTHER", "PERIODICAURADAMAGEOTHEROTHER",
		"PERIODICAURADAMAGEOTHER", "AURAAPPLICATIONADDEDOTHERHARMFUL", "AURAADDEDOTHERHARMFUL",
	}
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"]
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"]
	eventSearchMap["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"]
	
	eventSearchMap["CHAT_MSG_SPELL_TRADESKILLS"] = {
		"FEEDPET_LOG_FIRSTPERSON", "FEEDPET_LOG_THIRDPERSON", "TRADESKILL_LOG_FIRSTPERSON", "TRADESKILL_LOG_THIRDPERSON",
	}
	
	if CurrentLocale == "deDE" then
		-- Remove ITEMENCHANTMENTADDOTHERSELF, it's ambiguous to SIMPLECASTOTHEROTHER.
		-- Remove ITEMENCHANTMENTADDSELFSELF, it's ambiguous to SIMPLECASTSELFOTHER.
		for event, list in pairs(eventSearchMap) do
			local i = 1
			while i < #list do
				local pattern = list[i]
				if pattern == "ITEMENCHANTMENTADDOTHERSELF" or pattern == "ITEMENCHANTMENTADDSELFSELF" then
					table_remove(list, i)
				else
					i = i + 1
				end
			end
		end
	end
	
	-- Loop through each of the events.
	for event, t in pairs(eventSearchMap) do
		-- Remove invalid global strings.
		local num = #t
		for i = num, 1, -1 do
			if not _G[t[i]] then
				table_remove(t, i)
			end
		end
	end
	
	CreateEventSearchMap = nil
end

local function ResortEventSearchMap()
	for event, t in pairs(eventSearchMap) do
		-- Sort the global strings from most to least specific.
		table_sort(t, GlobalStringCompareFunc)
	end
	
	ResortEventSearchMap = nil
end

local damageTypeToEnglish = {
	[SPELL_SCHOOL0_CAP] = DAMAGETYPE_PHYSICAL,
	[SPELL_SCHOOL1_CAP] = DAMAGETYPE_HOLY,
	[SPELL_SCHOOL2_CAP] = DAMAGETYPE_FIRE,
	[SPELL_SCHOOL3_CAP] = DAMAGETYPE_NATURE,
	[SPELL_SCHOOL4_CAP] = DAMAGETYPE_FROST,
	[SPELL_SCHOOL5_CAP] = DAMAGETYPE_SHADOW,
	[SPELL_SCHOOL6_CAP] = DAMAGETYPE_ARCANE,
	[DAMAGETYPE_PHYSICAL] = DAMAGETYPE_PHYSICAL,
	[DAMAGETYPE_HOLY] = DAMAGETYPE_HOLY,
	[DAMAGETYPE_FIRE] = DAMAGETYPE_FIRE,
	[DAMAGETYPE_NATURE] = DAMAGETYPE_NATURE,
	[DAMAGETYPE_FROST] = DAMAGETYPE_FROST,
	[DAMAGETYPE_SHADOW] = DAMAGETYPE_SHADOW,
	[DAMAGETYPE_ARCANE] = DAMAGETYPE_ARCANE,
}

local attributeToEnglish = {
	[MANA] = ATTRIBUTE_MANA,
	[ENERGY] = ATTRIBUTE_ENERGY,
	[RAGE] = ATTRIBUTE_RAGE,
	[FOCUS] = ATTRIBUTE_FOCUS,
	[HEALTH] = ATTRIBUTE_HEALTH,
	[HAPPINESS_POINTS] = ATTRIBUTE_HAPPINESS,
	[ATTRIBUTE_MANA] = ATTRIBUTE_MANA,
	[ATTRIBUTE_ENERGY] = ATTRIBUTE_ENERGY,
	[ATTRIBUTE_RAGE] = ATTRIBUTE_RAGE,
	[ATTRIBUTE_FOCUS] = ATTRIBUTE_FOCUS,
	[ATTRIBUTE_HEALTH] = ATTRIBUTE_HEALTH,
	[ATTRIBUTE_HAPPINESS] = ATTRIBUTE_HAPPINESS,
}

local GlobalStringFuncs = {}
local PopulateFuncs = {}
local ValidityFuncs = {}

GlobalStringFuncs[EVENTTYPE_AURA] = function()
	-- Aura captureMap = { recipient, abilityName, applications, isBuff }
	globalStringInfo["AURAADDEDOTHERHELPFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {1, 2, false, true}}
	globalStringInfo["AURAADDEDSELFHELPFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {"player", 1, false, true}}
	globalStringInfo["AURAAPPLICATIONADDEDOTHERHELPFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {1, 2, 3, true}}
	globalStringInfo["AURAAPPLICATIONADDEDSELFHELPFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {"player", 1, 2, true}}
	globalStringInfo["AURAADDEDOTHERHARMFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {1, 2, false, false}}
	globalStringInfo["AURAADDEDSELFHARMFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {"player", 1, false, false}}
	globalStringInfo["AURAAPPLICATIONADDEDOTHERHARMFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {1, 2, 3, false}}
	globalStringInfo["AURAAPPLICATIONADDEDSELFHARMFUL"] = {eventType = EVENTTYPE_AURA, captureMap = {"player", 1, 2, false}}
end

PopulateFuncs[EVENTTYPE_AURA] = function(captureMap, capturedData)
	-- Aura captureMap = { recipient, abilityName, applications, isBuff }
	parserEvent.eventType = EVENTTYPE_AURA
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local recipientName = capturedData[captureMap[1]] or captureMap[1]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[2]]
	parserEvent.applications = tonumber(capturedData[captureMap[3]]) or 1
	parserEvent.isBuff = captureMap[4]
end

ValidityFuncs[EVENTTYPE_AURA] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local applications = captureMap[3]
	local isBuff = captureMap[4]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.applications ~= nil then
		if filter.applications then
			if not applications then
				return false
			end
		else
			if applications then
				return false
			end
		end
	end
	if filter.applications_not ~= nil then
		if filter.applications_not then
			if applications then
				return false
			end
		else
			if not applications then
				return false
			end
		end
	end
	
	if filter.isBuff ~= nil then
		if filter.isBuff then
			if not isBuff then
				return false
			end
		else
			if isBuff then
				return false
			end
		end
	end
	if filter.isBuff_not ~= nil then
		if filter.isBuff_not then
			if isBuff then
				return false
			end
		else
			if not isBuff then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_CAST] = function()
	-- Cast captureMap = { source, recipient, abilityName, isBegin, isPerform }
	globalStringInfo["OPEN_LOCK_OTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {1, 3, 2, false, true}}
	globalStringInfo["OPEN_LOCK_SELF"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", 2, 1, false, true}}
	globalStringInfo["SIMPLECASTOTHEROTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {1, 3, 2, false, false}}
	globalStringInfo["SIMPLECASTOTHERSELF"] = {eventType = EVENTTYPE_CAST, captureMap = {1, "player", 2, false, false}}
	globalStringInfo["SIMPLECASTSELFOTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", 2, 1, false, false}}
	globalStringInfo["SIMPLECASTSELFSELF"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", "player", 1, false, false}}
	globalStringInfo["SIMPLEPERFORMOTHEROTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {1, 3, 2, false, true}}
	globalStringInfo["SIMPLEPERFORMOTHERSELF"] = {eventType = EVENTTYPE_CAST, captureMap = {1, "player", 2, false, true}}
	globalStringInfo["SIMPLEPERFORMSELFOTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", 2, 1, false, true}}
	globalStringInfo["SIMPLEPERFORMSELFSELF"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", "player", 1, false, true}}
	globalStringInfo["SPELLCASTOTHERSTART"] = {eventType = EVENTTYPE_CAST, captureMap = {1, false, 2, true, false}}
	globalStringInfo["SPELLCASTSELFSTART"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", false, 1, true, false}}
	globalStringInfo["SPELLPERFORMOTHERSTART"] = {eventType = EVENTTYPE_CAST, captureMap = {1, false, 2, true, true}}
	globalStringInfo["SPELLPERFORMSELFSTART"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", false, 1, true, true}}
	globalStringInfo["SPELLTERSEPERFORM_OTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {1, false, 2, false, true}}
	globalStringInfo["SPELLTERSEPERFORM_SELF"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", false, 1, false, true}}
	globalStringInfo["SPELLTERSE_OTHER"] = {eventType = EVENTTYPE_CAST, captureMap = {1, false, 2, false, false}}
	globalStringInfo["SPELLTERSE_SELF"] = {eventType = EVENTTYPE_CAST, captureMap = {"player", false, 1, false, false}}
end

PopulateFuncs[EVENTTYPE_CAST] = function(captureMap, capturedData)
	parserEvent.eventType = EVENTTYPE_CAST
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.isBegin = captureMap[4]
	parserEvent.isPerform = captureMap[5]
end

ValidityFuncs[EVENTTYPE_CAST] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local abilityName = captureMap[3]
	local isBegin = captureMap[4]
	local isPerform = captureMap[5]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if filter.abilityName_not then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	
	if filter.isBegin ~= nil then
		if filter.isBegin then
			if not isBegin then
				return false
			end
		else
			if isBegin then
				return false
			end
		end
	end
	if filter.isBegin_not ~= nil then
		if filter.isBegin_not then
			if isBegin then
				return false
			end
		else
			if not isBegin then
				return false
			end
		end
	end
	
	if filter.isPerform ~= nil then
		if filter.isPerform then
			if not isPerform then
				return false
			end
		else
			if isPerform then
				return false
			end
		end
	end
	if filter.isPerform_not ~= nil then
		if filter.isPerform_not then
			if isPerform then
				return false
			end
		else
			if not isPerform then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_CREATE] = function()
	-- Create captureMap = { source, item, amount, isLink, isCreated }
	globalStringInfo["LOOT_ITEM"] = {eventType = EVENTTYPE_CREATE, captureMap = {1, 2, false, true, false}}
	globalStringInfo["LOOT_ITEM_MULTIPLE"] = {eventType = EVENTTYPE_CREATE, captureMap = {1, 2, 3, true, false}}
	globalStringInfo["LOOT_ITEM_SELF"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, false, true, false}}
	globalStringInfo["LOOT_ITEM_SELF_MULTIPLE"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, 2, true, false}}
	globalStringInfo["LOOT_ITEM_CREATED_SELF"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, false, true, true}}
	globalStringInfo["LOOT_ITEM_CREATED_SELF_MULTIPLE"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, 2, true, true}}
	globalStringInfo["LOOT_ITEM_PUSHED_SELF"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, false, true, true}}
	globalStringInfo["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, 2, true, true}}
--	globalStringInfo["TRADESKILL_LOG_FIRSTPERSON"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", 1, false}}
--	globalStringInfo["TRADESKILL_LOG_THIRDPERSON"] = {eventType = EVENTTYPE_CREATE, captureMap = {1, 2, false}}
	
	globalStringInfo["YOU_LOOT_MONEY"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", false, 1, false, false}}
	globalStringInfo["LOOT_MONEY_SPLIT"] = {eventType = EVENTTYPE_CREATE, captureMap = {"player", false, 1, false, false}}
	globalStringInfo["LOOT_MONEY"] = {eventType = EVENTTYPE_CREATE, captureMap = {1, false, 2, false, false}}
end

local GOLD_MATCH = "(%d+) " .. _G.GOLD
local SILVER_MATCH = "(%d+) " .. _G.SILVER
local COPPER_MATCH = "(%d+) " .. _G.COPPER
PopulateFuncs[EVENTTYPE_CREATE] = function(captureMap, capturedData)
	-- Create captureMap = { source, item, amount, isLink, isCreated }
	parserEvent.eventType = EVENTTYPE_CREATE
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	if captureMap[2] then
		-- item
		parserEvent.amount = captureMap[3] and capturedData[captureMap[3]] or 1
		local name = capturedData[captureMap[2]]
		local itemName, itemLink, itemRarity = GetItemInfo(name)
		if itemName then
			parserEvent.itemLink = itemLink
			parserEvent.itemName = itemName
			parserEvent.itemString = itemLink:match("^|c%x%x%x%x%x%x%x%x|H(item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+)|h%[")
			parserEvent.itemRarity = itemRarity
		else
			parserEvent.itemLink = false
			parserEvent.itemName = name
			parserEvent.itemString = false
			parserEvent.itemRarity = 1
		end
	else
		-- money
		local moneys = capturedData[captureMap[3]]
		local gold = moneys:match(GOLD_MATCH) or 0
		local silver = moneys:match(SILVER_MATCH) or 0
		local copper = moneys:match(COPPER_MATCH) or 0
		parserEvent.amount = gold * 10000 + silver * 100 + copper
		parserEvent.itemLink = false
		parserEvent.itemName = false
		parserEvent.itemString = false
		parserEvent.itemRarity = 1
	end
	parserEvent.isCreated = captureMap[5]
end

ValidityFuncs[EVENTTYPE_CREATE] = function(captureMap, filter)
	local sourceName = captureMap[1]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_DAMAGE] = function()
	-- Damage captureMap = { damageType, source, recipient, amount, abilityName, isCrit, isDoT, isSplit }
	globalStringInfo["COMBATHITCRITOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, "player", 2, false, true, false, false}}
	globalStringInfo["COMBATHITCRITSCHOOLOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, 1, "player", 2, false, true, false, false}}
	globalStringInfo["COMBATHITCRITSCHOOLOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, 1, 2, 3, false, true, false, false}}
	globalStringInfo["COMBATHITCRITSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", 1, 2, false, true, false, false}}
	globalStringInfo["COMBATHITCRITOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, 2, 3, false, true, false, false}}
	globalStringInfo["COMBATHITOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, 2, 3, false, false, false, false}}
	globalStringInfo["COMBATHITOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, "player", 2, false, false, false, false}}
	globalStringInfo["COMBATHITSCHOOLOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, 1, "player", 2, false, false, false, false}}
	globalStringInfo["COMBATHITSCHOOLOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, 1, 2, 3, false, false, false, false}}
	globalStringInfo["COMBATHITSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", 1, 2, false, false, false, false}}
	globalStringInfo["DAMAGESHIELDOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, 1, 4, 2, SHIELDSLOT, false, false, false}}
	globalStringInfo["DAMAGESHIELDOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, 1, "player", 2, SHIELDSLOT, false, false, false}}
	globalStringInfo["DAMAGESHIELDSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {2, "player", 3, 1, SHIELDSLOT, false, false, false}}
	globalStringInfo["PERIODICAURADAMAGEOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, 4, 1, 2, 5, false, true, false}}
	globalStringInfo["PERIODICAURADAMAGEOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {2, 3, "player", 1, 4, false, true, false}}
	globalStringInfo["PERIODICAURADAMAGESELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, "player", 1, 2, 4, false, true, false}}
	globalStringInfo["PERIODICAURADAMAGESELFSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {2, "player", "player", 1, 3, false, true, false}}
	globalStringInfo["SPELLLOGCRITOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, 3, 4, 2, true, false, false}}
	globalStringInfo["SPELLLOGCRITOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, "player", 3, 2, true, false, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {5, 1, 3, 4, 2, true, false, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, 1, "player", 3, 2, true, false, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, "player", 2, 3, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLSELFSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, "player", "player", 2, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", 2, 3, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITSELFSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", "player", 2, 1, true, false, false}}
	globalStringInfo["SPELLLOGOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, 3, 4, 2, false, false, false}}
	globalStringInfo["SPELLLOGOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, "player", 3, 2, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {5, 1, 3, 4, 2, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, 1, "player", 3, 2, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, "player", 2, 3, 1, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLSELFSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, "player", "player", 2, 1, false, false, false}}
	globalStringInfo["SPELLLOGSELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", 2, 3, 1, false, false, false}}
	globalStringInfo["SPELLLOGSELFSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", "player", 2, 1, false, false, false}}
	globalStringInfo["PERIODICAURADAMAGEOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, false, 1, 2, 4, false, true, false}}
	globalStringInfo["PERIODICAURADAMAGESELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {2, false, "player", 1, 3, false, true, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, false, 2, 3, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITSCHOOLSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, false, "player", 2, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, false, 2, 3, 1, true, false, false}}
	globalStringInfo["SPELLLOGCRITSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, false, "player", 2, 1, true, false, false}}
	globalStringInfo["SPELLLOGOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, false, 2, 3, 1, false, false, false}}
	globalStringInfo["SPELLLOGSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, false, "player", 2, 1, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {4, false, 2, 3, 1, false, false, false}}
	globalStringInfo["SPELLLOGSCHOOLSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {3, false, "player", 2, 1, false, false, false}}
	globalStringInfo["SPELLSPLITDAMAGEOTHEROTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, 3, 4, 2, false, false, true}}
	globalStringInfo["SPELLSPLITDAMAGEOTHERSELF"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, 1, "player", 3, 2, false, false, true}}
	globalStringInfo["SPELLSPLITDAMAGESELFOTHER"] = {eventType = EVENTTYPE_DAMAGE, captureMap = {DAMAGETYPE_PHYSICAL, "player", 2, 3, 1, false, false, true}}
end

PopulateFuncs[EVENTTYPE_DAMAGE] = function(captureMap, capturedData)
	-- Attempt to get the damage type and convert it to a number if there is one.
	local damageType = fixDamageType[capturedData[captureMap[1]] or captureMap[1]]

	parserEvent.eventType = EVENTTYPE_DAMAGE
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	parserEvent.damageTypeLocal = damageType
	parserEvent.damageType = damageTypeToEnglish[damageType] or DAMAGETYPE_UNKNOWN
	local sourceName = capturedData[captureMap[2]] or captureMap[2]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[3]] or captureMap[3]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.amount = capturedData[captureMap[4]]+0 -- coerce to number
	parserEvent.abilityName = capturedData[captureMap[5]] or captureMap[5]
	parserEvent.isCrit = captureMap[6]
	parserEvent.isDoT = captureMap[7]
	parserEvent.isSplit = captureMap[8]
end

ValidityFuncs[EVENTTYPE_DAMAGE] = function(captureMap, filter)
	local damageType = captureMap[1]
	if type(damageType) == "string" then
		damageType = damageTypeToEnglish[damageType] or DAMAGETYPE_UNKNOWN
	end
	damageType = damageType or false
	local sourceName = captureMap[2]
	local recipientName = captureMap[3]
	local abilityName = captureMap[5]
	local isCrit = captureMap[6]
	local isDoT = captureMap[7]
	local isSplit = captureMap[8]
	
	if filter.damageType ~= nil and damageType ~= filter.damageType and type(damageType) == "string" then
		return false
	end
	if filter.damageType_not ~= nil and damageType == filter.damageType_not and type(damageType) == "string" then
		return false
	end

	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not and not filter.abilityName_not and not abilityName then
		return false
	end
	
	if filter.isCrit ~= nil then
		if filter.isCrit then
			if not isCrit then
				return false
			end
		else
			if isCrit then
				return false
			end
		end
	end
	if filter.isCrit_not ~= nil then
		if filter.isCrit_not then
			if isCrit then
				return false
			end
		else
			if not isCrit then
				return false
			end
		end
	end
	
	if filter.isDoT ~= nil then
		if filter.isDoT then
			if not isDoT then
				return false
			end
		else
			if isDoT then
				return false
			end
		end
	end
	if filter.isDoT_not ~= nil then
		if filter.isDoT_not then
			if isDoT then
				return false
			end
		else
			if not isDoT then
				return false
			end
		end
	end
	
	if filter.isSplit ~= nil then
		if filter.isSplit then
			if not isSplit then
				return false
			end
		else
			if isSplit then
				return false
			end
		end
	end
	if filter.isSplit_not ~= nil then
		if filter.isSplit_not then
			if isSplit then
				return false
			end
		else
			if not isSplit then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_DEATH] = function()
	-- Death captureMap = { source, recipient, abilityName, isItem }
	globalStringInfo["SELFKILLOTHER"] = {eventType = EVENTTYPE_DEATH, captureMap = {"player", 1, false, false}}
	globalStringInfo["PARTYKILLOTHER"] = {eventType = EVENTTYPE_DEATH, captureMap = {2, 1, false, false}}
	globalStringInfo["UNITDESTROYEDOTHER"] = {eventType = EVENTTYPE_DEATH, captureMap = {false, 1, false, true}}
	globalStringInfo["UNITDIESOTHER"] = {eventType = EVENTTYPE_DEATH, captureMap = {false, 1, false, false}}
	globalStringInfo["UNITDIESSELF"] = {eventType = EVENTTYPE_DEATH, captureMap = {false, "player", false, false}}
	globalStringInfo["INSTAKILLOTHER"] = {eventType = EVENTTYPE_DEATH, captureMap = {false, 1, 2, false}}
	globalStringInfo["INSTAKILLSELF"] = {eventType = EVENTTYPE_DEATH, captureMap = {false, "player", 1, false}}
end

PopulateFuncs[EVENTTYPE_DEATH] = function(captureMap, capturedData)
	-- Get the name of the slain enemy.
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	local enemyName = capturedData[captureMap[2]] or captureMap[2]
	
	parserEvent.eventType = EVENTTYPE_DEATH
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	if sourceName == "player" then
		parserEvent.sourceID = "player"
		parserEvent.sourceName = playerName
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	if enemyName == "player" then
		parserEvent.recipientID = "player"
		parserEvent.recipientName = playerName
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = enemyName
		parserEvent.recipientID = toUnitID[enemyName] or false
		parserEvent.recipientPvP = not not recentPvP[enemyName]
	end
	
	parserEvent.abilityName = capturedData[captureMap[3]] or captureMap[3]
	parserEvent.isItem = captureMap[4]
end

ValidityFuncs[EVENTTYPE_DEATH] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local abilityName = captureMap[3]
	local isItem = captureMap[4]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if not filter.abilityName then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if not filter.abilityName_not then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	
	if filter.isItem ~= nil then
		if filter.isItem then
			if not isItem then
				return false
			end
		else
			if isItem then
				return false
			end
		end
	end
	if filter.isItem_not ~= nil then
		if filter.isItem_not then
			if isItem then
				return false
			end
		else
			if not isItem then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_DISPEL] = function()
	-- Dispel captureMap = { recipient, recipientAbilityName, source, sourceAbilityName, isFailed }
	globalStringInfo["AURADISPELOTHER"] = {eventType = EVENTTYPE_DISPEL, captureMap = {1, 2, false, false, false}}
	globalStringInfo["AURADISPELOTHER2"] = {eventType = EVENTTYPE_DISPEL, captureMap = {1, 2, 3, false, false}}
	globalStringInfo["AURADISPELOTHER3"] = {eventType = EVENTTYPE_DISPEL, captureMap = {1, 2, 3, 4, false}}
	globalStringInfo["AURADISPELSELF"] = {eventType = EVENTTYPE_DISPEL, captureMap = {"player", 1, false, false, false}}
	globalStringInfo["AURADISPELSELF2"] = {eventType = EVENTTYPE_DISPEL, captureMap = {"player", 1, 2, false, false}}
	globalStringInfo["AURADISPELSELF3"] = {eventType = EVENTTYPE_DISPEL, captureMap = {"player", 1, 2, 3, false}}
	globalStringInfo["DISPELFAILEDOTHEROTHER"] = {eventType = EVENTTYPE_DISPEL, captureMap = {2, 3, 1, false, true}}
	globalStringInfo["DISPELFAILEDOTHERSELF"] = {eventType = EVENTTYPE_DISPEL, captureMap = {"player", 2, 1, false, true}}
	globalStringInfo["DISPELFAILEDSELFOTHER"] = {eventType = EVENTTYPE_DISPEL, captureMap = {1, 2, "player", false, true}}
	globalStringInfo["DISPELFAILEDSELFSELF"] = {eventType = EVENTTYPE_DISPEL, captureMap = {"player", 1, "player", false, true}}
end

PopulateFuncs[EVENTTYPE_DISPEL] = function(captureMap, capturedData)
	-- Dispel captureMap = { recipient, recipientAbilityName, source, sourceAbilityName, isFailed }
	parserEvent.eventType = EVENTTYPE_DISPEL
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[3]] or captureMap[3]
	if sourceName == "player" or sourceName == playerName then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[1]] or captureMap[1]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.recipientAbilityName = capturedData[captureMap[2]]
	parserEvent.sourceAbilityName = capturedData[captureMap[4]] or captureMap[4]
	parserEvent.isFailed = captureMap[5]
end

ValidityFuncs[EVENTTYPE_DISPEL] = function(captureMap, filter)
	local sourceName = captureMap[3]
	local recipientName = captureMap[1]
	local sourceAbilityName = captureMap[4]
	local recipientAbilityName = captureMap[2]
	local isFailed = captureMap[5]
	
	--[[
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	]]

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.sourceAbilityName ~= nil then
		if filter.sourceAbilityName then
			if not sourceAbilityName then
				return false
			end
		else
			if sourceAbilityName then
				return false
			end
		end
	end
	if filter.sourceAbilityName_not ~= nil then
		if filter.sourceAbilityName_not then
			if sourceAbilityName then
				return false
			end
		else
			if not sourceAbilityName then
				return false
			end
		end
	end
	
	if filter.recipientAbilityName ~= nil then
		if filter.recipientAbilityName then
			if not recipientAbilityName then
				return false
			end
		else
			if recipientAbilityName then
				return false
			end
		end
	end
	if filter.recipientAbilityName_not ~= nil then
		if filter.recipientAbilityName_not then
			if recipientAbilityName then
				return false
			end
		else
			if not recipientAbilityName then
				return false
			end
		end
	end
	
	if filter.isFailed ~= nil then
		if filter.isFailed then
			if not isFailed then
				return false
			end
		else
			if isFailed then
				return false
			end
		end
	end
	if filter.isFailed_not ~= nil then
		if filter.isFailed_not then
			if isFailed then
				return false
			end
		else
			if not isFailed then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_DRAIN] = function()
	-- Drain captureMap = { source, recipient, abilityName, amount, attribute }
	globalStringInfo["SPELLPOWERDRAINOTHEROTHER"] = {eventType = EVENTTYPE_DRAIN, captureMap = {1, 5, 2, 3, 4}}
	globalStringInfo["SPELLPOWERDRAINOTHERSELF"] = {eventType = EVENTTYPE_DRAIN, captureMap = {1, "player", 2, 3, 4}}
	globalStringInfo["SPELLPOWERDRAINSELFOTHER"] = {eventType = EVENTTYPE_DRAIN, captureMap = {"player", 4, 1, 2, 3}}
	globalStringInfo["SPELLPOWERDRAINSELFSELF"] = {eventType = EVENTTYPE_DRAIN, captureMap = {"player", "player", 1, 2, 3}}
	globalStringInfo["SPELLPOWERDRAINOTHER"] = {eventType = EVENTTYPE_DRAIN, captureMap = {false, 4, 1, 2, 3}}
	globalStringInfo["SPELLPOWERDRAINSELF"] = {eventType = EVENTTYPE_DRAIN, captureMap = {false, "player", 1, 2, 3}}
end

PopulateFuncs[EVENTTYPE_DRAIN] = function(captureMap, capturedData)
	-- Drain captureMap = { source, recipient, abilityName, amount, attribute }
	parserEvent.eventType = EVENTTYPE_DRAIN
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.amount = capturedData[captureMap[4]]+0 -- coerce to number
	parserEvent.attributeLocal = capturedData[captureMap[5]]
	parserEvent.attribute = attributeToEnglish[parserEvent.attributeLocal] or ATTRIBUTE_UNKNOWN
end

ValidityFuncs[EVENTTYPE_DRAIN] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local abilityName = captureMap[3]
	local amount = captureMap[4]
	local attribute = captureMap[5]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if filter.abilityName_not then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	
	if filter.amount ~= nil then
		if filter.amount then
			if not amount then
				return false
			end
		else
			if amount then
				return false
			end
		end
	end
	if filter.amount_not ~= nil then
		if filter.amount_not then
			if amount then
				return false
			end
		else
			if not amount then
				return false
			end
		end
	end
	
	if filter.attribute ~= nil then
		if filter.attribute then
			if not attribute then
				return false
			end
		else
			if attribute then
				return false
			end
		end
	end
	if filter.attribute_not ~= nil then
		if filter.attribute_not then
			if attribute then
				return false
			end
		else
			if not attribute then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_DURABILITY] = function()
	-- Durability captureMap = { source, recipient, abilityName, item }
	globalStringInfo["SPELLDURABILITYDAMAGEALLOTHEROTHER"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {1, 3, 2, false}}
	globalStringInfo["SPELLDURABILITYDAMAGEALLOTHERSELF"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {1, "player", 2, false}}
	globalStringInfo["SPELLDURABILITYDAMAGEALLSELFOTHER"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {"player", 2, 1, false}}
	globalStringInfo["SPELLDURABILITYDAMAGEOTHEROTHER"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {1, 3, 2, 4}}
	globalStringInfo["SPELLDURABILITYDAMAGEOTHERSELF"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {1, "player", 2, 3}}
	globalStringInfo["SPELLDURABILITYDAMAGESELFOTHER"] = {eventType = EVENTTYPE_DURABILITY, captureMap = {"player", 2, 1, 3}}
end

PopulateFuncs[EVENTTYPE_DURABILITY] = function(captureMap, capturedData)
	-- Durability captureMap = { source, recipient, abilityName, item }
	parserEvent.eventType = EVENTTYPE_DURABILITY
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.item = capturedData[captureMap[4]] or captureMap[4]
end

ValidityFuncs[EVENTTYPE_DURABILITY] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local abilityName = captureMap[3]
	local item = captureMap[4]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if filter.abilityName_not then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	
	if filter.item ~= nil then
		if filter.item then
			if not item then
				return false
			end
		else
			if item then
				return false
			end
		end
	end
	if filter.item_not ~= nil then
		if filter.item_not then
			if item then
				return false
			end
		else
			if not item then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_ENCHANT] = function()
	-- Enchant captureMap = { source, recipient, abilityName, item }
	globalStringInfo["ITEMENCHANTMENTADDOTHEROTHER"] = {eventType = EVENTTYPE_ENCHANT, captureMap = {1, 3, 2, 4}}
	globalStringInfo["ITEMENCHANTMENTADDOTHERSELF"] = {eventType = EVENTTYPE_ENCHANT, captureMap = {1, "player", 2, 3}}
	globalStringInfo["ITEMENCHANTMENTADDSELFOTHER"] = {eventType = EVENTTYPE_ENCHANT, captureMap = {"player", 2, 1, 3}}
	globalStringInfo["ITEMENCHANTMENTADDSELFSELF"] = {eventType = EVENTTYPE_ENCHANT, captureMap = {"player", "player", 1, 2}}
end

PopulateFuncs[EVENTTYPE_ENCHANT] = function(captureMap, capturedData)
	-- Enchant captureMap = { source, recipient, abilityName, item }
	parserEvent.eventType = EVENTTYPE_ENCHANT
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.item = capturedData[captureMap[4]]
end

ValidityFuncs[EVENTTYPE_ENCHANT] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_ENVIRONMENTAL] = function()
	-- Environmental captureMap = { hazardType, damageType, recipient, amount }
	globalStringInfo["VSENVIRONMENTALDAMAGE_DROWNING_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_DROWNING, DAMAGETYPE_NATURE, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_DROWNING_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_DROWNING, DAMAGETYPE_NATURE, 1, 2}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FALLING_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_FALLING, DAMAGETYPE_PHYSICAL, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FALLING_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_FALLING, DAMAGETYPE_PHYSICAL, 1, 2}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FATIGUE_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_FATIGUE, DAMAGETYPE_PHYSICAL, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FATIGUE_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_FATIGUE, DAMAGETYPE_PHYSICAL, 1, 2}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FIRE_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_FIRE, DAMAGETYPE_FIRE, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_FIRE_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_SLIME, DAMAGETYPE_NATURE, 1, 2}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_LAVA_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_LAVA, DAMAGETYPE_FIRE, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_LAVA_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_SLIME, DAMAGETYPE_NATURE, 1, 2}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_SLIME_SELF"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_SLIME, DAMAGETYPE_NATURE, "player", 1}}
	globalStringInfo["VSENVIRONMENTALDAMAGE_SLIME_OTHER"] = {eventType = EVENTTYPE_ENVIRONMENTAL, captureMap = {HAZARDTYPE_SLIME, DAMAGETYPE_NATURE, 1, 2}}
end

PopulateFuncs[EVENTTYPE_ENVIRONMENTAL] = function(captureMap, capturedData)
	parserEvent.eventType = EVENTTYPE_ENVIRONMENTAL
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	parserEvent.hazardType = captureMap[1]
	parserEvent.hazardTypeLocal = hazardTypeToLocal[parserEvent.hazardType]
	parserEvent.damageType = captureMap[2]
	parserEvent.damageTypeLocal = damageTypeToLocal[parserEvent.damageType]
	parserEvent.amount = capturedData[captureMap[4]]+0 -- coerce to number
	
	local recipientName = capturedData[captureMap[3]] or captureMap[3]
	local recipientID
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		recipientID = "player"
		parserEvent.recipientID = recipientID
	else
		parserEvent.recipientName = recipientName
		recipientID = toUnitID[recipientName] or false
		parserEvent.recipientID = recipientID
	end
end

ValidityFuncs[EVENTTYPE_ENVIRONMENTAL] = function(captureMap, filter)
	local hazardType = captureMap[1]
	local damageType = captureMap[2]
	if filter.hazardType ~= nil and filter.hazardType ~= hazardType then
		return false
	end
	if filter.hazardType_not ~= nil and filter.hazardType_not == hazardType then
		return false
	end
	if filter.damageType ~= nil and filter.damageType ~= damageType then
		return false
	end
	if filter.damageType_not ~= nil and filter.damageType_not == damageType then
		return false
	end
	return true
end

GlobalStringFuncs[EVENTTYPE_EXPERIENCE] = function()
	-- Experience captureMap = { amount, source, bonusAmount, bonusType, penaltyAmount, penaltyType, amountRaidPenalty, amountGroupBonus, recipient }
	globalStringInfo["COMBATLOG_XPGAIN"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, false, false, false, false, false, false, false, 1}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION1"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION1_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, false, 5, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION1_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, 5, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION2"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION2_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, false, 5, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION2_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, 3, 4, false, false, 5, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION4"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION4_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, false, 5, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION4_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, 5, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION5"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION5_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, false, 5, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_EXHAUSTION5_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, 3, 4, 5, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, false, false, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, false, false, false, 3, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {2, 1, false, false, false, false, 3, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {1, false, false, false, false, false, false, false, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {1, false, false, false, false, false, false, 2, "player"}}
	globalStringInfo["COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID"] = {eventType = EVENTTYPE_EXPERIENCE, captureMap = {1, false, false, false, false, false, 2, false, "player"}}
end

PopulateFuncs[EVENTTYPE_EXPERIENCE] = function(captureMap, capturedData)
	-- Experience captureMap = { amount, source, bonusAmount, bonusType, penaltyAmount, penaltyType, amountRaidPenalty, amountGroupBonus, recipient }
	parserEvent.eventType = EVENTTYPE_EXPERIENCE
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local sourceName = capturedData[captureMap[2]] or captureMap[2]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[9]] or captureMap[9]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	
	parserEvent.amount = capturedData[captureMap[1]]+0 -- coerce to number
	parserEvent.bonusAmount = tonumber(capturedData[captureMap[3]] or captureMap[3]) or 0
	parserEvent.bonusType = capturedData[captureMap[4]] or captureMap[4]
	parserEvent.penaltyAmount = tonumber(capturedData[captureMap[5]] or captureMap[5]) or 0
	parserEvent.penaltyType = capturedData[captureMap[6]] or captureMap[6]
	parserEvent.amountRaidPenalty = tonumber(capturedData[captureMap[7]] or captureMap[7]) or 0
	parserEvent.amountGroupBonus = tonumber(capturedData[captureMap[8]] or captureMap[8]) or 0
end

ValidityFuncs[EVENTTYPE_EXPERIENCE] = function(captureMap, filter)
	local sourceName = captureMap[2]
	local recipientName = captureMap[9]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_EXTRAATTACK] = function()
	-- Extra Attack captureMap = { recipient, abilityName, amount }
	globalStringInfo["SPELLEXTRAATTACKSSELF"] = {eventType = EVENTTYPE_EXTRAATTACK, captureMap = {"player", 2, 1}}
	globalStringInfo["SPELLEXTRAATTACKSSELF_SINGULAR"] = {eventType = EVENTTYPE_EXTRAATTACK, captureMap = {"player", 2, 1}}
	globalStringInfo["SPELLEXTRAATTACKSOTHER"] = {eventType = EVENTTYPE_EXTRAATTACK, captureMap = {1, 3, 2}}
	globalStringInfo["SPELLEXTRAATTACKSOTHER_SINGULAR"] = {eventType = EVENTTYPE_EXTRAATTACK, captureMap = {1, 3, 2}}
end

PopulateFuncs[EVENTTYPE_EXTRAATTACK] = function(captureMap, capturedData)
	-- Extra Attack captureMap = { recipient, abilityName, amount }
	parserEvent.eventType = EVENTTYPE_EXTRAATTACK
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local recipientName = capturedData[captureMap[1]] or captureMap[1]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[2]]
	parserEvent.amount = tonumber(capturedData[captureMap[3]]) or 1
end

ValidityFuncs[EVENTTYPE_EXTRAATTACK] = function(captureMap, filter)
	local recipientName = captureMap[1]
	local abilityName = captureMap[2]
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if filter.abilityName_not then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_FADE] = function()
	-- Fade captureMap = { recipient, abilityName }
	globalStringInfo["AURAREMOVEDOTHER"] = {eventType = EVENTTYPE_FADE, captureMap = {2, 1}}
	globalStringInfo["AURAREMOVEDSELF"] = {eventType = EVENTTYPE_FADE, captureMap = {"player", 1}}
end

PopulateFuncs[EVENTTYPE_FADE] = function(captureMap, capturedData)
	-- Fade captureMap = { recipient, abilityName }
	parserEvent.eventType = EVENTTYPE_FADE
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local recipientName = capturedData[captureMap[1]] or captureMap[1]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	
	parserEvent.abilityName = capturedData[captureMap[2]]
end

ValidityFuncs[EVENTTYPE_FADE] = function(captureMap, filter)
	local recipientName = captureMap[1]
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_FAIL] = function()
	-- Fail captureMap = { source, abilityName, reason }
	globalStringInfo["SPELLFAILCASTSELF"] = {eventType = EVENTTYPE_FAIL, captureMap = {"player", 1, 2}}
	globalStringInfo["SPELLFAILPERFORMSELF"] = {eventType = EVENTTYPE_FAIL, captureMap = {"player", 1, 2}}
end

PopulateFuncs[EVENTTYPE_FAIL] = function(captureMap, capturedData)
	-- Fail captureMap = { source, abilityName, reason }
	parserEvent.eventType = EVENTTYPE_FAIL
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	parserEvent.abilityName = capturedData[captureMap[2]]
	parserEvent.reason = capturedData[captureMap[3]]
end

ValidityFuncs[EVENTTYPE_FAIL] = function(captureMap, filter)
	local sourceName = captureMap[1]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_FEEDPET] = function()
	-- Feed Pet captureMap = { recipient, item }
	globalStringInfo["FEEDPET_LOG_FIRSTPERSON"] = {eventType = EVENTTYPE_FEEDPET, captureMap = {"player", 1}}
	globalStringInfo["FEEDPET_LOG_THIRDPERSON"] = {eventType = EVENTTYPE_FEEDPET, captureMap = {1, 2}}
end

PopulateFuncs[EVENTTYPE_FEEDPET] = function(captureMap, capturedData)
	-- Feed Pet captureMap = { recipient, item }
	parserEvent.eventType = EVENTTYPE_FEEDPET
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local recipientName = capturedData[captureMap[1]] or captureMap[1]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.item = capturedData[captureMap[2]]
end

ValidityFuncs[EVENTTYPE_FEEDPET] = function(captureMap, filter)
	local recipientName = captureMap[1]
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_GAIN] = function()
	-- Fade captureMap = { source, recipient, abilityName, amount, attribute }
	globalStringInfo["POWERGAINOTHEROTHER"] = {eventType = EVENTTYPE_GAIN, captureMap = {4, 1, 5, 2, 3}}
	globalStringInfo["POWERGAINOTHERSELF"] = {eventType = EVENTTYPE_GAIN, captureMap = {3, "player", 4, 1, 2}}
	globalStringInfo["POWERGAINSELFOTHER"] = {eventType = EVENTTYPE_GAIN, captureMap = {"player", 1, 4, 2, 3}}
	globalStringInfo["POWERGAINSELFSELF"] = {eventType = EVENTTYPE_GAIN, captureMap = {"player", "player", 3, 1, 2}}
	globalStringInfo["POWERGAINOTHER"] = {eventType = EVENTTYPE_GAIN, captureMap = {false, 1, 4, 2, 3}}
	globalStringInfo["POWERGAINSELF"] = {eventType = EVENTTYPE_GAIN, captureMap = {false, "player", 3, 1, 2}}
end

PopulateFuncs[EVENTTYPE_GAIN] = function(captureMap, capturedData)
	-- Fade captureMap = { source, recipient, abilityName, amount, attribute }
	parserEvent.eventType = EVENTTYPE_GAIN
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.amount = capturedData[captureMap[4]]+0 -- coerce to number
	parserEvent.attributeLocal = capturedData[captureMap[5]]
	parserEvent.attribute = attributeToEnglish[parserEvent.attributeLocal] or ATTRIBUTE_UNKNOWN
end

ValidityFuncs[EVENTTYPE_GAIN] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_HEAL] = function()
	-- Heal captureMap = { source, recipient, amount, abilityName, isCrit, isHoT }
	globalStringInfo["HEALEDCRITOTHERSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {1, "player", 3, 2, true, false}}
	globalStringInfo["HEALEDCRITOTHEROTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {1, 3, 4, 2, true, false}}
	globalStringInfo["HEALEDCRITSELFOTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", 2, 3, 1, true, false}}
	globalStringInfo["HEALEDCRITSELFSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", "player", 2, 1, true, false}}
	globalStringInfo["HEALEDOTHERSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {1, "player", 3, 2, false, false}}
	globalStringInfo["HEALEDOTHEROTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {1, 3, 4, 2, false, false}}
	globalStringInfo["HEALEDSELFOTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", 2, 3, 1, false, false}}
	globalStringInfo["HEALEDSELFSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", "player", 2, 1, false, false}}
	globalStringInfo["PERIODICAURAHEALOTHEROTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {3, 1, 2, 4, false, true}}
	globalStringInfo["PERIODICAURAHEALOTHERSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {2, "player", 1, 3, false, true}}
	globalStringInfo["PERIODICAURAHEALSELFOTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", 1, 2, 3, false, true}}
	globalStringInfo["PERIODICAURAHEALSELFSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {"player", "player", 1, 2, false, true}}
	
	globalStringInfo["HEALEDCRITOTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {false, 2, 3, 1, true, false}}
	globalStringInfo["HEALEDCRITSELF"] = {eventType = EVENTTYPE_HEAL, captureMap = {false, "player", 2, 1, true, false}}
	globalStringInfo["HEALEDOTHER"] = {eventType = EVENTTYPE_HEAL, captureMap = {false, 2, 3, 1, false, false}}
end

PopulateFuncs[EVENTTYPE_HEAL] = function(captureMap, capturedData)
	parserEvent.eventType = EVENTTYPE_HEAL
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	local recipientID
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		recipientID = "player"
		parserEvent.recipientID = recipientID
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		recipientID = toUnitID[recipientName] or false
		parserEvent.recipientID = recipientID
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.amount = capturedData[captureMap[3]]+0 -- coerce to number
	parserEvent.abilityName = capturedData[captureMap[4]]
	parserEvent.isCrit = captureMap[5]
	parserEvent.isHoT = captureMap[6]

	-- Get the unit ID for the healed unit.

	-- Make sure it's a valid unit id.
	if recipientID then
		local healthMissing = UnitHealthMax(recipientID) - UnitHealth(recipientID)
		local overhealAmount = parserEvent.amount - healthMissing

		-- Check if any overhealing occured.
		if overhealAmount > 0 then
			parserEvent.overhealAmount = overhealAmount
			parserEvent.realAmount = parserEvent.amount - overhealAmount
		else
			parserEvent.overhealAmount = 0
			parserEvent.realAmount = parserEvent.amount
		end
	else
		parserEvent.overhealAmount = 0
		parserEvent.realAmount = parserEvent.amount
	end
end

ValidityFuncs[EVENTTYPE_HEAL] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local isCrit = captureMap[5]
	local isHoT = captureMap[6]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.isCrit ~= nil then
		if filter.isCrit then
			if not isCrit then
				return false
			end
		else
			if isCrit then
				return false
			end
		end
	end
	if filter.isCrit_not ~= nil then
		if filter.isCrit_not then
			if isCrit then
				return false
			end
		else
			if not isCrit then
				return false
			end
		end
	end
	
	if filter.isHoT ~= nil then
		if filter.isHoT then
			if not isHoT then
				return false
			end
		else
			if isHoT then
				return false
			end
		end
	end
	if filter.isHoT_not ~= nil then
		if filter.isHoT_not then
			if isHoT then
				return false
			end
		else
			if not isHoT then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_HONOR] = function()
	-- Honor captureMap = { amount, source, sourceRank } -- if amount == false then isDishonor = true.
	globalStringInfo["COMBATLOG_DISHONORGAIN"] = {eventType = EVENTTYPE_HONOR, captureMap = {false, 1, false}}
	globalStringInfo["COMBATLOG_HONORAWARD"] = {eventType = EVENTTYPE_HONOR, captureMap = {1, false, false}}
	globalStringInfo["COMBATLOG_HONORGAIN"] = {eventType = EVENTTYPE_HONOR, captureMap = {3, 1, 2}}
end

PopulateFuncs[EVENTTYPE_HONOR] = function(captureMap, capturedData)
	-- Honor captureMap = { amount, source, sourceRank } -- if amount == false then isDishonor = true.
	parserEvent.eventType = EVENTTYPE_HONOR
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	local sourceName = capturedData[captureMap[2]] or captureMap[2]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	
	parserEvent.amount = tonumber(capturedData[captureMap[1]] or captureMap[1]) or 0
	parserEvent.sourceRank = capturedData[captureMap[3]] or captureMap[3]
	parserEvent.isHonorable = captureMap[1] and true
end

ValidityFuncs[EVENTTYPE_HONOR] = function(captureMap, filter)
	local isHonorable = captureMap[1]
	local sourceName = captureMap[2]
	local sourceRank = captureMap[3]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end
	
	if filter.isHonorable ~= nil then
		if filter.isHonorable then
			if not isHonorable then
				return false
			end
		else
			if isHonorable then
				return false
			end
		end
	end
	if filter.isHonorable_not ~= nil then
		if filter.isHonorable_not then
			if isHonorable then
				return false
			end
		else
			if not isHonorable then
				return false
			end
		end
	end
	
	if filter.sourceRank ~= nil then
		if filter.sourceRank then
			if not sourceRank then
				return false
			end
		else
			if sourceRank then
				return false
			end
		end
	end
	if filter.sourceRank_not ~= nil then
		if filter.sourceRank_not then
			if sourceRank then
				return false
			end
		else
			if not sourceRank then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_INTERRUPT] = function()
	-- Interrupt captureMap = { source, recipient, abilityName }
	globalStringInfo["SPELLINTERRUPTOTHEROTHER"] = {eventType = EVENTTYPE_INTERRUPT, captureMap = {1, 2, 3}}
	globalStringInfo["SPELLINTERRUPTOTHERSELF"] = {eventType = EVENTTYPE_INTERRUPT, captureMap = {1, "player", 2}}
	globalStringInfo["SPELLINTERRUPTSELFOTHER"] = {eventType = EVENTTYPE_INTERRUPT, captureMap = {"player", 1, 2}}
end

PopulateFuncs[EVENTTYPE_INTERRUPT] = function(captureMap, capturedData)
	-- Interrupt captureMap = { source, recipient, abilityName }
	parserEvent.eventType = EVENTTYPE_INTERRUPT
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
end

ValidityFuncs[EVENTTYPE_INTERRUPT] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local abilityName = captureMap[3]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	if filter.abilityName ~= nil then
		if filter.abilityName then
			if not abilityName then
				return false
			end
		else
			if abilityName then
				return false
			end
		end
	end
	if filter.abilityName_not ~= nil then
		if filter.abilityName_not then
			if abilityName then
				return false
			end
		else
			if not abilityName then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_LEECH] = function()
	-- Leech captureMap = { source, recipient, abilityName, amount, attribute, sourceGained, amountGained, attributeGained }
	globalStringInfo["SPELLPOWERLEECHOTHEROTHER"] = {eventType = EVENTTYPE_LEECH, captureMap = {1, 5, 2, 3, 4, 6, 7, 8}}
	globalStringInfo["SPELLPOWERLEECHOTHERSELF"] = {eventType = EVENTTYPE_LEECH, captureMap = {1, "player", 2, 3, 4, 5, 6, 7}}
	globalStringInfo["SPELLPOWERLEECHSELFOTHER"] = {eventType = EVENTTYPE_LEECH, captureMap = {"player", 4, 1, 2, 3, "player", 5, 6}}
end

PopulateFuncs[EVENTTYPE_LEECH] = function(captureMap, capturedData)
	-- Leech captureMap = { source, recipient, abilityName, amount, attribute, sourceGained, amountGained, attributeGained }
	parserEvent.eventType = EVENTTYPE_LEECH
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	local sourceName = capturedData[captureMap[1]] or captureMap[1]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[2]] or captureMap[2]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	local sourceGainedName = capturedData[captureMap[6]] or captureMap[6]
	if sourceGainedName == "player" then
		parserEvent.sourceGainedName = playerName
		parserEvent.sourceGainedID = "player"
		parserEvent.sourceGainedPvP = false
	else
		parserEvent.sourceGainedName = sourceGainedName
		parserEvent.sourceGainedID = toUnitID[sourceGainedName] or false
		parserEvent.sourceGainedPvP = not not recentPvP[sourceGainedName]
	end
	parserEvent.abilityName = capturedData[captureMap[3]]
	parserEvent.amount = capturedData[captureMap[4]]+0 -- coerce to number
	parserEvent.attributeLocal = capturedData[captureMap[5]]
	parserEvent.attribute = attributeToEnglish[parserEvent.attributeLocal] or ATTRIBUTE_UNKNOWN
	parserEvent.amountGained = capturedData[captureMap[7]]+0 -- coerce to number
	parserEvent.attributeGainedLocal = capturedData[captureMap[8]]
	parserEvent.attributeGained = attributeToEnglish[parserEvent.attributeGainedLocal] or ATTRIBUTE_UNKNOWN
end

ValidityFuncs[EVENTTYPE_LEECH] = function(captureMap, filter)
	local sourceName = captureMap[1]
	local recipientName = captureMap[2]
	local sourceGainedName = captureMap[6]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end

	if filter.sourceGainedID ~= nil then
		if filter.sourceGainedID == "player" then
			if sourceGainedName ~= "player" then
				return false
			end
		else
			if sourceGainedName == "player" then
				return false
			end
		end
	end
	if filter.sourceGainedID_not ~= nil and filter.sourceGainedID_not == "player" and sourceGainedName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_MISS] = function()
	-- Miss captureMap = { missType, source, recipient, abilityName }
	globalStringInfo["MISSEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, 1, 2, false}}
	globalStringInfo["MISSEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, 1, "player", false}}
	globalStringInfo["MISSEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, "player", 1, false}}
	globalStringInfo["SPELLBLOCKEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, 1, 3, 2}}
	globalStringInfo["SPELLBLOCKEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, 1, "player", 2}}
	globalStringInfo["SPELLBLOCKEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, "player", 2, 1}}
	globalStringInfo["SPELLDODGEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, 1, 3, 2}}
	globalStringInfo["SPELLDODGEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, 1, "player", 2}}
	globalStringInfo["SPELLDODGEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, "player", 2, 1}}
	globalStringInfo["SPELLDODGEDSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, "player", "player", 1}}
	globalStringInfo["SPELLEVADEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, 1, 3, 2}}
	globalStringInfo["SPELLEVADEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, "player", 2, 1}}
	globalStringInfo["SPELLEVADEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, 1, "player", 2}}
	globalStringInfo["SPELLEVADEDSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, "player", "player", 1}}
	globalStringInfo["SPELLIMMUNEOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, 3, 2}}
	globalStringInfo["SPELLIMMUNEOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, "player", 2}}
	globalStringInfo["SPELLIMMUNESELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", 2, 1}}
	globalStringInfo["SPELLIMMUNESELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", "player", 1}}
	globalStringInfo["SPELLLOGABSORBOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, 1, 3, 2}}
	globalStringInfo["SPELLLOGABSORBOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, 1, "player", 2}}
	globalStringInfo["SPELLLOGABSORBSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, "player", 2, 1}}
	globalStringInfo["SPELLLOGABSORBSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, "player", "player", 1}}
	globalStringInfo["SPELLMISSOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, 1, 3, 2}}
	globalStringInfo["SPELLMISSOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, 1, "player", 2}}
	globalStringInfo["SPELLMISSSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, "player", 2, 1}}
	globalStringInfo["SPELLMISSSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_MISS, "player", "player", 1}}
	globalStringInfo["SPELLPARRIEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, 1, 3, 2}}
	globalStringInfo["SPELLPARRIEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, 1, "player", 2}}
	globalStringInfo["SPELLPARRIEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, "player", 2, 1}}
	globalStringInfo["SPELLPARRIEDSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, "player", "player", 1}}
	globalStringInfo["SPELLREFLECTOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_REFLECT, 1, 3, 2}}
	globalStringInfo["SPELLREFLECTOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_REFLECT, 1, "player", 2}}
	globalStringInfo["SPELLREFLECTSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_REFLECT, "player", 2, 1}}
	globalStringInfo["SPELLREFLECTSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_REFLECT, "player", "player", 1}}
	globalStringInfo["SPELLRESISTOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 1, 3, 2}}
	globalStringInfo["SPELLRESISTOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 1, "player", 2}}
	globalStringInfo["SPELLRESISTSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, "player", 2, 1}}
	globalStringInfo["SPELLRESISTSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, "player", "player", 1}}
	globalStringInfo["VSABSORBOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, 1, 2, false}}
	globalStringInfo["VSABSORBOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, 1, "player", false}}
	globalStringInfo["VSABSORBSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, "player", 1, false}}
	globalStringInfo["VSBLOCKOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, 1, 2, false}}
	globalStringInfo["VSBLOCKOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, 1, "player", false}}
	globalStringInfo["VSBLOCKSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_BLOCK, "player", 1, false}}
	globalStringInfo["VSDODGEOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, 1, 2, false}}
	globalStringInfo["VSDODGEOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, 1, "player", false}}
	globalStringInfo["VSDODGESELFOTHER"] ={eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DODGE, "player", 1, false}}
	globalStringInfo["VSEVADEOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, 1, 2, false}}
	globalStringInfo["VSEVADEOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, 1, "player", false}}
	globalStringInfo["VSEVADESELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, "player", 1, false}}
	globalStringInfo["IMMUNEOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, 2, false}}
	globalStringInfo["IMMUNEOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, "player", false}}
	globalStringInfo["IMMUNESELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", 1, false}}
	globalStringInfo["IMMUNESELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", "player", false}}
	globalStringInfo["IMMUNESPELLOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 2, 1, 3}}
	globalStringInfo["IMMUNESPELLOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, "player", 2}}
	globalStringInfo["IMMUNESPELLSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", 1, 2}}
	globalStringInfo["IMMUNESPELLSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", "player", 1}}
	globalStringInfo["VSIMMUNEOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, 2, false}}
	globalStringInfo["VSIMMUNEOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, "player", false}}
	globalStringInfo["VSIMMUNESELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", 1, false}}
	globalStringInfo["VSDEFLECTOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, 1, 2, false}}
	globalStringInfo["VSDEFLECTOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, 1, "player", false}}
	globalStringInfo["VSDEFLECTSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, "player", 2, false}}
	globalStringInfo["SPELLDEFLECTEDOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, 1, 3, 2}}
	globalStringInfo["SPELLDEFLECTEDOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, 1, "player", 2}}
	globalStringInfo["SPELLDEFLECTEDSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, "player", 2, 1}}
	globalStringInfo["SPELLDEFLECTEDSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_DEFLECT, "player", "player", 1}}
	globalStringInfo["VSPARRYOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, 1, 2, false}}
	globalStringInfo["VSPARRYOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, 1, "player", false}}
	globalStringInfo["VSPARRYSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_PARRY, "player", 1, false}}
	globalStringInfo["IMMUNEDAMAGECLASSOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 2, 1, false}}
	globalStringInfo["IMMUNEDAMAGECLASSOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, 1, "player", false}}
	globalStringInfo["IMMUNEDAMAGECLASSSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, "player", 1, false}}
	globalStringInfo["VSRESISTOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 2, 1, false}}
	globalStringInfo["VSRESISTOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 1, "player", false}}
	globalStringInfo["VSRESISTSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, "player", 1, false}}
	globalStringInfo["SPELLLOGABSORBOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, false, 2, 1}}
	globalStringInfo["SPELLLOGABSORBSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_ABSORB, false, "player", 1}}
	globalStringInfo["SPELLIMMUNEOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, false, 2, 1}}
	globalStringInfo["SPELLIMMUNESELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, false, "player", 1}}
	globalStringInfo["PROCRESISTOTHEROTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 2, 1, 3}}
	globalStringInfo["PROCRESISTOTHERSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, 1, "player", 2}}
	globalStringInfo["PROCRESISTSELFOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, "player", 1, 2}}
	globalStringInfo["PROCRESISTSELFSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, "player", "player", 1}}
	globalStringInfo["SPELLRESISTOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, false, 2, 1}}
	globalStringInfo["SPELLRESISTSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_RESIST, false, "player", 1}}
	globalStringInfo["IMMUNESPELLOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, false, 1, 2}}
	globalStringInfo["IMMUNESPELLSELF"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_IMMUNE, false, "player", 1}}
	globalStringInfo["SPELLEVADEDOTHER"] = {eventType = EVENTTYPE_MISS, captureMap = {MISSTYPE_EVADE, false, 2, 1}}
end

PopulateFuncs[EVENTTYPE_MISS] = function(captureMap, capturedData)
	parserEvent.eventType = EVENTTYPE_MISS
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	parserEvent.missType = captureMap[1]
	parserEvent.missTypeLocal = missTypeToLocal[parserEvent.missType]
	local sourceName = capturedData[captureMap[2]] or captureMap[2]
	if sourceName == "player" then
		parserEvent.sourceName = playerName
		parserEvent.sourceID = "player"
		parserEvent.sourcePvP = false
	else
		parserEvent.sourceName = sourceName
		parserEvent.sourceID = toUnitID[sourceName] or false
		parserEvent.sourcePvP = not not recentPvP[sourceName]
	end
	local recipientName = capturedData[captureMap[3]] or captureMap[3]
	if recipientName == "player" then
		parserEvent.recipientName = playerName
		parserEvent.recipientID = "player"
		parserEvent.recipientPvP = false
	else
		parserEvent.recipientName = recipientName
		parserEvent.recipientID = toUnitID[recipientName] or false
		parserEvent.recipientPvP = not not recentPvP[recipientName]
	end
	parserEvent.abilityName = capturedData[captureMap[4]] or captureMap[4]
end

ValidityFuncs[EVENTTYPE_MISS] = function(captureMap, filter)
	local missType = captureMap[1]
	if filter.missType ~= nil and filter.missType ~= captureMap[1] then
		return false
	end
	if filter.missType_not ~= nil and filter.missType_not == captureMap[1] then
		return false
	end
	
	local sourceName = captureMap[2]
	local recipientName = captureMap[3]
	
	if filter.sourceID ~= nil then
		if filter.sourceID == "player" then
			if sourceName ~= "player" then
				return false
			end
		else
			if sourceName == "player" then
				return false
			end
		end
	end
	if filter.sourceID_not ~= nil and filter.sourceID_not == "player" and sourceName == "player" then
		return false
	end

	if filter.recipientID ~= nil then
		if filter.recipientID == "player" then
			if recipientName ~= "player" then
				return false
			end
		else
			if recipientName == "player" then
				return false
			end
		end
	end
	if filter.recipientID_not ~= nil and filter.recipientID_not == "player" and recipientName == "player" then
		return false
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_REPUTATION] = function()
	-- Reputation captureMap = { faction, amount, rank, isNegative }
	globalStringInfo["FACTION_STANDING_CHANGED"] = {eventType = EVENTTYPE_REPUTATION, captureMap = {2, false, 1, false}}
	globalStringInfo["FACTION_STANDING_DECREASED"] = {eventType = EVENTTYPE_REPUTATION, captureMap = {1, 2, false, true}}
	globalStringInfo["FACTION_STANDING_INCREASED"] = {eventType = EVENTTYPE_REPUTATION, captureMap = {1, 2, false, false}}
end

PopulateFuncs[EVENTTYPE_REPUTATION] = function(captureMap, capturedData)
	-- Reputation captureMap = { faction, amount, rank, isNegative }
	parserEvent.eventType = EVENTTYPE_REPUTATION
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	parserEvent.faction = capturedData[captureMap[1]]
	parserEvent.amount = tonumber(capturedData[captureMap[2]] or captureMap[2]) or 0
	parserEvent.rank = capturedData[captureMap[3]] or captureMap[3]
	if captureMap[4] then
		parserEvent.amount = -parserEvent.amount
	end
end

ValidityFuncs[EVENTTYPE_REPUTATION] = function(captureMap, filter)
	local rank = captureMap[3]
	local isNegative = captureMap[4]
	
	if filter.rank ~= nil then
		if filter.rank then
			if not rank then
				return false
			end
		else
			if rank then
				return false
			end
		end
	end
	if filter.rank_not ~= nil then
		if filter.rank_not then
			if rank then
				return false
			end
		else
			if not rank then
				return false
			end
		end
	end
	
	if filter.isNegative ~= nil then
		if filter.isNegative then
			if not isNegative then
				return false
			end
		else
			if isNegative then
				return false
			end
		end
	end
	if filter.isNegative_not ~= nil then
		if filter.isNegative_not then
			if isNegative then
				return false
			end
		else
			if not isNegative then
				return false
			end
		end
	end
	
	return true
end

GlobalStringFuncs[EVENTTYPE_SKILL] = function()
	-- Skill captureMap = { abilityName, amount }
	globalStringInfo["SKILL_RANK_UP"] = {eventType = EVENTTYPE_SKILL, captureMap = {1, 2}}
end

PopulateFuncs[EVENTTYPE_SKILL] = function(captureMap, capturedData)
	-- Skill captureMap = { abilityName, amount }
	parserEvent.eventType = EVENTTYPE_SKILL
	parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
	
	parserEvent.abilityName = capturedData[captureMap[1]]
	parserEvent.amount = capturedData[captureMap[2]]
end

ValidityFuncs[EVENTTYPE_SKILL] = function(captureMap, filter)
	return true
end

local function CreateGlobalStringCaptureMaps()
	-- Create the capture map for each supported global string.
	
	for k, v in pairs(GlobalStringFuncs) do
		v()
	end
	GlobalStringFuncs = nil
	
	-- Print an error message for each global string that isn't found and remove it from the info map.
	for name, v in pairs(globalStringInfo) do
		if not _G[name] then
--			DEFAULT_CHAT_FRAME:AddMessage("Parser-3.0: Unable to find global string: " .. name)
			globalStringInfo[name] = nil
		end
		if not v.populateEventFunc then
			local eventType = v.eventType
			if PopulateFuncs[eventType] then
				v.populateEventFunc = PopulateFuncs[eventType]
				v.validFunc = ValidityFuncs[eventType]
			else
				error(("%q does not specify a known eventType"):format(name))
			end
		end
	end
	
	PopulateFuncs = nil
	ValidityFuncs = nil
	
	CreateGlobalStringCaptureMaps = nil
end

local function MakeGlobalStringsUnique()
	local tmp = {}
	
	for name in pairs(globalStringInfo) do
		local str = _G[name]
		local num = tmp[str]
		if not num then
			tmp[str] = 1
		else
			tmp[str] = num + 1
			_G[name] = str .. (' '):rep(num) -- possibly change to 0-width character later: \226\129\160
		end
	end
	
	tmp = nil
	
	MakeGlobalStringsUnique = nil
end

local FixLogString
-- Note: This is stolen from SW_FixLogStrings
if CurrentLocale == "deDE" then
	function FixLogString(str)
		--problematic strings
		-- %ss 
		-- a string capture directly followd by a letter followed by a space
		return str:gsub("(%%%d?$?s)(%a%s)", "%1%'%2")
		
		-- ckknight note: I may use 0-width character instead of apostrophe.
	end
elseif CurrentLocale == "frFR" then
	function FixLogString(str)
		-- de is the main seperator
		return str:gsub("(%%%d?$?s) de (%%%d?$?s)", "%1 DE %2"):gsub("|2", "DE")
		
		-- ckknight note: I may use 'd', 0-width character, 'e' instead of 'DE'.
	end
elseif CurrentLocale == "zhCN" or CurrentLocale == "zhTW" then
	function FixLogString(str)
		-- jinsongzhao
		if str:find("的%%s") or str:find("对%%s") or str:find("击中%%s") or str:find("對%%s") or str:find("擊中%%s") then
			str = str:gsub("(%%%d?$?s)([^%s+].)", "%1 %2")
			str = str:gsub("(.[^%s+])(%%%d?$?s)", "%1 %2")
			str = str:gsub("(.[^%s+])(%%%d?$?d)", "%1 %2")
			str = str:gsub("(%%%d?$?d)([^%s+].)", "%1 %2")
			
			-- ckknight note: I may use 0-width character instead of a space.
		end
		return str
	end
else
	function FixLogString(str)
		--problematic strings
		-- %s's 
		--Twilight's Hammer Ambassador's Flame Shock hits you for 1234 fire damage.
		-- or fictional: Twilight's Hammer Ambassador's Nature's Grasp ...
		return str:gsub("(%%%d?$?s)('s)", "%1% %2")
		
		-- ckknight note: I may use 0-width character instead of a space.
	end
end

local function FixAmbiguousGlobalStrings()
	for name in pairs(globalStringInfo) do
		local str = _G[name]
		local newstr = FixLogString(str)
		if str ~= newstr then
			_G[name] = newstr
		end
	end
	
	MakeGlobalStringsUnique()
	
	for k in pairs(globalStringInfo) do
		for l in next, globalStringInfo, k do
			assert(_G[k] ~= _G[l])
		end
	end
	
	FixAmbiguousGlobalStrings = nil
end

local function FindGlobalStringRareWords()
	-- Hold the number of times each word appears in all the global strings.
	local wordCounts = {}
	
	local tmp = {}
	-- Loop through all of the supported global strings.
	for name in pairs(globalStringInfo) do
		local str = _G[name]
		local pattern = str:find("%%1%$[sd]") and "%%%d%$[sd]" or "%%[sd]"
		local start = 0
		local fin = 0
		while true do
			local lastFin = fin
			start, fin = str:find(pattern, start + 1)
			if not start then
				local s = str:sub(lastFin+1)
				if s:len() > 0 then
					tmp[#tmp+1] = s
				end
				break
			end
			if lastFin+1 <= start-1 then
				tmp[#tmp+1] = str:sub(lastFin+1, start-1)
			end
		end
		-- Count how many times each word appears in the global string.
		for i, word in ipairs(tmp) do
			wordCounts[word] = (wordCounts[word] or 0) + 1
			tmp[i] = nil
		end
	end


	-- Loop through all of the supported global strings.
	for name in pairs(globalStringInfo) do
		local leastSeen, rarestWord

		local str = _G[name]
		local pattern = str:find("%%1%$[sd]") and "%%%d%$[sd]" or "%%[sd]"
		local start = 0
		local fin = 0
		while true do
			local lastFin = fin
			start, fin = str:find(pattern, start + 1)
			if not start then
				local s = str:sub(lastFin+1)
				if s:len() > 0 then
					tmp[#tmp+1] = s
				end
				break
			end
			if lastFin+1 <= start-1 then
				tmp[#tmp+1] = str:sub(lastFin+1, start-1)
			end
		end

		-- Find the rarest word in the global string.
		for i, word in ipairs(tmp) do
			if not leastSeen or wordCounts[word] < leastSeen or (wordCounts[word] == leastSeen and word:len() > rarestWord:len()) then
				leastSeen = wordCounts[word]
				rarestWord = word
			end
			tmp[i] = nil
		end

		-- Set the rarest word.
		globalStringInfo[name].rarestWord = rarestWord
	end
	
	FindGlobalStringRareWords = nil
end

local function ConvertGlobalString(name, first)
	-- Check if the passed global string does not exist.
	local str = _G[name]
	if not str then
		return
	end

	-- Return the cached conversion if it has already been converted.
	if globalStringInfo[name] and globalStringInfo[name].searchPattern then
		return
	end

	-- Hold the capture order.
	local captureOrder
	local numCaptures = 0

	-- Escape lua magic chars.
	local pattern = str:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
	
	if pattern:find("%%%%1%%%$") then
		captureOrder = {}
		-- Loop through each capture and setup the capture order.
		for index in pattern:gmatch("%%%%(%d)%%%$[sd]") do
			numCaptures = numCaptures + 1
			captureOrder[index+0] = numCaptures
		end
		-- Convert %1$s to (..-) and %1$d to (%d+).
		pattern = pattern:gsub("%%%%%d%%%$s", "(..-)")
		pattern = pattern:gsub("%%%%%d%%%$d", "(%%d+)")
	else
		-- Convert %s to (..-) and %d to (%d+).
		pattern = pattern:gsub("%%%%s", "(..-)")
		pattern = pattern:gsub("%%%%d", "(%%d+)")
	end
	
	if pattern:sub(-5) == "(..-)" then
		pattern = pattern:sub(1, -6) .. "(.+)"
	end
	
	-- If no entry exists for the global string name, create one.
	if not globalStringInfo[name] then
		globalStringInfo[name] = {}
	end
	
	if first then
		pattern = "^" .. pattern
	end

	-- Cache the converted pattern and capture order.
	globalStringInfo[name].searchPattern = pattern
	globalStringInfo[name].captureOrder = captureOrder
end

local function ConvertGlobalStrings()
	-- Loop through all of the global strings.
	for name in pairs(globalStringInfo) do
		-- Get the global string converted to a lua search pattern.
		ConvertGlobalString(name, true)
	end

	-- Convert and cache all of the trailer global strings.
	ConvertGlobalString("ABSORB_TRAILER")
	ConvertGlobalString("BLOCK_TRAILER")
	ConvertGlobalString("RESIST_TRAILER")
	ConvertGlobalString("VULNERABLE_TRAILER")
	ConvertGlobalString("CRUSHING_TRAILER")
	ConvertGlobalString("GLANCING_TRAILER")
	
	--[[
	for k, info_k in pairs(globalStringInfo) do
		for l, info_l in pairs(globalStringInfo) do
			if k ~= l and info_k.searchPattern == info_l.searchPattern then
				DEFAULT_CHAT_FRAME:AddMessage(("Parser-3.0: %q and %q are ambiguous for locale %q. Please inform ckknight."):format(k, l, CurrentLocale))
			end
		end
	end
	]]
	
	if not FixAmbiguousGlobalStrings then -- code run
		for k, v in pairs(globalStringInfo) do
			for l, u in next, globalStringInfo, k do
				assert(v.searchPattern ~= u.searchPattern)
			end
		end
	end
	
	ConvertGlobalString = nil
	ConvertGlobalStrings = nil
end

local function ParsePartialEffectInfo(message, start)
	-- Check for a glancing blow.
	if message:find(globalStringInfo["GLANCING_TRAILER"].searchPattern, start) then
		parserEvent.isGlancing = true
	else
		parserEvent.isGlancing = false
	end
	
	-- Check for a crushing blow.
	if message:find(globalStringInfo["CRUSHING_TRAILER"].searchPattern, start) then
		parserEvent.isCrushing = true
	else
		parserEvent.isCrushing = false
	end

	-- Check for a partial absorb.
	local value = message:match(globalStringInfo["ABSORB_TRAILER"].searchPattern, start)
	if value then
		parserEvent.absorbAmount = value+0 -- coerce to number
	else
		parserEvent.absorbAmount = 0
	end

	-- Check for a partial block.
	value = message:match(globalStringInfo["BLOCK_TRAILER"].searchPattern, start)
	if value then
		parserEvent.blockAmount = value+0 -- coerce to number
	else
		parserEvent.blockAmount = 0
	end

	-- Check for a partial resist.
	value = message:match(globalStringInfo["RESIST_TRAILER"].searchPattern, start)
	if value then
		parserEvent.resistAmount = value+0 -- coerce to number
	else
		parserEvent.resistAmount = 0
	end

	-- Check for vulnerability damage.
	value = message:match(globalStringInfo["VULNERABLE_TRAILER"].searchPattern, start)
	if value then
		parserEvent.vulnerableAmount = value+0 -- coerce to number
	else
		parserEvent.vulnerableAmount = 0
	end
end

local Parser11_clients

local function RefreshEvents()
	for msg, info in pairs(globalStringInfo) do
		messages[msg] = false
	end
	for eventType, t in pairs(registry) do
		for filter, func in pairs(t) do
			for msg, info in pairs(globalStringInfo) do
				if info.eventType == eventType then
					if info.validFunc(info.captureMap, filter) then
						messages[msg] = true
					end
				end
			end
		end
	end
	for event, data in pairs(Parser11_clients) do
		for _, msg in ipairs(eventSearchMap[event]) do
			messages[msg] = true
		end
	end
	if registry[EVENTTYPE_UNKNOWN] then
		messages[EVENTTYPE_UNKNOWN] = true
	end
	for event, v in pairs(eventSearchMap) do
		if messages[EVENTTYPE_UNKNOWN] then
			Parser.frame:RegisterEvent(event)
		else
			Parser.frame:UnregisterEvent(event)
			for _, msg in ipairs(v) do
				if messages[msg] then
					Parser.frame:RegisterEvent(event)
					break
				end
			end
		end
	end
end

local list = {}
local function GetAcceptableEventTypes(data)
	for k in pairs(list) do
		list[k] = nil
	end
	if data.eventType ~= nil then
		if eventTypeToLocal[data.eventType] then
			list[data.eventType] = true
			return list
		end
	end
	if data.eventType_in ~= nil then
		if isList(data.eventType_in) then
			for _,v in ipairs(data.eventType_in) do
				list[v] = true
			end
		else
			for k, v in pairs(data.eventType_in) do
				if v then
					list[k] = true
				end
			end
		end
		return list
	end
	for k in pairs(eventTypeToLocal) do
		list[k] = true
	end
	if data.eventType_notin ~= nil then
		if isList(data.eventType_notin) then
			for _,v in ipairs(data.eventType_notin) do
				list[v] = nil
			end
		else
			for k, v in pairs(data.eventType_notin) do
				if v then
					list[k] = nil
				end
			end
		end
		return list
	end
	if data.eventType_not ~= nil then
		list[data.eventType_not] = nil
		return list
	end
	return list
end

local t = {}
for k in pairs(eventTypeToLocal) do
	t[#t+1] = k
end
local function func(t, start, ...)
	if start > #t then
		return ...
	else
		return t[start], func(t, start+1, ...)
	end
end
local function GetEventTypeTuple(...)
	return func(t, 1, ...)
end

function Parser:RegisterParserEvent(data, func, ...)
	Parser:argCheck(data, 2, 'table')
	if self == Parser then
		Parser:argCheck(func, 3, 'function')
	else
		Parser:argCheck(func, 3, 'function', 'string')
		if type(func) == "string" and type(self[func]) ~= "function" then
			Parser:error("Handler %q nonexistent.", func)
		end
	end
	local problem = validateFilter(data)
	if problem then
		Parser:error(problem)
	end
	local f = func
	if type(func) == "string" then
		if select('#', ...) > 0 then
			local t = { ... }
			local n = select('#', ...) + 1
			f = function(val)
				t[n] = val
				self[func](self, unpack(t, 1, n))
				t[n] = nil
			end
		else
			f = function(val)
				self[func](self, val)
			end
		end
	else
		if select('#', ...) > 0 then
			local t = { ... }
			local n = select('#', ...) + 1
			f = function(val)
				t[n] = val
				func(unpack(t, 1, n))
				t[n] = nil
			end
		end
	end
	for eventType in pairs(GetAcceptableEventTypes(data)) do
		if not registry[eventType] then
			registry[eventType] = {}
		end
		registry[eventType][data] = f
	end
	ownerRegistry[data] = self
	RefreshEvents()
end

function Parser:UnregisterParserEvent(data)
	Parser:argCheck(data, 2, 'table')
	local problem = validateFilter(data)
	if problem then
		Parser:error(problem)
	end
	
	if ownerRegistry[data] then
		for eventType in pairs(eventTypeToLocal) do
			if registry[eventType] then
				registry[eventType][data] = nil
			end
		end
		ownerRegistry[data] = nil
		RefreshEvents()
	end
end

function Parser:IsParserEventRegistered(data)
	Parser:argCheck(data, 2, 'table')
	local problem = validateFilter(data)
	if problem then
		Parser:error(problem)
	end
	if ownerRegistry[data] then
		return true
	end
	return false
end

function Parser:UnregisterAllParserEvents()
	Parser:argCheck(self, 1, 'table')
	if self == Parser then
		Parser:error("Must call `UnregisterAllParserEvents' from a mixin instance.")
	end
	for data, owner in pairs(ownerRegistry) do
		if owner == self then
			Parser.UnregisterParserEvent(self, data)
		end
	end
end

function Parser:OnEmbedDisable(target)
	self.UnregisterAllParserEvents(target)
end

local tmpCapture
do
	local t = {}
	function tmpCapture(_, finish, ...)
		if not finish then
			return nil
		end
		local num = select('#', ...)
		local t_num = #t
		if t_num > num then
			for i = t_num, num+1, -1 do
				t[i] = nil
			end
		end
		for i = 1, num do
			t[i] = select(i, ...)
		end
		return finish, t
	end
end

local ParserLib_SELF = 103
local ParserLib_MELEE = 112
local ParserLib_DAMAGESHIELD = 113
local ParserLib_NONE = 200

local BackwardsConvert
local Parser11_filterCache
local Parser11_filterCacheFuncs
if not _G.ParserLib or rawget(_G.ParserLib, 'parser30') then
	_G.ParserLib = {parser30 = true}
	local ParserLib = _G.ParserLib
	local first = true
	function ParserLib:GetInstance(version)
		assert(version == '1.1')
		if not first then
			return self
		end
		first = false
		_G.ParserLib_SELF = ParserLib_SELF
		_G.ParserLib_MELEE = ParserLib_MELEE
		_G.ParserLib_DAMAGESHIELD = ParserLib_DAMAGESHIELD
		_G.ParserLib_NONE = ParserLib_NONE
		
		local result = {}
		function BackwardsConvert(info)
			for k in pairs(result) do
				result[k] = nil
			end
			if info.eventType == EVENTTYPE_DAMAGE then
				result.type = "hit"
				if info.damageType == DAMAGETYPE_PHYSICAL or info.damageType == DAMAGETYPE_UNKNOWN then
					result.element = nil
				else
					result.element = info.damageTypeLocal
				
					if CurrentLocale == "frFR" then
						if result.element == SPELL_SCHOOL6_CAP then
							result.element = "Arcane"
						end
					elseif CurrentLocale == "zhTW" then
						if result.element == SPELL_SCHOOL5_CAP then
							result.element = "暗影"
						end
					end
				end
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName or ParserLib_NONE
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or ParserLib_NONE
				end
				result.skill = info.abilityName or ParserLib_MELEE
				if result.skill == SHIELDSLOT then
					result.skill = ParserLib_DAMAGESHIELD
				end
				result.amount = info.amount
				result.isCrit = info.isCrit
				result.isDOT = info.isDoT
				result.isSplit = info.isSplit
				result.isCrushing = info.isCrushing
				result.isGlancing = info.isGlancing
				if info.absorbAmount == 0 then
					result.amountAbsorb = nil
				else
					result.amountAbsorb = info.absorbAmount
				end
				if info.blockAmount == 0 then
					result.amountBlock = nil
				else
					result.amountBlock = info.blockAmount
				end
				if info.resistAmount == 0 then
					result.amountResist = nil
				else
					result.amountResist = info.resistAmount
				end
				if info.vulnerableAmount == 0 then
					result.amountVulnerable = nil
				else
					result.amountVulnerable = info.vulnerableAmount
				end
			elseif info.eventType == EVENTTYPE_HEAL then
				result.type = "heal"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName or ParserLib_NONE
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or ParserLib_NONE
				end
				result.skill = info.abilityName
				result.amount = info.amount
				result.isCrit = info.isCrit
				result.isDOT = info.isHoT
			elseif info.eventType == EVENTTYPE_ENVIRONMENTAL then
				result.type = "environment"
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or false
				end
				result.amount = info.amount
				if info.hazardType == HAZARDTYPE_DROWNING then
					result.damageType = "drown"
				elseif info.hazardType == HAZARDTYPE_FALLING then
					result.damageType = "fall"
				elseif info.hazardType == HAZARDTYPE_FATIGUE then
					result.damageType = "exhaust"
				elseif info.hazardType == HAZARDTYPE_FIRE then
					result.damageType = "fire"
				elseif info.hazardType == HAZARDTYPE_LAVA then
					result.damageType = "lava"
				elseif info.hazardType == HAZARDTYPE_SLIME then
					result.damageType = "slime"
				else
					error(("Unknown hazardType: %s. Inform ckknight immediately."):format(toliteral(info.hazardType)))
				end
				if info.absorbAmount == 0 then
					result.amountAbsorb = nil
				else
					result.amountAbsorb = info.absorbAmount
				end
				if info.blockAmount == 0 then
					result.amountBlock = nil
				else
					result.amountBlock = info.blockAmount
				end
				if info.resistAmount == 0 then
					result.amountResist = nil
				else
					result.amountResist = info.resistAmount
				end
				if info.vulnerableAmount == 0 then
					result.amountVulnerable = nil
				else
					result.amountVulnerable = info.vulnerableAmount
				end
			elseif info.eventType == EVENTTYPE_MISS then
				result.type = "miss"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName or ParserLib_NONE
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or ParserLib_NONE
				end
				result.skill = info.abilityName or ParserLib_MELEE
				result.missType = info.missType:lower()
			elseif info.eventType == EVENTTYPE_DEATH then
				result.type = "death"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or false
				end
				result.skill = info.abilityName
				result.isItem = info.isItem
			elseif info.eventType == EVENTTYPE_CAST then
				result.type = "cast"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				result.isBegin = info.isBegin
				result.isPerform = info.isPerform
			elseif info.eventType == EVENTTYPE_DRAIN then
				result.type = "drain"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName or ParserLib_NONE
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or ParserLib_NONE
				end
				result.skill = info.abilityName
				result.amount = info.amount
				result.attribute = info.attributeLocal
			elseif info.eventType == EVENTTYPE_DURABILITY then
				result.type = "durability"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				result.item = info.item or nil
				result.isAllItems = not result.item
			elseif info.eventType == EVENTTYPE_EXTRAATTACK then
				result.type = "extraattack"
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				result.amount = info.amount
			elseif info.eventType == EVENTTYPE_INTERRUPT then
				result.type = "interrupt"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
			elseif info.eventType == EVENTTYPE_DISPEL then
				result.type = "dispel"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.recipientAbilityName
				result.sourceSkill = info.sourceAbilityName
				result.isFailed = info.isFailed
			elseif info.eventType == EVENTTYPE_LEECH then
				result.type = "leech"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				if info.sourceGainedID == "player" then
					result.sourceGained = ParserLib_SELF
				else
					result.sourceGained = info.sourceGainedName
				end
				result.skill = info.abilityName
				result.amount = info.amount
				result.amountGained = info.amountGained
				result.attribute = info.attributeLocal
				result.attributeGained = info.attributeGainedLocal
			elseif info.eventType == EVENTTYPE_FAIL then
				result.type = "fail"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				result.skill = info.abilityName
				result.reason = info.reason
			elseif info.eventType == EVENTTYPE_ENCHANT then
				result.type = "enchant"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				result.item = info.item
			elseif info.eventType == EVENTTYPE_REPUTATION then
				result.type = "reputation"
				result.faction = info.faction
				result.rank = info.rank or nil
				if info.amount ~= 0 then
					if info.amount < 0 then
						result.isNegative = true
						result.amount = -info.amount
					else
						result.isNegative = false
						result.amount = info.amount
					end
				end
			elseif info.eventType == EVENTTYPE_HONOR then
				result.type = "honor"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				result.sourceRank = info.sourceRank or nil
				if info.amount ~= 0 then
					result.amount = info.amount or nil
				end
				result.isDishonor = not info.isHonorable
			elseif info.eventType == EVENTTYPE_EXPERIENCE then
				result.type = "experience"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				if info.recipientID == "player" then
					result.victim = nil
				else
					result.victim = info.recipientName
				end
				result.amount = info.amount
				if info.bonusAmount > 0 then
					result.bonusAmount = "+" .. info.bonusAmount
				end
				result.bonusType = info.bonusType or nil
				if info.penaltyAmount ~= 0 then
					result.penaltyAmount = info.penaltyAmount or nil
					result.penaltyType = info.penaltyType or nil
				end
				if info.amountRaidPenalty ~= 0 then
					result.amountRaidPenalty = info.amountRaidPenalty or nil
				end
				if info.amountGroupBonus ~= 0 then
					result.amountGroupBonus = info.amountGroupBonus or nil
				end
			elseif info.eventType == EVENTTYPE_FADE then
				result.type = "fade"
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				assert(type(result.skill) == "string")
			elseif info.eventType == EVENTTYPE_GAIN then
				result.type = "gain"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName or ParserLib_NONE
				end
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName or ParserLib_NONE
				end
				result.skill = info.abilityName
				result.attribute = info.attributeLocal or nil
				result.amount = info.amount
			elseif info.eventType == EVENTTYPE_AURA then
				result.type = info.isBuff and "buff" or "debuff"
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.skill = info.abilityName
				if info.amountRank ~= 1 then
					result.amountRank = info.amountRank
				end
			elseif info.eventType == EVENTTYPE_FEEDPET then
				result.type = "feedpet"
				if info.recipientID == "player" then
					result.victim = ParserLib_SELF
				else
					result.victim = info.recipientName
				end
				result.item = info.item or nil
			elseif info.eventType == EVENTTYPE_CREATE then
				result.type = "create"
				if info.sourceID == "player" then
					result.source = ParserLib_SELF
				else
					result.source = info.sourceName
				end
				result.item = info.item or nil
			else
				result.type = "unknown"
				result.message = info.message
			end
			return result
		end

		function ParserLib:RegisterEvent(addonID, event, handler)
			if eventSearchMap[event] and addonID then
				if type(handler) == "string" then
					if type(addonID) == "table" then
						handler = addonID[handler]
					else
						handler = _G[handler]
					end
				end
			
				if not handler then
					error('Usage: RegisterEvent(addonID, "event", handler or "handler")')
				end

				if not Parser11_clients[event] then
					Parser11_clients[event] = {}
				end

				Parser11_clients[event][addonID] = handler
				RefreshEvents()
			end
		end
	
		function ParserLib:UnregisterEvent(addonID, event)
			if Parser11_clients[event] and Parser11_clients[event][addonID] then
				Parser11_clients[event][addonID] = nil
				if not Parser11_clients[event] then
					Parser11_clients[event] = nil
				end
				RefreshEvents()
			end
		end
	
		function ParserLib:UnregisterAllEvents(addonID)
			for event in pairs(Parser11_clients) do
				self:UnregisterEvent(addonID, event)
			end
		end
	
		function ParserLib:IsEventRegistered(addonID, event)
			return Parser11_clients[event] and Parser11_clients[event][addonID]
		end
	
		local convertOldInfoTypeToNew = {
			buff = EVENTTYPE_AURA,
			debuff = EVENTTYPE_AURA,
			cast = EVENTTYPE_CAST,
			create = EVENTTYPE_CREATE,
			hit = EVENTTYPE_DAMAGE,
			death = EVENTTYPE_DEATH,
			dispel = EVENTTYPE_DISPEL,
			drain = EVENTTYPE_DRAIN,
			durability = EVENTTYPE_DURABILITY,
			enchant = EVENTTYPE_ENCHANT,
			environment = EVENTTYPE_ENVIRONMENTAL,
			experience = EVENTTYPE_EXPERIENCE,
			extraattack = EVENTTYPE_EXTRAATTACK,
			fade = EVENTTYPE_FADE,
			fail = EVENTTYPE_FAIL,
			feedpet = EVENTTYPE_FEEDPET,
			gain = EVENTTYPE_GAIN,
			heal = EVENTTYPE_HEAL,
			honor = EVENTTYPE_HONOR,
			interrupt = EVENTTYPE_INTERRUPT,
			leech = EVENTTYPE_LEECH,
			miss = EVENTTYPE_MISS,
			reputation = EVENTTYPE_REPUTATION,
			unknown = EVENTTYPE_UNKNOWN,
		}
	
		local function getFilter(addonID, infoType)
			if not Parser11_filterCache[addonID] then
				Parser11_filterCache[addonID] = {}
			end
			if not Parser11_filterCache[addonID][infoType] then
				local isBuff = nil
				if infoType == "buff" then
					isBuff = true
				elseif infoType == "debuff" then
					isBuff = false
				end
				Parser11_filterCache[addonID][infoType] = {
					eventType = convertOldInfoTypeToNew[infoType] or infoType,
					isBuff = isBuff
				}
			end
			return Parser11_filterCache[addonID][infoType]
		end
		
		local function handlerFunc(func, addonID, info)
			local backwards_info = BackwardsConvert(info)
			if type(addonID) == "table" then
				func(addonID, backwards_info.type, backwards_info, _G.event)
			else
				func(backwards_info.type, backwards_info, _G.event)
			end
		end
		function ParserLib:RegisterInfoType(addonID, infoType, func)
			if type(func) == "string" then
				if type(addonID) == "table" then
					func = addonID[func]
				else
					func = _G[func]
				end
			end
		
			if not func then
				error('Usage: RegisterInfoType(addonID, "infoType", handler or "handler")')
			end
			
			Parser11_filterCacheFuncs[getFilter(addonID, infoType)] = func
			Parser:RegisterParserEvent(getFilter(addonID, infoType), handlerFunc, func, addonID)
		end
	
		function ParserLib:UnregisterInfoType(addonID, infoType)
			local x = Parser11_filterCache[addonID] and Parser11_filterCache[addonID][infoType]
			if not x then
				return
			end
			Parser:UnregisterParserEvent(x)
			Parser11_filterCacheFuncs[x] = nil
			Parser11_filterCache[addonID][infoType] = nil
			if not next(Parser11_filterCache[addonID]) then
				Parser11_filterCache[addonID] = nil
			end
		end
	
		function ParserLib:UnregisterAllInfoTypes(addonID)
			if Parser11_filterCache[addonID] then
				for infoType in pairs(Parser11_filterCache[addonID]) do
					self:UnregisterInfoType(addonID, infoType)
				end
			end
		end
	
		function ParserLib:IsInfoTypeRegistered(addonID, infoType)
			if Parser11_filterCache[addonID] and Parser11_filterCache[addonID][infoType] then
				return true
			else
				return false
			end
		end
	
		local function ConvertPattern(pattern, anchor)
			local seq

			-- Add % to escape all magic characters used in LUA pattern matching, except $ and %
			pattern = pattern:gsub("([%^%(%)%.%[%]%*%+%-%?])","%%%1")


			if pattern:find("%$") then
				seq = {} -- fills with ordered list of $s as they appear
				local idx = 1 -- incremental index into field[]
				local prevIdx = idx
				local tmpSeq = {}
				for i in pattern:gmatch("%%(%d?)%$?[sd]") do
					if tonumber(i) then
						tmpSeq[idx] = tonumber(i)
						prevIdx = tonumber(i)+1
					else
						tmpSeq[idx] = prevIdx
						prevIdx = idx + 1
					end
					idx = idx + 1
				end
				for i, j in ipairs(tmpSeq) do
					seq[j] = i
				end
			end

			-- Do these AFTER escaping the magic characters.
			pattern = pattern:gsub("%%%d?%$?s", "(.-)")
			pattern = pattern:gsub("%%%d?%$?d", "(%-?%%d+)")


			-- Escape $ now.
			pattern = pattern:gsub("%$","%%$")

			-- Anchor tag can improve string.find() performance by 100%.
			if anchor then pattern = "^"..pattern end

			-- If the pattern ends with (.-), replace it with (.+), or the capsule will be lost.
			if pattern:sub(-4) == "(.-)" then
				pattern = pattern:sub(0, -5) .. "(.+)"
			end

			if seq then
				return pattern, unpack(seq)
			else
				return pattern
			end
		end
		local DoNothing = function(tok) return tok end
		local customPatterns = setmetatable({},{__index=function(self, key)
			local cp, tt, n, f, o

			tt = {}
			for tk in key:gmatch("%%%d?%$?([sd])") do
				table_insert(tt, tk)
			end

			cp = { ConvertPattern(key, true) }
			cp.p = cp[1]

			n = #(cp)
			for i=1,n-1 do
				cp[i] = cp[i+1]
			end
			table_remove(cp, n)

			f = {}
			o = {}
			n = #(tt)
			for i=1, n do
				if tt[i] == "s" then
					f[i] = DoNothing
				else
					f[i] = tonumber
				end
			end

			if not cp[1] then
				if n == 0 then
					self[key] = function() end
				elseif n == 1 then
					self[key] = function(text)
						o[1] = text:match(cp.p)
						if o[1] then
							return f[1](o[1])
						end
					end
				elseif n == 2 then
					self[key] = function(text)
						o[1], o[2]= text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2])
						end
					end
				elseif n == 3 then
					self[key] = function(text)
						o[1], o[2], o[3] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3])
						end
					end
				elseif n == 4 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4])
						end
					end
				elseif n == 5 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4]), f[5](o[5])
						end
					end
				elseif n == 6 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4]), f[5](o[5]), f[6](o[6])
						end
					end
				elseif n == 7 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4]), f[5](o[5]), f[6](o[6]), f[7](o[7])
						end
					end
				elseif n == 8 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7], o[8] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4]), f[5](o[5]), f[6](o[6]), f[7](o[7]), f[8](o[8])
						end
					end
				elseif n == 9 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7], o[8], o[9] = text:match(cp.p)
						if o[1] then
							return f[1](o[1]), f[2](o[2]), f[3](o[3]), f[4](o[4]), f[5](o[5]), f[6](o[6]), f[7](o[7]), f[8](o[8]), f[9](o[9])
						end
					end
				end
			else
				if n == 0 then
					self[key] = function() end
				elseif n == 1 then
					self[key] = function(text)
						o[1] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]])
						end
					end
				elseif n == 2 then
					self[key] = function(text)
						o[1], o[2] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]])
						end
					end
				elseif n == 3 then
					self[key] = function(text)
						o[1], o[2], o[3] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]])
						end
					end
				elseif n == 4 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]])
						end
					end
				elseif n == 5 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]]), f[cp[5]](o[cp[5]])
						end
					end
				elseif n == 6 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]]), f[cp[5]](o[cp[5]]), f[cp[6]](o[cp[6]])
						end
					end
				elseif n == 7 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]]), f[cp[5]](o[cp[5]]), f[cp[6]](o[cp[6]]), f[cp[7]](o[cp[7]])
						end
					end
				elseif n == 8 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7], o[8] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]]), f[cp[5]](o[cp[5]]), f[cp[6]](o[cp[6]]), f[cp[7]](o[cp[7]]), f[cp[8]](o[cp[8]])
						end
					end
				elseif n == 9 then
					self[key] = function(text)
						o[1], o[2], o[3], o[4], o[5], o[6], o[7], o[8], o[9] = text:match(cp.p)
						if o[1] then
							return f[cp[1]](o[cp[1]]), f[cp[2]](o[cp[2]]), f[cp[3]](o[cp[3]]), f[cp[4]](o[cp[4]]), f[cp[5]](o[cp[5]]), f[cp[6]](o[cp[6]]), f[cp[7]](o[cp[7]]), f[cp[8]](o[cp[8]]), f[cp[9]](o[cp[9]])
						end
					end
				end
			end
			return self[key]
		end})
		function ParserLib:Deformat(text, pattern)
			return customPatterns[pattern](text)
		end
	
		function ParserLib:IterateInfoTable()
			return pairs(BackwardsConvert(parserEvent))
		end
	
		return self
	end
	
	function ParserLib:NeedsUpgraded()
		return true
	end
	
	function ParserLib:Register(lib)
		assert(_G.TekLibStub)
		local libobj = _G.TekLibStub:NewStub("ParserLib")
		_G.ParserLib = libobj
		libobj:Register(lib)
		
		lib = ParserLib:GetInstance("1.1")
		
		for event, data in pairs(Parser11_clients) do
			for addonID, handler in pairs(data) do
				lib:RegisterEvent(addonID, event, handler)
				data[addonID] = nil
			end
			Parser11_clients[event] = nil
		end
		
		for addonID, data in pairs(Parser11_filterCache) do
			for infoType, filter in pairs(data) do
				local func = Parser11_filterCacheFuncs[filter]
				lib:RegisterInfoType(addonID, infoType, func)
				data[infoType] = nil
				Parser11_filterCacheFuncs[filter] = nil
			end
			Parser11_filterCache[addonID] = nil
		end
		
		RefreshEvents()
	end
end

local should_UpdateToUnitID = false
local function UpdateToUnitID()
	should_UpdateToUnitID = false
	for k in pairs(toUnitID) do
		toUnitID[k] = nil
	end
	
	local numParty = GetNumPartyMembers()
	local numRaid = GetNumRaidMembers()
	if numRaid > 0 then
		for i = 1, numRaid do
			local unitID = "raidpet" .. i
			local name = UnitName(unitID)
			if name then
				toUnitID[name] = unitID
			end
		end
		local name = UnitName("pet")
		if name then
			toUnitID[name] = "pet"
		end
		for i = 1, numRaid do
			local unitID = "raid" .. i
			toUnitID[UnitName(unitID)] = unitID
		end
	elseif numParty > 0 then
		for i = 1, numParty do
			local unitID = "partypet" .. i
			local name = UnitName(unitID)
			if name then
				toUnitID[name] = unitID
			end
		end
		local name = UnitName("pet")
		if name then
			toUnitID[name] = "pet"
		end
		for i = 1, numParty do
			local unitID = "party" .. i
			toUnitID[UnitName(unitID)] = unitID
		end
	else
		local name = UnitName("pet")
		if name then
			toUnitID[name] = "pet"
		end
	end
end

local shownParserEvent = setmetatable({}, {
	__index = parserEvent,
	__newindex = function(self, key, value)
		error("Cannot edit a read-only table", 2)
	end,
	__raw = parserEvent, -- so AceConsole-2.0 can properly :PrintLiteral
})
local sending = false
local function SendParserEvent(eventType, event)
	sending = true
	local r = registry[eventType]
	if r then
		for filter, func in pairs(r) do
			if filterFuncs[filter](parserEvent) then
				local success, ret = pcall(func, shownParserEvent)
				if not success then
					geterrorhandler()(ret)
				end
			end
		end
	end
	-- Parser 1.1 compat
	local q = Parser11_clients[event]
	if q then
		local backwardsParserEvent = BackwardsConvert(parserEvent)
		for addonID, func in pairs(q) do
			local success, ret
			if type(addonID) == "table" then
				success, ret = pcall(func, addonID, event, backwardsParserEvent)
			else
				success, ret = pcall(func, event, backwardsParserEvent)
			end
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	sending = false
end

function Parser:GetCurrentParserEvent()
	return sending and shownParserEvent or nil
end

local nextCleanup = 0
local function OnEvent(this, event, message)
	if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "UNIT_PET" or event == "PLAYER_PET_CHANGED" or event == "PLAYER_LOGIN" or event == "UNIT_NAME_UPDATE" then
		should_UpdateToUnitID = true
		return
	end
	if event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" then
		local unit = event == "PLAYER_TARGET_CHANGED" and "target" or "mouseover"
		if UnitExists(unit) and UnitPlayerControlled(unit) and not UnitIsFriend("player", unit) then
			local now = GetTime()
			if nextCleanup <= now then
				for k, v in pairs(recentPvP) do
					if v < now then
						recentPvP[k] = nil
					end
				end
				nextCleanup = now + 60
			end
			recentPvP[UnitName(unit)] = now + 60
		end
		return
	end
	
	local eventSearchMap_event = eventSearchMap[event]
	-- Leave if there is no map of global strings to search for the event.
	if not eventSearchMap_event then
		return
	end
	
	if ResortEventSearchMap then
		-- Resorts the event search map
		ResortEventSearchMap()

		-- Find the rarest word for each supported global string.
		FindGlobalStringRareWords()

		-- Convert the supported global strings into lua search patterns.
		ConvertGlobalStrings()
	end
	
	-- Loop through all of the global strings to search for the event.
	for i = 1, #eventSearchMap_event do
		local name = eventSearchMap_event[i]
		-- Get the info for the global string and ensure it's valid.
		local info = globalStringInfo[name]
		if info then
			-- First, check if the rarest word in the global string is in the combat message since
			-- a plain text search is faster than doing a full regular expression search.
			if message:find(info.rarestWord, 1, true) then
				-- Get capture data.
				if not messages[name] then
					if message:find(info.searchPattern) then
						return
					end
				else
					local start, capturedData = tmpCapture(message:find(info.searchPattern))
					if capturedData then
						-- Erase the parser event table and call the appropriate function to populate it.
						for k in pairs(parserEvent) do
							parserEvent[k] = nil
						end
						local order = info.captureOrder
						if order then
							capturedData[1], capturedData[2], capturedData[3], capturedData[4], capturedData[5], capturedData[6], capturedData[7], capturedData[8], capturedData[9] = capturedData[order[1]], capturedData[order[2]], capturedData[order[3]], capturedData[order[4]], capturedData[order[5]], capturedData[order[6]], capturedData[order[7]], capturedData[order[8]], capturedData[order[9]]
						end
						if should_UpdateToUnitID then
							UpdateToUnitID()
						end
						info.populateEventFunc(info.captureMap, capturedData)
						
						local eventType = parserEvent.eventType
					
						-- Make sure there is an event to send.
				    	if eventType then
							-- Check if the event type is damage or environmental.
							if eventType == EVENTTYPE_DAMAGE or eventType == EVENTTYPE_ENVIRONMENTAL then
								-- Parse partial effect trailer information.
								if #message > start then
									ParsePartialEffectInfo(message, start+1)
								else
									parserEvent.isGlancing = false
									parserEvent.isCrushing = false
									parserEvent.absorbAmount = 0
									parserEvent.blockAmount = 0
									parserEvent.resistAmount = 0
									parserEvent.vulnerableAmount = 0
								end
						    end
							
							-- debugging info
							parserEvent.globalString = name
							parserEvent.event = event
							parserEvent.message = message
							local uid = Parser.UID_NUM + 1
							Parser.UID_NUM = uid
							parserEvent.uid = uid
							
							-- Send the event.
							SendParserEvent(eventType, event)
						end
						return
					end
				end
			end
		end
	end
	if messages[EVENTTYPE_UNKNOWN] then
		for k in pairs(parserEvent) do
			parserEvent[k] = nil
		end
		
		parserEvent.eventType = EVENTTYPE_UNKNOWN
		parserEvent.eventTypeLocal = eventTypeToLocal[parserEvent.eventType]
		parserEvent.event = event
		parserEvent.message = message
		
		-- Send the event.
		SendParserEvent(EVENTTYPE_UNKNOWN, event)
	end
end

local function activate(self, oldLib, oldDeactivate)
	Parser = self
	
	self.frame = oldLib and oldLib.frame or _G.CreateFrame("Frame", "Parser30Frame")
	self.frame:SetScript("OnEvent", OnEvent)
	self.frame:RegisterEvent("RAID_ROSTER_UPDATE")
	self.frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self.frame:RegisterEvent("PLAYER_LOGIN")
	self.frame:RegisterEvent("UNIT_PET")
	self.frame:RegisterEvent("UNIT_NAME_UPDATE")
	self.frame:RegisterEvent("PLAYER_PET_CHANGED")
	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	
	self.registry = oldLib and oldLib.registry or {}
	registry = self.registry
	self.ownerRegistry = oldLib and oldLib.ownerRegistry or {}
	ownerRegistry = self.ownerRegistry
	self.Parser11_clients = oldLib and oldLib.Parser11_clients or {}
	Parser11_clients = self.Parser11_clients
	self.Parser11_filterCache = oldLib and oldLib.Parser11_filterCache or {}
	Parser11_filterCache = self.Parser11_filterCache
	self.Parser11_filterCacheFuncs = oldLib and oldLib.Parser11_filterCacheFuncs or {}
	Parser11_filterCacheFuncs = self.Parser11_filterCacheFuncs
	
	self.UID_NUM = oldLib and oldLib.UID_NUM or 0
	
	-- Create the event search map.
	CreateEventSearchMap()
	
	-- Create the global string capture map.
	CreateGlobalStringCaptureMaps()
	
	-- Some strings are ambiguous, dependent on the language.
--	FixAmbiguousGlobalStrings() -- currently disabled due to political reasons
	
	RefreshEvents()
end

AceLibrary:Register(Parser, MAJOR_VERSION, MINOR_VERSION, activate, nil, nil)