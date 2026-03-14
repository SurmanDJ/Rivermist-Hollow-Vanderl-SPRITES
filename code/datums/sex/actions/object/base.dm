
/datum/sex_action/object_fuck
	abstract_type = /datum/sex_action/object_fuck
	name = "object_fuck"
	requires_hole_storage = TRUE
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	hole_id = ORGAN_SLOT_VAGINA
	stored_item_type = /obj/item

/datum/sex_action/object_fuck/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	var/mob/living/storage_receiver = get_storage_receiver(user, target)
	var/obj/item/item_to_check = get_storage_check_item(user, target)
	if(!storage_insertor || !storage_receiver || !item_to_check)
		return FALSE

	var/hand_lock = storage_insertor.get_active_precise_hand()
	if(check_sex_lock(storage_insertor, hand_lock))
		return FALSE
	if(check_sex_lock(storage_insertor, null, item_to_check))
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/lock_sex_object(mob/living/user, mob/living/target)
	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	var/mob/living/storage_receiver = get_storage_receiver(user, target)
	var/obj/item/item_to_lock = get_storage_check_item(user, target)
	if(storage_insertor)
		add_sex_lock(storage_insertor, storage_insertor.get_active_precise_hand())
	if(storage_insertor && item_to_lock)
		add_sex_lock(storage_insertor, null, item_to_lock)
	if(storage_receiver && hole_id)
		add_sex_lock(storage_receiver, hole_id, null, FALSE)

/datum/sex_action/object_fuck/get_storage_check_item(mob/living/user, mob/living/target)
	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	return get_sextoy_in_hand(storage_insertor)

#define MAX_TOY_SIZE WEIGHT_CLASS_SMALL

/proc/get_sextoy_in_hand(mob/living/user)

	var/obj/item/thing = user.get_active_held_item()
	if(thing != null && thing.w_class < MAX_TOY_SIZE) //Anything smaller than this fucks the puss.
		return thing
	return null

#undef MAX_TOY_SIZE
