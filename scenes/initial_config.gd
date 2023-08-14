extends Control
## Save first initial config
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)

@onready
var _twitch_channel_input: LineEdit = $SettingContainer/VBoxContainer/TwitchSettings/TwitchUsername
@onready
var _game_version_label: Label = $GameVersion
@onready
var _accept_button: Button = $Accept
@onready
var _accept_dialog: AcceptDialog = $AcceptDialog
@onready
var _pokemon_cache = $"/root/PokemonCache"


func _ready():
	var request = HTTPRequest.new()
	add_child(request)
	
	request.request_completed.connect(self._on_request_completed)
	if request.request("https://godotengine.org") != OK:
		_accept_dialog.show()
	else:
		if GameSettings.config_exists:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		else:
			_game_version_label.text = "Pokédexica v%s" % Globals.VERSION


func _process(delta):
	if not _accept_button.disabled and not _pokemon_cache.isCacheReady:
		_accept_button.text = "Waiting for cache..."
		_accept_button.disabled = true
	elif _accept_button.disabled and _pokemon_cache.isCacheReady:
		_accept_button.text = "Accept"
		_accept_button.disabled = false


func _on_accept_pressed():
	if not _twitch_channel_input.text.strip_edges().is_empty():
		_twitch_channel_input.editable = false
		GameSettings.twitch_channel = _twitch_channel_input.text
		GameSettings.save_data()
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_accept_focus_exited():
	_accept_button.text = "Accept"


func _on_game_settings_settings_updated(result):
	if result == OK:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		_accept_button.text = "Try again :("


func _on_request_completed(result, _response_code, _header, _body):
	if result != HTTPRequest.RESULT_SUCCESS:
		_accept_dialog.show()


func _on_accept_dialog_confirmed():
	get_tree().quit(126)


func _on_accept_dialog_canceled():
	get_tree().quit(126)
