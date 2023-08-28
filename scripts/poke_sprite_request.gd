class_name PokeSpriteRequest
extends Node


var _pokemon_key
var _sprite


func request(pokemon_key, sprite):
	_pokemon_key = pokemon_key
	_sprite = sprite
	
	var pokemon_entry = PokeCache.get_pokedex_entry_number(_pokemon_key)
	var sprite_path = PokeCache.get_pokemon_sprite_path(pokemon_entry, _sprite)
	if FileAccess.file_exists(sprite_path):
		return _get_sprite_from_disk(sprite_path)
	else:
		return _make_sprite_request()


func _get_sprite_from_disk(sprite_path: String):
	var image = Image.new()
	var result = image.load(sprite_path)

	if result == OK:
		print("Loaded pokemon sprite from %s" % sprite_path)
		var sprite_texture = ImageTexture.create_from_image(image)
		PokeCache.set_pokemon_sprite_texture(_pokemon_key, _sprite, sprite_texture)
	else:
		push_error("cannot load png image")

	return result


func _make_sprite_request():
	var sprite_url = PokeCache.get_pokemon_sprite_url(_pokemon_key, _sprite)
	var http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_request_completed)
	add_child(http_request)
	
	var error = http_request.request(sprite_url)
	if error != OK:
		push_error("Cannot connect to %s" % sprite_url)
	else:
		print("pokemon sprite request: %s" % sprite_url)
	return error


func _on_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Cannot get pokemon sprite response")
	else:
		var pokemon_entry = PokeCache.get_pokedex_entry_number(_pokemon_key)
		var sprite_path = PokeCache.get_pokemon_sprite_path(pokemon_entry, _sprite)
		if not FileAccess.file_exists(sprite_path):
			if not DirAccess.dir_exists_absolute(Globals.SPRITES_PATH.path_join(_sprite)):
				DirAccess.make_dir_recursive_absolute(Globals.SPRITES_PATH.path_join(_sprite))
			
			var file = FileAccess.open(sprite_path, FileAccess.WRITE)
			if file != null:
				file.store_buffer(body)
				file.flush()
			else:
				push_error("cannot open %s: %s" % [sprite_path, FileAccess.get_open_error()])
		
		var image = Image.new()
		if image.load_png_from_buffer(body) == OK:
			var sprite_texture = ImageTexture.create_from_image(image)
			PokeCache.set_pokemon_sprite_texture(_pokemon_key, _sprite, sprite_texture)
		else:
			push_error("cannot load png image")
