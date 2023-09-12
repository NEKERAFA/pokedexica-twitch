@tool
class_name HeaderUI
extends Control
## Shows a header with a button
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal button_pressed

var _title: String
var _button_normal: Texture2D
var _button_hover: Texture2D


@onready
var _title_label: Label = $Title
@onready
var _button: TextureButton = $Button


@export
var title: String:
	get:
		return _title
	set(value):
		_title = value

		if _title_label != null:
			_title_label.text = _title
			_title_label.notify_property_list_changed()


@export_group("Textures")
@export
var button_normal: Texture2D:
	get:
		return _button_normal
	set(value):
		_button_normal = value
		
		if _button != null:
			_button.texture_normal = _button_normal
			_button.notify_property_list_changed()

@export
var button_hover: Texture2D:
	get:
		return _button_hover
	set(value):
		_button_hover = value
		
		if _button != null:
			_button.texture_hover = _button_hover
			_button.notify_property_list_changed()


func _ready():
	_title_label.text = _title
	_button.texture_normal = _button_normal
	_button.texture_hover = _button_hover


func _on_button_pressed():
	button_pressed.emit()
