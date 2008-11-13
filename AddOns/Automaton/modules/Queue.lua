local L = AceLibrary("AceLocale-2.2"):new("Automaton_Queue")
Automaton_Queue = Automaton:NewModule("Queue", "AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")
local module = Automaton_Queue

L:RegisterTranslations("enUS", function() return {
	["Queue"] = true,
	["Options for accepting Battleground queues."] = true,
	["Enabled"] = true,
	["Accepts Battleground queues"] = true,
	["Delay"] = true,
	["With this option enabled, automatic battleground entry is delayed for 100 seconds."] = true,
	["Join"] = true,
	["Joins battleground queues when the battlefield window is displayed."] = true,
	["Joining %s..."] = true,
	["Joining %s in 1:40..."] = true,
	["Join only if not already in a Battleground"] = true,
	["Restricts joining to only when you are not currently in a BG (will still allow you to be in the queue)"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Queue"] = "전장 대기",
	["Options for accepting Battleground queues."] = "전장 대기 옵션을 설정합니다.",
	["Enabled"] = "사용",
	["Accepts Battleground queues"] = "전장 입장을 지연시킵니다.",
	["Delay"] = "지연",
	["With this option enabled, automatic battleground entry is delayed for 100 seconds."] = "이 옵션이 활성화시, 전장 입장을 100초 동안 지연시킵니다.",
	["Join"] = "참가",
	["Joins battleground queues when the battlefield window is displayed."] = "전장 신청 창이 열리면 전장 대기열에 자동 참가합니다.",
	["Joining %s..."] = "%s 입장...",
	["Joining %s in 1:40..."] = "1:40 초 동안 %s 입장 지연...",
	["Join only if not already in a Battleground"] = "전장일 경우 참가 안함",
	["Restricts joining to only when you are not currently in a BG (will still allow you to be in the queue)"] = "당신이 현재 전장에 없을때만 참가를 제한합니다.",
} end)

L:RegisterTranslations("esES", function() return {
	["Queue"] = "Cola",
	["Options for accepting Battleground queues."] = "Opciones para aceptar colas de Campos de Batalla",
	["Enabled"] = "Activado",
	["Accepts Battleground queues"] = "Acepta colas de Campo de Batalla",
	["Delay"] = "Retraso",
	["With this option enabled, automatic battleground entry is delayed for 100 seconds."] = "Con esta opci\195\179n activada la entrada autom\195\161tica a campos de batalla se retrasa 100 segundos",
	["Join"] = "Unirse",
	["Joins battleground queues when the battlefield window is displayed."] = "Te a\195\177ade a las colas para campos de batalla cuando la ventana de campos de batalla est\195\161 abierta.",
	["Joining %s..."] = "Entrando en %s",
	["Joining %s in 1:40..."] = "Entrando en %s en 1:40m...",
} end)

L:RegisterTranslations("zhTW", function() return {
	["Queue"] = "自動排隊",
	["Options for accepting Battleground queues."] = "自動接受戰場排隊",
	["Enabled"] = "允許",
	["Accepts Battleground queues"] = "允許自動進入戰場",
	["Delay"] = "延遲",
	["With this option enabled, automatic battleground entry is delayed for 100 seconds."] = "啟用後延遲100秒自動進入戰場",
	["Join"] = "加入",
	["Joins battleground queues when the battlefield window is displayed."] = "啟用後自動接受戰場排隊",
	["Joining %s..."] = "進入 %s...",
	["Joining %s in 1:40..."] = "1分40秒後入 %s ...",
} end)

module.description = L["Options for accepting Battleground queues."]
module.options = {
	delay = {
		type = 'toggle',
		name = L["Delay"],
		desc = L["With this option enabled, automatic battleground entry is delayed for 100 seconds."],
		get = function() return module.db.profile.delay end,
		set = function(v) module.db.profile.delay = v end,
	},
	join = {
		type = 'toggle',
		name = L["Join"],
		desc = L["Joins battleground queues when the battlefield window is displayed."],
		get = function() return module:IsEventRegistered("BATTLEFIELDS_SHOW") end,
		set = function(v)
			if v then
				module:RegisterEvent("BATTLEFIELDS_SHOW")
			else
				module:UnregisterEvent("BATTLEFIELDS_SHOW")
			end
			module.db.profile.join = v
		end,
	},
	restrict = {
		type = 'toggle',
		name = L["Join only if not already in a Battleground"],
		desc = L["Restricts joining to only when you are not currently in a BG (will still allow you to be in the queue)"],
		get = function() return module.db.profile.restrict end,
		set = function(v) module.db.profile.restrict = v end,
	},
}

function module:OnInitialize()
    self.db = Automaton:AcquireDBNamespace("Queue")
    Automaton:RegisterDefaults("Queue", "profile", {
		disabled = false,
        join = true,
        delay = true,
		restrict = true,
    })
--	Automaton:SetDisabledAsDefault(self, "Queue")
	self:RegisterOptions(self.options)
end

function module:OnEnable()
	if module.db.profile.join then
		module:RegisterEvent("BATTLEFIELDS_SHOW")
	end
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
end

function module:UPDATE_BATTLEFIELD_STATUS()
	local active, confirm, map
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, mapName, instanceID = GetBattlefieldStatus(i)
		if status == "active" then
			active = true
		elseif status == "confirm" then
			confirm = i
			map = mapName .. " " .. instanceID
		end
	end

	if not confirm then return end

	if active and module.db.profile.restrict then return end

	if module.db.profile.delay or active then
		self:Print(L["Joining %s in 1:40..."], map)
		self:ScheduleEvent("Automaton_Queue" .. confirm, AcceptBattlefieldPort, 100, confirm, 1)
	elseif not self:IsEventScheduled("Automaton_Queue" .. confirm) then
		if UnitIsAFK("player") then return end
		self:Print(L["Joining %s..."], map)
		AcceptBattlefieldPort(confirm, 1)
	end
end

function module:BATTLEFIELDS_SHOW()
	if IsPartyLeader() or IsRaidLeader() then
		JoinBattlefield(0, 1)
	else
		JoinBattlefield(0)
	end
	BattlefieldFrame:Hide()
end