extends Button

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO

const PADDING: Vector2 = Vector2(10,10)

var screen_size: Vector2 = Vector2.ZERO

var parent: Node

func _ready() -> void:
	parent = get_parent()
	on_viewport_changed()
	get_viewport().size_changed.connect(on_viewport_changed)

func _process(_delta: float) -> void:
	if dragging:
		parent.global_position = get_global_mouse_position() - offset
		parent.global_position = parent.global_position.clamp(PADDING, screen_size - PADDING)

func _on_button_down() -> void:
	dragging = true
	offset = parent.get_global_mouse_position() - parent.global_position


func _on_button_up() -> void:
	dragging = false

func on_viewport_changed() -> void:
	screen_size = get_viewport_rect().size
