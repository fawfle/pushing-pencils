extends Node2D

var completed: int = 0
var quota: int = 1

@export var events: Array[Event]

var correct_text: String

func _ready() -> void:
	Global.document_submitted.connect(on_document_submitted)

func on_document_submitted(text: String):
	if correct_text == text:
		completed += 1;
		Global.document_completed.emit()
