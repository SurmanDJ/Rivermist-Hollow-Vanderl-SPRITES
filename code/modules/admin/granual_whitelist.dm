GLOBAL_LIST_INIT(vessel_ids, list(WHITELIST_AUTOMATON))

/datum/whitelist_panel
	var/datum/admins/holder
	var/selected_ckey = null

/datum/whitelist_panel/New(datum/admins/passed_holder)
	holder = passed_holder
	return ..()

/datum/whitelist_panel/proc/show_ui(mob/user, forced_key)
	if(forced_key)
		selected_ckey = forced_key

	var/list/dat = list()
	dat += "<center><b>Whitelist Panel</b></center><HR>"
	dat += "<b>CKEY:</b> [selected_ckey] <a href='byond://?src=[REF(src)];task=ckey'>Change</a><BR><BR>"

	if(selected_ckey)
		dat += "<b>Current Whitelists for [selected_ckey]:</b><BR>"
		var/list/all_whitelists = GLOB.vessel_ids
		for(var/wl_id in all_whitelists)
			var/datum/save_manager/SM = get_save_manager(selected_ckey)
			var/data = SM ? SM.get_data("whitelists", wl_id, null) : null
			var/has_wl = islist(data) && data["granted"]
			dat += " - [wl_id]: <b>[has_wl ? "<font color='green'>Granted</font>" : "<font color='red'>Not Granted</font>"]</b>"
			if(islist(data))
				if(has_wl)
					dat += " (by [data["granted_by"]] on [time2text(data["granted_on"], "DD/MM/YYYY")])"
				else if(data["granted_by"])
					dat += " (revoked by [data["granted_by"]] on [time2text(data["revoked_on"], "DD/MM/YYYY")])"
			if(has_wl)
				dat += " <a href='byond://?src=[REF(src)];task=remove_whitelist;wl_id=[wl_id]'>Remove</a>"
			else
				dat += " <a href='byond://?src=[REF(src)];task=add_whitelist;wl_id=[wl_id]'>Grant</a>"
			dat += "<BR>"

		dat += "<BR><a href='byond://?src=[REF(src)];task=add_custom'>Add Custom Whitelist ID</a>"

		dat += "<HR><b>Current Job Whitelists for [selected_ckey]:</b><BR>"
		if(!CONFIG_GET(flag/sql_enabled))
			dat += "<font color='red'>SQL is disabled, so job whitelists are unavailable.</font><BR>"
		else
			var/list/job_whitelist_options = get_job_whitelist_options()
			var/list/job_whitelists = get_job_whitelist_grants(selected_ckey, TRUE)
			if(!islist(job_whitelists))
				dat += "<font color='red'>Could not load job whitelist data from the database.</font><BR>"
			else if(!length(job_whitelist_options))
				dat += "No jobs or subclasses currently use job whitelists.<BR>"
			else
				for(var/wl_id in job_whitelist_options)
					var/display_name = job_whitelist_options[wl_id]
					var/list/grant_data = job_whitelists[wl_id]
					var/has_wl = islist(grant_data)
					dat += " - [display_name]: <b>[has_wl ? "<font color='green'>Granted</font>" : "<font color='red'>Not Granted</font>"]</b>"
					if(has_wl)
						dat += " (by [grant_data["granted_by"]] on [grant_data["granted_at"]])"
						dat += " <a href='byond://?src=[REF(src)];task=remove_job_whitelist;wl_id=[wl_id]'>Remove</a>"
					else
						dat += " <a href='byond://?src=[REF(src)];task=add_job_whitelist;wl_id=[wl_id]'>Grant</a>"
					dat += "<BR>"

				for(var/wl_id in job_whitelists)
					if(job_whitelist_options[wl_id])
						continue
					var/list/grant_data = job_whitelists[wl_id]
					dat += " - [wl_id] (no longer mapped to a job): <b><font color='green'>Granted</font></b>"
					dat += " (by [grant_data["granted_by"]] on [grant_data["granted_at"]])"
					dat += " <a href='byond://?src=[REF(src)];task=remove_job_whitelist;wl_id=[wl_id]'>Remove</a><BR>"

	var/datum/browser/popup = new(user, "whitelist_panel", "Whitelist Panel", 400, 400)
	popup.set_content(dat.Join())
	popup.open()

/datum/whitelist_panel/proc/get_all_whitelist_ids()
	return list(
		WHITELIST_AUTOMATON,
		//as we add more we can fill it out here
	)

/datum/whitelist_panel/Topic(href, list/href_list)
	. = ..()
	if(!holder)
		return
	var/mob/user = usr
	if(holder.owner != user.client)
		return
	if(!check_rights_for(user.client, R_ADMIN))
		to_chat(user, span_boldwarning("No admin permission"))
		return

	switch(href_list["task"])
		if("ckey")
			var/chosen_ckey = input(user, "Enter ckey", "CKEY", selected_ckey) as text|null
			if(!chosen_ckey)
				return
			selected_ckey = ckey(chosen_ckey)

		if("add_whitelist")
			if(!selected_ckey)
				to_chat(user, span_boldwarning("No ckey selected."))
				return
			var/wl_id = href_list["wl_id"]
			grant_whitelist(user, selected_ckey, wl_id)

		if("remove_whitelist")
			if(!selected_ckey)
				to_chat(user, span_boldwarning("No ckey selected."))
				return
			var/wl_id = href_list["wl_id"]
			revoke_whitelist(user, selected_ckey, wl_id)

		if("add_job_whitelist")
			if(!selected_ckey)
				to_chat(user, span_boldwarning("No ckey selected."))
				return
			var/wl_id = href_list["wl_id"]
			grant_job_whitelist(user, selected_ckey, wl_id)

		if("remove_job_whitelist")
			if(!selected_ckey)
				to_chat(user, span_boldwarning("No ckey selected."))
				return
			var/wl_id = href_list["wl_id"]
			revoke_job_whitelist(user, selected_ckey, wl_id)

		if("add_custom")
			if(!selected_ckey)
				to_chat(user, span_boldwarning("No ckey selected."))
				return
			var/wl_id = input(user, "Enter custom whitelist ID (must match vessel_id exactly)", "Custom Whitelist", "") as text|null
			if(!wl_id)
				return
			grant_whitelist(user, selected_ckey, wl_id)

	show_ui(user)

/datum/whitelist_panel/proc/grant_whitelist(mob/user, target_ckey, wl_id)
	var/datum/save_manager/SM = get_save_manager(target_ckey)
	if(!SM)
		to_chat(user, span_boldwarning("Could not load save manager for [target_ckey]."))
		return
	SM.set_data("whitelists", wl_id, list(
		"granted" = TRUE,
		"granted_by" = ckey(user.ckey),
		"granted_on" = world.realtime
	))
	var/msg = "[key_name_admin(user)] granted whitelist '[wl_id]' to [target_ckey]"
	message_admins(msg)
	log_admin(msg)

/datum/whitelist_panel/proc/revoke_whitelist(mob/user, target_ckey, wl_id)
	var/datum/save_manager/SM = get_save_manager(target_ckey)
	if(!SM)
		to_chat(user, span_boldwarning("Could not load save manager for [target_ckey]."))
		return
	SM.set_data("whitelists", wl_id, list(
		"granted" = FALSE,
		"granted_by" = ckey(user.ckey),
		"revoked_on" = world.realtime
	))
	var/msg = "[key_name_admin(user)] revoked whitelist '[wl_id]' from [target_ckey]"
	message_admins(msg)
	log_admin(msg)

/datum/whitelist_panel/proc/grant_job_whitelist(mob/user, target_ckey, wl_id)
	var/list/job_whitelist_options = get_job_whitelist_options()
	if(!job_whitelist_options[wl_id])
		to_chat(user, span_boldwarning("Unknown job whitelist '[wl_id]'."))
		return
	if(!grant_job_whitelist_entry(target_ckey, wl_id, user.ckey))
		to_chat(user, span_boldwarning("Failed to grant the job whitelist '[wl_id]'. Check SQL connectivity."))
		return
	var/msg = "[key_name_admin(user)] granted job whitelist '[get_job_whitelist_label(wl_id)]' ([wl_id]) to [target_ckey]"
	message_admins(msg)
	log_admin(msg)

/datum/whitelist_panel/proc/revoke_job_whitelist(mob/user, target_ckey, wl_id)
	if(!revoke_job_whitelist_entry(target_ckey, wl_id))
		to_chat(user, span_boldwarning("Failed to revoke the job whitelist '[wl_id]'. Check SQL connectivity."))
		return
	var/msg = "[key_name_admin(user)] revoked job whitelist '[get_job_whitelist_label(wl_id)]' ([wl_id]) from [target_ckey]"
	message_admins(msg)
	log_admin(msg)

/client/proc/is_whitelisted(whitelist_id)
	var/datum/save_manager/SM = get_save_manager(ckey)
	if(!SM)
		return FALSE
	var/data = SM.get_data("whitelists", whitelist_id, null)
	if(!islist(data))
		return FALSE
	return data["granted"]

/proc/is_whitelisted_for(target_ckey, whitelist_id)
	var/datum/save_manager/SM = get_save_manager(target_ckey)
	if(!SM)
		return FALSE
	var/data = SM.get_data("whitelists", whitelist_id, null)
	if(!islist(data))
		return FALSE
	return data["granted"]
