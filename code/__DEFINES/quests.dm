#define QUEST_GROUP_ERRANDS "Guild Errands"
#define QUEST_GROUP_BOUNTIES "Bounties"

#define QUEST_TIER_ROUTINE 1
#define QUEST_TIER_RISKY 2
#define QUEST_TIER_DANGEROUS 3
#define QUEST_TIER_DEADLY 4
#define QUEST_TIER_LETHAL 5
#define QUEST_TIER_MYTHIC 6

#define QUEST_RETRIEVAL "Retrieval"
#define QUEST_COURIER "Courier"
#define QUEST_HUNT "Hunt"
#define QUEST_CLEAR_OUT "Clear Out"
#define QUEST_RAID "Raid"
#define QUEST_BOSS "Boss"

#define QUEST_HANDLER_REWARD_MULTIPLIER 2
#define QUEST_REWARD_PER_RISK_POINT 6
#define QUEST_DEPOSIT_RATE 0.18
#define QUEST_MIN_DEPOSIT 4
#define QUEST_MAX_DEPOSIT 80

#define QUEST_BASE_REWARD_RETRIEVAL 18
#define QUEST_BASE_REWARD_COURIER 16
#define QUEST_BASE_REWARD_HUNT 8
#define QUEST_BASE_REWARD_CLEAR_OUT 18
#define QUEST_BASE_REWARD_RAID 28
#define QUEST_BASE_REWARD_BOSS 40

#define QUEST_KILL_COUNT_REWARD 4
#define QUEST_CLEAR_OUT_RISK_BONUS 1
#define QUEST_RAID_RISK_BONUS 3
#define QUEST_BOSS_RISK_BONUS 5

#define QUEST_MOB_SPAWN_WEIGHT "spawn_weight"
#define QUEST_MOB_RISK_VALUE "risk_value"
#define QUEST_MOB_GROUP_MIN "group_min"
#define QUEST_MOB_GROUP_MAX "group_max"
#define QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX) list(QUEST_MOB_SPAWN_WEIGHT = SPAWN_WEIGHT, QUEST_MOB_RISK_VALUE = RISK_VALUE, QUEST_MOB_GROUP_MIN = GROUP_MIN, QUEST_MOB_GROUP_MAX = GROUP_MAX)
#define QUEST_MOB_SOLO(SPAWN_WEIGHT, RISK_VALUE) QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, 1, 1)
#define QUEST_MOB_PACK(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX) QUEST_MOB_DATA(SPAWN_WEIGHT, RISK_VALUE, GROUP_MIN, GROUP_MAX)

// Delivery quest additional reward scaling
#define QUEST_DELIVERY_DISTANCE_DIVISOR 6 // Divides the distance for reward calculation
#define QUEST_DELIVERY_DISTANCE_BONUS 1 // Adds a bonus for longer distances
#define QUEST_COURIER_BONUS_FLAT 8 // Flat bonus for courier quests, since you gotta wait for a person to open a package
#define QUEST_DELIVERY_PER_ITEM_BONUS 5 // Bonus per item delivered


// ==>>> NEW LIST

#define QUEST_KILL_MOBS_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/smallrat = QUEST_MOB_PACK(10, 1, 2, 5),\
	/mob/living/simple_animal/hostile/retaliate/frog = QUEST_MOB_SOLO(7, 1),\
	/mob/living/simple_animal/hostile/retaliate/bat = QUEST_MOB_PACK(8, 2, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/bigrat = QUEST_MOB_PACK(8, 2, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/fox = QUEST_MOB_SOLO(6, 2),\
	/mob/living/simple_animal/hostile/retaliate/raccoon = QUEST_MOB_PACK(5, 3, 1, 2),\
	/mob/living/simple_animal/hostile/retaliate/snapper = QUEST_MOB_SOLO(6, 3),\
	/mob/living/simple_animal/hostile/retaliate/shade = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/retaliate/poltergeist = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/dragger = QUEST_MOB_SOLO(4, 4),\
	/mob/living/simple_animal/hostile/retaliate/wolf = QUEST_MOB_PACK(6, 4, 2, 4),\
	/mob/living/simple_animal/hostile/retaliate/bobcat = QUEST_MOB_SOLO(5, 4),\
	/mob/living/simple_animal/hostile/retaliate/spider = QUEST_MOB_PACK(6, 4, 2, 5),\
	/mob/living/simple_animal/hostile/skeleton = QUEST_MOB_PACK(5, 5, 2, 4),\
	/mob/living/simple_animal/hostile/skeleton/spear = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/simple_animal/hostile/skeleton/bow = QUEST_MOB_PACK(3, 5, 2, 3),\
	/mob/living/simple_animal/hostile/skeleton/axe = QUEST_MOB_PACK(3, 6, 1, 2),\
	/mob/living/carbon/human/species/goblin/npc = QUEST_MOB_PACK(5, 5, 2, 4),\
	/mob/living/carbon/human/species/goblin/npc/cave = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/goblin/npc/sea = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/kobold/base/unskilled/naked = QUEST_MOB_PACK(4, 4, 2, 5),\
	/mob/living/carbon/human/species/kobold/base/unskilled/light_gear = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/zizombie/npc/peasant = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/human/northern/thief = QUEST_MOB_PACK(4, 5, 1, 2),\
	/mob/living/carbon/human/species/human/northern/highwayman = QUEST_MOB_PACK(3, 6, 1, 2),\
)
#define QUEST_KILL_MEDIUM_LIST list(\
	/mob/living/carbon/human/species/goblin/npc/cave = QUEST_MOB_PACK(6, 5, 3, 6),\
	/mob/living/carbon/human/species/goblin/npc/sea = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/kobold/base/unskilled/light_gear = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/kobold/base/skilled/light_gear = QUEST_MOB_PACK(4, 6, 3, 5),\
	/mob/living/carbon/human/species/kobold/base/unskilled/medium_gear = QUEST_MOB_PACK(3, 6, 3, 5),\
	/mob/living/carbon/human/species/zizombie/npc/peasant = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/zizombie/npc/warrior = QUEST_MOB_PACK(3, 7, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/easy = QUEST_MOB_PACK(5, 5, 3, 6),\
	/mob/living/carbon/human/species/skeleton/npc/pirate = QUEST_MOB_PACK(4, 5, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/medium = QUEST_MOB_PACK(3, 7, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc2 = QUEST_MOB_PACK(5, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/spear = QUEST_MOB_PACK(5, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/spear2 = QUEST_MOB_PACK(4, 6, 3, 5),\
	/mob/living/simple_animal/hostile/orc/ranged = QUEST_MOB_PACK(4, 6, 3, 4),\
	/mob/living/simple_animal/hostile/orc/orc_marauder = QUEST_MOB_PACK(3, 8, 3, 4),\
	/mob/living/simple_animal/hostile/orc/orc_marauder/spear = QUEST_MOB_PACK(3, 8, 3, 4),\
	/mob/living/simple_animal/hostile/deepone = QUEST_MOB_PACK(4, 6, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/arm = QUEST_MOB_PACK(3, 7, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/spit = QUEST_MOB_PACK(3, 7, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/wiz = QUEST_MOB_PACK(2, 8, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/gator = QUEST_MOB_PACK(3, 7, 2, 3),\
	/mob/living/simple_animal/hostile/retaliate/bogbug = QUEST_MOB_PACK(5, 6, 3, 6),\
	/mob/living/simple_animal/hostile/retaliate/spider/mutated = QUEST_MOB_PACK(4, 6, 3, 6),\
	/mob/living/carbon/human/species/human/northern/thief = QUEST_MOB_PACK(4, 5, 2, 4),\
	/mob/living/carbon/human/species/human/northern/highwayman = QUEST_MOB_PACK(3, 6, 2, 4),\
)
#define QUEST_RAID_LIST list(\
	/mob/living/carbon/human/species/skeleton/npc/medium = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/carbon/human/species/skeleton/npc/hard = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/zizombie/npc/warrior = QUEST_MOB_PACK(4, 8, 3, 5),\
	/mob/living/carbon/human/species/zizombie/npc/militiamen = QUEST_MOB_PACK(3, 8, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc_marauder = QUEST_MOB_PACK(4, 8, 3, 5),\
	/mob/living/simple_animal/hostile/orc/orc_marauder/spear = QUEST_MOB_PACK(3, 8, 3, 5),\
	/mob/living/carbon/human/species/orc/warrior = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/orc/marauder = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/arm = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/spit = QUEST_MOB_PACK(4, 7, 3, 5),\
	/mob/living/simple_animal/hostile/deepone/wiz = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/simple_animal/hostile/deepone/elite = QUEST_MOB_PACK(2, 9, 2, 3),\
	/mob/living/carbon/human/species/human/northern/base/very_skilled/medium_gear = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/carbon/human/species/human/northern/base/skilled/heavy_gear = QUEST_MOB_PACK(3, 8, 2, 4),\
	/mob/living/carbon/human/species/human/northern/base/very_skilled/heavy_gear = QUEST_MOB_PACK(2, 9, 2, 3),\
	/mob/living/carbon/human/species/human/northern/searaider = QUEST_MOB_PACK(3, 9, 2, 4),\
	/mob/living/carbon/human/species/human/northern/bog_deserters = QUEST_MOB_PACK(3, 9, 2, 4),\
)
#define QUEST_BOSS_KILL_LIST list(\
	/mob/living/simple_animal/hostile/retaliate/voiddragon = QUEST_MOB_SOLO(3, 13),\
	/mob/living/simple_animal/hostile/retaliate/voiddragon/red = QUEST_MOB_SOLO(2, 13),\
	/mob/living/simple_animal/hostile/boss/fishboss = QUEST_MOB_SOLO(2, 14),\
	/mob/living/simple_animal/hostile/retaliate/voiddragon/red/tsere = QUEST_MOB_SOLO(1, 16),\
)
