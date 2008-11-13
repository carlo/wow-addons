-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- bot.lua
-- Bot report functions
-----------------------------------

SS_Bot = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
local L = AceLibrary("AceLocale-2.2"):new("SS_Bot")

function SS_Bot:Add(plr, tar, rac, cla)
  local loc = GetZoneText()..", "..GetSubZoneText()
  local datetime = tostring(date())
  local t = time()
  local sum = datetime.." - "..loc.."\n"..rac.." "..cla.."\n"..L["farming:"].." "..tar

  tinsert(SS.dbr.realm.botReportList,  {  player = plr,
                                          mob = tar,
                                          date = datetime,
                                          location = loc,
                                          race = rac,
                                          class = cla,
                                          summary = sum,
                                        })
  tinsert(SS.dbr.realm.botBlackList,{  player = plr,
                                                time = t
                                            })
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["%s has been added to the reportlist"], plr))
end

local botEditBox
local markedPlayer, markedRace, markedClass

-- Shows a pop-up dialog to mark a player as bot
function SS_Bot:Mark()
  StaticPopupDialogs["SPAMSENTRY_MARKBOT"] = {
    text = L["Type a name or select a player to mark as bot"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      markedPlayer = getglobal(this:GetParent():GetName().."EditBox"):GetText()
      markedRace = UnitRace("target")
      markedClass = UnitClass("target")
      if not SS:InList(SS.dbr.realm.botBlackList, markedPlayer) then
        SS_Bot:ScheduleEvent(SS_Bot.MarkMob, 0.2)
      else
        SS:ShowNotification( format(L["%s has been reported before"], markedPlayer), 
                          TEXT(CONTINUE), 
                          function() SS_Bot:MarkMob() end, 
                          TEXT(CANCEL), 
                          function() end
                         )      
      end
    end,
    OnShow = function()
      botEditBox = this:GetName().."EditBox"
      SS_Bot:RegisterEvent("PLAYER_TARGET_CHANGED", function() 
        if UnitIsPlayer("target") then 
          getglobal(botEditBox):SetText(UnitName("target") or "") 
        end 
      end)
      if UnitIsPlayer("target") then
        getglobal(botEditBox):SetText(UnitName("target") or "")
      end
    end,
    OnHide = function()
      SS_Bot:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
  StaticPopup_Show ("SPAMSENTRY_MARKBOT")
end

function SS_Bot:MarkMob()
  StaticPopupDialogs["SPAMSENTRY_MARKBOT"] = {
    text = L["Type a name or select the mob this bot is farming"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      SS_Bot:Add(markedPlayer, getglobal(this:GetParent():GetName().."EditBox"):GetText(), markedRace or "", markedClass or "")
    end,
    OnShow = function()
      botEditBox = this:GetName().."EditBox"
      SS_Bot:RegisterEvent("PLAYER_TARGET_CHANGED", function() 
        if not UnitIsPlayer("target") then 
          getglobal(botEditBox):SetText(UnitName("target") or "") 
        end 
      end)
      if not UnitIsPlayer("target") then
        getglobal(botEditBox):SetText(UnitName("target") or "")
      end
    end,
    OnHide = function()
      SS_Bot:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
  StaticPopup_Show ("SPAMSENTRY_MARKBOT")
end

function SS_Bot:List()
  local l = SS.dbr.realm.botReportList
  local num = getn(l)
  if num > 0 then
    SS:Msg(0, L["Marked bots"])
    for i=1, num, 1 do
      character = l[i].player
      date = l[i].date
      loc = l[i].location
      raceclass = ""
      if l[i].race and l[i].class then
        raceclass = " ("..l[i].race.." "..l[i].class..")"
      end
      SS:Msg(0, format("%s. %s%s: |cffffffff%s-%s|r\n" , tostring(i),character, raceclass, date, loc))
    end
  else
    SS:Msg(0, L["No marked bots"])
  end
end

function SS_Bot:Remove(name, manual)
  local l = SS.dbr.realm.botReportList
  local index = SS:InList(l, name)
  if not index then return end

  tremove(SS.dbr.realm.botReportList, index)
  if manual then
    SS_Bot:RemoveBotBlackList(name)
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["%s has been removed"], tostring(name)))
end

function SS_Bot:Clear(num, manual)
  -- Clean garbage: Remove entries older then 14 days from the blacklist
  local t = time() - 1209600 
  for i=1, getn(SS.dbr.realm.botBlackList), 1 do
    if SS.dbr.realm.botBlackList[1].time < t then
      tremove(SS.dbr.realm.botBlackList, 1)
    else
      break
    end
  end
  -- Clear the reportlist
  if num==0 then
    num = getn(SS.dbr.realm.botReportList)
  end
  for i=1, num, 1 do
    local name = SS.dbr.realm.botReportList[1].player
    tremove(SS.dbr.realm.botReportList, 1)
    if manual then
      SS_Bot:RemoveBotBlackList(name)
    end
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["Reportlist cleared (%s items)"], num))
end

function SS_Bot:RemoveBotBlackList(plr)
  for i=1, getn(SS.dbr.realm.botBlackList), 1 do
    if SS.dbr.realm.botBlackList[i].player == plr then
      tremove(SS.dbr.realm.botBlackList, i)
      break
    end
  end
end
