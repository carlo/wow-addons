AsheylaLib = {}
AsheylaLib_Settings = {}
local mastermetatable = {}
local metatable
local version = "3.3.2"
local dateuploaded = "July 1, 2007"
local modules = {}
local registeredforhooks = {}
local counter = 0

local function error(msg)
	local f = geterrorhandler()
	if f then f(msg) end
end

function AsheylaLib:ReturnVersion()
	return version
end

function AsheylaLib:ReturnDateUploaded()
	return dateuploaded
end

function AsheylaLib:NewModule(name,...)
	counter = counter + 1
	local module = {}
	module.libraries = {}
	modules[module] = 1
	AsheylaLib:AddLibrary(module,"CoreLib")
	module.libraries["CoreLib"].name = name or "ASHEYLALIBMODULE"..counter
	module.libraries["CoreLib"].hooks = {
		pre = {},
		post = {},
	}
	for i = 1,select("#",...) do
		local library = select(i,...)
		AsheylaLib:AddLibrary(module,library)
	end
	setmetatable(module,metatable)
	return module
end

function AsheylaLib:IsModule(module)
	return modules[module] and true or false
end

function AsheylaLib:GetModule(name)
	for module in pairs(modules) do
		if module.libraries["CoreLib"].name == name then return module end
	end
end

function AsheylaLib:RegisterForHooks(name)
	local oldfunc = AsheylaLib:IsMethod(name)
	if oldfunc then
		if not AsheylaLib:IsRegisteredForHooks(name) then
			registeredforhooks[name] = oldfunc
			local function newfunc(self,...)
				local prehooks = self.libraries["CoreLib"].hooks.pre[name]
				if prehooks then
					local cancelled
					for index,value in pairs(prehooks) do
						local done = value(self,...)
						if done then cancelled = true end
					end
					if cancelled then return end
				end
				oldfunc(self,...)
				local posthooks = self.libraries["CoreLib"].hooks.post[name]
				if posthooks then
					for index,value in pairs(posthooks) do value(self,...) end
				end
			end
			AsheylaLib:SetMethod(name,newfunc)
			return newfunc
		end
		return AsheylaLib:IsMethod(name)
	end
	return false
end

function AsheylaLib:IsRegisteredForHooks(name)
	if AsheylaLib:IsMethod(name) then
		return registeredforhooks[name] and true or false
	end
end

function AsheylaLib:UnregisterForHooks(lib,name)
	if AsheylaLib:IsRegisteredForHooks(name) then
		AsheylaLib:SetMethod(name,registeredforhooks[name])
		registeredforhooks[name] = nil
	end
end

function AsheylaLib:SetMethod(name,func)
	for i,v in pairs(mastermetatable) do
		if v[name] then v[name] = func end
	end
end


function AsheylaLib:CreateLibrary(str,library)
	mastermetatable[str] = library
	registeredforhooks[str] = {}
end

function AsheylaLib:IsCreatedLibrary(library)
	return mastermetatable[library]
end

function AsheylaLib:AddLibrary(module,library)
	if AsheylaLib:IsCreatedLibrary(library) then
		module.libraries[library] = {} 
	end
end

local savedargs = {}
function AsheylaLib:CallEvent(newevent,...)
	local savedevent = event
	for i = #savedargs,1,-1 do table.remove(savedargs,1) end
	for i = 1,select("#",...) do 
		table.insert(savedargs,getglobal("arg"..i)) 
		local newarg = select(i,...)
		if type(newarg) == "table" then newarg = mastermetatable["CoreLib"]:CopyTable(newarg) end
		setglobal("arg"..i,newarg)
	end
	setglobal("event",newevent)
	for module in pairs(modules) do
		if module:IsRegisteredEvent(newevent) then
			local func = module:GetScript("OnEvent")
			if func and type(func) == "function" then func(newevent) end
		end
	end
	for i = 1,#savedargs do setglobal("arg"..i,savedargs[i]) end
	setglobal("event",savedevent)
end

function AsheylaLib:CallScript(module,script,...)
	local func = module:GetScript(script)
	if func and type(func) == "function" then func(...) end
end

function AsheylaLib:GetMethod(index)
	for i,v in pairs(mastermetatable) do
		if self.libraries[i] and v[index] then 
			return v[index] 
		end
	end
end

function AsheylaLib:IsMethod(index)
	for i,v in pairs(mastermetatable) do
		if v[index] then return v[index] end
	end
	return false
end

metatable = {__index = AsheylaLib.GetMethod}
