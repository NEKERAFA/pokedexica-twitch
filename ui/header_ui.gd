@tool
class_name HeaderUI
extends TextureRect


signal button_pressed


@onready
var title_label: Label = $Title
@onready
var button: TextureButton = $Button


@export
var title: String = "Title"


@export_group("Textures")
@export
var button_normal: Texture2D
@export
var button_hover: Texture2D


func _process(_delta):
	if title_label.text != title:
		title_label.text = title

	if button.texture_normal != button_normal:
		button.texture_normal = button_normal

	if button.texture_hover != button_hover:
		button.texture_hover != button_hover


func _on_button_pressed():
	button_pressed.emit()
