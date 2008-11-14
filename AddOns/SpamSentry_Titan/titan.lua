-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- titan.lua
-- Plug-In for TitanBar
-----------------------------------

-- don't bother loading plugin data if Titan isn't loaded successfully
if not IsAddOnLoaded("Titan") then return end

local L = AceLibrary("AceLocale-2.2"):new("SpamSentry")

function SS_Titan_OnLoad(self)
  if IsAddOnLoaded("Titan") then
    self.registry = {
      id = "SpamSentry",
      version = tostring(SS.db.profile.version),
      menuText = "SpamSentry", 
      buttonTextFunction = "SS_Titan_GetButtonText",
      tooltipTitle = "SpamSentry",
      tooltipCustomFunction = SS_Titan_SetTooltip,
      icon = "Interface\\AddOns\\SpamSentry\\icon", 
      iconWidth = 16,
      savedVariables = {
        ShowIcon = 1,
        ShowLabelText = NIL,
        ShowColoredText = 1,
      }
    }
    TitanPanelButton_OnLoad(self)
    SS:RegisterEvent("SPAMSENTRY_REPORTLIST_UPDATED", function() 
        SS:OnDataUpdate()
        TitanPanelPluginHandle_OnUpdate("SpamSentry", TITAN_PANEL_UPDATE_ALL)
      end
   )
  end
end

function SS_Titan_GetButtonText(id)
  local numspam,numbot,numrp = 0,0,0
  local db,dr = SS.db.profile, SS.dbr.realm
  numspam = getn(SS.spamReportList)
  numbot = getn(dr.botReportList)
  numrp = getn(dr.rpReportList)
  
  local text1, text2, text3 = "", "", ""
  if db.showSpamCounter then text1 = string.format("S:|cffffffff%d|r ", numspam) end
  if db.showBotCounter then text2 = string.format("B:|cffffffff%d|r ", numbot) end
  if db.showRPCounter then text3 = string.format("N:|cffffffff%d|r", numrp) end
  
  TitanUtils_GetPlugin("SpamSentry").icon = numspam==0 and "Interface\\AddOns\\SpamSentry\\icon" or "Interface\\AddOns\\SpamSentry\\icon_red"
  return "SpamSentry", text1..text2..text3
end

function SS_Titan_SetTooltip()
  local numspam = getn(SS.spamReportList)
  local numbot = getn(SS.dbr.realm.botReportList)
  local numrp = getn(SS.dbr.realm.rpReportList)
  local numblock = SS.db.profile.totalBlocked
  
  -- Tooltip title
  GameTooltip:SetText("SpamSentry", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

  GameTooltip:AddLine("\n");
  GameTooltip:AddLine("|cffffffff"..L["spam"].."|r")
  GameTooltip:AddDoubleLine(L["total blocked"], numblock)
  GameTooltip:AddDoubleLine(L["on reportlist"], numspam)
  
  GameTooltip:AddLine("\n")
  GameTooltip:AddLine("|cffffffff"..L["bot"].."|r")
  GameTooltip:AddDoubleLine(L["on reportlist"], numbot)

  GameTooltip:AddLine("\n")
  GameTooltip:AddLine("|cffffffff"..L["naming"].."|r")
  GameTooltip:AddDoubleLine(L["on reportlist"], numrp)

  GameTooltip:AddLine("\n")
  GameTooltip:AddLine(TitanUtils_GetGreenText("Hint: "..L["Click to submit ticket"]))
end

function SS_Titan_OnClick(self, button)
  if button == "LeftButton" then
    if getn(SS.spamReportList)>0 then
      SS_Report:ShowGUI("spam")
    elseif getn(SS.dbr.realm.botReportList)>0 then
      SS_Report:ShowGUI("bot")
    else
      SS_Report:ShowGUI("rp")
    end
  elseif button == "RightButton" then
    GameTooltip:Hide()
    SS:OpenMenu(TitanPanelSpamSentryButton)
  end
end
