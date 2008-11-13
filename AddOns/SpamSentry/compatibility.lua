-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- compatibility.lua
-- Provides hacks to force compatibility with other addons
-----------------------------------

function SS:Compat_Enable()
  -- WIM
  if IsAddOnLoaded("WIM") then
    self:Hook("WIM_PostMessage", "Compat_WIM_PostMessage", true)
  end
  
  -- Cellular
  if IsAddOnLoaded("Cellular") then
    self:Hook(Cellular, "CHAT_MSG_WHISPER", "Compat_Cellular_Whisper", true)
  end

  -- ForgottenChat
  if IsAddOnLoaded("ForgottenChatCC") then
    self:Hook("FCCC_IncomingMessage", "Compat_FC_IncomingMessage", true)
  end
  
  -- Chatr
  if IsAddOnLoaded("Chatr") then
    self:Hook("Chatr_Event", "Compat_Chatr_Event", true)
  end
end

-----------------------------------
-----------------------------------
-- WIM
-- Tested with 2.0.9
function SS:Compat_WIM_PostMessage(user, msg, ttype, from, raw_msg)
  if ttype==1 then
    self:ChatFrame_MessageEventHandler(event, function() self.hooks.WIM_PostMessage(arg2, msg, 1, arg2, arg1) end)
  else
    self.hooks.WIM_PostMessage(user, msg, ttype, from, raw_msg)
  end
end

-----------------------------------
-----------------------------------
-- Cellular
-- Tested with r27467
function SS:Compat_Cellular_Whisper()
  self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks[Cellular].CHAT_MSG_WHISPER(Cellular, event) end)
end

-----------------------------------
-----------------------------------
-- ForgottenChat
-- Tested with 3.1
function SS:Compat_FC_IncomingMessage()
  self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks.FCCC_IncomingMessage(arg2, arg1) end)
end

-----------------------------------
-----------------------------------
-- Chatr
-- Tested with 0.3.9.4.5 Beta
function SS:Compat_Chatr_Event()
  if event == "CHAT_MSG_WHISPER" then
    self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks.Chatr_Event() end)
  else
    self.hooks.Chatr_Event()
  end
end