/datum/sex_action/masturbate
	abstract_type = /datum/sex_action/masturbate
	requires_free_hands = TRUE

/datum/sex_action/masturbate/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/lock_sex_object(mob/living/user, mob/living/target)
	var/locked = get_hand_lock_slot(user)
	if(locked)
		add_sex_lock(user, locked)
