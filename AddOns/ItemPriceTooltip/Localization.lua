local L = {}

-- Default localization
L["Custom text"] = true
L["Don't show anything for items that are not known"] = true
L["Don't show anything for items that cannot be sold to a vendor"] = true
L["General"] = true
L["Ignore unknown items"] = true
L["Ignore unsellable items"] = true
L["Modifier key only"] = true
L["modifier.any"] = "Any"
L["Only show price when a modifier key is held down"] = true
L["Prices in library: %d"] = true
L["Purge prices!"] = true
L["Purge recorded vendor prices"] = true
L["Record vendor prices"] = true
L["Recorded vendor prices: %d"] = true
L["Sells for"] = true
L["Show price for bag slots"] = true
L["Show statistics for stored prices"] = true
L["Show statistics"] = true
L["Specify a custom text to display instead of 'Sells for'."] = true
L["Text color"] = true
L["Unknown sell price"] = true
L["Display style"] = true
L["Select the display style"] = true
L["Coins"] = true
L["Text only"] = true
L["Price data"] = true
L["coin.gold"] = "g"
L["coin.silver"] = "s"
L["coin.copper"] = "c"
L["Charge"] = true  -- Must match the tooltip text for items with 1 charge!
L["Charges"] = true  -- Must match the tooltip text for items with 2 or more charges!


local GameLocale = GetLocale()

-- Translators, there are some unused translations from older versions. Feel free to remove them if you discover any.
-- I do plan to make a script to quickly weed them out at some point.

if GameLocale == "deDE" then
  L["Custom text"] = "Benutzerdefinierter Text"
  L["Don't show anything for items that are not known"] = "Zeigt nichts an wenn der Gegenstand unbekannt ist."
  L["Don't show anything for items that cannot be sold to a vendor"] = "Zeigt nichts an wenn der Gegenstand nicht verkauft werden kann."
  L["General"] = "Allgemein"
  L["Ignore unknown items"] = "Ignoriere unbekannte Gegenstände"
  L["Ignore unsellable items"] = "Ignoriere unverkäufliche Gegenstände"
  L["Modifier key only"] = "Modifikator-Taste"
  L["modifier.any"] = "Eine der Drei"
  L["Only show price when a modifier key is held down"] = "Preise nur anzeigen, wenn eine Modifikator-Taste gedrückt wird."
  L["Prices in library: %d"] = "Preise in der Datenbank: %d"
  L["Purge prices!"] = "Preise löschen!"
  L["Purge recorded vendor prices"] = "Alle aufgezeichneten Händlerpreise löschen."
  L["Record vendor prices"] = "Händlerpreise aufzeichnen"
  L["Recorded vendor prices: %d"] = "Aufgezeichnete Händlerpreise: %d"
  L["Sells for"] = "Verkauf für"
  L["Show price for bag slots"] = "Zeigt den Preis für Taschenplätze an."
  L["Show statistics for stored prices"] = "Statistiken für gespeicherte Preise anzeigen."
  L["Show statistics"] = "Statistiken anzeigen"
  L["Specify a custom text to display instead of 'Sells for'."] = "Gebe hier einen eigenen Text an, der anstelle von 'Verkauf für' angezeigt wird."
  L["Text color"] = "Textfarbe"
  L["Unknown sell price"] = "Unbekannter Verkaufspreis"
  L["Display style"] = "Anzeigeart"
  L["Select the display style"] = "Legt die Art der Anzeige fest."
  L["Coins"] = "Münzsymbole"
  L["Text only"] = "Text"
  L["Price data"] = "Preisdaten"
  L["coin.gold"] = "g"
  L["coin.silver"] = "s"
  L["coin.copper"] = "k"
  L["Charge"] = "Aufladung"
  L["Charges"] = "Aufladungen"
  
elseif GameLocale == "frFR" then
  L["Custom text"] = "Texte personnalis\195\169"
  L["Don't show anything for items that are not known"] = "Ne rien afficher pour les objets non r\195\169f\195\169renc\195\169s"
  L["Don't show anything for items that cannot be sold to a vendor"] = "Ne rien afficher pour les objets invendables"
  L["General"] = "G\195\169n\195\169ral"
  L["Ignore unknown items"] = "Ignorer les objets inconnus"
  L["Ignore unsellable items"] = "Ignorer les objets invendables"
  L["Modifier key only"] = "Seulement avec la touche"
  L["modifier.any"] = "Tous"
  L["Only show price when a modifier key is held down"] = "Afficher uniquement si la touche s\195\169lectionn\195\169e est activ\195\169e"
  L["Prices in library: %d"] = "Prix enregistr\195\169s: %d"
  L["Purge prices!"] = "Purger les prix"
  L["Purge recorded vendor prices"] =  "Purger les prix enregistr\195\169s"
  L["Record vendor prices"] = "Enregistrer les prix des marchands"
  L["Recorded vendor prices: %d"] = "Prix des marchands enregistr\195\169s: %d"
  L["Sells for"] = "Vendu pour"
  L["Show price for bag slots"] = "Affiche le prix des sacs"
  L["Show statistics for stored prices"] = "Montrer les statistiques ppour les prix enregistr\195\169s"
  L["Show statistics"] = "Montrer les statistiques"
  L["Specify a custom text to display instead of 'Sells for'."] = "Indiquer un texte personnalis\195\169 (au lieu de 'Vendu pour')."
  L["Text color"] = "Couleur du texte"
  L["Unknown sell price"] = "Prix inconnu"
  L["Display style"] = "Style d'affichage"
  L["Select the display style"] = "Choisir le style d'affichage du prix"
  L["Coins"] = "Pi\195\168ces"
  L["Text only"] = "Texte"
  L["Price data"] = "Donn\195\169es"
  L["coin.gold"] = "o"
  L["coin.silver"] = "a"
  L["coin.copper"] = "c"
  
elseif GameLocale == "esES" then
  L["Custom text"] = "Texto personalizado"
  L["Don't show anything for items that are not known"] = "No mostrar nada para objetos que no son conocidos"
  L["Don't show anything for items that cannot be sold to a vendor"] = "No mostrar nada para objetos que no pueden ser vendidos en una tienda"
  L["General"] = "General"
  L["Ignore unknown items"] = "Ignorar objetos desconocidos"
  L["Ignore unsellable items"] = "Ignorar objetos que no se pueden vender"
  L["Modifier key only"] = "Solo clave del modificador"
  L["modifier.any"] = "Cualquiera"
  L["Only show price when a modifier key is held down"] = "Solo mostrar el precio cuando una clave de un modificador esta presionada"
  L["Prices in library: %d"] = "Precios en la libreria: %d"
  L["Purge prices!"] = "¡Borrar precios!"
  L["Purge recorded vendor prices"] = "¡Borrar los precios grabados de las tiendas!"
  L["Record vendor prices"] = "Guardar precios de las tiendas"
  L["Recorded vendor prices: %d"] = "Precios de las tiendas guardados: %d"
  L["Sells for"] = "Se vende por"
  L["Show price for bag slots"] = "Mostrar precio para los huecos de bolsas"
  L["Show statistics for stored prices"] = "Mostrar estadisticas de los precios almacenados"
  L["Show statistics"] = "Mostrar estadisticas"
  L["Specify a custom text to display instead of 'Sells for'."] = "Especificar texto personalizado para mostrar en lugar de 'Se vende por'"
  L["Text color"] = "Color del texto"
  L["Unknown sell price"] = "Precio de venta desconocido"
  L["Display style"] = "Estilo a mostrar"
  L["Select the display style"] = "Seleccione el estilo a mostrar"
  L["Coins"] = "Monedas"
  L["Text only"] = "Solo texto"
  
elseif GameLocale == "koKR" then
  L["Custom text"] = "사용자 정의 글자"
  L["Don't show anything for items that are not known"] = "가격을 알 수 없는 아이템의 튤탑울 표시하지 않습니다."
  L["Don't show anything for items that cannot be sold to a vendor"] = "팔 수 없는 아이템의 툴팁을 표시하지 않습니다."
  L["General"] = "일반"
  L["Ignore unknown items"] = "가격 모르는 아이템 무시"
  L["Ignore unsellable items"] = "팔 수 없는 아이템 무시"
  L["Modifier key only"] = "기능키 사용"
  L["modifier.any"] = "모두"
  L["Only show price when a modifier key is held down"] = "기능키를 사용했을 경우에만 판매가격을 표시합니다."
  L["Prices in library: %d"] = "라이브러리 판매 가격 : %d"
  L["Purge prices!"] = "데이터 삭제"
  L["Purge recorded vendor prices"] = "상점 판매가격 데이터를 삭제합니다."
  L["Record vendor prices"] = "상점 판매가격 기록"
  L["Recorded vendor prices: %d"] = "저장된 판매 가격 : %d"
  L["Sells for"] = "판매 가격"
  L["Show price for bag slots"] = "가방 공간에도 판매가격을 표시합니다."
  L["Show statistics for stored prices"] = "저장된 금액의 통계 보기"
  L["Show statistics"] = "통계 보기"
  L["Specify a custom text to display instead of 'Sells for'."] = "'판매 가격' 대신에 원하는 문구를 넣을 수 있습니다."
  L["Text color"] = "글자 색상"
  L["Unknown sell price"] = "알 수 없음"
  L["Display style"] = "표시 형식"
  L["Select the display style"] = "표시형식을 선택합니다."
  L["Coins"] = "코인"
  L["Text only"] = "글자"
  L["Price data"] = "가격 데이터"
  L["coin.gold"] = "골드"
  L["coin.silver"] = "실버"
  L["coin.copper"] = "코퍼"
  L["Charge"] = "가격"
  L["Charges"] = "가격"

elseif GameLocale == "zhCN" then
  --L["Bag slots"] = "背包栏"
  --L["Choose a modifier key"] = "选择一个控制键"
  L["Custom text"] = "自定义文字"
  --L["Display style"] = "显示方式"
  L["Modifier key only"] = "设置控制键"
 -- L["Modifier key"] = "控制键"
  L["Only show price when a modifier key is held down"] = "仅控制键按下后显示售价"
  L["Prices in library: %d"] = "内置的售价记录：%d"
  L["Purge prices!"] = "清除价格！"
  L["Purge recorded vendor prices"] = "清除记录的商人处售价"
  L["Record vendor prices"] = "记录出售价格"
  L["Recorded vendor prices: %d"] = "商人处售价记录：%d"
  L["Sells for"] = "售价"
  L["Show price for bag slots"] = "显示背包栏背包价格"
  L["Show statistics for stored prices"] = "显示所有已储存售价的数量"
  L["Show statistics"] = "显示售价储存数"
  L["Text color"] = "文字颜色"
 -- L["Text"] = "文字"
  L["Unknown sell price"] = "未知价格/无法出售"
  L["Don't show anything for items that are not known"] = "未知物品中不显示任何内容"
  L["Don't show anything for items that cannot be sold to a vendor"] = "不可出售物品中不显示任何内容"
  L["General"] = "基本设置"
  L["Ignore unknown items"] = "屏蔽未知物品"
  L["Ignore unsellable items"] = "屏蔽不可出售物品"
  L["modifier.any"] = "Any"
  L["Specify a custom text to display instead of 'Sells for'."] = "用自定义文本取代默认显示的 '售价'"
  L["Display style"] = "显示样式"
  L["Select the display style"] = "选择显示样式"
  L["Coins"] = "图标"
  L["Text only"] = "仅文字"
  L["Price data"] = "价格数据"
  
elseif GameLocale == "zhTW" then
  L["Bag slots"] = "背包欄位"
  L["Choose a modifier key"] = "選擇輔助鍵"
  L["Custom text"] = "自訂文字"
  L["Display style"] = "顯示樣式"
  L["Don't show anything for items that are not known"] = "不顯示所有未知物品"
  L["Don't show anything for items that cannot be sold to a vendor"] = "不顯示所有無法售予商人的物品"
  L["Ignore unknown items"] = "忽略未知物品"
  L["Ignore unsellable items"] = "不顯示無法售出的物品"
  L["Modifier key only"] = "只在按下輔助鍵時"
  L["Modifier key"] = "輔助鍵"
  L["Only show price when a modifier key is held down"] = "只在按下輔助鍵時才顯示賣出價"
  L["Prices in library: %d"] = "ItemPrice 程式庫: %d"
  L["Purge prices!"] = "清除賣出價!"
  L["Purge recorded vendor prices"] = "清除已記錄的商人賣出價"
  L["Record vendor prices"] = "記錄商人賣出價"
  L["Recorded vendor prices: %d"] = "商人賣出價記錄: %d"
  L["Sells for"] = "賣出價"
  L["Show price for bag slots"] = "顯示背包欄位的價格"
  L["Show statistics for stored prices"] = "顯示賣出價記錄統計"
  L["Show statistics"] = "顯示統計"
  L["Text color"] = "文字顏色"
  L["Text"] = "文字"
  L["Unknown sell price"] = "賣出價不明"

elseif GameLocale == "ruRU" then  
  L["Custom text"] = "Свой текст"
  L["Don't show anything for items that are not known"] = "Ничего не показывать, для неизвестных вещей"
  L["Don't show anything for items that cannot be sold to a vendor"] = "Ничего не показывать, для вещей, которые нельзя продать"
  L["General"] = "Общие"
  L["Ignore unknown items"] = "Игнорировать неизвестные вещи"
  L["Ignore unsellable items"] = "Игнорировать вещи, которые нельзя продать"
  L["Modifier key only"] = "Только с клавишей-модификатором"
  L["modifier.any"] = "Любая"
  L["Only show price when a modifier key is held down"] = "Показывать цену только когда нажата клавиша-модификатор"
  L["Prices in library: %d"] = "Цены в библиотеке: %d"
  L["Purge prices!"] = "Очистить цены"
  L["Purge recorded vendor prices"] = "Очистить записанные у продавцов цены"
  L["Record vendor prices"] = "Записывать цены у продавцов"
  L["Recorded vendor prices: %d"] = "Записанные у продавцов цены: %d"
  L["Sells for"] = "Можно продать за"
  L["Show price for bag slots"] = "Показывать цену для вещей в сумках"
  L["Show statistics for stored prices"] = "Показывать статистику для хранящихся вещей"
  L["Show statistics"] = "Показывать статистику"
  L["Specify a custom text to display instead of 'Sells for'."] = "Укажите свой текст для отображения вместо 'Можно продать за'."
  L["Text color"] = "Цвет текста"
  L["Unknown sell price"] = "Цена неизвестна"
  L["Display style"] = "Стиль отображения"
  L["Select the display style"] = "Выберите стиль отображения"
  L["Coins"] = "Монеты"
  L["Text only"] = "Текст"
  L["Price data"] = "Информация по ценам"
  L["coin.gold"] = "з"
  L["coin.silver"] = "с"
  L["coin.copper"] = "м"
  L["Charge"] = "Заряд"  -- Must match the tooltip text for items with 1 charge!
  L["Charges"] = "Заряда\ов"  -- Must match the tooltip text for items with 2 or more charges!
end

for key, text in pairs(L) do
  if text == true then L[key] = key end
end

_G.ItemPriceTooltip_Locale = setmetatable(L, {
  __newindex = function() error("Attempt to write to the locale table!", 2) end,
  __index = function(self, key)
    if key == nil then error("Key was nil!", 2) end
    geterrorhandler()("Unknown key: "..tostring(key))
    rawset(self, key, key)
    return key
  end,
})

