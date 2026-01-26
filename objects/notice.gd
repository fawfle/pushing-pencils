class_name Notice extends Node2D

@onready var text_label: Label = $TextLabel
@onready var sprite: Sprite2D = $Sprite2D

func set_text(text: String) -> void:
	text_label.text = text

func get_sprite() -> Sprite2D:
	return sprite
