/datum/attribute_holder/sheet/job/advclass/towner/lumberjack
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/labor/lumberjacking = 40,
		/datum/attribute/skill/craft/carpentry = 20
	)

/datum/job/advclass/towner/lumberjack
	title = "Lumberjack"
	tutorial = "You're a lumberjack, ensure the settlement has wood."
	total_positions = 5
	spawn_positions = 5

	outfit = /datum/outfit/towner/lumberjack
	category_tags = list(CAT_TOWNER)
	give_bank_account = 6

	job_bitflag = BITFLAG_CONSTRUCTOR

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/towner/lumberjack


/datum/outfit/towner/lumberjack
	name = "Lumberjack"
	head = /obj/item/clothing/head/hatfur
	mask = null
	neck = null
	cloak = null
	armor = /obj/item/clothing/armor/leather/vest
	shirt = /obj/item/clothing/shirt/undershirt/colored/random
	wrists = null
	gloves = null
	pants = /obj/item/clothing/pants/tights/colored/random
	shoes = /obj/item/clothing/shoes/boots/leather
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/weapon/axe/iron
	beltr = null
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/weapon/knife/villager = 1
	)
