class_name PokemonSprite
extends Control
## Shows pokemon sprite
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _pokemon_sprite_rect = $SpritePanel/Sprite
@onready
var _spinner_container = $SpritePanel/CenterContainer


func set_pokemon_sprite_by_entry_number(pokemon_entry_number: int):
	var pokemon_key = PokeCache.get_pokemon_key_by_entry_number(pokemon_entry_number)
	set_pokemon_sprite_by_key(pokemon_key, pokemon_entry_number > GameSettings.last_pokemon_entry)


func set_pokemon_sprite_by_key(pokemon_key: String, last_pokemon: bool):
	set_loading(true)

	var pokemon_sprite = await PokeCache.get_pokemon_sprite_texture(pokemon_key)
	if pokemon_sprite != null:
		set_loading(false)

		_pokemon_sprite_rect.texture = pokemon_sprite
		if last_pokemon:
			_pokemon_sprite_rect.modulate = Color.BLACK
		else:
			_pokemon_sprite_rect.modulate = Color.hex(0x88888888)


func set_loading(loading: bool):
	if loading:
		_spinner_container.show()
		_pokemon_sprite_rect.hide()
	else:
		_spinner_container.hide()
		_pokemon_sprite_rect.show()
