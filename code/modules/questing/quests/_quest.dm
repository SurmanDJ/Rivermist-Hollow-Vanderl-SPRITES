/datum/quest
	var/title = ""
	var/datum/weakref/quest_giver_reference
	var/quest_giver_name = ""
	var/datum/weakref/quest_receiver_reference
	var/quest_receiver_name = ""
	var/quest_type = ""
	var/contract_group = QUEST_GROUP_ERRANDS
	var/requested_tier = QUEST_TIER_ROUTINE
	var/threat_tier = QUEST_TIER_ROUTINE
	var/minimum_tier = QUEST_TIER_ROUTINE
	var/maximum_tier = QUEST_TIER_MYTHIC
	var/base_reward_value = 0
	var/reward_amount = 0
	var/deposit_amount = 0
	var/complete = FALSE

	/// Progress tracking
	var/progress_current = 0
	var/progress_required = 1

	/// Target item type for fetch quests
	var/obj/item/target_item_type
	/// Target item type for courier quests
	var/obj/item/target_delivery_item
	/// Target mob type for kill quests
	var/mob/target_mob_type
	/// Location for courier quests
	var/area/indoors/town/target_delivery_location
	/// Location name for kill/clear quests
	var/target_spawn_area = ""
	/// Stable anchor coordinates for resolving the quest's map context.
	var/target_anchor_x = 0
	var/target_anchor_y = 0
	var/target_anchor_z = 0

	/// Scroll icon state
	var/quest_icon = "scroll_quest"

	/// Fallback reference to the spawned scroll
	var/obj/item/paper/scroll/quest/quest_scroll
	/// Weak reference to the quest scroll
	var/datum/weakref/quest_scroll_ref
	/// List of weakrefs to actual quest items/mobs for reducing overhead of compass.
	var/list/datum/weakref/tracked_atoms = list()

/datum/quest/Destroy()
	// Clean up mobs with quest components
	for(var/mob/living/M in GLOB.mob_list)
		var/datum/component/quest_object/Q = M.GetComponent(/datum/component/quest_object)
		if(Q && Q.quest_ref?.resolve() == src)
			M.remove_filter("quest_item_outline")
			qdel(Q)

	for(var/datum/weakref/tracked_weakref in tracked_atoms)
		var/atom/target_atom = tracked_weakref.resolve()
		if(QDELETED(target_atom))
			continue

		if(!complete)
			if(ismob(target_atom))
				qdel(target_atom)
			else if(quest_type == QUEST_RETRIEVAL && istype(target_atom, target_item_type))
				qdel(target_atom)
			else if(quest_type == QUEST_COURIER && (istype(target_atom, /obj/item/parcel) || (target_delivery_item && istype(target_atom, target_delivery_item))))
				qdel(target_atom)

		tracked_atoms -= tracked_weakref
		qdel(tracked_weakref)

	// Clean up references
	quest_scroll = null
	if(quest_scroll_ref)
		var/obj/item/paper/scroll/quest/Q = quest_scroll_ref.resolve()
		if(Q && !QDELETED(Q))
			Q.assigned_quest = null
			qdel(Q)
		quest_scroll_ref = null

	return ..()

/datum/quest/proc/add_tracked_atom(atom/movable/to_track)
	tracked_atoms += WEAKREF(to_track)

/datum/quest/proc/remove_tracked_atom(atom/movable/to_untrack)
	if(!to_untrack)
		return FALSE

	for(var/datum/weakref/tracked_ref in tracked_atoms.Copy())
		if(tracked_ref.resolve() != to_untrack)
			continue

		tracked_atoms -= tracked_ref
		qdel(tracked_ref)
		return TRUE

	return FALSE

/datum/quest/proc/set_target_anchor(atom/source)
	var/turf/anchor_turf = get_turf(source)
	if(!anchor_turf)
		return FALSE

	target_anchor_x = anchor_turf.x
	target_anchor_y = anchor_turf.y
	target_anchor_z = anchor_turf.z
	return TRUE

/datum/quest/proc/get_target_anchor_turf()
	if(!target_anchor_x || !target_anchor_y || !target_anchor_z)
		return null

	return locate(target_anchor_x, target_anchor_y, target_anchor_z)

/datum/quest/proc/get_map_file_for_turf(turf/target_turf)
	if(!target_turf)
		return null

	var/map_file = SSmapping.level_trait(target_turf.z, ZTRAIT_MAP_FILE)
	if(!map_file)
		return null

	return lowertext("[map_file]")

/datum/quest/proc/get_nearest_tracked_location(turf/reference_turf, include_held_items = TRUE)
	var/turf/origin_turf = reference_turf ? get_turf(reference_turf) : (quest_scroll ? get_turf(quest_scroll) : null)
	if(!origin_turf)
		return null

	var/turf/closest
	var/min_dist = INFINITY
	var/list/stale_refs = list()

	for(var/datum/weakref/ref in tracked_atoms)
		var/atom/movable/A = ref.resolve()
		if(!A || QDELETED(A))
			stale_refs += ref
			continue

		if(ismob(A))
			var/mob/living/tracked_mob = A
			if(tracked_mob.stat == DEAD)
				stale_refs += ref
				continue
		else if(isitem(A) && !include_held_items)
			if(recursive_loc_check(A, /mob/living))
				continue

		var/turf/A_turf = get_turf(A)
		if(!A_turf)
			stale_refs += ref
			continue

		var/dist = get_dist(origin_turf, A_turf)
		if(dist < min_dist)
			min_dist = dist
			closest = A_turf

	for(var/datum/weakref/stale_ref in stale_refs)
		tracked_atoms -= stale_ref
		qdel(stale_ref)

	return closest

/datum/quest/proc/has_tracked_item_in_inventory()
	var/list/stale_refs = list()

	for(var/datum/weakref/ref in tracked_atoms)
		var/obj/item/tracked_item = ref.resolve()
		if(!tracked_item || QDELETED(tracked_item))
			stale_refs += ref
			continue

		if(recursive_loc_check(tracked_item, /mob/living))
			for(var/datum/weakref/stale_ref in stale_refs)
				tracked_atoms -= stale_ref
				qdel(stale_ref)
			return TRUE

	for(var/datum/weakref/stale_ref in stale_refs)
		tracked_atoms -= stale_ref
		qdel(stale_ref)

	return FALSE

/datum/quest/proc/get_area_target_turf(area/target_area, turf/reference_turf)
	if(!target_area)
		return null

	var/turf/origin_turf = reference_turf ? get_turf(reference_turf) : null
	if(origin_turf)
		var/list/same_z_turfs = target_area.get_turfs_by_zlevel(origin_turf.z)
		if(length(same_z_turfs))
			return same_z_turfs[1]

	for(var/list/zlevel_turfs as anything in target_area.get_zlevel_turf_lists())
		if(length(zlevel_turfs))
			return zlevel_turfs[1]

	return null

/datum/quest/proc/get_turn_in_target_turf(turf/reference_turf)
	var/turf/origin_turf = reference_turf ? get_turf(reference_turf) : (quest_scroll ? get_turf(quest_scroll) : null)
	var/turf/best_turf
	var/best_score = INFINITY

	for(var/obj/effect/decal/marker_export/marker in world)
		var/turf/marker_turf = get_turf(marker)
		if(!marker_turf)
			continue

		if(!origin_turf)
			return marker_turf

		var/score = marker_turf.z == origin_turf.z ? get_dist(origin_turf, marker_turf) : 1000 + abs(marker_turf.z - origin_turf.z)
		if(score < best_score)
			best_score = score
			best_turf = marker_turf

	return best_turf

/datum/quest/proc/should_use_live_target_location(turf/live_target_turf)
	if(!live_target_turf)
		return FALSE

	var/turf/anchor_turf = get_target_anchor_turf()
	if(!anchor_turf)
		return TRUE

	var/anchor_map_file = get_map_file_for_turf(anchor_turf)
	if(!anchor_map_file)
		return TRUE

	var/live_map_file = get_map_file_for_turf(live_target_turf)
	if(!live_map_file)
		return FALSE

	return live_map_file == anchor_map_file

/datum/quest/proc/get_anchor_safe_target_location(turf/reference_turf, turf/live_target_turf)
	if(should_use_live_target_location(live_target_turf))
		return live_target_turf

	return get_target_anchor_turf() || live_target_turf

/datum/quest/proc/get_target_map_anchor(turf/reference_turf)
	return get_target_anchor_turf() || get_target_location(reference_turf)

/datum/quest/proc/get_supported_map_name(map_file)
	if(!map_file)
		return null

	var/static/list/supported_map_names = list(
		"bogforest.dmm" = "Bog Forest",
		"desert.dmm" = "Desert",
		"frozen_mountains.dmm" = "Frozen Mountains",
		"hsector.dmm" = "Rivermist City",
		"hsector_snow.dmm" = "Rivermist City (Winter)",
		"underdark.dmm" = "Underdark",
	)

	return supported_map_names[lowertext("[map_file]")]

/datum/quest/proc/get_target_map_text(turf/reference_turf)
	var/turf/map_anchor = get_target_map_anchor(reference_turf)
	if(!map_anchor)
		return "Error: target location could not be determined."

	var/map_file = get_map_file_for_turf(map_anchor)
	if(!map_file)
		return "Error: target is not on a supported quest map."

	var/map_name = get_supported_map_name(map_file)
	if(!map_name)
		return "Error: target is on an unsupported map ([map_file])."

	return map_name

/datum/quest/proc/find_portal_to_area(area/target_area, turf/from_turf)
	if(!target_area || !from_turf)
		return null

	var/obj/structure/fluff/traveltile/best
	var/best_dist = INFINITY

	for(var/obj/structure/fluff/traveltile/tile in GLOB.traveltiles)
		var/turf/tile_turf = get_turf(tile)
		if(!tile_turf || !is_in_zweb(tile_turf.z, from_turf.z))
			continue
		if(tile.cached_destination_area != target_area)
			continue

		var/distance = get_dist(from_turf, tile_turf)
		if(distance < best_dist)
			best_dist = distance
			best = tile

	return best

/datum/quest/proc/get_compass_signal_label(turf/reference_turf, using_live_target)
	return using_live_target ? "Live target signal" : "Quest spawner echo"

/datum/quest/proc/get_compass_signal_data(turf/reference_turf)
	var/list/signal_data = list(
		"compass_target" = null,
		"resolved_target" = null,
		"status_text" = "The signal cannot be resolved.",
	)
	if(!reference_turf)
		return signal_data

	var/turf/live_target_turf = get_nearest_tracked_location(reference_turf)
	var/turf/resolved_target = get_target_location(reference_turf)
	var/using_live_target = resolved_target && live_target_turf && resolved_target == live_target_turf
	var/signal_label = get_compass_signal_label(reference_turf, using_live_target)

	if(!resolved_target)
		signal_data["status_text"] = "[signal_label] unavailable."
		return signal_data

	signal_data["resolved_target"] = resolved_target
	signal_data["compass_target"] = resolved_target

	if(resolved_target.z != reference_turf.z)
		if(!is_in_zweb(resolved_target.z, reference_turf.z))
			var/area/target_area = get_area(resolved_target)
			var/obj/structure/fluff/traveltile/portal = find_portal_to_area(target_area, reference_turf)
			if(portal)
				signal_data["compass_target"] = get_turf(portal)
				signal_data["status_text"] = "[signal_label] routed through a local gate."
				return signal_data

			signal_data["compass_target"] = null
			signal_data["status_text"] = "[signal_label] is on another map."
			return signal_data

		signal_data["compass_target"] = null
		signal_data["status_text"] = resolved_target.z > reference_turf.z ? "[signal_label] is above you." : "[signal_label] is below you."
		return signal_data

	if(get_dist(reference_turf, resolved_target) <= 1)
		signal_data["status_text"] = "[signal_label] is very close."
	else
		signal_data["status_text"] = "[signal_label] is active."

	return signal_data

/datum/quest/proc/get_tier_label(tier = threat_tier)
	switch(tier)
		if(QUEST_TIER_ROUTINE)
			return "Tier I - Routine"
		if(QUEST_TIER_RISKY)
			return "Tier II - Risky"
		if(QUEST_TIER_DANGEROUS)
			return "Tier III - Dangerous"
		if(QUEST_TIER_DEADLY)
			return "Tier IV - Deadly"
		if(QUEST_TIER_LETHAL)
			return "Tier V - Lethal"
		if(QUEST_TIER_MYTHIC)
			return "Tier VI - Mythic"
	return "Tier ?"

/datum/quest/proc/get_tier_band_text()
	return "[get_tier_label(minimum_tier)] to [get_tier_label(maximum_tier)]"

/datum/quest/proc/get_tier_choices()
	var/list/choices = list()
	for(var/tier in minimum_tier to maximum_tier)
		choices[get_tier_label(tier)] = tier
	return choices

/datum/quest/proc/get_effective_requested_tier(obj/effect/landmark/quest_spawner/landmark)
	var/tier = requested_tier
	if(!tier && landmark)
		tier = landmark.get_default_contract_tier()
	if(!tier)
		tier = minimum_tier

	tier = clamp(tier, minimum_tier, maximum_tier)
	if(landmark)
		tier = clamp(tier, landmark.min_contract_tier, landmark.max_contract_tier)
	return tier

/// Generate quest content - override in subtypes
/datum/quest/proc/generate(obj/effect/landmark/quest_spawner/landmark)
	if(!title)
		title = get_title()
	if(landmark)
		set_target_anchor(landmark)
		requested_tier = get_effective_requested_tier(landmark)
		threat_tier = requested_tier
	return TRUE

/// Get the quest title - override in subtypes for dynamic titles
/datum/quest/proc/get_title()
	return title

/// Get objective text for scroll display
/datum/quest/proc/get_objective_text()
	return "Complete the objective."

/// Get location text for scroll display
/datum/quest/proc/get_location_text()
	return target_spawn_area ? "Reported sighting in [target_spawn_area] region." : "Location unknown."

/// Check if quest objectives are complete
/datum/quest/proc/check_completion()
	return progress_current >= progress_required

/// Called when progress is updated
/datum/quest/proc/on_progress_update()
	if(check_completion())
		mark_complete()
	else
		quest_scroll?.update_quest_text()

/// Mark quest as complete
/datum/quest/proc/mark_complete()
	complete = TRUE
	quest_scroll?.update_quest_text()

/// Base reward by contract type, without randomization.
/datum/quest/proc/get_base_reward()
	return base_reward_value

/datum/quest/proc/get_risk_score(turf/target_turf)
	return requested_tier

/datum/quest/proc/get_workload_reward(turf/target_turf)
	return 0

/datum/quest/proc/get_tier_from_risk_score(risk_score)
	if(risk_score <= 3)
		return QUEST_TIER_ROUTINE
	if(risk_score <= 5)
		return QUEST_TIER_RISKY
	if(risk_score <= 7)
		return QUEST_TIER_DANGEROUS
	if(risk_score <= 10)
		return QUEST_TIER_DEADLY
	if(risk_score <= 13)
		return QUEST_TIER_LETHAL
	return QUEST_TIER_MYTHIC

/// Calculate reward from base type value + concrete risk score + workload done.
/datum/quest/proc/calculate_reward(turf/target_turf)
	var/risk_score = max(1, ROUND_UP(get_risk_score(target_turf)))
	var/workload_reward = max(0, ROUND_UP(get_workload_reward(target_turf)))
	threat_tier = get_tier_from_risk_score(risk_score)
	return max(0, ROUND_UP(get_base_reward() + (risk_score * QUEST_REWARD_PER_RISK_POINT) + workload_reward))

/datum/quest/proc/calculate_deposit(reward_override)
	var/reward_reference = isnum(reward_override) ? reward_override : reward_amount
	if(reward_reference <= 0)
		reward_reference = get_base_reward() + (get_effective_requested_tier(null) * QUEST_REWARD_PER_RISK_POINT)
	return clamp(ROUND_UP(max(QUEST_MIN_DEPOSIT, reward_reference * QUEST_DEPOSIT_RATE)), QUEST_MIN_DEPOSIT, QUEST_MAX_DEPOSIT)

/// Get icon for scroll based on actual threat tier.
/datum/quest/proc/get_scroll_icon()
	switch(threat_tier)
		if(QUEST_TIER_ROUTINE, QUEST_TIER_RISKY)
			return "scroll_quest_low"
		if(QUEST_TIER_DANGEROUS, QUEST_TIER_DEADLY)
			return "scroll_quest_mid"
		if(QUEST_TIER_LETHAL, QUEST_TIER_MYTHIC)
			return "scroll_quest_high"
	return quest_icon

/// Get target location for compass - returns turf of nearest tracked atom
/datum/quest/proc/get_target_location(turf/reference_turf)
	var/turf/live_target_turf = get_nearest_tracked_location(reference_turf)
	return get_anchor_safe_target_location(reference_turf, live_target_turf)

/// Check if a user can claim this quest - override for restrictions
/datum/quest/proc/can_claim(mob/user)
	return TRUE

/// Called when quest is claimed by a user
/datum/quest/proc/on_claim(mob/user)
	quest_receiver_reference = WEAKREF(user)
	quest_receiver_name = user.real_name
