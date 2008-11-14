--[[
	BagnonUtil
		A library of functions for accessing bag data
--]]

BagnonUtil = CreateFrame('Frame')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local currentPlayer = UnitName('player')


--[[ Bank ]]--

BagnonUtil:SetScript('OnEvent', function(self, event)
	self.atBank = (event == 'BANKFRAME_OPENED')
end)
BagnonUtil:RegisterEvent('BANKFRAME_OPENED')
BagnonUtil:RegisterEvent('BANKFRAME_CLOSED')

function BagnonUtil:AtBank()
	return self.atBank
end


--[[ Item/Bag Info Retrieval ]]--

function BagnonUtil:GetInvSlot(bag)
	return bag > 0 and ContainerIDToInventoryID(bag)
end

function BagnonUtil:GetBagSize(bag, player)
	if self:IsCachedBag(bag, player) then
		return (BagnonDB and BagnonDB:GetBagData(bag, player)) or 0
	end
	return (bag == KEYRING_CONTAINER and GetKeyRingSize()) or GetContainerNumSlots(bag)
end

function BagnonUtil:GetBagLink(bag, player)
	if self:IsCachedBag(bag, player) then
		return BagnonDB and (select(2, BagnonDB:GetBagData(bag, player)))
	end
	return GetInventoryItemLink('player', self:GetInvSlot(bag))
end

function BagnonUtil:GetBagType(bag, player)
	if bag == KEYRING_CONTAINER then
		return 256
	elseif bag > 0 then
		local link = self:GetBagLink(bag, player)
		return link and GetItemFamily(link)
	else
		return 0
	end
end

--returns all information about an item
function BagnonUtil:GetItemInfo(bag, slot, player)
	local link, count, texture, quality, readable, cached, locked, _

	if self:IsCachedBag(bag, player) then
		if BagnonDB then
			link, count, texture, quality = BagnonDB:GetItemData(bag, slot, player)
			cached = true
		end
	else
		link = GetContainerItemLink(bag, slot)
		if link then
			texture, count, locked, _, readable = GetContainerItemInfo(bag, slot)
			quality = select(3, GetItemInfo(link))
		end
	end

	return link, count, texture, quality, locked, readable, cached
end


function BagnonUtil:GetItemLink(bag, slot, player)
	if self:IsCachedBag(bag, player) then
		return BagnonDB and (BagnonDB:GetItemData(bag, slot, player))
	end
	return GetContainerItemLink(bag, slot)
end

function BagnonUtil:GetItemCount(bag, slot, player)
	if self:IsCachedBag(bag, player) then
		if BagnonDB then
			local link, count = BagnonDB:GetItemData(bag, slot, player)
			if link then
				return count or 1
			end
		else
			return 0
		end
	end
	return select(2, GetContainerItemInfo(bag, slot))
end


--[[ Bag Type Checks ]]--

--returns true if the given bag is cached AND we have a way of reading data for it
function BagnonUtil:IsCachedBag(bag, player)
	return currentPlayer ~= (player or currentPlayer) or (not self:AtBank() and self:IsBankBag(bag))
end

function BagnonUtil:IsInventoryBag(bag)
	return bag == KEYRING_CONTAINER or (bag > -1 and bag < 5)
end

function BagnonUtil:IsBankBag(bag)
	return (bag == BANK_CONTAINER or bag > 4)
end

--returns if the given bag is an ammo bag/soul bag
--bankslots, the main bag, and the keyring cannot be ammo slots
function BagnonUtil:IsAmmoBag(bag, player)
	local bagType = self:GetBagType(bag, player)
	return bagType == 1 or bagType == 2 or bagType == 4
end

--returns if the given bag is a profession bag (herb bag, engineering bag, etc)
--bankslots, the main bag, and the keyring cannot be ammo slots
function BagnonUtil:IsProfessionBag(bag, player)
	local bagType = self:GetBagType(bag, player)
	return bagType > 4 and bagType ~= 256
end


--[[ Non bag related stuff ]]--

--creates a new class of objects that inherits from objects of <type>, ex 'Frame', 'Button', 'StatusBar'
--does not chain inheritance
function BagnonUtil:CreateWidgetClass(type)
	local class = CreateFrame(type)
	local mt = {__index = class}

	function class:New(o)
		if o then
			local type, cType = o:GetFrameType(), self:GetFrameType()
			assert(type == cType, format("'%s' expected, got '%s'", cType, type))
		end
		return setmetatable(o or CreateFrame(type), mt)
	end

	return class
end


--[[ Settings ]]--

function BagnonUtil:GetSets()
	return Bagnon.sets
end

function BagnonUtil:SetShowBorders(enable)
	self:GetSets().showBorders = enable or nil

	local bags = Bagnon:GetInventory()
	if bags and bags:IsShown() then
		bags:Regenerate()
	end

	local bank = Bagnon:GetBank()
	if bank and bank:IsShown() then
		bank:Regenerate()
	end
end

function BagnonUtil:ShowingBorders()
	return Bagnon.sets.showBorders
end

function BagnonUtil:ReplacingBank()
	return Bagnon.sets.showBankAtBank
end