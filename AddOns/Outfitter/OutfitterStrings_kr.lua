if GetLocale() == "koKR" then	
	Outfitter_cTitle = "Outfitter";
	Outfitter_cTitleVersion = Outfitter_cTitle.." "..Outfitter_cVersion;

	Outfitter_cNameLabel = "이름:";
	Outfitter_cCreateUsingTitle = "최적화:";
	Outfitter_cUseCurrentOutfit = "현재 장비 세트 사용";
	Outfitter_cUseEmptyOutfit = "빈 장비 세트 생성";

	Outfitter_cOutfitterTabTitle = "Outfitter";
	Outfitter_cOptionsTabTitle = "옵션";
	Outfitter_cAboutTabTitle = "정보";

	Outfitter_cNewOutfit = "신규 장비 세트";
	Outfitter_cRenameOutfit = "장비 세트 이름 변경";

	Outfitter_cCompleteOutfits = "완비 세트";
	Outfitter_cPartialOutfits = "부분 세트";
	Outfitter_cAccessoryOutfits = "액세서리";
	Outfitter_cSpecialOutfits = "특수 조건";
	Outfitter_cOddsNEndsOutfits = "나머지 장비들";

	Outfitter_cGlobalCategory = "특별 세트";
	Outfitter_cNormalOutfit = "평상시";
	Outfitter_cNakedOutfit = "벗기";

	Outfitter_cFishingOutfit = "낚시";
	Outfitter_cHerbalismOutfit = "약초 채집";
	Outfitter_cMiningOutfit = "채광";
	Outfitter_cSkinningOutfit = "무두질";
	Outfitter_cFireResistOutfit = "화염 저항";
	Outfitter_cNatureResistOutfit = "자연 저항";
	Outfitter_cShadowResistOutfit = "암흑 저항";
	Outfitter_cArcaneResistOutfit = "비전 저항";
	Outfitter_cFrostResistOutfit = "냉기 저항";

	Outfitter_cArgentDawnOutfit = "은빛 여명회";
	Outfitter_cRidingOutfit = "말타기";
	Outfitter_cDiningOutfit = "음식 먹기";
	Outfitter_cBattlegroundOutfit = "전장";
	Outfitter_cABOutfit = "전장: 아라시 분지";
	Outfitter_cAVOutfit = "전장: 알터랙 계곡";
	Outfitter_cWSGOutfit = "전장: 전쟁노래 협곡";
	Outfitter_cArenaOutfit = "전장: 투기장";
	Outfitter_cEotSOutfit = "전장: 폭풍의 눈";
	Outfitter_cCityOutfit = "마을 주변";
	Outfitter_cSwimmingOutfit = "수영";

	Outfitter_cMountSpeedFormat = "이동 속도 (%d+)%%만큼 증가"; -- For detecting when mounted
	Outfitter_cFlyingMountSpeedFormat = "비행 속도 (%d+)%%만큼 증가"; -- For detecting when mounted

	Outfitter_cBagsFullError = "Outfitter: 가방이 가득 차서 %s|1을;를; 벗을 수 없습니다.";
	Outfitter_cDepositBagsFullError = "Outfitter: 가방이 가득 차서 %s|1을;를; 벗을 수 없습니다.";
	Outfitter_cWithdrawBagsFullError = "Outfitter: 가방이 가득 차서 %s|1을;를; 벗을 수 없습니다.";
	Outfitter_cItemNotFoundError = "Outfitter: %s 아이템을 찾을 수 없습니다.";
	Outfitter_cItemAlreadyUsedError = "Outfitter: %s|1은;는; 이미 다른 슬롯에서 사용중이므로 %s 슬롯에 착용할 수 없습니다.";
	Outfitter_cAddingItem = "Outfitter: %s|1을;를; %s 세트에 추가합니다.";
	Outfitter_cNameAlreadyUsedError = "오류: 사용중인 이름입니다.";
	Outfitter_cNoItemsWithStatError = "경고: 해당 능력을 가진 아이템이 없습니다.";

	Outfitter_cEnableAll = "모두 활성화";
	Outfitter_cEnableNone = "모두 비활성화";

	Outfitter_cConfirmDeleteMsg = "%s 세트를 삭제 하시겠습니까?";
	Outfitter_cConfirmRebuildMsg = "%s 세트를 재구성 하시겠습니까?";
	Outfitter_cRebuild = "재구성";

	Outfitter_cWesternPlaguelands = "서부 역병지대";
	Outfitter_cEasternPlaguelands = "동부 역병지대";
	Outfitter_cStratholme = "스트라솔름";
	Outfitter_cScholomance = "스칼로맨스";
	Outfitter_cNaxxramas = "낙스라마스";
	Outfitter_cAlteracValley = "알터랙 계곡";
	Outfitter_cArathiBasin = "아라시 분지";
	Outfitter_cWarsongGulch = "전쟁노래 협곡";
	Outfitter_cEotS = "폭풍의 눈";
	Outfitter_cIronforge = "아이언포지";
	Outfitter_cCityOfIronforge = "아이언포지";
	Outfitter_cDarnassus = "다르나서스";
	Outfitter_cStormwind = "스톰윈드";
	Outfitter_cOrgrimmar = "오그리마";
	Outfitter_cThunderBluff = "썬더 블러프";
	Outfitter_cUndercity = "언더시티";
	Outfitter_cSilvermoon = "실버문";
	Outfitter_cExodar = "엑소다르";
	Outfitter_cShattrath = "샤트라스";
	Outfitter_cAQ40 = "안퀴라즈 사원";

	Outfitter_cItemStatFormats =
	{
		{Format = "체력 %+(%d+)", Types = {"Stamina"}},
		{Format = "지능 %+(%d+)", Types = {"Intellect"}},
		{Format = "민첩성 %+(%d+)", Types = {"Agility"}},
		{Format = "힘 %+(%d+)", Types = {"Strength"}},
		{Format = "정신력 %+(%d+)", Types = {"Spirit"}},
		{Format = "방어도 %+(%d+)", Types = {"Armor"}},
		{Format = "방어 숙련도 %+(%d+)", Types = {"Defense"}},
		{Format = "방어 숙련도 향상 %+(%d+)", Types = {"Defense"}},
	
		{Format = "%+(%d+) 체력", Types = {"Stamina"}},
		{Format = "%+(%d+) 지능", Types = {"Intellect"}},
		{Format = "%+(%d+) 민첩성", Types = {"Agility"}},
		{Format = "%+(%d+) 힘", Types = {"Strength"}},
		{Format = "%+(%d+) 정신력", Types = {"Spirit"}},
		{Format = "(%d+) 방어도", Types = {"Armor"}},
		{Format = "%+(%d+) 전투력", Types = {"Attack", "RangedAttack"}},
		{Format = "전투력 (%d+)만큼 증가", Types = {"Attack", "RangedAttack"}},
		{Format = "원거리 전투력 (%d+)만큼 증가", Types = {"RangedAttack"}},	
	
		{Format = "%+(%d+) 방어 숙련도", Types = {"Defense"}},
	
		{Format = "모든 능력치 %+(%d+)", Types = {"Stamina", "Intellect", "Agility", "Strength", "Spirit"}},
	
		{Format = "마나 %+(%d+)", Types = {"Mana"}},
		{Format = "생명력 %+(%d+)", Types = {"Health"}},
	
		{Format = "매 5초마다 %+(%d+)의 마나", Types = {"ManaRegen"}},
		{Format = "매 5초마다 (%d+)의 마나가 회복됩니다.", Types = {"ManaRegen"}},
	
		{Format = "매 5초마다 %+(%d+)의 생명력", Types = {"HealthRegen"}},
		{Format = "매 5초마다 (%d+)의 생명력이 회복됩니다.", Types = {"HealthRegen"}},
		{Format = "5초당 (%d+)의 생명력이 회복됩니다.", Types = {"HealthRegen"}},
	
		{Format = "최하급 탈것 속도 증가", Value = 3, Types = {"Riding"}},
		{Format = "미스릴 박차", Value = 3, Types = {"Riding"}},
	
		{Format = "화염 저항력 %+(%d+)", Types = {"FireResist"}},
		{Format = "자연 저항력 %+(%d+)", Types = {"NatureResist"}},
		{Format = "냉기 저항력 %+(%d+)", Types = {"FrostResist"}},
		{Format = "암흑 저항력 %+(%d+)", Types = {"ShadowResist"}},
		{Format = "비전 저항력 %+(%d+)", Types = {"ArcaneResist"}},
		{Format = "모든 저항력 %+(%d+)", Types = {"FireResist", "NatureResist", "FrostResist", "ShadowResist", "ArcaneResist"}},
	
		{Format = "무기 공격력 %+(%d+)", Types = {"MeleeDmg"}},
		{Format = "무기의 적중률이 (%d+)%%만큼 증가합니다.", Types = {"MeleeHit"}},
		{Format = "치명타를 적중시킬 확률이 (%d+)%%만큼 증가합니다.", Types = {"MeleeCrit"}},
		{Format = "공격을 회피할 확률이 (%d+)%%만큼 증가합니다.", Types = {"Dodge"}},
		{Format = "공격력 %+(%d+)", Types = {"MeleeDmg"}},
		{Format = "(%d+)의 피해 방어", Types = {"Block"}},
		{Format = "방어도 %+(%d+)", Types = {"Block"}},
		{Format = "방패 막기 숙련도가 (%d+)만큼 증가합니다.", Types = {"Block"}},
	
		{Format = "낚시 숙련도 %+(%d+)%.", Types = {"Fishing"}},
		{Format = "낚시 %+(%d+)", Types = {"Fishing"}},
		{Format = "약초 채집 %+(%d+)", Types = {"Herbalism"}},
		{Format = "채광 %+(%d+)", Types = {"Mining"}},
		{Format = "무두질 %+(%d+)", Types = {"Skinning"}},
	
		{Format = "주문이 극대화 효과를 낼 확률이(%d+)%%만큼 증가합니다.", Types = {"SpellCrit"}},
		{Format = "주문의 적중률이 (%d+)%%만큼 증가합니다.", Types = {"SpellHit"}},
		{Format = "모든 주문 및 효과의 공격력과 치유량이 최대 (%d+)만큼 증가합니다", Types = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg", "Healing"}},
		{Format = "모든 주문 및 효과에 의한 치유량이 최대 (%d+)만큼 증가합니다", Types = {"Healing"}},
		{Format = "주문 공격력 및 치유량 %+(%d+)", Types = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg", "Healing"}},
		{Format = "치유 및 주문 공격력 %+(%d+)", Types = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg", "Healing"}},
		{Format = "주문 치유량 %+(%d+)", Types = {"Healing"}},
		{Format = "%+(%d+) 주문 치유량", Types = {"Healing"}},
		{Format = "주문 공격력 %+(%d+)", Types = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg"}},
		{Format = "%+(%d+) 주문 공격력", Types = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg"}},
		
		{Format = "%+(%d+) 화염 주문 공격력", Types = {"FireDmg"}},
		{Format = "%+(%d+) 암흑 주문 공격력", Types = {"ShadowDmg"}},
		{Format = "%+(%d+) 냉기 주문 공격력", Types = {"FrostDmg"}},
		{Format = "%+(%d+) 비전 주문 공격력", Types = {"ArcaneDmg"}},
		{Format = "%+(%d+) 자연 주문 공격력", Types = {"NatureDmg"}},

		{Format = "화염 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다.", Types = {"FireDmg"}},
		{Format = "암흑 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다.", Types = {"ShadowDmg"}},
		{Format = "냉기 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다.", Types = {"FrostDmg"}},
		{Format = "비전 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다.", Types = {"ArcaneDmg"}},
		{Format = "자연 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다.", Types = {"NatureDmg"}},

		{Format = "방어 숙련도 %+(%d+)", Types = {"DefenseRating"}},
	
		{Format = "치명타 적중도가 (%d+)만큼 증가합니다.", Types = {"MeleeCritRating"}},
		{Format = "적중도가 (%d+)만큼 증가합니다.", Types = {"MeleeHitRating"}},
	
		{Format = "근접 치명타 적중도가 %+?(%d+)만큼 증가합니다.", Types = {"MeleeCritRating"}},
		{Format = "근접 적중도가 %+?(%d+)만큼 증가합니다.", Types = {"MeleeHitRating"}},
		{Format = "회피 숙련도가 %+?(%d+)만큼 증가합니다.", Types = {"MeleeDodgeRating"}},
		{Format = "무기 막기 숙련도가 %+?(%d+)만큼 증가합니다.", Types = {"MeleeParryRating"}},
		{Format = "방어 숙련도가 %+?(%d+)만큼 증가합니다.", Types = {"DefenseRating"}},
		{Format = "방패 막기 숙련도가 %+?(%d+)만큼 증가합니다.", Types = {"ShieldBlockRating"}},
		--{Format = "Increases your block rating by %+?(%d+)", Types = {"ShieldBlockRating"}},
	
		{Format = "주문 극대화 적중도가 (%d+)만큼 증가합니다.", Types = {"SpellCritRating"}},
		{Format = "주문의 극대화 적중도가 (%d+)만큼 증가합니다.", Types = {"SpellCritRating"}},
		{Format = "주문 적중도가 (%d+)만큼 증가합니다.", Types = {"SpellHitRating"}},
		{Format = "주문의 적중도가 (%d+)만큼 증가합니다.", Types = {"SpellHitRating"}},
		
		{Format = "주문 극대화 적중도 %+(%d+)", Types = {"SpellCritRating"}},
		{Format = "주문 적중도 %+(%d+)", Types = {"SpellHitRating"}},
	};

	Outfitter_cAgilityStatName = "민첩성";
	Outfitter_cArmorStatName = "방어도";
	Outfitter_cDefenseStatName = "방어 숙련도";
	Outfitter_cIntellectStatName = "지능";
	Outfitter_cSpiritStatName = "정신력";
	Outfitter_cStaminaStatName = "체력";
	Outfitter_cStrengthStatName = "힘";
	Outfitter_cTotalStatsName = "모든 능력치";

	Outfitter_cManaRegenStatName = "마나 회복";
	Outfitter_cHealthRegenStatName = "생명력 회복";

	Outfitter_cSpellCritStatName = "주문 극대화";
	Outfitter_cSpellHitStatName = "주문 적중도";
	Outfitter_cSpellDmgStatName = "주문 공격력";
	Outfitter_cFrostDmgStatName = "냉기 주문 공격력";
	Outfitter_cFireDmgStatName = "화염 주문 공격력";
	Outfitter_cArcaneDmgStatName = "비전 주문 공격력";
	Outfitter_cShadowDmgStatName = "암흑 주문 공격력";
	Outfitter_cNatureDmgStatName = "자연 주문 공격력";
	Outfitter_cHealingStatName = "치유량";

	Outfitter_cMeleeCritStatName = "근접 치명타";
	Outfitter_cMeleeHitStatName = "근접 적중도";
	Outfitter_cMeleeDmgStatName = "근접 공격력";
	Outfitter_cAttackStatName = "전투력";
	Outfitter_cRangedAttackStatName = "원거리 전투력";
	Outfitter_cDodgeStatName = "회피";

	Outfitter_cArcaneResistStatName = "비전 저항력";
	Outfitter_cFireResistStatName = "화염 저항력";
	Outfitter_cFrostResistStatName = "냉기 저항력";
	Outfitter_cNatureResistStatName = "자연 저항력";
	Outfitter_cShadowResistStatName = "암흑 저항력";

	Outfitter_cFishingStatName = "낚시";
	Outfitter_cHerbalismStatName = "약초 채집";
	Outfitter_cMiningStatName = "채광";
	Outfitter_cSkinningStatName = "무두질";

	Outfitter_cOptionsTitle = "Outfitter 옵션";
	Outfitter_cShowMinimapButton = "미니맵 버튼 표시";
	Outfitter_cShowMinimapButtonOnDescription = "미니맵 버튼을 사용하지 않으려면 이 설정을 끄십시오.";
	Outfitter_cShowMinimapButtonOffDescription = "미니맵 버튼을 사용하려면 이 설정을 켜십시오.";
	Outfitter_cAutoSwitch = "장비 자동-교환";
	Outfitter_cAutoSwitchOnDescription = "장비를 자동적으로 변경하지 않으려면 이 설정을 끄십시오.";
	Outfitter_cAutoSwitchOffDescription = "장비를 자동으로 변경하려면 이 설정을 켜십시오.";
	Outfitter_cTooltipInfo = "툴팁 표시";
	Outfitter_cTooltipInfoOnDescription = "툴팁에 '사용처:' 정보를 표시하지 않으려면 이 설정을 끄십시오. (착용장비에 마우스을 올렸을 때 프레임율을 향상 시킵니다.)";
	Outfitter_cTooltipInfoOffDescription = "툴팁에 '사용처:' 정보를 표시하려면 이 설정을 켜십시오.";
	Outfitter_cRememberVisibility = "망토와 투구 설정 기억";
	Outfitter_cRememberVisibilityOnDescription = "모든 망토와 투구에 대해서 동일한 설정을 하려면 이 설정을 끄십시오.";
	Outfitter_cRememberVisibilityOffDescription = "각각의 망토와 투구에 대한 설정을 기억하려면 이 설정을 켜십시오.";
	Outfitter_cShowHotkeyMessages = "단축키로 변경할때 보여주기";
	Outfitter_cShowHotkeyMessagesOnDescription = "단축키로 세트를 변경할때 메시지를 보지 않으려면 이 설정을 끄십시오.";
	Outfitter_cShowHotkeyMessagesOffDescription = "단축키로 세트를 변경할때 메시지를 보려면 이 설정을 켜십시오.";

	Outfitter_cEquipOutfitMessageFormat = "Outfitter: %s 장비됨";
	Outfitter_cUnequipOutfitMessageFormat = "Outfitter: %s 해제됨";

	Outfitter_cAboutTitle = "Outfitter 정보";
	Outfitter_cAuthor = "Designed and written by John Stephen with GemFix by smurfy\n Flight Form added by Zanoroy.";
	Outfitter_cTestersTitle = "Beta Testers";
	Outfitter_cTestersNames = "Airmid, Deziree, Fizzelbang, Harper, Kallah and Sumitra";
	Outfitter_cSpecialThanksTitle = "Special thanks for their support to";
	Outfitter_cSpecialThanksNames = "Brian, Dave, Glenn, Leah, Mark, The Mighty Pol and Forge";
	Outfitter_cGuildURL = "";
	Outfitter_cGuildURL2 = "http://www.forgeguild.com";

	Outfitter_cOpenOutfitter = "Outfitter 열기";

	Outfitter_cArgentDawnOutfitDescription = "이 세트는 역병지대에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cRidingOutfitDescription = "이 세트는 탈것을 탈 때 자동으로 착용 됩니다.";
	Outfitter_cDiningOutfitDescription = "이 세트는 음식을 먹거나 음료를 마실 때 자동으로 착용 됩니다.";
	Outfitter_cBattlegroundOutfitDescription = "이 세트는 전장에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cArathiBasinOutfitDescription = "이 세트는 아라시 분지에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cAlteracValleyOutfitDescription = "이 세트는 알터랙 계곡에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cWarsongGulchOutfitDescription = "이 세트는 전쟁노래 협곡에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cEotSOutfitDescription = "이 세트는 폭풍의 눈에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cCityOutfitDescription = "이 세트는 우호적인 대도시에 있을 때 자동으로 착용 됩니다.";
	Outfitter_cSwimmingOutfitDescription = "이 세트는 수영할 때 자동적으로 장착됩니다.";

	Outfitter_cKeyBinding = "단축키";

	BINDING_HEADER_OUTFITTER_TITLE = Outfitter_cTitle;
	BINDING_NAME_OUTFITTER_OUTFIT = "Outfitter 열기";

	BINDING_NAME_OUTFITTER_OUTFIT1  = "세트 1";
	BINDING_NAME_OUTFITTER_OUTFIT2  = "세트 2";
	BINDING_NAME_OUTFITTER_OUTFIT3  = "세트 3";
	BINDING_NAME_OUTFITTER_OUTFIT4  = "세트 4";
	BINDING_NAME_OUTFITTER_OUTFIT5  = "세트 5";
	BINDING_NAME_OUTFITTER_OUTFIT6  = "세트 6";
	BINDING_NAME_OUTFITTER_OUTFIT7  = "세트 7";
	BINDING_NAME_OUTFITTER_OUTFIT8  = "세트 8";
	BINDING_NAME_OUTFITTER_OUTFIT9  = "세트 9";
	BINDING_NAME_OUTFITTER_OUTFIT10 = "세트 10";

	Outfitter_cShowHelm = "투구 보이기";
	Outfitter_cShowCloak = "망토 보이기";
	Outfitter_cHideHelm = "투구 숨기기";
	Outfitter_cHideCloak = "망토 숨기기";

	Outfitter_cDisableOutfit = "세트 사용 안함";
	Outfitter_cDisableOutfitInBG = "전장에서 사용 안함";
	Outfitter_cDisableOutfitInCombat = "전투중 사용 안함";
	Outfitter_cDisableOutfitInAQ40 = "안퀴라즈 사원 내 사용 안함";
	Outfitter_cDisableOutfitInNaxx = "낙스라마스 내 사용 안함";
	Outfitter_cDisabledOutfitName = "%s (사용 안함)";

	Outfitter_cMinimapButtonTitle = "미니맵 버튼";
	Outfitter_cMinimapButtonDescription = "클릭 : 세트 선택, 드래그 : 미니맵 버튼 이동";

	Outfitter_cDruidClassName = "드루이드";
	Outfitter_cHunterClassName = "사냥꾼";
	Outfitter_cMageClassName = "마법사";
	Outfitter_cPaladinClassName = "성기사";
	Outfitter_cPriestClassName = "사제";
	Outfitter_cRogueClassName = "도적";
	Outfitter_cShamanClassName = "주술사";
	Outfitter_cWarlockClassName = "흑마법사";
	Outfitter_cWarriorClassName = "전사";

	Outfitter_cBattleStance = "전투 태세";
	Outfitter_cDefensiveStance = "방어 태세";
	Outfitter_cBerserkerStance = "광폭 태세";

	Outfitter_cWarriorBattleStance = "전사: 전투 태세";
	Outfitter_cWarriorDefensiveStance = "전사: 방어 태세";
	Outfitter_cWarriorBerserkerStance = "전사: 광폭 태세";

	Outfitter_cBearForm = "곰 변신";
	Outfitter_cFlightForm = "폭풍까마귀 변신";
	Outfitter_cSwiftFlightForm = "빠른 폭풍까마귀 변신";
	Outfitter_cCatForm = "표범 변신";
	Outfitter_cAquaticForm = "바다표범 변신";
	Outfitter_cTravelForm = "치타 변신";
	Outfitter_cDireBearForm = "광포한 곰 변신";
	Outfitter_cMoonkinForm = "달빛야수 변신";
	Outfitter_cTreeOfLifeForm = "생명의 나무";

	Outfitter_cGhostWolfForm = "늑대 정령";

	Outfitter_cStealth = "은신";

	Outfitter_cDruidBearForm = "드루이드: 곰 변신";
	Outfitter_cDruidCatForm = "드루이드: 표범 변신";
	Outfitter_cDruidAquaticForm = "드루이드: 바다표범 변신";
	Outfitter_cDruidTravelForm = "드루이드: 치타 변신";
	Outfitter_cDruidMoonkinForm = "드루이드: 달빛야수 변신";
	Outfitter_cDruidFlightForm = "드루이드: 폭풍까마귀 변신";
	Outfitter_cDruidSwiftFlightForm = "드루이드: 빠른 폭풍까마귀 변신";
	Outfitter_cDruidTreeOfLifeForm = "드루이드: 생명의 나무";
	Outfitter_cDruidProwl = "드루이드: 숨기";
	Outfitter_cProwl = "숨기";
	
	Outfitter_cPriestShadowform = "사제: 어둠의 형상";

	Outfitter_cRogueStealth = "도적: 은신";

	Outfitter_cShamanGhostWolf = "주술사: 늑대 정령";

	Outfitter_cHunterMonkey = "사냥꾼: 원숭이의 상";
	Outfitter_cHunterHawk =  "사냥꾼: 매의 상";
	Outfitter_cHunterCheetah =  "사냥꾼: 치타의 상";
	Outfitter_cHunterPack =  "사냥꾼: 치타 무리의 상";
	Outfitter_cHunterBeast =  "사냥꾼: 야수의 상";
	Outfitter_cHunterWild =  "사냥꾼: 야생의 상";
	Outfitter_cHunterViper = "사냥꾼: 독사의 상";

	Outfitter_cMageEvocate = "마법사: 환기";

	Outfitter_cAspectOfTheCheetah = "치타의 상";
	Outfitter_cAspectOfThePack = "치타 무리의 상";
	Outfitter_cAspectOfTheBeast = "야수의 상";
	Outfitter_cAspectOfTheWild = "야생의 상";
	Outfitter_cAspectOfTheViper = "독사의 상";
	Outfitter_cEvocate = "환기";

	Outfitter_cCompleteCategoryDescripton = "모든 슬롯의 아이템에 관한 설정이 들어있는 완전한 장비 세트입니다.";
	Outfitter_cPartialCategoryDescription = "Mix-n-match의 장비 세트는 전부가 아닌 일부 슬롯만 가집니다. 장비 세트가 선택되면 이전에 선택되었던 보조 장비 세트 또는 Mix-n-match 세트를 대체하면서, 완비 세트에서 해당 아이템만을 교체합니다.";
	Outfitter_cAccessoryCategoryDescription = "보조 장비의 장비 세트는 전부가 아닌 일부 슬롯만 가집니다. Mix-n-match와는 다르게 이전에 선택되었던 보조 장비 세트 또는 Mix-n-match 세트를 대체하지 않고 추가로 완비 세트에서 해당 아이템을 교체합니다.";
	Outfitter_cSpecialCategoryDescription = "특수 조건의 장비 세트는 해당하는 조건을 충족시킬 경우 자동으로 착용됩니다.";
	Outfitter_cOddsNEndsCategoryDescription = "나머지 장비들의 아이템들은 장비 세트에 한번도 사용되지 않은 아이템들입니다.";

	Outfitter_cRebuildOutfitFormat = "%s 재구성";

	Outfitter_cTranslationCredit = " ";

	Outfitter_cSlotEnableTitle = "슬롯 활성화";
	Outfitter_cSlotEnableDescription = "슬롯을 활성화 하면 해당 장비 세트를 사용할때 같이 변경됩니다.";

	Outfitter_cFinger0SlotName = "첫번째 손가락";
	Outfitter_cFinger1SlotName = "두번째 손가락";

	Outfitter_cTrinket0SlotName = "첫번째 장신구";
	Outfitter_cTrinket1SlotName = "두번째 장신구";

	Outfitter_cOutfitCategoryTitle = "카테고리";
	Outfitter_cBankCategoryTitle = "은행";
	Outfitter_cDepositToBank = "모든 아이템을 은행으로";
	Outfitter_cDepositUniqueToBank = "특정 아이템을 은행으로";
	Outfitter_cWithdrawFromBank = "은행으로부터 아이템 회수";

	Outfitter_cMissingItemsLabel = "찾을 수 없는 아이템: ";
	Outfitter_cBankedItemsLabel = "은행에 있는 아이템: ";

	Outfitter_cRepairAllBags = "Outfitter: 모든 아이템 수리";

	Outfitter_cStatsCategory = "능력치";
	Outfitter_cMeleeCategory = "근접";
	Outfitter_cSpellsCategory = "주문과 치유";
	Outfitter_cRegenCategory = "회복";
	Outfitter_cResistCategory = "저항";
	Outfitter_cTradeCategory = "전문기술";

	Outfitter_cTankPoints = "탱크 포인트";
	Outfitter_cCustom = "사용자 설정";

	Outfitter_cScript = "스크립트";
	Outfitter_cDisableScript = "스크립트 비활성화";
	Outfitter_cEditScriptTitle = "%s 세트에 대한 스크립트";
	Outfitter_cEditScriptEllide = "스크립트 편집...";
	Outfitter_cEventsLabel = "이벤트:";
	Outfitter_cScriptLabel = "스크립트:";
	Outfitter_cSetCurrentItems = "현재 아이템으로 갱신";
	Outfitter_cConfirmSetCurrentMsg = "%s|1을;를; 현재 착용 장비를 사용하여 갱신하시겠습니까? 주의: 세트에 현재 활성화된 슬롯만 갱신됩니다. -- 적용후 추가적으로 슬롯을 변경할 수 있습니다.";
	Outfitter_cSetCurrent = "갱신";
	Outfitter_cTyping = "입력...";
	Outfitter_cScriptErrorFormat = "%d 라인 오류: %s";
	Outfitter_cExtractErrorFormat = "%[문자열 \"장비 스크립트\"%]:(%d+):(.*)";
	Outfitter_cPresetScript = "미리 정의된 스크립트:";
	Outfitter_cCustomScript = "사용자 정의";
	Outfitter_cSettings = "설정";
	Outfitter_cSource = "원본";
	Outfitter_cInsertFormat = "<- %s";

	Outfitter_cContainerBagSubType = "가방";
	Outfitter_cUsedByPrefix = "장비 세트: ";

	Outfitter_cNone = "없음";
end
