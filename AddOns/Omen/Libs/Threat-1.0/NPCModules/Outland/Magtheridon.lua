local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54284 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Magtheridon"], BB["Hellfire Channeler"], function(Magtheridon)
	Magtheridon:RegisterTranslation("enUS", function() return {
		["I... am... unleashed!"] = "I... am... unleashed!",
	} end)

	Magtheridon:RegisterTranslation("deDE", function() return {
		["I... am... unleashed!"] = "Ich... bin... frei!",
	} end)

	Magtheridon:RegisterTranslation("frFR", function() return {
		["I... am... unleashed!"] = "Me... voilà... déchaîné !",
	} end)

	Magtheridon:RegisterTranslation("koKR", function() return {
		["I... am... unleashed!"] = "내가... 풀려났도다!",
	} end)

	Magtheridon:RegisterTranslation("zhTW", function() return {
		["I... am... unleashed!"] = "我……被……釋放了!",
	} end)

	Magtheridon:RegisterTranslation("zhCN", function() return {
		["I... am... unleashed!"] = "我……自由了！",
	} end)

	local magPhase = Magtheridon:GetTranslation("I... am... unleashed!")
	local channelerDeathCount = 0
	Magtheridon:UnregisterTranslations()

	function Magtheridon:Init()
		self:RegisterCombatant(BB["Magtheridon"], true)
		self:RegisterCombatant(BB["Hellfire Channeler"], self.ChannelerDeath)

		self:RegisterChatEvent("yell", BB["Magtheridon"], magPhase, self.phaseTransition)
	end
	
	function Magtheridon:ChannelerDeath()
		self:SetNumberOfMobs(self:GetNumberOfMobs() - 1)
		channelerDeathCount = channelerDeathCount + 1
	end

	function Magtheridon:StartFight()
		self:SetNumberOfMobs(5)
		channelerDeathCount = 0
	end

	function Magtheridon:phaseTransition()
		if channelerDeathCount == 5 then
			self:SetNumberOfMobs(1)
		else
			self:SetNumberOfMobs(self:GetNumberOfMobs() + 1)
		end
		self:WipeRaidThreatOnMob(BB["Magtheridon"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
