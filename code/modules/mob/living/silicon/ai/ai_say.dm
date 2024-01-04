/mob/living/silicon/ai/say(message, bubble_type,list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if(parent && istype(parent) && parent.stat != DEAD) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		return parent.say(arglist(args))
	return ..()

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	// AIs cannot speak if silent AI is on.
	// Unless forced is set, as that's probably stating laws or something.
	if(!forced && CONFIG_GET(flag/silent_ai))
		to_chat(src, span_danger("The ability for AIs to speak is currently disabled via server config."))
		return FALSE

	return ..()

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)

	if (!message)
		return

	var/obj/machinery/holopad/active_pad = current
	if(istype(active_pad) && active_pad.masters[src])//If there is a hologram and its master is the user.
		var/obj/effect/overlay/holo_pad_hologram/ai_holo = active_pad.masters[src]
		var/turf/padturf = get_turf(active_pad)
		var/padloc
		if(padturf)
			padloc = AREACOORD(padturf)
		else
			padloc = "(UNKNOWN)"
		src.log_talk(message, LOG_SAY, tag="HOLOPAD in [padloc]")
		ai_holo.say(message, language = language)
	else
		to_chat(src, span_alert("No holopad connected."))

// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 300 // NOVA EDIT - ORIGINAL: 600

// NOVA ADDITION START
/mob/living/silicon/ai
	/// The currently selected VOX Announcer voice.
	var/vox_type = VOX_BMS
	/// The list of available VOX Announcer voices to choose from.
	var/list/vox_voices = list(VOX_HL, VOX_NORMAL, VOX_BMS)
	/// The paths for the VOX words.
	var/list/vox_paths = list(VOX_HL = "vox_sounds_hl", VOX_NORMAL = "vox_sounds", VOX_BMS = "vox_sounds_bms", VOX_MIL = "vox_sounds_mil")
	/// The VOX word(s) that were previously inputed.
	var/vox_word_string
// NOVA ADDITION END

/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"

	if(incapacitated())
		return

	var/dat = {"
	<font class='bad'>WARNING:</font> Misuse of the announcement system will get you job banned.<BR><BR>
	Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR>
	<UL><LI>You can also click on the word to PREVIEW it.</LI>
	<LI>You can only say 30 words for every announcement.</LI>
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>
	<LI>Numbers are in word format, e.g. eight, sixty, etc </LI>
	<LI>Sound effects begin with an 's' before the actual word, e.g. scensor</LI>
	<LI>Use Ctrl+F to see if a word exists in the list.</LI></UL><HR>
	"}

	var/index = 0
	for(var/word in GLOB[vox_paths[vox_type]]) // NOVA EDIT - VOX types
		index++
		dat += "<A href='?src=[REF(src)];say_word=[word]'>[capitalize(word)]</A>"
		if(index != GLOB[vox_paths[vox_type]].len) // NOVA EDIT - VOX types
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/ai/proc/announcement()
	var/static/announcing_vox = 0 // Stores the time of the last announcement
	if(announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(announcing_vox - world.time)]."))
		return

	var/message = tgui_input_text(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement)

	if(!message || announcing_vox > world.time)
		return

	last_announcement = message

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB[vox_paths[vox_type]][word])
			incorrect_words += word

	if(incorrect_words.len)
		to_chat(src, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	announcing_vox = world.time + VOX_DELAY

	log_message("made a vocal announcement with the following message: [message].", LOG_GAME)
	log_talk(message, LOG_SAY, tag="VOX Announcement")

	var/list/players = list()
	var/turf/ai_turf = get_turf(src)
	for(var/mob/player_mob as anything in GLOB.player_list)
		var/turf/player_turf = get_turf(player_mob)
		if(is_valid_z_level(ai_turf, player_turf))
			players += player_mob
	minor_announce(capitalize(message), "[name] announces:", players = players, should_play_sound = FALSE)

	for(var/word in words)
		play_vox_word(word, ai_turf, null)


/proc/play_vox_word(word, ai_turf, mob/only_listener)

	word = lowertext(word)

	if(GLOB[vox_paths[vox_type]][word]) // NOVA EDIT - VOX types

		var/sound_file = GLOB[vox_paths[vox_type]][word] // NOVA EDIT - VOX types
		// NOVA ADDITION START
		var/volume = 100
		switch(vox_type)
			if(VOX_HL)
				volume = 75
			if(VOX_MIL)
				volume = 50 // My poor ears...
		// If the vox stuff are disabled, or we failed getting the word from the list, just early return.
		if(!sound_file)
			return FALSE
		// NOVA ADDITION END
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX, volume = volume) // NOVA EDIT - Volume
		voice.status = SOUND_STREAM

	// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/player_mob as anything in GLOB.player_list)
				if(!player_mob.can_hear() || !(safe_read_pref(player_mob.client, /datum/preference/toggle/sound_announcements)))
					continue

				var/turf/player_turf = get_turf(player_mob)
				if(!is_valid_z_level(ai_turf, player_turf))
					continue

				SEND_SOUND(player_mob, voice)
		else
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE

#undef VOX_DELAY
#endif
