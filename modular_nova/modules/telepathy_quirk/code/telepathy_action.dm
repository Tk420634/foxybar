/datum/mutation/human/telepathy
	power_path = /datum/action/cooldown/spell/pointed/telepathy

/datum/action/cooldown/spell/pointed/telepathy
	name = "Telepathic Communication"
	desc = "<b>Left click</b>: point target to project a thought to them. <b>Right click</b>: project to your last thought target, if in range."
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND
	cooldown_time = 1 SECONDS
	cast_range = 7
	/// What's the last mob we point-targeted with this ability?
	var/datum/weakref/last_target_ref
	/// The message we send
	var/message
	/// Are we blocking casts?
	var/blocked = FALSE

/datum/action/cooldown/spell/pointed/telepathy/is_valid_target(atom/cast_on)
	. = ..()
	if (!.)
		return FALSE

	if (!isliving(cast_on))
		to_chat(owner, span_warning("Inanimate objects can't hear your thoughts."))
		owner.balloon_alert(owner, "not a thing with thoughts!")
		return FALSE

	var/mob/living/living_target = cast_on
	if (living_target.stat == DEAD)
		to_chat(owner, span_warning("The disruptive noise of departed resonance inhibits your ability to communicate with the dead."))
		owner.balloon_alert(owner, "can't transmit to the dead!")
		return FALSE

	if (get_dist(living_target, owner) > cast_range)
		owner.balloon_alert(owner, "too far away!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/telepathy/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST || blocked)
		return

	message = autopunct_bare(tgui_input_text(owner, "What do you wish to whisper to [cast_on]?", "[src]"))
	if(QDELETED(src) || QDELETED(owner) || QDELETED(cast_on) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST

	if(get_dist(cast_on, owner) > cast_range)
		owner.balloon_alert(owner, "they're too far!")
		return . | SPELL_CANCEL_CAST

	if(!message)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/telepathy/Trigger(trigger_flags, atom/target)
	var/mob/living/last_target = last_target_ref?.resolve()
	if(isnull(last_target))
		last_target_ref = null
		owner.balloon_alert(owner, "last target is not available!")
		return
	else if(get_dist(last_target, owner) > cast_range)
		owner.balloon_alert(owner, "[last_target] is too far away!")
		return

	if (trigger_flags & TRIGGER_SECONDARY_ACTION)
		blocked = TRUE
		message = autopunct_bare(tgui_input_text(owner, "What do you wish to whisper to [last_target]?", "[src]"))
		if(QDELETED(src) || QDELETED(owner) || QDELETED(last_target) || !can_cast_spell())
			blocked = FALSE
			return blocked
		send_thought(owner, last_target, message)
		src.StartCooldown()
		blocked = FALSE
		return

	. = ..()

/datum/action/cooldown/spell/pointed/telepathy/cast(mob/living/cast_on)
	. = ..()
	send_thought(owner, cast_on, message)

/datum/action/cooldown/spell/pointed/telepathy/proc/send_thought(mob/living/caster, mob/living/target, message)
	log_directed_talk(caster, target, message, LOG_SAY, name)

	last_target_ref = WEAKREF(target)

	to_chat(owner, span_boldnotice("You reach out and convey to [target]: \"[span_purple(message)]\""))
	// flub a runechat chat message, do something with the language later
	owner.create_chat_message(owner, owner.get_selected_language(), message, list("italics"))
	if(!target.can_block_magic(antimagic_flags, charge_cost = 0) && target.client) //make sure we've got a client before we bother sending anything
		to_chat(target, span_boldnotice("A voice echoes in your head: \"[span_purple(message)]\""))
		target.create_chat_message(target, target.get_selected_language(), message, list("italics")) // it appears over them since they hear it in their head
	else
		owner.balloon_alert(owner, "something blocks your thoughts!")
		to_chat(owner, span_warning("Your mind encounters impassable resistance: the thought was blocked!"))
		return

	// send to ghosts as well i guess
	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = span_boldnotice("[owner] [src]")
		from_mob_name += span_boldnotice(":")
		var/to_link = FOLLOW_LINK(ghost, target)
		var/to_mob_name = span_name("[target]")

		to_chat(ghost, "[from_link] [from_mob_name] [message] [to_link] [to_mob_name]")
