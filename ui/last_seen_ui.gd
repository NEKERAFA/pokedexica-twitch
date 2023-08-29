class_name LastSeenUI
extends Control
## Shows maximun entry in pokedex
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _last_seen_panel = $LastSeenPanel
@onready
var _pokemon_seen_label: Label = $LastSeenPanel/LastSeenContainer/PokemonContainer/Pokemon
@onready
var _user_name_label: Label = $LastSeenPanel/LastSeenContainer/UsernameContainer/Username


func set_last_pokemon_seen(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	_last_seen_panel.show()
	_pokemon_seen_label.text = pokemon_name
	_pokemon_seen_label.add_theme_color_override("font_color", pokemon_color)
	_user_name_label.text = user_name
	_user_name_label.add_theme_color_override("font_color", user_color)
