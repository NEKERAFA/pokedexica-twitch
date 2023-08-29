@tool
class_name HeaderUI
extends Control


signal button_pressed


@onready
var _title_label: Label = $Background/Title
@onready
var _button: TextureButton = $Background/Button


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
