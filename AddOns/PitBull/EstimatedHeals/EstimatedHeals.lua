if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local watchspells
do
	local _,class = UnitClass("player")
	local BS = Rock("LibBabble-Spell-3.0"):GetLookupTable()
	if class == "PRIEST" then
		watchspells = {
			[BS["Lesser Heal"]] = true,
			[BS["Heal"]] = true,
			[BS["Greater Heal"]] = true,
			[BS["Flash Heal"]] = true,
			[BS["Prayer of Healing"]] = true,
			[BS["Circle of Healing"]] = true,
		}
	elseif class == "DRUID" then
		watchspells = {
			[BS["Healing Touch"]] = true,
			[BS["Regrowth"]] = true,
		}
	elseif class == "SHAMAN" then
		watchspells = {
			[BS["Lesser Healing Wave"]] = true,
			[BS["Healing Wave"]] = true,
			[BS["Chain Heal"]] = true,
		}
	elseif class == "PALADIN" then
		watchspells = {
			[BS["Holy Light"]] = true,
			[BS["Flash of Light"]] = true,
		}
	else
		return
	end
end

local localization = (GetLocale() == "koKR") and {
	["Show the estimated health gain from heals on your PitBull frames. NOTE: This works a lot better if you have Gagorian's DrDamage running."] = "PitBull 프레임에 치유에 의해 획득된 예상 치유량을 표시합니다. 유의: 이 작업은 Gagorian의 DrDamage 애드온이 설치되어 있는 경우에 보다 낫게 기능합니다.",
	["Estimated heals"] = "예상 치유량",
	["Heal bar color"] = "치유바 색상",
	["Estimated heals"] = "예상 치유량",
	["Enable"] = "활성화",
	["Show overheal text"] = "과다 치유 문자 표시",
} or {}

local L = PitBull:L("PitBull-EstimatedHeals", localization)

local PitBull = PitBull
local PitBull_HealthBar = PitBull_HealthBar
local PitBull_EstimatedHeals
local spellamount
if DrDamage then
	PitBull_EstimatedHeals = PitBull:NewModule("EstimatedHeals", "LibRockHook-1.0", "LibRockEvent-1.0")
	spellamount = setmetatable({},{
		__index = function(self,key)
			self[key] = setmetatable({},{
				__index = function(t,k)
					-- Use the average heal amount non-crit
					local _,_,_,_,avg = DrDamage:RawNumbers(DrDamage:GetSpellInfo(key, k),key)
					t[k] = avg
					return avg
				end
			})
			return self[key]
		end
	})
else
	PitBull_EstimatedHeals = PitBull:NewModule("EstimatedHeals", "LibRockHook-1.0", "LibRockEvent-1.0", "LibParser-4.0")
	spellamount = setmetatable({},{ -- No way to tell the ranks with Parser events.
					-- We could guess by the rank of the last spellcast sent, but that will not
					-- always be consistant if the player is spamming heals (UNIT_SPELLCAST_SENT
					-- for the next spell may come before the combat log event)
		__index = function(t,k)
			t[k] = "0;0"
			return t[k]
		end
	})
end
local self = PitBull_EstimatedHeals
self.desc = L["Show the estimated health gain from heals on your PitBull frames. NOTE: This works a lot better if you have Gagorian's DrDamage running."]
local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local PitBull_HealthBar = PitBull:GetModule("HealthBar")
PitBull_EstimatedHeals:RegisterPitBullChildFrames('estHealBar', 'estOverhealText')

function PitBull_EstimatedHeals:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("EstimatedHeals")
	PitBull:SetDatabaseNamespaceDefaults("EstimatedHeals", "profile", {
		color = {0, 0.8, 0, 0.5},
		groups = {
			['*'] = {text = true},
		}
	})
end

function PitBull_EstimatedHeals:OnEnable()
	self:AddHook(PitBull_HealthBar, "UpdateHealth")
	self:AddEventListener("UNIT_SPELLCAST_SENT")
	self:AddEventListener("UNIT_SPELLCAST_STOP", "CastStop")
	self:AddEventListener("UNIT_SPELLCAST_INTERRUPTED", "CastStop")
	--self:AddEventListener("UNIT_SPELLCAST_FAILED", "CastStop")
	if DrDamage then
		self:AddEventListener("DrDamage_Update")
		self.OnHeal = nil
	else
		self:AddParserListener({
			eventType = "Heal",
			sourceID = "player",
			isCrit = false,
			recipientID_not = false,
			abilityName_in = watchspells,
		}, "OnHeal")
		self.DrDamage_Update = nil
	end
end

function PitBull_EstimatedHeals:OnHeal(info)
	local str = spellamount[info.abilityName]
	local amt, casts = str:match("^(%d+);(%d+)$")
	spellamount[info.abilityName] = math.floor(((amt*casts)+info.amount)/(casts+1))..";"..casts+1
end

function PitBull_EstimatedHeals:DrDamage_Update()
	for k in pairs(spellamount) do
		spellamount[k] = nil
	end
end

function PitBull_EstimatedHeals:UpdateHealth(object,unit,frame)
	self.hooks[object].UpdateHealth(object,unit,frame)
	if frame.estHealBar then
		self:PositionBar(frame)
	end
end

function PitBull_EstimatedHeals:PositionBar(frame)
	frame.estHealBar:ClearAllPoints()
	local db = PitBull_HealthBar.db.profile[frame.group]
	local n
	local v = frame.healthBar:GetValue()
	local over = v + frame.estHealBar:GetValue() - 1
	over = over > 0 and (over * UnitHealthMax(frame:GetUnit()))
	if over and self.db.profile.groups[frame.group].text then
		local text
		if frame.estOverhealText then
			text = frame.estOverhealText
		else
			text = newFrame('FontString', frame.estHealBar, 'OVERLAY')
			frame.estOverhealText = text
			text:SetFont(PitBull:GetFont())
			text:SetShadowColor( 0, 0, 0, 1)
			text:SetShadowOffset( 0.8, -0.8 )
		end
		text:SetText("+"..math.floor(over))
	else
		if frame.estOverhealText then
			frame.estOverhealText = delFrame(frame.estOverhealText)
		end
	end
	if frame.estHealBar.orientation == "HORIZONTAL" then
		local w = frame.healthBar:GetWidth()
		if db.deficit and db.reverse then
			n = w*v
		elseif db.deficit or db.reverse then
			n = w*v-(w*frame.estHealBar:GetValue())
		else
			n = w*v
		end
		frame.estHealBar:SetPoint("TOPLEFT", frame.healthBar.bg, "TOPLEFT", n, 0)
		if frame.estOverhealText then
			if n == w*v then
				frame.estOverhealText:SetPoint("LEFT", frame.healthBar.bg, "RIGHT")
			else
				frame.estOverhealText:SetPoint("RIGHT", frame.healthBar.bg, "LEFT")
			end
		end
	else
		local w = frame.healthBar:GetHeight()
		if db.deficit and db.reverse then
			n = w*v
		elseif db.deficit or db.reverse then
			n = w*v-(w*frame.estHealBar:GetValue())
		else
			n = w*v
		end
		frame.estHealBar:SetPoint("BOTTOMLEFT", frame.healthBar.bg, "BOTTOMLEFT", 0, n)
		if frame.estOverhealText then
			if n == w*v then
				frame.estOverhealText:SetPoint("BOTTOM", frame.healthBar.bg, "TOP")
			else
				frame.estOverhealText:SetPoint("TOP", frame.healthBar.bg, "BOTTOM")
			end
		end
	end
end

function PitBull_EstimatedHeals:UNIT_SPELLCAST_SENT(ns, event, casterid, spellname, spellrank, targetname)
	if casterid ~= "player" then
		return
	end
	if watchspells[spellname] then
		if spellrank then
			spellrank = tonumber(spellrank:match("(%d+)$"))
		else
			spellrank = 0
		end
		local spell = spellamount[spellname]
		local amount
		if type(spell) == "string" then
			amount = spell:match("^(%d+)")
		else
			amount = spell[spellrank]
		end
		if amount then
			for unit, frame in PitBull:IterateUnitFrames() do
				if frame:IsVisible() and UnitName(unit) == targetname and not self.db.profile.groups[frame.group].ignore then
					local hpmax = UnitHealthMax(unit)
					if hpmax > 0 and hpmax ~= 100 then
						local perc = amount / hpmax
						if perc > 1 then
							perc = 1
						end
						local estHealBar = frame.estHealBar or newFrame("StatusBar", frame)
						frame.estHealBar = estHealBar
						
						estHealBar:SetWidth(frame.healthBar:GetWidth())
						estHealBar:SetHeight(frame.healthBar:GetHeight())
						
						estHealBar:SetFrameLevel(frame.healthBar:GetFrameLevel()+1)
						
						estHealBar.orientation = frame.healthBar:GetOrientation()
						estHealBar:SetOrientation(estHealBar.orientation)
						
						estHealBar:SetMinMaxValues(0, 1)
						estHealBar:SetValue(perc)
						estHealBar:SetStatusBarTexture(PitBull:GetStatusBarTexture())
						estHealBar:SetStatusBarColor(unpack(self.db.profile.color))
						
						estHealBar:Show()
						
						self:PositionBar(frame)
					end
				end
			end
		end
	end
end

function PitBull_EstimatedHeals:CastStop(ns, event, casterid)
	if casterid == "player" then
		for _,frame in PitBull:IterateUnitFrames() do
			if frame.estHealBar then
				frame.estHealBar.orientation = nil
				frame.estHealBar = delFrame(frame.estHealBar)
			end
			if frame.estOverhealText then
				frame.estOverhealText = delFrame(frame.estOverhealText)
			end
		end
	end
end

function PitBull_EstimatedHeals:OnUpdateFrame(unit, frame)
	if frame.estHealBar then
		self:PositionBar(frame)
	end
end

function PitBull_EstimatedHeals:OnPopulateUnitFrame(unit, frame)
	
end

function PitBull_EstimatedHeals:OnClearUnitFrame(unit, frame)
	if frame.estHealBar then
		frame.estHealBar.orientation = nil
		frame.estHealBar = delFrame(frame.estHealBar)
	end
end

function PitBull_EstimatedHeals:OnUpdateStatusBarTexture(texture)
	for _,frame in PitBull:IterateUnitFrames() do
		if frame.estHealBar then
			frame.estHealBar:SetStatusBarTexture(texture)
		end
	end
end

-- Global Options
local function getColor()
	return unpack(PitBull_EstimatedHeals.db.profile.color)
end
local function setColor(r,g,b,a)
	PitBull_EstimatedHeals.db.profile.color = {r,g,b,a}
end
PitBull.options.args.global.args.estheals = {
	type = 'group',
	name = L["Estimated heals"],
	desc = L["Estimated heals"],
	args = {
		color = {
			type = 'color',
			name = L["Heal bar color"],
			desc = L["Heal bar color"],
			get = getColor,
			set = setColor,
			hasAlpha = true,
		},
	},
}
-- Unit/Group Specific Options
local function getDisabled(group)
	return PitBull_EstimatedHeals.db.profile.groups[group].ignore
end
local function getEnabled(group)
	return not PitBull_EstimatedHeals.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	PitBull_EstimatedHeals.db.profile.groups[group].ignore = not value
end
local function getText(group)
	return PitBull_EstimatedHeals.db.profile.groups[group].text
end
local function setText(group, value)
	PitBull_EstimatedHeals.db.profile.groups[group].text = value
end
PitBull_EstimatedHeals:RegisterPitBullOptionsMethod(function(group)
	return {
		name = L["Estimated heals"],
		desc = L["Estimated heals"],
		type = 'group',
		args = {
			ignore = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enable"],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
				order = 1,
			},
			text = {
				type = 'boolean',
				name = L["Show overheal text"],
				desc = L["Show overheal text"],
				get = getText,
				set = setText,
				passValue = group,
				disabled = getDisabled,
			},
		}
	}
end)
