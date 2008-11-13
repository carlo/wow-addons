-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- rp.lua
-- RP naming violation report functions
-----------------------------------

SS_RP = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
local L = AceLibrary("AceLocale-2.2"):new("SS_RP")

function SS_RP:Add(plr, override)
  if override or not SS:InList(SS.dbr.realm.rpBlackList, plr) then
    local rac, cla = "",""
    if UnitName("target")==plr then
      rac = UnitRace("target")
      cla = UnitClass("target")
    end
    local datetime = tostring(date())
    local t = time()
    local sum = datetime.." - "..rac.." "..cla
    tinsert(SS.dbr.realm.rpReportList,  {  player = plr,
                                            date = datetime,
                                            race = rac,
                                            class = cla,
                                            summary=sum,
                                         })
    tinsert(SS.dbr.realm.rpBlackList,{  player = plr,
                                        time = t
                                     })
    SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
    SS:Msg(0, format(L["%s has been added to the reportlist"], plr))
  else
    SS:ShowNotification( format(L["%s has been reported before"], plr), 
                         TEXT(CONTINUE), 
                         function() SS_RP:Add(plr, true) end, 
                         TEXT(CANCEL), 
                         function() end
                         )      
  end
end

local rpEditBox
-- Shows a pop-up dialog to mark a player as bot
function SS_RP:Mark()
  StaticPopupDialogs["SPAMSENTRY_MARKRP"] = {
    text = L["Type a name or select a player violating naming rules"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      SS_RP:Add(getglobal(this:GetParent():GetName().."EditBox"):GetText())
    end,
    OnShow = function()
      rpEditBox = this:GetName().."EditBox"
      SS_RP:RegisterEvent("PLAYER_TARGET_CHANGED", function() 
        if UnitIsPlayer("target") then 
          getglobal(rpEditBox):SetText(UnitName("target") or "") 
        end 
      end)
      if UnitIsPlayer("target") then
        getglobal(rpEditBox):SetText(UnitName("target") or "")
      end
    end,
    OnHide = function()
      SS_RP:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end,
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
  StaticPopup_Show("SPAMSENTRY_MARKRP")
end

function SS_RP:List()
  local l = SS.dbr.realm.rpReportList
  local num = getn(l)
  if num > 0 then
    SS:Msg(0, L["Marked players"])
    for i=1, num, 1 do
      character = l[i].player
      date = l[i].date
      raceclass = ""
      if l[i].race and l[i].class then
        raceclass = " ("..l[i].race.." "..l[i].class..")"
      end
      SS:Msg(0, format("%s. %s %s: |cffffffff%s|r\n" , tostring(i),character, raceclass, date))
    end
  else
    SS:Msg(0, L["No marked players"])
  end
end

function SS_RP:Remove(name, manual)
  local l = SS.dbr.realm.rpReportList
  local index = SS:InList(l, name)
  if not index then return end

  tremove(SS.dbr.realm.rpReportList, index)
  if manual then
    SS_RP:RemoveRPBlackList(name)
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["%s has been removed"], tostring(name)))
end

function SS_RP:Clear(num, manual)
  -- Clean garbage: Remove entries older then 14 days from the blacklist
  local t = time() - 1209600 
  for i=1, getn(SS.dbr.realm.rpBlackList), 1 do
    if SS.dbr.realm.rpBlackList[1].time < t then
      tremove(SS.dbr.realm.rpBlackList, 1)
    else
      break
    end
  end
  -- Clear the reportlist
  if num==0 then
    num = getn(SS.dbr.realm.rpReportList)
  end
  for i=1, num, 1 do
    local name = SS.dbr.realm.rpReportList[1].player
    tremove(SS.dbr.realm.rpReportList, 1)
    if manual then
      SS_RP:RemoveRPBlackList(name)
    end
  end
  SS:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
  SS:Msg(0, format(L["Reportlist cleared (%s items)"], num))
end

function SS_RP:RemoveRPBlackList(plr)
  for i=1, getn(SS.dbr.realm.rpBlackList), 1 do
    if SS.dbr.realm.rpBlackList[i].player == plr then
      tremove(SS.dbr.realm.rpBlackList, i)
      break
    end
  end
end
