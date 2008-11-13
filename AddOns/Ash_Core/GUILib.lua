local GUILib = {}
local menucounter = 0
local guimenus = {}

function GUILib:CreateGUI(guitable)
	local menu = self:MakeMenu(guitable)
	local menuname = menu:GetName()
	local point,relative,to,num1,num2 = "TOPLEFT",menuname,"TOPLEFT",10,-10
	local framecollection = {}
	local menuwidth,menumaxheight = 0,0
	for column,frames in ipairs(guitable) do
		local currcolumn = self:MakeMenuColumn(menu,menuname,column)
		local columnname = currcolumn:GetName()
		table.insert(framecollection,{})
		local height,maxwidth = 0,0
		local p,r,t = "TOPLEFT",columnname,"TOPLEFT"
		for index,value in ipairs(frames) do
			if value == "BREAK" then
				local num = table.getn(framecollection)
				framecollection[num].hasbreak = index - 1
			else
				if (value.title or value.largetitle) then value = {value} end
				local place = self:CreateMenuFrames(menu,value,columnname,index)
				height = height + place:GetHeight()
				maxwidth = math.max(maxwidth,place:GetWidth())
				table.insert(framecollection[table.getn(framecollection)],place)
				place:ClearAllPoints()
				place:SetPoint(p,r,t,0,0)
				p,r,t = "TOP",place:GetName(),"BOTTOM"
				place.column = currcolumn
			end
		end
		maxwidth = maxwidth + 30
		currcolumn:SetHeight(height)
		currcolumn:SetWidth(maxwidth)
		framecollection[table.getn(framecollection)].height = height
		menuwidth = menuwidth + maxwidth
		menumaxheight = math.max(menumaxheight,height)
		currcolumn:ClearAllPoints()
		currcolumn:SetPoint(point,relative,to,num1,num2)
		point,relative,to,num1,num2 = "TOPLEFT",columnname,"TOPRIGHT",0,0
		currcolumn.menu = menu
	end
	menu:SetWidth(menuwidth - 10)
	menu:SetHeight(menumaxheight + 20)
	menu:ClearAllPoints()
	menu:SetPoint("TOPLEFT","UIParent","TOPLEFT",200,-100)
	for index,value in pairs(framecollection) do
		local offset = (value.height - menumaxheight) / (table.getn(value) - 1)
		for i = 2,table.getn(value) do
			local newoffset = offset
			if value.hasbreak then
				if value.hasbreak == i - 1 then
					newoffset = value.height - menumaxheight
				else
					newoffset = 0
				end
			end
			local place = value[i]
			place:ClearAllPoints()
			place:SetPoint("TOPLEFT",value[i - 1]:GetName(),"BOTTOMLEFT",0,newoffset)
		end
	end
	return menu
end

function GUILib:CreateMenuFrame(menu,frametable,name,counter)
	local frametype = frametable.type
	local frame
	local holder = CreateFrame("Frame",name.."Holder"..counter,menu)
	local point
	if frametype == "button" then
		frame = CreateFrame("Button",(frametable.name or name.."Element"..counter),menu,"Ash_CoreButtonTemplate")
		if frametable.width then frame:SetWidth(frametable.width) end
		if frametable.height then frame:SetHeight(frametable.height) end
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		end
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		frame.holder = holder
		holder:SetWidth(frame:GetWidth())
		holder:SetHeight(frame:GetHeight() + (frametable.buffer or 0))
		point = "CENTER"
	elseif frametype == "checkbutton" then
		frame = CreateFrame("CheckButton",(frametable.name or name.."Element"..counter),menu,"Ash_CoreCheckButtonTemplate")
		if frametable.width then frame:SetWidth(frametable.width) end
		if frametable.height then frame:SetHeight(frametable.height) end
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		elseif frametable.largetitle then
			getglobal(frame:GetName().."LargeTitle"):SetText(frametable.largetitle)
		end
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		frame.holder = holder
		holder:SetWidth(frame:GetWidth() + getglobal(frame:GetName().."Title"):GetWidth())
		holder:SetHeight(frame:GetHeight() + (frametable.buffer or 0))
		point = "LEFT"
	elseif frametype == "slider" then
		frame = CreateFrame("Slider",(frametable.name or name.."Element"..counter),menu,"Ash_CoreSliderTemplate")
		if frametable.width then frame:SetWidth(frametable.width) end
		if frametable.height then frame:SetHeight(frametable.height) end
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		elseif frametable.largetitle then
			getglobal(frame:GetName().."LargeTitle"):SetText(frametable.largetitle)
		end
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		frame.holder = holder
		getglobal(frame:GetName().."Low"):SetText(frametable.lowval)
		getglobal(frame:GetName().."High"):SetText(frametable.highval)
		frame:SetMinMaxValues(frametable.lowval,frametable.highval)
		frame:SetValueStep(frametable.step)
		holder:SetWidth(frame:GetWidth())
		holder:SetHeight(frame:GetHeight() + getglobal(frame:GetName().."High"):GetHeight() + getglobal(frame:GetName().."Title"):GetHeight() + (frametable.buffer or 0))
		point = "CENTER"
	elseif frametype == "editbox" then
		frame = CreateFrame("EditBox",(frametable.name or name.."Element"..counter),menu,"Ash_CoreEditBoxTemplate")
		if frametable.width then frame:SetWidth(frametable.width) end
		if frametable.height then frame:SetHeight(frametable.height) end
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		frame.holder = holder
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		elseif frametable.largetitle then
			getglobal(frame:GetName().."LargeTitle"):SetText(frametable.largetitle)
		end
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		frame.holder = holder
		holder:SetWidth(frame:GetWidth())
		holder:SetHeight(frame:GetHeight() + getglobal(frame:GetName().."Title"):GetHeight() + (frametable.buffer or 0))
		point = "BOTTOM"
	elseif frametype == "dropdown" then
		frame = CreateFrame("Frame",(frametable.name or name.."Element"..counter),menu,"DropDownLibTemplate")
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		elseif frametable.largetitle then
			getglobal(frame:GetName().."LargeTitle"):SetText(frametable.largetitle)
		end
		frame.holder = holder
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		local width = frametable.width or 90
		DropDownLib:SetWidth(width,frame)
		DropDownLib:Initialize(frame,frametable.func)
		holder:SetWidth(frame:GetWidth() - 32)
		holder:SetHeight(frame:GetHeight() + getglobal(frame:GetName().."Title"):GetHeight() + (frametable.buffer or 0))
		point = "LEFT"
	elseif frametype == "colorselect" then
		frame = CreateFrame("CheckButton",(frametable.name or name.."Element"..counter),menu,"Ash_CoreColorSwatchTemplate")
		if frametable.width then frame:SetWidth(frametable.width) end
		if frametable.height then frame:SetHeight(frametable.height) end
		if frametable.scripts then
			for index,value in pairs(frametable.scripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.overridescripts then
			for index,value in pairs(frametable.overridescripts) do
				frame:SetScript(index,value)
			end
		end
		if frametable.title then
			getglobal(frame:GetName().."Title"):SetText(frametable.title)
		elseif frametable.largetitle then
			getglobal(frame:GetName().."LargeTitle"):SetText(frametable.largetitle)
		end
		frame.tooltipText = frametable.tooltiptext
		frame.self = self
		if frametable.data then
			for index,value in pairs(frametable.data) do frame[index] = value end
		end
		frame.holder = holder
		holder:SetWidth(frame:GetWidth() + getglobal(frame:GetName().."Title"):GetWidth() + 8)
		holder:SetHeight(frame:GetHeight() + (frametable.buffer or 0))
		point = "RIGHT"
	end
	frame:ClearAllPoints()
	frame:SetPoint(point,holder:GetName(),point)
	return holder
end

function GUILib:CreateMenuFrames(menu,frames,name,counter)
	local place = CreateFrame("Frame",name.."Place"..counter,menu)
	local placename = place:GetName()
	local maxwidth,maxheight = 0,0
	for index,frametable in ipairs(frames) do
		local holder = self:CreateMenuFrame(menu,frametable,placename,index)
		maxwidth = math.max(maxwidth,holder:GetWidth())
		maxheight = math.max(maxheight,holder:GetHeight())
		holder:ClearAllPoints()
		holder:SetPoint("TOPLEFT",placename,"TOPLEFT")
		holder.place = place
	end
	place:SetWidth(maxwidth)
	place:SetHeight(maxheight)
	return place
end

function GUILib:MakeMenuColumn(menu,name,counter)
	local column = CreateFrame("Frame",name.."Column"..counter,menu)
	return column
end

function GUILib:MakeMenu(guitable)
	menucounter = menucounter + 1
	local menuname = guitable.name or "AshCoreMenu"..menucounter
	local menu = CreateFrame("Frame",menuname,UIParent,"Ash_CoreMenuTemplate")
	getglobal(menu:GetName().."Title"):SetText(guitable.title)
	table.insert(guimenus,menu)
	if guitable.scripts then
		for index,value in pairs(guitable.scripts) do
			menu:SetScript(index,value)
		end
	end
	local oldfunc = menu:GetScript("OnShow") or function() end
	menu:SetScript("OnShow",function(self)
		oldfunc(self)
		for index,value in ipairs(guimenus) do
			if not (value == self) then value:Hide() end
		end
	end)
	return menu
end

AsheylaLib:CreateLibrary("GUILib",GUILib)
