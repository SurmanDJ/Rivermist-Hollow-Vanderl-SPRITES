/datum/attribute_holder/sheet/job/watch_warden
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_PERCEPTION = 1,
		STAT_SPEED = 1,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/craft/traps = 20
	)

/datum/job/watch_warden
	title = "Town Watch Warden"
	tutorial = "You are a Warden of the Town Watch. \
	You oversee prisoners, guard the town gates, and ensure that sentences are carried out lawfully. \
	Your duty is vigilance, containment, and control — not mercy, not glory."
	department_flag = TOWNWATCH
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_WATCH_WARDEN
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	selection_color = JCOLOR_TOWNWATCH

	outfit = /datum/outfit/watch_warden

	give_bank_account = 50

	exp_type = list(EXP_TYPE_LIVING)
	exp_types_granted = list(EXP_TYPE_GARRISON, EXP_TYPE_COMBAT)
	exp_requirements = list(
		EXP_TYPE_LIVING = 450
	)

	job_bitflag = BITFLAG_GARRISON

	attribute_sheet = /datum/attribute_holder/sheet/job/watch_warden


	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED
	)

/datum/outfit/watch_warden
	name = "Town Watch Warden"
	head = /obj/item/clothing/head/helmet/townwatch/town_warden
	mask = null
	neck = /obj/item/clothing/neck/coif
	cloak = /obj/item/clothing/cloak/half/guard
	armor = /obj/item/clothing/armor/cuirass/iron
	shirt = /obj/item/clothing/armor/gambeson/colored/town_watch
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou/leather/splint
	shoes = /obj/item/clothing/shoes/boots/armor/light
	backr = /obj/item/storage/backpack/satchel/black
	backl = null
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
		/obj/item/clothing/head/menacing,
		/obj/item/weapon/knuckles
	)

/datum/job/watch_warden/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.verbs |= /mob/proc/haltyell
