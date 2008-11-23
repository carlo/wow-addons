------------------------------------------------------
-- localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------

SP_Localized = {};		-- this line doesn't need localization, it just lets us use SP_Localized below.

	SOLD_FOR_PRICE_BY = "Sold for %s by";					-- prefix to vendor info when price is shown
	SOLD_BY = "Sold by";									-- prefix to vendor info when no price is shown
	RETURN_TO = "Return to";								-- prefix to info for librams
	ARCANUM_FORMAT = "Reward: %s enchantment";				-- bonus info for librams
	VENDOR_LOCATION_FORMAT = "%s, %s";						-- format for showing vendor name and location
	SP_FACTION_REWARDS = "%s Rewards:";
	SP_FACTION_REWARDS_COUNT = "%d %s Rewards";
	SP_TURNIN = "Faction turnin for";
	SP_WITH = "also requires";
	
-- notes for other items
	DARKMOON = "Bring to Darkmoon Faire, win prizes!";
	
-- notes for vendors with special availability
	SEASONAL_VENDOR = "(Seasonal vendor)";
	SCHOLO_QUEST = "Requires Spectral Essence";

-- non-nil note so vendors in instances are highlighted in a different color
-- but no actual note text because it'd be cheesy to give too much away...	
	BRD_BARKEEP = "";
	DM_LIBRARY = "";
	
-- non-nil note for faction recipes so it gets a different color
-- no actual note because it's part of the base tooltip now.
	REQ_FACTION = "";
	
-- notes for items only available once you have a certain reputation standing
	THORIUM_FRIENDLY = "Requires Thorium Brotherhood - "..FACTION_STANDING_LABEL5;
	THORIUM_HONORED = "Requires Thorium Brotherhood - "..FACTION_STANDING_LABEL6;
	THORIUM_REVERED = "Requires Thorium Brotherhood - "..FACTION_STANDING_LABEL7;
	THORIUM_EXALTED = "Requires Thorium Brotherhood - "..FACTION_STANDING_LABEL8;

	TIMBERMAW_FRIENDLY = "Requires Timbermaw Furbolgs - "..FACTION_STANDING_LABEL5;

-- Faction names
	AD_FACTION = "Argent Dawn";
	ZG_FACTION = "Zandalar Tribe";
	AQ20_FACTION = "Cenarion Circle";
	AQ40_FACTION = "Brood of Nozdormu";
	
-- localized class names
	PALADIN = "Paladin";
	SHAMAN = "Shaman";
	MAGE = "Mage";
	PRIEST = "Priest";
	WARLOCK = "Warlock";
	WARRIOR = "Warrior";
	HUNTER = "Hunter";
	ROGUE = "Rogue";
	DRUID = "Druid";

-- localized weapon types
	STAFF = "Staff";
	MACE = "Mace";
	AXE = "Axe";
	GUN = "Gun";
	DAGGER = "Dagger";
	SHIELD = "Shield";
	SWORD = "Sword";
	
	SP_RECIPE = "Recipe";	-- the 6th return of GetItemInfo() for tradeskill recipes
	SP_BOOK = "Book";	-- the 7th return of GetItemInfo() for "recipes" that aren't for tradeskills
	SP_MISCELLANEOUS = "Miscellaneous";
	SP_PET = "Pet";
	SP_QUIVER = "Quiver";
	SP_CONTAINER = "Container";
	
SP_OPTIONS_GENERAL = "Add info to tooltips for items:";
SP_OPTION_RECIPES = "Items available from NPC vendors";
SP_OPTION_RECIPE_COST = "Show vendor price for items";
SP_OPTION_LIBRAM = "Librams (turnin NPC and reward info)";
SP_OPTION_DARKMOON = "Items with Darkmoon Faire rewards";
SP_OPTION_AD = "Items turned in for Seals of the Dawn/Crusade";

SP_OPTIONS_RAID = "And for special raid loot:";
SP_OPTION_ZG = "Zul'Gurub";
SP_OPTION_ZG_FACTION = "(Zandalar Tribe rewards)";
SP_OPTION_AQ20 = "Ruins of Ahn'Qiraj";
SP_OPTION_AQ20_FACTION = "(AQ20 Cenarion Circle rewards)";
SP_OPTION_AQ40 = "Ahn'Qiraj";
SP_OPTION_AQ40_FACTION = "(AQ40 Brood of Nozdormu rewards)";
SP_OPTION_POST_RAID = "Post to raid chat when getting info via '/swp [link]'";

if ( GetLocale() == "deDE" ) then

	-- new de-localizations override 
	-- new de-localizations adds
	-- by zara @ united-netplayers.de

	SOLD_FOR_PRICE_BY = "Wird für %s verkauft von";					-- prefix to vendor info when price is shown
	SOLD_BY = "Wird verkauft von";									-- prefix to vendor info when no price is shown
	RETURN_TO = "Zurückkehren zu";								-- prefix to info for librams
	ARCANUM_FORMAT = "Belohnung: %s Verzauberung";				-- bonus info for librams
	VENDOR_LOCATION_FORMAT = "%s, %s";						-- format for showing vendor name and location
	SP_FACTION_REWARDS = "%s Belohnung:";
	SP_FACTION_REWARDS_COUNT = "%d %s Belohnung";
	SP_TURNIN = "Rufabgabe für";
	SP_WITH = "wird auch benötigt";
	
-- notes for other items
	DARKMOON = "Zum Dunkelmond-Jahrmarkt bringen und Belohnungen abholen!";
	
-- notes for vendors with special availability
	SEASONAL_VENDOR = "(Saisonaler Verkäufer)";
	SCHOLO_QUEST = "Benötigt Spektrale Essenz";
	
	BRD_BARKEEP = "Schwarzfelstiefen - Gastwirt";
	DM_LIBRARY = "Düsterbruch - Bibliothek";
	
	REQ_FACTION = "Ruf ";
	
-- notes for items only available once you have a certain reputation standing
	THORIUM_FRIENDLY = "Benötigt Thorium-Bruderschaft - "..FACTION_STANDING_LABEL5;
	THORIUM_HONORED = "Benötigt Thorium-Bruderschaft - "..FACTION_STANDING_LABEL6;
	THORIUM_REVERED = "Benötigt Thorium-Bruderschaft - "..FACTION_STANDING_LABEL7;
	THORIUM_EXALTED = "Benötigt Thorium-Bruderschaft - "..FACTION_STANDING_LABEL8;

	TIMBERMAW_FRIENDLY = "Benötigt Die Holzschlundfeste - "..FACTION_STANDING_LABEL5;

	-- Faction names
	AD_FACTION = "Argentumdämmerung";
	ZG_FACTION = "Stamm der Zandalar";
	AQ20_FACTION = "Zirkel des Cenarius";
	AQ40_FACTION = "Brut Nozdormus";
	
	-- localized class names
	PALADIN = "Paladin";
	SHAMAN = "Schamane";
	MAGE = "Magier";
	PRIEST = "Priester";
	WARLOCK = "Hexenmeister";
	WARRIOR = "Krieger";
	HUNTER = "Jäger";
	ROGUE = "Schurke";
	DRUID = "Druide";
	
	-- localized weapon types
	STAFF = "Stab";
	MACE = "Streitkolben";
	AXE = "Axt";
	GUN = "Schusswaffe";
	DAGGER = "Dolch";
	SHIELD = "Schild";
	SWORD = "Schwert";
	
	-- added
    BOW = "Bogen";
    CROSSBOW = "Armbrust";
    POLEARM = "Stangenwaffe";
    THROWN = "Wurfwaffe";
    WAND = "Zauberstab";
	
	SP_RECIPE = "Rezept";	-- the 6th return of GetItemInfo() for tradeskill recipes
	SP_BOOK = "Buch";	-- the 7th return of GetItemInfo() for "recipes" that aren't for tradeskills 
		
	-- SP_OPTIONS = "SwindlerPreventer Options";
	-- SP_OPTIONS_GENERAL = "Add info to tooltips for items:";
	-- SP_OPTION_RECIPES = "Recipes available from NPC vendors";
	-- SP_OPTION_RECIPE_COST = "Show vendor price for recipes";
	-- SP_OPTION_LIBRAM = "Librams (turnin NPC and reward info)";
	-- SP_OPTION_DARKMOON = "Grey items with Darkmoon Faire rewards";
	-- SP_OPTION_AD = "Items turned in for Seals of the Dawn/Crusade";

	-- SP_OPTIONS_RAID = "And for special raid loot:";
	-- SP_OPTION_ZG = "Zul'Gurub";
	-- SP_OPTION_ZG_FACTION = "(Zandalar Tribe rewards)";
	-- SP_OPTION_AQ20 = "Ruins of Ahn'Qiraj";
	-- SP_OPTION_AQ20_FACTION = "(AQ20 Cenarion Circle rewards)";
	-- SP_OPTION_AQ40 = "Ahn'Qiraj";
	-- SP_OPTION_AQ40_FACTION = "(AQ40 Brood of Nozdormu rewards)";
	-- SP_OPTION_POST_RAID = "Post to raid chat when getting info via '/swp [link]'";
	
	
-- localized zone names (only those that differ from the enUS version should be present)
	SP_Localized["Alterac Mountains"] = "Das Alteracgebirge";
	SP_Localized["Arathi Highlands"] = "Das Arathihochland";
	SP_Localized["Badlands"] = "Das Ödland";
	SP_Localized["Blackrock Depths"] = "Schwarzfelstiefen"; -- zara
	SP_Localized["Blasted Lands"] = "Die verwüsteten Lande";
	SP_Localized["Burning Steppes"] = "Die brennende Steppe";
	SP_Localized["Dustwallow Marsh"] = "Die Marschen von Dustwallow";
	SP_Localized["Eastern Plaguelands"] = "Die östlichen Pestländer";
	SP_Localized["Elwynn Forest"] = "Der Wald von Elwynn";
	SP_Localized["Hillsbrad Foothills"] = "Die Vorgebirge von Hillsbrad";
	SP_Localized["Redridge Mountains"] = "Das Redridgegebirge";
	SP_Localized["Silverpine Forest"] = "Der Silberwald";
	SP_Localized["Stonetalon Mountains"] = "Das Steinkrallengebirge";
	SP_Localized["Stormwind City"] = "Stormwind";
	SP_Localized["Stranglethorn Vale"] = "Stranglethorn";
	SP_Localized["Swamp of Sorrows"] = "Die Sümpfe des Elends";
	SP_Localized["The Barrens"] = "Das Brachland";
	SP_Localized["The Hinterlands"] = "Das Hinterland";
	SP_Localized["Tirisfal Glades"] = "Tirisfal";
	SP_Localized["Un'Goro Crater"] = "Der Un'Goro Krater";
	SP_Localized["Wailing Caverns"] = "Die Höhlen des Wehklagens";
	SP_Localized["Western Plaguelands"] = "Die westlichen Pestländer";
	SP_Localized["Wetlands"] = "Das Sumpfland";

	SP_Localized["Darkshore"] = "Dunkelküste";
	SP_Localized["Dire Maul"] = "Düsterbruch";
	SP_Localized["Alterac Valley"] = "Alteractal";
	SP_Localized["Arathi Basin"] = "Arathibecken";
	SP_Localized["Ashenvale"] = "Eschental";
	SP_Localized["Blackfathom Deeps"] = "Tiefschwarze Grotte";		
	SP_Localized["Blackrock Mountain"] = "Der Schwarzfels";		
	SP_Localized["Blackrock Spire"] = "Schwarzfelsspitze";
	SP_Localized["Blackwing Lair"] = "Pechschwingenhort";		
	SP_Localized["Booty Bay"] = "Beutebucht";		
	SP_Localized["The Deadmines"] = "Die Todesminen";
	SP_Localized["Deadwind Pass"] = "Gebirgspass der Totenwinde";
	SP_Localized["Deeprun Tram"] = "Die Tiefenbahn";
	SP_Localized["Dire Maul (North)"] = "Düsterbruch (Nord)";
	SP_Localized["Dire Maul (East)"] = "Düsterbruch (Ost)";
	SP_Localized["Dire Maul (West)"] = "Düsterbruch (West)";		
	SP_Localized["Duskwood"] = "Dämmerwald";		
	SP_Localized["Everlook"] = "Ewige Warte";
	SP_Localized["Felwood"] = "Teufelswald";
	SP_Localized["Ironforge"] = "Eisenschmiede";
	SP_Localized["Lower Blackrock Spire"] = "Untere Schwarzfelsspitze";
	SP_Localized["Menethil Harbor"] = "Hafen von Menethil";
	SP_Localized["Molten Core"] = "Geschmolzener Kern";
	SP_Localized["Moonglade"] = "Mondlichtung";		
	SP_Localized["Onyxia's Lair"] = "Onyxias Hort";
	SP_Localized["Ratchet"] = "Ratschet";
	SP_Localized["Ragefire Chasm"] = "Der Flammenschlund";
	SP_Localized["Razorfen Downs"] = "Hügel der Klingenhauer";
	SP_Localized["Razorfen Kraul"] = "Kral der Klingenhauer";
	SP_Localized["Ruins of Ahn'Qiraj"] = "Ruinen von Ahn'Qiraj";
	SP_Localized["Scarlet Monastery"] = "Das Scharlachrote Kloster";
	SP_Localized["Searing Gorge"] = "Sengende Schlucht";
	SP_Localized["Shadowfang Keep"] = "Burg Schattenfang";
	SP_Localized["The Stockade"] = "Das Verlies";
	SP_Localized["Stonetalon Mountains"] = "Steinkrallengebirge";
	SP_Localized["Stormwind City"] = "Sturmwind";
	SP_Localized["Stranglethorn Vale"] = "Schlingendorntal";
	SP_Localized["Swamp of Sorrows"] = "Sümpfe des Elends";		
	SP_Localized["Temple of Ahn'Qiraj"] = "Tempel von Ahn'Qiraj";
	SP_Localized["The Temple of Atal'Hakkar"] = "Der Tempel von Atal'Hakkar";
	SP_Localized["Theramore Isle"] = "Insel Theramore";
	SP_Localized["Thousand Needles"] = "Tausend Nadeln";
	SP_Localized["Thunder Bluff"] = "Donnerfels";
	SP_Localized["Undercity"] = "Unterstadt";
	SP_Localized["Upper Blackrock Spire"] = "Obere Schwarzfelsspitze";
	SP_Localized["Warsong Gulch"] = "Kriegshymnenschlucht";
	SP_Localized["Winterspring"] = "Winterquell";

	-- zara Burning Crusade
	SP_Localized["Plaguewood"] = "Seuchenwald";
	SP_Localized["Hellfire Citadel"] = "Höllenfeuerzitadelle";
	SP_Localized["The Bone Wastes"] = "Die Knochenwüste";
	SP_Localized["Ring of Observance"] = "Ring der Beobachtung";
	SP_Localized["Coilfang Reservoir"] = "Der Echsenkessel";
	SP_Localized["Azuremyst Isle"] = "Azurmythosinsel";
	SP_Localized["Bloodmyst Isle"] = "Blutmythosinsel";
	SP_Localized["Eversong Woods"] = "Immersangwald";
	SP_Localized["Ghostlands"] = "Geisterlande";
	SP_Localized["The Exodar"] = "Die Exodar";
	SP_Localized["Silvermoon City"] = "Silbermond";
	SP_Localized["Shadowmoon Valley"] = "Schattenmondtal";
	SP_Localized["Black Temple"] = "Der Schwarze Tempel";
	SP_Localized["Terokkar Forest"] = "Wälder von Terokkar";
	SP_Localized["Auchenai Crypts"] = "Auchenaikrypta";
	SP_Localized["Mana-Tombs"] = "Managruft";
	SP_Localized["Shadow Labyrinth"] = "Schattenlabyrinth";
	SP_Localized["Sethekk Halls"] = "Sethekkhallen";
	SP_Localized["Hellfire Peninsula"] = "Höllenfeuerhalbinsel";
	SP_Localized["The Dark Portal"] = "Das Dunkle Portal";
	SP_Localized["Hellfire Ramparts"] = "Höllenfeuerbollwerk";
	SP_Localized["The Blood Furnace"] = "Der Blutkessel";
	SP_Localized["The Shattered Halls"] = "Die zerschmetterten Hallen";
	SP_Localized["Magtheridon's Lair"] = "Magtheridons Kammer";
	SP_Localized["Zangarmarsh"] = "Zangarmarschen";
	SP_Localized["The Slave Pens"] = "Die Sklavenunterkünfte";
	SP_Localized["The Underbog"] = "Der Tiefensumpf";
	SP_Localized["The Steamvault"] = "Die Dampfkammer";
	SP_Localized["Serpentshrine Cavern"] = "Höhle des Schlangenschreins";
	SP_Localized["Blade's Edge Mountains"] = "Schergrat";
	SP_Localized["Gruul's Lair"] = "Gruuls Unterschlupf";
	SP_Localized["Netherstorm"] = "Nethersturm";
	SP_Localized["Tempest Keep"] = "Festung der Stürme";
	SP_Localized["The Mechanar"] = "Die Mechanar";
	SP_Localized["The Botanica"] = "Die Botanika";
	SP_Localized["The Arcatraz"] = "Die Arkatraz";
	SP_Localized["The Eye"] = "Das Auge";
	SP_Localized["Eye of the Storm"] = "Auge des Sturms";
	SP_Localized["Shattrath City"] = "Shattrath";
	SP_Localized["Caverns of Time"] = "Die Höhlen der Zeit";
	SP_Localized["Old Hillsbrad Foothills"] = "Vorgebirge des Alten Hügellands";
	SP_Localized["The Black Morass"] = "Der schwarze Morast";
	SP_Localized["Night Elf Village"] = "Nachtelfen Dorf";
	SP_Localized["Horde Encampment"] = "Horde Lager";
	SP_Localized["Alliance Base"] = "Allianz Basis";

	
-- localized NPC names (only those that differ from the enUS version should be present)
	SP_Localized["Alchemist Pestlezugg"] = "Alchimist Pestlezugg";
	SP_Localized["Argent Quartermaster Hasana"] = "Argentum-Rüstmeister Hasana";
	SP_Localized["Argent Quartermaster Lightspark"] = "Argentum-Rüstmeister Lightspark";
	SP_Localized["Defias Profiteer"] = "Defias-Schieber";
	SP_Localized["Lorekeeper Lydros"] = "Wissenswächter Lydros";
	SP_Localized["Outfitter Eric"] = "Ausstatter Eric";
	SP_Localized["Quartermaster Miranda Breechlock"] = "Rüstmeisterin Miranda Breechlock";
	SP_Localized["Rin'wosho the Trader"] = "Rin'wosho der Händler";

-- localized libram descriptions 
	SP_Localized["+1% Dodge"] = "+1% Ausweichen";
	SP_Localized["+1% Haste"] = "+1% Angriffsgeschwindigkeit";
	SP_Localized["+100 Health"] = "+100 Gesundheit";
	SP_Localized["+125 Armor"] = "+125 Rüstung";
	SP_Localized["+20 Fire Resistance"] = "+20 Feuer Resistenz";
	SP_Localized["+8 Spell damage/healing"] = "+8 Zauberschaden/Heilung";
	SP_Localized["+8 any single stat"] = "+8 alle Werte";

-- localized special raid loot tokens
	SP_Localized["Zulian Coin"]		=	"Zulianische Münze";
	SP_Localized["Razzashi Coin"]		=	"Münze der Razzashi";
	SP_Localized["Hakkari Coin"]		=	"Münze der Hakkari";
	SP_Localized["Gurubashi Coin"]		=	"Münze der Gurubashi";
	SP_Localized["Vilebranch Coin"]	=	"Münze der Vilebranch";
	SP_Localized["Witherbark Coin"]	=	"Münze der Witherbark";
	SP_Localized["Sandfury Coin"]		=	"Münze der Sandfury";
	SP_Localized["Skullsplitter Coin"]	=	"Münze der Skullsplitter";
	SP_Localized["Bloodscalp Coin"]	=	"Münze der Bloodscalp";
            
	SP_Localized["Red Hakkari Bijou"]		=	"Rotes Schmuckstück der Hakkari";
	SP_Localized["Blue Hakkari Bijou"]		=	"Blaues Schmuckstück der Hakkari";
	SP_Localized["Yellow Hakkari Bijou"]	=	"Gelbes Schmuckstück der Hakkari";
	SP_Localized["Orange Hakkari Bijou"]	=	"Orangefarbenes Schmuckstück der Hakkari";
	SP_Localized["Green Hakkari Bijou"]	=	"Grünes Schmuckstück der Hakkari";
	SP_Localized["Purple Hakkari Bijou"]	=	"Lilanes Schmuckstück der Hakkari";
	SP_Localized["Bronze Hakkari Bijou"]	=	"Bronzefarbenes Schmuckstück der Hakkari";
	SP_Localized["Silver Hakkari Bijou"]	=	"Silbernes Schmuckstück der Hakkari";
	SP_Localized["Gold Hakkari Bijou"]		=	"Goldenes Schmuckstück der Hakkari";
            
	SP_Localized["Primal Hakkari Bindings"]	=	"Urzeitliche Hakkaribindungen";
	SP_Localized["Primal Hakkari Armsplint"]	=	"Urzeitliche Hakkariarmsplinte";
	SP_Localized["Primal Hakkari Stanchion"]	=	"Urzeitliche Hakkaristütze";
	SP_Localized["Primal Hakkari Girdle"]		=	"Urzeitlicher Hakkarigurt";
	SP_Localized["Primal Hakkari Sash"]		=	"Urzeitliche Hakkarischärpe";
	SP_Localized["Primal Hakkari Shawl"]		=	"Urzeitlicher Hakkarischal";
	SP_Localized["Primal Hakkari Tabard"]		=	"Urzeitlicher Hakkariwappenrock";
	SP_Localized["Primal Hakkari Kossack"]		=	"Urzeitlicher Hakkarikosak";
	SP_Localized["Primal Hakkari Aegis"]		=	"Urzeitliche Aegis der Hakkari";
            
	SP_Localized["Qiraji Magisterial Ring"]	=	"Gebieterring der Qiraji";
	SP_Localized["Qiraji Ceremonial Ring"]		=	"Zeremonienring der Qiraji";
	SP_Localized["Qiraji Martial Drape"]		=	"Kampftuch der Qiraji";
	SP_Localized["Qiraji Regal Drape"]			=	"Hoheitstuch der Qiraji";
	SP_Localized["Qiraji Spiked Hilt"]			=	"Stachelgriff der Qiraji";
	SP_Localized["Qiraji Ornate Hilt"]			=	"Verschnörkelter Griff der Qiraji";
            
	SP_Localized["Imperial Qiraji Armaments"]	=	"Imperiale Qirajiwaffe";
	SP_Localized["Imperial Qiraji Regalia"]	=	"Imperiale Qirajiinsignie";
            
	SP_Localized["Qiraji Bindings of Command"]		=	"Befehlsbindungen der Qiraji";
	SP_Localized["Qiraji Bindings of Dominance"]	=	"Dominanzbindungen der Qiraji";
	SP_Localized["Ouro's Intact Hide"]				=	"Ouros intakte Haut";
	SP_Localized["Skin of the Great Sandworm"]		=	"Haut des großen Sandwurms";
	SP_Localized["Vek'lor's Diadem"]				=	"Vek'lors Diadem";
	SP_Localized["Vek'nilash's Circlet"]			=	"Vek'nilashs Reif";
	SP_Localized["Carapace of the Old God"]		=	"Knochenpanzer des alten Gottes";
	SP_Localized["Husk of the Old God"]			=	"Hülle des alten Gottes";
            
	SP_Localized["Stone Scarab"]	=	"Steinskarabäus";
	SP_Localized["Gold Scarab"]	=	"Goldskarabäus";
	SP_Localized["Silver Scarab"]	=	"Silberskarabäus";
	SP_Localized["Bronze Scarab"]	=	"Bronzeskarabäus";
	SP_Localized["Crystal Scarab"]	=	"Kristallskarabäus";
	SP_Localized["Clay Scarab"]	=	"Tonskarabäus";
	SP_Localized["Bone Scarab"]	=	"Knochenskarabäus";
	SP_Localized["Ivory Scarab"]	=	"Elfenbeinskarabäus";
            
	SP_Localized["Azure Idol"]			=	"Azurgötze";
	SP_Localized["Onyx Idol"]			=	"Onyxgötze";
	SP_Localized["Lambent Idol"]		=	"Züngelnder Götze";
	SP_Localized["Amber Idol"]			=	"Bernsteingötze";
	SP_Localized["Jasper Idol"]		=	"Jaspisgötze";
	SP_Localized["Obsidian Idol"]		=	"Obsidiangötze";
	SP_Localized["Vermillion Idol"]	=	"Zinnobergötze";
	SP_Localized["Alabaster Idol"]		=	"Alabastergötze";
            
	SP_Localized["Idol of the Sun"]	=	"Götze der Sonne";
	SP_Localized["Idol of Night"]		=	"Götze der Nacht";
	SP_Localized["Idol of Death"]		=	"Götze des Todes";
	SP_Localized["Idol of the Sage"]	=	"Götze der Weisen";
	SP_Localized["Idol of Rebirth"]	=	"Götze der Wiedergeburt";
	SP_Localized["Idol of Life"]		=	"Götze des Lebens";
	SP_Localized["Idol of Strife"]		=	"Götze des Kampfes";
	SP_Localized["Idol of War"]		=	"Götze des Krieges";

end


if ( GetLocale() == "koKR" ) then

	SOLD_FOR_PRICE_BY = "상점가격 %s 판매:";					-- prefix to vendor info when price is shown
	SOLD_BY = "[판매]";									-- prefix to vendor info when no price is shown
	RETURN_TO = "보상 NPC: ";								-- prefix to info for librams
	ARCANUM_FORMAT = "최종보상: %s - 마법부여 가능";				-- bonus info for librams
	VENDOR_LOCATION_FORMAT = "%s (%s)";						-- format for showing vendor name and location
	
-- notes for other items
	DARKMOON = "다크문상품권 교환용";
	
-- notes for vendors with special availability
	SEASONAL_VENDOR = "(계절 임시상인)";
	SCHOLO_QUEST = "카엘다로우 영원정수 착용 필요";
	
-- notes for items only available once you have a certain reputation standing
	THORIUM_FRIENDLY = "토륨대장조합 평판필요 - "..FACTION_STANDING_LABEL5;
	THORIUM_HONORED = "토륨대장조합 평판필요 - "..FACTION_STANDING_LABEL6;
	THORIUM_REVERED = "토륨대장조합 평판필요 - "..FACTION_STANDING_LABEL7;
	THORIUM_EXALTED = "토륨대장조합 평판필요 - "..FACTION_STANDING_LABEL8;

	TIMBERMAW_FRIENDLY = "나무구렁펄볼그 평판필요 - "..FACTION_STANDING_LABEL5;

-- localized zone names (only those that differ from the enUS version should be present)
	SP_Localized["Alterac Mountains"] = "알터랙 산맥";
	SP_Localized["Arathi Highlands"] = "아라시 고원";
	SP_Localized["Ashenvale"] = "잿빛 골짜기";
	SP_Localized["Azshara"] = "아즈샤라";
	SP_Localized["Badlands"] = "황야의 땅";
	SP_Localized["Blackrock Depths"] = "검은바위 나락";
	SP_Localized["Blasted Lands"] = "저주받은 땅";
	SP_Localized["Burning Steppes"] = "이글거리는 협곡";
	SP_Localized["Darkshore"] = "어둠의 해안";
	SP_Localized["Darnassus"] = "다르나서스";
	SP_Localized["Desolace"] = "잊혀진 땅";
	SP_Localized["Dire Maul"] = "혈투의 전장";
	SP_Localized["Dun Morogh"] = "던 모로";
	SP_Localized["Durotar"] = "듀로타";
	SP_Localized["Duskwood"] = "그늘숲";
	SP_Localized["Eastern Plaguelands"] = "동부 역병지대";
	SP_Localized["Elwynn Forest"] = "엘윈숲";
	SP_Localized["Felwood"] = "악령의 숲";
	SP_Localized["Feralas"] = "페랄라스";
	SP_Localized["Gnomeregan"] = "놈리건";
	SP_Localized["Hillsbrad Foothills"] = "힐스브래드 구릉지";
	SP_Localized["Ironforge"] = "아이언포지";
	SP_Localized["Loch Modan"] = "모단 호수";
	SP_Localized["Moonglade"] = "달의 숲";
	SP_Localized["Mulgore"] = "멀고어";
	SP_Localized["Orgrimmar"] = "오그리마";
	SP_Localized["Redridge Mountains"] = "붉은마루 산맥";
	SP_Localized["Silithus"] = "실리더스";
	SP_Localized["Silverpine Forest"] = "은빛 소나무숲";
	SP_Localized["Stonetalon Mountains"] = "돌발톱 산맥";
	SP_Localized["Stormwind City"] = "스톰윈드";
	SP_Localized["Stranglethorn Vale"] = "가시덤불 골짜기";
	SP_Localized["Swamp of Sorrows"] = "슬픔의 늪";
	SP_Localized["Tanaris"] = "타나리스";
	SP_Localized["Teldrassil"] = "텔드랏실";
	SP_Localized["The Barrens"] = "불모의 땅";
	SP_Localized["The Hinterlands"] = "동부 내륙지";
	SP_Localized["Thousand Needles"] = "버섯구름 봉우리";
	SP_Localized["Thunder Bluff"] = "썬더 블러프";
	SP_Localized["Tirisfal Glades"] = "티리스팔 숲";
	SP_Localized["Un'Goro Crater"] = "운고로 분화구";
	SP_Localized["Undercity"] = "언더시티";
	SP_Localized["Wailing Caverns"] = "통곡의 동굴";
	SP_Localized["Western Plaguelands"] = "서부 역병지대";
	SP_Localized["Westfall"] = "서부 몰락지대";
	SP_Localized["Wetlands"] = "저습지";

-- localized NPC names (only those that differ from the enUS version should be present)
	SP_Localized["Abigail Shiel"] = "애비게일 시엘";
	SP_Localized["Alchemist Pestlezugg"] = "연금술사 페슬저그";
	SP_Localized["Alexandra Bolero"] = "알렉산드라 볼레로";
	SP_Localized["Algernon"] = "알게르논";
	SP_Localized["Amy Davenport"] = "트에이미 데이븐포";
	SP_Localized["Andrew Hilbert"] = "앤드류 힐버트";
	SP_Localized["Androd Fadran"] = "안드로드 패드랜";
	SP_Localized["Argent Quartermaster Hasana"] = "은빛병참장교 하사나";
	SP_Localized["Argent Quartermaster Lightspark"] = "은빛병참장교 라이트스파크";
	SP_Localized["Balai Lok'Wein"] = "발라이 로크웨인";
	SP_Localized["Bale"] = "베일";
	SP_Localized["Banalash"] = "바나래쉬";
	SP_Localized["Blimo Gadgetspring"] = "블리모 가젯스프링";
	SP_Localized["Blixrez Goodstitch"] = "블릭스레즈 굿스티치";
	SP_Localized["Bliztik"] = "블리즈틱";
	SP_Localized["Bombus Finespindle"] = "봄부스 파인스핀들";
	SP_Localized["Borya"] = "보르야";
	SP_Localized["Brienna Starglow"] = "브리에나 스타글로";
	SP_Localized["Bro'kin"] = "브로킨";
	SP_Localized["Bronk"] = "브론크";
	SP_Localized["Catherine Leland"] = "캐서린 릴랜드";
	SP_Localized["Christoph Jeffcoat"] = "크리스토프 제프코트";
	SP_Localized["Clyde Ranthal"] = "클라이드 랜덜";
	SP_Localized["Constance Brisboise"] = "콘스턴스 브리스부아즈";
	SP_Localized["Corporal Bluth"] = "하사관 블루스";
	SP_Localized["Cowardly Crosby"] = "겁쟁이 크로스비";
	SP_Localized["Crazk Sparks"] = "크라즈크 스팍스";
	SP_Localized["Dalria"] = "달리아";
	SP_Localized["Daniel Bartlett"] = "다니엘 바틀렛";
	SP_Localized["Danielle Zipstitch"] = "다니엘 집스티치";
	SP_Localized["Darian Singh"] = "다리안 싱그";
	SP_Localized["Darnall"] = "다르날";
	SP_Localized["Defias Profiteer"] = "데피아즈단 악덕업자";
	SP_Localized["Deneb Walker"] = "데네브 워커";
	SP_Localized["Derak Nightfall"] = "데락 나이트폴";
	SP_Localized["Dirge Quikcleave"] = "더지 퀵클레이브";
	SP_Localized["Drac Roughcut"] = "드락 러프컷";
	SP_Localized["Drake Lindgren"] = "드레이크 린드그렌";
	SP_Localized["Drovnar Strongbrew"] = "드로브나르 스트롱브루";
	SP_Localized["Dustwallow Marsh"] = "먼지진흙 습지대";
	SP_Localized["Elynna"] = "엘리나";
	SP_Localized["Evie Whirlbrew"] = "에비 휠브루";
	SP_Localized["Fradd Swiftgear"] = "프래드 스위프트기어";
	SP_Localized["Gagsprocket"] = "객스프로켓";
	SP_Localized["Gearcutter Cogspinner"] = "기어커터 코그스피너";
	SP_Localized["George Candarte"] = "민간인 조지 칸다테";
	SP_Localized["Gharash"] = "가라쉬";
	SP_Localized["Ghok'kah"] = "그호카";
	SP_Localized["Gigget Zipcoil"] = "기젯 집코일";
	SP_Localized["Gikkix"] = "긱킥스";
	SP_Localized["Gina MacGregor"] = "지나 맥그레거";
	SP_Localized["Glyx Brewright"] = "글릭스 브루라이트";
	SP_Localized["Gnaz Blunderflame"] = "그나즈 블런더플레임";
	SP_Localized["Gretta Ganter"] = "그레타 간터";
	SP_Localized["Grimtak"] = "그림탁";
	SP_Localized["Hagrus"] = "하그루스";
	SP_Localized["Hammon Karwn"] = "하몬 카른";
	SP_Localized["Harggan"] = "하르간";
	SP_Localized["Harklan Moongrove"] = "하클란 문그로브";
	SP_Localized["Harlown Darkweave"] = "하론 다크위브";
	SP_Localized["Harn Longcast"] = "한 롱캐스트 ";
	SP_Localized["Heldan Galesong"] = "헬단 게일송";
	SP_Localized["Helenia Olden"] = "헬레니아 올든";
	SP_Localized["Himmik"] = "힘믹";
	SP_Localized["Hula'mahi"] = "훌라마히";
	SP_Localized["Jabbey"] = "재비";
	SP_Localized["Jandia"] = "잔디아";
	SP_Localized["Janet Hommers"] = "자넷 호머스";
	SP_Localized["Jangdor Swiftstrider"] = "장도르 스위프트스트라이더";
	SP_Localized["Jannos Ironwill"] = "야노스 아이언윌";
	SP_Localized["Jaquilina Dramet"] = "자킬리나 드라메트";
	SP_Localized["Jase Farlane"] = "제이스 파레인";
	SP_Localized["Jazzrik"] = "자즈릭";
	SP_Localized["Jeeda"] = "지다";
	SP_Localized["Jennabink Powerseam"] = "제나빙크 파워심";
	SP_Localized["Jessara Cordell"] = "예사라 코르델";
	SP_Localized["Jinky Twizzlefixxit"] = "진키 트위즐픽시트";
	SP_Localized["Joseph Moore"] = "조셉 무어";
	SP_Localized["Jubie Gadgetspring"] = "주비 가젯스프링";
	SP_Localized["Jun'ha"] = "준하";
	SP_Localized["Jutak"] = "주타크";
	SP_Localized["Kaita Deepforge"] = "카이타 딥포지";
	SP_Localized["Kalldan Felmoon"] = "칼단 펠문";
	SP_Localized["Keena"] = "키나";
	SP_Localized["Kelsey Yance"] = "켈시 얀스";
	SP_Localized["Kendor Kabonka"] = "켄로드 카본카";
	SP_Localized["Khara Deepwater"] = "카라 딥워터";
	SP_Localized["Kiknikle"] = "킥니클";
	SP_Localized["Killian Sanatha"] = "킬리안 사나타";
	SP_Localized["Kilxx"] = "킬륵스";
	SP_Localized["Kireena"] = "키리나";
	SP_Localized["Kithas"] = "키타스";
	SP_Localized["Knaz Blunderflame"] = "크나즈 블런더플레임";
	SP_Localized["Kor'geld"] = "코르겔드";
	SP_Localized["Kriggon Talsone"] = "크리곤 달손";
	SP_Localized["Krinkle Goodsteel"] = "크린클 굿스틸";
	SP_Localized["Kulwia"] = "쿨위아";
	SP_Localized["Kzixx"] = "크직스";
	SP_Localized["Laird"] = "레어드";
	SP_Localized["Lardan"] = "라르단";
	SP_Localized["Leo Sarn"] = "레오 사른";
	SP_Localized["Leonard Porter"] = "레오나드 포터";
	SP_Localized["Lilly"] = "릴리";
	SP_Localized["Lindea Rabonne"] = "린디아 라본느";
	SP_Localized["Lizbeth Cromwell"] = "리즈베스 크롬웰";
	SP_Localized["Logannas"] = "로간나스";
	SP_Localized["Lokhtos Darkbargainer"] = "로크토스 아크바게이너";
	SP_Localized["Lorekeeper Lydros"] = "현자 리드로스";
	SP_Localized["Lorelae Wintersong"] = "로렐라이 윈터송";
	SP_Localized["Magnus Frostwake"] = "마그누스 프로스트웨이크";
	SP_Localized["Mahu"] = "마후";
	SP_Localized["Mallen Swain"] = "말렌스웨인";
	SP_Localized["Malygen"] = "말리젠";
	SP_Localized["Maria Lumere"] = "마리아 루메르";
	SP_Localized["Martine Tramblay"] = "마틴 트램블레이";
	SP_Localized["Masat T'andr"] = "마사트 탄드르";
	SP_Localized["Mathredis Firestar"] = "마스레디스 파이어스타";
	SP_Localized["Mavralyn"] = "마브라린";
	SP_Localized["Mazk Snipeshot"] = "마즈크 스나이프샷";
	SP_Localized["Meilosh"] = "메일로쉬";
	SP_Localized["Micha Yance"] = "미카 얀스";
	SP_Localized["Millie Gregorian"] = "밀리 그레고리안";
	SP_Localized["Montarr"] = "몬타르";
	SP_Localized["Muuran"] = "무란";
	SP_Localized["Mythrin'dir"] = "미스린디르";
	SP_Localized["Naal Mistrunner"] = "나알 미스트러너";
	SP_Localized["Namdo Bizzfizzle"] = "남도 비즈피즐";
	SP_Localized["Nandar Branson"] = "난다르 브랜슨";
	SP_Localized["Narj Deepslice"] = "나르 딥슬라이스";
	SP_Localized["Narkk"] = "나르크";
	SP_Localized["Nata Dawnstrider"] = "나타 던스트라이더";
	SP_Localized["Nergal"] = "네르갈";
	SP_Localized["Nerrist"] = "네리스트";
	SP_Localized["Nessa Shadowsong"] = "네사 섀도송";
	SP_Localized["Nina Lightbrew"] = "니나 라이트브루";
	SP_Localized["Nioma"] = "니오마";
	SP_Localized["Nyoma"] = "니오마";
	SP_Localized["Ogg'marr"] = "오그마르";
	SP_Localized["Old Man Heming"] = "노인 헤밍";
	SP_Localized["Outfitter Eric"] = "제단사 에릭";
	SP_Localized["Plugger Spazzring"] = "플러거 스파즈링";
	SP_Localized["Pratt McGrubben"] = "프랫 맥그루벤";
	SP_Localized["Qia"] = "퀴아";
	SP_Localized["Quartermaster Miranda Breechlock"] = "병참장교 미란다 브리치락";
	SP_Localized["Ranik"] = "래니크";
	SP_Localized["Rann Flamespinner"] = "랜 플레임스피너";
	SP_Localized["Rartar"] = "라르타르";
	SP_Localized["Rikqiz"] = "릭키즈";
	SP_Localized["Rin'wosho the Trader"] = "상인 린워쇼";
	SP_Localized["Rizz Loosebolt"] = "리즈 루즈볼트";
	SP_Localized["Ronald Burch"] = "로널드 버치";
	SP_Localized["Ruppo Zipcoil"] = "루포 집코일";
	SP_Localized["Saenorion"] = "새노리온";
	SP_Localized["Sewa Mistrunner"] = "세와 미스트러너";
	SP_Localized["Shandrina"] = "샨드리나";
	SP_Localized["Shankys"] = "샨키스";
	SP_Localized["Sheendra Tallgrass"] = "신드라 톨그래스";
	SP_Localized["Shen'dralar Provisioner"] = "셴드랄라 고대인";
	SP_Localized["Sheri Zipstitch"] = "셰리 집스티치";
	SP_Localized["Soolie Berryfizz"] = "술리 배리피즈";
	SP_Localized["Sovik"] = "소빅";
	SP_Localized["Stuart Fleming"] = "스튜어트 플레밍";
	SP_Localized["Sumi"] = "수미";
	SP_Localized["Super-Seller 680"] = "슈퍼 판매기 680";
	SP_Localized["Tamar"] = "타마르";
	SP_Localized["Tansy Puddlefizz"] = "탄지 퍼들피즈";
	SP_Localized["Tari'qa"] = "타리카";
	SP_Localized["Thaddeus Webb"] = "타데우스 웨브";
	SP_Localized["Tharynn Bouden"] = "타린 바우던";
	SP_Localized["Tilli Thistlefuzz"] = "틸리 시슬퍼즈";
	SP_Localized["Truk Wildbeard"] = "트루크 와일드바이드";
	SP_Localized["Tunkk"] = "텅크";
	SP_Localized["Ulthaan"] = "울샨";
	SP_Localized["Ulthir"] = "울시르";
	SP_Localized["Uthok"] = "우톡";
	SP_Localized["Vaean"] = "바이안";
	SP_Localized["Valdaron"] = "발다론";
	SP_Localized["Veenix"] = "비닉스";
	SP_Localized["Vendor-Tron 1000"] = "자동 판매기 1000";
	SP_Localized["Vharr"] = "바르";
	SP_Localized["Vivianna"] = "비비안나";
	SP_Localized["Vizzklick"] = "비즈클릭";
	SP_Localized["Wenna Silkbeard"] = "웨나 실크비어드";
	SP_Localized["Werg Thickblade"] = "웨르그 틱블레이드";
	SP_Localized["Wik'Tar"] = "위크타르";
	SP_Localized["Winterspring"] = "여명의 설원";
	SP_Localized["Worb Strongstitch"] = "워브 스트롱스티치";
	SP_Localized["Wrahk"] = "레이크";
	SP_Localized["Wulan"] = "울란";
	SP_Localized["Wunna Darkmane"] = "우나 다크메인";
	SP_Localized["Xandar Goodbeard"] = "샨다르 굿비어드";
	SP_Localized["Xizk Goodstitch"] = "시즈크 굿스티치";
	SP_Localized["Xizzer Fizzbolt"] = "시저 피즈볼트";
	SP_Localized["Yonada"] = "요나다";
	SP_Localized["Yuka Screwspigot"] = "유카 스크류스피곳";
	SP_Localized["Zan Shivsproket"] = "잰 쉬브스프로켓";
	SP_Localized["Zannok Hidepiercer"] = "잔노크 하이드피이서";
	SP_Localized["Zansoa"] = "잔소아";
	SP_Localized["Zarena Cromwind"] = "자레나 크롬윈드";
	SP_Localized["Zargh"] = "자르그";
	SP_Localized["Zixil"] = "직실";

-- localized libram descriptions
	SP_Localized["+8 any single stat"] = "+8 원하는 스탯 한가지";
	SP_Localized["+100 Health"] = "+100 생명력";
	SP_Localized["+150 Mana"] = "+150 마나";
	SP_Localized["+20 Fire Resistance"] = "+20 화염저항";
	SP_Localized["+125 Armor"] = "+125 방어도";
	SP_Localized["+1% Haste"] = "+1% 공격속도";
	SP_Localized["+1% Dodge"] = "+1% 회피율";
	SP_Localized["+8 Spell damage/healing"] = "+8 치유 효과와 주문의 피해";

-- localized special raid loot tokens
	SP_Localized["Zulian Coin"]		=	"줄리안부족 주화";
	SP_Localized["Razzashi Coin"]		=	"래즈자쉬부족 주화";
	SP_Localized["Hakkari Coin"]		=	"학카리부족 주화";
	SP_Localized["Gurubashi Coin"]		=	"구루바시부족 주화";
	SP_Localized["Vilebranch Coin"]	=	"썩은가지부족 주화";
	SP_Localized["Witherbark Coin"]	=	"마른나무껍질부족 주화";
	SP_Localized["Sandfury Coin"]		=	"성난모래부족 주화";
	SP_Localized["Skullsplitter Coin"]	=	"백골가루부족 주화";
	SP_Localized["Bloodscalp Coin"]	=	"붉은머리부족 주화";
            
	SP_Localized["Red Hakkari Bijou"]		=	"붉은색 학카리 장신구";
	SP_Localized["Blue Hakkari Bijou"]		=	"파란색 학카리 장신구";
	SP_Localized["Yellow Hakkari Bijou"]	=	"노란색 학카리 장신구";
	SP_Localized["Orange Hakkari Bijou"]	=	"주황색 학카리 장신구";
	SP_Localized["Green Hakkari Bijou"]	=	"녹색 학카리 장신구";
	SP_Localized["Purple Hakkari Bijou"]	=	"보라색 학카리 장신구";
	SP_Localized["Bronze Hakkari Bijou"]	=	"청동색 학카리 장신구";
	SP_Localized["Silver Hakkari Bijou"]	=	"은색 학카리 장신구";
	SP_Localized["Gold Hakkari Bijou"]		=	"황금색 학카리 장신구";
            
	SP_Localized["Primal Hakkari Bindings"]	=	"고대 학카리 팔보호구";
	SP_Localized["Primal Hakkari Armsplint"]	=	"고대 학카리 어깨갑옷";
	SP_Localized["Primal Hakkari Stanchion"]	=	"고대 학카리 손목갑옷";
	SP_Localized["Primal Hakkari Girdle"]		=	"고대 학카리 벨트";
	SP_Localized["Primal Hakkari Sash"]		=	"고대 학카리 장식띠";
	SP_Localized["Primal Hakkari Shawl"]		=	"고대 학카리 어깨걸이";
	SP_Localized["Primal Hakkari Tabard"]		=	"고대 학카리 휘장";
	SP_Localized["Primal Hakkari Kossack"]		=	"고대 학카리 조끼";
	SP_Localized["Primal Hakkari Aegis"]		=	"고대 학카리 아이기스";
            
	SP_Localized["Qiraji Magisterial Ring"]	=	"권위의 퀴라지 반지";
	SP_Localized["Qiraji Ceremonial Ring"]		=	"의식의 퀴라지 반지";
	SP_Localized["Qiraji Martial Drape"]		=	"전쟁의 퀴라지 망토";
--	SP_Localized["Qiraji Regal Drape"]			=	"xxxxx";
	SP_Localized["Qiraji Spiked Hilt"]			=	"못박힌 퀴라지 자루";
	SP_Localized["Qiraji Ornate Hilt"]			=	"화려한 퀴라지 자루";
            
	SP_Localized["Imperial Qiraji Armaments"]	=	"제국의 퀴라지 무기";
--	SP_Localized["Imperial Qiraji Regalia"]	=	"xxxxx";
            
	SP_Localized["Qiraji Bindings of Command"]		=	"지휘의 퀴라지 팔보호구";
--	SP_Localized["Qiraji Bindings of Dominance"]	=	"xxxxx";
	SP_Localized["Ouro's Intact Hide"]				=	"온전한 아우로의 가죽";
--	SP_Localized["Skin of the Great Sandworm"]		=	"xxxxx";
--	SP_Localized["Vek'lor's Diadem"]				=	"xxxxx";
	SP_Localized["Vek'nilash's Circlet"]			=	"베크닐라쉬의 관";
--	SP_Localized["Carapace of the Old God"]		=	"xxxxx";
--	SP_Localized["Husk of the Old God"]			=	"xxxxx";
            
	SP_Localized["Stone Scarab"]	=	"돌 스카라베";
	SP_Localized["Gold Scarab"]	=	"황금 스카라베";
	SP_Localized["Silver Scarab"]	=	"은 스카라베";
	SP_Localized["Bronze Scarab"]	=	"청동 스카라베";
	SP_Localized["Crystal Scarab"]	=	"수정 스카라베";
	SP_Localized["Clay Scarab"]	=	"찰흙 스카라베";
	SP_Localized["Bone Scarab"]	=	"뼈 스카라베";
	SP_Localized["Ivory Scarab"]	=	"상아 스카라베";
            
	SP_Localized["Azure Idol"]			=	"청금석 우상";
	SP_Localized["Onyx Idol"]			=	"마노 우상";
	SP_Localized["Lambent Idol"]		=	"미명석 우상";
	SP_Localized["Amber Idol"]			=	"호박석 우상";
	SP_Localized["Jasper Idol"]		=	"벽옥 우상";
	SP_Localized["Obsidian Idol"]		=	"흑요석 우상";
	SP_Localized["Vermillion Idol"]	=	"단사 우상";
	SP_Localized["Alabaster Idol"]		=	"설화석 우상";
            
	SP_Localized["Idol of the Sun"]	=	"태양의 우상";
	SP_Localized["Idol of Night"]		=	"밤의 우상";
	SP_Localized["Idol of Death"]		=	"죽음의 우상";
	SP_Localized["Idol of the Sage"]	=	"현자의 우상";
	SP_Localized["Idol of Rebirth"]	=	"환생의 우상";
--	SP_Localized["Idol of Life"]		=	"xxxxx";
--	SP_Localized["Idol of Strife"]		=	"xxxxx";
	SP_Localized["Idol of War"]		=	"전쟁의 우상";

end

if ( GetLocale() == "frFR" ) then

-- localized special raid loot tokens
	SP_Localized["Zulian Coin"]		=	"Pièce zulienne";
	SP_Localized["Razzashi Coin"]		=	"Pièce Razzashi";
	SP_Localized["Hakkari Coin"]		=	"Pièce hakkari";
	SP_Localized["Gurubashi Coin"]		=	"Pièce Gurubashi";
	SP_Localized["Vilebranch Coin"]	=	"Pièce Vilebranch";
	SP_Localized["Witherbark Coin"]	=	"Pièce Witherbark";
	SP_Localized["Sandfury Coin"]		=	"Pièce Sandfury";
	SP_Localized["Skullsplitter Coin"]	=	"Pièce Skullsplitter";
	SP_Localized["Bloodscalp Coin"]	=	"Pièce Bloodscalp";
            
	SP_Localized["Red Hakkari Bijou"]		=	"Bijou hakkari rouge";
	SP_Localized["Blue Hakkari Bijou"]		=	"Bijou hakkari bleu";
	SP_Localized["Yellow Hakkari Bijou"]	=	"Bijou hakkari jaune";
	SP_Localized["Orange Hakkari Bijou"]	=	"Bijou hakkari orange";
	SP_Localized["Green Hakkari Bijou"]	=	"Bijou hakkari vert";
	SP_Localized["Purple Hakkari Bijou"]	=	"Bijou hakkari violet";
	SP_Localized["Bronze Hakkari Bijou"]	=	"Bijou hakkari bronze";
	SP_Localized["Silver Hakkari Bijou"]	=	"Bijou hakkari argenté";
	SP_Localized["Gold Hakkari Bijou"]		=	"Bijou hakkari doré";
            
	SP_Localized["Primal Hakkari Bindings"]	=	"Manchettes primordiales hakkari";
	SP_Localized["Primal Hakkari Armsplint"]	=	"Brassards primordiaux hakkari";
	SP_Localized["Primal Hakkari Stanchion"]	=	"Etançon primordial hakkari";
	SP_Localized["Primal Hakkari Girdle"]		=	"Ceinturon primordial hakkari";
	SP_Localized["Primal Hakkari Sash"]		=	"Echarpe primordiale hakkari";
	SP_Localized["Primal Hakkari Shawl"]		=	"Châle primordial hakkari";
	SP_Localized["Primal Hakkari Tabard"]		=	"Tabard primordial hakkari";
	SP_Localized["Primal Hakkari Kossack"]		=	"Casaque primordiale hakkari";
	SP_Localized["Primal Hakkari Aegis"]		=	"Egide primordiale hakkari";
            
	SP_Localized["Qiraji Magisterial Ring"]	=	"Anneau de magistrat qiraji";
	SP_Localized["Qiraji Ceremonial Ring"]		=	"Anneau de cérémonie qiraji";
	SP_Localized["Qiraji Martial Drape"]		=	"Drapé martial qiraji";
	SP_Localized["Qiraji Regal Drape"]			=	"Drapé royal qiraji";
	SP_Localized["Qiraji Spiked Hilt"]			=	"Drapé royal qiraji";
	SP_Localized["Qiraji Ornate Hilt"]			=	"Manche orné";
            
	SP_Localized["Imperial Qiraji Armaments"]	=	"Armes impériales qiraji";
	SP_Localized["Imperial Qiraji Regalia"]	=	"Tenue de parade impériale qiraji";
            
	SP_Localized["Qiraji Bindings of Command"]		=	"Manchettes de commandement qiraji";
	SP_Localized["Qiraji Bindings of Dominance"]	=	"Manchettes de domination qiraji";
	SP_Localized["Ouro's Intact Hide"]				=	"Peau intacte d'Ouro";
	SP_Localized["Skin of the Great Sandworm"]		=	"Peau du Grand ver des sables";
	SP_Localized["Vek'lor's Diadem"]				=	"Diadème de Vek'lor";
	SP_Localized["Vek'nilash's Circlet"]			=	"Diadème de Vek'nilash";
	SP_Localized["Carapace of the Old God"]		=	"Carapace du Dieu très ancien";
	SP_Localized["Husk of the Old God"]			=	"Carcasse du Dieu très ancien";
            
	SP_Localized["Stone Scarab"]	=	"Scarabée de pierre";
	SP_Localized["Gold Scarab"]	=	"Scarabée d'or";
	SP_Localized["Silver Scarab"]	=	"Scarabée d'argent";
	SP_Localized["Bronze Scarab"]	=	"Scarabée de bronze";
	SP_Localized["Crystal Scarab"]	=	"Scarabée de cristal";
	SP_Localized["Clay Scarab"]	=	"Scarabée d'argile";
	SP_Localized["Bone Scarab"]	=	"Scarabée d'os";
	SP_Localized["Ivory Scarab"]	=	"Scarabée d'ivoire";
            
	SP_Localized["Azure Idol"]			=	"Idole azur";
	SP_Localized["Onyx Idol"]			=	"Idole d'onyx";
	SP_Localized["Lambent Idol"]		=	"Idole brillante";
	SP_Localized["Amber Idol"]			=	"Idole d'ambre";
	SP_Localized["Jasper Idol"]		=	"Idole de jaspe";
	SP_Localized["Obsidian Idol"]		=	"Idole d'obsidienne";
	SP_Localized["Vermillion Idol"]	=	"Idole vermillon";
	SP_Localized["Alabaster Idol"]		=	"Idole d'albâtre";
            
	SP_Localized["Idol of the Sun"]	=	"Idole du soleil";
	SP_Localized["Idol of Night"]		=	"Idole de la nuit";
	SP_Localized["Idol of Death"]		=	"Idole de la mort";
	SP_Localized["Idol of the Sage"]	=	"Idole du sage";
	SP_Localized["Idol of Rebirth"]	=	"Idole de la renaissance";
	SP_Localized["Idol of Life"]		=	"Idole de la vie";
	SP_Localized["Idol of Strife"]		=	"Idole de la lutte";
	SP_Localized["Idol of War"]		=	"Idole de la guerre";

end
