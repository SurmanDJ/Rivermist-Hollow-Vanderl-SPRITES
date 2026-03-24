/datum/map_template/pocket
	name = "_pocket_base"
	id = "_pocket_base"
	keep_cached_map = TRUE
	var/padding = 1
	var/lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	var/idle_timeout = POCKET_DEFAULT_IDLE_TIMEOUT

/proc/is_valid_pocket_lifecycle_policy(policy)
	return policy == POCKET_LIFECYCLE_KEEP_LOADED || policy == POCKET_LIFECYCLE_HIBERNATE || policy == POCKET_LIFECYCLE_COLLAPSE

/proc/format_pocket_lifecycle_policy(policy)
	switch(policy)
		if(POCKET_LIFECYCLE_KEEP_LOADED)
			return "keep loaded"
		if(POCKET_LIFECYCLE_HIBERNATE)
			return "hibernate"
		if(POCKET_LIFECYCLE_COLLAPSE)
			return "collapse"
	return "unknown"

/datum/pocket_dimension
	var/instance_id
	var/instance_key
	var/datum/map_template/pocket/template
	var/lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	var/idle_timeout = POCKET_DEFAULT_IDLE_TIMEOUT
	var/state = POCKET_STATE_HIBERNATING
	var/last_touched = 0
	var/datum/turf_reservation/reservation
	var/turf/load_turf
	var/turf/return_turf
	var/list/affected_turfs = list()
	var/list/turf/entry_turfs = list()
	var/list/turf/drop_turfs = list()
	var/list/obj/structure/pocket_dimension_exit/exit_objects = list()
	var/list/area/managed_areas = list()
	var/list/atom/movable/native_movables = list()
	var/list/atom/movable/hibernated_movables = list()
	var/obj/effect/abstract/pocket_dimension_storage/storage

/datum/pocket_dimension/New(datum/map_template/pocket/template, instance_key, instance_id, lifecycle_policy, idle_timeout)
	src.template = template
	src.instance_key = instance_key
	src.instance_id = instance_id
	apply_lifecycle_settings(lifecycle_policy, idle_timeout)
	touch()
	. = ..()

/datum/pocket_dimension/Destroy(force)
	if(SSpocket_dimensions)
		SSpocket_dimensions.unregister_instance(src)

	release_loaded_layout()
	hibernated_movables.Cut()
	QDEL_NULL(storage)

	template = null
	instance_key = null
	state = null
	last_touched = 0
	return_turf = null
	return ..()

/datum/pocket_dimension/proc/apply_lifecycle_settings(new_lifecycle_policy = null, new_idle_timeout = null)
	if(!isnull(new_lifecycle_policy) && is_valid_pocket_lifecycle_policy(new_lifecycle_policy))
		lifecycle_policy = new_lifecycle_policy
	else
		lifecycle_policy = template?.lifecycle_policy || POCKET_LIFECYCLE_KEEP_LOADED

	if(!isnull(new_idle_timeout))
		idle_timeout = max(0, new_idle_timeout)
	else
		idle_timeout = max(0, template?.idle_timeout || 0)

/datum/pocket_dimension/proc/touch()
	last_touched = world.time

/datum/pocket_dimension/proc/is_hibernating()
	return state == POCKET_STATE_HIBERNATING && !reservation

/datum/pocket_dimension/proc/release_loaded_layout()
	for(var/obj/structure/pocket_dimension_exit/exit_object as anything in exit_objects)
		exit_object.linked_pocket = null

	for(var/area/current_area as anything in managed_areas)
		if(!istype(current_area, /area/pocket_dimension))
			continue
		var/area/pocket_dimension/pocket_area = current_area
		if(pocket_area.linked_pocket == src)
			pocket_area.linked_pocket = null

	QDEL_LIST(exit_objects)
	managed_areas.Cut()
	entry_turfs.Cut()
	drop_turfs.Cut()
	affected_turfs.Cut()
	native_movables.Cut()
	load_turf = null

	QDEL_NULL(reservation)
	state = POCKET_STATE_HIBERNATING

/datum/pocket_dimension/proc/activate()
	if(reservation)
		state = POCKET_STATE_ACTIVE
		touch()
		return TRUE
	if(!template?.width || !template?.height)
		return FALSE

	var/padded_width = template.width + (template.padding * 2)
	var/padded_height = template.height + (template.padding * 2)
	reservation = SSmapping.RequestPocketBlockReservation(padded_width, padded_height)
	if(!reservation)
		return FALSE

	load_turf = locate(
		reservation.bottom_left_coords[1] + template.padding,
		reservation.bottom_left_coords[2] + template.padding,
		reservation.bottom_left_coords[3],
	)
	if(!load_turf || !template.load(load_turf))
		load_turf = null
		QDEL_NULL(reservation)
		return FALSE

	cache_loaded_layout()
	state = POCKET_STATE_ACTIVE
	restore_hibernated_movables()
	touch()
	return TRUE

/datum/pocket_dimension/proc/cache_loaded_layout()
	affected_turfs.Cut()
	entry_turfs.Cut()
	drop_turfs.Cut()
	managed_areas.Cut()
	native_movables.Cut()
	QDEL_LIST(exit_objects)
	exit_objects = list()

	var/list/turfs = template.get_affected_turfs(load_turf)
	for(var/turf/current_turf as anything in turfs)
		affected_turfs[current_turf] = TRUE

		var/area/current_area = get_area(current_turf)
		managed_areas |= current_area

		for(var/obj/effect/landmark/pocket_dimension/entry/entry_marker in current_turf)
			entry_turfs += current_turf
			qdel(entry_marker)

		for(var/obj/effect/landmark/pocket_dimension/drop_spot/drop_marker in current_turf)
			drop_turfs += current_turf
			qdel(drop_marker)

		for(var/obj/effect/landmark/pocket_dimension/exit/exit_marker in current_turf)
			var/obj/structure/pocket_dimension_exit/exit_object = new(current_turf)
			exit_object.linked_pocket = src
			exit_objects += exit_object
			qdel(exit_marker)

		for(var/atom/movable/movable as anything in current_turf)
			native_movables[movable] = TRUE

	if(!length(entry_turfs))
		var/turf/fallback_entry = get_center_turf()
		if(fallback_entry)
			entry_turfs += fallback_entry

	if(!length(exit_objects) && length(entry_turfs))
		var/obj/structure/pocket_dimension_exit/fallback_exit = new(entry_turfs[1])
		fallback_exit.linked_pocket = src
		exit_objects += fallback_exit

	for(var/area/current_area as anything in managed_areas)
		if(!istype(current_area, /area/pocket_dimension))
			continue

		var/area/pocket_dimension/pocket_area = current_area
		pocket_area.linked_pocket = src
		pocket_area.name = "[template.name] #[instance_id]"

	for(var/obj/structure/pocket_dimension_exit/exit_object as anything in exit_objects)
		native_movables[exit_object] = TRUE

/datum/pocket_dimension/proc/get_occupants()
	var/list/occupants = list()

	for(var/turf/current_turf as anything in affected_turfs)
		for(var/mob/occupant as anything in current_turf.get_all_contents())
			if(QDELETED(occupant) || occupants[occupant] || !contains_turf(get_turf(occupant)))
				continue
			occupants[occupant] = TRUE

	return occupants

/datum/pocket_dimension/proc/has_occupants()
	return !!length(get_occupants())

/datum/pocket_dimension/proc/get_center_turf()
	if(!load_turf)
		return null
	return locate(
		load_turf.x + round((template.width - 1) * 0.5),
		load_turf.y + round((template.height - 1) * 0.5),
		load_turf.z,
	)

/datum/pocket_dimension/proc/get_entry_turf()
	if(length(entry_turfs))
		return pick(entry_turfs)
	return get_center_turf()

/datum/pocket_dimension/proc/is_valid_drop_turf(turf/target, atom/movable/movable)
	if(!target || QDELETED(target) || !contains_turf(target) || !isopenturf(target))
		return FALSE
	return !target.is_blocked_turf(TRUE, movable)

/datum/pocket_dimension/proc/get_drop_turf(atom/movable/movable)
	if(length(drop_turfs))
		var/list/turf/valid_drop_spots = list()
		for(var/turf/drop_turf as anything in drop_turfs)
			if(is_valid_drop_turf(drop_turf, movable))
				valid_drop_spots += drop_turf
		if(length(valid_drop_spots))
			return pick(valid_drop_spots)

	var/list/turf/fallback_turfs = list()
	for(var/turf/current_turf as anything in affected_turfs)
		if(!is_valid_drop_turf(current_turf, movable))
			continue
		fallback_turfs += current_turf

	if(length(fallback_turfs))
		return pick(fallback_turfs)
	return get_entry_turf() || get_center_turf()

/datum/pocket_dimension/proc/get_return_turf()
	if(isturf(return_turf) && !QDELETED(return_turf))
		return return_turf
	return find_safe_turf()

/datum/pocket_dimension/proc/contains_turf(turf/target)
	if(!target)
		return FALSE
	return !!affected_turfs[target]

/datum/pocket_dimension/proc/enter_mob(mob/user, turf/new_return_turf)
	if(!user)
		return FALSE
	if(!reservation && !activate())
		return FALSE

	if(new_return_turf)
		return_turf = new_return_turf

	var/turf/entry_turf = get_entry_turf()
	if(!entry_turf)
		return FALSE

	touch()
	user.forceMove(entry_turf)
	return TRUE

/datum/pocket_dimension/proc/send_movable_inside(atom/movable/movable, turf/new_return_turf = null, turf/forced_drop_turf = null)
	if(!movable || QDELETED(movable))
		return FALSE
	if(!reservation && !activate())
		return FALSE

	if(new_return_turf && (!isturf(return_turf) || QDELETED(return_turf) || !has_occupants()))
		return_turf = new_return_turf

	var/turf/drop_turf = forced_drop_turf
	if(!is_valid_drop_turf(drop_turf, movable))
		drop_turf = get_drop_turf(movable)
	if(!drop_turf)
		return FALSE

	touch()
	return transfer_foreign_movable(movable, drop_turf)

/datum/pocket_dimension/proc/exit_mob(mob/user)
	if(!user)
		return FALSE

	var/turf/target = get_return_turf()
	if(!target)
		return FALSE

	touch()
	user.forceMove(target)
	return TRUE

/datum/pocket_dimension/proc/eject_all(message = null)
	var/turf/target = get_return_turf()
	if(!target)
		return

	for(var/mob/occupant as anything in get_occupants())
		if(message)
			to_chat(occupant, span_warning(message))
		occupant.forceMove(target)

/datum/pocket_dimension/proc/should_preserve_foreign_movable(atom/movable/movable, items_only = FALSE)
	if(!movable || QDELETED(movable) || native_movables[movable] || ismob(movable))
		return FALSE
	if(items_only && !isitem(movable))
		return FALSE
	return TRUE

/datum/pocket_dimension/proc/transfer_foreign_movable(atom/movable/movable, atom/new_loc)
	if(!movable || !new_loc || QDELETED(movable))
		return FALSE

	var/mob/item_holder = ismob(movable.loc) ? movable.loc : null
	if(item_holder && isitem(movable) && !item_holder.temporarilyRemoveItemFromInventory(movable, TRUE))
		return FALSE

	return movable.forceMove(new_loc)

/datum/pocket_dimension/proc/eject_foreign_movables(items_only = FALSE)
	var/turf/target = get_return_turf()
	if(!target)
		return

	var/list/already_checked = list()
	for(var/turf/current_turf as anything in affected_turfs)
		for(var/atom/movable/movable as anything in current_turf.get_all_contents())
			if(already_checked[movable] || !should_preserve_foreign_movable(movable, items_only))
				continue
			already_checked[movable] = TRUE

			if(!contains_turf(get_turf(movable)))
				continue

			transfer_foreign_movable(movable, target)

	if(storage)
		for(var/atom/movable/movable as anything in storage.contents.Copy())
			if(!should_preserve_foreign_movable(movable, items_only))
				continue
			transfer_foreign_movable(movable, target)

	hibernated_movables.Cut()
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/proc/ensure_storage()
	if(!storage)
		storage = new
	return storage

/datum/pocket_dimension/proc/store_foreign_movables_for_hibernation()
	var/obj/effect/abstract/pocket_dimension_storage/hibernate_storage = ensure_storage()
	if(!hibernate_storage || !load_turf)
		return

	hibernated_movables.Cut()

	var/list/already_checked = list()
	for(var/turf/current_turf as anything in affected_turfs)
		for(var/atom/movable/movable as anything in current_turf.get_all_contents())
			if(already_checked[movable] || !should_preserve_foreign_movable(movable))
				continue
			already_checked[movable] = TRUE

			var/turf/movable_turf = get_turf(movable)
			if(!contains_turf(movable_turf))
				continue

			hibernated_movables[movable] = list(
				movable_turf.x - load_turf.x,
				movable_turf.y - load_turf.y,
			)

			if(!transfer_foreign_movable(movable, hibernate_storage))
				hibernated_movables -= movable

/datum/pocket_dimension/proc/restore_hibernated_movables()
	if(!length(hibernated_movables) || !load_turf)
		return

	var/turf/fallback_turf = get_entry_turf() || get_center_turf()
	for(var/atom/movable/movable as anything in hibernated_movables)
		if(QDELETED(movable))
			continue

		var/list/offsets = hibernated_movables[movable]
		var/turf/restore_turf = locate(load_turf.x + offsets[1], load_turf.y + offsets[2], load_turf.z)
		if(!restore_turf || !contains_turf(restore_turf))
			restore_turf = fallback_turf
		if(!restore_turf)
			continue

		movable.forceMove(restore_turf)

	hibernated_movables.Cut()
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/proc/hibernate()
	if(is_hibernating())
		return TRUE
	if(has_occupants())
		return FALSE

	store_foreign_movables_for_hibernation()
	release_loaded_layout()
	state = POCKET_STATE_HIBERNATING
	return TRUE

/datum/pocket_dimension/proc/process_idle_lifecycle()
	if(!idle_timeout || world.time < last_touched + idle_timeout)
		return FALSE
	if(has_occupants())
		return FALSE

	switch(lifecycle_policy)
		if(POCKET_LIFECYCLE_KEEP_LOADED)
			return FALSE
		if(POCKET_LIFECYCLE_HIBERNATE)
			if(is_hibernating())
				return FALSE
			return hibernate()
		if(POCKET_LIFECYCLE_COLLAPSE)
			if(!SSpocket_dimensions)
				return FALSE
			return SSpocket_dimensions.delete_instance(src)

	return FALSE

/area/pocket_dimension
	name = "Pocket Dimension"
	area_flags = NO_TELEPORT | HIDDEN_AREA
	var/datum/pocket_dimension/linked_pocket

/area/pocket_dimension/Destroy(force)
	linked_pocket = null
	return ..()

/area/pocket_dimension/test_chamber
	name = "Pocket Test Chamber"

/area/pocket_dimension/bag_of_holding
	name = "Bag of Holding Cache"

/obj/effect/landmark/pocket_dimension
	name = "pocket dimension marker"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE

/obj/effect/landmark/pocket_dimension/entry
	name = "pocket entry marker"

/obj/effect/landmark/pocket_dimension/drop_spot
	name = "pocket drop spot marker"

/obj/effect/landmark/pocket_dimension/exit
	name = "pocket exit marker"

/obj/effect/abstract/pocket_dimension_storage
	invisibility = INVISIBILITY_ABSTRACT

/obj/structure/pocket_dimension_exit
	name = "return seam"
	desc = "A stable tear in space. Touch it to return to where you entered from."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladder01"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/pocket_dimension/linked_pocket

/obj/structure/pocket_dimension_exit/Destroy(force)
	linked_pocket = null
	return ..()

/obj/structure/pocket_dimension_exit/examine(mob/user)
	. = ..()
	. += span_notice("Touch it to step back out of the pocket dimension.")

/obj/structure/pocket_dimension_exit/proc/use_exit(mob/user)
	if(!linked_pocket)
		to_chat(user, span_warning("The seam wavers, but nowhere answers."))
		return
	linked_pocket.exit_mob(user)

/obj/structure/pocket_dimension_exit/attack_hand(mob/user, list/modifiers)
	. = ..()
	use_exit(user)

/obj/structure/pocket_dimension_exit/attack_animal(mob/user, list/modifiers)
	use_exit(user)

/obj/structure/pocket_dimension_exit/attack_paw(mob/user, list/modifiers)
	use_exit(user)

/datum/map_template/pocket/test_chamber
	name = "Pocket Test Chamber"
	id = "pocket_test_chamber"
	mappath = "_maps/templates/pocket_test_chamber.dmm"

/datum/map_template/pocket/bag_of_holding
	name = "Bag of Holding Cache"
	id = "pocket_bag_of_holding"
	mappath = "_maps/templates/pocket_bag_of_holding.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	idle_timeout = 2 MINUTES

/obj/item/pocket_dimension_tester
	name = "folded-space scroll"
	desc = "A debugging scroll that opens a small test pocket dimension."
	icon_state = "skub"
	item_state = "skub"
	w_class = WEIGHT_CLASS_SMALL
	var/template_ref = /datum/map_template/pocket/test_chamber
	var/access_mode = POCKET_ACCESS_INSTANCE_OWNER
	var/pocket_lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	var/pocket_idle_timeout = 2 MINUTES

/obj/item/pocket_dimension_tester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pocket_access, template_ref, access_mode, pocket_lifecycle_policy, pocket_idle_timeout, null, TRUE, TRUE, TRUE, "Pocket Dimension", "The scroll hums with folded space. What do you want it to do?", "The pocket dimension buckles and throws you back into mundane space!", "The scroll burns away, and the pocket dimension collapses around you!")
