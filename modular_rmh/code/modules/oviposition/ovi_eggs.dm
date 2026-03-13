#define OVI_EGG_NORMAL "normal_ovi"
#define OVI_EGG_SPIDER "spider_ovi"
#define OVI_EGG_BOG_BUG "bog_bug_ovi"
#define OVI_EGG_HARPY "harpy_ovi"

// Egg profiles keep appearance and hatch behavior together so new egg types only
// need one local subtype instead of special cases spread across the system.
/datum/oviposition_egg_profile
	var/egg_type = OVI_EGG_NORMAL
	var/display_name = "oviposition egg"
	var/display_desc = "A soft, warm egg that feels alive even before it starts to twitch."
	var/display_icon_state = "egg"
	var/display_icon = null
	var/display_color = null
	var/hatch_result_type = /obj/item/reagent_containers/food/snacks/oviposition_egg/color/green //placeholder because we don't want human hatching
	var/requires_fertilization = TRUE
	var/poll_for_ghost = TRUE
	var/require_ghost_to_hatch = TRUE
	var/incubation_stage_duration = 5 MINUTES
	var/list/stage_messages = null
	var/ready_message = null
	var/hatch_message = null

/datum/oviposition_egg_profile/proc/get_stage_message(stage)
	return stage_messages?[stage]

/datum/oviposition_egg_profile/proc/apply_to_egg(obj/item/oviposition_egg/egg)
	if(!egg)
		return
	egg.name = display_name
	egg.desc = display_desc
	egg.icon_state = display_icon_state
	egg.color = display_color
	if(display_icon)
		egg.icon = display_icon

/datum/oviposition_egg_profile/spider
	egg_type = OVI_EGG_SPIDER
	display_name = "spider egg"
	display_desc = "A soft, web-slick egg with a faint, unsettling pulse."
	display_icon_state = "egg_color"
	display_color = "#6d7685"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/spider
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 4 MINUTES
	ready_message = "The spider egg in my %CONTAINER% twitches with hungry little movements."
	hatch_message = "%EGG% splits open in a spray of web and skittering legs!"

/datum/oviposition_egg_profile/bog_bug
	egg_type = OVI_EGG_BOG_BUG
	display_name = "bog bug egg"
	display_desc = "A damp, swamp-dark egg with a shell that flexes around something hungry."
	display_icon_state = "egg_color"
	display_color = "#4d6a3f"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/bogbug
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 7 MINUTES
	ready_message = "The bog bug egg in my %CONTAINER% churns like a swamp creature is kicking to get free."
	hatch_message = "%EGG% bursts with a wet pop, spilling out a ravenous bog bug!"

/datum/oviposition_egg_profile/harpy
	egg_type = OVI_EGG_HARPY
	display_name = "hardshell egg"
	display_desc = "A smooth, birdlike egg with a sturdy shell and a gentle, nest-warm weight."
	display_icon_state = "egg_chicken"
	display_color = "#eee3c7"
	ready_message = "The harpy egg in my %CONTAINER% feels full and heavy, like a ripe nesting egg ready to be laid."

/proc/get_oviposition_egg_profile(egg_type)
	var/profile_type = /datum/oviposition_egg_profile
	switch(egg_type)
		if(OVI_EGG_SPIDER)
			profile_type = /datum/oviposition_egg_profile/spider
		if(OVI_EGG_BOG_BUG)
			profile_type = /datum/oviposition_egg_profile/bog_bug
		if(OVI_EGG_HARPY)
			profile_type = /datum/oviposition_egg_profile/harpy
	return new profile_type

/proc/get_species_oviposition_egg_type(mob/living/owner)
	if(isharpy(owner))
		return OVI_EGG_HARPY
	return null

/proc/get_oviposition_parent_features(mob/living/parent)
	if(!ishuman(parent))
		return null

	var/mob/living/carbon/human/human_parent = parent
	var/datum/bodypart_feature/hair/parent_hair = human_parent.get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	var/datum/bodypart_feature/hair/parent_facial_hair = human_parent.get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	return list(
		"skin_tone" = human_parent.skin_tone,
		"hair_color" = human_parent.get_hair_color(),
		"hair_style" = parent_hair?.accessory_type,
		"facial_hair_color" = human_parent.get_facial_hair_color(),
		"facial_hair_style" = parent_facial_hair?.accessory_type,
		"eye_color" = human_parent.get_eye_color(),
		"species" = human_parent.dna?.species?.type,
	)

/obj/item/oviposition_egg
	parent_type = /obj/item/reagent_containers/food/snacks/oviposition_egg
	name = "oviposition egg"
	desc = "A soft, warm egg that feels alive even before it starts to twitch."
	w_class = WEIGHT_CLASS_SMALL
	body_storage_bulk = 1
	var/egg_type = OVI_EGG_NORMAL
	var/mob/living/oviposition_mother
	var/oviposition_mother_name
	var/list/oviposition_mother_features

/obj/item/oviposition_egg/Initialize(mapload)
	. = ..()
	update_egg_appearance()

/obj/item/oviposition_egg/proc/set_egg_type(new_egg_type)
	if(new_egg_type)
		egg_type = new_egg_type
	update_egg_appearance()
	return egg_type

/obj/item/oviposition_egg/proc/set_oviposition_mother(mob/living/new_mother)
	oviposition_mother = new_mother
	oviposition_mother_name = new_mother?.real_name
	oviposition_mother_features = get_oviposition_parent_features(new_mother)
	return oviposition_mother

/obj/item/oviposition_egg/proc/get_oviposition_mother(mob/living/default_mother = null)
	return oviposition_mother || default_mother

/obj/item/oviposition_egg/proc/get_egg_profile()
	return get_oviposition_egg_profile(egg_type)

/obj/item/oviposition_egg/proc/update_egg_appearance()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	if(!profile)
		return
	profile.apply_to_egg(src)

/obj/item/oviposition_egg/proc/requires_fertilization()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.requires_fertilization) ? TRUE : profile.requires_fertilization

/obj/item/oviposition_egg/proc/get_hatch_result_type()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_result_type

/obj/item/oviposition_egg/proc/get_incubation_stage_duration()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.incubation_stage_duration || 15 MINUTES

/obj/item/oviposition_egg/proc/get_stage_message(stage)
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.get_stage_message(stage)

/obj/item/oviposition_egg/proc/get_ready_message()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.ready_message

/obj/item/oviposition_egg/proc/get_hatch_message()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_message

/obj/item/oviposition_egg/proc/should_poll_for_ghost()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.poll_for_ghost) ? FALSE : profile.poll_for_ghost

/obj/item/oviposition_egg/proc/requires_ghost_to_hatch()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.require_ghost_to_hatch) ? FALSE : profile.require_ghost_to_hatch

/obj/item/oviposition_egg/proc/get_pregnancy_component()
	return GetComponent(/datum/component/pregnancy)

/obj/item/oviposition_egg/proc/has_pregnancy()
	return !isnull(get_pregnancy_component())

/obj/item/oviposition_egg/proc/is_fertilized()
	var/datum/component/pregnancy/pregnancy = get_pregnancy_component()
	return !isnull(pregnancy?.father)
