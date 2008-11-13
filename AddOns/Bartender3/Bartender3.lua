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

--[[ $Id: Bartender3.lua 49922 2007-09-26 20:15:15Z nevcairiel $ ]]
Bartender3 = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "AceHook-2.1")

local Bartender3, self = Bartender3, Bartender3

local VERSION = tonumber(("$Revision: 49922 $"):match("%d+"))
Bartender3.revision = VERSION
Bartender3.versionstring = "3.1.2 |cffff8888r%d|r"
Bartender3.version = Bartender3.versionstring:format(VERSION)
Bartender3.date = ("$Date: 2007-09-26 16:15:15 -0400 (Wed, 26 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")

local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

local waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")

local _G = getfenv(0)

local table_insert = table.insert
local table_remove = table.remove

local SetOverrideBindingClick = SetOverrideBindingClick
local GetBindingKey = GetBindingKey
local SetBinding = SetBinding

function Bartender3:OnInitialize()
	self:RegisterDB("BT3DB")
	self:SetupDefaults()
	
	_, self.playerclass = UnitClass("player")
	
	self:PopulateOptions()
end

function Bartender3:OnEnable(first)
	if first then
		self:InitialSetup()
		self:UpgradeConfig()
		self:ConvertBindings()
		
		if IsAddOnLoaded("cyCircled") then
			self:Hook(cyCircled, "LoadPlugins", "cyLoaded")
		end
	end
	
	self:CreateStanceMap()
	for i=1,10 do
		if self.actionbars[i] then self.actionbars[i]:InitStates() end
	end
	self:RefreshBars()
	self:RegisterOverrideBindings()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatLockdown")
	self:RegisterEvent("UPDATE_BINDINGS", "RegisterOverrideBindings")
end

function Bartender3:InitialSetup()
	self.unlock = false
	self.actionbars, self.actionbuttons, self.specialbars, self.bars = {}, {}, {}, {}
	for i=1,120 do
		self.actionbuttons[i] = { state = "unused", object = nil}
	end

	for i=1,10 do
		if self.db.profile.Bars[i].Enabled then
			local bar = Bartender3.Class.ActionBar:new(i, self.db.profile.Bars[i], self.db.profile.Bars[i].Buttons or 12)
			self.actionbars[i] = bar
		else
			-- feed a dummy config entry into the options table, so that we can actually activate it.
			self:CreateDisabledBarOptions(i, L["Bar %s"]:format(i))
		end
	end
	
	self:RemoveDefaultUIElements()
	
	self.keyframe = CreateFrame("Frame", nil, UIParent)
	
	BINDING_HEADER_Bartender3 = "Bartender3"
	for i=1,10 do
		for k=1,12 do
			_G[((i == 1) and "BINDING_NAME_ACTIONBUTTON%d" or "BINDING_NAME_BT3BUTTON%d"):format(((i-1)*12)+k)] = L["Bartender3 Bar %s Button %s"]:format(i, k)
		end
	end
	
	if waterfall then
		waterfall:Register("Bartender3", 
							"aceOptions", self.options, 
							"title", "Bartender3 Configuration",
							"treeLevels", 3);
		self.options.args.config = {
			name = L["Config"],
			desc = L["Open the configuration GUI"],
			wfHidden = true,
			type = "execute",
			func = function() waterfall:Open("Bartender3") end,
		}
	end
	
end

local specialbars = {
	["STANCE"] = L["StanceBar"],
	["PET"] = L["PetBar"],
	["MICROMENU"] = L["MicroMenu"],
	["BAGS"] = L["BagBar"],
	["XP"] = L["XPBar"],
	["REPUTATION"] = L["Reputation Bar"],
}

function Bartender3:RemoveDefaultUIElements()
	-- Hide the main grafics
	MainMenuBarArtFrame:Hide()
	MainMenuBar:Hide()
	
	for k,v in pairs(specialbars) do
		local config = self.db.profile.SpecialBars[k]
		if config.Enabled then
			self.specialbars[k] = Bartender3.Class.SpecialBar:new(k, v, config)
		else
			self:CreateDisabledBarOptions(k, v, true)
		end
	end
end

function Bartender3:OnProfileEnable()
	self:LockBars()
	for i=1,10 do
		-- bar disabling logic, lots of cases
		local config = self.db.profile.Bars[i]
		-- bar should be enabled, and was enabled
		if config.Enabled and self.actionbars[i] and self.actionbars[i].config.Enabled then 
			self.actionbars[i]:ChangeProfile(config)
		-- bar should be enabled, but was not, and object not existent
		elseif config.Enabled and not self.actionbars[i] then
			self.actionbars[i] = Bartender3.Class.ActionBar:new(i, config, config.Buttons or 12)
		-- bar should be enabled, but was not, object exists, but was set to disabled
		elseif config.Enabled and not self.actionbars[i].config.Enabled then
			self.actionbars[i]:ChangeProfile(config)
			self.actionbars[i]:InitOptions()
		-- bar should be disabled, and was enabled
		elseif not config.Enabled and self.actionbars[i] and self.actionbars[i].config.Enabled then
			self.actionbars[i]:ChangeProfile(config)
			self:CreateDisabledBarOptions(i, L["Bar %s"]:format(i))
		-- bar should be disabled, was disabled, but object does exist
		elseif not config.Enabled and self.actionbars[i] then
			self.actionbars[i]:ChangeProfile(config)
		end
	end
	for i,v in pairs(self.specialbars) do
		v:ChangeProfile(self.db.profile.SpecialBars[i])
	end
	self:ConvertBindings()
end

function Bartender3:CombatLockdown()
	if self.unlock then
		self:LockBars()
		self:Print(L["ActionBars have been locked because you entered combat."])
		-- close any dewdrop menu owned by us
		local parent = dewdrop:GetOpenedParent()
		for i,v in pairs(self.bars) do
			if parent == v.frame then
				dewdrop:Close()
			end
		end
	end
end

function Bartender3:GetFreeButton(bar)
	if bar then
		for i=1,12 do
			local button = ((bar.id-1)*12)+i
			if ( self.actionbuttons[button].state == "unused" ) then 
				local newbutton = Bartender3.Class.Button:new(bar, button)
				self.actionbuttons[button].state = "used"
				self.actionbuttons[button].object = newbutton
				return newbutton
			elseif ( self.actionbuttons[button].state == "free" ) then 
				self.actionbuttons[button].state = "used"
				self.actionbuttons[button].object:AssignButton(bar, button)
				return self.actionbuttons[button].object
			end
		end
	end
end

function Bartender3:UnlockBars()
	for i,v in pairs(self.bars) do
		if v.config.Enabled then v:UnlockFrames() end
	end
	self.unlock = true
	if Bartender3FuBar then Bartender3FuBar:UpdateDisplay() end
end

function Bartender3:LockBars()
	for i,v in pairs(self.bars) do
		if v.config.Enabled then v:LockFrames() end
	end
	self.unlock = nil
	if Bartender3FuBar then Bartender3FuBar:UpdateDisplay() end
end

function Bartender3:RefreshBars(bar)
	if bar then bar:RefreshLayout() else
		for i,v in pairs(self.bars) do
			if v.config.Enabled then 
				v:RefreshLayout() 
				v:RefreshStyle()
				if v.UpdateStates then v:UpdateStates() end
			end
		end
	end
end

function Bartender3:GetConfig(index, special)
	if special then
		return self.db.profile.SpecialBars[index]
	else
		return self.db.profile.Bars[index]
	end
end

function Bartender3:GetBarObject(index, special)
	if special then
		return self.specialbars[index]
	else
		return self.actionbars[index]
	end
end

function Bartender3:ToggleBarEnabled(barid, special)
	if InCombatLockdown() then return end
	
	if not special then
		barid = tonumber(barid)
		local bar, barconfig = self.actionbars[barid], self.db.profile.Bars[barid]
		if bar and barconfig.Enabled then -- disable the bar
			barconfig.Enabled = false
			bar:LockFrames()
			bar.frame:Hide()
			self:CreateDisabledBarOptions(barid, L["Bar %s"]:format(barid))
		elseif bar then -- bar was disabled before
			barconfig.Enabled = true
			bar:InitOptions()
			bar:ChangeProfile(barconfig) -- refresh config
			if self.unlock then bar:UnlockFrames() end
		else -- bar doesnt exist yet
			barconfig.Enabled = true
			bar = Bartender3.Class.ActionBar:new(barid, barconfig, barconfig.Buttons or 12)
			self.actionbars[barid] = bar
			if self.unlock then bar:UnlockFrames() end
		end
	else
		local bar, config = self.specialbars[barid], self.db.profile.SpecialBars[barid]
		config.Enabled = not config.Enabled
		if not bar then -- we are enableing
			self.specialbars[barid] = Bartender3.Class.SpecialBar:new(barid, specialbars[barid], config)
			if self.unlock then bar:UnlockFrames() end
		elseif config.Enabled then -- we are enabling, too
			bar:InitOptions()
			bar:ChangeProfile(config)
			if self.unlock then bar:UnlockFrames() end
		elseif not config.Enabled then
			bar:LockFrames()
			bar.frame:Hide()
			self:CreateDisabledBarOptions(barid, specialbars[barid], true)
		end
	end
end

function Bartender3:LockButtons(silence)
	if self.db.profile.ButtonLock then
		self.db.profile.ButtonLock = false
		if not silence then self:Print(L["ActionBar lock %s."]:format(self:GetOnOffText(false))) end
	else
		self.db.profile.ButtonLock = true
		if not silence then self:Print(L["ActionBar lock %s."]:format(self:GetOnOffText(true))) end
	end
end

function Bartender3:GetOnOffText(bool)
	return bool and ("|cff00ff00%s|r"):format(L["On"]) or ("|cffff0000%s|r"):format(L["Off"])
end

function Bartender3:RegisterOverrideBindings()
	ClearOverrideBindings(self.keyframe)
	for i=1,120 do
		local key1, key2 = GetBindingKey((i<13 and "ACTIONBUTTON%d" or "BT3BUTTON%d"):format(i))
		if key1 then SetOverrideBindingClick(self.keyframe, false, key1, ("BT3Button%d"):format(i)) end
		if key2 then SetOverrideBindingClick(self.keyframe, false, key2, ("BT3Button%d"):format(i)) end
	end
end

-- declare our class prototype and our creation function
Bartender3.Class = {}

local function objectConstructor(class, ...)
	local object = {}
	setmetatable(object, class.mt)
	
	if object.init then
		object.init(object, ...)
	end
	
	return object
end

function Bartender3.Class:CreatePrototype(inherit)
	local class, prototype = {}, {}
	
	if inherit then
		setmetatable(prototype, inherit.mt)
		prototype.super = inherit
	end
	
	class.prototype = prototype
	class.new = objectConstructor
	class.mt = { __index = prototype }
	return class
end
