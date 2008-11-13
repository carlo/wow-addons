--Traditional Chinese translate by 竹笙姬@暴風祭壇,http://tw.myblog.yahoo.com.tw/norova.tw

local L = AceLibrary("AceLocale-2.2"):new("SS_Bot")

L:RegisterTranslations("zhTW", function() return {
  -- Bot message
  ["%s has been added to the reportlist"] = "%s 已被加入待回報清單",
  ["Type a name or select a player to mark as bot"] = "選擇或輸入疑似外掛的玩家角色名稱.",
  ["Type a name or select the mob this bot is farming"] = "選擇或輸入疑似外掛玩家正在攻擊的怪物名稱.",
  ["farming:"] = "內容:",
  ["%s has been reported before"] = "%s 先前已回報過.",
  ["%s has been removed"] = "%s 已從清單移除",
  ["Reportlist cleared (%s items)"] = "清空回報清單 (%s 件)",
  ["Marked bots"] = "已標記的玩家",
  ["No marked bots"] = "無被標記資料",
} end )