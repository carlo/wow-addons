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
--[[ $Id: Style.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49903 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local L = AceLibrary("AceLocale-2.2"):new("Bartender3")
local _G = getfenv(0)

Bartender3.styles = {
	["Default"] = { name = L["Default"]},
	["Zoomed"] = { name = L["Zoomed"], coords = {0.08,0.92,0.08,0.92} },
	["Dreamlayout"] = { 
		name = L["Dreamlayout"],
		coords = {0.08,0.92,0.08,0.92}, 
		padding = 3, 
		customframe = true,
		FrameFunc = function(button) 
			local frame = CreateFrame("Frame", button:GetName().."DL", button)
			frame:ClearAllPoints()
			frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1, edgeFile = "", edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0},})
			frame:SetBackdropColor(0, 0, 0, 0.6)
			frame:SetAllPoints(button)
			frame:SetFrameLevel(0)
			return frame
		end,
	},
}

function Bartender3:cyLoaded(obj)
	self.hooks[obj].LoadPlugins(obj)
	self.cydb = cyCircled:AcquireDBNamespace("Bartender3")
	self:RefreshBars()
end

function Bartender3:RefreshStyle(button, bar)
	if not button.icon then return end
	local style = Bartender3.styles[bar.config.Style]
	if not style then return end
	
	if self.cydb then
		if self.cydb.profile["Bar" .. bar.id] then
			if not button.overlay then button.overlay = _G[button:GetName() .. "Overlay"] end
		end
	end
	
	if style.customframe and style.FrameFunc and not button.overlay then 
		if not button.customframe then button.customframe = style.FrameFunc(button) end
	else
		if button.customframe then 
			button.customframe:Hide()
			button.customframe = nil
		end
	end
	
	-- cyCircled support
	
	if (button.class and not HasAction(button.class:PagedID()) and not button.class.parent.config.ShowGrid) then 
		if button.customframe then button.customframe:Hide() end
		if button.overlay then button.overlay:Hide() end
	else 
		if button.customframe then button.customframe:Show() end
		if button.overlay then button.overlay:Show() end
	end
	
	if button.overlay then return end
	
	if style.coords then
		button.icon:SetTexCoord(style.coords[1], style.coords[2], style.coords[3], style.coords[4])
	else
		button.icon:SetTexCoord(0,1,0,1)
	end
	
	button.icon:ClearAllPoints()
	if style.padding then
		button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", style.padding, -style.padding)
		button.icon:SetPoint("BOTTOMRIGHT",button, "BOTTOMRIGHT",  -style.padding, style.padding)
	else
		button.icon:SetAllPoints(button)
	end
end
