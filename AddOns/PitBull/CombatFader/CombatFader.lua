if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))
local DURATION = 0.5

local localization = (GetLocale() == "koKR") and {
	["Adds alpha changes based on combat."] = "전투에 근거해 투명도를 변경하는 기능을 추가합니다.",
	["Combat fade time"] = "전투 상태 명암 시간",
	["Set how long frames should be faded when combat status changes."] = "전투 상태가 변경된 경우 프레임의 명암 시간을 설정합니다.",
	["Combat fader"] = "전투 명암 넣기",
	["Change the alpha of the unit frame based on the units combat status."] = "유닛의 전투 상태에 근거해 유닛 프레임의 투명도를 변경합니다.",
	["In Combat alpha"] = "전투중 밝아짐",
	["What alpha to have while in combat."] = "전투중인 동안에 갖게될 투명도를 설정합니다.",
	["Out of Combat alpha"] = "비전투중 어두어짐",
	["What alpha to have while out of combat."] = "비전투중인 동안에 갖게될 투명도를 설정합니다.",
	["Enable"] = "활성화",
	["Enable changing the alpha based on combat status."] = "전투 상태에 근거해 투명도를 변경하는 기능을 활성화합니다",
} or {}

local L = PitBull:L("PitBull_CombatFader", localization)

local PitBull = PitBull
local PitBull_CombatFader = PitBull:NewModule("CombatFader", "LibRockEvent-1.0", "LibRockTimer-1.0")
local self = PitBull_CombatFader
PitBull:SetModuleDefaultState(self, false)
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end
self.desc = L["Adds alpha changes based on combat."]
local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame
local _abs, _floor, _cos, _pi = math.abs, math.floor, math.cos, math.pi
local activeframes = {}
local IsWackyUnit = PitBull.IsWackyUnit

function PitBull_CombatFader:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("CombatFader")
	PitBull:SetDatabaseNamespaceDefaults("CombatFader", "profile", {
		fadetime = 5,
		groups = {
			['**'] = { 
				disable = true,
				inAlpha = 1,
				outAlpha = 0.25,
			},
			["player"] = {
				disable = false,
				inAlpha = 1,
				outAlpha = 0.25,
			},			
			["target"] = {
				disable = false,
				inAlpha = 1,
				outAlpha = 0.5,
			},			
			["party"] = {
				disable = false,
				inAlpha = 1,
				outAlpha = 0.25,
			},			
		}
	})
end

function PitBull_CombatFader:OnEnable()
	self:AddEventListener("PLAYER_REGEN_ENABLED")
	self:AddEventListener("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
	self:AddRepeatingTimer(0, "UpdateAlphas")
end

function PitBull_CombatFader:PLAYER_REGEN_ENABLED()
	local db = self.db.profile.groups
	local inCombat = UnitAffectingCombat('player')
	local stop = GetTime() + self.db.profile.fadetime
	
	if inCombat then
		for unit, frame in PitBull:IterateUnitFrames() do
			if (frame and frame.group and not db[frame.group].ignore) then
				frame.cfstop = stop
				activeframes[frame] = db[frame.group].inAlpha
			end
		end
	else
		for unit, frame in PitBull:IterateUnitFrames() do
			if (frame and frame.group and not db[frame.group].ignore) then
				frame.cfstop = stop
				activeframes[frame] = db[frame.group].outAlpha
			end
		end
	end
end

function PitBull_CombatFader:OnClearUnitFrame(unit, frame)
	frame.cfstop = nil
	activeframes[frame] = nil
	frame:SetAlpha(1)
end

function PitBull_CombatFader:OnUpdateFrame(unit, frame)
	local stop = GetTime() + self.db.profile.fadetime
	local inCombat = UnitAffectingCombat('player')
	if (frame and frame.group and not self.db.profile.groups[frame.group].ignore) then
		if (IsWackyUnit[unit]) then
			if (not frame.cfstop) then frame.cfstop = stop end -- only set the stop time if it hasn't been set
		else
			frame.cfstop = stop -- always set the stop if it's not wacky
		end
		if inCombat then
			local finalAlpha = self.db.profile.groups[frame.group].inAlpha
			local currentAlpha = frame:GetAlpha()
			if (_floor(_abs(currentAlpha - finalAlpha)*100) > 0) then
				activeframes[frame] = finalAlpha
			end
		else
			local finalAlpha = self.db.profile.groups[frame.group].outAlpha
			local currentAlpha = frame:GetAlpha()
			if (_floor(_abs(currentAlpha - finalAlpha)*100) > 0) then
				activeframes[frame] = finalAlpha
			end
		end
	end
end

local function CosineInterpolate(y1, y2, mu)
	local mu2 = (1-_cos(mu*_pi))/2
	return y1*(1-mu2)+y2*mu2
end

function PitBull_CombatFader:UpdateAlphas()
	local now, fadeTime, currentAlpha, finalAlpha, tSteps = GetTime(), self.db.profile.fadetime
	for frame, finalAlpha in pairs(activeframes) do
		tSteps = frame.cfstop - now
		currentAlpha = frame:GetAlpha()
		if (_floor(_abs(currentAlpha - finalAlpha)*100) > 0) then
			tSteps = 1 - (tSteps / fadeTime)
			if (finalAlpha) then
				currentAlpha = CosineInterpolate(currentAlpha,finalAlpha,tSteps)
				if (currentAlpha > 1) then currentAlpha = 1 end
				if (currentAlpha < 0) then currentAlpha = 0 end
				frame:SetAlpha(currentAlpha)
			end
		else
			activeframes[frame] = nil
			frame.cfstop = nil
		end
	end
end

-- Global Options
local function setFadeTime(value)
	PitBull_CombatFader.db.profile.fadetime = value
end
local function getFadeTime()
	return PitBull_CombatFader.db.profile.fadetime
end
PitBull.options.args.global.args.combatfader = {
	type = 'number',
	name = L["Combat fade time"],
	desc = L["Set how long frames should be faded when combat status changes."],
	min = 0.1,
	max = 10,
	step = 0.1,
	get = getFadeTime,
	set = setFadeTime,
}

-- Unit/Group Specific Options
local function getOOC(group)
	return PitBull_CombatFader.db.profile.groups[group].outAlpha
end
local function setOOC(group, value)
	PitBull_CombatFader.db.profile.groups[group].outAlpha = value
end
local function getInCombat(group)
	return PitBull_CombatFader.db.profile.groups[group].inAlpha
end
local function setInCombat(group, value)
	PitBull_CombatFader.db.profile.groups[group].inAlpha = value
end
local function getEnabled(group)
	return not PitBull_CombatFader.db.profile.groups[group].ignore
end
local function getDisabled(group)
	return PitBull_CombatFader.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	PitBull_CombatFader.db.profile.groups[group].ignore = not value
end
PitBull_CombatFader:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Combat fader"],
		desc = L["Change the alpha of the unit frame based on the units combat status."],
		type = 'group',
		args = {
			incombat = {
				type = 'number',
				name = L["In Combat alpha"],
				desc = L["What alpha to have while in combat."],
				get = getInCombat,
				set = setInCombat,
				passValue = group,
				isPercent = true,
				min = 0,
				max = 1,
				step = 0.05,
				disabled = getDisabled,
			},
			ooc = {
				type = 'number',
				name = L["Out of Combat alpha"],
				desc = L["What alpha to have while out of combat."],
				get = getOOC,
				set = setOOC,
				passValue = group,
				isPercent = true,
				min = 0,
				max = 1,
				step = 0.05,
				disabled = getDisabled,
			},
			enable = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enable changing the alpha based on combat status."],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
				order = 1,
			},
		}
	}
end)
