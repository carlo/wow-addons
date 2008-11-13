if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 51570 $"):match("%d+"))

local PitBull = PitBull
local PitBull_ExperienceBar = PitBull:NewModule("ExperienceBar", "LibRockEvent-1.0")
local self = PitBull_ExperienceBar
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-10-10 02:08:17 -0400 (Wed, 10 Oct 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an experience bar on the unit frame."] = "유닛 프레임에 경험치 바를 표시합니다.",
	["Experience"] = "경험치",
	["Set the colors for the experience bar."] = "경험치 바를 위한 색상을 설정합니다.",
	["Color"] = "색상",
	["Set the color for the experience bar."] = "경험치 바를 위한 색상을 설정합니다.",
	["Background color"] = "배경 색상",
	["Set the background color for the experience bar."] = "경험치 바를 위한 배경 색상을 설정합니다.",
	["Rest color"] = "휴식 색상",
	["Set the color for rested experience on the bar."] = "바에 휴식 경험치를 위한 색상을 설정합니다.",
	["Options for the units experience bar."] = "유닛의 경험치 바를 위한 옵션",
	["Enable"] = "활성화",
	["Enable the experience bar."] = "경험치 바를 활성화합니다.",
	["Show as deficit"] = "감소치로 표시",
	["Show experience deficit, draining the bar when you gain experience."] = "경험치를 획득한 경우에 바가 감소하는, 빠져 나가는 경험치로 표시합니다.",
	["Reverse"] = "반전",
	["Reverses the direction of the experience bar, filling it from right to left."] = "경험치 바의 진행 방향을 뒤집어 우측에서 좌측으로 채워나가는 방식으로 표시합니다.",
} or {}

local L = PitBull:L("PitBull-ExperienceBar", localization)

self.desc = L["Show an experience bar on the unit frame."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local repColor = {
	[1] = {r = 226/255, g = 45/255, b = 75/255}, -- Hated
	[2] = {r = 226/255, g = 45/255, b = 75/255}, -- Hostile
	[3] = {r = 0.75, g = 0.27, b = 0}, -- unfriendly
	[4] = {r = 1, g = 1, b = 34/255}, -- neutral
	[5] = {r = 0.2, g = 0.8, b = 0.15}, -- friendly
	[6] = {r = 0.2, g = 0.8, b = 0.15}, -- honored
	[7] = {r = 0.2, g = 0.8, b = 0.15}, -- revered
	[8] = {r = 0.2, g = 0.8, b = 0.15}, -- exalted
}

PitBull_ExperienceBar:RegisterPitBullChildFrames('expBar')

local showPet = select(2, UnitClass("player")) == "HUNTER"

function PitBull_ExperienceBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("ExperienceBar")
	PitBull:SetDatabaseNamespaceDefaults("ExperienceBar", "profile", {
		['**'] = {
			ignore = false,
			deficit = false,
			reverse = false,
		},
		player = {
			ignore = true,
		},
		colors = {0, 0, 1},
		restColors = {1, 0, 1},
		bgColors = {0, 0, 0},
	})
end

function PitBull_ExperienceBar:OnEnable(first)
	self:AddEventListener("PLAYER_XP_UPDATE")
	self:AddEventListener("UPDATE_EXHAUSTION", "PLAYER_XP_UPDATE")
	self:AddEventListener("PLAYER_LEVEL_UP", "PLAYER_XP_UPDATE")
end

function PitBull_ExperienceBar:PLAYER_XP_UPDATE()
	self:UpdateExperience("player")
	if showPet then
		self:UpdateExperience("pet")
	end
end

function PitBull_ExperienceBar:UpdateExperience(unit, frame)
	if not unit then
		self:PLAYER_XP_UPDATE()
		return
	end
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit(unit) do
			self:UpdateExperience(unit, frame)
		end
		return
	end
	
	if self.db.profile[unit].ignore or UnitLevel(unit) == MAX_PLAYER_LEVEL or (unit == "pet" and UnitLevel("pet") == UnitLevel("player")) then
		if frame.expBar then
			PitBull_ExperienceBar:OnClearUnitFrame(unit, frame)
			PitBull:UpdateLayout(frame)
		end
		return
	else
		if not frame.expBar then
			PitBull_ExperienceBar:OnPopulateUnitFrame(unit, frame)
			PitBull:UpdateLayout(frame)
		end
	end
	
	local current, max
	if unit == "player" then
		current, max = UnitXP(unit), UnitXPMax(unit)
	else
		current, max = GetPetExperience()
	end
	if max == 0 then
		current = 0
		max = 1
	end
	local rest = unit == "player" and GetXPExhaustion() or 0
	if self.db.profile[unit].deficit ~= self.db.profile[unit].reverse then
		frame.expBar:SetValue(math.max(max - current - rest, 0) / max)
		frame.expBar.rest:SetValue((max - current) / max)
	else
		frame.expBar:SetValue(current / max)
		frame.expBar.rest:SetValue(math.min(current + rest, max) / max)
	end
	local r, g, b = unpack(self.db.profile.colors)
	local br, bg, bb = unpack(self.db.profile.bgColors)
	local rr, rg, rb = unpack(self.db.profile.restColors)
	if self.db.profile[unit].reverse then
		frame.expBar:SetStatusBarColor(br, bg, bb, 1)
		frame.expBar.bg:SetVertexColor(r, g, b, 1)
	else
		frame.expBar:SetStatusBarColor(r, g, b, 1)
		frame.expBar.bg:SetVertexColor(br, bg, bb, 1)
	end	
	frame.expBar.rest:SetStatusBarColor(rr, rg, rb, 1)
end

function PitBull_ExperienceBar:OnUpdateFrame(unit, frame)
	if unit == "player" or (showPet and unit == "pet") then
		self:UpdateExperience(unit, frame)
	end
end

function PitBull_ExperienceBar:OnPopulateUnitFrame(unit, frame)
	if frame.expBar or self.db.profile[unit].ignore or UnitLevel(unit) == MAX_PLAYER_LEVEL then
		return 
	end
	if unit == "player" or (showPet and unit == "pet") then
		local expBar = newFrame("StatusBar", frame)
		frame.expBar = expBar
		expBar:SetMinMaxValues(0, 1)
		expBar:SetValue(0.5)
		expBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
		expBar:SetStatusBarColor(0, 0, 1, 1)
		
		local expBarRest = newFrame("StatusBar", expBar)
		frame.expBar.rest = expBarRest
		expBarRest:SetMinMaxValues(0, 1)
		expBarRest:SetValue(0.5)
		expBarRest:SetStatusBarTexture(PitBull:GetStatusBarTexture())
		expBarRest:SetStatusBarColor(1, 0, 1, 1)
		expBarRest:SetAllPoints(expBar)
		
		local a, b = expBar:GetFrameLevel(), expBarRest:GetFrameLevel()
		expBar:SetFrameLevel(b)
		expBarRest:SetFrameLevel(a)
		
		local expBarBG = newFrame("Texture", expBarRest, "BACKGROUND")
		frame.expBar.bg = expBarBG
		expBarBG:SetTexture(PitBull:GetStatusBarTexture())
		expBarBG:SetVertexColor(unpack(self.db.profile.bgColors))
		expBarBG:SetAllPoints(expBar)
	end
end

function PitBull_ExperienceBar:OnClearUnitFrame(unit, frame)
	if frame.expBar then
		frame.expBar.bg = delFrame(frame.expBar.bg)
		frame.expBar.rest = delFrame(frame.expBar.rest)
		frame.expBar = delFrame(frame.expBar)
	end
end

function PitBull_ExperienceBar:OnUpdateStatusBarTexture(texture)
	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if frame.expBar and frame.expBar.bg and frame.expBar.rest then
			frame.expBar:SetStatusBarTexture(texture)
			frame.expBar.bg:SetTexture(texture)
			frame.expBar.rest:SetStatusBarTexture(texture)
		end
	end
	if showPet then
		for frame in PitBull:IterateUnitFramesForUnit("pet") do
			if frame.expBar and frame.expBar.bg and frame.expBar.rest then
				frame.expBar:SetStatusBarTexture(texture)
				frame.expBar.bg:SetTexture(texture)
				frame.expBar.rest:SetStatusBarTexture(texture)
			end
		end
	end
end

function PitBull_ExperienceBar:OnUnknownLayout(unit, frame, name)
	frame.expBar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
	frame.expBar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
	frame.expBar:SetHeight(20)
end

local function getDisabled(group)
	return self.db.profile[group].ignore
end
local function getEnabled(group)
	return not self.db.profile[group].ignore
end

local function setEnabled(group, value)
	self.db.profile[group].ignore = not value
	PitBull_ExperienceBar:UpdateExperience(group)
end

local function getDeficit(group)
	return PitBull_ExperienceBar.db.profile[group].deficit
end
local function setDeficit(group, value)
	PitBull_ExperienceBar.db.profile[group].deficit = value

	PitBull_ExperienceBar:UpdateExperience(group)
end
local function getReverse(group)
	return PitBull_ExperienceBar.db.profile[group].reverse
end
local function setReverse(group, value)
	PitBull_ExperienceBar.db.profile[group].reverse = value
	
	PitBull_ExperienceBar:UpdateExperience(group)
end


local function GetColor()
	return unpack(PitBull_ExperienceBar.db.profile.colors)
end

local function SetColor(r, g, b)
	PitBull_ExperienceBar.db.profile.colors = {r, g, b}
	
	PitBull_ExperienceBar:UpdateExperience()
end

local function GetBGColor()
	return unpack(PitBull_ExperienceBar.db.profile.bgColors)
end

local function SetBGColor(r, g, b)
	PitBull_ExperienceBar.db.profile.bgColors = {r, g, b}

	PitBull_ExperienceBar:UpdateExperience()
end

local function GetRestColor()
	return unpack(PitBull_ExperienceBar.db.profile.restColors)
end

local function SetRestColor(r, g, b)
	PitBull_ExperienceBar.db.profile.restColors = {r, g, b}
	
	PitBull_ExperienceBar:UpdateExperience()
end

PitBull.options.args.global.args.colors.args.experienceBar = {
	type = 'group',
	name = L["Experience"],
	desc = L["Set the colors for the experience bar."],
	args = {
		bar = {
			type = 'color',
			name = L["Color"],
			desc = L["Set the color for the experience bar."],
			get = GetColor,
			set = SetColor,
		},
		background = {
			type = 'color',
			name = L["Background color"],
			desc = L["Set the background color for the experience bar."],
			get = GetBGColor,
			set = SetBGColor,
		},
		resting = {
			type = 'color',
			name = L["Rest color"],
			desc = L["Set the color for rested experience on the bar."],
			get = GetRestColor,
			set = SetRestColor,
		},
	},
}

PitBull_ExperienceBar:RegisterPitBullOptionsMethod(function(group)
	if group == "player" or (showPet and group == "pet") then 
		return {
			name = L["Experience"],
			desc = L["Options for the units experience bar."],
			type = 'group',
			args = {
				ignore = {
					type = 'boolean',
					name = L["Enable"],
					desc = L["Enable the experience bar."],
					get = getEnabled,
					set = setEnabled,
					passValue = group,
					order = 1,
				},
				deficit = {
					type = 'boolean',
					name = L["Show as deficit"],
					desc = L["Show experience deficit, draining the bar when you gain experience."],
					get = getDeficit,
					set = setDeficit,
					passValue = group,
					disabled = getDisabled,
				},
				reverse = {
					type = 'boolean',
					name = L["Reverse"],
					desc = L["Reverses the direction of the experience bar, filling it from right to left."],
					get = getReverse,
					set = setReverse,
					passValue = group,
					disabled = getDisabled,
				},
			}
		}
	end
end)

