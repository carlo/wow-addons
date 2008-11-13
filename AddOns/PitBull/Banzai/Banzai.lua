if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49329 $"):match("%d+"))

local L = AceLibrary("AceLocale-2.2"):new("PitBull_Banzai")
L:RegisterTranslations("enUS", function() return {
	["Adds aggro coloring to PitBull."] = true,
	["Aggro color"] = true,
	["Sets which color to use on the health bar of units that have aggro."] = true,
	["Enable aggro indicator"] = true,
	["Change the color of this unit's health bar when it gets aggro."] = true,
} end)
L:RegisterTranslations("koKR", function() return {
	["Adds aggro coloring to PitBull."] = "PitBull에 어그로 색상화를 추가합니다.",
	["Aggro color"] = "어그로 색상",
	["Sets which color to use on the health bar of units that have aggro."] = "어그로를 갖고 있는 유닛의 생명력바에 사용할 색상을 설정합니다",
	["Enable aggro indicator"] = "어그로 아이콘 활성화",
	["Change the color of this unit's health bar when it gets aggro."] = "어그로를 획득한 경우 이 유닛의 생명력바의 색상을 변경합니다.",
} end)

PitBull_Banzai = PitBull:NewModule("Banzai", "LibRockEvent-1.0", "LibRockHook-1.0")
local PitBull_Banzai = PitBull_Banzai
local self = PitBull_Banzai
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 22:54:09 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end
self.desc = L["Adds aggro coloring to PitBull."]

local PitBull_HealthBar = PitBull:GetModule("HealthBar")

local banzai
local backgroundColors = {0, 0, 0, 1}

local function updateBGColor(color)
	for i, v in ipairs(color) do
		backgroundColors[i] = (v + 0.2) / 3
	end
	backgroundColors[4] = 1
end

function PitBull_Banzai:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("Banzai")
	PitBull:SetDatabaseNamespaceDefaults("Banzai", "profile", {
		color = {1.0, 0, 0, 1.0},
		groups = {
			target = {
				ignore = true,
			},
			targettarget = {
				ignore = true,
			},
			targettargettarget = {
				ignore = true,
			},
			["*"] = {},
		}
	})
	updateBGColor(self.db.profile.color)
end

function PitBull_Banzai:OnEnable()
	banzai = Rock("Banzai-1.1", false, true)
	if not banzai then
		error("PitBull_Banzai requires the library Banzai-1.1 to be available.")
	end
	self:AddEventListener("AceEvent-2.0", "Banzai_UnitGainedAggro", "AggroChanged")
	self:AddEventListener("AceEvent-2.0", "Banzai_UnitLostAggro", "AggroChanged")
	self:AddHook(PitBull_HealthBar, "UpdateHealthbarColor")
end

function PitBull_Banzai:AggroChanged(ns, event, unitId)
	for frame in PitBull:IterateUnitFramesForUnit(unitId) do
		if frame and not self.db.profile.groups[frame.group].ignore then
			self:UpdateHealthbarColor(PitBull_HealthBar, unitId, frame)
		end
	end
end

function PitBull_Banzai:UpdateHealthbarColor(module, unit, frame)
	if not frame.healthBar then
		return self.hooks[module].UpdateHealthbarColor(module, unit, frame)
	end
	if not self.db.profile.groups[frame.group].ignore then
		local aggro = banzai:GetUnitAggroByUnitId(unit)
		if aggro then
			local color = self.db.profile.color
			if PitBull_HealthBar.db.profile[frame.group].reverse then
				frame.healthBar:SetStatusBarColor(unpack(backgroundColors))
				frame.healthBar.bg:SetVertexColor(unpack(color))
			else
				frame.healthBar:SetStatusBarColor(unpack(color))
				frame.healthBar.bg:SetVertexColor(unpack(backgroundColors))
			end
			return
		end
	end
	self.hooks[module].UpdateHealthbarColor(module, unit, frame)
end
-- Global Options
local function getColor()
	return unpack(PitBull_Banzai.db.profile.color)
end
local function setColor(r, g, b, a)
	PitBull_Banzai.db.profile.color = {r, g, b, a}
	updateBGColor(PitBull_Banzai.db.profile.color)
	for unit,frame in PitBull:IterateUnitFrames() do
		PitBull_Banzai:UpdateHealthbarColor(PitBull_HealthBar, unit, frame)
	end
end
PitBull.options.args.global.args.colors.args.banzai = {
	type = 'color',
	name = L["Aggro color"],
	desc = L["Sets which color to use on the health bar of units that have aggro."],
	get = getColor,
	set = setColor,
}
-- Unit/Group Specific Options
local function getEnabled(group)
	return not PitBull_Banzai.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	PitBull_Banzai.db.profile.groups[group].ignore = not value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Banzai:UpdateHealthbarColor(PitBull_HealthBar, unit, frame)
	end
end
PitBull_Banzai:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'boolean',
		name = L["Enable aggro indicator"],
		desc = L["Change the color of this unit's health bar when it gets aggro."],
		get = getEnabled,
		set = setEnabled,
		passValue = group,
	}
end)

