local L = AceLibrary("AceLocale-2.2"):new("SS_Bot")

L:RegisterTranslations("frFR", function() return {
  -- Bot message
  ["%s has been added to the reportlist"] = "Le message de %s a \195\169t\195\169 ajout\195\169 au rapport.",
  ["Type a name or select a player to mark as bot"] = "Entrez un nom ou s\195\169lectionnez un joueur pour le signaler comme robot.",
  ["Type a name or select the mob this bot is farming"] = "Tapez un nom ou selectionnez un monstre que ce robot farm", 
  ["farming:"] = "farming:",
  ["%s has been reported before"] = "%s a d\195\169j\195\160 \195\169t\195\169 rapport\195\169 en tant que robot.",
  ["%s has been removed"] = "Le message de %s \195\160 \195\169t\195\169 effac\195\169.|r",
  ["Reportlist cleared (%s items)"] = "La liste est vid\195\169e. (%s messages)",
  ["Marked bots"] = "Liste des joueurs marqu\195\169s comme robots",
  ["No marked bots"] = "Il n'y a pas robots rapport\195\169s.",
} end )