/// Spritesheet for quest contract preview icons.
/// Generates preview icons for all mob types used in kill/hunt quests,
/// bundling them into a single PNG sent once per client instead of
/// base64-encoding each icon inside every ui_data() response.
///
/// Pre-generated synchronously in contractledger's LateInitialize().
/// Falls back to lazy generation on first send() if no ledger exists yet.
/datum/asset/spritesheet/quest_previews
	name = "quest_previews"
	cross_round_cachable = FALSE
	var/sprites_generated = FALSE
	var/generation_in_progress = FALSE

/datum/asset/spritesheet/quest_previews/create_spritesheets()
	// No-op during SSassets init — atoms don't exist yet.
	// Actual generation happens lazily in generate_quest_sprites().
	return

/datum/asset/spritesheet/quest_previews/send(client/client)
	if(!sprites_generated)
		// Reset stale lock from a previous failed attempt so we can retry.
		generation_in_progress = FALSE
		generate_quest_sprites()
	if(!sprites_generated)
		// Generation failed or no sprites — skip parent send() to avoid
		// realize_spritesheets() on empty/corrupt state (Division by zero).
		return
	return ..()

/datum/asset/spritesheet/quest_previews/ensure_ready()
	if(!sprites_generated)
		generation_in_progress = FALSE
		generate_quest_sprites()
	if(!sprites_generated)
		// Generation failed — don't let parent call realize_spritesheets()
		// on empty data, which causes Division by zero in generate_css().
		return
	return ..()

/// Populates the spritesheet with preview icons for all quest mob types.
/// Called lazily on first send() — by this point atoms are fully initialized.
/datum/asset/spritesheet/quest_previews/proc/generate_quest_sprites()
	if(sprites_generated || generation_in_progress)
		return
	generation_in_progress = TRUE

	var/obj/structure/fake_machine/contractledger/ledger_ref = locate() in world
	if(!ledger_ref)
		generation_in_progress = FALSE
		return

	var/list/seen_sources = list()
	var/list/seen_types = list()
	var/inserted_count = 0

	// Iterate ALL contract types directly from the global registry,
	// bypassing user-based permission filters (is_boss_raid_issuer etc.)
	// so that boss/raid mob sprites are always included.
	for(var/contract_group in GLOB.global_quest_contract_groups)
		var/list/group_contract_types = GLOB.global_quest_contract_groups[contract_group] || list()
		for(var/contract_type in group_contract_types)
			if(contract_type in seen_types)
				continue
			seen_types += contract_type
			if(!(contract_type in list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOSS)))
				continue

			var/datum/quest/quest_template = ledger_ref.create_quest_for_type(contract_type)
			if(!istype(quest_template, /datum/quest/kill))
				if(quest_template)
					qdel(quest_template)
				continue

			var/datum/quest/kill/kill_template = quest_template
			var/list/tier_choices = kill_template.get_tier_choices()
			for(var/tier_label in tier_choices)
				var/tier_value = tier_choices[tier_label]
				kill_template.requested_tier = tier_value
				var/list/candidate_pool = kill_template.get_candidate_target_pool()
				for(var/mob_type in candidate_pool)
					var/source = ledger_ref.get_preview_icon_source_mob_type(mob_type)
					if(seen_sources[source])
						continue
					seen_sources[source] = TRUE
					if(insert_quest_preview_sprite(ledger_ref, source))
						inserted_count++
					CHECK_TICK

			qdel(kill_template)

	if(!inserted_count)
		// Nothing was inserted — don't attempt to realize an empty spritesheet.
		generation_in_progress = FALSE
		return

	// Refresh icon objects in sizes to prevent BYOND icon cache eviction.
	// After 40+ Insert() calls, each creating multiple icon() objects,
	// early icons may fall out of BYOND's FIFO icon cache.
	// get_icon_dimensions() on an expired icon returns width=0, causing
	// Division by zero in generate_css().
	// SPRSZ_ICON = 2 (defined in legacy_spritesheet.dm)
	for(var/size_id in sizes)
		var/list/size = sizes[size_id]
		if(size[2])
			size[2] = icon(size[2])

	// Unregister any empty assets from the initial register() pass,
	// then finalize with the actual sprites.
	unregister()
	fully_generated = FALSE
	realize_spritesheets(yield = FALSE)

	// Mark as complete AFTER everything is finalized, so send() won't
	// ship an empty CSS if called during generation.
	sprites_generated = TRUE
	// Always unlock — even if realize_spritesheets() threw a runtime,
	// next attempt (e.g. player opens ledger) can retry generation.
	generation_in_progress = FALSE

/// Inserts a single mob preview sprite. Returns TRUE on success.
/datum/asset/spritesheet/quest_previews/proc/insert_quest_preview_sprite(obj/structure/fake_machine/contractledger/ledger_ref, atom/mob_type)
	var/sprite_name = quest_preview_sprite_name(mob_type)
	if(!sprite_name)
		return FALSE

	var/icon/preview_icon

	// Simple_animal mobs — try static icon first, fall back to temp mob.
	// Some mobs (wolf, etc.) set icon_state dynamically in Initialize(),
	// so the initial() value may not exist in the DMI file.
	if(ispath(mob_type, /mob/living/simple_animal))
		var/icon_file = initial(mob_type.icon)
		var/icon_state = ledger_ref.get_simple_animal_preview_icon_state(mob_type)
		if(icon_file && icon_state)
			var/list/available_states = ledger_ref.get_preview_icon_states(icon_file)
			if(islist(available_states) && (icon_state in available_states))
				preview_icon = ledger_ref.build_target_preview_icon(mob_type, icon_file, icon_state)
				if(!preview_icon)
					preview_icon = icon(icon_file, icon_state, SOUTH, 1)
		// Static approach failed — spawn temp mob and getFlatIcon
		if(!preview_icon)
			var/turf/preview_turf = locate(1, 1, 1)
			if(!preview_turf)
				preview_turf = get_turf(ledger_ref)
			if(preview_turf)
				var/mob/temp_mob = new mob_type(preview_turf)
				if(temp_mob)
					temp_mob.setDir(SOUTH)
					var/icon/flattened = getFlatIcon(temp_mob, SOUTH, no_anim = TRUE)
					preview_icon = flattened ? icon(flattened, frame = 1) : null
					qdel(temp_mob)

	// Monster model human mobs (goblin, zombie, orc, kobold) —
	// use static icon from DMI directly. These mobs' regenerate_icons()
	// sets icon_state="" and builds via overlays, which don't render
	// correctly via getFlatIcon during LateInitialize.
	// initial(icon) and initial(icon_state) on these mob types point
	// to the species DMI file with valid states (e.g. "goblin", "zizombie").
	else if(ispath(mob_type, /mob/living/carbon/human) && ledger_ref.uses_monster_model_preview(mob_type))
		var/icon_file = initial(mob_type.icon)
		var/icon_state = initial(mob_type.icon_state)
		if(icon_file && icon_state)
			preview_icon = icon(icon_file, icon_state, SOUTH, 1)

	// Human outlaw mobs — need runtime mob creation + getFlatIcon for cropped torso
	else if(ispath(mob_type, /mob/living/carbon/human))
		var/turf/preview_turf = locate(1, 1, 1)
		if(!preview_turf)
			preview_turf = get_turf(ledger_ref)
		if(!preview_turf)
			return FALSE

		var/mob/living/carbon/human/temp_mob = new mob_type(preview_turf)
		if(!temp_mob)
			return FALSE
		temp_mob.setDir(SOUTH)
		ledger_ref.finalize_outlaw_preview_mob(temp_mob)
		preview_icon = ledger_ref.build_outlaw_runtime_preview_icon(temp_mob)
		qdel(temp_mob)

	// Generic mob fallback
	else if(ispath(mob_type, /mob))
		var/turf/preview_turf = locate(1, 1, 1)
		if(!preview_turf)
			preview_turf = get_turf(ledger_ref)
		if(!preview_turf)
			return FALSE

		var/mob/temp_mob = new mob_type(preview_turf)
		if(!temp_mob)
			return FALSE
		temp_mob.setDir(SOUTH)
		ledger_ref.finalize_preview_mob(temp_mob)
		var/icon/flattened = getFlatIcon(temp_mob, SOUTH, no_anim = TRUE)
		preview_icon = flattened ? icon(flattened, frame = 1) : null
		qdel(temp_mob)

	if(!preview_icon)
		return FALSE

	// Fit to 64x64 canvas
	preview_icon = ledger_ref.fit_preview_icon_to_square(preview_icon, 64)
	if(!preview_icon)
		return FALSE

	// Validate dimensions — icons with 0 width/height will cause
	// Division by zero in generate_css() later.
	if(preview_icon.Width() <= 0 || preview_icon.Height() <= 0)
		return FALSE

	// Detect actual icon_state name for Insert().
	// Static icons (simple_animal, monster model) retain their original
	// state name (e.g. "goblin", "zizombie") through fit_preview_icon_to_square.
	// queuedInsert does icon(src, icon_state=...) — passing "" when the icon
	// only has a named state produces an empty icon, silently skipping insertion.
	var/list/preview_states = icon_states(preview_icon)
	var/insert_state = length(preview_states) ? preview_states[1] : ""
	Insert(sprite_name, preview_icon, insert_state)
	return TRUE

/// Returns a deterministic CSS-safe sprite name for a given mob type path.
/proc/quest_preview_sprite_name(mob_type)
	if(!ispath(mob_type))
		return null
	return "quest_mob_[sanitize_css_class_name("[mob_type]")]"
