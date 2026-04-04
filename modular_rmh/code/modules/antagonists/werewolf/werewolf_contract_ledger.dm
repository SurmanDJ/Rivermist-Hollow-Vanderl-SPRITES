/obj/structure/fake_machine/contractledger/antag
	name = "black contract ledger"
	desc = "A hidden ledger whose ink writhes when ordinary eyes try to follow it. Only those already marked as villains can make sense of its pages."
	contract_ledger_id = "antag_contracts"

/obj/structure/fake_machine/contractledger/antag/proc/get_access_antag_datum(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.mind?.has_antag_datum(/datum/antagonist)

/obj/structure/fake_machine/contractledger/antag/can_user_access_ledger(mob/living/carbon/human/user, show_feedback = FALSE)
	if(!..())
		return FALSE

	if(get_access_antag_datum(user))
		return TRUE

	if(show_feedback)
		to_chat(user, span_warning(get_access_denial_message(user)))
	return FALSE

/obj/structure/fake_machine/contractledger/antag/get_access_denial_message(mob/living/carbon/human/user)
	return "The hidden script recoils from me. This ledger is for antagonists alone."

/obj/structure/fake_machine/contractledger/antag/get_role_label(mob/user)
	var/datum/antagonist/antag_datum = get_access_antag_datum(user)
	if(antag_datum)
		return antag_datum.name
	return "Antagonist"

/obj/structure/fake_machine/contractledger/antag/get_ledger_window_title(mob/user)
	return "Black Contract Ledger"

/obj/structure/fake_machine/contractledger/antag/get_default_contract_issuer_name(mob/living/carbon/human/user)
	return "The Black Ledger"

/obj/structure/fake_machine/contractledger/antag/should_show_handler_contract_advice()
	return FALSE

/obj/structure/fake_machine/contractledger/antag/requires_bank_account_for_contracts(mob/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/get_contract_deposit_amount(mob/living/carbon/human/user, datum/quest/attached_quest)
	return 0

/obj/structure/fake_machine/contractledger/antag/is_quest_handler(mob/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/is_contract_type_allowed_for_user(mob/user, contract_type)
	return TRUE

/obj/structure/fake_machine/contractledger/antag/get_contract_group_catalog(mob/user)
	var/static/list/antag_contract_groups = list(
		QUEST_GROUP_BOUNTIES = list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOSS),
	)
	return antag_contract_groups

/obj/structure/fake_machine/contractledger/antag/werewolf
	name = "moon hunt ledger"
	desc = "A thick ledger bound in scarred hide, its pages inked with claw-marks, spoor, and blood. The script only steadies for a true child of the moon."
	contract_ledger_id = "werewolf_contracts"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_access_antag_datum(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.mind?.has_antag_datum(/datum/antagonist/werewolf)

/obj/structure/fake_machine/contractledger/antag/werewolf/get_access_denial_message(mob/living/carbon/human/user)
	return "The moon hunt ledger will only open its pages to werewolves."

/obj/structure/fake_machine/contractledger/antag/werewolf/get_ledger_window_title(mob/user)
	return "Moon Hunt Ledger"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_default_contract_issuer_name(mob/living/carbon/human/user)
	return "The Moon Hunt"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_contract_group_catalog(mob/user)
	var/static/list/werewolf_contract_groups = list(
		QUEST_GROUP_BOUNTIES = list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID),
	)
	return werewolf_contract_groups

/obj/structure/fake_machine/contractledger/antag/werewolf/get_contract_objective_score(datum/quest/quest)
	var/effective_tier = quest?.threat_tier || quest?.requested_tier || QUEST_TIER_ROUTINE
	effective_tier = clamp(effective_tier, QUEST_TIER_ROUTINE, QUEST_TIER_MYTHIC)
	return WW_CONTRACT_SCORE_BASE + ((effective_tier - QUEST_TIER_ROUTINE) * WW_CONTRACT_SCORE_STEP)

/obj/structure/fake_machine/contractledger/antag/werewolf/on_contract_completed(mob/living/carbon/human/user, datum/quest/completed_quest, reward, original_reward, tax_amt)
	var/objective_score = completed_quest?.objective_score_reward || get_contract_objective_score(completed_quest)
	if(objective_score <= 0)
		return

	var/datum/antagonist/werewolf/werewolf_antag = user?.mind?.has_antag_datum(/datum/antagonist/werewolf)
	if(!werewolf_antag)
		return

	werewolf_antag.add_contract_objective_score(objective_score)
