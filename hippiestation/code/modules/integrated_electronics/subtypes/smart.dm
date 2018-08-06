// - MMI Tank - //
/obj/item/integrated_circuit/input/mmi_tank
	name = "man-machine interface tank"
	desc = "This circuit is just a jar filled with an artificial liquid mimicking the cerebrospinal fluid."
	extended_desc = "This jar can hold 1 man-machine interface and let it take control of some basic functions of the assembly."
	complexity = 29
	inputs = list("laws" = IC_PINTYPE_LIST)
	outputs = list(
		"man-machine interface" = IC_PINTYPE_REF,
		"direction" = IC_PINTYPE_DIR,
		"click target" = IC_PINTYPE_REF
		)
	activators = list(
		"move" = IC_PINTYPE_PULSE_OUT,
		"left" = IC_PINTYPE_PULSE_OUT,
		"right" = IC_PINTYPE_PULSE_OUT,
		"up" = IC_PINTYPE_PULSE_OUT,
		"down" = IC_PINTYPE_PULSE_OUT,
		"leftclick" = IC_PINTYPE_PULSE_OUT,
		"shiftclick" = IC_PINTYPE_PULSE_OUT,
		"altclick" = IC_PINTYPE_PULSE_OUT,
		"ctrlclick" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 150
	can_be_asked_input = TRUE
	var/obj/item/mmi/installed_brain

/obj/item/integrated_circuit/input/mmi_tank/attackby(var/obj/item/mmi/O, var/mob/user)
	if(!istype(O,/obj/item/mmi))
		to_chat(user,"<span class='warning'>You can't put that inside.</span>")
		return
	if(installed_brain)
		to_chat(user,"<span class='warning'>There's already a brain inside.</span>")
		return
	user.transferItemToLoc(O,src)
	installed_brain = O
	can_be_asked_input = FALSE
	to_chat(user, "<span class='notice'>You gently place \the man-machine interface inside the tank.</span>")
	to_chat(O, "<span class='notice'>You are slowly being placed inside the man-machine-interface tank.</span>")
	O.brainmob.remote_control=src
	set_pin_data(IC_OUTPUT, 1, O)

/obj/item/integrated_circuit/input/mmi_tank/attack_self(var/mob/user)
	if(installed_brain)
		RemoveBrain()
		to_chat(user, "<span class='notice'>You slowly lift [installed_brain] out of the MMI tank.</span>")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		installed_brain = null
		push_data()
	else
		to_chat(user, "<span class='notice'>You don't see any brain swimming in the tank.</span>")

/obj/item/integrated_circuit/input/mmi_tank/Destroy()
	RemoveBrain()
	..()

/obj/item/integrated_circuit/input/mmi_tank/relaymove(var/n,var/dir)
	set_pin_data(IC_OUTPUT, 2, dir)
	do_work(1)
	switch(dir)
		if(8)	activate_pin(2)
		if(4)	activate_pin(3)
		if(1)	activate_pin(4)
		if(2)	activate_pin(5)

/obj/item/integrated_circuit/input/mmi_tank/do_work(var/n)
	push_data()
	activate_pin(n)

/obj/item/integrated_circuit/input/mmi_tank/proc/RemoveBrain()
	if(installed_brain)
		can_be_asked_input = TRUE
		installed_brain.forceMove(drop_location())
		set_pin_data(IC_OUTPUT, 1, WEAKREF(null))
		if(installed_brain.brainmob)
			installed_brain.brainmob.remote_control = installed_brain
	..()


//Brain changes
/mob/living/brain/var/check_bot_self = FALSE

/mob/living/brain/ClickOn(atom/A, params)
	..()
	if(!istype(remote_control,/obj/item/integrated_circuit/input/mmi_tank))
		return
	var/obj/item/integrated_circuit/input/mmi_tank/brainholder=remote_control
	brainholder.set_pin_data(IC_OUTPUT, 3, A)
	var/list/modifiers = params2list(params)

	if(modifiers["shift"])
		brainholder.do_work(7)
		return
	if(modifiers["alt"])
		brainholder.do_work(8)
		return
	if(modifiers["ctrl"])
		brainholder.do_work(9)
		return

	if(istype(A,/obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/CheckedAssembly = A

		if(brainholder in CheckedAssembly.assembly_components)
			var/obj/item/electronic_assembly/holdingassembly=A
			check_bot_self=TRUE

			if(holdingassembly.opened)
				holdingassembly.ui_interact(src)
			holdingassembly.attack_self(src)
			check_bot_self=FALSE
			return

	brainholder.do_work(6)

/mob/living/brain/canUseTopic()
	return	check_bot_self

/obj/item/integrated_circuit/smart/advanced_pathfinder/proc/hippie_xor_decrypt()
	var/Ps = get_pin_data(IC_INPUT, 4)
	if(!Ps)
		return
	var/list/Pl = json_decode(XorEncrypt(hextostr(Ps, TRUE), SScircuit.cipherkey))
	if(Pl&&islist(Pl))
		idc.access = Pl

// - pAI connector circuit - //
/obj/item/integrated_circuit/input/pAI_connector
	name = "pAI connector circuit"
	desc = "This circuit lets you fit in a personal artificial intelligence to give it some form of control over the bot."
	extended_desc = "You can wire various functions to it."
	complexity = 29
	inputs = list("laws" = IC_PINTYPE_LIST)
	outputs = list(
		"personal artificial intelligence" = IC_PINTYPE_REF,
		"direction" = IC_PINTYPE_DIR,
		"click target" = IC_PINTYPE_REF
		)
	activators = list(
		"move" = IC_PINTYPE_PULSE_OUT,
		"left" = IC_PINTYPE_PULSE_OUT,
		"right" = IC_PINTYPE_PULSE_OUT,
		"up" = IC_PINTYPE_PULSE_OUT,
		"down" = IC_PINTYPE_PULSE_OUT,
		"leftclick" = IC_PINTYPE_PULSE_OUT,
		"shiftclick" = IC_PINTYPE_PULSE_OUT,
		"altclick" = IC_PINTYPE_PULSE_OUT,
		"ctrlclick" = IC_PINTYPE_PULSE_OUT,
		"shiftctrlclick" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 150
	can_be_asked_input = TRUE
	var/obj/item/paicard/installed_pai

/obj/item/integrated_circuit/input/pAI_connector/attackby(var/obj/item/paicard/O, var/mob/user)
	if(!istype(O,/obj/item/paicard))
		to_chat(user,"<span class='warning'>You can't put that inside.</span>")
		return
	if(installed_pai)
		to_chat(user,"<span class='warning'>There's already a pAI connected to this.</span>")
		return
	user.transferItemToLoc(O,src)
	installed_pai = O
	can_be_asked_input = FALSE
	to_chat(user, "<span class='notice'>You slowly connect the circuit's pins to the [installed_pai].</span>")
	to_chat(O, "<span class='notice'>You are slowly being connected to the pAI connector.</span>")
	O.pai.remote_control=src
	set_pin_data(IC_OUTPUT, 1, O)

/obj/item/integrated_circuit/input/pAI_connector/attack_self(var/mob/user)
	if(installed_pai)
		RemovepAI()
		to_chat(user, "<span class='notice'>You slowly disconnect the circuit's pins from the [installed_pai].</span>")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		installed_pai = null
		push_data()
	else
		to_chat(user, "<span class='notice'>The connection port is empty.</span>")

/obj/item/integrated_circuit/input/pAI_connector/relaymove(var/n,var/dir)
	set_pin_data(IC_OUTPUT, 2, dir)
	do_work(1)
	switch(dir)
		if(8)	activate_pin(2)
		if(4)	activate_pin(3)
		if(1)	activate_pin(4)
		if(2)	activate_pin(5)

/obj/item/integrated_circuit/input/pAI_connector/do_work(var/n)
	push_data()
	activate_pin(n)


/obj/item/integrated_circuit/input/pAI_connector/Destroy()
	RemovepAI()
	..()

/obj/item/integrated_circuit/input/pAI_connector/proc/RemovepAI()
	if(installed_pai)
		can_be_asked_input = TRUE
		installed_pai.forceMove(drop_location())
		set_pin_data(IC_OUTPUT, 1, WEAKREF(null))
		installed_pai.pai.remote_control = installed_pai
	..()


//pAI changes
/mob/living/silicon/pai/var/check_bot_self = FALSE

/mob/living/silicon/pai/ClickOn(atom/A, params)
	..()
	if(!istype(remote_control,/obj/item/integrated_circuit/input/pAI_connector))
		return
	var/obj/item/integrated_circuit/input/pAI_connector/paiholder=remote_control
	paiholder.set_pin_data(IC_OUTPUT, 3, A)
	var/list/modifiers = params2list(params)

	if(modifiers["shift"])
		paiholder.do_work(7)
		return
	if(modifiers["alt"])
		paiholder.do_work(8)
		return
	if(modifiers["ctrl"])
		paiholder.do_work(9)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		paiholder.do_work(10)
		return


	if(istype(A,/obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/CheckedAssembly = A

		if(paiholder in CheckedAssembly.assembly_components)
			var/obj/item/electronic_assembly/holdingassembly=A
			check_bot_self=TRUE

			if(holdingassembly.opened)
				holdingassembly.ui_interact(src)
			holdingassembly.attack_self(src)
			check_bot_self=FALSE
			return

	paiholder.do_work(6)

/mob/living/silicon/pai/canUseTopic()
	return	check_bot_self
