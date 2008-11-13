-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Fonts
-- Author: Mik
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

-- The font files to use.
local FONT_FILES = {
 Adventure		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\adventure.ttf",
 Bazooka		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\bazooka.ttf",
 Cooline		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\cooline.ttf",
 Default		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\porky.ttf",
 Diogenes		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\diogenes.ttf",
 Friz			= "Fonts\\FRIZQT__.TTF",
 Ginko			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\ginko.ttf",
 Heroic			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\heroic.ttf",
 Talisman		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\talisman.ttf",
 Transformers	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\transformers.ttf",
 Yellowjacket	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\yellowjacket.ttf",
 Zephyr			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\zephyr.ttf",
}


-------------------------------------------------------------------------------
-- Load.
-------------------------------------------------------------------------------

-- Loop through all of the fonts and register them.
for fontName, fontPath in pairs(FONT_FILES) do
 MikSBT.RegisterFont(fontName, fontPath);
end