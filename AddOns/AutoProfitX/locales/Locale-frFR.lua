local L = AceLibrary("AceLocale-2.2"):new("AutoProfitX")

L:RegisterTranslations("frFR", function() return {
		--commands
		--["/autoprofitx"] = "/autoprofitx",
		["/apx"] = "/apx",
		["options"] = "options",
		["Show options panel."] = "Afficher le panneau d'options.",
		["add"] = "ajout",
		["Add items to global ignore list."] = "Ajouter des objets à la liste d'ignore.",
		["<item link>[<item link>...]"] = "<lien de l'objet>[<lien de l'objet>...]",
		["rem"] = "suppr",
		["Remove items from global ignore list."] = "Enlever des objets de la liste d'ignore.",
		["me"] = "me",
		["Add or remove an item from your exception list."] = "Ajouter ou supprimer des objets de votre liste d'exceptions.",
		["list"] = "liste",
		["List your exceptions."] = "Liste de vos exceptions.",
		
		--options
		["Addon Options"] = "Options de l'addon",
		["Auto Sell"] = "Vente automatique",
		["Automatically sell junk items when opening vendor window."] = "Vendre automatiquement la camelote lorsqu'on ouvre la fenêtre du vendeur.",
		["Sales Reports"] = "Notifier les ventes",
		["Print items being sold in chat frame."] = "Afficher les objets vendus dans la fenêtre de chat.",
		["Show Profit"] = "Afficher les profits",
		["Print total profit after sale."] = "Afficher le total des profits après vente.",
		["Sell Soulbound"] = "Vendre les objets liés",
		["Sell unusable soulbound items."] = "Vendre les objets liés inutilisables.",
		--no longer used
		--["Acquire Unsafe Links"] = "Obtenir les objets non fiables",
		--["Automatically get information about unsafe item links. (CAUTION: may cause you to disconnect when displaying exception list!!!)"] = "Obtenir automatiquement les informations des objets invalides. (ATTENTION: risque de déconnexion lors de l'affichage de la liste d'exceptions !!!)",
		["Button Animation Options"] = "Options d'animation du bouton",
		["Set up when you want the treasure pile in the button to spin."] = "Paramétrage pour que le trésor du bouton tourne",
		["Never spin"] = "Jamais tourner",
		["Mouse-over and profit"] = "Survol de la souris et profits",
		["Mouse-over"] = "Survol de la souris",
		["Profits"] = "Profits",
		["Spin when you mouse-over the button and there is junk to vendor."] = "Tourner lors du survol avec la souris ou qu'il y a des objets à vendre.",
		["Spin every time you mouse over."] = "Tourner lors du survol de la souris.",
		["Spin every time there is junk to sell."] = "Tourner dès qu'il y a des objets à vendre.",
		["Reset Button Pos"] = "RAZ la position du bouton",
		["Reset APX button position on the vendor screen to the top right corner."] = "Réinitialise la position du bouton APX dans la fenêtre du vendeur dans le coin en haut à droite.",
		["Exception List"] = "Liste d'exceptions",
		["Clear Exceptions"] = "Vider les exceptions",
		["Remove all items from exception list."] = "Supprime tous les objets de la liste d'exceptions.",
		["Import Exception List"] = "Importer la liste d'exceptions",
		["Choose character to import exceptions from. Your exceptions will be deleted."] = "Choisir un personnage pour importer sa liste d'exceptions. Les exceptions actuelles seront supprimées.",
		
		--functions
		["Added %s to exception list for all characters."] = "Ajout de %s à la liste d'exceptions pour tous les personnages.", 		--%s is item link
		["Invalid item link provided."] = "Le lien de l'objet fourni est invalide.",
		["Removed %s from all exception lists."] = "Suppression de %s de toutes les listes d'exceptions.",		--%s is item link
		["Removed %s from exception list."] = "Suppression de %s de la liste d'exceptions.",		--%s is item link
		["Added %s to exception list."] = "Ajout de %s à la liste d'exceptions.",		--%s is item link
		["Exceptions:"] = "Exceptions :",
		["Your exception list is empty."] = "La liste d'exception est vide.",
		["Deleted all exceptions."] = "Toutes les exceptions ont été supprimées.",
		["Exception list imported from %s on %s."] = "Liste d'exceptions importée de %s vers %s.",		--first %s - character name, second %s - realm
		["Exception list could not be found for %s on %s."] = "Liste d'exceptions introuvable pour %s vers %s.",		--first %s - character name, second %s - realm
		["Sold %s."] = "Vendu %s.",		--%s - item link
		
		--button functions
		["Total profits: %s"] = "Profits totaux : %s",		--%s is value of all the junk sold
		["Sell Junk Items"] = "Vendre la camelote",
		["You have no junk items in your inventory."] = "Pas de camelote dans l'inventaire.",
		
		--temporary features
		["Update Exception List"] = "MAJ la liste d'exceptions",
		["Update exception list from pre 2.0 AutoProfitX version."] = "Mettre à jour la liste d'exceptions à partir d'une version d'AutoProfitX antérieure à la 2.0 .",
		["Exceptions updated."] = "Liste d'exceptions mise à jour.",
		
		--FeatureFrame
		["OneKey Sell"] = "Raccourci de vente",
		["OneKey sell junk items when opening vendor window"] = "Ce raccourci clavier vend la camelote lorsqu'une fenêtre de vendeur est ouverte.",
		
		--Price
		["g "] = "o",
		["s "] = "a",
		["c"] = "c",
		
		--misc
		["LIST_SEPARATOR"] = ", ",		--separator used to separate words in a list for exmple ", " in rogue, mage, warrior. This is used to split classes listed in the tooltips under Class:
	} end)
