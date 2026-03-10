/obj/structure/fake_machine/contractledger
	name = "Grand Contract Ledger"
	desc = "A massive ledger book with gilded edges, sitting atop a pedestal with the Mercenary's Guild banner. Its myriad enchanted pages are filled with various contracts and bounties issued by Mercenary's Guild, with arcane scripts that appears and fades as contracts are issued and completed."
	icon = 'icons/obj/questing.dmi'
	icon_state = "contractledger"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	layer = ABOVE_MOB_LAYER
	layer = GAME_PLANE_UPPER
	var/input_point

/obj/structure/fake_machine/contractledger/Initialize()
	. = ..()
	input_point = locate(x, y - 1, z)
	var/obj/effect/decal/marker_export/marker = new(get_turf(input_point))
	marker.desc = "Place completed contract scrolls here to turn them in."
	marker.layer = ABOVE_OBJ_LAYER

/obj/structure/fake_machine/contractledger/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = .. ()
	if(istype(P, /obj/item/paper/scroll/quest))
		turn_in_contract(user, P)
		return
	return

/obj/structure/fake_machine/contractledger/Topic(href, href_list)
	. = ..()
	if(href_list["consultcontracts"])
		consult_contracts(usr)
		return attack_hand(usr)
	if(href_list["turnincontract"])
		turn_in_contract(usr)
		return attack_hand(usr)
	if(href_list["abandoncontract"])
		abandon_contract(usr)
		return attack_hand(usr)
	if(href_list["printcontracts"])
		print_contracts(usr)
		return attack_hand(usr)
	return attack_hand(usr)

/obj/structure/fake_machine/contractledger/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	// Keep this browser-driven; native list input is faster here than TGUI.
	var/contents = "<center><h2>Grand Contract Ledger</h2>"
	contents += "<a href='?src=[REF(src)];consultcontracts=1'>Consult Contracts</a><br>"
	contents += "<a href='?src=[REF(src)];turnincontract=1'>Turn in Contract</a><br>"
	contents += "<a href='?src=[REF(src)];abandoncontract=1'>Abandon Contract</a><br>"
	if(is_quest_handler(user))
		contents += "<a href='?src=[REF(src)];printcontracts=1'>Print Issued Contracts</a><br>"
	contents += "</center>"
	var/datum/browser/popup = new(user, "Grand Contract Ledger", "", 500, 300)
	popup.set_content(contents)
	popup.open()

/obj/structure/fake_machine/contractledger/proc/is_quest_handler(mob/user)
	if(!user)
		return FALSE

	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null
	if(!mob_job)
		return FALSE

	var/job_name = lowertext(mob_job.title ? mob_job.title : user.job)
	return mob_job.is_quest_giver || findtext(job_name, "merchant") || findtext(job_name, "banker") || findtext(job_name, "steward")

/obj/structure/fake_machine/contractledger/proc/is_boss_raid_issuer(mob/user)
	if(!user)
		return FALSE

	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null
	if(!mob_job)
		return FALSE

	var/job_name = lowertext(mob_job.title ? mob_job.title : user.job)
	return is_burgmeister_job(mob_job) || \
		findtext(job_name, "councilor") || \
		is_adventurers_guildmaster_job(mob_job) || \
		is_adventurers_assistant_job(mob_job) || \
		(findtext(job_name, "guildmaster") && findtext(job_name, "adventurer")) || \
		(findtext(job_name, "assistant") && findtext(job_name, "adventurer"))

/obj/structure/fake_machine/contractledger/proc/create_quest_for_type(contract_type)
	var/quest_path = GLOB.global_quest_registry[contract_type]
	if(!quest_path)
		return null
	return new quest_path

/obj/structure/fake_machine/contractledger/proc/get_available_contract_groups(mob/user)
	var/list/group_choices = list()
	for(var/contract_group in GLOB.global_quest_contract_groups)
		var/list/types_in_group = get_available_contract_types(user, contract_group)
		if(length(types_in_group))
			group_choices[contract_group] = contract_group
	return group_choices

/obj/structure/fake_machine/contractledger/proc/get_available_contract_types(mob/user, contract_group)
	var/list/type_choices = list()
	var/list/group_types = GLOB.global_quest_contract_groups[contract_group] || list()

	for(var/contract_type in group_types)
		if((contract_type in list(QUEST_RAID, QUEST_BOSS)) && !is_boss_raid_issuer(user))
			continue

		var/datum/quest/template = create_quest_for_type(contract_type)
		if(!template)
			continue

		type_choices["[template.quest_type] ([template.get_tier_band_text()])"] = contract_type
		qdel(template)

	return type_choices

/obj/structure/fake_machine/contractledger/proc/consult_contracts(mob/user)
	if(!(user in SStreasury.bank_accounts))
		say("You have no bank account.")
		return

	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null
	var/is_handler = is_quest_handler(user)
	if(!is_handler)
		var/quest_number = 0
		for(var/obj/item/paper/scroll/quest/quest_scroll in GLOB.quest_scrolls)
			var/datum/weakref/weakref_datum = WEAKREF(user)
			if(quest_scroll.assigned_quest && !quest_scroll.assigned_quest.complete && quest_scroll.assigned_quest.quest_receiver_reference == weakref_datum)
				quest_number++
		var/max_quests_for_job = mob_job?.max_active_quests || 3
		if(quest_number >= max_quests_for_job)
			say("You have reached the maximum number of active quests. You can take up to [max_quests_for_job] active quests at a time.")
			return

	var/list/group_choices = get_available_contract_groups(user)
	if(!length(group_choices))
		say("No contract groups are currently available.")
		return

	var/group_selection = input(user, "Select contract group", "CONTRACTS") as null|anything in group_choices
	if(!group_selection)
		return

	var/selected_group = group_choices[group_selection]
	var/list/type_choices = get_available_contract_types(user, selected_group)
	if(!length(type_choices))
		say("No contracts are currently available in that group.")
		return

	var/type_selection_label = input(user, "Select contract type", "CONTRACTS") as null|anything in type_choices
	if(!type_selection_label)
		return

	var/type_selection = type_choices[type_selection_label]
	var/datum/quest/attached_quest = create_quest_for_type(type_selection)

	if(!attached_quest)
		to_chat(user, span_warning("Invalid quest type selected!"))
		return

	var/list/tier_choices = attached_quest.get_tier_choices()
	var/tier_selection = input(user, "Select contract threat tier", "CONTRACTS") as null|anything in tier_choices
	if(!tier_selection)
		qdel(attached_quest)
		return

	attached_quest.requested_tier = tier_choices[tier_selection]

	// Set giver or receiver
	if(is_handler)
		attached_quest.quest_giver_name = user.real_name
		attached_quest.quest_giver_reference = WEAKREF(user)
	else
		attached_quest.quest_receiver_reference = WEAKREF(user)
		attached_quest.quest_receiver_name = user.real_name

	// Find appropriate landmark
	var/obj/effect/landmark/quest_spawner/chosen_landmark = find_quest_landmark(attached_quest.requested_tier, type_selection)
	if(!chosen_landmark)
		to_chat(user, span_warning("No suitable location found for this contract!"))
		qdel(attached_quest)
		return

	// Generate quest content (spawns mobs/items)
	if(!attached_quest.generate(chosen_landmark))
		to_chat(user, span_warning("Failed to generate quest content!"))
		qdel(attached_quest)
		return

	// Create scroll
	var/obj/item/paper/scroll/quest/spawned_scroll = new(get_turf(src))
	spawned_scroll.assigned_quest = attached_quest
	attached_quest.quest_scroll = spawned_scroll
	attached_quest.quest_scroll_ref = WEAKREF(spawned_scroll)

	// Reward calculation comes after generation & scroll creation to factor in delivery/pickup distance.
	attached_quest.reward_amount = attached_quest.calculate_reward(get_turf(chosen_landmark))
	attached_quest.deposit_amount = attached_quest.calculate_deposit(attached_quest.reward_amount)
	spawned_scroll.base_icon_state = attached_quest.get_scroll_icon()

	if(SStreasury.bank_accounts[user] < attached_quest.deposit_amount)
		to_chat(user, span_warning("Insufficient balance funds. You need [attached_quest.deposit_amount] amna in your meister."))
		attached_quest.quest_scroll = null
		attached_quest.quest_scroll_ref = null
		attached_quest.deposit_amount = 0
		spawned_scroll.assigned_quest = null
		qdel(spawned_scroll)
		qdel(attached_quest)
		return

	user.put_in_hands(spawned_scroll)
	log_quest(user.ckey, user.mind, user, "Take [attached_quest.quest_type]")

	// Update scroll text
	spawned_scroll.update_quest_text()

	// Charge deposit
	SStreasury.bank_accounts[user] -= attached_quest.deposit_amount
	SStreasury.treasury_value += attached_quest.deposit_amount
	SStreasury.log_entries += "+[attached_quest.deposit_amount] to treasury (quest deposit)"

/obj/structure/fake_machine/contractledger/proc/find_quest_landmark(contract_tier, contract_type)
	var/list/exact_landmarks = list()
	var/list/closest_landmarks = list()
	var/best_gap = INFINITY
	GLOB.quest_landmarks_list = shuffle(GLOB.quest_landmarks_list)
	for(var/obj/effect/landmark/quest_spawner/landmark in GLOB.quest_landmarks_list)
		if(!landmark.supports_contract_type(contract_type))
			continue

		var/has_clients_around = FALSE
		for(var/mob/M in get_hearers_in_view(world.view, landmark))
			if(!M.client)
				continue

			has_clients_around = TRUE

		if(has_clients_around)
			continue

		if(landmark.supports_contract_tier(contract_tier))
			exact_landmarks += landmark
			continue

		var/tier_gap = landmark.get_tier_gap(contract_tier)
		if(tier_gap < best_gap)
			best_gap = tier_gap
			closest_landmarks = list(landmark)
		else if(tier_gap == best_gap)
			closest_landmarks += landmark

	if(length(exact_landmarks))
		return pick(exact_landmarks)

	if(length(closest_landmarks))
		return pick(closest_landmarks)

	return null

/obj/structure/fake_machine/contractledger/proc/turn_in_contract(mob/user, obj/item/paper/scroll/quest/scroll_in_hand)
	if(scroll_in_hand)
		var/list/mob/quest_assignees = scroll_in_hand.get_quest_assignees(user, TRUE)
		if(!(user in quest_assignees))
			to_chat(user, span_warning("You are not the assigned quest receiver for this contract!"))
			return
		turn_in_scroll(user, scroll_in_hand)
	else
		for(var/obj/item/paper/scroll/quest/floor_scroll in input_point)
			var/list/mob/quest_assignees = floor_scroll.get_quest_assignees(user, TRUE)
			if(!(user in quest_assignees))
				continue
			turn_in_scroll(user, floor_scroll)


/obj/structure/fake_machine/contractledger/proc/turn_in_scroll(mob/user, obj/item/paper/scroll/quest/scroll)
	var/reward = 0
	var/original_reward = 0
	var/total_deposit_return = 0
	var/tax_rate = SStreasury.tax_value
	var/tax_amt = 0

	if(scroll.assigned_quest?.complete)
		// Calculate base reward
		var/base_reward = scroll.assigned_quest.reward_amount
		original_reward += base_reward

		// Calculate deposit return
		var/deposit_return = scroll.assigned_quest.deposit_amount || scroll.assigned_quest.calculate_deposit(scroll.assigned_quest.reward_amount)
		total_deposit_return += deposit_return

		// Apply Steward/Mechant bonus if applicable (only to the base reward)
		if(is_quest_handler(user))
			reward += base_reward * QUEST_HANDLER_REWARD_MULTIPLIER
		else
			reward += base_reward

		// Add deposit return to both reward totals
		reward += deposit_return
		original_reward += deposit_return

		qdel(scroll.assigned_quest)
		qdel(scroll)

		// Tax payment
		tax_amt = round(tax_rate * reward)
		if(tax_amt > 0)
			reward -= tax_amt
			SStreasury.give_money_treasury(tax_amt, "quest completion tax - [src.name]")
			record_featured_stat(FEATURED_STATS_TAX_PAYERS, user, tax_amt)
			record_round_statistic(STATS_TAXES_COLLECTED, tax_amt)

	cash_in(user, round(reward), original_reward, tax_amt)

/obj/structure/fake_machine/contractledger/proc/cash_in(mob/user, reward, original_reward, tax_amt)
	add_mammons_to_atom(user, reward)

	if(reward > 0)
		say(reward > original_reward ? \
			"Your handler assistance-increased reward of [reward] amna has been dispensed! The difference is [reward - original_reward] amna. ([tax_amt] amna taxed.)" : \
			"Your reward of [reward] amna has been dispensed. ([tax_amt] amna taxed.)")

/obj/structure/fake_machine/contractledger/proc/abandon_contract(mob/user)
	var/obj/item/paper/scroll/quest/abandoned_scroll = locate() in input_point
	if(!abandoned_scroll)
		to_chat(user, span_warning("No contract scroll found in the input area!"))
		return

	var/datum/quest/quest = abandoned_scroll.assigned_quest
	if(!quest)
		to_chat(user, span_warning("This scroll doesn't have an assigned contract!"))
		return

	if(quest.complete)
		turn_in_contract(user)
		return

	var/refund = quest.deposit_amount || quest.calculate_deposit(quest.reward_amount)

	// First try to return to quest giver
	var/mob/giver = quest.quest_giver_reference?.resolve()
	if(giver && (giver in SStreasury.bank_accounts))
		SStreasury.bank_accounts[giver] += refund
		SStreasury.treasury_value -= refund
		SStreasury.log_entries += "-[refund] from treasury (contract refund to handler)"
		to_chat(user, span_notice("The deposit has been returned to the contract giver."))
	// Otherwise try quest receiver
	else if(quest.quest_receiver_reference)
		var/mob/receiver = quest.quest_receiver_reference.resolve()
		if(receiver && (receiver in SStreasury.bank_accounts))
			SStreasury.bank_accounts[receiver] += refund
			SStreasury.treasury_value -= refund
			SStreasury.log_entries += "-[refund] from treasury (contract refund to volunteer)"
			to_chat(user, span_notice("You receive a [refund] amna refund for abandoning the contract."))
		else
			cash_in(user, refund, refund, 0)
			SStreasury.treasury_value -= refund
			SStreasury.log_entries += "-[refund] from treasury (contract refund)"
			to_chat(user, span_notice("Your refund of [refund] amna has been dispensed."))

	log_quest(user.ckey, user.mind, user, "Abandon [abandoned_scroll.assigned_quest.quest_type]")
	abandoned_scroll.assigned_quest = null
	qdel(quest)
	qdel(abandoned_scroll)

/obj/structure/fake_machine/contractledger/proc/print_contracts(mob/user)
	var/list/active_quests = list()
	for(var/obj/item/paper/scroll/quest/quest_scroll in GLOB.quest_scrolls)
		if(quest_scroll.assigned_quest && !quest_scroll.assigned_quest.complete)
			active_quests += quest_scroll

	if(!length(active_quests))
		say("No active contracts found.")
		return

	var/obj/item/paper/scroll/report = new(get_turf(src))
	report.name = "Guild Contract Report"
	report.desc = "A list of currently active contracts issued by the Mercenary's Guild."

	var/report_text = "<center><b>MERCENARY'S GUILD - ACTIVE CONTRACTS</b></center><br><br>"
	report_text += "<i>Generated on [station_time_timestamp()]</i><br><br>"

	for(var/obj/item/paper/scroll/quest/quest_scroll in active_quests)
		var/datum/quest/quest = quest_scroll.assigned_quest
		var/area/quest_area = get_area(quest_scroll)
		report_text += "<b>Title:</b> [quest.title].<br>"
		report_text += "<b>Issuer:</b> [quest.quest_giver_name ? quest.quest_giver_name : "Mercenary's Guild"].<br>"
		report_text += "<b>Recipient:</b> [quest.quest_receiver_name ? quest.quest_receiver_name : "Unclaimed"].<br>"
		report_text += "<b>Group:</b> [quest.contract_group].<br>"
		report_text += "<b>Type:</b> [quest.quest_type].<br>"
		report_text += "<b>Threat:</b> [quest.get_tier_label()].<br>"
		report_text += "<b>Last Known Location:</b> [quest_area ? quest_area.name : "Unknown Location"].<br>"
		report_text += "<b>Reward:</b> [quest.reward_amount] amna.<br><br>"

	report.info = report_text
	say("Contract report printed.")
