#define OVI_EGG_NORMAL "normal_ovi"
#define OVI_EGG_SPIDER "spider_ovi"

/obj/item/oviposition_egg
	parent_type = /obj/item/reagent_containers/food/snacks/oviposition_egg
	name = "oviposition egg"
	desc = "A soft, warm egg that feels alive even before it starts to twitch."
	w_class = WEIGHT_CLASS_SMALL
	body_storage_bulk = 1
	var/egg_type = OVI_EGG_NORMAL

/obj/item/oviposition_egg/Initialize(mapload)
	. = ..()
	update_egg_appearance()

/obj/item/oviposition_egg/proc/set_egg_type(new_egg_type)
	if(new_egg_type)
		egg_type = new_egg_type
	update_egg_appearance()
	return egg_type

/obj/item/oviposition_egg/proc/update_egg_appearance()
	color = null
	switch(egg_type)
		if(OVI_EGG_SPIDER)
			name = "spider egg"
			desc = "A soft, web-slick egg with a faint, unsettling pulse."
			icon_state = "egg_color"
			color = "#6d7685"
		else
			name = initial(name)
			desc = initial(desc)
			icon_state = initial(icon_state)

/obj/item/oviposition_egg/proc/get_pregnancy_component()
	return GetComponent(/datum/component/pregnancy)

/obj/item/oviposition_egg/proc/is_fertilized()
	return !isnull(get_pregnancy_component())
