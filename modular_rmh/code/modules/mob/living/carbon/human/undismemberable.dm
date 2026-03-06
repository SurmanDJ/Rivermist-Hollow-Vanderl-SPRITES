/mob/living/carbon/Initialize()
	. = ..()

	AddComponent(/datum/component/table_crawl)
	addtimer(CALLBACK(src, PROC_REF(make_bodyparts_undismemberable)), 10)

/mob/living/carbon/proc/make_bodyparts_undismemberable()
	if(!client)
		return

	for(var/obj/item/bodypart/chest/C in src.bodyparts)
		C.dismemberable = 0
	for(var/obj/item/bodypart/head/H in src.bodyparts)
		H.dismemberable = 0
	for(var/obj/item/bodypart/l_arm/LA in src.bodyparts)
		LA.dismemberable = 0
	for(var/obj/item/bodypart/r_arm/RA in src.bodyparts)
		RA.dismemberable = 0
	for(var/obj/item/bodypart/l_leg/LL in src.bodyparts)
		LL.dismemberable = 0
	for(var/obj/item/bodypart/r_leg/RL in src.bodyparts)
		RL.dismemberable = 0

/datum/component/table_crawl
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/living/owner
	var/obj/structure/table/current_table
	var/under_table = FALSE
	var/visual_override = FALSE
	var/old_layer
	var/old_plane

/datum/component/table_crawl/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	owner = parent

	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(owner, COMSIG_LIVING_SET_RESTING, PROC_REF(on_state_change))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_state_change))
	RegisterSignal(owner, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_state_change))

/datum/component/table_crawl/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_SET_RESTING,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_LIVING_SET_BUCKLED,
	))
	untrack_table()
	. = ..()

/datum/component/table_crawl/Destroy()
	clear_under_table_visual()
	current_table = null
	owner = null
	return ..()

/datum/component/table_crawl/proc/can_table_crawl()
	if(QDELETED(owner))
		return FALSE
	if(owner.buckled)
		return FALSE
	if(!owner.resting || owner.body_position != LYING_DOWN)
		return FALSE
	if(owner.m_intent != MOVE_INTENT_SNEAK)
		return FALSE
	if(owner.mob_size >= MOB_SIZE_LARGE)
		return FALSE
	return TRUE

/datum/component/table_crawl/proc/get_table(atom/location = owner.loc)
	var/turf/table_turf = get_turf(location)
	if(!table_turf)
		return

	for(var/obj/structure/table/table in table_turf)
		return table

/datum/component/table_crawl/proc/get_crawl_delay(obj/structure/table/target_table)
	var/adjusted_climb_time = target_table.climb_time
	if(HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		adjusted_climb_time *= 2
	if(!ishuman(owner))
		adjusted_climb_time = 0
	adjusted_climb_time -= owner.STASPD * 2
	return max(adjusted_climb_time, 0)

/datum/component/table_crawl/proc/can_finish_table_crawl(obj/structure/table/target_table, turf/target_turf)
	if(QDELETED(owner) || QDELETED(target_table))
		return FALSE
	if(!can_table_crawl())
		return FALSE
	if(get_table(owner.loc))
		return FALSE
	if(get_turf(target_table) != target_turf)
		return FALSE
	if(!owner.Adjacent(target_table))
		return FALSE
	return TRUE

/datum/component/table_crawl/proc/on_pre_move(mob/living/source, list/move_args)
	SIGNAL_HANDLER

	refresh_state()
	if(under_table || !can_table_crawl())
		return

	var/turf/source_turf = get_turf(owner)
	var/turf/target_turf = get_turf(move_args[MOVE_ARG_NEW_LOC])
	if(!source_turf || !target_turf || source_turf == target_turf)
		return
	if(get_table(source_turf))
		return

	var/obj/structure/table/target_table = get_table(target_turf)
	if(!target_table)
		return

	var/crawl_delay = get_crawl_delay(target_table)
	if(crawl_delay && !do_after(owner, crawl_delay, target_table, extra_checks = CALLBACK(src, PROC_REF(can_finish_table_crawl), target_table, target_turf), interaction_key = "table_crawl"))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	if(!can_finish_table_crawl(target_table, target_turf))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	var/added_passtable = FALSE
	if(!(owner.pass_flags & PASSTABLE))
		added_passtable = TRUE
		owner.pass_flags |= PASSTABLE

	var/moved = owner.Move(target_turf, move_args[MOVE_ARG_DIRECTION])

	if(added_passtable)
		owner.pass_flags &= ~PASSTABLE

	if(moved && get_turf(owner) == target_turf)
		enter_under_table(target_table)

	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/component/table_crawl/proc/on_moved(datum/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	refresh_state()

/datum/component/table_crawl/proc/on_state_change(datum/source, ...)
	SIGNAL_HANDLER
	refresh_state()

/datum/component/table_crawl/proc/on_table_deleted(datum/source)
	SIGNAL_HANDLER
	exit_under_table()

/datum/component/table_crawl/proc/refresh_state()
	if(!under_table)
		return

	var/obj/structure/table/table = get_table()
	if(!can_table_crawl() || !table)
		exit_under_table()
		return

	track_table(table)
	apply_under_table_visual()

/datum/component/table_crawl/proc/enter_under_table(obj/structure/table/target_table)
	under_table = TRUE
	track_table(target_table)
	apply_under_table_visual()

/datum/component/table_crawl/proc/exit_under_table()
	under_table = FALSE
	clear_under_table_visual()
	untrack_table()

/datum/component/table_crawl/proc/track_table(obj/structure/table/new_table)
	if(current_table == new_table)
		return
	untrack_table()
	current_table = new_table
	if(current_table)
		RegisterSignal(current_table, COMSIG_PARENT_QDELETING, PROC_REF(on_table_deleted))

/datum/component/table_crawl/proc/untrack_table()
	if(!current_table)
		return
	UnregisterSignal(current_table, COMSIG_PARENT_QDELETING)
	current_table = null

/datum/component/table_crawl/proc/apply_under_table_visual()
	if(QDELETED(owner))
		return
	if(!visual_override)
		old_layer = owner.layer
		old_plane = owner.plane
		visual_override = TRUE

	owner.reset_offsets("structure_climb")
	owner.layer = TABLE_LAYER - 0.1
	owner.plane = GAME_PLANE_LOWER

/datum/component/table_crawl/proc/clear_under_table_visual()
	if(QDELETED(owner) || !visual_override)
		return

	owner.layer = old_layer
	owner.plane = old_plane
	visual_override = FALSE

	var/obj/structure/table/table = get_table()
	if(table?.climb_offset)
		owner.set_mob_offsets("structure_climb", _x = 0, _y = table.climb_offset)
	else
		owner.reset_offsets("structure_climb")
