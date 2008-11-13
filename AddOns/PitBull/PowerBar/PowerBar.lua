if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_PowerBar = PitBull:NewModule("PowerBar", "LibRockEvent-1.0")
local self = PitBull_PowerBar
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show a mana/rage/energy/focus bar on the PitBull unit frames."] = "PitBull 유닛 프레임에 마나/분노/기력/집중 바를 표시합니다.",
	["Power"] = "마력",
	["Power bar display settings for this unit type."] = "이 유닛 유형을 위한 마력바 표시 설정",
	["Enable"] = "활성화",
	["Enables the power bar."] = "마력 바를 활성화합니다.",
	["Show as deficit"] = "결손치로 표시",
	["Show power deficit, filling the bar when you use up your power."] = "마력을 사용한 경우에 결손치로, 바를 채워 나가는 방식으로 마력을 표시합니다.",
	["Reverse"] = "반전",
	["Reverses the direction of the power bar, filling it from right to left."] = "마력바의 진행 방향을 뒤집어 우측에서 좌측으로 채워 나가는 방식으로 표시합니다.",
	["Hide non-mana"] = "비마나 숨김",
	["Hides the power bar if energy, rage, or focus is showing."] = "기력, 분노, 집중이 표시되고 있는 경우에 마력바를 숨깁니다.",
	["Hide non-power"] = "비마력 숨김",
	["Hides the power bar if the unit has no power."] = "유닛이 마력이 없는 경우에 마력바를 숨깁니다.",
	["Color by class"] = "직업별 색상",
	["Color the power bar by class instead of power type. Note: only colors if the unit is a player."] = "마력 유형 대신에 직업별로 마력 바를 색상 표시합니다. 주의: 유닛이 플레이어인 경우에만 색상 표시합니다.",
	["Custom Color"] = "사용자 색상",
	["Use custom colors for the power bars on this unit."] = "이 유닛에 대해 마력바를 위한 사용자 지정 색상을 사용합니다.",
	["Power Colors"] = "마력 색상",
	["Custom power bar colors."] = "사용자 지정 마력바 색상",
		["Rage"] = "분노",
		["Mana"] = "마나",
		["Focus(Pet)"] = "집중",
		["Energy"] = "기력",
	["Custom background color"] = "사용자 배경 색상",
	["Override dynamic background color calculation."] = "동적인 배경 색상 산출 무시",
	["Power background colors"] = "마력 배경 색상",
	["Custom power bar background colors."] = "사용자 지정 마력 바 배경 색상",
		["Rage Background"] = "분노 배경",
		["Mana Background"] = "마나 배경",
		["Focus Background"] = "집중 배경",
		["Energy Background"] = "기력 배경",
} or {}

local L = PitBull:L("PitBull-PowerBar", localization)

self.desc = L["Show a mana/rage/energy/focus bar on the PitBull unit frames."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local old_UnitPowerType = UnitPowerType
local function UnitPowerType(unit)
	local power = old_UnitPowerType(unit)
	if power ~= 0 then
		return power
	end
	local _,c = UnitClass(unit)
	if c == "ROGUE" then
		return 3
	elseif c == "WARRIOR" then
		return 1
	end
	return power
end
local ManaBarColor = ManaBarColor

PitBull_PowerBar:RegisterPitBullChildFrames('powerBar')

local unitsShown = {}

function PitBull_PowerBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("PowerBar")
	PitBull:SetDatabaseNamespaceDefaults("PowerBar", "profile", {
		['**'] = {
			deficit = false,
			reverse = false,
			hidden = false,
			
			colorByClass = false,
			
			customColor = false,
			customBGColor = false,
			customColors = {
				rage = PitBull.colorConstants.rage,
				energy = PitBull.colorConstants.energy,
				focus = PitBull.colorConstants.focus,
				mana = PitBull.colorConstants.mana,

				rageBG = { 11/255, 11/255, 11/255 },
				energyBG = { 11/255, 11/255, 11/255 },
				focusBG = { 11/255, 11/255, 11/255 },
				manaBG = { 11/255, 11/255, 11/255 },
			},
			
			hideNoMana = false,
			hideNoPower = false,
		},
		targettarget = {
			hidden = true,
		},
		targettargettarget = {
			hidden = true,
		},
		raid = {
			hideNoMana = true,
		},
	})
end

function PitBull_PowerBar:OnEnable(first)
	-- bucketed events
	self:AddEventListener({UNIT_MANA=true, UNIT_RAGE=true, UNIT_FOCUS=true, UNIT_ENERGY=true, UNIT_MAXMANA=true, UNIT_MAXRAGE=true, UNIT_MAXFOCUS=true, UNIT_MAXENERGY=true }, "UNIT_MANA", 0.05)
	self:AddEventListener("UNIT_DISPLAYPOWER", "UNIT_DISPLAYPOWER", 0.05)
end

function PitBull_PowerBar:UNIT_MANA(ns, event, units)
	for unit in pairs(units) do
		for frame in PitBull:IterateUnitFramesForUnit(unit) do
			if unitsShown[frame] then
				self:UpdatePowerValue(unit, frame)
			end
		end
	end
end

function PitBull_PowerBar:UNIT_DISPLAYPOWER(ns, event, units)
	for unit in pairs(units) do
		for frame in PitBull:IterateUnitFramesForUnit(unit) do
			if self.db.profile[frame.group].hideNoMana then
				if UnitPowerType(unit) == 0 then -- mana
					if not frame.powerBar then
						self:OnPopulateUnitFrame(unit, frame)
						PitBull:UpdateLayout(frame)
					end
				else -- not mana
					if frame.powerBar then
						self:OnClearUnitFrame(unit, frame)
						PitBull:UpdateLayout(frame)
					end
				end
			elseif self.db.profile[frame.group].hideNoPower then
				if UnitManaMax(unit) > 0 then -- has power
					if not frame.powerBar then
						self:OnPopulateUnitFrame(unit, frame)
						PitBull:UpdateLayout(frame)
					end
				else -- no power
					if frame.powerBar then
						self:OnClearUnitFrame(unit, frame)
						PitBull:UpdateLayout(frame)
					end
				end
			end
			self:UpdatePowerValue(unit, frame)
			self:UpdatePowerColor(unit, frame)
		end
	end
end

function PitBull_PowerBar:UpdatePowerValueAndColor(group)
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_PowerBar:UpdatePowerValue(unit, frame)
		PitBull_PowerBar:UpdatePowerColor(unit, frame)
	end
end

function PitBull_PowerBar:UpdatePowerValue(unit, frame)
	if not frame.powerBar then
		return
	end
	local db = self.db.profile[frame.group]
	
	local max = UnitManaMax(unit)
	if max > 0 then
		local value = UnitMana(unit)
		local perc = value / max
		if db.deficit ~= db.reverse then
			perc = 1 - perc
		end
		frame.powerBar:SetValue(perc)
	else	
		if db.deficit ~= db.reverse then
			frame.powerBar:SetValue(1)
		else
			frame.powerBar:SetValue(0)
		end
	end
end

function PitBull_PowerBar:UpdatePowerColor(unit, frame)
	if not frame.powerBar then
		return
	end
	local db = self.db.profile[frame.group]
	
	local powerType = UnitPowerType(unit)
	local r,g,b
	local br, bg, bb
	local customColor = db.customColor
	local customBGColor = db.customBGColor
	local colorByClass = db.colorByClass
	if colorByClass and UnitIsPlayer(unit) then
		local _,class = UnitClass(unit)
		r,g,b = unpack(PitBull.colorConstants[class])
	elseif powerType == 0 then
		if customColor then
			r,g,b = unpack(db.customColors.mana)
		else
			r,g,b = unpack(PitBull.colorConstants.mana)
		end
		if customBGColor then
			br,bg,bb = unpack(db.customColors.manaBG)
		end
	elseif powerType == 1 then
		if UnitManaMax(unit) == 0 then
			r,g,b = 0.2, 0.2, 0.2
		else
			if customColor then
				r,g,b = unpack(db.customColors.rage)
			else
				r,g,b = unpack(PitBull.colorConstants.rage)
			end
			if customBGColor then
				br,bg,bb = unpack(db.customColors.rageBG)
			end
		end
	elseif powerType == 2 then
		if customColor then
			r,g,b = unpack(db.customColors.focus)
		else
			r,g,b = unpack(PitBull.colorConstants.focus)
		end
		if customBGColor then
			br,bg,bb = unpack(db.customColors.focusBG)
		end
	elseif powerType == 3 then
		if customColor then
			r,g,b = unpack(db.customColors.energy)
		else
			r,g,b = unpack(PitBull.colorConstants.energy)
		end
		if customBGColor then
			br,bg,bb = unpack(db.customColors.energyBG)
		end
	else
		r,g,b = unpack(PitBull.colorConstants.unknown)
	end
	
	if not br then
		br,bg,bb = (r+0.2)/3, (g+0.2)/3, (b+0.2)/3
	end
	if db.reverse then
		frame.powerBar:SetStatusBarColor(br, bg, bb, 1)
		frame.powerBar.bg:SetVertexColor(r, g, b, 1)
	else
		frame.powerBar:SetStatusBarColor(r, g, b, 1)
		frame.powerBar.bg:SetVertexColor(br, bg, bb, 1)
	end
end

function PitBull_PowerBar:OnUpdateFrame(unit, frame)
	if self.db.profile[frame.group].hideNoMana then
		if UnitPowerType(unit) == 0 then -- mana
			if not frame.powerBar then
				self:OnPopulateUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		else -- not mana
			if frame.powerBar then
				self:OnClearUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end	
	elseif self.db.profile[frame.group].hideNoPower then
		if UnitManaMax(unit) > 0 then -- has power
			if not frame.powerBar then
				self:OnPopulateUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		else -- no power
			if frame.powerBar then
				self:OnClearUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end
	end
	if frame.powerBar and unitsShown[frame] then
		self:UpdatePowerValue(unit, frame)
		self:UpdatePowerColor(unit, frame)
	end
end

function PitBull_PowerBar:OnPopulateUnitFrame(unit, frame)
	if frame.powerBar or self.db.profile[frame.group].hidden then
		return
	end
	if self.db.profile[frame.group].hideNoMana then
	 	if UnitPowerType(unit) ~= 0 then
			return
		end
	elseif self.db.profile[frame.group].hideNoPower then
		if UnitManaMax(unit) == 0 then
			return
		end
	end
	local powerBar = newFrame("StatusBar", frame)
	frame.powerBar = powerBar
	powerBar:SetMinMaxValues(0, 1)
	powerBar:SetValue(1)
	powerBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	powerBar:SetStatusBarColor(0, 0, 1, 1)

	local powerBarBG = newFrame("Texture", powerBar, "BACKGROUND")
	frame.powerBar.bg = powerBarBG
	powerBarBG:SetTexture(PitBull:GetStatusBarTexture())
	powerBarBG:SetVertexColor(0, 0, 0.5, 1)
	powerBarBG:ClearAllPoints()
	powerBarBG:SetAllPoints(powerBar)
end

function PitBull_PowerBar:OnClearUnitFrame(unit, frame)
	if frame.powerBar then
		frame.powerBar.bg = delFrame(frame.powerBar.bg)
		frame.powerBar = delFrame(frame.powerBar)
	end
	unitsShown[frame] = nil
end

function PitBull_PowerBar:OnUpdateStatusBarTexture(texture)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.powerBar then
			frame.powerBar:SetStatusBarTexture(texture)
			frame.powerBar.bg:SetTexture(texture)
		end
	end
end

function PitBull_PowerBar:OnUnknownLayout(unit, frame, name)
	frame.powerBar:SetPoint("TOPLEFT", frame, "LEFT", 5, 0)
	frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
end

function PitBull_PowerBar:OnUpdateLayout(unit, frame)
	local old = not unitsShown[frame]
	local now = not frame.powerBar or not frame.powerBar:IsShown()
	if old == now then
		return
	end
	unitsShown[frame] = not now
	if not now then
		self:OnUpdateFrame(unit, frame)
	end
end

local function getDeficit(group)
	return PitBull_PowerBar.db.profile[group].deficit
end
local function setDeficit(group, value)
	PitBull_PowerBar.db.profile[group].deficit = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_PowerBar:UpdatePowerValue(unit, frame)
	end
end
local function getReverse(group)
	return PitBull_PowerBar.db.profile[group].reverse
end
local function setReverse(group, value)
	PitBull_PowerBar.db.profile[group].reverse = value
	PitBull_PowerBar:UpdatePowerValueAndColor(group)
end
local function getDisabled(group)
	return PitBull_PowerBar.db.profile[group].hidden
end
local function getEnabled(group)
	return not PitBull_PowerBar.db.profile[group].hidden
end
local function setEnabled(group, value)
	value = not value
	PitBull_PowerBar.db.profile[group].hidden = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		if value then
			self:OnClearUnitFrame(unit, frame)
		else
			self:OnPopulateUnitFrame(unit, frame)
			self:OnUpdateFrame(unit, frame)
		end
		PitBull:UpdateLayout(frame)
	end
end

local function getColorByClass(group)
	return PitBull_PowerBar.db.profile[group].colorByClass
end

local function setColorByClass(group, value)
	PitBull_PowerBar.db.profile[group].colorByClass = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		self:UpdatePowerColor(unit, frame)
	end
end

local function getHideNoMana(group)
	return PitBull_PowerBar.db.profile[group].hideNoMana
end
local function setHideNoMana(group, value)
	PitBull_PowerBar.db.profile[group].hideNoMana = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		if UnitPowerType(unit) ~= 0 then
			if value then
				self:OnClearUnitFrame(unit, frame)
			else
				self:OnPopulateUnitFrame(unit, frame)
				self:OnUpdateFrame(unit, frame)
			end
			PitBull:UpdateLayout(frame)
		end
	end
end

local function getHideNoPower(group)
	return PitBull_PowerBar.db.profile[group].hideNoPower
end
local function setHideNoPower(group, value)
	PitBull_PowerBar.db.profile[group].hideNoPower = value
	
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		if UnitManaMax(unit) == 0 then
			if value then
				self:OnClearUnitFrame(unit, frame)
			else
				self:OnPopulateUnitFrame(unit, frame)
				self:OnUpdateFrame(unit, frame)
			end
			PitBull:UpdateLayout(frame)
		end
	end
end

local function getColor(gk)
	return unpack(PitBull_PowerBar.db.profile[gk[1]].customColors[gk[2]])
end
local function setColor(gk, r, g, b, a)
	local t = PitBull_PowerBar.db.profile[gk[1]].customColors[gk[2]]
	t[1] = r
	t[2] = g
	t[3] = b
	t[4] = a
	PitBull_PowerBar:UpdatePowerValueAndColor(gk[1])
end
PitBull_PowerBar:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Power"],
		desc = L["Power bar display settings for this unit type."],
		type = 'group',
		args = {
			enable = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the power bar."],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
				order = 1,
			},
			deficit = {
				type = 'boolean',
				name = L["Show as deficit"],
				desc = L["Show power deficit, filling the bar when you use up your power."],
				get = getDeficit,
				set = setDeficit,
				passValue = group,
				disabled = getDisabled,
			},
			reverse = {
				type = 'boolean',
				name = L["Reverse"],
				desc = L["Reverses the direction of the power bar, filling it from right to left."],
				get = getReverse,
				set = setReverse,
				passValue = group,
				disabled = getDisabled,
			},
			hideNoMana = {
				type = 'boolean',
				name = L["Hide non-mana"],
				desc = L["Hides the power bar if energy, rage, or focus is showing."],
				get = getHideNoMana,
				set = setHideNoMana,
				passValue = group,
				disabled = getDisabled,
			},
			hideNoPower = group:find("target$") and {
				type = 'boolean',
				name = L["Hide non-power"],
				desc = L["Hides the power bar if the unit has no power."],
				get = getHideNoPower,
				set = setHideNoPower,
				passValue = group,
				disabled = getDisabled,
			} or nil,
			colorByClass = {
				type = 'boolean',
				name = L["Color by class"],
				desc = L["Color the power bar by class instead of power type. Note: only colors if the unit is a player."],
				get = getColorByClass,
				set = setColorByClass,
				passValue = group,
				disabled = getDisabled,
			},
			customColor = {
				name = L["Custom Color"],
				desc = L["Use custom colors for the power bars on this unit."],
				type = 'boolean',
				order = 1200,
				get = function(group) return PitBull_PowerBar.db.profile[group].customColor end,
				set = function(group, value)
					PitBull_PowerBar.db.profile[group].customColor = value
					PitBull_PowerBar:UpdatePowerValueAndColor(group)
				end,
				passValue = group,
				disabled = getDisabled,
			},
			customColors = {
				name = L["Power Colors"],
				desc = L["Custom power bar colors."],
				type = 'group',
				order = 1201,
				disabled = function(group) return getDisabled(group) or not PitBull_PowerBar.db.profile[group].customColor end,
				passValue = group,
				args = {
					rage = {
						passValue = { group, "rage" },
						get = getColor,
						set = setColor,
						name = L["Rage"],
						desc = L["Rage"],
						type = 'color'
					},
					mana = {
						passValue = { group, "mana" },
						get = getColor,
						set = setColor,
						name = L["Mana"],
						desc = L["Mana"],
						type = 'color'
					},
					focus = {
						passValue = { group, "focus" },
						get = getColor,
						set = setColor,
						name = L["Focus(Pet)"],
						desc = L["Focus(Pet)"],
						type = 'color'
					},
					energy = {
						passValue = { group, "energy" },
						get = getColor,
						set = setColor,
						name = L["Energy"],
						desc = L["Energy"],
						type = 'color'
					},
				},
			},
			customBGColor = {
				name = L["Custom background color"],
				desc = L["Override dynamic background color calculation."],
				type = 'boolean',
				order = 1202,
				get = function(group) return PitBull_PowerBar.db.profile[group].customBGColor end,
				set = function(group, value)
					PitBull_PowerBar.db.profile[group].customBGColor = value
					PitBull_PowerBar:UpdatePowerValueAndColor(group)
				end,
				disabled = getDisabled,
				passValue = group
			},
			customBGColors = {
				name = L["Power background colors"],
				desc = L["Custom power bar background colors."],
				type = 'group',
				order = 1203,
				disabled = function(group) return getDisabled(group) or not PitBull_PowerBar.db.profile[group].customBGColor end,
				passValue = group,
				args = {
					rageBG = {
						passValue = { group, "rageBG" },
						get = getColor,
						set = setColor,
						name = L["Rage Background"],
						desc = L["Rage Background"],
						type = 'color'
					},
					manaBG = {
						passValue = { group, "manaBG" },
						get = getColor,
						set = setColor,
						name = L["Mana Background"],
						desc = L["Mana Background"],
						type = 'color'
					},
					focusBG = {
						passValue = { group, "focusBG" },
						get = getColor,
						set = setColor,
						name = L["Focus Background"],
						desc = L["Focus Background"],
						type = 'color'
					},
					energyBG = {
						passValue = { group, "energyBG" },
						get = getColor,
						set = setColor,
						name = L["Energy Background"],
						desc = L["Energy Background"],
						type = 'color'
					},
				},
			},
		}
	}
end)

