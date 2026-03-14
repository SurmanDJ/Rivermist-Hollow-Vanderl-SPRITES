GLOBAL_LIST_EMPTY(active_quest_compasses)
GLOBAL_LIST_EMPTY(claimed_quest_compass_users)

/obj/structure/fake_machine/contractledger
	name = "Grand Contract Ledger"
	desc = "A massive ledger book with gilded edges, sitting atop a pedestal with the Mercenary's Guild banner."
	icon = 'icons/obj/questing.dmi'
	icon_state = "contractledger"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
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



/obj/structure/fake_machine/contractledger/Topic(href, href_list)
	. = ..()

	if(href_list["consultcontracts"])
		consult_contracts(usr)
		return attack_hand(usr)

	if(href_list["getcompass"])
		issue_quest_compass(usr)
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

	var/contents = "<center><h2>Grand Contract Ledger</h2>"

	contents += "<a href='?src=[REF(src)];consultcontracts=1'>Consult Contracts</a><br>"
	contents += "<a href='?src=[REF(src)];getcompass=1'>Claim Quest Compass</a><br>"
	contents += "<a href='?src=[REF(src)];turnincontract=1'>Turn in Contract</a><br>"
	contents += "<a href='?src=[REF(src)];abandoncontract=1'>Abandon Contract</a><br>"

	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null

	if(mob_job?.is_quest_giver)
		contents += "<a href='?src=[REF(src)];printcontracts=1'>Print Issued Contracts</a><br>"

	contents += "</center>"

	var/datum/browser/popup = new(user, "Grand Contract Ledger", "", 500, 300)
	popup.set_content(contents)
	popup.open()



/obj/structure/fake_machine/contractledger/proc/consult_contracts(mob/user)

	if(!(user in SStreasury.bank_accounts))
		say("You have no bank account.")
		return


	var/list/tier_data = list(
		QUEST_TIER_ROUTINE = 4,
		QUEST_TIER_RISKY = 10,
		QUEST_TIER_DANGEROUS = 18,
		QUEST_TIER_DEADLY = 30,
		QUEST_TIER_LETHAL = 50,
		QUEST_TIER_MYTHIC = 80
	)


	var/list/tier_names = list(
		QUEST_TIER_ROUTINE = "Routine",
		QUEST_TIER_RISKY = "Risky",
		QUEST_TIER_DANGEROUS = "Dangerous",
		QUEST_TIER_DEADLY = "Deadly",
		QUEST_TIER_LETHAL = "Lethal",
		QUEST_TIER_MYTHIC = "Mythic"
	)


	var/list/difficulty_choices = list()

	for(var/tier in tier_data)

		var/deposit = tier_data[tier]

		difficulty_choices["[tier_names[tier]] ([deposit] mammon deposit)"] = tier


	var/selection = tgui_input_list(user, "Select contract difficulty", "CONTRACTS", difficulty_choices)

	if(!selection)
		return


	var/actual_tier = difficulty_choices[selection]
	var/deposit = tier_data[actual_tier]


	if(SStreasury.bank_accounts[user] < deposit)
		say("Insufficient balance funds.")
		return


	var/type_choices = GLOB.global_quest_types

	var/type_selection = tgui_input_list(user, "Select contract type", "CONTRACTS", type_choices[actual_tier])

	if(!type_selection)
		return


	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null


	if(!mob_job?.is_quest_giver)

		var/quest_number = 0

		for(var/obj/item/paper/scroll/quest/quest_scroll in GLOB.quest_scrolls)

			var/datum/weakref/weakref_datum = WEAKREF(user)

			if(quest_scroll.assigned_quest && !quest_scroll.assigned_quest.complete && quest_scroll.assigned_quest.quest_receiver_reference == weakref_datum)
				quest_number++

		var/max_quests_for_job = mob_job?.max_active_quests || 3

		if(quest_number >= max_quests_for_job)
			say("You have reached the maximum number of active quests.")
			return



	var/datum/quest/attached_quest


	switch(type_selection)

		if(QUEST_RETRIEVAL)
			attached_quest = new /datum/quest/retrieval()

		if(QUEST_COURIER)
			attached_quest = new /datum/quest/courier()

		if(QUEST_HUNT)
			attached_quest = new /datum/quest/kill()

		if(QUEST_CLEAR_OUT)
			attached_quest = new /datum/quest/kill/clearout()

		if(QUEST_RAID)
			attached_quest = new /datum/quest/kill/raid()

		if(QUEST_BOSS)
			attached_quest = new /datum/quest/kill/boss()



	if(!attached_quest)
		return



	attached_quest.quest_tier = actual_tier
	attached_quest.deposit_amount = attached_quest.calculate_deposit()



	if(mob_job?.is_quest_giver)

		attached_quest.quest_giver_name = user.real_name
		attached_quest.quest_giver_reference = WEAKREF(user)

	else

		attached_quest.quest_receiver_reference = WEAKREF(user)
		attached_quest.quest_receiver_name = user.real_name



	var/obj/effect/landmark/quest_spawner/chosen_landmark = find_quest_landmark(actual_tier, type_selection)

	if(!chosen_landmark)
		qdel(attached_quest)
		return



	if(!attached_quest.generate(chosen_landmark))
		qdel(attached_quest)
		return



	var/obj/item/paper/scroll/quest/spawned_scroll = new(get_turf(src))

	user.put_in_hands(spawned_scroll)

	log_quest(user.ckey, user.mind, user, "Take [attached_quest.quest_type]")


	spawned_scroll.base_icon_state = attached_quest.get_scroll_icon()
	spawned_scroll.assigned_quest = attached_quest


	attached_quest.quest_scroll = spawned_scroll
	attached_quest.quest_scroll_ref = WEAKREF(spawned_scroll)


	attached_quest.reward_amount = attached_quest.calculate_reward(get_turf(chosen_landmark))


	spawned_scroll.update_quest_text()


	SStreasury.bank_accounts[user] -= deposit
	SStreasury.treasury_value += deposit
	SStreasury.log_entries += "+[deposit] to treasury (quest deposit)"



/obj/structure/fake_machine/contractledger/proc/find_quest_landmark(tier, type)

	var/list/correctest_landmarks = list()

	GLOB.quest_landmarks_list = shuffle(GLOB.quest_landmarks_list)


	for(var/obj/effect/landmark/quest_spawner/landmark in GLOB.quest_landmarks_list)

		if(landmark.quest_tier != tier || !(type in landmark.quest_type))
			continue

		correctest_landmarks += landmark


	if(length(correctest_landmarks))
		return pick(correctest_landmarks)


	return null