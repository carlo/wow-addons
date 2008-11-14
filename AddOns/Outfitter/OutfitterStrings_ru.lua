if GetLocale() == "ruRU" then
	Outfitter.cTitle = "Outfitter"
	Outfitter.cTitleVersion = Outfitter.cTitle.." "..Outfitter.cVersion

	Outfitter.cSingleItemFormat = "%s"
	Outfitter.cTwoItemFormat = "%s и %s"
	Outfitter.cMultiItemFormat = "%s{{, %s}} и %s"

	Outfitter.cNameLabel = "Название:"
	Outfitter.cCreateUsingTitle = "Сделать под:"
	Outfitter.cUseCurrentOutfit = "Использвать текущий комплект"
	Outfitter.cUseEmptyOutfit = "Создать пустой комплект"
	Outfitter.cAutomationLabel = "Авто:"

	Outfitter.cOutfitterTabTitle = "Комплекты"
	Outfitter.cOptionsTabTitle = "Настройки"
	Outfitter.cAboutTabTitle = "О моде"

	Outfitter.cNewOutfit = "Новый комплект"
	Outfitter.cRenameOutfit = "Переименовать комплект"

	Outfitter.cCompleteOutfits = "Полные комплекты"
	Outfitter.cAccessoryOutfits = "Аксессуары"
	Outfitter.cOddsNEndsOutfits = "Всякая всячина"

	Outfitter.cGlobalCategory = "Специальные комплекты"
	Outfitter.cNormalOutfit = "Обычный"
	Outfitter.cNakedOutfit = "Парадный комплект"

	Outfitter.cScriptCategoryName = {}
	Outfitter.cScriptCategoryName.PVP = "Игрок против игрока"
	Outfitter.cScriptCategoryName.TRADE = "Активные"
	Outfitter.cScriptCategoryName.GENERAL = "Основные"

	Outfitter.cArgentDawnOutfit = "Серебрянный Рассвет"
	Outfitter.cCityOutfit = "Недалеко от города"
	Outfitter.cBattlegroundOutfit = "Боевые площадки"
	Outfitter.cAVOutfit = "Боевая площадка: Альтеракская долина"
	Outfitter.cABOutfit = "Боевая площадка: Низина Арати"
	Outfitter.cArenaOutfit = "Боевая площадка: Арена"
	Outfitter.cEotSOutfit = "Боевая площадка: Око Бури"
	Outfitter.cWSGOutfit = "Боевая площадка: Ущелье Песни Войны"
	Outfitter.cDiningOutfit = "Еда"
	Outfitter.cFishingOutfit = "Рыбалка"
	Outfitter.cHerbalismOutfit = "Травничество"
	Outfitter.cMiningOutfit = "Горное дело"
	Outfitter.cFireResistOutfit = "Сопротивление: Огонь"
	Outfitter.cNatureResistOutfit = "Сопротивление: Силы природы"
	Outfitter.cShadowResistOutfit = "Сопротивление: Темная магия"
	Outfitter.cArcaneResistOutfit = "Сопротивление: Тайная магия"
	Outfitter.cFrostResistOutfit = "Сопротивление: Магия льда"
	Outfitter.cRidingOutfit = "Верховая езда"
	Outfitter.cSkinningOutfit = "Свежевание"
	Outfitter.cSwimmingOutfit = "Плавание"
	Outfitter.cLowHealthOutfit = "Мало здоровья или маны"
	Outfitter.cHasBuffOutfit = "Игрок имеет баф"
	Outfitter.cInZonesOutfit = "В зонах"
	Outfitter.cSoloOutfit = "Соло/Группа/Рейд"
	Outfitter.cFallingOutfit = "Падение"

	Outfitter.cArgentDawnOutfitDescription = "Одевает комплект, когда вы находитесь в Лихоземье"
	Outfitter.cRidingOutfitDescription = "Одевает комплект для верховой езды"
	Outfitter.cDiningOutfitDescription = "Одевает комплект, когда вы едите или пьете, а ваши здоровье/жизнь ниже 90%"
	Outfitter.cBattlegroundOutfitDescription = "Одевает комплект, когда вы находитесь на боевых площадках"
	Outfitter.cArathiBasinOutfitDescription = "Одевает комплект, когда вы находитесь на боевой площадке Низина Арати"
	Outfitter.cAlteracValleyOutfitDescription = "Одевает комплект, когда вы находитесь на боевой площадке Альтеракская долина"
	Outfitter.cWarsongGulchOutfitDescription = "Одевает комплект, когда вы находитесь на боевой площадке Ущелье Песни Войны"
	Outfitter.cEotSOutfitDescription = "Одевает комплект, когда вы находитесь на Око Бури"
	Outfitter.cArenaOutfitDescription = "Одевает комплект, когда вы находитеть на арене"
	Outfitter.cCityOutfitDescription = "Одевает комплект, когда вы находитесь в одном из дружественных главных городов"
	Outfitter.cSwimmingOutfitDescription = "Одевает комплект для плавания"
	Outfitter.cFishingOutfitDescription = "Снимает комплект при входе в бой и одевает, когда бой заканчивается"
	Outfitter.cSpiritOutfitDescription = "Одевает комплект, когда вы регенереруете ману (правило пяти секунд)"
	Outfitter.cHerbalismDescription = "Одевает комплект, когда курсор наведен на траву для добычи , и умений недостаточно"
	Outfitter.cMiningDescription = "Одевает комплект, когда курсор наведен на жилу для добычи , и умений недостаточно"
	Outfitter.cLockpickingDescription = "Одевает комплект, когда курсор наведен на замок для вскрытия, и умений недостаточно"
	Outfitter.cSkinningDescription = "Одевает комплект, когда курсор наведен на животное, предназначенное для освежевания, и умений недостаточно"
	Outfitter.cLowHealthDescription = "Одевает комплект, когда ваше здоровье или мана на определенном уровне"
	Outfitter.cHasBuffDescription = "Одевает комплект, в зависимости от бафа"
	Outfitter.SpiritRegenOutfitDescription = "Одевает комплект, когда вы регенереруете ману (правило пяти секунд)"
	Outfitter.cDruidCasterFormDescription = "Одевает комплект, когда вы ни в одной из форм друида"
	Outfitter.cPriestShadowformDescription = "Одевает комплект, когда вы находитесь в shadow form"
	Outfitter.cShamanGhostWolfDescription = "Одевает комплект, когда вы находитесь в ghost wolf form"
	Outfitter.cHunterMonkeyDescription = "Одевает комплект, когда вы находитесь в Monkey aspect"
	Outfitter.cHunterHawkDescription = "Одевает комплект, когда вы находитесь в Hawk aspect"
	Outfitter.cHunterCheetahDescription = "Одевает комплект, когда вы находитесь в Cheetah aspect"
	Outfitter.cHunterPackDescription = "Одевает комплект, когда вы находитесь в Pack aspect"
	Outfitter.cHunterBeastDescription = "Одевает комплект, когда вы находитесь в Beast aspect"
	Outfitter.cHunterWildDescription = "Одевает комплект, когда вы находитесь в Wild aspect"
	Outfitter.cHunterViperDescription = "Одевает комплект, когда вы находитесь в Viper aspect"
	Outfitter.cHunterFeignDeathDescription = "Одевает комплект, когда вы находитесь в feigning death"
	Outfitter.cMageEvocateDescription = "Одевает комплект, когда вы находитесь в evocating"
	Outfitter.cWarriorBerserkerStanceDescription = "Одевает комплект, когда вы находитесь в Berserker stance"
	Outfitter.cWarriorDefensiveStanceDescription = "Одевает комплект, когда вы находитесь в Defensive stance"
	Outfitter.cWarriorBattleStanceDescription = "Одевает комплект, когда вы находитесь в Battle stance"
	Outfitter.cInZonesOutfitDescription = "Одевает комплект, когда вы находитесь в одной из зон на мини-карте, представленных ниже"
	Outfitter.cSoloOutfitDescription = "Одевает комплект для соло, группы или рейда, в зависимости от настроек"
	Outfitter.cFallingOutfitDescription = "Одевает комплект, когда вы падаете"

	Outfitter.cMountSpeedFormat = "Увеличение скорости ездового животного на (%d+)%%%."; -- For detecting when mounted
	Outfitter.cFlyingMountSpeedFormat = "Increases flight speed by (%d+)%%%."; -- For detecting when mounted

	Outfitter.cBagsFullError = "Не могу снять %s, так как сумки заполнены"
	Outfitter.cDepositBagsFullError = "Не могу поместить %s в банк, так как в банке нет места"
	Outfitter.cWithdrawBagsFullError = "Не могу взять %s, так как сумки заполнены"
	Outfitter.cItemNotFoundError = "Не могу найти %s"
	Outfitter.cItemAlreadyUsedError = "Не могу поместить %s в ячейку %s, потому что предмет уже используется в другой ячейке"
	Outfitter.cAddingItem = "Предмет %s добавлен к комплекту %s"
	Outfitter.cNameAlreadyUsedError = "Ошибка: Имя уже используется"
	Outfitter.cNoItemsWithStatError = "Предупрежение: Ни одна из ваших вещей не имеет этих атрибутов"
	Outfitter.cCantUnequipCompleteError = "Не могу снять %s потому что полные комплекты не могут быть сняты целиком (вы должны одеть другой полный комплект)"

	Outfitter.cEnableAll = "Включить все"
	Outfitter.cEnableNone = "Отключить все"

	Outfitter.cConfirmDeleteMsg = "Вы правда хотите удалить комплект %s?"
	Outfitter.cConfirmRebuildMsg = "Вы правда хотите перестроить комплект %s?"
	Outfitter.cRebuild = "Перестроить"

	Outfitter.cWesternPlaguelands = "Западное Лихоземье"
	Outfitter.cEasternPlaguelands = "Восточное Лихоземье"
	Outfitter.cStratholme = "Стратхольм"
	Outfitter.cScholomance = "Некроситет"
	Outfitter.cNaxxramas = "Naxxramas"
	Outfitter.cAlteracValley = "Альтеракская долина"
	Outfitter.cArathiBasin = "Низина Арати"
	Outfitter.cWarsongGulch = "Ущелье Песни Войны"
	Outfitter.cEotS = "Око Бури"
	Outfitter.cIronforge = "Стальгорн"
	Outfitter.cCityOfIronforge = "Стальгорн"
	Outfitter.cDarnassus = "Дарнасс"
	Outfitter.cStormwind = "Штормград"
	Outfitter.cOrgrimmar = "Огриммар"
	Outfitter.cThunderBluff = "Громовой Утес"
	Outfitter.cUndercity = "Подгород"
	Outfitter.cSilvermoon = "Луносвет"
	Outfitter.cExodar = "Экзодар"
	Outfitter.cShattrath = "Шаттрат"
	Outfitter.cAQ40 = "Храм Ан'Кираж"
	Outfitter.cBladesEdgeArena = "Blade's Edge Arena"
	Outfitter.cNagrandArena = "Арена Награнда"
	Outfitter.cRuinsOfLordaeron = "Руины Лордаэрона"

	Outfitter.cItemStatFormats =
	{
		{Format = "Minor Mount Speed Increase", Value = 3, Types = {"Riding"}},
		{Format = "Mithril Spurs", Value = 3, Types = {"Riding"}},
		
		"Increases damage done by (.+) spells and effects by up to (%d+)",
		"Increases (.+) done by up to (%d+) and (healing) done by up to (%d+)",
		"Increases (healing) done by up to (%d+) and damage done by up to (%d+) for all (magical spells and effects)",
		"Increases the (.+) of your .+ by (%d+)",
		"Increases your (.+) by (%d+)",
		"Improves your (.+) by (%d+)",
		"Increases (.+) by up to (%d+)",
		"Increases (.+) by (%d+)",
		"%+(%d+) (.+) and %+(%d+) (.+)", -- Multi-stat items like secondary-color gems
		"%+(%d+) (.+)/%+(%d+) (.+)/%+(%d+) (.+)", -- Multi-stat enchants from ZG
		"%+(%d+) (.+)/%+(%d+) (.+)", -- Multi-stat enchants from ZG
		
		"Increased (.+) %+(%d+)",
		"Improves (.+) by (%d+)",
		
		"Restores (%d+) (.+)",
		
		"%+(%d+) (%w+) Spell Damage",
		
		"(%d+) (.+)",
		"(.+) %+(%d+)",
	}

	Outfitter.cItemStatPhrases =
	{
		["Выносливость"] = "Stamina",
		["Интеллект"] = "Intellect",
		["Ловкость"] = "Agility",
		["Сила"] = "Strength",
		["Дух"] = "Spirit",
		["all stats"] = {"Stamina", "Intellect", "Agility", "Strength", "Spirit"},
		
		["Броня"] = "Armor",
		
		["Мана"] = "Mana",
		["Здоровье"] = "Health",
		
		["fire resistance"] = "FireResist",
		["nature resistance"] = "NatureResist",
		["frost resistance"] = "FrostResist",
		["shadow resistance"] = "ShadowResist",
		["arcane resistance"] = "ArcaneResist",
		["all resistances"] = {"FireResist", "NatureResist", "FrostResist", "ShadowResist", "ArcaneResist"},
		
		["defense rating"] = "DefenseRating",
		["resilience rating"] = "ResilienceRating",
		["attack power"] = {"Attack", "RangedAttack"},
		["ranged attack power"] = "RangedAttack",
		["critical strike rating"] = "MeleeCritRating",
		["hit rating"] = "MeleeHitRating",
		["dodge rating"] = "DodgeRating",
		["parry rating"] = "ParryRating",
		["block"] = "Block",
		["block value"] = "Block",
		["weapon damage"] = "MeleeDmg",
		["damage"] = "MeleeDmg",
		["haste rating"] = "MeleeHasteRating",
		
		["spell critical rating"] = "SpellCritRating",
		["spell critical strike rating"] = "SpellCritRating",
		["spell hit rating"] = "SpellHitRating",
		["spell penetration"] = "SpellPen",
		["spell haste rating"] = "SpellHasteRating",
		
		["damage and healing done by magical spells and effects"] = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg", "Healing"},
		["spell damage"] = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg"},
		["spell power"] = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg"},
		["spell damage and healing"] = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg", "Healing"},
		["magical spells and effects"] = {"SpellDmg", "ShadowDmg", "FireDmg", "FrostDmg", "ArcaneDmg", "NatureDmg"},
		
		["fire"] = "FireDmg",
		["shadow"] = "ShadowDmg",
		["frost"] = "FrostDmg",
		["arcane"] = "ArcaneDmg",
		["nature"] = "NatureDmg",
		
		["healing done by spells and effects"] = "Healing",
		["healing"] = "Healing",
		["healing spells"] = "Healing",
		
		["Рыбная ловля"] = "Fishing",
		["Травничество"] = "Herbalism",
		["Горное дело"] = "Mining",
		["Свежевание"] = "Skinning",
		["Верховая езда"] = "Riding",
		
		["mana per 5 sec"] = {"ManaRegen", "CombatManaRegen"},
		["mana regen"] = {"ManaRegen", "CombatManaRegen"},
		["health per 5 sec"] = {"HealthRegen", "CombatHealthRegen"},
		["health regen"] = {"HealthRegen", "CombatHealthRegen"},
	}

	Outfitter.cAgilityStatName = "Ловкость"
	Outfitter.cArmorStatName = "Броня"
	Outfitter.cDefenseStatName = "Защита"
	Outfitter.cIntellectStatName = "Интеллект"
	Outfitter.cSpiritStatName = "Дух"
	Outfitter.cStaminaStatName = "Выносливость"
	Outfitter.cStrengthStatName = "Сила"
	Outfitter.cTotalStatsName = "Общие показатели"
	Outfitter.cHealthStatName = "Здоровье"
	Outfitter.cManaStatName = "Мана"

	Outfitter.cManaRegenStatName = "Мана в 5"
	Outfitter.cCombatManaRegenStatName = "Мана в 5 (бой)"
	Outfitter.cHealthRegenStatName = "Здоровье в 5"
	Outfitter.cCombatHealthRegenStatName = "Здоровье в 5 (бой)"

	Outfitter.cSpellCritStatName = "Крит. урон от магии"
	Outfitter.cSpellHitStatName = "Рейтинг меткости"
	Outfitter.cSpellDmgStatName = "Урон от магии"
	Outfitter.cSpellHasteStatName = "Скорость магии"
	Outfitter.cFrostDmgStatName = "Урон от заклинаний магии льда"
	Outfitter.cFireDmgStatName = "Урон от огненный заклинаний"
	Outfitter.cArcaneDmgStatName = "Урон от заклинаний тайной магии"
	Outfitter.cShadowDmgStatName = "Урон от заклинаний темной магии"
	Outfitter.cNatureDmgStatName = "Урон от заклинаний сил природы"
	Outfitter.cHealingStatName = "Лечение"

	Outfitter.cMeleeCritStatName = "Крит. удар"
	Outfitter.cMeleeHitStatName = "Рейтинг меткости"
	Outfitter.cMeleeHasteStatName = "Скорость атаки"
	Outfitter.cMeleeDmgStatName = "Урон"
	Outfitter.cAttackStatName = "Сила атаки"
	Outfitter.cRangedAttackStatName = "Сила атаки дальнего боя"
	Outfitter.cDodgeStatName = "Уклонение"
	Outfitter.cParryStatName = "Парирование"
	Outfitter.cBlockStatName = "Блок"
	Outfitter.cResilienceStatName = "Устойчивость"

	Outfitter.cArcaneResistStatName = "Сопротивление тайной магии"
	Outfitter.cFireResistStatName = "Сопротивление огню"
	Outfitter.cFrostResistStatName = "Сопротивление магии льда"
	Outfitter.cNatureResistStatName = "Сопротивление силам природы"
	Outfitter.cShadowResistStatName = "Сопротивление темной магии"

	Outfitter.cFishingStatName = "Рыбная ловля"
	Outfitter.cHerbalismStatName = "Травничество"
	Outfitter.cMiningStatName = "Горное дело"
	Outfitter.cSkinningStatName = "Cнятие шкур"

	Outfitter.cOptionsTitle = "Настройки"
	Outfitter.cShowMinimapButton = "Иконка на мини-карте"
	Outfitter.cShowMinimapButtonOnDescription = "Отлючичите, если не хотите видеть иконку Outfitter на мини-карте"
	Outfitter.cShowMinimapButtonOffDescription = "Включие, если хотите видеть иконку Outfitter на мини-карте"
	Outfitter.cAutoSwitch = "Отключить авто-смены"
	Outfitter.cAutoSwitchOnDescription = "Включите, если не хотите автоматической смены комплектов"
	Outfitter.cAutoSwitchOffDescription = "Отключите, если хотите автоматическую смену комплектов"
	Outfitter.cTooltipInfo = "'Используется:' в описании вещи"
	Outfitter.cTooltipInfoOnDescription = "Выключите, если не хотите видеть 'Используется:' в описании вещи или у вас проблемы с просмотром вещей"
	Outfitter.cTooltipInfoOffDescription = "Включите, если хотите видеть 'Используется:' в описании вещи"
	Outfitter.cOutfitDisplay = "Outfit display"
	Outfitter.cShowHotkeyMessages = "Сообщения о смене комплекта"
	Outfitter.cShowHotkeyMessagesOnDescription = "Отключите, если не хотите Показывать сообщения о смене комплекта по клавиатурным привязкам"
	Outfitter.cShowHotkeyMessagesOffDescription = "Включите, если хотите показывать сообщения о смене комплекта по клавиатурным привязкам"
	Outfitter.cShowOutfitBar = "Показывать комплект-панель"
	Outfitter.cShowOutfitBarDescription = "Показывает комплект-панель Outfitter с клавишами всех комплектов"
	Outfitter.cEquipOutfitMessageFormat = "Outfitter: %s одет"
	Outfitter.cUnequipOutfitMessageFormat = "Outfitter: %s снят"

	Outfitter.cAboutTitle = "Об Outfitter"
	Outfitter.cAuthor = "Designed and written by John Stephen with contributions by %s"
	Outfitter.cTestersTitle = "Outfitter тестеры"
	Outfitter.cTestersNames = "%s"
	Outfitter.cSpecialThanksTitle = "Специальное спасибо"
	Outfitter.cSpecialThanksNames = "%s"
	Outfitter.cTranslationCredit = "Переводы %s"
	Outfitter.cURL = "wobbleworks.com"

	Outfitter.cOpenOutfitter = "Открыть Outfitter"

	Outfitter.cKeyBinding = "Клавиатурные привзяки"

	BINDING_HEADER_OUTFITTER_TITLE = Outfitter.cTitle
	BINDING_NAME_OUTFITTER_OUTFIT = "Открыть Outfitter"

	BINDING_NAME_OUTFITTER_OUTFIT1  = "Комплект 1"
	BINDING_NAME_OUTFITTER_OUTFIT2  = "Комплект 2"
	BINDING_NAME_OUTFITTER_OUTFIT3  = "Комплект 3"
	BINDING_NAME_OUTFITTER_OUTFIT4  = "Комплект 4"
	BINDING_NAME_OUTFITTER_OUTFIT5  = "Комплект 5"
	BINDING_NAME_OUTFITTER_OUTFIT6  = "Комплект 6"
	BINDING_NAME_OUTFITTER_OUTFIT7  = "Комплект 7"
	BINDING_NAME_OUTFITTER_OUTFIT8  = "Комплект 8"
	BINDING_NAME_OUTFITTER_OUTFIT9  = "Комплект 9"
	BINDING_NAME_OUTFITTER_OUTFIT10 = "Комплект 10"
	
	Outfitter.cShow = "Показать"
	Outfitter.cHide = "Скрыть"
	Outfitter.cDontChange = "Не менять"

	Outfitter.cHelm = "Головной убор"
	Outfitter.cCloak = "Плащ"
	Outfitter.cPlayerTitle = "Title"

	Outfitter.cAutomation = "Авто"

	Outfitter.cDisableOutfit = "Отключить"
	Outfitter.cDisableAlways = "Всегда"
	Outfitter.cDisableOutfitInBG = "На боевых площадках"
	Outfitter.cDisableOutfitInCombat = "Отключено пока в бою"
	Outfitter.cDisableOutfitInAQ40 = "В храме Ан'Кираж"
	Outfitter.cDisableOutfitInNaxx = "В Наксрамасе"
	Outfitter.cDisabledOutfitName = "%s (Отключено)"

	Outfitter.cOutfitBar = "Outfit панель"
	Outfitter.cShowInOutfitBar = "Показывать в комплект-панели"
	Outfitter.cChangeIcon = "Выбрать иконку..."

	Outfitter.cMinimapButtonTitle = "Значек Outfitter на мини-карте"
	Outfitter.cMinimapButtonDescription = "Щелкните для выбора различных комплектов или тяните для перестаскивания иконки."

	Outfitter.cClassName = {}
	Outfitter.cClassName.DRUID = "Друид"
	Outfitter.cClassName.HUNTER = "Охотник"
	Outfitter.cClassName.MAGE = "Маг"
	Outfitter.cClassName.PALADIN = "Паладин"
	Outfitter.cClassName.PRIEST = "Жрец"
	Outfitter.cClassName.ROGUE = "Разбойник"
	Outfitter.cClassName.SHAMAN = "Шаман"
	Outfitter.cClassName.WARLOCK = "Чернокнижник"
	Outfitter.cClassName.WARRIOR = "Воин"

	Outfitter.cBattleStance = "Боевая стойка"
	Outfitter.cDefensiveStance = "Оборонительная стойка"
	Outfitter.cBerserkerStance = "Стойка берсерка"

	Outfitter.cWarriorBattleStance = "Воин: Боевая стойка"
	Outfitter.cWarriorDefensiveStance = "Воин: Оборонительная стойка"
	Outfitter.cWarriorBerserkerStance = "Воин: Стойка берсерка"

	Outfitter.cBearForm = "Облик медведя"
	Outfitter.cFlightForm = "Облик птицы"
	Outfitter.cSwiftFlightForm = "Быстрый воздушный облик"
	Outfitter.cCatForm = "Облик кошки"
	Outfitter.cAquaticForm = "Водный облик"
	Outfitter.cTravelForm = "Походный облик"
	Outfitter.cDireBearForm = "Облик лютого медведя"
	Outfitter.cMoonkinForm = "Облик лунного совуха"
	Outfitter.cTreeOfLifeForm = "Древо Жизни"

	Outfitter.cGhostWolfForm = "Призрачный волк"

	Outfitter.cStealth = "Незаметность"

	Outfitter.cDruidCasterForm = "Друид: форма гуманоида"
	Outfitter.cDruidBearForm = "Друид: Облик медведя"
	Outfitter.cDruidCatForm = "Друид: Облик кошки"
	Outfitter.cDruidAquaticForm = "Друид: Водный облик"
	Outfitter.cDruidTravelForm = "Друид: Походный облик"
	Outfitter.cDruidMoonkinForm = "Друид: Облик лунного совуха"
	Outfitter.cDruidFlightForm = "Друид: Облик птицы"
	Outfitter.cDruidSwiftFlightForm = "Друид: Быстрый воздушный облик"
	Outfitter.cDruidTreeOfLifeForm = "Друид: Древо Жизни"
	Outfitter.cDruidProwl = "Друид: Крадущийся зверь"
	Outfitter.cProwl = "Крадущийся зверь"

	Outfitter.cPriestShadowform = "Жрец: Облик Тьмы"

	Outfitter.cRogueStealth = "Разбойник: Незаметность"
	Outfitter.cLockpickingOutfit = "Разбойник: Взлом замка"

	Outfitter.cShamanGhostWolf = "Шаман: Призрачный волк"

	Outfitter.cHunterMonkey = "Охотник: Дух обезьяны"
	Outfitter.cHunterHawk =  "Охотник: Дух ястреба"
	Outfitter.cHunterCheetah =  "Охотник: Дух гепарда"
	Outfitter.cHunterPack =  "Охотник: Дух стаи"
	Outfitter.cHunterBeast =  "Охотник: Дух зверя"
	Outfitter.cHunterWild =  "Охотник: Дух дикой природы"
	Outfitter.cHunterViper = "Охотник: Дух гадюки"
	Outfitter.cHunterFeignDeath = "Охотник: Дух гепарда"

	Outfitter.cMageEvocate = "Маг: Прилив сил"
	Outfitter.cEvocate = "Прилив сил"


	Outfitter.cAspectOfTheCheetah = "Дух гепарда"
	Outfitter.cAspectOfThePack = "Дух стаи"
	Outfitter.cAspectOfTheBeast = "Дух зверя"
	Outfitter.cAspectOfTheWild = "Дух дикой природы"
	Outfitter.cAspectOfTheViper = "Дух гадюки"


	Outfitter.cCompleteCategoryDescription = "Полные комплекты занимают все ячейки на персонаже. При смене любого комплекта на этот - все вещи переодеваются."
	Outfitter.cAccessoryCategoryDescription = "Аксессуары - это неполные комплекты. Вы можете одевать сразу несколько комплектов акксесуаров"
	Outfitter.cOddsNEndsCategoryDescription = "Всякая всячина - это предметы, которых нет ни в одном комплекте."

	Outfitter.cRebuildOutfitFormat = "Перестроить для %s"

	Outfitter.cSlotEnableTitle = "Использовать ячейку"
	Outfitter.cSlotEnableDescription = "Выберите, если хотите включить данный предмет в текущий комплект. Если предмет не выбран, комплект не изменится при смене."

	Outfitter.cFinger0SlotName = "Первый палец"
	Outfitter.cFinger1SlotName = "Второй палец"

	Outfitter.cTrinket0SlotName = "Первый аксессуар"
	Outfitter.cTrinket1SlotName = "Второй аксессуар"

	Outfitter.cOutfitCategoryTitle = "Категория"
	Outfitter.cBankCategoryTitle = "Банк"
	Outfitter.cDepositToBank = "Положить все предметы в банк"
	Outfitter.cDepositUniqueToBank = "Положить предметы в банк по одному"
	Outfitter.cWithdrawFromBank = "Забрать предметы из банка"

	Outfitter.cMissingItemsLabel = "Отстутствующие предметы: "
	Outfitter.cBankedItemsLabel = "Предметы из банка: "

	Outfitter.cStatsCategory = "Характеристики"
	Outfitter.cMeleeCategory = "Ближний бой"
	Outfitter.cSpellsCategory = "Лечение и магический урон"
	Outfitter.cRegenCategory = "Регенерация"
	Outfitter.cResistCategory = "Сопротивления"
	Outfitter.cTradeCategory = "Умения"

	Outfitter.cTankPoints = "ОчкиТанка"
	Outfitter.cCustom = "Настройка"

	Outfitter.cScriptFormat = "Скрипт (%s)"
	Outfitter.cScriptSettings = "Настройки..."
	Outfitter.cNoScript = "Пусто"
	Outfitter.cDisableScript = "Отключено"
	Outfitter.cDisableIn = "Отключено"
	Outfitter.cEditScriptTitle = "Скрипт для комплекта %s"
	Outfitter.cEditScriptEllide = "Свой..."
	Outfitter.cEventsLabel = "События:"
	Outfitter.cScriptLabel = "Скрипт:"
	Outfitter.cSetCurrentItems = "Обновить на текущие предметы"
	Outfitter.cConfirmSetCurrentMsg = "Вы правда хотите обновить комплект %s, используюя текущие предметы? Примечание: только включенные ячейки будут обновлены"
	Outfitter.cSetCurrent = "Обновить"
	Outfitter.cTyping = "Идет набор текста..."
	Outfitter.cScriptErrorFormat = "Ошибка на строке %d: %s"
	Outfitter.cExtractErrorFormat = "%[string \"Outfit Script\"%]:(%d+):(.*)"
	Outfitter.cPresetScript = "Скрипт по умолчанию:"
	Outfitter.cCustomScript = "Custom"
	Outfitter.cSettings = "Настройки"
	Outfitter.cSource = "Источник"
	Outfitter.cInsertFormat = "<- %s"

	Outfitter.cUsedByPrefix = "Используется в комплектах: "

	Outfitter.cNone = "Пусто"
	Outfitter.cTooltipMultibuffSeparator1 = " и "
	Outfitter.cTooltipMultibuffSeparator2 = " / "
	Outfitter.cNoScriptSettings = "Нет настроек для этого скрипта."
	Outfitter.cMissingItemsSeparator = ", "
	Outfitter.cUnequipOthers = "При смене снимать другие комплекты Акссесуаров"

	Outfitter.cConfirmResetMsg = "Вы правда хотите обнулить настройки Outfitter для этого персонажа?  Все комплекты будут удалены и созданы по умолчанию."
	Outfitter.cReset = "Сбросить"

	Outfitter.cIconFilterLabel = "Поиск:"
	Outfitter.cIconSetLabel = "Иконки:"

	Outfitter.cCantReloadUI = "Вам необходимо перезапустить WoW для обновления Outfitter"
	Outfitter.cChooseIconTitle = "Выберите иконку для комплекта %s"
	Outfitter.cOutfitterDecides = "Outfitter выбрал иконку за Вас"

	Outfitter.cSuggestedIcons = "Предложенные иконки"
	Outfitter.cSpellbookIcons = "Ваши заклинания"
	Outfitter.cYourItemIcons = "Ваши сумки"
	Outfitter.cEveryIcon = "Все иконки"
	Outfitter.cItemIcons = "Все иконки (предметы)"
	Outfitter.cAbilityIcons = "Все иконки (заклинания)"

	Outfitter.cRequiresLockpicking = "Требуется Взлом замка"
	Outfitter.cUseDurationTooltipLineFormat = "^Использование:.*на (%d+) сек."
	Outfitter.cUseDurationTooltipLineFormat2 = "^Использование:.*Время действия (%d+) сек."

	Outfitter.cOutfitBarSizeLabel = "Размер"
	Outfitter.cOutfitBarSmallSizeLabel = "Мал"
	Outfitter.cOutfitBarLargeSizeLabel = "Бол"
	Outfitter.cOutfitBarAlphaLabel = "Прозрачность"
	Outfitter.cOutfitBarCombatAlphaLabel = "Прозрачность в бою"
	Outfitter.cOutfitBarVerticalLabel = "Вертикально"
	Outfitter.cOutfitBarLockPositionLabel = "Заблокировать"
	Outfitter.cOutfitBarHideBackgroundLabel = "Убрать фон"

	Outfitter.cPositionLockedError = "Комплект-панель заблокирована и не может быть перемещена"

	Outfitter.cMustBeAtBankError = "Вы должны открыть свой банк для отчета по пропавшим предметам"
	Outfitter.cMissingItemReportIntro = "Пропавшие предметы (если один и тотже предмет использовался в разных комплектах,то он будет показан в отчете несколько раз):"
	Outfitter.cNoMissingItems = "Все предметы на месте"

	Outfitter.cAutoChangesDisabled = "Автоматическая смена отключена"
	Outfitter.cAutoChangesEnabled = "Автоматическая смена включена"
	
	Outfitter.c2HAxes = "Двуручные топоры"
	Outfitter.c2HMaces = "Двуручное ударное оружие"
	Outfitter.c2HSwords = "Двуручные мечи"
	
	-- OutfitterFu strings
	
	Outfitter.cFuHint = "Left-click to toggle Outfitter window."
	Outfitter.cFuHideMissing = "Hide missing"
	Outfitter.cFuHideMissingDesc = "Hide outfits with missing items."
	Outfitter.cFuRemovePrefixes = "Remove prefixes"
	Outfitter.cFuRemovePrefixesDesc = "Remove outfit name prefixes to shorten the text displayed in FuBar."
	Outfitter.cFuMaxTextLength = "Max text length"
	Outfitter.cFuMaxTextLengthDesc = "The maximum length of the text displayed in FuBar."
	Outfitter.cFuHideMinimapButton = "Hide minimap button"
	Outfitter.cFuHideMinimapButtonDesc = "Hide Outfitter's minimap button."
	Outfitter.cFuInitializing = "Initializing"
end
