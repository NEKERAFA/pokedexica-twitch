class_name PokeRequest
extends Node
## Controls Poke API requests
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


const POKEAPI_URL: String = "https://pokeapi.co/api"
const POKEAPI_VERSION: String = "v2"

const POKEAPI_POKEDEX: String = "pokedex"
const POKEAPI_POKEMON_SPECIES: String = "pokemon_species"
const POKEAPI_POKEMON: String = "pokemon"

const POKEDEX_NAME: String = "national"

signal request_completed(success: bool)


enum RequestType { POKEDEX, POKEMON_SPECIES, POKEMON }


func request(type: RequestType, resource = null):
	if type == RequestType.POKEDEX:
		return _make_pokedex_request()
	elif type == RequestType.POKEMON_SPECIES:
		if resource != null:
			return _make_pokemon_species_request(resource)
		else:
			push_error("resource cannot be null")
			return ERR_INVALID_PARAMETER
	elif type == RequestType.POKEMON:
		if resource != null:
			return _make_pokemon_request(resource)
		else:
			push_error("resource cannot be null")
			return ERR_INVALID_PARAMETER
	else:
		push_error("request type {0} not implemented" % type)
		return ERR_METHOD_NOT_FOUND


func _make_pokedex_request():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_pokedex_request_completed)

	var pokedex_url = PokeRequest.get_pokeapi_url("pokedex", POKEDEX_NAME)
	var error = http_request.request(pokedex_url)
	if error != OK:
		push_error("Cannot connect to pokeapi")
	else:
		print("pokedex request: %s" % pokedex_url)
	return error


func _on_pokedex_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Cannot get pokedex response")
	else:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			var response = json.get_data()
			for entry in response.get("pokemon_entries", []):
				PokeCache.set_pokedex_entry(entry.pokemon_species.name, entry.entry_number, entry.pokemon_species.url)
			
			request_completed.emit(true)
		else:
			push_error("Error on parse pokedex response: line {0}: {1}" % [json.get_error_line(), json.get_error_message()])
			request_completed.emit(false)


func _make_pokemon_species_request(resource):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_pokemon_species_request_completed)

	var pokemon_species_url = PokeCache.get_pokemon_species_url(resource)
	var error = http_request.request(pokemon_species_url)
	if error != OK:
		push_error("Cannot connect to pokeapi")
	else:
		print("pokemon species request: %s" % pokemon_species_url)
	return error


func _on_pokemon_species_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Cannot get pokemon_species response")
	else:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			var response = json.get_data()
			var pokemon_names = {}
			for entry in response.names:
				if entry.language.name == "en":
					pokemon_names[entry.language.name] = entry.name
			var pokemon_color = Globals.get_pokemon_color(response.color.name)

			PokeCache.set_pokemon_species(response.name, pokemon_names, pokemon_color)
			request_completed.emit(true)
		else:
			push_error("Error on parse pokemon_species response: line {0}: {1}" % [json.get_error_line(), json.get_error_message()])
			request_completed.emit(false)


func _make_pokemon_request(resource):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_pokemon_request_completed)

	var pokemon_url = PokeRequest.get_pokeapi_url("pokemon", resource)
	var error = http_request.request(pokemon_url)
	if error != OK:
		push_error("Cannot connect to pokeapi")
	else:
		print("pokemon request: %s" % pokemon_url)
	return error


func _on_pokemon_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Cannot get pokemon response")
	else:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			var response = json.get_data()
			var pokemon_sprites = {
				"official-artwork" = {
					"url" = response.sprites.other["official-artwork"].front_default
				}
			}
			
			PokeCache.set_pokemon_sprites(response.name, pokemon_sprites)
			request_completed.emit(true)
		else:
			push_error("Error on parse pokemon response: line {0}: {1}" % [json.get_error_line(), json.get_error_message()])
			request_completed.emit(false)


static func get_pokeapi_url(resource, resource_name):
	return POKEAPI_URL.path_join(POKEAPI_VERSION).path_join(resource).path_join(resource_name)
