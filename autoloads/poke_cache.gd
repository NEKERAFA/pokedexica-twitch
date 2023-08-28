extends Node
## Save cache information about PokeAPI request
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal cache_loaded
signal added_pokemon_sprite(pokemon_key)


# pokedex structure:
# {
#   pokemon_name = {
#     "entry" = pokedex_entry_number,
#     "pokemon_species" = {
#       "url" = pokemon_species_url,
#       "names" = {
#          "en" = pokemon_species_english_name,
#          ...
#       },
#       "color" = pokemon_species_color
#     }
#     "pokemon" =  {
#       "sprites" = {
#         "official-artwork" = {
#           "url" = pokemon_artwork_official-artwork_front_url,
#           "texture" = pokemon_artwork_official-artwork_image_front_texture
#         },
#         ...
#       }
#     }
#   }
# }
var pokedex = {}
var pokedex_updated = false
var is_cache_loaded = false


#### GETTERS #######################################################################################

## Check if pokemon exists in pokedex
func has_pokemon_key(pokemon_key: String) -> bool:
	return pokedex.has(pokemon_key)


func get_pokedex_entry(pokemon_key: String, default = null):
	return pokedex.get(pokemon_key, default)


## Get the pokedex entry number of a pokemon
func get_pokedex_entry_number(pokemon_key: String, default = -1):
	var pokemon_entry = get_pokedex_entry(pokemon_key, {"entry" = default})
	return pokemon_entry.get("entry", default)


func get_pokemon_key_by_entry_number(entry_number: int):
	if entry_number > 0 and entry_number < pokedex.size():
		var pokemon_keys = pokedex.keys()
		var pokemon_keys_size = pokemon_keys.size()
		var key = 0
		while key < pokemon_keys_size and get_pokedex_entry_number(pokemon_keys[key], -1) != entry_number:
			key = key + 1
		
		return pokemon_keys[key] if key < pokemon_keys_size else null
	else:
		push_warning("entry_number must be between 0 and %d" % pokedex.size())
		return null


## Get the pokemon species of a pokemon
func get_pokemon_species(pokemon_key: String, default = null):
	var pokedex_entry = get_pokedex_entry(pokemon_key, {"pokemon_species" = default})
	return pokedex_entry.get("pokemon_species", default)


## Get the pokemon species url of a pokemon
func get_pokemon_species_url(pokemon_key: String, default = null):
	var pokemon_species = get_pokemon_species(pokemon_key, {"url" = default})
	return pokemon_species.get("url", default)


func has_pokemon_names(pokemon_key: String) -> bool:
	var pokemon_species = get_pokemon_species(pokemon_key, {})
	return pokemon_species.has("names")


func has_pokemon_color(pokemon_key: String) -> bool:
	var pokemon_species = get_pokemon_species(pokemon_key, {})
	return pokemon_species.has("color")


## Check if there is info of pokemon species
func has_pokemon_species_info(pokemon_key: String) -> bool:
	return has_pokemon_names(pokemon_key) && has_pokemon_color(pokemon_key)


## Get the pokemon real names of a pokemon
func get_pokemon_names(pokemon_key: String, default = {}):
	if not has_pokemon_names(pokemon_key):
		await _make_pokemon_species_request(pokemon_key)
	
	var pokemon_species = get_pokemon_species(pokemon_key, {"names" = default})
	return pokemon_species.get("names", default)


## Get the pokemon real names of a pokemon
func get_pokemon_name(pokemon_key: String, lang = "en", default = null):
	var pokemon_name = await get_pokemon_names(pokemon_key, {})
	return pokemon_name.get(lang, default)


## Get the pokemon color of a pokemon
func get_pokemon_color(pokemon_key: String, default = null):
	if not has_pokemon_color(pokemon_key):
		await _make_pokemon_species_request(pokemon_key)

	var pokemon_species = get_pokemon_species(pokemon_key, {"color" = default})
	return pokemon_species.get("color", default)


func has_pokemon_info(pokemon_key: String) -> bool:
	var pokemon_entry = get_pokedex_entry(pokemon_key, {})
	return pokemon_entry.has("pokemon")


func get_pokemon_info(pokemon_key: String, default = null):
	var pokemon_entry = get_pokedex_entry(pokemon_key, {"pokemon" = default})
	return pokemon_entry.get("pokemon", default)


func get_pokemon_sprites(pokemon_key: String, default = null):
	var pokemon_info = get_pokemon_info(pokemon_key, {"sprites" = default})
	return pokemon_info.get("sprites", default)


func get_pokemon_sprite(pokemon_key: String, sprite = "official-artwork", default = null):
	var pokemon_sprites = get_pokemon_sprites(pokemon_key, {})
	return pokemon_sprites.get(sprite, default)


func has_pokemon_sprite_url(pokemon_key: String, sprite = "official-artwork"):
	var pokemon_sprite = get_pokemon_sprite(pokemon_key, sprite, {})
	return pokemon_sprite.has("url")


## Get the pokemon sprite url of a pokemon
func get_pokemon_sprite_url(pokemon_key: String, sprite = "official-artwork", default = null):
	var pokemon_sprite = get_pokemon_sprite(pokemon_key, sprite, {})
	return pokemon_sprite.get("url", default)


func has_pokemon_sprite_texture(pokemon_key: String, sprite = "official-artwork"):
	var pokemon_sprite = get_pokemon_sprite(pokemon_key, sprite, {})
	return pokemon_sprite.has("texture")


## Get the pokemon sprite of a pokemon
func get_pokemon_sprite_texture(pokemon_key: String, sprite = "official-artwork", default = null):
	if not has_pokemon_sprite_url(pokemon_key, sprite):
		await _make_pokemon_request(pokemon_key)
	
	if not has_pokemon_sprite_texture(pokemon_key, sprite):
		_make_pokemon_sprite_request(pokemon_key, sprite)

	var pokemon_sprite = get_pokemon_sprite(pokemon_key, sprite, {})
	return pokemon_sprite.get("texture", default)


## Check if pokedex cache is empty
func is_empty() -> bool:
	return pokedex.is_empty()


## Get the number of entries in pokedex
func size() -> int:
	return pokedex.size()


#### SETTERS #######################################################################################

func set_pokedex_entry(pokemon_key: String, entry_number: int, pokemon_species_url: String):
	if not has_pokemon_key(pokemon_key):
		pokedex[pokemon_key] = {
			"entry" = entry_number,
			"pokemon_species" = {
				"url" = pokemon_species_url
			}
		}
	else:
		push_warning("pokemon %s is cached" % pokemon_key)


## Set a new pokemon species data onto cache
func set_pokemon_species(pokemon_key: String, names: Dictionary, color: Color):
	if has_pokemon_key(pokemon_key):
		pokedex[pokemon_key]["pokemon_species"]["names"] = names
		pokedex[pokemon_key]["pokemon_species"]["color"] = color
		pokedex_updated = true
	else:
		push_error("pokemon %s not cached" % pokemon_key)


## Set a new pokemon sprites onto cache
func set_pokemon_sprites(pokemon_key: String, sprites: Dictionary):
	if has_pokemon_key(pokemon_key):
		if not has_pokemon_info(pokemon_key):
			pokedex[pokemon_key]["pokemon"] = {}
		
		pokedex[pokemon_key]["pokemon"]["sprites"] = sprites
		pokedex_updated = true
	else:
		push_error("pokemon %s not cached" % pokemon_key)


## Set a new pokemon sprite texture onto cache
func set_pokemon_sprite_texture(pokemon_key: String, sprite: String, texture: ImageTexture):
	if has_pokemon_sprite_url(pokemon_key, sprite):
		pokedex[pokemon_key]["pokemon"]["sprites"][sprite]["texture"] = texture
		added_pokemon_sprite.emit(pokemon_key)
	else:
		push_error("pokemon %s not cached" % pokemon_key)


#### STATIC FUNCTIONS ##############################################################################


## Get the full path to pokemon artwork file
static func get_pokemon_sprite_path(pokemon_entry: int, sprite: String = "official-artwork"):
	return Globals.SPRITES_PATH.path_join(sprite).path_join("%04d.png" % pokemon_entry)


## Escape a pokemon name as pokemon key
static func get_pokemon_key(pokemon_name: String):
	return pokemon_name.replace(" ",  "-").replace("'", "").replace(".", "").to_lower()


#### NODE FUNCTIONS ################################################################################

func _ready():
	if FileAccess.file_exists(Globals.POKEDEX_PATH):
		_load_cache_file()
	else:
		await _make_pokedex_request()


func _load_cache_file():
	var file = FileAccess.open(Globals.POKEDEX_PATH, FileAccess.READ)
	if file != null:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			if json.data is Array:
				_load_pokedex_from_json(json.data, 1)
			elif json.data is Dictionary:
				_load_pokedex_from_json(json.data, json.data.get("version", 0))
			cache_loaded.emit(true)
			is_cache_loaded = true
		else:
			push_error("error in %s:%s: %s" % [Globals.POKEDEX_PATH, json.get_error_line(), json.get_error_message()])
			cache_loaded.emit(false)
	else:
		push_error("cannot open %s: %s" % [Globals.POKEDEX_PATH, FileAccess.get_open_error()])
		cache_loaded.emit(false)


func _load_pokedex_from_json(data, version: int):
	if version == 1:
		for entry in data:
			var pokemon_key = entry["key"]
			pokedex[pokemon_key] = _load_entry_from_v1(entry)
	elif version == 2:
		for entry in data.get("list", []):
			var pokemon_key = entry["key"]
			pokedex[pokemon_key] = _load_entry_from_v2(entry)


func _load_entry_from_v1(entry):
	var pokemon_key = entry["key"]

	return {
		"entry" = entry["entry_number"],
		"pokemon_species" = {
			"url" = PokeRequest.get_pokeapi_url("pokemon-species", pokemon_key),
			"names" = {
				"en" = entry["name"]
			},
			"color" = Color.html(entry["type_color"])
		}
	}


func _load_entry_from_v2(entry):
	var data = {
		"entry" = entry["entry"],
		"pokemon_species" = {
			"url" = entry["pokemon_species"]["url"]
		}
	}
	
	if entry["pokemon_species"].has("names") and entry["pokemon_species"].has("color"):
		data["pokemon_species"]["names"] = entry["pokemon_species"]["names"]
		data["pokemon_species"]["color"] = Color.html(entry["pokemon_species"]["color"])
	
	if entry.has("pokemon"):
		data["pokemon"] = {
			"sprites" = {
				"official-artwork" = {
					"url" = entry["pokemon"]["sprites"]["official-artwork"]["url"]
				}
			}
		}
	
	return data
 

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and pokedex_updated:
		_save_cache_to_disk()


func _save_cache_to_disk():
	if not DirAccess.dir_exists_absolute(Globals.CACHE_PATH):
		DirAccess.make_dir_absolute(Globals.CACHE_PATH)

	var file = FileAccess.open(Globals.POKEDEX_PATH, FileAccess.WRITE)
	if file != null:
		var data = { "version" = 2, "list" = pokedex.keys().map(_get_entry_to_data) }
		file.store_string(JSON.stringify(data))
		file.flush()
	else:
		push_error("cannot open %s: %s" % [Globals.POKEDEX_PATH, FileAccess.get_open_error()])


func _get_entry_to_data(pokemon_key):
	var data = {
		"key" = pokemon_key,
		"entry" = pokedex[pokemon_key]["entry"],
		"pokemon_species" = {
			"url" = pokedex[pokemon_key]["pokemon_species"]["url"]
		}
	}
	
	if has_pokemon_species_info(pokemon_key):
		data["pokemon_species"]["names"] = pokedex[pokemon_key]["pokemon_species"]["names"]
		data["pokemon_species"]["color"] = pokedex[pokemon_key]["pokemon_species"]["color"].to_html(false)
	
	if has_pokemon_sprite_url(pokemon_key):
		data["pokemon"] = {
			"sprites" = {
				"official-artwork" = {
					"url" = pokedex[pokemon_key]["pokemon"]["sprites"]["official-artwork"]["url"]
				}
			}
		}

	return data


func _make_pokedex_request():
	var poke_request = PokeRequest.new()
	add_child(poke_request)

	if poke_request.request(PokeRequest.RequestType.POKEDEX) == OK:
		var result = await poke_request.request_completed
		if result:
			pokedex_updated = true
			cache_loaded.emit(true)
		else:
			push_error("cannot process request pokedex")
			cache_loaded.emit(false)
	else:
		push_error("cannot request pokedex")
		cache_loaded.emit(false)


func _make_pokemon_species_request(pokemon_key: String):
	var poke_request = PokeRequest.new()
	add_child(poke_request)

	if poke_request.request(PokeRequest.RequestType.POKEMON_SPECIES, pokemon_key) == OK:
		var result = await poke_request.request_completed
		if result:
			pokedex_updated = true
		else:
			push_error("cannot process request pokemon species")
	else:
		push_error("cannot request pokemon species")


func _make_pokemon_request(pokemon_key: String):
	var poke_request = PokeRequest.new()
	add_child(poke_request)

	if poke_request.request(PokeRequest.RequestType.POKEMON, pokemon_key) == OK:
		var result = await poke_request.request_completed
		if result:
			pokedex_updated = true
		else:
			push_error("cannot process request pokemon")
	else:
		push_error("cannot request pokemon")


func _make_pokemon_sprite_request(pokemon_key: String, sprite = 'official-artwork'):
	var poke_sprite_request = PokeSpriteRequest.new()
	add_child(poke_sprite_request)

	if poke_sprite_request.request(pokemon_key, sprite) != OK:
		push_error("cannot request pokemon sprite %s" % sprite)
