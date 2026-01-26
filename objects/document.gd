class_name Document extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var text_box: LineEdit = $TextBox

@onready var pencil_sound: AudioStreamPlayer2D = $PencilWrite
@onready var eraser_sound: AudioStreamPlayer2D = $EraserSound
@onready var pen_sound: AudioStreamPlayer2D = $PenWrite

@onready var fancy_header: Sprite2D = $FancyHeader

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

@onready var pencil_sound_timer: Timer = $PencilSoundTimer
@onready var eraser_sound_timer: Timer = $EraserSoundTimer
@onready var pen_sound_timer: Timer = $PenSoundTimer

func _ready() -> void:
	Global.item_dropped.connect(on_item_dropped)
	pencil_sound_timer.timeout.connect(func(): pencil_sound.stop())
	eraser_sound_timer.timeout.connect(func(): eraser_sound.stop())
	pen_sound_timer.timeout.connect(func(): pen_sound.stop())

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
		if (new_text[new_text.length() - 1] != " "): play_pen_sound()
		
	if (used_pen or instrument == Instrument.PEN) and new_text.length() < previous_text.length():
		text_box.text = previous_text
		text_box.caret_column = text_box.text.length()
		return
	
	if instrument == Instrument.PENCIL and new_text.length() < previous_text.length():
		if previous_text[previous_text.length() - 1] != " ": play_eraser_sound()
	
	previous_text = new_text
	

func play_pencil_sound():
	if (pencil_sound.playing):
		pencil_sound_timer.start(0.1)
		return
	
	pencil_sound_timer.start(0.1)
	var start_time = pencil_sound.stream.get_length() * randf_range(0, 0.8)
	pencil_sound.play(start_time)

func play_pen_sound():
	if (pen_sound.playing):
		pen_sound_timer.start(0.1)
		return
	
	pen_sound_timer.start(0.1)
	var start_time = pen_sound.stream.get_length() * randf_range(0, 0.8)
	pen_sound.play(start_time)

func play_eraser_sound():
	if eraser_sound.playing:
		eraser_sound_timer.start(0.1)
		return
		
	eraser_sound_timer.start(0.1)
	var start_time = eraser_sound.stream.get_length() * randf_range(0, 0.7)
	eraser_sound.play(start_time)

func add_fancy_header():
	fancy_header.visible = true
