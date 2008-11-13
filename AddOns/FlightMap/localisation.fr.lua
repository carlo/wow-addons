-- Translatable strings, French version

-- XXX This is not yet translated!  If you wish to translate it,
--     please send a copy to me via <bje@apnic.net> so I can include
--     it in the next release!

if (GetLocale() == "frFR") then
    BINDING_HEADER_FLIGHTMAP = "FlightMap";
    BINDING_NAME_FLIGHTMAP   = "Montre la carte des chemins a\195\169riens";

    FLIGHTMAP_NAME          = "FlightMap";
    FLIGHTMAP_DESCRIPTION   = "Informations des chemins a\195\169riens sur la carte du monde";
    FLIGHTMAP_ALLIANCE      = "Alliance";
    FLIGHTMAP_HORDE         = "Horde";
    FLIGHTMAP_CONTESTED     = "Contest\195\169";

    -- Zone names
    FLIGHTMAP_MOONGLADE     = "Reflet-de-Lune (Moonglade)";
    FLIGHTMAP_ELWYNN        = "For\195\170t d'Elwynn";
    FLIGHTMAP_DUNMOROGH     = "Dun Morogh";
    FLIGHTMAP_TIRISFAL      = "Clairi\195\168res de Tirisfal";
    FLIGHTMAP_LOCHMODAN     = "Loch Modan";
    FLIGHTMAP_SILVERPINE    = "For\195\170t des Pins argent\195\169s (Silverpine Forest)";
    FLIGHTMAP_WESTFALL      = "Marche de l'Ouest (Westfall)";
    FLIGHTMAP_REDRIDGE      = "Les Carmines (Redridge Mts)";
    FLIGHTMAP_DUSKWOOD      = "Bois de la P\195\169nombre (Duskwood)";
    FLIGHTMAP_HILLSBRAD     = "Contreforts d'Hillsbrad";
    FLIGHTMAP_WETLANDS      = "Les Paluns (Wetlands)";
    FLIGHTMAP_ALTERAC       = "Montagnes d'Alterac";
    FLIGHTMAP_ARATHI        = "Hautes-terres d'Arathi";
    FLIGHTMAP_STRANGLETHORN = "Vall\195\169e de Strangleronce (Stranglethorn Vale)";
    FLIGHTMAP_BADLANDS      = "Terres ingrates (Badlands)";
    FLIGHTMAP_SORROWS       = "Marais des Chagrins (Swamp of Sorrows)";
    FLIGHTMAP_HINTERLANDS   = "Les Hinterlands";
    FLIGHTMAP_SEARINGGORGE  = "Gorge des Vents br\195\187lants (Searing Gorge)";
    FLIGHTMAP_BLASTEDLANDS  = "Terres foudroy\195\169es (Blasted Lands)";
    FLIGHTMAP_BURNINGSTEPPE = "Steppes ardentes";
    FLIGHTMAP_WESTERNPLAGUE = "Maleterres de l'ouest (Western Plaguelands)";
    FLIGHTMAP_EASTERNPLAGUE = "Maleterres de l'est (Eastern Plaguelands)";
    FLIGHTMAP_DUROTAR       = "Durotar";
    FLIGHTMAP_MULGORE       = "Mulgore";
    FLIGHTMAP_DARKSHORE     = "Sombrivage (Darkshore)";
    FLIGHTMAP_BARRENS       = "Les Tarides (the Barrens)";
    FLIGHTMAP_STONETALON    = "Les Serres-Rocheuses (Stonetalon Mts)";
    FLIGHTMAP_ASHENVALE     = "Ashenvale";
    FLIGHTMAP_1KNEEDLES     = "Mille pointes (Thousand Needles)";
    FLIGHTMAP_DESOLACE      = "D\195\169solace";
    FLIGHTMAP_DUSTWALLOW    = "Mar\195\169cage d'\195\130prefange (Dustwallow Marsh)";
    FLIGHTMAP_FERALAS       = "Feralas";
    FLIGHTMAP_TANARIS       = "Tanaris";
    FLIGHTMAP_AZSHARA       = "Azshara";
    FLIGHTMAP_FELWOOD       = "Gangrebois (Felwood)";
    FLIGHTMAP_UNGOROCRATER  = "Crat\195\168re d'Un'Goro";
    FLIGHTMAP_SILITHUS      = "Silithus";
    FLIGHTMAP_WINTERSPRING  = "Berceau-de-l'Hiver (Winterspring)";
    FLIGHTMAP_TELDRASSIL    = "Teldrassil";
    FLIGHTMAP_DEADWINDPASS  = "D\195\169fil\195\169 de Deuillevent (Deadwind Pass)";
    FLIGHTMAP_ORGRIMMAR     = "Orgrimmar";
    FLIGHTMAP_THUNDERBLUFF  = "Thunder Bluff";
    FLIGHTMAP_UNDERCITY     = "Undercity";
    FLIGHTMAP_IRONFORGE     = "Ironforge";
    FLIGHTMAP_STORMWIND     = "Cit\195\169 de Stormwind";
    FLIGHTMAP_DARNASSUS     = "Darnassus";

    -- Burning Crusade zones
    FLIGHTMAP_BLADESEDGE    = "Blade's Edge Mountains";
    FLIGHTMAP_HELLFIRE      = "Hellfire Peninsula";
    FLIGHTMAP_NAGRAND       = "Nagrand";
    FLIGHTMAP_NETHERSTORM   = "Netherstorm";
    FLIGHTMAP_SHADOWMOON    = "Shadowmoon Valley";
    FLIGHTMAP_SHATTRATH     = "Shattrath City";
    FLIGHTMAP_TEROKKAR      = "Terokkar Forest";
    FLIGHTMAP_ZANGARMARSH   = "Zangarmarsh";

    -- General strings
    FLIGHTMAP_TIMING        = "(ajustement)";
    FLIGHTMAP_LEVELS        = "|cff00ff00Niveau de Zone: %d - %d|r";
    FLIGHTMAP_NOFLIGHTS     = "Aucun connu!";
    FLIGHTMAP_NOT_KNOWN     = "(Inconnu)";
    FLIGHTMAP_NO_COST       = "Gratuit";
    FLIGHTMAP_MONEY_GOLD    = "o";
    FLIGHTMAP_MONEY_SILVER  = "a";
    FLIGHTMAP_MONEY_COPPER  = "c";
    FLIGHTMAP_FLIGHTTIME    = "Temps de vol: ";
    FLIGHTMAP_QUICKEST      = "Trajet le plus rapide";
    FLIGHTMAP_TOTAL_TIME    = "Temps total";
    FLIGHTMAP_VIA           = "Via ";
    FLIGHTMAP_CONFIRM       = "Voulez-vous vraiment rejoindre %s?%s";
    FLIGHTMAP_CONFIRM_TIME  = " Ce vol devrait prendre ";

    -- Command strings
    FLIGHTMAP_RESET         = "r\195\169initialiser";
    FLIGHTMAP_SHOWMAP       = "ouvrir";
    FLIGHTMAP_LOCKTIMES     = "verrouiller";
    FLIGHTMAP_GETHELP       = "aide";

    -- Help text
    FLIGHTMAP_TIMER_HELP    =
        "Maintenir la touche SHIFT et d\195\169placer la barre de temps de vol pour la d\195\169placer.";
    FLIGHTMAP_SUBCOMMANDS   = {
        [FLIGHTMAP_RESET]       = "Remettre la bar de temps de vol dans sa position d'origine",
        [FLIGHTMAP_SHOWMAP]     = "Ouvrir la fen\195\170tre des chemins a\195\169riens",
        [FLIGHTMAP_GETHELP]     = "Montrer ce texte",
    };

    -- Locked/unlocked status
    FLIGHTMAP_TIMESLOCKED   = {
        [true] = "Les temps de vol ne seront plus enregistr\195\169s.",
        [false] = "Les temps de vol seront \195\160 pr\195\169sent enregistr\195\169s.",
    };

    -- Option strings
    FLIGHTMAP_OPTIONS_CLOSE = "Fermer";
    FLIGHTMAP_OPTIONS_TITLE = "Options FlightMap";
    FLIGHTMAP_OPTIONS = {};
    FLIGHTMAP_OPTIONS[1] = {   -- Option 1: flight path lines
        label = "Afficher les lignes",
        option = "showPaths",
        tooltip = "Dessine les lignes des chemins a\195\169riens sur la carte du monde.",
    };
    FLIGHTMAP_OPTIONS[2] = {   -- Option 2: extra POI buttons
        label = "Ma\195\174tre sur la carte",
        option = "showPOIs",
        tooltip = "Affiche l'emplacement des ma\195\174tres de vol sur la carte des zones par une ic\195\180ne.",
    };
    FLIGHTMAP_OPTIONS[3] = {   -- Option 3: Unknown masters
        label = "Montrer tous les vols",
        option = "showAllInfo",
        tooltip = "Montre tous les points de vol, m\195\170me ceux qui ne sont pas d\195\169couvert.",
    };
    FLIGHTMAP_OPTIONS[4] = {   -- Option 4: Auto-Dismount
        label = "Quitter sa monture",
        option = "autoDismount",
        tooltip = "Quitte sa monture automatiquement en parlant \195\160 un ma\195\174tre de vol.",
    };
    FLIGHTMAP_OPTIONS[5] = {   -- Option 5: flight timers
        label = "Bar de temps de vol",
        option = "useTimer",
        tooltip = "Active/Supprime la barre de progression du trajet.",
    };

    FLIGHTMAP_OPTIONS[6] = {   -- Option 6: Show flight destinations
        label = "Montrer les destinations",
        option = "showDestinations",
        tooltip = "Affiche les destinations de vol dans les bulles d'aide.",
        children = {7, 8, 9},
    };
    FLIGHTMAP_OPTIONS[7] = {   -- Option 7: Show multi-hop destinations
        label = "Inclure les multi-hop",
        option = "showMultiHop",
        tooltip = "Affiche les destinations multi-hop dans les bulles d'aide.",
    };
    FLIGHTMAP_OPTIONS[8] = {   -- Option 8: Show flight times
        label = "Afficher la dur\195\169e",
        option = "showTimes",
        tooltip = "Affiche le temps de vol pour chaque destination dans les bulles d'aide.",
    };
    FLIGHTMAP_OPTIONS[9] = {   -- Option 9: Show flight costs
        label = "Afficher le prix",
        option = "showCosts",
        tooltip = "Affiche le prix des vols dans les bulles d'aide.",
    };
    FLIGHTMAP_OPTIONS[10] = {   -- Option 10: Taxi window extras
        label = "Fen\195\170tre de vol am\195\169lior\195\169",
        option = "fullTaxiMap",
        tooltip = "Affiche sur la fen\195\170tre de vol les interconnections entre les diff\195\169rentes destinations.",
    };
    FLIGHTMAP_OPTIONS[11] = {   -- Option 11: Confirm flight destinations
        label = "Confirmation de vol",
        option = "confirmFlights",
        tooltip = "Demande confirmation avant de prendre un vol.",
    };

    -- These constants determine how "Town, Zone" strings look.
    -- SEP_STRING is what separates Town from Zone.  SEP_POSTAMBLE
    -- is anything that is after Zone.
    FLIGHTMAP_SEP_STRING    = ", ";
    FLIGHTMAP_SEP_POSTAMBLE = "";
end
