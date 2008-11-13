local media = LibStub("LibSharedMedia-2.0")
local Threat = AceLibrary("Threat-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Omen")

local math_floor = _G.math.floor

local LegitimateUnits = {player = true, pet = true, playerpet = true, target = true, focus = true, mouseover = true, npc = true, NPC = true}
for i = 1, 4 do
	LegitimateUnits["party" .. i] = true
	LegitimateUnits["partypet" .. i] = true
	LegitimateUnits["party" .. i .. "pet"] = true
end
for i = 1, 40 do
	LegitimateUnits["raid" .. i] = true
	LegitimateUnits["raidpet" .. i] = true
	LegitimateUnits["raid" .. i .. "pet"] = true
end
setmetatable(LegitimateUnits, {__index=function(self, key)
	if type(key) ~= "string" then
		return false
	end
	if key:find("target$") and not key:find("^npc") then
		local value = self[key:sub(1, -7)]
		self[key] = value
		return value
	end
	self[key] = false
	return false
end})
Omen.LegitimateUnits = LegitimateUnits

local function ConvertToK(n)
	if not Omen.ActiveSkin.ShortThreatNumbers then return n, "" end
	if n > 1000 then
		return n / 1000, "k"
	end
	return n, ""
end

local function animateBar()
	this.animatedTime = this.animatedTime + arg1
	local pct = min(1, this.animatedTime / this.totalAnimateTime)
	local delta = (this.destinationWidth - this.startWidth) * pct
	this.tex:SetWidth(this.startWidth + delta)
	if not Omen.ActiveSkin.StretchBarTextures then
		local texPct = (this.startWidth + delta) / this.totalWidth
		this.tex:SetTexCoord(0, texPct, 0, 1)
	end
	if pct == 1 then
		this:SetScript("OnUpdate", nil)
	end
end

local function animatePercent(self, pct, dPct) 
	local w = self:GetParent():GetWidth() - 10
	self.labels.threatpercent:SetText(dPct)
	local width = w * pct
	if Omen.ActiveSkin.AnimateBars then
		self.totalWidth = w
		self.startWidth = self.tex:GetWidth()
		self.destinationWidth = width
		self.totalAnimateTime = 0.25
		self.animatedTime = 0
		if self.startWidth ~= self.destinationWidth then
			self:SetScript("OnUpdate", animateBar)
		end
	else
		self.tex:SetWidth(width)
		if not Omen.ActiveSkin.StretchBarTextures then
			self.tex:SetTexCoord(0, pct, 0, 1)
		end
	end	
end

local function getOffset(self, data)
	local bw = self.Anchor:GetWidth() - 8
	local amt = data[1] * bw
	if data[3] == "RIGHT" then
		amt = amt * -1
	end
	return amt
end

local lookup_table = {}
local function deepcopy(object)
	for k, v in pairs(lookup_table) do
		lookup_table[k] = v
	end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


local default_color = {r=1,g=0,b=0,a=1}
local default_player_color = {r=1,g=0,b=0,a=1}
local playerName

function Omen:LoadSkin(name)
	-- self:Print("Loading skin %q", name)
	local loadedSkin = self.db.account.Skins[name]
	local currentSettings = self.db.profile.CurrentSkinSettings
	for k, v in pairs(currentSettings) do
		currentSettings[k] = nil
	end
	_G.collectgarbage('collect') -- get rid of the copies of tables that we aren't using anymore
	for k, v in pairs(self.SkinDefaults) do
		currentSettings[k] = deepcopy((loadedSkin and loadedSkin[k]) or v)
	end	
	self:PatchSkin()
	self.ActiveSkin = currentSettings
end

function Omen:PatchSkin()
	local currentSettings = self.db.profile.CurrentSkinSettings
	for k, v in pairs(self.SkinDefaults) do
		if currentSettings[k] == nil then
			currentSettings[k] = deepcopy(v)
		elseif type(v) == "table" then
			for k2, v2 in pairs(v) do
				if currentSettings[k][k2] == nil then
					currentSettings[k][k2] = deepcopy(v2)
				end
			end
		end
	end
end

function Omen:SaveCurrentSkinAs(name)
	local skin = self.db.account.Skins[name]
	if not skin then
		self.db.account.Skins[name] = {}
		skin = self.db.account.Skins[name]
	end
	for k, v in pairs(self.ActiveSkin) do
		skin[k] = v
	end
	self:UpdateSkinList()
end
------------------------------
-- Skin updates and stuff 
------------------------------

function Omen:ApplySkin()
	local skin = self.ActiveSkin
	if not skin then self:Print(debugstack()) end
	--[[
	if not skin.Width then 
		self:PrintLiteral(skin)
		self:Print(debugstack())
	end
	]]--
	
	if skin.ShowTitle then
		self.Anchor.title:Show()
	else
		self.Anchor.title:Hide()
	end
	
	if Omen.db.profile.Locked then
		Omen.Grip:Hide()
	else
		Omen.Grip:Show()
	end
	
	-- Set the frame width
	self.Anchor:SetWidth(skin.Width)

	-- Set the frame background color
	local f = skin.BackdropColor
	self.Anchor:SetBackdropColor(f.r, f.g, f.b, f.a)

	-- Set the frame border color
	local f = skin.BorderColor
	self.Anchor:SetBackdropBorderColor(f.r, f.g, f.b, f.a)
	
	-- Set column positions
	self:UpdateLayout()
	
	-- Set bar heights, colors, textures, fonts
	for k, v in pairs(self.bars) do
		self:UpdateBarDisplay(k)
	end

	local ShowColumns = self.ActiveSkin.ShowColumns
	self.barsOffset = ((ShowColumns and 22) or 5) + self.titleOffset
	
	for k,v in ipairs(self.barList) do
		if skin.ShowAggroArrow and skin.AggroArrowColor then
			v.aggroArrow:SetVertexColor(skin.AggroArrowColor.r,
				skin.AggroArrowColor.g,
				skin.AggroArrowColor.b,
				skin.AggroArrowColor.a
			)
		end
		if v.myArrow then
			if skin.ShowSelfArrow and skin.SelfArrowColor then
				v.myArrow:SetVertexColor(skin.SelfArrowColor.r,
					skin.SelfArrowColor.g,
					skin.SelfArrowColor.b,
					skin.SelfArrowColor.a
				)
				v.myArrow:Show()
			else
				v.myArrow:Hide()
			end
		end
	end
	
	-- Set column visibility
	for k, v in pairs(self.Anchor.columns) do
		self:ToggleColumn(k, skin.ColumnVisibility[k])
		if not ShowColumns then
			v:Hide()
		end

		local font, size = v:GetFont()
		local cFontSettings = skin.CustomBarFonts["_COLUMNS_"]
		if cFontSettings and cFontSettings[4] then
			font = media:Fetch("font", cFontSettings[4])
		end
		size = (cFontSettings and cFontSettings[1]) or size
		v:SetFont(font, size, cFontSettings[2] or "")		
		if cFontSettings then
			local c = cFontSettings[3]
			v:SetVertexColor(c.r, c.g, c.b, 1)
		else
			v:SetVertexColor(1,1,1,1)
		end
	end
	
	if skin.ShowVersionNumber then
		Omen.Anchor.revision:Show()
		self.Anchor.outofDate:SetPoint("TOPLEFT", self.Anchor.revision, "BOTTOMLEFT", 0, -1)
	else
		Omen.Anchor.revision:Hide()
		Omen.Anchor.outofDate:SetPoint("TOPLEFT", self.Anchor, "BOTTOMLEFT", 4, 2)
	end
	
	self:ArrangeBars()
end

function Omen:UpdateBarDisplay(name)
	local skin = self.ActiveSkin
	playerName = playerName or UnitName("player")
	
	local v = self.bars[name]
	if not v then return end

	v.tex:SetTexture(media:Fetch("statusbar", skin.CustomBarTextures[name] or skin.BarTexture or "Blizzard"))
	
	local c
	
	c = skin.CustomColors[name] or (name == playerName and default_player_color) or RAID_CLASS_COLORS[v.unitclass or ""] or default_color
	v.barColor = c
	v.tex:SetVertexColor(c.r, c.g, c.b)
	
	local h = skin.CustomBarHeights[name] or skin.BarHeight
	v:SetHeight(h)
	
	-- Need to set fonts in here too
	local cFontSettings = skin.CustomBarFonts[name] or skin.CustomBarFonts["_BARS_"]
	for k, l in pairs(v.labels) do
		local font, size = l:GetFont()
		if cFontSettings and cFontSettings[4] then
			font = media:Fetch("font", cFontSettings[4])
		end
		if cFontSettings and cFontSettings[3] then
			l:SetVertexColor(cFontSettings[3].r, cFontSettings[3].g, cFontSettings[3].b, 1)
		end
		
		size = (cFontSettings and cFontSettings[1]) or size
		l:SetFont(font, size, cFontSettings[2] or "")
	end
end

-- Updates column and label positions
function Omen:UpdateLayout()
	for name, column in pairs(self.Anchor.columns) do
		local posData = self.ActiveSkin.ColumnOffsets[name]
		--[[
		if not posData then
			self:PrintLiteral(self.ActiveSkin)
		end
		]]--
		column:ClearAllPoints()
		column:SetPoint("TOP" .. posData[2], self.Anchor, "TOP" .. posData[3], getOffset(self, posData), self.titleOffset * -1 - 7)	

		for k, bar in pairs(self.bars) do
			local label = bar.labels[name]
			label:ClearAllPoints()
			label:SetPoint(posData[2], bar, posData[3], getOffset(self, posData), 0)	
		end
	end
end

function Omen:ToggleColumn(name, value, force)
	self.ActiveSkin.ColumnVisibility[name] = value
	if value then
		self.Anchor.columns[name]:Show()
		for k,v in pairs(self.bars) do
			v.labels[name]:Show()
		end
	else
		self.Anchor.columns[name]:Hide()
		for k,v in pairs(self.bars) do
			v.labels[name]:Hide()
		end
	end
end

------------------------------
-- Creation methods
------------------------------

local OMEN_BAR_INDEX = 0
function Omen:CreateBar(isPlayer)
	local f = CreateFrame("Button", "OmenBar" .. OMEN_BAR_INDEX, self.Anchor)
	OMEN_BAR_INDEX = OMEN_BAR_INDEX + 1
	f:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
	-- f:GetHighlightTexture():SetBlendMode("ADD")
	
	f:RegisterForDrag("LeftButton")
	f:RegisterForClicks("RightButtonDown")
	f:SetScript("OnEnter", function()
		if not this:IsVisible() then return end
		GameTooltip:SetOwner(this)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(this.unitname)
		GameTooltip:AddLine("|cffffffff" .. L["Right-click to set properties for"] .. " " .. this.unitname .. "|r")
		GameTooltip:AddLine("|cffffffff" .. L["Shift-right-click to open the Omen menu"] .. "|r")
		if this.validUnit and not UnitIsUnit(this.unitid, "player") then
			GameTooltip:AddLine("|cffffffff" .. L["Left-click and drag to create a pullout bar\ncomparing your threat to "] .. " " .. this.unitname .. "|r")
		end
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	f:SetScript("OnClick", function()
		if arg1 == "RightButton" then
			if IsShiftKeyDown() then
				dewdrop:Open(Omen.Anchor, "children", Omen.OnMenuRequest, 'cursorX', true, 'cursorY', true)
			else
				Omen.lastBarClicked = this
				dewdrop:Open(this, "children", Omen.barMenu, 'cursorX', true, 'cursorY', true)
			end
		end
	end)
	
	f:SetScript("OnDragStart", function()
		if Omen.db.profile.Locked then return end
		if this.unitid ~= "AGGRO_GAIN" and (not this.validUnit or this.unitid == "player") then return end
		local bar = OmenThreatBar:new()
		bar:CreateBar(this.unitname, this.unitid, Omen.ActiveSkin.BarTexture, this.unitid == "AGGRO_GAIN")
		bar:Appear()

		bar.Bar:ClearAllPoints()
		local x, y = GetCursorPosition()
		x = x / UIParent:GetScale()
		y = y / UIParent:GetScale()
		bar.Bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
		bar.Bar:SetFrameStrata("HIGH")
		bar.Bar:StartMoving()
		bar.Bar:SetFrameLevel(5)
		
		bar.Bar:SetScript("OnReceiveDrag", function()
			this:StopMovingOrSizing()
		end)
		bar.Bar.Player:SetScript("OnReceiveDrag", function()
			this:StopMovingOrSizing()
		end)
		bar.Bar.Tank:SetScript("OnReceiveDrag", function()
			this:StopMovingOrSizing()
		end)
		bar.Bar.Glow:SetScript("OnReceiveDrag", function()
			this:StopMovingOrSizing()
		end)

		local level = bar.Bar:GetFrameLevel()
	end)
	
	f.tex = f:CreateTexture()
	f.tex:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	f.tex:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
	f.tex:SetWidth(25)
	
	if isPlayer then
		f.myArrow = f:CreateTexture()
		f.myArrow:SetTexture([[Interface\AddOns\Omen\arrow]])
		f.myArrow:SetPoint("RIGHT", f, "LEFT", -5, 0)
		f.myArrow:SetTexCoord(0, 0.5, 0, 1)
		f.myArrow:SetWidth(6)
		f.myArrow:SetHeight(12)
		f.myArrow:Show()
	end
	
	f.aggroArrow = f:CreateTexture()
	f.aggroArrow:SetTexture([[Interface\AddOns\Omen\arrow]])
	f.aggroArrow:SetPoint("LEFT", f, "RIGHT", 5, 0)
	f.aggroArrow:SetTexCoord(0.5, 1, 0, 1)
	f.aggroArrow:SetWidth(6)
	f.aggroArrow:SetHeight(12)	
	f.aggroArrow:Hide()	
	
	f.threatVal = 0
	
	self:CreateLabels(f)

	f.SetPercent = animatePercent
	return f
end

function Omen:CreateLabels(bar)
	local skin = self.ActiveSkin
	bar.labels = {}
	local c = self.Anchor.columns
	for name, column in pairs(c) do
		local t = bar:CreateFontString(nil, nil, "GameFontNormal")
		t:SetVertexColor(1,1,1,1)
		t:SetText("-" .. name .. "-")
		bar.labels[name] = t
	end
end

function Omen:CreateColumn(name, label)
	local t = self.Anchor:CreateFontString(nil, nil, "GameFontNormal")
	t:SetVertexColor(1,1,1,1)
	t.name = name
	t:SetText(label)
	self.Anchor.columns[name] = t
end

function Omen:CreateAggroGainBar(name)
	local bar = self:addOrGetBar(name, "AGGRO_GAIN")
	bar.labels.tps:SetText("")
	bar.labels.fight_tps:SetText("")
	self.AggroBar = bar
end

------------------------------------------------------
-- UI update stuff
------------------------------------------------------

function Omen:SetAnchorWidth(width)
	self.Anchor:SetWidth(width)
	self:ApplySkin()
end

function Omen:ArrangeBars()	
	if not self.Anchor:IsVisible() then return end
	local threatTarget = self.watchedUnitID

	local aggroHolderAggro = 0
	if threatTarget then	
		if Threat:UnitInMeleeRange(threatTarget) then
			aggroHolderAggro = self:UpdateAggroGainBar(1.1)
		else
			aggroHolderAggro = self:UpdateAggroGainBar(1.3)
		end
	end
	
	if not self.db.profile.ShowAggroGain and self.AggroBar then
		self.AggroBar.threatVal = 0
	end
	
	table.sort(self.barList, function(a,b)
		return b.threatVal < a.threatVal
	end)
	
	local lastBar = nil
	local maxThreat = -1
	local barCt = 0
	local tHt = 0
	local gotPlayer = false
	local showPlayer = self.db.profile.AlwaysShowSelf
	local maxBars = self.db.profile.MaxBars
	local showKTM = self.db.profile.ShowKtmData
	
	if showPlayer then maxBars = maxBars - 1 end
	if aggroHolderAggro == 0 then
		aggroHolderAggro = self.barList[1] and self.barList[1].threatVal
	end
	local aggroBar = self.AggroBar
	local showAggro = self.ActiveSkin.ShowAggroArrow 
	local lastWithAggro = self.lastWithAggro
	
	for k,v in pairs(self.barList) do
		local isPlayer = v.unitid == "player" and showPlayer and v.threatVal > 0
		if isPlayer or (barCt < maxBars and v.threatVal > 0 and (showKTM or not v.isForeign) and (self.db.profile.Classes[v.unitclass] or not v.validUnit)) then
			if v.unitname == lastWithAggro and showAggro then
				v.aggroArrow:Show()
			else
				v.aggroArrow:Hide()
			end
			if maxThreat == -1 then
				maxThreat = v.threatVal
			end
			v:Show()
			v:ClearAllPoints()
			
			local displayPercent
			if aggroHolderAggro and aggroHolderAggro > 0 then
				displayPercent = math_floor(v.threatVal / aggroHolderAggro * 100) .. "%"
			else
				displayPercent = "--.-%"
			end
			v:SetPercent(v.threatVal / maxThreat, displayPercent)
			if lastBar then
				v:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, 0)
				v:SetPoint("TOPRIGHT", lastBar, "BOTTOMRIGHT", 0, 0)
			else
				v:SetPoint("TOPLEFT", self.Anchor, "TOPLEFT", 5, self.barsOffset * -1)
				v:SetPoint("TOPRIGHT", self.Anchor, "TOPRIGHT", -5, self.barsOffset * -1)
			end
			v.pointsClear = false
			lastBar = v
			tHt = tHt + v:GetHeight()
			if isPlayer then
				maxBars = maxBars + 1
			end
			barCt = barCt + 1
		else
			if not v.pointsClear then
				v:ClearAllPoints()
				v.pointsClear = true
			end
			v:Hide()
		end
	end
	self.Anchor:SetHeight(max(22, tHt + self.barsOffset + 5))
end

function Omen:Clear()
	if not self.barList then return end
	for k, v in pairs(self.barList) do
		v.threatVal = 0
		v.targetThreat = 0
		v.globalThreat = 0
		v:Hide()
	end
	self.Anchor:SetHeight(max(22, self.barsOffset + 5))
end

function Omen:UpdateAggroGainBar(multiplier)
	local aggroToBeat = 0
	
	if not self.AggroBar then return end

	if not self.watchedUnitID then return end
	local bar = self.bars[self.lastWithAggro]
	if bar then
		aggroToBeat = bar.threatVal
	end	

	self.AggroBar.threatVal = aggroToBeat * multiplier
	local threatVal, isK = ConvertToK(self.AggroBar.threatVal)
	self.AggroBar.labels.threat:SetText(string.format("%2.1f%s", threatVal, isK))
	return aggroToBeat
end

function Omen:ShowTest()
	local pNum = GetNumPartyMembers()
	local rNum = GetNumRaidMembers()

	local uName = UnitName("player")
	if not self.bars[pName] then
		self:addOrGetBar(uName, "player")
	end

	uName = UnitName("pet")
	if uName then
		self:addOrGetBar(uName, "pet")
	end

	local pName
	for i = 1, pNum do
		pName = UnitName("party" .. i)
		if pName then
			self:addOrGetBar(pName, "party" .. i)
		end
		pName = UnitName("party" .. i .. "pet")
		if pName then
			self:addOrGetBar(pName, "party" .. i .. "pet")
		end
	end
	
	for i = 1, rNum do
		pName = UnitName("raid" .. i)
		if pName then
			self:addOrGetBar(pName, "raid" .. i)
		end
		pName = UnitName("raid" .. i .. "pet")
		if pName then
			self:addOrGetBar(pName, "raid" .. i .. "pet")
		end
	end	
	
	for i = 1, (self.db.profile.MaxBars - #self.barList) do
		pName = "* Test-" .. i
		self:addOrGetBar(pName, "TEST_BAR")
	end
		
	table.sort(self.barList, function(a,b)
		return a.unitname < b.unitname
	end)

	local lastVal = 7500
	for _, v in ipairs(self.barList) do
		lastVal = lastVal + 2500
		v.threatVal = lastVal
		v.tex:SetWidth(0)
		v.labels.threat:SetText(v.threatVal)
	end
	local v = self.AggroBar
	v.threatVal = lastVal + 2500
	v.threatVal = lastVal + 2500
	v.tex:SetWidth(0)
	v.labels.threat:SetText(v.threatVal)
	
	for k,v in ipairs(Omen.ThreatBars) do
		v:Appear()
	end
	self:ApplySkin()
end

function Omen:SetAnchors(useDB)
	local t = self.db.profile.GrowUp
	local x, y
	if useDB then
		x, y = self.db.profile.PositionX, self.db.profile.PositionY
		if not x and not y then
			Omen.Anchor:ClearAllPoints()
			Omen.Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			return
		end
	elseif t then
		x, y = self.Anchor:GetLeft(), self.Anchor:GetBottom()
	else
		x, y = self.Anchor:GetLeft(), self.Anchor:GetTop()
	end
	Omen.Anchor:ClearAllPoints()
	if t then
		Omen.Anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
	else
		Omen.Anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
	self.db.profile.PositionX, self.db.profile.PositionY = x, y
end

function Omen:addOrGetBar(name, unit)
	if self.bars[name] then return self.bars[name] end
	local bar = self:CreateBar(LegitimateUnits[unit] and UnitIsUnit("player", unit))
	bar.unitid = unit
	bar.unitname = name
	bar.targetThreat = 0
	bar.globalThreat = 0	
	local foreign = ""
	if LegitimateUnits[unit] then
		bar.validUnit = true
		bar.unitclass = select(2, UnitClass(unit))
		bar.isForeign = Threat:IsUsingForeignThreatSource(name)
		if bar.isForeign then
			foreign = "*"
		end
	else
		bar.validUnit = false
	end
		
	bar.labels.name:SetText(name .. foreign)
	
	self.bars[name] = bar
	tinsert(self.barList, bar)
	self:ApplySkin()
	return bar
end
