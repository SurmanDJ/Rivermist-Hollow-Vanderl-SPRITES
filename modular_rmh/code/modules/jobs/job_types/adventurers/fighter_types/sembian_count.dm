/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/sembian_count
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 1,
		STAT_ENDURANCE = 2,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/music = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/labor/mathematics = 30
	)

/datum/job/advclass/combat/adventurer_fighter/sembian_count
	title = "Sembian Count"
	tutorial = "A Sembian count of the eastern Heartlands, visiting on formal state business."

	outfit = /datum/outfit/adventurer_fighter/sembian_count
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE
	total_positions = 1
	is_recognized = TRUE
	honorary = "Count"
	honorary_f = "Countess"

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/sembian_count


	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE,
		TRAIT_FOREIGNER
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/call_bird/grenzel
	)

/datum/job/advclass/combat/adventurer_fighter/sembian_count/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.dna?.species.id == SPEC_ID_HUMEN)
		spawned.dna.species.native_language = "Old Psydonic"
		spawned.dna.species.accent_language = spawned.dna.species.get_accent(spawned.dna.species.native_language)

/datum/outfit/adventurer_fighter/sembian_count
	name = "Sembian Count"
	head = /obj/item/clothing/head/helmet/skullcap/grenzelhoft
	mask = null
	neck = /obj/item/clothing/neck/gorget
	cloak = /obj/item/clothing/cloak/half/colored/random
	armor = /obj/item/clothing/armor/brigandine
	shirt = /obj/item/clothing/shirt/grenzelhoft
	wrists = null
	gloves = /obj/item/clothing/gloves/angle/grenzel
	pants = /obj/item/clothing/pants/grenzelpants
	shoes = /obj/item/clothing/shoes/rare/grenzelhoft
	backr = null
	backl = null
	belt = /obj/item/storage/belt/leather/plaquesilver/adventurers_subclasses
	beltl = /obj/item/weapon/sword/sabre/dec
	beltr = /obj/item/flashlight/flare/torch/lantern
	ring = /obj/item/clothing/ring/gold
	l_hand = null
	r_hand = null

	backpack_contents = list(/obj/item/storage/belt/pouch/coins/veryrich = 1)

/datum/outfit/adventurer_fighter/sembian_count/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == FEMALE)
		armor = /obj/item/clothing/armor/gambeson/heavy/dress/alt
		beltl = /obj/item/weapon/sword/rapier/dec
