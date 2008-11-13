local scripts = {
	checkbutton = {
		OnShow = function() this:SetChecked(this.self:Get(this.setting)) end,
		OnClick = function() this.self:Set(this.setting,this:GetChecked() and true or false); this.self:UpdateSettings() end,
	},
	slider = {
		OnShow = function() this.real = false this:SetValue(this.self:Get(this.setting)) this.real = true end,
		OnValueChanged = function()
			local value = this:GetValue()
			local formatstring
			if math.floor(value) == value then 
				formatstring = "%d"
			else
				formatstring = "%.2f"
			end
			getglobal(this:GetName().."Value"):SetText(string.format(formatstring,value))
			if this.real then
				this.self:Set(this.setting,value)
				this.self:UpdateSettings()
			end
		end,
	},
	editbox1 = { --initialized with a string
		OnEditFocusGained = function() this:SetText(this.self:Get(this.setting) or ""); this:HighlightText() end,
		OnEditFocusLost = function() this:HighlightText(0,0) end,
		OnShow = function() this:SetText(this.self:Get(this.setting) or "") end,
		OnEscapePressed = function()
			local text = this:GetText()
			if text == "" then
				this:ClearFocus()
			else
				this:SetText("")
			end
		end,
		OnEnterPressed = function() this.self:Set(this.setting,this:GetText()); this:ClearFocus() end,
	},
	editbox2 = { --left blank, OnEnterPressed and OnEnter will be defined elsewhere
		OnEditFocusGained = function() this:SetText("") end,
		OnEditFocusLost = function() this:SetText("") end,
		OnEscapePressed = function()
			local text = this:GetText()
			if text == "" then
				this:ClearFocus()
			else
				this:SetText("")
			end
		end,
	},
	editbox3 = { --controls a table
		OnEditFocusGained = function() this:SetText("") end,
		OnEditFocusLost = function() this:SetText("") end,
		OnEscapePressed = function()
			local text = this:GetText()
			if text == "" then
				this:ClearFocus()
			else
				this.self:Set(this.setting,string.lower(text),nil)
				this:SetText("")
			end
		end,
		OnEnterPressed = function()
			local text = this:GetText()
			if not (text == "") then
				this.self:Set(this.setting,string.lower(text),1)
				this:SetText("")
			end
		end,
		OnEnter = function()
			if this.tooltipText then
				local text = this.tooltipText
				for index,value in pairs(this.self:Get(this.setting)) do
					text = text.."\n"..index
				end
				GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
				GameTooltip:SetText(text, nil, nil, nil, nil, 1);
			end
		end,
	},
	dropdown = {
		OnShow = function()
			getglobal(this:GetName().."Text"):SetText(this.self:Get(this.setting))
		end,
	},
	dropdown2 = {
		OnShow = function()
			getglobal(this:GetName().."Text"):SetText(this.text)
		end,
	},
}

local function filldropdown(frame,setting,values)
	local info
	for index,value in ipairs(values) do
		info = DropDownLib:GetTable()
		info.text = value
		info.checked = (Cooldowns:Get(setting) == value) and 1
		info.func = function() 
			Cooldowns:Set(setting,value) 
			Cooldowns:UpdateSettings() 
			getglobal(frame:GetName().."Text"):SetText(value)
			DropDownLib:CloseDropDownMenus()
		end
		DropDownLib:AddButton(info,1)
	end
end

local sortingtable = {}
local function sorttable(pretable)
	for index,value in pairs(sortingtable) do sortingtable[index] = nil end
	for index,value in pairs(pretable) do table.insert(sortingtable,index) end
	table.sort(sortingtable)
	return sortingtable
end

local types = {
	["Cooldown"] = "cooldown",
}

local orderedtypes = {
	"Cooldown",
}

local category

local function colordropdown()
	local info
	local DROPDOWNLIB_MENU_LEVEL = DropDownLib:MenuLevel()
	local DROPDOWNLIB_MENU_VALUE = DropDownLib:MenuValue()
	if DROPDOWNLIB_MENU_LEVEL == 4 then
		local subcat = DROPDOWNLIB_MENU_VALUE
		for index,value in ipairs({"begin","half","final"}) do
			info = DropDownLib:GetTable()
			info.text = value
			info.notCheckable = 1
			info.hasColorSwatch = 1
			info.r = Cooldowns:Get("colors",category,subcat,value,"r") or 1
			info.g = Cooldowns:Get("colors",category,subcat,value,"g") or 1
			info.b = Cooldowns:Get("colors",category,subcat,value,"b") or 1
			info.swatchFunc = function()
				local r,g,b = DropDownLibColorPicker:GetColorRGB()
				Cooldowns:Set("colors",category,subcat,value,"r",r)
				Cooldowns:Set("colors",category,subcat,value,"g",g)
				Cooldowns:Set("colors",category,subcat,value,"b",b)
				for i,v in ipairs({"begin","half","final"}) do
					if not Cooldowns:Get("colors",category,subcat,v) then
						Cooldowns:Set("colors",category,subcat,v,"r",r)
						Cooldowns:Set("colors",category,subcat,v,"g",g)
						Cooldowns:Set("colors",category,subcat,v,"b",b)
					end
				end
				Cooldowns:UpdateSettings()
				DoTimer:UpdateSettings()
			end
			DropDownLib:AddButton(info,4)
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 3 then
		local entries = Cooldowns:AcquireTable()
		if string.sub(DROPDOWNLIB_MENU_VALUE,1,5) == "spell" then
			local tab = string.sub(DROPDOWNLIB_MENU_VALUE,6)
			for i = 1,GetNumSpellTabs() do
				local name,_,offset,numspells = GetSpellTabInfo(i)
				if name == tab then
					for id = offset + 1,offset + numspells do
						local spell = GetSpellName(id,BOOKTYPE_SPELL)
						entries[spell] = 1
					end
					break
				end
			end
		elseif string.sub(DROPDOWNLIB_MENU_VALUE,1,4) == "item" then
			local itemloc = string.sub(DROPDOWNLIB_MENU_VALUE,5)
			if itemloc == "Inventory" then
				for i = 1,19 do
					local name = GetItemInfo(GetInventoryItemLink("player",i) or "")
					if name then
						entries[name] = 1
					end
				end
			else
				local _,bagid
				if itemloc == "Backpack" then
					bagid = 0
				else
					_,_,bagid = string.find(itemloc,"(%d)")
				end
				for i = 1,GetContainerNumSlots(bagid) do
					local name = GetItemInfo(GetContainerItemLink(bagid,i) or "")
					if name then
						entries[name] = 1
					end	
				end
			end
		elseif string.sub(DROPDOWNLIB_MENU_VALUE,1,5) == "other" then
			entries["Global Cooldown"] = 1
			entries["Spell Locked"] = 1
		end
		entries = sorttable(entries)
		for index,value in ipairs(entries) do
			info = DropDownLib:GetTable()
			info.text = value
			local checked
			if Cooldowns:Get("colors","timer",value) then checked = 1 end
			info.checked = checked
			info.value = value
			info.hasArrow = 1
			info.func = function() 
				if checked then 
					Cooldowns:Set("colors","timer",value,nil) 
					Cooldowns:UpdateSettings()
					DoTimer:UpdateSettings()
				end 
			end
			DropDownLib:AddButton(info,3)
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 2 then
		category = DROPDOWNLIB_MENU_VALUE
		if category == "timer" then
			local nextentries = {"Inventory","Backpack","Bag 1","Bag 2","Bag 3","Bag 4","Other"}
			local nexttypes = {"item","item","item","item","item","item","other"}
			local counter = 1
			for i = 1,GetNumSpellTabs() do
				local name = GetSpellTabInfo(i)
				table.insert(nextentries,counter,name)
				table.insert(nexttypes,counter,"spell")
				counter = counter + 1
			end
			for index,value in ipairs(nextentries) do
				info = DropDownLib:GetTable()
				info.text = value
				info.value = nexttypes[index]..value
				info.hasArrow = 1
				info.notCheckable = 1
				DropDownLib:AddButton(info,2)
			end
		elseif category == "type" then
			local subcat = "cooldown"
			for index,value in ipairs({"begin","half","final"}) do
				info = DropDownLib:GetTable()
				info.text = value
				info.notCheckable = 1
				info.hasColorSwatch = 1
				info.r = Cooldowns:Get("colors",category,subcat,value,"r") or Cooldowns:GetTimerData()[subcat].colors[value]["r"]
				info.g = Cooldowns:Get("colors",category,subcat,value,"g") or Cooldowns:GetTimerData()[subcat].colors[value]["g"]
				info.b = Cooldowns:Get("colors",category,subcat,value,"b") or Cooldowns:GetTimerData()[subcat].colors[value]["b"]
				info.swatchFunc = function()
					local r,g,b = DropDownLibColorPicker:GetColorRGB()
					Cooldowns:Set("colors",category,subcat,value,"r",r)
					Cooldowns:Set("colors",category,subcat,value,"g",g)
					Cooldowns:Set("colors",category,subcat,value,"b",b)
					for i,v in ipairs({"begin","half","final"}) do
						if not Cooldowns:Get("colors",category,subcat,v) then
							Cooldowns:Set("colors",category,subcat,v,"r",Cooldowns:GetTimerData()[subcat].colors[v]["r"])
							Cooldowns:Set("colors",category,subcat,v,"g",Cooldowns:GetTimerData()[subcat].colors[v]["g"])
							Cooldowns:Set("colors",category,subcat,v,"b",Cooldowns:GetTimerData()[subcat].colors[v]["b"])
						end
					end
					Cooldowns:UpdateSettings()
					DoTimer:UpdateSettings()
				end
				DropDownLib:AddButton(info,2)
			end
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 1 then
		info = DropDownLib:GetTable()
		info.text = "Specific Timer"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "timer"
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "All Timers"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "type"
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Bar Text"
		local colors = Cooldowns:Get("bartextcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = Cooldowns:Get("bartextcolor")
		local defcolor = Cooldowns:GetDefault("bartextcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then Cooldowns:Set("bartextcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			Cooldowns:Set("bartextcolor","r",r)
			Cooldowns:Set("bartextcolor","g",g)
			Cooldowns:Set("bartextcolor","b",b)
			Cooldowns:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Ghost Timers"
		local colors = Cooldowns:Get("ghostcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = Cooldowns:Get("ghostcolor")
		local defcolor = Cooldowns:GetDefault("ghostcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then Cooldowns:Set("ghostcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			Cooldowns:Set("ghostcolor","r",r)
			Cooldowns:Set("ghostcolor","g",g)
			Cooldowns:Set("ghostcolor","b",b)
			Cooldowns:UpdateSettings()
			DoTimer:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Bar Background"
		local colors = Cooldowns:Get("barbackgroundcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = Cooldowns:Get("barbackgroundcolor")
		local defcolor = Cooldowns:GetDefault("barbackgroundcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then Cooldowns:Set("barbackgroundcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			Cooldowns:Set("barbackgroundcolor","r",r)
			Cooldowns:Set("barbackgroundcolor","g",g)
			Cooldowns:Set("barbackgroundcolor","b",b)
			Cooldowns:UpdateSettings()
			DoTimer:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
	end
end

local function otherdropdown()
	local frame = this:GetParent()
	if frame.setting and frame.values then 
		filldropdown(frame,frame.setting,frame.values) 
	end 
end

local guitable = {
	title = "Cooldowns Main Menu",
	name = "CooldownsMenuFrame",
	{ --column 1
		{
			title = "Enabled",
			type = "checkbutton",
			tooltiptext = "Turns the addon on or off, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "status",
			},
		},
		{
			title = "Locked",
			type = "checkbutton",
			tooltiptext = "Locks the addon, hiding the drag icon, default state: unlocked.",
			scripts = scripts.checkbutton,
			data = {
				setting = "locked",
			},
		},
		{
			title = "Header",
			type = "checkbutton",
			tooltiptext = "Toggles the showing of the 'Cooldowns' header, default state: shown.",
			scripts = scripts.checkbutton,
			data = {
				setting = "names",
			},
		},
		{
			title = "Clickable",
			type = "checkbutton",
			tooltiptext = "Determines if debuffs can be clicked: Leftclick to add to chat, rightclick to remove, shift+rightclick to remove and block, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "clickable",
			},
		},
		{
			title = "Show Tenths",
			type = "checkbutton",
			tooltiptext = "Determines if the displayed duration on timers is accurate to .1 second, else to 1 second, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "tenths",
			},
		},
		{
			title = "Tooltips",
			type = "checkbutton",
			tooltiptext = "Determines if tooltips will be shown when you mouse over timers, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "tooltips",
			},
		},
		{
			title = "Icons",
			type = "checkbutton",
			tooltiptext = "Determines if the icons in the bar format will be shown, default state: shown.",
			scripts = scripts.checkbutton,
			data = {
				setting = "icons",
			},
		},
		{
			title = "Reversed",
			type = "checkbutton",
			tooltiptext = "Determines if the timers in 'bar' format will grow instead of shrink, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "reversed",
			},
		},
		{
			title = "Expire Alert",
			type = "checkbutton",
			tooltiptext = "Determines if the timer icon (in icons format) highlights for 2 seconds at less than 5 seconds remaining, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "expalert",
			},
		},
		{
			title = "Play Sounds",
			type = "checkbutton",
			tooltiptext = "Determines if a sound will be played when a timer hits five seconds left, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "playsound",
			},
		},
		{
			title = "Ghost Timers",
			type = "checkbutton",
			tooltiptext = "Determines if ghost timers will be created or not.  Ghost timers are created when timers expire, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "ghosts",
			},
		},
		{
			title = "Hide All",
			type = "checkbutton",
			tooltiptext = "Determines if all timers will be hidden from view, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "hideall",
			},
		},
		{
			title = "Integrated",
			type = "checkbutton",
			tooltiptext = "Determines if the timers are integrated into DoTimer, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "dotimer",
			},
		},
	},
	{ --column 2
		{
			title = "Scale",
			type = "slider",
			tooltiptext = "Changes the relative size of the interface, default value: 1.",
			scripts = scripts.slider,
			lowval = .5,
			highval = 1.25,
			step = .05,
			data = {
				setting = "scale",
			},
		},
		{
			title = "Timer Scale",
			type = "slider",
			tooltiptext = "Changes the relative size of the debuff icons of the interface, default value: 1.",
			scripts = scripts.slider,
			lowval = .5,
			highval = 2,
			step = .05,
			data = {
				setting = "buttonscale",
			},
		},
		{
			title = "Bar Length",
			type = "slider",
			tooltiptext = "Determines how long the bar are in Bars format, or how much text is shown in Text format, default 175.",
			scripts = scripts.slider,
			lowval = 50,
			highval = 250,
			step = 5,
			data = {
				setting = "barlength",
			},
		},
		{
			title = "Timer Spacing",
			type = "slider",
			tooltiptext = "Determines how spaced out the timers are from each other, default 5.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 20,
			step = 1,
			data = {
				setting = "timerspacing",
			},
		},
		{
			title = "Alpha",
			type = "slider",
			tooltiptext = "Determines the overall alpha of the timers.  1 means fully opaque; 0 means completely translucent, default 1.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 1,
			step = .05,
			data = {
				setting = "alpha",
			},
		},
		{
			title = "Ghost Duration",
			type = "slider",
			tooltiptext = "Determines how long, in seconds, ghost timers will stay on the screen.  Set to '0' for deletion to be handled automatically by Cooldowns, default 5.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 10,
			step = 1,
			data = {
				setting = "ghostdata",
			},
		},
		{
			title = "Bar Texture",
			type = "slider",
			tooltiptext = "Determines the index of which bar texture will be used, default 4.",
			scripts = scripts.slider,
			lowval = 1,
			highval = 24,
			step = 1,
			data = {
				setting = "bartexture",
			},
		},
		{
			title = "Min Cooldown",
			type = "slider",
			tooltiptext = "Determines the minimum length of a cooldown, in seconds, for a timer to be made, default 2.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 10,
			step = 1,
			data = {
				setting = "mincd",
			},
		},
		{
			title = "Max Cooldown",
			type = "slider",
			tooltiptext = "Determines the maximum length of a cooldown, in hours, for a timer to be made (0 means no limit), default 1.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 12,
			step = 1,
			data = {
				setting = "maxcd",
			},
		},
		{
			title = "Fade In Time",
			type = "slider",
			tooltiptext = "Determines how long, in seconds, timers will take to fade in, default 1.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 5,
			step = 1,
			data = {
				setting = "fadeintime",
			},
		},
		{
			title = "Fade Out Time",
			type = "slider",
			tooltiptext = "Determines how long, in seconds, timers will take to fade out, default 3.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 5,
			step = 1,
			data = {
				setting = "fadeouttime",
			},
		},
	},
	{ --column 3
		{
			title = "Colors",
			type = "dropdown",
			tooltiptext = "Lets you set the color of specific timers, timer types, and the bar text.",
			func = colordropdown,
			scripts = scripts.dropdown2,
			data = {
				text = "Choose...",
			},
		},
		{
			title = "Timer Format",
			type = "dropdown",
			tooltiptext = "Determines if the timers will be displayed as bars, icons, or text, default bars.",
			width = 90,
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "format",
				values = {"bars","icons","text"},
			},
		},
		{
			title = "Timer Layout",
			type = "dropdown",
			tooltiptext = "Sets the direction in which new debuff timers are added, default value: down.",
			width = 90,
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "timerlayout",
				values = {"up","down","left","right"},
			},
		},
		{
			title = "Sorting Method",
			type = "dropdown",
			tooltiptext = "Sets the manner in which timers are sorted: time added or time remaining, and ascending or descending, default value: remaining (D).",
			width = 90,
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "sortmethod",
				values = {"added (A)","added (D)","remaining (A)","remaining (D)","alphabetical (A)","alphabetical (D)"},
			},
		},
		{
			title = "Seconds Format",
			type = "dropdown",
			tooltiptext = "Sets the manner in which the time string is displayed when less than 1 minute remains on the timer.",
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "secondsformat",
				values = {"##",":##","0:##"},
			},
		},
		{
			title = "Hidden Timers",
			type = "editbox",
			tooltiptext = "Allows timers to be hidden upon creation.  Press ENTER after typing in a name to add it to the list, or ESCAPE to remove it.  \n\nCurrent List:",
			scripts = scripts.editbox3,
			data = {
				setting = "hidden",
			},
		},
		{
			title = "Chat Msg",
			type = "editbox",
			tooltiptext = [[
				Allows you to customize the chat message sent when left-clicking a timer.

				Valid formatting codes:
				%s: spell name
				%d: time remaining
				%t: Soulstone's target

				Normal: %s,%d
				No Target: %s,%d,%t

				Prefix with one of [normal,soulstone] followed by a ":" to set the msg for that type.
				Press ENTER when finished typing.
				
				Current strings:]],
			scripts = scripts.editbox2,
			overridescripts = {
				OnEnterPressed = function() 
					local text = this:GetText()
					if not (text == "") then 
						local _,_,output,msg = string.find(text,"(%a+)%:%s?(.+)")
						if output then 
							output = string.lower(output)
							Cooldowns:Set("chatmsg"..output,msg)
							this:SetText("") 
						end
					end
				end,
				OnEnter = function() 
					if this.tooltipText then
						local text = this.tooltipText
						text = text.."\nNormal: "..Cooldowns:Get("chatmsgnormal")
						text = text.."\nSoulstone: "..Cooldowns:Get("chatmsgsoulstone")
						GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
						GameTooltip:SetText(text, nil, nil, nil, nil, 1);
					end
				end,
			},
		},
		{
			title = "Bar Msg",
			type = "editbox",
			tooltiptext = [[
				Allows you to customize the text inside the bar / shown in 'text only' format.
				
				Valid formatting codes:
				%s: spell name
				%d: time remaining
				
				Press ENTER when finished typing.]],
			scripts = scripts.editbox1,
			data = {
				setting = "barmsg",
			},
		},
	},
	{ --column 4
		{
			title = "Reset",
			type = "button",
			tooltiptext = "Resets all settings to their default value.",
			buffer = 10,
			scripts = {
				OnClick = function() 
					this.self:ClearSettings() 
					CooldownsMenuFrame:Hide()
					CooldownsMenuFrame:Show()
				end,
			},
		},
		{
			title = "Reset Position",
			type = "button",
			tooltiptext = "Resets the position of the drag icon to the middle of the screen.",
			buffer = 10,
			scripts = {
				OnClick = function() this.self:Set("offsetX",nil); this.self:UpdateSettings() end,
			},
		},
		{
			title = "Author Info",
			type = "button",
			tooltiptext = "Prints in the chat frame information about the current version and about the author.",
			buffer = 10,
			scripts = {
				OnClick = function() Cooldowns:Commands("help info") end,
			},
		},
		{
			title = "Show Preview",
			type = "button",
			tooltiptext = "Shows the interface for the current settings for 3 targets and 4 debuffs.",
			buffer = 10,
			scripts = {
				OnClick = function() this.self:ShowTimers(1,4) end,
			},
		},
		{
			title = "Hide Preview",
			type = "button",
			tooltiptext = "Hides the preview created from the above button, as well as any other timers.",
			buffer = 10,
			scripts = {
				OnClick = function() this.self:RemoveAllTimers() end,
			},
		},
		{
			title = "Profiles",
			type = "button",
			tooltiptext = "Opens the Profile Creator menu.",
			buffer = 10,
			scripts = {
				OnClick = function() ProfileLib:ShowGUI() end,
			},
		},
		"BREAK",
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

function Cooldowns:ShowGUI()
	if not CooldownsMenuFrame then
		Cooldowns:CreateGUI(guitable)
	end
	CooldownsMenuFrame:Show()
end
