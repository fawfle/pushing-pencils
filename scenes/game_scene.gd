class_name GameManager extends Node2D

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")

var warning_scene: PackedScene = preload("res://objects/warning.tscn")
var memo_scene: PackedScene = preload("res://objects/memo.tscn")
var notice_scene: PackedScene = preload("res://objects/notice.tscn")
var index_card_scene: PackedScene = preload("res://objects/index_card.tscn")

@onready var stamp_sound := $StampSound
@onready var fax_sound := $FaxSound
@onready var paper_slide_sound := $PaperSlideSound


@export var completed: int = 0
# var quota: int = 1

var round_type: ROUND_TYPE = ROUND_TYPE.DOC_FILE

## store current rules without processing randoms
var current_master_rules: Array[Rules.ID] = [Rules.ID.MATCH]
## process randoms
var current_rules: Array[Rules.ID] = [Rules.ID.MATCH]
var current_text: String
var output_text: String
var input: String

# TODO:
# possibly procedural rules/docs for certain spans as an option (i.e. pick random 5 accounting for mutual exclusivity)

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

# for debugging, add if needed
var book_scene: PackedScene = preload("res://objects/book.tscn")
var pen_scene: PackedScene = preload("res://objects/pen.tscn")

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
	var type: DOC_TYPE = DOC_TYPE.WARNING
	var apply_effect ## function to run on created document
	
	func _init(_condition, _text: String, _doc_type: DOC_TYPE=DOC_TYPE.WARNING, _apply_effect=func(_x): return):
		condition = _condition
		text = _text
		type = _doc_type
		apply_effect = _apply_effect
		

enum DOC_TYPE {
	MEMO,
	WARNING,
	NOTICE,
	INDEX_CARD
}

## rejections for specific failure states, meant to teach play
var custom_rejections: Array[CustomRejection] = [
	CustomRejection.new(func(item: Node2D): return (item is Memo), "DO NOT FAX MEMOS"),
	CustomRejection.new(func(item: Node2D): return (item is Warning), "DO NOT FAX WARNINGS"),
	CustomRejection.new(func(item: Node2D): return (item is FileItem), "DO NOT FAX ITEMS"),
	
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.ONLY_LAST_13_LETTERS) and input != Rules.apply(Rules.ID.ONLY_LAST_13_LETTERS, input)), "DUE TO LETTER SHORTAGES, CIRCLE IS CHANGED", DOC_TYPE.NOTICE),
	
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.NO_VOWELS) and input.contains("y")), "CORPORATE HAS DECIDED Y IS ALWAYS A VOWEL", DOC_TYPE.NOTICE),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.NO_VOWELS) and input != Rules.apply(Rules.ID.NO_VOWELS, input)), "VOWELS ARE INEFFICIENT"),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PEN_ONLY) and current_document.used_pencil), "Not Professional"),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PENCIL_ONLY) and current_document.used_pen), "Too Professional\nUse Pencil."),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PENCIL_ONLY) and current_document.used_pen), "PEN", DOC_TYPE.INDEX_CARD, func(x): x.set_fancy_header()),
	CustomRejection.new(func(item: Node2D): return (item is Document) and (current_rules.has(Rules.ID.PENCIL_ONLY) and current_document.used_pen), "PENCIL", DOC_TYPE.INDEX_CARD, func(x): x.set_simple_header())
]

@onready var screen_size = get_viewport_rect().size / 4

var promoted: bool = false

func _ready() -> void:
	Utils.load_wordlist()

	Global.document_submitted.connect(on_document_submitted)
	Global.item_submitted.connect(on_item_submitted)
	
	if completed > 3:
		var book = book_scene.instantiate()
		add_child(book)
		play_enter_animation(book)
	
	if completed > 11:
		var pen = pen_scene.instantiate()
		add_child(pen)
		play_enter_animation(pen, 100)
	
	check_events()
	begin_round()

func check_events() -> void:	
	if events[completed]:
		run_event(events[completed])
		
	if completed == len(events) - 1:
		promoted = true
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://3d_section.tscn")
		return

func run_event(event: Event):
	for scene in event.nodes_to_add:
		var obj: Node = scene.instantiate()
		add_child(obj)
		play_enter_animation(obj, 80)
		
	if event.memo_text != "":
		add_memo(event.memo_text)
	
	if event.notice_text != "":
		add_notice(event.notice_text, 100)
	
	rejection_memo_text = event.rejection_memo_text
	
	if event.update_rules:
		current_master_rules = event.rules
		if current_master_rules.has(Rules.ID.ONLY_LAST_13_LETTERS):
			Global.circle_changed.emit()
	
	# if event.new_quota <= quota:
	# 	quota = event.new_quota
	
	if event.change_round_type:
		round_type = event.round_type

func on_document_submitted(doc_input: String):
	fax_sound.play()
	
	input = doc_input
	remove_child(current_document)
	print("input: " + input)
	print("expected output: " + output_text)
	
	await get_tree().create_timer(2.0).timeout
	
	if check_rules(input):
		completed += 1;
		
		check_events()
		Global.document_completed.emit()
		current_document.queue_free()
		if (completed < len(events)): begin_round()
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
	if promoted:
			return
			
	process_master_rules()
	
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
	
	if current_rules.has(Rules.ID.PEN_ONLY):
		current_document.add_fancy_header()
	set_file_shapes()
	
	var meets_criteria: bool = false
	
	var max_iterations: int = 500
	var iterations:int = 0
	
	while (!meets_criteria) and iterations < max_iterations:
		iterations += 1
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
	stamp.position = Vector2(randf_range(-35, 15), randf_range(-55, 25))
	
	var sprite: Sprite2D = item.get_sprite()
	# set clip children to true :)
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	sprite.add_child(stamp)
	
	stamp_sound.play()
	

# set top deferred to make special objects appear above non special
func play_enter_animation(node: Node2D, set_top_deferred_frames=0):
	paper_slide_sound.play()
	
	var duration: float = randf_range(0.8, 1.2)
	
	var start_position: Vector2 = Vector2(-screen_size.x, randf_range(-10, 10))
	var end_position: Vector2 = Vector2(randf_range(-100, -25), randf_range(-10, 10))
	
	node.global_position = start_position
	
	for i in range(set_top_deferred_frames):
		await get_tree().process_frame
	
	if set_top_deferred_frames > 0: move_child(node, -1)
	
	await get_tree().create_timer(randf_range(0, 0.2)).timeout
	
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	
	while timer.time_left != 0:
		if Global.held == node:
			break
		var t: float = (duration - timer.time_left) / duration
		t = 1 - (1 - t) * (1 - t) # ease out
		node.global_position = lerp(start_position, end_position, t)
		await get_tree().process_frame

func on_item_submitted(item: Node2D):
	fax_sound.play()
	remove_child(item)
	
	await get_tree().create_timer(2.0).timeout
	
	if item is Memo:
		play_stamp_animation(item)
	if item is FileItem:
		play_stamp_animation(item)
	if item is Notice:
		play_stamp_animation(item)
	if item is Warning:
		play_stamp_animation(item)
	
	handle_custom_rejections(item)

func handle_custom_rejections(item: Node2D):
	for custom_rejection in custom_rejections:
		if not custom_rejection.activated and custom_rejection.condition.call(item):
			var obj = null
			match custom_rejection.type:
				DOC_TYPE.WARNING:
					obj = add_warning(custom_rejection.text)
				DOC_TYPE.MEMO:
					obj =add_memo(custom_rejection.text)
				DOC_TYPE.NOTICE:
					obj = add_notice(custom_rejection.text)
				DOC_TYPE.INDEX_CARD:
					obj = add_index_card(custom_rejection.text)
			if obj and custom_rejection.apply_effect:
				custom_rejection.apply_effect.call(obj)
			
			custom_rejection.activated = true

func add_memo(text: String, buffer: int = 60) -> Memo:
	var memo: Memo = memo_scene.instantiate()
	add_child(memo)
	play_enter_animation(memo, buffer)
	memo.set_text(text)
	return memo

func add_warning(text: String, buffer: int = 100) -> Warning:
	var warning: Warning = warning_scene.instantiate()
	add_child(warning)
	warning.set_text(text)
	play_enter_animation(warning, buffer)
	return warning

func add_notice(text: String, buffer: int = 100) -> Notice:
	var notice: Notice = notice_scene.instantiate()
	add_child(notice)
	notice.set_text(text)
	play_enter_animation(notice, buffer)
	return notice

func add_index_card(text: String, buffer: int = 100) -> IndexCard:
	var card: IndexCard = index_card_scene.instantiate()
	add_child(card)
	card.set_text(text)
	play_enter_animation(card, buffer)
	return card

var symbol_rules: Array[Rules.ID] = [Rules.ID.HYPHEN_SPACE, Rules.ID.ONLY_FIRST_13_LETTERS, Rules.ID.REVERSE_EACH_WORD, Rules.ID.NO_VOWELS, Rules.ID.FLIP_CASE, Rules.ID.ALPHABETICAL_ORDER]

func process_master_rules():
	current_rules.clear()
	
	for rule in current_master_rules:
		if rule == Rules.ID.RANDOM_NORMAL or rule == Rules.ID.RANDOM_NEW_CIRCLE:
			var new_rule: Rules.ID = get_unique_random_rule()
			current_rules.append(new_rule)
		else:
			current_rules.append(rule)

func get_unique_random_rule():
	var rule: Rules.ID = symbol_rules.pick_random()
	if rule in current_rules:
		return get_unique_random_rule()
	
	return rule

# TODO
func shredder_storm():
	pass
