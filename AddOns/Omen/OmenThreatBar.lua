OmenThreatBar = AceLibrary("AceOO-2.0").Class("AceEvent-2.0")
local media = LibStub("LibSharedMedia-2.0")
local Threat = AceLibrary("Threat-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Omen")
local math_floor = _G.math.floor
local OmenThreatBars = {}

local function FreeBar(bar)
	bar.used = false
end

local function animateBar()
	this.animatedTime = this.animatedTime + arg1
	local pct = min(1, this.animatedTime / this.totalAnimateTime)
	local delta = (this.destinationWidth - this.startWidth) * pct
	this.pTex:SetWidth(this.startWidth + delta)
	local texPct = (this.startWidth + delta) / this.totalWidth
	this.pTex:SetTexCoord(0, texPct, 0, 1)

	if pct == 1 then
		this:SetScript("OnUpdate", nil)
	end
end

local function updateBar(bar, w)
	bar:SetScript("OnUpdate", animateBar)
	bar.totalWidth = bar.tTex:GetWidth()
	bar.startWidth = bar.pTex:GetWidth()
	bar.destinationWidth = w
	bar.totalAnimateTime = 0.25
	bar.animatedTime = 0
end

local function doGlow()
	local this = this:GetParent()
	this.glowPulse = this.glowPulse + arg1
	local alpha = math.cos(this.glowPulse * this.glowPeriod) / 2 + 0.5
	this.gTex:SetVertexColor(1, alpha * 0.25, alpha * 0.25, alpha)	
end

local function GetBar(self, name)
	for k, v in ipairs(OmenThreatBars) do
		if not v.used then
			v.used = true
			return v
		end
	end
	
	if name then
		for k, v in ipairs(OmenThreatBars) do
			if k == name then
				error("Error: Bar '" .. name .. "' is already loaded!")
			end
		end
	end
	
	local barName = name or ("OmenThreatBar" .. #OmenThreatBars)
	
	local B = CreateFrame("Frame", barName, UIParent)
	B:SetFrameStrata("MEDIUM")
	B.Glow = CreateFrame("Frame", barName .. "Glow", B)
	B.Glow:SetPoint("TOPLEFT", B, "TOPLEFT", 0, 0)
	B.Glow:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 0, 0)
	B.used = true
	
	B:SetHeight(20)
	B:SetWidth(250)
	B:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

	B.Glow:SetFrameStrata("HIGH")
	B.gTex = B.Glow:CreateTexture()
	B.gTex:SetPoint("TOPLEFT", B.Glow, "TOPLEFT", -3, 3)	
	B.gTex:SetPoint("BOTTOMRIGHT", B.Glow, "BOTTOMRIGHT", 3, -3)
	B.gTex:SetDrawLayer("BORDER")
	B.gTex:SetBlendMode("ADD")
	B.gTex:SetVertexColor(1, 0, 0, 0)
	
	B:SetMovable(true)
	B:EnableMouse(true)	
	B:SetScript("OnMouseDown", function() this:StartMoving() end )
	B:SetScript("OnMouseUp",  function() this:StopMovingOrSizing() end )
	
	B:SetClampedToScreen(true)
	
	B.bTex = B:CreateTexture()
	B.bTex:SetPoint("TOPLEFT", B, "TOPLEFT", 0, 0)
	B.bTex:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 0, 0)
		
	B:SetFrameLevel(5)
	B:SetFrameStrata("MEDIUM")
	
	B.Tank = CreateFrame("Frame", barName .. "Player", B)
	B.Tank:SetFrameLevel(6)
	B.Tank:SetFrameStrata("MEDIUM")
	B.Tank:SetPoint("TOPLEFT", B, "TOPLEFT", 0, 0)
	B.Tank:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 0, 0)
	B.tTex = B.Tank:CreateTexture()
	B.tTex:SetPoint("TOPLEFT", B.Tank, "TOPLEFT", 0, 0)
	B.tTex:SetPoint("BOTTOMLEFT", B.Tank, "BOTTOMLEFT", 0, 0)
	B.tTex:SetWidth(50)

	B.Player = CreateFrame("Frame", barName .. "Player", B.Tank)
	B.Player:SetFrameLevel(7)
	B.Player:SetFrameStrata("MEDIUM")
	B.Player:SetPoint("TOPLEFT", B, "TOPLEFT", 0, 0)
	B.Player:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 0, 0)
	B.pTex = B.Player:CreateTexture()
	B.pTex:SetPoint("TOPLEFT", B.Player, "TOPLEFT", 0, -2)
	B.pTex:SetPoint("BOTTOMLEFT", B.Player, "BOTTOMLEFT", 0, 2)
	B.pTex:SetWidth(25)
	
	local t = B.Player:CreateFontString(nil, nil, "GameFontNormal")
	t:SetVertexColor(1,1,1,1)
	local font, size = t:GetFont()
	t:SetFont(font, 10 , "OUTLINE")
	t:SetText("Label")	
	t:SetPoint("LEFT", B, "LEFT", 7, 0)
	B.label = t
	
	local t = B.Player:CreateFontString(nil, nil, "GameFontNormal")
	t:SetVertexColor(1,1,1,1)
	local font, size = t:GetFont()
	t:SetFont(font, 8, "OUTLINE")
	t:SetText("Title")	
	t:SetPoint("BOTTOM", B, "TOP", 0, 2)
	B.title = t

	local t = B.Player:CreateFontString(nil, nil, "GameFontNormal")
	t:SetVertexColor(1,1,1,1)
	local font, size = t:GetFont()
	t:SetFont(font, 10, "OUTLINE")
	t:SetText("TPS")	
	t:SetPoint("LEFT", B, "LEFT", 60, 0)
	B.tpslabel = t
	
	B:SetResizable(true)
	local grip = CreateFrame("Button", "OmenResizeGrip", B)
	grip:SetNormalTexture([[Interface\AddOns\Omen\ResizeGrip]])
	grip:SetHighlightTexture([[Interface\AddOns\Omen\ResizeGrip]])
	grip:SetWidth(16)
	grip:SetHeight(16)
	grip:SetScript("OnMouseDown", function() this:GetParent():StartSizing() end)
	grip:SetScript("OnMouseUp", function() this:GetParent():StopMovingOrSizing() end )
	grip:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 5, -5)
	grip:SetFrameStrata("HIGH")
	B.Grip = grip
	-- B.Grip:Hide()
	
	B.Grip:SetScript("OnEnter", function() B.Grip:Show() end )
	B:SetScript("OnEnter", function() B.Grip:Show() end )
	B:SetScript("OnLeave", function() B.Grip:Hide() end )
	
	B:SetMinResize(50, 5)

	dewdrop:Register(B, "children", Omen.threatBarMenu)
		
	B:Hide()
		
	tinsert(OmenThreatBars, B)
	return B
end

function OmenThreatBar.prototype:LoadBar(dbNamespace)
	self.Bar = GetBar(self, dbNamespace)
	self.db = Omen:AcquireDBNamespace(dbNamespace)
	if not self.db.profile.playerName == UnitName("player") then return end
	self:InitBar()
end

function OmenThreatBar.prototype:CreateBar(tankName, tankUnit, texture, followTarget)
	self.Bar = GetBar(self)
	self.db = Omen:AcquireDBNamespace(self.Bar:GetName())
	self.db.profile.texture = texture

	self.db.profile.followTarget = followTarget
	self.db.profile.playerName = UnitName("player")
	if not followTarget then	
		self.db.profile.tankName = tankName
		self.db.profile.tankUnit = tankUnit
		self.db.profile.targetName = UnitName(tankUnit .. "target")
	else
		self.db.profile.targetName = UnitName("target")
	end
	self:InitBar()
end

local GLOBAL_TARGET
function OmenThreatBar.prototype:InitBar()
	GLOBAL_TARGET = Threat.GlobalTarget
	Omen.db.profile.ThreatBars[self.Bar:GetName()] = true
	self.Bar.parent = self
	
	if not Omen.LegitimateUnits[self.db.profile.tankUnit] then
		-- Omen:Print("Unit isn't legit: %s (%s)", self.db.profile.tankUnit, self.db.profile.tankName)
		self.db.profile.tankUnit = nil
	end
	if self.db.profile.followTarget then
		self.db.profile.tankName = UnitName("targettarget")
		self.db.profile.targetName = UnitName("targettargettarget")
	end
	
	self.Bar:Hide()
	self.Bar:SetAlpha(0)
	
	self.Bar.title:SetText(string.format("%s v. %s (%s)", self.db.profile.playerName or "", self.db.profile.tankName or L["No tank"], self.db.profile.targetName or L["No target"]))
	
	local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
	self.Bar.pTex:SetVertexColor(c.r, c.g, c.b, 0.8)
	self.Bar.tTex:SetVertexColor(1, 0.4, 0, 0.9)
	self.Bar.bTex:SetVertexColor(1,0,0, 1.0)
	
	if self.db.profile.Height then
		self.Bar:SetHeight(self.db.profile.Height)
		self.Bar:SetWidth(self.db.profile.Width)
	end
	
	self.Bar:SetScript("OnSizeChanged", function()
		this.parent.db.profile.Height = this:GetHeight()
		this.parent.db.profile.Width = this:GetWidth()
	end)
	
	self.tankThreat = 1
	self.playerThreat = 0
	self:UpdateTexture()
	
	self:RegisterEvent("Threat_ThreatUpdated")
	self:RegisterEvent("Threat_PartyChanged")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	tinsert(Omen.ThreatBars, self)
end

function OmenThreatBar.prototype:Threat_PartyChanged()
	if self.tankName then
		local partyID = Threat:GetUnitIDByUnitName(self.tankName)
		if partyID then
			self.tankUnit = partyID
		else
			self:Remove()
		end
	end
end

function OmenThreatBar.prototype:UpdateTexture()
	local tex = self.db.profile.texture
	if not tex then tex = "Blizzard" end
	self.Bar.bTex:SetTexture(media:Fetch("statusbar", tex))
	self.Bar.pTex:SetTexture(media:Fetch("statusbar", tex))
	self.Bar.tTex:SetTexture(media:Fetch("statusbar", tex))
	self.Bar.gTex:SetTexture(media:Fetch("statusbar", tex))
end

function OmenThreatBar.prototype:Zero()
	self.playerThreat = 0
	self.Bar.label:Hide()
	self.Bar.tpslabel:Hide()
	self:UpdateBars()
end

function OmenThreatBar.prototype:UNIT_TARGET(arg1)
	if not Threat:IsActive() then return end
	-- If followTarget then determine tank
	-- Else determine target
	local updated
	if self.db.profile.followTarget and UnitIsUnit("target", arg1) then
		local partyMemberName = UnitName("targettarget")
		local partyMemberUnit = Threat:GetUnitIDByUnitName(partyMemberName)
		if partyMemberUnit then
			self.db.profile.tankName = partyMemberName
			self.db.profile.tankUnit = partyMemberUnit
			updated = true
		end		
	elseif self.db.profile.tankUnit and not self.db.profile.followTarget and UnitIsUnit(arg1, self.db.profile.tankUnit) then
		-- Omen:Print("Updating target name for tank %s", self.db.profile.tankName)
		self.db.profile.targetName = UnitName(arg1 .. "target")
		updated = true
	end
	if updated then
		self.Bar.title:SetText(string.format("%s v. %s (%s)", self.db.profile.playerName, tostring(self.db.profile.tankName), tostring(self.db.profile.targetName)))
		self:UpdateLabel()
		self:UpdateBars()
	end	
end

function OmenThreatBar.prototype:PLAYER_TARGET_CHANGED()
	if not Threat:IsActive() then return end
	if not UnitName("target") then	
		self.playerThreat = 0
		return
	end
	if self.db.profile.followTarget then
		local partyMemberName = UnitName("targettarget")
		local partyMemberUnit = Threat:GetUnitIDByUnitName(partyMemberName)
		if partyMemberUnit then
			self.db.profile.tankName = partyMemberName
			self.db.profile.tankUnit = partyMemberUnit
			self.Bar.title:SetText(string.format("%s v. %s (%s)", self.db.profile.playerName, self.db.profile.tankName, tostring(self.db.profile.targetName)))
		end
	end
	self.db.profile.targetName = UnitName("target")

	self.tankThreat = Threat:GetThreat(self.db.profile.tankName, self.db.profile.targetName or GLOBAL_TARGET)
	self.playerThreat = Threat:GetThreat(self.db.profile.playerName, self.db.profile.targetName or GLOBAL_TARGET)

	if self.tankThreat == 0 then
		self.tankThreat = 1
	end
	self:UpdateBars()
	self:UpdateLabel()
end

function OmenThreatBar.prototype:UpdateLabel()
	if not self.db.profile.tankUnit then
		self:Zero()
		return
	end
	if not self.db.profile.targetName then
		self:Zero()
		return
	end
	if not self.Bar:IsVisible() then return end
	self.Bar.label:Show()
	self.Bar.tpslabel:Show()
	local pTPS = Threat:GetTPS(self.db.profile.playerName, self.db.profile.targetName)
	local tTPS = Threat:GetTPS(self.db.profile.tankName, self.db.profile.targetName)
	-- Omen:Print(string.format("sTPS, pTPS: %s, %s", tTPS, pTPS))
	local tpsDelta = pTPS - tTPS
	local tDelta = self.tankThreat - self.playerThreat
	
	local pct = string.format("%2.1f%%", self.playerThreat / self.tankThreat * 100)
	self.Bar.label:SetText(pct)

	local multi = 1.3
	if Threat:UnitInMeleeRange(self.db.profile.tankUnit .. "target") then
		multi = 1.1
	end

	local tto = string.format("%2.0f", ((self.tankThreat * multi) - self.playerThreat) / tpsDelta)
	if tpsDelta > 0 then
		self.Bar.tpslabel:SetText(string.format("+%2.0f TPS (%ss)", tpsDelta, tto))
	else
		self.Bar.tpslabel:SetText(string.format("%2.0f TPS", tpsDelta))
	end
end

function OmenThreatBar.prototype:UpdateBars()
	if not self.db.profile.tankUnit then return end
	if not self.Bar:IsVisible() then return end
	local multi = 1.3
	local bw
	if Threat:UnitInMeleeRange(self.db.profile.tankUnit .. "target") then
		multi = 1.1
	end
	bw = (self.Bar:GetWidth() - 8)  / multi
	self.Bar.tTex:SetWidth( bw )
	
	local pct = self.playerThreat / self.tankThreat
	
	local glowWindow = 0.4
	if pct > 1.3 - glowWindow then
		self:StartGlow(4.0)
	else
		self:EndGlow()
	end

	updateBar(self.Bar, max(0, min(multi, pct) * bw))
end

local function changeAlpha(bar, amt)
	local ba = bar:GetAlpha()
	local nba = min(1, max(0, ba + amt))
	bar:SetAlpha(nba)
	if (amt < 0 and nba <= 0) then
		bar:Hide()
		local p = bar.parent
		local name = bar:GetName() .. "Fade"
		if p and p:IsEventScheduled(name) then
			p:CancelScheduledEvent(name)
		end
	elseif (amt > 0 and nba >= (bar.parent.db.profile.Alpha or 1)) then
		bar:SetAlpha(bar.parent.db.profile.Alpha or 1)
		local p = bar.parent
		local name = bar:GetName() .. "Appear"
		if p:IsEventScheduled(name) then
			p:CancelScheduledEvent(name)
		end
	end
end

function OmenThreatBar.prototype:Appear()
	if not self:IsEventScheduled(self.Bar:GetName() .. "Appear") then
		local step = 1 / 27
		self.Bar:Show()
		self:ScheduleRepeatingEvent(self.Bar:GetName() .. "Appear", changeAlpha, step, self.Bar, step)
	end
end

function OmenThreatBar.prototype:Show()
	self.Bar:Show()
end

function OmenThreatBar.prototype:Fade()
	if not self:IsEventScheduled(self.Bar:GetName() .. "Fade") then
		local step = 1 / 27
		self:ScheduleRepeatingEvent(self.Bar:GetName() .. "Fade", changeAlpha, step, self.Bar, step * -1)
	end
end

function OmenThreatBar.prototype:StartUpdates()
	local n = "OmenBarAutoUpdate" .. self.Bar:GetName()
	if not self:IsEventScheduled(n) then
		self:ScheduleRepeatingEvent(n, self.UpdateLabel, 0.2, self)
	end
end

function OmenThreatBar.prototype:EndUpdates()
	local n = "OmenBarAutoUpdate" .. self.Bar:GetName()
	self:EndGlow()
	if self:IsEventScheduled(n) then
		self:CancelScheduledEvent(n)
	end
	self:Fade()
end

function OmenThreatBar.prototype:StartGlow(period)
	if not self.Bar.Glow:GetScript("OnUpdate") then
		self.Bar.glowPulse = 0
		self.Bar.glowPeriod = period
		self.Bar.Glow:SetScript("OnUpdate", doGlow)
	end
end

function OmenThreatBar.prototype:EndGlow()
	if self.Bar.Glow:GetScript("OnUpdate") then
		self.Bar.Glow:SetScript("OnUpdate", nil)
		self.Bar.gTex:SetVertexColor(0,0,0,0)
	end
end

function OmenThreatBar.prototype:PLAYER_REGEN_ENABLED()
	self:ScheduleEvent("OmenBarDisableAutoUpdate" .. self.Bar:GetName(), self.EndUpdates, 4, self)
end

function OmenThreatBar.prototype:Threat_ThreatUpdated(pName, pUnit, target)
	self:StartUpdates()
	if pUnit == "player" then
		self.playerThreat = Threat:GetThreat(pName, self.db.profile.targetName or GLOBAL_TARGET)
	elseif pName == self.db.profile.tankName then
		self:Appear()
		self.tankThreat = Threat:GetThreat(pName, self.db.profile.targetName or GLOBAL_TARGET)
		if self.tankThreat == 0 then
			self.tankThreat = 1
		end
	else
		return
	end	
	self:UpdateBars()
	self:UpdateLabel()
end

function OmenThreatBar.prototype:Remove()
	self:UnregisterEvent("Threat_ThreatUpdated")
	self:UnregisterEvent("UNIT_TARGET")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")

	dewdrop:Close()
	Omen:ResetDB(self.Bar:GetName(), "profile")
	self:EndUpdates()
	FreeBar(self.Bar)
	if self:IsEventScheduled(self.Bar:GetName() .. "Fade") then
		self:CancelScheduledEvent(self.Bar:GetName() .. "Fade")
	end
	if self:IsEventScheduled(self.Bar:GetName() .. "Appear") then
		self:CancelScheduledEvent(self.Bar:GetName() .. "Appear")
	end
	self.Bar:Hide()
	
	for i = 1, #Omen.ThreatBars do
		if Omen.ThreatBars[i] == self then
			tremove(Omen.ThreatBars, i)
			break
		end
	end

	Omen.db.profile.ThreatBars[self.Bar:GetName()] = nil
	self.Bar.parent = nil
	self = nil
end