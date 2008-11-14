-- zhTW localization by Hekylin.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Omen", "zhTW")
if not L then return end

-- Main Omen window
L["<Unknown>"] = "<未知的>"
L["Omen Quick Menu"] = "Omen快捷選單"
L["Use Focus Target"] = "使用Focus目標"
L["Test Mode"] = "測試模式"
L["Open Config"] = "開啟設定"
L["Open Omen's configuration panel"] = true
L["Hide Omen"] = "隱藏Omen"
L["Name"] = "名字"
L["Threat [%]"] = "仇恨 [%]"
L["Threat"] = "仇恨"
L["TPS"] = "TPS"
L["Toggle Focus"] = "鎖定Focus"
L["> Pull Aggro <"] = true

-- Warnings
L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."] = "|cffff0000Error:|r 如果您在登入後啟動過一次單位名牌, Omen將無法使用警報功能"
L["Passed %s%% of %s's threat!"] = "已超過「%2$s」的 %1$2.0f%% 仇恨值!"

-- Config module titles
L["General Settings"] = "綜合設定"
L["Profiles"] = true
L["Slash Command"] = true

-- Config strings, general settings section
L["OMEN_DESC"] = "Omen是一個占用少量系統資源的仇恨UI, 可以顯示你參與的戰鬥中怪物的仇恨表. 你可以改變Omen的外觀, 並且根據不同的角色儲存不同的設定."
L["Alpha"] = true
L["Controls the transparency of the main Omen window."] = "控制主視窗的透明度"
L["Scale"] = "縮放"
L["Controls the scaling of the main Omen window."] = "控制主視窗的尺寸"
L["Frame Strata"] = true
L["Controls the frame strata of the main Omen window. Default: MEDIUM"] = true
L["Clamp To Screen"] = true
L["Controls whether the main Omen window can be dragged offscreen"] = true
L["Tells Omen to additionally check your 'focus' and 'focustarget' before your 'target' and 'targettarget' in that order for threat display."] = true
L["Tells Omen to enter Test Mode so that you can configure Omen's display much more easily."] = true
L["Collapse to show a minimum number of bars"] = "收起以顯示最小數量的計量條"
L["Lock Omen"] = "鎖定Omen"
L["Locks Omen in place and prevents it from being dragged or resized."] = "鎖定Omen, 使其無法移動或拉伸."
L["Show minimap button"] = true
L["Show the Omen minimap button"] = true
L["Ignore Player Pets"] = true
L["IGNORE_PLAYER_PETS_DESC"] = [[
Tells Omen to skip enemy player pets when determining which unit to display threat data on.

Player pets maintain a threat table when in |cffffff78Aggressive|r or |cffffff78Defensive|r mode and behave just like normal mobs, attacking the target with the highest threat. If the pet is instructed to attack a specific target, the pet still maintains the threat table, but sticks on the assigned target which by definition has 100% threat. Player pets can be taunted to force them to attack you.

However, player pets on |cffffff78Passive|r mode do not have a threat table, and taunt does not work on them. They only attack their assigned target when instructed and do so without any threat table.

When a player pet is instructed to |cffffff78Follow|r, the pet's threat table is wiped immediately and stops attacking, although it may immediately reacquire a target based on its Aggressive/Defensive mode.
]]
L["Autocollapse"] = "自動收起"
L["Autocollapse Options"] = "自動收起設定"
L["Grow bars upwards"] = "計量條向上成長"
L["Hide Omen on 0 bars"] = "當長條棒數量為零時隱藏Omen"
L["Hide Omen entirely if it collapses to show 0 bars"] = "當Omen收起並長條棒數量為零時隱藏Omen"
L["Max bars to show"] = "長條棒的顯示數量"
L["Max number of bars to show"] = "長條棒的最大顯示數量"
L["Background Options"] = "背景設定"
L["Background Texture"] = "背景材質"
L["Texture to use for the frame's background"] = "框架背景的材質"
L["Border Texture"] = "邊緣材質"
L["Texture to use for the frame's border"] = "框架邊緣的材質"
L["Background Color"] = "背景顏色"
L["Frame's background color"] = "框架的背景顏色"
L["Border Color"] = "邊緣顏色"
L["Frame's border color"] = "框架的邊緣顏色"
L["Tile Background"] = "標題的背景"
L["Tile the background texture"] = "標題背景的材質"
L["Background Tile Size"] = "標題背景的尺寸"
L["The size used to tile the background texture"] = "標題背景材質的尺寸"
L["Border Thickness"] = "邊緣厚度"
L["The thickness of the border"] = "邊緣厚度"
L["Bar Inset"] = "嵌入長條棒"
L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"] = "仇恨長條棒顯示的內框與外框的距離"

-- Config strings, title bar section
L["Title Bar Settings"] = "標題條的設定"
L["Configure title bar settings."] = "設定標題條"
L["Show Title Bar"] = true
L["Show the Omen Title Bar"] = true
L["Title Bar Height"] = "標題條的高度"
L["Height of the title bar. The minimum height allowed is twice the background border thickness."] = "標題條厚度. 厚度的最小值是背景邊緣厚度的一倍"
L["Title Text Options"] = "標題設定"
L["The font that the title text will use"] = "標題字型"
L["The outline that the title text will use"] = "標題輪框"
L["The color of the title text"] = "標題演色"
L["Control the font size of the title text"] = "標題字體大小"

-- Config strings, show when... section
L["Show When..."] = "顯示時機"
L["Show Omen when..."] = "顯示Omen的時機"
L["This section controls when Omen is automatically shown or hidden."] = true
L["Use Auto Show/Hide"] = true
L["Show Omen when any of the following are true"] = "Omen會在以下條件中顯示"
L["You have a pet"] = "你有寵物"
L["Show Omen when you have a pet out"] = "在寵物存在時顯示Omen"
L["You are alone"] = "無組隊"
L["Show Omen when you are alone"] = "無組隊時顯示Omen"
L["You are in a party"] = "你在隊伍中"
L["Show Omen when you are in a 5-man party"] = "在5人隊伍中顯示Omen"
L["You are in a raid"] = "Raid中"
L["Show Omen when you are in a raid"] = "當在Raid中時顯示Omen"
L["However, hide Omen if any of the following are true (higher priority than the above)."] = true
L["You are resting"] = "你在測試"
L["Turning this on will cause Omen to hide whenever you are in a city or inn."] = true
L["You are in a battleground"] = "你在戰場中"
L["Turning this on will cause Omen to hide whenever you are in a battleground or arena."] = true
L["You are not in combat"] = true
L["Turning this on will cause Omen to hide whenever you are not in combat."] = "選擇此選項會在離開戰鬥後隱藏Omen"
L["AUTO_SHOW/HIDE_NOTE"] = "Note: If you manually toggle Omen to show or hide, it will remain shown or hidden regardless of Auto Show/Hide settings until you next zone, join or leave a party or raid, or change any Auto Show/Hide settings."

-- Config strings, show classes... section
L["Show Classes..."] = "顯示職業"
L["SHOW_CLASSES_DESC"] = "Omen將顯示以下職業的仇恨. 除非你點選'不在隊伍中'的選項, 不然Omen將只顯示你的隊伍中玩家"
L["Show bars for these classes"] = "顯示的職業"
L["DEATHKNIGHT"] = "死亡騎士"
L["DRUID"] = "德魯伊"
L["HUNTER"] = "獵人"
L["MAGE"] = "法師"
L["PALADIN"] = "騎士"
L["PET"] = "寵物"
L["PRIEST"] = "牧師"
L["ROGUE"] = "賊"
L["SHAMAN"] = "薩滿"
L["WARLOCK"] = "術士"
L["WARRIOR"] = "戰士"
L["*Not in Party*"] = "*不在隊伍中*"

-- Config strings, bar settings section
L["Bar Settings"] = "長條棒的設定"
L["Configure bar settings."] = "設定長條棒"
L["Animate Bars"] = "動畫長條棒"
L["Smoothly animate bar changes"] = "平滑動畫長條棒"
L["Short Numbers"] = "數字顯示簡化"
L["Display large numbers in Ks"] = "顯示比較大的數值時使用千進位(K)"
L["Bar Texture"] = "長條棒材質"
L["The texture that the bar will use"] = "長條棒使用的材質"
L["Bar Height"] = "長條棒高度"
L["Height of each bar"] = "長條棒的高度"
L["Bar Spacing"] = "長條棒間隔"
L["Spacing between each bar"] = "長條棒之間的間隔"
L["Show TPS"] = "顯示TPS"
L["Show threat per second values"] = "顯示每秒仇恨量"
L["TPS Window"] = "TP視窗"
L["TPS_WINDOW_DESC"] = "每秒仇恨量的計算是根據最後X秒視窗內的變化而決定的"
L["Show Threat Values"] = true
L["Show Threat %"] = true
L["Show Headings"] = "顯示上標題"
L["Show column headings"] = "顯示專欄的上標題"
L["Heading BG Color"] = "上標題的背景顏色"
L["Heading background color"] = "上標題的背景顏色"
L["Use 'My Bar' color"] = "使用'我的長條棒'顏色"
L["Use a different colored background for your threat bar in Omen"] = "Omen中自己的仇恨條背景使用不同顏色顯示"
L["'My Bar' BG Color"] = "我的長條棒的背景顏色"
L["The background color for your threat bar"] = "自己的仇恨條的背景顏色"
L["Use Tank Bar color"] = true
L["Use a different colored background for the tank's threat bar in Omen"] = true
L["Tank Bar Color"] = true
L["The background color for your tank's threat bar"] = true
L["Show Pull Aggro Bar"] = true
L["Show a bar for the amount of threat you will need to reach in order to pull aggro."] = true
L["Pull Aggro Bar Color"] = true
L["The background color for your Pull Aggro bar"] = true
L["Use Class Colors"] = true
L["Use standard class colors for the background color of threat bars"] = true
L["Pet Bar Color"] = true
L["The background color for pets"] = true
L["Bar BG Color"] = true
L["The background color for all threat bars"] = true
L["Always Show Self"] = true
L["Always show your threat bar on Omen (ignores class filter settings), showing your bar on the last row if necessary"] = true
L["Bar Label Options"] = "長條棒標籤選項"
L["Font"] = "字體"
L["The font that the labels will use"] = "標籤字體"
L["Font Size"] = "字體大小"
L["Control the font size of the labels"] = "標籤字體的大小"
L["Font Color"] = "字體顏色"
L["The color of the labels"] = "標籤的顏色"
L["Font Outline"] = "字體輪框"
L["The outline that the labels will use"] = "標籤輪框的選擇"
L["None"] = "無"
L["Outline"] = "輪框"
L["Thick Outline"] = "加倍高亮"

-- Config strings, slash command section
L["OMEN_SLASH_DESC"] = "這些按鈕跟斜線命令有相同效果 /omen"
L["Toggle Omen"] = "開關 Omen"
L["Center Omen"] = "Omen 居中"
L["Configure"] = "設定"
L["Open the configuration dialog"] = "打開 Omen 設定視窗"

-- Config strings, warning settings section
L["Warning Settings"] = "警報設定"
L["OMEN_WARNINGS_DESC"] = "這裡可以調整Omen在什麼時間和用怎樣的方式給你提出仇恨警告."
L["Enable Sound"] = "啟動聲音"
L["Causes Omen to play a chosen sound effect"] = "造成Omen播放所選擇的聲音"
L["Enable Screen Flash"] = "啟動屏幕閃動"
L["Causes the entire screen to flash red momentarily"] = "造成全銀幕紅色閃爍"
L["Enable Screen Shake"] = "啟動屏幕震動"
L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."] = "造成全銀幕震動. 此選項只有在不啟動單位名牌的時候有效果"
L["Enable Warning Message"] = "啟動警告訊息"
L["Print a message to screen when you accumulate too much threat"] = "當你仇恨過多時在屏幕上顯示警告字幕"
L["Warning Threshold %"] = "警告顯示的關口(%)"
L["Sound to play"] = "播放聲音"
L["Disable while tanking"] = "當坦怪時關閉警告"
L["DISABLE_WHILE_TANKING_DESC"] = "如果在防禦姿態, 熊型態, 正義之怒啟動時, 不顯示警告."
L["Test warnings"] = "測試警報"

-- Config strings, for Fubar
L["Click|r to toggle the Omen window"] = "點擊|r 打開/關閉 Omen 設定面板"
L["Right-click|r to open the options menu"] = "右鍵|r 打開設定選單"
L["FuBar Options"] = "FuBar 設定"
L["Attach to minimap"] = "依附到小地圖"
L["Hide minimap/FuBar icon"] = "隱藏小地圖/Fubar 小圖示"
L["Show icon"] = "顯示小圖示"
L["Show text"] = "顯示文字"
L["Position"] = "位置"
L["Left"] = "左邊"
L["Center"] = "居中"
L["Right"] = "右邊"

-- FAQ
L["Help File"] = "幫助文件"
L["A collection of help pages"] = "挑選過的幫助文件"
L["FAQ Part 1"] = true
L["FAQ Part 2"] = true
L["Frequently Asked Questions"] = "FAQ"
L["Warrior"] = "戰士"

L["GENERAL_FAQ"] = [[
|cffffd200Omen3跟Omen2的差別|r

Omen3依賴Blizzard所給的仇恨API. 跟Omen2不一樣, Omen3不會去推測或者計算仇恨. 仇恨值是通過API直接向服務器索取.

Omen2使用仇恨2.0Library. 這個Library是根據偵測戰鬥紀錄, 法術, Buff, Debuff, 姿態跟裝備來計算不同的仇恨值. 仇恨的計算是根據現有的資料跟觀測資料所得到的數據計算的. 很多技能是假設值, 無法驗證的(比如擊退, 我們假設是50%降仇恨).

仇恨2.0Library也包含了在其他人都用這個Library的時候同步整個Raid的仇恨值. 這些仇恨數據用來提供給整個Raid.

3.0.2開始. Omen將不再做這些動作, 仇恨Library也不需要了. Omen3使用Blizzard內建仇恨監視器, 並從其索取仇恨資料. 這也造成Omen不在需要同步資料, 偵測戰鬥紀錄或者猜測數據了. 效能會因為減少資料傳送而提升. 包括CPU跟Memory的使用量都會減少. 針對特殊Boss的仇恨變化事件也不再需要.

更進一步的受益包括了一些NPC的仇恨. 比如SW1的人形NPC坦王的仇恨. 但是也是有一些不利的地方. 仇恨數據更新速度變慢了, Raid中如果沒有人的目標是那個NPC的話, 他的仇恨將無法得到. 而你沒有直接參與的戰鬥你也無法得到仇恨(你如果沒有造成任何傷害或者製造任何仇恨你無法得到仇恨值, 就算你讓你的寵物去打而你沒有攻擊也一樣不能拿到仇恨值). 

|cffffd200How do I get rid of the 2 vertical gray lines down the middle?|r

Lock your Omen. Locking Omen will prevent it from being moved or resized, as well as prevent the columns from being resized. If you haven't realized it, the 2 vertical gray lines are column resizing handles.

|cffffd200怎樣將Omen3的外觀改成跟Omen2類似?|r

改變背景材質跟邊緣材質, 將背景顏色改成黑色, 邊緣顏色改成藍色.

|cffffd200為什麼就算我在戰鬥中也看不到任何仇恨值?|r

除非你對怪有做出任何傷害或者造成任何仇恨, 不然Blizzard仇恨API不會給任何仇恨值. 我們猜測這可能是Blizzard為了減少網路資料傳送. 

|cffffd200Is there ANY way around this Blizzard limitation? Not being able to see my pet's threat before I attack has set me back to guessing.|r

There is no way around this limitation short of us doing the guessing for you (which is exactly how Omen2 did it).

The goal of Omen3 is to provide accurate threat data, we no longer intend to guess for you and in the process lower your FPS. Have some confidence in your pet/tank, or just wait 2 seconds before attacking and use a low damage spell such as Ice Lance so that you can get initial threat readings.
]]
L["GENERAL_FAQ2"] = [[
|cffffd200Can we get AoE mode back?|r

Again, this is not really possible without guessing threat values. Blizzard's threat API only allows us to query for threat data on units that somebody in the raid is targetting. This means that if there are 20 mobs and only 6 of them are targetted by the raid, there is no way to obtain accurate threat data on the other 14.

This is also extremely complicated to guess particularly for healing and buffing (threat gets divided by the number of mobs you are in combat with) because mobs that are under crowd control effects (sheep, banish, sap, etc) do not have their threat table modified and addons cannot reliably tell how many mobs you are in combat with. Omen2's guess was almost always wrong.

|cffffd200The tooltips on unit mouseover shows a threat % that does not match the threat % reported by Omen3. Why?|r

Blizzard's threat percentage is scaled to between 0% and 100%, so that you will always pull aggro at 100%. Omen reports the raw unscaled values which has pulling aggro percentages at 110% while in melee range and 130% otherwise.

By universal agreement, the primary target of a mob is called the tank and is defined to be at 100% threat.

|cffffd200Omen3有同步資料或者分析戰鬥資料麼?|r

Omen不需要同步資料或者分析戰鬥資料. 現階段沒有任何比要去這樣做.

|cffffd200仇恨資料更新太慢...|r

Omen3仇恨更新速度跟Blizzard提供仇恨數據給我們的速度是一樣的.

In fact, Blizzard updates them about once per second, which is much faster than what Omen2 used to sync updates. In Omen2, you only transmitted your threat to the rest of the raid once every 3 seconds (or 1.5s if you were a tank).

|cffffd200我要去那裏回報Bug或者提出建議?|r

http://forums.wowace.com/showthread.php?t=14249

|cffffd200誰製作了Omen3?|r

Xinhuan (Blackrock US Alliance) did.

|cffffd200Do you accept Paypal donations?|r

Yes, send to xinhuan AT gmail DOT com.
]]
L["WARRIOR_FAQ"] = [[The following data is obtained from |cffffd200http://www.tankspot.com/forums/f200/39775-wow-3-0-threat-values.html|r on 2nd Oct 2008 (credits to Satrina). The numbers are for a level 80.

|cffffd200Modifiers|r
Battle Stance ________ x 80
Berserker Stance _____ x 80
Tactical Mastery _____ x 121/142/163
Defensive Stance _____ x 207.35

Note that in our original threat estimations (that we use now in WoW 2.0), we equated 1 damage to 1 threat, and used 1.495 to represent the stance+defiance multiplier. We see that Blizzard's method is to use the multiplier without decimals, so in 2.x it would've been x149 (maybe x149.5); it is x207 (maybe 207.3) in 3.0. I expect that this is to allow the transport of integer values instead of decimal values across the Internet for efficiency. It appears that threat values are multiplied by 207.35 at the server, then rounded.

If you still want to use the 1 damage = 1 threat method, the stance modifiers are 0.8 and 2.0735, etc.

|cffffd200Threat Values  (stance modifiers apply unless otherwise noted):|r
Battle Shout _________ 78 (split)
Cleave _______________ damage + 225 (split)
Commanding Shout _____ 80 (split)
Concussion Blow ______ damage only
Damage Shield ________ damage only
Demoralising Shout ___ 63 (split)
Devastate ____________ damage + 5% of AP *** Needs re-checking for 8982 **
Dodge/Parry/Block_____ 1 (in defensive stance with Improved Defensive Stance only)
Heroic Strike ________ damage + 259
Heroic Throw _________ 1.50 x damage
Rage Gain ____________ 5 (stance modifier is not applied)
Rend _________________ damage only
Revenge ______________ damage + 121
Shield Bash __________ 36
Shield Slam __________ damage + 770
Shockwave ____________ damage only
Slam _________________ damage + 140
Spell Reflect ________ damage only (only for spells aimed at you)
Social Aggro _________ 0
Sunder Armour ________ 345 + 5%AP
Thunder Clap _________ 1.85 x damage
Vigilance ____________ 10% of target's generated threat (stance modifier is not applied)

如果你同過加強反彈魔法天賦幫助隊友反彈魔法, 你不會得到任何仇恨值. 相對的如果你通過那個天賦幫助隊有反彈魔法, 這個仇恨會計算到隊友身上.
]]

