local L = AceLibrary("AceLocale-2.2"):new("beql")

L:RegisterTranslations("ruRU", function() return{

	["Bayi's Extended Quest Log"] = "Bayi's Extended Quest Log",
	["No Objectives!"] = "Нет Целей!",
	["(Done)"] = "(Сделано)",
	["Click to open Quest Log"] = "Нажмите, чтобы открыть Журнал Заданий",
	["Completed!"] = "Выполнено!",
	[" |cffff0000Disabled by|r"] = " |cffff0000Отключено|r",
	["Reload UI ?"] = "Перезагрузить интерфейс?",
	["FubarPlugin Config"] = "Настройки FuBar",
	["Requires Interface Reload"] = "Требует перезагрузку интерфейса игры.",

	["Quest Log Options"] = "Журнал заданий",
	["Options related to the Quest Log"] = "Настройки журнала заданий",
	["Lock Quest Log"] = "Прилепить журнал заданий",
	["Makes the quest log unmovable"] = "Выберите, чтобы сделать журнал заданий неперемещаемым.",
	["Always Open Minimized"] = "Всегда открывать свернутым",
	["Force the quest log to open minimized"] = "Выберите, чтобы журнал заданий всегда открывался в свернутом виде.",
	["Always Open Maximized"] = "Всегда открывать развернутым",
	["Force the quest log to open maximized"] = "Выберите, чтобы журнал заданий всегда открывался в развернутом виде.",
	["Show Quest Level"] = "Показывать уровень задания",
	["Shows the quests level"] = "Выберите, чтобы в журнале показывались уровни заданий.",
	["Info on Quest Completion"] = "Извещать о выполнении задания",
	["Shows a message and plays a sound when you complete a quest"] = "Выберите, чтобы после выполнения задания проигрывался звуковой сигнал и появлялось текстовое сообщение.",
	["Auto Complete Quest"] = "Автозавершение задания",
	["Automatically Complete Quests"] = "Выберите, чтобы автоматически (без диалога) получать награду у нанимателя за выполненые задания (если такое возможно).",
	["Mob Tooltip Quest Info"] = "Инфо в окне подсказки существа",
	["Show quest info in mob tooltips"] = "Выберите, чтобы информация о задании появилась в окне подсказки существа.",
	["Item Tooltip Quest Info"] = "Инфо в окне подсказки предмета",
	["Show quest info in item tooltips"] = "Выберите, чтобы информация о задании появилась в окне подсказки существа.",
	["Simple Quest Log"] = "Стандартный вид",
	["Uses the default Blizzard Quest Log"] = "Выберите, чтобы использовать стандартный вид журнала заданий от Blizzard.",
	["Quest Log Alpha"] = "Прозрачность журнала заданий",
	["Sets the Alpha of the Quest Log"] = "Setzt die Transparenz des Questlogs.",

	["Quest Tracker"] = "Список заданий",
	["Quest Tracker Options"] = "Список заданий",
	["Options related to the Quest Tracker"] = "Настройки списка заданий",
	["Lock Tracker"] = "Прилепить список",
	["Makes the quest tracker unmovable"] = "Выберите, чтобы сделать список неперемещаемым.",
	["Show Tracker Header"] = "Показывать заголовок списка",
	["Shows the trackers header"] = "Выберите, чтобы показать заголовок списка заданий.",
	["Hide Completed Objectives"] = "Скрывать выполненные цели",
	["Automatical hide completed objectives in tracker"] = "Выберите, чтобы автоматически скрывать выполненные цели задания в списке.",
	["Remove Completed Quests"] = "Убирать выполненные задания",
	["Automatical remove completed quests from tracker"] = "Выберите, чтобы автоматически убирать выполненные задания из списка.",
	["Font Size"] = "Размер шрифта",
	["Changes the font size of the tracker"] = "Устанавливает размер шрифта списка заданий",
	["Sort Tracker Quests"] = "Сортировать задания в списке",
	["Sort the quests in tracker"] = "Выберите, чтобы автоматически сортировать задания в списке.",
	["Show Quest Zones"] = "Показывать зоны",
	["Show the quests zone it belongs to above its name"] = "Выберите, чтобы над названиями заданий писались зоны, к которым задания принадлежат.",
	["Add New Quests"] = "Добавлять новые задания",
	["Automatical add new Quests to tracker"] = "Выберите, чтобы новые задания автоматически добавлялись в список.",
	["Add Untracked"] = "Добавлять обновившиеся задания",
	["Automatical add quests with updated objectives to tracker"] = "Выберите, чтобы в список автоматически добавлялись задания, цели которых обновились.",
	["Reset tracker position"] = "Исходная позиция списка",
	["Active Tracker"] = "Активный список",
	["Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker"] = "Выберите, чтобы сделать список активным: при наведении курсора на задание в списке показываются подсказки, нажатие ЛКМ на название открывает журнал, нажатие ПКМ убирает задание из списка.",
	["Hide Objectives for Completed only"] = "Скрывать только для выполненных заданий",
	["Hide objectives only for completed quests"] = "Выберите, чтобы автоматически цели скрывались только для выполненных заданий.",

	["Markers"] = "Маркеры",
	["Customize the Objective/Quest Markers"] = "Настройки маркеров Целей и Заданий",
	["Show Objective Markers"] = "Показывать маркеры целей",
	["Display Markers before objectives"] = "Выберите, чтобы отображать маркеры перед целями.",
	["Use Listing"] = "Использовать список",
	["User Listing rather than symbols"] = "Выберите, чтобы использовать пользовательский список вместо символов.",
	["List Type"] = "Тип списка",
	["Set the type of listing"] = "Устанавливает тип списка",
	["Symbol Type"] = "Тип символов",
	["Set the type of symbol"] = "Устанавливает тип символов: -, +, @, >",

	["Colors"] = "Настройки цвета",
	["Set tracker Colors"] = "Настройки цветов списка заданий",
	["Background"] = "Использовать фон",
	["Use Background"] = "Выберите, чтобы использовать фон для списка заданий.",
	["Custom Background Color"] = "Изменить цвет фона",
	["Use custom color for background"] = "Выберите, чтобы самостоятельно установить цвет фона.",
	["Background Color"] = "Цвет фона",
	["Sets the Background Color"] = "Установка цвета фона.",
	["Background Corner Color"] = "Цвет границы",
	["Sets the Background Corner Color"] = "Установка цвета границы.",
	["Use Quest Level Colors"] = "Цветовая индикация сложности",
	["Use the colors to indicate quest difficulty"] = "Выберите, чтобы использовать изменение цвета текста названия в зависимости от сложности задания.",
	["Custom Zone Color"] = "Изменить цвет зоны",
	["Use custom color for Zone names"] = "Выберите, чтобы самостоятельно установить цвет текста надписи зоны задания.",
	["Zone Color"] = "Цвет зоны",
	["Sets the zone color"] = "Установка цвета зоны.",
	["Fade Colors"] = "Использовать затемнение цвета",
	["Fade the objective colors"] = "Выберите, чтобы применить автоматическое затемнение цвета надписи цели.",
	["Custom Objective Color"] = "Изменить цвет цели",
	["Use custom color for objective text"] = "Выберите, чтобы самостоятельно установить цвет надписи цели.",
	["Objective Color"] = "Невыполненная цель",
	["Sets the color for objectives"] = "Установка цвета надписи цели.",
	["Completed Objective Color"] = "Выполненная цель",
	["Sets the color for completed objectives"] = "Установка цвета текста надписи выполненной цели.",
	["Custom Header Color"] = "Изменить цвет задания",
	["Use custom color for headers"] = "Выберите, чтобы самостоятельно установить цвет текста для названий заданий в списке.",
	["Completed Header Color"] = "Выполненное задание",
	["Sets the color for completed headers"] = "Установка цвета текста названий выполненных заданий.",
	["Failed Header Color"] = "Проваленное задание",
	["Sets the color for failed quests"] = "Установка цвета текста названий проваленных заданий.",
	["Header Color"] = "Цвет Заголовка",
	["Sets the color for headers"] = "Установка цвета текста заголовков.",
	["Disable Tracker"] = "Отключить список",
	["Disable the Tracker"] = "Выберите, чтобы убрать список с экрана.",
	["Quest Tracker Alpha"] = "Прозрачность списка",
	["Sets the Alpha of the Quest Tracker"] = "Устанавливает прозрачность списка заданий.",
	["Auto Resize Tracker"] = "Автоизменение размера списка",
	["Automatical resizes the tracker depending on the lenght of the text in it"] = "Автоматически изменяет размер списка в зависимости от длины текста",
	["Fixed Tracker Width"] = "Зафиксировать ширину списка",
	["Sets the fixed width of the tracker if auto resize is disabled"] = "Устанавливает фиксированную ширину, если выключено автоизменение размера.",

	["Pick Locale"] = "Язык интерфейса",
	["Change Locale (needs Interface Reload)"] = "Изменить язык интерфейса адд-она (требует перезагрузку интерфейса игры).",

	["|cffffffffQuests|r"] = "|cffffffffВсего заданий|r",
	["|cffff8000Tracked Quests|r"] = "|cffff8000Отслеживаемые задания|r",
	["|cff00d000Completed Quests|r"] = "|cff00d000Выполненные задания|r",
	["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"] = "|cffeda55fНажмите|r для открытия журнала заданий, или |cffeda55fНажмите с Shift'ом|r для открытия графического интерфейса настроек Waterfall",






	["Tooltip"] = "Окно подсказки",
	["Tooltip Options"] = "Настройки окна подсказки",
	["Tracker Tooltip"] = "Окно подсказки для списка заданий",
	["Showing mouseover tooltips in tracker"] = "Выберите, чтобы при наведении курсора на список заданий показывалось окно подсказки.",
	["Quest Description in Tracker Tooltip"] = "Описание задания в окне подсказки",
	["Displays the actual quest's description in the tracker tooltip"] = "Выберите, чтобы в окне подсказки списка отображались описания заданий.",
	["Party Quest Progression info"] = "Инфо о прогрессе группы по заданию",
	["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"] = "Выберите, чтобы в окне подсказки отображалась информация о прогрессе группы по заданию. Для предоставления информации в клиенте согруппника должен быть установлен адд-он Quixote.",
	["Enable Left Click"] = "Доп. функция левого щелчка",
	["Left clicking a quest in the tracker opens the Quest Log"] = "Выберите, чтобы открывать журнал левым щелчком мыши по списку.",
	["Enable Right Click"] = "Доп. функция правого щелчка",
	["Right clicking a quest in the tracker removes it from the tracker"] = "Выберите, чтобы правым щелчком мыши удалять задание из списка.",
	["Quest Log Scale"] = "Масштаб журнала заданий",
	["Sets the Scale of the Quest Log"] = "Устанавливает масштаб журнала заданий.",
	["Force Tracker Unlock"] = "Принудительно сделать список перемещаемым",
	["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"] = "Делает список заданий перемещаемым даже при загруженом CTMod. Проверьте наличие и настройки CTMod прежде чем использовать эту опцию.",
	["Quest Progression to Party Chat"] = "Процесс выполнения в групповой чат",
	["Prints the Quest Progression Status to the Party Chat"] = "Выводит процесс выполнения задания в групповой чат.",
	["Completion Sound"] = "Звук Выполнения",
	["Select the sound to be played when a quest is completed"] = "Выбор звука, который воспроизводится по выполнению задания.",

	["Quest Description Color"] = "Цвет описания задания",
	["Sets the color for the Quest description"] = "Устанавливает цвет текста описания задания.",
	["Party Member Color"] = "Цвет членов группы",
	["Party Member with Quixote Color"] = "Цвет членов группы с Quixote",
	["Sets the color for Party member"] = "Устанавливает цвет для членов группы.",

--[[ new with 3.0
	["Main Options"] = true, -- translate me!!!
	["Enable Addon"] = true, -- translate me!!!
	["Enable this Addon"] = true, -- translate me!!!
	["General Quest Log Options"] = true, -- translate me!!!
	["No sound"] = true, -- translate me!!!
	["Don't play a sound"] = true, -- translate me!!!
	["Watch Options"] = true, -- translate me!!!
	["Zones"] = true, -- translate me!!!
	["NPC color"] = true, -- translate me!!!
	["Title color"] = true, -- translate me!!!

-- Fubar
	["Show icon"] = true, -- translate me!!!
	["Show the plugins icon on the panel."] = true, -- translate me!!!
	["Show text"] = true, -- translate me!!!
	["Show the plugins text on the panel."] = true, -- translate me!!!
	["Show colored text"] = true, -- translate me!!!
	["Allow the plugin to color its text."] = true, -- translate me!!!
	["Detach tooltip"] = true, -- translate me!!!
	["Detach the tooltip from the panel."] = true, -- translate me!!!
	["Lock tooltip"] = true, -- translate me!!!
	["Lock the tooltips position. When the tooltip is locked, you must use Alt to access it with your mouse."] = true, -- translate me!!!
	["Position"] = true, -- translate me!!!
	["Position the plugin on the panel."] = true, -- translate me!!!
	["Left"] = true, -- translate me!!!
	["Right"] = true, -- translate me!!!
	["Center"] = true, -- translate me!!!
	["Attach to minimap"] = true, -- translate me!!!
	["Attach the plugin to the minimap instead of the panel."] = true, -- translate me!!!
	["Hide plugin"] = true, -- translate me!!!
	["Hidden"] = true, -- translate me!!!
	["Hide the plugin from the panel or minimap, leaving the addon running."] = true, -- translate me!!!
	["Other"] = true, -- translate me!!!
	["Close"] = true, -- translate me!!!
	["Close the menu."] = true, -- translate me!!!
	["Minimap position"] = true, -- translate me!!!

-- Profiles
	["Profiles"] = true, -- translate me!!!
 
-- Achievement Tracker
	["Achievement Tracker"] = true, -- translate me!!!
	["Enable Achievement Tracker"] = true, -- translate me!!!
	["Enables the Achievement Tracker, which can be moved an collapsed."] = true, -- translate me!!!
	["Makes the achievement tracker unmovable"] = true, -- translate me!!!
	["Show Achievement Tracker Header"] = true, -- translate me!!!
	["Shows the header of the Achievementtracker"] = true, -- translate me!!!
	["Save tracked Achievement"] = true, -- translate me!!!
	["Save last tracked Achievement and resore it after login"] = true, -- translate me!!!
	["Remove Completed Achievement"] = true, -- translate me!!!
	["Automatical remove the completed Achievement from tracker"] = true, -- translate me!!!
	["Achievement Tracker Alpha"] = true, -- translate me!!!
	["Sets the Alpha of the Achievement Tracker"] = true, -- translate me!!!
	["Achievement Tracker Scale"] = true, -- translate me!!!
	["Sets the Scale of the Achievement Tracker"] = true, -- translate me!!!
--]]
-- Profiles
	["ace2profile_default"] = "По умолчанию",
	["ace2profile_intro"] = "Вы можете сменить активный профиль БД, этим вы можете устанавливать различные настройки для каждого персонажа.",
	["ace2profile_reset_desc"] = "Сброс текущего профиля на его стандартные значения, в том случаи если ваша конфигурация испорчена, или вы желаете всё перенастроить заново.",
	["ace2profile_reset"] = "Сброс профиля",
	["ace2profile_reset"] = "Сброс текущего профиля на стандартный",
	["ace2profile_choose_desc"] = "Вы можете создать новый профиль введя название в поле ввода, или выбрать один из уже существующих профилей.",
	["ace2profile_new"] = "Новый",
	["ace2profile_new_sub"] = "Создать новый чистый профиль.",
	["ace2profile_choose"] = "Профиля",
	["ace2profile_choose_sub"] = "Выберите один из уже доступных профилей.",
	["ace2profile_copy_desc"] = "Скопировать настройки профиля в на данный момент активный профиль.",
	["ace2profile_copy"] = "Скопировать с",
	["ace2profile_delete_desc"] = "Удалить существующий и неиспользуемый профиль из БД для сохранения места, и очистить SavedVariables файл.",
	["ace2profile_delete"] = "Удалить профиль",
	["ace2profile_delete_sub"] = "Удаления профиля из БД.",
	["ace2profile_delete_confirm"] = "Вы уверены что вы хотите удалить выбранный профиль?",
	["ace2profile_profiles"] = "Профиля",
	["ace2profile_profiles_sub"] = "Управление профилями",


} end )
if GetLocale() == "ruRU" then
BINDING_HEADER_beqlTITLE = "bEQL"
BINDING_NAME_TrackerToggle = "Вкл-Выкл трекера"


BEQL_COMPLETE = "%(Выполнено%)"

BEQL_QUEST_ACCEPTED = "Задание принято:"

end