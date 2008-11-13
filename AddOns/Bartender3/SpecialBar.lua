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
--[[ $Id: SpecialBar.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49903 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local table_insert = table.insert
local table_remove = table.remove
local _G = _G

--[[
	Special Bars
	
	Special Bars are an abstraction layer for the MicroMenu/Bags/Stance/Pet Bar
	The table self.buttons holds the actual frames of the buttons.
]]

Bartender3.Class.SpecialBar = Bartender3.Class:CreatePrototype(Bartender3.Class.Bar)
local specialbarprototype = Bartender3.Class.SpecialBar.prototype

function specialbarprototype:init(bartype, barname, config)
	specialbarprototype.super.prototype.init(self, bartype, config, false)
	
	self.bartype = bartype
	self.barname = barname
	self:AssignFrames(bartype)
	
	self:InitOptions()
	
	self:RefreshLayout()
	self:RefreshStyle()
end

function specialbarprototype:ChangeProfile(config)
	specialbarprototype.super.prototype.ChangeProfile(self, config)
	
	self.buttons = nil
	self:AssignFrames(self.bartype)
	self:RefreshLayout()
end

function specialbarprototype:AssignFrames(bartype)
	if self.buttons then return end
	self.buttons = {}
	if not bartype then bartype = self.bartype end
	if ( bartype == "STANCE" ) then
		self.buttonwidth = 30
		self.buttonheight = 30
		for i=1,10 do 
			local button = _G[("ShapeshiftButton%d"):format(i)]
			button:SetParent(self.frame)
			button:SetNormalTexture("")
			
			button.icon = _G[("ShapeshiftButton%dIcon"):format(i)]
			button.cooldown = _G[("ShapeshiftButton%dCooldown"):format(i)]
			button:SetFrameLevel(2)
			table_insert(self.buttons, button) 
		end
		self:StanceBar_OnInit()
	elseif ( bartype == "PET" ) then
		self.buttonwidth = 30
		self.buttonheight = 30
		for i=1, NUM_PET_ACTION_SLOTS, 1 do
			local button = _G[("PetActionButton%d"):format(i)]
			button:SetParent(self.frame)
			button.normalTexture = _G[("PetActionButton%dNormalTexture2"):format(i)]
			button.normalTexture:Hide()
			
			button.icon = _G[("PetActionButton%dIcon"):format(i)]
			button.cooldown = _G[("PetActionButton%dCooldown"):format(i)]
			button:SetFrameLevel(2)
			table_insert(self.buttons, button) 
		end
		
		self:PetBar_OnInit()
	elseif ( bartype == "MICROMENU" ) then
		self.buttonwidth = 29
		self.buttonheight = 37
		self.specialmicromenu = true
		table_insert(self.buttons, CharacterMicroButton)
		table_insert(self.buttons, SpellbookMicroButton)
		table_insert(self.buttons, TalentMicroButton)
		UpdateTalentButton = function() end
		table_insert(self.buttons, QuestLogMicroButton)
		table_insert(self.buttons, SocialsMicroButton)
		table_insert(self.buttons, LFGMicroButton)
		table_insert(self.buttons, MainMenuMicroButton)
		table_insert(self.buttons, HelpMicroButton)
		
		for i,v in pairs(self.buttons) do v:SetParent(self.frame); v:Show(); v:SetFrameLevel(2); end
	elseif ( bartype == "BAGS" ) then
		self.buttonwidth = MainMenuBarBackpackButton:GetWidth()
		self.buttonheight = MainMenuBarBackpackButton:GetHeight()
		
		if self.config.Keyring then
			table_insert(self.buttons, KeyRingButton)
		else
			KeyRingButton:Hide()
		end
		
		if not self.config.OneBag then
			table_insert(self.buttons, CharacterBag3Slot) 
			table_insert(self.buttons, CharacterBag2Slot) 
			table_insert(self.buttons, CharacterBag1Slot) 
			table_insert(self.buttons, CharacterBag0Slot)
		else
			CharacterBag3Slot:Hide()
			CharacterBag2Slot:Hide()
			CharacterBag1Slot:Hide()
			CharacterBag0Slot:Hide()
		end
	 	--MainMenuBarBackpackButton:SetScript("OnClick", function() OpenAllBags() end)
		table_insert(self.buttons, MainMenuBarBackpackButton)
		for i,v in pairs(self.buttons) do 
			v.icon = _G[v:GetName().."IconTexture"]
			v:SetParent(self.frame)
			if v ~= KeyRingButton then v:SetNormalTexture("") end
			v:SetFrameLevel(2)
			v:Show()
		end
	elseif ( bartype == "XP" ) then
		self.buttonwidth = 1024
		self.buttonheight = 13
		table_insert(self.buttons, MainMenuExpBar)
		MainMenuExpBar:SetParent(self.frame)
		MainMenuExpBar:Show()
	elseif ( bartype == "REPUTATION" ) then
		self.buttonwidth = 1024
		self.buttonheight = 13
		table_insert(self.buttons, ReputationWatchBar)
		ReputationWatchBar:SetParent(self.frame)
		ReputationWatchBar:Show()
		
		self:ReputationBar_OnInit()
	end
end

function specialbarprototype:StanceBar_OnInit()
	if self.stanceinit then return end
	self.stanceinit = true
	hooksecurefunc("ShapeshiftBar_Update", function() self:ShapeshiftBar_Update() end)
end

function specialbarprototype:ShapeshiftBar_Update()
	self:RefreshLayout()
	self:RefreshStyle()
end

-- maybe think about rebuilding the petbar, this hooking is a PITA
function specialbarprototype:PetBar_OnInit()
	if self.petinit then return end
	self.petinit = true
	hooksecurefunc("PetActionBar_ShowGrid", function() self:PetActionBar_ShowGrid() end)
	hooksecurefunc("PetActionBar_HideGrid", function() self:PetActionBar_HideGrid() end)
	hooksecurefunc("PetActionBar_Update", function() self:PetActionBar_Update() end)
end

function specialbarprototype:PetActionBar_Update()
	for i, frame in pairs(self.buttons) do
		local _, _, texture = GetPetActionInfo(i);
		if ( texture ) then
			frame.normalTexture:SetTexCoord(0,0,0,0)
		else
			frame.normalTexture:SetTexCoord(-0.1,1.1,-0.1,1.12)
		end
	end
end

function specialbarprototype:PetActionBar_ShowGrid()
	local name;
	for i, frame in pairs(self.buttons) do
		name = GetPetActionInfo(i);
		if ( not name ) then
			frame.normalTexture:Show()
		end
	end
end

function specialbarprototype:PetActionBar_HideGrid()
	if ( PetActionBarFrame.showgrid == 0 ) then
		for i, frame in pairs(self.buttons) do
			frame.normalTexture:Hide()
		end
	end
end

function specialbarprototype:ReputationBar_OnInit()
	hooksecurefunc("ReputationWatchBar_Update",  function() self:RefreshLayout() end)
end

function specialbarprototype:ToggleKeyring()
	if self.bartype ~= "BAGS" then return end
	self.config.Keyring = not self.config.Keyring
	self.buttons = nil
	self:AssignFrames(self.bartype)
	self:RefreshLayout()
	self:RefreshStyle()
end

function specialbarprototype:ToggleOneBag()
	if self.bartype ~= "BAGS" then return end
	self.config.OneBag = not self.config.OneBag
	self.buttons = nil
	self:AssignFrames(self.bartype)
	self:RefreshLayout()
	self:RefreshStyle()
	self.optionstable.args.rows.max = ( #self.buttons > 1 ) and #self.buttons or 2
end
