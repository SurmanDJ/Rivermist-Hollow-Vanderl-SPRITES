/datum/sex_action/masturbate
	abstract_type = /datum/sex_action/masturbate
	requires_free_hands = TRUE

/datum/sex_action/masturbate/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/locked = user.get_active_precise_hand()
	if(check_sex_lock(user, locked))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/lock_sex_object(mob/living/user, mob/living/target)
	var/locked = user.get_active_precise_hand()
	add_sex_lock(user, locked)
