class_name GameManager extends Node2D

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")
var memo_scene: PackedScene = preload("res://objects/memo.tscn")

var completed: int = 0
var quota: int = 1

var current_rules: Array[Rules.ID] = [Rules.ID.ANY]
var current_text: String
var output_text: String

const MAX_LENGTH: int = 14

@export var events: Array[Event]

var current_file: Node
var current_document: Node

enum ROUND_TYPE {
	DOC_FILE, # classic
	DOC_ONLY, # only a doc, mainly for tutorial
}

@onready var screen_size = get_viewport_rect().size / 4

func _ready() -> void:
	Global.document_submitted.connect(on_document_submitted)
	check_events()
	add_file_and_document()

func check_events() -> void:
	for event in events:
		if (completed == event.on_completed):
			run_event(event)

func run_event(event: Event):
	for scene in event.nodes_to_add:
		var obj: Node = scene.instantiate()
		add_child(obj)
		play_enter_animation(obj, 10)
		
	if event.memo_text != "":
		var memo: Memo = memo_scene.instantiate()
		add_child(memo)
		play_enter_animation(memo, 60)
		memo.set_text(event.memo_text)
	
	if event.update_rules:
		current_rules = event.rules
	
	if event.new_quota <= quota:
		quota = event.new_quota

func on_document_submitted(input: String):
	print("input: " + input)
	print("expected output: " + output_text)
	if output_text == input:
		completed += 1;
		check_events()
		Global.document_completed.emit()
		current_document.queue_free()
		add_file_and_document()
	else:
		play_stamp_animation()

func add_file():
	current_document = document_scene.instantiate()
	add_child(current_file)
	play_enter_animation(current_document)

func add_file_and_document():
	current_file = file_scene.instantiate()
	current_document = document_scene.instantiate()
	add_child(current_file)
	add_child(current_document)
	
	play_enter_animation(current_file)
	play_enter_animation(current_document)
		
	var id: String = Utils.generate_doc_id()
	current_file.set_id(id)
	current_document.set_id(id)
	
	var meets_criteria: bool = false
	
	while (!meets_criteria):
		current_text = Utils.generate_sentence(3)
		output_text = Rules.apply_multiple(current_rules, current_text)
		meets_criteria = output_text != "" and current_text.length() < MAX_LENGTH and output_text.length() < MAX_LENGTH
	
	current_file.set_text(current_text)

func play_stamp_animation():
	remove_child(current_document)
	
	await get_tree().create_timer(0.4).timeout
	
	add_child(current_document)
	play_enter_animation(current_document)
	
	current_document.add_rejected_stamp()

# set top deferred to make special objects appear above non special
func play_enter_animation(node: Node2D, set_top_deferred_frames=0):
	var duration: float = randf_range(0.8, 1.2)
	
	var start_position: Vector2 = Vector2(-screen_size.x, randf_range(-10, 10))
	var end_position: Vector2 = Vector2(randf_range(-100, -25), randf_range(-10, 10))
	
	node.global_position = start_position
	
	for i in range(set_top_deferred_frames):
		await get_tree().process_frame
	
	if set_top_deferred_frames > 0: move_child(node, -1)
	
	
	await get_tree().create_timer(randf_range(0, 0.2)).timeout
	
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	
	while timer.time_left != 0 or Global.held == node:
		var t: float = (duration - timer.time_left) / duration
		t = 1 - (1 - t) * (1 - t) # ease out
		node.global_position = lerp(start_position, end_position, t)
		await get_tree().process_frame
