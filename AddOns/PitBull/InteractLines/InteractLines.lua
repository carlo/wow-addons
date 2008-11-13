if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_InteractLines = PitBull:NewModule("InteractLines", "LibRockTimer-1.0", "LibParser-4.0")
local self = PitBull_InteractLines
PitBull:SetModuleDefaultState(self, false)
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Eye candy that shows lines connecting units that interact with each other."] = "유닛 서로간에 교류하는 연결 라인을 표시합니다.",
	["Interact lines"] = "상호 작용 라인",
	["Options for the interaction lines, drawing lines between units that interact with eachother."] = "유닛간에 서로 교류하는 라인을 그려내는 상호 작용 라인을 위한 옵션.",
	["Line alpha"] = "라인 투명도",
	["Change the alpha of all drawn lines."] = "그려진 모든 라인의 투명도를 변경합니다.",
	["Line duration"] = "라인 지속 시간",
	["Sets how long a interaction line should stay visible on the screen."] = "화면상에 보여질 상호 작용 라인의 지속 시간을 설정합니다.",
	["Heal color"] = "치유 색상",
	["Color for lines drawn as a result of units healing eachother."] = "유닛 서로간에 치유한 결과를 그려낸 라인을 위한 색상",
	["Damage color"] = "피해 색상",
	["Color for lines drawn as a result of units damaging eachother."] = "유닛 서로간에 피해를 입힌 결과를 그려낸 라인을 위한 색상",
	["Amount threshold"] = "한계량",
	["Line fades if damage/heal amount is below this number."] = "이 수치 이하로 피해/치유량이 내려가는 경우에 라인이 사라집니다.",
	["Enable interact lines"] = "상호 작용 라인 활성화",
	["Enables interaction lines for this unit type."] = "이 유닛 유형에 대해 상호 작용 라인 기능을 활성화합니다.",
} or {}

local L = PitBull:L("PitBull-InteractLines", localization)

self.desc = L["Eye candy that shows lines connecting units that interact with each other."]
local remove = table.remove
local UnitIsUnit = UnitIsUnit

local line_path = "Interface\\AddOns\\" .. debugstack():match("[d%.][d%.][O%.]ns\\(.-)\\[A-Za-z]-%.lua") .. "\\textures\\line"

local tableheap = {}
local function getTable()
	if tableheap[1] then
		local t = tableheap[1]
		remove(tableheap,1)
		return t
	end
	return {}
end
local function scrapTable(t)
	for k in pairs(t) do
		t[k] = nil
	end
	tableheap[#tableheap+1] = t
end

local looselines = {}
local activelines = {}
local function getFrame()
	if looselines[1] then
		local frame = looselines[1]
		activelines[#activelines+1] = frame
		remove(looselines,1)
		return frame
	end
	local frame = UIParent:CreateTexture(nil, "ARTWORK")
	frame:SetTexture(line_path)
	activelines[#activelines + 1] = frame
	return frame
end
local function scrapFrame(index, frame)
	if not frame then
		frame = activelines[index]
	end
	frame:ClearAllPoints()
	frame:Hide()
	
	frame.snd = nil
	frame.rcv = nil
	frame.startalpha = nil
	frame.starttime = nil
	frame.endtime = nil
	frame.type = nil
	
	looselines[#looselines+1] = frame
	remove(activelines,index)
end

local function positionLine(line)
	local ses = line.snd:GetScale()
	local ees = line.rcv:GetScale()
	
	local sx = (line.snd:GetLeft() + line.snd:GetRight()) / 2 * ses
	local sy = (line.snd:GetBottom() + line.snd:GetTop()) / 2 * ses
	local ex = (line.rcv:GetLeft() + line.rcv:GetRight()) / 2 * ees
	local ey = (line.rcv:GetBottom() + line.rcv:GetTop()) / 2 * ees
	
	--[[
	if line.snd.unit == 'targettargettarget' then
		local f = line.snd
		AceLibrary("AceConsole-2.0"):Print("::targettargettarget debug::")
		AceLibrary("AceConsole-2.0"):Print("left:",f:GetLeft())
		AceLibrary("AceConsole-2.0"):Print("right:",f:GetRight())
		AceLibrary("AceConsole-2.0"):Print("top:",f:GetTop())
		AceLibrary("AceConsole-2.0"):Print("bottom:",f:GetBottom())
		
		AceLibrary("AceConsole-2.0"):Print("ses:",f:GetBottom())
		
		AceLibrary("AceConsole-2.0"):Print("sx:",sx)
		AceLibrary("AceConsole-2.0"):Print("sy:",sy)
	end]]
	
	local dx,dy = ex - sx, ey - sy
	local cx,cy = (sx + ex) / 2, (sy + ey) / 2
	if (dx < 0) then
		dx,dy = -dx,-dy
	end
	local length = sqrt(dx^2 + dy^2)
	if length <= 0 then
		return
	end
	local s,c = -dy / length, dx / length
	local sc = s * c
	local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
	if (dy >= 0) then
		Bwid = ((length * c) - (32 * s)) * (32/60)
		Bhgt = ((32 * c) - (length * s)) * (32/60)
		BLx, BLy, BRy = (32 / length) * sc, s^2, (length / 32) * sc
		BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
		TRy = BRx
	else
		Bwid = ((length * c) + (32 * s)) * (32/60)
		Bhgt = ((32 * c) + (length * s)) * (32/60)
		BLx, BLy, BRx = s * s, -(length / 32) * sc, 1 + (32 / length) * sc
		BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
		TRx = TLy
	end
	local r,g,b
	if line.type == 'h' then
		r,g,b = unpack(self.db.profile.healcolor)
	else
		r,g,b = unpack(self.db.profile.damagecolor)
	end
	line:SetVertexColor(r,g,b,1)
	line:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
	line:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", cx + Bwid, cy + Bhgt)
	line:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", cx - Bwid, cy - Bhgt)
	line:SetAlpha(line.startalpha)
	line:Show()
end

local relationships = setmetatable({},{
	__index = function(t,k)
		local v = getTable()
		t[k] = v
		for unitid, frame in PitBull:IterateUnitFrames() do
			if UnitIsUnit(k,unitid) then
				v[#v+1] = frame
			end
		end
		return v
	end,
})

function PitBull_InteractLines:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("InteractLines")
	PitBull:SetDatabaseNamespaceDefaults("InteractLines", "profile", {
		alpha = 0.65,
		duration = 3,
		healcolor = { 0.1, 1, 0.1 },
		damagecolor = { 1, 0.1, 0.1 },
		threshold = 300,
		groups = {
			['*'] = {},
		}
	})
end



function PitBull_InteractLines:OnEnable()
	self:AddParserListener({eventType = "Heal"}, "OnHeal")
	self:AddParserListener({eventType = "Damage"}, "OnDamage")
	self:AddRepeatingTimer(0.15, "UpdateLines")
end

do
	local temp = {}
	function PitBull_InteractLines:OnHeal(info)
		if not info.sourceID and not info.recipientID then
			return
		end
		local sourceID = info.sourceID
		local recipientID = info.recipientID
		if not sourceID then
			for unit in PitBull:IterateUnitFrames() do
				if UnitName(unit) == info.sourceName then
					sourceID = unit
				end
			end
			if not sourceID then
				return
			end
		end
		if not recipientID then
			for unit in PitBull:IterateUnitFrames() do
				if UnitName(unit) == info.recipientName then
					recipientID = unit
				end
			end
			if not recipientID then
				return
			end
		end
		local amount = info.amount
		if sourceID == recipientID then
			amount = amount / 2
		end
		for _,startframe in ipairs(relationships[sourceID]) do
			if startframe:IsShown() then
				for _,endframe in ipairs(relationships[recipientID]) do
					if startframe ~= endframe and endframe:IsShown() then
						self:MakeLine('h',startframe,endframe,amount)
					end
				end
			end
		end
	end
	
	function PitBull_InteractLines:OnDamage(info)
		if not info.sourceID and not info.recipientID then
			return
		end
		local sourceID = info.sourceID
		local recipientID = info.recipientID
		if not sourceID then
			for unit in PitBull:IterateUnitFrames() do
				if UnitName(unit) == info.sourceName then
					sourceID = unit
				end
			end
			if not sourceID then
				return
			end
		end
		if not recipientID then
			for unit in PitBull:IterateUnitFrames() do
				if UnitName(unit) == recipientName then
					recipientID = unit
				end
			end
			if not recipientID then
				return
			end
		end
		local amount = info.amount
		if sourceID == recipientID then
			amount = amount / 2
		end
		for _,startframe in ipairs(relationships[sourceID]) do
			if startframe:IsShown() then
				for _,endframe in ipairs(relationships[recipientID]) do
					if startframe ~= endframe and endframe:IsShown() then
						self:MakeLine('d',startframe,endframe,amount)
					end
				end
			end
		end
	end
	
	function PitBull_InteractLines:MakeLine(linetype,startframe,endframe,amount)
		--!!2.1 check, delete!
		local alphacheck
		if IsLoggedIn then
			alphacheck = 'GetEffectiveAlpha'
		else
			alphacheck = 'GetAlpha'
		end
		--
		if startframe[alphacheck](startframe) == 0 or endframe[alphacheck](endframe) == 0 or self.db.profile.groups[startframe.group].ignore or self.db.profile.groups[endframe.group].ignore then
			return
		end
		local line = getFrame()
		line.snd = startframe
		line.rcv = endframe
		if amount < self.db.profile.threshold then
			line.startalpha = self.db.profile.alpha * (amount / self.db.profile.threshold)
		else
			line.startalpha = self.db.profile.alpha
		end
		line.starttime = GetTime()
		line.endtime = line.starttime + self.db.profile.duration
		line.type = linetype
		positionLine(line)
	end
end
do
	local function clearrel()
		for k,v in pairs(relationships) do
			scrapTable(v)
			relationships[k] = nil
		end
	end
	PitBull_InteractLines.OnUpdateFrame = clearrel
	PitBull_InteractLines.OnPopulateUnitFrame = clearrel
	PitBull_InteractLines.OnClearUnitFrame = clearrel
end

do
	local nukeframes = {}
	local function rsrt(a,b)
		return a > b
	end
	function PitBull_InteractLines:UpdateLines()
		for k in pairs(nukeframes) do
			nukeframes[k] = nil
		end
		local time = GetTime()
		for k,v in ipairs(activelines) do
			if v.endtime <= time then
				nukeframes[#nukeframes+1] = k
			else
				v:SetAlpha(v.startalpha*((v.endtime-time)/self.db.profile.duration))
			end
		end
		table.sort(nukeframes,rsrt)
		for _,v in ipairs(nukeframes) do
			scrapFrame(v)
		end
	end
	function PitBull_InteractLines:OnClearUnitFrame(unit, frame)
		for k in pairs(nukeframes) do
			nukeframes[k] = nil
		end
		for k,v in ipairs(activelines) do
			if v.snd == frame or v.rcv == frame then
				nukeframes[#nukeframes+1] = k
			end
		end
		table.sort(nukeframes,rsrt)
		for _,v in ipairs(nukeframes) do
			scrapFrame(v)
		end
		for k,v in pairs(relationships) do
			scrapTable(v)
			relationships[k] = nil
		end
	end
end
-- global options
local function getAlpha()
	return self.db.profile.alpha
end
local function setAlpha(v)
	self.db.profile.alpha = v
end
local function getDuration()
	return self.db.profile.duration
end
local function setDuration(v)
	self.db.profile.duration = v
end
local function getHealColor()
	return unpack(self.db.profile.healcolor)
end
local function setHealColor(r,g,b)
	self.db.profile.healcolor = {r,g,b}
end
local function getDamageColor()
	return unpack(self.db.profile.damagecolor)
end
local function setDamageColor(r,g,b)
	self.db.profile.damagecolor = {r,g,b}
end
local function getThreshold()
	return self.db.profile.threshold
end
local function setThreshold(v)
	self.db.profile.threshold = v
end
PitBull.options.args.global.args.interactlines = {
	type = 'group',
	name = L["Interact lines"],
	desc = L["Options for the interaction lines, drawing lines between units that interact with eachother."],
	args = {
		alpha = {
			type = 'number',
			name = L["Line alpha"],
			desc = L["Change the alpha of all drawn lines."],
			isPercent = true,
			min = 0,
			max = 1,
			step = 0.05,
			get = getAlpha,
			set = setAlpha,
		},
		duration = {
			type = 'number',
			name = L["Line duration"],
			desc = L["Sets how long a interaction line should stay visible on the screen."],
			min = 0.5,
			max = 10,
			step = 0.5,
			get = getDuration,
			set = setDuration,
		},
		healcolor = {
			type = 'color',
			name = L["Heal color"],
			desc = L["Color for lines drawn as a result of units healing eachother."],
			get = getHealColor,
			set = setHealColor,
		},
		damagecolor = {
			type = 'color',
			name = L["Damage color"],
			desc = L["Color for lines drawn as a result of units damaging eachother."],
			get = getDamageColor,
			set = setDamageColor,
		},
		threshold = {
			type = 'number',
			name = L["Amount threshold"],
			desc = L["Line fades if damage/heal amount is below this number."],
			min = 0,
			max = 5000,
			step = 250,
			get = getThreshold,
			set = setThreshold,
		},
	},
}
-- per group options
local function getEnabled(group)
	return not PitBull_InteractLines.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	PitBull_InteractLines.db.profile.groups[group].ignore = not value
end
PitBull_InteractLines:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'boolean',
		name = L["Enable interact lines"],
		desc = L["Enables interaction lines for this unit type."],
		get = getEnabled,
		set = setEnabled,
		passValue = group,
	}
end)

