
/obj/item/organ/genitals/penis/ovipositor
	name = "ovipositor"
	penis_type = PENIS_TYPE_OVIPOSITOR
	sheath_type = SHEATH_TYPE_NORMAL
	ovi_egg_type = OVI_EGG_NORMAL
	egg_clutch_size = 1
	var/custom_egg_name = ""
	var/custom_egg_desc = ""
	var/custom_egg_color = null
	var/resource_dependent_yield = FALSE

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

/obj/item/organ/genitals/penis/ovipositor/proc/set_clutch_size(new_size)
	if(isnull(new_size))
		return egg_clutch_size

	egg_clutch_size = max(1, round(new_size))

	var/datum/component/ovipositor/ovipositor_component = GetComponent(/datum/component/ovipositor)
	ovipositor_component?.set_clutch_size(egg_clutch_size)
	return egg_clutch_size

// Keep the organ type and the oviposition behavior separate so character prefs can pick
// the anatomy while quirks or mob setup decide whether it is actually functional.
/proc/set_ovipositor_functionality(obj/item/organ/genitals/penis/ovipositor, enabled = TRUE)
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

/proc/get_oviposition_egg_type_option_name(option)
	switch(option)
		if(OVI_EGG_NORMAL)
			return "Safe (Normal)"
		if(OVI_EGG_HARPY)
			return "Harpy"
	return "[option]"

/datum/sprite_accessory/genitals/penis/ovipositor
	name = "Ovipositor"
	icon_state = "tapered"
	color_key_defaults = list(KEY_CHEST_COLOR, KEY_CHEST_COLOR)

/datum/customizer_choice/organ/genitals/penis/ovipositor
	name = "Ovipositor"
	organ_type = /obj/item/organ/genitals/penis/ovipositor
	sprite_accessories = list(/datum/sprite_accessory/genitals/penis/ovipositor)

/datum/quirk/peculiarity/ovipositor
	name = "Oviposition"
	desc = "My 'penis' is a functional ovipositor and can be used to lay eggs."
	customization_label = "Choose Egg Type"
	customization_options = list(
		OVI_EGG_NORMAL,
	)
	extra_customization_fields = list(
		list("key" = "clutch_size", "label" = "Clutch Size", "type" = QUIRK_NUMBER, "default" = 1, "min" = 1, "max" = 6),
		list("key" = "custom_name", "label" = "Custom Egg Name", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "Leave blank for default"),
		list("key" = "custom_desc", "label" = "Custom Egg Desc", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "Leave blank for default"),
		list("key" = "custom_color", "label" = "Egg Color (hex)", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "#RRGGBB or blank"),
		list("key" = "resource_dependent", "label" = "Resource-Dependent Yield", "type" = QUIRK_SELECT, "default" = "No", "options" = list("No", "Yes")),
	)

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
	if(!customization_value || !(customization_value in customization_options))
		customization_value = OVI_EGG_NORMAL

	var/obj/item/organ/genitals/penis/ovipositor/ovipositor_organ = owner?.getorganslot(ORGAN_SLOT_PENIS)
	if(!ovipositor_organ)
		return
	ovipositor_organ.set_egg_type(customization_value)

	var/clutch = text2num(get_extra_value("clutch_size", 1))
	ovipositor_organ.set_clutch_size(max(1, clutch))

	ovipositor_organ.custom_egg_name = get_extra_value("custom_name", "")
	ovipositor_organ.custom_egg_desc = get_extra_value("custom_desc", "")
	ovipositor_organ.custom_egg_color = sanitize_oviposition_color(get_extra_value("custom_color", ""))
	ovipositor_organ.resource_dependent_yield = (get_extra_value("resource_dependent", "No") == "Yes")

	set_ovipositor_functionality(ovipositor_organ, TRUE)

/datum/quirk/peculiarity/ovipositor/on_remove()
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor_organ = owner?.getorganslot(ORGAN_SLOT_PENIS)
	set_ovipositor_functionality(ovipositor_organ, FALSE)

/datum/quirk/peculiarity/ovipositor/get_option_name(option)
	return get_oviposition_egg_type_option_name(option)

/datum/quirk/peculiarity/egg_layer
	name = "Egg Layer"
	desc = "My womb slowly forms eggs on its own."
	customization_label = "Choose Egg Type"
	customization_options = list(
		OVI_EGG_NORMAL,
	)
	extra_customization_fields = list(
		list("key" = "clutch_size", "label" = "Max Eggs in Womb", "type" = QUIRK_NUMBER, "default" = 3, "min" = 1, "max" = 6),
		list("key" = "custom_name", "label" = "Custom Egg Name", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "Leave blank for default"),
		list("key" = "custom_desc", "label" = "Custom Egg Desc", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "Leave blank for default"),
		list("key" = "custom_color", "label" = "Egg Color (hex)", "type" = QUIRK_TEXT, "default" = "", "placeholder" = "#RRGGBB or blank"),
		list("key" = "resource_dependent", "label" = "Resource-Dependent Yield", "type" = QUIRK_SELECT, "default" = "No", "options" = list("No", "Yes")),
	)

/datum/quirk/peculiarity/egg_layer/is_available(datum/preferences/prefs)
	if(!..())
		return FALSE
	if(!prefs)
		return TRUE

	var/datum/customizer_entry/organ/genitals/vagina/vagina_entry = prefs.get_customizer_entry_of_type(/datum/customizer_entry/organ/genitals/vagina)
	return vagina_entry && !vagina_entry.disabled

/datum/quirk/peculiarity/egg_layer/on_spawn()
	if(!customization_value || !(customization_value in customization_options))
		customization_value = OVI_EGG_NORMAL

	if(!owner)
		return

	ADD_TRAIT(owner, TRAIT_EGG_LAYER, "[type]")
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.update_check_eggs_verb()

	var/obj/item/organ/genitals/filling_organ/vagina/vagina = owner.getorganslot(ORGAN_SLOT_VAGINA)
	if(vagina)
		var/clutch = text2num(get_extra_value("clutch_size", 3))
		vagina.oviposition_egg_production_limit = max(1, clutch)
		vagina.custom_egg_name = get_extra_value("custom_name", "")
		vagina.custom_egg_desc = get_extra_value("custom_desc", "")
		vagina.custom_egg_color = sanitize_oviposition_color(get_extra_value("custom_color", ""))
		vagina.resource_dependent_yield = (get_extra_value("resource_dependent", "No") == "Yes")

/datum/quirk/peculiarity/egg_layer/on_remove()
	if(!owner)
		return

	REMOVE_TRAIT(owner, TRAIT_EGG_LAYER, "[type]")
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.update_check_eggs_verb()

	var/obj/item/organ/genitals/filling_organ/vagina/vagina = owner.getorganslot(ORGAN_SLOT_VAGINA)
	if(vagina)
		vagina.oviposition_egg_production_limit = initial(vagina.oviposition_egg_production_limit)
		vagina.custom_egg_name = ""
		vagina.custom_egg_desc = ""
		vagina.custom_egg_color = null
		vagina.resource_dependent_yield = FALSE

/datum/quirk/peculiarity/egg_layer/get_option_name(option)
	return get_oviposition_egg_type_option_name(option)

/// Validates a hex color string for oviposition egg tinting. Returns null if invalid.
/proc/sanitize_oviposition_color(color_input)
	if(!color_input || !istext(color_input))
		return null
	var/color = trim(color_input)
	if(!length(color))
		return null
	// Accept #RGB, #RRGGBB, #RRGGBBAA formats
	var/static/regex/hex_color = regex("^#\[0-9a-fA-F\]{3}(\[0-9a-fA-F\]{3}(\[0-9a-fA-F\]{2})?)?$")
	if(!hex_color.Find(color))
		return null
	return color
