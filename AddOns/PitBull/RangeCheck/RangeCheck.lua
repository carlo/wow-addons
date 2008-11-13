if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 50777 $"):match("%d+"))

local BS = Rock("LibBabble-Spell-3.0"):GetLookupTable()

local localization = (GetLocale() == "koKR") and {
	["Range checking for PitBull unit frames."] = "PitBull 유닛 프레임을 위해 거리를 확인합니다.",
	["Range checking"] = "거리 확인",
	["Options for range checking between you and other units."] = "자신과 다른 유닛과의 거리 확인을 위한 옵션",
	["Opacity"] = "투명도",
	["Set the opacity to use on units that are not in range of you."] = "시야 범위를 벗어난 유닛에 사용할 투명도를 설정합니다.",
	["Enabled"] = "활성화",
	["Enable range checking."] = "거리 확인 기능을 활성화합니다.",
	["Interval"] = "간격",
	["Set how often the range should be checked."] = "얼마나 자주 거리를 확인할 것인지를 설정합니다.",
	["Enable range check"] = "거리 확인 활성화",
	["Range check turns units which are out of range slightly transparent."] = "시야 거리밖에 있는 유닛은 약간 불투명하게 전환해 거리를 확인합니다.",
} or {}

local L = PitBull:L("PitBull-RangeCheck", localization)

local distanceCheckFunction
local distanceCheckFunctionLow
local running
do
	local _,class = UnitClass("player")
	if class == "PRIEST" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Flash Heal"], unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "DRUID" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Healing Touch"], unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "PALADIN" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Holy Light"], unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "SHAMAN" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Healing Wave"], unit) == 1 or not UnitIsFriend("player", unit) end
	elseif class == "WARLOCK" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Corruption"], unit) == 1 or IsSpellInRange(BS["Shadow Bolt"], unit) == 1 or CheckInteractDistance(unit, 4) end
		distanceCheckFunctionLow = function(unit) return IsSpellInRange(BS["Fear"], unit) == 1 or UnitIsFriend("player", unit) end
	elseif class == "MAGE" then
		distanceCheckFunction = function(unit) return IsSpellInRange(BS["Fireball"], unit) == 1 or CheckInteractDistance(unit, 4) end
		distanceCheckFunctionLow = function(unit) return IsSpellInRange(BS["Fire Blast"], unit) == 1 or UnitIsFriend("player", unit) end
	else
		distanceCheckFunction = function(unit) return CheckInteractDistance(unit, 4) end
	end
	running = false
end

local PitBull = PitBull
local PitBull_RangeCheck = PitBull:NewModule("RangeCheck", "LibRockTimer-1.0")
local self = PitBull_RangeCheck
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-10-03 11:05:27 -0400 (Wed, 03 Oct 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end
self.desc = L["Range checking for PitBull unit frames."]

function PitBull_RangeCheck:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("RangeCheck")
	PitBull:SetDatabaseNamespaceDefaults("RangeCheck", "profile", {
		opacity = 0.6,
		interval = 0.7,
		enabled = true,
		groups = {
			player = {
				ignore = true,
			},
			target = {
				ignore = true,
			},
			targettarget = {
				ignore = true,
			},
			targettargettarget = {
				ignore = true,
			},
			['*'] = {},
		}
	})
end

function PitBull_RangeCheck:OnEnable()
	self:Enable()
end

function PitBull_RangeCheck:OnDisable()
	self:Disable()
end

function PitBull_RangeCheck:Enable()
	if self.db.profile.enabled and not running then
		self:AddRepeatingTimer("PitBull_RangeCheck", self.db.profile.interval, "RangeCheck")
		running = true
	end
end

function PitBull_RangeCheck:Disable()
	if running then
		self:RemoveTimer("PitBull_RangeCheck")
	
		for unit, frame in PitBull:IterateUnitFrames() do
			frame:SetAlpha(1)
		end
		running = false
	end
end

function PitBull_RangeCheck:RangeCheck()
	local opacity = self.db.profile.opacity
	for unit, frame in PitBull:IterateUnitFrames() do
		if frame:IsVisible() and not self.db.profile.groups[frame.group].ignore then
			if distanceCheckFunction(unit) then
				if distanceCheckFunctionLow then
					if distanceCheckFunctionLow( unit ) then
						frame:SetAlpha(1)
					else
						frame:SetAlpha(opacity+(1-opacity)/2)
					end
				else
					frame:SetAlpha(1)
				end
			else
				frame:SetAlpha(opacity)
			end
		end
	end
end


-- Global Options
local function getOpacity()
	return (PitBull_RangeCheck.db.profile.opacity)
end
local function setOpacity(opacity)
	PitBull_RangeCheck.db.profile.opacity = opacity
end
local function getGlobalEnabled()
	return (PitBull_RangeCheck.db.profile.enabled)
end
local function getGlobalDisabled()
	return not PitBull_RangeCheck.db.profile.enabled
end
local function setGlobalEnabled(enabled)
	PitBull_RangeCheck.db.profile.enabled = enabled
	if enabled then
		PitBull_RangeCheck:Enable()
	else
		PitBull_RangeCheck:Disable()
	end
end
local function getInterval()
	return (PitBull_RangeCheck.db.profile.interval)
end
local function setInterval(interval)
	PitBull_RangeCheck.db.profile.interval = interval
	if running then
		PitBull_RangeCheck:Disable()
		PitBull_RangeCheck:Enable()
	end
end
PitBull.options.args.global.args.rangecheck = {
	name = L["Range checking"],
	desc = L["Options for range checking between you and other units."],
	type = 'group',
	args = {
		opacity = {
			type = 'number',
			name = L["Opacity"],
			desc = L["Set the opacity to use on units that are not in range of you."],
			get = getOpacity,
			set = setOpacity,
			step = 0.01,
			bigStep = 0.05,
			disabled = getGlobalDisabled,
		},
		enabled = {
			type = 'boolean',
			name = L["Enabled"],
			desc = L["Enable range checking."],
			get = getGlobalEnabled,
			set = setGlobalEnabled,
		},
		interval = {
			type = 'number',
			name = L["Interval"],
			desc = L["Set how often the range should be checked."],
			get = getInterval,
			set = setInterval,
			min = 0.1,
			max = 10,
			step = 0.1,
			disabled = getGlobalDisabled,
		},
	},
}

-- Unit/Group Specific Options
local function getEnabled(group)
	return not PitBull_RangeCheck.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	PitBull_RangeCheck.db.profile.groups[group].ignore = not value
	if not value then
		for unit, frame in PitBull:IterateUnitFrames() do
			if frame.group ==  group then
				frame:SetAlpha(1)
			end
		end
	end
end
PitBull_RangeCheck:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Enable range check"],
		desc = L["Range check turns units which are out of range slightly transparent."],
		type = 'boolean',
		get = getEnabled,
		set = setEnabled,
		passValue = group,
	}
end)

