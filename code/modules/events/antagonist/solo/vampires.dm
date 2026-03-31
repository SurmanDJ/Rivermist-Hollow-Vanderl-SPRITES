/datum/round_event_control/antagonist/solo/vampires
	name = "Vampires"
	tags = list(
		TAG_COMBAT,
		TAG_BLOOD,
		TAG_VILLAIN,
	)
	roundstart = TRUE
	antag_flag = ROLE_VAMPIRE
	shared_occurence_type = SHARED_HIGH_THREAT

	weight = 10

	denominator = 25

	base_antags = 1
	maximum_antags = 4

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/vampire
	antag_datum = /datum/antagonist/vampire/lord

	restricted_roles = list(
		/datum/job/lord,
		/datum/job/captain
	)

/datum/round_event_control/antagonist/solo/vampires/valid_for_map()
	if(SSmapping.config.map_name != "Voyage")
		return TRUE
	return FALSE

/datum/round_event/antagonist/solo/vampire
	var/datum/antagonist/vampire/lord/lord
	var/is_spawn = TRUE

/datum/round_event/antagonist/solo/vampire/add_datum_to_mind(datum/mind/antag_mind)
	if(!lord)
		lord = antag_mind.add_antag_datum(antag_datum)
		return
	// flip flops secondary denominators to a spawn and an in-town vamp
	lord.starting_thralls += antag_mind.add_antag_datum(is_spawn ? /datum/antagonist/vampire/lords_spawn : /datum/antagonist/vampire)
	is_spawn = !is_spawn

/datum/round_event/antagonist/solo/vampire/kill()
	lord = null
	. = ..()
