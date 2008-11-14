local _G = _G
local LibStub = LibStub or error("LibStub not found!")
local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local assert = assert
local ipairs = ipairs
local match = string.match
local tonumber = tonumber
local tostring = tostring
local type = type

local GetContainerItemDurability = GetContainerItemDurability
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local InRepairMode = InRepairMode
local MerchantFrame = MerchantFrame

-- No global variables after this!

local L = ItemPriceTooltip.L

local ItemPrice = LibStub("ItemPrice-1.1")

local function GetContainerItemPrice(...)
  GetContainerItemPrice = nil
  
  local WorldFrame = _G.WorldFrame
  local tooltip = _G.CreateFrame("GameTooltip")
  tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

  local Lines = {}
  for i = 1, 10 do -- Relevant information should be in the first few lines... hopefully!
    local left = assert(tooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    local right = assert(tooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    tooltip:AddFontStrings(left, right)
    Lines[#Lines+1] = left
    Lines[#Lines+1] = right
  end

  local tooltip_money
  tooltip:SetScript("OnTooltipAddMoney", function(_, money) tooltip_money = money end)

  local CHARGE = L["Charge"]
  local CHARGES = L["Charges"]
  local function HasCharges()
    for _, line in ipairs(Lines) do
      local text = line:IsVisible() and line:GetText()
      if text and (match(text, CHARGE) or match(text, CHARGES)) then return true end
    end
  end

  function GetContainerItemPrice(bag, slot)
    local _, count = GetContainerItemInfo(bag, slot)
    if not count or count < 1 then return end
    tooltip:ClearLines()
    if not tooltip:IsOwned(WorldFrame) then tooltip:SetOwner(WorldFrame, "ANCHOR_NONE") end
    tooltip_money = nil
    local _, repairCost = tooltip:SetBagItem(bag, slot)
    if type(repairCost) == "number" and repairCost > 0 then return end -- Chickening out - don't want repair cost to affect saved prices!
    if tooltip_money then
      if count > 1 then return tooltip_money / count end
      if HasCharges() then return end -- Don't record as there is a chance the price is reduced!
      return tooltip_money
    end
    return 0
  end
  
  return GetContainerItemPrice(...)
end

local function ScanSlot(bag, slot, db)
  local link = GetContainerItemLink(bag, slot)
  if not link then return end
  local id = tonumber(link:match("item:(%d+)"))
  if not id then return end
  if ItemPrice:GetPriceById(id) then return end -- In the library we trust! Only recording unknown items. This could become an option.
  local curCur, maxDur = GetContainerItemDurability(bag, slot)
  if curCur and curCur ~= maxDur then return end
  local price = GetContainerItemPrice(bag, slot)
  if not price or db[id] == price then return end
  db[id] = price
  if ItemPriceTooltip:IsDebugging() then
    ItemPriceTooltip:Debug("Found price for %d (%q): %s", id, _G.GetItemInfo(link), tostring(db[id]))
  end
end


function ItemPriceTooltip:ScanVendorPrices()
  if not GetContainerItemPrice then return end
  if InRepairMode() then return end
  self:Debug("Scanning vendor")
  local recorded_prices = self.recorded_prices
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      ScanSlot(bag, slot, recorded_prices)
    end
  end
end

function ItemPriceTooltip:PurgeRecordedPrices()
  local t = {}
  self.db.global.recorded_prices = t
  self.recorded_prices = t
end

do
  local EventFrame

  function ItemPriceTooltip:EnableVendorScan()
    if not self:IsEnabled() then return end
    if not EventFrame then
      EventFrame = CreateFrame("Frame")
      EventFrame:SetScript("OnEvent", function() self:ScanVendorPrices() end)
    end
    EventFrame:RegisterEvent("MERCHANT_SHOW")
    self:Debug("Vendor scan enabled")
  end

  function ItemPriceTooltip:DisableVendorScan()
    if not EventFrame then return end
    EventFrame:UnregisterAllEvents()
    self:Debug("Vendor scan disabled")
  end

  function ItemPriceTooltip:CheckVendorScan()
    if self:IsEnabled() and self:IsRecordingVendorPrices() then
      self:EnableVendorScan()
    else
      self:DisableVendorScan()
    end
  end
end



