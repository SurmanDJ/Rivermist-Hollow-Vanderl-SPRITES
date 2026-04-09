/datum/clothing_display_helper

/datum/clothing_display_helper/proc/get_species_name(spec_id)
	switch(spec_id)
		if(SPEC_ID_HUMEN) return "human"
		if(SPEC_ID_DWARF) return "dwarf"
		if(SPEC_ID_DUERGAR) return "duergar"
		if(SPEC_ID_AASIMAR) return "aasimar"
		if(SPEC_ID_ELF) return "elf"
		if(SPEC_ID_ELF_W) return "wood elf"
		if(SPEC_ID_HALF_ELF) return "half-elf"
		if(SPEC_ID_DROW) return "drow"
		if(SPEC_ID_HALF_DROW) return "half-drow"
		if(SPEC_ID_TIEFLING) return "tiefling"
		if(SPEC_ID_HALF_ORC) return "half-orc"
		if(SPEC_ID_ORC) return "orc"
		if(SPEC_ID_GOBLIN) return "goblin"
		if(SPEC_ID_KOBOLD) return "kobold"
		if(SPEC_ID_DRAGONBORN) return "dragonborn"
		if(SPEC_ID_LIZARDFOLK) return "lizardfolk"
		if(SPEC_ID_TABAXI) return "tabaxi"
		if(SPEC_ID_GNOLL) return "gnoll"
		if(SPEC_ID_OGRE) return "ogre"
		if(SPEC_ID_SEELIE) return "seelie"
		else
			return "[spec_id]"


/datum/clothing_display_helper/proc/pluralize(name)
	if(!name)
		return ""

	if(name == "elf") return "elves"
	if(name == "half-elf") return "half-elves"
	if(name == "lizardfolk") return "lizardfolk"
	if(name == "tabaxi") return "tabaxi"
	if(name == "seelie") return "seelie"
	if(name == "half-drow") return "half-drow"

	if(copytext(name, -1) == "f")
		return "[copytext(name, 1, -1)]ves"

	return "[name]s"


/datum/clothing_display_helper/proc/format_sex(list/allowed_sex)
	if(!length(allowed_sex))
		return ""

	if(allowed_sex.len >= 2)
		return "men and women"

	if(MALE in allowed_sex)
		return "men"

	if(FEMALE in allowed_sex)
		return "women"

	return ""


/datum/clothing_display_helper/proc/format_race(list/allowed_race)
	if(!length(allowed_race))
		return ""

	var/list/names = list()

	for(var/r in allowed_race)
		names += src.get_species_name(r)

	if(names.len == 1)
		return src.pluralize(names[1])

	if(names.len <= 3)
		var/list/plural = list()
		for(var/n in names)
			plural += src.pluralize(n)
		return plural.Join(", ")

	if(names.len >= length(ALL_RACES_LIST))
		return "all races"

	return "many races"


/datum/clothing_display_helper/proc/build_display_text(list/allowed_sex, list/allowed_race)
	var/sex_text = src.format_sex(allowed_sex)
	var/race_text = src.format_race(allowed_race)

	if(sex_text && race_text)
		return "Can be worn by [sex_text] of [race_text]."

	if(race_text)
		return "Can be worn by [race_text]."

	if(sex_text)
		return "Can be worn by [sex_text]."

	return ""

GLOBAL_VAR_INIT(clothing_display_helper, new /datum/clothing_display_helper)

/obj/item/clothing/examine(mob/user)
	. = ..()

	var/datum/clothing_display_helper/H = GLOB.clothing_display_helper
	if(H)
		var/text = H.build_display_text(src.allowed_sex, src.allowed_race)
		if(text)
			. += span_notice(text)

