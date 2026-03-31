/proc/legacy_attribute_skill_path(skill_type)
	if(isnull(skill_type))
		return null
	if(ispath(skill_type, /datum/attribute/skill))
		return skill_type

	switch(skill_type)
		if(/datum/skill/combat/axes, /datum/skill/combat/maces)
			return /datum/attribute/skill/combat/axesmaces

	var/text_path = "[skill_type]"
	if(!findtext(text_path, "/datum/skill/"))
		return null

	var/translated_path = text2path(replacetext(text_path, "/datum/skill/", "/datum/attribute/skill/"))
	if(ispath(translated_path, /datum/attribute/skill))
		return translated_path
	return null

/proc/normalize_attribute_stat_list(list/stat_list)
	if(!LAZYLEN(stat_list))
		return null

	var/list/normalized = list()
	for(var/stat_key in stat_list)
		var/stat_path = legacy_attribute_stat_path(stat_key)
		if(!stat_path)
			continue

		var/amount = stat_list[stat_key]
		if(!isnum(amount))
			continue

		normalized[stat_path] = amount
	return normalized

/proc/legacy_attribute_stat_path(stat_key)
	switch(stat_key)
		if(STATKEY_STR)
			return STAT_STRENGTH
		if(STATKEY_PER)
			return STAT_PERCEPTION
		if(STATKEY_INT)
			return STAT_INTELLIGENCE
		if(STATKEY_CON)
			return STAT_CONSTITUTION
		if(STATKEY_END)
			return STAT_ENDURANCE
		if(STATKEY_SPD)
			return STAT_SPEED
		if(STATKEY_LCK)
			return STAT_FORTUNE
	if(ispath(stat_key, STAT))
		return stat_key
	return null

/proc/build_legacy_attribute_sheet(list/legacy_stats = null, list/legacy_skills = null)
	if(!LAZYLEN(legacy_stats) && !LAZYLEN(legacy_skills))
		return null

	var/datum/attribute_holder/sheet/job/generated_sheet = new
	generated_sheet.raw_attribute_list = list()

	if(LAZYLEN(legacy_stats))
		for(var/stat_key in legacy_stats)
			var/stat_path = legacy_attribute_stat_path(stat_key)
			if(!stat_path)
				continue
			generated_sheet.raw_attribute_list[stat_path] = legacy_stats[stat_key]

	if(LAZYLEN(legacy_skills))
		for(var/skill_key in legacy_skills)
			var/skill_path = legacy_attribute_skill_path(skill_key)
			if(!skill_path)
				continue

			var/amount = legacy_skills[skill_key]
			if(islist(amount))
				amount = amount[1]
			if(!isnum(amount))
				continue

			var/translated_amount = amount * 10
			if(skill_path in generated_sheet.raw_attribute_list)
				generated_sheet.raw_attribute_list[skill_path] = max(generated_sheet.raw_attribute_list[skill_path], translated_amount)
			else
				generated_sheet.raw_attribute_list[skill_path] = translated_amount

	generated_sheet.update_attributes()
	return generated_sheet

/proc/resolve_attribute_sheet(sheet_type)
	if(ispath(sheet_type, /datum/attribute_holder/sheet))
		if(GLOB.attribute_sheets[sheet_type])
			return GLOB.attribute_sheets[sheet_type]
		return GLOB.attribute_sheets[sheet_type] = new sheet_type()
	if(istype(sheet_type, /datum/attribute_holder/sheet))
		return sheet_type
	return null

/proc/legacy_attribute_stat_key(stat_key)
	switch(stat_key)
		if(STAT_STRENGTH)
			return STATKEY_STR
		if(STAT_PERCEPTION)
			return STATKEY_PER
		if(STAT_INTELLIGENCE)
			return STATKEY_INT
		if(STAT_CONSTITUTION)
			return STATKEY_CON
		if(STAT_ENDURANCE)
			return STATKEY_END
		if(STAT_SPEED)
			return STATKEY_SPD
		if(STAT_FORTUNE)
			return STATKEY_LCK
	if(istext(stat_key))
		return stat_key
	return null

/proc/legacy_attribute_skill_legacy_path(skill_type)
	if(isnull(skill_type))
		return null
	if(ispath(skill_type, /datum/skill))
		return skill_type

	switch(skill_type)
		if(/datum/attribute/skill/combat/axesmaces)
			return /datum/skill/combat/axesmaces

	var/text_path = "[skill_type]"
	if(!findtext(text_path, "/datum/attribute/skill/"))
		return null

	var/translated_path = text2path(replacetext(text_path, "/datum/attribute/skill/", "/datum/skill/"))
	if(ispath(translated_path, /datum/skill))
		return translated_path
	return null

/proc/build_legacy_jobstats_from_sheet(sheet_type)
	var/datum/attribute_holder/sheet/resolved_sheet = resolve_attribute_sheet(sheet_type)
	if(!resolved_sheet)
		return null

	var/list/legacy_stats = list()
	for(var/attribute_path in resolved_sheet.raw_attribute_list)
		if(!ispath(attribute_path, STAT))
			continue

		var/legacy_stat_key = legacy_attribute_stat_key(attribute_path)
		if(!legacy_stat_key)
			continue

		var/amount = resolved_sheet.raw_attribute_list[attribute_path]
		if(!isnum(amount))
			continue

		legacy_stats[legacy_stat_key] = amount

	return LAZYLEN(legacy_stats) ? legacy_stats : null

/proc/build_legacy_skills_from_sheet(sheet_type)
	var/datum/attribute_holder/sheet/resolved_sheet = resolve_attribute_sheet(sheet_type)
	if(!resolved_sheet)
		return null

	var/list/legacy_skills = list()
	for(var/attribute_path in resolved_sheet.raw_attribute_list)
		if(!ispath(attribute_path, SKILL))
			continue

		var/legacy_skill_path = legacy_attribute_skill_legacy_path(attribute_path)
		if(!legacy_skill_path)
			continue

		var/amount = resolved_sheet.raw_attribute_list[attribute_path]
		if(!isnum(amount))
			continue

		legacy_skills[legacy_skill_path] = round(amount / 10)

	return LAZYLEN(legacy_skills) ? legacy_skills : null
