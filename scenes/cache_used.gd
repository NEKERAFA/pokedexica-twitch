extends Label
## Controls cache used size
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)

@onready
var timer: Timer = $"./Timer"


func _ready():
	timer.start()


func update_time():
	timer.start(5)
	text = "Current used: %s" % String.humanize_size(PokemonCache.GetCacheSize());


func _on_timer_timeout():
	update_time()
