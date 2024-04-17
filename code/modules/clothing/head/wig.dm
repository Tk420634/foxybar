/obj/item/clothing/head/wig
	name = "wig"
	desc = "A bunch of hair without a head attached."
	icon = 'icons/mob/human/human_face.dmi'   // default icon for all hairs
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hair_vlong"
	inhand_icon_state = "pwig"
	worn_icon_state = "wig"
	flags_inv = HIDEHAIR
	color = COLOR_BLACK
	var/hairstyle = "Very Long Hair"
	var/adjustablecolor = TRUE //can color be changed manually?

/obj/item/clothing/head/wig/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/clothing/head/wig/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && (slot & ITEM_SLOT_HEAD))
		item_flags |= EXAMINE_SKIP

/obj/item/clothing/head/wig/dropped(mob/user)
	. = ..()
	item_flags &= ~EXAMINE_SKIP

/obj/item/clothing/head/wig/update_icon_state()
	var/datum/sprite_accessory/hair/hair_style = GLOB.hairstyles_list[hairstyle]
	if(hair_style)
		icon = hair_style.icon
		icon_state = hair_style.icon_state
	return ..()

<<<<<<< HEAD

/obj/item/clothing/head/wig/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	female_uniform = NO_FEMALE_UNIFORM,
	override_state = null,
	override_file = null,
	use_height_offset = TRUE,
	mutant_styles = NONE, // NOVA EDIT ADD - Further outfit modification for outfits (added `mutant_styles` argument)
)
	return ..(default_layer, default_icon_file, isinhands, female_uniform, override_state, override_file, use_height_offset = FALSE)

=======
>>>>>>> c66636d21e0 (Fix height settings double-applying offsets / some human icon gen cleanup I guess (#82672))
/obj/item/clothing/head/wig/worn_overlays(mutable_appearance/standing, isinhands = FALSE, file2use)
	. = ..()
	if(isinhands)
		return

	var/datum/sprite_accessory/hair/hair = GLOB.hairstyles_list[hairstyle]
	if(!hair)
		return

	var/mutable_appearance/hair_overlay = mutable_appearance(hair.icon, hair.icon_state, layer = -HAIR_LAYER, appearance_flags = RESET_COLOR)
	hair_overlay.color = color
	hair_overlay.pixel_y = hair.y_offset
	. += hair_overlay

	// So that the wig actually blocks emissives.
	hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, src, alpha = hair_overlay.alpha)

/obj/item/clothing/head/wig/attack_self(mob/user)
	var/new_style = tgui_input_list(user, "Select a hairstyle", "Wig Styling", GLOB.hairstyles_list - "Bald")
	var/newcolor = adjustablecolor ? input(usr,"","Choose Color",color) as color|null : null
	if(!user.can_perform_action(src))
		return
	if(new_style && new_style != hairstyle)
		hairstyle = new_style
		user.visible_message(span_notice("[user] changes \the [src]'s hairstyle to [new_style]."), span_notice("You change \the [src]'s hairstyle to [new_style]."))
	if(newcolor && newcolor != color) // only update if necessary
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	update_appearance()

/obj/item/clothing/head/wig/afterattack(mob/living/carbon/human/target, mob/user)
	. = ..()
	if(!istype(target))
		return

	if(target.head)
		var/obj/item/clothing/head = target.head
		if((head.flags_inv & HIDEHAIR) && !istype(head, /obj/item/clothing/head/wig))
			to_chat(user, span_warning("You can't get a good look at [target.p_their()] hair!"))
			return
	var/obj/item/bodypart/head/noggin = target.get_bodypart(BODY_ZONE_HEAD)
	if(!noggin)
		to_chat(user, span_warning("[target.p_They()] have no head!"))
		return

	var/selected_hairstyle = null
	var/selected_hairstyle_color = null
	if(istype(target.head, /obj/item/clothing/head/wig))
		var/obj/item/clothing/head/wig/wig = target.head
		selected_hairstyle = wig.hairstyle
		selected_hairstyle_color = wig.color
	else if((noggin.head_flags & HEAD_HAIR) && target.hairstyle != "Bald")
		selected_hairstyle = target.hairstyle
		selected_hairstyle_color = "[target.hair_color]"

	if(selected_hairstyle)
		to_chat(user, span_notice("You adjust the [src] to look just like [target.name]'s [selected_hairstyle]."))
		add_atom_colour(selected_hairstyle_color, FIXED_COLOUR_PRIORITY)
		hairstyle = selected_hairstyle
		update_appearance()

/obj/item/clothing/head/wig/random/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald") //Don't want invisible wig
	add_atom_colour("#[random_short_color()]", FIXED_COLOUR_PRIORITY)
	. = ..()

/obj/item/clothing/head/wig/natural
	name = "natural wig"
	desc = "A bunch of hair without a head attached. This one changes color to match the hair of the wearer. Nothing natural about that."
	color = COLOR_WHITE
	adjustablecolor = FALSE
	custom_price = PAYCHECK_COMMAND

/obj/item/clothing/head/wig/natural/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald")
	. = ..()

/obj/item/clothing/head/wig/natural/visual_equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && (slot & ITEM_SLOT_HEAD))
		if(color != user.hair_color) // only update if necessary
			add_atom_colour(user.hair_color, FIXED_COLOUR_PRIORITY)
			update_appearance()
		user.update_worn_head()
