extends Control
## Controls game loop
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


func _on_settings_button_pressed():
	var _settings_scene: PackedScene = load("res://scenes/settings.tscn")
	get_tree().change_scene_to_packed(_settings_scene)
