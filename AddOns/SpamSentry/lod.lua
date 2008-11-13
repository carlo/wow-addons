-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- lod.lua
-- Load-on-demand functionality
-----------------------------------

local modules = {
                  bot = {},
                  report = {},
                  rp = {},
                  big5 = {},
                }
local header = "X-SpamSentry-"

function SS:Load(m)
  for i,v in pairs(modules[m]) do
    if not IsAddOnLoaded(v) then
      LoadAddOn(v)
    end
  end   
  modules[m] = {}
end

function SS:DetectAddonFiles()
   local num = GetNumAddOns()
   for i = 1, num,1 do
      if not IsAddOnLoaded(i) and IsAddOnLoadOnDemand(i) then
         if GetAddOnMetadata(i, header.."Report") then
            tinsert(modules.report, i)
         elseif GetAddOnMetadata(i, header.."Bot") then
            tinsert(modules.bot, i)
         elseif GetAddOnMetadata(i, header.."RP") then
            tinsert(modules.rp, i)
         elseif GetAddOnMetadata(i, header.."Big5") then
            tinsert(modules.big5, i)
         end
      end
   end
end

