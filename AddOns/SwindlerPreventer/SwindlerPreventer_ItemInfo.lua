------------------------------------------------------
-- SwindlerPreventer_ItemInfo.lua
-- Originally based on the tables at http://members.cox.net/katy-w/Trades/Home.htm
-- Corrected / extended with info from http://wow.allakhazam.com and http://wowguru.com
------------------------------------------------------
-- LOCALIZATION: nothing locale-specific here (the recipe names are all in comments)
------------------------------------------------------

SP_ItemInfo = {

--Bags (NEW!)
	[38082] = { b=12000000 },	--"Gigantique" Bag
	[30744] = { b=120000 },	--Draenic Leather Pack
	[4499] 	= { b=100000 },	--Huge Brown Sack
	[4497]	= { b=20000 },	--Heavy Brown Bag
	[4498]	= { b=2500 },	--Brown Leather Satchel
	[4496]	= { b=500 },	--Small Brown Pouch
	[30748] = { b=140000 },	--Enchanter's Satchel
	[30745]	= { b=140000 },	--Heavy Toolbox
	[22250] = { b=1000 },	--Herb Pouch
	[39489] = { b=5000 },	--Scribe's Satchel
	[30746] = { b=100000 },	--Mining Sack
	[11363] = { b=1000 },	--Medium Shot Pouch
	[5441]	= { b=1000 },	--Small Shot Pouch
	[2102]	= { b=4 },		--Small Ammo Pouch
	[7371]	= { b=2000 },	--Heavy Quiver
	[11362] = { b=1000 },	--Medium Quiver
	[5439]	= { b=100 },	--Small Quiver
	[2101]	= { b=4 },		--Light Quiver

--Pets (NEW!)
	[11023] = { b=10000 },	--Ancona Chicken
	[10360] = { b=5000 },	--Black Kingsnake
	[29958] = { b=100000 },	--Blue Dragonhawk Hatchling
	[29901] = { b=5000 },	--Blue Moth Egg
	[8485]	= { b=4000 },	--Cat Carrier: Bombay
	[10394] = { b=5000 },	--Prairie Dog Whistle
	[29364] = { b=100000 },	--Brown Rabbit Crate
	[10361]	= { b=5000 },	--Brown Snake
	[8496]	= { b=4000 },	--Parrot: Cockatiel
	[10393] = { b=5000 },	--Cockroach
	[8486]	= { b=4000 },	--Cat Carrier: Cornish Rex
	[10392] = { b=5000 },	--Crimson Snake
	[29953] = { b=5000 },	--Golden Dragonhawk Hatchling
	[8500]	= { b=5000 },	--Great Horned Owl
	[8501]	= { b=5000 },	--Hawk Owl
	[29363] = { b=400000 }, -- Mana Wyrmling
	[8487]	= { b=4000 },	--Cat Carrier: Orange Tabby
	[29956] = { b=5000 },	--Red Dragonhawk Hatchling
	[29902] = { b=100000 },	--Red Moth Egg
	[8495] 	= { b=4000 },	--Parrot: Senegal
	[8490]	= { b=6000 },	--Cat Carrier: Siamese
	[29957] = { b=5000 },	--Silver Dragonhawk Hatchiling
	[8488]	= { b=4000 },	--Cat Carrier: Silver Tabby
	[8497]	= { b=2000 },	--Snowshoe Rabbit
	[8489]	= { b=6000 },	--Cat Carrier: White Kitten
	[29904] = { b=5000 },	--White Moth Egg
	[29903] = { b=5000 },	--Yellow Moth

-- Alchemy
	[13477]	= { b=12000 },	-- Recipe: Superior Mana Potion
	[13478]	= { b=13000 },	-- Recipe: Elixir of Superior Defense
	[5640]	= { b=100 },	-- Recipe: Rage Potion
	[5642]	= { b=1800 },	-- Recipe: Free Action Potion
	[5643]	= { b=2000 },	-- Recipe: Great Rage Potion
	[6053]	= { b=800 },	-- Recipe: Holy Protection Potion
	[6055]	= { b=1500 },	-- Recipe: Fire Protection Potion
	[6056]	= { b=2000 },	-- Recipe: Frost Protection Potion
	[6057]	= { b=2000 },	-- Recipe: Nature Protection Potion
	[9300]	= { b=10000 },	-- Recipe: Elixir of Demonslaying
	[9301]	= { b=10000 },	-- Recipe: Elixir of Shadow Power
	[9302]	= { b=9000 },	-- Recipe: Ghost Dye
	[6068]	= { b=1500 },	-- Recipe: Shadow Oil
	[6054]	= { b=900 },	-- Recipe: Shadow Protection Potion
	[14634]	= { b=2500 },	-- Recipe: Frost Oil
	[13480]	= { b=15000 },	-- Recipe: Major Healing Potion
	[9303]	= { b=8000 },	-- Recipe: Philosophers' Stone
	[12958]	= { b=50000 },	-- Recipe: Transmute Arcanite
	[9304]	= { b=8000 },	-- Recipe: Transmute Iron to Gold
	[9305]	= { b=8000 },	-- Recipe: Transmute Mithril to Truesilver
	[13501]	= { b=30000, note=SCHOLO_QUEST  },	-- Recipe: Major Mana Potion
	[13483]	= { b=15000, note=BRD_BARKEEP  },	-- Recipe: Transmute Fire to Earth
	[13482]	= { b=15000, note=REQ_FACTION  },	-- Recipe: Transmute Air to Fire
	[13484]	= { b=15000, 	note=REQ_FACTION  },	-- Recipe: Transmute Earth to Water
	[13485]	= { b=15000, note=SCHOLO_QUEST  },	-- Recipe: Transmute Water to Air
	[20013]	= { b=50000, note=REQ_FACTION },		-- Recipe: Living Action Potion
	[20011]	= { b=50000, note=REQ_FACTION },		-- Recipe: Mageblood Potion
	[20014]	= { b=50000, note=REQ_FACTION },		-- Recipe: Major Troll's Blood Potion
	[20012]	= { b=50000, note=REQ_FACTION },		-- Recipe: Greater Dreamless Sleep Potion
	[20761]	= { b=120000, note=REQ_FACTION },		-- Recipe: Transmute Elemental Fire

-- Blacksmithing
	[12162]	= { b=3000 },	-- Plans: Hardened Iron Shortsword
	[12164]	= { b=4400 },	-- Plans: Massive Iron Axe
	[7995]	= { b=6000 },	-- Plans: Mithril Scale Bracers
	[10858]	= { b=3000 },	-- Plans: Solid Iron Maul
	[6047]	= { b=4400 },	-- Plans: Golden Scale Coif
	[12163]	= { b=4400 },	-- Plans: Moonsteel Broadsword
	[8030]	= { b=10000, note=SCHOLO_QUEST  },		-- Plans: Ebon Shiv
	[12823]	= { b=20000, note=SCHOLO_QUEST  },		-- Plans: Huge Thorium Battleaxe
	[12819]	= { b=16000, note=SCHOLO_QUEST  },		-- Plans: Ornate Thorium Handaxe
	[12703]	= { b=40000, note=SCHOLO_QUEST  },		-- Plans: Storm Gauntlets
	[19208]	= { b=70000, note=THORIUM_REVERED },		-- Plans: Black Amnesty
	[19209]	= { b=70000, note=THORIUM_EXALTED  },	-- Plans: Blackfury
	[19211]	= { b=120000, note=THORIUM_EXALTED  },	-- Plans: Blackguard
	[19210]	= { b=120000, note=THORIUM_EXALTED  },	-- Plans: Ebon Hand
	[19212]	= { b=120000, note=THORIUM_EXALTED  },	-- Plans: Nightfall
	[17051]	= { b=70000, note=THORIUM_FRIENDLY  },	-- Plans: Dark Iron Bracers
	[17060]	= { b=220000, note=THORIUM_EXALTED  },	-- Plans: Dark Iron Destroyer
	[19207]	= { b=80000, note=THORIUM_REVERED  },	-- Plans: Dark Iron Gauntlets
	[19206]	= { b=60000, note=THORIUM_REVERED  },	-- Plans: Dark Iron Helm
	[17052]	= { b=180000, note=THORIUM_EXALTED  },	-- Plans: Dark Iron Leggings
	[17059]	= { b=220000, note=THORIUM_HONORED  },	-- Plans: Dark Iron Reaver
	[20040]	= { b=80000, note=THORIUM_EXALTED  },	-- Plans: Dark Iron Boots
	[17049]	= { b=90000, note=THORIUM_HONORED  },	-- Plans: Fiery Chain Girdle
	[17053]	= { b=200000, note=THORIUM_REVERED  },	-- Plans: Fiery Chain Shoulders
	[19202]	= { b=22000, note=REQ_FACTION  },		-- Plans: Heavy Timbermaw Belt
	[19204]	= { b=40000, note=REQ_FACTION  },		-- Plans: Heavy Timbermaw Boots
	[19203]	= { b=22000, note=REQ_FACTION  },		-- Plans: Girdle of the Dawn
	[19205]	= { b=40000, note=REQ_FACTION  },		-- Plans: Gloves of the Dawn
	[19781]	= { b=50000, note=REQ_FACTION  },		-- Plans: Darksoul Shoulders
	[19780]	= { b=50000, note=REQ_FACTION  },		-- Plans: Darksoul Leggings
	[19779]	= { b=50000, note=REQ_FACTION  },		-- Plans: Darksoul Breastplate
	[19778]	= { b=50000, note=REQ_FACTION  },		-- Plans: Bloodsoul Gauntlets
	[19777]	= { b=50000, note=REQ_FACTION  },		-- Plans: Bloodsoul Shoulders
	[19776]	= { b=50000, note=REQ_FACTION  },		-- Plans: Bloodsoul Breastplate
	[22219]	= { b=50000, note=REQ_FACTION  },		-- Plans: Jagged Obsidian Shield
	[22221]	= { b=80000, note=REQ_FACTION  },		-- Plans: Obsidian Mail Tunic
	[22209]	= { b=50000, note=REQ_FACTION  },		-- Plans: Heavy Obsidian Belt
	[22214]	= { b=50000, note=REQ_FACTION  },		-- Plans: Light Obsidian Belt
	[22768] = { b=50000, note=REQ_FACTION  }, 	-- Plans: Ironvine Belt 
	[22766] = { b=50000, note=REQ_FACTION  }, 	-- Plans: Ironvine Breastplate 
	[22767] = { b=50000, note=REQ_FACTION  }, 	-- Plans: Ironvine Gloves

-- Enchanting
	[44498] = { i="4 Dream Shard", b=0 },
	[44496] = { i="10 Dream Shard", b=0 },
	[44495] = { i="10 Dream Shard", b=0 },
	[44494] = { i="10 Dream Shard", b=0 },
	[44492] = { i="10 Dream Shard", b=0 },
	[44491] = { i="4 Dream Shard", b=0 },
	[44490] = { i="4 Dream Shard", b=0 },
	[44489] = { i="4 Dream Shard", b=0 },
	[44488] = { i="4 Dream Shard", b=0 },
	[44487] = { i="10 Dream Shard", b=0 },
	[44486] = { i="10 Dream Shard", b=0 },
	[44485] = { i="4 Dream Shard", b=0 },
	[44484] = { i="4 Dream Shard", b=0 },
	[44483] = { i="10 Dream Shard", b=0 },
	[44473] = { i="10 Dream Shard", b=0 },
	[44472] = { i="4 Dream Shard", b=0 },
	[44471] = { i="4 Dream Shard", b=0 },
	[37349] = { i="4 Dream Shard", b=0 },
	[37347] = { i="4 Dream Shard", b=0 },
	[37344] = { i="10 Dream Shard", b=0 },
	[37339] = { i="10 Dream Shard", b=0 },
	[6349]	= { b=500 },	-- Formula: Enchant 2H Weapon - Lesser Intellect
	[11223]	= { b=5800 },	-- Formula: Enchant Bracer - Deflection
	[11163]	= { b=3000 },	-- Formula: Enchant Bracer - Lesser Deflection
	[11101]	= { b=2500 },	-- Formula: Enchant Bracer - Lesser Strength
	[6342]	= { b=300 },	-- Formula: Enchant Chest - Minor Mana
	[11039]	= { b=800 },	-- Formula: Enchant Cloak - Minor Agility
	[11152]	= { b=3000 },	-- Formula: Enchant Gloves - Fishing
	[16217]	= { b=12000 },	-- Formula: Enchant Shield - Greater Stamina
	[6377]	= { b=1000 },	-- Formula: Enchant Boots - Minor Agility
	[6346]	= { b=400 },	-- Formula: Enchant Chest - Lesser Mana
	[16221]	= { b=16000 },	-- Formula: Enchant Chest - Major Health
	[16224]	= { b=20000 },	-- Formula: Enchant Cloak - Superior Defense
	[16243]	= { b=22000 },	-- Formula: Runed Arcanite Rod
	[20758]	= { b=500 },	-- Formula: Minor Wizard Oil
	[20752]	= { b=3000 },	-- Formula: Minor Mana Oil
	[20753]	= { b=4000 },	-- Formula: Lesser Wizard Oil
	[20754]	= { b=10000 },	-- Formula: Lesser Mana Oil
	[20755]	= { b=20000 },	-- Formula: Wizard Oil
	[19449]	= { b=100000, 	note=THORIUM_REVERED  },	-- Formula: Enchant Weapon - Mighty Intellect
	[19448]	= { b=80000, note=THORIUM_REVERED  },	-- Formula: Enchant Weapon - Mighty Spirit
	[19444]	= { b=30000, note=THORIUM_REVERED  },	-- Formula: Enchant Weapon - Strength
	[19445]	= { b=30000, note=REQ_FACTION  },		-- Formula: Enchant Weapon - Agility
	[19447]	= { b=60000, note=REQ_FACTION  },		-- Formula: Enchant Bracer - Healing
	[19446]	= { b=30000, 	note=REQ_FACTION  },		-- Formula: Enchant Bracer - Mana Regeneration
	[20756]	= { b=40000, 	note=REQ_FACTION  },		-- Formula: Brilliant Wizard Oil (zandalar)
	[20757]	= { b=40000, 	note=REQ_FACTION  },		-- Formula: Brilliant Mana Oil (zandalar)
	[20732]	= { b=90000, 	note=REQ_FACTION  },		-- Formula: Cloak - Greater Fire Resistance (cenarion)
	[20733]	= { b=90000, 	note=REQ_FACTION  },		-- Formula: Cloak - Greater Nature Resistance (cenarion)
	[22392]	= { b=25000, 	note=REQ_FACTION  },		-- Formula: 2H Weapon - Agility (timbermaw)
	
-- Engineering
	[22729] = { b=8000 },	-- Schematic: Steam Tonk Controller
	[18649]	= { b=1800 },	-- Schematic: Blue Firework
	[10607]	= { b=3600 },	-- Schematic: Deepdive Helmet
	[7560]	= { b=1200 },	-- Schematic: Gnomish Universal Remote
	[13309]	= { b=1000 },	-- Schematic: Lovingly Crafted Boomstick
	[14639]	= { b=1500 },	-- Schematic: Minor Recombobulator
	[10609]	= { b=4000 },	-- Schematic: Mithril Mechanical Dragonling
	[16041]	= { b=12000 },	-- Schematic: Thorium Grenade
	[16042]	= { b=12000 },	-- Schematic: Thorium Widget
	[18647]	= { b=1800 },	-- Schematic: Red Firework
	[13310]	= { b=2000 },	-- Schematic: Accurate Scope
	[10602]	= { b=3000 },	-- Schematic: Deadly Scope
	[16050]	= { b=20000 },	-- Schematic: Delicate Arcanite Converter
	[7742]	= { b=2400 },	-- Schematic: Gnomish Cloaking Device
	[7561]	= { b=2000 },	-- Schematic: Goblin Jumper Cables
	[18648]	= { b=1800 },	-- Schematic: Green Firework
	[18652]	= { b=12000 },	-- Schematic: Gyrofreeze Ice Reflector
	[13308]	= { b=1800 },	-- Schematic: Ice Deflector
	[16046]	= { b=16000 },	-- Schematic: Masterwork Target Dummy
	[13311]	= { b=10000 },	-- Schematic: Mechanical Dragonling
	[18656]	= { b=16000 },	-- Schematic: Powerful Seaforium Charge
	[16047]	= { b=16000 },	-- Schematic: Thorium Tube
	[18650]	= { b=5000 },	-- Schematic: EZ-Thro Dynamite II
	[19027]	= { b=1250 },	-- Schematic: Snake Burst Firework
	[18651]	= { b=12000 },	-- Schematic: Truesilver Transformer
	[20001]	= { b=50000, note=REQ_FACTION  },		-- Schematic: Bloodvine Lens
	[20000]	= { b=50000, note=REQ_FACTION  },		-- Schematic: Bloodvine Goggles
	
-- Jewelcrafting
	[43597] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[43497] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[43485] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[43320] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[43319] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[43318] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[43317] = { i="4 Dalaran Jewelcrafter's Token", b=0 },
	[42653] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42652] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42651] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42650] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42649] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42648] = { i="6 Dalaran Jewelcrafter's Token", b=0 },
	[42315] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42314] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42313] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42312] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42311] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42310] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42309] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42308] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42307] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42306] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42305] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42304] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42303] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42302] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42301] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42300] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42299] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42298] = { i="2 Dalaran Jewelcrafter's Token", b=0 },
	[42138] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41718] = { b=40000, note=REQ_FACTION },
	[41711] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41710] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41709] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41708] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41707] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41706] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41705] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41704] = { i="5 Dalaran Jewelcrafter's Token", b=0 },
	[41703] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41702] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41701] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41699] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41698] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41697] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41696] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41694] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41693] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41692] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41690] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41689] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41688] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41687] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41686] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41582] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41581] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41580] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41579] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41578] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41577] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[41576] = { i="3 Dalaran Jewelcrafter's Token", b=0 },
	[35238] = { b=500000, note=REQ_FACTION },											
	[35239] = { b=500000, note=REQ_FACTION },											
	[35240] = { b=500000, note=REQ_FACTION },											
	[35241] = { b=500000, note=REQ_FACTION },											
	[35242] = { b=500000, note=REQ_FACTION },											
	[35243] = { b=500000, note=REQ_FACTION },											
	[35244] = { b=500000, note=REQ_FACTION },											
	[35245] = { b=500000, note=REQ_FACTION },											
	[35246] = { b=500000, note=REQ_FACTION },											
	[35247] = { b=500000, note=REQ_FACTION },											
	[35248] = { b=500000, note=REQ_FACTION },											
	[35249] = { b=500000, note=REQ_FACTION },											
	[35250] = { b=500000, note=REQ_FACTION },											
	[35251] = { b=500000, note=REQ_FACTION },											
	[35252] = { b=500000, note=REQ_FACTION },											
	[35253] = { b=500000, note=REQ_FACTION },											
	[35254] = { b=500000, note=REQ_FACTION },											
	[35255] = { b=500000, note=REQ_FACTION },											
	[35256] = { b=500000, note=REQ_FACTION },											
	[35257] = { b=500000, note=REQ_FACTION },											
	[35258] = { b=500000, note=REQ_FACTION },											
	[35259] = { b=500000, note=REQ_FACTION },											
	[35260] = { b=500000, note=REQ_FACTION },											
	[35261] = { b=500000, note=REQ_FACTION },											
	[35262] = { b=500000, note=REQ_FACTION },											
	[35263] = { b=500000, note=REQ_FACTION },											
	[35264] = { b=500000, note=REQ_FACTION },											
	[35265] = { b=500000, note=REQ_FACTION },											
	[35266] = { b=500000, note=REQ_FACTION },											
	[35267] = { b=500000, note=REQ_FACTION },											
	[35268] = { b=500000, note=REQ_FACTION },											
	[35269] = { b=500000, note=REQ_FACTION },											
	[35270] = { b=500000, note=REQ_FACTION },											
	[35271] = { b=500000, note=REQ_FACTION },											
	[35322] = { b=120000, note=REQ_FACTION },											
	[35323] = { b=120000, note=REQ_FACTION },											
	[35325] = { b=120000, note=REQ_FACTION },											
	[37504] = { b=500000, note=REQ_FACTION },											

	[23133]	= { b=60000, note=REQ_FACTION },	-- Design: Runed Blood Garnet
	[23143]	= { b=60000, note=REQ_FACTION },	-- Design: Dazzling Deep Peridot
	[23145]	= { b=50000, note=REQ_FACTION },	-- Design: Royal Shadow Draenite
	[23149]	= { b=50000, note=REQ_FACTION },	-- Design: Gleaming Golden Draenite
	[20854]	= { b=1800 },	-- Design: Amulet of the Moon
	[21941]	= { b=5000 },	-- Design: Black Pearl Panther
	[20973]	= { b=2000 },	-- Design: Blazing Citrine Ring
	[21952]	= { b=10000 },	-- Design: Emerald Crown of Destruction
	[20856]	= { b=1500 },	-- Design: Heavy Golden Necklace of Battle
	[20971]	= { b=1500 },	-- Design: Heavy Iron Knuckles
	[21957]	= { b=15000 },	-- Design: Necklace of the Diamond Tower
	[21948]	= { b=7500 },	-- Design: Opal Necklace of Impact
	[21942]	= { b=6000 },	-- Design: Ruby Crown of Restoration
	[20975]	= { b=2500 },	-- Design: The Jade Eye
	[21943]	= { b=6000 },	-- Design: Truesilver Crab
	[20855]	= { b=1500 },	-- Design: Wicked Moonstone Ring
	
-- Leatherworking
	[44589] = { i="3 Heavy Borean Leather", b=0 },
	[44588] = { i="3 Heavy Borean Leather", b=0 },
	[44587] = { i="3 Heavy Borean Leather", b=0 },
	[44586] = { i="3 Heavy Borean Leather", b=0 },
	[44585] = { i="3 Heavy Borean Leather", b=0 },
	[44584] = { i="3 Heavy Borean Leather", b=0 },
	[44553] = { i="2 Arctic Fur", b=0 },
	[44552] = { i="2 Arctic Fur", b=0 },
	[44551] = { i="2 Arctic Fur", b=0 },
	[44550] = { i="2 Arctic Fur", b=0 },
	[44549] = { i="2 Arctic Fur", b=0 },
	[44548] = { i="2 Arctic Fur", b=0 },
	[44547] = { i="2 Arctic Fur", b=0 },
	[44546] = { i="2 Arctic Fur", b=0 },
	[44545] = { i="3 Heavy Borean Leather", b=0 },
	[44544] = { i="3 Heavy Borean Leather", b=0 },
	[44543] = { i="3 Heavy Borean Leather", b=0 },
	[44542] = { i="3 Heavy Borean Leather", b=0 },
	[44541] = { i="3 Heavy Borean Leather", b=0 },
	[44540] = { i="3 Heavy Borean Leather", b=0 },
	[44539] = { i="3 Heavy Borean Leather", b=0 },
	[44538] = { i="3 Heavy Borean Leather", b=0 },
	[44537] = { i="3 Heavy Borean Leather", b=0 },
	[44536] = { i="3 Heavy Borean Leather", b=0 },
	[44535] = { i="3 Heavy Borean Leather", b=0 },
	[44534] = { i="3 Heavy Borean Leather", b=0 },
	[44533] = { i="3 Heavy Borean Leather", b=0 },
	[44532] = { i="3 Heavy Borean Leather", b=0 },
	[44531] = { i="3 Heavy Borean Leather", b=0 },
	[44530] = { i="3 Heavy Borean Leather", b=0 },
	[44528] = { i="3 Heavy Borean Leather", b=0 },
	[44527] = { i="3 Heavy Borean Leather", b=0 },
	[44526] = { i="3 Heavy Borean Leather", b=0 },
	[44525] = { i="3 Heavy Borean Leather", b=0 },
	[44524] = { i="3 Heavy Borean Leather", b=0 },
	[44523] = { i="3 Heavy Borean Leather", b=0 },
	[44522] = { i="3 Heavy Borean Leather", b=0 },
	[44521] = { i="3 Heavy Borean Leather", b=0 },
	[44520] = { i="3 Heavy Borean Leather", b=0 },
	[44519] = { i="3 Heavy Borean Leather", b=0 },
	[44518] = { i="3 Heavy Borean Leather", b=0 },
	[44517] = { i="3 Heavy Borean Leather", b=0 },
	[44516] = { i="3 Heavy Borean Leather", b=0 },
	[44515] = { i="3 Heavy Borean Leather", b=0 },
	[44514] = { i="3 Heavy Borean Leather", b=0 },
	[44513] = { i="3 Heavy Borean Leather", b=0 },
	[18949]	= { b=2000 },	-- Pattern: Barbaric Bracers
	[5973]	= { b=650 },	-- Pattern: Barbaric Leggings
	[7289]	= { b=650 },	-- Pattern: Black Whelp Cloak
	[20576]	= { b=350 },	-- Pattern: Black Whelp Tunic
	[15751]	= { b=20000 },	-- Pattern: Blue Dragonscale Breastplate
	[15729]	= { b=12000 },	-- Pattern: Chimeric Gloves
	[7613]	= { b=2000 },	-- Pattern: Green Leather Armor
	[7451]	= { b=2800 },	-- Pattern: Green Whelp Bracers
	[18731]	= { b=2000 },	-- Pattern: Heavy Leather Ball
	[7361]	= { b=1800 },	-- Pattern: Herbalist's Gloves
	[15735]	= { b=14000 },	-- Pattern: Ironfeather Shoulders
	[15734]	= { b=14000 },	-- Pattern: Living Shoulders
	[5786]	= { b=550 },	-- Pattern: Murloc Scale Belt
	[5787]	= { b=600 },	-- Pattern: Murloc Scale Breastplate
	[5789]	= { b=2800 },	-- Pattern: Murloc Scale Bracers
	[8409]	= { b=4000 },	-- Pattern: Nightscape Shoulders
	[13288]	= { b=2500 },	-- Pattern: Raptor Hide Belt
	[7290]	= { b=1600 },	-- Pattern: Red Whelp Gloves
	[15741]	= { b=16000 },	-- Pattern: Stormshroud Pants
	[5788]	= { b=650 },	-- Pattern: Thick Murloc Armor
	[8385]	= { b=3500 },	-- Pattern: Turtle Scale Gloves
	[15725]	= { b=12000 },	-- Pattern: Wicked Leather Gauntlets
	[13287]	= { b=2500 },	-- Pattern: Raptor Hide Harness
	[6474]	= { b=550 },	-- Pattern: Deviate Scale Cloak
	[6475]	= { b=1500 },	-- Pattern: Deviate Scale Gloves
	[15758]	= { b=22000 },	-- Pattern: Devilsaur Gauntlets
	[7362]	= { b=2000 },	-- Pattern: Earthen Leather Shoulders
	[15740]	= { b=16000 },	-- Pattern: Frostsaber Boots
	[14635]	= { b=3000 },	-- Pattern: Gem-studded Leather Belt
	[15726]	= { b=12000 },	-- Pattern: Green Dragonscale Breastplate
	[15724]	= { b=12000 },	-- Pattern: Heavy Scorpid Bracers
	[15762]	= { b=25000 },	-- Pattern: Heavy Scorpid Helm
	[15756]	= { b=22000 },	-- Pattern: Runic Leather Headband
	[18239]	= { b=3500 },	-- Pattern: Shadowskin Gloves
	[15759]	= { b=22000, 	note=BRD_BARKEEP  },		-- Pattern: Black Dragonscale Breastplate
	[17025]	= { b=160000, 	note=THORIUM_HONORED },		-- Pattern: Black Dragonscale Boots
	[19331]	= { b=90000, note=THORIUM_REVERED },		-- Pattern: Chromatic Gauntlets
	[19332]	= { b=90000, note=THORIUM_REVERED },		-- Pattern: Corehound Belt
	[17022]	= { b=150000, note=THORIUM_FRIENDLY },	-- Pattern: Corehound Boots
	[19330]	= { b=60000, note=THORIUM_REVERED },		-- Pattern: Lava Belt
	[19333]	= { b=90000, note=THORIUM_REVERED },		-- Pattern: Molten Belt
	[17023]	= { b=160000, note=THORIUM_FRIENDLY },	-- Pattern: Molten Helm
	[15742]	= { b=16000, note=TIMBERMAW_FRIENDLY },	-- Pattern: Warbear Harness
	[15754]	= { b=20000, note=TIMBERMAW_FRIENDLY },	-- Pattern: Warbear Woolies
	[20253]	= { b=16000, note=REQ_FACTION },			-- Pattern: Warbear Harness
	[20254]	= { b=20000, note=REQ_FACTION },			-- Pattern: Warbear Woolies
	[19327]	= { b=40000, note=REQ_FACTION },			-- Pattern: Timbermaw Brawlers
	[19326]	= { b=22000, note=REQ_FACTION },			-- Pattern: Might of the Timbermaw
	[19328]	= { b=22000, note=REQ_FACTION },		-- Pattern: Dawn Treaders
	[19329]	= { b=40000, 	note=REQ_FACTION },		-- Pattern: Golden Mantle of the Dawn
	[19771]	= { b=50000, note=REQ_FACTION },		-- Pattern: Primal Batskin Bracers
	[19773]	= { b=50000, note=REQ_FACTION },		-- Pattern: Blood Tiger Shoulders
	[19770]	= { b=50000, note=REQ_FACTION },		-- Pattern: Primal Batskin Gloves
	[19772]	= { b=50000, note=REQ_FACTION },		-- Pattern: Blood Tiger Breastplate
	[19769]	= { b=50000, note=REQ_FACTION },		-- Pattern: Primal Batskin Jerkin
	[20382]	= { b=60000, note=REQ_FACTION },		-- Pattern: Dreamscale Breastplate
	[20506]	= { b=40000, note=REQ_FACTION },		-- Pattern: Spitfire Bracers
	[20507]	= { b=40000, note=REQ_FACTION },		-- Pattern: Spitfire Gauntlets
	[20508]	= { b=40000, note=REQ_FACTION },		-- Pattern: Spitfire Breastplate
	[20509]	= { b=40000, note=REQ_FACTION },		-- Pattern: Sandstalker Bracers
	[20510]	= { b=40000, note=REQ_FACTION },		-- Pattern: Sandstalker Gauntlets
	[20511]	= { b=40000, note=REQ_FACTION },		-- Pattern: Sandstalker Breastplate
	[22769] = { b=50000, note=REQ_FACTION }, -- Pattern: Bramblewood Belt 
	[22770] = { b=50000, note=REQ_FACTION }, -- Pattern: Bramblewood Boots 
	[22771] = { b=50000, note=REQ_FACTION }, -- Pattern: Bramblewood Helm 

-- Tailoring
	[42188] = { b=50000, note=REQ_FACTION },
	[38327] = { b=5000 },	-- Pattern: Haliscan Jacket
	[37915] = { b=5000 },	-- Pattern: Dress Shoes
	[38328] = { b=4500 },	-- Pattern: Haliscan Pantaloons
	[7089]	= { b=1500 },	-- Pattern: Azure Silk Cloak
	[7114]	= { b=1000 },	-- Pattern: Azure Silk Gloves
	[6272]	= { b=300 },	-- Pattern: Blue Linen Robe
	[6270]	= { b=200 },	-- Pattern: Blue Linen Vest
	[6274]	= { b=400 },	-- Pattern: Blue Overalls
	[14627]	= { b=800 },	-- Pattern: Bright Yellow Shirt
	[6401]	= { b=1100 },	-- Pattern: Dark Silk Shirt
	[6275]	= { b=800 },	-- Pattern: Greater Adept's Robe
	[4355]	= { b=1500 },	-- Pattern: Icy Cloak
	[10314]	= { b=4000 },	-- Pattern: Lavender Mageweave Shirt
	[10311]	= { b=3000 },	-- Pattern: Orange Martial Shirt
	[10317]	= { b=4000 },	-- Pattern: Pink Mageweave Shirt
	[5771]	= { b=200 },	-- Pattern: Red Linen Bag
	[5772]	= { b=500 },	-- Pattern: Red Woolen Bag
	[10326]	= { b=5000 },	-- Pattern: Tuxedo Jacket
	[10323]	= { b=4500 },	-- Pattern: Tuxedo Pants
	[10321]	= { b=4500 },	-- Pattern: Tuxedo Shirt
	[10325]	= { b=10000 },	-- Pattern: White Wedding Dress
	[10318]	= { b=7000 },	-- Pattern: Admiral's Hat
	[10728]	= { b=1500 },	-- Pattern: Black Swashbuckler's Shirt
	[7087]	= { b=1200 },	-- Pattern: Crimson Silk Cloak
	[7088]	= { b=5000 },	-- Pattern: Crimson Silk Robe
	[14630]	= { b=1000 },	-- Pattern: Enchanter's Cowl
	[14483]	= { b=16000 },	-- Pattern: Felcloth Pants
	[14526]	= { b=20000 },	-- Pattern: Mooncloth
	[14468]	= { b=12000 },	-- Pattern: Runecloth Bag
	[14488]	= { b=12000 },	-- Pattern: Runecloth Boots
	[14472]	= { b=12000 },	-- Pattern: Runecloth Cloak
	[14481]	= { b=16000 },	-- Pattern: Runecloth Gloves
	[14469]	= { b=12000 },	-- Pattern: Runecloth Robe
	[21358]	= { b=12000 },	-- Pattern: Soul Pouch
	[18487]	= { b=40000, note=DM_LIBRARY  },			-- Pattern: Mooncloth Robe
	[17018]	= { b=80000, note=THORIUM_FRIENDLY  },	-- Pattern: Flarecore Gloves
	[19220]	= { b=90000, note=THORIUM_REVERED  },	-- Pattern: Flarecore Leggings
	[17017]	= { b=180000, note=THORIUM_HONORED  },	-- Pattern: Flarecore Mantle
	[19219]	= { b=60000, note=THORIUM_REVERED  },	-- Pattern: Flarecore Robe
	[19215]	= { b=22000, 	note=REQ_FACTION  },		-- Pattern: Wisdom of the Timbermaw
	[19218]	= { b=40000, 	note=REQ_FACTION  },		-- Pattern: Mantle of the Timbermaw
	[19216]	= { b=22000, note=REQ_FACTION  },		-- Pattern: Argent Boots
	[19217]	= { b=40000, note=REQ_FACTION  },		-- Pattern: Argent Shoulders
	[19766]	= { b=50000, note=REQ_FACTION  },		-- Pattern: Bloodvine Boots
	[19765]	= { b=50000, note=REQ_FACTION  },		-- Pattern: Bloodvine Leggings
	[19764]	= { b=50000, note=REQ_FACTION  },		-- Pattern: Bloodvine Vest
	[22310]	= { b=20000, note=REQ_FACTION  },		-- Pattern: Cenarion Herb Bag
	[22312]	= { b=50000, note=REQ_FACTION  },		-- Pattern: Satchel of Cenarius
	[22307]	= { b=6000 },								-- Pattern: Enchanted Mageweave Pouch
	[22308]	= { b=20000, note=REQ_FACTION  },		-- Pattern: Enchanted Runecloth Bag
	[22683] = { b=90000, note=REQ_FACTION }, -- Pattern: Gaea's Embrace 
	[22773] = { b=50000, note=REQ_FACTION  }, -- Pattern: Sylvan Crown 
	[22772] = { b=50000, note=REQ_FACTION  }, -- Pattern: Sylvan Shoulders 
	[22774] = { b=50000, note=REQ_FACTION  }, -- Pattern: Sylvan Vest 
	

-- Cooking
	[43506] = { i="3 Dalaran Cooking Award", b=0 },
	[43505] = { i="3 Dalaran Cooking Award", b=0 },
	[43037] = { i="3 Dalaran Cooking Award", b=0 },
	[43036] = { i="3 Dalaran Cooking Award", b=0 },
	[43035] = { i="3 Dalaran Cooking Award", b=0 },
	[43034] = { i="3 Dalaran Cooking Award", b=0 },
	[43033] = { i="3 Dalaran Cooking Award", b=0 },
	[43032] = { i="3 Dalaran Cooking Award", b=0 },
	[43031] = { i="3 Dalaran Cooking Award", b=0 },
	[43030] = { i="3 Dalaran Cooking Award", b=0 },
	[43029] = { i="3 Dalaran Cooking Award", b=0 },
	[43028] = { i="3 Dalaran Cooking Award", b=0 },
	[43027] = { i="3 Dalaran Cooking Award", b=0 },
	[43026] = { i="3 Dalaran Cooking Award", b=0 },
	[43025] = { i="3 Dalaran Cooking Award", b=0 },
	[43024] = { i="3 Dalaran Cooking Award", b=0 },
	[43023] = { i="3 Dalaran Cooking Award", b=0 },
	[43022] = { i="3 Dalaran Cooking Award", b=0 },
	[43021] = { i="3 Dalaran Cooking Award", b=0 },
	[43020] = { i="3 Dalaran Cooking Award", b=0 },
	[43019] = { i="3 Dalaran Cooking Award", b=0 },
	[43018] = { i="3 Dalaran Cooking Award", b=0 },
	[16072]	= { b=10000 },	-- Expert Cookbook
	[13949]	= { b=20000 },	-- Recipe: Baked Salmon
	[4609]	= { b=1000 },	-- Recipe: Barbecued Buzzard Wing
	[2889]	= { b=240 },	-- Recipe: Beer Basted Boar Ribs
	[3734]	= { b=1600 },	-- Recipe: Big Bear Steak
	[3679]	= { b=400 },	-- Recipe: Blood Sausage
	[6325]	= { b=40 },		-- Recipe: Brilliant Smallfish
	[6330]	= { b=1200 },	-- Recipe: Bristle Whisker Catfish
	[5528]	= { b=800 },	-- Recipe: Clam Chowder
	[2698]	= { b=400 },	-- Recipe: Cooked Crab Claw
	[3681]	= { b=1600 },	-- Recipe: Crocolisk Gumbo
	[3678]	= { b=400 },	-- Recipe: Crocolisk Steak
	[3682]	= { b=1600 },	-- Recipe: Curiously Tasty Omelet
	[12239]	= { b=7000 },	-- Recipe: Dragonbreath Chili
	[5485]	= { b=400 },	-- Recipe: Fillet of Frenzy
	[3683]	= { b=1600 },	-- Recipe: Gooey Spider Cake
	[2697]	= { b=400 },	-- Recipe: Goretusk Liver Pie
	[12240]	= { b=7000 },	-- Recipe: Heavy Kodo Stew
	[20075]	= { b=2000 },	-- Recipe: Heavy Crocolisk Stew
	[3735]	= { b=1800 },	-- Recipe: Hot Lion Chops
	[12229]	= { b=5000 },	-- Recipe: Hot Wolf Ribs
	[12231]	= { b=3000 },	-- Recipe: Jungle Stew
	[5489]	= { b=1200 },	-- Recipe: Lean Venison
	[13947]	= { b=20000 },	-- Recipe: Lobster Stew
	[6329]	= { b=400 },	-- Recipe: Loch Frenzy Delight
	[6328]	= { b=400 },	-- Recipe: Longjaw Mud Snapper
	[13948]	= { b=20000 },	-- Recipe: Mightfish Steak
	[17062]	= { b=2200 },	-- Recipe: Mithril Head Trout
	[3680]	= { b=1600 },	-- Recipe: Murloc Fin Soup
	[12233]	= { b=3000 },	-- Recipe: Mystery Stew
	[6368]	= { b=400 },	-- Recipe: Rainbow Fin Albacore
	[2699]	= { b=800 },	-- Recipe: Redridge Goulash
	[12228]	= { b=5000 },	-- Recipe: Roast Raptor
	[6369]	= { b=2200 },	-- Recipe: Rockscale Cod
	[2701]	= { b=1600 },	-- Recipe: Seasoned Wolf Kabob
	[6326]	= { b=40 },		-- Recipe: Slitherskin Mackerel
	[6892]	= { b=250 },	-- Recipe: Smoked Bear Meat
	[16111]	= { b=12000 },	-- Recipe: Spiced Chili Crab
	[2700]	= { b=400 },	-- Recipe: Succulent Pork Ribs
	[18046]	= { b=12000 },	-- Recipe: Tender Wolf Steak
	[728]	= { b=200 },	-- Recipe: Westfall Stew
	[12226]	= { b=25 },		-- Recipe: Crispy Bat Wing
	[5488]	= { b=400 },	-- Recipe: Crispy Lizard Tail
	[5484]	= { b=240 },	-- Recipe: Roasted Kodo Meat
	[5483]	= { b=140 },	-- Recipe: Scorpid Surprise
	[5486]	= { b=440 },	-- Recipe: Strider Stew
	[12232]	= { b=5000 },	-- Recipe: Carrion Surprise
	[13940]	= { b=16000 },	-- Recipe: Cooked Glossy Mightfish
	[13941]	= { b=16000 },	-- Recipe: Filet of Redgill
	[6039]	= { b=5000 },	-- Recipe: Giant Clam Scorcho
	[13942]	= { b=16000 },	-- Recipe: Grilled Squid
	[13943]	= { b=16000 },	-- Recipe: Hot Smoked Bass
	[12227]	= { b=1600 },	-- Recipe: Lean Wolf Steak
	[16110]	= { b=12000 },	-- Recipe: Monster Omelet
	[13945]	= { b=20000 },	-- Recipe: Nightfin Soup
	[13946]	= { b=20000 },	-- Recipe: Poached Sunscale Salmon
	[13939]	= { b=16000 },	-- Recipe: Spotted Yellowtail
	[16767]	= { b=3000 },	-- Recipe: Undermine Clam Chowder
	[21099]	= { b=500 },	-- Recipe: Smoked Sagefish
	[21219]	= { b=5000 },	-- Recipe: Sagefish Delight
	[17201]	= { b=240, note=SEASONAL_VENDOR  },	-- Recipe: Egg Nog
	[17200]	= { b=25, note=SEASONAL_VENDOR  },	-- Recipe: Gingerbread Cookie
	[18160]	= { b=200, note=REQ_FACTION },								-- Recipe: Thistle Tea
	[35566] = { b=20000 },							-- Recipe: Juicy Bear Burger
	[35564] = { b=20000 },							-- Recipe: Charred Bear Kabobs

-- Fishing
	[16083]	= { b=10000 },	-- Expert Fishing - The Bass and You

-- First Aid
	[16084]	= { b=10000 },	-- Expert First Aid - Under Wraps
	[16112]	= { b=2200 },	-- Manual: Heavy Silk Bandage
	[16113]	= { b=5000 },	-- Manual: Mageweave Bandage
	[19442]	= { b=100000, note=REQ_FACTION},	-- Formula: Powerful Anti-Venom

------------------------------------------------------
-- Burning Crusade content
------------------------------------------------------

-- Alchemy
	[13517] = { b=80000, note=REQ_FACTION },		-- Recipe: Alchemist's Stone
	[22900] = { b=30000 },							-- Recipe: Elixir of Camouflage
	[22901] = { b=30000 },							-- Recipe: Sneaking Potion
	[22902] = { b=36000 },							-- Recipe: Elixir of Major Frost Power
	[22905] = { b=45000, note=REQ_FACTION },		-- Recipe: Elixir of Major Agility
	[22906] = { i="30 Glowcap", note=REQ_FACTION },	-- Recipe: Shrouding Potion
	[22907] = { b=45000 },							-- Recipe: Super Mana Potion
	[22908] = { b=60000, note=REQ_FACTION },		-- Recipe: Elixir of Major Firepower
	[22909] = { b=45000 },							-- Recipe: Elixir of Major Defense
	[22910] = { b=80000, note=REQ_FACTION },		-- Recipe: Elixir of Major Shadow Power
	[22911] = { b=50000 },							-- Recipe: Major Dreamless Sleep Potion
	[22915] = { b=80000, note=REQ_FACTION },		-- Recipe: Transmute Primal Air to Fire
	[22916] = { i="25 Glowcap", note=REQ_FACTION },	-- Recipe: Transmute Primal Earth to Water
	[22918] = { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Primal Water to Air
	[22922] = { b=90000, note=REQ_FACTION },		-- Recipe: Major Nature Protection Potion
	[23574] = { b=80000 },							-- Recipe: Transmute Primal Might
	[24001]	= { b=45000, note=REQ_FACTION },		-- Recipe: Elixir of Major Agility
	[25869] = { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Earthstorm Diamond
	[25870] = { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Skyfire Diamond
	[29232]	= { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Skyfire Diamond
	[30443] = { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Primal Fire to Earth
	[22917] = { b=72000, note=REQ_FACTION },		-- Recipe: Transmute Primal Fire to Earth
	[31354] = { b=40000, note=REQ_FACTION },		-- Recipe: Flask of the Titans
	[31355] = { b=40000, note=REQ_FACTION },		-- Recipe: Flask of Supreme Power
	[31356] = { b=36000, note=REQ_FACTION },		-- Recipe: Flask of Distilled Wisdom
	[31357] = { b=40000, note=REQ_FACTION },		-- Recipe: Flask of Chromatic Resistance
	[32070]	= { b=40000, note=REQ_FACTION },		-- Recipe: Earthen Elixir
	[32071]	= { i="2 Halaa Research Token", b=0 },	-- Recipe: Elixir of Ironskin
	[33209] = { b=40000,	note=REQ_FACTION },		-- Recipe: Flask of Chromatic Wonder
	[35752] = { b=250000,	note=REQ_FACTION },				-- Recipe: Guardian's Alchemist Stone
	[35753] = { b=250000,	note=REQ_FACTION },				-- Recipe: Sorcerer's Alchemist Stone
	[35754] = { b=250000,	note=REQ_FACTION },				-- Recipe: Redeemer's Alchemist Stone
	[35755] = { b=250000,	note=REQ_FACTION },				-- Recipe: Assassin's Alchemist Stone

-- Blacksmithing
	[23590] = { b=40000 },							-- Plans: Adamantite Maul
	[23591] = { b=40000 },							-- Plans: Adamantite Cleaver
	[23592] = { b=40000 },							-- Plans: Adamantite Dagger
	[23593] = { b=40000 },							-- Plans: Adamantite Rapier
	[23594] = { b=54000 },							-- Plans: Adamantite Plate Bracers
	[23595] = { b=54000 },							-- Plans: Adamantite Plate Gloves
	[23596] = { b=54000 },							-- Plans: Adamantite Breastplate
	[23597] = { b=60000, note=REQ_FACTION },		-- Plans: Enchanted Adamantite Belt
	[23598] = { b=60000, note=REQ_FACTION },		-- Plans: Enchanted Adamantite Boots
	[23599] = { b=60000, note=REQ_FACTION },		-- Plans: Enchanted Adamantite Breastplate
	[23600] = { b=80000, note=REQ_FACTION },		-- Plans: Enchanted Adamantite Leggings
	[23601] = { b=60000, note=REQ_FACTION },		-- Plans: Flamebane Bracers
	[23602] = { b=60000, note=REQ_FACTION },		-- Plans: Flamebane Helm
	[23603] = { b=60000, note=REQ_FACTION },		-- Plans: Flamebane Gloves
	[23604] = { b=80000, note=REQ_FACTION },		-- Plans: Flamebane Breastplate
	[23618] = { b=54000 },							-- Plans: Adamantite Sharpening Stone
	[23619] = { b=54000, note=REQ_FACTION },		-- Plans: Felsteel Shield Spike
	[23638] = { b=60000 },							-- Plans: Lesser Rune of Shielding
	[24002]	= { b=54000, note=REQ_FACTION },		-- Plans: Felsteel Shield Spike
	[25526] = { b=54000 },							-- Plans: Greater Rune of Warding
	[25846] = { b=40000 },							-- Plans: Adamantite Rod
	[25847] = { b=120000 },							-- Plans: Eternium Rod
	[28632] = { b=54000 },							-- Plans: Adamantite Weightstone
	[31390] = { b=216000 },							-- Plans: Wildguard Breastplate
	[31391] = { b=216000 },							-- Plans: Wildguard Leggings
	[31392] = { b=216000 },							-- Plans: Wildguard Helm
	[31393]	= { b=240000, note=REQ_FACTION },		-- Plans: Iceguard Breastplate
	[31394]	= { b=240000, note=REQ_FACTION },		-- Plans: Iceguard Leggings
	[31395]	= { b=240000, note=REQ_FACTION },		-- Plans: Iceguard Helm
	[32442]	= { b=80000, note=REQ_FACTION },		-- Plans: Shadesteel Bracers
	[32444]	= { b=80000, note=REQ_FACTION },		-- Plans: Shadesteel Girdle
	[32443]	= { b=80000, note=REQ_FACTION },		-- Plans: Shadesteel Greaves
	[32441]	= { b=80000, note=REQ_FACTION },		-- Plans: Shadesteel Sabots

-- Enchanting
	[22531] = { b=54000 },							-- Formula: Enchant Bracer - Superior Healing
	[22536] = { b=100000 },							-- Formula: Enchant Ring - Spellpower
	[22537] = { b=100000, note=REQ_FACTION },		-- Formula: Enchant Ring - Healing Power
	[22538] = { b=200000 },							-- Formula: Enchant Ring - Stats
	[22539] = { b=60000 },							-- Formula: Enchant Shield - Intellect
	[22547] = { b=54000 },							-- Formula: Enchant Chest - Exceptional Stats
	[22562] = { b=50000 },							-- Formula: Superior Mana Oil
	[22563] = { b=70000 },							-- Formula: Superior Wizard Oil
	[22565] = { b=60000 },							-- Formula: Large Prismatic Shard
	[24000]	= { b=54000, note=REQ_FACTION },		-- Formula: Enchant Bracer - Superior Healing
	[24003]	= { b=54000, note=REQ_FACTION },		-- Formula: Enchant Chest - Exceptional Stats
	[25848] = { b=90000 },							-- Formula: Runed Adamantite Rod
	[25849] = { b=120000 },							-- Formula: Runed Eternium Rod
	[28271] = { b=72000 },							-- Formula: Enchant Gloves - Spell Strike
	[28272] = { b=80000 },							-- Formula: Enchant Gloves - Major Spellpower
	[28273] = { b=60000, note=REQ_FACTION },		-- Formula: Enchant Gloves - Major Healing
	[28274] = { b=36000 },							-- Formula: Enchant Cloak - Spell Penetration
	[28281] = { b=60000, note=REQ_FACTION },		-- Formula: Enchant Weapon - Major Healing
	[28282] = { b=40000 },							-- Formula: Enchant Shield - Major Stamina
	[22535]	= { b=100000, note=REQ_FACTION },		-- Formula: Enchant Ring - Weapon Might
	[22552]	= { b=60000, note=REQ_FACTION },		-- Formula: Enchant Weapon - Major Striking
	[33165] = { b=30000,	note=REQ_FACTION },				-- Formula: Enchant Weapon - Greater Agility
	[33148] = { b=90000,	note=REQ_FACTION },				-- Formula: Enchant Cloak - Dodge
	[33149] = { b=90000,	note=REQ_FACTION },				-- Formula: Enchant Cloak - Stealth
	[33150] = { b=100000,	note=REQ_FACTION },				-- Formula: Enchant Cloak - Subtlety
	[33151] = { b=90000,	note=REQ_FACTION },				-- Formula: Enchant Cloak - Subtlety
	[33152] = { b=100000,	note=REQ_FACTION },				-- Formula: Enchant Gloves - Superior Agility
	[33153] = { b=90000,	note=REQ_FACTION },				-- Formula: Enchant Gloves - Threat
	[34872] = { b=150000,	note=REQ_FACTION },				-- Formula: Void Shatter
	[35500] = { b=150000,	note=REQ_FACTION },				-- Formula: Enchant Chest - Defense

-- Engineering
	[23799] = { b=80000 },							-- Schematic: Adamantite Rifle
	[23807] = { b=60000 },							-- Schematic: Adamantite Scope
	[23811] = { b=60000 },							-- Schematic: White Smoke Flare
	[23814] = { b=54000 },							-- Schematic: Green Smoke Flare
	[23815] = { b=60000 },							-- Schematic: Adamantite Shells
	[23816] = { b=40000 },							-- Schematic: Fel Iron Toolbox
	[23805] = { b=80000 },							-- Schematic: Ultra-Spectropic Detection Goggles
	[23803] = { b=60000 },							-- Schematic: Cogspinner Goggles
	[23874]	= { b=80000, note=REQ_FACTION },		-- Schematic: Elemental Seaforium Charge                                     
	[32381]	= { b=16000 },							-- Schematic: Fused Wiring                                               

-- Jewelcrafting
	[20970] = { b=1500 },							-- Design: Pendant of the Agate Shield
	[21954] = { b=10000 },							-- Design: Ring of Bitter Shadows
	[23130] = { b=36000 },							-- Design: Teardrop Blood Garnet
	[23131] = { b=45000 },							-- Design: Bold Blood Garnet
	[23134] = { b=54000 },							-- Design: Delicate Blood Garnet
	[23135] = { b=36000 },							-- Design: Inscribed Flame Spessarite
	[23136] = { b=45000 },							-- Design: Luminous Flame Spessarite
	[23137] = { b=54000 },							-- Design: Glinting Flame Spessarite
	[23138] = { b=60000, note=REQ_FACTION },		-- Design: Potent Flame Spessarite
	[23140] = { b=36000 },							-- Design: Radiant Deep Peridot
	[23141] = { b=45000 },							-- Design: Jagged Deep Peridot
	[23142] = { b=54000 },							-- Design: Enduring Deep Peridot
	[23144] = { b=36000 },							-- Design: Glowing Shadow Draenite
	[23146] = { b=54000 },							-- Design: Shifting Shadow Draenite
	[23147] = { b=54000 },							-- Design: Sovereign Shadow Draenite
	[23148] = { b=36000 },							-- Design: Brilliant Golden Draenite
	[23150] = { b=54000 },							-- Design: Thick Golden Draenite
	[23151] = { b=54000 },							-- Design: Rigid Golden Draenite
	[23152] = { b=36000 },							-- Design: Solid Azure Moonstone
	[23153] = { b=45000 },							-- Design: Sparkling Azure Moonstone
	[23155] = { b=54000 },							-- Design: Lustrous Azure Moonstone
	[24174] = { b=120000 },							-- Design: Pendant of Frozen Flame
	[24175] = { b=120000, note=REQ_FACTION },		-- Design: Pendant of Thawing
	[24176] = { b=120000, note=REQ_FACTION },		-- Design: Pendant of Withering
	[24177] = { b=120000, note=REQ_FACTION },		-- Design: Pendant of Shadow's End
	[24178] = { b=108000 },							-- Design: Pendant of the Null Rune
	[24179] = { b=120000, note=REQ_FACTION },		-- Design: Felsteel Boar
	[24180] = { b=108000 },							-- Design: Dawnstone Crab
	[24181] = { b=120000 },							-- Design: Living Ruby Serpent
	[24182] = { b=120000, note=REQ_FACTION },		-- Design: Talasite Owl
	[24183] = { b=108000 },							-- Design: Nightseye Panther
	[25904] = { b=120000, note=REQ_FACTION },		-- Design: Insightful Earthstorm Diamond
	[25908] = { b=108000 },							-- Design: Swift Skyfire Diamond
	[25910] = { b=120000 },							-- Design: Enigmatic Skyfire Diamond
	[28291] = { b=54000 },							-- Design: Smooth Golden Draenite
	[28596] = { b=45000 },							-- Design: Bright Blood Garnet
	[30826] = { b=120000, note=REQ_FACTION },		-- Design: Ring of Arcane Shielding
	[31358]	= { b=10800, note=REQ_FACTION },		-- Design: Dawnstone Crab
	[31359]	= { b=54000, note=REQ_FACTION },		-- Design: Enduring Deep Peridot
	[31401] = { b=120000 },							-- Design: The Frozen Eye
	[31402] = { b=108000 },							-- Design: The Natural Ward
	[25902]	= { b=120000, note=REQ_FACTION },		-- Design: Powerful Earthstorm Diamond
	[25903]	= { b=120000, note=REQ_FACTION },		-- Design: Bracing Earthstorm Diamond
	[32299]	= { b=60000, note=REQ_FACTION },		-- Design: Balanced Shadowsong Amethyst
	[32274]	= { b=60000, note=REQ_FACTION },		-- Design: Bold Crimson Spinel
	[32283]	= { b=60000, note=REQ_FACTION },		-- Design: Bright Crimson Spinel
	[32290]	= { b=60000, note=REQ_FACTION },		-- Design: Brilliant Lionseye
	[32311]	= { b=60000, note=REQ_FACTION },		-- Design: Dazzling Seaspray Emerald
	[32277]	= { b=60000, note=REQ_FACTION },		-- Design: Delicate Crimson Spinel
	[32309]	= { b=60000, note=REQ_FACTION },		-- Design: Enduring Seaspray Emerald
	[32293]	= { b=60000, note=REQ_FACTION },		-- Design: Gleaming Lionseye
	[32306]	= { b=60000, note=REQ_FACTION },		-- Design: Glinting Pyrestone
	[32301]	= { b=60000, note=REQ_FACTION },		-- Design: Glowing Shadowsong Amethyst
	[32300]	= { b=60000, note=REQ_FACTION },		-- Design: Infused Shadowsong Amethyst
	[32312]	= { b=60000, note=REQ_FACTION },		-- Design: Jagged Seaspray Emerald
	[32305]	= { b=60000, note=REQ_FACTION },		-- Design: Luminous Pyrestone
	[32288]	= { b=60000, note=REQ_FACTION },		-- Design: Lustrous Empyrean Sapphire
	[32304]	= { b=60000, note=REQ_FACTION },		-- Design: Potent Pyrestone
	[32310]	= { b=60000, note=REQ_FACTION },		-- Design: Radiant Seaspray Emerald
	[32302]	= { b=60000, note=REQ_FACTION },		-- Design: Royal Shadowsong Amethyst
	[32282]	= { b=60000, note=REQ_FACTION },		-- Design: Runed Crimson Spinel
	[32291]	= { b=60000, note=REQ_FACTION },		-- Design: Smooth Lionseye
	[32292] = { b=60000, note=REQ_FACTION },		-- Design: Rigid Lionseye
	[32286]	= { b=60000, note=REQ_FACTION },		-- Design: Solid Empyrean Sapphire
	[32287]	= { b=60000, note=REQ_FACTION },		-- Design: Sparkling Empyrean Sapphire
	[32284]	= { b=60000, note=REQ_FACTION },		-- Design: Subtle Crimson Spinel
	[32281]	= { b=60000, note=REQ_FACTION },		-- Design: Teardrop Crimson Spinel
	[32294]	= { b=60000, note=REQ_FACTION },		-- Design: Thick Lionseye
	[32308]	= { b=60000, note=REQ_FACTION },		-- Design: Wicked Pyrestone
	[33622]	= { b=120000, note=REQ_FACTION },		-- Design: Relentless Earthstorm Diamond
	[32412]	= { b=120000, note=REQ_FACTION },		-- Design: Relentless Earthstorm Diamond
	[33155] = { b=108000,	note=REQ_FACTION },				-- Design: Kailee's Rose
	[33156] = { b=108000,	note=REQ_FACTION },				-- Design: Crimson Sun
	[33157] = { b=108000,	note=REQ_FACTION },				-- Design: Falling Star
	[33158] = { b=120000,	note=REQ_FACTION },				-- Design: Stone of Blades
	[33159] = { b=108000,	note=REQ_FACTION },				-- Design: Blood of Amber
	[33160] = { b=120000,	note=REQ_FACTION },				-- Design: Facet of Eternity
	[33305] = { b=108000,	note=REQ_FACTION },				-- Design: Don Julio's Heart
	[33783]	= { i="4 Halaa Research Token", b=0 },	-- Design: Steady Talasite
	[24208] = { b=120000 },							-- Design: Mystic Dawnstone
	[35505] = { b=150000,	note=REQ_FACTION },				-- Design: Ember Skyfire Diamond
	[35502] = { b=150000,	note=REQ_FACTION },				-- Design: Eternal Earthstorm Diamond
	[35695] = { b=250000,	note=REQ_FACTION },				-- Design: Figurine - Empyrean Tortoise
	[35696] = { b=250000,	note=REQ_FACTION },				-- Design: Figurine - Khorium Boar
	[35697] = { b=250000,	note=REQ_FACTION },				-- Design: Figurine - Crimson Serpent
	[35698] = { b=250000,	note=REQ_FACTION },				-- Design: Figurine - Shadowsong Panther
	[35699] = { b=250000,	note=REQ_FACTION },				-- Design: Figurine - Seaspray Albatross
	[35708] = { b=120000,	note=REQ_FACTION },				-- Design: Regal Nightseye
	[35766] = { b=60000,	note=REQ_FACTION },				-- Design: Steady Seaspray Emerald
	[35767] = { b=60000,	note=REQ_FACTION },				-- Design: Reckless Pyrestone
	[35768] = { b=60000,	note=REQ_FACTION },				-- Design: Quick Lionseye
	[35769] = { b=60000,	note=REQ_FACTION },				-- Design: Forceful Seaspray Emerald
	
-- Leatherworking
	[25720] = { b=50000 },							-- Pattern: Heavy Knothide Leather
	[25721] = { b=50000, note=REQ_FACTION },		-- Pattern: Vindicator's Armor Kit
	[25722] = { b=50000, note=REQ_FACTION },		-- Pattern: Magister's Armor Kit
	[25725] = { b=50000 },							-- Pattern: Riding Crop
	[25726] = { b=10000 },							-- Pattern: Comfortable Insoles
	[25732] = { b=108000 },							-- Pattern: Fel Leather Gloves
	[25733] = { b=126000 },							-- Pattern: Fel Leather Boots
	[25734] = { b=126000 },							-- Pattern: Fel Leather Leggings
	[25735] = { b=144000 },							-- Pattern: Heavy Clefthoof Vest
	[25736] = { b=126000 },							-- Pattern: Heavy Clefthoof Leggings
	[25737] = { b=126000 },							-- Pattern: Heavy Clefthoof Boots
	[25738]	= { b=10800, note=REQ_FACTION },		-- Pattern: Felstalker Belt
	[25739]	= { b=14400, note=REQ_FACTION },		-- Pattern: Felstalker Bracers
	[25740]	= { b=14400, note=REQ_FACTION },		-- Pattern: Felstalker Breastplate
	[25741]	= { b=10800, note=REQ_FACTION },		-- Pattern: Netherfury Belt
	[25742]	= { b=10800, note=REQ_FACTION },		-- Pattern: Netherfury Leggings
	[25743]	= { b=10800, note=REQ_FACTION },		-- Pattern: Netherfury Boots
	[29213] = { b=108000 },							-- Pattern: Felstalker Belt
	[29214] = { b=144000 },							-- Pattern: Felstalker Bracers
	[29215] = { b=144000 },							-- Pattern: Felstalker Breastplate
	[29217] = { b=108000, note=REQ_FACTION },		-- Pattern: Netherfury Belt
	[29218] = { b=108000, note=REQ_FACTION },		-- Pattern: Netherfury Boots
	[29219] = { b=108000, note=REQ_FACTION },		-- Pattern: Netherfury Leggings
	[29664]	= { b=45000, note=REQ_FACTION },		-- Pattern: Reinforced Mining Bag
	[29677] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Felscale Leggings
	[29682] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Felscale Gloves
	[29684] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Felscale Boots
	[29689] = { b=80000, note=REQ_FACTION },		-- Pattern: Flamescale Leggings
	[29691] = { b=80000, note=REQ_FACTION },		-- Pattern: Flamescale Boots
	[29693] = { b=80000, note=REQ_FACTION },		-- Pattern: Flamescale Belt
	[29698] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Clefthoof Leggings
	[29700] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Clefthoof Gloves
	[29701] = { b=80000, note=REQ_FACTION },		-- Pattern: Enchanted Clefthoof Boots
	[29702] = { b=80000, note=REQ_FACTION },		-- Pattern: Blastguard Pants
	[29703] = { b=80000, note=REQ_FACTION },		-- Pattern: Blastguard Boots
	[29704] = { b=80000, note=REQ_FACTION },		-- Pattern: Blastguard Belt
	[29713] = { b=120000 },							-- Pattern: Drums of Panic
	[29717] = { b=120000, note=REQ_FACTION },		-- Pattern: Drums of Battle
	[29719] = { b=54000 },							-- Pattern: Cobrahide Leg Armor
	[29720] = { b=54000 },							-- Pattern: Clefthide Leg Armor
	[29721] = { b=108000 },							-- Pattern: Nethercleft Leg Armor
	[29722] = { b=108000 },							-- Pattern: Nethercobra Leg Armor
	[30444] = { b=45000, note=REQ_FACTION },		-- Pattern: Reinforced Mining Bag
	[31361]	= { b=54000, note=REQ_FACTION },		-- Pattern: Cobrahide Leg Armor
	[31362]	= { b=10800, note=REQ_FACTION },		-- Pattern: Nethercobra Leg Armor
	[32429]	= { b=80000, note=REQ_FACTION },		-- Pattern: Boots of Shackled Souls
	[32430]	= { b=80000, note=REQ_FACTION },		-- Pattern: Bracers of Shackled Souls
	[32431]	= { b=80000, note=REQ_FACTION },		-- Pattern: Greaves of Shackled Souls
	[32436]	= { b=80000, note=REQ_FACTION },		-- Pattern: Redeemed Soul Cinch
	[32435]	= { b=80000, note=REQ_FACTION },		-- Pattern: Redeemed Soul Legguards
	[32433]	= { b=80000, note=REQ_FACTION },		-- Pattern: Redeemed Soul Mocassins
	[32434]	= { b=80000, note=REQ_FACTION },		-- Pattern: Redeemed Soul Wristguards
	[32432]	= { b=80000, note=REQ_FACTION },		-- Pattern: Waistguard of Shackled Souls
	[33205] = { b=240000,	note=REQ_FACTION },				-- Pattern: Shadowprowler's Chestguard
	[33124] = { b=50000,	note=REQ_FACTION },				-- Pattern: Cloak of Darkness
	[34173] = { b=160000,	note=REQ_FACTION },		-- Pattern: Drums of Speed
	[34175] = { b=160000,	note=REQ_FACTION },		-- Pattern: Drums of Restoration
	[34201] = { b=160000,	note=REQ_FACTION },		-- Pattern: Netherscale Ammo Pouch
	[34172] = { b=160000,	note=REQ_FACTION },		-- Pattern: Drums of Speed
	[34174] = { b=160000,	note=REQ_FACTION },		-- Pattern: Drums of Restoration
	[34218] = { b=160000,	note=REQ_FACTION },		-- Pattern: Netherscale Ammo Pouch
	[34200] = { b=160000,	note=REQ_FACTION },		-- Pattern: Quiver of a Thousand Feathers
	
-- Tailoring
	[21892] = { b=40000 },							-- Pattern: Bolt of Imbued Netherweave
	[21893] = { b=40000 },							-- Pattern: Imbued Netherweave Bag
	[21894] = { b=40000 },							-- Pattern: Bolt of Soulcloth
	[21895] = { b=40000 },							-- Pattern: Primal Mooncloth
	[21896] = { b=40000 },							-- Pattern: Netherweave Robe
	[21897] = { b=40000 },							-- Pattern: Netherweave Tunic
	[21898] = { b=60000 },							-- Pattern: Imbued Netherweave Pants
	[21899] = { b=60000 },							-- Pattern: Imbued Netherweave Boots
	[21900] = { b=60000 },							-- Pattern: Imbued Netherweave Robe
	[21901] = { b=60000 },							-- Pattern: Imbued Netherweave Tunic
	[21902] = { b=72000 },							-- Pattern: Soulcloth Gloves
	[21908] = { b=60000 },							-- Pattern: Spellfire Belt
	[21909] = { b=60000 },							-- Pattern: Spellfire Gloves
	[21910] = { b=60000 },							-- Pattern: Spellfire Vest
	[21911] = { b=60000 },							-- Pattern: Spellfire Bag
	[21912] = { b=60000 },							-- Pattern: Frozen Shadoweave Shoulders
	[21913] = { b=60000 },							-- Pattern: Frozen Shadoweave Vest
	[21914] = { b=60000 },							-- Pattern: Frozen Shadoweave Boots
	[21915] = { b=60000 },							-- Pattern: Ebon Shadowbag
	[21916] = { b=60000 },							-- Pattern: Primal Mooncloth Belt
	[21917] = { b=60000 },							-- Pattern: Primal Mooncloth Robe
	[21918] = { b=60000 },							-- Pattern: Primal Mooncloth Shoulders
	[21919] = { b=60000 },							-- Pattern: Primal Mooncloth Bag
	[24292] = { b=60000, note=REQ_FACTION },		-- Pattern: Mystic Spellthread
	[24293] = { b=60000, note=REQ_FACTION },		-- Pattern: Silver Spellthread
	[24295] = { b=360000, note=REQ_FACTION },		-- Pattern: Golden Spellthread
	[24294] = { b=360000, note=REQ_FACTION },		-- Pattern: Runic Spellthread
	[24314] = { b=36000 },							-- Pattern: Bag of Jewels
	[24316] = { b=40000 },							-- Pattern: Spellcloth
	[30483] = { b=40000 },							-- Pattern: Shadowcloth
	[30833] = { b=60000, note=REQ_FACTION },		-- Pattern: Cloak of Arcane Evasion
	[30842] = { b=60000, note=REQ_FACTION },		-- Pattern: Flameheart Bracers
	[30843] = { b=80000, note=REQ_FACTION },		-- Pattern: Flameheart Gloves
	[30844] = { b=100000, note=REQ_FACTION },		-- Pattern: Flameheart Vest
	[32447]	= { b=80000, note=REQ_FACTION },		-- Pattern: Night's End
	[32438]	= { b=80000, note=REQ_FACTION },		-- Pattern: Soulguard Bracers
	[32440]	= { b=80000, note=REQ_FACTION },		-- Pattern: Soulguard Girdle
	[32439]	= { b=80000, note=REQ_FACTION },		-- Pattern: Soulguard Leggings
	[32437]	= { b=80000, note=REQ_FACTION },		-- Pattern: Soulguard Slippers

-- Cooking
	[22647] = { b=400 },							-- Recipe: Crunchy Spider Surprise
	[27685] = { b=40 },								-- Recipe: Lynx Steak
	[27687] = { b=400 },							-- Recipe: Bat Bites
	[27688] = { b=18000 },							-- Recipe: Ravager Dog
	[27689] = { b=20000 },							-- Recipe: Sporeling Snack
	[27690] = { b=30000 },							-- Recipe: Blackened Basilisk
	[27691] = { b=27000 },							-- Recipe: Roasted Clefthoof
	[27692] = { b=30000 },							-- Recipe: Warp Burger
	[27694] = { b=18000 },							-- Recipe: Blackened Trout
	[27695] = { b=18000 },							-- Recipe: Feltail Delight
	[27696] = { b=20000 },							-- Recipe: Blackened Sporefish
	[27697] = { b=27000 },							-- Recipe: Grilled Mudfish
	[27698] = { b=27000 },							-- Recipe: Poached Bluefish
	[27699] = { b=30000 },							-- Recipe: Golden Fish Sticks
	[27700] = { b=30000 },							-- Recipe: Spicy Crawdad
	[27736] = { b=18000 },							-- Master Cookbook
	[27693] = { b=30000 },							-- Recipe: Talbuk Steak
	[30156] = { i="1 Glowcap", b=0 },				-- Recipe: Clam Bar
	[31674] = { b=30000 },							-- Recipe: Crunchy Serpent
	[31675] = { b=30000 },							-- Recipe: Mok'Nathal Shortribs

-- Fishing
	[27532] = { b=50000 },							-- Master Fishing - The Art of Angling

-- First Aid
	[21992] = { b=18000 },							-- Manual: Netherweave Bandage
	[21993] = { b=36000 },							-- Manual: Heavy Netherweave Bandage
	[22012] = { b=45000 },							-- Master First Aid - Doctor in the House

};

SP_DarkmoonInfo = {
	[19933]	= DARKMOON,		-- Glowing Scorpid Blood
	[11404]	= DARKMOON,		-- Evil Bat Eye
	[5117]	= DARKMOON,		-- Vibrant Plume
	[11407]	= DARKMOON,		-- Torn Bear Pelt
	[4582]	= DARKMOON,		-- Soft Bushy Tail
	[5134]	= DARKMOON,		-- Small Furry Paw
};

SP_TokenInfo = {
-- ZG uncommon/rare tokens are no longer used for class-gear quests (only remaining use is to turn in for rep)
--	[19698]	=	{ 19835, 19827, 19831, 19838, 19842, 20034 },	-- Zulian Coin
--	[19699]	=	{ 19841, 19830, 19832, 19835, 19839, 19845 },	-- Razzashi Coin
--	[19700]	=	{ 19834, 19840, 19842, 19828, 19832, 19849 },	-- Hakkari Coin
--	[19701]	=	{ 19838, 19824, 19845, 19831, 19829, 19848 },	-- Gurubashi Coin
--	[19702]	=	{ 19825, 19823, 19848, 19836, 19840, 19846 },	-- Vilebranch Coin
--	[19703]	=	{ 19828, 19849, 19846, 19827, 19841, 19824 },	-- Witherbark Coin
--	[19704]	=	{ 19839, 19843, 20034, 19825, 19822, 19833 },	-- Sandfury Coin
--	[19705]	=	{ 19833, 19829, 20033, 19826, 19834, 19823 },	-- Skullsplitter Coin
--	[19706]	=	{ 19836, 19826, 19822, 19843, 19830, 20033 },	-- Bloodscalp Coin
--
--	[19707]	=	{ 19827, 19840, 19848 },	-- Red Hakkari Bijou
--	[19708]	=	{ 19836, 19830, 19846 },	-- Blue Hakkari Bijou
--	[19709]	=	{ 19843, 19833, 19824 },	-- Yellow Hakkari Bijou
--	[19710]	=	{ 19842, 19849, 19845 },	-- Orange Hakkari Bijou
--	[19711]	=	{ 19839, 19823, 19832 },	-- Green Hakkari Bijou
--	[19712]	=	{ 19835, 19826, 19829 },	-- Purple Hakkari Bijou
--	[19713]	=	{ 19838, 19822, 19841 },	-- Bronze Hakkari Bijou
--	[19714]	=	{ 19831, 20033, 20034 },	-- Silver Hakkari Bijou
--	[19715]	=	{ 19825, 19834, 19828 },	-- Gold Hakkari Bijou

	[19813]	=	{ 19782 },	-- Punctured Voodoo Doll (warrior)
	[19814]	=	{ 19784 },	-- Punctured Voodoo Doll (rogue)
	[19815]	=	{ 19783 },	-- Punctured Voodoo Doll (paladin)
	[19816]	=	{ 19785 },	-- Punctured Voodoo Doll (hunter)
	[19817]	=	{ 19786 },	-- Punctured Voodoo Doll (shaman)
	[19818]	=	{ 19787 },	-- Punctured Voodoo Doll (mage)
	[19819]	=	{ 19788 },	-- Punctured Voodoo Doll (warlock)
	[19820]	=	{ 19789 },	-- Punctured Voodoo Doll (priest)
	[19821]	=	{ 19790 },	-- Punctured Voodoo Doll (druid)
	
	[22637]	=	{ 19782, 19783, 19784, 19785, 19786, 19787, 19788, 19789, 19790 },	-- Primal Hakkari Idol
	
	[19716]	=	{ 19827, 19833, 19846 },	-- Primal Hakkari Bindings
	[19717]	=	{ 19836, 19830, 19824 },	-- Primal Hakkari Armsplint
	[19718]	=	{ 19840, 19843, 19848 },	-- Primal Hakkari Stanchion
	[19719]	=	{ 19835, 19823, 19829 },	-- Primal Hakkari Girdle
	[19720]	=	{ 19839, 19842, 19849 },	-- Primal Hakkari Sash
	[19721]	=	{ 19826, 19832, 19845 },	-- Primal Hakkari Shawl
	[19722]	=	{ 19825, 19838, 19828 },	-- Primal Hakkari Tabard
	[19723]	=	{ 19822, 20033, 20034 },	-- Primal Hakkari Kossack
	[19724]	=	{ 19834, 19841, 19831 },	-- Primal Hakkari Aegis

	[20884]	=	{ 21408, 21393, 21399, 21414, 21396 },	-- Qiraji Magisterial Ring
	[20888]	=	{ 21405, 21402, 21417, 21411 },			-- Qiraji Ceremonial Ring
	[20886]	=	{ 21404, 21401, 21392, 21398, 21395 },	-- Qiraji Spiked Hilt
	[20890]	=	{ 21410, 21407, 21416, 21413 },			-- Qiraji Ornate Hilt
	[20885]	=	{ 21412, 21394, 21406, 21415 },			-- Qiraji Martial Drape
	[20889]	=	{ 21403, 21397, 21409, 21418, 21400 },	-- Qiraji Regal Drape

	[21232]	=	{ 21242, 21272, 21244, 21269 },			-- Imperial Qiraji Armaments
	[21237]	=	{ 21273, 21275, 21268 },				-- Imperial Qiraji Regalia

	[20928]	=	{ 21350, 21349, 21359, 21361, 21367, 
				  21365, 21333, 21330 },				-- Qiraji Bindings of Command
	[20932]	=	{ 21391, 21388, 21373, 21338, 21344, 
				  21345, 21354, 21355, 21335, 21376 },	-- Qiraji Bindings of Dominance
	[20927]	=	{ 21352, 21362, 21346, 21332 },			-- Ouro's Intact Hide
	[20931]	=	{ 21390, 21368, 21375, 21336, 21356 },	-- Skin of the Great Sandworm
	[20930]	=	{ 21387, 21360, 21366, 21372, 21353 },	-- Vek'lor's Diadem
	[20926]	=	{ 21337, 21347, 21329, 21348 },			-- Vek'nilash's Circlet
	[20929]	=	{ 21389, 21364, 21370, 21374, 21331 },	-- Carapace of the Old God
	[20933]	=	{ 21351, 21334, 21343, 21357 },			-- Husk of the Old God

	[20858]	=	{ 21405, 21403, 21387, 21351, 21417, 21362, 21365, 21372, 21345, 
				  21415, 21356, 21355, 21392, 21407, 21334, 21329, 21330 },			-- Stone Scarab
	[20859]	=	{ 21404, 21412, 21402, 21397, 21391, 21352, 21416, 21370, 21336, 
		 		  21343, 21414, 21354, 21353, 21376, 21349, 21360, 21400, 21333 },	-- Gold Scarab
	[20860]	=	{ 21401, 21389, 21350, 21361, 21368, 21374, 21337, 21413, 21344, 
		 		  21346, 21399, 21348, 21396, 21411, 21331, 21394, 21409, 21355 },	-- Silver Scarab
	[20861]	=	{ 21408, 21410, 21393, 21388, 21406, 21349, 21418, 21398, 21364, 
		 		  21366, 21373, 21347, 21332, 21357, 21395, 21335, 21390, 21345 },	-- Bronze Scarab
	[20862]	=	{ 21392, 21407, 21359, 21367, 21334, 21329, 21405, 21403, 21387, 
		 		  21391, 21351, 21417, 21362, 21372, 21344, 21415, 21356, 21376 },	-- Crystal Scarab
	[20863]	=	{ 21360, 21338, 21400, 21330, 21404, 21412, 21402, 21397, 21388, 
		 		  21352, 21416, 21361, 21370, 21373, 21336, 21343, 21414, 21353 },	-- Clay Scarab
	[20864]	=	{ 21394, 21409, 21401, 21389, 21359, 21368, 21365, 21374, 21337, 
		 		  21413, 21346, 21399, 21354, 21348, 21396, 21411, 21331, 21335 },	-- Bone Scarab
	[20865]	=	{ 21390, 21375, 21333, 21408, 21410, 21393, 21406, 21350, 21418, 
		 		  21398, 21364, 21367, 21366, 21338, 21347, 21332, 21357, 21395 },	-- Ivory Scarab

	[20866]	=	{ 21401, 21406, 21414 },		-- Azure Idol
	[20867]	=	{ 21405, 21394, 21416 },		-- Onyx Idol
	[20868]	=	{ 21410, 21403, 21393 },		-- Lambent Idol
	[20869]	=	{ 21402, 21418, 21398, 21395 },	-- Amber Idol
	[20870]	=	{ 21412, 21407, 21417 },		-- Jasper Idol
	[20871]	=	{ 21397, 21413, 21400, 21411 },	-- Obsidian Idol
	[20872]	=	{ 21404, 21409, 21399, 21396 },	-- Vermillion Idol
	[20873]	=	{ 21408, 21392, 21415 },		-- Alabaster Idol

	[20874]	=	{ 21361, 21368, 21344, 21343, 21329 },					-- Idol of the Sun
	[20875]	=	{ 21362, 21338, 21334, 21347, 21330 },					-- Idol of Night
	[20876]	=	{ 21351, 21349, 21337, 21345, 21332 },					-- Idol of Death
	[20877]	=	{ 21389, 21388, 21374, 21373, 21346, 21348, 21335 },	-- Idol of the Sage
	[20878]	=	{ 21387, 21350, 21372, 21336, 21355, 21357 },			-- Idol of Rebirth
	[20879]	=	{ 21391, 21352, 21370, 21365, 21353, 21376 },			-- Idol of Life
	[20881]	=	{ 21390, 21364, 21359, 21366, 21375, 21354 },			-- Idol of Strife
	[20882]	=	{ 21360, 21367, 21333, 21356, 21331 },					-- Idol of War
};

local ZG = "ZG_FACTION";
local AQ20 = "AQ20_FACTION";
local AQ40 = "AQ40_FACTION";
SP_TokenFactions = { ZG, AQ20, AQ40 };
SP_TokenRewards = {
	[19822]	=	{ class="WARRIOR",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Vindicator's Breastplate
	[19823]	=	{ class="WARRIOR",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Vindicator's Belt
	[19824]	=	{ class="WARRIOR",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Vindicator's Armguards
	[19825]	=	{ class="PALADIN",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Freethinker's Breastplate
	[19826]	=	{ class="PALADIN",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Freethinker's Belt
	[19827]	=	{ class="PALADIN",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Freethinker's Armguards
	[19828]	=	{ class="SHAMAN",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Augur's Hauberk
	[19829]	=	{ class="SHAMAN",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Augur's Belt
	[19830]	=	{ class="SHAMAN",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Augur's Bracers
	[19831]	=	{ class="HUNTER",	faction=ZG,	rep=7,	type=INVTYPE_SHOULDER },	-- Predator's Mantle
	[19832]	=	{ class="HUNTER",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Predator's Belt
	[19833]	=	{ class="HUNTER",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Predator's Bracers
	[19834]	=	{ class="ROGUE",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Madcap's Tunic
	[19835]	=	{ class="ROGUE",	faction=ZG,	rep=6,	type=INVTYPE_SHOULDER },	-- Madcap's Mantle
	[19836]	=	{ class="ROGUE",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Madcap's Bracers
	[19838]	=	{ class="DRUID",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Haruspex's Tunic
	[19839]	=	{ class="DRUID",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Haruspex's Belt
	[19840]	=	{ class="DRUID",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Haruspex's Bracers
	[19841]	=	{ class="PRIEST",	faction=ZG,	rep=7,	type=INVTYPE_SHOULDER },	-- Confessor's Mantle
	[19842]	=	{ class="PRIEST",	faction=ZG,	rep=6,	type=INVTYPE_WAIST },		-- Confessor's Bindings
	[19843]	=	{ class="PRIEST",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Confessor's Wraps
	[19845]	=	{ class="MAGE", 	faction=ZG,	rep=6,	type=INVTYPE_SHOULDER },	-- Illusionist's Mantle
	[19846]	=	{ class="MAGE", 	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Illusionist's Wraps
	[20034]	=	{ class="MAGE", 	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Illusionist's Robes
	[19848]	=	{ class="WARLOCK",	faction=ZG,	rep=5,	type=INVTYPE_WRIST },	-- Demoniac's Wraps
	[19849]	=	{ class="WARLOCK",	faction=ZG,	rep=6,	type=INVTYPE_SHOULDER },	-- Demoniac's Mantle
	[20033]	=	{ class="WARLOCK",	faction=ZG,	rep=7,	type=INVTYPE_CHEST },		-- Demoniac's Robes	

	[19782]	=	{ class="WARRIOR",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Presence of Might	
	[19783]	=	{ class="PALADIN",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Syncretist's Sigil	
	[19784]	=	{ class="ROGUE",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Death's Embrace	
	[19785]	=	{ class="HUNTER",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Falcon's Call	
	[19786]	=	{ class="SHAMAN",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Vodouisant's Vigilant Embrace	
	[19787]	=	{ class="MAGE", 	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Presence of Sight	
	[19788]	=	{ class="WARLOCK",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Hoodoo Hex	
	[19789]	=	{ class="PRIEST",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Prophetic Aura	
	[19790]	=	{ class="DRUID",	faction=ZG,	rep=5,	type=ENSCRIBE },	-- Animist's Caress	

	[21392]	=	{ class="WARRIOR",	faction=AQ20,	rep=8,	type=AXE },	-- Sickle of Unyielding Strength	
	[21393]	=	{ class="WARRIOR",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Signet of Unyielding Strength	
	[21394]	=	{ class="WARRIOR",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Drape of Unyielding Strength	
	[21395]	=	{ class="PALADIN",	faction=AQ20,	rep=8,	type=SWORD },	-- Blade of Eternal Justice	
	[21396]	=	{ class="PALADIN",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Ring of Eternal Justice	
	[21397]	=	{ class="PALADIN",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Cape of Eternal Justice	
	[21398]	=	{ class="SHAMAN",	faction=AQ20,	rep=8,	type=MACE },	-- Hammer of the Gathering Storm	
	[21399]	=	{ class="SHAMAN",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Ring of the Gathering Storm	
	[21400]	=	{ class="SHAMAN",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Cloak of the Gathering Storm	
	[21401]	=	{ class="HUNTER",	faction=AQ20,	rep=8,	type=AXE },	-- Scythe of the Unseen Path	
	[21402]	=	{ class="HUNTER",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Signet of the Unseen Path	
	[21403]	=	{ class="HUNTER",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Cloak of the Unseen Path	
	[21404]	=	{ class="ROGUE",	faction=AQ20,	rep=8,	type=DAGGER },	-- Dagger of Veiled Shadows	
	[21405]	=	{ class="ROGUE",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Band of Veiled Shadows	
	[21406]	=	{ class="ROGUE",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Cloak of Veiled Shadows	
	[21407]	=	{ class="DRUID",	faction=AQ20,	rep=8,	type=MACE },	-- Mace of Unending Life	
	[21408]	=	{ class="DRUID",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Band of Unending Life	
	[21409]	=	{ class="DRUID",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Cloak of Unending Life	
	[21410]	=	{ class="PRIEST",	faction=AQ20,	rep=8,	type=MACE },	-- Gavel of Infinite Wisdom	
	[21411]	=	{ class="PRIEST",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Ring of Infinite Wisdom	
	[21412]	=	{ class="PRIEST",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Shroud of Infinite Wisdom	
	[21413]	=	{ class="MAGE", 	faction=AQ20,	rep=8,	type=SWORD },		-- Blade of Vaulted Secrets	
	[21414]	=	{ class="MAGE", 	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Band of Vaulted Secrets
	[21415]	=	{ class="MAGE", 	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Drape of Vaulted Secrets	
	[21416]	=	{ class="WARLOCK",	faction=AQ20,	rep=8,	type=DAGGER },	-- Kris of Unspoken Names	
	[21417]	=	{ class="WARLOCK",	faction=AQ20,	rep=6,	type=INVTYPE_FINGER },		-- Ring of Unspoken Names	
	[21418]	=	{ class="WARLOCK",	faction=AQ20,	rep=7,	type=INVTYPE_CLOAK },		-- Shroud of Unspoken Names	

	[21273]	=	{ class="ANY",	faction=AQ40,	type=STAFF },		-- Blessed Qiraji Acolyte Staff	
	[21275]	=	{ class="ANY",	faction=AQ40,	type=STAFF },		-- Blessed Qiraji Augur Staff	
	[21268]	=	{ class="ANY",	faction=AQ40,	type=MACE },	-- Blessed Qiraji War Hammer	
	[21355]	=	{ class="ANY",	faction=AQ40,	type=AXE },		-- Blessed Qiraji War Axe	
	[21388]	=	{ class="ANY",	faction=AQ40,	type=GUN },		-- Blessed Qiraji Musket	
	[21333]	=	{ class="ANY",	faction=AQ40,	type=DAGGER },	-- Blessed Qiraji Pugio	
	[21359]	=	{ class="ANY",	faction=AQ40,	type=SHIELD },	-- Blessed Qiraji Bulwark	

	[21329]	=	{ class="WARRIOR",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Conqueror's Crown	
	[21330]	=	{ class="WARRIOR",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Conqueror's Spaulders	
	[21331]	=	{ class="WARRIOR",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Conqueror's Breastplate	
	[21332]	=	{ class="WARRIOR",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Conqueror's Legguards	
	[21333]	=	{ class="WARRIOR",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Conqueror's Greaves	
	[21334]	=	{ class="WARLOCK",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Doomcaller's Robes	
	[21335]	=	{ class="WARLOCK",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Doomcaller's Mantle	
	[21336]	=	{ class="WARLOCK",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Doomcaller's Trousers	
	[21337]	=	{ class="WARLOCK",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Doomcaller's Circlet	
	[21338]	=	{ class="WARLOCK",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Doomcaller's Footwraps	
	[21343]	=	{ class="MAGE", 	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Enigma Robes	
	[21344]	=	{ class="MAGE", 	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Enigma Boots	
	[21345]	=	{ class="MAGE", 	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Enigma Shoulderpads	
	[21346]	=	{ class="MAGE", 	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Enigma Leggings	
	[21347]	=	{ class="MAGE", 	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Enigma Circlet	
	[21348]	=	{ class="PRIEST",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Tiara of the Oracle	
	[21349]	=	{ class="PRIEST",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Footwraps of the Oracle	
	[21350]	=	{ class="PRIEST",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Mantle of the Oracle	
	[21351]	=	{ class="PRIEST",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Vestments of the Oracle	
	[21352]	=	{ class="PRIEST",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Trousers of the Oracle	
	[21353]	=	{ class="DRUID",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Genesis Helm	
	[21354]	=	{ class="DRUID",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Genesis Shoulderpads	
	[21355]	=	{ class="DRUID",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Genesis Boots	
	[21356]	=	{ class="DRUID",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Genesis Trousers	
	[21357]	=	{ class="DRUID",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Genesis Vest	
	[21359]	=	{ class="ROGUE",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Deathdealer's Boots	
	[21360]	=	{ class="ROGUE",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Deathdealer's Helm	
	[21361]	=	{ class="ROGUE",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Deathdealer's Spaulders	
	[21362]	=	{ class="ROGUE",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Deathdealer's Leggings	
	[21364]	=	{ class="ROGUE",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Deathdealer's Vest	
	[21365]	=	{ class="HUNTER",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Striker's Footguards	
	[21366]	=	{ class="HUNTER",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Striker's Diadem	
	[21367]	=	{ class="HUNTER",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Striker's Pauldrons	
	[21368]	=	{ class="HUNTER",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Striker's Leggings	
	[21370]	=	{ class="HUNTER",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Striker's Hauberk	
	[21372]	=	{ class="SHAMAN",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Stormcaller's Diadem	
	[21373]	=	{ class="SHAMAN",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Stormcaller's Footguards	
	[21374]	=	{ class="SHAMAN",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Stormcaller's Hauberk	
	[21375]	=	{ class="SHAMAN",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Stormcaller's Leggings	
	[21376]	=	{ class="SHAMAN",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Stormcaller's Pauldrons	
	[21387]	=	{ class="PALADIN",	faction=AQ40,	rep=5,	type=INVTYPE_HEAD },		-- Avenger's Crown	
	[21388]	=	{ class="PALADIN",	faction=AQ40,	rep=4,	type=INVTYPE_FEET },		-- Avenger's Greaves	
	[21389]	=	{ class="PALADIN",	faction=AQ40,	rep=6,	type=INVTYPE_CHEST },		-- Avenger's Breastplate	
	[21390]	=	{ class="PALADIN",	faction=AQ40,	rep=5,	type=INVTYPE_LEGS },		-- Avenger's Legguards	
	[21391]	=	{ class="PALADIN",	faction=AQ40,	rep=4,	type=INVTYPE_SHOULDER },	-- Avenger's Pauldrons	
};

SP_TokenNames = {
-- ZG uncommon/rare tokens are no longer used for class-gear quests (only remaining use is to turn in for rep)
	[19698]	=	"Zulian Coin",
	[19699]	=	"Razzashi Coin",
	[19700]	=	"Hakkari Coin",
	[19701]	=	"Gurubashi Coin",
	[19702]	=	"Vilebranch Coin",
	[19703]	=	"Witherbark Coin",
	[19704]	=	"Sandfury Coin",
	[19705]	=	"Skullsplitter Coin",
	[19706]	=	"Bloodscalp Coin",
                
	[19707]	=	"Red Hakkari Bijou",
	[19708]	=	"Blue Hakkari Bijou",
	[19709]	=	"Yellow Hakkari Bijou",
	[19710]	=	"Orange Hakkari Bijou",
	[19711]	=	"Green Hakkari Bijou",
	[19712]	=	"Purple Hakkari Bijou",
	[19713]	=	"Bronze Hakkari Bijou",
	[19714]	=	"Silver Hakkari Bijou",
	[19715]	=	"Gold Hakkari Bijou",
                
	[19813]	=	"Punctured Voodoo Doll",	-- (warrior)
	[19814]	=	"Punctured Voodoo Doll",	-- (rogue)
	[19815]	=	"Punctured Voodoo Doll",	-- (paladin)
	[19816]	=	"Punctured Voodoo Doll",	-- (hunter)
	[19817]	=	"Punctured Voodoo Doll",	-- (shaman)
	[19818]	=	"Punctured Voodoo Doll",	-- (mage)
	[19819]	=	"Punctured Voodoo Doll",	-- (warlock)
	[19820]	=	"Punctured Voodoo Doll",	-- (priest)
	[19821]	=	"Punctured Voodoo Doll",	-- (druid)
	
	[22637]	=	"Primal Hakkari Idol",

	[19716]	=	"Primal Hakkari Bindings",
	[19717]	=	"Primal Hakkari Armsplint",
	[19718]	=	"Primal Hakkari Stanchion",
	[19719]	=	"Primal Hakkari Girdle",
	[19720]	=	"Primal Hakkari Sash",
	[19721]	=	"Primal Hakkari Shawl",
	[19722]	=	"Primal Hakkari Tabard",
	[19723]	=	"Primal Hakkari Kossack",
	[19724]	=	"Primal Hakkari Aegis",
                
	[20884]	=	"Qiraji Magisterial Ring",
	[20888]	=	"Qiraji Ceremonial Ring",
	[20885]	=	"Qiraji Martial Drape",
	[20889]	=	"Qiraji Regal Drape",
	[20886]	=	"Qiraji Spiked Hilt",
	[20890]	=	"Qiraji Ornate Hilt",
                
	[21232]	=	"Imperial Qiraji Armaments",
	[21237]	=	"Imperial Qiraji Regalia",
                
	[20928]	=	"Qiraji Bindings of Command",
	[20932]	=	"Qiraji Bindings of Dominance",
	[20927]	=	"Ouro's Intact Hide",
	[20931]	=	"Skin of the Great Sandworm",
	[20930]	=	"Vek'lor's Diadem",
	[20926]	=	"Vek'nilash's Circlet",
	[20929]	=	"Carapace of the Old God",
	[20933]	=	"Husk of the Old God",
                
	[20858]	=	"Stone Scarab",
	[20859]	=	"Gold Scarab",
	[20860]	=	"Silver Scarab",
	[20861]	=	"Bronze Scarab",
	[20862]	=	"Crystal Scarab",
	[20863]	=	"Clay Scarab",
	[20864]	=	"Bone Scarab",
	[20865]	=	"Ivory Scarab",
                
	[20866]	=	"Azure Idol",
	[20867]	=	"Onyx Idol",
	[20868]	=	"Lambent Idol",
	[20869]	=	"Amber Idol",
	[20870]	=	"Jasper Idol",
	[20871]	=	"Obsidian Idol",
	[20872]	=	"Vermillion Idol",
	[20873]	=	"Alabaster Idol",
                
	[20874]	=	"Idol of the Sun",
	[20875]	=	"Idol of Night",
	[20876]	=	"Idol of Death",
	[20877]	=	"Idol of the Sage",
	[20878]	=	"Idol of Rebirth",
	[20879]	=	"Idol of Life",
	[20881]	=	"Idol of Strife",
	[20882]	=	"Idol of War",
};

SP_TokenQuality = {
-- ZG uncommon/rare tokens are no longer used for class-gear quests (only remaining use is to turn in for rep)
	[19698]	=	2,	-- Zulian Coin
	[19699]	=	2,	-- Razzashi Coin
	[19700]	=	2,	-- Hakkari Coin
	[19701]	=	2,	-- Gurubashi Coin
	[19702]	=	2,	-- Vilebranch Coin
	[19703]	=	2,	-- Witherbark Coin
	[19704]	=	2,	-- Sandfury Coin
	[19705]	=	2,	-- Skullsplitter Coin
	[19706]	=	2,	-- Bloodscalp Coin

	[19707]	=	3,	-- Red Hakkari Bijou
	[19708]	=	3,	-- Blue Hakkari Bijou
	[19709]	=	3,	-- Yellow Hakkari Bijou
	[19710]	=	3,	-- Orange Hakkari Bijou
	[19711]	=	3,	-- Green Hakkari Bijou
	[19712]	=	3,	-- Purple Hakkari Bijou
	[19713]	=	3,	-- Bronze Hakkari Bijou
	[19714]	=	3,	-- Silver Hakkari Bijou
	[19715]	=	3,	-- Gold Hakkari Bijou

	[19813]	=	2,	-- Punctured Voodoo Doll (warrior)
	[19814]	=	2,	-- Punctured Voodoo Doll (rogue)
	[19815]	=	2,	-- Punctured Voodoo Doll (paladin)
	[19816]	=	2,	-- Punctured Voodoo Doll (hunter)
	[19817]	=	2,	-- Punctured Voodoo Doll (shaman)
	[19818]	=	2,	-- Punctured Voodoo Doll (mage)
	[19819]	=	2,	-- Punctured Voodoo Doll (warlock)
	[19820]	=	2,	-- Punctured Voodoo Doll (priest)
	[19821]	=	2,	-- Punctured Voodoo Doll (druid)
	
	[22637]	=	3,	-- Primal Hakkari Idol

	[19716]	=	4,	-- Primal Hakkari Bindings
	[19717]	=	4,	-- Primal Hakkari Armsplint
	[19718]	=	4,	-- Primal Hakkari Stanchion
	[19719]	=	4,	-- Primal Hakkari Girdle
	[19720]	=	4,	-- Primal Hakkari Sash
	[19721]	=	4,	-- Primal Hakkari Shawl
	[19722]	=	4,	-- Primal Hakkari Tabard
	[19723]	=	4,	-- Primal Hakkari Kossack
	[19724]	=	4,	-- Primal Hakkari Aegis

	-- we use this quality array to also determine how many of an item you need for a quest,
	-- because there's currently a consistent formula for it. (5x green A, 5x green B, 2x blue, 1x epic)
	-- except in AQ20 the "epic" piece is in some cases actually a blue, so we label it 3.1 here;
	-- it still shows shows up blue, but we catch that it's not the same as a 3(.0) item.
	[20884]	=	3.1,	-- Qiraji Magisterial Ring
	[20888]	=	3.1,	-- Qiraji Ceremonial Ring
	[20885]	=	3.1,	-- Qiraji Martial Drape
	[20889]	=	3.1,	-- Qiraji Regal Drape
	[20886]	=	4,	-- Qiraji Spiked Hilt
	[20890]	=	4,	-- Qiraji Ornate Hilt

	[21232]	=	4,	-- Imperial Qiraji Armaments
	[21237]	=	4,	-- Imperial Qiraji Regalia

	[20928]	=	4,	-- Qiraji Bindings of Command
	[20932]	=	4,	-- Qiraji Bindings of Dominance
	[20927]	=	4,	-- Ouro's Intact Hide
	[20931]	=	4,	-- Skin of the Great Sandworm
	[20930]	=	4,	-- Vek'lor's Diadem
	[20926]	=	4,	-- Vek'nilash's Circlet
	[20929]	=	4,	-- Carapace of the Old God
	[20933]	=	4,	-- Husk of the Old God

	[20858]	=	2,	-- Stone Scarab
	[20859]	=	2,	-- Gold Scarab
	[20860]	=	2,	-- Silver Scarab
	[20861]	=	2,	-- Bronze Scarab
	[20862]	=	2,	-- Crystal Scarab
	[20863]	=	2,	-- Clay Scarab
	[20864]	=	2,	-- Bone Scarab
	[20865]	=	2,	-- Ivory Scarab

	[20866]	=	3,	-- Azure Idol
	[20867]	=	3,	-- Onyx Idol
	[20868]	=	3,	-- Lambent Idol
	[20869]	=	3,	-- Amber Idol
	[20870]	=	3,	-- Jasper Idol
	[20871]	=	3,	-- Obsidian Idol
	[20872]	=	3,	-- Vermillion Idol
	[20873]	=	3,	-- Alabaster Idol

	[20874]	=	3,	-- Idol of the Sun
	[20875]	=	3,	-- Idol of Night
	[20876]	=	3,	-- Idol of Death
	[20877]	=	3,	-- Idol of the Sage
	[20878]	=	3,	-- Idol of Rebirth
	[20879]	=	3,	-- Idol of Life
	[20881]	=	3,	-- Idol of Strife
	[20882]	=	3,	-- Idol of War
}

SP_FactionTokenSets = {
	["ZG"] = {
		{ 19698, 19699, 19700 }, 	-- Zulian, Razzashi, and Hakkari Coins	
		{ 19701, 19702, 19703 },	-- Gurubashi, Vilebranch, and Witherbark Coins
		{ 19704, 19705, 19706 },	-- Sandfury, Skullsplitter, and Bloodscalp Coins
	
		{ 19707 },		-- Red Hakkari Bijou
		{ 19708 },		-- Blue Hakkari Bijou
		{ 19709 },		-- Yellow Hakkari Bijou
		{ 19710 },		-- Orange Hakkari Bijou
		{ 19711 },		-- Green Hakkari Bijou
		{ 19712 },		-- Purple Hakkari Bijou
		{ 19713 },		-- Bronze Hakkari Bijou
		{ 19714 },		-- Silver Hakkari Bijou
		{ 19715 },		-- Gold Hakkari Bijou
	},
	["AD"] = {
		{ 22525 },		-- Crypt Fiend Parts
		{ 22526 },		-- Bone Fragments
		{ 22527 },		-- Core of Elements
		{ 22528 },		-- Dark Iron Scraps
		{ 22529 },		-- Savage Frond
	},
};

