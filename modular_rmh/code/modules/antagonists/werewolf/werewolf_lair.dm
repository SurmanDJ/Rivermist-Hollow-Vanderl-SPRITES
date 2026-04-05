/proc/is_werewolf_lair_natural_wall(turf/target_wall)
	if(istype(target_wall, /turf/closed/mineral))
		return TRUE
	if(istype(target_wall, /turf/closed/wall/mineral))
		return target_wall.type == /turf/closed/wall/mineral
	return FALSE

/datum/antagonist/werewolf
	var/lair_created = FALSE
	var/datum/weakref/lair_entrance_ref

/datum/antagonist/werewolf/proc/initialize_werewolf_lair_ability()
	sync_werewolf_lair_creation_spell()

/datum/antagonist/werewolf/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	remove_werewolf_lair_creation_spell(old_body)
	sync_werewolf_lair_creation_spell()
	sync_werewolf_contract_assignments()
	sync_werewolf_contract_actions()
	refresh_werewolf_contract_browser_if_open()

/datum/antagonist/werewolf/proc/cleanup_werewolf_lair()
	remove_werewolf_lair_creation_spell()

	var/obj/structure/werewolf_lair_entrance/lair_entrance = get_werewolf_lair_entrance()
	lair_entrance_ref = null
	if(lair_entrance)
		qdel(lair_entrance)

/datum/antagonist/werewolf/proc/get_werewolf_lair_entrance()
	if(!lair_entrance_ref)
		return null

	var/obj/structure/werewolf_lair_entrance/lair_entrance = lair_entrance_ref.resolve()
	if(lair_entrance)
		return lair_entrance

	lair_entrance_ref = null
	return null

/datum/antagonist/werewolf/proc/can_create_werewolf_lair()
	if(lair_created)
		return FALSE
	return !get_werewolf_lair_entrance()

/datum/antagonist/werewolf/proc/register_werewolf_lair(obj/structure/werewolf_lair_entrance/lair_entrance)
	if(!istype(lair_entrance))
		return FALSE

	lair_created = TRUE
	lair_entrance_ref = WEAKREF(lair_entrance)
	return TRUE

/datum/antagonist/werewolf/proc/remove_werewolf_lair_creation_spell(mob/living/carbon/human/spell_holder = owner?.current)
	if(!istype(spell_holder))
		return

	spell_holder.remove_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair)

/datum/antagonist/werewolf/proc/sync_werewolf_lair_creation_spell()
	var/mob/living/carbon/human/current_mob = owner?.current
	if(!istype(current_mob))
		return

	if(transformed && can_create_werewolf_lair())
		current_mob.add_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair, source = src)
		return

	current_mob.remove_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair)

/area/pocket_dimension/werewolf_lair
	name = "Werewolf Lair"

/datum/map_template/pocket/werewolf_lair
	name = "Werewolf Lair"
	id = "pocket_werewolf_lair"
	mappath = "modular_rmh/_maps/templates/pockets/pocket_werewolf_lair.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	persistence_mode = POCKET_PERSISTENCE_MOVABLES

/obj/structure/werewolf_lair_entrance
	name = "clawed-out lair"
	desc = "A clawed burrow mouth hidden against the wild wall. The air beyond smells of damp earth, wet fur, and the moon."
	icon = 'icons/turf/floors.dmi'
	icon_state = "hole1"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/weakref/owner_werewolf_ref
	var/list/invited_werewolf_ckeys

/obj/structure/werewolf_lair_entrance/Initialize(mapload, datum/antagonist/werewolf/owner_werewolf, turf/dug_wall)
	. = ..()
	invited_werewolf_ckeys = list()

	if(!mapload && !owner_werewolf)
		return INITIALIZE_HINT_QDEL

	if(istype(dug_wall))
		setDir(get_dir(src, dug_wall))
	else
		refresh_wall_visual_offset()

	if(mapload)
		return .

	owner_werewolf_ref = WEAKREF(owner_werewolf)

/obj/structure/werewolf_lair_entrance/setDir(newdir)
	..()
	refresh_wall_visual_offset()

/obj/structure/werewolf_lair_entrance/proc/refresh_wall_visual_offset()
	var/pixel_offset_x = 0
	var/pixel_offset_y = 0

	switch(dir)
		if(NORTH)
			pixel_offset_y = ICON_SIZE_Y
		if(SOUTH)
			pixel_offset_y = -ICON_SIZE_Y
		if(EAST)
			pixel_offset_x = ICON_SIZE_X
		if(WEST)
			pixel_offset_x = -ICON_SIZE_X

	set_base_pixel_x(pixel_offset_x)
	set_base_pixel_y(pixel_offset_y)

/obj/structure/werewolf_lair_entrance/Destroy()
	if(SSpocket_dimensions)
		SSpocket_dimensions.delete_instance(get_pocket_instance_key(), "The lair collapses and throws everything back outside!")

	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(owner_werewolf)
		var/obj/structure/werewolf_lair_entrance/current_lair = owner_werewolf.get_werewolf_lair_entrance()
		if(current_lair == src)
			owner_werewolf.lair_entrance_ref = null

	invited_werewolf_ckeys = null
	owner_werewolf_ref = null
	return ..()

/obj/structure/werewolf_lair_entrance/attack_hand(mob/user, list/modifiers)
	. = ..()
	try_enter_user(user)

/obj/structure/werewolf_lair_entrance/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_manage_invites(user, TRUE))
		return ..()

	show_invite_management_menu(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/werewolf_lair_entrance/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(istype(attacking_item, /obj/item/grabbing))
		var/obj/item/grabbing/grab_item = attacking_item
		if(handle_grabbed_entry(user, grab_item))
			return TRUE

	return ..()

/obj/structure/werewolf_lair_entrance/examine(mob/user)
	. = ..()
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		. += span_warning("The burrow has gone dead and still.")
		return .

	if(IS_WEREWOLF(user) == owner_werewolf)
		. += span_notice("Right-click to manage invitations for other werewolves.")
		if(length(invited_werewolf_ckeys))
			. += span_notice("Invited werewolves: [english_list(get_invited_display_names())].")
		else
			. += span_notice("No other werewolves have been invited yet.")

/obj/structure/werewolf_lair_entrance/proc/get_owner_werewolf()
	if(!owner_werewolf_ref)
		return null

	var/datum/antagonist/werewolf/owner_werewolf = owner_werewolf_ref.resolve()
	if(owner_werewolf)
		return owner_werewolf

	owner_werewolf_ref = null
	return null

/obj/structure/werewolf_lair_entrance/proc/get_pocket_instance_key()
	return "werewolf_lair::[REF(src)]"

/obj/structure/werewolf_lair_entrance/proc/get_pocket_instance()
	return SSpocket_dimensions?.get_instance(get_pocket_instance_key())

/obj/structure/werewolf_lair_entrance/proc/get_or_create_pocket_instance()
	return SSpocket_dimensions?.get_or_create_instance(get_pocket_instance_key(), /datum/map_template/pocket/werewolf_lair, POCKET_LIFECYCLE_KEEP_LOADED, 0)

/obj/structure/werewolf_lair_entrance/proc/try_enter_user(mob/living/user)
	if(!can_user_enter_lair(user, FALSE, TRUE))
		return FALSE

	var/datum/pocket_dimension/pocket_instance = get_or_create_pocket_instance()
	if(!pocket_instance)
		to_chat(user, span_warning("The lair refuses to open right now."))
		return FALSE

	to_chat(user, span_notice("I slip into the lair."))
	return pocket_instance.enter_mob(user, get_turf(src), src)

/obj/structure/werewolf_lair_entrance/proc/handle_grabbed_entry(mob/living/user, obj/item/grabbing/grab_item)
	if(!istype(user) || !istype(grab_item))
		return FALSE
	if(user.used_intent.type != /datum/intent/grab/move && user.used_intent.type != /datum/intent/grab/shove)
		return FALSE
	if(!can_werewolf_use_lair(user, TRUE))
		return FALSE

	var/mob/living/victim = grab_item.grabbed
	if(!istype(victim))
		to_chat(user, span_warning("Only living prey can be forced through the lair mouth."))
		return TRUE

	var/follow_inside = user.used_intent.type == /datum/intent/grab/move
	if(!force_movable_inside(user, victim, follow_inside))
		return TRUE

	user.stop_pulling()
	qdel(grab_item)
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/force_movable_inside(mob/living/user, atom/movable/movable, follow_inside = FALSE)
	if(!movable || QDELETED(movable))
		return FALSE

	var/datum/pocket_dimension/pocket_instance = get_or_create_pocket_instance()
	if(!pocket_instance)
		to_chat(user, span_warning("The lair mouth refuses to open right now."))
		return FALSE

	var/turf/entrance_turf = get_turf(src)
	if(!pocket_instance.send_movable_inside(movable, entrance_turf, null, src))
		to_chat(user, span_warning("[movable] won't fit through the lair mouth."))
		return FALSE

	if(follow_inside && !pocket_instance.enter_mob(user, entrance_turf, src))
		to_chat(user, span_warning("The lair takes [movable], but bars my way."))
		return FALSE

	var/mob/living/victim = movable
	if(istype(victim))
		log_combat(user, victim, follow_inside ? "dragged into a werewolf lair" : "shoved into a werewolf lair")

	user.visible_message(
		span_warning("[user] [follow_inside ? "drags" : "shoves"] [movable] into [src]!"),
		span_notice("I [follow_inside ? "drag" : "shove"] [movable] into [src]."),
	)
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/can_user_enter_lair(mob/living/user, forced = FALSE, show_feedback = FALSE)
	if(!istype(user))
		return FALSE

	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE

	if(is_owner_werewolf(user, owner_werewolf))
		return TRUE

	if(is_invited_werewolf(user))
		return TRUE

	if(forced)
		return TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(has_moonshackle_access(human_user))
			return TRUE

	if(show_feedback)
		to_chat(user, span_warning(get_access_denial_message(user)))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/can_werewolf_use_lair(mob/living/user, show_feedback = FALSE)
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE

	if(is_owner_werewolf(user, owner_werewolf) || is_invited_werewolf(user))
		return TRUE

	if(show_feedback)
		to_chat(user, span_warning("Only the lair's owner or an invited werewolf can use this entrance that way."))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/is_owner_werewolf(mob/living/user, datum/antagonist/werewolf/owner_werewolf = null)
	owner_werewolf ||= get_owner_werewolf()
	if(!owner_werewolf)
		return FALSE
	return IS_WEREWOLF(user) == owner_werewolf

/obj/structure/werewolf_lair_entrance/proc/is_invited_werewolf(mob/living/user)
	var/datum/antagonist/werewolf/requesting_werewolf = IS_WEREWOLF(user)
	if(!requesting_werewolf)
		return FALSE
	if(!length(invited_werewolf_ckeys))
		return FALSE
	return user.ckey in invited_werewolf_ckeys

/obj/structure/werewolf_lair_entrance/proc/has_moonshackle_access(mob/living/carbon/human/human_user)
	if(istype(human_user.wear_neck, /obj/item/clothing/neck/moonshackle_collar))
		return TRUE

	for(var/obj/item/held_item as anything in human_user.held_items)
		if(istype(held_item, /obj/item/clothing/neck/moonshackle_collar))
			return TRUE

	return FALSE

/obj/structure/werewolf_lair_entrance/proc/get_access_denial_message(mob/living/user)
	if(IS_WEREWOLF(user))
		return "This lair belongs to another werewolf. I need an invitation to enter."
	return "I need a moonshackle collar, or a werewolf to force me through, before the lair will take me."

/obj/structure/werewolf_lair_entrance/proc/can_manage_invites(mob/living/user, show_feedback = FALSE)
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE
	if(!istype(user))
		return FALSE
	if(!user.Adjacent(src))
		if(show_feedback)
			to_chat(user, span_warning("I need to stand by my lair entrance first."))
		return FALSE
	if(IS_WEREWOLF(user) == owner_werewolf)
		return TRUE
	if(show_feedback)
		to_chat(user, span_warning("Only the lair's owner can manage invitations."))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/show_invite_management_menu(mob/living/user)
	var/choice = tgui_alert(user, "What do I want to do with my lair?", "Moon Lair", list("Invite", "Revoke", "Cancel"))
	if(!choice || choice == "Cancel")
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	switch(choice)
		if("Invite")
			return invite_werewolf_by_name(user)
		if("Revoke")
			return revoke_werewolf_by_name(user)

	return FALSE

/obj/structure/werewolf_lair_entrance/proc/invite_werewolf_by_name(mob/living/user)
	var/invitee_name = stripped_input(user, "Enter the name of the werewolf to invite.", "Moon Lair", "", MAX_NAME_LEN)
	if(!invitee_name)
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	var/datum/mind/invitee_mind = find_werewolf_mind_by_name(invitee_name)
	if(!invitee_mind)
		to_chat(user, span_warning("No werewolf by that name answers the moon."))
		return FALSE

	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(invitee_mind == owner_werewolf?.owner)
		to_chat(user, span_notice("It is already my lair."))
		return FALSE

	var/mob/living/carbon/human/invitee = invitee_mind.current
	if(!istype(invitee) || !invitee.ckey)
		to_chat(user, span_warning("That werewolf is not in a form I can invite right now."))
		return FALSE

	if(invitee.ckey in invited_werewolf_ckeys)
		to_chat(user, span_notice("[invitee] already knows the way into my lair."))
		return FALSE

	invited_werewolf_ckeys += invitee.ckey
	to_chat(user, span_notice("[invitee] is now welcome in my lair."))
	to_chat(invitee, span_notice("[user] invites me into [user.p_their()] lair."))
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/revoke_werewolf_by_name(mob/living/user)
	if(!length(invited_werewolf_ckeys))
		to_chat(user, span_notice("No werewolves are currently invited into my lair."))
		return FALSE

	var/revoke_name = stripped_input(user, "Enter the name of the werewolf to revoke.", "Moon Lair", "", MAX_NAME_LEN)
	if(!revoke_name)
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	var/revoked_ckey = find_invited_werewolf_ckey_by_name(revoke_name)
	if(!revoked_ckey)
		to_chat(user, span_warning("No invited werewolf matches that name."))
		return FALSE

	invited_werewolf_ckeys -= revoked_ckey
	to_chat(user, span_notice("That werewolf is no longer welcome in my lair."))

	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.current)
			continue
		if(werewolf_mind.current.ckey != revoked_ckey)
			continue
		to_chat(werewolf_mind.current, span_warning("[user] has revoked your invitation to [user.p_their()] lair."))
		break

	return TRUE

/obj/structure/werewolf_lair_entrance/proc/find_werewolf_mind_by_name(search_name)
	var/needle = lowertext(search_name)

	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.has_antag_datum(/datum/antagonist/werewolf))
			continue

		var/mob/living/carbon/human/current_mob = werewolf_mind.current
		if(!istype(current_mob))
			continue
		if(lowertext(current_mob.real_name) == needle || lowertext(current_mob.name) == needle)
			return werewolf_mind

	return null

/obj/structure/werewolf_lair_entrance/proc/find_invited_werewolf_ckey_by_name(search_name)
	var/search_ckey = ckey(search_name)
	if(search_ckey in invited_werewolf_ckeys)
		return search_ckey

	var/needle = lowertext(search_name)
	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.has_antag_datum(/datum/antagonist/werewolf))
			continue

		var/mob/living/carbon/human/current_mob = werewolf_mind.current
		if(!istype(current_mob) || !(current_mob.ckey in invited_werewolf_ckeys))
			continue
		if(lowertext(current_mob.real_name) == needle || lowertext(current_mob.name) == needle)
			return current_mob.ckey

	return null

/obj/structure/werewolf_lair_entrance/proc/get_invited_display_names()
	var/list/display_names = list()
	if(!length(invited_werewolf_ckeys))
		return display_names

	for(var/invited_ckey in invited_werewolf_ckeys)
		var/display_name = invited_ckey
		for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
			var/mob/living/carbon/human/current_mob = werewolf_mind?.current
			if(!istype(current_mob) || current_mob.ckey != invited_ckey)
				continue
			display_name = current_mob.real_name
			break
		display_names += display_name

	return display_names
