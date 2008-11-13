--[[
Name: Babble-Inventory-2.2
Revision: $Rev: 47451 $
Authors(s): Daviesh (oma_daviesh@hotmail.com)
Documentation: http://www.wowace.com/wiki/Babble-Inventory-2.2
SVN: http://svn.wowace.com/wowace/trunk/Babble-2.2/Babble-Inventory-2.2
Dependencies: AceLibrary, AceLocale-2.2
License: MIT
]]

local MAJOR_VERSION = "Babble-Inventory-2.2"
local MINOR_VERSION = tonumber(string.sub("$Revision: 47451 $", 12, -3))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end

local _, x = AceLibrary("AceLocale-2.2"):GetLibraryVersion()
MINOR_VERSION = MINOR_VERSION * 100000 + x

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local BabbleInventory = AceLibrary("AceLocale-2.2"):new(MAJOR_VERSION)

BabbleInventory:RegisterTranslations("enUS", function() return {
    --Armor Types
    ["Cloth"] = true,
    ["Leather"] = true,
    ["Mail"] = true,
    ["Plate"] = true,

    --Armor Slots
    ["Head"] = true,
    ["Neck"] = true,
    ["Shoulder"] = true,
    ["Back"] = true,
    ["Chest"] = true,
    ["Shirt"] = true,
    ["Tabard"] = true,
    ["Wrist"] = true,
    ["Hands"] = true,
    ["Waist"] = true,
    ["Legs"] = true,
    ["Feet"] = true,
    ["Ring"] = true,
    ["Trinket"] = true,
    ["Held in Off-Hand"] = true,
    ["Relic"] = true,
    ["Libram"] = true,
    ["Totem"] = true,
    ["Idol"] = true,

    --Weapons
    ["Axe"] = true,
    ["Bow"] = true,
    ["Crossbow"] = true,
    ["Dagger"] = true,
    ["Fist Weapon"] = true,
    ["Gun"] = true,
    ["Mace"] = true,
    ["Polearm"] = true,
    ["Shield"] = true,
    ["Staff"] = true,
    ["Sword"] = true,
    ["Thrown"] = true,
    ["Wand"] = true,

    --Weapon Types
    ["One-Hand"] = true,
    ["Two-Hand"] = true,
    ["Main Hand"] = true,
    ["Off Hand"] = true,

    --Weapon sub-types
    ["Bows"] = true,
    ["Crossbows"] = true,
    ["Daggers"] = true,
    ["Guns"] = true,
    ["Fishing Pole"] = true,
    ["Fist Weapons"] = true,
    ["Miscellaneous"] = true,
    ["One-Handed Axes"] = true,
    ["One-Handed Maces"] = true,
    ["One-Handed Swords"] = true,
    ["Polearms"] = true,
    ["Staves"] = true,
    ["Thrown"] = true,
    ["Two-Handed Axes"] = true,
    ["Two-Handed Maces"] = true,
    ["Two-Handed Swords"] = true,
    ["Wands"] = true,

    --Misc Items
    ["Ammo Pouch"] = true,
    ["Arrow"] = true,
    ["Bag"] = true,
    ["Bandage"] = true,
    ["Bullet"] = true,
    ["Drink"] = true,
    ["Food"] = true,
    ["Gem"] = true,
    ["Key"] = true,
    ["Potion"] = true,
    ["Quiver"] = true,
} end)

BabbleInventory:RegisterTranslations("deDE", function() return {
    --Armor Types
    ["Cloth"] = "Stoff",
    ["Leather"] = "Leder",
    ["Mail"] = "Schwere R\195\188stung",
    ["Plate"] = "Platte",

    --Armor Slots
    ["Head"] = "Kopf",
    ["Neck"] = "Hals",
    ["Shoulder"] = "Schulter",
    ["Back"] = "R\195\188cken",
    ["Chest"] = "Brust",
    ["Shirt"] = "Hemd",
    ["Tabard"] = "Wappenrock",
    ["Wrist"] = "Handgelenke",
    ["Hands"] = "H\195\164nde",
    ["Waist"] = "Taille",
    ["Legs"] = "Beine",
    ["Feet"] = "F\195\188\195\159e",
    ["Ring"] = "Finger",
    ["Trinket"] = "Schmuck",
    ["Held in Off-Hand"] = "In Schildhand gef\195\188hrt",
    ["Relic"] = "Relikt",
    ["Libram"] = "Buchband",
    ["Totem"] = "Totem",
    ["Idol"] = "G\195\182tze",

    --Weapons
    ["Axe"] = "Axt",
    ["Bow"] = "Bogen",
    ["Crossbow"] = "Armbrust",
    ["Dagger"] = "Dolch",
    ["Fist Weapon"] = "Faustwaffe",
    ["Gun"] = "Schusswaffe",
    ["Mace"] = "Streitkolben",
    ["Polearm"] = "Stangenwaffe",
    ["Shield"] = "Schild",
    ["Staff"] = "Stab",
    ["Sword"] = "Schwert",
    ["Thrown"] = "Wurfwaffe",
    ["Wand"] = "Zauberstab",

    --Weapon Types
    ["One-Hand"] = "Einh\195\164ndig",
    ["Two-Hand"] = "Zweih\195\164ndig",
    ["Main Hand"] = "Waffenhand",
    ["Off Hand"] = "Schildhand",

    --Weapon sub-types
    ["Bows"] = "B\195\182gen",
    ["Crossbows"] = "Armbr\195\188ste",
    ["Daggers"] = "Dolche",
    ["Guns"] = "Schusswaffen",
    ["Fishing Pole"] = "Angel",
    ["Fist Weapons"] = "Faustwaffen",
    ["Miscellaneous"] = "Verschiedenes",		--or "Sonstiges"??
    ["One-Handed Axes"] = "Einhand\195\164xte",
    ["One-Handed Maces"] = "Einhandstreitkolben",
    ["One-Handed Swords"] = "Einhandschwerter",
    ["Polearms"] = "Stangenwaffen",
    ["Staves"] = "St\195\164be",
    ["Thrown"] = "Wurfwaffen",
    ["Two-Handed Axes"] = "Zweihand\195\164xte",
    ["Two-Handed Maces"] = "Zweihandstreitkolben",
    ["Two-Handed Swords"] = "Zweihandschwerter",
    ["Wands"] = "Zauberst\195\164be",

    --Misc Items
    ["Ammo Pouch"] = "Munitionsbeutel",
    ["Arrow"] = "Pfeil",
    ["Bag"] = "Beh\195\164lter",
    ["Bandage"] = "Verband",
    ["Bullet"] = "Kugel",
    ["Drink"] = "Getr\195\164nk",
    ["Food"] = "Essen",
    ["Gem"] = "Edelstein",
    ["Key"] = "Schl\195\188ssel",
    ["Potion"] = "Trank",
    ["Quiver"] = "K\195\182cher",
} end)

BabbleInventory:RegisterTranslations("frFR", function() return {
    --Armor Types
    ["Cloth"] = "Tissu",
    ["Leather"] = "Cuir",
    ["Mail"] = "Mailles",
    ["Plate"] = "Plaques",

    --Armor Slots
    ["Head"] = "T\195\170te",
    ["Neck"] = "Cou",
    ["Shoulder"] = "Epaule",
    ["Back"] = "Dos",
    ["Chest"] = "Torse",
    ["Shirt"] = "Chemise",
    ["Tabard"] = "Tabard",
    ["Wrist"] = "Poignets",
    ["Hands"] = "Mains",
    ["Waist"] = "Taille",
    ["Legs"] = "Jambes",
    ["Feet"] = "Pieds",
    ["Ring"] = "Anneau",
    ["Trinket"] = "Bijou",
    ["Held in Off-Hand"] = "Tenu(e) en main gauche",
    ["Relic"] = "Relique",
    ["Libram"] = "Libram",
    ["Totem"] = "Totem",
    ["Idol"] = "Idole",

    --Weapons
    ["Axe"] = "Hache",
    ["Bow"] = "Arc",
    ["Crossbow"] = "Arbal\195\168te",
    ["Dagger"] = "Dague",
    ["Fist Weapon"] = "Arme de pugilat",
    ["Gun"] = "Arme \195\160 feu",
    ["Mace"] = "Masse",
    ["Polearm"] = "Arme d'hast",
    ["Shield"] = "Bouclier",
    ["Staff"] = "B\195\162ton",
    ["Sword"] = "Ep\195\169e",
    ["Thrown"] = "Armes de jet",
    ["Wand"] = "Baguette",

    --Weapon Types
    ["One-Hand"] = "A une main",
    ["Two-Hand"] = "Deux mains",
    ["Main Hand"] = "Main droite",
    ["Off Hand"] = "Main gauche",

    --Weapon sub-types
    ["Bows"] = "Arcs",
    ["Crossbows"] = "Arbalètes",
    ["Daggers"] = "Dagues",
    ["Guns"] = "Fusils",
    ["Fishing Pole"] = "Canne à pêche",
    ["Fist Weapons"] = "Armes de pugilat",
    ["Miscellaneous"] = "Divers",
    ["One-Handed Axes"] = "Haches à une main",
    ["One-Handed Maces"] = "Masses à une main",
    ["One-Handed Swords"] = "Epées à une main",
    ["Polearms"] = "Armes d'hast",
    ["Staves"] = "Bâtons",
    ["Thrown"] = "Armes de jets",
    ["Two-Handed Axes"] =  "Haches à deux mains",
    ["Two-Handed Maces"] = "Masses à deux mains",
    ["Two-Handed Swords"] = "Epées à deux mains",
    ["Wands"] = "Baguettes",

    --Misc Items
    ["Ammo Pouch"] = "Giberne",
    ["Arrow"] = "Fl\195\168che",
    ["Bag"] = "Sac",
    ["Bandage"] = "Bandage",
    ["Bullet"] = "Balle",
    ["Drink"] = "Breuvage",
    ["Food"] = "Ration",
    ["Gem"] = "Gemme",
    ["Key"] = "Cl\195\169",
    ["Potion"] = "Potion",
    ["Quiver"] = "Carquois",
} end)

BabbleInventory:RegisterTranslations("zhTW", function() return {
    --Armor Types
    ["Cloth"] = "布甲",
    ["Leather"] = "皮甲",
    ["Mail"] = "鎖甲",
    ["Plate"] = "鎧甲",

    --Armor Slots
    ["Head"] = "頭部",
    ["Neck"] = "頸部",
    ["Shoulder"] = "肩部",
    ["Back"] = "背部",
    ["Chest"] = "胸部",
    ["Shirt"] = "襯衣",
    ["Tabard"] = "公會徽章",
    ["Wrist"] = "手腕",
    ["Hands"] = "手",
    ["Waist"] = "腰部",
    ["Legs"] = "腿部",
    ["Feet"] = "腳",
    ["Ring"] = "手指",
    ["Trinket"] = "飾品",
    ["Held in Off-Hand"] = "副手物品",
    ["Relic"] = "聖物",
    ["Libram"] = "聖契",
    ["Totem"] = "圖騰",
    ["Idol"] = "雕像",

    --Weapons
    ["Axe"] = "斧",
    ["Bow"] = "弓",
    ["Crossbow"] = "弩",
    ["Dagger"] = "匕首",
    ["Fist Weapon"] = "拳套",
    ["Gun"] = "槍械",
    ["Mace"] = "錘",
    ["Polearm"] = "長柄武器",
    ["Shield"] = "盾牌",
    ["Staff"] = "法杖",
    ["Sword"] = "劍",
    ["Thrown"] = "投擲武器",
    ["Wand"] = "魔杖",

    --Weapon Types
    ["One-Hand"] = "單手",
    ["Two-Hand"] = "雙手",
    ["Main Hand"] = "主手",
    ["Off Hand"] = "副手",

    --Weapon sub-types
    ["Bows"] = "弓",
    ["Crossbows"] = "弩",
    ["Daggers"] = "匕首",
    ["Guns"] = "槍械",
    ["Fishing Pole"] = "魚竿",
    ["Fist Weapons"] = "拳套",
    ["Miscellaneous"] = "其他",
    ["One-Handed Axes"] = "單手斧",
    ["One-Handed Maces"] = "單手錘",
    ["One-Handed Swords"] = "單手劍",
    ["Polearms"] = "長柄武器",
    ["Staves"] = "法杖",
    ["Thrown"] = "投擲武器",
    ["Two-Handed Axes"] = "雙手斧",
    ["Two-Handed Maces"] = "雙手錘",
    ["Two-Handed Swords"] = "雙手劍",
    ["Wands"] = "魔杖",

    --Misc Items
    ["Ammo Pouch"] = "彈藥袋",
    ["Arrow"] = "箭",
    ["Bag"] = "容器",
    ["Bandage"] = "繃帶",
    ["Bullet"] = "子彈",
    ["Drink"] = "飲料",
    ["Food"] = "食物",
    ["Gem"] = "珠寶",
    ["Key"] = "鑰匙",
    ["Potion"] = "藥水",
    ["Quiver"] = "箭袋",
} end)

BabbleInventory:RegisterTranslations("zhCN", function() return {
    --Armor Types
    ["Cloth"] = "布甲",
    ["Leather"] = "皮甲",
    ["Mail"] = "锁甲",
    ["Plate"] = "板甲",
    
    --Armor Slots
    ["Head"] = "头部",
    ["Neck"] = "颈部",
    ["Shoulder"] = "肩部",
    ["Back"] = "背部",
    ["Chest"] = "胸部",
    ["Shirt"] = "衬衫",
    ["Tabard"] = "徽章",
    ["Wrist"] = "手腕",
    ["Hands"] = "手",
    ["Waist"] = "腰部",
    ["Legs"] = "腿部",
    ["Feet"] = "脚",
    ["Ring"] = "手指",
    ["Trinket"] = "饰品",
    ["Held in Off-Hand"] = "副手物品",
    ["Relic"] = "圣物",
    ["Libram"] = "圣契",
    ["Totem"] = "图腾",
    ["Idol"] = "神像",
    
    --Weapons
    ["Axe"] = "斧",
    ["Bow"] = "弓",
    ["Crossbow"] = "弩",
    ["Dagger"] = "匕首",
    ["Fist Weapon"] = "拳套",
    ["Gun"] = "枪械",
    ["Mace"] = "锤",
    ["Polearm"] = "长柄武器",
    ["Shield"] = "盾牌",
    ["Staff"] = "法杖",
    ["Sword"] = "剑",
    ["Thrown"] = "投掷武器",
    ["Wand"] = "魔杖",
    
    --Weapon Types
    ["One-Hand"] = "单手",
    ["Two-Hand"] = "双手",
    ["Main Hand"] = "主手",
    ["Off Hand"] = "副手",
    
	--Weapon sub-types
    ["Bows"] = "弓",
    ["Crossbows"] = "弩",
    ["Daggers"] = "匕首",
    ["Guns"] = "枪械",
    ["Fishing Pole"] = "鱼竿",
    ["Fist Weapons"] = "拳套",
    ["Miscellaneous"] = "其他",
    ["One-Handed Axes"] = "单手斧",
    ["One-Handed Maces"] = "单手锤",
    ["One-Handed Swords"] = "单手剑",
    ["Polearms"] = "长柄武器",
    ["Staves"] = "法杖",
    ["Thrown"] = "投掷武器",
    ["Two-Handed Axes"] = "双手斧",
    ["Two-Handed Maces"] = "双手锤",
    ["Two-Handed Swords"] = "双手剑",
    ["Wands"] = "魔杖",
	
    --Misc Items
    ["Ammo Pouch"] = "弹药袋",
    ["Arrow"] = "弓箭",
    ["Bag"] = "背包",
    ["Bandage"] = "绷带",
    ["Bullet"] = "子弹",
    ["Drink"] = "饮品",
    ["Food"] = "食物",
    ["Gem"] = "珠宝",
    ["Key"] = "钥匙",
    ["Potion"] = "药水",
    ["Quiver"] = "箭袋",
} end)

BabbleInventory:RegisterTranslations("koKR", function() return {
    --Armor Types
    ["Cloth"] = "천",
    ["Leather"] = "가죽",
    ["Mail"] = "사슬",
    ["Plate"] = "판금",

    --Armor Slots
    ["Head"] = "머리",
    ["Neck"] = "목",
    ["Shoulder"] = "어깨",
    ["Back"] = "등",
    ["Chest"] = "가슴",
    ["Shirt"] = "속옷",
    ["Tabard"] = "휘장",
    ["Wrist"] = "손목",
    ["Hands"] = "손",
    ["Waist"] = "허리",
    ["Legs"] = "다리",
    ["Feet"] = "발",
    ["Ring"] = "손가락",
    ["Trinket"] = "장신구",
    ["Held in Off-Hand"] = "보조장비",
    ["Relic"] = "유물",
    ["Libram"] = "성서",
    ["Totem"] = "토템",
    ["Idol"] = "우상",

    --Weapons
    ["Axe"] = "도끼",
    ["Bow"] = "활",
    ["Crossbow"] = "석궁",
    ["Dagger"] = "단검",
    ["Fist Weapon"] = "장착 무기",
    ["Gun"] = "총",
    ["Mace"] = "둔기",
    ["Polearm"] = "장창",
    ["Shield"] = "방패",
    ["Staff"] = "지팡이",
    ["Sword"] = "도검",
    ["Thrown"] = "투척 무기",
    ["Wand"] = "마법봉",

    --Weapon Types
    ["One-Hand"] = "한손",
    ["Two-Hand"] = "양손",
    ["Main Hand"] = "주장비",
    ["Off Hand"] = "보조장비",

    --Weapon sub-types
    ["Bows"] = "활류",
    ["Crossbows"] = "석궁류",
    ["Daggers"] = "단검류",
    ["Guns"] = "총기류",
    ["Fishing Pole"] = "낚싯대",
    ["Fist Weapons"] = "장착 무기류",
    ["Miscellaneous"] = "기타",
    ["One-Handed Axes"] = "한손 도끼류",
    ["One-Handed Maces"] = "한손 둔기류",
    ["One-Handed Swords"] = "한손 도검류",
    ["Polearms"] = "장창류",
    ["Staves"] = "지팡이류",
    ["Thrown"] = "투척 무기류",
    ["Two-Handed Axes"] = "양손 도끼류",
    ["Two-Handed Maces"] = "양손 둔기류",
    ["Two-Handed Swords"] = "양손 도검류",
    ["Wands"] = "마법봉",

    --Misc Items
    ["Ammo Pouch"] = "탄약주머니",
    ["Arrow"] = "화살",
    ["Bag"] = "가방",
    ["Bandage"] = "붕대",
    ["Bullet"] = "총알",
    ["Drink"] = "음료",
    ["Food"] = "음식",
    ["Gem"] = "보석",
    ["Key"] = "열쇠",
    ["Potion"] = "물약",
    ["Quiver"] = "화살통",
} end)

BabbleInventory:RegisterTranslations("esES", function() return {
    --Armor Types
    ["Cloth"] = "Tela",
    ["Leather"] = "Cuero",
    ["Mail"] = "Malla",
    ["Plate"] = "Placas", -- Malla de placas?

    --Armor Slots
    ["Head"] = "Cabeza",
    ["Neck"] = "Cuello",
    ["Shoulder"] = "Hombro",
    ["Back"] = "Espalda",
    ["Chest"] = "Pecho",
    ["Shirt"] = "Camisa",
    ["Tabard"] = "Tabardo",
    ["Wrist"] = "Muñeca",
    ["Hands"] = "Manos",
    ["Waist"] = "Cintura",
    ["Legs"] = "Piernas",
    ["Feet"] = "Pies",
    ["Ring"] = "Dedo",
    ["Trinket"] = "Alhaja",
    ["Held in Off-Hand"] = "Sostener con la mano izquierda",
    ["Relic"] = "Reliquia",
    ["Libram"] = "Tratado",
    ["Totem"] = "Tótem",
    ["Idol"] = "Ídolo",

    --Weapons
    ["Axe"] = "Hacha",
    ["Bow"] = "Arco",
    ["Crossbow"] = "Ballesta",
    ["Dagger"] = "Daga",
    ["Fist Weapon"] = "Arma de puño",
    ["Gun"] = "Arma de fuego",
    ["Mace"] = "Maza",
    ["Polearm"] = "Arma de asta",
    ["Shield"] = "Escudo",
    ["Staff"] = "Bastón",
    ["Sword"] = "Espada",
    ["Thrown"] = "Arma arrojadiza",
   	["Wand"] = "Varita",

    --Weapon Types
    ["One-Hand"] = "Una mano",
    ["Two-Hand"] = "Dos manos",
    ["Main Hand"] = "Mano derecha",
   	["Off Hand"] = "Mano izquierda",

    --Weapon sub-types
--	["Bows"] = true,
--	["Crossbows"] = true,
--	["Daggers"] = true,
--	["Guns"] = true,
--	["Fishing Pole"] = true,
--	["Fist Weapons"] = true,
--	["Miscellaneous"] = true,
--	["One-Handed Axes"] = true,
--	["One-Handed Maces"] = true,
--	["One-Handed Swords"] = true,
--	["Polearms"] = true,
--	["Staves"] = true,
--	["Thrown"] = true,
--	["Two-Handed Axes"] = true,
--	["Two-Handed Maces"] = true,
--	["Two-Handed Swords"] = true,
--	["Wands"] = true,

    --Misc Items
    ["Ammo Pouch"] = "Bolsa de munición",
    ["Arrow"] = "Flecha",
    ["Bag"] = "Bolsa",
    ["Bandage"] = "Venda",
    ["Bullet"] = "Bala",
    ["Drink"] = "Bebida",
    ["Food"] = "Comida",
    ["Gem"] = "Gema",
    ["Key"] = "Llave",
    ["Potion"] = "Poción",
    ["Quiver"] = "Carcaj",
} end)

BabbleInventory:Debug()
BabbleInventory:SetStrictness(true)

AceLibrary:Register(BabbleInventory, MAJOR_VERSION, MINOR_VERSION)
BabbleInventory = nil
