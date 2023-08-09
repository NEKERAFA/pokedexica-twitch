extends Node
## General constanst and utilities
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


const VERSION: String = "0.6.0"


const CACHE_PATH: String = "user://cache"


var poke_colors: Dictionary = {
	"black": Color.BLACK,
	"blue": Color.hex(0x4080FF),
	"brown": Color.SADDLE_BROWN,
	"gray": Color.hex(0x808898),
	"green": Color.LIME_GREEN,
	"pink": Color.PINK,
	"purple": Color.hex(0x8040FF),
	"red": Color.ORANGE_RED,
	"white": Color.hex(0xF0F0F8),
	"yellow": Color.GOLD
}


var current_pokemon_entry: int = 0


func get_pokemon_color(color_name: String):
	return poke_colors[color_name.to_lower()]


func pokemon_found():
	current_pokemon_entry += 1
	return current_pokemon_entry


func reset_pokedex():
	current_pokemon_entry = 0
