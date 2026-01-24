class_name Document extends Node2D

@onready var label: Label = $Label

func set_id(id: String) -> void:
	label.text = id

func get_id() -> String:
	return label.text
