local abacus = AceLibrary("Abacus-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Automaton_Repair")
Automaton_Repair = Automaton:NewModule("Repair", "AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")
local module = Automaton_Repair

L:RegisterTranslations("enUS", function() return {
	["Repair"] = true,
	["Automatically repair all inventory items when at merchant"] = true,
	["Repairing all items for: %s"] = true,
	["You cannot afford to repair. Go farm you poor newbie."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Repair"] = "아이템 수리",
	["Automatically repair all inventory items when at merchant"] = "상인에게 모든 아이템을 자동으로 수리합니다.",
	["Repairing all items for: %s"] = "모든 아이템 수리: %s",
	["You cannot afford to repair. Go farm you poor newbie."] = "당신은 아이템 수리를 할 수 없습니다. 돈이 부족합니다.",
} end)

L:RegisterTranslations("esES", function() return {
	["Repair"] = "Reparar",
	["Automatically repair all inventory items when at merchant"] = "Repara autom\195\161ticamente todos tus objetos del inventario cuando est\195\161s en un vendedor",
	["Repairing all items for: %s"] = "Reparando todos los objetos por: %s",
	["You cannot afford to repair. Go farm you poor newbie."] = "No tienes suficiente dinero para la reparaci\195\179n",

} end)

L:RegisterTranslations("zhTW", function() return {
	["Repair"] = "自動修裝",
	["Automatically repair all inventory items when at merchant"] = "自動修理裝備",
	["Repairing all items for: %s"] = "此次共修理了 : %s",
	["You cannot afford to repair. Go farm you poor newbie."] = "你身上沒有組購的修裝費用!",

} end)

module.description = L["Automatically repair all inventory items when at merchant"]
module.options = {
}

function module:OnInitialize()
	self:RegisterOptions(self.options)
end

function module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
end

function Automaton_Repair:MERCHANT_SHOW()
	if not CanMerchantRepair() then return end
	local repairCost = GetRepairAllCost()
	local totalMoney = GetMoney()
	if totalMoney <= repairCost then
		self:Print(L["You cannot afford to repair. Go farm you poor newbie."])
		return
	end
	if repairCost > 0 then
		self:Print(L["Repairing all items for: %s"], abacus:FormatMoneyFull(repairCost, true))
		if not self:IsDebugging() then
			RepairAllItems()
		end
	end
end