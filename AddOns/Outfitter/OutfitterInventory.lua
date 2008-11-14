----------------------------------------
-- General
----------------------------------------

function Outfitter:InventorySlotIsEmpty(pInventorySlot)
	return Outfitter:GetInventoryItemInfo(pInventorySlot) == nil
end

function Outfitter:GetBagItemInfo(pBagIndex, pSlotIndex)
	local vItemLink = GetContainerItemLink(pBagIndex, pSlotIndex)
	local vItemInfo = Outfitter:GetItemInfoFromLink(vItemLink)
	
	if not vItemInfo then
		return nil
	end
	
	vItemInfo.Texture = GetContainerItemInfo(pBagIndex, pSlotIndex)
	
	return vItemInfo
end

function Outfitter:GetAmmotSlotItemName()
	local vSlotID = Outfitter.cSlotIDs.AmmoSlot
	local vAmmoItemTexture = GetInventoryItemTexture("player", vSlotID)
	
	if not vAmmoItemTexture then
		return nil
	end
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	OutfitterTooltip:SetInventoryItem("player", vSlotID)
	
	if not OutfitterTooltipTextLeft1:IsShown() then
		OutfitterTooltip:Hide()
		return nil
	end
	
	local vAmmoItemName = OutfitterTooltipTextLeft1:GetText()
	
	OutfitterTooltip:Hide()
	
	return vAmmoItemName, vAmmoItemTexture
end

function Outfitter:GetBagSlotItemName(pBagIndex, pBagSlotIndex)
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	OutfitterTooltip:SetBagItem(pBagIndex, pBagSlotIndex)
	
	if not OutfitterTooltipTextLeft1:IsShown() then
		OutfitterTooltip:Hide()
		return nil
	end
	
	local vItemName = OutfitterTooltipTextLeft1:GetText()
	
	OutfitterTooltip:Hide()
	
	return vItemName
end

function Outfitter:IsBankBagIndex(pBagIndex)
	return pBagIndex and (pBagIndex > NUM_BAG_SLOTS or pBagIndex < 0)
end

----------------------------------------
-- Ammo slot link caching
----------------------------------------

Outfitter.AmmoLinkByName = {}

function Outfitter:GetAmmotSlotItemLink()
	local vName, vTexture = Outfitter:GetAmmotSlotItemName()
	
	if not vName then
		return nil
	end
	
	if not self.Settings.AmmoLinkByName then
		self.Settings.AmmoLinkByName = {}
	end
	
	local vLink = self.Settings.AmmoLinkByName[vName]
	
	if vLink then
		return vLink
	end
	
	vLink = Outfitter:FindAmmoSlotItemLink(vName)
	
	if not vLink then
		return nil
	end
	
	self.Settings.AmmoLinkByName[vName] = vLink
	return vLink
end

function Outfitter:FindAmmoSlotItemLink(pName)
	for vBagIndex = 0, NUM_BAG_SLOTS do
		local vNumBagSlots = GetContainerNumSlots(vBagIndex)
		
		for vBagSlotIndex = 1, vNumBagSlots do
			local vLink = GetContainerItemLink(vBagIndex, vBagSlotIndex)
			
			if vLink then
				local vName = Outfitter:GetBagSlotItemName(vBagIndex, vBagSlotIndex)
				
				if vName == pName then
					return vLink
				end
			end
		end -- for vBagSlotIndex
	end -- for vBagIndex
	
	-- Failed to find the ammo
	
	return nil
end

----------------------------------------
--
----------------------------------------

function Outfitter:GetInventoryItemInfo(pInventorySlot)
	local vSlotID = self.cSlotIDs[pInventorySlot]
	local vItemLink = self:GetInventorySlotIDLink(vSlotID)
	local vItemInfo = self:GetItemInfoFromLink(vItemLink)
	
	if not vItemInfo then
		return nil
	end
	
	vItemInfo.Quality = GetInventoryItemQuality("player", vSlotID)
	vItemInfo.Texture = GetInventoryItemTexture("player", vSlotID)
	
	return vItemInfo
end

function Outfitter:GetNumBags()
	if self.BankFrameOpened then
		return NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, -1
	else
		return NUM_BAG_SLOTS, 0
	end
end

function Outfitter:GetInventorySlotIDLink(pSlotID)
	if pSlotID == 0 then -- AmmoSlot
		return self:GetAmmotSlotItemLink()
	else
		return GetInventoryItemLink("player", pSlotID)
	end
end

function Outfitter:GetInventorySlotItemInfo(pInventorySlot)
	local vItemLink = self:GetInventorySlotIDLink(Outfitter.cSlotIDs[pInventorySlot])

	if not vItemLink then
		return
	end
	
	return self:GetItemInfoFromLink(vItemLink)
end

Outfitter.LinkCache =
{
	Inventory = {},
	FirstBagIndex = 0,
	NumBags = 0,
	Bags = {},
}

function Outfitter:Synchronize()
	local vBagsChanged, vInventoryChanged = false, false

	-- Synchronize bag links
	
	local vNumBags, vFirstBagIndex = self:GetNumBags()
	
	if self.LinkCache.FirstBagIndex ~= vFirstBagIndex
	or self.LinkCache.NumBags ~= vNumBags then
		
		self.LinkCache.FirstBagIndex = vFirstBagIndex
		self.LinkCache.NumBags = vNumBags
		
		vBagsChanged = true
	end
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local vBag = self.LinkCache.Bags[vBagIndex]
		local vBagChanged = false
		
		if not vBag then
			vBag = {}
			self.LinkCache.Bags[vBagIndex] = vBag
		end
		
		local vNumBagSlots = GetContainerNumSlots(vBagIndex)
		
		if #vBag ~= vNumBagSlots then
			self:EraseTable(vBag)
			vBagChanged = true
		end
		
		for vSlotIndex = 1, vNumBagSlots do
			local vItemLink = GetContainerItemLink(vBagIndex, vSlotIndex) or ""
			
			if vBag[vSlotIndex] ~= vItemLink then
				vBag[vSlotIndex] = vItemLink
				vBagChanged = true
			end
		end
		
		if vBagChanged then
			self.ItemList_FlushBagFromEquippableItems(vBagIndex)
			vBagsChanged = true
		end
	end
	
	-- Synchronize inventory links
	
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		local vItemLink
		
		if vInventorySlot == "AmmoSlot" then
			local vName, vTexture = self:GetAmmotSlotItemName()
			
			if vName then
				vItemLink = vName.."|"..(vTexture or "") -- Not an item link, just a unique reference to the contents
			end
		else
			vItemLink = GetInventoryItemLink("player", self.cSlotIDs[vInventorySlot])
		end
		
		if self.LinkCache.Inventory[vInventorySlot] ~= vItemLink then
			self.LinkCache.Inventory[vInventorySlot] = vItemLink
			vInventoryChanged = true
		end
	end
	
	if vInventoryChanged then
		self.ItemList_FlushInventoryFromEquippableItems()
		self:InventoryChanged()
	end
	
	-- Done
	
	if vBagsChanged or vInventoryChanged then
		self.DisplayIsDirty = true
		self:Update(false)
	end
	
	self:RunThreads()
	
	return vBagsChanged or vInventoryChanged, vInventoryChanged, vBagsChanged
end

----------------------------------------
-- Inventory
----------------------------------------

Outfitter._Inventory = {}

function Outfitter._Inventory:Construct()
	self.ItemsByCode = {}
	self.ItemsBySlot = {}
	self.EquippedItems = nil
	self.BagItems = {}
end

function Outfitter._Inventory:AddItem(pItem)
	-- Add the item to the code list

	local vItemFamily = self.ItemsByCode[pItem.Code]

	if not vItemFamily then
		vItemFamily = {}
		self.ItemsByCode[pItem.Code] = vItemFamily
	end
	
	table.insert(vItemFamily, pItem)
	
	-- Add the item to the slot list
	
	local vItemSlot = self.ItemsBySlot[pItem.ItemSlotName]
	
	if not vItemSlot then
		vItemSlot = {}
		self.ItemsBySlot[pItem.ItemSlotName] = vItemSlot
	end
	
	table.insert(vItemSlot, pItem)
	
	-- Add the item to the bags
	
	if pItem.Location.BagIndex then
		local vBagItems = self.BagItems[pItem.Location.BagIndex]
		
		if not vBagItems then
			vBagItems = {}
			self.BagItems[pItem.Location.BagIndex] = vBagItems
		end
		
		vBagItems[pItem.Location.BagSlotIndex] = pItem
		
	-- Add the item to the equipped items
	
	elseif pItem.Location.SlotName then
		self.EquippedItems[pItem.Location.SlotName] = pItem
	end
end

function Outfitter._Inventory:FlushChangedItems()
	-- Check inventory
	
	local vFlushInventory = false

	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local vEquippedItemInfo = Outfitter:GetInventorySlotItemInfo(vInventorySlot)
		local vItemInfo = self.EquippedItems[vInventorySlot]
		
		if (vEquippedItemInfo ~= nil) ~= (vItemInfo ~= nil) then
			vFlushInventory = true
			break
		end
		
		if vItemInfo
		and (vItemInfo.Code ~= vEquippedItemInfo.Code
		  or vItemInfo.SubCode ~= vEquippedItemInfo.SubCode
		  or vItemInfo.EnchantCode ~= vEquippedItemInfo.EnchantCode 
		  or vItemInfo.JewelCode1 ~= vEquippedItemInfo.JewelCode1 
		  or vItemInfo.JewelCode2 ~= vEquippedItemInfo.JewelCode2 
		  or vItemInfo.JewelCode3 ~= vEquippedItemInfo.JewelCode3 
		  or vItemInfo.JewelCode4 ~= vEquippedItemInfo.JewelCode4
		  or vItemInfo.UniqueID ~= vEquippedItemInfo.UniqueID) then
			vFlushInventory = true
			break
		end
	end
	
	-- Have to flush bags too since inventory event changes probably
	-- also have bag event changes.  Not flushing the bag can result
	-- in a strange state where an item appears to be in two places at once.
	
	if vFlushInventory then
		self:FlushItems()
	end
end

function Outfitter._Inventory:FindItemInfoByCode(pItemInfo)
	local vItems = self.ItemsByCode[pItemInfo.Code]
	
	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true
		end
	end
	
	return false
end

function Outfitter._Inventory:FindItemInfoBySlot(pItemInfo)
	local vItems = self.ItemsBySlot[pItemInfo.ItemSlotName]

	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true
		end
	end
	
	return false
end

function Outfitter._Inventory:VerifyItems()
	-- Check that all the inventory items are accounted for
	
	for vInventorySlot, vItemInfo in pairs(self.EquippedItems) do
		-- Verify the item in the code list
		
		if not self:FindItemInfoByCode(self, vItemInfo) then
			Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by code")
		end
		
		-- Check the item in the slot list
		
		if not self:FindItemInfoBySlot(vItemInfo) then
			Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by slot")
		end
	end
	
	-- Check that all bag items are accounted for
	
	for _, vBagItems in pairs(self.BagItems) do
		for _, vItemInfo in pairs(vBagItems) do
			-- Verify the item in the code list
			
			if not self:FindItemInfoByCode(vItemInfo) then
				Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by code")
			end
			
			-- Check the item in the slot list
			
			if not self:FindItemInfoBySlot(vItemInfo) then
				Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by slot")
			end
		end
	end
end

function Outfitter._Inventory:FlushBag(pBagIndex)
	if self.BagItems[pBagIndex] then
		for vBagSlotIndex, vItem in pairs(self.BagItems[pBagIndex]) do
			self:RemoveItem(vItem)
		end
		
		self.NeedsUpdate = true
		self.BagItems[pBagIndex] = nil
	end
end

function Outfitter._Inventory:FlushEquippedItems()
	for vInventorySlot, vItem in pairs(self.EquippedItems) do
		self:RemoveItem(vItem)
	end
	
	self.NeedsUpdate = true
	self.EquippedItems = nil
end

function Outfitter._Inventory:RemoveItem(pItem)
	-- Remove the item from the code list
	
	local vItems = self.ItemsByCode[pItem.Code]
	
	for vIndex, vItem in ipairs(vItems) do
		if vItem == pItem then
			table.remove(vItems, vIndex)
			break
		end
	end

	-- Remove the item from the slot list
	
	local vItemSlot = self.ItemsBySlot[pItem.ItemSlotName]
	
	if vItemSlot then
		for vIndex, vItem in ipairs(vItemSlot) do
			if vItem == pItem then
				table.remove(vItemSlot, vIndex)
				break
			end
		end
	end
	
	-- Remove the item from the bags list
	
	if pItem.Location.BagIndex then
		local vBagItems = self.BagItems[pItem.Location.BagIndex]
		
		if vBagItems then
			vBagItems[pItem.Location.BagSlotIndex] = nil
		end
	
	-- Remove the item from the equipped list
	
	elseif pItem.Location.SlotName then
		self.EquippedItems[pItem.Location.SlotName] = nil
	end
end

function Outfitter._Inventory:GetEquippedItems()
	return self.EquippedItems
end

function Outfitter._Inventory:ResetIgnoreItemFlags()
	for vItemCode, vItemFamily in pairs(self.ItemsByCode) do
		for _, vItem in ipairs(vItemFamily) do
			vItem.IgnoreItem = nil
		end
	end
end

function Outfitter._Inventory:GetEquippableItems(pIncludeItemStats)
	-- Check for a change in the number of bags
	
	local vNumBags, vFirstBagIndex = Outfitter:GetNumBags()
	
	if (self.FirstBagIndex ~= vFirstBagIndex
	or self.NumBags ~= vNumBags) then
		for vBagIndex = self.FirstBagIndex, vFirstBagIndex - 1 do
			self:FlushBag(vBagIndex)
		end
		
		for vBagIndex = vNumBags + 1, self.NumBags do
			self:FlushBag(vBagIndex)
		end
		
		self.NeedsUpdate = true
	end
	
	-- If there's a cached copy just clear the IgnoreItem flags and return it
	-- (never use the cached copy if the caller wants stats)
	
	if not self.NeedsUpdate
	and not pIncludeItemStats then
		self:ResetIgnoreItemFlags()
	end
	
	local vStatDistribution = Outfitter:GetPlayerStatDistribution()
	
	if not self.EquippedItems
	or pIncludeItemStats then
		self.EquippedItems = {}
		
		for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
			local vItemInfo = Outfitter:GetInventoryItemInfo(vInventorySlot)
			
			if vItemInfo
			and vItemInfo.ItemSlotName
			and vItemInfo.Code ~= 0 then
				vItemInfo.SlotName = vInventorySlot
				vItemInfo.Location = {SlotName = vInventorySlot}
				
				if pIncludeItemStats then	
					Outfitter:GetItemStats(vItemInfo, vStatDistribution)
				end
				
				self:AddItem(vItemInfo)
			end
		end
	else
		for vInventorySlot, vItem in pairs(self.EquippedItems) do
			vItem.IgnoreItem = nil
		end
	end
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local vBagItems = self.BagItems[vBagIndex]
		
		if not vBagItems
		or pIncludeItemStats then
			self.BagItems[vBagIndex] = {}
			
			local vNumBagSlots = GetContainerNumSlots(vBagIndex)
			
			if vNumBagSlots > 0 then
				for vBagSlotIndex = 1, vNumBagSlots do
					local vItemInfo = Outfitter:GetBagItemInfo(vBagIndex, vBagSlotIndex)
					
					if vItemInfo
					and vItemInfo.Code ~= 0
					and vItemInfo.ItemSlotName
					and Outfitter:CanEquipBagItem(vBagIndex, vBagSlotIndex)
					and not Outfitter:BagItemWillBind(vBagIndex, vBagSlotIndex) then
						vItemInfo.BagIndex = vBagIndex
						vItemInfo.BagSlotIndex = vBagSlotIndex
						vItemInfo.Location = {BagIndex = vBagIndex, BagSlotIndex = vBagSlotIndex}
						
						if pIncludeItemStats then	
							Outfitter:GetItemStats(vItemInfo, vStatDistribution)
						end
						
						self:AddItem(vItemInfo)
					end
				end -- for vBagSlotIndex
			end -- if vNumBagSlots > 0
		else -- if not BagItems
			for vBagSlotIndex, vItem in pairs(vBagItems) do
				vItem.IgnoreItem = nil
			end
		end -- if not BagItems
	end -- for vBagIndex
	
	self.FirstBagIndex = vFirstBagIndex
	self.NumBags = vNumBags
	
	self.NeedsUpdate = false
end

function Outfitter._Inventory:SwapLocations(pLocation1, pLocation2)
	-- if pLocation1.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocations: Swapping bag "..pLocation1.BagIndex..", "..pLocation1.BagSlotIndex)
	-- elseif pLocation1.SlotName then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocations: Swapping slot "..pLocation1.SlotName)
	-- end
	-- if pLocation2.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocations: with bag "..pLocation2.BagIndex..", "..pLocation2.BagSlotIndex)
	-- elseif pLocation2.SlotName then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocations: with slot "..pLocation2.SlotName)
	-- end
end

function Outfitter._Inventory:SwapLocationWithInventorySlot(pLocation, pSlotName)
	-- if pLocation.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocationWithInventorySlot: Swapping bag "..pLocation.BagIndex..", "..pLocation.BagSlotIndex.." with slot "..pSlotName)
	-- elseif pLocation.SlotName then
	-- 	Outfitter:TestMessage("Outfitter._Inventory:SwapLocationWithInventorySlot: Swapping slot "..pLocation.SlotName.." with slot "..pSlotName)
	-- end
end

function Outfitter._Inventory:SwapBagSlotWithInventorySlot(pBagIndex, pBagSlotIndex, pSlotName)
	-- Outfitter:TestMessage("Outfitter._Inventory:SwapBagSlotWithInventorySlot: Swapping bag "..pBagIndex..", "..pBagSlotIndex.." with slot "..pSlotName)
end

function Outfitter._Inventory:FindItemOrAlt(pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	local vItem, vIgnoredItem = self:FindItem(pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	
	if vItem then
		return vItem
	end
	
	-- See if there's an alias for the item if it wasn't found
	
	local vAltCode = Outfitter.cItemAliases[pOutfitItem.Code]
	
	if not vAltCode then
		return nil, vIgnoredItem
	end
	
	return self:FindItem({Code = vAltCode}, pMarkAsInUse, true)
end

function Outfitter._Inventory:FindItem(pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	local vItem, vIndex, vItemFamily, vIgnoredItem = self:FindItemIndex(pOutfitItem, pAllowSubCodeWildcard)
	
	if not vItem then
		return nil, vIgnoredItem
	end
	
	if pMarkAsInUse then
		vItem.IgnoreItem = true
	end
	
	return vItem
end

function Outfitter._Inventory:FindAllItemsOrAlt(pOutfitItem, pAllowSubCodeWildcard, rItems)
	local vNumItems = self:FindAllItems(pOutfitItem, pAllowSubCodeWildcard, rItems)
	local vAltCode = Outfitter.cItemAliases[pOutfitItem.Code]
	
	if vAltCode then
		vNumItems = vNumItems + self:FindAllItems({Code = vAltCode}, true, rItems)
	end
	
	return vNumItems
end

function Outfitter._Inventory:FindAllItems(pOutfitItem, pAllowSubCodeWildcard, rItems)
	local vItemFamily = self.ItemsByCode[pOutfitItem.Code]
	
	if not vItemFamily then
		return 0
	end
	
	local vNumItemsFound = 0
	
	for vIndex, vItem in ipairs(vItemFamily) do
		if (pAllowSubCodeWildcard and not pOutfitItem.SubCode)
		or vItem.SubCode == pOutfitItem.SubCode then
			table.insert(rItems, vItem)
			vNumItemsFound = vNumItemsFound + 1
		end
	end
	
	return vNumItemsFound
end

function Outfitter._Inventory:FindItemIndex(pOutfitItem, pAllowSubCodeWildcard)
	local vItemFamily = self.ItemsByCode[pOutfitItem.Code]
	
	if not vItemFamily then
		return
	end
	
	local vBestMatch = nil
	local vBestMatchIndex = nil
	local vNumItemsFound = 0
	local vFoundIgnoredItem = nil
	
	for vIndex, vItem in ipairs(vItemFamily) do
		-- All done if the caller doesn't care about the SubCode
		
		if pAllowSubCodeWildcard
		and not pOutfitItem.SubCode then
			if vItem.IgnoreItem then
				vFoundIgnoredItem = vItem
			else
				return vItem, vIndex, vItemFamily, nil
			end
		
		-- If the subcode matches then check for an enchant match
		
		elseif vItem.SubCode == pOutfitItem.SubCode then
			-- If the enchant matches then we're all done
			
			if vItem.EnchantCode == pOutfitItem.EnchantCode 
			and vItem.JewelCode1 == pOutfitItem.JewelCode1 
			and vItem.JewelCode2 == pOutfitItem.JewelCode2
			and vItem.JewelCode3 == pOutfitItem.JewelCode3 
			and vItem.JewelCode4 == pOutfitItem.JewelCode4
			and vItem.UniqueID == pOutfitItem.UniqueID then
				if vItem.IgnoreItem then
					vFoundIgnoredItem = vItem
				else
					return vItem, vIndex, vItemFamily
				end
			
			-- Otherwise save the match in case a better one can
			-- be found
			
			else
				if vItem.IgnoreItem then
					if not vFoundIgnoredItem then
						vFoundIgnoredItem = vItem
					end
				else
					vBestMatch = vItem
					vBestMatchIndex = vIndex
					vNumItemsFound = vNumItemsFound + 1
				end
			end
		end
	end
	
	-- Return the match if only one item was found
	
	if vNumItemsFound == 1
	and not vBestMatch.IgnoreItem then
		return vBestMatch, vBestMatchIndex, vItemFamily, nil
	end
	
	return nil, nil, nil, vFoundIgnoredItem
end

function Outfitter._Inventory:GetMissingItems(pOutfit)
	if not pOutfit then
		Outfitter:DebugMessage("Inventory:GetMissingItems: pOutfit is nil")
		Outfitter:DebugStack()
		return
	end
	
	local vMissingItems = nil
	local vBankedItems = nil
	
	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		if vOutfitItem.Code ~= 0 then
			local vItem = self:FindItemOrAlt(vOutfitItem)
			
			if not vItem then
				if not vMissingItems then
					vMissingItems = {}
				end
				
				table.insert(vMissingItems, vOutfitItem)
			elseif Outfitter:IsBankBagIndex(vItem.Location.BagIndex) then
				if not vBankedItems then
					vBankedItems = {}
				end
				
				table.insert(vBankedItems, vOutfitItem)
			end
		end
	end
	
	return vMissingItems, vBankedItems
end

function Outfitter._Inventory:CompiledUnusedItemsList()
	self:ResetIgnoreItemFlags()
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local vItem = self:FindItemOrAlt(vOutfitItem, true)
					
					if vItem then
						vItem.UsedInOutfit = true
					end
				end
			end
		end
	end
	
	local vUnusedItems = nil
	
	for vCode, vFamilyItems in pairs(self.ItemsByCode) do
		for vIndex, vOutfitItem in ipairs(vFamilyItems) do
			if not vOutfitItem.UsedInOutfit
			and vOutfitItem.ItemSlotName ~= "AmmoSlot"
			and Outfitter.cIgnoredUnusedItems[vOutfitItem.Code] == nil then
				if not vUnusedItems then
					vUnusedItems = {}
				end
				
				table.insert(vUnusedItems, vOutfitItem)
			end
		end
	end
	
	self.UnusedItems = vUnusedItems
end

function Outfitter._Inventory:ItemsAreSame(pItem1, pItem2)
	if not pItem1 then
		return pItem2 == nil
	end
	
	if not pItem2 then
		return false
	end
	
	if pItem1.Code == 0 then
		return pItem2.Code == 0
	end
	
	if pItem1.Code ~= pItem2.Code
	or pItem1.SubCode ~= pItem2.SubCode then
		return false
	end
	
	local vItems = {}
	local vNumItems = self:FindAllItemsOrAlt(pItem1, nil, vItems)
	
	if vNumItems == 0 then
		-- Shouldn't ever get here
		
		Outfitter:DebugMessage("Inventory:ItemsAreSame: Item not found")
		Outfitter:DebugTable("Item", pItem1)
		
		return false
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's the same
		
		return true
	else
		return pItem1.EnchantCode == pItem2.EnchantCode
		   and pItem1.JewelCode1 == pItem2.JewelCode1
		   and pItem1.JewelCode2 == pItem2.JewelCode2
		   and pItem1.JewelCode3 == pItem2.JewelCode3
		   and pItem1.JewelCode4 == pItem2.JewelCode4
		   and pItem1.UniqueID == pItem2.UniqueID
	end
end

function Outfitter._Inventory:EquipmentSlotContainsItem(pEquipmentSlot, pOutfitItem)
	-- Nil items are supposed to be ignored, so never claim the slot contains them
	
	if pOutfitItem == nil then
		return false, nil
	end
	
	-- If the item specifies an empty slot check to see if the slot is actually empty
	
	if pOutfitItem.Code == 0 then
		return self.EquippedItems[pEquipmentSlot] == nil
	end
	
	local vItems = {}
	local vNumItems = self:FindAllItemsOrAlt(pOutfitItem, nil, vItems)
	
	if vNumItems == 0 then
		return false
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's in the slot
		
		return vItems[1].SlotName == pEquipmentSlot, vItems[1]
	else
		-- See if one of the items is in the slot
		
		for vIndex, vItem in ipairs(vItems) do
			if vItem.SlotName == pEquipmentSlot then
				-- Must match the enchant and jewel codes if there are multiple items
				-- in order to be considered a perfect match
				
				local vCodesMatch = vItem.EnchantCode == pOutfitItem.EnchantCode
				                and vItem.JewelCode1 == pOutfitItem.JewelCode1
				                and vItem.JewelCode2 == pOutfitItem.JewelCode2
				                and vItem.JewelCode3 == pOutfitItem.JewelCode3
				                and vItem.JewelCode4 == pOutfitItem.JewelCode4
				                and vItem.UniqueID == pOutfitItem.UniqueID
				
				return vCodesMatch, vItem
			end
		end
		
		-- No items in the slot
		
		return false, nil
	end
end

----------------------------------------
-- ItemList
----------------------------------------

function Outfitter.ItemList_AddItem(pItemList, pItem)
	-- Add the item to the code list

	local vItemFamily = pItemList.ItemsByCode[pItem.Code]

	if not vItemFamily then
		vItemFamily = {}
		pItemList.ItemsByCode[pItem.Code] = vItemFamily
	end
	
	table.insert(vItemFamily, pItem)
	
	-- Add the item to the slot list
	
	local vItemSlot = pItemList.ItemsBySlot[pItem.ItemSlotName]
	
	if not vItemSlot then
		vItemSlot = {}
		pItemList.ItemsBySlot[pItem.ItemSlotName] = vItemSlot
	end
	
	table.insert(vItemSlot, pItem)
	
	-- Add the item to the bags
	
	if pItem.Location.BagIndex then
		local vBagItems = pItemList.BagItems[pItem.Location.BagIndex]
		
		if not vBagItems then
			vBagItems = {}
			pItemList.BagItems[pItem.Location.BagIndex] = vBagItems
		end
		
		vBagItems[pItem.Location.BagSlotIndex] = pItem
		
	-- Add the item to the inventory
	
	elseif pItem.Location.SlotName then
		pItemList.InventoryItems[pItem.Location.SlotName] = pItem
	end
end

function Outfitter.ItemList_FlushChangedItems()
	if not Outfitter.EquippableItems then
		return
	end
	
	-- Check inventory
	
	local vFlushInventory = false

	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local vEquippedItemInfo = Outfitter:GetInventorySlotItemInfo(vInventorySlot)
		local vItemInfo = Outfitter.EquippableItems.InventoryItems[vInventorySlot]
		
		if (vEquippedItemInfo ~= nil) ~= (vItemInfo ~= nil) then
			vFlushInventory = true
			break
		end
		
		if vItemInfo
		and (vItemInfo.Code ~= vEquippedItemInfo.Code
		  or vItemInfo.SubCode ~= vEquippedItemInfo.SubCode
		  or vItemInfo.EnchantCode ~= vEquippedItemInfo.EnchantCode 
		  or vItemInfo.JewelCode1 ~= vEquippedItemInfo.JewelCode1 
		  or vItemInfo.JewelCode2 ~= vEquippedItemInfo.JewelCode2 
		  or vItemInfo.JewelCode3 ~= vEquippedItemInfo.JewelCode3 
		  or vItemInfo.JewelCode4 ~= vEquippedItemInfo.JewelCode4
		  or vItemInfo.UniqueID ~= vEquippedItemInfo.UniqueID) then
			vFlushInventory = true
			break
		end
	end
	
	-- Have to flush bags too since inventory event changes probably
	-- also have bag event changes.  Not flushing the bag can result
	-- in a strange state where an item appears to be in two places at once.
	
	if vFlushInventory then
		Outfitter.ItemList_FlushEquippableItems()
	end
end

function Outfitter.ItemList_FindItemInfoByCode(pItemList, pItemInfo)
	local vItems = pItemList.ItemsByCode[pItemInfo.Code]
	
	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true
		end
	end
	
	return false
end

function Outfitter.ItemList_FindItemInfoBySlot(pItemList, pItemInfo)
	local vItems = pItemList.ItemsBySlot[pItemInfo.ItemSlotName]

	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true
		end
	end
	
	return false
end

function Outfitter.ItemList_VerifyItems(pItemList)
	-- Check that all the inventory items are accounted for
	
	for vInventorySlot, vItemInfo in pairs(pItemList.InventoryItems) do
		-- Verify the item in the code list
		
		if not Outfitter.ItemList_FindItemInfoByCode(pItemList, vItemInfo) then
			Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by code")
		end
		
		-- Check the item in the slot list
		
		if not Outfitter.ItemList_FindItemInfoBySlot(pItemList, vItemInfo) then
			Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by slot")
		end
	end
	
	-- Check that all bag items are accounted for
	
	for _, vBagItems in pairs(pItemList.BagItems) do
		for _, vItemInfo in pairs(vBagItems) do
			-- Verify the item in the code list
			
			if not Outfitter.ItemList_FindItemInfoByCode(pItemList, vItemInfo) then
				Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by code")
			end
			
			-- Check the item in the slot list
			
			if not Outfitter.ItemList_FindItemInfoBySlot(pItemList, vItemInfo) then
				Outfitter:DebugMessage("Didn't find item "..vItemInfo.Name.." by slot")
			end
		end
	end
end

function Outfitter.ItemList_FlushEquippableItems()
	Outfitter.EquippableItems = nil
end

function Outfitter.ItemList_FlushBagFromEquippableItems(pBagIndex)
	if Outfitter.EquippableItems
	and Outfitter.EquippableItems.BagItems[pBagIndex] then
		for vBagSlotIndex, vItem in pairs(Outfitter.EquippableItems.BagItems[pBagIndex]) do
			Outfitter.ItemList_RemoveItem(Outfitter.EquippableItems, vItem)
		end
		
		Outfitter.EquippableItems.NeedsUpdate = true
		Outfitter.EquippableItems.BagItems[pBagIndex] = nil
	end
end

function Outfitter.ItemList_FlushInventoryFromEquippableItems()
	if Outfitter.Debug.InventoryCache then
		Outfitter:TestMessage("ItemList_FlushInventoryFromEquippableItems")
	end
	
	if Outfitter.EquippableItems then
		for vInventorySlot, vItem in pairs(Outfitter.EquippableItems.InventoryItems) do
			Outfitter.ItemList_RemoveItem(Outfitter.EquippableItems, vItem)
		end
		
		Outfitter.EquippableItems.NeedsUpdate = true
		Outfitter.EquippableItems.InventoryItems = nil
	end
end

function Outfitter.ItemList_New()
	return {ItemsByCode = {}, ItemsBySlot = {}, InventoryItems = nil, BagItems = {}}
end

function Outfitter.ItemList_RemoveItem(pItemList, pItem)
	-- Remove the item from the code list
	
	local vItems = pItemList.ItemsByCode[pItem.Code]
	
	for vIndex, vItem in ipairs(vItems) do
		if vItem == pItem then
			table.remove(vItems, vIndex)
			break
		end
	end

	-- Remove the item from the slot list
	
	local vItemSlot = pItemList.ItemsBySlot[pItem.ItemSlotName]
	
	if vItemSlot then
		for vIndex, vItem in ipairs(vItemSlot) do
			if vItem == pItem then
				table.remove(vItemSlot, vIndex)
				break
			end
		end
	end
	
	-- Remove the item from the bags list
	
	if pItem.Location.BagIndex then
		local vBagItems = pItemList.BagItems[pItem.Location.BagIndex]
		
		if vBagItems then
			vBagItems[pItem.Location.BagSlotIndex] = nil
		end
		
	-- Remove the item from the inventory list
	
	elseif pItem.Location.SlotName then
		pItemList.InventoryItems[pItem.Location.SlotName] = nil
	end
end

function Outfitter.ItemList_GetInventoryOutfit(pEquippableItems)
	return pEquippableItems.InventoryItems
end

function Outfitter.ItemList_ResetIgnoreItemFlags(pItemList)
	for vItemCode, vItemFamily in pairs(pItemList.ItemsByCode) do
		for _, vItem in ipairs(vItemFamily) do
			vItem.IgnoreItem = nil
		end
	end
end

function Outfitter.ItemList_GetEquippableItems(pIncludeItemStats)
	-- Check for a change in the number of bags
	
	local vNumBags, vFirstBagIndex = Outfitter:GetNumBags()
	
	if Outfitter.EquippableItems
	and (Outfitter.EquippableItems.FirstBagIndex ~= vFirstBagIndex
	or Outfitter.EquippableItems.NumBags ~= vNumBags) then
		for vBagIndex = Outfitter.EquippableItems.FirstBagIndex, vFirstBagIndex - 1 do
			Outfitter.ItemList_FlushBagFromEquippableItems(vBagIndex)
		end
		
		for vBagIndex = vNumBags + 1, Outfitter.EquippableItems.NumBags do
			Outfitter.ItemList_FlushBagFromEquippableItems(vBagIndex)
		end
		
		Outfitter.EquippableItems.NeedsUpdate = true
	end
	
	-- If there's a cached copy just clear the IgnoreItem flags and return it
	-- (never use the cached copy if the caller wants stats)
	
	if Outfitter.EquippableItems
	and not Outfitter.EquippableItems.NeedsUpdate
	and not pIncludeItemStats then
		Outfitter.ItemList_ResetIgnoreItemFlags(Outfitter.EquippableItems)
		
		return Outfitter.EquippableItems
	end
	
	if not Outfitter.EquippableItems
	or pIncludeItemStats then
		Outfitter.EquippableItems = Outfitter.ItemList_New()
	end
	
	local vStatDistribution = Outfitter:GetPlayerStatDistribution()
	
	if not Outfitter.EquippableItems.InventoryItems
	or pIncludeItemStats then
		Outfitter.EquippableItems.InventoryItems = {}
		
		for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
			local vItemInfo = Outfitter:GetInventoryItemInfo(vInventorySlot)
			
			if vItemInfo
			and vItemInfo.ItemSlotName
			and vItemInfo.Code ~= 0 then
				vItemInfo.SlotName = vInventorySlot
				vItemInfo.Location = {SlotName = vInventorySlot}
				
				if pIncludeItemStats then	
					Outfitter.ItemList_GetItemStats(vItemInfo, vStatDistribution)
				end
				
				Outfitter.ItemList_AddItem(Outfitter.EquippableItems, vItemInfo)
			end
		end
	else
		for vInventorySlot, vItem in pairs(Outfitter.EquippableItems.InventoryItems) do
			vItem.IgnoreItem = nil
		end
	end
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local vBagItems = Outfitter.EquippableItems.BagItems[vBagIndex]
		
		if not vBagItems
		or pIncludeItemStats then
			Outfitter.EquippableItems.BagItems[vBagIndex] = {}
			
			local vNumBagSlots = GetContainerNumSlots(vBagIndex)
			
			if vNumBagSlots > 0 then
				for vBagSlotIndex = 1, vNumBagSlots do
					local vItemInfo = Outfitter:GetBagItemInfo(vBagIndex, vBagSlotIndex)
					
					if vItemInfo
					and vItemInfo.Code ~= 0
					and vItemInfo.ItemSlotName
					and Outfitter:CanEquipBagItem(vBagIndex, vBagSlotIndex)
					and not Outfitter:BagItemWillBind(vBagIndex, vBagSlotIndex) then
						vItemInfo.BagIndex = vBagIndex
						vItemInfo.BagSlotIndex = vBagSlotIndex
						vItemInfo.Location = {BagIndex = vBagIndex, BagSlotIndex = vBagSlotIndex}
						
						if pIncludeItemStats then	
							Outfitter.ItemList_GetItemStats(vItemInfo, vStatDistribution)
						end
						
						Outfitter.ItemList_AddItem(Outfitter.EquippableItems, vItemInfo)
					end
				end -- for vBagSlotIndex
			end -- if vNumBagSlots > 0
		else -- if not BagItems
			for vBagSlotIndex, vItem in pairs(vBagItems) do
				vItem.IgnoreItem = nil
			end
		end -- if not BagItems
	end -- for vBagIndex
	
	Outfitter.EquippableItems.FirstBagIndex = vFirstBagIndex
	Outfitter.EquippableItems.NumBags = vNumBags
	
	Outfitter.EquippableItems.NeedsUpdate = false
	
	return Outfitter.EquippableItems
end

function Outfitter.ItemList_SwapLocations(pItemList, pLocation1, pLocation2)
	-- if pLocation1.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocations: Swapping bag "..pLocation1.BagIndex..", "..pLocation1.BagSlotIndex)
	-- elseif pLocation1.SlotName then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocations: Swapping slot "..pLocation1.SlotName)
	-- end
	-- if pLocation2.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocations: with bag "..pLocation2.BagIndex..", "..pLocation2.BagSlotIndex)
	-- elseif pLocation2.SlotName then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocations: with slot "..pLocation2.SlotName)
	-- end
end

function Outfitter.ItemList_SwapLocationWithInventorySlot(pItemList, pLocation, pSlotName)
	-- if pLocation.BagIndex then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocationWithInventorySlot: Swapping bag "..pLocation.BagIndex..", "..pLocation.BagSlotIndex.." with slot "..pSlotName)
	-- elseif pLocation.SlotName then
	-- 	Outfitter:TestMessage("Outfitter.ItemList_SwapLocationWithInventorySlot: Swapping slot "..pLocation.SlotName.." with slot "..pSlotName)
	-- end
end

function Outfitter.ItemList_SwapBagSlotWithInventorySlot(pItemList, pBagIndex, pBagSlotIndex, pSlotName)
	-- Outfitter:TestMessage("Outfitter.ItemList_SwapBagSlotWithInventorySlot: Swapping bag "..pBagIndex..", "..pBagSlotIndex.." with slot "..pSlotName)
end

function Outfitter.ItemList_FindItemOrAlt(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	local vItem, vIgnoredItem = Outfitter.ItemList_FindItem(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	
	if vItem then
		return vItem
	end
	
	-- See if there's an alias for the item if it wasn't found
	
	local vAltCode = Outfitter.cItemAliases[pOutfitItem.Code]
	
	if not vAltCode then
		return nil, vIgnoredItem
	end
	
	return Outfitter.ItemList_FindItem(pItemList, {Code = vAltCode}, pMarkAsInUse, true)
end

function Outfitter.ItemList_FindItem(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
	local vItem, vIndex, vItemFamily, vIgnoredItem = Outfitter.ItemList_FindItemIndex(pItemList, pOutfitItem, pAllowSubCodeWildcard)
	
	if not vItem then
		return nil, vIgnoredItem
	end
	
	if pMarkAsInUse then
		vItem.IgnoreItem = true
	end
	
	return vItem
end

function Outfitter.ItemList_FindAllItemsOrAlt(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems)
	local vNumItems = Outfitter.ItemList_FindAllItems(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems)
	local vAltCode = Outfitter.cItemAliases[pOutfitItem.Code]
	
	if vAltCode then
		vNumItems = vNumItems + Outfitter.ItemList_FindAllItems(pItemList, {Code = vAltCode}, true, rItems)
	end
	
	return vNumItems
end

function Outfitter.ItemList_FindAllItems(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems)
	if not pItemList then
		return 0
	end
	
	local vItemFamily = pItemList.ItemsByCode[pOutfitItem.Code]
	
	if not vItemFamily then
		return 0
	end
	
	local vNumItemsFound = 0
	
	for vIndex, vItem in ipairs(vItemFamily) do
		if (pAllowSubCodeWildcard and not pOutfitItem.SubCode)
		or vItem.SubCode == pOutfitItem.SubCode then
			table.insert(rItems, vItem)
			vNumItemsFound = vNumItemsFound + 1
		end
	end
	
	return vNumItemsFound
end

function Outfitter.ItemList_FindItemIndex(pItemList, pOutfitItem, pAllowSubCodeWildcard)
	if not pItemList then
		return
	end
	
	local vItemFamily = pItemList.ItemsByCode[pOutfitItem.Code]
	
	if not vItemFamily then
		return
	end
	
	local vBestMatch = nil
	local vBestMatchIndex = nil
	local vNumItemsFound = 0
	local vFoundIgnoredItem = nil
	
	for vIndex, vItem in ipairs(vItemFamily) do
		-- All done if the caller doesn't care about the SubCode
		
		if pAllowSubCodeWildcard
		and not pOutfitItem.SubCode then
			if vItem.IgnoreItem then
				vFoundIgnoredItem = vItem
			else
				return vItem, vIndex, vItemFamily, nil
			end
		
		-- If the subcode matches then check for an enchant match
		
		elseif vItem.SubCode == pOutfitItem.SubCode then
			-- If the enchant matches then we're all done
			
			if vItem.EnchantCode == pOutfitItem.EnchantCode 
			and vItem.JewelCode1 == pOutfitItem.JewelCode1 
			and vItem.JewelCode2 == pOutfitItem.JewelCode2
			and vItem.JewelCode3 == pOutfitItem.JewelCode3 
			and vItem.JewelCode4 == pOutfitItem.JewelCode4
			and vItem.UniqueID == pOutfitItem.UniqueID then
				if vItem.IgnoreItem then
					vFoundIgnoredItem = vItem
				else
					return vItem, vIndex, vItemFamily
				end
			
			-- Otherwise save the match in case a better one can
			-- be found
			
			else
				if vItem.IgnoreItem then
					if not vFoundIgnoredItem then
						vFoundIgnoredItem = vItem
					end
				else
					vBestMatch = vItem
					vBestMatchIndex = vIndex
					vNumItemsFound = vNumItemsFound + 1
				end
			end
		end
	end
	
	-- Return the match if only one item was found
	
	if vNumItemsFound == 1
	and not vBestMatch.IgnoreItem then
		return vBestMatch, vBestMatchIndex, vItemFamily, nil
	end
	
	return nil, nil, nil, vFoundIgnoredItem
end
		
function Outfitter.ItemList_GetItemStats(pItem, pDistribution)
	if pItem.Stats then
		return pItem.Stats
	end
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	
	if pItem.SlotName then
		local vHasItem = OutfitterTooltip:SetInventoryItem("player", Outfitter.cSlotIDs[pItem.SlotName])
		
		if not vHasItem then
			OutfitterTooltip:Hide()
			return nil
		end
	elseif pItem.BagIndex == -1 then
		OutfitterTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(pItem.BagSlotIndex))
	else
		OutfitterTooltip:SetBagItem(pItem.BagIndex, pItem.BagSlotIndex)
	end
	
	local vStats = Outfitter:GetItemStatsFromTooltip(OutfitterTooltip)
	
	OutfitterTooltip:Hide()
	
	if not vStats then
		return nil
	end
	
	pItem.Stats = vStats
	
	if pDistribution then
		Outfitter:ConvertRatingsToStats(vStats)
		Outfitter:DistributeSecondaryStats(vStats, pDistribution)
	end

	return vStats
end

function Outfitter:IsBankBagIndex(pBagIndex)
	return pBagIndex and (pBagIndex > NUM_BAG_SLOTS or pBagIndex < 0)
end

function Outfitter.ItemList_GetMissingItems(pEquippableItems, pOutfit)
	if not pOutfit then
		Outfitter:DebugMessage("ItemList_GetMissingItems: pOutfit is nil")
		Outfitter:DebugStack()
		return
	end
	
	local vMissingItems = nil
	local vBankedItems = nil
	
	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		if vOutfitItem.Code ~= 0 then
			local vItem = Outfitter.ItemList_FindItemOrAlt(pEquippableItems, vOutfitItem)
			
			if not vItem then
				if not vMissingItems then
					vMissingItems = {}
				end
				
				table.insert(vMissingItems, vOutfitItem)
			elseif Outfitter:IsBankBagIndex(vItem.Location.BagIndex) then
				if not vBankedItems then
					vBankedItems = {}
				end
				
				table.insert(vBankedItems, vOutfitItem)
			end
		end
	end
	
	return vMissingItems, vBankedItems
end

function Outfitter.ItemList_CompiledUnusedItemsList(pEquippableItems)
	Outfitter.ItemList_ResetIgnoreItemFlags(pEquippableItems)
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local vItem = Outfitter.ItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true)
					
					if vItem then
						vItem.UsedInOutfit = true
					end
				end
			end
		end
	end
	
	local vUnusedItems = nil
	
	for vCode, vFamilyItems in pairs(pEquippableItems.ItemsByCode) do
		for vIndex, vOutfitItem in ipairs(vFamilyItems) do
			if not vOutfitItem.UsedInOutfit
			and vOutfitItem.ItemSlotName ~= "AmmoSlot"
			and Outfitter.cIgnoredUnusedItems[vOutfitItem.Code] == nil then
				if not vUnusedItems then
					vUnusedItems = {}
				end
				
				table.insert(vUnusedItems, vOutfitItem)
			end
		end
	end
	
	pEquippableItems.UnusedItems = vUnusedItems
end

function Outfitter.ItemList_ItemsAreSame(pEquippableItems, pItem1, pItem2)
	if not pItem1 then
		return pItem2 == nil
	end
	
	if not pItem2 then
		return false
	end
	
	if pItem1.Code == 0 then
		return pItem2.Code == 0
	end
	
	if pItem1.Code ~= pItem2.Code
	or pItem1.SubCode ~= pItem2.SubCode then
		return false
	end
	
	local vItems = {}
	local vNumItems = Outfitter.ItemList_FindAllItemsOrAlt(pEquippableItems, pItem1, nil, vItems)
	
	if vNumItems == 0 then
		-- Shouldn't ever get here
		
		Outfitter:DebugMessage("Outfitter.ItemList_ItemsAreSame: Item not found")
		Outfitter:DebugTable("Item", pItem1)
		
		return false
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's the same
		
		return true
	else
		return pItem1.EnchantCode == pItem2.EnchantCode
		   and pItem1.JewelCode1 == pItem2.JewelCode1
		   and pItem1.JewelCode2 == pItem2.JewelCode2
		   and pItem1.JewelCode3 == pItem2.JewelCode3
		   and pItem1.JewelCode4 == pItem2.JewelCode4
		   and pItem1.UniqueID == pItem2.UniqueID
	end
end

function Outfitter.ItemList_InventorySlotContainsItem(pEquippableItems, pInventorySlot, pOutfitItem)
	-- Nil items are supposed to be ignored, so never claim the slot contains them
	
	if pOutfitItem == nil then
--		Outfitter:DebugMessage("InventorySlotContainsItem: OutfitItem is nil")
		return false, nil
	end
	
	-- If the item specifies an empty slot check to see if the slot is actually empty
	
	if pOutfitItem.Code == 0 then
		return pEquippableItems.InventoryItems[pInventorySlot] == nil
	end
	
	local vItems = {}
	local vNumItems = Outfitter.ItemList_FindAllItemsOrAlt(pEquippableItems, pOutfitItem, nil, vItems)
	
	if vNumItems == 0 then
--		Outfitter:DebugMessage("InventorySlotContainsItem: OutfitItem not found")
--		Outfitter:DebugTable("InventorySlotContainsItem: OutfitItem", pOutfitItem)
		
		return false
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's in the slot
		
		local vMatch = vItems[1].Location.SlotName == pInventorySlot
		
		if not vMatch then
--			Outfitter:DebugMessage("InventorySlotContainsItem: Slots don't match %s", tostring(pInventorySlot))
--			Outfitter:DebugTable("InventorySlotContainsItem: Item", vItems[1])
		end
		
		return vMatch, vItems[1]
	else
		-- See if one of the items is in the slot
		
		for vIndex, vItem in ipairs(vItems) do
			if vItem.Location.SlotName == pInventorySlot then
				-- Must match the enchant and jewel codes if there are multiple items
				-- in order to be considered a perfect match
				
				local vCodesMatch = vItem.EnchantCode == pOutfitItem.EnchantCode
				                and vItem.JewelCode1 == pOutfitItem.JewelCode1
				                and vItem.JewelCode2 == pOutfitItem.JewelCode2
				                and vItem.JewelCode3 == pOutfitItem.JewelCode3
				                and vItem.JewelCode4 == pOutfitItem.JewelCode4
				                and vItem.UniqueID == pOutfitItem.UniqueID
				
				if not vCodesMatch then
--					Outfitter:DebugMessage("InventorySlotContainsItem: Items don't match")
--					Outfitter:DebugTable("InventorySlotContainsItem: OutfitItem", pOutfitItem)
--					Outfitter:DebugTable("InventorySlotContainsItem: Item", vItem)
				end
				
				return vCodesMatch, vItem
			end
		end
		
		-- No items in the slot
		
--		Outfitter:DebugMessage("InventorySlotContainsItem: Items don't match -- no item")
--		Outfitter:DebugTable("InventorySlotContainsItem: OutfitItem", pOutfitItem)
		
		return false, nil
	end
end
