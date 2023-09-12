extends Control
## Represents main scene
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)

@onready
var _header: HeaderUI = $Header
@onready
var _game_scene = $Game
@onready
var _settings_background = $SettingsBackground
@onready
var _settings_scene = $Settings
@onready
var _third_party_popup = $ThirdPartyPopup


@export
var button_settings: Texture2D
@export
var button_settings_hover: Texture2D
@export
var button_back: Texture2D
@export
var button_back_hover: Texture2D


enum Scenes { GAME, SETTINGS }
var _current_scene = Scenes.GAME
var _current_tween: Tween


var _animation_time = 0.2


func _ready():
	_set_game_header()


func _on_header_button_pressed():
	if _current_tween:
		_current_tween.kill()
	
	match  _current_scene:
		Scenes.GAME:
			_current_scene = Scenes.SETTINGS
			_show_settings()
		Scenes.SETTINGS:
			_current_scene = Scenes.GAME
			_hide_settings()


func _hide_settings():
	# Change header values
	_set_game_header()
	
	# Create animations
	var _current_tween = create_tween().set_parallel()
	_current_tween.tween_property(_settings_scene, "anchor_left", -1, _animation_time).set_trans(Tween.TRANS_QUAD)
	_current_tween.tween_property(_settings_scene, "anchor_right", 0, _animation_time).set_trans(Tween.TRANS_QUAD)
	_settings_background.modulate = Color.WHITE
	_current_tween.tween_property(_settings_background, "modulate", Color(1, 1, 1, 0), _animation_time / 2.0).set_trans(Tween.TRANS_QUAD)


func _show_settings():
	# Change header values
	_set_settings_header()
	
	# Create animations
	var _current_tween = create_tween().set_parallel()
	_current_tween.tween_property(_settings_scene, "anchor_left", 0, _animation_time).set_trans(Tween.TRANS_QUAD)
	_current_tween.tween_property(_settings_scene, "anchor_right", 1, _animation_time).set_trans(Tween.TRANS_QUAD)
	_settings_background.modulate = Color(1, 1, 1, 0)
	_current_tween.tween_property(_settings_background, "modulate", Color.WHITE, _animation_time / 2.0).set_trans(Tween.TRANS_QUAD)


func _set_settings_header():
	_header.title = "Settings"
	_header.button_normal = button_back
	_header.button_hover = button_back_hover


func _set_game_header():
	_header.title = "Pokédexica"
	_header.button_normal = button_settings
	_header.button_hover = button_settings_hover


func _on_settings_show_third_party():
	_third_party_popup.show()
