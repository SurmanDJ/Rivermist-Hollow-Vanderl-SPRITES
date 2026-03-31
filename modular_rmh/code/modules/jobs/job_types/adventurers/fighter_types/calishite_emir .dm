/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/calishite_emir
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 1,
		STAT_ENDURANCE = 2,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/music = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/labor/mathematics = 30
	)

/datum/job/advclass/combat/adventurer_fighter/calishite_emir
	title = "Calishite Trade-Emir"
	f_title = "Calishite Trade-Amirah"
	tutorial = "A Calishite emir and merchant-prince, traveling Faerûn on guild business."

	outfit = /datum/outfit/adventurer_fighter/calishite_emir
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE
	total_positions = 1
	is_recognized = TRUE
	honorary = "Emir"
	honorary_f = "Amirah"

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/calishite_emir


	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE,
		TRAIT_FOREIGNER
	)

	languages = list(/datum/language/zalad)

/datum/job/advclass/combat/adventurer_fighter/calishite_emir/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.dna?.species)
		if(spawned.dna.species.id == SPEC_ID_HUMEN)
			spawned.dna.species.native_language = "Zalad"
			spawned.dna.species.accent_language = spawned.dna.species.get_accent(spawned.dna.species.native_language)
		if(spawned.dna.species.id == SPEC_ID_HALF_ELF)
			if(spawned.dna.species.native_language == "Imperial")
				spawned.dna.species.native_language = "Zalad"
				spawned.dna.species.accent_language = spawned.dna.species.get_accent(spawned.dna.species.native_language)

/datum/outfit/adventurer_fighter/calishite_emir
	name = "Calishite Trade-Emir"
	head = /obj/item/clothing/head/crown/circlet
	mask = null
	neck = /obj/item/clothing/neck/shalal/emir
	cloak = /obj/item/clothing/cloak/raincloak/colored/purple
	armor = /obj/item/clothing/armor/gambeson/arming
	shirt = /obj/item/clothing/shirt/tunic/colored/purple
	wrists = null
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/shalal
	backr = /obj/item/storage/backpack/satchel
	backl = null
	belt = /obj/item/storage/belt/leather/shalal/adventurers_subclasses
	beltl = /obj/item/weapon/scabbard/sword/royal
	beltr = /obj/item/flashlight/flare/torch/lantern
	ring = /obj/item/clothing/ring/gold/guild_mercator
	l_hand = /obj/item/weapon/sword/sabre/shalal
	r_hand = null

	backpack_contents = list(/obj/item/storage/belt/pouch/coins/veryrich = 1)

/datum/outfit/adventurer_fighter/calishite_emir/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == FEMALE)
		shirt = /obj/item/clothing/shirt/dress/silkdress/colored/black
