/hook/startup/proc/SendTGSStartup()
	world.TgsTargetedChatBroadcast("Тестовое сообщение о инициализации ГЭК Факел. Заходите на <[get_world_url()]>", FALSE)
	return TRUE

/hook/roundend/proc/SendTGSRoundEnd()
	var/list/data = GLOB.using_map.roundend_statistics()
	var/text = "<br><br>"
	if (data != null)
		text += GLOB.using_map.roundend_summary(data)
	world.TgsTargetedChatBroadcast("Тестовое вообщение об окончание раунда на ГЭК Факел. [text]", FALSE)
	return TRUE
