local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

L:RegisterTranslations("esES", function() return {
  -- Messages
  ["Blocked messages:"] = "Mensajes bloqueados:",
  ["No blocked messages"] = "No hay mensajes bloqueados",
  ["%s has been removed"] = "El mensaje de %s borrado",
  ["Reportlist cleared (%s items)"] = "La lista de informes ha sido borrada",
  ["You already have a ticket pending"] = "A\195\186n tienes una consulta abierta...",
  ["Nothing to report"] = "Nada de lo que informar",
  ["Farming:"] = "Farming:",
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = "Edit the text for your ticket",
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000AVISO: \194\161Comprueba BIEN los personajes antes de informar sobre ellos!|r",
  ["SSGUITICKETHELP"] = "Copy this text and paste it into your ticket.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "Edit ticket text. '%s' will be replaced with your name.",
  ["SSGUIHELP_FEEDBACK"] = "Copy this sequence and submit it to the mod-author.",
  ["[Items on reportlist: %s]"] = "[Items on reportlist: %s]",
  ["Message:"] = "Message:",

  --GUI tooltip
  ["Date / time"] = "Date / time",
  ["Channel"] = "Channel",
  ["Message-ID"] = "Message-ID",
  ["Click to copy message\n<CTRL>-Click to remove message"] = "Click to copy message\n<CTRL>-Click to remove message",
  
  -- No reply
  ["[NO REPLY NEEDED]"] = "[NO ES NECESARIO CONTACTAR CONMIGO]",
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_esES =  "Estimado Maestro de Juego,\n\nLa forma en que el personaje actuaba y se mov\195\173a parec\195\173a estar automatizada. Es por ello que quiero denunciar a este jugador porque posiblemente sea un bot.\n\nSaludos,\n\n%s\n---\n";
SPAMSENTRY_RPTEXT_esUS =   "Dear GM,\n\nThe following character(s) have a name that violates the naming policy. I hope you will investigate the matter and take appropriate action.\n\nBest regards,\n\n%s\n---\n"
