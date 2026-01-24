extends Node2D

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")

var completed: int = 0
var quota: int = 1

var current_rules: Array[Rules.ID] = [Rules.ID.NONE]

@export var events: Array[Event]

var current_file: Node
var current_document: Node

var correct_text: String

func _ready() -> void:
	Global.document_submitted.connect(on_document_submitted)
	
	add_file_and_document()

func check_events() -> void:
	for event in events:
		if (completed == event.on_completed):
			run_event(event)

func run_event(event: Event):
	for scene in event.nodes_to_add:
		scene.instantiate()
	
	if event.update_rules:
		current_rules = event.rules
	
	if event.update_quota:
		quota = event.new_quota

func on_document_submitted(text: String):
	if correct_text == text:
		completed += 1;
		Global.document_completed.emit()

func add_file_and_document():
	current_file = file_scene.instantiate()
	current_document = document_scene.instantiate()
	add_child(current_file)
	add_child(current_document)
	
	var id: String = Utils.generate_doc_id()
	current_file.set_id(id)
	current_document.set_id(id)
