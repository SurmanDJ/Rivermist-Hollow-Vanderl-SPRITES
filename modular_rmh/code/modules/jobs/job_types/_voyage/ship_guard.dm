/datum/attribute_holder/sheet/job/advclass/watch_guard/marine
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 2,
		STAT_PERCEPTION = 1,
		STAT_SPEED = 1,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/firearms = 50,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/reading = 10
	)

/datum/job/advclass/watch_guard/marine
	title = "Ship Marine"
	tutorial = "You are a marine aboard the vessel. \
	You guard the deck, enforce discipline among the crew, and repel boarders."

	outfit = /datum/outfit/watch_guard/marine
	category_tags = list(CAT_WATCHMAN)

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/watch_guard/marine

	traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_MEDIUMARMOR,
		TRAIT_KNOWBANDITS
	)

/datum/job/advclass/watch_guard/marine/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	var/weapons = list("Cutlass", "Axe")
	var/weapon_choice = browser_input_list(spawned, "CHOOSE YOUR WEAPON.", "ARM YOURSELF", weapons)

	switch(weapon_choice)
		if("Cutlass")
			spawned.put_in_hands(new /obj/item/weapon/sword/sabre/cutlass(get_turf(spawned)), TRUE)
			spawned.put_in_hands(new /obj/item/weapon/scabbard/sword(get_turf(spawned)), TRUE)
		if("Axe")
			spawned.put_in_hands(new /obj/item/weapon/axe/steel(get_turf(spawned)), TRUE)

/datum/outfit/watch_guard/marine
	name = "Ship Marine"
	head = /obj/item/clothing/head/helmet/kettle
	mask = null
	neck = /obj/item/clothing/neck/coif/cloth
	cloak = /obj/item/clothing/cloak/half/guard
	armor = /obj/item/clothing/armor/brigandine/light
	shirt = /obj/item/clothing/armor/gambeson/colored/town_watch
	wrists = /obj/item/clothing/wrists/bracers/leather/advanced
	gloves = /obj/item/clothing/gloves/leather/advanced
	pants = /obj/item/clothing/pants/trou/leather/splint
	shoes = /obj/item/clothing/shoes/boots/leather/advanced
	backr = /obj/item/storage/backpack/satchel/black
	backl = /obj/item/weapon/shield/heater
	belt = /obj/item/storage/belt/leather/town_watch
	beltr = null
	beltl = /obj/item/weapon/mace/stunmace
	ring = /obj/item/clothing/ring/slave_control
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/clothing/neck/slave_collar,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot,
		/obj/item/flashlight/flare/torch/lantern,
	)
