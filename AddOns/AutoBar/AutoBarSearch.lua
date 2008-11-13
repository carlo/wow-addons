--[[
Name: AutoBarSearch
Author: Toadkiller of Proudmoore
Website: http://www.wowace.com/
]]
-- Copyright 2007+ Toadkiller of Proudmoore.
-- http://code.google.com/p/autobar/


local AceOO = AceLibrary("AceOO-2.0")
local BS = AceLibrary:GetInstance("Babble-Spell-2.2");
local BZ = AceLibrary:GetInstance("Babble-Zone-2.2")

AutoBarSearch = {}
AutoBarSearch.spells = {}

AutoBarSearch.dirtyBags = {}
local searchSpace, items, playerLevel

AutoBarSearch.zoneGroup = {}
AutoBarSearch.zoneGroup[BZ["Serpentshrine Cavern"]] = "Blades Edge"
AutoBarSearch.zoneGroup[BZ["Serpentshrine Cavern"]] = "Coilfang"
AutoBarSearch.zoneGroup[BZ["The Slave Pens"]] = "Coilfang"
AutoBarSearch.zoneGroup[BZ["The Steamvault"]] = "Coilfang"
AutoBarSearch.zoneGroup[BZ["The Underbog"]] = "Coilfang"
AutoBarSearch.zoneGroup[BZ["The Arcatraz"]] = "Tempest Keep"
AutoBarSearch.zoneGroup[BZ["The Botanica"]] = "Tempest Keep"
AutoBarSearch.zoneGroup[BZ["The Eye"]] = "Tempest Keep"
AutoBarSearch.zoneGroup[BZ["The Mechanar"]] = "Tempest Keep"

-- Recycle lists will avoid garbage collection and memory thrashing but potentially grow over time
-- A simple 2 list aproach that recycles objects specific to that type of list so the bulk of operations should be only initing recycled objects.
-- We shall see if this is a good thing
local Recycle = AceOO.Class()
Recycle.virtual = true -- this means that it cannot be instantiated. (cannot call :new())
Recycle.prototype.recycleList = 0
Recycle.prototype.dataList = 0

function Recycle.prototype:init()
	Recycle.super.prototype.init(self) -- very important. Will fail without this.
	self.recycleList = {}
	self.dataList = {}
end

-- Returns a new or recycled list object
function Recycle.prototype:Create()
	if (self.recycleList[1]) then
		local i = # self.recycleList
		local x = self.recycleList[i]
		self.recycleList[i] = nil
		return x
	else
		return {}
	end
end

-- Adds some trash to the recycle list
-- do delete trash from the original list.
function Recycle.prototype:Recycle()
	table.insert(self.recycleList, trash)
end



-- The search space with all items to look for
-- Tracks client buttons that are looking (for proper deletion)
--		{ itemId = {buttonsIndex, ...} }
local SearchSpace = AceOO.Class(Recycle)

-- Add a list of itemIds for the given buttonsIndex
function SearchSpace.prototype:Add(itemId, buttonsIndex)
	local clientButtons = self.dataList[itemId]
	if (not clientButtons) then
		clientButtons = self:Create()
		self.dataList[itemId] = clientButtons
	end
	clientButtons[buttonsIndex] = true
end

-- Remove a list of itemIds for the given buttonsIndex
function SearchSpace.prototype:Delete(itemId, buttonsIndex)
	local clientButtons = self.dataList[itemId]
	if (clientButtons) then
		clientButtons[buttonsIndex] = nil
	end
	if (# clientButtons == 0) then
		self:Recycle(clientButtons)
		self.dataList[itemId] = nil
	end
end

-- Remove and Recycle all items
function SearchSpace.prototype:Reset()
	for itemId, clientButtons in pairs(self.dataList) do
		for i, buttonsIndex in ipairs(clientButtons) do
			clientButtons[buttonsIndex] = nil
		end
		self:Recycle(clientButtons)
		self.dataList[itemId] = nil
	end
end

-- Testing & Debug function only
function SearchSpace.prototype:Contains(id)
	for itemId, clientButtons in pairs(self.dataList) do
		if (itemId == id) then
			if (not AutoBarSearch.trace) then
				DEFAULT_CHAT_FRAME:AddMessage("SearchSpace.prototype:Contains    itemId " .. tostring(itemId))
			end
			return true
		end
	end
	return false
end

-- Return the search space list.
-- Do not manipulate the list.  It is only for performance when checking if an itemId is searched for
function SearchSpace.prototype:GetList()
	return self.dataList
end



-- List of items to search for per slot.  No duplicates, highest priority overwrites.
-- Synced to SearchSpace.  All SearchSpace changes are via Items
-- Should only be changed via Config, or hunter pet food swithes
-- Priority is slotIndex.categoryIndex
--		{ itemId = {category, slotIndex, categoryIndex} }
local Items = AceOO.Class(Recycle)

function Items.prototype:init()
	Items.super.prototype.init(self)
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		self.dataList[buttonsIndex] = {}
	end
end

-- Add a list of itemIds for the given buttonsIndex
function Items.prototype:Add(itemList, buttonsIndex, category, slotIndex)
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Add    category " .. tostring(category) .. " itemList " .. tostring(itemList))
	for i, itemId in pairs(itemList) do
		local buttonItems = self.dataList[buttonsIndex]
		local itemData = buttonItems[itemId]
		if (not itemData) then
			itemData = self:Create()
			buttonItems[itemId] = itemData
			itemData.category = category
			itemData.slotIndex = slotIndex
			itemData.categoryIndex = i
			AutoBarSearch.space:Add(itemId, buttonsIndex)
		elseif (slotIndex > itemData.slotIndex or (slotIndex == itemData.slotIndex and i >= itemData.categoryIndex)) then
			itemData.category = category
			itemData.slotIndex = slotIndex
			itemData.categoryIndex = i
		end
	end
end

-- Remove a list of itemIds for the given buttonsIndex
-- ToDo: on deletion reapply lower priority ones / track them from the start?
function Items.prototype:Delete(itemList, buttonsIndex, category, slotIndex)
	for i, itemId in pairs(itemList) do
		local buttonItems = self.dataList[buttonsIndex]
		local itemData = buttonItems[itemId]
		if (itemData and slotIndex == itemData.slotIndex) then
			buttonItems[itemId] = nil
			self:Recycle(itemData)
			AutoBarSearch.space:Delete(itemId, buttonsIndex)
		end
	end
end

-- Rearrange item slot and categoryIndex if given.
function Items.prototype:Rearrange(buttonsIndex, slotIndexA, slotIndexB, category, categoryIndexA, categoryIndexB)
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Rearrange    buttonsIndex " .. tostring(buttonsIndex) .. " slotIndexA " .. tostring(slotIndexA) .. " slotIndexB " .. tostring(slotIndexB) .. " category " .. tostring(category) .. " categoryIndexA " .. tostring(categoryIndexA) .. " categoryIndexB " .. tostring(categoryIndexB))
	local buttonItems = self.dataList[buttonsIndex]
	for itemId, itemData in pairs(buttonItems) do
		-- Swap all in the affected slotIndexes
		if (itemData.slotIndex == slotIndexA) then
			itemData.slotIndex = slotIndexB
		elseif (itemData.slotIndex == slotIndexB) then
			itemData.slotIndex = slotIndexA
		end

		-- Also adjust categoryIndex if necessary
		if (itemData.category == category) then
			if (itemData.categoryIndex == categoryIndexA) then
				itemData.categoryIndex = categoryIndexB
			elseif (itemData.categoryIndex == categoryIndexB) then
				itemData.categoryIndex = categoryIndexA
			end
		end
	end
	AutoBarSearch.sorted:Rearrange(buttonsIndex, slotIndexA, slotIndexB, category, categoryIndexA, categoryIndexB)
end

-- Remove and Recycle all items
function Items.prototype:Reset()
	for buttonsIndex, buttonItems in ipairs(self.dataList) do
		for itemId, itemData in pairs(buttonItems) do
			buttonItems[itemId] = nil
		end
		self:Recycle(itemData)
	end
end

-- Testing & Debug function only
function Items.prototype:Contains(id)
	for buttonsIndex, buttonItems in ipairs(self.dataList) do
		for itemId, itemData in pairs(buttonItems) do
			if (itemId == id) then
				if (not AutoBarSearch.trace) then
					DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Contains    itemId " .. tostring(itemId))
				end
				return true
			end
		end
	end
	return false
end

local tempList = {}
-- Populate the given button, or all if none specified
function Items.prototype:Populate(buttonsIndex)
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Populate    buttonsIndex " .. tostring(buttonsIndex))
	local function GetItems(slotItem)
		if (type(slotItem) == "string") then
			local categoryInfo = AutoBarCategoryList[slotItem]
			if (categoryInfo) then
				if (categoryInfo.spell) then
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Populate   slotItem " .. tostring(slotItem))
--DevTools_Dump(AutoBarCategoryList["PORTALS"])
					return slotItem, categoryInfo.items, nil
				elseif (categoryInfo.spells) then
					return slotItem, categoryInfo.items, categoryInfo.spells
				else
					return slotItem, categoryInfo.items, nil
				end
			else
				return nil, nil, nil;
			end
		elseif (type(slotItem) == "number") then
			tempList[1] = slotItem
			return nil, tempList, nil;
		elseif (type(slotItem) == "table") then
			return nil, slotItem, nil;
		else
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Populate    GetItems unknown type " .. tostring(type(slotItem)))
		end
	end

	local startIndex = 1
	local endIndex = AUTOBAR_MAXBUTTONS
	if (buttonsIndex) then
		startIndex = buttonsIndex
		endIndex = buttonsIndex
	end
	local category, itemList
	for buttonsIndex = startIndex, endIndex, 1 do
		local buttonInfo = AutoBar.buttons[buttonsIndex]
		if (buttonInfo and buttonInfo[1]) then
			for slotIndex = 1, # buttonInfo, 1 do
				category, itemList, spells = GetItems(buttonInfo[slotIndex])
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Populate    itemList " .. tostring(itemList) .. " buttonsIndex " .. tostring(buttonsIndex) .. " category " .. tostring(category))
				if (itemList) then
					self:Add(itemList, buttonsIndex, category, slotIndex)
				end
				if (spells) then
--DEFAULT_CHAT_FRAME:AddMessage("Items.prototype:Populate Add   spells " .. tostring(spells) .. " buttonsIndex " .. tostring(buttonsIndex) .. " category " .. tostring(category))
					self:Add(spells, buttonsIndex, category, slotIndex)
				end
			end
		end
	end
end

-- Return the buttons search list.
-- Do not manipulate the list.  It is only for performance when checking if an itemId is searched for
function Items.prototype:GetList(buttonsIndex)
	if (buttonsIndex) then
		return self.dataList[buttonsIndex]
	else
		return self.dataList
	end
end


-- Map of bag, inventory and spell contents
-- Changes synced to Found
-- [bag][slot] = <itemId | nil>
local Stuff = AceOO.Class()

function Stuff.prototype:init()
	Stuff.super.prototype.init(self)
	self.dataList = {}
	for bag = 0, 4, 1 do
		self.dataList[bag] = {}
	end
	self.dataList.inventory = {}
	self.dataList.spells = {}
end

-- Add itemId to bag, slot, spell
function Stuff.prototype:Add(itemId, bag, slot, spell)
	local slotList
	if (bag) then
		slotList = self.dataList[bag]
		slotList[slot] = itemId
	elseif (slot) then
		slotList = self.dataList.inventory
		slotList[slot] = itemId
	else
		slotList = self.dataList.spells
		slotList[spell] = itemId
	end

	if (bag or slot) then
		-- Filter out too high level items
		_, _, _, _, itemMinLevel = GetItemInfo(itemId);
		if (itemMinLevel <= playerLevel) then
			AutoBarSearch.found:Add(itemId, bag, slot)
		end
	else
		AutoBarSearch.found:Add(itemId, bag, slot, spell)
	end
--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Add bag " .. tostring(bag) .. " slot " .. tostring(slot))
end

-- Remove itemId from bag, slot, spell
function Stuff.prototype:Delete(itemId, bag, slot, spell)
	local slotList
	if (bag) then
		slotList = self.dataList[bag]
		slotList[slot] = nil
	elseif (slot) then
		slotList = self.dataList.inventory
		slotList[slot] = nil
	else
		slotList = self.dataList.spells
		slotList[spell] = nil
	end

	AutoBarSearch.found:Delete(itemId, bag, slot, spell)
--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Delete bag " .. tostring(bag) .. " slot " .. tostring(slot))
end

-- Scan the given bag.
function Stuff.prototype:ScanBag(bag)
	local slotList = self.dataList[bag]
	local name, itemId, oldItemId
	local nSlots = GetContainerNumSlots(bag)

--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Scan bag " .. tostring(bag) .. " nSlots " .. tostring(nSlots) .. " slotList " .. tostring(slotList))

	-- ToDo: Clear out excess slots if bag got smaller

	for slot = 1, nSlots, 1 do
		name, itemId = AutoBar.LinkDecode(GetContainerItemLink(bag, slot))
		oldItemId = slotList[slot]

--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Scan name " .. tostring(name) .. " itemId " .. tostring(itemId) .. " oldItemId " .. tostring(oldItemId))
		if (itemId) then
			if (oldItemId and oldItemId ~= itemId) then
				self:Delete(oldItemId, bag, slot)
				self:Add(itemId, bag, slot)
			elseif (not oldItemId) then
				self:Add(itemId, bag, slot, nil)
			end
		elseif (not itemId and oldItemId) then
			self:Delete(oldItemId, bag, slot, nil)
		end
	end
end

-- Scan equipped inventory items.
function Stuff.prototype:ScanInventory()
	local slotList = self.dataList.inventory
	local name, itemId, oldItemId

	-- Scan equipped items
	for slot = 0, 19 do
		name, itemId = AutoBar.LinkDecode(GetInventoryItemLink("player", slot));
		oldItemId = slotList[slot]

		if (itemId) then
			if (oldItemId and oldItemId ~= itemId) then
				self:Delete(oldItemId, nil, slot, nil)
				self:Add(itemId, nil, slot, nil)
			elseif (not oldItemId) then
				self:Add(itemId, nil, slot, nil)
			end
		elseif (not itemId and oldItemId) then
			self:Delete(oldItemId, nil, slot, nil)
		end
	end
end

-- Scan spells.
function Stuff.prototype:ScanSpells()
	-- Scan available spells
	for spellName, spellInfo in pairs(AutoBarSearch.spells) do
--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:ScanSpells    spellName " .. tostring(spellName));
		spellInfo.canCast = AutoBarSearch:CanCastSpell(spellName)

		AutoBarSearch:RegisterSpell(spellName)
		if (spellInfo.canCast) then
			self:Add(spellName, nil, nil, spellName)
		else
			self:Delete(spellName, nil, nil, spellName)
		end
	end
end

-- Scan the requested Stuff.
function Stuff.prototype:Scan()
	playerLevel = UnitLevel("player")
	local bag
	AutoBar:LogEventStart("Stuff.prototype:Scan")
	for bag = 0, 4, 1 do
		if (AutoBarSearch.dirtyBags[bag]) then
			AutoBar:LogEventStart("AutoBar scanned bag")
			self:ScanBag(bag)
			AutoBar:LogEventEnd("AutoBar scanned bag", bag)
			AutoBarSearch.dirtyBags[bag] = false
		end
	end
	if (AutoBarSearch.dirtyBags.inventory) then
--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Scan    scanning inventory ");
		self:ScanInventory()
		AutoBarSearch.dirtyBags.inventory = false
	end
	if (AutoBarSearch.dirtyBags.spells) then
--DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Scan    scanning spells ");
		self:ScanSpells()
		AutoBarSearch.dirtyBags.spells = false
	end
	AutoBar:LogEventEnd("Stuff.prototype:Scan")
end

-- Remove and Recycle all items
function Stuff.prototype:Reset()
	local slotList
	for bag = 0, 4, 1 do
		slotList = self.dataList[bag]
		for i, itemId in pairs(slotList) do
			slotList[i] = nil
		end
	end
	slotList = self.dataList.inventory
	for i, itemId in pairs(slotList) do
		slotList[i] = nil
	end
end

-- Testing & Debug function only
function Stuff.prototype:Contains(id)
	local slotList
	local contains = false
	for bag = 0, 4, 1 do
		slotList = self.dataList[bag]
		for i, itemId in pairs(slotList) do
			if (itemId == id) then
				contains = true
				if (not AutoBarSearch.trace) then
					DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Contains    itemId " .. tostring(itemId).." at bag/slot " .. tostring(bag).." / " .. tostring(i))
				end
			end
		end
	end
	slotList = self.dataList.inventory
	for i, itemId in pairs(slotList) do
		if (itemId == id) then
			contains = true
			if (not AutoBarSearch.trace) then
				DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Contains inventory    itemId " .. tostring(itemId))
			end
		end
	end
	slotList = self.dataList.spells
	for i, itemId in pairs(slotList) do
		if (itemId == id) then
			contains = true
			if (not AutoBarSearch.trace) then
				DEFAULT_CHAT_FRAME:AddMessage("Stuff.prototype:Contains spells    itemId " .. tostring(itemId))
			end
		end
	end
	return contains
end


-- Return the Stuff list.
-- Do not manipulate the list.  It is only for performance.
function Stuff.prototype:GetList()
	return self.dataList
end


-- Syncs to Stuff and Current
-- itemId = { [bag, slot, spell], ... }
local Found = AceOO.Class(Recycle)

function Found.prototype:init()
	Found.super.prototype.init(self)
	self.dataList = {}
end

-- Add itemId to bag, slot
function Found.prototype:Add(itemId, bag, slot, spell)
	local itemData = self.dataList[itemId]
	if (not itemData) then
		itemData = self:Create()
		self.dataList[itemId] = itemData
		itemData[1] = bag
		itemData[2] = slot
		itemData[3] = spell

		-- First time Item found so add it everywhere
		if (searchSpace[itemId]) then
			AutoBarSearch.current:Merge(itemId)
		end

		-- Remove possible old entries left over from a Reset
		for i = # itemData, 4, -1 do
			itemData[i] = nil
		end
	else
		-- Item previously found so just record additional location
		local bFound = false
		local nItems = # itemData
		local i = 1
		while (i <= nItems) do
			if (itemData[i] == bag and itemData[i + 1] == slot and itemData[i + 2] == spell) then
				bFound = true
				break
			end
			i = i + 3
		end
		if (not bFound) then
			itemData[i] = bag
			itemData[i + 1] = slot
			itemData[i + 2] = spell
--DEFAULT_CHAT_FRAME:AddMessage("Found.prototype:Add    itemId " .. tostring(itemId) .. " i " .. tostring(i) .. " bag " .. tostring(itemData[i]) .. " slot " .. tostring(itemData[i + 1]) .. " spell " .. tostring(itemData[i + 2]))
		end
	end
end

-- Remove bag, slot, spell for the itemId
function Found.prototype:Delete(itemId, bag, slot, spell)
	local itemData = self.dataList[itemId]
	if (itemData) then
		local nItems = # itemData
--DEFAULT_CHAT_FRAME:AddMessage("Found.prototype:Delete    itemId " .. tostring(itemId) .. " bag " .. tostring(bag) .. " slot " .. tostring(slot) .. " nItems " .. tostring(nItems))
		local i = 1
		while (i <= nItems) do
			if (itemData[i] == bag and itemData[i + 1] == slot and itemData[i + 2] == spell) then
				local lastIndex = math.modf((nItems - 1) / 3) * 3 + 1
--DEFAULT_CHAT_FRAME:AddMessage("Found.prototype:Delete    itemData[i] " .. tostring(itemData[i]) .. " itemData[i + 1] " .. tostring(itemData[i + 1]) .. " itemData[i + 2] " .. tostring(itemData[i + 2]) .. " i " .. tostring(i) .. " lastIndex " .. tostring(lastIndex))
				if (lastIndex > i) then
					itemData[i] = itemData[lastIndex]
					itemData[i + 1] = itemData[lastIndex + 1]
					itemData[i + 2] = itemData[lastIndex + 2]
				end
				itemData[lastIndex + 2] = nil
				itemData[lastIndex + 1] = nil
				itemData[lastIndex] = nil
				break
			end
			i = i + 3
		end

		-- Item is now totally gone so remove it everywhere
		if (not (itemData[1] or itemData[2] or itemData[3])) then
			self.dataList[itemId] = nil
			self:Recycle(itemData)

			if (searchSpace[itemId]) then
				AutoBarSearch.current:Purge(itemId)
			end
		end
	end
end

-- Remove and Recycle all items
function Found.prototype:Reset()
	for itemId, itemData in pairs(self.dataList) do
		self.dataList[itemId] = nil
		self:Recycle(itemData)
		-- Clearing out itemData handled in Add
	end
end

-- Testing & Debug function only
function Found.prototype:Contains(id, count)
	for itemId, itemData in pairs(self.dataList) do
		if (itemId == id) then
			if (not AutoBarSearch.trace) then
				DEFAULT_CHAT_FRAME:AddMessage("Found.prototype:Contains    itemId " .. tostring(itemId))
			end
			if (count) then
				local nItems = # itemData
				local found = 0
				local i = 1
				while (i <= nItems) do
					if (itemData[i] or itemData[i + 1] or itemData[i + 2]) then
						found = found + 1
					end
					i = i + 3
				end
				if (found == count) then
					return true
				else
					return false
				end
			end
			return true
		end
	end
	return false
end

-- Return the buttons found list.
-- Do not manipulate the list.  It is only for performance.
function Found.prototype:GetList()
	return self.dataList
end


-- list of found items for the button
-- bag, slot synced to Stuff
-- { itemId, ... }
local Current = AceOO.Class()

function Current.prototype:init()
	Current.super.prototype.init(self)
	self.dataList = {}
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		self.dataList[buttonsIndex] = {}
	end
end

-- Add the brand new item to any interrested buttons
function Current.prototype:Merge(itemId)
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		local searchItems = items[buttonsIndex]
		if (searchItems and searchItems[itemId]) then
			local itemData = searchItems[itemId]
			self:Add(buttonsIndex, itemId)
--DEFAULT_CHAT_FRAME:AddMessage("Current.prototype:Merge    itemId " .. tostring(itemId) .. " buttonsIndex " .. tostring(buttonsIndex))
			AutoBarSearch.sorted:Add(buttonsIndex, itemId, itemData.slotIndex, itemData.categoryIndex)
		end
	end
end

-- Purge the defunct item from its client buttons
function Current.prototype:Purge(itemId)
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		local searchItems = items[buttonsIndex]
		if (searchItems and searchItems[itemId]) then
			self:Delete(buttonsIndex, itemId)
--DEFAULT_CHAT_FRAME:AddMessage("Current.prototype:Purge    itemId " .. tostring(itemId) .. " buttonsIndex " .. tostring(buttonsIndex))
			AutoBarSearch.sorted:Delete(buttonsIndex, itemId)
		end
	end
end

-- Add the found item to the list of itemIds for the given buttonsIndex
function Current.prototype:Add(buttonsIndex, itemId)
	local buttonItems = self.dataList[buttonsIndex]
	buttonItems[itemId] = true
end

-- Remove the found item from the list of itemIds for the given buttonsIndex
-- ToDo: on deletion reapply lower priority ones / track them from the start?
function Current.prototype:Delete(buttonsIndex, itemId)
	local buttonItems = self.dataList[buttonsIndex]
	buttonItems[itemId] = nil
end

-- Remove and Recycle all items
function Current.prototype:Reset()
	for buttonsIndex, buttonItems in ipairs(self.dataList) do
		for itemId, itemData in pairs(buttonItems) do
			buttonItems[itemId] = nil
		end
	end
end

-- Testing & Debug function only
function Current.prototype:Contains(id)
	for buttonsIndex, buttonItems in ipairs(self.dataList) do
		for itemId, itemData in pairs(buttonItems) do
			if (itemId == id) then
				if (not AutoBarSearch.trace) then
					DEFAULT_CHAT_FRAME:AddMessage("Current.prototype:Contains    itemId " .. tostring(itemId).." at buttonsIndex " .. tostring(buttonsIndex))
				end
				return true
			end
		end
	end
	return false
end

-- Return the buttons found list.
-- Do not manipulate the list.  It is only for performance.
function Current.prototype:GetList(buttonsIndex)
	if (buttonsIndex) then
		return self.dataList[buttonsIndex]
	else
		return self.dataList
	end
end


-- Sorted version of Current items for each button
-- Syncs to Items and Current
-- Verify / add items
-- n = { itemId, slotIndex, categoryIndex}, ... }
local Sorted = AceOO.Class(Recycle)

function Sorted.prototype:init()
	Sorted.super.prototype.init(self)
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		self.dataList[buttonsIndex] = {}
	end
	self.promotedList = {}	-- Location current best usable item came from
	self.dirtyList = {}		-- Which lists need sorting
	self.dirty = false		-- True if some list needs sorting
end

-- Add the found item to the list of itemIds for the given buttonsIndex
function Sorted.prototype:Add(buttonsIndex, itemId, slotIndex, categoryIndex)
	local buttonItems = self.dataList[buttonsIndex]
	local bFound = false

if (not itemId) then
	DEFAULT_CHAT_FRAME:AddMessage("Sorted.prototype:Add   bad itemId  " .. tostring(itemId))
end

	for i, sortedItemData in ipairs(buttonItems) do
		if (sortedItemData.itemId == itemId) then
			bFound = true
			if (slotIndex > sortedItemData.slotIndex) then
				sortedItemData.slotIndex = slotIndex
				sortedItemData.categoryIndex = categoryIndex
				-- Do not need a subcheck for categoryIndex, as itemId should be unique per category
			end
			break
		end
	end
	if (not bFound) then
		local sortedItemData = self:Create()
		table.insert(buttonItems, sortedItemData)
		sortedItemData.itemId = itemId
		sortedItemData.slotIndex = slotIndex
		sortedItemData.categoryIndex = categoryIndex
	end
	self.dirtyList[buttonsIndex] = true
	self.dirty = true
end

-- Remove the found item from the list of itemIds for the given buttonsIndex
-- ToDo: on deletion reapply lower priority ones / track them from the start?
function Sorted.prototype:Delete(buttonsIndex, itemId)
	local buttonItems = self.dataList[buttonsIndex]

	for i, sortedItemData in ipairs(buttonItems) do
		if (sortedItemData.itemId == itemId) then
			table.remove(buttonItems, i)
			self:Recycle(sortedItemData)
			break
		end
	end
	self.dirtyList[buttonsIndex] = true
	self.dirty = true
end

-- Sorting is descending order as we want the highest slot / index to have precedence
local function SortBySlotCategory(a, b)
	if (a and b) then
		if (a.slotIndex == b.slotIndex and a.categoryIndex and b.categoryIndex) then
			return a.categoryIndex > b.categoryIndex;
		else
			return a.slotIndex > b.slotIndex;
		end
	else
		return true;
	end
end

-- Update any dirty lists.
-- If index is specified then sort it only and do not change dirty state
function Sorted.prototype:Update(index)
	local startIndex = 1
	local endIndex = AUTOBAR_MAXBUTTONS
	local oldDirty = false
	if (index) then
		startIndex = index
		endIndex = index
		oldDirty = self.dirty
		self.dirty = true
		self.dirtyList[index] = true
	end
	if (self.dirty) then
		for buttonsIndex = startIndex, endIndex, 1 do
			if (self.dirtyList[buttonsIndex]) then
				local sortList = self.dataList[buttonsIndex]
				if (sortList) then
					table.sort(sortList, SortBySlotCategory)
					self:SetBest(buttonsIndex)
				end
				self.dirtyList[buttonsIndex] = false
				AutoBarButton.dirtyButton[buttonsIndex] = true
			end
		end
		self.dirty = oldDirty
	end
end

-- Rearrange item slot and categoryIndex if given.
function Sorted.prototype:Rearrange(buttonsIndex, slotIndexA, slotIndexB, category, categoryIndexA, categoryIndexB)
--DEFAULT_CHAT_FRAME:AddMessage("Sorted.prototype:Rearrange    buttonsIndex " .. tostring(buttonsIndex) .. " slotIndexA " .. tostring(slotIndexA) .. " slotIndexB " .. tostring(slotIndexB) .. " category " .. tostring(category) .. " categoryIndexA " .. tostring(categoryIndexA) .. " categoryIndexB " .. tostring(categoryIndexB))
	local sortList = self.dataList[buttonsIndex]
	local buttonItems = items[buttonsIndex]
	local dirty = false
	for i, sortedItemData in ipairs(sortList) do
		-- Swap all in the affected slotIndexes
--DEFAULT_CHAT_FRAME:AddMessage("Sorted.prototype:Rearrange   pre  " .. tostring(i) .. " sortedItemData.itemId " .. tostring(sortedItemData.itemId) .. " sortedItemData.slotIndex " .. tostring(sortedItemData.slotIndex))
		if (sortedItemData.slotIndex == slotIndexA) then
			sortedItemData.slotIndex = slotIndexB
			dirty = true
		elseif (sortedItemData.slotIndex == slotIndexB) then
			sortedItemData.slotIndex = slotIndexA
			dirty = true
		end
--DEFAULT_CHAT_FRAME:AddMessage("Sorted.prototype:Rearrange   post " .. tostring(i) .. " sortedItemData.itemId " .. tostring(sortedItemData.itemId) .. " sortedItemData.slotIndex " .. tostring(sortedItemData.slotIndex))

		-- Also adjust categoryIndex if necessary
		if (categoryIndexA and categoryIndexB) then
			if (buttonItems[sortedItemData.itemId].category == category) then
				if (sortedItemData.categoryIndex == categoryIndexA) then
					sortedItemData.categoryIndex = categoryIndexB
					dirty = true
				elseif (sortedItemData.categoryIndex == categoryIndexB) then
					sortedItemData.categoryIndex = categoryIndexA
					dirty = true
				end
			end
		end
	end
	if (dirty) then
		self.dirty = true
		self.dirtyList[buttonsIndex] = true
	end
end

-- Remove and Recycle all items
function Sorted.prototype:Reset()
	self.dirty = true
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		local buttonItems = self.dataList[buttonsIndex]

		for i, sortedItemData in pairs(buttonItems) do
			buttonItems[i] = nil
			self:Recycle(sortedItemData)
		end
		self.dirtyList[buttonsIndex] = true
	end
	self.dirty = true
end

-- Testing & Debug function only
function Sorted.prototype:Contains(itemId)
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		local buttonItems = self.dataList[buttonsIndex]

		for i, sortedItemData in ipairs(buttonItems) do
			if (itemId == sortedItemData.itemId) then
				if (not AutoBarSearch.trace) then
					DEFAULT_CHAT_FRAME:AddMessage("Sorted.prototype:Contains    itemId " .. tostring(itemId).." at buttonsIndex " .. tostring(buttonsIndex))
				end
				return true
			end
		end
	end
	return false
end

-- Dirty a specific button
function Sorted.prototype:SetDirty(buttonsIndex)
	self.dirty = true
	self.dirtyList[buttonsIndex] = true
end

-- Return the buttons sorted list.
-- Do not manipulate the list.  It is only for performance.
function Sorted.prototype:GetList(buttonsIndex)
	if (buttonsIndex) then
		return self.dataList[buttonsIndex]
	else
		return self.dataList
	end
end

local function swap(list, a, b)
	if (a ~= b) then
		local temp = list[a]
		list[a] = list[b]
		list[b] = temp
	end
end

-- After sorting make sure first item is usable
function Sorted.prototype:SetBest(buttonsIndex)
	local sortedItems = AutoBarSearch.sorted:GetList(buttonsIndex)
--	local searchItems = items[buttonsIndex]
	local searchItems = AutoBarSearch.items:GetList()[buttonsIndex]

	assert(searchItems, "Sorted.prototype:SetBest items["..tostring(buttonsIndex).."] is nil")

	-- Restore correct sorting
	if (self.promotedList[buttonsIndex]) then
		swap(sortedItems, 1, self.promotedList[buttonsIndex])
		self.promotedList[buttonsIndex] = nil
	end

	local itemId, category, categoryInfo
	local found = false
	for sortedIndex, sortedItemData in ipairs(sortedItems) do
		local good = true
		itemId = sortedItemData.itemId
		category = searchItems[itemId].category
		categoryInfo = AutoBarCategoryList[category]
-- n = { itemId, slotIndex, categoryIndex}, ... }
		if (categoryInfo) then
			local zone = GetRealZoneText()
			if (categoryInfo.location and categoryInfo.location ~= zone) then
--DEFAULT_CHAT_FRAME:AddMessage("Sorted:SetBest in zone " .. tostring(zone) .. " categoryInfo.location " .. tostring(categoryInfo.location))
				local zoneGroup = AutoBarSearch.zoneGroup[zone]
--DEFAULT_CHAT_FRAME:AddMessage("Sorted:SetBest zoneGroup " .. tostring(zoneGroup))
				if (zoneGroup ~= categoryInfo.location) then
					good = false
				end
			end
			if (categoryInfo.battleground and not AutoBar.inBG) then
				good = false;
			else
				if (not fallback) then
					fallback = index;
				end
				if (categoryInfo.nonCombat and AutoBar.inCombat) then
					good = false;
--				elseif (categoryInfo.limit) then
--					local losthp = UnitHealthMax("player") - UnitHealth("player");
--					local lostmana = UnitManaMax("player") - UnitMana("player");
--					if (UnitPowerType("player") ~= 0 ) then
--						--if (UnitClass("player") == "Druid") then
--							-- Can't check mana in druid forms
--						--	lostmana = 0;
--						--else
--							-- Class doesn't have mana, don't limit
--							lostmana = 10000;
--						--end
--					end
--					if (categoryInfo.limit.downhp and categoryInfo.limit.downhp[categoryIndex] > losthp) then
--						good = false;
--					elseif (categoryInfo.limit.downmana and categoryInfo.limit.downmana[categoryIndex] > lostmana) then
--						good = false;
--					end
				end
			end
		end

		if (good) then
			-- Swap it to first spot if not already there
			if (sortedIndex ~= 1) then
				swap(sortedItems, 1, sortedIndex)
				self.promotedList[buttonsIndex] = sortedIndex
			end
			break
		end
	end
end


-- Returns true if a spell can be cast at all
-- Therefore returns true if IsUsableSpell returns true or only mana is lacking or it exists in the spellbook
function AutoBarSearch:CanCastSpell(spellName)
	usable, noMana = IsUsableSpell(spellName)
	if (not usable) then
		if (not noMana) then
			local spellInfo = AutoBarSearch.spells[spellName]
			if (not spellInfo or not spellInfo.canCast) then
				return false
			else
				return true
			end
		else
			return true;
		end
	end
	return true;
end


-- Register a spell, and figure out its spellbook index for use in tooltip
-- {spellName = {canCast, spellId, spellTab}}
function AutoBarSearch:RegisterSpell(spellName)
	local spellInfo = AutoBarSearch.spells[spellName]
	if (not spellInfo) then
		spellInfo = {}
		AutoBarSearch.spells[spellName] = spellInfo
	end

--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:RegisterSpell " .. tostring(spellName))
	local spell, spellRank

	local i = 1
	while true do
		spell, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spell then
			break
		elseif (spellName == spell) then
			spellInfo.spellId = i
			spellInfo.spellTab = BOOKTYPE_SPELL
		end
		i = i + 1
	end

	spellInfo.canCast = AutoBarSearch:CanCastSpell(spellName) or spellInfo.spellId
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:RegisterSpell spellInfo.spellId " .. tostring(spellInfo.spellId))
	return spellName
end


-- Spell specific inits
function AutoBarSearch:InitializeSpells()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:InitializeSpells")

	-- Scan categoryInfo.castList for usable spells
--	local castList, spellName, spellList;
--	for categoryName, categoryInfo in pairs(AutoBarCategoryList) do
--		castList = categoryInfo.castList;
--		if (castList) then
--			for index = 1, # castList, 2 do
--				if (AutoBar.CLASS == castList[index]) then
--					spellName = castList[index + 1]
--					AutoBarSearch.spells[spellName] = false
--					if (categoryInfo.spell) then
--						if (not categoryInfo.items) then
--							categoryInfo.items = {}
--						end
--						table.insert(categoryInfo.items, spellName)
--					else
--						if (not categoryInfo.spells) then
--							categoryInfo.spells = {}
--						end
--						table.insert(categoryInfo.spells, spellName)
----DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:InitializeSpells " .. tostring(spellName))
--						if (spellName and AutoBarSearch:CanCastSpell(spellName)) then	-- TODO: update on leveling in case new spell aquired
----DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:InitializeSpells castable " .. tostring(spellName))
--							categoryInfo.castSpell = spellName
--							self:RegisterSpell(spellName)
--						end
--					end
--				end
--			end
--		end
--	end

--	if (AutoBar.CLASS == "DRUID") then
--		self:RegisterSpell(BS["Swift Flight Form"])
--		self:RegisterSpell(BS["Flight Form"])
--		self:RegisterSpell(BS["Travel Form"])
--
--		spellList = {}
--		spellList[1] = self:RegisterSpell(BS["Teleport: Moonglade"])
--		AutoBarCategoryList["PORTALS"].items = spellList
--	elseif (AutoBar.CLASS == "MAGE") then
--		spellList = {}
--		self:RegisterSpell(BS["Conjure Food"])
--		AutoBarCategoryList["FOOD_CONJURE"].items = spellList
--
--		spellList = {}
--		self:RegisterSpell(BS["Conjure Water"])
--		AutoBarCategoryList["WATER_CONJURE"].items = spellList
--
--		spellList = {}
--		spellList[5] = self:RegisterSpell(BS["Conjure Mana Emerald"])
--		spellList[4] = self:RegisterSpell(BS["Conjure Mana Ruby"])
--		spellList[3] = self:RegisterSpell(BS["Conjure Mana Citrine"])
--		spellList[2] = self:RegisterSpell(BS["Conjure Mana Jade"])
--		spellList[1] = self:RegisterSpell(BS["Conjure Mana Agate"])
--		AutoBarCategoryList["MANASTONE_CONJURE"].items = spellList
--
--		spellList = {}
--		spellList[18] = self:RegisterSpell(BS["Portal: Shattrath"])
--		spellList[17] = self:RegisterSpell(BS["Portal: Orgrimmar"])
--		spellList[16] = self:RegisterSpell(BS["Portal: Ironforge"])
--		spellList[15] = self:RegisterSpell(BS["Portal: Darnassus"])
--		spellList[14] = self:RegisterSpell(BS["Portal: Exodar"])
--		spellList[13] = self:RegisterSpell(BS["Portal: Silvermoon"])
--		spellList[12] = self:RegisterSpell(BS["Portal: Stormwind"])
--		spellList[11] = self:RegisterSpell(BS["Portal: Thunder Bluff"])
--		spellList[10] = self:RegisterSpell(BS["Portal: Undercity"])
--		spellList[9] = self:RegisterSpell(BS["Teleport: Shattrath"])
--		spellList[8] = self:RegisterSpell(BS["Teleport: Orgrimmar"])
--		spellList[7] = self:RegisterSpell(BS["Teleport: Ironforge"])
--		spellList[6] = self:RegisterSpell(BS["Teleport: Darnassus"])
--		spellList[5] = self:RegisterSpell(BS["Teleport: Exodar"])
--		spellList[4] = self:RegisterSpell(BS["Teleport: Silvermoon"])
--		spellList[3] = self:RegisterSpell(BS["Teleport: Stormwind"])
--		spellList[2] = self:RegisterSpell(BS["Teleport: Thunder Bluff"])
--		spellList[1] = self:RegisterSpell(BS["Teleport: Undercity"])
--		AutoBarCategoryList["PORTALS"].items = spellList
--	elseif (AutoBar.CLASS == "PALADIN") then
--		self:RegisterSpell(BS["Summon Charger"])
--		self:RegisterSpell(BS["Summon Warhorse"])
--	elseif (AutoBar.CLASS == "SHAMAN") then
--		self:RegisterSpell(BS["Ghost Wolf"])
--
--		spellList = {}
--		spellList[1] = self:RegisterSpell(BS["Astral Recall"])
--		AutoBarCategoryList["PORTALS"].items = spellList
--	elseif (AutoBar.CLASS == "WARLOCK") then
--		self:RegisterSpell(BS["Summon Dreadsteed"])
--		self:RegisterSpell(BS["Summon Felsteed"])
--		self:RegisterSpell(BS["Create Healthstone"])
--
--		spellList = {}
--		spellList[1] = self:RegisterSpell(BS["Ritual of Summoning"])
--		AutoBarCategoryList["PORTALS"].items = spellList
--	end
end


-- Only call this once
function AutoBarSearch:Initialize()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:Initialize")
	AutoBarSearch.space = SearchSpace:new()		-- All items to search for
	AutoBarSearch.items = Items:new()			-- Items to search for for each button + category etc.

	AutoBarSearch.sorted = Sorted:new()			-- Sorted version of Current items

	AutoBarSearch.current = Current:new()		-- Current items found for each button (Found intersect Items)
	AutoBarSearch.found = Found:new()			-- All items found in Stuff + list of bag, slot found in

	AutoBarSearch.stuff = Stuff:new()			-- Map of bags, inventory and spells

	searchSpace = AutoBarSearch.space:GetList()
	items = AutoBarSearch.items:GetList()
end

-- Empty everything
function AutoBarSearch:Empty()
	AutoBarSearch.space:Reset()
	AutoBarSearch.items:Reset()
	AutoBarSearch.sorted:Reset()
	AutoBarSearch.current:Reset()
	AutoBarSearch.found:Reset()
	AutoBarSearch.stuff:Reset()
end

-- Completely reset everything and then rescan.
function AutoBarSearch:Reset()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:Reset Start")
	AutoBarSearch:Empty()

	-- Add Items
	AutoBarSearch.items:Populate()
	for i = 0, 4, 1 do
		AutoBarSearch.dirtyBags[i] = true
	end
	AutoBarSearch.dirtyBags.inventory = true
	AutoBarSearch.dirtyBags.spells = true
	AutoBarSearch.dirty = true
	AutoBarSearch.stuff:Scan()
	AutoBarSearch.sorted:Update()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:Reset End")
end



-- Testing & Debug function only
function AutoBarSearch:Contains(itemId)
	if (not AutoBarSearch.trace) then
		DEFAULT_CHAT_FRAME:AddMessage("\n\n   AutoBarSearch:Contains: " .. tostring(itemId))
	end
	local contains = false

	contains = contains or AutoBarSearch.space:Contains(itemId)
	contains = contains or AutoBarSearch.items:Contains(itemId)
	contains = contains or AutoBarSearch.sorted:Contains(itemId)
	contains = contains or AutoBarSearch.current:Contains(itemId)
	contains = contains or AutoBarSearch.found:Contains(itemId)
	contains = contains or AutoBarSearch.stuff:Contains(itemId)

	return contains
end


-- Testing & Debug function only
function AutoBarSearch:DumpSlot(buttonsIndex)
	DEFAULT_CHAT_FRAME:AddMessage("\n\n   AutoBarSearch:DumpSlot " .. tostring(buttonsIndex))
	DEFAULT_CHAT_FRAME:AddMessage("items ")
	DevTools_Dump(AutoBarSearch.items:GetList(buttonsIndex))
	DEFAULT_CHAT_FRAME:AddMessage("current ")
	DevTools_Dump(AutoBarSearch.current:GetList(buttonsIndex))
	DEFAULT_CHAT_FRAME:AddMessage("sorted ")
	DevTools_Dump(AutoBarSearch.sorted:GetList(buttonsIndex))
end


-- Test harness		/script AutoBarSearch:Test()
function AutoBarSearch:Test()
	if (false and DevTools_Dump) then
		UpdateAddOnMemoryUsage()
		local usedKB = GetAddOnMemoryUsage("AutoBar")
		AutoBarSearch.trace = true
		DEFAULT_CHAT_FRAME:AddMessage("\nAutoBarSearch:Test start")
		DEFAULT_CHAT_FRAME:AddMessage("usedKB = " .. usedKB)
		AutoBarSearch:Empty()
		playerLevel = UnitLevel("player")

		AutoBarSearch.items:Add({4536}, 1, nil, 1)
		assert(AutoBarSearch.items:Contains(4536), "AutoBarSearch.items:Add failed")
		assert(AutoBarSearch.space:Contains(4536), "AutoBarSearch.space:Add failed")
		AutoBarSearch.items:Delete({4536}, 1, nil, 1)
		assert(not AutoBarSearch.items:Contains(4536), "AutoBarSearch.items:Delete failed")
		assert(not AutoBarSearch.space:Contains(4536), "AutoBarSearch.space:Delete failed")
		AutoBarSearch.items:Add({4536, 6948, 4757}, 1, nil, 1)
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n Items Added [1]")
--		DevTools_Dump(AutoBarSearch.items:GetList(1))
		assert(AutoBarSearch.items:Contains(4536), "AutoBarSearch.items:Add {4536, 6948, 4757} failed")
		assert(AutoBarSearch.items:Contains(6948), "AutoBarSearch.items:Add {4536, 6948, 4757} failed")
		assert(AutoBarSearch.items:Contains(4757), "AutoBarSearch.items:Add {4536, 6948, 4757} failed")
		assert(AutoBarSearch.space:Contains(4536), "AutoBarSearch.space:Add {4536, 6948, 4757} failed")
		assert(AutoBarSearch.space:Contains(6948), "AutoBarSearch.space:Add {4536, 6948, 4757} failed")
		assert(AutoBarSearch.space:Contains(4757), "AutoBarSearch.space:Add {4536, 6948, 4757} failed")

		AutoBarSearch.stuff:Add(6948, 0, 1)
		assert(AutoBarSearch.stuff:Contains(6948), "AutoBarSearch.stuff:Add 6948 failed")
		AutoBarSearch.stuff:Delete(6948, 0, 1)
		assert(not AutoBarSearch.stuff:Contains(6948), "AutoBarSearch.stuff:Delete 6948 failed")

		AutoBarSearch.stuff:Add(2130, 0, 1)
		assert(AutoBarSearch.stuff:Contains(2130), "AutoBarSearch.stuff:Add 2130 failed")
		assert(AutoBarSearch.found:Contains(2130), "AutoBarSearch.found:Add 2130 failed")
		assert(not AutoBarSearch.current:Contains(2130), "AutoBarSearch.current 2130 incorectly added")
		assert(not AutoBarSearch.sorted:Contains(2130), "AutoBarSearch.current 2130 incorectly added")

		AutoBarSearch.stuff:Add(6948, 0, 2)
		assert(AutoBarSearch.stuff:Contains(6948), "AutoBarSearch.stuff:Add 6948 failed")
		assert(AutoBarSearch.found:Contains(6948), "AutoBarSearch.found:Add 6948 failed")
		assert(AutoBarSearch.current:Contains(6948), "AutoBarSearch.current 6948 failed")
		assert(AutoBarSearch.sorted:Contains(6948), "AutoBarSearch.current 6948 failed")

		AutoBarSearch.stuff:Add(2132, 0, 3)
		assert(AutoBarSearch.stuff:Contains(2132), "AutoBarSearch.stuff:Add 2132 failed")
		assert(AutoBarSearch.found:Contains(2132), "AutoBarSearch.found:Add 2132 failed")
		assert(not AutoBarSearch.current:Contains(2132), "AutoBarSearch.current 2132 incorectly added")
		assert(not AutoBarSearch.sorted:Contains(2132), "AutoBarSearch.current 2132 incorectly added")

		AutoBarSearch.stuff:Add(4536, 0, 4)
		assert(AutoBarSearch.stuff:Contains(4536), "AutoBarSearch.stuff:Add 4536 failed")
		assert(AutoBarSearch.found:Contains(4536), "AutoBarSearch.found:Add 4536 failed")
		assert(AutoBarSearch.current:Contains(4536), "AutoBarSearch.current 4536 failed")
		assert(AutoBarSearch.sorted:Contains(4536), "AutoBarSearch.current 4536 failed")

		AutoBarSearch.stuff:Add(4757, 0, 5)
		assert(AutoBarSearch.found:Contains(4757), "AutoBarSearch.found:Add 4757 failed")
		assert(AutoBarSearch.found:Contains(4757, 1), "AutoBarSearch.found:Add 4757 failed")
		AutoBarSearch.stuff:Add(4757, 2, 5)
		assert(AutoBarSearch.found:Contains(4757, 2), "AutoBarSearch.found:Add 4757 failed")
		AutoBarSearch.stuff:Add(4757, 1, 5)
		assert(AutoBarSearch.found:Contains(4757, 3), "AutoBarSearch.found:Add 4757 failed")
		assert(AutoBarSearch.stuff:Contains(4757), "AutoBarSearch.stuff:Add 4757 3/3 failed")
		assert(AutoBarSearch.current:Contains(4757), "AutoBarSearch.current 4757 failed")
		assert(AutoBarSearch.sorted:Contains(4757), "AutoBarSearch.current 4757 failed")

		AutoBarSearch.sorted:Update()
		local sorted = AutoBarSearch.sorted:GetList(1)
		assert(sorted[1].itemId == 4757, "AutoBarSearch.sorted 4757 failed")
		assert(sorted[2].itemId == 6948, "AutoBarSearch.sorted 4757 failed")
		assert(sorted[3].itemId == 4536, "AutoBarSearch.sorted 4757 failed")

		AutoBarSearch.stuff:Delete(2130, 0, 1)
		AutoBarSearch.stuff:Delete(6948, 0, 2)
		AutoBarSearch.stuff:Delete(2132, 0, 3)
		AutoBarSearch.stuff:Delete(4536, 0, 4)
		assert(not AutoBarSearch.stuff:Contains(2130), "AutoBarSearch.stuff:Delete 2130 failed")
		assert(not AutoBarSearch.stuff:Contains(6948), "AutoBarSearch.stuff:Delete 6948 failed")
		assert(not AutoBarSearch.stuff:Contains(2132), "AutoBarSearch.stuff:Delete 2132 failed")
		assert(not AutoBarSearch.stuff:Contains(4536), "AutoBarSearch.stuff:Delete 4536 failed")

		AutoBarSearch.stuff:Delete(4757, 0, 5)
		assert(AutoBarSearch.found:Contains(4757, 2), "AutoBarSearch.found:Delete 4757 1/3 failed")
		assert(AutoBarSearch.stuff:Contains(4757), "AutoBarSearch.stuff:Delete 4757 1/3 failed")
		assert(AutoBarSearch.current:Contains(4757), "AutoBarSearch.current 4757 1/3 failed")
		assert(AutoBarSearch.sorted:Contains(4757), "AutoBarSearch.current 4757 1/3 failed")
		AutoBarSearch.stuff:Delete(4757, 1, 5)
		assert(AutoBarSearch.found:Contains(4757, 1), "AutoBarSearch.found:Delete 4757 2/3 failed")
		assert(AutoBarSearch.stuff:Contains(4757), "AutoBarSearch.stuff:Delete 4757 2/3 failed")
		assert(AutoBarSearch.current:Contains(4757), "AutoBarSearch.current 4757 2/3 failed")
		assert(AutoBarSearch.sorted:Contains(4757), "AutoBarSearch.current 4757 2/3 failed")
		AutoBarSearch.stuff:Delete(4757, 2, 5)
		assert(not AutoBarSearch.found:Contains(4757), "AutoBarSearch.found:Delete 4757 3/3 failed")
		assert(not AutoBarSearch.stuff:Contains(4757), "AutoBarSearch.stuff:Delete 4757 3/3 failed")
		assert(not AutoBarSearch.current:Contains(4757), "AutoBarSearch.current 4757 3/3 failed")
		assert(not AutoBarSearch.sorted:Contains(4757), "AutoBarSearch.current 4757 3/3 failed")

		AutoBarSearch.items:Delete({4757}, 1, nil, 1)
		assert(not AutoBarSearch.items:Contains(4757), "AutoBarSearch.items:Delete 4757 failed")
		assert(not AutoBarSearch.space:Contains(4757), "AutoBarSearch.space:Delete 4757 failed")
		AutoBarSearch.items:Add({4757}, 1, nil, 1)
		AutoBarSearch.items:Delete({4536, 4757, 6948}, 1, nil, 1)
		assert(not AutoBarSearch.items:Contains(4757), "AutoBarSearch.items:Delete {4536, 6948, 4757} failed")
		assert(not AutoBarSearch.items:Contains(4536), "AutoBarSearch.items:Delete {4536, 6948, 4757} failed")
		assert(not AutoBarSearch.items:Contains(6948), "AutoBarSearch.items:Delete {4536, 6948, 4757} failed")
		assert(not AutoBarSearch.space:Contains(4757), "AutoBarSearch.space:Delete {4536, 6948, 4757} failed")
		assert(not AutoBarSearch.space:Contains(4536), "AutoBarSearch.space:Delete {4536, 6948, 4757} failed")
		assert(not AutoBarSearch.space:Contains(6948), "AutoBarSearch.space:Delete {4536, 6948, 4757} failed")

--		AutoBarSearch.items:Populate()
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n SearchSpace")
--		DevTools_Dump(AutoBarSearch.space:GetList())

--		AutoBarSearch.items:Add({BS["Conjure Food"]}, 24, nil, 1)
--		AutoBarSearch.stuff:ScanSpells()
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n SearchSpace")
--		DevTools_Dump(AutoBarSearch.space:GetList())

--		local bag0, bag1, bag2, bag3, bag4 = true, true, true, true, true
--		AutoBarSearch.stuff:Scan(bag0, bag1, bag2, bag3, bag4)

--		DEFAULT_CHAT_FRAME:AddMessage("\n\n Stuff")
--		DevTools_Dump(AutoBarSearch.stuff:GetList())
--
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n Found")
--		DevTools_Dump(AutoBarSearch.found:GetList())
--
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n Current")
--		DevTools_Dump(AutoBarSearch.current:GetList(1))
--
--		AutoBarSearch.sorted:Update()
--		DEFAULT_CHAT_FRAME:AddMessage("\n\n Sorted")
--		DevTools_Dump(AutoBarSearch.sorted:GetList())

		DEFAULT_CHAT_FRAME:AddMessage("AutoBarSearch:Test successful")
		AutoBarSearch:Reset()
		UpdateAddOnMemoryUsage()
		usedKB = GetAddOnMemoryUsage("AutoBar")
		DEFAULT_CHAT_FRAME:AddMessage("usedKB = " .. usedKB)
	end
end


-- /script AutoBarSearch:Contains("Travel Form")
-- /script DevTools_Dump(AutoBar.buttons[1])
-- /script DevTools_Dump(AutoBarSearch.items:GetList(4))
-- /script DevTools_Dump(AutoBarSearch.space:GetList())
-- /script DevTools_Dump(AutoBarSearch.sorted:GetList())
-- /script DevTools_Dump(AutoBarSearch.found:GetList()[28104])
-- /script DevTools_Dump(AutoBarSearch.stuff:GetList())
-- /script DevTools_Dump(AutoBarCategoryList["PORTALS"])
-- /script DevTools_Dump(AutoBarSearch.spells)
-- /script AutoBarSearch:DumpSlot(23)
-- /script AutoBarSearch:Empty()

-- /script AutoBarSearch.items:Rearrange(buttonsIndex, slotIndexA, slotIndexB, category, categoryIndexA, categoryIndexB)
