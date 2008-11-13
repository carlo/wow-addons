--[[
	Bagnon Localization Information: English Language
		This file must be present to have partial translations
--]]

BAGNON_LOCALS = {}
local L = BAGNON_LOCALS

--bindings
BINDING_HEADER_BAGNON = "Bagnon"
BINDING_NAME_BAGNON_TOGGLE = "Toggle Inventory"
BINDING_NAME_BANKNON_TOGGLE = "Toggle Bank"

--item types, should not need to be translated
L.TypeContainer = select(3, GetAuctionItemClasses())
L.TypeQuiver = select(7, GetAuctionItemClasses())

--subtypes, should not need to be translated
L.SubTypeBag = select(1, GetAuctionItemSubClasses(3))
L.SubTypeSoulBag = select(2, GetAuctionItemSubClasses(3))

--system messages
L.NewUser = "New user detected, default settings loaded"
L.Updated = "Updated to v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Cannot open the bank, no saved information available"
L.vBagnonLoaded = format("vBagnon and Bagnon are incompatible. Click %s to disable vBagnon and reload your UI", TEXT(ACCEPT))

--slash commands
L.Commands = "Commands:"
L.ShowMenuDesc = "Shows the options menu"
L.ShowBagsDesc = "Toggles the inventory frame"
L.ShowBankDesc = "Toggles the bank frame"

--frame text
L.TitleBank = "%s's Bank"
L.TitleBags = "%s's Inventory"
L.ShowBags = "Show Bags"
L.HideBags = "Hide Bags"

--tooltips
L.TipShowMenu = "<Right-Click> to Configure"
L.TipShowSearch = "<Double-Click> to Search"
L.TipShowBag = "<Click> to Show"
L.TipHideBag = "<Click> to Hide"
L.TipGoldOnRealm = "Total on %s"

--menu text
L.FrameSettings = "Frame Settings"
L.Lock = "Lock Position"
L.Toplevel = "Always On Top"
L.BackgroundColor = "Background"
L.FrameLevel = "Frame Level"
L.Opacity = "Opacity"
L.Scale = "Scale"
L.Spacing = "Spacing"
L.Cols = "Columns"
L.ReverseSort = "Reverse Order"