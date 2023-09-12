class_name ThirdPartyPopup
extends ColorRect
## Popup with Third-Party licenses
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


func _on_accept_pressed():
	hide()


func _on_third_party_text_meta_clicked(meta):
	OS.shell_open(meta)
