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

--[[ $Id: ActionBarStates.lua 50231 2007-09-29 08:50:20Z nevcairiel $ ]]
local Bartender3 = Bartender3

local VERSION = tonumber(("$Revision: 50231 $"):match("%d+"))
if Bartender3.revision < VERSION then
	Bartender3.version = Bartender3.versionstring:format(VERSION)
	Bartender3.revision = VERSION
	Bartender3.date = ('$Date: 2007-09-29 04:50:20 -0400 (Sat, 29 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local L = AceLibrary("AceLocale-2.2"):new("Bartender3")

local table_insert = table.insert
local table_remove = table.remove
local table_concat = table.concat

Bartender3.statemodifiers = { "ctrl", "shift", "alt" }


local function tfind(haystack, needle, searchfunc)
	for i,v in pairs(haystack) do
		if (searchfunc and searchfunc(v, needle) or (v == needle)) then return i end
	end
	return nil
end

-- values taken from Babble-Spell-2.2
-- not in the AceLocale for simplicity and a better overview
-- and no dep on BS-2.2, that would be overkill imho :p
local STANCES
local LOCALE = GetLocale()
if LOCALE == "deDE" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "Kampfhaltung",
		["Defensive Stance"] = "Verteidigungshaltung",
		["Berserker Stance"] = "Berserkerhaltung",
		-- druid
		["Bear Form"] = "B\195\164rengestalt",
		["Dire Bear Form"] = "Terrorb\195\164rengestalt",
		["Cat Form"] = "Katzengestalt",
		["Tree of Life"] = "Baum des Lebens",
		["Moonkin Form"] = "Mondkingestalt",
		-- rogue
		["Stealth"] = "Verstohlenheit",
	}
elseif LOCALE == "frFR" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "Posture de combat",
		["Defensive Stance"] = "Posture d\195\169fensive",
		["Berserker Stance"] = "Posture berserker",
		-- druid
		["Bear Form"] = "Forme d'ours",
		["Dire Bear Form"] = "Forme d'ours redoutable",
		["Cat Form"] = "Forme de f\195\169lin",
		["Tree of Life"] = "Arbre de vie",
		["Moonkin Form"] = "Forme de s\195\169l\195\169nien",
		-- rogue
		["Stealth"] = "Camouflage",
	}
elseif LOCALE == "esES" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "Actitud de batalla",
		["Defensive Stance"] = "Actitud defensiva",
		["Berserker Stance"] = "Actitud rabiosa",
		-- druid
		["Bear Form"] = "Forma de oso",
		["Dire Bear Form"] = "Forma de oso temible",
		["Cat Form"] = "Forma felina",
		["Tree of Life"] = "\195\129rbol de vida",
		["Moonkin Form"] = "Forma de lech\195\186cico lunar",
		-- rogue
		["Stealth"] = "Sigilo",
	}
elseif LOCALE == "zhCN" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "战斗姿态",
		["Defensive Stance"] = "防御姿态",
		["Berserker Stance"] = "狂暴姿态",
		-- druid
		["Bear Form"] = "熊形态",
		["Dire Bear Form"] = "巨熊形态",
		["Cat Form"] = "猎豹形态",
		["Tree of Life"] = "Tree of Life", -- need this
		["Moonkin Form"] = "枭兽形态",
		-- rogue
		["Stealth"] = "潜行",
	}
elseif LOCALE == "zhTW" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "戰鬥姿態",
		["Defensive Stance"] = "防禦姿態",
		["Berserker Stance"] = "狂暴姿態",
		-- druid
		["Bear Form"] = "熊形態",
		["Dire Bear Form"] = "巨熊形態",
		["Cat Form"] = "獵豹形態",
		["Tree of Life"] = "生命之樹",
		["Moonkin Form"] = "梟獸形態",
		-- rogue
		["Stealth"] = "潛行",
	}
elseif LOCALE == "koKR" then
	STANCES = {
		-- warrior
		["Battle Stance"] = "전투 태세",
		["Defensive Stance"] = "방어 태세",
		["Berserker Stance"] = "광폭 태세",
		-- druid
		["Bear Form"] = "곰 변신",
		["Dire Bear Form"] = "광포한 곰 변신",
		["Cat Form"] = "표범 변신",
		["Tree of Life"] = "생명의 나무",
		["Moonkin Form"] = "달빛야수 변신",
		-- rogue
		["Stealth"] = "은신",
	}
else
	if LOCALE ~= "enUS" and LOCALE ~= "enGB" then
		Bartender3:Print("Your Locale is not officially supported by Bartender3. Stances/Shapeshifting will not work correctly.")
		Bartender3:Print("If you want to help and add support for your Locale, please contact the author at h.leppkes AT gmail DOT com")
		Bartender3:Print("Your Locale was reported as: " .. LOCALE)
	end
	STANCES = {
		-- warrior
		["Battle Stance"] = "Battle Stance",
		["Defensive Stance"] = "Defensive Stance",
		["Berserker Stance"] = "Berserker Stance",
		-- druid
		["Bear Form"] = "Bear Form",
		["Dire Bear Form"] = "Dire Bear Form",
		["Cat Form"] = "Cat Form",
		["Tree of Life"] = "Tree of Life",
		["Moonkin Form"] = "Moonkin Form",
		-- rogue
		["Stealth"] = "Stealth",
	}
end

-- stances, indexd by their actual name
Bartender3.DefaultStanceMap = { 
	["WARRIOR"] = {
		{
			short = "battle",
			name = STANCES["Battle Stance"],
			defpage = 7,
		},
		{
			short = "def",
			name = STANCES["Defensive Stance"],
			defpage = 8,
		},
		{
			short = "berserker",
			name = STANCES["Berserker Stance"],
			defpage = 9,
		},
	},
	["DRUID"] = {
		{
			ashort = "bear",
			short = "bear",
			name = STANCES["Bear Form"],
			defpage = 9,
		},
		{
			ashort = "direbear",
			short = "bear",
			name = STANCES["Dire Bear Form"],
			defpage = 9,
		},
		{
			short = "cat",
			name = STANCES["Cat Form"],
			defpage = 7,
		},
		{
			short = "moonkin",
			name = STANCES["Moonkin Form"],
		},
		{
			short = "treeoflife",
			name = STANCES["Tree of Life"],
		},
		{
			name = L["Cat Form (Prowl)"],
			short = "prowl",
			defpage = 8,
			dummy = true,
			special = true,
			depend = "cat",
		},
	},
	["ROGUE"] = {
		{
			short = "stealth",
			name = STANCES["Stealth"],
			defpage = 7,
		},
	},
	["PRIEST"] = {
		{
			name = L["Shadowform"],
			short = "shadowform",
			dummy = true,
		},
	}
}

local num_shapeshift_forms
function onUpdateShapeshiftForms()
	local newforms = GetNumShapeshiftForms()
	if num_shapeshift_forms ~= newforms then
		Bartender3:CreateStanceMap()
		for k,v in pairs(Bartender3.actionbars) do
			if v then v:UpdateStates() end
		end
	end
end

Bartender3:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", onUpdateShapeshiftForms)

local validStanceTable = { ["-1"] = "Hide", ["0"] = "Don't Page", ["1"] = "Page  1", ["2"] = "Page  2", ["3"] = "Page  3", ["4"] = "Page  4", ["5"] = "Page  5", ["6"] = "Page  6", ["7"] = "Page  7", ["8"] = "Page  8", ["9"] = "Page  9", ["10"] = "Page 10" }

function Bartender3:CreateStanceMap()
	local class = Bartender3.playerclass
	local stanceinfo = Bartender3.DefaultStanceMap[class]
	if not stanceinfo then return end
	
	num_shapeshift_forms = GetNumShapeshiftForms()
	
	self.stancemap = {}
	
	for i,v in pairs(stanceinfo) do
		table_insert(self.stancemap, {
				["ashort"] = v.ashort,
				["short"] = v.short,
				["index"] = nil,
				["name"] = v.name,
				["defpage"] = v.defpage,
				["special"] = v.special,
			})
	end
	
	for i = 1, num_shapeshift_forms do
		local tex, name, isActive = GetShapeshiftFormInfo(i)
		local index = tfind(self.stancemap, name, function(h, n) return h.name == n end)
		if index then
			local v = self.stancemap[index]
			v.index = i
		end
	end
	
	if class == "DRUID" then
		local index = tfind(self.stancemap, "direbear", function(h, n) return h.ashort == n end)
		if self.stancemap[index].index then
			local index2 = tfind(self.stancemap, "bear", function(h, n) return h.ashort == n end)
			self.stancemap[index2].hide = true
			self.stancemap[index].hide = nil
		else
			self.stancemap[index].hide = true
		end
	end
	
	-- look for  dummys and add those, and hide redundant ones
	for i=1,#stanceinfo do
		if stanceinfo[i].dummy then
			local depend = stanceinfo[i].depend
			if depend then
				local index = tfind(self.stancemap, depend, function(h, n) return h.short == n end)
				self.stancemap[i].index = index and (self.stancemap[index].index ~= nil) and i
			else
				self.stancemap[i].index = i
			end
		end
	end
end

function Bartender3.Class.ActionBar.prototype:InitStates()
	if not Bartender3.stancemap then Bartender3:CreateStanceMap() end
	local class, frame = Bartender3.playerclass, self.frame
	local stancemap = Bartender3.stancemap
	
	-- setup states
	if not self.config.States then self.config.States = {} end
	
	-- Setup Stances
	if stancemap then
		-- sanity check for weird setups - you never know
		if not self.config.Stances then self.config.Stances = {} end
		-- stance config is empty and we are bar1, setup default stances - all stances, no matter what the user actually has, he might learn them later
		if self.mainbar and not next(self.config.Stances) then 
			for _,v in pairs(Bartender3.DefaultStanceMap[class]) do 
			-- set default stance page if one was set
				if self.config.Stances[v.short] == nil and v.defpage then
					self.config.Stances[v.short] = tostring(v.defpage)
				end
			end
		end
		-- add stances to our options table
		if self.optionstable then
			local options = self.optionstable
			for i,v in pairs(stancemap) do
				if not options.args.paging.args.stance.args[v.ashort or v.short] then
					options.args.paging.args.stance.args[v.ashort or v.short] = {
						order = i,
						name = v.name,
						type = "text",
						desc = L["Configure which bar to switch to in %s."]:format(v.name),
						validate = validStanceTable,
						get = function() return Bartender3:GetConfig(self.id).Stances[v.short] or 0 end,
						set = function(b) Bartender3:GetBarObject(self.id):SetStancePage(v.short, b) end,
						disabled = function() return not Bartender3.stancemap[i].index end,
						hidden = function() return Bartender3.stancemap[i].hide end,
					}
				end
			end
		end
	end
	
	self:UpdateStates()
end

function Bartender3.Class.ActionBar.prototype:UpdateStates()
	if not Bartender3.stancemap then Bartender3:CreateStanceMap() end
	local class, frame = Bartender3.playerclass, self.frame
	
	-- init the statebutton with our 10 bars
	for i=0,10 do
		self:AddButtonStates(i, i)
	end
	
	if self.config.StatesEnabled then
		-- the StateDriver is pretty smart
		-- arguments will be parsed from left to right, so we have a priority here
		local statedriver = {}
		
		-- highest priority have our temporary quick-swap keys
		for i,v in pairs(Bartender3.statemodifiers) do
			local page = self.config.States[v]
			if page and tonumber(page) ~= 0 then 
				table_insert(statedriver, ("[modifier:%s]%s"):format(v, page))
			end
		end
		
		-- second priority the manual changes using the actionbar options
		if self.mainbar then
			for i=2,6 do
				table_insert(statedriver, ("[actionbar:%s]%s"):format(i, i))
			end
		end
		
		-- third priority the stances
		if Bartender3.stancemap then
			for i,v in pairs(Bartender3.stancemap) do
				local state = self:GetStanceState(v)
				if not v.special and state and v.index then
					-- special handling for druid prowling since its no real stance
					-- stealth:1 has a higher priority then general cat stance, so we just add it in before the actual cat line, and no issues whatsoever :)
					if ( class == "DRUID" and v.short == "cat" and self:GetStanceState("prowl") ) then
						local prowl = self:GetStanceState("prowl")
						table_insert(statedriver, ("[stance:%s,stealth:1]%s"):format(v.index, prowl))
					end
					table_insert(statedriver, ("[stance:%s]%s"):format(v.index, state))
				end
			end
		end
		
		-- TODO: Help/Harm support as lowest priority - will only be active in stance:0 ( druid in caster form ) or when stances are not activated
		
		table_insert(statedriver, "0")
		
		RegisterStateDriver(frame, "page", table_concat(statedriver, ";"))
		frame:SetAttribute("statemap-page", "$input")
		frame:SetAttribute("state", frame:GetAttribute("state-page"))
	else
		UnregisterStateDriver(frame)
		frame:SetAttribute("state", "0")
	end
	
	self:ApplyStateButton()
end

function Bartender3.Class.ActionBar.prototype:GetStanceState(stance)
	local state
	if type(stance) == "table" then 
		state = tonumber(self.config.Stances[stance.short])
	else
		state = tonumber(self.config.Stances[stance])
	end
	if state and state == 0 then state = nil end
	return state
end


function Bartender3.Class.ActionBar.prototype:AddButtonStates(state, page)
	for _,v in pairs(self.buttonobjects) do
		local action = (page == 0) and v.id or (v.rid + ((page - 1) * 12))
		v:SetStateAction(state, action)
	end
	self:AddRightClickState(state)
	self:AddToStateButton(state)
end


function Bartender3.Class.ActionBar.prototype:AddToStateButton(state)
	if not self.statebutton then self.statebutton = {} end
	state = tonumber(state)
	if not tfind(self.statebutton, state) then 
		table_insert(self.statebutton, state)
	end
end

function Bartender3.Class.ActionBar.prototype:ApplyStateButton()
	local states1, states2 = {}, {}
	for _,v in pairs(self.statebutton) do
		table_insert(states1, ("%s:S%s1;"):format(v, v))
		table_insert(states2, ("%s:S%s2;"):format(v, v))
	end
	self.frame:SetAttribute("statebutton", table_concat(states1, ""))
	self.frame:SetAttribute("statebutton2", table_concat(states2, ""))
end
