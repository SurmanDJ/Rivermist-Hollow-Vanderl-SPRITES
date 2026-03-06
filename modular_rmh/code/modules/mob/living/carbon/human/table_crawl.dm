/mob/living
	var/tmp/table_crawl_under_table = FALSE

/mob/living/proc/can_table_crawl()
	if(buckled)
		return FALSE
	if(!resting || body_position != LYING_DOWN)
		return FALSE
	if(m_intent != MOVE_INTENT_SNEAK)
		return FALSE
	if(mob_size >= MOB_SIZE_LARGE)
		return FALSE
	return TRUE

/mob/living/proc/get_table_crawl_table(atom/location = loc)
	var/turf/table_turf = get_turf(location)
	if(!table_turf)
		return

	for(var/obj/structure/table/table in table_turf)
		return table

/mob/living/proc/get_table_crawl_delay(obj/structure/table/target_table)
	var/adjusted_climb_time = target_table.climb_time
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		adjusted_climb_time *= 2
	if(!ishuman(src))
		adjusted_climb_time = 0
	adjusted_climb_time -= STASPD * 2
	return max(adjusted_climb_time, 0)

/mob/living/proc/can_finish_table_crawl(obj/structure/table/target_table, turf/target_turf)
	if(QDELETED(src) || QDELETED(target_table))
		return FALSE
	if(!can_table_crawl())
		return FALSE
	if(get_table_crawl_table(loc))
		return FALSE
	if(get_turf(target_table) != target_turf)
		return FALSE
	if(!Adjacent(target_table))
		return FALSE
	return TRUE

/mob/living/proc/apply_table_crawl_visual()
	reset_offsets("structure_climb")
	layer = TABLE_LAYER - 0.1
	plane = GAME_PLANE_LOWER

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
	if(!table_crawl_under_table)
		return
	if(!can_table_crawl() || !get_table_crawl_table())
		table_crawl_under_table = FALSE
		clear_table_crawl_visual()
		return
	apply_table_crawl_visual()

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
	RegisterSignals(target, list(
		COMSIG_LIVING_SET_RESTING,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_LIVING_SET_BUCKLED,
	), PROC_REF(on_state_change))

/datum/element/table_crawl/Detach(mob/living/source, ...)
	UnregisterSignal(source, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_SET_RESTING,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_LIVING_SET_BUCKLED,
	))
	source.table_crawl_under_table = FALSE
	source.clear_table_crawl_visual()
	return ..()

/datum/element/table_crawl/proc/on_pre_move(mob/living/source, list/move_args)
	SIGNAL_HANDLER

	source.refresh_table_crawl()
	if(source.table_crawl_under_table || !source.can_table_crawl())
		return

	var/turf/source_turf = get_turf(source)
	var/turf/target_turf = get_turf(move_args[MOVE_ARG_NEW_LOC])
	if(!source_turf || !target_turf || source_turf == target_turf)
		return
	if(source.get_table_crawl_table(source_turf))
		return

	var/obj/structure/table/target_table = source.get_table_crawl_table(target_turf)
	if(!target_table)
		return

	var/crawl_delay = source.get_table_crawl_delay(target_table)
	if(crawl_delay && !do_after(source, crawl_delay, target_table, extra_checks = CALLBACK(source, TYPE_PROC_REF(/mob/living, can_finish_table_crawl), target_table, target_turf), interaction_key = "table_crawl"))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	if(!source.can_finish_table_crawl(target_table, target_turf))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	var/added_passtable = FALSE
	if(!(source.pass_flags & PASSTABLE))
		added_passtable = TRUE
		source.pass_flags |= PASSTABLE

	var/moved = source.Move(target_turf, move_args[MOVE_ARG_DIRECTION])

	if(added_passtable)
		source.pass_flags &= ~PASSTABLE

	if(moved && get_turf(source) == target_turf)
		source.table_crawl_under_table = TRUE
		source.apply_table_crawl_visual()

	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/element/table_crawl/proc/on_moved(mob/living/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	source.refresh_table_crawl()

/datum/element/table_crawl/proc/on_state_change(mob/living/source, ...)
	SIGNAL_HANDLER
	source.refresh_table_crawl()
