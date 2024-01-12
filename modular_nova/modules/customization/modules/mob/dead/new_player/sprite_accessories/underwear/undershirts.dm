//Modular Undershirts
/datum/sprite_accessory/undershirt
	icon = 'modular_nova/master_files/icons/mob/clothing/underwear.dmi'
	use_static = TRUE
	///Whether this underwear includes a bottom (For Leotards and the likes)
	var/hides_groin = FALSE

/*
	Base recolorable shirts
*/
/datum/sprite_accessory/undershirt/shirt
	name = "Shirt"
	icon_state = "shirt_white" //Reuses TG sprite until they set up GAGS for underwear
	use_static = null

/datum/sprite_accessory/undershirt/shortsleeve
	name = "Short-Sleeved Shirt"
	icon_state = "whiteshortsleeve" //Reuses TG sprite until they set up GAGS for underwear
	use_static = null

/datum/sprite_accessory/undershirt/tanktop
	name = "Tank Top"
	icon_state = "tank_white" //Reuses TG sprite until they set up GAGS for underwear
	use_static = null

/datum/sprite_accessory/undershirt/longsleeve
	name = "Long-Sleeved Shirt"
	icon_state = "longsleeve_white"
	use_static = null

/datum/sprite_accessory/undershirt/polo
	name = "Polo Shirt"
	icon_state = "polo"
	use_static = null

/datum/sprite_accessory/undershirt/tanktop_midriff
	name = "Tank Top - Midriff"
	icon_state = "tank_midriff"
	gender = FEMALE
	use_static = null

/datum/sprite_accessory/undershirt/tanktop_midriff_alt
	name = "Tank Top - Midriff Halterneck"
	icon_state = "tank_midriff_alt"
	gender = FEMALE
	use_static = null

/datum/sprite_accessory/undershirt/offshoulder
	name = "Shirt - Off-Shoulder"
	icon_state = "one_arm"
	gender = FEMALE
	use_static = null

/datum/sprite_accessory/undershirt/buttondown
	name = "Shirt - Buttondown"
	icon_state = "buttondown"
	gender = NEUTER
	use_static = null

/datum/sprite_accessory/undershirt/buttondown/short_sleeve
	name = "Shirt - Short Sleeved Buttondown"
	icon_state = "buttondown_short"

/datum/sprite_accessory/undershirt/leotard
	name = "Shirt - Leotard"
	icon_state = "leotard"
	gender = FEMALE
	use_static = null
	hides_groin = TRUE

/datum/sprite_accessory/undershirt/turtleneck
	name = "Sweater - Turtleneck"
	icon_state = "turtleneck"
	use_static = null
	gender = NEUTER

/datum/sprite_accessory/undershirt/turtleneck/smooth
	name = "Sweater - Smooth Turtleneck"
	icon_state = "turtleneck_smooth"

/datum/sprite_accessory/undershirt/turtleneck/sleeveless
	name = "Sweater - Sleeveless Turtleneck"
	icon_state = "turtleneck_sleeveless"

/datum/sprite_accessory/undershirt/leotard/turtleneck
	name = "Shirt - Turtleneck Leotard"
	icon_state = "leotard_turtleneck"

/datum/sprite_accessory/undershirt/leotard/turtleneck/sleeveless
	name = "Shirt - Turtleneck Leotard Sleeveless"
	icon_state = "leotard_turtleneck_sleeveless"

/*
	Preset/Decal Shirts
*/
/datum/sprite_accessory/undershirt/bulletclub //4 life
	name = "Shirt - Black Skull"
	icon_state = "shirt_bc"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bee_shirt
	name = "Shirt - Bee"
	icon_state = "bee_shirt"
	use_static = TRUE

/datum/sprite_accessory/undershirt/striped
	name = "Long-Sleeved Shirt - Black Stripes"
	icon_state = "longstripe"
	gender = NEUTER
	use_static = TRUE

/datum/sprite_accessory/undershirt/striped/blue
	name = "Long-Sleeved Shirt - Blue Stripes"
	icon_state = "longstripe_blue"

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top - Striped"
	icon_state = "tank_stripes"
	use_static = TRUE

/datum/sprite_accessory/undershirt/tank_top_rainbow
	name = "Tank Top - Rainbow"
	icon_state = "tank_rainbow"
	use_static = TRUE

/datum/sprite_accessory/undershirt/tank_top_sun
	name = "Tank Top - Sun"
	icon_state = "tank_sun"
	use_static = TRUE

//Not really qualifying as shirts but having nowhere better to go, these get shoved to the bottom of the list
/datum/sprite_accessory/undershirt/corset
	name = "Corset"
	icon_state = "corset"
	gender = FEMALE
	use_static = TRUE
	hides_groin = TRUE //an undershirt-specific bit of code, so the corset has to be an undershirt... unless you want to refactor it

/datum/sprite_accessory/undershirt/babydoll
	name = "Babydoll"
	icon_state = "babydoll"
	gender = FEMALE
	use_static = null
