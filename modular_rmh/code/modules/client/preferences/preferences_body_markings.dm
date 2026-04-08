/datum/preferences/handle_body_markings_topic(mob/user, href_list)
	..()
	switch(href_list["preference"]) // Yes, for the sake of consistency
		if("switch_emissive")
			var/zone = href_list["key"]
			var/name = href_list["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return
			if(!emissive_markings[zone])
				emissive_markings[zone] = list()
			if(name in emissive_markings[zone])
				emissive_markings[zone] -= name
			else
				emissive_markings[zone] += name
