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

--[[ $Id: Button.lua 49924 2007-09-26 20:24:17Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49924 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 16:24:17 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

Bartender3.Class.Button = Bartender3.Class:CreatePrototype()
local prototype = Bartender3.Class.Button.prototype
local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

local _G = _G

local function ShortenKeyBinding(text)
	text = text:gsub("CTRL--", L["|c00FF9966C|r"])
	text = text:gsub("STRG--", L["|c00CCCC00S|r"])
	text = text:gsub("ALT--", L["|c009966CCA|r"])
	text = text:gsub("SHIFT--", L["|c00CCCC00S|r"])
	text = text:gsub(L["Num Pad "], L["NP"])
	text = text:gsub(L["Mouse Button "], L["M"])
	text = text:gsub(L["Middle Mouse"], L["MM"])
	text = text:gsub(L["Backspace"], L["Bs"])
	text = text:gsub(L["Spacebar"], L["Sp"])
	text = text:gsub(L["Delete"], L["De"])
	text = text:gsub(L["Home"], L["Ho"])
	text = text:gsub(L["End"], L["En"])
	text = text:gsub(L["Insert"], L["Ins"])
	text = text:gsub(L["Page Up"], L["Pu"])
	text = text:gsub(L["Page Down"], L["Pd"])
	text = text:gsub(L["Down Arrow"], L["D"])
	text = text:gsub(L["Up Arrow"], L["U"])
	text = text:gsub(L["Left Arrow"], L["L"])
	text = text:gsub(L["Right Arrow"], L["R"])
	
	return text
end

local function onEnterFunc(button)
	local tt = Bartender3.db.profile.Tooltip
	if tt == "enabled" or (tt == "nocombat" and not InCombatLockdown()) then 
		button.class:SetTooltip() 
	end
end

local function onLeaveFunc(button)
	if GameTooltip:IsOwned(button) then
		GameTooltip:Hide()
	end
end

local function onAttributeChangedFunc(button, attr)
	local self = button.class
	if attr == "state-parent" then
		self:UpdateButton()
	end
end

local function onDragStartFunc(button)
	local self = button.class
	if ( not Bartender3.db.profile.ButtonLock or IsShiftKeyDown()) then
		PickupAction(self.action)
		self:UpdateButton()
		self:UpdateFlash()
	end
end

local function onUpdateFunc(button, elapsed) 
	local self = button.class
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.2 then
		self:OnUpdate(self.elapsed)
		self.elapsed = 0
	end
end

local function onEventFunc(button, event)
	local self = button.class
	self:BaseEventHandler(event)
	if self.eventsregistered then
		self:ButtonEventHandler(event)
	end
end

local function updateStateFunc(button)
	local self = button.class
	self:UpdateState()
end

function prototype:init(parent, id)
	self.parent = parent
	self.id = id
	self.rid = self.id - ( self.parent.id - 1 ) * 12
	
	self.showgrid = 0
	self.flashing = 0
	self.flashtime = 0
	self.outOfRange = false
	self.elapsed = 0
	self.action = 0
	
	self:CreateButtonFrame()
end

-- CreateButtonFrame will NOT anchor the button, you HAVE to do that.
function prototype:CreateButtonFrame()
	local name = "BT3Button"..self.id
	self.frame = CreateFrame("CheckButton", name, self.parent.frame, "SecureActionButtonTemplate, ActionButtonTemplate")
	local frame = self.frame
	
	frame.class = self
	frame:RegisterForClicks("AnyUp")
	frame:RegisterForDrag("LeftButton", "RightButton")
	
	frame:SetScript("OnUpdate", onUpdateFunc)
	frame:SetScript("OnEnter", onEnterFunc)
	frame:SetScript("OnLeave", onLeaveFunc)
	frame:SetScript("OnAttributeChanged", onAttributeChangedFunc)
	frame:SetScript("OnDragStart", onDragStartFunc)
	frame:SetScript("OnEvent", onEventFunc)
	frame:SetScript("PostClick", updateStateFunc)
	
	frame.icon = _G[("%sIcon"):format(name)]
	frame.border = _G[("%sBorder"):format(name)]
	frame.cooldown = _G[("%sCooldown"):format(name)]
	frame.macroName = _G[("%sName"):format(name)]
	frame.hotkey = _G[("%sHotKey"):format(name)]
	frame.count = _G[("%sCount"):format(name)]
	frame.flash = _G[("%sFlash"):format(name)]
	frame.flash:Hide()
	
	--frame:SetPushedTexture("")
	frame:SetNormalTexture("")
	
	local oldNT = _G[("%sNormalTexture"):format(name)]
	oldNT:Hide()
	
	frame.normalTexture = frame:CreateTexture(("%sBTNT"):format(name))
	frame.normalTexture:SetAllPoints(oldNT)
	
	frame.pushedTexture = frame:GetPushedTexture()
	frame.highlightTexture = frame:GetHighlightTexture()
	
	frame.textureCache = {}
	frame.textureCache.pushed = frame.pushedTexture:GetTexture()
	frame.textureCache.highlight = frame.highlightTexture:GetTexture()
	
	self.parent.frame:SetAttribute("addchild", frame)
	frame:SetAttribute("type", "action")
	frame:SetAttribute("action", self.id)
	frame:SetAttribute("useparent-unit", true)
	frame:SetAttribute("useparent-statebutton", true)
	frame:SetAttribute("hidestates", "-1")
	
	self:SetStateAction(0, self.id)
	
	self:UpdateButton()
	
	self:RegisterBarEvents()
end

function prototype:SetStateAction(state, action)
	for i=1,2 do
		self.frame:SetAttribute(("*action-S%d%d"):format(state, i), action)
	end
end

function prototype:PagedID()
	if not self.action then self:RefreshAction() end
	return self.action
end

-- will return true if the action actually changed
function prototype:RefreshAction()
	local oldaction = self.action
	self.action = SecureButton_GetModifiedAttribute(self.frame, "action", SecureStateChild_GetEffectiveButton(self.frame)) or 1
	
	return (oldaction ~= self.action)
end

function prototype:UpdateIcon()
	local frame = self.frame
	local texture = GetActionTexture(self.action)
	if ( texture ) then
		self.rangeTimer = -1
		frame.icon:SetTexture(texture)
		frame.icon:Show()
		frame.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		frame.normalTexture:SetTexCoord(0,0,0,0)
		frame.tex = texture
	else
		self.rangeTimer = nil
		frame.icon:Hide()
		frame.cooldown:Hide()
		frame.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot")
		frame.hotkey:SetVertexColor(0.6, 0.6, 0.6)
		frame.normalTexture:SetTexCoord(-0.1,1.1,-0.1,1.12)
		frame.tex = nil
	end
end

function prototype:UpdateButton(force)
	if not self:RefreshAction() and not force then return end
	--self:RefreshAction()
	local frame = self.frame
	self:UpdateIcon()
	self:UpdateCount()
	self:UpdateHotkeys()
	Bartender3:RefreshStyle(self.frame, self.parent)
	if ( HasAction(self.action) ) then
		self:RegisterButtonEvents()
		self:UpdateState()
		self:UpdateUsable()
		self:UpdateCooldown()
		self:UpdateFlash()
		self:ShowButton()
		self.frame:SetScript("OnUpdate", onUpdateFunc)
	else
		self.frame:SetScript("OnUpdate", nil)
		self:UnregisterButtonEvents()
		
		if ( self.showgrid == 0 and not self.parent.config.ShowGrid ) then
			frame.normalTexture:Hide()
			if frame.overlay then
				frame.overlay:Hide()
			end
		else
			frame.normalTexture:Show()
			if frame.overlay then
				frame.overlay:Show()
			end
		end
		frame.cooldown:Hide()
		self:HideButton()
	end
	
	if ( IsEquippedAction(self.action) ) then
		frame.border:SetVertexColor(0, 1.0, 0, 0.75)
		frame.border:Show()
	else
		frame.border:Hide()
	end
	
	if ( GameTooltip:IsOwned(self.frame) ) then
		self:SetTooltip()
	else
		self.updateTooltip = nil
	end
	
	if self.parent.config.HideMacrotext then
		frame.macroName:SetText("")
	else
		frame.macroName:SetText(GetActionText(self.action))
	end
end

function prototype:UpdateHotkeys()
	local hotkey = self.frame.hotkey
	local oor = Bartender3.db.profile.OutOfRange or "none"
	local key1, key2 = GetBindingKey(((self.parent.id == 1) and "ACTIONBUTTON%d" or "BT3BUTTON%d"):format(self.id))
	local key = key1 or key2
	local text = GetBindingText(key, "KEY_", 1)
	if text == "" or self.parent.config.HideHotkey or not HasAction(self.action) then
		hotkey:SetText(RANGE_INDICATOR)
		hotkey:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 1, -2)
		hotkey:Hide()
	else
		hotkey:SetText(ShortenKeyBinding(text))
		hotkey:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -2, -2)
		hotkey:Show()
	end
end

function prototype:UpdateCount()
	if ( IsConsumableAction(self.action) or IsStackableAction(self.action) ) then
		self.frame.count:SetText(GetActionCount(self.action))
	else
		self.frame.count:SetText("")
	end
end

function prototype:UpdateState()
	local actionID = self.action
	if ( IsCurrentAction(actionID) or IsAutoRepeatAction(actionID) ) then
		self.frame:SetChecked(1)
	else
		self.frame:SetChecked(0)
	end
	if ( self.showgrid == 0 and not HasAction(self.action) ) then
		if ( self.parent.config.ShowGrid ~= true ) then
			self.frame.normalTexture:Hide()
		end
	end
end

function prototype:UpdateUsable()
	local oor = Bartender3.db.profile.OutOfRange or "none"
	local isUsable, notEnoughMana = IsUsableAction(self.action)
	local icon, hotkey = self.frame.icon, self.frame.hotkey
	local oorcolor, oomcolor = Bartender3.db.profile.Colors.OutOfRange, Bartender3.db.profile.Colors.OutOfMana
	if ( oor ~= "button" or not self.outOfRange) then
		if ( oor == "none" or not self.outOfRange) then
			hotkey:SetVertexColor(1.0, 1.0, 1.0)
		elseif ( oor == "hotkey" ) then
			hotkey:SetVertexColor(oorcolor.r, oorcolor.g, oorcolor.b)
		end
		
		if ( isUsable ) then
			icon:SetVertexColor(1.0, 1.0, 1.0);
		elseif ( notEnoughMana ) then
			icon:SetVertexColor(oomcolor.r, oomcolor.g, oomcolor.b)
		else
			icon:SetVertexColor(0.4, 0.4, 0.4);
		end
	elseif ( oor == "button" ) then
		icon:SetVertexColor(oorcolor.r, oorcolor.g, oorcolor.b)
		hotkey:SetVertexColor(1.0, 1.0, 1.0)
	end
end

function prototype:UpdateCooldown()
	local start, duration, enable = GetActionCooldown(self.action)
	CooldownFrame_SetTimer(self.frame.cooldown, start, duration, enable)
end

function prototype:UpdateFlash()
	local action = self.action
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		self:StartFlash()
	else
		self:StopFlash()
	end
end

function prototype:OnUpdate(elapsed)
	if not self.frame.tex then self:UpdateIcon() end
	
	if ( self.flashing == 1 ) then
		self.flashtime = self.flashtime - elapsed;
		if ( self.flashtime <= 0 ) then
			local overtime = -self.flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;
			
			local flashTexture = self.frame.flash
			if ( flashTexture:IsVisible() ) then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end
	end
	
	if ( self.rangeTimer ) then
		self.rangeTimer = self.rangeTimer - elapsed
		if ( self.rangeTimer <= 0 ) then
			local valid = IsActionInRange(self.action)
			local hotkey = self.frame.hotkey
			local hkshown = (hotkey:GetText() == RANGE_INDICATOR and Bartender3.db.profile.OutOfRange == "hotkey")
			if valid and hkshown then 
				hotkey:Show() 
			elseif hkshown then
				hotkey:Hide()
			end
			self.outOfRange = (valid == 0)
			self:UpdateUsable()
			self.rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end

function prototype:SetTooltip()
	-- if we get called by the tooltip callback code, self is the frame and we have to override that.
	if self.class then self = self.class end
	local frame = self.frame
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self.frame)
	else
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	end
	
	if ( GameTooltip:SetAction(self.action) ) then
		frame.UpdateTooltip = self.SetTooltip
	else
		frame.UpdateTooltip = nil
	end
end

function prototype:StartFlash()
	self.flashing = 1
	self.flashtime = 0
	self:UpdateState()
end

function prototype:StopFlash()
	self.flashing = 0
	self.frame.flash:Hide()
	self:UpdateState()
end

function prototype:ShowButton()
	local frame = self.frame
	if frame.overlay then return end
	
	frame.pushedTexture:SetTexture(frame.textureCache.pushed)
	frame.highlightTexture:SetTexture(frame.textureCache.highlight)
end

function prototype:HideButton()
	local frame = self.frame
	if frame.overlay then return end
	
	frame.pushedTexture:SetTexture("")
	frame.highlightTexture:SetTexture("")
end

function prototype:ShowGrid(override)
	local button = self.frame
	if not override then self.showgrid = self.showgrid+1 end
	
	button.normalTexture:Show()
	if button.overlay then
		button.overlay:Show()
	end
end

function prototype:HideGrid(override)
	local button = self.frame
	if not override then self.showgrid = self.showgrid-1 end
	if ( self.showgrid == 0 and not HasAction(self.action) ) then
		if ( not self.parent.config.ShowGrid ) then
			button.normalTexture:Hide()
			if button.overlay then
				button.overlay:Hide()
			end
		end
	end
end

function prototype:ReleaseButton()
	local bt3button = Bartender3.actionbuttons[self.id]
	bt3button.state = "free"
	self.frame:Hide()
	self.frame:SetParent(UIParent)
end

function prototype:AssignButton(parent, id)
	self.frame:SetParent(parent.frame)
	parent.frame:SetAttribute("addchild", self.frame)
	self.parent = parent
	self.id = id
	self.frame:SetAttribute("action", id)
	self:SetStateAction(0, self.id)
	self.frame:Show()
end

function prototype:RegisterBarEvents()
	local frame = self.frame
	frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	frame:RegisterEvent("ACTIONBAR_SHOWGRID")
	frame:RegisterEvent("ACTIONBAR_HIDEGRID")
	frame:RegisterEvent("UPDATE_BINDINGS")
	frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
end

local buttonevents = {
	"PLAYER_TARGET_CHANGED",
	"ACTIONBAR_UPDATE_STATE",
	"ACTIONBAR_UPDATE_USABLE",
	"ACTIONBAR_UPDATE_COOLDOWN",
	--"UPDATE_INVENTORY_ALERTS",
	--"PLAYER_AURAS_CHANGED",
	"CRAFT_SHOW",
	"CRAFT_CLOSE",
	"TRADE_SKILL_SHOW",
	"TRADE_SKILL_CLOSE",
	"PLAYER_ENTER_COMBAT",
	"PLAYER_LEAVE_COMBAT",
	"START_AUTOREPEAT_SPELL",
	"STOP_AUTOREPEAT_SPELL",
}

function prototype:RegisterButtonEvents()
	if self.eventsregistered then return end
	self.eventsregistered = true
	
	local frame = self.frame
	for _, event in pairs(buttonevents) do
		frame:RegisterEvent(event)
	end
end

function prototype:UnregisterButtonEvents()
	if not self.eventsregistered then return end
	self.eventsregistered = nil
	
	local frame = self.frame
	for _, event in pairs(buttonevents) do
		frame:UnregisterEvent(event)
	end
end

--[[
	Following Events are always set and will always be called - i call them the base events
]]
function prototype:BaseEventHandler(event)
	if not self.parent.config.Enabled or self.parent.config.Hide then return end
	
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		local button = arg1
		if ( button == 0 or button == self.action ) then
			-- force a refresh
			self:UpdateButton(true)
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" or e == "ACTIONBAR_PAGE_CHANGED") then
		self:UpdateButton(true)
	elseif ( event == "ACTIONBAR_SHOWGRID" ) then
		self:ShowGrid()
	elseif ( event == "ACTIONBAR_HIDEGRID" ) then
		self:HideGrid()
	elseif ( event == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeys()
	elseif ( event == "UPDATE_SHAPESHIFT_FORM" ) then
		self:UpdateButton()
	end
end

--[[
	Following Events are only set when the Button in question has a valid action - i call them the button events
]]
function prototype:ButtonEventHandler(event)
	if not self.parent.config.Enabled or self.parent.config.Hide then return end
	local actionId = self.action
	
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		self:UpdateState()
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		self:UpdateUsable()
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		self:UpdateCooldown()
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		self:UpdateState()
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(actionId) ) then
			self:StartFlash()
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(actionId) ) then
			self:StopFlash()
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(actionId) ) then
			self:StartFlash()
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( self.flashing == 1 and not IsAttackAction(actionId) ) then
			self:StopFlash()
		end
	end
end


