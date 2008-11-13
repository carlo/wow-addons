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
--[[ $Id: Defaults.lua 49903 2007-09-26 18:04:31Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 49903 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end


local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

-- returns current config ver, and recent version
function Bartender3:GetConfigVersion()
	return self.db.profile.Version or 0, 312
end

function Bartender3:UpgradeConfig()
	local v, w = self:GetConfigVersion()
	if w > v then
		self:Print(L["Bartender3 has been updated to the latest config revision. You should only see this message once."])
		
		-- 310 - switched back to default profile - prompt warning message that it may be lost
		if v < 310 then
			if type(self.db.profile.Keybindings) == "table" then
				self:ConvertBindings()
			end
			if (self:GetProfile() == "Default") then
				self:Print(L["If your settings seem to have been reset, check your profile settings and switch to the appropriate profile if necessary."])
			end
		end
		
		-- 311 - added more outofrange options - convert old boolean to the new string
		if v < 311 then
			if type(self.db.profile.OutOfRange) == "boolean" then
				self.db.profile.OutOfRange = self.db.profile.OutOfRange and "button" or "none"
			end
		end
		
		-- 312 
		-- added option to disable tooltip while in combat, convert old boolean
		-- converted stance keys to strings 
		if v < 312 then
			self.db.profile.Tooltip = self.db.profile.HideTooltip and "disabled" or "enabled"
			self.db.profile.HideTooltip = nil
			
			for i,v in pairs(self.db.profile.Bars) do
				for stance,page in pairs(v.Stances) do
					v.Stances[stance] = tostring(page)
				end
			end
		end
		
		-- set config revision to latest
		self.db.profile.Version = w
	end
end

function Bartender3:ConvertBindings()
	for k, v in pairs(self.db.profile.Keybindings or {}) do
		if v and v[1] then
			SetBinding(v[1], k:upper())
		end
		if v and v[2] then
			SetBinding(v[2], k:upper())
		end
	end
	for i=1,120 do
		local key1, key2 = GetBindingKey(("CLICK BT3Button%d:LeftButton"):format(i))
		if key1 then SetBinding(key1, ("BT3BUTTON%d"):format(i)) end
		if key2 then SetBinding(key2, ("BT3BUTTON%d"):format(i)) end
	end
	for i=1,12 do
		local key1, key2 = GetBindingKey(("BT3BUTTON%d"):format(i))
		if key1 then SetBinding(key1, ("ACTIONBUTTON%d"):format(i)) end
		if key2 then SetBinding(key2, ("ACTIONBUTTON%d"):format(i)) end
	end
	SaveBindings(GetCurrentBindingSet())
	-- remove old bindings ( no longer used )
	self.db.profile.Keybindings = nil
end

function Bartender3:SetupDefaults()
	self.defaults = {
		Bars = {
			['**'] = {
				Rows = 1,
				Padding = 0,
				Scale = 1,
				Alpha = 1,
				Hide = false,
				Enabled = true,
				Buttons = 12,
				StatesEnabled = false,
				ShowGrid = false,
				Style = "Dreamlayout",
				States = {},
				Stances = {},
				HideHotkey = false,
				HideMacrotext = false,
				FadeOut = false,
			},
			[1] = {
				StatesEnabled = true,
			},
			[2] = {
				Enabled = false,
			},
			[3] = {
				Rows = 12,
			},
			[4] = {
				Rows = 12,
			},
			[5] = {
			},
			[6] = {
			},
			[7] = {
				Enabled = false,
			},
			[8] = {
				Enabled = false,
			},
			[9] = {
				Enabled = false,
			},
			[10] = {
				Enabled = false,
			},
		},
		SpecialBars = {
			['**'] = {
				Rows = 1,
				Padding = 0,
				Scale = 1,
				Alpha = 1,
				Hide = false,
				Enabled = true,
				Style = "Dreamlayout",
				FadeOut = false,
			},
			["STANCE"] = {
			},
			["PET"] = {
			},
			["MICROMENU"] = {
				Padding = -4,
				Style = "Default",
			},
			["BAGS"] = {
				Padding = 1,
				Keyring = true,
				OneBag = false,
			},
			["XP"] = {
				Hide = true,
				Style = "Default",
			},
			["REPUTATION"] = {
				Hide = true,
				Style = "Default",
			},
		},
		Tooltip = "enabled",
		SelfCastModifier = true,
		SelfCastRightClick = false,
		ButtonLock = false,
		OutOfRange = true,
		Colors = { OutOfRange = { r = 0.8, g = 0.1, b = 0.1 }, OutOfMana = { r = 0.5, g = 0.5, b = 1.0 } },
		Sticky = true,
	}
	
	self.defaultpositions = {
		[1] = {
			PosX = -5,
			PosY = -5,
			Anchor = "BOTTOMLEFT",
		},
		[2] = {
			PosX = 300,
			PosY = 300,
			Anchor = "BOTTOMLEFT",
		},
		[3] = {
			PosX = -41,
			PosY = 100,
			Anchor = "BOTTOMRIGHT",
		},
		[4] = {
			PosX = -77,
			PosY = 100,
			Anchor = "BOTTOMRIGHT",
		},
		[5] = {
			PosX = -5,
			PosY = 67,
			Anchor = "BOTTOMLEFT",
		},
		[6] = {
			PosX = -5,
			PosY = 31,
			Anchor = "BOTTOMLEFT",
		},
		[7] = {
			PosX = 300,
			PosY = 336,
			Anchor = "BOTTOMLEFT",
		},
		[8] = {
			PosX = 300,
			PosY = 372,
			Anchor = "BOTTOMLEFT",
		},
		[9] = {
			PosX = 300,
			PosY = 408,
			Anchor = "BOTTOMLEFT",
		},
		[10] = {
			PosX = 300,
			PosY = 444,
			Anchor = "BOTTOMLEFT",
		},
		["STANCE"] = {
			PosX = 20,
			PosY = 123,
			Anchor = "BOTTOMLEFT",
		},
		["PET"] = {
			PosX = 20,
			PosY = 153,
			Anchor = "BOTTOMLEFT",
		},
		["MICROMENU"] = {
			PosX = -208,
			PosY = -5,
			Anchor = "BOTTOMRIGHT",
		},
		["BAGS"] = {
			PosX = -213,
			PosY = 33,
			Anchor = "BOTTOMRIGHT",
		},
		["XP"] = {
			PosX = 0,
			PosY = 0,
			Anchor = "BOTTOMLEFT",
		},
		["REPUTATION"] = {
			PosX = 0,
			PosY = 13,
			Anchor = "BOTTOMLEFT",
		},
	}
	
	self:RegisterDefaults('profile', self.defaults)
end
