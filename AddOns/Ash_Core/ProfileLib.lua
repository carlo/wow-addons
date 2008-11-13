ProfileLib = AsheylaLib:NewModule("ProfileLib","GUILib")
local modules = {}
local selectedmodules = {}

function ProfileLib:RegisterForProfiles(module)
	table.insert(modules,module)
end

function ProfileLib:LoadProfile(profile)
	if type(profile) == "string" then
		for i,v in ipairs(self:Get("profiles")) do
			if v.name == profile then
				profile = v
				break
			end
		end
	end
	if profile and type(profile) == "table" then
		for i,v in pairs(profile.modules) do
			local module = AsheylaLib:GetModule(i)
			module:RegisterSettings()
			self:ClearTable(module:GetSettings())
			for index,value in pairs(v) do
				module:Set(index,value)
			end
			module:UpdateSettings()
		end
		self:Print("Profile < ",profile.name," > loaded successfully!")
	end
end

local flagbuttons = {
	["ProfileLibEnterCombatCheckButton"] = "combat-true",
	["ProfileLibLeaveCombatCheckButton"] = "combat-false",
	["ProfileLibJoinGroupCheckButton"] = "group-true",
	["ProfileLibLeaveGroupCheckButton"] = "group-false",
	["ProfileLibUseOtherwiseCheckButton"] = "otherwise",
	["ProfileLibDefaultProfileCheckButton"] = "default",
}

function ProfileLib:InitiateProfileCreation()
	ProfileLibNameEditBox:Show()
	ProfileLibModulesDropDown:Show()
	ProfileLibOnlyCharCheckButton:Show()
	ProfileLibEnterCombatCheckButton:Show()
	ProfileLibLeaveCombatCheckButton:Show()
	ProfileLibJoinGroupCheckButton:Show()
	ProfileLibLeaveGroupCheckButton:Show()
	ProfileLibUseOtherwiseCheckButton:Show()
	ProfileLibDefaultProfileCheckButton:Show()
	ProfileLibDoneButton:Show()
	for i,v in pairs(selectedmodules) do selectedmodules[i] = nil end
end

function ProfileLib:ClearMenu()
	ProfileLibNameEditBox:Hide()
	ProfileLibNameEditBox:SetText("")
	ProfileLibModulesDropDown:Hide()
	ProfileLibOnlyCharCheckButton:Hide()
	ProfileLibEnterCombatCheckButton:Hide()
	ProfileLibLeaveCombatCheckButton:Hide()
	ProfileLibJoinGroupCheckButton:Hide()
	ProfileLibLeaveGroupCheckButton:Hide()
	ProfileLibUseOtherwiseCheckButton:Hide()
	ProfileLibDefaultProfileCheckButton:Hide()
	ProfileLibDoneButton:Hide()
end

function ProfileLib:CreateProfile()
	local newprofile = {
		modules = {},
		flags = {},
	}
	newprofile.name = ProfileLibNameEditBox:GetText()
	if newprofile.name == "" then
		self:Print("Please type a name for your profile!")
		return
	end
	local hasmodules
	for i,v in pairs(selectedmodules) do
		hasmodules = true
		local settings = self:CopyTable(i:GetSettings(),1)
		newprofile.modules[i:GetName()] = settings
	end
	if not hasmodules then
		self:Print("Please select one or more modules!")
		return
	end
	if ProfileLibOnlyCharCheckButton:GetChecked() then newprofile.onlychar = GetRealmName().."-"..UnitName("player") end
	for i,v in pairs(flagbuttons) do
		if getglobal(i):GetChecked() then newprofile.flags[v] = 1 end
	end
	self:Set("profiles","+",newprofile)
	self:Print("Your profile has been created successfully!")
	self:ClearMenu()
end

local sortfunc = function(a,b) return a.name < b.name end

local function dropdown()
	local DROPDOWNLIB_MENU_LEVEL = DropDownLib:MenuLevel()
	local DROPDOWNLIB_MENU_VALUE = DropDownLib:MenuValue()
	local info
	if DROPDOWNLIB_MENU_LEVEL == 3 then
		info = DropDownLib:GetTable()
		info.text = "Load Me!"
		info.notCheckable = 1
		info.textR = .2
		info.textG = 1
		info.textB = .2
		info.arg1 = DROPDOWNLIB_MENU_VALUE
		info.func = function(arg1) ProfileLib:LoadProfile(arg1) DropDownLib:CloseDropDownMenus() end
		DropDownLib:AddButton(info,3)
		info = DropDownLib:GetTable()
		info.text = ""
		info.disabled = 1
		DropDownLib:AddButton(info,3)
		info = DropDownLib:GetTable()
		info.text = "Remove This Entry"
		info.arg1 = DROPDOWNLIB_MENU_VALUE
		info.notCheckable = 1
		info.textR = 1
		info.textG = .3
		info.textB = .3
		info.func = function(arg1)
			for i,v in ipairs(ProfileLib:Get("profiles")) do
				if v == arg1 then
					ProfileLib:Set("profiles","-",i)
					DropDownLib:CloseDropDownMenus()
					return
				end
			end
		end
		DropDownLib:AddButton(info,3)
	elseif DROPDOWNLIB_MENU_LEVEL == 2 then
		local profiles = ProfileLib:Get("profiles")
		if profiles then
			local generalprofs = {}
			local charprofs = {}
			local id = GetRealmName().."-"..UnitName("player")
			for i,v in ipairs(profiles) do
				if (not v.onlychar) then
					table.insert(generalprofs,v)
				elseif (v.onlychar == id) then 
					table.insert(charprofs,v) 
				end
			end
			table.sort(generalprofs,sortfunc)
			table.sort(charprofs,sortfunc)
			if table.getn(charprofs) > 0 then
				info = DropDownLib:GetTable()
				info.text = "Character-Specific Profiles"
				info.isTitle = 1
				info.notCheckable = 1
				DropDownLib:AddButton(info,2)
				for i,v in ipairs(charprofs) do
					info = DropDownLib:GetTable()
					info.text = v.name
					info.value = v
					info.notCheckable = 1
					info.hasArrow = 1
					DropDownLib:AddButton(info,2)
				end
			end
			if table.getn(generalprofs) > 0 then
				info = DropDownLib:GetTable()
				info.text = "General Profiles"
				info.isTitle = 1
				info.notCheckable = 1
				DropDownLib:AddButton(info,2)
				for i,v in ipairs(generalprofs) do
					info = DropDownLib:GetTable()
					info.text = v.name
					info.value = v
					info.notCheckable = 1
					info.hasArrow = 1
					DropDownLib:AddButton(info,2)
				end
			end
			info = DropDownLib:GetTable()
			info.text = ""
			info.disabled = 1
			DropDownLib:AddButton(info,2)
			info = DropDownLib:GetTable()
			info.text = "Delete All Profiles"
			info.notCheckable = 1
			info.textR = 1
			info.textG = .3
			info.textB = .3
			info.func = function()
				ProfileLib:Set("profiles",nil)
				DropDownLib:CloseDropDownMenus()
			end
			DropDownLib:AddButton(info,2)
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 1 then
		info = DropDownLib:GetTable()
		info.notCheckable = 1
		info.text = "Create New"
		info.func = function() ProfileLib:InitiateProfileCreation() end
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.notCheckable = 1
		info.hasArrow = 1
		info.text = "Load or Delete"
		DropDownLib:AddButton(info,1)
	end
end

local scripts = {
	checkbutton = {
		OnShow = function() this:SetChecked(false) end,
	},
}

local guitable = {
	title = "Profile Creator",
	name = "ProfileMenuFrame",
	scripts = {
		OnShow = function() ProfileLib:ClearMenu() end,
	},
	{ --column 1
		{
			title = "Begin Here!",
			type = "dropdown",
			tooltiptext = "Choose an action.",
			func = function() 
				dropdown()
			end,
			scripts = {
				OnShow = function() getglobal(this:GetName().."Text"):SetText(this.text) end,
			},
			data = {
				text = "Choose..."
			},
		},
		{
			title = "Profile Name",
			name = "ProfileLibNameEditBox",
			type = "editbox",
			tooltiptext = "Type here the name you want to give this profile.",
			scripts = {
				OnEditFocusGained = function() this:HighlightText() end,
				OnEditFocusLost = function() this:HighlightText(0,0) end,
				OnEscapePressed = function()
					local text = this:GetText()
					if text == "" then
						this:ClearFocus()
					else
						this:SetText("")
					end
				end,
				OnEnterPressed = function() this:ClearFocus() end,
			},
		},
		{
			title = "Modules",
			name = "ProfileLibModulesDropDown",
			type = "dropdown",
			tooltiptext = "Select which modules you want this profile to apply to.  Their current settings will be used.",
			func = function()
				local info
				for index,value in ipairs(modules) do
					info = DropDownLib:GetTable()
					info.text = value:GetName()
					info.checked = selectedmodules[value]
					info.arg1 = value
					info.keepShownOnClick = 1
					info.func = function(arg1)
						if this.checked then
							selectedmodules[arg1] = nil
						else
							selectedmodules[arg1] = 1
						end
					end
					DropDownLib:AddButton(info,1)
				end
				info = DropDownLib:GetTable()
				info.text = ""
				info.disabled = 1
				DropDownLib:AddButton(info,1)
				info = DropDownLib:GetTable()
				info.text = "Done!"
				info.notCheckable = 1
				info.textR = .2
				info.textG = 1
				info.textB = .2
				info.func = function()
					DropDownLib:CloseDropDownMenus()
				end
				DropDownLib:AddButton(info,1)
			end,
			scripts = {
				OnShow = function() getglobal(this:GetName().."Text"):SetText(this.text) end,
			},
			data = {
				text = "Choose..."
			},
		},
		{
			title = "Only This Character",
			name = "ProfileLibOnlyCharCheckButton",
			type = "checkbutton",
			tooltiptext = "Check this if you want this profile only visible for this character.  Character-Specific profiles are valued higher than general profiles.",
			scripts = scripts.checkbutton,
		},
		{
			title = "Use When Entering Combat / IC",
			name = "ProfileLibEnterCombatCheckButton",
			type = "checkbutton",
			tooltiptext = "Check this if you want this profile to be automatically set when you enter combat, or to be valued higher when in combat and another profile change occurs.",
			scripts = scripts.checkbutton,
			overridescripts = {
				OnClick = function() if this:GetChecked() then ProfileLibLeaveCombatCheckButton:SetChecked(false) end end,
			},
		},
		{
			title = "Use When Leaving Combat / OOC",
			name = "ProfileLibLeaveCombatCheckButton",
			type = "checkbutton",
			tooltiptext = "Check this if you want this profile to be automatically set when you leave combat, or to be valued higher when out of combat and another profile change occurs.",
			scripts = scripts.checkbutton,
			overridescripts = {
				OnClick = function() if this:GetChecked() then ProfileLibEnterCombatCheckButton:SetChecked(false) end end,
			},
		},
		{
			title = "Use When Joining Group / Grouped",
			name = "ProfileLibJoinGroupCheckButton",
			type = "checkbutton",
			scripts = scripts.checkbutton,
			overridescripts = {
				OnClick = function() if this:GetChecked() then ProfileLibLeaveGroupCheckButton:SetChecked(false) end end,
			},
			tooltiptext = "Check this if you want this profile to be automatically set when you join a party or raid, or to be valued higher when grouped and another profile change occurs.",
		},
		{
			title = "Use When Leaving Group / Ungrouped",
			name = "ProfileLibLeaveGroupCheckButton",
			type = "checkbutton",
			scripts = scripts.checkbutton,
			overridescripts = {
				OnClick = function() if this:GetChecked() then ProfileLibJoinGroupCheckButton:SetChecked(false) end end,
			},
			tooltiptext = "Check this if you want this profile to be automatically set when you leave a party or raid, or to be valued higher when ungrouped and another profile change occurs.",
		},
		{
			title = "Use Otherwise",
			name = "ProfileLibUseOtherwiseCheckButton",
			type = "checkbutton",
			scripts = scripts.checkbutton,
			tooltiptext = "Check this if you want this profile to be automatically set when one of the above four things happens, but no other profile is set to be used.",
		},
		{
			title = "Default Profile",
			name = "ProfileLibDefaultProfileCheckButton",
			type = "checkbutton",
			scripts = scripts.checkbutton,
			tooltiptext = "Check this if you want this profile to be loaded when you log into the game.",
		},
		{
			title = "Create!",
			name = "ProfileLibDoneButton",
			type = "button",
			tooltiptext = "Creates the Profile.",
			scripts = {
				OnClick = function() ProfileLib:CreateProfile() end,
			},
		},
		{
			title = "Help",
			type = "button",
			tooltiptext = "Displays some info about profiles.",
			scripts = {
				OnClick = function()
					ProfileLib:Print("|cff00ffffProfile Creator Info:|r")
					ProfileLib:Print("|cff00ff00Basics|r: This menu lets you set profiles of settings for DoTimer, Cooldowns, Communication, and Notifications.  These profiles can be loaded at a later time for quick swapping of multiple settings, or for creating different layouts for different characters.")
					ProfileLib:Print("|cff00ff00Transitions|r: You can select flags for your profiles, which can cause them to be automatically loaded when a certain event occurs, currently entering/leaving combat and joining/leaving a group.")
					ProfileLib:Print("|cff00ff00Rules|r: The addon tries to make the most appropriate selection of which profile to load.  It uses a system of events and conditions.  When you enter/leave combat or join/leave a group, that action is the event.  When that happens, the OTHER pair becomes a condition.")
					ProfileLib:Print("|cff00ff00Continued|r: So if you enter combat and are not grouped, the event is entering combat and the condition is ungrouped.  The addon scans your profiles and selects the ones that meet that event and are not flagged for the opposite of the condition (in the example, grouped).")
					ProfileLib:Print("|cff00ff00Continued|r: Then it separates the character-specific from the general profiles.  It scans the char-spec ones, looking for one that has the correct condition (ungrouped).  If it can't find one, it just looks for one that has no condition (neither grouped nor ungrouped was specified).  Then it looks for an 'Otherwise' profile.")
					ProfileLib:Print("|cff00ff00Continued|r: Then it does the same thing, but for general profiles.  As soon as it finds a profile that matches all this, it stops searching.  Complicated, eh?  Use wisely.")
				end,
			},
		},
		{
			title = "Close",
			type = "button",
			tooltiptext = "Closes this window.",
			scripts = {
				OnClick = function() this.holder.place.column.menu:Hide() end,
			},
		},
	},
}

function ProfileLib:ShowGUI()
	if not ProfileMenuFrame then
		ProfileLib:CreateGUI(guitable)
	end
	ProfileMenuFrame:Show()
end

local f = CreateFrame("Frame")
f.loaded = false
f.combat = 1
f.grouped = 1
f.potential = {}
f.potentialchar = {}
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:SetScript("OnEvent",function(self,event) 
	local id = GetRealmName().."-"..UnitName("player")
	if event == "PLAYER_ENTERING_WORLD" then
		if not this.loaded then
			ProfileLib:RegisterSettings() 
			if ProfileLib:Get("profiles") then
				for i,v in ipairs(ProfileLib:Get("profiles")) do
					if not v.flags then v.flags = {} end
					if v.flags["default"] and (v.onlychar and v.onlychar == id) then
						ProfileLib:LoadProfile(v)
						return
					end
				end
				for i,v in ipairs(ProfileLib:Get("profiles")) do
					if v.flags["default"] and not v.onlychar then
						ProfileLib:LoadProfile(v)
						return
					end
				end
			end
		end
	else
		if not ProfileLib:Get("profiles") then return end
		local changed
		if string.find(event,"REGEN") then changed = "combat" else changed = "group" end
		local combat = UnitAffectingCombat("player") and true or false
		local grouped = (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and true or false
		if not (combat == this.combat and grouped == this.grouped) then
			this.combat = combat
			this.grouped = grouped
			--choose the correct profile to load!
			for i,v in ipairs(this.potential) do this.potential[i] = nil end
			for i,v in ipairs(this.potentialchar) do this.potentialchar[i] = nil end
			local combatstr = "combat-"..tostring(combat)
			local wrongcombatstr = "combat-"..tostring(not combat)
			local groupstr = "group-"..tostring(grouped)
			local wronggroupstr = "group-"..tostring(not grouped)
			local primarystr,wrongprimarystr,secondarystr,wrongsecondarystr
			if changed == "combat" then
				primarystr = combatstr
				wrongprimarystr = wrongcombatstr
				secondarystr = groupstr
				wrongsecondarystr = wronggroupstr
			else
				primarystr = groupstr
				wrongprimarystr = wronggroupstr
				secondarystr = combatstr
				wrongsecondarystr = wrongcombatstr
			end
			for _,profile in ipairs(ProfileLib:Get("profiles")) do
				if not profile.flags then profile.flags = {} end
				local flags = profile.flags
				if flags[primarystr] then
					if not flags[wrongsecondarystr] then
						if profile.onlychar then
							if profile.onlychar == id then table.insert(this.potentialchar,profile) end
						else
							table.insert(this.potential,profile)
						end
					end
				end
			end
			if table.getn(this.potentialchar) > 0 then
				for i,v in ipairs(this.potentialchar) do
					if v.flags[secondarystr] then
						ProfileLib:LoadProfile(v)
						return
					end
				end
				ProfileLib:LoadProfile(this.potentialchar[1])
				return
			end
			for i,v in ipairs(ProfileLib:Get("profiles")) do
				if v.flags["otherwise"] and v.onlychar and v.onlychar == id then
					ProfileLib:LoadProfile(v)
					return
				end
			end
			if table.getn(this.potential) > 0 then
				for i,v in ipairs(this.potential) do
					if v.flags[secondarystr] then
						ProfileLib:LoadProfile(v)
						return
					end
				end
				ProfileLib:LoadProfile(this.potential[1])
				return
			end
			for i,v in ipairs(ProfileLib:Get("profiles")) do
				if v.flags["otherwise"] and not v.onlychar then
					ProfileLib:LoadProfile(v)
					return
				end
			end
		end
	end
end)

AsheylaLib:CreateLibrary("ProfileLib",ProfileLib)
