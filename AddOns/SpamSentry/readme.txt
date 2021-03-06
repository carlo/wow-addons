SpamSentry by Anea

This addon puts an end to the goldspam in your chatwindows. To detect spam, SpamSentry uses sophistacted heuristics that have been developed over the course of nearly two years. It also enables you to report spammers using an intuitive one-click report system. Regular updates and an outstanding reputation make SpamSentry your number one spam blocker! Or at least, so I hope ;)

---
Version 20081027
- Fixed the missing texts in the report pane
- Fixed issue with the Social Pane / Guild Pane behaving odd (bug in WhoLib)
- Fixed issue with Titan Panel
---

Installation: 
* Unzip the file into your 'Interface/Addons' folder. 

Features:
* Detects multi-message spam
* Customizable notification
* FuBar and Titan support
* Support for Whisp, Chatter, Wim and other messaging addons.
* Manual reporting of players you suspect to be a goldseller / bot / violating naming rules
* Report-button in mailframe to report spam send to you by in-game mail
* Seperate reportlists are maintained for each realm you play on
* And many more

Use: 
* Left click the minimap/fubar/titan icon to show a listing of to-be-reported characters
* Type /sentry or right-click the icon for options

How to help: 
* If a spam-message isn't recognised:
  1. Report the spammer by right-clicking the name in the chat window and selecting "Report Spam"
  2. Type /sentry spam feedback
  3. Send me a PM with the code sequence
* If you encounter a false positive: 
  1. Click the message in SpamSentry main-window
  2. Send me a PM containing that message

About reporting:
GM-Tickets have been confirmed to be limited to 500 characters. If you edit the ticket texts it is advised to keep enough characters available to actually report characters.

Performance notes: 
* All code has been designed to minimize parsing-time, and maximize performance for raiding. 
* The mod currently uses a little under 300kB memory (Patch 2.3 GetAddOnMemoryUsage()).
* Type /sentry statistics to show session statistics.

Known issues:
* Blizzard made an a-typical implementation for who-queries. You may notice slow response on the /who command while using this mod when the chat is crowded. 
* Textballoons from says and yells are still shown. Blizzard currently provides no way to block textballoons.

Localisation: 
German - Credits to: Scath, Gothico , Gamefaq 
French - Credits to: Foxbad, Onissifor, Citanul, Beldarane
Spanish - Credits to Nekromant for his translation
Chinese - Credits to Norova for her translation
Other  - Please contact me if you're able / willing to provide localisation for your language.

Special thanks:
To Aery for unlimited testing-support

Versionhistory:
20081027
- Fixed the missing texts in the report pane
- Fixed issue with the Social Pane / Guild Pane behaving odd (bug in WhoLib)
- Fixed issue with Titan Panel
20081016 - Updated for patch 3.0
20080707 - Updated filters, fixed rare bug.
20080617 - Updated filters, added statistics command.
20080609 - Fixed typo in German localisation. Fixed small bug. Updated filters.
20080525 - Updated French localisation. SpamSentry icon now turns red when spam has been found. Fixed small bug with titanpanel. Updated filters.
20080520 - Fixed problem with tracking certain channels on German clients. Updated filters.
20080516 - Updated german translation (Gamefaq). Updated filters. Code cleanup.
20080508 - Fixed rare bug when handling chatrequests from other addons. Added compatibility for the Chatter Highlights module.
20080507 - Updated filters.
20080504 - Fixed typo in feedback-function.
20080503 - Updated filters; updated TitanBar-plugin to work properly with TitanBar 3.2.
20080502 - Fixed bug with invalid library reference. Fixed a few minor bugs. Updated filters.
20080424 - Updated filters. updated compatibility for WIM addon (Thanks Pazza).
20080411 - Updated filters, added compatibility for Whisp addon.
20080405 - Updated for patch 2.4. Updated filters. Added emote, lookingforgroup and localdefense channels. Removed LOD functionality; overhead was bigger than the actual gain. Fixed functionality for feedback option.
20070603 - Various small bugfixes.
20070526
- Updated for patch 2.1
- New GUI for spamreporting to reflect changes in the Blizzard interface
- Party-invites from people that haven't whispered you (or you them) or that are not on your friends or guildlist are now ignored. This feature can be turned of via the options menu.
20070524-beta - Updated for patch 2.1. New GUI for spamreporting to reflect changes in the Blizzard interface.
20070521 - Two small potential fixes for reported issues with levelcheck and framexml errors. Updated filters.
20070515 - Updated wholib to fix issue with an error with 3rd party addons. Fixed error with localised blacklists.
20070512 - Tweaked filters to deal with some multi-message spam. Added an optional ignore-by-level. Updated translations. Fixed issue with closing social pane at random times.
20070426 - Updated filters. Counters on FuBar / Titan bar are now customisable. Added a no-reply-needed notice to tickettexts.
20070417 - Fixed multimessage detection. Updated filters and translations. Added rightclick option for reporting naming violations.
20070410 - Solved issue with some non-detected whitespaces. Added traditional chinese translations by Norova. Added RP support. Changed some notifications. Updated filtering logic to deal better with multi message spams and false positives.
20070328 - Added support for WIM, Cellular and ForgottenChat. Updated filters. Fixed a rare error when manually reporting a spammer. Using server time/date now instead of local. Added support for the guildrecruitment channel.
20070303 - Updated filters. Fixed ignore system. Spam-button in mailframe will no longer show when the mod is disabled. Fixed possible false positive when no results from the who-query were received. Fixed some minor issues.
20070212 - Fixed (and tested) schedules for reminder and garbage collection.
20070211 - Fixed hourly reminder (thx Elkano). Fixed line-end in reports. Updated localisations, filters. Changed some routines.
20070204 - Fixed typo in French Translation
20070203.2 - Fixed more localisation stuff. Fixed major issue with caught messages from general channels.
20070203 - Fixed issue with localisation. Fixed bot code.
20070202 - Fixed minor issue with incorrect text in generated reports
20070129 - Added code to fix a major bug in the reporting-logic that emerged when using channels in non-default chatwindows.
20070123 - Major recoding : Ace2 rewrite. Several minor bugfixes. Independent GUI.
---
20070115 - Fixed some minor bugs and issues, updated TOC, and re-added rightclick support when clicking a playername in chat.
20070103 - Added GUI-support for FuBar and Titan. Updated filters to deal with control characters. Added a check for availability of ticket-system. Fixed several minor bugs.
20061224 - Critical update. Changed hooks to solve pet-bar issue. Created work-around for UI-error.
20061221 - Updated filters, fixed a few minor bugs/issues, added configurable report language, added slash-commands for handling reportlists.
20061213 - Updated helptexts
20061212 - Major update:
- Reworked reporting: If there is one character to report, the report is as usual. If there are more, only a brief list is generated to save characters (500 limit).
- Added functionality for detecting multi-line spams. This works by delaying non white-listed messages for a few minor seconds to make sure no more lines are incoming. Delaying can optionally disabled.
- Bot reporting now works with reportlists just like spam.
- Ignorelist is only emptied at login now
- Bots can no longer be reported twice
- Fixed issue with general channels on German clients
- Added Spanish translation, thanks to Nekromant
- Removed the LFG-channel support as the channel is no longer existent
- Tweaked the filters a bit
20061130 - Fixed general channel filtering. Added report-button to mailframe. Updated filters. Fixed potential scripterror with ignorelist.
20061122 - Added support for manual bot-reporting. Added automatic ignore-list adding/removing to suppress subsequent textballoons. Fixed a minor bug.
20061118 - Updated version-check
20061117 - Several updates:
- Full rework of WIM-hook.
- Fixed a few minor bugs
- Updated filters
- Reworked heuristics for better prevention of false positives
- Updated French translation
20061112 - Several updates:
- Now supresses fast spammed messages
- Added general channel support
- Added French localisation, thanks to Foxbad
- Added support for WIM
- Optimized some code (thanks Noos)
20061109 - Changed who-hook to fix issues with other mods
20061108 - Major update:
- Added German localisation, thanks to Scath
- Added cross-realm support
- Fixed a bug where the mod caused open windows to close/move on each received message
- Updated the report-GUI to support messages of up to 5000 characters now. (previously only 500)
- Added a who-cache to prevent quickly-spammed messages from appearing due to who-lag.
20061107 - Minor bug-fix, typo's.
20061106 - Fixed a bug semi-randomly causing messages from people not in guild/party/friends to not appear in chatlog
20061105 - Removed left-behind debugcode causing an error now when a message was blocked. Updated some message-texts.
20061104 - Removed the clickable link in player messages, added a right-click option to player-frames and player-names. Cleaned-up some code, removed a bug causing a script error.
20061103 - Fixed a bug that caused the mod to generate a script error when receiving a whisper from a low-level character
20061102 - Removed left-behind debugcode
20061031 - Beta 2
20061029 - Beta
20061024 - Alfa