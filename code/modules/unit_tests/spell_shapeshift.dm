/**
 * Validates that all shapeshift type spells
 * have a valid possible_shapes setup.
 */
/datum/unit_test/shapeshift_spell_validity

/datum/unit_test/shapeshift_spell_validity/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell/undirected/shapeshift)

	for(var/spell_type in types_to_test)
		var/datum/action/cooldown/spell/undirected/shapeshift/shift = new spell_type()
		if(!LAZYLEN(shift.possible_shapes))
			TEST_FAIL("Shapeshift spell: [shift] ([spell_type]) did not have any possible shapeshift options.")

		for(var/shift_type in shift.possible_shapes)
			if(!ispath(shift_type, /mob/living))
				TEST_FAIL("Shapeshift spell: [shift] had an invalid / non-living shift type ([shift_type]) in their possible shapes list.")

		qdel(shift)

/**
 * Tests that shapeshift spells transfer a player's mind into the temporary form
 * and return it to the original body when the form ends.
 */
/datum/unit_test/shapeshift_spell_transfers_mind

/datum/unit_test/shapeshift_spell_transfers_mind/Run()
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	caster.mind_initialize()

	var/datum/action/cooldown/spell/undirected/shapeshift/rat/rat_form = new(caster.mind)
	rat_form.Grant(caster)
	rat_form.shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bigrat

	var/datum/mind/caster_mind = caster.mind
	var/mob/living/shifted_form = rat_form.do_shapeshift(caster)
	TEST_ASSERT(istype(shifted_form, /mob/living/simple_animal/hostile/retaliate/bigrat), "Rat Form failed to create the rat body for the test.")
	TEST_ASSERT_EQUAL(caster_mind.current, shifted_form, "Shapeshift failed to transfer the caster's mind into the temporary form.")
	TEST_ASSERT_EQUAL(shifted_form.mind, caster_mind, "The shifted form did not receive the caster's mind.")
	TEST_ASSERT_EQUAL(rat_form.owner, shifted_form, "The shapeshift spell did not follow the caster into the temporary form.")

	var/mob/living/restored_body = rat_form.do_unshapeshift(shifted_form)
	TEST_ASSERT_EQUAL(restored_body, caster, "Shapeshift returned the wrong body when unshifting.")
	TEST_ASSERT_EQUAL(caster_mind.current, caster, "Unshapeshift failed to return the caster's mind to the original body.")
	TEST_ASSERT_EQUAL(caster.mind, caster_mind, "The original body did not regain the caster's mind after unshifting.")
	TEST_ASSERT_EQUAL(rat_form.owner, caster, "The shapeshift spell did not return to the original body after unshifting.")

	qdel(rat_form)
