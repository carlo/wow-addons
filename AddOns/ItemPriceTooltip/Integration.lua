local _G = _G
local LibStub = LibStub or error("LibStub not found!")
local ItemPriceTooltip = LibStub("AceAddon-3.0"):GetAddon("ItemPriceTooltip")

local pcall = pcall
local select = select
local tonumber = tonumber
local type = type
local xpcall = xpcall

local GetAddOnInfo = GetAddOnInfo

-- No global variables after this!

local function errorhandler(msg)
  return _G.geterrorhandler()(msg)
end

local EnableLinkWranglerSupport
local EnableLinksSupport, DisableLinksSupport

local function init()
  init = nil

  local function ToItemId(item)
    return tonumber(item) or type(item) == "string" and tonumber(item:match("item:(%d+)"))
  end
  
  if select(5, GetAddOnInfo("Links")) then
    local AceEvent20Handler
    if _G.AceLibrary then
      local handler = {}
      local ok, err = pcall(function() _G.AceLibrary("AceEvent-2.0"):embed(handler) end)
      AceEvent20Handler = ok and handler
      if not ok then ItemPriceTooltip:Debug(tostring(err)) end
    end

    if AceEvent20Handler then
      function EnableLinksSupport()
        AceEvent20Handler:RegisterEvent("Links_LinkOpened", function(item, tooltip)
          if not ItemPriceTooltip:IsEnabled() then return end
          local id = ToItemId(item)
          if not id then return end
          ItemPriceTooltip:AddPrice(tooltip, 1, id)
        end)
        ItemPriceTooltip:Debug("Support for Links enabled")
        DisableLinksSupport = DisableLinksSupport or function()
          AceEvent20Handler:UnregisterEvent("Links_LinkOpened")
        end
      end
    end
  end

  if select(5, GetAddOnInfo("LinkWrangler")) then
    if type(_G.LinkWrangler) == "table" and tonumber(_G.LinkWrangler.Version) >= 1.6 then
      local LinkWrangler = _G.LinkWrangler
      function EnableLinkWranglerSupport()
        LinkWrangler.RegisterCallback("ItemPriceTooltip", function(frame, link)
          if not ItemPriceTooltip:IsEnabled() then return end
          local id = ToItemId(link)
          if not id then return end
          ItemPriceTooltip:AddPrice(frame, 1, id)
        end, "refresh")
        EnableLinkWranglerSupport = nil
        ItemPriceTooltip:Debug("Support for LinkWrangler enabled")
      end
    end
  end
end

function ItemPriceTooltip:EnableIntegration()
  if init then init() end
  if EnableLinkWranglerSupport then xpcall(EnableLinkWranglerSupport, errorhandler) end
  if EnableLinksSupport then xpcall(EnableLinksSupport, errorhandler) end
end

function ItemPriceTooltip:DisableIntegration()
  if DisableLinksSupport then xpcall(DisableLinksSupport, errorhandler) end
end



