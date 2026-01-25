class_name File extends Node2D

@onready var id_label: Label = $IDLabel
@onready var text_label: Label = $TextLabel

func set_id(id: String) -> void:
	id_label.text = id

func get_id() -> String:
	return id_label.text

func set_text(text: String) -> void:
	text_label.text = text
