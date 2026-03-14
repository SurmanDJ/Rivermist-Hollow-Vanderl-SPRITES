/datum/blueprint_recipe/carpentry/torture_table
	name = "torture table"
	desc = "A cruel table meant for restraining captives."
	result_type = /obj/structure/bondage/torture_table
	required_materials = list(
		/obj/item/natural/wood/plank = 3,
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 1
	)
	supports_directions = TRUE
	craftdiff = 2
	build_time = 4 SECONDS

/datum/blueprint_recipe/carpentry/torture_table_lever
	name = "torture table (lever)"
	desc = "A torture table fitted with a mechanical lever."
	result_type = /obj/structure/bondage/torture_table/lever
	required_materials = list(
		/obj/item/natural/wood/plank = 3,
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 2
	)
	supports_directions = TRUE
	craftdiff = 3
	build_time = 5 SECONDS

/datum/blueprint_recipe/carpentry/x_pillory
	name = "x-pillory"
	desc = "A brutal restraint frame shaped like a cross."
	result_type = /obj/structure/bondage/x_pillory
	required_materials = list(
		/obj/item/grown/log/tree/small = 2,
		/obj/item/grown/log/tree/stick = 2,
		/obj/item/ingot/iron = 1
	)
	supports_directions = TRUE
	craftdiff = 2

/datum/blueprint_recipe/carpentry/gloryhole
	name = "partition wall"
	desc = "A wooden partition wall."
	result_type = /obj/structure/bondage/gloryhole
	required_materials = list(
		/obj/item/natural/wood/plank = 2,
		/obj/item/grown/log/tree/stick = 1
	)
	supports_directions = TRUE
	craftdiff = 1

/datum/blueprint_recipe/carpentry/wooden_horse
	name = "wooden horse"
	desc = "A painful triangular restraint device."
	result_type = /obj/structure/wooden_horse
	required_materials = list(
		/obj/item/natural/wood/plank = 3,
		/obj/item/grown/log/tree/stick = 2
	)
	supports_directions = TRUE
	craftdiff = 2
	build_time = 4 SECONDS

/datum/blueprint_recipe/carpentry/wooden_horse_mobile
	name = "mobile wooden horse"
	desc = "A wooden horse that can be dragged around."
	result_type = /obj/structure/wooden_horse/mobile
	required_materials = list(
		/obj/item/natural/wood/plank = 3,
		/obj/item/grown/log/tree/small = 1,
		/obj/item/rope = 1
	)
	supports_directions = TRUE
	craftdiff = 2

/datum/blueprint_recipe/carpentry/wooden_horse_small
	name = "small wooden horse"
	desc = "A smaller version of the wooden horse."
	result_type = /obj/structure/wooden_horse/small
	required_materials = list(
		/obj/item/natural/wood/plank = 2,
		/obj/item/grown/log/tree/stick = 1
	)
	supports_directions = TRUE
	craftdiff = 1

/datum/blueprint_recipe/carpentry/wooden_horse_metal
	name = "reinforced wooden horse"
	desc = "A wooden horse reinforced with iron."
	result_type = /obj/structure/wooden_horse/metal
	required_materials = list(
		/obj/item/natural/wood/plank = 3,
		/obj/item/ingot/iron = 2
	)
	supports_directions = TRUE
	craftdiff = 3
	build_time = 5 SECONDS
