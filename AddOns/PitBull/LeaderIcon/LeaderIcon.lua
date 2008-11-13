if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_LeaderIcon = PitBull:NewModule("LeaderIcon", "LibRockEvent-1.0", "LibRockTimer-1.0")
local self = PitBull_LeaderIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an icon on the unit frame when the unit is the group leader."] = "유닛이 그룹의 지휘자인 경우에 유닛 프레임에 아이콘을 표시합니다.",
	["Leader"] = "지휘자",
	["Options for the leader icon for this unit."] = "이 유닛에 대한 지휘자 아이콘을 위한 옵션",
	["Enable"] = "활성화",
	["Enables the leader icon, indicating who is the current group or raid leader."] = "현재 그룹 혹은 공격대의 지휘자임을 가리키는 지휘자 아이콘을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-LeaderIcon", localization)

self.desc = L["Show an icon on the unit frame when the unit is the group leader."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_LeaderIcon:RegisterPitBullChildFrames('leaderIcon')

function PitBull_LeaderIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("LeaderIcon")
	PitBull:SetDatabaseNamespaceDefaults("LeaderIcon", "profile", {
		['*'] = {
			disable = false,
		},
	})
end

function PitBull_LeaderIcon:OnEnable()
	self:AddEventListener("PARTY_LEADER_CHANGED")
	self:AddEventListener("PARTY_MEMBERS_CHANGED", "PARTY_LEADER_CHANGED")
end

local configMode = PitBull.configMode

function PitBull_LeaderIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:Update(unit, frame)
	end
end

function PitBull_LeaderIcon:Update(unit, frame)
	if frame.group ~= "player" and frame.group ~= "party" and frame.group ~= "raid" then
		return
	end
	local has = true
	if unit == "player" then
		if not IsPartyLeader() then
			has = false
		end
	else
		local raid = unit:match("^raid(%d%d?)$")
		if raid then
			local _, rank = GetRaidRosterInfo(tonumber(raid))
			if rank ~= 2 then
				has = false
			end
		else
			local party = unit:match("^party(%d)$")
			if party then
				if GetPartyLeaderIndex() ~= tonumber(party) then
					has = false
				end
			else
				has = false
			end
		end
	end
	if configMode then
		has = true
	end
	if self.db.profile[frame.group].disable then
		has = false
	end
	
	if has then
		if not frame.leaderIcon then
			local leaderIcon = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.leaderIcon = leaderIcon
			leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
			leaderIcon:SetTexCoord(0.1, 0.84, 0.14, 0.88)
			leaderIcon:Hide()
			PitBull:UpdateLayout(frame)
		end
	else
		if frame.leaderIcon then
			frame.leaderIcon = delFrame(frame.leaderIcon)
			
			PitBull:UpdateLayout(frame)
		end
	end
end

local function UpdateStuff(self)
	for unit, frame in PitBull:IterateNonWackyUnitFrames() do
		self:Update(unit, frame)
	end
end

function PitBull_LeaderIcon:PARTY_LEADER_CHANGED()
	self:AddTimer("PitBull_LeaderIcon-UpdateStuff", 0, UpdateStuff, self)
end

function PitBull_LeaderIcon:OnUpdateFrame(unit, frame)
	self:Update(unit, frame)
end

function PitBull_LeaderIcon:OnClearUnitFrame(unit, frame)
	if frame.leaderIcon then
		frame.leaderIcon = delFrame(frame.leaderIcon)
	end
end

function PitBull_LeaderIcon:OnUnknownLayout(unit, frame)
	frame.leaderIcon:SetPoint("CENTER", frame, "TOPLEFT", 0, 0)
	frame.leaderIcon:SetWidth(12)
	frame.leaderIcon:SetHeight(12)
end

local function getEnable(group)
	return not PitBull_LeaderIcon.db.profile[group].disable
end
local function setEnable(group, value)
	PitBull_LeaderIcon.db.profile[group].disable = not value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_LeaderIcon:Update(unit, frame)
	end
end

PitBull_LeaderIcon:RegisterPitBullOptionsMethod(function(group)
	if group ~= "player" and group ~= "party" and group ~= "raid" then
		return
	end
	return {
		type = 'group',
		name = L["Leader"],
		desc = L["Options for the leader icon for this unit."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the leader icon, indicating who is the current group or raid leader."],
				get = getEnable,
				set = setEnable,
				passValue = group,
			}
		}
	}
end)
