local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Blackheart the Inciter"], function(Blackheart)
	Blackheart:RegisterTranslation("enUS", function() return {
		["Time for fun!"] = "Time for fun!",
		["War Stomp"] = "War Stomp",
	} end)

	Blackheart:RegisterTranslation("deDE", function() return {
		["Time for fun!"] = "Zeit für Spass!",
		["War Stomp"] = "Kriegsdonner",
	} end)

	Blackheart:RegisterTranslation("frFR", function() return {
		["Time for fun!"] = "Rions un peu !",
		["War Stomp"] = "Choc martial",
	} end)

	Blackheart:RegisterTranslation("koKR", function() return {
		["Time for fun!"] = "재미를 볼 시간이다!",
		["War Stomp"] = "전투 발구르기",
	} end)

	Blackheart:RegisterTranslation("zhTW", function() return {
		["Time for fun!"] = "玩樂的時間到了!",
		["War Stomp"] = "戰爭踐踏",
	} end)

	Blackheart:RegisterTranslation("zhCN", function() return {
		["Time for fun!"] = nil,
		["War Stomp"] = "战争践踏",
	} end)
	
	local blackheartPhase = Blackheart:GetTranslation("Time for fun!")
	local warStomp = Blackheart:GetTranslation("War Stomp")
	Blackheart:UnregisterTranslations()

	function Blackheart:Init()
		self:RegisterCombatant(BB["Blackheart the Inciter"], true)

		self:RegisterChatEvent("yell", BB["Blackheart the Inciter"], blackheartPhase, self.phaseTransition)
		if warStomp then
			self.attacks[warStomp] = function(self, mob, target) self.ModifyThreat(mob, target, 0.50, 0) end -- Need testing to nail down the exact value, so it's getting the default 50% for now.
		end
	end
	

	function Blackheart:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Blackheart:phaseTransition()
		self:WipeRaidThreatOnMob(BB["Blackheart the Inciter"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
