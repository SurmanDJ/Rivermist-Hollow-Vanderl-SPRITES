/datum/sprite_accessory/eyes/get_appearance(obj/item/organ/eyes/eyes, obj/item/bodypart/bodypart, color_string)
	if(istype(eyes))
		glows = eyes.glows
	return ..()
