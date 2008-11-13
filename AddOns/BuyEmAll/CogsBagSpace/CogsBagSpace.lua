local revision = 2

if not CogsBagSpace or CogsBagSpace.revision < revision then
	local c = { revision = revision }
	CogsBagSpace = c
	
	--[[
	Herb & Enchanting item lists from Periodic Table
	]]
	local specialBagItems = {
		herb = "3358 8839 13466 4625 13467 3821 785 13465 13468 2450 2452 3818 3355 3357 8838 3369 3820 8153 8836 13463 8845 8846 13464 2447 2449 765 2453 3819 3356 8831",
		enchanting = "11083 16204 11137 11176 10940 11174 10938 11135 11175 16202 11134 16203 10998 11082 10939 11084 14343 11139 10978 11177 14344 11138 11178",
	}




	--[[
	Determine whether an item is an herb or enchanting material
	]]
	function c:IsSpecialBagItem(bagType, itemID)
		for curID in gmatch(specialBagItems[bagType], "%d+") do
			if itemID == curID then return true end
		end
		return false
	end




	--[[
	Determines the amount of an item you have in your bags.
	Parameters:
		itemID - the id of the item you are checking
	Returns:
		number of the given item in your bags
	]]
	function c:GetBagItemCount(itemID)
		local count = 0
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link and itemID == tonumber(strmatch(link, "item:(%d+):")) then
					count = count + select(2, GetContainerItemInfo(bag, slot))
				end
			end
		end
		
		return count
	end




	--[[
	Determines the amount of an item you can fit in your bags.
	Parameters:
		itemID - the id for the item
	Returns:
		freeSpace - Amount of the item you can fit in your bags (not including your
			quiver or ammo pouch)
		specialSpace - Amount of the item you can fit in your quiver or ammo pouch
		stackSize - Amount of the item in a full stack
	]]
	local returns = {}
	function c:FreeBagSpace(itemID)
		returns.freeSpace = 0
		returns.specialSpace = 0
		local itemSubType, stackSize = select(7, GetItemInfo(itemID))
		
		for theBag = 0,4 do
			local which, doBag = "freeSpace", true
			
			if theBag > 0 then -- 0 is always the backpack
				local bagLink = GetInventoryItemLink("player", 19 + theBag) -- Bag #1 is in inventory slot 20
				if bagLink then
					local bagSubType = select(7, GetItemInfo(bagLink))
					if bagSubType == "Ammo Pouch" and itemSubType == "Bullet" or
					   bagSubType == "Quiver" and itemSubType == "Arrow" then
						which = "specialSpace"
					elseif bagSubType == "Ammo Pouch" and itemSubType ~= "Bullet" or
						   bagSubType == "Quiver" and itemSubType ~= "Arrow" or
						   bagSubType == "Herb Bag"
								and not self:IsSpecialBagItem("herb",itemID) or
						   bagSubType == "Enchanting Bag"
								and not self:IsSpecialBagItem("enchanting",itemID) then
						doBag = false
					end
				else
					doBag = false
				end
			end
				
			if doBag then
				local numSlot = GetContainerNumSlots(theBag)
				for theSlot = 1, numSlot do
					local itemLink = GetContainerItemLink(theBag, theSlot)
					if not itemLink then
						returns[which] = returns[which] + stackSize
					elseif strfind(itemLink, "item:"..itemID..":") then
						local _,itemCount = GetContainerItemInfo(theBag, theSlot)
						returns[which] =
							returns[which] + stackSize - itemCount
					end
				end
			end
		end
		
		return returns.freeSpace, returns.specialSpace, stackSize
	end
end