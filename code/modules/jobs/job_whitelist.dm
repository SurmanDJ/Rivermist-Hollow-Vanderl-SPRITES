GLOBAL_LIST_EMPTY(job_whitelist_cache)

/proc/get_job_whitelist_grants(target_ckey, force_refresh = FALSE)
	target_ckey = ckey(target_ckey)
	if(!target_ckey)
		return list()

	if(!force_refresh)
		var/list/cached_grants = GLOB.job_whitelist_cache[target_ckey]
		if(islist(cached_grants))
			return cached_grants

	if(!CONFIG_GET(flag/sql_enabled))
		return null
	if(SSdbcore.shutting_down || !SSdbcore.Connect())
		return null

	var/list/grants = list()
	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"SELECT whitelist_id, granted_by_ckey, granted_at FROM [format_table_name("job_whitelist")] WHERE ckey = :ckey ORDER BY whitelist_id",
		list("ckey" = target_ckey)
	)
	if(!query.warn_execute())
		qdel(query)
		return null

	while(query.NextRow())
		grants[query.item[1]] = list(
			"granted_by" = query.item[2],
			"granted_at" = query.item[3]
		)

	qdel(query)
	GLOB.job_whitelist_cache[target_ckey] = grants
	return grants

/proc/clear_job_whitelist_cache(target_ckey)
	target_ckey = ckey(target_ckey)
	if(!target_ckey)
		return
	GLOB.job_whitelist_cache[target_ckey] = null

/proc/is_job_whitelisted_for(target_ckey, whitelist_id)
	if(!whitelist_id)
		return TRUE

	var/list/grants = get_job_whitelist_grants(target_ckey)
	if(!islist(grants))
		return FALSE
	return !isnull(grants[whitelist_id])

/proc/grant_job_whitelist_entry(target_ckey, whitelist_id, admin_ckey)
	target_ckey = ckey(target_ckey)
	admin_ckey = ckey(admin_ckey)
	whitelist_id = "[whitelist_id]"
	if(!target_ckey || !admin_ckey || !length(whitelist_id))
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	if(SSdbcore.shutting_down || !SSdbcore.Connect())
		return FALSE

	var/datum/DBQuery/query = SSdbcore.NewQuery(
		{"INSERT INTO [format_table_name("job_whitelist")] (ckey, whitelist_id, granted_by_ckey, granted_at)
		VALUES (:ckey, :whitelist_id, :admin_ckey, Now())
		ON DUPLICATE KEY UPDATE granted_by_ckey = :admin_ckey, granted_at = Now()"},
		list(
			"ckey" = target_ckey,
			"whitelist_id" = whitelist_id,
			"admin_ckey" = admin_ckey
		)
	)
	var/succeeded = query.warn_execute()
	qdel(query)

	if(succeeded)
		clear_job_whitelist_cache(target_ckey)
	return succeeded

/proc/revoke_job_whitelist_entry(target_ckey, whitelist_id)
	target_ckey = ckey(target_ckey)
	whitelist_id = "[whitelist_id]"
	if(!target_ckey || !length(whitelist_id))
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	if(SSdbcore.shutting_down || !SSdbcore.Connect())
		return FALSE

	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"DELETE FROM [format_table_name("job_whitelist")] WHERE ckey = :ckey AND whitelist_id = :whitelist_id",
		list(
			"ckey" = target_ckey,
			"whitelist_id" = whitelist_id
		)
	)
	var/succeeded = query.warn_execute()
	qdel(query)

	if(succeeded)
		clear_job_whitelist_cache(target_ckey)
	return succeeded

/proc/get_job_whitelist_options()
	var/list/options = list()
	if(!SSjob)
		return options
	if(!length(SSjob.all_occupations))
		SSjob.SetupOccupations()
	if(!length(SSjob.all_occupations))
		return options

	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(!job.job_whitelist_id)
			continue
		if(options[job.job_whitelist_id])
			continue

		var/entry_type = "Job"
		if(istype(job, /datum/job/advclass))
			entry_type = "Subclass"
		options[job.job_whitelist_id] = "[job.title] ([entry_type])"

	return options

/proc/get_job_whitelist_label(whitelist_id)
	if(!whitelist_id)
		return null

	var/list/options = get_job_whitelist_options()
	return options[whitelist_id] || whitelist_id

/client/proc/is_job_whitelisted(whitelist_id)
	return is_job_whitelisted_for(ckey, whitelist_id)
