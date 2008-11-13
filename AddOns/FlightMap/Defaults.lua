-- Default neutral data sets for FlightMap
--
-- Some default flight times thanks to Krwaz, author of FlightPath.
-- 
-- This file is loaded after the localisations

-- Default options
FLIGHTMAP_DEFAULT_OPTS = {
     ["showPaths"]   = true,
     ["showPOIs"]    = true,
     ["showAllInfo"] = false,
     ["useTimer"]    = true,
     ["showCosts"]   = false,
     ["showTimes"]   = false,
     ["fullTaxiMap"] = true,
};

-- Sub-zones
FLIGHTMAP_SUBZONES = {
    [FLIGHTMAP_ORGRIMMAR]    = FLIGHTMAP_DUROTAR,
    [FLIGHTMAP_THUNDERBLUFF] = FLIGHTMAP_MULGORE,
    [FLIGHTMAP_UNDERCITY]    = FLIGHTMAP_TIRISFAL,
    [FLIGHTMAP_IRONFORGE]    = FLIGHTMAP_DUNMOROGH,
    [FLIGHTMAP_STORMWIND]    = FLIGHTMAP_ELWYNN,
    [FLIGHTMAP_SHATTRATH]    = FLIGHTMAP_TEROKKAR,
};

FlightMap = {
    ["Opts"]             = FLIGHTMAP_DEFAULT_OPTS,
    ["Knowledge"]        = {},
};
