-----------------------------------------------------
-- localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "Meat"
FOM_DIET_FISH					= "Fish"
FOM_DIET_BREAD					= "Bread"
FOM_DIET_CHEESE					= "Cheese"
FOM_DIET_FRUIT					= "Fruit"
FOM_DIET_FUNGUS					= "Fungus"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "Bat"
FOM_BEAR						= "Bear"
FOM_BIRD_OF_PREY				= "Bird of Prey"        	-- WotLK
FOM_BOAR						= "Boar"                	
FOM_CARRION_BIRD				= "Carrion Bird"        	
FOM_CAT							= "Cat"                 	
FOM_CHIMAERA					= "Chimaera"            	-- WotLK exotic
FOM_CORE_HOUND					= "Core Hound"          	-- WotLK exotic
FOM_CRAB						= "Crab"                	
FOM_CROCOLISK					= "Crocolisk"           	
FOM_DEVILSAUR					= "Devilsaur"           	-- WotLK exotic
FOM_DRAGONHAWK					= "Dragonhawk"          	-- BC
FOM_GORILLA						= "Gorilla"             	
FOM_HYENA						= "Hyena"               	
FOM_MOTH						= "Moth"                	-- WotLK exotic
FOM_NETHER_RAY					= "Nether Ray"          	-- BC
FOM_RAPTOR						= "Raptor"              	
FOM_RAVAGER						= "Ravager"             	-- BC
FOM_RHINO						= "Rhino"               	-- WotLK exotic
FOM_SCORPID						= "Scorpid"             	
FOM_SERPENT						= "Serpent"             	-- BC
FOM_SILITHID					= "Silithid"            	-- WotLK exotic
FOM_SPIDER						= "Spider"              	
FOM_SPIRIT_BEAST				= "Spirit Beast"        	-- WotLK exotic
FOM_SPOREBAT					= "Sporebat"            	-- BC
FOM_TALLSTRIDER					= "Tallstrider"         	
FOM_TURTLE						= "Turtle"              	
FOM_WARP_STALKER				= "Warp Stalker"			-- BC
FOM_WASP						= "Wasp"                	-- WotLK
FOM_WIND_SERPENT				= "Wind Serpent"        	
FOM_WOLF						= "Wolf"                	
FOM_WORM						= "Worm"                	-- WotLK exotic

-- From here on down, the localized strings are just for readability... they don't affect whether Feed-O-Matic works.

FOM_BUTTON_TOOLTIP1				= "<Left-Click to feed pet %s>"
FOM_BUTTON_TOOLTIP1_FALLBACK	= "<Alt-Left-Click to feed pet %s>"
FOM_BUTTON_TOOLTIP2				= "<Right-Click for Feed-O-Matic Options>"

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNDER				= "%s doesn't like this anymore."
FOM_QUALITY_WILL				= "%s will eat this."
FOM_QUALITY_LIKE				= "%s likes to eat this."
FOM_QUALITY_LOVE				= "%s loves to eat this."

-- User-visible errors
FOM_ERROR_NO_FOOD				= "Could not find any food in your bags for %s."
FOM_ERROR_NO_FOOD_NO_FALLBACK	= "Could not find any food in your bags for %s that you haven't told Feed-O-Matic to avoid."
FOM_FALLBACK_MESSAGE			= "Hold Alt while pressing the Feed Pet button or key to feed %s anyway."

-- Feeding status messages
FOM_FEEDING_EAT					= "Feeding %s a %s..."
FOM_FEEDING_FEED				= "feeds %s a %s. "

FOM_PET_HUNGRY					= "%s is hungry!"
FOM_PET_VERY_HUNGRY				= "%s is very hungry!"

-- Options panel
FOM_OPTIONS_SUBTEXT				= "To feed your pet with Feed-O-Matic, click the pet happiness icon, bind a key to Feed Pet in the Key Bindings menu, or put '/click FOM_FeedButton' in a macro."

FOM_OPTIONS_TOOLTIP				= "Show food quality in tooltips"
FOM_OPTIONS_LOW_LVL_1ST			= "Prefer lower-level foods"
FOM_OPTIONS_AVOID_QUEST			= "Avoid foods needed for quests"
                            	
FOM_OPTIONS_HEADER_WARNING		= "Warn that pet needs feeding:"
                            	
FOM_OPTIONS_WARN_ICON			= "Flash icon"
FOM_OPTIONS_WARN_TEXT			= "Show text"
FOM_OPTIONS_WARN_SOUND			= "Play sound"
FOM_OPTIONS_SOUND_BELL			= "Generic bell sound"
                            	
FOM_OPTIONS_WARN_LEVEL			= "Warn when pet is:"
FOM_OPTIONS_LEVEL_CONTENT		= "Content"
FOM_OPTIONS_LEVEL_UNHAPPY		= "Unhappy"
FOM_OPTIONS_LEVEL_NONE			= "Don't warn"
                            	
FOM_OPTIONS_FEED_NOTIFY 		= "Notify when feeding:"
FOM_OPTIONS_NOTIFY_EMOTE		= "With an emote"
FOM_OPTIONS_NOTIFY_TEXT			= "In chat window"
FOM_OPTIONS_NOTIFY_NONE			= "Don't notify"

FOM_OPTIONS_FOODS_TITLE			= "Food Preferences"
FOM_OPTIONS_FOODS_TEXT			= "Uncheck individul foods (or food categories) below to prevent Feed-O-Matic from feeding them to your pet. Feed-O-Matic will prefer to use foods from categories closer to the top of the list."

FOM_OPTIONS_FOODS_NAME			= "Food"
FOM_OPTIONS_FOODS_COOKING		= "Cooking Products"

FOM_OPTIONS_FOODS_CONJURED		= "Conjured Foods"
FOM_OPTIONS_FOODS_CONJ_COMBO	= "Conjured Mana Restoring Foods"
FOM_OPTIONS_FOODS_BASIC			= "Basic Foods"
FOM_OPTIONS_FOODS_COMBO			= "Mana Restoring Foods"
FOM_OPTIONS_FOODS_BONUS			= "“Well Fed” Foods"
FOM_OPTIONS_FOODS_INEDIBLE		= "Raw Foods"

FOM_OPTIONS_FOODS_ONLY_PET		= "Only show foods %s will eat"
FOM_OPTIONS_FOODS_ONLY_LVL		= "Only show foods a pet near my level will eat"
FOM_OPTIONS_FOODS_ONLY_INV		= "Only show foods in my inventory"

FOM_DIFFICULTY_HEADER			= "Recipe status:"                            	
FOM_DIFFICULTY_1   				= "Trivial"
FOM_DIFFICULTY_2   				= "Easy"
FOM_DIFFICULTY_3				= "Medium"
FOM_DIFFICULTY_4				= "Difficult"
FOM_DIFFICULTY_5	   			= "Unknown"

------------------------------------------------------

if (GetLocale() == "frFR") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "Viande"
FOM_DIET_FISH					= "Poisson"
FOM_DIET_BREAD					= "Pain"
FOM_DIET_CHEESE					= "Fromage"
FOM_DIET_FRUIT					= "Fruit"
FOM_DIET_FUNGUS					= "Champignon"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "Chauve-souris"
FOM_BEAR						= "Ours"
FOM_BOAR						= "Sanglier"
FOM_CARRION_BIRD				= "Charognard"
FOM_CAT							= "Félin"
FOM_CRAB						= "Crabe"
FOM_CROCOLISK					= "Crocilisque"
FOM_GORILLA						= "Gorille"
FOM_HYENA						= "Hyène"
--FOM_RAPTOR						= "Raptor"				-- same as enUS
FOM_SCORPID						= "Scorpide"
FOM_SPIDER						= "Araignée"
FOM_TALLSTRIDER					= "Haut-trotteur"
FOM_TURTLE						= "Tortue"
FOM_WIND_SERPENT				= "Serpent des vents"
FOM_WOLF						= "Loup"
FOM_DRAGONHAWK					= "Faucon-dragon"			-- BC
FOM_NETHER_RAY					= "Raie du Néant"			-- BC
FOM_RAVAGER						= "Ravageur"				-- BC
--FOM_SERPENT						= "Serpent"				-- BC; same as enUS
FOM_SPOREBAT					= "Sporoptère"				-- BC
FOM_WARP_STALKER				= "Traqueur dimensionnel"	-- BC
-- needs localization
--FOM_BIRD_OF_PREY				= "Bird of Prey"			-- WotLK
--FOM_WASP						= "Wasp"					-- WotLK
--FOM_CHIMAERA					= "Chimaera"				-- WotLK exotic
--FOM_CORE_HOUND					= "Core Hound"				-- WotLK exotic
--FOM_DEVILSAUR					= "Devilsaur"				-- WotLK exotic
--FOM_MOTH						= "Moth"					-- WotLK exotic
--FOM_RHINO						= "Rhino"					-- WotLK exotic
--FOM_SILITHID					= "Silithid"				-- WotLK exotic
--FOM_SPIRIT_BEAST				= "Spirit Beast"			-- WotLK exotic
--FOM_WORM						= "Worm"					-- WotLK exotic

-- From here on down, the localized strings are just for readability... they don't affect whether Feed-O-Matic works.

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNDER				= "%s n'en mange plus désormais."
FOM_QUALITY_WILL				= "%s en mangera."
FOM_QUALITY_LIKE				= "%s aime en manger."
FOM_QUALITY_LOVE				= "%s adore en manger."

-- User-visible errors
FOM_ERROR_NO_FOOD				= "%s n'a pas trouvé de nourriture dans votre sac."

-- Feeding status messages
FOM_FEEDING_EAT					= "%s mange un(e) %s."; 
FOM_FEEDING_FEED				= "donne à %s à manger un(e) %s. "
                        		
FOM_PET_HUNGRY 					= "%s a faim!"
FOM_PET_VERY_HUNGRY				= "%s a très faim!"

end

------------------------------------------------------

if (GetLocale() == "deDE") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "Fleisch"
FOM_DIET_FISH					= "Fisch"
FOM_DIET_BREAD					= "Brot"
FOM_DIET_CHEESE					= "Käse"
FOM_DIET_FRUIT					= "Obst"
--	FOM_DIET_FUNGUS				= "Fungus"					-- same as enUS

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "Fledermaus"
FOM_BEAR						= "Bär"
FOM_BOAR						= "Eber"
FOM_CARRION_BIRD				= "Aasvogel"
FOM_CAT							= "Katze"
FOM_CRAB						= "Krebs"
FOM_CROCOLISK					= "Krokilisk"
--	FOM_GORILLA					= "Gorilla"					-- same as enUS
FOM_HYENA						= "Hyäne"
--	FOM_RAPTOR					= "Raptor"					-- same as enUS
FOM_SCORPID						= "Skorpid"
FOM_SPIDER						= "Spinne"
FOM_TALLSTRIDER					= "Weitschreiter"
FOM_TURTLE						= "Schildkröte"
FOM_WIND_SERPENT				= "Windnatter"
--	FOM_WOLF					= "Wolf"					-- same as enUS
FOM_DRAGONHAWK					= "Drachenfalke"			-- BC
FOM_NETHER_RAY					= "Netherrochen"			-- BC
FOM_RAVAGER						= "Felshetzer"				-- BC
FOM_SERPENT						= "Schlange"				-- BC
FOM_SPOREBAT					= "Sporensegler"			-- BC
FOM_WARP_STALKER				= "Sphärenjäger"			-- BC
-- needs localization
--FOM_BIRD_OF_PREY				= "Bird of Prey"			-- WotLK
--FOM_WASP						= "Wasp"					-- WotLK
--FOM_CHIMAERA					= "Chimaera"				-- WotLK exotic
--FOM_CORE_HOUND					= "Core Hound"				-- WotLK exotic
--FOM_DEVILSAUR					= "Devilsaur"				-- WotLK exotic
--FOM_MOTH						= "Moth"					-- WotLK exotic
--FOM_RHINO						= "Rhino"					-- WotLK exotic
--FOM_SILITHID					= "Silithid"				-- WotLK exotic
--FOM_SPIRIT_BEAST				= "Spirit Beast"			-- WotLK exotic
--FOM_WORM						= "Worm"					-- WotLK exotic

-- From here on down, the localized strings are just for readability; they don't affect whether Feed-O-Matic works.

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNDER				= "%s mag das nicht mehr fressen."
FOM_QUALITY_WILL				= "%s mag das fressen."
FOM_QUALITY_LIKE				= "%s frisst das gerne."
FOM_QUALITY_LOVE				= "%s liebt es, das zu fressen."

-- User-visible errors
FOM_ERROR_NO_FOOD 				= "%s findet nichts zu fressen in Deinem Rucksack."

-- Feeding status messages
FOM_FEEDING_EAT  				= "%s frisst ein %s aus Deinem Rucksack."
FOM_FEEDING_FEED 				= "füttert %s ein %s. "

end

------------------------------------------------------

if (GetLocale() == "esES" or GetLocale() == "esMX") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "Carne"
FOM_DIET_FISH					= "Pescado"
FOM_DIET_BREAD					= "Pan"
FOM_DIET_CHEESE					= "Queso"
FOM_DIET_FRUIT					= "Fruta"
FOM_DIET_FUNGUS					= "Hongo"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "Murciélago"
FOM_BEAR						= "Oso"
FOM_BOAR						= "Jabalí"
FOM_CARRION_BIRD				= "Carroñero"
FOM_CAT							= "Felino"
FOM_CRAB						= "Cangrejo"
FOM_CROCOLISK					= "Crocolisco"
FOM_GORILLA						= "Gorila"
FOM_HYENA						= "Hiena"
--	FOM_RAPTOR					= "Raptor"					-- same as enUS
FOM_SCORPID						= "Escórpido"
FOM_SPIDER						= "Araña"
FOM_TALLSTRIDER					= "Zancaalta"
FOM_TURTLE						= "Tortuga"
FOM_WIND_SERPENT				= "Serpiente alada"
FOM_WOLF						= "Lobo"
FOM_DRAGONHAWK					= "Dracohalcón"				-- BC
FOM_NETHER_RAY					= "Raya abisal"				-- BC
FOM_RAVAGER						= "Devastador"				-- BC
FOM_SERPENT						= "Serpiente"				-- BC
FOM_SPOREBAT					= "Esporiélago"				-- BC
FOM_WARP_STALKER				= "Acechador deformado"		-- BC
-- needs localization
--FOM_BIRD_OF_PREY				= "Bird of Prey"			-- WotLK
--FOM_WASP						= "Wasp"					-- WotLK
--FOM_CHIMAERA					= "Chimaera"				-- WotLK exotic
--FOM_CORE_HOUND					= "Core Hound"				-- WotLK exotic
--FOM_DEVILSAUR					= "Devilsaur"				-- WotLK exotic
--FOM_MOTH						= "Moth"					-- WotLK exotic
--FOM_RHINO						= "Rhino"					-- WotLK exotic
--FOM_SILITHID					= "Silithid"				-- WotLK exotic
--FOM_SPIRIT_BEAST				= "Spirit Beast"			-- WotLK exotic
--FOM_WORM						= "Worm"					-- WotLK exotic

-- From here on down, the localized strings are just for readability; they don't affect whether Feed-O-Matic works.

FOM_BUTTON_TOOLTIP1				= "<Left-Click para alimentar al pet %s>"
FOM_BUTTON_TOOLTIP1_FALLBACK	= "<Alt-Left-Click para Alimentar al pet %s>"
FOM_BUTTON_TOOLTIP2				= "<Right-Click para las opciones de Feed-O-Matic>"

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNDER				= "%s no le gusta."
FOM_QUALITY_WILL				= "%s podria comerlo."
FOM_QUALITY_LIKE				= "%s le gusta comerse esto."
FOM_QUALITY_LOVE				= "%s ama comer esto."

-- User-visible errors
FOM_ERROR_NO_FOOD				= "No fue posible encontrar una comida para %s."
FOM_ERROR_NO_FOOD_NO_FALLBACK	= "No fue posible encontrar ninguna comida en los bags para %s que no hayas dicho a Feed-O-Matic que deba evitar."
FOM_FALLBACK_MESSAGE			= "Presionar Alt mientras presionas el boton de Alimentar Pet o una tecla para alimentar %s de todas formas."

-- Feeding status messages
FOM_FEEDING_EAT					= "Alimentando %s a %s..." 
FOM_FEEDING_FEED				= "Alimentando %s con %s. "

FOM_PET_HUNGRY					= "%s esta hambriento!"
FOM_PET_VERY_HUNGRY				= "%s esta realmente hambriento!"

end

------------------------------------------------------

if (GetLocale() == "ruRU") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "Мясо"
FOM_DIET_FISH					= "Рыба"
FOM_DIET_BREAD					= "Хлеб"
FOM_DIET_CHEESE					= "Сыр"
FOM_DIET_FRUIT					= "Фрукты"
FOM_DIET_FUNGUS					= "Грибы"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "Летучая мышь"
FOM_BEAR						= "Медведь"
FOM_BOAR						= "Вепрь"
FOM_CARRION_BIRD				= "Падальщик"
FOM_CAT							= "Кошка"
FOM_CRAB						= "Краб"
FOM_CROCOLISK					= "Кроколиск"
FOM_GORILLA						= "Горилла"
FOM_HYENA						= "Гиена"
FOM_RAPTOR						= "Ящер"
FOM_SCORPID						= "Скорпид"
FOM_SPIDER						= "Паук"
FOM_TALLSTRIDER					= "Долгоног"
FOM_TURTLE						= "Черепаха"
FOM_WIND_SERPENT				= "Крылатый змей"
FOM_WOLF						= "Волк"
FOM_DRAGONHAWK					= "Дракондор"				-- BC
FOM_NETHER_RAY					= "Скат Пустоты"			-- BC
FOM_RAVAGER						= "Опустошитель"			-- BC
FOM_SERPENT						= "Змей"					-- BC
FOM_SPOREBAT					= "Спороскат"				-- BC
FOM_WARP_STALKER				= "Прыгуана"				-- BC
-- needs localization
--FOM_BIRD_OF_PREY				= "Bird of Prey"			-- WotLK
--FOM_WASP						= "Wasp"					-- WotLK
--FOM_CHIMAERA					= "Chimaera"				-- WotLK exotic
--FOM_CORE_HOUND					= "Core Hound"				-- WotLK exotic
--FOM_DEVILSAUR					= "Devilsaur"				-- WotLK exotic
--FOM_MOTH						= "Moth"					-- WotLK exotic
--FOM_RHINO						= "Rhino"					-- WotLK exotic
--FOM_SILITHID					= "Silithid"				-- WotLK exotic
--FOM_SPIRIT_BEAST				= "Spirit Beast"			-- WotLK exotic
--FOM_WORM						= "Worm"					-- WotLK exotic

-- From here on down, the localized strings are just for readability; they don't affect whether Feed-O-Matic works.
end

------------------------------------------------------

if (GetLocale() == "koKR") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "고기"
FOM_DIET_FISH					= "생선"
FOM_DIET_BREAD					= "빵"
FOM_DIET_CHEESE					= "치즈"
FOM_DIET_FRUIT					= "과일"
FOM_DIET_FUNGUS					= "버섯"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "박쥐"
FOM_BEAR						= "곰"
FOM_BOAR						= "멧돼지"
FOM_CARRION_BIRD				= "독수리"
FOM_CAT							= "살쾡이"
FOM_CRAB						= "게"
FOM_CROCOLISK					= "악어"
FOM_GORILLA						= "고릴라"
FOM_HYENA						= "하이에나"
FOM_OWL							= "올빼미"
FOM_RAPTOR						= "랩터"
FOM_SCORPID						= "전갈"
FOM_SPIDER						= "거미"
FOM_TALLSTRIDER					= "타조"
FOM_TURTLE						= "거북이"
FOM_WIND_SERPENT				= "천둥매"
FOM_WOLF						= "늑대"
FOM_DRAGONHAWK					= "용매"						-- BC
FOM_NETHER_RAY					= "황천의 가오리"					-- BC
FOM_RAVAGER						= "갈퀴발톱"					-- BC
FOM_SERPENT						= "살무사"						-- BC
FOM_SPOREBAT					= "포자날개"					-- BC
FOM_WARP_STALKER				= "차원의 추적자"					-- BC

-- From here on down, the localized strings are just for readability... they don't affect whether Feed-O-Matic works.

FOM_BUTTON_TOOLTIP1				= "<왼쪽 클릭: %s 먹이 주기>"
FOM_BUTTON_TOOLTIP1_FALLBACK	= "<Alt+왼쪽 클릭: %s 먹이 주기>"
FOM_BUTTON_TOOLTIP2				= "<오른 클릭: Feed-O-Matic 옵션>"

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNDER				= "%s도 이런건 안먹겠대요."
FOM_QUALITY_WILL				= "%s 주면 먹긴 할 거에요."
FOM_QUALITY_LIKE				= "%s 입맛에 딱 맞습니다."
FOM_QUALITY_LOVE				= "%s 침 흘리기 시작합니다."

-- User-visible errors
FOM_ERROR_NO_FOOD				= "%s 먹이가 가방에 없는 것 같아요!"
FOM_ERROR_NO_FOOD_NO_FALLBACK	= "Feed-O-Matic에 입력한 %s 금지 먹이가 없습니다."
FOM_FALLBACK_MESSAGE			= "Hold Alt while pressing the Feed Pet button or key to feed %s anyway."

-- Feeding status messages
FOM_FEEDING_EAT					= " %s에게 %s를 먹입니다..."
FOM_FEEDING_FEED				= " %s에게 %s를 먹이며 말합니다. "

FOM_PET_HUNGRY					= "%s 배가 고프답니다"
FOM_PET_VERY_HUNGRY				= "%s 배가 등에 달라 붙었습니다!"

-- Options panel
FOM_OPTIONS_SUBTEXT				= "단축키 메뉴에서 Feed Pet에 키를 지정한 후 누르거나 매크로 '/click FOM_FeedButton'을 만드세요."
                            	
FOM_OPTIONS_TOOLTIP				= "툴팁에 음식 품질 보기"
FOM_OPTIONS_LOW_LVL_1ST			= "낮은 레벨 음식 먼저"
FOM_OPTIONS_OPEN_SLOTS			= "가방 여유 공간 확보"
                            	
FOM_OPTIONS_HEADER_AVOID		= "먹이지 마시오:"
FOM_OPTIONS_AVOID_BONUS			= "“추가효과”가 있는 음식"
FOM_OPTIONS_AVOID_QUEST			= "퀘스트에 쓰이는 음식"
FOM_OPTIONS_AVOID_COOK			= "요리 제작에 필요한 음식"
FOM_OPTIONS_COOK_UNKNOWN		= "미확인 레시피용 저장"
                            	
FOM_DIFFICULTY_RECIPES			= "%s 제조법"	-- "all recipes", "easy recipes", etc. (the key word gets colored.)
FOM_DIFFICULTY_ALL				= "전체"
FOM_DIFFICULTY_GREEN			= "쉬운"
FOM_DIFFICULTY_YELLOW			= "보통"
FOM_DIFFICULTY_ORANGE			= "어려운"
                            	
FOM_OPTIONS_HEADER_WARNING		= "먹이를 먹여야 할때 경고 방식:"
                            	
FOM_OPTIONS_WARN_ICON			= "아이콘 깜박임"
FOM_OPTIONS_WARN_TEXT			= "텍스트 보이기"
FOM_OPTIONS_WARN_SOUND			= "소리 재생"
FOM_OPTIONS_SOUND_BELL			= "일반 종 소리"
                            	
FOM_OPTIONS_WARN_LEVEL			= "펫 상태 경고:"
FOM_OPTIONS_LEVEL_CONTENT		= "만족"
FOM_OPTIONS_LEVEL_UNHAPPY		= "불만족"
FOM_OPTIONS_LEVEL_NONE			= "경고 안함"
                            	
FOM_OPTIONS_FEED_NOTIFY 		= "먹이 줄때 알림:"
FOM_OPTIONS_NOTIFY_EMOTE		= "감정 표현으로"
FOM_OPTIONS_NOTIFY_TEXT			= "채팅창에"
FOM_OPTIONS_NOTIFY_NONE			= "알리지 않음"

end

------------------------------------------------------

if (GetLocale() == "zhTW") then

-- Diet names. These should be the six diets returned from GetPetFoodTypes() and shown in the Pet tab of the character window (when mousing over the happy icon). 
-- (Want to get them all nice and quick for your localization? Go tame a bear or boar... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT					= "肉"
FOM_DIET_FISH					= "魚"
FOM_DIET_BREAD					= "麵包"
FOM_DIET_CHEESE					= "乳酪"
FOM_DIET_FRUIT					= "水果"
FOM_DIET_FUNGUS					= "蘑菇"

-- Beast family names; we use these to provide immersive pet-specific sounds when the pet is hungry. 
-- If not localized, all pets will just play a bell sound when hungry.
FOM_BAT							= "蝙蝠"                       
FOM_BEAR						= "熊"                    
FOM_BOAR						= "野豬"                   
FOM_CARRION_BIRD				= "禿鷹"           
FOM_CAT							= "貓"                        
FOM_CRAB						= "螃蟹"                   
FOM_CROCOLISK					= "鱷魚"               
FOM_GORILLA						= "猩猩"                   
FOM_HYENA						= "土狼"                   
FOM_OWL							= "貓頭鷹"                      
FOM_RAPTOR						= "迅猛龍"                  
FOM_SCORPID						= "蠍子"                   
FOM_SPIDER						= "蜘蛛"                   
FOM_TALLSTRIDER					= "陸行鳥"              
FOM_TURTLE						= "烏龜"                   
FOM_WIND_SERPENT				= "風蛇"           
FOM_WOLF						= "狼"                    
FOM_DRAGONHAWK					= "龍鷹"					-- BC
FOM_NETHER_RAY					= "虛空鰭刺"				-- BC
FOM_RAVAGER						= "破壞者"					-- BC
FOM_SERPENT						= "毒蛇"					-- BC
FOM_SPOREBAT					= "孢子蝙蝠"				-- BC
FOM_WARP_STALKER				= "扭曲行者"				-- BC

end
