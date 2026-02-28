/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/
/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female, roundstart = FALSE, female_same = FALSE)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()

	for(var/datum/sprite_accessory/accessory as anything in subtypesof(prototype))
		if(IS_ABSTRACT(accessory))
			continue

		accessory = new accessory()

		if(roundstart && accessory.locked)
			continue

		L[accessory.name] = accessory

		if(accessory.gender == MALE)
			male[accessory.name] = accessory
			if(female_same)
				female[accessory.name] = accessory
		else if(accessory.gender == FEMALE)
			female[accessory.name] = accessory
		else
			male[accessory.name] = accessory
			female[accessory.name] = accessory

/datum/sprite_accessory
	var/use_static		//determines if the accessory will be skipped by color preferences
	var/locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects
	var/list/specuse = list(SPEC_ID_HUMEN) //what species can use dis
	var/additional = FALSE //added hairbands/metal in hair/beards
	var/roundstart = TRUE
	var/under_layer = FALSE

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/body_markings/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"

/datum/sprite_accessory/body_markings/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"

/datum/sprite_accessory/body_markings/lbelly
	name = "Light Belly"
	icon_state = "lbelly"

/datum/sprite_accessory/snouts
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/frills
	icon = 'icons/mob/mutant_bodyparts.dmi'
	abstract_type = /datum/sprite_accessory/frills
	icon = 'modular_rmh/icons/mob/sprite_accessory/frills/frills.dmi'
	color_key_name = "Frills"
	relevant_layers = list(BODY_ADJ_LAYER)

/datum/sprite_accessory/frills/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	return is_human_part_visible(owner, HIDEEARS|HIDEHAIR)

/datum/sprite_accessory/frills/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_FACE)

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/simpledualcolor
	name = "Simple - Dual Color"
	icon_state = "m_frills_simple"
	color_keys = 2
	color_key_names = list("Outer", "Inner")

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/shortdualcolor
	name = "Short - Dual Color"
	icon_state = "m_frills_short"
	color_keys = 2
	color_key_names = list("Outer", "Inner")

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/frills/aquaticdualcolor
	name = "Aquatic - Dual Color"
	icon_state = "m_frills_aqua"
	color_keys = 2
	color_key_names = list("Outer", "Inner")

/datum/sprite_accessory/frills/divinity
	name = "Divinity"
	icon_state = "divinity"

/datum/sprite_accessory/frills/horns
	name = "Horns"
	icon_state = "horns"

/datum/sprite_accessory/frills/horns_double
	name = "Horns Double"
	icon_state = "hornsdouble"

/datum/sprite_accessory/frills/big
	name = "Big"
	icon_state = "big"

/datum/sprite_accessory/frills/cobrahood
	name = "Cobra Hood"
	icon_state = "cobrahood"
	color_keys = 2
	color_key_names = list("Hood", "Inner")

/datum/sprite_accessory/frills/cobrahood_ears
	name = "Cobra Hood (Ears)"
	icon_state = "cobraears"
	color_keys = 2
	color_key_names = list("Hood", "Inner")

/datum/sprite_accessory/frills/split
	name = "Split"
	icon_state = "split"

/datum/sprite_accessory/frills/split_big
	name = "Split (Big)"
	icon_state = "split_big"

/datum/sprite_accessory/frills/split_slim
	name = "Split (Slim)"
	icon_state = "split_slim"

/datum/sprite_accessory/frills/earlike
	name = "Earlike"
	icon_state = "earlike"
	color_keys = 2
	color_key_names = list("Outer", "Inner")

/datum/sprite_accessory/frills/earlike_thick
	name = "Earlike (Thick)"
	icon_state = "earlike_thick"

/datum/sprite_accessory/frills/earlike_angled
	name = "Earlike (Angled)"
	icon_state = "earlike_angled"

/datum/sprite_accessory/spines
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/spines_animated
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/spines/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/spines_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines_animated/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines_animated/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines_animated/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines_animated/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines_animated/aqautic
	name = "Aquatic"
	icon_state = "aqua"


/datum/sprite_accessory/legs 	//legs are a special case, they aren't actually sprite_accessories but are updated with them.
	icon = null					//These datums exist for selecting legs on preference, and little else

/datum/sprite_accessory/legs/none
	name = "Normal Legs"

/datum/sprite_accessory/caps
	icon = 'icons/mob/mutant_bodyparts.dmi'
	color_key_defaults = list(KEY_HAIR_COLOR)

/datum/sprite_accessory/caps/round
	name = "Round"
	icon_state = "round"
