-- Russian localization file for ruRU by StingerSoft.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Omen", "ruRU")
if not L then return end

-- Main Omen window
L["<Unknown>"] = "<Неизвестно>"
L["Omen Quick Menu"] = "Быстрое меню Омена"
L["Use Focus Target"] = "Использовать цель фокуса"
L["Test Mode"] = "Режим теста"
L["Open Config"] = "Открыть настройки"
L["Open Omen's configuration panel"] = "Открывает окно настроек Омена"
L["Hide Omen"] = "Скрыть Омен"
L["Name"] = "Имя"
L["Threat [%]"] = "Угроза [%]"
L["Threat"] = "Угроза"
L["TPS"] = "УГзС"
L["Toggle Focus"] = "Перекл. фоукса"
L["> Pull Aggro <"] = "> Аггро пула <"

-- Warnings
L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."] = "|cffff0000Ошибка:|r Омен не может использовать предупреждения \"встряской\" если вы включили таблицы имён  после входа."
L["Passed %s%% of %s's threat!"] = "Достигнуто %s%% угрозы %s(а)!"

-- Config module titles
L["General Settings"] = "Основные настройки"
L["Profiles"] = "Профиля"
L["Slash Command"] = "Команды"

-- Config strings, general settings section
L["OMEN_DESC"] = "Омен - это облегченный измеритель угрозы который показывает вам угрозу монстров с которыми вы вступили в бой. Вы можете изменить его вид, настроить работать, и сконфигурировать разлицные профиля для каждого вашего персонажа."
L["Alpha"] = "Прозрачность"
L["Controls the transparency of the main Omen window."] = "Настройка прозрачности главного окна Омена"
L["Scale"] = "Масштаб"
L["Controls the scaling of the main Omen window."] = "Настройка масштаба главного окна Омена"
L["Frame Strata"] = true
L["Controls the frame strata of the main Omen window. Default: MEDIUM"] = true
L["Clamp To Screen"] = true
L["Controls whether the main Omen window can be dragged offscreen"] = true
L["Tells Omen to additionally check your 'focus' and 'focustarget' before your 'target' and 'targettarget' in that order for threat display."] = "Омен выполняет дополнительную проверку вашего 'focus' и 'focustarget' на наличие угрозы для отображение её."
L["Tells Omen to enter Test Mode so that you can configure Omen's display much more easily."] = "Омен входит в режим тестирования, что позволит вам его настроить для более лучшего отображения данных."
L["Collapse to show a minimum number of bars"] = "Collapse to show a minimum number of bars"
L["Lock Omen"] = "Зафиксировать Омен"
L["Locks Omen in place and prevents it from being dragged or resized."] = "Фиксирует Омен на месте и не позволяет менять размер или перетаскивать его."
L["Show minimap button"] = "Кнопка у мини-карты"
L["Show the Omen minimap button"] = "Поместить кнопку Омена у мини-карты"
L["Ignore Player Pets"] = true
L["IGNORE_PLAYER_PETS_DESC"] = [[
Tells Omen to skip enemy player pets when determining which unit to display threat data on.

Player pets maintain a threat table when in |cffffff78Aggressive|r or |cffffff78Defensive|r mode and behave just like normal mobs, attacking the target with the highest threat. If the pet is instructed to attack a specific target, the pet still maintains the threat table, but sticks on the assigned target which by definition has 100% threat. Player pets can be taunted to force them to attack you.

However, player pets on |cffffff78Passive|r mode do not have a threat table, and taunt does not work on them. They only attack their assigned target when instructed and do so without any threat table.

When a player pet is instructed to |cffffff78Follow|r, the pet's threat table is wiped immediately and stops attacking, although it may immediately reacquire a target based on its Aggressive/Defensive mode.
]]
L["Autocollapse"] = "Авто-сворачивание"
L["Autocollapse Options"] = "Настройки авто-сворачивания"
L["Grow bars upwards"] = "Возрастание полос вверх"
L["Hide Omen on 0 bars"] = "Скрыть Омен при 0 полосах"
L["Hide Omen entirely if it collapses to show 0 bars"] = "Полностью скрыть Омен если он отображает 0 полос"
L["Max bars to show"] = "Макс полос"
L["Max number of bars to show"] = "Максимальное число показываемых полос"
L["Background Options"] = "Опции заднего плана"
L["Background Texture"] = "Текстура фона"
L["Texture to use for the frame's background"] = "Текстура фона фреймов"
L["Border Texture"] = "Текстура края"
L["Texture to use for the frame's border"] = "Текстура полей фреймов"
L["Background Color"] = "Цвет фона"
L["Frame's background color"] = "Цвет фона фреймов"
L["Border Color"] = "Цвет края"
L["Frame's border color"] = "Цвет края фреймов"
L["Tile Background"] = "Фон мазайки"
L["Tile the background texture"] = "Текстура фона мазайки"
L["Background Tile Size"] = "Размер фона мазайки"
L["The size used to tile the background texture"] = "Размер используемый для текстуры фона мазайки"
L["Border Thickness"] = "Толщина края"
L["The thickness of the border"] = "Толщина края"
L["Bar Inset"] = "Врезка полосы"
L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"] = "Устанавливает как клубоко во фрейме будут отображатся полосы угрозы"

-- Config strings, title bar section
L["Title Bar Settings"] = "Настройка заглавий"
L["Configure title bar settings."] = "Настройка заглавий полос."
L["Show Title Bar"] = "Полоса заглавий"
L["Show the Omen Title Bar"] = "Отобпажать полосу заглавие омена"
L["Title Bar Height"] = "Высота заглавий"
L["Height of the title bar. The minimum height allowed is twice the background border thickness."] = "Высота заглавий полос. Минимальная высота позволяет в два раза превысить толщину фона границ."
L["Title Text Options"] = "Опции текста заглавий"
L["The font that the title text will use"] = "Шрифт используемый в заглавиях"
L["The outline that the title text will use"] = "Контур текста заглавий"
L["The color of the title text"] = "Цвет текста заглавий"
L["Control the font size of the title text"] = "Настройка размера шрифта текста заглавий"

-- Config strings, show when... section
L["Show When..."] = "Показывать когда.."
L["Show Omen when..."] = "Показывать Омен когда.."
L["This section controls when Omen is automatically shown or hidden."] = true
L["Use Auto Show/Hide"] = true
L["Show Omen when any of the following are true"] = "Показывать Омен когда выбранные действия верны"
L["You have a pet"] = "С питомцем"
L["Show Omen when you have a pet out"] = "Показывать Омен когда у вас призван питомец"
L["You are alone"] = "Вы один"
L["Show Omen when you are alone"] = "Показывать Омен когда вы один"
L["You are in a party"] = "В группе"
L["Show Omen when you are in a 5-man party"] = "Показывать Омен когда вы находитесь в группе"
L["You are in a raid"] = "В рейде"
L["Show Omen when you are in a raid"] = "Показывать Омен когда вы находитесь в рейде"
L["However, hide Omen if any of the following are true (higher priority than the above)."] = true
L["You are resting"] = "При отдыхе"
L["Turning this on will cause Omen to hide whenever you are in a city or inn."] = true
L["You are in a battleground"] = "На поле сражения"
L["Turning this on will cause Omen to hide whenever you are in a battleground or arena."] = true
L["You are not in combat"] = true
L["Turning this on will cause Omen to hide whenever you are not in combat."] = "Скрывает Омен всегда когда вы находитесь в состоянии в не боя."
L["AUTO_SHOW/HIDE_NOTE"] = "Note: If you manually toggle Omen to show or hide, it will remain shown or hidden regardless of Auto Show/Hide settings until you next zone, join or leave a party or raid, or change any Auto Show/Hide settings."

-- Config strings, show classes... section
L["Show Classes..."] = "Показывать классы.."
L["SHOW_CLASSES_DESC"] = "Показывать полосы угрозы Омена для определённых классов. Относится только к группе/рейду. Исключением является опция 'Не в группе'."
L["Show bars for these classes"] = "Показ полос для след. классов"
L["DEATHKNIGHT"] = "Рыцарь смерти"
L["DRUID"] = "Друид"
L["HUNTER"] = "Охотник"
L["MAGE"] = "Маг"
L["PALADIN"] = "Паладин"
L["PET"] = "Питомец"
L["PRIEST"] = "Жрец"
L["ROGUE"] = "Разбойник"
L["SHAMAN"] = "Шаман"
L["WARLOCK"] = "Чернокнижник"
L["WARRIOR"] = "Воин"
L["*Not in Party*"] = "*Не в группе*"

-- Config strings, bar settings section
L["Bar Settings"] = "Настройка полос"
L["Configure bar settings."] = "Настройка полос"
L["Animate Bars"] = "Анимация полос"
L["Smoothly animate bar changes"] = "Плавная анимация изменений полос"
L["Short Numbers"] = "Сокрощать №"
L["Display large numbers in Ks"] = "Отображать большие числа с сокращение К"
L["Bar Texture"] = "Текстура полосы"
L["The texture that the bar will use"] = "Текстуры используемые для полос"
L["Bar Height"] = "Высота полос"
L["Height of each bar"] = "Высота всех полос"
L["Bar Spacing"] = "Промежуток полос"
L["Spacing between each bar"] = "Промежуток между каждой полоской"
L["Show TPS"] = "Показ УГзС"
L["Show threat per second values"] = "Показывать значение вырабатываемой угрозы за секунду"
L["TPS Window"] = "Окно УГзС"
L["TPS_WINDOW_DESC"] = "Угроза в секунду базируется на вычислении в реальном времени скольжении окна из последних Х секунд."
L["Show Threat Values"] = "Показ значения угрозы"
L["Show Threat %"] = "Показ угрозу в %"
L["Show Headings"] = "Показ заголовков"
L["Show column headings"] = "Показывать колонк заголовков"
L["Heading BG Color"] = "Цвет фона заголовка"
L["Heading background color"] = "Цвет фона заголовка"
L["Use 'My Bar' color"] = "Окраска 'Моей полосы'"
L["Use a different colored background for your threat bar in Omen"] = "Использовать другую окраску фона для вашей полосы угрозы в Омене"
L["'My Bar' BG Color"] = "Цвет 'Моей полосы'"
L["The background color for your threat bar"] = "Цвет фона вашей полосы угрозы"
L["Use Tank Bar color"] = "Окраска танка"
L["Use a different colored background for the tank's threat bar in Omen"] = "Использовать другую окраску фона полосы угрозы танков в Омене"
L["Tank Bar Color"] = "Цвет полосы танка"
L["The background color for your tank's threat bar"] = "Цвет фона полосы угрозы вашего танка"
L["Show Pull Aggro Bar"] = "Полоса аггро пула"
L["Show a bar for the amount of threat you will need to reach in order to pull aggro."] = "Показывает полосу со значением угрозы, достигнув которой вы сорвёте аггро"
L["Pull Aggro Bar Color"] = "Цвет полосы пула"
L["The background color for your Pull Aggro bar"] = "Цвет фона вашей полосы пула"
L["Use Class Colors"] = "Цвет класса"
L["Use standard class colors for the background color of threat bars"] = "Использовать стандартный цвет уласса в качестве цвета фона полосы угрозы"
L["Pet Bar Color"] = true
L["The background color for pets"] = true
L["Bar BG Color"] = "Цвет фона полос"
L["The background color for all threat bars"] = "Цвет фона для всех полос угрозы"
L["Always Show Self"] = "Всегда показ себя"
L["Always show your threat bar on Omen (ignores class filter settings), showing your bar on the last row if necessary"] = "Всегда отображать вашу полосу угрозы в Омене (игнарируя настройки фильтрации по классу)"
L["Bar Label Options"] = "Настройка надписей полос"
L["Font"] = "Шрифт"
L["The font that the labels will use"] = "Шрифт используемый надписями"
L["Font Size"] = "Размер шрифта"
L["Control the font size of the labels"] = "Настройка размера шрифта надписей"
L["Font Color"] = "Цвет шрифта"
L["The color of the labels"] = "Цвет надписей"
L["Font Outline"] = "Контур шрифта"
L["The outline that the labels will use"] = "Контур шрифта надписей"
L["None"] = "Отсутствует"
L["Outline"] = "Контур"
L["Thick Outline"] = "Толстый контур"

-- Config strings, slash command section
L["OMEN_SLASH_DESC"] = "These buttons execute the same functions as the ones in the slash command /omen"
L["Toggle Omen"] = "Открыть/Закрыть Омен"
L["Center Omen"] = "По Центру"
L["Configure"] = "Настройка"
L["Open the configuration dialog"] = "Открывает окно настройки"

-- Config strings, warning settings section
L["Warning Settings"] = "Настройки предупреждений"
L["OMEN_WARNINGS_DESC"] = "Данный раздел поможет вам настроить вывод сообщений об аггресии/угрозы."
L["Enable Sound"] = "Включить звуки"
L["Causes Omen to play a chosen sound effect"] = "Омен будет проигрывать выбранный вами звуковой эффект"
L["Enable Screen Flash"] = "Включить мигание экрана"
L["Causes the entire screen to flash red momentarily"] = "Весь экран будет мигать красным цветом"
L["Enable Screen Shake"] = "Включить встряску экрана"
L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."] = "Весь экран будет трястись. Данная настройка будет работать только если выключены таблицы имен"
L["Enable Warning Message"] = "Включить предупреждения"
L["Print a message to screen when you accumulate too much threat"] = "Выводить сообщение на экран когда скапливается за много угрозы"
L["Warning Threshold %"] = "Порог предупреждения %"
L["Sound to play"] = "Проигрываемый звук"
L["Disable while tanking"] = "Отключит при танковании"
L["DISABLE_WHILE_TANKING_DESC"] = "Не выводить предупреждения если активна Оборонительная стойка, Облик медведя, Праведное неистовство или Лик льда."
L["Test warnings"] = "Тестирование предупреждений"

-- Config strings, for Fubar 
L["Click|r to toggle the Omen window"] = "Кликни|r чтоб открыть-закрыть окно Омена"
L["Right-click|r to open the options menu"] = "Правый-Клик|r открывает меню настроек"
L["FuBar Options"] = "Опции FuBarа"
L["Attach to minimap"] = "Закрепить у мини-карты"
L["Hide minimap/FuBar icon"] = "Скрыть иконку у мини-карты/FuBarа"
L["Show icon"] = "Отображать иконку"
L["Show text"] = "Отображать текст"
L["Position"] = "Позиция"
L["Left"] = "Слева"
L["Center"] = "По центру"
L["Right"] = "Справа"

-- FAQ
L["Help File"] = "Файл справки"
L["A collection of help pages"] = "Коллекция страниц помощи"
L["FAQ Part 1"] = true
L["FAQ Part 2"] = true
L["Frequently Asked Questions"] = "Часто задаваемые вопросы"
L["Warrior"] = "Воин"

L["GENERAL_FAQ"] = [[
|cffffd200Чем отлисается Omen3 от Omen2?|r

Omen3 расчеты берет с Близардского API угрозы и событий угрозы. Он не вычисляет или экстраполирует угрозу в отличие от Omen2.

Omen2 used what we called the Threat-2.0 library. This library was responsible for monitoring the combat log, spellcasting, buffs, debuffs, stances, talents and gear modifiers for calculating each individuals threat. Threat was calculated based on what was known or approximated from observed behaviors. Many abilities such as knockbacks were just assumed (to be a 50% threat reduction) as they were mostly impossible to confirm.

The Threat-2.0 library also included addon communication to broadcast your threat to the rest of the raid as long as they were also using Threat-2.0. This data was then used to provide a raid wide display of threat information.

Since patch 3.0.2, Omen no longer does any of these things and the need for a threat library is no longer necessary. Omen3 uses Blizzard's new in-built threat monitor to obtain exact values of every members threat. This means Omen3 has no need for synchronisation of data, combat log parsing or guessing, resulting in a significant increase in performance with regards to network traffic, CPU time and memory used. The implementation of boss modules for specific threat events (such as Nightbane wiping threat on landing) are also no longer necessary.

Further benefits of this new implementation include the addition of NPC threat on a mob (eg, Human Kalecgos). However, there are some drawbacks; frequency of updates are much slower, threat details cannot be obtained unless somebody in your party/raid are targetting the mob and it is also not possible to obtain threat from a mob you are not in direct combat with.

|cffffd200How do I get rid of the 2 vertical gray lines down the middle?|r

Lock your Omen. Locking Omen will prevent it from being moved or resized, as well as prevent the columns from being resized. If you haven't realized it, the 2 vertical gray lines are column resizing handles.

|cffffd200How do I make Omen3 look like Omen2?|r

Change the both the Background Texture and Border Texture to Blizzard Tooltip, change the Background Color to black (by dragging the luminance bar to the bottom), and the Border Color to blue.

|cffffd200Why does no threat data show on a mob when I target it even though it is in combat?|r

The Blizzard threat API does not return threat data on any mob you are not in direct combat with. We suspect this is an effort on Blizzard's part to save network traffic.

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

|cffffd200Does Omen3 sync or parse the combat log?|r

No. Omen3 does not attempt to sync or parse the combat log. Currently there are no intentions to do so.

|cffffd200The threat updates are slow...|r

Omen3 updates the threat values you see as often as Blizzard updates the threat values to us.

In fact, Blizzard updates them about once per second, which is much faster than what Omen2 used to sync updates. In Omen2, you only transmitted your threat to the rest of the raid once every 3 seconds (or 1.5s if you were a tank).

|cffffd200Where can I report bugs or give suggestions?|r

http://forums.wowace.com/showthread.php?t=14249

|cffffd200Кто написал Омен3?|r

Это сделал Xinhuan (Blackrock US Alliance).

|cffffd200Do you accept Paypal donations?|r

Yes, send to xinhuan AT gmail DOT com.

|cffffd200Кто перевел Омен3 на русский?|r

Это сделал StingerSoft (Азурегос/Эритнулл).
]]
L["WARRIOR_FAQ"] = [[Следующие данные взяты с |cffffd200http://www.tankspot.com/forums/f200/39775-wow-3-0-threat-values.html|r  2ого Окт 2008 (автор Satrina). Числа для 80 уровня.

|cffffd200Модификатор|r
Боевая стойка ____________ x 80
Стойка берсерка ___________x 80
Тактическое превосходство _x 121/142/163
Оборонительная стойка _____x 207.35

Note that in our original threat estimations (that we use now in WoW 2.0), we equated 1 damage to 1 threat, and used 1.495 to represent the stance+defiance multiplier. We see that Blizzard's method is to use the multiplier without decimals, so in 2.x it would've been x149 (maybe x149.5); it is x207 (maybe 207.3) in 3.0. I expect that this is to allow the transport of integer values instead of decimal values across the Internet for efficiency. It appears that threat values are multiplied by 207.35 at the server, then rounded.

Если Вы все используете 1 единицу урона = 1 единице угрозы, модификатор стоек - 0.8 и 2.0735, и т.д.

|cffffd200Значения угрозы  (stance modifiers apply unless otherwise noted):|r
Боевой крик __________ 78 (split)
Рассекающий удар _____ урон + 225 (split)
Командирский крик ____ 80 (split)
Оглушающий удар ______ только урон
Ранящий щит __________ только урон
Деморализующий крик __ 63 (split)
Разрушение ___________ урон + 5% от СА *** Нужно перепроверить для 8982 **
Уклон/Парир/Блок______ 1 (только в оборонительной стойке с улучшенной оборонительной стойкой)
Удар героя ___________ урон + 259
Бросок оружия _________1.50 x урона
Получение Ярости______ 5 (stance modifier is not applied)
Кровопускание_________ только урон
Реванш  ______________ урон + 121
Удар щитом ___________ 36
Сокрушение щитом ______урон + 770
Ударная волна _________только урон
Сокрушение ____________урон + 140
Отражение заклинания __только урон (only for spells aimed at you)
Общественное аггро ___ 0
Раскол брони _________ 345 + 5%СА
Удар грома ___________ 1.85 x урона
Бдительность __________10% от вырабатываемой угрозы цели (stance modifier is not applied)

You do not gain threat for reflecting spells targetted at allies with Improved Spell Reflect. When you reflect a spell for an ally, your ally gains the threat for the damage dealt by the reflected spell.
]]

