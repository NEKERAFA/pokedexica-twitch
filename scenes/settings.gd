extends Control
## Save settings and check third-party licenses
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _twitch_settings: TwitchChannelForm = $SettingContainer/VBoxContainer/TwitchSettings
@onready
var _game_version_lbl: Label = $GameInfoContainer/GameVersion


func _ready():
	_game_version_lbl.text = "Pokédexica v%s" % Globals.VERSION
	if GameSettings.config_exists:
		_twitch_settings.twitch_channel = GameSettings.twitch_channel


func _on_other_licenses_pressed():
	var third_party_popup = $ThirdPartyPopup
	third_party_popup.show()


func _on_third_party_popup_close_popup():
	var third_party_popup = $ThirdPartyPopup
	third_party_popup.hide()


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta)


func _on_header_ui_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
