
/obj/item/organ/genitals/penis/ovipositor
	name = "ovipositor"
	penis_type = PENIS_TYPE_OVIPOSITOR
	sheath_type = SHEATH_TYPE_NORMAL
	var/ovi_egg_type = OVI_EGG_NORMAL

/obj/item/organ/genitals/penis/ovipositor/Insert(mob/living/M, special, drop_if_replaced)
	. = ..()
	if(!GetComponent(/datum/component/ovipositor))
		AddComponent(/datum/component/ovipositor)

/obj/item/organ/genitals/penis/ovipositor/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/pubes/comp = GetComponent(/datum/component/body_storage/pubes)
	comp?.RemoveComponent()
	qdel(comp)

/obj/item/organ/genitals/penis/ovipositor/proc/set_egg_type(new_egg_type)
	if(new_egg_type)
		ovi_egg_type = new_egg_type
	return ovi_egg_type

// Keep the organ type and the oviposition behavior separate so character prefs can pick
// the anatomy while quirks or mob setup decide whether it is actually functional.
/proc/set_ovipositor_functionality(obj/item/organ/genitals/penis/ovipositor/ovipositor, enabled = TRUE)
	if(!ovipositor)
		return FALSE

	var/datum/component/ovipositor/ovipositor_component = ovipositor.GetComponent(/datum/component/ovipositor)

	if(enabled)
		if(!ovipositor_component)
			ovipositor.AddComponent(/datum/component/ovipositor)
		return TRUE

	if(ovipositor_component)
		qdel(ovipositor_component)
	return TRUE

/proc/ensure_typed_ovipositor(mob/living/owner, egg_type = OVI_EGG_NORMAL)
	if(!owner)
		return null

	var/obj/item/organ/genitals/penis/current_penis = owner.getorganslot(ORGAN_SLOT_PENIS)
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = current_penis

	if(!istype(ovipositor))
		if(current_penis)
			current_penis.Remove(owner, FALSE, FALSE)
			qdel(current_penis)
		ovipositor = new /obj/item/organ/genitals/penis/ovipositor()
		ovipositor.Insert(owner, FALSE, FALSE)

	ovipositor.set_egg_type(egg_type)
	set_ovipositor_functionality(ovipositor, TRUE)
	return ovipositor

/proc/ensure_spider_ovipositor(mob/living/owner)
	return ensure_typed_ovipositor(owner, OVI_EGG_SPIDER)

/proc/ensure_bog_bug_ovipositor(mob/living/owner)
	return ensure_typed_ovipositor(owner, OVI_EGG_BOG_BUG)

/datum/sprite_accessory/genitals/penis/ovipositor
	name = "Ovipositor"
	// Reuse the closest existing preview art until a dedicated ovipositor overlay is added.
	icon_state = "tapered"
	color_key_defaults = list(KEY_CHEST_COLOR, KEY_CHEST_COLOR)

/datum/customizer_choice/organ/genitals/penis/ovipositor
	name = "Ovipositor"
	organ_type = /obj/item/organ/genitals/penis/ovipositor
	sprite_accessories = list(/datum/sprite_accessory/genitals/penis/ovipositor)

/datum/quirk/peculiarity/ovipositor
	name = "Oviposition"
	desc = "My 'penis' is a functional ovipositor and can be used to lay eggs."

/datum/quirk/peculiarity/ovipositor/is_available(datum/preferences/prefs)
	if(!..())
		return FALSE
	if(!prefs)
		return TRUE

	var/datum/customizer_entry/organ/genitals/penis/penis_entry = prefs.get_customizer_entry_of_type(/datum/customizer_entry/organ/genitals/penis)
	if(!penis_entry || penis_entry.disabled)
		return FALSE

	return penis_entry.customizer_choice_type == /datum/customizer_choice/organ/genitals/penis/ovipositor

/datum/quirk/peculiarity/ovipositor/on_spawn()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = owner?.getorganslot(ORGAN_SLOT_PENIS)
	set_ovipositor_functionality(ovipositor, TRUE)

/datum/quirk/peculiarity/ovipositor/on_remove()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = owner?.getorganslot(ORGAN_SLOT_PENIS)
	set_ovipositor_functionality(ovipositor, FALSE)
