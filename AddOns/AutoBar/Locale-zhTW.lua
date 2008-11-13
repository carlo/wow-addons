--
-- AutoBar
-- http://code.google.com/p/autobar/
-- Various Artists
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("zhTW", function() return {
		["AUTOBAR"] = "AutoBar",
		["CONFIG_WINDOW"] = "設定視窗",
		["SLASHCMD_LONG"] = "/autobar",
		["SLASHCMD_SHORT"] = "/atb",
		["BUTTON"] = "按鈕",
		["EDITSLOT"] = "編輯欄位",
		["VIEWSLOT"] = "檢視欄位",
		["LOAD_ERROR"] = "|cff00ff00載入 AutoBarConfig 發生錯誤。請確定是否有這個插件，並啟用插件。|r錯誤: ",
		["Toggle the config panel"] = "切換 AutoBar 設定視窗",
		["Empty"] = "--",

		--  AutoBarConfig.lua
		["EMPTY"] = "空"; --AUTOBAR_CONFIG_EMPTY
		["STYLE"] = "樣式",
		["STYLE_TIP"] = "改變動作條樣式。",
		["DEFAULT"] = "預設",
		["ZOOMED"] = "放大",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "停用右擊自我施法";
		["AUTOBAR_CONFIG_REMOVECAT"] = "移除目前類型";
		["AUTOBAR_CONFIG_ROW"] = "列";
		["AUTOBAR_CONFIG_COLUMN"] = "欄";
		["AUTOBAR_CONFIG_GAPPING"] = "圖示間隔";
		["AUTOBAR_CONFIG_ALPHA"] = "圖示透明度";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "按鈕寬度";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "按鈕高度";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "調整左右依附位置";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "調整上下依附位置";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "不鎖定\n按鈕長寬比";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "隱藏快捷鍵顯示";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "隱藏數量顯示";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "顯示空按鈕";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "顯示物品類型圖示";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "隱藏提示訊息";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "按鈕\n彈出\n方向";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "按Shift鍵彈出按鈕";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "隱藏拖曳點";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "高框架顯示層級";
		["AUTOBAR_CONFIG_CTRLSHOWSDRAGHANDLE"] = "按Ctrl鍵顯示拖曳點";
		["AUTOBAR_CONFIG_LOCKACTIONBARS"] = "當鎖定 AutoBar 時，\n鎖定動作條";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "隱藏按鈕邊框";
		["AUTOBAR_CONFIG_NOPOPUP"] = "不彈出";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "使用後重新排列順序";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "右鍵以寵物為目標";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "無";
		["AUTOBAR_CONFIG_BT3BAR"] = "BT3 動作條";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "主目錄";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "聊天視窗";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "聊天視窗選單";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "動作條";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "小選單";
		["AUTOBAR_CONFIG_ALIGN"] = "按鈕排列方向";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(未發現: 物品 ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " 層 (左鍵編輯)";
		["AUTOBAR_CONFIG_CHARACTER"] = "角色";
		["AUTOBAR_CONFIG_SHARED"] = "共用";
		["AUTOBAR_CONFIG_CLASS"] = "職業";
		["AUTOBAR_CONFIG_BASIC"] = "基本";
		["AUTOBAR_CONFIG_USECHARACTER"] = "使用角色層";
		["AUTOBAR_CONFIG_USESHARED"] = "使用共用層";
		["AUTOBAR_CONFIG_USECLASS"] = "使用職業層";
		["AUTOBAR_CONFIG_USEBASIC"] = "使用基本層";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "隱藏設定提示訊息";
		["AUTOBAR_CONFIG_OSKIN"] = "使用 oSkin";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "記錄效能";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "角色層";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "共用層";
		["AUTOBAR_CONFIG_SHARED1"] = "共用1";
		["AUTOBAR_CONFIG_SHARED2"] = "共用2";
		["AUTOBAR_CONFIG_SHARED3"] = "共用3";
		["AUTOBAR_CONFIG_SHARED4"] = "共用4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "編輯角色層";
		["AUTOBAR_CONFIG_EDITSHARED"] = "編輯共用層";
		["AUTOBAR_CONFIG_EDITCLASS"] = "編輯職業層";
		["AUTOBAR_CONFIG_EDITBASIC"] = "編輯基本層";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "煙火",
		["Tradeskill.Tool.Fishing.Lure"] = "魚餌",
		["Tradeskill.Tool.Fishing.Gear"] = "釣魚裝備",
		["Tradeskill.Tool.Fishing.Tool"] = "魚竿",

		["Consumable.Food.Bonus"] = "食物: 所有補助食物";
		["Consumable.Food.Buff.Strength"] = "食物: 力量增益";
		["Consumable.Food.Buff.Agility"] = "食物: 敏捷增益";
		["Consumable.Food.Buff.Attack Power"] = "食物: 攻擊強度增益";
		["Consumable.Food.Buff.Healing"] = "食物: 治療效果增益";
		["Consumable.Food.Buff.Spell Damage"] = "食物: 法術傷害增益";
		["Consumable.Food.Buff.Stamina"] = "食物: 耐力增益";
		["Consumable.Food.Buff.Intellect"] = "食物: 智力增益";
		["Consumable.Food.Buff.Spirit"] = "食物: 精神增益";
		["Consumable.Food.Buff.Mana Regen"] = "食物: 法力恢復增益";
		["Consumable.Food.Buff.HP Regen"] = "食物: 生命力恢復增益";
		["Consumable.Food.Buff.Other"] = "食物: 其他";

		["Consumable.Buff.Health"] = "增益: 生命力";
		["Consumable.Buff.Armor"] = "增益: 護甲值";
		["Consumable.Buff.Regen Health"] = "增益: 生命力恢復速度";
		["Consumable.Buff.Agility"] = "增益: 敏捷";
		["Consumable.Buff.Intellect"] = "增益: 智力";
		["Consumable.Buff.Protection"] = "增益: 防護";
		["Consumable.Buff.Spirit"] = "增益: 精神";
		["Consumable.Buff.Stamina"] = "增益: 耐力";
		["Consumable.Buff.Strength"] = "增益: 力量";
		["Consumable.Buff.Attack Power"] = "增益: 攻擊強度";
		["Consumable.Buff.Attack Speed"] = "增益: 攻擊速度";
		["Consumable.Buff.Dodge"] = "增益: 閃躲";
		["Consumable.Buff.Resistance"] = "增益: 抗性";

		["Consumable.Buff Group.General.Self"] = "增益: 一般";
		["Consumable.Buff Group.General.Target"] = "增益: 一般目標";
		["Consumable.Buff Group.Caster.Self"] = "增益: 施法者";
		["Consumable.Buff Group.Caster.Target"] = "增益: 施法者目標";
		["Consumable.Buff Group.Melee.Self"] = "增益: 近戰";
		["Consumable.Buff Group.Melee.Target"] = "增益: 近戰目標";
		["Consumable.Buff.Other.Self"] = "增益: 其他";
		["Consumable.Buff.Other.Target"] = "增益: 其他目標";
		["Consumable.Buff.Chest"] = "增益: 胸甲";
		["Consumable.Buff.Shield"] = "增益: 盾牌";
		["Consumable.Weapon Buff"] = "增益: 武器";

		["Consumable.Quest.Usable"] = "任務物品";

		["Consumable.Potion.Recovery.Healing.Basic"] = "治療藥水";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "治療藥水: 劍刃山脈";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "治療藥水: 盤牙洞穴";
		["Consumable.Potion.Recovery.Healing.PvP"] = "治療藥水: 戰場";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "治療藥水: 風暴要塞";
		["Consumable.Potion.Recovery.Mana.Basic"] = "法力藥水";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "法力藥水: 劍刃山脈";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "法力藥水: 盤牙洞穴";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "法力藥水: 戰場";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "法力藥水: 風暴要塞";

		["Consumable.Weapon Buff.Poison.Crippling"] = "致殘毒藥";
		["Consumable.Weapon Buff.Poison.Deadly"] = "致命毒藥";
		["Consumable.Weapon Buff.Poison.Instant"] = "速效毒藥";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "麻痹毒藥";
		["Consumable.Weapon Buff.Poison.Wound"] = "致傷毒藥";
		["Consumable.Weapon Buff.Oil.Mana"] = "法力之油";
		["Consumable.Weapon Buff.Oil.Wizard"] = "巫師之油";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "磨刀石";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "平衡石";

		["Consumable.Bandage.Basic"] = "繃帶";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "奧特蘭克繃帶";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "戰歌繃帶";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "阿拉希繃帶";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "食物: 普通";
		["Consumable.Food.Percent.Basic"] = "食物: 恢復固定百分比生命力";
		["Consumable.Food.Percent.Bonus"] = "食物: 恢復固定百分比生命力 (補助效果)";
		["Consumable.Food.Combo Percent"] = "食物: 恢復固定百分比生命力及法力";
		["Consumable.Food.Combo Health"] = "複合食物";
		["Consumable.Food.Edible.Bread.Conjured"] = "食物: 魔法麵包";
		["Consumable.Food.Conjure"] = "造食術";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "食物: 阿拉希盆地";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "食物: 戰歌峽谷";

		["Consumable.Food.Pet.Bread"] = "食物: 寵物麵包";
		["Consumable.Food.Pet.Cheese"] = "食物: 寵物乳酪";
		["Consumable.Food.Pet.Fish"] = "食物: 寵物魚類";
		["Consumable.Food.Pet.Fruit"] = "食物: 寵物水果";
		["Consumable.Food.Pet.Fungus"] = "食物: 寵物蘑菇";
		["Consumable.Food.Pet.Meat"] = "食物: 寵物肉類";

		["AUTOBAR_CLASS_CUSTOM"] = "自訂";
		["Misc.Minipet.Normal"] = "觀賞用寵物";
		["Misc.Minipet.Snowball"] = "節慶觀賞用寵物";
		["AUTOBAR_CLASS_CLEAR"] = "清除欄位";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "安戈洛: 恢復水晶";

		["Consumable.Anti-Venom"] = "抗毒藥劑";

		["Consumable.Warlock.Healthstone"] = "治療石";
		["Consumable.Warlock.Create Healthstone"] = "製造治療石";
		["Consumable.Mage.Mana Stone"] = "法力寶石";
		["Consumable.Mage.Conjure Mana Stone"] = "製造法力寶石";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "昏睡藥水";
		["Consumable.Potion.Recovery.Rejuvenation"] = "活力藥水";
		["Consumable.Jeweler.Statue"] = "石像";

		["Misc.Battle Standard.Battleground"] = "戰場軍旗";
		["Misc.Battle Standard.Alterac Valley"] = "奧特蘭克山谷軍旗";
		["Consumable.Recovery.Rune"] = "惡魔和黑暗符文";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "秘法防護";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "火焰防護";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "冰霜防護";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "自然防護";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "暗影防護";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "法術防護";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "神聖防護";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "有限無敵藥水";
		["Consumable.Buff.Free Action"] = "增益: 自由行動";

		["AUTOBAR_CLASS_PORTALS"] = "傳送門和傳送";
		["Misc.Hearth"] = "爐石";
		["Misc.Booze"] = "酒";
		["Consumable.Water.Basic"] = "水";
		["Consumable.Water.Percentage"] = "水: 恢復固定百分比法力";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "水: 魔法水";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "造水術";
		["Consumable.Water.Buff.Spirit"] = "水: 精神增益";
		["Consumable.Buff.Rage.Self"] = "怒氣藥水";
		["Consumable.Buff.Energy.Self"] = "能量藥水";
		["Consumable.Buff.Speed"] = "增益: 迅捷";
		["AUTOBAR_CLASS_SOULSHARDS"] = "靈魂碎片";
		["Reagent.Ammo.Arrow"] = "箭";
		["Reagent.Ammo.Bullet"] = "子彈";
		["Reagent.Ammo.Thrown"] = "投擲武器";
		["Misc.Engineering.Explosives"] = "工程學爆炸物";
		["Misc.Mount.Normal"] = "騎乘";
		["Misc.Mount.Summoned"] = "騎乘: 召喚";
		["Misc.Mount.Ahn'Qiraj"] = "騎乘: 其拉甲蟲";
		["Misc.Mount.Flying"] = "騎乘: 飛行";

	}
end);


if (GetLocale()=="zhTW") then

AUTOBAR_CHAT_MESSAGE1 = "記錄檔是舊的版本，已被清除。不支援記錄檔的升級。";
AUTOBAR_CHAT_MESSAGE2 = "更新多物品按鈕#%d物品#%d，使用物品編號替換物品名稱。";
AUTOBAR_CHAT_MESSAGE3 = "更新單一物品按鈕#%d，使用物品編號替換物品名稱。";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "要編輯欄位請選擇欄位分頁\n下方的欄位進行編輯。";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "檢視綜合層 (無法編輯)";
AUTOBAR_CONFIG_RESET = "重設";
AUTOBAR_CONFIG_REVERT = "復原";
AUTOBAR_CONFIG_DONE = "完成";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Shift-點擊進入詳細分類)";
AUTOBAR_CONFIG_DRAGHANDLE = "滑鼠左鍵拖曳移動 AutoBar\n左擊鎖定/解鎖\n右鍵顯示功能選項";
AUTOBAR_CONFIG_EMPTYSLOT = "空欄位";
AUTOBAR_CONFIG_CLEARSLOT = "清除欄位";
AUTOBAR_CONFIG_SETSHARED = "共用記錄檔:";
AUTOBAR_CONFIG_SETSHAREDTIP = "選擇使用共用記錄檔，\n將會把共用的設定值套用到所有的角色。";

AUTOBAR_CONFIG_TAB_SLOTS = "欄位";
AUTOBAR_CONFIG_TAB_BAR = "動作條";
AUTOBAR_CONFIG_TAB_BUTTONS = "按鈕";
AUTOBAR_CONFIG_TAB_POPUP = "彈出";
AUTOBAR_CONFIG_TAB_PROFILE = "記錄檔";
AUTOBAR_CONFIG_TAB_KEYS = "快捷鍵";

AUTOBAR_TOOLTIP1 = " (數量: ";
AUTOBAR_TOOLTIP2 = " [自定義物品]";
AUTOBAR_TOOLTIP4 = " [僅用於戰場]";
AUTOBAR_TOOLTIP5 = " [僅用於非戰鬥狀態]";
AUTOBAR_TOOLTIP6 = " [使用條件限制]";
AUTOBAR_TOOLTIP7 = " [使用後需冷卻]";
AUTOBAR_TOOLTIP8 = "\n(左鍵用於主手武器\n右鍵用於副手武器)";

AUTOBAR_CONFIG_DOCKTO = "依附於:";
AUTOBAR_CONFIG_USECHARACTERTIP = "角色層的物品只適用於這個角色。";
AUTOBAR_CONFIG_USESHAREDTIP = "共用層的物品適用於其他角色使用。\n共用項目可由記錄檔分頁中選擇。";
AUTOBAR_CONFIG_USECLASSTIP = "職業層的物品適用於所有相同職業的角色。";
AUTOBAR_CONFIG_USEBASICTIP = "基本層的物品適用於所有角色可用的基本物品。";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "改變可見的層只作用於這個角色。";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "改變可見的層可作用於所有使用相同的記錄檔的角色。";
AUTOBAR_CONFIG_TIPOVERRIDE = "這一層的物品優先順序優於下一層的欄位。\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "上一層的物品優先順序優於這一層的欄位。\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "變動只作用於這個角色。";
AUTOBAR_CONFIG_TIPAFFECTSALL = "變動作用於所有角色。";
AUTOBAR_CONFIG_SETUPSINGLE = "古典設定";
AUTOBAR_CONFIG_SETUPSHARED = "共用設定";
AUTOBAR_CONFIG_SETUPSTANDARD = "標準設定";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "清空欄位";
AUTOBAR_CONFIG_SETUPSINGLETIP = "點擊將設定為古典 AutoBar 設定。";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "點擊將設定為共用設定\n啟用角色專用以及共用欄位。";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "啟用編輯並使用所有欄位。";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "清除所有角色和共用的欄位。";
AUTOBAR_CONFIG_RESETSINGLETIP = "點擊將重設為單一角色設定的預設值。";
AUTOBAR_CONFIG_RESETSHAREDTIP = "點擊將重設為角色共用設定的預設值。\n職業專用按鈕會複製到角色欄位。\n預設按鈕將複製到共用的欄位。";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "點擊將重設為標準預設值。\n職業專用按鈕會在職業欄位中。\n預設按鈕在基本欄位中。\n共用和角色欄位將會清除。";

--  AutoBarConfig.lua
AUTOBAR_TOOLTIP9 = "多類型物品按鈕\n";
AUTOBAR_TOOLTIP10 = " (按物品編號定制)";
AUTOBAR_TOOLTIP11 = "\n(物品編號未經過驗證)";
AUTOBAR_TOOLTIP12 = " (按物品名稱定制)";
AUTOBAR_TOOLTIP13 = "單一類型物品按鈕\n\n";
AUTOBAR_TOOLTIP14 = "\n不能直接使用。";
AUTOBAR_TOOLTIP15 = "\n武器目標\n(左鍵用於主手武器\n右鍵用於副手武器。)";
AUTOBAR_TOOLTIP16 = "\n需目標。";
AUTOBAR_TOOLTIP17 = "\n僅用於非戰鬥狀態。";
AUTOBAR_TOOLTIP18 = "\n僅用於戰鬥狀態。";
AUTOBAR_TOOLTIP19 = "\n使用地點: ";
AUTOBAR_TOOLTIP20 = "\n使用條件限制: ";
AUTOBAR_TOOLTIP21 = "需恢復生命力";
AUTOBAR_TOOLTIP22 = "需恢復法力";
AUTOBAR_TOOLTIP23 = "單一物品按鈕\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "奧特蘭克山谷";
--AUTOBAR_WARSONGGULCH = "戰歌峽谷";
--AUTOBAR_ARATHIBASIN = "阿拉希盆地";
--AUTOBAR_AHN_QIRAJ = "安其拉";

end