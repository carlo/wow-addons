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
		info.checked = (DoTimer:Get(setting) == value) and 1
		info.func = function() 
			DoTimer:Set(setting,value) 
			DoTimer:UpdateSettings() 
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
	["Harmful"] = "debuff",
	["Helpful"] = "buff",
	["No Target"] = "notarget",
}

local orderedtypes = {
	"Harmful",
	"Helpful",
	"No Target",
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
			info.r = DoTimer:Get("colors",category,subcat,value,"r") or 1
			info.g = DoTimer:Get("colors",category,subcat,value,"g") or 1
			info.b = DoTimer:Get("colors",category,subcat,value,"b") or 1
			info.swatchFunc = function()
				local r,g,b = DropDownLibColorPicker:GetColorRGB()
				DoTimer:Set("colors",category,subcat,value,"r",r)
				DoTimer:Set("colors",category,subcat,value,"g",g)
				DoTimer:Set("colors",category,subcat,value,"b",b)
				for i,v in ipairs({"begin","half","final"}) do
					if not DoTimer:Get("colors",category,subcat,v) then
						DoTimer:Set("colors",category,subcat,v,"r",r)
						DoTimer:Set("colors",category,subcat,v,"g",g)
						DoTimer:Set("colors",category,subcat,v,"b",b)
					end
				end
				DoTimer:UpdateSettings()
			end
			DropDownLib:AddButton(info,4)
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 3 then
		if category == "timer" then
			local entries = DoTimer:AcquireTable()
			local tab = DROPDOWNLIB_MENU_VALUE
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
			entries = sorttable(entries)
			for index,value in ipairs(entries) do
				info = DropDownLib:GetTable()
				info.text = value
				local checked
				if DoTimer:Get("colors","timer",value) then checked = 1 end
				info.checked = checked
				info.value = value
				info.hasArrow = 1
				info.func = function() 
					if checked then 
						DoTimer:Set("colors","timer",value,nil) 
						DoTimer:UpdateSettings()
					end 
				end
				DropDownLib:AddButton(info,3)
			end
		elseif category == "type" then
			local subcat = DROPDOWNLIB_MENU_VALUE
			for index,value in ipairs({"begin","half","final"}) do
				info = DropDownLib:GetTable()
				info.text = value
				info.notCheckable = 1
				info.hasColorSwatch = 1
				info.r = DoTimer:Get("colors",category,subcat,value,"r") or DoTimer:GetTimerData()[subcat].colors[value]["r"]
				info.g = DoTimer:Get("colors",category,subcat,value,"g") or DoTimer:GetTimerData()[subcat].colors[value]["g"]
				info.b = DoTimer:Get("colors",category,subcat,value,"b") or DoTimer:GetTimerData()[subcat].colors[value]["b"]
				info.swatchFunc = function()
					local r,g,b = DropDownLibColorPicker:GetColorRGB()
					DoTimer:Set("colors",category,subcat,value,"r",r)
					DoTimer:Set("colors",category,subcat,value,"g",g)
					DoTimer:Set("colors",category,subcat,value,"b",b)
					for i,v in ipairs({"begin","half","final"}) do
						if not DoTimer:Get("colors",category,subcat,v) then
							DoTimer:Set("colors",category,subcat,v,"r",DoTimer:GetTimerData()[subcat].colors[v]["r"])
							DoTimer:Set("colors",category,subcat,v,"g",DoTimer:GetTimerData()[subcat].colors[v]["g"])
							DoTimer:Set("colors",category,subcat,v,"b",DoTimer:GetTimerData()[subcat].colors[v]["b"])
						end
					end
					DoTimer:UpdateSettings()
				end
				DropDownLib:AddButton(info,3)
			end
		end
	elseif DROPDOWNLIB_MENU_LEVEL == 2 then
		category = DROPDOWNLIB_MENU_VALUE
		if category == "timer" then
			for i = 1,GetNumSpellTabs() do
				local name = GetSpellTabInfo(i)
				info = DropDownLib:GetTable()
				info.text = name
				info.value = name
				info.hasArrow = 1
				info.notCheckable = 1
				DropDownLib:AddButton(info,2)
			end
		elseif category == "type" then
			for index,value in ipairs(orderedtypes) do
				info = DropDownLib:GetTable()
				info.text = value
				local timertype = types[value]
				local checked
				if DoTimer:Get("colors","type",timertype) then checked = 1 end
				info.checked = checked
				info.value = timertype
				info.hasArrow = 1
				info.func = function() 
					if checked then 
						DoTimer:Set("colors","type",timertype,nil) 
						DoTimer:UpdateSettings()
					end 
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
		info.text = "Timer Type"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "type"
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Bar Text"
		local colors = DoTimer:Get("bartextcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = DoTimer:Get("bartextcolor")
		local defcolor = DoTimer:GetDefault("bartextcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then DoTimer:Set("bartextcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			DoTimer:Set("bartextcolor","r",r)
			DoTimer:Set("bartextcolor","g",g)
			DoTimer:Set("bartextcolor","b",b)
			DoTimer:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Ghost Timers"
		local colors = DoTimer:Get("ghostcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = DoTimer:Get("ghostcolor")
		local defcolor = DoTimer:GetDefault("ghostcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then DoTimer:Set("ghostcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			DoTimer:Set("ghostcolor","r",r)
			DoTimer:Set("ghostcolor","g",g)
			DoTimer:Set("ghostcolor","b",b)
			DoTimer:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
		info = DropDownLib:GetTable()
		info.text = "Bar Background"
		local colors = DoTimer:Get("barbackgroundcolor")
		info.r = colors.r
		info.g = colors.g
		info.b = colors.b
		info.hasColorSwatch = 1
		local checked
		local currcolor = DoTimer:Get("barbackgroundcolor")
		local defcolor = DoTimer:GetDefault("barbackgroundcolor")
		if not (currcolor.r == defcolor.r and currcolor.g == defcolor.g and currcolor.b == defcolor.b) then checked = 1 end
		info.checked = checked
		info.func = function() if checked then DoTimer:Set("barbackgroundcolor",nil) end end
		info.swatchFunc = function()
			local r,g,b = DropDownLibColorPicker:GetColorRGB()
			DoTimer:Set("barbackgroundcolor","r",r)
			DoTimer:Set("barbackgroundcolor","g",g)
			DoTimer:Set("barbackgroundcolor","b",b)
			DoTimer:UpdateSettings()
		end
		DropDownLib:AddButton(info,1)
	end
end

local function hiddentypesdropdown()
	local info
	for index,value in ipairs(orderedtypes) do
		info = DropDownLib:GetTable()
		local type = string.lower(types[value])
		local checked
		if DoTimer:Get("hiddentypes",type) then checked = 1 end
		info.checked = checked
		info.text = value
		info.func = function() if checked then DoTimer:Set("hiddentypes",type,nil) else DoTimer:Set("hiddentypes",type,1) end DoTimer:UpdateSettings() end
		DropDownLib:AddButton(info,1)
	end
end

local function otherdropdown()
	local frame = this:GetParent()
	if frame and frame.setting and frame.values then 
		filldropdown(frame,frame.setting,frame.values) 
	end 
end

local guitable = {
	title = "DoTimer Main Menu",
	name = "DoTimerMenuFrame",
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
			title = "Names",
			type = "checkbutton",
			tooltiptext = "Toggles the showing of target names, default state: shown.",
			scripts = scripts.checkbutton,
			data = {
				setting = "names",
			},
		},
		{
			title = "Raid Icons",
			type = "checkbutton",
			tooltiptext = "Determines if raid icons will be overlayed over target names.  Note that 'Names' can be turned off to only have raid icons shown, default state: on.",
			scripts = scripts.checkbutton,
			data = {
				setting = "raidicons",
			},
		},
		{
			title = "Levels",
			type = "checkbutton",
			tooltiptext = "Determines if the level of the target will be displayed, default state: shown.",
			scripts = scripts.checkbutton,
			data = {
				setting = "levels",
			},
		},
		{
			title = "Show Only Target",
			type = "checkbutton",
			tooltiptext = "Determines if only timers for your current target will be shown (the others will be tracked, but hidden), default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "onlytarget",
			},
		},
		{
			title = "Sort Target",
			type = "checkbutton",
			tooltiptext = "Determines if the table for the current target will be automatically sorted to the first position, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "sorttarget",
			},
		},
		{
			title = "Show Only Focus",
			type = "checkbutton",
			tooltiptext = "Determines if only timers for your current focus will be shown (the others will be tracked, but hidden).  Note that this and 'Show Only Target' can be used together, with the latter being sorted first, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "onlyfocus",
			},
		},
		{
			title = "Sort Focus",
			type = "checkbutton",
			tooltiptext = "Determines if the table for the current target will be automatically sorted to the first position.  Note that this and 'Sort Target' can be used together, with the latter being sorted first, default state: off.",
			scripts = scripts.checkbutton,
			data = {
				setting = "sortfocus",
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
			title = "On Yourself",
			type = "checkbutton",
			tooltiptext = "Determines if timers representing buffs on yourself will be created, default state: no.",
			scripts = scripts.checkbutton,
			data = {
				setting = "playertimers",
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
			title = "Target Spacing",
			type = "slider",
			tooltiptext = "Determines how spaced out the targets are from each other, default 15.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 30,
			step = 1,
			data = {
				setting = "targetspacing",
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
			tooltiptext = "Determines how long, in seconds, ghost timers will stay on the screen, default 5.",
			scripts = scripts.slider,
			lowval = 1,
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
		{
			title = "Max Buff Duration",
			type = "slider",
			tooltiptext = "Determines the maximum duration, in minutes, buffs you cast can last to be made a timer (0 means no limit), default 1.",
			scripts = scripts.slider,
			lowval = 0,
			highval = 15,
			step = 1,
			data = {
				setting = "maxbuffduration",
			},
		},
	},
	{ --column 3
		{
			title = "Colors",
			type = "dropdown",
			tooltiptext = "Lets you set the color of specific timers, timer types, ghost timers, and the bar text.",
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
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "format",
				values = {"bars","icons","text"},
			},
		},
		{
			title = "Target Layout",
			type = "dropdown",
			tooltiptext = "Sets the direction in which new target tables are added, default value: left.",
			func = otherdropdown,
			scripts = scripts.dropdown,
			data = {
				setting = "targetlayout",
				values = {"up","down","left","right"},
			},
		},
		{
			title = "Timer Layout",
			type = "dropdown",
			tooltiptext = "Sets the direction in which new debuff timers are added, default value: down.",
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
			tooltiptext = "Sets the manner in which debuffs are sorted: time added or time remaining, and ascending or descending, default value: remaining (D).",
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
			title = "Hidden Types",
			type = "dropdown",
			tooltiptext = "Lets you hide entire timer types from appearing onscreen.",
			func = hiddentypesdropdown,
			scripts = scripts.dropdown2,
			data = {
				text = "Choose...",
			},
		},
		{
			title = "Debugging",
			type = "editbox",
			tooltiptext = "Sets debug messages.  \"off\" for none, \"on\" for default frame, or a number representing the chat frame to send the messages.  Press ENTER when done typing.",
			scripts = scripts.editbox1,
			data = {
				setting = "debugchannel",
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
				%r: spell rank
				%d: time remaining
				%t: spell's target
				%l: target's level

				Normal: %s,%r,%d,%t,%l
				No Target: %s,%r,%d

				Prefix with one of [normal,notarget] followed by a ":" to set the msg for that type.
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
							DoTimer:Set("chatmsg"..output,msg)
							this:SetText("") 
						end
					end
				end,
				OnEnter = function() 
					if this.tooltipText then
						local text = this.tooltipText
						text = text.."\nNormal: "..DoTimer:Get("chatmsgnormal")
						text = text.."\nNo Target: "..DoTimer:Get("chatmsgnotarget")
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
				%r: spell rank
				%d: time remaining
				%t: spell's target
				%l: target's level
				
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
					DoTimerMenuFrame:Hide()
					DoTimerMenuFrame:Show()
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
				OnClick = function() DoTimer:Commands("help info") end,
			},
		},
		{
			title = "Beginners",
			type = "button",
			tooltiptext = "Prints in the chat frame basic info about the mod, for beginners.",
			buffer = 10,
			scripts = {
				OnClick = function() DoTimer:Commands("help new") end,
			},
		},
		{
			title = "Show Preview",
			type = "button",
			tooltiptext = "Shows the interface for the current settings for 3 targets and 4 debuffs.",
			buffer = 10,
			scripts = {
				OnClick = function() this.self:ShowTimers(3,4) end,
			},
		},
		{
			title = "Hide Preview",
			type = "button",
			tooltiptext = "Hides the preview created from the above button, as well as any other timers.  Beware.",
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

function DoTimer:ShowGUI()
	if not DoTimerMenuFrame then
		DoTimer:CreateGUI(guitable)
	end
	DoTimerMenuFrame:Show()
end
