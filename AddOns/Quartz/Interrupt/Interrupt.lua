--[[
	Copyright (C) 2006-2007 Nymbia

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local L = AceLibrary("AceLocale-2.2"):new("Quartz")
local deformat = AceLibrary("Deformat-2.0")
local db
if Quartz:HasModule('Interrupt') then
	return
end
local QuartzInterrupt = Quartz:NewModule('Interrupt')
local QuartzPlayer = Quartz:GetModule('Player')

local SPELLINTERRUPTOTHERSELF = SPELLINTERRUPTOTHERSELF
function QuartzInterrupt:OnInitialize()
	db = Quartz:AcquireDBNamespace("Interrupt")
	Quartz:RegisterDefaults("Interrupt", "profile", {
		interruptcolor = {0,0,0},
	})
end
function QuartzInterrupt:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE", 'CheckInterrupt')
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", 'CheckInterrupt')
end
function QuartzInterrupt:CheckInterrupt(msg)
	local player, spell = deformat(msg, SPELLINTERRUPTOTHERSELF)
	if player then
		QuartzPlayer.castBarText:SetText(L["INTERRUPTED (%s)"]:format(player:upper()))
		QuartzPlayer.castBar:SetStatusBarColor(unpack(db.profile.interruptcolor))
		QuartzPlayer.stopTime = GetTime()
	end
end
Quartz.options.args.Interrupt = {
	type = 'group',
	name = L["Interrupt"],
	desc = L["Interrupt"],
	order = 600,
	args = {
		toggle = {
			type = 'toggle',
			name = L["Enable"],
			desc = L["Enable"],
			get = function()
				return Quartz:IsModuleActive('Interrupt')
			end,
			set = function(v)
				Quartz:ToggleModuleActive('Interrupt', v)
			end,
			order = 100,
		},
		interruptcolor = {
			type = 'color',
			name = L["Interrupt Color"],
			desc = L["Set the color the cast bar is changed to when you have a spell interrupted"],
			set = function(...)
				db.profile.interruptcolor = {...}
			end,
			get = function()
				return unpack(db.profile.interruptcolor)
			end,
			order = 101,
		},
	},
}