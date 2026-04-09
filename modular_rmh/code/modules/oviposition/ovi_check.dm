// Egg type constants (for get_egg_type_short_name)
#define OVI_EGG_NORMAL "normal_ovi"
#define OVI_EGG_SPIDER "spider_ovi"
#define OVI_EGG_BOG_BUG "bog_bug_ovi"
#define OVI_EGG_HARPY "harpy_ovi"
#define OVI_EGG_EMBRYO "embryo_ovi"

/// Verb for checking egg status via TGUI.
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

	data["nutriment"] = round(owner.get_reagent_amount(/datum/reagent/consumable/nutriment), 0.1)
	data["organs"] = list()

	// --- Ovipositor ---
	var/obj/item/organ/genitals/penis/ovipositor/ovi_organ = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(istype(ovi_organ))
		var/datum/component/ovipositor/ovi_comp = ovi_organ.GetComponent(/datum/component/ovipositor)
		if(ovi_comp)
			var/list/ovi = list()
			ovi["id"] = "ovipositor"
			ovi["title"] = "OVIPOSITOR"
			ovi["icon"] = "mars"
			ovi["egg_count"] = ovi_comp.eggs_stored
			ovi["egg_capacity"] = ovi_comp.get_max_stored_eggs()
			ovi["clutch_size"] = ovi_comp.get_clutch_size()
			ovi["egg_type_name"] = get_egg_type_short_name(ovi_organ.ovi_egg_type)
			ovi["custom_color"] = ovi_organ.custom_egg_color
			ovi["custom_name"] = ovi_organ.custom_egg_name
			ovi["resource_dependent"] = ovi_organ.resource_dependent_yield
			ovi["egg_stage"] = ovi_comp.egg_stage
			ovi["eggs"] = list()
			UNTYPED_LIST_ADD(data["organs"], ovi)

	// --- Womb ---
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = owner.getorganslot(ORGAN_SLOT_VAGINA)
	var/list/vagina_eggs
	if(vagina && vagina.supports_oviposition_pregnancy())
		vagina_eggs = vagina.get_oviposition_eggs()

	var/is_egg_layer = HAS_TRAIT(owner, TRAIT_EGG_LAYER)
	var/hatchling_count = 0
	if(vagina)
		hatchling_count = vagina.count_internal_womb_hatchlings()

	if(length(vagina_eggs) || hatchling_count || is_egg_layer)
		var/list/womb = list()
		womb["id"] = "womb"
		womb["title"] = "WOMB"
		womb["icon"] = "venus"
		womb["egg_count"] = length(vagina_eggs)
		womb["is_egg_layer"] = is_egg_layer
		womb["hatchling_count"] = hatchling_count
		if(is_egg_layer && vagina)
			womb["egg_capacity"] = vagina.oviposition_egg_production_limit
			womb["resource_dependent"] = vagina.resource_dependent_yield
			if(vagina.next_oviposition_egg_generation > 0 && length(vagina_eggs) < vagina.oviposition_egg_production_limit)
				var/remaining = max(0, vagina.next_oviposition_egg_generation - world.time)
				womb["next_egg_seconds"] = round(remaining / 10, 1)
				womb["interval_seconds"] = round(vagina.oviposition_egg_production_interval / 10, 1)
		womb["eggs"] = list()
		for(var/obj/item/oviposition_egg/egg as anything in vagina_eggs)
			UNTYPED_LIST_ADD(womb["eggs"], build_single_egg(egg))
		UNTYPED_LIST_ADD(data["organs"], womb)

	// --- Other organs (Anus, Guts) ---
	for(var/slot in list(ORGAN_SLOT_ANUS, ORGAN_SLOT_GUTS))
		var/obj/item/organ/organ = owner.getorganslot(slot)
		if(!organ || !organ.supports_oviposition_pregnancy())
			continue
		var/list/organ_eggs = organ.get_oviposition_eggs()
		if(!length(organ_eggs))
			continue
		var/list/od = list()
		od["id"] = slot
		od["title"] = uppertext(organ.get_oviposition_location_name())
		od["icon"] = "circle"
		od["egg_count"] = length(organ_eggs)
		od["eggs"] = list()
		for(var/obj/item/oviposition_egg/egg as anything in organ_eggs)
			UNTYPED_LIST_ADD(od["eggs"], build_single_egg(egg))
		UNTYPED_LIST_ADD(data["organs"], od)

	return data

/datum/oviposition_status_menu/proc/build_single_egg(obj/item/oviposition_egg/egg)
	var/list/d = list()
	d["name"] = egg.name
	d["type_name"] = get_egg_type_short_name(egg.egg_type)
	d["display_color"] = egg.custom_egg_color || egg.color
	d["color_hex"] = egg.custom_egg_color

	var/datum/component/pregnancy/preg = egg.get_pregnancy_component()
	if(preg)
		d["has_preg"] = TRUE
		d["stage"] = preg.stage
		d["max_stage"] = preg.max_stage
		d["progress_pct"] = round((preg.stage / max(1, preg.max_stage)) * 100)
		d["fertilized"] = preg.fertilized
		d["hatch_inside"] = egg.hatch_inside_host
		d["auto_hatch"] = egg.auto_hatch_when_laid
		d["mother_name"] = egg.oviposition_mother_name
		d["father_name"] = preg.father_name
		if(preg.stage >= preg.max_stage)
			d["status"] = "ready"
		else if(preg.stage > 0)
			d["status"] = "growing"
		else
			d["status"] = "dormant"
		if(preg.stage < preg.max_stage && preg.max_stage > 0)
			d["time_left"] = round(((preg.max_stage - preg.stage) * preg.stage_duration) / 10, 1)
		else
			d["time_left"] = 0
	else
		d["has_preg"] = FALSE
		d["stage"] = 0
		d["max_stage"] = 0
		d["progress_pct"] = 0
		d["status"] = "dormant"
		d["time_left"] = 0

	return d

/// Short display name for egg types.
/proc/get_egg_type_short_name(egg_type)
	switch(egg_type)
		if(OVI_EGG_NORMAL)
			return "Normal"
		if(OVI_EGG_SPIDER)
			return "Spider"
		if(OVI_EGG_BOG_BUG)
			return "Bog Bug"
		if(OVI_EGG_HARPY)
			return "Harpy"
		if(OVI_EGG_EMBRYO)
			return "Embryo"
	return "[egg_type]"
