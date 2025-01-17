/obj/structure/table/mag
	name = "Magnetic Table"
	desc = "It is simple magnetic table. Good for merchants."
	icon = 'proxima/code/modules/merchant/magtable/mag_tables.dmi'
	icon_state = "magnetic_table_disabled"
	var/icon_state_open = "magnetic_table_disabled"
	var/icon_state_closed = "magnetic_table_enabled"
	req_access = list(access_merchant)
	can_plate = 0
	can_reinforce = 0
	flipped = -1
	var/locked = 0

/obj/structure/table/mag/Initialize()
	. = ..()
	verbs -= /obj/structure/table/verb/do_flip
	verbs -= /obj/structure/table/proc/do_put
	name = "Magnetic Table"
	health_max = 20
	health_current = 20


/obj/structure/table/mag/on_update_icon()
	if (locked)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_open
	return

/obj/structure/table/mag/can_connect()
	return FALSE

damage_health

/obj/structure/table/mag/damage_health(damage)
	..()
	if(health_current <= 10 && locked)
		toggle_lock()


/obj/structure/table/mag/Destroy()
	if(locked)
		toggle_lock()
	..()

/obj/structure/table/mag/break_to_parts(full_return = 0)
	if(locked)
		toggle_lock()
	..()

/obj/structure/table/mag/proc/toggle_lock()
	if(health_current <= 10 && !locked)
		return
	locked = !locked
	update_icon()
	for (var/obj/item/I in get_turf(src))
		I.anchored = locked
	playsound(src, 'sound/effects/storage/briefcase.ogg', 100, 1)

/obj/structure/table/mag/attackby(obj/item/card/W as obj, mob/user as mob, var/click_params)
	if(isrobot(user))
		return
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/modular_computer))
		if(allowed(usr))
			toggle_lock()
			visible_message(SPAN_NOTICE("[usr] [locked ? "" : "un"]locked [src]!"))
			return
	if(isitem(W))
		if(user.drop_from_inventory(W, src.loc))
			auto_align(W, click_params)
			W.anchored = locked
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	..()

/obj/structure/table/mag/CtrlClick()
	return
