-- Default English Data for MetaMap

-- General
METAMAP_CATEGORY = "Interface";
METAMAP_SUBTITLE = "WorldMap Mod";
METAMAP_DESC = "MetaMap adds enhancements to the standard World Map.";
METAMAP_STRING_LOCATION = "Location";
METAMAP_STRING_LEVELRANGE = "Level Range";
METAMAP_STRING_PLAYERLIMIT = "Player Limit";
METAMAP_MAPLIST_INFO = "LeftClick: Ping Note\nRightClick: Edit Note\nCTRL+Click: Loot Table";
METAMAP_HINT = "Hint: Left-click to open MetaMap.\nRight-click for options";
METAMAP_NOTES_SHOWN = "Notes"
METAMAP_LINES_SHOWN = "Lines"
METAMAP_SEARCHTEXT = "Search";
METAMAPLIST_SORTED = "Sorted List";
METAMAPLIST_UNSORTED = "Unsorted List";
METAMAP_CLOSE_BUTTON ="Close";

BINDING_HEADER_METAMAP_TITLE = "MetaMap";
BINDING_NAME_METAMAP_MAPTOGGLE = "Toggle WorldMap";
BINDING_NAME_METAMAP_MAPTOGGLE1 = "WorldMap Mode 1";
BINDING_NAME_METAMAP_MAPTOGGLE2 = "WorldMap Mode 2";
BINDING_NAME_METAMAP_FSTOGGLE = "Toggle FullScreen";
BINDING_NAME_METAMAP_SAVESET = "Toggle Map Mode";
BINDING_NAME_METAMAP_KB = "Toggle Database Display"
BINDING_NAME_METAMAP_KB_TARGET_UNIT = "Capture Target Details";
BINDING_NAME_METAMAP_BWPCLEAR = "Clear Waypoint";
BINDING_NAME_METAMAP_QST = "Toggle Quest Log"
BINDING_NAME_METAMAP_TRK = "Toggle Tracker Display"
BINDING_NAME_METAMAP_QUICKNOTE = "Set Quick Note";

-- Commands
METAMAP_ENABLE_COMMANDS = { "/mapnote" }
METAMAP_ONENOTE_COMMANDS = { "/onenote", "/allowonenote", "/aon" }
METAMAP_MININOTE_COMMANDS = { "/nextmininote", "/nmn" }
METAMAP_MININOTEONLY_COMMANDS = { "/nextmininoteonly", "/nmno" }
METAMAP_MININOTEOFF_COMMANDS = { "/mininoteoff", "/mno" }
METAMAP_QUICKNOTE_COMMANDS = { "/quicknote", "/qnote", "/qtloc" }

-- Interface Configuration
METAMAP_OPTIONS_TITLE = "MetaMap Options";
METAMAP_OPTIONS_BUTTON = "Options";
METAMAP_OPTIONS_SHOWAUTHOR = "Show notes author"
METAMAP_OPTIONS_SHOWBUT = "Show Minimap Button";
METAMAP_OPTIONS_AUTOSEL = "Autowrap Tooltip Text";
METAMAP_OPTIONS_BUTPOS = "MiniMap Button Position";
METAMAP_OPTIONS_POI = "Set POI when entering new zone (Points Of Interest)";
METAMAP_OPTIONS_LISTCOLORS = "Use coloured Sidelist";
METAMAP_OPTIONS_TRANS = "Map Transparency";
METAMAP_OPTIONS_SHADER = "BackDrop Shader";
METAMAP_OPTIONS_SHADESET = "Instance Backdrop Color";
METAMAP_OPTIONS_DONE = "Done";
METAMAP_OPTIONS_SCALE = "Map Scale";
METAMAP_OPTIONS_TTSCALE = "Tooltip Scale";
METAMAP_OPTIONS_TRACKICON = "Show Tracker on MetaMap Icon";
METAMAP_OPTIONS_CCREATOR = "[Click for Creator]";
METAMAP_OPTIONS_CONTAINER = "Data Display Opacity";
METAMAP_OPTIONS_NOTESIZE = "Map Note Scale";

METAMAP_MENU_FONT = "Menu FontSize";
METAMAP_MENU_MODE = "Menu on Click";
METAMAP_MENU_EXTOPT = "General Options/Help";
METAMAP_MENU_MAPCRD = "Show Main Coords";
METAMAP_MENU_MINCRD = "Show MiniMap Coords";
METAMAP_MENU_FILTER = "Notes Filter"
METAMAP_MENU_FILTER1 = "Show All"
METAMAP_MENU_FILTER2 = "Hide All"
METAMAP_MENU_TRKFILTER = "Tracker Filter";
METAMAP_MENU_MAPSET = "Map Display Mode";
METAMAP_MENU_MAPMOD = "Create notes with MapMod";
METAMAP_MENU_ACTION = "Click through map";
METAMAP_MENU_FLIGHT = "FlightMap Options";
METAMAP_MENU_TRKMOD = "Tracker Display";
METAMAP_MENU_TRKSET = "Track Herbs/Minerals";
METAMAP_MENU_BWPMOD = "Set a Waypoint";
METAMAP_MENU_FWMMOD = "Show Unexplored";
METAMAP_MENU_WKBMOD = "Knowledge Base";
METAMAP_MENU_NBKMOD = "Note Book";
METAMAP_MENU_QSTMOD = "Quest Log";

METAMAP_TABTEXT1 = "General";
METAMAP_TABTEXT2 = "MetaNotes";
METAMAP_TABTEXT3 = "Modules";
METAMAP_TABTEXT4 = "Database";
METAMAP_TABTEXT5 = "ZoneCheck";
METAMAP_TABTEXT6 = "Help";

METAMAP_NOMODULE = "module is missing or not enabled!";
METAMAP_MODULETEXT = "Always load the following modules when starting a new session";
METAMAP_FWM_TEXT = "Show FWM Options";

METAMAP_LOADCVT_BUTTON = "Imports Module";
METAMAP_LOADEXP_BUTTON = "Exports Module";
METAMAP_LOADBKP_BUTTON = "Backup/Restore";
METAMAP_IMPORTS_HEADER = "Import/Export Module";
METAMAP_RELOADUI_BUTTON = "Reload UI";
METAMAP_IMPORT_BUTTON = "Import";
METAMAP_IMPORT_INSTANCE = "Instance Data";
METAMAP_IMPORT_INSTANCE_INFO = "This will import any notes created for the instance maps. The file 'MetaMapData.lua' must exist in the MetaMapCVT directory, and contain data in the correct format. This file is included as standard with MetaMap";
METAMAP_IMPORT_EXP = "User File";
METAMAP_IMPORT_EXP_INFO = "This will import User created notes into MetaMap. The file 'MetaMapEXP.lua' must exist in the MetaMapCVT directory, and contain data in the correct format. This is the file created as 'SavedVariables\\MetaMapEXP.lua' by the Exports module.\nThis will additionally import notes created by MapMod or QuestHistory into MetaMap. Please refer to 'Modules' in the Help section for correct procedure.";
METAMAP_IMPORTS_INFO = "Reload the User Interface after use, to ensure all redundant data is cleared from memory.";
METAMAP_CONFIRM_IMPORT = "Current import file contains data for";
METAMAP_CONFIRM_EXPORT = "Please select the desired data file to export";

METAMAP_ZONECHECK_BUTTON = "Check Zones";
METAMAP_ZONEMOVE_BUTTON = "Convert Zone";
METAMAP_ORPHAN_TEXT1 = "Selected %s of |cffff0000%s|r orphaned zones:";
METAMAP_ORPHAN_TEXT2 = "Select correct zone to convert to:";
METAMAP_ZONE_ERROR = "Found incorrect zone names for:";
METAMAP_ZONE_SHIFTED = "Successfully converted |cffff0000%s|r to |cff00ff00%s|r";
METAMAP_ZONE_NOSHIFT = "No orphaned zones found. All data zones match current zones.";

METAMAPEXP_EXPORTED = "Exported %s unique %s entries to";

METAMAPFWM_USECOLOR = "Color unexplored areas";
METAMAPFWM_SETCOLOR = "Set Color";

METAKB_LOAD_MODULE = "Load Module";
METAMAP_NOKBDATA = "MetaMapWKB module not loaded - KB data not processed";

METAMAPBLT_HINT = "Shift+Click: Link Item  -  CTRL+Click: Dressing Room";
METAMAPBLT_NO_INFO = "No information available for this item";
METAMAPBLT_NO_DATA = "Data not yet available or data not imported";
METAMAPBLT_CLASS_SELECT = "Select required class below";

METAMAPBKP_BACKUP = "Backup Data";
METAMAPBKP_RESTORE = "Restore Data";
METAMAPBKP_INFO = "Backup will save all current data to a seperate file. Choose Restore at any time to replace the current data with the last saved data.";
METAMAPBKP_BACKUP_DONE = "Successfuly backed up all data";
METAMAPBKP_RESTORE_DONE = "Successfuly restored all data";
METAMAPBKP_RESTORE_FAIL = "No data found to restore";

METAMAP_INFOLINE_HINT1 = "LeftClick to toggle StoryLine";
METAMAP_INFOLINE_HINT2 = "RightClick to toggle SideList";
METAMAP_INFOLINE_HINT3 = "RightClick On Map To Zoom Out"
METAMAP_INFOLINE_HINT4 = "Ctrl+LeftClick to create a note"
METAMAP_INFOLINE_HINT5 = "ShiftClick to insert coords";
METAMAP_INFOLINE_HINT6 = "CTRLClick to toggle colours";

METAMAP_BUTTON_TOOLTIP1 = "LeftClick to Show Map";
METAMAP_BUTTON_TOOLTIP2 = "RightClick for Options";
METAMAP_CLICK_ON_SECOND_NOTE = "Choose Second Note To Draw/Clear A Line"
METAMAP_CLICK_ON_LOCATION = "LeftClick on map for new note location"

METAMAP_NEW_NOTE = "Create Note"
METAMAP_MININOTE_OFF = "MiniNote Off"
METAMAP_OPTIONS_TEXT = "Notes Options"
METAMAP_CANCEL = "Cancel"
METAMAP_EDIT_NOTE = "Edit Note"
METAMAP_MININOTE_ON = "Set MiniNote"
METAMAP_SEND_NOTE = "Send Note"
METAMAP_TOGGLELINE = "Toggle Line"
METAMAP_MOVE_NOTE = "Move Note";
METAMAP_DELETE_NOTE = "Delete"
METAMAP_SAVE_NOTE = "Save"
METAMAP_NEWNOTE = "New";
METAMAP_EDIT_TITLE = "Title (required):"
METAMAP_EDIT_INFO1 = "Info Line 1 (optional):"
METAMAP_EDIT_INFO2 = "Info Line 2 (optional):"
METAMAP_EDIT_CREATOR = "Creator (optional - leave blank to hide):"

METAMAP_SEND_MENU = "Send Note"
METAMAP_SLASHCOMMAND = "Change Mode"
METAMAP_SEND_TIP = "These notes can be received by all MetaMap users"
METAMAP_SEND_PLAYER = "Enter player name:"
METAMAP_SENDTOPLAYER = "Send to Player"
METAMAP_SENDTOPARTY = "Send to Party"
METAMAP_SENDTOGUILD = "Send to Guild"
METAMAP_SHOWSEND = "Change Mode"
METAMAP_SEND_SLASHTITLE = "Get slash Command:"
METAMAP_SEND_SLASHTIP = "Highlight this and use CTRL+C to copy to clipboard\n(then you can post it in a forum for example)"
METAMAP_SEND_SLASHCOMMAND = "/Command:"
METAMAP_PARTYSENT = "PartyNote sent to all Party members.";
METAMAP_RAIDSENT = "PartyNote sent to all Raid members.";
METAMAP_GUILDSENT = "Note sent to all Guild members.";
METAMAP_NOGUILD = "Not currently a Guild member.";
METAMAP_NOPARTY = "Not currently in a Party or Raid.";
METAMAP_NOPLAYER = "Player name missing!";

METAMAP_OWNNOTES = "Show notes created by your character"
METAMAP_OTHERNOTES = "Show notes received from other characters"
METAMAP_HIGHLIGHT_LASTCREATED = "Highlight last created note in |cFFFF0000red|r"
METAMAP_HIGHLIGHT_MININOTE = "Highlight note selected for MiniNote in |cFF6666FFblue|r"
METAMAP_ACCEPTINCOMING = "Accept incoming notes from other players"
METAMAP_AUTOPARTYASMININOTE = "Automatically set party notes as MiniNote."
METAMAP_ZONESEARCH_TEXT = "Delete notes for |cffffffff%s|r by creator:"
METAMAP_ZONESEARCH_TEXTHINT = "Hint: Open WorldMap and set map to desired area for deletion";
METAMAP_BATCHDELETE = "This will delete all notes for |cFFFFD100%s|r with creator as |cFFFFD100%s|r.";
METAMAP_DELETED_BY_NAME = "Deleted selected notes with creator |cFFFFD100%s|r and name |cFFFFD100%s|r."
METAMAP_DELETED_BY_CREATOR = "Deleted all notes with creator |cFFFFD100%s|r."
METAMAP_DELETED_BY_ZONE = "Deleted all notes for |cFFFFD100%s|r with creator |cFFFFD100%s|r."

METAMAP_CREATEDBY = "Created by"
METAMAP_MAPNOTEHELP = "This command can only be used to insert a note"
METAMAP_ACCEPT_NOTE = "Note added to the map of |cFFFFD100%s|r."
METAMAP_DECLINE_NOTE = "Could not add, this note is too near to |cFFFFD100%q|r in |cFFFFD100%s|r."
METAMAP_ACCEPT_MININOTE = "MiniNote set for the map of |cFFFFD100%s|r.";
METAMAP_DECLINE_GET = "|cFFFFD100%s|r tried to send you a note in |cFFFFD100%s|r, but it was too near to |cFFFFD100%q|r."
METAMAP_DISABLED_GET = "Could not receive note from |cFFFFD100%s|r: reception disabled in the options."
METAMAP_ACCEPT_GET = "You received a map note from |cFFFFD100%s|r for |cFFFFD100%s|r."
METAMAP_PARTY_GET = "|cFFFFD100%s|r set a new party note in |cFFFFD100%s|r."
METAMAP_NOTE_SENT = "Note sent to |cFFFFD100%s|r."
METAMAP_QUICKNOTE_DEFAULTNAME = "QuickNote"
METAMAP_MININOTE_DEFAULTNAME = "MiniNote"
METAMAP_VNOTE_DEFAULTNAME = "VirtualNote"
METAMAP_SETMININOTE = "Set note as new MiniNote"
METAMAP_PARTYNOTE = "Party Note"
METAMAP_SETCOORDS = "Coords (xx,yy):"
METAMAP_VNOTE = "Virtual"
METAMAP_VNOTE_INFO = "Creates a virtual note. Save on map of choice to bind."
METAMAP_VNOTE_SET = "Virtual note created on the World Map."
METAMAP_MININOTE_INFO = "Creates a note on the Minimap only."
METAMAP_INVALIDZONE = "Could not create - no player coords available in this zone.";

--- Instances Information

---Blackfathom Deeps
METAMAP_BFD_INFO = "Situated along the Zoram Strand of Ashenvale, Blackfathom Deeps was once a glorious temple dedicated to the night elves' moon-goddess, Elune. However, the great Sundering shattered the temple - sinking it beneath the waves of the Veiled Sea. There it remained untouched - until, drawn by its ancient power - the naga and satyr emerged to plumb its secrets. Legends hold that the ancient beast, Aku'mai, has taken up residence within the temple's ruins. Aku'mai, a favored pet of the primordial Old Gods, has preyed upon the area ever since. Drawn to Aku'mai's presence, the cult known as the Twilight's Hammer has also come to bask in the Old Gods' evil presence.";
---Blackrock Depths
METAMAP_BRD_INFO = "Once the capital city of the Dark Iron dwarves, this volcanic labyrinth now serves as the seat of power for Ragnaros the Firelord. Ragnaros has uncovered the secret to creating life from stone and plans to build an army of unstoppable golems to aid him in conquering the whole of Blackrock Mountain. Obsessed with defeating Nefarian and his draconic minions, Ragnaros will go to any extreme to achieve final victory.";
---Blackrock Spire
METAMAP_BRS_INFO = "The mighty fortress carved within the fiery bowels of Blackrock Mountain was designed by the master dwarf-mason, Franclorn Forgewright. Intended to be the symbol of Dark Iron power, the fortress was held by the sinister dwarves for centuries. However, Nefarian - the cunning son of the dragon, Deathwing - had other plans for the great keep. He and his draconic minions took control of the upper Spire and made war on the dwarves' holdings in the mountain's volcanic depths. Realizing that the dwarves were led by the mighty fire elemental, Ragnaros - Nefarian vowed to crush his enemies and claim the whole of Blackrock mountain for himself.";
---Blackrock Spire Upper
METAMAP_BSU_INFO = "The mighty fortress carved within the fiery bowels of Blackrock Mountain was designed by the master dwarf-mason, Franclorn Forgewright. Intended to be the symbol of Dark Iron power, the fortress was held by the sinister dwarves for centuries. However, Nefarian - the cunning son of the dragon, Deathwing - had other plans for the great keep. He and his draconic minions took control of the upper Spire and made war on the dwarves' holdings in the mountain's volcanic depths. Realizing that the dwarves were led by the mighty fire elemental, Ragnaros - Nefarian vowed to crush his enemies and claim the whole of Blackrock mountain for himself.";
---Blackwing Lair
METAMAP_BWL_INFO = "Blackwing Lair can be found at the very height of Blackrock Spire. It is there in the dark recesses of the mountain's peak that Nefarian has begun to unfold the final stages of his plan to destroy Ragnaros once and for all and lead his army to undisputed supremacy over all the races of Azeroth. Nefarian has vowed to crush Ragnaros. To this end, he has recently begun efforts to bolster his forces, much as his father Deathwing had attempted to do in ages past. However, where Deathwing failed, it now seems the scheming Nefarian may be succeeding. Nefarian's mad bid for dominance has even attracted the ire of the Red Dragon Flight, which has always been the Black Flight's greatest foe. Though Nefarian's intentions are known, the methods he is using to achieve them remain a mystery. It is believed, however that Nefarian has been experimenting with the blood of all of the various Dragon Flights to produce unstoppable warriors.";
---Dire Maul
METAMAP_DMC_INFO = "Built twelve thousand years ago by a covert sect of night elf sorcerers, the ancient city of Eldre'Thalas was used to protect Queen Azshara's most prized arcane secrets. Though it was ravaged by the Great Sundering of the world, much of the wondrous city still stands as the imposing Dire Maul. The ruins' three distinct districts have been overrun by all manner of creatures - especially the spectral highborne, foul satyr and brutish ogres. Only the most daring party of adventurers can enter this broken city and face the ancient evils locked within its ancient vaults.";
---Gnomeregan
METAMAP_GNM_INFO = "Located in Dun Morogh, the technological wonder known as Gnomeregan has been the gnomes' capital city for generations. Recently, a hostile race of mutant troggs infested several regions of Dun Morogh - including the great gnome city. In a desperate attempt to destroy the invading troggs, High Tinker Mekkatorque ordered the emergency venting of the city's radioactive waste tanks. Several gnomes sought shelter from the airborne pollutants as they waited for the troggs to die or flee. Unfortunately, though the troggs became irradiated from the toxic assault - their siege continued, unabated. Those gnomes who were not killed by noxious seepage were forced to flee, seeking refuge in the nearby dwarven city of Ironforge. There, High Tinker Mekkatorque set out to enlist brave souls to help his people reclaim their beloved city. It is rumored that Mekkatorque's once-trusted advisor, Mekgineer Thermaplug, betrayed his people by allowing the invasion to happen. Now, his sanity shattered, Thermaplug remains in Gnomeregan - furthering his dark schemes and acting as the city's new techno-overlord.";
---Maraudon
METAMAP_MDN_INFO = "Protected by the fierce Maraudine centaur, Maraudon is one of the most sacred sites within Desolace. The great temple/cavern is the burial place of Zaetar, one of two immortal sons born to the demigod, Cenarius. Legend holds that Zaetar and the earth elemental princess, Theradras, sired the misbegotten centaur race. It is said that upon their emergence, the barbaric centaur turned on their father and killed him. Some believe that Theradras, in her grief, trapped Zaetar's spirit within the winding cavern - used its energies for some malign purpose. The subterranean tunnels are populated by the vicious, long-dead ghosts of the Centaur Khans, as well as Theradras' own raging, elemental minions.";
---Molten Core
METAMAP_TMC_INFO = "The Molten Core lies at the very bottom of Blackrock Depths. It is the heart of Blackrock Mountain and the exact spot where, long ago in a desperate bid to turn the tide of the dwarven civil war, Emperor Thaurissan summoned the elemental Firelord, Ragnaros, into the world. Though the fire lord is incapable of straying far from the blazing Core, it is believed that his elemental minions command the Dark Iron dwarves, who are in the midst of creating armies out of living stone. The burning lake where Ragnaros lies sleeping acts as a rift connecting to the plane of fire, allowing the malicious elementals to pass through. Chief among Ragnaros' agents is Majordomo Executus - for this cunning elemental is the only one capable of calling the Firelord from his slumber.";
---Onyxia's Lair
METAMAP_ONL_INFO = "Onyxia is the daughter of the mighty dragon Deathwing, and sister of the scheming Nefarion Lord of Blackrock Spire. It is said that Onyxia delights in corrupting the mortal races by meddling in their political affairs. To this end it is believed that she takes on various humanoid forms and uses her charm and power to influence delicate matters between the different races. Some believe that Onyxia has even assumed an alias once used by her father - the title of the royal House Prestor. When not meddling in mortal concerns, Onyxia resides in a fiery cave below the Dragonmurk, a dismal swamp located within Dustwallow Marsh. There she is guarded by her kin, the remaining members of the insidious Black Dragon Flight.";
---Ragefire Chasm
METAMAP_RFC_INFO = "Ragefire Chasm consists of a network of volcanic caverns that lie below the orcs' new capital city of Orgrimmar. Recently, rumors have spread that a cult loyal to the demonic Shadow Council has taken up residence within the Chasm's fiery depths. This cult, known as the Burning Blade, threatens the very sovereignty of Durotar. Many believe that the orc Warchief, Thrall, is aware of the Blade's existence and has chosen not to destroy it in the hopes that its members might lead him straight to the Shadow Council. Either way, the dark powers emanating from Ragefire Chasm could undo all that the orcs have fought to attain.";
---Razorfen Downs
METAMAP_RFD_INFO = "Crafted from the same mighty vines as Razorfen Kraul, Razorfen Downs is the traditional capital city of the quillboar race. The sprawling, thorn-ridden labyrinth houses a veritable army of loyal quillboar as well as their high priests - the Death's Head tribe. Recently, however, a looming shadow has fallen over the crude den. Agents of the undead Scourge - led by the lich, Amnennar the Coldbringer - have taken control over the quillboar race and turned the maze of thorns into a bastion of undead might. Now the quillboar fight a desperate battle to reclaim their beloved city before Amnennar spreads his control across the Barrens.";
---Razorfen Kraul
METAMAP_RFK_INFO = "Ten thousand years ago, during the War of the Ancients, the mighty demigod, Agamaggan, came forth to battle the Burning Legion. Though the colossal boar fell in combat, his actions helped save Azeroth from ruin. Yet over time, in the areas where his blood fell, massive thorn-ridden vines sprouted from the earth. The quillboar - believed to be the mortal offspring of the mighty god, came to occupy these regions and hold them sacred. The heart of these thorn-colonies was known as the Razorfen. The great mass of Razorfen Kraul was conquered by the old crone, Charlga Razorflank. Under her rule, the shamanistic quillboar stage attacks on rival tribes as well as Horde villages. Some speculate that Charlga has even been negotiating with agents of the Scourge - aligning her unsuspecting tribe with the ranks of the Undead for some insidious purpose.";
---Scarlet Monastery
METAMAP_TSM_INFO = "The Monastery was once a proud bastion of Lordaeron's priesthood - a center for learning and enlightenment. With the rise of the undead Scourge during the Third War, the peaceful Monastery was converted into a stronghold of the fanatical Scarlet Crusade. The Crusaders are intolerant of all non-human races, regardless of alliance or affiliation. They believe that any and all outsiders are potential carriers of the undead plague - and must be destroyed. Reports indicate that adventurers who enter the monastery are forced to contend with Scarlet Commander Mograine - who commands a large garrison of fanatically devoted warriors. However, the monastery's true master is High Inquisitor Whitemane - a fearsome priestess who possesses the ability to resurrect fallen warriors to do battle in her name.";
---Scholomance
METAMAP_SLM_INFO = "The Scholomance is housed within a series of crypts that lie beneath the ruined keep of Caer Darrow. Once owned by the noble Barov family, Caer Darrow fell to ruin following the Second War. As the wizard Kel'thuzad enlisted followers for his Cult of the Damned he would often promise immortality in exchange for serving his Lich King. The Barov family fell to Kel'thuzad's charismatic influence and donated the keep and its crypts to the Scourge. The cultists then killed the Barovs and turned the ancient crypts into a school for necromancy known as the Scholomance. Though Kel'thuzad no longer resides in the crypts, devoted cultists and instructors still remain. The powerful lich, Ras Frostwhisper, rules over the site and guards it in the Scourge's name - while the mortal necromancer, Darkmaster Gandling, serves as the school's insidious headmaster.";
---Shadowfang Keep
METAMAP_SFK_INFO = "During the Third War, the wizards of the Kirin Tor battled against the undead armies of the Scourge. When the wizards of Dalaran died in battle, they would rise soon after - adding their former might to the growing Scourge. Frustrated by their lack of progress (and against the advice of his peers), the Archmage Arugal elected to summon extra-dimensional entities to bolster Dalaran's diminishing ranks. Arugal's summoning brought the ravenous worgen into the world of Azeroth. The feral wolf-men slaughtered not only the Scourge, but quickly turned on the wizards themselves. The worgen sieged the keep of the noble, Baron Silverlaine. Situated above the tiny hamlet of Pyrewood, the keep quickly fell into shadow and ruin. Driven mad with guilt, Arugal adopted the worgen as his children and retreated to the newly dubbed 'Shadowfang Keep'. It's said he still resides there, protected by his massive pet, Fenrus - and haunted by the vengeful ghost of Baron Silverlaine.";
---Stratholme
METAMAP_STR_INFO = "Once the jewel of northern Lordaeron, the city of Stratholme is where Prince Arthas turned against his mentor, Uther Lightbringer, and slaughtered hundreds of his own subjects who were believed to have contracted the dreaded plague of undeath. Arthas' downward spiral and ultimate surrender to the Lich King soon followed. The broken city is now inhabited by the undead Scourge - led by the powerful lich, Kel'thuzad. A contingent of Scarlet Crusaders, led by Grand Crusader Dathrohan, also holds a portion of the ravaged city. The two sides are locked in constant, violent combat. Those adventurers brave (or foolish) enough to enter Stratholme will be forced to contend with both factions before long. It is said that the city is guarded by three massive watchtowers, as well as powerful necromancers, banshees and abominations. There have also been reports of a malefic Death Knight riding atop an unholy steed - dispensing indiscriminate wrath on all those who venture within the realm of the Scourge.";
---The Deadmines
METAMAP_TDM_INFO = "Once the greatest gold production center in the human lands, the Dead Mines were abandoned when the Horde razed Stormwind city during the First War. Now the Defias Brotherhood has taken up residence and turned the dark tunnels into their private sanctum. It is rumored that the thieves have conscripted the clever goblins to help them build something terrible at the bottom of the mines - but what that may be is still uncertain. Rumor has it that the way into the Deadmines lies through the quiet, unassuming village of Moonbrook.";
---The Stockade
METAMAP_TSK_INFO = "The Stockades are a high-security prison complex, hidden beneath the canal district of Stormwind city. Presided over by Warden Thelwater, the Stockades are home to petty crooks, political insurgents, murderers and a score of the most dangerous criminals in the land. Recently, a prisoner-led revolt has resulted in a state of pandemonium within the Stockades - where the guards have been driven out and the convicts roam free. Warden Thelwater has managed to escape the holding area and is currently enlisting brave thrill-seekers to venture into the prison and kill the uprising's mastermind - the cunning felon, Bazil Thredd.";
---The Temple of Atal'Hakkar
METAMAP_TST_INFO = "Over a thousand years ago, the powerful Gurubashi Empire was torn apart by a massive civil war. An influential group of troll priests, known as the Atal'ai, attempted to bring back an ancient blood god named Hakkar the Soulflayer. Though the priests were defeated and ultimately exiled, the great troll empire buckled in upon itself. The exiled priests fled far to the north, into the Swamp of Sorrows. There they erected a great temple to Hakkar - where they could prepare for his arrival into the physical world. The great dragon Aspect, Ysera, learned of the Atal'ai's plans and smashed the temple beneath the marshes. To this day, the temple's drowned ruins are guarded by the green dragons who prevent anyone from getting in or out. However, it is believed that some of the fanatical Atal'ai may have survived Ysera's wrath - and recommitted themselves to the dark service of Hakkar.";
---Uldaman
METAMAP_ULD_INFO = "Uldaman is an ancient Titan vault that has laid buried deep within the earth since the world's creation. Dwarven excavations have recently penetrated this forgotten city, releasing the Titans' first failed creations: the troggs. Legends say that the Titans created troggs from stone. When they deemed the experiment a failure, the Titans locked the troggs away and tried again - resulting in the creation of the dwarven race. The secrets of the dwarves' creation are recorded on the fabled Discs of Norgannon - massive Titan artifacts that lie at the very bottom of the ancient city. Recently, the Dark Iron dwarves have launched a series of incursions into Uldaman, hoping to claim the discs for their fiery master, Ragnaros. However, protecting the buried city are several guardians - giant constructs of living stone that crush any hapless intruders they find. The Discs themselves are guarded by a massive, sentient Stonekeeper called Archaedas. Some rumors even suggest that the dwarves' stone-skinned ancestors, the earthen, still dwell deep within the city's hidden recesses.";
---Wailing Caverns
METAMAP_TWC_INFO = "Recently, a night elf druid named Naralex discovered a network of underground caverns within the heart of the Barrens. Dubbed the 'Wailing Caverns', these natural caves were filled with steam fissures which produced long, mournful wails as they vented. Naralex believed he could use the caverns' underground springs to restore lushness and fertility to the Barrens - but to do so would require siphoning the energies of the fabled Emerald Dream. Once connected to the Dream however, the druid's vision somehow became a nightmare. Soon the Wailing Caverns began to change - the waters turned foul and the once-docile creatures inside metamorphosed into vicious, deadly predators. It is said that Naralex himself still resides somewhere inside the heart of the labyrinth, trapped beyond the edges of the Emerald Dream. Even his former acolytes have been corrupted by their master's waking nightmare - transformed into the wicked Druids of the Fang.";
---Zul'Farrak
METAMAP_ZFK_INFO = "This sun-blasted city is home to the Sandfury trolls, known for their particular ruthlessness and dark mysticism. Troll legends tell of a powerful sword called Sul'thraze the Lasher, a weapon capable of instilling fear and weakness in even the most formidable of foes. Long ago, the weapon was split in half. However, rumors have circulated that the two halves may be found somewhere within Zul'Farrak's walls. Reports have also suggested that a band of mercenaries fleeing Gadgetzan wandered into the city and became trapped. Their fate remains unknown. But perhaps most disturbing of all are the hushed whispers of an ancient creature sleeping within a sacred pool at the city's heart - a mighty demigod who will wreak untold destruction upon any adventurer foolish enough to awaken him.";
---Zul'Gurub
METAMAP_ZGB_INFO = "Over a thousand years ago the powerful Gurubashi Empire was torn apart by a massive civil war. An influential group of troll priests, known as the Atal'ai, called forth the avatar of an ancient and terrible blood god named Hakkar the Soulflayer. Though the priests were defeated and ultimately exiled, the great troll empire collapsed upon itself. The exiled priests fled far to the north, into the Swamp of Sorrows, where they erected a great temple to Hakkar in order to prepare for his arrival into the physical world.";
---Ahn'Qiraj
METAMAP_TAQ_INFO = "At the heart of Ahn'Qiraj lies an ancient temple complex. Built in the time before recorded history, it is both a monument to unspeakable gods and a massive breeding ground for the qiraji army. Since the War of the Shifting Sands ended a thousand years ago, the Twin Emperors of the qiraji empire have been trapped inside their temple, barely contained behind the magical barrier erected by the bronze dragon Anachronos and the night elves. Now that the Scepter of the Shifting Sands has been reassembled and the seal has been broken, the way into the inner sanctum of Ahn'Qiraj is open. Beyond the crawling madness of the hives, beneath the Temple of Ahn'Qiraj, legions of qiraji prepare for invasion. They must be stopped at all costs before they can unleash their voracious insectoid armies on Kalimdor once again, and a second War of the Shifting Sands breaks loose!";
---Ruins of Ahn'Qiraj
METAMAP_RAQ_INFO = "During the final hours of the War of the Shifting Sands, the combined forces of the night elves and the four dragonflights drove the battle to the very heart of the qiraji empire, to the fortress city of Ahn'Qiraj. Yet at the city gates, the armies of Kalimdor encountered a concentration of silithid war drones more massive than any they had encountered before. Ultimately the silithid and their qiraji masters were not defeated, but merely imprisoned inside a magical barrier, and the war left the cursed city in ruins. A thousand years have passed since that day, but the qiraji forces have not been idle. A new and terrible army has been spawned from the hives, and the ruins of Ahn'Qiraj are teeming once again with swarming masses of silithid and qiraji. This threat must be eliminated, or else all of Azeroth may fall before the terrifying might of the new qiraji army.";
---Naxxramas
METAMAP_NAX_INFO = "Floating above the Plaguelands, the necropolis known as Naxxramas serves as the seat of one of the Lich King's most powerful officers, the dreaded lich Kel'Thuzad. Horrors of the past and new terrors yet to be unleashed are gathering inside the necropolis as the Lich King's servants prepare their assault. Soon the Scourge will march again...";
---Hellfire Citadel
METAMAP_HFC_INFO = "Though much of Draenor was shattered by the reckless Ner'zhul, the Hellfire Citadel remains intact � inhabited now by marauding bands of red, furious fel orcs. Though the presence of this new, savage breed presents something of a mystery, what's far more disconcerting is that the numbers of these fel orcs seem to be growing. \n\nDespite Thrall and Grom Hellscream's successful bid to end the Horde's corruption by slaying Mannoroth, reports indicate that the barbaric orcs of Hellfire Citadel have somehow managed to find a new source of corruption to fuel their primitive bloodlust. \n\nWhatever authority these orcs answer to is unknown, although it is a strongly held belief that they are not working for the Burning Legion. \n\nPerhaps the most unsettling news to come from Outland are the accounts of thunderous, savage cries issuing from somewhere deep beneath the citadel. Many have begun to wonder if these unearthly outbursts are somehow connected to the corrupted fel orcs and their growing numbers. Unfortunately those questions will have to remain unanswered. \n\nAt least for now.";
---Coilfang Reservoir
METAMAP_CFR_INFO = "The delicate ecology of Zangarmarsh has been thrown out of balance. Unnatural phenomena are corrupting and destroying the marsh's native flora and fauna. This disturbance has been traced to the foreboding Coilfang Reservoir. It is rumored that the leader of this mysterious edifice is none other than the infamous Lady Vashj. Only you can discover her nefarious plans and stop them before it's too late. Coilfang Reservoir is divided into four areas, three of which are five-man dungeons (the Slave Pens, the Underbog, and the Steamvault), in addition to the 20-man raid dungeon, Serpentshrine Cavern.";
---Auchindoun
METAMAP_AUC_INFO = "It was once a holy ground for Draenei burial until a group of renegade Orcs botched an attempt to summon a demon in its walls. The resulting magical disaster nearly destroyed the entire area. Its crypt-filled interior looks quite haunting. \n\nAuchindoun is now in turmoil as different factions vie for power in this magical spot.\n\nNow it is ruled by a being named Murmur, a powerful elemental similar to Ragnaros and Thunderaan, but aligned with the power of elemental sound rather than with fire, wind, or other known elements. Along the way, you face fallen draenei, demons (including a fel guard overseer), ethereals, orcs, ogres, and even some undead.\n";
---Tempest Keep
METAMAP_TTK_INFO = "The mighty Tempest Keep was created by the enigmatic naaru: sentient beings of pure energy and the sworn enemies of the Burning Legion. As a base of operations for the naaru, the structure itself possesses the technology to teleport through alternate dimensions, traveling from one location to another in the blink of an eye. \n\nWith Outland serving as the strategic battlefront in the ongoing Burning Crusade, the naaru recently used Tempest Keep to reach the shattered land. However, when the naaru set out from their stronghold, Prince Kael�thas and his blood elves quickly raided the dimensional fortress and assumed control over its satellite structures. \n\nNow, guided by some unknown purpose, Kael�thas manipulates the keep�s otherworldly technologies, using them to harness the chaotic energies of the Netherstorm itself. \n\nThough Kael�thas and his minions maintain a tight hold on the keep, a band of draenei recently hijacked one of its satellite structures, the Exodar, and used it to escape Outland. In seeking out other worlds, the draenei, led by the ancient prophet, Velen, hoped to find allies who would stand with them against the Legion and its nihilistic Crusade.\n";
---Magtheridons Lair
METAMAP_MAG_INFO = "A brutal Pit Lord and servant of Mannoroth the Destructor, Magtheridon found his way to Draenor after its cataclysm. With the clans in disarray, and most killed in the disaster, Magtheridon was quick to show his power, and rallied the surviving orcs under his pennant. The orcs were corrupted and became Fel Orcs. He declared himself the ruler of the ruined world Outland. \n\nOver the years, Magtheridon brought legions of demons to Outland through the four dimensional gateways which Ner'zhul shattered the world with, and his forces became very expansive. These demons included Nether Dragons, Voidwalkers, Succubi, Felguards, Felbeasts, Doomguards, Eredar, and Infernals. \n\nIt was almost twenty years after the Cataclysm that Illidan and his servants came to Outland with a plan to rid the land of all demonic entities there, so that Kil'jaeden, Illidan's vengeful master, could not follow him. \n\nMagtheridon found himself under attack by Illidan, Kael'thas and his Blood Elves, Lady Vashj's army of naga, and even the elusive draenei, led by the Elder Sage, Akama. \n\nThe combined disrupted the dimensional gateways which supplied Magtheridon with reinforcements, and then laid siege to Magtheridon's Black Citadel itself. \n\nThe Pit Lord rallied his forces to defend him, but the combined skills of the heroes crushed his resistances. Eventually, Magtheridon was defeated by the four generals, and asked if Illidan had been sent to test him. Illidan cackled in reply, saying that he had come to replace him.";
---Karazhan
METAMAP_KZN_INFO = "Between Duskwood and the Swamp of Sorrows lies the desolate region of Deadwind Pass, where jagged, brooding spires of granite loom over petrified, lifeless forests. As its name suggests, it is a land devoid of life.\nBut it was not always so... \n\nMedivh, the Last Guardian, made his home in Deadwind, in the bright tower of Karazhan. Though he was the greatest wizard of his day (and humanity's intended custodian) Medivh was secretly possessed by the dark spirit of Sargeras, the Destroyer of Worlds. Through Medivh, Sargeras opened the Dark Portal and allowed the orcs to wage war upon the mortal kingdoms of Azeroth. \n\nAs the war progressed, Medivh fought against Sargeras' control. The raging conflict within him finally drove the wizard irrevocably insane. His childhood friend and the king's lieutenant-at-arms, Anduin Lothar, suspected the mage of treachery. With the aid of Medivh's young apprentice, Khadgar, Lothar stormed Karazhan and killed his one-time comrade. Since that day, a terrible curse has pervaded both the tower and the lands around it - casting a dark pall over Deadwind Pass and the region that is now known as Duskwood \n\nIn recent years, nobles of Darkshire ventured into Deadwind Pass to investigate the blight that had settled over the region. They entered the dark tower � but never emerged. In fact, witnesses maintain that the dread spirits of the nobles now reside within Karazhan's walls, cursed to revel in the tower's crumbling opera house for eternity. Yet far more perilous spirits reside within Medivh's macabre study, for it was there that demonic entities responded to the deranged wizard's summons. \n\nDespite the myriad terrors that lie within, adventurers are still drawn to Karazhan - tempted by rumors of unspeakable secrets that may be found within the tower's arcane libraries. It is said that the vast, magical halls house the powerful spellbooks of Medivh himself.\n\nOnly one thing is certain when visiting the dreaded tower of Karazhan...\n\n...you may never find your way out.\n";
---Gruul's Lair
METAMAP_GRL_INFO = "";
---Caverns of Time
METAMAP_COT_INFO = "";
