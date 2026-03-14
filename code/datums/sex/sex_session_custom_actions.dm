/datum/sex_session
	var/custom_action_editor_mode = null
	var/custom_action_editor_key = null
	var/datum/sex_custom_action_data/custom_action_editor_draft = null

/datum/sex_session/proc/get_saved_custom_action_data()
	return get_player_custom_sex_actions(user.ckey, get_character_slot(user))

/datum/sex_session/proc/save_saved_custom_action_data(list/custom_actions)
	return save_player_custom_sex_actions(user.ckey, custom_actions, get_character_slot(user))

/datum/sex_session/proc/get_all_menu_actions()
	var/list/menu_actions = list()
	for(var/action_type in GLOB.sex_actions)
		var/datum/sex_action/action = SEX_ACTION(action_type)
		if(action)
			menu_actions += action

	var/list/custom_actions = get_saved_custom_action_data()
	for(var/action_id in custom_actions)
		var/datum/sex_custom_action_data/action_data = custom_actions[action_id]
		if(!action_data)
			continue
		menu_actions += new /datum/sex_action/custom(action_data)

	return menu_actions

/datum/sex_session/proc/is_custom_action_key(action_key)
	return istext(action_key) && findtext(action_key, SEX_CUSTOM_ACTION_PREFIX) == 1

/datum/sex_session/proc/extract_custom_action_id(action_key)
	if(!is_custom_action_key(action_key))
		return null
	return copytext("[action_key]", findtext("[action_key]", SEX_CUSTOM_ACTION_PREFIX) + length(SEX_CUSTOM_ACTION_PREFIX))

/datum/sex_session/proc/get_action_key(action_ref)
	if(istype(action_ref, /datum/sex_action))
		var/datum/sex_action/action = action_ref
		return action.get_menu_action_key()
	if(ispath(action_ref, /datum/sex_action))
		return "[action_ref]"
	if(istext(action_ref))
		var/action_key = trim(url_decode("[action_ref]"))
		if(!length(action_key))
			return null
		if(is_custom_action_key(action_key))
			return action_key
		var/list/custom_actions = get_saved_custom_action_data()
		if(action_key in custom_actions)
			return "[SEX_CUSTOM_ACTION_PREFIX][action_key]"
		return action_key
	return null

/datum/sex_session/proc/get_action_template(action_ref)
	if(istype(action_ref, /datum/sex_action))
		return action_ref

	var/action_key = get_action_key(action_ref)
	if(!action_key)
		return null

	var/list/custom_actions = get_saved_custom_action_data()
	if(is_custom_action_key(action_key))
		var/custom_action_id = extract_custom_action_id(action_key)
		var/datum/sex_custom_action_data/action_data = custom_actions[custom_action_id]
		if(!action_data)
			return null
		return new /datum/sex_action/custom(action_data)

	if(action_key in custom_actions)
		var/datum/sex_custom_action_data/action_data = custom_actions[action_key]
		if(action_data)
			return new /datum/sex_action/custom(action_data)

	var/resolved_action_type = text2path(action_key)
	if(!resolved_action_type || !ispath(resolved_action_type, /datum/sex_action))
		return null
	return SEX_ACTION(resolved_action_type)

/datum/sex_session/proc/instantiate_action(action_ref)
	var/datum/sex_action/action_template = get_action_template(action_ref)
	if(!action_template)
		return null
	return action_template.build_runtime_instance()

/datum/sex_session/proc/get_custom_action_zone_label(part)
	var/zone_mask = get_custom_sex_part_filter_mask(part)
	switch(zone_mask)
		if(SEX_UI_ZONE_MOUTH)
			return "Mouth"
		if(SEX_UI_ZONE_GENITALS)
			return "Genitals"
		if(SEX_UI_ZONE_ARMS)
			return "Arms"
		if(SEX_UI_ZONE_LEGS)
			return "Legs"
		if(SEX_UI_ZONE_BODY)
			return "Body"
	return "Misc"

/datum/sex_session/proc/load_custom_action_draft_from_template(template_id)
	var/datum/sex_custom_action_template/template = GLOB.sex_custom_action_templates[template_id]
	if(!template)
		return FALSE
	custom_action_editor_mode = "template"
	custom_action_editor_key = template_id
	custom_action_editor_draft = template.build_draft()
	return TRUE

/datum/sex_session/proc/load_custom_action_draft_from_saved(action_id)
	var/list/custom_actions = get_saved_custom_action_data()
	var/datum/sex_custom_action_data/action_data = custom_actions[action_id]
	if(!action_data)
		return FALSE
	custom_action_editor_mode = "custom"
	custom_action_editor_key = action_id
	custom_action_editor_draft = action_data.copy()
	return TRUE

/datum/sex_session/proc/reset_custom_action_draft()
	if(custom_action_editor_mode == "custom" && custom_action_editor_key)
		return load_custom_action_draft_from_saved(custom_action_editor_key)
	if(custom_action_editor_mode == "template" && custom_action_editor_key)
		return load_custom_action_draft_from_template(custom_action_editor_key)
	custom_action_editor_draft = null
	custom_action_editor_mode = null
	custom_action_editor_key = null
	return TRUE

/datum/sex_session/proc/save_custom_action_draft()
	if(!custom_action_editor_draft)
		return FALSE

	custom_action_editor_draft.normalize()
	var/list/custom_actions = get_saved_custom_action_data()
	var/is_new_action = !length(custom_action_editor_draft.id)
	if(is_new_action)
		custom_action_editor_draft.id = generate_custom_sex_action_id()
		custom_action_editor_draft.created = world.realtime
	else
		var/datum/sex_custom_action_data/existing_action = custom_actions[custom_action_editor_draft.id]
		if(existing_action?.created)
			custom_action_editor_draft.created = existing_action.created
		else if(!custom_action_editor_draft.created)
			custom_action_editor_draft.created = world.realtime

	custom_action_editor_draft.last_modified = world.realtime
	custom_actions[custom_action_editor_draft.id] = custom_action_editor_draft.copy()

	if(!save_saved_custom_action_data(custom_actions))
		return FALSE

	custom_action_editor_mode = "custom"
	custom_action_editor_key = custom_action_editor_draft.id
	custom_action_editor_draft = custom_actions[custom_action_editor_draft.id].copy()
	to_chat(user, span_notice("[is_new_action ? "Saved" : "Updated"] custom action '[custom_action_editor_draft.name]'."))
	return TRUE

/datum/sex_session/proc/delete_custom_action(action_id)
	if(!action_id)
		return FALSE
	var/list/custom_actions = get_saved_custom_action_data()
	if(!(action_id in custom_actions))
		return FALSE
	var/datum/sex_custom_action_data/deleted_action = custom_actions[action_id]
	custom_actions.Remove(action_id)
	if(!save_saved_custom_action_data(custom_actions))
		return FALSE
	if(custom_action_editor_key == action_id)
		custom_action_editor_mode = null
		custom_action_editor_key = null
		custom_action_editor_draft = null
	to_chat(user, span_notice("Deleted custom action '[deleted_action?.name || action_id]'."))
	return TRUE

/datum/sex_session/proc/get_custom_scope_options()
	return list(
		"Partner" = SEX_CUSTOM_SCOPE_PARTNER,
		"Solo" = SEX_CUSTOM_SCOPE_SELF,
	)

/datum/sex_session/proc/get_custom_part_options()
	return list(
		"Unspecified" = SEX_CUSTOM_PART_NONE,
		"Mouth" = SEX_CUSTOM_PART_MOUTH,
		"Penis" = SEX_CUSTOM_PART_PENIS,
		"Vagina" = SEX_CUSTOM_PART_VAGINA,
		"Anus" = SEX_CUSTOM_PART_ANUS,
		"Breasts" = SEX_CUSTOM_PART_BREASTS,
		"Testicles" = SEX_CUSTOM_PART_TESTICLES,
		"Hands" = SEX_CUSTOM_PART_HANDS,
		"Feet" = SEX_CUSTOM_PART_FEET,
		"Thighs" = SEX_CUSTOM_PART_THIGHS,
		"Body" = SEX_CUSTOM_PART_BODY,
		"Any genitals" = SEX_CUSTOM_PART_ANY_GENITALS,
	)

/datum/sex_session/proc/get_custom_climax_options()
	return list(
		"Default" = null,
		"On body" = ORGASM_LOCATION_ONTO,
		"Inside" = ORGASM_LOCATION_INTO,
		"Oral" = ORGASM_LOCATION_ORAL,
		"On self" = ORGASM_LOCATION_SELF,
	)

/datum/sex_session/proc/prompt_custom_action_text(prompt_title, field_title, current_value, max_length = 256)
	var/new_value = input(user, prompt_title, field_title, current_value) as message|null
	if(isnull(new_value))
		return null
	new_value = trim("[new_value]")
	if(length(new_value) > max_length)
		new_value = copytext(new_value, 1, max_length + 1)
	return new_value

/datum/sex_session/proc/edit_custom_action_field(field_id)
	if(!custom_action_editor_draft)
		return FALSE

	switch(field_id)
		if("name")
			var/new_name = prompt_custom_action_text("Enter the action name.", "Custom Action Name", custom_action_editor_draft.name, 64)
			if(isnull(new_name))
				return FALSE
			if(!length(new_name))
				to_chat(user, span_warning("Custom actions need a name."))
				return FALSE
			custom_action_editor_draft.name = new_name
		if("scope")
			var/list/options = get_custom_scope_options()
			var/current_label = get_custom_sex_scope_label(custom_action_editor_draft.action_scope)
			var/choice = input(user, "Choose who this action is meant for.", "Action Scope", current_label) as null|anything in options
			if(isnull(choice))
				return FALSE
			custom_action_editor_draft.action_scope = options[choice]
		if("user_part")
			var/list/options = get_custom_part_options()
			var/current_label = get_custom_sex_part_label(custom_action_editor_draft.required_user_part)
			var/choice = input(user, "Choose the body part or organ you use.", "Acting Part", current_label) as null|anything in options
			if(isnull(choice))
				return FALSE
			custom_action_editor_draft.required_user_part = options[choice]
		if("target_part")
			var/list/options = get_custom_part_options()
			var/current_label = get_custom_sex_part_label(custom_action_editor_draft.required_target_part)
			var/choice = input(user, "Choose the body part or organ on the receiving side.", "Receiving Part", current_label) as null|anything in options
			if(isnull(choice))
				return FALSE
			custom_action_editor_draft.required_target_part = options[choice]
		if("require_same_tile")
			custom_action_editor_draft.require_same_tile = !custom_action_editor_draft.require_same_tile
		if("require_grab")
			custom_action_editor_draft.require_grab = !custom_action_editor_draft.require_grab
		if("requires_free_hands")
			custom_action_editor_draft.requires_free_hands = !custom_action_editor_draft.requires_free_hands
		if("gags_user")
			custom_action_editor_draft.gags_user = !custom_action_editor_draft.gags_user
		if("gags_target")
			custom_action_editor_draft.gags_target = !custom_action_editor_draft.gags_target
		if("do_time_seconds")
			var/new_time = input(user, "How many seconds should one cycle take?", "Action Timing", custom_action_editor_draft.do_time_seconds) as num|null
			if(isnull(new_time))
				return FALSE
			custom_action_editor_draft.do_time_seconds = clamp(new_time, 0.5, 10)
		if("stamina_cost")
			var/new_cost = input(user, "How much stamina should one cycle cost?", "Stamina Cost", custom_action_editor_draft.stamina_cost) as num|null
			if(isnull(new_cost))
				return FALSE
			custom_action_editor_draft.stamina_cost = clamp(new_cost, 0, 10)
		if("user_arousal")
			var/new_value = input(user, "How much arousal should the acting side gain each cycle?", "Actor Arousal", custom_action_editor_draft.user_arousal) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.user_arousal = clamp(new_value, 0, 10)
		if("user_pain")
			var/new_value = input(user, "How much pain should the acting side gain each cycle?", "Actor Pain", custom_action_editor_draft.user_pain) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.user_pain = clamp(new_value, 0, 10)
		if("user_orgasm")
			var/new_value = input(user, "How much orgasm progress should the acting side gain each cycle?", "Actor Orgasm Progress", custom_action_editor_draft.user_orgasm) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.user_orgasm = clamp(new_value, 0, 10)
		if("target_arousal")
			var/new_value = input(user, "How much arousal should the receiving side gain each cycle?", "Target Arousal", custom_action_editor_draft.target_arousal) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.target_arousal = clamp(new_value, 0, 10)
		if("target_pain")
			var/new_value = input(user, "How much pain should the receiving side gain each cycle?", "Target Pain", custom_action_editor_draft.target_pain) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.target_pain = clamp(new_value, 0, 10)
		if("target_orgasm")
			var/new_value = input(user, "How much orgasm progress should the receiving side gain each cycle?", "Target Orgasm Progress", custom_action_editor_draft.target_orgasm) as num|null
			if(isnull(new_value))
				return FALSE
			custom_action_editor_draft.target_orgasm = clamp(new_value, 0, 10)
		if("message_start")
			custom_action_editor_draft.message_start = prompt_custom_action_text("Optional message when the action starts. Leave blank to use a fallback line.", "Start Message", custom_action_editor_draft.message_start, 400)
		if("message_tick")
			custom_action_editor_draft.message_tick = prompt_custom_action_text("Optional message for each action cycle. Leave blank to use a fallback line.", "Cycle Message", custom_action_editor_draft.message_tick, 400)
		if("message_finish")
			custom_action_editor_draft.message_finish = prompt_custom_action_text("Optional message when the action stops. Leave blank to use a fallback line.", "Finish Message", custom_action_editor_draft.message_finish, 400)
		if("message_climax_active")
			custom_action_editor_draft.message_climax_active = prompt_custom_action_text("Optional message when the acting side climaxes.", "Actor Climax Message", custom_action_editor_draft.message_climax_active, 400)
		if("message_climax_passive")
			custom_action_editor_draft.message_climax_passive = prompt_custom_action_text("Optional message when the receiving side climaxes.", "Receiver Climax Message", custom_action_editor_draft.message_climax_passive, 400)
		if("active_climax_location")
			var/list/options = get_custom_climax_options()
			var/current_label = get_custom_sex_climax_location_label(custom_action_editor_draft.active_climax_location)
			var/choice = input(user, "Choose the climax placement for the acting side.", "Actor Climax Result", current_label) as null|anything in options
			if(isnull(choice))
				return FALSE
			custom_action_editor_draft.active_climax_location = options[choice]
		if("passive_climax_location")
			var/list/options = get_custom_climax_options()
			var/current_label = get_custom_sex_climax_location_label(custom_action_editor_draft.passive_climax_location)
			var/choice = input(user, "Choose the climax placement for the receiving side.", "Receiver Climax Result", current_label) as null|anything in options
			if(isnull(choice))
				return FALSE
			custom_action_editor_draft.passive_climax_location = options[choice]
		else
			return FALSE

	custom_action_editor_draft.normalize()
	return TRUE

/datum/sex_session/proc/render_custom_action_selector(label, summary, href_task, href_value, selected_tab, selected = FALSE)
	var/item_class = "custom-sidebar-item"
	if(selected)
		item_class += " active"
	return "<a class='[item_class]' href='?src=[REF(src)];task=[href_task];value=[url_encode("[href_value]")];tab=[selected_tab]'><span class='custom-sidebar-name'>[html_encode(label)]</span><span class='custom-sidebar-summary'>[html_encode(summary)]</span></a>"

/datum/sex_session/proc/render_custom_action_field(label, field_id, value, selected_tab, details = null)
	var/display_value = value
	if(!length("[display_value]"))
		display_value = "<span class='custom-editor-empty'>Not set</span>"
	else
		display_value = html_encode("[display_value]")
		display_value = replacetext(display_value, "\n", "<br>")

	var/list/content = list()
	content += "<a class='custom-editor-field' href='?src=[REF(src)];task=custom_edit_field;field=[field_id];tab=[selected_tab]'>"
	content += "<span class='custom-editor-label'>[html_encode(label)]</span>"
	content += "<span class='custom-editor-value'>[display_value]</span>"
	if(details)
		content += "<span class='custom-editor-detail'>[html_encode(details)]</span>"
	content += "</a>"
	return content.Join("")

/datum/sex_session/proc/render_custom_action_info(label, value)
	return "<div class='custom-editor-field info'><span class='custom-editor-label'>[html_encode(label)]</span><span class='custom-editor-value'>[html_encode("[value]")]</span></div>"

/datum/sex_session/proc/get_custom_actions_tab_content(selected_tab = "custom_actions")
	var/list/content = list()
	var/list/custom_actions = get_saved_custom_action_data()

	content += "<div class='custom-actions-layout'>"
	content += "<div class='custom-actions-sidebar'>"
	content += "<div class='prefs-header'>Templates</div>"
	for(var/template_id in GLOB.sex_custom_action_templates)
		var/datum/sex_custom_action_template/template = GLOB.sex_custom_action_templates[template_id]
		var/is_selected = (custom_action_editor_mode == "template" && custom_action_editor_key == template_id)
		content += render_custom_action_selector(template.template_name, template.template_summary, "custom_select_template", template_id, selected_tab, is_selected)

	content += "<div class='prefs-header' style='margin-top: 10px;'>Saved Actions</div>"
	if(!length(custom_actions))
		content += "<div class='no-data'>You have not saved any custom actions yet.</div>"
	else
		for(var/action_id in custom_actions)
			var/datum/sex_custom_action_data/action_data = custom_actions[action_id]
			var/is_selected = (custom_action_editor_mode == "custom" && custom_action_editor_key == action_id)
			content += render_custom_action_selector(action_data.name, get_custom_action_summary(action_data), "custom_select_saved", action_id, selected_tab, is_selected)
	content += "</div>"

	content += "<div class='custom-actions-editor'>"
	if(!custom_action_editor_draft)
		content += "<div class='no-data'>Pick a template on the left or load one of your saved custom actions.</div>"
	else
		custom_action_editor_draft.normalize()
		var/is_saved_action = (custom_action_editor_mode == "custom" && length(custom_action_editor_draft.id))
		var/header_text = is_saved_action ? "Editing Saved Action" : "Editing Draft"
		content += "<div class='panel-header'>"
		content += "<h3>[header_text]: [html_encode(custom_action_editor_draft.name)]</h3>"
		content += "<div class='custom-editor-buttons'>"
		content += "<a class='control-btn' href='?src=[REF(src)];task=custom_save;tab=[selected_tab]'>[is_saved_action ? "Save Changes" : "Create Action"]</a>"
		content += "<a class='control-btn' href='?src=[REF(src)];task=custom_reset;tab=[selected_tab]'>Reset Draft</a>"
		if(is_saved_action)
			content += "<a class='control-btn remove-btn' href='?src=[REF(src)];task=custom_delete;value=[url_encode(custom_action_editor_draft.id)];tab=[selected_tab]' onclick='return confirm(\"Delete [html_encode(custom_action_editor_draft.name)]?\")'>Delete</a>"
		content += "</div>"
		content += "</div>"

		content += "<div class='action-summary'>Templates provide sensible defaults; filters in the interaction list are derived automatically from Acting Part and Receiving Part.</div>"
		content += "<div class='action-summary'>Message tokens: {name}, {user}, {target}, {user_their}, {target_their}, {user_them}, {target_them}, {force}, {speed}, {user_part}, {target_part}.</div>"

		content += "<div class='custom-editor-section'>"
		content += "<div class='action-subheader'>Basics</div>"
		content += render_custom_action_field("Name", "name", custom_action_editor_draft.name, selected_tab)
		content += render_custom_action_field("Scope", "scope", get_custom_sex_scope_label(custom_action_editor_draft.action_scope), selected_tab, "Partner actions only show against other people. Solo actions only show when targeting yourself.")
		content += render_custom_action_field("Acting Part", "user_part", get_custom_sex_part_label(custom_action_editor_draft.required_user_part), selected_tab, "This also decides the left-side interaction filter bucket.")
		content += render_custom_action_field("Receiving Part", "target_part", get_custom_sex_part_label(custom_action_editor_draft.required_target_part), selected_tab, "This also decides the right-side interaction filter bucket.")
		content += render_custom_action_info("Interaction Filters", "[get_custom_action_zone_label(custom_action_editor_draft.required_user_part)] -> [get_custom_action_zone_label(custom_action_editor_draft.required_target_part)]")
		content += "</div>"

		content += "<div class='custom-editor-section'>"
		content += "<div class='action-subheader'>Rules</div>"
		content += render_custom_action_field("Require Same Tile", "require_same_tile", custom_action_editor_draft.require_same_tile ? "Yes" : "No", selected_tab)
		content += render_custom_action_field("Require Grab", "require_grab", custom_action_editor_draft.require_grab ? "Yes" : "No", selected_tab)
		content += render_custom_action_field("Requires Free Hands", "requires_free_hands", custom_action_editor_draft.requires_free_hands ? "Yes" : "No", selected_tab)
		content += render_custom_action_field("Gag Acting Side", "gags_user", custom_action_editor_draft.gags_user ? "Yes" : "No", selected_tab)
		content += render_custom_action_field("Gag Receiving Side", "gags_target", custom_action_editor_draft.gags_target ? "Yes" : "No", selected_tab)
		content += render_custom_action_field("Cycle Time", "do_time_seconds", "[custom_action_editor_draft.do_time_seconds] seconds", selected_tab)
		content += render_custom_action_field("Stamina Cost", "stamina_cost", "[custom_action_editor_draft.stamina_cost]", selected_tab)
		content += "</div>"

		content += "<div class='custom-editor-section'>"
		content += "<div class='action-subheader'>Effects Per Cycle</div>"
		content += render_custom_action_field("Actor Arousal", "user_arousal", "[custom_action_editor_draft.user_arousal]", selected_tab)
		content += render_custom_action_field("Actor Pain", "user_pain", "[custom_action_editor_draft.user_pain]", selected_tab)
		content += render_custom_action_field("Actor Orgasm Progress", "user_orgasm", "[custom_action_editor_draft.user_orgasm]", selected_tab)
		content += render_custom_action_field("Receiver Arousal", "target_arousal", "[custom_action_editor_draft.target_arousal]", selected_tab)
		content += render_custom_action_field("Receiver Pain", "target_pain", "[custom_action_editor_draft.target_pain]", selected_tab)
		content += render_custom_action_field("Receiver Orgasm Progress", "target_orgasm", "[custom_action_editor_draft.target_orgasm]", selected_tab)
		content += "</div>"

		content += "<div class='custom-editor-section'>"
		content += "<div class='action-subheader'>Messages</div>"
		content += render_custom_action_field("Start Message", "message_start", custom_action_editor_draft.message_start, selected_tab)
		content += render_custom_action_field("Cycle Message", "message_tick", custom_action_editor_draft.message_tick, selected_tab)
		content += render_custom_action_field("Finish Message", "message_finish", custom_action_editor_draft.message_finish, selected_tab)
		content += "</div>"

		content += "<div class='custom-editor-section'>"
		content += "<div class='action-subheader'>Climax Handling</div>"
		content += render_custom_action_field("Actor Climax Message", "message_climax_active", custom_action_editor_draft.message_climax_active, selected_tab)
		content += render_custom_action_field("Actor Climax Result", "active_climax_location", get_custom_sex_climax_location_label(custom_action_editor_draft.active_climax_location), selected_tab)
		content += render_custom_action_field("Receiver Climax Message", "message_climax_passive", custom_action_editor_draft.message_climax_passive, selected_tab)
		content += render_custom_action_field("Receiver Climax Result", "passive_climax_location", get_custom_sex_climax_location_label(custom_action_editor_draft.passive_climax_location), selected_tab)
		content += "</div>"

		if(is_saved_action)
			var/created_text = custom_action_editor_draft.created ? time2text(custom_action_editor_draft.created, "MM/DD/YY hh:mm") : "Unknown"
			var/modified_text = custom_action_editor_draft.last_modified ? time2text(custom_action_editor_draft.last_modified, "MM/DD/YY hh:mm") : created_text
			content += "<div class='action-summary'>Saved: [created_text] | Updated: [modified_text]</div>"
		content += "</div>"
	content += "</div>"

	return content.Join("")

/datum/sex_session/proc/handle_custom_action_topic(list/href_list)
	switch(href_list["task"])
		if("custom_select_template")
			return load_custom_action_draft_from_template(url_decode(href_list["value"]))
		if("custom_select_saved")
			return load_custom_action_draft_from_saved(url_decode(href_list["value"]))
		if("custom_edit_field")
			return edit_custom_action_field(href_list["field"])
		if("custom_save")
			if(!save_custom_action_draft())
				to_chat(user, span_warning("Failed to save the custom action."))
			return TRUE
		if("custom_delete")
			if(!delete_custom_action(url_decode(href_list["value"])))
				to_chat(user, span_warning("Failed to delete that custom action."))
			return TRUE
		if("custom_reset")
			return reset_custom_action_draft()
	return FALSE
