local CoreLib = {}

function CoreLib:Print(...) --basic output function
	if DEFAULT_CHAT_FRAME then
		local output = ""
		for i = 1,select("#",...) do
			local msg = select(i,...)
			output = output..tostring(msg)
		end
		DEFAULT_CHAT_FRAME:AddMessage(output) 
	end
end

function CoreLib:ColorPrint(r,g,b,...) --basic output function
	if DEFAULT_CHAT_FRAME then
		local output = ""
		for i = 1,select("#",...) do
			local msg = select(i,...)
			output = output..tostring(msg)
		end
		DEFAULT_CHAT_FRAME:AddMessage(output,r,g,b) 
	end
end

function CoreLib:OtherPrint(frame,...) --basic output function
	if frame then
		local output = ""
		for i = 1,select("#",...) do
			local msg = select(i,...)
			output = output..msg
		end
		frame:AddMessage(output) 
	end
end

function CoreLib:Debug(...) --makes a debug msg if i have that turned on
	local debugchannel = self:Get("debugchannel")
	if debugchannel and not (debugchannel == "" or debugchannel == "off") then
		local frame = getglobal("ChatFrame"..debugchannel)
		if (not (debugchannel == "on")) and frame then self:OtherPrint(frame,...)
		else self:Print(...)
		end
	end
end

function CoreLib:Hook(module,name,loc,hookfunc)
	if AsheylaLib:IsModule(module) then
		AsheylaLib:RegisterForHooks(name)
		local hooks = module.libraries["CoreLib"].hooks[loc]
		if not hooks[name] then hooks[name] = {} end
		hooks[name][self] = hookfunc
	end
end

function CoreLib:Unhook(module,name,loc)
	local hooks = module.libraries["CoreLib"].hooks[loc]
	if hooks[name] then hooks[name][self] = nil end
	for index,value in pairs(module.libraries["CoreLib"].hooks["pre"]) do return end
	for index,value in pairs(module.libraries["CoreLib"].hooks["post"]) do return end
	AsheylaLib:UnregisterForHooks(name)
end

function CoreLib:GetHook(module,name,loc)
	local hooks = module.libraries["CoreLib"].hooks[loc]
	if hooks[name] then return hooks[name][self] end
end

function CoreLib:RegisterSettings()
	if not self:HasRegisteredSettings() then
		local name = self:GetName()
		local settings
		if not AsheylaLib_Settings[name] then AsheylaLib_Settings[name] = {} end
		settings = AsheylaLib_Settings[name]
		self:UpdateSettings()
	end
end

function CoreLib:UnregisterSettings()
	if self:HasRegisteredSettings() then
		AsheylaLib_Settings[self:GetName()] = nil
	end
end

function CoreLib:HasRegisteredSettings()
	return AsheylaLib_Settings[self:GetName()] and true or false
end

function CoreLib:GetSettings()
	if self:HasRegisteredSettings() then
		return AsheylaLib_Settings[self:GetName()]
	end
end

function CoreLib:AddDefaultSettings(meta)
	if self:HasRegisteredSettings() then
		local name = self:GetName()
		local newmeta = {__index = meta}
		local currmeta = getmetatable(AsheylaLib_Settings[name])
		if currmeta then
			currmeta = self:CombineTables(currmeta,newmeta)
		else
			setmetatable(AsheylaLib_Settings[name],newmeta)
		end
	end
end

function CoreLib:Set(...)
	if self:HasRegisteredSettings() then
		local settings = AsheylaLib_Settings[self:GetName()]
		local num = select("#",...)
		local setting,val,op
		setting = settings
		if not (num == 2) then 
			for i = 1,num - 2 do
				local ind = select(i,...)
				if type(ind) == "table" then
					setting = ind
				else
					rawset(setting,ind,(rawget(setting,ind) or {}))
					setting = setting[ind]
				end
			end
		end
		op,val = select(num - 1,...)
		if op == "+" or op == "-" then
			if op == "+" then
				table.insert(setting,val)
			else
				table.remove(setting,val)
			end
		else
			rawset(setting,op,val)
		end
	end
end

function CoreLib:Get(...)
	if self:HasRegisteredSettings() then
		local setting = AsheylaLib_Settings[self:GetName()]
		for i = 1,select("#",...) do
			if not setting then return end
			local val = select(i,...)
			setting = setting[val]
		end
		return setting
	end
end

function CoreLib:GetDefault(...)
	if self:HasRegisteredSettings() then
		local setting = getmetatable(AsheylaLib_Settings[self:GetName()])["__index"]
		for i = 1,select("#",...) do
			if not setting then return end
			local val = select(i,...)
			setting = setting[val]
		end
		return setting
	end
end

function CoreLib:ClearSettings()
	self:ClearTable(AsheylaLib_Settings[self:GetName()])
	self:UpdateSettings()
end

function CoreLib:GetName()
	return self.libraries["CoreLib"].name
end

function CoreLib:SetScript(script,func)
	self.libraries["CoreLib"].scripts = self.libraries["CoreLib"].scripts or {}
	self.libraries["CoreLib"].scripts[script] = func
end

function CoreLib:GetScript(script)
	return self.libraries["CoreLib"].scripts and self.libraries["CoreLib"].scripts[script]
end

function CoreLib:RegisterEvent(event)
	self.libraries["CoreLib"].events = self.libraries["CoreLib"].events or {}
	self.libraries["CoreLib"].events[event] = 1
end

function CoreLib:IsRegisteredEvent(event)
	return (self.libraries["CoreLib"].events and self.libraries["CoreLib"].events[event]) and true or false
end

function CoreLib:UnregisterEvent(event)
	if self.libraries["CoreLib"].events then self.libraries["CoreLib"].events[event] = nil end
end

function CoreLib:MakeSlashCmd(...)
	local global = string.upper(self:GetName())
	SlashCmdList[global] = function(msg) if self.Commands then self:Commands(msg) end end
	for i = 1,select("#",...) do
		local slash = select(i,...)
		setglobal("SLASH_"..global..i,slash)
	end
end

function CoreLib:ParseString(text,...) 
	text = text or ""
	local entries = {}
	local start = 1
	local savetext = text
	for i = 1,select("#",...),2 do
    	local search = select(i,...)
		local newsearch,starter,ender = search,"",""
		if string.sub(search,1,1) == "^" then
			newsearch = string.sub(newsearch,2)
			starter = "^"
		end
		if string.sub(search,string.len(search)) == "$" then
			newsearch = string.sub(newsearch,1,string.len(newsearch)-1)
			ender = "$"
		end
        local numfound = 0
		if not string.find(search,"%(") then
		    if string.find(text,search) then
				numfound = 1
				table.insert(entries,true)
			end
		else
			while string.find(text,search) do				
				numfound = numfound + 1
				local found = {string.find(text,string.format("%s(%s)%s",starter,newsearch,ender))}
				local oldtext = text
				text = string.gsub(text,string.gsub(found[3],"(%p)","%%%1"),"",1)
				for id = 4,table.getn(found) do table.insert(entries,found[id]) end
				if text == oldtext then
					
					break
				end
			end
			if select(i + 1,...) and numfound > 0 then
				local nextarg = select(i + 1,...)
			    local numcaps = (table.getn(entries) - start + 1) / numfound
			    local numstart
				if nextarg < 0 then numstart = start elseif nextarg > 0 then numstart = start + (numcaps * nextarg) end
     			for id = 1,((numfound - math.abs(nextarg)) * numcaps) do table.remove(entries,numstart) end
			end
		end
		if numfound == 0 then table.insert(entries,false) end
		start = table.getn(entries) + 1
		text = savetext
	end
	for index,value in ipairs(entries) do
		if type(tonumber(value)) == "number" then entries[index] = tonumber(value)
		elseif type(value) == "string" then
			local newentry = string.gsub(value,"%,",".")
			if type(tonumber(newentry)) == "number" then entries[index] = tonumber(newentry) end
		end
	end
	return unpack(entries)
end

function CoreLib:CopyTable(oldtable,suppress,tabledata)
	tabledata = tabledata or {}
	local newtable = {}
	if not tabledata[oldtable] then
		tabledata[oldtable] = tcopy
	end
	for index,value in pairs(oldtable) do
		if type(index) == "table" then
			if tabledata[index] then
				index = tabledata[index]
			else
				index = self:CopyTable(index,suppress,tabledata)
			end
		end
		if type(value) == "table" then
			if tabledata[value] then
				newtable[index] = tabledata[value]
			else
				newtable[index] = self:CopyTable(value,suppress,tabledata)
			end
		else
			newtable[index] = value
		end
	end
	if not suppress then
		local meta = getmetatable(oldtable)
		if meta then setmetatable(newtable,meta) end
	end
	return newtable
end

function CoreLib:CombineTables(table1,table2)
	for index,value in pairs(table2) do
		if table1[index] then
			if type(table1[index]) == "table" and type(value) == "table" then 
				table1[index] = self:CombineTables(table1[index],value)
			end
		else
			table1[index] = value
		end
	end
	return table1
end

local tablepool = {}
local currenttables = {}
local setupdate

function CoreLib:AcquireTable(manual)
	local t = table.remove(tablepool,1) or {}
	if not manual then
		table.insert(currenttables,t)
		setupdate(true)
	end
	self:ClearTable(t)
	return t
end

function CoreLib:ReleaseTable(...)
	for i = 1,select("#",...) do
		local t = select(i,...)
		if type(t) == "table" then
			self:ClearTable(t)
			setmetatable(t,nil)
			table.insert(tablepool,t)
		end
	end
end

function CoreLib:ClearTable(t)
	for index,value in pairs(t) do t[index] = nil end
end

local f = CreateFrame("Frame")

local updatefunc = function()
	if #currenttables > 0 then
		CoreLib:ReleaseTable(unpack(currenttables))
		for i = #currenttables,1,-1 do table.remove(currenttables,i) end
		setupdate(false)
	end
end

function setupdate(scanning)
	if scanning then
		f:SetScript("OnUpdate",updatefunc)
	else
		f:SetScript("OnUpdate",nil)
	end
end

function makegarbage()
	local f = CreateFrame("Frame")
	f.counter = 1000
	f:SetScript("OnUpdate",function(self,elapsed)
		if self.counter > 0 then
			local x = DoTimer:AcquireTable()
		else
			self:SetScript("OnUpdate",nil)
		end
		self.counter = self.counter - 1
	end)
end

function CoreLib:UpdateSettings()
	if self.libraries["CoreLib"].updatescripts then
		for index,value in ipairs(self.libraries["CoreLib"].updatescripts) do value(self) end
	end
end

function CoreLib:AddSettingsUpdateScript(func)
	self.libraries["CoreLib"].updatescripts = self.libraries["CoreLib"].updatescripts or {}
	table.insert(self.libraries["CoreLib"].updatescripts,func)
end

function CoreLib:AddAuthorInfo()
	self:Print("|cff00ffffDoTimer Version/Author Info:|r")
	self:Print("|cff00ff00Current version|r: ",AsheylaLib:ReturnVersion())
	self:Print("|cff00ff00Date Uploaded|r: ",AsheylaLib:ReturnDateUploaded())
	self:Print("|cff00ff00Author|r: Asheyla <Warcraft Gaming Faction>, Shattered Hand (Horde)")
	self:Print("|cff00ff00Email|r: ross456@gmail.com")
	self:Print("|cff00ff00AIM|r: IBerian3209")
	self:Print("|cff00ff00Paypal Donations|r: ross456@gmail.com")
end

AsheylaLib:CreateLibrary("CoreLib",CoreLib)
