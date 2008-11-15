--[[
	WARNING: This is a generated file.
	If you wish to perform or update localizations, please go to our Localizer website at:
	http://localizer.norganna.org/

	AddOn: Auctioneer
	Revision: $Id$
	Version: 5.1.3824 (SnaggleTooth)

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

AuctioneerLocalizations = {

	deDE = {

		-- Section: Help Text
		["AHWC_Help_AuctionHouseScale"]	= "Auktionsfenstergröße?";
		["AHWC_Help_AuctionHouseScaleAnswer"]	= "Der Auktionsschieberegler verändert die Größe des gesamten Auktionshausfensters. Standard ist 1";
		["AHWC_Help_CompactUIFontScale"]	= "KompaktUI Schriftgröße";
		["AHWC_Help_CompactUIFontScaleAnswer"]	= "Der KompaktUI Schriftenschieberegler verändert die Textgröße die in der KompaktUI Ansichtsbildlaufleiste angezeigt wird. Standard ist 0";
		["AHWC_Help_ProtectWindow"]	= "Was bewirkt der Schutz des AH Fensters?";
		["AHWC_Help_ProtectWindowAnswer"]	= "Das Auktionsfenster schließt sich normalerweise wenn Du andere Fenster öffnest, wie z.B. das Geselligkeitsfenster, Questlog oder Berufefenster. Diese Option erlaubt es das Fenster hinter den anderen geöffnet zu halten.";
		["AHWC_Help_RemberLastPosition"]	= "Letzte Fensterposition merken";
		["AHWC_Help_RemberLastPositionAnswer"]	= "Ist diese Option aktiviert, wird sich das Auktionsfenster an der zuletzt gemerkten Stelle wieder öffnen";
		["AHWC_Help_SearchUIScale"]	= "SuchUI Größe";
		["AHWC_Help_SearchUIScaleAnswer"]	= "Der SuchUI Schieberegler verändert die allgemeine Größe des Nicht-Auktions-SuchUI Fensters. Standard ist 1";
		["AHWC_Help_whatisthis"]	= "Was für ein Hilfsmittel ist das?";
		["AHWC_Help_whatisthisAnswer"]	= "Dieses Hilfsmittel erlaubt euch das Auktionsfenster zu ziehen und für diese Spielzeit an eine andere Stelle zu bewegen. Nutzt diese Option und bewegt das Fenster wohin Ihr es möchtet. Ebenfalls wird dann das Auktionsfenster nicht mehr geschlossen, wenn Ihr andere Fenster öffnet.";
		["SIMP_Help_SimpleStats"]	= "Was ist Simple Stats";
		["SIMP_Help_SlashHelp1"]	= "Hilfe für Auctioneer Advance Simple";
		["SIMP_Help_SlashHelp2"]	= "Das ist die Hilfe für das Modul Simple";
		["SIMP_Help_SlashHelp3"]	= "lösche aktuelle Simple Preis Datenbank";
		["SIMP_Help_SlashHelp4"]	= "Erzwinge eine Archivierung der %s Simple täglichen Statistiken (Beginne neuen Tag)";
		["SIMP_Help_SlashHelp5"]	= "Lösche die Simple Statistik für";
		["SIMP_Help_SlashHelp6"]	= "Archiviere {{%s}} tägliche Statistiken und beginne einen neuen Tag";
		["SIMP_Help_SlashHelpClearingData"]	= "%s - Simple: Lösche die Daten für %s für {{%s}}";

		-- Section: HelpTooltip
		["AHWC_HelpTooltip_AllowMovable"]	= "Diese Option aktivieren um das Auktionsfenster zu bewegen.";
		["AHWC_HelpToolTip_AuctionHouseScale"]	= "Diese Option erlaubt es die allgemeine Größe des Auktionsfensters zu verändern. Standard ist 1";
		["AHWC_HelpTooltip_CompactUIFontScale"]	= "Diese Option verändert die Größe der in der Bildlaufleiste angezeigten Schrift. Standard ist 0";
		["AHWC_HelpToolTip_PreventClosingAuctionHouse"]	= "Diese Option verhindert das Schliessen des Auktionsfensters wenn andere Fenster geöffnet werden, entsprechend euer Einstellung.";
		["AHWC_HelpToolTip_ProtectProcessing"]	= "Diese Option aktivieren um den erweiterten Schutz nach Ende des Scanns, bis alle Prozesse abgeschlossen sind, einzuschalten.";
		["AHWC_HelpToolTip_RemberLastPosition"]	= "Wenn diese Option angewählt ist wird sich das Auktionsfenster wieder da öffnen, wo es zuletzt platziert wurde.";
		["AHWC_HelpTooltip_SearchUIScale"]	= "Diese Option erlaubt euch die allgemeine Größe des Nicht-Auktions-SuchUI zu verändern. Standard ist 1";

		-- Section: Interface
		["AHWC_Interface_AllowMovable"]	= "Erlaubt es das Auktionsfenster zu bewegen.";
		["AHWC_Interface_Always"]	= "immer";
		["AHWC_Interface_AuctionHouseScale"]	= "Auktionsfenstergröße";
		["AHWC_Interface_CompactUIFontScale"]	= "CompactUI Schriftgröße";
		["AHWC_Interface_Never"]	= "nie";
		["AHWC_Interface_PreventClosingAuctionHouse"]	= "Auktionsfenster wird offen gehalten wenn andere Fenster genutzt werden.";
		["AHWC_Interface_ProtectAuctionWindow"]	= "Schützt das Auktionsfenster";
		["AHWC_Interface_ProtectProcessing"]	= "Aktiviere diese Option um das Fenster offen zu halten solange eine Aufgabe erledigt wird.";
		["AHWC_Interface_RemberLastPosition"]	= "Soll die letzte Position gespeichert werden?";
		["AHWC_Interface_Scanning"]	= "Wenn gescannt wird";
		["AHWC_Interface_SearchUIScale"]	= "Größe der SuchUI";
		["AHWC_Interface_WindowMovementOptions"]	= "Fensterbewegungsoptionen";
		["AHWC_Interface_WindowProtectionOptions"]	= "Fensterschutzoptionen";
		["AHWC_Interface_WindowSizeOptions"]	= "Fenstergrößenoptionen";
		["SIMP_Interface_EnableSimpleStats"]	= "Simple Stats einschalten";

	};

	enUS = {

		-- Section: Help Text
		["AHWC_Help_AuctionHouseScale"]	= "Auction House Scale?";
		["AHWC_Help_AuctionHouseScaleAnswer"]	= "The Auction House scale slider adjusts the overall size of the entire Auction House window. The default size is 1.";
		["AHWC_Help_CompactUIFontScale"]	= "CompactUI Font Scale?";
		["AHWC_Help_CompactUIFontScaleAnswer"]	= "The CompactUI Font Scale slider adjusts the text size displayed in AucAdvance CompactUI option in the Browse Tab. The default size is 0.";
		["AHWC_Help_ProtectWindow"]	= "What does Protecting the AH Window do?";
		["AHWC_Help_ProtectWindowAnswer"]	= "The Auction House window is normally closed when you open other windows, such as the Social window, the Quest Log, or your profession windows. This option allows it to remain open, behind those other windows.";
		["AHWC_Help_RemberLastPosition"]	= "Remember last known window position?";
		["AHWC_Help_RemberLastPositionAnswer"]	= "If this box is checked, the auction frame will reopen in the last location it was moved to.";
		["AHWC_Help_SearchUIScale"]	= "SearchUI Scale?";
		["AHWC_Help_SearchUIScaleAnswer"]	= "The SearchUI scale slider adjusts the overall size of the non auction house SearchUI window. The default size is 1.";
		["AHWC_Help_whatisthis"]	= "What is this utility?";
		["AHWC_Help_whatisthisAnswer"]	= "This utility allows you to drag and relocate the auction frame for this play session. Just click and move where you desire. It also allows you to protect the Auction House from closing when opening certain Blizzard windows.";
		["SDEV_Help_Confidence"]	= "What does confidence mean?";
		["SDEV_Help_ConfidenceAnswer"]	= "Confidence is a value between 0 and 1 that determines the strength of the calculations (higher the better).";
		["SDEV_Help_Filtered"]	= "What do you mean filtered?";
		["SDEV_Help_FilteredAnswer"]	= "Items outside a (1.5*Standard) variance are ignored and assumed to be wrongly priced when calculating the deviation.";
		["SDEV_Help_Normalized"]	= "What is the Normalized calculation?";
		["SDEV_Help_NormalizedAnswer"]	= "In short terms again, it is the average of those values determined within the standard deviation variance calculation.";
		["SDEV_Help_SlashHelp1"]	= "Help for Auctioneer Advanced - StdDev";
		["SDEV_Help_SlashHelp2"]	= "this StdDev help";
		["SDEV_Help_SlashHelp3"]	= "clear current %s StdDev price database";
		["SDEV_Help_SlashHelp4"]	= "Clearing StdDev stats for";
		["SDEV_Help_StandardDeviationCalculation"]	= "What is a Standard Deviation calculation?";
		["SDEV_Help_StandardDeviationCalculationAnswer"]	= "In short terms, it is a distance to mean average calculation.";
		["SDEV_Help_StdDevStats"]	= "What are StdDev stats?";
		["SDEV_Help_StdDevStatsAnswer"]	= "StdDev stats are the numbers that are generated by the StdDev module consisting of a filtered Standard Deviation calculation of item cost.";
		["SDEV_Help_WhyMultiplyStack"]	= "Why have the option to multiply by stack size?";
		["SDEV_Help_WhyMultiplyStackAnswer"]	= "The original Stat-StdDev multiplied by the stack size of the item, but some like dealing on a per-item basis.";
		["SIMP_Help_AverageMinimumBuyout"]	= "What's the point in an average minimum buyout?";
		["SIMP_Help_AverageMinimumBuyoutAnswer"]	= "This way you know how good a market is dealing. If the MBO (minimum buyout) is bigger than the average MBO, then it's usually a good time to sell, and if the average MBO is greater than the MBO, then it's a good time to buy.";
		["SIMP_Help_HowAveragesCalculated"]	= "How is the moving day averages calculated exactly?";
		["SIMP_Help_HowAveragesCalculatedAnswer"]	= "Todays Moving Average is ((X-1)*YesterdaysMovingAverage + TodaysAverage) / X, where X is the number of days (3,7, or 14).";
		["SIMP_Help_MinimumBuyout"]	= "Why do I need to know minimum buyout?";
		["SIMP_Help_MinimumBuyoutAnswer"]	= "While some items will sell very well at average within 2 days, others may sell only if it is the lowest price listed. This was an easy calculation to do, so it was put in this module.";
		["SIMP_Help_MinimumBuyoutVariance"]	= "What's the '10% variance' mentioned earlier for?";
		["SIMP_Help_MinimumBuyoutVarianceAnswer"]	= "If the current MBO is inside a 10% range of the running average, the current MBO is averaged in to the running average at 50% (normal). If the current MBO is outside the 10% range, the current MBO will only be averaged in at a 12.5% rate.";
		["SIMP_Help_MovingAverage"]	= "What does 'moving day average' mean?";
		["SIMP_Help_MovingAverageAnswer"]	= "Moving average means that it places more value on yesterday's moving averagethan today's average. The determined amount is then used for tomorrow's moving average calculation.";
		["SIMP_Help_NoDaySaved"]	= "So you aren't saving a day-to-day average?";
		["SIMP_Help_NoDaySavedAnswer"]	= "No, that would not only take up space, but heavy calculations on each auction house scan, and this is only a simple model.";
		["SIMP_Help_SimpleStats"]	= "What are simple stats?";
		["SIMP_Help_SimpleStatsAnswer"]	= "Simple stats are the numbers that are generated by the Simple module, the Simple module averages all of the prices for items that it sees and provides moving 3, 7, and 14 day averages.  It also provides daily minimum buyout along with a running average minimum buyout within 10% variance.";
		["SIMP_Help_SlashHelp1"]	= "Help for Auctioneer Advanced - Simple";
		["SIMP_Help_SlashHelp2"]	= "this Simple help";
		["SIMP_Help_SlashHelp3"]	= "clear current %s Simple price database";
		["SIMP_Help_SlashHelp4"]	= "force the %s Simple daily stats to archive (start a new day)";
		["SIMP_Help_SlashHelp5"]	= "Clearing Simple stats for";
		["SIMP_Help_SlashHelp6"]	= "Archiving {{%s}} daily stats and starting a new day";
		["SIMP_Help_SlashHelpClearingData"]	= "%s - Simple: clearing data for %s for {{%s}}";
		["SIMP_Help_WhyMultiplyStack"]	= "Why have the option to multiply stack size?";
		["SIMP_Help_WhyMultiplyStackAnswer"]	= "The original Stat-Simple multiplied by the stack size of the item, but some like dealing on a per-item basis.";
		["SIMP_Help_WhyVariance"]	= "What's the point of a variance on minimum buyout?";
		["SIMP_Help_WhyVarianceAnswer"]	= "Because some people put their items on the market for rediculous price (too low or too high), so this helps keep the average from getting out of hand.";

		-- Section: HelpTooltip
		["AHWC_HelpTooltip_AllowMovable"]	= "Ticking this box will enable the ability to relocate the auction frame";
		["AHWC_HelpToolTip_AuctionHouseScale"]	= "This option allows you to adjust the overall size of the Auction House window. Default is 1.";
		["AHWC_HelpTooltip_CompactUIFontScale"]	= "This option allows you to adjust the text size of the CompactUI on the Browse tab. The default size is 0.";
		["AHWC_HelpToolTip_PreventClosingAuctionHouse"]	= "This will prevent other windows from closing the Auction House window when you open them, according to your settings";
		["AHWC_HelpToolTip_ProtectProcessing"]	= "This option allows you to extend protection from the end of the scan until processing is done.";
		["AHWC_HelpToolTip_RemberLastPosition"]	= "If this box is checked, the auction frame will reopen in the last location it was moved to.";
		["AHWC_HelpTooltip_SearchUIScale"]	= "This option allows you to adjust the overall size of the non auction house SearchUI window. The default size is 1.";
		["SDEV_HelpTooltip_DisplayConfidence"]	= "Toggle display of 'Confidence' calculation in tooltips on or off";
		["SDEV_HelpTooltip_DisplayMean"]	= "Toggle display of 'Mean' calculation in tooltips on or off";
		["SDEV_HelpTooltip_DisplayNormalized"]	= "Display Standard Deviation";
		["SDEV_HelpTooltip_DisplayStandardDeviation"]	= "Toggle display of 'Standard Deviation' calculation in tooltips on or off";
		["SDEV_HelpTooltip_EnableStdDevStats"]	= "Allow StdDev to gather and return price data";
		["SDEV_HelpTooltip_MultiplyStack"]	= "Multiplies by current stack size if on";
		["SDEV_HelpTooltip_Show"]	= "Toggle display of stats from the StdDev module on or off";
		["SIMP_HelpTooltip_EnableSimpleStats"]	= "Allow Simple Stats to gather and return price data";
		["SIMP_HelpTooltip_LongerAverage"]	= "Returns longer averages (7-day, or even 14-day) for low-volume items";
		["SIMP_HelpTooltip_MinBuyout"]	= "Toggle display of Minimum Buyout from the Simple module on or off";
		["SIMP_HelpTooltip_MinBuyoutAverage"]	= "Toggle display of Minimum Buyout average from the Simple module on or off";
		["SIMP_HelpTooltip_MultiplyStack"]	= "Multiplies by current stack size if on";
		["SIMP_HelpTooltip_Show"]	= "Toggle display of stats from the Simple module on or off";
		["SIMP_HelpTooltip_Toggle14Day"]	= "Toggle display of 14-Day average from the Simple module on or off";
		["SIMP_HelpTooltip_Toggle3Day"]	= "Toggle display of 3-Day average from the Simple module on or off";
		["SIMP_HelpTooltip_Toggle7Day"]	= "Toggle display of 7-Day average from the Simple module on or off";

		-- Section: Interface
		["AHWC_Interface_AllowMovable"]	= "Allow the auction frame to be movable";
		["AHWC_Interface_Always"]	= "Always";
		["AHWC_Interface_AuctionHouseScale"]	= "Auction House Scale";
		["AHWC_Interface_CompactUIFontScale"]	= "CompactUI Font Scale";
		["AHWC_Interface_Never"]	= "Never";
		["AHWC_Interface_PreventClosingAuctionHouse"]	= "Prevent other windows from closing the Auction House window.";
		["AHWC_Interface_ProtectAuctionWindow"]	= "Protect the Auction House window:";
		["AHWC_Interface_ProtectProcessing"]	= "Check this to protect the window until processing is done.";
		["AHWC_Interface_RemberLastPosition"]	= "Remember last known window position?";
		["AHWC_Interface_Scanning"]	= "When Scanning";
		["AHWC_Interface_SearchUIScale"]	= "SearchUI Scale";
		["AHWC_Interface_WindowMovementOptions"]	= "Window Movement Options";
		["AHWC_Interface_WindowProtectionOptions"]	= "Window Protection Options";
		["AHWC_Interface_WindowSizeOptions"]	= "Window Size Options";
		["SDEV_Interface_ClearingData"]	= "StdDev: clearing data for %s for {{%s\"}}";
		["SDEV_Interface_DisplayConfidence"]	= "Display Confidence";
		["SDEV_Interface_DisplayMean"]	= "Display Mean";
		["SDEV_Interface_DisplayNormalized"]	= "Display Normalized";
		["SDEV_Interface_DisplayStandardDeviation"]	= "Display Standard Deviation";
		["SDEV_Interface_EnableStdDevStats"]	= "Enable StdDev Stats";
		["SDEV_Interface_MultiplyStack"]	= "Multiply by Stack Size";
		["SDEV_Interface_Show"]	= "Show stddev stats in the tooltips?";
		["SDEV_Interface_StdDevOptions"]	= "StdDev options";
		["SIMP_Interface_ClearingSimple"]	= "Clearing Simple stats for";
		["SIMP_Interface_ClearingSimpleStats"]	= "Clearing Simple stats for {{%s}} on {{%s}}";
		["SIMP_Interface_EnableSimpleStats"]	= "Enable Simple Stats";
		["SIMP_Interface_LongerAverage"]	= "Report safer prices for low volume items";
		["SIMP_Interface_MinBuyout"]	= "Display Daily Minimum Buyout";
		["SIMP_Interface_MinBuyoutAverage"]	= "Display Average of Daily Minimum Buyouts";
		["SIMP_Interface_MultiplyStack"]	= "Multiply by stack size";
		["SIMP_Interface_SeenCount"]	= "Seen |cffddeeff %d%s today %s";
		["SIMP_Interface_Show"]	= "Show simple stats in the tooltips?";
		["SIMP_Interface_SimpleOptions"]	= "Simple Options";
		["SIMP_Interface_Toggle14Day"]	= "Display Moving 14 Day Average";
		["SIMP_Interface_Toggle3Day"]	= "Display Moving 3 Day Average";
		["SIMP_Interface_Toggle7Day"]	= "Display Moving 7 Day Average";

		-- Section: Tooltip
		["SDEV_Tooltip_Confidence"]	= "Confidence: ";
		["SDEV_Tooltip_Individually"]	= "(or individually)";
		["SDEV_Tooltip_MeanPrice"]	= "Mean price";
		["SDEV_Tooltip_Normalized"]	= "Normalized";
		["SDEV_Tooltip_PricesPoints"]	= "StdDev prices {{%d}} points:";
		["SDEV_Tooltip_StdDeviation"]	= "Std Deviation";
		["SIMP_Tooltip_14DayAverage"]	= "14 day average";
		["SIMP_Tooltip_3DayAverage"]	= "3 day average";
		["SIMP_Tooltip_7DayAverage"]	= "7 day average";
		["SIMP_Tooltip_AverageMBO"]	= "Average MBO";
		["SIMP_Tooltip_SeenNumberDays"]	= "Seen %s%s%s over %s%s%s days:";
		["SIMP_Tooltip_SeenToday"]	= "Seen %s%s%s today:";
		["SIMP_Tooltip_SimplePrices"]	= "Simple prices:";
		["SIMP_Tooltip_TodaysMBO"]	= "Today's Min BO";

	};

}