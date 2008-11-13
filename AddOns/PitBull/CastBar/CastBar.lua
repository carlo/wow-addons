if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 53016 $"):match("%d+"))

local PitBull = PitBull
local PitBull_CastBar = PitBull:NewModule("CastBar", "LibRockEvent-1.0", "LibRockTimer-1.0")
local self = PitBull_CastBar
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-10-23 18:18:33 -0400 (Tue, 23 Oct 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show a casting bar each of the PitBull unit frames."] = "각각의 PitBull 유닛 프레임에 시전바를 표시합니다.",
	["Casting bar"] = "시전바",
	["Spell Text"] = "주문 문자",
	["Time Text"] = "시간 문자",
	["Casting"] = "시전",
	["Channeling"] = "채널 연결",
	["Complete"] = "완료",
	["Fail"] = "실패",
	["Background"] = "배경",
	["Cast"] = "시전",
	["Options for the cast bar."] = "시전바를 위한 옵션",
	["Enable"] = "활성화",
	["Enables the cast bar for this unit.\n\nNote that disabling the cast bar for the player does not automatically enable the standard Blizzard cast bar, you must do that in the Hide Blizzard Frames menu."] = "이 유닛에 대해 시전바를 활성화합니다.\n\n기본 블리자드 시전바를 자동으로 활성화하지 않은 플레이어를 위해서는 숨겨져 있는 블리자드 프레임 메뉴에서 반드시 시전바를 비활성화시켜야 한다는 것에 유의하십시요.",
	["Show icon"] = "아이콘 표시",
	["Show the icon for the spell which is being cast."] = "시전중인 주문을 위해 아이콘을 표시합니다",
} or {}

local L = PitBull:L("PitBull-CastBar", localization)

self.desc = L["Show a casting bar each of the PitBull unit frames."]

local newList, del, newDict = Rock:GetRecyclingFunctions("PitBull", "newList", "del", "newDict")
local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_CastBar:RegisterPitBullChildFrames('castBar', 'castBarText', 'castBarTimeText', 'castBarIcon')

local castData = {}

function PitBull_CastBar:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("CastBar")
	PitBull:SetDatabaseNamespaceDefaults("CastBar", "profile", {
		groups = {
			['**'] = {
				ignore = false,
				showIcon = true,
			},
			["targettarget"] = {
				ignore = true,
			},
			["targettargettarget"] = {
				ignore = true,
			},
			["focustarget"] = {
				ignore = true,
			},
			["focustarget"] = {
				ignore = true,
			},
			["partytarget"] = {
				ignore = true,
			},
			["partypettarget"] = {
				ignore = true,
			},
			["raidtarget"] = {
				ignore = true,
			},
		},
		spelltextcolor = {1, 1, 1},
		timetextcolor = {1, 1, 1},
		castingcolor = {1.0, 0.7, 0.0},
		channelingcolor = {0, 1.0, 0},
		completecolor = {0, 1.0, 0},
		failcolor = {1.0, 0, 0},
		backgroundcolor = { .5, .5, .5, .8 },
	})
end

function PitBull_CastBar:OnEnable(first)
	self.castData = castData -- for Roartindon so he can read the data.
	self:AddRepeatingTimer(0, "UpdateAllCastBars")

	self:AddEventListener("UNIT_SPELLCAST_SENT")
	self:AddEventListener("UNIT_SPELLCAST_START")
	self:AddEventListener("UNIT_SPELLCAST_CHANNEL_START")
	self:AddEventListener("UNIT_SPELLCAST_STOP")
	self:AddEventListener("UNIT_SPELLCAST_FAILED")
	self:AddEventListener("UNIT_SPELLCAST_DELAYED")
	self:AddEventListener("UNIT_SPELLCAST_CHANNEL_UPDATE")
	self:AddEventListener("UNIT_SPELLCAST_CHANNEL_STOP")
	self:AddEventListener("UNIT_SPELLCAST_INTERRUPTED")
	self:AddEventListener("UNIT_SPELLCAST_CHANNEL_INTERRUPTED", "UNIT_SPELLCAST_INTERRUPTED")
end

function PitBull_CastBar:UpdateAllCastBars()
	local frame
	for unit, data in pairs(castData) do
		local one = false
		for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
			if frame.castBar then
				one = true
				local currentTime = GetTime()
				if data.casting then
					local showTime = math.min(currentTime, data.endTime)
					frame.castBar:SetValue(showTime)
					local delay = data.delay
					if delay and delay ~= 0 then
						frame.castBarTimeText:SetText(("|cffff0000+%.1f|cffffffff %.1f"):format(data.delay, data.endTime - showTime))
					else
						frame.castBarTimeText:SetText(("%.1f"):format(data.endTime - showTime))
					end
					if currentTime > data.endTime and not UnitIsUnit("player", unit) then
						castData[unit].casting = nil
						castData[unit].fadeOut = 1
						castData[unit].stopTime = currentTime
					end
				elseif data.channeling then
					local showTime = currentTime
					if currentTime > data.endTime then
						showTime = data.endTime
						castData[unit].channeling = nil
						castData[unit].fadeOut = 1
						castData[unit].stopTime = currentTime
					end
					local remainingTime = data.endTime - showTime
					frame.castBar:SetValue(data.startTime + remainingTime)
					frame.castBarTimeText:SetText(("%.1f"):format(remainingTime))

					if data.delay and data.delay ~= 0 then
						frame.castBarTimeText:SetText(("|cffFF0000-%.1f|cffffffff %.1f"):format(data.delay, remainingTime))
					else
						frame.castBarTimeText:SetText(("%.1f"):format(remainingTime))
					end
				elseif data.fadeOut then
					local alpha
					if data.stopTime then
						alpha = data.stopTime - currentTime + 1
					else
						alpha = 0
					end
					if alpha >= 1 then
						alpha = 1
					end
					if alpha <= 0 then
						frame.castBar:Hide()
						frame.castBarText:SetText("")
						frame.castBarTimeText:SetText("")
						if frame.castBarIcon then
							frame.castBarIcon:Hide()
						end
						frame.castBar:SetValue(0)

						castData[unit] = del(castData[unit])
					else
						frame.castBar:SetAlpha(alpha)
						frame.castBarText:SetAlpha(alpha)
						frame.castBarTimeText:SetAlpha(alpha)
						if frame.castBarIcon then
							frame.castBarIcon:SetAlpha(alpha)
						end
					end
				else
					if castData[unit] then
						castData[unit] = del(castData[unit])
					end
					break
				end
			end
		end
		if not one and castData[unit] then
			castData[unit] = del(castData[unit])
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_SENT(ns, event, unit, spell, rank, target)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if not self.db.profile.groups[frame.group].ignore and frame.castBar then
			if not castData[unit] then
				castData[unit] = newList()
			end

			if target == "" then
				target = nil
			end
			castData[unit].target = target
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_START(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if not self.db.profile.groups[frame.group].ignore and frame.castBar then
			if not castData[unit] then
				castData[unit] = newList()
			end
			local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(unit)
			if icon == "Interface\\Icons\\Temp" then
				icon = nil
			end

			castData[unit].spell = spell
			castData[unit].rank = rank
			castData[unit].displayName = displayName
			castData[unit].icon = icon
			castData[unit].startTime = startTime * 0.001
			castData[unit].endTime = endTime * 0.001
			castData[unit].delay = 0
			castData[unit].casting = 1
			castData[unit].channeling = nil
			castData[unit].fadeOut = nil

			frame.castBar:SetStatusBarColor(unpack(self.db.profile.castingcolor))
			frame.castBar:SetAlpha(1.0)
			frame.castBar:SetMinMaxValues(castData[unit].startTime, castData[unit].endTime)
			-- calculate the correct value since this function can be called for wacky units as well.
			frame.castBar:SetValue(GetTime())
			frame.castBar:Show()

			if type(castData[unit].target)=="string" and UnitName(unit) ~= castData[unit].target then
				frame.castBarText:SetText(displayName .. " (" .. castData[unit].target ..")" )
			else
				frame.castBarText:SetText(displayName)
			end
			frame.castBarText:SetAlpha(1.0)
			frame.castBarText:Show()
			frame.castBarText:SetTextColor(unpack(self.db.profile.spelltextcolor))

			frame.castBarTimeText:SetAlpha(1.0)
			frame.castBarTimeText:Show()
			frame.castBarTimeText:SetTextColor(unpack(self.db.profile.timetextcolor))

			if frame.castBarIcon then
				frame.castBarIcon:SetAlpha(1.0)
				frame.castBarIcon:SetTexture(icon)
				frame.castBarIcon:Show()
			end
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_CHANNEL_START(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if not self.db.profile.groups[frame.group].ignore and frame.castBar then
			if not castData[unit] then
				castData[unit] = newDict()
			end
			local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
			if icon == "Interface\\Icons\\Temp" then
				icon = nil
			end

			castData[unit].spell = spell
			castData[unit].rank = rank
			castData[unit].displayName = spell
			castData[unit].icon = icon
			castData[unit].startTime = startTime * 0.001
			castData[unit].endTime = endTime * 0.001
			castData[unit].delay = 0
			castData[unit].casting = nil
			castData[unit].channeling = 1
			castData[unit].fadeOut = nil

			frame.castBar:SetStatusBarColor(unpack(self.db.profile.channelingcolor))
			frame.castBar:SetAlpha(1.0)
			frame.castBar:SetMinMaxValues(castData[unit].startTime, castData[unit].endTime)
			-- calculate the correct value since this function can be called for wacky units as well.
			frame.castBar:SetValue(castData[unit].startTime + castData[unit].endTime - GetTime())
			frame.castBar:Show()


			frame.castBarText:SetText(spell)
			frame.castBarText:SetAlpha(1.0)
			frame.castBarText:Show()
			frame.castBarText:SetTextColor(unpack(self.db.profile.spelltextcolor))

			frame.castBarTimeText:SetAlpha(1.0)
			frame.castBarTimeText:Show()
			frame.castBarTimeText:SetTextColor(unpack(self.db.profile.timetextcolor))

			if frame.castBarIcon then
				frame.castBarIcon:SetAlpha(1.0)
				frame.castBarIcon:SetTexture(icon)
				frame.castBarIcon:Show()
			end
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_STOP(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if frame.castBar and castData[unit] and castData[unit].casting then
			castData[unit].casting = nil
			castData[unit].fadeOut = 1
			castData[unit].stopTime = GetTime()

			frame.castBar:SetStatusBarColor(unpack(self.db.profile.completecolor))
			frame.castBar:SetMinMaxValues(0.0, 1.0)
			frame.castBarTimeText:SetText("")
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_FAILED(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if frame.castBar and castData[unit] and (castData[unit].casting or castData[unit].channeling) then
			castData[unit].casting = nil
			castData[unit].channeling = nil
			castData[unit].fadeOut = 1
			castData[unit].stopTime = GetTime()

			frame.castBar:SetStatusBarColor(unpack(self.db.profile.failcolor))
			frame.castBar:SetAlpha(1.0)
			frame.castBar:SetMinMaxValues(0.0, 1.0)
			frame.castBar:SetValue(1.0)
			frame.castBar:Show()

			frame.castBarText:SetText(FAILED)
			frame.castBarText:SetAlpha(1.0)
			frame.castBarText:Show()
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_INTERRUPTED(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if frame.castBar and castData[unit] then
			castData[unit].casting = nil
			castData[unit].channeling = nil
			castData[unit].fadeOut = 1
			castData[unit].stopTime = GetTime()

			frame.castBar:SetStatusBarColor(unpack(self.db.profile.failcolor))
			frame.castBar:SetAlpha(1.0)
			frame.castBar:SetMinMaxValues(0.0, 1.0)
			frame.castBar:SetValue(1.0)
			frame.castBar:Show()

			frame.castBarText:SetText(INTERRUPTED)
			frame.castBarText:SetAlpha(1.0)
			frame.castBarText:Show()
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_DELAYED(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit, true) do
		if frame.castBar and castData[unit] and castData[unit].casting then
			local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(unit)

			if not spell or not startTime or not endTime then
				return
			end

			local oldStart = castData[unit].startTime

			castData[unit].startTime = startTime * 0.001
			castData[unit].endTime = endTime * 0.001

			castData[unit].delay = (castData[unit].delay or 0) + (castData[unit].startTime - oldStart)

			frame.castBar:SetMinMaxValues(castData[unit].startTime, castData[unit].endTime)
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_CHANNEL_UPDATE(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		if frame.castBar and castData[unit] then
			local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)

			if not spell then
				castData[unit] = del(castData[unit])
				frame.castBarText:SetText("")
				frame.castBarTimeText:SetText("")
				if frame.castBarIcon then
					frame.castBarIcon:Hide()
				end
				frame.castBar:Hide()
				return
			end

			local oldStart = castData[unit].startTime
			castData[unit].startTime = startTime * 0.001
			castData[unit].endTime = endTime * 0.001
			castData[unit].delay = (castData[unit].delay or 0) + (oldStart - castData[unit].startTime)

			frame.castBar:SetMinMaxValues(castData[unit].startTime, castData[unit].endTime)
		end
	end
end

function PitBull_CastBar:UNIT_SPELLCAST_CHANNEL_STOP(ns, event, unit)
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		if frame.castBar and castData[unit] then
			castData[unit].channeling = nil
			castData[unit].casting = nil
			castData[unit].fadeOut = 1
			castData[unit].stopTime = GetTime()

			if frame.castBarTimeText then
				frame.castBarTimeText:SetText("")
			end
		end
	end
end

function PitBull_CastBar:OnUpdateFrame(unit, frame)
	if not frame.castBar or self.db.profile.groups[frame.group].ignore then
		return
	end

	if PitBull.IsWackyUnit[unit] then
		-- We have a non-event driven wacky unit with a castBar that's not ignored
		-- We manually call the start and stop functions for those units
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(unit)
		if displayName then
			self:UNIT_SPELLCAST_START(nil, nil, unit)
			return
		end
		spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
		if displayName then
			self:UNIT_SPELLCAST_CHANNEL_START(nil, nil, unit)
			return
		end
		if castData[unit] then
			if castData[unit].channeling then
				self:UNIT_SPELLCAST_CHANNEL_STOP(nil, nil, unit)
			elseif castData[unit].casting then
				self:UNIT_SPELLCAST_STOP(nil, nil, unit)
			end
		end
	elseif unit == "target" or unit == "focus" then
		-- This occurs when the player has selected a new target or focus.
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(unit)
		if displayName then
			self:UNIT_SPELLCAST_START(nil, nil, unit)
			return
		end
		spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
		if displayName then
			self:UNIT_SPELLCAST_CHANNEL_START(nil, nil, unit)
			return
		end
		if castData[unit] then
			castData[unit] = del(castData[unit])
			frame.castBarText:SetText("")
			frame.castBarTimeText:SetText("")
			if frame.castBarIcon then
				frame.castBarIcon:SetTexture(nil)
			end
			frame.castBar:SetValue(0)
		end
	end
end

function PitBull_CastBar:OnPopulateUnitFrame(unit, frame)
	if frame.castBar or self.db.profile.groups[frame.group].ignore then
		return
	end
	local castBar = newFrame("StatusBar", frame)
	frame.castBar = castBar
	castBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
	castBar:SetMinMaxValues(0, 1)
	castBar:SetValue(0)
	castBar:Hide()

	local castBarBG = newFrame("Texture", frame, "BACKGROUND")
	frame.castBar.bg = castBarBG
	castBarBG:SetTexture(PitBull:GetStatusBarTexture())
	castBarBG:SetVertexColor(unpack(self.db.profile.backgroundcolor))
	castBarBG:ClearAllPoints()
	castBarBG:SetAllPoints(castBar)
	castBarBG:Hide()

	local font, fontsize = PitBull:GetFont()

	local castBarText = newFrame("FontString", castBar, "OVERLAY")
	frame.castBarText = castBarText
	castBarText:SetFont( font, fontsize )
	castBarText:SetShadowColor( 0, 0, 0, 1)
	castBarText:SetShadowOffset( 0.8, -0.8 )
	castBarText:SetNonSpaceWrap(false)
	castBarText:SetJustifyH( "LEFT" )
	castBarText:ClearAllPoints()
	castBarText:SetAllPoints(castBar)
	castBarText:Hide()

	local castBarTimeText = newFrame("FontString", castBar, "OVERLAY")
	frame.castBarTimeText = castBarTimeText
	castBarTimeText:SetFont( font, fontsize )
	castBarTimeText:SetShadowColor( 0, 0, 0, 1)
	castBarTimeText:SetShadowOffset( 0.8, -0.8 )
	castBarTimeText:SetNonSpaceWrap(false)
	castBarTimeText:SetJustifyH("RIGHT")
	castBarTimeText:ClearAllPoints()
	castBarTimeText:SetAllPoints(castBar)
	castBarTimeText:Hide()

	if self.db.profile.groups[frame.group].showIcon then
		local castBarIcon = newFrame("Texture", castBar, "BACKGROUND")
		frame.castBarIcon = castBarIcon
		castBarIcon:SetPoint( "RIGHT", castBar, "LEFT", 0, 0)
		castBarIcon:Hide()
	end
end

function PitBull_CastBar:OnUpdateFont(font, fontsize)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.castBar then
			frame.castBarText:SetFont( font, fontsize)
			frame.castBarTimeText:SetFont( font, fontsize )
		end
	end
end

function PitBull_CastBar:OnUpdateStatusBarTexture(texture)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.castBar then
			frame.castBar:SetStatusBarTexture(texture)
			frame.castBar.bg:SetTexture(texture)
		end
	end
end

function PitBull_CastBar:OnClearUnitFrame(unit, frame)
	if frame.castBar then
		frame.castBar.bg = delFrame(frame.castBar.bg)
		frame.castBarText = delFrame(frame.castBarText)
		frame.castBarTimeText = delFrame(frame.castBarTimeText)
		if frame.castBarIcon then
			frame.castBarIcon = delFrame(frame.castBarIcon)
		end
		frame.castBar = delFrame(frame.castBar)
	end
end

function PitBull_CastBar:OnUnknownLayout(unit, frame, name)
	if frame.castBar then
		if name == 'castBar' then
			frame.castBar:SetHeight(16)
			frame.castBar:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 21, 0 )
			frame.castBar:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, 0)
			frame.castBar.bg:ClearAllPoints()
			frame.castBar.bg:SetAllPoints(frame.castBar)
			frame.castBar:Hide()
		elseif name == 'castBarIcon' then
			frame.castBarIcon:SetHeight(16)
			frame.castBarIcon:SetWidth(16)
			frame.castBarIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			frame.castBarIcon:SetPoint("RIGHT", frame.castBar, "LEFT")
		elseif name == 'castBarText' then
			frame.castBarText:ClearAllPoints()
			frame.castBarText:SetAllPoints(frame.castBar)
		elseif name == 'castBarTimeText' then
			frame.castBarTimeText:ClearAllPoints()
			frame.castBarTimeText:SetAllPoints(frame.castBar)
			frame.castBarTimeText:SetJustifyH("RIGHT")
		end
	end
end
-- Global Options
local function getDBColor(field)
	return unpack(PitBull_CastBar.db.profile[field])
end
local function setDBColor(field,r,g,b)
	PitBull_CastBar.db.profile[field] = {r,g,b}
end
local function setDBColorWithAlpha(field,r,g,b,a)
	PitBull_CastBar.db.profile[field] = {r,g,b,a}
	if field == 'backgroundcolor' then
		for _,frame in PitBull:IterateUnitFrames() do
			if frame.castBar then
				frame.castBar.bg:SetVertexColor(r, g, b, a)
			end
		end
	end
end

PitBull.options.args.global.args.colors.args.castbar = {
	type = 'group',
	name = L["Casting bar"],
	desc = L["Casting bar"],
	child_get = getDBColor,
	child_set = setDBColor,
	child_type = 'color',
	args = {
		spelltextcolor = {
			name = L["Spell Text"],
			desc = L["Spell Text"],
			passValue = 'spelltextcolor',
		},
		timetextcolor = {
			name = L["Time Text"],
			desc = L["Time Text"],
			passValue = 'timetextcolor',
		},
		castingcolor = {
			name = L["Casting"],
			desc = L["Casting"],
			passValue = 'castingcolor',
		},
		channelingcolor = {
			name = L["Channeling"],
			desc = L["Channeling"],
			passValue = 'channelingcolor',
		},
		completecolor = {
			name = L["Complete"],
			desc = L["Complete"],
			passValue = 'completecolor',
		},
		failcolor = {
			name = L["Fail"],
			desc = L["Fail"],
			passValue = 'failcolor',
		},
		backgroundcolor = {
			name = L["Background"],
			desc = L["Background"],
			hasAlpha = true,
			passValue = 'backgroundcolor',
		},
	},
}
-- Unit/Group Specific Options
local function getDisabled(group)
	return PitBull_CastBar.db.profile.groups[group].ignore
end
local function getEnabled(group)
	return not PitBull_CastBar.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	value = not value
	PitBull_CastBar.db.profile.groups[group].ignore = value
	if value then
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.castBar then
				PitBull_CastBar:OnClearUnitFrame(unit, frame)
				castData[unit] = nil
				PitBull:UpdateLayout(frame)
			end
		end
	else
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if not frame.castBar then
				PitBull_CastBar:OnPopulateUnitFrame(unit, frame)
				PitBull:UpdateLayout(frame)
			end
		end
	end
end
local function getShowIcon(group)
	return PitBull_CastBar.db.profile.groups[group].showIcon
end
local function setShowIcon(group, value)
	PitBull_CastBar.db.profile.groups[group].showIcon = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		if frame.castBar then
			PitBull_CastBar:OnClearUnitFrame(unit, frame)
			PitBull_CastBar:OnPopulateUnitFrame(unit, frame)
			PitBull:UpdateLayout(frame)
		end
	end
end

PitBull_CastBar:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'group',
		name = L["Cast"],
		desc = L["Options for the cast bar."],
		args = {
			enable = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the cast bar for this unit.\n\nNote that disabling the cast bar for the player does not automatically enable the standard Blizzard cast bar, you must do that in the Hide Blizzard Frames menu."],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
				order = 1,
			},
			showIcon = {
				type = 'boolean',
				name = L["Show icon"],
				desc = L["Show the icon for the spell which is being cast."],
				get = getShowIcon,
				set = setShowIcon,
				passValue = group,
				disabled = getDisabled,
			},
		},
	}
end)

