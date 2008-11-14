local _G = _G
local LibStub = LibStub or error("LibStub not found!")
local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local pairs = pairs
local select = select
local tonumber = tonumber
local type = type

local GetActionCount = GetActionCount
local GetAuctionItemInfo = GetAuctionItemInfo
local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local GetContainerItemInfo = GetContainerItemInfo
local GetCraftReagentInfo = GetCraftReagentInfo
local GetGuildBankItemInfo = GetGuildBankItemInfo
local GetInboxItem = GetInboxItem
local GetInventoryItemCount = GetInventoryItemCount
local GetItemCount = GetItemCount
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootSlotInfo = GetLootSlotInfo
local GetMerchantItemCostItem = GetMerchantItemCostItem
local GetMerchantItemInfo = GetMerchantItemInfo
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestLogRewardInfo = GetQuestLogRewardInfo
local GetSendMailItem = GetSendMailItem
local GetTradePlayerItemInfo = GetTradePlayerItemInfo
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeTargetItemInfo = GetTradeTargetItemInfo
local IsConsumableAction = IsConsumableAction
local IsStackableAction = IsStackableAction
local MerchantFrame = MerchantFrame

-- No global variables after this!

local Hooks = {}

function ItemPriceTooltip:InstallHooks(tooltip)
  for name, func in pairs(Hooks) do
    if type(tooltip[name]) == "function" then
      self:SecureHook(tooltip, name, func)
    end
  end
end

function Hooks:SetAction(id)
  local _, item = self:GetItem()
  if not item then return end
  local count = 1
  if IsConsumableAction(id) or IsStackableAction(id) then
    local actionCount = GetActionCount(id)
    if actionCount and actionCount == GetItemCount(item) then
      count = actionCount
    end
  end
  ItemPriceTooltip:AddPrice(self, count, item)
end

function Hooks:SetAuctionItem(type, index)
  local _, _, count = GetAuctionItemInfo(type, index)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetAuctionSellItem()
  local _, _, count = GetAuctionSellItemInfo()
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetBagItem(bag, slot)
  if MerchantFrame:IsShown() then return end
  local _, count = GetContainerItemInfo(bag, slot)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetCraftItem(skill, slot)
  local count = 1
  if slot then
    count = select(3, GetCraftReagentInfo(skill, slot))
  end
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetHyperlink(link, count)
  count = tonumber(count)
  if not count or count < 1 then
    local owner = self:GetOwner()
    count = owner and tonumber(owner.count)
    if not count or count < 1 then count = 1 end
  end
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetInboxItem(index, attachmentIndex)
  local _, _, count = GetInboxItem(index, attachmentIndex)
  ItemPriceTooltip:AddPrice(self, count)
end

local function IsBagSlot(slot)
  return slot >= 20 and slot <= 23 or slot >= 68
end

function Hooks:SetInventoryItem(unit, slot)
  if type(slot) ~= "number" or slot < 0 then return end
  if not ItemPriceTooltip:IsShowingPriceForBagSlots() and IsBagSlot(slot) then return end

  local count = 1
  if slot < 20 or slot > 39 and slot < 68 then
    count = GetInventoryItemCount(unit, slot)
  end
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetLootItem(slot)
  local _, _, count = GetLootSlotInfo(slot)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetLootRollItem(rollID)
  local _, _, count = GetLootRollItemInfo(rollID)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetMerchantCostItem(index, item)
  local _, count = GetMerchantItemCostItem(index, item)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetMerchantItem(slot)
  local _, _, _, count = GetMerchantItemInfo(slot)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetQuestItem(type, slot)
  local _, _, count = GetQuestItemInfo(type, slot)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetQuestLogItem(type, index)
  local _, _, count = GetQuestLogRewardInfo(index)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetSendMailItem(index)
  local _, _, count = GetSendMailItem(index)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetSocketedItem()
  ItemPriceTooltip:AddPrice(self, 1)
end

function Hooks:SetExistingSocketGem()
  ItemPriceTooltip:AddPrice(self, 1)
end

function Hooks:SetSocketGem()
  ItemPriceTooltip:AddPrice(self, 1)
end

function Hooks:SetTradePlayerItem(index)
  local _, _, count = GetTradePlayerItemInfo(index)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetTradeSkillItem(skill, slot)
  local count = 1
  if slot then
    count = select(3, GetTradeSkillReagentInfo(skill, slot))
  end
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetTradeTargetItem(index)
  local _, _, count = GetTradeTargetItemInfo(index)
  ItemPriceTooltip:AddPrice(self, count)
end

function Hooks:SetGuildBankItem(tab, slot)
  local _, count = GetGuildBankItemInfo(tab, slot)
  ItemPriceTooltip:AddPrice(self, count)
end
