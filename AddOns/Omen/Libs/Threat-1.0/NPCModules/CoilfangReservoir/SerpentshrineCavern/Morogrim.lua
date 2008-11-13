local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Morogrim Tidewalker"], BB["Tidewalker Lurker"], function(Morogrim)
	Morogrim:RegisterTranslation("enUS", function() return {
		["Murlocs"] = "Murlocs",
	} end)

	Morogrim:RegisterTranslation("deDE", function() return {
		["Murlocs"] = "Murlocs",
	} end)

	Morogrim:RegisterTranslation("frFR", function() return {
		["Murlocs"] = "Murlocs",
	} end)

	Morogrim:RegisterTranslation("koKR", function() return {
		["Murlocs"] = "멀록 등장",
	} end)

	Morogrim:RegisterTranslation("zhTW", function() return {
		["Murlocs"] = "魚人",
	} end)

	Morogrim:RegisterTranslation("zhCN", function() return {
		["Murlocs"] = "鱼人",
	} end)

	local murlocPhase = Morogrim:GetTranslation("Murlocs")

	Morogrim:UnregisterTranslations()

	function Morogrim:Init()
		self:RegisterCombatant(BB["Morogrim Tidewalker"], true)
		self:RegisterCombatant(BB["Tidewalker Lurker"], self.SingleDeath)

		if murlocPhase then
				self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		end
	end

	function Morogrim:StartFight()
		-- SetNumberOfMobs is used as a divisor for global threat. Be sure to set it correctly, and to account for mob deaths during the fight
		-- If you are unsure of the participants, or you want to just be safe, leave this at 1
		self:SetNumberOfMobs(1)
	end

	function Morogrim:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find(murlocPhase) then
			self:SetNumberOfMobs(self:GetNumberOfMobs() + 12)	-- Morogrim + 12 murlocs (two packs of six)
			self:WipeRaidThreatOnMob(BB["Tidewalker Lurker"])
		end
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end