if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))
local DURATION = 0.5

local localization = (GetLocale() == "koKR") and {
	["Adds fading to the health/power bars."] = "생명력/마력바에 명암 넣기 기능을 추가합니다",
	["Bar fade time"] = "바 명암 시간",
	["Set how long the bars should stay faded after gain or loss before being set back to the original alpha."] = "바가 원래의 투명도로 복귀하기 이전에 명암의 득실 지속 시간을 설정합니다.",
	["Bar fading"] = "바 명암 넣기",
	["Options for fading the bar displays when their values change, as opposed to changing the values instantly."] = "Options for fading the bar displays when their values change, as opposed to changing the values instantly.",
	["Enable power"] = "마력 활성화",
	["Enable fading/smoothing changes to Power."] = "마력을 위해 명암 넣기/유연하게 변경하는 기능을 활성화합니다.",
	["Enable health"] = "생명력 활성화",
	["Enable fading/smoothing changes to Health."] = "생명력을 위해 명암 넣기/유연하게 변경하는 기능을 활성화합니다.",
	["Fade"] = "명암",
	["Fade the alpha of the updated piece of the bar."] = "Fade the alpha of the updated piece of the bar.",
	["Smooth"] = "유연함",
	["Smooth the bar changes, making loss and gain move as a progress bar as opposed to whole chunks."] = "Smooth the bar changes, making loss and gain move as a progress bar as opposed to whole chunks.",
} or {}

local L = PitBull:L("PitBull-BarFader", localization)

local PitBull = PitBull
local PitBull_BarFader = PitBull:NewModule("BarFader", "LibRockHook-1.0", "LibRockTimer-1.0")
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end
PitBull_BarFader.desc = L["Adds fading to the health/power bars."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame
local _abs, _cos, _pi = math.abs, math.cos, math.pi
local PitBull_HealthBar = PitBull:GetModule("HealthBar")
local PitBull_PowerBar = PitBull:GetModule("PowerBar")
local activeframes = {}

function PitBull_BarFader:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("BarFader")
	PitBull:SetDatabaseNamespaceDefaults("BarFader", "profile", {
		fadetime = 0.5,
		color = {0, 0.8, 0, 0.5},
		groups = {
			['*'] = {},
		}
	})
end

function PitBull_BarFader:OnEnable()
	if PitBull_PowerBar then self:AddHook(PitBull_PowerBar, "UpdatePowerValue") end
	if PitBull_HealthBar then self:AddHook(PitBull_HealthBar, "UpdateHealth") end
	self:AddRepeatingTimer(0, "UpdateFaders")
	DURATION = self.db.profile.fadetime
end

function PitBull_BarFader:DrawHealthFader(frame)
	local healthFade
	if frame.healthFade then
		healthFade = frame.healthFade
	else
		healthFade = newFrame("StatusBar", frame)
	end
	frame.healthFade = healthFade
	healthFade.destValue = nil
	healthFade.faderstop = nil
	healthFade:SetOrientation(frame.healthBar:GetOrientation())
	healthFade:SetAllPoints(frame.healthBar)
	healthFade:SetMinMaxValues(frame.healthBar:GetMinMaxValues())
	healthFade:SetValue(frame.healthBar:GetValue())
	healthFade:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	healthFade:Hide()
end

function PitBull_BarFader:DrawPowerFader(frame)
	local powerFade
	if frame.powerFade then
		powerFade = frame.powerFade
	else
		powerFade = newFrame("StatusBar", frame)
	end
	frame.powerFade = powerFade
	powerFade.destValue = nil
	powerFade.faderstop = nil
	powerFade:SetOrientation(frame.powerBar:GetOrientation())
	powerFade:SetAllPoints(frame.powerBar)
	powerFade:SetMinMaxValues(frame.powerBar:GetMinMaxValues())
	powerFade:SetValue(frame.powerBar:GetValue())
	powerFade:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	powerFade:Hide()
end

function PitBull_BarFader:OnUpdateStatusBarTexture(texture)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.healthFade then
			frame.healthFade:SetStatusBarTexture(texture)
		end
		if frame.powerFade then
			frame.powerFade:SetStatusBarTexture(texture)
		end
	end
end

function PitBull_BarFader:OnClearUnitFrame(unit, frame)
	if frame.healthFade then
		activeframes[frame.healthFade] = nil
		frame.healthFade = delFrame(frame.healthFade)
	end
	if frame.powerFade then
		activeframes[frame.powerFade] = nil
		frame.powerFade = delFrame(frame.powerFade)
	end
end

function PitBull_BarFader:OnUpdateLayout(unit, frame)
	if frame.healthFade then
		if (not frame.healthBar) then
			activeframes[frame.healthFade] = nil
			frame.healthFade = delFrame(frame.healthFade)
			return
		end
		frame.healthFade:SetAllPoints(frame.healthBar)
		frame.healthFade:SetOrientation(frame.healthBar:GetOrientation())
		frame.healthBar:SetFrameLevel(3)
		frame.healthFade:SetFrameLevel(4)
		frame.healthFade:SetStatusBarTexture(PitBull:GetStatusBarTexture())
		frame.healthFade:SetMinMaxValues(frame.healthBar:GetMinMaxValues())
		frame.healthFade:Hide()
	end
	if frame.powerFade then
		if (not frame.powerBar) then
			activeframes[frame.powerFade] = nil
			frame.powerFade = delFrame(frame.powerFade)
			return
		end
		frame.powerFade:SetAllPoints(frame.powerBar)
		frame.powerFade:SetOrientation(frame.powerBar:GetOrientation())
		frame.powerBar:SetFrameLevel(3)
		frame.powerFade:SetFrameLevel(4)
		frame.powerFade:SetStatusBarTexture(PitBull:GetStatusBarTexture())
		frame.powerFade:SetMinMaxValues(frame.powerBar:GetMinMaxValues())
		frame.powerFade:Hide()
	end
end

function PitBull_BarFader:UpdateHealth(object, unit, frame)
	local isFading = true
	local db = self.db.profile.groups[frame.group]
	if db.ignore or db.disableHealth or (not db.smooth and not db.fade) then
		return self.hooks[object].UpdateHealth(object,unit,frame)
	end
	if not frame.healthFade then
		self:DrawHealthFader(frame)
	end
	local preValue = frame.healthFade.destValue or frame.healthBar:GetValue()
	self.hooks[object].UpdateHealth(object,unit,frame)
	local destValue = frame.healthBar:GetValue()
	if _abs(destValue - preValue) >= 0.015 then
		local healthFade = frame.healthFade
		if (not healthFade.startValue) then
			isFading = false
			healthFade.startValue = preValue
		end
		healthFade.stop = GetTime() + DURATION
		healthFade.destValue = destValue
		healthFade:SetStatusBarColor(frame.healthBar:GetStatusBarColor())
		if db.smooth and db.fade then
			if preValue < destValue then
				frame.healthBar:SetValue(preValue)
			end
			healthFade:SetAlpha(0)
			if (not isFading) then
				healthFade:SetValue(preValue)
			end
			healthFade.stop = GetTime() + DURATION
			healthFade.style = "both"
		elseif db.smooth then
			if preValue < destValue then
				frame.healthBar:SetValue(preValue)
			end
			if (not isFading) then
				healthFade:SetValue(preValue)
			end
			healthFade:SetAlpha(0.7)
			healthFade.style = "smooth"
		elseif db.fade then
			if preValue < destValue then
				healthFade:SetAlpha(0)
				frame.healthBar:SetValue(preValue)
				if (not isFading) then
					healthFade:SetValue(destValue)
				end
			else
				if (not isFading) then
					healthFade:SetAlpha(0.7)
					healthFade:SetValue(preValue)
				end
			end
			healthFade.style = "flash"
		end
		healthFade:Show()
		activeframes[healthFade] = "healthFade"
	end
end

function PitBull_BarFader:UpdatePowerValue(object, unit, frame)
	local isFading = true
	local db = self.db.profile.groups[frame.group]
	if db.ignore or db.disablePower or (not db.smooth and not db.fade) or not frame.powerBar then
		return self.hooks[object].UpdatePowerValue(object,unit,frame)
	end
	if not frame.powerFade then
		self:DrawPowerFader(frame)
	end
	local preValue = frame.powerFade.destValue or frame.powerBar:GetValue()
	self.hooks[object].UpdatePowerValue(object,unit,frame)
	local destValue = frame.powerBar:GetValue()
	if _abs(destValue - preValue) >= 0.015 then
		local powerFade = frame.powerFade
		if (not powerFade.startValue) then
			powerFade.startValue = preValue
			isFading = false
		end
		powerFade.stop = GetTime() + DURATION
		powerFade.destValue = destValue
		powerFade:SetStatusBarColor(frame.powerBar:GetStatusBarColor())
		if (db.smooth and db.fade) then
			if preValue < destValue then
				frame.powerBar:SetValue(preValue)
			end
			if (not isFading) then
				powerFade:SetValue(preValue)
			end
			powerFade:SetAlpha(0)
			powerFade.style = 'both'
		elseif db.smooth then
			if preValue < destValue then
				frame.powerBar:SetValue(preValue)
			end
			if (not isFading) then
				powerFade:SetValue(preValue)
			end
			powerFade:SetAlpha(0.7)
			powerFade.style = "smooth"
		elseif db.fade then
			if preValue < destValue then
				powerFade:SetAlpha(0)
				frame.powerBar:SetValue(preValue)
				if (not isFading) then
					powerFade:SetValue(destValue)
				end
			else
				if (not isFading) then
					powerFade:SetAlpha(0.7)
					powerFade:SetValue(preValue)
				end
			end
			powerFade.style = "flash"
		end
		powerFade:Show()
		activeframes[powerFade] = "powerFade"
	end
end

local function CosineInterpolate(y1, y2, mu)
	local mu2 = (1-_cos(mu*_pi))/2
	return y1*(1-mu2)+y2*mu2
end

function PitBull_BarFader:UpdateFaders()
	local now, stop, alpha = GetTime()
	for frame, field in pairs(activeframes) do
		stop, alpha = frame.stop
		if stop < now then
			-- done.  set both bar values to the dest value, nuke entry in activeframes, set alpha to 0
			activeframes[frame] = nil
			local parent = frame:GetParent()
			if field == "healthFade" then
				PitBull_BarFader.hooks[PitBull_HealthBar].UpdateHealth(PitBull_HealthBar, parent:GetUnit(), parent)
			elseif field == "powerFade" then
				PitBull_BarFader.hooks[PitBull_PowerBar].UpdatePowerValue(PitBull_PowerBar, parent:GetUnit(), parent)
			end
			frame.startValue = nil
			frame.destValue = nil
			frame:Hide()
			return
		end
		if frame.startValue < frame.destValue then
			alpha = (1 - ((stop - now) / DURATION))*0.7
		else
			alpha = ((stop - now) / DURATION)*0.7
		end
		if frame.style == "flash" then
			frame:SetAlpha(alpha)
		elseif frame.style == 'both' then
			frame:SetAlpha(alpha)
			local cVal = frame:GetValue()
			cVal = CosineInterpolate(cVal,frame.destValue, 1 - ((stop - now) / DURATION) )
			frame:SetValue(cVal)
		elseif frame.style == 'smooth' then
			local cVal = frame:GetValue()
			cVal = CosineInterpolate(cVal,frame.destValue, 1 - ((stop - now) / DURATION) )
			frame:SetValue(cVal)
		end
	end
end

-- Global Options
local function setFadeTime(value)
	PitBull_BarFader.db.profile.fadetime = value
	DURATION = value
end
local function getFadeTime()
	return PitBull_BarFader.db.profile.fadetime
end
PitBull.options.args.global.args.barfader = {
	type = 'number',
	name = L["Bar fade time"],
	desc = L["Set how long the bars should stay faded after gain or loss before being set back to the original alpha."],
	min = 0.1,
	max = 5,
	step = 0.1,
	get = getFadeTime,
	set = setFadeTime,
}


-- Unit/Group Specific Options
local function getFade(group)
	return PitBull_BarFader.db.profile.groups[group].fade
end
local function setFade(group, value)
	PitBull_BarFader.db.profile.groups[group].fade = value
end
local function getSmooth(group)
	return PitBull_BarFader.db.profile.groups[group].smooth
end
local function setSmooth(group, value)
	PitBull_BarFader.db.profile.groups[group].smooth = value
end
local function getEnablePower(group)
	return not PitBull_BarFader.db.profile.groups[group].disablePower
end
local function setEnablePower(group, value)
	PitBull_BarFader.db.profile.groups[group].disablePower = not value
	
	if PitBull_BarFader.db.profile.groups[group].disableHealth and PitBull_BarFader.db.profile.groups[group].disablePower then
		PitBull_BarFader.db.profile.groups[group].ignore = true
	else
		PitBull_BarFader.db.profile.groups[group].ignore = false
	end
end
local function getEnableHealth(group)
	return not PitBull_BarFader.db.profile.groups[group].disableHealth
end
local function setEnableHealth(group, value)
	PitBull_BarFader.db.profile.groups[group].disableHealth = not value
	
	if PitBull_BarFader.db.profile.groups[group].disableHealth and PitBull_BarFader.db.profile.groups[group].disablePower then
		PitBull_BarFader.db.profile.groups[group].ignore = true
	else
		PitBull_BarFader.db.profile.groups[group].ignore = false
	end
end
local function getDisabled(group)
	return PitBull_BarFader.db.profile.groups[group].ignore
end
PitBull_BarFader:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Bar fading"],
		desc = L["Options for fading the bar displays when their values change, as opposed to changing the values instantly."],
		type = 'group',
		args = {
			power = {
				type = 'boolean',
				name = L["Enable power"],
				desc = L["Enable fading/smoothing changes to Power."],
				get = getEnablePower,
				set = setEnablePower,
				passValue = group,
				order = 1,
			},
			health = {
				type = 'boolean',
				name = L["Enable health"],
				desc = L["Enable fading/smoothing changes to Health."],
				get = getEnableHealth,
				set = setEnableHealth,
				passValue = group,
				order = 1,
			},
			fade = {
				type = 'boolean',
				name = L["Fade"],
				desc = L["Fade the alpha of the updated piece of the bar."],
				get = getFade,
				set = setFade,
				passValue = group,
				disabled = getDisabled,
			},
			smooth = {
				type = 'boolean',
				name = L["Smooth"],
				desc = L["Smooth the bar changes, making loss and gain move as a progress bar as opposed to whole chunks."],
				get = getSmooth,
				set = setSmooth,
				passValue = group,
				disabled = getDisabled,
			},
		}
	}
end)
