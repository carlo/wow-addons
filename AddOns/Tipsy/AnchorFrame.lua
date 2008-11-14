--[[
Tipsy/AnchorFrame.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local Tipsy = Tipsy
if not Tipsy then return end


function Tipsy:CreateAnchorFrame()
	local db = self.db.profile
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(125)
	frame:SetHeight(85)

	local title = "|cFFFFFFFFTipsy Tooltip Anchor|r"
	local notes = "Right click when finished positioning the tooltip."

	local string = frame:CreateFontString()
	string:SetAllPoints(frame)
	string:SetFontObject("GameFontNormalSmall")
	string:SetText(title .. "|n|n" .. notes)

	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left=4, right=4, top=4, bottom=4 }
	})
	frame:SetBackdropColor(0.75,0,0,1)
	frame:SetBackdropBorderColor(0.75,0,0,1)

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")

	frame:SetScript("OnDragStart", function() 
		this:StartMoving() 
	end)

	frame:SetScript("OnDragStop", function() 
		this:StopMovingOrSizing() 
	end)

	frame:SetScript("OnMouseDown", function(this, button)
		if button == "RightButton" then
			-- Here we take advantage of the 2.2 API change that GetPoint will automatically
			-- pick the nearest parent anchor position. See http://www.wowwiki.com/API_Region_GetPoint
			db.point, _, db.relativePoint, db.xOfs, db.yOfs = this:GetPoint()
			this:Hide()
		end
	end)

	return frame
end


