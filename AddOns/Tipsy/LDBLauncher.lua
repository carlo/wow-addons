--[[
Tipsy/LDBLauncher.lua

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

--[[ Setup the LDB launcher ]]
LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Tipsy", {
	icon = [[Interface\AddOns\Tipsy\Icon]],
	text = "Tipsy",
	OnClick = function(frame, button)
		Tipsy:ShowTooltipAnchor() 
	end,
	OnEnter = function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_NONE")
		GameTooltip:SetPoint(Tipsy:GetTipAnchor(frame))
		GameTooltip:ClearLines()

		GameTooltip:AddLine("Tipsy")
		GameTooltip:AddLine("")
		GameTooltip:AddLine("Click to toggle the tooltip anchor frame")

		GameTooltip:Show()
	end,
	OnHide = function()
		GameTooltip:Hide()
	end,
})

