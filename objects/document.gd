class_name Document extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var text_box: LineEdit = $TextBox

@onready var pencil_sound: AudioStreamPlayer2D = $PencilWrite

# var img = Image.load_from_file("res://Sprites/Stamp.png")
# var image: ImageTexture = ImageTexture.create_from_image(img)
# @export var stamp_image: Texture2D

enum Instrument {
	PENCIL,
	PEN
}

var instrument: Instrument = Instrument.PENCIL

var overlapping_pencil: bool = false
var overlapping_pen: bool = false

var used_pen: bool = false
var used_pencil: bool = false

var previous_text: String

func _ready() -> void:
	Global.item_dropped.connect(on_item_dropped)

func set_id(id: String) -> void:
	label.text = id

func get_id() -> String:
	return label.text

func on_item_dropped(node: Node):
	if node is Pen and overlapping_pen:
		text_box.grab_focus.call_deferred()
		text_box.caret_column = text_box.text.length()
		previous_text = get_text()
		instrument = Instrument.PEN
	
	if node is Pencil and overlapping_pencil:
		text_box.grab_focus.call_deferred()
		text_box.caret_column = text_box.text.length()
		previous_text = get_text()
		instrument = Instrument.PENCIL

func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Pencil:
		overlapping_pencil = true
	if parent is Pen:
		overlapping_pen = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Pencil:
		overlapping_pencil = false
	if parent is Pen:
		overlapping_pen = false



func get_text() -> String:
	return text_box.text

func get_sprite() -> Sprite2D:
	return $Sprite2D

## for handling fail behavior based on pen/pencil
func handle_reset():
	if (used_pen): text_box.text = ""
	used_pen = false
	used_pencil = false

func _on_text_box_text_changed(new_text: String) -> void:
	# flag to reject used docs used with pencil
	if instrument == Instrument.PENCIL and new_text.length() > previous_text.length():
		used_pencil = true
		if (new_text[new_text.length() - 1] != " "): play_pencil_sound()
	
	if instrument == Instrument.PEN and new_text.length() > previous_text.length():
		used_pen = true
		
	if (used_pen or instrument == Instrument.PEN) and new_text.length() < previous_text.length():
		text_box.text = previous_text
		text_box.caret_column = text_box.text.length()
	else:
		previous_text = new_text

func play_pencil_sound():
	var start_time = pencil_sound.stream.get_length() * randf_range(0, 0.8)
	pencil_sound.play(start_time)
	
	await get_tree().create_timer(0.2).timeout
	
	pencil_sound.stop()
	
