local TimerLib = {}
local defaultsettings
local defaulttimerdata
local defaulttarget
local defaulttimer
local defaultghostdata
local defaulthiddendata
local defaultblankdata
local listofmodules = {}
local timerdatametatable
local timermetatable
local targetmetatable
local bartextures
local timertypes
local counter = 1

function TimerLib:CreateTimerInstance(targetframe,timerframe,anchorframe,positionframe)
	table.insert(listofmodules,self)
	local frame = CreateFrame("Frame")
	targetframe = targetframe or "TimerLibInstance"..counter.."Target"
	positionframe = positionframe or "TimerLibPositionFrame"..counter
	timerframe = timerframe or "Timer"
	anchorframe = anchorframe or "TimerLibAnchorFrame"..counter
	positionframe = positionframe or "TimerLibPositionFrame"..counter
	self.libraries["TimerLib"].frame = frame
	self.libraries["TimerLib"].datatable = {}
	self.libraries["TimerLib"].targetframe = targetframe
	self.libraries["TimerLib"].timerframe = timerframe
	self.libraries["TimerLib"].timerdata = self.libraries["TimerLib"].timerdata or {}
	self.libraries["TimerLib"].anchorframe = anchorframe
	self.libraries["TimerLib"].positionframe = positionframe
	self.libraries["TimerLib"].totaltargets = 0
	self.libraries["TimerLib"].totaltimers = 0
	self.libraries["TimerLib"].updatefunc = function(frame,elapsed) self:UpdateTimers(elapsed) end
	counter = counter + 1
	self:RegisterSettings()
	self:AddDefaultSettings(defaultsettings)
	setmetatable(self.libraries["TimerLib"].timerdata,timerdatametatable)
	--make the position frame
	local position = CreateFrame("Button",positionframe,UIParent,"TimerLibPositionFrameTemplate")
	--make the anchorframe
	position.self = self
	local anchor = CreateFrame("Frame",anchorframe,UIParent,"TimerLibAnchorFrameTemplate")
	anchor:ClearAllPoints()
	anchor:SetPoint("CENTER",positionframe,"CENTER")
	anchor.self = self
	self:CreateFrames(1,1)
	self:AddSettingsUpdateScript(self.UpdateInterface)
	self:UpdateInterface()
end

function TimerLib:UpdateInterface()
	--expects:
	-- .locked
	-- .status
	-- .scale
	local anchor = getglobal(self.libraries["TimerLib"].anchorframe)
	local position = getglobal(self.libraries["TimerLib"].positionframe)
	if self:Get("locked") then position:Hide() else position:Show() end
	if self:Get("status") then 
		anchor:Show() 
	else 
		anchor:Hide() 
		position:Hide() 
		self:RemoveAllTimers()
	end
	anchor:SetScale(self:Get("scale"))
	position:ClearAllPoints()
	if self:Get("offsetX") then
		position:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT",self:Get("offsetX"),self:Get("offsetY"))
	else
		position:SetPoint("CENTER","UIParent","CENTER",math.random(0,5),math.random(0,5))
	end
	self:DefineFormat()
	self:DefineInterface()
	local hideall = self:Get("hideall")
	for i = 1,self:GetNumTargets() do
		for id = 1,self:GetNumTimers(i) do
			local timer = self:GetTimer(i,id)
			if (not (timer.type == "hidden")) and (hideall or timer.module:Get("hidden",string.lower(timer.spell)) or (timer.module:Get("hiddentypes",string.lower(timer.type)))) then
				if timer.module:TimerIsReal(timer) then
					timer.origtype = timer.type
					timer.type = "hidden"
				else
					self:RemoveTimer(i,id,"hidden",1)
				end
			elseif (timer.type == "hidden") and (not hideall) and (not timer.module:Get("hidden",string.lower(timer.spell))) and (not timer.module:Get("hiddentypes",string.lower(timer.origtype))) then
				timer.type = timer.origtype
			end
		end
	end
	self:CreateInterface(1,1)
end

function TimerLib:AddTarget(t,nocheck,module)
	if self.libraries["TimerLib"].frozen then return end
	if self:Get("status") then
		t = t or {}
		t.module = module or self
		t.time = GetTime()
		t.text = t.text or t.target
		setmetatable(t,targetmetatable)
		local timers
		if table.getn(t) > 0 then
			timers = self:AcquireTable()
			for id = 1,table.getn(t) do table.insert(timers,table.remove(t,1)) end
		end
		local i = self:ReturnTargetTable(t.target,t.level,t.sex,t.module)
		if nocheck then i = nil end
		local casted = self.libraries["TimerLib"].datatable
		if not i then
			table.insert(casted,t) 
			i = table.getn(casted)
		end
		if timers then
			local target = self:GetTarget(i)
			for id = 1,table.getn(timers) do
				local timer = table.remove(timers,1)
				if type(timer) == "table" then
					self:AddTimer(i,timer,1)
				end
			end
			self:ReleaseTable(timers)
		end
		for k,v in pairs(t) do casted[i][k] = v end
		return i
	end
end

function TimerLib:AddTimer(target,d,suppress,module,targetmodule)
	if self.libraries["TimerLib"].frozen then return end
	if self:Get("status") then
		target = target or {}
		d = d or {}
		setmetatable(d,timermetatable)
		d.time = d.time or GetTime()
		d.english = d.english or d.spell
		d.module = d.module or module or self
		d.self = d.self or self
		d.timeadded = d.timeadded or GetTime()
		if self:Get("hideall") then
			if d.module:TimerIsReal(d) then 
				d.origtype = d.type
				d.type = "hidden" 
			else 
				return 
			end
		else
			if (d.module:Get("hidden",string.lower(d.spell)) and d.module:TimerIsReal(d)) or (d.module:Get("hiddentypes",string.lower(d.type))) then 
				d.origtype = d.type
				d.type = "hidden"
			end
		end
		local i
		local casted = self.libraries["TimerLib"].datatable
		if type(target) == "number" then
			i = target
		elseif type(target) == "table" then
			i = self:AddTarget(target,nil,targetmodule)
		end
		if i and casted[i] then
			for id = table.getn(casted[i]),1,-1 do
				local timer = casted[i][id]
				if timer.module == d.module and timer.spell == d.spell and ((timer.time + timer.duration <= GetTime()) or casted[i].norepeat) then self:RemoveTimer(i,id,"replaced",1,1) end
			end
			table.insert(casted[i],d)
			if not suppress then self:CreateInterface() end
		end
	end
end

function TimerLib:GetTimerData()
	return self.libraries["TimerLib"].timerdata
end

function TimerLib:GetTarget(i)
	return self.libraries["TimerLib"].datatable[i]
end

function TimerLib:GetTimer(i,id)
	return self.libraries["TimerLib"].datatable[i][id]
end

function TimerLib:CreateFrames(targets,timers)
	targets = math.max(targets,self.libraries["TimerLib"].totaltargets)
	timers = math.max(timers,self.libraries["TimerLib"].totaltargets)
	local changed
	local anchor = getglobal(self.libraries["TimerLib"].anchorframe)
	local targetframe = self.libraries["TimerLib"].targetframe
	local timerframe = self.libraries["TimerLib"].timerframe
	for i = self.libraries["TimerLib"].totaltargets + 1,targets do
		--make the targets
		changed = 1
		local target = CreateFrame("Frame",targetframe..i,anchor,"TimerLibTargetFrameTemplate")
		--set IDs
		target:SetID(i)
		target:Hide()
		getglobal(targetframe..i.."Name").self = self
		for id = 1,self.libraries["TimerLib"].totaltimers do
			--make the timers
			local timer = CreateFrame("Frame",targetframe..i..timerframe..id,target,"TimerLibTimerFrameTemplate")
			--set IDs
			timer:SetID(id)
			timer:Hide()
			getglobal(targetframe..i..timerframe..id.."BarButton").self = self
			getglobal(targetframe..i..timerframe..id.."IconButton").self = self
			getglobal(targetframe..i..timerframe..id.."TextButton").self = self
		end
	end
	for i = 1,targets do
		local target = getglobal(targetframe..i)
		for id = self.libraries["TimerLib"].totaltimers + 1,timers do
			changed = 1
			--make the timers
			local timer = CreateFrame("Frame",targetframe..i..timerframe..id,target,"TimerLibTimerFrameTemplate")
			--set IDs
			timer:SetID(id)
			timer:Hide()
			getglobal(targetframe..i..timerframe..id.."BarButton").self = self
			getglobal(targetframe..i..timerframe..id.."IconButton").self = self
			getglobal(targetframe..i..timerframe..id.."TextButton").self = self
		end
	end
	if changed then 
		self.libraries["TimerLib"].totaltargets = targets
		self.libraries["TimerLib"].totaltimers = timers
		self:DefineInterface(1)
		self:DefineFormat(1)
	end
	return self.libraries["TimerLib"].totaltargets,self.libraries["TimerLib"].totaltimers
end

function TimerLib:OnTimerEvent(event,i,id,...)
	if i and id then
		local casted = self.libraries["TimerLib"].datatable
		if casted[i] and casted[i][id] then
			local module = casted[i][id].module
			AsheylaLib:CallScript(module,event,i,id,self,...)
		end
	elseif i then
		local casted = self.libraries["TimerLib"].datatable
		if casted[i] then
			local module = casted[i].module
			AsheylaLib:CallScript(module,event,i,self,...)
		end	
	else
		AsheylaLib:CallScript(self,event,...)
	end
end

function TimerLib:CreateInterface(redraw,external) --defines the major portion of writing to the screen; it is called when something drastic has to happen to the interface (i.e., not just updating a timer)
	--expects:
	-- .onlytarget
	-- .names
	-- .raidicons
	-- .format
	-- .maxtarget
	-- .expalert
	-- .alpha
	-- .buttonscale
	-- .clickable
	if self.libraries["TimerLib"].frozen then return end
	self:Debug("redoing interface")
	for i = table.getn(self.libraries["TimerLib"].datatable),1,-1 do
		if table.getn(self.libraries["TimerLib"].datatable[i]) == 0 then self:RemoveTarget(i,1) end
	end
	self:SortTimers()
	local timerlib = self.libraries["TimerLib"]
	local datatable = timerlib.datatable
	local time = GetTime()
	if table.getn(datatable) == 0 then timerlib.frame:SetScript("OnUpdate",nil) end 
	if table.getn(datatable) >= 1 then timerlib.frame:SetScript("OnUpdate",timerlib.updatefunc) end --restoring that OnUpdate
	local targetindex = self:ReturnUnitTargetTable("target")
	local focusindex = self:ReturnUnitTargetTable("focus")
	local maxtargets = table.getn(datatable)
	local maxtimers = 0
	for index,value in ipairs(datatable) do
		local query = table.getn(value)
		if query > maxtimers then maxtimers = query end
	end	
	self:CreateFrames(maxtargets,maxtimers)
	datatable.numshown = maxtargets
	local onlytarget = self:Get("onlytarget")
	local onlyfocus = self:Get("onlyfocus")
	local names = self:Get("names")
	local raidicons = self:Get("raidicons")
	local timerformat = self:Get("format")
	local alpha = self:Get("alpha")
	local clickable = self:Get("clickable")
	local reversed = self:Get("reversed")
	local buttonscale = self:Get("buttonscale")
	local expalert = self:Get("expalert")
	local barmsg = self:Get("barmsg")
	local timerlayout = self:Get("timerlayout")
	for i = 1,maxtargets do --displaying the information onscreen for each target
		if ((not onlytarget) or (i == (targetindex or ((not UnitExists("target")) and i or 0)))) or ((not onlyfocus) or (i == (focusindex or ((not UnitExists("focus")) and i or 0)))) then
			local targettable = datatable[i]
			local targetframename = timerlib.targetframe..i
			getglobal(targetframename):Show()
			getglobal(targetframename.."Name").target = targettable.text
			targettable.frame = getglobal(targetframename)
			if names or raidicons then --set the target name if you have them on, else hide it
				local flag
				getglobal(targetframename.."Name"):Show()
				if names then
					getglobal(targetframename.."NameText"):SetText(targettable.text)
				else
					getglobal(targetframename.."NameText"):SetText("")
				end
				if targettable.icon > 0 and raidicons then
					getglobal(targetframename.."NameIcon"):Show()
					SetRaidTargetIconTexture(getglobal(targetframename.."NameIcon"),targettable.icon)
				else
					flag = true
					getglobal(targetframename.."NameIcon"):Hide()
				end
				if names then
					getglobal(targetframename.."Name"):SetHeight(getglobal(targetframename.."NameText"):GetHeight())
					getglobal(targetframename.."Name"):SetWidth(getglobal(targetframename.."NameText"):GetWidth())
				else
					if flag then
						getglobal(targetframename.."Name"):SetHeight(1)
						getglobal(targetframename.."Name"):SetWidth(1)
					else
						getglobal(targetframename.."Name"):SetHeight(getglobal(targetframename.."NameIcon"):GetHeight())
						getglobal(targetframename.."Name"):SetWidth(getglobal(targetframename.."NameIcon"):GetWidth())
					end
				end
			else
				getglobal(targetframename.."Name"):Hide()
			end
			local totaldebuffs = table.getn(targettable)
			targettable.numshown = totaldebuffs
			targettable.numvisible = nil
			for id = 1,totaldebuffs do --for each timer on the target
				local timerframename = targetframename..timerlib.timerframe..id
				local timerframe = getglobal(timerframename)
				local timer = targettable[id]
				local timerdata = timer.module.libraries["TimerLib"].timerdata[timer.type]
				if timer.type == "hidden" and not targettable.numvisible then targettable.numvisible = id - 1 end
				if redraw or not (timerframe.data and timerframe.data == timer) then
					timerframe.data = timer
					timer.frame = timerframe
					timerframe:Show()
					timerframe:SetAlpha(timer.alpha or 1)
					local type = timer.type
					local remaining = timer.duration - time + timer.time
					if timerformat == "icons" then
						getglobal(timerframename.."IconButton"):UnlockHighlight()
						getglobal(timerframename.."IconButtonTexture"):SetTexture(timer.texture) --setting the icon
						if timerdata.disptimer then
							local text = self:ReturnFormattedDuration(remaining)
							if remaining <= 0 then text = "" end
							getglobal(timerframename.."IconTime"):SetText(text)
							local displayed = timer.displayed
							if (displayed and displayed <= 5 and displayed > 3) and expalert then getglobal(timerframename.."IconButton"):LockHighlight() end
						else
							getglobal(timerframename.."IconTime"):SetText(timer.spell)
						end	
						local r,g,b = timer.module:GetTimerColor(timer)
						getglobal(timerframename.."IconTime"):SetTextColor(r,g,b)
						getglobal(timerframename.."IconButton"):SetScale(buttonscale * timerdata.scale)
						getglobal(timerframename.."IconButton"):SetAlpha(alpha * timerdata.alpha)
						if timerdata.total then 
							getglobal(timerframename.."IconTime"):SetAlpha(timerdata.alpha) 
						else
							getglobal(timerframename.."IconTime"):SetAlpha(1) 
						end
						getglobal(timerframename.."IconButton"):EnableMouse(clickable and timerdata.clickable)
						local timerwidth,timerheight
						if timerlayout == "left" or timerlayout == "right" then
							timerwidth = math.max(24 * buttonscale * timerdata.scale,getglobal(timerframename.."IconTime"):GetWidth())
							timerheight = timerwidth + 5 + getglobal(timerframename.."IconTime"):GetHeight()
						else
							timerheight = math.max(24 * buttonscale * timerdata.scale,getglobal(timerframename.."IconTime"):GetHeight())
							timerwidth = timerheight + 5 + getglobal(timerframename.."IconTime"):GetWidth()
						end
						getglobal(timerframename.."Icon"):SetWidth(timerwidth)
						getglobal(timerframename.."Icon"):SetHeight(timerheight)
					elseif timerformat == "bars" then
						getglobal(timerframename.."BarButtonTexture"):SetTexture(timer.texture) --setting the icon
						if timerdata.disptimer then
							local value = (timer.duration - time + timer.time) / timer.duration
							local text = self:FormatBarText(i,id)
							getglobal(timerframename.."BarStatusSpark"):Show()
							if reversed then value = 1 - value end
							if remaining <= 0 then 
								value = 1
								text = string.find(barmsg,"%s") and timer.spell or ""
								getglobal(timerframename.."BarStatusSpark"):Hide()
							end
							getglobal(timerframename.."BarStatus"):SetValue(value)
							getglobal(timerframename.."BarStatusTime"):SetText(text) 							
						else
							getglobal(timerframename.."BarStatus"):SetValue(1)
							getglobal(timerframename.."BarStatusTime"):SetText(timer.spell)
						end
						local r,g,b = timer.module:GetTimerColor(timer)
						getglobal(timerframename.."BarStatus"):SetStatusBarColor(r,g,b)
						getglobal(timerframename.."BarStatus"):SetAlpha(alpha * timerdata.alpha)
						timerframe:SetScale(buttonscale * timerdata.scale)
						if timerdata.total then 
							getglobal(timerframename.."BarButton"):SetAlpha(alpha * timerdata.alpha) 
						else
							getglobal(timerframename.."BarButton"):SetAlpha(alpha) 
						end						
						getglobal(timerframename.."BarBackground"):SetAlpha(alpha * timerdata.alpha / 2)
						getglobal(timerframename.."BarButton"):EnableMouse(clickable and timerdata.clickable)
					elseif timerformat == "text" then
						if timerdata.disptimer then
							local text = self:FormatBarText(i,id)
							if remaining <= 0 then text = string.find(barmsg,"%s") and timer.spell or "" end
							getglobal(timerframename.."TextButtonTime"):SetText(text)
						else
							getglobal(timerframename.."TextButtonTime"):SetText(timer.spell)
						end	
						local r,g,b = timer.module:GetTimerColor(timer)
						getglobal(timerframename.."TextButtonTime"):SetTextColor(r,g,b)	
						timerframe:SetScale(buttonscale * timerdata.scale)
						getglobal(timerframename.."TextButton"):SetAlpha(alpha * timerdata.alpha)
						getglobal(timerframename.."TextButton"):EnableMouse(clickable and timerdata.clickable)
					end
				end
			end
			if not targettable.numvisible then targettable.numvisible = totaldebuffs end
		end
	end
	for i = 1,timerlib.totaltargets do
		if 
			(i > (datatable.numshown or 0))
		or 
			(onlytarget and not (i == (targetindex or ((not UnitExists("target")) and i or 0)))) 
		or
			(onlyfocus and not (i == (focusindex or ((not UnitExists("focus")) and i or 0)))) 
		or 
			(datatable[i][1] and datatable[i][1].type == "hidden")
		then
			if datatable[i] then datatable[i].numshown = 0 end
			getglobal(timerlib.targetframe..i):Hide() --hiding unused targets
			for id = 1,timerlib.totaltimers do
				getglobal(timerlib.targetframe..i..timerlib.timerframe..id).data = nil
			end
		else
			for id = (datatable[i].numshown or 0) + 1,timerlib.totaltimers do
				local timerframe = getglobal(timerlib.targetframe..i..timerlib.timerframe..id)
				timerframe:Hide() --hiding unused timers in used targets
				timerframe.data = nil
			end
		end
	end
	self:ResizeInterface()
end

function TimerLib:SortTimers()
	local casted = self.libraries["TimerLib"].datatable
	local time = GetTime()
	local method,letter = self:ParseString(self:Get("sortmethod"),"(%a+) %((%a)%)")
	for i = 1,table.getn(casted) do
		table.sort(casted[i],function(a,b)
			if (a.type == b.type) then
				local val1 = ((method == "remaining" and (a.duration - time + a.time)) or (method == "added" and (a.time)) or (method == "alphabetical" and (a.spell)))
				local val2 = ((method == "remaining" and (b.duration - time + b.time)) or (method == "added" and (b.time)) or (method == "alphabetical" and (b.spell)))
				if letter == "A" then
					return (val1 < val2)
				elseif letter == "D" then
					return (val1 > val2)
				end	
			else
				if a.type == "hidden" then
					return false
				elseif b.type == "hidden" then
					return true
				else 
					local index1 = self:ReturnTimerdataIndex(a.type)
					local index2 = self:ReturnTimerdataIndex(b.type)
					if index1 == index2 then
						return (a.type < b.type)
					else
						return (index1 < index2) 
					end
				end
			end
		end)
	end
	table.sort(casted,function(a,b)
		local isfirsthidden = (a[1] and a[1].type == "hidden")
		local issecondhidden = (b[1] and b[1].type == "hidden")
		if (isfirsthidden == issecondhidden) then
			local real1 = not a.external
			local real2 = not b.external
			if (real1 and real2) then
				return (a.time < b.time)
			elseif (not real1) and (not real2) then
				local priority1 = a.priority and true or false
				local priority2 = b.priority and true or false
				if priority1 == priority2 then
					return (a.text < b.text)
				else
					return priority1
				end
			else
				return real1
			end
		else
			return issecondhidden
		end
	end)
	if (self:Get("onlyfocus") or self:Get("sortfocus")) and UnitExists("focus") then	
		local targetindex = self:ReturnUnitTargetTable("focus")
		if targetindex then
			local entry = casted[targetindex]
			table.remove(casted,targetindex)
			table.insert(casted,1,entry)
		end
	end
	if (self:Get("onlytarget") or self:Get("sorttarget")) and UnitExists("target") then	
		local targetindex = self:ReturnUnitTargetTable("target")
		if targetindex then
			local entry = casted[targetindex]
			table.remove(casted,targetindex)
			table.insert(casted,1,entry)
		end
	end
end

function TimerLib:ReturnTimerdataIndex(entry)
	for index,value in ipairs(self.libraries["TimerLib"].timerdata) do if value == entry then return index end end
	return table.getn(self.libraries["TimerLib"].timerdata) + 1
end

function TimerLib:ReturnAnchors()
	local targetsetup = self:Get("targetlayout")
	local timersetup = self:Get("timerlayout")
	local ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10
	local num1,num2,num3,num4,num5,num6,num7,num8,num9,num10
	--ref1/2: name string to target frame: the name is anchored by (1) to the target's (2)
	--ref3/4: time string to timer texture: the timer is anchored by (3) to the texture's (4)
	--ref5/6 the anchor corner/its opposite: the 1st target is anchored by (5) to the drag icon's (6)
	--ref7: corner for the other targets: the next target is anchored by (5) to the current's (7)
	--ref8/9: anchors for the timers: the next timer is anchored by its (9) to the previous's (8) (reversed order than usual)
	--num1/2: dist. between name string and target: you go left (1) and up (2) to go from target to name
	--num3/4: dist. between time string and texture: you go left (3) and up (4) to go from texture to timer
	--num5/6: dist. between timers: you go left (5) and up (6) to go from one timerlayout to the next
	--num7/8: dist. between targets: you go left (7) and up (8) to go from one target to the next
	--num9/10: from main frame to 1st target, for a bit of room: you go left (9) and up (10) to go from main frame to 1st target
	if targetsetup == "up" and timersetup == "left" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOPRIGHT","BOTTOMRIGHT","TOP","BOTTOM","BOTTOMRIGHT","TOPLEFT","TOPRIGHT","TOPLEFT","TOPRIGHT","RIGHT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,0,-5,-self:Get("timerspacing"),0,0,self:Get("targetspacing"),-5,5
	elseif targetsetup == "down" and timersetup == "left" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMRIGHT","TOPRIGHT","TOP","BOTTOM","TOPRIGHT","BOTTOMLEFT","BOTTOMRIGHT","TOPLEFT","TOPRIGHT","RIGHT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,-self:Get("timerspacing"),0,0,-self:Get("targetspacing"),-5,-5
	elseif targetsetup == "left" and timersetup == "up" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOP","BOTTOM","LEFT","RIGHT","BOTTOMRIGHT","TOPLEFT","BOTTOMLEFT","TOPLEFT","BOTTOMLEFT","BOTTOM"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,5,0,0,self:Get("timerspacing"),-self:Get("targetspacing"),0,-5,5
	elseif targetsetup == "right" and timersetup == "up" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOP","BOTTOM","LEFT","RIGHT","BOTTOMLEFT","TOPRIGHT","BOTTOMRIGHT","TOPLEFT","BOTTOMLEFT","BOTTOM"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,5,0,0,self:Get("timerspacing"),self:Get("targetspacing"),0,5,5
	elseif targetsetup == "up" and timersetup == "right" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOPLEFT","BOTTOMLEFT","TOP","BOTTOM","BOTTOMLEFT","TOPRIGHT","TOPLEFT","TOPRIGHT","TOPLEFT","LEFT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,0,-5,self:Get("timerspacing"),0,0,self:Get("targetspacing"),5,5
	elseif targetsetup == "down" and timersetup == "right" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMLEFT","TOPLEFT","TOP","BOTTOM","TOPLEFT","BOTTOMRIGHT","BOTTOMLEFT","TOPRIGHT","TOPLEFT","LEFT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,self:Get("timerspacing"),0,0,-self:Get("targetspacing"),5,-5
	elseif targetsetup == "left" and timersetup == "down" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOM","TOP","LEFT","RIGHT","TOPRIGHT","BOTTOMLEFT","TOPLEFT","BOTTOMLEFT","TOPLEFT","TOP"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,5,0,0,-self:Get("timerspacing"),-self:Get("targetspacing"),0,-5,-5
	elseif targetsetup == "right" and timersetup == "down" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOM","TOP","LEFT","RIGHT","TOPLEFT","BOTTOMRIGHT","TOPRIGHT","BOTTOMLEFT","TOPLEFT","TOP"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,5,0,0,-self:Get("timerspacing"),self:Get("targetspacing"),0,5,-5
	elseif targetsetup == "right" and timersetup == "right" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMLEFT","TOPLEFT","TOP","BOTTOM","TOPLEFT","BOTTOMRIGHT","TOPRIGHT","TOPRIGHT","TOPLEFT","LEFT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,self:Get("timerspacing"),0,self:Get("targetspacing"),0,5,-5
	elseif targetsetup == "down" and timersetup == "down" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOM","TOP","LEFT","RIGHT","TOPLEFT","BOTTOMRIGHT","BOTTOMLEFT","BOTTOMLEFT","TOPLEFT","TOP"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,5,0,0,-(self:Get("timerspacing")),0,-(self:Get("targetspacing")),5,-5
	elseif targetsetup == "left" and timersetup == "left" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMRIGHT","TOPRIGHT","TOP","BOTTOM","TOPRIGHT","BOTTOMLEFT","TOPLEFT","TOPLEFT","TOPRIGHT","RIGHT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,-self:Get("timerspacing"),0,-self:Get("targetspacing"),0,-5,-5
	elseif targetsetup == "up" and timersetup == "up" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOP","BOTTOM","LEFT","RIGHT","BOTTOMLEFT","TOPRIGHT","TOPLEFT","TOPLEFT","BOTTOMLEFT","BOTTOM"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,5,0,0,self:Get("timerspacing"),0,self:Get("targetspacing"),5,5
	elseif targetsetup == "up" and timersetup == "down" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "TOP","BOTTOM","LEFT","RIGHT","BOTTOMLEFT","TOPRIGHT","TOPLEFT","BOTTOMLEFT","TOPLEFT","TOP"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,-5,5,0,0,-self:Get("timerspacing"),0,self:Get("targetspacing"),5,5
	elseif targetsetup == "down" and timersetup == "up" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOM","TOP","LEFT","RIGHT","TOPLEFT","BOTTOMRIGHT","BOTTOMLEFT","TOPLEFT","BOTTOMLEFT","BOTTOM"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,5,0,0,self:Get("timerspacing"),0,-self:Get("targetspacing"),5,-5
	elseif targetsetup == "left" and timersetup == "right" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMLEFT","TOPLEFT","TOP","BOTTOM","TOPRIGHT","BOTTOMLEFT","TOPLEFT","TOPRIGHT","TOPLEFT","LEFT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,self:Get("timerspacing"),0,-self:Get("targetspacing"),0,5,-5
	elseif targetsetup == "right" and timersetup == "left" then
		ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10 = "BOTTOMRIGHT","TOPRIGHT","TOP","BOTTOM","TOPLEFT","BOTTOMRIGHT","TOPRIGHT","TOPLEFT","TOPRIGHT","RIGHT"
		num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = 0,5,0,-5,-self:Get("timerspacing"),0,self:Get("targetspacing"),0,-5,-5
	else
		return
	end
	return ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10
end

function TimerLib:DefineInterface(suppress) --the controller behind the 16 different interface layouts
	--expects:
	-- .targetlayout
	-- .timerlayout
	-- .targetspacing
	-- .timerspacing
	local ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = self:ReturnAnchors()
	for i = 1,self.libraries["TimerLib"].totaltargets do
		getglobal(self.libraries["TimerLib"].targetframe..i):ClearAllPoints()
		getglobal(self.libraries["TimerLib"].targetframe..i.."Name"):ClearAllPoints()
		getglobal(self.libraries["TimerLib"].targetframe..i.."Name"):SetPoint(ref1,self.libraries["TimerLib"].targetframe..i,ref2,num1,num2)
		for id = 1,self.libraries["TimerLib"].totaltimers do
			getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id):ClearAllPoints()
			getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id.."IconTime"):ClearAllPoints()
			getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id.."IconTime"):SetPoint(ref3,self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id.."IconButton",ref4,num3,num4)
		end
	end
	for i = 1,self.libraries["TimerLib"].totaltargets do
		getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe.."1"):SetPoint(ref10,self.libraries["TimerLib"].targetframe..i,ref10)
		for id = 2,self.libraries["TimerLib"].totaltimers do
			getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id):SetPoint(ref9,self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..(id-1),ref8,num5,num6)
		end
	end
	getglobal(self.libraries["TimerLib"].targetframe.."1"):SetPoint(ref5,self.libraries["TimerLib"].positionframe,ref6,num9,num10)
	for i = 2,self.libraries["TimerLib"].totaltargets do
		getglobal(self.libraries["TimerLib"].targetframe..i):SetPoint(ref5,self.libraries["TimerLib"].targetframe..(i-1),ref7,num7,num8)
	end
	if not suppress then self:ResizeInterface() end
end

function TimerLib:ResizeInterface() --resizes the frames that hold the timers so that they are more tightly compacted on the screen
	local timerformat = self:Get("format")
	local timerlayout = self:Get("timerlayout")
	local targetlayout = self:Get("targetlayout")
	local timerspacing = self:Get("timerspacing")
	local barlength = self:Get("barlength")
	local buttonscale = self:Get("buttonscale")
	local hasname = self:Get("names") or self:Get("raidicons")
	local offset = self:Get("icons") and 16 or 0
	for i = 1,table.getn(self.libraries["TimerLib"].datatable) do
		if self.libraries["TimerLib"].datatable[i].numshown > 0 then
			local maxheight,maxwidth = 0,0
			if timerformat == "icons" then
				for id = 1,self.libraries["TimerLib"].datatable[i].numvisible do
					local timer = getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id.."Icon")
					maxheight = math.max(timer:GetHeight(),maxheight)
					maxwidth = math.max(timer:GetWidth(),maxwidth)
				end
			elseif timerformat == "bars" then
				maxheight = 16 * buttonscale
				maxwidth = (barlength + offset) * buttonscale
			elseif timerformat == "text" then
				maxheight = 15 * buttonscale
				maxwidth = barlength * buttonscale
			end
			for id = 1,self.libraries["TimerLib"].datatable[i].numvisible do
				local timer = getglobal(self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id)
				timer:SetWidth(maxwidth)
				timer:SetHeight(maxheight)
			end
			local totalwidth,totalheight
			if timerlayout == "down" or timerlayout == "up" then
				totalheight = (self.libraries["TimerLib"].datatable[i].numvisible * (maxheight + timerspacing)) - timerspacing
				totalwidth = maxwidth
			else
				totalheight = maxheight
				totalwidth = (self.libraries["TimerLib"].datatable[i].numvisible * (maxwidth + timerspacing)) - timerspacing
			end
			local targetheight,targetwidth
			local targetframe = self.libraries["TimerLib"].targetframe..i
			local adjustoffset
			local namewidth,nameheight
			if hasname then
				namewidth = getglobal(targetframe.."Name"):GetWidth()
				nameheight = getglobal(targetframe.."Name"):GetHeight()
				if (targetlayout == "down" or targetlayout == "up") then
					--height
					targetheight = totalheight
					targetwidth = totalwidth
					adjustoffset = true
				else
					targetheight = totalheight
					targetwidth = math.max(totalwidth,namewidth)
				end
			else
				targetheight = totalheight
				targetwidth = totalwidth
			end
			local ref1,ref2,ref3,ref4,ref5,ref6,ref7,ref8,ref9,ref10,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10 = self:ReturnAnchors()
			if adjustoffset then
				local add = nameheight + 5
				if targetlayout == "down" then num8 = num8 - add else num8 = num8 + add end
			end
			if i > 1 then getglobal(targetframe):SetPoint(ref5,self.libraries["TimerLib"].targetframe..(i-1),ref7,num7,num8) end
			getglobal(targetframe):SetWidth(targetwidth)
			getglobal(targetframe):SetHeight(targetheight)
		end
	end
end

function TimerLib:DefineFormat(suppress)
	--expects:
	-- .format
	-- .icons
	-- .barlength
	if self:Get("format") == "icons" then
		for i = 1,self.libraries["TimerLib"].totaltargets do
			for id = 1,self.libraries["TimerLib"].totaltimers do
				local timerframe = self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id
				getglobal(timerframe.."Icon"):Show()
				getglobal(timerframe.."Bar"):Hide()
				getglobal(timerframe.."Text"):Hide()
				getglobal(timerframe):SetScale(1)
			end
		end
	elseif self:Get("format") == "bars" then
		for i = 1,self.libraries["TimerLib"].totaltargets do
			for id = 1,self.libraries["TimerLib"].totaltimers do
				local timerframe = self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id
				getglobal(timerframe.."Icon"):Hide()
				getglobal(timerframe.."Bar"):Show()
				getglobal(timerframe.."Text"):Hide()
				local offset
				if self:Get("icons") then
					offset = 16
					getglobal(timerframe.."BarButtonTexture"):Show()
				else
					offset = 0
					getglobal(timerframe.."BarButtonTexture"):Hide()
				end
				getglobal(timerframe.."BarStatus"):ClearAllPoints()
				getglobal(timerframe.."BarStatus"):SetPoint("TOPLEFT",timerframe.."Bar","TOPLEFT",offset,0)
				getglobal(timerframe.."Bar"):SetWidth(self:Get("barlength") + offset)
				getglobal(timerframe.."Bar"):SetHeight(16)
				getglobal(timerframe.."BarStatusTime"):SetWidth(self:Get("barlength") - 6)
				local color = self:Get("bartextcolor")
				getglobal(timerframe.."BarStatusTime"):SetTextColor(color.r,color.g,color.b)
				color = self:Get("barbackgroundcolor")
				getglobal(timerframe.."BarBackground"):SetStatusBarColor(color.r,color.g,color.b)
				getglobal(timerframe.."BarButton"):SetWidth(self:Get("barlength") + offset)
				getglobal(timerframe.."BarStatus"):SetWidth(self:Get("barlength"))
				getglobal(timerframe.."BarStatus"):SetStatusBarTexture(bartextures[self:Get("bartexture")])
				getglobal(timerframe.."BarBackground"):SetWidth(self:Get("barlength"))
				getglobal(timerframe.."BarBackground"):SetStatusBarTexture(bartextures[self:Get("bartexture")])
			end
		end
	elseif self:Get("format") == "text" then
		for i = 1,self.libraries["TimerLib"].totaltargets do
			for id = 1,self.libraries["TimerLib"].totaltimers do
				local timerframe = self.libraries["TimerLib"].targetframe..i..self.libraries["TimerLib"].timerframe..id
				getglobal(timerframe.."Icon"):Hide()
				getglobal(timerframe.."Bar"):Hide()
				getglobal(timerframe.."Text"):Show()
				getglobal(timerframe.."Text"):SetWidth(self:Get("barlength"))
				getglobal(timerframe.."Text"):SetHeight(15)
				getglobal(timerframe.."TextButtonTime"):SetWidth(self:Get("barlength"))
				getglobal(timerframe.."TextButton"):SetWidth(self:Get("barlength"))
			end
		end
	end
	if not suppress then self:ResizeInterface() end
end

local blanktimer = {
	spell = "Blank Spot", 
	rank = "", 
	texture = "No Texture", 
	duration = 0, 
	time = 0, 
	type = "blank", 
	english = "Blank Spot",
}

function TimerLib:InsertBlankTimer(i,id)
	self:AddTimer(i,blanktimer,1,nil,nil,id)
end

local secondsformats = {
	["##"] = "%d%s",
	[":##"] = ":%.2d%s",
	["0:##"] = "0:%.2d%s",
}

function TimerLib:ReturnFormattedDuration(time) --modifies the time remaining on the timer into a format suitable for the screen
	--expects:
	-- .tenths
	local minutes = math.floor(time / 60)
	local seconds = math.floor(time - (60 * minutes))
	local remaining = time - (60 * minutes) - (seconds)
	local decimal
	if self:Get("tenths") then decimal = "."..string.format("%d",remaining * 10) else decimal = "" end
	if minutes == 0 then
		return string.format(secondsformats[self:Get("secondsformat")],seconds,decimal)
	else
		if minutes < 60 then
			return string.format("%d:%.2d%s",minutes,seconds,decimal)
		else
			local hours = math.floor(minutes / 60)
			minutes = minutes - (60 * hours)
			if hours < 24 then
				return string.format("%d:%d:%.2d%s",hours,minutes,seconds,decimal)
			else
				local days = math.floor(hours / 24)
				hours = hours - (24 * days)
				return string.format("%d:%d:%d:%.2d%s",days,hours,minutes,seconds,decimal)
			end
		end
	end
end

function TimerLib:UpdateTimers(elapsed) --updating the timers onscreen, as well as checking for any finished timers
	--expects:
	-- .tenths
	-- .format
	-- .playsound
	-- .expalert
	local timerformat = self:Get("format")
	local barmsg = self:Get("barmsg")
	local ghosts = self:Get("ghosts")
	local ghostduration = self:Get("ghostdata")
	local tenths = self:Get("tenths")
	local playsound = self:Get("playsound")
	local expalert = self:Get("expalert")
	local reversed = self:Get("reversed")
	local barlength = self:Get("barlength")
	local fadeintime = self:Get("fadeintime")
	local fadeouttime = self:Get("fadeouttime")
	local timerlib = self.libraries["TimerLib"]
	local datatable = timerlib.datatable
	if table.getn(datatable) == 0 then timerlib.frame:SetScript("OnUpdate",nil) end
	local time = GetTime()
	for i = table.getn(datatable),1,-1 do --scanning all the timers to see if they are done
		for id = table.getn(datatable[i]),1,-1 do
			if datatable[i] and datatable[i][id] then
				local timer = datatable[i][id]
				local timerdata = timer.module.libraries["TimerLib"].timerdata[timer.type]
				local timerframe = timerlib.targetframe..i..timerlib.timerframe..id
				getglobal(timerframe):SetAlpha(1)
				if timerdata.hastimer then
					timer.alpha = nil
					if time >= timer.time + timer.duration then --yep it's done all right
						if not timer.datachanged then
							timer.datachanged = true
							if not timer.finished then self:RemoveTimer(i,id,"finished") end
							local r,g,b = timer.module:GetTimerColor(timer)
							if timerformat == "bars" then
								getglobal(timerframe.."BarStatusTime"):SetText(string.find(barmsg,"%s") and timer.spell or "")
								getglobal(timerframe.."BarStatus"):SetValue(1)
								getglobal(timerframe.."BarStatusSpark"):Hide()
								getglobal(timerframe.."BarStatus"):SetStatusBarColor(r,g,b)
								getglobal(timerframe.."BarButtonStack"):SetText("")
							elseif timerformat == "icons" then
								getglobal(timerframe.."IconTime"):SetText("")
								getglobal(timerframe.."IconTime"):SetTextColor(r,g,b)
								getglobal(timerframe.."IconButtonStack"):SetText("")
							elseif timerformat == "text" then
								getglobal(timerframe.."TextButtonTime"):SetText(timer.spell)
								getglobal(timerframe.."TextButtonTime"):SetTextColor(r,g,b)
							end
						end
						local dtype = timer.type
						local fadingout
						local moddedduration = 0
						if ghosts and timer.module:TimerIsReal(dtype) and not (dtype == "hidden") then 
							if time >= timer.time + timer.duration + ghostduration then
								fadingout = true
								moddedduration = ghostduration
							end
						else
							fadingout = true
						end
						if fadingout then
							if (fadeouttime == 0) or (time >= timer.time + timer.duration + moddedduration + fadeouttime) then
								self:RemoveTimer(i,id,"fadedout")
							else
								local alpha = 1 - ((time - timer.time - timer.duration - moddedduration) / fadeouttime)
								timer.alpha = alpha
								timer.frame:SetAlpha(alpha)
							end
						end
					else
						local timeremaining = timer.duration - time + timer.time
						local timeelapsed = time - timer.timeadded
						local fadingtime = math.min(fadeintime,timer.duration - 1)
						if fadingtime > 0 then
							if timeelapsed <= fadingtime then
								local alpha = timeelapsed / fadingtime
								getglobal(timerframe):SetAlpha(alpha)
								timer.alpha = alpha
							end
						end
						if timerdata.disptimer then
							local remaining = tonumber(string.format(tenths and "%.1f" or "%d",timeremaining)) --modifying the displayed time if it needs changing
							if timerformat == "icons" then
								local r,g,b = timer.module:GetTimerColor(timer)
								if (not timer.r) or (not (timer.r == r and timer.g == g and timer.b == b)) then
									getglobal(timerframe.."IconTime"):SetTextColor(r,g,b)
									timer.r = r
									timer.g = g
									timer.b = b
								end
								if (not timer.displayed) or (remaining < timer.displayed) then
									getglobal(timerframe.."IconTime"):SetText(self:ReturnFormattedDuration(timeremaining)) --updating the time if they aren't done
									if (timer.stack and timer.stack > 1) then getglobal(timerframe.."IconButtonStack"):SetText(timer.stack) else getglobal(timerframe.."IconButtonStack"):SetText("") end
									if remaining == 5 then
										if playsound then PlaySoundFile("Interface\\AddOns\\Ash_Core\\Files\\expalert.wav") end
										if expalert then getglobal(timerframe.."IconButton"):LockHighlight() end
									elseif remaining == 3 then
										if expalert then getglobal(timerframe.."IconButton"):UnlockHighlight() end
									end
									timer.displayed = remaining
								end
							elseif timerformat == "bars" then
								local barvalue = timeremaining / timer.duration
								if reversed then barvalue = 1 - barvalue end
								getglobal(timerframe.."BarStatus"):SetValue(barvalue)
								local r,g,b = timer.module:GetTimerColor(timer)
								if (not timer.r) or (not (timer.r == r and timer.g == g and timer.b == b)) then
									getglobal(timerframe.."BarStatus"):SetStatusBarColor(r,g,b)
									timer.r = r
									timer.g = g
									timer.b = b
								end
								if (not timer.displayed) or (remaining < timer.displayed) then
									getglobal(timerframe.."BarStatusTime"):SetText(self:FormatBarText(i,id)) --updating the time if they aren't done
									if (timer.stack and timer.stack > 1) then getglobal(timerframe.."BarButtonStack"):SetText(timer.stack) else getglobal(timerframe.."BarButtonStack"):SetText("") end
									if remaining == 5 then
										if playsound then PlaySoundFile("Interface\\AddOns\\Ash_Core\\Files\\expalert.wav") end
									end
									timer.displayed = remaining
								end
								getglobal(timerframe.."BarStatusSpark"):ClearAllPoints()
								getglobal(timerframe.."BarStatusSpark"):SetPoint("CENTER",timerframe.."BarStatus","LEFT",(barvalue * barlength),0)
							elseif timerformat == "text" then	
								local r,g,b = timer.module:GetTimerColor(timer)
								if (not timer.r) or (not (timer.r == r and timer.g == g and timer.b == b)) then
									getglobal(timerframe.."TextButtonTime"):SetTextColor(r,g,b)
									timer.r = r
									timer.g = g
									timer.b = b
								end
								if (not timer.displayed) or (remaining < timer.displayed) then
									getglobal(timerframe.."TextButtonTime"):SetText(self:FormatBarText(i,id)) --updating the time if they aren't done
									if remaining == 5 then
										if playsound then PlaySoundFile("Interface\\AddOns\\Ash_Core\\Files\\expalert.wav") end
									end
									timer.displayed = remaining
								end
							end
						end
					end
				end
			end
		end
	end
end

function TimerLib:ReturnTargetTable(target,sex,level,module) --returns the timer table for the corresponding target/sex/level information
	local casted = self.libraries["TimerLib"].datatable
	for i = 1,table.getn(casted) do
		if casted[i].target == target and casted[i].sex == sex and casted[i].level == level and ((not module) or casted[i].module == module) then return i end
	end
end

function TimerLib:ReturnTargetType(unit)
	if (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) then return "player" end
	return "mob"
end

function TimerLib:HasDebuff(spell,unit)
	unit = unit or "target"
	spell = string.gsub(spell,"(%p)","%%%1")
	local i = 1
	local debuff,rank,icon,count,debuffType,duration,timeleft = UnitDebuff(unit,1)
	while debuff do
		if string.find(debuff,spell) and duration and timeleft then return duration,timeleft end
		i = i + 1
		debuff,rank,icon,count,debuffType,duration,timeleft = UnitDebuff(unit,i)
	end
end

function TimerLib:HasBuff(spell,unit)
	unit = unit or "target"
	spell = string.gsub(spell,"(%p)","%%%1")
	local i = 1
	local buff,rank,icon,count,duration,timeleft = UnitBuff(unit,1)
	while buff do
		if string.find(buff,spell) and duration and timeleft then return duration,timeleft end
		i = i + 1
		buff,rank,icon,count,duration,timeleft = UnitBuff(unit,i)
	end
end

function TimerLib:FindUnitTargetTable(unit)
	local name = UnitName(unit)
	local sex = UnitSex(unit)
	local level = UnitLevel(unit)
	local time = GetTime()
	for i = 1,self:GetNumTargets() do
		local target = self:GetTarget(i)
		if target.target == name and target.sex == sex and target.level == level then
			for id = 1,self:GetNumTimers(i) do
				local timer = self:GetTimer(i,id)
				local duration,timeleft
				if timer.type == "debuff" then
					duration,timeleft = self:HasDebuff(timer.spell,unit)
				elseif timer.type == "buff" then
					duration,timeleft = self:HasBuff(timer.spell,unit)
				end
				if (duration and timeleft) and (math.abs(timeleft - (timer.duration - time + timer.time)) <= .1) and (math.abs(duration - timer.duration) <= .1) then return i end
			end
		end
	end
end

function TimerLib:ReturnUnitTargetTable(unit)
	local unitflag = (UnitIsUnit(unit,"target") and "target") or (UnitIsUnit(unit,"focus") and "focus")
	if unitflag then unit = unitflag end
	local ttype = self:ReturnTargetType(unit)
	if unit == "target" or unit == "focus" then
		for i = 1,self:GetNumTargets() do
			local target = self:GetTarget(i)
			if target.unit and target.unit == unit then return i end
		end
	end
	if ttype == "player" then
		for i = 1,self:GetNumTargets() do
			local target = self:GetTarget(i)
			if ttype == target.type and target.target == UnitName(unit) then return i end
		end
	end
	local i = self:FindUnitTargetTable(unit)
	if i then
		if unitflag then self:GetTarget(i).unit = unit end
		return i
	end
end

function TimerLib:FormatBarText(i,id)
	--expects:
	-- .barmsg
	local datatable = self.libraries["TimerLib"].datatable[i]
	local displayed = datatable[id].duration - GetTime() + self.libraries["TimerLib"].datatable[i][id].time
	local count = (datatable[id].stack and datatable[id].stack > 1 and datatable[id].stack or "")
	local spell = datatable[id].spell
	local rank = datatable[id].rank
	local target = datatable.target
	local level = datatable.level
	local subentries = {
		["%d"] = self:ReturnFormattedDuration(displayed),
		["%s"] = spell,
		["%c"] = count,
		["%r"] = rank,
		["%t"] = target,
		["%l"] = level,
	}
	local msg = string.gsub(self:Get("barmsg"),"(%%%a)",function(a) return subentries[a] or "" end)
	msg = string.gsub(msg,"[%(%[%<%{][%)%]%>%}]","")
	return msg
end

function TimerLib:CreateTimerGroup(name,isreal,hastimer,disptimer,clickable,scale,alpha,colors,total)
	self.libraries["TimerLib"].timerdata = self.libraries["TimerLib"].timerdata or {}
	self.libraries["TimerLib"].timerdata[name] = {
		isreal = isreal,
		hastimer = hastimer,
		disptimer = disptimer,
		clickable = clickable,
		scale = scale,
		alpha = alpha,
		colors = colors,
		total = total,
	}
	table.insert(self.libraries["TimerLib"].timerdata,name)
end

function TimerLib:RemoveTimer(i,id,reason,suppress,nofade) --deletes a timer onscreen from existence
	--expects:
	-- .ghosts
	--possible reasons: finished, broke, replaced, target, full, clicked,inaccurate
	if self.libraries["TimerLib"].frozen then return end
	reason = reason or "unknown"
	if self.libraries["TimerLib"].datatable[i] and self.libraries["TimerLib"].datatable[i][id] then
		local timer = self:GetTimer(i,id)
		local remaining = timer.duration - GetTime() + timer.time
		if (reason == "fadedout") or nofade or (remaining > (timer.duration / 20)) then --if less than 5% remains, it will be left alone to fade out.
			if reason == "broke" then reason = "finished" end
			table.remove(self.libraries["TimerLib"].datatable[i],id)
			if not suppress then self:CreateInterface() end
		else
			timer.finished = true
		end
		self:Debug("the timer for "..timer.spell.." has been removed, reason: "..reason)
	end
end

function TimerLib:GetTimerColor(timer)
	local remaining = timer.duration - GetTime() + timer.time
	local half = timer.duration / 2
	local colors
	local r,g,b
	if timer.module:TimerIsReal(timer.type) then colors = self:Get("colors","timer",timer.spell) end
	if not colors then colors = self:Get("colors","timer",string.lower(timer.spell)) end
	if not colors then colors = self:Get("colors","type",timer.type) end
	if not colors then colors = self.libraries["TimerLib"].timerdata[timer.type].colors end
	if self.libraries["TimerLib"].timerdata[timer.type].disptimer then
		if remaining <= 0 then
			local color = self:Get("ghostcolor")
			r,g,b = color.r,color.g,color.b
		elseif remaining <= 5 then
			local color = colors["final"]
			r,g,b = color.r,color.g,color.b
		elseif remaining <= 7 then
			local fadefromcolor
			if remaining > half then
				fadefromcolor = colors["begin"]
			else
				fadefromcolor = colors["half"]
			end
			local fadetocolor = colors["final"]
			local elapsed = (7 - remaining) / 2
			r = fadefromcolor.r + ((fadetocolor.r - fadefromcolor.r) * elapsed)
			g = fadefromcolor.g + ((fadetocolor.g - fadefromcolor.g) * elapsed)
			b = fadefromcolor.b + ((fadetocolor.b - fadefromcolor.b) * elapsed)
		elseif remaining <= half then
			local color = colors["half"]
			r,g,b = color.r,color.g,color.b
		elseif remaining <= half + 2 then
			local fadefromcolor = colors["begin"]
			local fadetocolor = colors["half"]
			local elapsed = (half + 2 - remaining) / 2
			r = fadefromcolor.r + ((fadetocolor.r - fadefromcolor.r) * elapsed)
			g = fadefromcolor.g + ((fadetocolor.g - fadefromcolor.g) * elapsed)
			b = fadefromcolor.b + ((fadetocolor.b - fadefromcolor.b) * elapsed)
		else
			local color = colors["begin"]
			r,g,b = color.r,color.g,color.b
		end
	else
		local color = colors["begin"]
		r,g,b = color.r,color.g,color.b
	end
	return r,g,b
end

function TimerLib:RemoveTarget(targetindex,norefresh)
	if self.libraries["TimerLib"].frozen then return end
	self:Debug("a target table has been removed")
	table.remove(self.libraries["TimerLib"].datatable,targetindex)
	if not norefresh then self:CreateInterface() end
end

function TimerLib:RemoveAllTimers()
	if self.libraries["TimerLib"].frozen then return end
	self:Debug("the interface has been cleared")
	for i = table.getn(self.libraries["TimerLib"].datatable),1,-1 do
		self:RemoveTarget(i,1)
	end
	self:CreateInterface()
end

function TimerLib:ShowTimers(numtargets,numtimers) --used to view different interface layouts
	self:RemoveAllTimers()
	numtargets = numtargets or self.libraries["TimerLib"].totaltargets
	numtimers = numtimers or self.libraries["TimerLib"].totaltimers
	local time = GetTime()
	local stagger = 0
	for i = 1,numtargets do
		local target = {target = "Scary Mob "..i}
		for id = 1,numtimers do
			local timer = {spell = "Cool Timer", duration = 20, time = time - stagger}
			self:AddTimer(target,timer,1)
			stagger = stagger + .5
		end
		self:CreateInterface()
	end
end

function TimerLib:TimeToNum(time)
	local test = tonumber(time)
	if test then return test end
	local matches = {
		["s"] = 1,
		["m"] = 60,
		["h"] = 3600,
		["d"] = 86400,
	}
	local usages = {self:ParseString(time,"(%d+[smhd])")}
	if usages[1] == false then return end
	local seconds = 0
	for index,value in ipairs(usages) do
		local num,str = self:ParseString(value,"(%d+)(%a)")
		seconds = seconds + (num * (matches[str] or 0))
	end
	return seconds
end

function TimerLib:NumToTime(num)
	local str = ""
	local matches = {
		{len = 86400,letter = "d"},
		{len = 3600,letter = "h"},
		{len = 60,letter = "m"},
		{len = 1,letter = "s"},
	}
	if num == 0 then return "0s" end
	for index,value in ipairs(matches) do
		local total = 0
		while num >= value.len do
			total = total + 1
			num = num - value.len
		end
		if total > 0 then str = str..total..value.letter.." " end
	end
	str = string.sub(str,1,-2)
	return str
end

function TimerLib:TimerIsReal(i,id)
	if id then
		return self.libraries["TimerLib"].timerdata[self.libraries["TimerLib"].datatable[i][id].type].isreal and true or false
	elseif type(i) == "table" then
		return self.libraries["TimerLib"].timerdata[i.type].isreal
	else
		return self.libraries["TimerLib"].timerdata[i].isreal
	end
end

function TimerLib:GetNumTargets()
	return #self.libraries["TimerLib"].datatable
end

function TimerLib:GetNumTimers(i)
	return #self.libraries["TimerLib"].datatable[i]
end

function TimerLib:FreezeTimers()
	self.libraries["TimerLib"].frame:SetScript("OnUpdate",nil)
	self.libraries["TimerLib"].frozen = true
end

function TimerLib:UnFreezeTimers()
	if self:GetNumTargets() > 0 then self.libraries["TimerLib"].frame:SetScript("OnUpdate",self.libraries["TimerLib"].updatefunc) end
	self.libraries["TimerLib"].frozen = false
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function(self,event) for _,module in ipairs(listofmodules) do module:CreateInterface(1) end end)

defaulttimerdata = {
	isreal = true,
	hastimer = true,
	disptimer = true,
	clickable = true,
	scale = 1,
	alpha = 1,
	colors = {
		begin = {
			r = .2,
			g = 1.0,
			b = .2,
		},
		half = {
			r = 1.0,
			g = 1.0,
			b = .2,
		},
		final = {
			r = 1.0,
			g = .2,
			b = .2,
		},
	}
}
defaulthiddendata = {
	isreal = true,
	hastimer = true,
	disptimer = false,
	clickable = false,
	scale = 1,
	alpha = 0,
	total = true,
	colors = {
		begin = {
			r = 0.0,
			g = 0.0,
			b = 0.0,
		},
		half = {
			r = 0.0,
			g = 0.0,
			b = 0.0,
		},
		final = {
			r = 0.0,
			g = 0.0,
			b = 0.0,
		},
	}
}
timertypes = {
	hidden = defaulthiddendata,
}
defaulttarget = {
	target = "Target",
	text = "Target",
	type = "player",
	sex = 0,
	level = 0,
	icon = 0,
	id = 0,
}
defaulttimer = {
	spell = "Spell",
	rank = "",
	texture = "Interface\\Icons\\Spell_Lightning_LightningBolt01",
	duration = 10,
	type = "default",
}
bartextures = {
	"Interface\\TargetingFrame\\UI-StatusBar",
	"Interface\\TargetingFrame\\UI-TargetingFrame-BarFill",
	"Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
	"Interface\\AddOns\\Ash_Core\\Files\\Banto",
	"Interface\\AddOns\\Ash_Core\\Files\\Charcoal",
	"Interface\\AddOns\\Ash_Core\\Files\\Cilo",
	"Interface\\AddOns\\Ash_Core\\Files\\Cool",
	"Interface\\AddOns\\Ash_Core\\Files\\Elven",
	"Interface\\AddOns\\Ash_Core\\Files\\Futuristic",
	"Interface\\AddOns\\Ash_Core\\Files\\Futuristic_3d",
	"Interface\\AddOns\\Ash_Core\\Files\\Glaze",
	"Interface\\AddOns\\Ash_Core\\Files\\Gloss",
	"Interface\\AddOns\\Ash_Core\\Files\\Grunge",
	"Interface\\AddOns\\Ash_Core\\Files\\Halycon",
	"Interface\\AddOns\\Ash_Core\\Files\\Measurement",
	"Interface\\AddOns\\Ash_Core\\Files\\Metal",
	"Interface\\AddOns\\Ash_Core\\Files\\Moonmaster",
	"Interface\\AddOns\\Ash_Core\\Files\\OtraviCB",
	"Interface\\AddOns\\Ash_Core\\Files\\Perl",
	"Interface\\AddOns\\Ash_Core\\Files\\Smooth",
	"Interface\\AddOns\\Ash_Core\\Files\\Solid",
	"Interface\\AddOns\\Ash_Core\\Files\\Steel",
	"Interface\\AddOns\\Ash_Core\\Files\\Stone",
	"Interface\\AddOns\\Ash_Core\\Files\\Striped",
}

defaultsettings = {
	["onlytarget"] = false,
	["sorttarget"] = false,
	["onlyfocus"] = false,
	["sortfocus"] = false,
	["ghosts"] = true,
	["status"] = true,
	["barlength"] = 175,
	["barmsg"] = "%d - %s",
	["icons"] = true,
	["raidicons"] = true,
	["targetlayout"] = "down",
	["targetspacing"] = 15,
	["scale"] = 1,
	["buttonscale"] = 1,
	["sortmethod"] = "remaining (D)",
	["names"] = true,
	["clickable"] = true,
	["tenths"] = false,
	["playsound"] = false,
	["alpha"] = 1,
	["reverse"] = false,
	["expalert"] = true,
	["timerlayout"] = "down",
	["ghostdata"] = 2,
	["locked"] = false,
	["format"] = "bars",
	["timerspacing"] = 5,
	["hideall"] = false,
	["hidden"] = {},
	["hiddentypes"] = {},
	["bartexture"] = 4,
	["bartextcolor"] = {r = .85, g = .85, b = .85},
	["ghostcolor"] = {r = .25, g = .25, b = 1},
	["barbackgroundcolor"] = {r = .1, g = .6, b = .8},
	["fadeintime"] = 1,
	["fadeouttime"] = 3,
	["secondsformat"] = "0:##",
}

timerdatametatable = {__index = function(i,v) return timertypes[v] or defaulttimerdata end}
targetmetatable = {__index = defaulttarget}
timermetatable = {__index = defaulttimer}

AsheylaLib:CreateLibrary("TimerLib",TimerLib)
