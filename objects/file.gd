class_name File extends Node2D

@onready var id_label: Label = $IDLabel

func set_id(id: String) -> void:
	id_label.text = id

func get_id() -> String:
	return id_label.text
