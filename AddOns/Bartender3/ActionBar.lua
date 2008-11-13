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
--[[ $Id: ActionBar.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49903 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local table_insert = table.insert
local table_remove = table.remove

--[[
	Action Bars
	
	ActionBar is the abstract class for all of the 10 actionbars
	self.buttons holds the actual frames
	self.buttonobjects holds the ButtonClass objects
]]

Bartender3.Class.ActionBar = Bartender3.Class:CreatePrototype(Bartender3.Class.Bar)
local actionbarprototype = Bartender3.Class.ActionBar.prototype


function actionbarprototype:init(id, config, numbuttons)
	actionbarprototype.super.prototype.init(self, id, config, true)
	self.buttonwidth = 36
	self.buttonheight = 36

	self.numbuttons = numbuttons
	self:CreateButtons()
	
	self:InitStates()
	self:InitOptions()
	
	self:RefreshStyle()
	self:UpdateSelfCast()
	self:RefreshLayout()
end

function actionbarprototype:ChangeProfile(config)
	actionbarprototype.super.prototype.ChangeProfile(self, config)
	
	self.numbuttons = self.config.Buttons
	self:SetButtons(self.numbuttons)
	self:InitStates()
	self:RefreshLayout()
end

function actionbarprototype:CreateButtons()
	if self.buttons or self.buttonobjects then return end
	self.buttons, self.buttonobjects, self.keybindings = {}, {}, {}
	for i=1, self.numbuttons do
		local button = Bartender3:GetFreeButton(self)
		table_insert(self.buttons, button.frame)
		table_insert(self.buttonobjects, button)
	end
end

function actionbarprototype:SetButtons(a)
	local oldbuttons = self.numbuttons
	self.numbuttons = a
	self.config.Buttons = a
	if a > oldbuttons then
		for i=(oldbuttons+1),a do
			local button = Bartender3:GetFreeButton(self)
			table_insert(self.buttons, button.frame)
			table_insert(self.buttonobjects, button)
			if Bartender3.unlock then button.frame:SetFrameLevel(2) end
		end
		self:UpdateStates()
	elseif a < oldbuttons then
		for i=(a+1), oldbuttons do
			-- fetch the last button
			local butnum = #self.buttonobjects
			-- release it
			self.buttonobjects[butnum]:ReleaseButton()
			table_remove(self.buttons)
			table_remove(self.buttonobjects)
		end
	else return end -- no change
	local maxbuttons = #self.buttons
	self.optionstable.args.rows.max = ( maxbuttons > 1 ) and maxbuttons or 2
	-- refresh rows config.
	if self.config.Rows > maxbuttons then self:SetRows(maxbuttons) else self:SetRows(self.config.Rows) end
	self:RefreshLayout()
	self:UpdateSelfCast()
end

function actionbarprototype:RefreshLayout()
	actionbarprototype.super.prototype.RefreshLayout(self)
	for i,v in pairs(self.buttonobjects) do
		v:UpdateButton()
	end
end

function actionbarprototype:AddRightClickState(state)
	local scrc = Bartender3.db.profile.SelfCastRightClick
	local target = scrc and "player" or nil
	
	self.frame:SetAttribute("unit-S" .. state .. "2", target)
end

function actionbarprototype:UpdateSelfCast()
	for i,v in pairs(self.buttons) do
		v:SetAttribute("checkselfcast", Bartender3.db.profile.SelfCastModifier)
	end
	self:UpdateStates()
end

function actionbarprototype:SetModifierState(modifier, page)
	if not self.config.States then return end
	self.config.States[modifier] = (page==0) and nil or page
	self:UpdateStates()
end

function actionbarprototype:SetStancePage(stance, page)
	self.config.Stances[stance] = page
	self:UpdateStates()
end
