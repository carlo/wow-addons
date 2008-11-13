local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54174 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Illidan Stormrage"], function(Illidan)
	Illidan:RegisterTranslation("enUS", function() return {
		["Behold the power... of the demon within!"] = "Behold the power... of the demon within!",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "Blade of Azzinoth casts Summon Tear of Azzinoth.",
		["Flame of Azzinoth"] = "Flame of Azzinoth",
	} end)

	Illidan:RegisterTranslation("deDE", function() return {
		["Behold the power... of the demon within!"] = "Erzittert vor der Macht des Dämonen!",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "Klinge von Azzinoth wirkt Träne von Azzinoth beschwören.",
		["Flame of Azzinoth"] = "Flamme von Azzinoth",
	} end)

	Illidan:RegisterTranslation("koKR", function() return {
		["Behold the power... of the demon within!"] = "내 안에 깃든... 악마의 힘을 보여주마!",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "아지노스의 칼날|1이;가; 아지노스의 눈물 소환|1을;를; 시전합니다.",
		["Flame of Azzinoth"] = "아지노스의 불꽃",
	} end)

	Illidan:RegisterTranslation("frFR", function() return {
		["Behold the power... of the demon within!"] = "Contemplez la puissance... du démon intérieur !",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "Lame d'Azzinoth lance Invocation de la Larme d'Azzinoth.",
		["Flame of Azzinoth"] = "Flamme d'Azzinoth",
	} end)

	Illidan:RegisterTranslation("zhTW", function() return {
		["Behold the power... of the demon within!"] = "感受我體內的惡魔之力吧!",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "埃辛諾斯之刃施放了召喚埃辛諾斯之淚。",
		["Flame of Azzinoth"] = "埃辛諾斯火焰",
	} end)

	Illidan:RegisterTranslation("zhCN", function() return {
		["Behold the power... of the demon within!"] = "感受我体内的恶魔之力吧！",
		["Blade of Azzinoth casts Summon Tear of Azzinoth."] = "埃辛诺斯之刃施放了召唤埃辛诺斯之类。",
		["Flame of Azzinoth"] = "埃辛诺斯之焰",
	} end)

	local demon = Illidan:GetTranslation("Behold the power... of the demon within!")
	local azzinoth = Illidan:GetTranslation("Blade of Azzinoth casts Summon Tear of Azzinoth.")
	local flameDies = string.format(UNITDIESOTHER, Illidan:GetTranslation("Flame of Azzinoth"))

	Illidan:UnregisterTranslations()

	function Illidan:Init()
		self:RegisterCombatant(BB["Illidan Stormrage"], true)
		self:RegisterChatEvent("yell", BB["Illidan Stormrage"], demon, self.PhaseDemon)
	end

	function Illidan:OnEnable()
		ThreatLib:GetModule("NPCCore").modulePrototype.OnEnable(self)
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
		self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	end

	function Illidan:PhaseDemon()
		self:WipeRaidThreatOnMob(BB["Illidan Stormrage"])
		if not self:IsEventScheduled("IllidanDemonTimer") then
			self:ScheduleEvent("IllidanDemonTimer", self.PhaseNormal, 65, self)
		end
	end

	function Illidan:PhaseNormal()
		self:WipeRaidThreatOnMob(BB["Illidan Stormrage"])
	end

	-- Phase 2
	local flames = 0
	function Illidan:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
		if msg == azzinoth then
			self:WipeAllRaidThreat()
			self:SetNumberOfMobs(2)
			flames = 2
		end
	end
	
	function Illidan:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
		if msg == flameDies then
			flames = flames - 1
			if flames == 0 then
				-- phase 3
				self:WipeAllRaidThreat()
				self:SetNumberOfMobs(1)
			else
				self:SetNumberOfMobs(flames)
			end
		end
	end

	function Illidan:StartFight()
		self:SetNumberOfMobs(1)
	end

end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
