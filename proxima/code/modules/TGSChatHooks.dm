/world/TgsInitializationComplete()
	. = ..()
	world.TgsTargetedChatBroadcast("**Внимание, <@&839057002046947329>**\nНачинается смена на ГЭК Факел.\n*Заходите на <[get_world_url()]>*", FALSE)

/hook/roundend/proc/SendTGSRoundEnd()
	var/list/data = GLOB.using_map.roundend_statistics()
	if (data != null)
		var/v1 = data["clients"]
		var/v2 = data["surviving_humans"]
		var/v3 = data["surviving_total"]//required field for roundend webhook!
		var/v4 = data["ghosts"] //required field for roundend webhook!
		var/v5 = data["escaped_humans"]
		var/v6 = data["escaped_total"]
		var/v7 = data["left_behind_total"] //players who didnt escape and aren't on the station.
		var/v8 = data["offship_players"]
		world.TgsTargetedChatBroadcast("**Раунд на ГЭК Факел завершен.**\n__Статистика:__\n*Выжило из экипажа: [v2] (из которых органиков: [v3])*\n*Эвакуированно экипажа: [v5] (из которых органиков: [v6])*\n*Выживший экипаж, но брошенный помирать: [v7]*\n*Выжившие не члены экипажа: [v8]*\n*Всего игроков: [v1] (из них наблюдателей: [v4])*", FALSE)
	else
		world.TgsTargetedChatBroadcast("**Раунд на ГЭК Факел завершен.**\n__Статистики нет.__", FALSE)
	return TRUE
