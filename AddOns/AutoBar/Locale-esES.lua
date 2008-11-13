--
-- AutoBar
-- http://code.google.com/p/autobar/
-- Spanish translation by shiftos
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("esES", function() return {
		["AUTOBAR"] = "AutoBar",
		["CONFIG_WINDOW"] = "Ventana de Configuraci\195\179n",
		["SLASHCMD_LONG"] = "/autobar",
		["SLASHCMD_SHORT"] = "/atb",
		["BUTTON"] = "Bot\195\179n",
		["EDITSLOT"] = "Editar Casilla",
		["VIEWSLOT"] = "Ver Casilla",
		["LOAD_ERROR"] = "|cff00ff00Error al cargar AutoBarConfig. Aseg\195\186rate de que lo tienes instalado y activado.|r Error: ",
		["Toggle the config panel"] = "Toggle the config panel",

		--  AutoBarConfig.lua
		["EMPTY"] = "Vac\195\173o"; --AUTOBAR_CONFIG_EMPTY
		["STYLE"] = "Estilo",
		["STYLE_TIP"] = "Cambia el estilo de la barra",
		["DEFAULT"] = "Por defecto",
		["ZOOMED"] = "Agrandado",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "Desactivar Autolanzado con ClicDerecho";
		["AUTOBAR_CONFIG_REMOVECAT"] = "Eliminar la Categor\195\173a Actual";
		["AUTOBAR_CONFIG_ROW"] = "Filas";
		["AUTOBAR_CONFIG_COLUMN"] = "Columnas";
		["AUTOBAR_CONFIG_GAPPING"] = "Espacio entre Iconos";
		["AUTOBAR_CONFIG_ALPHA"] = "Transparencia de Iconos";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "Anchura del Bot\195\179n";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "Altura del Bot\195\179n";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "Mover ancla horizontalmente";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "Mover ancla verticalmente";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "Altura del Bot\195\179n\ny Anchura Desbloqueados";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "Ocultar el texto de la\ntecla asignada";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "Ocultar el Texto del\nContador";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "Mostrar los Botones Vac\195\173os";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "Mostrar Iconos de Categorias";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "Ocultar los Tooltips";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "Direcci\195\179n\nde la ventana emergente\nde los botones";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "Ventana emergente con tecla de\nMay\195\186sculas";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "Ocultar Manilla de Arrastre";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "Estrato de Marco Alto";
		["AUTOBAR_CONFIG_CTRLSHOWSDRAGHANDLE"] = "La tecla Ctrl muestra la Manilla de Arrastre";
		["AUTOBAR_CONFIG_LOCKACTIONBARS"] = "Bloquear las Barras de Acci\195\179n\ncuando se bloquea Autobar";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "Botones Planos";
		["AUTOBAR_CONFIG_NOPOPUP"] = "Sin Ventana Emergente";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "Reajustar el orden al usar";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "Clic-Derecho cambia objetivo a la Mascota";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "Ninguno";
		["AUTOBAR_CONFIG_BT3BAR"] = "Barra de BarTender3 ";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "Men\195\186 Principal";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "Ventana de Chat";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "Men\195\186 de la Ventana de Chat";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "Barra de Acci\195\179n";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "Men\195\186 de Botones";
		["AUTOBAR_CONFIG_ALIGN"] = "Alinear Botones";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(No encontrado: Objeto ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " Capa (clic para editar)";
		["AUTOBAR_CONFIG_CHARACTER"] = "Personaje";
		["AUTOBAR_CONFIG_SHARED"] = "Compartido";
		["AUTOBAR_CONFIG_CLASS"] = "Clase";
		["AUTOBAR_CONFIG_BASIC"] = "B\195\161sico";
		["AUTOBAR_CONFIG_USECHARACTER"] = "Usar la capa de Personaje";
		["AUTOBAR_CONFIG_USESHARED"] = "Usar la capa Compartida";
		["AUTOBAR_CONFIG_USECLASS"] = "Usar la capa de Clase";
		["AUTOBAR_CONFIG_USEBASIC"] = "Usar la capa B\195\161sica";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "Ocultar los Tooltips de\nConfiguraci\195\179n";
		["AUTOBAR_CONFIG_OSKIN"] = "Usar oSkin";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "Log Performance";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "Distribuci\195\179n de Personaje";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "Distribuci\195\179n de Compartido";
		["AUTOBAR_CONFIG_SHARED1"] = "Compartido 1";
		["AUTOBAR_CONFIG_SHARED2"] = "Compartido 2";
		["AUTOBAR_CONFIG_SHARED3"] = "Compartido 3";
		["AUTOBAR_CONFIG_SHARED4"] = "Compartido 4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "Editar la capa de\nPersonaje";
		["AUTOBAR_CONFIG_EDITSHARED"] = "Editar la capa\nCompartida";
		["AUTOBAR_CONFIG_EDITCLASS"] = "Editar la capa de Clase";
		["AUTOBAR_CONFIG_EDITBASIC"] = "Editar la capa B\195\161sica";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "Fuegos artificiales",
		["Tradeskill.Tool.Fishing.Lure"] = "Cebos de Pesca",
		["Tradeskill.Tool.Fishing.Gear"] = "Equipo de Pesca",
		["Tradeskill.Tool.Fishing.Tool"] = "Ca\195\177as de Pescar",

		["Consumable.Food.Bonus"] = "Comida: Bonificaci\195\179n";
		["Consumable.Food.Buff.Strength"] = "Comida: Bonificaci\195\179n de Fuerza";
		["Consumable.Food.Buff.Agility"] = "Comida: Bonificaci\195\179n de Agilidad";
		["Consumable.Food.Buff.Attack Power"] = "Food: Attack Power Bonus";
		["Consumable.Food.Buff.Healing"] = "Food: Healing Bonus";
		["Consumable.Food.Buff.Spell Damage"] = "Food: Spell Damage Bonus";
		["Consumable.Food.Buff.Stamina"] = "Comida: Bonificaci\195\179n de Aguante";
		["Consumable.Food.Buff.Intellect"] = "Comida: Bonificaci\195\179n de Inteligencia";
		["Consumable.Food.Buff.Spirit"] = "Comida: Bonificaci\195\179n de Esp\195\173ritu";
		["Consumable.Food.Buff.Mana Regen"] = "Comida: Bonificaci\195\179n de Regeneraci\195\179n de Man\195\161";
		["Consumable.Food.Buff.HP Regen"] = "Comida: Bonificaci\195\179n de Regeneraci\195\179n de Salud";
		["Consumable.Food.Buff.Other"] = "Comida: Otros";

		["Consumable.Buff.Health"] = "Buff de Health";
		["Consumable.Buff.Armor"] = "Buff de Armor";
		["Consumable.Buff.Regen Health"] = "Buff de Regen Health";
		["Consumable.Buff.Agility"] = "Buff de Agility";
		["Consumable.Buff.Intellect"] = "Buff de Intellect";
		["Consumable.Buff.Protection"] = "Buff de Protection";
		["Consumable.Buff.Spirit"] = "Buff de Spirit";
		["Consumable.Buff.Stamina"] = "Buff de Stamina";
		["Consumable.Buff.Strength"] = "Buff de Strength";
		["Consumable.Buff.Attack Power"] = "Buff de Potencia de Ataque";
		["Consumable.Buff.Attack Speed"] = "Buff de Velocidad de Ataque";
		["Consumable.Buff.Dodge"] = "Buff de Esquiva";
		["Consumable.Buff.Resistance"] = "Buff de Resistance";

		["Consumable.Buff Group.General.Self"] = "Buff: General";
		["Consumable.Buff Group.General.Target"] = "Buff: General Target";
		["Consumable.Buff Group.Caster.Self"] = "Buff: Caster";
		["Consumable.Buff Group.Caster.Target"] = "Buff: Caster Target";
		["Consumable.Buff Group.Melee.Self"] = "Buff: Melee";
		["Consumable.Buff Group.Melee.Target"] = "Buff: Melee Target";
		["Consumable.Buff.Other.Self"] = "Buff: Other";
		["Consumable.Buff.Other.Target"] = "Buff: Other Target";
		["Consumable.Buff.Chest"] = "Buff: Chest";
		["Consumable.Buff.Shield"] = "Buff: Shield";
		["Consumable.Weapon Buff"] = "Buff: Weapon";

		["Consumable.Quest.Usable"] = "Objetos de Misi\195\179n";

		["Consumable.Potion.Recovery.Healing.Basic"] = "Pociones de Curaci\195\179n";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "Heal Potions: Blades Edge";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "Heal Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Healing.PvP"] = "Pociones de Salud de Campos de Batalla";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "Heal Potions: Tempest Keep";
		["Consumable.Potion.Recovery.Mana.Basic"] = "Pociones de Man\195\161";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "Mana Potions: Blades Edge";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "Mana Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "Pociones de Campos de Batalla";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "Mana Potions: Tempest Keep";

		["Consumable.Weapon Buff.Poison.Crippling"] = "Veneno de Ralentizaci\195\179n";  -- check
		["Consumable.Weapon Buff.Poison.Deadly"] = "Veneno Mortal";
		["Consumable.Weapon Buff.Poison.Instant"] = "Veneno Instant\195\161neo";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "Veneno de entumecimiento mental";   -- check
		["Consumable.Weapon Buff.Poison.Wound"] = "Veneno Hiriente";                  -- check
		["Consumable.Weapon Buff.Oil.Mana"] = "Aceite de encantamiento: Regeneraci\195\179n de Man\195\161";
		["Consumable.Weapon Buff.Oil.Wizard"] = "Aceite de encantamiento: Bonificaci\195\179n a Da\195\177o/Curaci\195\179n";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "Piedras de afilar creadas por Herrero";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "Piedras de peso creadas por Herrero";

		["Consumable.Bandage.Basic"] = "Vendas";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "Vendas de Alterac";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "Vendas de Grito de Guerra";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "Vendas de Arathi";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "Comida: Sin Bonificaci\195\179n";
		["Consumable.Food.Percent.Basic"] = "Comida: % aumento de salud";
		["Consumable.Food.Percent.Bonus"] = "Comida: % Regeneraci\195\179n de Salud (buff de bien alimentado)";
		["Consumable.Food.Combo Percent"] = "Comida: % aumento de salud y man\195\161";
		["Consumable.Food.Combo Health"] = "Combinaci\195\179n de Comida y Agua";
		["Consumable.Food.Edible.Bread.Conjured"] = "Comida: Conjurada por Mago";
		["Consumable.Food.Conjure"] = "Conjure Food";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "Comida: Cuenca de Arathi";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "Comida: Garganta Grito de Guerra";

		["Consumable.Food.Pet.Bread"] = "Comida: Pan para Mascota";
		["Consumable.Food.Pet.Cheese"] = "Comida: Queso para Mascota";
		["Consumable.Food.Pet.Fish"] = "Comida: Pescado para Mascota";
		["Consumable.Food.Pet.Fruit"] = "Comida: Fruta para Mascota";
		["Consumable.Food.Pet.Fungus"] = "Comida: Hongo para Mascota";
		["Consumable.Food.Pet.Meat"] = "Comida: Carne para Mascota";

		["AUTOBAR_CLASS_CUSTOM"] = "Personalizado";
		["Misc.Minipet.Normal"] = "Mascota";
		["Misc.Minipet.Snowball"] = "Mascota de Festividad";
		["AUTOBAR_CLASS_CLEAR"] = "Limpiar esta Casilla";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "Un'Goro: Cristal de Recuperaci\195\179n";

		["Consumable.Anti-Venom"] = "Anti-Veneno";

		["Consumable.Warlock.Healthstone"] = "Piedras de Salud";
		["Consumable.Warlock.Create Healthstone"] = "Create Healthstone";
		["Consumable.Mage.Mana Stone"] = "Piedras de Man\195\161";
		["Consumable.Mage.Conjure Mana Stone"] = "Conjure Manastones";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "Poci\195\179n de letargo sin sueños";
		["Consumable.Potion.Recovery.Rejuvenation"] = "Pociones de Rejuvenecimiento";
		["Consumable.Jeweler.Statue"] = "Est\195\161tuas de piedra";

		["Misc.Battle Standard.Battleground"] = "Estandarte de Batalla";
		["Misc.Battle Standard.Alterac Valley"] = "Estandarte de Batalla VdA";
		["Consumable.Recovery.Rune"] = "Runas Oscuras y Demon\195\173acas";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "Protecci\195\179n contra arcano";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "Protecci\195\179n contra Fuego";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "Protecci\195\179n contra Escarcha";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "Protecci\195\179n contra Naturaleza";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "Protecci\195\179n contra Sombra";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "Protecci\195\179n contra Hechizo";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "Protecci\195\179n contra Sagrado";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "Pociones de Invulnerabilidad";
		["Consumable.Buff.Free Action"] = "Poci\195\179n de Acci\195\179n Libre";

		["AUTOBAR_CLASS_PORTALS"] = "Portals and Teleports";
		["Misc.Hearth"] = "Piedra de hogar";
		["Misc.Booze"] = "Alcohol";
		["Consumable.Water.Basic"] = "Agua";
		["Consumable.Water.Percentage"] = "Agua: % aumento de man\195\161";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "Agua: Conjurada por Mago";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "Conjure Water";
		["Consumable.Water.Buff.Spirit"] = "Agua: Bonificaci\195\179n de Esp\195\173ritu";
		["Consumable.Buff.Rage.Self"] = "Pociones de Rabia";
		["Consumable.Buff.Energy.Self"] = "Pociones de Energ\195\173a";
		["Consumable.Buff.Speed"] = "Pociones de Velocidad";
		["AUTOBAR_CLASS_SOULSHARDS"] = "Fragmentos de Alma";
		["Reagent.Ammo.Arrow"] = "Flechas";
		["Reagent.Ammo.Bullet"] = "Balas";
		["Reagent.Ammo.Thrown"] = "Armas Arrojadizas";
		["Misc.Engineering.Explosives"] = "Explosivos de Ingenier\195\173a";
		["Misc.Mount.Normal"] = "Monturas";
		["Misc.Mount.Summoned"] = "Monturas: Summoned";
		["Misc.Mount.Ahn'Qiraj"] = "Monturas: Qiraji";
		["Misc.Mount.Flying"] = "Monturas: Flying";

	}
end);


if (GetLocale() == "esES") then

AUTOBAR_CHAT_MESSAGE1 = "La configuraci\195\179n para este personaje es de una versi\195\179n anterior. Borrando. No se intentar\195\161 actualizar la configuraci\195\179n actual.";
AUTOBAR_CHAT_MESSAGE2 = "Actualizando el bot\195\179n de multi-objetos #%d objeto #%d para usar el itemid en vez del nombre del objeto.";
AUTOBAR_CHAT_MESSAGE3 = "Actualizando el bot\195\179n de objeto \195\186nico #%d para usar el itemid en vez del nombre del objeto.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "Para editar una casilla selecci\195\179nala en la secci\195\179n Edici\195\179n de casillas\nen la parte baja de la pesta\195\177a de Casillas";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "Vista de Capa Combinada (no editable) ";
AUTOBAR_CONFIG_RESET = "Reestablecer";
AUTOBAR_CONFIG_REVERT = "Revertir";
AUTOBAR_CONFIG_DONE = "Hecho";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Clic+May\195\186sculas para explorar la Categor\195\173a)";
AUTOBAR_CONFIG_DRAGHANDLE = "Clic-Izquierdo+Arrastrar para mover AutoBar\nClic-izquierdo para Bloquearlo / Desbloquearlo\nClic-Derecho para las opciones";
AUTOBAR_CONFIG_EMPTYSLOT = "Casilla Vac\195\173a";
AUTOBAR_CONFIG_CLEARSLOT = "Limpiar Casilla";
AUTOBAR_CONFIG_SETSHARED = "Perfil Compartido:";
AUTOBAR_CONFIG_SETSHAREDTIP = "Elige el perfil compartido que usar\195\161 este personaje.\nLos cambios a un perfil compartido afectar\195\161n a todos los personajes que lo usen";

AUTOBAR_CONFIG_TAB_SLOTS = "Casillas";
AUTOBAR_CONFIG_TAB_BAR = "Barra";
AUTOBAR_CONFIG_TAB_BUTTONS = "Botones";
AUTOBAR_CONFIG_TAB_POPUP = "Vent. Emergente";
AUTOBAR_CONFIG_TAB_PROFILE = "Perfil";
AUTOBAR_CONFIG_TAB_KEYS = "Teclas";

AUTOBAR_TOOLTIP1 = " (Cantidad: ";
AUTOBAR_TOOLTIP2 = " [Objeto Personalizado]";
AUTOBAR_TOOLTIP4 = " [Solo Campos de Batalla]";
AUTOBAR_TOOLTIP5 = " [Solo Sin Combate]";
AUTOBAR_TOOLTIP6 = " [Uso Limitado]";
AUTOBAR_TOOLTIP7 = " [Enfriamiento]";
AUTOBAR_TOOLTIP8 = "\n(Clic-Izquierdo para aplicar como arma de la mano principal\nClic-Derecho para aplicar como arma de la mano secundaria)";

AUTOBAR_CONFIG_DOCKTO = "Anclado a:";
AUTOBAR_CONFIG_USECHARACTERTIP = "Los objetos de la capa de Personaje son espec\195\173ficos para este personaje.";
AUTOBAR_CONFIG_USESHAREDTIP = "Los objetos de la capa Compartida son compartidos con otros personajes que tambi\195\169n usan la misma capa Compartida\nLa capa espec\195\173fica puede ser elegida en la pesa\195\177a de Perfil.";
AUTOBAR_CONFIG_USECLASSTIP = "Los objetos de la capa de Clase son compartidos por todos los personajes de la misma clase que usan la capa de Clase.";
AUTOBAR_CONFIG_USEBASICTIP = "Los objetos de la capa B\195\161sica son compartidos por todos los personajes que usan la capa B\195\161sica.";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "Los cambios a la distribuci\195\179n visual solo afectan a este personaje.";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "Los cambios a la distribuci\195\179n visual afectan a todos los personajes que usan el mismo perfil compartido.";
AUTOBAR_CONFIG_TIPOVERRIDE = "Los objetos en una casilla de esta capa se superpondr\195\161n a los objetos de esta casilla en capas inferiores.\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "Los objetos en una casilla de esta capa ser\195\161n superpuestos por objetos de capas superiores.\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "Los cambios afectan solo a este personaje.";
AUTOBAR_CONFIG_TIPAFFECTSALL = "Los cambios afectan a todos los personajes.";
AUTOBAR_CONFIG_SETUPSINGLE = "Configuraci\195\179n \195\154nica";
AUTOBAR_CONFIG_SETUPSHARED = "Configuraci\195\179n Compartida";
AUTOBAR_CONFIG_SETUPSTANDARD = "Configuraci\195\179n Est\195\161ndar";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "Desde cero";
AUTOBAR_CONFIG_SETUPSINGLETIP = "Clic para una configuraci\195\179n de personaje \195\186nico similar al AutoBar cl\195\161sico.";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "Clic para una configuraci\195\179n compartida.\nPermite tanto capas de un personaje en particular como capas compartidas";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "Activa la edici\195\179n y uso de todas las capas.";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "Limpia las casillas compartidas y de personaje.";
AUTOBAR_CONFIG_RESETSINGLETIP = "Clic para reestablecer la configuraci\195\179n por defecto de Personaje \195\154nico.";
AUTOBAR_CONFIG_RESETSHAREDTIP = "Clic para reestablecer la configuraci\195\179n por defecto de los Personajes Compartidos.\nLas casillas de clase son copiadas a la capa de Personaje.\nLas casillas por defecto son copiadas a la capa Compartida.";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "Pulsa para reestablecer la configuraci\195\179n est\195\161ndar.\nLas casillas de clase se colocan en la capa de Clase.\nLas casillas por defecto son colocadas en la capa B\195\161sica.\nLas capas de Personaje y Compartido son limpiadas.";

--  AutoBarConfig.lua
AUTOBAR_TOOLTIP9 = "Bot\195\179n Multi Categor\195\173a\n";
AUTOBAR_TOOLTIP10 = " (Objeto Personalizado por ID)";
AUTOBAR_TOOLTIP11 = "\n(ID de objeto no reconocida)";
AUTOBAR_TOOLTIP12 = " (Objeto Personalizado por Nombre)";
AUTOBAR_TOOLTIP13 = "Bot\195\179n de Categor\195\173a \195\154nica\n\n";
AUTOBAR_TOOLTIP14 = "\nNo usable de forma directa.";
AUTOBAR_TOOLTIP15 = "\nArma Objetivo\n(Clic-Izquierdo arma principal\nClic-Derecho arma secundaria.)"; -- check
AUTOBAR_TOOLTIP16 = "\nSeleccionado.";
AUTOBAR_TOOLTIP17 = "\nSolo sin combate.";
AUTOBAR_TOOLTIP18 = "\nSolo en combate.";
AUTOBAR_TOOLTIP19 = "\nLugar: ";
AUTOBAR_TOOLTIP20 = "\nUso Limitado: "
AUTOBAR_TOOLTIP21 = "Requiere Recuperaci\195\179n de Salud";
AUTOBAR_TOOLTIP22 = "Requiere Recuperaci\195\179n de Man\195\161";
AUTOBAR_TOOLTIP23 = "Bot\195\179n de Objeto \195\154nico\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "Valle de Alterac";
--AUTOBAR_WARSONGGULCH = "Garganta Grito de Guerra";
--AUTOBAR_ARATHIBASIN = "Cuenca de Arathi";
--AUTOBAR_AHN_QIRAJ = "Ahn'Qiraj";

end