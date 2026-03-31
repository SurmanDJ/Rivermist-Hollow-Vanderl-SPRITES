/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/bombardier_tinkerer
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_ENDURANCE = 1,
		/datum/attribute/skill/combat/axesmaces = 20,
		/datum/attribute/skill/labor/mining = 10,
		/datum/attribute/skill/craft/engineering = 50,
		/datum/attribute/skill/craft/bombs = 40,
		/datum/attribute/skill/craft/smelting = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/reading = 20
	)

/datum/job/advclass/combat/adventurer_fighter/bombardier_tinkerer
	title = "Bombardier Tinkerer"
	tutorial = "Tinkerers that like to blow things up."

	allowed_races = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR, SPEC_ID_GNOME, SPEC_ID_GNOME_D)
	outfit = /datum/outfit/adventurer_fighter/bombardier_tinkerer
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/bombardier_tinkerer


	traits = list(
		TRAIT_MEDIUMARMOR,
	)

/datum/outfit/adventurer_fighter/bombardier_tinkerer
	name = "Bombardier Tinkerer"
	head = /obj/item/clothing/head/helmet/kettle
	mask = /obj/item/clothing/face/goggles
	neck = null
	cloak = /obj/item/clothing/cloak/half/colored/brown
	armor = /obj/item/clothing/armor/chainmail/iron
	shirt = /obj/item/clothing/armor/gambeson/light
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = null
	pants = /obj/item/clothing/pants/trou
	shoes = /obj/item/clothing/shoes/boots/leather
	backr = null
	backl = /obj/item/storage/backpack/backpack
	belt = /obj/item/storage/belt/leather/adventurers_subclasses
	beltl = /obj/item/weapon/pick
	beltr = /obj/item/weapon/hammer/iron
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(/obj/item/explosive/bottle = 3, /obj/item/flint = 1)
