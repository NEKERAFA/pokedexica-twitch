class_name FooterUI
extends Control
## Shows current pokemon found, or print message to user that make a failure
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


const FOUND_BY = " found by "
const NOT_FOUND = ", it's not that pokémon"
const USER_REPEAT = ", you wrote last pokémon"


@onready
var _footer_panel = $FooterPanel
@onready
var _first_label: Label = $FooterPanel/TextContainer/FirstLabel
@onready
var _second_label: Label = $FooterPanel/TextContainer/SecondLabel
@onready
var _third_label: Label = $FooterPanel/TextContainer/ThirdLabel


func set_pokemon_found(pokemon_name: String, pokemon_entry_number: int, pokemon_color: Color, user_name: String, user_color: Color):
	_first_label.text = "%s #%04d" % [pokemon_name, pokemon_entry_number]
	_first_label.add_theme_color_override("font_color", pokemon_color)
	_second_label.text = FOUND_BY
	_third_label.text = user_name
	_third_label.add_theme_color_override("font_color", user_color)
	_third_label.show()
	
	if not _footer_panel.visible:
		_footer_panel.show()


func set_pokemon_not_found(user_name: String, user_color: Color):
	_first_label.text = user_name
	_first_label.add_theme_color_override("font_color", user_color)
	_second_label.text = NOT_FOUND
	_third_label.hide()
	
	if not _footer_panel.visible:
		_footer_panel.show()


func set_user_repeat_pokemon(user_name: String, user_color: Color):
	_first_label.text = user_name
	_first_label.add_theme_color_override("font_color", user_color)
	_second_label.text = USER_REPEAT
	_third_label.hide()
	
	if not _footer_panel.visible:
		_footer_panel.show()
