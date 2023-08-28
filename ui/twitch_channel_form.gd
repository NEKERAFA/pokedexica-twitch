class_name TwitchChannelForm
extends VBoxContainer
## Twitch channel form item
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal channel_connect


@onready
var _channel_input: LineEdit = $FormContainer/ChannelInput
@onready
var _connect_button: Button = $Connect


## Twitch channel input value
var twitch_channel: String:
	get:
		return _channel_input.text.strip_escapes().replace(" ", "")
	set(value):
		_channel_input.text = value


func _ready():
	TwitchManager.get_user_completed.connect(self._on_twitch_manager_get_user_completed)


## Set if twitch channel can be editable or not
func set_disable_input(disabled: bool):
	_channel_input.editable = not disabled


func _on_connect_pressed():
	_channel_input.editable = false
	_connect_button.disabled = true
	_connect_button.text = "Checking..."
	TwitchManager.try_channel_exist(twitch_channel)


func _on_twitch_manager_get_user_completed(result: bool):
	_channel_input.editable = true
	_connect_button.disabled = false

	if result:
		GameSettings.twitch_channel = twitch_channel
		GameSettings.save_data()
		_connect_button.text = "Connect"
		channel_connect.emit()
	else:
		_connect_button.text = "Try again! :("
