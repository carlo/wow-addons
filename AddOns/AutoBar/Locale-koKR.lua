
-- AutoBar
-- http://code.google.com/p/autobar/
-- Courtesy of Sayclub
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("koKR", function() return {
        ["AUTOBAR"] = "오토바",
        ["CONFIG_WINDOW"] = "설정 창 열기",
        ["SLASHCMD_LONG"] = "/autobar",
        ["SLASHCMD_SHORT"] = "/atb",
        ["BUTTON"] = "버튼",
        ["EDITSLOT"] = "버튼 편집",
        ["VIEWSLOT"] = "슬롯 보기",
		["LOAD_ERROR"] = "|cff00ff00AutoBarConfig를 불려올수 없습니다. 그것을 사용 가능하게 활성화 시키세요.|r 오류: ",
		["Toggle the config panel"] = "설정 패널을 열거나 닫습니다.",

		-- AutoBar_Config.lua
		["EMPTY"] = "빈창";
		["STYLE"] = "스타일",
		["STYLE_TIP"] = "단축 행동바의 스타일을 변경합니다.",
		["DEFAULT"] = "Default",
		["ZOOMED"] = "Zoomed",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "우 클릭시 자신에게 시전 안함";
		["AUTOBAR_CONFIG_REMOVECAT"] = "현재 카테고리 삭제";
		["AUTOBAR_CONFIG_ROW"] = "가로";
		["AUTOBAR_CONFIG_COLUMN"] = "세로";
		["AUTOBAR_CONFIG_GAPPING"] = "아이콘 간격";
		["AUTOBAR_CONFIG_ALPHA"] = "아이콘 투명도";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "버튼 너비";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "버튼 높이";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "위치 변경(좌측 및 우측)";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "위치 변경(상단 및 하단)";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "버튼 높이 및 너비\n동시 변경 해제";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "단축키 숨김";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "갯수 숨김";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "빈 버튼 표시";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "카테고리 아이콘 표시";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "툴팁 숨김";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "팝업 버튼 방향";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "Shift 키 클릭시 팝업";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "이동 단추 숨김";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "높은 프레임 계층";
		["AUTOBAR_CONFIG_CTRLSHOWSDRAGHANDLE"] = "Ctrl 키로 이동 버튼 표시";
		["AUTOBAR_CONFIG_LOCKACTIONBARS"] = "바를 잠글때\n액션바 고정";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "버튼 평범하게 표시";
		["AUTOBAR_CONFIG_NOPOPUP"] = "팝업 없음";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "사용 순서 재배열";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "우 클릭시 대상의 소환수";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "없음";
		["AUTOBAR_CONFIG_BT3BAR"] = "BarTender3 바";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "메인 메뉴";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "대화창";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "대화창 메뉴";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "액션 바";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "메뉴 버튼";
		["AUTOBAR_CONFIG_ALIGN"] = "일렬 버튼";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(찾을수 없음 : 아이템 ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " 계층 (편집 클릭)";
		["AUTOBAR_CONFIG_CHARACTER"] = "캐릭터";
		["AUTOBAR_CONFIG_SHARED"] = "공유";
		["AUTOBAR_CONFIG_CLASS"] = "직업";
		["AUTOBAR_CONFIG_BASIC"] = "기본";
		["AUTOBAR_CONFIG_USECHARACTER"] = "캐릭터 계층 사용";
		["AUTOBAR_CONFIG_USESHARED"] = "공유 계층 사용";
		["AUTOBAR_CONFIG_USECLASS"] = "직업 계층 사용";
		["AUTOBAR_CONFIG_USEBASIC"] = "기본 계층 사용";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "구성 툴팁 숨김";
		["AUTOBAR_CONFIG_OSKIN"] = "oSkin 사용";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "동작 기록";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "캐릭터 배치";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "공유 배치";
		["AUTOBAR_CONFIG_SHARED1"] = "공유 1";
		["AUTOBAR_CONFIG_SHARED2"] = "공유 2";
		["AUTOBAR_CONFIG_SHARED3"] = "공유 3";
		["AUTOBAR_CONFIG_SHARED4"] = "공유 4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "캐릭터 계층 편집";
		["AUTOBAR_CONFIG_EDITSHARED"] = "공유 계층 편집";
		["AUTOBAR_CONFIG_EDITCLASS"] = "직업 계층 편집";
		["AUTOBAR_CONFIG_EDITBASIC"] = "기본 계층 편집";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "폭죽",
		["Tradeskill.Tool.Fishing.Lure"] = "낚시 미끼",
		["Tradeskill.Tool.Fishing.Gear"] = "낚시 기어",
		["Tradeskill.Tool.Fishing.Tool"] = "낚싯대",

		["Consumable.Food.Bonus"] = "음식: 모든 보너스 음식들";
		["Consumable.Food.Buff.Strength"] = "음식: 힘 향상";
		["Consumable.Food.Buff.Agility"] = "음식: 민첩 향상";
		["Consumable.Food.Buff.Attack Power"] = "음식: 전투력 보너스";
		["Consumable.Food.Buff.Healing"] = "음식: 치유 보너스";
		["Consumable.Food.Buff.Spell Damage"] = "음식: 마법 피해 보너스";
		["Consumable.Food.Buff.Stamina"] = "음식: 체력 향상";
		["Consumable.Food.Buff.Intellect"] = "음식: 지능 향상";
		["Consumable.Food.Buff.Spirit"] = "음식: 정신력 향상";
		["Consumable.Food.Buff.Mana Regen"] = "음식: 마나 회복 향상";
		["Consumable.Food.Buff.HP Regen"] = "음식: 체력 회복 향상";
		["Consumable.Food.Buff.Other"] = "음식: 기타";

		["Consumable.Buff.Health"] = "버프: 생명력";
		["Consumable.Buff.Armor"] = "버프: 방어";
		["Consumable.Buff.Regen Health"] = "버프: 체력 회복";
		["Consumable.Buff.Agility"] = "버프: 민첩성";
		["Consumable.Buff.Intellect"] = "버프: 지능";
		["Consumable.Buff.Protection"] = "버프: 보호";
		["Consumable.Buff.Spirit"] = "버프: 정신력";
		["Consumable.Buff.Stamina"] = "버프: 체력";
		["Consumable.Buff.Strength"] = "버프: 힘";
		["Consumable.Buff.Attack Power"] = "버프: 전투력";
		["Consumable.Buff.Attack Speed"] = "버프: 공격 속도";
		["Consumable.Buff.Dodge"] = "버프: 회피";
		["Consumable.Buff.Resistance"] = "버프: 저항";

		["Consumable.Buff Group.General.Self"] = "일반 버프";
		["Consumable.Buff Group.General.Target"] = "일반 대상 버프";
		["Consumable.Buff Group.Caster.Self"] = "시전자 버프";
		["Consumable.Buff Group.Caster.Target"] = "시전자 대상 버프";
		["Consumable.Buff Group.Melee.Self"] = "근접 버프";
		["Consumable.Buff Group.Melee.Target"] = "근접 대상 버프";
		["Consumable.Buff.Other.Self"] = "기타 버프";
		["Consumable.Buff.Other.Target"] = "기타 대상 버프";
		["Consumable.Buff.Chest"] = "버프: 가슴";
		["Consumable.Buff.Shield"] = "버프: 방패";
		["Consumable.Weapon Buff"] = "버프: 무기";

		["Consumable.Quest.Usable"] = "퀘스트 아이템";

		["Consumable.Potion.Recovery.Healing.Basic"] = "치유 물약";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "치유 물약: 칼날 산맥";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "치유 물약: 갈퀴송곳니 저수지";
		["Consumable.Potion.Recovery.Healing.PvP"] = "전장 치유 물약";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "치유 물약: 폭풍우 요새";
		["Consumable.Potion.Recovery.Mana.Basic"] = "마나 물약";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "마나 물약: 칼날 산맥";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "마나 물약: 갈퀴송곳니 저수지";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "전장 마나 물약";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "마나 물약: 폭풍우 요새";

		["Consumable.Weapon Buff.Poison.Crippling"] = "신경 마비 독";
		["Consumable.Weapon Buff.Poison.Deadly"] = "맹독";
		["Consumable.Weapon Buff.Poison.Instant"] = "순간 효과 독";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "정신 마비 독";
		["Consumable.Weapon Buff.Poison.Wound"] = "상처 감염 독";
		["Consumable.Weapon Buff.Oil.Mana"] = "마나 오일: 마나 회복";
		["Consumable.Weapon Buff.Oil.Wizard"] = "마술사 오일: 피해 및 치유 향상";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "숫돌";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "무게추";

		["Consumable.Bandage.Basic"] = "붕대";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "알터랙 계곡 붕대";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "전쟁노래 협곡 붕대";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "아라시 분지 붕대";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "음식: 일반";
		["Consumable.Food.Percent.Basic"] = "음식: % 체력 회복";
		["Consumable.Food.Percent.Bonus"] = "음식: % 체력 회복 (버프)";
		["Consumable.Food.Combo Percent"] = "음식: % 체력 & 마나 회복";
		["Consumable.Food.Combo Health"] = "음식 및 음료 동시";
		["Consumable.Food.Edible.Bread.Conjured"] = "음식: 마법사 창조";
		["Consumable.Food.Conjure"] = "음식 창조";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "음식: 아라시 분지";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "음식: 전쟁노래 협곡";

		["Consumable.Food.Pet.Bread"] = "음식: 소환수 빵";
		["Consumable.Food.Pet.Cheese"] = "음식: 소환수 치즈";
		["Consumable.Food.Pet.Fish"] = "음식: 소환수 물고기";
		["Consumable.Food.Pet.Fruit"] = "음식: 소환수 과일";
		["Consumable.Food.Pet.Fungus"] = "음식: 소환수 버섯";
		["Consumable.Food.Pet.Meat"] = "음식: 소환수 고기";

		["AUTOBAR_CLASS_CUSTOM"] = "일반";
		["Misc.Minipet.Normal"] = "소환수";
		["Misc.Minipet.Snowball"] = "축제 소환수";
		["AUTOBAR_CLASS_CLEAR"] = "이 슬롯 비움";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "운고르 : 회복의 수정";

		["Consumable.Anti-Venom"] = "해독제";

		["Consumable.Warlock.Healthstone"] = "생명석";
		["Consumable.Warlock.Create Healthstone"] = "생명석 창조";
		["Consumable.Mage.Mana Stone"] = "마나석";
		["Consumable.Mage.Conjure Mana Stone"] = "마나석 창조";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "숙면의 물약";
		["Consumable.Potion.Recovery.Rejuvenation"] = "회복 물약";
		["Consumable.Jeweler.Statue"] = "돌 조각상";

		["Misc.Battle Standard.Battleground"] = "전투 깃발";
		["Misc.Battle Standard.Alterac Valley"] = "알터랙 계곡 전투 깃발";
		["Consumable.Recovery.Rune"] = "어둠 또는 악마의 룬";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "비전 보호 물약";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "화염 보호 물약";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "냉기 보호 물약";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "자연 보호 물약";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "암흑 보호 물약";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "주문 보호 물약 ";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "신성 보호 물약";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "제한된 무적 물약";
		["Consumable.Buff.Free Action"] = "자유 행동의 물약";

		["AUTOBAR_CLASS_PORTALS"] = "차원문 & 순간이동";
		["Misc.Hearth"] = "귀환석";
		["Misc.Booze"] = "술";
		["Consumable.Water.Basic"] = "음료";
		["Consumable.Water.Percentage"] = "음료: % 마나 회복";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "음료: 마법사 창조";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "음료 창조";
		["Consumable.Water.Buff.Spirit"] = "음료: 정신력 향상";
		["Consumable.Buff.Rage.Self"] = "분노의 물약";
		["Consumable.Buff.Energy.Self"] = "기력의 물약";
		["Consumable.Buff.Speed"] = "신속의 물약";
		["AUTOBAR_CLASS_SOULSHARDS"] = "영혼석";
		["Reagent.Ammo.Arrow"] = "화살";
		["Reagent.Ammo.Bullet"] = "탄환";
		["Reagent.Ammo.Thrown"] = "투척 무기류";
		["Misc.Engineering.Explosives"] = "폭탄";
		["Misc.Mount.Normal"] = "탈것";
		["Misc.Mount.Summoned"] = "탈것: 소환";
		["Misc.Mount.Ahn'Qiraj"] = "탈것: 안퀴라즈";
		["Misc.Mount.Flying"] = "탈것: 비행";

	}
end);


if (GetLocale()=="koKR") then

AUTOBAR_CHAT_MESSAGE1 = "이 캐릭터에 대한 전 버전의 설정값이 있습니다. 삭제하십시오. 설정 업데이트를 시도하지 않고 있습니다.";
AUTOBAR_CHAT_MESSAGE2 = "아이템 이름 대신 아이템의 ID를 이용하기 위해, 복수 아이템 버튼 #%d를 #%d로 변경합니다.";
AUTOBAR_CHAT_MESSAGE3 = "아이템 이름 대신 아이템의 ID를 이용하기 위해, 단일 아이템 버튼 #%d로 변경합니다.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "슬롯을 편집하려면 슬롯 탭의 아래에 슬롯 편집 섹션에서 선택합니다.";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "결합된 계층 보기 (편집 불가)";
AUTOBAR_CONFIG_RESET = "초기화";
AUTOBAR_CONFIG_REVERT = "되돌리기";
AUTOBAR_CONFIG_DONE = "완료";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Shift 클릭 : 카테고리 조사)";
AUTOBAR_CONFIG_DRAGHANDLE = "위치 이동 : 마우스 좌 클릭후 끌기\n잠금/해제 : 마우스 좌 클릭\n옵션 : 마우스 우 클릭";
AUTOBAR_CONFIG_EMPTYSLOT = "빈 슬롯";
AUTOBAR_CONFIG_CLEARSLOT = "슬롯 비움";
AUTOBAR_CONFIG_SETSHARED = "공유 프로파일:";
AUTOBAR_CONFIG_SETSHAREDTIP = "사용할 공유 프로파일을 선택하세요.\n공유된 프로파일에 대한 변화는 그것을 사용하고 있는 모든 캐릭터에게 영향을 줍니다.";

AUTOBAR_CONFIG_TAB_SLOTS = "슬롯";
AUTOBAR_CONFIG_TAB_BAR = "바";
AUTOBAR_CONFIG_TAB_BUTTONS = "버튼들";
AUTOBAR_CONFIG_TAB_POPUP = "팝업";
AUTOBAR_CONFIG_TAB_PROFILE = "프로파일";
AUTOBAR_CONFIG_TAB_KEYS = "단축키";

AUTOBAR_TOOLTIP1 = " (갯수: ";
AUTOBAR_TOOLTIP2 = " [사용자 아이템]";
AUTOBAR_TOOLTIP4 = " [전장에서만 가능]";
AUTOBAR_TOOLTIP5 = " [비전투시만 가능]";
AUTOBAR_TOOLTIP6 = " [제한된 사용]";
AUTOBAR_TOOLTIP7 = " [재사용]";
AUTOBAR_TOOLTIP8 = "\n(좌 클릭시 주무기 적용\n우 클릭시 보조무기 적용)";

AUTOBAR_CONFIG_DOCKTO = "위치 변경:";
AUTOBAR_CONFIG_USECHARACTERTIP = "캐릭터 계층 아이템은 이 캐릭터에만 특별히 적용합니다.";
AUTOBAR_CONFIG_USESHAREDTIP = "공유되는 계층 아이템이 똑같은 공유 계층을 사용하는 다른 캐릭터에 의하여 함께 공유됩니다.\n특정한 계층은 프로파일 탭 위에 선택될 수 있습니다.";
AUTOBAR_CONFIG_USECLASSTIP = "직업 계층 아이템이 직업 계층을 사용하는 똑같은 직업의 모든 캐릭터에 의하여 함께 공유됩니다.";
AUTOBAR_CONFIG_USEBASICTIP = "기본 계층 아이템이 모든 캐릭터에 의하여 기본 계층을 사용하면서 함께 공유됩니다.";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "시각적인 배치에 대한 변경은 이 캐릭터에 영향을 줍니다.";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "시각적인 배치에 대한 변경은 같이 공유되는 프로파일을 사용하고 있는 모든 캐릭터들에 영향을 줍니다.";
AUTOBAR_CONFIG_TIPOVERRIDE = "이 계층 위의 슬롯 아이템은 더 낮은 계층 위의 그 슬롯의 아이템 위로 올라갑니다.\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "이 계층 위의 슬롯 아이템은 더 높은 계층 위의 아이템에 의하여 아래로 내려갑니다.\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "변경은 현재 캐릭터만 영향을 줍니다.";
AUTOBAR_CONFIG_TIPAFFECTSALL = "변경은 모든 캐릭터에 영향을 줍니다.";
AUTOBAR_CONFIG_SETUPSINGLE = "싱글 구성";
AUTOBAR_CONFIG_SETUPSHARED = "공유 구성";
AUTOBAR_CONFIG_SETUPSTANDARD = "표준 구성";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "빈 슬레이트";
AUTOBAR_CONFIG_SETUPSINGLETIP = "표준 오토바와 비슷한 하나의 캐릭터 설정들을 위해 클릭하세요.";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "공유되는 설정들을 위해 클릭하세요.\n공유되는 계층들 뿐만 아니라 특정 캐릭터를 가능하게 합니다.";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "모든 계층들의 편집과 사용을 가능하게 합니다.";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "모든 캐릭터를 없애고 슬롯들을 공유합니다.";
AUTOBAR_CONFIG_RESETSINGLETIP = "싱글 캐릭터를 기본값으로 초기화 하려면 클릭하세요.";
AUTOBAR_CONFIG_RESETSHAREDTIP = "공유되는 캐릭터를 기본값으로 초기화 하려면 클릭하세요.\n직업 특정의 슬롯이 캐릭터 계층으로 복사해 집니다.\n기본 슬롯이 공유되는 계층으로 복사해 집니다.";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "표준을 기본값으로 초기화 하려면 클릭하세요.\n직업 특정의 슬롯들은 직업 계층 안에 있습니다.\n기본 슬롯들은 기초적인 계층 안에 있습니다.\n공유 그리고 캐릭터 계층들을 비우게 됩니다.";

--  AutoBar_Config.lua
AUTOBAR_TOOLTIP9 = "복수 카테고리 버튼\n";
AUTOBAR_TOOLTIP10 = " (사용자 아이템 ID)";
AUTOBAR_TOOLTIP11 = "\n(인정되지 않는 아이템 ID)";
AUTOBAR_TOOLTIP12 = " (사용자 아이템 이름)";
AUTOBAR_TOOLTIP13 = "단일 카테고리 버튼\n\n";
AUTOBAR_TOOLTIP14 = "\n직접 사용 불가";
AUTOBAR_TOOLTIP15 = "\n무기 대상\n(좌시 클릭 주무기\n우 클릭시 보조무기)";
AUTOBAR_TOOLTIP16 = "\n대상";
AUTOBAR_TOOLTIP17 = "\n비전투시만";
AUTOBAR_TOOLTIP18 = "\n전투시만";
AUTOBAR_TOOLTIP19 = "\n위치: ";
AUTOBAR_TOOLTIP20 = "\n제한된 사용: "
AUTOBAR_TOOLTIP21 = "체력 회복 요구";
AUTOBAR_TOOLTIP22 = "마나 회복 요구";
AUTOBAR_TOOLTIP23 = "단일 아이템 버튼\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "알터랙 계곡";
--AUTOBAR_WARSONGGULCH = "전쟁노래 협곡";
--AUTOBAR_ARATHIBASIN = "아라시 분지";
--AUTOBAR_AHN_QIRAJ = "안퀴라즈";

end