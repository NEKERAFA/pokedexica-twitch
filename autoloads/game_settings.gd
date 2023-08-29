extends Node
## Utilities to load and write in config file
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal settings_updated


const CONFIG_FILE_PATH: String = "user://settings.cfg"
const DEFAULT_CHANNEL: String = ""
const DEFAULT_LAST_POKEMON_ENTRY: int = 0
const DEFAULT_LAST_POKEMON_NAME: String = "<undefined>"
const DEFAULT_LAST_POKEMON_COLOR: Color = Color.BLACK
const DEFAULT_LAST_USER_NAME: String = "<undefined>"
const DEFAULT_LAST_USER_COLOR: Color = Color.BLACK


var _config_file := ConfigFile.new()


## Checks if config file exists
var config_exists: bool:
	get:
		return FileAccess.file_exists(CONFIG_FILE_PATH)


## Twitch channel to read IRC chat
var twitch_channel: String:
	get:
		return _config_file.get_value("Twitch", "channel", DEFAULT_CHANNEL)
	set(channel):
		_config_file.set_value("Twitch", "channel", channel)


## Last pokemon entry seen
var last_pokemon_entry: int:
	get:
		return _config_file.get_value("Last_Pokemon", "entry", DEFAULT_LAST_POKEMON_ENTRY)
	set(entry):
		_config_file.set_value("Last_Pokemon", "entry", entry)


## Last pokemon name seen
var last_pokemon_name: String:
	get:
		return _config_file.get_value("Last_Pokemon", "name", DEFAULT_LAST_POKEMON_NAME)
	set(pokemon_name):
		_config_file.set_value("Last_Pokemon", "name", pokemon_name)


## Last pokemon type color seen
var last_pokemon_color: Color:
	get:
		return _config_file.get_value("Last_Pokemon", "color", DEFAULT_LAST_POKEMON_COLOR)
	set(pokemon_color):
		_config_file.set_value("Last_Pokemon", "color", pokemon_color)


## User name who saw last pokemon
var last_user_name: String:
	get:
		return _config_file.get_value("Last_Pokemon", "user_name", DEFAULT_LAST_USER_NAME)
	set(user_name):
		_config_file.set_value("Last_Pokemon", "user_name", user_name)


## User color who saw last pokemon
var last_user_color: Color:
	get:
		return _config_file.get_value("Last_Pokemon", "user_color", DEFAULT_LAST_USER_COLOR)
	set(user_color):
		_config_file.set_value("Last_Pokemon", "user_color", user_color)


## Loads config file
func _init():
	if config_exists:
		if _config_file.load(CONFIG_FILE_PATH) != OK:
			push_error("cannot load %s" % CONFIG_FILE_PATH)


## Save setting to config file
func save_data():
	if _config_file.save(CONFIG_FILE_PATH) == OK:
		settings_updated.emit()
	else:
		push_error("cannot save %s" % CONFIG_FILE_PATH)
