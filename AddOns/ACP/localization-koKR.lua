if not ACP then return end

if (GetLocale() == "koKR") then
ACP:UpdateLocale( {
   ["Reload your User Interface?"] = "당신의 사용자 인터페이스를 재시작 하시겠습니까?",
   ["Save the current addon list to [%s]?"] = "현재 애드온 목록을 [%s]로 저장 하시겠습니까?",
   ["Enter the new name for [%s]:"] = "[%s]의 새로운 이름 입력:",
   ["Addons [%s] Saved."] = "애드온 [%s]를 저장합니다.",
   ["Addons [%s] Unloaded."] = "애드온 [%s]를 삭제합니다.",
   ["Addons [%s] Loaded."] = "애드온 [%s]를 불려옵니다.",
   ["Addons [%s] renamed to [%s]."] = "애드온 [%s]를 [%s]로 이름을 변경합니다.",
   ["Loaded on demand."] = "사용시 자동 실행",
   ["AddOns"] = "애드온",
   ["Load"] = "실행",
   ["Disable All"] = "모두 미사용",
   ["Enable All"] = "모두 사용",
   ["ReloadUI"] = "재시작",
   ["Sets"] = "세트",
   ["No information available."] = "알려진 정보가 없습니다.",
   ["Loaded"] = "실행됨",
   
   
   ["Blizzard_AuctionUI"] = "Blizzard: Auction",
   ["Blizzard_BattlefieldMinimap"] = "Blizzard: Battlefield Minimap",
   ["Blizzard_BindingUI"] = "Blizzard: Binding",
   ["Blizzard_CombatText"] = "Blizzard: Combat Text",
   ["Blizzard_CraftUI"] = "Blizzard: Craft",
   ["Blizzard_GMSurveyUI"] = "Blizzard: GM Survey",
   ["Blizzard_InspectUI"] = "Blizzard: Inspect",
   ["Blizzard_ItemSocketingUI"] = "Blizzard: Item Socketing",
   ["Blizzard_MacroUI"] = "Blizzard: Macro",
   ["Blizzard_RaidUI"] = "Blizzard: Raid",
   ["Blizzard_TalentUI"] = "Blizzard: Talent",
   ["Blizzard_TradeSkillUI"] = "Blizzard: Trade Skill",
   ["Blizzard_TrainerUI"] = "Blizzard: Trainer",
} )
end