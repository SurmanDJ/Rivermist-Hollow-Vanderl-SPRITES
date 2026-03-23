/datum/unit_test/pocket_dimensions/Run()
	var/obj/item/pocket_dimension_tester/tester_scroll = allocate(/obj/item/pocket_dimension_tester, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/origin = get_turf(tester)

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance(REF(tester_scroll), tester_scroll.template_ref, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(instance, "Pocket dimension instance should be created.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should accept a mob entry.")
	TEST_ASSERT(instance.contains_turf(get_turf(tester)), "Tester should wind up inside the pocket dimension.")

	var/obj/item/storage/backpack/foreign_bag = allocate(/obj/item/storage/backpack, get_turf(tester))
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign items spawned into the pocket should count as in-pocket objects.")

	TEST_ASSERT(instance.exit_mob(tester), "Pocket dimension should be able to return a mob.")
	TEST_ASSERT_EQUAL(get_turf(tester), origin, "Tester should return to the entry turf.")
	instance.last_touched = 0
	TEST_ASSERT(instance.process_idle_lifecycle(), "Pocket dimension should hibernate when left idle.")
	TEST_ASSERT(instance.is_hibernating(), "Pocket dimension should enter a hibernating state after idling out.")
	TEST_ASSERT_NULL(instance.reservation, "Hibernating pocket dimensions should release their reservation.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should wake back up when entered.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign movables should be restored when a hibernating pocket wakes.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(REF(tester_scroll)), "Pocket dimension should be deletable.")
	TEST_ASSERT_NULL(SSpocket_dimensions.get_instance(REF(tester_scroll)), "Pocket dimension should unregister after deletion.")
	TEST_ASSERT_EQUAL(get_turf(foreign_bag), origin, "Foreign items should be ejected before the pocket collapses.")
