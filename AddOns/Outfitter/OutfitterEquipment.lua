Outfitter.EquipmentUpdateCount = 0

function Outfitter:DebugEquipmentChangeList(pEquipmentChangeList)
	Outfitter:DebugMark()
	Outfitter:DebugTable("ChangeList", pEquipmentChangeList)
end

function Outfitter:BuildUnequipChangeList(pOutfit, pEquippableItems)
	local vEquipmentChangeList = {}

	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		local vItem, vIgnoredItem = Outfitter.ItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true)
		
		if vItem then
			table.insert(vEquipmentChangeList, {FromLocation = vItem.Location, Item = vItem, ToLocation = nil})
		end
	end -- for
	
	return vEquipmentChangeList
end

function Outfitter:BuildEquipmentChangeList(pOutfit, pEquippableItems)
	local vEquipmentChangeList = {}
	
	Outfitter.ItemList_ResetIgnoreItemFlags(pEquippableItems)
	
	-- Remove items which are already in the correct slot from the outfit and from the
	-- equippable items list
	
	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		local vContainsItem, vItem = Outfitter.ItemList_InventorySlotContainsItem(pEquippableItems, vInventorySlot, vOutfitItem)
		
		if vContainsItem then
			pOutfit.Items[vInventorySlot] = nil
			
			if vItem then
				vItem.IgnoreItem = true
			end
		end
	end
	
	-- Scan the outfit using the Outfitter.cSlotNames array as an index so that changes
	-- are executed in the specified order.  The order is designed so that items with
	-- durability values are unequipped first, followed by other items such as cloaks and rings
	-- which have no durability.  This makes unequipping before a wipe more practical for
	-- classes who can get away with it (Feign Death ftw, or "for the repair bill" I should say).
	
	self.EquippedUniqueGemIndex = self:RecycleTable(self.EquippedUniqueGemIndex)
	self.EquippedUniqueGemItem = self:RecycleTable(self.EquippedUniqueGemItem)
	
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		local vOutfitItem = pOutfit.Items[vInventorySlot]
		
		if vOutfitItem then
			local vSlotID = Outfitter.cSlotIDs[vInventorySlot]
			local vCurrentItemInfo = self:GetInventoryItemInfo(vInventorySlot)
			local vInsertBefore = #vEquipmentChangeList + 1
			
			-- The CurrentItemInfo is the item being unequipped.  If another item
			-- with the same gem has already been equipped, then insert the unequip
			-- entry before that one
			
			if vCurrentItemInfo then
				for vIndex = 1, 4 do
					local vJewelCode = vCurrentItemInfo["JewelCode"..vIndex]
					
					if self.EquippedUniqueGemIndex[vJewelCode] then
						-- Move this unequip operation above the first gem it conflicts with
						
						if not vInsertBefore
						or self.EquippedUniqueGemIndex[vJewelCode] < vInsertBefore then
							vInsertBefore = self.EquippedUniqueGemIndex[vJewelCode]
						end
						
						self.EquippedUniqueGemIndex[vJewelCode] = nil
						self.EquippedUniqueGemItem[vJewelCode] = nil
					end
				end
			end
						
			-- Empty the slot if it's supposed to be blank
			
			if vOutfitItem.Code == 0 or vOutfitItem.Code == nil then
				if vCurrentItemInfo then
					table.insert(vEquipmentChangeList, vInsertBefore, {SlotName = vInventorySlot, SlotID = vSlotID, ItemName = vOutfitItem.Name, ItemLocation = nil})
					
					-- Adjust any entries in the EquippedUniqueGemIndex table to account for the insertion
					
					for vJewelCode, vChangeIndex in pairs(self.EquippedUniqueGemIndex) do
						if vChangeIndex >= vInsertBefore then
							self.EquippedUniqueGemIndex[vJewelCode] = vChangeIndex + 1
						end
					end
				end
			else
				-- Find the item
				
				local vItem, vIgnoredItem = Outfitter.ItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true)
				
				-- If the item wasn't found then show an appropriate error message

				if not vItem then
					self:ShowEquipError(vOutfitItem, vIgnoredItem, vInventorySlot)
				
				-- Otherwise generate a change to move the item from its present location to the correct slot
				
				else
					pOutfit.Items[vInventorySlot].MetaSlotName = vItem.MetaSlotName
					
					local vEquipmentChange = {SlotName = vInventorySlot, SlotID = vSlotID, ItemName = vOutfitItem.Name, ItemMetaSlotName = vItem.MetaSlotName, ItemLocation = vItem.Location}
					
					if vEquipmentChange.ItemMetaSlotName == "TwoHandSlot"
					and not Outfitter:ItemUsesBothWeaponSlots(vOutfitItem) then
						vEquipmentChange.ItemMetaSlotName = "Weapon0Slot"
					end
					
					table.insert(vEquipmentChangeList, vInsertBefore, vEquipmentChange)
					
					-- Adjust any entries in the EquippedUniqueGemIndex table to account for the insertion
					
					for vJewelCode, vChangeIndex in pairs(self.EquippedUniqueGemIndex) do
						if vChangeIndex >= vInsertBefore then
							self.EquippedUniqueGemIndex[vJewelCode] = vChangeIndex + 1
						end
					end
					
					-- Note any unique-equipped gems being put on
					
					for vIndex = 1, 4 do
						local vJewelCode = vItem["JewelCode"..vIndex]
						
						if self.cUniqueEquippedGemIDs[vJewelCode] then
							if self.EquippedUniqueGemIndex[vJewelCode] then
								-- Another item with the same jewel code is already being equipped, just warn the user
								
								Outfitter:NoteMessage("Attempting to equip %s and %s, but they have the same unique-equipped gem", vOutfitItem.Name or "unknown", self.EquippedUniqueGemItem[vJewelCode].Name or "unknown")
							else
								self.EquippedUniqueGemIndex[vJewelCode] = vInsertBefore
								self.EquippedUniqueGemItem[vJewelCode] = vOutfitItem
							end
						end -- if cUniqueEquippedGemIDs
					end -- for vIndex
				end -- else not vItem
			end -- else vOutfitItem.Code == 0 or vOutfitItem.Code == nil
		end -- if
	end -- for
	
	if #vEquipmentChangeList == 0 then
		return nil
	end
	
	Outfitter:OptimizeEquipmentChangeList(vEquipmentChangeList)
	
	return vEquipmentChangeList
end

function Outfitter:PickupItemLocation(pItemLocation)
	if pItemLocation == nil then
		self:ErrorMessage("nil location in PickupItemLocation")
		return
	end
	
	if pItemLocation.BagIndex then
		if CT_oldPickupContainerItem then
			CT_oldPickupContainerItem(pItemLocation.BagIndex, pItemLocation.BagSlotIndex)
		else
			PickupContainerItem(pItemLocation.BagIndex, pItemLocation.BagSlotIndex)
		end
	elseif pItemLocation.SlotName then
		PickupInventoryItem(self.cSlotIDs[pItemLocation.SlotName])
	else
		self:ErrorMessage("Unknown location in PickupItemLocation")
		return
	end
end

function Outfitter:ShowEquipError(pOutfitItem, pIgnoredItem, pInventorySlot)
	if pOutfitItem.Name then
		if pIgnoredItem then
			local vSlotDisplayName = Outfitter.cSlotDisplayNames[pInventorySlot]
			
			if not vSlotDisplayName then
				vSlotDisplayName = pInventorySlot
			end
			
			Outfitter:ErrorMessage(format(Outfitter.cItemAlreadyUsedError, pOutfitItem.Name, vSlotDisplayName))
		else
			Outfitter:ErrorMessage(format(Outfitter.cItemNotFoundError, pOutfitItem.Name))
		end
	else
		Outfitter:ErrorMessage(format(Outfitter.cItemNotFoundError, "unknown"))
	end
end

function Outfitter:FindEquipmentChangeForSlot(pEquipmentChangeList, pSlotName)
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.SlotName == pSlotName then
			return vChangeIndex, vEquipmentChange
		end
	end
	
	return nil, nil
end

function Outfitter:FixSlotSwapChange(pEquipmentList, pChangeIndex1, pEquipmentChange1, pSlotName1, pChangeIndex2, pEquipmentChange2, pSlotName2)
	-- No problem if both slots will be emptied
	
	if not pEquipmentChange1.ItemLocation
	and not pEquipmentChange2.ItemLocation then
		return
	end
	
	-- No problem if neither slot is being moved to the other one
	
	local vSlot2ToSlot1 = pEquipmentChange1.ItemLocation ~= nil
			            and pEquipmentChange1.ItemLocation.SlotName == pSlotName2
	
	local vSlot1ToSlot2 = pEquipmentChange2.ItemLocation ~= nil
			            and pEquipmentChange2.ItemLocation.SlotName == pSlotName1
	
	-- No problem if the slots are swapping with each other
	-- or not moving between each other at all
	
	if vSlot2ToSlot1 == vSlot1ToSlot2 then
		return
	end
	
	-- Slot 1 is moving to slot 2
	
	if vSlot1ToSlot2 then
		
		if pEquipmentChange1.ItemLocation then
			-- Swap change 1 and change 2 around
			
			pEquipmentList[pChangeIndex1] = pEquipmentChange2
			pEquipmentList[pChangeIndex2] = pEquipmentChange1
			
			-- Insert a change to empty slot 2
			
			table.insert(pEquipmentList, pChangeIndex1, {SlotName = pEquipmentChange2.SlotName, SlotID = pEquipmentChange2.SlotID, ItemLocation = nil})
		else
			-- Slot 1 is going to be empty, so empty slot 2 instead
			-- and then when slot 1 is moved it'll swap the empty space
			
			pEquipmentChange1.SlotName = pSlotName2
			pEquipmentChange1.SlotID = pEquipmentChange2.SlotID
			pEquipmentChange1.ItemLocation = nil
		end
		
	-- Slot 2 is moving to slot 1
	
	else
		if pEquipmentChange2.ItemLocation then
			-- Insert a change to empty slot 1 first
			
			table.insert(pEquipmentList, pChangeIndex1, {SlotName = pEquipmentChange1.SlotName, SlotID = pEquipmentChange1.SlotID, ItemLocation = nil})
		else
			-- Slot 2 is going to be empty, so empty slot 1 instead
			-- and then when slot 2 is moved it'll swap the empty space
			
			pEquipmentChange2.SlotName = pSlotName1
			pEquipmentChange2.SlotID = pEquipmentChange1.SlotID
			pEquipmentChange2.ItemLocation = nil
			
			-- Change the order so that slot 1 gets emptied before the move
			
			pEquipmentList[pChangeIndex1] = pEquipmentChange2
			pEquipmentList[pChangeIndex2] = pEquipmentChange1
		end
	end
end

function Outfitter:OptimizeEquipmentChangeList(pEquipmentChangeList)
	local vSwapList =
	{
		{Slot1 = "Finger0Slot", Slot2 = "Finger1Slot"},
		{Slot1 = "Trinket0Slot", Slot2 = "Trinket1Slot"},
		{Slot1 = "MainHandSlot", Slot2 = "SecondaryHandSlot"},
	}
	
	local vDidSlot = {}
	
	local vChangeIndex = 1
	local vNumChanges = #pEquipmentChangeList
	
	while vChangeIndex <= vNumChanges do
		local vEquipmentChange = pEquipmentChangeList[vChangeIndex]
		
		-- If a two-hand weapon is being equipped, remove the change event
		-- for removing the offhand slot
		
		if vEquipmentChange.ItemMetaSlotName == "TwoHandSlot" then
			local vChangeIndex2, vEquipmentChange2 = Outfitter:FindEquipmentChangeForSlot(pEquipmentChangeList, "SecondaryHandSlot")
			
			-- If there's a change for the offhand slot, remove it
			
			if vChangeIndex2 then
				table.remove(pEquipmentChangeList, vChangeIndex2)
				
				if vChangeIndex2 < vChangeIndex then
					vChangeIndex = vChangeIndex - 1
				end
				
				vNumChanges = vNumChanges - 1
			end
			
			-- Insert a new change for the offhand slot to empty it ahead
			-- of equipping the two-hand item
			
			local vSlotID = Outfitter.cSlotIDs.SecondaryHandSlot
			
			table.insert(pEquipmentChangeList, vChangeIndex, {SlotName = "SecondaryHandSlot", SlotID = vSlotID, ItemLocation = nil})
			
		-- Otherwise see if the change needs to be re-arranged so that slot
		-- swapping works correctly
		
		else
			for vSwapListIndex, vSwapSlotInfo in ipairs(vSwapList) do
				if vEquipmentChange.SlotName == vSwapSlotInfo.Slot1
				and not vDidSlot[vEquipmentChange.SlotName] then
					local vChangeIndex2, vEquipmentChange2 = Outfitter:FindEquipmentChangeForSlot(pEquipmentChangeList, vSwapSlotInfo.Slot2)
					
					if vChangeIndex2 then
						Outfitter:FixSlotSwapChange(pEquipmentChangeList, vChangeIndex, vEquipmentChange, vSwapSlotInfo.Slot1, vChangeIndex2, vEquipmentChange2, vSwapSlotInfo.Slot2)
					end
					
					vDidSlot[vEquipmentChange.SlotName] = true
					
					vNumChanges = #pEquipmentChangeList
				end
			end
		end
		
		-- Check for a unique-equipped gem being put on, then if the same gem is being removed
		-- we can move the unequipping one to happen first
		
		
		
		--
		
		vChangeIndex = vChangeIndex + 1
	end
end

function Outfitter:ExecuteEquipmentChangeList(pEquipmentChangeList, pEmptyBagSlots, pExpectedEquippableItems)
	local vSaved_EnableSFX
	
	if gOutfitter_Settings.DisableEquipSounds then
		vSaved_EnableSFX = GetCVar("Sound_EnableSFX")
		SetCVar("Sound_EnableSFX", "0")
	end
	
	ClearCursor() -- Make sure nothing is already being held
	
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.ItemLocation then
			self:PickupItemLocation(vEquipmentChange.ItemLocation)
			EquipCursorItem(vEquipmentChange.SlotID)
			
			if pExpectedEquippableItems then
				self.ItemList_SwapLocationWithInventorySlot(pExpectedEquippableItems, vEquipmentChange.ItemLocation, vEquipmentChange.SlotName)
			end
		else
			-- Remove the item
			
			if not pEmptyBagSlots
			or #pEmptyBagSlots == 0 then
				local vItemInfo = self:GetInventoryItemInfo(vEquipmentChange.SlotName)
				
				if not vItemInfo then
					self:ErrorMessage("Internal error: Can't empty slot %s because bags are full but slot is empty", vEquipmentChange.SlotName)
				else
					self:ErrorMessage(format(self.cBagsFullError, vItemInfo.Name))
				end
			else
				local vBagIndex = pEmptyBagSlots[1].BagIndex
				local vBagSlotIndex = pEmptyBagSlots[1].BagSlotIndex
				
				table.remove(pEmptyBagSlots, 1)
				
				PickupInventoryItem(vEquipmentChange.SlotID)
				if CT_oldPickupContainerItem then
					CT_oldPickupContainerItem(vBagIndex, vBagSlotIndex)
				else
					PickupContainerItem(vBagIndex, vBagSlotIndex)
				end
				
				if pExpectedEquippableItems then
					self.ItemList_SwapBagSlotWithInventorySlot(pExpectedEquippableItems, vBagIndex, vBagSlotIndex, vEquipmentChange.SlotName)
				end
			end
		end
	end
	
	if vSaved_EnableSFX then
		SetCVar("Sound_EnableSFX", vSaved_EnableSFX)
	end
end

function Outfitter:ExecuteEquipmentChangeList2(pEquipmentChangeList, pEmptySlots, pBagsFullErrorFormat, pExpectedEquippableItems)
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.ToLocation then
			self:PickupItemLocation(vEquipmentChange.FromLocation)
			EquipCursorItem(vEquipmentChange.SlotID)
			
			if pExpectedEquippableItems then
				self.ItemList_SwapLocationWithInventorySlot(pExpectedEquippableItems, vEquipmentChange.ToLocation, vEquipmentChange.SlotName)
			end
		else
			-- Remove the item
			
			if not pEmptySlots
			or #pEmptySlots == 0 then
				self:ErrorMessage(format(pBagsFullErrorFormat, vEquipmentChange.Item.Name))
			else
				local vToLocation = {BagIndex = pEmptySlots[1].BagIndex, BagSlotIndex = pEmptySlots[1].BagSlotIndex}
				
				table.remove(pEmptySlots, 1)
				
				self:PickupItemLocation(vEquipmentChange.FromLocation)
				self:PickupItemLocation(vToLocation)
				
				if pExpectedEquippableItems then
					self.ItemList_SwapLocations(pExpectedEquippableItems, vEquipmentChange.FromLocation, vToLocation)
				end
			end
		end
	end
end

function Outfitter:BeginEquipmentUpdate()
	self.EquipmentUpdateCount = self.EquipmentUpdateCount + 1
end

function Outfitter:EndEquipmentUpdate(pCallerName, pUpdateNow)
	self.EquipmentUpdateCount = self.EquipmentUpdateCount - 1
	
	if self.EquipmentUpdateCount == 0 then
		if pUpdateNow then
			if self.Debug.EquipmentChanges then
				self:TestMessage("EndEquipmentUpdate: updating now")
			end
			self:UpdateEquippedItems()
		else
			self:ScheduleEquipmentUpdate()
		end
		
		self:Update(false)
	end
end

function Outfitter:UpdateEquippedItems()
	if not self.EquippedNeedsUpdate
	and not self.WeaponsNeedUpdate then
		if self.Debug.EquipmentChanges then
			self:TestMessage("UpdateEquippedItems: no update necessary")
		end
		return
	end
	
	if self.Debug.EquipmentChanges then
		self:TestMessage("UpdateEquippedItems: updating equipment")
	end
	
	-- Delay all changes until they're alive or not casting a spell
	
	if self.IsDead
	or self.IsCasting
	or self.IsChanneling then
		return
	end
	
	local vCurrentTime = GetTime()
	
	if vCurrentTime - self.LastEquipmentUpdateTime < self.cMinEquipmentUpdateInterval then
		self:ScheduleEquipmentUpdate()
		return
	end
	
	self.LastEquipmentUpdateTime = vCurrentTime
	
	local vWeaponsNeedUpdate = self.WeaponsNeedUpdate
	
	self.EquippedNeedsUpdate = false
	self.WeaponsNeedUpdate = false
	
	-- Compile the outfit
	
	local vEquippableItems = self.ItemList_GetEquippableItems()
	local vCompiledOutfit = self:GetCompiledOutfit()
	
	-- If the outfit contains non-weapon changes then
	-- delay the change until they're out of combat but go
	-- ahead and swap the weapon slots if there are any
	
	if self.InCombat or self.MaybeInCombat then
		if vWeaponsNeedUpdate
		and self:OutfitHasCombatEquipmentSlots(vCompiledOutfit) then
			
			-- Allow the weapon change to proceed but defer the rest
			-- until they're out of combat
			
			local vWeaponOutfit = self:NewEmptyOutfit()
			
			for vEquipmentSlot, _ in pairs(self.cCombatEquipmentSlots) do
				vWeaponOutfit.Items[vEquipmentSlot] = vCompiledOutfit.Items[vEquipmentSlot]
			end
			
			-- Still need to update the rest once they exit combat
			-- if there are non-equipment slot items
			
			if not self:OutfitOnlyHasCombatEquipmentSlots(vCompiledOutfit) then
				self.EquippedNeedsUpdate = true
			end
			
			-- Switch to the weapons-only part
			
			vCompiledOutfit = vWeaponOutfit
		else
			-- No weapon changes, just defer the whole outfit change
			
			self.EquippedNeedsUpdate = true
			self:ScheduleEquipmentUpdate()
			return
		end
	end
	
	-- Equip it
	
	local vEquipmentChangeList = self:BuildEquipmentChangeList(vCompiledOutfit, vEquippableItems)
	
	if vEquipmentChangeList then
		-- local vExpectedEquippableItems = self.ItemList_New()
	
		self:DebugTable("EquipmentChangeList", vEquipmentChangeList)
		
		self:ExecuteEquipmentChangeList(vEquipmentChangeList, self:GetEmptyBagSlotList(), vExpectedEquippableItems)
		
		self:DebugTable("ExpectedEquippableItems", vExpectedEquippableItems)
	end
	
	-- Update the outfit we're expecting to see on the player
	
	for vInventorySlot, vItem in pairs(vCompiledOutfit.Items) do
		self.ExpectedOutfit.Items[vInventorySlot] = vCompiledOutfit.Items[vInventorySlot]
	end
	
	self.MaybeInCombat = false
	
	self:ScheduleEquipmentUpdate()
end

function Outfitter:ScheduleEquipmentUpdate()
	if not self.EquippedNeedsUpdate
	and not self.WeaponsNeedUpdate then
		if self.Debug.EquipmentChanges then
			self:TestMessage("ScheduleEquipmentUpdate: no update necessary")
		end
		return
	end
	
	local vElapsed = GetTime() - self.LastEquipmentUpdateTime
	local vDelay = self.cMinEquipmentUpdateInterval - vElapsed
	
	 if vDelay < 0.05 then
		vDelay = 0.05
	end
	
	if self.Debug.EquipmentChanges then
		self:TestMessage("ScheduleEquipmentUpdate: updating in %d seconds", vDelay)
	end
	
	MCSchedulerLib:ScheduleUniqueTask(vDelay, self.UpdateEquippedItems, self)
end

----------------------------------------
-- Outfitter.OutfitStack
----------------------------------------

function Outfitter.OutfitStack:Initialize()
	self:RestoreSavedStack()
end

function Outfitter.OutfitStack:RestoreSavedStack()
	if not gOutfitter_Settings.LastOutfitStack then
		gOutfitter_Settings.LastOutfitStack = {}
	end
	
	for vIndex, vOutfit in ipairs(gOutfitter_Settings.LastOutfitStack) do
		if vOutfit.Name then
			vOutfit = Outfitter:FindOutfitByName(vOutfit.Name)
		end
		
		if vOutfit then
			table.insert(self.Outfits, vOutfit)
		end
	end
	
	Outfitter.ExpectedOutfit = Outfitter:GetCompiledOutfit()
	
	Outfitter:UpdateTemporaryOutfit(Outfitter:GetNewItemsOutfit(Outfitter.ExpectedOutfit))
	
	if gOutfitter_Settings.Options.ShowStackContents then
		self:DebugOutfitStack("Restore saved stack")
	end
end

function Outfitter.OutfitStack:AddOutfit(pOutfit, pLayerID)
	local vFound, vIndex = self:FindOutfit(pOutfit)
	
	-- If it's already on then remove it from the stack
	-- so it can be added to the end
	
	if vFound then
		table.remove(self.Outfits, vIndex)
		table.remove(gOutfitter_Settings.LastOutfitStack, vIndex)
		
		for vLayerID, vLayerIndex in pairs(gOutfitter_Settings.LayerIndex) do
			if vIndex < vLayerIndex then
				gOutfitter_Settings.LayerIndex[vLayerID] = vLayerIndex - 1
			end
		end
		
		Outfitter:DispatchOutfitEvent("UNWEAR_OUTFIT", pOutfit.Name, pOutfit)
	end
	
	-- Figure out the position to insert at
	
	local vStackLength = #self.Outfits
	local vInsertIndex = vStackLength + 1
	
	local vLayerIndex = gOutfitter_Settings.LayerIndex[pLayerID]
	
	if vLayerIndex then
		vInsertIndex = vLayerIndex
	end
	
	if pLayerID then
		gOutfitter_Settings.LayerIndex[pLayerID] = vInsertIndex
	end
	
	-- Adjust the layer indices
	
	for vLayerID, vLayerIndex in pairs(gOutfitter_Settings.LayerIndex) do
		if vInsertIndex < vLayerIndex then
			gOutfitter_Settings.LayerIndex[vLayerID] = vLayerIndex + 1
		end
	end
	
	-- Add the outfit
	
	table.insert(self.Outfits, vInsertIndex, pOutfit)
	
	if pOutfit.Name then
		table.insert(gOutfitter_Settings.LastOutfitStack, vInsertIndex, {Name = pOutfit.Name})
	else
		table.insert(gOutfitter_Settings.LastOutfitStack, vInsertIndex, pOutfit)
	end
	
	Outfitter.DisplayIsDirty = true
	
	if gOutfitter_Settings.Options.ShowStackContents then
		self:DebugOutfitStack("Add outfit")
	end
	
	if vFound then
		self:CollapseTemporaryOutfits()
	end
	
	Outfitter:DispatchOutfitEvent("WEAR_OUTFIT", pOutfit.Name, pOutfit)
end

function Outfitter.OutfitStack:RemoveOutfit(pOutfit)
	local vFound, vIndex = self:FindOutfit(pOutfit)
	
	if not vFound then
		return false
	end
	
	-- Remove the outfit
	
	table.remove(self.Outfits, vIndex)
	table.remove(gOutfitter_Settings.LastOutfitStack, vIndex)
	
	self:CollapseTemporaryOutfits()
			
	for vLayerID, vLayerIndex in pairs(gOutfitter_Settings.LayerIndex) do
		if vIndex < vLayerIndex then
			gOutfitter_Settings.LayerIndex[vLayerID] = vLayerIndex - 1
		end
	end
	
	Outfitter.DisplayIsDirty = true
	
	if gOutfitter_Settings.Options.ShowStackContents then
		self:DebugOutfitStack("Remove outfit")
	end
	
	return true
end

function Outfitter.OutfitStack:FindOutfit(pOutfit)
	for vIndex, vOutfit in ipairs(self.Outfits) do
		if vOutfit == pOutfit then
			return true, vIndex
		end
	end
	
	return false, nil
end

function Outfitter.OutfitStack:FindOutfitByCategory(pCategoryID)
	for vIndex, vOutfit in ipairs(self.Outfits) do
		if vOutfit.CategoryID == pCategoryID then
			return true, vIndex
		end
	end
	
	return false, nil
end

function Outfitter.OutfitStack:Clear()
	for vIndex, vOutfit in ipairs(self.Outfits) do
		Outfitter:DispatchOutfitEvent("UNWEAR_OUTFIT", vOutfit.Name, vOutfit)
	end
	
	Outfitter:EraseTable(self.Outfits)
	
	gOutfitter_Settings.LastOutfitStack = Outfitter:RecycleTable(gOutfitter_Settings.LastOutfitStack)
	gOutfitter_Settings.LayerIndex = Outfitter:RecycleTable(gOutfitter_Settings.LayerIndex)
	Outfitter.DisplayIsDirty = true
	
	if gOutfitter_Settings.Options.ShowStackContents then
		Outfitter:DebugMessage("Outfitter stack cleared")
	end
end

function Outfitter.OutfitStack:ClearCategory(pCategoryID)
	local vIndex = 1
	local vStackLength = #self.Outfits
	local vChanged = false
	
	while vIndex <= vStackLength do
		local vOutfit = self.Outfits[vIndex]
		
		if vOutfit
		and vOutfit.CategoryID == pCategoryID then
			-- Remove the outfit from the stack
			
			table.remove(self.Outfits, vIndex)
			table.remove(gOutfitter_Settings.LastOutfitStack, vIndex)
			
			vStackLength = vStackLength - 1
			vChanged = true
			
			-- Adjust the layer indices
			
			for vLayerID, vLayerIndex in pairs(gOutfitter_Settings.LayerIndex) do
				if vIndex < vLayerIndex then
					gOutfitter_Settings.LayerIndex[vLayerID] = vLayerIndex - 1
				end
			end
			
			Outfitter:DispatchOutfitEvent("UNWEAR_OUTFIT", vOutfit.Name, vOutfit)
		else
			vIndex = vIndex + 1
		end
	end
	
	self:CollapseTemporaryOutfits()
	
	if vChanged then
		if gOutfitter_Settings.Options.ShowStackContents then
			self:DebugOutfitStack("Clear category "..pCategoryID)
		end
		
		Outfitter.DisplayIsDirty = true
	end
end

function Outfitter.OutfitStack:GetTemporaryOutfit()
	local vStackSize = #self.Outfits
	
	if vStackSize == 0 then
		return nil
	end
	
	local vOutfit = self.Outfits[vStackSize]
	
	if vOutfit.Name then
		return nil
	end
	
	return vOutfit
end

function Outfitter.OutfitStack:CollapseTemporaryOutfits()
	local vIndex = 1
	local vStackLength = #self.Outfits
	local vTemporaryOutfit1 = nil
	
	while vIndex <= vStackLength do
		local vOutfit = self.Outfits[vIndex]
		
		if vOutfit
		and vOutfit.Name == nil then
			if vTemporaryOutfit1 then
				-- Copy the items up
				
				for vInventorySlot, vItem in pairs(vTemporaryOutfit1.Items) do
					if not vOutfit.Items[vInventorySlot] then
						vOutfit.Items[vInventorySlot] = vItem
					end
				end
				
				-- Remove the lower temp outfit
				
				table.remove(self.Outfits, vIndex - 1)
				vStackLength = vStackLength - 1
			else
				vIndex = vIndex + 1
			end
			
			vTemporaryOutfit1 = vOutfit
		else
			vTemporaryOutfit1 = nil
			vIndex = vIndex + 1
		end
	end
end

function Outfitter.OutfitStack:IsTopmostOutfit(pOutfit)
	local vStackLength = #self.Outfits
	
	if vStackLength == 0 then
		return false
	end
	
	return self.Outfits[vStackLength] == pOutfit
end

function Outfitter.OutfitStack:UpdateOutfitDisplay()
	local vShowHelm, vShowCloak, vShowTitleID
	
	for vIndex, vOutfit in ipairs(self.Outfits) do
		if vOutfit.ShowHelm ~= nil then
			vShowHelm = vOutfit.ShowHelm
		end
		
		if vOutfit.ShowCloak ~= nil then
			vShowCloak = vOutfit.ShowCloak
		end
		
		if vOutfit.ShowTitleID ~= nil then
			vShowTitleID = vOutfit.ShowTitleID
		end
	end -- for
	
	if vShowHelm == true then
		ShowHelm("1")
	elseif vShowHelm == false then
		ShowHelm("0")
	end
	
	if vShowCloak == true then
		ShowCloak("1")
	elseif vShowCloak == false then
		ShowCloak("0")
	end
	
	if vShowTitleID ~= nil then
		SetCurrentTitle(vShowTitleID)
	end
end

function Outfitter:TagOutfitLayer(pOutfit, pLayerID)
	local vFound, vIndex = Outfitter.OutfitStack:FindOutfit(pOutfit)
	
	if not vFound then
		return
	end
	
	gOutfitter_Settings.LayerIndex[pLayerID] = vIndex
end

function Outfitter.OutfitStack:DebugOutfitStack(pOperation)
	Outfitter:DebugMessage("Outfitter Stack Contents: "..pOperation)
	
	for vIndex, vOutfit in ipairs(self.Outfits) do
		if vOutfit.Name then
			Outfitter:DebugMessage("Slot "..vIndex..": "..vOutfit.Name)
		else
			Outfitter:DebugMessage("Slot "..vIndex..": Temporaray outfit")
		end
	end
	
	Outfitter:DebugTable("LayerIndex", gOutfitter_Settings.LayerIndex)
end

function Outfitter.OutfitStack:GetCurrentOutfitInfo()
	local vStackLength = #self.Outfits
	
	if vStackLength == 0 then
		return "", nil
	end
	
	local vOutfit = self.Outfits[vStackLength]
	
	if vOutfit and vOutfit.Name then
		return vOutfit.Name, vOutfit
	else
		return Outfitter.cCustom, vOutfit
	end
end

