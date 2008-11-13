if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_Highlight = PitBull:NewModule("Highlight", "LibRockEvent-1.0")
local self = PitBull_Highlight
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Highlight unit frames on mouse-over or on targetting."] = "마우스를 올려 놓은 혹은 대상으로 잡힌 유닛 프레임을 강조 표시합니다.",
	["Highlight"] = "강조",
	["Options for highlighting this unit when selected or moused over."] = "선택된 혹은 마우스를 올려 놓은 이 유닛의 강조 표시를 위한 옵션",
	["Enable"] = "활성화",
	["Highlight this unit on mouse-over."] = "마우스를 올려 놓았을 경우에 이 유닛을 강조 표시합니다.",
	["Highlight when targetted"] = "대상 지정의 경우 강조",
	["Highlight this unit frame when it is the same as your current target."] = "이 유닛 프레임을 현재 대상으로 지정한 경우에 강조 표시합니다.",
} or {}

local L = PitBull:L("PitBull-Highlight", localization)

self.desc = L["Highlight unit frames on mouse-over or on targetting."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local UnitIsUnit = UnitIsUnit

PitBull_Highlight:RegisterPitBullChildFrames('highlight')

function PitBull_Highlight:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("Highlight")
	PitBull:SetDatabaseNamespaceDefaults("Highlight", "profile", {
		['**'] = {
			hidden = false,
			showTarget = true,
		},
		target = {
			showTarget = false,
		},
		targettarget = {
			showTarget = false,
		},
		targettargettarget = {
			showTarget = false,
		}
	})
end

function PitBull_Highlight:OnEnable(first)
	self:AddEventListener("PLAYER_TARGET_CHANGED")
end

function PitBull_Highlight:PLAYER_TARGET_CHANGED()
	if UnitExists('target') then
		local mouseFocus = GetMouseFocus()
		for unit, frame in PitBull:IterateUnitFrames() do
			if frame.highlight and self.db.profile[frame.group].showTarget then
				if UnitIsUnit(unit, 'target') then
					frame.highlight:Show()
				elseif frame ~= mouseFocus then
					frame.highlight:Hide()
				end
			end
		end
	else
		local mouseFocus = GetMouseFocus()
		for unit, frame in PitBull:IterateUnitFrames() do
			if frame ~= mouseFocus and frame.highlight then
				frame.highlight:Hide()
			end
		end
	end
end

function PitBull_Highlight:OnPopulateUnitFrame(unit, frame)
	if not PitBull_Highlight.db.profile[frame.group].hidden then
		local highlight = newFrame("Texture", frame.overlay, "OVERLAY")
		frame.highlight = highlight
		highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		highlight:SetBlendMode("ADD")
		highlight:SetAlpha(0.5)
		highlight:Hide()
		highlight:SetAllPoints(frame)
	end
end

function PitBull_Highlight:OnClearUnitFrame(unit, frame)
	if frame.highlight then
		frame.highlight = delFrame(frame.highlight)
	end
end

function PitBull_Highlight:OnFrameOnEnter(unit, frame)
	if frame.highlight then
		frame.highlight:Show()
	end
end

function PitBull_Highlight:OnFrameOnLeave(unit, frame)
	if frame.highlight and (not UnitIsUnit(unit, "target") or not self.db.profile[frame.group].showTarget) then
		frame.highlight:Hide()
	end
end

function PitBull_Highlight:OnUnknownLayout(unit, frame, name)
	frame.highlight:SetAllPoints(frame)
	local mouseFocus = GetMouseFocus()
	if mouseFocus == frame then
		frame.highlight:Show()
		return
	end
	if UnitIsUnit(unit, "target") and self.db.profile[frame.group].showTarget then
		frame.highlight:Show()
		return
	end
	frame.highlight:Hide()
end

local function getDisabled(group)
	return PitBull_Highlight.db.profile[group].hidden
end
local function getEnabled(group)
	return not PitBull_Highlight.db.profile[group].hidden
end
local function setEnabled(group, value)
	value = not value
	PitBull_Highlight.db.profile[group].hidden = value
	
	if value then
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull_Highlight:OnClearUnitFrame(unit, frame)
			
			PitBull:UpdateLayout(frame)
		end
	else
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull_Highlight:OnPopulateUnitFrame(unit, frame)
		
			PitBull:UpdateLayout(frame)
			
			PitBull_Highlight:PLAYER_TARGET_CHANGED()
		end
	end
end
local function getShowTarget(group)
	return PitBull_Highlight.db.profile[group].showTarget
end
local function setShowTarget(group, value)
	PitBull_Highlight.db.profile[group].showTarget = value

	if value then
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.highlight and UnitIsUnit(unit, "target") then
				frame.highlight:Show()
			end
		end
	else
		local mouseFocus = GetMouseFocus()
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.highlight and frame ~= mouseFocus then
				frame.highlight:Hide()
			end
		end
	end
end
PitBull_Highlight:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Highlight"],
		desc = L["Options for highlighting this unit when selected or moused over."],
		type = "group",
		args = {
			enable = {
				name = L["Enable"],
				desc = L["Highlight this unit on mouse-over."],
				type = 'boolean',
				get = getEnabled,
				set = setEnabled,
				passValue = group,
				order = 1,
			},
			showTarget = {
				name = L["Highlight when targetted"],
				desc = L["Highlight this unit frame when it is the same as your current target."],
				type = 'boolean',
				get = getShowTarget,
				set = setShowTarget,
				passValue = group,
				disabled = getDisabled,
			},
		}
	}
end)
