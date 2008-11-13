-----------------------------------
-----------------------------------
-- SpamSentry by Anea
--
-- Detects and blocks gold-spam messages
-- Type /sentry or /spamsentry in-game for options
-----------------------------------
-- core.lua
-- Main routines and functionionality
-----------------------------------

-- Create Ace2 instance
SS = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "AceHook-2.1", "FuBarPlugin-2.0", "AceModuleCore-2.0", "WhoLib-1.0")
local L = AceLibrary("AceLocale-2.2"):new("SpamSentry")

-- Default settings and variables
local defaultsProfile = {
  version = 0,                       -- The version we are running
  channelList = {                    -- Monitored channels
                 [L["whisper"]] = true,
                 [L["say"]] = true,
                 [L["yell"]] = true,
                 [L["general"]] = true,
                 [L["trade"]] = true,
                 [L["guildrecruitment"]] = true,
                },
  totalBlocked = 0,                  -- Blocked messages
  enableDelay = true,                -- Enables delaying of messages
  notifyMessage = true,              -- Shows a warning when a message has been blocked
  notifyHourly = true,               -- Shows an hourly reminder when messages have been blocked
  notifyDebug = false,               -- Shows debug messages
  showSpamCounter = true,            -- Show counter in fubar/titan
  showBotCounter = false,            -- Show counter in fubar/titan
  showRPCounter = false,             -- Show counter in fubar/titan
  minimumLevel = 1,                  -- Set the minimum level of players to be able to whisper you
  hidePartyInvite = false,           -- Hide party-invites from people you don't know
}
local defaultsRealm = {
  reportLanguage = GetLocale(),      -- Language of the ticketmessage
  botReportList = {},                -- List with tagged bots
  botBlackList = {},                 -- List with recently tagged bots
  rpReportList = {},                 -- List with tagged RP name violators
  rpBlackList = {},                  -- List with recently tagged RP name violators
  spamTicketText = "",               -- Custom ticket text
  botTicketText = "",                -- Custom ticket text
  rpTicketText = "",                 -- Custom ticket text
}
local defaultsChar = {
  ignoreList = {},                   -- List with temporarily ignored players
}

-- local variables
SS.currentBuild = 20070613           -- Latest build
SS.variablesLoaded = false           -- True once the mod has properly started up.

SS.spamReportList = {}               -- List with caught spammers
SS.message = {}                      -- Spam and Ham scores from messages
SS.character = {}                    -- List with characters
SS.characterBlackList = {}           -- Blacklisted characters for this session
SS.spamFeedbackList = {}                 -- List with manually reported spammers cached for later feedback

SS.lastPlayer = ""                   -- Last player that a who-query was send for
SS.lastMessage = ""                  -- Last message that was send to you (skip duplicate entries sent by the interface)
SS.chatHistory = {}                  -- Chat cache
SS.chatQueue = {}                    -- Queue with messages that need a bit of delaying
SS.whoQueue = {}                     -- Queue with players we want to look up

SS.guildList={}                      -- Cache of the guildlist
SS.partyList={}                      -- Cache of the current party/raid
SS.friendsList = {}                  -- Cache of the friendslist
SS.knownList={}                      -- Cache of people you have talked to

SS.strip = "[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$\194\163\226\130\172=,.]+"    -- Pattern for stripping spacers from messages.
SS.clean = "[^a-zA-Z0-9$\194\163\226\130\172=,.%s]+"  -- Pattern for cleaning messages.

SS.blackList = {
                "dollar",
                "pounds",
                "usd",
                "gbp",
                "$%d+.+%d+g",
                "%d+g.+$%d+",
                "\226\130\172%d+.+%d+g",
                "%d+g.+\226\130\172%d+",
                "\194\163%d+.+%d+g",
                "%d+g.+\194\163%d+",
                "powerlevel",
                "www",
                "[,.]com", "[,.]corn", "[,.]conn", "[,.]c0m", "[,.]c0rn", "[,.]c0nn",
                "peons", "p3ons", "pe0ns", "p30ns", "peon5", "p3on5", "pe0n5", "p30n5",
                "1to70",
                "pl170",
                "gameworker",
               }
SS.greyList = {
                "cheap",
                "visit",
                "buy",
                "delivery",
                "discount",
                "peons",
                "170",
                "375",
                "gold",
                "payment",
                "website",
                "bucks",
                "safe",
              }
SS.websites = {
                "100g.ca",
                "1225game",
                "29games",
                "365ige",
                "agamegold",
                "agamegoid",
                "auctionwowhouse",
                "buywowgame",
                "buyw0wgame",
                "buyvvowgame",
                "championshall",
                "eusupplier",
                "eugspa",
                "gagora",
                "gamenoble",
                "gmauthorization",
                "gmworker",
                "gmw0rker",
                "gmworking",
                "gmw0rking",
                "gold4guild",
                "goldwithyou",
                "goldwow",
                "helpugame",
                "heygt",
                "hugold",
                "igdollar",
                "igamebuy",
                "igm365",
                "igs36five",
                "igs365",
                "gs365",
                "itembay",
                "itemrate",
                "iuc365",
                "kgs",
                "mmoinn",
                "mmospa",
                "ogchannel",
                "ogmarket",
                "ogs365",
                "0gs365",
                "ogs4u",
                "okstar2008",
                "p4hire",
                "peons4hire",
                "peons4h1re",
                "peons4",
                "4hire",
                "p3ons",
                "hir3",
                "pkpkg",
                "player123",
                "ssegames",
                "speedpanda",
                "terrarpg",
                "tusongame",
                "ucgogo",
                "ucatm",
                "whoyo",
                "wow4s",
                "wowcoming",
                "woweuropecn",
                "woweuropegold",
                "wowforever",
                "wowfreebuy",
                "wowgoldsky",
                "wowgoldex",
                "wowgshop",
                "wowjx",
                "wowmine",
                "wowpanning",
                "wowpfs",
                "wowspa",
                "wowstar2008",
                "wowsupplier",
                "zlywy",
              } 

-----------------------------------
-----------------------------------
-- Initialisation functions

function SS:OnInitialize()
  self:RegisterDB("SpamSentryDB", "SpamSentryDBchar")
  self.dbr = self:AcquireDBNamespace("dbr")
  self.dbc = self:AcquireDBNamespace("dbc")

  self:RegisterDefaults("profile", defaultsProfile)
  self:RegisterDefaults("dbr", "realm", defaultsRealm)
  self:RegisterDefaults("dbc", "char", defaultsChar)

  self:SetupOptions()
  self:DetectAddonFiles()
  
  -- Add entries to the unit-pop-up menu's.
  UnitPopupButtons["SPAMSENTRY_RP"] = { text = L["|cffff8833Report Name|r"], dist = 0 }
  NEWBIE_TOOLTIP_UNIT_SPAMSENTRY = L["Add this player to the SpamSentry naming violation reportlist"]
  table.insert(UnitPopupMenus["FRIEND"], 8, "SPAMSENTRY_RP")
  end

function SS:OnEnable()
  -- Cache guild and partylist
  self:RegisterBucketEvent({"PLAYER_GUILD_UPDATE", "GUILD_ROSTER_UPDATE"}, 1, "UpdateGuildList")
  self:RegisterBucketEvent("PARTY_MEMBERS_CHANGED", 1, "UpdatePartyList")
  self:RegisterBucketEvent("FRIENDLIST_UPDATE", 1, "UpdateFriendsList")
  self:UpdateGuildList()
  self:UpdatePartyList()
  self:UpdateFriendsList()
  
  -- 
  self:RegisterEvent("PARTY_INVITE_REQUEST", "CheckPartyInvite")

  -- Register localised blacklist
  self.localisedBlackList = L:LocalisedBlackList()

  if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
    self:StartUp()
  else
    self:RegisterEvent("AceEvent_FullyInitialized", "StartUp")
  end
end

function SS:OnDisable()
  self:FlushChatQueue()           -- Show all delayed messages  now
  self:UnhookAll()                -- Disable all hooks
  self.variablesLoaded = false    -- Flag this mod as disabled
end

function SS:StartUp()
  if not self.variablesLoaded then
    self:Hook("ChatFrame_MessageEventHandler", true)   -- Hook the Chatframe OnEvent function.
    self:Hook("SetItemRef", true)                      -- Hook the ItemLink OnEvent function
    self:SecureHook("UnitPopup_OnClick")               -- Hook the UnitPopup OnClick function
    self:Compat_Enable()                               -- Hook 3rd party addons

    -- Clear the ignorelist from last session
    self:ClearIgnore(0)

    -- Update the GUI
    self:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
   
    -- Check version, update variables
    self:CheckVersion()
    
    -- Start queue-system
    self:ToggleChatQueue()
    
    -- Schedules
    self:ScheduleRepeatingEvent("SS_CHECKREPORT", SS.CheckReport, 3600)           -- Hourly report message
    self:ScheduleRepeatingEvent("SS_CHATQUEUECOOLDOWN", SS.ChatQueueCooldown, 5)  -- Who-callback check
    self:ScheduleRepeatingEvent("SS_COLLECTGARBAGE", SS.CollectGarbage, 60)       -- Garbage collection
        
    self.variablesLoaded = true
    self:CheckReport()
  end
end

-----------------------------------
-----------------------------------
-- Hooks and events

-- Chat message event
function SS:ChatFrame_MessageEventHandler(event, handler)
  local msg = arg1
  local plr = arg2
  local chn = strlower(tostring(arg4))
  local id = arg11
  local spam = -2
  local channels = self.db.profile.channelList
  local tmsg = ""
  
  if msg and plr then
    if event == "CHAT_MSG_WHISPER" and channels[L["whisper"]] then
      self.knownList[plr] = true
      chn = L["whisper"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif event== "CHAT_MSG_SAY" and channels[L["say"]] then
      chn = L["say"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif event== "CHAT_MSG_YELL" and channels[L["yell"]] then
      chn = L["yell"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif event=="CHAT_MSG_CHANNEL" and channels[L["trade"]] and strfind(chn, L["trade"]) then
      chn = L["trade"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif event=="CHAT_MSG_CHANNEL" and channels[L["general"]] and strfind(chn, L["general"]) then
      chn = L["general"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif event=="CHAT_MSG_CHANNEL" and channels[L["guildrecruitment"]] and strfind(chn, L["guildrecruitment"]) then
      chn = L["guildrecruitment"]
      spam = self:SpamCheck1(msg, plr, chn, event)
    elseif (strfind(event, "CHAT_MSG_SYSTEM") and self:SupressIgnoreMsg(msg)) then
      return
    end
  end

  if spam == -2 then
    self:CallChatEvent(event, handler)
  elseif spam == -1 then
    if self.db.profile.enableDelay then
      local mIndex = self:AddChatQueue(plr, msg, event, chn, id, handler)
      self.chatQueue[mIndex].queued = true
    else
      self:CallChatEvent(event, handler)
    end
  elseif spam == 1 then
    self:SpamFound(plr, self:GetChatHistory(plr), chn, id)
    self.knownList[plr] = false
  elseif spam ==2 then
    self.knownList[plr] = false
  elseif spam == 0 then
    self:SendWho(plr, msg, event, chn, id)
  end
end

-- Set query for player info
function SS:SendWho(plr, msg, event, chn, id)
  local result = self:UserInfo(plr, 
                               {
                                 queue = self.WHOLIB_QUEUE_QUIET, 
                                 timeout = -1,
                                 callback = "WhoCallback"
                               })
  local index = self:AddChatQueue(plr, msg, event, chn, id)
  if result then
    SS.character[result.Name] = {}
    SS.character[result.Name].level = result.Level
    SS.character[result.Name].guild = result.Guild
    self:ChatQueueProcessMessage(index)
  else
    self.chatQueue[index].waiting = true
  end
end

-- Callback function for who-query results
function SS:WhoCallback(result)
  if not result then 
    SS:Msg(3, "Empty WhoCallback: "..tostring(result)) 
    return 
  end
  
  SS.character[result.Name] = {}
  SS.character[result.Name].level = result.Level
  SS.character[result.Name].guild = result.Guild
  for i=1, getn(SS.chatQueue), 1 do
    if SS.chatQueue[i].name == result.Name then
      SS:ChatQueueProcessMessage(i)
    end
  end
end

-- This function hooks into clickable chatlinks. It does some action if special SpamSentry links are found.
function SS:SetItemRef(link, text, button)
  if strsub(link, 1, 20) == "SpamSentrySpamTicket" then
    SS:Load("report")
    SS_Report:ShowGUI("spam")
  elseif strsub(link, 1, 19) == "SpamSentryBotTicket"then
    SS:Load("report")
    SS_Report:ShowGUI("bot")
  elseif strsub(link, 1, 19) == "SpamSentryRPTicket"then
    SS:Load("report")
    SS_Report:ShowGUI("rp")
  elseif strsub(link, 1, 13) == "SpamSentryMsg" then
    local s,e,entry = string.find(link, "(%d+)")
    entry = tonumber(entry)
    if self.spamReportList[entry] then
      local plr = self.spamReportList[entry].player
      self:Msg(0, "* "..self:PlayerLink(plr)..": |cffff55ff"..self.spamReportList[entry].message.."|r")
    end
  else
    self.hooks.SetItemRef(link, text, button)
  end
end

-- Hook to unit-pop-up menu's
function SS:UnitPopup_OnClick()
  local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
  local val = this.value
  local unit = dropdownFrame.unit
  local name = dropdownFrame.name
  local id = dropdownFrame.lineID

  -- Report spammer
  if val == "REPORT_SPAM" then
    if (unit and not name) then name = UnitName(unit) end
    
    if name and self.chatHistory[name] then
      self.spamFeedbackList[name] = self:GetChatHistory(name)
      self:Msg(0, format(L["%s has been added to the feedback list"], name))
    end
  elseif val == "SPAMSENTRY_RP" then
    if (unit and not name) then name = UnitName(unit) end
    if name then
      SS:Load("rp") 
      SS_RP:Add(name) 
    end
  end
end

-- Outgoing chatevents
function SS:CallChatEvent(event, handler)
  if handler and type(handler)=="function" then
    handler(event)
  else
    self.hooks.ChatFrame_MessageEventHandler(event)
  end
end

-- Called when a chat-event needs to be thrown while being in a who-event.
function SS:CallOldChatEvent(index)
  local sthis, sevent, sarg1, sarg2, sarg3, sarg4, sarg5, sarg6, sarg7, sarg8, sarg9, sarg10, sarg11, sarg12 = this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12
  
  local m = self.chatQueue[index]
  if not m.done then
    this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, handler = m.this, m.event, m.arg1, m.arg2, m.arg3, m.arg4, m.arg5, m.arg6, m.arg7, m.arg8, m.arg9, m.arg10, m.arg11, m.arg12, m.handler

    self:CallChatEvent(event, handler)
    self.chatQueue[index].done = true
  end 
  this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = sthis, sevent, sarg1, sarg2, sarg3, sarg4, sarg5, sarg6, sarg7, sarg8, sarg9, sarg10, sarg11, sarg12
end

-----------------------------------
-----------------------------------
-- Spam detection

-- This function checks the message for spam. Scores are assigned for various characteristics
-- Returns 2 on blacklist, 1 on spam, 0 on yet unknown, -1 on no spam and queue, -2 whitelist
-- Returns the concatenated message if applicable
function SS:SpamCheck1(msg, plr, chn, evt)
  -- Check messaging and garbage collection
  self:ChatQueueCooldown()
  
  -- You self are whitelisted!
  if strsub(event, 10) == "WHISPER_INFORM" then return -2 end
  if plr==UnitName("player") and not self.db.profile.notifyDebug then return -2 end   -- Extra check allows debugging

  -- Player on Character blacklist has spammed before and is ignored now
  if self:InList(self.characterBlackList, plr) then return 2 end

  -- Player in your party/raid is white-listed
  if self:InList(self.partyList, plr) then return -2 end

  -- Player on your friends-list is white-listed
  if self:InList(self.friendsList, plr) then return -2 end

  -- Player in your guild is white-listed
  if self:InList(self.guildList, plr) then return -2,msg end
  
  -- GM is whitelisted
  if(TEXT(getglobal("CHAT_FLAG_"..tostring(arg6)) == CHAT_FLAG_GM)) then return -2,msg end
  
  -- Previous messages from players within the past 60 seconds are taken into account.
  self:AddChatHistory(plr, msg, chn)
  msg = self:GetChatHistory(plr)
  
  -- Blacklist items score -0.1 point for the first one, -0.2 for the next, -0.4 for the one after, etc.
  local sc,gr = self:ScoreSpam(plr, msg)
  
  if sc == 0 and not (self.db.profile.minimumLevel > 1 and chn == L["whisper"]) then 
    -- If no negative score has been found, there's no reason to do more checks or do a who-query.
    -- This should prevent Bank / Auction and other windows from closing most of the time.
    if gr == 0 then
      return -2
    end
    return -1
  elseif self.character[plr] then
    -- Check if the player has been queried before. If so, no need to do a who-query again.
    -- This lowers server-load and prevents messages passing through when spammed fast after each other
    local tsc = sc + self:ScoreHam(plr, msg)
    if tsc < 0 then
      return 1
    elseif self.character[plr].level < self.db.profile.minimumLevel then
      return 2
    elseif sc == 0 and gr ==0 then 
      -- Whitelist if no suspicious items have been found
      return -2
    end
    return -1
  end
  -- Message is suspicious, but we have no data on this player. Who-query advised.
  return 0
end

-- Secundairy spamcheck afer who-request has been completed or timed-out
-- Returns 2 on blacklist, 1 on spam, 0 on yet unknown, -1 on no spam and queue, -2 whitelist
function SS:SpamCheck2(plr, msg)
  if SS:ScoreHam(plr, msg) + SS:ScoreSpam(plr, msg) < 0 then
    return 1
  elseif self.character[plr] and self.character[plr].level < self.db.profile.minimumLevel then
    return 2
  else
    if self.db.profile.enableDelay then
      return -1
    else
      return -2
    end
  end
end

-- Looks up items from the list in the message and assigns scores
function SS:ScoreSpam(plr, msg)
  if self.message[msg] and self.message[msg].spam then
    return self.message[msg].spam, self.message[msg].grey
  end
  
  local score,grey = 0,0
  
  -- Remove all spacers and non-latin characters
  local tmsg = string.lower(string.gsub(msg, self.strip, ""))
  
  -- Parse websites
  for i=1, getn(self.websites) do
    if strfind(tmsg, strlower(self.websites[i])) then
      score = score==0 and -0.2 or score * 2
    end
  end
  -- Parse blacklist
  for i=0, getn(self.blackList), 1 do
    if self.blackList[i] and strfind(tmsg, strlower(self.blackList[i])) then 
      score = score==0 and -0.1 or score * 2
    end
  end
  -- Parse localised blacklist
  if self.localisedBlackList then
    for i=0, getn(self.localisedBlackList), 1 do
      if self.localisedBlackList[i] and strfind(msg, strlower(self.localisedBlackList[i])) then 
        score = score==0 and -0.1 or score * 2
      end
    end
  end
  -- Parse greylist. If a greylisted item is found, the message will be queued for delay. 
  -- If blacklisted items were found above, the grey score will be added to the spam score
  for i=0, getn(self.greyList), 1 do
    if self.greyList[i] and strfind(tmsg, strlower(self.greyList[i])) then 
      grey = grey==0 and -0.1 or grey * 2
    end
  end
  if score < 0 then score = score + grey end
  
  -- If the message contains a link to an item, add 0.1 points to the score.
  -- Note that this is actually hamscoring, but I have added it here to prevent from unneeded who-queries
  if strfind(msg, "|H(item:.+)|h") then
    score = score + 0.1
  end
  
  if not self.message[msg] then
    self.message[msg] = {}
  end
  self.message[msg].spam = score
  self.message[msg].grey = grey
  self.message[msg].time = GetTime()
  return score,grey
end

function SS:ScoreHam(plr, msg)
  local score = 0

  if self.character[plr] then
    local level = self.character[plr].level
    local guild = self.character[plr].guild

    if level and level>10 then
      score = score + 0.1  -- Refund if the player is above level 10
    end
    if level and level>30 then
      score = score + 0.3  -- Refund more if the player is above level 30
    end
    if guild and guild~= "" then
      score = score + 0.3  -- Refund if the player is in a guild
    end
  end

  -- If your own level is below 15, add 0.2 points to the score, as you are more likely to get messages from low-levels
  if UnitLevel("player")<15 then
    score = score + 0.2
  end
  return score
end

-----------------------------------
-----------------------------------
-- Report functions
-- List and edit functions are user-initiated, and will be load-on-demand
-- Called when a spammer is found

function SS:SpamFound(plr, msg, typ, id)
  if SS:InList(SS.characterBlackList, plr) then return end
  local entry = self:AddSpam(plr, msg, typ, id)
  if self.db.profile.notifyMessage then
    local link = "|HSpamSentrySpamTicket|h|cff8888ff["..L["here"].."]|r|h"
    local text = format(L["* Alert: %s tried to send you %s (%s). Click %s to report."], self:PlayerLink(plr), self:MessageLink(L["this message"],entry), typ, link)
    self:Msg(2, text)
    PlaySound("QUESTLOGOPEN")
  end
end

function SS:AddSpam(plr, msg, typ, id)
  self:AddIgnore(plr, typ)
  self.db.profile.totalBlocked = self.db.profile.totalBlocked + 1
  if not self:InList(self.characterBlackList, plr) then
    tinsert(self.characterBlackList, plr)
  end
  local entry = self.InList(self.spamReportList, plr)
  if not entry then
    -- clean-up message
    local tmsg = gsub(tostring(msg), SS.clean, "")
    tmsg = gsub(msg, "([%s=.,])+", "%1")
    local datetime = self:GetServerDateTime()
    local sum = datetime.."\n"..tmsg
    tinsert(self.spamReportList, { player = plr,
                                   message = tmsg,
                                   time = datetime,
                                   type = typ or "unknown",
                                   id = id,
                                   summary = sum,
                                 })
    self:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
    return getn(self.spamReportList)
  end
  return entry
end

-- Show a warning once every hour.
function SS:CheckReport()
  local m = L["One or more characters are on the reportlist. Click %s to report them to a GM."]
  -- Create a clickable link. This is handled by the SetItemRef hook.
  if getn(SS.spamReportList)>0 then
    local link = "|HSpamSentrySpamTicket|h|cff8888ff["..L["here"].."]|r|h"
    SS:Msg(1, format(m, link))
    PlaySound("QUESTLOGOPEN")
  elseif getn(SS.dbr.realm.botReportList)>0 then
    local link = "|HSpamSentryBotTicket|h|cff8888ff["..L["here"].."]|r|h"
    SS:Msg(1, format(m, link))
    PlaySound("QUESTLOGOPEN")
  elseif getn(SS.dbr.realm.rpReportList)>0 then
    local link = "|HSpamSentryRPTicket|h|cff8888ff["..L["here"].."]|r|h"
    SS:Msg(1, format(m, link))
    PlaySound("QUESTLOGOPEN")
  end
end

-- Called by the spam-button in the mailframe
function SS:ReportMail()
  local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(InboxFrame.openMailID)
  local msg = subject.."\n"..strsub(string.gsub(OpenMailBodyText:GetText() or "", "%s+", " "), 1, 300)
  self:Msg(0, format(L["%s has been added to the reportlist"], tostring(sender)))
  if sender then
    local offset = 0
    self:AddSpam(sender, msg, "mail")
  else
    self:Msg(0, L["Player already removed from game by a GM"])
  end
end

-----------------------------------
-----------------------------------
-- Queue functions

function SS:AddChatQueue(plr, msg, e, chn, id, hnd)
  tinsert(self.chatQueue,{name = plr,
                          message = msg,
                          time = GetTime(),
                          waiting = false,
                          queued = false,
                          done = false,
                          id = id,
                          channel = chn,
                          this = this,
                          event = e,
                          arg1 = arg1,
                          arg2 = arg2,
                          arg3 = arg3,
                          arg4 = arg4,
                          arg5 = arg5,
                          arg6 = arg6,
                          arg7 = arg7,
                          arg8 = arg8,
                          arg9 = arg9,
                          arg10= arg10,
                          arg11= arg11,
                          arg12= arg12,
                          handler = hnd,
                        })
  return getn(self.chatQueue)
end

function SS:CheckChatQueue()
  if getn(SS.chatQueue) > 0 then
    local t = GetTime() - 5
    local i = 1
    local stop = false
    repeat
      if SS.chatQueue[i].queued and SS.chatQueue[i].time < t and not SS.chatQueue[i].done then
        local plr = SS.chatQueue[i].name
        if not SS:InList(SS.characterBlackList, plr) then  -- Check blacklist.
          SS:CallOldChatEvent(i)
        end
        tremove(SS.chatQueue, i)
      else
        i = i + 1  
      end
      stop = i >= getn(SS.chatQueue)
    until stop
  end
end

function SS:FlushChatQueue()
  local num = getn(self.chatQueue)
  for i=1, num, 1 do
    local plr = self.chatQueue[1].args[4]
    if not self:InList(self.characterBlackList, plr) then  -- Check blacklist.
      self:CallOldChatEvent(1)
    end
    tremove(self.chatQueue, 1)
  end
end

function SS:ToggleChatQueue()
  if self.db.profile.enableDelay then
    self:ScheduleRepeatingEvent("SS_ChatQueue", SS.CheckChatQueue, 1)
  else
    self:CancelScheduledEvent("SS_ChatQueue")
    self:FlushChatQueue()
  end
end

local waiting, timesup, queued, done
-- Removes players from waitlist if they've been on it for more then 10 seconds
function SS:ChatQueueCooldown()
  local t = GetTime() - 10
  for i=1, getn(SS.chatQueue), 1 do
    waiting = SS.chatQueue[i].waiting
    timesup = SS.chatQueue[i].time < t
    queued = SS.chatQueue[i].queued
    done = SS.chatQueue[i].done
    if waiting and timesup and not (queued or done) then
      SS:ChatQueueProcessMessage(i)
    elseif not (waiting or queued or done) then
      -- Mark left-behind messages as garbage (just-in-case)
      SS.chatQueue[i].done = true
    end
  end
end

-- Process a message after a who result has been received or timed out
function SS:ChatQueueProcessMessage(index)
  local name = SS.chatQueue[index].name
  local msg = SS:GetChatHistory(name)
  local spam = SS:SpamCheck2(name, msg)
  if spam == 2 then
    SS.chatQueue[index].done = true
    self.knownList[name] = false
  elseif spam == 1 then
    SS:SpamFound(name, msg, SS.chatQueue[index].channel, SS.chatQueue[index].id)
    SS.chatQueue[index].done = true
    self.knownList[name] = false
  elseif spam == -1 then
    SS.chatQueue[index].queued = true
  elseif spam == -2 then
    SS:CallOldChatEvent(index)
  end
end

-- Garbage collection of chatqueue and message cache
function SS:CollectGarbage()
  -- Message cache
  if getn(SS.chatQueue) > 0 then
    local i = 1
    local stop = false
    repeat
      if SS.chatQueue[i].done then
        tremove(SS.chatQueue, i)
      else
        i = i + 1 
      end
      stop = i>= getn(SS.chatQueue)
    until stop
  end

  -- Spam / Ham cache
  if getn(SS.message) > 0 then
    local i = 1
    local t = GetTime() - 120
    repeat
      if SS.message[i].time < t then
        tremove(SS.message, i)
      else
        i = i + 1
      end
      stop = i>= getn(SS.message)
    until stop
  end

  -- ChatHistory: The last message is saved for 1 minute, additional messages for 30 seconds
  local t = GetTime()
  for i=1, getn(SS.chatHistory), 1 do
  -- Remove first message if older then 1 minutes
  if SS.chatHistory[i].time[1] < t - 60 then
      tremove(SS.chatHistory,i)
    else
    -- Remove all other messages if older then 30 seconds
      for j=2, getn(SS.chatHistory[i].time), 1 do
        if SS.chatHistory[i].time[j] < t - 30 then
          tremove(SS.chatHistory[i].message,j)
          tremove(SS.chatHistory[i].time,j)
          tremove(SS.chatHistory[i].channel,j)
        end
      end
    end
  end
  
end

-----------------------------------
-----------------------------------
-- Cache and history functions

function SS:UpdateGuildList()
  self.guildList = {}
  if GetGuildInfo("player") then
    for i=1,GetNumGuildMembers(true),1 do
      local name = GetGuildRosterInfo(i)
      tinsert(self.guildList, name)
    end
  end
end

function SS:UpdatePartyList()
  self.partyList = {}
  if UnitInRaid("player") then
    for i=1,GetNumRaidMembers(),1 do
      local name = GetRaidRosterInfo(i)
      tinsert(self.partyList, name)
    end
  else
    for i=1,GetNumPartyMembers(),1 do
      local name = UnitName("party"..tostring(i))
      tinsert(self.partyList, name)
    end
  end
end

function SS:UpdateFriendsList()
  self.friendsList = {}
  local numfriends = GetNumFriends()
  for i=1, numfriends, 1 do
    local name = GetFriendInfo(i)
    tinsert(self.friendsList, name)
  end
end

-- The chathistory keeps track of recently received messages from a player
function SS:AddChatHistory(plr, msg, chn)
  -- Insert new message
  if not self.chatHistory[plr] then
    self.chatHistory[plr] = { message = {}, time = {}, channel = {}}
  end
  if not (self.chatHistory[plr].message[1] == msg) then
    tinsert(self.chatHistory[plr].message, 1, msg)
    tinsert(self.chatHistory[plr].time, 1, t)
    tinsert(self.chatHistory[plr].channel, 1, chn)
  end
end

-- Returns the combined recent messages from this player
function SS:GetChatHistory(plr)
  local msg = ""
  if self.chatHistory[plr] then
    for i=1, getn(self.chatHistory[plr].message), 1 do
      msg = self.chatHistory[plr].message[i].." "..msg
    end
  end
  return msg
end

-----------------------------------
-----------------------------------
-- Ignore party invites from strangers
function SS:CheckPartyInvite(plr)
  if not self.db.profile.hidePartyInvite then return end
  if not (self:InList(self.friendsList, plr) or self:InList(self.guildList, plr) or self.knownList[plr]) then
    for i=1, STATICPOPUP_NUMDIALOGS do
      local f = getglobal("StaticPopup" .. i)
      if f:IsVisible() and f.which=="PARTY_INVITE" then 
        f:Hide()
        SS:Msg(0, L["Player unknown, party invite cancelled"])
      end
    end
  end
end

-----------------------------------
-----------------------------------
-- Ignore functions
-- These function assure that subsequent textballoons from spammers are suppressed
function SS:AddIgnore(plr, typ)
  if typ == L["say"] or typ == L["yell"] then
    if not self:InList(self.dbc.char.ignoreList, plr) then
      tinsert(self.dbc.char.ignoreList, plr)
      AddIgnore(plr)
    end
  end
end

function SS:ClearIgnore(num)
  if num==0 then
    num = getn(self.dbc.char.ignoreList)
  end
  for i=1,num,1 do
    local plr = self.dbc.char.ignoreList[1]
    if plr then
      DelIgnore(plr)
    end
    tremove(self.dbc.char.ignoreList,1)
  end
end

function SS:SupressIgnoreMsg(msg)
  if strfind(msg, ERR_IGNORE_NOT_FOUND) or strfind(msg, ERR_IGNORE_SELF) then return true end
  for i=1, getn(self.dbc.char.ignoreList), 1 do
    if strfind(msg, self.dbc.char.ignoreList[i]) then
      return true
    end
  end
  return false
end

-----------------------------------
-----------------------------------
-- Utility and other functions

-- Output message to the chatframe
-- Level can be either:
-- 0: System message
-- 1: Hourly notification
-- 2: Normal message
-- 3: Debug
function SS:Msg(level, text)
  if not text then return end
  local s = self.db.profile
  if level==0
  or level==1 and s.notifyHourly 
  or level==2 and s.notifyMessage
  or level==3 and s.notifyDebug then
    DEFAULT_CHAT_FRAME:AddMessage(text, 1, 0.6, 0.46)
  end
end

-- Returns the index of the item in the list, true/false for recursive lists
function SS:InList(list, item)
  if list and item then
    item = strlower(item)
    for i,v in pairs(list) do
      if type(v)=="table" then
        if self:InList(v, item) then
          return i
        end
      elseif type(v)=="string" and strlower(v)==item then 
        return i
      elseif v==item then
        return i
      end
    end
  end
  return false
end

-- Create a link to a playername
function SS:PlayerLink(link)
  local type = "player:"..link
  return "|H"..type.."|h|cffffff00["..link.."]|r|h"
end

-- Create a link to a SpamSentry message
function SS:MessageLink(link, entry)
  local type= "SpamSentryMsg:"
  return "|H"..type.."_"..entry.."|h|cff8888ff["..link.."]|r|h"
end

-- Functionality for calculating the server date
-- Offset is in days
function SS:GetServerDateTime()
  local serHour, serMinute = GetGameTime()
  local utcHour, utcMinute = tonumber(date("!%H")), tonumber(date("!%M"))
  local locHour, locMinute = tonumber(date("%H")), tonumber(date("%M"))
  local ser = serHour + serMinute / 60
  local loc = locHour + locMinute / 60
  local utc = utcHour + utcMinute / 60
  local lower, upper, locdate, utcdate, serdate
  locdate = time()
  
  -- Determine date-borders
  if utc > 12 then
    lower = 24 - utc
    upper = 24
  else
    lower = 0
    upper = utc
  end
  -- Determine utc-date
  if loc < lower then
    utcdate = locdate - 86400
  elseif loc > upper then
    utcdate = locdate + 86400
  else
    utcdate = locdate
  end
  -- Determine server-date 
  if ser < lower then
    serdate = utcdate + 86400
  elseif ser > upper then
    serdate = utcdate - 86400
  else
    serdate = utcdate
  end
  
  return date("%x", serdate)..format(" %02d:%02d", serHour, serMinute)
end

-- Show a dialog box with given text. Executes the given functions on accept/cancel.
function SS:ShowNotification(text, acceptText, acceptFunc, cancelText, cancelFunc)
  StaticPopupDialogs["SPAMSENTRY_NOTIFICATION"] = {
   text = text,
   button1 = acceptText,
   button2 = (type(cancelFunc)=="function") and cancelText or nil,
   OnAccept = acceptFunc,
   OnCancel = cancelFunc,
   timeout = 0,
   whileDead = 1,
   hideOnEscape = 1
  };
  StaticPopup_Show ("SPAMSENTRY_NOTIFICATION");
end

-- Functionality for versioning
function SS:CheckVersion()
  -- No reply-needed dialog
  if self.db.profile.version < 20070524 and self.db.profile.version > 0 then
    self:ShowNotification(
      format("|cffff0000SpamSentry|r|cffff9977 v%s|r|cffffffff\n\nYou are upgrading SpamSentry from an installation pre patch 2.1.\n\n To ensure that you won't experience errors you are advised to remove all SpamSentry folders, and then re-install the latest version.|r", SS.currentBuild),
      TEXT(OKAY),
      function() end
    )
    SS.dbr.realm.spamReportList = nil
  end

  if not self.db.profile.version == self.currentBuild then
    self:Msg(0, format(L["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."], "|cffffffff"..self.db.profile.version.."|r"))
  end
  self.db.profile.version = self.currentBuild
end
