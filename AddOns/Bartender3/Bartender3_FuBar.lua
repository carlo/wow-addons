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
--[[ $Id: Bartender3_FuBar.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
Bartender3FuBar = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "FuBarPlugin-2.0")
local Bartender3, Bartender3FuBar = Bartender3, Bartender3FuBar

local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

Bartender3FuBar.name = "Bartender3"
Bartender3FuBar.version = Bartender3.version
Bartender3FuBar.revision = Bartender3.revision
Bartender3FuBar.date = Bartender3.date
Bartender3FuBar.hasIcon = "Interface\\Icons\\INV_Drink_05"
Bartender3FuBar.hasNoColor = true
Bartender3FuBar.defaultMinimapPosition = 285
Bartender3FuBar.clickableTooltip = false
Bartender3FuBar.hideWithoutStandby = true
Bartender3FuBar.independentProfile = true
Bartender3FuBar.cannotDetachTooltip = true

local waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")

function Bartender3FuBar:OnInitialize()
	self.db = Bartender3:AcquireDBNamespace("fubar")
	
	Bartender3.options.args.fbp_blank = {
		order = 59,
		type = "header",
	}
	Bartender3.options.args.fubar = {
		order = 60,
		type = "group",
		name = L["FuBarPlugin Config"],
		desc = L["Configure the FuBar Plugin"],
		args = {},
	}
	AceLibrary("AceConsole-2.0"):InjectAceOptionsTable(self, Bartender3.options.args.fubar)
	self.OnMenuRequest = Bartender3.options
end

local Tablet = AceLibrary("Tablet-2.0")
-- FuBar Stuff
function Bartender3FuBar:OnTooltipUpdate()
	local cat = Tablet:AddCategory("columns", 2)
	cat:AddLine("text", L["Button lock"], "text2", Bartender3:GetOnOffText(Bartender3.db.profile.ButtonLock))
	cat:AddLine("text", L["Bar lock"], "text2", Bartender3:GetOnOffText(not Bartender3.unlock))
	Tablet:SetHint(L["\n|cffeda55fDouble-Click|r to open config GUI.\n|cffeda55fCtrl-Click|r to toggle button lock. |cffeda55fShift-Click|r to toggle bar lock."])
end

function Bartender3FuBar:OnClick(button)
	if IsShiftKeyDown() then
		if Bartender3.unlock then
			Bartender3:LockBars()
		else
			Bartender3:UnlockBars()
		end
	elseif IsControlKeyDown() then
		Bartender3:LockButtons()
	end
	self:UpdateDisplay()
end

function Bartender3FuBar:OnDoubleClick()
	if waterfall then
		waterfall:Open("Bartender3")
	else
		self:Print(L["Waterfall-1.0 is required to access the GUI."])
	end
end
