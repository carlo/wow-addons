--[[
Name: PeriodicTable-3.0
Revision: $Rev: 36068 $
Author: Nymbia (nymbia@gmail.com)
Many thanks to Tekkub for writing PeriodicTable 1 and 2, and for permission to use the name PeriodicTable!
Website: http://www.wowace.com/wiki/PeriodicTable-3.0
Documentation: http://www.wowace.com/wiki/PeriodicTable-3.0/API
SVN: http://svn.wowace.com/wowace/trunk/PeriodicTable-3.0/PeriodicTable-3.0/
Description: Library of compressed itemid sets.
Dependencies: AceLibrary
License: LGPL v2.1
Copyright (C) 2007 Nymbia

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]

local MAJOR_VERSION = "PeriodicTable-3.0"
local MINOR_VERSION = "$Rev: 36068 $"

if not AceLibrary then error(MAJOR_VERSION.." requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION,MINOR_VERSION) then return end

local type = type
local rawget = rawget
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local next = next

local getItemID, makeNonPresentMultiSet, fromb36, fromb36c, uncompress, breakCType, isInCType, shredCTypeCache, shredCache, multisetiter, setiter, activate
local PT3_mt = {}
local PT3 = setmetatable({},PT3_mt)

local sets, embedversions, cache, loaddata, iternum, iterpos

--Note: new modules must be added to this list!
--Note2: Misc is not LoD because it's members do not have a common parent set name.
local lodmodules = {
	Consumable = false,
	Gear = false,
	GearSet = false,
	InstanceLoot = false,
	InstanceLootHeroic = false,
	Reputation = false,
	Tradeskill = false,
	TradeskillResultMats = false,
}
-- set to false to prevent auto-enabling
local ATTEMPTENABLE = true
-- Scan all addons checking if they're a PT3 module.
for i = 1, GetNumAddOns() do
	local metadata = GetAddOnMetadata(i, "X-PeriodicTable-3.0-Module")
	if metadata then
		-- If this is indeed a PT3 module, make sure it's actually enabled; if it is, tag it as present and loadable.
		local name, _, _, enabled = GetAddOnInfo(i)
		if enabled then
			lodmodules[metadata] = "PRESENT"
		else
			if ATTEMPTENABLE then
				EnableAddOn(i)
				name, _, _, enabled = GetAddOnInfo(i)
				if enabled then
					lodmodules[metadata] = "PRESENT"
				end
			end
		end
	end
end
---------------------------------------------
--       Internal / Local Functions        --
---------------------------------------------
function PT3:getUpgradeData()
	-- This returns info for the purposes of library upgrades, but can also
	-- be used as a hax method of grabbing the sets table.
	return sets, embedversions
end
function getItemID(item)
	-- accepts either an item string ie "item:12345:0:0:0:2342:123324:12:1", hyperlink, or an itemid.
	-- returns a number'ified itemid.
	return tonumber(item) or tonumber(item:match("item:(%d+)")) or (-1 * (item:match("enchant:(%d+)") or 0))
end
function makeNonPresentMultiSet(parentname)
	-- makes an implied multiset, ie if you define only the set "a.b.c", 
	-- a request to "a.b" will come through here for a.b to be built.
	-- an expensive function because it needs to iterate all active sets,
	-- moreso for invalid sets. (which is why it now stores an empty string for
	-- invalid sets)
	local setstring = "m"
	-- Escape characters that will screw up the name matching.
	local escapedparentname = parentname:gsub("([%.%(%)%%%+%-%*%?%[%]%^%$])", "%%%1")
	-- Check all the sets to see if they start with this name.
	for k,v in pairs(sets) do
		if k:match("^"..escapedparentname.."%.") then
			-- If they do, jam 'em in the multiset.
			setstring = setstring..","..k
		end
	end
	-- Gross little hack to prevent repeat tries on nonexistant sets. It's tempting to just error out when
	-- a bad set is called!! that'll be done here..
	if setstring == "m" then
		setstring = ""
	end
	-- Store it.
	sets[parentname] = setstring
end
-- These two functions are for use with string.gsub.  The first simply returns the number, the second
-- takes a second argument that's simply an extra chunk of string we want to keep (a colon)
function fromb36(lead,str)
	return lead..tonumber(str,36)
end
function fromb36c(lead,str,tail)
	return lead..tonumber(str,36)..tail
end
function uncompress(setstring)
	-- Takes a compressed string,
	-- ie "iq6:o,nq3:k"
	-- and returns an uncompressed one,
	-- ie "24270:24,30747:20"
	if not setstring then
		return
	end
	if setstring:sub(1,2) == "m," or setstring:sub(1,2) == "u," then
		-- Do nothing to these, they come uncompressed.
		return setstring
	elseif setstring:sub(1,2) == "o," then
		-- Uncompress the itemid but NOT the value.
		return setstring:gsub("(%-?)(%w+)(:)",fromb36c)
	elseif setstring:sub(1,2) == "c[" then
		-- Chop it into pieces, uncompress those, reassemble, and return.
		local newsetstring = "c"
		for set in setstring:gmatch("(%b[])") do
			local childstring,rest = set:sub(2,-2):match("([^,]+,)(.+)$")
			newsetstring = newsetstring.."["..childstring..uncompress(rest).."]"
		end
		return newsetstring
	else
		-- Uncompress every damn thing.
		return setstring:gsub("(%-?)(%w+)",fromb36)
	end
end
function breakCType(set, setstring)
	-- Take a c[] set and split it into its child set strings.
	-- Replace the c[] set with a multiset.
	if not set then
		return
	end
	local newstring = "m,"
	for subsetstring in setstring:gmatch("(%b[])") do
		-- Drop the brackets, find the child name, store the rest in a set with that name.
		local childname, rest = subsetstring:sub(2,-2):match("([^,]+),(.+)$")
		childname = set.."."..childname
		sets[childname] = rest
		newstring = newstring..childname..","
	end
	sets[set] = newstring:sub(1, -2)
end
function isInCType(set)
	-- Check to see if this set is contained within some c[] set somewhere.
	local parent, child = set:match("^(.+)%.([^%.]+)$")
	if not parent then
		-- We're in a set with no periods, so this can't be contained anywhere.
		return
	end
	-- Use rawget to avoid invoking the metamethod to generate a multiset.
	-- Since we're traversing each set of this set's possible parents eventually
	-- through recursive calls, there's no reason to let it generate all those multisets.
	local parentset = rawget(sets,parent)
	if parentset and parentset:len() > 0 then
		-- Since we found a set at this parent point, let's escape matchy characters now in the child name
		child = child:gsub("([%.%(%)%%%+%-%*%?%[%]%^%$])", "%%%1")
		if parentset:sub(1,2) == "c[" and parentset:match("%["..child..",") then
			-- Not only did we find a c[] set, we found one with this set contained it in.  hawt.
			return parent
		end
	else
		return isInCType(parent)
	end
end
function shredCTypeCache(setname, setdata)
	-- This is a specialized function that's only gonna see use when a compressed set is upgraded with a new version.
	for subset in setdata:gmatch("(%b[])") do
		local childname, rest = subset:sub(2):match("([^,]+),(.+)$")
		if rest:sub(1,2) == "c[" then
			-- Ohnoes, nested sets.  Kill these too!!
			shredCTypeCache(setname.."."..childname, rest)
		end
		cache[setname.."."..childname] = nil
	end
end
function shredCache(setname)
	-- If there's a cache for this set, delete it, since we just added a new copy.
	if rawget(cache, setname) then
		cache[setname] = nil
	end
	local parentname = setname:match("^(.+)%.[^%.]+$")
	if parentname then
		-- Recurse and do the same for the parent set if we find one.
		shredCache(parentname)
	end
end
function setiter(t)
	local k,v
	if iterpos then
		-- We already have a position that we're at in the iteration, grab the next value up.
		k,v = next(t,iterpos)
	else
		-- We havent yet touched this set, grab the first value.
		k,v = next(t)
	end
	if k == "set" then
		k,v = next(t, k)
	end
	if k then
		iterpos = k
		return k,v,t.set
	end
end
function multisetiter(t)
	local k,v
	if iterpos then
		-- We already have a position that we're at in the iteration, grab the next value up.
		k,v = next(t[iternum],iterpos)
	else
		-- We havent yet touched this set, grab the first value.
		k,v = next(t[iternum])
	end
	if k == "set" then
		k,v = next(t[iternum], k)
	end
	if k then
		-- There's an entry here, no need to move on to the next table yet.
		iterpos = k
		return k,v,t[iternum].set
	else
		-- No entry, time to check for a new table.
		iternum = iternum + 1
		if not t[iternum] then
			return
		end
		k,v = next(t[iternum])
		if k == "set" then
			k,v = next(t[iternum],k)
		end
		iterpos = k
		return k,v,t[iternum].set
	end
end
cache = setmetatable({}, {
	__mode = 'v', -- weaken this table's values.
	__index = function(self, key)
		-- Get the setstring in question.  This call does most of the hairy stuff
		-- like putting together implied but absent multisets and finding child sets
		local setstring = uncompress(sets[key])
		if setstring == "" then
			return
		end
		-- Grab the first two characters so we don't need to call :sub 5 times
		local firsttwo = setstring:sub(1,2)
		if firsttwo == "m," then
			-- This table is a list of references to the members of this set.
			self[key] = {}
			local working = self[key]
			for childset in setstring:sub(3):gmatch("([^,]+)") do
				if childset ~= key then
					local pointer = cache[childset]
					if pointer then
						local _, firstv = next(pointer)
						if type(firstv) == "table" then
							-- This is a multiset, copy its references
							for _,v in ipairs(pointer) do
								working[#working+1] = v
							end
						elseif firstv then
							-- This is not a multiset, just stick a reference in.
							working[#working+1] = pointer
						end
					end
				end
			end
			return working
		elseif firsttwo == "c[" then
			-- We're lookin' at one o' them funky compressed sets. Break it into its children 
			-- (this replaces the setstring with that of a multiset) then run the metamethod again.
			breakCType(key, sets[key])
			return self[key]
		elseif firsttwo == "o," or firsttwo == "u," then
			-- This is an oddball -or- uncompressed set.  But at this level, everyone's already been
			-- uncompressed, so let's just tweak the string so that it'll work on the catch-all normal set
			-- code below.
			setstring = setstring:sub(3)
		end
		self[key] = {}
		local working = self[key]
		for itemstring in setstring:gmatch("([^,]+)") do
			-- for each item (comma seperated)..
			-- ...check to see if we have a value set (ie "14543:1121")
			local id, value = itemstring:match("^([^:]+):(.+)$")
			-- if we don't, (ie "14421,12312"), then set the value to true.
			id, value = tonumber(id) or tonumber(itemstring), value or true
			if not id then
				error('malformed set? '..key)
			end
			working[id] = value
		end
		-- stick the set name in there so that we can find out which set an item originally came from.
		working.set = key
		return working
	end
})
---------------------------------------------
--                  API                    --
---------------------------------------------
-- These three are pretty simple.  Note that non-present chunks will be generated by the metamethods.
function PT3:GetSetTable(set)
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	end
	return cache[set]
end
function PT3:GetSetStringCompressed(set)
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	end
	return sets[set]
end
function PT3:GetSetStringUncompressed(set)
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	end
	return uncompress(sets[set])
end
function PT3:IsSetMulti(set)
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	end
	-- Check if this set's a multiset by checking if its table contains tables instead of strings/booleans
	local pointer = cache[set]
	if not pointer then
		return
	end
	local _, firstv = next(pointer)
	if type(firstv) == "table" then
		return true
	else
		return false
	end
end
function PT3:IterateSet(set)
	local t = cache[set]
	if not t then
		self:error("Invalid set: "..set)
	end
	if self:IsSetMulti(set) then
		iternum, iterpos = 1, nil
		return multisetiter, t
	else
		iterpos = nil
		return setiter, t
	end
end
-- Check if the item's contained in this set or any of it's child sets.  If it is, return the value
-- (which is true for items with no value set) and the set where the item is contained in data.
function PT3:ItemInSet(item, set)
	if type(item) ~= "number" and type(item) ~= "string" then
		self:error("Invalid arg1: item must be a number or item link")
	elseif type(set) ~= "string" then
		self:error("Invalid arg2: set must be a string")
	end
	-- Type the passed item out to an itemid.
	item = getItemID(item)
	if item == 0 then
		self:error("Invalid arg1: invalid item.")
	end
	local pointer = cache[set]
	if not pointer then
		return
	end
	local _, firstv = next(pointer)
	if type(firstv) == "table" then
		-- The requested set is a multiset, iterate its children.  Return the first matching item.
		for _,v in ipairs(pointer) do
			if v[item] then
				return v[item], v.set
			end
		end
	elseif pointer[item] then
		-- Not a multiset, just return the value and set name.
		return pointer[item], pointer.set
	end
end
function PT3:AddData(arg1, arg2, arg3)
	if type(arg1) ~= "string" then
		self:error("Invalid arg1: name must be a string")
	elseif type(arg2) ~= "string" and type(arg2) ~= "table" then
		self:error("Invalid arg2: must be set contents string or table, or revision string")
	elseif arg3 and type(arg3) ~= "table" then
		self:error("Invalid arg3: must be a table")
	end
	if not arg3 and type(arg2) == "string" then
		-- Just a string.
		local replacing
		if rawget(sets, arg1) then
			replacing = true
		end
		sets[arg1] = arg2
		-- Clear the cache of this set's data if it exists, avoiding invoking the metamethod.
		-- No sense generating data if we're just gonna nuke it anyway ;)
		if replacing then
			shredCache(arg1)
			if arg2:sub(1,2) == "c[" then
				-- We've got a new copy of a compressed set, what a pain in the ass.
				-- This situation calls for another recursive function!
				shredCTypeCache(arg1, arg2)
			end
		end
	else
		-- Table of sets passed.
		if arg3 then
			-- Woot, version numbers and everything.
			if type(arg2) ~= "string" then
				self:error("Invalid arg2: must be revision string")
			end
			local version = tonumber(arg2:match("(%d+)"))
			if embedversions[arg1] and embedversions[arg1] >= version then
				-- The loaded version is newer than this one.
				return
			end
			embedversions[arg1] = version
			for k,v in pairs(arg3) do
				-- Looks good, throw 'em in there one by one
				self:AddData(k,v)
			end
		else
			-- Boo, no version numbers.  Just overwrite all these sets.
			for k,v in pairs(arg2) do
				self:AddData(k,v)
			end
		end
	end
end
function PT3:ItemSearch(item)
	-- Ew, expensive..  fun though.
	if type(item) ~= "number" and type(item) ~= "string" then
		self:error("Invalid arg1: item must be a number or item link")
	end
	if not embedversions.AllData then
		for k,v in pairs(lodmodules) do
			if v == "PRESENT" then
				LoadAddOn("PeriodicTable-3.0-"..k)
			end
		end
	end
	item = getItemID(item)
	if item == 0 then
		self:error("Invalid arg1: invalid item.")
	end
	local matches = {}
	for k,v in pairs(sets) do
		local _, set = self:ItemInSet(item, k)
		if set then
			local have
			for _,v in ipairs(matches) do
				if v == set then
					have = true
				end
			end
			if not have then
				table.insert(matches, set)
			end
		end
	end
	if #matches > 0 then
		return matches
	end
end
function PT3:GetNumSets()
	local num = 0
	for k,v in pairs(sets) do
		num = num + 1
	end
	return num
end
function PT3:GetNumCachedSets()
	local num = 0
	for k,v in pairs(cache) do
		num = num + 1
	end
	return num
end
function PT3:GetBetter(set, itema, itemb)
	-- Pretty simple.  Grab the values of both items.  If both are numbers, return whichever item is higher.
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	elseif type(itema) ~= "number" and type(itema) ~= "string" then
		self:error("Invalid arg2: item must be a number or item link")
	elseif type(itemb) ~= "number" and type(itemb) ~= "string" then
		self:error("Invalid arg3: item must be a number or item link")
	end
	local vala = self:ItemInSet(itema, set)
	local valb = self:ItemInSet(itemb, set)
	if tonumber(vala) and tonumber(valb) then
		if tonumber(vala) > tonumber(valb) then
			return itema, tonumber(vala)
		else
			return itemb, tonumber(valb)
		end
	end
end
function PT3:GetBest(set)
	if type(set) ~= "string" then
		self:error("Invalid arg1: set must be a string")
	end
	local highestitem
	local highestvalue = 0
	local pointer = cache[set]
	if not pointer then
		return
	end
	local _, firstv = next(pointer)
	if type(firstv) == "table" then
		-- Multiset.  Step through its tables, keep the highest integer value.
		for _, t in ipairs(pointer) do
			for k,v in pairs(t) do
				if tonumber(v) and tonumber(v) > highestvalue then
					highestvalue = tonumber(v)
					highestitem = tonumber(k)
				end
			end
		end
	else
		-- Normal ole set, just find the biggest number.
		for k,v in pairs(pointer) do
			if tonumber(v) and tonumber(v) > highestvalue then
				highestvalue = tonumber(v)
				highestitem = tonumber(k)
			end
		end
	end
	if highestitem then
		return highestitem, highestvalue
	end
end
PT3_mt.__call = PT3.GetSetTable
function activate(self, oldLib, oldDeactivate)
	local setsmeta = {
		__index = function(self, key)
			local base = key:match("^([^%.]+)%.") or key
			if lodmodules[base] == "PRESENT" and not embedversions.AllData then
				lodmodules[base] = "LOADED"
				LoadAddOn("PeriodicTable-3.0-"..base)
				-- still may need to generate multiset or something like that, so re-call the metamethod if need be
				return self[key]
			end
			local parent = isInCType(key)
			if parent then
				breakCType(parent)
			else
				makeNonPresentMultiSet(key)
			end
			return self[key]
		end
	}
	if oldLib then
		sets, embedversions = oldLib:getUpgradeData()
		--reassign this metatable in case the code of the metamethod needs upgraded.
		sets = setmetatable(sets, setsmeta)
	else
		sets = setmetatable({}, setsmeta)
		embedversions = {}
	end
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end
AceLibrary:Register(PT3, MAJOR_VERSION, MINOR_VERSION, activate)
PT3=nil
