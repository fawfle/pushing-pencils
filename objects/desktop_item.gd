class_name DesktopItem extends TextureButton

## speed at which item will slide off blocking items
const SLIDEOFF_SPEED: float = 160

@onready var area_2d: Area2D = $"../Area2D"

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO

@export var padding: Vector2 = Vector2(30,30)

var screen_size: Vector2 = Vector2.ZERO
var screen_bounds: Array[Vector2]

var parent: Node2D

@export var click_sounds: Array[AudioStreamPlayer2D]
@export var drop_sounds: Array[AudioStreamPlayer2D]

@export var slide_sounds: Array[AudioStreamPlayer2D]

## if specified, creates a bitmask of the texture using alpha
@export var custom_clickmask_texture: Texture2D

var moving: bool = false
## whether or not item is being animated by external code
var animating: bool = false

func _ready() -> void:
	parent = get_parent()
	update_viewport()
	# get_viewport().size_changed.connect(on_viewport_changed)
	if custom_clickmask_texture:
		add_bitmask_from_texture(custom_clickmask_texture)

func _process(delta: float) -> void:
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
		return
	
	if animating or area_2d == null: return
	# resolve collisions when placed over "blocking" item
	for area in area_2d.get_overlapping_areas():
		if area.is_in_group("blocking") and area.get_parent().get_index() < parent.get_index():
			parent.global_position += (parent.global_position - area.global_position).normalized() * SLIDEOFF_SPEED * delta
			parent.global_position = parent.global_position.clamp(screen_bounds[0], screen_bounds[1])

func _on_button_down() -> void:	
	for area in area_2d.get_overlapping_areas():
		if area.is_in_group("blocking") and area.get_parent().get_index() > parent.get_index():
			return
	
	dragging = true
	animating = false
	offset = parent.get_global_mouse_position() - parent.global_position
	parent.get_parent().move_child(parent, -1)
	parent.z_index = 10
	Global.held = parent
	
	if len(click_sounds) > 0: click_sounds.pick_random().play()


func _on_button_up() -> void:
	if not dragging: return
	
	dragging = false
	Global.held = null
	parent.get_parent().move_child(parent, -1)
	Global.item_dropped.emit(parent)
	parent.z_index = 0
	
	if len(drop_sounds) > 0: drop_sounds.pick_random().play()

func update_viewport() -> void:
	# hardcoded garbage
	screen_size = get_viewport_rect().size # / get_viewport().get_camera_2d().scale
	screen_size /= 4; # scale of camera
	
	screen_bounds = [-screen_size / 2 + padding, screen_size / 2 - padding]

func add_bitmask_from_texture(texture: Texture2D):
	var bitmap = BitMap.new();
	bitmap.create_from_image_alpha(texture.get_image(), 0.9)
	
	# reset position, hopefully match sprite
	position = Vector2.ZERO
	texture_click_mask = bitmap;
