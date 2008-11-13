-- ================================================================================================
-- =  ItemPriceTooltip                                                                            =
-- ================================================================================================

-- Import global variables

local assert, error, ipairs, next, pairs, select, tonumber, tostring, type, unpack, pcall, xpcall =
      assert, error, ipairs, next, pairs, select, tonumber, tostring, type, unpack, pcall, xpcall
local getmetatable, setmetatable, rawequal, rawget, rawset, getfenv, setfenv, loadstring, debugstack =
      getmetatable, setmetatable, rawequal, rawget, rawset, getfenv, setfenv, loadstring, debugstack
local math, string, table = math, string, table
local find, format, gmatch, gsub, tolower, match, toupper, join, split, trim =
      string.find, string.format, string.gmatch, string.gsub, string.lower, string.match, string.upper, string.join, string.split, string.trim
local concat, insert, maxn, remove, sort = table.concat, table.insert, table.maxn, table.remove, table.sort
local max, min, abs, ceil, floor = math.max, math.min, math.abs, math.ceil, math.floor

local CreateFrame = CreateFrame
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetItemInfo = GetItemInfo
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local MerchantFrame = MerchantFrame

local AceLibrary = AceLibrary
local LibStub = LibStub

-- No global variables after this!

local _G = getfenv()


-- ================================================================================================
-- = Localization                                                                                 =
-- ================================================================================================

local L = AceLibrary("AceLocale-2.2"):new("ItemPriceTooltip")

L:RegisterTranslations("enUS", function() return {
    ["Sells for"] = true,
    ["Display style"] = true,
    ["Text"] = true,
    ["Text color"] = true,
    ["Custom text"] = true,
    ["Bag slots"] = true,
    ["Show price for bag slots"] = true,
    ["Record vendor prices"] = true,
    ["Purge prices!"] = true,
    ["Purge recorded vendor prices"] = true,
    ["Modifier key only"] = true,
    ["Only show price when a modifier key is held down"] = true,
    ["Unknown sell price"] = true,
    ["Modifier key"] = true,
    ["Choose a modifier key"] = true,
    ["Show statistics"] = true,
    ["Show statistics for stored prices"] = true,
    ["Prices in library: %d"] = true,
    ["Recorded vendor prices: %d"] = true,
    ["Ignore unknown items"] = true,
    ["Don't show anything for items that are not known"] = true,
    ["Ignore unsellable items"] = true,
    ["Don't show anything for items that cannot be sold to a vendor"] = true,
  }
end)

L:RegisterTranslations("deDE", function() return {
    ["Sells for"] = "Verkauf f\195\188r",
    ["Display style"] = "Anzeigestil",
    ["Text"] = "Text",
    ["Text color"] = "Textfarbe",
    ["Custom text"] = "Benutzerdefinierter Text",
    ["Bag slots"] = "Taschenpl\195\164tze",
    ["Show price for bag slots"] = "Den Preis f\195\188r Taschenpl\195\164tze anzeigen",
    ["Record vendor prices"] = "H\195\164ndlerpreise aufzeichnen",
    ["Purge prices!"] = "Preise l\195\182schen!",
    ["Purge recorded vendor prices"] = "Alle aufgezeichneten H\195\164ndlerpreise l\195\182schen",
    ["Modifier key only"] = "Nur Modifikator-Taste",
    ["Only show price when a modifier key is held down"] = "Preise nur anzeigen, wenn eine Modifikator-Taste gedr\195\188ckt wird",
    ["Unknown sell price"] = "Unbekannter Verkaufspreis",
    ["Modifier key"] = "Modifikator-Taste",
    ["Choose a modifier key"] = "Eine Modifikator-Taste ausw\195\164hlen",
    ["Show statistics"] = "Statistiken anzeigen",
    ["Show statistics for stored prices"] = "Statistiken f\195\188r gespeicherte Preise anzeigen",
    ["Prices in library: %d"] = "Preise in der Datenbank: %d",
    ["Recorded vendor prices: %d"] = "Aufgezeichnete H\195\164ndlerpreise: %d",
  }
end)

L:RegisterTranslations("frFR", function() return {
    ["Sells for"] = "Vendu pour",
    ["Display style"] = "Style d'affichage",
    ["Text"] = "Texte",
    ["Text color"] = "Couleur du texte",
    ["Custom text"] = "Texte personnalis\195\169",
    ["Bag slots"] = "Sac",
    ["Show price for bag slots"] = "Affiche le prix des sacs",
    ["Record vendor prices"] = "Enregistrer les prix des marchands",
    ["Purge prices!"] = "Purge des prix!",
    ["Purge recorded vendor prices"] = "Purge de l'enregistrement des prix des marchands",
  }
end)

L:RegisterTranslations("koKR", function() return {
    ["Sells for"] = "판매 가격",
    ["Display style"] = "표시 방법",
    ["Text"] = "글자",
    ["Text color"] = "글자 색상",
    ["Custom text"] = "사용자 정의 글자",
    ["Bag slots"] = "가방 공간",
    ["Show price for bag slots"] = "가방 공간에도 판매가격을 표시합니다.",
    ["Record vendor prices"] = "상점 판매가격 기록",
    ["Purge prices!"] = "데이터 삭제",
    ["Purge recorded vendor prices"] = "상점 판매가격 데이터를 삭제합니다.",
    ["Modifier key only"] = "기능키 사용",
    ["Only show price when a modifier key is held down"] = "기능키를 사용했을 경우에만 판매가격을 표시합니다.",
    ["Unknown sell price"] = "알 수 없음",
    ["Modifier key"] = "기능키",
    ["Choose a modifier key"] = "기능키를 선택합니다.",
    ["Show statistics"] = "통계 보기",
    ["Show statistics for stored prices"] = "저장된 금액의 통계 보기",
    ["Prices in library: %d"] = "라이브러리 판매 가격 : %d",
    ["Recorded vendor prices: %d"] = "저장된 판매 가격 : %d",
    ["Ignore unknown items"] = "가격 모르는 아이템 무시",
    ["Don't show anything for items that are not known"] = "가격을 알 수 없는 아이템의 튤탑울 표시하지 않습니다.",
    ["Ignore unsellable items"] = "팔 수 없는 아이템 무시",
    ["Don't show anything for items that cannot be sold to a vendor"] = "팔 수 없는 아이템의 툴팁을 표시하지 않습니다.",
  }
end)

L:RegisterTranslations("zhCN", function() return {
    ["Sells for"] = "售价",
    ["Display style"] = "显示方式",
    ["Text"] = "文字",
    ["Text color"] = "文字颜色",
    ["Custom text"] = "自定义文字",
    ["Bag slots"] = "背包栏",
    ["Show price for bag slots"] = "显示背包栏背包价格",
    ["Record vendor prices"] = "记录出售价格",
    ["Purge prices!"] = "清除价格！",
    ["Purge recorded vendor prices"] = "清除记录的商人处售价",
    ["Modifier key only"] = "设置控制键",
    ["Only show price when a modifier key is held down"] = "仅控制键按下后显示售价",
    ["Unknown sell price"] = "未知价格/无法出售",
    ["Modifier key"] = "控制键",
    ["Choose a modifier key"] = "选择一个控制键",
    ["Show statistics"] = "显示售价储存数",
    ["Show statistics for stored prices"] = "显示所有已储存售价的数量",
    ["Prices in library: %d"] = "内置的售价记录：%d",
    ["Recorded vendor prices: %d"] = "商人处售价记录：%d",
  }
end)

L:RegisterTranslations("zhTW", function() return {
    ["Sells for"] = "賣出價",
    ["Display style"] = "顯示樣式",
    ["Text"] = "文字",
    ["Text color"] = "文字顏色",
    ["Custom text"] = "自訂文字",
    ["Bag slots"] = "背包欄位",
    ["Show price for bag slots"] = "顯示背包欄位的價格",
    ["Record vendor prices"] = "記錄商人賣出價",
    ["Purge prices!"] = "清除賣出價!",
    ["Purge recorded vendor prices"] = "清除已記錄的商人賣出價",
    ["Modifier key only"] = "只在按下輔助鍵時",
    ["Only show price when a modifier key is held down"] = "只在按下輔助鍵時才顯示賣出價",
    ["Unknown sell price"] = "賣出價不明",
    ["Modifier key"] = "輔助鍵",
    ["Choose a modifier key"] = "選擇輔助鍵",
    ["Show statistics"] = "顯示統計",
    ["Show statistics for stored prices"] = "顯示賣出價記錄統計",
    ["Prices in library: %d"] = "ItemPrice 程式庫: %d",
    ["Recorded vendor prices: %d"] = "商人賣出價記錄: %d",
  }
end)

L:RegisterTranslations("esES", function() return {
    ["Sells for"] = "Se vende por",
    ["Display style"] = "Estilo",
    ["Text"] = "Texto",
    ["Text color"] = "Color del Texto",
    ["Custom text"] = "Texto personalizado",
    ["Bag slots"] = "Bolsas",
    ["Show price for bag slots"] = "Mostrar precio en bolsas",
    ["Record vendor prices"] = "Guardar precio de los comerciantes",
    ["Purge prices!"] = "¡Purgar precios!",
    ["Purge recorded vendor prices"] = "Purgar precios de los comerciantes",
    ["Modifier key only"] = "Mostrar solo con tecla",
    ["Only show price when a modifier key is held down"] = "Mostrar precios solo con la tecla asignada pulsada",
    ["Unknown sell price"] = "Precio de venta desconocido",
    ["Modifier key"] = "Tecla",
    ["Choose a modifier key"] = "Asignar tecla",
    ["Show statistics"] = "Mostrar estadísticas",
    ["Show statistics for stored prices"] = "Mostrar estadísticas para precios guardados",
    ["Prices in library: %d"] = "Precios en biblioteca: %d",
    ["Recorded vendor prices: %d"] = "Precios guardados de comerciantes: %d",
    ["Ignore unknown items"] = "Ignorar objetos desconocidos",
    ["Don't show anything for items that are not known"] = "No mostrar nada para los objetos desconocidos",
    ["Ignore unsellable items"] = "Ignorar objetos invendibles",
    ["Don't show anything for items that cannot be sold to a vendor"] = "No mostrar nada para los objetos invendibles",
  }
end)

-- ================================================================================================
-- =  Initialization (addon, libraries, etc.)                                                     =
-- ================================================================================================

local mixins = {"AceHook-2.1", "AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "FuBarPlugin-2.0"}
local hasAceDebug = AceLibrary:HasInstance("AceDebug-2.0")
if hasAceDebug then insert(mixins, "AceDebug-2.0") end

local ItemPriceTooltip = AceLibrary("AceAddon-2.0"):new(unpack(mixins))
ItemPriceTooltip:RegisterDB("ItemPriceTooltipDB")

local function noop() end
local dbg, debug, ldebug
if hasAceDebug then
  function dbg() return ItemPriceTooltip:IsDebugging() end
  function debug(...) return ItemPriceTooltip:Debug(...) end
  function ldebug(level, ...) return ItemPriceTooltip:LevelDebug(level, ...) end
  -- ItemPriceTooltip:SetDebugging(true)
  -- ItemPriceTooltip:SetDebugLevel(1)
else
  dbg, debug, ldebug = noop, noop, noop
end

local function AceLibStub(major)
  local lib, minor = LibStub:GetLibrary(major, true)
  if lib then return lib, minor end
  _G.EnableAddOn(major)
  _G.LoadAddOn(major)
  return LibStub:GetLibrary(major)
end

-- Libraries
local Abacus = AceLibrary("Abacus-2.0")

local ItemPriceLibName = "ItemPrice-1.1"


local function link2id(link)
  return tonumber(match(link, "item:(%d+)") or match(link, "%d+"))
end

local function rgb2hex(r, g, b)
  return format("%02x%02x%02x", min(255,max(0,r*255)), min(255,max(0,g*255)), min(255,max(0,b*255)))
end

local function hex2rgb(h)
  local r, g, b = match(h, "^(%x%x)(%x%x)(%x%x)$")
  r, g, b = tonumber(r, 16) or 255, tonumber(g, 16) or 255, tonumber(b, 16) or 255
  return r/255, g/255, b/255
end


-- ================================================================================================
-- =  Tooltip hooking functions                                                                   =
-- ================================================================================================

local Hooks = {}
do
  function Hooks:SetAction(id)
    local _, item = self:GetItem()
    if not item then return end
    local count = 1
    if _G.IsConsumableAction(id) or _G.IsStackableAction(id) then
      local actionCount = _G.GetActionCount(id)
      if actionCount and actionCount == _G.GetItemCount(item) then
        count = actionCount
      end
    end
    ItemPriceTooltip:AddPrice(self, count, item)
  end

  function Hooks:SetAuctionItem(type, index)
    local _, _, count = _G.GetAuctionItemInfo(type, index)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetAuctionSellItem()
    local _, _, count = _G.GetAuctionSellItemInfo()
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetBagItem(bag, slot)
    if MerchantFrame:IsShown() then return end
    local _, count = _G.GetContainerItemInfo(bag, slot)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetCraftItem(skill, slot)
    local count = 1
    if slot then
      count = select(3, _G.GetCraftReagentInfo(skill, slot))
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

  function Hooks:SetInboxItem(index)
    local _, _, count = _G.GetInboxItem(index)
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
      count = _G.GetInventoryItemCount(unit, slot)
    end
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetLootItem(slot)
    local _, _, count = _G.GetLootSlotInfo(slot)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetLootRollItem(rollID)
    local _, _, count = _G.GetLootRollItemInfo(rollID)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetMerchantCostItem(index, item)
    local _, count = _G.GetMerchantItemCostItem(index, item)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetMerchantItem(slot)
    local _, _, _, count = _G.GetMerchantItemInfo(slot)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetQuestItem(type, slot)
    local _, _, count = _G.GetQuestItemInfo(type, slot)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetQuestLogItem(type, index)
    local _, _, count = _G.GetQuestLogRewardInfo(index)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetSendMailItem(index)
    local _, _, count = _G.GetSendMailItem(index)
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
    local _, _, count = _G.GetTradePlayerItemInfo(index)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetTradeSkillItem(skill, slot)
    local count = 1
    if slot then
      count = select(3, _G.GetTradeSkillReagentInfo(skill, slot))
    end
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetTradeTargetItem(index)
    local _, _, count = _G.GetTradeTargetItemInfo(index)
    ItemPriceTooltip:AddPrice(self, count)
  end

  function Hooks:SetGuildBankItem(tab, slot)
    local _, count = _G.GetGuildBankItemInfo(tab, slot)
    ItemPriceTooltip:AddPrice(self, count)
  end
end

-- ================================================================================================
-- = Vendor scanning                                                                              =
-- ================================================================================================

local vendor_scan
do
  local tooltip_money
  local tooltip_name = "ItemPriceTooltip_Tooltip"
  local tooltip = CreateFrame("GameTooltip", tooltip_name, nil, "GameTooltipTemplate")
  tooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
  tooltip:SetScript("OnTooltipAddMoney", function(_, money) tooltip_money = money end)

  local tooltip_lines
  local function has_charges()
    if not tooltip_lines then
      tooltip_lines = {}
      local left_name, right_name = tooltip_name .. "TextLeft", tooltip_name .. "TextRight"
      local i = 1
      local left, right = _G[left_name..i], _G[right_name..i]
      while left and right do
        tooltip_lines[#tooltip_lines + 1] = left
        tooltip_lines[#tooltip_lines + 1] = right
        i = i + 1
        left, right = _G[left_name..i], _G[right_name..i]
      end
    end
    for _, line in ipairs(tooltip_lines) do
      local text = line:IsVisible() and line:GetText()
      if text and match(text, "^%s*%d+%s+[Cc]harge") then return true end
    end
  end

  local function get_price_at_vendor(bag, slot)
    local _, count = GetContainerItemInfo(bag, slot)
    if not count or count < 1 then return end
    tooltip_money = nil
    tooltip:ClearLines()
    local _, repairCost = tooltip:SetBagItem(bag, slot)
    if type(repairCost) == "number" and repairCost > 0 then return end -- Chickening out - don't want repair cost to affect saved prices!
    if tooltip_money then
      if count > 1 then return tooltip_money / count end
      if has_charges() then return end -- Don't record as there is a chance the price is reduced!
      return tooltip_money
    end
    return 0
  end

  local function scan_slot(bag, slot)
    local link = GetContainerItemLink(bag, slot)
    if not link then return end
    local itemId = assert(link2id(link))
    local new_price = get_price_at_vendor(bag, slot)
    if not new_price or new_price == ItemPriceTooltip:GetLibPrice(itemId) then
      ItemPriceTooltip:SetDBPrice(itemId, nil)
    else
      if dbg() then debug("Price: %s = %s (%s)", link, new_price, ItemPriceTooltip:GetLibPrice(itemId)) end
      ItemPriceTooltip:SetDBPrice(itemId, new_price)
    end
  end

  function vendor_scan()
    if not MerchantFrame:IsShown() then return end
    if _G.InRepairMode() then return end
    debug("Scanning vendor")
    for bag = 0, _G.NUM_BAG_FRAMES do
      for slot = 1, GetContainerNumSlots(bag) do
        scan_slot(bag, slot)
      end
    end
  end
end


-- ================================================================================================
-- =  Addon methods                                                                               =
-- ================================================================================================

local options
do
  local self = ItemPriceTooltip

  local function DisableTextOptions() return self:GetDisplayStyle() ~= "text" end

  options = {
    type = "group",
    args = {
      style = {
        order = 100,
        name = L["Display style"],
        desc = L["Display style"],
        type = "text",
        get = "GetDisplayStyle",
        set = "SetDisplayStyle",
        validate = {text = L["Text"], blizzard = "Blizzard"},
      },
      color = {
        order = 110,
        name = L["Text color"],
        desc = L["Text color"],
        type = "color",
        get = function() return hex2rgb(self:GetTextColor()) end,
        set = function(r,  g, b) self:SetTextColor(rgb2hex(r, g, b)) end,
      },
      customtext = {
        order = 111,
        name = L["Custom text"],
        desc = L["Custom text"],
        type = "text",
        usage = format("<%s>", L["Custom text"]),
        get = "GetCustomText",
        set = "SetCustomText",
        disabled = DisableTextOptions,
      },
      modifier = {
        order = 200,
        name = L["Modifier key only"],
        desc = L["Only show price when a modifier key is held down"],
        type = "text",
        get = "GetModifierKey",
        set = "SetModifierKey",
        validate = {"NONE", "ALT", "CTRL", "SHIFT", "ANY"},
      },
      bagslots = {
        order = 300,
        name = L["Bag slots"],
        guiName = L["Show price for bag slots"],
        desc = L["Show price for bag slots"],
        type = "toggle",
        get = "IsShowingPriceForBagSlots",
        set = "SetShowingPriceForBagSlots",
      },
      unsellable = {
        order = 300,
        name = L["Ignore unsellable items"],
        desc = L["Don't show anything for items that cannot be sold to a vendor"],
        type = "toggle",
        get = "IsIgnoreUnsellable",
        set = "SetIgnoreUnsellable",
      },
      unknown = {
        order = 300,
        name = L["Ignore unknown items"],
        desc = L["Don't show anything for items that are not known"],
        type = "toggle",
        get = "IsIgnoreUnknown",
        set = "SetIgnoreUnknown",
      },
      record = {
        order = 400,
        name = L["Record vendor prices"],
        desc = L["Record vendor prices"],
        type = "toggle",
        get = "IsRecordingVendorPrices",
        set = "SetRecordingVendorPrices",
      },
      report = {
        order = 500,
        name = L["Show statistics"],
        desc = L["Show statistics for stored prices"],
        type = "execute",
        func = "ReportStats",
      },
      purge = {
        order = 1000,
        name = L["Purge prices!"],
        desc = L["Purge recorded vendor prices"],
        type = "execute",
        func = "PurgeScannedPrices",
        confirm = true,
      },
    },
  }

  -- FuBar options
  self.OnMenuRequest = options
  self.hasIcon = "Interface\\Icons\\INV_Misc_Eye_01"
  self.hasNoColor = true
  self.cannotDetachTooltip = true
  self.independentProfile = true
  self.hideWithoutStandby = true
end

function ItemPriceTooltip:GetTitle()
  return "ItemPriceTooltip"
end

function ItemPriceTooltip:ToString()
  return "ItemPriceTooltip"
end

function ItemPriceTooltip:OnInitialize()
  local db_name = ItemPriceLibName
  self.ip_db = self:AcquireDBNamespace(db_name).account
  local defaults = {}
  defaults.prices = {}
  self:RegisterDefaults(db_name, 'account', defaults)

  local defaults = {
    format = {
      textcolor = "7fff7f",
      style = "text",
    },
    modifierKey = "NONE",
    modifierOnly = false,
    ignoreUnsellable = false,
    ignoreUnknown = false,
    disabled = {
      bagslots = false,
      recordingVendorPrices = false,
    },
  }

  self:RegisterDefaults('profile', defaults)

  self:RegisterChatCommand({ "/itempricetooltip", "/ipt" }, options)

end

function ItemPriceTooltip:ReportStats()
  local lib = self.priceLib
  if lib then
    self:Print(L["Prices in library: %d"], lib:GetPriceCount())
  end
  local count = 0
  for _ in pairs(self.ip_db.prices) do count = count + 1 end
  self:Print(L["Recorded vendor prices: %d"], count)
end

function ItemPriceTooltip:GetModifierKey()
  return self.db.profile.modifierKey or "NONE"
end

function ItemPriceTooltip:SetModifierKey(key)
  self.db.profile.modifierKey = key
end

do
  local M = {}
  function M.NONE() return true end
  function M.ALT() return IsAltKeyDown() end
  function M.CTRL() return IsControlKeyDown() end
  function M.SHIFT() return IsShiftKeyDown() end
  function M.ANY() return IsModifierKeyDown() end

  function ItemPriceTooltip:IsChosenModifierDown()
    return M[self:GetModifierKey()]()
  end
end

function ItemPriceTooltip:IsRecordingVendorPrices()
  return not self.db.profile.disabled.recordingVendorPrices
end

function ItemPriceTooltip:SetRecordingVendorPrices(record)
  self.db.profile.disabled.recordingVendorPrices = not record
  if self._enabled then
    if record then
      if not self:IsEventRegistered("MERCHANT_SHOW") then self:RegisterEvent("MERCHANT_SHOW") end
    else
      if self:IsEventRegistered("MERCHANT_SHOW") then self:UnregisterEvent("MERCHANT_SHOW") end
    end
  end
end

function ItemPriceTooltip:PurgeScannedPrices()
  self.ip_db.prices = {}
end

function ItemPriceTooltip:IsShowingPriceForBagSlots()
  return not self.db.profile.disabled.bagslots
end

function ItemPriceTooltip:SetShowingPriceForBagSlots(show)
  self.db.profile.disabled.bagslots = not show
end

function ItemPriceTooltip:IsIgnoreUnsellable()
  return self.db.profile.ignoreUnsellable
end

function ItemPriceTooltip:SetIgnoreUnsellable(enabled)
  self.db.profile.ignoreUnsellable = enabled
end

function ItemPriceTooltip:IsIgnoreUnknown()
  return self.db.profile.ignoreUnknown
end

function ItemPriceTooltip:SetIgnoreUnknown(enabled)
  self.db.profile.ignoreUnknown = enabled
end

function ItemPriceTooltip:GetTextColor()
  return self.db.profile.format.textcolor
end

function ItemPriceTooltip:SetTextColor(textcolor)
  self.db.profile.format.textcolor = textcolor
end

function ItemPriceTooltip:GetCustomText()
  return self.db.profile.format.customtext
end

function ItemPriceTooltip:SetCustomText(text)
  if type(text) == "string" then
    text = trim(text)
    if text == "" then text = nil end
  else
    text = nil
  end
  self.db.profile.format.customtext = text
end

function ItemPriceTooltip:GetDisplayStyle()
  return self.db.profile.format.style
end

function ItemPriceTooltip:SetDisplayStyle(style)
  self.db.profile.format.style = style
end

function ItemPriceTooltip:SetDBPrice(id, price)
  self.ip_db.prices[id] = price
end

function ItemPriceTooltip:GetDBPrice(id)
  return self.ip_db.prices[id]
end

function ItemPriceTooltip:GetLibPrice(id)
  local lib = self.priceLib
  return lib and lib:GetPrice(id)
end

function ItemPriceTooltip:GetPrice(item)
  local id = item and tonumber(item) or link2id(item)
  return id and (self:IsRecordingVendorPrices() and self:GetDBPrice(id) or self:GetLibPrice(id))
end

local function UpdatePriceDB(self)
  local priceLib, lib_version = self.priceLib, self.priceLibVersion
  if not priceLib then return end
  local ip_db = self.ip_db
  if ip_db.version == lib_version then return end
  local db_prices = ip_db.prices
  for id, price in pairs(db_prices) do
    if priceLib:GetPrice(id) == price then
      db_prices[id] = nil
    end
  end
  ip_db.version = lib_version
end


local function EnableLinkWranglerSupport(self)
  local LinkWrangler = self._LinkWrangler
  if LinkWrangler then return end
  LinkWrangler = _G.LinkWrangler
  if not LinkWrangler or LinkWrangler.Version < 1.6 then return end
  LinkWrangler.RegisterCallback("ItemPriceTooltip", function(frame, link)
    if not self._enabled then return end
    debug("LinkWrangler callback: frame = %s, link = %q", frame, link)
    self:AddPrice(frame, 1, link)
  end, "refresh")
  self._LinkWrangler = LinkWrangler
  debug("Setup support for LinkWrangler.")
end

function ItemPriceTooltip:Links_LinkOpened(link, tooltip)
  self:AddPrice(tooltip, 1, link)
end

local function Hook_GetSellValue(self)
  local orig_GetSellValue = _G.GetSellValue
  function _G.GetSellValue(item)
    if not self._enabled then return orig_GetSellValue(item) end
    if not item then return end
    local id = tonumber(item) or tonumber(match(item, "item:(%d+)"))
    if not id then
      local _, link = GetItemInfo(item)
      if not link then return end
      id = tonumber(match(link, "item:(%d+)"))
      if not id then return end
    end
    local price = self:GetPrice(id)
    if price then return price end
    if orig_GetSellValue then return orig_GetSellValue(id) end
  end
end

function ItemPriceTooltip:OnEnable(first)
  self:installHooks(_G.GameTooltip, Hooks)
  self:installHooks(_G.ItemRefTooltip, Hooks)

  self.priceLib, self.priceLibVersion = AceLibStub(ItemPriceLibName)
  UpdatePriceDB(self)

  if self:IsRecordingVendorPrices() then
    self:RegisterEvent("MERCHANT_SHOW")
  end

  self:RegisterEvent("Links_LinkOpened") -- See: http://www.wowace.com/wiki/Links

  local ok, msg = pcall(EnableLinkWranglerSupport, self)
  if dbg() and not ok then debug("Failed to setup support for LinkWrangler: %q.", tostring(msg)) end

  if first then
    Hook_GetSellValue(self)
  end

  self._enabled = true
end

function ItemPriceTooltip:OnDisable()
  self._enabled = nil
  self.priceLib = nil
end

function ItemPriceTooltip:installHooks(tooltip, hooks)
  for name, func in pairs(hooks) do
    if type(tooltip[name]) == "function" then
      self:SecureHook(tooltip, name, func)
    end
  end
end

function ItemPriceTooltip:MERCHANT_SHOW()
  vendor_scan()
end

do
  local function SellsForText1(textcolor, customtext)
    return format("|cff%s%s|r", textcolor, customtext or L["Sells for"])
  end
  local function SellsForTextN(textcolor, customtext, count, pstr)
    return format("%s |cffffffaa(|r|cffffffff%d|r |cffaaaaaax|r %s|cffffffaa)|r", SellsForText1(textcolor, customtext), count, pstr)
  end

  local function FormatPriceText(price, count, textcolor, customtext)
    textcolor = textcolor or "ffffff"
    count = count or 1
    local pstr1 = Abacus:FormatMoneyShort(price, true)
    local pstrN = Abacus:FormatMoneyFull(price * count, true)
    if count == 1 then return SellsForText1(textcolor, customtext), pstrN end
    return SellsForTextN(textcolor, customtext, count, pstr1), pstrN
  end

  local function AddLines(tooltip, left, right)
    if not (left or right) then return end
    if right then
      tooltip:AddDoubleLine(left and tostring(left) or " ", tostring(right))
    else
      tooltip:AddLine(tostring(left))
    end
    return true
  end

  function ItemPriceTooltip:AddPrice(tooltip, count, item)
    local modifierShow = self:GetModifierKey() ~= "NONE"
    if modifierShow and not self:IsChosenModifierDown() then return end
    item = item or select(2, tooltip:GetItem())
    if not item then return end
    local price = self:GetPrice(item)
    if not price then
      if self:IsIgnoreUnknown() then return end
      tooltip:AddLine(format("|cffff0000%s|r", L["Unknown sell price"]))
    elseif price == 0 then
      if self:IsIgnoreUnsellable() then return end
      tooltip:AddLine(format("|cff%s%s|r", self:GetTextColor(), _G.ITEM_UNSELLABLE))
    else
      local style = self:GetDisplayStyle()
      if style == "blizzard" then
        _G.SetTooltipMoney(tooltip, count and price * count or price)
      else
        local left, right = FormatPriceText(price, count, self:GetTextColor(), self:GetCustomText())
        tooltip:AddDoubleLine(left, right)
      end
    end
    if tooltip:IsShown() then tooltip:Show() end
  end

end
