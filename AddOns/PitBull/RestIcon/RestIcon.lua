if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_RestIcon = PitBull:NewModule("RestIcon", "LibRockEvent-1.0")
local self = PitBull_RestIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an icon on the unit frame when the unit is resting in an inn or city."] = "유닛이 여관 혹은 대도시에서 휴식중인 경우에 유닛 프레임에 아이콘을 표시합니다.",
	["Resting"] = "휴식중",
	["Options for the resting icon."] = "휴식 아이콘을 위한 옵션",
	["Enable"] = "활성화",
	["Enables the icon indicating whether or not the player is currently resting."] = "플레이어의 현재 휴식 여부를 가리키는 아이콘을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-RestIcon", localization)

self.desc = L["Show an icon on the unit frame when the unit is resting in an inn or city."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_RestIcon:RegisterPitBullChildFrames('restIcon')

function PitBull_RestIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("RestIcon")
	PitBull:SetDatabaseNamespaceDefaults("RestIcon", "profile", {
		disable = false,
	})
end

function PitBull_RestIcon:OnEnable()
	self:AddEventListener("PLAYER_UPDATE_RESTING")
	self:AddEventListener("PLAYER_ENTERING_WORLD", "PLAYER_UPDATE_RESTING")
end

local configMode = PitBull.configMode

function PitBull_RestIcon:OnChangeConfigMode(value)
	configMode = value
	self:PLAYER_UPDATE_RESTING()
end

function PitBull_RestIcon:PLAYER_UPDATE_RESTING(ns, event, frame)
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			self:PLAYER_UPDATE_RESTING(ns, event, frame)
		end
		return
	end
	
	local resting = configMode or IsResting()
	if resting and not self.db.profile.disable then
		if not frame.restIcon then
			frame.restIcon = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.restIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
			frame.restIcon:SetTexCoord(0.09, 0.43, 0.08, 0.42)
			frame.restIcon:Hide()
			PitBull:UpdateLayout(frame)
		end
	else
		if frame.restIcon then
			frame.restIcon = delFrame(frame.restIcon)
			
			PitBull:UpdateLayout(frame)
		end
	end
end

function PitBull_RestIcon:OnUpdateFrame(unit, frame)
	if unit == "player" then
		self:PLAYER_UPDATE_RESTING(ns, event, frame)
	end
end

function PitBull_RestIcon:OnClearUnitFrame(unit, frame)
	if frame.restIcon then
		frame.restIcon = delFrame(frame.restIcon)
	end
end

function PitBull_RestIcon:OnUnknownLayout(unit, frame)
	if frame.combatIcon then
		frame.restIcon:SetPoint("LEFT", frame.combatIcon, "RIGHT", 4, 0)
	else
		frame.restIcon:SetPoint("CENTER", frame, "BOTTOMLEFT", 0, 0)
	end
	frame.restIcon:SetWidth(18)
	frame.restIcon:SetHeight(18)
end

PitBull_RestIcon:RegisterPitBullOptionsMethod(function(group)
	if group ~= "player" then
		return
	end
	return {
		type = 'group',
		name = L["Resting"],
		desc = L["Options for the resting icon."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the icon indicating whether or not the player is currently resting."],
				get = function()
					return not self.db.profile.disable
				end,
				set = function(value)
					self.db.profile.disable = not value
					self:PLAYER_UPDATE_RESTING()
				end,
			}
		}
	}
end)
