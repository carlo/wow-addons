local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54174 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Hydross the Unstable"], BB["Pure Spawn of Hydross"], BB["Tainted Spawn of Hydross"], function(Hydross)
	Hydross:RegisterTranslation("enUS", function() return {
		["Aaghh, the poison..."] = "Aaghh, the poison...",
		["Better, much better."] = "Better, much better.",
	} end)

	Hydross:RegisterTranslation("deDE", function() return {
		["Aaghh, the poison..."] = "Aahh, das Gift...",
		["Better, much better."] = "Besser, viel besser.",
	} end)

	Hydross:RegisterTranslation("frFR", function() return {
		["Aaghh, the poison..."] = "Aaarrgh, le poison…",
		["Better, much better."] = "Ça va mieux. Beaucoup mieux.",
	} end)

	Hydross:RegisterTranslation("koKR", function() return {
		["Aaghh, the poison..."] = "으아아, 독이...",
		["Better, much better."] = "아... 기분이 훨씬 좋군.",
	} end)

	Hydross:RegisterTranslation("zhTW", function() return {
		["Aaghh, the poison..."] = "啊，毒……",
		["Better, much better."] = "很好，舒服多了。",
	} end)

	Hydross:RegisterTranslation("zhCN", function() return {
		["Aaghh, the poison..."] = "啊……毒性侵袭了我……",
		["Better, much better."] = "感觉好多了。",
	} end)

	local poisonPhase = Hydross:GetTranslation("Aaghh, the poison...")
	local waterPhase = Hydross:GetTranslation("Better, much better.")

	Hydross:UnregisterTranslations()

	function Hydross:Init()

		self:RegisterCombatant(BB["Hydross the Unstable"], true)

		self:RegisterCombatant(BB["Pure Spawn of Hydross"], self.SingleDeath)
		self:RegisterCombatant(BB["Tainted Spawn of Hydross"], self.SingleDeath)

		self:RegisterChatEvent("yell", BB["Hydross the Unstable"], poisonPhase, self.phaseTransition)
		self:RegisterChatEvent("yell", BB["Hydross the Unstable"], waterPhase, self.phaseTransition)
	end

	function Hydross:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Hydross:phaseTransition()
		-- self:SetNumberOfMobs(5)		-- Hydross + 4 spawns
		self:SetNumberOfMobs(self:GetNumberOfMobs() + 4)		-- Add 4 spawns
		self:WipeRaidThreatOnMob(BB["Hydross the Unstable"])
		self:WipeRaidThreatOnMob(BB["Pure Spawn of Hydross"])
		self:WipeRaidThreatOnMob(BB["Tainted Spawn of Hydross"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end