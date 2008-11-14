local DEBUG = false
local _G = _G
local LibStub = LibStub or error("LibStub not found!")

local assert = assert
local error = error
local format = string.format
local geterrorhandler = geterrorhandler
local match = string.match
local pairs = pairs
local rawset = rawset
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring
local type = type

-- No global variables after this!

local L = _G.ItemPriceTooltip_Locale
_G.ItemPriceTooltip_Locale = nil

local ItemPrice_major = "ItemPrice-1.1"
local ItemPrice, ItemPrice_minor = LibStub(ItemPrice_major)

local ItemPriceTooltip = LibStub("AceAddon-3.0"):NewAddon("ItemPriceTooltip", "AceHook-3.0", "AceConsole-3.0")
ItemPriceTooltip.L = L

if DEBUG then
  local frame = _G.CreateFrame("Frame")
  local updateCount = 0
  frame:SetScript("OnUpdate", function() updateCount = updateCount + 1 end)
  function ItemPriceTooltip:Debug(msg, ...)
    self:Print(format("%d: "..tostring(msg), updateCount, ...))
  end
  function ItemPriceTooltip:IsDebugging() return true end
else
  ItemPriceTooltip.Debug = function()end
  function ItemPriceTooltip:IsDebugging() end
end

function ItemPriceTooltip:GetPriceById(id)
  if not id then return nil end
  local price = ItemPrice:GetPriceById(id)
  if price then return price end
  if not self:IsRecordingVendorPrices() then return nil end
  return self.recorded_prices[id]
end
function ItemPriceTooltip:GetPrice(item)
  return self:GetPriceById(tonumber(item) or tonumber(match(tostring(item), "item:(%d+)")))
end


function ItemPriceTooltip:OnInitialize()
  local defaults_profile = {
    textcolor = "7fff7f",
    modifierKey = "NONE",
    showBagSlots = true,
    style = "coin",
  }

  local defaults_global = {
    recorded_prices = {},
  }

  local defaults = {
    profile = defaults_profile,
    global = defaults_global,
  }

  local db = LibStub("AceDB-3.0"):New("ItemPriceTooltipAce3DB", defaults, "Default")
  self.db = db

  local recorded_prices = db.global.recorded_prices
  self.recorded_prices = recorded_prices

  if db.global.ItemPrice_major ~= ItemPrice_major or db.global.ItemPrice_minor ~= ItemPrice_minor then
    self:Print(format("Checking price library: %q, %d", ItemPrice_major, ItemPrice_minor))
    local count, rcount = 0, 0
    for id in pairs(recorded_prices) do
      count = count + 1
      if ItemPrice:GetPriceById(id) then
        recorded_prices[id] = nil
        rcount = rcount + 1
      end
    end
    db.global.ItemPrice_major = ItemPrice_major
    db.global.ItemPrice_minor = ItemPrice_minor
    if count > 0 and rcount > 0 then
      self:Print(format("Cleared %d out of %d recorded prices", rcount, count))
    else
      self:Print("No changes needed")
    end
  end

  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(self.name, function() return self:GetOptions() end)

  self:RegisterChatCommand("itempricetooltip", "OpenConfig", true)
  self:RegisterChatCommand("ipt", "OpenConfig", true, false)

  self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

  self:Debug("%s initialized", self.name)
end

function ItemPriceTooltip:OpenConfig()
  LibStub("AceConfigDialog-3.0"):Open(self.name)
end

function ItemPriceTooltip:OnEnable()
  self:InstallHooks(_G.GameTooltip)
  self:InstallHooks(_G.ItemRefTooltip)
  self:EnableIntegration()
  self:CheckVendorScan()
  self:Debug("%s enabled", tostring(self.name))
end

function ItemPriceTooltip:OnDisable()
  self:DisableVendorScan()
  self:DisableIntegration()
  self:Debug("%s disabled", tostring(self.name))
end

function ItemPriceTooltip:OnProfileChanged()
  self:CheckVendorScan()
end

function ItemPriceTooltip:GetModifierKey()
  return self.db.profile.modifierKey or "NONE"
end

function ItemPriceTooltip:SetModifierKey(key)
  self.db.profile.modifierKey = key
end

do
  local function true_func() return true end
  local M = {
    NONE = true_func,
    ALT = _G.IsAltKeyDown,
    CTRL = _G.IsControlKeyDown,
    SHIFT = _G.IsShiftKeyDown,
    ANY = _G.IsModifierKeyDown,
  }
  setmetatable(M, {__index=function() return true_func end})

  function ItemPriceTooltip:IsChosenModifierDown()
    return M[self:GetModifierKey()]()
  end
end


function ItemPriceTooltip:IsShowingPriceForBagSlots()
  return self.db.profile.showBagSlots
end

function ItemPriceTooltip:SetShowingPriceForBagSlots(enabled)
  self.db.profile.showBagSlots = not not enabled
end

function ItemPriceTooltip:IsIgnoreUnsellable()
  return self.db.profile.ignoreUnsellable
end

function ItemPriceTooltip:SetIgnoreUnsellable(enabled)
  self.db.profile.ignoreUnsellable = not not enabled
end

function ItemPriceTooltip:IsIgnoreUnknown()
  return self.db.profile.ignoreUnknown
end

function ItemPriceTooltip:SetIgnoreUnknown(enabled)
  self.db.profile.ignoreUnknown = not not enabled
end

function ItemPriceTooltip:GetTextColor()
  return self.db.profile.textcolor
end

function ItemPriceTooltip:SetTextColor(textcolor)
  self.db.profile.textcolor = textcolor
end

function ItemPriceTooltip:GetCustomText()
  return self.db.profile.customtext
end

function ItemPriceTooltip:SetCustomText(text)
  if type(text) == "string" then
    text = text:trim()
    if text == "" then text = nil end
  else
    text = nil
  end
  self.db.profile.customtext = text
end

function ItemPriceTooltip:GetStyle()
  return self.db.profile.style
end

function ItemPriceTooltip:SetStyle(style)
  self.db.profile.style = style
end

function ItemPriceTooltip:IsRecordingVendorPrices()
  return self.db.profile.recordingVendorPrices
end

function ItemPriceTooltip:SetRecordingVendorPrices(record)
  self.db.profile.recordingVendorPrices = not not record
  self:CheckVendorScan()
end



