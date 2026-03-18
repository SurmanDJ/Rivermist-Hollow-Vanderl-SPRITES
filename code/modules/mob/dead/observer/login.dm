/mob/dead/observer/Login()
	..()

	if(client && client.prefs)
		client.fps = client.prefs.clientfps
		ghost_accs = client.prefs.ghost_accs
		ghost_others = client.prefs.ghost_others
	var/preferred_form = null

	if(IsAdminGhost(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.ghost_form
		ghost_orbit = client.prefs.ghost_orbit

	apply_admin_ghost_icon_preference()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	if(preferred_form)
		icon_state = preferred_form

	updateghostimages()
