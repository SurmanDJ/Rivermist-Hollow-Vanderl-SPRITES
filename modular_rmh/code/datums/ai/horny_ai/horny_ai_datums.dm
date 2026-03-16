/datum/ai_behavior/horny
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

	var/seekboredom = 0
	var/stand_up_counter = 0
	var/wrong_action = FALSE
	var/knockdown_need = TRUE

/datum/ai_behavior/horny/simple_mob
	// Simple mobs currently only use the shared horny flow as-is.

/datum/ai_behavior/horny/human
	// Human-type mobs add prep work before the shared action flow.


/datum/ai_behavior/horny/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(isnull(targetting_datum))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	if(isnull(controller.blackboard[BB_HORNY_TIME_START]))
		controller.set_blackboard_key(BB_HORNY_TIME_START, world.time)
	controller.set_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT, 0)
	controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)

	var/atom/target = controller.blackboard[target_key]

	var/mob/living/target_living = target
	var/mob/living/basic_mob = controller.pawn

	if(!basic_mob.GetComponent(/datum/component/arousal)) // give arousal datum if none
		basic_mob.AddComponent(/datum/component/arousal)

	if((basic_mob.gender == MALE && !basic_mob.getorganslot(ORGAN_SLOT_PENIS)) || (basic_mob.gender == FEMALE && !basic_mob.getorganslot(ORGAN_SLOT_VAGINA)))
		basic_mob.give_genitals()

	var/list/arousal_data = list()
	SEND_SIGNAL(basic_mob, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/is_spent = arousal_data["is_spent"]

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN] || is_spent) // if on cooldown or unhorny - stop
		return FALSE

	if(targetting_datum.can_horny(basic_mob, target_living))
		if(basic_mob.gender == MALE)
			basic_mob.visible_message(span_boldwarning("[basic_mob] has his eyes on [target_living], cock throbbing!"))
		else
			basic_mob.visible_message(span_boldwarning("[basic_mob] has her eyes on [target_living], cunt dripping!"))

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 4)

	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	else if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
	if(picked_organ)
		picked_organ.toggle_visibility("Show Above clothes")

	basic_mob.start_sex_session(target_living)
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

	RegisterSignal(basic_mob, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

	controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time)
	SEND_SIGNAL(controller.pawn, COMSIG_HORNY_TARGET_SET, TRUE)

/datum/ai_behavior/horny/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN]) // if on cooldown - stop
		controller.CancelActions()
		controller.modify_cooldown(src, world.time)
		return FALSE

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	var/mob/living/basic_mob = controller.pawn

	if(basic_mob.stat > SOFT_CRIT)
		return

	if(!targetting_datum.can_horny(basic_mob, current_target))
		finish_action(controller, FALSE, target_key)
		return

	if(ismob(current_target))
		if(current_target:stat == DEAD)
			finish_action(controller, FALSE, target_key)
			return


	var/mob/living/target_living = current_target

	//check if they got away during chasing
	if(seekboredom > 10) //11 cycles of Perform, thus //44 sec
		seekboredom = 0
		finish_action(controller, FALSE, target_key)
		return

	if(!basic_mob.Adjacent(target_living))
		knockdown_need = TRUE
		seekboredom += 1
		return
	else
		seekboredom = CLAMP(seekboredom - 1, 0, 10)

	if(target_living.body_position != LYING_DOWN)
		knockdown_need = TRUE
	else
		knockdown_need = FALSE

	var/list/arousal_data = list()
	SEND_SIGNAL(basic_mob, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/is_spent = arousal_data["is_spent"]
	var/last_orgasm_time = arousal_data["last_ejaculation_time"]

	var/datum/sex_session/session = get_sex_session(basic_mob, target_living)
	if(!session) //if we took too long and it's deleted
		session = basic_mob.start_sex_session(target_living)

	//check if we are sated
	if(last_orgasm_time > world.time - 10 SECONDS || is_spent || controller.blackboard[BB_HORNY_TIME_START] < world.time - 5 MINUTES)
		if(session)
			session.stop_current_action()
		finish_action(controller, TRUE, target_key)
		return

	if(basic_mob.body_position == LYING_DOWN) //try to stand before doing anything
		if(!basic_mob.stand_up())
			stand_up_counter += 1
			if(stand_up_counter >= 5)
				finish_action(controller, FALSE, target_key)
		stand_up_counter = 0
		return

	if(try_pre_knockdown_disarm(controller, basic_mob, target_living))
		return

	if(world.time > controller.blackboard[BB_HORNY_STUN_COOLDOWN] && knockdown_need)
		if(attempt_stamina_knockdown(controller, basic_mob, target_living))
			return

	if(handle_target_prep(controller, basic_mob, target_living, session))
		return

	start_horny_action(controller, basic_mob, target_living, session, target_key)

/datum/ai_behavior/horny/proc/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	// Override this in mob-specific subclasses when they need setup work before the sex action starts.
	return TRUE

/datum/ai_behavior/horny/proc/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	return TRUE

/datum/ai_behavior/horny/proc/attempt_stamina_knockdown(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!basic_mob.Adjacent(target_living))
		knockdown_need = TRUE
		return FALSE
	if(target_living.body_position == LYING_DOWN)
		knockdown_need = FALSE
		return FALSE

	var/prob2defend
	var/obj/item/mainhand = target_living.get_active_held_item()
	var/obj/item/offhand = target_living.get_inactive_held_item()
	var/list/parry_data = target_living.calculate_parry_values(mainhand, offhand)
	prob2defend += CLAMP(parry_data["defense_bonus"] / 80, 0, 40)
	prob2defend += CLAMP(target_living.STASPD / 20 * 50, 0, 50)
	if(target_living.cmode)
		prob2defend *= 1.2
	if(target_living.surrendering)
		prob2defend *= 0.1
	prob2defend = CLAMP(prob2defend, 0, 85)

	var/base_stamina_drain = iscarbon(basic_mob) ? target_living.maximum_stamina * 0.18 : target_living.maximum_stamina * 0.24
	var/stamina_drain = max(round(base_stamina_drain * (1 - (prob2defend / 125))), 5)
	target_living.adjust_stamina(stamina_drain, null, FALSE, FALSE)

	// Once only 20% stamina remains, the takedown becomes guaranteed
	var/stamina_exhaustion = target_living.maximum_stamina ? (target_living.stamina / target_living.maximum_stamina) : 0
	var/down_chance = CLAMP(round((stamina_exhaustion / 0.8) * 100), 0, 100)

	if(prob(down_chance))
		if(iscarbon(basic_mob))
			target_living.SetStun(30)
			target_living.SetKnockdown(50)
		else
			target_living.SetStun(80)
			target_living.SetKnockdown(200)
		if(target_living.body_position != LYING_DOWN)
			target_living.emote("gasp")
		controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time + 10 SECONDS)
		basic_mob.visible_message(span_danger("[basic_mob] batters [target_living]'s guard down and drags them to the ground!"))
	else
		controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time + 5 SECONDS)
		basic_mob.visible_message(span_danger("[basic_mob] tries to pull [target_living] to the ground, exhausting them!"))

	return TRUE

/datum/ai_behavior/horny/proc/start_horny_action(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session, target_key)
	if(!session)
		return

	var/action_type = select_horny_ai_act(basic_mob, target_living, session)
	if(isnull(action_type))
		return

	if(isnull(session.current_action))
		session.try_start_action(action_type)
		basic_mob.face_atom(target_living)
		var/force = rand(SEX_FORCE_MID, SEX_FORCE_MAX)
		var/speed = rand(SEX_SPEED_MID, SEX_SPEED_MAX)
		session.set_current_force(force)
		session.set_current_speed(speed)
		target_living.apply_status_effect(/datum/status_effect/debuff/mob_fucked)
		if(isnull(session.current_action))
			wrong_action = TRUE
			finish_action(controller, FALSE, target_key)

/datum/ai_behavior/horny/proc/select_horny_ai_act(mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	var/list/weighted_actions = list()
	var/has_penis = !!basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	var/has_vagina = !!basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
	var/target_has_penis = !!target_living.getorganslot(ORGAN_SLOT_PENIS)
	var/target_has_vagina = !!target_living.getorganslot(ORGAN_SLOT_VAGINA)

	if(has_penis)
		weighted_actions += /datum/sex_action/npc/npc_throat_sex
		weighted_actions += /datum/sex_action/npc/npc_throat_sex
		weighted_actions += /datum/sex_action/npc/npc_anal_sex
		if(target_has_vagina)
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex

	if(has_vagina)
		weighted_actions += /datum/sex_action/npc/npc_facesitting
		weighted_actions += /datum/sex_action/npc/npc_facesitting
		if(target_has_penis)
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_anal_ride_sex

	if(!length(weighted_actions))
		return null

	var/list/valid_actions = list()
	for(var/datum/sex_action/action_type as anything in weighted_actions)
		if(session.can_perform_action(action_type))
			valid_actions += action_type

	if(!length(valid_actions))
		return null

	return pick(valid_actions)

/datum/ai_behavior/horny/simple_mob/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	if(!ishuman(target_living) || !basic_mob.Adjacent(target_living))
		return FALSE

	if(!prob(15))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	return strip_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/simple_mob/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!ishuman(target_living) || !basic_mob.Adjacent(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	return disarm_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/simple_mob/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	if(!human_target.Adjacent(basic_mob))
		return FALSE
	if(!human_target.get_active_held_item() && !human_target.get_inactive_held_item())
		return FALSE
	if(!prob(50))
		human_target.visible_message(span_danger("[basic_mob] swats at [human_target]'s hands, but fails to disarm them!"), \
				span_userdanger("[basic_mob] swats at my hands, but I keep hold of my weapon!"), span_hear("I hear a rough struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		return TRUE

	for(var/obj/item/I in human_target.held_items)
		human_target.dropItemToGround(I, force = FALSE, silent = FALSE)
	human_target.Stun(5)
	human_target.visible_message(span_danger("[basic_mob] bats at [human_target]'s hands and disarms them!"), \
			span_userdanger("[basic_mob] bats at my hands and disarms me!"), span_hear("I hear someone getting disarmed!"), COMBAT_MESSAGE_RANGE)
	return TRUE

/datum/ai_behavior/horny/proc/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	return TRUE

/datum/ai_behavior/horny/simple_mob/proc/strip_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	var/list/possible_items = list()

	var/obj/item/clothing/pants = human_target.wear_pants
	if(pants && (pants.flags_inv & HIDECROTCH) && !pants.genital_access)
		possible_items += pants

	if(prob(40))
		var/obj/item/clothing/armor = human_target.wear_armor
		if(armor)
			possible_items += armor

	if(prob(40))
		var/obj/item/clothing/shirt = human_target.wear_shirt
		if(shirt)
			possible_items += shirt

	if(prob(35))
		var/obj/item/random_item = pick(human_target.get_equipped_items(FALSE))
		if(istype(random_item, /obj/item/clothing) || istype(random_item, /obj/item/storage/belt))
			possible_items += random_item

	if(!length(possible_items))
		return FALSE

	var/obj/item/stripped_item = pick(possible_items)
	if(!stripped_item)
		return FALSE

	basic_mob.visible_message(span_danger("[basic_mob] starts tugging at [human_target]'s [stripped_item]!"))
	if(!do_after(basic_mob, rand(12, 20) DECISECONDS, human_target))
		return FALSE
	if(QDELETED(stripped_item) || stripped_item.loc != human_target)
		return FALSE

	if(prob(35) && !istype(stripped_item, /obj/item/storage) && !istype(stripped_item, /obj/item/clothing/ring))
		stripped_item.take_damage(damage_amount = stripped_item.max_integrity * 0.15, sound_effect = FALSE)

	basic_mob.visible_message(span_danger("[basic_mob] tears [human_target]'s [stripped_item] loose!"))
	human_target.dropItemToGround(stripped_item)
	stripped_item.throw_at(pick(orange(2, get_turf(human_target))), 2, 1, basic_mob, TRUE)
	return TRUE

/datum/ai_behavior/horny/human/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	if(!iscarbon(basic_mob))
		return FALSE

	var/mob/living/carbon/carbon_mob = basic_mob
	ensure_target_grab(carbon_mob, target_living)

	if(!ishuman(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	strip_human_target(basic_mob, human_target)

	if(tie_human_target(carbon_mob, human_target))
		return TRUE

	return FALSE

/datum/ai_behavior/horny/human/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!ishuman(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	return disarm_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/human/proc/ensure_target_grab(mob/living/carbon/carbon_mob, mob/living/target_living)
	if(carbon_mob.pulling)
		return

	carbon_mob.drop_all_held_items()
	var/sel_zone
	if(prob(30)) // chance to gag
		sel_zone = BODY_ZONE_PRECISE_MOUTH
	else
		sel_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_GROIN)

	if(!length(target_living.grabbedby))
		target_living.grabbedby(carbon_mob, FALSE, sel_zone)

/datum/ai_behavior/horny/human/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	if(!human_target.Adjacent(basic_mob))
		return FALSE
	if(!human_target.get_active_held_item() && !human_target.get_inactive_held_item())
		return FALSE
	if(!prob(50))
		human_target.visible_message(span_danger("[basic_mob] lunges for [human_target]'s weapon, but can't wrench it free!"), \
				span_userdanger("[basic_mob] lunges for my weapon, but I keep hold of it!"), span_hear("I hear a struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		return TRUE

	for(var/obj/item/I in human_target.held_items)
		human_target.dropItemToGround(I, force = FALSE, silent = FALSE)
	human_target.Stun(5)
	human_target.visible_message(span_danger("[basic_mob] disarms [human_target]!"), \
			span_userdanger("[basic_mob] disarms me!"), span_hear("I hear someone getting punished!"), COMBAT_MESSAGE_RANGE)
	return TRUE

/datum/ai_behavior/horny/human/proc/strip_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	var/pririty_list = list(human_target.wear_pants, human_target.wear_armor, human_target.wear_shirt)
	for(var/obj/item/clothing/priority_cloth in pririty_list)
		if(priority_cloth && (priority_cloth.flags_inv & HIDECROTCH) && !priority_cloth.genital_access)
			if(!do_after(basic_mob, 1 SECONDS, human_target))
				basic_mob.visible_message(span_danger("[basic_mob] manages to rip [human_target]'s [priority_cloth.name] off!"))
				var/obj/item/clothing/thepants = priority_cloth
				human_target.dropItemToGround(thepants)
				thepants.throw_at(pick(orange(2, get_turf(human_target))), 2, 1, basic_mob, TRUE)

	if(!prob(10))
		return

	var/obj/item/item = pick(human_target.get_equipped_items(FALSE))
	if(!istype(item, /obj/item/clothing) && !istype(item, /obj/item/storage/belt))
		return
	if(!do_after(basic_mob, 1 SECONDS, human_target))
		if(!istype(item, /obj/item/storage) && !istype(item, /obj/item/clothing/ring))
			item.take_damage(damage_amount = item.max_integrity * 0.2, sound_effect = FALSE)
		basic_mob.visible_message(span_danger("[basic_mob] manages to rip [human_target]'s [item] off!"))
		human_target.dropItemToGround(item)
		item.throw_at(pick(orange(2, get_turf(human_target))), 2, 1, basic_mob, TRUE)

/datum/ai_behavior/horny/human/proc/tie_human_target(mob/living/carbon/carbon_mob, mob/living/carbon/human/human_target)
	if(human_target.body_position != LYING_DOWN || human_target.get_active_held_item())
		return FALSE
	if(!carbon_mob.Adjacent(human_target) || human_target.get_num_arms(TRUE) <= 1 || human_target.handcuffed)
		return FALSE

	carbon_mob.visible_message(span_danger("[carbon_mob] begins to tie up [human_target]'s hands!"))
	if(!do_after(carbon_mob, 1 SECONDS, human_target))
		return FALSE

	var/obj/item/rope/rope_item = new /obj/item/rope
	if(rope_item.apply_cuffs(human_target, carbon_mob))
		return TRUE

	qdel(rope_item)
	return FALSE

/datum/ai_behavior/horny/proc/on_attacked(mob/living/source, atom/attacker, damage)
	SIGNAL_HANDLER
	if(!damage || !source?.ai_controller || !attacker)
		return
	if(attacker == source || QDELETED(attacker) || isturf(attacker))
		return
	if(ismob(attacker))
		var/mob/M = attacker
		if(M.status_flags & GODMODE || M.stat == DEAD)
			return
	if(source.see_invisible < attacker.invisibility)
		return

	var/datum/ai_controller/controller = source.ai_controller
	var/atom/current_horny_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]

	if(attacker == current_horny_target)
		var/hit_count = (controller.blackboard[BB_HORNY_TARGET_ATTACK_COUNT] || 0) + 1
		controller.set_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT, hit_count)
		var/should_retaliate = hit_count >= 4 || (hit_count >= 2 && source.health <= source.maxHealth * 0.75)
		if(!should_retaliate)
			return

		controller.set_blackboard_key(BB_HORNY_AGGRO_TARGET, attacker)
		controller.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)

	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]

	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, attacker)

	var/atom/potential_hiding_location = targetting_datum?.find_hidden_mobs(source, attacker)
	if(potential_hiding_location)
		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, potential_hiding_location)
	else
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	controller.CancelActions()



/datum/ai_behavior/horny/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic_mob = controller.pawn

	for(var/datum/sex_session/session as anything in return_sessions_with_user(basic_mob))
		if(session.user != basic_mob)
			continue
		session.stop_current_action()

	UnregisterSignal(basic_mob, COMSIG_ATOM_WAS_ATTACKED)

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 0)


	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
		picked_organ.toggle_visibility(FALSE)
	if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
		picked_organ.toggle_visibility(FALSE)


	seekboredom = 0
	knockdown_need = TRUE
	wrong_action = FALSE
	basic_mob.stop_pulling()
	controller.clear_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_HORNY_TIME_START)
	if(basic_mob.is_dead())
		return
	if(!succeeded)
		//if ran away - be angry
		controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + 30 SECONDS)
		basic_mob.visible_message(span_danger("[basic_mob] stomps on the ground, clearly unsatisfied!"))
		controller.modify_cooldown(src, world.time)
		//controller.CancelActions()
		return



	//if sated - go off and sleep or smth
	controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + 90 SECONDS)
	basic_mob.visible_message(span_danger("[basic_mob] exhales contently!"))
	controller.modify_cooldown(src, world.time)
	//controller.CancelActions()

