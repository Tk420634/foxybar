// Core balance principles with these roundstart augments is that they are SLOW. 2 toolspeed minimum where possible - finding actual things in round should always be better, this is for flavor and accessibility. The accessibility alone already provides these with a lot of value.

// ARM IMPLANTS
/obj/item/organ/internal/cyberimp/arm/adjuster
	name = "adjuster arm implant"
	desc = "A miniaturized toolset implant containing a simple fingertip-mounted universal screwdriver bit with an inverted torque-wrench head. Most commonly used when rearranging furniture or other station machinery."
	items_to_create = list(/obj/item/wrench/integrated, /obj/item/screwdriver/integrated)

/obj/item/organ/internal/cyberimp/arm/adjuster/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NAKAMURA)

/obj/item/organ/internal/cyberimp/arm/electrical_toolset
	name = "electrical toolset implant"
	desc = "Bereft of any kind of insulation to speak of, this aug has a very distinct nickname amongst frontier outpost crews: 'the sizzler'. Often used in high verticality environments where loadout space is at a premium."
	items_to_create = list(/obj/item/screwdriver/integrated, /obj/item/multitool/integrated)

/obj/item/organ/internal/cyberimp/arm/electrical_toolset/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NAKAMURA)

/obj/item/organ/internal/cyberimp/arm/arc_welder
	name = "shipbreaker's toolset implant"
	desc = "A specialized salvage-grade implant that houses an arc welder, miniaturized crowbar within the bearer's arm, plus a fingertip torque-wrench rated for enough newtons to get the job done. Renowned across the frontier for being the 'trashy tattoo' equivalent of someone's first aug."
	items_to_create = list(/obj/item/wrench/integrated, /obj/item/crowbar/integrated, /obj/item/weldingtool/electric/arc_welder/integrated)

/obj/item/organ/internal/cyberimp/arm/arc_welder/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/item/organ/internal/cyberimp/arm/emt_triage
	name = "triage actuator implant"
	desc = "Pioneered by Interdyne Pharmaceuticals for use in their frontier postings, this set of in-arm augments allows medical staff to perform basic life-saving surgeries out on the field."
	items_to_create = list(/obj/item/surgical_drapes/integrated, /obj/item/scalpel/integrated, /obj/item/hemostat/integrated)

/obj/item/organ/internal/cyberimp/arm/emt_triage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_INTERDYNE)

/obj/item/organ/internal/cyberimp/arm/civilian_barstaff
	name = "waitstaff implant"
	desc = "The galactic service industry demands only the finest from its (underpaid) employees, leading to the development of this sordid piece of technology which substitutes a user's organic arm for a food storage space and an integrated chamois cleaning cloth. Why?"
	items_to_create = list(/obj/item/storage/bag/tray/integrated, /obj/item/reagent_containers/cup/rag/integrated)

/obj/item/organ/internal/cyberimp/arm/civilian_lighter
	name = "thumbtip lighter implant"
	desc = "This extraordinarily useless implant was a product of market demand, and it exists because the galactic diaspora apparently craves the ability to light things with their thumbtips."
	items_to_create = list(/obj/item/lighter/integrated)
