-----------------------------------
-----------------------------------
-- SpamSentry by Anea
-----------------------------------
-- compatibility.lua
-- Provides hacks to force compatibility with other addons
-- 2008-10-16: Disabled all hacks for further testing with patch 3.0
-----------------------------------
function SS:Compat_Enable()
  -- WIM
  if IsAddOnLoaded("WIM") then  
    if(WIM_CompareVersion("2.4.9") < 0) then  
--      self:Hook("WIM_MessageEventHandler", "Compat_WIM_MessageEventHandler", true)  
    end  
  end

  -- Cellular
  if IsAddOnLoaded("Cellular") then
--    self:Hook(Cellular, "CHAT_MSG_WHISPER", "Compat_Cellular_Whisper", true)
  end

  -- ForgottenChat
  if IsAddOnLoaded("ForgottenChatCC") then
--    self:Hook("FCCC_IncomingMessage", "Compat_FC_IncomingMessage", true)
  end
  
  -- Chatr
  if IsAddOnLoaded("Chatr") then
--    self:Hook("Chatr_Event", "Compat_Chatr_Event", true)
  end
  
  -- Whisp
  if IsAddOnLoaded("Whisp") then
--    self:Hook(Whisp, "ChatEventIncoming", "Compat_Whisp_ChatEventIncoming", true)
  end
  
  -- Chatter
  if IsAddOnLoaded("Chatter") and Chatter:GetModule("Highlights"):IsEnabled() then
--    self:Hook(Chatter:GetModule("Highlights"), "ParseChat", "Compat_ChatterHighlights_ParseChat", true)
  end
  
end

-----------------------------------
-----------------------------------
-- WIM
-- Tested with 2.4.9
function SS:Compat_WIM_MessageEventHandler(event)
  if(event == "CHAT_MSG_WHISPER") then  
    self:ChatFrame_MessageEventHandler(event, function() self.hooks.WIM_MessageEventHandler(event); end)  
  else  
    self.hooks.WIM_MessageEventHandler(event)  
  end 
end

-----------------------------------
-----------------------------------
-- Cellular
-- Tested with r27467
function SS:Compat_Cellular_Whisper()
  self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks[Cellular]["CHAT_MSG_WHISPER"](Cellular, event) end)
end

-----------------------------------
-----------------------------------
-- ForgottenChat
-- Tested with 3.1
function SS:Compat_FC_IncomingMessage()
  self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks.FCCC_IncomingMessage(arg2, arg1) end)
end

--
---------------------------------
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

-----------------------------------
-----------------------------------
-- Whisp
-- Tested with 20080411
function SS:Compat_Whisp_ChatEventIncoming()
  self:ChatFrame_MessageEventHandler("CHAT_MSG_WHISPER", function() self.hooks[Whisp]["ChatEventIncoming"](Whisp, arg1, arg2) end)
end

-----------------------------------
-----------------------------------
-- Chatter Highlights
-- Tested with r72849
function SS:Compat_ChatterHighlights_ParseChat(obj, event, msg, snd)
  self:ChatFrame_MessageEventHandler(event, function(event) self.hooks[Chatter:GetModule("Highlights")]["ParseChat"](Chatter:GetModule("Highlights"), event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11) end)
end
