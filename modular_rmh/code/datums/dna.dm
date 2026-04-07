/datum/dna
	///Emissive body markings of the DNA's owner. This is for storing their original state for re-creating the character.
	var/list/list/emissive_markings = list()

/datum/dna/transfer_identity(mob/living/carbon/destination, set_species=TRUE)
	..()
	if(!istype(destination))
		return
	destination.dna.emissive_markings = emissive_markings.Copy()

/datum/dna/copy_dna(datum/dna/new_dna)
	..()
	new_dna.emissive_markings = deepCopyList(emissive_markings)

/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, datum/preferences/pref_load = null)
	..()
	if(mrace && has_dna() && pref_load)
		dna.emissive_markings = deepCopyList(pref_load.emissive_markings)
