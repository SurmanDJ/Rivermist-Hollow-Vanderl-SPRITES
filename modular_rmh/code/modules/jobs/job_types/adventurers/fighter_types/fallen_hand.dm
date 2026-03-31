/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/fallen_hand
	raw_attribute_list = list(
		STAT_STRENGTH = 3,
		STAT_PERCEPTION = 2,
		STAT_INTELLIGENCE = 3,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/mathematics = 30
	)

/datum/job/advclass/combat/adventurer_fighter/fallen_hand
	title = "Fallen Hand"
	tutorial = "As the Lord’s Hand, you governed coin, contracts, and quiet threats alike. \
	With your hold in ruins, you now serve in exile — guarding secrets, managing survival, and deciding how far loyalty truly goes."

	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE
	outfit = /datum/outfit/adventurer_fighter/fallen_hand
	total_positions = 1

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/fallen_hand


	traits = list(
		TRAIT_SEEPRICES,
		TRAIT_HEAVYARMOR,
	)

/datum/outfit/adventurer_fighter/fallen_hand
	name = "Fallen Hnad"
	head = null
	mask = /obj/item/clothing/face/spectacles/golden
	neck = /obj/item/clothing/neck/chaincoif
	cloak = null
	armor = /obj/item/clothing/armor/medium/surcoat/heartfelt
	shirt = /obj/item/clothing/shirt/undershirt
	wrists = null
	gloves = /obj/item/clothing/gloves/leather/black
	pants = /obj/item/clothing/pants/tights/colored/black
	shoes = /obj/item/clothing/shoes/nobleboot
	backr = /obj/item/storage/backpack/satchel/heartfelt
	backl = null
	belt = /obj/item/storage/belt/leather/black/adventurers_subclasses
	beltl = /obj/item/weapon/sword/decorated
	beltr = /obj/item/storage/belt/pouch/coins/rich
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(/obj/item/scomstone = 1)
