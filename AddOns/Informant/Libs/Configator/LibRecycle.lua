--[[

	LibRecycle.lua
       A table recycling embeddable library.
       Released into the Public Domain without warranty. Use at your own peril!
	Credits: Norganna, MentalPower, Esamynn.


	Usage:
		local LibRecycle = LibStub("LibRecycle")
		-- then:
		local acquire, recycle, clone, scrub = LibRecycle.All()
		-- or:
		local acquire = LibRecycle.Acquire
		local recycle = LibRecycle.Recycle
		local clone = LibRecycle.Clone
		local scrub = LibRecycle.Scrub

	Functions:
		acquire( one, two, three, ...); Returns { one, two, three, ... }
		recycle( item ); Recycles the table "item" and all subtables. Clears all keys.
		recycle( table, key, key, ...); Recycles given keys in the table. Also clears their entries.
		clone( item, [unsafe] ); Returns a safe-cloned copy of the table (unless unsafe is true.)
		scrub( item ); Cleans the given table, recycling if necessary. Returns an empty table.

]]

local LIBRARY_VERSION_MAJOR = "LibRecycle"
local LIBRARY_VERSION_MINOR = 1

--[[-----------------------------------------------------------------

LibStub is a simple versioning stub meant for use in Libraries.
See <http://www.wowwiki.com/LibStub> for more info.
LibStub is hereby placed in the Public Domain.
Credits:
    Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke

--]]-----------------------------------------------------------------
do
	local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2
	local LibStub = _G[LIBSTUB_MAJOR]

	if not LibStub or LibStub.minor < LIBSTUB_MINOR then
		LibStub = LibStub or {libs = {}, minors = {} }
		_G[LIBSTUB_MAJOR] = LibStub
		LibStub.minor = LIBSTUB_MINOR
		
		function LibStub:NewLibrary(major, minor)
			assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
			minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")
			
			local oldminor = self.minors[major]
			if oldminor and oldminor >= minor then return nil end
			self.minors[major], self.libs[major] = minor, self.libs[major] or {}
			return self.libs[major], oldminor
		end
		
		function LibStub:GetLibrary(major, silent)
			if not self.libs[major] and not silent then
				error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
			end
			return self.libs[major], self.minors[major]
		end
		
		function LibStub:IterateLibraries() return pairs(self.libs) end
		setmetatable(LibStub, { __call = LibStub.GetLibrary })
	end
end
--[End of LibStub]---------------------------------------------------

local lib = LibStub:NewLibrary(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if not lib then return end

-- Create the recylebin (if it doesn't exist)
if not lib.recyclebin then lib.recyclebin = {} end

-- Store the following variables/functions locally to save on lookups.
local tremove = table.remove
local tinsert = table.insert
local recyclebin = lib.recyclebin

local TableofTables = {}
-- Define a local function so we can do the nested subcalls without lookups.
local function recycle(...)
	local tbl, key, item
	-- Get the passed parameter/s
	local n = select("#", ...)
	if n <= 0 then
		return
	elseif n == 1 then
		item = ...
		tbl, key = nil, nil
	elseif n == 2 then
		tbl, key = ...
		item = tbl[key]
	else
		for i=2, n do
			key = select(i, ...)
			recycle(tbl, key)
		end
		return
	end

	-- We can only clean tables
	if type(item) ~= 'table' then
		if tbl and key then
			tbl[key] = nil
		end
		return
	end
	if TableofTables[item] then return end
	
	TableofTables[item] = true
	-- Clean out any values from this table
	for k,v in pairs(item) do
		if type(v) == 'table' and (not v[0] or type(v[0]) ~= 'userdata') then
			-- Recycle this table too
			recycle(item, k)
		else
			item[k] = nil
		end
	end

	-- If we are to clean the input value
	if tbl and key then
		-- Place the husk of a table in the recycle bin
		tinsert(recyclebin, item)

		-- Clean out the original table entry too
		tbl[key] = nil
	end
	TableofTables[item] = nil

end
lib.Recycle = recycle

local function acquire(...)
	local item, v
	
	-- Get a recycled table or create a new one.
	if #recyclebin > 0 then
		item = tremove(recyclebin)
	end
	if not item then
		item = {}
	end

	-- And populate it if there's any args
	n = select("#", ...)
	for i = 1, n do
		v = select(i, ...)
		item[i] = v
	end
	return item
end
lib.Acquire = acquire

local function clone(source, unsafe  --[[ internal only: ]], depth, history)
	if type(source) ~= "table" then
		return source
	end

	if not depth then depth = 0 end
	if depth == 0 and not unsafe then
		history = acquire()
	end

	-- For all the values herein, perform a deep copy
	local dest = acquire()
	if history then history[source] = dest end
	for k, v in pairs(source) do
		if type(v) == "table" then
			if history then
				-- We are tracking the clone history.
				if history[v] then
					-- We have already cloned this table once, set a pointer to the previously
					-- cloned copy instead of recloning it.
					dest[k] = history[v]
				else
					-- Do a full clone of this node.
					dest[k] = clone(v, nil, depth+1, history)
				end
			else
				-- Do a full clone of this node.
				dest[k] = clone(v, nil, depth+1)
			end
		else
			dest[k] = v
		end
	end
	for k,v in pairs(history) do history[k] = nil end
	if history then recycle(history) end
	return dest
end
lib.Clone = clone

local function scrub(item)
	-- We can only clean tables
	if type(item) ~= 'table' then return end

	-- Clean out any values from this table
	for k,v in pairs(item) do
		if type(v) == 'table' then
			-- Recycle this table
			recycle(item, k)
		else
			item[k] = nil
		end
	end
end
lib.Scrub = scrub

function lib.All()
	return acquire, recycle, clone, scrub
end
