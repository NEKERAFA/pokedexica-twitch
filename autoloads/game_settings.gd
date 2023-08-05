extends Node
## Utilities to load and write in config file
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


const CONFIG_FILE_PATH: String = "user://settings.cfg"
const DEFAULT_CHANNEL: String = ""

var _config_file := ConfigFile.new()


## Twitch channel to read IRC chat
var twitch_channel: String:
	get:
		return _config_file.get_value("Twitch", "channel", DEFAULT_CHANNEL)
	set(channel):
		_config_file.set_value("Twitch", "channel", channel)


var config_exists: bool:
	get:
		return FileAccess.file_exists(CONFIG_FILE_PATH)


## Loads config file
func _init():
	if config_exists:
		if _config_file.load(CONFIG_FILE_PATH) != OK:
			push_warning("cannot load %s" % CONFIG_FILE_PATH)


## Save setting to config file
func save_data():
	return _config_file.save(CONFIG_FILE_PATH)
