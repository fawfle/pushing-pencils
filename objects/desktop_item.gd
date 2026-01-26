class_name DesktopItem extends TextureButton

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO

@export var PADDING: Vector2 = Vector2(30,30)

var screen_size: Vector2 = Vector2.ZERO
var screen_bounds: Array[Vector2]

var parent: Node

# TODO add audio
@export var click_sounds: Array[AudioStreamPlayer2D]
@export var drop_sounds: Array[AudioStreamPlayer2D]

@export var slide_sounds: Array[AudioStreamPlayer2D]

var moving: bool = false

func _ready() -> void:
	parent = get_parent()
	update_viewport()
	# get_viewport().size_changed.connect(on_viewport_changed)

func _process(_delta: float) -> void:
	if dragging:
		var target := get_global_mouse_position() - offset
		if target != parent.global_position:
			if not moving:
				if len(slide_sounds) > 0: slide_sounds.pick_random().play()
			moving = true
		else:
			moving = false
		parent.global_position = target
		parent.global_position = parent.global_position.clamp(screen_bounds[0], screen_bounds[1])

func _on_button_down() -> void:
	dragging = true
	offset = parent.get_global_mouse_position() - parent.global_position
	parent.get_parent().move_child(parent, -1)
	Global.held = parent
	
	if len(click_sounds) > 0: click_sounds.pick_random().play()


func _on_button_up() -> void:
	dragging = false
	Global.held = null
	Global.item_dropped.emit(parent)
	
	if len(drop_sounds) > 0: drop_sounds.pick_random().play()

func update_viewport() -> void:
	# hardcoded garbage
	screen_size = get_viewport_rect().size # / get_viewport().get_camera_2d().scale
	screen_size /= 4; # scale of camera
	
	screen_bounds = [-screen_size / 2 + PADDING, screen_size / 2 - PADDING]
