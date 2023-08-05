extends Control
## Save first initial config
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


var _twitch_channel_input: LineEdit


func _ready():
	if GameSettings.config_exists:
		_twitch_channel_input = $SettingContainer/VBoxContainer/TwitchSettings/TwitchUsername
		_twitch_channel_input.text = GameSettings.twitch_channel
		pass # TODO goes to game scene
	else:
		_twitch_channel_input = $SettingContainer/VBoxContainer/TwitchSettings/TwitchUsername


func _on_accept_pressed():
	if not _twitch_channel_input.text.strip_edges().is_empty():
		GameSettings.twitch_channel = _twitch_channel_input.text
		GameSettings.save_data()
		# TODO goes to game scene
