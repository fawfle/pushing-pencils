class_name Memo extends Node2D

@onready var text_label: Label = $TextLabel

func set_text(text: String) -> void:
	text_label.text = text
