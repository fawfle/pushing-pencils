## Class that manages primary game loop like documents and submitting
class_name GameManager extends Node2D

## Singleton variable for class
static var inst: GameManager

var file_scene: PackedScene = preload("res://objects/file.tscn")
var document_scene: PackedScene = preload("res://objects/document.tscn")

@onready var stamp_sound := $StampSound
@onready var fax_sound := $FaxSound
@onready var paper_slide_sound := $PaperSlideSound

@onready var pencil_timer := $PencilTutorialTimer

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

@onready var screen_size = get_viewport_rect().size / 4

var promoted: bool = false

func _ready() -> void:
	if inst == null:
		inst = self
	
	Utils.load_wordlist()
	
	Global.document_submitted.connect(on_document_submitted)
	Global.item_submitted.connect(on_item_submitted)
	
	pencil_timer.timeout.connect(func(): if completed <= 1: add_message_i(Message.TYPE.WARNING, "USE THE PENCIL TIP. 1 POINT DEDUCTED."))
	
	if completed > 3:
		var book = book_scene.instantiate()
		add_child(book)
		play_enter_animation(book)
	
	if completed > 13:
		var pen = pen_scene.instantiate()
		add_child(pen)
		play_enter_animation(pen, 2.1)
	
	if completed >= 1:
		Global.player_name = "[PLAYER NAME]"
	
	begin_round(completed)

func on_document_submitted(doc_input: String):
	fax_sound.play()
	
	input = doc_input
	remove_child(current_document)
	
	await get_tree().create_timer(2.0).timeout
	
	# check twice
	handle_response_events(current_document)
	
	if check_rules(input):
		complete_round();
	else:
		if rejection_memo_text != "":
			add_message_i(Message.TYPE.MEMO, rejection_memo_text)
			rejection_memo_text = ""
		
		current_document.handle_reset()
		play_stamp_animation(current_document)
	
	# check after
	# handle_custom_responses(current_document)

func complete_round():
	completed += 1;
	
	if completed == 1 and Global.player_name == "":
		Global.player_name = input
		pencil_timer.start()
		
	if completed >= TASK_LIST.TASKS.size() - 1:
		promoted = true
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://3d_section.tscn")
		return
	
	Global.document_completed.emit()
	if current_document: current_document.queue_free()
	if (completed < len(TASK_LIST.TASKS)): begin_round(completed)

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

func begin_round(round_number: int):
	if promoted: return
	
	load_task(TASK_LIST.TASKS[round_number])
	
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
		current_document.add_pen_header()
	elif current_rules.has(Rules.ID.PENCIL_ONLY):
		current_document.add_pencil_header()
	
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
func set_file_shapes():
	for rule in current_rules:
		if Rules.rule_shape_dictionary.has(rule):
			current_file.add_shape(Rules.rule_shape_dictionary[rule])

func play_stamp_animation(item: Node):
	if item == null: return;
	
	if get_children().has(item):
		remove_child(item)
	await get_tree().create_timer(0.4).timeout
	
	add_child(item)
	play_enter_animation(item)

	var stamp: Sprite2D = Sprite2D.new()
	stamp.texture = stamp_texture
	stamp.self_modulate.a = 0.8
	
	stamp.rotate(randf_range(0, 2 * PI))
	var bounds: Vector2 = Vector2.ZERO;
	# terrible code to get collision shape
	for child in item.get_children():
		if child is DesktopItem:
			bounds = (child as DesktopItem).padding
	# account for fact that vertical padding is usually less
	bounds = (bounds + Vector2(0, 15 * floor(bounds.y / 15))).max(Vector2.ZERO)
	stamp.position = Vector2(randf_range(-bounds.x, bounds.x), randf_range(-bounds.y, bounds.y))
	
	var sprite: Sprite2D = item.get_sprite()
	# set clip children to true :)
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	sprite.add_child(stamp)
	
	stamp_sound.play()
	

# set top deferred to make special objects appear above non special
func play_enter_animation(node: Node2D, wait_time: float=0):
	var duration: float = randf_range(0.8, 1.2)
	
	var start_position: Vector2 = Vector2(-screen_size.x, randf_range(-10, 10))
	var end_position: Vector2 = Vector2(randf_range(-100, -25), randf_range(-10, 10))
	
	node.global_position = start_position
	for child in node.get_children():
		if child is DesktopItem:
			child.animating = true
	
	await get_tree().create_timer(wait_time).timeout
	
	if wait_time > 0: move_child(node, -1)
	
	paper_slide_sound.play()
	await get_tree().create_timer(randf_range(0, 0.4)).timeout
	
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	
	while timer.time_left != 0:
		if Global.held == node:
			break
		var t: float = (duration - timer.time_left) / duration
		t = 1 - (1 - t) * (1 - t) # ease out
		node.global_position = lerp(start_position, end_position, t)
		await get_tree().process_frame
	
	if node == null: return
	
	node.global_position = end_position
	for child in node.get_children():
		if child is DesktopItem:
			child.animating = false

func on_item_submitted(item: Node2D):
	if item is Pencil or item is Pen:
		return
	
	if item is Award and item.number == 2:
		item.queue_free()
		# TODO: add photo
		
	# big sad that you can't make an array of types to make this code cleaner.
	elif item is Memo or item is FileItem or item is Notice or item is Warning or item is IndexCard or item is Pamphlet or item is Award:
		fax_sound.play()
		remove_child(item)
		await get_tree().create_timer(2.0).timeout
		play_stamp_animation(item)
	
	handle_response_events(item)

func handle_response_events(item: Node2D):
	for response_event: ResponseEvent in ResponseEvent.response_events:
		if not response_event.activated and response_event.condition.call(item):
			var obj = add_message(response_event.get_message())
			if obj and response_event.apply_effect:
				response_event.apply_effect.call(obj)
			
			response_event.update()

## add message from "Message" data class
func add_message(message: Message) -> Node2D:
	var msg: Node2D = message.instantiate_scene();
	add_child(msg);
	play_enter_animation(msg, message.wait_time)
	msg.set_text(message.text)
	return msg

## add message "inline". No overloads so seperate function
func add_message_i(type: Message.TYPE, text: String, wait_time: float = 1.5):
	var msg: Node2D = Message.type_scenes[type].instantiate();
	add_child(msg);
	play_enter_animation(msg, wait_time)
	msg.set_text(text)
	return msg

func process_master_rules():
	current_rules.clear()
	
	for rule in current_master_rules:
		if rule == Rules.ID.RANDOM_NORMAL or rule == Rules.ID.RANDOM_NEW_CIRCLE:
			var new_rule: Rules.ID = get_unique_random_rule()
			current_rules.append(new_rule)
		else:
			current_rules.append(rule)


## Pool of rules to pick from when selecting random rules
var rule_pool: Array[Rules.ID] = [Rules.ID.HYPHEN_SPACE, Rules.ID.ONLY_FIRST_13_LETTERS, Rules.ID.REVERSE_EACH_WORD, Rules.ID.NO_VOWELS, Rules.ID.FLIP_CASE, Rules.ID.ALPHABETICAL_ORDER]

func get_unique_random_rule():
	var rule: Rules.ID = rule_pool.pick_random()
	if rule in current_rules:
		return get_unique_random_rule()
	
	return rule

# TODO
func shredder_storm():
	pass

## helper function to load data from task data structure
func load_task(task: Task):
	if task.memo_text: add_message_i(Message.TYPE.MEMO, task.memo_text)
	if task.notice_text: add_message_i(Message.TYPE.NOTICE, task.notice_text)
	if task.rejection_memo_text: rejection_memo_text = task.rejection_memo_text
	if task.rules: current_master_rules = task.rules;
	if task.round_type != null: round_type = task.round_type;
	
	if task.nodes_to_add:
		for node in task.nodes_to_add:
			var obj: Node = node.instantiate()
			add_child(obj)
			play_enter_animation(obj, 2.0)


var DEBUG_input_command: String = ""
var DEBUG_input_num: String = ""
func _input(event: InputEvent) -> void:
	if event is not InputEventKey: return;
	event = event as InputEventKey;
	
	if event.pressed and event.keycode == KEY_ENTER:
		DEBUG_handle_command(DEBUG_input_command)
		DEBUG_input_command = ""
	elif event.pressed:
		DEBUG_input_command += event.as_text_keycode();
	
	if not Global.debug_mode:
		return
	
	if event.pressed and event.keycode == KEY_RIGHT:
		complete_round()
	elif event.pressed and event.keycode >= KEY_0 and event.keycode <= KEY_9:
		DEBUG_input_num += event.as_text_keycode();
	elif event.pressed and event.keycode == KEY_ENTER:
		if int(DEBUG_input_num) < TASK_LIST.TASKS.size():
			completed = (int(DEBUG_input_num)) - 1;
			complete_round();
		DEBUG_input_num = "";

func DEBUG_handle_command(command: String):
	print("Entered Command: " + command);
	if command.to_lower() == "enterdebug":
		add_message_i(Message.TYPE.NOTICE, "Entering Debug Mode.\nYou Cheater.", 0.0)
		Global.debug_mode = true
		return;
	
	if not Global.debug_mode: return
	
	match command:
		pass
