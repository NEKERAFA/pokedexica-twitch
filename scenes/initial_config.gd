extends Control
## Save first initial config
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


var _twitch_channel_input: LineEdit
var _game_version_label: Label
@onready
var _accept_button: Button = $Accept


func _ready():
	if GameSettings.config_exists:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		_twitch_channel_input = $SettingContainer/VBoxContainer/TwitchSettings/TwitchUsername
		_game_version_label = $GameVersion
		_game_version_label.text = "Pokédexica v%s" % Globals.VERSION


func _on_accept_pressed():
	if not _twitch_channel_input.text.strip_edges().is_empty():
		GameSettings.twitch_channel = _twitch_channel_input.text
		if GameSettings.save_data() == OK:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		else:
			_accept_button.text = "Try again :("


func _on_accept_focus_exited():
	_accept_button.text = "Accept"
