GLOBAL_DATUM(character_directory, /datum/character_directory)
GLOBAL_LIST_EMPTY(name_to_appearance)
#define READ_PREFS(target, pref) (target.client.prefs.read_preference(/datum/preference/pref) || "Unset")

//We want players to be able to decide whether they show up in the directory or not
/datum/preference/toggle/show_in_directory
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "show_in_directory"
	savefile_identifier = PREFERENCE_PLAYER

//The advertisement that you show to people looking through the directory
/datum/preference/text/character_ad
	savefile_key = "character_ad"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	maximum_value_length = MAX_FLAVOR_LEN

//TGUI gets angry if you don't define a default on text preferences
/datum/preference/text/character_ad/create_default_value()
	return ""

//Any text preference needs this for some reason
/datum/preference/text/character_ad/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/choiced/attraction
	savefile_key = "attraction"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/attraction/init_possible_values()
	return list("Androsexual", "Gynosexual", "Bisexual", "Skoliosexual", "Pansexual", "Demisexual", "Asexual", "Aromantic", "Unset", "Check OOC")

/datum/preference/choiced/attraction/create_default_value()
	return "Unset"

/datum/preference/choiced/attraction/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/choiced/display_gender
	savefile_key = "display_gender"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/display_gender/init_possible_values()
	return list("Masculine", "Feminine", "Nonbinary", "Intersex", "Plural", "Genderfluid", "Unset", "Check OOC")

/datum/preference/choiced/display_gender/create_default_value()
	return "Unset"

/datum/preference/choiced/display_gender/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
//Can't believe Bubberstation invented attraction and gender in the year December 2023

//Add a cooldown for the character directory to the client, primarily to stop server lag from refresh spam
/client
	COOLDOWN_DECLARE(char_directory_cooldown)

//Make a verb to open the character directory
/client/verb/show_character_directory()
	set name = "Character Directory"
	set category = "OOC"
	set desc = "Shows a listing of all active characters, along with their associated OOC notes, flavor text, and more."

	// This is primarily to stop malicious users from trying to lag the server by spamming this verb
	if(!COOLDOWN_FINISHED(src, char_directory_cooldown))
		to_chat(src, span_alert("Hold your horses! Its still refreshing!"))
		return
	COOLDOWN_START(src, char_directory_cooldown, 10)

//Check if there's not already a character directory open; open a new one if one is not present
	if(!GLOB.character_directory)
		GLOB.character_directory = new
	GLOB.character_directory.ui_interact(mob)

// This is a global singleton. Keep in mind that all operations should occur on user, not src.
/datum/character_directory
	/// The character preview views for the UI.
	var/list/atom/movable/screen/map_view/char_preview/character_preview_views = list()

/datum/character_directory/Destroy(force)
	QDEL_LIST(character_preview_views)
	return ..()

/datum/character_directory/proc/create_character_preview_view(mob/user)
	var/assigned_view = "preview_[user.ckey]_[REF(src)]_directory"
	if(user.client?.screen_maps[assigned_view])
		return

	var/atom/movable/screen/map_view/char_preview/new_view = new(null, src)
	new_view.generate_view(assigned_view)
	new_view.display_to(user)

/// Takes a record and updates the character preview view to match it.
/datum/character_directory/proc/update_preview(mob/user, assigned_view, mutable_appearance/appearance)
	var/mutable_appearance/preview = new(appearance)

	preview.underlays += mutable_appearance('icons/effects/effects.dmi', "static_base", alpha = 20)
	preview.add_overlay(mutable_appearance(generate_icon_alpha_mask('icons/effects/effects.dmi', "scanline"), alpha = 20))

	var/atom/movable/screen/map_view/char_preview/old_view = user.client?.screen_maps[assigned_view]?[1]
	if(!old_view)
		return

	old_view.appearance = preview.appearance

/datum/character_directory/ui_state(mob/user)
	return GLOB.always_state

/datum/character_directory/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_views[ref(user)] = create_character_preview_view(user)
		ui = new(user, src, "NovaCharacterDirectory", "Character Directory")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/character_directory/ui_close(mob/user)
	character_preview_views -= ref(user)

//We want this information to update any time the player updates their preferences, not just when the panel is refreshed
/datum/character_directory/ui_data(mob/user)
	. = ..()
	var/list/data = .

//Collect the user's own preferences for the top of the UI
	if (user?.client?.prefs)
		data["personalVisibility"] = READ_PREFS(user, toggle/show_in_directory)
		data["personalAttraction"] = READ_PREFS(user, choiced/attraction)
		data["personalGender"] = READ_PREFS(user, choiced/display_gender)
		data["personalErpTag"] = READ_PREFS(user, choiced/erp_status)
		data["personalVoreTag"] = READ_PREFS(user, choiced/erp_status_v)
		data["personalNonconTag"] = READ_PREFS(user, choiced/erp_status_nc)
		data["prefsOnly"] = TRUE

	data["assigned_view"] = "preview_[user.ckey]_[REF(src)]_directory"
	data["canOrbit"] = isobserver(user)

	return data

/datum/character_directory/ui_static_data(mob/user)
	. = ..()
	var/list/data = .

	var/list/directory_mobs = list()
	for(var/datum/record/crew/record in GLOB.manifest.locked)
		GLOB.name_to_appearance[record.name] = record.character_appearance

	//We want the directory to display only alive players, not observers or people in the lobby
	for(var/mob/mob in GLOB.alive_player_list)
		// These are the variables we're trying to display in the directory
		var/name = ""
		var/mutable_appearance/appearance
		var/species = "Ask"
		var/ooc_notes = ""
		var/flavor_text = ""
		var/attraction = "Unset"
		var/gender = "Unset"
		var/erp = "Ask"
		var/vore = "Ask"
		var/noncon = "Ask"
		var/character_ad = ""
		var/exploitable = ""
		var/ref = REF(mob)
		//Just in case something we get is not a mob
		if(!mob)
			continue

		//Different approach for humans and silicons
		if(ishuman(mob))
			var/mob/living/carbon/human/human = mob
			//If someone is obscured without flavor text visible, we don't want them on the Directory.
			if((human.wear_mask && (human.wear_mask.flags_inv & HIDEFACE) && READ_PREFS(human, toggle/obscurity_examine)) || (human.head && (human.head.flags_inv & HIDEFACE) && READ_PREFS(human, toggle/obscurity_examine)) || (HAS_TRAIT(human, TRAIT_UNKNOWN)))
				continue
			//Display custom species, otherwise show base species instead
			species = (READ_PREFS(human, text/custom_species))
			if(species == "Unset")
				species = "[human.dna.species.name]"
			//Load standard flavor text preference
			flavor_text = READ_PREFS(human, text/flavor_text)
		else if(issilicon(mob))
			var/mob/living/silicon/silicon = mob
			//If the target is a silicon, we want it to show its brain as its species
			species = READ_PREFS(silicon, choiced/brain_type)
			//Load silicon flavor text in place of normal flavor text
			flavor_text = READ_PREFS(silicon, text/silicon_flavor_text)
		//Don't show if they are not a human or a silicon
		else continue
		//List of all the shown ERP preferences in the Directory. If there is none, return "Unset"
		attraction = READ_PREFS(mob, choiced/attraction)
		gender = READ_PREFS(mob, choiced/display_gender)
		erp = READ_PREFS(mob, choiced/erp_status)
		vore = READ_PREFS(mob, choiced/erp_status_v)
		noncon = READ_PREFS(mob, choiced/erp_status_nc)
		character_ad = READ_PREFS(mob, text/character_ad)
		ooc_notes = READ_PREFS(mob, text/ooc_notes)
		appearance = GLOB.name_to_appearance[mob.real_name]
		//If the user is an antagonist or Observer, we want them to be able to see exploitables in the Directory.
		if(user.mind?.has_antag_datum(/datum/antagonist) || isobserver(user))
			if(exploitable == EXPLOITABLE_DEFAULT_TEXT)
				exploitable = "Unset"
			else exploitable = READ_PREFS(mob, text/exploitable)
		else exploitable = "Obscured"
		//And finally, we want to get the mob's name, taking into account disguised names.
		name = mob.real_name ? mob.name : mob.real_name

		directory_mobs.Add(list(list(
			"name" = name,
			"appearance" = appearance,
			"species" = species,
			"ooc_notes" = ooc_notes,
			"attraction" = attraction,
			"gender" = gender,
			"erp" = erp,
			"vore" = vore,
			"noncon" = noncon,
			"exploitable" = exploitable,
			"character_ad" = character_ad,
			"flavor_text" = flavor_text,
			"ref" = ref
		)))

	data["directory"] = directory_mobs

	return data

/datum/character_directory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	var/mob/user = usr
	if(!user)
		return

	switch(action)
		if("refresh")
			// This is primarily to stop malicious users from trying to lag the server by spamming this verb
			if(!COOLDOWN_FINISHED(user.client, char_directory_cooldown))
				to_chat(user, "<span class='warning'>Please wait before refreshing the directory again.</span>")
				return
			COOLDOWN_START(user.client, char_directory_cooldown, 10)
			update_static_data(user, ui)
			return TRUE
		if("orbit")
			var/ref = params["ref"]
			var/mob/dead/observer/ghost = user
			var/atom/movable/poi = (locate(ref) in GLOB.mob_list)
			if (poi == null)
				return TRUE
			ghost.ManualFollow(poi)
			ghost.reset_perspective(null)
			return TRUE
		if("view_character")
			update_preview(usr, params["assigned_view"], params["appearance"])
			return TRUE
