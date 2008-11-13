--[[
Copyright (c) 2007, Hendrik Leppkes < h.leppkes@gmail.com >
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are 
met:

    * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above 
       copyright notice, this list of conditions and the following 
       disclaimer in the documentation and/or other materials provided 
       with the distribution.
    * Neither the name of the Bartender3 Development Team nor the names of 
       its contributors may be used to endorse or promote products derived 
       from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--[[ $Id: Bar.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49903 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local dewdrop = AceLibrary("Dewdrop-2.0")

local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

local table_insert = table.insert
local table_remove = table.remove
local math_floor = math.floor

local function onUpdateFunc(bar, elapsed) 
	local self = bar.class
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.2 then
		self:OnUpdate(self.elapsed)
		self.elapsed = 0
	end
end

Bartender3.Class.Bar = Bartender3.Class:CreatePrototype()
local barprototype = Bartender3.Class.Bar.prototype

function barprototype:init(id, config, statebar)
	self.id = id
	self.config = config
	self.statebar = statebar
	self.barname = L["Bar %s"]:format(self.id)
	if self.statebar and self.id == 1 then self.mainbar = true end
	
	self:CreateBarFrame()
	
	table_insert(Bartender3.bars, self)
	
end

function barprototype:ChangeProfile(config)
	self.config = config
end

function barprototype:CreateBarFrame()
	local name = "BT3Bar"..self.id
	local frame = CreateFrame("Button", name, UIParent, self.statebar and "SecureStateDriverTemplate")
	frame.class = self
	frame:EnableMouse(false)
	frame:SetMovable(true)
	--frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("RightButtonDown", "LeftButtonUp")
	frame:SetWidth(10)
	frame:SetHeight(10)
	frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 3, top = 3, bottom = 5},})
	frame:SetBackdropColor(0, 0, 0, 0)
	frame:SetBackdropBorderColor(0.5, 0.5, 0, 0)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame.Text = frame:CreateFontString(nil, "ARTWORK")
	frame.Text:SetFontObject(GameFontNormal)
	frame.Text:SetText()
	frame.Text:Show()
	frame.Text:ClearAllPoints()
	frame.Text:SetPoint("CENTER", frame, "CENTER",0,0)
	if self.config.Hide then frame:Hide() else frame:Show() end
	self.frame = frame
	
	self.elapsed = 0
	if self.config.FadeOut then frame:SetScript("OnUpdate", onUpdateFunc ) end
end

function barprototype:OnUpdate(elapsed)
	if self.config.FadeOut then
		if MouseIsOver(self.frame) and self.faded then
			self.frame:SetAlpha(self.config.Alpha)
			self.faded = nil
			if self.buttonobjects then
				for k,v in pairs(self.buttonobjects) do
					v:UpdateCooldown()
				end
			end
		elseif not MouseIsOver(self.frame) and not self.faded then
			self.frame:SetAlpha(0)
			self.faded = true
			for k,v in pairs(self.buttons) do
				if v.cooldown then v.cooldown:Hide() end
			end
		end
	end
end

function barprototype:SetFadeOut(fade)
	self.config.FadeOut = fade
	self.faded = nil
	if not fade then
		self.frame:SetAlpha(self.config.Alpha)
		self.frame:SetScript("OnUpdate", nil)
	else
		self.frame:SetScript("OnUpdate", onUpdateFunc)
	end
end

local function onEnterFunc(bar)
	bar:SetBackdropBorderColor(0.5, 0.5, 0, 1)
end

local function onLeaveFunc(bar)
	bar:SetBackdropBorderColor(0, 0, 0, 0)
end

local function onDragStartFunc(bar)
	if Bartender3.db.profile.Sticky and StickyFrames then
		local frames = {}
		for k,v in pairs(Bartender3.bars) do
			if v.frame ~= bar then table_insert(frames, v.frame) end
		end
		local p = 8 - bar.class.config.Padding
		StickyFrames:StartMoving(bar, frames, p, p, p, p)
	else
		bar:StartMoving()
	end
	bar:SetBackdropBorderColor(0, 0, 0, 0)
end

local function onDragStopFunc(bar)
	local self = bar.class
	if Bartender3.db.profile.Sticky and StickyFrames then
		StickyFrames:StopMoving(bar)
	else
		bar:StopMovingOrSizing()
	end
	self:SavePosition()
end

local function onClickFunc(bar, button, down)
	local self = bar.class
	if button == "RightButton" then
		self:ShowBarOptions()
	elseif button == "LeftButton" then
		self:ToggleVisibilty()
	end
end

function barprototype:UnlockFrames()
	local frame = self.frame
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", onEnterFunc)
	frame:SetScript("OnLeave", onLeaveFunc)
	frame:SetScript("OnDragStart", onDragStartFunc)
	frame:SetScript("OnDragStop", onDragStopFunc)
	frame:SetScript("OnClick", onClickFunc)
	if self.config.Hide then
		frame:SetBackdropColor(1, 0, 0, 0.5)
	else
		frame:SetBackdropColor(0, 1, 0, 0.5)
	end
	frame:SetFrameLevel(3)
	frame.Text:SetText(self.barname)
	frame:Show()
	if self.config.FadeOut then
		frame:SetScript("OnUpdate", nil)
		frame:SetAlpha(self.config.Alpha)
		self.faded = nil
	end
end

function barprototype:LockFrames()
	local frame = self.frame
	onDragStopFunc(frame)
	frame:EnableMouse(false)
	frame:SetScript("OnEnter", nil)
	frame:SetScript("OnLeave", nil)
	frame:SetScript("OnDragStart", nil)
	frame:SetScript("OnDragStop", nil)
	frame:SetScript("OnClick", nil)
	frame:SetBackdropColor(0, 0, 0, 0)
	frame:SetBackdropBorderColor(0, 0, 0, 0)
	frame.Text:SetText("")
	--frame:SetFrameLevel(1)
	if self.config.Hide then self.frame:Hide() else self.frame:Show() end
	if self.config.FadeOut then
		frame:SetScript("OnUpdate", onUpdateFunc)
	end
end

-- This function will not work in combat
function barprototype:ToggleVisibilty()
	if InCombatLockdown() then return end -- to avoid a message, you never know
	self.config.Hide = not self.config.Hide
	if self.config.Hide and Bartender3.unlock then
		self.frame:SetBackdropColor(1, 0, 0, 0.5)
	elseif self.config.Hide then
		self.frame:Hide()
	elseif Bartender3.unlock then
		self.frame:SetBackdropColor(0, 1, 0, 0.5)
	else
		self.frame:Show()
	end
end

function barprototype:RefreshLayout()
	if InCombatLockdown() then return end -- to avoid a message, you never know
	self:RefreshScale()
	self:RefreshButtonLayout()
	self:RefreshAlpha()
	self:LoadPosition()
	if self.config.Hide and not Bartender3.unlock and self.config.Enabled then self.frame:Hide() else self.frame:Show() end
end

function barprototype:LoadPosition()
	local x, y, s = self.config.PosX, self.config.PosY, self.frame:GetEffectiveScale()
	local defaultx, defaulty, defaultanchor = (Bartender3.defaultpositions[self.id].PosX) or 0, (Bartender3.defaultpositions[self.id].PosY) or 0, Bartender3.defaultpositions[self.id].Anchor or "BOTTOMLEFT"
	if x and y then
		x,y = x/s, y/s
	end
	self.frame:ClearAllPoints()
	self.frame:SetPoint("BOTTOMLEFT", UIParent, x and "BOTTOMLEFT" or defaultanchor, x or defaultx, y or defaulty)
end

function barprototype:SavePosition()
	local frame = self.frame
	local x,y = frame:GetLeft(), frame:GetBottom()
	local s = frame:GetEffectiveScale()
	x,y = x*s,y*s
	self.config.PosX = x
	self.config.PosY = y
end

function barprototype:RefreshButtonLayout()
	local buttons = #self.buttons
	local Rows = self.config.Rows or 1
	local ButtonPerRow = math_floor(buttons / Rows + 0.5) -- just a precaution
	Rows = math_floor(buttons / ButtonPerRow + 0.5)
	local Padding = self.config.Padding or 0
	self.frame:SetWidth(self.buttonwidth * ButtonPerRow + ((ButtonPerRow - 1) * Padding) + 8)
	self.frame:SetHeight(self.buttonheight * Rows + ((Rows - 1) * Padding) + 8)
	for i=1,buttons do
		local button = self.buttons[i]
		button:ClearAllPoints()
		if i > 1 and ((i-1) % ButtonPerRow) == 0 then
			button:SetPoint("TOPLEFT", self.buttons[i-ButtonPerRow], "BOTTOMLEFT", 0, self.specialmicromenu and -(Padding - 21) or -Padding)
		elseif i > 1 then
			button:SetPoint("TOPLEFT", self.buttons[i-1], "TOPRIGHT", Padding, 0)
		else
			button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 5, self.specialmicromenu and 18 or -3)
		end
	end
end

function barprototype:RefreshStyle()
	local style = self.config.Style
	for i,v in pairs(self.buttons) do
		Bartender3:RefreshStyle(v, self)
	end
end

function barprototype:RefreshScale()
	self.frame:SetScale(self.config.Scale or 1)
	self:LoadPosition()
end

function barprototype:RefreshAlpha()
	for i,v in pairs(self.buttons) do
		v:SetAlpha(self.config.Alpha or 0)
	end
end

function barprototype:InitOptions()
	self.optionstable = Bartender3:CreateBarOptions(self.id, self.barname, not self.statebar)
	if self.optionstable.args.rows then self.optionstable.args.rows.max = ( #self.buttons > 1 ) and #self.buttons or 2 end
end

-- config functions

function barprototype:SetRows(r)
	local maxbuttons = #self.buttons
	self.config.Rows = r
	self:RefreshButtonLayout()
end

function barprototype:SetPadding(r)
	self.config.Padding = r
	self:RefreshButtonLayout()
end

function barprototype:SetScale(s)
	self.config.Scale = s
	self:RefreshScale()
end

function barprototype:SetAlpha(a)
	self.config.Alpha = a
	self:RefreshAlpha()
end

function barprototype:SetStyle(s)
	self.config.Style = s
	self:RefreshStyle()
end

function barprototype:SetShowGrid(s)
	self.config.ShowGrid = s
	for i,v in pairs(self.buttonobjects) do
		if s then
			v:ShowGrid(true)
		else
			v:HideGrid(true)
		end
	end
end

function barprototype:ShowBarOptions()
	if InCombatLockdown() then return end
	dewdrop:Open(self.frame, 'children', function() dewdrop:FeedAceOptionsTable(self.optionstable) end, 'cursorX', true, 'cursorY', true)
end
