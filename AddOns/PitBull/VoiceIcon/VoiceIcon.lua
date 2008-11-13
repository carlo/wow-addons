if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 50729 $"):match("%d+"))

local localization = (GetLocale() == "koKR") and {
	["Show an icon based on whether or not the unit is in combat."] = "유닛의 전투 참가 여부에 근거해 아이콘을 표시합니다.",
	["Combat"] = "전투",
	["Options for the in-combat indicator for this unit."] = "이 유닛에 대해 전투중 아이콘을 위한 옵션",
	["Enable"] = "활성화",
	["Enables the in-combat indicator for this unit."] = "이 유닛에 대해 전투중 아이콘을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-VoiceIcon", localization)

local PitBull = PitBull
local PitBull_VoiceIcon = PitBull:NewModule("VoiceIcon", "LibRockEvent-1.0", "LibRockTimer-1.0")
local self = PitBull_VoiceIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-10-02 21:08:50 -0400 (Tue, 02 Oct 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end
self.desc = L["Show an icon based on whether or not the unit's voice status."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_VoiceIcon:RegisterPitBullChildFrames('voiceIcon')

function PitBull_VoiceIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("VoiceIcon")
	PitBull:SetDatabaseNamespaceDefaults("VoiceIcon", "profile", {
		groups = {
			['**'] = { disable = false },
		},
	})
end

function PitBull_VoiceIcon:OnEnable()
	self:AddEventListener("VOICE_START")
	self:AddEventListener("VOICE_STOP", "VOICE_START")
end

function PitBull_VoiceIcon:VOICE_START(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		self:Update('player', frame, event == "VOICE_START")
	end
end

local configMode = PitBull.configMode

function PitBull_VoiceIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:Update(unit, frame)
	end
end

function PitBull_VoiceIcon:Update(unit, frame, state)
	if self.db.profile.groups[frame.group].disable then return end
	if unit:match("pet") then return end
	
	local isTalking = configMode
	if not isTalking then
		if state == nil then
			isTalking = UnitIsTalking(unit)
		else
			isTalking = state
		end
	end
	
	if isTalking then
		if not frame.voiceIcon then
			frame.voiceIcon = newFrame("Frame", frame.overlay)
			frame.voiceIcon:Hide()
			frame.voiceIcon.base = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.voiceIcon.base:SetTexture([[Interface\Common\VoiceChat-Speaker]])
			frame.voiceIcon.base:SetTexCoord(0.04, 0.96, 0.04, 0.96)
			frame.voiceIcon.base:SetAllPoints(frame.voiceIcon)
			frame.voiceIcon.noise = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.voiceIcon.noise:SetTexture([[Interface\Common\VoiceChat-On]])
			frame.voiceIcon.noise:SetTexCoord(0.04, 0.96, 0.04, 0.96)
			frame.voiceIcon.noise:SetAllPoints(frame.voiceIcon)
			PitBull:UpdateLayout(frame)
			UIFrameFlash(frame.voiceIcon.noise, 0.35, 0.35, -1)
		end
	else
		if frame.voiceIcon then
			frame.voiceIcon.base = delFrame(frame.voiceIcon.base)
			UIFrameFlashStop(frame.voiceIcon.noise)
			frame.voiceIcon.noise = delFrame(frame.voiceIcon.noise)
			frame.voiceIcon = delFrame(frame.voiceIcon)
			
			PitBull:UpdateLayout(frame)
		end
	end
end

function PitBull_VoiceIcon:OnUpdateFrame(unit, frame)
	self:Update(unit, frame)
end

function PitBull_VoiceIcon:OnClearUnitFrame(unit, frame)
	if frame.voiceIcon then
		frame.voiceIcon.base = delFrame(frame.voiceIcon.base)
		UIFrameFlashStop(frame.voiceIcon.noise)
		frame.voiceIcon.noise = delFrame(frame.voiceIcon.noise)
		frame.voiceIcon = delFrame(frame.voiceIcon)
	end
end

function PitBull_VoiceIcon:OnUnknownLayout(unit, frame)
	frame.voiceIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", 0, 0)
	frame.voiceIcon:SetWidth(18)
	frame.voiceIcon:SetHeight(18)
end

-- Unit/Group Specific Options
local function getEnabled(group)
	return not PitBull_VoiceIcon.db.profile.groups[group].disable
end
local function setEnabled(group, value)
	value = not value
	PitBull_VoiceIcon.db.profile.groups[group].disable = value
	if value then
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.voiceIcon then
				frame.voiceIcon.base = delFrame(frame.voiceIcon.base)
				frame.voiceIcon.noise = delFrame(frame.voiceIcon.noise)
				frame.voiceIcon = delFrame(frame.voiceIcon)
				PitBull:UpdateLayout(frame)
			end
		end
	else
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if not frame.voiceIcon then
				self:Update(unit, frame)
			end
		end
	end
end

PitBull_VoiceIcon:RegisterPitBullOptionsMethod(function(group)
	if group:match("pet") then return end
	return {
		type = 'group',
		name = L["Voice"],
		desc = L["Options for the voice indicator for this unit."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the voice indicator for this unit."],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
			}
		}
	}
end)

