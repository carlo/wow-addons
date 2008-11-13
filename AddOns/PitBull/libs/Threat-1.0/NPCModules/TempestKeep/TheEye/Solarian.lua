local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54286 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["High Astromancer Solarian"], BB["Solarium Agent"], BB["Solarium Priest"], function(Solarian)
	Solarian:RegisterTranslation("enUS", function() return {
		["I will crush your delusions of grandeur!"] = "I will crush your delusions of grandeur!",
		["You are hopelessly outmatched!"] = "You are hopelessly outmatched!",
	} end)

	Solarian:RegisterTranslation("deDE", function() return {
		["I will crush your delusions of grandeur!"] = "Ich werde Euch Euren Hochmut austreiben!",
		["You are hopelessly outmatched!"] = "Ihr seid eindeutig in der Unterzahl!",
	} end)

	Solarian:RegisterTranslation("frFR", function() return {
		["I will crush your delusions of grandeur!"] = "Je vais balayer vos illusions de grandeur !",
		["You are hopelessly outmatched!"] = "Vous êtes désespérément surclassés !",
	} end)

	Solarian:RegisterTranslation("koKR", function() return {
		["I will crush your delusions of grandeur!"] = "그 오만한 콧대를 꺾어주마!",
		["You are hopelessly outmatched!"] = "한 줌의 희망마저 짓밟아주마!",
	} end)

	Solarian:RegisterTranslation("zhTW", function() return {
		["I will crush your delusions of grandeur!"] = "我會粉碎你那偉大的夢想!",
		["You are hopelessly outmatched!"] = "我的實力遠勝於你!",
	} end)

	Solarian:RegisterTranslation("zhCN", function() return {
		["I will crush your delusions of grandeur!"] = "I will crush your delusions of grandeur!",--miss
		["You are hopelessly outmatched!"] = "You are hopelessly outmatched!",--miss
	} end)

	local zergPhase1 = Solarian:GetTranslation("I will crush your delusions of grandeur!")
	local zergPhase2 = Solarian:GetTranslation("You are hopelessly outmatched!")

	Solarian:UnregisterTranslations()

	local agentDeathCount = 0

	function Solarian:Init()

		self:RegisterCombatant(BB["High Astromancer Solarian"], true)

		self:RegisterCombatant(BB["Solarium Agent"], self.AgentDeath)
		self:RegisterCombatant(BB["Solarium Priest"], self.SingleDeath)

		self:RegisterChatEvent("yell", BB["High Astromancer Solarian"], zergPhase1, self.phaseTransition)
		self:RegisterChatEvent("yell", BB["High Astromancer Solarian"], zergPhase2, self.phaseTransition)
	end

	function Solarian:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Solarian:phaseTransition()
--		self:SetNumberOfMobs(self:GetNumberOfMobs() + 4)		-- Add 4 spawns
		self:SetNumberOfMobs(15) -- Solarian is "elsewhere" and 15 agents are spawned.
		self:WipeAllRaidThreat()
		agentDeathCount = 0
		if not self:IsEventScheduled("SolarianReturnTimer") then
				self:ScheduleEvent("SolarianReturnTimer", self.returnTransition, 25, self)
		end
	end

	function Solarian:AgentDeath()
		agentDeathCount = agentDeathCount + 1
		self:SetNumberOfMobs(self:GetNumberOfMobs() - 1)
	end

	function Solarian:returnTransition()
		if agentDeathCount == 15 then
			self:SetNumberOfMobs(3)
		else
			self:SetNumberOfMobs(self:GetNumberOfMobs() + 3)
		end
	end

end)



table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end