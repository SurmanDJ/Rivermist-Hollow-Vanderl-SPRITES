/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/fallen_lord
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_INTELLIGENCE = 3,
		STAT_ENDURANCE = 3,
		STAT_SPEED = 1,
		STAT_PERCEPTION = 2,
		STAT_FORTUNE = 5,
		/datum/attribute/skill/combat/axesmaces = 20,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/craft/cooking = 10
	)

/datum/job/advclass/combat/adventurer_fighter/fallen_lord
	title = "Fallen Lord"
	f_title = "Fallen Lady"
	tutorial = "Once the mighty ruler, your hold fell. Stripped of crown but not command, you now wander foreign lands in search of refuge, \
	vengeance, or a chance to reclaim what was lost."

	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE
	outfit = /datum/outfit/adventurer_fighter/fallen_lord
	total_positions = 1

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/fallen_lord


	traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
	)

/datum/outfit/adventurer_fighter/fallen_lord
	name = "Fallen Lord"
	head = /obj/item/clothing/head/helmet
	mask = null
	neck = /obj/item/clothing/neck/chaincoif
	cloak = /obj/item/clothing/cloak/heartfelt
	armor = /obj/item/clothing/armor/medium/surcoat/heartfelt
	shirt = /obj/item/clothing/shirt/undershirt
	wrists = null
	gloves = /obj/item/clothing/gloves/leather/black
	pants = /obj/item/clothing/pants/tights/colored/black
	shoes = /obj/item/clothing/shoes/nobleboot
	backr = null
	backl = null
	belt = /obj/item/storage/belt/leather/black/adventurers_subclasses
	beltr = /obj/item/storage/belt/pouch/coins/rich
	beltl = /obj/item/weapon/sword/long
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(/obj/item/scomstone = 1)
