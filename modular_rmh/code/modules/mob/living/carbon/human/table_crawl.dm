/mob/living
	var/tmp/table_crawl_under_table = FALSE
	var/tmp/table_crawl_attempting = FALSE
	var/tmp/table_crawl_pending_entry = FALSE
	var/tmp/table_crawl_passtable_owned = FALSE
	var/tmp/table_crawl_hidden = FALSE
	var/tmp/table_crawl_hidden_alpha = 255
	var/tmp/datum/action/innate/table_crawl_hide/table_crawl_hide_action

/mob/living/proc/can_table_crawl()
	if(buckled)
		return FALSE
	if(body_position != LYING_DOWN)
		return FALSE
	if(m_intent != MOVE_INTENT_SNEAK)
		return FALSE
	if(mob_size >= MOB_SIZE_LARGE)
		return FALSE
	return TRUE

/mob/living/proc/can_start_table_crawl()
	if(!can_table_crawl())
		return FALSE
	if(!resting)
		return FALSE
	return TRUE

/mob/living/proc/get_table_crawl_table(atom/location = loc)
	var/turf/table_turf = get_turf(location)
	if(!table_turf)
		return

	for(var/obj/structure/table/table in table_turf)
		return table

/mob/living/proc/get_table_crawl_delay(obj/structure/table/target_table)
	var/adjusted_climb_time = max(target_table.climb_time, 1 SECONDS)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		adjusted_climb_time *= 2
	return adjusted_climb_time

/mob/living/proc/can_virtual_table_climb(obj/structure/table/target_table, turf/target_turf)
	var/turf/source_turf = get_turf(src)
	if(!source_turf || !target_turf || source_turf == target_turf)
		return FALSE

	var/old_density = target_table.density
	target_table.density = FALSE

	. = !source_turf.LinkBlockedWithAccess(target_turf, src, null)
	if(.)
		. = target_turf.CanPass(src, target_turf)
	if(.)
		for(var/atom/movable/thing as anything in target_turf)
			if(thing == src || thing == target_table)
				continue
			if(!thing.CanPass(src, source_turf))
				. = FALSE
				break

	target_table.density = old_density

/mob/living/proc/can_finish_table_crawl(obj/structure/table/target_table, turf/target_turf)
	if(QDELETED(src) || QDELETED(target_table))
		return FALSE
	if(!can_start_table_crawl())
		return FALSE
	if(get_table_crawl_table(loc))
		return FALSE
	if(get_turf(target_table) != target_turf)
		return FALSE
	if(!Adjacent(target_table))
		return FALSE
	if(!can_virtual_table_climb(target_table, target_turf))
		return FALSE
	return TRUE

/mob/living/proc/table_crawl_head_bonk()
	var/obj/structure/table/target_table = get_table_crawl_table()
	var/atom/sound_source = src
	var/table_name = target_table ? "[target_table]" : "the underside of the table"
	if(target_table)
		sound_source = target_table

	visible_message(span_warning("[src] bumps their head on [table_name]!"), span_warning("You bump your head on [table_name]!"))
	playsound(sound_source, "genblunt", 100, TRUE)
	Stun(5 SECONDS)

/mob/living/proc/set_table_crawl_hidden(hidden)
	if(table_crawl_hidden == hidden)
		return

	table_crawl_hidden = hidden
	if(hidden)
		table_crawl_hidden_alpha = alpha
		alpha = 0
	else
		alpha = table_crawl_hidden_alpha
		table_crawl_hidden_alpha = initial(alpha)

	if(table_crawl_hide_action)
		table_crawl_hide_action.active = hidden
		table_crawl_hide_action.build_all_button_icons(UPDATE_BUTTON_STATUS, TRUE)

/mob/living/proc/update_table_crawl_hide_action()
	if(table_crawl_under_table)
		if(!table_crawl_hide_action)
			table_crawl_hide_action = new(src)
		table_crawl_hide_action.Grant(src)
		table_crawl_hide_action.active = table_crawl_hidden
		table_crawl_hide_action.build_all_button_icons(UPDATE_BUTTON_STATUS, TRUE)
		return

	set_table_crawl_hidden(FALSE)
	if(table_crawl_hide_action?.owner == src)
		table_crawl_hide_action.Remove(src)

/mob/living/proc/apply_table_crawl_visual()
	reset_offsets("structure_climb")
	layer = TABLE_LAYER - 0.1
	plane = GAME_PLANE_LOWER

/mob/living/proc/clear_table_crawl_passtable()
	if(!table_crawl_passtable_owned)
		return
	table_crawl_passtable_owned = FALSE
	pass_flags &= ~PASSTABLE

/mob/living/proc/clear_table_crawl_visual()
	var/obj/structure/table/table = get_table_crawl_table()
	if(table?.climb_offset)
		set_mob_offsets("structure_climb", _x = 0, _y = table.climb_offset)
	else
		reset_offsets("structure_climb")

	if(body_position == LYING_DOWN)
		layer = LYING_MOB_LAYER
	else
		layer = initial(layer)
	plane = initial(plane)

/mob/living/proc/refresh_table_crawl()
	if(table_crawl_pending_entry && !get_table_crawl_table())
		table_crawl_pending_entry = FALSE
		clear_table_crawl_passtable()
	if(!table_crawl_under_table)
		update_table_crawl_hide_action()
		return
	if(!can_table_crawl() || !get_table_crawl_table())
		table_crawl_under_table = FALSE
		update_table_crawl_hide_action()
		clear_table_crawl_visual()
		clear_table_crawl_passtable()
		return
	apply_table_crawl_visual()
	update_table_crawl_hide_action()

/mob/living/carbon/Initialize()
	. = ..()
	AddElement(/datum/element/table_crawl)

/datum/element/table_crawl
	element_flags = ELEMENT_DETACH

/datum/element/table_crawl/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_LIVING_SET_RESTING, PROC_REF(on_resting_change))
	RegisterSignal(target, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position_change))
	RegisterSignal(target, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_buckled_change))

/datum/element/table_crawl/Detach(mob/living/source, ...)
	UnregisterSignal(source, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_SET_RESTING,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_LIVING_SET_BUCKLED,
	))
	source.table_crawl_attempting = FALSE
	source.table_crawl_pending_entry = FALSE
	source.table_crawl_under_table = FALSE
	source.update_table_crawl_hide_action()
	source.clear_table_crawl_passtable()
	source.clear_table_crawl_visual()
	QDEL_NULL(source.table_crawl_hide_action)
	return ..()

/datum/element/table_crawl/proc/on_pre_move(mob/living/source, list/move_args)
	SIGNAL_HANDLER

	source.refresh_table_crawl()
	if(source.table_crawl_under_table || !source.can_start_table_crawl())
		return
	if(source.table_crawl_attempting)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	var/turf/source_turf = get_turf(source)
	var/turf/target_turf = get_turf(move_args[MOVE_ARG_NEW_LOC])
	if(!source_turf || !target_turf || source_turf == target_turf)
		return
	if(source.get_table_crawl_table(source_turf))
		return

	var/obj/structure/table/target_table = source.get_table_crawl_table(target_turf)
	if(!target_table)
		return
	if(!source.can_finish_table_crawl(target_table, target_turf))
		return

	var/crawl_delay = source.get_table_crawl_delay(target_table)
	source.table_crawl_attempting = TRUE
	source.visible_message(span_warning("[source] starts to crawl under [target_table]."), span_warning("You start to crawl under [target_table]..."))
	if(crawl_delay && !do_after(source, crawl_delay, target_table, extra_checks = CALLBACK(source, TYPE_PROC_REF(/mob/living, can_finish_table_crawl), target_table, target_turf), interaction_key = "table_crawl"))
		source.table_crawl_attempting = FALSE
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	source.table_crawl_attempting = FALSE
	if(!source.can_finish_table_crawl(target_table, target_turf))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	if(!(source.pass_flags & PASSTABLE))
		source.table_crawl_passtable_owned = TRUE
		source.pass_flags |= PASSTABLE

	source.table_crawl_pending_entry = TRUE
	var/crawl_direction = get_dir(source, target_turf)
	if(!crawl_direction || !step(source, crawl_direction))
		source.table_crawl_pending_entry = FALSE
		source.clear_table_crawl_passtable()
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/element/table_crawl/proc/on_moved(mob/living/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	if(source.table_crawl_pending_entry)
		source.table_crawl_pending_entry = FALSE
		if(source.get_table_crawl_table())
			source.table_crawl_under_table = TRUE
			source.apply_table_crawl_visual()
	source.clear_table_crawl_passtable()
	source.refresh_table_crawl()

/datum/element/table_crawl/proc/on_resting_change(mob/living/source, new_resting)
	SIGNAL_HANDLER
	if(source.table_crawl_under_table && !new_resting && source.body_position == LYING_DOWN)
		source.table_crawl_head_bonk()
	source.refresh_table_crawl()

/datum/element/table_crawl/proc/on_body_position_change(mob/living/source, new_body_position, old_body_position)
	SIGNAL_HANDLER
	if(source.table_crawl_under_table && old_body_position == LYING_DOWN && new_body_position == STANDING_UP)
		if(!HAS_TRAIT(source, TRAIT_INCAPACITATED))
			source.table_crawl_head_bonk()
		addtimer(CALLBACK(source, TYPE_PROC_REF(/mob/living, set_resting), TRUE, TRUE, TRUE), world.tick_lag)
		return
	source.refresh_table_crawl()

/datum/element/table_crawl/proc/on_buckled_change(mob/living/source, ...)
	SIGNAL_HANDLER
	source.refresh_table_crawl()

/datum/action/innate/table_crawl_hide
	name = "Hide under table"
	desc = "Pull yourself completely out of sight while you remain under the table."
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/table_crawl_hide/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE
	var/mob/living/table_hider = owner
	return table_hider.table_crawl_under_table && !!table_hider.get_table_crawl_table()

/datum/action/innate/table_crawl_hide/Activate()
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/table_hider = owner
	if(!table_hider.table_crawl_under_table)
		return
	table_hider.set_table_crawl_hidden(TRUE)
	active = TRUE
	to_chat(table_hider, span_notice("You tuck yourself completely out of sight beneath the table."))

/datum/action/innate/table_crawl_hide/Deactivate()
	if(isliving(owner))
		var/mob/living/table_hider = owner
		table_hider.set_table_crawl_hidden(FALSE)
		to_chat(table_hider, span_notice("You reveal yourself from beneath the table."))
	active = FALSE
	return ..()

/datum/action/innate/table_crawl_hide/Remove(mob/removed_from)
	if(active)
		Deactivate()
	return ..()
