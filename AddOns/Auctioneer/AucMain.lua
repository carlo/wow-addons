--[[
	Auctioneer
	Revision: $Id: AucMain.lua 1894 2007-05-24 13:54:19Z luke1410 $
	Version: 5.0.PRE.2544 (BillyGoat)
	Original version written by Norganna.
	Contributors: Araband

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
Auctioneer_RegisterRevision("$URL$", "$Rev: 1894 $")


Auctioneer.Version="5.0.PRE.2544";
-- If you want to see debug messages, create a window called "ettdebug" within the client.
if (Auctioneer.Version == "<".."%version%>") then
	Auctioneer.Version = "4.1.DEV";
end

local function onLoad()
	-- Unhook some boot triggers if necessary.
	-- These might not exist on initial loading or if an addon depends on Auctioneer
	if (Auctioneer_CheckLoad) then
		Stubby.UnregisterFunctionHook("AuctionFrame_LoadUI", Auctioneer_CheckLoad);
	end
	if (Auctioneer_ShowNotLoaded) then
		Stubby.UnregisterFunctionHook("AuctionFrame_Show", Auctioneer_ShowNotLoaded);
		if (BrowseNoResultsText and BrowseNoResultsText:GetText() == _AUCT('MesgNotLoaded')) then
			BrowseNoResultsText:SetText("")
		end
	end

	-- Hook in new tooltip code
	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 100, Auctioneer.Tooltip.HookTooltip);

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Auctioneer", "CommandHandler", [[
		local function cmdHandler(msg)
			local cmd, param = msg:lower():match("^(%w+)%s*(.*)$")
			cmd = cmd or msg:lower() or "";
			param = param or "";
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Auctioneer...Test")
					local loaded, reason = LoadAddOn("Auctioneer")
					if loaded then
						Stubby.Print("Auctioneer loaded successfully")
					else
						Stubby.Print("Failed to load Auctioneer. Error message: "..reason)
					end
				elseif (param == "auctionhouse") then
					Stubby.Print("Setting Auctioneer to load when this character visits the auction house")
					Stubby.SetConfig("Auctioneer", "LoadType", param)
				elseif (param == "always") then
					Stubby.Print("Setting Auctioneer to always load for this character")
					Stubby.SetConfig("Auctioneer", "LoadType", param)
					LoadAddOn("Auctioneer")
				elseif (param == "never") then
					Stubby.Print("Setting Auctioneer to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Auctioneer", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Auctioneer is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/auctioneer load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/auctioneer load auctionhouse|r - Auctioneer will load when you visit the auction house")
				Stubby.Print("  |cffffffff/auctioneer load always|r - Auctioneer will always load for this character")
				Stubby.Print("  |cffffffff/auctioneer load never|r - Auctioneer will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_AUCTIONEER1 = "/auctioneer"
		SLASH_AUCTIONEER2 = "/auction"
		SLASH_AUCTIONEER3 = "/auc"
		SlashCmdList["AUCTIONEER"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Auctioneer", "Triggers", [[
		function Auctioneer_CheckLoad()
			local loadType = Stubby.GetConfig("Auctioneer", "LoadType")
			if (loadType == "auctionhouse" or not loadType) then
				LoadAddOn("Auctioneer")
			end
		end
		function Auctioneer_ShowNotLoaded()
			if (not Auctioneer) then
				BrowseNoResultsText:SetText("]].._AUCT('MesgNotLoaded')..[[");
			end
		end
		local function onLoaded()
			Stubby.UnregisterAddOnHook("Blizzard_AuctionUI", "Auctioneer")
			if (not IsAddOnLoaded("Auctioneer")) then
				Stubby.RegisterFunctionHook("AuctionFrame_Show", 100, Auctioneer_ShowNotLoaded)
			end
		end
		Stubby.RegisterFunctionHook("AuctionFrame_LoadUI", 100, Auctioneer_CheckLoad)
		Stubby.RegisterAddOnHook("Blizzard_AuctionUI", "Auctioneer", onLoaded)
		local loadType = Stubby.GetConfig("Auctioneer", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Auctioneer")
		else
			Stubby.Print("]].._AUCT('MesgNotLoaded')..[[");
		end
	]]);
end

Auctioneer.OnLoad = onLoad;

