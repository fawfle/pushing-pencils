class_name GameManager extends Node2D

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")
var memo_scene: PackedScene = preload("res://objects/memo.tscn")

@export var completed: int = 0
var quota: int = 1

var round_type: ROUND_TYPE = ROUND_TYPE.DOC_FILE

var current_rules: Array[Rules.ID] = [Rules.ID.MATCH]
var current_text: String
var output_text: String
var input: String

# TODO:
# possibly procedural rules/docs for certain spans as an option (i.e. pick random 5 accounting for mutual exclusivity)

# TODO: Company WARNINGS instead of memo
## queueish of sorts where events will add/set rejection_memo_text on activating. Could be an array later?
var rejection_memo_text: String

const MAX_LENGTH: int = 14

@export var events: Array[Event]

var current_file: FileItem
var current_document: Document

enum ROUND_TYPE {
	DOC_FILE, # classic
	DOC_ONLY, # only a doc, mainly for tutorial
}

## Special events are enum flags for special function calls like the shredder storm
enum SPECIAL_EVENTS {
	SHREDDER_STORM
}

var stamp_texture: Texture2D = load("res://Sprites/Stamp.png")

var book_scene: PackedScene = preload("res://objects/book.tscn")

var rule_shape_dictionary: Dictionary[Rules.ID, Texture2D] = {
	Rules.ID.REVERSE_EACH_WORD: load("res://Sprites/shapes/shape-0002.png"),
	Rules.ID.NO_VOWELS: load("res://Sprites/shapes/shape-0001.png"),
	Rules.ID.ONLY_FIRST_13_LETTERS: load("res://Sprites/shapes/shape-0003.png"),
	Rules.ID.ONLY_LAST_13_LETTERS: load("res://Sprites/shapes/shape-0003.png"),
	Rules.ID.FLIP_CASE: load("res://Sprites/shapes/shape-0004.png"),
	Rules.ID.ALPHABETICAL_ORDER: load("res://Sprites/shapes/shape-0005.png"),
	Rules.ID.HYPHEN_SPACE: load("res://Sprites/shapes/shape-0006.png"),
}

class CustomRejection:
	var activated: bool = false
	var condition
	var text: String
	
	func _init(_condition, _text: String):
		condition = _condition
		text = _text
	
## rejections for specific failure states, meant to teach play
var custom_rejections: Array[CustomRejection] = [
	CustomRejection.new(func(item: Node2D): return (item is Memo), "DO NOT FAX MEMOS"),
	
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.NO_VOWELS) and input != Rules.apply(Rules.ID.NO_VOWELS, input)), "VOWELS ARE INEFFICIENT"),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PEN_ONLY) and current_document.used_pencil), "Not Professional"),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PENCIL_ONLY) and current_document.used_pen), "Too Professional")
]

@onready var screen_size = get_viewport_rect().size / 4

func _ready() -> void:
	Utils.load_wordlist()
	
	Global.document_submitted.connect(on_document_submitted)
	Global.item_submitted.connect(on_item_submitted)
	check_events()
	begin_round()
	if completed > 3:
		var book = book_scene.instantiate()
		add_child(book)
		play_enter_animation(book)

func check_events() -> void:
	for event in events:
		if (completed == event.on_completed):
			run_event(event)

func run_event(event: Event):
	for scene in event.nodes_to_add:
		var obj: Node = scene.instantiate()
		add_child(obj)
		play_enter_animation(obj, 80)
		
	if event.memo_text != "":
		var memo: Memo = memo_scene.instantiate()
		add_child(memo)
		play_enter_animation(memo, 60)
		memo.set_text(event.memo_text)
	
	rejection_memo_text = event.rejection_memo_text
	
	if event.update_rules:
		current_rules = event.rules
	
	if event.new_quota <= quota:
		quota = event.new_quota
	
	if event.change_round_type:
		round_type = event.round_type

func on_document_submitted(doc_input: String):
	input = doc_input
	remove_child(current_document)
	print("input: " + input)
	print("expected output: " + output_text)
	if check_rules(input):
		completed += 1;
		
		await get_tree().create_timer(0.5).timeout
		
		check_events()
		Global.document_completed.emit()
		current_document.queue_free()
		begin_round()
	else:
		if rejection_memo_text != "":
			var memo: Memo = memo_scene.instantiate()
			add_child(memo)
			memo.set_text(rejection_memo_text)
			play_enter_animation(memo, 100)
			rejection_memo_text = ""
		
		handle_custom_rejections(current_document)
		
		current_document.handle_reset()
		play_stamp_animation(current_document)

func check_rules(source: String) -> bool:
	if current_rules.has(Rules.ID.PENCIL_ONLY) and current_document.used_pen:
		return false
	if current_rules.has(Rules.ID.PEN_ONLY) and current_document.used_pencil:
		return false
	
	if not Rules.check_rules(current_rules, current_text, source):
		return false
	
	return true

func add_file():
	current_document = document_scene.instantiate()
	add_child(current_file)
	play_enter_animation(current_document)

func begin_round():
	match round_type:
		ROUND_TYPE.DOC_FILE:
			begin_file_doc_round()
		ROUND_TYPE.DOC_ONLY:
			begin_doc_only_round()

func begin_file_doc_round():
	current_file = file_scene.instantiate()
	current_document = document_scene.instantiate()
	add_child(current_file)
	add_child(current_document)
	
	play_enter_animation(current_file)
	play_enter_animation(current_document)
		
	var id: String = Utils.generate_doc_id()
	current_file.set_id(id)
	current_document.set_id(id)
	
	set_file_shapes()
	
	var meets_criteria: bool = false
	
	while (!meets_criteria):
		current_text = Utils.generate_sentence(3)
		output_text = Rules.apply_multiple(current_rules, current_text)
		meets_criteria = output_text != "" and current_text.length() < MAX_LENGTH and output_text.length() < MAX_LENGTH
	
	current_file.set_text(current_text)

func begin_doc_only_round():
	current_document = document_scene.instantiate()
	add_child(current_document)
	play_enter_animation(current_document)
	
	current_document.set_id(Utils.generate_doc_id())

## setting file shapes to match round rules. "Rule Changes" just mean two RULE.IDs correspond to the same shape and we discard the old one
# TODO decide what shapes mean
func set_file_shapes():
	for rule in current_rules:
		if rule_shape_dictionary.has(rule):
			current_file.add_shape(rule_shape_dictionary[rule])

func play_stamp_animation(item: Node):	
	if get_children().has(item):
		remove_child(item)
	await get_tree().create_timer(0.4).timeout
	
	add_child(item)
	play_enter_animation(item)

	var stamp: Sprite2D = Sprite2D.new()
	stamp.texture = stamp_texture
	stamp.self_modulate.a = 0.8
	
	stamp.rotate(randf_range(0, 2 * PI))
	stamp.position = Vector2(randf_range(-60, 40), randf_range(-80, 50))
	
	var sprite: Sprite2D = item.get_sprite()
	# set clip children to true :)
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	sprite.add_child(stamp)
	

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

func on_item_submitted(item: Node2D):
	if item is Memo:
		play_stamp_animation(item)
	if item is FileItem:
		play_stamp_animation(item)
	
	handle_custom_rejections(item)

func handle_custom_rejections(item: Node2D):
	for custom_rejection in custom_rejections:
		if not custom_rejection.activated and custom_rejection.condition.call(item):
			var memo: Memo = memo_scene.instantiate()
			add_child(memo)
			memo.set_text(custom_rejection.text)
			play_enter_animation(memo, 100)
			custom_rejection.activated = true

# TODO
func shredder_storm():
	pass
