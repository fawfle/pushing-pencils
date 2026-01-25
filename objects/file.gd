class_name FileItem extends Node2D

@onready var id_label: Label = $IDLabel
@onready var text_label: Label = $TextLabel

@onready var sprite: Sprite2D = $Sprite2D

@onready var shape_sprites: Array[Sprite2D] = [$Shape1, $Shape2, $Shape3]

var shape_count: int = 0

func set_id(id: String) -> void:
	id_label.text = id

func get_id() -> String:
	return id_label.text

func set_text(text: String) -> void:
	text_label.text = text

func add_shape(image) -> void:
	shape_sprites[shape_count].texture = image;
	shape_count += 1;

func get_sprite() -> Sprite2D:
	return sprite
