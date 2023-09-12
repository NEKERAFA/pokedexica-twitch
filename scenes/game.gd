extends Control
## Controls game loop
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var _last_seen: LastSeenUI = $LastSeenUI
@onready
var _pokemon_sprite: PokemonSprite = $PokemonSprite
@onready
var _footer: FooterUI = $FooterUI


var _last_pokemon_entry = 0
var _last_user_name = null
var _next_pokemon_entry:
	get:
		return _last_pokemon_entry + 1


func _ready():
	ChatManager.pokemon_entered.connect(self._on_chat_manager_pokemon_found)
	PokeCache.cache_loaded.connect(self._on_poke_cache_loaded)
	PokeCache.added_pokemon_sprite.connect(self._on_poke_cache_added_pokemon_sprite)

	if GameSettings.last_pokemon_entry > 0:
		_set_last_seen_panel()
	
	if PokeCache.is_cache_loaded:
		_on_poke_cache_loaded(true)


func _set_last_seen_panel():
	var pokemon_name = "%s #%04d" % [GameSettings.last_pokemon_name, GameSettings.last_pokemon_entry]
	var pokemon_color = GameSettings.last_pokemon_color
	var user_name = GameSettings.last_user_name
	var user_color = GameSettings.last_user_color
	_last_seen.set_last_pokemon_seen(pokemon_name, pokemon_color, user_name, user_color)


func _on_poke_cache_loaded(success):
	if success:
		_pokemon_sprite.set_pokemon_sprite_by_entry_number(_next_pokemon_entry)


func _on_poke_cache_added_pokemon_sprite(pokemon_key: String):
	var pokemon_entry_number = PokeCache.get_pokedex_entry_number(pokemon_key)
	if pokemon_entry_number == _next_pokemon_entry:
		_pokemon_sprite.set_pokemon_sprite_by_key(pokemon_key, pokemon_entry_number > GameSettings.last_pokemon_entry)


func _on_chat_manager_pokemon_found(pokemon_key: String, user_name: String, user_color: Color):
	var pokemon_entry_number = PokeCache.get_pokedex_entry_number(pokemon_key)
	
	if _next_pokemon_entry == pokemon_entry_number:
		if user_name == _last_user_name:
			_footer.set_user_repeat_pokemon(user_name, user_color)
		else:
			if _next_pokemon_entry < PokeCache.size():
				_on_next_pokemon_found(pokemon_key, pokemon_entry_number, user_name, user_color)
			else:
				_set_pokemon_found_panel(pokemon_key, pokemon_entry_number, user_name, user_color)
				_on_reset_pokemon(true)
	else:
		_footer.set_pokemon_not_found(user_name, user_color)
		_on_reset_pokemon(false)


func _on_next_pokemon_found(pokemon_key: String, pokemon_entry_number: int, user_name: String, user_color: Color):
	_last_user_name = user_name
	_set_pokemon_found_panel(pokemon_key, pokemon_entry_number, user_name, user_color)
	
	if GameSettings.last_pokemon_entry + 1 == pokemon_entry_number:
		var pokemon_name = await PokeCache.get_pokemon_name(pokemon_key, "en", pokemon_key)
		var pokemon_color = await PokeCache.get_pokemon_color(pokemon_key, Color.BLACK)
		_save_last_pokemon_found(pokemon_name, pokemon_color, user_name, user_color)
		_set_last_seen_panel()
	
	_move_next_pokemon()


func _set_pokemon_found_panel(pokemon_key: String, pokemon_entry_number: int, user_name: String, user_color: Color):
	var pokemon_name = await PokeCache.get_pokemon_name(pokemon_key, "en", pokemon_key)
	var pokemon_color = await PokeCache.get_pokemon_color(pokemon_key, Color.BLACK)
	_footer.set_pokemon_found(pokemon_name, pokemon_entry_number, pokemon_color, user_name, user_color)


func _save_last_pokemon_found(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	GameSettings.last_pokemon_entry = _next_pokemon_entry
	GameSettings.last_pokemon_name = pokemon_name
	GameSettings.last_pokemon_color = pokemon_color
	GameSettings.last_user_name = user_name
	GameSettings.last_user_color = user_color
	GameSettings.save_data()


func _move_next_pokemon():
	_last_pokemon_entry += 1
	_pokemon_sprite.set_pokemon_sprite_by_entry_number(_next_pokemon_entry)


func _on_reset_pokemon(last_pokemon: bool):
	_last_pokemon_entry = 0
	_last_user_name = null
	_pokemon_sprite.set_pokemon_sprite_by_entry_number(_next_pokemon_entry)


func _on_header_ui_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
