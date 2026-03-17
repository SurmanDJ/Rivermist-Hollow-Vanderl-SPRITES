#define RUNE_DAMAGE_THRESHOLD 90
#define RUNE_BRUTE_DAMAGE_SCALE 0.13
#define RUNE_BURN_DAMAGE_SCALE 0.2
#define RUNE_REBUILD_DELAY 5 SECONDS
#define RUNE_REVIVE_DELAY 1 SECONDS
#define RUNE_REVIVE_LOCKOUT 10 SECONDS


/datum/resurrection_rune_controller
	var/obj/structure/resurrection_rune/control/control_rune
	var/obj/structure/resurrection_rune/sub_rune
	var/list/linked_users = list()
	var/list/linked_users_by_name = list()
	var/list/linked_users_minds = list()
	var/list/linked_body_by_mind = list()
	var/list/resurrecting = list()
	// If the body is completely gone, rebuild this kind of shell at the rune
	var/mob_type = /mob/living/carbon/human

/datum/resurrection_rune_controller/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/datum/resurrection_rune_controller/Destroy()
	STOP_PROCESSING(SSobj, src)

	for(var/mob/living/carbon/linked_user as anything in linked_users)
		unregister_linked_user_signals(linked_user)

	control_rune = null
	sub_rune = null
	linked_users = null
	linked_users_by_name = null
	linked_users_minds = null
	linked_body_by_mind = null
	resurrecting = null
	return ..()

/datum/resurrection_rune_controller/process()
	if(!sub_rune)
		return
	if(!sub_rune.main_rune_link)
		sub_rune.find_master()
		return
	if(resurrections_disabled())
		return
	if(!linked_users_minds.len)
		return

	// Linked souls that fully lost their body get remade at the rune after a short delay.
	for(var/datum/mind/linked_mind as anything in linked_users_minds)
		if(should_remove_linked_mind(linked_mind))
			remove_linked_mind(linked_mind)
			return
		if(linked_mind.current)
			continue
		if(linked_mind in resurrecting)
			continue
		queue_body_remake(linked_mind)

/datum/resurrection_rune_controller/proc/resurrections_disabled()
	if(!sub_rune)
		return TRUE
	if(sub_rune.is_main)
		return FALSE
	return control_rune?.disabled_res

/datum/resurrection_rune_controller/proc/should_remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return FALSE

	var/mob/current_mob = linked_mind.current
	if(isnull(current_mob?.client))
		return FALSE
	return isnewplayer(current_mob.client.mob)

/datum/resurrection_rune_controller/proc/queue_body_remake(datum/mind/linked_mind)
	to_chat(linked_mind.get_ghost(TRUE, TRUE), span_blue("Somewhere, you are being remade anew..."))
	resurrecting |= linked_mind
	addtimer(CALLBACK(src, PROC_REF(spawn_new_body), linked_mind), RUNE_REBUILD_DELAY)

/datum/resurrection_rune_controller/proc/spawn_new_body(datum/mind/linked_mind)
	if(!sub_rune)
		resurrecting -= linked_mind
		return
	if(!(linked_mind in linked_users_minds))
		resurrecting -= linked_mind
		return
	if(linked_mind.current)
		resurrecting -= linked_mind
		return

	var/turf/rune_turf = get_turf(sub_rune)
	if(!rune_turf)
		resurrecting -= linked_mind
		return

	var/mob/living/carbon/new_body = new mob_type(rune_turf)
	var/mob/ghostie = linked_mind.get_ghost(TRUE)
	if(ghostie?.client?.prefs)
		ghostie.client.prefs.apply_prefs_to(new_body, TRUE)

	// Mind transfer expects the new body to briefly be the current body first
	linked_mind.current = new_body
	linked_mind.transfer_to(new_body)
	linked_mind.grab_ghost(TRUE)
	new_body.flash_act()

	replace_linked_body(linked_mind, new_body)
	resurrecting -= linked_mind
	apply_revival_debuffs(new_body)
	playsound(rune_turf, 'sound/misc/vampirespell.ogg', 100, FALSE, -1)
	to_chat(new_body, span_blue("You are back."))

/datum/resurrection_rune_controller/proc/add_user(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(!user.mind)
		return FALSE
	if(user in linked_users)
		return FALSE

	if(!(user.mind in linked_users_minds))
		linked_users_minds += user.mind
	replace_linked_body(user.mind, user)
	return TRUE

/datum/resurrection_rune_controller/proc/remove_user(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(!(user in linked_users))
		return FALSE

	var/datum/mind/linked_mind = user.mind
	unregister_linked_body(user)
	resurrecting -= user

	if(linked_mind)
		linked_users_minds -= linked_mind
		linked_body_by_mind.Remove(linked_mind)
		resurrecting -= linked_mind

	return TRUE

/datum/resurrection_rune_controller/proc/register_linked_body(mob/living/carbon/user)
	if(!user)
		return
	if(!(user in linked_users))
		linked_users += user
		register_linked_user_signals(user)

	linked_users_by_name[user.name] = user
	set_rune_link_state(user, TRUE)

/datum/resurrection_rune_controller/proc/unregister_linked_body(mob/living/carbon/user)
	if(!user)
		return

	linked_users -= user
	linked_users_by_name.Remove(user.name)
	resurrecting -= user
	unregister_linked_user_signals(user)
	set_rune_link_state(user, FALSE)

/datum/resurrection_rune_controller/proc/replace_linked_body(datum/mind/linked_mind, mob/living/carbon/new_body)
	if(!linked_mind || !new_body)
		return

	var/mob/living/carbon/old_body = linked_body_by_mind[linked_mind]
	if(old_body && old_body != new_body)
		unregister_linked_body(old_body)

	linked_body_by_mind[linked_mind] = new_body
	register_linked_body(new_body)

/datum/resurrection_rune_controller/proc/remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return

	var/mob/living/carbon/linked_body = linked_body_by_mind[linked_mind]
	if(linked_body)
		unregister_linked_body(linked_body)

	linked_users_minds -= linked_mind
	linked_body_by_mind.Remove(linked_mind)
	resurrecting -= linked_mind

/datum/resurrection_rune_controller/proc/register_linked_user_signals(mob/living/carbon/user)
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(handle_linked_user_update))
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(handle_linked_user_update))

/datum/resurrection_rune_controller/proc/unregister_linked_user_signals(mob/living/carbon/user)
	UnregisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(handle_linked_user_update))
	UnregisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(handle_linked_user_update))

/datum/resurrection_rune_controller/proc/set_rune_link_state(mob/living/carbon/user, linked)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	human_user.rune_linked = linked

/datum/resurrection_rune_controller/proc/handle_linked_user_update(mob/living/carbon/target)
	SIGNAL_HANDLER

	if(!target)
		return
	if(!sub_rune)
		return
	if(!sub_rune.is_main && !sub_rune.main_rune_link)
		if(!sub_rune.find_master())
			return
	if(resurrections_disabled())
		return
	if(!(target in linked_users))
		return
	if(target in resurrecting)
		return
	if(!should_trigger_revival(target))
		return

	queue_revival(target)

/datum/resurrection_rune_controller/proc/should_trigger_revival(mob/living/carbon/target)
	if(!target)
		return FALSE
	if(get_total_rune_damage(target) >= RUNE_DAMAGE_THRESHOLD)
		return TRUE
	if(target.is_dead())
		return TRUE

	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/open/lava))
		return TRUE
	if(istype(target_turf, /turf/open/lava/acid))
		return TRUE
	return FALSE

/datum/resurrection_rune_controller/proc/get_total_rune_damage(mob/living/carbon/target)
	if(!target)
		return 0

	// Limb damage is underrepresented in the raw health checks, so brute and burn are weighted here.
	var/brute_damage = target.getBruteLoss() * RUNE_BRUTE_DAMAGE_SCALE
	var/burn_damage = target.getFireLoss() * RUNE_BURN_DAMAGE_SCALE
	var/tox_damage = target.getToxLoss()
	var/oxy_damage = target.getOxyLoss()
	return brute_damage + burn_damage + tox_damage + oxy_damage

/datum/resurrection_rune_controller/proc/queue_revival(mob/living/carbon/user, is_linked = TRUE)
	if(!user)
		return
	if(user in resurrecting)
		return

	if(is_linked)
		to_chat(user.mind, span_blue("You feel a faint force tuggung you back to life..."))
	else
		to_chat(user.mind, span_blue("An alien force suddenly <b>YANKS</b> you back to life!"))

	sub_rune.visible_message(span_blue("The rune begins to grow brighter."))
	resurrecting |= user
	addtimer(CALLBACK(src, PROC_REF(complete_revival), user), RUNE_REVIVE_DELAY)

/datum/resurrection_rune_controller/proc/complete_revival(mob/living/carbon/user)
	var/turf/rune_turf = get_turf(sub_rune)
	var/mob/living/carbon/body = user
	if(!body || !rune_turf)
		if(sub_rune)
			sub_rune.visible_message(span_blue("The rune flickers, connection to a body suddenly severed."))
		resurrecting -= user
		return
	if(!(body in linked_users))
		resurrecting -= user
		return

	body.visible_message(span_blue("With a loud pop, [body.name] suddenly disappears!"))
	playsound(get_turf(body), 'sound/magic/repulse.ogg', 100, FALSE, -1)
	body.ExtinguishMob()
	body.forceMove(rune_turf)
	body.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)
	body.clear_fullscreens()
	body.reload_fullscreen()
	body.update_cone_show()
	body.update_fov_angles()

	var/was_zombie = body.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(was_zombie || body_has_rot(body))
		clear_rot_and_zombie_state(body, was_zombie)

	body.grab_ghost(TRUE)
	body.flash_act()
	apply_revival_debuffs(body)
	addtimer(CALLBACK(src, PROC_REF(clear_resurrection_lockout), body), RUNE_REVIVE_LOCKOUT)
	playsound(rune_turf, 'sound/misc/vampirespell.ogg', 100, FALSE, -1)
	to_chat(body, span_blue("Despite everything, you are back to life..."))
	to_chat(body, span_red("...But you remember the gnashing horror of what brought you here in minute detail - and you are terrified of repeating it."))

/datum/resurrection_rune_controller/proc/body_has_rot(mob/living/carbon/target)
	if(!target)
		return FALSE

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		if(bodypart.rotted)
			return TRUE
	return FALSE

/datum/resurrection_rune_controller/proc/clear_rot_and_zombie_state(mob/living/carbon/target, was_zombie)
	if(was_zombie)
		target.mind.remove_antag_datum(/datum/antagonist/zombie)
		target.death()

	var/datum/component/rot/rot = target.GetComponent(/datum/component/rot)
	if(rot)
		rot.amount = 0

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		bodypart.rotted = FALSE
		bodypart.update_limb()
		if(bodypart.can_be_disabled)
			bodypart.update_disabled()

	target.update_body()
	target.visible_message("<span class='notice'>The rot leaves [target]'s body!</span>", "<span class='green'>I feel the rot leave my body!</span>")

/datum/resurrection_rune_controller/proc/apply_revival_debuffs(mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.rune_linked)
			target.apply_status_effect(/datum/status_effect/debuff/revived/rune)
		else
			target.apply_status_effect(/datum/status_effect/debuff/revived/rune/rough)
	else
		target.apply_status_effect(/datum/status_effect/debuff/revived/rune/rough)

	target.apply_status_effect(/datum/status_effect/debuff/rune_glow)

/datum/resurrection_rune_controller/proc/clear_resurrection_lockout(mob/living/carbon/user)
	resurrecting -= user


/obj/structure/resurrection_rune
	name = "grand rune"
	desc = "It emits an otherwordly hum."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "portal"
	anchored = TRUE
	layer = BELOW_OPEN_DOOR_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/datum/resurrection_rune_controller/resrunecontroler
	var/is_main = FALSE
	var/obj/structure/resurrection_rune/control/main_rune_link
	pixel_x = -64
	pixel_y = -64

/obj/structure/resurrection_rune/Initialize(mapload)
	. = ..()
	resrunecontroler = new /datum/resurrection_rune_controller()
	resrunecontroler.sub_rune = src
	find_master()
	GLOB.global_resurrunes += src

/obj/structure/resurrection_rune/Destroy()
	if(resrunecontroler)
		resrunecontroler.control_rune = null
		resrunecontroler.sub_rune = null
		qdel(resrunecontroler)
		resrunecontroler = null

	main_rune_link = null
	GLOB.global_resurrunes -= src
	return ..()

/obj/structure/resurrection_rune/proc/find_master()
	for(var/obj/structure/resurrection_rune/control/found_master as anything in GLOB.global_resurrunes)
		main_rune_link = found_master
		if(resrunecontroler)
			resrunecontroler.control_rune = found_master
		return TRUE

	main_rune_link = null
	if(resrunecontroler)
		resrunecontroler.control_rune = null
	return FALSE

/obj/structure/resurrection_rune/proc/link_soul(mob/living/carbon/user)
	if(!resrunecontroler)
		return FALSE
	if(user in resrunecontroler.linked_users)
		to_chat(user, span_blue("Your Soul is already linked."))
		return FALSE
	if(!resrunecontroler.add_user(user))
		return FALSE

	to_chat(user, span_blue("You link your Soul to the Rune."))
	return TRUE

/obj/structure/resurrection_rune/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon))
		return
	if(!resrunecontroler)
		return
	if(!main_rune_link)
		find_master()
	if(!main_rune_link && !is_main)
		to_chat(user, span_blue("Somehow, the main rune is not connected..."))
		return
	if(!is_main && main_rune_link.disabled_res)
		to_chat(user, span_blue("Your masters have disabled the rune!"))
		return
	if(is_main)
		return

	var/mob/living/carbon/carbon_user = user
	var/choice = input(carbon_user, "What do you wish to do?", "Rune of Souls") as anything in list("Link Soul", "Revive a lost Soul", "Cancel")
	switch(choice)
		if("Link Soul")
			link_soul(carbon_user)
		if("Revive a lost Soul")
			to_chat(carbon_user, span_blue("The rune sputters, as if offended."))
		else
			return

/obj/structure/resurrection_rune/attacked_by(obj/item/I, mob/living/user)
	return FALSE

/obj/structure/resurrection_rune/control
	name = "master rune"
	is_main = TRUE
	var/disabled_res = FALSE

/obj/structure/resurrection_rune/control/Initialize(mapload)
	. = ..()

/obj/structure/resurrection_rune/control/proc/get_sub_rune()
	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(rune.is_main)
			continue
		return rune

/obj/structure/resurrection_rune/control/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon))
		return

	var/mob/living/carbon/carbon_user = user
	var/choice = input(carbon_user, "What do you wish to do?", "Master Rune") as anything in list("Link Soul", "Unlink a Soul", "Toggle Sub Rune", "Cancel")
	switch(choice)
		if("Link Soul")
			link_soul(carbon_user)
		if("Unlink a Soul")
			var/obj/structure/resurrection_rune/sub_rune = get_sub_rune()
			if(!sub_rune)
				return

			var/selected_name = input(carbon_user, "Choose.", "Souls") as null|anything in sub_rune.resrunecontroler.linked_users_by_name
			if(!selected_name)
				return

			var/mob/living/carbon/linked_target = sub_rune.resrunecontroler.linked_users_by_name[selected_name]
			if(!linked_target)
				return

			sub_rune.resrunecontroler.remove_user(linked_target)
			to_chat(carbon_user, span_blue("They are now damned."))
		if("Toggle Sub Rune")
			disabled_res = !disabled_res
			if(disabled_res)
				to_chat(carbon_user, span_blue("Let them perish."))
			else
				to_chat(carbon_user, span_blue("Another chance."))
		else
			return

/mob/living/carbon/proc/get_rune_linked(obj/structure/resurrection_rune/resrune)
	if(!resrune)
		return
	if(!resrune.main_rune_link)
		resrune.find_master()
	if(!resrune.resrunecontroler)
		return
	if(resrune.resrunecontroler.add_user(src))
		to_chat(src, span_blue("You are protected from Death."))

#undef RUNE_DAMAGE_THRESHOLD
#undef RUNE_BRUTE_DAMAGE_SCALE
#undef RUNE_BURN_DAMAGE_SCALE
#undef RUNE_REBUILD_DELAY
#undef RUNE_REVIVE_DELAY
#undef RUNE_REVIVE_LOCKOUT
