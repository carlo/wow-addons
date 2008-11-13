--Traditional Chinese translate by 竹笙姬@暴風祭壇,http://tw.myblog.yahoo.com.tw/norova.tw

local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

L:RegisterTranslations("zhTW", function() return {
  -- Messages
  ["Blocked messages:"] = "被阻擋的訊息:",
  ["No blocked messages"] = "無被阻擋的訊息.",
  ["%s has been removed"] = "%s 已從清單移除.",
  ["Reportlist cleared (%s items)"] = "清空回報清單 (%s 件)",
  ["You already have a ticket pending"] = "你已經送出一份回報單",
  ["Nothing to report"] = "無資料可回報",
  ["Farming:"] = "外掛種田:",
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = "編輯回報單的內文",
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000注意: 在回報疑似玩家前請重覆確認他們的資料!|r",
  ["SSGUITICKETHELP"] = "Copy this text and paste it into your ticket.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "編輯回報單內文. '%s' 為你的ID參數,他會自動被你的ID所取代.",
  ["SSGUIHELP_FEEDBACK"] = "將結果複製下來, 並發送給此插件模組的作者.",
  ["[Items on reportlist: %s]"] = "[Items on reportlist: %s]",
  ["Message:"] = "Message:",

  --GUI tooltip
  ["Date / time"] = "Date / time",
  ["Channel"] = "Channel",
  ["Message-ID"] = "Message-ID",
  ["Click to copy message\n<CTRL>-Click to remove message"] = "Click to copy message\n<CTRL>-Click to remove message",
  
  -- No reply
  ["[NO REPLY NEEDED]"] = "[不需回覆]",
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_zhTW =  "敬愛的GM大人,\n\n下列疑似機器人程式, 他的移動看來起來很有規律且路徑固定, 特此向您回報!\n\n辛苦您了,謝謝!!\n\n%s\n---\n"
SPAMSENTRY_RPTEXT_zhTW =   "敬愛的GM,\n\n下列玩家的角色名稱已經違反了角色命名規則,請您對該玩家做適當的處置,謝謝!!\n\n辛苦了!\n\n%s\n---\n"
