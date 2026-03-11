/obj/item/quest_compass
	name = "quest compass"
	desc = "A small enchanted compass. Use it on a quest scroll to attune it to that contract."
	icon = 'icons/obj/quest_compass.dmi'
	icon_state = "icon"
	w_class = WEIGHT_CLASS_SMALL

	var/datum/weakref/linked_scroll_ref
	var/current_distance_state
	var/current_arrow_state
	var/last_signal_text = "The compass is unlinked."
	var/last_linked_title = ""

/obj/item/quest_compass/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	update_appearance()

/obj/item/quest_compass/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	linked_scroll_ref = null
	return ..()

/obj/item/quest_compass/examine(mob/user)
	. = ..()
	if(last_linked_title)
		. += span_notice("Linked contract: [last_linked_title].")
	. += span_info(last_signal_text)

/obj/item/quest_compass/attack_self(mob/user)
	refresh_tracking(user)
	if(linked_scroll_ref)
		to_chat(user, span_info(last_signal_text))
	else
		to_chat(user, span_notice("Use the compass on a quest scroll to attune it."))
	return ..()

/obj/item/quest_compass/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target, /obj/item/paper/scroll/quest))
		return

	var/obj/item/paper/scroll/quest/quest_scroll = target
	link_to_scroll(quest_scroll, user)

/obj/item/quest_compass/process()
	var/obj/item/paper/scroll/quest/quest_scroll = get_linked_scroll()
	if(!quest_scroll)
		reset_compass("The compass is unlinked.")
		return

	if(!quest_scroll.assigned_quest || quest_scroll.assigned_quest.complete)
		reset_compass("The linked contract is complete.")
		return

	var/mob/living/carrier = recursive_loc_check(src, /mob/living)
	if(!carrier || !is_attuned_bearer(carrier, quest_scroll))
		reset_compass("The compass needs its linked scroll on the contract bearer.")
		return

	refresh_tracking(carrier)

/obj/item/quest_compass/update_overlays()
	. = ..()
	if(current_distance_state)
		. += mutable_appearance(icon, "icon")
	if(current_arrow_state)
		. += mutable_appearance(icon, current_arrow_state)

/obj/item/quest_compass/proc/get_linked_scroll()
	var/obj/item/paper/scroll/quest/quest_scroll = linked_scroll_ref?.resolve()
	if(!quest_scroll || QDELETED(quest_scroll))
		linked_scroll_ref = null
		return null
	return quest_scroll

/obj/item/quest_compass/proc/is_linked_to_scroll(obj/item/paper/scroll/quest/quest_scroll)
	return get_linked_scroll() == quest_scroll

/obj/item/quest_compass/proc/is_attuned_bearer(mob/living/user, obj/item/paper/scroll/quest/quest_scroll)
	if(!user || !quest_scroll?.assigned_quest)
		return FALSE

	var/mob/quest_bearer = quest_scroll.assigned_quest.quest_receiver_reference?.resolve()
	if(!quest_bearer || quest_bearer != user)
		return FALSE

	return recursive_loc_check(quest_scroll, /mob/living) == quest_bearer

/obj/item/quest_compass/proc/link_to_scroll(obj/item/paper/scroll/quest/quest_scroll, mob/user, silent = FALSE)
	if(!quest_scroll?.assigned_quest)
		if(user)
			to_chat(user, span_warning("This scroll carries no quest signal."))
		return FALSE

	linked_scroll_ref = WEAKREF(quest_scroll)
	last_linked_title = quest_scroll.assigned_quest.get_title()
	refresh_tracking(user)

	if(user && !silent)
		to_chat(user, span_notice("The compass attunes itself to [quest_scroll]."))
	return TRUE

/obj/item/quest_compass/proc/refresh_tracking(mob/user)
	var/obj/item/paper/scroll/quest/quest_scroll = get_linked_scroll()
	if(!quest_scroll)
		reset_compass("The compass is unlinked.")
		return FALSE

	if(!quest_scroll.assigned_quest)
		reset_compass("The linked scroll no longer carries a signal.")
		return FALSE

	var/turf/reference_turf = user ? get_turf(user) : get_turf(src)
	var/list/signal_data = quest_scroll.assigned_quest.get_compass_signal_data(reference_turf)
	if(!islist(signal_data))
		reset_compass("The compass cannot sense the contract.")
		return FALSE

	last_signal_text = signal_data["status_text"] || "The compass cannot sense the contract."
	current_distance_state = null
	current_arrow_state = null

	var/turf/compass_target = signal_data["compass_target"]
	if(compass_target && reference_turf)
		var/distance = get_dist(reference_turf, compass_target)
		current_distance_state = get_distance_state(distance)
		current_arrow_state = get_arrow_state(get_dir(reference_turf, compass_target))

	icon_state = current_distance_state || "icon"
	update_appearance()
	return TRUE

/obj/item/quest_compass/proc/reset_compass(status_text)
	last_signal_text = status_text
	current_distance_state = null
	current_arrow_state = null
	icon_state = "icon"
	update_appearance()

/obj/item/quest_compass/proc/get_distance_state(distance)
	switch(distance)
		if(0 to 7)
			return "dist_ind_4"
		if(8 to 20)
			return "dist_ind_3"
		if(21 to 45)
			return "dist_ind_2"
		if(46 to INFINITY)
			return "dist_ind_1"
	return null

/obj/item/quest_compass/proc/get_arrow_state(direction)
	switch(direction)
		if(NORTHWEST)
			return "1"
		if(NORTHEAST)
			return "2"
		if(SOUTHWEST)
			return "3"
		if(SOUTHEAST)
			return "4"
		if(NORTH)
			return "5"
		if(SOUTH)
			return "6"
		if(WEST)
			return "7"
		if(EAST)
			return "8"
	return null
