if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_RaidTargetIcon = PitBull:NewModule("RaidTargetIcon", "LibRockEvent-1.0")
local self = PitBull_RaidTargetIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an icon on the unit frame based on which Raid Target it is."] = "공격대 대상에 근거해 유닛 프레임에 아이콘을 표시합니다.",
	["Raid target"] = "공격대 대상",
	["Options for the raid target icon for this unit."] = "이 유닛에 대해 공격대 대상 아이콘을 위한 옵션",
	["Enable"] = "활성화",
	["Enables the raid target icon display on the unit frames for this unit type."] = "이 유닛 유형에 대해 유닛 프레임에 표시할 공격대 대상 아이콘을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-RaidTargetIcon", localization)

self.desc = L["Show an icon on the unit frame based on which Raid Target it is."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_RaidTargetIcon:RegisterPitBullChildFrames('raidTargetIcon')

function PitBull_RaidTargetIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("RaidTargetIcon")
	PitBull:SetDatabaseNamespaceDefaults("RaidTargetIcon", "profile", {
		['*'] = {
			disable = false,
		}
	})
end

function PitBull_RaidTargetIcon:OnEnable()
	self:AddEventListener("RAID_TARGET_UPDATE")
	self:AddEventListener("PARTY_MEMBERS_CHANGED", "RAID_TARGET_UPDATE")
end

local configMode = PitBull.configMode

function PitBull_RaidTargetIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:Update(unit, frame)
	end
end

local configMode_icons = {}

function PitBull_RaidTargetIcon:Update(unit, frame)
	local index = GetRaidTargetIndex(unit)
	if configMode then
		if not UnitExists(unit) or not index then
			index = configMode_icons[unit]
			if not index then
				index = math.random(1, 8)
				configMode_icons[unit] = index
			end
		end
	end
	if self.db.profile[frame.group].disable then
		index = nil
	end
	if index then
		if not frame.raidTargetIcon then
			frame.raidTargetIcon = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
			frame.raidTargetIcon:Hide()
			PitBull:UpdateLayout(frame)
		end
		
		SetRaidTargetIconTexture(frame.raidTargetIcon, index)
	else
		if frame.raidTargetIcon then
			frame.raidTargetIcon = delFrame(frame.raidTargetIcon)
			
			PitBull:UpdateLayout(frame)
		end
	end
end

function PitBull_RaidTargetIcon:RAID_TARGET_UPDATE()
	for unit, frame in PitBull:IterateNonWackyUnitFrames() do
		self:Update(unit, frame)
	end
end

function PitBull_RaidTargetIcon:OnUpdateFrame(unit, frame)
	self:Update(unit, frame)
end

function PitBull_RaidTargetIcon:OnClearUnitFrame(unit, frame)
	if frame.raidTargetIcon then
		frame.raidTargetIcon = delFrame(frame.raidTargetIcon)
	end
end

function PitBull_RaidTargetIcon:OnUnknownLayout(unit, frame)
	frame.raidTargetIcon:SetPoint("CENTER", frame, "TOP", 0, -3)
	frame.raidTargetIcon:SetWidth(18)
	frame.raidTargetIcon:SetHeight(18)
end

local function getEnable(group)
	return not PitBull_RaidTargetIcon.db.profile[group].disable
end
local function setEnable(group, value)
	PitBull_RaidTargetIcon.db.profile[group].disable = not value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_RaidTargetIcon:Update(unit, frame)
	end
end

PitBull_RaidTargetIcon:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'group',
		name = L["Raid target"],
		desc = L["Options for the raid target icon for this unit."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the raid target icon display on the unit frames for this unit type."],
				get = getEnable,
				set = setEnable,
				passValue = group,
			}
		}
	}
end)
