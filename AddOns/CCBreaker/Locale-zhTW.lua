--翻譯：zhucc
    local L = AceLibrary("AceLocale-2.2"):new("CCBreaker")

    --[[
    Explanation:
            [spell] : name of the broken spell
            [target] : name of the target the spell was on
            [breaker] : name of the person removing the spell
            [ability] : name of the ability breaking the spell
    ]]--

    L:RegisterTranslations("zhTW", function() return {
            ["[spell] on [target] was removed by [breaker]"] = "[target]身上的[spell]因為[breaker]的行為而消失了",
            ["[spell] on [target] was removed by [breaker]'s [ability]"] = "[target]身上的[spell]因為[breaker]的[ability]而消失了",
            ["[spell] on [target] was removed"] = "[target]身上的[spell]消失了",
            ["ability"] = "破壞技能",
            ["breaker"] = "破壞者",
            ["broadcast as raidwarning"] = "以團隊警告的形式廣播",
            ["broadcast to party"] = "廣播到隊伍頻道",
            ["broadcast to raid"] = "廣播到團隊頻道",
            ["center"] = "錯誤提示訊息框",
            ["Change the displayed text, leave blank for default"] = "更改螢幕中間的文字，留空則使用預設文字",
            ["Chat options"] = "聊天頻道選項",
            ["chat"] = "頻道",
            ["Chose color to use"] = "選擇要使用的顏色",
            ["class"] = "職業",
            ["Color messages"] = "顏色訊息",
            ["color text"] = "顏色文字",
            ["color"] = "顏色",
            ["config"] = "打開配置窗口",
            ["console"] = "聊天窗口",
            ["debug"] = "除錯",
            ["Display ability breaking the CC"] = "顯示破壞了控制技能的技能",
            ["Display broken spell"] = "顯示被破壞了的技能",
            ["Display centered messages"] = "在螢幕中間顯示訊息",
            ["Display console messages"] = "在聊天窗口顯示訊息",
            ["Display freed target"] = "顯示曾被控制的那個目標",
            ["Display options for centered messages"] = "在錯誤提示訊息框中顯示提醒文字",
            ["Display options in console"] = "在聊天窗口裡顯示提醒文字",
            ["Display options in Fubar"] = "在FuBar提示窗口裡顯示",
            ["Display options"] = "有關訊息顯示的選項",
            ["Display who broke CC"] = "顯示是誰破壞了控制技能",
            ["display"] = "顯示",
            ["druid"] = "德魯伊",
            ["Enable debug messages"] = "啟用除錯訊息",
            ["enable"] = "啟用",
            ["Filter for classes"] = "職業過濾器",
            ["Filter for raid roles"] = "團隊角色過濾器",
            ["Filter for unit types"] = "單位類型過濾器",
            ["Filter Options"] = "過濾器選項",
            ["filter"] = "過濾器",
            ["four"] = "詳細訊息",
            ["fubar"] = "FuBar",
            ["hunter"] = "獵人",
            ["mage"] = "法師",
            ["mainassist"] = "主助理",
            ["maintank"] = "主坦克",
            ["Open config in a Waterall window"] = "在Waterfall窗口裡進行選項配置",
            ["others"] = "其他人",
            ["paladin"] = "聖騎士",
            ["party pet"] = "隊伍寵物",
            ["party"] = "隊伍",
            ["pet"] = "寵物",
            ["player"] = "自己",
            ["priest"] = "牧師",
            ["raid pet"] = "團隊寵物",
            ["raid"] = "團隊",
            ["raidwarning"] = "團隊警告",
            ["Report CC breaks from those only"] = "只報告來自於這些選定的人的破壞",
            ["Report CC breaks of effects"] = "只報告這些選定的法術效果",
            ["Report CC breaks to those targets only"] = "只報告對於這些目標的破壞",
            ["Reset breaker data"] = "重置所統計的數據",
            ["reset"] = "重置",
            ["Rightclick for options"] = "右鍵點擊打開選項選單",
            ["rogue"] = "盜賊",
            ["role"] = "角色",
            ["shaman"] = "薩滿",
            ["Show break from druids"] = "顯示來自德魯伊的破壞",
            ["Show break from hunters"] = "顯示來自獵人的破壞",
            ["Show break from mages"] = "顯示來自法師的破壞",
            ["Show break from mainassists"] = "顯示來自主助理的破壞",
            ["Show break from maintanks"] = "顯示來自主坦克的破壞",
            ["Show break from others"] = "顯示來自其他人的破壞",
            ["Show break from paladins"] = "顯示來自聖騎士的破壞",
            ["Show break from party members"] = "顯示來自隊伍成員的破壞",
            ["Show break from party pets"] = "顯示來自隊伍寵物的破壞",
            ["Show break from player"] = "顯示來自自己的破壞",
            ["Show break from priests"] = "顯示來自牧師的破壞",
            ["Show break from raid members"] = "顯示來自團隊成員的破壞",
            ["Show break from raid pets"] = "顯示來自團隊寵物的破壞",
            ["Show break from rogues"] = "顯示來自盜賊的破壞",
            ["Show break from shamans"] = "顯示來自薩滿的破壞",
            ["Show break from warlocks"] = "顯示來自術士的破壞",
            ["Show break from warriors"] = "顯示來自戰士的破壞",
            ["Show break from your pet"] = "顯示來自自己寵物的破壞",
            ["Show break of "] = "當該技能被破壞時顯示",
            ["Show break on druids"] = "當作用於德魯伊身上控制技能被破壞時顯示",
            ["Show break on hunters"] = "當作用於獵人身上控制技能被破壞時顯示",
            ["Show break on mages"] = "當作用於法師身上控制技能被破壞時顯示",
            ["Show break on mainassists"] = "當作用於主助理身上控制技能被破壞時顯示",
            ["Show break on maintanks"] = "當作用於主坦克身上控制技能被破壞時顯示",
            ["Show break on others"] = "當作用於其他人身上控制技能被破壞時顯示",
            ["Show break on paladins"] = "當作用於聖騎士身上控制技能被破壞時顯示",
            ["Show break on party members"] = "當作用於隊伍成員身上控制技能被破壞時顯示",
            ["Show break on party pets"] = "當作用於隊伍寵物身上控制技能被破壞時顯示",
            ["Show break on player"] = "當作用於自己身上控制技能被破壞時顯示",
            ["Show break on priests"] = "當作用於牧師身上控制技能被破壞時顯示",
            ["Show break on raid members"] = "當作用於團隊成員身上控制技能被破壞時顯示",
            ["Show break on raid pets"] = "當作用於團隊寵物身上控制技能被破壞時顯示",
            ["Show break on rogues"] = "當作用於盜賊身上控制技能被破壞時顯示",
            ["Show break on shamans"] = "當作用於薩滿身上控制技能被破壞時顯示",
            ["Show break on warlocks"] = "當作用於術士身上控制技能被破壞時顯示",
            ["Show break on warriors"] = "當作用於戰士身上控制技能被破壞時顯示",
            ["Show break on your pet"] = "當作用於自己寵物身上控制技能被破壞時顯示",
            ["show effects"] = "要顯示的效果",
            ["show from"] = "破壞者過濾",
            ["show on"] = "目標過濾",
            ["Slash-Commands"] = "命令",
            ["spell"] = "控制技能",
            ["target"] = "施放目標",
            ["text if only spell an target are given"] = "在只能得到“控制技能”以及“施放目標”訊息時使用的文字",
            ["text if only spell, target and breaker are given"] = "在只能得到“控制技能”、“施放目標”以及“破壞者”訊息時使用的文字",
            ["text if spell, target, breaker and ability are given"] = "在“控制技能”、“施放目標”、“破壞者”以及“破壞技能”訊息都有時使用的文字",
            ["text"] = "文字",
            ["three"] = "簡短訊息",
            ["two"] = "最短訊息",
            ["unit"] = "單位",
            ["warlock"] = "術士",
            ["warrior"] = "戰士",
    } end)