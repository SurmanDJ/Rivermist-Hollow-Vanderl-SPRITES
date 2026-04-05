/datum/action/cooldown/spell/pointed/werewolf_create_lair
	name = "Dig Lair"
	desc = "Dig a hidden lair into a natural wall. You can do this only once."
	button_icon_state = "shapeshifted"
	active_msg = "Choose a natural wall to claw open for your lair."
	deactive_msg = "You still the digging frenzy."

	spell_type = SPELL_RAGE
	antimagic_flags = NONE
	has_visual_effects = FALSE
	charge_required = FALSE
	self_cast_possible = FALSE
	cast_range = 1

/datum/action/cooldown/spell/pointed/werewolf_create_lair/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	var/turf/target_wall = get_turf(cast_on)
	if(!is_werewolf_lair_natural_wall(target_wall))
		return FALSE

	var/turf/source_turf = get_turf(owner)
	if(isturf(source_turf) && !(get_dir(source_turf, target_wall) in GLOB.cardinals))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/werewolf_create_lair/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/mob/living/carbon/human/source = owner
	var/datum/antagonist/werewolf/source_werewolf = IS_WEREWOLF(source)
	var/turf/target_wall = get_turf(cast_on)
	var/turf/source_turf = get_turf(source)
	if(!istype(source) || !source_werewolf)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!source_werewolf.can_create_werewolf_lair())
		to_chat(source, span_warning("I have already claimed my lair."))
		source_werewolf.remove_werewolf_lair_creation_spell()
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!istype(target_wall) || !is_werewolf_lair_natural_wall(target_wall))
		to_chat(source, span_warning("My lair must be dug into a wild cave wall, not crafted stone or timber."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!isturf(source_turf) || source_turf.density)
		to_chat(source, span_warning("I need solid footing before I can dig out a lair."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!source.Adjacent(target_wall))
		to_chat(source, span_warning("I need to be right beside the wall I want to dig through."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!(get_dir(source_turf, target_wall) in GLOB.cardinals))
		to_chat(source, span_warning("I need to face the wall head-on before I can dig my lair into it."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(locate(/obj/structure/werewolf_lair_entrance) in source_turf)
		to_chat(source, span_warning("There is already a burrow mouth here."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	return . | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/werewolf_create_lair/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/source = owner
	var/datum/antagonist/werewolf/source_werewolf = IS_WEREWOLF(source)
	var/turf/target_wall = get_turf(cast_on)
	if(!istype(source) || !source_werewolf || !istype(target_wall))
		return FALSE

	source.visible_message(
		span_warning("[source] starts clawing a hidden lair into [target_wall]!"),
		span_notice("I dig my claws into [target_wall] and start carving out a lair."),
	)
	playsound(target_wall, 'sound/items/dig_shovel.ogg', 100, FALSE)

	if(!do_after(source, WW_LAIR_CREATION_TIME, target_wall))
		to_chat(source, span_warning("I abandon the lair before it is ready."))
		return FALSE

	if(!source_werewolf.can_create_werewolf_lair())
		return FALSE
	if(!istype(target_wall) || !is_werewolf_lair_natural_wall(target_wall))
		to_chat(source, span_warning("The wall is no longer fit for a lair."))
		return FALSE
	if(!source.Adjacent(target_wall))
		to_chat(source, span_warning("I stray too far from the wall and lose the shape of the burrow."))
		return FALSE
	var/turf/source_turf = get_turf(source)
	if(!isturf(source_turf))
		return FALSE
	if(!(get_dir(source_turf, target_wall) in GLOB.cardinals))
		to_chat(source, span_warning("I need to dig straight into the wall to hold the lair open."))
		return FALSE
	if(locate(/obj/structure/werewolf_lair_entrance) in source_turf)
		to_chat(source, span_warning("There is no room to open the lair mouth here."))
		return FALSE

	var/obj/structure/werewolf_lair_entrance/lair_entrance = new(source_turf, source_werewolf, target_wall)
	if(!istype(lair_entrance))
		to_chat(source, span_warning("The lair mouth caves in before it can settle."))
		return FALSE

	source_werewolf.register_werewolf_lair(lair_entrance)
	source.visible_message(
		span_warning("[source] tears open a hidden lair mouth!"),
		span_notice("The moon answers, and my lair opens at last."),
	)
	playsound(source_turf, 'sound/foley/doors/stoneopen.ogg', 80, FALSE)
	return TRUE

/datum/action/cooldown/spell/pointed/werewolf_create_lair/after_cast(atom/cast_on)
	. = ..()

	var/datum/antagonist/werewolf/source_werewolf = IS_WEREWOLF(owner)
	if(!source_werewolf)
		return

	// Successful digs consume the spell, but delaying the sync until after Activate()
	// finishes avoids tearing down the active click action mid-cast.
	addtimer(CALLBACK(source_werewolf, TYPE_PROC_REF(/datum/antagonist/werewolf, sync_werewolf_lair_creation_spell)), 0)
