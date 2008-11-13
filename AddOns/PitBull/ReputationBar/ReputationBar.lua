if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_ReputationBar = PitBull:NewModule("ReputationBar", "LibRockHook-1.0")
local self = PitBull_ReputationBar
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an reputation bar on the unit frame."] = "유닛 프레임에 평판바를 표시합니다.",
	["Reputation"] = "평판",
	["Options for the units reputation bar."] = "유닛의 평판바를 위한 옵션",
	["Enable"] = "활성화",
	["Enable the reputation bar."] = "평판바를 활성화합니다.",
	["Auto hide"] = "자동 숨김",
	["Hide the reputation bar when no faction is selected."] = "진영을 선택하지 않은 경우에 평판바를 숨깁니다.",
	["Show as deficit"] = "결손치로 표시",
	["Show reputation deficit, draining the bar when you gain reputation."] = "평판을 획듯한 경우에 평판을 결손치로, 빠져 나가는 방식으로 표시합니다.",
	["Reverse"] = "반전",
	["Reverses the direction of the reputation bar, filling it from right to left."] = "평판바의 진행 방향을 뒤집어 우측에서 좌측으로 채워 나가는 방식으로 표시합니다.",
	["Custom color"] = "사용자 색상",
	["Set a custom color for the reputation bar."] = "평판바를 위해 사용자 지정 색상을 설정합니다.",
	["Enable"] = "활성화",
	["Enable using a custom color for the reputation bar."] = "평판바를 위해 사용자 지정 색상 사용 기능을 활성화합니다.",
	["Color"] = "색상",
	["Set the custom color for the reputation bar."] = "평판바를 위해 사용자 지정 색상을 설정합니다.",
	["Custom background color"] = "사용자 배경 색상",
	["Set a custom background color for the reputation bar."] = "평판바를 위해 사용자 지정 배경 색상을 설정합니다.",
	["Enable"] = "활성화",
	["Enable using a custom background color for the reputation bar."] = "평판바를 위해 사용자 지정 배경 색상 사용 기능을 활성화합니다.",
	["Color"] = "색상",
	["Set the custom background color for the reputation bar."] = "평판바를 위해 사용자 지정 배경 색상을 설정합니다.",
} or {}

local L = PitBull:L("PitBull-ReputationBar", localization)

self.desc = L["Show an reputation bar on the unit frame."]

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

PitBull_ReputationBar:RegisterPitBullChildFrames('repBar')

function PitBull_ReputationBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("ReputationBar")
	PitBull:SetDatabaseNamespaceDefaults("ReputationBar", "profile", {
		ignore = true,
		autoHide = false,
		backgroundColor = { 1, 0, 0 },
		deficit = false,
		reverse = false,
		customColor = false,
		customColors = {1,1,1},
		customBGColor = false,
		customBGColors = {11/255, 11/255, 11/255},
	})
end

local repname, repreaction, repmin, repmax, repvalue = nil, 0, 0, 0, 0

function PitBull_ReputationBar:UpdateReputation(frame)
	if type(frame) ~= "table" then
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			self:UpdateReputation(frame)
		end
		return
	end
	if self.db.profile.ignore then
		if frame.repBar then
			PitBull_ReputationBar:OnClearUnitFrame("player", frame)
			PitBull:UpdateLayout(frame)
		end
		return
	else
		if not frame.repBar then
			PitBull_ReputationBar:OnPopulateUnitFrame("player", frame)
			PitBull:UpdateLayout(frame)
		end
	end
	repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		if not frame.repBar then
			self:OnPopulateUnitFrame("player", frame)
			PitBull:UpdateLayout(frame)
		end
		repmax = repmax - repmin
		repvalue = repvalue - repmin
		repmin = 0
		if self.db.profile.deficit ~= self.db.profile.reverse then
			frame.repBar:SetValue((repmax - repvalue) / (repmax - repmin))
		else
			frame.repBar:SetValue(repvalue / (repmax - repmin))
		end
		local color = repColor[repreaction]
		local r, g, b
		if self.db.profile.customColor then
			r, g, b = unpack(self.db.profile.customColors)
		else
			r, g, b = color.r, color.g, color.b
		end
		local br, bg, bb
		if self.db.profile.customBGColor then
			br, bg, bb = unpack(self.db.profile.customBGColors)
		else
			br, bg, bb = (r+0.2)/3, (g+0.2)/3, (b+0.2)/3
		end
		if self.db.profile.reverse then
			frame.repBar:SetStatusBarColor(br, bg, bb, 1)
			frame.repBar.bg:SetVertexColor(r, g, b, 1)
		else
			frame.repBar:SetStatusBarColor(r, g, b, 1)
			frame.repBar.bg:SetVertexColor(br, bg, bb, 1)
		end
	else
		if self.db.profile.autoHide then
			if frame.repBar then
				PitBull_ReputationBar:OnClearUnitFrame("player", frame)
				PitBull:UpdateLayout(frame)
			end
		else
			if frame.repBar then
				self:OnPopulateUnitFrame("player", frame)
				PitBull:UpdateLayout(frame)
			end
			frame.repBar.bg:SetVertexColor(unpack(self.db.profile.backgroundColor))
			frame.repBar:SetValue(0)
		end
	end
end

function PitBull_ReputationBar:OnEnable(first)
	if not self:HasHook("ReputationWatchBar_Update") then
		self:AddSecureHook("ReputationWatchBar_Update", "UpdateReputation")
	end
end

function PitBull_ReputationBar:OnUpdateFrame(unit, frame)
	if unit == "player" then
		self:UpdateReputation(frame)
	end
end

function PitBull_ReputationBar:OnPopulateUnitFrame(unit, frame)
	if frame.repBar or self.db.profile.ignore then
		return 
	end
	if unit == "player" then
		local repBar = newFrame("StatusBar", frame)
		frame.repBar = repBar
		repBar:SetParent(frame)
		repBar:SetMinMaxValues(0, 1)
		repBar:SetValue(0.5)
		repBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
		repBar:SetStatusBarColor(0, 1, 0, 1)

		local repBarBG = newFrame("Texture", frame.repBar, "BACKGROUND")
		frame.repBar.bg = repBarBG
		repBarBG:SetTexture(PitBull:GetStatusBarTexture())
		repBarBG:SetVertexColor(unpack(self.db.profile.backgroundColor))
		repBarBG:ClearAllPoints()
		repBarBG:SetAllPoints(repBar)
	end
end

function PitBull_ReputationBar:OnClearUnitFrame(unit, frame)
	if frame.repBar then
		frame.repBar.bg = delFrame(frame.repBar.bg)
		frame.repBar = delFrame(frame.repBar)
	end
end

function PitBull_ReputationBar:OnUpdateStatusBarTexture(texture)
	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if frame.repBar and frame.repBar.bg then
			frame.repBar:SetStatusBarTexture(texture)
			frame.repBar.bg:SetTexture(texture)
		end
	end
end

function PitBull_ReputationBar:OnUnknownLayout(unit, frame, name)
	frame.repBar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
	frame.repBar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
	frame.repBar:SetHeight(20)
	frame.repBar.bg:SetAllPoints(frame.repBar)
end

local function getDisabled()
	return self.db.profile.ignore
end

local function getEnabled()
	return not self.db.profile.ignore
end

local function setEnabled(value)
	self.db.profile.ignore = not value
	PitBull_ReputationBar:UpdateReputation()
end

local function getAutoHide()
	return self.db.profile.autoHide
end

local function setAutoHide(value)
	self.db.profile.autoHide = value
	PitBull_ReputationBar:UpdateReputation()
end

local function getDeficit()
	return PitBull_ReputationBar.db.profile.deficit
end
local function setDeficit(value)
	PitBull_ReputationBar.db.profile.deficit = value
	
	PitBull_ReputationBar:UpdateReputation()
end
local function getReverse()
	return PitBull_ReputationBar.db.profile.reverse
end
local function setReverse(value)
	PitBull_ReputationBar.db.profile.reverse = value
	
	PitBull_ReputationBar:UpdateReputation()
end


local function GetCustomColorToggle()
	return PitBull_ReputationBar.db.profile.customColor
end

local function SetCustomColorToggle(value)
	PitBull_ReputationBar.db.profile.customColor = value
	
	PitBull_ReputationBar:UpdateReputation()
end

local function GetCustomColor()
	return unpack(PitBull_ReputationBar.db.profile.customColors)
end

local function SetCustomColor(r, g, b)
	PitBull_ReputationBar.db.profile.customColors = {r, g, b}
	
	PitBull_ReputationBar:UpdateReputation()
end

local function GetCustomBGColorToggle()
	return PitBull_ReputationBar.db.profile.customBGColor
end

local function SetCustomBGColorToggle(value)
	PitBull_ReputationBar.db.profile.customBGColor = value
	
	PitBull_ReputationBar:UpdateReputation()
end

local function GetCustomBGColor()
	return unpack(PitBull_ReputationBar.db.profile.customBGColors)
end

local function SetCustomBGColor(r, g, b)
	PitBull_ReputationBar.db.profile.customBGColors = {r, g, b}
	
	PitBull_ReputationBar:UpdateReputation()
end

PitBull_ReputationBar:RegisterPitBullOptionsMethod(function(group)
	if group == "player" then 
		return {
			name = L["Reputation"],
			desc = L["Options for the units reputation bar."],
			type = 'group',
			args = {
				ignore = {
					type = 'boolean',
					name = L["Enable"],
					desc = L["Enable the reputation bar."],
					get = getEnabled,
					set = setEnabled,
					order = 1,
				},
				autoHide = {
					type = 'boolean',
					name = L["Auto hide"],
					desc = L["Hide the reputation bar when no faction is selected."],
					get = getAutoHide,
					set = setAutoHide,
					disabled = getDisabled,
				},
				deficit = {
					type = 'boolean',
					name = L["Show as deficit"],
					desc = L["Show reputation deficit, draining the bar when you gain reputation."],
					get = getDeficit,
					set = setDeficit,
					disabled = getDisabled,
				},
				reverse = {
					type = 'boolean',
					name = L["Reverse"],
					desc = L["Reverses the direction of the reputation bar, filling it from right to left."],
					get = getReverse,
					set = setReverse,
					disabled = getDisabled,
				},
				customColor = {
					type = 'group',
					name = L["Custom color"],
					desc = L["Set a custom color for the reputation bar."],
					disabled = getDisabled,
					args = {
						Enable = {
							type = 'boolean',
							name = L["Enable"],
							desc = L["Enable using a custom color for the reputation bar."],
							get = GetCustomColorToggle,
							set = SetCustomColorToggle,
						},
						setColor = {
							type = 'color',
							name = L["Color"],
							desc = L["Set the custom color for the reputation bar."],
							get = GetCustomColor,
							set = SetCustomColor,
							disabled = function() return not GetCustomColorToggle() end,
						},
					},
				},
				customBGColor = {
					type = 'group',
					name = L["Custom background color"],
					desc = L["Set a custom background color for the reputation bar."],
					disabled = getDisabled,
					args = {
						Enable = {
							type = 'boolean',
							name = L["Enable"],
							desc = L["Enable using a custom background color for the reputation bar."],
							get = GetCustomBGColorToggle,
							set = SetCustomBGColorToggle,
						},
						setColor = {
							type = 'color',
							name = L["Color"],
							desc = L["Set the custom background color for the reputation bar."],
							get = GetCustomBGColor,
							set = SetCustomBGColor,
							disabled = function() return not GetCustomBGColorToggle() end,
						},
					},
				},
			}
		}
	else
		return
	end
end)
