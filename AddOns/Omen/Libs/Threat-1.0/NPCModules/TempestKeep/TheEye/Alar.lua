local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Al'ar"], function(Alar)
	Alar:RegisterTranslation("enUS", function() return {
		["Al'ar begins to cast Rebirth."] = true,
	} end)
	Alar:RegisterTranslation("deDE", function() return {
		["Al'ar begins to cast Rebirth."] = "Al'ar beginnt Wiedergeburt zu wirken.", --needs testing
	} end)
	Alar:RegisterTranslation("frFR", function() return {
		["Al'ar begins to cast Rebirth."] = "Al'ar commence à lancer Renaissance.",
	} end)
	Alar:RegisterTranslation("koKR", function() return {
		["Al'ar begins to cast Rebirth."] = "알라르|1이;가; 환생 시전을 시작합니다.",
	} end)
	Alar:RegisterTranslation("zhTW", function() return {
		["Al'ar begins to cast Rebirth."] = "歐爾開始施放復生。",
	} end)
	Alar:RegisterTranslation("zhCN", function() return {
		["Al'ar begins to cast Rebirth."] = "奥开始施放复生。",
	} end)

	local rebirth = Alar:GetTranslation("Al'ar begins to cast Rebirth.")
	Alar:UnregisterTranslations()

	function Alar:Init()
		self:RegisterCombatant(BB["Al'ar"], true)
	end

	function Alar:OnEnable()
		ThreatLib:GetModule("NPCCore").modulePrototype.OnEnable(self)
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	end

	function Alar:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
		if msg == rebirth then
			self:WipeRaidThreatOnMob(BB["Al'ar"])
		end
	end
end)

end
