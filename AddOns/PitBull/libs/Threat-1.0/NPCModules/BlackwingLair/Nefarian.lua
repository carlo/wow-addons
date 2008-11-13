local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Nefarian"], function(Nefarian)
	Nefarian:RegisterTranslation("enUS", function() return {
		["BURN! You wretches! BURN!"] = "BURN! You wretches! BURN!"
	} end)

	Nefarian:RegisterTranslation("deDE", function() return {
		["BURN! You wretches! BURN!"] = "BRENNT! Ihr Elenden! BRENNT!"
	} end)

	Nefarian:RegisterTranslation("frFR", function() return {
		["BURN! You wretches! BURN!"] = nil
	} end)

	Nefarian:RegisterTranslation("koKR", function() return {
		["BURN! You wretches! BURN!"] = "불타라! 활활! 불타라!"
	} end)

	Nefarian:RegisterTranslation("zhTW", function() return {
		["BURN! You wretches! BURN!"] = "燃燒吧！你這個不幸的人！燃燒吧！"
	} end)
	
	Nefarian:RegisterTranslation("zhCN", function() return {
		["BURN! You wretches! BURN!"] = "燃烧吧！你这个"
	} end)

	local phaseTwo = Nefarian:GetTranslation("BURN! You wretches! BURN!")

	Nefarian:UnregisterTranslations()

	function Nefarian:Init()
		self:RegisterCombatant(BB["Nefarian"], true)
		self:RegisterChatEvent("yell", BB["Nefarian"], phaseTwo, self.phaseTwo)
	end

	function Nefarian:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Nefarian:phaseTwo()
		self:WipeRaidThreatOnMob(BB["Nefarian"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
