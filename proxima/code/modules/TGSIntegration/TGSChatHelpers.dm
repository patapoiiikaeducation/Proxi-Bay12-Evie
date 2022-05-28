/**
sends a message to chat

config_setting should be one of the following:

- null - noop
- empty string - use TgsTargetBroadcast with `admin_only = FALSE`
- other string - use TgsChatBroadcast with the tag that matches config_setting, only works with TGS4, if using TGS3 the above method is used
*/
/proc/send2chat(message, config_setting)
	if(config_setting == null || !world.TgsAvailable())
		return

	var/datum/tgs_version/version = world.TgsVersion()
	if(config_setting == "" || version.suite == 3)
		world.TgsTargetedChatBroadcast(message, FALSE)
		return

	var/debug = list()
	debug += "**Отладка каналов**\nПолучен тэг: `[config_setting]`\nДоступны следующие каналы:"

	var/list/channels_to_use = list()
	for(var/I in world.TgsChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I

		debug += "ID: `[channel.id]` isAdmin: [channel.is_admin_channel?"TRUE":"FALSE"] customTag: `[channel.custom_tag == null?"NULL":"[channel.custom_tag]"]` friendlyName: [channel.friendly_name] pseudoLink: <#[channel.id]>"

		if(channel.custom_tag == config_setting)
			channels_to_use += channel

			debug += "^^^ That channel passed ^^^"

	if(channels_to_use.len)
		world.TgsChatBroadcast(message, channels_to_use)

	debug += "\n**Само сообщение для передачи:**\n"
	debug += message
	world.TgsTargetedChatBroadcast(jointext(debug, "\n"), TRUE)

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights(requiredflags, 0, X))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.is_stealthed())
			.["stealth"] += X
		else
			.["present"] += X

/proc/get_active_player_count(var/alive_check = 0, var/afk_check = 0, var/human_check = 0)
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M && M.client)
			if(alive_check && M.stat)
				continue
			else if(afk_check && M.client.is_afk())
				continue
			else if(human_check && !ishuman(M))
				continue
			else if(isnewplayer(M)) // exclude people in the lobby
				continue
			else if(isghost(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/observer/ghost/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players
