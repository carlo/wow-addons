if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

if select(2, UnitClass("player")) ~= "DRUID" then
	return
end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_DruidManaBar = PitBull:NewModule("DruidManaBar", "LibRockEvent-1.0", "LibRockTimer-1.0")
local self = PitBull_DruidManaBar
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show a mana bar for your Druid when in Cat or Bear form."] = "드루이드의 표범 혹은 곰 변신 상태인 경우를 위한 마나바를 표시합니다.",
	["Druid mana"] = "드루이드 마나",
	["Druid mana display settings for this unit type."] = "이 유닛 유형을 위한 드루이드 마나 표시 설정",
	["Show as deficit"] = "결손치로 표시",
	["Show druid's mana deficit, filling the bar when you use up your druidMana."] = "드루이드의 마나를 결손치로, 바를 채워 나가는 방식으로 표시합니다.",
	["Reverse"] = "뒤집기",
	["Reverses the direction of the druid mana bar, filling it from right to left."] = "드루이드 마나바의 진행 방향을 뒤집어 우측에서 좌측으로 채워 나가는 방식으로 표시합니다",
	["Enable"] = "활성화",
	["Enables the druid mana bar."] = "드루이드 마나바를 활성화합니다.",
	["Text style"] = "문자 양식",
	["Choose what kind of text to show on the druid bar"] = "드루이드 마나바에 표시할 문자의 종류를 선택합니다.",
} or {}

local L = PitBull:L("PitBull-DruidManaBar", localization)

self.desc = L["Show a mana bar for your Druid when in Cat or Bear form."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local UnitPowerType = UnitPowerType

PitBull_DruidManaBar:RegisterPitBullModuleDependencies("PowerBar")
PitBull_DruidManaBar:RegisterPitBullChildFrames('druidManaBar', 'druidManaText')

local unitsShown = {}

local Gratuity

function PitBull_DruidManaBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("DruidManaBar")
	PitBull:SetDatabaseNamespaceDefaults("DruidManaBar", "profile", {
		deficit = false,
		reverse = false,
		hidden = false,
		textStyle = "Absolute",
	})
end

local regenMana, maxMana, currMana, currInt, fiveSecondRule

local textStyles = {
	["Absolute"] = function()
		if currMana == maxMana then
			return ""
		end
		return currMana .. "/" .. maxMana
	end,
	["Percentage"] = function()
		if currMana == maxMana then
			return ""
		end
		return ("%.0f%%"):format(currMana / maxMana * 100)
	end,
	["Absolute and Percentage"] = function()
		if currMana == maxMana then
			return ""
		end
		return ("%d/%d || %.0f%%"):format(currMana, maxMana, currMana / maxMana * 100)
	end,
	["Hide"] = function()
		return "" 
	end,
}

function PitBull_DruidManaBar:OnEnable(first)
	Gratuity = Rock("LibGratuity-3.0", false, true)
	if not Gratuity then
		error("PitBull_DruidManaBar requires the library LibGratuity-3.0 to be available.")
	end
	
	self:LEARNED_SPELL_IN_TAB()
	
	if UnitPowerType("player") == 0 then
		maxMana = UnitManaMax("player")
		currMana = UnitMana("player")
		_, currInt  = UnitStat("player", 4)
		self:Events()
		self:Update()
	else
		self:AddEventListener("UNIT_DISPLAYPOWER", "WaitForShapeshift")
	end
	
end

function PitBull_DruidManaBar:WaitForShapeshift(na, event, arg1)
	if arg1 ~= "player" then 
		return
	end
	
	self:RemoveEventListener("UNIT_DISPLAYPOWER")
	maxMana = UnitManaMax("player")
	currMana = UnitMana("player")
	_, currInt  = UnitStat("player", 4)
	self:Events()
	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if frame.druidManaBar then
			self:OnClearUnitFrame("player", frame)
			PitBull:UpdateLayout(frame)
		end
	end
	self:Update()
end

function PitBull_DruidManaBar:Events()
	self:AddEventListener("UNIT_MANA")
	self:AddEventListener("UNIT_MAXMANA")
	self:AddEventListener("UNIT_INVENTORY_CHANGED", "UNIT_MAXMANA")
	self:AddEventListener("UNIT_DISPLAYPOWER")
	self:AddEventListener("LEARNED_SPELL_IN_TAB")
	self:AddEventListener("PLAYER_ENTERING_WORLD")
	self:AddEventListener("PLAYER_LEAVING_WORLD")
end

function PitBull_DruidManaBar:PLAYER_ENTERING_WORLD()
	if UnitPowerType("player") ~= 0 then
		self:AddTimer("PitBull_DruidManaBar-SetMax", 7, "SetMax")
	end
end

function PitBull_DruidManaBar:PLAYER_LEAVING_WORLD()
	self:RemoveAllTimers()
end

function PitBull_DruidManaBar:UNIT_MANA(ns, event, arg1)
	if arg1 ~= "player" then
		return
	end
	
	if UnitPowerType("player") == 0 then
		currMana = UnitMana("player")
		maxMana = UnitManaMax("player")
		self:Update()
	else
		if regenMana and not self:HasTimer("PitBull_DruidManaBar-UpdateMana") then
			--Update mana every 2 seconds
			self:UpdateMana()
			self:AddRepeatingTimer("PitBull_DruidManaBar-UpdateMana", 2, "UpdateMana")
		end
		--if mana hasn't been updated for 7 seconds, set current mana to the max mana
		self:AddTimer("PitBull_DruidManaBar-SetMax", 7, "SetMax")
	end
end

function PitBull_DruidManaBar:UNIT_MAXMANA(ns, event, arg1)
	if arg1 ~= "player" then 
		return
	end
	
	local _, int  = UnitStat("player", 4)
	if UnitPowerType("player") == 0 then
		maxMana = UnitManaMax("player")
		currMana = UnitMana("player")
		currInt = int
	elseif currInt ~= int then
		maxMana = maxMana + ((int - currInt) * 15)
		currInt = int
		if currMana > maxMana then
			currMana = maxMana
		end
	end
	
	self:Update()
end

local getShapeshiftCost

local function killFSR()
	fiveSecondRule = false
end

function PitBull_DruidManaBar:UNIT_DISPLAYPOWER(ns, event, arg1)
	if arg1 ~= "player" then
		return
	end
	
	if UnitPowerType("player") == 0 then
		regenMana = false
		self:RemoveAllTimers()
		currMana = UnitMana("player")
		maxMana = UnitManaMax("player")
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			if frame.druidManaBar then
				self:OnClearUnitFrame("player", frame)
				PitBull:UpdateLayout(frame)
			end
		end
	else
		regenMana = true
		fiveSecondRule = true
		self:AddTimer("PitBull_DruidManaBar-FSR", 5, killFSR)
		currMana = currMana - getShapeshiftCost()
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			if not frame.druidManaBar then
				self:OnPopulateUnitFrame("player", frame)
				if frame.druidManaBar then
					PitBull:UpdateLayout(frame)
				end
			end
		end
	end
	
	self:Update()
end

local bearID
function getShapeshiftCost()
	Gratuity:SetSpell(bearID, BOOKTYPE_SPELL)
	local line = Gratuity:GetLine(2)
	if line then
		line = tonumber(line:match("(%d+)"))
	end
	return line or 0
end

--finds the spell ID of Bear Form
function PitBull_DruidManaBar:LEARNED_SPELL_IN_TAB()
	for i = 1, GetNumSpellTabs() do
		local _, texture, offset, numSpells = GetSpellTabInfo(i)
		if texture:find("Ability_Racial_BearForm") then
			for j = offset + 1, offset + numSpells do
				if GetSpellTexture(j, BOOKTYPE_SPELL):find("Ability_Racial_BearForm") then
					bearID = j
					break
				end
			end
			break
		end
	end
end

local math_floor = math.floor
function PitBull_DruidManaBar:UpdateMana()
	local regen, castingRegen = GetManaRegen()
	if fiveSecondRule then
		currMana = currMana + math_floor(castingRegen*2 + 0.5)
	else
		currMana = currMana + math_floor(regen*2 + 0.5)
	end

	if currMana >= maxMana then
		currMana = maxMana
		self:RemoveAllTimers()
	end

	self:Update()
end

function PitBull_DruidManaBar:SetMax()
	currMana = maxMana
	self:RemoveAllTimers()
	
	self:Update()
end

function PitBull_DruidManaBar:UpdateColor(frame)
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			self:UpdateColor(frame)
		end
		return
	end
	
	local r,g,b = unpack(PitBull.colorConstants.mana)
	
	if self.db.profile.reverse then
		frame.druidManaBar:SetStatusBarColor((r+0.2)/3, (g+0.2)/3, (b+0.2)/3, 1)
		frame.druidManaBar.bg:SetVertexColor(r, g, b, 1)
	else
		frame.druidManaBar:SetStatusBarColor(r, g, b, 1)
		frame.druidManaBar.bg:SetVertexColor((r+0.2)/3, (g+0.2)/3, (b+0.2)/3, 1)
	end
end

function PitBull_DruidManaBar:Update(frame)
	if not frame then
		for frame in PitBull:IterateUnitFramesForUnit("player") do
			if frame.druidManaBar then
				self:Update(frame)
			end
		end
		return
	end
	
	local db = self.db.profile
	
	if currMana and maxMana then
		local perc = currMana / maxMana
		if db.deficit ~= db.reverse then
			perc = 1 - perc
		end
		frame.druidManaBar:SetValue(perc)
		if currMana and maxMana then
			frame.druidManaText:SetText(textStyles[self.db.profile.textStyle]())
		end
	end
end

function PitBull_DruidManaBar:OnUpdateFrame(unit, frame)
	if frame.druidManaBar then
		self:Update(frame)
		self:UpdateColor(frame)
	end
end

function PitBull_DruidManaBar:OnPopulateUnitFrame(unit, frame)
	if unit ~= "player" or frame.druidManaBar or PitBull_DruidManaBar.db.profile.hidden or UnitPowerType("player") == 0 then
		return
	end
	local druidManaBar = newFrame("StatusBar", frame)
	frame.druidManaBar = druidManaBar
	druidManaBar:SetMinMaxValues(0, 1)
	druidManaBar:SetValue(1)
	druidManaBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	druidManaBar:SetStatusBarColor(0, 0, 1, 1)

	local druidManaBarBG = newFrame("Texture", druidManaBar, "BACKGROUND")
	frame.druidManaBar.bg = druidManaBarBG
	druidManaBarBG:SetTexture(PitBull:GetStatusBarTexture())
	druidManaBarBG:SetVertexColor(0, 0, 0.5, 1)
	druidManaBarBG:ClearAllPoints()
	druidManaBarBG:SetAllPoints(druidManaBar)
	
	local druidManaText = newFrame("FontString", druidManaBar, "OVERLAY")
	frame.druidManaText = druidManaText
	druidManaText:SetFont(PitBull:GetFont())
	druidManaText:SetShadowColor(0, 0, 0, 1)
	druidManaText:SetShadowOffset(0.8, -0.8)
	druidManaText:SetNonSpaceWrap(false)
	if currMana and maxMana then
		druidManaText:SetText(textStyles[self.db.profile.textStyle]())
	end
	
	self:UpdateColor(frame)
end

function PitBull_DruidManaBar:OnClearUnitFrame(unit, frame)
	if frame.druidManaBar then
		frame.druidManaText = delFrame(frame.druidManaText)
		frame.druidManaBar.bg = delFrame(frame.druidManaBar.bg)
		frame.druidManaBar = delFrame(frame.druidManaBar)
	end
end

function PitBull_DruidManaBar:OnUpdateStatusBarTexture(texture)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.druidManaBar then
			frame.druidManaBar:SetStatusBarTexture(texture)
			frame.druidManaBar.bg:SetTexture(texture)
		end
	end
end

function PitBull_DruidManaBar:OnUnknownLayout(unit, frame, name)
	if name == "druidManaBar" then
		frame.druidManaBar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
		frame.druidManaBar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		frame.druidManaBar:SetHeight(15)
	elseif name == "druidManaText" then
		frame.druidManaText:SetPoint("RIGHT", frame.druidManaBar, "RIGHT", -3, 0)
	end
end

function PitBull_DruidManaBar:OnUpdateLayout(unit, frame)
	local old = not unitsShown[frame]
	local now = not frame.druidManaBar or not frame.druidManaBar:IsShown()
	if old == now then
		return
	end
	unitsShown[frame] = not now
	if not now then
		self:OnUpdateFrame(unit, frame)
	end
end

local function getDeficit()
	return PitBull_DruidManaBar.db.profile.deficit
end
local function setDeficit(value)
	PitBull_DruidManaBar.db.profile.deficit = value

	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if frame.druidManaBar then
			PitBull_DruidManaBar:Update(frame)
		end
	end
end
local function getReverse()
	return PitBull_DruidManaBar.db.profile.reverse
end
local function setReverse(value)
	PitBull_DruidManaBar.db.profile.reverse = value

	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if frame.druidManaBar then
			PitBull_DruidManaBar:Update(frame)
			PitBull_DruidManaBar:UpdateColor(frame)
		end
	end
end
local function getHide()
	return PitBull_DruidManaBar.db.profile.hidden
end
local function getEnabled()
	return not PitBull_DruidManaBar.db.profile.hidden
end
local function setEnabled(value)
	value = not value
	PitBull_DruidManaBar.db.profile.hidden = value
	
	for frame in PitBull:IterateUnitFramesForUnit("player") do
		if value then
			self:OnClearUnitFrame("player", frame)
		else
			self:OnPopulateUnitFrame("player", frame)
			self:OnUpdateFrame("player", frame)
		end
		PitBull:UpdateLayout(frame)
	end
end
PitBull_DruidManaBar:RegisterPitBullOptionsMethod(function(group)
	if group == "player" then
		local textStyleValidate = {}
		for k in pairs(textStyles) do
			textStyleValidate[k] = L[k]
		end
		return {
			name = L["Druid mana"],
			desc = L["Druid mana display settings for this unit type."],
			type = 'group',
			args = {
				deficit = {
					type = 'boolean',
					name = L["Show as deficit"],
					desc = L["Show druid's mana deficit, filling the bar when you use up your druidMana."],
					get = getDeficit,
					set = setDeficit,
					disabled = getHide,
				},
				reverse = {
					type = 'boolean',
					name = L["Reverse"],
					desc = L["Reverses the direction of the druid mana bar, filling it from right to left."],
					get = getReverse,
					set = setReverse,
					disabled = getHide,
				},
				hide = {
					type = 'boolean',
					name = L["Enable"],
					desc = L["Enables the druid mana bar."],
					get = getEnabled,
					set = setEnabled,
					order = 1,
				},
				textStyle = {
					type = 'choice',
					name = L["Text style"],
					desc = L["Choose what kind of text to show on the druid bar"],
					get = function()
						return self.db.profile.textStyle
					end,
					set = function(value)
						self.db.profile.textStyle = value
						
						for frame in PitBull:IterateUnitFramesForUnit("player") do
							if frame.druidManaBar then
								self:Update(frame)
							end
						end
					end,
					choices = textStyleValidate,
					disabled = getHide,
				}
			}
		}
	end
end)
