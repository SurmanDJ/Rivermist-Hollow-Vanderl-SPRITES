
/obj/item/organ/genitals/penis/ovipositor
	name = "ovipositor"
	penis_type = PENIS_TYPE_OVIPOSITOR
	sheath_type = SHEATH_TYPE_NORMAL
	var/ovi_egg_type = OVI_EGG_NORMAL

/obj/item/organ/genitals/penis/ovipositor/Initialize()
	. = ..()
	if(!GetComponent(/datum/component/ovipositor))
		AddComponent(/datum/component/ovipositor)

/obj/item/organ/genitals/penis/ovipositor/proc/set_egg_type(new_egg_type)
	if(new_egg_type)
		ovi_egg_type = new_egg_type
	return ovi_egg_type

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
	return ovipositor

/proc/ensure_spider_ovipositor(mob/living/owner)
	return ensure_typed_ovipositor(owner, OVI_EGG_SPIDER)

/proc/ensure_bog_bug_ovipositor(mob/living/owner)
	return ensure_typed_ovipositor(owner, OVI_EGG_BOG_BUG)
