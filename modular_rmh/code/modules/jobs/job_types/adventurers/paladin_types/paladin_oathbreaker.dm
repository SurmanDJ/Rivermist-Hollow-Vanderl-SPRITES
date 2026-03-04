/datum/job/advclass/combat/adventurer_paladin/oathbreaker
	title = "Oath Of Oathbreaker"
	tutorial = "An oathbreaker is a paladin who breaks their sacred oaths to pursue some dark ambition or serve an evil power.\
	Whatever light burned in the paladin's heart been extinguished. Only darkness remains."

	outfit = /datum/outfit/adventurer_paladin/oathbreaker
	category_tags = list(CAT_ADVENTURER_PALADIN)
	give_bank_account = FALSE

	skills = list(
		/datum/skill/combat/axesmaces = 2,
		/datum/skill/combat/wrestling = 3,
		/datum/skill/combat/unarmed = 3,
		/datum/skill/combat/swords = 4,
		/datum/skill/combat/shields = 3,
		/datum/skill/misc/climbing = 1,
		/datum/skill/misc/athletics = 3,
		/datum/skill/misc/reading = 3,
		/datum/skill/magic/holy = 3,
		/datum/skill/craft/cooking = 1,
		/datum/skill/labor/mathematics = 3,
	)

	jobstats = list(
		STATKEY_STR = 3,
		STATKEY_PER = 1,
		STATKEY_INT = 3,
		STATKEY_CON = 3,
		STATKEY_END = 3,
		STATKEY_SPD = 1,
		STATKEY_LCK = -3,
	)

	traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_HOLY,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/essence/purify_water,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/sacred_flame,
		/datum/action/cooldown/spell/undirected/blade_ward,
	)

/datum/job/advclass/combat/adventurer_paladin/devotion/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
//	spawned.grant_language(/datum/language/abyss)

	if(spawned.dna?.species.id == SPEC_ID_HUMEN)
		spawned.dna.species.soundpack_m = new /datum/voicepack/male/knight()

	var/holder = spawned.patron?.devotion_holder
	if(holder)
		var/datum/devotion/devotion = new holder()
		devotion.make_templar()
		devotion.grant_to(spawned)

/datum/outfit/adventurer_paladin/oathbreaker
	name = "Oath Of Oathbreaker"
	head = /obj/item/clothing/head/helmet/heavy/graggar
	mask = /obj/item/clothing/face/facemask/steel
	neck = /obj/item/clothing/neck/highcollier
	cloak = /obj/item/clothing/cloak/graggar
	armor = /obj/item/clothing/armor/plate/full/graggar
	shirt = /obj/item/clothing/armor/chainmail
	wrists = null
	gloves = /obj/item/clothing/gloves/plate/graggar
	pants = /obj/item/clothing/pants/platelegs/graggar
	shoes = /obj/item/clothing/shoes/boots/armor/graggar
	backr = /obj/item/storage/backpack/satchel
	backl = /obj/item/weapon/sword/long/greatsword/zizo
	belt = /obj/item/storage/belt/leather/steel/adventurers_subclasses
	beltl = /obj/item/storage/belt/pouch/coins/mid
	beltr = null
	ring = null
	r_hand = null
	r_hand = null

/datum/outfit/adventurer_paladin/devotion/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)

/datum/job/adventurer_paladin/New()
	. = ..()
	job_subclasses += /datum/job/advclass/combat/adventurer_paladin/oathbreaker

/datum/job/adventurer_paladin/oathbreaker/New()
	. = ..()
	allowed_patrons = subtypesof(/datum/patron/faerun/evil_gods)
	allowed_patrons += subtypesof(/datum/patron/faerun/neutral_gods)