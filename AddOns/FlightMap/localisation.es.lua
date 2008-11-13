--Spanish Translation by Sisa & AlbertQ
if (GetLocale() == "esES") then

		BINDING_HEADER_FLIGHTMAP = "FlightMap";
		BINDING_NAME_FLIGHTMAP   = "Mostrar mapa de vuelo";
		
		FLIGHTMAP_NAME          = "FlightMap";
		FLIGHTMAP_DESCRIPTION   = "Informaci\195\179n ruta de vuelo en el Mapa del Mundo";
		FLIGHTMAP_ALLIANCE      = "Alianza";
		FLIGHTMAP_HORDE         = "Horda";
		FLIGHTMAP_CONTESTED     = "En Disputa";
		
		-- Zone names
		FLIGHTMAP_MOONGLADE     = "Claro de la Luna";
		FLIGHTMAP_ELWYNN        = "Bosque de Elwynn";
		FLIGHTMAP_DUNMOROGH     = "Dun Morogh";
		FLIGHTMAP_TIRISFAL      = "Claros de Trisfal";
		FLIGHTMAP_LOCHMODAN     = "Loch Modan";
		FLIGHTMAP_SILVERPINE    = "Bosque de Arg\195\169nteos";
		FLIGHTMAP_WESTFALL      = "Paramos de Poniente";
		FLIGHTMAP_REDRIDGE      = "Montañas Crestagrana";
		FLIGHTMAP_DUSKWOOD      = "Bosque del Ocaso";
		FLIGHTMAP_HILLSBRAD     = "Laderas de Trabalomas";
		FLIGHTMAP_WETLANDS      = "Los Humedales";
		FLIGHTMAP_ALTERAC       = "Montañas de Alterac";
		FLIGHTMAP_ARATHI        = "Tierras Altas de Arathi";
		FLIGHTMAP_STRANGLETHORN = "Vega de Tuercespina";
		FLIGHTMAP_BADLANDS      = "Tierras Inh\195\179spitas";
		FLIGHTMAP_SORROWS       = "Pantano de las Penas";
		FLIGHTMAP_HINTERLANDS   = "Tierras del Interior";
		FLIGHTMAP_SEARINGGORGE  = "La Garganta de Fuego";
		FLIGHTMAP_BLASTEDLANDS  = "Las Tierras Devastadas";
		FLIGHTMAP_BURNINGSTEPPE = "Las Estepas Ardientes";
		FLIGHTMAP_WESTERNPLAGUE = "Tierras de la Peste del Oeste";
		FLIGHTMAP_EASTERNPLAGUE = "Tierras de la Peste del Este";
		FLIGHTMAP_DUROTAR       = "Durotar";
		FLIGHTMAP_MULGORE       = "Mulgore";
		FLIGHTMAP_DARKSHORE     = "Costa Oscura";
		FLIGHTMAP_BARRENS       = "Los Bald\195\173os";
		FLIGHTMAP_STONETALON    = "Sierra Espol\195\179n";
		FLIGHTMAP_ASHENVALE     = "Vallefresno";
		FLIGHTMAP_1KNEEDLES     = "Las Mil Agujas";
		FLIGHTMAP_DESOLACE      = "Desolace";
		FLIGHTMAP_DUSTWALLOW    = "Marjal Revolcafango";
		FLIGHTMAP_FERALAS       = "Feralas";
		FLIGHTMAP_TANARIS       = "Tanaris";
		FLIGHTMAP_AZSHARA       = "Azshara";
		FLIGHTMAP_FELWOOD       = "Frondavil";
		FLIGHTMAP_UNGOROCRATER  = "Cr\195\161ter de Un'Goro";
		FLIGHTMAP_SILITHUS      = "Silithus";
		FLIGHTMAP_WINTERSPRING  = "Cuna del Invierno";
		FLIGHTMAP_TELDRASSIL    = "Teldrassil";
		FLIGHTMAP_DEADWINDPASS  = "Paso de la Muerte";
		FLIGHTMAP_ORGRIMMAR     = "Orgrimmar";
		FLIGHTMAP_THUNDERBLUFF  = "Cima del Trueno";
		FLIGHTMAP_UNDERCITY     = "Entrañas";
		FLIGHTMAP_IRONFORGE     = "Forjaz";
		FLIGHTMAP_STORMWIND     = "Ciudad de Ventormenta";
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
		FLIGHTMAP_TIMING        = "(cronometrando)";
		FLIGHTMAP_LEVELS        = "Niveles %d - %d";
		FLIGHTMAP_NOFLIGHTS     = "¡Ninguno conocido!";
		FLIGHTMAP_NOT_KNOWN     = "(Desconocido)";
		FLIGHTMAP_NO_COST       = "Gratis";
		FLIGHTMAP_MONEY_GOLD    = "o";
		FLIGHTMAP_MONEY_SILVER  = "p";
		FLIGHTMAP_MONEY_COPPER  = "c";
		FLIGHTMAP_FLIGHTTIME    = "Duraci\195\179n del vuelo: ";
		FLIGHTMAP_QUICKEST      = "Ruta m\195\161s r\195\161pida";
		FLIGHTMAP_TOTAL_TIME    = "Tiempo total";
		FLIGHTMAP_VIA           = "Por ";
		FLIGHTMAP_CONFIRM       = "¿Estas seguro que desas volar a %s?%s";
		FLIGHTMAP_CONFIRM_TIME  = " Este vuelo tardar\195\160 ";
		
		-- Command strings
		FLIGHTMAP_RESET         = "reiniciar";
		FLIGHTMAP_SHOWMAP       = "abrir";
		FLIGHTMAP_LOCKTIMES     = "bloqueado";
		FLIGHTMAP_GETHELP       = "ayuda";   -- TODO translate
		
		-- Help text        TODO translate
		FLIGHTMAP_TIMER_HELP    =
		    "Pulsa MAY\195\154S y arrastra la barra de tiempo para cambiar su posici\195\179n.";
		FLIGHTMAP_SUBCOMMANDS   = {
		    [FLIGHTMAP_RESET]       = "Reinicia la posicion de la barra de vuelo",
		    [FLIGHTMAP_SHOWMAP]     = "Abir el mapa de vuelos",
		    [FLIGHTMAP_GETHELP]     = "Mostrar este texto",
		};
		
		-- Locked/unlocked status
		FLIGHTMAP_TIMESLOCKED   = {
		    [true] = "Los tiempos de vuelo dejaran de ser guardados.",
		    [false] = "Los tiempos de vuelo ahora ser\195\161n guardados.",
		};
		
		-- Option strings
		FLIGHTMAP_OPTIONS_CLOSE = "Cerrar";
		FLIGHTMAP_OPTIONS_TITLE = "Opciones FlightMap";
		FLIGHTMAP_OPTIONS = {};
		FLIGHTMAP_OPTIONS[1] = {   -- Option 1: flight path lines
		    label = "L\195\173neas ruta de vuelo",
		    option = "showPaths",
		    tooltip = "Dibuja l\195\173neas de las rutas de vuelo en el mapa del mundo.",
		};
		FLIGHTMAP_OPTIONS[2] = {   -- Option 2: extra POI buttons
		    label = "Iconos maestros vuelo",
		    option = "showPOIs",
		    tooltip = "Muestra iconos extra en el mapa para los maestros de vuelo.",
		};
		FLIGHTMAP_OPTIONS[3] = {   -- Option 3: Unknown masters
		    label = "Vuelos desconocidos",
		    option = "showAllInfo",
		    tooltip = "Muestra toda la informaci\195\179n, incluso para los maestros de vuelo no visitados.",
		};
		FLIGHTMAP_OPTIONS[4] = {   -- Option 4: Auto-Dismount
		    label = "Auto desmontar",
		    option = "autoDismount",
		    tooltip = "Desmontar autom\195\161ticamente cuando hablas con el maestro de vuelo",
		};
		FLIGHTMAP_OPTIONS[5] = {   -- Option 5: flight timers
		    label = "Tiempo de vuelo",
		    option = "useTimer",
		    tooltip = "Activar/desactivar la barra de tiempo de vuelo.",
		};
		
		FLIGHTMAP_OPTIONS[6] = {   -- Option 6: Show flight destinations
		    label = "Mostrar destino",
		    option = "showDestinations",
		    tooltip = "Muestra destinos de vuelo en los cuadros de texto",
		    children = {7, 8, 9},
		};
		FLIGHTMAP_OPTIONS[7] = {   -- Option 7: Show multi-hop destinations
		    label = "Incluir multisalto",
		    option = "showMultiHop",
		    tooltip = "Opci\195\179n no v\195\161lida actualmente",
		};
		FLIGHTMAP_OPTIONS[8] = {   -- Option 8: Show flight times
		    label = "Con tiempos de vuelo",
		    option = "showTimes",
		    tooltip = "Muestra los tiempos de vuelo en los cuadros de texto.",
		};
		FLIGHTMAP_OPTIONS[9] = {   -- Option 9: Show flight costs
		    label = "Con costes de vuelo",
		    option = "showCosts",
		    tooltip = "Muestra costes de vuelo en los cuadros de texto.",
		};
		FLIGHTMAP_OPTIONS[10] = {   -- Option 10: Taxi window extras
		    label = "Ventana de vuelo avanzado",
		    option = "fullTaxiMap",
		    tooltip = "Mostrar red de vuelo en la venta de selecci\195\179n del vuelo",
		};
		FLIGHTMAP_OPTIONS[11] = {   -- Option 11: Confirm flight destinations
		    label = "Confirmar vuelos",
		    option = "confirmFlights",
		    tooltip = "Pedir confirmaci\195\179n antes de coger un vuelo",
		};
		
		-- These constants determine how "Town, Zone" strings look.
		-- SEP_STRING is what separates Town from Zone.  SEP_POSTAMBLE
		-- is anything that is after Zone.
		FLIGHTMAP_SEP_STRING    = ", ";
		FLIGHTMAP_SEP_POSTAMBLE = "";

end
