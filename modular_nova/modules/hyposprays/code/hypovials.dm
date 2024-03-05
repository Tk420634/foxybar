/obj/item/reagent_containers/cup/vial
	name = "broken hypovial"
	desc = "You probably shouldn't be seeing this. Shout at a coder."
	icon = 'modular_nova/modules/hyposprays/icons/vials.dmi'
	icon_state = "hypovial"
	fill_icon_state = "hypovial_fill"
	spillable = FALSE
	volume = 10
	possible_transfer_amounts = list(1,2,5,10)
	fill_icon_thresholds = list(10, 25, 50, 75, 100)
	var/chem_color //Used for hypospray overlay
	var/type_suffix = "-s"
	fill_icon = 'modular_nova/modules/hyposprays/icons/hypospray_fillings.dmi'

/obj/item/reagent_containers/cup/vial/update_overlays()
	. = ..()
	// Search the overlays for the fill overlay from reagent_containers, and nudge its layer down to have it look correct.
	var/list/generated_overlays = .
	for(var/added_overlay in generated_overlays)
		if(istype(added_overlay, /mutable_appearance))
			var/mutable_appearance/overlay_image = added_overlay
			if(findtext(overlay_image.icon_state, fill_icon_state) != 0)
				overlay_image.layer = layer - 0.01
				chem_color = overlay_image.color

/obj/item/reagent_containers/cup/vial/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/reagent_containers/cup/vial/on_reagent_change()
	update_icon()

//Fit in all hypos
/obj/item/reagent_containers/cup/vial/small
	name = "hypovial"
	desc = "A small, 50u capacity vial compatible with most hyposprays."
	volume = 50
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

	unique_reskin = list(
						"Sterile" = "hypovial",
						"Generic" = "hypovial-generic",
						"Brute" = "hypovial-brute",
						"Burn" = "hypovial-burn",
						"Toxin" = "hypovial-tox",
						"Oxyloss" = "hypovial-oxy",
						"Crit" = "hypovial-crit",
						"Buff" = "hypovial-buff",
						)

/obj/item/reagent_containers/cup/vial/small/style
	icon_state = "hypovial"

//Styles
/obj/item/reagent_containers/cup/vial/small/style/generic
	icon_state = "hypovial-generic"
/obj/item/reagent_containers/cup/vial/small/style/brute
	icon_state = "hypovial-brute"
/obj/item/reagent_containers/cup/vial/small/style/burn
	icon_state = "hypovial-burn"
/obj/item/reagent_containers/cup/vial/small/style/toxin
	icon_state = "hypovial-tox"
/obj/item/reagent_containers/cup/vial/small/style/oxy
	icon_state = "hypovial-oxy"
/obj/item/reagent_containers/cup/vial/small/style/crit
	icon_state = "hypovial-crit"
/obj/item/reagent_containers/cup/vial/small/style/buff
	icon_state = "hypovial-buff"

//Fit in CMO hypo only
/obj/item/reagent_containers/cup/vial/large
	name = "large hypovial"
	icon_state = "hypoviallarge"
	fill_icon_state = "hypoviallarge_fill"
	desc = "A large, 100u capacity vial that fits only in the most deluxe hyposprays."
	volume = 100
	possible_transfer_amounts = list(1,2,5,10,20,30,40,50,100)
	type_suffix = "-l"

	unique_reskin = list(
						"Sterile" = "hypoviallarge",
						"Generic" = "hypoviallarge-generic",
						"Brute" = "hypoviallarge-brute",
						"Burn" = "hypoviallarge-burn",
						"Toxin" = "hypoviallarge-tox",
						"Oxyloss" = "hypoviallarge-oxy",
						"Crit" = "hypoviallarge-crit",
						"Buff" = "hypoviallarge-buff",
						)

/obj/item/reagent_containers/cup/vial/large/style/
	icon_state = "hypoviallarge"

//Styles
/obj/item/reagent_containers/cup/vial/large/style/generic
	icon_state = "hypoviallarge-generic"
/obj/item/reagent_containers/cup/vial/large/style/brute
	icon_state = "hypoviallarge-brute"
/obj/item/reagent_containers/cup/vial/large/style/burn
	icon_state = "hypoviallarge-burn"
/obj/item/reagent_containers/cup/vial/large/style/toxin
	icon_state = "hypoviallarge-tox"
/obj/item/reagent_containers/cup/vial/large/style/oxy
	icon_state = "hypoviallarge-oxy"
/obj/item/reagent_containers/cup/vial/large/style/crit
	icon_state = "hypoviallarge-crit"
/obj/item/reagent_containers/cup/vial/large/style/buff
	icon_state = "hypoviallarge-buff"



//Hypos that are in the CMO's kit round start
/obj/item/reagent_containers/cup/vial/large/deluxe
	name = "deluxe hypovial"
	icon_state = "hypoviallarge-buff"
	list_reagents = list(/datum/reagent/medicine/omnizine = 15, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/cup/vial/large/salglu
	name = "large green hypovial (salglu)"
	icon_state = "hypoviallarge-oxy"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 50)

/obj/item/reagent_containers/cup/vial/large/synthflesh
	name = "large orange hypovial (synthflesh)"
	icon_state = "hypoviallarge-crit"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 50)

/obj/item/reagent_containers/cup/vial/large/multiver
	name = "large black hypovial (multiver)"
	icon_state = "hypoviallarge-tox"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 50)



//Some bespoke helper types for preloaded combat medkits.
/obj/item/reagent_containers/cup/vial/large/advbrute
	name = "Brute Heal"
	icon_state = "hypoviallarge-brute"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 50, /datum/reagent/medicine/sal_acid = 50)

/obj/item/reagent_containers/cup/vial/large/advburn
	name = "Burn Heal"
	icon_state = "hypoviallarge-burn"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 50, /datum/reagent/medicine/oxandrolone = 50)

/obj/item/reagent_containers/cup/vial/large/advtox
	name = "Toxin Heal"
	icon_state = "hypoviallarge-tox"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 100)

/obj/item/reagent_containers/cup/vial/large/advoxy
	name = "Oxy Heal"
	icon_state = "hypoviallarge-oxy"
	list_reagents = list(/datum/reagent/medicine/c2/tirimol = 50, /datum/reagent/medicine/salbutamol = 50)

/obj/item/reagent_containers/cup/vial/large/advcrit
	name = "Crit Heal"
	icon_state = "hypoviallarge-crit"
	list_reagents = list(/datum/reagent/medicine/atropine = 100)

/obj/item/reagent_containers/cup/vial/large/advomni
	name = "All-Heal"
	icon_state = "hypoviallarge-buff"
	list_reagents = list(/datum/reagent/medicine/regen_jelly = 100)

/obj/item/reagent_containers/cup/vial/large/numbing
	name = "Numbing"
	icon_state = "hypoviallarge-generic"
	list_reagents = list(/datum/reagent/medicine/mine_salve = 50, /datum/reagent/medicine/morphine = 50)
