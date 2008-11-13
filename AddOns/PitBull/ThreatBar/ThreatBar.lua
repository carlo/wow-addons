if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_ThreatBar = PitBull:NewModule("ThreatBar", "LibRockEvent-1.0")
local self = PitBull_ThreatBar
PitBull:SetModuleDefaultState(self, false)
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show a threat bar on the unit frame."] = "유닛 프레임에 위협바를 표시합니다.",
	["Threat"] = "위협",
	["Set the colors for the threat bar."] = "위협바를 위한 색상을 설정합니다.",
	["Color"] = "색상",
	["Set the color for the threat bar."] = "위협바를 위한 색상을 설정합니다.",
	["Background color"] = "배경 색상",
	["Set the background color for the threat bar."] = "위협바를 위한 배경 색상을 설정합니다.",
	["Options for the units threat bar."] = "유닛의 위협바를 위한 옵션.",
	["Enable"] = "활성화",
	["Enable the threat bar."] = "위협바를 활성화합니다.",
	["Show as deficit"] = "결손치로 표시",
	["Show threat deficit, draining the bar when you gain threat."] = "위협을 획득한 경우에 감소치로, 바가 빠져나가는 방식으로 위협도를 표시합니다.",
	["Reverse"] = "반전",
	["Reverses the direction of the threat bar, filling it from right to left."] = "위협바의 진행 방향을 뒤집어 우측에서 좌측으로 채워 나가는 방식으로 표시합니다.",
} or {}

local L = PitBull:L("PitBull-ThreatBar", localization)

self.desc = L["Show a threat bar on the unit frame."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local Threat

PitBull_ThreatBar:RegisterPitBullChildFrames('threatBar')

function PitBull_ThreatBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("ThreatBar")
	PitBull:SetDatabaseNamespaceDefaults("ThreatBar", "profile", {
		['**'] = {
			ignore = false,
			deficit = false,
			reverse = false,
		},
		colors = {.75, 0, 0},
		bgColors = {.25, 0, 0},
	})
end

function PitBull_ThreatBar:OnEnable(first)
	Threat = Rock("Threat-1.0", false, true)
	if not Threat then
		error("PitBull_ThreatBar requires the library Threat-1.0 to be available.")
	end
	self:AddEventListener("AceEvent-2.0", "Threat_ThreatUpdated")
	self:AddEventListener("AceEvent-2.0", "Threat_Activate")
	self:AddEventListener("AceEvent-2.0", "Threat_Deactivate")
	self:AddEventListener("PLAYER_TARGET_CHANGED")
	self:AddEventListener("PARTY_MEMBERS_CHANGED")
	self:AddEventListener("RAID_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED")
	self:AddEventListener("UNIT_PET", "PARTY_MEMBERS_CHANGED")
	self:AddEventListener("PLAYER_PET_CHANGED", "PARTY_MEMBERS_CHANGED")
end

local playerRaidID
local petRaidID
function PitBull_ThreatBar:PARTY_MEMBERS_CHANGED()
	local raid = GetNumRaidMembers()
	playerRaidID = nil
	petRaidID = nil
	if raid > 0 then
		for i = 1, raid do
			if UnitIsUnit("player", "raid" .. i) then
				playerRaidID = "raid" .. i
				break
			end
		end
		if UnitExists("pet") then
			for i = 1, raid do
				if UnitIsUnit("pet", "raidpet" .. i) then
					petRaidID = "raidpet" .. i
					break
				end
			end
		end
	end
end

local targetName
function PitBull_ThreatBar:PLAYER_TARGET_CHANGED()
	targetName = UnitName("target")
	
	for unit, frame in PitBull:IterateUnitFrames() do
		self:UpdateThreat(unit, frame)
	end
end

function PitBull_ThreatBar:Threat_ThreatUpdated(ns, event, name, unit, hash, value)
	if not targetName then
		return
	end
	
	if Threat:UnitIsUnit(targetName, hash) then
		self:UpdateThreat(unit)
	end
end

function PitBull_ThreatBar:Threat_Activate()
	for unit, frame in PitBull:IterateUnitFrames() do
		self:OnPopulateUnitFrame(unit, frame)
		PitBull:UpdateLayout(frame)
	end
end

function PitBull_ThreatBar:Threat_Deactivate()
	for unit, frame in PitBull:IterateUnitFrames() do
		self:OnClearUnitFrame(unit, frame)
		PitBull:UpdateLayout(frame)
	end
end

function PitBull_ThreatBar:UpdateThreat(unit, frame)
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit(unit) do
			self:UpdateThreat(unit, frame)
		end
		if unit == "player" then
			if playerRaidID then
				self:UpdateThreat(playerRaidID)
			end
		elseif unit == "pet" then
			if petRaidID then
				self:UpdateThreat(petRaidID)
			end
		end
		return
	end
	if not frame.threatBar then
		return
	end
	
	local current, max
	if targetName then
		current, max = Threat:GetThreat(UnitName(unit), targetName), Threat:GetMaxThreatOnTarget(targetName)
	end
	if not max or max == 0 then
		current = 0
		max = 1
	end
	if self.db.profile[unit].deficit ~= self.db.profile[unit].reverse then
		frame.threatBar:SetValue(math.max(max - current, 0) / max)
	else
		frame.threatBar:SetValue(current / max)
	end
	local r, g, b = unpack(self.db.profile.colors)
	local br, bg, bb = unpack(self.db.profile.bgColors)
	if self.db.profile[unit].reverse then
		frame.threatBar:SetStatusBarColor(br, bg, bb, 1)
		frame.threatBar.bg:SetVertexColor(r, g, b, 1)
	else
		frame.threatBar:SetStatusBarColor(r, g, b, 1)
		frame.threatBar.bg:SetVertexColor(br, bg, bb, 1)
	end	
end

function PitBull_ThreatBar:OnUpdateFrame(unit, frame)
	if not unit:find("target$") then
		self:UpdateThreat(unit, frame)
	end
end

function PitBull_ThreatBar:OnPopulateUnitFrame(unit, frame)
	if frame.threatBar or self.db.profile[frame.group].ignore then
		return 
	end
	if unit:find("target$") then
		return
	end
	if not Threat:IsActive() then
		return
	end
	local threatBar = newFrame("StatusBar", frame)
	frame.threatBar = threatBar
	threatBar:SetMinMaxValues(0, 1)
	threatBar:SetValue(0.5)
	threatBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	threatBar:SetStatusBarColor(unpack(self.db.profile.colors), 1)
	
	local threatBarBG = newFrame("Texture", threatBar, "BACKGROUND")
	frame.threatBar.bg = threatBarBG
	threatBarBG:SetTexture(PitBull:GetStatusBarTexture())
	threatBarBG:SetVertexColor(unpack(self.db.profile.bgColors))
	threatBarBG:SetAllPoints(threatBar)
end

function PitBull_ThreatBar:OnClearUnitFrame(unit, frame)
	if frame.threatBar then
		frame.threatBar.bg = delFrame(frame.threatBar.bg)
		frame.threatBar = delFrame(frame.threatBar)
	end
end

function PitBull_ThreatBar:OnUpdateStatusBarTexture(texture)
	for frame in PitBull:IterateUnitFramesForUnit("target") do
		if frame.threatBar and frame.threatBar.bg then
			frame.threatBar:SetStatusBarTexture(texture)
			frame.threatBar.bg:SetTexture(texture)
		end
	end
end

function PitBull_ThreatBar:OnUnknownLayout(unit, frame, name)
	frame.threatBar:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", frame:GetWidth()/2, 5)
	frame.threatBar:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 5)
	frame.threatBar:SetHeight(10)
end

local function getDisabled(group)
	return self.db.profile[group].ignore
end
local function getEnabled(group)
	return not self.db.profile[group].ignore
end
local function setEnabled(group, value)
	self.db.profile[group].ignore = not value
	
	if not value then
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.threatBar then
				PitBull_ThreatBar:OnClearUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end
	else
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if not frame.threatBar then
				PitBull_ThreatBar:OnPopulateUnitFrame(unit, frame)
				PitBull_ThreatBar:UpdateThreat(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end
	end
end

local function getDeficit(group)
	return PitBull_ThreatBar.db.profile[group].deficit
end
local function setDeficit(group, value)
	PitBull_ThreatBar.db.profile[group].deficit = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_ThreatBar:UpdateThreat(unit, frame)
	end
end
local function getReverse(group)
	return PitBull_ThreatBar.db.profile[group].reverse
end
local function setReverse(group, value)
	PitBull_ThreatBar.db.profile[group].reverse = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_ThreatBar:UpdateThreat(unit, frame)
	end
end


local function GetColor()
	return unpack(PitBull_ThreatBar.db.profile.colors)
end
local function SetColor(r, g, b)
	PitBull_ThreatBar.db.profile.colors = {r, g, b}
	
	for unit, frame in PitBull:IterateUnitFrames() do
		PitBull_ThreatBar:UpdateThreat(unit, frame)
	end
end

local function GetBGColor()
	return unpack(PitBull_ThreatBar.db.profile.bgColors)
end
local function SetBGColor(r, g, b)
	PitBull_ThreatBar.db.profile.bgColors = {r, g, b}
	for unit, frame in PitBull:IterateUnitFrames() do
		PitBull_ThreatBar:UpdateThreat(unit, frame)
	end
end

PitBull.options.args.global.args.colors.args.threatBar = {
	type = 'group',
	name = L["Threat"],
	desc = L["Set the colors for the threat bar."],
	args = {
		bar = {
			type = 'color',
			name = L["Color"],
			desc = L["Set the color for the threat bar."],
			get = GetColor,
			set = SetColor,
		},
		background = {
			type = 'color',
			name = L["Background color"],
			desc = L["Set the background color for the threat bar."],
			get = GetBGColor,
			set = SetBGColor,
		},
	},
}

PitBull_ThreatBar:RegisterPitBullOptionsMethod(function(group)
	if not group:find("target$") then
		return {
			name = L["Threat"],
			desc = L["Options for the units threat bar."],
			type = 'group',
			args = {
				ignore = {
					type = 'boolean',
					name = L["Enable"],
					desc = L["Enable the threat bar."],
					get = getEnabled,
					set = setEnabled,
					passValue = group,
					order = 1,
				},
				deficit = {
					type = 'boolean',
					name = L["Show as deficit"],
					desc = L["Show threat deficit, draining the bar when you gain threat."],
					get = getDeficit,
					set = setDeficit,
					passValue = group,
					disabled = getDisabled,
				},
				reverse = {
					type = 'boolean',
					name = L["Reverse"],
					desc = L["Reverses the direction of the threat bar, filling it from right to left."],
					get = getReverse,
					set = setReverse,
					passValue = group,
					disabled = getDisabled,
				},
			}
		}
	end
end)
