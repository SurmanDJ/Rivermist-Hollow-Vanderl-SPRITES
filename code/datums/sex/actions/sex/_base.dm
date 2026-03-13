/datum/sex_action/sex
	stored_item_type = /obj/item/organ/genitals/penis
	stored_item_name = "penetrating member"
	requires_hole_storage = TRUE
	abstract_type = /datum/sex_action/sex
	knot_on_finish = TRUE
	can_knot = TRUE
	user_priority = 100
	target_priority = 0

/datum/sex_action/sex/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/sex_action/sex/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)
	if(hole_id)
		add_sex_lock(target, hole_id, null, FALSE)

/datum/sex_action/generic

/datum/sex_action/generic/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE
