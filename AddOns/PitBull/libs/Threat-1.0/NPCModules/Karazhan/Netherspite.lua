local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Netherspite"], function(Netherspite)
	Netherspite:RegisterTranslation("enUS", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s cries out in withdrawal, opening gates to the nether.",
	} end)

	Netherspite:RegisterTranslation("deDE", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s schreit auf und \195\182ffnet Tore zum Nether.",
	} end)

	Netherspite:RegisterTranslation("frFR", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s se retire avec un cri en ouvrant un portail vers le Néant.",
	} end)

	Netherspite:RegisterTranslation("koKR", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s|1이;가; 물러나며 고함을 지르더니 황천의 문을 엽니다.",
	} end)

	Netherspite:RegisterTranslation("zhTW", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s大聲呼喊撤退，打開通往地獄的門。",
	} end)
	
	Netherspite:RegisterTranslation("zhCN", function() return {
		["%s cries out in withdrawal, opening gates to the nether."] = "%s在撤退中大声呼喊着，打开了回到虚空的传送门。",
	} end)

	local netherPhase = Netherspite:GetTranslation("%s cries out in withdrawal, opening gates to the nether.")

	Netherspite:UnregisterTranslations()

	function Netherspite:Init()
		self:RegisterCombatant(BB["Netherspite"], true)

		if netherPhase then
			self:RegisterChatEvent("emote", BB["Netherspite"], netherPhase, self.WipeAllRaidThreat)
			-- self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		end
	end

	function Netherspite:StartFight()
		-- SetNumberOfMobs is used as a divisor for global threat. Be sure to set it correctly, and to account for mob deaths during the fight
		-- If you are unsure of the participants, or you want to just be safe, leave this at 1
		self:SetNumberOfMobs(1)
		
	end
	
	function Netherspite:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find(netherPhase) then
			self:WipeRaidThreatOnMob(BB["Netherspite"])
		end
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
