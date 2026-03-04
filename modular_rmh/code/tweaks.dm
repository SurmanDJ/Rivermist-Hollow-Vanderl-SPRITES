/datum/quirk/vice/goodman
	name = "Good man"
	desc = "I try to live by honor and law. I help those in need, respect the authorities, and avoid needless cruelty. \
	My reputation as a good and honest man precedes me, and people often expect me to act with fairness and restraint. \
	\nYou are expected to behave as a lawful and decent person. \
	Criminal behavior, cruelty, and senseless violence go against your character. \
	Others may seek your help, rely on your judgment, or hold you to higher moral standards. \
	Play responsibly and stay true to your principles."
	point_value = 3
	incompatible_quirks = list(/datum/quirk/vice/wanted)

/obj/item
	var/integrity_scaled = FALSE


/obj/item/proc/get_integrity_multiplier()
	var/mult = 1

	switch(max_integrity)
		if(INTEGRITY_STRONGEST) // steel
			mult = 5
		if(INTEGRITY_STRONG) // iron
			mult = 4
		if(INTEGRITY_STANDARD) // leather
			mult = 3
		if(INTEGRITY_POOR) // cloth
			mult = 3

	return mult


/obj/item/proc/apply_item_scaling()

	if(integrity_scaled)
		return

	integrity_scaled = TRUE

	var/mult = get_integrity_multiplier()

	if(mult <= 1)
		return

	// durability scaling
	max_integrity *= mult
	atom_integrity = max_integrity

	// blade scaling
	if(max_blade_int > 0)
		max_blade_int *= mult
		blade_int *= mult
		dismember_blade_int *= mult



/obj/item/Initialize(mapload)

	if (attack_verb)
		attack_verb = typelist("attack_verb", attack_verb)

	if(sharpness)
		AddComponent(/datum/component/butchering, 80 * toolspeed)
	else
		max_blade_int = 0
		blade_int = 0

	// Random sharpness
	if(max_blade_int && !blade_int)
		blade_int = max_blade_int + rand(-(max_blade_int * 0.4), 0)

	// APPLY SCALING
	apply_item_scaling()

	if(!pixel_x && !pixel_y && !bigboy)
		pixel_x = rand(-5,5)
		pixel_y = rand(-5,5)

	update_transform()
	apply_components()

	return ..()