--[[
Name: LibDogTag-2.0
Revision: $Rev: 55375 $
Author: Cameron Kenneth Knight (ckknight@gmail.com)
Inspired By: WatchDog by Vika
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/wiki/LibDogTag-2.0
SVN: svn://svn.wowace.com/wowace/trunk/LibDogTag-2.0
Description: A library to provide a markup syntax for unit frame FontStrings
Dependencies: Rock (optional), MobHealth3/MobHealth2/MobInfo2 (optional), Babble-Spell-2.2 (optional), Threat-1.0 (optional), RangeCheck-1.0 (optional)
License: LGPL v2.1
]]

-------------------------------------------------------------------
-- FOR TAG INFORMATION SEE http://www.wowace.com/wiki/DogTag-2.0 --
-------------------------------------------------------------------

local MAJOR_VERSION = "LibDogTag-2.0"
local MINOR_VERSION = tonumber(("$Revision: 55375 $"):match("%d+")) or 0

local DogTag, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not DogTag then
	return
end

local oldLib
if oldMinor then
	oldLib = {}
	for k,v in pairs(DogTag) do
		oldLib[k] = v
		DogTag[k] = nil
	end
end

local L = {
	-- races
	["Blood Elf"] = "Blood Elf",
	["Draenei"] = "Draenei",
	["Dwarf"] = "Dwarf",
	["Gnome"] = "Gnome",
	["Human"] = "Human",
	["Night Elf"] = "Night Elf",
	["Orc"] = "Orc",
	["Tauren"] = "Tauren",
	["Troll"] = "Troll",
	["Undead"] = "Undead",

	-- short races
	["Blood Elf_short"] = "BE",
	["Draenei_short"] = "Dr",
	["Dwarf_short"] = "Dw",
	["Gnome_short"] = "Gn",
	["Human_short"] = "Hu",
	["Night Elf_short"] = "NE",
	["Orc_short"] = "Or",
	["Tauren_short"] = "Ta",
	["Troll_short"] = "Tr",
	["Undead_short"] = "Ud",

	-- classes
	["Warrior"] = "Warrior",
	["Priest"] = "Priest",
	["Mage"] = "Mage",
	["Shaman"] = "Shaman",
	["Paladin"] = "Paladin",
	["Warlock"] = "Warlock",
	["Druid"] = "Druid",
	["Rogue"] = "Rogue",
	["Hunter"] = "Hunter",

	-- short classes
	["Warrior_short"] = "Wr",
	["Priest_short"] = "Pr",
	["Mage_short"] = "Ma",
	["Shaman_short"] = "Sh",
	["Paladin_short"] = "Pa",
	["Warlock_short"] = "Wl",
	["Druid_short"] = "Dr",
	["Rogue_short"] = "Ro",
	["Hunter_short"] = "Hu",

	["Player"] = PLAYER,
	["Target"] = TARGET,
	["Focus-target"] = FOCUS,
	["Mouse-over"] = "Mouse-over",
	["%s's pet"] = "%s's pet",
	["%s's target"] = "%s's target",
	["Party member #%d"] = "Party member #%d",
	["Raid member #%d"] = "Raid member #%d",

	["Friend"] = "Friend",
	["Enemy"] = "Enemy",

	-- classifications
	["Rare"] = ITEM_QUALITY3_DESC,
	["Rare-Elite"] = ITEM_QUALITY3_DESC .. "-" .. ELITE,
	["Elite"] = ELITE,
	["Boss"] = BOSS,
	-- short classifications
	["Rare_short"] = "r",
	["Rare-Elite_short"] = "r+",
	["Elite_short"] = "+",
	["Boss_short"] = "b",

	["Feigned Death"] = "Feigned Death",
	["Stealthed"] = "Stealthed",
	["Soulstoned"] = "Soulstoned",

	["Dead"] = DEAD,
	["Ghost"] = "Ghost",
	["Offline"] = PLAYER_OFFLINE,
	["Online"] = "Online",
	["Combat"] = "Combat",
	["Resting"] = "Resting",
	["Tapped"] = "Tapped",
	["AFK"] = "AFK",
	["DND"] = "DND",

	["True"] = "True",

	["Rage"] = RAGE,
	["Focus"] = FOCUS,
	["Energy"] = ENERGY,
	["Mana"] = MANA,

	["PvP"] = PVP,
	["FFA"] = "FFA",

	-- genders
	["Male"] = MALE,
	["Female"] = FEMALE,

	-- forms
	["Bear"] = "Bear",
	["Cat"] = "Cat",
	["Moonkin"] = "Moonkin",
	["Aquatic"] = "Aquatic",
	["Flight"] = "Flight",
	["Travel"] = "Travel",
	["Tree"] = "Tree",

	["Bear_short"] = "Be",
	["Cat_short"] = "Ca",
	["Moonkin_short"] = "Mk",
	["Aquatic_short"] = "Aq",
	["Flight_short"] = "Fl",
	["Travel_short"] = "Tv",
	["Tree_short"] = "Tr",

	-- shortgenders
	["Male_short"] = "m",
	["Female_short"] = "f",

	["Leader"] = "Leader",

	-- spell trees
	["Hybrid"] = "Hybrid", -- for all 3 trees
	["Druid_Tree_1"] = "Balance",
	["Druid_Tree_2"] = "Feral Combat",
	["Druid_Tree_3"] = "Restoration",
	["Hunter_Tree_1"] = "Beast Mastery",
	["Hunter_Tree_2"] = "Marksmanship",
	["Hunter_Tree_3"] = "Survival",
	["Mage_Tree_1"] = "Arcane",
	["Mage_Tree_2"] = "Fire",
	["Mage_Tree_3"] = "Frost",
	["Paladin_Tree_1"] = "Holy",
	["Paladin_Tree_2"] = "Protection",
	["Paladin_Tree_3"] = "Retribution",
	["Priest_Tree_1"] = "Discipline",
	["Priest_Tree_2"] = "Holy",
	["Priest_Tree_3"] = "Shadow",
	["Rogue_Tree_1"] = "Assassination",
	["Rogue_Tree_2"] = "Combat",
	["Rogue_Tree_3"] = "Subtlety",
	["Shaman_Tree_1"] = "Elemental",
	["Shaman_Tree_2"] = "Enhancement",
	["Shaman_Tree_3"] = "Restoration",
	["Warrior_Tree_1"] = "Arms",
	["Warrior_Tree_2"] = "Fury",
	["Warrior_Tree_3"] = "Protection",
	["Warlock_Tree_1"] = "Affliction",
	["Warlock_Tree_2"] = "Demonology",
	["Warlock_Tree_3"] = "Destruction",
}
for k,v in pairs(L) do
	if type(v) ~= "string" then -- some evil addon messed it up
		L[k] = k
	end
end

-- alter L here
if GetLocale() == "deDE" then
	-- races
	L["Blood Elf"] = "Blutelf"
	L["Dwarf"] = "Zwerg"
	L["Gnome"] = "Gnom"
	L["Human"] = "Mensch"
	L["Night Elf"] = "Nachtelf"
	L["Undead"] = "Untoter"

	-- classes
	L["Warrior"] = "Krieger"
	L["Priest"] = "Priester"
	L["Mage"] = "Magier"
	L["Shaman"] = "Schamane"
	L["Warlock"] = "Hexenmeister"
	L["Druid"] = "Druide"
	L["Rogue"] = "Schurke"
	L["Hunter"] = "J\195\164ger"

	-- short classes
	L["Warrior_short"] = "Kr"
	L["Warlock_short"] = "He"
	L["Hunter_short"] = "J\195\164"

	L["%s's pet"] = "%s's Begleiter"
	L["%s's target"] = "%s's Ziel"
	L["Party member #%d"] = "Party Mitglied #%d"
	L["Raid member #%d"] = "Schlachtzug #%d"

	L["Friend"] = "Freund"
	L["Enemy"] = "Feind"

	L["Feigned Death"] = "Totgestellt"
	L["Stealthed"] = "Verstohlen"
	L["Soulstoned"] = "Seelenstein"

	L["Ghost"] = "Geist"
	L["Online"] = "Online"
	L["Combat"] = "Kampf"
	L["Resting"] = "Ausgeruht"
	L["Tapped"] = "angezapft"

	-- forms
	L["Bear"] = "B\195\164r"
	L["Cat"] = "Katze"
	L["Moonkin"] = "Mondkin"
	L["Aquatic"] = "Wasser"
	L["Flight"] = "Flug"
	L["Travel"] = "Reise"
	L["Tree"] = "Baum"

	L["Bear_short"] = "B\195\164"
	L["Cat_short"] = "Ka"
	L["Moonkin_short"] = "Mk"
	L["Aquatic_short"] = "Wa"
	L["Flight_short"] = "Fl"
	L["Travel_short"] = "Re"
	L["Tree_short"] = "Ba"

	-- shortgenders
	L["Male_short"] = "m"
	L["Female_short"] = "w"

	L["Leader"] = "Leiter"

	-- spell trees
	L["Hybrid"] = "Hybride"
	L["Druid_Tree_1"] = "Gleichgewicht"
	L["Druid_Tree_2"] = "Wilder Kampf"
	L["Druid_Tree_3"] = "Wiederherstellung"
	L["Hunter_Tree_1"] = "Tierherrschaft"
	L["Hunter_Tree_2"] = "Treffsicherheit"
	L["Hunter_Tree_3"] = "Überleben"
	L["Mage_Tree_1"] = "Arkan"
	L["Mage_Tree_2"] = "Feuer"
	L["Paladin_Tree_1"] = "Heilig"
	L["Paladin_Tree_2"] = "Schutz"
	L["Paladin_Tree_3"] = "Vergeltung"
	L["Priest_Tree_1"] = "Disziplin"
	L["Priest_Tree_2"] = "Heilig"
	L["Priest_Tree_3"] = "Schatten"
	L["Rogue_Tree_1"] = "Meucheln"
	L["Rogue_Tree_2"] = "Kampf"
	L["Rogue_Tree_3"] = "T\195\164uschung"
	L["Shaman_Tree_1"] = "Elementar"
	L["Shaman_Tree_2"] = "Verst\195\164rkung"
	L["Shaman_Tree_3"] = "Wiederherstellung"
	L["Warrior_Tree_1"] = "Waffen"
	L["Warrior_Tree_2"] = "Furor"
	L["Warrior_Tree_3"] = "Schutz"
	L["Warlock_Tree_1"] = "Gebrechen"
	L["Warlock_Tree_2"] = "D\195\164monologie"
	L["Warlock_Tree_3"] = "Zerstörung"

elseif GetLocale() == "koKR" then
	-- races
	L["Blood Elf"] = "블러드 엘프"
	L["Draenei"] = "드레나이"
	L["Dwarf"] = "드워프"
	L["Gnome"] = "노움"
	L["Human"] = "인간"
	L["Night Elf"] = "나이트 엘프"
	L["Orc"] = "오크"
	L["Tauren"] = "타우렌"
	L["Troll"] = "트롤"
	L["Undead"] = "언데드"

	-- short races
	L["Blood Elf_short"] = "블엘"
	L["Draenei_short"] = "드레"
	L["Dwarf_short"] = "드웝"
	L["Gnome_short"] = "놈"
	L["Human_short"] = "인간"
	L["Night Elf_short"] = "나엘"
	L["Orc_short"] = "오크"
	L["Tauren_short"] = "타렌"
	L["Troll_short"] = "트롤"
	L["Undead_short"] = "언데"

	-- classes
	L["Warrior"] = "전사"
	L["Priest"] = "사제"
	L["Mage"] = "마법사"
	L["Shaman"] = "주술사"
	L["Paladin"] = "성기사"
	L["Warlock"] = "흑마법사"
	L["Druid"] = "드루이드"
	L["Rogue"] = "도적"
	L["Hunter"] = "사냥꾼"

	-- short classes
	L["Warrior_short"] = "전"
	L["Priest_short"] = "사"
	L["Mage_short"] = "마"
	L["Shaman_short"] = "주"
	L["Paladin_short"] = "성"
	L["Warlock_short"] = "흑"
	L["Druid_short"] = "드"
	L["Rogue_short"] = "도"
	L["Hunter_short"] = "냥"

	L["Focus-target"] = "주시 대상"
	L["Mouse-over"] = "마우스-오버"
	L["%s's pet"] = "%s의 소환수"
	L["%s's target"] = "%s의 대상"
	L["Party member #%d"] = "파티원 #%d"
	L["Raid member #%d"] = "공격대원 #%d"

	L["Friend"] = "아군"
	L["Enemy"] = "적군"


	L["Rare_short"] = "희"
	L["Rare-Elite_short"] = "희+"
	L["Elite_short"] = "+"
	L["Boss_short"] = "보"

	L["Feigned Death"] = "죽은척하기" -- must match aura
	L["Stealthed"] = "은신중"
	L["Soulstoned"] = "영혼석 보관"

	L["Ghost"] = "유령"
	L["Online"] = "접속중"
	L["Combat"] = "전투중"
	L["Resting"] = "휴식중"
	L["Tapped"] = "선점"
	L["AFK"] = "자리비움"
	L["DND"] = "다른용무중"

	L["True"] = "True" -- check

	L["PvP"] = "전쟁" -- PVP,
	L["FFA"] = "전투 지역"

	-- forms
	L["Bear"] = "곰"
	L["Cat"] = "표범"
	L["Moonkin"] = "달빛야수"
	L["Aquatic"] = "바다표범"
	L["Flight"] = "폭풍까마귀"
	L["Travel"] = "치타"
	L["Tree"] = "나무"

	L["Bear_short"] = "곰"
	L["Cat_short"] = "표범"
	L["Moonkin_short"] = "달빛"
	L["Aquatic_short"] = "바표"
	L["Flight_short"] = "폭까"
	L["Travel_short"] = "치타"
	L["Tree_short"] = "나무"

	-- shortgenders
	L["Male_short"] = "남"
	L["Female_short"] = "여"
	L["Leader"] = "지휘관"

	-- spell trees
	L["Hybrid"] = "하이브리드" -- for all 3 trees
	L["Druid_Tree_1"] = "조화"
	L["Druid_Tree_2"] = "야성"
	L["Druid_Tree_3"] = "회복"
	L["Hunter_Tree_1"] = "야수"
	L["Hunter_Tree_2"] = "사격"
	L["Hunter_Tree_3"] = "생존"
	L["Mage_Tree_1"] = "비전"
	L["Mage_Tree_2"] = "화염"
	L["Mage_Tree_3"] = "냉기"
	L["Paladin_Tree_1"] = "신성"
	L["Paladin_Tree_2"] = "보호"
	L["Paladin_Tree_3"] = "징벌"
	L["Priest_Tree_1"] = "수양"
	L["Priest_Tree_2"] = "신성"
	L["Priest_Tree_3"] = "암흑"
	L["Rogue_Tree_1"] = "암살"
	L["Rogue_Tree_2"] = "전투"
	L["Rogue_Tree_3"] = "잠행"
	L["Shaman_Tree_1"] = "정기"
	L["Shaman_Tree_2"] = "고양"
	L["Shaman_Tree_3"] = "복원"
	L["Warrior_Tree_1"] = "무기"
	L["Warrior_Tree_2"] = "분노"
	L["Warrior_Tree_3"] = "방어"
	L["Warlock_Tree_1"] = "고통"
	L["Warlock_Tree_2"] = "악마"
	L["Warlock_Tree_3"] = "파괴"
elseif GetLocale() == "frFR" then
	-- races
	L["Blood Elf"] = "Elfe de sang"
	L["Draenei"] = "Draeneï"
	L["Dwarf"] = "Nain"
	L["Gnome"] = "Gnome"
	L["Human"] = "Humain"
	L["Night Elf"] = "Elfe de la nuit"
	L["Orc"] = "Orc"
	L["Tauren"] = "Tauren"
	L["Troll"] = "Troll"
	L["Undead"] = "Mort-vivant"

	-- short races
	L["Blood Elf_short"] = "ES"
	L["Draenei_short"] = "Dr"
	L["Dwarf_short"] = "Na"
	L["Gnome_short"] = "Gn"
	L["Human_short"] = "Hu"
	L["Night Elf_short"] = "EN"
	L["Orc_short"] = "Or"
	L["Tauren_short"] = "Ta"
	L["Troll_short"] = "Tr"
	L["Undead_short"] = "MV"

	-- classes
	L["Warrior"] = "Guerrier"
	L["Priest"] = "Prêtre"
	L["Mage"] = "Mage"
	L["Shaman"] = "Chaman"
	L["Paladin"] = "Paladin"
	L["Warlock"] = "Démoniste"
	L["Druid"] = "Druide"
	L["Rogue"] = "Voleur"
	L["Hunter"] = "Chasseur"

	-- short classes
	L["Warrior_short"] = "Gu"
	L["Priest_short"] = "Pr"
	L["Mage_short"] = "Ma"
	L["Shaman_short"] = "Ch"
	L["Paladin_short"] = "Pa"
	L["Warlock_short"] = "Dé"
	L["Druid_short"] = "Dr"
	L["Rogue_short"] = "Vo"
	L["Hunter_short"] = "Ch"

	L["Player"] = PLAYER
	L["Target"] = TARGET
	L["Focus-target"] = FOCUS
	L["Mouse-over"] = "Sous la souris"
	L["%s's pet"] = "Familier de %s"
	L["%s's target"] = "Cible de %s"
	L["Party member #%d"] = "Membre du groupe #%d"
	L["Raid member #%d"] = "Membre du raid #%d"

	L["Friend"] = "Ami"
	L["Enemy"] = "Ennemi"

	-- classifications
	L["Rare"] = ITEM_QUALITY3_DESC
	L["Rare-Elite"] = ELITE .. "-" .. ITEM_QUALITY3_DESC
	L["Elite"] = ELITE
	L["Boss"] = BOSS
	-- short classifications
	L["Rare_short"] = "r"
	L["Rare-Elite_short"] = "r+"
	L["Elite_short"] = "+"
	L["Boss_short"] = "b"

	L["Feigned Death"] = "Feint la mort"
	L["Stealthed"] = "Camouflé"
	L["Soulstoned"] = "Âme conservée"

	L["Dead"] = DEAD
	L["Ghost"] = "Fantôme"
	L["Offline"] = PLAYER_OFFLINE
	L["Online"] = "En ligne"
	L["Combat"] = "Combat"
	L["Resting"] = "Repos"
	L["Tapped"] = "Touché"
	L["AFK"] = "ABS"
	L["DND"] = "NPD"

	L["True"] = "Vrai"

	L["Rage"] = RAGE
	L["Focus"] = FOCUS
	L["Energy"] = ENERGY
	L["Mana"] = MANA

	L["PvP"] = PVP
	L["FFA"] = "FFA"

	-- genders
	L["Male"] = MALE
	L["Female"] = FEMALE

	-- forms
	L["Bear"] = "Ours"
	L["Cat"] = "Félin"
	L["Moonkin"] = "Sélénien"
	L["Aquatic"] = "Aquatique"
	L["Flight"] = "Vol"
	L["Travel"] = "Voyage"
	L["Tree"] = "Arbre"

	L["Bear_short"] = "Ou"
	L["Cat_short"] = "Fé"
	L["Moonkin_short"] = "Sé"
	L["Aquatic_short"] = "Aq"
	L["Flight_short"] = "Vo"
	L["Travel_short"] = "Vy"
	L["Tree_short"] = "Ar"

	-- shortgenders
	L["Male_short"] = "h"
	L["Female_short"] = "f"

	L["Leader"] = "Chef"

	-- spell trees
	L["Hybrid"] = "Hybride" -- for all 3 trees
	L["Druid_Tree_1"] = "Equilibre"
	L["Druid_Tree_2"] = "Combat farouche"
	L["Druid_Tree_3"] = "Restauration"
	L["Hunter_Tree_1"] = "Maîtrise des bêtes"
	L["Hunter_Tree_2"] = "Précision"
	L["Hunter_Tree_3"] = "Survie"
	L["Mage_Tree_1"] = "Arcane"
	L["Mage_Tree_2"] = "Feu"
	L["Mage_Tree_3"] = "Givre"
	L["Paladin_Tree_1"] = "Sacré"
	L["Paladin_Tree_2"] = "Protection"
	L["Paladin_Tree_3"] = "Vindicte"
	L["Priest_Tree_1"] = "Discipline"
	L["Priest_Tree_2"] = "Sacré"
	L["Priest_Tree_3"] = "Ombre"
	L["Rogue_Tree_1"] = "Assassinat"
	L["Rogue_Tree_2"] = "Combat"
	L["Rogue_Tree_3"] = "Finesse"
	L["Shaman_Tree_1"] = "Elémentaire"
	L["Shaman_Tree_2"] = "Amélioration"
	L["Shaman_Tree_3"] = "Restauration"
	L["Warrior_Tree_1"] = "Armes"
	L["Warrior_Tree_2"] = "Fureur"
	L["Warrior_Tree_3"] = "Protection"
	L["Warlock_Tree_1"] = "Affliction"
	L["Warlock_Tree_2"] = "Démonologie"
	L["Warlock_Tree_3"] = "Destruction"
elseif GetLocale() == "zhTW" then
	-- races
	L["Blood Elf"] = "血精靈"
	L["Draenei"] = "德萊尼"
	L["Dwarf"] = "矮人"
	L["Gnome"] = "地精"
	L["Human"] = "人類"
	L["Night Elf"] = "夜精靈"
	L["Orc"] = "獸人"
	L["Tauren"] = "牛頭人"
	L["Troll"] = "食人妖"
	L["Undead"] = "不死族"

	-- short races
	L["Blood Elf_short"] = "血"
	L["Draenei_short"] = "萊"
	L["Dwarf_short"] = "矮"
	L["Gnome_short"] = "地"
	L["Human_short"] = "人"
	L["Night Elf_short"] = "夜"
	L["Orc_short"] = "獸"
	L["Tauren_short"] = "牛"
	L["Troll_short"] = "食"
	L["Undead_short"] = "不"

	-- classes
	L["Warrior"] = "戰士"
	L["Priest"] = "牧師"
	L["Mage"] = "法師"
	L["Shaman"] = "薩滿"
	L["Paladin"] = "聖騎士"
	L["Warlock"] = "術士"
	L["Druid"] = "德魯伊"
	L["Rogue"] = "盜賊"
	L["Hunter"] = "獵人"

	-- short classes
	L["Warrior_short"] = "戰"
	L["Priest_short"] = "牧"
	L["Mage_short"] = "法"
	L["Shaman_short"] = "薩"
	L["Paladin_short"] = "聖"
	L["Warlock_short"] = "術"
	L["Druid_short"] = "德"
	L["Rogue_short"] = "賊"
	L["Hunter_short"] = "獵"

	L["Player"] = PLAYER
	L["Target"] = TARGET
	L["Focus-target"] = FOCUSTARGET
	L["Mouse-over"] = "滑鼠目標"
	L["%s's pet"] = "%s的寵物"
	L["%s's target"] = "%s的目標"
	L["Party member #%d"] = "隊伍成員#%d"
	L["Raid member #%d"] = "團隊成員#%d"

	L["Friend"] = "友方"
	L["Enemy"] = "敵方"

	-- classifications
	L["Rare"] = "稀有"
	L["Rare-Elite"] = "稀有" .. "-" .. ELITE
	L["Elite"] = ELITE
	L["Boss"] = BOSS
	-- short classifications
	L["Rare_short"] = "稀"
	L["Rare-Elite_short"] = "稀+"
	L["Elite_short"] = "+"
	L["Boss_short"] = "首"

	L["Feigned Death"] = "假死"
	L["Stealthed"] = "潛行"
	L["Soulstoned"] = "靈魂被保存"

	L["Dead"] = DEAD
	L["Ghost"] = "鬼魂"
	L["Offline"] = PLAYER_OFFLINE
	L["Online"] = "上線"
	L["Combat"] = "戰鬥"
	L["Resting"] = "休息"
	L["Tapped"] = "選取"
	L["AFK"] = "暫離"
	L["DND"] = "勿擾"

	L["True"] = "真"

	L["Rage"] = RAGE
	L["Focus"] = FOCUS
	L["Energy"] = ENERGY
	L["Mana"] = MANA

	L["PvP"] = PVP
	L["FFA"] = PVPFFA

	-- genders
	L["Male"] = MALE
	L["Female"] = FEMALE

	-- forms
	L["Bear"] = "熊"
	L["Cat"] = "獵豹"
	L["Moonkin"] = "梟獸"
	L["Aquatic"] = "水棲"
	L["Flight"] = "飛行"
	L["Travel"] = "旅行"
	L["Tree"] = "樹"

	L["Bear_short"] = "熊"
	L["Cat_short"] = "豹"
	L["Moonkin_short"] = "梟"
	L["Aquatic_short"] = "水"
	L["Flight_short"] = "飛"
	L["Travel_short"] = "旅"
	L["Tree_short"] = "樹"

	-- shortgenders
	L["Male_short"] = "男"
	L["Female_short"] = "女"

	L["Leader"] = "隊長"

	-- spell trees
	L["Hybrid"] = "混合" -- for all 3 trees
	L["Druid_Tree_1"] = "平衡"
	L["Druid_Tree_2"] = "野性戰鬥"
	L["Druid_Tree_3"] = "恢復"
	L["Hunter_Tree_1"] = "野獸控制"
	L["Hunter_Tree_2"] = "射擊"
	L["Hunter_Tree_3"] = "生存"
	L["Mage_Tree_1"] = "秘法"
	L["Mage_Tree_2"] = "火焰"
	L["Mage_Tree_3"] = "冰霜"
	L["Paladin_Tree_1"] = "神聖"
	L["Paladin_Tree_2"] = "防護"
	L["Paladin_Tree_3"] = "懲戒"
	L["Priest_Tree_1"] = "戒律"
	L["Priest_Tree_2"] = "神聖"
	L["Priest_Tree_3"] = "暗影"
	L["Rogue_Tree_1"] = "刺殺"
	L["Rogue_Tree_2"] = "戰鬥"
	L["Rogue_Tree_3"] = "敏銳"
	L["Shaman_Tree_1"] = "元素"
	L["Shaman_Tree_2"] = "增強"
	L["Shaman_Tree_3"] = "恢復"
	L["Warrior_Tree_1"] = "武器"
	L["Warrior_Tree_2"] = "狂怒"
	L["Warrior_Tree_3"] = "防護"
	L["Warlock_Tree_1"] = "痛苦"
	L["Warlock_Tree_2"] = "惡魔學識"
	L["Warlock_Tree_3"] = "毀滅"

--***************************************
-- zhCN Chinese Simplify
-- 2007/09/19 CN3羽月 雪夜之狼
-- 请保留本翻译作者名 谢谢
-- E=mail:xionglingfeng@Gmail.com
-- Website:http://www.wowtigu.org  (Chs)
--***************************************
elseif GetLocale() == "zhCN" then
	-- races
	L["Blood Elf"] = "血精灵"
	L["Draenei"] = "德莱尼"
	L["Dwarf"] = "矮人"
	L["Gnome"] = "侏儒"
	L["Human"] = "人类"
	L["Night Elf"] = "暗夜精灵"
	L["Orc"] = "兽人"
	L["Tauren"] = "牛头人"
	L["Troll"] = "巨魔"
	L["Undead"] = "亡灵"

	-- short races
	L["Blood Elf_short"] = "血"
	L["Draenei_short"] = "德"
	L["Dwarf_short"] = "矮"
	L["Gnome_short"] = "侏"
	L["Human_short"] = "人"
	L["Night Elf_short"] = "暗"
	L["Orc_short"] = "兽"
	L["Tauren_short"] = "牛"
	L["Troll_short"] = "巨"
	L["Undead_short"] = "亡"

	-- classes
	L["Warrior"] = "战士"
	L["Priest"] = "牧师"
	L["Mage"] = "法师"
	L["Shaman"] = "萨满祭司"
	L["Paladin"] = "圣骑士"
	L["Warlock"] = "术士"
	L["Druid"] = "德鲁伊"
	L["Rogue"] = "潜行者"
	L["Hunter"] = "猎人"

	-- short classes
	L["Warrior_short"] = "战"
	L["Priest_short"] = "牧"
	L["Mage_short"] = "法"
	L["Shaman_short"] = "萨"
	L["Paladin_short"] = "圣"
	L["Warlock_short"] = "术"
	L["Druid_short"] = "德"
	L["Rogue_short"] = "贼"
	L["Hunter_short"] = "猎"

	L["Player"] = "玩家"
	L["Target"] = "目标"
	L["Focus-target"] = "焦点目标"
	L["Mouse-over"] = "鼠标目标"
	L["%s's pet"] = "%s的宠物"
	L["%s's target"] = "%s的目标"
	L["Party member #%d"] = "队伍成员#%d"
	L["Raid member #%d"] = "团队成员#%d"

	L["Friend"] = "友方"
	L["Enemy"] = "敌方"

	-- classifications
	L["Rare"] = "稀有"
	L["Rare-Elite"] = "稀有" .. "-" .. ELITE
	L["Elite"] = "精英"
	L["Boss"] = "Boss"
	-- short classifications
	L["Rare_short"] = "稀"
	L["Rare-Elite_short"] = "稀+"
	L["Elite_short"] = "+"
	L["Boss_short"] = "首"

	L["Feigned Death"] = "假死"
	L["Stealthed"] = "潜行"
	L["Soulstoned"] = "灵魂已保存"

	L["Dead"] = "死亡"
	L["Ghost"] = "鬼魂"
	L["Offline"] = "离线"
	L["Online"] = "上线"
	L["Combat"] = "战斗"
	L["Resting"] = "休息"
	L["Tapped"] = "选取"
	L["AFK"] = "暂离"
	L["DND"] = "勿扰"

	L["True"] = "真"

	L["Rage"] = RAGE
	L["Focus"] = "焦点"
	L["Energy"] = "能量"
	L["Mana"] = "魔法值"

	L["PvP"] = PVP
	L["FFA"] = PVPFFA

	-- genders
	L["Male"] = "男"
	L["Female"] = "女"

	-- forms
	L["Bear"] = "熊"
	L["Cat"] = "猎豹"
	L["Moonkin"] = "枭兽"
	L["Aquatic"] = "水栖"
	L["Flight"] = "飞行"
	L["Travel"] = "旅行"
	L["Tree"] = "树"

	L["Bear_short"] = "熊"
	L["Cat_short"] = "豹"
	L["Moonkin_short"] = "枭"
	L["Aquatic_short"] = "水"
	L["Flight_short"] = "飞"
	L["Travel_short"] = "旅"
	L["Tree_short"] = "树"

	-- shortgenders
	L["Male_short"] = "男"
	L["Female_short"] = "女"

	L["Leader"] = "队长"

	-- spell trees
	L["Hybrid"] = "Hybrid" -- for all 3 trees
	L["Druid_Tree_1"] = "平衡"
	L["Druid_Tree_2"] = "野性战斗"
	L["Druid_Tree_3"] = "恢复"
	L["Hunter_Tree_1"] = "野兽掌握"
	L["Hunter_Tree_2"] = "射击"
	L["Hunter_Tree_3"] = "生存"
	L["Mage_Tree_1"] = "奥术"
	L["Mage_Tree_2"] = "火焰"
	L["Mage_Tree_3"] = "冰霜"
	L["Paladin_Tree_1"] = "神圣"
	L["Paladin_Tree_2"] = "防护"
	L["Paladin_Tree_3"] = "惩戒"
	L["Priest_Tree_1"] = "戒律"
	L["Priest_Tree_2"] = "神圣"
	L["Priest_Tree_3"] = "暗影"
	L["Rogue_Tree_1"] = "刺杀"
	L["Rogue_Tree_2"] = "战斗"
	L["Rogue_Tree_3"] = "敏锐"
	L["Shaman_Tree_1"] = "元素战斗"
	L["Shaman_Tree_2"] = "增强"
	L["Shaman_Tree_3"] = "恢复"
	L["Warrior_Tree_1"] = "武器"
	L["Warrior_Tree_2"] = "狂怒"
	L["Warrior_Tree_3"] = "防御"
	L["Warlock_Tree_1"] = "痛苦"
	L["Warlock_Tree_2"] = "恶魔学识"
	L["Warlock_Tree_3"] = "毁灭"
end

setmetatable(L, {__index = function(self, key)
	local _, ret = pcall(error, ("Error indexing L[%q]"):format(tostring(key)), 2)
	geterrorhandler()(ret)
	self[key] = key
	return key
end})

local MobHealth_PPP = MobHealth_PPP
local MobHealth3 = MobHealth3
local AceLibrary = AceLibrary
local BabbleSpell = AceLibrary and AceLibrary:HasInstance("Babble-Spell-2.2") and AceLibrary("Babble-Spell-2.2")
local Threat = AceLibrary and AceLibrary:HasInstance("Threat-1.0") and AceLibrary("Threat-1.0")
local RangeCheck = AceLibrary and AceLibrary:HasInstance("RangeCheck-1.0") and AceLibrary("RangeCheck-1.0")

local _G = _G
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UNKNOWN = UNKNOWN or "Unknown"
local unpack = unpack
local pcall = pcall
local select = select
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitIsFriend = UnitIsFriend
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty
local UnitExists = UnitExists
local UnitIsVisible = UnitIsVisible
local UnitIsPlayer = UnitIsPlayer
local UnitPlayerControlled = UnitPlayerControlled
local time = time
local UnitName = UnitName
local rawget = rawget
local pairs = pairs
local ipairs = ipairs
local next = next
local setmetatable = setmetatable
local type = type
local assert = assert
local tonumber = tonumber
local tostring = tostring
local string_gsub = string.gsub
local math_floor = math.floor
local table_sort = table.sort
local table_concat = table.concat
local error = error
local loadstring = loadstring
local GetTime = GetTime
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo

local newList, newDict, newSet, del
do
	local pool = {}
	function newList(...)
		local t = next(pool)
		if t then
			pool[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
		else
			t = { ... }
		end
		return t
	end
	function newDict(...)
		local t = next(pool)
		if t then
			pool[t] = nil
		else
			t = {}
		end
		for i = 1, select('#', ...), 2 do
			t[select(i, ...)] = select(i+1, ...)
		end
		return t
	end
	function newSet(...)
		local t = next(pool)
		if t then
			pool[t] = nil
		else
			t = {}
		end
		for i = 1, select('#', ...) do
			t[select(i, ...)] = true
		end
		return t
	end
	function del(t)
		if not t then
			error("Bad argument #1 to `del'. Expected table, got nil.", 2)
		end
		pool[t] = true
		for k in pairs(t) do
			t[k] = nil
		end
		t[''] = true
		t[''] = nil
		return nil
	end
end

local precondition, postcondition, argCheck
if Rock then
	precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")
else
	precondition, postcondition, argCheck = function() end, function() end, function() end
end

local colors = {}
for class, data in pairs(RAID_CLASS_COLORS) do
	colors[class] = { data.r, data.g, data.b, }
end
colors.unknown = { 0.8, 0.8, 0.8 }
colors.hostile = { 226/255, 45/255, 75/255 }
colors.neutral = { 1, 1, 34/255 }
colors.friendly = { 0.2, 0.8, 0.15 }
colors.civilian = { 48/255, 113/255, 191/255 }
colors.tapped = { 0.5, 0.5, 0.5 }
colors.dead = { 0.6, 0.6, 0.6 }
colors.disconnected = { 0.7, 0.7, 0.7 }
colors.inCombat = { 1, 0, 0 }
colors.petHappy = { 0, 1, 0 }
colors.petNeutral = { 1, 1, 0 }
colors.petAngry = { 1, 0, 0 }
colors.rage = { 226/255, 45/255, 75/255 }
colors.energy = { 1, 220/255, 25/255 }
colors.focus = { 1, 210/255, 0 }
colors.mana = { 48/255, 113/255, 191/255 }
colors.minHP = { 1, 0, 0 }
colors.midHP = { 1, 1, 0 }
colors.maxHP = { 0, 1, 0 }

local lastMouseFocus

local IsLegitimateUnit = {player=true,pet=true,target=true,focus=true,mouseover=true}
for i = 1, 4 do
	IsLegitimateUnit['party' .. i] = true
	IsLegitimateUnit['partypet' .. i] = true
end
for i = 1, 40 do
	IsLegitimateUnit['raid' .. i] = true
	IsLegitimateUnit['raidpet' .. i] = true
end
setmetatable(IsLegitimateUnit, {__index=function(self, unit)
	if type(unit) ~= "string" then
		return false
	end
	if not unit:find("target$") then
		self[unit] = false
		return false
	end
	local nonTarget = unit:sub(1, -7)
	local good = self[nonTarget]
	self[unit] = good
	return good
end})

local currentAuras, currentDebuffTypes
local function func(self, unit)
	local t = newList()
	local u = newList()
	for i = 1, 40 do
		local name = UnitBuff(unit, i)
		if not name then
			break
		end
		t[name] = true
	end
	local isFriend = UnitIsFriend("player", unit)
	for i = 1, 40 do
		local name, _, _, _, dispelType = UnitDebuff(unit, i)
		if not name then
			break
		end
		t[name] = true
		if isFriend and dispelType then
			u[dispelType] = true
		end
	end
	currentAuras[unit] = t
	currentDebuffTypes[unit] = u
	return self[unit]
end
local x = {__index=func}
currentAuras = setmetatable({},x)
currentDebuffTypes = setmetatable({},x)
x = nil

local guildNotes, officerNotes
local function refreshGuildNotes(auto)
	if auto and getmetatable(guildNotes) then
		return
	end
	for k in pairs(guildNotes) do
		guildNotes[k] = nil
	end
	for k in pairs(officerNotes) do
		officerNotes[k] = nil
	end
	if not IsInGuild() then
		return nil
	end
	for i = 1, GetNumGuildMembers(true) do
		local name, _, _, _, _, _, note, officernote = GetGuildRosterInfo(i)
		guildNotes[name] = note
		officerNotes[name] = officernote
	end
end
local x = {__index=function(self, name)
	refreshGuildNotes()
	setmetatable(guildNotes, nil)
	setmetatable(officerNotes, nil)
	return self[name]
end}
guildNotes = setmetatable({},x)
officerNotes = setmetatable({},x)

local tt = CreateFrame("GameTooltip")
local UIParent = UIParent
tt:SetOwner(UIParent, "ANCHOR_NONE")
tt.left = {}
tt.right = {}
for i=1,30 do
	tt.left[i] = tt:CreateFontString()
	tt.left[i]:SetFontObject(GameFontNormal)
	tt.right[i] = tt:CreateFontString()
	tt.right[i]:SetFontObject(GameFontNormal)
	tt:AddFontStrings(tt.left[i], tt.right[i])
end
local nextTime = 0
local lastName
local lastUnit
local function updateTT(unit)
	local name = UnitName(unit)
	local time = GetTime()
	if lastUnit == unit and lastName == name and nextTime < time then
		return
	end
	lastUnit = unit
	lastName = name
	nextTime = time + 1
	tt:ClearLines()
	tt:SetUnit(unit)
	if not tt:IsOwned(UIParent) then
		tt:SetOwner(UIParent, "ANCHOR_NONE")
	end
end

local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local function FigureNPCGuild(unit)
	updateTT(unit)
	local left_2 = tt.left[2]:GetText()
	if not left_2 or left_2:find(LEVEL_start) then
		return nil
	end
	return left_2
end

local factionList = {}

local PVP = type(PVP) == "string" and PVP or "PvP"
local function FigureFaction(unit)
	local _, faction = UnitFactionGroup(unit)
	if UnitPlayerControlled(unit) or UnitIsPlayer(unit) then
		return faction
	end

	updateTT(unit)
	local left_2 = tt.left[2]:GetText()
	local left_3 = tt.left[3]:GetText()
	if not left_2 or not left_3 then
		return faction
	end
	local hasGuild = not left_2:find(LEVEL_start)
	local factionText = not hasGuild and left_3 or tt.left[4]:GetText()
	if factionText == PVP then
		return faction
	end
	if factionList[factionText] or faction then
		return factionText
	end
end

local function FigureZone(unit)
	if UnitIsVisible(unit) then
		return nil
	end
	if not UnitIsConnected(unit) then
		return nil
	end
	updateTT(unit)
	local left_2 = tt.left[2]:GetText()
	local left_3 = tt.left[3]:GetText()
	if not left_2 or not left_3 then
		return nil
	end
	local hasGuild = not left_2:find(LEVEL_start)
	local factionText = not hasGuild and left_3 or tt.left[4]:GetText()
	if factionText == PVP then
		factionText = nil
	end
	local hasFaction = factionText and not UnitPlayerControlled(unit) and not UnitIsPlayer(unit) and (UnitFactionGroup(unit) or factionList[factionText])
	if hasGuild and hasFaction then
		return tt.left[5]:GetText()
	elseif hasGuild or hasFaction then
		return tt.left[4]:GetText()
	else
		return left_3
	end
end

local RockComm

local talentReceptor, talentSpecs, talentSpecNames
local addonVersionReceptor

local mt = {__index = function(self, key)
	talentSpecs[key] = false
	talentSpecNames[key] = false
	if not RockComm then
		RockComm = Rock and Rock("LibRockComm-1.0", false, true)
		if not RockComm then
			return self[key]
		end
		RockComm:AddTalentReceptor(talentReceptor)
		RockComm:AddAddonVersionReceptor(addonVersionReceptor)
	end
	RockComm:QueryTalents("WHISPER", key)
	return self[key]
end}
talentSpecs = setmetatable({}, mt)
talentSpecNames = setmetatable({}, mt)

local mt = {__index = function(self, key)
	self[key] = false
	if not RockComm then
		RockComm = Rock and Rock("LibRockComm-1.0", false, true)
		if not RockComm then
			return self[key]
		end
		RockComm:AddTalentReceptor(talentReceptor)
		RockComm:AddAddonVersionReceptor(addonVersionReceptor)
	end
	RockComm:QueryAddonVersion(self[0], "WHISPER", key)
	return self[key]
end}

local addonVersions = setmetatable({}, {__index = function(self, key)
	local t = setmetatable({ [0] = key }, mt)
	self[key] = t
	return t
end})

local Modifiers; Modifiers = {}
-- when writing modifiers, inputs can be a number or a string. Also, any of these can be returned, as well as nil, which means a blank string.
-- the modifier itself can be in the form of a function or a table containing a function and an event string (or a table of event strings). The events specified will cause the string to update upon that event.
-- note: can take an argument, either nil, a number, a string.
Modifiers.IsEqual = {[[if tostring(value) ~= ${arg:string} then value = nil end]], value = "number;string", arg = "number;string", ret = "same;nil", globals = "tostring"}

Modifiers["~IsEqual"] = {"if tostring(value) == ${arg:string} then value = nil end", value = "number;string", arg = "number;string", ret = "same;nil", globals = "tostring"}

Modifiers.IsLess = {[[do
	local value_num = tonumber(value)
	local arg_num = tonumber(${arg})
	if value_num and arg_num then
		if value_num >= arg_num then
			value = nil
		end
	else
		if tostring(value) >= ${arg:string} then
			value = nil
		end
	end
end]], value = "number;string", arg = "number;string", ret = "same;nil", globals = "tonumber;tostring"}

Modifiers["~IsLess"] = {[[do
	local value_num = tonumber(value)
	local arg_num = tonumber(${arg})
	if value_num and arg_num then
		if value_num < arg_num then
			value = nil
		end
	else
		if tostring(value) >= ${arg:string} then
			value = nil
		end
	end
end]], value = "number;string", arg = "number;string", ret = "same;nil", globals = "tonumber;tostring"}

Modifiers.IsLessEqual = {[[do
	local value_num = tonumber(value)
	local arg_num = tonumber(${arg})
	if value_num and arg_num then
		if value_num > arg_num then
			value = nil
		end
	else
		if tostring(value) > ${arg:string} then
			value = nil
		end
	end
end]], value = "number;string", arg = "number;string", ret = "same;nil", globals = "tonumber;tostring"}

Modifiers["~IsLessEqual"] = {[[do
	local value_num = tonumber(value)
	local arg_num = tonumber(${arg})
	if value_num and arg_num then
		if value_num <= arg_num then
			value = nil
		end
	else
		if tostring(value) <= ${arg:string} then
			value = nil
		end
	end
end]], value = "number;string", arg = "number;string", ret = "same;nil", globals = "tonumber;tostring"}

Modifiers.IsGreater = "~IsLessEqual"
Modifiers.IsGreaterEqual = "~IsLess"
Modifiers.IsNotEqual = "~IsEqual"

Modifiers.Hide = "~IsEqual"
Modifiers.HideLess = "~IsLess"
Modifiers.HideGreater = "~IsGreater"
Modifiers.HideLessEqual = "~IsLessEqual"
Modifiers.HideGreaterEqual = "~IsGreaterEqual"
Modifiers.HideUnless = "~IsNotEqual"
Modifiers.HideZero = "Hide(0)"

Modifiers.Prepend = {"value = ${arg} .. value", value = "number;string", arg = "string", ret = "string"}

Modifiers.Append = {"value = value .. ${arg}", value = "number;string", arg = "string", ret = "string"}

Modifiers.Negate = "Mult(-1)"

Modifiers.Percent = {"value = value .. '%'", value = "number", ret = "string"}

Modifiers.Short = {[[
	if type(value) ~= "number" then
		local a,b = value:match("^(%d+)/(%d+)")
		if a then
			a, b = tonumber(a), tonumber(b)
			if b >= 10000000 then
				b = ("%.1fm"):format(b / 1000000)
			elseif b >= 1000000 then
				b = ("%.2fm"):format(b / 1000000)
			elseif b >= 100000 then
				b = ("%.0fk"):format(b / 1000)
			elseif b >= 10000 then
				b = ("%.1fk"):format(b / 1000)
			end
			if a >= 10000000 then
				a = ("%.1fm"):format(a / 1000000)
			elseif a >= 1000000 then
				a = ("%.2fm"):format(a / 1000000)
			elseif a >= 100000 then
				a = ("%.0fk"):format(a / 1000)
			elseif a >= 10000 then
				a = ("%.1fk"):format(a / 1000)
			end
			value = a.."/"..b
		end
	else
		if value >= 10000000 then
			value = ("%.1fm"):format(value / 1000000)
		elseif value >= 1000000 then
			value = ("%.2fm"):format(value / 1000000)
		elseif value >= 100000 then
			value = ("%.0fk"):format(value / 1000)
		elseif value >= 10000 then
			value = ("%.1fk"):format(value / 1000)
		else
			value = math_floor(value+0.5)
		end
	end
]],	value = "number;string", ret = "same;nil", globals = "math.floor"}

Modifiers.VeryShort = {[[
	if type(value) ~= "number" then
		local a,b = value:match("^(%d+)/(%d+)")
		if a then
			a, b = tonumber(a), tonumber(b)
			if b >= 1000000 then
				b = ("%.0fm"):format(b / 1000000)
			elseif b >= 1000 then
				b = ("%.0fk"):format(b / 1000)
			end
			if a >= 1000000 then
				a = ("%.0fm"):format(a / 1000000)
			elseif a >= 1000 then
				a = ("%.0fk"):format(a / 1000)
			end
			value = a.."/"..b
		end
	else
		if value >= 1000000 then
			value = ("%.0fm"):format(value / 1000000)
		elseif value >= 1000 then
			value = ("%.0fk"):format(value / 1000)
		else
			value = math_floor(value+0.5)
		end
	end
]], value = "number;string", ret = "same;nil", globals = "math.floor"}

Modifiers.Upper = {"value = value:upper()", value = "string", ret = "string"}
Modifiers.Lower = {"value = value:lower()", value = "string", ret = "string"}

Modifiers.Bracket = {"value = '[' .. value .. ']'", value = "number;string", ret = "string"}
Modifiers.Paren = {"value = '(' .. value .. ')'", value = "number;string", ret = "string"}
Modifiers.Angle = {"value = '<' .. value .. '>'", value = "number;string", ret = "string"}
Modifiers.Brace = {"value = '{' .. value .. '}'", value = "number;string", ret = "string"}

Modifiers.Trunc = {[[do
	local len = 0
	for i = 1, ${arg} do
		local b = value:byte(len+1)
		if not b then
			break
		elseif b <= 127 then
			len = len + 1
		elseif b <= 223 then
			len = len + 2
		elseif b <= 239 then
			len = len + 3
		else
			len = len + 4
		end
	end
	value = value:sub(1, len)
end]], arg = "number", value = "string", ret = "string"}

Modifiers.Contains = {"if not value:find(${arg}) then value = nil end", value = "string", arg = "string", ret = "string;nil"}

Modifiers["~Contains"] = {"if value:find(${arg}) then value = nil end", value = "string", arg = "string", ret = "string;nil"}

Modifiers.HideContains = "~Contains"

Modifiers.ShortClass = {([[
	if value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	else
		value = nil
	end]]):format(L["Priest"], L["Priest_short"], L["Mage"], L["Mage_short"], L["Shaman"], L["Shaman_short"], L["Paladin"], L["Paladin_short"], L["Warlock"], L["Warlock_short"], L["Druid"], L["Druid_short"], L["Rogue"], L["Rogue_short"], L["Hunter"], L["Hunter_short"], L["Warrior"], L["Warrior_short"]), ret = "string;nil"}

Modifiers.ShortRace = {([[
	if value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	else
		value = nil
	end]]):format(L["Blood Elf"], L["Blood Elf_short"], L["Draenei"], L["Draenei_short"], L["Dwarf"], L["Dwarf_short"], L["Gnome"], L["Gnome_short"], L["Human"], L["Human_short"], L["Night Elf"], L["Night Elf_short"], L["Orc"], L["Orc_short"], L["Tauren"], L["Tauren_short"], L["Troll"], L["Troll_short"], L["Undead"], L["Undead_short"]), ret = "string;nil" }

Modifiers.ShortDruidForm = {([[
	if value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	elseif value == %q then
		value = %q
	else
		value = nil
	end]]):format(L["Bear"], L["Bear_short"], L["Cat"], L["Cat_short"], L["Moonkin"], L["Moonkin_short"], L["Aquatic"], L["Aquatic_short"], L["Flight"], L["Flight_short"], L["Travel"], L["Travel_short"], L["Tree"], L["Tree_short"]), ret = "string;nil" }

Modifiers.RepColor = {function(data)
	return [[do
		local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
		if not repname then
		]] .. (data.isMod and [[
			value = "|r" .. value
		]] or [[
			value = "|r"
		]]) .. [[
		else
			local info = FACTION_BAR_COLORS[repreaction]
		]] .. (data.isMod and [[
			value = ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, value)
		]] or [[
			value = ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
		]]) .. [[
		end
	end]]
end, events = "Reputation", globals = "GetWatchedFactionInfo;FACTION_BAR_COLORS"}

Modifiers.StatusColor = {function(data)
	return [[do
		local r,g,b
		if not UnitIsConnected(${unit}) then
			r,g,b = unpack(colors.disconnected)
		elseif UnitIsDeadOrGhost(${unit}) then
			r,g,b = unpack(colors.dead)
		else
		]] .. (data.isMod and [[
			value = "|r" .. value
		]] or [[
			value = "|r"
		]]) .. [[
		end
		if r then
		]] .. (data.isMod and [[
			value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
		]] or [[
			value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
		]]) .. [[
		end
	end]]
end, value = "number;string", ret = "string", events = "DeadTime", globals = "unpack;UnitIsConnected;UnitIsDeadOrGhost"}

Modifiers.HappyColor = {function(data)
	return [[do
		local x = GetPetHappiness()
		local r,g,b
		if x == 3 then
			r,g,b = unpack(colors.petHappy)
		elseif x == 2 then
			r,g,b = unpack(colors.petNeutral)
		elseif x == 1 then
			r,g,b = unpack(colors.petAngry)
		else
		]] .. (data.isMod and [[
			value = "|r" .. value
		]] or [[
			value = "|r"
		]]) .. [[
		end
		if r then
		]] .. (data.isMod and [[
			value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
		]] or [[
			value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
		]]) .. [[
		end
	end]]
end, value = "number;string", ret = "string", events = "UNIT_HAPPINESS", globals = "unpack;GetPetHappiness" }

Modifiers.HostileColor = {function(data)
	return [[do
		local r, g, b

		if UnitIsPlayer(${unit}) or UnitPlayerControlled(${unit}) then
			if UnitCanAttack(${unit}, "player") then
				-- they can attack me
				if UnitCanAttack("player", ${unit}) then
					-- and I can attack them
					r, g, b = unpack(colors.hostile)
				else
					-- but I can't attack them
					r, g, b = unpack(colors.civilian)
				end
			elseif UnitCanAttack("player", ${unit}) then
				-- they can't attack me, but I can attack them
				r, g, b = unpack(colors.neutral)
			elseif UnitIsPVP(${unit}) then
				-- on my team
				r, g, b = unpack(colors.friendly)
			else
				-- either enemy or friend, no violence
				r, g, b = unpack(colors.civilian)
			end
		elseif (UnitIsTapped(${unit}) and not UnitIsTappedByPlayer(${unit})) or UnitIsDead(${unit}) then
			r, g, b = unpack(colors.tapped)
		else
			local reaction = UnitReaction(${unit}, "player")
			if reaction then
				if reaction >= 5 then
					r, g, b = unpack(colors.friendly)
				elseif reaction == 4 then
					r, g, b = unpack(colors.neutral)
				else
					r, g, b = unpack(colors.hostile)
				end
			else
				r, g, b = unpack(colors.unknown)
			end
		end

	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", events = "UNIT_FACTION", globals = "UnitIsPlayer;UnitPlayerControlled;UnitCanAttack;UnitIsPVP;UnitIsTapped;UnitIsTappedByPlayer;UnitIsDead;UnitReaction" }

Modifiers.ClassColor = {function(data)
	return [[do
		local _,class = UnitClass(${unit})
		local r, g, b = unpack(colors[class] or colors.unknown)
	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", globals = "UnitClass"}

Modifiers.HPColor = {function(data)
	return [[do
		local perc = UnitHealth(${unit}) / UnitHealthMax(${unit})
		local r1, g1, b1
		local r2, g2, b2
		if perc <= 0.5 then
			perc = perc * 2
			r1, g1, b1 = unpack(colors.minHP)
			r2, g2, b2 = unpack(colors.midHP)
		else
			perc = perc * 2 - 1
			r1, g1, b1 = unpack(colors.midHP)
			r2, g2, b2 = unpack(colors.maxHP)
		end
		local r, g, b = r1 + (r2-r1)*perc, g1 + (g2-g1)*perc, b1 + (b2-b1)*perc
	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", events = "UNIT_HEALTH;UNIT_MAXHEALTH", globals = "UnitHealth;UnitHealthMax;unpack" }

Modifiers.AggroColor = {function(data)
	return [[do
		local val = UnitReaction("player", ${unit}) or 5

		local info = UnitReactionColor[val]
	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", events = "UNIT_FACTION", globals = "UnitReaction;UnitReactionColor" }

Modifiers.DifficultyColor = {function(data)
	return [[if UnitCanAttack("player", ${unit}) then
		local level = UnitLevel(${unit})
		if level <= 0 then
			level = 99
		end
		local info = GetDifficultyColor(level)
	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", events = "UNIT_LEVEL;PLAYER_LEVEL_UP", globals = "UnitCanAttack;UnitLevel;GetDifficultyColor" }

Modifiers.PowerColor = {function(data)
	return [[do
		local powerType = UnitPowerType(${unit})
		local r,g,b
		if powerType == 0 then
			r,g,b = unpack(colors.mana)
		elseif powerType == 1 then
			r,g,b = unpack(colors.rage)
		elseif powerType == 2 then
			r,g,b = unpack(colors.focus)
		elseif powerType == 3 then
			r,g,b = unpack(colors.energy)
		else
			r,g,b = unpack(colors.unknown)
		end
	]] .. (data.isMod and [[
		value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
	]] or [[
		value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	]]) .. [[
	end]]
end, value = "number;string", ret = "string", events = "UNIT_DISPLAYPOWER", globals = "unpack;UnitPowerType" }

Modifiers.CombatColor = {function(data)
	return [[
		if UnitAffectingCombat(${unit}) then
			local r,g,b = unpack(colors.inCombat)
	]] .. (data.isMod and [[
			value = ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
	]] or [[
			value = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	]]) .. [[
		else
	]] .. (data.isMod and [[
			value = "|r" .. value
		]] or [[
			value = "|r"
	]]) .. [[
		end
	]]
end, value = "number;string", ret = "string", events = "Update", globals = "unpack;UnitAffectingCombat" }

Modifiers.Round = {function(data)
	if type(data.arg) ~= "string" then
		local arg = math_floor((data.arg or 0) + 0.5)
		if arg == 0 then
			return [[value = math_floor(value + 0.5)]]
		else
			return [[value = math_floor(value * (10^]] .. arg .. [[) + 0.5) / (10^]] .. arg .. [[)]]
		end
	else -- dynamic
		return [[value = math_floor(value * (10^${arg}) + 0.5) / (10^${arg})]]
	end
end, arg = "nil;number", value = "number", ret = "number", globals = "math.floor"}

Modifiers.Add = {[[value = value + ${arg}]], arg = "number", value = "number", ret = "number"}
Modifiers.Sub = {[[value = value - ${arg}]], arg = "number", value = "number", ret = "number"}
Modifiers.Mult = {[[value = value * ${arg}]], arg = "number", value = "number", ret = "number"}
Modifiers.Div = {[[value = value / ${arg}]], arg = "number", value = "number", ret = "number"}
Modifiers.Pow = {[[value = value ^ ${arg}]], arg = "number", value = "number", ret = "number"}
Modifiers.Mod = {[[value = value % ${arg}]], arg = "number", value = "number", ret = "number"}

Modifiers.Floor = {[[value = math_floor(value)]], value = "number", ret = "number", globals = "math.floor"}
Modifiers.Ceil = {[[value = math_ceil(value)]], value = "number", ret = "number", globals = "math.ceil"}

local function abbreviate(text)
	local b = text:byte(1)
	if b <= 127 then
		return text:sub(1, 1)
	elseif b <= 223 then
		return text:sub(1, 2)
	elseif b <= 239 then
		return text:sub(1, 3)
	else
		return text:sub(1, 4)
	end
end
Modifiers.Abbreviate = {[[
	if value:find(" ") then
		value = value:gsub(" *([^ ]+) *", DogTag___abbreviate)
	end
]], value = "string", ret = "string", globals = "DogTag.__abbreviate"}

Modifiers.Color = {function(data)
	local arg = data.arg:lower()
	if arg:find("%[") and arg:find("%]") then -- dynamic
		return [[do
			local arg = ${arg}
			if not arg:match("^%x%x%x%x%x%x$") then
				arg = "ffffff"
			end
			value = "|cff" .. arg]] .. (data.isMod and [[ .. value .. "|r"]] or "") .. [[
		end]]
	else
		if not arg:match("^%x%x%x%x%x%x$") then
			arg = "ffffff"
		end
		if data.isMod then
			return [[value = "|cff]] .. arg .. [[" .. value .. "|r"]]
		else
			return [[value = "|cff]] .. arg .. [["]]
		end
	end
end, arg = "string", value = "number;string", ret = "string"}
-- colors
Modifiers.White = "Color(ffffff)"
Modifiers.Red = "Color(ff0000)"
Modifiers.Green = "Color(00ff00)"
Modifiers.Blue = "Color(0000ff)"
Modifiers.Cyan = "Color(00ffff)"
Modifiers.Fuchsia = "Color(ff00ff)"
Modifiers.Yellow = "Color(ffff00)"
Modifiers.Gray = "Color(afafaf)"

local Tags = {}
-- When writing tags, `unit` is modified before the call, that contains the unit id.
-- Also, nil (which translates to empty string), a number, or a string can be returned.
-- the tag itself can be in the form of a function or a table containing a function and an event string (or a table of event strings). The events specified will cause the string to update upon that event.
-- Note: can take an argument, either nil, a number, or a string.

Tags.IsFriend = {("value = UnitIsFriend('player', ${unit}) and %q"):format(L["Friend"]), ret = "string;nil", events = "UNIT_FACTION", globals = "UnitIsFriend" }

Tags["~IsFriend"] = {("value = not UnitIsFriend('player', ${unit}) and %q"):format(L["Enemy"]), ret = "string;nil", events = "UNIT_FACTION", globals = "UnitIsFriend" }

Tags.IsEnemy = "~IsFriend"

Tags.Text = {"if ${arg} ~= '' then value = ${arg} end", arg = "string", ret = "string;nil"}

Tags.Name = {"value = UnitName(${unit})", ret = "string", events = "UNIT_NAME_UPDATE;PLAYER_ENTERING_WORLD", globals = "UnitName"}

Tags.Realm = {[[do
	local _
	_, value = UnitName(${unit})
	if value == "" then
		value = nil
	end
end]], ret = "string;nil", events = "UNIT_NAME_UPDATE", globals="UnitName"}

Tags["~Realm"] = {([[do
	local _, realm = UnitName(${unit})
	if not realm or realm == "" then
		value = %q
	end
end]]):format(L["True"]), ret = "string;nil", events = "UNIT_NAME_UPDATE", globals="UnitName"}

Tags.NameRealm = "Text([Name][Realm:Prepend(-)])"

Tags.NameHostile = "Name:HostileColor"

Tags.Status = "Offline:HasDivineIntervention:[Dead?IsFeignedDeath:HasSoulstone:Dead]"

Tags["~Status"] = "~Offline?~HasDivineIntervention?~Dead"

Tags.StatusGone = "Status"

Tags.CurHP = {function(data)
	if MobHealth3 then
		return [[do
			local currValue = UnitHealth(${unit})
			if currValue == 0 then
				value = 0
			else
				if not UnitIsFriend("player", ${unit}) then
					local maxValue = UnitHealthMax(${unit})
					local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, currValue, maxValue)
					if MHfound then
						value = curr
					end
				end
				if not value then
					value = currValue
				end
			end
		end]], 'globals', 'UnitHealth;MobHealth3;UnitIsFriend;UnitHealthMax'
	elseif MobHealth_PPP then
		return [[do
			local currValue = UnitHealth(${unit})
			if currValue == 0 then
				value = 0
			else
				if not UnitIsFriend("player", ${unit}) then
					local name = UnitName(${unit})
					local level = UnitLevel(${unit})
					local ppp = MobHealth_PPP(name..":"..level)
					if ppp > 0 then
						value = math_floor(currValue * ppp + 0.5)
					end
				end
				if not value then
					value = currValue
				end
			end
		end]], 'globals', 'UnitHealth;UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;math.floor'
	else
		return [[value = UnitHealth(${unit})]], 'globals', 'UnitHealth'
	end
end, ret = "number", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags.MaxHP = {function(data)
	if MobHealth3 then
		return [[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue == 0 then
				value = 0
			else
				if not UnitIsFriend("player", ${unit}) then
					local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, 1, maxValue)
					if MHfound then
						value = max
					end
				end
				if not value then
					value = maxValue
				end
			end
		end]], 'globals', "UnitHealthMax;UnitIsFriend;MobHealth3"
	elseif MobHealth_PPP then
		return [[do
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp > 0 then
					value = math_floor(100 * ppp + 0.5)
				end
			end
			if not value then
				value = UnitHealthMax(${unit})
			end
		end]], 'globals', "UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;math.floor;UnitHealthMax"
	else
		return [[value = UnitHealthMax(${unit})]], 'globals', "UnitHealthMax"
	end
end, ret = "number", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags.PercentHP = {[[do
	local hpmax = UnitHealthMax(${unit})
	if hpmax == 0 then
		value = 0
	else
		value = math_floor(1000 * UnitHealth(${unit}) / hpmax + 0.5) / 10
	end
end]], ret = "number", events = "UNIT_HEALTH;UNIT_MAXHEALTH", globals = "UnitHealth;UnitHealthMax;math.floor" }

Tags.MissingHP = {function(data)
	if MobHealth3 then
		return [[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue == 0 then
				value = 0
			else
				local currValue = UnitHealth(${unit})
				if not UnitIsFriend("player", ${unit}) then
					local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, currValue, maxValue)
					if MHfound then
						value = max - curr
					end
				end
				if not value then
					value = maxValue - currValue
				end
			end
		end]], 'globals', "UnitHealthMax;UnitHealth;UnitIsFriend;MobHealth3"
	elseif MobHealth_PPP then
		return [[do
			local currValue = UnitHealth(${unit})
			if currValue == 0 then
				value = 0
			else
				if not UnitIsFriend("player", ${unit}) then
					local name = UnitName(${unit})
					local level = UnitLevel(${unit})
					local ppp = MobHealth_PPP(name..":"..level)
					if ppp > 0 then
						value = math_floor((100 - currValue) * ppp + 0.5)
					end
				end
				if not value then
					value = UnitHealthMax(${unit}) - currValue
				end
			end
		end]], "UnitHealth;UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;math.floor;UnitHealthMax"
	else
		return [[value = UnitHealthMax(${unit}) - UnitHealth(${unit})]], 'globals', "UnitHealthMax;UnitHealth"
	end
end, ret = "number", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags.FractionalHP = {function(data)
	if MobHealth3 then
		return [[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue == 0 then
				value = "0/0"
			else
				local currValue = UnitHealth(${unit})
				if maxValue ~= 100 then
					value = currValue.."/"..maxValue
				elseif not UnitIsFriend("player", ${unit}) then
					local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, currValue, maxValue)
					if MHfound then
						value = curr.."/"..max
					end
				end
				if not value then
					value = currValue.."/"..maxValue
				end
			end
		end]], 'globals', "UnitHealthMax;UnitHealth;MobHealth3;UnitIsFriend"
	elseif MobHealth_PPP then
		return [[do
			local currValue = UnitHealth(${unit})
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp > 0 then
					value = math_floor(currValue * ppp + 0.5) .. "/" .. math_floor(100 * ppp + 0.5)
				end
			end
			if not value then
				value = currValue .. "/" .. UnitHealthMax(${unit})
			end
		end]], 'globals', "UnitHealth;UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;math.floor;UnitHealthMax"
	else
		return [[value = UnitHealth(${unit}).."/"..UnitHealthMax(${unit})]], 'globals', "UnitHealth;UnitHealthMax"
	end
end, ret = "string", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags.SureHP = {function(data)
	if MobHealth3 then
		return [[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue ~= 0 then
				if maxValue ~= 100 then
					value = UnitHealth(${unit}).."/"..maxValue
				elseif not UnitIsFriend("player", ${unit}) then
					local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, UnitHealth(${unit}), maxValue)
					if MHfound then
						value = curr.."/"..max
					end
				end
			end
		end]], 'globals', "UnitHealthMax;UnitHealth;MobHealth3;UnitIsFriend"
	elseif MobHealth_PPP then
		return [[do
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp > 0 then
					value = math_floor(UnitHealth(${unit}) * ppp + 0.5) .. "/" .. math_floor(100 * ppp + 0.5)
				end
			else
				local maxValue = UnitHealthMax(${unit})
				if maxValue ~= 100 then
					value = UnitHealth(${unit}).."/"..maxValue
				end
			end
		end]], 'globals', "UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;UnitHealth;math.floor;UnitHealthMax"
	else
		return [[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue ~= 0 and maxValue ~= 100 then
				value = UnitHealth(${unit}).."/"..maxValue
			end
		end]], 'globals', "UnitHealthMax;UnitHealth"
	end
end, ret = "string;nil", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags["~SureHP"] = {function(data)
	if MobHealth3 then
		return ([[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue == 0 then
				value = %q
			elseif not UnitIsFriend("player", ${unit}) and maxValue == 100 then
				local _, _, MHfound = MobHealth3:GetUnitHealth(${unit}, 1, 100)
				if not MHfound then
					value = %q
				end
			end
		end]]):format(L["True"], L["True"]), 'globals', "UnitHealthMax;UnitIsFriend;MobHealth3"
	elseif MobHealth_PPP then
		return ([[do
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp <= 0 then
					value = %q
				end
			elseif UnitHealthMax(${unit}) == 100 then
				value = %q
			end
		end]]):format(L["True"], L["True"]), 'globals', "UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;UnitHealthMax"
	else
		return ([[do
			local maxValue = UnitHealthMax(${unit})
			if maxValue == 0 or maxValue == 100 then
				value = %q
			end
		end]]):format(L["True"], L["True"]), 'globals', "UnitHealthMax"
	end
end, ret = "string;nil", events = "UNIT_HEALTH;UNIT_MAXHEALTH" }

Tags.SmartHP = "SureHP:PercentHP:Percent"

Tags.CurMP = {"value = UnitMana(${unit})", ret = "number", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitMana" }

Tags.MaxMP = {"value = UnitManaMax(${unit})", ret = "number", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitManaMax" }

Tags.PercentMP = {[[do
	local mpmax = UnitManaMax(${unit})
	if mpmax == 0 then
		value = 0
	else
		value = math_floor(1000 * UnitMana(${unit}) / mpmax + 0.5) / 10
	end
end]], ret = "number", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitMana;UnitManaMax;math.floor" }

Tags.MissingMP = "MaxMP:Sub([CurMP])"

Tags.FractionalMP = "Text([CurMP]/[MaxMP])"

Tags.TypePower = {([[do
	local p = UnitPowerType(${unit})
	if p == 1 then
		value = %q
	elseif p == 2 then
		value = %q
	elseif p == 3 then
		value = %q
	else
		value = %q
	end
end]]):format(L["Rage"], L["Focus"], L["Energy"], L["Mana"]), ret = "string", events = "UNIT_DISPLAYPOWER", globals = "UnitPowerType" }

Tags.IsPowerType = {function(data)
	local arg = data.arg:lower()
	if arg == "rage" then
		return ([[value = UnitPowerType(${unit}) == 1 and %q]]):format(L["Rage"])
	elseif arg == "focus" then
		return ([[value = UnitPowerType(${unit}) == 2 and %q]]):format(L["Focus"])
	elseif arg == "energy" then
		return ([[value = UnitPowerType(${unit}) == 3 and %q]]):format(L["Energy"])
	elseif arg == "mana" then
		return ([[value = UnitPowerType(${unit}) == 0 and %q]]):format(L["Mana"])
	elseif arg:find("%[") and arg:find("%]") then
		return ([[
			local arg = (${arg}):lower()
			if arg == "rage" then
				value = UnitPowerType(${unit}) == 1 and %q
			elseif arg == "focus" then
				value = UnitPowerType(${unit}) == 2 and %q
			elseif arg == "energy" then
				value = UnitPowerType(${unit}) == 3 and %q
			elseif arg == "mana" then
				value = UnitPowerType(${unit}) == 0 and %q
			end
		]]):format(L["Rage"], L["Focus"], L["Energy"], L["Mana"])
	else
		return [[value = nil]]
	end
end, arg = "string", ret = "nil;string", events = "UNIT_DISPLAYPOWER", globals = "UnitPowerType"}

Tags["~IsPowerType"] = {function(data)
	local arg = data.arg:lower()
	if arg == "rage" then
		return ([[value = UnitPowerType(${unit}) ~= 1 and %q]]):format(L["True"])
	elseif arg == "focus" then
		return ([[value = UnitPowerType(${unit}) ~= 2 and %q]]):format(L["True"])
	elseif arg == "energy" then
		return ([[value = UnitPowerType(${unit}) ~= 3 and %q]]):format(L["True"])
	elseif arg == "mana" then
		return ([[value = UnitPowerType(${unit}) ~= 0 and %q]]):format(L["True"])
	elseif arg:find("%[") and arg:find("%]") then
		return ([[
			local arg = (${arg}):lower()
			if arg == "rage" then
				value = UnitPowerType(${unit}) ~= 1 and %q
			elseif arg == "focus" then
				value = UnitPowerType(${unit}) ~= 2 and %q
			elseif arg == "energy" then
				value = UnitPowerType(${unit}) ~= 3 and %q
			elseif arg == "mana" then
				value = UnitPowerType(${unit}) ~= 0 and %q
			end
		]]):format(L["True"], L["True"], L["True"], L["True"])
	else
		return ([[value = %q]]):format(L["True"])
	end
end, arg = "string", ret = "nil;string", events = "UNIT_DISPLAYPOWER", globals = "UnitPowerType"}

Tags.IsRage = "IsPowerType(Rage)"
Tags.IsFocus = "IsPowerType(Focus)"
Tags.IsEnergy = "IsPowerType(Energy)"
Tags.IsMana = "IsPowerType(Mana)"

Tags.Level = {[[do
	local x = UnitLevel(${unit})
	if x > 0 then
		value = x
	else
		value = "??"
	end
end]], ret = "number;string", events = "UNIT_LEVEL", globals = "UnitLevel" }

Tags.IsMaxLevel = {([[value = UnitLevel(${unit}) >= %d and %q]]):format(MAX_PLAYER_LEVEL, L["True"]), ret = "string;nil", events = "UNIT_LEVEL", globals = "UnitLevel"}

Tags["~IsMaxLevel"] = {([[value = UnitLevel(${unit}) < %d and %q]]):format(MAX_PLAYER_LEVEL, L["True"]), ret = "string;nil", events = "UNIT_LEVEL", globals = "UnitLevel"}

Tags.Class = {([[value = UnitClass(${unit}) or %q]]):format(UNKNOWN), ret = "string", globals = "UnitClass"}

Tags.SmartClass = {[[value = (UnitIsPlayer(${unit}) or (not UnitIsFriend("player", ${unit}) and not UnitPlayerControlled(${unit}))) and UnitClass(${unit})]], ret = "string;nil", globals = "UnitIsPlayer;UnitIsFriend;UnitPlayerControlled;UnitClass"}

Tags["~SmartClass"] = {([[value = not UnitIsPlayer(${unit}) and (UnitIsFriend("player", ${unit}) or UnitPlayerControlled(${unit})) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlayer;UnitIsFriend;UnitPlayerControlled;UnitClass"}

Tags.PlayerClass = "IsPlayer?Class"

Tags["~PlayerClass"] = "~IsPlayer"

Tags.ShortClass = "Class:ShortClass"

Tags.ShortSmartClass = "SmartClass:ShortClass"

Tags.ShortPlayerClass = "PlayerClass:ShortClass"

Tags.Creature = {([[value = UnitCreatureFamily(${unit}) or UnitCreatureType(${unit}) or %q]]):format(UNKNOWN), ret = "string", globals = "UnitCreatureFamily;UnitCreatureType"}

Tags.CreatureType = {([[value = UnitCreatureType(${unit}) or %q]]):format(UNKNOWN), ret = "string", globals = "UnitCreatureType"}

Tags.Combos = {[[value = GetComboPoints()]], ret = "number", events = "PLAYER_COMBO_POINTS", globals = "GetComboPoints" }

Tags.ComboSymbols = {function(data)
	return [[do
		local num = GetComboPoints()
		if num > 0 then
			value = (]] .. (data.arg and "${arg}" or '"@"') .. [[):rep(num)
		end
	end]]
end, arg = "string;nil", ret = "string;nil", events = "PLAYER_COMBO_POINTS", globals = "GetComboPoints"}

Tags["~ComboSymbols"] = {([[value = GetComboPoints() == 0 and %q]]):format(L["True"]), ret = "string;nil", events = "PLAYER_COMBO_POINTS", globals = "GetComboPoints"}

Tags.Classification = {([[do
	local c = UnitClassification(${unit})
	if c == "rare" then
		value = %q
	elseif c == "rareelite" then
		value = %q
	elseif c == "elite" then
		value = %q
	elseif c == "worldboss" then
		value = %q
	end
end]]):format(L["Rare"], L["Rare-Elite"], L["Elite"], L["Boss"]), ret = "string;nil", globals = "UnitClassification"}

Tags["~Classification"] = {([[value = UnitClassification(${unit}) == "normal" and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitClassification"}

Tags.ShortClassification = {([[do
	local c = UnitClassification(${unit})
	if c == "rare" then
		value = %q
	elseif c == "rareelite" then
		value = %q
	elseif c == "elite" then
		value = %q
	elseif c == "worldboss" then
		value = %q
	end
end]]):format(L["Rare_short"], L["Rare-Elite_short"], L["Elite_short"], L["Boss_short"]), ret = "string;nil", globals = "UnitClassification"}

Tags["~ShortClassification"] = "~Classification"

Tags.Faction = {[[value = DogTag___FigureFaction(${unit})]], ret = "string;nil", globals = "DogTag.__FigureFaction"}

Tags.Offline = {([[do
	local t = DogTag___GetOfflineTime(${unit})
	if t then
		value = %q .. t .. %q
	end
end]]):format(L["Offline"] .. " (", ")"), ret = "string;nil", events = "OfflineTime", globals = "DogTag.__GetOfflineTime"}

Tags["~Offline"] = {([[value = UnitIsConnected(${unit}) and %q]]):format(L["Online"]), ret = "string;nil", events = "OfflineTime", globals = "UnitIsConnected"}

Tags.Dead = {([[do
	if UnitIsDeadOrGhost(${unit}) then
		local t = DogTag___GetDeadTime(${unit})
		if t then
			value = (UnitIsGhost(${unit}) and %q or %q) .. " (" .. t .. ")"
		else
			value = UnitIsGhost(${unit}) and %q or %q
		end
	end
end]]):format(L["Ghost"], L["Dead"], L["Ghost"], L["Dead"]), ret = "string;nil", globals = "DogTag.__GetDeadTime;UnitIsDeadOrGhost;UnitIsGhost", events = "DeadTime"}

Tags["~Dead"] = {([[value = not UnitIsDeadOrGhost(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsDeadOrGhost", events = "DeadTime"}

Tags.AFK = {([[do
	local t = DogTag___GetAFKTime(${unit})
	if t then
		value = %q .. t .. %q
	end
end]]):format(L["AFK"] .. " (", ")"), ret = "string;nil", events = "AFKTime", globals = "DogTag.__GetAFKTime"}

Tags["~AFK"] = {([[value = not UnitIsAFK(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "AFKTime", globals = "UnitIsAFK"}

Tags.DND = {([[value = UnitIsDND(${unit}) and %q]]):format(L["DND"]), ret = "string;nil", events = "PLAYER_FLAGS_CHANGED", globals = "UnitIsDND"}

Tags["~DND"] = {([[value = not UnitIsDND(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "PLAYER_FLAGS_CHANGED", globals = "UnitIsDND"}

Tags.AFKDND = "AFK:DND"

Tags.SmartRace = {([[
	if UnitIsPlayer(${unit}) then
		value = UnitRace(${unit}) or %q
	else
		value = UnitCreatureFamily(${unit}) or UnitCreatureType(${unit}) or %q
	end
]]):format(UNKNOWN, UNKNOWN), ret = "string", globals = "UnitIsPlayer;UnitRace;UnitCreatureFamily;UnitCreatureType"}

Tags.Race = {"value = UnitRace(${unit})", ret = "string", globals = "UnitRace"}

Tags.ShortRace = "Race:ShortRace"

Tags.PvP = {([[value = UnitIsPVPFreeForAll(${unit}) and %q or UnitIsPVP(${unit}) and %q]]):format(L["FFA"], L["PvP"]), ret = "string;nil", globals = "UnitIsPVP;UnitIsPVPFreeForAll"}

Tags["~PvP"] = {([[value = not UnitIsPVP(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPVP"}

Tags.Plus = {([[value = UnitIsPlusMob(${unit}) and %q]]):format(L["Elite_short"]), ret = "string;nil", globals = "UnitIsPlusMob"}

Tags["~Plus"] = {([[value = not UnitIsPlusMob(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlusMob"}

Tags.Sex = {([[do
	local sex = UnitSex(${unit})
	if sex == 2 then
		value = %q
	elseif sex == 3 then
		value = %q
	end
end]]):format(L["Male"], L["Female"]), ret = "string;nil", globals = "UnitSex"}

Tags["~Sex"] = {([[do
	local sex = UnitSex(${unit})
	value = sex ~= 2 and sex ~= 3 and %q
end]]):format(L["True"]), ret = "string;nil", globals = "UnitSex"}

Tags.ShortSex = {([[do
	local sex = UnitSex(${unit})
	if sex == 2 then
		value = %q
	elseif sex == 3 then
		value = %q
	end
end]]):format(L["Male_short"], L["Female_short"]), ret = "string;nil", globals = "UnitSex"}

Tags["~ShortSex"] = "~Sex"

Tags.Resting = {([[value = IsResting() and %q]]):format(L["Resting"]), ret = "string;nil", events = "PLAYER_UPDATE_RESTING", globals = "IsResting" }

Tags["~Resting"] = {([[value = not IsResting() and %q]]):format(L["True"]), ret = "string;nil", events = "PLAYER_UPDATE_RESTING", globals = "IsResting" }

Tags.Leader = {([[value = UnitIsPartyLeader(${unit}) and %q]]):format(L["Leader"]), ret = "string;nil", globals = "UnitIsPartyLeader"}

Tags["~Leader"] = {([[value = not UnitIsPartyLeader(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPartyLeader"}

Tags.LeaderShort = "Leader:Trunc(1)"

Tags.HappyNum = {[[value = GetPetHappiness() or 0]], ret = "number", events = "UNIT_HAPPINESS", globals = "GetPetHappiness"}

Tags.HappyText = {[=[value = _G["PET_HAPPINESS" .. (GetPetHappiness() or 0)]]=], ret = "string;nil", events = "UNIT_HAPPINESS", globals = "_G;GetPetHappiness" }

Tags["~HappyText"] = {([[do
	local happy = GetPetHappiness()
	value = happy ~= 1 and happy ~= 2 and happy ~= 3 and %q
end]]):format(L["True"]), ret = "string;nil", events = "UNIT_HAPPINESS", globals = "GetPetHappiness" }

Tags.HappyIcon = {[[do
	local happy = GetPetHappiness()
	if happy == 3 then
		value = ":D"
	elseif happy == 2 then
		value = ":I"
	elseif happy == 1 then
		value = "B("
	end
end]], ret = "string;nil", events = "UNIT_HAPPINESS", globals = "GetPetHappiness" }

Tags["~HappyIcon"] = "~HappyText"

Tags.CurXP = {[[
	if ${unit} == "pet" then
		value = GetPetExperience()
	else
	 	value = UnitXP(${unit})
	end
]], ret = "number", events = "UNIT_PET_EXPERIENCE;PLAYER_XP_UPDATE", globals = "GetPetExperience;UnitXP" }

Tags.MaxXP = {[[
	if ${unit} == "pet" then
		local _,max = GetPetExperience()
		value = max
	else
	 	value = UnitXPMax(${unit})
	end
]], ret = "number", events = "UNIT_PET_EXPERIENCE;PLAYER_XP_UPDATE", globals = "GetPetExperience;UnitXP" }

Tags.FractionalXP = {[[
	local cur, max
	if ${unit} == "pet" then
		cur, max = GetPetExperience()
	else
	 	cur, max = UnitXP(${unit}), UnitXPMax(${unit})
	end
	value = cur .. '/' .. max
]], ret = "string", events = "UNIT_PET_EXPERIENCE;PLAYER_XP_UPDATE", globals = "GetPetExperience;UnitXP;UnitXPMax" }

Tags.PercentXP = {[[
	if ${unit} == "pet" then
		local cur, max = GetPetExperience()
		if max > 0 then
			value = math_floor(1000 * cur/max + 0.5) / 10
		else
			value = 0
		end
	else
	 	local max = UnitXPMax(${unit})
		if max > 0 then
			local cur = UnitXP(${unit})
			value = math_floor(1000 * cur/max + 0.5) / 10
		else
			value = 0
		end
	end
]], ret = "number", events = "UNIT_PET_EXPERIENCE;PLAYER_XP_UPDATE", globals = "GetPetExperience;UnitXP;math.floor" }

Tags.MissingXP = {[[
	if ${unit} == "pet" then
		local cur, max = GetPetExperience()
		value = max - cur
	else
	 	value = UnitXPMax(${unit}) - UnitXP(${unit})
	end
]], ret = "number", events = "UNIT_PET_EXPERIENCE;PLAYER_XP_UPDATE", globals = "GetPetExperience;UnitXPMax;UnitXP" }

Tags.RestXP = {[[value = UnitIsUnit(${unit}, "player") and GetXPExhaustion() or 0]], ret = "number", events = "PLAYER_XP_UPDATE", globals = "UnitIsUnit;GetXPExhaustion"}

Tags.PercentRestXP = {[[do
	local max = UnitXPMax(${unit})
	if max > 0 then
		local rest = UnitIsUnit(${unit}, "player") and GetXPExhaustion() or 0
		value = math_floor(1000 * rest/max + 0.5) / 10
	else
		value = 0
	end
end]], ret = "number", events = "PLAYER_XP_UPDATE", globals = "UnitIsUnit;GetXPExhaustion;UnitXPMax;math.floor" }


Tags.TappedByMe = {[[value = UnitIsTappedByPlayer(${unit}) and "*"]], ret = "string;nil", events = "Update", globals = "UnitIsTappedByPlayer" }

Tags["~TappedByMe"] = {([[value = not UnitIsTappedByPlayer(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "Update", globals = "UnitIsTappedByPlayer" }

Tags.IsTapped = {([[value = UnitIsTapped(${unit}) and not UnitIsTappedByPlayer(${unit}) and %q]]):format(L["Tapped"]), ret = "string;nil", events = "Update", globals = "UnitIsTapped;UnitIsTappedByPlayer" }

Tags["~IsTapped"] = {([[value = (not UnitIsTapped(${unit}) or UnitIsTappedByPlayer(${unit})) and %q]]):format(L["True"]), ret = "string;nil", events = "Update", globals = "UnitIsTapped;UnitIsTappedByPlayer" }

Tags.IsMaxHP = {([[value = UnitHealth(${unit}) == UnitHealthMax(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_HEALTH;UNIT_MAXHEALTH", globals = "UnitHealthMax;UnitHealth" }

Tags["~IsMaxHP"] = {([[value = UnitHealth(${unit}) ~= UnitHealthMax(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_HEALTH;UNIT_MAXHEALTH", globals = "UnitHealthMax;UnitHealth" }

Tags.IsMaxMP = {([[value = UnitMana(${unit}) == UnitManaMax(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitMana;UnitManaMax" }

Tags["~IsMaxMP"] = {([[value = UnitMana(${unit}) ~= UnitManaMax(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitMana;UnitManaMax" }

Tags.HasNoMP = {([[value = UnitManaMax(${unit}) == 0 and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitManaMax" }

Tags["~HasNoMP"] = {([[value = UnitManaMax(${unit}) ~= 0 and %q]]):format(L["True"]), ret = "string;nil", events = "UNIT_MANA;UNIT_RAGE;UNIT_FOCUS;UNIT_ENERGY;UNIT_MAXMANA;UNIT_MAXRAGE;UNIT_MAXFOCUS;UNIT_MAXENERGY;UNIT_DISPLAYPOWER", globals = "UnitManaMax" }

Tags.InCombat = {([[value = UnitAffectingCombat(${unit}) and %q]]):format(L["Combat"]), ret = "string;nil", events = "Update", globals = "UnitAffectingCombat"}

Tags["~InCombat"] = {([[value = not UnitAffectingCombat(${unit}) and %q]]):format(L["True"]), ret = "string;nil", events = "Update", globals = "UnitAffectingCombat"}

Tags.FKey = {[[do
	local fkey
	if UnitIsUnit(${unit}, "player") then
		fkey = 0
	else
		for i = 1, 4 do
			if UnitIsUnit(${unit}, "party" .. i) then
				fkey = i
				break
			end
		end
	end
	if fkey then
		value = "F" .. (fkey + 1)
	end
end]], ret = "string;nil", globals = "UnitIsUnit"}

Tags["~FKey"] = {([[value = not UnitIsUnit(${unit}, "player") and not UnitIsUnit(${unit}, "party1") and not UnitIsUnit(${unit}, "party2") and not UnitIsUnit(${unit}, "party3") and not UnitIsUnit(${unit}, "party4") and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsUnit"}

Tags.RaidGroup = {[[
	for i = 1, GetNumRaidMembers() do
		local name, rank, subgroup = GetRaidRosterInfo(i)
		if name == UnitName(${unit}) then
			value = subgroup
			break
		end
	end
]], ret = "string;nil", globals = "GetNumRaidMembers;GetRaidRosterInfo;UnitName"}

Tags["~RaidGroup"] = {([[do
	value = %q
	for i = 1, GetNumRaidMembers() do
		local name, rank, subgroup = GetRaidRosterInfo(i)
		if name == UnitName(${unit}) then
			value = nil
			break
		end
	end
end]]):format(L["True"]), ret = "string;nil", globals = "GetNumRaidMembers;GetRaidRosterInfo;UnitName"}

Tags.Guild = {[[if UnitIsPlayer(${unit}) then
	value = GetGuildInfo(${unit})
else
	value = DogTag___FigureNPCGuild(${unit})
end]], ret = "string;nil", globals = "GetGuildInfo;UnitIsPlayer;DogTag.__FigureNPCGuild"}

Tags["~Guild"] = {([[if UnitIsPlayer(${unit}) then
	value = not GetGuildInfo(${unit}) and %q
else
	value = not DogTag___FigureNPCGuild(${unit}) and %q
end]]):format(L["True"], L["True"]), ret = "string;nil", globals = "GetGuildInfo;UnitIsPlayer;DogTag.__FigureNPCGuild"}

Tags.GuildRank = {[[do
	local _, rank = GetGuildInfo(${unit})
	value = rank
end]], ret = "string;nil", globals = "GetGuildInfo"}

Tags["~GuildRank"] = {([[do
	local _, rank = GetGuildInfo(${unit})
	value = not rank and %q
end]]):format(L["True"]), ret = "string;nil", globals = "GetGuildInfo"}

Tags.GuildNote = {[[do
	local name, server = UnitName(${unit})
	if name and (not server or server == "") then
		value = DogTag___guildNotes[name]
	end
end]], ret = "string;nil", globals = "UnitName;DogTag.__guildNotes", events = "GUILD_ROSTER_UPDATE"}

Tags["~GuildNote"] = {([[do
	local name, server = UnitName(${unit})
	value = (not name or (server and server ~= "") or not DogTag___guildNotes[name]) and %q
end]]):format(L["True"]), ret = "string;nil", globals = "UnitName;DogTag.__guildNotes", events = "GUILD_ROSTER_UPDATE"}

Tags.OfficerNote = {[[do
	local name, server = UnitName(${unit})
	if name and (not server or server == "") then
		value = DogTag___officerNotes[name]
	end
end]], ret = "string;nil", globals = "UnitName;DogTag.__officerNotes", events = "GUILD_ROSTER_UPDATE"}

Tags["~OfficerNote"] = {([[do
	local name, server = UnitName(${unit})
	value = (not name or (server and server ~= "") or not DogTag___officerNotes[name]) and %q
end]]):format(L["True"]), ret = "string;nil", globals = "UnitName;DogTag.__officerNotes", events = "GUILD_ROSTER_UPDATE"}

Tags.Zone = {[[value = DogTag___FigureZone(${unit})]], ret = "string;nil", globals = "DogTag.__FigureZone", events = "SlowUpdate"}

Tags["~Zone"] = {([[value = not DogTag___FigureZone(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "DogTag.__FigureZone", events = "SlowUpdate"}

Tags.Target = {[[do
	local u = unit .. "target"
	if UnitExists(u) then
		value = UnitName(u)
	end
end]], ret = "string;nil", events = "UNIT_TARGET", globals = "UnitExists;UnitName" }

Tags["~Target"] = {([[do
	local u = unit .. "target"
	value = not UnitExists(u) and %q
end]]):format(L["True"]), ret = "string;nil", events = "UNIT_TARGET", globals = "UnitExists;UnitName" }

Tags.TargetTarget = {[[do
	local u = unit .. "targettarget"
	if UnitExists(u) then
		value = UnitName(u)
	end
end]], ret = "string;nil", events = "UNIT_TARGET", globals = "UnitExists;UnitName" }

Tags["~TargetTarget"] = {([[do
	local u = unit .. "targettarget"
	value = not UnitExists(u) and %q
end]]):format(L["True"]), ret = "string;nil", events = "UNIT_TARGET;Update", globals = "UnitExists;UnitName" }

Tags.NumTargeting = {[[do
	value = 0
	local raid = GetNumRaidMembers()
	if raid > 0 then
		for i = 1, raid do
			if UnitIsUnit("raid" .. i .. "target", ${unit}) then
				value = value + 1
			end
		end
	else
		if UnitIsUnit("target", ${unit}) then
			value = value + 1
		end
		for i = 1, GetNumPartyMembers() do
			if UnitIsUnit("party" .. i .. "target", ${unit}) then
				value = value + 1
			end
		end
	end
end]], ret = "number", events = "UNIT_TARGET;Update", globals = "UnitIsUnit;GetNumRaidMembers;GetNumPartyMembers"}

Tags.TargetingList = {[[do
	local DogTag___TargetingList_tmp = DogTag.__TargetingList_tmp
	if not DogTag___TargetingList_tmp then
		DogTag___TargetingList_tmp = {}
		DogTag.__TargetingList_tmp = DogTag___TargetingList_tmp
	end
	local raid = GetNumRaidMembers()
	if raid > 0 then
		for i = 1, raid do
			if UnitIsUnit("raid" .. i .. "target", ${unit}) then
				local name, server = UnitName("raid" .. i)
				if server and server ~= "" then
					DogTag___TargetingList_tmp[#DogTag___TargetingList_tmp+1] = name .. "-" .. server
				else
					DogTag___TargetingList_tmp[#DogTag___TargetingList_tmp+1] = name
				end
			end
		end
	else
		if UnitIsUnit("target", ${unit}) then
			DogTag___TargetingList_tmp[#DogTag___TargetingList_tmp+1] = UnitName("player")
		end
		for i = 1, GetNumPartyMembers() do
			if UnitIsUnit("party" .. i .. "target", ${unit}) then
				DogTag___TargetingList_tmp[#DogTag___TargetingList_tmp+1] = UnitName("party" .. i)
			end
		end
	end
	table_sort(DogTag___TargetingList_tmp)
	if #DogTag___TargetingList_tmp >= 1 then
		value = table_concat(DogTag___TargetingList_tmp, ", ")
	end
	for i = 1, #DogTag___TargetingList_tmp do
		DogTag___TargetingList_tmp[i] = nil
	end
end]], ret = "string;nil", events = "UNIT_TARGET;Update", globals = "UnitIsUnit;GetNumRaidMembers;GetNumPartyMembers;UnitName;table.sort;table.concat"}

Tags.InGroup = {([[value = (GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0) and %q]]):format(L["True"]), ret = "string;nil", globals = "GetNumRaidMembers;GetNumPartyMembers" }

Tags.IsMouseOver = {([[value = DogTag.__isMouseOver and %q]]):format(L["True"]), ret = "string;nil", events = "Mouseover" }

Tags["~IsMouseOver"] = {([[value = not DogTag.__isMouseOver and %q]]):format(L["True"]), ret = "string;nil", events = "Mouseover" }

Tags.CurRep = {[[do
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		value = repvalue - repmin
	end
end]], ret = "number;nil", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags["~CurRep"] = "~RepName"

Tags.MaxRep = {[[do
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		value = repmax - repmin
	end
end]], ret = "number;nil", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags["~MaxRep"] = "~RepName"

Tags.FractionalRep = {[[do
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		repvalue = repvalue - repmin
		repmax = repmax - repmin
		value = repvalue .. '/' .. repmax
	end
end]], ret = "string;nil", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags["~FractionalRep"] = "~RepName"

Tags.PercentRep = {[[do
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		repmax = repmax - repmin
		repvalue = repvalue - repmin
		value = math_floor(1000 * repvalue/repmax + 0.5) / 10
	end
end]], ret = "number;nil", events = "Reputation", globals = "GetWatchedFactionInfo;math.floor"}

Tags["~PercentRep"] = "~RepName"

Tags.MissingRep = {[[do
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if repname then
		value = repmax - repvalue
	end
end]], ret = "number;nil", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags["~MissingRep"] = "~RepName"

Tags.RepName = {[[value = GetWatchedFactionInfo()]], ret = "number;nil", events = "Reputation", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags["~RepName"] = {([[value = not GetWatchedFactionInfo() and %q]]):format(L["True"]), ret = "number;nil", events = "Reputation", globals = "GetWatchedFactionInfo"}

Tags.RepReaction = {[[do
	local alpha, bravo = GetWatchedFactionInfo()
	if alpha then
		value = _G["FACTION_STANDING_LABEL"..bravo]
	end
end]], ret = "number;nil", events = "Reputation", events = "Reputation", globals = "GetWatchedFactionInfo;_G"}

Tags["~RepReaction"] = "~RepName"

Tags.DruidForm = {function(data)
	if not BabbleSpell then
		return ([[do
			local _,c = UnitClass(${unit})
			if c == "DRUID" then
				local power = UnitPowerType(${unit})
				if power == 1 then
					value = %q
				elseif power == 3 then
					value = %q
				end
			end
		end]]):format(L["Bear"], L["Cat"]), 'globals', "UNIT_DISPLAYPOWER"
	else
		return ([[do
			local _,c = UnitClass(${unit})
			if c == "DRUID" then
				local power = UnitPowerType(${unit})
				if power == 1 then
					value = %q
				elseif power == 3 then
					value = %q
				else
					local auras = DogTag___currentAuras[${unit}]
					if auras[%q] then
						value = %q
					elseif auras[%q] then
						value = %q
					elseif auras[%q] or auras[%q] then
						value = %q
					elseif auras[%q] then
						value = %q
					elseif auras[%q] then
						value = %q
					end
				end
			end
		end]]):format(L["Bear"], L["Cat"], BabbleSpell["Moonkin Form"], L["Moonkin"], BabbleSpell["Aquatic Form"], L["Aquatic"], BabbleSpell["Flight Form"], BabbleSpell["Swift Flight Form"], L["Flight"], BabbleSpell["Travel Form"], L["Travel"], BabbleSpell["Tree of Life"], L["Tree"]), 'events', (";"):join("UNIT_DISPLAYPOWER", BabbleSpell["Moonkin Form"], BabbleSpell["Aquatic Form"], BabbleSpell["Flight Form"], BabbleSpell["Swift Flight Form"], BabbleSpell["Travel Form"], BabbleSpell["Tree of Life"])
	end
end, ret = "string;nil", globals = "UnitClass;UnitPowerType;DogTag.__currentAuras"}

Tags["~DruidForm"] = {function(data)
	if not BabbleSpell then
		return ([[do
			local _,c = UnitClass(${unit})
			if c == "DRUID" then
				if UnitPowerType(${unit}) ~= 0 then
					value = %q
				end
			else
				value = %q
			end
		]]):format(L["True"], L["True"]), 'events', "UNIT_DISPLAYPOWER"
	else
		return ([[do
			local _,c = UnitClass(${unit})
			if c == "DRUID" then
				if UnitPowerType(${unit}) == 0 then
					local auras = DogTag___currentAuras[${unit}]
					if not auras[%q] and not auras[%q] and not auras[%q] and not auras[%q] and not auras[%q] and not auras[%q] then
						value = %q
					end
				else
					value = %q
				end
			else
				value = %q
			end
		end]]):format(BabbleSpell["Moonkin Form"], BabbleSpell["Aquatic Form"], BabbleSpell["Flight Form"], BabbleSpell["Swift Flight Form"], BabbleSpell["Travel Form"], BabbleSpell["Tree of Life"], L["True"], L["True"], L["True"]), 'events', (";"):join("UNIT_DISPLAYPOWER", BabbleSpell["Moonkin Form"], BabbleSpell["Aquatic Form"], BabbleSpell["Flight Form"], BabbleSpell["Swift Flight Form"], BabbleSpell["Travel Form"], BabbleSpell["Tree of Life"])
	end
end, ret = "string;nil", globals = "UnitClass;UnitPowerType;DogTag.__currentAuras"}

Tags.ShortDruidForm = "DruidForm:ShortDruidForm"
Tags["~ShortDruidForm"] = "~DruidForm"

Tags.IsUnit = {function(data)
	local arg = data.arg:lower()
	if not arg:find("%[") and not arg:find("%]") and not IsLegitimateUnit[arg] then
		return ("value = nil")
	end
	local unit = data.unit
	if unit then
		if not IsLegitimateUnit[unit] then
			return ("value = nil")
		end
		if unit == arg then
			return ("value = %q"):format(L["True"])
		end
		if (unit == "player" or unit == "pet" or unit:find("^party%d$") or unit:find("^partypet%d$")) and (arg == "player" or arg == "pet" or arg:find("^party%d$") or arg:find("^partypet%d$")) then
			return ("value = nil")
		elseif unit:find("^raid%d+") and (arg == "pet" or arg:find("^partypet%d$") or arg:find("^raidpet%d+$")) then
			return ("value = nil")
		elseif unit:find("^raidpet%d+") and (arg == "player" or arg:find("^party%d$") or arg:find("^raid%d+$")) then
			return ("value = nil")
		end
		return ("value = UnitIsUnit(${unit}, ${arg}) and %q"):format(L["True"])
	else
		return ("value = ((${unit} == ${arg}) or UnitIsUnit(${unit}, ${arg})) and %q"):format(L["True"])
	end
end, arg = "string", ret = "string;nil", events = "Special_IsUnit"}

Tags["~IsUnit"] = {function(data)
	local arg = data.arg:lower()
	if not arg:find("%[") and not arg:find("%]") and not IsLegitimateUnit[arg] then
		return ("value = %q"):format(L["True"])
	end
	local unit = data.unit
	if unit then
		if not IsLegitimateUnit[unit] then
			return ("value = %q"):format(L["True"])
		end
		if unit == arg then
			return ("value = %q"):format(L["True"])
		end
		if (unit == "player" or unit == "pet" or unit:find("^party%d$") or unit:find("^partypet%d$")) and (arg == "player" or arg == "pet" or arg:find("^party%d$") or arg:find("^partypet%d$")) then
			return ("value = %q"):format(L["True"])
		elseif unit:find("^raid%d+") and (arg == "pet" or arg:find("^partypet%d$") or arg:find("^raidpet%d+$")) then
			return ("value = %q"):format(L["True"])
		elseif unit:find("^raidpet%d+") and (arg == "player" or arg:find("^party%d$") or arg:find("^raid%d+$")) then
			return ("value = %q"):format(L["True"])
		end
	end
	return ("value = not UnitIsUnit(${unit}, ${arg}) and %q"):format(L["True"])
end, arg = "string", ret = "string;nil", events = "Special_IsUnit"}

Tags.IsPlayer = {([[value = UnitIsPlayer(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlayer"}

Tags["~IsPlayer"] = {([[value = not UnitIsPlayer(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlayer"}

Tags.IsPet = {([[value = not UnitIsPlayer(${unit}) and UnitPlayerControlled(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlayer;UnitPlayerControlled"}

Tags["~IsPet"] = {([[value = (UnitIsPlayer(${unit}) or not UnitPlayerControlled(${unit})) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitIsPlayer;UnitPlayerControlled"}

Tags.IsPlayerOrPet = {([[value = UnitPlayerControlled(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitPlayerControlled"}

Tags["~IsPlayerOrPet"] = {([[value = not UnitPlayerControlled(${unit}) and %q]]):format(L["True"]), ret = "string;nil", globals = "UnitPlayerControlled"}

Tags.HasAura = {function(data)
	if data.arg:find("%[") and data.arg:find("%]") then
		return [[value = "HasAura cannot support dynamic arguments."]]
	end
	if BabbleSpell then
		local arg = data.arg
		local localized = BabbleSpell:HasTranslation(arg)
		if localized then -- if arg is English
			arg = BabbleSpell[arg]
		end
		return ([[value = DogTag___currentAuras[${unit}][%q] and %q]]):format(arg, arg), 'events', arg
	else
		return [[value = DogTag___currentAuras[${unit}][${arg}] and ${arg}]], 'events', data.arg
	end
end, arg = "string", ret = "string;nil", globals = "DogTag.__currentAuras"}

Tags["~HasAura"] = {function(data)
	if data.arg:find("%[") and data.arg:find("%]") then
		return [[value = "HasAura cannot support dynamic arguments."]]
	end
	return ([[value = not DogTag___currentAuras[${unit}][${arg}] and %q]]):format(L["True"]), 'events', data.arg
end, arg = "string", ret = "string;nil", globals = "DogTag.__currentAuras"}

Tags.IsShadowform = "HasAura(Shadowform)"
Tags.IsFeignedDeath = {function(data)
	if BabbleSpell then
		return ([[value = UnitIsFeignDeath(${unit}) and %q]]):format(BabbleSpell["Feign Death"])
	else
		return ([[value = UnitIsFeignDeath(${unit}) and %q]]):format(L["Feigned Death"])
	end
end, ret = "string;nil", globals = "UnitIsFeignDeath"}
Tags.IsStealthed = ("HasAura(Stealth):HasAura(Shadowmeld):HasAura(Prowl)?Text(%s)"):format(L["Stealthed"])
Tags.HasShieldWall = "HasAura(Shield Wall)"
Tags.HasLastStand = "HasAura(Last Stand)"
Tags.HasSoulstone = ("HasAura(Soulstone):HasAura(Soulstone Resurrection)?Text(%q)"):format(L["Soulstoned"])
Tags.HasMisdirection = "HasAura(Misdirection)"
Tags.HasIceBlock = "HasAura(Ice Block)"
Tags.HasInvisibility = "HasAura(Invisibility)"
Tags.HasDivineIntervention = "HasAura(Divine Intervention)"

Tags.HasDebuffType = {function(data)
	if data.arg:find("%[") and data.arg:find("%]") then
		return [[value = "HasDebuffType cannot support dynamic arguments."]]
	end
	return [[value = DogTag___currentDebuffTypes[${unit}][${arg}] and ${arg}]], 'events', data.arg
end, arg = "string", ret = "string;nil", globals = "DogTag.__currentDebuffTypes"}

Tags["~HasDebuffType"] = {function(data)
	if data.arg:find("%[") and data.arg:find("%]") then
		return [[value = "HasDebuffType cannot support dynamic arguments."]]
	end
	return ([[value = not DogTag___currentDebuffTypes[${unit}][${arg}] and %q]]):format(L["True"]), 'events', data.arg
end, arg = "string", ret = "string;nil", globals = "DogTag.__currentDebuffTypes"}

Tags.HasMagicDebuff = "HasDebuffType(Magic)"
Tags.HasCurseDebuff = "HasDebuffType(Curse)"
Tags.HasPoisonDebuff = "HasDebuffType(Poison)"
Tags.HasDiseaseDebuff = "HasDebuffType(Disease)"

if date("%Y%m%d") < "20070803" then
	Tags.PvPRankNum = {[[value = UnitPVPRank(${unit})]], ret = "number", globals = "UnitPVPRank"}
end

Tags.PvPRank = {[[do
	local pvpname = UnitPVPName(${unit})
	local name = UnitName(${unit})
	if name ~= pvpname and pvpname then
		local str = "%s*" .. name .. "%s*"
		value = pvpname:gsub(str, '')
	end
end]], ret = "string;nil", events = "UNIT_NAME_UPDATE;PLAYER_ENTERING_WORLD", globals = "UnitPVPName;UnitName"}

Tags.Range = {function(data)
	if not RangeCheck then
		return [[]]
	else
		return [[value = RangeCheckLib:getRangeAsString(${unit})]], 'globals', "RangeCheck-1.0", 'events', "Update"
	end
end, ret = "string;nil"}

Tags.Threat = {function(data)
	if not Threat then
		return [[]]
	else
		return ([[if UnitIsFriend("player", ${unit}) then
			if UnitExists("target") then
				value = math_floor(ThreatLib:GetThreat(UnitName(${unit}), UnitName("target"))+0.5)
			else
				value = 0
			end
		else
			value = math_floor(ThreatLib:GetThreat(%q, UnitName(${unit}))+0.5)
		end]]):format(UnitName("player")), 'globals', "Threat-1.0;UnitName;UnitExists;math.floor;UnitIsFriend"
	end
end, ret = "number;nil", events = "PLAYER_TARGET_CHANGED(target);Threat"}

Tags.MaxThreat = {function(data)
	if not Threat then
		return [[]]
	else
		return [[if UnitIsFriend("player", ${unit}) then
			if UnitExists("target") then
				value = math_floor(ThreatLib:GetMaxThreatOnTarget(UnitName("target"))+0.5)
			else
				value = 0
			end
		else
			value = math_floor(ThreatLib:GetMaxThreatOnTarget(UnitName(${unit}))+0.5)
		end]], 'globals', "Threat-1.0;UnitName;math.floor;UnitExists;UnitIsFriend"
	end
end, ret = "number;nil", events = "Threat;Threat(target)"}

Tags.PercentThreat = {function(data)
	if not Threat then
		return [[]]
	else
		return ([[if UnitIsFriend("player", ${unit}) then
			if UnitExists("target") then
				local target = UnitName("target")
				local max = ThreatLib:GetMaxThreatOnTarget(target)
				if max == 0 then
					value = 0
				else
					value = math_floor(1000 * ThreatLib:GetThreat(UnitName(${unit}), target) / max + 0.5) / 10
				end
			else
				value = 0
			end
		else
			local name = UnitName(${unit})
			local max = ThreatLib:GetMaxThreatOnTarget(name)
			if max == 0 then
				value = 0
			else
				value = math_floor(1000 * ThreatLib:GetThreat(%q, name) / max + 0.5) / 10
			end
		end]]):format(UnitName("player"), UnitName("player")), 'globals', "Threat-1.0;UnitName;UnitExists;math.floor;UnitIsFriend"
	end
end, ret = "number;nil", events = "PLAYER_TARGET_CHANGED(target);Threat"}

Tags.MissingThreat = "MaxThreat:Sub([Threat])"
Tags.FractionalThreat = "Text([Threat]/[MaxThreat])"

Tags.HasNoThreat = {function(data)
	if not Threat then
		return ([[value = %q]]):format(L["True"])
	else
		return ([[if UnitIsFriend("player", ${unit}) then
			if UnitExists("target") then
				value = ThreatLib:GetThreat(UnitName(${unit}), UnitName("target")) == 0 and %q
			else
				value = %q
			end
		else
			value = ThreatLib:GetThreat(%q, UnitName(${unit})) == 0 and %q
		end]]):format(L["True"], L["True"], UnitName("player"), L["True"]), 'globals', "Threat-1.0;UnitName;UnitExists"
	end
end, ret = "string;nil", events = "PLAYER_TARGET_CHANGED(target);Threat"}

if date("%Y%m%d") < "20070721" then
	Tags.EnemyThreat = "Threat"
	Tags.MissingEnemyThreat = "MissingThreat"
	Tags.FractionalEnemyThreat = "FractionalThreat"
	Tags.MaxEnemyThreat = "MaxThreat"
	Tags.PercentEnemyThreat = "PercentThreat"
	Tags.HasNoEnemyThreat = "HasNoThreat"
end

Tags.Alt = {([[value = IsAltKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "AltKey", globals = "IsAltKeyDown"}

Tags["~Alt"] = {([[value = not IsAltKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "AltKey", globals = "IsAltKeyDown"}

Tags.Shift = {([[value = IsShiftKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "ShiftKey", globals = "IsShiftKeyDown"}

Tags["~Shift"] = {([[value = not IsShiftKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "ShiftKey", globals = "IsShiftKeyDown"}

Tags.Ctrl = {([[value = IsControlKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "CtrlKey", globals = "IsControlKeyDown"}

Tags["~Ctrl"] = {([[value = not IsControlKeyDown() and %q]]):format(L["True"]), ret = "string;nil", events = "CtrlKey", globals = "IsControlKeyDown"}

Tags.TalentSpec = {[[if UnitIsPlayer(${unit}) and UnitIsFriend("player", ${unit}) then
	local name, server = UnitName(${unit})
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	value = DogTag___talentSpecs[name]
end]], ret = "string;nil", events = "Talent", globals = "DogTag.__talentSpecs;UnitIsPlayer;UnitIsFriend;UnitName"}

Tags.TalentTree = {[[if UnitIsPlayer(${unit}) and UnitIsFriend("player", ${unit}) then
	local name, server = UnitName(${unit})
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	value = DogTag___talentSpecNames[name]
end]], ret = "string;nil", events = "Talent", globals = "DogTag.__talentSpecNames;UnitIsPlayer;UnitIsFriend;UnitName"}

Tags.AddonVersion = {[[if UnitIsPlayer(${unit}) and UnitIsFriend("player", ${unit}) then
	local name, server = UnitName(${unit})
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	value = DogTag___addonVersions[${arg}][name]
end]], ret = "string;nil", arg = "string", events = "AddonVersion", globals = "DogTag.__addonVersions;UnitIsPlayer;UnitIsFriend;UnitName"}

Tags._ = {[[value = "_ tag referenced improperly"]], arg = "string;number;nil", ret = "string;number;nil"}

Tags.RepColor = Modifiers.RepColor
Tags.StatusColor = Modifiers.StatusColor
Tags.HappyColor = Modifiers.HappyColor
Tags.HostileColor = Modifiers.HostileColor
Tags.ClassColor = Modifiers.ClassColor
Tags.HPColor = Modifiers.HPColor
Tags.AggroColor = Modifiers.AggroColor
Tags.DifficultyColor = Modifiers.DifficultyColor
Tags.PowerColor = Modifiers.PowerColor
Tags.CombatColor = Modifiers.CombatColor
Tags.Color = Modifiers.Color
-- colors
Tags.White = Modifiers.White
Tags.Red = Modifiers.Red
Tags.Green = Modifiers.Green
Tags.Blue = Modifiers.Blue
Tags.Cyan = Modifiers.Cyan
Tags.Fuchsia = Modifiers.Fuchsia
Tags.Yellow = Modifiers.Yellow
Tags.Gray = Modifiers.Gray

Tags.SmartMissingHP = "MissingHP:HideZero:Negate"

local function sortStringList(s)
	if not s then
		return nil
	end
	local list = newList((";"):split(s))
	table_sort(list)
	local q = table_concat(list, ';')
	list = del(list)
	return q
end

local TagEvents = {}
local ModifierEvents = {}
local TagAliases = {}
local ModifierAliases = {}
local TagAliasFunctions = {}
local ModifierAliasFunctions = {}
local TagArguments = {}
local ModifierArguments = {}
local TagReturns = {}
local ModifierReturns = {}
local ModifierValues = {}
local TagGlobals = {}
local ModifierGlobals = {}
do
	for tag, data in pairs(Tags) do
		if type(data) == "table" then
			local arg = sortStringList(data.arg)
			if arg and arg ~= "nil" then
				TagArguments[tag] = arg
				local a,b,c = (";"):split(arg)
				assert(a == "nil" or a == "number" or a == "string")
				assert(not b or b == "nil" or b == "number" or b == "string")
				assert(not c or c == "nil" or c == "number" or c == "string")
			end
			TagReturns[tag] = sortStringList(data.ret)
			if data.ret then
				local a,b,c = (";"):split(data.ret)
				assert(a == "nil" or a == "number" or a == "string")
				assert(not b or b == "nil" or b == "number" or b == "string")
				assert(not c or c == "nil" or c == "number" or c == "string")
			end
			TagEvents[tag] = sortStringList(data.events)
			TagGlobals[tag] = sortStringList(data.globals)
			if TagGlobals[tag] then
				local globals = newList((';'):split(TagGlobals[tag]))
				for _,v in ipairs(globals) do
					if not v:find("%.") then
						assert(_G[v], ("Unknown global: %q"):format(v))
					end
				end
				globals = del(globals)
			end
			local func = data[1]
			if Modifiers[tag] ~= Tags[tag] then
				del(Tags[tag])
			end
			Tags[tag] = func
		elseif type(data) == "string" then
			TagAliases[tag] = data
			Tags[tag] = nil
		elseif type(data) == "function" then
			TagAliases[tag] = data()
			TagAliasFunctions[tag] = data
			Tags[tag] = nil
		end
	end

	for mod, data in pairs(Modifiers) do
		if type(data) == "table" then
			local arg = sortStringList(data.arg)
			if arg and arg ~= "nil" then
				ModifierArguments[mod] = arg
				local a,b,c = (";"):split(arg)
				assert(a == "nil" or a == "number" or a == "string")
				assert(not b or b == "nil" or b == "number" or b == "string")
				assert(not c or c == "nil" or c == "number" or c == "string")
			end
			ModifierReturns[mod] = sortStringList(data.ret)
			if data.ret then
				local a,b,c = (";"):split(data.ret)
				assert(a == "nil" or a == "number" or a == "string" or a == "same")
				assert(not b or b == "nil" or b == "number" or b == "string" or b == "same")
				assert(not c or c == "nil" or c == "number" or c == "string" or c == "same")
			end
			local value = sortStringList(data.value)
			if value and value ~= "number;string" then
				ModifierValues[mod] = value
				local a,b = (";"):split(value)
				assert(a == "number" or a == "string")
				assert(not b or b == "number" or b == "string")
			end
			ModifierEvents[mod] = sortStringList(data.events)
			ModifierGlobals[mod] = sortStringList(data.globals)
			if ModifierGlobals[mod] then
				local globals = newList((';'):split(ModifierGlobals[mod]))
				for _,v in ipairs(globals) do
					if not v:find("%.") then
						assert(_G[v], ("Unknown global: %q"):format(v))
					end
				end
				globals = del(globals)
			end
			local func = data[1]
			del(Modifiers[mod])
			Modifiers[mod] = func
		elseif type(data) == "string" then
			ModifierAliases[mod] = data
			Modifiers[mod] = nil
		elseif type(data) == "function" then
			ModifierAliases[mod] = data()
			ModifierAliasFunctions[mod] = data
			Modifiers[mod] = nil
		end
	end
end

local correctCasing = setmetatable({},{__mode='kv',__index=function(self, tag)
	if not tag then
		return nil
	end
	if Tags[tag] or Modifiers[tag] or TagAliases[tag] or ModifierAliases[tag] then
		self[tag] = tag
		return tag
	end
	local tag_lower = tag:lower()
	for k in pairs(Tags) do
		if k:lower() == tag_lower then
			self[tag] = k
			return k
		end
	end
	for k in pairs(Modifiers) do
		if k:lower() == tag_lower then
			self[tag] = k
			return k
		end
	end
	for k in pairs(TagAliases) do
		if k:lower() == tag_lower then
			self[tag] = k
			return k
		end
	end
	for k in pairs(ModifierAliases) do
		if k:lower() == tag_lower then
			self[tag] = k
			return k
		end
	end
	self[tag] = tag
	return tag
end})

local function toliteral(value)
	if type(value) == "number" then
		return ("(%s)"):format(value)
	else
		return ("(%q)"):format(value)
	end
end

local function unpackAndDel(t, start, finish)
	if not start then
		start = 1
	elseif not finish then
		finish = #t
	end
	if start > finish then
		t = del(t)
		return
	end
	return t[start], unpackAndDel(t, start + 1, finish)
end

local function splitCode(code)
	if code:sub(1, 1) == "[" then
		local alpha, bravo, charlie = code:match("^(%b[])([:!%?])(.*)$")
		if alpha then
			return "_(" .. alpha .. ")", bravo, splitCode(charlie)
		end
		local alpha = code:match("^(%b[])$")
		if alpha then
			return splitCode(alpha:sub(2, -2))
		end
	end
	local nextSymbol = code:match("^[^:!%?%(]*(.)")
	if nextSymbol == "(" then
		local alpha, bravo, charlie = code:match("^([^%(]*%b())([:!%?])(.*)$")
		if alpha then
			return alpha, bravo, splitCode(charlie)
		end
		local alpha = code:match("^([^%(]*%b())$")
		if alpha then
			return alpha
		end
	end
	local alpha, bravo, charlie = code:match("^([^:!%?]*)([:!%?])(.*)$")
	if not alpha then
		return code
	end
	return alpha, bravo, splitCode(charlie)
end

local function _splitParam(code)
	local negate, tag, param = code:match("^(~*)([a-zA-Z_#]+)(%b())$")
	if param then
		param = param:sub(2, -2)
	end
	if tag then
		local t, unit = tag:match("([a-zA-Z_]+)#([a-zA-Z_]+)")
		if t then
			return t, param, ((negate:len() % 2) == 1 and true or false), unit:lower()
		else
			return tag, param, ((negate:len() % 2) == 1 and true or false), nil
		end
	else
		negate, tag = code:match("^(~*)(.+)$")
		if tag then
			local t, unit = tag:match("^([a-zA-Z_]+)#([a-zA-Z_]+)$")
			if t then
				return t, nil, ((negate:len() % 2) == 1 and true or false), unit:lower()
			else
				return tag, nil, ((negate:len() % 2) == 1 and true or false), nil
			end
		else
			return code, nil, nil, nil
		end
	end
end
local function splitParam(code)
	local code, param, negate, unit = _splitParam(code)
	code = correctCasing[code]
	if type(param) == "string" and param:find("%[") and param:find("%]") then
		param = DogTag:FixCasing(param)
	end
	if negate then
		local neg_code = '~' .. code
		if Tags[neg_code] or Modifiers[neg_code] or TagAliases[neg_code] or ModifierAliases[neg_code] then
			return neg_code, param, false, unit
		end
	end
	return code, param, negate, unit
end

local function joinParam(tag, param, negate, unit)
	if tag == "_" and param and param:find("^%[.*%]$") then
		local inner = param:sub(2, -2)
		if not inner:find("[%[%]%?!:]") then
			return inner
		end
		return param
	end
	local t = newList()
	if negate then
		t[#t+1] = "~"
	end
	t[#t+1] = tag
	if unit then
		t[#t+1] = "#"
		t[#t+1] = unit
	end
	if param then
		t[#t+1] = "("
		t[#t+1] = param
		t[#t+1] = ")"
	end
	local s = table_concat(t)
	t = del(t)
	return s
end

local parse, compileTree
local function _compileTree(code, globals, cachedTags, doneCachedTags, lastPossibleReturns)
	if type(code) == "string" then
		return code, 0, lastPossibleReturns
	end
	local ends
	local tmp
	code[1], ends, tmp = _compileTree(code[1], globals, cachedTags, doneCachedTags, lastPossibleReturns)
	if not code[1] then
		code = del(code)
		lastPossibleReturns = del(lastPossibleReturns)
		return nil, ends
	end
	lastPossibleReturns = tmp
	local t = newList()
	local finalPossibleReturns = newList()
	if not code[2] then
		local tag, param, negate, unit = splitParam(code[1])

		local func = Tags[tag]
		if func then
			local hasCache = false
			local firstCache = not doneCachedTags[code[1]]
			if cachedTags[code[1]] then
				hasCache = cachedTags[code[1]]
				doneCachedTags[code[1]] = true
				if not firstCache then
					t[#t+1] = "if "
					t[#t+1] = hasCache
					t[#t+1] = " ~= NIL then value = "
					t[#t+1] = hasCache
					t[#t+1] = ";"
					t[#t+1] = " else "
				end
			elseif code[1]:find("^~") and cachedTags[code[1]:sub(2)] then
				hasCache = cachedTags[code[1]:sub(2)]
				if tag:find("^~") then
					tag = tag:sub(2)
					negate = not negate
					func = Tags[tag]
					assert(func)
				end
				doneCachedTags[code[1]] = true
				if not firstCache then
					t[#t+1] = "if "
					t[#t+1] = hasCache
					t[#t+1] = " ~= NIL then value = not "
					t[#t+1] = hasCache
					t[#t+1] = (" and %q;"):format(L["True"])
					t[#t+1] = " else "
				end
			end
			if param then
				if not TagArguments[tag] then
					t = del(t)
					code = del(code)
					lastPossibleReturns = del(lastPossibleReturns)
					finalPossibleReturns = del(finalPossibleReturns)
					return nil, ("%q Unexpected parameter to %q"):format(param, tag)
				end
				if TagArguments[tag]:find("number") then
					param = tonumber(param) or param
					if type(param) ~= "number" and not TagArguments[tag]:find("string")  and (not param:find("%[") or not param:find("%]")) then
						-- must be number
						t = del(t)
						code = del(code)
						lastPossibleReturns = del(lastPossibleReturns)
						finalPossibleReturns = del(finalPossibleReturns)
						return nil, ("%q Bad param to %q. Expected number."):format(param, tag)
					end
				end
			else
				if TagArguments[tag] and not TagArguments[tag]:find("nil") then
					t = del(t)
					code = del(code)
					lastPossibleReturns = del(lastPossibleReturns)
					finalPossibleReturns = del(finalPossibleReturns)
					return nil, ("%q Expected parameter"):format(tag)
				end
			end
			if unit and unit ~= "player" then
				if not IsLegitimateUnit[unit] then
					t = del(t)
					code = del(code)
					lastPossibleReturns = del(lastPossibleReturns)
					finalPossibleReturns = del(finalPossibleReturns)
					return nil, ("%q Unknown unit"):format(unit)
				end
				t[#t+1] = ("if UnitExists(%q) then "):format(unit)
				ends = ends + 1
			end
			if negate and not TagReturns[tag]:find("nil") then
				if hasCache then
					t[#t+1] = " end;"
				end
				t[#t+1] = "value = nil;"
				finalPossibleReturns["nil"] = true
			else
				local g = TagGlobals[tag]
				if g then
					g = newList((";"):split(g))
					for _,v in ipairs(g) do
						globals[v] = true
					end
					g = del(g)
				end

				if type(func) == "function" then
					local data = newList()
					data.isMod = false
					data.unit = unit
					data.unit_str = unit and ("(%q)"):format(unit) or "(unit)"
					data.arg = param
					data.arg_str = param and toliteral(param) or "(nil)"
					data.arg_string = param and ("(%q)"):format(param) or '("nil")'
					data.argtype = ("(%q)"):format(type(param))
					local hash = newDict('func', func(data))
					func = hash.func
					if hash.globals then
						g = newList((";"):split(hash.globals))
						for _,v in ipairs(g) do
							globals[v] = true
						end
						g = del(g)
					end
					hash = del(hash)
					data = del(data)
				end
				if param then
					if type(param) == "string" and param:find("%[") and param:find("%]") then
						local single = param:find("^%[[^%[%]]+%]$") and tag ~= "_"
						local possibleReturns

						if not single then
							if tag ~= "_" then
								t[#t+1] = "local v = value;"
							end

							t[#t+1] = "" -- placeholder

							local t_id = #t
							local madeT = false
							local t_numstart = math.random(1, 10000000)
							local t_num = t_numstart
							local t_literal = newList()
							local st = 1
							t[#t+1] = [[do ]]
							while st <= param:len() do
								local start, fin, left, literal = param:find("^(.-)(%b[])", st)
								if not start then
									local rest = param:sub(st)
									if rest:len() > 0 then
										if not madeT then
											t[#t+1] = ("value = %q"):format(rest)
											if possibleReturns then
												possibleReturns = del(possibleReturns)
											end
											possibleReturns = newSet("string")
										else
											t_literal[t_num+1] = rest
										end
									end
									break
								end
								if not madeT and (left:len() > 0 or start ~= 1 or fin ~= param:len()) then
									madeT = true
								end
								local inner = literal:sub(2, -2)
								st = fin+1
								if left:len() > 0 then
									t_literal[t_num] = left
								end

								local u = newList()
								if madeT then
									u[#u+1] = "do "
								end
								u[#u+1] = "value = nil;"

								local result, ret = compileTree(parse(splitCode(inner)), globals, cachedTags, doneCachedTags)
								u[#u+1] = result

								if madeT then
									t_num = t_num + 1
									u[#u+1] = ([[t_%d = value or '';]]):format(t_num)
									u[#u+1] = [[end;]]
									if ret then
										ret = del(ret)
									end
								else
									possibleReturns = ret
								end
								local s = table_concat(u)
								u = del(u)
								t[#t+1] = s
							end
							if madeT then
								local u = newList()
								for i = t_numstart+1, t_num do
									u[i] = ("local t_%d = '';"):format(i)
								end
								t[t_id] = table_concat(u)
								u = del(u)
								t[#t+1] = [[value = ]]
								if t_literal[0] then
									t[#t+1] = ("%q"):format(t_literal[0])
									t[#t+1] = " .. "
								end
								for i = t_numstart+1, t_num+1 do
									if i <= t_num then
										t[#t+1] = "t_"
										t[#t+1] = i
										t[#t+1] = " .. "
									end
									if t_literal[i] then
										t[#t+1] = ("%q"):format(t_literal[i])
										t[#t+1] = " .. "
									end
								end
								t[#t] = [[;]]

								possibleReturns = newSet("string")
							end
							t_literal = del(t_literal)
							t[#t+1] = [[end;]]
						end
						if tag ~= "_" then
							if single then
								local result, ret = compileTree(parse(splitCode(param:sub(2, -2))), globals, cachedTags, doneCachedTags)
								result = result:gsub("%f[A-Za-z0-9_]value%f[^A-Za-z0-9_]", "arg")
								possibleReturns = ret
								t[#t+1] = "local arg;"
								t[#t+1] = result
							else
								t[#t+1] = "local arg = value;"
							end
							local set = newSet((";"):split(TagArguments[tag] or 'nil'))
							if set["nil"] then
								if set.number then
									if set.string then
										-- do nothing
									else
										if (not possibleReturns["nil"] and not possibleReturns.number) or possibleReturns.string then
											t[#t+1] = "arg = tonumber(arg);"
										end
									end
								else
									if set.string then
										if possibleReturns.number then
											if possibleReturns["nil"] then
												t[#t+1] = "if arg then arg = tostring(arg) end;"
											else
												t[#t+1] = "arg = tostring(arg);"
											end
										end
									else
										error(("Bad argument list. Can't just return nil. %q"):format(tag))
									end
								end
							else
								if set.number then
									if set.string then
										if possibleReturns["nil"] then
											t[#t+1] = "if not arg then arg = '' end;"
										end
									else
										if possibleReturns["nil"] or possibleReturns.string then
											t[#t+1] = "arg = tonumber(arg) or 0;"
										end
									end
								else
									if set.string then
										if not possibleReturns["nil"] then
											if possibleReturns.number then
												t[#t+1] = "arg = tostring(arg);"
											end
										else
											if possibleReturns.number then
												t[#t+1] = "if arg then arg = tostring(arg) else arg = '' end;"
											else
												t[#t+1] = "if not arg then arg = '' end;"
											end
										end
									else
										error(("Bad argument list. Can't just return nil. %q"):format(tag))
									end
								end
							end
							set = del(set)
							t[#t+1] = "value = v;"
						end
						if possibleReturns then
							possibleReturns = del(possibleReturns)
						end
						func = func:gsub("${arg}", "(arg)")
						func = func:gsub("%(${arg}%)", "(arg)")
						local pos = func:find("${arg:string}")
						if pos and func:find("${arg:string}", pos+1) then
							t[#t+1] = "local arg_string = tostring(arg);"
							func = func:gsub("%(${arg:string}%)", "(arg_string)")
							func = func:gsub("${arg:string}", "(arg_string)")
						else
							func = func:gsub("%(${arg:string}%)", "(tostring(arg))")
							func = func:gsub("${arg:string}", "(tostring(arg))")
						end
						local pos = func:find("${argtype}")
						if pos and func:find("${argtype}", pos+1) then
							t[#t+1] = "local argtype = type(arg);"
							func = func:gsub("%(${argtype}%)", "(argtype)")
							func = func:gsub("${argtype}", "(argtype)")
						else
							func = func:gsub("%(${argtype}%)", "(type(arg))")
							func = func:gsub("${argtype}", "(type(arg))")
						end
					else
						func = func:gsub("%(${arg}%)", toliteral(param))
						func = func:gsub("${arg}", toliteral(param))
						func = func:gsub("%(${arg:string}%)", ("(%q)"):format(param))
						func = func:gsub("${arg:string}", ("(%q)"):format(param))
						func = func:gsub("%(${argtype}%)", ("(%q)"):format(type(param)))
						func = func:gsub("${argtype}", ("(%q)"):format(type(param)))
					end
				else
					func = func:gsub("%(${arg}%)", "(nil)")
					func = func:gsub("${arg}", "(nil)")
					func = func:gsub("%(${arg:string}%)", '("nil")')
					func = func:gsub("${arg:string}", '("nil")')
					func = func:gsub("%(${argtype}%)", '("nil")')
					func = func:gsub("${argtype}", '("nil")')
				end
				if unit then
					func = func:gsub("%(${unit}%)", ("(%q)"):format(unit))
					func = func:gsub("${unit}", ("(%q)"):format(unit))
				else
					func = func:gsub("%(${unit}%)", "(unit)")
					func = func:gsub("${unit}", "(unit)")
				end
				if tag ~= "_" then
					t[#t+1] = func
					if func ~= "" then
						t[#t+1] = ";"
					end
				end
				if hasCache then
					t[#t+1] = hasCache
					t[#t+1] = " = value;"
				end
				if negate then
					t[#t+1] = ("value = not value and %q;"):format(L["True"])
					finalPossibleReturns["string"] = true
					finalPossibleReturns["nil"] = true
				else
					local tagRet = newList((';'):split(TagReturns[tag]))
					for _,v in ipairs(tagRet) do
						finalPossibleReturns[v] = true
					end
					tagRet = del(tagRet)
				end
				if hasCache and not firstCache then
					t[#t+1] = " end;"
				end
			end
		else
			t = del(t)
			code = del(code)
			lastPossibleReturns = del(lastPossibleReturns)
			finalPossibleReturns = del(finalPossibleReturns)
			return nil, ("%q Unknown tag"):format(tag)
		end
	elseif code[2] == "?" then
		t[#t+1] = code[1]
		t[#t+1] = ("if value then value = nil;")
		local q, e = _compileTree(code[3], globals, cachedTags, doneCachedTags, newSet("nil"))
		if not q then
			t = del(t)
			code = del(code)
			lastPossibleReturns = del(lastPossibleReturns)
			finalPossibleReturns = del(finalPossibleReturns)
			return nil, e
		end
		t[#t+1] = q
		for i = 1, e do
			t[#t+1] = "end;"
		end
		if code[4] == "!" then
			t[#t+1] = ("else ")
			local q, e = _compileTree(code[5], globals, cachedTags, doneCachedTags, newSet("nil"))
			if not q then
				t = del(t)
				code = del(code)
				lastPossibleReturns = del(lastPossibleReturns)
				finalPossibleReturns = del(finalPossibleReturns)
				return nil, e
			end
			t[#t+1] = q
			for i = 1, e do
				t[#t+1] = "end;"
			end
		end
		t[#t+1] = ("end;")
	elseif code[2] == ":" then
		t[#t+1] = code[1]
		local mod, param, negate, unit = splitParam(code[3])
		local func = Modifiers[mod] or Tags[mod]
		if func then
			local isMod = func == Modifiers[mod]
			local hasCache = false
			local firstCache = not doneCachedTags[code[3]]
			if not isMod then
				if cachedTags[code[3]] then
					hasCache = cachedTags[code[3]]
					doneCachedTags[code[3]] = true
					if not firstCache then
						t[#t+1] = "if "
						t[#t+1] = hasCache
						t[#t+1] = " ~= NIL then value = "
						t[#t+1] = hasCache
						t[#t+1] = ";"
						t[#t+1] = " else "
					end
				elseif code[1]:find("^~") and cachedTags[code[3]:sub(2)] then
					hasCache = cachedTags[code[3]:sub(2)]
					if mod:find("^~") then
						mod = mod:sub(2)
						negate = not negate
						func = Tags[mod]
						assert(func)
					end
					doneCachedTags[code[3]] = true
					if not firstCache then
						t[#t+1] = "if "
						t[#t+1] = hasCache
						t[#t+1] = " ~= NIL then value = not "
						t[#t+1] = hasCache
						t[#t+1] = (" and %q;"):format(L["True"])
						t[#t+1] = " else "
					end
				end
			end
			if param then
				local arg = (isMod and ModifierArguments[mod]) or (not isMod and TagArguments[mod])
				if not arg then
					t = del(t)
					code = del(code)
					lastPossibleReturns = del(lastPossibleReturns)
					finalPossibleReturns = del(finalPossibleReturns)
					return nil, ("%q Unexpected param to %q"):format(param, mod)
				end

				if arg:find("number") then
					param = tonumber(param) or param
					if type(param) ~= "number" and not arg:find("string") and (not param:find("%[") or not param:find("%]")) then
						-- must be number
						t = del(t)
						code = del(code)
						lastPossibleReturns = del(lastPossibleReturns)
						finalPossibleReturns = del(finalPossibleReturns)
						return nil, ("%q Bad param to %q. Expected number."):format(param, mod)
					end
				end
			else
				local arg = (isMod and ModifierArguments[mod]) or (not isMod and TagArguments[mod])
				if arg and not arg:find("nil") then
					t = del(t)
					code = del(code)
					lastPossibleReturns = del(lastPossibleReturns)
					finalPossibleReturns = del(finalPossibleReturns)
					return nil, ("%q Expected parameter"):format(mod)
				end
			end
			if unit and not IsLegitimateUnit[unit] then
				t = del(t)
				code = del(code)
				lastPossibleReturns = del(lastPossibleReturns)
				finalPossibleReturns = del(finalPossibleReturns)
				return nil, ("%q Unknown unit"):format(unit)
			end
			if isMod then
				local val = ModifierValues[mod]
				if val and ((val == "number" and lastPossibleReturns["string"]) or (val == "string" and lastPossibleReturns["number"])) then
					t[#t+1] = [[if type(value) == "]]
					t[#t+1] = val
					t[#t+1] = [[" ]]
					if unit and unit ~= "player" then
						t[#t+1] = "and UnitExists("
						t[#t+1] = ("%q"):format(unit)
						t[#t+1] = ") "
					end
					t[#t+1] = "then "
					if val == "number" then
						if lastPossibleReturns.string then
							finalPossibleReturns.string = true
						end
					else
						if lastPossibleReturns.number then
							finalPossibleReturns.number = true
						end
					end
				elseif lastPossibleReturns["nil"] then
					t[#t+1] = "if value "
					if unit and unit ~= "player" then
						t[#t+1] = "and UnitExists("
						t[#t+1] = ("%q"):format(unit)
						t[#t+1] = ") "
					end
					t[#t+1] = "then "
				elseif unit and unit ~= "player" then
					t[#t+1] = "if UnitExists("
					t[#t+1] = ("%q"):format(unit)
					t[#t+1] = ") "
					t[#t+1] = "then "
				else
					t[#t+1] = "do "
				end
			else
				t[#t+1] = "if not value "
				if unit and unit ~= "player" then
					t[#t+1] = "and UnitExists("
					t[#t+1] = ("%q"):format(unit)
					t[#t+1] = ") "
				end
				t[#t+1] = "then "
				ends = ends + 1
			end
			if not negate or (isMod and ModifierReturns[mod]:find("nil")) or (not isMod and TagReturns[mod]:find("nil")) then
				if negate and isMod then
					t[#t+1] = "local old_value = value;"
				end
				local g
				if isMod then
					g = ModifierGlobals[mod]
				else
					g = TagGlobals[mod]
				end
				if g then
					g = newList((";"):split(g))
					for _,v in ipairs(g) do
						globals[v] = true
					end
					g = del(g)
				end
				if type(func) == "function" then
					local data = newList()
					data.isMod = isMod
					data.unit = unit
					data.unit_str = unit and ("(%q)"):format(unit) or "(unit)"
					data.arg = param
					data.arg_str = param and toliteral(param) or "(nil)"
					data.arg_string = param and ("(%q)"):format(param) or '("nil")'
					data.argtype = ("(%q)"):format(type(param))
					local hash = newDict('func', func(data))
					func = hash.func
					if hash.globals then
						g = newList((";"):split(hash.globals))
						for _,v in ipairs(g) do
							globals[v] = true
						end
						g = del(g)
					end
					hash = del(hash)
					data = del(data)
				end
				if param then
					if type(param) == "string" and param:find("%[") and param:find("%]") then
						local single = param:find("^%[[^%[%]]+%]$") and mod ~= "_"
						local possibleReturns
						if not single then
							if mod ~= "_" then
								t[#t+1] = "local v = value;"
							end

							t[#t+1] = "" -- placeholder

							local t_id = #t
							local madeT = false
							local t_numstart = math.random(0, 10000000)
							local t_num = t_numstart
							local t_literal = newList()
							local st = 1
							t[#t+1] = [[do ]]
							while st <= param:len() do
								local start, fin, left, literal = param:find("^(.-)(%b[])", st)
								if not start then
									local rest = param:sub(st)
									if rest:len() > 0 then
										if not madeT then
											t[#t+1] = ("value = %q"):format(rest)
											if possibleReturns then
												possibleReturns = del(possibleReturns)
											end
											possibleReturns = newSet("string")
										else
											t_literal[t_num+1] = rest
										end
									end
									break
								end
								if not madeT and (left:len() > 0 or start ~= 1 or fin ~= param:len()) then
									madeT = true
								end
								local inner = literal:sub(2, -2)
								st = fin+1
								if left:len() > 0 then
									t_literal[t_num] = left
								end

								local u = newList()
								if madeT then
									u[#u+1] = "do "
								end
								u[#u+1] = "value = nil;"

								local result, ret = compileTree(parse(splitCode(inner)), globals, cachedTags, doneCachedTags)
								u[#u+1] = result

								if madeT then
									t_num = t_num + 1
									u[#u+1] = ([[t_%d = value or '';]]):format(t_num)
									u[#u+1] = [[end;]]
								else
									possibleReturns = ret
								end
								local s = table_concat(u)
								u = del(u)
								t[#t+1] = s
							end
							if madeT then
								local u = newList()
								for i = t_numstart+1, t_num do
									u[i] = ("local t_%d = '';"):format(i)
								end
								t[t_id] = table_concat(u)
								u = del(u)
								t[#t+1] = [[value = ]]
								if t_literal[0] then
									t[#t+1] = ("%q"):format(t_literal[0])
									t[#t+1] = " .. "
								end
								for i = t_numstart+1, t_num+1 do
									if i <= t_num then
										t[#t+1] = "t_"
										t[#t+1] = i
										t[#t+1] = " .. "
									end
									if t_literal[i] then
										t[#t+1] = ("%q"):format(t_literal[i])
										t[#t+1] = " .. "
									end
								end
								t[#t] = [[;]]
								possibleReturns = newSet("string")
							end
							t_literal = del(t_literal)
							t[#t+1] = [[end;]]
						end
						if mod ~= "_" then
							if single then
								local result, ret = compileTree(parse(splitCode(param:sub(2, -2))), globals, cachedTags, doneCachedTags)
								result = result:gsub("%f[A-Za-z0-9_]value%f[^A-Za-z0-9_]", "arg")
								possibleReturns = ret
								t[#t+1] = "local arg;"
								t[#t+1] = result
							else
								t[#t+1] = "local arg = value;"
							end
							local set = newSet((";"):split((isMod and ModifierArguments[mod]) or (not isMod and TagArguments[mod]) or 'nil'))
							if set["nil"] then
								if set.number then
									if set.string then
										-- do nothing
									else
										if (not possibleReturns["nil"] and not possibleReturns.number) or possibleReturns.string then
											t[#t+1] = "arg = tonumber(arg);"
										end
									end
								else
									if set.string then
										if possibleReturns.number then
											if possibleReturns["nil"] then
												t[#t+1] = "if arg then arg = tostring(arg) end;"
											else
												t[#t+1] = "arg = tostring(arg);"
											end
										end
									else
										error(("Bad argument list. Can't just return nil. %q"):format(mod))
									end
								end
							else
								if set.number then
									if set.string then
										if possibleReturns["nil"] then
											t[#t+1] = "if not arg then arg = '' end;"
										end
									else
										if possibleReturns["nil"] or possibleReturns.string then
											t[#t+1] = "arg = tonumber(arg) or 0;"
										end
									end
								else
									if set.string then
										if not possibleReturns["nil"] then
											if possibleReturns.number then
												t[#t+1] = "arg = tostring(arg);"
											end
										else
											if possibleReturns.number then
												t[#t+1] = "if arg then arg = tostring(arg) else arg = '' end;"
											else
												t[#t+1] = "if not arg then arg = '' end;"
											end
										end
									else
										error(("Bad argument list. Can't just return nil. %q"):format(mod))
									end
								end
							end
							set = del(set)
							if not single then
								t[#t+1] = "value = v;"
							end
						end
						if possibleReturns then
							possibleReturns = del(possibleReturns)
						end
						func = func:gsub("%(${arg}%)", "(arg)")
						func = func:gsub("${arg}", "(arg)")
						local pos = func:find("${arg:string}")
						if pos and func:find("${arg:string}", pos+1) then
							t[#t+1] = "local arg_string = tostring(arg);"
							func = func:gsub("%(${arg:string}%)", "(arg_string)")
							func = func:gsub("${arg:string}", "(arg_string)")
						else
							func = func:gsub("%(${arg:string}%)", "(tostring(arg))")
							func = func:gsub("${arg:string}", "(tostring(arg))")
						end
						local pos = func:find("${argtype}")
						if pos and func:find("${argtype}", pos+1) then
							t[#t+1] = "local argtype = type(arg);"
							func = func:gsub("%(${argtype}%)", "(argtype)")
							func = func:gsub("${argtype}", "(argtype)")
						else
							func = func:gsub("%(${argtype}%)", "(type(arg))")
							func = func:gsub("${argtype}", "(type(arg))")
						end
					else
						func = func:gsub("%(${arg}%)", toliteral(param))
						func = func:gsub("${arg}", toliteral(param))
						func = func:gsub("%(${arg:string}%)", ("(%q)"):format(param))
						func = func:gsub("${arg:string}", ("(%q)"):format(param))
						func = func:gsub("%(${argtype}%)", ("(%q)"):format(type(param)))
						func = func:gsub("${argtype}", ("(%q)"):format(type(param)))
					end
				else
					func = func:gsub("%(${arg}%)", "(nil)")
					func = func:gsub("${arg}", "(nil)")
					func = func:gsub("%(${arg:string}%)", '("nil")')
					func = func:gsub("${arg:string}", '("nil")')
					func = func:gsub("%(${argtype}%)", '("nil")')
					func = func:gsub("${argtype}", '("nil")')
				end
				if unit then
					func = func:gsub("%(${unit}%)", ("(%q)"):format(unit))
					func = func:gsub("${unit}", ("(%q)"):format(unit))
				else
					func = func:gsub("%(${unit}%)", "(unit)")
					func = func:gsub("${unit}", "(unit)")
				end
				if mod ~= "_" then
					t[#t+1] = func
					if func ~= "" then
						t[#t+1] = ";"
					end
				end
				if hasCache then
					t[#t+1] = hasCache
					t[#t+1] = " = value;"
				end
				if negate then
					t[#t+1] = "value = not value and "
					if isMod then
						t[#t+1] = "old_value"
						t[#t+1] = " end;"
					else
						t[#t+1] = ("%q;"):format(L["True"])
					end
					finalPossibleReturns["string"] = true
					finalPossibleReturns["nil"] = true
				elseif isMod then
					t[#t+1] = " end;"
				end
				if not negate then
					local rets = newSet((';'):split((isMod and ModifierReturns[mod]) or (not isMod and TagReturns[mod])))
					if rets.same then
						rets.same = nil
						if not lastPossibleReturns.number and not lastPossibleReturns.string then
							finalPossibleReturns.number = true
							finalPossibleReturns.string = true
						else
							finalPossibleReturns.number = lastPossibleReturns.number
							finalPossibleReturns.string = lastPossibleReturns.string
						end
					end
					for v in pairs(rets) do
						finalPossibleReturns[v] = true
					end
					if lastPossibleReturns["nil"] then
						finalPossibleReturns["nil"] = true
					end
					if lastPossibleReturns.number then
						finalPossibleReturns.number = true -- FIXME
					end
					if lastPossibleReturns.string then
						finalPossibleReturns.string = true -- FIXME
					end
					rets = del(rets)
				end
				if hasCache and not firstCache then
					t[#t+1] = " end;"
				end
			else
				t[#t+1] = "value = nil;"
			end
		else
			t = del(t)
			code = del(code)
			lastPossibleReturns = del(lastPossibleReturns)
			finalPossibleReturns = del(finalPossibleReturns)
			return nil, ("%q Unknown modifier or tag"):format(mod)
		end
	else
		t = del(t)
		code = del(code)
		lastPossibleReturns = del(lastPossibleReturns)
		finalPossibleReturns = del(finalPossibleReturns)
		return nil, ("%q Unknown separator"):format(code[2])
	end
	code = del(code)
	lastPossibleReturns = del(lastPossibleReturns)
	local s = table_concat(t)
	t = del(t)
	return s, ends, finalPossibleReturns
end

function compileTree(code, globals, cachedTags, doneCachedTags)
	local madeDoneCachedTags = not doneCachedTags
	if madeDoneCachedTags then
		doneCachedTags = newList()
	end
	local q, e, possibleReturns = _compileTree(code, globals, cachedTags, doneCachedTags, newSet("nil"))
	if not q then
		return ("value = %q;"):format(e), newSet("string")
	end
	for i = 1, e do
		q = q .. "end;"
	end
	if madeDoneCachedTags then
		doneCachedTags = del(doneCachedTags)
	end
	return q, possibleReturns
end

local function select2(min, max, ...)
	if min <= max then
		return select(min, ...), select2(min+1, max, ...)
	end
end

function parse(...)
	local n = select('#', ...)
	if n == 1 then
		return newList((...))
	end
	local q_num = 0
	local q_pos
	local x_pos
	for i = 1, n do
		if select(i, ...) == "?" then
			q_num = q_num + 1
			if not q_pos then
				q_pos = i
			end
		elseif select(i, ...) == "!" then
			q_num = q_num - 1
			if q_num == 0 then
				x_pos = i
				break
			end
		end
	end
	if q_pos then
		if not x_pos then
			return newList(parse(select2(1, q_pos - 1, ...)), "?", parse(select(q_pos + 1, ...)))
		else
			return newList(parse(select2(1, q_pos - 1, ...)), "?", parse(select2(q_pos + 1, x_pos - 1, ...)), "!", parse(select(x_pos + 1, ...)))
		end
	end
	return newList(parse(select2(1, n - 2, ...)), ":", select(n, ...))
end

local function cleanText(text)
	while true do
		local lastText = text
		text = string_gsub(text, " +$", "")
		text = string_gsub(text, "^ +", "")
		text = string_gsub(text, "  +", " ")
		text = string_gsub(text, "|| ||", "||")
		text = string_gsub(text, "^||", "")
		text = string_gsub(text, "||$", "")
		if text == lastText then
			if text == "" then
				return " "
			end
			return text
		end
	end
end

local UnitToLocale = {player = L["Player"], target = L["Target"], pet = L["%s's pet"]:format(L["Player"]), focus = L["Focus-target"], mouseover = L["Mouse-over"]}
setmetatable(UnitToLocale, {__index=function(self, unit)
	if unit:find("pet$") then
		local nonPet = unit:sub(1, -4)
		self[unit] = L["%s's pet"]:format(self[nonPet])
		return self[unit]
	elseif not unit:find("target$") then
		if unit:find("^party%d$") then
			local num = unit:match("^party(%d)$")
			self[unit] = L["Party member #%d"]:format(num)
			return self[unit]
		elseif unit:find("^raid%d%d?$") then
			local num = unit:match("^raid(%d%d?)$")
			self[unit] = L["Raid member #%d"]:format(num)
			return self[unit]
		elseif unit:find("^partypet%d$") then
			local num = unit:match("^partypet(%d)$")
			self[unit] = UnitToLocale["party" .. num .. "pet"]
			return self[unit]
		elseif unit:find("^raidpet%d%d?$") then
			local num = unit:match("^raidpet(%d%d?)$")
			self[unit] = UnitToLocale["raid" .. num .. "pet"]
			return self[unit]
		end
		self[unit] = unit
		return unit
	end
	local nonTarget = unit:sub(1, -7)
	self[unit] = L["%s's target"]:format(self[nonTarget])
	return self[unit]
end})

local GetOfflineTime, GetAFKTime, GetDeadTime

local figureCachedTags
do
	local _figureCachedTags
	local function __figureCachedTags(code, data)
		for i = 1, #code, 2 do
			local v = code[i]
			if type(v) == "table" then
				__figureCachedTags(v, data)
			else
				local tag, param, negate, unit = splitParam(v)
				if param and param:find("%[") and param:find("%]") then
					_figureCachedTags(v, data)
				elseif Tags[tag] then
					data[v] = (data[v] or 0) + 1
				end
			end
		end
	end
	function _figureCachedTags(code, data)
		local st = 1
		while st <= code:len() do
			local start, fin, left, literal = code:find("^(.-)(%b[])", st)
			if not start then
				break
			end
			local inner = literal:sub(2, -2)
			st = fin+1
			local tree = parse(splitCode(inner))
			__figureCachedTags(tree, data)
		end
	end
	function figureCachedTags(code)
		local data = newList()
		_figureCachedTags(code, data)
		for k, v in pairs(data) do
			if k:find("^~") and data[k:sub(2)] then
				data[k:sub(2)] = data[k:sub(2)] + v
				data[k] = nil
			end
		end
		for k, v in pairs(data) do
			if v == 1 then
				data[k] = nil
			else
				data[k] = k:gsub("[^A-Za-z0-9_]", "_")
			end
		end
		return data
	end
end

local antiAlias
do
	local antiAliasWithUnit
	local handler__unit = nil
	local function handler(literal)
		local inner = literal:sub(2,-2)
		local code = newList(splitCode(inner))
		local real = newList()
		for i = 1, #code, 2 do
			local bit, param, negate, unit = splitParam(code[i])
			if not unit then
				unit = handler__unit
			end
			local func
			local isMod = false
			if code[i-1] ~= ":" then
				func = TagAliases[bit]
			else
				func = ModifierAliases[bit]
				if not func and not Modifiers[bit] then
					func = TagAliases[bit]
				else
					isMod = true
				end
			end
			if i == 1 then
				real[1] = "["
			else
				real[#real+1] = code[i-1]
			end
			if negate then
				real[#real+1] = "~"
			end
			if type(param) == "string" and param:find("%[") and param:find("%]") then
				param = antiAliasWithUnit(param, unit)
			end
			if func then
				local group = not isMod and func:find("[%?!:]")
				if group then
					real[#real+1] = "_(["
				end
				if param and func:find("[:%(%?!]") then
					if func:find("%(arg%)") then
						real[#real+1] = func:gsub("%(arg%)", "(" .. param .. ")")
					else
						real[#real+1] = joinParam(bit, param, nil, unit)
					end
				elseif unit and func:find("#") then
					real[#real+1] = joinParam(bit, param, nil, unit)
				elseif not func:find("[:%?!]") then
					local fbit, fparam, fnegate, funit = splitParam(func)
					real[#real+1] = joinParam(fbit, antiAliasWithUnit(fparam, unit) or param, fnegate, funit or unit)
				elseif unit then
					if param then
						real[#real+1] = joinParam(bit, param, nil, unit)
					else
						local fcode = newList(splitCode(func))
						for j = 1, #fcode, 2 do
							if j > 1 then
								real[#real+1] = fcode[j-1]
							end
							local fbit, fparam, fnegate, funit = splitParam(fcode[j])
							real[#real+1] = joinParam(fbit, antiAliasWithUnit(fparam, unit), fnegate, unit)
						end
					end
				else
					real[#real+1] = func
					if param then
						real[#real+1] = "("
						real[#real+1] = param
						real[#real+1] = ")"
					end
				end
				if group then
					real[#real+1] = "])"
				end
			else
				real[#real+1] = joinParam(bit, param, nil, unit)
			end
		end
		code = del(code)

		real[#real+1] = ']'
		local str = table_concat(real):gsub("~~", "")
		real = del(real)
		return str
	end
	function antiAliasWithUnit(key, unit)
		if key == nil then
			return nil
		end
		if unit == nil then
			local value = rawget(antiAlias, key)
			if value then
				return value
			end
		end
		local value = key:gsub("~~", "")
		while true do
			local lastValue = value
			local last_handler__unit = handler__unit
			handler__unit = unit
			value = lastValue:gsub("(%b[])", handler)
			handler__unit = last_handler__unit
			if value == lastValue then
				break
			end
		end
		if unit == nil then
			antiAlias[key] = value
		end
		return value
	end
	antiAlias = setmetatable({}, {__index = function(self, key)
		return antiAliasWithUnit(key)
	end, __mode= 'k'})
end

function DogTag:UnaliasCode(code)
	return antiAlias[code]
end
precondition(DogTag, 'UnaliasCode', function(self, code)
	argCheck(code, 2, "string")
end)

local function enumLines(text)
	local lines = newList(('\n'):split(text))
	local t = newList()
	for i, v in ipairs(lines) do
		t[#t+1] = v
		t[#t+1] = " -- "
		t[#t+1] = i
		t[#t+1] = "\n"
	end
	lines = del(lines)
	local s = table_concat(t)
	t = del(t)
	return s
end

function DogTag:CreateFunctionFromCode(code, notDebug)
	if type(code) ~= "string" then
		error(("Bad argument #2 to `CreateFunctionFromCode'. Expected %q, got %q."):format("string", type(code)), 2)
	end
	code = antiAlias[code]
	if cleanText(code) == "" then
		return ""
	end
	local cachedTags = figureCachedTags(code)
	local t = newList()
	t[#t+1] = ([[local DogTag = LibStub(%q);]]):format(MAJOR_VERSION)
	t[#t+1] = [[local colors = DogTag.__colors;]]
	t[#t+1] = "" -- placeholder
	t[#t+1] = [[local NIL = {};]]
	t[#t+1] = [[local cleanText = DogTag.__cleanText;]]
	t[#t+1] = [[return function(unit) ]]
	local u = newList()
	for k, v in pairs(cachedTags) do
		u[#u+1] = "local "
		u[#u+1] = v
		u[#u+1] = " = NIL;"
	end
	t[#t+1] = table_concat(u)
	u = del(u)
	t[#t+1] = [[if not UnitExists(unit) then return ]]
	local globals = newList()
	globals['table.concat'] = true
	globals['string.gsub'] = true
	globals['type'] = true
	globals['tonumber'] = true
	globals['UnitExists'] = true
	if code:find("[%[%?:!][Nn][Aa][Mm][Ee][%]:%?!]") then
		t[#t+1] = [=[DogTag___UnitToLocale[unit]]=]
		globals['DogTag.__UnitToLocale'] = true
	else
		t[#t+1] = [[""]]
	end
	t[#t+1] = [[ end;]]
	t[#t+1] = "" -- placeholder
	local tmp_id = #t
	local madeTmp = false
	local tmp_num = 0
	local tmp_literal = newList()
	local st = 1
	while st <= code:len() do
		local start, fin, left, literal = code:find("^(.-)(%b[])", st)
		if not start then
			local rest = code:sub(st)
			if rest:len() > 0 then
				if not madeTmp then
					t[#t+1] = ("return %q"):format(rest)
				else
					tmp_literal[tmp_num+1] = rest
				end
			end
			break
		end
		if not madeTmp and (left:len() > 0 or start ~= 1 or fin ~= code:len()) then
			madeTmp = true
		end
		local inner = literal:sub(2, -2)
		st = fin+1
		if left:len() > 0 then
			tmp_literal[tmp_num] = left
		end
		if st < code:len() then
			madeTmp = true
		end

		local u = newList()
		u[#u+1] = "do local value;"

		local result, ret = compileTree(parse(splitCode(inner)), globals, cachedTags)
		if ret then
			ret = del(ret)
		end
		u[#u+1] = result
		if not madeTmp then
			u[#u+1] = [[return cleanText(value or '');]]
		else
			tmp_num = tmp_num + 1
			u[#u+1] = ([[tmp_%d = value or '';]]):format(tmp_num)
		end
		u[#u+1] = [[end;]]
		local s = table_concat(u)
		u = del(u)
		t[#t+1] = s
	end
	local u = newList()
	for i = 1, tmp_num do
		u[i] = ("local tmp_%d = '';"):format(i)
	end
	t[tmp_id] = table_concat(u)
	u = del(u)
	local u = newList()
	for k in pairs(globals) do
		if k:find("^Lib[A-Z][A-Za-z%-]%-%d+%.%d+$") then
			u[#u+1] = "local "
			u[#u+1] = k:gsub("%-.*", "")
			u[#u+1] = "Lib = Rock('"
			u[#u+1] = k
			u[#u+1] = "', false, true);"
		elseif k:find("[A-Za-z%-]*%-%d%.%d") then
			if Rock then
				Rock(k, false, true) -- try to load
			end
			if AceLibrary then
				AceLibrary:HasInstance(k) -- try to load
			end
			if LibStub(k, true) then
				-- catches Rock and AceLibrary
				u[#u+1] = "local "
				u[#u+1] = k:gsub("%-.*", "")
				u[#u+1] = "Lib = LibStub('"
				u[#u+1] = k
				u[#u+1] = "');"
			elseif AceLibrary then
				-- non-LibStub AceLibrary libs.
				u[#u+1] = "local "
				u[#u+1] = k:gsub("%-.*", "")
				u[#u+1] = "Lib = AceLibrary and AceLibrary:HasInstance('"
				u[#u+1] = k
				u[#u+1] = "') and AceLibrary('"
				u[#u+1] = k
				u[#u+1] = "');"
			end
		else
			u[#u+1] = "local "
			u[#u+1] = k:gsub("%.", "_")
			u[#u+1] = " = "
			u[#u+1] = k
			u[#u+1] = ";"
		end
	end
	globals = del(globals)
	t[3] = table_concat(u)
	u = del(u)
	if tmp_num > 0 then
		t[#t+1] = [[return cleanText(]]
		if tmp_literal[0] then
			t[#t+1] = ("%q"):format(tmp_literal[0])
			t[#t+1] = " .. "
		end
		for i = 1, tmp_num+1 do
			if i <= tmp_num then
				t[#t+1] = [[tmp_]]
				t[#t+1] = i
				t[#t+1] = " .. "
			end
			if tmp_literal[i] then
				t[#t+1] = ("%q"):format(tmp_literal[i])
				t[#t+1] = " .. "
			end
		end
		t[#t] = [[);]]
	end
	tmp_literal = del(tmp_literal)
	t[#t+1] = [[end;]]
	cachedTags = del(cachedTags)
	local s = table_concat(t)
	t = del(t)
	if not notDebug then
		s = enumLines(s:gsub(";", ";\n")) -- avoid interning the new string if not debugging
	end
	return s
end
precondition(DogTag, 'CreateFunctionFromCode', function(self, code, notDebug)
	argCheck(code, 2, "string")
	argCheck(notDebug, 3, "boolean", "nil")
end)

local codeToFunction; codeToFunction = setmetatable({}, {__index=function(self, key)
	local code = antiAlias[key]
	if code ~= key then
		self[key] = self[code]
		return self[key]
	end
	local s = DogTag:CreateFunctionFromCode(code, true)
	DogTag.__colors = colors
	DogTag.__cleanText = cleanText
	DogTag.__UnitToLocale = UnitToLocale
	DogTag.__currentAuras = currentAuras
	DogTag.__currentDebuffTypes = currentDebuffTypes
	DogTag.__guildNotes = guildNotes
	DogTag.__officerNotes = officerNotes
	DogTag.__GetOfflineTime = GetOfflineTime
	DogTag.__GetAFKTime = GetAFKTime
	DogTag.__GetDeadTime = GetDeadTime
	DogTag.__FigureNPCGuild = FigureNPCGuild
	DogTag.__FigureZone = FigureZone
	DogTag.__FigureFaction = FigureFaction
	DogTag.__abbreviate = abbreviate
	DogTag.__talentSpecs = talentSpecs
	DogTag.__talentSpecNames = talentSpecNames
	DogTag.__addonVersions = addonVersions
	local func, err = loadstring(s)
	local val
	if not func then
		geterrorhandler()(("DogTag-2.0: Error (%s) loading code %q. Please inform ckknight."):format(err, code))
		val = codeToFunction[""]
	else
		local status, result = pcall(func)
		if not status then
			geterrorhandler()(("DogTag-2.0: Error (%s) running code %q. Please inform ckknight."):format(result, code))
			val = codeToFunction[""]
		else
			val = result
		end
	end
	DogTag.__colors = nil
	DogTag.__cleanText = nil
	DogTag.__UnitToLocale = nil
	DogTag.__currentAuras = nil
	DogTag.__currentDebuffTypes = nil
	DogTag.__guildNotes = nil
	DogTag.__officerNotes = nil
	DogTag.__GetOfflineTime = nil
	DogTag.__GetAFKTime = nil
	DogTag.__GetDeadTime = nil
	DogTag.__FigureNPCGuild = nil
	DogTag.__FigureZone = nil
	DogTag.__FigureFaction = nil
	DogTag.__abbreviate = nil
	DogTag.__talentSpecs = nil
	DogTag.__talentSpecNames = nil
	DogTag.__addonVersions = nil
	self[code] = val
	return val
end, __mode='k'})

local NormalUnits = {player = true, pet = true, target = true, mouseover = true, focus = true}
for i = 1, 4 do
	NormalUnits['party' .. i] = true
	NormalUnits['partypet' .. i] = true
end
for i = 1, 40 do
	NormalUnits['raid' .. i] = true
end

local codeToEventList; codeToEventList = setmetatable({}, {__index = function(self, realkey)
	local key = antiAlias[realkey]
	if key ~= realkey then
		self[realkey] = self[key]
		return self[realkey]
	end
	local t = newList()
	local len = key:len()
	local st = 1
	while st <= len do
		local start, fin, left, literal = key:find("^(.-)(%b[])", st)
		if not start then
			break
		end
		local inner = literal:sub(2, -2)
		st = fin+1
		local code = newList(splitCode(inner))
		for i = 1, #code, 2 do
			local bit, param, negate, unit = splitParam(code[i])
			local func
			if code[i-1] ~= ":" then
				func = Tags[bit]
			else
				func = Modifiers[bit] or Tags[bit]
			end
			local isMod = func == Modifiers[bit]
			local eventList = (isMod and ModifierEvents[bit]) or (not isMod and TagEvents[bit])
			if type(func) == "function" then
				local data = newList()
				data.isMod = isMod
				data.unit = unit
				data.unit_str = unit and ("(%q)"):format(unit) or "(unit)"
				data.arg = param
				data.arg_str = param and toliteral(param) or "(nil)"
				data.arg_string = param and ("(%q)"):format(param) or '("nil")'
				data.argtype = ("(%q)"):format(type(param))
				local hash = newDict('func', func(data))
				data = del(data)
				if hash.events then
					if eventList then
						eventList = eventList .. ";" .. hash.events
					else
						eventList = hash.events
					end
				end
				hash = del(hash)
			end
			if unit == true then
				unit = nil
			end
			if unit and not NormalUnits[unit] then
				if eventList then
					eventList = eventList .. ";" .. "Update"
				else
					eventList = "Update"
				end
			end
			if eventList then
				local events = newList((";"):split(eventList))
				for _,event in ipairs(events) do
					if event == "Special_IsUnit" then
						if param == "player" or param == "pet" or param == "target" or param == "focus" or param == "mouseover" or param:find("^party%d$") or param:find("^partypet%d$") or param:find("^raid%d+$") or param:find("^raidpet%d+$") then
							t[event .. "=" .. param] = true
						else
							t["Update=" .. param] = true
						end
						if unit then
							t[event .. "=" .. unit] = true
						else
							t[event] = true
						end
					else
						local e, u = event:match("([A-Z_]+)%(([a-z]+)%)")
						if not e then
							e, u = event, unit
						end
						if u then
							t[e .. "=" .. u] = true
						else
							t[e] = true
						end
					end
				end
				events = del(events)
			end
			if type(param) == "string" and param:find("%[") and param:find("%]") then
				for k, v in pairs(codeToEventList[param]) do
					t[k] = v
				end
			end
		end
		code = del(code)
	end
	self[key] = t
	return t
end, __mode = 'k'})

local eventData = setmetatable({}, {__index = function(self, event)
	local t = newList()
	self[event] = t
	if event:find("^[A-Z_]+$") then
		DogTag.frame:RegisterEvent(event)
	end
	return t
end})
local buckets = setmetatable({}, {__index = function(self, event)
	local t = newList()
	self[event] = t
	return t
end})

local registry
local codeHash

local frameToText = {}
local textToFrame = {}

local toUpdate = {}

local function updateText(text, code, unit)
	local success, ret = pcall(codeToFunction[code], unit)
	if success then
		toUpdate[text] = nil
		text:SetText(ret)
	else
		geterrorhandler()(("%s.%d: Error with code %q on %q. %s"):format(MAJOR_VERSION, MINOR_VERSION, code, unit, ret))
	end
end

local runUpdate

local hasReputationEvent = false
local hasThreatEvent = false
local hasAuraEvent = false
local hasMouseoverEvent = false
local hasAltKeyEvent = false
local hasCtrlKeyEvent = false
local hasShiftKeyEvent = false
local hasUpdateEvent = false
local hasTalentEvent = false
local hasAddonVersionEvent = false
local hasSlowUpdateEvent = false
local hasAFKTimeEvent = false
local hasDeadTimeEvent = false
local hasOfflineTimeEvent = false
local shouldRecheckEventData = false
local function RecheckEventData()
	shouldRecheckEventData = false
	hasReputationEvent = not not rawget(eventData, "Reputation")
	hasThreatEvent = not not rawget(eventData, "Threat")
	hasMouseoverEvent = not not rawget(eventData, "Mouseover")
	hasUpdateEvent = not not rawget(eventData, "Update")
	hasSlowUpdateEvent = not not rawget(eventData, "SlowUpdate")
	hasAltKeyEvent = not not rawget(eventData, "AltKey")
	hasCtrlKeyEvent = not not rawget(eventData, "CtrlKey")
	hasShiftKeyEvent = not not rawget(eventData, "ShiftKey")
	hasAFKTimeEvent = not not rawget(eventData, "AFKTime")
	hasDeadTimeEvent = not not rawget(eventData, "DeadTime")
	hasOfflineTimeEvent = not not rawget(eventData, "OfflineTime")
	hasTalentEvent = not not rawget(eventData, "Talent")
	hasAddonVersionEvent = not not rawget(eventData, "AddonVersion")
	for k in pairs(eventData) do
		if not k:find("^[A-Z_]+$") then
			if k ~= "Reputation" and k ~= "Mouseover" and k ~= "Threat" and k ~= "Update" and k ~= "SlowUpdate" and k ~= "AltKey" and k ~= "ShiftKey" and k ~= "CtrlKey" and k ~= "AFKTime" and k ~= "DeadTime" and k ~= "OfflineTime" and k ~= "Talent" and k ~= "AddonVersion" then
				hasAuraEvent = true
				break
			end
		end
	end
end

function DogTag:AddFontString(text, frame, unit, code)
	if not IsLegitimateUnit[unit] then
		code = ""
	end
	local outline = ""
	if code:find("^%[[Oo][Uu][Tt][Ll][Ii][Nn][Ee]%]") then
		code = code:sub(10)
		outline = "OUTLINE"
	elseif code:find("^%[[Tt][Hh][Ii][Cc][Kk][Oo][Uu][Tt][Ll][Ii][Nn][Ee]%]") then
		code = code:sub(15)
		outline = "OUTLINE, THICKOUTLINE"
	end
	if codeHash[text] then
		if codeHash[text] == code and registry[text] == unit and textToFrame[text] == frame and select(3, text:GetFont()) == outline then
			toUpdate[text] = true
			return
		end
		self:RemoveFontString(text)
	end
	codeHash[text] = code
	registry[text] = unit
	if NormalUnits[unit] then
		local events = codeToEventList[code]

		for event in pairs(events) do
			local event, u = ("="):split(event, 2)
			if not u then
				u = unit
			end
			if eventData[event][text] and eventData[event][text] ~= u then
				if type(eventData[event][text]) == "string" then
					local old = eventData[event][text]
					eventData[event][text] = newList()
					eventData[event][text][old] = true
				end
				eventData[event][text][u] = true
			else
				eventData[event][text] = u
			end
		end
	end
	registry[text] = unit

	shouldRecheckEventData = true

	if not frameToText[frame] then
		frameToText[frame] = newList()
	end
	frameToText[frame][text] = unit
	textToFrame[text] = frame

	local font, fontsize = text:GetFont()
	text:SetFont(font, fontsize, outline)
	DogTag.__isMouseOver = textToFrame[text] == lastMouseFocus
	updateText(text, codeHash[text], unit)
end
precondition(DogTag, 'AddFontString', function(self, text, frame, unit, code)
	argCheck(text, 2, "table")
	argCheck(frame, 3, "table")
	argCheck(unit, 4, "string")
	argCheck(code, 5, "string")
end)

local alwaysEvents = {
	PARTY_MEMBERS_CHANGED = true,
	PLAYER_ENTERING_WORLD = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_FOCUS_CHANGED = true,
	PLAYER_PET_CHANGED = true,
	UPDATE_MOUSEOVER_UNIT = true,
	UNIT_PET = true,
	ADDON_LOADED = true,
	PLAYER_LOGIN = true,
	UPDATE_FACTION = true,
	UNIT_AURA = true,
	MODIFIER_STATE_CHANGED = true,
	PLAYER_FLAGS_CHANGED = true,
	GUILD_ROSTER_UPDATE = true,
	PLAYER_GUILD_UPDATE = true,
}

function DogTag:RemoveFontString(text)
	local code = codeHash[text]
	if not code then
		return
	end

	local unit = registry[text]
	registry[text] = nil
	codeHash[text] = nil
	if NormalUnits[unit] then
		local events = codeToEventList[code]

		for event in pairs(events) do
			local t = eventData[event]
			if type(t[text]) == "table" then
				del(t[text])
			end
			t[text] = nil
			if not next(t) then
				eventData[event] = del(t)
				if event:find("^[A-Z_]+$") then
					if not alwaysEvents[event] then
						self.frame:UnregisterEvent(event)
					end
					buckets[event] = del(buckets[event])
				end
			end
		end

		shouldRecheckEventData = true
	end

	local frame = textToFrame[text]
	textToFrame[text] = nil
	frameToText[frame][text] = nil
	if not next(frameToText[frame]) then
		frameToText[frame] = del(frameToText[frame])
	end
end
precondition(DogTag, 'RemoveFontString', function(self, text)
	argCheck(text, 2, "table")
end)

function DogTag:UpdateFontString(text)
	local unit = registry[text]

	if unit then
		DogTag.__isMouseOver = textToFrame[text] == lastMouseFocus
		updateText(text, codeHash[text], unit)
	end
end
precondition(DogTag, 'UpdateFontString', function(self, text)
	argCheck(text, 2, "table")
end)

local auraQueue = {}

function DogTag:UpdateAllForUnit(unit)
	if not IsLegitimateUnit[unit] then
		return
	end

	if rawget(currentAuras, unit) then
		currentAuras[unit] = del(currentAuras[unit])
		currentDebuffTypes[unit] = del(currentDebuffTypes[unit])
		auraQueue[unit] = true
	end

	for text, u in pairs(registry) do
		if u == unit then
			toUpdate[text] = true
		end
	end
	for event, data in pairs(eventData) do
		for text, u in pairs(data) do
			if u == unit or data[u] then
				toUpdate[text] = true
			end
		end
	end

	runUpdate()
end
precondition(DogTag, 'UpdateAllForUnit', function(self, unit)
	argCheck(unit, 2, "string")
end)

function DogTag:UpdateAllForFrame(frame)
	if not frame:IsShown() then
		return
	end

	local list = frameToText[frame]
	if not list then
		return
	end

	for text, unit in pairs(list) do
		toUpdate[text] = true
	end

	runUpdate()
end
precondition(DogTag, 'UpdateAllForFrame', function(self, frame)
	argCheck(frame, 2, "table")
end)

function DogTag:Evaluate(unit, code)
	if not IsLegitimateUnit[unit] then
		return ""
	end
	DogTag.__isMouseOver = false

	local success, ret = pcall(codeToFunction[code], unit)
	if success then
		return ret
	else
		geterrorhandler()(("%s.%d: Error with code %q on %q. %s"):format(MAJOR_VERSION, MINOR_VERSION, code, unit, ret))
	end
end
precondition(DogTag, 'Evaluate', function(self, unit, code)
	argCheck(unit, 2, "string")
	argCheck(code, 3, "string")
end)

do
	local function handler(literal)
		local inner = literal:sub(2, -2)
		local code = newList(splitCode(inner))
		local real = newList()
		for i = 1, #code, 2 do
			local bit, param, negate, unit = splitParam(code[i])

			if i == 1 then
				real[1] = "["
			else
				real[#real+1] = code[i-1]
			end

			real[#real+1] = joinParam(bit, param, negate, unit)
		end
		code = del(code)
		real[#real+1] = ']'
		local str = table_concat(real):gsub("~~", "")
		real = del(real)
		return str
	end
	function DogTag:FixCasing(code)
		local outline = ""
		if code:find("^%[[Oo][Uu][Tt][Ll][Ii][Nn][Ee]%]") then
			code = code:sub(10)
			outline = "[Outline]"
		elseif code:find("^%[[Tt][Hh][Ii][Cc][Kk][Oo][Uu][Tt][Ll][Ii][Nn][Ee]%]") then
			code = code:sub(15)
			outline = "[ThickOutline]"
		end
		return outline .. (code:gsub("(%b[])", handler))

	end
	precondition(DogTag, 'FixCasing', function(self, code)
		argCheck(code, 2, "string")
	end)
end

function DogTag:UNIT_AURA(unit)
	auraQueue[unit] = true
end

local offlineTimes = {}
local afkTimes = {}
local deadTimes = {}

function DogTag:PARTY_MEMBERS_CHANGED()
	for k, v in pairs(currentAuras) do
		currentAuras[k] = del(v)
		currentDebuffTypes[k] = del(currentDebuffTypes[k])
	end
	for text, unit in pairs(registry) do
		auraQueue[unit] = true
		toUpdate[text] = true
	end

	local unitType, max = "raid", GetNumRaidMembers()
	if max == 0 then
		unitType, max = "party", GetNumPartyMembers()
	end

	for i = 0, max do
		local unit = unitType .. i
		if i == 0 then
			unit = "player"
		end
		if not UnitExists(unit) then
			break
		end
		local name, server = UnitName(unit)
		if server and server ~= "" then
			name = name .. "-" .. server
		end
		if not UnitIsConnected(unit) then
			if not offlineTimes[name] then
				offlineTimes[name] = time()
			end
			afkTimes[name] = nil
		else
			offlineTimes[name] = nil
			if UnitIsAFK(unit) then
				if not afkTimes[name] then
					afkTimes[name] = time()
				end
			else
				afkTimes[name] = nil
			end
		end
		if UnitIsDeadOrGhost(unit) then
			if not deadTimes[name] then
				deadTimes[name] = time()
			end
		else
			deadTimes[name] = nil
		end
	end

	runUpdate()
end
DogTag.PLAYER_ENTERING_WORLD = DogTag.PARTY_MEMBERS_CHANGED
DogTag.UNIT_PET = DogTag.PARTY_MEMBERS_CHANGED

function DogTag:UPDATE_FACTION()
	for i = 1, GetNumFactions() do
		local name = GetFactionInfo(i)
		factionList[name] = true
	end
end

function DogTag:PLAYER_TARGET_CHANGED()
	self:UpdateAllForUnit('target')
end

function DogTag:PLAYER_FOCUS_CHANGED()
	self:UpdateAllForUnit('focus')
end

function DogTag:PLAYER_PET_CHANGED()
	self:UpdateAllForUnit('pet')
end

local inMouseover = false
function DogTag:UPDATE_MOUSEOVER_UNIT()
	inMouseover = true
	self:UpdateAllForUnit('mouseover')
end

local function clearCodes()
	for k in pairs(codeToFunction) do
		codeToFunction[k] = nil
	end
	for k, v in pairs(codeToEventList) do
		codeToEventList[k] = del(v)
	end
	for k in pairs(antiAlias) do
		antiAlias[k] = nil
	end
	for k, v in pairs(eventData) do
		eventData[k] = del(v)
	end
	for k, v in pairs(buckets) do
		buckets[k] = del(v)
	end
	for k, v in pairs(TagAliasFunctions) do
		TagAliases[k] = v()
	end
	for k, v in pairs(ModifierAliasFunctions) do
		ModifierAliases[k] = v()
	end

	local self = DogTag
	self.frame:UnregisterAllEvents()
	for k in pairs(alwaysEvents) do
		self.frame:RegisterEvent(k)
	end

	DogTag:PARTY_MEMBERS_CHANGED()
end

local AceEvent
function DogTag:ADDON_LOADED()
	-- for extra addons' help, such as MobHealth3 or MobInfo2
	AceLibrary = _G.AceLibrary
	local good = false
	if not MobHealth_PPP and _G.MobHealth_PPP then
		MobHealth_PPP = _G.MobHealth_PPP
		good = true
	end
	if not MobHealth3 and _G.MobHealth3 then
		MobHealth3 = _G.MobHealth3
		good = true
	end
	if not BabbleSpell and AceLibrary and AceLibrary:HasInstance("Babble-Spell-2.2") then
		BabbleSpell = AceLibrary("Babble-Spell-2.2")
		good = true
	end
	if not AceEvent and AceLibrary and AceLibrary:HasInstance("AceEvent-2.0") then
		AceEvent = AceLibrary("AceEvent-2.0")
		AceEvent:embed(self)
		self:RegisterEvent("Threat_ThreatUpdated")
		good = true
	end
	if not Threat and AceLibrary and AceLibrary:HasInstance("Threat-1.0") then
		Threat = AceLibrary("Threat-1.0")
		good = true
	end
	if not RangeCheck and AceLibrary and AceLibrary:HasInstance("RangeCheck-1.0") then
		RangeCheck = AceLibrary("RangeCheck-1.0")
		good = true
	end
	if not good then
		return
	end
	clearCodes()
	return true
end

function DogTag:PLAYER_LOGIN()
	if not self:ADDON_LOADED() then
		self:PARTY_MEMBERS_CHANGED()
	end
	self:UPDATE_FACTION()

	self:PLAYER_FLAGS_CHANGED("player")
end

function DogTag:SetColorConstantTable(t)
	colors = t
	-- need to update the colors reference in the functions
	for k in pairs(codeToFunction) do
		codeToFunction[k] = nil
	end
	clearCodes()
end
precondition(DogTag, 'SetColorConstantTable', function(self, t)
	argCheck(t, 2, "table")
end)

function DogTag:MODIFIER_STATE_CHANGED(key)
	local eventName
	if key == "ALT" then
		eventName = "AltKey"
		if not hasAltKeyEvent then
			return
		end
	elseif key == "CTRL" then
		eventName = "CtrlKey"
		if not hasCtrlKeyEvent then
			return
		end
	elseif key == "SHIFT" then
		eventName = "ShiftKey"
		if not hasShiftKeyEvent then
			return
		end
	else
		return
	end

	for text in pairs(eventData[eventName]) do
		if text:IsVisible() and text:GetNumPoints() > 0 then
			DogTag.__isMouseOver = textToFrame[text] == lastMouseFocus
			updateText(text, codeHash[text], registry[text])
		end
	end
end

function DogTag:OnMouseoverUpdate()
	local toUpdate = newList()
	local mouseFocus = GetMouseFocus()
	local list, list2 = frameToText[lastMouseFocus], frameToText[mouseFocus]
	lastMouseFocus = mouseFocus
	if hasMouseoverEvent then
		if list then
			if list2 then
				for text, unit in pairs(eventData.Mouseover) do
					if list[text] or list2[text] then
						toUpdate[text] = true
					end
				end
			else
				for text, unit in pairs(eventData.Mouseover) do
					if list[text] then
						toUpdate[text] = true
					end
				end
			end
		elseif list2 then
			for text, unit in pairs(eventData.Mouseover) do
				if list2[text] then
					toUpdate[text] = true
				end
			end
		end
	end

	for text, u in pairs(registry) do
		if u == "mouseover" or u.mouseover then
			toUpdate[text] = true
		end
	end
	for event, data in pairs(eventData) do
		for text, u in pairs(data) do
			if u == "mouseover" or u.mouseover then
				toUpdate[text] = true
			end
		end
	end

	for text in pairs(toUpdate) do
		if text:IsVisible() and text:GetNumPoints() > 0 then
			DogTag.__isMouseOver = textToFrame[text] == lastMouseFocus
			updateText(text, codeHash[text], registry[text])
		end
	end
	toUpdate = del(toUpdate)
end

function DogTag:OnReputationUpdate()
	if not hasReputationEvent then
		return
	end
	for text, unit in pairs(eventData.Reputation) do
		toUpdate[text] = true
	end
end

function DogTag:Threat_ThreatUpdated(unitName, unitID, targetHash, threatValue)
	if not Threat or not hasThreatEvent then
		return
	end
	for text, unit in pairs(eventData.Threat) do
		if not toUpdate[text] then
			local name = UnitName(unit)
			if (unit == unitID or unit[unitID] or (name and Threat:UnitIsUnit(name, targetHash))) then
				toUpdate[text] = true
			end
		end
	end
end

function GetAFKTime(unit)
	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local t = afkTimes[name]
	if not t then
		return nil
	end
	local time_diff = time() - t
	if time_diff < 3600 then
		return ("%d:%02d"):format(time_diff/60, time_diff%60)
	else
		return ("%d:%02d:%02d"):format(time_diff/3600, time_diff%3600/60, time_diff%60)
	end
end

function GetDeadTime(unit)
	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local t = deadTimes[name]
	if not t then
		return nil
	end
	local time_diff = time() - t
	if time_diff < 3600 then
		return ("%d:%02d"):format(time_diff/60, time_diff%60)
	else
		return ("%d:%02d:%02d"):format(time_diff/3600, time_diff%3600/60, time_diff%60)
	end
end

function GetOfflineTime(unit)
	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local t = offlineTimes[name]
	if not t then
		return nil
	end
	local time_diff = time() - t
	if time_diff < 3600 then
		return ("%d:%02d"):format(time_diff/60, time_diff%60)
	else
		return ("%d:%02d:%02d"):format(time_diff/3600, time_diff%3600/60, time_diff%60)
	end
end

function DogTag:PLAYER_FLAGS_CHANGED(unit)
	buckets.PLAYER_FLAGS_CHANGED[unit or false] = true

	local name, server = UnitName(unit)
	if not name then
		return
	end
	if server and server ~= "" then
		name = name .. '-' .. server
	end
	local isAFK = UnitIsAFK(unit)

	if isAFK then
		if afkTimes[name] then
			return
		end
		afkTimes[name] = time()
	else
		if not afkTimes[name] then
			return
		end
		afkTimes[name] = nil
	end

	for text, u in pairs(eventData.AFKTime) do
		if not toUpdate[text] then
			local n, server = UnitName(unit)
			if n then
				if server and server ~= "" then
					n = n .. '-' .. server
				end
				if n == name then
					toUpdate[text] = true
				end
			end
		end
	end
end

local nextGuildRosterUpdate = 0
function DogTag:GUILD_ROSTER_UPDATE()
	buckets.GUILD_ROSTER_UPDATE[false] = true

	refreshGuildNotes(true)

	nextGuildRosterUpdate = GetTime() + 20
end

function DogTag:PLAYER_GUILD_UPDATE()
	refreshGuildNotes(true)
end

function talentReceptor(sender, data)
	local nums = newList()
	for i,v in ipairs(data) do
		local num = 0
		for j,u in ipairs(v) do
			num = num + u
		end
		nums[i] = num
	end
	talentSpecs[sender] = ("%d/%d/%d"):format(nums[1], nums[2], nums[3])
	local class = data.class
	class = class:sub(1, 1) .. class:sub(2):lower()
	if nums[1] == 0 and nums[2] == 0 and nums[3] == 0 then
		talentSpecNames[sender] = _G.NONE or "None"
	else
		local first, second, third
		if nums[1] >= nums[2] then
			if nums[1] >= nums[3] then
				first = 1
				if nums[2] >= nums[3] then
					second = 2
					third = 3
				else
					second = 3
					third = 2
				end
			else
				first = 3
				second = 1
				third = 2
			end
		else
			if nums[2] >= nums[3] then
				first = 2
				if nums[1] >= nums[3] then
					second = 1
					third = 3
				else
					second = 3
					third = 1
				end
			else
				first = 3
				second = 2
				third = 1
			end
		end
		local first_num = nums[first]
		local second_num = nums[second]
		if first_num*3/4 <= second_num then
			if first_num*3/4 <= nums[third] then
				-- all three balanced out
				talentSpecNames[sender] = L["Hybrid"]
			else
				talentSpecNames[sender] = L[class .. "_Tree_" .. first] .. "/" .. L[class .. "_Tree_" .. second]
			end
		else
			talentSpecNames[sender] = L[class .. "_Tree_" .. first]
		end
	end
	nums = del(nums)
	-- trigger "Talent" event
	if not hasTalentEvent then
		return
	end
	for text, unit in pairs(eventData.Talent) do
		toUpdate[text] = true
	end
end

function addonVersionReceptor(sender, addon, version)
	addonVersions[addon][sender] = version or _G.NONE or "None"
	-- trigger "Talent" event
	if not hasAddonVersionEvent then
		return
	end
	for text, unit in pairs(eventData.AddonVersion) do
		toUpdate[text] = true
	end
end

local namesChecked = {}
local num = 0
local nextTime = GetTime()
function runUpdate()
	num = num + 1
	local currentTime = GetTime()
	if currentTime > nextGuildRosterUpdate then
		if IsInGuild() then
			GuildRoster()
		end
		nextGuildRosterUpdate = currentTime + 20
	end
	if currentTime > nextTime then
		nextTime = nextTime + 1
		if hasAFKTimeEvent then
			for text in pairs(eventData.AFKTime) do
				local unit = registry[text]
				local name, server = UnitName(unit)
				if name then
					if server and server ~= "" then
						name = name .. "-" .. server
					end
					if UnitIsVisible(unit) then
						if afkTimes[name] then
							toUpdate[text] = true
						end
					else
						if UnitIsAFK(unit) then
							if not afkTimes[name] then
								afkTimes[name] = time()
							end
							toUpdate[text] = true
						else
							if afkTimes[name] then
								afkTimes[name] = nil
								toUpdate[text] = true
							end
						end
					end
				end
			end
		end
		if hasOfflineTimeEvent then
			for text in pairs(eventData.OfflineTime) do
				if not toUpdate[text] then
					local unit = registry[text]
					local name, server = UnitName(unit)
					if name then
						if server and server ~= "" then
							name = name .. "-" .. server
						end
						if offlineTimes[name] then
							toUpdate[text] = true
						end
					end
				end
			end
		end
		if hasDeadTimeEvent then
			for text in pairs(eventData.DeadTime) do
				local unit = registry[text]
				if UnitInRaid(unit) or UnitInParty(unit) then
					local name, server = UnitName(unit)
					if name then
						if server and server ~= "" then
							name = name .. "-" .. server
						end
						if not namesChecked[name] then
							if UnitIsDeadOrGhost(unit) then
								if not deadTimes[name] then
									deadTimes[name] = time()
								end
								namesChecked[name] = true
								toUpdate[text] = true
							else
								if deadTimes[name] then
									deadTimes[name] = nil
									namesChecked[name] = true
									toUpdate[text] = true
								end
							end
						else
							toUpdate[text] = true
						end
					end
				elseif UnitIsDeadOrGhost(unit) then
					toUpdate[text] = true
				end
			end
			for k in pairs(namesChecked) do
				namesChecked[k] = nil
			end
		end
	end
	if num%5 == 0 and hasAuraEvent then
		if num%20 == 0 then
			for unit, v in pairs(currentAuras) do
				if not NormalUnits[unit] then
					currentAuras[unit] = del(v)
					currentDebuffTypes[unit] = del(currentDebuffTypes[unit])
				end
			end
		end
		for unit in pairs(auraQueue) do
			auraQueue[unit] = nil
			local t = newList()
			local u = newList()
			for i = 1, 40 do
				local name = UnitBuff(unit, i)
				if not name then
					break
				end
				t[name] = true
			end
			local isFriend = UnitIsFriend("player", unit)
			for i = 1, 40 do
				local name,_,_,_,dispelType = UnitDebuff(unit, i)
				if not name then
					break
				end
				t[name] = true
				if isFriend and dispelType then
					u[dispelType] = true
				end
			end
			local old = rawget(currentAuras, unit) or newList()
			local oldType = rawget(currentDebuffTypes, unit) or newList()
			local changed = newList()
			local changedDebuffTypes = newList()
			for k in pairs(t) do
				if not old[k] then
					changed[k] = true
				else
					old[k] = nil
				end
			end
			for k in pairs(old) do
				if not t[k] then
					changed[k] = true
				end
			end
			for k in pairs(u) do
				if not oldType[k] then
					changedDebuffTypes[k] = true
				else
					oldType[k] = nil
				end
			end
			for k in pairs(oldType) do
				if not u[k] then
					changedDebuffTypes[k] = true
				end
			end
			currentAuras[unit] = t
			currentDebuffTypes[unit] = u
			old = del(old)
			oldType = del(oldType)
			for name in pairs(changed) do
				if rawget(eventData, name) then
					for text in pairs(eventData[name]) do
						toUpdate[text] = true
					end
				end
			end
			for dispelType in pairs(changedDebuffTypes) do
				if rawget(eventData, dispelType) then
					for text in pairs(eventData[dispelType]) do
						toUpdate[text] = true
					end
				end
			end
			changed = del(changed)
			changedDebuffTypes = del(changedDebuffTypes)
		end
	end
	if num%3 == 0 and hasUpdateEvent then
		for text in pairs(eventData.Update) do
			toUpdate[text] = true
		end
	end
	if num%200 == 0 and hasSlowUpdateEvent then
		for text in pairs(eventData.SlowUpdate) do
			toUpdate[text] = true
		end
	end
	local mouseoverIsTarget = UnitIsUnit("target", "mouseover")
	for event, units in pairs(buckets) do
		if units[false] then
			for text in pairs(eventData[event]) do
				toUpdate[text] = true
			end
		else
			if mouseoverIsTarget and not units.mouseover then
				units.mouseover = units.target
			end
			for text, unit in pairs(eventData[event]) do
				if not toUpdate[text] then
					if units[unit] then
						toUpdate[text] = true
					elseif type(unit) == "table" then
						for u in pairs(unit) do
							if units[u] then
								toUpdate[text] = true
							end
						end
					end
				end
			end
		end
		buckets[event] = del(units)
	end
	local noMouseover = not UnitExists("mouseover")
	if inMouseover and noMouseover then
		inMouseover = false
		for event, data in pairs(eventData) do
			for text, u in pairs(data) do
				if u == "mouseover" or u.mouseover then
					toUpdate[text] = true
				end
			end
		end
	end
	if noMouseover then
		for text in pairs(toUpdate) do
			if registry[text] == "mouseover" then
				toUpdate[text] = nil
			end
		end
	end
	for text in pairs(toUpdate) do
		toUpdate[text] = nil
		local unit = registry[text]
		if unit and text:IsVisible() and text:GetNumPoints() > 0 then
			DogTag.__isMouseOver = textToFrame[text] == lastMouseFocus
			updateText(text, codeHash[text], unit)
		end
	end
end

DogTag.frame = oldLib and oldLib.frame or CreateFrame("Frame", MAJOR_VERSION .. "_Frame")
local frame = DogTag.frame
frame:UnregisterAllEvents()
for k in pairs(alwaysEvents) do
	frame:RegisterEvent(k)
end
frame:SetScript("OnEvent", function(this, event, arg1, ...)
	local func = DogTag[event]
	if func then
		func(DogTag, arg1, ...)
		return
	end
	buckets[event][arg1 or false] = true
end)

local timePassed = 0
local firstTime = true
frame:SetScript("OnUpdate", function(this, elapsed)
	timePassed = timePassed + elapsed
	if timePassed > 0.05 then
		if firstTime then
			firstTime = false
			DogTag:PARTY_MEMBERS_CHANGED()
		end
		if shouldRecheckEventData then
			RecheckEventData()
		end
		timePassed = 0
		runUpdate()
	end
end)

if not oldLib or not oldLib.hookedRep then
	hooksecurefunc("ReputationWatchBar_Update", function()
		DogTag:OnReputationUpdate()
	end)
end
DogTag.hookedRep = true

registry = {}
DogTag.registry = registry
codeHash = {}
DogTag.codeHash = codeHash

if oldLib then
	for text, unit in pairs(oldLib.registry) do
		DogTag:AddFontString(text, unit, oldLib.codeHash[text])
	end
end
