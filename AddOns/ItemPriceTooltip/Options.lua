local _G = _G
local LibStub = LibStub or error("LibStub not found!")
local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local assert = assert
local format = string.format
local ipairs = ipairs
local max = math.max
local min = math.min
local setmetatable = setmetatable
local tonumber = tonumber
local type = type

-- No global variables after this!

local L = ItemPriceTooltip.L

local options
function ItemPriceTooltip:GetOptions()
  if options then return options end

  local _order = 0
  local function order()
    _order = _order + 1
    return _order
  end

  local _spaceCount = 0
  local function AddSpacer(args)
    _spaceCount = _spaceCount + 1
    args["spacer".._spaceCount] = {
      order = order(),
      type = "description",
      name = "",
    }
  end

  local function rgb2hex(r, g, b)
    return format("%02x%02x%02x", min(255,max(0,r*255)), min(255,max(0,g*255)), min(255,max(0,b*255)))
  end

  local function hex2rgb(h)
    local r, g, b = h:match("^(%x%x)(%x%x)(%x%x)$")
    r, g, b = tonumber(r, 16) or 255, tonumber(g, 16) or 255, tonumber(b, 16) or 255
    return r/255, g/255, b/255
  end

  local MODIFIER_TEXTS = {
    NONE = assert(_G.NONE_KEY),
    ANY = L["modifier.any"],
    ALT = assert(_G.ALT_KEY),
    CTRL = assert(_G.CTRL_KEY),
    SHIFT = assert(_G.SHIFT_KEY),
  }
  local MODIFIER_VALUES = {"NONE", "ALT", "CTRL", "SHIFT", "ANY"}
  local MODIFIER_MAP = {}
  for i, m in ipairs(MODIFIER_VALUES) do 
    MODIFIER_VALUES[i] = assert(MODIFIER_TEXTS[m])
    MODIFIER_MAP[i] = m
    MODIFIER_MAP[m] = i 
  end

  local general = {
    order = order(),
    type = "group",
    name = L["General"],
    args = {},
  }

  general.args.IgnoreUnsellable = {
    order = order(),
    type = "toggle",
    name = L["Ignore unsellable items"],
    desc = L["Don't show anything for items that cannot be sold to a vendor"],
    get = "IsIgnoreUnsellable",
    set = "SetIgnoreUnsellable",
  }
  AddSpacer(general.args)
  
  general.args.IgnoreUnknown = {
    order = order(),
    type = "toggle",
    name = L["Ignore unknown items"],
    desc = L["Don't show anything for items that are not known"],
    get = "IsIgnoreUnknown",
    set = "SetIgnoreUnknown",
  }
  AddSpacer(general.args)

  general.args.ShowingPriceForBagSlots = {
    order = order(),
    type = "toggle",
    name = L["Show price for bag slots"],
    desc = L["Show price for bag slots"],
    get = "IsShowingPriceForBagSlots",
    set = "SetShowingPriceForBagSlots",
  }
  AddSpacer(general.args)
  
  general.args.ModifierKey = {
    order = order(),
    name = L["Modifier key only"],
    desc = L["Only show price when a modifier key is held down"],
    type = "select",
    values = MODIFIER_VALUES,
    get = function() return MODIFIER_MAP[self:GetModifierKey()] end,
    set = function(info, val) self:SetModifierKey(MODIFIER_MAP[val]) end,
  }
  AddSpacer(general.args)

  general.args.Style = {
    order = order(),
    name = L["Display style"],
    desc = L["Select the display style"],
    type = "select",
    values = {
      coin = L["Coins"],
      text = L["Text only"],
      blizzard = "Blizzard",
    },
    get = function() return self:GetStyle() end,
    set = function(info, style) self:SetStyle(style) end,
  }
  AddSpacer(general.args)

  general.args.TextColor = {
    order = order(),
    name = L["Text color"],
    desc = L["Text color"],
    type = "color",
    get = function() return hex2rgb(self:GetTextColor()) end,
    set = function(info, r,  g, b) self:SetTextColor(rgb2hex(r, g, b)) end,
  }
  AddSpacer(general.args)

  general.args.CustomText = {
    order = order(),
    name = L["Custom text"],
    desc = L["Specify a custom text to display instead of 'Sells for'."],
    type = "input",
    get = "GetCustomText",
    set = "SetCustomText",
  }

  local pricedata = {
    order = order(),
    type = "group",
    name = L["Price data"],
    args = {}
  }
  
  pricedata.args.RecordVendorPrices = {
    order = order(),
    type = "toggle",
    name = L["Record vendor prices"],
    desc = L["Record vendor prices"],
    type = "toggle",
    get = "IsRecordingVendorPrices",
    set = "SetRecordingVendorPrices",
  }
  -- AddSpacer(pricedata.args)

  pricedata.args.libstats = {
    order = order(),
    type = "group",
    inline = true,
    name = "Statistics",
    args = {},
  }

  pricedata.args.libstats.args.libversion = {
    order = order(),
    type = "description",
    name = function() return format("Library: %q, v. %d", self.db.global.ItemPrice_major, self.db.global.ItemPrice_minor) end,
  }
  pricedata.args.libstats.args.libcount = {
    order = order(),
    type = "description",
    name = function() return format(L["Prices in library: %d"], LibStub("ItemPrice-1.1"):GetPriceCount()) end,
  }
  local function GetNumRecordedPrices()
    local count = 0
    for _ in pairs(self.recorded_prices) do count = count + 1 end
    return count
  end
  pricedata.args.libstats.args.recordcount = {
    order = order(),
    type = "description",
    name = function() return format(L["Recorded vendor prices: %d"], GetNumRecordedPrices()) end,
  }

  pricedata.args.PurgeRecordedPrices = {
    order = order(),
    type = "execute",
    name = L["Purge prices!"],
    desc = L["Purge recorded vendor prices"],
    func = "PurgeRecordedPrices",
    confirm = true,
    disabled = function() return GetNumRecordedPrices() == 0 end,
  }


  local AceDBOptions = LibStub("AceDBOptions-3.0", true)
  local profiles
  if AceDBOptions then
    profiles = AceDBOptions:GetOptionsTable(self.db)
    profiles.order = order()
  end

  local proxy = setmetatable({}, {__index=function(proxy, name)
    if type(self[name]) ~= "function" then return end
    local delegate = function(_, _, ...) return self[name](self, ...) end
    proxy[name] = delegate
    return delegate
  end})

  options = {
    type = "group",
    name = self.name,
    handler = proxy,
    args = {
      general = general,
      pricedata = pricedata,
      profiles = profiles,
    },
  }
  return options
end


