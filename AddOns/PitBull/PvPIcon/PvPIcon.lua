if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_PvPIcon = PitBull:NewModule("PvPIcon", "LibRockEvent-1.0")
local self = PitBull_PvPIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an icon on the unit frame when the unit is in PvP mode."] = "유닛이 PvP 모드 상태인 경우에 유닛 프레임에 아이콘을 표시합니다.",
	["PvP"] = "PvP",
	["Change settings for the PvP icon."] = "PvP 아이콘을 위한 설정을 변경합니다.",
	["Enable"] = "활성화",
	["Enables the PvP icon, indicating if this unit is flagged for PvP."] = "이 유닛이 PvP중임을 가리키는 PvP 아이콘을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-PvPIcon", localization)

PitBull.desc = L["Show an icon on the unit frame when the unit is in PvP mode."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_PvPIcon:RegisterPitBullChildFrames('pvpIcon')

function PitBull_PvPIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("PvPIcon")
	PitBull:SetDatabaseNamespaceDefaults("PvPIcon", "profile", {
		groups = {
			['*'] = {},
		},
	})
end

function PitBull_PvPIcon:OnEnable()
	self:AddEventListener("UPDATE_FACTION", "OnEvent")
	self:AddEventListener("PLAYER_FLAGS_CHANGED", "OnEvent")
	self:AddEventListener("UNIT_FACTION", "OnEvent")
end


local configMode = PitBull.configMode

function PitBull_PvPIcon:OnEvent(ns, event, unit)
	self:Update(unit)
end

function PitBull_PvPIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:Update(unit, true)
	end
end

local configMode_icons = {}

function PitBull_PvPIcon:Update(unit, noPet)
	if not unit then
		unit = "player"
	end
	
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		if self.db.profile.groups[frame.group].ignore then
			if frame.pvpIcon then
				frame.pvpIcon = delFrame(frame.pvpIcon)
				PitBull:UpdateLayout(frame)
			end
			return
		end
		
		local has = false
		
		if UnitIsPVPFreeForAll(unit) then
			has = 'FFA'
		else
			local faction = UnitFactionGroup(unit)
			if faction and (UnitIsPVP(unit) or configMode) then
				has = faction
			end
		end
		if not has and configMode then
			has = configMode_icons[unit]
			if not has then
				if unit == "player" or unit == "pet" or unit:find("^party%d$") or unit:find("^raid%d+$") or unit:find("^partypet%d$") or unit:find("^raidpet%d+$") or unit == "targettarget" or (unit:find("targettarget$") and not unit:find("targettargettarget$")) then
					has = UnitFactionGroup("player")
				elseif unit:find("^focus") then
					has = "FFA"
				else
					local faction = UnitFactionGroup("player")
					if faction == "Horde" then
						has = "Alliance"
					else
						has = "Horde"
					end
				end
				configMode_icons[unit] = has
			end
		end
		
		if has then
			if not frame.pvpIcon then
				frame.pvpIcon = newFrame("Texture", frame.overlay, "ARTWORK")
				frame.pvpIcon:Hide()
				PitBull:UpdateLayout(frame)
			end
			frame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. has)
			if has == "Horde" then
				frame.pvpIcon:SetTexCoord(0.08, 0.58, 0.045, 0.545)
			elseif has == "Alliance" then
				frame.pvpIcon:SetTexCoord(0.07, 0.58, 0.06, 0.57)
			else -- FFA
				frame.pvpIcon:SetTexCoord(0.05, 0.605, 0.015, 0.57)
			end
		else
			if frame.pvpIcon then
				frame.pvpIcon = delFrame(frame.pvpIcon)

				PitBull:UpdateLayout(frame)
			end
		end
	end
	
	if not noPet then
		if unit == "player" then
			self:Update("pet")
		else
			local num = unit:match("^party(%d)$")
			if num then
				self:Update("partypet" .. num)
			end
		end
	end
end

function PitBull_PvPIcon:OnUpdateFrame(unit, frame)
	self:Update(unit, true)
end

function PitBull_PvPIcon:OnClearUnitFrame(unit, frame)
	if frame.pvpIcon then
		frame.pvpIcon = delFrame(frame.pvpIcon)
	end
end

function PitBull_PvPIcon:OnUnknownLayout(unit, frame)
	frame.pvpIcon:SetPoint("CENTER", frame, "TOPRIGHT", 0, 0)
	frame.pvpIcon:SetWidth(27)
	frame.pvpIcon:SetHeight(27)
end

local function getEnabled(group)
	return not PitBull_PvPIcon.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	value = not value
	PitBull_PvPIcon.db.profile.groups[group].ignore = value
	if value then
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.pvpIcon then
				frame.pvpIcon = delFrame(frame.pvpIcon)
			end
		end
	else
		for unit in PitBull:IterateUnitFramesByGroup(group) do
			PitBull_PvPIcon:Update(unit)
		end
	end
end
PitBull_PvPIcon:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'group',
		name = L["PvP"],
		desc = L["Change settings for the PvP icon."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the PvP icon, indicating if this unit is flagged for PvP."],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
			}
		}
	}
end)

