--[[
	Bagnon Localization Information: Russian Localization by kutensky
		This file must be present to have partial translations
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'ruRU')
if not L then return end

L.BagnonToggle = "Открыть инвентарь"
L.BanknonToggle = "Открыть сейф банка"

--system messages
L.NewUser = "Обнаружен новый пользователь, загружены стандартные настройки"
L.Updated = "Updated to v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Невозможно открыть сейф, сохраненные данные не доступны"
L.vBagnonLoaded = format("vBagnon and Bagnon are incompatible. Click %s to disable vBagnon and reload your UI", TEXT(ACCEPT))

--slash commands
L.Commands = "Команды:"
L.ShowBagsDesc = "Открыть инвентарь"
L.ShowBankDesc = "Открыть сейф банка"
L.ShowVersionDesc = 'Сообщить версию программы'

--frame text
L.TitleBank = "Сейф игрока %s"
L.TitleBags = "Инвентарь игрока %s"
L.ShowBags = "Показать сумки"
L.HideBags = "Убрать сумки"

--tooltips
L.TipShowMenu = "<ПКМ> Настройки"
L.TipShowSearch = "<Двойной клик> Поиск"
L.TipShowBag = "<Клик> отобразить сумку"
L.TipHideBag = "<Клик> спрятать сумку"
L.TipGoldOnRealm = "Всего денег на %s"

L.ConfirmReloadUI = 'Изменение вступит в силу после перезагрузки игры'