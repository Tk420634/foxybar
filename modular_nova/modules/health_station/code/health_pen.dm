/obj/item/reagent_containers/hypospray/medipen/health_station //mining pen lite
	name = "colonial survival medipen"
	desc = "A medipen for surviving in the harsh environments, heals most common damage sources. Cheaper alternative to more common mining pens."
	icon = 'modular_nova/modules/health_station/icons/medipen.dmi'
	icon_state = "pen"
	inhand_icon_state = "stimpen"
	base_icon_state = "pen"
	volume = 25
	amount_per_transfer_from_this = 25
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 10,
	/datum/reagent/medicine/sal_acid = 10,
	/datum/reagent/medicine/leporazine = 5,
	)
