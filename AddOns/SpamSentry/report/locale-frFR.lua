local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

L:RegisterTranslations("frFR", function() return {
  -- Messages
  ["Blocked messages:"] = "Message(s) bloqu\195\169(s):",
  ["No blocked messages"] = "Il n'y a pas messages bloqu\195\169s.",
  ["%s has been removed"] = "Le message de %s \195\160 \195\169t\195\169 effac\195\169.|r",
  ["Reportlist cleared (%s items)"] = "La liste est vid\195\169e. (%s messages)",
  ["You already have a ticket pending"] = "Il y a d\195\169j\195\160 une requ\195\170te MJ en cours.",
  ["Nothing to report"] = "Rien \195\160 rapporter.",
  ["Farming:"] = "Farming:",
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = "Editez le texte de votre message",
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000Attention: V\195\169rifiez le rapport avant de l'envoyer!|r",
  ["SSGUITICKETHELP"] = "Copy this text and paste it into your ticket.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "Editer le texte du message. '%s' peut \195\170tre remplac\195\169 par votre nom.",
  ["SSGUIHELP_FEEDBACK"] = "Copiez le texte et envoyez-le \195\160 l'auteur de ce mod.",
  ["[Items on reportlist: %s]"] = "[Items on reportlist: %s]",
  ["Message:"] = "Message:",

  --GUI tooltip
  ["Date / time"] = "Date / time",
  ["Channel"] = "Channel",
  ["Message-ID"] = "Message-ID",
  ["Click to copy message\n<CTRL>-Click to remove message"] = "Click to copy message\n<CTRL>-Click to remove message",
  
  -- No reply
  ["[NO REPLY NEEDED]"] = "[NO REPLY NEEDED]",
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_frFR =  "Cher MJ,\n\nLes actes et les trajets de ces personnages me semblent \195\170tre des actes automatiques/script\195\169s. Je souhaite donc rapporter son comportement.\n\nSalutations,\n\n%s\n---\n";
SPAMSENTRY_RPTEXT_frFR =   "Cher MJ,\n\nLe(s) personnage(s) suivant(s) a(ont) un nom qui viole La Charte des Noms si on s'en r\195\169f\195\168re aux Conditions d'Utilisation de World of Warcraft. J'esp\195\168re que vous \195\169tudirez ma requ\195\168te et prendrez une mesure appropri\195\169e.\n\nSalutations,\n\n%s\n---\n" 
