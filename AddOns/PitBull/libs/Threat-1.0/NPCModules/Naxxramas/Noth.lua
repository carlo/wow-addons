local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 40795 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Noth the Plaguebringer"], function(Noth)
	Noth:RegisterTranslation("enUS", function() return {
		["Noth the Plaguebringer gains Blink."] = "Noth the Plaguebringer gains Blink.",
	} end)

	Noth:RegisterTranslation("deDE", function() return {
		["Noth the Plaguebringer gains Blink."] = "Noth der Seuchenf\195\188rst bekommt 'Blinzeln'.",
	} end)

	Noth:RegisterTranslation("koKR", function() return {
		["Noth the Plaguebringer gains Blink."] = "역병술사 노스|1이;가; 점멸 효과를 얻었습니다.",
	} end)

	Noth:RegisterTranslation("zhCN", function() return {
		["Noth the Plaguebringer gains Blink."] = "瘟疫使者诺斯获得了闪现术的效果。",
	} end)

	Noth:RegisterTranslation("zhTW", function() return {
		["Noth the Plaguebringer gains Blink."] = "瘟疫者諾斯獲得了閃現的效果。",
	} end)

	local blink = Noth:GetTranslation("Noth the Plaguebringer gains Blink.")

	Noth:UnregisterTranslations()

	function Noth:Init()
		self:RegisterCombatant(BB["Noth the Plaguebringer"], true)
	end

	function Noth:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Noth:OnEnable()
		ThreatLib:GetModule("NPCCore").modulePrototype.OnEnable(self)
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	end

	function Noth:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		if msg == blink then
			self:WipeRaidThreatOnMob(BB["Noth the Plaguebringer"])
		end
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
