// TO DO:
/* *
 * Champion of Baal
 * A miniboss for quest system, designed to be a high-level challenge for multiple players.
 * Uses fuckoff gear that should not be looted - hence snowflake dismemberment code.
 */

GLOBAL_LIST_INIT(aggro, world.file2list("strings/rt/species_hostile.txt"))

/mob/living/carbon/human/species/human/northern/base/very_skilled/heavy_gear/baal_champion
	base_strength = 30
	base_speed = 30
	base_perception = 30
	base_constitution = 30
	base_endurance = 30
	base_fortune = 30

/datum/outfit/npc/baal_champion/pre_equip(mob/living/carbon/human/H)
	..()
	armor = /obj/item/clothing/armor/plate/full/graggar
	pants = /obj/item/clothing/pants/platelegs/graggar
	shoes = /obj/item/clothing/shoes/boots/armor/graggar
	gloves = /obj/item/clothing/gloves/plate/graggar
	head = /obj/item/clothing/head/helmet/heavy/graggar
	neck = /obj/item/clothing/neck/highcollier
	mask = /obj/item/clothing/face/facemask/steel
	belt = /obj/item/storage/belt/leather/mercenary/black
	wrists = /obj/item/clothing/wrists/bracers/psythorns
	cloak = /obj/item/clothing/cloak/graggar
	r_hand = /obj/item/weapon/sword/long/greatsword/zizo
	l_hand = null

/mob/living/carbon/human/proc/empower_equipment(integrity_bonus = 200, weapon_bonus = 0)

    for(var/obj/item/I in src.get_equipped_items())
        if(!I)
            continue

        if(I.uses_integrity)
            I.max_integrity += integrity_bonus
            I.atom_integrity = I.max_integrity

        if(weapon_bonus && hasvar(I, "force"))
            I.force += weapon_bonus

/mob/living/carbon/human/species/human/northern/base/very_skilled/heavy_gear/baal_champion/after_creation()
	..()

	ADD_TRAIT(src, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOSTAMINA, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_ANTIMAGIC, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHARDCRIT, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOSOFTCRIT, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_BOMBIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_RESISTHEAT, TRAIT_GENERIC)

	adjust_skillrank(/datum/skill/combat/unarmed,6, TRUE)
	adjust_skillrank(/datum/skill/misc/athletics, 6, TRUE)
	adjust_skillrank(/datum/skill/combat/wrestling, 6, TRUE)
	adjust_skillrank(/datum/skill/combat/swords, 6, TRUE)
	adjust_skillrank(/datum/skill/combat/axesmaces, 6, TRUE)

	ai_controller?.blackboard[BB_ARMOR_CLASS] = 3

	equipOutfit(new /datum/outfit/npc/baal_champion)
	addtimer(CALLBACK(src, PROC_REF(empower_equipment), 1000, 50), 1)