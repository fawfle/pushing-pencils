class_name Bell extends Node2D

@onready var ring_button: TextureButton = $RingButton
@onready var bell_sound: AudioStreamPlayer2D = $BellSound

func _ready() -> void:
	ring_button.button_down.connect(func(): bell_sound.play())
