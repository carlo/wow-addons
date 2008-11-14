--[[
Tipsy/Tipsy.lua

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

--[[ Addon declaration ]]
Tipsy = LibStub("AceAddon-3.0"):NewAddon("Tipsy", "AceConsole-3.0", "AceHook-3.0")
Tipsy.revision = tonumber(("$Revision: 13 $"):match("%d+"))
Tipsy.date = ("$Date: 2008-10-06 23:52:46 +0000 (Mon, 06 Oct 2008) $"):match("%d%d%d%d%-%d%d%-%d%d")

--[[ Private locals ]]
local db = nil

local defaults = {
	profile = {
		-- Default location copied from FrameXML/GameTooltip.lua
		-- tooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
		point = "BOTTOMRIGHT",
		relativePoint = "BOTTOMRIGHT",
		xOfs = -CONTAINER_OFFSET_X - 13,
		yOfs = CONTAINER_OFFSET_Y,
	}
}

--[[ Constructor ]]
function Tipsy:OnInitialize()
	LibStub("tekKonfig-AboutPanel").new(nil, "Tipsy")

	self.db = LibStub("AceDB-3.0"):New("TipsyDB", defaults, "Default")
	db = self.db.profile

	self:RegisterChatCommand("tipsy", "SlashCommandHandler")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
end

function Tipsy:SlashCommandHandler(input)
	local arg1 = self:GetArgs(input)
	if arg1 == "show" then
		self:ShowTooltipAnchor()
	elseif arg1 == "reset" then
		self:ResetTooltipAnchor()
	else
		self:Print("Tipsy Usage:")
		self:Print("/tipsy show - show the tooltip anchor")
		self:Print("/tipsy reset - reset the tooltip anchor to the bottom right")
	end
end

function Tipsy:ResetTooltipAnchor()
	db.point = defaults.profile.point
	db.relativePoint = defaults.profile.point
	db.xOfs = defaults.profile.xOfs
	db.yOfs = defaults.profile.yOfs
	self:ShowTooltipAnchor()
end

function Tipsy:ShowTooltipAnchor()
	if self.anchorFrame == nil then
		self.anchorFrame = self:CreateAnchorFrame()
	end

	self.anchorFrame:ClearAllPoints()
	self.anchorFrame:SetPoint( self.db.profile.point, UIParent, self.db.profile.relativePoint, self.db.profile.xOfs, self.db.profile.yOfs )
	self.anchorFrame:Show()
end

function Tipsy:GameTooltip_SetDefaultAnchor(tooltip, parent, ...)
	tooltip:SetOwner(parent, "ANCHOR_NONE")
	tooltip:ClearAllPoints()
	tooltip:SetPoint(db.point, UIParent, db.relativePoint, db.xOfs, db.yOfs)
end

function Tipsy:GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

