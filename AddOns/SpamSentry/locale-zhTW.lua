--Traditional Chinese translate by 竹笙姬@暴風祭壇,http://tw.myblog.yahoo.com.tw/norova.tw

local L = AceLibrary("AceLocale-2.2"):new("SpamSentry")

L:RegisterTranslations("zhTW", function() return {
  -- Channel names
  ["whisper"] = "密語",
  ["say"] = "說",
  ["yell"] = "大喊",
  ["general"] = "綜合",
  ["trade"] = "交易",
  ["guildrecruitment"] = "公會招募",
  ["emote"] = "emote",
  ["lookingforgroup"] = "寻求组队",
  ["localdefense"] = "本地防务",

  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = "SpamSentry v%s Anea. 鍵入 |cffffffff/sentry|r 可設定選項.",
  
  -- Alerts
  ["%s has been added to the SpamSentry feedback list"] = "SpamSentry: %s 已被加入待回報清單",
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = "* 警告: %s 嘗試傳送給你 %s (%s). 待回報清單內含1名以上的玩家. 點擊 %s 向 GM 回報.",
  ["this message"] = "此訊息",
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = "待回報清單內含1名以上的玩家. 點擊 %s 向 GM 回報.",
  ["here"] = "這裡",
  ["Player already removed from game by a GM"] = "玩家已被 GM 從遊戲中移除.",
  ["No messages from %s in cache"] = "暫存資料中無 %s 相關訊息",
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = "|cffdd0000垃圾廣告|r",
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = "|cffdd0000垃圾訊息|r",
  ["Add the last message from this player to the SpamSentry reportlist"] = "將此玩家的訊息加入待回報清單.",
  ["|cffff8833Report Name|r"] = "|cffff8833不當名稱|r",
  ["Add this player to the SpamSentry naming violation reportlist"] = "將此玩家加入檢舉不當名稱回報清單",
 
  -- Tooltip
  ["Click to submit ticket"] = "點擊並送出回報單",
  ["on reportlist"] = "於待回報清單",
  ["total blocked"] = "全部已阻擋",

  -- Options:
  ["options"] = "選項",
  ["setup this mod to your needs"] = "你可以自由設定模組內容",
  ["FuBar options"] = "FuBar選項",
  ["set the FuBar options"] = "設定FuBar選項",

  -- Options: List
  ["bot"] = "檢舉疑似外掛",
  ["manage or add bots"] = "管理或增加疑似外掛玩家",
  ["spam"] = "檢舉垃圾訊息",
  ["manage blocked spam messages"] = "管理阻擋的垃圾訊息",
  ["naming"] = "檢舉不當名稱",
  ["manage or add players that violated naming rules"] = "管理或增加違反命名規則的玩家角色",
  ["add"] = "增加",
  ["add a character to the reportlist"] = "加入一名玩家至待回報清單",
  ["remove"] = "移除",
  ["removes the specified character from the list"] = "從清單上移除被選定的玩家",
  ["character"] = "玩家",
  ["clear"] = "清除",
  ["empties the report list"] = "清空待回報名單",
  ["list"] = "清單",
  ["lists all reported characters"] = "列出被回報的玩家",
  ["report"] = "回報",
  ["report the characters to a GM"] = "向 GM 回報",

  -- Options: Channels
  ["channel"] = "頻道",
  ["check the channels you want the addon to monitor"] = "確認你要使用的頻道",

  -- Options: Counters
  ["counters"] = "計數器",
  ["set which counters you would like to see on FuBar/Titan"] = "設定你想顯示在FuBar/Titan上的計數器形式",

  -- Options: Ticket texts    
  ["bottext"] = "bot(機器人)回報單",
  ["set the text for the bot ticket"] = "設定檢舉外掛回報單的內文",
  ["spamtext"] = "spam(不當訊息)回報單",
  ["set the text for the spam ticket"] = "設定檢舉垃圾訊息回報單的內文",
  ["naming text"] = "naming(命名規則)回報單",
  ["set the text for the naming ticket"] = "設定檢舉不當名稱回報單的內文",

  -- Options: Language
  ["language"] = "語言",
  ["set the language of the ticket text"] = "設定回報單內文所使用的語言",

  -- Options: Notification
  ["notification"] = "通知",
  ["set what notifications you would like to see"] = "設定你所想要看的通知文字",
  ["message"] = "訊息",
  ["show a warning when a message is blocked"] = "有訊息被擋下來時顯示警告",
  ["hourly"] = "每小時",
  ["show an hourly reminder when messages are waiting to be reported"] = "當有訊息等待回報時, 每小時提醒一次",
  ["debug"] = "debug",
  ["show debug messages"] = "顯示 debug 訊息",
  
  --Options: Delay
  ["delay"] = "延遲",
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = "遲延可疑的訊息, 防止重覆發文",
  
  -- Options: Autoclear reportlist
  ["autoclear"] = "自動清除",
  ["automatically clear the reportlist on login"] = "每次登入時自動清除回報清單",

  -- Options: Ignore party invites
  ["ignore party invite"] = "忽略邀請組隊",
  ["ignore party invites from people you don't know"] = "忽略不認識的玩家邀請你加入隊伍",
  ["Player unknown, party invite cancelled"] = "未知玩家,取消組隊邀請",
  --Options: Feedback
  ["feedback"] = "feedback",
  ["FEEDBACK_DESC"] = "當有訊息無法讓插件正確阻擋時, 使用此選項向作者發送報告訊息.",

  -- Options: Ignore by level
  ["ignore by level"] = "忽略等級",
  ["hide whispers from characters below the set level"] = "密語角色等級若等於設定值,將自動忽略",
  
  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = "[不需回覆]\n",

} end )

 function L:LocalisedBlackList()
  return {
    "ＷＷＷ．ＷＨＯＹＯ．ＣＯＭ．ＴＷ",
    "互友財富網",
    "代打服務",
    "代客練功套餐",
    "代 練",
  }
end
