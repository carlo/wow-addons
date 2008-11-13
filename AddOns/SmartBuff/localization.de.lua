-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() == "deDE") then

-- Druid
SMARTBUFF_DRUID_CAT = "Katzengestalt";
SMARTBUFF_DRUID_MOONKIN = "Mondkingestalt";
SMARTBUFF_DRUID_TRACK = "Humanoide aufsp\195\188ren";

SMARTBUFF_MOTW = "Mal der Wildnis";
SMARTBUFF_GOTW = "Gabe der Wildnis";
SMARTBUFF_THORNS = "Dornen";
SMARTBUFF_OMENOFCLARITY = "Omen der Klarsicht";
SMARTBUFF_BARKSKIN = "Baumrinde";
SMARTBUFF_NATURESGRASP = "Griff der Natur";
SMARTBUFF_TIGERSFURY = "Tigerfuror";
SMARTBUFF_REJUVENATION = "Verj\195\188ngung";
SMARTBUFF_REGROWTH = "Nachwachsen";

SMARTBUFF_REMOVECURSE = "Fluch Aufheben";
SMARTBUFF_ABOLISHPOISON = "Vergiftung Aufheben";

-- Mage
SMARTBUFF_AI = "Arkane Intelligenz";
SMARTBUFF_AB = "Arkane Brillanz";
SMARTBUFF_ICEARMOR = "Eisr\195\188stung";
SMARTBUFF_FROSTARMOR = "Frostr\195\188stung";
SMARTBUFF_MAGEARMOR = "Magische R\195\188stung";
SMARTBUFF_MOLTENARMOR = "Gl\195\188hende R\195\188stung";
SMARTBUFF_DAMPENMAGIC = "Magie d\195\164mpfen";
SMARTBUFF_AMPLIFYMAGIC = "Magie verst\195\164rken";
SMARTBUFF_MANASHIELD = "Manaschild";
SMARTBUFF_FIREWARD = "Feuerzauberschutz";
SMARTBUFF_FROSTWARD = "Frostzauberschutz";
SMARTBUFF_ICEBARRIER = "Eisbarriere";
SMARTBUFF_COMBUSTION = "Verbrennung";
SMARTBUFF_ARCANEPOWER = "Arkane Macht";
SMARTBUFF_PRESENCEOFMIND = "Geistesgegenwart";

SMARTBUFF_MAGE_PATTERN = {"r\195\188stung$"};

-- Priest
SMARTBUFF_PWF = "Machtwort: Seelenst\195\164rke";
SMARTBUFF_POF = "Gebet der Seelenst\195\164rke";
SMARTBUFF_SP = "Schattenschutz";
SMARTBUFF_POSP = "Gebet des Schattenschutzes";
SMARTBUFF_INNERFIRE = "Inneres Feuer";
SMARTBUFF_DS = "G\195\182ttlicher Willen";
SMARTBUFF_POS = "Gebet der Willenskraft";
SMARTBUFF_PWS = "Machtwort: Schild";
SMARTBUFF_FEARWARD = "Furchtzauberschutz";
SMARTBUFF_ELUNESGRACE = "Elunes Anmut";
SMARTBUFF_FEEDBACK = "R\195\188ckkopplung";
SMARTBUFF_SHADOWGUARD = "Schattenschild";
SMARTBUFF_TOUCHOFWEAKNESS = "Ber\195\188hrung der Schw\195\164che";
SMARTBUFF_INNERFOCUS = "Innerer Fokus";
SMARTBUFF_RENEW = "Erneuerung";

-- Warlock
SMARTBUFF_FELARMOR = "Teufelsr\195\188stung";
SMARTBUFF_DEMONARMOR = "D\195\164monenr\195\188stung";
SMARTBUFF_DEMONSKIN = "D\195\164monenhaut";
SMARTBUFF_UNENDINGBREATH = "Unendlicher Atem";
SMARTBUFF_DGINVISIBILITY = "Gro\195\159e Unsichtbarkeit entdecken";
SMARTBUFF_DINVISIBILITY = "Unsichtbarkeit entdecken";
SMARTBUFF_DLINVISIBILITY = "Geringe Unsichtbarkeit entdecken";
SMARTBUFF_SOULLINK = "Seelenverbindung";
SMARTBUFF_SHADOWWARD = "Schatten-Zauberschutz";
SMARTBUFF_DARKPACT = "Dunkler Pakt";
SMARTBUFF_SOULSTONE = "Seelenstein-Auferstehung";

SMARTBUFF_WARLOCK_PATTERN = {"^D\195\164monen%a+"};

-- Hunter
SMARTBUFF_TRUESHOTAURA = "Aura des Volltreffers";
SMARTBUFF_RAPIDFIRE = "Schnellfeuer";
SMARTBUFF_AOTH = "Aspekt des Falken";
SMARTBUFF_AOTM = "Aspekt des Affen";
SMARTBUFF_AOTW = "Aspekt der Wildnis";
SMARTBUFF_AOTB = "Aspekt des Wildtiers";
SMARTBUFF_AOTC = "Aspekt des Geparden";
SMARTBUFF_AOTP = "Aspekt des Rudels";
SMARTBUFF_AOTV = "Aspekt der Viper";

SMARTBUFF_HUNTER_PATTERN = {"^Aspekt de%a %a+"};

-- Shamane
SMARTBUFF_LIGHTNINGSHIELD = "Blitzschlagschild";
SMARTBUFF_WATERSHIELD = "Wasserschild";
SMARTBUFF_EARTHSHIELD = "Erdschild";
SMARTBUFF_ROCKBITERW = "Waffe des Felsbei\195\159ers";
SMARTBUFF_FROSTBRANDW = "Waffe des Frostbrands";
SMARTBUFF_FLAMETONGUEW = "Waffe der Flammenzunge";
SMARTBUFF_WINDFURYW = "Waffe des Windzorns";
SMARTBUFF_WATERBREATHING = "Wasseratmung";

SMARTBUFF_SHAMAN_PATTERN = {"%a+schild$"};

-- Warrior
SMARTBUFF_BATTLESHOUT = "Schlachtruf";
SMARTBUFF_COMMANDINGSHOUT = "Befehlsruf";
SMARTBUFF_BERSERKERRAGE = "Berserkerwut";
SMARTBUFF_BLOODRAGE = "Blutrausch";

-- Rogue
SMARTBUFF_BLADEFLURRY = "Klingenwirbel";
SMARTBUFF_SAD = "Zerh\195\164ckseln";
SMARTBUFF_EVASION = "Entrinnen";
SMARTBUFF_INSTANTPOISON = "Sofort wirkendes Gift";
SMARTBUFF_WOUNDPOISON = "Wundgift";
SMARTBUFF_MINDPOISON = "Gedankenbenebelndes Gift";
SMARTBUFF_DEADLYPOISON = "T\195\182dliches Gift";
SMARTBUFF_CRIPPLINGPOISON = "Verkr\195\188ppelndes Gift";
SMARTBUFF_ANESTHETICPOISON = "Beruhigendes Gift";

-- Paladin
SMARTBUFF_RIGHTEOUSFURY = "Zorn der Gerechtigkeit";
SMARTBUFF_HOLYSHIELD = "Heiliger Schild";
SMARTBUFF_BOM = "Segen der Macht";
SMARTBUFF_GBOM = "Gro\195\159er Segen der Macht";
SMARTBUFF_BOW = "Segen der Weisheit";
SMARTBUFF_GBOW = "Gro\195\159er Segen der Weisheit";
SMARTBUFF_BOSAL = "Segen der Rettung";
SMARTBUFF_GBOSAL = "Gro\195\159er Segen der Rettung";
SMARTBUFF_BOK = "Segen der K\195\182nige";
SMARTBUFF_GBOK = "Gro\195\159er Segen der K\195\182nige";
SMARTBUFF_BOSAN = "Segen des Refugiums";
SMARTBUFF_GBOSAN = "Gro\195\159er Segen des Refugiums";
SMARTBUFF_BOL = "Segen des Lichts";
SMARTBUFF_GBOL = "Gro\195\159er Segen des Lichts";
SMARTBUFF_SOCOMMAND = "Siegel des Befehls";
SMARTBUFF_SOFURY = "Siegel des Furors";
SMARTBUFF_SOJUSTICE = "Siegel der Gerechtigkeit";
SMARTBUFF_SOLIGHT = "Siegel des Lichts";
SMARTBUFF_SORIGHTEOUSNESS = "Siegel der Rechtschaffenheit";
SMARTBUFF_SOWISDOM = "Siegel der Weisheit";
SMARTBUFF_SOTCRUSADER = "Siegel des Kreuzfahrers";
SMARTBUFF_SOVENGEANCE = "Siegel der Vergeltung";
SMARTBUFF_SOBLOOD = "Siegel des Blutes";
SMARTBUFF_DEVOTIONAURA = "Aura der Hingabe";
SMARTBUFF_RETRIBUTIONAURA = "Aura der Vergeltung";
SMARTBUFF_CONCENTRATIONAURA = "Aura der Konzentration";
SMARTBUFF_SHADOWRESISTANCEAURA = "Aura des Schattenwiderstands";
SMARTBUFF_FROSTRESISTANCEAURA = "Aura des Frostwiderstands";
SMARTBUFF_FIRERESISTANCEAURA = "Aura des Feuerwiderstands";
SMARTBUFF_SANCTITYAURA = "Aura der Heiligkeit";
SMARTBUFF_CRUSADERAURA = "Aura des Kreuzfahrers";

SMARTBUFF_PALADIN_PATTERN = {"^Siegel de%a %a+"};

-- Stones and oils
SMARTBUFF_SSROUGH = "Rauer Wetzstein";
SMARTBUFF_SSCOARSE = "Grober Wetzstein";
SMARTBUFF_SSHEAVY = "Schwerer Wetzstein";
SMARTBUFF_SSSOLID = "Robuster Wetzstein";
SMARTBUFF_SSDENSE = "Verdichteter Wetzstein";
SMARTBUFF_SSELEMENTAL = "Elementarwetzstein";
SMARTBUFF_WSROUGH = "Rauer Gewichtsstein";
SMARTBUFF_WSCOARSE = "Grober Gewichtsstein";
SMARTBUFF_WSHEAVY = "Schwerer Gewichtsstein";
SMARTBUFF_WSSOLID = "Robuster Gewichtsstein";
SMARTBUFF_WSDENSE = "Verdichteter Gewichtsstein";
SMARTBUFF_SHADOWOIL = "Schatten\195\182l";
SMARTBUFF_FROSTOIL = "Frost\195\182l";
SMARTBUFF_MANAOILMINOR = "Schwaches Mana\195\182l";
SMARTBUFF_MANAOILLESSER = "Geringes Mana\195\182l";
SMARTBUFF_MANAOILBRILLIANT = "Hervorragendes Mana\195\182l";
SMARTBUFF_MANAOILSUPERIOR = "\195\156berragendes Mana\195\182l";
SMARTBUFF_WIZARDOILMINOR = "Schwaches Zauber\195\182l";
SMARTBUFF_WIZARDOILLESSER = "Geringes Zauber\195\182l";
SMARTBUFF_WIZARDOIL = "Zauber\195\182l";
SMARTBUFF_WIZARDOILBRILLIANT = "Hervorragendes Zauber\195\182l";
SMARTBUFF_WIZARDOILSUPERIOR = "\195\156berragendes Zauber\195\182l";

SMARTBUFF_WEAPON_STANDARD = {"Dolche", "\195\164xte", "schwerter", "streitkolben", "St\195\164be", "Faustwaffen"};
SMARTBUFF_WEAPON_BLUNT = {"streitkolben", "Faustwaffen", "St\195\164be"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "Gewichtsstein$";
SMARTBUFF_WEAPON_SHARP = {"Dolche", "\195\164xte", "schwerter", "Stangenwaffen"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "Wetzstein$";

-- Tracking
SMARTBUFF_FINDMINERALS = "Mineraliensuche";
SMARTBUFF_FINDHERBS = "Kr\195\164utersuche";
SMARTBUFF_FINDTREASURE = "Schatzsucher";
SMARTBUFF_TRACKHUMANOIDS = "Humanoide aufsp\195\188ren";
SMARTBUFF_TRACKBEASTS = "Wildtiere aufsp\195\188ren";
SMARTBUFF_TRACKUNDEAD = "Untote aufsp\195\188ren";
SMARTBUFF_TRACKHIDDEN = "Verborgenes aufsp\195\188ren";
SMARTBUFF_TRACKELEMENTALS = "Elementare aufsp\195\188ren";
SMARTBUFF_TRACKDEMONS = "D\195\164monen aufsp\195\188ren";
SMARTBUFF_TRACKGIANTS = "Riesen aufsp\195\188ren";
SMARTBUFF_TRACKDRAGONKIN = "Drachkin aufsp\195\188ren";
SMARTBUFF_SENSEDEMONS = "D\195\164monen Sp\195\188ren";
SMARTBUFF_SENSEUNDEAD = "Untote Sp\195\188ren";

-- Racial
SMARTBUFF_STONEFORM = "Steinform";
SMARTBUFF_PRECEPTION = "Wachsamkeit";
SMARTBUFF_BLOODFURY = "Kochendes Blut";
SMARTBUFF_BERSERKING = "Berserker";
SMARTBUFF_WOTFORSAKEN = "Wille der Verlassenen";

-- Reagents
SMARTBUFF_WILDBERRIES = "Wilde Beeren";
SMARTBUFF_WILDTHORNROOT = "Wilder Dornwurz";
SMARTBUFF_WILDQUILLVINE = "Wilde Federranke";
SMARTBUFF_ARCANEPOWDER = "Arkanes Pulver";
SMARTBUFF_HOLYCANDLE = "Heilige Kerze";
SMARTBUFF_SACREDCANDLE = "Hochheilige Kerze";
SMARTBUFF_SYMBOLOFKINGS = "Symbol der K\195\182nige";

-- Food
SMARTBUFF_SAGEFISHDELIGHT = "Weisenfisch Supreme";
SMARTBUFF_BUZZARDBITES = "Bussardbissen";
SMARTBUFF_RAVAGERDOG = "Hei\195\159er Hetzer";
SMARTBUFF_FELTAILDELIGHT = "Teufelsfinne Supreme";
SMARTBUFF_CLAMBAR = "Muschelriegel";
SMARTBUFF_SPORELINGSNACK = "Sporlingschmaus";
SMARTBUFF_BLACKENEDSPOREFISH = "Schwarzgebratener Sporenfisch";
SMARTBUFF_BLACKENEDBASILISK = "Schwarzgebratener Basilisk";
SMARTBUFF_GRILLEDMUDFISH = "Gegrillter Matschflosser";
SMARTBUFF_POACHEDBLUEFISH = "Ged\195\188nstete Blauflosse";
SMARTBUFF_ROASTEDCLEFTHOOF = "Ger\195\182steter Grollhuf";
SMARTBUFF_WARPBURGER = "Doppelwarper";
SMARTBUFF_TALBUKSTEAK = "Talbuksteak";
SMARTBUFF_GOLDENFISHSTICKS = "Goldfischst\195\164bchen";
SMARTBUFF_CRUNCHYSERPENT = "Knusperschlange";
SMARTBUFF_MOKNATHALSHORTRIBS = "Rippchen der Mok'Nathal";
SMARTBUFF_SPICYCRAWDAD = "W\195\188rziger Flusskrebs";

SMARTBUFF_FOOD_AURA = "Satt";


-- Creature type
SMARTBUFF_HUMANOID  = "Humanoid";
SMARTBUFF_DEMON     = "D\195\164mon";
SMARTBUFF_BEAST     = "Wildtier";
SMARTBUFF_ELEMENTAL = "Elementar";
SMARTBUFF_DEMONTYPE = "Wichtel";

-- Classes
SMARTBUFF_CLASSES = {"Druide", "J\195\164ger", "Magier", "Paladin", "Priester", "Schurke", "Schamane", "Hexenmeister", "Krieger", "J\195\164ger Pet", "Hexer Pet"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"Solo", "Gruppe", "Raid", "Schlachtfeld", "MC", "Ony", "BWL", "Naxx", "AQ", "ZG", "Custom 1", "Custom 2", "Custom 3", "Custom 4", "Custom 5"};
SMARTBUFF_INSTANCES = {"Der geschmolzene Kern", "Onyxias Hort", "Pechschwingenhort", "Naxxramas", "Ahn'Qiraj", "Zul'Gurub", "Alteractal", "Arathibecken", "Kriegshymnenschlucht", "Die Arena des Schergrats", "Die Arena von Nagrand"};

-- Mount
SMARTBUFF_MOUNT = "Erh\195\182ht Tempo um (%d+)%%.";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Trigger";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Ziel";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Optionen";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Buff Timer l\195\182schen";

-- Options Frame Text
SMARTBUFF_OFT                = "SmartBuff An/Aus";
SMARTBUFF_OFT_MENU           = "Zeige/verberge Optionen Men\195\188";
SMARTBUFF_OFT_AUTO           = "Erinnerung";
SMARTBUFF_OFT_AUTOTIMER      = "Check Timer";
SMARTBUFF_OFT_AUTOCOMBAT     = "im Kampf";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Ton";
SMARTBUFF_OFT_AUTOREST       = "Unterdr\195\188ckt in St\195\164dten";
SMARTBUFF_OFT_HUNTERPETS     = "J\195\164ger Pets buffen";
SMARTBUFF_OFT_WARLOCKPETS    = "Hexer Pets buffen";
SMARTBUFF_OFT_ARULES         = "Zus\195\164tzliche Regeln";
SMARTBUFF_OFT_GRP            = "Raid Sub-Gruppen zum Buffen";
SMARTBUFF_OFT_SUBGRPCHANGED  = "\195\150ffne Men\195\188";
SMARTBUFF_OFT_BUFFS          = "Buffs/F\195\164higkeiten";
SMARTBUFF_OFT_TARGET         = "Bufft das anvisierte Ziel";
SMARTBUFF_OFT_DONE           = "Fertig";
SMARTBUFF_OFT_APPLY          = "\195\156bernehmen";
SMARTBUFF_OFT_GRPBUFFSIZE    = "Gruppengr\195\182sse";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Klassengr\195\182sse";
SMARTBUFF_OFT_MESSAGES       = "Unterdr\195\188cke Meldungen";
SMARTBUFF_OFT_MSGNORMAL      = "Normal";
SMARTBUFF_OFT_MSGWARNING     = "Warnung";
SMARTBUFF_OFT_MSGERROR       = "Fehler";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Verberge Minimap-Knopf";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff Timer";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Vorlagenwechsel";
SMARTBUFF_OFT_SELFFIRST      = "Mich zuerst";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Bufft mit Mausrad hoch";
SMARTBUFF_OFT_SCROLLWHEELDOWN = "runter";
SMARTBUFF_OFT_TARGETSWITCH   = "bei Zielwechsel";
SMARTBUFF_OFT_BUFFTARGET     = "Bufft das Ziel";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instanzen";
SMARTBUFF_OFT_CHECKCHARGES   = "Aufladungen";
SMARTBUFF_OFT_RBT            = "Reset BT";
SMARTBUFF_OFT_BUFFINCITIES   = "Bufft in St\195\164dten";
SMARTBUFF_OFT_UISYNC         = "UI Sync";
SMARTBUFF_OFT_ADVGRPBUFFCHECK = "Grp Buff Check";
SMARTBUFF_OFT_ADVGRPBUFFRANGE = "Grp Range Check";
SMARTBUFF_OFT_BLDURATION     = "Blacklisted";
SMARTBUFF_OFT_COMPMODE       = "Komp. Modus";
SMARTBUFF_OFT_MINIGRP        = "Mini Gruppe";
SMARTBUFF_OFT_ANTIDAZE       = "Anti-Daze";
SMARTBUFF_OFT_HIDESABUTTON   = "Verberge Action-Knopf";
SMARTBUFF_OFT_INCOMBAT       = "im Kampf";

-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Schaltet SmartBuff An/Aus";
SMARTBUFF_OFTT_AUTO          = "Schaltet die Erinnerung an fehlende Buffs An/Aus";
SMARTBUFF_OFTT_AUTOTIMER     = "Verz\195\182gerung in Sekunden zwischen zwei Checks.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Check auch w\195\164hrend dem Kampf durchf\195\188hren.";
SMARTBUFF_OFTT_AUTOCHAT      = "Zeigt fehlende Buffs als Chat-Meldung an.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Zeigt fehlende Buffs als Splash-Meldung\nin der mitte des Bildschirms an.";
SMARTBUFF_OFTT_AUTOSOUND     = "Bei fehlende Buffs erklingt ein Ton.";
SMARTBUFF_OFTT_AUTOREST      = "Erinnerung wird in den\nHauptst\195\164dten unterdr\195\188ckt.";
SMARTBUFF_OFTT_HUNTERPETS    = "Bufft die J\195\164ger Pets auch.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Bufft die Hexer Pets auch,\nausser den " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Bufft nicht:\n- Dornen auf Magier, Priester und Hexer\n- Arkane Intelligenz auf Klassen ohne Mana\n- G\195\182ttlicher Willen auf Klassen ohne Mana";
SMARTBUFF_OFTT_SUBGRPCHANGED = "\195\150ffnet automatisch das SmartBuff Men\195\188,\nwenn du die Sub-Gruppe gewechselt hast.";
SMARTBUFF_OFTT_GRPBUFFSIZE   = "Anzahl Spieler die in der Gruppe sein m\195\188ssen\nund den Gruppen-Buff nicht haben,\ndamit der Gruppen-Buff verwendet wird.";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Verbirgt den SmartBuff Minimap-Knopf.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf der Buffs,\nsoll daran erinnert werden.\n0 = Deaktivert";
SMARTBUFF_OFTT_SELFFIRST     = "Bufft den eigenen Charakter immer zuerst.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Bufft beim Bewegen des Scrollrads nach vorne.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Bufft beim Bewegen des Scrollrads zur\195\188ck.";
SMARTBUFF_OFTT_TARGETSWITCH  = "Bufft beim Wechsel eines Ziels.";
SMARTBUFF_OFTT_BUFFTARGET    = "Bufft zuerst das aktuelle Ziel,\nfalls dies freundlich ist.";
SMARTBUFF_OFTT_BUFFPVP       = "Bufft auch Spieler im PvP Modus,\nwenn man selbst nicht im PvP ist.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Wechselt automatisch die Buff-Vorlage,\nwenn der Gruppentyp sich \195\164ndert.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Wechselt automatisch die Buff-Vorlage,\nwenn die Instanz sich \195\164ndert.";
SMARTBUFF_OFTT_CHECKCHARGES  = "Erinnerung wenn die Aufladungen\neines Buffs bald aufgebraucht sind.\n0 = Deaktivert";
SMARTBUFF_OFTT_BUFFINCITIES  = "Bufft auch in den Hauptst\195\164dten.\nWenn du PvP geflagged bist, bufft es immer.";
SMARTBUFF_OFTT_UISYNC        = "Aktiviert die Synchronisation mit dem UI,\num die Buff-Zeiten der anderen Spieler zu erhalten.";
SMARTBUFF_OFTT_ADVGRPBUFFCHECK = "Der erweiterte Gruppenbuff-Check\nbezieht auch die Einzelbuffs mitein,\nbevor ein Gruppenbuff benutzt wird.";
SMARTBUFF_OFTT_ADVGRPBUFFRANGE = "Der erweiterte Gruppenbuff-Distanz-Check\n\195\188berpr\195\188ft ob jedes Gruppenmitglied auch\ninnerhalb der Buff-Distanz ist,\nbevor ein Gruppenbuff benutzt wird.";
SMARTBUFF_OFTT_BLDURATION    = "Wieviele Sekunden ein Spieler auf\ndie schwarze Liste gesetzt wird.\n0 = Deaktivert";
SMARTBUFF_OFTT_COMPMODE      = "Kompatibilit\195\164ts Modus\nWarnung!!!\nBenutzte diesen Modus nur, wenn Probleme auftreten\nBuffs auf sich selbst zu casten.";
SMARTBUFF_OFTT_MINIGRP       = "Zeigt die Raid-Subgruppen Einstellungen in einem\neigenen verschiebbaren Mini-Fenster an.";
SMARTBUFF_OFTT_ANTIDAZE      = "Bricht automatisch den\nAspekt des Geparden/Rudels ab,\nwenn jemand bet\195\164ubt wird\n(Selbst oder Gruppe).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Wechselt die Schriftart\nder Buff-Meldungen.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Verbirgt den SmartBuff Action-Knopf.";
SMARTBUFF_OFTT_SPLASHDURATION= "Wieviele Sekunden die Splash Meldung angezeigt wird,\nbevor sie ausgeblendet wird.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Nur mich";
SMARTBUFF_BST_SELFNOT        = "Mich nicht";
SMARTBUFF_BST_COMBATIN       = "Im Kampf";
SMARTBUFF_BST_COMBATOUT      = "Aus dem Kampf";
SMARTBUFF_BST_MAINHAND       = "Waffenhand";
SMARTBUFF_BST_OFFHAND        = "Schildhand";
SMARTBUFF_BST_REMINDER       = "Benachrichtigung";
SMARTBUFF_BST_MANALIMIT      = "Grenzwert";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Bufft nur deinen eigenen Charakter."; 
SMARTBUFF_BSTT_SELFNOT       = "Bufft alle anderen selektierte Klassen,\nausser deinen eigenen Charakter.";
SMARTBUFF_BSTT_COMBATIN      = "Bufft innerhalb des Kampfes.";
SMARTBUFF_BSTT_COMBATOUT     = "Bufft ausserhalb des Kampfes.";
SMARTBUFF_BSTT_MAINHAND      = "Bufft die Haupthand.";
SMARTBUFF_BSTT_OFFHAND       = "Bufft die Schildhand.";
SMARTBUFF_BSTT_REMINDER      = "Erinnerungs-Nachricht ausgeben.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf des Buffs,\nsoll daran erinnert werden.\n0 = Globaler Rebuff Timer";
SMARTBUFF_BSTT_MANALIMIT     = "Mana/Wut/Energie Grenzwert\nWenn du unter diesen Wert f\195\164llst\nwird der Buff nicht mehr verwendet.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Minimiert/Maximiert\ndas Optionenfenster";

-- Messages
SMARTBUFF_MSG_LOADED         = "geladen";
SMARTBUFF_MSG_DISABLED       = "SmartBuff ist deaktiviert!";
SMARTBUFF_MSG_SUBGROUP       = "Du hast die Subgruppe gewechselt, bitte \195\188berpr\195\188fe die Einstellungen!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nichts zu buffen";
SMARTBUFF_MSG_BUFFED         = "gebuffed";
SMARTBUFF_MSG_OOR            = "ist ausser Reichweite zum Buffen!";
--SMARTBUFF_MSG_CD             = "hat noch Cooldown";
SMARTBUFF_MSG_CD             = "Globaler Cooldown!";
SMARTBUFF_MSG_CHAT           = "nicht m\195\182glich \195\188ber Chat-Befehl!";
SMARTBUFF_MSG_SHAPESHIFT     = "In Verwandlung kann nicht gebufft werden!";
SMARTBUFF_MSG_NOACTIONSLOT   = "muss in einem Slot auf der Aktionsleiste sein, dass es funktioniert!";
SMARTBUFF_MSG_GROUP          = "Gruppe";
SMARTBUFF_MSG_NEEDS          = "ben\195\182tigt";
SMARTBUFF_MSG_OOM            = "Zuwenig Mana/Wut/Energie!";
SMARTBUFF_MSG_STOCK          = "Aktueller Bestand";
SMARTBUFF_MSG_NOREAGENT      = "Zuwenig";
SMARTBUFF_MSG_DEACTIVATED    = "deaktiviert!";
SMARTBUFF_MSG_REBUFF         = "ReBuff";
SMARTBUFF_MSG_LEFT           = "\195\188brig";
SMARTBUFF_MSG_CLASS          = "Klasse";
SMARTBUFF_MSG_CHARGES        = "Aufladungen";

-- Support
SMARTBUFF_MINIMAP_TT         = "Links Klick: Optionen Men\195\188\nRechts Klick: An/Aus\nAlt-Links Klick: SmartDebuff\nShift-Ziehen: Knopf verschieben";
SMARTBUFF_TITAN_TT           = "Links Klick: Optionen Men\195\188\nRechts Klick: An/Aus\nAlt-Links Klick: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nLinks Klick: Optionen Men\195\188\nShift-Links Klick: An/Aus\nAlt-Links Klick: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S Knopf -|r\nLinks Klick: Ordne nach Klassen\nShift-Links Klick: Klassen-Farben\nAlt-Links Klick: Zeige L/R\n|cff20d2ff- P Knopf -|r\nLinks Klick: Verberge Pets";

end
