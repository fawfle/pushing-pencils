class_name Bell extends Node2D

@onready var ring_button: TextureButton = $RingButton
@onready var bell_sound: AudioStreamPlayer2D = $BellSound

var ding_messages: Dictionary[int, Message] = {
	10: Message.new(Message.TYPE.WARNING, "PLEASE BE QUIET"),
	40: Message.new(Message.TYPE.WARNING, "STOP PRESSING THE BELL"),
	90: Message.new(Message.TYPE.WARNING, "NOISY. 1 POINT DEDUCTED"),
	150: Message.new(Message.TYPE.WARNING, "SHUT UP"),
	210: Message.new(Message.TYPE.WARNING, "SHUT UP SHUT UP SHUT UP SHUT UP"),
	300: Message.new(Message.TYPE.WARNING, "BELL COMMITTEE NOTIFIED"),
	400: Message.new(Message.TYPE.WARNING, "AUDITORY EXPERIENCE REVOKED"),
	450: Message.new(Message.TYPE.WARNING, "YOU ARE EASILY ENTERTAINED"), # after bell sound revoked
}

var bell_revoked_threshold: int = 400

var clicked: int = 0

func _ready() -> void:
	ring_button.button_down.connect(play_bell_sound)
	ring_button.button_down.connect(on_button_down)

func on_button_down():
	clicked += 1
	
	var message = ding_messages.get(clicked)
	
	if message != null:
		GameManager.inst.add_message(message)
	
	if clicked == bell_revoked_threshold: revoke_bell();

func revoke_bell():
	ring_button.button_down.disconnect(play_bell_sound)

func play_bell_sound():
	bell_sound.play()
