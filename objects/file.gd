class_name File extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	label.text = Utils.generate_doc_id()

func set_id(id: String) -> void:
	label.text = id

func get_id() -> String:
	return label.text
