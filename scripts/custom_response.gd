class_name CustomResponse

var activated: bool = false
var index: int = 0
var condition
var text: Array[String]
var type: DOC_TYPE = DOC_TYPE.WARNING
var apply_effect ## function to run on created document
## default wait time for custom responses
var wait_time: float = 1.5

func _init(_condition, _text, _doc_type: DOC_TYPE=DOC_TYPE.WARNING, _apply_effect=func(_x): return):		
	if _text is Array:
		text.assign(_text)
	else:
		text = [_text]
		
	condition = _condition
	type = _doc_type
	apply_effect = _apply_effect

# function chaining to add buffer to custom response
func set_wait_time(time: float) -> CustomResponse:
	wait_time = time
	return self

func get_text():
	return text[index]

func update():
	index += 1
	if index == len(text):
		activated = true

enum DOC_TYPE {
	MEMO,
	WARNING,
	NOTICE,
	INDEX_CARD,
	AWARD_3
}


## responses for specific failure states, meant to teach play
static var custom_responses: Array[CustomResponse] = [
	CustomResponse.new(func(item: Node2D): return (item is Memo), "DO NOT FAX MEMOS"),
	CustomResponse.new(func(item: Node2D): return (item is Warning), ["DO NOT FAX WARNINGS", "FINAL WARNING FOR FAXING WARNINGS", "YOU HAVE BEEN WARNED"]),
	CustomResponse.new(func(item: Node2D): return (item is FileItem), "DO NOT FAX ITEMS"),
	CustomResponse.new(func(item: Node2D): return (item is Pamphlet), "DAMAGE OF INSPIRATIONAL COMPANY MATERIALS"),
	
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.completed == 0) and (GameManager.inst.input.to_lower().replace(" ", "") == "yourname"), "YOU ARE NOT FUNNY", DOC_TYPE.WARNING, func(_x): Global.player_name="Not Funny").set_wait_time(1.9),

	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.ONLY_LAST_13_LETTERS) and GameManager.inst.input != Rules.apply(Rules.ID.ONLY_LAST_13_LETTERS, GameManager.inst.input)), "DUE TO LETTER SHORTAGES, CIRCLE IS CHANGED", DOC_TYPE.NOTICE),
	
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.NO_VOWELS) and GameManager.inst.input.to_lower().contains("y")), "CORPORATE HAS DECIDED Y IS ALWAYS A VOWEL", DOC_TYPE.NOTICE),
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.NO_VOWELS) and GameManager.inst.input != Rules.apply(Rules.ID.NO_VOWELS, GameManager.inst.input)), "VOWELS ARE INEFFICIENT"),
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PEN_ONLY) and GameManager.inst.current_document.used_pencil), "Not Professional"),
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "Too Professional\nUse Pencil."),
	
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "PEN", DOC_TYPE.INDEX_CARD, func(x): x.set_fancy_header()).set_wait_time(4.0),
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "PENCIL", DOC_TYPE.INDEX_CARD, func(x): x.set_simple_header()).set_wait_time(4.0),
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.current_rules.has(Rules.ID.PENCIL_ONLY) and GameManager.inst.current_document.used_pen), "ANY", DOC_TYPE.INDEX_CARD, func(x): x.set_normal_header()).set_wait_time(4.0),
	
	CustomResponse.new(func(item: Node2D): return (item is Award) and (item.number == 3), "", DOC_TYPE.AWARD_3),
	
	## debug mode
	CustomResponse.new(func(item: Node2D): return (item is Document) and (GameManager.inst.completed == 0) and GameManager.inst.input == "cheaterxyzxyz", "Entering Debug Mode.\nYou Cheater.", DOC_TYPE.NOTICE, func(_x): Global.debug_mode = true).set_wait_time(1.9)
]
