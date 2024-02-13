#define SYNTH_CHARGE_MAX 150
#define SYNTH_CHARGE_MIN 50
#define SYNTH_CHARGE_PER_NUTRITION 10
#define SYNTH_CHARGE_DELAY_PER_100 10
#define SYNTH_DRAW_NUTRITION_BUFFER 30
#define SYNTH_APC_MINIMUM_PERCENT 20

/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord. Useful if you run on elecricity. Not so much otherwise."
	contents = newlist(/obj/item/apc_powercord)
	zone = "l_arm"
	cannot_confiscate = TRUE

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wire1"
	///Object basetypes which the powercord is allowed to connect to.
	var/static/list/charge_whitelist = typecacheof(list(
		/obj/item/stock_parts/cell,
		/obj/machinery/power/apc,
	))

///Attempt to charge from an object by using them on the powercord.
/obj/item/apc_powercord/attackby(obj/item/attacking_item, mob/user, params)
	if(!can_power_draw(attacking_item, user))
		return ..()
	try_power_draw(attacking_item, user)

///Attempt to charge from an object by using the powercord on them.
/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !can_power_draw(target, user))
		return ..()
	try_power_draw(target, user)

///Returns TRUE or FALSE depending on if the target object can be used as a power source.
/obj/item/apc_powercord/proc/can_power_draw(obj/target, mob/user)
	return ishuman(user) && is_type_in_typecache(target, charge_whitelist)

///Attempts to start using an object as a power source.
///Checks the user's internal powercell to see if it exists.
/obj/item/apc_powercord/proc/try_power_draw(obj/target, mob/living/carbon/human/user)
	user.changeNext_move(CLICK_CD_MELEE)

	var/obj/item/organ/internal/stomach/synth/synth_cell = user.organs_slot[ORGAN_SLOT_STOMACH]
	if(QDELETED(synth_cell) || !istype(synth_cell))
		to_chat(user, span_warning("You plug into [target], but nothing happens! It seems you don't have an internal cell to charge."))
		return

	if(user.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		to_chat(user, span_warning("You are already fully charged!"))
		return

	user.visible_message(span_notice("[user] inserts a power connector into [target]."), span_notice("You begin to draw power from [target]."))
	do_power_draw(target, user)

	if(QDELETED(target))
		return

	user.visible_message(span_notice("[user] unplugs from [target]."), span_notice("You unplug from [target]."))

/**
 * Runs a loop to charge a synth cell (stomach) from a power cell or APC.
 * Displays chat messages to the user and nearby observers.
 *
 * Stops when:
 * - The user's internal cell is full.
 * - The cell has less than the minimum charge.
 * - The user moves, or anything else that can happen to interrupt a do_after.
 *
 * Arguments:
 * * target - The power cell or APC to drain.
 * * user - The human mob draining the power cell.
 */
/obj/item/apc_powercord/proc/do_power_draw(obj/target, mob/living/carbon/human/user)
	// Draw power from an APC if one was given.
	var/obj/machinery/power/apc/target_apc
	if(istype(target, /obj/machinery/power/apc))
		target_apc = target

	var/obj/item/stock_parts/cell/target_cell = target_apc ? target_apc.cell : target
	var/minimum_cell_charge = target_apc ? SYNTH_APC_MINIMUM_PERCENT : 0

	if(!target_cell || target_cell.percent() < minimum_cell_charge)
		to_chat(user, span_warning("[target] has no charge to draw from."))
		return

	var/power_needed
	var/power_use
	while(TRUE)
		// Check if the user is "fully charged" yet.
		// Ensures minimum draw is always lower than this margin to prevent wasteful loops.
		power_needed = NUTRITION_LEVEL_ALMOST_FULL - user.nutrition
		if(power_needed <= SYNTH_CHARGE_MIN * 2)
			to_chat(user, span_notice("You are fully charged."))
			break

		// Check if the charge level of the cell is below the minimum.
		// Prevents synths from overloading the cell.
		if(target_cell.percent() < minimum_cell_charge)
			to_chat(user, span_warning("[target] lacks the power to charge you."))
			break

		// Calculate how much to draw from the cell this cycle.
		power_use = clamp(power_needed, SYNTH_CHARGE_MIN, SYNTH_CHARGE_MAX)
		power_use = clamp(power_use, 0, target_cell.charge)
		if(power_use <= 0)
			to_chat(user, span_warning("[target] lacks the power to charge you."))
			break

		// Attempt to drain charge from the cell.
		if(!do_after(user, (power_use / 100) * SYNTH_CHARGE_DELAY_PER_100, target))
			break

		if(!target_cell.use(power_use))
			// The cell could be sabotaged, which causes it to explode and qdelete.
			if(QDELETED(target_cell))
				return
			to_chat(user, span_warning("[target] lacks the power to charge you."))
			break

		// If charging was successful, then increase user nutrition and emit sparks.
		user.nutrition += power_use / SYNTH_CHARGE_PER_NUTRITION
		do_sparks(1, FALSE, target_cell.loc)

	// Start APC recharging if power was used and the APC has power available.
	if(target_apc && !QDELETED(target_apc) && !QDELETED(target_apc.cell) && target_apc.main_status > APC_NO_POWER)
		target_apc.charging = APC_CHARGING
		target_apc.update_appearance()

#undef SYNTH_CHARGE_MAX
#undef SYNTH_CHARGE_MIN
#undef SYNTH_CHARGE_PER_NUTRITION
#undef SYNTH_CHARGE_DELAY_PER_100
