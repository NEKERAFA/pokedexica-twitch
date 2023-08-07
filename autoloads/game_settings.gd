extends Node
## Utilities to load and write in config file
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


const CONFIG_FILE_PATH: String = "user://settings.cfg"
const DEFAULT_CHANNEL: String = ""
const DEFAULT_LAST_POKEMON: int = 0
const DEFAULT_LAST_POKEMON_NAME: String = ""
const DEFAULT_LAST_BY: String = ""


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
		return _config_file.get_value("Last_Pokemon", "entry", DEFAULT_LAST_POKEMON)
	set(entry):
		_config_file.set_value("Last_Pokemon", "entry", entry)


## Last pokemon name seen
var last_pokemon_name: String:
	get:
		return _config_file.get_value("Last_Pokemon", "name", DEFAULT_LAST_POKEMON_NAME)
	set(pokemon_name):
		_config_file.set_value("Last_Pokemon", "name", pokemon_name)


## Last pokemon seen by
var last_pokemon_by: String:
	get:
		return _config_file.get_value("Last_Pokemon", "username", DEFAULT_LAST_BY)
	set(username):
		_config_file.set_value("Last_Pokemon", "username", username)


## Loads config file
func _init():
	if config_exists:
		if _config_file.load(CONFIG_FILE_PATH) != OK:
			push_warning("cannot load %s" % CONFIG_FILE_PATH)


## Save setting to config file
func save_data():
	return _config_file.save(CONFIG_FILE_PATH)
