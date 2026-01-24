extends Button

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO

@export var PADDING: Vector2 = Vector2(30,30)

var screen_size: Vector2 = Vector2.ZERO
var screen_bounds: Array[Vector2];

var parent: Node

func _ready() -> void:
	parent = get_parent()
	on_viewport_changed()
	get_viewport().size_changed.connect(on_viewport_changed)

func _process(_delta: float) -> void:
	if dragging:
		parent.global_position = get_global_mouse_position() - offset
		parent.global_position = parent.global_position.clamp(screen_bounds[0], screen_bounds[1])

func _on_button_down() -> void:
	dragging = true
	offset = parent.get_global_mouse_position() - parent.global_position
	parent.get_parent().move_child(parent, -1)


func _on_button_up() -> void:
	dragging = false

func on_viewport_changed() -> void:
	# hardcoded garbage
	screen_size = get_viewport_rect().size # / get_viewport().get_camera_2d().scale
	screen_size /= 4; # scale of camera
	
	screen_bounds = [-screen_size / 2 + PADDING, screen_size / 2 - PADDING]
