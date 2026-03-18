/obj/item/clothing/face/spectacles/fancy
	name = "fancy spectacles"
	icon = 'modular_rmh/icons/clothing/fancy_spectacles.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/onmob/fancy_spectacles.dmi'
	icon_state = "glasses"

/obj/item/clothing/face/spectacles/fancy_dark
	name = "fancy spectacles"
	icon = 'modular_rmh/icons/clothing/fancy_spectacles.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/onmob/fancy_spectacles.dmi'
	icon_state = "glasses_dark"

/datum/repeatable_crafting_recipe/sewing/fancy_spectacles
	name = "fancy spectacles"
	output = /obj/item/clothing/face/spectacles/fancy
	attacked_atom = /obj/item/clothing/face/spectacles
	requirements = list(
		/obj/item/clothing/face/spectacles = 1,
		/obj/item/natural/silk = 1,
		/obj/item/dye_pack/luxury = 1,
	)
	craftdiff = 2
	category = "Mask"

/datum/repeatable_crafting_recipe/sewing/fancy_spectacles/dark
	name = "dark fancy spectacles"
	output = /obj/item/clothing/face/spectacles/fancy_dark
	requirements = list(
		/obj/item/clothing/face/spectacles = 1,
		/obj/item/natural/silk = 1,
		/obj/item/dye_pack/cheap = 1,
	)
