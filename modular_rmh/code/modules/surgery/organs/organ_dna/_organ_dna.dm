
/datum/organ_dna/eyes
	var/eye_glowing = FALSE

/datum/organ_dna/eyes/imprint_organ(obj/item/organ/eyes/eyes, datum/species/species)
	..()
	if(istype(eyes))
		eyes.glows = eye_glowing
