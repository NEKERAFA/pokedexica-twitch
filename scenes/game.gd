extends Control
## Controls game loop
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


@onready
var last_pokemon_panel: PanelContainer = $LastSeenPanel
@onready
var last_pokemon_label: Label = $LastSeenPanel/VBoxContainer/LastSeenContainer/PokemonSeen
@onready
var last_user_label: Label = $LastSeenPanel/VBoxContainer/UsernameContainer/Username
@onready
var pokemon_artwork_texture: TextureRect = $PokemonArtworkPanel/PokemonArtwork
@onready
var spinner_texture: TextureRect = $PokemonArtworkPanel/CenterContainer/Spinner
@onready
var footer_panel: PanelContainer = $FooterPanel
@onready
var pokemon_found_label: Label = $FooterPanel/HBoxContainer/PokemonFound
@onready
var user_name_label: Label = $FooterPanel/HBoxContainer/Username


var last_pokemon_entry = 0
var last_user_name = null


func _ready():
	ChatManager.pokemon_entered.connect(self._on_pokemon_manager_pokemon_found)
	PokeCache.cache_loaded.connect(self._on_poke_cache_loaded)
	PokeCache.added_pokemon_sprite.connect(self._on_poke_cache_added_pokemon_sprite)

	if GameSettings.last_pokemon_entry > 0:
		_set_last_seen_panel()
	
	if PokeCache.is_cache_loaded:
		_on_poke_cache_loaded(true)


func _set_last_seen_panel():
	last_pokemon_label.text = "%s #%04d" % [GameSettings.last_pokemon_name, GameSettings.last_pokemon_entry]
	last_pokemon_label.add_theme_color_override("font_color", GameSettings.last_pokemon_color)
	last_user_label.text = GameSettings.last_pokemon_by
	last_user_label.add_theme_color_override("font_color", GameSettings.last_user_color)
	last_pokemon_panel.show()


func _on_poke_cache_loaded(success):
	if success:
		var pokemon_key = PokeCache.get_pokemon_key_by_entry_number(1)
		_set_pokemon_sprite_texture(pokemon_key)


func _on_poke_cache_added_pokemon_sprite(pokemon_key: String):
	var pokemon_entry = PokeCache.get_pokedex_entry_number(pokemon_key)
	if pokemon_entry == last_pokemon_entry + 1:
		_set_pokemon_sprite_texture(pokemon_key)


func _set_pokemon_sprite_texture(pokemon_key: String):
	var pokemon_sprite = await PokeCache.get_pokemon_sprite_texture(pokemon_key)
	if pokemon_sprite != null:
		spinner_texture.hide()

		pokemon_artwork_texture.texture = pokemon_sprite
		pokemon_artwork_texture.show()
		
		if (last_pokemon_entry >= GameSettings.last_pokemon_entry):
			pokemon_artwork_texture.modulate = Color.BLACK
		else:
			pokemon_artwork_texture.modulate = Color.hex(0x88888888)


func _on_settings_button_pressed():
	pass


func _on_pokemon_manager_pokemon_found(pokemon_key: String, user_name: String, user_color: Color):
	var pokemon_entry = PokeCache.get_pokedex_entry_number(pokemon_key)
	
	if last_pokemon_entry + 1 == pokemon_entry: #and user_name != last_user_name:
		if last_pokemon_entry + 1 < PokeCache.size():
			_on_next_pokemon_found(pokemon_key, pokemon_entry, user_name, user_color)
		else:
			_on_reset_pokemon()
	else:
		_on_reset_pokemon()


func _on_next_pokemon_found(pokemon_key: String, pokemon_entry: int, user_name: String, user_color: Color):
	last_user_name = user_name

	var pokemon_name = await PokeCache.get_pokemon_name(pokemon_key, "en", pokemon_key)
	var pokemon_color = await PokeCache.get_pokemon_color(pokemon_key, Color.BLACK)
	
	_set_pokemon_found_panel(pokemon_name, pokemon_color, user_name, user_color)
	
	if GameSettings.last_pokemon_entry + 1 == pokemon_entry:
		_save_last_pokemon_found(pokemon_name, pokemon_color, user_name, user_color)
		_set_last_seen_panel()
	
	_move_next_pokemon()


func _set_pokemon_found_panel(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	pokemon_found_label.text = "%s #%04d" % [pokemon_name, last_pokemon_entry + 1]
	pokemon_found_label.add_theme_color_override("font_color", pokemon_color)
	user_name_label.text = user_name
	user_name_label.add_theme_color_override("font_color", user_color)
	footer_panel.show()


func _save_last_pokemon_found(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	GameSettings.last_pokemon_entry = last_pokemon_entry + 1
	
	GameSettings.last_pokemon_name = pokemon_name
	GameSettings.last_pokemon_color = pokemon_color
	GameSettings.last_pokemon_by = user_name
	GameSettings.last_user_color = user_color
	GameSettings.save_data()


func _move_next_pokemon():
	last_pokemon_entry += 1
	var pokemon_key = PokeCache.get_pokemon_key_by_entry_number(last_pokemon_entry + 1)
	spinner_texture.show()
	_set_pokemon_sprite_texture(pokemon_key)


func _on_reset_pokemon():
	last_pokemon_entry = 0
	last_user_name = null
	var pokemon_key = PokeCache.get_pokemon_key_by_entry_number(1)
	spinner_texture.show()
	_set_pokemon_sprite_texture(pokemon_key)
