-------------------------------------------------------------------------------
-- Taiwan Localization 
-- Update: 2007/10/14 rx9876@ptt.cc全新翻譯 2.2a_zhtw v.4, ref to 竹笙姬@暴風祭壇, DDX, Youngway
--                    pattern翻譯不確定, 需要看戰鬥記錄, 沒有職業角色無法測, pattern實際功能未深入研究也不清楚
-------------------------------------------------------------------------------
if (GetLocale() == "zhTW") then

-- Druid
SMARTBUFF_DRUID_CAT = "獵豹形態";
SMARTBUFF_DRUID_MOONKIN = "梟獸型態";
SMARTBUFF_DRUID_TRACK = "追蹤人型生物";

SMARTBUFF_MOTW = "野性印記";
SMARTBUFF_GOTW = "野性賜福";
SMARTBUFF_THORNS = "荊棘術";
SMARTBUFF_OMENOFCLARITY = "清晰預兆";
SMARTBUFF_BARKSKIN = "樹皮術";
SMARTBUFF_NATURESGRASP = "自然之握";
SMARTBUFF_TIGERSFURY = "猛虎之怒";
SMARTBUFF_REJUVENATION = "回春術";
SMARTBUFF_REGROWTH = "癒合";

SMARTBUFF_REMOVECURSE = "消除詛咒";
SMARTBUFF_ABOLISHPOISON = "驅毒術";

-- Mage
SMARTBUFF_AI = "秘法智慧";
SMARTBUFF_AB = "秘法光輝";
SMARTBUFF_ICEARMOR = "冰甲術";
SMARTBUFF_FROSTARMOR = "霜甲術";
SMARTBUFF_MAGEARMOR = "魔甲術";
SMARTBUFF_MOLTENARMOR = "熔火護甲";
SMARTBUFF_DAMPENMAGIC = "魔法抑制";
SMARTBUFF_AMPLIFYMAGIC = "魔法增效";
SMARTBUFF_MANASHIELD = "法力護盾";
SMARTBUFF_FIREWARD = "防護火焰結界";
SMARTBUFF_FROSTWARD = "防護冰霜結界";
SMARTBUFF_ICEBARRIER = "寒冰護體";
SMARTBUFF_COMBUSTION = "燃燒";
SMARTBUFF_ARCANEPOWER = "秘法強化";

SMARTBUFF_MAGE_PATTERN = {"%a+甲術$"};

-- Priest
SMARTBUFF_PWF = "真言術:韌";
SMARTBUFF_POF = "堅韌禱言";
SMARTBUFF_SP = "暗影防護";
SMARTBUFF_POSP = "暗影防護禱言";
SMARTBUFF_INNERFIRE = "心靈之火";
SMARTBUFF_DS = "神聖之靈";
SMARTBUFF_POS = "精神禱言";
SMARTBUFF_PWS = "真言術:盾";
SMARTBUFF_FEARWARD = "防護恐懼結界";
SMARTBUFF_ELUNESGRACE = "伊露恩的賜福";
SMARTBUFF_FEEDBACK = "回饋";
SMARTBUFF_SHADOWGUARD = "暗影守衛";
SMARTBUFF_TOUCHOFWEAKNESS = "虛弱之觸";
SMARTBUFF_INNERFOCUS = "心靈專注";
SMARTBUFF_RENEW = "恢復";

-- Warlock
SMARTBUFF_FELARMOR = "獄甲術";
SMARTBUFF_DEMONARMOR = "魔甲術";
SMARTBUFF_DEMONSKIN = "惡魔皮膚";
SMARTBUFF_UNENDINGBREATH = "魔息術";
SMARTBUFF_DGINVISIBILITY = "偵測強效隱形";
SMARTBUFF_DINVISIBILITY = "偵測隱形";
SMARTBUFF_DLINVISIBILITY = "偵測次級隱形";
SMARTBUFF_SOULLINK = "靈魂鏈結";
SMARTBUFF_SHADOWWARD = "防護暗影結界";
SMARTBUFF_DARKPACT = "黑暗契約";
SMARTBUFF_SOULSTONE = "靈魂石復活";

SMARTBUFF_WARLOCK_PATTERN = {"^Demon %a+"}; --SMARTBUFF_WARLOCK_PATTERN = {"^Demon %a+", "^Detect %a+ Invisibility$"};

-- Hunter
SMARTBUFF_TRUESHOTAURA = "強擊光環";
SMARTBUFF_RAPIDFIRE = "急速射擊";
SMARTBUFF_AOTH = "雄鷹守護";
SMARTBUFF_AOTM = "靈猴守護";
SMARTBUFF_AOTW = "野性守護";
SMARTBUFF_AOTB = "野獸守護";
SMARTBUFF_AOTC = "獵豹守護";
SMARTBUFF_AOTP = "豹群守護";
SMARTBUFF_AOTV = "蝮蛇守護";

SMARTBUFF_HUNTER_PATTERN = {"^%a+守護$"};

-- Shaman
SMARTBUFF_LIGHTNINGSHIELD = "閃電之盾";
SMARTBUFF_WATERSHIELD = "水之盾";
SMARTBUFF_EARTHSHIELD = "大地之盾";
SMARTBUFF_ROCKBITERW = "石化武器";
SMARTBUFF_FROSTBRANDW = "冰封武器";
SMARTBUFF_FLAMETONGUEW = "火舌武器";
SMARTBUFF_WINDFURYW = "風怒武器";
SMARTBUFF_WATERBREATHING = "水下呼吸";

SMARTBUFF_SHAMAN_PATTERN = {"%a+之盾$"};

-- Warrior
SMARTBUFF_BATTLESHOUT = "戰鬥怒吼";
SMARTBUFF_COMMANDINGSHOUT = "命令之吼";
SMARTBUFF_BERSERKERRAGE = "狂暴之怒";
SMARTBUFF_BLOODRAGE = "血性狂暴";

-- Rogue
SMARTBUFF_BLADEFLURRY = "劍刃亂舞";
SMARTBUFF_SAD = "切割";
SMARTBUFF_EVASION = "閃避";
SMARTBUFF_INSTANTPOISON = "速效毒藥";
SMARTBUFF_WOUNDPOISON = "致傷毒藥";
SMARTBUFF_DEADLYPOISON = "致命毒藥";
SMARTBUFF_CRIPPLINGPOISON = "致殘毒藥";
SMARTBUFF_ANESTHETICPOISON = "麻醉毒藥";
SMARTBUFF_MINDPOISON = "麻痹毒藥";
SMARTBUFF_MINDPOISON2 = "麻痹毒藥 II";
SMARTBUFF_MINDPOISON3 = "麻痹毒藥 III";


-- Paladin
SMARTBUFF_RIGHTEOUSFURY = "正義之怒";
SMARTBUFF_HOLYSHIELD = "神聖之盾";
SMARTBUFF_BOM = "力量祝福";
SMARTBUFF_GBOM = "強效力量祝福";
SMARTBUFF_BOW = "智慧祝福";
SMARTBUFF_GBOW = "強效智慧祝福";
SMARTBUFF_BOSAL = "拯救祝福";
SMARTBUFF_GBOSAL = "強效拯救祝福";
SMARTBUFF_BOK = "王者祝福";
SMARTBUFF_GBOK = "強效王者祝福";
SMARTBUFF_BOSAN = "庇護祝福";
SMARTBUFF_GBOSAN = "強效庇護祝福";
SMARTBUFF_BOL = "光明祝福";
SMARTBUFF_GBOL = "強效光明祝福";
SMARTBUFF_BOF = "自由祝福";
SMARTBUFF_BOP = "保護祝福";
SMARTBUFF_SOCOMMAND = "命令聖印";
SMARTBUFF_SOFURY = "憤怒聖印";
SMARTBUFF_SOJUSTICE = "公正聖印";
SMARTBUFF_SOLIGHT = "光明聖印";
SMARTBUFF_SORIGHTEOUSNESS = "正義聖印";
SMARTBUFF_SOWISDOM = "智慧聖印";
SMARTBUFF_SOTCRUSADER = "十字軍聖印";
SMARTBUFF_SOVENGEANCE = "復仇聖印";
SMARTBUFF_SOBLOOD = "血之聖印";
SMARTBUFF_DEVOTIONAURA = "虔誠光環";
SMARTBUFF_RETRIBUTIONAURA = "懲罰光環";
SMARTBUFF_CONCENTRATIONAURA = "專注光環";
SMARTBUFF_SHADOWRESISTANCEAURA = "暗影抗性光環";
SMARTBUFF_FROSTRESISTANCEAURA = "冰霜抗性光環";
SMARTBUFF_FIRERESISTANCEAURA = "火焰抗性光環";
SMARTBUFF_SANCTITYAURA = "聖潔光環";
SMARTBUFF_CRUSADERAURA = "十字軍光環";

SMARTBUFF_PALADIN_PATTERN = {"^%a+聖印$"};

-- Stones and oils
SMARTBUFF_SSROUGH = "劣質磨刀石";
SMARTBUFF_SSCOARSE = "粗製磨刀石";
SMARTBUFF_SSHEAVY = "重磨刀石";
SMARTBUFF_SSSOLID = "堅固的磨刀石";
SMARTBUFF_SSDENSE = "緻密磨刀石";
SMARTBUFF_SSELEMENTAL = "元素磨刀石";
SMARTBUFF_WSROUGH = "劣質平衡石";
SMARTBUFF_WSCOARSE = "粗製平衡石";
SMARTBUFF_WSHEAVY = "重平衡石";
SMARTBUFF_WSSOLID = "堅固的平衡石";
SMARTBUFF_WSDENSE = "緻密平衡石";
SMARTBUFF_SHADOWOIL = "暗影之油";
SMARTBUFF_FROSTOIL = "冰霜之油";
SMARTBUFF_MANAOILMINOR = "初級法力之油";
SMARTBUFF_MANAOILLESSER = "次級法力之油";
SMARTBUFF_MANAOILBRILLIANT = "卓越法力之油";
SMARTBUFF_MANAOILSUPERIOR = "超強法力之油";
SMARTBUFF_WIZARDOILMINOR = "初級法力之油";
SMARTBUFF_WIZARDOILLESSER = "次級巫師之油";
SMARTBUFF_WIZARDOIL = "巫師之油";
SMARTBUFF_WIZARDOILBRILLIANT = "卓越巫師之油";
SMARTBUFF_WIZARDOILSUPERIOR = "超強巫師之油";

SMARTBUFF_WEAPON_STANDARD = {"匕首", "斧", "劍", "錘", "法杖", "拳套", "長柄武器"};
SMARTBUFF_WEAPON_BLUNT = {"魔杖", "法杖", "拳套"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "平衡石$";
SMARTBUFF_WEAPON_SHARP = {"匕首", "斧", "劍", "長柄武器"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "磨刀石$";

-- Tracking
SMARTBUFF_FINDMINERALS = "尋找礦物";
SMARTBUFF_FINDHERBS = "尋找草藥";
SMARTBUFF_FINDTREASURE = "尋找財寶";
SMARTBUFF_TRACKHUMANOIDS = "追蹤人型生物";
SMARTBUFF_TRACKBEASTS = "追蹤野獸";
SMARTBUFF_TRACKUNDEAD = "追蹤不死生物";
SMARTBUFF_TRACKHIDDEN = "追蹤隱藏生物";
SMARTBUFF_TRACKELEMENTALS = "追蹤元素生物";
SMARTBUFF_TRACKDEMONS = "追蹤惡魔";
SMARTBUFF_TRACKGIANTS = "追蹤巨人";
SMARTBUFF_TRACKDRAGONKIN = "追蹤龍類";
SMARTBUFF_SENSEDEMONS = "感知惡魔";
SMARTBUFF_SENSEUNDEAD = "感知不死生物";

-- Racial
SMARTBUFF_STONEFORM = "石像形態";
SMARTBUFF_PRECEPTION = "感知";
SMARTBUFF_BLOODFURY = "血性狂暴";
SMARTBUFF_BERSERKING = "狂暴";
SMARTBUFF_WOTFORSAKEN = "亡靈意志";

-- Reagents
SMARTBUFF_WILDBERRIES = "野性漿果";
SMARTBUFF_WILDTHORNROOT = "野性荊棘草";
SMARTBUFF_WILDQUILLVINE = "野生羽蔓";
SMARTBUFF_ARCANEPOWDER = "魔粉";
SMARTBUFF_HOLYCANDLE = "聖潔蠟燭";
SMARTBUFF_SACREDCANDLE = "神聖蠟燭";
SMARTBUFF_SYMBOLOFKINGS = "王者印記";

-- Food
--SMARTBUFF_ = "";
SMARTBUFF_SAGEFISHDELIGHT = "美味鼠尾魚";
SMARTBUFF_BUZZARDBITES = "禿鷲便餐";
SMARTBUFF_RAVAGERDOG = "劫毀熱狗";
SMARTBUFF_FELTAILDELIGHT = "魔尾點心";
SMARTBUFF_CLAMBAR = "蛤蜊條";
SMARTBUFF_SPORELINGSNACK = "小孢子點心";
SMARTBUFF_BLACKENEDSPOREFISH = "焦黑的孢子魚";
SMARTBUFF_BLACKENEDBASILISK = "焦黑的蜥蜴肉串";
SMARTBUFF_GRILLEDMUDFISH = "烤泥鰍";
SMARTBUFF_POACHEDBLUEFISH = "水煮藍魚";
SMARTBUFF_ROASTEDCLEFTHOOF = "燒烤裂蹄肉";
SMARTBUFF_WARPBURGER = "扭曲漢堡";
SMARTBUFF_TALBUKSTEAK = "塔巴克肉排";
SMARTBUFF_GOLDENFISHSTICKS = "金魚肉串";
SMARTBUFF_CRUNCHYSERPENT = "香脆巨蛇肉";
SMARTBUFF_MOKNATHALSHORTRIBS = "摩克納薩爾小肋排";
SMARTBUFF_SPICYCRAWDAD = "香辣喇蛄";

SMARTBUFF_FOOD_AURA = "進食充分";


-- Creature type
SMARTBUFF_HUMANOID  = "人型生物";
SMARTBUFF_DEMON     = "惡魔";
SMARTBUFF_BEAST     = "野獸";
SMARTBUFF_ELEMENTAL = "元素生物";
SMARTBUFF_DEMONTYPE = "小鬼";

-- Classes
SMARTBUFF_CLASSES = {"德魯伊", "獵人", "法師", "聖騎士", "牧師", "盜賊", "薩滿", "術士", "戰士", "獵人寵物", "術士寵物"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"自我", "隊伍", "團隊", "戰場", "MC", "Ony", "BWL", "AQ", "ZG", "自定義 1", "自定義 2", "自定義 3", "自定義 4", "自定義 5"};
SMARTBUFF_INSTANCES = {"熔火之心", "奧妮克希亞的巢穴", "黑翼之巢", "安其拉", "祖爾格拉布", "奧特蘭克山谷", "阿拉希盆地", "戰歌峽谷"};

-- Mount
SMARTBUFF_MOUNT = "速度提高%a*(%d+)%%.";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "觸發";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "目標";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "選項視窗";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "重置 Buff 時間";

-- Options Frame Text
SMARTBUFF_OFT                = "SmartBuff 開/關";
SMARTBUFF_OFT_MENU           = "選項視窗 顯示/隱藏";
SMARTBUFF_OFT_AUTO           = "啟用提示";
SMARTBUFF_OFT_AUTOTIMER      = "檢查週期";
SMARTBUFF_OFT_AUTOCOMBAT     = "戰鬥";
SMARTBUFF_OFT_AUTOCHAT       = "聊天";
SMARTBUFF_OFT_AUTOSPLASH     = "閃爍";
SMARTBUFF_OFT_AUTOSOUND      = "聲音";
SMARTBUFF_OFT_AUTOREST       = "城市內停用";
SMARTBUFF_OFT_HUNTERPETS     = "Buff獵人寵物";
SMARTBUFF_OFT_WARLOCKPETS    = "Buff術士寵物";
SMARTBUFF_OFT_ARULES         = "進階規則";
SMARTBUFF_OFT_GRP            = "監控團隊中小隊";
SMARTBUFF_OFT_SUBGRPCHANGED  = "開啟選項視窗";
SMARTBUFF_OFT_BUFFS          = "Buff項目";
SMARTBUFF_OFT_TARGET         = "Buff目標";
SMARTBUFF_OFT_DONE           = "確定";
SMARTBUFF_OFT_APPLY          = "套用";
SMARTBUFF_OFT_GRPBUFFSIZE    = "隊伍觸發人數";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "職業觸發人數";
SMARTBUFF_OFT_MESSAGES       = "關閉訊息";
SMARTBUFF_OFT_MSGNORMAL      = "一般";
SMARTBUFF_OFT_MSGWARNING     = "警告";
SMARTBUFF_OFT_MSGERROR       = "錯誤";
SMARTBUFF_OFT_HIDEMMBUTTON   = "隱藏小地圖按鈕";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff計時器";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "自動切換方案";
SMARTBUFF_OFT_SELFFIRST      = "自己優先";
SMARTBUFF_OFT_SCROLLWHEEL    = "滑鼠滾輪觸發";
SMARTBUFF_OFT_SCROLLWHEELUP  = "滑鼠滾輪向上";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "下";
SMARTBUFF_OFT_TARGETSWITCH   = "目標改變觸發";
SMARTBUFF_OFT_BUFFTARGET     = "Buff 目標";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "副本";
SMARTBUFF_OFT_CHECKCHARGES   = "次數檢查";
SMARTBUFF_OFT_RBT            = "重置計時器";
SMARTBUFF_OFT_BUFFINCITIES   = "在城市內buff";
SMARTBUFF_OFT_UISYNC         = "UI同步";
SMARTBUFF_OFT_ADVGRPBUFFCHECK = "團隊buff檢查";
SMARTBUFF_OFT_ADVGRPBUFFRANGE = "團隊範圍檢查";
SMARTBUFF_OFT_BLDURATION     = "忽略";
SMARTBUFF_OFT_COMPMODE       = "相容模式";
SMARTBUFF_OFT_MINIGRP        = "小團隊";
SMARTBUFF_OFT_ANTIDAZE       = "防眩暈";
SMARTBUFF_OFT_HIDESABUTTON   = "隱藏動作按鈕";
SMARTBUFF_OFT_INCOMBAT       = "戰鬥中";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";

-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "SmarBuff 開/關";
SMARTBUFF_OFTT_AUTO          = "Buff提示 開/關";
SMARTBUFF_OFTT_AUTOTIMER     = "Buff監視時間的間隔";
SMARTBUFF_OFTT_AUTOCOMBAT    = "戰鬥時保持監視";
SMARTBUFF_OFTT_AUTOCHAT      = "Buff消失訊息 - 聊天視窗訊息";
SMARTBUFF_OFTT_AUTOSPLASH    = "Buff消失訊息 - 螢幕中央閃爍訊息";
SMARTBUFF_OFTT_AUTOSOUND     = "Buff消失訊息 - 聲音提示";
SMARTBUFF_OFTT_AUTOREST      = "在主城內停用訊息提示";
SMARTBUFF_OFTT_HUNTERPETS    = "Buff獵人寵物";
SMARTBUFF_OFTT_WARLOCKPETS   = "Buff術士寵物,除了" .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "設定以下情況不施法:\n法師、牧師和術士不施放荊棘術,                    \n無魔法職業不施放秘法智慧、神聖之靈.";
SMARTBUFF_OFTT_SUBGRPCHANGED = "所在小隊變動後,自動開啟Smartbuff選項視窗.";
SMARTBUFF_OFTT_GRPBUFFSIZE   = "小隊補充群體buff的人數門檻.";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "隱藏小地圖按鈕.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Buff消失前多少秒,\n提示你重新施法.\n0 = 不提示";
SMARTBUFF_OFTT_SELFFIRST     = "優先對自己施放buff";
SMARTBUFF_OFTT_SCROLLWHEELUP = "當滑鼠滾輪向前滾動時buff";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "當滑鼠滾輪向後滾動時buff.";
SMARTBUFF_OFTT_TARGETSWITCH  = "當你改變目標時buff.";
SMARTBUFF_OFTT_BUFFTARGET    = "當目標為友好狀態時,優先buff該目標";
SMARTBUFF_OFTT_BUFFPVP       = "自身非PVP時,也buff PvP玩家";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "依團體狀態自動切換方案";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "切換副本時,自動切換方案";
SMARTBUFF_OFTT_CHECKCHARGES  = "當buff次數過低時警告.";
SMARTBUFF_OFTT_BUFFINCITIES  = "當你在城市內仍然buff.\n如果你在PvP狀態下,不論任何情況皆會buff";
SMARTBUFF_OFTT_UISYNC	       = "啟動UI同步自身施放給其他玩家的buff剩餘時間.";
SMARTBUFF_OFTT_ADVGRPBUFFCHECK = "檢查團體buff會一併檢查單體buff.";
SMARTBUFF_OFTT_ADVGRPBUFFRANGE = "檢查施放團隊中,\n是否每個人都在有效範圍內";
SMARTBUFF_OFTT_BLDURATION    = "忽略玩家秒數\n0 = 停用";
SMARTBUFF_OFTT_COMPMODE      = "相容模式\n警示!!!\n除非無法buff自己,否則不勾選";
SMARTBUFF_OFTT_MINIGRP       = "以獨立可移動小視窗顯示Raid各小隊設定.";
SMARTBUFF_OFTT_ANTIDAZE      = "若小隊中有人眩暈,\n自動取消獵豹/豹群守護";
SMARTBUFF_OFTT_SPLASHSTYLE   = "更換 buff 訊息字型.";
SMARTBUFF_OFTT_HIDESABUTTON  = "隱藏SmartBuff動作按鈕.";
SMARTBUFF_OFTT_INCOMBAT      = "只對自己作用.\n被勾選為'戰鬥中'的第一個buff會在戰鬥前被設定在按鈕上,\n並能在戰鬥中使用.\n注意: 戰鬥中禁用邏輯判斷.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "顯示SmartDebuff視窗.";
SMARTBUFF_OFTT_SPLASHDURATION= "閃爍訊息持續秒數.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "僅對自己施法";
SMARTBUFF_BST_SELFNOT        = "不對自己施法";
SMARTBUFF_BST_COMBATIN       = "戰鬥狀態觸發";
SMARTBUFF_BST_COMBATOUT      = "非戰鬥狀態觸發";
SMARTBUFF_BST_MAINHAND       = "主手";
SMARTBUFF_BST_OFFHAND        = "副手";
SMARTBUFF_BST_REMINDER       = "通知";
SMARTBUFF_BST_MANALIMIT      = "力能底線";--力能是技能施放來源,如怒氣、能量、法力

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "僅對自己施法,不對其他隊友施法";
SMARTBUFF_BSTT_SELFNOT       = "除了自己,也buff所有勾選職業";
SMARTBUFF_BSTT_COMBATIN      = "在戰鬥狀態時保持自動觸發技能";
SMARTBUFF_BSTT_COMBATOUT     = "在非戰鬥狀態時保持自動觸發技能";
SMARTBUFF_BSTT_MAINHAND      = "Buff主手";
SMARTBUFF_BSTT_OFFHAND       = "Buff副手";
SMARTBUFF_BSTT_REMINDER      = "顯示提示訊息.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Buff消失前多少秒,\n發出警告訊息.0 = 不提示";
SMARTBUFF_BSTT_MANALIMIT     = "設定魔法/怒氣/能量保留門檻.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "最小化/最大化 設定視窗.";

-- Messages
SMARTBUFF_MSG_LOADED         = "已載入.";
SMARTBUFF_MSG_DISABLED       = "SmarBuff已停用.";
SMARTBUFF_MSG_SUBGROUP       = "你已經加入一個新的小隊,請檢查你的設定.";
SMARTBUFF_MSG_NOTHINGTODO    = "不需執行任何指令.";
SMARTBUFF_MSG_BUFFED         = "已施放";
SMARTBUFF_MSG_OOR            = "不在施法範圍內.";
--SMARTBUFF_MSG_CD             = "冷卻中!";
SMARTBUFF_MSG_CD             = "公共CD時間已到.";
SMARTBUFF_MSG_CHAT           = "沒有發現任何聊天視窗.";
SMARTBUFF_MSG_SHAPESHIFT     = "變形狀態不能施法";
SMARTBUFF_MSG_NOACTIONSLOT   = "需要動作條按鈕才能正常運作";
SMARTBUFF_MSG_GROUP          = "隊伍";
SMARTBUFF_MSG_NEEDS          = "需要加buff:";
SMARTBUFF_MSG_OOM            = "沒有足夠的魔法/怒氣/能量!";
SMARTBUFF_MSG_STOCK          = "目前庫存的";
SMARTBUFF_MSG_NOREAGENT      = "沒有施法材料:";
SMARTBUFF_MSG_DEACTIVATED    = "停用!";
SMARTBUFF_MSG_REBUFF         = "Rebuff:";
SMARTBUFF_MSG_LEFT           = "剩餘";
SMARTBUFF_MSG_CLASS          = "職業";
SMARTBUFF_MSG_CHARGES        = "次";

-- Support
SMARTBUFF_MINIMAP_TT         = "左鍵: 選項視窗\n右鍵: 開/關\nAlt-左鍵: SmartDebuff\nShift拖曳: 移動按鈕";
SMARTBUFF_TITAN_TT           = "左鍵: 開啟選項\n右鍵: 開/關\nAlt-左鍵: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\n左鍵: 開啟選項\nShift-左鍵: 開/關\nAlt-左鍵: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-左鍵拖曳: 移動視窗\n|cff20d2ff- S 按鈕 -|r\n左鍵: 依職業顯示\nShift-左鍵: 職業顏色\nAlt-左鍵: 高亮度 L/R\n|cff20d2ff- P 按鈕 -|r\n左鍵: 隱藏寵物 開/關";


-- Code table
-- à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
-- á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
-- â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
-- ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
-- ä : \195\164                    ñ : \195\177    ö : \195\182
-- æ : \195\166                                    ø : \195\184
-- ç : \195\167                                     : \197\147
-- 
-- Ä : \195\132
-- Ö : \195\150
-- Ü : \195\156
-- ß : \195\159
end