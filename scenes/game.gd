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


func _ready():
	if GameSettings.last_pokemon_entry > 0:
		_set_last_seen_panel()

	var pokemon_manager = $"/root/TwitchManager"
	pokemon_manager.connect("ManagerReady", self._on_pokemon_manager_manager_ready)
	pokemon_manager.connect("PokemonFound", self._on_pokemon_manager_pokemon_found)
	pokemon_manager.connect("PokemonNotFound", self._on_pokemon_manager_pokemon_not_found)
	pokemon_manager.connect("PokemonArtworkDownloaded", self._on_pokemon_manager_pokemon_artwork_downloaded)
	
	if pokemon_manager.isManagerReady:
		_set_pokemon_artwork()


func _set_last_seen_panel():
	last_pokemon_label.text = "%s #%04d" % [GameSettings.last_pokemon_name, GameSettings.last_pokemon_entry]
	last_pokemon_label.add_theme_color_override("font_color", GameSettings.last_pokemon_color)
	last_user_label.text = GameSettings.last_pokemon_by
	last_user_label.add_theme_color_override("font_color", GameSettings.last_user_color)
	last_pokemon_panel.show()


func _set_pokemon_artwork():
	var pokemon_name: String = PokemonCache.GetPokemonName(Globals.current_pokemon_entry + 1)
	var pokemon_artwork: Texture = PokemonCache.GetPokemonArtwork(pokemon_name)
	if pokemon_artwork != null:
		_set_pokemon_artwork_texture(pokemon_artwork)


func _set_pokemon_artwork_texture(pokemon_artwork: Texture):
	pokemon_artwork_texture.texture = pokemon_artwork
	pokemon_artwork_texture.show()
	spinner_texture.hide()
	
	if (Globals.current_pokemon_entry >= GameSettings.last_pokemon_entry):
		pokemon_artwork_texture.modulate = Color.BLACK
	else:
		pokemon_artwork_texture.modulate = Color.hex(0x88888888)


func _on_settings_button_pressed():
	var _settings_scene: PackedScene = load("res://scenes/settings.tscn")
	get_tree().change_scene_to_packed(_settings_scene)


func _on_pokemon_manager_manager_ready():
	_set_pokemon_artwork()


func _on_pokemon_manager_pokemon_found(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	Globals.pokemon_found()

	pokemon_found_label.text = "%s #%04d" % [pokemon_name, Globals.current_pokemon_entry]
	pokemon_found_label.add_theme_color_override("font_color", pokemon_color)
	user_name_label.text = user_name
	user_name_label.add_theme_color_override("font_color", user_color)
	footer_panel.show()
	
	if (Globals.current_pokemon_entry > GameSettings.last_pokemon_entry):
		_save_last_pokemon_found(pokemon_name, pokemon_color, user_name, user_color)
		_set_last_seen_panel()

	spinner_texture.show()
	_set_pokemon_artwork()


func _save_last_pokemon_found(pokemon_name: String, pokemon_color: Color, user_name: String, user_color: Color):
	GameSettings.last_pokemon_entry = Globals.current_pokemon_entry
	GameSettings.last_pokemon_name = pokemon_name
	GameSettings.last_pokemon_color = pokemon_color
	GameSettings.last_pokemon_by = user_name
	GameSettings.last_user_color = user_color
	GameSettings.save_data()


func _on_pokemon_manager_pokemon_not_found():
	Globals.reset_pokedex()
	footer_panel.hide()
	spinner_texture.show()
	_set_pokemon_artwork()


func _on_pokemon_manager_pokemon_artwork_downloaded(pokemon_artwork: Texture):
	_set_pokemon_artwork_texture(pokemon_artwork)
