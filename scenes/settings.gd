extends Control
## Save settings and check third-party licenses
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _game_version_lbl: Label = $GameInfoContainer/GameVersion
@onready
var _twitch_channel_input: LineEdit = $SettingContainer/VBoxContainer/TwitchSettings/TwitchUsername
@onready
var _save_button: Button = $Save


func _ready():
	_game_version_lbl.text = "Pokédexica v%s" % Globals.VERSION
	if GameSettings.config_exists:
		_twitch_channel_input.text = GameSettings.twitch_channel


func _on_back_button_pressed():
	pass # TODO return to game scene.


func _on_other_licenses_pressed():
	pass # TODO goes to othe license scene.


func _on_save_pressed():
	if not _twitch_channel_input.text.strip_edges().is_empty():
		GameSettings.twitch_channel = _twitch_channel_input.text
		if GameSettings.save_data() == OK:
			_save_button.text = "Saved!"
		else:
			_save_button.text = "Try again :("
	else:
		_twitch_channel_input.call_deferred("grab_focus")


func _on_save_focus_exited():
	_save_button.text = "Save"
