-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- report.lua
-- Spam management and report functions
-----------------------------------

SS_Report = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0")
local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

-----------------------------------
-----------------------------------
-- Initialisation

SS_Report.itemHeight = 55
SS_Report.shown = 5
SS_Report.tablet = AceLibrary("Tablet-2.0")

function SS_Report:OnEnable()
  self:RegisterEvent("SPAMSENTRY_REPORTLIST_UPDATED", "Update")

  -- Setup the default ticket texts
  local b = SS.dbr.realm.botTicketText
  local r = SS.dbr.realm.rpTicketText
  if not b or b =="" then
    SS.dbr.realm.botTicketText = getglobal("SPAMSENTRY_BOTTEXT_"..SS.dbr.realm.reportLanguage)
  end
  if not r or r =="" then
    SS.dbr.realm.rpTicketText = getglobal("SPAMSENTRY_RPTEXT_"..SS.dbr.realm.reportLanguage)
  end
  
  -- Setup the spam report frame
  local frameName = "SpamSentryUI"
  local item
  local offset = -6

  local item = CreateFrame("Button", frameName .. "Item1", SpamSentryUI, "SpamSentryItem")
  item:SetPoint("TOPLEFT", 10, offset + 10 - self.itemHeight)
  item:SetPoint("BOTTOMRIGHT", frameName .. "ScrollFrame", "TOPLEFT", 10, offset - self.itemHeight)
  item:SetID(1)
  self:RegisterToolTip(item)
  
  for i=2, self.shown, 1 do
    item = CreateFrame("Button", frameName .. "Item" .. i, SpamSentryUI, "SpamSentryItem")
    item:SetPoint("TOPLEFT", frameName .. "Item" .. i-1, "BOTTOMLEFT", 0, offset)
    item:SetPoint("BOTTOMRIGHT", frameName .. "Item" .. i-1, "BOTTOMRIGHT", 0, offset - self.itemHeight)
    item:SetID(i)
    self:RegisterToolTip(item)
  end
end

-----------------------------------
-----------------------------------
-- Spam list and edit functions

function SS_Report:ListSpam()
  local l = SS.spamReportList
  local num = getn(l)
  if num>0 then
    SS:Msg(0, L["Blocked messages:"])
    for i=1, num, 1 do
      character = l[i].player
      message = gsub(l[i].message, "\n", " ")
      typ = l[i].type;
      if strlen(message)>50 then
        message = strsub(message, 1, 50)
      end
      SS:Msg(0, format("%s. %s(%s): |cffffffff%s ...|r" , tostring(i), SS:PlayerLink(character), typ, message))
    end
  else
    SS:Msg(0, L["No blocked messages"])
  end
end

function SS_Report:RemoveSpam(name, manual)
  local l = SS.spamReportList
  local index = SS:InList(l, name)
  if not index then return end
  if SS.chatHistory[name] then -- Reset the chatcache to prevent re-blocking
    SS.chatHistory[name].message = {}
    SS.chatHistory[name].time = {}
  end
  tremove(SS.spamReportList, index)
  if manual then
    DelIgnore(name)
    tremove(SS.characterBlackList, index)
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["%s has been removed"], name))  
end

function SS_Report:ClearSpam(num, manual)
  if num==0 then
    num = getn(SS.spamReportList)
  end
  for i=1, num, 1 do
    local name = SS.spamReportList[1].player
    if SS.chatHistory[name] then -- Reset the chatcache to prevent re-blocking
      SS.chatHistory[name].message = {}
      SS.chatHistory[name].time = {}
    end
    tremove(SS.spamReportList, 1)
    if manual then
      DelIgnore(name)
      tremove(SS.characterBlackList, 1)
    end
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["Reportlist cleared (%s items)"], num))
end

-----------------------------------
-----------------------------------
-- Ticket / Report functions

function SS_Report:SendSpamReport()
  local l = SS.spamReportList
  for i=1, getn(l),1 do
    if l[i].id then
     ComplainChat(l[i].id)
    else
      SS:Msg(0, "No ID for: "..l[i].message)
    end
  end
  self:ClearSpam(0)
end

-- Show the SpamSentry ticketframe GUI
function SS_Report:ShowGUI(t)
  if t=="spam" then
    SpamSentrySend:SetText(SEND_LABEL)
    SpamSentryClear:SetText(CLEAR_ALL)
    SpamSentry_HelpText:SetText(L["SSGUIHELP"])  
    SpamSentryUIParent:Show()
    return
  end

  SpamSentry_TicketButtonEditBot:Hide()
  SpamSentry_TicketButtonEditRP:Hide()
  SpamSentry_TicketButtonClearBot:Hide()
  SpamSentry_TicketButtonClearRP:Hide()
  if t=="bot" then
    SpamSentry_TicketHelpText:SetText(L["SSGUITICKETHELP"])
    SpamSentry_TicketEditBox:SetText(self:MakeBotReport())
    SpamSentry_TicketButtonClearBot:Show()
  elseif t=="rp" then
    SpamSentry_TicketHelpText:SetText(L["SSGUITICKETHELP"]) 
    SpamSentry_TicketEditBox:SetText(self:MakeRPReport())
    SpamSentry_TicketButtonClearRP:Show()
  elseif t=="editbot" then
    SpamSentry_TicketHelpText:SetText(L["SSGUIHELP_EDITTICKETTEXT"])
    SpamSentry_TicketButtonEditBot:Show()
    SpamSentry_TicketEditBox:SetText(SS.dbr.realm.botTicketText)
  elseif t=="editrp" then
    SpamSentry_TicketHelpText:SetText(L["SSGUIHELP_EDITTICKETTEXT"])
    SpamSentry_TicketButtonEditRP:Show()
    SpamSentry_TicketEditBox:SetText(SS.dbr.realm.rpTicketText)
  elseif t=="feedback" then
    SpamSentry_TicketHelpText:SetText(L["SSGUIHELP_FEEDBACK"])
    SpamSentry_TicketEditBox:SetText(self:FeedBackText())
  end
  SpamSentryUITicketParent:Show()
end

-- Create the bot report-text
function SS_Report:MakeBotReport()
  local text = L["Nothing to report"]
  local report = "\n"
  local l = SS.dbr.realm.botReportList
  local num = min(5, getn(l))   -- Limit reports to 5 due to the 500-char ticket limit.

  if num > 0 then
    for i=1, num, 1 do
      raceclass = ""
      if l[i].race and l[i].class then
        raceclass = "("..l[i].race.." "..l[i].class..")"
      end
      report = report .. format("%s %s- %s - %s. "..L["Farming:"].." %s\n", l[i].player, raceclass, l[i].date, l[i].location, l[i].mob or "")
    end
    text = format(SS.dbr.realm.botTicketText, UnitName("player"))..report
  end
  return text,count
end

-- Create the RP report-text
function SS_Report:MakeRPReport()
  local text = L["Nothing to report"]
  local report = "\n"
  local l = SS.dbr.realm.rpReportList
  local num = min(5, getn(l))   -- Limit reports to 5 due to the 500-char ticket limit.

  if num > 0 then
    for i=1, num, 1 do
      raceclass = ""
      if l[i].race and l[i].class then
        raceclass = l[i].race.." "..l[i].class
        if not raceclass=="" then raceclass = "("..raceclass..")" end
      end
      report = report .. format("%s %s- %s\n", l[i].player, raceclass, l[i].date)
    end
    text = format(SS.dbr.realm.rpTicketText, UnitName("player"))..report
  end
  return text,count
end
-----------------------------------
-----------------------------------
-- Ticket text editing

function SS_Report:ResetTicketText()
  SS.dbr.realm.botTicketText = getglobal("SPAMSENTRY_BOTTEXT_"..SS.dbr.realm.reportLanguage)
  SS.dbr.realm.rpTicketText = getglobal("SPAMSENTRY_RPTEXT_"..SS.dbr.realm.reportLanguage)
end

-----------------------------------
-----------------------------------
-- Feedback functions

function SS_Report:FeedBackText()
  local ret = ""
  if SS.spamFeedbackList then
    for i,v in pairs(SS.spamFeedbackList) do
      ret = ret .. self:StringToHex(v).."\n\n"
    end
  end
  return ret
end

local str2hex = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
function SS_Report:StringToHex(s)
  local ret, b, n, m = "", 0, 0 ,0
  for i=1, strlen(s), 1 do
    b = strbyte(s, i)
    n = mod(b, 16)
    m = (b - n) / 16
    ret = ret..str2hex[m+1]..str2hex[n+1]
  end
  return ret
end

-----------------------------------
-----------------------------------
-- GUI functions

function SS_Report:RegisterToolTip(item)
  SS_Report.tablet:Register(item, 
    'children', function() 
      local id = item:GetID()

      local cat = SS_Report.tablet:AddCategory(
          'columns', 2,
          'child_textR', 1,
          'child_textG', 1,
          'child_textB', 0,
          'child_textR2', 1,
          'child_textG2', 1,
          'child_textB2', 1
      )
      cat:AddLine('text', NAME, 
                  'text2', SS.spamReportList[id].player
      )
      cat:AddLine('text', L["Date / time"],
                  'text2', SS.spamReportList[id].time
      )
      cat:AddLine('text', L["Channel"],
                  'text2', SS.spamReportList[id].type
      )
      cat:AddLine('text', L["Message-ID"],
                  'text2', SS.spamReportList[id].id or "|cffff0000n/a|r"
      )

      SS_Report.tablet:SetHint(L["Click to copy message\n<CTRL>-Click to remove message"])
    end,
    'point', function()
      return "TOPRIGHT", "TOPLEFT"
    end
  )
end

function SS_Report:OnMousewheel(scrollframe, direction)
  local scrollbar = getglobal(scrollframe:GetName() .. "ScrollBar")
  scrollbar:SetValue(scrollbar:GetValue() - direction * (scrollbar:GetHeight() / 2))
  self:Update()
end

function SS_Report:Update()
  local size = getn(SS.spamReportList)
  FauxScrollFrame_Update(SpamSentryUIScrollFrame, size, SS_Report.shown, SS_Report.shown)

  local offset = SpamSentryUIScrollFrame.offset
  for index = 1, SS_Report.shown, 1 do
    local i = index + offset
    local item = getglobal("SpamSentryUIItem".. index)

    if i <= size then
      item:SetText(format("|cffffff00[%02d] %s: |cffffffff%s|r",i,SS.spamReportList[i].player, SS.spamReportList[i].message))
      item:SetID(i)
      item:Show()
    else
      item:Hide()
    end
  end
  
  SpamSentry_Counter:SetText(format(L["[Items on reportlist: %s]"], size))
end

-- Show a dialog box with given text. Executes the given functions on accept/cancel.
-- Blizzard has a weird popup ui. Some of this code was taken from Prat UrlCopy
function SS_Report:ShowCopyPopup(message)
  StaticPopupDialogs["SPAMSENTRY_NOTIFICATION"] = {
    text = L["Message:"],
    button2 = CLOSE,
    hasEditBox = 1,
    hasWideEditBox = 1,
    showAlert = 1,
    maxLetters = 255,
    OnAccept = function() end,
    timeout = 0,
    whileDead = 1,
    exclusive=1,
    hideOnEscape = 1,
    OnShow = function()
      getglobal(this:GetName().."WideEditBox"):SetText(message)
      getglobal(this:GetName().."WideEditBox"):SetFocus()
      getglobal(this:GetName().."WideEditBox"):HighlightText()

      local button = getglobal(this:GetName().."Button2")
      button:ClearAllPoints()
      button:SetWidth(200)
      button:SetPoint("CENTER", getglobal(this:GetName().."WideEditBox"), "CENTER", 0, -30)
      getglobal(this:GetName().."AlertIcon"):Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,

  };
  StaticPopup_Show ("SPAMSENTRY_NOTIFICATION")
end
