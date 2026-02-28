/datum/sprite_accessory/wings
	abstract_type = /datum/sprite_accessory/wings
	icon = 'modular_rmh/icons/mob/sprite_accessory/wings/wings.dmi'
	color_key_name = "Wings"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)
	/// Whether the sprite accessory has states for open wings (With an "_open" suffix).
	var/can_open = FALSE

/datum/sprite_accessory/wings/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_BACK)

/datum/sprite_accessory/wings/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(!owner || !can_open)
		return ..()
	var/obj/item/organ/wings/wings_organ = owner.getorganslot(ORGAN_SLOT_WINGS)
	if(!wings_organ || !wings_organ.is_open)
		return ..()
	return "[icon_state]_open"

#ifdef UNIT_TESTS

/datum/sprite_accessory/wings/unit_testing_icon_states(list/states)
	states += icon_state
	if(can_open)
		states += "[icon_state]_open"

#endif

/datum/sprite_accessory/wings/kobold
	name = "Kobold"
	icon_state = "kobold"
	color_key_defaults = list(KEY_SKIN_COLOR)

/datum/sprite_accessory/wings/wide
	abstract_type = /datum/sprite_accessory/wings/wide
	icon = 'modular_rmh/icons/mob/sprite_accessory/wings/wings_wide.dmi'
	pixel_x = -7

/datum/sprite_accessory/wings/huge
	abstract_type = /datum/sprite_accessory/wings/huge
	icon = 'modular_rmh/icons/mob/sprite_accessory/wings/wings_huge.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	pixel_x = -32
	can_open = TRUE

/datum/sprite_accessory/wings/large
	abstract_type = /datum/sprite_accessory/wings/large
	icon = 'modular_rmh/icons/mob/sprite_accessory/wings/wings_64x32.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)
	pixel_x = -16

/datum/sprite_accessory/wings/large/harpyswept
	name = "Harpy (Swept)"
	icon_state = "harpys"
	color_key_defaults = list(KEY_HAIR_COLOR)

/datum/sprite_accessory/wings/large/gargoyle
	name = "Gargoyle"
	icon_state = "gargoyle"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER, BODY_ADJ_LAYER)

/datum/sprite_accessory/wings/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/wings/bat
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/wings/featheryv2
	name = "Feathery v2"
	icon_state = "featheryv2"

/datum/sprite_accessory/wings/wide/succubus
	name = "Succubus"
	icon_state = "succubus"
	extra_state = TRUE

/datum/sprite_accessory/wings/wide/dragon_synth
	name = "Dragon (synthetic alt)"
	icon_state = "dragonsynth"

/datum/sprite_accessory/wings/wide/dragon_alt1
	name = "Dragon (alt 1)"
	icon_state = "dragonalt1"

/datum/sprite_accessory/wings/wide/dragon_alt2
	name = "Dragon (alt 2)"
	icon_state = "dragonalt2"

/datum/sprite_accessory/wings/wide/harpywings
	name = "Harpy"
	icon_state = "harpy"

/datum/sprite_accessory/wings/wide/harpywingsalt1
	name = "Harpy (alt 1)"
	icon_state = "harpyalt"

/datum/sprite_accessory/wings/wide/harpywingsalt2
	name = "Harpy (Bat)"
	icon_state = "harpybat"

/datum/sprite_accessory/wings/wide/harpywings_top
	name = "Harpy (Top)"
	icon_state = "harpy_top"
	relevant_layers = list(BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/wide/harpywingsalt1_top
	name = "Harpy (alt 1) (Top)"
	icon_state = "harpyalt_top"
	relevant_layers = list(BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/wide/harpywingsalt2_top
	name = "Harpy (Bat) (Top)"
	icon_state = "harpybat_top"
	relevant_layers = list(BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/wide/low_wings
	name = "Low wings"
	icon_state = "low"

/datum/sprite_accessory/wings/wide/low_wings_top
	name = "Low wings (Top)"
	icon_state = "low_top"

/datum/sprite_accessory/wings/wide/spider
	name = "Spider legs"
	icon_state = "spider_legs"

/datum/sprite_accessory/wings/wide/robowing
	name = "mechanical dragon wings"
	icon_state = "robowing"

/datum/sprite_accessory/wings/huge/angel
	name = "Angel"
	icon_state = "angel"

/datum/sprite_accessory/wings/huge/dragon
	name = "Dragon"
	icon_state = "dragon"
	color_keys = 2
	color_key_names = list("Primary", "Membrane")

/datum/sprite_accessory/wings/huge/megamoth
	name = "Megamoth"
	icon_state = "megamoth"

/datum/sprite_accessory/wings/huge/mothra
	name = "Mothra"
	icon_state = "mothra"

/datum/sprite_accessory/wings/huge/skeleton
	name = "Skeleton"
	icon_state = "skele"

/datum/sprite_accessory/wings/huge/robotic
	name = "Robotic"
	icon_state = "robotic"

/datum/sprite_accessory/wings/large/harpyswept
	name = "Harpy (Swept)"
	icon_state = "harpys"

/datum/sprite_accessory/wings/large/harpyswept_alt
	name = "Harpy (Swept Alt)"
	icon_state = "harpys_alt"

/datum/sprite_accessory/wings/large/harpyfluff
	name = "Harpy Fluff"
	icon_state = "harpyfluff"

/datum/sprite_accessory/wings/large/harpyfolded
	name = "Harpy Folded"
	icon_state = "harpyfolded"

/datum/sprite_accessory/wings/large/harpyowl
	name = "Harpy Owl"
	icon_state = "harpyowl"

/datum/sprite_accessory/wings/large/harpybat_alt
	name = "Harpy Bat Alt"
	icon_state = "harpybat_alt"

/datum/sprite_accessory/wings/large/gargoyle
	name = "Gargoyle"
	icon_state = "gargoyle"
