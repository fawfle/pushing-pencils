class_name Document extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var text_box: LineEdit = $TextBox

var img = Image.load_from_file("res://Sprites/Stamp.png")
var image: ImageTexture = ImageTexture.create_from_image(img)

var overlapping_pencil: bool = false

func _ready() -> void:
	Global.item_dropped.connect(on_item_dropped)

func set_id(id: String) -> void:
	label.text = id

func get_id() -> String:
	return label.text

func on_item_dropped(node: Node):
	if not node is Pencil:
		return
	
	if overlapping_pencil:
		text_box.grab_focus.call_deferred()
		text_box.caret_column = text_box.text.length()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Pencil:
		overlapping_pencil = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Pencil:
		overlapping_pencil = false

func get_text() -> String:
	return text_box.text

func add_rejected_stamp() -> void:
	var stamp: Sprite2D = Sprite2D.new()
	stamp.texture = image
	stamp.self_modulate.a = 0.8
	
	stamp.rotate(randf_range(0, 2 * PI))
	
	# set clip children to true :)
	sprite.add_child(stamp)
