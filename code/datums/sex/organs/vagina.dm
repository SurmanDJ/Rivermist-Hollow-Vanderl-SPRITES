/obj/item/organ/genitals/filling_organ/vagina
	name = "vagina"
	icon = 'modular_rmh/icons/eaglephntm/icons/obj/surgery.dmi'
	icon_state = "vagina"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	//var/fertility = TRUE
	var/preggotimer //dumbass timer
	var/pre_pregnancy_size = 0
	reagent_to_make = /datum/reagent/consumable/femcum
	refilling = FALSE
	reagent_generate_rate = 0.5
	max_femcum = 5
	max_reagents = 40 //big cap, ordinary absorbtion.
	altnames = list("vagina", "cunt", "womb", "pussy", "slit", "kitty", "snatch") //used in thought messages.
	absorbing = TRUE
	fertility = TRUE
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	additional_blocker = "underwear"
	bloatable = TRUE
	stretchable = FALSE

/obj/item/organ/genitals/filling_organ/vagina/Insert(mob/living/M, special, drop_if_replaced)
	. = ..()
	if(M.femcum)
		reagent_to_make = M.femcum
	add_bodystorage(M, null, /datum/component/body_storage/vagina)

/obj/item/organ/genitals/filling_organ/vagina/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/vagina/comp = GetComponent(/datum/component/body_storage/vagina)
	comp?.RemoveComponent()

/obj/item/organ/genitals/filling_organ/vagina/proc/get_womb_storage()
	return GetComponent(/datum/component/body_storage/vagina)

/obj/item/organ/genitals/filling_organ/vagina/proc/is_womb_egg(obj/item/oviposition_egg/egg)
	if(!egg)
		return FALSE
	var/datum/component/body_storage/vagina/storage = get_womb_storage()
	if(!storage)
		return FALSE
	return storage.check_item_in_layer(src, egg, STORAGE_LAYER_DEEP)

/obj/item/organ/genitals/filling_organ/vagina/proc/get_womb_oviposition_eggs(include_fertilized = null)
	var/list/eggs = list()
	var/datum/component/body_storage/vagina/storage = get_womb_storage()
	if(!storage)
		return eggs

	for(var/obj/item/oviposition_egg/egg as anything in storage.deep_layer_contents)
		var/fertilized = egg.is_fertilized()
		if(isnull(include_fertilized) || include_fertilized == fertilized)
			eggs += egg

	return eggs

/obj/item/organ/genitals/filling_organ/vagina/proc/fertilize_oviposition_egg(mob/living/father = null, baby_type = /mob/living/carbon/human)
	if(!owner)
		return null

	for(var/obj/item/oviposition_egg/egg as anything in get_womb_oviposition_eggs(FALSE))
		egg.AddComponent(/datum/component/pregnancy, owner, father, baby_type)
		return egg

	return null

/obj/item/organ/genitals/filling_organ/vagina/proc/has_oviposition_pregnancy()
	for(var/obj/item/oviposition_egg/egg as anything in get_womb_oviposition_eggs(TRUE))
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && !pregnancy.laid)
			return TRUE
	return FALSE

/obj/item/organ/genitals/filling_organ/vagina/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	if(issimple(C))
		return C.gender == FEMALE
	else
		if(pref_load)
			return pref_load.get_customizer_entry_of_type(/datum/customizer_entry/organ/genitals/vagina)
		else
			return C.gender == FEMALE

