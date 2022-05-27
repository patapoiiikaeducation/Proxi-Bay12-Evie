#define IRC_STATUS_THROTTLE 5

/datum/tgs_chat_command/ircstatus
	name = "status"
	help_text = "Показывает админов, кол-во игроков, игровой режим и настоящий игровой режим на сервере"
	admin_only = TRUE
	var/last_irc_status = 0

/datum/tgs_chat_command/ircstatus/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_status < IRC_STATUS_THROTTLE)
		return
	last_irc_status = rtod
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["total"]
	var/status = "**Админы: [allmins.len]**\n(Активные: __*[english_list(adm["present"])]*__\nАФК: __*[english_list(adm["afk"])]*__\nСкрыты: __*[english_list(adm["stealth"])]*__\nБез бана: __*[english_list(adm["noflags"])]*__).\n\n"
	status += "**Игроки: [GLOB.clients.len]**\n(Активные: __*[get_active_player_count(0,1,0)]*__).\nНастоящий режим: __*[SSticker.mode ? SSticker.mode.name : "Не начался"]*__."
	return status

/datum/tgs_chat_command/irccheck
	name = "check"
	help_text = "Показывает онлайн, текущий режим и адрес сервера"
	var/last_irc_check = 0

/datum/tgs_chat_command/irccheck/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod
	return "[game_id ? "**Раунд № *[game_id]***\n" : ""]__[GLOB.clients.len]__ игроков на __[GLOB.using_map.full_name]__\nРежим: __[PUBLIC_GAME_MODE]__\nРаунд __[GAME_STATE != RUNLEVEL_LOBBY ? (GAME_STATE != RUNLEVEL_POSTGAME ? "В процессе" : "Заканчивается") : "Подготавливается"]__\n**Заходи к нам: <[get_world_url()]>!**"

/datum/tgs_chat_command/ircmanifest
	name = "manifest"
	help_text = "Показывает список членов экипажа с их должностями"
	var/last_irc_check = 0

/datum/tgs_chat_command/ircmanifest/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod
	var/list/msg = list()
	var/list/positions = list()
	var/list/nano_crew_manifest = nano_crew_manifest()
	// We rebuild the list in the format external tools expect
	for(var/dept in nano_crew_manifest)
		var/list/dept_list = nano_crew_manifest[dept]
		if(dept_list.len > 0)
			positions[dept] = list()
			var/depString
			switch(dept)
				if ("heads") depString = "Командование"
				if ("spt") depString = "Поддержка командования"
				if ("sci") depString = "Научный отдел"
				if ("sec") depString = "Отдел безопасности"
				if ("eng") depString = "Инженерный отдел"
				if ("med") depString = "Медицинский отдел"
				if ("sup") depString = "Отдел снабжения"
				if ("exp") depString = "Экспедиционный отдел"
				if ("srv") depString = "Отдел обслуживания"
				if ("bot") depString = "Синтетики"
				if ("civ") depString = "Гражданские"
				else depString = dept
			msg += "__**[depString]**__"
			for(var/list/person in dept_list)
				var/datum/mil_branch/branch_obj = mil_branches.get_branch(person["branch"])
				var/datum/mil_rank/rank_obj = mil_branches.get_rank(person["branch"], person["milrank"])
				msg += "__[person["rank"]]__ - `[branch_obj!=null ? "[branch_obj.name_short] " : ""][rank_obj!=null ? "[rank_obj.name_short] " : ""][person["name"]]`"
	return jointext(msg, "\n")

/** -- Отвечать на тикеты из дискорда? Я подумаю над этим
/datum/tgs_chat_command/ahelp
	name = "ahelp"
	help_text = ""
	admin_only = TRUE

/datum/tgs_chat_command/ahelp/Run(datum/tgs_chat_user/sender, params)
	var/list/all_params = splittext(params, " ")
	if(all_params.len < 2)
		return "Insufficient parameters"
	var/target = all_params[1]
	all_params.Cut(1, 2)
	var/id = text2num(target)
	if(id != null)
		var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(id)
		if(AH)
			target = AH.initiator_ckey
		else
			return "Ticket #[id] not found!"
	var/res = IrcPm(target, all_params.Join(" "), sender.friendly_name)
	if(res != "Message Successful")
		return res
**/

/datum/tgs_chat_command/adminwho
	name = "adminwho"
	help_text = "Перечисляет администраторов, находящихся на сервере"

/datum/tgs_chat_command/adminwho/Run(datum/tgs_chat_user/sender, params)
	var/list/msg = list()
	var/active_staff = 0
	var/total_staff = 0
	var/can_investigate = sender.channel.is_admin_channel

	for(var/client/C in GLOB.admins)
		var/line = list()
		if(!can_investigate && C.is_stealthed())
			continue
		total_staff++
		if(check_rights(R_ADMIN,0,C))
			line += "[C] в ранге **["\improper[C.holder.rank]"]**"
		else
			line += "[C] в ранге ["\improper[C.holder.rank]"]"
		if(!C.is_afk())
			active_staff++
		if(can_investigate)
			if(C.is_afk())
				line += " *(АФК - [C.inactivity2text()])*"
			if(isghost(C.mob))
				line += " - *Наблюдает*"
			else if(istype(C.mob,/mob/new_player))
				line += " - *В Лобби*"
			else
				line += " - *Играет*"
			if(C.is_stealthed())
				line += " *(Скрыт)*"
		line = jointext(line, null)
		if(check_rights(R_ADMIN,0,C))
			msg.Insert(1, line)
		else
			msg += line
	return "__**Админов онлайн: [can_investigate?"[active_staff]/[total_staff]":"[active_staff]"]**__\n[jointext(msg,"\n")]"

GLOBAL_LIST(round_end_notifiees)

/datum/tgs_chat_command/notify
	name = "notify"
	help_text = "Уведомляет вызвавшего по окончанию раунда"
	admin_only = TRUE

/datum/tgs_chat_command/notify/Run(datum/tgs_chat_user/sender, params)
	if(GAME_STATE == RUNLEVEL_POSTGAME)
		return "[sender.mention], раунд уже закончился!"
	LAZYINITLIST(GLOB.round_end_notifiees)
	GLOB.round_end_notifiees[sender.mention] = TRUE
	return "Я уведомлю [sender.mention] когда раунд закончится."
