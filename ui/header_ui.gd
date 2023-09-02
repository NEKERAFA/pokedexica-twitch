@tool
class_name HeaderUI
extends Control
## Shows a header with a button
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal button_pressed


@onready
var _title_label: Label = $Title
@onready
var _button: TextureButton = $Button


@export
var title: String = "Title"


@export_group("Textures")
@export
var button_normal: Texture2D
@export
var button_hover: Texture2D


func _process(_delta):
	if _title_label.text != title:
		_title_label.text = title

	if _button.texture_normal != button_normal:
		_button.texture_normal = button_normal

	if _button.texture_hover != button_hover:
		_button.texture_hover = button_hover


func _on_button_pressed():
	button_pressed.emit()
