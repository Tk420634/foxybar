/datum/design/hypovial
	name = "Hypovial"
	id = "hypovial"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/reagent_containers/cup/vial
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/basic_medical/New()
	design_ids += list(
		"hypovial",
	)
	return ..()



/// Large hypovials
/datum/design/hypovial/large
	name = "Large Hypovial"
	id = "large_hypovial"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/reagent_containers/cup/vial/large

/datum/design/hypokit
	name = "Hypospray Kit"
	id = "hypokit"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/storage/hypospraykit/empty
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/biotech/New()
	design_ids += list(
		"large_hypovial",
		"hypokit",
	)
	return ..()



/// Hyposprays
/datum/design/hypokit/deluxe
	name = "Deluxe Hypospray Kit"
	id = "hypokit_deluxe"
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 6,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	build_path = /obj/item/storage/hypospraykit/cmo/empty

/datum/design/hypomkii
	name = "MkII Hypospray"
	id = "hypomkii"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/hypospray/mkii
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/adv_biotech/New()
	design_ids += list(
		"hypokit_deluxe",
		"hypomkii",
	)
	return ..()



/// CMO-tier hyposprays: these are added in alien surgery so they're not COMPLETELY irreplacable.  Open to removing it.
/datum/design/hypomkii/deluxe
	name = "Deluxe MkII Hypospray"
	id = "hypomkii_deluxe"
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 1,
	)
	build_path = /obj/item/hypospray/mkii/cmo
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL_ADVANCED,
	)

/datum/techweb_node/alien_surgery/New()
	design_ids += list(
		"hypomkii_deluxe",
	)
	return ..()



/// For reasons unknown, pens are included as an autolathe deisgn here, in the hypospray module of all places.
/// I'm not touching this unless a maint asks me to because it feels weird and haunted, like the picture of a potato that bricks Source if you remove it.
/datum/design/pen
	name = "Pen"
	id = "pen"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/pen
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)
