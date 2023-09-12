extends Gift
## Controls twitch messages
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal pokemon_entered(pokemon_key: String, user_name: String, user_color: Color)

# squirtle easter egg
var _squirtle_synons = ["vamo a calmarno", "vamoh a calmarnoh", "vamoacalmarno", "vamohacalmarnoh"]


func _ready():
	username = _get_anonymously_user()
	token["access_token"] = "123456"

	chat_message.connect(self._on_chat_message)
	GameSettings.settings_updated.connect(self._on_game_settings_updated)

	await connect_client()

	if GameSettings.twitch_channel != "":
		join_channel(GameSettings.twitch_channel)


func connect_client():
	var success = await connect_to_irc()
	if success:
		request_caps()
	else:
		push_error("cannot connect to twitch channel")


func _on_chat_message(data: SenderData, message: String):
	if not data.tags.has("reply-parent-msg-id") and message.split(" ").size() <= 3:
		var pokemon_key = PokeCache.get_pokemon_key(message)
		if _squirtle_synons.find(message.to_lower()) != -1:
			pokemon_key = "squirtle"

		if PokeCache.has_pokemon_key(pokemon_key):
			var user_name = data.tags.get("display-name", data.user)
			var user_color = Color.from_string(data.tags["color"], Color.BLACK)
			pokemon_entered.emit(pokemon_key, user_name, user_color)


func _on_game_settings_updated():
	if GameSettings.twitch_channel != "":
		if connected and not channels.has(GameSettings.twitch_channel.to_lower()):
			for channel in channels.keys():
				leave_channel(channel)

			join_channel(GameSettings.twitch_channel)
		elif not connected:
			connect_client()


func _get_anonymously_user():
	var number = int(Time.get_unix_time_from_system() * 1000) % 1000000
	return "justinfan%06d" % number
