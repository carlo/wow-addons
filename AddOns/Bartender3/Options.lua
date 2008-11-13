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
--[[ $Id: Options.lua 50219 2007-09-29 08:00:43Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 50219 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-29 04:00:43 -0400 (Sat, 29 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

local function getCombatLockdown()
	 return InCombatLockdown()
end

function Bartender3:PopulateOptions()
	self.options = {
		type = "group",
		args = {
			lock = {
				order = 1,
				name = L["Lock"], 
				type = "toggle",
				desc = L["Toggle the lock of the action bars."],
				get = function() return not Bartender3.unlock end,
				set = function(v)
					if Bartender3.unlock then
						Bartender3:LockBars()
					else
						Bartender3:UnlockBars()
					end
				end,
				disabled = getCombatLockdown,
			},
			buttonlock = {
				order = 2,
				name = L["Lock Buttons"], 
				type = "toggle",
				desc = L["Toggle the lock of the buttons."],
				get = function() return Bartender3.db.profile.ButtonLock end,
				set = function() Bartender3:LockButtons(true) end,
			},
			head1 = {
				order = 3,
				type = "header",
			},
			tooltip = {
				order = 4,
				name = L["Button Tooltip"],
				type = "text",
				desc = L["Configure the Button Tooltip."],
				get = function() return Bartender3.db.profile.Tooltip end,
				set = function(h)
					Bartender3.db.profile.Tooltip = h
				end,
				validate = { ["disabled"] = L["Disabled"], ["nocombat"] = L["Disabled in Combat"], ["enabled"] = L["Enabled"] }
			},
			selfcast = {
				order = 5,
				name = L["Self Casting"],
				desc = L["Configute Self Casting options"],
				type = "group",
				args = {
					modifier = {
						order = 1,
						name = L["Modifier SelfCast"],
						desc = L["SelfCast using the Interface SelfCast Modifier"],
						type = "toggle",
						get = function() return Bartender3.db.profile.SelfCastModifier end,
						set = function(scm)
							Bartender3.db.profile.SelfCastModifier = scm
							for i,v in pairs(Bartender3.actionbars) do
								if v then v:UpdateSelfCast() end
							end
						end,
					},
					rightclick = {
						order = 2,
						name = L["RightClick SelfCast"],
						desc = L["SelfCast using Right click"],
						type = "toggle",
						get = function() return Bartender3.db.profile.SelfCastRightClick end,
						set = function(v)
							Bartender3.db.profile.SelfCastRightClick = v
							for i,v in pairs(Bartender3.actionbars) do
								if v then v:UpdateSelfCast() end
							end
						end,
					},
				},
				disabled = getCombatLockdown,
			},
			range = {
				order = 7,
				name = L["Out of Range Indicator"],
				desc = L["Configure the button recoloring based on range"],
				type = "text",
				get = function() return Bartender3.db.profile.OutOfRange end,
				set = function(sc) 
					Bartender3.db.profile.OutOfRange = sc
					for k, v in pairs(Bartender3.actionbuttons) do
						if v.object then v.object:UpdateUsable(); v.object:UpdateHotkeys(); end
					end
				end,
				validate = { ["none"] = L["None"], ["button"] = L["Button"], ["hotkey"] = L["Hotkey"] },
			},
			colors = {
				order = 8,
				name = L["Color Configuration"],
				desc = L["Configure the colors of the range and Out of Mana Indicators"],
				type = "group",
				args = {
					range = {
						name = L["Out of Range"],
						desc = L["Configure the color of the out of range indicator"],
						type = "color",
						get = function() 
							local c = Bartender3.db.profile.Colors.OutOfRange
							return c.r, c.g, c.b
						end,
						set = function(r,g,b)
							local c = Bartender3.db.profile.Colors.OutOfRange
							c.r, c.g, c.b = r,g,b
						end,
					},
					mana = {
						name = L["Out of Mana"],
						desc = L["Configure the color of the out of mana indicator"],
						type = "color",
						get = function() 
							local c = Bartender3.db.profile.Colors.OutOfMana
							return c.r, c.g, c.b
						end,
						set = function(r,g,b)
							local c = Bartender3.db.profile.Colors.OutOfMana
							c.r, c.g, c.b = r,g,b
						end,
					},
				},
			},
			sticky = {
				order = 9,
				name = L["Sticky Frames"],
				desc = L["Snap Bars while moving"],
				type = "toggle",
				get = function() return Bartender3.db.profile.Sticky end,
				set = function(value)
					Bartender3.db.profile.Sticky = value
				end,
			},
			head2 = {
				order = 10,
				type = "header",
			},
			head3 = {
				order = 45,
				type = "header",
			},
		},
	}
	
	self:RegisterChatCommand({ "/bar", "/bartender3", "/bt3" }, self.options )
	self.options.args.standby.hidden = true
end

-- option get/set functions to avoid a new anonymous function for every bar we create

local function getConfig(id, special)
	return Bartender3:GetConfig(id, special)
end

local function getBar(id, special)
	return Bartender3:GetBarObject(id, special)
end

local function getBarEnabledLockdown(table)
	local id, special = table.id, table.special
	return InCombatLockdown() or not getConfig(id, special).Enabled
end

local function getBarEnabled(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Enabled
end

local function getBarDisabled(table)
	return not getBarEnabled(table)
end

local function getBarHide(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Hide
end

local function toggleBarHide(table, value)
	local id, special = table.id, table.special
	getBar(id, special):ToggleVisibilty()
end

local function getRows(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Rows
end

local function setRows(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetRows(value)
end

local function barHasNoRows(table)
	local id, special = table.id, table.special
	return not (#getBar(id, special).buttons > 1)
end

local function getPadding(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Padding
end

local function setPadding(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetPadding(value)
end

local function getScale(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Scale
end

local function setScale(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetScale(value)
end

local function getAlpha(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Alpha
end

local function setAlpha(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetAlpha(value)
	getBar(id, special).faded = nil
end

local function getStyle(table)
	local id, special = table.id, table.special
	return getConfig(id, special).Style
end

local function setStyle(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetStyle(value)
end

local function getFadeOut(table)
	local id, special = table.id, table.special
	return getConfig(id, special).FadeOut
end

local function setFadeOut(table, value)
	local id, special = table.id, table.special
	getBar(id, special):SetFadeOut(value)
end

local function toggleEnabled(table)
	local id, special = table.id, table.special
	Bartender3:ToggleBarEnabled(id, special)
end

local function getHideMacroText(table)
	local id = table.id
	return not getConfig(id).HideMacrotext
end

local function setHideMacroText(table, value)
	local id = table.id
	getConfig(id).HideMacrotext = not value
	for _,v in pairs(getBar(id).buttonobjects) do
		v:UpdateButton(true)
	end
end

local function getHideHotkey(table)
	local id = table.id
	return not getConfig(id).HideHotkey
end

local function setHideHotkey(table, value)
	local id = table.id
	getConfig(id).HideHotkey = not value
	for _,v in pairs(getBar(id).buttonobjects) do
		v:UpdateHotkeys()
	end
end

local function getShowGrid(table)
	local id = table.id
	return getConfig(id).ShowGrid
end

local function setShowGrid(table, value)
	local id = table.id
	getBar(id):SetShowGrid(value)
end

local function getStatesEnabled(table)
	local id = table.id
	return getConfig(id).StatesEnabled
end

local function setStatesEnabled(table, value)
	local id = table.id
	getConfig(id).StatesEnabled = value
	getBar(id):UpdateStates()
end

local function getStatesDisabled(table)
	local id = table.id
	return not getConfig(id).StatesEnabled
end

local function noStanceMap()
	return (Bartender3.stancemap == nil)
end

local function getModifier(table)
	local id, mod = table.id, table.modifier
	return (getConfig(id).States[mod] or 0)
end

local function setModifier(table, value)
	local id, mod = table.id, table.modifier
	getBar(id):SetModifierState(mod, value)
end

local function getButtons(table)
	local id = table.id
	return getConfig(id).Buttons
end

local function setButtons(table, value)
	local id = table.id
	getBar(id):SetButtons(value)
end

local function resetBar(table)
	local id, special = table.id, table.special
	if special then
		Bartender3.db.profile.SpecialBars[id] = nil
	else
		Bartender3.db.profile.Bars[tonumber(id)] = nil
	end
	ReloadUI()
end

function Bartender3:CreateBarOptions(id, name, special)
	local optionname = ( special ) and (id:lower().."bar") or ("bar"..id)
	
	local order = ( special ) and 50 or (30+id)
	-- Options for all bartypes
	self.options.args[optionname] = {
		order = order, 
		name = name,
		type = "group",
		desc = L["Configuration for %s"]:format(name),
		args = {
			enabled = {
				order = 1,
				name = L["Enabled"],
				type = "toggle",
				desc = L["Enable %s."]:format(name),
				get = getBarEnabled,
				set = toggleEnabled,
				disabled = getCombatLockdown,
				passValue = {["id"] = id, ["special"] = special},
			},
			hide = {
				order = 2,
				name = L["Hide"],
				type = "toggle",
				desc = L["Hide %s"]:format(name),
				get = getBarHide,
				set = toggleBarHide,
				disabled = getBarEnabledLockdown,
				passValue = {["id"] = id, ["special"] = special},
			},
			rows = {
				order = 4,
				name = L["Rows"],
				type = "range",
				desc = L["Change the rows of the Bar"],
				max = 12, min = 1, step = 1, -- maxbuttons will be adjusted by the bar itself.
				get = getRows,
				set = setRows,
				disabled = getBarEnabledLockdown,
				--hidden = barHasNoRows,
				passValue = {["id"] = id, ["special"] = special},
			},
			padding = {
				order = 5,
				name = L["Padding"],
				type = "range",
				desc = L["Change the padding of the bar."],
				min = -20, max = 30, step = 1,
				get = getPadding,
				set = setPadding,
				disabled = getBarEnabledLockdown,
				passValue = {["id"] = id, ["special"] = special},
			},
			scale = {
				order = 6,
				name = L["Scale"],
				type = "range",
				desc = L["Change the scale of the bar."],
				min = .1, max = 2, step = 0.01, bigStep = 0.05,
				isPercent = true,
				get = getScale,
				set = setScale,
				disabled = getBarEnabledLockdown,
				passValue = {["id"] = id, ["special"] = special},
			},
			alpha = {
				order = 7,
				name = L["Alpha"],
				type = "range",
				desc = L["Change the alpha of the bar."],
				min = .1, max = 1, step = 0.01, bigStep = 0.05,
				get = getAlpha,
				set = setAlpha,
				disabled = getBarDisabled,
				passValue = {["id"] = id, ["special"] = special},
			},
			style = {
				order = 8,
				name = L["Style"],
				type = "text",
				desc = L["Change the style of the bar."],
				get = getStyle,
				set = setStyle,
				disabled = getBarEnabledLockdown,
				passValue = {["id"] = id, ["special"] = special},
				validate = {}
			},
			fadeout = {
				order = 9,
				name = L["FadeOut"],
				type = "toggle",
				desc = L["Fade out the Bar when not hovering it."],
				get = getFadeOut,
				set = setFadeOut,
				disabled = getBarDisabled,
				passValue = {["id"] = id, ["special"] = special},
			},
			sep = {
				order = 30,
				type = "header",
			},
			reset = {
				order = 31,
				name = L["Reset"],
				type = "execute",
				desc = L["Reset this bar.\n Warning: This will reload your UI afterwards to restore functionality."],
				func = resetBar,
				disabled = getCombatLockdown,
				passValue = {["id"] = id, ["special"] = special},
			},
		}
	}
	
	local options = self.options.args[optionname]
	
	for k,v in pairs(Bartender3.styles) do
		options.args.style.validate[k] = v.name
	end

	-- Options for ActionBars
	if not special then
		options.args.macrotext = {
			order = 9,
			name = L["Macro Text"],
			type = "toggle",
			desc = L["Show the button Macro Text"],
			get = getHideMacroText,
			set = setHideMacroText,
			disabled = getBarEnabledLockdown,
			passValue = {["id"] = id, ["special"] = special},
		}
		options.args.hotkey = {
			order = 9,
			name = L["Hotkey"],
			type = "toggle",
			desc = L["Show the button Hotkey"],
			get = getHideHotkey,
			set = setHideHotkey,
			disabled = getBarEnabledLockdown,
			passValue = {["id"] = id, ["special"] = special},
		}
		options.args.showgrid = {
			order = 9,
			name = L["Show Grid"],
			type = "toggle",
			desc = L["Show the grid of the bar even while locked."],
			get = getShowGrid,
			set = setShowGrid,
			disabled = getBarDisabled,
			passValue = {["id"] = id, ["special"] = special},
		}
		options.args.paging = {
			order = 10,
			name = L["Button Paging"],
			type = "group",
			desc = L["Configure the State-Based Button Swapping."],
			args = {
				enabled = {
					order = 1,
					name = L["Enabled"],
					type = "toggle",
					desc = L["Toggle the Paging support."],
					get = getStatesEnabled,
					set = setStatesEnabled,
					passValue = {["id"] = id, ["special"] = special},
				},
				modifier = {
					order = 2,
					name = L["Modifier"],
					type = "group",
					desc = L["Swapping based on the modifiers."],
					args = {},
					disabled = getStatesDisabled,
					passValue = {["id"] = id, ["special"] = special},
				},
				stance = {
					order = 3,
					name = L["Stances"],
					type = "group",
					desc = L["Swapping based on your Stance."],
					args = {},
					hidden = noStanceMap,
					disabled = getStatesDisabled,
					passValue = {["id"] = id, ["special"] = special},
				},
			},
			disabled = getBarEnabledLockdown,
			passValue = {["id"] = id, ["special"] = special},
		}
		for _,m in pairs(self.statemodifiers) do
			options.args.paging.args.modifier.args[m] = {
				name = L[m],
				type = "range",
				desc = L["Configure which bar to switch to when %s is down."]:format(L[m]),
				min = 0, max = 10, step = 1,
				get = getModifier,
				set = setModifier,
				passValue = {["id"] = id, ["special"] = special, ["modifier"] = m},
			}
		end
		options.args.buttons = {
			order = 11,
			name = L["Buttons"],
			type = "range",
			desc = L["Configure the number of Buttons."],
			min = 1, max = 12, step = 1,
			get = getButtons,
			set = setButtons,
			disabled = getBarEnabledLockdown,
			passValue = {["id"] = id, ["special"] = special},
		}
	else
		if id == "BAGS" then
			options.args.keyring = {
				order = 10,
				name = L["Keyring"],
				type = "toggle",
				desc = L["Toggle the Keyring"],
				get = function() return self:GetConfig(id, special).Keyring end, -- we only have one bag bar, so only once the functions -- keep them here
				set = function()
					self:GetBarObject(id, special):ToggleKeyring()
				end,
				disabled = getCombatLockdown,
			}
			options.args.onebag = {
				order = 11,
				name = L["OneBag"],
				type = "toggle",
				desc = L["Toggle the display of only one Bag Icon"],
				get = function() return self:GetConfig(id, special).OneBag end,
				set = function()
					self:GetBarObject(id, special):ToggleOneBag()
				end,
				disabled = getCombatLockdown,
			}
		elseif id == "MICROMENU" then
			options.args.style = nil
		elseif id == "XP" or id == "REPUTATION" then
			options.args.style = nil
			options.args.rows = nil
			options.args.padding = nil
		end
	end
	
	return options
end

function Bartender3:CreateDisabledBarOptions(id, name, special)
	local optionname = special and id:lower() .."bar" or "bar"..id
	
	self.options.args[optionname] = {
		order = special and 50 or 30+id,
		name = name,
		type = "group",
		desc = L["Configuration for %s"]:format(name),
		args = {
			enabled = {
				order = 1,
				name = L["Enabled"],
				type = "toggle",
				desc = L["Enable %s."]:format(name),
				get = getBarEnabled,
				set = toggleEnabled,
				passValue = {["id"] = id, ["special"] = special},
				disabled = getCombatLockdown,
			},
		},
	}
end
