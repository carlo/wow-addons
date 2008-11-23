------------------------------------------------------
-- SwindlerPreventer_Vendors.lua
-- Originally based on the tables at http://members.cox.net/katy-w/Trades/Home.htm
-- Corrected / extended with info from http://wow.allakhazam.com and http://wowguru.com
------------------------------------------------------
-- LOCALIZATION NOTE: the english recipe names in here are just comments;
--  it won't do anything in-game if you translate them.
------------------------------------------------------

SP_VendorLocations = {
-- not actually splitting this up by faction, but I've got it sorted that way in case I decide to later.
-- Bag Vendors
		["Haris Pilton"] = "Shattrath City",
		["Caregiver Ophera Windfury"] = "Hellfire Peninsula",
		["Fabian Lanzonelli"] = "Terokkar Forest",
		["Alyssa Griffith"] = "Stormwind City",
		["Cuzi"] = "The Exodar",
		["Eral"] = "Shattrath City",
		["Gotri"] = "Orgrimmar",
		["Jonathan Chambers"] = "Undercity",
		["Pakwa"] = "Thunder Bluff",
		["Pithwick"] = "Ironforge",
		["Rathin"] = "Silvermoon City",
		["Yldan"] = "Darnassus",
		["Botanist Tyniarrel"] = "Eversong Woods",
		["Chardryn"] = "Darnassus",
		["Eldraeith"] = "Stormwind City",
		["Gwina Stonebranch"] = "Ironforge",
		["Katrina Alliestar"] = "Undercity",
		["Selina Weston"] = "Tirisfal Glades",
		["Uma Bartulm"] = "Dustwallow Marsh",
		["Zeal'aya"] = "Orgrimmar",
		["Stanly McCormick"] = "Stormwind City",
		["Burkrum"] = "Ashenvale",
		["Kaja"] = "Orgrimmar",
		["Mathaleron"] = "Silvermoon City",
		["Hogor Thunderhoof"] = "Thunder Bluff",
		["Nicholas Atwood"] = "Undercity",
		["Bretta Goldfury"] = "Ironforge",
		["Thulman Flintcrag"] = "Stormwind City",
		["Muhaa"] = "The Exodar",
		["Avelii"] = "The Exodar",
		["Beega"] = "Bloodmyst Isle",
		["Marda Weller"] = "Stormwind City",
		["Mura"] = "Azuremyst Isle",
		["Thalgus Thunderfist"] = "Ironforge",
		["Benijah Fenner"] = "Undercity",
		["Landria"] = "Darnassus",
		["Skolmin Goldfury"] = "Ironforge",
		["Frederick Stover"] = "Stormwind City",
		["Jin'sora"] = "Orgrimmar",
		["Celana"] = "Silvermoon City",
		["Kuna Thunderhorn"] = "Thunder Bluff",
		["Abigail Sawyer"] = "Undercity",
		["Ellandrieth"] = "Darnassus",
		["Ariyell Skyshadow"] = "Darnassus",
		["Trak'gen"] = "Orgrimmar",
		["Xantili"] = "Orgrimmar",
		["Onnis"] = "The Exodar",
		["Logan Daniel"] = "Azuremyst Isle",

-- Vanity Pet Vendors
		["Magus Tirth"] = "Thousand Needles",
		["Dealer Rashaad"] = "Netherstorm",
		["Xan'tish"] = "Orgrimmar",
		["Halpa"] = "Thunder Bluff",
		["Jeremiah Payson"] = "Undercity",
		["Jilanne"] = "Eversong Woods",
		["Sixx"] = "The Exodar",
		["Donni Anthania"] = "Elwynn Forest",
		["Yarlyn Amberstill"] = "Dun Morogh",
		["Lil Timmy"] = "Stormwind City",
		
--Recipe Vendors added by Thortok2000
		["Haughty Modiste"] = "Tanaris",
		["Shaani"] = "Isle of Quel'Danas",
		["Ainderu Summerleaf"] = "Dalaran",
		["Lalla Brightweave"] = "Dalaran",
		["Ildine Sorrowspear"] = "Dalaran",
		["Tiffany Cartier"] = "Dalaran",
		["Larana Drome"] = "Dalaran",
		["Linna Bruder"] = "Dalaran",
		["Derek Odds"] = "Dalaran",
		["Braeg Stoutbeard"] = "Dalaran",
		["Vanessa Sellers"] = "Dalaran",
		["Archmage Alvareaux"] = "Dalaran",

--Alliance
		["Alexandra Bolero"] = "Stormwind City",
		["Amy Davenport"] = "Redridge Mountains",
		["Androd Fadran"] = "Arathi Highlands",
		["Blimo Gadgetspring"] = "Azshara",
		["Bombus Finespindle"] = "Ironforge",
		["Brienna Starglow"] = "Feralas",
		["Burbik Gearspanner"] = "Ironforge",
		["Catherine Leland"] = "Stormwind City",
		["Clyde Ranthal"] = "Redridge Mountains",
		["Corporal Bluth"] = "Stranglethorn Vale",
		["Dalria"] = "Ashenvale",
		["Danielle Zipstitch"] = "Duskwood",
		["Darian Singh"] = "Stormwind City",
		["Defias Profiteer"] = "Westfall",
		["Deneb Walker"] = "Arathi Highlands",
		["Drac Roughcut"] = "Loch Modan",
		["Drake Lindgren"] = "Elwynn Forest",
		["Drovnar Strongbrew"] = "Arathi Highlands",
		["Edna Mullby"] = "Stormwind City",
		["Elynna"] = "Darnassus",
		["Emrul Riknussun"] = "Ironforge",
		["Erika Tate"] = "Stormwind City",
		["Fradd Swiftgear"] = "Wetlands",
		["Fyldan"] = "Darnassus",
		["Gearcutter Cogspinner"] = "Ironforge",
		["Gigget Zipcoil"] = "The Hinterlands",
		["Gina MacGregor"] = "Westfall",
		["Gloria Femmel"] = "Redridge Mountains",
		["Gretta Ganter"] = "Dun Morogh",
		["Hammon Karwn"] = "Arathi Highlands",
		["Harggan"] = "The Hinterlands",
		["Harklan Moongrove"] = "Ashenvale",
		["Harlown Darkweave"] = "Ashenvale",
		["Heldan Galesong"] = "Darkshore",
		["Helenia Olden"] = "Dustwallow Marsh",
		["Janet Hommers"] = "Desolace",
		["Jannos Ironwill"] = "Arathi Highlands",
		["Jennabink Powerseam"] = "Wetlands",
		["Jessara Cordell"] = "Stormwind City",
		["Jubie Gadgetspring"] = "Azshara",
		["Kaita Deepforge"] = "Stormwind City",
		["Kendor Kabonka"] = "Stormwind City",
		["Khara Deepwater"] = "Loch Modan",
		["Khole Jinglepocket"] = "Stormwind City",
		["Kriggon Talsone"] = "Westfall",
		["Laird"] = "Darkshore",
		["Lardan"] = "Ashenvale",
		["Leonard Porter"] = "Western Plaguelands",
		["Lindea Rabonne"] = "Hillsbrad Foothills",
		["Logannas"] = "Feralas",
		["Malygen"] = "Felwood",
		["Maria Lumere"] = "Stormwind City",
		["Mavralyn"] = "Darkshore",
		["Micha Yance"] = "Hillsbrad Foothills",
		["Mythrin'dir"] = "Darnassus",
		["Namdo Bizzfizzle"] = "Gnomeregan",
		["Nandar Branson"] = "Hillsbrad Foothills",
		["Narj Deepslice"] = "Arathi Highlands",
		["Neal Allen"] = "Wetlands",
		["Nessa Shadowsong"] = "Teldrassil",
		["Nina Lightbrew"] = "Blasted Lands",
		["Nioma"] = "The Hinterlands",
		["Nyoma"] = "Teldrassil",
		["Outfitter Eric"] = "Ironforge",
		["Pratt McGrubben"] = "Feralas",
		["Rann Flamespinner"] = "Loch Modan",
		["Rann Flamespinner"] = "Loch Modan",
		["Ruppo Zipcoil"] = "The Hinterlands",
		["Saenorion"] = "Darnassus",
		["Shandrina"] = "Ashenvale",
		["Sheri Zipstitch"] = "Duskwood",
		["Shylenai"] = "Darnassus",
		["Soolie Berryfizz"] = "Ironforge",
		["Stuart Fleming"] = "Wetlands",
		["Tansy Puddlefizz"] = "Ironforge",
		["Tharynn Bouden"] = "Elwynn Forest",
		["Tilli Thistlefuzz"] = "Ironforge",
		["Truk Wildbeard"] = "The Hinterlands",
		["Ulthaan"] = "Ashenvale",
		["Ulthir"] = "Darnassus",
		["Vaean"] = "Darkshore",
		["Valdaron"] = "Darkshore",
		["Vivianna"] = "Feralas",
		["Wenna Silkbeard"] = "Wetlands",
		["Wulmort Jinglepocket"] = "Ironforge",
		["Xandar Goodbeard"] = "Loch Modan",
		
		["Arred"] = "The Exodar",
-- Horde
		["Abigail Shiel"] = "Tirisfal Glades",
		["Algernon"] = "Undercity",
		["Andrew Hilbert"] = "Silverpine Forest",
		["Balai Lok'Wein"] = "Dustwallow Marsh",
		["Bale"] = "Felwood",
		["Banalash"] = "Swamp of Sorrows",
		["Borya"] = "Orgrimmar",
		["Bronk"] = "Feralas",
		["Christoph Jeffcoat"] = "Hillsbrad Foothills",
		["Constance Brisboise"] = "Tirisfal Glades",
		["Daniel Bartlett"] = "Undercity",
		["Derak Nightfall"] = "Hillsbrad Foothills",
		["Felicia Doan"] = "Undercity",
		["Felika"] = "Orgrimmar",
		["George Candarte"] = "Hillsbrad Foothills",
		["Gharash"] = "Swamp of Sorrows",
		["Ghok'kah"] = "Dustwallow Marsh",
		["Grimtak"] = "Durotar",
		["Hagrus"] = "Orgrimmar",
		["Harn Longcast"] = "Mulgore",
		["Hula'mahi"] = "The Barrens",
		["Jandia"] = "Thousand Needles",
		["Jangdor Swiftstrider"] = "Feralas",
		["Jeeda"] = "Stonetalon Mountains",
		["Joseph Moore"] = "Undercity",
		["Jun'ha"] = "Arathi Highlands",
		["Keena"] = "Arathi Highlands",
		["Killian Sanatha"] = "Silverpine Forest",
		["Kireena"] = "Desolace",
		["Kithas"] = "Orgrimmar",
		["Kor'geld"] = "Orgrimmar",
		["Kulwia"] = "Stonetalon Mountains",
		["Leo Sarn"] = "Silverpine Forest",
		["Lilly"] = "Silverpine Forest",
		["Lizbeth Cromwell"] = "Undercity",
		["Mahu"] = "Thunder Bluff",
		["Mallen Swain"] = "Hillsbrad Foothills",
		["Martine Tramblay"] = "Tirisfal Glades",
		["Millie Gregorian"] = "Undercity",
		["Montarr"] = "Thousand Needles",
		["Muuran"] = "Desolace",
		["Naal Mistrunner"] = "Thunder Bluff",
		["Nata Dawnstrider"] = "Thunder Bluff",
		["Nerrist"] = "Stranglethorn Vale",
		["Ogg'marr"] = "Dustwallow Marsh",
		["Otho Moji'ko"] = "The Hinterlands",
		["Penney Copperpinch"] = "Orgrimmar",
		["Rartar"] = "Swamp of Sorrows",
		["Ronald Burch"] = "Undercity",
		["Sewa Mistrunner"] = "Thunder Bluff",
		["Shadi Mistrunner"] = "Thunder Bluff",
		["Shankys"] = "Orgrimmar",
		["Sheendra Tallgrass"] = "Feralas",
		["Sovik"] = "Orgrimmar",
		["Sumi"] = "Orgrimmar",
		["Tamar"] = "Orgrimmar",
		["Tarban Hearthgrain"] = "The Barrens",
		["Tari'qa"] = "The Barrens",
		["Thaddeus Webb"] = "Undercity",
		["Tunkk"] = "Arathi Highlands",
		["Uthok"] = "Stranglethorn Vale",
		["Vharr"] = "Stranglethorn Vale",
		["Werg Thickblade"] = "Tirisfal Glades",
		["Wik'Tar"] = "Ashenvale",
		["Worb Strongstitch"] = "Feralas",
		["Wrahk"] = "The Barrens",
		["Wulan"] = "Desolace",
		["Wunna Darkmane"] = "Mulgore",
		["Xen'to"] = "Orgrimmar",
		["Yonada"] = "The Barrens",
		["Zansoa"] = "Durotar",
		["Zargh"] = "The Barrens",

		["Gelanthis"] = "Silvermoon City",

-- Neutral
		["Aendel Windspear"] = "Silithus",
		["Alchemist Pestlezugg"] = "Tanaris",
		["Argent Quartermaster Hasana"] = "Tirisfal Glades",
		["Argent Quartermaster Lightspark"] = "Western Plaguelands",
		["Blixrez Goodstitch"] = "Stranglethorn Vale",
		["Blizrik Buckshot"] = "Tanaris",
		["Bliztik"] = "Duskwood",
		["Bro'kin"] = "Alterac Mountains",
		["Cowardly Crosby"] = "Stranglethorn Vale",
		["Crazk Sparks"] = "Stranglethorn Vale",
		["Darnall"] = "Moonglade",
		["Dirge Quikcleave"] = "Tanaris",
		["Evie Whirlbrew"] = "Winterspring",
		["Gagsprocket"] = "The Barrens",
		["Gikkix"] = "Tanaris",
		["Glyx Brewright"] = "Stranglethorn Vale",
		["Gnaz Blunderflame"] = "Stranglethorn Vale",
		["Himmik"] = "Winterspring",
		["Jabbey"] = "Tanaris",
		["Jaquilina Dramet"] = "Stranglethorn Vale",
		["Jase Farlane"] = "Eastern Plaguelands",
		["Jazzrik"] = "Badlands",
		["Jinky Twizzlefixxit"] = "Thousand Needles",
		["Jutak"] = "Stranglethorn Vale",
		["Kalldan Felmoon"] = "Wailing Caverns",
		["Kania"] = "Silithus",
		["Kelsey Yance"] = "Stranglethorn Vale",
		["Kiknikle"] = "The Barrens",
		["Kilxx"] = "The Barrens",
		["Knaz Blunderflame"] = "Stranglethorn Vale",
		["Krinkle Goodsteel"] = "Tanaris",
		["Kzixx"] = "Duskwood",
		["Lieutenant General Andorov"] = "Ruins of Ahn'Qiraj",
		["Lokhtos Darkbargainer"] = "Blackrock Depths",
		["Lorelae Wintersong"] = "Moonglade",
		["Magnus Frostwake"] = "Western Plaguelands",
		["Masat T'andr"] = "Swamp of Sorrows",
		["Mazk Snipeshot"] = "Stranglethorn Vale",
		["Meilosh"] = "Felwood",
		["Mishta"] = "Silithus",
		["Narkk"] = "Stranglethorn Vale",
		["Nergal"] = "Un'Goro Crater",
		["Old Man Heming"] = "Stranglethorn Vale",
		["Plugger Spazzring"] = "Blackrock Depths",
		["Qia"] = "Winterspring",
		["Quartermaster Miranda Breechlock"] = "Eastern Plaguelands",
		["Ranik"] = "The Barrens",
		["Rikqiz"] = "Stranglethorn Vale",
		["Rin'wosho the Trader"] = "Stranglethorn Vale",
		["Rizz Loosebolt"] = "Alterac Mountains",
		["Shen'dralar Provisioner"] = "Dire Maul",
		["Smudge Thunderwood"] = "Alterac Mountains",
		["Super-Seller 680"] = "Desolace",
		["Vargus"] = "Silithus",
		["Veenix"] = "Stonetalon Mountains",
		["Vendor-Tron 1000"] = "Desolace",
		["Vizzklick"] = "Tanaris",
		["Xizk Goodstitch"] = "Stranglethorn Vale",
		["Xizzer Fizzbolt"] = "Winterspring",
		["Yuka Screwspigot"] = "Burning Steppes",
		["Zan Shivsproket"] = "Hillsbrad Foothills",
		["Zannok Hidepiercer"] = "Silithus",
		["Zarena Cromwind"] = "Stranglethorn Vale",
		["Zixil"] = "Hillsbrad Foothills",
		["Zorbin Fandazzle"] = "Feralas",
		
-- Libram turnin NPCs
		["Lorekeeper Lydros"] = "Dire Maul",
		["Mathredis Firestar"] = "Burning Steppes",

-- Burning Crusade content (not sorted by faction)
		["Eldara Dawnrunner"] = "Isle of Quel'Danas",
		["Aaron Hollman"] = "Shattrath City",
		["Aged Dalaran Wizard"] = "Old Hillsbrad Foothills",
		["Alchemist Gribble"] = "Hellfire Peninsula",
		["Aldraan"] = "Nagrand",
		["Almaador"] = "Shattrath City",
		["Altaa"] = "The Exodar",
		["Alurmi"] = "Tanaris",
		["Andrion Darkspinner"] = "Shattrath City",
		["Apothecary Antonivich"] = "Hellfire Peninsula",
		["Apprentice Darius"] = "Deadwind Pass",
		["Aresella"] = "Hellfire Peninsula",
		["Arras"] = "The Exodar",
		["Arrond"] = "Shadowmoon Valley",
		["Asarnan"] = "Netherstorm",
		["Baxter"] = "Hellfire Peninsula",
		["Borto"] = "Nagrand",
		["Burko"] = "Hellfire Peninsula",
		["Captured Gnome"] = "Zangarmarsh",
		["Cookie One-Eye"] = "Hellfire Peninsula",
		["Coreiel"] = "Nagrand",
		["Cro Threadstrong"] = "Shattrath City",
		["Daga Ramba"] = "Blade's Edge Mountains",
		["Daggle Ironshaper"] = "Shadowmoon Valley",
		["Dealer Malij"] = "Netherstorm",
		["Deynna"] = "Silvermoon City",
		["Doba"] = "Zangarmarsh",
		["Egomis"] = "The Exodar",
		["Eiin"] = "Shattrath City",
		["Eriden"] = "Silvermoon City",
		["Erilia"] = "Eversong Woods",
		["Fazu"] = "Bloodmyst Isle",
		["Fedryen Swiftspear"] = "Zangarmarsh",
		["Feera"] = "The Exodar",
		["Felannia"] = "Hellfire Peninsula",
		["Gambarinka"] = "Zangarmarsh",
		["Gaston"] = "Hellfire Peninsula",
		["Gidge Spellweaver"] = "Shattrath City",
		["Haalrun"] = "Zangarmarsh",
		["Haferet"] = "The Exodar",
		["Indormi"] = "Hyjal Summit",
		["Innkeeper Biribi"] = "Terokkar Forest",
		["Innkeeper Grilka"] = "Terokkar Forest",
		["Jim Saltit"] = "Shattrath City",
		["Johan Barnes"] = "Hellfire Peninsula",
		["Juno Dufrain"] = "Zangarmarsh",
		["Kalaen"] = "Hellfire Peninsula",
		["Karaaz"] = "Netherstorm",
		["Koren"] = "Karazhan",
		["Krek Cragcrush"] = "Shadowmoon Valley",
		["Landraelanis"] = "Eversong Woods",
		["Lebowski"] = "Hellfire Peninsula",
		["Leeli Longhaggle"] = "Terokkar Forest",
		["Logistics Officer Ulrike"] = "Hellfire Peninsula",
		["Loolruna"] = "Zangarmarsh",
		["Lyna"] = "Silvermoon City",
		["Madame Ruby"] = "Shattrath City",
		["Mari Stonehand"] = "Shadowmoon Valley",
		["Master Chef Mouldier"] = "Ghostlands",
		["Mathar G'ochar"] = "Nagrand",
		["Melaris"] = "Silvermoon City",
		["Mixie Farshot"] = "Hellfire Peninsula",
		["Muheru the Weaver"] = "Zangarmarsh",
		["Mycah"] = "Zangarmarsh",
		["Naka"] = "Zangarmarsh",
		["Nakodu"] = "Shattrath City",
		["Nasmara Moonsong"] = "Shattrath City",
		["Neii"] = "The Exodar",
		["Nula the Butcher"] = "Nagrand",
		["Okuno"] = "Black Temple",
		["Paulsta'ats"] = "Nagrand",
		["Phea"] = "The Exodar",
		["Provisioner Nasela"] = "Nagrand",
		["Quartermaster Davian Vaclav"] = "Nagrand",
		["Quartermaster Endarin"] = "Shattrath City",
		["Quartermaster Enuril"] = "Shattrath City",
		["Quartermaster Jaffrey Noreliqe"] = "Nagrand",
		["Quartermaster Urgronn"] = "Hellfire Peninsula",
		["Quelis"] = "Silvermoon City",
		["Rathis Tomber"] = "Ghostlands",
		["Rohok"] = "Hellfire Peninsula",
		["Rungor"] = "Terokkar Forest",
		["Sassa Weldwell"] = "Blade's Edge Mountains",
		["Seer Janidi"] = "Zangarmarsh",
		["Sid Limbardi"] = "Hellfire Peninsula",
		["Skreah"] = "Shattrath City",
		["Supply Officer Mills"] = "Terokkar Forest",
		["Tatiana"] = "Hellfire Peninsula",
		["Thomas Yance"] = "Old Hillsbrad Foothills",
		["Trader Narasu"] = "Nagrand",
		["Uriku"] = "Nagrand",
		["Viggz Shinesparked"] = "Shattrath City",
		["Vodesiin"] = "Hellfire Peninsula",
		["Wind Trader Lathrai"] = "Shattrath City",
		["Yatheon"] = "Silvermoon City",
		["Ythyar"] = "Karazhan",
		["Yurial Soulwater"] = "Shattrath City",
		["Zaralda"] = "Silvermoon City",
		["Zurai"] = "Zangarmarsh",
		["\"Cookie\" McWeaksauce"] = "Azuremyst Isle",
};

SP_VendorInfo = {
	["Alliance"] = {
	-- Bags
		[39489] = { "Stanly McCormick" },								--Scribe's Satchel
		[30748] = { "Caregiver Ophera Windfury", "Fabian Lanzonelli" },	-- Enchanter's Satchel
		[30747] = { "Caregiver Ophera Windfury", "Fabian Lanzonelli" },	-- Gem Pouch
		[30746] = { "Caregiver Ophera Windfury", "Fabian Lanzonelli" },	-- Mining Sack
		[30745] = { "Caregiver Ophera Windfury", "Fabian Lanzonelli" },	-- Heavy Toolbox
		[30744] = { "Caregiver Ophera Windfury", "Fabian Lanzonelli" },	-- Draenic Leather Pack
		[22250] = { "Chardryn", "Eldraeith", "Gwina Stonebranch", "Uma Bartulm" },	--Herb Pouch
		[11362]	= { "Landria", "Skolmin Goldfury", "Frederick Stover", "Avelii", "Ariyell Skyshadow", "Marda Weller" },	--Medium Quiver
		[7371]	= { "Avelii", "Beega", "Marda Weller", "Mura", "Thalgus Thunderfist" },	--Heavy Quiver
		[5441]	= { "Bretta Goldfury", "Thulman Flintcrag", "Muhaa" },	--Small Shot Pouch
		[5439]	= { "Landria", "Skolmin Goldfury", "Frederick Stover", "Avelii", "Ariyell Skyshadow" },	--Small Quiver
		[4499]	= { "Alyssa Griffith", "Cuzi", "Pithwick", "Yldan" },	--Huge Brown Sack
		[4498]	= { "Alyssa Griffith", "Cuzi", "Pithwick", "Yldan", "Ellandrieth", "Onnis", "Logan Daniel" },	--Brown Leather Satchel
		[4497]	= { "Alyssa Griffith", "Cuzi", "Pithwick", "Yldan", "Ellandrieth", "Onnis", "Logan Daniel" },	--Heavy Brown Bag
		[4496]	= { "Alyssa Griffith", "Cuzi", "Pithwick", "Yldan", "Ellandrieth", "Onnis", "Logan Daniel" },	--Small Brown Pouch
		[2101]	= { "Avelii", "Beega", "Frederick Stover", "Marda Weller", "Mura", "Thalgus Thunderfist" },	--Light Quiver
	
	--Vanity Pets (NEW!)
		[29904] = { "Sixx" },											-- White Moth Egg
		[29903] = { "Sixx" },											-- Yellow Moth Egg
		[29901] = { "Sixx" },											-- Blue Moth Egg
		[8501]	= { "Shylenai" },										-- Hawk Owl
		[8500]	= { "Shylenai" },										-- Great Horned Owl
		[8497]	= { "Yarlyn Amberstill" },								-- Snowshoe Rabbit
		[8489]	= { "Lil Timmy" },										-- Cat Carrier: White Kitten
		[8488]	= { "Donni Anthania" },									-- Cat Carrier: Silver Tabby
		[8487]	= { "Donni Anthania" },									-- Cat Carrier: Orange Tabby
		[8486]	= { "Donni Anthania" },									-- Cat Carrier: Cornish Rex
		[8485] 	= { "Donni Anthania" },									-- Cat Carrier: Bombay

	-- Alchemy
		[13478]	= { "Soolie Berryfizz" },								-- Recipe: Elixir of Superior Defense
		[13477]	= { "Ulthir" },											-- Recipe: Superior Mana Potion
		[9302]	= { "Logannas" },										-- Recipe: Ghost Dye
		[9301]	= { "Maria Lumere" },									-- Recipe: Elixir of Shadow Power
		[9300]	= { "Nina Lightbrew" },									-- Recipe: Elixir of Demonslaying
		[6057]	= { "Logannas" },										-- Recipe: Nature Protection Potion
		[6056]	= { "Drovnar Strongbrew" },								-- Recipe: Frost Protection Potion
		[6055]	= { "Nandar Branson" },									-- Recipe: Fire Protection Potion
		[6054]	= { "Harklan Moongrove" },								-- Recipe: Shadow Protection Potion
		[6053]	= { "Xandar Goodbeard" },								-- Recipe: Holy Protection Potion
		[5643]	= { "Ulthir" },											-- Recipe: Great Rage Potion
		[5642]	= { "Soolie Berryfizz", "Ulthir" },						-- Recipe: Free Action Potion
		[5640]	= { "Xandar Goodbeard", "Harklan Moongrove" },			-- Recipe: Rage Potion
		
	-- Blacksmithing
		[12162]	= { "Kaita Deepforge"},									-- Plans: Hardened Iron Shortsword
		[10858]	= { "Jannos Ironwill" },								-- Plans: Solid Iron Maul
		[7995]	= { "Harggan" },										-- Plans: Mithril Scale Bracers

	-- Enchanting
		[11039]	= { "Dalria" },											-- Formula: Enchant Cloak - Minor Agility
		[11101]	= { "Dalria" },											-- Formula: Enchant Bracer - Lesser Strength
		[11152]	= { "Tharynn Bouden" },									-- Formula: Enchant Gloves - Fishing
		[11163]	= { "Micha Yance" },									-- Formula: Enchant Bracer - Lesser Deflection
		[11223]	= { "Mythrin'dir" },									-- Formula: Enchant Bracer - Deflection
		[16217]	= { "Mythrin'dir" },									-- Formula: Enchant Shield - Greater Stamina
		[20752] = { "Johan Barnes", "Egomis", "Jessara Cordell", "Tilli Thistlefuzz", "Vaean", "Ildine Sorrowspear" },	-- Formula: Minor Mana Oil
		[20753] = { "Johan Barnes", "Egomis", "Jessara Cordell", "Tilli Thistlefuzz", "Vaean", "Ildine Sorrowspear" },	-- Formula: Lesser Wizard Oil
		[20758] = { "Johan Barnes", "Egomis", "Jessara Cordell", "Tilli Thistlefuzz", "Vaean" },	-- Formula: Minor Wizard Oil
		[6342] = { "Johan Barnes", "Egomis", "Jessara Cordell", "Tilli Thistlefuzz", "Vaean" },		-- Formula: Enchant Chest - Minor Mana
		[6349]	= { "Tilli Thistlefuzz" },								-- Formula: Enchant 2H Weapon - Lesser Intellect

	-- Engineering
		[22729] = { "Gearcutter Cogspinner" },							-- Schematic: Steam Tonk Controller
	
		[18649]	= { "Darian Singh", "Gearcutter Cogspinner" },			-- Schematic: Blue Firework
		[7560]	= { "Gearcutter Cogspinner" },							-- Schematic: Gnomish Universal Remote
		[13309]	= { "Fradd Swiftgear" },								-- Schematic: Lovingly Crafted Boomstick
		[14639]	= { "Fradd Swiftgear", "Namdo Bizzfizzle" },			-- Schematic: Minor Recombobulator
		[16041]	= { "Gearcutter Cogspinner" },							-- Schematic: Thorium Grenade
		[16042]	= { "Gearcutter Cogspinner" },							-- Schematic: Thorium Widget
	
	-- Jewelcrafting
		[20854]	= { "Mythrin'dir", "Arred" },							-- Design: Amulet of the Moon
		[20855]	= { "Dalria" },											-- Design: Wicked Moonstone Ring
		[20856]	= { "Arred", "Edna Mullby" },							-- Design: Heavy Golden Necklace of Battle
		[20970] = { "Neal Allen" },										-- Design: Pendant of the Agate Shield
		[20971]	= { "Micha Yance" },									-- Design: Heavy Iron Knuckles
		[20973]	= { "Micha Yance" },									-- Design: Blazing Citrine Ring
		[20975]	= { "Arred", "Burbik Gearspanner" },					-- Design: The Jade Eye
		[21941]	= { "Helenia Olden" },									-- Design: Black Pearl Panther
		[21942]	= { "Hammon Karwn" },									-- Design: Ruby Crown of Restoration
		[21943]	= { "Helenia Olden" },									-- Design: Truesilver Crab
		[21948]	= { "Arred", "Burbik Gearspanner" },					-- Design: Opal Necklace of Impact

	-- Leatherworking
		[13288]	= { "Androd Fadran" },									-- Pattern: Raptor Hide Belt
		[15725]	= { "Leonard Porter" },									-- Pattern: Wicked Leather Gauntlets
		[15734]	= { "Pratt McGrubben" },								-- Pattern: Living Shoulders
		[15741]	= { "Leonard Porter" },									-- Pattern: Stormshroud Pants
		[18731]	= { "Bombus Finespindle" },								-- Pattern: Heavy Leather Ball
		[18949]	= { "Saenorion" },										-- Pattern: Barbaric Bracers
		[20576]	= { "Amy Davenport" },									-- Pattern: Black Whelp Tunic
		[5786]	= { "Gina MacGregor", "Mavralyn" },						-- Pattern: Murloc Scale Belt
		[5787]	= { "Gina MacGregor", "Mavralyn" },						-- Pattern: Murloc Scale Breastplate
		[5788]	= { "Micha Yance" },									-- Pattern: Thick Murloc Armor
		[5789]	= { "Helenia Olden" },									-- Pattern: Murloc Scale Bracers
		[5973]	= { "Hammon Karwn", "Lardan" },							-- Pattern: Barbaric Leggings
		[7289]	= { "Clyde Ranthal" },									-- Pattern: Black Whelp Cloak
		[7290]	= { "Wenna Silkbeard" },								-- Pattern: Red Whelp Gloves
		[7361]	= { "Harlown Darkweave" },								-- Pattern: Herbalist's Gloves
		[7451]	= { "Pratt McGrubben", "Saenorion" },					-- Pattern: Green Whelp Bracers
		[7613]	= { "Wenna Silkbeard" },								-- Pattern: Green Leather Armor
		[8385]	= { "Pratt McGrubben" },								-- Pattern: Turtle Scale Gloves
		[8409]	= { "Nioma" },											-- Pattern: Nightscape Shoulders
		
	-- Tailoring
		[10311]	= { "Elynna" },											-- Pattern: Orange Martial Shirt
		[10314]	= { "Outfitter Eric" },									-- Pattern: Lavender Mageweave Shirt
		[10317]	= { "Outfitter Eric" },									-- Pattern: Pink Mageweave Shirt
		[10321]	= { "Outfitter Eric" },									-- Pattern: Tuxedo Shirt
		[10323]	= { "Outfitter Eric" },									-- Pattern: Tuxedo Pants
		[10325]	= { "Alexandra Bolero" },								-- Pattern: White Wedding Dress
		[10326]	= { "Outfitter Eric" },									-- Pattern: Tuxedo Jacket
		[14627]	= { "Danielle Zipstitch" },								-- Pattern: Bright Yellow Shirt
		[22307] = { "Johan Barnes", "Egomis", "Jessara Cordell", "Tilli Thistlefuzz", "Vaean", "Ildine Sorrowspear" },	-- Pattern: Enchanted Mageweave Pouch
		[4355]	= { "Micha Yance" },									-- Pattern: Icy Cloak
		[5771]	= { "Gina MacGregor", "Valdaron" },						-- Pattern: Red Linen Bag
		[5772]	= { "Amy Davenport", "Jennabink Powerseam",  "Rann Flamespinner", "Valdaron" },	-- Pattern: Red Woolen Bag
		[6270]	= { "Tharynn Bouden", "Valdaron" },						-- Pattern: Blue Linen Vest
		[6272]	= { "Drake Lindgren", "Elynna" },						-- Pattern: Blue Linen Robe
		[6274]	= { "Gina MacGregor", "Alexandra Bolero" },				-- Pattern: Blue Overalls
		[6275]	= { "Elynna", "Jennabink Powerseam", "Rann Flamespinner", "Sheri Zipstitch" },	-- Pattern: Greater Adept's Robe
		[6401]	= { "Sheri Zipstitch" },								-- Pattern: Dark Silk Shirt
		[7089]	= { "Brienna Starglow" },								-- Pattern: Azure Silk Cloak
		[7114]	= { "Wenna Silkbeard" },								-- Pattern: Azure Silk Gloves

	-- Cooking
		[12228]	= { "Corporal Bluth", "Hammon Karwn" , "Helenia Olden" },	-- Recipe: Roast Raptor
		[12229]	= { "Vivianna" },										-- Recipe: Hot Wolf Ribs
		[12231]	= { "Corporal Bluth" },									-- Recipe: Jungle Stew
		[12233]	= { "Helenia Olden", "Janet Hommers" },					-- Recipe: Mystery Stew
		[12239]	= { "Helenia Olden" },									-- Recipe: Dragonbreath Chili
		[12240]	= { "Janet Hommers" },									-- Recipe: Heavy Kodo Stew
		[13947]	= { "Vivianna" },										-- Recipe: Lobster Stew
		[13948]	= { "Vivianna" },										-- Recipe: Mightfish Steak
		[13949]	= { "Vivianna" },										-- Recipe: Baked Salmon
		[16072]	= { "Shandrina" },										-- Expert Cookbook
		[16110]	= { "Malygen" },										-- Recipe: Monster Omelet
		[16111]	= { "Kriggon Talsone" },								-- Recipe: Spiced Chili Crab
		[17062]	= { "Heldan Galesong", "Lindea Rabonne", "Stuart Fleming", "Tansy Puddlefizz" },	-- Recipe: Mithril Head Trout
		[17200]	= { "Khole Jinglepocket", "Wulmort Jinglepocket" },		-- Recipe: Gingerbread Cookie
		[17201]	= { "Khole Jinglepocket", "Wulmort Jinglepocket" },		-- Recipe: Egg Nog
		[18046]	= { "Truk Wildbeard" },									-- Recipe: Tender Wolf Steak
		[21099]	= { "Micha Yance", "Fyldan", "Emrul Riknussun", "Gloria Femmel", "Erika Tate", "Nyoma", "Phea", "\"Cookie\" McWeaksauce" },	-- Recipe: Smoked Sagefish
		[21219]	= { "Micha Yance", "Fyldan", "Emrul Riknussun", "Gloria Femmel", "Erika Tate", "Nyoma", "Phea", "\"Cookie\" McWeaksauce" },	-- Recipe: Sagefish Delight
		[2697]	= { "Kendor Kabonka" },									-- Recipe: Goretusk Liver Pie
		[2698]	= { "Kendor Kabonka" },									-- Recipe: Cooked Crab Claw
		[2699]	= { "Kendor Kabonka" },									-- Recipe: Redridge Goulash
		[2700]	= { "Kendor Kabonka" },									-- Recipe: Succulent Pork Ribs
		[2701]	= { "Kendor Kabonka" },									-- Recipe: Seasoned Wolf Kabob
		[2889]	= { "Kendor Kabonka" },									-- Recipe: Beer Basted Boar Ribs
		[3678]	= { "Kendor Kabonka" },									-- Recipe: Crocolisk Steak
		[3679]	= { "Kendor Kabonka" },									-- Recipe: Blood Sausage
		[3680]	= { "Kendor Kabonka" },									-- Recipe: Murloc Fin Soup
		[3681]	= { "Kendor Kabonka" },									-- Recipe: Crocolisk Gumbo
		[3682]	= { "Kendor Kabonka" },									-- Recipe: Curiously Tasty Omelet
		[3683]	= { "Kendor Kabonka" },									-- Recipe: Gooey Spider Cake
		[3734]	= { "Ulthaan" },										-- Recipe: Big Bear Steak
		[4609]	= { "Narj Deepslice" },									-- Recipe: Barbecued Buzzard Wing
		[5485]	= { "Laird" },											-- Recipe: Fillet of Frenzy
		[5489]	= { "Ulthaan" },										-- Recipe: Lean Venison
		[5528]	= { "Heldan Galesong", "Kriggon Talsone" },				-- Recipe: Clam Chowder
		[6325]	= { "Catherine Leland", "Gretta Ganter", "Khara Deepwater", "Nyoma", "Tharynn Bouden" },	-- Recipe: Brilliant Smallfish
		[6326]	= { "Kriggon Talsone", "Nessa Shadowsong", "Tansy Puddlefizz" },	-- Recipe: Slitherskin Mackerel
		[6328]	= { "Khara Deepwater", "Nyoma", "Tansy Puddlefizz", "Tharynn Bouden" },	-- Recipe: Longjaw Mud Snapper
		[6329]	= { "Khara Deepwater" },								-- Recipe: Loch Frenzy Delight
		[6330]	= { "Catherine Leland", "Lindea Rabonne", "Tharynn Bouden" },	-- Recipe: Bristle Whisker Catfish
		[6368]	= { "Catherine Leland" , "Heldan Galesong", "Kriggon Talsone" , "Nessa Shadowsong" , "Stuart Fleming" },	-- Recipe: Rainbow Fin Albacore
		[6369]	= { "Heldan Galesong", "Lindea Rabonne" , "Stuart Fleming" , "Tansy Puddlefizz" },	-- Recipe: Rockscale Cod
		[6892]	= { "Drac Roughcut" },									-- Recipe: Smoked Bear Meat
		[728]	= { "Kendor Kabonka" },									-- Recipe: Westfall Stew
		[35566] = { "Malygen" },							-- Recipe: Juicy Bear Burger
		[35564] = { "Malygen" },							-- Recipe: Charred Bear Kabobs
		
	-- First Aid
		[16084]	= { "Deneb Walker" },									-- Expert First Aid - Under Wraps
		[16112]	= { "Deneb Walker" },									-- Manual: Heavy Silk Bandage
		[16113]	= { "Deneb Walker" },									-- Manual: Mageweave Bandage

------------------------------------------------------
-- Burning Crusade content (Alliance)
------------------------------------------------------

	-- Alchemy
		[22900] = { "Alchemist Gribble", "Leeli Longhaggle", "Altaa" },	-- Recipe: Elixir of Camouflage
		[22901] = { "Leeli Longhaggle" },								-- Recipe: Sneaking Potion
		[22902] = { "Haalrun" },										-- Recipe: Elixir of Major Frost Power
		[22905] = { "Logistics Officer Ulrike" },						-- Recipe: Elixir of Major Agility
		[22907] = { "Haalrun" },										-- Recipe: Super Mana Potion
		[22909] = { "Haalrun" },										-- Recipe: Elixir of Major Defense
		[22911] = { "Leeli Longhaggle" },								-- Recipe: Major Dreamless Sleep Potion
		[23574] = { "Altaa" },											-- Recipe: Transmute Primal Might
		[25870] = { "Logistics Officer Ulrike" },						-- Recipe: Transmute Skyfire Diamond
		[30443] = { "Trader Narasu" },									-- Recipe: Transmute Primal Fire to Earth
		[32071]	= { "Quartermaster Davian Vaclav" },					-- Recipe: Elixir of Ironskin
		
	-- Blacksmithing
		[23590] = { "Arras" },											-- Plans: Adamantite Maul
		[23591] = { "Arras" },											-- Plans: Adamantite Cleaver
		[23592] = { "Arras" },											-- Plans: Adamantite Dagger
		[23593] = { "Arras" },											-- Plans: Adamantite Rapier
		[23594] = { "Loolruna" },										-- Plans: Adamantite Plate Bracers
		[23595] = { "Loolruna" },										-- Plans: Adamantite Plate Gloves
		[23596] = { "Loolruna" },										-- Plans: Adamantite Breastplate
		[23619] = { "Logistics Officer Ulrike" },						-- Plans: Felsteel Shield Spike
		[23638] = { "Mari Stonehand" },									-- Plans: Lesser Rune of Shielding
		[25847] = { "Mari Stonehand" },									-- Plans: Eternium Rod
		
	-- Enchanting
		[22531] = { "Logistics Officer Ulrike" },						-- Formula: Enchant Bracer - Superior Healing
		[22547] = { "Logistics Officer Ulrike" },						-- Formula: Enchant Chest - Exceptional Stats
		[22562] = { "Egomis" },											-- Formula: Superior Mana Oil
		[22563] = { "Egomis" },											-- Formula: Superior Wizard Oil
		[22565] = { "Egomis" },											-- Formula: Large Prismatic Shard
		[25848] = { "Vodesiin" },										-- Formula: Runed Adamantite Rod
		[33150] = { "Logistics Officer Ulrike" },			-- Formula: Enchant Cloak - Subtlety
		
	-- Engineering
		[23799] = { "Feera" },											-- Schematic: Adamantite Rifle
		[23803] = { "Lebowski" },										-- Schematic: Cogspinner Goggles
		[23805] = { "Lebowski" },										-- Schematic: Ultra-Spectropic Detection Goggles
		[23807] = { "Daggle Ironshaper" },								-- Schematic: Adamantite Scope
		[23811] = { "Feera" },											-- Schematic: White Smoke Flare
		[23815] = { "Feera" },											-- Schematic: Adamantite Shells
		[23816] = { "Feera" },											-- Schematic: Fel Iron Toolbox
		
	-- Jewelcrafting
		[23130] = { "Tatiana" },										-- Design: Teardrop Blood Garnet
		[23131] = { "Tatiana" },										-- Design: Bold Blood Garnet
		[23135] = { "Tatiana" },										-- Design: Inscribed Flame Spessarite
		[23137] = { "Tatiana" },										-- Design: Glinting Flame Spessarite
		[23140] = { "Tatiana" },										-- Design: Radiant Deep Peridot
		[23141] = { "Tatiana" },										-- Design: Jagged Deep Peridot
		[23142] = { "Logistics Officer Ulrike" },						-- Design: Enduring Deep Peridot
		[23144] = { "Tatiana" },										-- Design: Glowing Shadow Draenite
		[23147] = { "Tatiana" },										-- Design: Sovereign Shadow Draenite
		[23148] = { "Tatiana" },										-- Design: Brilliant Golden Draenite
		[23151] = { "Tatiana" },										-- Design: Rigid Golden Draenite
		[23152] = { "Tatiana" },										-- Design: Solid Azure Moonstone
		[23153] = { "Tatiana" },										-- Design: Sparkling Azure Moonstone
		[24180] = { "Logistics Officer Ulrike" },						-- Design: Dawnstone Crab
		[28291] = { "Tatiana" },										-- Design: Smooth Golden Draenite
		[28596] = { "Tatiana" },										-- Design: Bright Blood Garnet
		[33783]	= { "Quartermaster Davian Vaclav" },					-- Design: Steady Talasite
		[24208] = { "Aldraan" },										-- Design: Mystic Dawnstone
		
	-- Leatherworking
		[25720] = { "Haferet" },										-- Pattern: Heavy Knothide Leather
		[25726] = { "Haferet" },										-- Pattern: Comfortable Insoles
		[29213] = { "Logistics Officer Ulrike" },						-- Pattern: Felstalker Belt
		[29214] = { "Logistics Officer Ulrike" },						-- Pattern: Felstalker Bracers
		[29215] = { "Logistics Officer Ulrike" },						-- Pattern: Felstalker Breastplate
		[29217] = { "Trader Narasu" },									-- Pattern: Netherfury Belt
		[29218] = { "Trader Narasu" },									-- Pattern: Netherfury Boots
		[29219] = { "Trader Narasu" },									-- Pattern: Netherfury Leggings
		[29719] = { "Logistics Officer Ulrike" },						-- Pattern: Cobrahide Leg Armor
		[29722] = { "Logistics Officer Ulrike" },						-- Pattern: Nethercobra Leg Armor
		[30444] = { "Trader Narasu" },									-- Pattern: Reinforced Mining Bag
		[34173] = { "Trader Narasu" },				-- Pattern: Drums of Speed
		[34175] = { "Trader Narasu" },				-- Pattern: Drums of Restoration
		[34218] = { "Logistics Officer Ulrike" },	-- Pattern: Netherscale Ammo Pouch
		
	-- Tailoring
		[21892] = { "Neii" },											-- Pattern: Bolt of Imbued Netherweave
		[21894] = { "Borto", "Neii" },									-- Pattern: Bolt of Soulcloth
		[21896] = { "Neii" },											-- Pattern: Netherweave Robe
		[21897] = { "Neii" },											-- Pattern: Netherweave Tunic
		[21898] = { "Muheru the Weaver" },								-- Pattern: Imbued Netherweave Pants
		[21899] = { "Muheru the Weaver" },								-- Pattern: Imbued Netherweave Boots
		[21902] = { "Borto" },											-- Pattern: Soulcloth Gloves
		
	-- Cooking
		[22647] = { "Fazu" },											-- Recipe: Crunchy Spider Surprise
		[27688] = { "Sid Limbardi" },									-- Recipe: Ravager Dog
		[27690] = { "Supply Officer Mills" },							-- Recipe: Blackened Basilisk
		[27691] = { "Uriku" },											-- Recipe: Roasted Clefthoof
		[27692] = { "Uriku", "Supply Officer Mills" },					-- Recipe: Warp Burger
		[27693] = { "Uriku" },											-- Recipe: Talbuk Steak
		[27694] = { "Doba" },											-- Recipe: Blackened Trout
		[27695] = { "Doba" },											-- Recipe: Feltail Delight
		[27697] = { "Uriku" },											-- Recipe: Grilled Mudfish
		[27698] = { "Uriku" },											-- Recipe: Poached Bluefish
		[27699] = { "Innkeeper Biribi" },								-- Recipe: Golden Fish Sticks
		[27700] = { "Innkeeper Biribi" },								-- Recipe: Spicy Crawdad
		[27736] = { "Gaston" },											-- Master Cookbook
		[31674] = { "Sassa Weldwell" },							-- Recipe: Crunchy Serpent
		[31675] = { "Sassa Weldwell" },							-- Recipe: Mok'Nathal Shortribs
		
	-- First Aid
		[21992] = { "Burko" },											-- Manual: Netherweave Bandage
		[21993] = { "Burko" },											-- Manual: Heavy Netherweave Bandage
		[22012] = { "Burko" },											-- Master First Aid - Doctor in the House
		
	},
	
	["Horde"] = {
	--Bags
		[30744] = { "Floyd Pinkus" },									--Draenic Leather Pack
		[4499]	= { "Gotri", "Jonathan Chambers", "Pakwa", "Rathin" },	--Huge Brown Sack
		[4497]	= { "Gotri", "Jonathan Chambers", "Pakwa", "Rathin", "Trak'gen" },	--Heavy Brown Bag
		[4498]	= { "Gotri", "Jonathan Chambers", "Pakwa", "Rathin", "Trak'gen" },	--Brown Leather Satchel
		[4496]	= { "Gotri", "Jonathan Chambers", "Pakwa", "Rathin", "Trak'gen" },	--Small Brown Pouch
		[30748] = { "Floyd Pinkus" },									--Enchanter's Satchel
		[30745] = { "Floyd Pinkus" },									--Heavy Toolbox
		[30747] = { "Floyd Pinkus" },									--Gem Pouch
		[22250] = { "Botanist Tyniarrel", "Katrina Alliestar", "Selina Weston", "Zeal'aya" },	--Herb Pouch
		[30746] = { "Floyd Pinkus" },									--Mining Sack
		[11363] = { "Burkrum" },										--Medium Shot Pouch
		[5441]	= { "Kaja", "Mathaleron", "Hogor Thunderhoof", "Nicholas Atwood" },		--Small Shot Pouch
		[2102]	= { "Burkrum" },										--Small Ammo Pouch
		[7371]	= { "Benijah Fenner" },									--Heavy Quiver
		[11362]	= { "Jin'sora", "Celana", "Kuna Thunderhorn", "Abigail Sawyer" },	--Medium Quiver
		[5439]	= { "Jin'sora", "Celana", "Kuna Thunderhorn", "Abigail Sawyer" },	--Small Quiver
		[2101]	= { "Benijah Fenner" },									--Light Quiver
		[39489] = { "Xantili" },										--Scribe's Satchel
	
	--Vanity Pets (NEW!)
		[10360] = { "Xan'tish" },										--Black Kingsnake
		[10394] = { "Halpa" },											--Prairie Dog
		[10361] = { "Xan'tish" },										--Brown Snake
		[10393] = { "Jeremiah Payson" },								--Cockroach
		[10392] = { "Xan'tish" },										--Crimson Snake
		[29953] = { "Jilanne" },										--Golden Dragonhawk Hatchling
		[29956] = { "Jilanne" },										--Red Dragonhawk Hatchling
		[29957] = { "Jilanne" },										--Silver Dragonhawk Hatchling
	-- Alchemy
		[13477]	= { "Algernon" },										-- Recipe: Superior Mana Potion
		[13478]	= { "Kor'geld" },										-- Recipe: Elixir of Superior Defense
		[5640]	= { "Hagrus" },											-- Recipe: Rage Potion
		[5642]	= { "Kor'geld" },										-- Recipe: Free Action Potion
		[5643]	= { "Hagrus" },											-- Recipe: Great Rage Potion
		[6053]	= { "Hula'mahi" },										-- Recipe: Holy Protection Potion
		[6054]	= { "Christoph Jeffcoat" },								-- Recipe: Shadow Protection Potion
		[6055]	= { "Jeeda" },											-- Recipe: Fire Protection Potion
		[6057]	= { "Bronk" },											-- Recipe: Nature Protection Potion
		[6068]	= { "Montarr" },										-- Recipe: Shadow Oil
		[9300]	= { "Rartar" },											-- Recipe: Elixir of Demonslaying
		[9301]	= { "Algernon" },										-- Recipe: Elixir of Shadow Power
		[9302]	= { "Bronk" },											-- Recipe: Ghost Dye
		
	-- Blacksmithing
		[10858]	= { "Muuran" },											-- Plans: Solid Iron Maul
		[12162]	= { "Sumi" },											-- Plans: Hardened Iron Shortsword
		[12164]	= { "Vharr" },											-- Plans: Massive Iron Axe
		[7995]	= { "Gharash" },										-- Plans: Mithril Scale Bracers
                                    
	-- Enchanting
		[11039]	= { "Kulwia" },											-- Formula: Enchant Cloak - Minor Agility
		[11101]	= { "Kulwia" },											-- Formula: Enchant Bracer - Lesser Strength
		[11163]	= { "Keena" },											-- Formula: Enchant Bracer - Lesser Deflection
		[11223]	= { "Banalash" },										-- Formula: Enchant Bracer - Deflection
		[16217]	= { "Daniel Bartlett" },								-- Formula: Enchant Shield - Greater Stamina
		[20752] = { "Felannia", "Lyna", "Erilia", "Kithas", "Nata Dawnstrider", "Thaddeus Webb", "Lilly", "Leo Sarn" },										-- Formula: Minor Mana Oil
		[20753] = { "Felannia","Lyna", "Erilia", "Kithas", "Nata Dawnstrider", "Thaddeus Webb", "Lilly", "Leo Sarn" },										-- Formula: Lesser Wizard Oil
		[20758] = { "Felannia", "Lyna", "Erilia", "Kithas", "Nata Dawnstrider", "Thaddeus Webb", "Lilly", "Leo Sarn", "Ildine Sorrowspear" },	-- Formula: Minor Wizard Oil
		[6342] = { "Felannia", "Lyna", "Erilia", "Kithas", "Leo Sarn", "Lilly", "Nata Dawnstrider", "Thaddeus Webb" },										-- Formula: Enchant Chest - Minor Mana
		[6346]	= { "Kithas", "Lilly" },								-- Formula: Enchant Chest - Lesser Mana
		[6349]	= { "Kithas", "Leo Sarn", "Nata Dawnstrider" },			-- Formula: Enchant 2H Weapon - Lesser Intellect
		[6377]	= { "Nata Dawnstrider" },								-- Formula: Enchant Boots - Minor Agility
		
	-- Engineering
		[22729] = { "Sovik" },											-- Schematic: Steam Tonk Controller
		
		[16041]	= { "Sovik" },											-- Schematic: Thorium Grenade
		[16042]	= { "Sovik" },											-- Schematic: Thorium Widget
		[18647]	= { "Sovik" },											-- Schematic: Red Firework

	-- Jewelcrafting
		[20854]	= { "Daniel Bartlett", "Gelanthis" },					-- Design: Amulet of the Moon
		[20856]	= { "Gelanthis", "Felika" },							-- Design: Heavy Golden Necklace of Battle
		[20970] = { "Jandia" },											-- Design: Pendant of the Agate Shield
		[20971]	= { "Christoph Jeffcoat" },								-- Design: Heavy Iron Knuckles
		[20973]	= { "Kireena" },										-- Design: Blazing Citrine Ring
		[20975]	= { "Gelanthis", "Felicia Doan" },						-- Design: The Jade Eye
		[21941]	= { "Banalash" },										-- Design: Black Pearl Panther
		[21942]	= { "Keena" },											-- Design: Ruby Crown of Restoration
		[21943]	= { "Nerrist" },										-- Design: Truesilver Crab
		[21948]	= { "Gelanthis", "Shadi Mistrunner" },  				-- Design: Opal Necklace of Impact
		                                                
	-- Leatherworking
		[13287]	= { "Tunkk" },											-- Pattern: Raptor Hide Harness
		[15725]	= { "Werg Thickblade" },								-- Pattern: Wicked Leather Gauntlets
		[15734]	= { "Jangdor Swiftstrider" },							-- Pattern: Living Shoulders
		[15741]	= { "Werg Thickblade" },								-- Pattern: Stormshroud Pants
		[18731]	= { "Tamar" },											-- Pattern: Heavy Leather Ball
		[18949]	= { "Joseph Moore" },									-- Pattern: Barbaric Bracers
		[5786]	= { "Andrew Hilbert" },									-- Pattern: Murloc Scale Belt
		[5787]	= { "Andrew Hilbert" },									-- Pattern: Murloc Scale Breastplate
		[5788]	= { "Christoph Jeffcoat" },								-- Pattern: Thick Murloc Armor
		[5973]	= { "Jandia", "Keena" },								-- Pattern: Barbaric Leggings
		[7451]	= { "Jangdor Swiftstrider", "Joseph Moore" },			-- Pattern: Green Whelp Bracers
		[7613]	= { "George Candarte" },								-- Pattern: Green Leather Armor
		[8385]	= { "Jangdor Swiftstrider" },							-- Pattern: Turtle Scale Gloves
		[8409]	= { "Jangdor Swiftstrider", "Worb Strongstitch" },		-- Pattern: Nightscape Shoulders
		
	-- Tailoring
		[10311]	= { "Mahu" },											-- Pattern: Orange Martial Shirt
		[10314]	= { "Borya" },											-- Pattern: Lavender Mageweave Shirt
		[10317]	= { "Borya" },											-- Pattern: Pink Mageweave Shirt
		[10321]	= { "Millie Gregorian" },								-- Pattern: Tuxedo Shirt
		[10323]	= { "Millie Gregorian" },								-- Pattern: Tuxedo Pants
		[10325]	= { "Mahu" },											-- Pattern: White Wedding Dress
		[10326]	= { "Millie Gregorian" },								-- Pattern: Tuxedo Jacket
		[22307] = { "Felannia", "Lyna", "Erilia", "Kithas", "Nata Dawnstrider", "Thaddeus Webb", "Lilly", "Leo Sarn" },	-- Pattern: Enchanted Mageweave Pouch
		[4355]	= { "Ghok'kah" },										-- Pattern: Icy Cloak
		[5771]	= { "Andrew Hilbert", "Mahu", "Rathis Tomber" },		-- Pattern: Red Linen Bag
		[5772]	= { "Borya", "Mahu", "Millie Gregorian", "Wrahk", "Yonada" },	-- Pattern: Red Woolen Bag
		[6270]	= { "Borya", "Constance Brisboise", "Wrahk" },			-- Pattern: Blue Linen Vest
		[6272]	= { "Andrew Hilbert", "Wrahk" },						-- Pattern: Blue Linen Robe
		[6274]	= { "Borya", "Mallen Swain", "Yonada" },				-- Pattern: Blue Overalls
		[6275]	= { "Millie Gregorian" },								-- Pattern: Greater Adept's Robe
		[6401]	= { "Mallen Swain" },									-- Pattern: Dark Silk Shirt
		[7089]	= { "Jun'ha" },											-- Pattern: Azure Silk Cloak
		[7114]	= { "Kireena" },										-- Pattern: Azure Silk Gloves

	-- Cooking
		[12226]	= { "Abigail Shiel" },									-- Recipe: Crispy Bat Wing
		[12228]	= { "Keena", "Nerrist", "Ogg'marr" },					-- Recipe: Roast Raptor
		[12229]	= { "Sheendra Tallgrass" },								-- Recipe: Hot Wolf Ribs
		[12231]	= { "Nerrist" },										-- Recipe: Jungle Stew
		[12232]	= { "Banalash", "Kireena", "Ogg'marr" },				-- Recipe: Carrion Surprise
		[12239]	= { "Ogg'marr" },										-- Recipe: Dragonbreath Chili
		[12240]	= { "Kireena" },										-- Recipe: Heavy Kodo Stew
		[13947]	= { "Sheendra Tallgrass" },								-- Recipe: Lobster Stew
		[13948]	= { "Sheendra Tallgrass" },								-- Recipe: Mightfish Steak
		[13949]	= { "Sheendra Tallgrass" },								-- Recipe: Baked Salmon
		[16072]	= { "Wulan" },											-- Expert Cookbook
		[16110]	= { "Bale" },											-- Recipe: Monster Omelet
		[16111]	= { "Banalash", "Uthok" },								-- Recipe: Spiced Chili Crab
		[17062]	= { "Shankys", "Wik'Tar", "Wulan", "Lizbeth Cromwell" },	-- Recipe: Mithril Head Trout
		[17200]	= { "Penney Copperpinch" },								-- Recipe: Gingerbread Cookie
		[17201]	= { "Penney Copperpinch" },								-- Recipe: Egg Nog
		[20075]	= { "Ogg'marr" },										-- Recipe: Heavy Crocolisk Stew
		[21099] = { "Quelis", "Master Chef Mouldier", "Wulan", "Derak Nightfall", "Naal Mistrunner", "Tarban Hearthgrain", "Ronald Burch", "Otho Moji'ko", "Xen'to" },	-- Recipe: Smoked Sagefish
		[21219] = { "Quelis", "Master Chef Mouldier", "Wulan", "Derak Nightfall", "Naal Mistrunner", "Tarban Hearthgrain", "Ronald Burch", "Otho Moji'ko", "Xen'to" },	-- Recipe: Sagefish Delight
		[3682]	= { "Keena", "Nerrist" },								-- Recipe: Curiously Tasty Omelet
		[3735]	= { "Zargh" },											-- Recipe: Hot Lion Chops
		[5483]	= { "Grimtak" },										-- Recipe: Scorpid Surprise
		[5484]	= { "Wunna Darkmane" },									-- Recipe: Roasted Kodo Meat
		[5486]	= { "Tari'qa" },										-- Recipe: Strider Stew
		[5488]	= { "Tari'qa" },										-- Recipe: Crispy Lizard Tail
		[6325]	= { "Harn Longcast", "Martine Tramblay", "Sewa Mistrunner", "Lizbeth Cromwell" },	-- Recipe: Brilliant Smallfish
		[6326]	= { "Martine Tramblay", "Zansoa" },						-- Recipe: Slitherskin Mackerel
		[6328]	= { "Harn Longcast", "Killian Sanatha", "Naal Mistrunner", "Lizbeth Cromwell" },	-- Recipe: Longjaw Mud Snapper
		[6330]	= { "Derak Nightfall", "Naal Mistrunner", "Sewa Mistrunner", "Ronald Burch" },	-- Recipe: Bristle Whisker Catfish
		[6368]	= { "Killian Sanatha", "Shankys", "Zansoa", "Ronald Burch" },	-- Recipe: Rainbow Fin Albacore
		[6369]	= { "Shankys", "Wik'Tar", "Wulan", "Lizbeth Cromwell" },	-- Recipe: Rockscale Cod
		[6892]	= { "Andrew Hilbert" },									-- Recipe: Smoked Bear Meat
		[35566] = { "Bale" },							-- Recipe: Juicy Bear Burger
		[35564] = { "Bale" },							-- Recipe: Charred Bear Kabobs
		
	-- First Aid
		[16084]	= { "Balai Lok'Wein" },						-- Expert First Aid - Under Wraps
		[16112]	= { "Balai Lok'Wein" },						-- Manual: Heavy Silk Bandage
		[16113]	= { "Balai Lok'Wein" },						-- Manual: Mageweave Bandage

------------------------------------------------------
-- Burning Crusade content (Horde)
------------------------------------------------------

	-- Alchemy          
		[22900] = { "Daga Ramba", "Apothecary Antonivich", "Melaris" },	-- Recipe: Elixir of Camouflage
		[22901] = { "Seer Janidi" },									-- Recipe: Sneaking Potion
		[22902] = { "Seer Janidi" },									-- Recipe: Elixir of Major Frost Power
		[22907] = { "Daga Ramba" },										-- Recipe: Super Mana Potion
		[22909] = { "Daga Ramba" },										-- Recipe: Elixir of Major Defense
		[22911] = { "Daga Ramba" },										-- Recipe: Major Dreamless Sleep Potion
		[23574] = { "Melaris" },										-- Recipe: Transmute Primal Might
		[24001]	= { "Quartermaster Urgronn" },							-- Recipe: Elixir of Major Agility
		[29232]	= { "Quartermaster Urgronn" },							-- Recipe: Transmute Skyfire Diamond
		[22917]	= { "Provisioner Nasela" },								-- Recipe: Transmute Primal Fire to Earth
		[32071]	= { "Quartermaster Jaffrey Noreliqe" },					-- Recipe: Elixir of Ironskin
		                                                        
	-- Blacksmithing                                            
		[23590] = { "Eriden" },											-- Plans: Adamantite Maul
		[23591] = { "Eriden" },											-- Plans: Adamantite Cleaver
		[23592] = { "Eriden" },											-- Plans: Adamantite Dagger
		[23593] = { "Eriden" },											-- Plans: Adamantite Rapier
		[23594] = { "Krek Cragcrush" },									-- Plans: Adamantite Plate Bracers
		[23595] = { "Krek Cragcrush" },									-- Plans: Adamantite Plate Gloves
		[23596] = { "Krek Cragcrush" },									-- Plans: Adamantite Breastplate
		[23638] = { "Rohok" },											-- Plans: Lesser Rune of Shielding
		[24002]	= { "Quartermaster Urgronn" },							-- Plans: Felsteel Shield Spike
		[25847] = { "Rohok" },											-- Plans: Eternium Rod
		                                                        
	-- Enchanting                                               
		[22562] = { "Lyna" },											-- Formula: Superior Mana Oil
		[22563] = { "Lyna" },											-- Formula: Superior Wizard Oil
		[22565] = { "Lyna" },											-- Formula: Large Prismatic Shard
		[24000]	= { "Quartermaster Urgronn" },							-- Formula: Enchant Bracer - Superior Healing
		[24003]	= { "Quartermaster Urgronn" },							-- Formula: Enchant Chest - Exceptional Stats
		[25848] = { "Rungor" },											-- Formula: Runed Adamantite Rod
		[33151] = { "Quartermaster Urgronn" },				-- Formula: Enchant Cloak - Subtlety
		                                                        
	-- Engineering                                              
		[23799] = { "Yatheon" },										-- Schematic: Adamantite Rifle
		[23803] = { "Mixie Farshot" },									-- Schematic: Cogspinner Goggles
		[23805] = { "Captured Gnome" },									-- Schematic: Ultra-Spectropic Detection Goggles
		[23807] = { "Mixie Farshot" },									-- Schematic: Adamantite Scope
		[23811] = { "Yatheon", "Captured Gnome" },						-- Schematic: White Smoke Flare
		[23815] = { "Yatheon" },										-- Schematic: Adamantite Shells
		[23816] = { "Yatheon" },										-- Schematic: Fel Iron Toolbox
		                                                        
	-- Jewelcrafting                                            
		[23130] = { "Kalaen" },											-- Design: Teardrop Blood Garnet
		[23131] = { "Kalaen" },											-- Design: Bold Blood Garnet
		[23135] = { "Kalaen" },											-- Design: Inscribed Flame Spessarite
		[23137] = { "Kalaen" },											-- Design: Glinting Flame Spessarite
		[23140] = { "Kalaen" },											-- Design: Radiant Deep Peridot
		[23141] = { "Kalaen" },											-- Design: Jagged Deep Peridot
		[23144] = { "Kalaen" },											-- Design: Glowing Shadow Draenite
		[23147] = { "Kalaen" },											-- Design: Sovereign Shadow Draenite
		[23148] = { "Kalaen" },											-- Design: Brilliant Golden Draenite
		[23151] = { "Kalaen" },											-- Design: Rigid Golden Draenite
		[23152] = { "Kalaen" },											-- Design: Solid Azure Moonstone
		[23153] = { "Kalaen" },											-- Design: Sparkling Azure Moonstone
		[28291] = { "Kalaen" },											-- Design: Smooth Golden Draenite
		[28596] = { "Kalaen" },											-- Design: Bright Blood Garnet
		[31358]	= { "Quartermaster Urgronn" },							-- Design: Dawnstone Crab
		[31359]	= { "Quartermaster Urgronn" },							-- Design: Enduring Deep Peridot
		[33783]	= { "Quartermaster Jaffrey Noreliqe" },					-- Design: Steady Talasite
		[24208] = { "Coreiel" },										-- Design: Mystic Dawnstone
                                                                
	-- Leatherworking                                           
		[25720] = { "Zaralda" },										-- Pattern: Heavy Knothide Leather
		[25726] = { "Zaralda" },										-- Pattern: Comfortable Insoles
		[25738]	= { "Quartermaster Urgronn" },							-- Pattern: Felstalker Belt
		[25739]	= { "Quartermaster Urgronn" },							-- Pattern: Felstalker Bracers
		[25740]	= { "Quartermaster Urgronn" },							-- Pattern: Felstalker Breastplate
		[25741]	= { "Provisioner Nasela" },								-- Pattern: Netherfury Belt
		[25742]	= { "Provisioner Nasela" },								-- Pattern: Netherfury Leggings
		[25743]	= { "Provisioner Nasela" },								-- Pattern: Netherfury Boots
		[29664]	= { "Provisioner Nasela" },								-- Pattern: Reinforced Mining Bag
		[31361]	= { "Quartermaster Urgronn" },							-- Pattern: Cobrahide Leg Armor
		[31362]	= { "Quartermaster Urgronn" },							-- Pattern: Nethercobra Leg Armor
		[34174] = { "Provisioner Nasela" },			-- Pattern: Drums of Restoration
		[34172] = { "Provisioner Nasela" },			-- Pattern: Drums of Speed
		[34201] = { "Quartermaster Urgronn" },		-- Pattern: Netherscale Ammo Pouch
		                                                        
	-- Tailoring                                                
		[21892] = { "Deynna" },											-- Pattern: Bolt of Imbued Netherweave
		[21893] = { "Mathar G'ochar" },									-- Pattern: Imbued Netherweave Bag
		[21894] = { "Deynna", "Mathar G'ochar" },						-- Pattern: Bolt of Soulcloth
		[21896] = { "Deynna" },											-- Pattern: Netherweave Robe
		[21897] = { "Deynna" },											-- Pattern: Netherweave Tunic
		[21898] = { "Zurai" },											-- Pattern: Imbued Netherweave Pants
		[21899] = { "Zurai" },											-- Pattern: Imbued Netherweave Boots
		[21902] = { "Mathar G'ochar" },									-- Pattern: Soulcloth Gloves
		                                                        
	-- Cooking                                                  
		[22647] = { "Master Chef Mouldier" },							-- Recipe: Crunchy Spider Surprise
		[27685] = { "Landraelanis" },									-- Recipe: Lynx Steak
		[27687] = { "Master Chef Mouldier" },							-- Recipe: Bat Bites
		[27688] = { "Cookie One-Eye" },									-- Recipe: Ravager Dog
		[27690] = { "Innkeeper Grilka" },								-- Recipe: Blackened Basilisk
		[27690] = { "Innkeeper Grilka" },								-- Recipe: Blackened Basilisk
		[27691] = { "Nula the Butcher" },								-- Recipe: Roasted Clefthoof
		[27692] = { "Innkeeper Grilka", "Nula the Butcher" },			-- Recipe: Warp Burger
		[27693] = { "Nula the Butcher" },								-- Recipe: Talbuk Steak
		[27694] = { "Gambarinka" },										-- Recipe: Blackened Trout
		[27695] = { "Zurai" },											-- Recipe: Feltail Delight
		[27697] = { "Nula the Butcher" },								-- Recipe: Grilled Mudfish
		[27698] = { "Nula the Butcher" },								-- Recipe: Poached Bluefish
		[27699] = { "Rungor" },											-- Recipe: Golden Fish Sticks
		[27700] = { "Rungor" },											-- Recipe: Spicy Crawdad
		[27736] = { "Baxter" },											-- Master Cookbook
		                                                        
	-- First Aid                                                
		[21992] = { "Aresella" },										-- Manual: Netherweave Bandage
		[21993] = { "Aresella" },										-- Manual: Heavy Netherweave Bandage
		[22012] = { "Aresella" },										-- Master First Aid - Doctor in the House
		
	},
	
	["Neutral"] = {
	-- Bags
		[38082] = { "Haris Pilton" },									--"Gigantique" Bag
		[4499]	= { "Eral" },											--Huge Brown Sack
		[4497]	= { "Eral", "Nergal" },											--Heavy Brown Bag
		[4498]	= { "Eral", "Nergal" },											--Brown Leather Satchel
		[4496]	= { "Eral" },											--Small Brown Pouch
		[11363] = { "Mazk Snipeshot" },									--Medium Shot Pouch
		[2102]	= { "Mazk Snipeshot" },									--Small Ammo Pouch
	
	--Vanity Pets (NEW!)
		[11023] = { "Magus Tirth" },									--Ancona Chicken
		[29958] = { "Dealer Rashaad" },									--Blue Dragonhawk Hatchling
		[29364] = { "Dealer Rashaad" },									--Brown Rabbit
		[8496]	= { "Narkk" },											--Cockatiel
		[10393] = { "Dealer Rashaad" },									--Cockroach
		[10392] = { "Dealer Rashaad" },									--Crimson Snake
		[29363] = { "Dealer Rashaad" },									--Mana Wyrmling
		[29902] = { "Dealer Rashaad" },									--Red Moth Egg
		[8495]	= { "Dealer Rashaad", "Narkk", },						--Senegal
		[8490]	= { "Dealer Rashaad" },									--Cat Carrier: Siamese

	-- Alchemy
		[13482]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Recipe: Transmute Air to Fire
		[13483]	= { "Plugger Spazzring" },								-- Recipe: Transmute Fire to Earth
		[13484]	= { "Meilosh" },										-- Recipe: Transmute Earth to Water
		[13485]	= { "Magnus Frostwake" },								-- Recipe: Transmute Water to Air
		[13501]	= { "Magnus Frostwake" },								-- Recipe: Major Mana Potion
		[20011]	= { "Rin'wosho the Trader" },							-- Recipe: Mageblood Potion
		[20012]	= { "Rin'wosho the Trader" },							-- Recipe: Greater Dreamless Sleep Potion
		[20013]	= { "Rin'wosho the Trader" },							-- Recipe: Living Action Potion
		[20014]	= { "Rin'wosho the Trader" },							-- Recipe: Major Troll's Blood Potion
                                                                
		[12958]	= { "Alchemist Pestlezugg" },							-- Recipe: Transmute Arcanite
		[13480]	= { "Evie Whirlbrew" },									-- Recipe: Major Healing Potion
		[14634]	= { "Bro'kin" },										-- Recipe: Frost Oil
		[20761]	= { "Lokhtos Darkbargainer" },							-- Recipe: Transmute Elemental Fire
		[5640]	= { "Ranik", "Defias Profiteer" },											-- Recipe: Rage Potion
		[5642]	= { "Vendor-Tron 1000" },								-- Recipe: Free Action Potion
		[5643]	= { "Vendor-Tron 1000" },								-- Recipe: Great Rage Potion
		[6053]	= { "Kzixx" },											-- Recipe: Holy Protection Potion
		[6056]	= { "Glyx Brewright" },									-- Recipe: Frost Protection Potion
		[6057]	= { "Glyx Brewright", "Alchemist Pestlezugg"},			-- Recipe: Nature Protection Potion
		[6068]	= { "Bliztik" },										-- Recipe: Shadow Oil
		[9303]	= { "Alchemist Pestlezugg" },							-- Recipe: Philosophers' Stone
		[9304]	= { "Alchemist Pestlezugg" },							-- Recipe: Transmute Iron to Gold
		[9305]	= { "Alchemist Pestlezugg" },							-- Recipe: Transmute Mithril to Truesilver
		
	-- Blacksmithing
		[12703]	= { "Magnus Frostwake" },								-- Plans: Storm Gauntlets
		[12819]	= { "Magnus Frostwake" },								-- Plans: Ornate Thorium Handaxe
		[12823]	= { "Magnus Frostwake" },								-- Plans: Huge Thorium Battleaxe
		[17049]	= { "Lokhtos Darkbargainer" },							-- Plans: Fiery Chain Girdle
		[17051]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Bracers
		[17052]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Leggings
		[17053]	= { "Lokhtos Darkbargainer" },							-- Plans: Fiery Chain Shoulders
		[17059]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Reaver
		[17060]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Destroyer
		[19202]	= { "Meilosh" },										-- Plans: Heavy Timbermaw Belt
		[19203]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Plans: Girdle of the Dawn
		[19204]	= { "Meilosh" },										-- Plans: Heavy Timbermaw Boots
		[19205]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Plans: Gloves of the Dawn
		[19206]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Helm
		[19207]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Gauntlets
		[19208]	= { "Lokhtos Darkbargainer" },							-- Plans: Black Amnesty
		[19209]	= { "Lokhtos Darkbargainer" },							-- Plans: Blackfury
		[19210]	= { "Lokhtos Darkbargainer" },							-- Plans: Ebon Hand
		[19211]	= { "Lokhtos Darkbargainer" },							-- Plans: Blackguard
		[19212]	= { "Lokhtos Darkbargainer" },							-- Plans: Nightfall
		[19776]	= { "Rin'wosho the Trader" },							-- Plans: Bloodsoul Breastplate
		[19777]	= { "Rin'wosho the Trader" },							-- Plans: Bloodsoul Shoulders
		[19778]	= { "Rin'wosho the Trader" },							-- Plans: Bloodsoul Gauntlets
		[19779]	= { "Rin'wosho the Trader" },							-- Plans: Darksoul Breastplate
		[19780]	= { "Rin'wosho the Trader" },							-- Plans: Darksoul Leggings
		[19781]	= { "Rin'wosho the Trader" },							-- Plans: Darksoul Shoulders
		[20040]	= { "Lokhtos Darkbargainer" },							-- Plans: Dark Iron Boots
		[22209]	= { "Vargus" },											-- Plans: Heavy Obsidian Belt
		[22214]	= { "Vargus" },											-- Plans: Light Obsidian Belt
		[22219]	= { "Lieutenant General Andorov" },						-- Plans: Jagged Obsidian Shield
		[22221]	= { "Lieutenant General Andorov" },						-- Plans: Obsidian Mail Tunic
		[22766] = { "Vargus" }, 										-- Plans: Ironvine Breastplate 
		[22767] = { "Vargus" }, 										-- Plans: Ironvine Gloves
		[22768] = { "Vargus" }, 										-- Plans: Ironvine Belt 
		[8030]	= { "Magnus Frostwake" },								-- Plans: Ebon Shiv
		
		[10858]	= { "Jazzrik" },										-- Plans: Solid Iron Maul
		[12162]	= { "Jutak" },											-- Plans: Hardened Iron Shortsword
		[12163]	= { "Zarena Cromwind" },								-- Plans: Moonsteel Broadsword
		[12164]	= { "Jaquilina Dramet" },								-- Plans: Massive Iron Axe
		[6047]	= { "Krinkle Goodsteel" },								-- Plans: Golden Scale Coif

	-- Enchanting
		[44498] = { "Vanessa Sellers" },
		[44496] = { "Vanessa Sellers" },
		[44495] = { "Vanessa Sellers" },
		[44494] = { "Vanessa Sellers" },
		[44492] = { "Vanessa Sellers" },
		[44491] = { "Vanessa Sellers" },
		[44490] = { "Vanessa Sellers" },
		[44489] = { "Vanessa Sellers" },
		[44488] = { "Vanessa Sellers" },
		[44487] = { "Vanessa Sellers" },
		[44486] = { "Vanessa Sellers" },
		[44485] = { "Vanessa Sellers" },
		[44484] = { "Vanessa Sellers" },
		[44483] = { "Vanessa Sellers" },
		[44473] = { "Vanessa Sellers" },
		[44472] = { "Vanessa Sellers" },
		[44471] = { "Vanessa Sellers" },
		[37349] = { "Vanessa Sellers" },
		[37347] = { "Vanessa Sellers" },
		[37344] = { "Vanessa Sellers" },
		[37339] = { "Vanessa Sellers" },

		
		[19444]	= { "Lokhtos Darkbargainer" },							-- Formula: Enchant Weapon - Strength
		[19445]	= { "Meilosh" },										-- Formula: Enchant Weapon - Agility
		[19446]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Formula: Enchant Bracer - Mana Regeneration
		[19447]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Formula: Enchant Bracer - Healing
		[19448]	= { "Lokhtos Darkbargainer" },							-- Formula: Enchant Weapon - Mighty Spirit
		[19449]	= { "Lokhtos Darkbargainer" },							-- Formula: Enchant Weapon - Mighty Intellect
		[20732]	= { "Kania" },											-- Formula: Cloak - Greater Fire Resistance
		[20733]	= { "Kania" },											-- Formula: Cloak - Greater Nature Resistance
		[20756]	= { "Rin'wosho the Trader" },							-- Formula: Brilliant Wizard Oil
		[20757]	= { "Rin'wosho the Trader" },							-- Formula: Brilliant Mana Oil
		[22392]	= { "Meilosh" },										-- Formula: 2H Weapon - Agility

		[16221]	= { "Qia" },											-- Formula: Enchant Chest - Major Health
		[16224]	= { "Lorelae Wintersong" },								-- Formula: Enchant Cloak - Superior Defense
		[16243]	= { "Lorelae Wintersong" },								-- Formula: Runed Arcanite Rod
		[20752] = { "Yurial Soulwater", "Madame Ruby", "Dealer Malij", "Kania", "Asarnan" },	-- Formula: Minor Mana Oil
		[20753] = { "Yurial Soulwater", "Madame Ruby", "Dealer Malij", "Kania", "Asarnan" },	-- Formula: Lesser Wizard Oil
		[20754]	= { "Kania" },											-- Formula: Lesser Mana Oil
		[20755]	= { "Kania" },											-- Formula: Wizard Oil
		[20758] = { "Yurial Soulwater", "Madame Ruby", "Dealer Malij", "Kania", "Asarnan" },	-- Formula: Minor Wizard Oil
		[6342]	= { "Yurial Soulwater", "Madame Ruby", "Dealer Malij", "Kania", "Asarnan" },	-- Formula: Enchant Chest - Minor Mana
		[6377]	= { "Zixil" },											-- Formula: Enchant Boots - Minor Agility

	-- Engineering
		[20000]	= { "Rin'wosho the Trader" },							-- Schematic: Bloodvine Goggles
		[20001]	= { "Rin'wosho the Trader" },							-- Schematic: Bloodvine Lens

		[10602]	= { "Knaz Blunderflame", "Yuka Screwspigot" },			-- Schematic: Deadly Scope
		[10607]	= { "Jubie Gadgetspring" },								-- Schematic: Deepdive Helmet
		[10609]	= { "Ruppo Zipcoil" },									-- Schematic: Mithril Mechanical Dragonling
		[13308]	= { "Rizz Loosebolt", "Super-Seller 680" },				-- Schematic: Ice Deflector
		[13309]	= { "Jinky Twizzlefixxit" },							-- Schematic: Lovingly Crafted Boomstick
		[13310]	= { "Mazk Snipeshot", "Super-Seller 680" },				-- Schematic: Accurate Scope
		[13311]	= { "Gnaz Blunderflame" },								-- Schematic: Mechanical Dragonling
		[16046]	= { "Xizzer Fizzbolt" },								-- Schematic: Masterwork Target Dummy
		[16047]	= { "Xizzer Fizzbolt" },								-- Schematic: Thorium Tube
		[16050]	= { "Xizzer Fizzbolt" },								-- Schematic: Delicate Arcanite Converter
		[18648]	= { "Crazk Sparks", "Gagsprocket" },					-- Schematic: Green Firework
		[18650]	= { "Blizrik Buckshot" },								-- Schematic: EZ-Thro Dynamite II
		[18651]	= { "Mazk Snipeshot" },									-- Schematic: Truesilver Transformer
		[18652]	= { "Xizzer Fizzbolt" },								-- Schematic: Gyrofreeze Ice Reflector
		[18656]	= { "Xizzer Fizzbolt" },								-- Schematic: Powerful Seaforium Charge
		[19027]	= { "Zorbin Fandazzle" },								-- Schematic: Snake Burst Firework
		[7560]	= { "Jinky Twizzlefixxit" },							-- Schematic: Gnomish Universal Remote
		[7561]	= { "Kzixx", "Super-Seller 680", "Veenix", "Zixil" },	-- Schematic: Goblin Jumper Cables
		[7742]	= { "Zan Shivsproket" },								-- Schematic: Gnomish Cloaking Device

	-- Jewelcrafting
		[43597] = { "Tiffany Cartier" },
		[43497] = { "Tiffany Cartier" },
		[43485] = { "Tiffany Cartier" },
		[43320] = { "Tiffany Cartier" },
		[43319] = { "Tiffany Cartier" },
		[43318] = { "Tiffany Cartier" },
		[43317] = { "Tiffany Cartier" },
		[42653] = { "Tiffany Cartier" },
		[42652] = { "Tiffany Cartier" },
		[42651] = { "Tiffany Cartier" },
		[42650] = { "Tiffany Cartier" },
		[42649] = { "Tiffany Cartier" },
		[42648] = { "Tiffany Cartier" },
		[42315] = { "Tiffany Cartier" },
		[42314] = { "Tiffany Cartier" },
		[42313] = { "Tiffany Cartier" },
		[42312] = { "Tiffany Cartier" },
		[42311] = { "Tiffany Cartier" },
		[42310] = { "Tiffany Cartier" },
		[42309] = { "Tiffany Cartier" },
		[42308] = { "Tiffany Cartier" },
		[42307] = { "Tiffany Cartier" },
		[42306] = { "Tiffany Cartier" },
		[42305] = { "Tiffany Cartier" },
		[42304] = { "Tiffany Cartier" },
		[42303] = { "Tiffany Cartier" },
		[42302] = { "Tiffany Cartier" },
		[42301] = { "Tiffany Cartier" },
		[42300] = { "Tiffany Cartier" },
		[42299] = { "Tiffany Cartier" },
		[42298] = { "Tiffany Cartier" },
		[42138] = { "Tiffany Cartier" },
		[41718] = { "Archmage Alvareaux" },
		[41711] = { "Tiffany Cartier" },
		[41710] = { "Tiffany Cartier" },
		[41709] = { "Tiffany Cartier" },
		[41708] = { "Tiffany Cartier" },
		[41707] = { "Tiffany Cartier" },
		[41706] = { "Tiffany Cartier" },
		[41705] = { "Tiffany Cartier" },
		[41704] = { "Tiffany Cartier" },
		[41703] = { "Tiffany Cartier" },
		[41702] = { "Tiffany Cartier" },
		[41701] = { "Tiffany Cartier" },
		[41699] = { "Tiffany Cartier" },
		[41698] = { "Tiffany Cartier" },
		[41697] = { "Tiffany Cartier" },
		[41696] = { "Tiffany Cartier" },
		[41694] = { "Tiffany Cartier" },
		[41693] = { "Tiffany Cartier" },
		[41692] = { "Tiffany Cartier" },
		[41690] = { "Tiffany Cartier" },
		[41689] = { "Tiffany Cartier" },
		[41688] = { "Tiffany Cartier" },
		[41687] = { "Tiffany Cartier" },
		[41686] = { "Tiffany Cartier" },
		[41582] = { "Tiffany Cartier" },
		[41581] = { "Tiffany Cartier" },
		[41580] = { "Tiffany Cartier" },
		[41579] = { "Tiffany Cartier" },
		[41578] = { "Tiffany Cartier" },
		[41577] = { "Tiffany Cartier" },
		[41576] = { "Tiffany Cartier" },
		[20855]	= { "Ranik" },  										-- Design: Wicked Moonstone Ring
		[21952]	= { "Mishta" },  										-- Design: Emerald Crown of Destruction
		[21954] = { "Jase Farlane" },									-- Design: Ring of Bitter Shadows
		[21957]	= { "Qia" }, 											-- Design: Necklace of the Diamond Tower
		[23133]	= { "Quartermaster Enuril" },							-- Design: Runed Blood Garnet
		[23143]	= { "Quartermaster Enuril" },							-- Design: Dazzling Deep Peridot
		[23145]	= { "Quartermaster Endarin" },							-- Design: Royal Shadow Draenite
		[23149]	= { "Quartermaster Endarin" },							-- Design: Gleaming Golden Draenite
		
	-- Leatherworking
		[44589] = { "Braeg Stoutbeard" },
		[44588] = { "Braeg Stoutbeard" },
		[44587] = { "Braeg Stoutbeard" },
		[44586] = { "Braeg Stoutbeard" },
		[44585] = { "Braeg Stoutbeard" },
		[44584] = { "Braeg Stoutbeard" },
		[44553] = { "Braeg Stoutbeard" },
		[44552] = { "Braeg Stoutbeard" },
		[44551] = { "Braeg Stoutbeard" },
		[44550] = { "Braeg Stoutbeard" },
		[44549] = { "Braeg Stoutbeard" },
		[44548] = { "Braeg Stoutbeard" },
		[44547] = { "Braeg Stoutbeard" },
		[44546] = { "Braeg Stoutbeard" },
		[44545] = { "Braeg Stoutbeard" },
		[44544] = { "Braeg Stoutbeard" },
		[44543] = { "Braeg Stoutbeard" },
		[44542] = { "Braeg Stoutbeard" },
		[44541] = { "Braeg Stoutbeard" },
		[44540] = { "Braeg Stoutbeard" },
		[44539] = { "Braeg Stoutbeard" },
		[44538] = { "Braeg Stoutbeard" },
		[44537] = { "Braeg Stoutbeard" },
		[44536] = { "Braeg Stoutbeard" },
		[44535] = { "Braeg Stoutbeard" },
		[44534] = { "Braeg Stoutbeard" },
		[44533] = { "Braeg Stoutbeard" },
		[44532] = { "Braeg Stoutbeard" },
		[44531] = { "Braeg Stoutbeard" },
		[44530] = { "Braeg Stoutbeard" },
		[44528] = { "Braeg Stoutbeard" },
		[44527] = { "Braeg Stoutbeard" },
		[44526] = { "Braeg Stoutbeard" },
		[44525] = { "Braeg Stoutbeard" },
		[44524] = { "Braeg Stoutbeard" },
		[44523] = { "Braeg Stoutbeard" },
		[44522] = { "Braeg Stoutbeard" },
		[44521] = { "Braeg Stoutbeard" },
		[44520] = { "Braeg Stoutbeard" },
		[44519] = { "Braeg Stoutbeard" },
		[44518] = { "Braeg Stoutbeard" },
		[44517] = { "Braeg Stoutbeard" },
		[44516] = { "Braeg Stoutbeard" },
		[44515] = { "Braeg Stoutbeard" },
		[44514] = { "Braeg Stoutbeard" },
		[44513] = { "Braeg Stoutbeard" },
		[15742]	= { "Meilosh" },										-- Pattern: Warbear Harness
		[15754]	= { "Meilosh" },										-- Pattern: Warbear Woolies
		[17022]	= { "Lokhtos Darkbargainer" },							-- Pattern: Corehound Boots
		[17023]	= { "Lokhtos Darkbargainer" },							-- Pattern: Molten Helm
		[17025]	= { "Lokhtos Darkbargainer" },							-- Pattern: Black Dragonscale Boots
		[19326]	= { "Meilosh" },										-- Pattern: Might of the Timbermaw
		[19327]	= { "Meilosh" },										-- Pattern: Timbermaw Brawlers
		[19328]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Pattern: Dawn Treaders
		[19329]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Pattern: Golden Mantle of the Dawn
		[19330]	= { "Lokhtos Darkbargainer" },							-- Pattern: Lava Belt
		[19331]	= { "Lokhtos Darkbargainer" },							-- Pattern: Chromatic Gauntlets
		[19332]	= { "Lokhtos Darkbargainer" },							-- Pattern: Corehound Belt
		[19333]	= { "Lokhtos Darkbargainer" },							-- Pattern: Molten Belt
		[19769]	= { "Rin'wosho the Trader" },							-- Pattern: Primal Batskin Jerkin
		[19770]	= { "Rin'wosho the Trader" },							-- Pattern: Primal Batskin Gloves
		[19771]	= { "Rin'wosho the Trader" },							-- Pattern: Primal Batskin Bracers
		[19772]	= { "Rin'wosho the Trader" },							-- Pattern: Blood Tiger Breastplate
		[19773]	= { "Rin'wosho the Trader" },							-- Pattern: Blood Tiger Shoulders
		[20253]	= { "Meilosh" },										-- Pattern: Warbear Harness
		[20254]	= { "Meilosh" },										-- Pattern: Warbear Woolies
		[20382]	= { "Aendel Windspear" },								-- Pattern: Dreamscale Breastplate
		[20506]	= { "Aendel Windspear" },								-- Pattern: Spitfire Bracers
		[20507]	= { "Aendel Windspear" },								-- Pattern: Spitfire Gauntlets
		[20508]	= { "Aendel Windspear" },								-- Pattern: Spitfire Breastplate
		[20509]	= { "Aendel Windspear" },								-- Pattern: Sandstalker Bracers
		[20510]	= { "Aendel Windspear" },								-- Pattern: Sandstalker Gauntlets
		[20511]	= { "Aendel Windspear" },								-- Pattern: Sandstalker Breastplate
		[22769] = { "Aendel Windspear" }, 								-- Pattern: Bramblewood Belt 
		[22770] = { "Aendel Windspear" }, 								-- Pattern: Bramblewood Boots 
		[22771] = { "Aendel Windspear" }, 								-- Pattern: Bramblewood Helm 

		[14635]	= { "Rikqiz", "Vendor-Tron 1000" },						-- Pattern: Gem-studded Leather Belt
		[15724]	= { "Zannok Hidepiercer" },								-- Pattern: Heavy Scorpid Bracers
		[15726]	= { "Masat T'andr" },									-- Pattern: Green Dragonscale Breastplate
		[15729]	= { "Blimo Gadgetspring" },								-- Pattern: Chimeric Gloves
		[15735]	= { "Gigget Zipcoil" },									-- Pattern: Ironfeather Shoulders
		[15740]	= { "Qia" },											-- Pattern: Frostsaber Boots
		[15751]	= { "Blimo Gadgetspring" },								-- Pattern: Blue Dragonscale Breastplate
		[15756]	= { "Jase Farlane" },									-- Pattern: Runic Leather Headband
		[15758]	= { "Nergal" },											-- Pattern: Devilsaur Gauntlets
		[15759]	= { "Plugger Spazzring" },								-- Pattern: Black Dragonscale Breastplate
		[15762]	= { "Zannok Hidepiercer" },								-- Pattern: Heavy Scorpid Helm
		[18239]	= { "Rikqiz" },											-- Pattern: Shadowskin Gloves
		[5788]	= { "Blixrez Goodstitch" },								-- Pattern: Thick Murloc Armor
		[5789]	= { "Blixrez Goodstitch" },								-- Pattern: Murloc Scale Bracers
		[6474]	= { "Kalldan Felmoon" },								-- Pattern: Deviate Scale Cloak
		[6475]	= { "Kalldan Felmoon" },								-- Pattern: Deviate Scale Gloves
		[7362]	= { "Zixil" },											-- Pattern: Earthen Leather Shoulders
		[7451]	= { "Vendor-Tron 1000" },								-- Pattern: Green Whelp Bracers
		[7613]	= { "Vendor-Tron 1000" },								-- Pattern: Green Leather Armor
		                                            
	-- Tailoring
		[42188] = { "Archmage Alvareaux" },
		[37915] = { "Haughty Modiste" },								-- Pattern: Dress Shoes
		[38327] = { "Haughty Modiste" },								-- Pattern: Haliscan Jacket
		[38328] = { "Haughty Modiste" },								-- Pattern: Haliscan Pantaloons
		[17017]	= { "Lokhtos Darkbargainer" },							-- Pattern: Flarecore Mantle
		[17018]	= { "Lokhtos Darkbargainer" },							-- Pattern: Flarecore Gloves
		[19215]	= { "Meilosh" },										-- Pattern: Wisdom of the Timbermaw
		[19216]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Pattern: Argent Boots
		[19217]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Pattern: Argent Shoulders
		[19218]	= { "Meilosh" },										-- Pattern: Mantle of the Timbermaw
		[19219]	= { "Lokhtos Darkbargainer" },							-- Pattern: Flarecore Robe
		[19220]	= { "Lokhtos Darkbargainer" },							-- Pattern: Flarecore Leggings
		[19764]	= { "Rin'wosho the Trader" },							-- Pattern: Bloodvine Vest
		[19765]	= { "Rin'wosho the Trader" },							-- Pattern: Bloodvine Leggings
		[19766]	= { "Rin'wosho the Trader" },							-- Pattern: Bloodvine Boots
		[22307] = { "Yurial Soulwater", "Madame Ruby", "Dealer Malij", "Kania", "Asarnan" },			-- Pattern: Enchanted Mageweave Pouch
		[22308]	= { "Kania" },											-- Pattern: Enchanted Runecloth Bag
		[22310]	= { "Mishta" },											-- Pattern: Cenarion Herb Bag
		[22312]	= { "Mishta" },											-- Pattern: Satchel of Cenarius
		[22683] = { "Mishta" }, 										-- Pattern: Gaea's Embrace 
		[22772] = { "Mishta" }, 										-- Pattern: Sylvan Shoulders 
		[22773] = { "Mishta" }, 										-- Pattern: Sylvan Crown 
		[22774] = { "Mishta" }, 										-- Pattern: Sylvan Vest 

		[10318]	= { "Cowardly Crosby" },								-- Pattern: Admiral's Hat
		[10728]	= { "Narkk" },											-- Pattern: Black Swashbuckler's Shirt
		[14468]	= { "Qia" },											-- Pattern: Runecloth Bag
		[14469]	= { "Darnall" },										-- Pattern: Runecloth Robe
		[14472]	= { "Darnall" },										-- Pattern: Runecloth Cloak
		[14481]	= { "Qia" },											-- Pattern: Runecloth Gloves
		[14483]	= { "Lorelae Wintersong" },								-- Pattern: Felcloth Pants
		[14488]	= { "Darnall" },										-- Pattern: Runecloth Boots
		[14526]	= { "Qia", "Evie Whirlbrew" },							-- Pattern: Mooncloth
		[14630]	= { "Super-Seller 680", "Xizk Goodstitch" },			-- Pattern: Enchanter's Cowl
		[18487]	= { "Shen'dralar Provisioner" },						-- Pattern: Mooncloth Robe
		[21358]	= { "Vizzklick" },										-- Pattern: Soul Pouch
		[5772]	= { "Kiknikle", "Zixil" },								-- Pattern: Red Woolen Bag
		[6272]	= { "Ranik" },											-- Pattern: Blue Linen Robe
		[6275]	= { "Ranik" },											-- Pattern: Greater Adept's Robe
		[6401]	= { "Super-Seller 680" },								-- Pattern: Dark Silk Shirt
		[7087]	= { "Super-Seller 680", "Xizk Goodstitch" },			-- Pattern: Crimson Silk Cloak
		[7088]	= { "Vizzklick" },										-- Pattern: Crimson Silk Robe

	-- Cooking
		[43506] = { "Derek Odds" },
		[43505] = { "Derek Odds" },
		[43037] = { "Derek Odds" },
		[43036] = { "Derek Odds" },
		[43035] = { "Derek Odds" },
		[43034] = { "Derek Odds" },
		[43033] = { "Derek Odds" },
		[43032] = { "Derek Odds" },
		[43031] = { "Derek Odds" },
		[43030] = { "Derek Odds" },
		[43029] = { "Derek Odds" },
		[43028] = { "Derek Odds" },
		[43027] = { "Derek Odds" },
		[43026] = { "Derek Odds" },
		[43025] = { "Derek Odds" },
		[43024] = { "Derek Odds" },
		[43023] = { "Derek Odds" },
		[43022] = { "Derek Odds" },
		[43021] = { "Derek Odds" },
		[43020] = { "Derek Odds" },
		[43019] = { "Derek Odds" },
		[43018] = { "Derek Odds" },

		[12227]	= { "Super-Seller 680" },								-- Recipe: Lean Wolf Steak
		[12228]	= { "Vendor-Tron 1000" },								-- Recipe: Roast Raptor
		[12229]	= { "Super-Seller 680" },								-- Recipe: Hot Wolf Ribs
		[12231]	= { "Vendor-Tron 1000" },								-- Recipe: Jungle Stew
		[12232]	= { "Vendor-Tron 1000" },								-- Recipe: Carrion Surprise
		[12233]	= { "Super-Seller 680" },								-- Recipe: Mystery Stew
		[12239]	= { "Super-Seller 680" },								-- Recipe: Dragonbreath Chili
		[12240]	= { "Vendor-Tron 1000" },								-- Recipe: Heavy Kodo Stew
		[13939]	= { "Gikkix" },											-- Recipe: Spotted Yellowtail
		[13940]	= { "Kelsey Yance" },									-- Recipe: Cooked Glossy Mightfish
		[13941]	= { "Kelsey Yance" },									-- Recipe: Filet of Redgill
		[13942]	= { "Gikkix" },											-- Recipe: Grilled Squid
		[13943]	= { "Kelsey Yance" },									-- Recipe: Hot Smoked Bass
		[13945]	= { "Gikkix" },											-- Recipe: Nightfin Soup
		[13946]	= { "Gikkix" },											-- Recipe: Poached Sunscale Salmon
		[16110]	= { "Himmik", "Qia" },									-- Recipe: Monster Omelet
		[16767]	= { "Jabbey" },											-- Recipe: Undermine Clam Chowder
		[17062]	= { "Kelsey Yance" },									-- Recipe: Mithril Head Trout
		[18046]	= { "Dirge Quikcleave" },								-- Recipe: Tender Wolf Steak
		[21099] = { "Jim Saltit", "Kelsey Yance" },						-- Recipe: Smoked Sagefish
		[21219] = { "Jim Saltit", "Kelsey Yance" },						-- Recipe: Sagefish Delight
		[3734]	= { "Super-Seller 680" },								-- Recipe: Big Bear Steak
		[3735]	= { "Vendor-Tron 1000" },								-- Recipe: Hot Lion Chops
		[4609]	= { "Super-Seller 680" },								-- Recipe: Barbecued Buzzard Wing
		[5489]	= { "Vendor-Tron 1000" },								-- Recipe: Lean Venison
		[6039]	= { "Kelsey Yance" },									-- Recipe: Giant Clam Scorcho
		[6330]	= { "Kilxx" },											-- Recipe: Bristle Whisker Catfish
		[6368]	= { "Kilxx" },											-- Recipe: Rainbow Fin Albacore
		[6369]	= { "Kelsey Yance" },									-- Recipe: Rockscale Cod
		[18160]	= { "Smudge Thunderwood" },								-- Recipe: Thistle Tea

	-- Fishing
		[16083]	= { "Old Man Heming" },									-- Expert Fishing - The Bass and You
		
	-- First Aid
		[19442]	= { "Argent Quartermaster Hasana", "Argent Quartermaster Lightspark", "Quartermaster Miranda Breechlock" },	-- Formula: Powerful anti-venom

------------------------------------------------------
-- Burning Crusade content (Neutral)
------------------------------------------------------

	-- Alchemy
		[13517] = { "Almaador" },										-- Recipe: Alchemist's Stone
		[22906] = { "Mycah" },											-- Recipe: Shrouding Potion
		[22908] = { "Quartermaster Enuril" },							-- Recipe: Elixir of Major Firepower
		[22910] = { "Nakodu" },											-- Recipe: Elixir of Major Shadow Power
		[22915] = { "Almaador" },										-- Recipe: Transmute Primal Air to Fire
		[22916] = { "Mycah" },											-- Recipe: Transmute Primal Earth to Water
		[22918] = { "Fedryen Swiftspear" },								-- Recipe: Transmute Primal Water to Air
		[22922] = { "Fedryen Swiftspear" },								-- Recipe: Major Nature Protection Potion
		[23574] = { "Skreah" },											-- Recipe: Transmute Primal Might
		[25869] = { "Fedryen Swiftspear" },								-- Recipe: Transmute Earthstorm Diamond
		[31354] = { "Almaador" },										-- Recipe: Flask of the Titans
		[31355] = { "Alurmi" },											-- Recipe: Flask of Supreme Power
		[31356] = { "Fedryen Swiftspear" },								-- Recipe: Flask of Distilled Wisdom
		[31357] = { "Nakodu" },											-- Recipe: Flask of Chromatic Resistance
		[32070]	= { "Fedryen Swiftspear" },								-- Recipe: Earthen Elixir
		[33209] = { "Apprentice Darius" },								-- Recipe: Flask of Chromatic Wonder
		[35752] = { "Eldara Dawnrunner" },							-- Recipe: Guardian's Alchemist Stone
		[35753] = { "Eldara Dawnrunner" },							-- Recipe: Sorcerer's Alchemist Stone
		[35754] = { "Eldara Dawnrunner" },							-- Recipe: Redeemer's Alchemist Stone
		[35755] = { "Eldara Dawnrunner" },							-- Recipe: Assassin's Alchemist Stone
		
	-- Blacksmithing
		[23590] = { "Aaron Hollman" },									-- Plans: Adamantite Maul
		[23591] = { "Aaron Hollman" },									-- Plans: Adamantite Cleaver
		[23592] = { "Aaron Hollman" },									-- Plans: Adamantite Dagger
		[23593] = { "Aaron Hollman" },									-- Plans: Adamantite Rapier
		[23597] = { "Quartermaster Enuril" },							-- Plans: Enchanted Adamantite Belt
		[23598] = { "Quartermaster Enuril" },							-- Plans: Enchanted Adamantite Boots
		[23599] = { "Quartermaster Enuril" },							-- Plans: Enchanted Adamantite Breastplate
		[23600] = { "Quartermaster Enuril" },							-- Plans: Enchanted Adamantite Leggings
		[23601] = { "Quartermaster Endarin" },							-- Plans: Flamebane Bracers
		[23602] = { "Quartermaster Endarin" },							-- Plans: Flamebane Helm
		[23603] = { "Quartermaster Endarin" },							-- Plans: Flamebane Gloves
		[23604] = { "Quartermaster Endarin" },							-- Plans: Flamebane Breastplate
		[23618] = { "Fedryen Swiftspear" },								-- Plans: Adamantite Sharpening Stone
		[25526] = { "Fedryen Swiftspear" },								-- Plans: Greater Rune of Warding
		[25846] = { "Aaron Hollman" },									-- Plans: Adamantite Rod
		[28632] = { "Fedryen Swiftspear" },								-- Plans: Adamantite Weightstone
		[31390] = { "Fedryen Swiftspear" },								-- Plans: Wildguard Breastplate
		[31391] = { "Fedryen Swiftspear" },								-- Plans: Wildguard Leggings
		[31392] = { "Fedryen Swiftspear" },								-- Plans: Wildguard Helm
		[31393]	= { "Koren" },											-- Plans: Iceguard Breastplate                          
		[31394]	= { "Koren" },											-- Plans: Iceguard Leggings                             
		[31395]	= { "Koren" },											-- Plans: Iceguard Helm                                 
		[32441]	= { "Okuno" },											-- Plans: Shadesteel Sabots
		[32442]	= { "Okuno" },											-- Plans: Shadesteel Bracers
		[32443]	= { "Okuno" },											-- Plans: Shadesteel Greaves
		[32444]	= { "Okuno" },											-- Plans: Shadesteel Girdle

	-- Enchanting
		[22535]	= { "Ythyar" },											-- Formula: Enchant Ring - Weapon Might
		[22536] = { "Alurmi" },											-- Formula: Enchant Ring - Spellpower
		[22537] = { "Almaador" },										-- Formula: Enchant Ring - Healing Power
		[22538] = { "Nakodu" },										-- Formula: Enchant Ring - Stats
		[22539] = { "Aged Dalaran Wizard" },							-- Formula: Enchant Shield - Intellect
		[22562] = { "Madame Ruby" },									-- Formula: Superior Mana Oil
		[22563] = { "Madame Ruby" },									-- Formula: Superior Wizard Oil
		[22565] = { "Madame Ruby" },									-- Formula: Large Prismatic Shard
		[25849] = { "Madame Ruby" },									-- Formula: Runed Eternium Rod
		[28271] = { "Fedryen Swiftspear" },								-- Formula: Enchant Gloves - Spell Strike
		[28272] = { "Alurmi" },											-- Formula: Enchant Gloves - Major Spellpower
		[28273] = { "Almaador" },										-- Formula: Enchant Gloves - Major Healing
		[28274] = { "Karaaz", "Paulsta'ats" },							-- Formula: Enchant Cloak - Spell Penetration
		[28281] = { "Almaador" },										-- Formula: Enchant Weapon - Major Healing
		[28282] = { "Madame Ruby" },									-- Formula: Enchant Shield - Major Stamina
		[22552]	= { "Karaaz", "Paulsta'ats" },							-- Formula: Enchant Weapon - Major Striking
		[33148] = { "Nakodu" },											-- Formula: Enchant Cloak - Dodge
		[33149] = { "Fedryen Swiftspear" },								-- Formula: Enchant Cloak - Stealth
		[33152] = { "Alurmi" },											-- Formula: Enchant Gloves - Superior Agility
		[33153] = { "Almaador" },										-- Formula: Enchant Gloves - Threat
		[33165] = { "Apprentice Darius" },								-- Formula: Enchant Weapon - Greater Agility
		[34872] = { "Eldara Dawnrunner" },				-- Formula: Void Shatter
		[35500] = { "Eldara Dawnrunner" },				-- Formula: Enchant Chest - Defense
		
	-- Engineering
		[23799] = { "Viggz Shinesparked" },								-- Schematic: Adamantite Rifle
		[23811] = { "Wind Trader Lathrai" },							-- Schematic: White Smoke Flare
		[23814] = { "Fedryen Swiftspear" },								-- Schematic: Green Smoke Flare
		[23815] = { "Wind Trader Lathrai" },							-- Schematic: Adamantite Shells
		[23816] = { "Wind Trader Lathrai" },							-- Schematic: Fel Iron Toolbox
		[23874]	= { "Karaaz", "Paulsta'ats" },							-- Schematic: Elemental Seaforium Charge
		[32381]	= { "Viggz Shinesparked", "Xizzer Fizzbolt" },			-- Schematic: Fused Wiring

	-- Jewelcrafting
		[23134] = { "Karaaz", "Paulsta'ats" },							-- Design: Delicate Blood Garnet
		[23136] = { "Karaaz", "Paulsta'ats" },							-- Design: Luminous Flame Spessarite
		[23138] = { "Nakodu" },											-- Design: Potent Flame Spessarite
		[23146] = { "Karaaz", "Paulsta'ats" },							-- Design: Shifting Shadow Draenite
		[23150] = { "Karaaz", "Paulsta'ats" },							-- Design: Thick Golden Draenite
		[23155] = { "Karaaz", "Paulsta'ats" },							-- Design: Lustrous Azure Moonstone
		[24174] = { "Alurmi" },											-- Design: Pendant of Frozen Flame
		[24175] = { "Nakodu" },											-- Design: Pendant of Thawing
		[24176] = { "Quartermaster Enuril" },							-- Design: Pendant of Withering
		[24177] = { "Quartermaster Endarin" },							-- Design: Pendant of Shadow's End
		[24178] = { "Karaaz", "Paulsta'ats" },							-- Design: Pendant of the Null Rune
		[24179] = { "Nakodu" },											-- Design: Felsteel Boar
		[24181] = { "Alurmi" },											-- Design: Living Ruby Serpent
		[24182] = { "Almaador" },										-- Design: Talasite Owl
		[24183] = { "Fedryen Swiftspear" },								-- Design: Nightseye Panther
		[25902]	= { "Ythyar" },											-- Design: Powerful Earthstorm Diamond
		[25903]	= { "Ythyar" },											-- Design: Bracing Earthstorm Diamond
		[25904] = { "Almaador" },										-- Design: Insightful Earthstorm Diamond
		[25908] = { "Karaaz", "Paulsta'ats" },							-- Design: Swift Skyfire Diamond
		[25910] = { "Alurmi" },											-- Design: Enigmatic Skyfire Diamond
		[30826] = { "Almaador" },										-- Design: Ring of Arcane Shielding
		[31401] = { "Apprentice Darius" },								-- Design: The Frozen Eye
		[31402] = { "Fedryen Swiftspear" },								-- Design: The Natural Ward
		[32274]	= { "Indormi" },										-- Design: Bold Crimson Spinel
		[32277]	= { "Indormi" },										-- Design: Delicate Crimson Spinel
		[32281]	= { "Indormi" },										-- Design: Teardrop Crimson Spinel
		[32282]	= { "Indormi" },										-- Design: Runed Crimson Spinel
		[32283]	= { "Indormi" },										-- Design: Bright Crimson Spinel
		[32284]	= { "Indormi" },										-- Design: Subtle Crimson Spinel
		[32286]	= { "Indormi" },										-- Design: Solid Empyrean Sapphire
		[32287]	= { "Indormi" },										-- Design: Sparkling Empyrean Sapphire
		[32288]	= { "Indormi" },										-- Design: Lustrous Empyrean Sapphire
		[32290]	= { "Indormi" },										-- Design: Brilliant Lionseye
		[32291]	= { "Indormi" },										-- Design: Smooth Lionseye
		[32292] = { "Indormi" },										-- Design: Rigid Lionseye
		[32293]	= { "Indormi" },										-- Design: Gleaming Lionseye
		[32294]	= { "Indormi" },										-- Design: Thick Lionseye
		[32299]	= { "Indormi" },										-- Design: Balanced Shadowsong Amethyst
		[32300]	= { "Indormi" },										-- Design: Infused Shadowsong Amethyst
		[32301]	= { "Indormi" },										-- Design: Glowing Shadowsong Amethyst
		[32302]	= { "Indormi" },										-- Design: Royal Shadowsong Amethyst
		[32304]	= { "Indormi" },										-- Design: Potent Pyrestone
		[32305]	= { "Indormi" },										-- Design: Luminous Pyrestone
		[32306]	= { "Indormi" },										-- Design: Glinting Pyrestone
		[32308]	= { "Indormi" },										-- Design: Wicked Pyrestone
		[32309]	= { "Indormi" },										-- Design: Enduring Seaspray Emerald
		[32310]	= { "Indormi" },										-- Design: Radiant Seaspray Emerald
		[32311]	= { "Indormi" },										-- Design: Dazzling Seaspray Emerald
		[32312]	= { "Indormi" },										-- Design: Jagged Seaspray Emerald
		[32412]	= { "Karaaz", "Paulsta'ats" },							-- Design: Relentless Earthstorm Diamond
		[33622]	= { "Karaaz", "Paulsta'ats" },							-- Design: Relentless Earthstorm Diamond
		[33155] = { "Almaador" },										-- Design: Kailee's Rose
		[33157] = { "Nakodu" },											-- Design: Falling Star
		[33158] = { "Alurmi" },											-- Design: Stone of Blades
		[33159] = { "Almaador" },										-- Design: Blood of Amber
		[33160] = { "Alurmi" },											-- Design: Facet of Eternity
		[33156] = { "Paulsta'ats", "Karaaz" },							-- Design: Crimson Sun
		[33305] = { "Paulsta'ats", "Karaaz" },							-- Design: Don Julio's Heart
		[35238] = { "Shaani" },											
		[35239] = { "Shaani" },											
		[35240] = { "Shaani" },											
		[35241] = { "Shaani" },											
		[35242] = { "Shaani" },											
		[35243] = { "Shaani" },											
		[35244] = { "Shaani" },											
		[35245] = { "Shaani" },											
		[35246] = { "Shaani" },											
		[35247] = { "Shaani" },											
		[35248] = { "Shaani" },											
		[35249] = { "Shaani" },											
		[35250] = { "Shaani" },											
		[35251] = { "Shaani" },											
		[35252] = { "Shaani" },											
		[35253] = { "Shaani" },											
		[35254] = { "Shaani" },											
		[35255] = { "Shaani" },											
		[35256] = { "Shaani" },											
		[35257] = { "Shaani" },											
		[35258] = { "Shaani" },											
		[35259] = { "Shaani" },											
		[35260] = { "Shaani" },											
		[35261] = { "Shaani" },											
		[35262] = { "Shaani" },											
		[35263] = { "Shaani" },											
		[35264] = { "Shaani" },											
		[35265] = { "Shaani" },											
		[35266] = { "Shaani" },											
		[35267] = { "Shaani" },											
		[35268] = { "Shaani" },											
		[35269] = { "Shaani" },											
		[35270] = { "Shaani" },											
		[35271] = { "Shaani" },											
		[35322] = { "Shaani" },											
		[35323] = { "Shaani" },											
		[35325] = { "Shaani" },											
		[35505] = { "Eldara Dawnrunner" },				-- Design: Ember Skyfire Diamond
		[35502] = { "Eldara Dawnrunner" },				-- Design: Eternal Earthstorm Diamond
		[35695] = { "Eldara Dawnrunner" },							-- Design: Figurine - Empyrean Tortoise
		[35696] = { "Eldara Dawnrunner" },							-- Design: Figurine - Khorium Boar
		[35697] = { "Eldara Dawnrunner" },							-- Design: Figurine - Crimson Serpent
		[35698] = { "Eldara Dawnrunner" },							-- Design: Figurine - Shadowsong Panther
		[35699] = { "Eldara Dawnrunner" },							-- Design: Figurine - Seaspray Albatross
		[35708] = { "Eldara Dawnrunner" },							-- Design: Regal Nightseye
		[35766] = { "Eldara Dawnrunner", "Shaani" },							-- Design: Steady Seaspray Emerald
		[35767] = { "Eldara Dawnrunner", "Shaani" },							-- Design: Reckless Pyrestone
		[35768] = { "Eldara Dawnrunner", "Shaani" },							-- Design: Quick Lionseye
		[35769] = { "Eldara Dawnrunner", "Shaani" },							-- Design: Forceful Seaspray Emerald
		[37504] = { "Shaani" },											
		
	-- Leatherworking
		[25720] = { "Cro Threadstrong" },								-- Pattern: Heavy Knothide Leather
		[25721] = { "Quartermaster Endarin" },							-- Pattern: Vindicator's Armor Kit
		[25722] = { "Quartermaster Enuril" },							-- Pattern: Magister's Armor Kit
		[25725] = { "Thomas Yance" },									-- Pattern: Riding Crop
		[25732] = { "Karaaz", "Paulsta'ats" },							-- Pattern: Fel Leather Gloves
		[25733] = { "Karaaz", "Paulsta'ats" },							-- Pattern: Fel Leather Boots
		[25734] = { "Karaaz", "Paulsta'ats" },							-- Pattern: Fel Leather Leggings
		[25735] = { "Fedryen Swiftspear" },								-- Pattern: Heavy Clefthoof Vest
		[25736] = { "Fedryen Swiftspear" },								-- Pattern: Heavy Clefthoof Leggings
		[25737] = { "Fedryen Swiftspear" },								-- Pattern: Heavy Clefthoof Boots
		[29677] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Felscale Leggings
		[29682] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Felscale Gloves
		[29684] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Felscale Boots
		[29689] = { "Quartermaster Endarin" },							-- Pattern: Flamescale Leggings
		[29691] = { "Quartermaster Endarin" },							-- Pattern: Flamescale Boots
		[29693] = { "Quartermaster Endarin" },							-- Pattern: Flamescale Belt
		[29698] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Clefthoof Leggings
		[29700] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Clefthoof Gloves
		[29701] = { "Quartermaster Enuril" },							-- Pattern: Enchanted Clefthoof Boots
		[29702] = { "Quartermaster Endarin" },							-- Pattern: Blastguard Pants
		[29703] = { "Quartermaster Endarin" },							-- Pattern: Blastguard Boots
		[29704] = { "Quartermaster Endarin" },							-- Pattern: Blastguard Belt
		[29713] = { "Alurmi" },											-- Pattern: Drums of Panic
		[29717] = { "Almaador" },										-- Pattern: Drums of Battle
		[29720] = { "Fedryen Swiftspear" },								-- Pattern: Clefthide Leg Armor
		[29721] = { "Fedryen Swiftspear" },								-- Pattern: Nethercleft Leg Armor
		[32429]	= { "Okuno" },											-- Pattern: Boots of Shackled Souls
		[32430]	= { "Okuno" },											-- Pattern: Bracers of Shackled Souls
		[32431]	= { "Okuno" },											-- Pattern: Greaves of Shackled Souls
		[32436]	= { "Okuno" },											-- Pattern: Redeemed Soul Cinch
		[32435]	= { "Okuno" },											-- Pattern: Redeemed Soul Legguards
		[32433]	= { "Okuno" },											-- Pattern: Redeemed Soul Mocassins
		[32434]	= { "Okuno" },											-- Pattern: Redeemed Soul Wristguards
		[32432]	= { "Okuno" },											-- Pattern: Waistguard of Shackled Souls
		[33124] = { "Apprentice Darius" },					-- Pattern: Cloak of Darkness
		[33205] = { "Apprentice Darius" },					-- Pattern: Shadowprowler's Chestguard
		[34200] = { "Nakodu" },						-- Pattern: Quiver of a Thousand Feathers
		
	-- Tailoring
		[21892] = { "Eiin" },											-- Pattern: Bolt of Imbued Netherweave
		[21893] = { "Eiin" },											-- Pattern: Imbued Netherweave Bag
		[21895] = { "Nasmara Moonsong", "Ainderu Summerleaf" },								-- Pattern: Primal Mooncloth
		[21896] = { "Eiin" },											-- Pattern: Netherweave Robe
		[21897] = { "Eiin" },											-- Pattern: Netherweave Tunic
		[21900] = { "Arrond" },											-- Pattern: Imbued Netherweave Robe
		[21901] = { "Arrond" },											-- Pattern: Imbued Netherweave Tunic
		[21908] = { "Gidge Spellweaver", "Lalla Brightweave" },								-- Pattern: Spellfire Belt
		[21909] = { "Gidge Spellweaver", "Lalla Brightweave" },								-- Pattern: Spellfire Gloves
		[21910] = { "Gidge Spellweaver", "Lalla Brightweave" },								-- Pattern: Spellfire Vest
		[21911] = { "Gidge Spellweaver", "Lalla Brightweave" },								-- Pattern: Spellfire Bag
		[21912] = { "Andrion Darkspinner", "Linna Bruder" },							-- Pattern: Frozen Shadoweave Shoulders
		[21913] = { "Andrion Darkspinner", "Linna Bruder" },							-- Pattern: Frozen Shadoweave Vest
		[21914] = { "Andrion Darkspinner", "Linna Bruder" },							-- Pattern: Frozen Shadoweave Boots
		[21915] = { "Andrion Darkspinner", "Linna Bruder" },							-- Pattern: Ebon Shadowbag
		[21916] = { "Nasmara Moonsong", "Ainderu Summerleaf" },								-- Pattern: Primal Mooncloth Belt
		[21917] = { "Nasmara Moonsong", "Ainderu Summerleaf" },								-- Pattern: Primal Mooncloth Robe
		[21918] = { "Nasmara Moonsong", "Ainderu Summerleaf" },								-- Pattern: Primal Mooncloth Shoulders
		[21919] = { "Nasmara Moonsong", "Ainderu Summerleaf" },								-- Pattern: Primal Mooncloth Bag
		[24292] = { "Quartermaster Enuril" },							-- Pattern: Mystic Spellthread
		[24293] = { "Quartermaster Endarin" },							-- Pattern: Silver Spellthread
		[24294] = { "Quartermaster Enuril" },							-- Pattern: Runic Spellthread
		[24295] = { "Quartermaster Endarin" },							-- Pattern: Golden Spellthread
		[24314] = { "Karaaz", "Paulsta'ats" },							-- Pattern: Bag of Jewels
		[24316] = { "Gidge Spellweaver", "Lalla Brightweave" },								-- Pattern: Spellcloth
		[30483] = { "Andrion Darkspinner", "Linna Bruder" },							-- Pattern: Shadowcloth
		[30833] = { "Nakodu" },											-- Pattern: Cloak of Arcane Evasion
		[30842] = { "Quartermaster Endarin" },							-- Pattern: Flameheart Bracers
		[30843] = { "Quartermaster Endarin" },							-- Pattern: Flameheart Gloves
		[30844] = { "Quartermaster Endarin" },							-- Pattern: Flameheart Vest
		[32447]	= { "Okuno" },											-- Pattern: Night's End
		[32438]	= { "Okuno" },											-- Pattern: Soulguard Bracers
		[32440]	= { "Okuno" },											-- Pattern: Soulguard Girdle
		[32439]	= { "Okuno" },											-- Pattern: Soulguard Leggings
		[32437]	= { "Okuno" },											-- Pattern: Soulguard Slippers
		
	-- Cooking
		[27689] = { "Mycah" },											-- Recipe: Sporeling Snack
		[27696] = { "Juno Dufrain" },									-- Recipe: Blackened Sporefish
		[27736] = { "Naka" },											-- Master Cookbook
		[30156] = { "Mycah", "Naka" },									-- Recipe: Clam Bar
		
	-- Fishing
		[27532] = { "Juno Dufrain" },									-- Master Fishing - The Art of Angling

	},
};

SP_LibramInfo = {
	[18333] = { name="Lorekeeper Lydros", bonus="+8 Spell damage/healing" },	-- Libram of Focus
	[18334] = { name="Lorekeeper Lydros", bonus="+1% Dodge" },					-- Libram of Protection
	[18332] = { name="Lorekeeper Lydros", bonus="+1% Haste" },					-- Libram of Rapidity
	[11736] = { name="Mathredis Firestar", bonus="+20 Fire Resistance" },		-- Libram of Resilience
	[11732] = { name="Mathredis Firestar", bonus="+150 Mana" },					-- Libram of Rumination
	[11734] = { name="Mathredis Firestar", bonus="+125 Armor" },				-- Libram of Tenacity
	[11737] = { name="Mathredis Firestar", bonus="+8 any single stat" },		-- Libram of Voracity
	[11733] = { name="Mathredis Firestar", bonus="+100 Health" },				-- Libram of Constitution
};
