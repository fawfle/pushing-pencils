extends TextureButton

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO

@export var PADDING: Vector2 = Vector2(30,30)

var screen_size: Vector2 = Vector2.ZERO
var screen_bounds: Array[Vector2]

var parent: Node

var entering: bool = false

func _ready() -> void:
	parent = get_parent()
	on_viewport_changed()
	get_viewport().size_changed.connect(on_viewport_changed)

func _process(_delta: float) -> void:
	if entering:
		
		return
	
	if dragging:
		parent.global_position = get_global_mouse_position() - offset
		parent.global_position = parent.global_position.clamp(screen_bounds[0], screen_bounds[1])

func _on_button_down() -> void:
	dragging = true
	offset = parent.get_global_mouse_position() - parent.global_position
	parent.get_parent().move_child(parent, -1)
	Global.held = parent


func _on_button_up() -> void:
	dragging = false
	Global.held = null
	Global.item_dropped.emit(parent)

func on_viewport_changed() -> void:
	# hardcoded garbage
	screen_size = get_viewport_rect().size # / get_viewport().get_camera_2d().scale
	screen_size /= 4; # scale of camera
	
	screen_bounds = [-screen_size / 2 + PADDING, screen_size / 2 - PADDING]

func play_enter_animation():
	var start_position = Vector2(-screen_bounds[0].x, randf_range(-10, 10))
	var end_position = Vector2(-screen_bounds[0].x * 0.25, randf_range(-10, 10))
	
	var duration: float = 1.0;
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	
	while (not timer.is_stopped()):
		parent.global_position = lerp(start_position, end_position, (duration - timer.time_left) / duration)
		
		await get_tree().process_frame
