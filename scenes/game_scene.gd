extends Node2D

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")

var completed: int = 0
var quota: int = 1

@export var events: Array[Event]

var current_file: Node
var current_document: Node

var correct_text: String

func _ready() -> void:
	Global.document_submitted.connect(on_document_submitted)

func check_events() -> void:
	for event in events:
		if (completed == event.on_completed):
			if event.update_quota:
				quota = event.new_quota

func on_document_submitted(text: String):
	if correct_text == text:
		completed += 1;
		Global.document_completed.emit()

func add_file_and_document():
	file_scene.instantiate()
	document_scene.instantiate()
	
	# var id: String
