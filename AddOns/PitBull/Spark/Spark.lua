if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_Spark = PitBull:NewModule("Spark", "LibRockEvent-1.0")
local self = PitBull_Spark
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Graceful display of energy ticks and the spellcasting five-second-rule."] = "기력 회복 및 5초 규칙 주문 시전을 우아하게 표시합니다.",
	["Power spark"] = "마력 섬광",
	["Set the color of the power spark."] = "마력 섬광을 위한 색상을 설정합니다.",
	["Enable power spark"] = "마력 섬광 활성화",
	["A spark that travels the length of your power bar, displaying the time left to the next energy tick, or how long until you're outside the five-second rule, depending on your class and current power type."] = "마력바의 길이를 이동하는 하나의 섬광으로 직업 및 마력 유형에 근거해 다음 기력 회복까지 남은 시간을, 혹은 5초 규칙을 벗어나기 까지의 걸린 시간을 표시합니다.",
} or {}

local L = PitBull:L("PitBull-Spark", localization)

self.desc = L["Graceful display of energy ticks and the spellcasting five-second-rule."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local GetTime = GetTime
local UnitMana = UnitMana
local UnitPowerType = UnitPowerType

PitBull_Spark:RegisterPitBullModuleDependencies("PowerBar")
PitBull_Spark:RegisterPitBullChildFrames('powerSpark')

-- Frames, stored locally since there's only one copy of each that we care about.
local powerSpark, powerBar

-- Status and event time storage
local energy_lasttick, spellcast_finish_time, current_energy, power, current_mana = GetTime(), GetTime(), 0, 0, 0
local last_spellcast = 0

-- functions
local manaOnUpdate, energyOnUpdate

-- constants
local energyticklength = 2
local fiveseclength = 5

function manaOnUpdate(frame)
	frame:ClearAllPoints()
	local timediff = GetTime() - spellcast_finish_time
	if timediff > fiveseclength then
		frame:Hide()
		return frame:SetScript('OnUpdate', nil)
	else
		frame:SetPoint('LEFT', powerBar, 'LEFT', (timediff / fiveseclength) * (powerBar:GetWidth() - 1), 0)
	end
end

function energyOnUpdate(frame)
	frame:ClearAllPoints()
	local timediff = GetTime() - energy_lasttick
	if timediff > energyticklength then
		energy_lasttick = energy_lasttick + energyticklength
	end
	frame:SetPoint('LEFT', powerBar, 'LEFT', (timediff / energyticklength) * (powerBar:GetWidth() - 1), 0)
end

function PitBull_Spark:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("Spark")
	PitBull:SetDatabaseNamespaceDefaults("Spark", "profile", {
		color = {1, 1, 1, 0.3},
		enable = true,
	})
end

function PitBull_Spark:OnEnable()
	power = UnitPowerType('player')
	current_energy = 0
	if self.db.profile.enable then
		self:DoRegistrations()
	end
end

function PitBull_Spark:DoRegistrations()
	power = UnitPowerType('player')
	current_energy = 0
	local _, class = UnitClass('player')
	if class == "ROGUE" then
		self:AddEventListener("UNIT_ENERGY")
		self:AddEventListener("PLAYER_TARGET_CHANGED")
		self:AddEventListener("PLAYER_REGEN_ENABLED")
		self:AddEventListener("PLAYER_REGEN_DISABLED")
		self:AddEventListener("UNIT_FACTION")
		self:AddEventListener("PLAYER_DEAD")
		self:AddEventListener("PLAYER_ALIVE")
		self.UNIT_MANA = nil
		self.UNIT_DISPLAYPOWER = nil
		self.UNIT_SPELLCAST_SUCCEEDED = nil
	elseif class == "DRUID" then
		self:AddEventListener("UNIT_SPELLCAST_SUCCEEDED")
		self:AddEventListener("PLAYER_TARGET_CHANGED")
		self:AddEventListener("PLAYER_REGEN_ENABLED")
		self:AddEventListener("PLAYER_REGEN_DISABLED")
		self:AddEventListener("UNIT_FACTION")
		self:AddEventListener("PLAYER_DEAD")
		self:AddEventListener("PLAYER_ALIVE")
		self:AddEventListener("UNIT_ENERGY")
		self:AddEventListener("UNIT_MANA")
		self:AddEventListener("UNIT_DISPLAYPOWER")
		current_mana = UnitMana('player')
	elseif class == "WARRIOR" then
		self.UNIT_ENERGY = nil
		self.UNIT_MANA = nil
		self.UNIT_DISPLAYPOWER = nil
		self.UNIT_SPELLCAST_SUCCEEDED = nil
		self.PLAYER_TARGET_CHANGED = nil
		self.PLAYER_REGEN_ENABLED = nil
		self.PLAYER_REGEN_DISABLED = nil
		self.UNIT_FACTION = nil
		self.PLAYER_DEAD = nil
		self.PLAYER_ALIVE = nil
		self.OnPopulateUnitFrame = nil
		self.OnUpdateLayout = nil
		self.OnClearUnitFrame = nil
	else -- normal mana user
		self:AddEventListener("UNIT_SPELLCAST_SUCCEEDED")
		self:AddEventListener("UNIT_MANA")
		self.UNIT_ENERGY = nil
		self.UNIT_DISPLAYPOWER = nil
		self.PLAYER_TARGET_CHANGED = nil
		self.PLAYER_REGEN_ENABLED = nil
		self.PLAYER_REGEN_DISABLED = nil
		self.UNIT_FACTION = nil
		self.PLAYER_DEAD = nil
		self.PLAYER_ALIVE = nil
		current_mana = UnitMana('player')
	end
end

local inCombat = false

function PitBull_Spark:PLAYER_REGEN_ENABLED()
	inCombat = false
	if powerSpark and power == 3 and UnitIsDeadOrGhost("player") or (UnitMana("player") == UnitManaMax("player") and (not UnitCanAttack("player", "target") or UnitIsDeadOrGhost("target"))) then
		powerSpark:SetScript('OnUpdate', nil)
		powerSpark:Hide()
	end
end

function PitBull_Spark:PLAYER_REGEN_DISABLED()
	inCombat = true
	if powerSpark and power == 3 then
		powerSpark:SetScript('OnUpdate', energyOnUpdate)
		powerSpark:Show()
	end
end

function PitBull_Spark:PLAYER_TARGET_CHANGED()
	if not powerSpark or power ~= 3 then
		return
	end
	if UnitIsDeadOrGhost("player") or (UnitMana("player") == UnitManaMax("player") and (not UnitCanAttack("player", "target") or UnitIsDeadOrGhost("target")) and not inCombat) then
		powerSpark:SetScript('OnUpdate', nil)
		powerSpark:Hide()
	else	
		powerSpark:SetScript('OnUpdate', energyOnUpdate)
		powerSpark:Show()
	end
end
PitBull_Spark.PLAYER_DEAD = PitBull_Spark.PLAYER_TARGET_CHANGED
PitBull_Spark.PLAYER_ALIVE = PitBull_Spark.PLAYER_TARGET_CHANGED

function PitBull_Spark:UNIT_FACTION(ns, event, unit)
	if (unit ~= 'player' and unit ~= 'target') or not powerSpark or power ~= 3 then
		return
	end
	self:PLAYER_TARGET_CHANGED()
end

function PitBull_Spark:UNIT_ENERGY(ns, event, unit)
	if unit ~= 'player' or not powerSpark or power ~= 3 then
		return
	end
	local newenergy = UnitMana('player')
	if newenergy > current_energy then
		energy_lasttick = GetTime()
		if UnitIsDeadOrGhost("player") or (newenergy == UnitManaMax("player") and (not UnitCanAttack("player", "target") or UnitIsDeadOrGhost("target")) and not inCombat) then
			powerSpark:SetScript('OnUpdate', nil)
			powerSpark:Hide()
		else
			powerSpark:SetScript('OnUpdate', energyOnUpdate)
			powerSpark:Show()
		end
	end
	current_energy = newenergy
end

function PitBull_Spark:UNIT_MANA(ns, event, unit)
	if unit ~= 'player' or not powerSpark or power ~= 0 then
		return
	end
	local newmana = UnitMana('player')
	if newmana == UnitManaMax('player') then
		powerSpark:Hide()
		powerSpark:SetScript('OnUpdate', nil)
	elseif newmana < current_mana and last_spellcast - GetTime() < 0.25 then
		powerSpark:Show()
		spellcast_finish_time = last_spellcast
		powerSpark:SetScript('OnUpdate', manaOnUpdate)
	end
	current_mana = newmana
end

function PitBull_Spark:UNIT_DISPLAYPOWER(ns, event, unit)
	if unit == 'player' and powerSpark then
		power = UnitPowerType('player')
		if power == 3 then
			-- kitty form
--			spellcast_finish_time = nil
--			last_spellcast = nil
			energy_lasttick = GetTime()
			current_energy = UnitMana('player')
			powerSpark:Hide()
			powerSpark:SetScript('OnUpdate', nil)
		elseif power == 0 then
			-- pretty blue bar, make sure it knows we just cast a spell shifting out (that does stop regen, right?)
--			energy_lasttick = nil
			self:UNIT_SPELLCAST_SUCCEEDED('player')
			powerSpark:Hide()
			powerSpark:SetScript('OnUpdate', nil)
		else
			-- bare fite
--			spellcast_finish_time = nil
--			last_spellcast = nil
--			energy_lasttick = nil
			powerSpark:Hide()
			powerSpark:SetScript('OnUpdate', nil)
		end
	end
end

function PitBull_Spark:UNIT_SPELLCAST_SUCCEEDED(ns, event, unit)
	if unit == 'player' and power == 0 and powerSpark then
		last_spellcast = GetTime()
	end
end

function PitBull_Spark:OnPopulateUnitFrame(unit, frame)
	if unit == 'player' and self.db.profile.enable and frame.powerBar and select(2, UnitClass('player')) ~= "WARRIOR" and not powerSpark then
		powerSpark = newFrame("Frame", frame)
		frame.powerSpark = powerSpark
		
		local texture = newFrame("Texture", powerSpark, "OVERLAY")
		frame.powerSpark.texture = texture
		texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		texture:SetVertexColor(unpack(self.db.profile.color))
		texture:SetBlendMode('ADD')
		texture:Show()
		
		powerBar = frame.powerBar
		if self.UNIT_ENERGY then
			self:UNIT_ENERGY('player')
		end
	end
end

function PitBull_Spark:OnUpdateLayout(unit, frame)
	if unit == 'player' and powerSpark and self.db.profile.enable then
		powerBar = frame.powerBar
		
		if not powerBar then
			return self:OnClearUnitFrame(unit, frame)
		end
		
		powerSpark:SetFrameLevel(powerBar:GetFrameLevel() + 2)
		
		-- reassign frame heights/anchors etc, since this (which fires on combat enter/leave) will stop the bar otherwise
		powerSpark.texture:SetPoint('CENTER', powerSpark, 'LEFT')
		
		powerSpark:SetWidth(20)
		powerSpark.texture:SetWidth(20)
		
		local script = powerSpark:GetScript('OnUpdate')
		powerSpark.texture:Show()
		
		local height = powerBar:GetHeight() * 2
		powerSpark:SetHeight(height)
		powerSpark.texture:SetHeight(height)
		
		if script then
			powerSpark:Show()
			powerSpark:SetScript('OnUpdate', script)
		else
			powerSpark:Hide()
		end
	end
end

function PitBull_Spark:OnClearUnitFrame(unit, frame)
	if unit == 'player' and frame.powerSpark then
		frame.powerSpark.texture = delFrame(frame.powerSpark.texture)
		frame.powerSpark = delFrame(frame.powerSpark)
		powerSpark = nil
	end
end

-- Options stuff
local function enabled_get()
	return PitBull_Spark.db.profile.enable
end
local function enabled_set(v)
	PitBull_Spark.db.profile.enable = v
	if select(2, UnitClass('player')) == "WARRIOR" then
		return
	end
	if v then
		if not powerSpark then
			for frame in PitBull:IterateUnitFrames("player") do
				PitBull_Spark:OnPopulateUnitFrame('player', frame)
			end
		end
		for frame in PitBull:IterateUnitFrames("player") do
			PitBull_Spark:OnUpdateLayout('player', frame)
		end
		PitBull_Spark:DoRegistrations()
--		energy_lasttick = nil
--		spellcast_finish_time = nil
--		last_spellcast = nil
		powerSpark:Hide()
		powerSpark:SetScript('OnUpdate', nil)
	else
		PitBull_Spark:RemoveAllEventListeners()
		if powerSpark then
			powerSpark:Hide()
			powerSpark:SetScript('OnUpdate', nil)
		end
	end
end
local function color_get()
	return unpack(PitBull_Spark.db.profile.color)
end
local function color_set(r,g,b,a)
	PitBull_Spark.db.profile.color = {r,g,b,a}
	if powerSpark then
		powerSpark.texture:SetVertexColor(r,g,b,a)
	end
end

PitBull.options.args.global.args.colors.args.spark = {
	type = 'color',
	name = L["Power spark"],
	desc = L["Set the color of the power spark."],
	get = color_get,
	set = color_set,
	hasAlpha = true,
}

PitBull_Spark:RegisterPitBullOptionsMethod(function(group)
	if group ~= 'player' then
		return
	end
	return {
		type = 'boolean',
		name = L["Enable power spark"],
		desc = L["A spark that travels the length of your power bar, displaying the time left to the next energy tick, or how long until you're outside the five-second rule, depending on your class and current power type."],
		get = enabled_get,
		set = enabled_set,
	}
end)

