class_name Document extends Node2D

@onready var label: Label = $Label
@onready var text_box: LineEdit = $TextBox

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
		print("hey")
		text_box.grab_focus.call_deferred()
		text_box.caret_column = text_box.text.length()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Pencil:
		overlapping_pencil = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Pencil:
		overlapping_pencil = false
