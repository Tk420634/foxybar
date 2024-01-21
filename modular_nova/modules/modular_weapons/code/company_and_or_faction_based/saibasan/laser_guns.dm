// Modular energy weapons, laser guns that can transform into different variants after a few seconds of waiting and animation
// Long version, takes both hands to use and doesn't fit in any bags out there
/obj/item/gun/energy/modular_laser_rifle
	name = "\improper Hyeseong modular laser rifle"
	desc = "A popular energy weapon system that can be reconfigured into many different variants on the fly. \
		Seen commonly amongst Marsians, as the red planet is the birthplace of this piece of tech. \
		This large rifle version is made for the many modders on the planet who can easily handle larger weapons."
	icon = 'modular_nova/modules/modular_weapons/icons/obj/company_and_or_faction_based/saibasan/guns48x.dmi'
	icon_state = "hyeseong_switch"
	base_icon_state = "hyeseong"
	cell_type = /obj/item/stock_parts/cell/hyeseong_internal_cell
	modifystate = TRUE
	ammo_type = list()
	can_select = FALSE
	ammo_x_offset = 0
	selfcharge = 1
	charge_delay = 30
	shaded_charge = TRUE
	/// What datums of weapon modes can we use?
	var/list/weapon_mode_options = list(
		/datum/laser_weapon_mode,
		/datum/laser_weapon_mode/marksman,
		/datum/laser_weapon_mode/disabler_machinegun,
		/datum/laser_weapon_mode/launcher,
		/datum/laser_weapon_mode/shotgun,
	)
	/// Populates with a list of weapon mode names and their respective paths on init
	var/list/weapon_mode_name_to_path = list()
	/// Info for the radial menu for switching weapon mode
	var/list/radial_menu_data = list()
	/// Is the gun currently changing types? Prevents the gun from firing if yes
	var/currently_switching_types = FALSE
	/// How long transitioning takes before you're allowed to pick a weapon type
	var/transition_duration = 3 SECONDS
	/// What the currently selected weapon mode is, for quickly referencing for use in procs and whatnot
	var/datum/laser_weapon_mode/currently_selected_mode
	/// Name of the firing mode that is selected by default
	var/default_selected_mode = "Kill"

/obj/item/gun/energy/modular_laser_rifle/Initialize(mapload)
	. = ..()
	create_weapon_mode_stuff()

/// Handles filling out all of the lists regarding weapon modes and radials around that
/obj/item/gun/energy/modular_laser_rifle/proc/create_weapon_mode_stuff()
	if(length(weapon_mode_name_to_path) || length(radial_menu_data))
		return // We don't need to worry about it if there's already stuff here
	for(var/datum/laser_weapon_mode/laser_mode as anything in weapon_mode_options)
		laser_mode = new()
		weapon_mode_name_to_path[laser_mode.name] = laser_mode
		var/obj/projectile/mode_projectile = laser_mode.casing.projectile_type
		radial_menu_data[laser_mode.name] = image(icon = mode_projectile.icon, icon_state = mode_projectile.icon_state)
	currently_selected_mode = weapon_mode_name_to_path[default_selected_mode]
	transform_gun(currently_selected_mode, FALSE)

/obj/item/gun/energy/modular_laser_rifle/attack_self(mob/living/user)
	if(!currently_switching_types)
		change_to_switch_mode(user)
	return ..()

/// Makes the gun inoperable, playing an animation and giving a prompt to switch gun modes after the transition_duration passes
/obj/item/gun/energy/modular_laser_rifle/proc/change_to_switch_mode(mob/living/user)
	currently_switching_types = TRUE
	flick("[base_icon_state]_switch_on", src)
	playsound(src, 'sound/items/modsuit/ballin.ogg', 75, TRUE)
	icon_state = "[base_icon_state]_switch"
	addtimer(CALLBACK(src, PROC_REF(show_radial_choice_menu)), user)

/// Shows the radial choice menu to the user, if the user doesnt exist or isnt holding the gun anymore, it reverts back to its last form
/obj/item/gun/energy/modular_laser_rifle/proc/show_radial_choice_menu(mob/living/user)
	if(!user?.is_holding(src))
		flick("[base_icon_state]_switch_off", src)
		icon_state = "[base_icon_state]_[currently_selected_mode.weapon_icon_state]"
		playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)
		return

	var/picked_choice = show_radial_menu(
		user,
		src,
		radial_menu_data,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		flick("[base_icon_state]_switch_off", src)
		icon_state = "[base_icon_state]_[currently_selected_mode.weapon_icon_state]"
		playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)
		return

	transform_gun(picked_choice, TRUE)

/// Transforms the gun into a different type, if replacing is set to true then it'll make sure to remove any effects the prior gun type had
/obj/item/gun/energy/modular_laser_rifle/proc/transform_gun(datum/laser_weapon_mode/new_weapon_mode, replacing = TRUE)
	if(replacing)
		currently_selected_mode.remove_from_weapon(src)
	currently_selected_mode = new_weapon_mode
	flick("[base_icon_state]_switch_off", src)
	currently_selected_mode.apply_stats(src)
	currently_selected_mode.apply_to_weapon(src)
	playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)

// Power cell for the big rifle
/obj/item/stock_parts/cell/hyeseong_internal_cell
	name = "\improper Hyseong modular laser rifle internal cell"
	desc = "These are usually supposed to be inside of the gun, you know."
	maxcharge = STANDARD_CELL_CHARGE * 2
