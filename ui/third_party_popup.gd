extends ColorRect
## Popup with Third-Party licenses
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal close_popup


func _on_accept_pressed():
	emit_signal("close_popup")


func _on_third_party_text_meta_clicked(meta):
	OS.shell_open(meta)
