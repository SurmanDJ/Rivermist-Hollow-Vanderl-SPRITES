/// Verb for players to check the status of their oviposition organs and eggs via TGUI.
/mob/living/carbon/human/verb/check_eggs()
	set name = "Check Eggs"
	set category = "IC"
	set desc = "Focus inward to feel the state of any eggs inside you."

	if(stat == DEAD)
		to_chat(src, span_warning("I can't feel anything. I'm dead."))
		return

	var/datum/oviposition_status_menu/menu = new(src)
	menu.ui_interact(src)

/datum/oviposition_status_menu
	var/mob/living/carbon/human/owner

/datum/oviposition_status_menu/New(mob/living/carbon/human/_owner)
	owner = _owner

/datum/oviposition_status_menu/Destroy()
	owner = null
	return ..()

/datum/oviposition_status_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/oviposition_status_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvipositionStatus")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/oviposition_status_menu/ui_close(mob/user)
	qdel(src)

/datum/oviposition_status_menu/ui_data(mob/user)
	var/list/data = list()

	if(!owner || QDELETED(owner))
		return data

	data["sections"] = list()

	// --- Ovipositor ---
	var/obj/item/organ/genitals/penis/ovipositor/ovi_organ = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(istype(ovi_organ))
		var/datum/component/ovipositor/ovi_comp = ovi_organ.GetComponent(/datum/component/ovipositor)
		if(ovi_comp)
			var/list/ovi_data = list()
			ovi_data["type"] = "ovipositor"
			ovi_data["title"] = "Ovipositor"
			ovi_data["eggs_stored"] = ovi_comp.eggs_stored
			ovi_data["max_stored"] = ovi_comp.get_max_stored_eggs()
			ovi_data["clutch_size"] = ovi_comp.get_clutch_size()
			ovi_data["resource_dependent"] = ovi_organ.resource_dependent_yield
			if(ovi_organ.resource_dependent_yield)
				ovi_data["nutriment"] = round(owner.get_reagent_amount(/datum/reagent/consumable/nutriment), 0.1)
			if(ovi_organ.custom_egg_name && length(ovi_organ.custom_egg_name))
				ovi_data["custom_name"] = ovi_organ.custom_egg_name
			if(ovi_organ.custom_egg_color)
				ovi_data["custom_color"] = ovi_organ.custom_egg_color
			UNTYPED_LIST_ADD(data["sections"], ovi_data)

	// --- Womb / Vagina ---
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = owner.getorganslot(ORGAN_SLOT_VAGINA)
	if(vagina && vagina.supports_oviposition_pregnancy())
		var/is_egg_layer = HAS_TRAIT(owner, TRAIT_EGG_LAYER)
		var/list/all_eggs = vagina.get_oviposition_eggs()
		var/egg_count = length(all_eggs)
		var/hatchling_count = vagina.count_internal_womb_hatchlings()

		if(egg_count || hatchling_count || is_egg_layer)
			var/list/womb_data = list()
			womb_data["type"] = "womb"
			womb_data["title"] = "Womb"
			womb_data["is_egg_layer"] = is_egg_layer
			womb_data["hatchling_count"] = hatchling_count

			if(is_egg_layer)
				var/limit = vagina.oviposition_egg_production_limit
				womb_data["egg_count"] = egg_count
				womb_data["egg_limit"] = limit
				womb_data["resource_dependent"] = vagina.resource_dependent_yield
				if(vagina.resource_dependent_yield)
					womb_data["nutriment"] = round(owner.get_reagent_amount(/datum/reagent/consumable/nutriment), 0.1)
				if(vagina.next_oviposition_egg_generation > 0 && egg_count < limit)
					var/remaining = max(0, vagina.next_oviposition_egg_generation - world.time)
					womb_data["next_egg_seconds"] = round(remaining / 10, 1)
					womb_data["interval_seconds"] = round(vagina.oviposition_egg_production_interval / 10, 1)

			womb_data["eggs"] = build_egg_list(vagina)
			UNTYPED_LIST_ADD(data["sections"], womb_data)

	// --- Other organs (anus, guts) ---
	for(var/slot in list(ORGAN_SLOT_ANUS, ORGAN_SLOT_GUTS))
		var/obj/item/organ/other_organ = owner.getorganslot(slot)
		if(!other_organ || !other_organ.supports_oviposition_pregnancy())
			continue
		var/list/other_eggs = other_organ.get_oviposition_eggs()
		if(!length(other_eggs))
			continue
		var/list/other_data = list()
		other_data["type"] = "other"
		other_data["title"] = capitalize(other_organ.get_oviposition_location_name())
		other_data["eggs"] = build_egg_list(other_organ)
		UNTYPED_LIST_ADD(data["sections"], other_data)

	return data

/datum/oviposition_status_menu/proc/build_egg_list(obj/item/organ/organ)
	var/list/egg_list = list()
	if(!organ)
		return egg_list

	for(var/obj/item/oviposition_egg/egg as anything in organ.get_oviposition_eggs())
		var/list/egg_data = list()
		egg_data["name"] = egg.name
		egg_data["egg_type"] = egg.egg_type
		egg_data["custom_color"] = egg.custom_egg_color

		var/datum/component/pregnancy/preg = egg.get_pregnancy_component()
		if(preg)
			egg_data["growing"] = TRUE
			egg_data["stage"] = preg.stage
			egg_data["max_stage"] = preg.max_stage
			egg_data["fertilized"] = preg.fertilized
			egg_data["laid"] = preg.laid
			egg_data["ready"] = (preg.stage >= preg.max_stage)
			egg_data["hatch_inside"] = egg.hatch_inside_host
		else
			egg_data["growing"] = FALSE

		UNTYPED_LIST_ADD(egg_list, egg_data)

	return egg_list
