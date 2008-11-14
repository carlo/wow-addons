local _G = _G
local LibStub = LibStub or error("LibStub not found!")
local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local format = string.format
local select = select
local tonumber = tonumber

-- No global variables after this!

local L = ItemPriceTooltip.L

local function MakeFormat(G, S, C)
  local GSC = G.." "..S.." "..C
  local GS = G.." "..S
  local GC = G.." "..C
  local SC = S.." "..C
  local Z = C:format(0)
  return function(amount)
    if not amount then return "" end
    if amount <= 0 then return Z end
    if amount < 100 then return format(C, amount) end
    if amount < 10000 then
      local copper = amount % 100
      if copper > 0 then
        return format(SC, (amount-copper) / 100, copper)
      else
        return format(S, amount / 100)
      end
    else
      local copper = amount % 100
      if copper > 0 then
        local tmp = (amount-copper) / 100
        local silver = tmp % 100
        if silver > 0 then
          return format(GSC, (tmp-silver) / 100, silver, copper)
        else
          return format(GC, tmp / 100, copper)
        end
      else
        local tmp = amount / 100
        local silver = tmp % 100
        if silver > 0 then
          return format(GS, (tmp-silver) / 100, silver)
        else
          return format(G, tmp / 100)
        end
      end
    end
  end
end

local coin = [[|cffffffff%%d|r|TInterface\AddOns\ItemPriceTooltip\Textures\%s:0:0:1|t]]
local FormatMoneyCoin = MakeFormat(coin:format("Gold"), coin:format("Silver"), coin:format("Copper"))
local coin = [[|cffffffff%%d|r|cff%s%s|r]]
local FormatMoneyText = MakeFormat(coin:format("ffd700", L["coin.gold"]),
                                   coin:format("c7c7cf", L["coin.silver"]),
                                   coin:format("eda55f", L["coin.copper"]))

local SELLS_FOR = L["Sells for"]
local UNKNOWN_SELL_PRICE = format("|cffff0000%s|r", L["Unknown sell price"])
local ITEM_UNSELLABLE = _G.ITEM_UNSELLABLE

local function SellsForText1(textcolor, customtext)
  return format("|cff%s%s|r", textcolor, customtext or SELLS_FOR)
end

local function SellsForTextN(textcolor, customtext, count, pstr)
  return format("%s |cffffffaa(|r|cffffffff%d|r |cffaaaaaax|r %s|cffffffaa)|r", SellsForText1(textcolor, customtext), count, pstr)
end

local function FormatPriceText(price, count, textcolor, customtext, style)
  textcolor = textcolor or "ffffff"
  count = count or 1
  local fmt = style == "text" and FormatMoneyText or FormatMoneyCoin
  local pstrN = fmt(price * count)
  if count == 1 then return SellsForText1(textcolor, customtext), pstrN end
  local pstr1 = fmt(price)
  return SellsForTextN(textcolor, customtext, count, pstr1), pstrN
end


function ItemPriceTooltip:AddPrice(tooltip, count, item)
  if not ItemPriceTooltip:IsChosenModifierDown() then return end
  item = item or select(2, tooltip:GetItem())
  if not item then return end
  local price = ItemPriceTooltip:GetPrice(item)
  if not price then
    if ItemPriceTooltip:IsIgnoreUnknown() then return end
    tooltip:AddLine(UNKNOWN_SELL_PRICE)
  elseif price == 0 then
    if ItemPriceTooltip:IsIgnoreUnsellable() then return end
    tooltip:AddLine(format("|cff%s%s|r", ItemPriceTooltip:GetTextColor(), ITEM_UNSELLABLE))
  else
    local style = ItemPriceTooltip:GetStyle()
    if style == "blizzard" then
      _G.SetTooltipMoney(tooltip, count and price * count or price)
    else
      local left, right = FormatPriceText(price, count, ItemPriceTooltip:GetTextColor(), ItemPriceTooltip:GetCustomText(), style)
      tooltip:AddDoubleLine(left, right)
    end
  end
  if tooltip:IsShown() then tooltip:Show() end
end
