--[[
Copyright (c) 2006, Hendrik Leppkes < mail@nevcairiel.net >
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

Modified for AutoBar support
Toadkiller 2007
-- http://code.google.com/p/autobar/
]]

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

AutoBar.styles = {
	[1] = { name = L["DEFAULT"]},
	[2] = { name = L["ZOOMED"], coords = {0.07,0.93,0.07,0.93} },
	[3] = {
		name = L["DREAMLAYOUT"],
		coords = {0.07,0.93,0.07,0.93},
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
	[4] = {
		name = "cyCircled",
		noHotKey = true,
		callbackFunc = nil,
		callbackSelf = nil,
	},
}
-- Button Skinning support needs a style above, as well as a callbackFunc set
-- Setting callbackFunc stops regular formatting
-- Set the style via AutoBar:SetStyle() below
-- If there are missing attributes you want handled let Toadkiller know


function AutoBar:GetButtonSize()
	local buttonWidth = AutoBar.display.buttonWidth;
	local buttonHeight = AutoBar.display.buttonHeight;
	local gapping = AutoBar.display.gapping;
	local style = AutoBar:GetStyle();
	if (style.buttonWidth) then
		buttonWidth = style.buttonWidth;
	end
	if (style.buttonHeight) then
		buttonHeight = style.buttonHeight;
	end
	if (style.gapping) then
		gapping = style.gapping;
	end
	return buttonWidth, buttonHeight, gapping;
end


function AutoBar:GetStyle()
	return AutoBar.styles[AutoBar.display.style];
end


-- Set Style to the given index, or matched name, or insert the new style & set it as well
-- Returns the style index
function AutoBar:SetStyle(newStyle)
	if (type(newStyle) == "number") then
		AutoBar.style = newStyle;
	elseif (type(newStyle) == "string") then
		for index, style in pairs () do
			if (style.name == newStyle) then
				AutoBar.style = index;
			end
		end
	elseif (type(newStyle) == "table") then
		table.insert(AutoBar.styles, newStyle);
		AutoBar.style = AutoBar:SetStyle(newStyle.name);
	end
	AutoBar.delayLayoutUpdate:Start()
	return AutoBar.style;
end


function AutoBar:RefreshStyle(button)
	if not button.icon then return end
	local style = AutoBar:GetStyle();
	if not style then return end

	if (style == 4) then
		if not button.overlay then
			button.overlay = getglobal(button:GetName() .. "Overlay")
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
	if (not button:GetAttribute("buttonsIndex")) then
		if button.customframe then button.customframe:Hide() end
		if button.overlay then button.overlay:Hide() end
	else
		if button.customframe then button.customframe:Show() end
		if button.overlay then button.overlay:Show() end
	end
	if (style.noHotKey) then
		button.hotKey:Hide();
	else
		button.hotKey:Show();
	end

	-- Skinning Hook
	if (style.callbackFunc) then
		if (style.callbackSelf) then
			style.callbackFunc(style.callbackSelf, button)
		else
			style.callbackFunc(button)
		end
		return
	elseif button.overlay then
		return
	end

	-- Regular Styles
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
