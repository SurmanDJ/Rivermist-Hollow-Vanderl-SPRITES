/datum/erp_preference/bitflag/horny_mob_types
	name = "Horny Mob Types"
	description = "Choose which horny mob families may target you when Horny AI is enabled."
	category = "Mobs"
	default_value = HORNY_MOB_TYPE_ALL
	flags = list(
		"Humanoids" = HORNY_MOB_TYPE_HUMANOIDS,
		"Spiders" = HORNY_MOB_TYPE_SPIDERS,
		"Bog Bugs" = HORNY_MOB_TYPE_BOG_BUGS,
		"Trolls" = HORNY_MOB_TYPE_TROLLS,
		"Volfs and kin" = HORNY_MOB_TYPE_VOLFS,
		"Lamias" = HORNY_MOB_TYPE_LAMIAS,
		"Minotaurs" = HORNY_MOB_TYPE_MINOTAURS,
		"Lycans" = HORNY_MOB_TYPE_LYCANS,
	)
	flag_descriptions = list(
		"Humanoids" = "Humanlike horny NPCs such as orcs, goblins, bums, and other humanoid hostiles may target you.",
		"Spiders" = "Horny spiders and mire spiders may target you.",
		"Bog Bugs" = "Horny bog bugs may target you.",
		"Trolls" = "Horny trolls and bog trolls may target you.",
		"Volfs and kin" = "Horny volf-family beasts that share the volf AI may target you.",
		"Lamias" = "Horny lamias may target you.",
		"Minotaurs" = "Horny minotaurs may target you.",
		"Lycans" = "Horny lycans may target you.",
	)
