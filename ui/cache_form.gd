extends VBoxContainer
## Controls cache used size and clears cache
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)

@onready
var cache_label: Label = $CacheInfoContainer/CacheUsed
@onready
var timer: Timer = $Timer


func _ready():
	timer.start()
	_update_size()


func _update_size():
	cache_label.text = "Current used: %s" % String.humanize_size(_get_recursive_size(Globals.CACHE_PATH));


func _get_recursive_size(path: String):
	var files_size = 0
	
	var dir = DirAccess.open(path)
	if dir != null:
		dir.include_navigational = false
		if dir.list_dir_begin() == OK:
			var entry_name = dir.get_next()
			while entry_name != "":
				var entry_path = path.path_join(entry_name)
				if dir.current_is_dir():
					files_size += _get_recursive_size(entry_path)
				else:
					var file = FileAccess.open(entry_path, FileAccess.READ)
					if file != null:
						files_size += file.get_length()
					else:
						push_error("cannot open %s: %s" % [entry_path, FileAccess.get_open_error()])
				entry_name = dir.get_next()
		else:
			push_error("cannot list %s" % Globals.CACHE_PATH)
		dir.list_dir_end()
	else:
		push_error("cannot open %s: %s" % [Globals.CACHE_PATH, DirAccess.get_open_error()])
	
	return files_size


func _on_timer_timeout():
	_update_size()


func _on_clear_cache_pressed():
	_remove_recursive(Globals.CACHE_PATH, false)
	_update_size()


func _remove_recursive(path: String, remove_entry: bool):
	var entries = _get_entries(path)
	for entry in entries:
		var entry_path = path.path_join(entry.name)
		if entry.is_directory:
			_remove_recursive(entry_path, true)
		elif entry.name != "pokedex.json":
			if DirAccess.remove_absolute(ProjectSettings.globalize_path(entry_path)) == OK:
				print("removed %s" % entry_path)
			else:
				push_error("cannot remove %s" % entry_path)
	
	if remove_entry:
		if DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK:
			print("removed %s" % path)
		else:
			push_error("cannot remove %s" % path)


func _get_entries(path: String):
	var entries = []
	var dir = DirAccess.open(path)
	if dir != null:
		dir.include_navigational = false
		if dir.list_dir_begin() == OK:
			var entry = dir.get_next()
			while entry != "":
				entries.append({
					"name": entry,
					"is_directory": dir.current_is_dir()
				})
				entry = dir.get_next()
		else:
			push_error("cannot list %s" % Globals.CACHE_PATH)
		dir.list_dir_end()
	else:
		push_error("cannot open %s: %s" % [path, DirAccess.get_open_error()])

	return entries
