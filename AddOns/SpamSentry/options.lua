-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- options.lua
-- Commandline and FuBar options
-----------------------------------

local L = AceLibrary("AceLocale-2.2"):new("SpamSentry")

-- generic options
local options = {
  type = "group",
  name = L["options"],
  desc = L["setup this mod to your needs"],
  order = 4,
  args = {
    channels = {
      type = "group",
      order = 1,
      name = L["channel"],
      desc = L["check the channels you want the addon to monitor"],
      args = {
        whisper = {
          type = "toggle",
          name = L["whisper"],
          desc = L["whisper"],
          get = function() return SS.db.profile.channelList[L["whisper"]] end,
          set = function(v) SS.db.profile.channelList[L["whisper"]] = v end,
          order = 1,
        },
        say = {
          type = "toggle",
          name = L["say"],
          desc = L["say"],
          get = function() return SS.db.profile.channelList[L["say"]] end,
          set = function(v) SS.db.profile.channelList[L["say"]] = v end,
          order = 2,
        },
        yell = {
          type = "toggle",
          name = L["yell"],
          desc = L["yell"],
          get = function() return SS.db.profile.channelList[L["yell"]] end,
          set = function(v) SS.db.profile.channelList[L["yell"]] = v end,
          order = 3,
        },  
        general = {
          type = "toggle",
          name = L["general"],
          desc = L["general"],
          get = function() return SS.db.profile.channelList[L["general"]] end,
          set = function(v) SS.db.profile.channelList[L["general"]] = v end ,
          order = 4,
        },
        trade = {
          type = "toggle",
          name = L["trade"],
          desc = L["trade"],
          get = function() return SS.db.profile.channelList[L["trade"]] end,
          set = function(v) SS.db.profile.channelList[L["trade"]] = v end,
          order = 5,
        },
        recruit = {
          type = "toggle",
          name = L["guildrecruitment"],
          desc = L["guildrecruitment"],
          get = function() return SS.db.profile.channelList[L["guildrecruitment"]] end,
          set = function(v) SS.db.profile.channelList[L["guildrecruitment"]] = v end,
          order = 6,
        },
      },
    },
    notification = {
      type = "group",
      name = L["notification"],
      desc = L["set what notifications you would like to see"],
      order = 2,
      args = {
        message = {
          type = "toggle",
          name = L["message"],
          desc = L["show a warning when a message is blocked"],
          order = 2,
          set = function(v) SS.db.profile.notifyMessage = v end,
          get = function() return SS.db.profile.notifyMessage end,
        },
        hourly = {
          type = "toggle",
          name = L["hourly"],
          desc = L["show an hourly reminder when messages are waiting to be reported"],
          order = 3,
          set = function(v) SS.db.profile.notifyHourly = v end,
          get = function() return SS.db.profile.notifyHourly end,
        },
        debug = {
          type = "toggle",
          name = L["debug"],
          desc = L["show debug messages"],
          order = 5,
          set = function(v) SS.db.profile.notifyDebug = v end,
          get = function() return SS.db.profile.notifyDebug end,
        },
      },
    },
    counters = {
      type = "group",
      name = L["counters"],
      desc = L["set which counters you would like to see on FuBar/Titan"],
      order = 3,
      args = {
        cspam = {
          type = "toggle",
          name = L["spam"],
          desc = L["spam"],
          order = 1,
          set = function(v) 
            SS.db.profile.showSpamCounter = v
            SS:OnTextUpdate()
          end,
          get = function() return SS.db.profile.showSpamCounter end,
        },
        cbot = {
          type = "toggle",
          name = L["bot"],
          desc = L["bot"],
          order = 2,
          set = function(v) 
            SS.db.profile.showBotCounter = v
            SS:OnTextUpdate()
          end,
          get = function() return SS.db.profile.showBotCounter end,
        },
        cnaming = {
          type = "toggle",
          name = L["naming"],
          desc = L["naming"],
          order = 3,
          set = function(v) 
            SS.db.profile.showRPCounter = v
            SS:OnTextUpdate()
          end,
          get = function() return SS.db.profile.showRPCounter end,
        },
      },
    },
    spacer1 = {
      type = "header",
      order = 10,
    },
    language = {
      type = "group",
      name = L["language"],
      desc = L["set the language of the ticket text"],
      order = 11,
      args = {
        enUS = {
          type = "toggle",
          name = "enUS",
          desc = "English",
          isRadio = true,
          set = function() 
            SS.dbr.realm.reportLanguage="enUS" 
            SS:Load("report") 
            SS_Report:ResetTicketText() 
          end,
          get = function() return SS.dbr.realm.reportLanguage=="enUS" end,
        },
        deDE = {
          type = "toggle",
          name = "deDE",
          desc = "Deutsch",
          isRadio = true,
          set = function() 
            SS.dbr.realm.reportLanguage="deDE" 
            SS:Load("report") 
            SS_Report:ResetTicketText() 
          end,
          get = function() return SS.dbr.realm.reportLanguage=="deDE" end,
        },
        frFR = {
          type = "toggle",
          name = "frFR",
          desc = "Francais",
          isRadio = true,
          set = function() 
            SS.dbr.realm.reportLanguage="frFR" 
            SS:Load("report") 
            SS_Report:ResetTicketText() 
          end,
          get = function() return SS.dbr.realm.reportLanguage=="frFR" end,
        },
        esES = {
          type = "toggle",
          name = "esES",
          desc = "Espanol",
          isRadio = true,
          set = function() 
            SS.dbr.realm.reportLanguage="esES" 
            SS:Load("report") 
            SS_Report:ResetTicketText() 
          end,
          get = function() return SS.dbr.realm.reportLanguage=="esES" end,
        },
        zhTW = {
          type = "toggle",
          name = "zhTW",
          desc = "Chinese",
          isRadio = true,
          set = function() 
            SS.dbr.realm.reportLanguage="zhTW" 
            SS:Load("report") 
            SS_Report:ResetTicketText() 
          end,
          get = function() return SS.dbr.realm.reportLanguage=="zhTW" end,
        },
      },
    },
    bottext = {
      type = "execute",
      name = L["bottext"],
      desc = L["set the text for the bot ticket"],
      order = 13,
      func = function()
        SS:Load("report")
        SS_Report:ShowGUI("editbot")
      end,
    },    
    rptext = {
      type = "execute",
      name = L["naming text"],
      desc = L["set the text for the naming ticket"],
      order = 14,
      func = function() 
        SS:Load("report") 
        SS_Report:ShowGUI("editrp") 
      end,
    },
    spacer2 = {
      type = "header",
      order = 20,
    },
    ignorebylevel = {
      type = "range",
      order = 21,
      name = L["ignore by level"],
      desc = L["hide whispers from characters below the set level"],
      min = 1,
      max = 71,
      step = 1,
      set = function(v) SS.db.profile.minimumLevel=v end,
      get = function() return SS.db.profile.minimumLevel end,
    },
    delay = {
      type = "toggle",
      name = L["delay"],
      desc = L["toggle the delaying of suspicious messages, to stop multi-message spams from showing"],
      order = 22,
      set = function(v) 
        SS:Load("report") 
        SS.db.profile.enableDelay=v 
        SS:ToggleChatQueue() 
      end,
      get = function() return SS.db.profile.enableDelay end,
    },      
    ignoreinvite = {
      type = "toggle",
      name = L["ignore party invite"],
      desc = L["ignore party invites from people you don't know"],
      order = 22,
      set = function(v) SS.db.profile.hidePartyInvite=v end,
      get = function() return SS.db.profile.hidePartyInvite end,
    },      
  },
}
  
-- fubar commands
SS.fucommands = {
  type = "group",
  args = {
    spam = {
      type = "group",
      name = L["spam"],
      desc = L["manage blocked spam messages"],
      order = 1,
      args = {},
    },
    bot = {
      type = "group",
      name = L["bot"],
      desc = L["manage or add bots"],
      order = 2,
      args = {},
    },
    rp = {
      type = "group",
      name = L["naming"],
      desc = L["manage or add players that violated naming rules"],
      order = 2,
      args = {},
    },
    spacer = {
      type = "header",
      order = 4,
    },
    options = {},
    fuoptions = {
      type = "group",
      name = L["FuBar options"],
      desc = L["set the FuBar options"],
      order = 10,
      args = {}
    },
  },
}

-- slash commands
SS.slashcommands = {
  type = "group",
  args = {
    spam = {
      type = "group",
      name = L["spam"],
      desc = L["manage blocked spam messages"],
      order = 1,
      args = {
        list = {
          type = "execute",
          name = L["list"],
          desc = L["lists all reported characters"],
          order = 1,
          func = function() 
            SS:Load("report") 
            SS_Report:ListSpam() 
          end,
        },
        remove = {
          type = "text",
          name = L["remove"],
          desc = L["removes the specified character from the list"],
          usage = "<"..L["character"]..">",
          order = 2,
          get = false,
          set = function(v) 
            SS:Load("report") 
            SS_Report:RemoveSpam(v, true) 
          end,
          validate = function(v) return SS:InList(SS.spamReportList, v) end,
        },
        clear = {
          type = "execute",
          name = L["clear"],
          desc = L["empties the report list"],
          order = 3,
          func = function() 
            SS:Load("report") 
            SS_Report:ClearSpam(0, true) 
          end,
        },
        report = {
          type = "execute",
          name = L["report"],
          desc = L["report the characters to a GM"],
          order = 4,
          func = function() 
            SS:Load("report") 
            SS_Report:ShowGUI("spam") 
          end,
        },
        feedback = {
          type = "execute",
          name = L["feedback"],
          desc = L["FEEDBACK_DESC"],
          order = 5,
          func = function(v) 
            SS:Load("report")
            SS_Report:ShowGUI("feedback") 
          end,
        },      
      },
    },
    bot = {
      type = "group",
      name = L["bot"],
      desc = L["manage or add bots"],
      order = 2,
      args = {
        add = {
          type = "execute",
          name = L["add"],
          desc = L["add a character to the reportlist"],
          order = 1,
          func = function() 
            SS:Load("bot") 
            SS_Bot:Mark() 
          end,
        },
        list = {
          type = "execute",
          name = L["list"],
          desc = L["lists all reported characters"],
          order = 2,
          func = function() 
            SS:Load("bot") 
            SS_Bot:List() 
          end,
        },
        remove = {
          type = "text",
          name = L["remove"],
          desc = L["removes the specified character from the list"],
          usage = "<"..L["character"]..">",
          order = 3,
          get = false,
          set = function(v) 
            SS:Load("bot") 
            SS_Bot:Remove(v, true) 
          end,
          validate = function(v) return SS:InList(SS.dbr.realm.botReportList, v) end,
        },
        clear = {
          type = "execute",
          name = L["clear"],
          desc = L["empties the report list"],
          order = 4,
          func = function() 
            SS:Load("bot") 
            SS_Bot:Clear(0, true) 
          end,
        },
        report = {
          type = "execute",
          name = L["report"],
          desc = L["report the characters to a GM"],
          order = 5,
          func = function() 
            SS:Load("report") 
            SS_Report:ShowGUI("bot") 
          end,
        },
      },
    },
    rp = {
      type = "group",
      name = L["naming"],
      desc = L["manage or add players that violated naming rules"],
      order = 3,
      args = {
        add = {
          type = "execute",
          name = L["add"],
          desc = L["add a character to the reportlist"],
          order = 1,
          func = function() 
            SS:Load("rp") 
            SS_RP:Mark() 
          end,
        },
        list = {
          type = "execute",
          name = L["list"],
          desc = L["lists all reported characters"],
          order = 2,
          func = function() 
            SS:Load("rp") 
            SS_RP:List() 
          end,
        },
        remove = {
          type = "text",
          name = L["remove"],
          desc = L["removes the specified character from the list"],
          usage = "<"..L["character"]..">",
          order = 3,
          get = false,
          set = function(v) 
            SS:Load("rp") 
            SS_RP:Remove(v, true) 
          end,
          validate = function(v) return SS:InList(SS.dbr.realm.botReportList, v) end,
        },
        clear = {
          type = "execute",
          name = L["clear"],
          desc = L["empties the report list"],
          order = 4,
          func = function() 
            SS:Load("rp") 
            SS_RP:Clear(0, true) 
          end,
        },
        report = {
          type = "execute",
          name = L["report"],
          desc = L["report the characters to a GM"],
          order = 5,
          func = function() 
            SS:Load("report") 
            SS_RP:ShowGUI("rp") 
          end,
        },
      },
    },

  },
}
  
-- Setup fubar
SS.title = "SpamSentry"
SS.hasIcon = true
SS.hideWithoutStandby = true
SS.independentProfile = false

-- fubar selected listitems
SS.reportIndex = {}

function SS:SetupOptions()
  -- Setup menu entries
  SS.slashcommands.args.options =  options
  self:RegisterChatCommand({"/spamsentry","/sentry"}, SS.slashcommands)
  
  SS.fucommands.args.options =  options
  --self.OnMenuRequest = SS.fucommands
  self.overrideMenu = true

  -- Register list updates  
  self:RegisterEvent("SPAMSENTRY_REPORTLIST_UPDATED", "OnDataUpdate")
  self:TriggerEvent("SPAMSENTRY_REPORTLIST_UPDATED")
end

-- Create menu dynamically to avoid default fubar-options
local dewdrop = AceLibrary("Dewdrop-2.0")
function SS:OnMenuRequest(level, value, inTooltip, v1, v2, v3)
  dewdrop:FeedAceOptionsTable(SS.fucommands)
  
  if value=="fuoptions" or v1=="fuoptions" or v2=="fuoptions" or v3=="fuoptions" then
    self:AddImpliedMenuOptions(2)
  end
end

-----------------------------------
-----------------------------------
-- Input functions

function SS:OnClick(button)
  SS:Load("report")
  if getn(self.spamReportList)>0 then
    SS_Report:ShowGUI("spam")
  elseif getn(self.dbr.realm.botReportList)>0 then
    SS_Report:ShowGUI("bot")
  elseif getn(self.dbr.realm.rpReportList)>0 then
    SS_Report:ShowGUI("rp")
  else
    SS_Report:ShowGUI("spam")
  end
end

-----------------------------------
-----------------------------------
-- Update functions

function SS:OnDataUpdate()
  -- cat, list, addfunc, removefunc, clearfunc
  self.fucommands.args.spam.args = self:GenerateOptionsList(
    "spam", 
    self.spamReportList,
    nil,
    function() SS:Load("report") SS_Report:RemoveSpam(SS.reportIndex["spam"], true) end,
    function() SS:Load("report") SS_Report:ClearSpam(0, true) end
  )
  self.fucommands.args.bot.args = self:GenerateOptionsList(
    "bot", 
    self.dbr.realm.botReportList,
    function() SS:Load("bot") SS_Bot:Mark() end,
    function() SS:Load("bot") SS_Bot:Remove(SS.reportIndex["bot"], true) end,
    function() SS:Load("bot") SS_Bot:Clear(0, true) end
  )
  self.fucommands.args.rp.args = self:GenerateOptionsList(
    "rp", 
    self.dbr.realm.rpReportList,
    function() SS:Load("rp") SS_RP:Mark() end,
    function() SS:Load("rp") SS_RP:Remove(SS.reportIndex["rp"], true) end,
    function() SS:Load("rp") SS_RP:Clear(0, true) end
  )
  self:OnTextUpdate()
end

function SS:OnTextUpdate()
  local numspam,numbot,numrp = 0,0,0
  numspam = getn(self.spamReportList)
  numbot = getn(SS.dbr.realm.botReportList)
  numrp = getn(SS.dbr.realm.rpReportList)
  
  local text1, text2, text3 = "", "", ""
  if SS.db.profile.showSpamCounter then text1 = string.format("S:|cffffffff%d|r ", numspam) end
  if SS.db.profile.showBotCounter then text2 = string.format("B:|cffffffff%d|r ", numbot) end
  if SS.db.profile.showRPCounter then text3 = string.format("N:|cffffffff%d|r", numrp) end
  
  self:SetText(text1..text2..text3)
end

local tablet = AceLibrary("Tablet-2.0")
function SS:OnTooltipUpdate()
    local numspam = getn(self.spamReportList)
    local numbot = getn(self.dbr.realm.botReportList)
    local numrp = getn(self.dbr.realm.rpReportList)

    local cat = tablet:AddCategory(
        'text', L["spam"],
        'columns', 2,
        'child_textR', 1,
        'child_textG', 1,
        'child_textB', 0,
        'child_textR2', 1,
        'child_textG2', 1,
        'child_textB2', 1
    )
    cat:AddLine(
        'text', L["total blocked"],
        'text2', self.db.profile.totalBlocked
    )
    cat:AddLine(
        'text', L["on reportlist"],
        'text2', numspam
    )
    
    cat = tablet:AddCategory(
        'text', L["bot"],
        'columns', 2,
        'child_textR', 1,
        'child_textG', 1,
        'child_textB', 0,
        'child_textR2', 1,
        'child_textG2', 1,
        'child_textB2', 1
    )
    cat:AddLine(
        'text', L["on reportlist"],
        'text2', numbot
    )

    cat = tablet:AddCategory(
        'text', L["naming"],
        'columns', 2,
        'child_textR', 1,
        'child_textG', 1,
        'child_textB', 0,
        'child_textR2', 1,
        'child_textG2', 1,
        'child_textB2', 1
    )
    cat:AddLine(
        'text', L["on reportlist"],
        'text2', numrp
    )
    
    tablet:SetHint(L["Click to submit ticket"])
end

-- Builts a reportlist and options to manage the list
function SS:GenerateOptionsList(cat, list, addfunc, removefunc, clearfunc)
  local ret = {}
  local l = list
  local num = getn(l)
  for i=1, num, 1 do
    local character = l[i].player
    local message = l[i].summary or "n/a"
    tinsert(ret, {
      type = "toggle",
      name = character,
      desc = message,
      isRadio = true,
      order = i,
      set = function(v) SS.reportIndex[cat]=tostring(character) end,
      get = function() return SS.reportIndex[cat]==character end,
    })
  end
  tinsert(ret, {
    type = "header",
    order = 100,
  })
  tinsert(ret, {
    type = "execute",
    name = L["report"],
    desc = L["report the characters to a GM"],
    order = 101,
    func = function() 
      SS:Load("report") 
      SS_Report:ShowGUI(cat) 
    end,
  })
  if cat ~= "spam" then
    tinsert(ret, {
      type = "execute",
      name = L["add"],
      desc = L["add a character to the reportlist"],
      order = 102,
      func = addfunc,
    })
  end
  tinsert(ret, {
    type = "execute",
    name = L["remove"],
    desc = L["removes the specified character from the list"],
    order = 103, 
    func = removefunc,
  })
  tinsert(ret, {
    type = "execute",
    name = L["clear"],
    desc = L["empties the report list"],
    order = 104,
    func = clearfunc,
  })
  return ret
end
