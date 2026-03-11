/datum/ai_planning_subtree/simple_find_horny

/datum/ai_planning_subtree/simple_find_horny/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		return
	if(horny_ai_should_yield_to_aggro(controller))
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_horny_targets, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/datum/ai_planning_subtree/horny
	/// Blackboard key containing current target
	var/target_key = BB_BASIC_MOB_CURRENT_HORNY_TARGET


/datum/ai_planning_subtree/horny/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return
	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN])
		return
	if(horny_ai_should_yield_to_aggro(controller))
		return
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	if(target)
		return SUBTREE_RETURN_FINISH_PLANNING //we are going into +battle+...no distractions.

/datum/ai_planning_subtree/proc/horny_ai_should_yield_to_aggro(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]
	if(!living_pawn || !targetting_datum)
		return FALSE

	if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return TRUE

	if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, controller.blackboard[BB_HIGHEST_THREAT_MOB]))
		return TRUE

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(length(retaliate_list))
		for(var/mob/living/retaliator as anything in retaliate_list)
			if(retaliate_list[retaliator] + 2 MINUTES < world.time)
				continue
			if(!can_see(living_pawn, retaliator, 8))
				continue
			if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, retaliator))
				return TRUE

	if(locate(/datum/ai_planning_subtree/aggro_find_target) in controller.planning_subtrees || locate(/datum/ai_planning_subtree/minotaur_targeting) in controller.planning_subtrees)
		var/search_range = controller.blackboard[BB_AGGRO_RANGE] || 9
		for(var/mob/living/potential_target in hearers(search_range, living_pawn) - living_pawn)
			if(horny_ai_is_valid_aggro_target(living_pawn, targetting_datum, potential_target))
				return TRUE

	return FALSE

/datum/ai_planning_subtree/proc/horny_ai_is_valid_aggro_target(mob/living/living_pawn, datum/targetting_datum/targetting_datum, atom/target)
	if(!target || target == living_pawn || QDELETED(target))
		return FALSE

	if(!targetting_datum.can_attack(living_pawn, target) && !targetting_datum.should_disarm(living_pawn, target))
		return FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return FALSE
		if(living_target.rogue_sneaking)
			var/extra_chance = (living_pawn.health <= living_pawn.maxHealth * 0.5) ? 30 : 0
			if(!living_pawn.npc_detect_sneak(living_target, extra_chance))
				return FALSE

	return TRUE
