// --- Questing Core Definitions (MUST BE FIRST) ---
#include "questing_def.dm"

// --- Core Systems ---
#include "questing_helpers.dm"
#include "contract_ledger.dm"
#include "questing_components.dm"
#include "questing_decals.dm"
#include "questing_landmarks.dm"

// --- Items ---
//#include "items\parcel.dm"
#include "items\quest_scroll.dm"
#include "items\spawn_effect.dm"

// --- Base Types ---
#include "types\__quest.dm"
#include "types\__quest_list.dm"
//#include "types\quest_courier.dm" - custom locatiom, works in the future
//#include "types\quest_retrieval.dm" - fix for now (1)

// --- Kill Quests ---
#include "types\kill\__quest_kill_base.dm"
#include "types\kill\quest_clearout.dm"
#include "types\kill\quest_kill_easy.dm"
#include "types\kill\quest_raid.dm"
#include "types\kill\quest_outlaw.dm"

// There is no courier/retrieval working quest for now due zones/doors