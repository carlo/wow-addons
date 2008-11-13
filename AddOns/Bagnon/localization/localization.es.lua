--[[
	Bagnon Localization file: Spanish
		Credit goes to Ferroginus
--]]

if GetLocale() ~= "esES" then return end

local L = BAGNON_LOCALS

--bindings
BINDING_HEADER_BAGNON = "Bagnon"
BINDING_NAME_BAGNON_TOGGLE = "Activar Inventario"
BINDING_NAME_BANKNON_TOGGLE = "Activar Banco"

--system messages
L.NewUser = "New user detected, default settings loaded"
L.Updated = "Opciones de Bagnon actualizadas a v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Cannot open the bank, no saved information available"

--slash commands
L.Commands = "Commands:"
L.ShowMenuDesc = "Shows the options menu"
L.ShowBagsDesc = "Toggles the inventory frame"
L.ShowBankDesc = "Toggles the bank frame"

--frame text
L.TitleBank = "Banco de %s"
L.TitleBags = "Inventario de %s"
L.ShowBags = "Mostrar Bolsas"
L.HideBags = "Ocultar Bolsas"

--tooltips
L.TipShowMenu = "<Botón DER> para menú de opciones"
L.TipShowSearch = "<Doble-Click> para buscar"
L.TipShowBag = "<Botón IZQ> para mostrar"
L.TipHideBag = "<Botón IZQ> para esconder"
L.TipGoldOnRealm = "Total on %s"

--menu text
L.FrameSettings = "Frame Settings"
L.Lock = "Bloquear posición"
L.Toplevel = "Toplevel"
L.BackgroundColor = "Fondo"
L.FrameLevel = "Capa"
L.Opacity = "Opacidad"
L.Scale = "Escala"
L.Spacing = "Espaciado"
L.Cols = "Columnas"