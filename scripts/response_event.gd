class_name ResponseEvent

var activated: bool = false
var index: int = 0
var condition
var messages: Array[Message]
var apply_effect ## function to run on created document

func _init(_condition, _text, _message_type: Message.TYPE=Message.TYPE.WARNING, _apply_effect=func(_x): return):
	var text: Array[String];
	if _text is Array:
		text.assign(_text)
	else:
		text = [_text]
	
	for t in text:
		messages.push_back(Message.new(_message_type, t))
		
	condition = _condition
	apply_effect = _apply_effect

# function chaining to add buffer to custom response
func set_wait_time(time: float) -> ResponseEvent:
	for msg: Message in messages: msg.wait_time = time
	return self

func get_message() -> Message:
	return messages[index]

func update() -> void:
	index += 1
	if index == len(messages):
		activated = true


## responses for specific failure states, meant to teach play
static var response_events: Array[ResponseEvent] = [
	ResponseEvent.new(func(item: Node2D): return (item is Memo), "DO NOT FAX MEMOS"),
	ResponseEvent.new(func(item: Node2D): return (item is Warning), ["DO NOT FAX WARNINGS", "FINAL WARNING FOR FAXING WARNINGS", "YOU HAVE BEEN WARNED"]),
	ResponseEvent.new(func(item: Node2D): return (item is FileItem), "DO NOT FAX ITEMS"),
	ResponseEvent.new(func(item: Node2D): return (item is Pamphlet), "DAMAGE OF INSPIRATIONAL COMPANY MATERIALS"),
	
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.completed == 0) and (GameManager.inst.input.to_lower().replace(" ", "") == "yourname"), "YOU ARE NOT FUNNY", Message.TYPE.WARNING, func(_x): Global.player_name="Not Funny").set_wait_time(1.9),

	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.ONLY_LAST_13_LETTERS) and GameManager.inst.input != Rules.apply(Rules.ID.ONLY_LAST_13_LETTERS, GameManager.inst.input)), "DUE TO LETTER SHORTAGES, CIRCLE IS CHANGED", Message.TYPE.NOTICE),
	
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.NO_VOWELS) and GameManager.inst.input.to_lower().contains("y")), "CORPORATE HAS DECIDED Y IS ALWAYS A VOWEL", Message.TYPE.NOTICE),
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.NO_VOWELS) and GameManager.inst.input != Rules.apply(Rules.ID.NO_VOWELS, GameManager.inst.input)), "VOWELS ARE INEFFICIENT"),
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PEN_ONLY) and GameManager.inst.current_document.used_pencil), "Not Professional"),
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "Too Professional\nUse Pencil."),
	
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "PEN", Message.TYPE.INDEX_CARD, func(x): x.set_fancy_header()).set_wait_time(4.0),
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "PENCIL", Message.TYPE.INDEX_CARD, func(x): x.set_simple_header()).set_wait_time(4.0),
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "ANY", Message.TYPE.INDEX_CARD, func(x): x.set_normal_header()).set_wait_time(4.0),
	
	ResponseEvent.new(func(item: Node2D): return (item is Award) and (item.number == 3), "", Message.TYPE.AWARD_3),
	
	## debug mode
	ResponseEvent.new(func(item: Node2D): return (item is Document) and (GameManager.inst.completed == 0) and GameManager.inst.input == "cheaterxyzxyz", "Entering Debug Mode.\nYou Cheater.", Message.TYPE.NOTICE, func(_x): Global.debug_mode = true).set_wait_time(1.9)
]
