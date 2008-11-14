--  Translation courtesy of Stan (Arcádia - EU Zirkel des Cenarius)
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Omen", "deDE")
if not L then return end

-- Main Omen window
L["<Unknown>"] = "<Unbekannt>"
L["Omen Quick Menu"] = "Omen Schnellmenü"
L["Use Focus Target"] = "Fokusziel verwenden"
L["Test Mode"] = "Testmodus"
L["Open Config"] = "Optionen öffnen"
L["Open Omen's configuration panel"] = "Omens Konfigurationsmenü öffnen"
L["Hide Omen"] = "Omen verstecken"
L["Name"] = "Name"
L["Threat [%]"] = "Bedrohung [%]"
L["Threat"] = "Bedrohung"
L["TPS"] = "BPS"
L["Toggle Focus"] = "Fokus an/ausschalten"
L["> Pull Aggro <"] = "> Aggro ziehen <"

-- Warnings
L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."] = "|cffff0000Fehler:|r Omen kann keine Wackelwarnungen benutzen wenn Namensschilder aktiviert wurden seitdem Sie eingeloggt haben."
L["Passed %s%% of %s's threat!"] = "%s%% der Bedrohung von %s überschritten!"

-- Config module titles
L["General Settings"] = "Allgemeine Optionen"
L["Profiles"] = "Profile"
L["Slash Command"] = "Slashkommando"

-- Config strings, general settings section
L["OMEN_DESC"] = "Omen ist ein leichtgewichtiges Bedrohungsmeter, dass Ihnen die Bedrohung auf Monstern anzeigt mit denen Sie sich im Kampf befinden. Sie können ändern wie Omen aussieht und sich verhält und verschiedene Profile für Ihre Spielfiguren festlegen."
L["Alpha"] = "Sichtbarkeit"
L["Controls the transparency of the main Omen window."] = "Kontrolliert die Sichtbarkeit des Omen Hauptfensters"
L["Scale"] = "Skalierung"
L["Controls the scaling of the main Omen window."] = "Kontrolliert die Skalierung des Omen Hauptfensters"
L["Frame Strata"] = "Höhenstufe"
L["Controls the frame strata of the main Omen window. Default: MEDIUM"] = "Kontrolliert die Höhenstufe des Omen Hauptfensters. Standard: MEDIUM"
L["Clamp To Screen"] = "Auf dem Bildschirm festhalten"
L["Controls whether the main Omen window can be dragged offscreen"] = "Kontrolliert ob das Omen Fenster über die Bildschirmkanten hinaus verschoben werden kann"
L["Tells Omen to additionally check your 'focus' and 'focustarget' before your 'target' and 'targettarget' in that order for threat display."] = "Lässt Omen zusätzlich den Fokus und das Fokusziel vor dem Ziel und dem Ziel des Ziels für die Bedrohungsanzeige überprüfen"
L["Tells Omen to enter Test Mode so that you can configure Omen's display much more easily."] = "Startet den Omen Testmodus um das Einstellen der Anzeige zu vereinfachen"
L["Collapse to show a minimum number of bars"] = "Zusammenklappen um nur eine minimale Anzahl an Balken zu zeigen"
L["Lock Omen"] = "Omen verankern"
L["Locks Omen in place and prevents it from being dragged or resized."] = "Verankert Omen um zu verhindern, dass es verschoben oder die Größe geändert wird."
L["Show minimap button"] = "Zeige Minimap Icon"
L["Show the Omen minimap button"] = "Zeige das Omen Minimap Icon"
L["Ignore Player Pets"] = "Spieler Begleiter ignorieren"
L["IGNORE_PLAYER_PETS_DESC"] = [[
Veranlasst Omen gegnerische Spielerbegleiter ausser acht zu lassen wenn bestimmt wird auf welche Einheit Bedrohung angezeigt werden soll.

Spielerbegleiter haben nur eine Bedrohungsliste wenn sie sich im |cffffff78Aggressiven|r oder |cffffff78Defensiveb|r Modus befinden und so wie normale Mobs verhalten, also das Ziel mit der größten Bedrohung angreiffen. Wird der Beleiter dazu veranlasst, eine bestimntes Ziel anzugreiffen, behält der Begleiter eine Bedrohungstabelle, aber bleibt bei dem festgelegten Ziel, welches per Definition 100% Bedrohung hat. Spielerbegleiter können gespottet werden um sie zu zwingen Sie anzugreiffen.

Spielerbegleiter im |cffffff78Passiven|r Modus haben auf jeden Fall keine Bedrohungstabelle und Spott funktioniert bei ihnen nicht. Sie greiffen das ausgewählte Ziel nur auf Befehl an und das auch ohne Bedrohungstabelle.

Wenn ein Spielerbegleiter dazu aufgefordert wird, zu |cffffff78Folgen|r, wird die Bedrohungstabelle gelöscht und es hört auf anzugreiffen, dennoch kann es sofort wieder ein neues Ziel aufnehmen, wenn wieder in den Aggressiven/Defensiven Modus gewechselt wird.
]]
L["Autocollapse"] = "Automatisches Zusammenklappen"
L["Autocollapse Options"] = "Optionen für das automatische Zusammenklappen"
L["Grow bars upwards"] = "Balken nach oben aufbauen"
L["Hide Omen on 0 bars"] = "Omen ausblenden wenn keine Balken vorhanden sind"
L["Hide Omen entirely if it collapses to show 0 bars"] = "Omen komplett ausblenden wenn es zusammenklappt um 0 Balken anzuzeigen"
L["Max bars to show"] = "Maximale Anzahl an Balken"
L["Max number of bars to show"] = "Anzahl der Balken die maximal angezeigt werden"
L["Background Options"] = "Optionen für den Hintergrund"
L["Background Texture"] = "Hintergrundtextur"
L["Texture to use for the frame's background"] = "Textur die für den Hintergrund des Fensters genutzt werden soll"
L["Border Texture"] = "Randtextur"
L["Texture to use for the frame's border"] = "Textur die für den Rand des Fensters genutzt werden soll"
L["Background Color"] = "Hintergrundfarbe"
L["Frame's background color"] = "Farbe die für den Hintergrund des Fensters genutzt werden soll"
L["Border Color"] = "Randfarbe"
L["Frame's border color"] = "Farbe die für den Rand des Fensters genutzt werden soll"
L["Tile Background"] = "Hintergrundkacheln"
L["Tile the background texture"] = "Textur für den Hintergrund in Kacheln anzeigen"
L["Background Tile Size"] = "Größe der Kacheln des Hintergrundes"
L["The size used to tile the background texture"] = "Die Größe der Kacheln die für die Hintergrundtextur benutzt wird"
L["Border Thickness"] = "Dicke des Randes"
L["The thickness of the border"] = "Die Dicke des Randes"
L["Bar Inset"] = "Balkeneinfügung"
L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"] = "Legt fest, wie weit innerhalb des Fensters die Bedrohungsbalken von den vier Rändern des Fensters entfernt sind"

-- Config strings, title bar section
L["Title Bar Settings"] = "Optionen für die Titelleiste"
L["Configure title bar settings."] = "Einstellungen für die Titelleiste ändern"
L["Show Title Bar"] = "Zeige Titelleiste"
L["Show the Omen Title Bar"] = "Zeige die Titelleiste von Omen an"
L["Title Bar Height"] = "Höhe der Titelleisten"
L["Height of the title bar. The minimum height allowed is twice the background border thickness."] = "Höhe der Titelleisten. Die minimal erlaubte Höhe ist doppelt so dick wie der Rand des Hintergrundfensters"
L["Title Text Options"] = "Optionen für den Titeltext"
L["The font that the title text will use"] = "Die Schriftart die der Titeltext verwenden wird"
L["The outline that the title text will use"] = "Die Kontur die der Titeltext verwenden wird"
L["The color of the title text"] = "Die Farbe die der Titeltext verwenden wird"
L["Control the font size of the title text"] = "Die Schriftgröße des Titeltextes ändern"

-- Config strings, show when... section
L["Show When..."] = "Zeige wenn..."
L["Show Omen when..."] = "Zeige Omen wenn..."
L["This section controls when Omen is automatically shown or hidden."] = "Dieser Bereicht kontrolliert ob Omen automatisch aus- oder eingeblendet wird"
L["Use Auto Show/Hide"] = "Automatisches Anzeigen/Verstecken verwenden"
L["Show Omen when any of the following are true"] = "Zeige Omen wenn ein beliebiges der folgenden wahr ist"
L["You have a pet"] = "Ich einen Begleiter habe"
L["Show Omen when you have a pet out"] = "Zeige Omen wenn ich einen Begleiter habe"
L["You are alone"] = "Ich alleine bin"
L["Show Omen when you are alone"] = "Zeige Omen wenn ich alleine bin"
L["You are in a party"] = "Ich in einer Gruppe bin"
L["Show Omen when you are in a 5-man party"] = "Zeige Omen wenn ich einer 5er Gruppe bin"
L["You are in a raid"] = "Ich in einem Schlachtzug bin"
L["Show Omen when you are in a raid"] = "Zeige Omen wenn ich in einer Schlachtzuggruppe bin"
L["However, hide Omen if any of the following are true (higher priority than the above)."] = "Verstecke Omen wenn folgende Bedingungen wahr sind (höhere Priorität als die oberen)."
L["You are resting"] = "Ich mich ausruhe"
L["Turning this on will cause Omen to hide whenever you are in a city or inn."] = "Wird diese Funktion aktiviert, wird Omen jedesmal wenn Sie sich in einer Stadt oder einem Gasthaus befinden, ausgeblendet"
L["You are in a battleground"] = "Ich in einem Schlachtfeld bin"
L["Turning this on will cause Omen to hide whenever you are in a battleground or arena."] = "Wird diese Funktion aktiviert, wird Omen jedesmal wenn Sie sich auf einem Schlachtfeld oder einer Arena befinden, ausgeblendet"
L["You are not in combat"] = "Sie befinden sich nicht im Kampf"
L["Turning this on will cause Omen to hide whenever you are not in combat."] = "Wenn Sie diese Option aktivieren wird Omen ausgeblendet, wenn Sie sich nicht im Kampf befinden"
L["AUTO_SHOW/HIDE_NOTE"] = "Anmerkung: Wenn Sie Omen manuell ein- oder ausblenden, wird es ein- oder ausgeblendet bleiben, egal welche Einstellungen Sie in den Anzeigen/Verstecken Einstellungen vorgenommen haben, bis Sie das nächste mal die Zone wechseln, eine(r) Gruppe verlassen/beitreten oder die Anzeigen/Verstecken Einstellungen ändern."

-- Config strings, show classes... section
L["Show Classes..."] = "Zeige Klassen..."
L["SHOW_CLASSES_DESC"] = "Zeite die Omen Bedrohungsbalken für folgende Klassen. Die Klassen hier betreffen jene Leute in Ihrer Gruppe/Schlachtzug nur mit Ausnahme der 'Nicht in der Gruppe' Option."
L["Show bars for these classes"] = "Zeige Balken für diese Klassen"
L["DEATHKNIGHT"] = "Todesritter"
L["DRUID"] = "Druide"
L["HUNTER"] = "Jäger"
L["MAGE"] = "Magier"
L["PALADIN"] = "Paladin"
L["PET"] = "Begleiter"
L["PRIEST"] = "Priester"
L["ROGUE"] = "Schurke"
L["SHAMAN"] = "Schamane"
L["WARLOCK"] = "Hexer"
L["WARRIOR"] = "Krieger"
L["*Not in Party*"] = "*Nicht in der Gruppe"

-- Config strings, bar settings section
L["Bar Settings"] = "Optionen für die Balken"
L["Configure bar settings."] = "Einstellungen für die Balken ändern"
L["Animate Bars"] = "Balken animieren"
L["Smoothly animate bar changes"] = "Flüssiges Animieren der Balkenänderungen"
L["Short Numbers"] = "Kurze Nummern"
L["Display large numbers in Ks"] = "Zeigt große Nummern im K-Format an"
L["Bar Texture"] = "Balktentextur"
L["The texture that the bar will use"] = "Diese Textur wird von den Balken genutzt"
L["Bar Height"] = "Balkenhöhe"
L["Height of each bar"] = "Höhe jedes Balkens"
L["Bar Spacing"] = "Abstand der Balken"
L["Spacing between each bar"] = "Abstand zwischen den Balken"
L["Show TPS"] = "Zeige BPS"
L["Show threat per second values"] = "Zeige Bedrohung pro Sekunde Werte"
L["TPS Window"] = "BPS Fenster"
L["TPS_WINDOW_DESC"] = "Die Bedrohung pro Sekunde Berechnung basiert auf einem in Echtzeit gestaffekteb Fenster der letzten X Sekunden"
L["Show Threat Values"] = "Zeige Bedrohungswerte"
L["Show Threat %"] = "Zeige % Bedrohung"
L["Show Headings"] = "Zeige Überschriften"
L["Show column headings"] = "Zeige die Überschriften der Spalten"
L["Heading BG Color"] = "Überschriftenhintergrundfarbe"
L["Heading background color"] = "Hintergrundfarbe der Überschriften"
L["Use 'My Bar' color"] = "Farbe des eigenen Balkens verwenden"
L["Use a different colored background for your threat bar in Omen"] = "Eine andere Hintergrundfarbe für den eigenen Bedrohungsbalken in Omen verwenden"
L["'My Bar' BG Color"] = "Hintergrundfarbe für den eigenen Balken"
L["The background color for your threat bar"] = "Die Hintergrundfarbe für den eigenen Bedrohungsbalken"
L["Use Tank Bar color"] = "Farbe des Tankbalkens verwenden"
L["Use a different colored background for the tank's threat bar in Omen"] = "Benutze eine andere Hintergrundfarbe für den Bedrohungsbalken des Tanks in Omen"
L["Tank Bar Color"] = "Farbe für den Tankbalken"
L["The background color for your tank's threat bar"] = "Die Hintergrundfarbe des Bedrohungsbalkens des Tanks"
L["Show Pull Aggro Bar"] = "'Aggro ziehen' Leiste anzeigen"
L["Show a bar for the amount of threat you will need to reach in order to pull aggro."] = "Zeigt eine Leiste mit dem Wert an Bedrohung der benötigt wird um Aggro zu ziehen"
L["Pull Aggro Bar Color"] = "Farbe der 'Aggro ziehen' Leiste"
L["The background color for your Pull Aggro bar"] = "Die Hintergrundfarbe für die 'Aggro ziehen' Leiste"
L["Use Class Colors"] = "Klassenfarben benutzen"
L["Use standard class colors for the background color of threat bars"] = "Benutze die Standard Klassenfarben für den Hintergrund der Bedrohungsbalken"
L["Pet Bar Color"] = "Begleiterleistenfarbe"
L["The background color for pets"] = "Die Hintergrundfarbe für Begleiter"
L["Bar BG Color"] = "Balkenhintergrundfarbe"
L["The background color for all threat bars"] = "Die Hintergrundfarbe für alle Bedrohungsbalken"
L["Always Show Self"] = "Selbst immer anzeigen"
L["Always show your threat bar on Omen (ignores class filter settings), showing your bar on the last row if necessary"] = "Zeige immer den eigenen Bedrohungsbalken an (ignoriert Klassenfilter), in der letzten Reihe, wenn nötig."
L["Bar Label Options"] = "Optionen für die Beschriftung der Balken"
L["Font"] = "Schriftart"
L["The font that the labels will use"] = "Die Schriftart die die Balken benutzen"
L["Font Size"] = "Schriftgröße"
L["Control the font size of the labels"] = "Die Schriftgröße der Balken ändern"
L["Font Color"] = "Schriftfarbe"
L["The color of the labels"] = "Die Schriftfarbe der Beschriftungen"
L["Font Outline"] = "Schriftkontur"
L["The outline that the labels will use"] = "Die Kontur der Beschriftungen"
L["None"] = "Keine"
L["Outline"] = "Kontur"
L["Thick Outline"] = "Dicke Kontur"

-- Config strings, slash command section
L["OMEN_SLASH_DESC"] = "Die Knöpfe machen das selbe wie die Slashkommandos beim Befehl /omen"
L["Toggle Omen"] = "Omen ein/ausblenden"
L["Center Omen"] = "Omen zentrieren"
L["Configure"] = "Einstellen"
L["Open the configuration dialog"] = "Den Konfigurationsdialog öffnen"

-- Config strings, warning settings section
L["Warning Settings"] = "Optionen für die Warnungen"
L["OMEN_WARNINGS_DESC"] = "Dieser Bereich erlaubt ihnen einzustellwen wann und wie sie Omen benachrichtigt wenn Sie kurz davor sind Aggro zu ziehen"
L["Enable Sound"] = "Ton aktivieren"
L["Causes Omen to play a chosen sound effect"] = "Lässt Omen einen ausgewählen Ton abspielen"
L["Enable Screen Flash"] = "Bildschirmblinken aktivieren"
L["Causes the entire screen to flash red momentarily"] = "Lässt den gesamten Bildschirm kurzzeitig rot leuchten"
L["Enable Screen Shake"] = "Bildschirmwackeln aktivieren"
L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."] = "Lässt die Spielwelt für einen kurzen Moment beben. Diese Option funktioniert nur wenn Namenschilder deaktiviert sind"
L["Enable Warning Message"] = "Warnmeldungen aktivieren"
L["Print a message to screen when you accumulate too much threat"] = "Zeigt eine Meldung auf dem Bildschirm wenn Sie zu viel Bedrohung erzeugen"
L["Warning Threshold %"] = "Warnschwelle %"
L["Sound to play"] = "Ton der gespielt wird"
L["Disable while tanking"] = "Beim Tanken deaktivieren"
L["DISABLE_WHILE_TANKING_DESC"] = "Gibt keine Warnmeldungen aus wenn Verteidigungshaltung, Bärengestalt, Zorn der Gerechtigkeit oder Frost Präsenz aktiv sind."
L["Test warnings"] = "Testwarnung"

-- Config strings, for Fubar
L["Click|r to toggle the Omen window"] = "Klicken|r um das Omen Fenster ein/auszublenden"
L["Right-click|r to open the options menu"] = "Rechts-klicken|r um das Optionsfenster zu öffnen"
L["FuBar Options"] = "FuBar Optionen"
L["Attach to minimap"] = "An der Minimap anbringen"
L["Hide minimap/FuBar icon"] = "Minimapsymbol anzeigen/verstecken"
L["Show icon"] = "Symbol zeigen"
L["Show text"] = "Text zeigen"
L["Position"] = "Position"
L["Left"] = "Links"
L["Center"] = "Mitte"
L["Right"] = "Rechts"

-- FAQ
L["Help File"] = "Hilfe"
L["A collection of help pages"] = "Eine Sammlung von Hilfestellungen"
L["FAQ Part 1"] = "Häufig gestellte Fragen - 1"
L["FAQ Part 2"] = "Häufig gestellte Fragen - 2"
L["Frequently Asked Questions"] = "Häufig gestellte Fragen"
L["Warrior"] = "Krieger"

L["GENERAL_FAQ"] = [[
|cffffd200Was unterscheidet Omen3 von Omen2?|r

Omen3 verlässt sich komplett auf die Blizzard Bedrohungs API und Bedrohungs Events. Es versucht nicht Bedrohung zu berechnen oder hochzurechnen wie es Omen2 tat.

Omen2 hat die sogenannte Threat-2.0 Library benutzt. Diese Library war verantwortlich für die Überwachung des Kampflogs, das Wirken von Zaubern, Buffs, Debuffs, Haltungen, Talente und Modifikatoren auf Ausrüstungen um die Bedrohung jedes Einzelnen zu berechnen. Bedrohung wurde auf Grund von Vermutungen und Annahmen berechnet, die durch Beobachtungen entstanden sind. Viele Fähigkeiten wie z.b Knockbacks wurden nur angenommen(als 50% Bedrohungsreduzierung) da es meist unmöglich war, sie zu bestätigen.

Die Threat-2.0 Library enthielt auch ein Kommunikationssystem um Ihre Bedrohung an den Rest der Schlachtgruppe zu senden, solange dieser auch Threat-2.0 benutzen. Diese Daten wurden dann dazu genutzt einen Schlachtzugsweiten Überblick der Bedrohungssituation darzustellen.

Seit dem Patch 3.0.2, macht Omen keines dieser Dinge mehr und eine Thread Library ist nicht länger notwendig. Omen3 nutzt Blizzards neuen, eingebauten, Bedrohungsmonitor um exakte Werte für die Bedrohung jedes Mitglieds zu empfangen. Dies bedeutet, Omen muss nicht länger mit anderen Mitspielern Daten synchronisieren, den Kampflog auslesen oder raten. Dies resultiert in einer viel besseren Geschwindigkeit im Bezug auf Netzwerkauslastung, CPU-Zeit und RAM-Verbrauch. Die Implementierung von Bossmodulen für spezielle Ereignisse (wie das Zurücksetzen der Bedrohung bei der Landung des Schreckens der Nacht) ist nicht länger notwendig.

Ein weiterer Vorteil dieser Implementierung ist die Anzeige der Bedrohung von NPCs (z.B. die menschliche Form von Kalecgos). Auch gebt es einige Nachteile; Die Frequenz der Aktualisierungen ist viel geringer, Bedrohung kann nur erfasst werden wenn jemand in Ihrer Gruppe den Mob im Ziel hat und sich im direkten Kampf mit diesem Monster befindet.

|cffffd200Wie werde ich die zwei vertikalen Linien in der Mitte los?|r

Verankern Sie ihr Omen. Wird Omen an der aktuellen Position verankert, kann es weder verschoben noch größenverändert werden, auch verhindert dies, dass Spalten in der Größe verändert werden. Falls es Ihnen nicht klar wurde, die zwei vertikalen Linien sind zum Verändern der Spaltenbreite.

|cffffd200Wie lasse ich Omen3 wie Omen2 aussehen?|r

Ändern Sie sowohl die Hintergrundtextur als auch die Randtextur auf Blizzard Tooltip, ändern Sie die Hintergrundfarbe auf schwarz (indem Sie den Sichtbarkeitsbalken ganz nach unten ziehen) und die Randfarbe auf blau.

|cffffd200Warum wird nichts angezeigt obwohl ich einen Monster im Ziel habe, welches sich im Kampf befindet?|r

Die Blizzard Threat API gibt keine Bedrohungsdaten zurück wenn Sie nicht im direkten Kampf mit diesem Monster sind. Wir denken dies ist ein Versuch von Blizzard den Netzwerkverkehr zu reduzieren.

|cffffd200Is there ANY way around this Blizzard limitation? Not being able to see my pet's threat before I attack has set me back to guessing.|r

There is no way around this limitation short of us doing the guessing for you (which is exactly how Omen2 did it).

The goal of Omen3 is to provide accurate threat data, we no longer intend to guess for you and in the process lower your FPS. Have some confidence in your pet/tank, or just wait 2 seconds before attacking and use a low damage spell such as Ice Lance so that you can get initial threat readings.
]]
L["GENERAL_FAQ2"] = [[
|cffffd200Können wir den AoE Modus wieder haben?|r

Wieder einmal ist dies nicht möglich ohne Bedrohungswerte zu raten. Blizzards Bedrohungs API erlaubt es uns nur für Einheiten die eine Person im Schlachtzug als Ziel hat zu empfangen. Das bedeutet, wenn es 20 Mobs gibt, und nur 6 davon bei Schlachtzugsmitgliedern im Ziel sind, es keinen Weg gibt um genaue Bedrohungswerte der anderen 14 zu empfangen.

Es ist auch sehr schwierig zu raten, gerade bei Heilung und Buffs (Bedrohung wird durch die Anzahl an Mobs geteilt mit denen Sie sich im Kampf befinden), da Mobs die sich unter Crowd Control Effekten (Schaf, Verbannung, Kopfnuss, usw) befinden, keine veränderte Bedrohungstabelle besitzen und Addons nicht zuverlässig sagen können mit vielen Mobs Sie sich im Kampf befinden. Der von Omen2 geratene Wert war meistens falsch.

|cffffd200Die Tooltips einer Einheit zeigt die Bedrohung in % an die nicht den % entspricht, die Omen3 anzeigt. Warum?|r

Blizzards Bedrohungsprozentuale scaliert zwischen 0% und 100%, so dass man immer bei 100% Aggro zieht. Omen zeigt Rohwerte an, die nicht skaliert sind und bei denen man bei 110% Aggro zieht, wenn man sich in Nahkampfreichweite befindet und bei 130% wenn nicht.

Nach allgemeinem Einverständnis, wird das Hauptziel eines Mobs als Tank bezeichnet und hat 100% Bedrohung.

|cffffd200Synchronisiert Omen3 oder holt Daten aus dem Kampflog?|r

Nein. Omen3 versucht nicht Daten mit anderen Spielern abzugleichen oder aus dem Kampflog zu ziehen. Momentan ist es nicht geplant dies zu tun.

|cffffd200Die Aktualisierungsrate der Bedrohung ist langsam...|r

Omen3 aktualisiert so oft die Bedrohungswerte wie Blizzard es zulässt.

In der Tat aktualisiert sie Blizzard etwa einmal pro Sekunde, was sogar viel schneller ist, als Omen2 es getan hat. In Omen2, wurde Ihre Bedrohung nur etwa alle 3 Sekunden an den Rest des Schlachtzuges gesendet (als Tank alle  1.5s).

|cffffd200Wo kann ich Fehler melden oder Vorschläge machen?|r

http://forums.wowace.com/showthread.php?t=14249

|cffffd200Wer hat Omen3 geschrieben?|r

Xinhuan (Blackrock US Alliance).

|cffffd200Sind Spenden via Paypal möglich?|r

Ja, schicken Sie sie an xinhuan AT gmail DOT com.
]]
L["WARRIOR_FAQ"] = [[Die folgenden Daten stammen von |cffffd200http://www.tankspot.com/forums/f200/39775-wow-3-0-threat-values.html|r am zweiten Okt. 2008 (Danke an Satrina!). Die Zahlen sind für Level 80.

|cffffd200Modifiers|r
Battle Stance ________ x 80
Berserker Stance _____ x 80
Tactical Mastery _____ x 121/142/163
Defensive Stance _____ x 207.35

Note that in our original threat estimations (that we use now in WoW 2.0), we equated 1 damage to 1 threat, and used 1.495 to represent the stance+defiance multiplier. We see Note that in our original threat estimations (that we use now in WoW 2.0), we equated 1 damage to 1 threat, and used 1.495 to represent the stance+defiance multiplier. We see that Blizzard's method is to use the multiplier without decimals, so in 2.x it would've been x149 (maybe x149.5); it is x207 (maybe 207.3) in 3.0. I expect that this is to allow the transport of integer values instead of decimal values across the Internet for efficiency. It appears that threat values are multiplied by 207.35 at the server, then rounded.

If you still want to use the 1 damage = 1 threat method, the stance modifiers are 0.8 and 2.0735, etc.

|cffffd200Threat Values  (stance modifiers apply unless otherwise noted):|r
Battle Shout _________ 78 (split)
Cleave _______________ damage + 225 (split)
Commanding Shout _____ 80 (split)
Concussion Blow ______ damage only
Damage Shield ________ damage only
Demoralising Shout ___ 63 (split)
Devastate ____________ damage + 5% of AP *** Needs re-checking for 8982 **
Dodge/Parry/Block_____ 1 (in defensive stance with Improved Defensive Stance only)
Heroic Strike ________ damage + 259
Heroic Throw _________ 1.50 x damage
Rage Gain ____________ 5 (stance modifier is not applied)
Rend _________________ damage only
Revenge ______________ damage + 121
Shield Bash __________ 36
Shield Slam __________ damage + 770
Shockwave ____________ damage only
Slam _________________ damage + 140
Spell Reflect ________ damage only (only for spells aimed at you)
Social Aggro _________ 0
Sunder Armour ________ 345 + 5%AP
Thunder Clap _________ 1.85 x damage
Vigilance ____________ 10% of target's generated threat (stance modifier is not applied)

You do not gain threat for reflecting spells targetted at allies with Improved Spell Reflect. When you reflect a spell for an ally, your ally gains the threat for the damage dealt by the reflected spell.
]]

