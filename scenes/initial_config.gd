extends Control
## Save first initial config
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _game_version_label: Label = $GameVersion
@onready
var _accept_dialog: AcceptDialog = $AcceptDialog


func _ready():
	_game_version_label.text = "Pokédexica v%s" % Globals.VERSION

	var request = HTTPRequest.new()
	add_child(request)
	
	if request.request("https://godotengine.org") != OK:
		_accept_dialog.show()
	else:
		if GameSettings.config_exists:
			get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_accept_dialog_confirmed():
	get_tree().quit(126)


func _on_accept_dialog_canceled():
	get_tree().quit(126)


func _on_twitch_channel_form_channel_connect():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
