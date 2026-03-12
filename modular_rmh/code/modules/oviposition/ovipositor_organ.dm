
/obj/item/organ/genitals/penis/ovipositor
	name = "ovipositor"
	penis_type = PENIS_TYPE_OVIPOSITOR
	sheath_type = SHEATH_TYPE_NORMAL
	var/ovi_egg_type = OVI_EGG_NORMAL

/obj/item/organ/genitals/penis/ovipositor/Initialize()
	. = ..()
	if(!GetComponent(/datum/component/ovipositor))
		AddComponent(/datum/component/ovipositor)
