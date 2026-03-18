GLOBAL_LIST_EMPTY(global_resurrunes)
GLOBAL_LIST_EMPTY(global_resurrune_markers)

#define RESURRECTION_TRAUMA_DURATION (90 MINUTES)
#define RESURRECTION_TRAUMA_RELIEF (5 MINUTES)
#define RESURRECTION_TRAUMA_PANIC_COOLDOWN (25 SECONDS)
#define RESURRECTION_TRAUMA_BOOZE_COOLDOWN (10 SECONDS)

//#define IS_RES_ELIGIBLE(source) ((source.InBadHealth() && !source.IsSleeping()) || (source.IsSleeping() && source.health < source.crit_threshold))


//For revive - your body DIDN'T rot, but it did suffer damage. Unlike being rotted, this one is only timed. Not forever.
/datum/status_effect/debuff/revived/rune
	id = "revived_rune"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/revived/rune
	effectedstats = list("strength" = -5, "perception" = -5, "intelligence" = -2, "endurance" = -5, "constitution" = -5, "speed" = -5, "fortune" = -1)
	duration = 15 MINUTES		//Should be long enough to stop someone from running back into battle. Plus, this stacks with body-rot debuff. RIP.

/atom/movable/screen/alert/status_effect/debuff/revived/rune
	name = "Rune Fatigue"
	desc = "You felt unfathomable forces course through you, restoring your body and your essance. Your body aches, and you can barely lift your arms, let alone fight."


/datum/status_effect/debuff/revived/rune/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_PACIFISM, "resurrection_rune")
	ADD_TRAIT(owner, TRAIT_NO_SELF_MAGIC, "resurrection_rune")


/datum/status_effect/debuff/revived/rune/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "resurrection_rune")
	REMOVE_TRAIT(owner, TRAIT_NO_SELF_MAGIC, "resurrection_rune")

/datum/status_effect/debuff/revived/rune/rough
	id = "revived_rune_rough"
	effectedstats = list("strength" = -8, "perception" = -8, "intelligence" = -5, "endurance" = -8, "constitution" = -8, "speed" = -8, "fortune" = -5)
	duration = 20 MINUTES

/datum/status_effect/debuff/revived/rune/light
	id = "revived_rune_light"
	effectedstats = list("strength" = -2, "perception" = -2, "intelligence" = -1, "endurance" = -2, "constitution" = -2, "speed" = -2)
	duration = 5 MINUTES

/datum/status_effect/debuff/resurrection_trauma
	id = "resurrection_trauma"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/resurrection_trauma
	duration = RESURRECTION_TRAUMA_DURATION
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	var/fear_mob_type = null
	var/fear_name = "that creature"
	var/next_panic_time = 0
	var/next_booze_relief_time = 0

/datum/status_effect/debuff/resurrection_trauma/on_creation(mob/living/new_owner, duration_override, feared_type, feared_name)
	fear_mob_type = feared_type
	if(feared_name)
		fear_name = feared_name
	return ..()

/datum/status_effect/debuff/resurrection_trauma/on_apply()
	. = ..()
	if(!.)
		return FALSE
	if(!ispath(fear_mob_type, /mob/living))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_PRAY, PROC_REF(on_owner_prayed))
	RegisterSignal(owner, COMSIG_SEX_CLIMAX, PROC_REF(on_owner_climaxed))
	RegisterSignal(owner, COMSIG_CARBON_REAGENT_ADD, PROC_REF(on_reagent_added))
	return TRUE

/datum/status_effect/debuff/resurrection_trauma/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_PRAY)
	UnregisterSignal(owner, COMSIG_SEX_CLIMAX)
	UnregisterSignal(owner, COMSIG_CARBON_REAGENT_ADD)
	return ..()

/datum/status_effect/debuff/resurrection_trauma/tick()
	if(world.time < next_panic_time)
		return
	if(!owner || owner.stat == DEAD)
		return

	for(var/mob/living/seen_creature in view(5, owner))
		if(seen_creature == owner)
			continue
		if(!istype(seen_creature, fear_mob_type))
			continue

		owner.emote("scream")
		owner.Immobilize(1.5 SECONDS)
		owner.add_stress(/datum/stress_event/traumatized)
		to_chat(owner, span_userdanger("You see [seen_creature] and freeze in terror!"))
		next_panic_time = world.time + RESURRECTION_TRAUMA_PANIC_COOLDOWN
		return

/datum/status_effect/debuff/resurrection_trauma/proc/ease_trauma(message)
	if(!owner)
		return

	remove_duration(RESURRECTION_TRAUMA_RELIEF)
	if(owner)
		to_chat(owner, span_notice(message))

/datum/status_effect/debuff/resurrection_trauma/proc/on_owner_prayed(datum/source, prayer)
	SIGNAL_HANDLER
	ease_trauma("Prayer steadies your nerves.")

/datum/status_effect/debuff/resurrection_trauma/proc/on_owner_climaxed(datum/source)
	SIGNAL_HANDLER
	ease_trauma("Pleasure briefly dulls the memory of death.")

/datum/status_effect/debuff/resurrection_trauma/proc/on_reagent_added(datum/source, datum/reagent/added_reagent, added_amount, method)
	SIGNAL_HANDLER
	if(world.time < next_booze_relief_time)
		return
	if(!(method & INGEST))
		return
	if(!istype(added_reagent, /datum/reagent/consumable/ethanol))
		return

	next_booze_relief_time = world.time + RESURRECTION_TRAUMA_BOOZE_COOLDOWN
	ease_trauma("The drink takes the sharpest edge off the memory.")

/atom/movable/screen/alert/status_effect/debuff/resurrection_trauma
	name = "Death Trauma"
	desc = "The creature that killed you still lingers in the back of your mind."

/atom/movable/screen/alert/status_effect/debuff/revived/rune/rough
	name = "Rune Fatigue (rough)"
	desc = "You felt an alien force course through you, restoring your body and your essance almost against your will. Your body aches, and you can barely lift your arms, let alone fight."
	icon_state = "beauty"

#define REVIVAL_FILTER "revival_glow"
///atom/movable/screen/alert/status_effect/debuff/rune_glow
//	name = "Revival Afterglow"
//	desc = "You have been reknit and transported by unfathomable forces. You need time to recover,"
//	icon_state = "revived"

/datum/status_effect/debuff/rune_glow
	var/outline_colour ="#b86cf7"
	id = "rune_revival"
	//alert_type = /atom/movable/screen/alert/status_effect/debuff/rune_glow
	duration = 30 SECONDS
	alert_type = null

/datum/status_effect/debuff/rune_glow/on_apply()
	. = ..()
	var/filter = owner.get_filter(REVIVAL_FILTER)
	owner.SetKnockdown(duration)
	owner.SetStun(duration)
	if (!filter)
		owner.add_filter(REVIVAL_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))

/datum/status_effect/debuff/rune_glow/on_remove()
	. = ..()
	to_chat(owner, span_warning("The revival sickness has eased a little..."))
	owner.remove_filter(REVIVAL_FILTER)

#undef REVIVAL_FILTER

/mob/living/carbon/human
	var/rune_linked = RUNE_LINK_NONE

#undef RESURRECTION_TRAUMA_DURATION
#undef RESURRECTION_TRAUMA_RELIEF
#undef RESURRECTION_TRAUMA_PANIC_COOLDOWN
#undef RESURRECTION_TRAUMA_BOOZE_COOLDOWN
