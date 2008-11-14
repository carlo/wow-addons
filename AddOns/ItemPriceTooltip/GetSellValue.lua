-- See: http://www.wowwiki.com/GetSellValue

local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local GetItemInfo = GetItemInfo
local tonumber = tonumber
local type = type

local oldGetSellValue = GetSellValue or function() return nil end

function GetSellValue(item)
  if not ItemPriceTooltip:IsEnabled() then return oldGetSellValue(item) end
  local id = tonumber(item)
  if not id then
    if type(item) ~= "string" then return nil end
    id = item:match("item:(%d+)")
    if id then
      id = tonumber(id)
    else
      local _, link = GetItemInfo(item)
      if not link then return nil end
      id = tonumber(link:match("item:(%d+)"))
    end
  end
  return ItemPriceTooltip:GetPriceById(id) or oldGetSellValue(id)
end

