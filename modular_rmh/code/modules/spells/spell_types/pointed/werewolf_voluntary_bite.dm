/datum/action/cooldown/spell/werewolf_voluntary_bite
	name = "Voluntary Bite"
	desc = "Offer the mooncurse through a deliberate bite to a willing human."
	button_icon_state = "tamebeast"
	active_msg = "Choose a willing human to offer the mooncurse."
	deactive_msg = "You lower your fangs."

	spell_type = SPELL_RAGE
	antimagic_flags = NONE
	has_visual_effects = FALSE
	charge_required = FALSE
	cooldown_time = WW_VOLUNTARY_BITE_COOLDOWN
	self_cast_possible = FALSE
	cast_range = 1

/datum/action/cooldown/spell/werewolf_voluntary_bite/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/werewolf_voluntary_bite/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(target == owner)
		to_chat(owner, span_warning("I cannot offer the mooncurse to myself."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(target.stat != CONSCIOUS)
		to_chat(owner, span_warning("They need to be awake to choose the mooncurse."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!target.client || !target.mind)
		to_chat(owner, span_warning("Only a living soul can willingly accept the mooncurse."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(target.werewolf_conversion_prompt_pending)
		to_chat(owner, span_warning("They are already deciding on the mooncurse."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST
	if(!target.can_werewolf())
		to_chat(owner, span_warning("The mooncurse cannot take hold in them."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/werewolf_voluntary_bite/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/source = owner
	var/mob/living/carbon/human/target = cast_on
	if(!istype(source) || !istype(target))
		return FALSE

	log_combat(source, target, "offered werewolf bite")
	source.visible_message(
		span_warning("[source] offers [target] the mooncurse with a deliberate bite."),
		span_notice("I offer [target] the mooncurse with a deliberate bite."),
	)

	if(!target.offer_voluntary_werewolf_bite(source))
		to_chat(source, span_warning("The moment to share the mooncurse slips away."))
		return FALSE

	return TRUE
