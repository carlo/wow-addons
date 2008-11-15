--[[
	Auctioneer Advanced - Scan Finish module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: ScanFinish.lua 3576 2008-10-10 03:07:13Z aesir $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that adds a few event functionalities
	to Auctioneer 5 when a successful scan is completed.

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
if not AucAdvanced then return end

local libType, libName = "Util", "ScanFinish"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local blnDebug = false
local blnLibEmbedded = nil

local blnScanStarted = false
local blnScanStatsReceived = false
local blnScanLastPage = false
local intScanMinThreshold = 300  --Safeguard to prevent Auditor Refresh button scans from executing our finish events. Use 300 or more to be safe
local blnScanMinThresholdMet = false
local strPrevSound = "AuctioneerClassic"

function lib.Processor(callbackType, ...)

	if blnDebug then
		print(".")
		print("  Debug:CallbackType:", callbackType)
		print("  Debug:Sound:", AucAdvanced.Settings.GetSetting("util.scanfinish.soundpath"))
		print("  Debug:ScanFinish:Processor:CallbackType:", callbackType)
		print("  Debug:API.IsBlocked=", AucAdvanced.API.IsBlocked())
		print("  Debug:API.IsScanning=", AucAdvanced.Scan.IsScanning())
		print("  Debug:ScanStarted=", blnScanStarted)
		print("  Debug:ScanLastPage=", blnScanLastPage)
		print("  Debug:ScanStatsReceived=", blnScanStatsReceived)
	end

	if (callbackType == "scanprogress") then
		if not AucAdvanced.Settings.GetSetting("util.scanfinish.activated") then
			return
		end
		private.ScanProgressReceiver(...)
	elseif (callbackType == "scanstats") then
		if not AucAdvanced.Settings.GetSetting("util.scanfinish.activated") then
			return
		end
		if blnDebug then print("  Debug:Updating ScanStatsReceived=true") end
		blnScanStatsReceived = true
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.ConfigChanged(...)
	end
end

function lib.OnLoad()
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.scanfinish.activated", true)
	AucAdvanced.Settings.SetDefault("util.scanfinish.shutdown", false)
	AucAdvanced.Settings.SetDefault("util.scanfinish.logout", false)
	AucAdvanced.Settings.SetDefault("util.scanfinish.message", "So many auctions... so little time")
	AucAdvanced.Settings.SetDefault("util.scanfinish.messagechannel", "none")
	AucAdvanced.Settings.SetDefault("util.scanfinish.emote", "none")
	AucAdvanced.Settings.SetDefault("util.scanfinish.debug", false)
	if AucAdvanced.Settings.GetSetting("util.scanfinish.debug") then blnDebug = true end
end

function private.ScanProgressReceiver(state, totalAuctions, scannedAuctions, elapsedTime)
	if blnDebug then print("	Debug:ScanProgressReceiver:Init") end
	if blnDebug then print("	Debug:Process State=", state) end

	--Check that we're enabled before passing on the callback
	-- OR
	--Check to see if browseoverride has been set, if so gracefully allow it to continue as is
	if not AucAdvanced.Settings.GetSetting("util.scanfinish.activated") then
		if blnDebug then print("  Debug:ScanFinish Switching State=false (ScanFinish is deactivated)") end
		state = false
	elseif AucAdvanced.Settings.GetSetting("util.browseoverride.activated") then
		if blnDebug then print("  Debug:ScanFinish Switching State=false (Browser override is activated)") end
		state = false
	end

	if blnDebug then
		print(" Debug:Sound: "..AucAdvanced.Settings.GetSetting("util.scanfinish.soundpath"))
		print("	Debug:ScanStarted="..tostring(blnScanStarted))
		print("	Debug:ScanLastPage="..tostring(blnScanLastPage))
		print("	Debug:ScanStatsReceived="..tostring(blnScanStatsReceived))
		print("	Debug:ScanMinThreshold="..tostring(intScanMinThreshold))
		if scannedAuctions then print("	Debug:ScannedAuctions="..tostring(scannedAuctions)) end
		if totalAuctions then print("	Debug:TotalAuctions="..tostring(totalAuctions)) end
	end

	--Change the state if we have not scanned any auctions yet.
	--This is done so that we don't start the timer too soon and thus get skewed numbers
	if (state == nil and (
		not scannedAuctions or
		scannedAuctions == 0 or
		not AucAdvanced.API.IsBlocked() or
		BrowseButton1:IsVisible()
	)) then
		if blnDebug then
			print("	Debug:ScanFinish Switching State=true")
			print("	Debug:Updating ScanStarted=true")
			print("	Debug:Updating ScanStatsReceived=false")
		end
		blnScanStarted = true
		blnScanLastPage = false
		blnScanStatsReceived = false
		state = true
	end

	--if all of the following conditions are met, we should have had a successfully completed full scan
	--1. Has the Processor sent a state of false
	--2. Did we find a successful scan start
	--3. Did we find a minimum amount of scan items
	--4. Did we see the last page of the scan
	--5. Did we receive the stats
	if (state == false
		and blnScanStarted
		and blnScanMinThresholdMet
		and blnScanLastPage
		and blnScanStatsReceived
		and not (AucAdvanced.Scan.Private.scanStack and #AucAdvanced.Scan.Private.scanStack > 0)
	) then
		private.PerformFinishEvents()
	end

	--detect if we've reached the last page. Print progress on the way if we're in debug
	--don't detect do this before the completed detection to prevent premature execution
	if totalAuctions and scannedAuctions then
		if blnDebug then
			print("	Debug:ScanFinish:totalAuctions:"..totalAuctions.."   scannedAuctions:"..scannedAuctions)
		end

		--Check to see if we've scanned to our minimum threshold to enable shutdown or logout
		if scannedAuctions > intScanMinThreshold and blnScanMinThresholdMet == false then
			if blnDebug then print("	Debug:ScanFinish Switching ScanMinThresholdMet=true") end
			--Send a friendly reminder that we may be shutting down or logging off now
			AlertShutdownOrLogOff()
			blnScanMinThresholdMet = true
		end

		--Send a warning about the impending shutdown/logout as we approach the end of our auction scan
		if blnScanStarted and blnScanMinThresholdMet and (totalAuctions - scannedAuctions < 150) then
			AlertShutdownOrLogOff()
		end
		if totalAuctions - scannedAuctions < 50 then
			if blnDebug then
				print("	Debug:ScanFinish Switching LastPageReached=true")
			end

			blnScanLastPage = true
			end
		end

end

function private.PerformFinishEvents()
	--Clean up/reset local variables
	blnScanStarted = false
	blnScanStatsReceived = false
	blnScanLastPage = false
	blnScanMinThresholdMet = false

	if blnDebug then
		print("  Debug:Message: "..AucAdvanced.Settings.GetSetting("util.scanfinish.message"))
		print("  Debug:MessageChannel: "..AucAdvanced.Settings.GetSetting("util.scanfinish.messagechannel"))
		print("  Debug:Emote: "..AucAdvanced.Settings.GetSetting("util.scanfinish.emote"))
		print("  Debug:LogOut: "..tostring(AucAdvanced.Settings.GetSetting("util.scanfinish.logout")))
		print("  Debug:ShutDown: "..tostring(AucAdvanced.Settings.GetSetting("util.scanfinish.shutdown")))
	end

	--Sound
	PlayCompleteSound()

	--Message
	if AucAdvanced.Settings.GetSetting("util.scanfinish.messagechannel") == "none" then
		--don't do anything
	elseif AucAdvanced.Settings.GetSetting("util.scanfinish.messagechannel") == "GENERAL" then
		SendChatMessage(AucAdvanced.Settings.GetSetting("util.scanfinish.message"),"CHANNEL",nil,GetChannelName("General"))
	else
		SendChatMessage(AucAdvanced.Settings.GetSetting("util.scanfinish.message"),AucAdvanced.Settings.GetSetting("util.scanfinish.messagechannel"))
	end


	--Emote
	if not (AucAdvanced.Settings.GetSetting("util.scanfinish.emote") == "none") then
		DoEmote(AucAdvanced.Settings.GetSetting("util.scanfinish.emote"))
	end

	--Shutdown or Logoff
	if (AucAdvanced.Settings.GetSetting("util.scanfinish.shutdown")) then
		print("AucAdvanced: {{"..libName.."}} Shutting Down!!")
		if not blnDebug then
			Quit()
		end
	elseif (AucAdvanced.Settings.GetSetting("util.scanfinish.logout")) then
		print("AucAdvanced: {{"..libName.."}} Logging Out!")
		if not blnDebug then
			Logout()
		end
	end
end

function AlertShutdownOrLogOff()
	if (AucAdvanced.Settings.GetSetting("util.scanfinish.shutdown")) then
		PlaySound("TellMessage")
		print("AucAdvanced: {{"..libName.."}} |cffff3300Reminder|r: Shutdown is enabled. World of Warcraft will be shut down once the current scan successfully completes.")
	elseif (AucAdvanced.Settings.GetSetting("util.scanfinish.logout")) then
		PlaySound("TellMessage")
		print("AucAdvanced: {{"..libName.."}} |cffff3300Reminder|r: LogOut is enabled. This character will be logged off once the current scan successfully completes.")
	end
end

function PlayCompleteSound()
	strConfiguredSoundPath = AucAdvanced.Settings.GetSetting("util.scanfinish.soundpath")
	if strConfiguredSoundPath and not (strConfiguredSoundPath == "none") then
		if blnDebug then
			print("AucAdvanced: {{"..libName.."}} You are listening to "..strConfiguredSoundPath)
		end
		if strConfiguredSoundPath == "AuctioneerClassic" then
			if blnLibEmbedded == nil then
			  	blnLibEmbedded = IsLibEmbedded()
			end
			strConfiguredSoundPath = "Interface\\AddOns\\Auc-Util-ScanFinish\\ScanComplete.mp3"
			if blnLibEmbedded then
				strConfiguredSoundPath = "Interface\\AddOns\\Auc-Advanced\\Modules\\Auc-Util-ScanFinish\\ScanComplete.mp3"
			end

			--Known PlaySoundFile bug seems to require some event preceeding it to get it to work reliably
			--Can get this working as a print to screen or an internal sound. Other developers
			--suggested this workaround.
			--http://forums.worldofwarcraft.com/thread.html?topicId=1777875494&sid=1&pageNo=4
			PlaySound("GAMEHIGHLIGHTFRIENDLYUNIT")
			PlaySoundFile(strConfiguredSoundPath)

		else
			PlaySound(strConfiguredSoundPath)
		end
	end
end

--Config UI functions
function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName, libType.." Modules")

	gui:AddHelp(id, "what is scanfinish",
		"What is ScanFinish?",
		"ScanFinish is an AuctioneerAdvanced module that will execute one or more useful events once Auctioneer has completed a scan successfully.\n\nScanFinish will only execute these events during full Auctioneer scans with a minimum threshold of "..intScanMinThreshold .." items, so there is no worry about logging off or spamming emotes during the incremental scans or BottomScanner activities. Unfortunately, this also means the functionality will not be enabled in auction houses with under "..intScanMinThreshold.." items."
		)

	gui:AddControl(id, "Header",	 0,	libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanfinish.activated", "Allow the execution of the events below once a successful scan completes")
	gui:AddTip(id, "Selecting this option will enable Auctioneer to perform the events below once Auctioneer has completed a scan successfully. \n\nUncheck this to disable all events.")

	gui:AddControl(id, "Subhead",	0,	"Sound & Emote")
	gui:AddControl(id, "Selectbox",  0, 3, {
		{"none", "None (do not play a sound)"},
		{"AuctioneerClassic", "Auctioneer Classic"},
		{"QUESTCOMPLETED","Quest Completed"},
		{"LEVELUP","Level Up"},
		{"AuctionWindowOpen","Auction House Open"},
		{"AuctionWindowClose","Auction House Close"},
		{"ReadyCheck","Raid Ready Check"},
		{"RaidWarning","Raid Warning"},
		{"LOOTWINDOWCOINSOUND","Coin"},
	}, "util.scanfinish.soundpath", "Pick the sound to play")
	gui:AddTip(id, "Selecting one of these sounds will cause Auctioneer to play that sound once Auctioneer has completed a scan successfully. \n\nBy selecting None, no sound will be played.")

	gui:AddControl(id, "Selectbox",  0, 3, {
		{"none"	  , "None (do not emote)"},
		{"APOLOGIZE" , "Apologize"},
		{"APPLAUD"   , "Applaud"},
		{"BRB"	   , "BRB"},
		{"CACKLE"	, "Cackle"},
		{"CHICKEN"   , "Chicken"},
		{"DANCE"	 , "Dance"},
		{"FAREWELL"  , "Farewell"},
		{"FLIRT"	 , "Flirt"},
		{"GLOAT"	 , "Gloat"},
		{"JOKE"	  , "Silly"},
		{"SLEEP"	 , "Sleep"},
		{"VICTORY"   , "Victory"},
		{"YAWN"	  , "Yawn"},

	}, "util.scanfinish.emote", "Pick the Emote to perform")
	gui:AddTip(id, "Selecting one of these emotes will cause your character to perform the selected emote once Auctioneer has completed a scan successfully.\n\nBy selecting None, no emote will be performed.")

	gui:AddControl(id, "Subhead",	0,	"Message")
	gui:AddControl(id, "Text",	   0, 1, "util.scanfinish.message", "Message text:")
	gui:AddTip(id, "Enter the message text of what you wish your character to say as well as choosing a channel below. \n\nThis will not execute slash commands.")
	gui:AddControl(id, "Selectbox",  0, 3, {
		{"none", "None (do not send message)"},
		{"SAY", "Say (/s)"},
		{"PARTY","Party (/p)"},
		{"RAID","Raid (/r)"},
		{"GUILD","Guild (/g)"},
		{"YELL","Yell (/y)"},
		{"EMOTE","Emote (/em)"},
		{"GENERAL","General"},
	}, "util.scanfinish.messagechannel", "Pick the channel to send your message to")
	gui:AddTip(id, "Selecting one of these channels will cause your character to say the message text into the selected channel once Auctioneer has completed a scan successfully. \n\nBy choosing Emote, your character will use the text above as a custom emote. \n\nBy selecting None, no message will be sent.")


	gui:AddControl(id, "Subhead",	0,	"Shutdown or Log Out")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanfinish.shutdown", "Shutdown World of Warcraft")
	gui:AddTip(id, "Selecting this option will cause Auctioneer to shut down World of Warcraft completely once Auctioneer has completed a scan successfully.")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanfinish.logout", "Log Out the current character")
	gui:AddTip(id, "Selecting this option will cause Auctioneer to log out to the character select screen once Auctioneer has completed a scan successfully. \n\nIf Shutdown is enabled, selecting this will have no effect")


	--Debug switch via gui. Currently not exposed to the end user
	--gui:AddControl(id, "Subhead",	0,	"")
	--gui:AddControl(id, "Checkbox",   0, 1, "util.scanfinish.debug", "Show Debug Information for this session")


end

function IsLibEmbedded()
	blnResult = false
	for pos, module in ipairs(AucAdvanced.EmbeddedModules) do
		--print("  Debug:Comparing Auc-Util-"..libName.." with "..module)
		if "Auc-Util-"..libName == module then
			if blnDebug then
				print("  Debug:Auc-Util-"..libName.." is an embedded module")
			end
			blnResult = true
			break
		end
	end
	return blnResult
end

function private.ConfigChanged()
	--Debug switch via gui. Currently not exposed to the end user
	--blnDebug = AucAdvanced.Settings.GetSetting("util.scanfinish.debug")
	if blnDebug then
		print("  Debug:Configuration Changed")
	end

	if not (strPrevSound == AucAdvanced.Settings.GetSetting("util.scanfinish.soundpath")) then
		PlayCompleteSound()
		strPrevSound = AucAdvanced.Settings.GetSetting("util.scanfinish.soundpath")
	end

	if (not AucAdvanced.Settings.GetSetting("util.scanfinish.activated")) then
		if blnDebug then print("  Debug:Updating ScanFinish:Deactivated") end
		private.ScanProgressReceiver(false)
	elseif (AucAdvanced.Scan.IsScanning()) then
		if blnDebug then print("  Debug:Updating ScanFinish with Scan in progress") end
		private.ScanProgressReceiver(true)
	end
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-ScanFinish/ScanFinish.lua $", "$Rev: 3576 $")
