/datum/quest/kill/boss
	quest_type = QUEST_BOSS
	contract_group = QUEST_GROUP_BOUNTIES
	mob_types_to_spawn = QUEST_BOSS_KILL_LIST
	count_min = 1
	count_max = 1
	kill_component_type = /datum/component/quest_object/kill/boss
	minimum_tier = QUEST_TIER_LETHAL
	maximum_tier = QUEST_TIER_MYTHIC
	base_reward_value = QUEST_BASE_REWARD_BOSS
	type_risk_bonus = QUEST_BOSS_RISK_BONUS
	var/target_display_name = ""

/datum/quest/kill/boss/get_title()
	if(title)
		return title
	if(target_display_name)
		return "Defeat the boss [target_display_name]"
	return "Defeat [pick("the terrible", "the dreadful", "the monstrous", "the infamous")] boss"

/datum/quest/kill/boss/get_objective_text()
	return "Slay [target_display_name ? target_display_name : initial(target_mob_type.name)]."

/datum/quest/kill/boss/generate(obj/effect/landmark/quest_spawner/landmark)
	..()
	if(!landmark)
		return FALSE
	if(!spawn_kill_mobs(landmark))
		return FALSE
	cache_target_display_name()
	return TRUE

/datum/quest/kill/boss/proc/cache_target_display_name()
	for(var/datum/weakref/target_ref in tracked_atoms)
		var/mob/living/target_mob = target_ref.resolve()
		if(!target_mob || QDELETED(target_mob))
			continue

		target_display_name = target_mob.real_name ? target_mob.real_name : (target_mob.job ? target_mob.job : initial(target_mob_type.name))
		title = "Defeat the boss [target_display_name]"
		return

	target_display_name = initial(target_mob_type.name)
