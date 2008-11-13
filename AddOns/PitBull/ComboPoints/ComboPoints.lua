if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local _,playerClass = UnitClass("player")
if playerClass ~= "ROGUE" and playerClass ~= "DRUID" then
	return
end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_ComboPoints = PitBull:NewModule("ComboPoints", "LibRockEvent-1.0")
local self = PitBull_ComboPoints
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show combo points on the unit frame if you are a Rogue or Druid in Cat form."]= "도적 혹은 드루이드의 표범 변신 상태인 경우에 유닛 프레임에 콤보 포인트를 표시합니다.",
	["Combo points"] = "콤보 포인트",
	["Options for the combo point display."] = "콤보 포인트 표시를 위한 옵션",
	["Enable"] = "활성화",
	["Enable combo point display."] = "콤보 포인트 표시 기능을 활성화합니다.",
	["Texture"] = "텍스쳐",
	["Set what texture to use for the combo points."] = "콤보 포인트에 사용할 텍스쳐를 설정합니다.",
	["Default"] = "기본",
	["Bar"] = "바",
} or {}

local L = PitBull:L("PitBull-ComboPoints", localization)

self.desc = L["Show combo points on the unit frame if you are a Rogue or Druid in Cat form."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local combo_path = "Interface\\AddOns\\" .. debugstack():match("[d%.][d%.][O%.]ns\\(.-)\\[A-Za-z]-%.lua") .. "\\combo"

PitBull_ComboPoints:RegisterPitBullChildFrames('comboPoints')

function PitBull_ComboPoints:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("ComboPoints")
	
	PitBull:SetDatabaseNamespaceDefaults("ComboPoints", "profile", {
		texture = "default",
	})
end

function PitBull_ComboPoints:OnEnable()
	self:AddEventListener("PLAYER_COMBO_POINTS")
end

local configMode = PitBull.configMode

function PitBull_ComboPoints:OnChangeConfigMode(value)
	configMode = value
	self:UpdateComboPoints()
end

function PitBull_ComboPoints:PLAYER_COMBO_POINTS()
	return self:UpdateComboPoints()
end

function PitBull_ComboPoints:UpdateComboPoints(frame)
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit("target") do
			self:UpdateComboPoints(frame)
		end
		return
	end
	if frame.comboPoints then
		local p = configMode and 5 or GetComboPoints()
		for i = 1, 5 do
			if p >= i then
				frame.comboPoints["combo"..i]:Show()
			else
				frame.comboPoints["combo"..i]:Hide()
			end
		end
		frame.comboPoints:Show()
	end
end

function PitBull_ComboPoints:OnUpdateFrame(unit, frame)
	if unit == "target" then
		self:UpdateComboPoints(frame)
	end
end

function PitBull_ComboPoints:OnPopulateUnitFrame(unit, frame)
	if not self.db.profile.ignore and unit == "target" then
		local comboPoints = newFrame("Frame", frame.overlay, "OVERLAY")
		frame.comboPoints = comboPoints
		for i = 1, 5 do
			local combo = newFrame("Texture", frame.comboPoints, "OVERLAY")
			comboPoints["combo"..i] = combo
			if self.db.profile.texture == "default" then
				combo:SetTexture(combo_path)
				combo:SetWidth(10)
				combo:SetHeight(10)
			else
				combo:SetTexture(PitBull:GetStatusBarTexture())
				combo:SetWidth(5)
				combo:SetHeight(8)
			end
		end
	end
end

function PitBull_ComboPoints:OnClearUnitFrame(unit, frame)
	if frame.comboPoints then
		for i = 1, 5 do
			frame.comboPoints["combo"..i] = delFrame( frame.comboPoints["combo"..i] )
		end
		frame.comboPoints = delFrame(frame.comboPoints)
	end
end

function PitBull_ComboPoints:OnUnknownLayout(unit, frame, combo)
	if frame.comboPoints and combo == "comboPoints" then
		frame.comboPoints:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 0)
		frame.comboPoints:SetWidth( 50 )
		frame.comboPoints:SetHeight( 10 )
		for i = 1, 5 do
			local combo = frame.comboPoints["combo"..i]
			combo:ClearAllPoints()
			if i == 1 then
				combo:SetPoint("RIGHT", frame.comboPoints, "RIGHT")
			else
				combo:SetPoint("RIGHT", frame.comboPoints["combo"..(i-1)], "LEFT")
			end			
		end
	end
end

local function comboTexture_get()
	return self.db.profile.texture
end
local function comboTexture_set(value)
	self.db.profile.texture = value
	for unit, frame in PitBull:IterateUnitFramesByGroup("target") do
		if frame.comboPoints then
			for i = 1, 5 do
				local combo = frame.comboPoints["combo" .. i]
				if combo then
					if value == "default" then
						combo:SetTexture(combo_path)
						combo:SetWidth(10)
						combo:SetHeight(10)
					else
						combo:SetTexture(PitBull:GetStatusBarTexture())
						combo:SetWidth(5)
						combo:SetHeight(8)
					end
				end
			end
		end
		PitBull:UpdateLayout(frame)
	end
end

local function getDisabled(group)
	return self.db.profile.ignore
end
local function getEnabled(group)
	return not self.db.profile.ignore
end
local function setEnabled(group, value)
	value = not value
	self.db.profile.ignore = value
	if value then
		for unit, frame in PitBull:IterateUnitFramesByGroup("target") do
			self:OnClearUnitFrame(unit, frame)
		end
	else
		for unit, frame in PitBull:IterateUnitFramesByGroup("target") do
			if not frame.combatText then
				self:OnPopulateUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end
	end
end

PitBull_ComboPoints:RegisterPitBullOptionsMethod(function(group)
	if group == "target" then
		return {
			type = 'group',
			name = "Combo points",
			desc = "Options for the combo point display.",
			args = {
				enable = {
					type = 'boolean',
					name = L["Enable"],
					desc = L["Enable combo point display."],
					get = getEnabled,
					set = setEnabled,
					passValue = group,
					order = 1,
				},			
				texture = {
					name = L["Texture"],
					desc = L["Set what texture to use for the combo points."],
					type = 'choice',
					choices = {
						default = L["Default"],
						bar = L["Bar"],
					},
					get = comboTexture_get,
					set = comboTexture_set,
					disabled = getDisabled,
				}
			}
		}
	end
end)